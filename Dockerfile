# Step 1: Use Python base image to set up the environment for Flask
FROM python:3.9-slim AS python-base

WORKDIR /app

# Copy the requirements.txt to install dependencies
COPY requirements.txt .

# Install Python dependencies and print installed packages
RUN pip install --no-cache-dir -r requirements.txt && pip list

# Step 2: Use Node.js base image to install Node.js dependencies for Cobalt
FROM node:18-bullseye-slim AS node-base

WORKDIR /cobalt

# Copy package.json and package-lock.json for Cobalt
COPY package*.json ./

# Install Node.js dependencies for Cobalt
RUN apt-get update && \
    apt-get install -y git && \
    npm ci && \
    npm cache clean --force && \
    rm -rf /var/lib/apt/lists/*

# Copy Cobalt app files
COPY . .

# Step 3: Combine Node.js and Python in the final image
FROM python:3.9-slim as final

# Install Node.js in the final image
RUN apt-get update && apt-get install -y nodejs npm && rm -rf /var/lib/apt/lists/*

# Copy installed Python dependencies from python-base
COPY --from=python-base /usr/local/lib/python3.9/site-packages /usr/local/lib/python3.9/site-packages
COPY --from=python-base /usr/local/bin /usr/local/bin

# Copy Node.js setup from the previous stage
COPY --from=node-base /cobalt /cobalt

WORKDIR /app

# Copy all application code
COPY . .

# Print Python path and installed packages for debugging
RUN echo $PYTHONPATH && pip list

# Expose ports for Flask and Cobalt
EXPOSE 8080 9000

# Start both the Cobalt and Flask servers
CMD ["sh", "-c", "node /cobalt/src/cobalt & python /app/app.py"]
