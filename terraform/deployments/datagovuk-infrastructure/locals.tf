locals {
  # Environment-specific rate Limits
  # Production and Staging: 400 warning / 500 block over 5 minutes
  # Integration and Test: 80 warning / 100 block over 5 minutes
  waf_rate_limits = var.govuk_environment == "production" || var.govuk_environment == "staging" ? {
    warning = 400
    block   = 500
    } : {
    warning = 80
    block   = 100
  }
}
