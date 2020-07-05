
########################################
# AMI and Launch Config
########################################

locals {
  get_latest_ami = var.ami_id == ""
  ami_id         = coalesce(var.ami_id, data.aws_ami.this[0].image_id)

  create_key_pair = var.ssh_key_pair_name == ""
  key_pair_name   = coalesce(var.ssh_key_pair_name, aws_key_pair.this[0].key_name)
}

data "aws_ami" "this" {
  count = local.get_latest_ami ? 1 : 0

  most_recent = true
  name_regex  = "^amzn2-ami-ecs-hvm-.*-x86_64-ebs"
  owners      = ["amazon"]

  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

resource "aws_key_pair" "this" {
  count = local.create_key_pair ? 1 : 0

  key_name_prefix = "${var.name}-ssh-key-"
  public_key      = var.ssh_pubkey

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_launch_configuration" "this" {
  name_prefix                 = "${var.name}-lc-"
  associate_public_ip_address = var.assign_ec2_public_ip #tfsec:ignore:AWS012
  ebs_optimized               = true
  key_name                    = local.key_pair_name
  iam_instance_profile        = aws_iam_instance_profile.ecs_instance_profile.id
  image_id                    = local.ami_id
  instance_type               = var.instance_type
  security_groups             = [aws_security_group.ecs_ec2_sg.id] #tfsec:ignore:AWS012

  #tfsec:ignore:AWS014
  root_block_device {
    delete_on_termination = true
    volume_size           = var.volume_size
    volume_type           = var.volume_type
  }

  user_data = <<EOF
#!/bin/bash -ex
echo ECS_CLUSTER=${aws_ecs_cluster.this.name} >> /etc/ecs/ecs.config

${var.userdata_script}

set -euo pipefail
# Install
yum install -y aws-cfn-bootstrap
# Can't signal back if the stack is in UPDATE_COMPLETE state, so ignore failures to do so.
# CFN will roll back if it expects the signal but doesn't get it anyway.
/opt/aws/bin/cfn-signal \
  --stack "${var.name}-asg-stack" \
  --resource ASG \
  --region "${local.region}" || true
EOF

  lifecycle {
    create_before_destroy = true
  }
}

########################################
# Security Group, S.G. Rules, and VPC Endpoint
########################################

resource "aws_security_group" "ecs_ec2_sg" {
  name_prefix = "${var.name}-ec2-sg-"
  description = "Security group for ECS ALB"
  vpc_id      = var.vpc_id

  tags = merge(
    var.tags,
    { "Name" = "${var.name}-ec2-sg" },
  )

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_security_group_rule" "ecs_ec2_ingress_from_alb" {
  description              = "SG rule to allow ALB to EC2 traffic"
  from_port                = 0
  protocol                 = "-1"
  security_group_id        = aws_security_group.ecs_ec2_sg.id
  source_security_group_id = aws_security_group.ecs_alb_sg.id
  to_port                  = 0
  type                     = "ingress"
}

resource "aws_security_group_rule" "ecs_ec2_egress_to_alb" {
  description              = "SG rule to allow ALB to EC2 traffic"
  from_port                = 0
  protocol                 = "-1"
  security_group_id        = aws_security_group.ecs_ec2_sg.id
  source_security_group_id = aws_security_group.ecs_alb_sg.id
  to_port                  = 0
  type                     = "egress"
}

resource "aws_vpc_endpoint" "ec2" {
  security_group_ids = [aws_security_group.ecs_ec2_sg.id]
  service_name       = "com.amazonaws.${local.region}.cloudformation"
  subnet_ids         = var.ec2_subnet_ids
  vpc_endpoint_type  = "Interface"
  vpc_id             = var.vpc_id

  tags = merge(
    var.tags,
    { "Description" = "Allows ECS ${var.name} to signal CloudFormation SignalResource API" },
  )
}

resource "aws_security_group_rule" "self_to_ecs_ec2" {
  description       = "Allow ECS EC2 to communicate with self and CFN VPC Endpoint"
  from_port         = 0
  protocol          = "-1"
  security_group_id = aws_security_group.ecs_ec2_sg.id
  self              = true
  to_port           = 0
  type              = "ingress"
}

resource "aws_security_group_rule" "ecs_ec2_to_self" {
  description       = "Allow ECS EC2 to communicate with self and CFN VPC Endpoint"
  from_port         = 0
  protocol          = "-1"
  security_group_id = aws_security_group.ecs_ec2_sg.id
  self              = true
  to_port           = 0
  type              = "egress"
}
