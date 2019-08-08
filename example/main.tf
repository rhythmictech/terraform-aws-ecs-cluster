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

# =============================================
#  Networking and resources
# =============================================

resource "tls_private_key" "ecs_root" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = "my-vpc"
  cidr = "10.0.0.0/16"

  azs             = ["us-east-1a", "us-east-1b", "us-east-1c"]
  private_subnets = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  public_subnets  = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]

  enable_nat_gateway = true
  enable_vpn_gateway = true

  tags = local.common_tags
}

# =============================================
#  ECS 
# =============================================

module "this" {
  source = "../"
  #   source                   = "github.com/rhythmictech/terraform-aws-ecs-cluster?ref=1.0.3"

  name                     = var.cluster_name
  tags                     = local.common_tags
  vpc_id                   = module.vpc.vpc_id
  alb_subnet_ids           = module.vpc.public_subnets
  instance_subnet_ids      = module.vpc.private_subnets
  ssh_pubkey               = tls_private_key.ecs_root.public_key_openssh
  instance_type            = "t3.micro"
  region                   = var.region
  min_instances            = 1
  max_instances            = 2
  desired_instances        = 1
}

# =============================================
#  INGRESS-EGRESSS RULEZ
# =============================================

resource "aws_security_group_rule" "ecs_alb_ingress_80" {
  security_group_id = module.this.alb-sg-id
  type = "ingress"
  from_port = 80
  to_port = 80
  protocol = "tcp"
  cidr_blocks = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "ecs_alb_ingress_443" {
  security_group_id = module.this.alb-sg-id
  type = "ingress"
  from_port = 443
  to_port = 443
  protocol = "tcp"
  cidr_blocks = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "ecs_alb_egress" {
  security_group_id = module.this.alb-sg-id
  type = "egress"
  from_port = 0
  to_port = 0
  protocol = "-1"
  cidr_blocks = [module.vpc.vpc_cidr_block]
}

resource "aws_security_group_rule" "ecs_ec2_ingress_from_alb" {
  security_group_id = module.this.ec2-sg-id
  type = "ingress"
  from_port = 0
  to_port = 0
  protocol = "-1"
  source_security_group_id = module.this.alb-sg-id
}

resource "aws_security_group_rule" "ecs_ec2_egress" {
  security_group_id = module.this.ec2-sg-id
  type = "egress"
  from_port = 0
  to_port = 0
  protocol = "-1"
  cidr_blocks = ["0.0.0.0/0"]
}

# =============================================
#   Output
# =============================================

