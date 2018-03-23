# Environment variables to parameterize the build:
#
# WAITSECS - number of seconds to keep the build alive
#
# This image expects to have the Docker socket bind-mounted into the container (see openshift docs on custom builds).
#
FROM openshift/origin-base

RUN INSTALL_PKGS="gettext automake make docker-ce" && \
    yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo && \
    yum install -y $INSTALL_PKGS && \
    rpm -V $INSTALL_PKGS && \
    yum clean all
COPY build.sh /tmp/build.sh
RUN chmod a+x /tmp/build.sh

LABEL io.k8s.display-name="OpenShift Custom Docker Builder" \
      io.k8s.description="Build docker images via an openshift custom build."
ENV HOME=/root
CMD ["/tmp/build.sh"]
