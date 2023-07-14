ARG VERSION=5.0.2
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

RUN echo "Building v$VERSION" && \
    git clone --depth 1 --branch v$VERSION https://github.com/Canto-Network/Canto.git Canto-$VERSION && \
    cd Canto-$VERSION && \
    make && \
    cd /app

FROM alpine:3

ARG VERSION
ENV VERSION=$VERSION
ENV CANTOD_HOME=/root/.cantod

COPY --from=buildenv /app/Canto-${VERSION}/build/cantod /tmp/cantod${VERSION}

RUN install -m 0755 -o root -g root -t /usr/local/bin /tmp/cantod$VERSION && \
    rm /tmp/cantod$VERSION;

WORKDIR /root
