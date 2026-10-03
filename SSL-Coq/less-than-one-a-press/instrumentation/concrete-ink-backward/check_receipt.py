"""Check the exact inside-update checkpoint and first Area-2 apply."""
import argparse
import json
from pathlib import Path
import re
import struct


def word(value):
    return struct.unpack('>I', struct.pack('>f', value))[0]


def check(text, actual_y, display_y=1938.8648681640625):
    if 'BACKWARD_INK_ERROR' in text:
        raise ValueError('Observer arming failed')
    records = []
    for line in text.splitlines():
        if line.startswith('BACKWARD_INK,'):
            records.append(dict(item.split('=', 1) for item in line.split(',')[1:]))
    accepted = [r for r in records if r['stage'] == 'accepted-return']
    if len(accepted) != 1:
        raise ValueError('Need exactly one successful accepted return')
    a = accepted[0]
    entries = [r for r in records if r['stage'] == 'disappeared-entry' and r['timer'] == a['timer']]
    if len(entries) != 1:
        raise ValueError('Missing same-update action entry')
    high = [word(-2200.), 1156733869, word(-1024.)]
    low = [word(-2200.), word(768.), word(-1024.)]
    display = [word(-2200.), word(display_y), word(-1024.)]
    movement = high if actual_y == 768 else [word(-2200.), word(1861.), word(-1024.)]
    for r in (a, entries[0]):
        if (r['area'] != '1' or int(r['action'], 16) != 0x1300
                or int(r['arg'], 16) != 0x40002 or r['used'] != r['upper']
                or int(r['upper'], 16) == 0 or r['owner'] != r['top']
                or int(r['top'], 16) == 0 or int(r['floor'], 16) == 0):
            raise ValueError('Wrong warp, action, argument or top owner')
        if [int(v, 16) for v in r['positions'].split(':')] != movement + low + display:
            raise ValueError('Exact accepted position relationship differs')
    setup = [r for r in records if r['stage'] == 'setup']
    if len(setup) != 1 or setup[0]['timer'] != a['timer']:
        raise ValueError('Wrong supplied setup boundary')
    apply_entry = next((line for line in text.splitlines() if line.startswith('FIRST_APPLY_ENTRY,')), '')
    apply_return = next((line for line in text.splitlines() if line.startswith('FIRST_APPLY_RETURN,')), '')
    if (',area=2,' not in apply_entry or ',area=2,' not in apply_return
            or ',platform=' + a['top'] + ',' not in apply_entry
            or ',platform=' + a['top'] + ',' not in apply_return
            or 'marioBits=(00000000,45abe000,43800000)' not in apply_entry
            or 'marioBits=(43b6cbe0,45abe000,c48919af)' not in apply_return):
        raise ValueError('First retained-top Area-2 apply missing or different')
    return dict(status='checked-conditional-installation', actualSetupY=actual_y,
                acceptedTimer=int(a['timer']), acceptedMovementWords=movement,
                collisionWords=low, displayWords=display, top=a['top'], used=a['used'],
                checkpoint='successful interact_warp return before act_disappeared',
                firstApplyMovementWords=[0x43b6cbe0, 0x45abe000, 0xc48919af],
                scope='Supplied fixture, not controller reachability or inverse coverage')


def main():
    p = argparse.ArgumentParser(description=__doc__)
    p.add_argument('receipt', type=Path)
    p.add_argument('--actual-y', type=int, choices=(768, 1861), required=True)
    p.add_argument('--display-y', type=float, default=1938.8648681640625)
    p.add_argument('--output', type=Path, required=True)
    args = p.parse_args()
    report = check(args.receipt.read_text(encoding='utf-8'), args.actual_y, args.display_y)
    args.output.write_text(json.dumps(report, indent=2) + '\n', encoding='utf-8')
    print(json.dumps(report))


if __name__ == '__main__':
    main()
