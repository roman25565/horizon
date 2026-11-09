"""Local mock of the Microsoft / Xbox Live / Minecraft services for the fork's launcher.

Answers the whole sign-in chain from account.rs with fake tokens, so you can sign in,
press Play and test account code without the internet or a real client ID.

    python mock_ms.py [--port 8765] [--name Roman] [--uuid <32 hex>] [--no-own] [--xerr 2148916233]

Only for debug builds of the launcher (cargo run without --release), with the
HORIZON_MOCK_AUTH patch in Endpoints::live(). Online-mode servers will refuse the fake token;
singleplayer, LAN and offline-mode servers work.
"""
import argparse
import json
import uuid as uuidlib
from http.server import BaseHTTPRequestHandler, ThreadingHTTPServer
from urllib.parse import parse_qs

p = argparse.ArgumentParser()
p.add_argument("--port", type=int, default=8765)
p.add_argument("--name", default="MockPlayer")
p.add_argument("--uuid", default=None, help="profile UUID, 32 hex chars without dashes")
p.add_argument("--no-own", action="store_true", help="the account does NOT own the game")
p.add_argument("--no-profile", action="store_true", help="owns the game but has no profile (404)")
p.add_argument("--xerr", type=int, default=None, help="make XSTS fail with this XErr code")
p.add_argument("--pending", type=int, default=1, help="token polls answered authorization_pending")
args = p.parse_args()
UUID = (args.uuid or uuidlib.uuid5(uuidlib.NAMESPACE_DNS, args.name).hex).replace("-", "").lower()
state = {"pending": args.pending, "n": 0}


class H(BaseHTTPRequestHandler):
    def _send(self, status, body):
        data = json.dumps(body).encode()
        self.send_response(status)
        self.send_header("Content-Type", "application/json")
        self.send_header("Content-Length", str(len(data)))
        self.end_headers()
        self.wfile.write(data)

    def _body(self):
        n = int(self.headers.get("Content-Length") or 0)
        return self.rfile.read(n).decode() if n else ""

    def log_message(self, fmt, *a):
        print(f"[mock] {self.command} {self.path}")

    def do_POST(self):
        body = self._body()
        path = self.path
        if path.endswith("/ms/devicecode"):
            state["pending"] = args.pending
            return self._send(200, {
                "user_code": "MOCK-CODE", "device_code": "mock-device",
                "verification_uri": f"http://127.0.0.1:{args.port}/link",
                "expires_in": 900, "interval": 1,
            })
        if path.endswith("/ms/token"):
            form = {k: v[0] for k, v in parse_qs(body).items()}
            grant = form.get("grant_type", "")
            if grant.endswith("device_code") and state["pending"] > 0:
                state["pending"] -= 1
                return self._send(400, {"error": "authorization_pending"})
            if grant.endswith("device_code") or grant == "refresh_token":
                state["n"] += 1
                return self._send(200, {
                    "access_token": f"ms-access-{state['n']}",
                    "refresh_token": f"ms-refresh-{state['n']}", "expires_in": 3600,
                })
            return self._send(400, {"error": "invalid_grant"})
        if path.endswith("/xbl"):
            return self._send(200, {"Token": "xbl-token", "DisplayClaims": {"xui": [{"uhs": "uhs-1"}]}})
        if path.endswith("/xsts"):
            if args.xerr:
                return self._send(401, {"Identity": "0", "XErr": args.xerr, "Message": ""})
            return self._send(200, {"Token": "xsts-token",
                                    "DisplayClaims": {"xui": [{"uhs": "uhs-1", "xid": "2535400000000000"}]}})
        if path.endswith("/mc/launcher/login") or path.endswith("/mc/authentication/login_with_xbox"):
            return self._send(200, {"access_token": "mc-mock-token", "token_type": "Bearer", "expires_in": 86400})
        self._send(404, {"error": "not mocked", "path": path})

    def do_GET(self):
        path = self.path
        if path == "/link":
            data = b"<h1>Mock sign-in: nothing to do, the launcher continues by itself.</h1>"
            self.send_response(200)
            self.send_header("Content-Type", "text/html")
            self.end_headers()
            return self.wfile.write(data)
        if path.endswith("/mc/entitlements/mcstore"):
            items = [] if args.no_own else [{"name": "product_minecraft"}, {"name": "game_minecraft"}]
            return self._send(200, {"items": items})
        if path.endswith("/mc/minecraft/profile"):
            if args.no_profile or args.no_own:
                return self._send(404, {"error": "NOT_FOUND"})
            return self._send(200, {
                "id": UUID, "name": args.name,
                "skins": [{"id": "s", "state": "ACTIVE", "variant": "CLASSIC",
                           "url": "http://textures.minecraft.net/texture/mock"}],
                "capes": [],
            })
        self._send(404, {"error": "not mocked", "path": path})


print(f"[mock] Microsoft/Xbox/Minecraft mock on http://127.0.0.1:{args.port}  player {args.name} {UUID}")
ThreadingHTTPServer(("127.0.0.1", args.port), H).serve_forever()
