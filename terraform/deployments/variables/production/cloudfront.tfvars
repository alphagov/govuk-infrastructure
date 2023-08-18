aws_region                             = "eu-west-1"
cloudfront_enable                      = true
cloudfront_create                      = 1
logging_bucket                         = "govuk-production-aws-logging.s3.amazonaws.com"
assets_certificate_arn                 = "arn:aws:acm:us-east-1:172025368201:certificate/ea27535c-f48a-4755-b6ca-c048c880e02d"
cloudfront_assets_distribution_aliases = ["assets.publishing.service.gov.uk"]
www_certificate_arn                    = "arn:aws:acm:us-east-1:172025368201:certificate/f2932d95-b83e-4627-b080-90aeea3c5b00"
cloudfront_www_distribution_aliases    = ["www.gov.uk"]
www_web_acl_id                         = ""
assets_web_acl_id                      = ""
origin_www_domain                      = "www-origin.eks.production.govuk.digital"
origin_www_id                          = "WWW Origin"
origin_assets_domain                   = "assets-origin.eks.production.govuk.digital"
origin_assets_id                       = "WWW Assets"
origin_notify_domain                   = "d159ztsj6bvr2n.cloudfront.net"
origin_notify_id                       = "notify alerts"

