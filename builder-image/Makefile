
IMAGE_NAME = spicysomtam/openshift-custom-docker-builder
TAG = latest
REGISTRY = 'docker.io'

build:
	docker build -t $(IMAGE_NAME):$(TAG) .

.PHONY: test

push:
	docker tag $(IMAGE_NAME):$(TAG) ${REGISTRY}/$(IMAGE_NAME):$(TAG) 
	docker push ${REGISTRY}/$(IMAGE_NAME):$(TAG) 
