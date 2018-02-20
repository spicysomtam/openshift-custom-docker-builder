# Introduction

A complete openshift custom build config to build docker images from git source and push them to a private registry. This was not particularly well documented, so some debugging was required to get it working.

Also included is a custom build config to retag images on a remote docker registry; that is, it allows you to promote images between environments, retag images between commit ids and versions, or however you do your image tagging. So image pull, retag, and push back.

Both of these can be integrated in Jenkins or whatever CI/CD you use (Openshift comes with a Jenkins setup out of the box). Thus you can build docker images in Openshift, and retag them via a remote registry (the internal Openshift docker registry isn't intended for this and is only really there to support the cluster).

# Image building

This is an example of building a simple nginx gateway Docker image.

The build config is `nginx-gateway-build-config.yml`. It defines a source git checkout, with a secret to check it out (assuming you have a secured repository for your code). The Dockefile could be in a sub directory, so you can optionally specify this. The build config also defines an output image, which includes the name of the remote registry to push the image to. Most remote registries are secured, and thus you can provide a secret to allow the push. The secret is a base64
encoded complete docker `config.json`; [instructions on setting this up here](registry-secret.md).

The builder image includes the build script and Dockerfile for the builder image. You can switch on debug via the DEBUG env var, and also specify a sleep at the end of the build, so you can debug the pod under origin (or maybe container platform if you are the cluster admin).

The `nginx` subdir gives an example of the Dockerfile that might be pulled own from your git repo, and then built.

## Running

```
$ oc create -f github-secret.yml # This needs adapting
$ oc create -f registry-secret.yml # You need to create this; see link above
$ oc new-app -f nginx-gateway-buid-config.yml
$ oc start-build nginx-gateway
$ oc edit bc/nginx-gateway # If you want to adapt it on the fly; eg switch on DEBUG, etc
```

# Image retagging

Typically your Openshift Jenkins CI/CD pipeline will build your app docker images (for Openshift) and then push them to an external docker registry where they are available globally, outside a single Openship cluster. Lets say they get tagged as `latest`; these are the images for dev, which will need testing, and then at some point will be promoted to `qa`, etc, and then deployed to another openshift project, or even another openshift cluster. Thus you have a need to be able to retag images on a remote registry, from a CI/CD pipeline running on the Openshift Jenkins. This is what this custom build config allows you to do.

Also consider the situation where you have multiple openshift clusters that are distributed geographically in data centers all over the country. How do you do image promotion between the clusters (and projects within the clusters)? The simple answer is to use an external docker registry (jfrog, docker, etc), that all clusters can pull images from, and this build config to do the image retagging.

The image build lives under the `tagger-image` directory. The build config for it is `custom-docker-tagger.yml`.

Most private registries allow pulls without credentials, but pushes need to be authenticated, so you can create the push secret as described above.

You load the build config as follows:
```
$ oc new-app -f custom-docker-tagger.yml
```

You build the image in the `tagger-image` dir (or pull my image from docker hub).

Then you do you image pulling and pushing as follows; the `DEBUG` lets you see what the script is doing:
```
$ oc start-build -e SOURCE_IMAGE=myregistry.com:5000/someimage:latest -e TARGET_IMAGE=myregistry.com:5000/someimage:qa -e DEBUG=true custom-docker-tagger
```

Thus the same build config can be used repeatedly for different images/tags; no need for a build config for every image.
