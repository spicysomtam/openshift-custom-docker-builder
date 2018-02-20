# Environment variables to parameterize the build:
#
# SOURCE_IMAGE - <registry>/<image>:<tag> name of the image
# TARGET_IMAGE - <registry>/<image>:<tag> name of the image
# DEBUG - switch on debugging if set to true (optional)
# SLEEP_AT_END - num secs to sleep at end of build, so you can access the pod in say origin, to debug, etc (optional)
#
# This image expects to have the Docker socket bind-mounted into the container (see openshift docs on custom builds).
#
FROM spicysomtam/openshift-custom-docker-builder

COPY retag.sh /tmp/retag.sh
RUN chmod a+x /tmp/retag.sh

LABEL io.k8s.display-name="OpenShift Custom Docker Tagger" \
      io.k8s.description="Retag and push images via an openshift custom build."
ENV HOME=/root
CMD ["/tmp/retag.sh"]
