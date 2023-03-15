resource "aws_route53_zone" "main" {
  name = var.domain
}

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

module "eks-external-dns" {
  source  = "lablabs/eks-external-dns/aws"
  version = "1.1.1"

  cluster_identity_oidc_issuer 	= module.eks.cluster_oidc_issuer_url
  cluster_identity_oidc_issuer_arn  = module.eks.oidc_provider_arn

  depends_on = [
        module.eks
  ]
}