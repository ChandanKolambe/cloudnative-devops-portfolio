#!/bin/bash
set -e

# Install kind if missing
if ! command -v kind &> /dev/null; then
  echo "Installing KinD..."
  curl -Lo kind https://kind.sigs.k8s.io/dl/latest/kind-linux-amd64
  chmod +x kind && sudo mv kind /usr/local/bin/
fi

# Create cluster if not exists
if ! kind get clusters 2>/dev/null | grep -q "cloudnative-cluster"; then
  echo "Creating KinD cluster..."
  kind create cluster --name cloudnative-cluster
fi

# Ensure kubeconfig points to the cluster
echo "Loading cluster kubeconfig..."
kind export kubeconfig --name cloudnative-cluster

# Wait until API server is ready
echo "Waiting for Kubernetes cluster readiness..."
until kubectl cluster-info &> /dev/null; do
  echo "Cluster is booting, retrying in 3 seconds..."
  sleep 3
done

# Apply manifests generically
echo "Applying manifests..."
kubectl apply -f k8s/ || true
kubectl apply -f monitoring/ || true

# Port-forward Prometheus and Grafana in background
echo "Starting port-forwarding for Prometheus and Grafana..."
kubectl port-forward svc/prometheus 9090:9090 >/tmp/prometheus.log 2>&1 &
kubectl port-forward svc/grafana 3000:3000 >/tmp/grafana.log 2>&1 &

echo "Setup completed successfully!"
echo "Prometheus → http://localhost:9090"
echo "Grafana    → http://localhost:3000"