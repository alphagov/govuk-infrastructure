#!/usr/bin/env bash
# This temporary script runs an arbitrary task using an existing task defintion
# in a new container, using ECS RunTask. This script will be replaced by
# features built into the GDS CLI.

set -eu

OPTIND=1 # Reset in case getopts has been used previously in the shell.

cluster="task_runner"
govuk_env="test"

function show_help {
  echo "Usage: cd govuk-infrastructure && gds aws govuk-tools-internal-admin ./tools/run-rake-task -a frontend rake db:migrate"
  exit 64
}

while getopts :a:c:e:h opt; do
    case $opt in
      h) show_help;;
      a)
        application=${OPTARG}
        ;;
      e)
        govuk_env=${OPTARG:-$govuk_env}
        ;;
      :)
        echo "Option -$OPTARG requires an app as the argument. e.g. -a frontend"
        show_help
        ;;
    esac
done

shift $((OPTIND-1))
[ "${1:-}" = "--" ] && shift
command=$@

if [ -z "${application}" ]; then echo "[Error] You must set the application arg" && show_help && exit 1; fi
if [ -z "${command}" ]; then echo "[Error] You must provide a command" && show_help && exit 1; fi

echo "[Warning] This is a temporary tool for use by the replatforming team."

root_dir="${PWD}"

app_dir="$root_dir/terraform/deployments/apps/$application"
env_dir="$root_dir/terraform/deployments/govuk-test"

echo "Fetching task_definition_arn from Terraform statefile in $app_dir"
cd ${app_dir}
terraform init >/dev/null
task_definition_arn=$(terraform output task_definition_arn)

echo "Fetching network_config from Terraform statefile in $env_dir"
cd ${env_dir}
terraform init >/dev/null
private_subnets=$(terraform output -json private_subnets)
security_groups=$(terraform output -json $application'_security_groups')
network_config="awsvpcConfiguration={subnets=$private_subnets,securityGroups=$security_groups,assignPublicIp=DISABLED}"

echo "Starting task:
  cluster: $cluster
  application: $application
  environment: $govuk_env
  task_definition_arn: $task_definition_arn
  network_config: $network_config
  command: $command"

task=$(aws ecs run-task --cluster $cluster \
--task-definition $task_definition_arn --launch-type FARGATE --count 1 \
--network-configuration $network_config \
--started-by $(whoami) \
--overrides '{
  "containerOverrides": [{
    "name": "'"$application"'",
    "command": ["/bin/bash", "-c", "'"$command"'"]
  }]
}')

task_arn=$(echo $task | jq .tasks[0].taskArn)

echo "Waiting for task $task_arn to finish..."
echo "View task: https://eu-west-1.console.aws.amazon.com/ecs/home?region=eu-west-1#/clusters/$cluster/tasks"

aws ecs wait tasks-stopped --tasks=[$task_arn] --cluster $cluster

task_results=$(aws ecs describe-tasks --tasks=[$task_arn] --cluster $cluster)
exit_code=$(echo $task_results | jq [.tasks[0].containers[].exitCode] | jq add)

echo "Task finished. Exit code: $exit_code"

exit $exit_code
