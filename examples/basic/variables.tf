
variable "vpc_id" {
  type = string
}

variable "public_subnets" {
  description = "Public subnets to add the ECS ALB to"
  type        = list(string)
}
