FROM node:18-slim

# Create non-root user
RUN groupadd -r appuser && useradd -r -g appuser appuser

# Set working directory
WORKDIR /app

# Install system dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    && rm -rf /var/lib/apt/lists/*

# Copy package files
COPY package*.json ./

# Install Node.js dependencies
RUN npm ci --only=production && npm cache clean --force

# Copy application code
COPY . .

# Create directory and set permissions
RUN mkdir -p /app && chown -R appuser:appuser /app

# Switch to non-root user
USER appuser

# Expose port (will be mapped to 8081 in compose)
EXPOSE 4000

# Start the application
CMD ["node", "server.js"]

