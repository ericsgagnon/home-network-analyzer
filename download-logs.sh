#!/bin/bash

# script modified from:
# https://www.dslreports.com/forum/r32302610-G1100-Router-can-it-be-rebooted-via-an-SSH-command

CACHE_DIR=${XDG_CACHE_HOME}/home-network-analyzer
mkdir -p $XDG_CACHE_HOME/home-network-analyzer
HOST=192.168.1.1
PASSWORD=`cat ~/.config/secrets/FIOS_ROUTER_PASSWORD`
SALT=`curl -k -H "Content-Type: application/json" https://${HOST}/api/login | sed 's/^.*passwordSalt":"\([a-z0-9-]*\)".*$/\1/'` 
digest=`/bin/echo -n "$PASSWORD$SALT" | sha512sum  | awk '{print $1}'`
COOKIE_FILE=${CACHE_DIR}/cookie.txt

curl -k -c ${COOKIE_FILE} -H "Content-Type: application/json" -X POST -d "{\"password\":\"$digest\"}" https://${HOST}/api/login
  
TOKEN=`awk '/XSRF-TOKEN/ {print $NF}' ${COOKIE_FILE}`
  

# system log
curl -o ${CACHE_DIR}/system-log.txt -k -b ${COOKIE_FILE} -H "X-XSRF-TOKEN: $TOKEN" https://${HOST}/api/settings/savelog/0
# security log
curl -o ${CACHE_DIR}/security-log.txt -k -b ${COOKIE_FILE} -H "X-XSRF-TOKEN: $TOKEN" https://${HOST}/api/settings/savelog/1
# advanced log
curl -o ${CACHE_DIR}/advanced-log.txt -k -b ${COOKIE_FILE} -H "X-XSRF-TOKEN: $TOKEN" https://${HOST}/api/settings/savelog/2
# firewall log
curl -o ${CACHE_DIR}/firewall-log.txt -k -b ${COOKIE_FILE} -H "X-XSRF-TOKEN: $TOKEN" https://${HOST}/api/settings/savelog/3
# WAN DHCP log
curl -o ${CACHE_DIR}/wan-dhcp-log.txt -k -b ${COOKIE_FILE} -H "X-XSRF-TOKEN: $TOKEN" https://${HOST}/api/settings/savelog/4
# LAN DHCP log
curl -o ${CACHE_DIR}/lan-dhcp-log.txt -k -b ${COOKIE_FILE} -H "X-XSRF-TOKEN: $TOKEN" https://${HOST}/api/settings/savelog/5


#curl -k -b ${COOKIE_FILE} -H "X-XSRF-TOKEN: $TOKEN" https://${HOST}/api/network
curl -k -b ${COOKIE_FILE} -H "X-XSRF-TOKEN: $TOKEN" https://${HOST}/api/logout
rm ${COOKIE_FILE}