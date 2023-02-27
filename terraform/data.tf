data "aws_eks_cluster" "cluster" {
  name = module.eks.cluster_name
}

data "aws_eks_cluster_auth" "cluster-auth" {
  depends_on = [data.aws_eks_cluster.cluster]
  name       = data.aws_eks_cluster.cluster.name
}

data "kubernetes_service" "ingress_argocd" {
  metadata {
    name      = var.argo_svc
    namespace = var.argo_ns
  }
  depends_on = [
        kubectl_manifest.ingress_argocd,
        module.load_balancer_controller]
}

data "aws_elb" "ingress_argocd" {
  name = regex(
    "(^[^-]+)",
    data.kubernetes_service.ingress_argocd.status[0].load_balancer[0].ingress[0].hostname
  )[0]
  depends_on = [data.kubernetes_service.ingress_argocd]
}

data "kubernetes_service" "ingress_nginx" {
  metadata {
    name      = "ingress-nginx-controller"
    namespace = "ingress-nginx"
  }
  depends_on = [kubectl_manifest.nginx]
}

# data "aws_elb" "ingress_nginx" {
#   name        = data.kubernetes_service.ingress_nginx.status[0].load_balancer[0].ingress[0].hostname
  
#   depends_on = [kubectl_manifest.nginx]
# }