#!/bin/bash
iptables=/sbin/iptables
InternetIP=
FirewallIP=

echo "1" > /proc/sys/net/ipv4/ip_forward

$iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE
#$iptables -A INPUT -s $FirwallIP -j ACCEPT
$iptables -t nat -A PREROUTING -d $InternetIP -j DNAT --to-destination $FirewallIP
