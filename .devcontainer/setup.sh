#!/bin/bash
set -euo pipefail

echo "=== Initialising Kubernetes infrastructure ==="

for tool in docker kind kubectl helm; do
  if ! command -v "$tool" >/dev/null 2>&1; then
    echo "ERROR: required tool '$tool' is not installed."
    exit 1
  fi
done

echo "Waiting for Docker daemon..."
DOCKER_READY=false
for i in {1..10}; do
  if docker info >/dev/null 2>&1; then
    DOCKER_READY=true
    break
  fi
  echo "Docker daemon is still starting up... ($i/10)"
  sleep 3
done

if [ "$DOCKER_READY" != true ]; then
  echo "ERROR: Docker daemon failed to become reachable."
  exit 1
fi

echo "Docker is ready."

if ! kind get clusters 2>/dev/null | grep -q '^cloudnative-cluster$'; then
  echo "Creating KinD cluster (this can take 1-2 minutes)..."
  kind create cluster --name cloudnative-cluster --wait 5m
else
  echo "KinD cluster already exists."
fi

kind export kubeconfig --name cloudnative-cluster

echo "Waiting for Kubernetes API..."
K8S_READY=false
for i in {1..20}; do
  if kubectl cluster-info >/dev/null 2>&1; then
    K8S_READY=true
    break
  fi
  sleep 3
done

if [ "$K8S_READY" != true ]; then
  echo "ERROR: Kubernetes control plane failed to respond."
  exit 1
fi

echo "Kubernetes is ready."

echo "=== Applying app infrastructure ==="
# Ensure the namespace exists so infra manifests can be applied
kubectl get namespace cloudnative-devops >/dev/null 2>&1 || kubectl create namespace cloudnative-devops

# We let Helm own the app resources (ConfigMap, Secret, Service, Deployment)
# Apply infra first (Postgres/Redis PVCs and DB services)
kubectl apply -f k8s/postgres-pvc.yaml -n cloudnative-devops || true
kubectl apply -f k8s/postgres-deployment.yaml -n cloudnative-devops || true
kubectl apply -f k8s/postgres-service.yaml -n cloudnative-devops || true
kubectl apply -f k8s/postgres-test-deployment.yaml -n cloudnative-devops || true
kubectl apply -f k8s/postgres-test-service.yaml -n cloudnative-devops || true
kubectl apply -f k8s/redis-deployment.yaml -n cloudnative-devops || true
kubectl apply -f k8s/redis-service.yaml -n cloudnative-devops || true

kubectl rollout status deployment/postgres -n cloudnative-devops --timeout=3m
kubectl rollout status deployment/redis -n cloudnative-devops --timeout=3m

echo "=== Deploying FastAPI via Helm ==="
if [ -d "helm/fastapi" ]; then
  helm lint helm/fastapi
  # Clean up any previous release or conflicting resources so Helm can own them
  helm uninstall fastapi -n cloudnative-devops --ignore-not-found || true
  kubectl delete deployment fastapi-deployment -n cloudnative-devops --ignore-not-found || true
  kubectl delete service fastapi-service -n cloudnative-devops --ignore-not-found || true
  kubectl delete configmap fastapi-config -n cloudnative-devops --ignore-not-found || true
  kubectl delete secret postgres-secret -n cloudnative-devops --ignore-not-found || true

  helm upgrade --install fastapi helm/fastapi \
    --namespace cloudnative-devops --create-namespace \
    --wait --rollback-on-failure --timeout=5m
else
  echo "Warning: helm/fastapi chart source directory not found. Skipping app deployment."
fi

echo "=== Installing ingress and cert-manager ==="
helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx --force-update >/dev/null 2>&1 || true
helm repo add jetstack https://charts.jetstack.io --force-update >/dev/null 2>&1 || true
helm repo update >/dev/null 2>&1

helm upgrade --install ingress-nginx ingress-nginx/ingress-nginx \
  --namespace ingress-nginx --create-namespace --wait --timeout=5m
helm upgrade --install cert-manager jetstack/cert-manager \
  --namespace cert-manager --create-namespace --set crds.enabled=true --wait --timeout=5m

echo "=== Applying monitoring and routing resources ==="
kubectl apply -f monitoring/prometheus-configmap.yaml -n cloudnative-devops
kubectl apply -f monitoring/prometheus-deployment.yaml -n cloudnative-devops
kubectl apply -f monitoring/prometheus-service.yaml -n cloudnative-devops
kubectl apply -f monitoring/grafana-deployment.yaml -n cloudnative-devops
kubectl apply -f monitoring/grafana-service.yaml -n cloudnative-devops
kubectl apply -f k8s/clusterissuer.yaml
kubectl apply -f k8s/ingress.yaml -n cloudnative-devops

if [ -f "k8s/hpa.yaml" ]; then
  kubectl apply -f k8s/hpa.yaml -n cloudnative-devops
fi

echo "=== Provisioning metrics server ==="
kubectl apply -f https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml
kubectl -n kube-system patch deployment metrics-server --type='json' \
  -p='[{"op":"add","path":"/spec/template/spec/containers/0/args/-","value":"--kubelet-insecure-tls"}]'

echo "=== Verifying rollout status ==="
kubectl rollout status deployment/fastapi-deployment -n cloudnative-devops --timeout=3m
kubectl rollout status deployment/prometheus -n cloudnative-devops --timeout=3m
kubectl rollout status deployment/grafana -n cloudnative-devops --timeout=3m
kubectl rollout status deployment/metrics-server -n kube-system --timeout=3m

echo "=== Configuring local DNS and port-forwarding ==="
if ! grep -q '^127\.0\.0\.1 fastapi\.local$' /etc/hosts; then
  echo "Injecting entry '127.0.0.1 fastapi.local' into /etc/hosts..."
  echo "127.0.0.1 fastapi.local" | sudo tee -a /etc/hosts >/dev/null
else
  echo "DNS entry for fastapi.local already present."
fi

cat <<'EOF' >/tmp/k8s-port-forward.sh
#!/bin/bash
while true; do
  if ! nc -z localhost 9090 &>/dev/null; then
    kubectl port-forward svc/prometheus 9090:9090 -n cloudnative-devops &>/dev/null &
  fi
  if ! nc -z localhost 3000 &>/dev/null; then
    kubectl port-forward svc/grafana 3000:3000 -n cloudnative-devops &>/dev/null &
  fi
  if ! nc -z localhost 8000 &>/dev/null; then
    kubectl port-forward svc/fastapi-service 8000:8000 -n cloudnative-devops &>/dev/null &
  fi
  if ! nc -z localhost 8443 &>/dev/null; then
    kubectl port-forward -n ingress-nginx svc/ingress-nginx-controller 8443:443 &>/dev/null &
  fi
  sleep 10
done
EOF

chmod +x /tmp/k8s-port-forward.sh
nohup /tmp/k8s-port-forward.sh >/dev/null 2>&1 &

echo "=== Setup successfully finalised! ==="
echo "FastAPI API Endpoint → http://localhost:8000"
echo "Prometheus Metrics   → http://localhost:9090"
echo "Grafana Dashboard    → http://localhost:3000"
echo "FastAPI HTTPS Endpoint → https://fastapi.local:8443/health"