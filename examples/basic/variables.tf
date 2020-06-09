# =============================================
#  Variables
# =============================================

variable "cluster_name" {
  description = "Name for ECS Cluster"
  type        = string
  default     = "ecs-cluster"
}

variable "region" {
  type    = string
  default = "us-east-1"
}

variable "tags" {
  type        = map(string)
  description = "common tags for all resources"
  default = {
    terraform_managed = "true"
  }
}

variable "vpc_id" {
  type = string
}

variable "public_subnets" {
  description = "Public subnets to add the ECS ALB to"
  type        = list(string)
}

variable "private_subnets" {
  description = "Private subnets to add the ECS EC2 instances to"
  type        = list(string)
}
