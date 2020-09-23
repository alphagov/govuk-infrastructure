# Frontend

Status: `alpha`

The frontend project manages the [frontend application][] service.
The app pulls an image from DockerHub and uses the infra-fargate module
to bring up the necessary resources, including the app itself in Fargate,
the load balancer, and logging for the app.

[frontend application]: http://github.com/alphagov/frontend
