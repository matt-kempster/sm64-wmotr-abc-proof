"""Check the diagnostic fork against two previously hooked JP initial queries."""
import gzip,json,sys
from pathlib import Path
sys.path.insert(0,str(Path(__file__).resolve().parent))
from search import ROOT,HERE,module,shadow,r
d=module('shadow_direct','instrumentation/ink-frozen-shell-buddy-replacement/test.py')
w,o,state,prep=d.roots();g=w.g;edits=[];g.load_state(state)
d.iso.mario(g,o,[-1920,19900,-1210],edits)
d.iso.write(g,o,'gMarioState.vel',[0,-16,20],edits);d.iso.write(g,o,'gMarioState.faceAngle',[0,0,0],edits)
d.iso.position(g,o,w.slot,[-1920,19890,-1210],edits);d.iso.advance(g,d.iso.Z)
d.place(g,49,d.BOX129,edits);d.place(g,15,d.EXACT,edits);d.iso.advance(g,d.iso.NEUTRAL)
before=d.snap(w,o);positive=shadow(w,o);assert d.snap(w,o)==before
assert positive['floorY']==768 and positive['floorOwner']==-1
assert positive['queryCandidate']==[-2140.031982421875,1830.177978515625,-1115.0291748046875]
old=json.loads(gzip.decompress((ROOT/'instrumentation/ink-bobomb-retimed-shoves/results.json.gz').read_bytes()))
recipe=old['results']['trials'][0]['recipe'];w,o,states,prep=r.roots();r.seed(w,o,states,recipe['seed'])
while w.read('gObjectPool[61].oTimer')<130:
 phase=w.read('gObjectPool[61].oTimer')
 for cut in recipe['cuts']:
  if cut['phase']==phase and cut['pos']:r.place(w,cut['slot'],cut['pos'])
 r.advance(w,o)
before=r.snapshot(w,o);negative=shadow(w,o);assert r.snapshot(w,o)==before
assert negative['floorY']==1933.4923095703125 and negative['floorOwner']==61
assert negative['queryCandidate']==[-2168.8564453125,1889.0369873046875,-1036.69287109375]
out=dict(scope='Isolated diagnostic action fork matches these two hooked native controls; not a global equivalence theorem',positive=positive,negative=negative,fullSnapshotRestored=True)
(HERE/'shadow-validation.json').write_bytes((json.dumps(out,indent=2)+'\n').encode())
print('PASS known native initial queries; original full snapshots restored')
