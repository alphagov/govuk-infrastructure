# CloudFront secondary CDN configuration for GOV.UK

The `cloudfront` module configures the AWS CloudFront content distribution
network (CDN) to serve www.gov.uk and assets.publishing.service.gov.uk, so
that:

- in the unlikely event of a prolonged outage of our primary CDN, we have the
  option to switch over to CloudFront
- more importantly, we have a second source for our CDN service for
  competitiveness and to reduce vendor lock-in
