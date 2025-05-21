# Creates a CloudFront distribution that delivers both frontend and API content via CDN
resource "aws_cloudfront_distribution" "frontend_cdn" {
  aliases             = ["www.mosaik-modern.com"]  # Custom domain
  enabled             = true                       # Enable the distribution
  is_ipv6_enabled     = true                       # IPv6 support
  default_root_object = "index.html"               # Entry file for the Vue app

  # === ORIGIN 1: Vue frontend from S3 ===
  origin {
    domain_name = aws_s3_bucket_website_configuration.frontend_site.website_endpoint  # Public S3 website URL
    origin_id   = "S3FrontendOrigin"  # Logical ID

    custom_origin_config {
      http_port              = 80
      https_port             = 443
      origin_protocol_policy = "http-only"  # S3 static websites support only HTTP
      origin_ssl_protocols   = ["TLSv1.2"]
    }
  }

  # === ORIGIN 2: Django backend via Load Balancer ===
  origin {
    domain_name = aws_lb.app.dns_name  # ALB DNS name
    origin_id   = "ALBOrigin"

    custom_origin_config {
      http_port              = 80
      https_port             = 443
      origin_protocol_policy = "http-only"  # ALB uses plain HTTP (TLS termination is at CloudFront)
      origin_ssl_protocols   = ["TLSv1.2"]
    }
  }

  # === Default behavior: serve Vue app from S3 ===
  default_cache_behavior {
    allowed_methods        = ["GET", "HEAD"]        # Only allow simple requests
    cached_methods         = ["GET", "HEAD"]
    target_origin_id       = "S3FrontendOrigin"     # Link to the S3 origin
    viewer_protocol_policy = "redirect-to-https"    # Force HTTPS

    forwarded_values {
      query_string = false
      cookies {
        forward = "none"  # No cookies required for static files
      }
    }
  }

  # === Special behavior: forward API requests to Django backend ===
  ordered_cache_behavior {
    path_pattern           = "/api/*"                # Match all API calls
    target_origin_id       = "ALBOrigin"             # Forward to ALB (Django backend)
    viewer_protocol_policy = "redirect-to-https"
    allowed_methods        = ["GET", "HEAD", "OPTIONS", "PUT", "POST", "PATCH", "DELETE"]  # Allow all REST methods
    cached_methods         = ["GET", "HEAD"]         # Only cache safe methods

    forwarded_values {
      query_string = true                            # Required for most APIs
      headers      = ["Authorization", "Content-Type"]  # Pass auth headers

      cookies {
        forward = "all"  # Forward cookies (e.g. for sessions or CSRF)
      }
    }

    min_ttl     = 0
    default_ttl = 0
    max_ttl     = 0     # Disable caching for dynamic API responses
  }

  # === Allow access from all regions (no geo restriction) ===
  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  # === TLS configuration ===
  viewer_certificate {
    acm_certificate_arn      = aws_acm_certificate.frontend_cert.arn  # Custom SSL certificate from ACM
    ssl_support_method        = "sni-only"                             # Standard for custom domains
    minimum_protocol_version = "TLSv1.2_2021"
  }

  # === Use best performance globally ===
  price_class = "PriceClass_All"

  tags = {
    Name = "VueFrontendCDN"
  }

  # CloudFront depends on the public S3 policy and a ready Load Balancer
  depends_on = [aws_s3_bucket_policy.public_read, aws_lb.app]
}
