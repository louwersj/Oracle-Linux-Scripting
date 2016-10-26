#!/bin/bash
#
# NAME:
#  config_elasticsearchNetHost.sh 
#
# DESC:
#  This is script is used to configure the network.host settings for 
#  elasticsearch to ensure it is listening to the IP set for local-ipv4
#  in the Oracle public IaaS cloud on Oracle Linux. We will retrieve
#  the local IPV4 adress and add it to the elasticsearch configuration 
#  file /etc/elasticsearch/elasticsearch.yml after which we restart
#  elasticsearch to ensure the setting new setting is active. This will
#  ensure that elasticsearch is now accessible outside localhost

echo "network.host: $(curl -s http://192.0.0.192/1.0/meta-data/local-ipv4)" >> /etc/elasticsearch/elasticsearch.yml
service elasticsearch restart
