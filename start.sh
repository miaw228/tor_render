#!/bin/bash

mkdir -p /var/lib/tor/hidden_service /var/log/tor

if [ -f /etc/secrets/hostname.b64 ]; then
  base64 -d /etc/secrets/hostname.b64 > /var/lib/tor/hidden_service/hostname
  base64 -d /etc/secrets/secret_key.b64 > /var/lib/tor/hidden_service/hs_ed25519_secret_key
  base64 -d /etc/secrets/public_key.b64 > /var/lib/tor/hidden_service/hs_ed25519_public_key
  chmod 700 /var/lib/tor/hidden_service
  chmod 600 /var/lib/tor/hidden_service/*
fi

tor &

echo "waiting for tor to bootstrap..."
TIMEOUT=120
ELAPSED=0
until grep -q "Bootstrapped 100%" /var/log/tor/log 2>/dev/null; do
  sleep 2
  ELAPSED=$((ELAPSED + 2))
  if [ "$ELAPSED" -ge "$TIMEOUT" ]; then
    echo "ERROR: Tor failed to bootstrap after ${TIMEOUT}s"
    exit 1
  fi
done

echo "Tor is ready. Your .onion address is:"
cat /var/lib/tor/hidden_service/hostname

nginx -g 'daemon off;'