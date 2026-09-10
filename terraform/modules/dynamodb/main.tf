resource "aws_dynamodb_table" "this" {
  name         = var.table_name
  billing_mode = var.billing_mode
  hash_key     = var.hash_key

  attribute {
    name = var.hash_key
    type = "S"
  }

  # Cheap insurance against accidental deletes/writes — ties into the
  # hackathon's Disaster Recovery requirement (RPO for volunteer data).
  point_in_time_recovery {
    enabled = true
  }

  tags = var.tags
}
