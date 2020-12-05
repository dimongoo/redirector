# Redirector

Example project that routes traffic to dedicated S3 spaces based on domain that request came with.\
Mapping of domains to paths is kept inside DynamoDB, while routing is executed with use of Lambda@Edge.

# Configuration

Configuration is split per service and per use

* `init.tf` - initial information for terraform about which provider is used and in which region
* `cloudfront.tf` - AWS Cloudfront CDN configuration
* `dynamodb.tf` - AWS DynamoDB configuration
* `lambda.tf` - AWS Lambda@Edge configuration
* `s3.tf` - AWS S3 bucket configuration
* `files/*` directory - contains Lambda source code and static files stored on S3

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

# How to test

After successful execution of `terraform apply` you will see fillowing output:
```
Outputs:

cloudfront_url = xxxxxxxxxxxxx.cloudfront.net
```
Go to the output URL in browser. The effect should be as follows:
```
Hello World Targeted from brf4gscvg8sncv210vja!!
```

### What is happening

1. CloudFront received request for `/`
2. Lambda@Edge checked that Cloudfront domain (from request) is in DynamoDB table
3. Lambda@Edge rewrote the request path based on information from DynamoDB to `/brf4gscvg8sncv210vja/index.html`
4. CloudFront forwarded reques to S3 bucket to path `/brf4gscvg8sncv210vja/index.html`
5. Succesfully retrieved html was returned to user

#### Side note 

During provisioning, DynamoDB is populated with test record:
```
key: Current cloudFront domain
value: brf4gscvg8sncv210vja
```
