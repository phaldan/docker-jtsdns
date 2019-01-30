FROM alpine:3.9@sha256:5a32c65954238c8f70fb9652ba7af86dbd3a10c053258578efea39897c127bf4 as builder
ARG JTSDNS_VERSION
WORKDIR /JTSDNS
RUN apk add --no-cache unzip wget ca-certificates && \
  wget --no-verbose --retry-connrefused --read-timeout=10 --timeout=10 --tries=3 "https://raw.githubusercontent.com/vishnubob/wait-for-it/master/wait-for-it.sh" && \
  chmod +x wait-for-it.sh
RUN wget --no-verbose --retry-connrefused --read-timeout=10 --timeout=10 --tries=3 "https://www.stefan1200.de/downloads/JTSDNS_${JTSDNS_VERSION}.zip" && \
  unzip JTSDNS_${JTSDNS_VERSION}.zip -d / && \
  rm -R JTSDNS_${JTSDNS_VERSION}.zip MySQL_JConnector/ tools/ JTSDNS-Windows* readme.txt

FROM openjdk:8u171-jre-alpine@sha256:e3168174d367db9928bb70e33b4750457092e61815d577e368f53efb29fea48b
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

