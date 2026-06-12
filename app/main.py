from fastapi import FastAPI
from app.core.database import Base, engine
from app.routers import users

app = FastAPI(title="CloudNative DevOps Portfolio API", version="0.3.0")

Base.metadata.create_all(bind=engine)

app.include_router(users.router)
