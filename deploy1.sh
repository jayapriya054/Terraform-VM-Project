
#!/bin/bash

# Update system
sudo apt-get update -y

# Install Docker
sudo apt-get install -y docker.io

# Start Docker service
sudo systemctl start docker
sudo systemctl enable docker

# Allow 'ubuntu' user to run Docker without sudo
sudo usermod -aG docker ubuntu
newgrp docker

sudo docker login -u jayapriya054 -p Jayamano@95

# Pull your Flask Docker image from Docker Hub
sudo docker pull Jayapriya054/frontend

# Run the Flask container
# Maps host port 80 to container port 5000 (Flask default)
sudo docker run -d -p 8080:5000 Jayapriya054/frontend

