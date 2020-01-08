#!/usr/bin/env bash
# SPDX-License-Identifier: GPL-2.0
#
# Copyright (C) 2016-2018 Jason A. Donenfeld <Jason@zx2c4.com>. All Rights Reserved.

die() {
	echo "[-] Error: Oops, your account number seems to be wron $1" >&2
	exit 1
}

PROGRAM="${0##*/}"
ARGS=( "$@" )
SELF="${BASH_SOURCE[0]}"
[[ $SELF == */* ]] || SELF="./$SELF"
SELF="$(cd "${SELF%/*}" && pwd -P)/${SELF##*/}"
[[ $UID == 0 ]] || exec sudo -p "[?] $PROGRAM must be run as root. Please enter the password for %u to continue: " -- "$BASH" -- "$SELF" "${ARGS[@]}"

[[ ${BASH_VERSINFO[0]} -ge 4 ]] || die "bash ${BASH_VERSINFO[0]} detected, when bash 4+ required"

set -e
type curl >/dev/null || die "Please install curl and then try again."
type jq >/dev/null || die "Please install jq and then try again."

read -p "[?] Please enter your VPN account number: " -r APIKEY

echo "[+] Contacting VPN_API in Server-FR_PARIS-."

	RESPONSE="$(curl -LsS -k --user admin:password --header 'Content-Type: application/json' --header 'Accept: application/json' -X POST --data '{"server_id":"11","client_description":"0000"}'  https://pierro100-eval-test.apigee.net/vpn_fr/api/clients/add_to_server/11?apikey={"$APIKEY"})" || die "Unable to connect to DAV_VPN_API."
	FIELDS="$(jq -r '.status,.message' <<<"$RESPONSE")" || die "Unable to parse response."
	IFS=$'\n' read -r -d '' STATUS MESSAGE <<<"$FIELDS" || true
	if [[ $STATUS != success ]]; then
		if [[ -n $MESSAGE ]]; then
			die "$MESSAGE"
		else
			die "An unknown API error has occurred. Please try again later."
		fi
	fi
	FIELDS="$(jq -r '.data.server_pubkey,.data.server_dns,.data.client_ipv4,.data.client_privkey,.data.server_port,.data.server_ip' <<<"$RESPONSE")" || die "Unable to parse response."
	IFS=$'\n' read -r -d '' SERVER_PUBKEY SERVER_DNS CLIENT_IPV4 CLIENT_PRIVKEY SERVER_PORT SERVER_IP <<<"$FIELDS" || true

	echo "[++] Writing WriteGuard configuration file to '/etc/wireguard/...conf'."
	umask 077
	mkdir -p /etc/wireguard/
	touch /etc/wireguard/wgFR.conf
	rm -r /etc/wireguard/wgFR.conf
	cat > /etc/wireguard/wgFR.conf <<-_EOF
		[Interface]
		PrivateKey = $CLIENT_PRIVKEY
		Address = $CLIENT_IPV4/32
		DNS = $SERVER_DNS

		[Peer]
		PublicKey = $SERVER_PUBKEY
		Endpoint = $SERVER_IP:$SERVER_PORT
		AllowedIPs = 0.0.0.0/0, ::/0

		_EOF
	
echo "[+++] Contacting VPN_API in Server-PL_WAW-."
    
    	RESPONSE="$(curl -LsS -k --user admin:password --header 'Content-Type: application/json' --header 'Accept: application/json' -X POST --data '{"server_id":"10","client_description":"0000"}'  https://pierro100-eval-test.apigee.net/vpn_fr/api/clients/add_to_server/10?apikey={"$APIKEY"})" || die "Unable to connect to DAV_VPN_API."
	FIELDS="$(jq -r '.status,.message' <<<"$RESPONSE")" || die "Unable to parse response."
	IFS=$'\n' read -r -d '' STATUS MESSAGE <<<"$FIELDS" || true
	if [[ $STATUS != success ]]; then
		if [[ -n $MESSAGE ]]; then
			die "$MESSAGE"
		else
			die "An unknown API error has occurred. Please try again later."
		fi
	fi
	FIELDS="$(jq -r '.data.server_pubkey,.data.server_dns,.data.client_ipv4,.data.client_privkey,.data.server_port,.data.server_ip' <<<"$RESPONSE")" || die "Unable to parse response."
	IFS=$'\n' read -r -d '' SERVER_PUBKEY SERVER_DNS CLIENT_IPV4 CLIENT_PRIVKEY SERVER_PORT SERVER_IP <<<"$FIELDS" || true

	echo "[++++] Writing WriteGuard configuration file to '/etc/wireguard/...conf'."
	umask 077
	mkdir -p /etc/wireguard/
	touch /etc/wireguard/wgPL.conf
	rm -r /etc/wireguard/wgPL.conf
	cat > /etc/wireguard/wgPL.conf <<-_EOF
		[Interface]
		PrivateKey = $CLIENT_PRIVKEY
		Address = $CLIENT_IPV4/32
		DNS = $SERVER_DNS

		[Peer]
		PublicKey = $SERVER_PUBKEY
		Endpoint = $SERVER_IP:$SERVER_PORT
		AllowedIPs = 0.0.0.0/0, ::/0

		_EOF
	

echo "[+++++] Success. The following commands may be run for connecting to VPN:"
	echo
	echo "  \$ wg-quick up wgFR"
	echo "  \$ wg-quick up wgPL"

echo
echo "[!!]Please wait up to 60 seconds for your public key to be added to the servers."

#echo "== Script avec confirmation =="

echo 

confirm()
{
    read -r -p "${1} [y/N] " response

    case "$response" in
        [yY][eE][sS]|[yY]) 
            true
            ;;
        *)
            false
            ;;
    esac
}

if confirm "Do you want to display one of your configuration?"; then
    echo
    read -p "[?] Which configuration Do you want to display * Answer with the country code 'FR':  " -r PAYS
    echo
    cat  /etc/wireguard/wg"$PAYS".conf
    #cat  /etc/wireguard/wgPL.conf
else
    echo "Good!"
fi
