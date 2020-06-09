output "alb-sg-id" {
  value = aws_security_group.ecs-alb-sg.id
}

output "ec2-sg-id" {
  value = aws_security_group.ecs_ec2_sg.id
}

output "cluster-id" {
  value = aws_ecs_cluster.ecs-cluster.id
}

output "alb-arn" {
  value = aws_alb.ecs-load-balancer.arn
}

output "alb-arn-suffix" {
  value = aws_alb.ecs-load-balancer.arn_suffix
}

output "alb-dns" {
  value = aws_alb.ecs-load-balancer.dns_name
}

output "alb-zone" {
  value = aws_alb.ecs-load-balancer.zone_id
}

output "cluster-name" {
  value = aws_ecs_cluster.ecs-cluster.name
}

output "cloudformation_asg_template" {
  value = (
    length(aws_cloudformation_stack.ecs-asg) == 0 ?
    null :
    aws_cloudformation_stack.ecs-asg[0].template_body
  )
}
