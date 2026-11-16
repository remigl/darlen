FROM docker.io/library/python:3.13-slim

ENV PYTHONDONTWRITEBYTECODE=1 PYTHONUNBUFFERED=1
WORKDIR /app

COPY pyproject.toml ./
COPY darlen ./darlen
RUN pip install --no-cache-dir .

RUN useradd --system --uid 10001 darlen
USER darlen

EXPOSE 8000
CMD ["uvicorn", "darlen.api:app", "--host", "0.0.0.0", "--port", "8000"]
