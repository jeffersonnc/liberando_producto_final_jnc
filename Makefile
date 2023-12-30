VENV 	?= venv
PYTHON 	= $(VENV)/bin/python3
PIP		= $(VENV)/bin/pip

# Variables used to configure docker images
IMAGE_REGISTRY_DOCKERHUB 	?= jeffersonnc
IMAGE_REGISTRY_GHCR			?= ghcr.io
IMAGE_REPO					= jeffersonnc
IMAGE_NAME					?= liberando_producto_final_jnc
VERSION						?= develop

# Variables used to configure docker images registries to build and push
IMAGE 				= $(IMAGE_REGISTRY_DOCKERHUB)/$(IMAGE_NAME):$(VERSION)
IMAGE_LATEST 		= $(IMAGE_REGISTRY_DOCKERHUB)/$(IMAGE_NAME):latest
IMAGE_GHCR			= $(IMAGE_REGISTRY_GHCR)/$(IMAGE_REPO)/$(IMAGE_NAME):$(VERSION)
IMAGE_GHCR_LATEST	= $(IMAGE_REGISTRY_GHCR)/$(IMAGE_REPO)/$(IMAGE_NAME):latest

.PHONY: run
run: $(VENV)/bin/activate
	$(PYTHON) src/app.py

.PHONY: unit-test
unit-test: $(VENV)/bin/activate
	pytest

.PHONY: unit-test-coverage
unit-test-coverage: $(VENV)/bin/activate
	pytest --cov

.PHONY: $(VENV)/bin/activate
$(VENV)/bin/activate: requirements.txt
	python3 -m venv $(VENV)
	$(PIP) install -r requirements.txt

.PHONY: docker-build
docker-build: ## Build image
	docker build -t $(IMAGE) -t $(IMAGE_LATEST) .

.PHONY: publish
publish: docker-build ## Publish image
	docker push $(IMAGE)
	docker push $(IMAGE_LATEST)

.PHONY: docker-build-ghcr
docker-build-ghcr: ## Build image for GHCR
	docker build -t $(IMAGE_GHCR) -t $(IMAGE_GHCR_LATEST) .

.PHONY: publish-ghcr
publish-ghcr: docker-build-ghcr ## Publish image to GHCR
	docker push $(IMAGE_GHCR)
	docker push $(IMAGE_GHCR_LATEST)
