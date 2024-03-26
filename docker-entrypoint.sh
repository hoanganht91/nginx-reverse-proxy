#!/bin/sh
set -e

# Compute the DNS resolvers for use in the templates - if the IP contains ":", it's IPv6 and must be enclosed in []
export RESOLVERS=$(awk '$1 == "nameserver" {print ($2 ~ ":")? "["$2"]": $2}' ORS=' ' /etc/resolv.conf | sed 's/ *$//g')
if [ "x$RESOLVERS" = "x" ]; then
    echo "Error: there is no resolvers!!" >&2
    exit 1
fi

# if $UPSTREAM_HTTP_ADDRESS start with http
if [ $(echo $UPSTREAM_HTTP_ADDRESS | grep -c '^http') -eq 0 ]; then
    echo Config load balancing: $UPSTREAM_HTTP_ADDRESS
    cp /template/default-lb.conf /etc/nginx/conf.d/default.conf.template
else
    echo Config resverse proxy: $UPSTREAM_HTTP_ADDRESS
    cp /template/default.conf /etc/nginx/conf.d/default.conf.template
fi

envsubst '$RESOLVERS $UPSTREAM_HTTP_ADDRESS $CLIENT_MAX_BODY_SIZE' < /etc/nginx/conf.d/default.conf.template > /etc/nginx/conf.d/default.conf

exec "$@"
