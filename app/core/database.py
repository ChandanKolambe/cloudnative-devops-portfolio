import os
from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker, declarative_base

LOCAL_DEFAULT_DB_URL = "postgresql://postgres:postgres@localhost:5432/portfolio_db"
LOCAL_TEST_DB_URL = "postgresql://postgres:postgres@localhost:5432/portfolio_test_db"

DOCKER_DEFAULT_DB_URL = "postgresql://postgres:postgres@db:5432/portfolio_db"
DOCKER_TEST_DB_URL = "postgresql://postgres:postgres@db_test:5432/portfolio_test_db"

app_env = os.getenv("APP_ENV", "dev")
running_in_docker = os.getenv("RUNNING_IN_DOCKER", "false").lower() == "true"

print("App Env:", app_env)
print("Running in Docker:", running_in_docker)

if app_env == "test":
    DATABASE_URL = DOCKER_TEST_DB_URL if running_in_docker else LOCAL_TEST_DB_URL
else:
    DATABASE_URL = os.getenv(
        "DATABASE_URL",
        DOCKER_DEFAULT_DB_URL if running_in_docker else LOCAL_DEFAULT_DB_URL
    )

print("Using DB:", DATABASE_URL)

engine = create_engine(DATABASE_URL)
SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)
Base = declarative_base()
