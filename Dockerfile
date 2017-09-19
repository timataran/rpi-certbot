FROM resin/raspberry-pi-alpine:3.6

MAINTAINER Tobias Hargesheimer <docker@ison.ws>

ENV CERTBOT_VERSION 0.14

RUN [ "cross-build-start" ]

#RUN apk add --update certbot>${CERTBOT_VERSION} && rm -rf /var/cache/apk/* \
RUN apk --no-cache add certbot>${CERTBOT_VERSION} \

RUN [ "cross-build-end" ]

VOLUME /etc/letsencrypt /var/lib/letsencrypt

EXPOSE 80 443

ENTRYPOINT [ "certbot" ]
