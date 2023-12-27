# Configure the AWS Provider
provider "aws" {
  region = "us-east-1"
}
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

terraform {
  backend "s3" {
    bucket         = "devops-uncut-remote-backend"
    key            = "global/s3/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "devops-uncut-terraform-locking"
    encrypt        = true
  }
}