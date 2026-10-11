from pathlib import Path
C=Path('D:/dev/hollowtide-world-refinement-20261008/project')
p=C/'scripts/creature_prologue.gd';s=p.read_text()
start=s.index('\tvar tiles:=PackedByteArray()');end=s.index('\tleader_sprite=actor',start)
s=s[:start]+'''\tbank=preload("res://scripts/ui/waking_bank.gd").new()
\tbank.reduce_motion=reduce_motion
\tvp.add_child(bank)
'''+s[end:]
s=s.replace('awakening, another survivor, then Highbank.','pilot riverbank collapse, a Wayline trainee, then Highbank.')
s=s.replace('const Painter=preload("res://scripts/dungeon/floor_painter.gd")\n','').replace('const Gen=preload("res://scripts/hollow/hollow_gen.gd")\n','')
s=s.replace('var dialogue:Node2D','var dialogue:Node2D\nvar bank:Node2D')
s=s.replace('\tpartner_sprite.visible=phase>0','\tpartner_sprite.visible=phase>0\n\tbank.companion_visible=phase>0\n\tbank.queue_redraw()')
s=s.replace('\tif phase==0:\n\t\ttitle.text=', '\t# Dialogue proposals for the approved pilot outline; final wording remains Preston\'s.\n\tif phase==0:\n\t\ttitle.text=',1)
s=s.replace('The river has gone quiet. You press against the clay and feel...\\n','The bank collapses. Across the river, pale light spills from the rising Hollow.\\nYou remember being human. ')
s=s.replace('"You heard the bank give way too? Stay close. There must be a way out."\\nWhich survivor do you call back to?','"I’m a Wayline trainee, sent to gather mail the river tore loose. Something told me to come down here tonight."\\nWhose voice do you answer?')
s=s.replace(' waits beside you. A break in the clay opens onto the path to Highbank.\\nFollow the village lights. Watch each other as you go.',' says, "No one runs a route alone. They keep turning me away without a partner."\\nYou need a guide. They need a partner. Together, you head for Highbank.')
p.write_text(s,encoding='utf-8')
print('Revised only waking presentation, text and comments.')
