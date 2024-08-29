FROM python:3.11-slim-buster

# Set working directory
WORKDIR /app

# Install required Python packages
COPY requirements.txt .
RUN pip install -r requirements.txt

# Ensure Gunicorn is installed in case it's not in requirements.txt
RUN pip install gunicorn

# Set FLASK_ENV to production
ENV FLASK_ENV=production

# Copy your application code
COPY . .

# Expose the port your Flask app will listen on
EXPOSE 9000

# Run your Flask app with Gunicorn
CMD ["gunicorn", "-b", "0.0.0.0:9000", "app:app"]
