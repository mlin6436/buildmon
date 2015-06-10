#!/bin/bash

sudo iptables -I INPUT -s jenkins.bbc.co.uk -j ACCEPT
sudo iptables -I OUTPUT -d jenkins.bbc.co.uk -j ACCEPT
sudo iptables -I INPUT -s ci-app.int.bbc.co.uk -j ACCEPT
sudo iptables -I OUTPUT -d ci-app.int.bbc.co.uk -j ACCEPT
sudo iptables -I INPUT -s ci-app.test.bbc.co.uk -j ACCEPT
sudo iptables -I OUTPUT -d ci-app.test.bbc.co.uk -j ACCEPT

sudo iptables -I INPUT -s ns1.tcams.bbc.co.uk -j ACCEPT
sudo iptables -I OUTPUT -d ns1.tcams.bbc.co.uk -j ACCEPT
sudo iptables -I INPUT -s ns1.thdow.bbc.co.uk -j ACCEPT
sudo iptables -I OUTPUT -d ns1.thdow.bbc.co.uk -j ACCEPT
sudo iptables -I INPUT -s ns1.rbsov.bbc.co.uk -j ACCEPT
sudo iptables -I OUTPUT -d ns1.rbsov.bbc.co.uk -j ACCEPT

sudo iptables -I INPUT -s 212.58.251.198 -j ACCEPT
sudo iptables -I OUTPUT -d 212.58.251.198 -j ACCEPT

sudo iptables -I INPUT -s fonts.googleapis.com -j ACCEPT
sudo iptables -I OUTPUT -d fonts.googleapis.com -j ACCEPT
sudo iptables -I INPUT -s netdna.bootstrapcdn.com -j ACCEPT
sudo iptables -I OUTPUT -d netdna.bootstrapcdn.com -j ACCEPT
sudo iptables -I INPUT -s fonts.gstatic.com -j ACCEPT
sudo iptables -I OUTPUT -d fonts.gstatic.com -j ACCEPT

#sudo iptables -A OUTPUT -p udp --dport 53 -j ACCEPT
#sudo iptables -A OUTPUT -p tcp --dport 53 -j ACCEPT

sudo iptables -I INPUT -s 127.0.0.1/24 -j ACCEPT
sudo iptables -I OUTPUT -d 127.0.0.1/24 -j ACCEPT

sudo iptables -P INPUT DROP
sudo iptables -P OUTPUT DROP

sudo iptables -L
