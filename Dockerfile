FROM alpine:latest as builder
LABEL Maintainer "Selfhosting-tools (https://github.com/selfhosting-tools)"

ARG UNBOUND_VERSION=1.9.6
ARG GPG_FINGERPRINT="EDFAA3F2CA4E6EB05681AF8E9F6F1C2D7E045F8D"
ARG SHA256_HASH="1d98fc6ea99197a20b4a0e540e87022cf523085786e0fc26de6ebb2720f5aaf0"


RUN apk add --no-cache \
      bash \
      curl \
      gnupg \
      build-base \
      libevent-dev \
      openssl-dev \
      expat-dev \
      ca-certificates

SHELL [ "/bin/bash", "-o", "pipefail", "-c" ]

WORKDIR /tmp
RUN \
   curl -OO https://www.nlnetlabs.nl/downloads/unbound/unbound-${UNBOUND_VERSION}.tar.gz{,.asc} && \
   echo "Verifying authenticity of unbound-${UNBOUND_VERSION}.tar.gz..." && \
   CHECKSUM=$(sha256sum unbound-${UNBOUND_VERSION}.tar.gz | awk '{print $1}') && \
   if [ "${CHECKSUM}" != "${SHA256_HASH}" ]; then echo "ERROR: Checksum does not match!" && exit 1; fi && \
   ( \
      gpg --keyserver ha.pool.sks-keyservers.net --recv-keys ${GPG_FINGERPRINT} || \
      gpg --keyserver keyserver.pgp.com --recv-keys ${GPG_FINGERPRINT} || \
      gpg --keyserver pgp.mit.edu --recv-keys ${GPG_FINGERPRINT} \
   ) && \
   FINGERPRINT="$(LANG=C gpg --verify unbound-${UNBOUND_VERSION}.tar.gz.asc unbound-${UNBOUND_VERSION}.tar.gz 2>&1 \
                | sed -n 's#^Primary key fingerprint: \(.*\)#\1#p' | tr -d '[:space:]')" && \
   if [ -z "${FINGERPRINT}" ]; then echo "ERROR: Invalid GPG signature!" && exit 1; fi && \
   if [ "${FINGERPRINT}" != "${GPG_FINGERPRINT}" ]; then echo "ERROR: Wrong GPG fingerprint!" && exit 1; fi && \
   echo "SHA256 and GPG signature are correct"

RUN echo "Extracting unbound-${UNBOUND_VERSION}.tar.gz..." && \
    tar -xzf "unbound-${UNBOUND_VERSION}.tar.gz"
WORKDIR /tmp/unbound-${UNBOUND_VERSION}

RUN ./configure --prefix="" \
    CFLAGS="-O2 -flto -fPIE -U_FORTIFY_SOURCE -D_FORTIFY_SOURCE=2 -fstack-protector-strong \
            -Wformat -Werror=format-security" \
    LDFLAGS="-Wl,-z,now -Wl,-z,relro" && \
    make && \
    make install DESTDIR=/builder


FROM alpine:latest
LABEL Maintainer "Selfhosting-tools (https://github.com/selfhosting-tools)"

ENV UID=991

RUN adduser -u ${UID} -s /bin/nologin -h /etc/unbound --disabled-password unbound

RUN apk add --no-cache \
   openssl \
   expat \
   tini

COPY --from=builder /builder /
COPY run.sh /usr/local/bin

VOLUME /etc/unbound
EXPOSE 53 53/udp

HEALTHCHECK --interval=10s --timeout=5s --start-period=10s CMD unbound-control status

CMD ["run.sh"]
