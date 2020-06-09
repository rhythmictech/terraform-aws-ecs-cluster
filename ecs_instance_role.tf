resource "aws_iam_role" "ecs_instance_role" {
  name_prefix        = "${var.name}-ec2-role-"
  path               = "/"
  assume_role_policy = data.aws_iam_policy_document.ecs_instance_policy_document.json

  tags = merge(
    local.base_tags,
    var.tags,
    {
      "Name" = "${var.name}-instance-role"
    },
  )
}

data "aws_iam_policy_document" "ecs_instance_policy_document" {
  statement {
    actions = [
      "sts:AssumeRole",
    ]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

resource "aws_iam_role_policy" "ecs_instance_policy" {
  count       = var.custom_iam_policy ? 1 : 0
  name_prefix = "${var.name}-ec2-role-policy-"
  role        = aws_iam_role.ecs_instance_role.id
  policy      = var.instance_policy_document
}

resource "aws_iam_role_policy_attachment" "ecs_instance_role_attachment" {
  role       = aws_iam_role.ecs_instance_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceforEC2Role"
}

resource "aws_iam_instance_profile" "ecs_instance_profile" {
  name_prefix = "${var.name}-ecs-instance-profile-"
  path        = "/"
  role        = aws_iam_role.ecs_instance_role.id
  # Keeping this here for now "in case". Issue should be fixed but I haven't tested thoroughly.
  # provisioner "local-exec" {
  #   command = "sleep 10" # wait for instance profile to appear due to https://github.com/terraform-providers/terraform-provider-aws/issues/838
  # }
}
