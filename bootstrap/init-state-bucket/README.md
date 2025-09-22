# init-state-bucket

This directory contains a small amount of Terraform intended to aid with
bootstrapping a new account, by creating an S3 bucket in the account
and then storing the state file in it. This bucket will subsequently be
used to store all other state files for the account.

## Bootstrapping/updating state bucket polciies
Follow the following procedure

1. Assume an appropriately privileged role in the target account
2. If this is a new account, create a new `.tfvars` file at
   `../tfvars/backends/ACCCOUNT.tfvars` where `ACCOUNT` is the name
   of the account you at working on
3. Run `init.sh ../tfvars/backends/ACCOUNT.tfvars` where `ACCOUNT` is the name
   of the account you at working on 