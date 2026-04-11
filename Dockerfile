FROM ubuntu:24.04

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        software-properties-common && \
    add-apt-repository ppa:deadsnakes/ppa && \
    apt-get update && \
    apt-get install -y --no-install-recommends \
        python3.11 \
        python3.11-venv \
        python3-pip \
        ca-certificates \
        && \
    apt-get upgrade -y && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Create virtual environment
RUN python3.11 -m venv /opt/venv
ENV PATH="/opt/venv/bin:$PATH"

WORKDIR /app
COPY src/requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt
COPY src/ .

# Create user without specifying UID - let system assign one
RUN useradd -m appuser && chown -R appuser:appuser /app
USER appuser
CMD ["python", "app.py"]
