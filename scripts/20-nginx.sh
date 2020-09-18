#!/bin/sh
#
# Description: Setup nginx
#

mkdir -p /etc/ssl/private/api
mkdir -p /etc/ssl/certs/api
mkdir -p /etc/nginx/snippets
cp /tmp/api.my-dash.conf /etc/nginx/conf.d/
cp /tmp/my-dash.conf /etc/nginx/conf.d/
cp /tmp/http-to-https.conf /etc/nginx/conf.d/
cp /tmp/proxy-pass.conf /etc/nginx/snippets/
rm /etc/nginx/conf.d/default.conf
mv /etc/nginx/nginx.conf /etc/nginx/nginx.conf.template
cp /tmp/nginx.conf /etc/nginx/

if [ $API_EXTERNAL_PORT != 4400 ]; then
    sed -i 's/4400/${API_EXTERNAL_PORT}/g' /etc/nginx/conf.d/api.my-dash.conf
fi
if [ $UI_EXTERNAL_PORT != 3300 ]; then
    sed -i 's/3300/${API_EXTERNAL_PORT}/g' /etc/nginx/conf.d/my-dash.conf
fi

exit 0