# Changelog

All notable changes to this project will be documented here.  
This project follows [Semantic Versioning](https://semver.org/).

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
