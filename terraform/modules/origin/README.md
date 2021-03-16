# origin

Creates the public traffic entry point to the environment(as opposed to the publishing one).

The traffic flow is as follows:
1. it is intended that public requests enters via:
    (a) Fastly CDN if using default/ecs workspace or
    (b) AWS CloudFront CDN directly for other workspaces (defined in this module)
2. CloudFront is protected via AWS WAF ACL which allows request coming only Fastly and office IPs only
3. CloudFront routes requests with path matching /assets/* to S3 rails asset bucket or
   origin Application Load-balancer which is connected to the frontend for now until router is ready.
