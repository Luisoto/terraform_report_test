variable "table_name" {
  type = string
  default = "ItemsTable"
}

variable "artifact_s3_bucket" {
  type = string
  default = "qrvey-bucket"
}

variable "artifact_s3_file" {
  type = string
  default = "artifact.zip"
}

