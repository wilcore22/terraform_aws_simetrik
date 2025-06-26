# Bucket S3 para archivos estáticos
resource "aws_s3_bucket" "frontend" {
  bucket = "${var.app_name}-frontend-${var.environment}"
  acl    = "private"
}

# CloudFront para distribución global
resource "aws_cloudfront_distribution" "frontend" {
  origin {
    domain_name = aws_s3_bucket.frontend.bucket_regional_domain_name
    origin_id   = "S3-${aws_s3_bucket.frontend.id}"

    s3_origin_config {
      origin_access_identity = aws_cloudfront_origin_access_identity.frontend.cloudfront_access_identity_path
    }
  }

  enabled             = true
  default_root_object = "index.html"


  custom_error_response {
  error_code         = 404
  response_code      = 200
  response_page_path = "/index.html"
}

  default_cache_behavior {
    allowed_methods  = ["GET", "HEAD"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = "S3-${aws_s3_bucket.frontend.id}"

    forwarded_values {
      query_string = false
      cookies {
        forward = "none"
      }
    }

    viewer_protocol_policy = "redirect-to-https"
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

resource "aws_cloudfront_origin_access_identity" "frontend" {
  comment = "OAI for ${var.app_name}"
}


resource "aws_rum_app_monitor" "frontend" {
  name   = "${var.app_name}-monitor"
  domain = aws_s3_bucket.frontend.bucket_regional_domain_name

  app_monitor_configuration {
    session_sample_rate = 0.1  
  }
}
