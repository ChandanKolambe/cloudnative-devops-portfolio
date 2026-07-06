#!/bin/bash
set -e

echo "=== Initialising Kubernetes Infrastructure ==="

# 1. Structural delay to let the Docker background service wake up safely
echo "Pausing 15 seconds for background daemon initialization..."
sleep 15

# 2. Polling loop to confirm Docker socket accessibility without crashing
echo "Verifying Docker service stability..."
set +e
DOCKER_READY=false
for i in {1..10}; do
  if docker info &> /dev/null; then
    DOCKER_READY=true
    break
  fi
  echo "Docker daemon is starting up, retrying in 3 seconds... ($i/10)"
  sleep 3
done
set -e

if [ "$DOCKER_READY" != true ]; then
  echo "ERROR: Docker daemon failed to become reachable. Exiting."
  exit 1
fi
echo "Docker is online and stable!"

# 3. Spin up the KinD cluster safely if missing
if ! kind get clusters 2>/dev/null | grep -q "cloudnative-cluster"; then
  echo "Creating KinD cluster (this takes 1-2 minutes)..."
  kind create cluster --name cloudnative-cluster
else
  echo "KinD cluster already exists."
fi

# 4. Sync configuration credentials
echo "Loading cluster kubeconfig credentials..."
kind export kubeconfig --name cloudnative-cluster

# 5. Wait for API gateway readiness with a maximum timeout ceiling
echo "Validating Kubernetes API stability..."
set +e
K8S_READY=false
for i in {1..20}; do
  if kubectl cluster-info &> /dev/null; then
    K8S_READY=true
    break
  fi
  sleep 3
done
set -e

if [ "$K8S_READY" != true ]; then
  echo "ERROR: Kubernetes control plane failed to respond."
  exit 1
fi
echo "Kubernetes is online!"

# ----------------------------------------------------------------------------
# 6. High-Speed Parallel Manifest Triggering
# ----------------------------------------------------------------------------
echo "=== Triggering All Deployments In Parallel ==="

echo "--> Applying Namespace and RBAC..."
kubectl apply -f k8s/namespace.yaml --validate=false
kubectl apply -f k8s/fastapi-serviceaccount.yaml -n cloudnative-devops
kubectl apply -f k8s/fastapi-role.yaml -n cloudnative-devops
kubectl apply -f k8s/fastapi-rolebinding.yaml -n cloudnative-devops

echo "--> Triggering App Infrastructure (Postgres, Redis, FastAPI)..."
kubectl apply -f k8s/configmap.yaml -n cloudnative-devops
kubectl apply -f k8s/secret.yaml -n cloudnative-devops
kubectl apply -f k8s/postgres-pvc.yaml -n cloudnative-devops
kubectl apply -f k8s/postgres-deployment.yaml -n cloudnative-devops
kubectl apply -f k8s/postgres-service.yaml -n cloudnative-devops
kubectl apply -f k8s/postgres-test-deployment.yaml -n cloudnative-devops
kubectl apply -f k8s/postgres-test-service.yaml -n cloudnative-devops
kubectl apply -f k8s/redis-deployment.yaml -n cloudnative-devops
kubectl apply -f k8s/redis-service.yaml -n cloudnative-devops
kubectl apply -f k8s/deployment.yaml -n cloudnative-devops --validate=false
kubectl apply -f k8s/fastapi-service.yaml -n cloudnative-devops

echo "--> Triggering Helm Extensions (Ingress + Cert-Manager)..."
helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx > /dev/null 2>&1
helm repo add jetstack https://charts.jetstack.io > /dev/null 2>&1
helm repo update > /dev/null 2>&1

helm upgrade --install ingress-nginx ingress-nginx/ingress-nginx --namespace ingress-nginx --create-namespace --timeout=2m0s
helm upgrade --install cert-manager jetstack/cert-manager --namespace cert-manager --create-namespace --set crds.enabled=true --timeout=2m0s

echo "--> Triggering Telemetry, Routing & Autoscaling Components..."
kubectl apply -f monitoring/prometheus-configmap.yaml -n cloudnative-devops
kubectl apply -f monitoring/prometheus-deployment.yaml -n cloudnative-devops
kubectl apply -f monitoring/prometheus-service.yaml -n cloudnative-devops
kubectl apply -f monitoring/grafana-deployment.yaml -n cloudnative-devops
kubectl apply -f monitoring/grafana-service.yaml -n cloudnative-devops
kubectl apply -f k8s/clusterissuer.yaml
kubectl apply -f k8s/ingress.yaml -n cloudnative-devops

# ADDED: Deploy Horizontal Pod Autoscaler manifest
if [ -f "k8s/hpa.yaml" ]; then
  kubectl apply -f k8s/hpa.yaml -n cloudnative-devops
fi

# ----------------------------------------------------------------------------
# ADDED: Idempotent Metrics Server Core Provisioner & Patch Controller
# ----------------------------------------------------------------------------
echo "--> Provisioning Kubernetes Metrics Engine API..."
kubectl apply -f https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml
echo "--> Applying KinD insecure TLS patches to Metrics Server deployment..."
kubectl -n kube-system patch deployment metrics-server --type='json' \
  -p='[{"op":"add","path":"/spec/template/spec/containers/0/args/-","value":"--kubelet-insecure-tls"}]'

# ----------------------------------------------------------------------------
# Sequential Verification Block (Now fast because downloads happen together)
# ----------------------------------------------------------------------------
echo "=== Verifying Health and Rollout States ==="
echo "Waiting for core system workloads to compile..."

kubectl rollout status deployment/postgres -n cloudnative-devops --timeout=3m
kubectl rollout status deployment/redis -n cloudnative-devops --timeout=3m
kubectl rollout status deployment/fastapi-deployment -n cloudnative-devops --timeout=3m
kubectl rollout status deployment/prometheus -n cloudnative-devops --timeout=3m
kubectl rollout status deployment/grafana -n cloudnative-devops --timeout=3m
kubectl rollout status deployment/metrics-server -n kube-system --timeout=3m

# ----------------------------------------------------------------------------
# Automated DNS Routing Mapping & Background Tunnels
# ----------------------------------------------------------------------------
echo "--> Verifying Local DNS Routing Mapping..."
if ! grep -q "fastapi.local" /etc/hosts; then
  echo "Injecting entry '127.0.0.1 fastapi.local' into /etc/hosts..."
  echo "127.0.0.1 fastapi.local" | sudo tee -a /etc/hosts > /dev/null
else
  echo "DNS entry for fastapi.local already present."
fi

echo "Initialising background port-forward controller..."
cat << 'EOF' > /tmp/k8s-port-forward.sh
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

echo "=== Setup Successfully Finalised! ==="
echo "FastAPI API Endpoint → http://localhost:8000"
echo "Prometheus Metrics   → http://localhost:9090"
echo "Grafana Dashboard    → http://localhost:3000"
echo "FastAPI HTTPS Endpoint → https://fastapi.local:8443/health"
