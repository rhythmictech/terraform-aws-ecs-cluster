#tfsec:ignore:AWS005
resource "aws_alb" "ecs_load_balancer" {
  name_prefix     = "ecs-"
  security_groups = [aws_security_group.ecs_alb_sg.id]
  subnets         = var.alb_subnet_ids

  tags = merge(
    var.tags,
    {
      "Name" = "${var.name}-alb"
    },
  )

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_security_group" "ecs_alb_sg" {
  description = "Security Group for ECS-ALB ${var.name}"
  name_prefix = "${var.name}-alb-sg-"
  vpc_id      = var.vpc_id

  tags = merge(
    var.tags,
    {
      "Name" = "${var.name}-alb-sg"
    },
  )

  lifecycle {
    create_before_destroy = true
  }
}
