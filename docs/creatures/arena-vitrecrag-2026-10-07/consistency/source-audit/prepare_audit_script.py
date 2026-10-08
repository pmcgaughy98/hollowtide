from pathlib import Path
old=Path('C:/Users/pmcga/Documents/Codex/2026-10-01/referenced-chatgpt-conversation-this-is-an/arena-ironvent-consistency-2026-10-07/source-audit/audit_originals.py')
out=Path('C:/Users/pmcga/Documents/Codex/2026-10-01/referenced-chatgpt-conversation-this-is-an/arena-vitrecrag-consistency-2026-10-07/source-audit/audit_originals.py')
s=old.read_text(encoding='utf-8-sig').replace('/arena-ironvent-consistency-2026-10-07/source-audit','/arena-vitrecrag-consistency-2026-10-07/source-audit')
s=s.replace("FORMS=['cinderhide','clinkerhide','ironvent']", "FORMS=['fusern','slagglass','vitrecrag']")
s=s.replace("OLD_FORMS=['kithflare','sparkwick','stormwick','tallowroot','huskward','rampartroot','rimefin','riftfin','scourmaw']", "OLD_FORMS=['kithflare','sparkwick','stormwick','tallowroot','huskward','rampartroot','rimefin','riftfin','scourmaw','cinderhide','clinkerhide','ironvent']")
out.write_text(s,encoding='utf8')
print('Prepared new-three Vitrecrag-line read-only audit')
