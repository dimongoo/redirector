provider "aws" {
  access_key = var.redirector_aws_access_key
  secret_key = var.redirector_aws_secret_key
  region     = "us-east-1"
  version    = "=3.19.0"
}
