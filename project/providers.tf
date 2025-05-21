# Define required Terraform providers and their versions
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"     # Use the official AWS provider
      version = "~> 5.0"            # Allow any version compatible with 5.x
    }
    random = {
      source  = "hashicorp/random"  # Use the random provider for generating unique values (e.g. IDs)
      version = "~> 3.0"            # Allow any version compatible with 3.x
    }
  }
}

# Configure the default AWS provider
provider "aws" {
  region = "eu-central-1"  # Set default AWS region to Frankfurt (eu-central-1)
}
