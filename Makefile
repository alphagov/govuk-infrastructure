SHELL=bash

.PHONY: lint_docs
LINT_DOCS ?= "docs/"
WATCH_DOCS ?= "false"

fn_vale = vale --config ".vale.ini" --no-global --glob "*.md" $(1)
lint_docs:
	@vale sync
	@EXIT_CODE=0; \
	$(call fn_vale,${LINT_DOCS}); \
	EXIT_CODE=$$?; \
	if [ "${LINT_DOCS}" == "docs/" ]; then \
  		1>&2 echo ""; \
   		1>&2 echo "TIP: use the LINT_DOCS variable to target just the documents you want to lint"; \
   		1>&2 echo -e "\n\tmake lint_docs LINT_DOCS=./docs/README.md"; \
   	fi; \
	if [ "${WATCH_DOCS}" == true ]; then \
	  	if ! which fswatch >/dev/null; then \
	  		echo "fswatch not found in the path."; \
	  		echo "fswatch is required for watching for file changes"; \
	  		exit 1; \
	  	fi; \
		fswatch -r -e ".*" -i "\\.md$$" -i "\\.txt$$" -i "\\.yml$$" .vale/ ${LINT_DOCS} \
		| xargs -I {} sh -c 'clear && $(call fn_vale,{})'; \
		exit; \
  	else \
  	  	1>&2 echo ""; \
  	  	1>&2 echo "TIP: use WATCH_DOCS=true to re-run the linter whenever the files change"; \
  	  	1>&2 echo -e "\n\tmake lint_docs WATCH_DOCS=true"; \
  	  	1>&2 echo -e "\tmake lint_docs LINT_DOCS=./docs/README.md WATCH_DOCS=true"; \
	fi; \
	exit $${EXIT_CODE};

.PHONY: ephemeral_cluster
ephemeral_cluster:
	@ if [[ -z "$${EPH_CLUSTER_ID}" ]] || [[ ! -v "EPH_CLUSTER_ID" ]]; then \
		echo "Set the ephemeral cluster id with the EPH_CLUSTER_ID variable"; \
		printf "\t make create_ephemeral_cluster EPH_CLUSTER_ID=\"eph-new-cluster\"\n"; \
		exit 1; \
  	fi; \
  	cd terraform/deployments/ephemeral; \
	terraform init; \
	echo "Ephemeral cluster $${EPH_CLUSTER_ID} will be built by Terraform in Terraform Cloud."; \
	echo "When the 'cluster_access' workspace is complete you should be able to access to the cluster"; \
	printf "\t aws eks update-kubeconfig --name $${EPH_CLUSTER_ID}\n"; \
	echo "Once all workspaces are complete, log into the cluster and run './validate.sh' to test the cluster is functioning"; \
	open "https://app.terraform.io/app/govuk/projects"; \
	echo "Press enter to continue"; \
	read; \
	terraform apply -var ephemeral_cluster_id="$${EPH_CLUSTER_ID}"; \