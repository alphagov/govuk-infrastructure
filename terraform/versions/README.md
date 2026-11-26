# Versions data

This directory has a shared Terraform variable definition for the versions of each third-party component deployed to
a Kubernetes cluster in this repository. The values of the variables are held in `.tfvars` files in their respective 
subdirectories.

The definition is symlinked to every Terraform root that needs it, and the right `.tfvars` file must be picked when 
applying the root.

```text
terraform/versions/
├── versions-variables.tf
├── concourse
│       └── versions.tfvars
├── integration
│       └── versions.tfvars
├── production
│       └── versions.tfvars
├── staging
        └── versions.tfvars
```


