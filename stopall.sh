#!/bin/bash

lsof -i tcp:21000 | awk 'NR!=1 {print $2}' | xargs kill -9 || true;
lsof -i tcp:21001 | awk 'NR!=1 {print $2}' | xargs kill -9 || true;
lsof -i tcp:21002| awk 'NR!=1 {print $2}' | xargs kill -9 || true;
lsof -i tcp:21003 | awk 'NR!=1 {print $2}' | xargs kill -9 || true;
lsof -i tcp:21004 | awk 'NR!=1 {print $2}' | xargs kill -9 || true;
lsof -i tcp:21005 | awk 'NR!=1 {print $2}' | xargs kill -9 || true;
lsof -i tcp:21006 | awk 'NR!=1 {print $2}' | xargs kill -9 || true;


pkill geth || true;
pkill blackbox || true;

ps -ef |grep geth
ps -ef |grep blackbox
