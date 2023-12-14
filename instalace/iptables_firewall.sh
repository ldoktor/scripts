#!/bin/bash
iptables=/sbin/iptables
Dom0IP=
InternetIP=
InternetIf=
LanIP=

echo "1" > /proc/sys/net/ipv4/ip_forward
echo "1" > /proc/sys/net/ipv4/ip_dynaddr
ip route add default via $Dom0IP

$iptables -t nat -A POSTROUTING -o $InternetIf -j MASQUERADE
#$iptables -t nat -A POSTROUTING -o $InternetIf -j SNAT --to $InternetIP
