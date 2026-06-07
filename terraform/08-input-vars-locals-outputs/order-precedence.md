# Terraform Variable Precedence

Terraform CLI uses this precedence order, from highest to lowest:

1. `-var` and `-var-file` command-line options
2. `*.auto.tfvars` and `*.auto.tfvars.json` files, in lexical order
3. `terraform.tfvars.json`
4. `terraform.tfvars`
5. `TF_VAR_*` environment variables
6. `default` values in `variable` blocks

## Example Variable

From `variables.tf`:

```hcl
variable "ec2_instance_type" {
  type    = string
  default = "t2.micro"
}
```

## 1. Default Value

If no other value is provided, Terraform uses:

```hcl
ec2_instance_type = "t2.micro"
```

## 2. Environment Variable

```bash
export TF_VAR_ec2_instance_type="t3.micro"
terraform plan
```

Terraform uses:

```hcl
ec2_instance_type = "t3.micro"
```

## 3. terraform.tfvars

```hcl
ec2_instance_type = "t2.small"
```

This overrides the environment variable and default.

## 4. terraform.tfvars.json

```json
{
  "ec2_instance_type": "t2.medium"
}
```

This overrides `terraform.tfvars`.

## 5. *.auto.tfvars

`01-common.auto.tfvars`

```hcl
ec2_instance_type = "t2.large"
```

`02-dev.auto.tfvars`

```hcl
ec2_instance_type = "t3a.micro"
```

Terraform loads these in filename order, so `02-dev.auto.tfvars` wins.

Final value at this point:

```hcl
ec2_instance_type = "t3a.micro"
```

## 6. Command-Line Flag

```bash
terraform plan -var="ec2_instance_type=t3.micro"
```

This overrides everything else.

Final value:

```hcl
ec2_instance_type = "t3.micro"
```

## Summary

If the same variable is set in all places above, Terraform will finally use:

```hcl
ec2_instance_type = "t3.micro"
```
