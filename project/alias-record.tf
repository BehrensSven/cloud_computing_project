# Create an A-record in Route 53 for the subdomain www.mosaik-modern.com
# This connects the domain to the CloudFront distribution using an alias

resource "aws_route53_record" "frontend_alias" {
  zone_id = data.aws_route53_zone.main.zone_id  # Reference to the main hosted zone (mosaik-modern.com)
  name    = "www.mosaik-modern.com"             # The subdomain that should point to CloudFront
  type    = "A"                                  # Type A = IPv4 address (alias in this case)

  alias {
    name                   = aws_cloudfront_distribution.frontend_cdn.domain_name   # CloudFront domain
    zone_id                = aws_cloudfront_distribution.frontend_cdn.hosted_zone_id # CloudFront’s hosted zone ID
    evaluate_target_health = false  # No health checks needed for CloudFront
  }
}
