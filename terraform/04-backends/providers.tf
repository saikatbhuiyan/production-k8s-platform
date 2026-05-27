terraform {
  required_version = ">= 1.7.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.0"
    }
  }

  backend "s3" {
    bucket = "example-bucket-1b67820e3a82"
    key    = "04-backends/state.tfstate"
    region = "us-east-1" # don't need to be same as provider region, but must be in same region as bucket
    use_lockfile = true
  }
}

provider "aws" {
  region = "us-east-1"
}
