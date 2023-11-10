FROM alpine:3.18.3 AS builder

ARG TOR_VER=0.4.8.9
ARG TORGZ=https://dist.torproject.org/tor-$TOR_VER.tar.gz

RUN \
  apk --no-cache add --update \
    alpine-sdk \
    gnupg \
    libevent \
    libevent-dev \
    zlib \
    zlib-dev \
    openssl \
    openssl-dev && \
  wget $TORGZ.sha256sum.asc && wget $TORGZ.sha256sum && wget $TORGZ && \
  gpg --keyserver keys.openpgp.org --recv-keys \
    514102454D0A87DB0767A1EBBE6A0531C18A9179 \
    B74417EDDF22AC9F9E90F49142E86A2A11F48D36 \
    2133BC600AB133E1D826D173FE43009C4607B1FB && \
  gpg --output /root/.gnupg/tor.keyring --export \
    514102454D0A87DB0767A1EBBE6A0531C18A9179 \
    B74417EDDF22AC9F9E90F49142E86A2A11F48D36 \
    2133BC600AB133E1D826D173FE43009C4607B1FB && \
  gpgv --keyring /root/.gnupg/tor.keyring tor-$TOR_VER.tar.gz.sha256sum.asc tor-$TOR_VER.tar.gz.sha256sum || { echo "Couldn't verify signature"; exit 1; } && \
  sha256sum -c tor-$TOR_VER.tar.gz.sha256sum || { echo "Couldn't verify checksum"; exit 1; } && \
  tar xfz tor-$TOR_VER.tar.gz && cd tor-$TOR_VER && \
  ./configure && make -j $(nproc --all) install

FROM alpine:3.18.3

RUN \
  apk --no-cache add --update \
    bash \
    libevent \
    libevent-dev \
    zlib \
    zlib-dev \
    openssl \
    openssl-dev && \
  adduser -s /bin/bash -D -u 99 tor && \
  mkdir -p /var/run/tor && chown -R tor:tor /var/run/tor && chmod 2700 /var/run/tor && \
  mkdir -p /home/tor/tor && chown -R tor:tor /home/tor/tor  && chmod 2700 /home/tor/tor

COPY --from=builder /usr/local/ /usr/local/

USER tor

VOLUME /home/tor

EXPOSE 9050
EXPOSE 9051

ENTRYPOINT ["tor", "-f", "/home/tor/torrc"]
