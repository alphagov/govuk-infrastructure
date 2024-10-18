resource "aws_api_gateway_domain_name" "search_api_domain" {
  domain_name     = var.search_api_domain
  certificate_arn = var.publishing_certificate_arn
}

resource "aws_lb" "search_nlb" {
  name               = "search-nlb"
  load_balancer_type = "network"
  internal           = true
  subnets            = data.terraform_remote_state.infra_networking.outputs.private_subnet_ids
}

resource "aws_lb_target_group" "search_api_gateway_tg" {
  name        = "search-api-gateway-tg"
  target_type = "alb"
  port        = "443"
  protocol    = "TCP"
  vpc_id      = data.tfe_outputs.vpc.nonsensitive_values.id
}

resource "aws_lb_listener" "search_nlb_listener" {
  load_balancer_arn = aws_lb.search_nlb.arn
  port              = "443"
  protocol          = "TCP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.search_api_gateway_tg.arn
  }
}

resource "aws_lb_target_group_attachment" "tg_attachment" {
  target_group_arn = aws_lb_target_group.search_api_gateway_tg.arn
  target_id        = var.search_api_lb_arn
  port             = 443
}

# VPC Link to allow API Gateway to connect to the search load balancer
resource "aws_api_gateway_vpc_link" "search_vpc_link" {
  name = "search_api_vpc_link"
  target_arns = [
    aws_lb.search_nlb.arn
  ]
}

resource "aws_api_gateway_rest_api" "search_rest_api" {
  name        = "search_api"
  description = "API Gateway for Search API"

  endpoint_configuration {
    types = ["EDGE"] # "Edge-optimized" routes traffic through CloudFront
  }
}

resource "aws_api_gateway_resource" "search_resource" {
  rest_api_id = aws_api_gateway_rest_api.search_rest_api.id
  parent_id   = aws_api_gateway_rest_api.search_rest_api.root_resource_id
  path_part   = "search.json"
}

resource "aws_api_gateway_method" "get_search_method" {
  rest_api_id   = aws_api_gateway_rest_api.search_rest_api.id
  resource_id   = aws_api_gateway_resource.search_resource.id
  http_method   = "GET"
  authorization = "NONE" # We can add API keys or other auth options should we need them
}

# Connect to the Search-API-v2 load balancer
resource "aws_api_gateway_integration" "search_lb_integration" {
  rest_api_id             = aws_api_gateway_rest_api.search_rest_api.id
  resource_id             = aws_api_gateway_resource.search_resource.id
  http_method             = aws_api_gateway_method.get_search_method.http_method
  integration_http_method = "GET"
  type                    = "HTTP_PROXY"
  connection_type         = "VPC_LINK"
  connection_id           = aws_api_gateway_vpc_link.search_vpc_link.id
  uri                     = var.search_api_lb_dns_name
}

# Create a deployment for the API Gateway
resource "aws_api_gateway_deployment" "search_deployment" {
  rest_api_id = aws_api_gateway_rest_api.search_rest_api.id
}

resource "aws_api_gateway_stage" "search_v0_1" {
  deployment_id = aws_api_gateway_deployment.search_deployment.id
  rest_api_id   = aws_api_gateway_rest_api.search_rest_api.id
  stage_name    = "v0_1" # Version embedded in the published URL
}

# Map API Gateway stages to custom domain
resource "aws_api_gateway_base_path_mapping" "search_api_mapping" {
  domain_name = aws_api_gateway_domain_name.search_api_domain.domain_name
  api_id      = aws_api_gateway_rest_api.search_rest_api.id
}

resource "aws_wafv2_web_acl" "search_api_waf" {
  name        = "search-api-waf"
  description = "WAF for Search API"
  scope       = "REGIONAL"

  default_action {
    allow {}
  }

  rule {
    name     = "rate-limit-rule"
    priority = 1
    action {
      block {}
    }

    statement {
      rate_based_statement {
        limit              = var.search_api_rate_limit
        aggregate_key_type = "IP"
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "search-api-rate-limit-rule"
      sampled_requests_enabled   = true
    }
  }

  visibility_config {
    cloudwatch_metrics_enabled = true
    metric_name                = "search-api-waf"
    sampled_requests_enabled   = true
  }
}

resource "aws_wafv2_web_acl_association" "waf_association" {
  resource_arn = aws_api_gateway_stage.search_v0_1.arn
  web_acl_arn  = aws_wafv2_web_acl.search_api_waf.arn
}

output "api_gateway_cname" {
  value       = aws_api_gateway_domain_name.search_api_domain.cloudfront_domain_name
  description = "CNAME to use in your DNS settings"
}
