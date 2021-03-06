resource "google_bigquery_dataset" "lineage_dataset" {
  project     = var.host_project
  dataset_id  = "data_lineage"
  description = "Dataset used to store data lineage information"
  location    = var.region
}

resource "google_bigquery_table" "lineage_table" {
  project     = var.host_project
  dataset_id  = google_bigquery_dataset.lineage_dataset.dataset_id
  table_id    = "${var.environment}_lineage_table"
  description = "Data Lineage table Recreate"
  time_partitioning {
    type  = "DAY"
    field = "reconcileTime"
  }

  schema = <<EOF
[
  {
    "name": "reconcileTime",
    "type": "TIMESTAMP",
    "mode": "NULLABLE",
    "description": "The time lineage was processed in UTC"
  },
  {
    "name": "jobInformation",
    "type": "RECORD",
    "mode": "NULLABLE",
    "description": "BigQuery Job information",
    "fields": [
      {
        "name": "jobId",
        "type": "STRING",
        "mode": "NULLABLE",
        "description": "The BigQuery/Operation Job Id which caused the change to the table."
      },
      {
        "name": "jobType",
        "type": "STRING",
        "mode": "NULLABLE"
      },
      {
        "name": "jobTime",
        "type": "TIMESTAMP",
        "mode": "NULLABLE",
        "description": "Job completion time in UTC"
      },
      {
        "name": "actuator",
        "type": "STRING",
        "mode": "NULLABLE",
        "description": "The email address of the authorized executor of Job, It can be a person or a service account."
      },
      {
        "name": "transform",
        "type": "RECORD",
        "mode": "NULLABLE",
        "description": "The transform operations done on source data. E.g. A SQL query or pipeline version information etc.",
        "fields": [
          {
            "name": "sql",
            "type": "STRING",
            "mode": "NULLABLE",
            "description": "The BigQuery or Dataflow SQL if that was the transformation operation."
          }
        ]
      }
    ]
  },
  {
    "name": "tableLineage",
    "type": "RECORD",
    "mode": "NULLABLE",
    "description": "Table level information",
    "fields": [
      {
        "name": "target",
        "type": "RECORD",
        "mode": "NULLABLE",
        "description": "The Data Entity which is created/modified",
        "fields": [
          {
            "name": "kind",
            "type": "STRING",
            "mode": "NULLABLE",
            "description": "Type of Entity - (UNKNOWN, QUERY_LEVEL_TABLE, CLOUD_STORAGE_FILE, BIGQUERY_TABLE)"
          },
          {
            "name": "sqlResource",
            "type": "STRING",
            "mode": "NULLABLE"
          },
          {
            "name": "linkedResource",
            "type": "STRING",
            "mode": "NULLABLE",
            "description": "A valid Fully Qualified GCP Resource name."
          }
        ]
      },
      {
        "name": "operation",
        "type": "STRING",
        "mode": "NULLABLE",
        "description": "The BigQuery Job type e.g. QUERY, COPY or IMPORT"
      },
      {
        "name": "parents",
        "type": "RECORD",
        "mode": "REPEATED",
        "description": "The tables which were read for generating/updating the source table.",
        "fields": [
          {
            "name": "kind",
            "type": "STRING",
            "mode": "NULLABLE",
            "description": "Type of Entity - (UNKNOWN, QUERY_LEVEL_TABLE, CLOUD_STORAGE_FILE, BIGQUERY_TABLE)"
          },
          {
            "name": "sqlResource",
            "type": "STRING",
            "mode": "NULLABLE"
          },
          {
            "name": "linkedResource",
            "type": "STRING",
            "mode": "NULLABLE",
            "description": "A valid Fully Qualified GCP Resource name."
          }
        ]
      }
    ]
  },
  {
    "name": "columnLineage",
    "type": "RECORD",
    "mode": "REPEATED",
    "description": "Column Level lineage if its a QUERY operation",
    "fields": [
      {
        "name": "target",
        "type": "RECORD",
        "mode": "NULLABLE",
        "description": "The Column Entity which is created/modified",
        "fields": [
          {
            "name": "column",
            "type": "STRING",
            "mode": "NULLABLE",
            "description": "Name of the column in the Data Entity"
          }
        ]
      },
      {
        "name": "operations",
        "type": "STRING",
        "mode": "REPEATED",
        "description": "List of Functions/Operations done on the source columns. e.g. SUM, CONCAT"
      },
      {
        "name": "parents",
        "type": "RECORD",
        "mode": "REPEATED",
        "description": "The Column Entity which is read/used to generate the output",
        "fields": [
          {
            "name": "table",
            "type": "RECORD",
            "mode": "NULLABLE",
            "description": "The Data Entity",
            "fields": [
              {
                "name": "kind",
                "type": "STRING",
                "mode": "NULLABLE",
                "description": "Type of Entity - (UNKNOWN, QUERY_LEVEL_TABLE, CLOUD_STORAGE_FILE, BIGQUERY_TABLE)"
              },
              {
                "name": "sqlResource",
                "type": "STRING",
                "mode": "NULLABLE"
              },
              {
                "name": "linkedResource",
                "type": "STRING",
                "mode": "NULLABLE",
                "description": "A valid Fully Qualified GCP Resource name."
              }
            ]
          },
          {
            "name": "column",
            "type": "STRING",
            "mode": "NULLABLE",
            "description": "Name of the column in the Data Entity"
          }
        ]
      }
    ]
  }
]

EOF

}