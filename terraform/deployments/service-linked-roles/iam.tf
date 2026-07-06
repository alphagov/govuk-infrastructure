// This is now managed in ../elasticsearch-green as part of module.opensearch
removed {
  from = aws_iam_role.manual_snapshot_role
  lifecycle {
    destroy = false
  }
}

// This is now managed in ../elasticsearch-green as part of module.opensearch
removed {
  from = aws_iam_policy.manual_snapshot_bucket_policy
  lifecycle {
    destroy = false
  }
}

// This is now managed in ../elasticsearch-green as part of module.opensearch
removed {
  from = aws_iam_role_policy_attachment.manual_snapshot_role_policy
  lifecycle {
    destroy = false
  }
}

// This is now managed in ../elasticsearch-green as part of module.opensearch
removed {
  from = aws_iam_policy.can_configure_es_snapshots
  lifecycle {
    destroy = false
  }
}
