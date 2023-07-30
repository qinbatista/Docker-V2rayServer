FROM debian:10-slim
ADD * ./

RUN apt-get update
RUN apt-get -y install make gcc apt-utils ca-certificates wget unzip


RUN mkdir -p /etc/v2ray /usr/local/share/v2ray
RUN wget https://github.com/v2fly/v2ray-core/releases/download/v5.7.0/v2ray-linux-64.zip
RUN unzip v2ray-linux-64.zip
RUN ls
RUN chmod +x v2ray
RUN mv v2ray /usr/bin/
RUN mv geosite.dat geoip.dat /usr/local/share/v2ray/
RUN mv -f myconfig.json /etc/v2ray/config.json
RUN v2ray help
RUN v2ray version
RUN v2ray help run
RUN v2ray run -c /etc/v2ray/config.json

# RUN set -ex \
#     && apt-get install -y ca-certificates \
#     && mkdir -p /etc/v2ray /usr/local/share/v2ray /var/log/v2ray \
#     # forward request and error logs to docker log collector
#     && ln -sf /dev/stdout /var/log/v2ray/access.log \
#     && ln -sf /dev/stderr /var/log/v2ray/error.log \
#     && chmod +x "${WORKDIR}"/v2ray.sh \
#     && "${WORKDIR}"/v2ray.sh "${TARGETPLATFORM}" "${TAG}"

EXPOSE 8000-8000/tcp
CMD  ["v2ray","c","/etc/v2ray/config.json"]