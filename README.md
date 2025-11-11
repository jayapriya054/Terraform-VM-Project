1.Created a python application
   
2.Build dockerimage for python app and pushed it to docker hub.
   
3.Terraform Infrastructure
Created VPC, 2 subnets, route table, and security groups.
Security groups configured:
Subnet 1 (public) → allows inbound HTTP (80) and SSH (22)
Subnet 2 (private) → restricted, only internal VPC traffic.

4.EC2 Instances
Launched instances in subnets:
Machine1, Machine2 → subnet1 (public, accessible)
Machine3 → subnet2 (private, internal only)
Used Terraform user_data to deploy Docker containers automatically.

5.Application Load Balancer (ALB)
Created ALB in front of instances.
Two target groups:
Target Group 1: port 80 → frontend
Target Group 2: port 8080 → backend
Attached EC2 instances to the respective target groups.
Listeners configured:
Listener 80 → forwards to Target Group 1
Listener 8080 → forwards to Target Group 2

6.Bash Scripting
Installs Docker, enables the service.
Adds ubuntu user to Docker group.
Pulls Docker image from Docker Hub.
Runs container mapping host port → container port

7.Post Deployment, app is accessed via EC2 instance public IP.



