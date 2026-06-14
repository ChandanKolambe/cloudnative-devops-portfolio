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

## Day 4 Progress
- Migrated database from SQLite → PostgreSQL
- Created new database `portfolio_db`
- Applied Alembic migrations to create tables
- Seeded sample users directly in Postgres
- Verified `/users/` endpoint returns real data

## Screenshots
![users Endpoint](docs/screenshots/day%204%20users%20endpoint.png)

## Day 5 Progress
- Implemented full CRUD APIs for `/users/`
- Added Pydantic validations for name and email
- Error handling with proper HTTP status codes

## Screenshots
![create user](docs/screenshots/day%205%20create%20user.png)
![get user](docs/screenshots/day%205%20get%20user.png)
![update user](docs/screenshots/day%205%20update%20user.png)
![get all users](docs/screenshots/day%205%20get%20all%20users.png)
![delete user](docs/screenshots/day%205%20delete%20user.png)
![get user after delete](docs/screenshots/day%205%20get%20user%20after%20delete.png)
![email id validation](docs/screenshots/day%205%20email%20id%20validation.png)
![name validation](docs/screenshots/day%205%20name%20validation.png)

## Day 6 Progress
- Integrated `pytest` framework into the project.
- Configured `.env.test`, `pytest.ini`, and `conftest.py` to ensure tests run against a dedicated test database.
- Wrote unit tests for User CRUD APIs:
- Verified error handling for invalid inputs.
- All tests passed successfully (`python -m pytest -v`).

## Screenshots
![pytest](docs/screenshots/day%206%20pytest%20unit%20tests.png)