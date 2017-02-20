#!/usr/bin/env bash
#!/bin/bash
# NAME:
#  slackReportInstanceUp.sh 
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
# 0.1       20FEB17     Johan Louwers    Initial creation
#
# LICENSE:
# Copyright (C) 2017  Johan Louwers
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
# Retrieve meta-data from the internal cloud API used to populate the slack message.
# includes the instance type, local IP and the local FQDN a registered in the OPC.
 metaDataInstanceType="$(curl -m 5 --fail -s http://192.0.0.192/1.0/meta-data/instance-type)"
 metaDataLocalIp="$(curl -m 5 --fail -s http://192.0.0.192/1.0/meta-data/local-ipv4)"
 metaDataLocalHost="$(curl -m 5 --fail -s http://192.0.0.192/1.0/meta-data/local-hostname)"

# Retrieve the information needed to connect to slack. This includes the name of your
# channel on slack as well as the code requried to access the incomming webHook at the
# slack website.
 channelName="$(curl -m 5 --fail -s http://192.0.0.192/1.0/user-data/slack_channel)"
 slackCode="$(curl -m 5 --fail -s http://192.0.0.192/1.0/user-data/slack_code)"

# set the slack message title
 msgTitle="Compute Cloud Service"

# Generte the slack message body, this is partially based upon the informtion which
# is retrieved from the meta-data api of the Oracle Public Cloud.
 msgBody="$(uname -s) instance $metaDataLocalHost is online with kernel $(uname -r). Sizing is : $metaDataInstanceType. Instance local cloud IP is $metaDataLocalIp"

# set the slack webhook url based upon a pre-defined first part and the slack code
# which we received from the user-data api from the Oracle Public Cloud. The info
# in the user-data is what you have to provide in the orchestration JSON file
# when provisioing a new instance on the Compute Cloud Service.
 slackUrl="https://hooks.slack.com/services/$slackCode"

# Generate the JSON payload which will be send to the slack webhook. This will
# contain the message we will post to the slack channel.
read -d '' payLoad << EOF
{
        "channel": "#$channelName",
        "username": "Compute Cloud Service",
        "icon_url": "https:\/\/github.com\/louwersj\/Oracle-Linux-Scripting\/raw\/master\/oracle_cloud\/compute_cloud\/postToSlack\/compute_cloud_icon.png",
        "attachments": [
            {
                "fallback": "$msgTitle",
                "color": "good",
                "title": "Instance $(hostname) is created",
                "fields": [{
                    "value": "$msgBody",
                    "short": false
                }]
            }
        ]
    }
EOF

# send the payload to the Slack webhook to ensure the message is posted to slack.
statusCode=$(curl \
        --write-out %{http_code} \
        --silent \
        --output /dev/null \
        -X POST \
        -H 'Content-type: application/json' \
        --data "${payLoad}" ${slackUrl})

echo ${statusCode}
