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

# resource "aws_route53_record" "pages" {
#   zone_id = aws_route53_zone.main.id
#   name    = "${var.ingress_svc}.${var.domain}"
#   type    = "CNAME"
#   ttl     = "300"
#   records = ["k8s-ingressn-ingressn-4fa0f755c5-ae8b73a324ad4b40.elb.us-east-1.amazonaws.com"] #[data.kubernetes_ingress.ingress_nginx.status[0].load_balancer[0].ingress[0].hostname] #

#   depends_on = [
#         data.kubernetes_ingress.ingress_nginx,
#         kubectl_manifest.nginx
#   ]
# }

resource "aws_route53_record" "pages" {
  for_each = toset(["A", "AAAA"])

  zone_id = aws_route53_zone.main.id
  name    = "${var.ingress_svc}.${var.domain}"
  type    = each.value

  alias {
    name                   = data.kubernetes_service.ingress_nginx.status[0].load_balancer[0].ingress[0].hostname
    zone_id                = data.aws_elb.ingress_nginx.zone_id
    evaluate_target_health = false
  }
  depends_on = [
        aws_route53_zone.main,
        data.aws_elb.ingress_nginx,
        data.kubernetes_service.ingress_nginx
  ]
}