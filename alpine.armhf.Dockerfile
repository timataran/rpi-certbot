FROM arm32v7/alpine:3.11

LABEL org.opencontainers.image.authors="Tobias Hargesheimer <docker@ison.ws>" \
	org.opencontainers.image.title="CertBot" \
	org.opencontainers.image.description="AlpineLinux with CertBot on arm arch" \
	org.opencontainers.image.licenses="Apache-2.0" \
	org.opencontainers.image.url="https://hub.docker.com/r/tobi312/rpi-certbot" \
	org.opencontainers.image.source="https://github.com/Tob1asDocker/rpi-certbot"

ENV CERTBOT_VERSION 1.0.0

#RUN set -x && apk add --update certbot>${CERTBOT_VERSION} && rm -rf /var/cache/apk/*
RUN set -x && apk --no-cache add certbot>${CERTBOT_VERSION}

VOLUME /etc/letsencrypt /var/lib/letsencrypt

EXPOSE 80 443

ENTRYPOINT [ "certbot" ]
