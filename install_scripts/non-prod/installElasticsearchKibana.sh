#!/bin/bash


function runMain {
  installJava
  configureYum
  installElasticsearch
  installKibana
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

function configureYum {
       echo "importing elastic GPG key"
       rpm --import https://artifacts.elastic.co/GPG-KEY-elasticsearch

       echo "elastic repo"
       echo "" >> /etc/yum.repos.d/public-yum-ol6.repo
       echo "[kibana-5.x]" >> /etc/yum.repos.d/public-yum-ol6.repo
       echo "name=Kibana repository for 5.x packages" >> /etc/yum.repos.d/public-yum-ol6.repo
       echo "baseurl=https://artifacts.elastic.co/packages/5.x/yum" >> /etc/yum.repos.d/public-yum-ol6.repo
       echo "gpgcheck=1" >> /etc/yum.repos.d/public-yum-ol6.repo
       echo "gpgkey=https://artifacts.elastic.co/GPG-KEY-elasticsearch" >> /etc/yum.repos.d/public-yum-ol6.repo
       echo "enabled=1" >> /etc/yum.repos.d/public-yum-ol6.repo
       echo "autorefresh=1" >> /etc/yum.repos.d/public-yum-ol6.repo
       echo "type=rpm-md" >> /etc/yum.repos.d/public-yum-ol6.repo
}


function installElasticsearch {
  elasticsearcInstalled=`packageInstalled elasticsearch`
    if [ "$elasticsearcInstalled" = "true" ];
   then
       echo "elasticsearch is already installed"
   else
       echo "installing elasticsearch"
       yum -y install elasticsearch

       startElasticsearch
   fi
}


function installKibana {
  kibanaInstalled=`packageInstalled kibana`
    if [ "$kibanaInstalled" = "true" ];
   then
       echo "Kibana is already installed"
   else
       echo "installing kibana"
       yum -y install kibana

       startKibana
   fi
}


function startElasticsearch {
  echo "configure elasticsearch service"
  chkconfig --add elasticsearch

  echo "starting elasticsearch"
  service elasticsearch start
}


function startKibana {
  echo "configure kibana service"
  chkconfig --add kibana

  echo "starting Kibana"
  service kibana start
}


runMain
