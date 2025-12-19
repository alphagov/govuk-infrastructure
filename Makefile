.PHONY: lint_docs
lint_docs:
	@vale sync
	@vale \
		--config ".vale.ini" \
		--glob='**/*.md' \
		--no-global \
		--no-exit \
		docs/