#!/bin/bash

domains=()
for ip in $( hostname -I ); do
	ns=$( host -t ns $ip | awk '{print $5}' )
	[[ "3(NXDOMAIN)" == $ns ]] && continue
	domains+=$( host $ip ${ns%.} | grep pointer | awk '{print $5}' | sed -e '/^$/d;s/\.$//;s/$(hostname -s)\.//' | sort | uniq )
done

echo -e "# local domains" >/etc/postgrey/own_domains
cat <<<"${domains[@]}" | sort | uniq | tr ' ' '\n' >>/etc/postgrey/own_domains
#mv /etc/postgrey/whitelist_clients /etc/postgrey/whitelist_clients.bak
# sed -e '/# local domain/{:a; N; /^$/!ba; r /etc/postgrey/own_domains' -e 'd;}' /etc/postgrey/whitelist_clients.bak >/etc/postgrey/whitelist_clients
sed -e '/# local domain/{:a; N; /^$/!ba; r /etc/postgrey/own_domains' -e 'd;}' /etc/postgrey/whitelist_clients
#if [[ $? -eq 0 ]]; then
#	echo -e "$( date +%c ) own domains updated"
#	systemctl reload postgrey.service
#fi
