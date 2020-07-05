
########################################
# Application Load Balancer
########################################

#tfsec:ignore:AWS005
resource "aws_alb" "this" {
  name_prefix     = "ecs-"
  security_groups = [aws_security_group.ecs_alb_sg.id]
  subnets         = var.alb_subnet_ids

  tags = merge(
    var.tags,
    { "Name" = "${var.name}-alb" },
  )

  lifecycle {
    create_before_destroy = true
  }
}

########################################
# Security Group, S.G. Rules
########################################

resource "aws_security_group" "ecs_alb_sg" {
  description = "Security Group for ECS-ALB ${var.name}"
  name_prefix = "${var.name}-alb-sg-"
  vpc_id      = var.vpc_id

  tags = merge(
    var.tags,
    { "Name" = "${var.name}-alb-sg" },
  )

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_security_group_rule" "alb_ingress_from_ec2" {
  description              = "SG rule to allow ALB ingress from EC2 ECS"
  security_group_id        = aws_security_group.ecs_alb_sg.id
  type                     = "ingress"
  from_port                = 0
  to_port                  = 0
  protocol                 = "-1"
  source_security_group_id = aws_security_group.ecs_ec2_sg.id
}

resource "aws_security_group_rule" "alb_egress_to_ec2" {
  description              = "SG rule to allow ALB egress to EC2 ECS cluster"
  security_group_id        = aws_security_group.ecs_alb_sg.id
  type                     = "egress"
  from_port                = 0
  to_port                  = 0
  protocol                 = "-1"
  source_security_group_id = aws_security_group.ecs_ec2_sg.id
}
