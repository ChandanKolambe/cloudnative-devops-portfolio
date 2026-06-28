import os
from fastapi import FastAPI, BackgroundTasks
from app.core.database import Base, engine
from app.routers import users
from prometheus_client import Counter, Histogram, generate_latest
from starlette.responses import Response
import redis

app = FastAPI(title="CloudNative DevOps Portfolio API", version="0.3.0")

if os.getenv("CI", "false").lower() != "true":
    Base.metadata.create_all(bind=engine)

app.include_router(users.router)

REQUEST_COUNT = Counter("http_requests_total", "Total HTTP requests", ["method", "endpoint"])
REQUEST_LATENCY = Histogram("http_request_duration_seconds", "Request latency", ["endpoint"])

@app.middleware("http")
async def prometheus_middleware(request, call_next):
    import time
    start_time = time.time()
    response = await call_next(request)
    REQUEST_COUNT.labels(request.method, request.url.path).inc()
    REQUEST_LATENCY.labels(request.url.path).observe(time.time() - start_time)
    return response

@app.get("/metrics")
async def metrics():
    return Response(generate_latest(), media_type="text/plain")

redis_url = os.getenv("REDIS_URL", "redis://localhost:6379/0")
r = redis.Redis.from_url(redis_url)

def write_to_redis(message: str):
    r.lpush("messages", message)

@app.post("/send-task/")
async def send_task(background_tasks: BackgroundTasks, msg: str):
    background_tasks.add_task(write_to_redis, msg)
    return {"status": "queued", "message": msg}

@app.get("/messages/")
async def get_messages():
    msgs = r.lrange("messages", 0, -1)
    return {"messages": [m.decode("utf-8") for m in msgs]}