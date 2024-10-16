# VPC Link to allow API Gateway to connect to the search load balancer
resource "aws_api_gateway_vpc_link" "search_vpc_link" {
  name = "search_api_vpc_link"
  target_arns = [
    var.search_api_lb_arn
  ]
}

resource "aws_api_gateway_rest_api" "search_rest_api" {
  name        = "search_api"
  description = "API Gateway for Search API"

  endpoint_configuration {
    types = ["EDGE"]  # "Edge-optimized" routes traffic through CloudFront
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
  stage_name  = "v0.1" # Version embedded in the published URL
}

output "api_gateway_cname" {
  value       = aws_api_gateway_domain_name.search_api_domain.cloudfront_domain_name
  description = "CNAME to use in your DNS settings"
}
