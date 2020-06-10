data "aws_ami" "ecs" {
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

resource "aws_key_pair" "default" {
  key_name_prefix = "${var.name}-ssh-key-"
  public_key      = var.ssh_pubkey

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_launch_configuration" "ecs_launch_config" {
  associate_public_ip_address = var.assign_ec2_public_ip #tfsec:ignore:AWS012
  ebs_optimized               = true
  key_name                    = aws_key_pair.default.key_name
  iam_instance_profile        = aws_iam_instance_profile.ecs_instance_profile.id
  image_id                    = data.aws_ami.ecs.image_id
  instance_type               = var.instance_type
  name_prefix                 = "${var.name}-lc-"
  security_groups             = [aws_security_group.ecs_ec2_sg.id] #tfsec:ignore:AWS012

  #tfsec:ignore:AWS014
  root_block_device {
    delete_on_termination = true
    volume_size           = var.volume_size
    volume_type           = var.volume_type
  }

  user_data = <<EOF
#!/bin/bash -ex
echo ECS_CLUSTER=${aws_ecs_cluster.ecs_cluster.name} >> /etc/ecs/ecs.config

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

resource "aws_security_group" "ecs_ec2_sg" {
  description = "Security group for ECS ALB"
  name_prefix = "${var.name}-ec2-sg-"
  vpc_id      = var.vpc_id

  tags = merge(
    var.tags,
    {
      "Name" = "${var.name}-ec2-sg"
    },
  )

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_security_group_rule" "ecs_ec2_ingress_from_alb" {
  description              = "SG rule to allow ALB to EC2 traffic"
  security_group_id        = aws_security_group.ecs_ec2_sg.id
  type                     = "ingress"
  from_port                = 0
  to_port                  = 0
  protocol                 = "-1"
  source_security_group_id = aws_security_group.ecs_alb_sg.id
}

resource "aws_security_group_rule" "ecs_ec2_egress_to_alb" {
  description              = "SG rule to allow ALB to EC2 traffic"
  security_group_id        = aws_security_group.ecs_ec2_sg.id
  type                     = "egress"
  from_port                = 0
  to_port                  = 0
  protocol                 = "-1"
  source_security_group_id = aws_security_group.ecs_alb_sg.id
}

resource "aws_vpc_endpoint" "ec2" {
  security_group_ids = [aws_security_group.ecs_ec2_sg.id]
  service_name       = "com.amazonaws.${local.region}.cloudformation"
  subnet_ids         = var.ec2_subnet_ids
  vpc_endpoint_type  = "Interface"
  vpc_id             = var.vpc_id

  tags = merge(
    var.tags,
    {
      "Description" = "Allows ECS ${var.name} to signal CloudFormation SignalResource API"
    },
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
