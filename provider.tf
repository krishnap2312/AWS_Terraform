# AWS CLI Credentials
provider "aws" {
  access_key = ""
  secret_key = ""
  region     = ""
}

terraform {
  required_providers {
    # provider Block - AWS
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    # provider Block - Time
    time = {
      source  = "hashicorp/time"
      version = "0.12.1"
    }
  }
}
