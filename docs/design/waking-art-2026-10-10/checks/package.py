from pathlib import Path
import hashlib,json,shutil,difflib
W=Path(__file__).parent;C=Path('D:/dev/hollowtide-world-refinement-20261008/project');L=Path('C:/Users/pmcga/dev/hollowtide')
def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest()
files=['scripts/ui/waking_bank_finish.gd','scripts/ui/hollow_entrance_finish.gd','scripts/ui/journey_shadows.gd','scripts/riverbank_journey.gd','scripts/arena/starward_finish.gdshader','scenes/waking_riverbank.tscn','scenes/hollow_entrance.tscn','assets/sprites/world/waking_bank_2026_10_10/waking_native.png','assets/sprites/world/waking_bank_2026_10_10/entrance_native.png','scripts/ui/waking_bank.gd','scripts/arena/creature_finish.gd','scripts/town/hollow_approach.gd','scripts/creature_prologue.gd']
baseline=json.loads((W/'install-baseline.json').read_text())
package=W/'package';package.mkdir(exist_ok=True)
for r in files:
 p=package/'candidate'/r;p.parent.mkdir(parents=True,exist_ok=True);shutil.copy2(C/r,p)
 if (L/r).exists():
  assert sha(L/r)==baseline[r],f'Concurrent edit to owned file: {r}'
  p=package/'originals'/r;p.parent.mkdir(parents=True,exist_ok=True);shutil.copy2(L/r,p)
  diff=''.join(difflib.unified_diff((L/r).read_text(encoding='utf-8').splitlines(True),(C/r).read_text(encoding='utf-8').splitlines(True),fromfile=r+' original',tofile=r+' candidate'))
  p=package/'diffs'/(r+'.diff');p.parent.mkdir(parents=True,exist_ok=True);p.write_text(diff,encoding='utf-8')
 else:assert r not in baseline,r
current_ai=(L/'docs/AI_COLLABORATION.md').read_text(encoding='utf-8')
note='''## Codex: detailed waking bank, immediate close-up entrance and Starward finish (October 10, 2026)

Preston requested finished environment assets matching the interiors, sel-out on the bank and close-up structure, the walkway opening that close-up immediately after partner choice, and Starward's outline/detail everywhere including portraits and fringe. Two versioned native 384x216 backgrounds now replace the simple bank/entrance paintings. The bank keeps its exact original code-painter fallback; water glints are bounded to painted river pixels. Both scenes use the shared material rim and bounded detail shader, preserving water/glows/standing pads/letters. Existing creature sizes, source palettes and finished actors remain installed. Built-in imagegen was used with Hall/Home and the prior scene as references; exact prompts, unmodified generated sources and nearest preparation are archived.

After agreement, the existing team record goes to a walkable bank. Its stone walkway node opens a separate close-up entrance. Esc returns beside the walkway; H or the south trail continues to Highbank. Before the first trial clear, the arch invites the pair to tell Highbank what they found. Claude's concurrent hub_town -> hollow_approach mission route is retained byte-exact in the town; his approach movement/cross/fades/run handoff remain intact, with only its entrance asset loader/nearest filter adapted to the same finished scenery. No Guildmaster dialogue, save fields, dungeon rules, settings or commits changed.

Starward alone opts into the shared selective material rim plus 0.55 bounded internal ink on every sprite/action and all eight expression portraits. A pooled portrait restores the normal shader for other forms. The head/neck fringe is included. Original PNGs, current cream/pink palette, silhouette alpha compared with the prior finish, bright cream highlights and portrait frame clipping remain intact. Native tests include all 329 Starward textures, real town/dungeon expressions, all six starter pairings and mouse/keyboard/Back, real walkway entry/return and the current soul/town/first-dungeon/Hollow/faint state loop. Evidence and source scope: [waking/entrance/Starward handoff](design/waking-art-2026-10-10/README.md). Preserve the original backups, seven-form refinements, darker jade Oxbowarchon, Sparkwick and Skimlet corrections, Gruntle clipping and Claude's concurrent code. These environment designs and additional partner line are presentation proposals, not approval of new lore.

'''
ai='docs/AI_COLLABORATION.md'; p=package/'candidate'/ai;p.parent.mkdir(parents=True,exist_ok=True)
assert current_ai.startswith('# Working Together on Hollowtide\n\n')
p.write_text(current_ai.replace('# Working Together on Hollowtide\n\n','# Working Together on Hollowtide\n\n'+note,1),encoding='utf-8')
p=package/'originals'/ai;p.parent.mkdir(parents=True,exist_ok=True);shutil.copy2(L/ai,p)
files.append(ai);baseline[ai]=sha(L/ai)
shutil.copytree(W/'sources',package/'sources',dirs_exist_ok=True)
for name in ['prompt.txt','entrance-prompt.txt']:shutil.copy2(W/name,package/name)
shutil.copytree(W/'review',package/'review',dirs_exist_ok=True)
checks=package/'checks';checks.mkdir(exist_ok=True)
for p in W.iterdir():
 if p.is_file() and p.suffix in ['.gd','.py','.json','.log'] and p.name not in ['package.py']:shutil.copy2(p,checks/p.name)
manifest={'files':{r:{'before':baseline.get(r),'candidate':sha(package/'candidate'/r)} for r in files},'source_images':{p.name:sha(p) for p in (package/'sources').iterdir()},'preserved_claude_town':sha(L/'scripts/town/hub_town.gd')}
(W/'install-manifest.json').write_text(json.dumps(manifest,indent=2));(package/'manifest.json').write_text(json.dumps(manifest,indent=2))
(package/'README.md').write_text('''# Waking bank, close-up entrance and Starward finish — 2026-10-10

Installed presentation work requested by Preston. Walk from the partner agreement to the stone walkway to enter the close-up immediately. Esc returns to the bank; H continues to Highbank, or walk to the south trail and press E. The initial arch directs the pair to Highbank before the existing first trial. On later Hollow missions, Claude's cinematic approach now uses the same finished backgrounds. His town hook and movement/cross/fade/dungeon methods are preserved.

## Art and finish

Two opaque backgrounds, generated with **built-in imagegen**, using the existing waking composition and finished Hollowtide Home/Hall interiors as references. The close-up also references the generated waking ruin. Exact tool prompts: [riverbank](prompt.txt), [entrance](entrance-prompt.txt). Untouched 1672x941 results: [bank source](sources/waking-source.png), [entrance source](sources/entrance-source.png). Godot Image.resize with INTERPOLATE_NEAREST prepares 384x216 siblings; no source repaint, alpha keying or palette quantization. Native viewport then presents at nearest 3x. Originals and every candidate file are archived separately.

The existing shared sel-out helper and dungeon material shader finish bank strata, roots, ruin, causeway, close-up masonry/arch and parapets. Masks exclude river, bright glows, letters and original actor standing pads. No shared shader was rewritten. Existing creature sources, sizes and house finish are preserved; moving contact shadows ground the team.

Starward opts into a dedicated wrapper of the existing shared rim/detail shaders. Material-coloured dark rim plus 0.55 detail applies to all 329 facings/action frames/portraits, including all eight emotions and head/neck fringe. Shared Finish.apply follows texture changes, restoring the original shader and preset for other forms. No creature PNG edits or regeneration. Bright cream highlights and silhouette alpha compared with the prior finish remain exact. Source hashes: checks/starward-sources.json.

## Native verification

96/96 waking choice/UI/input checks; 17/17 real walking, collision, node transition, return, Highbank and state checks; 11/11 bank-art/fallback/framing checks; 5/5 bank material GPU checks. All 329 Starward textures receive the rim/detail finish; preserved creature controls and pooled portrait switching are compared on the native GPU. Real town and dungeon dialogue exercise all eight expressions, clipping/dismissal and Gruntle reuse. The current soul handoff and real town loop through trial clear, Claude's Hollow approach, inventory/taught/IQ carry and faint loss are checked. Final live outputs/logs are in review/live and checks/live-*.log; audit records exact installed hashes and concurrent files retained. Intermediate fixture errors are superseded by final live results.

## Ownership and preservation

Only the manifest's candidate files are installed. hub_town.gd is not installed or edited: Claude's concurrent new Hollow approach hook is retained. His hollow_approach.gd keeps all movement, cross, entry, fades, effect drawing and state methods; only the art path/loader and nearest texture filter change. Prologue partner/soul selection and the existing team record stay intact, with the user-requested bank destination and new confirmation text. Bank code painter remains byte-equivalent to the original fallback. Sources/backups, seven-form refinements, Oxbowarchon jade, Sparkwick/Skimlet corrections and Gruntle clipping remain. No main-scene setting, battle/save rule, Guildmaster story, asset regeneration of creatures or commit changes.
''',encoding='utf-8')
print('Packaged',len(files),'guarded files; Claude town preserved. Ready for scoped installation.')
