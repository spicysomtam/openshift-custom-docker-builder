#!/bin/bash

# SOURCE_IMAGE - <registry>/<image>:<tag> name of the image
# TARGET_IMAGE - <registry>/<image>:<tag> name of the image
# DEBUG - switch on debugging if set to true (optional)
# SLEEP_AT_END - num secs to sleep at end of build, so you can access the pod in say origin, to debug, etc (optional)

# Alot of the env vars below are setup by k8s/openshift. Switch on DEBUG to see what is setup.

[ "${DEBUG}" = "true" ] && {
  set -x
  env|sort
  id
  ls -l
  pwd
}

[ -z "${DOCKER_SOCKET}" ] && {
  echo "Env var DOCKER_SOCKET not defined, meaning docker socket was not exposed in the custom build. Ensure its enabled."
  exit 1
}

[ ! -e "${DOCKER_SOCKET}" ] && {
  echo "Docker socket missing at ${DOCKER_SOCKET}"
  exit 1
}

[ -z "${SOURCE_IMAGE}" ] && {
  echo "SOURCE_IMAGE env var not defined."
  exit 1
}

[ -z "${TARGET_IMAGE}" ] && {
  echo "TARGET_IMAGE env var not defined."
  exit 1
}

echo "Pulling image ${SOURCE_IMAGE}."
docker pull ${SOURCE_IMAGE}

echo "Tagging image ${SOURCE_IMAGE} to ${TARGET_IMAGE}."
docker tag ${SOURCE_IMAGE} ${TARGET_IMAGE}

[ ! -z "$PUSH_DOCKERCFG_PATH" ] && {
  [[ ! -d ~/.docker ]] && mkdir ~/.docker
  cp $PUSH_DOCKERCFG_PATH/config.json ~/.docker/
}

echo "Pushing image ${TARGET_IMAGE}."
docker push ${TARGET_IMAGE}

[ ! -z "${SLEEP_AT_END}" ] && {
  sleep ${SLEEP_AT_END}
}

echo "Completed tagging and pushing."
