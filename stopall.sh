#!/bin/bash
pkill geth || true;
pkill blackbox || true;

ps -ef |grep geth
ps -ef |grep blackbox
