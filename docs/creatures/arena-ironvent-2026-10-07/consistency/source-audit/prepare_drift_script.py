from pathlib import Path
old=Path('C:/Users/pmcga/Documents/Codex/2026-10-01/referenced-chatgpt-conversation-this-is-an/arena-consistency-2026-10-07/source-audit/analyze_palette_drift.py')
out=Path('C:/Users/pmcga/Documents/Codex/2026-10-01/referenced-chatgpt-conversation-this-is-an/arena-ironvent-consistency-2026-10-07/source-audit/analyze_palette_drift.py')
out.write_text(old.read_text(encoding='utf-8-sig').replace('/arena-consistency-2026-10-07/source-audit','/arena-ironvent-consistency-2026-10-07/source-audit'),encoding='utf8')
