#!/bin/sh
# quick script to install additional tools on a alpine Linux node (container) 
# to be used in combination with n8n. Do note that this script should be run 
# as the user root. A quick and dirty way to login to a runnign container to 
# run this script is the following command: 
#
# docker exec -u root -it 165df9227e0b /bin/sh 
#
# taking into account that 165df9227e0b should be changed to the ID of the 
# actual container you want to enter and become root. 


# Check if the script is run as root
if [ "$(id -u)" -ne 0 ]; then
  echo "You should be root" >&2
  exit 1
fi


# use apk to install additional packages
apk add --no-cache --quiet curl tar ca-certificates


# make sure we have the github cli present
cd /tmp
GH_VERSION=$(curl -s https://api.github.com/repos/cli/cli/releases/latest | sed -n 's/.*"tag_name": "\([^"]*\)".*/\1/p')
curl -L "https://github.com/cli/cli/releases/download/${GH_VERSION}/gh_${GH_VERSION#v}_linux_amd64.tar.gz" -o gh.tar.gz

tar -xzf gh.tar.gz
cd gh_*/bin
mv gh /usr/local/bin/

cd /tmp 
rm -rf gh.tar.gz gh_*

gh --version
