data "aws_eks_cluster" "cluster" {
  name = module.eks.cluster_name
}

data "aws_eks_cluster_auth" "cluster-auth" {
  depends_on = [data.aws_eks_cluster.cluster]
  name       = data.aws_eks_cluster.cluster.name
}
