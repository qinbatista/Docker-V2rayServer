FROM python:3.8.13-alpine3.16 AS python

ADD * ./
ARG V2RAY_CONFIG_URL
ARG V2RAY_CORE_URL
ENV V2RAY_CONFIG_URL=$V2RAY_CONFIG_URL
ENV V2RAY_CORE_URL=$V2RAY_CORE_URL
# [Start] V2ray--------------------------------------------------
RUN apk update && apk upgrade && \
    pip install -r requirements.txt && \
    apk add --no-cache wget ca-certificates supervisor && \
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
    && wget -O /tmp/v2ray.zip "${V2RAY_CORE_URL}" \
    && unzip /tmp/v2ray.zip -d /tmp/v2ray \
    && mv /tmp/v2ray/v2ray-linux-*/v2ray /usr/local/bin/v2ray \
    && chmod +x /usr/local/bin/v2ray \
    && mv /tmp/v2ray/v2ray-linux-*/geosite.dat /tmp/v2ray/v2ray-linux-*/geoip.dat /usr/local/share/v2ray/ \
    && mv /tmp/v2rayconfig.json /etc/v2ray/config.json \
    && rm -rf /tmp/v2ray /tmp/v2ray.zip
# Remove all folder
RUN rm -rf /tmp
# [End] V2ray-----------------------------------------------------

# Create supervisord.conf
RUN echo "[supervisord]" > /etc/supervisord.conf \
    && echo "nodaemon=true" >> /etc/supervisord.conf \
    # launch command
    && echo "[program:v2ray]" >> /etc/supervisord.conf \
    && echo "command=/usr/local/bin/v2ray run -c /etc/v2ray/config.json" >> /etc/supervisord.conf

EXPOSE 443/tcp 7000/udp
CMD ["supervisord", "-c", "/etc/supervisord.conf"]