FROM alpine:latest
MAINTAINER BIND 9 Developers <bind9-dev@isc.org>

ENV DEBIAN_FRONTEND noninteractive
ENV LC_ALL C.UTF-8

ARG BIND9_VERSION=9.18.31
ARG BIND9_CHECKSUM=51b258969275c5206ef745a5aac03dbe98f1c8031fefed378d53597e7987b1b3

RUN apk --no-cache update
RUN apk --no-cache upgrade

RUN apk --no-cache add \
        autoconf \
        automake \
        build-base \
        fstrm \
        fstrm-dev \
        jemalloc \
        jemalloc-dev \
        json-c \
        json-c-dev \
        krb5-dev \
        krb5-libs \
        libcap-dev \
        libcap2 \
        libidn2 \
        libidn2-dev \
        libmaxminddb-dev \
        libmaxminddb-libs \
        libtool \
        libuv \
        libuv-dbg \
        libuv-dev \
        libxml2 \
        libxml2-dbg \
        libxml2-dev \
        libxslt \
        lmdb \
        lmdb-dev \
        make \
        musl-dbg \
        nghttp2-dev \
        nghttp2-libs \
        openssl-dbg \
        openssl-dev \
        procps \
	protobuf-c \
        protobuf-c-dev \
        tzdata

RUN mkdir -p /usr/src
ADD https://downloads.isc.org/isc/bind9/${BIND9_VERSION}/bind-${BIND9_VERSION}.tar.xz /usr/src
RUN cd /usr/src && \
    ( echo "${BIND9_CHECKSUM}  bind-${BIND9_VERSION}.tar.xz" | sha256sum -c - ) && \
    tar -xJf bind-${BIND9_VERSION}.tar.xz && \
    cd /usr/src/bind-${BIND9_VERSION} && \
    ./configure --prefix /usr \
                --sysconfdir=/etc/bind \
                --localstatedir=/ \
                --enable-shared \
                --disable-static \
                --with-gssapi \
                --with-libidn2 \
                --with-json-c \
                --with-lmdb=/usr \
                --with-gnu-ld \
                --with-maxminddb \
                --enable-dnstap && \
    make -j && \
    make install && \
    rm -rf /usr/src

# Create user and group
RUN addgroup -S bind && adduser -S -H -h /var/cache/bind -G bind bind

# Create default configuration file
RUN mkdir -p /etc/bind && chown root:bind /etc/bind/ && chmod 755 /etc/bind
COPY named.conf /etc/bind
RUN chown root:bind /etc/bind/named.conf && chmod 644 /etc/bind/named.conf

# Create working directory
RUN mkdir -p /var/cache/bind && chown bind:bind /var/cache/bind && chmod 755 /var/cache/bind

# Create directory to store secondary zones
RUN mkdir -p /var/lib/bind && chown bind:bind /var/lib/bind && chmod 755 /var/lib/bind

# Create log directory
RUN mkdir -p /var/log/bind && chown bind:bind /var/log/bind && chmod 755 /var/log/bind

# Create PID directory
RUN mkdir -p /run/named && chown bind:bind /run/named && chmod 755 /run/named

# Remove development packages
RUN apk --no-cache del \
        autoconf \
        automake \
        build-base \
        fstrm-dev \
        gnutls-utils \
        jemalloc-dev \
        json-c-dev \
        krb5-dev \
        libcap-dev \
        libidn2-dev \
        libmaxminddb-dev \
        libtool \
        libuv-dev \
        libxml2-dev \
        libxslt \
        lmdb-dev \
        make \
        nghttp2-dev \
        openssl-dev \
        protobuf-c-dev

VOLUME ["/etc/bind", "/var/cache/bind", "/var/lib/bind", "/var/log"]

EXPOSE 53/udp 53/tcp 953/tcp 853/tcp 443/tcp

ENTRYPOINT ["/usr/sbin/named", "-u", "bind"]
CMD ["-f", "-c", "/etc/bind/named.conf", "-L", "/var/log/bind/default.log"]
