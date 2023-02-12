module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "19.5.1"

  cluster_name    = local.cluster_name
  cluster_version = "1.24"

  vpc_id                         = module.vpc.vpc_id
  subnet_ids                     = module.vpc.private_subnets
  cluster_endpoint_public_access = true

  eks_managed_node_group_defaults = {
    ami_type = "AL2_x86_64"

  }

  eks_managed_node_groups = {
    one = {
      name = "node-group-1"

      instance_types = [var.node_type]

      min_size     = 1
      max_size     = 3
      desired_size = 2
    }

    two = {
      name = "node-group-2"

      instance_types = [var.node_type]

      min_size     = 1
      max_size     = 2
      desired_size = 1
    }
  }

  tags = {
    environment = var.env_name
    build       = "Terraform"
  }
}

resource "kubernetes_namespace" "argo_ns" {
  metadata {
    annotations = {
      name = var.argo-ns
    }
    name = var.argo-ns
  }

  depends_on = [
        module.eks
  ]
}

resource "null_resource" "kubectl" {
    provisioner "local-exec" {
        command = "aws eks --region ${var.region} update-kubeconfig --name ${data.aws_eks_cluster.cluster.name} --profile personal"
    }
}