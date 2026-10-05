from pathlib import Path
import json,subprocess,urllib.request,urllib.error,argparse
HOST="https://mapstools.googleapis.com/mcp"
PS=r"C:/Users/pmcga/.cache/codex-runtimes/codex-primary-runtime/dependencies/native/powershell/pwsh.exe"
class MapsMCP:
    def __init__(self):
        proc=subprocess.run([PS,"-NoProfile","-NonInteractive","-ExecutionPolicy","Bypass","-File",r"C:/Users/pmcga/.codex/google-maps-headers.ps1"],capture_output=True,text=True,check=True)
        self.headers={**json.loads(proc.stdout),"Content-Type":"application/json","Accept":"application/json, text/event-stream"}
        self.next_id=0
        r=self.request("initialize",{"protocolVersion":"2025-03-26","capabilities":{},"clientInfo":{"name":"hollowtide-world-research","version":"1.0"}})
        assert "result" in r,"MCP initialization failed"
        self.request("notifications/initialized",notification=True)
    def request(self,method,params=None,notification=False):
        body={"jsonrpc":"2.0","method":method}
        if not notification:
            self.next_id+=1;body["id"]=self.next_id
        if params is not None:body["params"]=params
        req=urllib.request.Request(HOST,data=json.dumps(body).encode(),headers=self.headers,method="POST")
        try:
            with urllib.request.urlopen(req,timeout=50) as response:
                text=response.read().decode()
                sid=response.headers.get("Mcp-Session-Id")
                if sid:self.headers["Mcp-Session-Id"]=sid
        except urllib.error.HTTPError as exc:
            if notification and exc.code in [202,204]:return {}
            raise RuntimeError("Maps MCP HTTP error "+str(exc.code)) from None
        if not text.strip():return {}
        if text.lstrip().startswith("{"):return json.loads(text)
        for line in text.splitlines():
            if line.startswith("data:"):return json.loads(line[5:].strip())
        raise RuntimeError("No MCP JSON response")
if __name__=="__main__":
    p=argparse.ArgumentParser();p.add_argument("--output",required=True);p.add_argument("--tool");p.add_argument("--args")
    a=p.parse_args();m=MapsMCP()
    if a.tool:
        reply=m.request("tools/call",{"name":a.tool,"arguments":json.loads(Path(a.args).read_text())})
        Path(a.output).write_text(json.dumps(reply,indent=2),encoding="utf-8")
        result=reply.get("result",{})
        print(json.dumps({"tool":a.tool,"error":reply.get("error"),"isError":result.get("isError",False),"result":result},ensure_ascii=False))
    else:
        reply=m.request("tools/list")
        Path(a.output).write_text(json.dumps(reply,indent=2),encoding="utf-8")
        print(json.dumps([{"name":x["name"],"inputSchema":x["inputSchema"]} for x in reply.get("result",{}).get("tools",[]) if x["name"] in ["search_places","compute_routes"]],indent=2))
