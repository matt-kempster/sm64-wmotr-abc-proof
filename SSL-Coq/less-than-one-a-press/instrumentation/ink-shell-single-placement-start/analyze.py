"""Classify exact finite release histories; no new game-state simulation."""
import argparse,collections,gzip,hashlib,json
from pathlib import Path
HERE=Path(__file__).resolve().parent;ROOT=HERE.parents[1]
def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest()
def main():
 p=argparse.ArgumentParser();p.add_argument('--verify',action='store_true');a=p.parse_args()
 data=json.loads(gzip.decompress((HERE/'results.json.gz').read_bytes()));ts=data['trials'];releases=[]
 for t in ts:
  f=t['firstRelease'];assert f is not None
  i=f['update']-t['recipe']['phase'];s=t['samples'][i];before=t['samples'][i-1]if i else t['beforeInitial'];box=s['actors']['49']
  assert box['behavior']=='bhvJumpingBox'and box['oHeldState']==0
  assert box['oForwardVel']in [0,40]
  # Native jumping_box HELD_THROWN calls get_thrown_or_placed(40,20,1);
  # HELD_DROPPED calls get_dropped, which sets forward/Y velocity to0.
  thrown=box['oForwardVel']==40
  assert box['oVelY']==16 if thrown else box['oVelY']==0
  mounted=any(e.get('to')==0x20810446 for e in t['events'][i])
  if t['recipe']['release']=='B'and not thrown:assert mounted
  if thrown:assert before['HOLP']!=t['beforeInitial']['HOLP']
  releases.append(dict(recipe=t['recipe'],releaseUpdate=f['update'],nativeKind='throw'if thrown else'drop',
   shellMountOnRelease=mounted,initialHOLP=t['beforeInitial']['HOLP'],HOLPBeforeRelease=before['HOLP'],releasedBox=box,
   marioAfterRelease=s['M'],firstUpdateHOLP=t['samples'][0]['HOLP'],firstUpdateHeld=t['samples'][0]['held']))
 counts=dict(cases=len(ts),boundaries=sum(len(t['samples'])for t in ts),freshRoots=data['independentFreshRoots'],
  useful=sum(t['useful']for t in ts),capture=sum(t['capture']for t in ts),arrivals=sum(t['arrival']is not None for t in ts),
  requestedB=sum(t['recipe']['release']=='B'for t in ts),requestedZ=sum(t['recipe']['release']=='Z'for t in ts),
  actualThrows=sum(x['nativeKind']=='throw'for x in releases),BInterruptedDrops=sum(x['recipe']['release']=='B'and x['nativeKind']=='drop'for x in releases),
  BStillHeldAfterFirstUpdate=sum(x['recipe']['release']=='B'and x['firstUpdateHeld']==49 for x in releases),
  BFirstUpdateHOLPOverwrites=sum(x['recipe']['release']=='B'and x['firstUpdateHeld']==49 and x['firstUpdateHOLP']!=x['initialHOLP']for x in releases),
  ridingHandlerHistories=sum(bool(t['mountEvents'])for t in ts),
  slideHistories=sum(any(s['actionName']in ['ACT_BUTT_SLIDE','ACT_CROUCH_SLIDE']for s in t['samples'])for t in ts))
 assert counts['actualThrows']==73 and counts['BInterruptedDrops']==44
 assert counts['BStillHeldAfterFirstUpdate']==counts['BFirstUpdateHOLPOverwrites']==101
 assert not counts['useful']and not counts['capture']
 z=collections.Counter(t['samples'][0]['actionName']for t in ts if t['recipe']['release']=='Z')
 examples=[t for t in ts if t['arrival']or t['recipe']in[dict(phase=120,y=1930,vy=-16,release='B'),dict(phase=124,y=1890,vy=-16,release='B'),dict(phase=124,y=1890,vy=-16,release='Z')]]
 sources=['src/game/behaviors/jumping_box.inc.c','src/game/object_helpers.c','src/game/mario_actions_airborne.c','src/game/interaction.c']
 out=dict(schema=1,scope=__doc__,counts=counts,ZFirstActions=dict(z),releases=releases,
  observedMinimumInitialY=min(t['recipe']['y']for t in ts),observedMaximumInitialY=max(t['recipe']['y']for t in ts),
  examples=examples,sourceSha256={s:sha(ROOT.parents[2]/'reference-sm64-decomp'/s)for s in sources},
  files={n:sha(HERE/n)for n in ['check.py','results.json.gz','README.md','analyze.py','.gitattributes']})
 dst=HERE/'analysis.json.gz'
 if a.verify:assert json.loads(gzip.decompress(dst.read_bytes()))==out
 else:assert not dst.exists();dst.write_bytes(gzip.compress((json.dumps(out,separators=(',',':'))+'\n').encode(),mtime=0))
 print(json.dumps(counts));print('PASS exact release-kind/HOLP analysis, source and artifact hashes')
if __name__=='__main__':main()
