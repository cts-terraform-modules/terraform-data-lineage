locals {
  host_project_cloudbuild_roles = {
    "bqadmin"       = "roles/bigquery.admin"
    "bqeditor"      = "roles/bigquery.dataEditor"
    "dataflowadmin" = "roles/dataflow.admin"
  }
}

resource "google_sourcerepo_repository" "data_lineage" {
  project = var.host_project
  name    = "data-lineage"
}

resource "google_cloudbuild_trigger" "dataflow_build" {
  provider = google-beta

  project     = var.host_project
  name        = "dataflow-build"
  description = "Build and deploy dataflow lineage job."

  trigger_template {
    branch_name = "master"
    repo_name   = google_sourcerepo_repository.data_lineage.name
  }

  build {
    step {
      name       = "gcr.io/cloud-builders/gcloud"
      entrypoint = "/bin/bash"

      args = [
        "-ce",

        <<EOF
          apt update
          apt install maven -y
          mvn generate-sources compile package exec:java \
            -Dexec.mainClass=com.google.cloud.solutions.datalineage.LineageExtractionPipeline \
            -Dmaven.test.skip=true \
            -Dexec.args=" \
          --streaming=true \
          --project=$$PROJECT_ID \
          --runner=DataflowRunner \
          --gcpTempLocation=gs://$$TEMP_GCS_BUCKET/temp/ \
          --stagingLocation=gs://$$TEMP_GCS_BUCKET/staging/ \
          --workerMachineType=n1-standard-4 \
          --subnetwork=https://www.googleapis.com/compute/v1/projects/$$PROJECT_ID/regions/$$REGION_ID/subnetworks/$$DATAFLOW_SUBNET \
          --region=$$REGION_ID \
          --lineageTableName=$$PROJECT_ID:$$DATASET_ID.$$LINEAGE_TABLE_ID \
          --tagTemplateId=projects/$$PROJECT_ID/locations/$$REGION_ID/tagTemplates/$$LINEAGE_TAG_TEMPLATE_NAME \
          --pubsubTopic=projects/$$PROJECT_ID/topics/$$AUDIT_LOGS_PUBSUB_TOPIC \
          --compositeLineageTopic=projects/$$PROJECT_ID/topics/$$LINEAGE_OUTPUT_PUBSUB_TOPIC"
        EOF
      ]

      env = [
        "PROJECT_ID=${var.host_project}",
        "TEMP_GCS_BUCKET=${google_storage_bucket.dataflow_staging_bucket.name}",
        "REGION_ID=${var.region}",
        "DATASET_ID=${google_bigquery_table.lineage_table.dataset_id}",
        "LINEAGE_TABLE_ID=${google_bigquery_table.lineage_table.table_id}",
        "LINEAGE_TAG_TEMPLATE_NAME=${google_data_catalog_tag_template.lineage_tag_template.tag_template_id}",
        "AUDIT_LOGS_PUBSUB_TOPIC=${google_pubsub_topic.data_lineage_audit_logs.name}",
        "LINEAGE_OUTPUT_PUBSUB_TOPIC=${google_pubsub_topic.composite_lineage.name}",
        "DATAFLOW_SUBNET=${var.dataflow_subnet}"
      ]
    }
  }
}

data "google_project" "host_project" {
  project_id = var.host_project
}

resource "google_project_iam_member" "utilities_cloudbuild" {
  for_each = local.host_project_cloudbuild_roles
  project  = var.host_project
  role     = each.value
  member   = "serviceAccount:${data.google_project.host_project.number}@cloudbuild.gserviceaccount.com"
}