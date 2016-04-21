#!/bin/bash
# NAME:
#  installRetinkDB.sh 
#
# DESC:
#  This script is used to install RethinkDB on Oracle Linux 6. 
#  It has only been tested on Linux 6 (in the Oracle Public 
#  cloud) however it is assumed to be able to be used on other
#  Oracle Linux versions and Redhat.
#
#  In general the script can be used to quickly install an 
#  instance of RethinkDB. This can be used to deploy new 
#  machines on an automated or semi-automated manner. It can in
#  theorie be used as a post installation script when deploying
#  new virtual machines in a private or public cloud.
#
#  Part of the script will take care of the installation of the
#  google protocol buffer code as this is generally not on the 
#  yum repositories for Oracle Linux. We will download the source
#  and do a compile to ensure it is in place. 
#
# LOG:
# VERSION---DATE--------NAME-------------COMMENT
# 0.1       16APR16   Johan Louwers    Initial creation
#
# LICENSE:
# Copyright (C) 2016  Johan Louwers
#
# This code is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License
# as published by the Free Software Foundation; either version 2
# of the License, or (at your option) any later version.
#
# This code is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this code; if not, write to the Free Software
# Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.



# installRetinkDBMain is the main function which will call all the sub-parts 
# of the code (for example install and config functions).
 function installRetinkDBMain {
	installRetinkDBPreReq
	installRetinkDBProtoBuf
	installRetinkDBInstall
	installRetinkDBConfig
 } 



# installRetinkDBPreReq will be used to install (if needed) some pre-req 
# packages (like git) as we need it in our code and it will not be triggerd
# by the yum command for the installation of RetinkDB
 function installRetinkDBPreReq {
   logger "installRetinkDB - installRetinkDBPreReq - start pre-req installation" 

   logger "installRetinkDB - installRetinkDBPreReq - install git"   
   yum -y install git

   logger "installRetinkDB - installRetinkDBPreReq - completed pre-req installation"   
 }



# installRetinkDBProtoBuf will Compile Google Protocol Buffers on your machine
# as this is needed by RethinkDB and it is not standard part of the used yum
# repository. Due to this we need to download the code from github and do a 
# clean make and install. If you run into the AM_PROG_AR issue open the 
# configure.ac file in /tmp/protobuf and comment out the associated line
 function installRetinkDBProtoBuf {
   logger "installRetinkDB - installRetinkDBProtoBuf - start installation of Google Protocol Buffers"

   logger "installRetinkDB - installRetinkDBProtoBuf - download code from github"
   cd /tmp
   git clone https://github.com/google/protobuf
   cd /tmp/protobuf

   logger "installRetinkDB - installRetinkDBProtoBuf - run autogen"
   ./autogen.sh

   logger "installRetinkDB - installRetinkDBProtoBuf - run configure"
   ./configure

   logger "installRetinkDB - installRetinkDBProtoBuf - run make"
   make

   logger "installRetinkDB - installRetinkDBProtoBuf - run make check"
   make check 

   logger "installRetinkDB - installRetinkDBProtoBuf - run make install"
   make install

   logger "installRetinkDB - installRetinkDBProtoBuf - completed installation of Google Protocol Buffers"
 }



# installRetinkDBInstall will do the main installation steps needed to get
# rethinkDB on your machine. It will download the repository from rethinkDB
# and do the actual installation. 
 function installRetinkDBInstall {
   #Ensure we clean the yum cache. 
   yum clean expire-cache

   #Getting the RethinkDB repo file to be able to install RethinkDB via yum
   wget https://download.rethinkdb.com/centos/6/x86_64/rethinkdb.repo -O /etc/yum.repos.d/rethinkdb.repo

   #Install rethinkDB via YUM
   yum -y install rethinkdb

   #Remove the repo file used to install RethinkDB
   rm -f /etc/yum.repos.d/rethinkdb.repo

   #Ensure we clean the yum cache. 
   yum clean expire-cache
 }



# installRetinkDBConfig will do the configuration of RethinkDB on your machine
# after the installation of the "raw" code. 
 function installRetinkDBConfig { 
   #Copy the defailt configuration example and use it for instance one. 
   cp /etc/rethinkdb/default.conf.sample /etc/rethinkdb/instances.d/instance1.conf
}


#Start the post configuration by calling function runPostConfig
installRetinkDBMain
