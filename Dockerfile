FROM alpine:3.11.3@sha256:ddba4d27a7ffc3f86dd6c2f92041af252a1f23a8e742c90e6e1297bfa1bc0c45 as builder
ARG JTSDNS_VERSION
WORKDIR /JTSDNS
RUN apk add --no-cache unzip wget ca-certificates && \
  wget --no-verbose --retry-connrefused --read-timeout=10 --timeout=10 --tries=3 "https://raw.githubusercontent.com/vishnubob/wait-for-it/master/wait-for-it.sh" && \
  chmod +x wait-for-it.sh
RUN wget --no-verbose --retry-connrefused --read-timeout=10 --timeout=10 --tries=3 "https://www.stefan1200.de/downloads/JTSDNS_${JTSDNS_VERSION}.zip" && \
  unzip JTSDNS_${JTSDNS_VERSION}.zip -d / && \
  rm -R JTSDNS_${JTSDNS_VERSION}.zip MySQL_JConnector/ tools/ JTSDNS-Windows* readme.txt

FROM openjdk:8u171-jre-alpine@sha256:8fce9c197de91e925595a74e159b82b589f70baf2e086f6e63a8b8c8e193a8ca
MAINTAINER Philipp Daniels <philipp.daniels@gmail.com>

ARG JTSDNS_VERSION=1.6.0
ARG VCS_REF
ARG BUILD_DATE

ENV JTSDNS_MYSQL_TIMEOUT=60
ENV JTSDNS_MYSQL_CREATE_TABLES=1

LABEL org.label-schema.schema-version="1.0" \
      org.label-schema.build-date=${BUILD_DATE} \
      org.label-schema.name="JTSDNS" \
      org.label-schema.version="${JTSDNS_VERSION}" \
      org.label-schema.description="TSDNS alternative with MySQL" \
      org.label-schema.url="https://www.stefan1200.de/forum/index.php?topic=208.0" \
      org.label-schema.usage="https://www.stefan1200.de/documentation/jtsdns/readme.txt" \
      org.label-schema.vcs-url="https://github.com/phaldan/docker-jtsdns" \
      org.label-schema.vcs-ref=${VCS_REF} \
      org.label-schema.vendor="PhALDan" \
      org.label-schema.docker.cmd="docker run -d --name=jtsdns -v JTSDNS.cfg:/JTSDNS/JTSDNS.cfg -p 41144:41144 phaldan/jtsdns"

RUN apk add --no-cache bash mariadb-client
WORKDIR /JTSDNS
COPY --from=builder /JTSDNS .
COPY docker-entrypoint.sh .
EXPOSE 41144/tcp
VOLUME /JTSDNS/log
ENTRYPOINT ["./docker-entrypoint.sh"]

