FROM python:3.12.4-slim AS builder
WORKDIR /app

COPY requirements.txt .
RUN python -m pip install --no-cache-dir --upgrade \
      "setuptools>=78.1.1" \
      "wheel>=0.46.2" \
      "jaraco.context>=6.1.0" \
      && python -m pip install --no-cache-dir -r requirements.txt \
      && rm -rf /usr/local/lib/python3.12/site-packages/setuptools* \
                /usr/local/lib/python3.12/site-packages/wheel* \
                /usr/local/lib/python3.12/site-packages/jaraco*

FROM python:3.12.4-slim
WORKDIR /app

RUN apt-get update \
      && apt-get install -y --no-install-recommends curl \
      && apt-get upgrade -y \
      && rm -rf /var/lib/apt/lists/*

RUN rm -rf /usr/local/lib/python3.12/site-packages/setuptools* \
           /usr/local/lib/python3.12/site-packages/wheel* \
           /usr/local/lib/python3.12/site-packages/jaraco*

RUN useradd -m appuser
USER appuser

COPY --from=builder /usr/local /usr/local

COPY . .

ENV RUNNING_IN_DOCKER=true
ENV DATABASE_URL=postgresql://postgres:postgres@db:5432/portfolio_db
ENV PYTHONPATH=/app

LABEL org.opencontainers.image.source="https://github.com/ChandanKolambe/cloudnative-devops-portfolio" \
      org.opencontainers.image.description="Cloud‑Native DevOps Portfolio project" \
      org.opencontainers.image.version="day12"

HEALTHCHECK --interval=10s --timeout=5s --retries=3 CMD curl -f http://localhost:8000/health || exit 1

CMD ["uvicorn", "app.main:app", "--host", "0.0.0.0", "--port", "8000"]
