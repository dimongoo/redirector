# CloudFront distribution
resource "aws_cloudfront_distribution" "redirector" {
  origin {
    domain_name = aws_s3_bucket.redirector.bucket_regional_domain_name
    origin_id   = aws_s3_bucket.redirector.id

    s3_origin_config {
      origin_access_identity = aws_cloudfront_origin_access_identity.redirector.cloudfront_access_identity_path
    }
  }

  enabled = true

  default_cache_behavior {
    allowed_methods  = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = aws_s3_bucket.redirector.id

    forwarded_values {
      query_string = false

      cookies {
        forward = "none"
      }
    }

    lambda_function_association {
      event_type   = "viewer-request"
      lambda_arn   = aws_lambda_function.redirector.qualified_arn
      include_body = false
    }

    viewer_protocol_policy = "redirect-to-https"
    min_ttl                = 1
    default_ttl            = 1
    max_ttl                = 1
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    cloudfront_default_certificate = true
  }
}

output "cloudfront_url" {
  description = "URL of CloudFront instance"
  value       = aws_cloudfront_distribution.redirector.domain_name
}
