resource "aws_ecs_cluster" "this" {
  name = "${var.name}-cluster"

  tags = merge(
    var.tags,
    { "Name" = "${var.name}-cluster" },
  )
}
