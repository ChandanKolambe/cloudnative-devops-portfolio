# Changelog

All notable changes to this project will be documented here.  
This project follows [Semantic Versioning](https://semver.org/).

---

## [v0.24.0] - 2026-07-23
### Day 24 – Security Hardening (PSS, SecurityContexts & NetworkPolicies)
- Enforced the Kubernetes Baseline PodSecurityStandard profile on the `cloudnative-devops` namespace to block privileged container execution.
- Hardened workloads (`fastapi`, `postgres`, `postgres-test`, `redis`) with strict unprivileged `securityContext` settings, forcing containers to execute as non-root users (`999` / `10001`) and drop `ALL` capabilities.
- Implemented a `RuntimeDefault` seccompProfile configuration across application pod specifications to safely filter Linux system calls.
- Resolved PostgreSQL root initialization permission errors (`Operation not permitted`) under non-root execution by injecting the custom `PGDATA` directory environment variable.
- Created a `default-deny-ingress` NetworkPolicy rule to implement a true least-privilege microsegmentation posture inside the workspace.
- Configured dedicated allow-ingress NetworkPolicy resources to explicitly authorize path traffic from the NGINX Ingress Controller, local host port-forwards, and the FastAPI application layer straight to backend databases.
- Streamlined the infrastructure Helm chart architecture by removing conflicting standalone `postgres-pvc` and `redis-pvc` manifests, routing storage explicitly through unique PersistentVolume matching label selectors.

---

## [v0.23.0] - 2026-07-16
### Day 23 – Stateful Storage Labs
- Added Kubernetes PersistentVolume definitions for PostgreSQL and Redis using hostPath-backed volumes for local KinD/Codespaces labs.
- Introduced PVC-backed storage for Redis and a StatefulSet-based Postgres deployment to demonstrate stateful workload patterns.
- Updated the infra Helm chart values to configure storage sizes for both services.
- Explicitly bound PVCs to the manual hostPath-backed PVs for deterministic local lab behavior.
- Documented that this lab uses local hostPath storage and is therefore a learning-oriented substitute for cloud CSI-backed storage.
- Verified the storage setup aligns with Kubernetes best practices for stateful applications and persistent data.

---

## [v0.22.0] - 2026-07-15
### Day 22 – Observability & Security Improvements
- Hardened the FastAPI application with secure health checks and improved metrics exposure.
- Added Helm-based monitoring services for Prometheus and Grafana.
- Updated the devcontainer and setup flow to support smoother local cluster bootstrap and port-forwarding.
- Simplified the infrastructure chart layout by moving manifests into the Helm-based charts structure.

---

## [v0.21.0] - 2026-07-08
### Day 21 – Helm RBAC & Config Management
- Extended Helm chart (`helm/fastapi`) to include namespace, ServiceAccount, Role, and RoleBinding templates.
- Added Helm‑managed ConfigMap (`fastapi-config`) and Secret (`postgres-secret`) with values injected from `values.yaml`.
- Removed manual RBAC/namespace manifests from `setup.sh` to avoid duplication; Helm now owns these resources.
- Verified FastAPI pods running under `fastapi-sa` with correct RBAC permissions.
- Confirmed environment variables (`DATABASE_URL`, `TEST_DATABASE_URL`, `REDIS_URL`) injected via Helm ConfigMap/Secret.
- Demonstrated Helm lifecycle:
  - `helm upgrade` initially failed due to `.spec.replicas` conflict.
  - Resolved by uninstalling and reinstalling chart; Deployment scaled successfully to 3 replicas.

---

## [v0.20.0] - 2026-07-07
### Day 20 – Helm Chart Basics
- Created Helm chart (`helm/fastapi`) with `Chart.yaml`, `values.yaml`, and templates for Deployment + Service.
- Parameterized replicas, image tag, resources, probes, and service configuration via `values.yaml`.
- Installed chart into `cloudnative-devops` namespace and verified pods running with image `0.20.0`.
- Validated health endpoint (`/health`) via port-forward and curl.
- Demonstrated `helm upgrade` workflow by scaling replicas from 2 → 3.

---

## [v0.19.0] - 2026-07-06
### Day 19 – Horizontal Pod Autoscaler (HPA) with Metrics Server
- Installed metrics-server in `kube-system` namespace to enable resource metrics.
- Patched metrics-server deployment with `--kubelet-insecure-tls` for KinD/Codespaces compatibility.
- Verified metrics availability via `kubectl top nodes` and `kubectl top pods`.
- Created HPA (`fastapi-hpa`) targeting FastAPI deployment with CPU utilization threshold (50%).
- Validated HPA scaling behavior:
  - Scale‑up: replicas increased from 2 → 5 under load (`hey` benchmark).
  - Scale‑down: replicas decreased back to baseline after load stopped.

---

## [v0.18.0] - 2026-07-05
### Day 18 – Liveness & Readiness Probes, Resource Limits
- Added liveness and readiness probes to FastAPI deployment (`/health` endpoint).
- Configured probe timings: liveness (delay=10s, period=15s), readiness (delay=5s, period=10s).
- Demonstrated probe behavior by temporarily setting invalid paths.
- Verified Service endpoint updates via `kubectl get endpoints fastapi-service`.
- Reverted probes back to `/health` and confirmed stable `1/1 Ready` pods.

---

## [v0.17.0] - 2026-07-05
### Day 17 – Ingress + TLS
- Installed NGINX Ingress Controller via Helm in `ingress-nginx` namespace.
- Installed cert-manager with CRDs in `cert-manager` namespace.
- Created ClusterIssuer (`selfsigned-issuer`) for TLS certificates.
- Defined Ingress resource (`fastapi-ingress`) with host `fastapi.local` and TLS termination.
- Issued TLS certificate (`fastapi-tls`) and verified secret creation.
- Port-forwarded ingress controller service to test HTTPS locally (`curl -vk https://fastapi.local:8443/health`).
- Validated FastAPI endpoints responding over HTTPS with TLS handshake.

---

## [v0.16.0] - 2026-07-03
### Day 16 – Namespace & RBAC
- Introduced `cloudnative-devops` namespace for workload isolation.
- Created `fastapi-sa` ServiceAccount and bound it with Role + RoleBinding.
- Updated FastAPI Deployment to use ServiceAccount.
- Pushed versioned image `ghcr.io/chandankolambe/cloudnative-devops-portfolio/app:0.16.0`.
- Verified pods running with RBAC enforced and correct image tag.
- Captured evidence via kubectl outputs and GHCR package screenshot.

---

## [v0.15.0] - 2026-07-02
### Day 15 – Kubernetes Advanced Services & Monitoring
- Recreated Kind cluster (`day15-cluster`) and validated control plane readiness.
- Applied ConfigMap, Secret, Postgres PVC, Deployment, and Service.
- Deployed Redis and confirmed FastAPI pods connected via `REDIS_URL`.
- Rolled out FastAPI Deployment + Service with DB + Redis integration.
- Deployed Prometheus + Grafana monitoring stack in cluster.
- Validated FastAPI endpoints (`/health`, `/users`, `/send-task`, `/metrics`) with curl.

---

## [v0.14.0] - 2026-07-02
### Day 14 – Kubernetes Baseline Cluster
- Created Kind cluster (`day14-cluster`) inside Codespace.
- Deployed FastAPI app as both a standalone Pod and a Deployment (2 replicas).
- Added Postgres Deployment + Service (`db`) for database integration.
- Patched FastAPI manifests with `DATABASE_URL` env var to connect Postgres.
- Verified pods (`fastapi` + `postgres`) all running successfully.

---

## [v0.13.0] - 2026-07-01
### Day 13 – Git Enhancements
- Configured protected branches (`main` requires PR reviews).
- Adopted semantic versioning (v0.7.0 → v0.13.0).
- Updated README roadmap to reflect versioning.

---

## [v0.12.0] - 2026-06-30
### Day 12 – Packaging & Registry
- Verified `docker run` and `docker compose` workflows.
- Pushed image to Docker Hub.
- Validated container networking and runtime behavior.

---

## [v0.11.0] - 2026-06-28
### Day 11 – Redis Integration
- Integrated Redis with FastAPI background tasks.
- Debugged Redis container startup and port visibility.
- Tagged release with working Redis endpoints.

---

## [v0.10.0] - 2026-06-26
### Day 10 – Monitoring
- Added Prometheus metrics and Grafana dashboards.
- Tagged monitoring milestone.

---

## [v0.9.0] - 2026-06-21
### Day 9 – CI/CD
- Configured GitHub Actions pipeline.
- Automated build/test workflow.
- Tagged CI/CD milestone.

---

## [v0.8.0] - 2026-06-20
### Day 8 – Dockerization
- Dockerized FastAPI app.
- Added Compose orchestration.
- Tagged Docker milestone.

---

## [v0.7.0] - 2026-06-20
### Day 7 – DB Migrations
- Implemented FastAPI app with /users CRUD endpoints
- Integrated SQLAlchemy ORM and Alembic migrations
- Added pytest unit tests (initial CRUD validation)
