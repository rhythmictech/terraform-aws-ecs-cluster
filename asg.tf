data "template_file" "asg_cfn" {
  template = file("${path.module}/asg.cfn.yml.tpl")

  vars = {
    description     = "Autoscaling group for ECS cluster"
    subnets         = join("\",\"", var.alb_subnet_ids)
    launchConfig    = aws_launch_configuration.ecs_launch_config.name
    minSize         = var.min_instances
    maxSize         = var.max_instances
    desiredCapacity = var.desired_instances
    healthCheck     = var.asg_health_check_type
    maxBatch        = var.asg_max_size
    minInService    = var.max_instances / 2
  }
}

resource "aws_cloudformation_stack" "ecs_asg" {
  count         = var.max_instances < 1 ? 0 : 1
  name          = "${var.name}-asg-stack"
  template_body = data.template_file.asg_cfn.rendered
}
