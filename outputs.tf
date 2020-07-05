output "alb_arn" {
  description = "ARN of ALB"
  value       = aws_alb.this.arn
}

output "alb_arn_suffix" {
  description = "ARN suffix of ALB"
  value       = aws_alb.this.arn_suffix
}

output "alb_dns_name" {
  description = "DNS name of ALB"
  value       = aws_alb.this.dns_name
}

output "alb_security_group_id" {
  description = "Resource ID for Security Group applied to ALB"
  value       = aws_security_group.ecs_alb_sg.id
}

output "alb_zone_id" {
  description = "R53 zone ID of ALB"
  value       = aws_alb.this.zone_id
}

output "ec2_security_group_id" {
  description = "Resource ID for Security Group applied to EC2 instances"
  value       = aws_security_group.ecs_ec2_sg.id
}

output "ecs_cluster_id" {
  description = "Resource ID of ECS cluster"
  value       = aws_ecs_cluster.this.id
}

output "ecs_cluster_name" {
  description = "ECS cluster name"
  value       = aws_ecs_cluster.this.name
}

output "cloudformation_asg_template" {
  description = "CloudFormation yaml template body for ASG"
  value = (
    length(aws_cloudformation_stack.ecs_asg) == 0 ?
    null :
    aws_cloudformation_stack.ecs_asg[0].template_body
  )
}
