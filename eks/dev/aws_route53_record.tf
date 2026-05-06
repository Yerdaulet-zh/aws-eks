data "aws_lb" "gateway_nlb" {
  name = var.load_balancer_name
}

resource "aws_route53_record" "this" {
  zone_id = data.aws_route53_zone.zones["imon.academy"].zone_id
  name    = "*.${data.aws_route53_zone.zones["imon.academy"].name}"
  type    = "A"

  allow_overwrite = true

  alias {
    name                   = data.aws_lb.gateway_nlb.dns_name
    zone_id                = data.aws_lb.gateway_nlb.zone_id
    evaluate_target_health = true
  }

  set_identifier = "prod-eks-frankfurt"
  weighted_routing_policy {
    weight = 100
  }
}
