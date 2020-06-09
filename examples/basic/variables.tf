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
  default = {
    terraform_managed = "true"
  }
  description = "common tags for all resources"
  type        = map(string)
}

variable "vpc_id" {
  type = string
}

variable "public_subnets" {
  description = "Public subnets to add the ECS ALB to"
  type        = list(string)
}
