# Creating New Deploy Concourse Pipeline

The most straight forward way of creating a new GOV.UK environment to test your
changes is to create a new `Deploy` Concourse pipeline which will create a new
`test` GOV.UK environment via Terraform workspace.

## Instructions

1. Clone this repo and create your own branch where you will modify the
   [deploy-parameters.yml](../pipelines/deploy-parameters.yml).

   The parameter definitions are:
   `workspace`: terraform workspace where your resources will be created
   `govuk_infrastructure_branch`: name of the branch of this repo you just created

   Push your changes to GitHub after your finished.

1. Set-up your Fly Concourse CLI tool to target the `govuk-tools` team in the
   [Big Concourse](https://cd.gds-reliability.engineering/teams/govuk-tools)

1. Create a new pipeline:

   ```shell
   fly -t <target_name> sp \
       -p <pipeline_name> \
       -c <path_to_deploy_file> \
       -l <path_to_deploy_parameters_file>
   ```

1. Browse to `https://cd.gds-reliability.engineering/teams/govuk-tools/pipelines/<pipeline_name>`
   to status of your new pipeline
