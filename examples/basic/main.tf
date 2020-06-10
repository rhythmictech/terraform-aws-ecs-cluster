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
  source = "../.."

  alb_subnet_ids    = var.public_subnets
  asg_max_size      = 1
  ec2_subnet_ids    = var.public_subnets
  desired_instances = 1
  instance_type     = "t3.micro"
  max_instances     = 2
  min_instances     = 1
  name              = "rhythmic-sandbox"
  ssh_pubkey        = tls_private_key.ecs_root.public_key_openssh
  vpc_id            = var.vpc_id

  tags = {
    terraform_managed = true
    delete_me         = "please"
  }
}

########################################
#  Security Group Rules
########################################

resource "aws_security_group_rule" "alb_ingress_80" {
  description       = "SG for HTTP traffic"
  security_group_id = module.this.alb_security_group_id
  type              = "ingress"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"] #tfsec:ignore:AWS006
}

resource "aws_security_group_rule" "alb_egress_all" {
  description       = "SG for Egress"
  security_group_id = module.this.alb_security_group_id
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"] #tfsec:ignore:AWS007
}
