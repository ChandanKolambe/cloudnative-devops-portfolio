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


def _get_database_url() -> str:
    configured_url = os.getenv("DATABASE_URL")
    if configured_url:
        return configured_url

    if app_env == "test":
        if running_in_docker:
            return DOCKER_TEST_DB_URL

        try:
            import psycopg2

            conn = psycopg2.connect(LOCAL_TEST_DB_URL)
            conn.close()
            return LOCAL_TEST_DB_URL
        except Exception:
            return "sqlite:///./test.db"

    return DOCKER_DEFAULT_DB_URL if running_in_docker else LOCAL_DEFAULT_DB_URL


DATABASE_URL = _get_database_url()
print("Using DB:", DATABASE_URL)

engine_kwargs = {}
if DATABASE_URL.startswith("sqlite"):
    engine_kwargs["connect_args"] = {"check_same_thread": False}

engine = create_engine(DATABASE_URL, **engine_kwargs)
SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)
Base = declarative_base()
