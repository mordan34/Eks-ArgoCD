provider "aws" {
  region = var.region
  profile = "personal"
}

data "aws_availability_zones" "available" {}

locals {
  cluster_name = "Prod-eks-${random_string.suffix.result}"
}

resource "random_string" "suffix" {
  length  = 8
  special = false
}

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "3.19.0"

  name = "Tikal-vpc"

  cidr = "10.0.0.0/16"
  azs  = slice(data.aws_availability_zones.available.names, 0, 3)

  private_subnets = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  public_subnets  = ["10.0.4.0/24", "10.0.5.0/24", "10.0.6.0/24"]

  enable_nat_gateway   = true
  single_nat_gateway   = true
  enable_dns_hostnames = true

  public_subnet_tags = {
    "kubernetes.io/cluster/${local.cluster_name}" = "shared"
    "kubernetes.io/role/elb"                      = 1
  }

  private_subnet_tags = {
    "kubernetes.io/cluster/${local.cluster_name}" = "shared"
    "kubernetes.io/role/internal-elb"             = 1
  }
}

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
}

resource "kubernetes_namespace" "argo_ns" {
  metadata {
    annotations = {
      name = var.argo-ns
    }
    name = var.argo-ns
  }
}

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
}

resource "aws_route53_zone" "main" {
  name = var.domain
}


module "load_balancer_controller" {
  source                           = "DNXLabs/eks-lb-controller/aws"
  version                          = "0.7.0"
  cluster_identity_oidc_issuer     = module.eks.cluster_oidc_issuer_url
  cluster_identity_oidc_issuer_arn = module.eks.oidc_provider_arn
  cluster_name                     = module.eks.cluster_name
}

resource "kubectl_manifest" "ingress_argocd" {
  yaml_body  = file("${path.module}/argocd-ingress.yaml")

  depends_on = [
        module.eks
  ]
}