data "aws_route53_zone" "primary" {
  name         = var.hosted_zone_name
  private_zone = false
}

resource "aws_acm_certificate" "static_website" {
  provider          = aws.us_east_1
  domain_name       = var.site_domain
  validation_method = "DNS"

  tags = {
    Name        = "${var.project_name}-certificate"
    Environment = var.environment
  }
}

resource "aws_route53_record" "certificate_validation" {
  for_each = {
    for dvo in aws_acm_certificate.static_website.domain_validation_options :
    dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  }

  zone_id = data.aws_route53_zone.primary.zone_id
  name    = each.value.name
  type    = each.value.type
  ttl     = 60
  records = [each.value.record]
}

resource "aws_acm_certificate_validation" "static_website" {
  provider                = aws.us_east_1
  certificate_arn         = aws_acm_certificate.static_website.arn
  validation_record_fqdns = [for record in aws_route53_record.certificate_validation : record.fqdn]
}

resource "aws_route53_record" "site_alias" {
  zone_id = data.aws_route53_zone.primary.zone_id
  name    = var.site_domain
  type    = "A"

  alias {
    name                   = aws_cloudfront_distribution.static_website.domain_name
    zone_id                = aws_cloudfront_distribution.static_website.hosted_zone_id
    evaluate_target_health = false
  }
}
