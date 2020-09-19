#!/bin/sh
#
# Description: Setup nginx
#
echo -e ""
echo -e "20-nginx.sh: Creating nginx directories."
echo -e ""
mkdir -p /etc/ssl/private/api
mkdir -p /etc/ssl/certs/api
mkdir -p /etc/nginx/snippets
echo -e ""
echo -e "20-nginx.sh: Move configuration"
echo -e ""
#cp /tmp/api.my-dash.conf /etc/nginx/conf.d/api.my-dash.conf
cp /tmp/my-dash.conf /etc/nginx/conf.d/my-dash.conf
cp /tmp/http-to-https.conf /etc/nginx/conf.d/http-to-https.conf
cp /tmp/proxy-pass.conf /etc/nginx/snippets/proxy-pass.conf
if [[ -f /etc/nginx/conf.d/default.conf ]];then
    rm /etc/nginx/conf.d/default.conf
fi
if [[ -f /etc/nginx/nginx.conf ]];then
    mv /etc/nginx/nginx.conf /etc/nginx/nginx.conf.template
fi
cp /tmp/nginx.conf /etc/nginx/nginx.conf

echo -e ""
echo -e "20-nginx.sh: Changing ports (if needed)."
echo -e ""
if [ $API_EXTERNAL_PORT != 4400 ]; then
    sed -i 's/4400/${API_EXTERNAL_PORT}/g' /etc/nginx/conf.d/my-dash.conf
fi
if [ $UI_EXTERNAL_PORT != 3300 ]; then
    sed -i 's/3300/${API_EXTERNAL_PORT}/g' /etc/nginx/conf.d/my-dash.conf
fi
echo -e ""
echo -e "20-nginx.sh: Done nginx setup."
echo -e ""

exit 0