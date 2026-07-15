#!/bin/bash
set -euo pipefail

if ! grep -q 'fastapi.local' /etc/hosts 2>/dev/null; then
  echo '127.0.0.1 fastapi.local' | sudo tee -a /etc/hosts >/dev/null
fi

for port in 8000 9090 3000 8443; do
  if ! ss -ltn "( sport = :$port )" 2>/dev/null | grep -q LISTEN; then
    case "$port" in
      8000)
        kubectl port-forward -n cloudnative-devops svc/fastapi-service 8000:8000 >/tmp/fastapi-port-forward.log 2>&1 &
        ;;
      9090)
        kubectl port-forward -n cloudnative-devops svc/prometheus 9090:9090 >/tmp/prometheus-port-forward.log 2>&1 &
        ;;
      3000)
        kubectl port-forward -n cloudnative-devops svc/grafana 3000:3000 >/tmp/grafana-port-forward.log 2>&1 &
        ;;
      8443)
        kubectl port-forward -n ingress-nginx svc/ingress-nginx-controller 8443:443 >/tmp/ingress-port-forward.log 2>&1 &
        ;;
    esac
  fi
done

sleep 2
curl -sk https://fastapi.local:8443/health >/dev/null 2>&1 || true
