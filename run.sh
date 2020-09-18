#!/bin/sh
#
# Description: Setup the docker environment
#

echo -e "#### Starting my-dash setup. ####"
/bin/sh /scripts/10-my-dash.sh
echo -e "#### Starting nginx setup. ####"
/bin/sh /scripts/20-nginx.sh
echo -e "#### Starting TLS certificate setup. ####"
/bin/sh /scripts/30-domain.sh
echo -e "#### Starting my-dash. ####"
/bin/sh /scripts/40-start.sh
echo -e "!!!! We should nevwer get here. 40-start.sh failed. !!!!"
exit 1