data "aws_ami" "ecs" {
  most_recent = true
  name_regex  = "^amzn2-ami-ecs-hvm-.*-x86_64-ebs"
  owners      = ["amazon"]

  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

resource "aws_security_group" "ecs_ec2_sg" {
  name_prefix = "${var.name}-ec2-sg-"
  description = "Seecurity group for ECS ALB"
  vpc_id      = var.vpc_id

  tags = merge(
    local.base_tags,
    var.tags,
    {
      "Name" = "${var.name}-ec2-sg"
    },
  )

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_key_pair" "default" {
  key_name_prefix = "${var.name}-ssh-key-"
  public_key      = var.ssh_pubkey

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_launch_configuration" "ecs-launch-config" {
  name_prefix          = "${var.name}-lc-"
  image_id             = data.aws_ami.ecs.image_id
  instance_type        = var.instance_type
  ebs_optimized        = true
  iam_instance_profile = aws_iam_instance_profile.ecs-instance-profile.id

  root_block_device {
    volume_type           = var.volume_type
    volume_size           = var.volume_size
    delete_on_termination = true
  }

  lifecycle {
    create_before_destroy = true
  }

  security_groups             = [aws_security_group.ecs_ec2_sg.id]
  associate_public_ip_address = var.ec2_public_ip
  key_name                    = aws_key_pair.default.key_name

  user_data = <<EOF
#!/bin/bash -ex
echo ECS_CLUSTER=${aws_ecs_cluster.ecs-cluster.name} >> /etc/ecs/ecs.config

${var.userdata_script}

set -euo pipefail
# Install 
yum install -y aws-cfn-bootstrap
# Can't signal back if the stack is in UPDATE_COMPLETE state, so ignore failures to do so.
# CFN will roll back if it expects the signal but doesn't get it anyway.
/opt/aws/bin/cfn-signal \
  --stack "${var.name}-asg-stack" \
  --resource ASG \
  --region "${var.region}" || true
EOF

}

