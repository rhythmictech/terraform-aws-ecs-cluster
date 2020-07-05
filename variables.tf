variable "alb_subnet_ids" {
  description = "Subnets ALB will listen on"
  type        = list(string)
}

variable "ami_id" {
  default     = ""
  description = "ECS AMI ID, defaults to latest Amazon-provided image (`name_regex = ^amzn2-ami-ecs-hvm-.*-x86_64-ebs`)"
  type        = string
}

variable "asg_health_check_type" {
  default     = "EC2"
  description = "Check instance health with EC2 or ELB checks"
  type        = string
}

variable "asg_max_size" {
  description = "Maximum batch size for ASG rolling updates"
  type        = string
}

variable "custom_iam_policy" {
  default     = false
  description = "Whether you're passing a custom policy document"
  type        = bool
}

variable "desired_instances" {
  default     = 2
  description = "Desired instances in ASG"
  type        = number
}

variable "assign_ec2_public_ip" {
  default     = true
  description = "Whether to assign a public IP to autoscaled instances"
  type        = bool
}

variable "ec2_subnet_ids" {
  description = "Subnets EC2 will listen on"
  type        = list(string)
}

variable "instance_policy_document" {
  default     = null
  description = "Policy document for instance IAM role"
  type        = string
}

variable "instance_type" {
  default     = "t3.micro"
  description = "Instance type to use in ASG"
  type        = string
}

variable "max_instances" {
  default     = 4
  description = "Max instances in ASG"
  type        = number
}

variable "min_instances" {
  default     = 2
  description = "Min instances in ASG"
  type        = number
}

variable "name" {
  default     = "ecs_cluster"
  description = "common name for resources in this module"
  type        = string
}

variable "ssh_pubkey" {
  default     = ""
  description = "Public key for default ssh key. One of `ssh_pubkey` or `ssh_key_pair_name` is required"
  type        = string
}

variable "ssh_key_pair_name" {
  default     = ""
  description = "Name of pre-existing key-pair for use with the EC2 launch config. One of `ssh_pubkey` or `ssh_key_pair_name` is required"
  type        = string
}

variable "tags" {
  default     = {}
  description = "common tags for all resources"
  type        = map(string)
}

variable "userdata_script" {
  default     = "echo 'No additional userdata was passed'"
  description = "Bash commands to be passed to the instance as userdata. Do NOT include a shebang."
  type        = string
}

variable "vpc_id" {
  description = "ID of VPC resources will be created in"
  type        = string
}

variable "volume_size" {
  default     = 100
  description = "Size of root volume of ECS instances"
  type        = number
}

variable "volume_type" {
  default     = "gp2"
  description = "Volume type to use for instance root"
  type        = string
}

data "aws_region" "current" {}

locals {
  region = data.aws_region.current.name
}
