data "template_file" "asg_cfn" {
  template = file("${path.module}/asg.cfn.yml.tpl")

  vars = {
    description     = "Autoscaling group for ECS cluster"
    desiredCapacity = var.desired_instances
    healthCheck     = var.asg_health_check_type
    launchConfig    = aws_launch_configuration.ecs_launch_config.name
    maxSize         = var.max_instances
    maxBatch        = var.asg_max_size
    minInService    = var.max_instances / 2
    minSize         = var.min_instances
    subnets         = join("\",\"", var.ec2_subnet_ids)
  }
}

resource "aws_cloudformation_stack" "ecs_asg" {
  count         = var.max_instances < 1 ? 0 : 1
  name          = "${regex("[a-zA-Z][-a-zA-Z0-9]*", var.name)}-asg-stack"
  template_body = data.template_file.asg_cfn.rendered
}
