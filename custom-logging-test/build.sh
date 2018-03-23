#!/bin/bash

# WAITSECS - number of seconds to keep the build alive

# Alot of the env vars below are setup by k8s/openshift. Switch on DEBUG to see what is setup.

bargs=''

[ "${DEBUG}" = "true" ] && {
  set -x
  env|sort
  id
  ls -l
  pwd
}

set -o pipefail
echo "Starting build."

[ -z "${DOCKER_SOCKET}" ] && {
  echo "Env var DOCKER_SOCKET not defined, meaning docker socket was not exposed in the custom build. Ensure its enabled."
  exit 1
}

[ ! -e "${DOCKER_SOCKET}" ] && {
  echo "Docker socket missing at ${DOCKER_SOCKET}"
  exit 1
}

c=0
[ -z "$WAITSECS" ] && {
  echo "Env var WAITSECS is a null value or not defined."
  exit 1
}

while [ $c -lt $WAITSECS ]
do
  docker images
  sleep 10
  c=$(($c+10))
  echo "Second elapsed: $c"
  echo ""
done

echo ""
echo "Completed build."
