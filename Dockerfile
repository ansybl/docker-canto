ARG VERSION=8.1.2
ARG GO_VERSION=1.21
FROM golang:${GO_VERSION}-alpine AS buildenv

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
    wget https://github.com/a8m/envsubst/releases/download/v1.4.2/envsubst-$(uname -s)-$(if [ "$(uname -m)" = "aarch64" ]; then echo "arm64"; else uname -m; fi) -O /tmp/envsubst && \
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

COPY config/docker-entrypoint.sh /
COPY config/docker-entrypoint.d/ /docker-entrypoint.d/
COPY config/root/ /root/
WORKDIR /root

STOPSIGNAL SIGINT

ENTRYPOINT [ "/docker-entrypoint.sh" ]
CMD ["cantod", "start", "--home", "/root/.cantod", "--x-crisis-skip-assert-invariants"]
