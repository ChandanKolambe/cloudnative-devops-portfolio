#!/bin/bash
set -e

echo "=== Initialising Kubernetes Infrastructure ==="

# 1. Spin up the KinD cluster safely
if ! kind get clusters 2>/dev/null | grep -q "cloudnative-cluster"; then
  echo "Creating KinD cluster (this takes 1-2 minutes)..."
  kind create cluster --name cloudnative-cluster
else
  echo "KinD cluster already exists."
fi

# 2. Sync credentials 
echo "Loading cluster kubeconfig credentials..."
kind export kubeconfig --name cloudnative-cluster

# 3. Wait for API gateway with strict timeout ceiling
echo "Validating Kubernetes API stability..."
set +e
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

# 4. Deploy resources safely
echo "Applying directory manifests..."
if [ -d "k8s" ]; then
  kubectl apply -f k8s/ --timeout=30s || echo "Warning: k8s resources took too long to apply."
fi

if [ -d "monitoring" ]; then
  kubectl apply -f monitoring/ --timeout=30s || echo "Warning: monitoring resources took too long to apply."
fi

# 5. Native resilient background port forwarding loop
echo "Initialising background port-forward controller..."
cat << 'EOF' > /tmp/k8s-port-forward.sh
#!/bin/bash
while true; do
  # Forward Prometheus if not already listening
  if ! nc -z localhost 9090 &>/dev/null; then
    kubectl port-forward svc/prometheus 9090:9090 &>/dev/null &
  fi
  # Forward Grafana if not already listening
  if ! nc -z localhost 3000 &>/dev/null; then
    kubectl port-forward svc/grafana 3000:3000 &>/dev/null &
  fi
  sleep 10
done
EOF

chmod +x /tmp/k8s-port-forward.sh
nohup /tmp/k8s-port-forward.sh >/dev/null 2>&1 &

echo "=== Setup Successfully Finalised! ==="
echo "Prometheus exposure targeted → http://localhost:9090"
echo "Grafana exposure targeted    → http://localhost:3000"
