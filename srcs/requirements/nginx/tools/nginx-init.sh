#!/bin/bash

set -e

echo "Starting NGINX initialization .."

# Create SSL directory
mkdir -p /etc/nginx/ssl

# Generate self-signed certificates if they do not exist
if [ ! -f /etc/nginx/ssl/inception.crt ] || \
   [ ! -f /etc/nginx/ssl/inception.key ]; then

    echo "Generating TLS certificate..."

    openssl req -x509 \
        -nodes \
        -newkey rsa:2048 \
        -days 365 \
        -keyout /etc/nginx/ssl/inception.key \
        -out /etc/nginx/ssl/inception.crt \
        -subj "/C=JO/ST=Amman/L=Amman/O=42/OU=Inception/CN=${DOMAIN_NAME}"

fi

# Generate the final NGINX configuration
envsubst '${DOMAIN_NAME}' \
    < /etc/nginx/nginx.conf.template \
    > /etc/nginx/nginx.conf

# Test NGINX configuration
nginx -t

echo "NGINX configuration is valid"

# Start NGINX in foreground
exec nginx -g "daemon off;"
