FROM python:3.11-slim

# Create non-root user
RUN groupadd -r appuser && useradd -r -g appuser appuser

# Set working directory
WORKDIR /app

# Install dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    apache2-utils \
    curl \
    && rm -rf /var/lib/apt/lists/*

# Copy seed data scripts
COPY . .

# Set permissions
RUN chown -R appuser:appuser /app

# Switch to non-root user
USER appuser

# Default command (can be overridden in compose)
CMD ["sh", "-c", "python make-data.py && ./generate-votes.sh"]

