#!/bin/bash
# NAME:
#  install_dev_nginx.sh 
#
# DESC:
#  To be used to install a nginx server in a very quick and dirty manner.
#  This is only for building a quick and dirty test/dev server and you should
#  never .... never never never .... use this for a production setup. 
#  You will need nginx-1.8.1-1.el7.ngx.x86_64.rpm which can be downloaded 
#  from the NGINX website. You need to ensure that this file is in the same 
#  directory as this script to make the script work. 
#
# This script is tested for Oracle Linux.
#
#
# LOG:
# VERSION---DATE--------NAME-------------COMMENT
# 0.1       26FEB16   Johan Louwers    Initial creation
#
# LICENSE:
# Copyright (C) 2015  Johan Louwers
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
# *
# */

function installNginx {
   firewallDisable
   deployNginx
   configNginx
 }


function firewallDisable {
#FIREWALL CHANGES
  # Stop and disable iptables / ip6tables. We will need to make this more correct by simply adding
  # a rule for port 80 in iptables and ip6tables. However, for testing we will disable the FW.
  logger "installNginx - firewallDisable - begin"

  systemctl stop iptables
  systemctl disable iptables
  systemctl stop ip6tables
  systemctl disable ip6tables
  
  logger "installNginx - firewallDisable - completed"
 }



function deployNginx {
# NGINX INSTALLATION
  # install nginx and start/enable this in systemctl. You will need nginx-1.8.1-1.el7.ngx.x86_64.rpm
  # for this which you can download from the nginx website. 
  logger "installNginx - deployNginx - begin"

  rpm -ivh nginx-1.8.1-1.el7.ngx.x86_64.rpm
  systemctl start nginx.service
  systemctl enable nginx.service

  logger "installNginx - deployNginx - completed"  
 }



function configNginx {
# NGINX CONFIG
  logger "installNginx - configNginx - begin" 

  # create a location to store the data. 
  mkdir /var/www/nginxdev

  # make a backup of the default config and remove the default config as we will replace it with our own
  cp /etc/nginx/conf.d/default.conf default.conf.backup
  rm -f /etc/nginx/conf.d/default.conf

  # build the config file
  echo "server {" >> /etc/nginx/conf.d/nginxdev.conf
  echo "    listen       80;">> /etc/nginx/conf.d/nginxdev.conf
  echo "    server_name  localhost;" >> /etc/nginx/conf.d/nginxdev.conf
  echo "    location / { " >> /etc/nginx/conf.d/nginxdev.conf
  echo "        root   /var/www/nginxdev; " >> /etc/nginx/conf.d/nginxdev.conf
  echo "        index  index.html index.htm; ">> /etc/nginx/conf.d/nginxdev.conf
  echo "    } " >> /etc/nginx/conf.d/nginxdev.conf
  echo "    error_page   500 502 503 504  /50x.html;" >> /etc/nginx/conf.d/nginxdev.conf
  echo "    location = /50x.html { " >> /etc/nginx/conf.d/nginxdev.conf
  echo "        root   /usr/share/nginx/html; ">> /etc/nginx/conf.d/nginxdev.conf
  echo "    } " >> /etc/nginx/conf.d/nginxdev.conf
  echo "} " >> /etc/nginx/conf.d/nginxdev.conf

  # restart nginx to ensure the new config file is loaded
  systemctl restart nginx
  logger "installNginx - configNginx - completed"   
 }

installNginx
