#!/bin/bash


function runMain {
  installJava
  installElasticsearch
  startElasticsearch
}



function packageInstalled () {
  numberOfPackages=`yum list installed | grep $1 | wc -l`
  if [ "$numberOfPackages" -gt "0" ];
   then
       echo "true"
   else
       echo "false"
  fi
}



function installJava {
  javaInstalled=`packageInstalled java-1.8.0-openjdk`
  if [ "$javaInstalled" = "true" ];
   then
       echo "java is already installed"
   else
      echo "installing java"
      yum -y install java-1.8.0-openjdk
  fi
}



function installElasticsearch {
  elasticsearcInstalled=`packageInstalled elasticsearch`
    if [ "$elasticsearcInstalled" = "true" ];
   then
       echo "elasticsearch is already installed"
   else
       echo "importing elastic GPG key"
       rpm --import http://packages.elastic.co/GPG-KEY-elasticsearch

       echo "adding elastic repository to yum"
       echo "" >> /etc/yum.repos.d/public-yum-ol6.repo
       echo "[elastic]" >> /etc/yum.repos.d/public-yum-ol6.repo
       echo "name=Elasticsearch repository for 2.x packages" >> /etc/yum.repos.d/public-yum-ol6.repo
       echo "baseurl=http://packages.elastic.co/elasticsearch/2.x/centos" >> /etc/yum.repos.d/public-yum-ol6.repo
       echo "gpgcheck=1" >> /etc/yum.repos.d/public-yum-ol6.repo
       echo "gpgkey=http://packages.elastic.co/GPG-KEY-elasticsearch" >> /etc/yum.repos.d/public-yum-ol6.repo
       echo "enabled=1" >> /etc/yum.repos.d/public-yum-ol6.repo

       echo "installing elasticsearch"
       yum -y install elasticsearch
   fi
}


function startElasticsearch {
  echo "starting elasticsearch"
  service elasticsearch start
}

runMain
