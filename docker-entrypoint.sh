#!/usr/bin/env ash
set -o errexit
set -o pipefail

main() {
  trap shutdown SIGTERM
  prepareConfig
  prepareDatabase
  start "$@"
}

shutdown() {
  echo "Caught signal"
  echo "Shutdown server (pid=${PID})"

  kill ${PID}
  wait ${PID}
  exit 0
}

start() {
  java -jar JTSDNS.jar "$@" &
  PID=$!
  echo "Start server (pid=${PID})"
  wait ${PID}
}

prepareConfig() {
  if [ ! -z ${JTSDNS_MYSQL_HOST+x} ]; then setConfigEntry "mysql_host" "${JTSDNS_MYSQL_HOST}"; fi
  if [ ! -z ${JTSDNS_MYSQL_PORT+x} ]; then setConfigEntry "mysql_port" "${JTSDNS_MYSQL_PORT}"; fi
  if [ ! -z ${JTSDNS_MYSQL_USER+x} ]; then setConfigEntry "mysql_user" "${JTSDNS_MYSQL_USER}"; fi
  if [ ! -z ${JTSDNS_MYSQL_PASSWORD+x} ]; then setConfigEntry "mysql_password" "${JTSDNS_MYSQL_PASSWORD}"; fi
  if [ ! -z ${JTSDNS_MYSQL_DATABASE+x} ]; then setConfigEntry "mysql_database" "${JTSDNS_MYSQL_DATABASE}"; fi

  if [ ! -z ${JTSDNS_MYSQL_VERIFY_SERVER_CERTIFICATE+x} ]; then setConfigEntry "mysql_verifyServerCertificate" "${JTSDNS_MYSQL_VERIFY_SERVER_CERTIFICATE}"; fi
  if [ ! -z ${JTSDNS_MYSQL_USE_SSL+x} ]; then setConfigEntry "mysql_useSSL" "${JTSDNS_MYSQL_USE_SSL}"; fi
  if [ ! -z ${JTSDNS_MYSQL_REQUIRE_SSL+x} ]; then setConfigEntry "mysql_requireSSL" "${JTSDNS_MYSQL_REQUIRE_SSL}"; fi
  if [ ! -z ${JTSDNS_MYSQL_USE_COMPRESSION+x} ]; then setConfigEntry "mysql_useCompression" "${JTSDNS_MYSQL_USE_COMPRESSION}"; fi

  if [ ! -z ${JTSDNS_LOGFILE+x} ]; then setConfigEntry "logfile" "${JTSDNS_LOGFILE}"; fi
}

setConfigEntry() {
  KEY=$1
  VALUE=$2
  LINE="${KEY} = ${VALUE}"
  if grep -q "^${KEY}\s*=" ${CONFIG_FILE}; then
    replaceConfigEntry "${KEY}" "${LINE}"
  else
    appendConfigEntry "${LINE}"
  fi
}

replaceConfigEntry() {
  KEY=$1
  LINE=$2
  sed -i "s|^${KEY}\s*=.*|${LINE}|g" ${CONFIG_FILE}
}

appendConfigEntry() {
  LINE=$1
  echo "${LINE}" >> ${CONFIG_FILE}
}

prepareDatabase() {
  grep = ${CONFIG_FILE} | sed 's/ *= */=/g' | sed $'s/\r//' > /tmp/${CONFIG_FILE}
  source /tmp/${CONFIG_FILE}
  rm /tmp/${CONFIG_FILE}
  "./wait-for-it.sh" --host="${mysql_host}" --port="${mysql_port}" -s -t "${JTSDNS_MYSQL_TIMEOUT}"

  if [ "${JTSDNS_MYSQL_CREATE_TABLES}" == "1" ]; then
    echo "Create database tables for JTSDNS, when not exist"
    mysql --host="${mysql_host}" --port="${mysql_port}" --user="${mysql_user}" --password="${mysql_password}" --database="${mysql_database}" < ${SQL_DUMP}
  fi
}

CONFIG_FILE="JTSDNS.cfg"
SQL_DUMP="jtsdns.sql"
PID=""
main "$@"

