variable "region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "node_type" {
  description = "EC2 instance type for EKS nodes"
  type = string
  default = "t3.small"
}

variable "argo-ns" {
  description = "K8S namespace for ArgoCD"
  type = string
  default = "argocd"
}