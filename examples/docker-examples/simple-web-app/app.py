#!/usr/bin/env python3
"""
Simple Web Application Example
Demonstrates a basic Flask application that can be containerized with Docker.
"""

from flask import Flask, jsonify
from datetime import datetime
import os
import logging

# Configure logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

# Create Flask app
app = Flask(__name__)

# Configuration
APP_VERSION = os.getenv("APP_VERSION", "1.0.0")
ENVIRONMENT = os.getenv("ENVIRONMENT", "development")

@app.route("/", methods=["GET"])
def index():
    """Root endpoint"""
    return jsonify({
        "message": "Welcome to Magic DevOps Stick Example App",
        "version": APP_VERSION,
        "environment": ENVIRONMENT,
        "timestamp": datetime.utcnow().isoformat()
    })

@app.route("/health", methods=["GET"])
def health():
    """Health check endpoint"""
    return jsonify({
        "status": "healthy",
        "timestamp": datetime.utcnow().isoformat()
    }), 200

@app.route("/ready", methods=["GET"])
def ready():
    """Readiness check endpoint"""
    return jsonify({
        "ready": True,
        "timestamp": datetime.utcnow().isoformat()
    }), 200

@app.route("/api/info", methods=["GET"])
def info():
    """Application info endpoint"""
    return jsonify({
        "app_name": "Magic DevOps Stick Example",
        "version": APP_VERSION,
        "environment": ENVIRONMENT,
        "python_version": os.sys.version,
        "timestamp": datetime.utcnow().isoformat()
    }), 200

@app.errorhandler(404)
def not_found(error):
    """Handle 404 errors"""
    return jsonify({
        "error": "Not found",
        "message": str(error),
        "timestamp": datetime.utcnow().isoformat()
    }), 404

@app.errorhandler(500)
def internal_error(error):
    """Handle 500 errors"""
    logger.error(f"Internal error: {error}")
    return jsonify({
        "error": "Internal server error",
        "message": str(error),
        "timestamp": datetime.utcnow().isoformat()
    }), 500

if __name__ == "__main__":
    logger.info(f"Starting application (version: {APP_VERSION}, environment: {ENVIRONMENT})")
    app.run(host="0.0.0.0", port=8000, debug=(ENVIRONMENT == "development"))
