#!/usr/bin/env bash
set -euo pipefail

usage() {
  echo "Usage: $0 --env <environment>"
  echo "  --env    Required. Specify the environment to use."
  exit 1
}

env=""

while getopts ":e:-:" opt; do
  case $opt in
    e)
      env="$OPTARG"
      ;;
    -)
      case "${OPTARG}" in
        env)
          env="${!OPTIND}"; OPTIND=$(( OPTIND + 1 ))
          ;;
        env=*)
          env="${OPTARG#*=}"
          ;;
        *)
          echo "Invalid option: --${OPTARG}" >&2
          usage
          ;;
      esac
      ;;
    \?)
      echo "Invalid option: -$OPTARG" >&2
      usage
      ;;
    :)
      echo "Option -$OPTARG requires an argument." >&2
      usage
      ;;
  esac
done

# Check if env parameter was provided
if [ -z "$env" ]; then
  echo "Error: --env parameter is required." >&2
  usage
fi

if [ ! -n "${AWS_SESSION_TOKEN+_}" ]; then
  echo "Error: you do not have AWS session credentials in your environment" >&2
  exit 2
fi

TEXT_BOLD_RED="\x1b[1;31;40m"
TEXT_RESET="\x1b[0m"
cat <<EOF
==> Bootstrapping a GOV.UK environment
About to perform a minimal bootstrapping of a GOV.UK environment. This will
result in an AWS VPC, DNS, and a minimally configured Kubernetes cluster.

The Kubernetes cluster will have a running instance of Concourse, with a
pipeline which will complete the bootstrapping process.

To do all of this you $(echo -e "${TEXT_BOLD_RED}MUST${TEXT_RESET}") be using a using an admin role in AWS. If you are not,
you are unlikely to have sufficient privilege to perform the bootstrapping process
and it will break part way through.

EOF

read -r -p "Continue (y/n)? " continue
case "$(echo "$continue" | tr "[:lower:]" "[:upper:]")" in
  y|Y ) : ;;
  yes|YES ) : ;;
  * ) exit 3 ;;
esac

echo "==> Initialising state bucket"
(cd init-state-bucket; ./init.sh "${env}") 2>&1 | sed -E "s/^/(state-bucket) /"

echo "==> Apply Terraform root: terraform/deployments/vpc/"
(
  cd ../terraform/deployments/vpc
  terraform init
  terraform apply -var-file tfvars/type/test.tfvars -var-file tfvars/named/ah-test.tfvars
) 2>&1 | sed -E "s/^/(vpc) /"

echo "==> Apply Terraform root: terraform/deployments/root-dns/"
(
  cd ../terraform/deployments/root-dns
  terraform init
  terraform apply -var-file tfvars/named/ah-test.tfvars
) 2>&1 | sed -E "s/^/(root-dns) /"

echo "==> Apply Terraform root: terraform/deployments/cluster-infrastructure/"
(
  cd ../terraform/deployments/cluster-infrastructure
  terraform init
  terraform apply -var-file tfvars/type/test.tfvars -var-file tfvars/named/ah-test.tfvars
) 2>&1 | sed -E "s/^/(cluster-infrastructure) /"

echo "==> Apply Terraform root: terraform/deployments/cluster-drivers/"
(
  cd ../terraform/deployments/cluster-drivers
  terraform init
  terraform apply -var-file tfvars/named/ah-test.tfvars
) 2>&1 | sed -E "s/^/(cluster-drivers) /"

echo "==> Apply Terraform root: terraform/deployments/concourse/"
(
  cd ../terraform/deployments/concourse
  terraform init
  terraform apply -var-file tfvars/named/ah-test.tfvars
) 2>&1 | sed -E "s/^/(concourse) /"

echo "==> Apply Terraform root: terraform/deployments/cluster-access/"
(
  cd ../terraform/deployments/cluster-access
  terraform init
  terraform apply -var-file tfvars/type/test.tfvars -var-file tfvars/named/ah-test.tfvars
) 2>&1 | sed -E "s/^/(cluster-access) /"

#echo "==> Downloading Fly binary"
#curl 'http://localhost:8080/api/v1/cli?arch=amd64&platform=darwin' -o fly
#chmod +x ./fly
#FLY="./fly"
#
#echo "==> Logging into Concourse"
#$FLY -t bootstrap login -c http://localhost:8080 -u bootstrap -p govuk
#
#$FLY -t bootstrap set-pipeline -n -p bootstrap -c ../pipelines/bootstrap.yml \
#  -v BOOTSTRAP_AWS_ACCESS_KEY_ID="${AWS_ACCESS_KEY_ID}" \
#  -v BOOTSTRAP_AWS_SECRET_ACCESS_KEY="${AWS_SECRET_ACCESS_KEY}" \
#  -v BOOTSTRAP_AWS_SESSION_TOKEN="${AWS_SESSION_TOKEN}"
#
#$FLY -t bootstrap unpause-pipeline -p bootstrap
#
#open "$($FLY targets | grep bootstrap | awk '{print $2}')/teams/main/pipelines/bootstrap"
#
#echo "==> Credentials"
#echo "==> Username: bootstrap"
#echo "==> Password: govuk"
