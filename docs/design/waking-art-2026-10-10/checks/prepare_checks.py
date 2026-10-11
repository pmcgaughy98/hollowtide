from pathlib import Path
import shutil
W=Path(__file__).parent;prior=Path('D:/dev/hollowtide-pilot-waking-20261010');L=Path('C:/Users/pmcga/dev/hollowtide')
for name in ['waking_check.gd','before_check.gd']:
    s=(prior/name).read_text(encoding='utf-8').replace(str(prior).replace('\\','/'),str(W).replace('\\','/'))
    if name=='before_check.gd':
        s=s.replace('var pro:Node=load(W+"originals/scripts/creature_prologue.gd").new()', '''var pro:Node=load("res://scenes/creature_prologue.tscn").instantiate()''')
        s=s.replace('root.add_child(pro)','''root.add_child(pro)
\tawait frames(8)
\t# Render the original code bank as the same viewport background, retaining all real UI/actors.
\tpro.bank.artwork=null
\tpro.bank.background.texture=ImageTexture.create_from_image(pro.bank.paint())
\tpro.bank.queue_redraw()''')
    (W/name).write_text(s,encoding='utf-8')
# Current Claude fixtures: only isolate output, add success assertions and clean node/audio shutdown.
s=(L/'tools/debug/soul_prologue_check.gd').read_text(encoding='utf-8').replace('res://docs/design/soul-prologue-2026-10-10/',str(W).replace('\\','/')+'/review/soul/')
s=s.replace('\tquit()','''\tfor n in root.get_children():n.queue_free()
\tload("res://scripts/audio/music.gd")._inst=null
\tfor k in 12:await process_frame
\tquit(0 if ok_hand and ok_wake else 1)''')
(W/'soul_check.gd').write_text(s,encoding='utf-8')
s=(prior/'town_loop_check.gd').read_text(encoding='utf-8')
original=(L/'tools/debug/town_loop_check.gd').read_text(encoding='utf-8')
baseline=(prior/'originals').exists()
assert 'The Mouth of the Hollow' in original and '_finish_after_boss' in original
(W/'town_loop_check.gd').write_text(s,encoding='utf-8')
print('Prepared 95-check scene review, original-bank before previews, soul and town-loop checks.')
