import {
  id = "gds-bq-processing"
  to = google_project.project
}

import {
  to = google_project_iam_binding.project_owners
  id = "gds-bq-processing roles/owner"
}

import {
  to = google_project_iam_binding.project_editors
  id = "gds-bq-processing roles/editor"
}
