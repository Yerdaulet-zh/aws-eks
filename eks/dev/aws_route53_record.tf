data "aws_elb_hosted_zone_id" "main" {}

resource "aws_route53_record" "this" {
  zone_id = data.aws_route53_zone.zones["imon.work"].zone_id
  name    = "*.${data.aws_route53_zone.zones["imon.work"].name}"
  type    = "A"

  allow_overwrite = true

  alias {
    name                   = var.load_balancer_dns_name
    zone_id                = data.aws_elb_hosted_zone_id.main.id
    evaluate_target_health = true
  }

  set_identifier = "prod-eks-frankfurt"
  weighted_routing_policy {
    weight = 100
  }
}
