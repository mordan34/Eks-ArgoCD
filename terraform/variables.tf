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

variable "argo_ns" {
  description = "K8S namespace for ArgoCD"
  type = string
  default = "argocd"
}

variable "argo_svc" {
  description = "K8S service name for ArgoCD"
  type = string
  default = "argo-cd-argocd-server"
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

variable "ingress_svc" {
  description = "General name for service"
  type = string
  default = "pages"
}

variable "env_name" {
  description = "The Environment to be used"
  type = string
  default = "Dev"
}

# Aws Autoscaler
variable "autoscaler_enabled" {
  type        = bool
  default     = true
  description = "If true Install Kubernetes Autoscaler"
}

variable "autoscaler_version" {
  description = "Autoscaler chart version"
  type        = string
  default     = "9.9.2"
}

variable "grafana_svc" {
  description = "Route53 record name of grafana service"
  type        = string
  default     = "monitoring"
}