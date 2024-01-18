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
                self.__log("this address:"+requests.get("https://checkip.amazonaws.com").text.strip() + " config address:" + gethostbyname(v2ray_address))

                if requests.get("https://checkip.amazonaws.com").text.strip() == gethostbyname(v2ray_address):
                    self.__log("Starting Caddy...")
                    with open(self.__file_path, "a+") as output_file:
                        subprocess.Popen(
                            "nohup caddy run --config /etc/caddy/Caddyfile &",
                            shell=True,
                            stdout=output_file,
                            stderr=output_file,
                            universal_newlines=True
                        )
                    self.__log(f"Caddy started in background. Logging to {self.__file_path}.")
                    break
            except Exception as e:
                self.__log(f"An error occurred: {str(e)}")

    def __log(self, result):
        with open(self.__file_path, "a+") as f:
            f.write(result+"\n")
        if os.path.getsize(self.__file_path) > 1024*128:
            with open(self.__file_path, "r") as f:
                os.remove(self.__file_path)


if __name__ == "__main__":
    sf = CaddyLauncher()
    sf._Caddy()
