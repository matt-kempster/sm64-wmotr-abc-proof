"""Independently recheck all three durable trace archives without running a ROM."""
import gzip
import hashlib
import json
import pathlib
import shutil
import subprocess
import sys
import tempfile

here = pathlib.Path(__file__).resolve().parent
for entry in json.loads((here/'manifest.json').read_text()):
    source = here/'records'/entry['label']
    for name, digest in entry['files'].items():
        assert hashlib.sha256((source/name).read_bytes()).hexdigest() == digest
    expected = json.loads((source/'result.json').read_text())
    with tempfile.TemporaryDirectory(prefix='sm64-buddy-check-') as tmp:
        out = pathlib.Path(tmp)
        for name in ['probe-source.c','prefix-source.c','run-source.sh','checker-source.py']:
            shutil.copyfile(source/name, out/name)
        raw = gzip.decompress((source/'raw.log.gz').read_bytes())
        (out/'raw.log').write_bytes(raw)
        trace = b'\n'.join(s for s in raw.splitlines() if s.startswith(b'BUDDY_')) + b'\n'
        (out/'trace.txt').write_bytes(trace)
        subprocess.run([sys.executable, str(out/'checker-source.py'), str(out), str(entry['mode'])],check=True,stdout=subprocess.PIPE)
        actual = json.loads((out/'result.json').read_text())
        for key in expected:
            if key != 'source_sha256': assert actual[key] == expected[key], key
        assert set(actual['source_sha256'].values()) == set(expected['source_sha256'].values())
    print('PASS archive', entry['label'])
