from fastapi import FastAPI
from app.core.database import Base, engine
from app.routers import users
from prometheus_client import Counter, Histogram, generate_latest
from starlette.responses import Response

app = FastAPI(title="CloudNative DevOps Portfolio API", version="0.3.0")

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