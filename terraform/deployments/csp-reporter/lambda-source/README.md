# CspReportsToFirehose

This lambda is to receive Content Security Policy reports using the [report-uri](https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers/Content-Security-Policy/report-uri) directive. It will write valid ones to Kinesis Firehose for storing.

It is not configured for the CSP [report-to](https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers/Content-Security-Policy/report-to) usage where a different JSON structure is used, at the time of writing report-to is not available in all browsers. It is also caught up in the browser [Reporting API](https://www.w3.org/TR/reporting-1/) which is currently a draft standard.

This was built targeting nodejs 22 and needs and an env var of FIREHOSE_DELIVERY_STREAM to specify the Kinesis

You can test this lambda in the AWS console by setting up a test event based on `apigateway-aws-proxy` with a customised body and Content-Type, you may want to comment out the Kinesis Firehose aspect for easier testing.
