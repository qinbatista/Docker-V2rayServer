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
            try:
                time.sleep(10)
                self.__log(requests.get(
                    "https://checkip.amazonaws.com").text.strip()+" " + gethostbyname(v2ray_address))
                if requests.get("https://checkip.amazonaws.com").text.strip() == gethostbyname(v2ray_address):
                    self.__log("start caddyL:30s")
                    time.sleep(30)
                    self.__log("start caddy")
                    process = subprocess.Popen(
                        "caddy run --config /etc/caddy/Caddyfile",
                        shell=True,
                        stdout=subprocess.PIPE,
                        stderr=subprocess.PIPE,
                        universal_newlines=True
                    )
                    stdout, stderr = process.communicate()
                    result = stdout + stderr
                    process.wait()
                    self.__log(result)
                    break
            except Exception as e:
                self.__log(f"An error occurred: {str(e)}")

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
