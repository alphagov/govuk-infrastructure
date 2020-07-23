# Fargate Console

This module provides a way to start a bash session in a running ECS container,
with the required application code, secrets, and environment variables for
developers to perform interactive operational and investigative tasks.

Use cases includes:

* Running a Rails console in an AWS environment
* Running a database console
* Running a web server without having traffic routed to that server.

See proposal 003 in govuk-replatforming-discovery-2020 for further details
of the tooling required to make this a good developer experience.

## How it works

Using a GDS CLI command such as `gds govuk console --env test --app frontend`
people will start a bash session in a running container in ECS.

Behind the scenes this command will start up a container like so:

```shell
aws ecs run-task --cluster task_runner --task-definition frontend_console \
--launch-type FARGATE --count 1 --started-by "Harry Potter" \
--network-configuration '{
  "awsvpcConfiguration": {
    "subnets": ["subnet-6dc4370b", "subnet-463bfd0e", "subnet-bfecd0e4"],
    "securityGroups": ["sg-0b873470482f6232d"],
    "assignPublicIp": "DISABLED"
  }
}'
```

See the proposal [003 ECS Fargate consoles][] for more details.

[003 ECS Fargate consoles]: https://github.com/alphagov/govuk-replatforming-discovery-2020/blob/c1264ac60409ccbbea95d8126c113ea6511789b0/proposals/003-ecs-fargate-consoles.md
