# Introduction

This is an openshift custom build that does some testing using docker. We were seeing an issue streaming logs in Jenkins pipeline builds:

```
+ oc start-build -e WAITSECS=600 --wait=true --follow=true custom-logging-test
build "custom-logging-test-3" started
Second elapsed: 20
REPOSITORY                                                                       TAG                                        IMAGE ID            CREATED             SIZE
.
.
registry.access.redhat.com/openshift3/ose-pod                                    v3.6.173.0.21                              63accd48a0d7        6 months ago        209MB
error streaming logs (unexpected EOF), waiting for build to complete
```

If you do it on the command line, it just drops output:

```
$ oc logs custom-logging-test-4-build|tail -5 # Output chopped
.
.
.
centos/mysql-57-centos7                                                          <none>              36995baff282        7 weeks ago         449MB

$ oc logs custom-logging-test-3-build|tail -5
.
.
Second elapsed: 600
Completed build.

$ oc start-build -e WAITSECS=120 --wait=true --follow=true custom-logging-test
.
.
error streaming logs (unexpected EOF), waiting for build to complete
```

# Installing build config and running

```
$ oc new-app -f custom-logging-test-bc.yml
$ oc start-build -e WAITSECS=120 --wait=true --follow=true custom-logging-test
build "custom-logging-test-3" started

$ oc logs custom-logging-test-3-build # view logs
```
