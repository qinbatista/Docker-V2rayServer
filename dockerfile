FROM alpine:latest
ADD * ./
RUN ls
RUN pwd
WORKDIR /tmp
ARG TARGETPLATFORM
ARG TAG
COPY v2ray.sh "${WORKDIR}"/v2ray.sh

RUN set -ex \
    && apk add --no-cache ca-certificates \
    && mkdir -p /etc/v2ray /usr/local/share/v2ray /var/log/v2ray \
    # forward request and error logs to docker log collector
    && ln -sf /dev/stdout /var/log/v2ray/access.log \
    && ln -sf /dev/stderr /var/log/v2ray/error.log \
    && chmod +x "${WORKDIR}"/v2ray.sh \
    && "${WORKDIR}"/v2ray.sh "${TARGETPLATFORM}" "${TAG}"
RUN ls
RUN mv -f /config.json /etc/v2ray/config.json

EXPOSE 8000/tcp
EXPOSE 8000/udp
CMD  ["v2ray","run","-c","/etc/v2ray/config.json"]