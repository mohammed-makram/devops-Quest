FROM python:3.11-slim

# Create non-root user
RUN groupadd -r appuser && useradd -r -g appuser appuser

# Set working directory
WORKDIR /app

# Install system dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    gcc \
    && rm -rf /var/lib/apt/lists/*

# Copy requirements and install Python dependencies
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copy application code
COPY . .

# Create directory for runtime files and set permissions
RUN mkdir -p /app && chown -R appuser:appuser /app

# Switch to non-root user
USER appuser

# Expose port 80 (internal), will be mapped to 8080 in compose
EXPOSE 80

# Use gunicorn to run the Flask app
CMD ["gunicorn", "--bind", "0.0.0.0:80", "--workers", "4", "--threads", "2", "--access-logfile", "-", "--error-logfile", "-", "app:app"]

