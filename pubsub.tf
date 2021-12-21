resource "google_pubsub_topic" "data_lineage_audit_logs" {
  project = var.host_project
  name    = "data-lineage-audit-logs"
}

resource "google_logging_project_sink" "data_lineage_sink" {
  for_each               = toset(var.logged_projects)
  project                = each.value
  name                   = "data-lineage-sink"
  destination            = "pubsub.googleapis.com/projects/${var.host_project}/topics/${google_pubsub_topic.data_lineage_audit_logs.name}"
  filter                 = "protoPayload.metadata.\"@type\"=\"type.googleapis.com/google.cloud.audit.BigQueryAuditMetadata\" protoPayload.methodName=\"google.cloud.bigquery.v2.JobService.InsertJob\" operation.last=true"
  unique_writer_identity = true
}

resource "google_pubsub_topic_iam_member" "sink_pubsub_writer" {
  for_each = toset(local.projects)
  project  = var.host_project
  topic    = google_pubsub_topic.data_lineage_audit_logs.id
  role     = "roles/pubsub.publisher"
  member   = google_logging_project_sink.data_lineage_sink[each.value].writer_identity
}

resource "google_pubsub_topic" "composite_lineage" {
  project = var.host_project
  name    = "composite-lineage"
}
