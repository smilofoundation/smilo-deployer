#!/bin/bash

SCRIPT=$(basename ${BASH_SOURCE[0]})
QTD=5
CONSENSUS=
GO_SMILO=v1.9.2.4
BLACKBOX=v2.0.0
BLACKBOX_QTD=5
INIT=false

# define command exec location
blackboxCMD="./blackbox"
gethCMD="./geth"

usage() {
  echo "Usage: $SCRIPT"
  echo "Optional command line arguments"
  echo "-c <number>  -- CONSENSUS to use. eg: sport"
  echo "-q <number>  -- QTD of validators to run. eg: 5"
  echo "-s <number>  -- GO_SMILO version. eg: v1.9.2.4"
  echo "-b <number>  -- BLACKBOX version. eg: v2.0.0"
  echo "-p <number>  -- QTD of blackbox instances to run. eg: 5"
  echo "-i <number>  -- INIT instances (true or false). eg: true"

  exit 1
}

while getopts "h?c:q:s:b:p:i:" args; do
case $args in
    h|\?)
      usage;
      exit;;
    c ) CONSENSUS=${OPTARG};;
    q ) QTD=${OPTARG};;
    s ) GO_SMILO=${OPTARG};;
    b ) BLACKBOX=${OPTARG};;
    p ) BLACKBOX_QTD=${OPTARG};;
    i ) INIT=${OPTARG};;
  esac
done

set -euxo pipefail

#init smilo
init_smilo_func() {
  echo "will init go-smilo node $i ..."
  rm -rf sdata/ss"$i"
  echo "[*] Configuring node $i"
  mkdir -p sdata/ss"$i"/{keystore,geth}
  cp config/permissioned-nodes.json sdata/ss"$i"/static-nodes.json
  cp config/blacklisted-addresses.json sdata/ss"$i"/geth/blacklisted-addresses.json
  cp config/permissioned-nodes.json sdata/ss"$i"/
  cp keys/key"$i" sdata/ss"$i"/keystore
  cp nodekeys/nodekey"$i" sdata/ss"$i"/geth/nodekey
  $gethCMD --datadir sdata/ss"$i" init genesis/"$CONSENSUS"smilo-genesis.json

  echo "init go-smilo node, done."
}

#init blackbox
init_blackbox_func() {
  echo "init blackbox node $i ..."

  DDIR="sdata/c$i"
  currentDir=$(pwd)
  mkdir -p "${DDIR}"
  mkdir -p sdata/logs
  cp "keys/tm$i.pub" "${DDIR}/tm.pub"
  cp "keys/tm$i.key" "${DDIR}/tm.key"
  rm -f "${DDIR}/tm.ipc"
  #change tls to "strict" to enable it (don't forget to also change http -> https)
  cat <<EOF > ${DDIR}/blackbox-config${i}.json
{
    "useWhiteList": false,
    "server": {
        "port": 900${i},
        "hostName": "http://localhost",
        "sslConfig": {
            "tls": "OFF",
            "generateKeyStoreIfNotExisted": true,
            "serverKeyStore": "${currentDir}/sdata/c${i}/server${i}-keystore",
            "serverKeyStorePassword": "smilo-deployer",
            "serverTrustStore": "${currentDir}/sdata/c${i}/server-truststore",
            "serverTrustStorePassword": "smilo-deployer",
            "serverTrustMode": "TOFU",
            "knownClientsFile": "${currentDir}/sdata/c${i}/knownClients",
            "clientKeyStore": "${currentDir}/sdata/c${i}/client${i}-keystore",
            "clientKeyStorePassword": "smilo-deployer",
            "clientTrustStore": "${currentDir}/sdata/c${i}/client-truststore",
            "clientTrustStorePassword": "smilo-deployer",
            "clientTrustMode": "TOFU",
            "knownServersFile": "${currentDir}/sdata/c${i}/knownServers"
        }
    },
    "peer": [
        {
            "url": "http://localhost:9001"
        },
        {
            "url": "http://localhost:9002"
        },
        {
            "url": "http://localhost:9003"
        },
        {
            "url": "http://localhost:9004"
        },
        {
            "url": "http://localhost:9005"
        }
    ],
    "keys": {
        "passwords": [],
        "keyData": [
            {
                "config": "${currentDir}/sdata/c${i}/tm.key",
                "publicKey": "${currentDir}/sdata/c${i}/tm.pub"
            }
        ]
    },
    "alwaysSendTo": [],
    "socket": "${currentDir}/sdata/c${i}/tm.ipc",
    "dbfile": "${currentDir}/sdata/c${i}/blackbox.db",
    "peersdbfile": "${currentDir}/sdata/c${i}/blackbox-peers.db"
}
EOF

  echo "init blackbox node, done."
}

# start smilo
start_smilo_func() {
  echo "starting go-smilo node $i ..."
#  bindTo=127.0.0.1
  NETWORK_ID=$(cat ./genesis/smilo-genesis.json | grep chainId | awk -F " " '{print $2}' | awk -F "," '{print $1}')
  echo "[*] Starting Smilo nodes with ChainID and NetworkId of $NETWORK_ID"
  ARGS="--verbosity 4 --allow-insecure-unlock  --permissioned=false --smilobft.blockperiod 1 --smilobft.requesttimeout 10000 --syncmode full --mine --miner.gasprice 1 --miner.threads 1 --rpc --rpcaddr 127.0.0.1 --rpcapi admin,db,eth,debug,miner,net,shh,txpool,personal,web3,smilobft,sport --rpccorsdomain \"*\" --ws --wsaddr 127.0.0.1 --wsorigins '*' --wsapi personal,admin,db,eth,net,web3,miner,shh,txpool,debug"

  VAULT_IPC=sdata/c"$i"/tm.ipc nohup $gethCMD --datadir sdata/ss"$i" $ARGS --rpcport $((21999+$i)) --wsport $((22999+$i)) --port $((20999+$i)) --unlock 0 --password ./config/passwords.txt 2>>sdata/logs/"$i".log &

  EXEC_PID=$!
  echo "started go-smilo node, pid=$EXEC_PID"
}

# start blackbox
start_blackbox_func() {
  echo "starting blackbox node $i ..."

  DDIR="sdata/c$i"
  CMD="${blackboxCMD} -configfile $DDIR/blackbox-config$i.json"
  echo "$CMD >> sdata/logs/blackbox$i.log 2>&1 &"
  ${CMD} >> "sdata/logs/blackbox$i.log" 2>&1 &
  sleep 1

  echo "Waiting until Blackbox node $i is running..."
  DOWN=true
  k=10
  while ${DOWN}; do
      sleep 1
      DOWN=false
      if [ ! -S "sdata/c${i}/tm.ipc" ]; then
          echo "Node ${i} is not yet listening on tm.ipc"
          DOWN=true
      fi

      set +e
      result=$(printf 'GET /upcheck HTTP/1.0\r\n\r\n' | nc -Uv sdata/c"${i}"/tm.ipc | tail -n 1)
      set -e
      if [ ! "${result}" == "I'm up!" ]; then
          echo "Node ${i} is not yet listening on http"
          DOWN=true
      fi

      k=$((k - 1))
      if [ ${k} -le 0 ]; then
          echo "Blackbox is taking a long time to start.  Look at the Blackbox logs in sdata/logs/ for help diagnosing the problem."
      fi
      echo "Waiting until all Blackbox nodes are running..."

      sleep 1
  done

  echo "Blackbox node $i started"

}

if [ "${INIT}" == "true" ]; then

  for i in $(seq 1 "$BLACKBOX_QTD"); do
    init_blackbox_func "$i"
  done

  for i in $(seq 1 "$QTD"); do
    init_smilo_func "$i"
  done

fi

sleep 2

for i in $(seq 1 "$BLACKBOX_QTD"); do
  start_blackbox_func "$i"
done

for i in $(seq 1 "$QTD"); do
  start_smilo_func "$i"
done

echo "done starting Smilo stack"
exit 0
