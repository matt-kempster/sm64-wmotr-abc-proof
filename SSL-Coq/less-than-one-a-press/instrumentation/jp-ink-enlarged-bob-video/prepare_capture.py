"""Add read-only frame capture to the already verified original-JP recipes.

Only screenshot requests and observation horizon change. No camera or gameplay
write is added, removed or retimed. Original sources remain untouched.
"""
import hashlib,json
from pathlib import Path
HERE=Path(__file__).resolve().parent;SOURCE=HERE.parent/'jp-ink-enlarged-bob-handoff'
def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest()
hashes={}
for name in['positive','no-final-box']:
 p=SOURCE/(name+'.c');s=p.read_text();hashes[name]=dict(source=sha(p),case=sha(SOURCE/(name+'.json')))
 s='/* Original-JP enlarged Bob video capture: '+name+'.\n * Screenshot requests only; gameplay, actor cuts and camera remain unchanged. */\n'+s[s.index('#define SEARCH_MODE'):]
 s=s.replace('#undef GetKeys','#undef GetKeys\n#include <mupen64plus/m64p_frontend.h>',1)
 s=s.replace('static int sc_armed,sc_started,sc_step,sc_bridge=-1;','static int sc_armed,sc_started,sc_step,sc_bridge=-1;\nstatic int video_shots;\nstatic m64p_error (*video_command)(m64p_command,int,void *);',1)
 before='}else if(pc==SC_CAMERA){if(sc_started&&sc_bridge<=45){sc_log("SC_STATE");eb_bob();}}'
 assert s.count(before)==1
 after='''}else if(pc==SC_CAMERA){if(sc_started&&sc_bridge<=65){
  sc_log("SC_STATE");eb_bob();
  if(sc_bridge>=1){
   fprintf(stderr,"VIDEO_SCREENSHOT,index=%d,requestTimer=%u,requestBridge=%d,previousFramebuffer=1,cameraEdits=0\\n",video_shots++,R32(A_GLOBAL_TIMER),sc_bridge);
   video_command(M64CMD_TAKE_NEXT_SCREENSHOT,0,NULL);
  }
 }}'''
 s=s.replace(before,after)
 before='sc_w16=dlsym(core,"DebugMemWrite16");return sc_w32&&sc_w16?M64ERR_SUCCESS:M64ERR_INCOMPATIBLE;'
 assert s.count(before)==1
 s=s.replace(before,'sc_w16=dlsym(core,"DebugMemWrite16");video_command=dlsym(core,"CoreDoCommand");return sc_w32&&sc_w16&&video_command?M64ERR_SUCCESS:M64ERR_INCOMPATIBLE;')
 s=s.replace('if(sc_bridge<=45)fprintf(stderr,"SC_INPUT','if(sc_bridge<=65)fprintf(stderr,"SC_INPUT')
 (HERE/(name+'.c')).write_bytes(s.encode());(HERE/(name+'.json')).write_bytes((SOURCE/(name+'.json')).read_bytes())
 hashes[name]['captureSource']=sha(HERE/(name+'.c'))
(HERE/'source-provenance.json').write_bytes((json.dumps(dict(scope=__doc__,sources=hashes),indent=2)+'\n').encode())
print('Prepared two capture probes; no gameplay or camera changes')
