"""A replay-addressed, partial-footprint retail oracle. Never a global frame.

The anchor is an external experiment identity, NOT a claim that a symbolic
memory is reachable. Only a caller already bound to that exact replay event
may consume a reply. Unknown anchors have no answer. Projection agreement
alone is intentionally insufficient. This is experimental evidence, not a
Clight/retail equivalence theorem.
"""
from dataclasses import dataclass
import hashlib
import json
from pathlib import Path

from engine import MEM, STATE, OBJECT, word, read, z


@dataclass(frozen=True)
class ReplayAnchor:
    capture_sha256: str
    event_id: int
    version: str = 'jp'


class UnmatchedCall(Exception):
    pass


class EmulatorOracle:
    def __init__(self, log):
        self.log = Path(log)
        data = self.log.read_bytes()
        self.digest = hashlib.sha256(data).hexdigest()
        self.events = [json.loads(line.split(',', 1)[1]) for line in
                       data.decode('utf-8', errors='replace').splitlines()
                       if line.startswith('R1_HANDOFF,')]
        totals = [json.loads(line.split(',', 1)[1]) for line in
                  data.decode('utf-8', errors='replace').splitlines()
                  if line.startswith('R1_HANDOFF_RESULT,')]
        if len(totals) != 1 or totals[0]['failures'] or totals[0]['pending']:
            raise ValueError('Incomplete or failed emulator capture')
        self.totals = totals[0]
        self.cases = {}
        pending = {}
        for event in self.events:
            if event['kind'] == 'entry':
                if event['id'] in pending or event['id'] in self.cases:
                    raise ValueError('Duplicate entry')
                pending[event['id']] = event
            elif event['kind'] == 'return':
                before = pending.pop(event['id'], None)
                if before is None or before['name'] != event['name']:
                    raise ValueError('Return without matching entry')
                if before['ra'] != event['pc'] or before['sp'] != event['sp']:
                    raise ValueError('Call/return ABI boundary mismatch')
                if before['area'] != 1 or event['area'] != 1:
                    raise ValueError('Not the selected SSL Area-1 window')
                if [(r['name'],r['address'],len(r['bytes'])) for r in before['regions']] != [
                    (r['name'],r['address'],len(r['bytes'])) for r in event['regions']]:
                    raise ValueError('Observation region identity changed')
                self.cases[event['id']] = (before,event)
        if pending or len(self.cases) != self.totals['returns']:
            raise ValueError('Unpaired calls')

    def answer(self, name, anchor):
        if not isinstance(anchor, ReplayAnchor) or anchor.version != 'jp' or anchor.capture_sha256 != self.digest:
            raise UnmatchedCall('No exact JP replay-event anchor; scalar agreement cannot establish a match')
        case = self.cases.get(anchor.event_id)
        if case is None or case[0]['name'] != name:
            raise UnmatchedCall('Wrong call occurrence or function')
        return case

    @staticmethod
    def mapped_regions(engine, event):
        """Only scalar byte regions with checked corresponding 32-bit layouts.

        Queue/thread pointers and OS internals have no established relocation
        here and are NOT copied into canonical symbolic addresses. Their reads
        remain in the receipt. Arbitrary outside memory remains unconstrained.
        """
        unit = engine.unit('mario')
        # OSPad is the anonymous composite actually used by gControllerPads.
        # Its size/layout is checked by the driver from the generated call type.
        mapping = {
            'gControllerPads': engine.global_address('_gControllerPads'),
            'gMarioStates.pos': STATE+60,
            'marioObject.pos': OBJECT+160,
            'marioObject.gfx.pos': OBJECT+32,
        }
        if unit.layout('_MarioState')[2]['_pos'] != 60:
            raise ValueError('MarioState position layout changed')
        if unit.layout('_GraphNodeObject')[2]['_pos'] != 32:
            raise ValueError('Graphical position layout changed')
        for region in event['regions']:
            if region['name'] in mapping:
                yield region['name'], mapping[region['name']], bytes.fromhex(region['bytes'])

    def facts(self, engine, name, anchor, before_memory, after_memory, result=None):
        before, after = self.answer(name, anchor)
        expected = {'osContStartReadData': 0x80339c08, 'osContGetReadData': 0x80339c88}
        if name not in expected or before['args'][0] != expected[name]:
            raise UnmatchedCall('Observed argument is outside the implemented symbol mapping')
        entry, effect = [], []
        for _,address,data in self.mapped_regions(engine,before):
            entry += [read(before_memory,word(address+i),1) == z.BitVecVal(value,8)
                      for i,value in enumerate(data)]
        for _,address,data in self.mapped_regions(engine,after):
            effect += [read(after_memory,word(address+i),1) == z.BitVecVal(value,8)
                       for i,value in enumerate(data)]
        if result is not None and name == 'osContStartReadData':
            effect.append(result == word(after['v0']))
        return z.And(*entry), z.And(*effect)

    def stats(self):
        changed = {}
        for before,after in self.cases.values():
            name=before['name']
            row=changed.setdefault(name,dict(calls=0,changedRegions={},returns={}))
            row['calls']+=1
            if name=='osContStartReadData':
                key=str(after['v0']);row['returns'][key]=row['returns'].get(key,0)+1
            for a,b in zip(before['regions'],after['regions']):
                if a['bytes'] != b['bytes']:
                    row['changedRegions'][a['name']]=row['changedRegions'].get(a['name'],0)+1
        return changed
