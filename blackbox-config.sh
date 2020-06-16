#!/usr/bin/env bash

set -euxo pipefail

#define version
targetversion=$1
set -e
if [[ "${targetversion:-unset}" == "unset" ]]; then
    echo "[*] Please set a version to run it with, eg: blackbox-config.sh v2.0.0"
    exit -1
fi

echo "Will download blackbox"
wget https://github.com/smilofoundation/Smilo-blackbox/releases/download/${targetversion}/blackbox-linux-amd64


echo "Will configure blackbox path and permissions"
mv ./blackbox-linux-amd64 ./blackbox
chmod +x ./blackbox


