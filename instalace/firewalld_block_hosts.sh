#!/bin/bash
# credits to Steven Hale
# http://www.stevenhale.co.uk/main/2015/09/blocking-facebook-with-firewalld/

# Use https://ipinfo.io/ to get 'asn' (association number)

#FACEBOOK=AS32934
#TWITTER=AS13414
#AMAZON=AS14618
#AMAZON=AS16509 - hosting (tiktok)

# Add a firewall rule for each entry.
RULES="$(firewall-cmd --direct --get-all-rules)"
for company in AS32934 AS13414; do
    for ip in $(whois -h whois.radb.net '!g'"$company" | grep /); do
		if grep -q " $ip " <<< "$RULES"; then
			#echo "$company:$ip already there"
			true
		else
			#echo "$company:$ip disabling"
			firewall-cmd --direct --add-rule ipv4 filter OUTPUT_direct 0 -d $ip -j DROP &> /dev/null
		fi
    done
done
