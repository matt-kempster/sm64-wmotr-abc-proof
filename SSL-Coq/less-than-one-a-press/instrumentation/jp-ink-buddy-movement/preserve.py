"""Archive the three checked runs; preserve exact source and compressed raw logs."""
import gzip
import hashlib
import json
import pathlib
import shutil
import sys

here = pathlib.Path(__file__).resolve().parent
project = here.parent.parent
manifest = []
for mode, label in [(1,'drop'),(2,'throw'),(3,'no-retarget')]:
    source = project / 'build' / ('jp-buddy-mode%d-20261114-v3' % mode)
    target = here / 'records' / label
    target.mkdir(parents=True, exist_ok=True)
    result = json.loads((source / 'result.json').read_text())
    assert result['passed']
    for name in ['result.json','selected-trace.txt','probe-source.c','prefix-source.c','run-source.sh','checker-source.py']:
        shutil.copyfile(source / name, target / name)
    # Checker is preserved as the exact version that validated the output.
    assert (target / 'checker-source.py').read_bytes() == (here / 'check.py').read_bytes()
    (target / 'raw.log.gz').write_bytes(gzip.compress((source / 'raw.log').read_bytes(),mtime=0))
    manifest.append(dict(mode=mode,label=label,files={p.name:hashlib.sha256(p.read_bytes()).hexdigest() for p in sorted(target.iterdir())}))
(here / 'manifest.json').write_text(json.dumps(manifest,indent=2)+'\n')
print('Preserved three checked original-JP runs.')
