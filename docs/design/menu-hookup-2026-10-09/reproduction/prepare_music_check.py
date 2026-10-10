from pathlib import Path
W=Path(__file__).parent
source=Path('C:/Users/pmcga/dev/hollowtide/tools/debug/music_check.gd').read_text()
assert source.rstrip().endswith('quit()')
source=source.replace('\tquit()','\t# Review-only teardown: let the forced faint/evolution/clear timers finish.\n\tawait _frames(180)\n\tfor child in root.get_children(): child.queue_free()\n\tMusic._inst = null\n\tawait _frames(4)\n\tquit()')
(W/'music_check.gd').write_text(source)
print('Preserved original music fixture; added isolated async teardown only.')
