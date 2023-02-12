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
        module.load_balancer_controller
  ]
}

resource "kubectl_manifest" "ingress_argocd" {
  yaml_body  = file("${path.module}/argocd-ingress.yaml")

  depends_on = [
        module.eks,
        module.load_balancer_controller
  ]
}