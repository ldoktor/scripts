#!/bin/bash
# credits to Steven Hale
# http://www.stevenhale.co.uk/main/2015/09/blocking-facebook-with-firewalld/

# Use https://ipinfo.io/ to get 'asn' (association number)

#FACEBOOK=AS32934
#TWITTER=AS13414
#AMAZON=AS14618

# Add a firewall rule for each entry.
for company in AS32934 AS13414; do
    for ip in $(whois -h whois.radb.net '!g'"$company" | grep /); do
        firewall-cmd --direct --add-rule ipv4 filter OUTPUT_direct 0 -d $ip -j DROP &> /dev/null
    done
done
