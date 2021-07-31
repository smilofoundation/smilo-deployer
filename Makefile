#!/usr/bin/env bash

# Copyright 2021 The Smilo Authors

PACKAGES = $(shell find ./src -type d -not -path '\./src')

COMPANY=smilo
AUTHOR=Smilo Developers
NAME=smilo

copy:
	cp ${GOPATH}/src/go-smilo/build/bin/geth .

download_197:
	./geth-config.sh v1.9.7.1

download_blackbox_2:
	./blackbox-config.sh v2.0.0

fix_permissions:
	chmod +x ./chmod.sh; ./chmod.sh

start_smilobft:
	./main.sh -i true

start_tendermint:
	./main.sh -i true -c tendermint-dao -p 0

start_istanbul:
	./main.sh -i true -c istanbul-dao -p 0

start_smilobftdao:
	./main.sh -i true -c smilobft-dao -p 0

logs:
	tail -f sdata/logs/1.log

logs_b:
	tail -f sdata/logs/blackbox1.log

check_block_number:
	watch geth --exec "eth.blockNumber" attach ipc:./sdata/ss1/geth.ipc

check_peers_connected:
	watch geth --exec "net.peerCount" attach http://localhost:22000

stop:
	./stopall.sh

clean:
	./clean.sh

generate_keys:
	cd ${GOPATH}/src/go-smilo/src/blockchain/smilobft/cmd/extradata/scripts
	node ./generate_keys.js 5 smilo-deployer

move_keys:
	mv ${GOPATH}/src/go-smilo/src/blockchain/smilobft/cmd/extradata/scripts/smilo-deployer/keys .
	mv ${GOPATH}/src/go-smilo/src/blockchain/smilobft/cmd/extradata/scripts/smilo-deployer/nodekeys .
	mv ${GOPATH}/src/go-smilo/src/blockchain/smilobft/cmd/extradata/scripts/smilo-deployer/passwords.txt ./config
	mv ${GOPATH}/src/go-smilo/src/blockchain/smilobft/cmd/extradata/scripts/smilo-deployer/permissioned-nodes.json ./config
	mv ${GOPATH}/src/go-smilo/src/blockchain/smilobft/cmd/extradata/scripts/smilo-deployer/smilo-genesis.json ./genesis