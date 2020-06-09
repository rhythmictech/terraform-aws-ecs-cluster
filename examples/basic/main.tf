########################################
#  Networking and resources
########################################

resource "tls_private_key" "ecs_root" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

########################################
#  ECS
########################################

module "this" {
  source = "../"

  name                = var.cluster_name
  tags                = var.tags
  vpc_id              = var.vpc_id
  alb_subnet_ids      = var.public_subnets
  instance_subnet_ids = var.private_subnets
  ssh_pubkey          = tls_private_key.ecs_root.public_key_openssh
  instance_type       = "t3.micro"
  region              = var.region
  min_instances       = 1
  max_instances       = 2
  desired_instances   = 1
}

########################################
#  Security Group Rules
########################################

resource "aws_security_group_rule" "ecs_alb_ingress_80" {
  description       = "SG for HTTP traffic"
  security_group_id = module.this.alb-sg-id
  type              = "ingress"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"] #tfsec:ignore:AWS006
}

resource "aws_security_group_rule" "ecs_alb_ingress_443" {
  description       = "SG for HTTPS traffic"
  security_group_id = module.this.alb-sg-id
  type              = "ingress"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"] #tfsec:ignore:AWS006
}

resource "aws_security_group_rule" "ecs_alb_egress" {
  description       = "SG for Egress"
  security_group_id = module.this.alb-sg-id
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = [module.vpc.vpc_cidr_block]
}

resource "aws_security_group_rule" "ecs_ec2_ingress_from_alb" {
  description              = "SG rule to allow ALB -> EC2 traffic"
  security_group_id        = module.this.ec2-sg-id
  type                     = "ingress"
  from_port                = 0
  to_port                  = 0
  protocol                 = "-1"
  source_security_group_id = module.this.alb-sg-id
}

resource "aws_security_group_rule" "ecs_ec2_egress" {
  description       = "SG rule to allow EC2 egress"
  security_group_id = module.this.ec2-sg-id
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"] #tfsec:ignore:AWS007
}
