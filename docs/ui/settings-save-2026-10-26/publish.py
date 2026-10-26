from pathlib import Path
import difflib,hashlib,json,re,shutil
W=Path(__file__).parent;L=Path('C:/Users/pmcga/dev/hollowtide');E=L/'docs/ui/settings-save-2026-10-26'
def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest()
base=json.loads((W/'protected-before.json').read_text(encoding='utf-8'))
owned={'scripts/main_menu.gd'}
for p,h in json.loads((W/'installed-files.json').read_text(encoding='utf-8')).items():assert sha(L/p)==h,p
assert not E.exists()
changed=[p for p,h in base.items() if not (L/p).is_file() or sha(L/p)!=h]
concurrent=[p for p in changed if p not in owned and p not in ('docs/AI_COLLABORATION.md','docs/team/CODEX_TASKS_2026-10-22.md')]
for rel in concurrent:
    if (L/rel).is_file():
        dest=W/'concurrent-at-finish'/rel;dest.parent.mkdir(parents=True,exist_ok=True);shutil.copy2(L/rel,dest)
for rel in ('docs/AI_COLLABORATION.md','docs/team/CODEX_TASKS_2026-10-22.md'):
    dest=W/'docs-before-publication'/rel;dest.parent.mkdir(parents=True,exist_ok=True);shutil.copy2(L/rel,dest)
old=(W/'originals/scripts/main_menu.gd').read_text(encoding='utf-8');new=(L/'scripts/main_menu.gd').read_text(encoding='utf-8')
(W/'source.diff').write_text(''.join(difflib.unified_diff(old.splitlines(True),new.splitlines(True),fromfile='original/scripts/main_menu.gd',tofile='installed/scripts/main_menu.gd')),encoding='utf-8')
cmd={'command':['C:/Users/pmcga/.cache/codex-runtimes/codex-primary-runtime/dependencies/python/python.exe','tools/debug/run_checks.py','rebind','--jobs','1','--logs',str(W/'runner'),'--md',str(W/'runner-result.md')],'cwd':str(L),'APPDATA':str(W/'runner-profile'),'LOCALAPPDATA':str(W/'runner-local-profile'),'exit':0,'result':'PASS rebind_check (26 assertions); known exit noise retained'}
(W/'runner-command.json').write_text(json.dumps(cmd,indent=2),encoding='utf-8')
E.mkdir(parents=True)
for name in ('originals','prepared','native','runner','proposal','concurrent-at-install','concurrent-at-finish','docs-before-publication'):
    if (W/name).exists():shutil.copytree(W/name,E/name,ignore=shutil.ignore_patterns('__pycache__','*.pyc'))
for p in W.iterdir():
    if p.is_file() and p.name!='HANDOFF.md' and p.suffix in ('.py','.gd','.md','.json','.log','.diff'):shutil.copy2(p,E/p.name)
private=W/'installed-profile/Godot/app_userdata/Hollowtide'
for p in private.glob('*.cfg*'):
    if p.is_file():
        dest=E/'private-test-configs'/p.name;dest.parent.mkdir(exist_ok=True);shutil.copy2(p,dest)
handoff=L/'docs/team/CODEX_HANDOFF_2026-10-26_settings_save.md';assert not handoff.exists();shutil.copy2(W/'HANDOFF.md',handoff)
result='''
## Codex result, October 26: C1 / task 4 title save

TITLE PORTION COMPLETE/INSTALLED: main_menu.gd loads current preferences before updating its five title keys, writes the complete .tmp then renames over the final file. Errors retain the dirty/retry flag and show the existing error; a successful retry clears it. Success refreshes shared preference caches. Native28/28 (save/integration16, fresh process4, failure/retry8); normal/restart logs clean, failure injections emit only the expected two warnings. Official rebind regression PASS,26 assertions, exit0 (its existing14-instance/5-resource exit noise retained). Real title controls preserve unknown keys, female courier and audio values; separate game prefs are byte-exact at the title-save boundary; later migration/rebinds/text speed survive. Earlier title bounds retained. Only the owned main_menu save method changed; Claude's concurrent files were preserved and recorded. Private profiles/settings/saves only; no art/rules/generation/paid call/commit. [Evidence and source diff](../ui/settings-save-2026-10-26/README.md); [handoff](CODEX_HANDOFF_2026-10-26_settings_save.md).

Original task4 is NOT claimed fully closed across all writers. Source issue for Claude's active pass7 UI lane: shared UI.write_prefs moves the final file to .bak before installing .tmp, but its readers do not read .bak. A private diagnostic reproduces an interruption state with valid backup settings yet default values returned. ui_style.gd/game_pause_menu.gd remain untouched as active Claude files. A concrete candidate-only fix is staged in the evidence folder's proposal/shared-pause-save.diff (copy prior final to backup, propagate backup-copy errors, then replace final). Candidate8/8 tests pass interruption-after-backup, existing-reader recovery, successful replacement and failed-backup preservation; NOT INSTALLED. Please rebase/integrate the small diff in the active UI lane. Title's direct rename avoids this separate gap. No cross-chat message sent. Next independent Codex factory slice C3 (type roles/shared button styles); C4 and remaining requests still pending, proposed words retain flags.
'''
queue=L/'docs/team/CODEX_TASKS_2026-10-22.md';raw=queue.read_bytes();assert raw==(W/'docs-before-publication/docs/team/CODEX_TASKS_2026-10-22.md').read_bytes()
nl=b'\r\n' if b'\r\n' in raw else b'\n';queue.write_bytes(raw+result.encode('utf-8').replace(b'\n',nl))
collab=L/'docs/AI_COLLABORATION.md';raw=collab.read_bytes();assert raw==(W/'docs-before-publication/docs/AI_COLLABORATION.md').read_bytes()
head,sep,rest=raw.partition(b'\n');nl=b'\r\n' if b'\r\n' in raw else b'\n'
entry='''
## Codex: title settings preservation and save replacement, C1 (October 26, 2026)

C1/task4 TITLE PORTION COMPLETE: main_menu loads prior prefs, writes .tmp then replaces final, keeps errors/retry flag on failure, refreshes shared cache and clears an old error after success. Native28/28, official rebind PASS26 assertions, private profiles only. One owned source method edited, earlier title bounds retained; concurrent Claude source changes preserved/archived. [Evidence](ui/settings-save-2026-10-26/README.md); [handoff](team/CODEX_HANDOFF_2026-10-26_settings_save.md). Task4 across all writers remains OPEN: current shared UI.write_prefs moves final to .bak before replacement but readers do not recover .bak; private interruption-state reproduction confirms defaults despite valid backup. Active pass7 UI files left intact. Concrete candidate-only proposal/shared-pause-save.diff and8/8 proposal checks staged for Claude to rebase/integrate (copy old final to backup before replacing; propagate backup-copy errors); NOT INSTALLED. Normal/current pause interoperability checked, no blanket power-cut recovery claim. Official rebind retains its runner-exempt14-instance/5-resource exit diagnostics; normal native logs clean, injected failures have expected warnings. No real settings/save, asset, rule, paid call, generation, message or commit change. Next independent Codex-owned slice C3 roles/styles; other factory work/proposed words remain pending.

'''
collab.write_bytes(head+sep+entry.encode('utf-8').replace(b'\n',nl)+rest)
assert queue.read_bytes().startswith((W/'docs-before-publication/docs/team/CODEX_TASKS_2026-10-22.md').read_bytes())
assert collab.read_bytes().endswith((W/'docs-before-publication/docs/AI_COLLABORATION.md').read_bytes().partition(b'\n')[2])
for p,h in json.loads((W/'installed-files.json').read_text()).items():assert sha(L/p)==h,p
after=[p for p,h in base.items() if not (L/p).is_file() or sha(L/p)!=h]
assert set(after)<=set(concurrent)|owned|{'docs/AI_COLLABORATION.md','docs/team/CODEX_TASKS_2026-10-22.md'},after
for rel in concurrent:
    if (L/rel).is_file():assert sha(L/rel)==sha(W/'concurrent-at-finish'/rel),f'Concurrent edit during publication: {rel}'
(E/'publication.json').write_text('{}',encoding='utf-8')
links=0
for p in (E/'README.md',handoff):
    for target in re.findall(r'\]\(([^)]+)\)',p.read_text(encoding='utf-8')):
        assert (p.parent/target).exists(),(p,target)
        links+=1
receipt={'protected_before':len(base),'protected_unchanged_after_docs':len(base)-len(after),'owned_production_change':['scripts/main_menu.gd'],'concurrent_source_changes_preserved':concurrent,'all_changed_existing_paths':after,'current_documentation_preserved':True,'native_installed':'28/28','official_rebind':'PASS,26 assertions,exit0; known noise archived','shared_pause_gap':'reproduced; active Claude-owned source unchanged','candidate_shared_fix':'8/8, proposal only, NOT installed','local_links_checked':links,'evidence':str(E),'handoff':str(handoff)}
(W/'publication.json').write_text(json.dumps(receipt,indent=2),encoding='utf-8');shutil.copy2(W/'publication.json',E/'publication.json');print(json.dumps(receipt,indent=2))
