/* Original JP: actual frozen-shell substitution into the prior Y19900
 * immediate-Z / Box+Buddy / Box sequence. Mode1 full; mode2 omit Buddy.
 * Initial FREEFALL and actor positions are grants; no later Mario edits. */
#define SEARCH_MODE 12
#define GetKeys clean_get_keys
#define PluginStartup clean_plugin_startup
#include "../jp-clean-gap-search/jp_clean_gap_search_probe.c"
#undef PluginStartup
#undef GetKeys
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
static void sc_update(unsigned int pc){if(pc!=SC_CAMERA){debugger_update_callback(pc);return;}if(sc_started&&sc_bridge<=35)sc_log("SC_STATE");resume_from_breakpoint();}
EXPORT m64p_error CALL PluginStartup(m64p_dynlib_handle core,void *ctx,void (*cb)(void *,int,const char *)){
 m64p_error r=clean_plugin_startup(core,ctx,cb);if(r!=M64ERR_SUCCESS)return r;sc_w32=dlsym(core,"DebugMemWrite32");sc_w16=dlsym(core,"DebugMemWrite16");return sc_w32&&sc_w16?M64ERR_SUCCESS:M64ERR_INCOMPATIBLE;
}
EXPORT void CALL GetKeys(int control,BUTTONS *keys){
 clean_get_keys(control,keys);if(control||!gTop)return;
 if(!sc_started&&(R16(A_CURR_AREA)!=1||R32(gTop+O_PYRAMID_PILLARS_TOUCHED)!=4))return;
 memset(keys,0,sizeof(*keys));
 if(!sc_armed){if(DSetCallbacks(debugger_init_callback,sc_update,debugger_vi_callback)!=M64ERR_SUCCESS||!add_exec_breakpoint(SC_CAMERA)){fprintf(stderr,"SC_ERROR,arm\n");return;}sc_armed=1;}
 if(!sc_started){sc_started=1;sc_log("SC_START");}
 if(sc_step==0)sw32(A_OBJECT_POOL+32*OBJECT_SIZE+O_ACTION,4,"shellBoxAction");
 if(sc_step==2){if(R32(SC_SHELL+O_INTERACT_TYPE)!=INTERACT_KOOPA_SHELL){fprintf(stderr,"SC_ERROR,shell-not-initialized\n");return;}sp(5900,51,3380);sa(0);sv(SC_SHELL+O_POS_X,6100,51,3380,"shellPosition");keys->B_BUTTON=1;}
 if(sc_step==6){if(R32(A_MARIO_STATES+M_ACTION)!=0x383||R32(A_MARIO_STATES+M_USED_OBJ)!=A_OBJECT_POOL+23*OBJECT_SIZE){fprintf(stderr,"SC_ERROR,pickup-entry\n");return;}sw32(A_MARIO_STATES+M_USED_OBJ,SC_SHELL,"usedReference");}
 if(sc_step==19){if(R32(A_MARIO_STATES+M_ACTION)!=0x08000207||R32(A_MARIO_STATES+M_HELD_OBJ)!=SC_SHELL){fprintf(stderr,"SC_ERROR,hold-idle\n");return;}keys->B_BUTTON=1;}
 if(sc_step==25){if(R32(A_MARIO_STATES+M_ACTION)!=0x80000588u||R16(A_MARIO_STATES+0x1a)!=6){fprintf(stderr,"SC_ERROR,throw-phase\n");return;}sv(R32(A_MARIO_STATES+0x98)+0x18,-1950,START_Y-10,-971,"highHOLP");}
 if(sc_step>=43&&sc_bridge<0&&R32(gTop+O_ACTION)==1&&R32(gTop+O_TIMER)==128){
  sc_bridge=0;sc_log("SC_BEFORE_CUT");
  sp(-1920,START_Y,-1210);sv(SC_SHELL+O_POS_X,-1920,START_Y-10,-1210,"shellPosition");
  sa(1);sv(A_MARIO_STATES+M_VEL_X,0,-16,20,"velocity");sw16(A_MARIO_STATES+0x2e,0,"faceYaw");keys->Z_TRIG=1;sc_log("SC_AFTER_CUT");
 }
 if(sc_bridge==1){
  sv(A_OBJECT_POOL+49*OBJECT_SIZE+O_POS_X,-1990.710693359375f,1799.2869873046875f,-1280.710693359375f,"box129");
  if(DEMO_MODE==1)sv(A_OBJECT_POOL+15*OBJECT_SIZE+O_POS_X,-2054.455810546875f,1799.2869873046875f,-1208.867919921875f,"buddy129");
  sc_log("SC_AFTER_PUSH_CUT");
 }
 if(sc_bridge==2){sv(A_OBJECT_POOL+49*OBJECT_SIZE+O_POS_X,-2117.125244140625f,1830.177978515625f,-1128.1343994140625f,"box130");sc_log("SC_AFTER_PUSH_CUT");}
 if(sc_bridge<=35)fprintf(stderr,"SC_INPUT,step=%d,bridge=%d,buttons=%u,x=%d,y=%d,A=0\n",sc_step+1,sc_bridge<0?-1:sc_bridge+1,(keys->B_BUTTON?16384:0)|(keys->Z_TRIG?8192:0),keys->X_AXIS,keys->Y_AXIS);
 ++sc_step;if(sc_bridge>=0)++sc_bridge;
}
