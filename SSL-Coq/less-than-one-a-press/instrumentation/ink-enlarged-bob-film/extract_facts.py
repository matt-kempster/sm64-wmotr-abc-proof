"""Small read-only film facts derived from the checked original-JP archives."""
import argparse,gzip,hashlib,importlib.util,json,struct
from pathlib import Path
HERE=Path(__file__).resolve().parent;ROOT=HERE.parents[1]
PACKET=ROOT/'instrumentation/jp-ink-enlarged-bob-handoff'
spec=importlib.util.spec_from_file_location('film_native_checker',PACKET/'check.py')
check=importlib.util.module_from_spec(spec);spec.loader.exec_module(check)
def load(p):return json.loads(gzip.decompress(p.read_bytes()))
def f32(v):return struct.unpack('<f',struct.pack('<f',float(v)))[0]
def xyz(v):return [f32(x)for x in check.xyz(v)]
def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest()
def case(name):
 d=PACKET/'records'/name;r=load(d/'receipt.json.gz');c=load(d/'case.json.gz')
 raw=gzip.decompress((d/'raw.log.gz').read_bytes()).decode(errors='replace')
 natives={int(s['bridge']):s for line in raw.splitlines()if line.startswith('SC_STATE,')for s in[check.fields(line)]if int(s['bridge'])>0}
 bobs={int(s['bridge']):s for s in r['bobRows']if int(s['bridge'])>0}
 selected=[]
 for bridge in [1,2,3,4,24,27]:
  s=c['expected'][bridge-1];n=natives[bridge];b=bobs[bridge]
  for k in ['M','C','G']:assert xyz(n[k])==s[k]
  selected.append(dict(bridge=bridge,completedUpdateLabel=127+bridge if bridge<=4 else None,nativeGlobalTimer=int(n['timer']),wafelGlobalTimer=s['timer'],area=s['area'],topTimerAfterUpdate=s['topTimer'],action=s['actionName'],M=s['M'],C=s['C'],G=s['G'],floorCache=s['floorY'],ceilingY=s['ceilingY'],floorOwner=s['floorOwner'],platform=s['platform'],used=s['used'],ridden=s['ridden'],collisions=s['collisions'],bob=dict(slot=39,XYZ=xyz(b['pos']),active=int(b['active']),radius=f32(b['radius']),height=f32(b['height']),scale=xyz(b['scale']),fuse=int(b['fuse']),action=int(b['action']),actionTimer=int(b['timer']),heldState=int(b['held'])),shellXYZ=s['shell']['position']))
 roles={key:dict(queryXYZ=xyz(q['query']),result=f32(q['result']),cacheAtFunctionReturn=f32(q['cache']),surfaceOwner=check.slot(q['owner']))for key,q in r['producerQueryRoles'].items()}
 assert selected[2]['G'][1]-selected[2]['M'][1]==1071.447265625
 return dict(name=name,archiveSha256={p.name:sha(p)for p in[d/'receipt.json.gz',d/'case.json.gz',d/'raw.log.gz']},initialMario=dict(action='FREEFALL',M=[-1960,19900,-1230],C=[-1960,19900,-1230],G=[-1960,19900,-1230],velocity=[0,-16,0],speed=0,yaw=0),initialShellXYZ=[-1960,19890,-1230],inputs=dict(update128='Z',later='neutral',A='always released'),laterActorCuts=c['cuts'],selectedBoundaries=selected,producerQueryRoles=roles,producerGap=1071.447265625,capture=r['capture'],arrivalXYZ=xyz(r['arrival']['M']),noLaterMarioEdits=True,rawSetupScalarWrites=len(r['stateWrites']),missingNativeCameraBridges=r['missingNativeCameraBoundaries'],matchedPhysicalBoundaries=len(r['checked']),retainedClockDifferences=len(r['mismatches']))
def facts():
 pos=case('positive');neg=case('no-final-box')
 assert pos['capture']and not neg['capture']
 assert pos['arrivalXYZ']==[365.5927734375,5500,-1096.8026123046875]and neg['arrivalXYZ']==[0,5500,256]
 return dict(schema=1,scope=__doc__,positionLegend={'M':'Movement position','C':'Mario object collision position','G':'Stored Graphics gfx.pos, not the drawn model or render matrix'},evidence='Original Japanese ROM conditional supplied-state replays; physical projections agree with separately reconstructed Wafel',positive=pos,ordinaryWarpControl=neg,donor=dict(cleanControllerInputsToHeld91=616,additionalNeutralInputsToFree91=12,freeDonorFuse=170,freeDonorRadius=91,freeDonorHeight=158.1999969482422,fixtureTransplantFields=32,fixtureTransplantScalarComponents=34,deliveryJoined=False),captionChecks=['No Buddy participates.','The shell creates the ground action natively from supplied FREEFALL; no slide action is written.','The enlarged Bob and Crazy Box shove on different updates, not twice through GRABBABLE in one pass.','The final producer stores G.Y=1839.447265625; 19900 is the initial airborne height, not its final stored G.','The producer initial lookup selects768 before the Crazy Box shove; later validation/quarter queries do not overwrite this stopped-step cache.','The no-final-box control retains a live Bob and a later Bob shove; it is not a no-further-push control.','Both runs have the same1071.447265625 gap and fresh768, but only the positive captures the top and displaces spawn.','Show missing camera bridges25/26 as a cut or disclosed gap, not invented images.','Rice screenshot requests concern the previous completed framebuffer; join requestTimer−1 separately from the native+2=Wafel telemetry convention.','Any schematic vertical motion is an instant assignment, not a literal visible falling path.','The high Mario/shell, conditional fake pickup/HOLP, native-profile copy, timed Bob placement and timed Crazy Box placement remain supplied.','No continuous no-new-A route or new Coq theorem follows from this film.'])
def main():
 ap=argparse.ArgumentParser();ap.add_argument('--verify',action='store_true');a=ap.parse_args();r=facts();p=HERE/'facts.json'
 if a.verify:assert json.loads(p.read_text())==r
 else:p.write_bytes((json.dumps(r,indent=2)+'\n').encode())
 print('PASS film facts from two original-JP archives')
if __name__=='__main__':main()
