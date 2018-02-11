FROM nginx

# New default conf containing the proxy config
COPY ./nginx.conf /etc/nginx/nginx.conf
ARG GIT_COMMIT=unknown

# Ewww—but this is a hack to make Watchtower re-deploy the gateway in order to pick up the
# updated addresses of the proxied services
RUN date > /var/timestamp

RUN rm -rf /etc/nginx/conf.d/* && \
    chgrp -R 0 /var/cache/nginx /var/run && \
    chmod -R g+rw /var/cache/nginx /var/run

COPY services/* /etc/nginx/conf.d/
LABEL GIT_COMMIT=${GIT_COMMIT}
EXPOSE 8080
