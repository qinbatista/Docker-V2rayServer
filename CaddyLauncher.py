# -*- coding: utf-8 -*-
import os
import subprocess
import requests
import time
from socket import *


class CaddyLauncher:
    def __init__(self):
        self.__file_path = "/v2ray_server.txt"

    def _Caddy(self):
        v2ray_address = os.environ.get('V2RAY_ADDRESS')
        while True:
            time.sleep(10)
            self.__log(requests.get(
                "https://checkip.amazonaws.com").text.strip()+" " + gethostbyname(v2ray_address))
            if requests.get("https://checkip.amazonaws.com").text.strip() == gethostbyname(v2ray_address):
                break
            time.sleep(10)
            process = subprocess.Popen(
                "caddy run --config /etc/caddy/Caddyfile",
                shell=True,
                stdout=subprocess.PIPE,
                stderr=subprocess.PIPE,
                universal_newlines=True
            )
            stdout, stderr = process.communicate()
            result = stdout + stderr
            self.__log(result)
            process.wait()

    def __log(self, result):
        with open(self.__file_path, "a+") as f:
            f.write(result+"\n")
        if os.path.getsize(self.__file_path) > 1024*128:
            with open(self.__file_path, "r") as f:
                content = f.readlines()
                os.remove(self.__file_path)


if __name__ == "__main__":
    sf = CaddyLauncher()
    sf._Caddy()
