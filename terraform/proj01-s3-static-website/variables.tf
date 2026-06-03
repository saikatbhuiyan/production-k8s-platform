variable "aws_region" {
  description = "Primary AWS region for the S3 bucket."
  type        = string
  default     = "ap-southeast-1"
}

variable "project_name" {
  description = "Short project name used in AWS resource names."
  type        = string
  default     = "proj01-static-website"
}

variable "environment" {
  description = "Environment tag for the deployed resources."
  type        = string
  default     = "dev"
}

variable "site_domain" {
  description = "Full domain name that will serve the site, for example www.example.com."
  type        = string
}

variable "hosted_zone_name" {
  description = "Route 53 hosted zone name, for example example.com."
  type        = string
}
