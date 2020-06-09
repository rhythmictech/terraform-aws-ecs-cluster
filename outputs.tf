output "alb_sg_id" {
  value = aws_security_group.ecs-alb-sg.id
}

output "ec2_sg_id" {
  value = aws_security_group.ecs_ec2_sg.id
}

output "cluster_id" {
  value = aws_ecs_cluster.ecs-cluster.id
}

output "alb_arn" {
  value = aws_alb.ecs-load-balancer.arn
}

output "alb_arn_suffix" {
  value = aws_alb.ecs-load-balancer.arn_suffix
}

output "alb_dns" {
  value = aws_alb.ecs-load-balancer.dns_name
}

output "alb_zone" {
  value = aws_alb.ecs-load-balancer.zone_id
}

output "cluster_name" {
  value = aws_ecs_cluster.ecs-cluster.name
}

output "cloudformation_asg_template" {
  value = (
    length(aws_cloudformation_stack.ecs-asg) == 0 ?
    null :
    aws_cloudformation_stack.ecs-asg[0].template_body
  )
}
