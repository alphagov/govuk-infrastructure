
# SEARCH EVALUATION

# bucket for automated_evaluation_function function.zip
resource "google_storage_bucket" "automated_evaluation_function" {
  name     = "${var.gcp_project_id}_automated_evaluation"
  location = var.gcp_region
}

# zipped automated_evaluation_function into bucket
resource "google_storage_bucket_object" "automated_evaluation_function_zipped" {
  name   = "automated_evaluation_function_${data.archive_file.automated_evaluation_function.output_md5}.zip"
  bucket = google_storage_bucket.automated_evaluation_function.name
  source = data.archive_file.automated_evaluation_function.output_path
}

# archive .py and requirements.txt for automated_evaluation_function to zip
data "archive_file" "automated_evaluation_function" {
  type        = "zip"
  source_dir  = "${path.module}/files/automated_evaluation/"
  output_path = "${path.module}/files/automated_evaluation.zip"
}

# gen 2 function for daily evaluation of search against judgement lists
resource "google_cloudfunctions2_function" "automated_evaluation" {
  name        = "automated_evaluation"
  description = "function that will automatically evaluationuate the search results daily"
  location    = var.gcp_region
  build_config {
    entry_point = "automated_evaluation"
    runtime     = "python311"
    source {
      storage_source {
        bucket = google_storage_bucket.automated_evaluation_function.name
        object = google_storage_bucket_object.automated_evaluation_function_zipped.name
      }
    }
  }
  service_config {
    max_instance_count    = 5
    available_cpu         = 2
    available_memory      = "4G"
    timeout_seconds       = 3600
    ingress_settings      = "ALLOW_INTERNAL_ONLY"
    service_account_email = google_service_account.automated_evaluation_pipeline.email
    environment_variables = {
      PROJECT_NAME = var.gcp_project_id
    }
  }
}


# scheduler resource that will trigger daily evaluation of search against judgement lists
resource "google_cloud_scheduler_job" "daily_search_evaluation" {
  name             = "daily_search_evaluation"
  description      = "daily evaluation of search against judgement lists"
  schedule         = "0 07 * * *"
  time_zone        = "Europe/London"
  attempt_deadline = "1800s"
  http_target {
    http_method = "POST"
    uri         = google_cloudfunctions2_function.automated_evaluation.url
    body        = base64encode(templatefile("${path.module}/files/automated_evaluation_default_datasets/config.tftpl", { judgement_list_names = [for file_jl in fileset("${path.module}/files/automated_evaluation_default_datasets/judgement_lists/", "*.csv") : split(".csv", file_jl)[0]], gcs_input_url = join("", ["gcs://", google_storage_bucket.automated_evaluation_judgement_lists.name, "/"]), gcs_output_url = join("", ["gcs://", google_storage_bucket.automated_evaluation_output.name]), gcp_project_number = var.gcp_project_number }))

    headers = {
      "Content-Type" = "application/json"
    }
    oidc_token {
      service_account_email = google_service_account.automated_evaluation_pipeline.email
      audience              = google_cloudfunctions2_function.automated_evaluation.url
    }
  }
}

# bucket for output of automated evaluation
resource "google_storage_bucket" "automated_evaluation_output" {
  name     = "${var.gcp_project_id}_automated_evaluation_output"
  location = var.gcp_region
}

# 
resource "google_storage_bucket_object" "qrels_seed_file" {
  name   = "ts=1970-01-01T00:00:00/qc=0/rc=0/judgement_list=sample/qrels.csv"
  bucket = google_storage_bucket.automated_evaluation_output.name
  source = "${path.module}/files/automated_evaluation_default_datasets/qrels.csv"
}

resource "google_storage_bucket_object" "report_seed_file" {
  name   = "ts=1970-01-01T00:00:00/qc=0/rc=0/judgement_list=sample/report.csv"
  bucket = google_storage_bucket.automated_evaluation_output.name
  source = "${path.module}/files/automated_evaluation_default_datasets/report.csv"
}

resource "google_storage_bucket_object" "run_seed_file" {
  name   = "ts=1970-01-01T00:00:00/qc=0/rc=0/judgement_list=sample/candidate=sample/run.csv"
  bucket = google_storage_bucket.automated_evaluation_output.name
  source = "${path.module}/files/automated_evaluation_default_datasets/run.csv"
}

resource "google_storage_bucket_object" "results_seed_file" {
  name   = "ts=1970-01-01T00:00:00/qc=0/rc=0/judgement_list=sample/candidate=sample/results.csv"
  bucket = google_storage_bucket.automated_evaluation_output.name
  source = "${path.module}/files/automated_evaluation_default_datasets/results.csv"
}

# top level dataset to store automated evaluation output
resource "google_bigquery_dataset" "automated_evaluation_output" {
  dataset_id                 = "automated_evaluation_output"
  location                   = var.gcp_region
  delete_contents_on_destroy = true
}


resource "google_bigquery_table" "qrels" {
  dataset_id          = google_bigquery_dataset.automated_evaluation_output.dataset_id
  table_id            = "qrels"
  depends_on          = [google_storage_bucket_object.qrels_seed_file]
  deletion_protection = false
  external_data_configuration {
    autodetect    = true
    source_format = "CSV"
    source_uris = [
      join("", [google_storage_bucket.automated_evaluation_output.url, "/", "*qrels.csv"])
    ]
    hive_partitioning_options {
      mode              = "AUTO"
      source_uri_prefix = google_storage_bucket.automated_evaluation_output.url
    }
    csv_options {
      field_delimiter = ","
      quote           = ""
    }
  }

}

resource "google_bigquery_table" "report" {
  dataset_id          = google_bigquery_dataset.automated_evaluation_output.dataset_id
  table_id            = "report"
  depends_on          = [google_storage_bucket_object.report_seed_file]
  deletion_protection = false
  external_data_configuration {
    autodetect    = true
    source_format = "CSV"
    source_uris = [
      join("", [google_storage_bucket.automated_evaluation_output.url, "/", "*report.csv"])
    ]
    hive_partitioning_options {
      mode              = "AUTO"
      source_uri_prefix = google_storage_bucket.automated_evaluation_output.url
    }
    csv_options {
      field_delimiter = ","
      quote           = ""
    }
  }

}

resource "google_bigquery_table" "run" {
  dataset_id          = google_bigquery_dataset.automated_evaluation_output.dataset_id
  table_id            = "run"
  depends_on          = [google_storage_bucket_object.run_seed_file]
  deletion_protection = false
  external_data_configuration {
    autodetect    = true
    source_format = "CSV"
    source_uris = [
      join("", [google_storage_bucket.automated_evaluation_output.url, "/", "*run.csv"])
    ]
    hive_partitioning_options {
      mode              = "AUTO"
      source_uri_prefix = google_storage_bucket.automated_evaluation_output.url
    }
    csv_options {
      field_delimiter = ","
      quote           = ""
    }
  }

}

resource "google_bigquery_table" "results" {
  dataset_id          = google_bigquery_dataset.automated_evaluation_output.dataset_id
  table_id            = "results"
  depends_on          = [google_storage_bucket_object.results_seed_file]
  deletion_protection = false
  external_data_configuration {
    autodetect    = true
    source_format = "CSV"
    source_uris = [
      join("", [google_storage_bucket.automated_evaluation_output.url, "/", "*results.csv"])
    ]
    hive_partitioning_options {
      mode              = "AUTO"
      source_uri_prefix = google_storage_bucket.automated_evaluation_output.url
    }
    csv_options {
      field_delimiter = ","
      quote           = ""
    }
  }

}

### judgement lists
resource "google_storage_bucket" "automated_evaluation_judgement_lists" {
  name     = "${var.gcp_project_id}_automated_evaluation_judgement_lists"
  location = var.gcp_region
}

resource "google_storage_bucket_object" "judgement_list" {
  for_each = fileset("${path.module}/files/automated_evaluation_default_datasets/judgement_lists/", "*.csv")
  name     = each.value
  bucket   = google_storage_bucket.automated_evaluation_judgement_lists.name
  source   = join("", ["${path.module}/files/automated_evaluation_default_datasets/judgement_lists/", each.value])
}

resource "google_service_account" "automated_evaluation_pipeline" {
  account_id   = "automated-evaluation-pipeline"
  display_name = "automated-evaluation-pipeline"
  description  = "Pipeline to trigger automated evaluation function, with permisssions to read google storage/ read and write to BQ / query vertex"
}

## vertex role and binding
resource "google_project_iam_custom_role" "automated_evaluation_pipeline" {
  role_id     = "automated_evaluation_pipeline"
  title       = "automated_evaluation_pipeline"
  description = ""
  permissions = [
    "discoveryengine.servingConfigs.search",
    "storage.objects.get",
    "storage.objects.list",
    "storage.objects.create",
    "storage.objects.update",
    "bigquery.tables.update",
    "bigquery.tables.updateData",
    "bigquery.jobs.create",
    "bigquery.datasets.get",
    "bigquery.tables.get",
    "bigquery.tables.getData",
    "cloudfunctions.functions.invoke",
    "run.jobs.run",
    "run.routes.invoke",
    "cloudfunctions.functions.get"
  ]
}

resource "google_project_iam_binding" "automated_evaluation_pipeline" {
  role    = google_project_iam_custom_role.automated_evaluation_pipeline.id
  project = var.gcp_project_id
  members = [
  google_service_account.automated_evaluation_pipeline.member]
}

