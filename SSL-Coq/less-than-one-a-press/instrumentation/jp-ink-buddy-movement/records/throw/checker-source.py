"""Verify exact setup writes and conditional Buddy relocation, never reachability."""
import hashlib
import json
import pathlib
import re
import struct
import sys

out = pathlib.Path(sys.argv[1])
mode = int(sys.argv[2])
raw = (out / 'trace.txt').read_text()
lines = raw.splitlines()
assert not any(s.startswith('BUDDY_ERROR') for s in lines)
def fields(line):
    return dict(re.findall(r'(\w+)=(\([^)]*\)|[^,]+)', line))
def xyz(row):
    return tuple(float(v) for v in row['buddy'].strip('()').split(','))
native = [fields(s) for s in lines if s.startswith('BUDDY_NATIVE,')]
obs = [fields(s) for s in lines if s.startswith('BUDDY_OBSERVE,')]
assert len(native) > 2000
assert len({s['timer'] for s in native}) == len(native)
assert all(xyz(s) == (-5990, 0, -3871) for s in native)
assert len(obs) >= 35 and [int(s['step']) for s in obs] == list(range(len(obs)))
assert len({s['timer'] for s in obs}) == len(obs)
assert all(s['buddyBehavior'] == native[0]['buddyBehavior'] for s in obs)
assert all(int(s['input']) & 0x82 == 0 for s in native + obs)
prefix_result = [fields(s) for s in (out / 'raw.log').read_text().splitlines() if s.startswith('RESULT,')]
assert len(prefix_result) == 1
assert all(int(prefix_result[0][k]) == 0 for k in ['aPressedFrames', 'aDownFrames', 'controllerAFrames'])
inputs = [fields(s) for s in lines if s.startswith('BUDDY_INPUT,')]
assert len(inputs) == len(obs)
assert all(int(s['A']) == 0 and int(s['x']) == 0 and int(s['y']) == 0 for s in inputs)
writes = [fields(s) for s in lines if s.startswith('BUDDY_WRITE,')]
# Fixed real JP addresses, independently taken from the existing prefix harness.
prefix = (out / 'prefix-source.c').read_text()
def macro(name):
    m = re.search(r'\b' + name + r'\s*=\s*(0x[0-9A-Fa-f]+|[0-9]+)', prefix)
    assert m, name
    return int(m[1], 0)
ms = macro('A_MARIO_STATES')
pool = macro('A_OBJECT_POOL')
size = macro('OBJECT_SIZE')
buddy = pool + 15 * size
small = pool + 23 * size
# Mario object is the native slot67 in this exact prefix; verify C/D destinations.
mobj = pool + 67 * size
expected = {}
def add_vec(base, label):
    for offset in (0, 4, 8): expected[(32, base + offset)] = label
add_vec(ms + macro('M_POS_X'), 'movement')
add_vec(mobj + macro('O_POS_X'), 'collision')
add_vec(mobj + macro('GFX_POS_X'), 'storedGraphics')
expected[(32, ms + macro('M_ACTION'))] = 'idle'
expected[(16, ms + 0x18)] = 'actionState'
expected[(16, ms + 0x1a)] = 'actionTimer'
expected[(32, ms + macro('M_FORWARD_VEL'))] = 'forward'
add_vec(ms + macro('M_VEL_X'), 'velocity')
for offset, label in [(0x2c, 'facePitch'), (0x2e, 'faceYaw'), (0x30, 'faceRoll')]:
    expected[(16, ms + offset)] = label
setup = [s for s in writes if s['label'] != 'conditionalUsedObjRetarget']
assert len(setup) == len(expected)
assert {(int(s['width']), int(s['address'], 16)): s['label'] for s in setup} == expected
assert all(s['step'] == '0' for s in setup)
bits = lambda v: struct.unpack('>I', struct.pack('>f', v))[0]
expected_values = {key: 0 for key in expected}
for base in [ms + macro('M_POS_X'), mobj + macro('O_POS_X'), mobj + macro('GFX_POS_X')]:
    for offset, value in [(0,5900), (4,51), (8,3380)]:
        expected_values[(32, base + offset)] = bits(value)
expected_values[(32, ms + macro('M_ACTION'))] = 0x0c400201
assert all(int(s['after'], 16) == expected_values[(int(s['width']), int(s['address'], 16))] for s in setup)
retarget = [s for s in writes if s['label'] == 'conditionalUsedObjRetarget']
assert len(retarget) == (0 if mode == 3 else 1)
if retarget:
    s = retarget[0]
    assert int(s['width']) == 32 and int(s['address'], 16) == ms + macro('M_USED_OBJ')
    assert int(s['before'], 16) == small and int(s['after'], 16) == buddy
    at = obs[int(s['step'])]
    assert at['action'] == '00000383' and int(at['used'], 16) == small
held = [s for s in obs if int(s['held'], 16) == (small if mode == 3 else buddy)]
assert held, 'native pickup never completed'
released = [s for s in obs if int(s['step']) > int(held[-1]['step']) and int(s['held'], 16) == 0]
assert released, 'native release never completed'
if mode == 3:
    assert all(xyz(s) == (-5990, 0, -3871) for s in obs)
else:
    assert all(xyz(s) == (-5990, 0, -3871) for s in held)
    assert all(xyz(s)[0] > 5800 and xyz(s)[2] > 3300 for s in released)
    assert int(released[0]['buddyHeld']) == (2 if mode == 2 else 3)
assert all(not buddy <= int(s['address'], 16) < buddy + size for s in writes)
keep = [s for s in lines if not s.startswith('BUDDY_NATIVE,')]
keep[:0] = [next(s for s in lines if s.startswith('BUDDY_NATIVE,'))]
keep.append([s for s in lines if s.startswith('BUDDY_NATIVE,')][-1])
(out / 'selected-trace.txt').write_bytes(('\n'.join(keep) + '\n').encode('utf-8'))
sha = lambda p: hashlib.sha256(p.read_bytes()).hexdigest()
result = dict(mode=mode, passed=True, evidence='Original JP conditional pickup-reference diagnostic; not controller-reachable cloning',
              native_boundaries=len(native), post_setup_boundaries=len(obs),
              no_buddy_state_writes=True, no_A=True, first_held=held[0],
              first_released=released[0], last=obs[-1],
              source_sha256={p.name: sha(p) for p in [out/'probe-source.c',out/'prefix-source.c',out/'run-source.sh',pathlib.Path(__file__)]},
              full_trace_sha256=sha(out/'trace.txt'), selected_trace_sha256=sha(out/'selected-trace.txt'))
(out / 'result.json').write_bytes((json.dumps(result, indent=2) + '\n').encode('utf-8'))
print(json.dumps({k: result[k] for k in ['mode','passed','native_boundaries','post_setup_boundaries','first_released']}))
