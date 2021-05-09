resource "aws_route53_record" "alias" {
  zone_id = var.r53_zone_id
  name    = var.r53_record_name
  type    = "A"

  alias {
    name                   = var.alias_dns_name
    zone_id                = var.alias_zone_id
    evaluate_target_health = true
  }
}
