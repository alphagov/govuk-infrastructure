# job-requests

A prototype CLI-based app for requesting and approving K8s job execution requests

## Prerequisites

- Docker daemon
- k3d

## Usage

1. Create a container registry: `k3d registry create jr.localhost --port 64864`
2. Create a cluster: `k3d cluster create jr --registry-use krd-jr.localhost:64864`
3. Build and push image: `make push`
4. Install K8s resources: `make deploy`
5. Build CLI: `make build-cli`
6. Create a JobRequest: `./bin/kubectl-job_request create bash:latest "echo hello world"`
