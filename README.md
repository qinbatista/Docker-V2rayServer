## Build Command

```
docker build -t qinbatista/v2rayserver .
```

## Run Command
```
docker pull qinbatista/v2rayserver && docker run -itd --restart=always -p 443:443 qinbatista/v2rayserver
```

# Docker-V2rayServer


docker run -itd --restart=always -p 443:443 -v /var/log/v2ray:/var/log/v2ray qinbatista/v2rayserver
