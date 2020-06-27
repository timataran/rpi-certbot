FROM arm32v7/python:3.8-alpine3.12

LABEL org.opencontainers.image.authors="Electronic Frontier Foundation and others, Tobias Hargesheimer <docker@ison.ws>" \
	org.opencontainers.image.title="CertBot" \
	org.opencontainers.image.description="AlpineLinux with CertBot on arm arch" \
	org.opencontainers.image.licenses="Apache-2.0" \
	org.opencontainers.image.url="https://hub.docker.com/r/tobi312/rpi-certbot" \
	org.opencontainers.image.source="https://github.com/Tob1asDocker/rpi-certbot"

ENTRYPOINT [ "certbot" ]
EXPOSE 80 443
VOLUME /etc/letsencrypt /var/lib/letsencrypt
WORKDIR /opt/certbot

# Retrieve certbot code
RUN mkdir -p src \
 && CERTBOT_VERSION=$(wget -qO- https://api.github.com/repos/certbot/certbot/releases/latest | grep 'tag_name' | cut -d\" -f4 | tr -d v) && echo "CERTBOT_VERSION=${CERTBOT_VERSION}" \
 && wget -O certbot-${CERTBOT_VERSION}.tar.gz https://github.com/certbot/certbot/archive/v${CERTBOT_VERSION}.tar.gz \
 && tar xf certbot-${CERTBOT_VERSION}.tar.gz \
 && cp certbot-${CERTBOT_VERSION}/CHANGELOG.md certbot-${CERTBOT_VERSION}/README.rst src/ \
 && cp certbot-${CERTBOT_VERSION}/letsencrypt-auto-source/pieces/dependency-requirements.txt . \
 && cp certbot-${CERTBOT_VERSION}/letsencrypt-auto-source/pieces/pipstrap.py . \
 && cp -r certbot-${CERTBOT_VERSION}/tools tools \
 && cp -r certbot-${CERTBOT_VERSION}/acme src/acme \
 && cp -r certbot-${CERTBOT_VERSION}/certbot src/certbot \
 && rm -rf certbot-${CERTBOT_VERSION}.tar.gz certbot-${CERTBOT_VERSION}

# Generate constraints file to pin dependency versions
RUN cat dependency-requirements.txt | tools/strip_hashes.py > unhashed_requirements.txt \
 && cat tools/dev_constraints.txt unhashed_requirements.txt | tools/merge_requirements.py > docker_constraints.txt

# Install certbot runtime dependencies
RUN apk add --no-cache --virtual .certbot-deps \
        libffi \
        libssl1.1 \
        openssl \
        ca-certificates \
        binutils

# Install certbot from sources
RUN apk add --no-cache --virtual .build-deps \
        gcc \
        linux-headers \
        openssl-dev \
        musl-dev \
        libffi-dev \
    && python pipstrap.py \
    && pip install -r dependency-requirements.txt \
    && pip install --no-cache-dir --no-deps \
        --editable src/acme \
        --editable src/certbot \
&& apk del .build-deps
