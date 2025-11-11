# Use a lightweight Python base image
FROM --platform=linux/amd64 python:3.12-slim     #make sure this architecture match with the EC2 instance architecture

# Set working directory inside the container
WORKDIR /app

# Copy all files from current directory into the container
COPY . .

# Install Python dependencies
RUN pip install --no-cache-dir -r requirements.txt

# Expose the port the Flask app will run on
EXPOSE 5000

# Run the Flask app
CMD ["python", "app.py"]
