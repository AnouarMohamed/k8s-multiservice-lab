SHELL := /usr/bin/env bash

NAMESPACE ?= stg
APP ?= flask-api
IMAGE ?= flask-api:stg
LOCAL_PORT ?= 5000
OVERLAY ?= k8s/overlays/staging

.PHONY: bootstrap install-dev test build deploy diff validate status logs port-forward smoke restart clean

bootstrap:
	./scripts/bootstrap-k3s.sh

install-dev:
	python -m pip install -r app/requirements-dev.txt

test:
	PYTHONPATH=app pytest app/tests

build:
	./scripts/build-image.sh

deploy:
	./scripts/deploy.sh

diff:
	kubectl diff -k $(OVERLAY)

validate:
	./scripts/validate.sh

status:
	./scripts/status.sh

logs:
	kubectl -n $(NAMESPACE) logs -l app.kubernetes.io/name=$(APP) --tail=100

port-forward:
	./scripts/port-forward.sh $(LOCAL_PORT)

smoke:
	./scripts/smoke-test.sh

restart:
	kubectl -n $(NAMESPACE) rollout restart deployment/$(APP)
	kubectl -n $(NAMESPACE) rollout status deployment/$(APP) --timeout=120s

clean:
	./scripts/cleanup.sh
