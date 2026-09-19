terraform {
  required_version = ">= 1.16.2"
}

locals {
  account_name_to_id = tomap({
    test        = "430354129336"
    integration = "210287912431"
    staging     = "696911096973"
    production  = "172025368201"
    tools       = "900804735337"
  })

  account_id_to_name = { for name, id in local.account_name_to_id : id => name }

  account_ids   = values(local.account_name_to_id)
  account_names = keys(local.account_name_to_id)
}
