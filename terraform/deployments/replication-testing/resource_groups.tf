resource "aws_resourcegroups_group" "jfharden" {
  name        = "jfharden-rds-replication-test"
  description = "Resources JFHarden created as part of RDS replication testing"

  resource_query {
    type = "TAG_FILTERS_1_0"
    query = jsonencode({
      ResourceTypeFilters = ["AWS::AllSupported"]
      TagFilters = [{
        Key    = "CreatedBy"
        Values = ["jonathan.harden@digital.cabinet-office.gov.uk"]
      }]
    })
  }
}
