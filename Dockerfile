FROM alpine:3

RUN apk update \
    && apk upgrade \
    && apk add \
    git \
    curl \
    nodejs \
    yarn
    
COPY run.sh /

RUN chmod +x /run.sh

ENV DOMAIN=domain.local \
    API_PORT=4000 \
    API_KEY=YOUR_AWESOME_AND_TOTALLY_SECRET_API_KEY \
    PLEX_URL=http://localhost:32400 \
    PLEX_TOKEN=YOUR_PLEX_TOKEN \
    SEAFILE_URL=http://localhost:8000 \
    SEAFILE_TOKEN=YOUR_SEAFILE_TOKEN \
    UNIFI_URL=http://localhost:8443 \
    UNIFI_USERNAME=YOUR_UNIFI_USERNAME \
    UNIFI_PASSWORD=YOUR_UNIFI_PASSWORD \
    NETDATA_DO_URL=http://localhost:19998 \
    NETDATA_HOME_URL=http://localhost:19999 \
    UPTIME_ROBOT_KEY=YOUR_UPTIME_ROBOT_API_KEY \
    UPTIME_ROBOT_URL=https://api.uptimerobot.com/v2/getMonitors \
    UI_PORT=3000 \
    REACT_APP_AUTH_ENDPOINT=/auth \
    REACT_APP_SEAFILE_ENDPOINT=/seafile \
    REACT_APP_PLEX_ENDPOINT=/plex \
    REACT_APP_UNIFI_ENDPOINT=/unifi \
    REACT_APP_NETDATA_DO_ENDPOINT=/netdata-do \
    REACT_APP_NETDATA_HOME_ENDPOINT=/netdata-home \
    REACT_APP_UPTIME_ROBOT_ENDPOINT=/uptime-robot

EXPOSE 3000 4000

CMD ["/bin/sh /run.sh"]
