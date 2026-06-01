resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"

  tags = {
    Name      = "resources"
    ManagedBy = "Terraform"
    Project   = "resources"
  }
}

resource "aws_subnet" "public" {
  vpc_id     = aws_vpc.main.id
  cidr_block = "10.0.1.0/24"

  tags = {
    Name      = "public-subnet"
    ManagedBy = "Terraform"
    Project   = "resources"
  }
}