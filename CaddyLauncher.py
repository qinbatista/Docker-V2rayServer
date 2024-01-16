# -*- coding: utf-8 -*-
import os
import subprocess
import requests
import time
from socket import *
class CaddyLauncher:
    def __init__(self):
        pass

    def _Caddy(self):
        v2ray_address = os.environ.get('V2RAY_ADDRESS')
        while True:
            time.sleep(10)
            print(requests.get("https://checkip.amazonaws.com").text.strip()+" " + gethostbyname(v2ray_address))
            if requests.get("https://checkip.amazonaws.com").text.strip() == gethostbyname(v2ray_address):
                break
        p = subprocess.Popen("caddy run --config /etc/caddy/Caddyfile", universal_newlines=True, shell=True,)
        p.wait()

if __name__ == "__main__":
    sf = CaddyLauncher()
    sf._Caddy()
