removed {
  from = aws_security_group_rule.postgres_from_eks_workers
  lifecycle {
    destroy = false
  }
}
removed {
  from = aws_security_group_rule.mysql_from_eks_workers
  lifecycle {
    destroy = false
  }
}
