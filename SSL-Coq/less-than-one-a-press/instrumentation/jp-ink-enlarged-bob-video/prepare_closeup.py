"""Separately labeled GraphNodeCamera-only closeup of the positive replay."""
import hashlib,json
from pathlib import Path
HERE=Path(__file__).resolve().parent
p=HERE/'positive.c';s=p.read_text();original=hashlib.sha256(p.read_bytes()).hexdigest()
s=s.replace('/* Original-JP enlarged Bob video capture: positive.','/* Original-JP enlarged Bob video capture: positive-closeup (render camera only).',1)
s=s.replace('Screenshot requests only; gameplay, actor cuts and camera remain unchanged.','GraphNodeCamera output only is overridden after native camera update; gameplay camera remains unchanged.',1)
needle='static void sc_update(unsigned int pc){'
camera='''/* Original-JP update_graph_node_camera return, checked against ROM bytes.
 * Change only rendered GraphNodeCamera pos/focus/roll. Do not touch Camera,
 * LakituState, Mario, objects, surfaces, input or gameplay cache. */
enum { VIDEO_RENDER_DONE=0x80287738 };
static void video_cf(uint32_t address,float value,const char *field){
 uint32_t bits;memcpy(&bits,&value,4);
 fprintf(stderr,"VIDEO_CAMERA_WRITE,bridge=%d,timer=%u,address=%08x,width=32,before=%08x,after=%08x,field=%s\\n",sc_bridge,R32(A_GLOBAL_TIMER),address,R32(address),bits,field);sc_w32(address,bits);
}
static void video_view(uint32_t gc){
 float x=-2070,y=1840,z=-1160,dx=-650,dy=420,dz=-600;
 if(R16(A_CURR_AREA)==2){x=rfloat(A_MARIO_STATES+M_POS_X);y=rfloat(A_MARIO_STATES+M_POS_Y)+60;z=rfloat(A_MARIO_STATES+M_POS_Z);dx=600;dy=280;dz=600;}
 video_cf(gc+0x1c,x+dx,"GraphNodeCamera.pos.x");video_cf(gc+0x20,y+dy,"GraphNodeCamera.pos.y");video_cf(gc+0x24,z+dz,"GraphNodeCamera.pos.z");
 video_cf(gc+0x28,x,"GraphNodeCamera.focus.x");video_cf(gc+0x2c,y,"GraphNodeCamera.focus.y");video_cf(gc+0x30,z,"GraphNodeCamera.focus.z");
 fprintf(stderr,"VIDEO_CAMERA_WRITE,bridge=%d,timer=%u,address=%08x,width=16,before=%04x,after=0000,field=GraphNodeCamera.rollScreen\\n",sc_bridge,R32(A_GLOBAL_TIMER),gc+0x3a,R16(gc+0x3a));sc_w16(gc+0x3a,0);
}
'''
assert s.count(needle)==1;s=s.replace(needle,camera+needle)
needle=' if(pc==FD_QUERY){fd_query_caller=r?(uint32_t)r[31]:0;}'
assert s.count(needle)==1;s=s.replace(needle,' if(pc==VIDEO_RENDER_DONE){if(sc_bridge>=1&&sc_bridge<=65)video_view(R32(sp+0x28));}\n else if(pc==FD_QUERY){fd_query_caller=r?(uint32_t)r[31]:0;}')
s=s.replace('uint32_t pcs[]={SC_CAMERA,FD_QUERY','uint32_t pcs[]={SC_CAMERA,VIDEO_RENDER_DONE,FD_QUERY',1)
s=s.replace('previousFramebuffer=1,cameraEdits=0','previousFramebuffer=1,cameraEdits=render-only')
(HERE/'positive-closeup.c').write_bytes(s.encode());(HERE/'positive-closeup.json').write_bytes((HERE/'positive.json').read_bytes())
(HERE/'closeup-provenance.json').write_bytes((json.dumps(dict(scope=__doc__,defaultCaptureSourceSha256=original,closeupSourceSha256=hashlib.sha256(s.encode()).hexdigest(),hook='0x80287738 update_graph_node_camera epilogue',fields='GraphNodeCamera pos offsets0x1c/20/24, focus0x28/2c/30, rollScreen0x3a',nativeCameraAndGameplayEdits=0),indent=2)+'\n').encode())
print('Prepared separately labeled render-only positive closeup')
