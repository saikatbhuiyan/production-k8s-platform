terraform {
  required_providers {
    aws = {
        source = "hashicorp/aws"
        version = "5.37.0"
    }
  }
}

# Actively managed by us, by our terraform project
resource "aws_s3_bucket" "my_bucket" {
  bucket = var.bucket_name
}

# Managed somewhere else, we just want to use in our project
data "aws_s3_bucket" "my_external_bucket" {
  bucket = "not-managed-by-us"
}


variable "bucket_name" {
  type = string
  description = "variable used to set bucket name"
  default = "default_bucket_name"
}

output "bucket_id" {
  value = aws_s3_bucket.my_bucket.id
}

# local values are like variables but they are only used within the module where they are  defined, 
# and they cannot be set from outside. They are often used to compute values based on other 
# variables or resources, and they can help to simplify the configuration and avoid repetition.
locals {
  bucket_name = "my_bucket_name"
}

module "my_module" {
  source = "./my_module"
}