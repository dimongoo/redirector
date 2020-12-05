
# DynamoDB
resource "aws_dynamodb_table" "redirector" {
  hash_key         = "domain"
  name             = "domainMappings"
  billing_mode     = "PAY_PER_REQUEST"
  stream_enabled   = true
  stream_view_type = "NEW_AND_OLD_IMAGES"

  attribute {
    name = "domain"
    type = "S"
  }

  replica {
    region_name = "eu-west-1"
  }
}

# DynamoDB sample data
resource "aws_dynamodb_table_item" "redirector" {
  table_name = aws_dynamodb_table.redirector.name
  hash_key   = aws_dynamodb_table.redirector.hash_key

  item = <<ITEM
{
  "domain": {"S": "${aws_cloudfront_distribution.redirector.domain_name}"},
  "mapping": {"S": "brf4gscvg8sncv210vja"}
}
ITEM
}
