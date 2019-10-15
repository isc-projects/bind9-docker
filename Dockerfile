FROM alpine:latest
MAINTAINER BIND 9 Developers <bind9-dev@isc.org>
ENV BIND9_VERSION 9.11.11
RUN apk update
RUN apk add \
	autoconf \
	automake \
	build-base \
	ccache \
	cmocka-dev \
	curl \
	fstrm-dev \
	geoip-dev \
	git \
	gnupg \
	json-c-dev \
	krb5-dev \
	kyua \
	libcap-dev \
	libidn2-dev \
	libmaxminddb-dev \
	libtool \
	libxml2-dev \
	libuv-dev \
	libxslt \
	lmdb-dev \
	make \
	openssl-dev \
	perl \
	perl-digest-hmac \
	perl-json \
	perl-net-dns \
	perl-xml-simple \
	protobuf-c-dev \
	py3-dnspython \
	py3-ply \
	python3 \
	tzdata
RUN curl -sSLO https://ftp.isc.org/isc/bind9/$BIND9_VERSION/bind-$BIND9_VERSION.tar.gz
RUN curl -sSLO https://ftp.isc.org/isc/bind9/$BIND9_VERSION/bind-$BIND9_VERSION.tar.gz.asc
RUN curl -sSL https://ftp.isc.org/isc/pgpkeys/codesign2019.txt | gpg --import
RUN gpg --verify bind-$BIND9_VERSION.tar.gz.asc bind-$BIND9_VERSION.tar.gz || exit 1
RUN tar -czf bind-$BIND9_VERSION.tar.gz
RUN cd bind-$BIND_VERSION && -Wall -Wextra -O2 -g ./configure --prefix=/usr --includedir=\${prefix}/include --mandir=\${prefix}/share/man --infodir=\${prefix}/share/info --sysconfdir=/etc/bind --localstatedir=/ --disable-silent-rules --libdir=\${prefix}/lib/x86_64-linux-gnu --libexecdir=\${prefix}/lib/x86_64-linux-gnu --disable-maintainer-mode --enable-developer --with-libtool --disable-static --with-cmocka --with-libxml2 --with-json-c --prefix=/usr/local --without-make-clean --sysconfdir=/etc/bind --enable-dnstap --with-libidn2 --with-maxminddb && make && make install
RUN ldconfig
VOLUME ["/etc/bind", "/var/cache/bind", "/var/lib/bind", "/var/log", "/var/run/bind"]

RUN addgroup -S bind && adduser -S bind -G bind
RUN mkdir -p /etc/bind && chown root:bind /etc/bind/ && chmod 750 /etc/bind
RUN mkdir -p /var/cache/bind && chown bind:bind /var/cache/bind && chmod 750 /var/cache/bind
RUN mkdir -p /var/lib/bind && chown bind:bind /var/lib/bind && chmod 750 /var/lib/bind
RUN mkdir -p /var/log/bind && chown bind:bind /var/log/bind && chmod 750 /var/log/bind
RUN mkdir -p /var/run/bind && chown bind:bind /var/run/bind && chmod 750 /var/run/bind

COPY named.conf /etc/bind/named.conf

EXPOSE 53
EXPOSE 53/udp

CMD ["/usr/sbin/named", "-f", "-c", "/etc/bind/named.conf", "-u", "bind"]
