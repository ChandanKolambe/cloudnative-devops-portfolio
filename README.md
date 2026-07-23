# CloudNative DevOps Portfolio

[![CI](https://github.com/ChandanKolambe/cloudnative-devops-portfolio/actions/workflows/ci.yml/badge.svg)](https://github.com/ChandanKolambe/cloudnative-devops-portfolio/actions/workflows/ci.yml)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)
![Python](https://img.shields.io/badge/python-3.12-blue)
![Docker](https://img.shields.io/badge/docker-ready-blue)
![Security](https://img.shields.io/badge/security-Trivy%20scan-green)
[![Docker](https://img.shields.io/docker/pulls/chandankolambe/fastapi-app)](https://hub.docker.com/r/chandankolambe/fastapi-app)
![GHCR](https://img.shields.io/badge/GHCR-published-blue)
![Kubernetes](https://img.shields.io/badge/kubernetes-ready-blue)
![Helm](https://img.shields.io/badge/helm-ready-blue)

**A compact, professional portfolio repository demonstrating a progression from backend fundamentals to production-grade DevOps: FastAPI, SQLAlchemy, Docker, CI/CD, Helm-native Kubernetes deployments, Prometheus/Grafana observability, and security-first infrastructure automation.**

---

### Quick links

* **Live demo (local)**: http://127.0.0.1:8000
  
* **Wiki (detailed day-by-day evidence)**: https://github.com/ChandanKolambe/cloudnative-devops-portfolio/wiki
  
* **Branching**: feature branches → dev → main

---

### Overview

This repository documents a step‑by‑step learning and implementation path. Each day is a focused milestone that builds toward a production‑ready, observable microservice:

* **Backend**: FastAPI, Pydantic, SQLAlchemy, Alembic, BackgroundTasks
  
* **Datastore**: PostgreSQL (dev + test), Redis (for async tasks and background queue)
  
* **Testing**: pytest, test DB isolation
  
* **Containerization**: Docker, docker‑compose, Docker Hub (registry), GitHub Container Registry (GHCR)

* **Orchestration**: Helm-native Kubernetes deployment on Kind with Helm charts for infra, app, and monitoring

* **Storage**: Kubernetes PersistentVolumes (PV), PersistentVolumeClaims (PVC), StatefulSets

* **Cluster Security**: Namespace-level Pod Security Standards (Baseline profile), explicit non-root SecurityContext configuration (UID 999/10001), dropped Linux capabilities (`ALL`), RuntimeDefault seccomp profiles, and least-privilege zero-trust microsegmentation via native Kubernetes NetworkPolicies.
  
* **Observability**: Prometheus client middleware with /metrics endpoint, Prometheus, Grafana dashboards, and service-level monitoring

* **Healthcheck**: FastAPI /health endpoint integrated with Docker health probes
  
* **CI/CD**: GitHub Actions (build, security scan, tests)
  
* **Docs**: README (high level) + GitHub Wiki (detailed evidence per day)
  

This README is intentionally concise. Detailed day‑by‑day evidence, logs, and screenshots live in the project **Wiki**.

![FastAPI Docs](docs/screenshots/day%208%20docker%20fastapi%20docs.png)
![Postgres DB](docs/screenshots/day%204%20postgres%20DB.png)
![PyTest](docs/screenshots/day%206%20pytest%20unit%20tests.png)
![Docker](docs/screenshots/day%208%20docker%20compose%20up%20build.png)
![Prometheus](docs/screenshots/day%2010%20prometheus.png)
![CI Github Actions](docs/screenshots/day%209%20ci%20success.png)
![Grafana Dashboard](docs/screenshots/day%2010%20grafana.png)

---

### Tech stack

**Languages & Frameworks**

* **Python 3.12**, FastAPI, SQLAlchemy, Alembic
  

**Infrastructure & DevOps**

* Docker, docker‑compose, Kubernetes (Kind), GitHub Actions, Trivy (security scan)

* Kubernetes (Kind) with Helm charts for infra, app, monitoring, and storage (PVs, PVCs, StatefulSets)
  
* Prometheus, Grafana (monitoring)
  
* PostgreSQL (dev + test), Redis (queue + background tasks)
  

**Testing & Quality**

* pytest

---

### Quickstart — Local (developer)

**1\. Clone**

```
git clone https://github.com/ChandanKolambe/cloudnative-devops-portfolio.git
cd cloudnative-devops-portfolio
```

**2\. Python virtual environment**

```
python -m venv .venv
source .venv/bin/activate
```

For PowerShell on Windows:

```
.\.venv\Scripts\Activate.ps1
```

**3\. Install**

```
pip install -r requirements.txt
```

**4\. Run (dev)**

```
uvicorn app.main:app --reload
```

Visit http://127.0.0.1:8000 and API docs at http://127.0.0.1:8000/docs.

> Note: the full stack is deployed via Helm/Kind. Local developer mode is useful for API and unit test iteration.

---

### Quickstart — Kubernetes (recommended for full stack)

**1\. Bootstrap the devcontainer and KinD cluster**

```
.devcontainer/setup.sh
```

**2\. Verify services and ports**

| Service | Port |
| :--- | :--- |
| FastAPI | 8000 |
| Prometheus | 9090 |
| Grafana | 3000 |
| FastAPI HTTPS | 8443 |

**3\. Test endpoints**

- Health check:
  ```bash
  curl http://localhost:8000/health
  # {"status":"ok"}
  ```
- User CRUD:
  ```bash
  curl -X POST http://localhost:8000/users/ -H "Content-Type: application/json" \
  -d '{"name":"Test","email":"test@example.com"}'
  curl http://localhost:8000/users/
  ```
- Metrics:
  ```bash
  curl http://localhost:8000/metrics
  ```

**4\. Apply migrations**

```
python -m venv .venv
source .venv/bin/activate
pip install -r requirements.txt
alembic upgrade head
```

**5\. Run tests**

```
pytest -v
```

**6\. Optional: build a Docker image**

```
docker build -t fastapi-app:latest .
```

This repository deploys the full stack using Helm charts under `charts/infra`, `charts/fastapi`, and `charts/monitoring`.


Build locally:
```
docker build -t chandankolambe/fastapi-app:latest .
```
Push to Docker Hub (optional):

```bash
docker login
docker push chandankolambe/fastapi-app:latest
```
Run directly from Docker Hub (optional):
```bash
docker run -p 8000:8000 chandankolambe/fastapi-app:latest
```

OR  
**6\. Build & Push Image (GHCR)**

Build locally:
```bash
docker build -t ghcr.io/chandankolambe/cloudnative-devops-portfolio/app:latest .
```

Push to GHCR (CI/CD):
```bash
echo $GITHUB_TOKEN | docker login ghcr.io -u ${{ github.actor }} --password-stdin
docker push ghcr.io/chandankolambe/cloudnative-devops-portfolio/app:latest
```

Run directly from GHCR:
```bash
docker run -p 8000:8000 ghcr.io/chandankolambe/cloudnative-devops-portfolio/app:latest
```

Latest build pull from GHCR:
```bash
docker pull ghcr.io/chandankolambe/cloudnative-devops-portfolio/app:latest
```
Commit‑specific build pull from GHCR::
```bash
docker pull ghcr.io/chandankolambe/cloudnative-devops-portfolio/app:<commit-sha>
```
Images are automatically scanned with Trivy during CI/CD to detect vulnerabilities before publishing.  

---

### Quickstart — GitHub Codespaces (Helm)

This project includes a `devcontainer.json` and `.devcontainer/setup.sh` that automatically:

- Installs `kubectl`, `kind`, and `helm`
- Creates a local KinD cluster (`cloudnative-cluster`)
- Deploys Helm charts from `charts/infra`, `charts/fastapi`, and `charts/monitoring`
- Installs `ingress-nginx`, `cert-manager`, and `metrics-server` via Helm
- Starts local port-forwarding for FastAPI, Prometheus, Grafana, and HTTPS access
- Namespace isolation (`cloudnative-devops`)
- Enforces Pod Security Standards (Baseline profile) with strict warning profiles
- Binds workloads via native NetworkPolicies to prevent unauthorized cross-pod traffic
- RBAC with `fastapi-sa` ServiceAccount
- Images pulled from GHCR (`app:<version>`)

#### Steps:

1. Open the repo in GitHub Codespaces.
2. Wait for the post-create setup to finish (cluster + Helm deployments completed).
3. Verify pods and services:

```bash
kubectl get pods -n cloudnative-devops
kubectl get svc -n cloudnative-devops
```
4. Access UIs via forwarded ports:

- **FastAPI** → http://localhost:8000
- **FastAPI (HTTPS)** → https://fastapi.local:8443/health
- **Prometheus** → http://localhost:9090
- **Grafana** → http://localhost:3000

---

### Environment Variables

This project uses environment files for configuration:

- `.env` → local/dev configuration (Postgres credentials, DB URLs, Docker flag).  
  - This file is **gitignored** to keep secrets safe.  
  - Copy `.env.example` → `.env` and adjust values as needed.

- `.env.test` → test configuration (`APP_ENV=test`) used by pytest and CI.  
  - This file is tracked in the repo so tests can run consistently.  

---

### Testing & Validation

**Local tests**

* Ensure `pytest.ini` at repo root configures environment files:
  
```
[pytest]
env_files =
    .env.test
```

**Typical test commands**

```
python -m pytest -v
# or inside the devcontainer with Helm/Kind deployments
pytest -v
```

**Manual validation (current Helm workflow)**

1.  Verify the cluster and namespace:

```
kubectl get pods -n cloudnative-devops
kubectl get svc -n cloudnative-devops
```

2.  Verify API using forwarded FastAPI service:

```
curl http://localhost:8000/users/
```

3.  Verify monitoring:

* Prometheus targets: http://localhost:9090/targets → **fastapi** job **UP**
* Grafana: http://localhost:3000 → dashboard panels update after hitting /users/

---

### CI / CD

**What runs in CI**

* Docker image build
  
* Trivy security scan
  
* pytest (lightweight or CI‑safe tests)
  
* Helm chart linting and Kubernetes readiness checks
  
**Notes**

* DB‑dependent tests are run locally or in Codespaces. CI uses environment flags to skip heavy DB tests where appropriate.
  
* Keep CI green by separating fast unit tests from integration tests that require Postgres.

---

### 📘 Roadmap
- ✅ v0.2.0 – Initial FastAPI setup
- ✅ v0.3.0 – Basic endpoints
- ✅ v0.5.0 – Observability basics
- ✅ v0.6.0 – Prometheus integration
- ✅ v0.7.0 – DB Migrations
- ✅ v0.8.0 – Dockerization
- ✅ v0.9.0 – CI/CD
- ✅ v0.10.0 – Monitoring
- ✅ v0.11.0 – Redis integration
- ✅ v0.12.0 – Packaging & Registry
- ✅ v0.13.0 – Git Enhancements
- ✅ v0.14.0 – Kubernetes baseline cluster
- ✅ v0.15.0 – Kubernetes advanced services & monitoring
- ✅ v0.16.0 – Namespace & RBAC
- ✅ v0.17.0 – Ingress + TLS
- ✅ v0.18.0 – Probes & Resource Limits
- ✅ v0.19.0 – Horizontal Pod Autoscaler (HPA) with metrics-server
- ✅ v0.20.0 – Helm chart basics (FastAPI deployment)
- ✅ v0.21.0 – Helm RBAC & Config Management
- ✅ v0.22.0 – Observability & Security in Helm
- ✅ v0.23.0 – Storage labs (PVs, PVCs, StatefulSets)
- ✅ v0.24.0 – Security labs (Pod Security Standards, Security Contexts, Network Policies)
- 🔜 future: infrastructure as code expansion (Terraform / managed Kubernetes)

---

### 🔖 Versioning
This project follows [Semantic Versioning](https://semver.org/):
- Milestones → v0.x.0
- Fixes/patches → v0.x.1

---

### Documentation strategy (recommended)

* **README**: high‑level project overview, quickstart, tech stack, and roadmap.
  
* **Wiki**: one page per day (Day 1, Day 2, … ). Each page contains:
  
  * Goal and summary
    
  * Commands run
    
  * Logs and screenshots
    
  * Evidence checklist (what was validated)
    
* **Docs folder**: keep validation screenshots

---

### Contribution & Branching

**Branching**

* main — stable, production ready
  
* dev — integration branch for merged features
  
* feature/\* — work in progress branches (e.g., feature/day10-monitoring)
  

**Pull request checklist**

* Code builds locally and in Docker
  
* Tests pass (pytest -v)
  
* Linting and formatting applied
  
* Documentation updated (README short note + Wiki page for detailed evidence)
  

**How to contribute**

* Fork → create feature/\* → open PR to dev → request review

---

### 📄 Release Notes
See [CHANGELOG.md](CHANGELOG.md) for detailed milestone history (v0.2.0 → v0.16.0).

### 🤝 Contributing
See [CONTRIBUTING.md](CONTRIBUTING.md) for guidelines.

### 📜 Code of Conduct
See [CODE_OF_CONDUCT.md](CODE_OF_CONDUCT.md).

### 🔒 Security
See [SECURITY.md](SECURITY.md) for vulnerability reporting.

---

### Contact & License

* **Author**: Chandan Kolambe
  
* **Email**: [chandan.kolambe@gmail.com](mailto:chandan.kolambe@gmail.com)

* **License**: [MIT](LICENSE)
---

### About Me

Hi, I’m **Chandan Kolambe** 👋  
- 🚀 Aspiring DevOps/SRE engineer building a cloud‑native portfolio  
- 🌍 Open to visa‑sponsored opportunities in Europe (Netherlands preferred)  
- 📖 Documenting my daily learning journey in this repo + Wiki  
- 🔗 Connect with me: [LinkedIn](https://www.linkedin.com/in/chandankolambe) | [GitHub](https://github.com/ChandanKolambe) | [Medium](https://medium.com/@ChandanKolambe)
