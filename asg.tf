
########################################
# Auto-Scaling Group
# launched via CloudFormation to take advantage of
# cloudformations support for rolling updates
########################################

resource "aws_cloudformation_stack" "ecs_asg" {
  count = var.max_instances < 1 ? 0 : 1

  name = "${regex("[a-zA-Z][-a-zA-Z0-9]*", var.name)}-asg-stack"
  template_body = try(templatefile("${path.module}/asg.cfn.yml.tpl",
    {
      description     = "Autoscaling group for ECS cluster"
      desiredCapacity = var.desired_instances
      healthCheck     = var.asg_health_check_type
      launchConfig    = try(aws_launch_configuration.this[0].name, "")
      maxSize         = var.max_instances
      maxBatch        = var.asg_max_size
      minInService    = var.max_instances / 2
      minSize         = var.min_instances
      subnets         = join("\",\"", var.ec2_subnet_ids)
  }), "")
}
