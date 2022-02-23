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
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 0.12.19 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 2.40 |
| <a name="requirement_template"></a> [template](#requirement\_template) | ~> 2.1 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 2.40 |
| <a name="provider_template"></a> [template](#provider\_template) | ~> 2.1 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_alb.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/alb) | resource |
| [aws_cloudformation_stack.ecs_asg](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudformation_stack) | resource |
| [aws_ecs_cluster.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecs_cluster) | resource |
| [aws_iam_instance_profile.ecs_instance_profile](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_instance_profile) | resource |
| [aws_iam_role.ecs_instance_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy.ecs_instance_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy) | resource |
| [aws_iam_role_policy_attachment.ecs_instance_role_attachment](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_launch_configuration.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/launch_configuration) | resource |
| [aws_security_group.ecs_alb_sg](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |
| [aws_security_group.ecs_ec2_sg](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |
| [aws_security_group_rule.alb_egress_to_ec2](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule) | resource |
| [aws_security_group_rule.alb_ingress_from_ec2](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule) | resource |
| [aws_security_group_rule.ecs_ec2_egress_to_alb](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule) | resource |
| [aws_security_group_rule.ecs_ec2_ingress_from_alb](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule) | resource |
| [aws_security_group_rule.ecs_ec2_to_self](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule) | resource |
| [aws_security_group_rule.self_to_ecs_ec2](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule) | resource |
| [aws_vpc_endpoint.ec2](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_endpoint) | resource |
| [aws_ami.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ami) | data source |
| [aws_iam_policy_document.ecs_instance_policy_document](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_region.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/region) | data source |
| [template_file.asg_cfn](https://registry.terraform.io/providers/hashicorp/template/latest/docs/data-sources/file) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_alb_subnet_ids"></a> [alb\_subnet\_ids](#input\_alb\_subnet\_ids) | Subnets ALB will listen on | `list(string)` | n/a | yes |
| <a name="input_ami_id"></a> [ami\_id](#input\_ami\_id) | ECS AMI ID, defaults to latest Amazon-provided image (`name_regex = ^amzn2-ami-ecs-hvm-.*-x86_64-ebs`) | `string` | `""` | no |
| <a name="input_asg_health_check_type"></a> [asg\_health\_check\_type](#input\_asg\_health\_check\_type) | Check instance health with EC2 or ELB checks | `string` | `"EC2"` | no |
| <a name="input_asg_max_size"></a> [asg\_max\_size](#input\_asg\_max\_size) | Maximum batch size for ASG rolling updates. Setting this to 0 will prevent ASG creation | `string` | n/a | yes |
| <a name="input_assign_ec2_public_ip"></a> [assign\_ec2\_public\_ip](#input\_assign\_ec2\_public\_ip) | Whether to assign a public IP to autoscaled instances | `bool` | `true` | no |
| <a name="input_custom_iam_policy"></a> [custom\_iam\_policy](#input\_custom\_iam\_policy) | Whether you're passing a custom policy document | `bool` | `false` | no |
| <a name="input_desired_instances"></a> [desired\_instances](#input\_desired\_instances) | Desired instances in ASG | `number` | `2` | no |
| <a name="input_ec2_subnet_ids"></a> [ec2\_subnet\_ids](#input\_ec2\_subnet\_ids) | Subnets EC2 will listen on | `list(string)` | n/a | yes |
| <a name="input_instance_policy_document"></a> [instance\_policy\_document](#input\_instance\_policy\_document) | Policy document for instance IAM role | `string` | `null` | no |
| <a name="input_instance_type"></a> [instance\_type](#input\_instance\_type) | Instance type to use in ASG | `string` | `"t3.micro"` | no |
| <a name="input_max_instances"></a> [max\_instances](#input\_max\_instances) | Max instances in ASG | `number` | `4` | no |
| <a name="input_min_instances"></a> [min\_instances](#input\_min\_instances) | Min instances in ASG | `number` | `2` | no |
| <a name="input_name"></a> [name](#input\_name) | common name for resources in this module | `string` | `"ecs_cluster"` | no |
| <a name="input_ssh_key_pair_name"></a> [ssh\_key\_pair\_name](#input\_ssh\_key\_pair\_name) | Name of pre-existing key-pair for use with the EC2 launch config. | `string` | `""` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | common tags for all resources | `map(string)` | `{}` | no |
| <a name="input_userdata_script"></a> [userdata\_script](#input\_userdata\_script) | Bash commands to be passed to the instance as userdata. Do NOT include a shebang. | `string` | `"echo 'No additional userdata was passed'"` | no |
| <a name="input_volume_size"></a> [volume\_size](#input\_volume\_size) | Size of root volume of ECS instances | `number` | `100` | no |
| <a name="input_volume_type"></a> [volume\_type](#input\_volume\_type) | Volume type to use for instance root | `string` | `"gp2"` | no |
| <a name="input_vpc_id"></a> [vpc\_id](#input\_vpc\_id) | ID of VPC resources will be created in | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_alb_arn"></a> [alb\_arn](#output\_alb\_arn) | ARN of ALB |
| <a name="output_alb_arn_suffix"></a> [alb\_arn\_suffix](#output\_alb\_arn\_suffix) | ARN suffix of ALB |
| <a name="output_alb_dns_name"></a> [alb\_dns\_name](#output\_alb\_dns\_name) | DNS name of ALB |
| <a name="output_alb_security_group_id"></a> [alb\_security\_group\_id](#output\_alb\_security\_group\_id) | Resource ID for Security Group applied to ALB |
| <a name="output_alb_zone_id"></a> [alb\_zone\_id](#output\_alb\_zone\_id) | R53 zone ID of ALB |
| <a name="output_cloudformation_asg_template"></a> [cloudformation\_asg\_template](#output\_cloudformation\_asg\_template) | CloudFormation yaml template body for ASG |
| <a name="output_ec2_security_group_id"></a> [ec2\_security\_group\_id](#output\_ec2\_security\_group\_id) | Resource ID for Security Group applied to EC2 instances |
| <a name="output_ecs_cluster_id"></a> [ecs\_cluster\_id](#output\_ecs\_cluster\_id) | Resource ID of ECS cluster |
| <a name="output_ecs_cluster_name"></a> [ecs\_cluster\_name](#output\_ecs\_cluster\_name) | ECS cluster name |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
