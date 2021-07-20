.PHONY: all build test clean

SHELL = /bin/bash

all: build test

build: build_prep build_platform

build_prerequisites:
	bash ci/kuma.sh
	kumactl install metrics | sed 's/name: kuma-metrics/name: $${namespace}/'  > templates/metrics.yaml

build_prep:
	@pushd examples/default; \
	terraform init; \
	popd

build_platform:
	@pushd examples/default; \
	terraform apply -auto-approve; \
	popd

test: test_deployment

test_deployment:
	@echo "Testing"

clean:
	@pushd examples/default; \
	terraform destroy -auto-approve; \
	popd
