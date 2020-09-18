#!/bin/sh
#
# Description: Setup the docker environment
#

/bin/sh /scripts/10-my-dash.sh
/bin/sh /scripts/20-nginx.sh
/bin/sh /scripts/30-domain.sh
/bin/sh /scripts/40-start.sh
echo -e "We should nevwer get here. 40-start.sh failed."
exit 1