# Terraform for GOV.UK Publishing on ECS

## Directory structure

* `deployments`: root modules, from where you can run Terraform commands. These
  should only call the `govuk` composition module and nothing else.
* `modules`: non-root modules
    * `govuk`: composition module for an entire GOV.UK Publishing environment
    * `app`: reusable module for an app; contains the essential resources which all the apps need.
    * `apps`: composition modules for each app; calls the app module plus any
      app-specific resources.
        * `publisher`: module which creates the Publisher app
        * ...
