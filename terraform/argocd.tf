resource "helm_release" "argo_cd" {
  name       = "argo-cd"
  repository = "https://argoproj.github.io/argo-helm"
  chart      = "argo-cd"
  version    = "5.19.15"
  namespace =  kubernetes_namespace.argo_ns.metadata[0].name
  set {
    name  = "server.service.type"
    value = "LoadBalancer"
  }

  set {
    name  = "configs.secret.argocdServerAdminPassword"
    value = random_password.master_password.bcrypt_hash
  }

  set {
    name  = "server.service.annotations\\.beta\\.kubernetes\\.io/aws-load-balancer-proxy-protocol"
    value = "*"
  }

  set {
    name  = "server.service.annotations.external-dns\\.alpha\\.kubernetes.io/hostname"
    value = "argocd.${var.domain}"
  }

  set {
    name  = "server.service.annotations.service\\.beta\\.kubernetes.io/aws-load-balancer-scheme"
    value = "external"
  }

  depends_on = [
        module.eks,
        random_password.master_password,
        module.load_balancer_controller,
        kubernetes_namespace.argo_ns
  ]
}

resource "kubectl_manifest" "ingress_argocd" {
  yaml_body  = templatefile("${path.module}/argocd-ingress.yaml", { argocd_svc = "${var.argo_svc}" })

  depends_on = [
        helm_release.argo_cd,
        aws_route53_zone.main
  ]
}