# CloudNative DevOps Portfolio

[![CI](https://github.com/ChandanKolambe/cloudnative-devops-portfolio/actions/workflows/ci.yml/badge.svg)](https://github.com/ChandanKolambe/cloudnative-devops-portfolio/actions/workflows/ci.yml)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)
![Python](https://img.shields.io/badge/python-3.12-blue)
![Docker](https://img.shields.io/badge/docker-ready-blue)
![Security](https://img.shields.io/badge/security-Trivy%20scan-green)

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
  
* **Datastore**: PostgreSQL (dev + test), Redis (for async tasks)
  
* **Testing**: pytest, test DB isolation
  
* **Containerization**: Docker, docker‑compose
  
* **Observability**: prometheus-client, Prometheus, Grafana dashboards
  
* **CI/CD**: GitHub Actions (build, security scan, tests)
  
* **Docs**: README (high level) + GitHub Wiki (detailed evidence per day)
  

This README is intentionally concise. Detailed day‑by‑day evidence, logs, and screenshots live in the project **Wiki** to keep the repo front page recruiter‑friendly.

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

* Docker, docker‑compose, GitHub Actions, Trivy (security scan)
  
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

**3\. Apply migrations**

```
docker-compose run web alembic upgrade head
docker-compose run -e APP_ENV=test web alembic upgrade head
```

**4\. Run tests (inside Docker)**

```
docker-compose run -e APP_ENV=test web pytest -v
```

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

### Roadmap

\- ✅ Day 1–9: Backend, DB, CRUD, CI/CD

\- ✅ Day 10: Monitoring (Prometheus + Grafana)

\- ✅ Day 11: Redis integration with FastAPI background tasks

\- 🔜 Kubernetes, Terraform, AWS EKS

---

### Documentation strategy (recommended)

* **README**: high‑level project overview, quickstart, tech stack, and roadmap. Keep it concise for recruiters.
  
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
