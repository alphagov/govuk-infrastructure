## Chat OpenServer Snapshots - `register-snapshot-repository.py`
This document details how the S3 buckets created for the backup process should be registered in each environment. Detailed instructions on how to create index snapshots in Amazon OpenSearch Service can be found [here]. Full instructions on how to access the Amazon OpenSearch Dashboard can be found on this [page].

Registering the S3 buckets as snapshot repositories is a manual one-off process to be carried out in each environment (Integration, Staging and Production). The first step is to log in to the OpenSearch Dashboard and map the AWS IAM Role of the user who will register the repositories. This is followed by running the `register-snapshot-repository.py` script. The backup jobs are run as cronjobs on the EKS cluster. The Production snapshot is created first, which gets imported by Staging and then Integration.

### Commands to run to map the IAM Role in the OpenSearch Dashboard:

```
eval $(gds aws govuk-[integration|staging|production]-admin -e -art 8h)

OPENSEARCH_URL=$(aws opensearch describe-domain --domain-name chat-engine | jq -r '.DomainStatus.Endpoints.vpc')

kubectl relay host/$OPENSEARCH_URL 4443:443
```

Open https://localhost:4443/_dashboards in a browser and log in. Map your AWS Role using instructions in Step 1 of https://docs.aws.amazon.com/opensearch-service/latest/developerguide/managedomains-snapshots.html#managedomains-snapshot-registerdirectory.

### Commands to run to register the S3 buckets (with the relay host from above still running):

```
virtualenv venv

source venv/bin/activate

pip install boto3 requests requests-aws4auth

python register-snapshot-repository.py [integration|staging|production]
```

[here]: https://docs.aws.amazon.com/opensearch-service/latest/developerguide/managedomains-snapshots.html
[page]: https://docs.publishing.service.gov.uk/manual/manage-opensearch-on-aws.html
