"""
https://docs.aws.amazon.com/opensearch-service/latest/developerguide/managedomains-snapshots.html
This script has been copied from:
https://raw.githubusercontent.com/alphagov/govuk-aws/main/terraform/projects/app-elasticsearch6/register-snapshot-repository.py
and is to be used to register the required S3 buckets as repositories for the Opensearch backup jobs,
in Integration, Staging and Production environments, which are run by EKS as cronjobs.

Instructions for running this script:
$ OPENSEARCH_DOMAIN_NAME="<insert your opensearch domain name (avaialble as an output of the terraform workspace)>"
$ S3_BUCKET_NAME="<insert the snapshot bucket name (avaialble as an output of the terraform workspace)>"
$ OPENSEARCH_IAM_ROLE_ARN="<insert the opensearch IAM role name (avaialble as an output of the terraform workspace)>"
$ eval $(gds aws govuk-[test|integration|staging|production]-admin -e -art 8h)
$ OPENSEARCH_URL=$(aws opensearch describe-domain --domain-name "${OPENSEARCH_DOMAIN_NAME}" | jq -r '.DomainStatus.Endpoints.vpc')
$ kubectl relay host/$OPENSEARCH_URL 4443:443
Open https://localhost:4443/_dashboards in a browser and log in
Map your AWS Role using instructions in Step 1 of https://docs.aws.amazon.com/opensearch-service/latest/developerguide/managedomains-snapshots.html#managedomains-snapshot-registerdirectory
$ virtualenv venv
$ source venv/bin/activate
$ pip install boto3 requests requests-aws4auth
$ python register-snapshot-repository.py [test|integration|staging|production]
"""

import os
import sys
import boto3
import requests
from requests_aws4auth import AWS4Auth

host = os.environ['OPENSEARCH_URL']
bucket = os.environ["S3_BUCKET_NAME"]
role_arn = os.environ["OPENSEARCH_IAM_ROLE_ARN"]
region = 'eu-west-1'
service = 'es'
credentials = boto3.Session().get_credentials()
awsauth = AWS4Auth(credentials.access_key, credentials.secret_key, region, service, session_token=credentials.token)

def register_repository(name, role_arn, delete_first=False, read_only=False):
    print(name)
    print(bucket)

    url = host + '_snapshot/' + name
    print(url)

    if delete_first:
        r = requests.delete(url)
        r.raise_for_status()
        print(r.text)

    payload = {
        "type": "s3",
        "settings": {
            "bucket": bucket, 
            "region": region,
            "role_arn": role_arn,
            "readonly": read_only
        }
    }

    headers = {"Content-Type": "application/json"}

    r = requests.put(url, auth=awsauth, json=payload, headers=headers, verify=False)
    r.raise_for_status()
    print(r.text)

delete_first = 'DELETE_FIRST' in os.environ

if sys.argv[1] == 'test':
    register_repository('govuk-production', role_arn, delete_first=delete_first, read_only=True)
elif sys.argv[1] == 'integration':
    register_repository('govuk-integration', role_arn, delete_first=delete_first)
    register_repository('govuk-production', role_arn, delete_first=delete_first, read_only=True)
elif sys.argv[1] == 'staging':
    register_repository('govuk-staging', role_arn, delete_first=delete_first)
    register_repository('govuk-production', role_arn, delete_first=delete_first, read_only=True)
elif sys.argv[1] == 'production':
    register_repository('govuk-production', role_arn, delete_first=delete_first)
else:
    print('expected one of [test|integration|staging|production]')
