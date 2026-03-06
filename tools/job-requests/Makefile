IMAGE_REPO ?= k3d-jr.localhost:64864/jobrequest-server
IMAGE_TAG  ?= latest

.PHONY: build-cli build-server docker-build push install-cli deploy test

build-cli:
	go build -o bin/kubectl-job_request ./cmd/kubectl-job_request

build-server:
	go build -o bin/server ./cmd/server

build: build-cli build-server

docker-build:
	docker build -t $(IMAGE_REPO):$(IMAGE_TAG) .

push: docker-build
	docker push $(IMAGE_REPO):$(IMAGE_TAG)

install: docker-build push
	kubectl rollout restart deploy/jobrequest-server -n jobrequest-system

install-cli: build-cli
	cp bin/kubectl-job_request /usr/local/bin/

deploy:
	kubectl apply -f deploy/namespace.yaml
	kubectl apply -f deploy/crd.yaml
	kubectl apply -f deploy/rbac.yaml
	kubectl apply -f deploy/service.yaml
	kubectl apply -f deploy/webhook.yaml
	kubectl apply -f deploy/deployment.yaml
	bash deploy/generate-certs.sh

test:
	go test ./...
