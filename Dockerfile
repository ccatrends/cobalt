FROM python:3.11-slim-buster

# Set working directory
WORKDIR /app

# Install required Python packages
COPY requirements.txt .
RUN pip install -r requirements.txt

# Set FLASK_ENV to production
ENV FLASK_ENV=production

# Copy your application code
COPY . .

# Copy the src directory to ensure all files are included
COPY src/ /app/src/

# Expose the port your Flask app will listen on
EXPOSE 9000

# Run your Flask app with Gunicorn
CMD ["gunicorn", "-b", "0.0.0.0:9000", "app:app"]
