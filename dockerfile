FROM debian:10-slim
ADD * ./

RUN apt-get update
RUN apt-get -y install make gcc apt-utils

WORKDIR /tmp
ARG TARGETPLATFORM
ARG TAG
COPY v2ray.sh "${WORKDIR}"/v2ray.sh

RUN set -ex \
    && apt-get install -y ca-certificates \
    && mkdir -p /etc/v2ray /usr/local/share/v2ray /var/log/v2ray \
    # forward request and error logs to docker log collector
    && ln -sf /dev/stdout /var/log/v2ray/access.log \
    && ln -sf /dev/stderr /var/log/v2ray/error.log \
    && chmod +x "${WORKDIR}"/v2ray.sh \
    && "${WORKDIR}"/v2ray.sh "${TARGETPLATFORM}" "${TAG}"



RUN cp config.json /etc/v2ray/config.json
EXPOSE 8000-8000/tcp
CMD  ["python","/usr/local/ssr/shadowsocks/server.py", "-c", "/etc/ssr.json"]