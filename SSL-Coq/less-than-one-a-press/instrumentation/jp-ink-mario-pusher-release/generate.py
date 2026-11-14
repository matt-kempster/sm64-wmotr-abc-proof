"""Original-JP probe for explicitly granted carrying states and native releases.

Reuses the authenticated prefix/query probe. Unlike the older XYZ-cut exporter,
this permits the enumerated held-pointer/HOLP/Mario grants before mounting.
Every such write is logged. It does not write an actor's release endpoint.
"""
import argparse, json, re, subprocess, sys
from pathlib import Path
HERE=Path(__file__).resolve().parent; ROOT=HERE.parents[1]
BASE=HERE.parent/'jp-ink-enlarged-bob-handoff/generate.py'
P=0x8033c118; M=0x80339e00

def main():
 p=argparse.ArgumentParser();p.add_argument('case',type=Path);p.add_argument('output',type=Path);a=p.parse_args()
 case=json.loads(a.case.read_bytes())
 if case['seedPhase']==128:
  assert not case['cuts']
  subprocess.run([sys.executable,str(HERE.parent/'jp-ink-preplaced-pushers/generate.py'),str(a.case),str(a.output)],check=True)
  return
 assert case['seedPhase']==126
 assert all(c['phase'] in [127,128] for c in case['cuts'])
 assert all(not x['buttons']&0x8000 for x in case['controls'])
 source=BASE.read_text()
 old="    for c in case['cuts']:\n        assert all(re.fullmatch(r'gObjectPool\\[\\d+\\]\\.oPos[XYZ]',e['path']) for e in c['edits'])\n"
 assert source.count(old)==1;source=source.replace(old,'')
 ns={'__file__':str(BASE),'__name__':'release_generator_base'}
 exec(compile(source,str(BASE),'exec'),ns)
 original=ns['write_lines']
 def writes(edits,table):
  lines=[]
  for e in edits:
   key=e['path'];v=e['after']
   if key=='gMarioState.marioBodyState.heldObjLastPosition':
    assert len(v)==3
    for i,x in enumerate(v):
     _,width,bits=ns['scalar'](0,x,isfloat=True)
     lines.append('  sw32(R32(0x80339e98u)+0x%xu,0x%08xu,%s);'%(0x18+4*i,bits,json.dumps(key)))
   elif key in ['gMarioState.heldObj','gMarioState.usedObj']:
    if v=='null':v=-1
    elif isinstance(v,str):
     match=re.fullmatch(r'gObjectPool\[(\d+)\]',v);assert match,v
     v=int(match[1])
    assert isinstance(v,int) and -1<=v<240
    addr=M+(0x7c if key.endswith('heldObj') else 0x80)
    value=0 if v<0 else P+v*0x260
    lines.append('  sw32(0x%08xu,0x%08xu,%s);'%(addr,value,json.dumps(key)))
   elif key=='gMarioState.actionArg':
    lines.append('  sw32(0x80339e1cu,0x%08xu,%s);'%(v,json.dumps(key)))
   else:lines.append(original([e],table))
  return '\n'.join(lines)
 ns['write_lines']=writes
 # Base reads the same two command arguments and retains its original provenance.
 ns['main']()
 s=a.output.read_text()
 box=(HERE.parent/'jp-ink-preplaced-pushers/generate.py').read_text()
 observation=box.split("observation=r'''",1)[1].split("'''",1)[0]
 needle='static void sc_update(unsigned int pc){';assert s.count(needle)==1
 s=s.replace(needle,observation+'\n'+needle)
 needle='sc_log("SC_STATE");eb_bob();';assert s.count(needle)==1
 s=s.replace(needle,needle+'pp_box();')
 s=s.replace('SC_AFTER_PUSH_CUT','SC_AFTER_RELEASE_SETUP')
 a.output.write_bytes(s.encode())
 print('Native release probe: all grants logged; no actor edits after their release')

if __name__=='__main__':main()
