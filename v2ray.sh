#!/bin/sh

V2RAY_CORE_URL=$1

if [ -z "$V2RAY_CORE_URL" ]; then
    echo "Error: V2RAY_CORE_URL is not set" && exit 1
fi

# Download V2Ray core zip
wget -O /tmp/v2ray.zip "$V2RAY_CORE_URL"

if [ $? -ne 0 ]; then
    echo "Error: Failed to download V2Ray core" && exit 1
fi

# Extract and install
unzip /tmp/v2ray.zip -d /tmp/v2ray
chmod +x /tmp/v2ray/v2ray
mv /tmp/v2ray/v2ray /usr/bin/
mv /tmp/v2ray/geosite.dat /tmp/v2ray/geoip.dat /usr/local/share/v2ray/
mv /tmp/v2rayconfig.json /etc/v2ray/config.json

# Clean up
rm -rf /tmp/v2ray /tmp/v2ray.zip

echo "Done"
