FROM python:3.11-slim-bookworm

RUN apt-get update && \
    apt-get upgrade -y && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

WORKDIR /app
COPY src/requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt
COPY src/ .
RUN useradd -m appuser && chown -R appuser:appuser /app
USER appuser
CMD ["python", "app.py"]
