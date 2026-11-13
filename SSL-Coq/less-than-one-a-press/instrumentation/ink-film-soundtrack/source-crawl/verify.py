import hashlib
import json
from pathlib import Path
import re
import runpy
import sys
from unittest.mock import patch

root = Path.cwd()
proof = root / 'reference-sm64-wmotr-abc-proof/SSL-Coq/less-than-one-a-press'
record = proof / 'build/jp-ink-handoff-demo-20261112-a'
archive = proof / 'docs/media/ink-handsfree-native'
receipt = json.loads((archive / 'supplied-handoff-receipt.json').read_text())
sha = lambda p: hashlib.sha256(p.read_bytes()).hexdigest()

checker = proof / 'instrumentation/jp-ink-handsfree-demo/check-handoff.py'
sys.argv = [str(checker), str(record)]
with patch.object(Path, 'write_text') as write:
    runpy.run_path(str(checker), run_name='__main__')
assert json.loads(write.call_args.args[0]) == receipt
assert sha(record / 'trace.txt') == sha(archive / 'supplied-handoff-trace.txt')
assert sha(record / 'probe.so') == sha(record / 'final-source-probe.so')
assert sha(root / 'reference-sm64-decomp/baserom.jp.z64') == receipt['romSha256']
media = proof / 'docs/media/ink-handsfree-and-handoff-demo.mp4'
site = root / 'pyramid-proof-assumptions-site/ink-handoff-evidence/ink-handsfree-followup'
video_receipt = json.loads((site / 'ink-handsfree-and-handoff-demo-receipt.json').read_text())
assert sha(media) == sha(site / media.name) == video_receipt['videoSha256']
assert sha(site / 'native/supplied-handoff-trace.txt') == sha(record / 'trace.txt')
assert json.loads((site / 'native/supplied-handoff-receipt.json').read_text()) == receipt
trace = (record / 'trace.txt').read_text().splitlines()
renders = [tuple(map(int, re.search(r'step=(\d+),timer=(\d+),', line).groups()))
           for line in trace if line.startswith('HANDS_RENDER,')]
requests = [tuple(map(int, re.search(r'index=(\d+),requestTimer=(\d+),previousFramebuffer=1', line).groups()))
            for line in trace if line.startswith('HANDS_SCREENSHOT,')]
assert len(renders) == len(requests)
assert [step for step, _ in renders[:31]] == [*range(1, 28), 30, 31, 32, 33]
for index, (n, timer) in enumerate(requests):
    assert n == index and timer == renders[index][1]
    if 1 <= n <= 26 or 28 <= n <= 63:
        assert renders[index - 1][0] == (n if n <= 26 else n + 2)
print(f"Matched the archived trace and all {len(receipt['screenshots'])} PNG hashes; verified the ROM and original video hashes.")
print("Confirmed PNG 5, 6, 7 and 28 correspond to completed inputs 5, 6, 7 and 30.")

