import json
from http.server import BaseHTTPRequestHandler, HTTPServer
from os import environ
import logging as log

with open("/var/run/argo/token") as f:
    plugin_token = f.read().strip()


class Plugin(BaseHTTPRequestHandler):

    def args(self):
        return json.loads(self.rfile.read(int(self.headers.get('Content-Length'))))

    def reply(self, reply):
        """
        return 200 HTTP code (success) if auth everything checks out
        """
        self.send_response(200)
        self.end_headers()
        self.wfile.write(json.dumps(reply).encode("UTF-8"))

    def forbidden(self):
        """
        return 403 HTTP (forbidden) code if authorization fails
        """
        self.send_response(403)
        self.end_headers()

    def unsupported(self):
        """
        return 404 HTTP code if we are asked for any other path than getparams
        """
        self.send_response(404)
        self.end_headers()

    def do_POST(self):
        if self.headers.get("Authorization") != "Bearer " + plugin_token:
            self.forbidden()

        if self.path == '/api/v1/getparams.execute':
            args = self.args()

            # just log the args for now
            for argument in args:
                log.info(f"Argument recieved: {argument}")

            # for now, just get the vouch hostname
            vouch_hostname = environ.get("VOUCH_HOSTNAME")

            # reply with just the vouch hostname
            self.reply({
                "output": {
                    "parameters": [
                        {
                            "vouch_hostname": vouch_hostname,
                        }
                    ]
                }
            })
        else:
            self.unsupported()


if __name__ == '__main__':
    httpd = HTTPServer(('', 4355), Plugin)
    httpd.serve_forever()
