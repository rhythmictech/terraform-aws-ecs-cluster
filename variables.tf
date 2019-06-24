locals {
  base_tags = {
    tf_module = "ecs-cluster"
  }
}

variable "name" {
  description = "common name for resources in this module"
  type        = string
  default     = "ecs-cluster"
}

variable "region" {
  type = string
}

variable "tags" {
  type        = map(string)
  description = "common tags for all resources"
  default     = {}
}

variable "instance_policy_document" {
  description = "Policy document for instance IAM role"
  type        = string

  default = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
      {
        "Effect": "Allow",
        "Action": [],
        "Resource": []
      }
  ]
}
EOF

}

variable "alb_subnet_ids" {
  description = "Subnets ALB will listen on"
  type = list(string)
}

variable "instance_subnet_ids" {
  description = "Subnets instances will be placed in"
  type = list(string)
}

variable "ssh_pubkey" {
  description = "Public key for default ssh key"
  type = string
}

variable "instance_type" {
  description = "Instance type to use in ASG"
  type = string
  default = "t3.micro"
}

variable "volume_type" {
  description = "Volume type to use for instance root"
  type = string
  default = "gp2"
}

variable "volume_size" {
  description = "Size of root volume of ECS instances"
  type = string
  default = 100
}

variable "ec2_public_ip" {
  description = "Whether to assign a public IP to autoscaled instances"
  type = string
  default = true
}

variable "asg_health_check_type" {
  description = "Check instance health with EC2 or ELB checks"
  type = string
  default = "EC2"
}

variable "vpc_id" {
  description = "ID of VPC resources will be created in"
  type = string
}

variable "max_instances" {
  description = "Max instances in ASG"
  type = string
  default = 4
}

variable "min_instances" {
  description = "Min instances in ASG"
  type = string
  default = 2
}

variable "desired_instances" {
  description = "Desired instances in ASG"
  type = string
  default = 2
}

variable "asg_max_size" {
  description = "Maximum batch size for ASG rolling updates"
  type = string
  default = 1
}

variable "userdata_script" {
  description = "Bash commands to be passed to the instance as userdata. Do NOT include a shebang."
  type = string
  default = "echo 'No additional userdata was passed'"
}

