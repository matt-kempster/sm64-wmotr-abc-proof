"""Check exact observed replies and resume actual generated call preimages.

Thirty checkpoint observations are a concrete integration test, not thirty
exhaustively searched updates. search_updates.py --emulator-capture separately
attempts the broad inverse problem and retains unmatched calls.
"""
import argparse
import hashlib
import json
from pathlib import Path
import sys
import time

HERE=Path(__file__).resolve().parent
sys.path.insert(0,str(HERE.parent/'rank1-backward-search'))
from clight import ROOT, walk, items
from engine import MEM, Scope, Path as Branch, read, word, z
from emulator_oracle import EmulatorOracle, ReplayAnchor
from hybrid_engine import HybridHorizonEngine

ROM_SHA256='9cf7a80db321b07a8d461fe536c02c87b7412433953891cdec9191bfad2db317'


def main():
    p=argparse.ArgumentParser(description=__doc__)
    p.add_argument('--capture',type=Path,required=True)
    p.add_argument('--rom',type=Path,required=True)
    p.add_argument('--symbols',type=Path,required=True)
    p.add_argument('--output',type=Path,required=True)
    a=p.parse_args();began=time.perf_counter()
    if hashlib.sha256(a.rom.read_bytes()).hexdigest()!=ROM_SHA256:
        raise ValueError('Wrong retail ROM')
    oracle=EmulatorOracle(a.capture)
    inputs=[json.loads(line.split(',',1)[1]) for line in a.capture.read_text(errors='replace').splitlines()
            if line.startswith('WAFEL_PILOT,')]
    if not inputs or any(row['buttons']&0x8000 for row in inputs):raise ValueError('A pressed or missing inputs')
    if [r['poll'] for r in inputs]!=list(range(1,len(inputs)+1)):raise ValueError('Controller history has gaps')
    if oracle.totals['checkpoints']!=30:raise ValueError('Expected thirty actually completed checkpoints')
    e=HybridHorizonEngine('jp',updates=30,runtime_audio=True,
        supplemental=ROOT/'build/rank1-backward-search/supplemental-generated',oracle=oracle)
    calls={}
    for caller in ('thread5_game_loop','read_controller_inputs'):
        fn=e.function('game_init',caller)
        for _,node in walk(fn.body):
            if node.tag=='Scall' and node.args[1].tag=='Evar':
                name=node.args[1].args[0].tag.removeprefix('_')
                if name in ('osContStartReadData','osContGetReadData'):calls[name]=(fn,node)
    padty=items(calls['osContGetReadData'][1].args[1].args[-1].args[0])[0].args[0]
    if e.unit('game_init').size(padty)[0]!=6:raise ValueError('OSContPad layout changed')
    checked=[]
    for ident,(before,after) in oracle.cases.items():
        fn,node=calls[before['name']];scope=Scope(e,fn);path='emulator-case-'+str(ident)
        e.anchors={(fn.name,path,before['name']):ReplayAnchor(oracle.digest,ident)}
        e.stop_post=z.BoolVal(False)
        regions=list(oracle.mapped_regions(e,after))
        post=z.And(*[read(MEM,word(address+i),1)==z.BitVecVal(value,8)
                     for _,address,data in regions for i,value in enumerate(data)])
        pre=e.external_call(node,[Branch(post)],scope,path)[0].condition
        solver=z.Solver();solver.set(timeout=10000);solver.add(e.remaining==30,pre)
        status=solver.check()
        if status!=z.sat:raise ValueError('Observed reply did not resume: '+str(status))
        # A contradictory observed byte must be rejected; the same reply may
        # not silently turn into a free post-state.
        _,address,data=regions[0]
        bad=e.external_call(node,[Branch(read(MEM,word(address),1)==z.BitVecVal(data[0]^1,8))],scope,path)[0].condition
        solver=z.Solver();solver.set(timeout=10000);solver.add(e.remaining==30,bad)
        if solver.check()!=z.unsat:raise ValueError('Contradictory reply was not rejected')
        checked.append(dict(event=ident,callee=before['name'],poll=before['poll'],reply='matched',
                            generatedCaller=fn.name,sourceSHA256=fn.digest))
    symbols={}
    for line in a.symbols.read_text().splitlines():
        fields=line.split()
        if len(fields)==3 and fields[1] in ('T','t'):
            symbols.setdefault(int(fields[0],16),[]).append(fields[2])
    native={};unmapped=[]
    for event in oracle.events:
        if event['kind']!='native':continue
        names=[name for name in symbols.get(event['callee'],[]) if name in e.image.symbols
               and e.image.symbols[name].internal]
        if len(names)!=1:
            unmapped.append(event);continue
        name=names[0];entry=e.image.symbols[name];fn=e.function(entry.unit,entry.body)
        row=native.setdefault(name,dict(calls=0,receivers=[],sourceSHA256=fn.digest))
        row['calls']+=1
        if event['slot'] not in row['receivers']:row['receivers'].append(event['slot'])
    checkpoints=[event for event in oracle.events if event['kind']=='checkpoint']
    report=dict(status='Exact replay call handoff checked; exhaustive inverse coverage remains open.',
        backend='retail JP Mupen64Plus interpreter; read-only observations; controller-only continuation',
        version='jp',romSHA256=ROM_SHA256,captureSHA256=oracle.digest,
        symbolFileSHA256=hashlib.sha256(a.symbols.read_bytes()).hexdigest(),
        controllerPolls=len(inputs),controllerSHA256=hashlib.sha256(json.dumps(
            [[r['poll'],r['buttons'],*r['stick']] for r in inputs],separators=(',',':')).encode()).hexdigest(),
        requestedUpdates=30,observedCompletedCheckpoints=30,completedExhaustiveUpdates=0,
        matchedCallCases=len(checked),contradictoryRepliesRejected=len(checked),
        callbackInvocations=oracle.totals['nativeCalls'],callbackBodies=native,unmappedCallbacks=unmapped,
        callEffects=oracle.stats(),checkpoints=checkpoints,checkedCases=checked,
        elapsedSeconds=time.perf_counter()-began,
        limits=['Replay-event anchors identify exact experimental cases, not arbitrary symbolic memories.',
                'Only mapped scalar bytes are constrained. OS queues, devices and all other memory remain open.',
                'Observed native names/receivers guide case selection; other live pointers remain possible.',
                'No supplied gap, no new controller trajectory, no Coq theorem, no global exclusion.'])
    a.output.parent.mkdir(parents=True,exist_ok=True)
    a.output.write_text(json.dumps(report,indent=2)+'\n')
    print(json.dumps({key:report[key] for key in ('matchedCallCases','observedCompletedCheckpoints',
          'completedExhaustiveUpdates','callbackInvocations','elapsedSeconds')}) )


if __name__=='__main__':main()
