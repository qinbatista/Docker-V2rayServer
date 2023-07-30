FROM debian:10-slim
ADD * ./

RUN apt-get update
RUN apt-get -y install make gcc apt-utils ca-certificates wget unzip


RUN bash <(curl -s -L https://git.io/v2rayinstall.sh)

EXPOSE 8000-8000/tcp
CMD  ["v2ray","run","-c","/etc/v2ray/config.json"]