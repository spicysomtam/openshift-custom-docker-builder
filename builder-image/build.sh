#!/bin/bash

# OUTPUT_IMAGE - <registry>/<image>:<tag> name of the image
# SUBDIR - sub dir to cd to before building (optional)
# DEBUG - switch on debugging if set to true (optional)
# SLEEP_AT_END - num secs to sleep at end of build, so you can access the pod in say origin, to debug, etc (optional)
# COMMIT - commit hash to checkout (optional)
# BUILDARGS - a hash ('#') delimited list of build args. eg BUILDARGS="VERSION=1.0#SOMETHING=foo".
#             With custom builds you cannot use build-args, so must use an env var instead.

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

BUILD_DIR=$(mktemp --directory || exit 1)

echo "Git cloning ${src})."
git clone ${SOURCE_REPOSITORY} ${BUILD_DIR} || {
  echo "Error trying to fetch git source ${src})."
  exit 1
}

cd $BUILD_DIR

[ ! -z "$COMMIT" ] && {
  git checkout $COMMIT || {
    echo "Error checking out $COMMIT."
    exit 1
  }
}

IFS=#
for a in $BUILDARGS
do
  unset IFS
  bargs+="--build-arg $a "

  [[ $a =~ ^VERSION= ]] && {
    VERFIX=$(echo $a|cut -d= -f2)
  }
done

unset IFS

BDIR=$BUILD_DIR
[ ! -z "${SUBDIR}" ] && BDIR=${BUILD_DIR}/${SUBDIR}

# Fix for this: https://github.com/moby/moby/issues/32457
# which works in latest docker-ce but not in openshift docker 0.12.x
# Replace /FROM ... <image>:\$VERSION$/ with the correct version
[ ! -z "$VERFIX" ] && sed -i "s/\$VERSION$/$VERFIX/" ${BDIR}/Dockerfile

echo "Building image using Dockerfile in ${BDIR}."
success=true
docker build $bargs --rm -t ${OUTPUT_IMAGE} ${BDIR} || success=false

# cleanup; put the build fail exit after the cleanup
cd -
rm -rf $BUILD_DIR

$success || exit 1

[ ! -z "$PUSH_DOCKERCFG_PATH" ] && {
  [[ ! -d ~/.docker ]] && mkdir ~/.docker
  cp $PUSH_DOCKERCFG_PATH/config.json ~/.docker/
}

docker push ${OUTPUT_IMAGE} || exit 1

[ ! -z "${SLEEP_AT_END}" ] && {
  sleep ${SLEEP_AT_END}
}

echo "Completed build."
