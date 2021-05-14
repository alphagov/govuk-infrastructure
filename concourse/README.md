# Configuring Concourse

Our Concourse pipelines are hosted in Big Concourse located at:
https://cd.gds-reliability.engineering/. You have access to it (and specific
Concourse teams) by being a member of the appropriate GitHub organisation.

To configure Concourse, you need a Concourse CLI client called `fly` that you
can download by clicking on the appropriate platform icon at the bottom right of
the [page](https://cd.gds-reliability.engineering/). You should ideally install
it in directory `/usr/local/bin/`.

Our Concourse is configured so that each GOV.UK environment (e.g.
`test` and `staging`) having its own Concourse team, e.g. `govuk-test` concourse
team for `test` GOV.UK environment.

`fly` uses the concept of `target` to refer to a specific Concourse team. To
register a new target with `fly`, you do:

```shell
fly --target <target_name> \
    login \
    --team-name <concourse_team> \
    --concourse-url https://cd.gds-reliability.engineering
```

where:
1. `<target_name>` is the name that you want to give to the target. By convention,
   we use `govuk-<govuk_environment>`, e.g. `govuk_test` for `test` GOV.UK
   environment
1. `concourse_team` is the name of an existing Concourse team, which usually
   follows the same format as `target_name` 

## Deploying Pipelines

Pipelines are deployed in Concourse teams with each GOV.UK environment (e.g.
`test` and `staging`) having their own team with default variables/secrets
(see `gds cd secrets ls`).

### Pipeline Deployment

To deploy a [pipeline](./pipelines), you need to run the following commands:

```shell
cd govuk-infrastructure

fly sp -t <concourse_target> \
       -p <pipeline_name>
       -c concourse/pipelines/<pipeline_filename> \
       -l concourse/parameters/<govuk_environment>/parameters.yml
```

where:
1. `<concourse_target>` is the Concourse target that points to the relevant
   Concourse team for the GOV.UK environment that we want to deploy to
1. `<pipeline_name>` is the name of the pipeline in Concourse
2. `<pipeline_filename>` is the filename which contains the pipeline configuration
3. `<govuk_environment>` is the GOV.UK environment that we want to deploy to
