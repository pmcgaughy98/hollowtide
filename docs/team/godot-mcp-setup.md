# Godot MCP setup

## Installed on 2026-09-25

- Godot AI 4.2.3 from https://github.com/hi-godot/godot-ai/releases/tag/v4.2.3 at `addons/godot_ai/`.
- Its plugin is listed in `project.godot` under `editor_plugins/enabled`.
- uv 0.12.19 and the pinned Python server dependencies are in `C:/Users/pmcga/Documents/Codex/2026-09-24/wh/godot-mcp-install/`.
- Codex's existing user config has a new `godot-ai` stdio entry. It starts the authenticated attach bridge with the exact server version, explicit portable cache and Python paths, ports 8000/9500, and telemetry disabled. Other MCP entries were preserved.
- No Claude configuration was changed.

## Finish activation

1. Save any open Godot work and close Hollowtide's editor normally.
2. Restart the Godot AI MCP connection in Codex settings, or restart Codex.
3. Double-click `tools/open-hollowtide-with-mcp.cmd`. This opens Hollowtide with the portable uv dependency available to that editor process. It does not change the Windows PATH permanently.
4. Confirm the Godot AI dock reports a connected server. Then ask the assistant to read Hollowtide's current scene hierarchy.

Do not open a second editor for this same project while the first is still open.

## What was checked

The release archive hash matched GitHub's release digest. The release manifest's RSA signature was verified against the upstream release public key; all 313 inventory file hashes matched. The Python server installed successfully and its command help runs. `codex mcp get godot-ai --json` confirms the enabled registration.

The live connection is **not yet verified**. The Codex execution sandbox prevented creation of `C:/Users/pmcga/AppData/Local/godot-ai/runtime`; a request for write access returned no grant. The server reported `ATTACH_RUNTIME_DIR_ERROR`. This is not evidence of a problem with the normal user's Windows permissions. Do not change Windows security settings or run as administrator to work around it. Activate normally in the desktop clients and check again.

Desktop screenshot capture also failed with `SetIsBorderRequired: No such interface supported`; Godot exposed only its window frame through accessibility. The active editor was not closed or manipulated blindly.

## Downloaded ChatGPT web tunnel

Reviewed `Downloads/chatgpt-web-tunnel-for-godot-ai-v0.1.0-ASSET-STORE.zip`, including its README and tunnel manager source. It is a companion Godot add-on, not the MCP server itself. It forwards ChatGPT web requests through OpenAI Secure MCP Tunnel to Godot AI.

The downloaded 0.1.0 copy targets Godot AI 3.2.0. The author's current 0.3.0 documentation describes Godot AI 4 capability authentication and rotation. Do not install the old archive over this v4 setup. No tunnel add-on or remote connection was installed during this task.

ChatGPT web setup additionally needs an OpenAI Platform tunnel, runtime API key, and ChatGPT developer-mode access. Enter credentials directly in the service/add-on when setting that up; never paste them into project files or chat. No keys or tunnels were created.

References:

- https://github.com/michaltomczykowski/godot-ai-chatgpt-web-tunnel
- https://developers.openai.com/api/docs/guides/secure-mcp-tunnels
- https://developers.openai.com/codex/mcp

## Maintenance

Keep the portable installation directory: Codex and the launcher reference it. Reconfigure both paths if moving it. Use Godot AI's supported updater and review the generated client command when updating. The current version pin and portable cache are deliberate. To disable the add-on, use Godot Project Settings > Plugins; to disable the connection, use Codex MCP settings. Do not overwrite a future installed add-on tree with this downloaded archive.
