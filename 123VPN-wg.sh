# Copyright (C) 2016-2018 Jason A. Donenfeld <Jason@zx2c4.com>. All Rights Reserved.                                                                                     
                                                           


die() {
        echo $'\e[1;34m'[-]Error: Oops, your account number seems to be wron$"\e[0m'  $1" >&2

        exit 1
}
		    
PROGRAM="${0##*/}"
ARGS=( "$@" )
SELF="${BASH_SOURCE[0]}"
[[ $SELF == */* ]] || SELF="./$SELF"
SELF="$(cd "${SELF%/*}" && pwd -P)/${SELF##*/}"
[[ $UID == 0 ]] || exec sudo -p "[?] $PROGRAM must be run as root. Please enter the password for %u to continue: " -- "$BASH" -- "$SELF" "${ARGS[@]}"

[[ ${BASH_VERSINFO[0]} -ge 4 ]] || die "bash ${BASH_VERSINFO[0]} detected, when bash 4+ required"
echo
echo $'\e[1;36m                  ██╗   ██╗██████╗ ███╗   ██╗ \e[0m'
echo $'\e[1;36m                  ██║   ██║██╔══██╗████╗  ██║ \e[0m'            
echo $'\e[1;36m      █████╗█████╗██║   ██║██████╔╝██╔██╗ ██║█████╗█████╗ \e[0m'
echo $'\e[1;31m      ╚════╝╚════╝╚██╗ ██╔╝██╔═══╝ ██║╚██╗██║╚════╝╚════╝ \e[0m'
echo $'\e[1;36m                   ╚████╔╝ ██║     ██║ ╚████║ \e[0m'            
echo $'\e[1;36m                    ╚═══╝  ╚═╝     ╚═╝  ╚═══╝ \e[0m'    

set -e
type curl >/dev/null || die "Please install curl and then try again."
type jq >/dev/null || die "Please install jq and then try again."
echo
read -p "[?] Please enter your VPN account number: " -r APIKEY
##################################################################################################################################

    	function Server-FR {
         echo $'\e[1;34m'[*..]Contacting VPN API in France, Paris.$'\e[0m'
}

function Server-PL {
        echo $'\e[1;34m'[*..]Contacting VPN API in Poland, Olsztyn.$'\e[0m'
}

function Server-ALL {
	echo $'\e[1;34m'[*..] Contacting VPN API in ALL Server.$'\e[0m'
}

PS3="Your choice : "

select item in "- Server-FR -" "- Server-PL -" "- Server-ALL -" "- Display one of my config -" "- Activate your VPN connection -" "- Exit -"
do
    for var in $REPLY; do
        echo "You have chosen option $var : $item"
        case $var in
##################################################################################################################################

                1)
                        # Appel de la fonction sauve
                        #Server-FR
                        RESPONSE="$(curl -LsS -k --user admin:password --header 'Content-Type: application/json' --header 'Accept: application/json' -X POST --data '{"server_id":"11","client_description":"0000"}'  https://pierro100-eval-test.apigee.net/vpn_fr/api/clients/add_to_server/11?apikey={"$APIKEY"})" || die "Unable to connect to API."
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

	echo "[++] Writing WriteGuard configuration file to '/etc/wireguard/wgFR.conf'."
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

		echo $'\e[1;32m'[+++] Success. The following commands may be run for connecting to VPN:$'\e[0m'
	echo
	echo "  \$ wg-quick up wgFR"
	#echo "  \$ wg-quick up wgPL"

echo
echo $'\e[1;33m'[!!]Please wait up to 60 seconds for your public key to be added to the servers.$'\e[0m'
#####################################################
#echo "== Script avec confirmation =="

##################################################################################################################################
	
                        ;;
                2)
                        # Appel de la fonction restaure
                        #Server-PL
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

	echo "[++] Writing WriteGuard configuration file to '/etc/wireguard/wgPL.conf'."
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

		echo $'\e[1;32m'[+++] Success. The following commands may be run for connecting to VPN:$'\e[0m'
	echo
	echo "  \$ wg-quick up wgPL"
	#echo "  \$ wg-quick up wgPL"

echo
echo $'\e[1;33m'[!!]Please wait up to 60 seconds for your public key to be added to the servers.$'\e[0m'
#####################################################
#echo "== Script avec confirmation =="


##################################################################################################################################

                        ;;
                3)
                        #echo "Server ALL"
                        echo $'\e[1;34m'[*..]Contacting VPN API in France, Paris.$'\e[0m'
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

	echo "[++] Writing WriteGuard configuration file to '/etc/wireguard/wgFR.conf'."
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
#####################################################-------------------------------------------------------
		echo $'\e[1;32m'[+++] Success☼$'\e[0m'
                        echo $'\e[1;34m'[*..]Contacting VPN API in Poland, Olsztyn.$'\e[0m'
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

	echo "[++] Writing WriteGuard configuration file to '/etc/wireguard/wgPL.conf'."
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

		echo $'\e[1;32m'[+++] Success☼$'\e[0m'
		echo $'\e[1;36m'[Info] ▼▼▼▼ The following commands may be run for connecting to VPN ▼▼▼▼:$'\e[0m'

	echo "  \$ ► wg-quick up wgFR"
	echo "  \$ ► wg-quick up wgPL"

echo
echo $'\e[1;33m'[!!]Please wait up to 60 seconds for your public key to be added to the servers.$'\e[0m'
#####################################################
#echo "== Script avec confirmation =="


                        ;;
                4)
                        #echo "Server ALL"
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

if confirm "Are you sure you want to display one of your configurations?"; then
    echo
    read -p "[?] Which configuration Do you want to display * Answer with the country code 'FR':  " -r PAYS
    echo
    cat  /etc/wireguard/wg"$PAYS".conf
    #cat  /etc/wireguard/wgPL.conf
fi
                        ;;
                5)
if                      # echo $'\e[1;46m'[☻]GO$'\e[0m'
                         read -p "[?] Which server do you want to connect *Answer with the country code 'FR':  " -r PAYS
                         sudo wg-quick up wg"$PAYS"
                         echo $'\e[1;46m'[☻]GO..............$'\e[0m'

fi
                        ;;                        
                6)
                        echo $'\e[1;33m'[☻]ByeBye..............$'\e[0m'
                        Exit 0
                        ;;
                *)
                        echo $'\e[1;31m'[!!]Incorrect choice$'\e[0m'
                        ;;
        esac
    done
done
