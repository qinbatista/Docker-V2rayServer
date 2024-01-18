FROM python:3.8.13-alpine3.16 as python

ADD * ./
#[Start] V2ray--------------------------------------------------
RUN pip install -r requirements.txt
WORKDIR /tmp
#all variables are on github action
ARG V2RAY_ADDRESS
ARG V2RAY_DOWNLOADURL
ARG V2RAY_TARGETPLATFORM
ARG V2RAY_TAG
ENV V2RAY_ADDRESS=${V2RAY_ADDRESS}
#install v2ray config
RUN apk add wget
RUN wget ${V2RAY_DOWNLOADURL}/${V2RAY_ADDRESS}/v2rayconfig.json
RUN cat /tmp/v2rayconfig.json
#install v2ray
COPY v2ray.sh "${WORKDIR}"/v2ray.sh
RUN set -ex \
    && apk add --no-cache ca-certificates \
    && mkdir -p /etc/v2ray /usr/local/share/v2ray /var/log/v2ray \
    && ln -sf /dev/stdout /var/log/v2ray/access.log \
    && ln -sf /dev/stderr /var/log/v2ray/error.log \
    && chmod +x "${WORKDIR}"/v2ray.sh \
    && "${WORKDIR}"/v2ray.sh "${V2RAY_TARGETPLATFORM}" "${V2RAY_TAG}" "${V2RAY_DOWNLOADURL}"
#install caddy
RUN apk add caddy
RUN wget ${V2RAY_DOWNLOADURL}/${V2RAY_ADDRESS}/Caddyfile
RUN cat /tmp/Caddyfile
RUN mv -f /tmp/Caddyfile /etc/caddy/Caddyfile
#remove all folder
RUN rm -rf /tmp
#[End] V2ray-----------------------------------------------------

# Install supervisord
RUN apk add supervisor

# Create supervisord.conf
RUN echo "[supervisord]" > /etc/supervisord.conf \
    && echo "nodaemon=true" >> /etc/supervisord.conf \
    #launch command
    && echo "[program:caddy-python]" >> /etc/supervisord.conf \
    && echo "command=python3 /CaddyLauncher.py" >> /etc/supervisord.conf \
    && echo "[program:v2ray]" >> /etc/supervisord.conf \
    && echo "command=v2ray run -c /etc/v2ray/config.json" >> /etc/supervisord.conf


EXPOSE 443/tcp 7000/tcp
CMD ["supervisord", "-c", "/etc/supervisord.conf"]