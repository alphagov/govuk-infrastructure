# Store terraform state in a bucket
# Variables cant't be used here.  See:
# https://github.com/hashicorp/terraform/issues/13022
#terraform {
#  backend "gcs" {
#    bucket = "govuk-knowledge-graph-staging-tfstate" # Change this (keep the -tfstate suffix)
#  }
#}
