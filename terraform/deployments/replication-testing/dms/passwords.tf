resource "random_password" "content_data_api_source" {
  length  = 32
  special = false
}

resource "random_password" "content_data_api_target" {
  length  = 32
  special = false
}
