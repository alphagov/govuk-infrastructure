# This Makefile is just for convenience when building locally.
# The production image is built by the GitHub Actions workflow in
# ../../.github/workflows/build-mongodb-image.yml.

.PHONY: all image

image:
	docker build -t mongodb:2.6 --platform linux/amd64 .
