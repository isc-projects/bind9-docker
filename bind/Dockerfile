FROM ubuntu:bionic
MAINTAINER BIND 9 Developers <bind9-dev@isc.org>
ENV DEBIAN_FRONTEND noninteractive

RUN apt-get -y update &&  apt-get -y dist-upgrade
RUN apt-get -y install --no-install-recommends --no-install-suggests software-properties-common

RUN add-apt-repository --yes --update ppa:isc/bind
RUN apt-get -y install --no-install-recommends --no-install-suggests bind9

RUN mkdir -p /var/run/named /etc/bind/zones
RUN chmod 775 /var/run/named
RUN chown root:bind /var/run/named

VOLUME ["/etc/bind", "/var/cache/bind", "/var/lib/bind", "/var/log", "/var/run/named"]

EXPOSE 53
EXPOSE 53/udp

CMD ["/usr/sbin/named", "-g", "-c", "/etc/bind/named.conf", "-u", "bind"]
