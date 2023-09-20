ARG VERSION=6.0.0
FROM golang:1.20-alpine AS buildenv

ARG VERSION

# Set up dependencies
RUN apk add --update --no-cache \
    eudev-dev \
    gcc \
    git \
    libc-dev \
    linux-headers \
    make

# Set working directory for the build
WORKDIR /app

RUN git clone --depth 1 --branch v$VERSION https://github.com/Canto-Network/Canto.git Canto-$VERSION && \
    cd Canto-$VERSION && \
    make && \
    wget https://github.com/a8m/envsubst/releases/download/v1.2.0/envsubst-`uname -s`-`uname -m` -O /tmp/envsubst && \
    cd /app

FROM alpine:3

ARG VERSION
ENV VERSION=$VERSION
ENV CANTOD_HOME=/root/.cantod

RUN apk add --update --no-cache jq

COPY --from=buildenv /app/Canto-${VERSION}/build/cantod /tmp/cantod
COPY --from=buildenv /tmp/envsubst /tmp/

RUN install -m 0755 -o root -g root -t /usr/local/bin /tmp/cantod && \
    rm /tmp/cantod && \
    install -m 0755 -o root -g root -t /usr/local/bin /tmp/envsubst && \
    rm /tmp/envsubst

COPY config/ /
WORKDIR /root

STOPSIGNAL SIGINT

ENTRYPOINT [ "/docker-entrypoint.sh" ]
CMD ["cantod", "start", "--home", "/root/.cantod", "--x-crisis-skip-assert-invariants"]
