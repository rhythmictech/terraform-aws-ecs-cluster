resource "aws_ecs_cluster" "ecs_cluster" {
  name = "${var.name}-cluster"

  tags = merge(
    local.base_tags,
    var.tags,
    {
      "Name" = "${var.name}-cluster"
    },
  )
}
