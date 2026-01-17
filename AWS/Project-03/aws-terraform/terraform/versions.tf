terraform {
  required_version = ">= 1.5.0"
  required_providers {
    aws = {
        source = "hashicrop/aws"
        version = "~> 5.0"
    }
  }
}