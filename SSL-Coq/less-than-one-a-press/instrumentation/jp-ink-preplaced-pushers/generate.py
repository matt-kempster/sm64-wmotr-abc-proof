"""Reuse the authenticated JP probe with all pusher cuts before shell contact.

Adds read-only Crazy Box observations. No later item/Mario edits are allowed.
"""
from pathlib import Path
import argparse, json, subprocess, sys
HERE=Path(__file__).resolve().parent
p=argparse.ArgumentParser();p.add_argument('case',type=Path);p.add_argument('output',type=Path);a=p.parse_args()
case=json.loads(a.case.read_bytes());assert case['seedPhase']==128 and not case['cuts']
assert case['controls'][0]['buttons']==0x2000
assert all(not x['buttons']&0x8000 for x in case['controls'])
subprocess.run([sys.executable,str(HERE.parent/'jp-ink-enlarged-bob-handoff/generate.py'),str(a.case),str(a.output)],check=True)
s=a.output.read_text(encoding='utf-8')
observation=r'''
static void pp_box(void){uint32_t b=A_OBJECT_POOL+49*OBJECT_SIZE;
 fprintf(stderr,"PP_BOX,bridge=%d,active=%u,type=%u,subtype=%u,intangible=%d,status=%u,action=%u,timer=%u,held=%u,radius=%.9g,height=%.9g,scale=(%.9g,%.9g,%.9g),pos=(%.9g,%.9g,%.9g),vel=(%.9g,%.9g,%.9g),forward=%.9g\n",sc_bridge,R16(b+0x74),R32(b+0x130),R32(b+0x190),(int32_t)R32(b+0x9c),R32(b+0x134),R32(b+0x14c),R32(b+0x154),R32(b+0x124),rfloat(b+0x1f8),rfloat(b+0x1fc),rfloat(b+0x2c),rfloat(b+0x30),rfloat(b+0x34),rfloat(b+0xa0),rfloat(b+0xa4),rfloat(b+0xa8),rfloat(b+0xac),rfloat(b+0xb0),rfloat(b+0xb4),rfloat(b+0xb8));
}
'''
needle='static void sc_update(unsigned int pc){';assert s.count(needle)==1;s=s.replace(needle,observation+'\n'+needle)
needle='sc_log("SC_STATE");eb_bob();';assert s.count(needle)==1;s=s.replace(needle,needle+'pp_box();')
assert 'SC_AFTER_PUSH_CUT' not in s
a.output.write_bytes(s.encode('utf-8'))
print('Added Crazy Box observations; zero post-mount item cuts')
