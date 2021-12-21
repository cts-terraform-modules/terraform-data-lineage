variable "host_project" {
  type = string
  description = "The project which hosts the data lineage resources"
}

variable "logged_projects" {
  type = list(string)
  description = "The projects which feed log information to the lineage solution"
}

variable "region" {
  type = string
  default = "europe-west2"
  description = "The region to build resources in"
}

variable "dataflow_subnet" {
  type = string
  description = "The name of the subnet the subnet to run dataflow within"
  default = "default"
}
