resource "aws_route53_zone" "main" {
  name = var.domain
}

resource "aws_route53_record" "ingress_argocd" {
  for_each = toset(["A", "AAAA"])

  zone_id = aws_route53_zone.main.id
  name    = "${var.appname}.${var.domain}"
  type    = each.value

  alias {
    name                   = data.kubernetes_service.ingress_argocd.status[0].load_balancer[0].ingress[0].hostname
    zone_id                = data.aws_elb.ingress_argocd.zone_id
    evaluate_target_health = false
  }
  depends_on = [
        aws_route53_zone.main
  ]
}

resource "aws_route53_record" "ingress_nginx" {
  zone_id = aws_route53_zone.main.id
  name    = "${var.ingress_svc}.${var.domain}"
  type    = "A"

  alias {
    name                   = data.kubernetes_ingress.ingress_nginx.status.0.load_balancer.0.ingress.0.hostname
    zone_id                = data.aws_elb.ingress_nginx.zone_id
    evaluate_target_health = false
  }
  records = [data.kubernetes_ingress.ingress_nginx.status.0.load_balancer.0.ingress.0.hostname]
  
  depends_on = [data.kubernetes_ingress.ingress_nginx]
}