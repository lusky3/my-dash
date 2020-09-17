#!/bin/sh
#
# Description: Build my-dash
#

git clone https://github.com/krestaino/my-dash.git /opt/my-dash

cd /opt/my-dash

touch .env

echo -e "API_PORT=$API_PORT" > .env
echo -e "API_KEY=$API_KEY" >> .env
echo -e "UI_ORIGIN=http://localhost:${UI_PORT}" >> .env
echo -e "PLEX_URL=$PLEX_URL" >> .env
echo -e "PLEX_TOKEN=$PLEX_TOKEN" >> .env
echo -e "SEAFILE_URL=$SEAFILE_URL" >> .env
echo -e "SEAFILE_TOKEN=$SEAFILE_TOKEN" >> .env
echo -e "UNIFI_URL=$UNIFI_URL" >> .env
echo -e "UNIFI_USERNAME=$UNIFI_USERNAME" >> .env
echo -e "UNIFI_PASSWORD=$UNIFI_PASSWORD" >> .env
echo -e "NETDATA_DO_URL=$NETDATA_DO_URL" >> .env
echo -e "NETDATA_HOME_URL=$NETDATA_HOME_URL" >> .env
echo -e "UPTIME_ROBOT_KEY=$UPTIME_ROBOT_KEY" >> .env
echo -e "UPTIME_ROBOT_URL=$UPTIME_ROBOT_URL" >> .env
echo -e "UI_PORT=$UI_PORT" >> .env
echo -e "REACT_APP_API_URL=http://localhost:${API_PORT}" >> .env
echo -e "REACT_APP_AUTH_ENDPOINT=$REACT_APP_AUTH_ENDPOINT" >> .env
echo -e "REACT_APP_SEAFILE_ENDPOINT=$REACT_APP_SEAFILE_ENDPOINT" >> .env
echo -e "REACT_APP_PLEX_ENDPOINT=$REACT_APP_PLEX_ENDPOINT" >> .env
echo -e "REACT_APP_UNIFI_ENDPOINT=$REACT_APP_UNIFI_ENDPOINT" >> .env
echo -e "REACT_APP_NETDATA_DO_ENDPOINT=$REACT_APP_NETDATA_DO_ENDPOINT" >> .env
echo -e "REACT_APP_NETDATA_DO_URL=${NETDATA_DO_URL}" >> .env
echo -e "REACT_APP_NETDATA_HOME_ENDPOINT=$REACT_APP_NETDATA_HOME_ENDPOINT" >> .env
echo -e "REACT_APP_NETDATA_HOME_URL=${NETDATA_HOME_URL}" >> .env
echo -e "REACT_APP_UPTIME_ROBOT_ENDPOINT=$REACT_APP_UPTIME_ROBOT_ENDPOINT" >> .env
echo -e "PORT=${UI_PORT}" >> .env

yarn setup

yarn build

yarn upgrade

yarn serve
