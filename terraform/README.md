# Terraform for GOV.UK Publishing on ECS

## Docs

* [Applying Terraform](docs/applying-terraform.md)
* [Adding an app](docs/adding-an-app.md)

## Applying Terraform

See [Applying Terraform](docs/applying-terraform.md).

## Directory structure

* `deployments`: root modules, from where you can run Terraform commands.
    * `govuk-publishing-platform`: creates all resources needed to bring up the
      infrastructure (apart from updating ECS Service task definitions)
    * `apps`: called by the Concourse CD pipeline to create new task definition
      revisions during a deploy.
        * `test`
          * `publisher`: deployment module for creating a new task definition
            revision for the Publisher app in the `test` environment. Requires
            an `image_tag` variable.
          * ...
* `modules`: non-root modules
    * `app`: reusable module for an app; contains the essential resources which all the apps need.
    * `task-definition`: reusable module for creating a task definition
    * `task-definitions`: task definitions for each app
        * `publisher`: module which creates a task definition for the Publisher app
