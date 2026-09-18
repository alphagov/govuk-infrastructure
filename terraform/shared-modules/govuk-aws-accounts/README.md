# GOV.UK AWS Accounts

A simple module which provides easy lookup of account names and IDs

## Example usage

See [./USAGE.md](./USAGE.md) for a detailed reference.

For all exammples you will need to include the module:

```tf
module "govuk_aws_accounts" {
    source = "../../shared-modules/govuk-aws-accounts/"
}
```

### Lookup an account ID by name

```tf
locals {
    account_id = module.govuk_aws_accounts.account_name_to_id["integration"]
}
```

### Lookup an account name by ID

```tf
locals {
    account_name = module.govuk_aws_accounts.account_id_to_name["430354129336"]
}
```

### Get a list of all account IDs

```tf
locals {
    all_account_ids = module.govuk_aws_accounts.account_ids
}
```

### Get a list of all account names

```tf
locals {
    all_account_names = module.govuk_aws_accounts.account_names
}
```
