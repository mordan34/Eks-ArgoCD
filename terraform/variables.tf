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

variable "domain" {
  description = "Route53 domain name"
  type = string
  default = "tikaldev.click"
}

variable "appname" {
  description = "General name for the app installed"
  type = string
  default = "argocd"
}

variable "env_name" {
  description = "The Environment to be used"
  type = string
  default = "Dev"
}