# Base image with Node.js and Python
FROM node:18-bullseye-slim

# Set working directory for the application
WORKDIR /app

# Install Python and pip
RUN apt-get update && \
    apt-get install -y python3 python3-pip && \
    rm -rf /var/lib/apt/lists/*

# Copy the Python requirements file
COPY requirements.txt .

# Install Python dependencies
RUN pip3 install --no-cache-dir -r requirements.txt

# Set working directory for Node.js
WORKDIR /cobalt

# Copy package.json and package-lock.json for Cobalt
COPY package*.json ./

# Install Node.js dependencies for Cobalt
RUN npm ci && npm cache clean --force

# Copy the rest of the application code
COPY . /app

# Set the working directory back to /app
WORKDIR /app

# Expose ports for Flask and Cobalt
EXPOSE 8080 9000

# Start both the Cobalt and Flask servers
CMD ["sh", "-c", "node /cobalt/src/cobalt & python3 /app/app.py"]
