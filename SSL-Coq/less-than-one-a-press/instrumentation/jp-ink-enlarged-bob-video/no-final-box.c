/* Original-JP enlarged Bob video capture: no-final-box.
 * Screenshot requests only; gameplay, actor cuts and camera remain unchanged. */
#define SEARCH_MODE 12
#define GetKeys clean_get_keys
#define PluginStartup clean_plugin_startup
#include "../jp-clean-gap-search/jp_clean_gap_search_probe.c"
#undef PluginStartup
#undef GetKeys
#include <mupen64plus/m64p_frontend.h>
#ifndef DEMO_MODE
#define DEMO_MODE 1
#endif
#ifndef START_Y
#define START_Y 19900.0f
#endif
enum { SC_CAMERA=0x802876d0, SC_SHELL=A_OBJECT_POOL+71*OBJECT_SIZE, SC_PUSH=A_OBJECT_POOL+39*OBJECT_SIZE };
static void (*sc_w32)(unsigned int,unsigned int);
static void (*sc_w16)(unsigned int,unsigned short);
static int sc_armed,sc_started,sc_step,sc_bridge=-1;
static int video_shots;
static m64p_error (*video_command)(m64p_command,int,void *);
static void sw32(uint32_t a,uint32_t v,const char *field) {
 fprintf(stderr,"SC_WRITE,step=%d,bridge=%d,width=32,address=%08x,before=%08x,after=%08x,field=%s\n",sc_step,sc_bridge,a,R32(a),v,field);sc_w32(a,v);
}
static void sw16(uint32_t a,uint16_t v,const char *field) {
 fprintf(stderr,"SC_WRITE,step=%d,bridge=%d,width=16,address=%08x,before=%04x,after=%04x,field=%s\n",sc_step,sc_bridge,a,R16(a),v,field);sc_w16(a,v);
}
static void sf(uint32_t a,float v,const char *f){uint32_t b;memcpy(&b,&v,4);sw32(a,b,f);}
static void sv(uint32_t a,float x,float y,float z,const char *f){sf(a,x,f);sf(a+4,y,f);sf(a+8,z,f);}
static void sp(float x,float y,float z){uint32_t m=R32(A_MARIO_OBJECT);sv(A_MARIO_STATES+M_POS_X,x,y,z,"movement");sv(m+O_POS_X,x,y,z,"collision");sv(m+GFX_POS_X,x,y,z,"storedGraphics");}
static void sa(int airborne){sw32(A_MARIO_STATES+M_ACTION,airborne?0x0100088c:0x0c400201,"action");sw16(A_MARIO_STATES+0x18,0,"actionState");sw16(A_MARIO_STATES+0x1a,0,"actionTimer");sv(A_MARIO_STATES+M_VEL_X,airborne?20:0,airborne?-16:0,0,"velocity");sf(A_MARIO_STATES+M_FORWARD_VEL,airborne?20:0,"forwardVel");sw16(A_MARIO_STATES+0x2c,0,"facePitch");sw16(A_MARIO_STATES+0x2e,airborne?16384:0,"faceYaw");sw16(A_MARIO_STATES+0x30,0,"faceRoll");}
static void sc_log(const char *tag){
 uint32_t m=R32(A_MARIO_OBJECT),f=R32(A_MARIO_STATES+M_FLOOR),s=SC_SHELL;
 fprintf(stderr,"%s,step=%d,bridge=%d,mode=%d,timer=%u,area=%u,topTimer=%u,topAction=%u,topActive=%u,action=%08x,actionState=%u,actionTimer=%u,input=%u,held=%08x,used=%08x,ridden=%08x,platform=%08x,floor=%08x,floorOwner=%08x,floorY=%.9g,ceilY=%.9g,forward=%.9g,M=(%.9g,%.9g,%.9g),C=(%.9g,%.9g,%.9g),G=(%.9g,%.9g,%.9g),vel=(%.9g,%.9g,%.9g),shellXYZ=(%.9g,%.9g,%.9g),shellActive=%u,shellBehavior=%08x,shellType=%u,shellIntangible=%d,shellStatus=%u,shellAction=%u,shellHeld=%u,shellRadius=%.9g,shellHeight=%.9g,command=%08x,opcode=%08x,stack=%u,collidedCount=%u,collided=(%08x,%08x,%08x,%08x),pushXYZ=(%.9g,%.9g,%.9g)\n",
 tag,sc_step,sc_bridge,DEMO_MODE,R32(A_GLOBAL_TIMER),R16(A_CURR_AREA),R32(gTop+O_TIMER),R32(gTop+O_ACTION),R16(gTop+O_ACTIVE_FLAGS),R32(A_MARIO_STATES+M_ACTION),R16(A_MARIO_STATES+0x18),R16(A_MARIO_STATES+0x1a),R16(A_MARIO_STATES+M_INPUT),R32(A_MARIO_STATES+M_HELD_OBJ),R32(A_MARIO_STATES+M_USED_OBJ),R32(A_MARIO_STATES+0x84),R32(A_MARIO_PLATFORM),f,f?R32(f+0x2c):0,rfloat(A_MARIO_STATES+M_FLOOR_HEIGHT),rfloat(A_MARIO_STATES+0x6c),rfloat(A_MARIO_STATES+M_FORWARD_VEL),
 rfloat(A_MARIO_STATES+M_POS_X),rfloat(A_MARIO_STATES+M_POS_Y),rfloat(A_MARIO_STATES+M_POS_Z),rfloat(m+O_POS_X),rfloat(m+O_POS_Y),rfloat(m+O_POS_Z),rfloat(m+GFX_POS_X),rfloat(m+GFX_POS_Y),rfloat(m+GFX_POS_Z),rfloat(A_MARIO_STATES+M_VEL_X),rfloat(A_MARIO_STATES+M_VEL_Y),rfloat(A_MARIO_STATES+M_VEL_Z),
 rfloat(s+O_POS_X),rfloat(s+O_POS_Y),rfloat(s+O_POS_Z),R16(s+O_ACTIVE_FLAGS),R32(s+O_BEHAVIOR),R32(s+O_INTERACT_TYPE),(int32_t)R32(s+0x9c),R32(s+0x134),R32(s+O_ACTION),R32(s+0x124),rfloat(s+0x1f8),rfloat(s+0x1fc),R32(s+0x1cc),R32(s+0x1cc)?R32(R32(s+0x1cc)):0,R32(s+0x1d0),R16(m+0x76),R32(m+0x78),R32(m+0x7c),R32(m+0x80),R32(m+0x84),rfloat(SC_PUSH+O_POS_X),rfloat(SC_PUSH+O_POS_Y),rfloat(SC_PUSH+O_POS_Z));
}
/* Read-only execute hooks. ROM main text maps byte 0x1000 to 0x80246000.
 * The query epilogue is inherited from the hash-authenticated rank1 audit;
 * quarter-step addresses were checked against this same JP ROM. */
enum { FD_QUERY=0x80381900, FD_QUERY_RETURN=0x80381b90,
 FD_GROUND=0x80255b60, FD_GROUND_RETURN=0x80255c8c,
 FD_QUARTER=0x802558dc, FD_QUARTER_RETURN=0x80255b4c,
 FD_QUARTER_CHECK=0x80255968, FD_QUARTER_COMMIT=0x80255ab4,
 FD_LOAD_MODEL=0x803839cc, FD_LOAD_SURFACES=0x80383828 };
static uint32_t fd_query_caller;
static int fd_live(void){return sc_bridge>=1&&sc_bridge<=8;}
static float fd_f0(void){float **p=(float **)DGetCPUDataPtr(M64P_CPU_REG_COP1_SIMPLE_PTR);return p&&p[0]?*p[0]:NAN;}
static void fd_surface(uint32_t s){
 if(!s)return;
 fprintf(stderr,"FD_SURFACE,surface=%08x,owner=%08x,type=%u,normal=(%.9g,%.9g,%.9g),origin=%.9g,vertices=(%d,%d,%d;%d,%d,%d;%d,%d,%d)\n",s,R32(s+0x2c),R16(s),rfloat(s+0x1c),rfloat(s+0x20),rfloat(s+0x24),rfloat(s+0x28),(int16_t)R16(s+0xa),(int16_t)R16(s+0xc),(int16_t)R16(s+0xe),(int16_t)R16(s+0x10),(int16_t)R16(s+0x12),(int16_t)R16(s+0x14),(int16_t)R16(s+0x16),(int16_t)R16(s+0x18),(int16_t)R16(s+0x1a));
}

static void eb_bob(void){uint32_t b=SC_PUSH;
 fprintf(stderr,"EB_BOB,bridge=%d,active=%u,type=%u,subtype=%u,intangible=%d,status=%u,action=%u,timer=%u,held=%u,fuse=%u,command=%08x,behavior=%08x,radius=%.9g,height=%.9g,scale=(%.9g,%.9g,%.9g),pos=(%.9g,%.9g,%.9g),vel=(%.9g,%.9g,%.9g),forward=%.9g\n",sc_bridge,R16(b+0x74),R32(b+0x130),R32(b+0x190),(int32_t)R32(b+0x9c),R32(b+0x134),R32(b+0x14c),R32(b+0x154),R32(b+0x124),R32(b+0xfc),R32(b+0x1cc),R32(b+0x20c),rfloat(b+0x1f8),rfloat(b+0x1fc),rfloat(b+0x2c),rfloat(b+0x30),rfloat(b+0x34),rfloat(b+0xa0),rfloat(b+0xa4),rfloat(b+0xa8),rfloat(b+0xac),rfloat(b+0xb0),rfloat(b+0xb4),rfloat(b+0xb8));
}

static void sc_update(unsigned int pc){
 uint64_t *r=(uint64_t *)DGetCPUDataPtr(M64P_CPU_REG_REG);
 uint32_t sp=r?(uint32_t)r[29]:0;
 if(pc==FD_QUERY){fd_query_caller=r?(uint32_t)r[31]:0;}
 else if(pc==FD_QUERY_RETURN){
  if(fd_live()){
   uint32_t p=R32(sp+0x4c),s=p?R32(p):0;
   fprintf(stderr,"FD_QUERY,bridge=%d,timer=%u,caller=%08x,current=%08x,query=(%.9g,%.9g,%.9g),result=%.9g,surface=%08x,owner=%08x,cache=%.9g,M=(%.9g,%.9g,%.9g)\n",sc_bridge,R32(A_GLOBAL_TIMER),fd_query_caller,R32(A_CURRENT_OBJECT),rfloat(sp+0x40),rfloat(sp+0x44),rfloat(sp+0x48),fd_f0(),s,s?R32(s+0x2c):0,rfloat(A_MARIO_STATES+M_FLOOR_HEIGHT),rfloat(A_MARIO_STATES+M_POS_X),rfloat(A_MARIO_STATES+M_POS_Y),rfloat(A_MARIO_STATES+M_POS_Z));
   fd_surface(s);
  }
 }else if(pc==FD_GROUND||pc==FD_GROUND_RETURN||pc==FD_QUARTER||pc==FD_QUARTER_RETURN||pc==FD_QUARTER_CHECK||pc==FD_QUARTER_COMMIT){
  if(fd_live()){
   fprintf(stderr,"FD_STEP,bridge=%d,pc=%08x,result=%d,cache=%.9g\n",sc_bridge,pc,r?(int32_t)r[2]:-999,rfloat(A_MARIO_STATES+M_FLOOR_HEIGHT));
   sc_log(pc==FD_GROUND?"FD_GROUND_ENTRY":pc==FD_GROUND_RETURN?"FD_GROUND_RETURN":pc==FD_QUARTER?"FD_QUARTER_ENTRY":pc==FD_QUARTER_RETURN?"FD_QUARTER_RETURN":pc==FD_QUARTER_COMMIT?"FD_QUARTER_COMMIT":"FD_QUARTER_CHECK");
   if(pc==FD_QUARTER_CHECK||pc==FD_QUARTER_RETURN){uint32_t p=R32(sp+0x44),s=R32(sp+0x30),c=R32(sp+0x34);fprintf(stderr,"FD_LOCAL,bridge=%d,pc=%08x,next=(%.9g,%.9g,%.9g),floor=%.9g,floorPointer=%08x,owner=%08x,ceiling=%.9g,ceilingPointer=%08x,upperWall=%08x\n",sc_bridge,pc,rfloat(p),rfloat(p+4),rfloat(p+8),rfloat(sp+0x28),s,s?R32(s+0x2c):0,rfloat(sp+0x2c),c,R32(sp+0x38));fd_surface(c);}
  }
 }else if(pc==FD_LOAD_MODEL||pc==FD_LOAD_SURFACES){
  if(fd_live()&&R32(A_CURRENT_OBJECT)==gTop)fprintf(stderr,"FD_TOP_LOAD,bridge=%d,pc=%08x,topTimer=%u,pos=(%.9g,%.9g,%.9g),yaw=%d,distance=%.9g,collisionDistance=%.9g,surfaces=%u\n",sc_bridge,pc,R32(gTop+O_TIMER),rfloat(gTop+O_POS_X),rfloat(gTop+O_POS_Y),rfloat(gTop+O_POS_Z),(int32_t)R32(gTop+0xc8),rfloat(gTop+0x15c),rfloat(gTop+0x194),R32(A_SURFACES_ALLOCATED));
 }else if(pc==SC_CAMERA){if(sc_started&&sc_bridge<=65){
  sc_log("SC_STATE");eb_bob();
  if(sc_bridge>=1){
   fprintf(stderr,"VIDEO_SCREENSHOT,index=%d,requestTimer=%u,requestBridge=%d,previousFramebuffer=1,cameraEdits=0\n",video_shots++,R32(A_GLOBAL_TIMER),sc_bridge);
   video_command(M64CMD_TAKE_NEXT_SCREENSHOT,0,NULL);
  }
 }}
 else{debugger_update_callback(pc);return;}
 resume_from_breakpoint();
}
EXPORT m64p_error CALL PluginStartup(m64p_dynlib_handle core,void *ctx,void (*cb)(void *,int,const char *)){
 m64p_error r=clean_plugin_startup(core,ctx,cb);if(r!=M64ERR_SUCCESS)return r;sc_w32=dlsym(core,"DebugMemWrite32");sc_w16=dlsym(core,"DebugMemWrite16");video_command=dlsym(core,"CoreDoCommand");return sc_w32&&sc_w16&&video_command?M64ERR_SUCCESS:M64ERR_INCOMPATIBLE;
}

static const int case_pads[][3]={{8192,0,0},
{0,0,0},
{0,0,0},
{0,0,0},
{0,0,0},
{0,0,0},
{0,0,0},
{0,0,0},
{0,0,0},
{0,0,0},
{0,0,0},
{0,0,0},
{0,0,0},
{0,0,0},
{0,0,0},
{0,0,0},
{0,0,0},
{0,0,0},
{0,0,0},
{0,0,0},
{0,0,0},
{0,0,0},
{0,0,0},
{0,0,0},
{0,0,0},
{0,0,0},
{0,0,0}};

EXPORT void CALL GetKeys(int control,BUTTONS *keys){
 clean_get_keys(control,keys);if(control||!gTop)return;
 if(!sc_started&&(R16(A_CURR_AREA)!=1||R32(gTop+O_PYRAMID_PILLARS_TOUCHED)!=4))return;
 memset(keys,0,sizeof(*keys));
 if(!sc_armed){unsigned i;uint32_t pcs[]={SC_CAMERA,FD_QUERY,FD_QUERY_RETURN,FD_GROUND,FD_GROUND_RETURN,FD_QUARTER,FD_QUARTER_RETURN,FD_QUARTER_CHECK,FD_QUARTER_COMMIT,FD_LOAD_MODEL,FD_LOAD_SURFACES};if(DSetCallbacks(debugger_init_callback,sc_update,debugger_vi_callback)!=M64ERR_SUCCESS){fprintf(stderr,"SC_ERROR,callback\n");return;}for(i=0;i<sizeof(pcs)/sizeof(pcs[0]);i++)if(!add_exec_breakpoint(pcs[i])){fprintf(stderr,"SC_ERROR,arm\n");return;}sc_armed=1;}
 if(!sc_started){sc_started=1;sc_log("SC_START");}
 if(sc_step==0)sw32(A_OBJECT_POOL+32*OBJECT_SIZE+O_ACTION,4,"shellBoxAction");
 if(sc_step==2){if(R32(SC_SHELL+O_INTERACT_TYPE)!=INTERACT_KOOPA_SHELL){fprintf(stderr,"SC_ERROR,shell-not-initialized\n");return;}sp(5900,51,3380);sa(0);sv(SC_SHELL+O_POS_X,6100,51,3380,"shellPosition");keys->B_BUTTON=1;}
 if(sc_step==6){if(R32(A_MARIO_STATES+M_ACTION)!=0x383||R32(A_MARIO_STATES+M_USED_OBJ)!=A_OBJECT_POOL+23*OBJECT_SIZE){fprintf(stderr,"SC_ERROR,pickup-entry\n");return;}sw32(A_MARIO_STATES+M_USED_OBJ,SC_SHELL,"usedReference");}
 if(sc_step==19){if(R32(A_MARIO_STATES+M_ACTION)!=0x08000207||R32(A_MARIO_STATES+M_HELD_OBJ)!=SC_SHELL){fprintf(stderr,"SC_ERROR,hold-idle\n");return;}keys->B_BUTTON=1;}
 if(sc_step==25){if(R32(A_MARIO_STATES+M_ACTION)!=0x80000588u||R16(A_MARIO_STATES+0x1a)!=6){fprintf(stderr,"SC_ERROR,throw-phase\n");return;}sv(R32(A_MARIO_STATES+0x98)+0x18,-1950,19890,-971,"highHOLP");}
 if(sc_step>=43&&sc_bridge<0&&R32(gTop+O_ACTION)==1&&R32(gTop+O_TIMER)==128){
  sc_bridge=0;sc_log("SC_BEFORE_CUT");
  sw32(0x80341f04u,0x00000000u,"gObjectPool[39].oAction");
  sw32(0x80341f44u,0x00000000u,"gObjectPool[39].oPrevAction");
  sw32(0x80341f0cu,0x00000000u,"gObjectPool[39].oTimer");
  sw32(0x80341edcu,0x00000000u,"gObjectPool[39].oHeldState");
  sw32(0x80341eb4u,0x000000aau,"gObjectPool[39].oBobombFuseTimer");
  sw32(0x80341eb0u,0x00000001u,"gObjectPool[39].oBobombFuseLit");
  sw32(0x80341eacu,0x00000000u,"gObjectPool[39].oBobombBlinkTimer");
  sw32(0x80341e44u,0x40006449u,"gObjectPool[39].oFlags");
  sw32(0x80341e54u,0x00000000u,"gObjectPool[39].oIntangibleTimer");
  sw32(0x80341eecu,0x00000000u,"gObjectPool[39].oInteractStatus");
  sw32(0x80341ea4u,0x00000000u,"gObjectPool[39].oMoveFlags");
  sw32(0x80341e64u,0x00000000u,"gObjectPool[39].oVelX");
  sw32(0x80341e68u,0x00000000u,"gObjectPool[39].oVelY");
  sw32(0x80341e6cu,0x00000000u,"gObjectPool[39].oVelZ");
  sw32(0x80341e70u,0x00000000u,"gObjectPool[39].oForwardVel");
  sw32(0x80341e7cu,0x00000000u,"gObjectPool[39].oMoveAnglePitch");
  sw32(0x80341e80u,0x00000a05u,"gObjectPool[39].oMoveAngleYaw");
  sw32(0x80341e84u,0x00000000u,"gObjectPool[39].oMoveAngleRoll");
  sw32(0x80341e88u,0x00000000u,"gObjectPool[39].oFaceAnglePitch");
  sw32(0x80341e8cu,0x00000a05u,"gObjectPool[39].oFaceAngleYaw");
  sw32(0x80341e90u,0x00000000u,"gObjectPool[39].oFaceAngleRoll");
  sw32(0x80341e9cu,0x40200000u,"gObjectPool[39].oGravity");
  sw32(0x80341f28u,0x3f4ccccdu,"gObjectPool[39].oFriction");
  sw32(0x80341f2cu,0x3fa66666u,"gObjectPool[39].oBuoyancy");
  sw32(0x80341ea8u,0x00000000u,"gObjectPool[39].oAnimState");
  sw32(0x80341de4u,0x3fb33333u,"gObjectPool[39].header.gfx.scale");
  sw32(0x80341de8u,0x3fb33333u,"gObjectPool[39].header.gfx.scale");
  sw32(0x80341decu,0x3fb33333u,"gObjectPool[39].header.gfx.scale");
  sw16(0x80341dbau,0x00000021u,"gObjectPool[39].header.gfx.node.flags");
  sw32(0x80341fb0u,0x42b60000u,"gObjectPool[39].hitboxRadius");
  sw32(0x80341fb4u,0x431e3333u,"gObjectPool[39].hitboxHeight");
  sw32(0x80341fc0u,0x00000000u,"gObjectPool[39].hitboxDownOffset");
  sw32(0x80341fb8u,0x00000000u,"gObjectPool[39].hurtboxRadius");
  sw32(0x80341fbcu,0x00000000u,"gObjectPool[39].hurtboxHeight");
  sw32(0x80339e3cu,0xc4f50000u,"gMarioState.pos");
  sw32(0x80339e40u,0x469b7800u,"gMarioState.pos");
  sw32(0x80339e44u,0xc499c000u,"gMarioState.pos");
  sw32(0x80346058u,0xc4f50000u,"gMarioObject.header.gfx.pos");
  sw32(0x8034605cu,0x469b7800u,"gMarioObject.header.gfx.pos");
  sw32(0x80346060u,0xc499c000u,"gMarioObject.header.gfx.pos");
  sw32(0x803460d8u,0xc4f50000u,"gMarioObject.oPosX");
  sw32(0x803460dcu,0x469b7800u,"gMarioObject.oPosY");
  sw32(0x803460e0u,0xc499c000u,"gMarioObject.oPosZ");
  sw32(0x80339e0cu,0x0100088cu,"gMarioState.action");
  sw16(0x80339e18u,0x00000000u,"gMarioState.actionState");
  sw16(0x80339e1au,0x00000000u,"gMarioState.actionTimer");
  sw32(0x80339e48u,0x00000000u,"gMarioState.vel");
  sw32(0x80339e4cu,0xc1800000u,"gMarioState.vel");
  sw32(0x80339e50u,0x00000000u,"gMarioState.vel");
  sw32(0x80339e54u,0x00000000u,"gMarioState.forwardVel");
  sw16(0x80339e2cu,0x00000000u,"gMarioState.faceAngle");
  sw16(0x80339e2eu,0x00004000u,"gMarioState.faceAngle");
  sw16(0x80339e30u,0x00000000u,"gMarioState.faceAngle");
  sw32(0x80339e48u,0x00000000u,"gMarioState.vel");
  sw32(0x80339e4cu,0xc1800000u,"gMarioState.vel");
  sw32(0x80339e50u,0x00000000u,"gMarioState.vel");
  sw16(0x80339e2cu,0x00000000u,"gMarioState.faceAngle");
  sw16(0x80339e2eu,0x00000000u,"gMarioState.faceAngle");
  sw16(0x80339e30u,0x00000000u,"gMarioState.faceAngle");
  sw32(0x80346a58u,0xc4f50000u,"gObjectPool[71].oPosX");
  sw32(0x80346a5cu,0x469b6400u,"gObjectPool[71].oPosY");
  sw32(0x80346a60u,0xc499c000u,"gObjectPool[71].oPosZ");
  sc_log("SC_AFTER_CUT");
 }
 if(sc_bridge>=0&&sc_bridge==1){
  sw32(0x80341e58u,0xc50200f6u,"gObjectPool[39].oPosX");
  sw32(0x80341e5cu,0x44e2269du,"gObjectPool[39].oPosY");
  sw32(0x80341e60u,0xc499ca4eu,"gObjectPool[39].oPosZ");
  sc_log("SC_AFTER_PUSH_CUT");
 }

 if(sc_bridge>=0&&(unsigned)sc_bridge<sizeof(case_pads)/sizeof(case_pads[0])){
  int buttons=case_pads[sc_bridge][0];keys->B_BUTTON=(buttons&0x4000)!=0;keys->Z_TRIG=(buttons&0x2000)!=0;keys->X_AXIS=case_pads[sc_bridge][1];keys->Y_AXIS=case_pads[sc_bridge][2];
 }
 if(sc_bridge<=65)fprintf(stderr,"SC_INPUT,step=%d,bridge=%d,buttons=%u,x=%d,y=%d,A=0\n",sc_step+1,sc_bridge<0?-1:sc_bridge+1,(keys->B_BUTTON?16384:0)|(keys->Z_TRIG?8192:0),keys->X_AXIS,keys->Y_AXIS);
 ++sc_step;if(sc_bridge>=0)++sc_bridge;
}
