SHELL := /bin/bash

ifdef SLIM
IMAGE := docker.io/imroc/kubectl:slim
DOCKERFILE := Dockerfile.slim
else
IMAGE := docker.io/imroc/kubectl:latest
DOCKERFILE := Dockerfile
endif

# CONTAINER_TOOL defines the container tool to be used for building images.
# Be aware that the target commands are only tested with Docker which is
# scaffolded by default. However, you might want to replace it to use other
# tools. (i.e. podman)
CONTAINER_TOOL ?= docker

.PHONY: all
all:
	make buildx-push
	SLIM=1 make buildx-push

.PHONY: build
build:
	$(CONTAINER_TOOL) build -t $(IMAGE) -f $(DOCKERFILE) .

.PHONY: push
push:
	$(CONTAINER_TOOL) push $(IMAGE)

.PHONY: build-push
build-push: build push

PLATFORMS ?= linux/arm64,linux/amd64

.PHONY: buildx
buildx:
	$(CONTAINER_TOOL) buildx build --platform=$(PLATFORMS) -t $(IMAGE) -f $(DOCKERFILE) .

.PHONY: buildx-push
buildx-push: buildx push
