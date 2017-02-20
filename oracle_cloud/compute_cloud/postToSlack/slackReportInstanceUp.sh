#!/usr/bin/env bash

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
