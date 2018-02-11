#!/bin/bash

# OUTPUT_IMAGE - <registry>/<image>:<tag> name of the image
# SUBDIR - sub dir to cd to before building (optional)
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

set -o pipefail

[ -z "${DOCKER_SOCKET}" ] && {
  echo "Env var DOCKER_SOCKET not defined, meaning docker socket was not exposed in the custom build. Ensure its enabled."
  exit 1
}

[ ! -e "${DOCKER_SOCKET}" ] && {
  echo "Docker socket missing at ${DOCKER_SOCKET}"
  exit 1
}

src=$SOURCE_REPOSITORY
[ ! -z "${SOURCE_SECRET_PATH}" ] && {
  user=$(cat ${SOURCE_SECRET_PATH}/username)
  pass=$(cat ${SOURCE_SECRET_PATH}/password)
  [[ $SOURCE_REPOSITORY =~ ^https ]] && SOURCE_REPOSITORY="https://${user}:${pass}@${SOURCE_REPOSITORY#https://}"
  [[ $SOURCE_REPOSITORY =~ ^http: ]] && SOURCE_REPOSITORY="http://${user}:${pass}@${SOURCE_REPOSITORY#http://}"
}

BUILD_DIR=$(mktemp --directory)

ref=''
[ ! -z "${SOURCE_REF}" ] && {
  ref="-b ${SOURCE_REF}"
}

ref="${SOURCE_REF}"
[ -z "${ref}" ] && ref=master

echo "Git cloning ${src} (ref=${ref})."
git clone ${SOURCE_REPOSITORY} ${BUILD_DIR} || {
  echo "Error trying to fetch git source ${src} (ref=${ref})."
  exit 1
}

if [ -z "${SUBDIR}" ]; then
  echo "Building image using Dockerfile in ${BUILD_DIR}."
  docker build --rm -t ${OUTPUT_IMAGE} ${BUILD_DIR}
else
  echo "Building image using Dockerfile in ${BUILD_DIR}/${SUBDIR}."
  docker build --rm -t ${OUTPUT_IMAGE} ${BUILD_DIR}/${SUBDIR}
fi

[ ! -z "$PUSH_DOCKERCFG_PATH" ] && {
  [[ ! -d ~/.docker ]] && mkdir ~/.docker
  cp $PUSH_DOCKERCFG_PATH/config.json ~/.docker/
}

docker push ${OUTPUT_IMAGE}

[ ! -z "${SLEEP_AT_END}" ] && {
  sleep ${SLEEP_AT_END}
}

echo "Completed build."
