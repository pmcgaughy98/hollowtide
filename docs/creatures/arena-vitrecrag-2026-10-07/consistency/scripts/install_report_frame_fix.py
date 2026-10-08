"""Install the reviewed empty-frame validator correction; preserve its prior version."""
from pathlib import Path
import hashlib,shutil
W=Path(__file__).resolve().parent;P=Path('C:/Users/pmcga/dev/hollowtide')
A=P/'docs/creatures/arena-vitrecrag-2026-10-07/consistency'
def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest()
live=P/'tools/arena/report_consistency.py';archive=A/'scripts/report_consistency.py';new=W/'candidate-tools/report_consistency.py'
assert sha(live)==sha(archive),'Unexpected concurrent report change'
snapshot=A/'scripts/report_consistency-before-empty-frame-fix.py';assert not snapshot.exists()
shutil.copy2(live,snapshot);shutil.copy2(new,live);shutil.copy2(new,archive)
print('Corrected untouched-frame validation; previous reporter preserved.')
