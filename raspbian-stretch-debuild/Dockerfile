FROM lboulard/raspbian-dev:stretch

RUN [ "cross-build-start" ]

RUN apt-get update \
    && DEBIAN_FRONTEND=noninteractive apt-get install -y gosu

ARG tiny_bin=tini-armel_0.17.0
ADD $tiny_bin /sbin/tini

ADD raspbian-entrypoint.sh /sbin/entrypoint.sh

RUN [ "cross-build-end" ]

ENTRYPOINT [ "/sbin/entrypoint.sh" ]
