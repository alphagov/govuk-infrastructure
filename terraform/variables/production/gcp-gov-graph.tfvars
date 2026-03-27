environment                         = "production"
folder_id                           = "278098142879"
billing_account                     = "015C7A-FAF970-B0D375"
project_id                          = "govuk-knowledge-graph"
project_number                      = "19513753240"
name                                = "production"
access_group_name                   = "govuk-gcp-access"
environment_workspace_name          = "govuk-knowledge-graph-production"
tfc_project_name                    = "govuk-data-engineering"
region                              = "europe-west2"
zone                                = "europe-west2-b"
location                            = "EUROPE-WEST2"
govgraph_domain                     = "govgraph.dev"
govgraphsearch_domain               = "govgraphsearch.dev"
govsearch_domain                    = "gov-search.service.gov.uk"
application_title                   = "GovGraph Search"
enable_auth                         = "true"
signon_url                          = "https://signon.publishing.service.gov.uk"
oauth_auth_url                      = "https://signon.publishing.service.gov.uk/oauth/authorize"
oauth_token_url                     = "https://signon.publishing.service.gov.uk/oauth/access_token"
oauth_callback_url                  = "https://gov-search.service.gov.uk/auth/gds/callback"
enable_redis_session_store_instance = true
gtm_id                              = "GTM-5LTHPJZ"
gtm_auth                            = "aWEg5ABBTyIPcsSg1cJWxg"

# Google Groups and external service accounts that are to have roles given to
# them.
#
# Users shouldn't be given access directly, only via their membership of a
# Google Group.
#
# Service accounts that are internal to this Google Cloud Project shouldn't be
# included here. They should be given directly in the .tf files, because they
# should be the same in every environment.

project_owner_members = [
  "group:govgraph-developers@digital.cabinet-office.gov.uk",
  "serviceAccount:terraform-cloud-production@govuk-production.iam.gserviceaccount.com",
]

iap_govgraphsearch_members = [
  "allUsers"
]

bigquery_job_user_members = [
  "group:govgraph-private-data-readers@digital.cabinet-office.gov.uk"
]

# Bucket: {project_id}-data-processed
storage_data_processed_object_viewer_members = [
]

# BigQuery dataset: private
bigquery_private_data_viewer_members = [
  "group:govgraph-private-data-readers@digital.cabinet-office.gov.uk",
  "serviceAccount:publishing-looker-studio-creds@govuk-publishing.iam.gserviceaccount.com",
]

# BigQuery dataset: public
bigquery_public_data_viewer_members = [
  "group:govgraph-private-data-readers@digital.cabinet-office.gov.uk",
  "serviceAccount:service-419945323196@gcp-sa-dataform.iam.gserviceaccount.com",
  "serviceAccount:service-942729121218@gcp-sa-dataform.iam.gserviceaccount.com",
  "serviceAccount:publishing-looker-studio-creds@govuk-publishing.iam.gserviceaccount.com",
]

bigquery_content_data_viewer_members = [
  "group:govgraph-private-data-readers@digital.cabinet-office.gov.uk",
  "serviceAccount:ner-bulk-inference@cpto-content-metadata.iam.gserviceaccount.com",
  "serviceAccount:wif-govgraph-bigquery-access@govuk-llm-question-answering.iam.gserviceaccount.com",
  "serviceAccount:wif-ner-new-content-inference@cpto-content-metadata.iam.gserviceaccount.com",
  "serviceAccount:wif-vectorstore@govuk-llm-question-answering.iam.gserviceaccount.com",
  "serviceAccount:publishing-looker-studio-creds@govuk-publishing.iam.gserviceaccount.com",
]

# BigQuery dataset: publisher
bigquery_publisher_data_viewer_members = [
  "group:govgraph-private-data-readers@digital.cabinet-office.gov.uk",
  "serviceAccount:publishing-looker-studio-creds@govuk-publishing.iam.gserviceaccount.com",
]

# BigQuery dataset: functions
bigquery_functions_data_viewer_members = [
  "group:govgraph-private-data-readers@digital.cabinet-office.gov.uk"
]

# BigQuery dataset: graph
bigquery_graph_data_viewer_members = [
  "group:govgraph-private-data-readers@digital.cabinet-office.gov.uk",
  "serviceAccount:ner-bulk-inference@cpto-content-metadata.iam.gserviceaccount.com",
  "serviceAccount:wif-govgraph-bigquery-access@govuk-llm-question-answering.iam.gserviceaccount.com",
  "serviceAccount:wif-ner-new-content-inference@cpto-content-metadata.iam.gserviceaccount.com",
  "serviceAccount:wif-vectorstore@govuk-llm-question-answering.iam.gserviceaccount.com",
  "serviceAccount:govuk-looker-poc@govuk-looker-poc.iam.gserviceaccount.com",
]

# BigQuery dataset: publishing-api
bigquery_publishing_api_data_viewer_members = [
  "group:govgraph-private-data-readers@digital.cabinet-office.gov.uk",
  "serviceAccount:service-419945323196@gcp-sa-dataform.iam.gserviceaccount.com",
  "serviceAccount:service-942729121218@gcp-sa-dataform.iam.gserviceaccount.com",
  "serviceAccount:custom-publishing-dataform-ser@govuk-publishing.iam.gserviceaccount.com",
  "serviceAccount:publishing-looker-studio-creds@govuk-publishing.iam.gserviceaccount.com",
]

# BigQuery dataset: smart_survey
bigquery_smart_survey_data_viewer_members = [
  "serviceAccount:data-engineering@govuk-user-feedback-dev.iam.gserviceaccount.com",
  "serviceAccount:data-engineering@govuk-user-feedback-staging.iam.gserviceaccount.com",
  "serviceAccount:data-engineering@govuk-user-feedback.iam.gserviceaccount.com",
]

# BigQuery dataset: support-api
bigquery_support_api_data_viewer_members = [
  "serviceAccount:data-engineering@govuk-user-feedback-dev.iam.gserviceaccount.com",
  "serviceAccount:data-engineering@govuk-user-feedback-staging.iam.gserviceaccount.com",
  "serviceAccount:data-engineering@govuk-user-feedback.iam.gserviceaccount.com",
]

# BigQuery dataset: search
bigquery_search_data_viewer_members = [
  "group:govgraph-private-data-readers@digital.cabinet-office.gov.uk",
  "serviceAccount:service-419945323196@gcp-sa-dataform.iam.gserviceaccount.com",
  "serviceAccount:service-942729121218@gcp-sa-dataform.iam.gserviceaccount.com",
  "serviceAccount:wif-govgraph-bigquery-access@govuk-llm-question-answering.iam.gserviceaccount.com",
  "serviceAccount:wif-vectorstore@govuk-llm-question-answering.iam.gserviceaccount.com",
  "serviceAccount:custom-publishing-dataform-ser@govuk-publishing.iam.gserviceaccount.com",
  "serviceAccount:publishing-looker-studio-creds@govuk-publishing.iam.gserviceaccount.com",
]

# BigQuery dataset: test
bigquery_test_data_viewer_members = [
]

# BigQuery dataset: whitehall
bigquery_whitehall_data_viewer_members = [
  "group:govgraph-private-data-readers@digital.cabinet-office.gov.uk",
  "serviceAccount:publishing-looker-studio-creds@govuk-publishing.iam.gserviceaccount.com",
]

# BigQuery dataset: asset-manager
bigquery_asset_manager_data_viewer_members = [
  "group:govgraph-private-data-readers@digital.cabinet-office.gov.uk",
  "serviceAccount:publishing-looker-studio-creds@govuk-publishing.iam.gserviceaccount.com",
]

# BigQuery dataset: zendesk
bigquery_zendesk_data_viewer_members = [
  "group:govgraph-private-data-readers@digital.cabinet-office.gov.uk",
  "serviceAccount:publishing-looker-studio-creds@govuk-publishing.iam.gserviceaccount.com",
]
