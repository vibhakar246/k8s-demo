# Use Ubuntu LTS instead of Debian (usually more up-to-date)
FROM python:3.11-slim-bookworm

WORKDIR /app

# Update all system packages to latest security patches
RUN apt-get update && \
    apt-get upgrade -y && \
    apt-get install -y --only-upgrade openssl libssl3 && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

COPY src/requirements.txt .
RUN pip install --no-cache-dir --upgrade pip && \
    pip install --no-cache-dir -r requirements.txt

COPY src/ .

RUN useradd -m -u 1000 appuser && chown -R appuser:appuser /app
USER appuser

EXPOSE 5000

CMD ["python", "app.py"]
