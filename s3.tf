# Origin identity for cloudFront to access S3
resource "aws_cloudfront_origin_access_identity" "redirector" {
}

# S3 bucket
resource "aws_s3_bucket" "redirector" {
  bucket = "redirector-test-project-bucket"
  acl    = "private"
}

# Bucket policy for CloudFront to access S3
data "aws_iam_policy_document" "redirector-s3-policy" {
  statement {
    actions   = ["s3:GetObject"]
    resources = ["${aws_s3_bucket.redirector.arn}/*"]

    principals {
      type        = "AWS"
      identifiers = [aws_cloudfront_origin_access_identity.redirector.iam_arn]
    }
  }
}

resource "aws_s3_bucket_policy" "redirector-s3-policy" {
  bucket = aws_s3_bucket.redirector.id
  policy = data.aws_iam_policy_document.redirector-s3-policy.json
}

# S3 sample data
resource "aws_s3_bucket_object" "redirector-index-html" {
  bucket = aws_s3_bucket.redirector.id
  content_type = "text/html"
  key    = "brf4gscvg8sncv210vja/index.html"
  source = "files/targeted-index.html"
  etag   = filemd5("files/targeted-index.html")
}

resource "aws_s3_bucket_object" "redirector-error-html" {
  bucket = aws_s3_bucket.redirector.id
  content_type = "text/html"
  key    = "error.html"
  source = "files/error.html"
  etag   = filemd5("files/error.html")
}
