PROJECT=dfpl-playground
REGISTRY=gcr.io/$(PROJECT)
IMAGE_NAME=canto
DOCKER_IMAGE=$(REGISTRY)/$(IMAGE_NAME)
VERSION=5.0.2
VERSIONS=1.0.0 2.0.1


docker/pull:
	docker pull $(DOCKER_IMAGE):$(IMAGE_TAG)

docker/build/version/%:
	docker build --tag=$(DOCKER_IMAGE):$* --build-arg VERSION=$* .

docker/build/versions:
	for version in $(VERSIONS) ; do \
	    make docker/build/version/$$version ; \
	done

docker/build: docker/build/versions

docker/login:
	gcloud auth print-access-token | docker login -u oauth2accesstoken --password-stdin https://gcr.io

docker/push/version/%:
	docker push $(DOCKER_IMAGE):$*

docker/push/versions:
	for version in $(VERSIONS) ; do \
	    make docker/push/version/$$version ; \
	done

docker/push: docker/push/versions

docker/run:
	docker run $(DOCKER_IT) --rm $(DOCKER_IMAGE)

docker/run/sh:
	docker run $(DOCKER_IT) --entrypoint /bin/sh --rm $(DOCKER_IMAGE)

lint/node:
	npx prettier --check .github *.md

lint: lint/node

format/node:
	npx prettier --write .github *.md

format: format/node
