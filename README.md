# CloudNative DevOps Portfolio

[![CI](https://github.com/ChandanKolambe/cloudnative-devops-portfolio/actions/workflows/ci.yml/badge.svg)](https://github.com/ChandanKolambe/cloudnative-devops-portfolio/actions/workflows/ci.yml)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)
![Python](https://img.shields.io/badge/python-3.12-blue)
![Docker](https://img.shields.io/badge/docker-ready-blue)
![Security](https://img.shields.io/badge/security-Trivy%20scan-green)
[![Docker](https://img.shields.io/docker/pulls/chandankolambe/fastapi-app)](https://hub.docker.com/r/chandankolambe/fastapi-app)
![GHCR](https://img.shields.io/badge/GHCR-published-blue)
![Kubernetes](https://img.shields.io/badge/kubernetes-ready-blue)

**A compact, professional portfolio repository demonstrating a progression from backend fundamentals to production‑grade DevOps: FastAPI, SQLAlchemy, Docker, CI/CD, Kubernetes readiness, Prometheus/Grafana monitoring, and Terraform, AWS EKS.**

---

### Quick links

* **Live demo (local)**: http://127.0.0.1:8000
  
* **Wiki (detailed day-by-day evidence)**: https://github.com//cloudnative-devops-portfolio/wiki
  
* **Branching**: feature branches → dev → main

---

### Overview

This repository documents a step‑by‑step learning and implementation path. Each day is a focused milestone that builds toward a production‑ready, observable microservice:

* **Backend**: FastAPI, Pydantic, SQLAlchemy, Alembic, BackgroundTasks
  
* **Datastore**: PostgreSQL (dev + test), Redis (for async tasks and background queue)
  
* **Testing**: pytest, test DB isolation
  
* **Containerization**: Docker, docker‑compose, Docker Hub (registry), GitHub Container Registry (GHCR)

* **Orchestration**: Kubernetes (Kind cluster, Pods, Deployments, Services)
  
* **Observability**: Prometheus client middleware with /metrics endpoint, Prometheus, Grafana dashboards

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
python -m venv venv
venv\Scripts\Activate.ps1
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

---

### Quickstart — Docker (recommended for full stack)

**1\. Build and start**

```
docker-compose up --build
```

**2\. Services and ports**


| Service | Port |
| :--- | :--- |
| FastAPI (web) | 8000 |
| Prometheus | 9090 |
| Grafana | 3000 |
| Postgres (dev) | 5432 |
| Postgres (test) | 5433 |
| Redis | 6379 |

**3. Test endpoints**

- Health check:
  ```bash
  curl localhost:8000/health
  # {"status":"ok"}
  ```
- User CRUD:
  ```bash
  curl -X POST localhost:8000/users/ -H "Content-Type: application/json" \
  -d '{"name":"Test","email":"test@example.com"}'
  curl localhost:8000/users/
  ```
- Metrics:
  ```bash
  curl localhost:8000/metrics
  ```
- Redis background tasks:
  ```bash
  curl -X POST localhost:8000/send-task/ -d "msg=Hello"
  curl localhost:8000/messages/
  ```

**4\. Apply migrations**

```
docker-compose run web alembic upgrade head
docker-compose run -e APP_ENV=test web alembic upgrade head
```

**5\. Run tests (inside Docker)**

```
docker-compose run -e APP_ENV=test web pytest -v
```

**6\. Build & Push Image (Docker Hub)**

Build locally:
```
docker build -t chandankolambe/fastapi-app:latest .
```
Push to Docker Hub

```bash
docker login
docker push chandankolambe/fastapi-app:latest
```
Run directly from Docker Hub
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

### Quickstart — GitHub Codespaces (Kubernetes)

This project includes a `devcontainer.json` and `.devcontainer/setup.sh` that automatically:

- Installs `kubectl`, `kind`, and `helm`
- Creates a local KinD cluster (`cloudnative-cluster`)
- Applies all manifests in `k8s/` and `monitoring/`
- Starts port-forwarding for Prometheus (`9090`) and Grafana (`3000`)
- Namespace isolation (`cloudnative-devops`)
- RBAC with `fastapi-sa` ServiceAccount
- Images pulled from GHCR (`app:<version>`)

#### Steps:

1. Open the repo in GitHub Codespaces.
2. Wait for the post-create setup to finish (cluster + manifests applied).
3. Verify pods and services:

```bash
kubectl get pods
kubectl get svc
```
4. Access UIs via forwarded ports:

- **FastAPI** → [https://&lt;codespace-id&gt;-30080.app.github.dev/health](https://<codespace-id>-30080.app.github.dev/health)
- **FastAPI (HTTPS)** → (https://<codespace-id>-8443.app.github.dev/health)(https://<codespace-id>-8443.app.github.dev/health)
- **Prometheus** → [https://&lt;codespace-id&gt;-9090.app.github.dev](https://<codespace-id>-9090.app.github.dev)
- **Grafana** → [https://&lt;codespace-id&gt;-3000.app.github.dev](https://<codespace-id>-3000.app.github.dev)

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
# or inside docker
docker-compose run -e APP_ENV=test web pytest -v
```

**Manual validation (example Day 10)**

1.  Insert a test user:

```
docker exec -it cloudnative-devops-portfolio-db-1 psql -U postgres -d portfolio_db

# inside psql
INSERT INTO users (name, email) VALUES ('TestUser', 'test@example.com');
\q
```

2.  Verify API:
  
```
curl localhost:8000/users/
# expected JSON includes TestUser
```

3.  Verify monitoring:
  

* Prometheus targets: http://localhost:9090/targets → **fastapi** job **UP**
  
* Grafana: http://localhost:3000 → dashboard panels update after hitting /users/

---

### CI / CD

**What runs in CI**

* Docker build
  
* Trivy security scan
  
* pytest (lightweight or CI‑safe tests)
  

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
- 🔜 Terraform, AWS EKS

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
