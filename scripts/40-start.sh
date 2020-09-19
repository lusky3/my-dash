#!/bin/sh
#
# Description: Start my-dash
#
echo -e ""
echo -e "40-start.sh: Starting nginx."
echo -e ""
/usr/sbin/nginx -c /etc/nginx/nginx.conf
echo -e ""
echo -e "40-start.sh: Starting yarn serve."
echo -e ""
cd /opt/my-dash
yarn serve