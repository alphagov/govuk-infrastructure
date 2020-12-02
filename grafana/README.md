Local grafana
=============

As a first step towards an observability stack, here's some code to spin up a
Grafana locally (using docker), and point it at the AWS datasources.

Getting started
---------------

Run docker-compose, providing AWS session tokens as env vars to allow it to
access AWS CloudWatch:

```
gds aws govuk-test-internal-admin -- docker-compose up
```

This will automatically run terraform using the grafana terraform provider to
initialise the datasources and dashboards configured in the terraform
directory.

Grafana data and terraform state is persisted in docker volumes.

