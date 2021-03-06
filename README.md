# terraform-aws-ecs-cluster
[![pre-commit-check](https://github.com/rhythmictech/terraform-aws-ecs-cluster/workflows/pre-commit-check/badge.svg)](https://github.com/rhythmictech/terraform-aws-ecs-cluster/actions)
[![GitHub release (latest by date)](https://img.shields.io/github/v/release/rhythmictech/terraform-aws-ecs-cluster)](https://github.com/rhythmictech/terraform-aws-ecs-cluster/releases)
<img src="https://img.shields.io/twitter/follow/RhythmicTech?style=social&logo=twitter" alt="follow on Twitter"></a>

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
    security_group_id = module.ecs_cluster.alb-sg-id
    type              = "ingress"
    from_port         = 80
    to_port           = 80
    protocol          = "tcp"
    cidr_blocks       = ["0.0.0.0/0"]
  }

  resource "aws_security_group_rule" "ecs_alb_ingress_443" {
    security_group_id = module.ecs_cluster.alb-sg-id
    type              = "ingress"
    from_port         = 443
    to_port           = 443
    protocol          = "tcp"
    cidr_blocks       = ["0.0.0.0/0"]
  }

  resource "aws_security_group_rule" "ecs_alb_egress" {
    security_group_id = module.ecs_cluster.alb-sg-id
    type              = "egress"
    from_port         = 0
    to_port           = 0
    protocol          = "-1"
    cidr_blocks       = ["${var.cidr_block[terraform.workspace]}"]
  }

  resource "aws_security_group_rule" "ecs_ec2_ingress_from_alb" {
    security_group_id        = module.ecs_cluster.ec2-sg-id
    type                     = "ingress"
    from_port                = 0
    to_port                  = 0
    protocol                 = "-1"
    source_security_group_id = module.ecs_cluster.alb-sg-id
  }

  resource "aws_security_group_rule" "ecs_ec2_egress" {
    security_group_id = module.ecs_cluster.ec2-sg-id
    type              = "egress"
    from_port         = 0
    to_port           = 0
    protocol          = "-1"
    cidr_blocks       = ["0.0.0.0/0"]
  }
  ```

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| terraform | >= 0.12.19 |
| aws | ~> 2.40 |
| template | ~> 2.1 |

## Providers

| Name | Version |
|------|---------|
| aws | ~> 2.40 |
| template | ~> 2.1 |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| alb\_subnet\_ids | Subnets ALB will listen on | `list(string)` | n/a | yes |
| asg\_max\_size | Maximum batch size for ASG rolling updates | `string` | n/a | yes |
| ec2\_subnet\_ids | Subnets EC2 will listen on | `list(string)` | n/a | yes |
| vpc\_id | ID of VPC resources will be created in | `string` | n/a | yes |
| ami\_id | ECS AMI ID, defaults to latest Amazon-provided image (`name_regex = ^amzn2-ami-ecs-hvm-.*-x86_64-ebs`) | `string` | `""` | no |
| asg\_health\_check\_type | Check instance health with EC2 or ELB checks | `string` | `"EC2"` | no |
| assign\_ec2\_public\_ip | Whether to assign a public IP to autoscaled instances | `bool` | `true` | no |
| custom\_iam\_policy | Whether you're passing a custom policy document | `bool` | `false` | no |
| desired\_instances | Desired instances in ASG | `number` | `2` | no |
| instance\_policy\_document | Policy document for instance IAM role | `string` | `null` | no |
| instance\_type | Instance type to use in ASG | `string` | `"t3.micro"` | no |
| max\_instances | Max instances in ASG | `number` | `4` | no |
| min\_instances | Min instances in ASG | `number` | `2` | no |
| name | common name for resources in this module | `string` | `"ecs_cluster"` | no |
| ssh\_key\_pair\_name | Name of pre-existing key-pair for use with the EC2 launch config. | `string` | `""` | no |
| tags | common tags for all resources | `map(string)` | `{}` | no |
| userdata\_script | Bash commands to be passed to the instance as userdata. Do NOT include a shebang. | `string` | `"echo 'No additional userdata was passed'"` | no |
| volume\_size | Size of root volume of ECS instances | `number` | `100` | no |
| volume\_type | Volume type to use for instance root | `string` | `"gp2"` | no |

## Outputs

| Name | Description |
|------|-------------|
| alb\_arn | ARN of ALB |
| alb\_arn\_suffix | ARN suffix of ALB |
| alb\_dns\_name | DNS name of ALB |
| alb\_security\_group\_id | Resource ID for Security Group applied to ALB |
| alb\_zone\_id | R53 zone ID of ALB |
| cloudformation\_asg\_template | CloudFormation yaml template body for ASG |
| ec2\_security\_group\_id | Resource ID for Security Group applied to EC2 instances |
| ecs\_cluster\_id | Resource ID of ECS cluster |
| ecs\_cluster\_name | ECS cluster name |

<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
