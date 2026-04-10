from flask import Flask
import os
import socket

app = Flask(__name__)

@app.route('/')
def hello():
    hostname = socket.gethostname()
    return f"""
    <html>
        <body style="background-color: #f0f0f0; text-align: center; padding-top: 50px;">
            <h1 style="color: #4CAF50;">🚀 DevOps Pipeline Working!</h1>
            <h2>Hello from Jenkins + Docker + Kubernetes!</h2>
            <p><strong>Pod Hostname:</strong> {hostname}</p>
            <p><strong>Environment:</strong> Development</p>
            <hr>
            <p>This is version 1.0 of your app deployed via CI/CD pipeline</p>
        </body>
    </html>
    """

@app.route('/health')
def health():
    return {"status": "healthy", "version": "1.0"}

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000)
