module "www_origin" {
  source = "../../modules/origin"

  vpc_id                               = local.vpc_id
  aws_region                           = data.aws_region.current.name
  assume_role_arn                      = var.assume_role_arn
  public_subnets                       = local.public_subnets
  public_zone_id                       = aws_route53_zone.workspace_public.zone_id
  external_app_domain                  = aws_route53_zone.workspace_public.name
  certificate                          = aws_acm_certificate.workspace_public.arn
  publishing_service_domain            = var.publishing_service_domain
  workspace_suffix                     = terraform.workspace == "default" ? "govuk" : terraform.workspace
  external_cidrs_list                  = concat(var.office_cidrs_list, data.fastly_ip_ranges.fastly.cidr_blocks)
  rails_assets_s3_regional_domain_name = aws_s3_bucket.rails_assets.bucket_regional_domain_name

  apps_security_config_list = {
    "frontend" = { security_group_id = module.frontend.security_group_id, target_port = 80 },
  }
}

module "draft_origin" {
  source = "../../modules/origin"

  vpc_id                               = local.vpc_id
  aws_region                           = data.aws_region.current.name
  assume_role_arn                      = var.assume_role_arn
  public_subnets                       = local.public_subnets
  public_zone_id                       = aws_route53_zone.workspace_public.zone_id
  external_app_domain                  = aws_route53_zone.workspace_public.name
  certificate                          = aws_acm_certificate.workspace_public.arn
  publishing_service_domain            = var.publishing_service_domain
  workspace_suffix                     = terraform.workspace == "default" ? "govuk" : terraform.workspace
  external_cidrs_list                  = concat(var.office_cidrs_list, data.fastly_ip_ranges.fastly.cidr_blocks)
  rails_assets_s3_regional_domain_name = aws_s3_bucket.rails_assets.bucket_regional_domain_name
  live                                 = false

  apps_security_config_list = {
    "draft-frontend" = { security_group_id = module.draft_frontend.security_group_id, target_port = 80 },
  }
}

data "http" "aws_cloudfront_ip_ranges" {
  url = "https://ip-ranges.amazonaws.com/ip-ranges.json"
}

resource "local_file" "aws_ip_ranges" {
    content     = data.http.aws_cloudfront_ip_ranges.body
    filename = "/tmp/aws-ip-ranges.json"
}

data "aws_lambda_invocation" "trigger_cloudfront_security_groups_updater" {
  function_name = module.www_origin.cloudfront_security_groups_updater_lambda_name

  input = <<JSON
{
    "Records": [
        {
            "EventVersion": "1.0",
            "EventSubscriptionArn": "arn:aws:sns:EXAMPLE",
            "EventSource": "aws:sns",
            "Sns": {
                "SignatureVersion": "1",
                "Timestamp": "1970-01-01T00:00:00.000Z",
                "Signature": "EXAMPLE",
                "SigningCertUrl": "EXAMPLE",
                "MessageId": "95df01b4-ee98-5cb9-9903-4c221d41eb5e",
                "Message": "{\"create-time\": \"yyyy-mm-ddThh:mm:ss+00:00\", \"synctoken\": \"0123456789\", \"md5\": \"${md5(data.http.aws_cloudfront_ip_ranges.body)}\", \"url\": \"https://ip-ranges.amazonaws.com/ip-ranges.json\"}",
                "Type": "Notification",
                "UnsubscribeUrl": "EXAMPLE",
                "TopicArn": "arn:aws:sns:EXAMPLE",
                "Subject": "TestInvoke"
            }
  		}
    ]
}
JSON
   depends_on = [module.www_origin]
}

output "result_entry" {
  value = jsondecode(data.aws_lambda_invocation.trigger_cloudfront_security_groups_updater.result)
}

output "ip_range_sync_token" {
  value = jsondecode(data.http.aws_cloudfront_ip_ranges.body).syncToken
}
