#!/usr/bin/env bash
set -e

# Enable core dumps. Requires privileged mode.
if [[ "${RELAY_ENABLE_COREDUMPS:-}" == "1" ]]; then
  mkdir -p /var/dumps
  chmod a+rwx /var/dumps
  echo '/var/dumps/core.%h.%e.%t' > /proc/sys/kernel/core_pattern
  ulimit -c unlimited
fi

# If tmp config folder found, copy file from there to work folder
mkdir -p /work/.relay/ && chown -R relay:relay /work
(cp ${CONFIG_FILE_PATH} /work/.relay/config.yml) || true
(cp /geoip/GeoLite2-City.mmdb /work/.relay/GeoLite2-City.mmdb) || true

# For compatibility with older images
if [ "$1" == "bash" ]; then
  set -- bash
elif [ "$(id -u)" == "0" ]; then
  set -- gosu relay /bin/relay "$@"
else
  set -- /bin/relay "$@"
fi

exec "$@"
