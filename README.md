# Introduction

A complete openshift custom build config to build docker images from git source and push them to a private registry. This was not particularly well documented, so some debugging was required to get it working.

# Example

This is an example of building a simple nginx gateway Docker image.

The build config is `nginx-gateway-build-config.yml`. It defines a source git checkout, with a secret to check it out (assuming you have a secured repository for your code). The Dockefile could be in a sub directory, so you can optionally specify this. The build config also defines an output image, which includes the name of the remote registry to push the image to. Most remote registries are secured, and thus you can provide a secret to allow the push. The secret is a base64
encoded complete docker config.xml; [see] (registry-secret.md).

The builder image includes the build script and Dockerfile for the builder image. You can switch on debug via the DEBUG env var, and also specify a sleep at the end of the build, so you can debug the pod under origin (or maybe container platform if you are the cluster admin).

The `nginx` subdir gives an example of the Dockerfile that might be pulled own from your git repo, and then built.
