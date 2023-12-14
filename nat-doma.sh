#!/bin/sh
ifup eth2
ifconfig eth0 192.168.0.1
IPTABLES=/sbin/iptables
/sbin/depmod -a
echo "1" > /proc/sys/net/ipv4/ip_dynaddr
echo "1" > /proc/sys/net/ipv4/ip_forward
#Turn NAT on.
$IPTABLES -t nat -A POSTROUTING -o eth2 -j MASQUERADE
#iptables -t nat -A POSTROUTING -o eth2 -j SNAT --to 147.229.217.126
