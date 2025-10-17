resource "random_password" "content_data_api_source" {
  length  = 32
  special = false
}

resource "random_password" "whitehall" {
  length  = 32
  special = false
}

resource "random_password" "publishing_api" {
  length  = 32
  special = false
}
