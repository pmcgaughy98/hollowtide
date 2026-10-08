from pathlib import Path
old=Path('C:/Users/pmcga/Documents/Codex/2026-10-01/referenced-chatgpt-conversation-this-is-an/arena-consistency-2026-10-07/source-audit/audit_originals.py')
out=Path('C:/Users/pmcga/Documents/Codex/2026-10-01/referenced-chatgpt-conversation-this-is-an/arena-ironvent-consistency-2026-10-07/source-audit/audit_originals.py')
s=old.read_text(encoding='utf-8-sig')
s=s.replace('/arena-consistency-2026-10-07/source-audit','/arena-ironvent-consistency-2026-10-07/source-audit')
s=s.replace("FORMS=['kithflare','sparkwick','stormwick','tallowroot','huskward','rampartroot','rimefin','riftfin','scourmaw']", "FORMS=['cinderhide','clinkerhide','ironvent']\nOLD_FORMS=['kithflare','sparkwick','stormwick','tallowroot','huskward','rampartroot','rimefin','riftfin','scourmaw']")
s=s.replace("BASES={n:(SRC/f'{n}_arena_front_take2_clear.png' if n in ('kithflare','tallowroot','rimefin') else SRC/'forms'/f'{n}.png') for n in FORMS}", "BASES={n:SRC/'forms'/f'{n}.png' for n in FORMS}")
s=s.replace("files.update(SRC.glob('*_arena_rotation_3x3.png')); files.update((SRC/'forms').glob('*_arena_rotation_3x3.png')); files.update((SRC/'walk').glob('*_sheet.png'))", "for n in FORMS:\n    files.update((SRC/'forms').glob(n+'*.png')); files.update((SRC/'walk').glob(n+'*_sheet.png'))")
s=s.replace("(W/'before-manifest.json').write_text(json.dumps({'project':str(P),'files':manifest,'protected_code_and_tools':sorted(protected,key=lambda x:x['path'])},indent=2),encoding='utf8')", """protected_assets=[]
for n in OLD_FORMS:
    oldfiles=list((P/'assets/sprites/arena'/n).glob('*.png'))+list((P/'assets/sprites/arena'/n/'small').glob('*.png'))+list((SRC/'walk').glob(n+'*_sheet.png'))
    for p in sorted(oldfiles): protected_assets.append({'path':p.relative_to(P).as_posix(),'sha256':sha(p),'bytes':p.stat().st_size})
(W/'before-manifest.json').write_text(json.dumps({'project':str(P),'files':manifest,'protected_code_and_tools':sorted(protected,key=lambda x:x['path']),'protected_assets':sorted(protected_assets,key=lambda x:x['path']),'authorized_report_tool_exception':'tools/arena/report_consistency.py'},indent=2),encoding='utf8')""")
s=s.replace("mirror={'kithflare':{'e':'w'},'rimefin':{'e':'w'},'sparkwick':{'e':'w'},'riftfin':{'nw':'ne'},'scourmaw':{'sw':'se'}}", "mirror={}")
s=s.replace("'protected_code':len(protected),", "'protected_code':len(protected),'protected_old_nine_assets':len(protected_assets),")
out.write_text(s,encoding='utf8')
print('Prepared new-three read-only audit script')
