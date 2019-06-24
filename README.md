# ecs-cluster module

## How to use this module

### Required Variables
* `vpc_id`: ID of vpc to create resources in
* `alb_subnet_ids`: Subnets the ALB will listen on (public subnets)

### Recommended Variables
* `instance_policy_document`: An object created by the `aws_iam_policy_document` datasource
  * purpose: additional IAM permissions to be granted to cluster nodes
  * default: empty document
* `name`: common name for resources created by this module (included in tags)

### Additional Requirements
* Security Group Rules will need to be granted to the ALB and instances using `aws_security_group_rule` resources  
  Example:
  ```terraform
  resource "aws_security_group_rule" "ecs_alb_ingress_80" {
    security_group_id = "${module.ecs-cluster.alb-sg-id}"
    type              = "ingress"
    from_port         = 80
    to_port           = 80
    protocol          = "tcp"
    cidr_blocks       = ["0.0.0.0/0"]
  }

  resource "aws_security_group_rule" "ecs_alb_ingress_443" {
    security_group_id = "${module.ecs-cluster.alb-sg-id}"
    type              = "ingress"
    from_port         = 443
    to_port           = 443
    protocol          = "tcp"
    cidr_blocks       = ["0.0.0.0/0"]
  }

  resource "aws_security_group_rule" "ecs_alb_egress" {
    security_group_id = "${module.ecs-cluster.alb-sg-id}"
    type              = "egress"
    from_port         = 0
    to_port           = 0
    protocol          = "-1"
    cidr_blocks       = ["${var.cidr_block[terraform.workspace]}"]
  }

  resource "aws_security_group_rule" "ecs_ec2_ingress_from_alb" {
    security_group_id        = "${module.ecs-cluster.ec2-sg-id}"
    type                     = "ingress"
    from_port                = 0
    to_port                  = 0
    protocol                 = "-1"
    source_security_group_id = "${module.ecs-cluster.alb-sg-id}"
  }

  resource "aws_security_group_rule" "ecs_ec2_egress" {
    security_group_id = "${module.ecs-cluster.ec2-sg-id}"
    type              = "egress"
    from_port         = 0
    to_port           = 0
    protocol          = "-1"
    cidr_blocks       = ["0.0.0.0/0"]
  }
  ```
