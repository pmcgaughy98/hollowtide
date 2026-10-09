from pathlib import Path
root=Path(__file__).parent
stage=root/'project'
text=(stage/'tools/debug/relay_yard_check.gd').read_text()
text=text.replace('D:/dev/hollowtide-map-20261008/review/','D:/dev/hollowtide-world-refinement-20261008/review/relay/')
text=text.replace('    if journey.has_node("RelayPractice"):\n','    verify("Atlas hidden during practice",not journey.atlas._hud_button.visible)\n    await key(KEY_M)\n    verify("Atlas cannot open over practice",not journey.atlas.opened)\n    if journey.has_node("RelayPractice"):\n',1)
text=text.replace('    verify("Cached clues and completion retained",','    await key(KEY_M)\n    verify("Atlas restored after practice and travel",journey.atlas.opened and journey.atlas.known("historic_street"))\n    await key(KEY_M)\n    verify("Cached clues and completion retained",')
(stage/'tools/debug/world_route_regression.gd').write_text(text)
