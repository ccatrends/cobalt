# Base image with Node.js and Python
FROM node:18-bullseye-slim

# Set working directory
WORKDIR /app

# Install Python3, pip, and other dependencies
RUN apt-get update && \
    apt-get install -y python3 python3-pip && \
    rm -rf /var/lib/apt/lists/*

# Display Python and Pip versions for debugging
RUN python3 --version && pip3 --version

# Copy the Python requirements file
COPY requirements.txt .

# Install Python dependencies
RUN pip3 install --no-cache-dir -r requirements.txt

# List installed Python packages for debugging
RUN pip3 list

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

# Display Python path to ensure it's correct
RUN echo "Python path:" && echo $PYTHONPATH

# Test importing Flask in the Docker build process
RUN python3 -c "import flask; print('Flask imported successfully')"

# Expose ports for Flask and Cobalt
EXPOSE 8080 9000

# Start both the Cobalt and Flask servers
CMD ["sh", "-c", "node /cobalt/src/cobalt & python3 /app/app.py"]
