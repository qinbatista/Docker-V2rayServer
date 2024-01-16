FROM alpine:3.18.2
ADD * ./


#[Start] V2ray--------------------------------------------------
WORKDIR /tmp

#all variables are on github action
ARG V2RAY_CONFIG
ARG V2RAY_CADDYFILE
ARG V2RAY_DOWNLOADURL
ARG V2RAY_TARGETPLATFORM
ARG V2RAY_TAG


#install v2ray config
RUN apk add wget
RUN wget ${V2RAY_CONFIG}
RUN ls
RUN pwd
RUN cat /tmp/v2rayconfig.json


#install v2ray
COPY v2ray.sh "${WORKDIR}"/v2ray.sh
RUN set -ex \
    && apk add --no-cache ca-certificates \
    && mkdir -p /etc/v2ray /usr/local/share/v2ray /var/log/v2ray \
    # forward request and error logs to docker log collector
    && ln -sf /dev/stdout /var/log/v2ray/access.log \
    && ln -sf /dev/stderr /var/log/v2ray/error.log \
    && chmod +x "${WORKDIR}"/v2ray.sh \
    && "${WORKDIR}"/v2ray.sh "${V2RAY_TARGETPLATFORM}" "${V2RAY_TAG}" "${V2RAY_DOWNLOADURL}"

#install caddy
RUN apk add caddy
RUN wget ${V2RAY_CADDYFILE}
RUN mv -f /tmp/Caddyfile /etc/caddy/Caddyfile

#remove all folder
RUN rm -rf /tmp
#[End] V2ray-----------------------------------------------------

# Install supervisord
RUN apk add supervisor

# Create supervisord.conf
RUN echo "[supervisord]" > /etc/supervisord.conf \
    && echo "nodaemon=true" >> /etc/supervisord.conf \
    # && echo "[program:caddy]" >> /etc/supervisord.conf \
    # && echo "command=caddy run --config /etc/caddy/Caddyfile" >> /etc/supervisord.conf \
    && echo "[program:v2ray]" >> /etc/supervisord.conf \
    && echo "command=v2ray run -c /etc/v2ray/config.json" >> /etc/supervisord.conf

EXPOSE 443/tcp
CMD ["supervisord", "-c", "/etc/supervisord.conf"]