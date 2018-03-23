
IMAGE_NAME = bamtech/custom-logging-test
TAG = latest
REGISTRY = razcp-docker.artifactory.bamtech.co:8080

build:
	docker build -t $(IMAGE_NAME):$(TAG) .

.PHONY: test

push:
	docker tag $(IMAGE_NAME):$(TAG) ${REGISTRY}/$(IMAGE_NAME):$(TAG) 
	docker push ${REGISTRY}/$(IMAGE_NAME):$(TAG) 
