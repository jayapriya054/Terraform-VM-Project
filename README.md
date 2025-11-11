1. Created a python application
2. Build dockerimage for python app and pushed it to docker hub.
3. Used Terraform to create VPC, 2 subnets, route table, security groups.
4. Launched EC2 instances in subnets (one associated to route table that allows user to access app, other ssociated to route table that does not allow user to access app ).
5. Created Application Load Balancer with Target Groups (port 80, port 8080).Attached EC2 instances to target groups.
6. Created bash script to install docker, deploy the application.
7. Bash script installs Docker, starts the service. Pulls your Docker image from Docker Hub. Runs the container, mapping host port to container port.
