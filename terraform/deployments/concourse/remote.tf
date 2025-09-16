data "terraform_remote_state" "cluster_infrastructure" {
  backend = "s3"

  config = {
    bucket = "govuk-ah-test-state-files"
    key    = "cluster-infrastructure.tfstate"
  }
}
