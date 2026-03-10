removed {
  from = helm_release.aws_vpc_cni
  lifecycle {
    destroy = false
  }
}
