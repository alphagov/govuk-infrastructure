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
  # CKAN rate limits - more relaxed than FIND to accommodate API usage
  # Production and Staging: 800 warning / 1000 block over 5 minutes
  # Integration and Test: 400 warning / 500 block over 5 minutes
  ckan_rate_limits = var.govuk_environment == "production" || var.govuk_environment == "staging" ? {
    warning = 800
    block   = 1000
    } : {
    warning = 400
    block   = 500
  }
  # CKAN non API rate limits
  # All envs: 100 challenge over 5 minutes
  ckan_non_api_rate_limit = {
    challenge = 100
  }
  # CKAN high latency rate limits
  # All envs: 10 challenge over 5 minutes
  ckan_high_latency_rate_limit = {
    challenge = 10
  }
}

