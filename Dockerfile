FROM python:3.11-slim-buster

# Set working directory
WORKDIR /app

# Install required Python packages
COPY requirements.txt .
RUN pip install -r requirements.txt

# Copy your application code
COPY . .

# Expose the port your Flask app will listen on (e.g., 5000)
EXPOSE 5000

# Run your Flask app
CMD ["python", "app.py"]
