# Variable precedence order in Terraform CLI:
# 1. -var and -var-file command-line options
# 2. *.auto.tfvars and *.auto.tfvars.json files (lexical order)
# 3. terraform.tfvars.json
# 4. terraform.tfvars
# 5. TF_VAR_* environment variables
# 6. Default values in variable blocks

ec2_instance_type = "t2.micro"

ec2_volume_config = {
  size = 10
  type = "gp2"
}

additional_tags = {
  ValuesFrom = "terraform.tfvars"
}
