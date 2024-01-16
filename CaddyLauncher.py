# -*- coding: utf-8 -*-
import subprocess
import requests
import time
from socket import *
class CaddyLauncher:
    def __init__(self):
        pass

    def _Caddy(self):
        while True:
            time.sleep(10)
            print(requests.get("https://checkip.amazonaws.com").text.strip()+" " + gethostbyname("us.qinyupeng.com"))
            if requests.get("https://checkip.amazonaws.com").text.strip() == gethostbyname("us.qinyupeng.com"):
                break
        p = subprocess.Popen("caddy run --config /etc/caddy/Caddyfile", universal_newlines=True, shell=True,)
        p.wait()


if __name__ == "__main__":
    sf = CaddyLauncher()
    sf._Caddy()
