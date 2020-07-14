# Frontend

Status: `alpha`

The frontend project manages the [frontend application][] service.
The app pulls an image from DockerHub and uses the infra-fargate module
to bring up the necessary resources, including the app itself in Fargate,
the load balancer, and logging for the app.

Additional configuration is defined in the task-definitions/frontend.json file
which includes the environment variables that the app process is given.

[frontend application]: http://github.com/alphagov/frontend
