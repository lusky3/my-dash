#!/bin/sh
#
# Description: Setup achme.sh and obtain Let'sEncrypt certificate
#

case $DOMAIN in
  "") echo "30-domain.sh: Domain ENV is empty. Kill script."; exit 1;;
  *) ;;
esac
export ECDSA=$ECDSA
case $ECDSA in
  false) export ECDSA="false";;
  "") export ECDSA="true";;
  *) export ECDSA="true";;
esac

# Check that acme doesn't already exist or update it if it does
if [[ -f /root/.acme.sh/acme.sh ]]; then
    echo "30-domain.sh: acme.sh was already found. Running update."
    # Add a link to acme.sh in bin for ease of access
    ln -s /root/.acme.sh/acme.sh /usr/bin/acme.sh && \
    acme.sh --upgrade
else
    echo "30-domain.sh: acme.sh was not found. Running install."
    # Clone acme.sh repo from github
    git clone https://github.com/acmesh-official/acme.sh.git /tmp/acme.sh && \
        cd /tmp/acme.sh && \
        # run the acme.sh installer
        ./acme.sh --install && \
        # Add a link to acme.sh in bin for ease of access
        ln -s /root/.acme.sh/acme.sh /usr/bin/acme.sh
fi

if [ ! "$(command -v acme.sh)" ]; then
    echo "30-domain.sh: acme.sh did not install properly. We will be unable to request a certificate."
    echo "30-domain.sh: This won't cause a script failure, but my-dash may not connect."
    echo "30-domain.sh: End script."
    exit 0
fi

# Check if ECDSA is wanted (Default = true)

case $ECDSA in
  true) echo "30-domain.sh: ECDSA certificate is wanted."; export ECDSA=" --keylength ec-256 --ecc";;
  *) echo "30-domain.sh: RSA certificate is wanted."; export ECDSA="";;
esac

# We don't want to waste our time if the certificates already exist
if [[ -f /root/.acme.sh/${DOMAIN}_ecc/${DOMAIN}.cer ]]; then
    echo "30-domain.sh: Certificate for $DOMAIN (ECC) appears to already exist, so we will only try to install it."
    acme.sh --install-cert -d $DOMAIN${ECDSA:19:25} \
            --key-file       /etc/ssl/private/priv.key  \
            --fullchain-file /etc/ssl/certs/fullchain.pem \
            --reloadcmd     "/usr/sbin/nginx -s reload"
elif [[ -f /root/.acme.sh/${DOMAIN}/${DOMAIN}.cer ]]; then
    echo "30-domain.sh: Certificate for $DOMAIN (RSA) appears to already exist, so we will only try to install it."
    acme.sh --install-cert -d $DOMAIN \
            --key-file       /etc/ssl/private/priv.key  \
            --fullchain-file /etc/ssl/certs/fullchain.pem \
            --reloadcmd     "/usr/sbin/nginx -s reload"
else
    echo "30-domain.sh: Certificate for $DOMAIN does NOT appear to exist, so we will try to request it."
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
        echo "30-domain.sh: DNS verification ENV values not found. Fallback to standalone method."
        DNS_METHOD="--alpn --tlsport ${UI_EXTERNAL_PORT}"
    fi

    # Request the sertificate from Let'sEncrypt
    echo "30-domain.sh: Attempting to request certificate..."
    /usr/sbin/nginx -s stop
    acme.sh --issue $DNS_METHOD -d $DOMAIN${ECDSA:0:19}
    # Install the certificate
    if [[ -f /root/.acme.sh/${DOMAIN}_ecc/${DOMAIN}.cer ]]; then
        echo "30-domain.sh: Certificate for $DOMAIN was found. Attempting to install to nginx..."
        acme.sh --install-cert -d $DOMAIN${ECDSA:19:25} \
            --key-file       /etc/ssl/private/priv.key  \
            --fullchain-file /etc/ssl/certs/fullchain.pem \
            --reloadcmd     "/usr/sbin/nginx -s reload"
    elif [[ -d /root/.acme.sh/${DOMAIN}/${DOMAIN}.cer ]]; then
        echo "30-domain.sh: Certificate for $DOMAIN was found. Attempting to install to nginx..."
        acme.sh --install-cert -d $DOMAIN${ECDSA:19:25} \
            --key-file       /etc/ssl/private/priv.key  \
            --fullchain-file /etc/ssl/certs/fullchain.pem \
            --reloadcmd     "/usr/sbin/nginx -s reload"
    else   
        echo "30-domain.sh: Certificate for $DOMAIN was Not Found."
        echo "30-domain.sh: Certificate request may have failed. Run acme.sh manually."
        echo "30-domain.sh: This won't cause a script failure, but my-dash may not connect."
        echo "30-domain.sh: End script."
    fi
fi
# We don't want to waste our time if the certificates already exist (api.domain)
if [[ -f /root/.acme.sh/api.${DOMAIN}_ecc/api.${DOMAIN}.cer ]]; then
    echo "30-domain.sh: Certificate for api.$DOMAIN (ECC) appears to already exist, so we will only try to install it."
    acme.sh --install-cert -d api.$DOMAIN${ECDSA:19:25} \
            --key-file       /etc/ssl/private/api/priv.key  \
            --fullchain-file /etc/ssl/certs/api/fullchain.pem \
            --reloadcmd     "/usr/sbin/nginx -s reload"
elif  [[ -f /root/.acme.sh/api.${DOMAIN}/api.${DOMAIN}.cer ]]; then
    echo "30-domain.sh: Certificate for api.$DOMAIN (RSA) appears to already exist, so we will only try to install it."
    acme.sh --install-cert -d api.$DOMAIN \
            --key-file       /etc/ssl/private/api/priv.key  \
            --fullchain-file /etc/ssl/certs/api/fullchain.pem \
            --reloadcmd     "/usr/sbin/nginx -s reload"
else
    echo "30-domain.sh: Certificate for api.$DOMAIN does not appear to exist, so we will try to request it."
    # Cloudflare
    if [[ -n "${CF_Token}" && -n "${CF_Account_ID}" ]]; then
        echo "30-domain.sh: Cloudflare token found."
        DNS_METHOD="--dns dns_cf"
    elif [[ -n "${CF_Key}" && -n "${CF_Email}" ]]; then
        echo "30-domain.sh: Cloudflare API key found."
        DNS_METHOD="--dns dns_cf"
    # AWS Route53
    elif [[ -n "${AWS_ACCESS_KEY_ID}" && -n "${AWS_SECRET_ACCESS_KEY}" ]]; then
        echo "30-domain.sh: AWS key found."
        DNS_METHOD="--dns dns_aws"
    # FreeDNS
    elif [[ -n "${FREEDNS_User}" && -n "${FREEDNS_Password}" ]]; then
        echo "30-domain.sh: FreeDNS user found."
        DNS_METHOD="--dns dns_freedns"
    # Fallback to Apache
    else
        echo "30-domain.sh: DNS verification ENV values not found. Fallback to standalone method."
        /usr/sbin/nginx -s stop
        DNS_METHOD="--alpn --tlsport ${UI_EXTERNAL_PORT}"
    fi

    # Request the sertificate from Let'sEncrypt
    echo "30-domain.sh: Attempting to request certificate..."
    acme.sh --issue $DNS_METHOD -d api.$DOMAIN${ECDSA:0:19}
    # Install the certificate
    if [[ -f /root/.acme.sh/api.${DOMAIN}_ecc/api.${DOMAIN}.cer ]]; then
        echo "30-domain.sh: Certificate for api.$DOMAIN (ECC) was found. Attempting to install to nginx..."
        acme.sh --install-cert -d api.$DOMAIN${ECDSA:19:25} \
            --key-file       /etc/ssl/private/api/priv.key  \
            --fullchain-file /etc/ssl/certs/api/fullchain.pem \
            --reloadcmd     "/usr/sbin/nginx -s reload"
     elif [[ -d /root/.acme.sh/api.${DOMAIN}/api.${DOMAIN}.cer ]]; then
        echo "30-domain.sh: Certificate for api.$DOMAIN (RSA) was found. Attempting to install to nginx..."
        acme.sh --install-cert -d api.$DOMAIN \
            --key-file       /etc/ssl/private/api/priv.key  \
            --fullchain-file /etc/ssl/certs/api/fullchain.pem \
            --reloadcmd     "/usr/sbin/nginx -s reload"
    else   
        echo "30-domain.sh: Certificate for api.$DOMAIN was Not Found."
        echo "30-domain.sh: Certificate request may have failed. Run acme.sh manually."
        echo "30-domain.sh: This won't cause a script failure, but my-dash may not connect."
        echo "30-domain.sh: End script."
        exit 0
    fi
fi
echo "30-domain.sh: Done certificate setup."
exit 0