FROM python:3.12.4-slim AS builder
WORKDIR /app

RUN useradd -m appuser
USER appuser

COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

FROM python:3.12.4-slim
WORKDIR /app

RUN apt-get update && apt-get upgrade -y && rm -rf /var/lib/apt/lists/*

RUN useradd -m appuser
USER appuser

COPY --from=builder /usr/local/lib/python3.12/site-packages /usr/local/lib/python3.12/site-packages
COPY --from=builder /usr/local/bin /usr/local/bin

COPY . .

LABEL org.opencontainers.image.source="https://github.com/ChandanKolambe/cloudnative-devops-portfolio" \
      org.opencontainers.image.description="Cloud‑Native DevOps Portfolio project" \
      org.opencontainers.image.version="day12"

HEALTHCHECK --interval=10s --timeout=5s --retries=3 CMD curl -f http://localhost:8000/health || exit 1

CMD ["uvicorn", "app.main:app", "--host", "0.0.0.0", "--port", "8000"]
