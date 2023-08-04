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

EXPOSE 443/tcp
CMD  ["v2ray","run","-c","/etc/v2ray/config.json"]