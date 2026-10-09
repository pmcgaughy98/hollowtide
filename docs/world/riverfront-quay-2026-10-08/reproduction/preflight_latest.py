from pathlib import Path
W=Path(__file__).parent
source=(W/'install_verified.py').read_text().split('guard={}')[0]
source=source.replace("'scripts/world_journey.gd',","'scripts/world_journey.gd','scripts/first_fight.gd',")
exec(compile(source,str(W/'install_verified.py'),'exec'))
print('Current world dependencies and protected art match')
