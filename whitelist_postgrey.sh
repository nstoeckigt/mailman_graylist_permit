#!/bin/bash

domains1=$( host 178.254.26.48 ns1.nstoeckigt.de | grep pointer | awk '{print $5}' | sed -e '/^$/d;s/\.$//;s/srv21\.//' | sort | uniq )
domains2=$( host 178.254.3.229 ns1.nstoeckigt.de | grep pointer | awk '{print $5}' | sed -e '/^$/d;s/\.$//;s/srv21\.//' | sort | uniq )

echo -e "# local domains" >/etc/postgrey/own_domains
echo -e "${domains1[@]} ${domains2[@]}" | sort | uniq | tr ' ' '\n' >>/etc/postgrey/own_domains
mv /etc/postgrey/whitelist_clients /etc/postgrey/whitelist_clients.bak
sed -e '/# local domain/{:a; N; /^$/!ba; r /etc/postgrey/own_domains' -e 'd;}' /etc/postgrey/whitelist_clients.bak >/etc/postgrey/whitelist_clients
if [[ $? -eq 0 ]]; then
	echo -e "$( date +%c ) own domains updated"
	systemctl reload postgrey.service
fi
