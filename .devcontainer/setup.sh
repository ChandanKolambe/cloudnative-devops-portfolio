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
# 6. Refactored Sequential Deployment Sequence
# ----------------------------------------------------------------------------
echo "=== Beginning Sequential App & Infrastructure Deployment ==="

echo "--> Applying Namespace and RBAC..."
kubectl apply -f k8s/namespace.yaml --validate=false
kubectl apply -f k8s/fastapi-serviceaccount.yaml -n cloudnative-devops
kubectl apply -f k8s/fastapi-role.yaml -n cloudnative-devops
kubectl apply -f k8s/fastapi-rolebinding.yaml -n cloudnative-devops

echo "--> Applying ConfigMaps, Secrets, PVCs, Postgres, Redis..."
kubectl apply -f k8s/configmap.yaml -n cloudnative-devops
kubectl apply -f k8s/secret.yaml -n cloudnative-devops
kubectl apply -f k8s/postgres-pvc.yaml -n cloudnative-devops
kubectl apply -f k8s/postgres-deployment.yaml -n cloudnative-devops
kubectl apply -f k8s/postgres-service.yaml -n cloudnative-devops
kubectl rollout status deployment/postgres -n cloudnative-devops --timeout=90s

kubectl apply -f k8s/postgres-test-deployment.yaml -n cloudnative-devops
kubectl apply -f k8s/postgres-test-service.yaml -n cloudnative-devops

kubectl apply -f k8s/redis-deployment.yaml -n cloudnative-devops
kubectl apply -f k8s/redis-service.yaml -n cloudnative-devops
kubectl rollout status deployment/redis -n cloudnative-devops --timeout=90s

echo "--> Deploying FastAPI Application Layer..."
kubectl apply -f k8s/deployment.yaml -n cloudnative-devops --validate=false
kubectl apply -f k8s/fastapi-service.yaml -n cloudnative-devops
kubectl rollout status deployment/fastapi-deployment -n cloudnative-devops --timeout=90s

echo "--> Deploying Prometheus and Grafana Telemetry Layer..."
kubectl apply -f monitoring/prometheus-configmap.yaml -n cloudnative-devops
kubectl apply -f monitoring/prometheus-deployment.yaml -n cloudnative-devops
kubectl apply -f monitoring/prometheus-service.yaml -n cloudnative-devops
kubectl rollout status deployment/prometheus -n cloudnative-devops --timeout=90s

kubectl apply -f monitoring/grafana-deployment.yaml -n cloudnative-devops
kubectl apply -f monitoring/grafana-service.yaml -n cloudnative-devops
kubectl rollout status deployment/grafana -n cloudnative-devops --timeout=90s

# ----------------------------------------------------------------------------
# 7. Resilient background port-forwarding engine (With Namespaces Fixed)
# ----------------------------------------------------------------------------
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
  sleep 10
done
EOF

chmod +x /tmp/k8s-port-forward.sh
nohup /tmp/k8s-port-forward.sh >/dev/null 2>&1 &

echo "=== Setup Successfully Finalised! ==="
echo "FastAPI API Endpoint → http://localhost:8000"
echo "Prometheus Metrics   → http://localhost:9090"
echo "Grafana Dashboard    → http://localhost:3000"
