FROM python:3.11-alpine

RUN apk update && apk upgrade && \
    apk add --no-cache ca-certificates

WORKDIR /app
COPY src/requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt
COPY src/ .
RUN adduser -D -u 1000 appuser && chown -R appuser:appuser /app
USER appuser
CMD ["python", "app.py"]
