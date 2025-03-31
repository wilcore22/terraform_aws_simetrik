provider "aws" {
  region     = "us-east-1"
  profile = "default"
}


terraform {
  backend "s3" {
    bucket         = "terraform-state-bucket-xyz"
    key            = "dev/terraform.tfstate"  
    region         = "us-east-1"
    encrypt        = true

  }
}


