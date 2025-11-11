terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }
}

provider "aws" {
  region = var.region
  profile = "default"
}

resource "aws_vpc" "Vpc" {
  cidr_block = "10.0.0.0/16"
  instance_tenancy = "default"
  tags = {
    Name = "Vpc"
  }
}

resource "aws_subnet" "Subnet1" {
  vpc_id     = aws_vpc.Vpc.id
  availability_zone = var.availability_zone[0]
  map_public_ip_on_launch = true
  cidr_block = "10.0.1.0/24"
  tags = {
    Name = "Subnet1"
  }
}

resource "aws_subnet" "Subnet2" {
  vpc_id     = aws_vpc.Vpc.id
  availability_zone = var.availability_zone[1]
  map_public_ip_on_launch = true
  cidr_block = "10.0.2.0/24"
  tags = {
    Name = "Subnet2"
  }
}

resource "aws_internet_gateway" "Internet_Gateway" {
    vpc_id = aws_vpc.Vpc.id
    region = var.region
    tags = {
        Name = "Internet_Gateway"
  }
}

resource "aws_route_table" "Route_table" {
  vpc_id = aws_vpc.Vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.Internet_Gateway.id
  }

  tags = {
    Name = "Route_table"
  }
}

resource "aws_route_table_association" "rt_public_ass_1" {
  subnet_id      = aws_subnet.Subnet1.id
  route_table_id = aws_route_table.Route_table.id
}

resource "aws_route_table_association" "rt_private_ass_2" {
  subnet_id      = aws_subnet.Subnet2.id
  route_table_id = aws_route_table.Route_table.id
}

resource "aws_instance" "Machine1" {
  ami           = var.ami
  region = var.region
  instance_type = var.instance_type
  key_name = var.key_name
  subnet_id = aws_subnet.Subnet1.id
  vpc_security_group_ids = [aws_security_group.Security_Group.id]
  monitoring = false
  user_data = file("deploy.sh")
  tags = {
    Name = "Machine1"
  }
}
resource "aws_instance" "Machine2" {
  ami           = var.ami
  region = var.region
  instance_type = var.instance_type
  key_name = var.key_name
  subnet_id = aws_subnet.Subnet1.id
  vpc_security_group_ids = [aws_security_group.Security_Group.id]
  monitoring = false
  user_data = file("deploy.sh")
  tags = {
    Name = "Machine2"
  }
}
resource "aws_instance" "Machine3" {
  ami           = var.ami
  region = var.region
  instance_type = var.instance_type
  key_name = var.key_name
  subnet_id = aws_subnet.Subnet2.id
  vpc_security_group_ids = [aws_security_group.Security_Group.id]
  monitoring = false
  user_data = file("deploy1.sh")
  tags = {
    Name = "Machine3"
  }
}

#security group for vms in subnet 1 
resource "aws_security_group" "Security_Group" {
  name   = "Security_Group"
  vpc_id = aws_vpc.Vpc.id
  description = "Allows HTTP inbound traffic"

  ingress{
    description= "HTTP from VPC"   #Allows any outside world user to visit website via port 80
    from_port        = 80
    to_port          = 80
    protocol         = "TCP"
    cidr_blocks      = ["0.0.0.0/0"]
  }
  ingress{
    description= "SSH"      #allows any user to connect to the instance using ssh on port 22
    from_port        = 22   
    to_port          = 22
    protocol         = "TCP"
    cidr_blocks      = ["0.0.0.0/0"]
  }
  egress {
    from_port        = 0      # Instance can send info to anywhere on any port 
    to_port          = 0
    protocol         = "-1"     #all protocols (TCP, UPD, etc)
    cidr_blocks      = ["0.0.0.0/0"]
  } 
  tags = {
    Name = "Security_Group"
  }
}

#Security group for vm in Subnet2

resource "aws_security_group" "Security_Group_b" {                 #all Vms in any subnet in same VPC can communicate by default      
  vpc_id     = aws_vpc.Vpc.id 
  description = "Allows inbound traffic within vpc"
  name   = "Security_Group_b"
  ingress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["10.0.0.0/16"]
   
  }
}

resource "aws_lb_target_group" "TargetGroup1" {
  name     = "TargetGroup1"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.Vpc.id
}

resource "aws_lb_target_group" "TargetGroup2" {
  name     = "TargetGroup2"
  port     = 8080
  protocol = "HTTP"
  vpc_id   = aws_vpc.Vpc.id
}


#Attach EC2 instances to target group
resource "aws_lb_target_group_attachment" "TargetGroup_m1" {
  target_group_arn = aws_lb_target_group.TargetGroup1.arn
  target_id        = aws_instance.Machine1.id
  port             = 80
}

resource "aws_lb_target_group_attachment" "TargetGroup_m2" {
  target_group_arn = aws_lb_target_group.TargetGroup1.arn
  target_id        = aws_instance.Machine2.id
  port             = 80
}

resource "aws_lb_target_group_attachment" "TargetGroup_m3" {
  target_group_arn = aws_lb_target_group.TargetGroup2.arn
  target_id        = aws_instance.Machine3.id
  port             = 8080
}

resource "aws_lb" "Load_Balancer" {
  name               = "load-balancer"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.Security_Group.id]
  subnets            = [aws_subnet.Subnet1.id,aws_subnet.Subnet2.id]

  tags = {
    Environment = "preview"
  }
}

resource "aws_lb_listener" "lb_listener_subnet1" {
  load_balancer_arn = aws_lb.Load_Balancer.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.TargetGroup1.arn
  }
}

resource "aws_lb_listener" "lb_listener_subnet2" {
  load_balancer_arn = aws_lb.Load_Balancer.arn
  port              = "8080"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.TargetGroup2.arn
  }
}

resource "aws_s3_bucket" "my_bucket" {
  bucket = "s3-demo-bucket-jp"

  tags = {
    Name        = "My bucket"
    Environment = "Dev"
  }
}