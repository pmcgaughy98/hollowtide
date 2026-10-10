from pathlib import Path
import hashlib,json
W=Path(__file__).parent;L=Path('C:/Users/pmcga/dev/hollowtide')
def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest()
base=json.loads((W/'baseline.json').read_text());protected=json.loads((W/'preinstall-protected.json').read_text());pending=json.loads((W/'pending-install.json').read_text())
changes={r:{'before':h,'now':sha(L/r) if (L/r).exists() else None} for r,h in protected.items() if not (L/r).exists() or sha(L/r)!=h}
owned=[i['path'] for i in pending if not (L/i['path']).exists() or sha(L/i['path'])!=i['after']]
art={r:h for r,h in base.items() if r.startswith('assets/sprites/') or ('original' in r.lower() and Path(r).suffix.lower() in ['.png','.bak'])}
art_changes=[r for r,h in art.items() if not (L/r).exists() or sha(L/r)!=h]
result={'protected_exact':len(protected)-len(changes),'source_sprites_and_original_backups_exact':not art_changes,'sprite_and_backup_files_checked':len(art),'owned_runtime_exact':not owned,'concurrent_before_install_retained':json.loads((W/'concurrent-before-install.json').read_text()),'changes_since_preinstall':changes,'owned_mismatches':owned,'art_mismatches':art_changes}
(W/'installation.json').write_text(json.dumps(result,indent=2));print(json.dumps(result,indent=2));raise SystemExit(1 if changes or owned or art_changes else 0)
