# Use a provider alias for us-east-1 (required for CloudFront TLS certificates!)
provider "aws" {
  alias  = "us_east_1"
  region = "us-east-1"  # CloudFront accepts TLS certs only from this region
}

# Request a TLS certificate for the frontend domain
resource "aws_acm_certificate" "frontend_cert" {
  provider          = aws.us_east_1
  domain_name       = "www.mosaik-modern.com"
  validation_method = "DNS"  # Validate via Route53 DNS record

  tags = {
    Name = "CloudFront TLS Certificate"
  }
}
