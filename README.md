# ZENTRAL
This repo comprises of the modules that can be used by application infra to create resources.

## How to Use

```terraform
module "application_rg" {
    source              = "github.com/enthuzest/zentral/modules/resource-group?ref=v0.0.3"
    resource_group_name = local.application_name
    location            = var.location
    tags                = var.tags
}
```

## Dependencies

Terraform version `~>1.12.0`

## Developers Do's

If you update a module run below command in terminal to auto generate the readme file.

```terraform-docs markdown -c ../../.terraform-docs.yml . >README.md```