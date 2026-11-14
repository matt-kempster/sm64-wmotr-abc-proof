"""Export the fresh-verified timing pair, including native throw and remount."""
import gzip,json,sys
from pathlib import Path
HERE=Path(__file__).resolve().parent;ROOT=HERE.parents[1]
sys.path.insert(0,str(ROOT/'instrumentation/ink-shell-delivery'))
from pending_slot import Guard,create_game,Observer,snap,advance,load_capture
from replay import bits

def extra(g,o):
 s=snap(g,o);a=s['slot23']
 return dict(used=s['used'],held=s['held'],ridden=s['ridden'],shellBoxAction=s['shellBoxAction'],slot23=dict(active=a['active'],flags=a['flags'],parent=a['parent'],posBits=list(map(bits,a['pos'])),type=a['type'],subtype=a['subtype'],status=a['status'],intangible=a['intangible'],heldState=a['heldState'],action=a['action'],timer=a['timer'],radiusBits=bits(a['radius']),heightBits=bits(a['height'])),command=a['command'])

def main():
 r=json.loads(gzip.decompress((ROOT/'instrumentation/ink-shell-delivery/pending-results.json.gz').read_bytes()));assert r['independentlyVerified']
 prep=r['preparation'];prefix=load_capture(ROOT/prep['prefix'])[:prep['prefixFrames']]+prep['controls']
 for step,name in [(5,'timely'),(6,'late')]:
  t=next(t for t in r['trials']if t['pickTimer']==897 and t['spawnStep']==step)
  f=next(f for f in r['followups']if f['pickTimer']==897 and f['spawnStep']==step and f['kind']=='throw')
  inputs=prefix+t['controls']+f['controls']+[dict(buttons=0,stick=[0,0])]*2
  grantPoll=len(prefix)+7+step
  g=Guard(create_game());o=Observer(g);rows=[]
  for i,p in enumerate(inputs):
   if i>=348:rows.append(dict(poll=i+1,observation=o.snapshot(),extra=extra(g,o)))
   if i+1==grantPoll:assert g.read('gObjectPool[32].oAction')==2;g.write('gObjectPool[32].oAction',4)
   advance(g,p)
   if len(prefix)<=i<len(prefix)+len(t['controls']):assert snap(g,o)==t['samples'][i-len(prefix)]
   if len(prefix)+len(t['controls'])<=i<len(prefix)+len(t['controls'])+len(f['controls']):assert snap(g,o)==f['samples'][i-len(prefix)-len(t['controls'])]
  out=HERE/name;out.mkdir(exist_ok=True)
  (out/'controller.inputs').write_bytes((''.join('%d %d %d %d\n'%(i+1,p['buttons'],*p['stick'])for i,p in enumerate(inputs))).encode())
  (out/'inputs.jsonl').write_bytes((''.join(json.dumps(p,separators=(',',':'))+'\n'for p in inputs)).encode())
  (out/'expected.json.gz').write_bytes(gzip.compress((json.dumps(rows,separators=(',',':'))+'\n').encode(),mtime=0))
  (out/'setup.json').write_bytes((json.dumps(dict(grantPoll=grantPoll,grant='gObjectPool[32].oAction:2->4',inputCount=len(inputs),mounted=f['mounted']),indent=2)+'\n').encode())
  print(name,len(inputs),grantPoll,f['mounted'])
if __name__=='__main__':main()
