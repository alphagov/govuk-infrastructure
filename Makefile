.PHONY: lint_docs
LINT_DOCS ?= docs/
lint_docs:
	@vale sync
	@vale \
		--config ".vale.ini" \
		--glob='**/*.md' \
		--no-global \
		--no-exit \
		${LINT_DOCS}
	@if [ ${LINT_DOCS} == "docs/" ]; then \
  		1>&2 echo ""; \
   		1>&2 echo "TIP: use the LINT_DOCS variable to target just the documents you want to lint"; \
   		1>&2 echo "\n\tmake lint_docs LINT_DOCS=./docs/README.md"; \
   	fi;