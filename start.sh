#!/bin/bash

mkdir -p /var/lib/tor/hidden_service

base64 -d /etc/secrets/hostname.b64 > /var/lib/tor/hidden_service/hostname
base64 -d /etc/secrets/secret_key.b64 > /var/lib/tor/hidden_service/hs_ed25519_secret_key
base64 -d /etc/secrets/public_key.b64 > /var/lib/tor/hidden_service/hs_ed25519_public_key

chmod 700 /var/lib/tor/hidden_service
chmod 600 /var/lib/tor/hidden_service/*

tor &

echo "waiting for tor to bootstrap..."
until grep -q "Bootstrapped 100%" /var/log/tor/log 2>/dev/null; do
    sleep 2
done

echo "Tor is ready. Your .onion address is:"
cat /var/lib/tor/hidden_service/hostname

python -m http.server 80