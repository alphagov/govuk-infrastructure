# TODO: This was created implicitly on the `govuk` engine when it was first created, so
# we're just removing it from state in case explicitly deleting it has weird side effects.
removed {
  from = module.serving_config_default
  lifecycle {
    destroy = false
  }
}
