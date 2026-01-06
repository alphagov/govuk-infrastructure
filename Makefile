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