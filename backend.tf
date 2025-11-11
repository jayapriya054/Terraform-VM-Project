terraform {
  backend "s3" {
    bucket =  "s3-demo-bucket-jp"
    key = "statefile/terraform.tfstate"
    region = "us-west-1"
  }
}


