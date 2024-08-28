# Step 1: Use Python base image to set up the environment for Flask
FROM python:3.9-slim AS python-base

# Set the working directory for Python dependencies
WORKDIR /app

# Copy the Flask application code to the working directory
COPY . /app

# Install Python dependencies
RUN pip install --no-cache-dir -r requirements.txt

# Step 2: Install Node.js and dependencies for Cobalt
FROM node:18-bullseye-slim AS node-base

WORKDIR /cobalt

# Copy the Cobalt app files
COPY package*.json ./

# Install Node.js dependencies for Cobalt
RUN apt-get update && \
    apt-get install -y git python3 build-essential && \
    npm ci && \
    npm cache clean --force && \
    apt-get purge --autoremove -y python3 build-essential && \
    rm -rf ~/.cache/ /var/lib/apt/lists/*

# Copy the rest of the Cobalt files
COPY . .

# Expose ports for both Flask and Cobalt
EXPOSE 8080 9000

# Step 3: Final container with both Python and Node.js
FROM python-base as final

# Copy Node.js setup from the previous stage
COPY --from=node-base /cobalt /cobalt

# Working directory for Flask app
WORKDIR /app

# Start both the Cobalt and Flask servers
CMD ["sh", "-c", "node /cobalt/src/cobalt & python app.py"]

