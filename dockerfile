FROM alpine:3.18.2
ADD * ./

WORKDIR /tmp
ARG TARGETPLATFORM
ARG TAG

#install v2ray
COPY v2ray.sh "${WORKDIR}"/v2ray.sh
RUN set -ex \
    && apk add --no-cache ca-certificates \
    && mkdir -p /etc/v2ray /usr/local/share/v2ray /var/log/v2ray \
    # forward request and error logs to docker log collector
    && ln -sf /dev/stdout /var/log/v2ray/access.log \
    && ln -sf /dev/stderr /var/log/v2ray/error.log \
    && chmod +x "${WORKDIR}"/v2ray.sh \
    && "${WORKDIR}"/v2ray.sh "${TARGETPLATFORM}" "${TAG}"
RUN mv -f /v2rayconfig.json /etc/v2ray/config.json

#install caddy
RUN apk add caddy
RUN mv -f /Caddyfile /etc/caddy/Caddyfile

# Install supervisord
RUN apk add supervisor

# Create supervisord.conf
RUN echo "[supervisord]" > /etc/supervisord.conf \
    && echo "nodaemon=true" >> /etc/supervisord.conf \
    && echo "[program:caddy]" >> /etc/supervisord.conf \
    && echo "command=caddy run --config /etc/caddy/Caddyfile" >> /etc/supervisord.conf \
    && echo "[program:v2ray]" >> /etc/supervisord.conf \
    && echo "command=v2ray run -c /etc/v2ray/config.json" >> /etc/supervisord.conf

EXPOSE 443/tcp
CMD ["supervisord", "-c", "/etc/supervisord.conf"]