# origin

Creates the entry point to the environment:

The traffic flow is as follows:
1. it is intended that:
    (a) public requests enters via:
        (i) Fastly CDN if using default/ecs workspace or
        (ii) AWS CloudFront CDN directly for other workspaces (defined in this module)
    (b) publishing requests enters via AWS CloudFront CDN directly
2. CloudFront is protected via AWS WAF ACL which allows request coming only Fastly and office IPs only
3. CloudFront routes requests with path matching /assets/* to S3 rails asset bucket or
   origin Application Load-balancer which is connected to the frontend for now until router is ready.
