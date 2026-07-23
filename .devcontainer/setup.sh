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

add_helm_repos() {
  helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx --force-update >/dev/null 2>&1 || true
  helm repo add jetstack https://charts.jetstack.io --force-update >/dev/null 2>&1 || true
  helm repo add metrics-server https://kubernetes-sigs.github.io/metrics-server --force-update >/dev/null 2>&1 || true
  helm repo update >/dev/null 2>&1
}

install_cert_manager() {
  echo "=== Installing cert-manager ==="
  helm upgrade --install cert-manager jetstack/cert-manager     --namespace cert-manager --create-namespace     --set installCRDs=true     --wait --timeout=5m
}

install_ingress_nginx() {
  echo "=== Installing ingress-nginx ==="
  helm upgrade --install ingress-nginx ingress-nginx/ingress-nginx     --namespace ingress-nginx --create-namespace     --wait --timeout=5m
}

install_metrics_server() {
  echo "=== Installing metrics-server ==="

  if ! helm status metrics-server -n kube-system >/dev/null 2>&1; then
    echo "Checking for unmanaged metrics-server resources in kube-system..."
    kubectl delete deployment metrics-server -n kube-system --ignore-not-found=true || true
    kubectl delete service metrics-server -n kube-system --ignore-not-found=true || true
    kubectl delete serviceaccount metrics-server -n kube-system --ignore-not-found=true || true
    kubectl delete rolebinding metrics-server-auth-reader -n kube-system --ignore-not-found=true || true
    kubectl delete clusterrole system:metrics-server --ignore-not-found=true || true
    kubectl delete clusterrolebinding metrics-server:system:auth-delegator --ignore-not-found=true || true
    kubectl delete clusterrolebinding system:metrics-server --ignore-not-found=true || true
    kubectl delete apiservice v1beta1.metrics.k8s.io --ignore-not-found=true || true
  fi

  helm upgrade --install metrics-server metrics-server/metrics-server \
    --namespace kube-system --create-namespace \
    --wait --rollback-on-failure --timeout=5m \
    --set args={"--kubelet-insecure-tls"}
}

ensure_namespace() {
  local ns="$1"
  if ! kubectl get namespace "$ns" >/dev/null 2>&1; then
    kubectl create namespace "$ns"
  fi
  
  echo "Applying Pod Security Standards to $ns..."
  #kubectl label namespace "$ns" pod-security.kubernetes.io/enforce=baseline --overwrite
  #kubectl label namespace "$ns" pod-security.kubernetes.io/warn=restricted --overwrite
  kubectl label namespace "$ns" pod-security.kubernetes.io/enforce=baseline pod-security.kubernetes.io/warn=restricted --overwrite
}

cat > /tmp/k8s-port-forward.sh <<'EOF'
#!/bin/bash
set -euo pipefail

check_local_port() {
  local port="$1"
  if command -v ss >/dev/null 2>&1; then
    if ss -ltn "( sport = :$port )" 2>/dev/null | grep -q LISTEN; then
      return 0
    fi
  elif command -v lsof >/dev/null 2>&1; then
    if lsof -iTCP:"$port" -sTCP:LISTEN >/dev/null 2>&1; then
      return 0
    fi
  fi
  return 1
}

start_forward() {
  local name="$1"
  local local_port="$2"
  local remote_port="$3"
  local namespace="${4:-cloudnative-devops}"

  if ! check_local_port "$local_port"; then
    if ! pgrep -f "kubectl port-forward -n $namespace svc/$name $local_port:$remote_port" >/dev/null 2>&1; then
      kubectl port-forward -n "$namespace" svc/"$name" "$local_port:$remote_port" >> /tmp/k8s-port-forward.log 2>&1 &
    fi
  fi
}

while true; do
  start_forward prometheus 9090 9090 cloudnative-devops
  start_forward grafana 3000 3000 cloudnative-devops
  start_forward fastapi-service 8000 8000 cloudnative-devops
  start_forward ingress-nginx-controller 8443 443 ingress-nginx
  sleep 10
done
EOF

chmod +x /tmp/k8s-port-forward.sh

add_helm_repos
install_cert_manager
install_ingress_nginx
install_metrics_server

ensure_namespace cloudnative-devops

echo "=== Preparing local storage paths for hostPath volumes ==="
for node in $(kind get nodes --name cloudnative-cluster 2>/dev/null || true); do
  docker exec "$node" mkdir -p /data/postgres /data/redis >/dev/null 2>&1 || true
done

echo "=== Deploying Helm infrastructure ==="
if [ -d "charts/infra" ]; then
  helm lint charts/infra
  if ! helm status infra -n cloudnative-devops >/dev/null 2>&1; then
    echo "Cleaning unmanaged infra resources before installing infra chart..."
    kubectl delete clusterissuer selfsigned-issuer --ignore-not-found=true || true
    kubectl delete pvc postgres-pvc redis-pvc -n cloudnative-devops --ignore-not-found=true || true
    kubectl delete pv postgres-pv redis-pv --ignore-not-found=true || true
    kubectl delete statefulset postgres -n cloudnative-devops --ignore-not-found=true || true
    kubectl delete deployment redis -n cloudnative-devops --ignore-not-found=true || true
  fi
  #helm upgrade --install infra charts/infra     --namespace cloudnative-devops --create-namespace     --wait --rollback-on-failure --timeout=5m
  helm upgrade --install infra charts/infra \
    --namespace cloudnative-devops --create-namespace \
    --wait --timeout=5m
else
  echo "Warning: charts/infra chart source directory not found. Skipping infrastructure deployment."
fi

echo "=== Deploying FastAPI via Helm ==="
if [ -d "charts/fastapi" ]; then
  helm lint charts/fastapi
  helm upgrade --install fastapi charts/fastapi     --namespace cloudnative-devops --create-namespace     --wait --rollback-on-failure --timeout=5m
else
  echo "Warning: charts/fastapi chart source directory not found. Skipping app deployment."
fi

echo "=== Deploying monitoring stack via Helm ==="
if [ -d "charts/monitoring" ]; then
  helm lint charts/monitoring
  helm upgrade --install monitoring charts/monitoring     --namespace cloudnative-devops --create-namespace     --wait --rollback-on-failure --timeout=5m
else
  echo "Warning: charts/monitoring chart source directory not found. Skipping monitoring deployment."
fi

echo "=== Verifying rollout status ==="
kubectl rollout status statefulset/postgres -n cloudnative-devops --timeout=3m
kubectl rollout status deployment/redis -n cloudnative-devops --timeout=3m

nohup /tmp/k8s-port-forward.sh >/tmp/k8s-port-forward.log 2>&1 &

echo "=== Setup successfully finalised! ==="
echo "FastAPI API Endpoint → http://localhost:8000"
echo "Prometheus Metrics   → http://localhost:9090"
echo "Grafana Dashboard    → http://localhost:3000"
echo "FastAPI HTTPS Endpoint → https://fastapi.local:8443/health"
