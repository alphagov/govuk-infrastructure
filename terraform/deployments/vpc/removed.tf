removed {
  from = aws_route53_zone.internal_zone

  lifecycle {
    destroy = false
  }
}

removed {
  from = aws_route53_zone.external_zone

  lifecycle {
    destroy = false
  }
}
