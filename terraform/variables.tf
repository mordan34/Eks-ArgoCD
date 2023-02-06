variable "region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "node_type" {
  description = "EC2 instance type for EKS nodes"
  type = string
  default = "t2.micro"
}