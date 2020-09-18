#!/bin/sh
#
# Description: Setup achme.sh and obtain Let'sEncrypt certificate
#
if [[ -z ${DOMAIN} ]]; then
    echo "20-domain.sh: Domain ENV is empty. Kill script."
    exit 1
fi

if [ -z $ECDSA ]; then
    ECDSA=true
fi

# Check that acme doesn't already exist or update it if it does
if [[ -f /.acme.sh/acme.sh ]]; then
    echo "20-domain.sh: acme.sh was already found. Running update."
    # Add a link to acme.sh in bin for ease of access
    ln -s /.acme.sh/acme.sh /usr/bin/acme.sh && \
    acme.sh --upgrade
else
    echo "20-domain.sh: acme.sh was not found. Running install."
    # Clone acme.sh repo from github
    git clone https://github.com/acmesh-official/acme.sh.git /tmp/acme.sh && \
        cd /tmp/acme.sh && \
        # run the acme.sh installer
        ./acme.sh --install --home /.acme.sh && \
        # Add a link to acme.sh in bin for ease of access
        ln -s /.acme.sh/acme.sh /usr/bin/acme.sh
fi

if [ ! "$(command -v acme.sh)" ]; then
    echo "20-domain.sh: acme.sh did not install properly. We will be unable to request a certificate."
    echo "20-domain.sh: This won't cause a script failure, but my-dash may not connect."
    echo "20-domain.sh: End script."
    exit 0
fi

# Check if ECDSA is wanted (Default = true)
if [[ "${ECDSA}" -eq "true" ]]; then
    echo "20-domain.sh: ECDSA certificate is wanted."
    export ECDSA=" --keylength ec-256 --ecc"
else
    echo "20-domain.sh: RSA certificate is wanted."
    export ECDSA=""
fi

# We don't want to waste our time if the certificates already exist
if [[ -f /.acme.sh/${DOMAIN}/${DOMAIN}.cer ]] || [[ -f /.acme.sh/${DOMAIN}_ecc/${DOMAIN}.cer ]]; then
    echo "20-domain.sh: Certificate for $DOMAIN appears to already exist, so we will only try to install it."
    acme.sh --install-cert -d $DOMAIN${ECDSA:19:25} \
            --key-file       /etc/ssl/private/priv.key  \
            --fullchain-file /etc/ssl/certs/fullchain.pem \
            --reloadcmd     "service nginx force-reload"
    exit 0
else
    echo "20-domain.sh: Certificate for $DOMAIN does not appear to exist, so we will try to request it."
    # Cloudflare
    if [[ -n "${CF_Token}" && -n "${CF_Account_ID}" ]] || [[ -n "${CF_Key}" && -n "${CF_Email}" ]]; then
        DNS_METHOD="--dns dns_cf"
    # AWS Route53
    elif [[ -n "${AWS_ACCESS_KEY_ID}" && -n "${AWS_SECRET_ACCESS_KEY}" ]]; then
        DNS_METHOD="--dns dns_aws"
    # FreeDNS
    elif [[ -n "${FREEDNS_User}" && -n "${FREEDNS_Password}" ]]; then
        DNS_METHOD="--dns dns_freedns"
    # Fallback to Apache
    else
        echo "20-domain.sh: DNS verification ENV values not found. Fallback to standalone method."
        DNS_METHOD="--alpn --tlsport ${UI_EXTERNAL_PORT}"
    fi

    # Request the sertificate from Let'sEncrypt
    echo "20-domain.sh: Attempting to request certificate..."
    service nginx stop
    acme.sh --issue $DNS_METHOD -d api.$DOMAIN${ECDSA:0:19}
    # Install the certificate
    if [[ -f /.acme.sh/api.$DOMAIN/api.${DOMAIN}.cer ]] || [[ -d /.acme.sh/api.${DOMAIN}_ecc/api.${DOMAIN}.cer ]]; then
        echo "20-domain.sh: Certificate for api.$DOMAIN was found. Attempting to install to nginx..."
        acme.sh --install-cert -d api.$DOMAIN${ECDSA:19:25} \
            --key-file       /etc/ssl/private/api/priv.key  \
            --fullchain-file /etc/ssl/certs/api/fullchain.pem \
            --reloadcmd     "service nginx force-reload"
    else   
        echo "20-domain.sh: Certificate for $DOMAIN was Not Found."
        echo "20-domain.sh: Certificate request may have failed. Run acme.sh manually."
        echo "20-domain.sh: This won't cause a script failure, but my-dash may not connect."
        echo "20-domain.sh: End script."
        exit 0
    fi
fi
# We don't want to waste our time if the certificates already exist (api.domain)
if [[ -f /.acme.sh/api.${DOMAIN}/api.${DOMAIN}.cer ]] || [[ -f /.acme.sh/api.${DOMAIN}_ecc/api.${DOMAIN}.cer ]]; then
    echo "20-domain.sh: Certificate for $DOMAIN appears to already exist, so we will only try to install it."
    acme.sh --install-cert -d api.$DOMAIN${ECDSA:19:25} \
            --key-file       /etc/ssl/private/api/priv.key  \
            --fullchain-file /etc/ssl/certs/api/fullchain.pem \
            --reloadcmd     "service nginx force-reload"
    exit 0
else
    echo "20-domain.sh: Certificate for $DOMAIN does not appear to exist, so we will try to request it."
    # Cloudflare
    if [[ -n "${CF_Token}" && -n "${CF_Account_ID}" ]] || [[ -n "${CF_Key}" && -n "${CF_Email}" ]]; then
        DNS_METHOD="--dns dns_cf"
    # AWS Route53
    elif [[ -n "${AWS_ACCESS_KEY_ID}" && -n "${AWS_SECRET_ACCESS_KEY}" ]]; then
        DNS_METHOD="--dns dns_aws"
    # FreeDNS
    elif [[ -n "${FREEDNS_User}" && -n "${FREEDNS_Password}" ]]; then
        DNS_METHOD="--dns dns_freedns"
    # Fallback to Apache
    else
        echo "20-domain.sh: DNS verification ENV values not found. Fallback to standalone method."
        service nginx stop
        DNS_METHOD="--alpn --tlsport ${UI_EXTERNAL_PORT}"
    fi

    # Request the sertificate from Let'sEncrypt
    echo "20-domain.sh: Attempting to request certificate..."
    acme.sh --issue $DNS_METHOD -d api.$DOMAIN${ECDSA:0:19}
    # Install the certificate
    if [[ -f /.acme.sh/api.$DOMAIN/api.${DOMAIN}.cer ]] || [[ -d /.acme.sh/api.${DOMAIN}_ecc/api.${DOMAIN}.cer ]]; then
        echo "20-domain.sh: Certificate for $DOMAIN was found. Attempting to install to nginx..."
        acme.sh --install-cert -d api.$DOMAIN${ECDSA:19:25} \
            --key-file       /etc/ssl/private/priv.key  \
            --fullchain-file /etc/ssl/certs/fullchain.pem \
            --reloadcmd     "service nginx force-reload"
    else   
        echo "20-domain.sh: Certificate for api.$DOMAIN was Not Found."
        echo "20-domain.sh: Certificate request may have failed. Run acme.sh manually."
        echo "20-domain.sh: This won't cause a script failure, but my-dash may not connect."
        echo "20-domain.sh: End script."
        exit 0
    fi
fi
echo "20-domain.sh: Certificate requested and installed to nginx. Ending script."
exit 0