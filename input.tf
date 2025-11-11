variable "region" {
  description = "Enter aws region"
  type = string
  default = "us-west-1"
}

variable "instance_type" {
  description = "Instance type"
  type = string
  default = "t3.micro"
}

variable "ami" {
    description = "AMI Value"
    type = string
    default = "ami-0e6a50b0059fd2cc3"
}

variable "availability_zone" {
    description = "Availability zones"
    type = list(string)
    default = ["us-west-1a", "us-west-1c"]
  
}