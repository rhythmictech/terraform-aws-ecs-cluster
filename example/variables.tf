# =============================================
#  Variables 
# =============================================
variable "env" {}

variable "cluster_name" {
  description = "Name for ECS Cluster"
  type        = string
  default     = "ecs-cluster"
}

variable "region" {
  type = string
}

variable "tags" {
  type        = map(string)
  description = "common tags for all resources"
  default     = {}
}

locals {
  common_tags = merge(var.tags, {
    env                 = var.env
    terraform_managed   = "true"
    terraform_workspace = terraform.workspace
    ecs_cluster         = var.cluster_name
  })
}