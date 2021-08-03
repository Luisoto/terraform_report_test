resource "aws_dynamodb_table" "qrvey_table" {
  name           = var.table_name
  billing_mode   = "PROVISIONED"
  read_capacity  = 20
  write_capacity = 20
  hash_key       = "name"
  range_key      = "alias"

  attribute {
    name = "name"
    type = "S"
  }

  attribute {
    name = "alias"
    type = "S"
  }

}