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
![FastAPI Hello World](docs/screenshots/day1-hello.png)
![Swagger UI](docs/screenshots/day1-echo.png)

## Next Steps
Day 2 → Add Dependency Injection and Background Tasks
