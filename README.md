# Redirector

Example project that routes traffic to dedicated S3 spaces based on domain that request came through.\
Mapping of domainsto paths is kept inside DynamoDB, while routing is executed on Lambda@Edge.

# Configuration

Configuration is split per service used and per file types

* `init.db` - initial information for terraform about which provider is used and in which region
* `cloudfront.tf` - AWS Cloudfront CDN configuration
* `dynamodb.tf` - AWS DynamoDB configuartion
* `lambda.tf` - AWS Lambda@Edge configuration
* `s3.tf` - AWS S3 bucket configuration
* `files` directory - contains Lambda source code and static files stored on S3


# How to run

Project was create with use of `terraform v0.13.5`.\

To start, simply create `creds.tf` file in root directory with following structure:
```
variable "redirector_aws_access_key" {
  default = "YOUR AWS ACCESS KEY"
}

variable "redirector_aws_secret_key" {
  default = "YOUR AWS SECRET KEY"
}
```

then execute `terraform apply`.
