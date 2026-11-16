"""Native HOLP throw directly to the shell target, with no later shell XYZ cut."""
import argparse,json,subprocess,sys
from pathlib import Path
HERE=Path(__file__).resolve().parent
p=argparse.ArgumentParser();p.add_argument('case',type=Path);p.add_argument('output',type=Path);a=p.parse_args()
c=json.loads(a.case.read_bytes());assert c['seedPhase']==126 and [x['phase'] for x in c['cuts']]==[128]
assert not any(e['path'].startswith('gObjectPool[71]')for e in c['initialEdits'])
assert not any(e['path'].startswith('gObjectPool[71]')for cut in c['cuts']for e in cut['edits'])
subprocess.run([sys.executable,str(HERE.parent/'jp-ink-mario-pusher-release/generate.py'),str(a.case),str(a.output)],check=True)
s=a.output.read_text(encoding='utf-8')
old='sv(R32(A_MARIO_STATES+0x98)+0x18,-1950,19890,-971,"highHOLP");'
assert s.count(old)==1
values=','.join(repr(float(x))+'f'for x in c['shellPreparationHOLP'])
s=s.replace(old,'sv(R32(A_MARIO_STATES+0x98)+0x18,'+values+',"highHOLP");')
obs=r'''
static void sf_shell(void){uint32_t b=SC_SHELL;
 fprintf(stderr,"SF_SHELL,step=%d,bridge=%d,active=%u,flags=%u,type=%u,intangible=%d,status=%u,action=%u,timer=%u,held=%u,command=%08x,behavior=%08x,radius=%.9g,height=%.9g,pos=(%.9g,%.9g,%.9g)\n",sc_step,sc_bridge,R16(b+0x74),R32(b+0x8c),R32(b+0x130),(int32_t)R32(b+0x9c),R32(b+0x134),R32(b+0x14c),R32(b+0x154),R32(b+0x124),R32(b+0x1cc),R32(b+0x20c),rfloat(b+0x1f8),rfloat(b+0x1fc),rfloat(b+0xa0),rfloat(b+0xa4),rfloat(b+0xa8));
}
'''
needle='static void sc_update(unsigned int pc){';assert s.count(needle)==1;s=s.replace(needle,obs+'\n'+needle)
needle='sc_log("SC_STATE");eb_bob();pp_box();';assert s.count(needle)==1;s=s.replace(needle,needle+'sf_shell();')
a.output.write_bytes(s.encode())
print('Remote shell HOLP',c['shellPreparationHOLP'],'target',c['shellTarget'],'no post-throw shell cuts')
