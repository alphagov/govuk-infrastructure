#!/usr/bin/env bash
# This temporary script runs an arbitrary task using an existing task defintion
# in a new container, using ECS RunTask. This script will be replaced by
# features built into the GDS CLI.

set -euf -o pipefail

trap "exit" INT TERM
trap "kill -- -$$" EXIT

OPTIND=1 # Reset in case getopts has been used previously in the shell.

cluster="task_runner"
govuk_env="test"

function show_help {
  echo "Usage: cd govuk-infrastructure && gds aws govuk-test-poweruser ./tools/run-rake-task -a frontend -v live rake db:migrate"
  exit 64
}

while getopts :a:c:e:v:h opt; do
    case $opt in
      h) show_help;;
      a)
        application=${OPTARG}
        ;;
      v)
        variant=${OPTARG:-default}
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

if [ -z "${application}" ]; then echo "[Error] You must set the application arg e.g. publisher" && show_help && exit 1; fi
if [ -z "${variant}" ]; then echo "[Error] You must set the variant arg e.g. web, worker, draft or live" && show_help && exit 1; fi
if [ -z "${command}" ]; then echo "[Error] You must provide a command" && show_help && exit 1; fi

echo "[Warning] This is a temporary tool for use by the replatforming team."

root_dir="${PWD}"

env_dir="$root_dir/terraform/deployments/govuk-publishing-platform"

echo "Fetching network_config from Terraform statefile in $env_dir"
cd ${env_dir}
terraform init >/dev/null
network_config=$(terraform output -json "$application" | jq -r ".$variant.network_config")

echo "Fetching task_definition_arn from the govuk ECS cluster"
cluster_name=$(terraform output -json "cluster_name" | jq -r)
task_definition_arn=$(aws --region eu-west-1 ecs describe-services --cluster "${cluster_name}" --service "${application}-${variant}" | jq -r '.services[0].taskDefinition')

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
--enable-execute-command \
--started-by $(whoami) \
--overrides '{
  "containerOverrides": [{
    "name": "app",
    "command": ["/bin/bash", "-c", "'"$command"'"]
  }]
}')

task_arn=$(echo $task | jq -r .tasks[0].taskArn)
task_id=${task_arn##*/}

echo "Waiting for task $task_arn to finish..."
echo "View task: https://eu-west-1.console.aws.amazon.com/ecs/home?region=eu-west-1#/clusters/$cluster/tasks"
echo "Tailing logs..."
echo ""

(aws --region eu-west-1 logs tail govuk --follow | grep "${application}-${variant}/app/${task_id}")&

aws ecs wait tasks-stopped --tasks="[\"$task_arn\"]" --cluster $cluster

task_results=$(aws ecs describe-tasks --tasks="[\"$task_arn\"]" --cluster $cluster)
exit_code=$(echo $task_results | jq [.tasks[0].containers[].exitCode] | jq add)

echo ""
echo "Task finished. Exit code: $exit_code"

# Sleep for a few seconds to let the logs catch up...
sleep 5

exit $exit_code
