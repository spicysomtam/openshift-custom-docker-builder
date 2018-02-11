# Introduction

We need a secret to allow openshift to push images to private registry. In effect, this is a base64 encoded docker config.json.

The process is described [here](https://docs.openshift.com/container-platform/3.6/dev_guide/builds/build_inputs.html#using-docker-credentials-for-private-registries).

# Create the secret

If the secret does not exist; prepare a docker `config.json` file, by moving yours aside:

```
$ mv ~/.docker/config.json ~/.docker/config.json.orig
```

Then login to the registry using docker and enter the credentials:

```
$ docker login registry
Username: myname
Password:
```

Assuming you are already logged into the required openshift project:

```
$ oc secrets new docker-io-somewhere ~/.docker/config.json
$ oc secrets link builder docker-io-somewhere
```

The secret should now exist and the openshift builder can use it. You can check the secret via the command above.

Cleanup after creating the secret:

```
$ rm -f ~/.docker/config.json
$ mv ~/.docker/config.json.orig ~/.docker/config.json
```
