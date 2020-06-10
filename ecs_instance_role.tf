resource "aws_iam_role" "ecs_instance_role" {
  assume_role_policy = data.aws_iam_policy_document.ecs_instance_policy_document.json
  name_prefix        = "${substr(var.name, 0, 20)}-ec2-role-"
  path               = "/"

  tags = merge(
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
      identifiers = ["ec2.amazonaws.com"]
      type        = "Service"
    }
  }
}

resource "aws_iam_role_policy" "ecs_instance_policy" {
  count       = var.custom_iam_policy ? 1 : 0
  name_prefix = "${var.name}-ec2-role-policy-"
  policy      = var.instance_policy_document
  role        = aws_iam_role.ecs_instance_role.id
}

resource "aws_iam_role_policy_attachment" "ecs_instance_role_attachment" {
  role       = aws_iam_role.ecs_instance_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceforEC2Role"
}

resource "aws_iam_instance_profile" "ecs_instance_profile" {
  name_prefix = "${substr(var.name, 0, 8)}-ecs-instance-profile-"
  path        = "/"
  role        = aws_iam_role.ecs_instance_role.id
}
