# CloudNative DevOps Portfolio

This repository documents my journey from backend fundamentals (FastAPI, SQLAlchemy, pytest) to full DevOps practices (Docker, Kubernetes, Terraform, GitHub Actions, AWS EKS, Prometheus/Grafana).

## Prerequisites
- Python 3.12+
- Git
- VS Code

### Setup Instructions
```powershell
# Clone repo
git clone https://github.com/ChandanKolambe/cloudnative-devops-portfolio.git
cd cloudnative-devops-portfolio

# Create virtual environment
python -m venv venv
venv\Scripts\activate

# Install dependencies
pip install -r requirements.txt

#Run the App
uvicorn app.main:app --reload
```

Visit: http://127.0.0.1:8000 → {"message":"Hello, DevOps World!"}

## Day 1 Progress
- Setup Python 3.12 virtual environment
- Installed FastAPI + Uvicorn
- Created Hello World and echo endpoints
- Verified app running locally at http://127.0.0.1:8000
## Screenshots
![FastAPI Hello World](docs/screenshots/day%201%20hello%20endpoint.png)
![echo Endpoint](docs/screenshots/day%201%20echo%20endpoint.png)

## Day 2 Progress
- Implemented Dependency Injection using FastAPI `Depends`
- Created a fake DB connection dependency
- Added Background Tasks to simulate async logging
- Verified endpoints:
  - `/items/` → shows injected DB connection
  - `/process/` → triggers background logging while returning instantly

## Screenshots
![Terminal showing background task logs](docs/screenshots/day%202%20background%20task%20logs.png)
![process Endpoint](docs/screenshots/day%202%20process%20endpoint.png)
![items Endpoint](docs/screenshots/day%202%20items%20endpoint.png)

## Day 3 Progress
- Integrated SQLAlchemy ORM with SQLite
- Defined `User` model (id, name, email)
- Added `/users/` endpoint to fetch users
- Setup Alembic migrations for schema evolution

## Screenshots
![users Endpoint](docs/screenshots/day%203%20users%20endpoint.png)