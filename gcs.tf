resource "google_storage_bucket" "dataflow_staging_bucket" {
  name                        = "${var.host_project}-dataflow-staging"
  project                     = var.host_project
  location                    = var.region
  uniform_bucket_level_access = true
  force_destroy               = true
}
