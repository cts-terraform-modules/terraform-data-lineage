resource "google_data_catalog_tag_template" "lineage_tag_template" {
  project         = var.host_project
  tag_template_id = "lineage_tag_template"
  region          = var.region
  display_name    = "Data Lineage"

  fields {
    field_id     = "jobTime"
    display_name = "Entity change timestamp"
    type {
      primitive_type = "TIMESTAMP"
    }
    is_required = true
  }

  fields {
    field_id     = "reconcileTime"
    display_name = "Lineage processed timestamp"
    type {
      primitive_type = "TIMESTAMP"
    }
    is_required = true
  }

  fields {
    field_id     = "actuator"
    display_name = "The email address of the authorized executor of Job which can be a person or a service account"
    type {
      primitive_type = "STRING"
    }
  }

  fields {
    field_id     = "jobId"
    display_name = "The BigQuery or Operation Job Id which made the change to the table"
    type {
      primitive_type = "STRING"
    }
  }

  fields {
    field_id     = "parents"
    display_name = "The tables which were read for generating this entity"
    type {
      primitive_type = "STRING"
    }
  }

  force_delete = "false"
}