from pathlib import Path
W=Path(__file__).parent
p=W/'verify.py';s=p.read_text()
s=s.replace("'native_assertions':13", "'native_assertions':19")
s=s.replace("'runtime_scope':['scripts/town/highbank_ground_painter.gd','scripts/town/item_shop_painter.gd']", "'runtime_scope':['scripts/creature_opening.gd','scripts/town/highbank_ground_painter.gd','scripts/town/item_shop_painter.gd'],'hall_approach_native_assertions':6,'title_without_foreground_actors':True,'new_game_prologue_smoke':True,'claude_title_theme_preserved':True")
s=s.replace("'concurrent_preserved':list(changed),'new_external_changes':list(new_changes)", "'concurrent_preserved_count':len(changed),'new_external_changes_count':len(new_changes)")
p.write_text(s)
