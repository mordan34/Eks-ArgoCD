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
}

data "aws_elb" "ingress_argocd" {
  name = regex(
    "(^[^-]+)",
    data.kubernetes_service.ingress_argocd.status[0].load_balancer[0].ingress[0].hostname
  )[0]
}