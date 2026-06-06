variable "ec2_instance_type" {
  type        = string
  description = "The type of the managed EC2 instances."
  default     = "t2.micro"

  validation {
    # condition = ec2_instance_type == "t2.micro" || ec2_instance_type == "t3.micro" || ec2_instance_type == "t3a.micro"
    condition     = contains(["t2.micro", "t3.micro", "t3a.micro"], var.ec2_instance_type)
    error_message = "The EC2 instance type must be either 't2.micro', 't3.micro', or 't3a.micro'."
  }
}

variable "ec2_volume_config" {
  type = object({
    size = number
    type = string
  })
  description = "The size and type of the root block volume for EC2 instances."

  default = {
    size = 10
    type = "gp3"
  }
}

variable "additional_tags" {
  type        = map(string)
  description = "Additional tags to apply to the EC2 instances."
  default     = {}
}

variable "my_sensitive_value" {
  type        = string
  description = "A sensitive value that should not be displayed in logs or output."
  default     = "sensitive_value"
  sensitive   = true
}
