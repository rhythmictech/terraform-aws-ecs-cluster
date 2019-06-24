resource "aws_security_group" "ecs-alb-sg" {
  name_prefix = "${var.name}-alb-sg-"
  vpc_id      = var.vpc_id

  tags = merge(
    local.base_tags,
    var.tags,
    {
      "Name" = "${var.name}-alb-sg"
    },
  )

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_alb" "ecs-load-balancer" {
  name_prefix     = "ecs-"
  security_groups = [aws_security_group.ecs-alb-sg.id]
  subnets         = var.alb_subnet_ids

  tags = merge(
    local.base_tags,
    var.tags,
    {
      "Name" = "${var.name}-alb"
    },
  )

  lifecycle {
    create_before_destroy = true
  }
}

