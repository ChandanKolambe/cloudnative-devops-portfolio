import os
from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker, declarative_base

DEFAULT_DB_URL = "postgresql://postgres:postgres@localhost:5432/portfolio_db"
TEST_DB_URL = "postgresql://postgres:postgres@localhost:5432/portfolio_test_db"

app_env = os.getenv("APP_ENV", "dev")

print("App Env:", app_env)

if app_env == "test":
    DATABASE_URL = TEST_DB_URL
else:
    DATABASE_URL = os.getenv("DATABASE_URL", DEFAULT_DB_URL)

print("Using DB:", DATABASE_URL)

engine = create_engine(DATABASE_URL)
SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)
Base = declarative_base()
