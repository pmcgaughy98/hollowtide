# Waking bank, close-up entrance and Starward finish — 2026-10-10

Installed presentation work requested by Preston. Walk from the partner agreement to the stone walkway to enter the close-up immediately. Esc returns to the bank; H continues to Highbank, or walk to the south trail and press E. The initial arch directs the pair to Highbank before the existing first trial. On later Hollow missions, Claude's cinematic approach now uses the same finished backgrounds. His town hook and movement/cross/fade/dungeon methods are preserved.

## Art and finish

Two opaque backgrounds, generated with **built-in imagegen**, using the existing waking composition and finished Hollowtide Home/Hall interiors as references. The close-up also references the generated waking ruin. Exact tool prompts: [riverbank](prompt.txt), [entrance](entrance-prompt.txt). Untouched 1672x941 results: [bank source](sources/waking-source.png), [entrance source](sources/entrance-source.png). Godot Image.resize with INTERPOLATE_NEAREST prepares 384x216 siblings; no source repaint, alpha keying or palette quantization. Native viewport then presents at nearest 3x. Originals and every candidate file are archived separately.

The existing shared sel-out helper and dungeon material shader finish bank strata, roots, ruin, causeway, close-up masonry/arch and parapets. Masks exclude river, bright glows, letters and original actor standing pads. No shared shader was rewritten. Existing creature sources, sizes and house finish are preserved; moving contact shadows ground the team.

Starward opts into a dedicated wrapper of the existing shared rim/detail shaders. Material-coloured dark rim plus 0.55 detail applies to all 329 facings/action frames/portraits, including all eight emotions and head/neck fringe. Shared Finish.apply follows texture changes, restoring the original shader and preset for other forms. No creature PNG edits or regeneration. Bright cream highlights and silhouette alpha compared with the prior finish remain exact. Source hashes: checks/starward-sources.json.

## Native verification

96/96 waking choice/UI/input checks; 17/17 real walking, collision, node transition, return, Highbank and state checks; 11/11 bank-art/fallback/framing checks; 5/5 bank material GPU checks. All 329 Starward textures receive the rim/detail finish; preserved creature controls and pooled portrait switching are compared on the native GPU. Real town and dungeon dialogue exercise all eight expressions, clipping/dismissal and Gruntle reuse. The current soul handoff and real town loop through trial clear, Claude's Hollow approach, inventory/taught/IQ carry and faint loss are checked. Final live outputs/logs are in review/live and checks/live-*.log; audit records exact installed hashes and concurrent files retained. Intermediate fixture errors are superseded by final live results.

## Ownership and preservation

Only the manifest's candidate files are installed. hub_town.gd is not installed or edited: Claude's concurrent new Hollow approach hook is retained. His hollow_approach.gd keeps all movement, cross, entry, fades, effect drawing and state methods; only the art path/loader and nearest texture filter change. Prologue partner/soul selection and the existing team record stay intact, with the user-requested bank destination and new confirmation text. Bank code painter remains byte-equivalent to the original fallback. Sources/backups, seven-form refinements, Oxbowarchon jade, Sparkwick/Skimlet corrections and Gruntle clipping remain. No main-scene setting, battle/save rule, Guildmaster story, asset regeneration of creatures or commit changes.

## Final installed result

All twelve final native fixtures pass without errors or leaks. Starward GPU: 9/9 across 329 textures, including 117 changed head/neck fringe pixels; all eight emotions also pass in real town/dungeon dialogue. Team headshot and breathing preview receive the same finish. Waking 96/96; playable journey 17/17; bank art 11/11; bank finish 5/5. Entrance material GPU: 30,529 selected pixels changed, zero outside its mask, alpha and bright glow exact. Claude cinematic entrance uses nearest native art and the shared material finish; the preserved walk/cross/fade reaches the Hollow. The first trial/clear, return inventory/taught/IQ and faint loss loop passes.

Audit: 14 installed files and original backups match; Claude town hook is byte-exact. 419 baseline paths changed or were removed concurrently outside this scope; their current state was retained. 0 Starward source paths changed concurrently after the art snapshot; retained current live textures were used in final GPU review. Audit details: [audit](checks/audit.json). Godot generated import/UID cache was refreshed for live verification; project.godot and default_bus_layout.tres were not edited.
