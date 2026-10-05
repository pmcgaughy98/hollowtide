"""Minimal Retro Diffusion MCP client over HTTP, for sessions where the MCP tools are not loaded. Key read from ~/.claude.json. Usage: python tools/debug/rd_client.py tools/call {json}"""
import json, sys, urllib.request, pathlib
cfg = json.load(open(pathlib.Path.home() / ".claude.json", encoding="utf-8"))["mcpServers"]["retro-diffusion"]
URL, AUTH = cfg["url"], cfg["headers"]["Authorization"]
SID = pathlib.Path.home() / ".rd_session.txt"

def post(body, sid=None):
    h = {"Authorization": AUTH, "Content-Type": "application/json", "Accept": "application/json, text/event-stream"}
    if sid: h["Mcp-Session-Id"] = sid
    req = urllib.request.Request(URL, json.dumps(body).encode(), h)
    with urllib.request.urlopen(req, timeout=600) as r:
        raw = r.read().decode()
        new_sid = r.headers.get("Mcp-Session-Id")
    msgs = []
    for line in raw.splitlines():
        if line.startswith("data:"):
            msgs.append(json.loads(line[5:]))
    if not msgs and raw.strip():
        msgs.append(json.loads(raw))
    return msgs, new_sid

def session():
    if SID.exists():
        return SID.read_text()
    _, sid = post({"jsonrpc": "2.0", "id": 1, "method": "initialize", "params": {"protocolVersion": "2025-03-26", "capabilities": {}, "clientInfo": {"name": "claude-hollowtide", "version": "1"}}})
    post({"jsonrpc": "2.0", "method": "notifications/initialized"}, sid)
    SID.write_text(sid or "")
    return sid

def call(method, params):
    msgs, _ = post({"jsonrpc": "2.0", "id": 2, "method": method, "params": params}, session())
    return msgs[-1] if msgs else None

if __name__ == "__main__":
    method = sys.argv[1]
    params = json.loads(sys.argv[2]) if len(sys.argv) > 2 else {}
    print(json.dumps(call(method, params), indent=1)[:int(sys.argv[3]) if len(sys.argv) > 3 else 20000])
