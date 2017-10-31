#!/bin/bash
if [[ $# == 0 ]]; then
  if [[ -z $SERVER ]]; then
    locs=(usa eu hk jp in br)
    locs_closer=($({ for loc in "${locs[@]}"; do echo "$(ping -c 3 -i 0.3 "equihash.$loc.nicehash.com" | grep min/avg/max/stddev | perl -pe's!.* ([\d\.]+)/([\d\.]+)/.*!$2!') $loc" & done; wait; } | sort -n | awk '{print $2}'))
    SERVER="equihash.${locs_closer[0]}.nicehash.com:3357"
  fi
  cpu_cnt=$(grep ^processor /proc/cpuinfo | wc -l)
  set -- -l "$SERVER" -u "$WALLET.${WORKER:-$HOSTNAME}" -t "$cpu_cnt"
fi
exec nice -n 18 nheqminer "$@"
