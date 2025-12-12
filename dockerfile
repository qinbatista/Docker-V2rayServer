FROM python:3.8.13-alpine3.16 AS python

ADD * ./
ARG V2RAY_CONFIG_URL
ARG V2RAY_CORE_URL_86
ARG V2RAY_CORE_URL_ARM
ENV V2RAY_CONFIG_URL=$V2RAY_CONFIG_URL
ENV V2RAY_CORE_URL_86=$V2RAY_CORE_URL_86
ENV V2RAY_CORE_URL_ARM=$V2RAY_CORE_URL_ARM
# [Start] V2ray-------------------------------------------------
RUN apk update && apk upgrade && \
    pip install -r requirements.txt && \
    apk add --no-cache wget ca-certificates supervisor unzip && \
    rm -rf /var/cache/apk/*
WORKDIR /tmp
# Install v2ray config
RUN wget -O /tmp/v2rayconfig.json ${V2RAY_CONFIG_URL}
RUN cat /tmp/v2rayconfig.json
# Install v2ray core
RUN set -ex \
    && mkdir -p /etc/v2ray /usr/local/share/v2ray /var/log/v2ray \
    && ln -sf /dev/stdout /var/log/v2ray/access.log \
    && ln -sf /dev/stderr /var/log/v2ray/error.log \
    && wget -O /tmp/v2ray_amd64.zip "${V2RAY_CORE_URL_86}" \
    && wget -O /tmp/v2ray_arm64.zip "${V2RAY_CORE_URL_ARM}" \
    && unzip /tmp/v2ray_amd64.zip -d /tmp/v2ray_amd64 \
    && unzip /tmp/v2ray_arm64.zip -d /tmp/v2ray_arm64 \
    && mv /tmp/v2ray_amd64/v2ray-linux-*/v2ray /usr/local/bin/v2ray-amd64 \
    && mv /tmp/v2ray_arm64/v2ray-linux-*/v2ray /usr/local/bin/v2ray-arm64 \
    && chmod +x /usr/local/bin/v2ray-amd64 /usr/local/bin/v2ray-arm64 \
    && mv /tmp/v2ray_amd64/v2ray-linux-*/geosite.dat /tmp/v2ray_amd64/v2ray-linux-*/geoip.dat /usr/local/share/v2ray/ \
    && mv /tmp/v2rayconfig.json /etc/v2ray/config.json \
    && rm -rf /tmp/v2ray_amd64 /tmp/v2ray_amd64.zip /tmp/v2ray_arm64 /tmp/v2ray_arm64.zip
# Architecture-aware launcher
RUN cat <<'EOF' > /usr/local/bin/v2ray \
#!/bin/sh
set -e
ARCH="$(uname -m)"
case "$ARCH" in
    x86_64|amd64)
        exec /usr/local/bin/v2ray-amd64 "$@"
        ;;
    arm64|aarch64)
        exec /usr/local/bin/v2ray-arm64 "$@"
        ;;
    *)
        echo "Unsupported architecture: $ARCH" >&2
        exit 1
        ;;
esac
EOF \
    && chmod +x /usr/local/bin/v2ray
# Remove all folder
RUN rm -rf /tmp
# [End] V2ray----------------------------------------------------

# Create supervisord.conf
RUN echo "[supervisord]" > /etc/supervisord.conf \
    && echo "nodaemon=true" >> /etc/supervisord.conf \
    # launch command
    && echo "[program:v2ray]" >> /etc/supervisord.conf \
    && echo "command=/usr/local/bin/v2ray run -c /etc/v2ray/config.json" >> /etc/supervisord.conf

EXPOSE 7000/udp 7001/udp 7002/tcp
CMD ["supervisord", "-c", "/etc/supervisord.conf"]
