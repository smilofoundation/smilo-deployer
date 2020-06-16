#!/usr/bin/env bash

set -euxo pipefail

#define version
targetversion=$1
set -e
if [[ "${targetversion:-unset}" == "unset" ]]; then
    echo "[*] Please set a version to run it with, eg: geth-config.sh v1.8.23.3"
    exit -1
fi

echo "Will download GETH"
wget https://github.com/smilofoundation/go-smilo/releases/download/${targetversion}/geth-linux-amd64

echo "Will configure GETH path and permissions"
mv ./geth-linux-amd64 ./geth || true
chmod +x ./geth

echo "Will run GETH version check command"

./geth version

