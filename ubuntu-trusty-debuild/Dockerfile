FROM lboulard/ubuntu-dev:trusty

RUN apt-get update \
    && DEBIAN_FRONTEND=noninteractive apt-get install -y sudo

ARG tiny_pkg=tini_0.17.0-amd64.deb
COPY $tiny_pkg /
RUN dpkg -i /$tiny_pkg && rm -f /$tiny_pkg

# Use self compiled su-exec as a replacement from non-available gosu
ADD su-exec /sbin/su-exec

ADD debuild-entrypoint.sh /sbin/entrypoint.sh

ENTRYPOINT [ "/sbin/entrypoint.sh" ]
