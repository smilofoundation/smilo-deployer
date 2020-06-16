# Smilo Deployer

This repo contains a bunch of shell scripts to aid on creating Smilo local networks for development proposes.

## Download Smilo release:
`
./geth-config.sh v1.9.2.4
`

## Download Blackbox release:
`
./blackbox-config.sh v2.0.0
`

## Fix permissions
`
chmod +x ./chmod.sh
./chmod.sh
`


## Start a network with defaults
`
./main.sh -i true
`

## Tail geth logs
`
tail -f sdata/logs/1.log
`

## Tail blackbox logs
`
tail -f sdata/logs/blackbox1.log
`

## Check block number
`
watch geth --exec "eth.blockNumber" attach ipc:./sdata/ss1/geth.ipc
`

## Check peers connected
`
watch geth --exec "net.peerCount" attach http://localhost:22000
`

## Stop all instances
`
./stopall.sh
`

## Clean up
`
./clean.sh
`

## Generating new Smilo keys
* Disclaimer: The keys located on keys and nodekeys directory are dummy keys created only for this repo and are not supposed to be used on production env.

1. clone go-smilo
2. clone Smilo-blackbox

3. Navigate to cmd extradata scripts folder
`
cd /opt/gocode/src/go-smilo/src/blockchain/smilobft/cmd/extradata/scripts
`

4. Generate smilo and blackbox keys
`
node ./generate_keys.js 5 smilo-deployer
`

5. Move it here:
```
mv /opt/gocode/src/go-smilo/src/blockchain/smilobft/cmd/extradata/scripts/smilo-deployer/keys .
mv /opt/gocode/src/go-smilo/src/blockchain/smilobft/cmd/extradata/scripts/smilo-deployer/nodekeys . 
mv /opt/gocode/src/go-smilo/src/blockchain/smilobft/cmd/extradata/scripts/smilo-deployer/passwords.txt ./config 
mv /opt/gocode/src/go-smilo/src/blockchain/smilobft/cmd/extradata/scripts/smilo-deployer/permissioned-nodes.json ./config 
mv /opt/gocode/src/go-smilo/src/blockchain/smilobft/cmd/extradata/scripts/smilo-deployer/smilo-genesis.json ./genesis 
```
