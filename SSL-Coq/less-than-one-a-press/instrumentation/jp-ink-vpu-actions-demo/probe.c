/* Original-JP conditional VPU/PU chapters. Stock camera; separate fresh runs.
 * Mode1 crawl,2butt-slide,3walking;4X-PUslide,5X-PUwalking,6XY-PUslide.
 * The logged setup is a diagnostic grant, not controller reachability. */
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
enum { DEMO_CAMERA=0x802876d0, DEMO_BOX=A_OBJECT_POOL+49*OBJECT_SIZE };
static void (*demo_write32)(unsigned int,unsigned int);
static void (*demo_write16)(unsigned int,unsigned short);
static m64p_error (*demo_command)(m64p_command,int,void *);
static int demo_armed,demo_started,demo_step,demo_shots;

static void demo_log(const char *tag) {
    uint32_t mario=R32(A_MARIO_OBJECT),floor=R32(A_MARIO_STATES+M_FLOOR);
    fprintf(stderr,"%s,mode=%d,step=%d,timer=%u,poll=%llu,area=%u,topTimer=%u,topAction=%u,topActive=%u,topBehavior=%08x,action=%08x,actionArg=%08x,actionState=%u,actionTimer=%u,held=%08x,used=%08x,boxHeld=%u,boxActive=%u,input=%u,platform=%08x,floorOwner=%08x,floor=%08x,floorY=%.9g,ceilingY=%.9g,forward=%.9g,yaw=%d,slideYaw=%d,slideVel=(%.9g,%.9g),velocity=(%.9g,%.9g,%.9g),state=(%.9g,%.9g,%.9g),collision=(%.9g,%.9g,%.9g),display=(%.9g,%.9g,%.9g),boxXYZ=(%.9g,%.9g,%.9g),boxVelocity=(%.9g,%.9g,%.9g),hitbox=%.9g\n",
      tag,DEMO_MODE,demo_step,R32(A_GLOBAL_TIMER),(unsigned long long)gPoll,R16(A_CURR_AREA),
      R32(gTop+O_TIMER),R32(gTop+O_ACTION),R16(gTop+O_ACTIVE_FLAGS),R32(gTop+O_BEHAVIOR),
      R32(A_MARIO_STATES+M_ACTION),R32(A_MARIO_STATES+0x1c),R16(A_MARIO_STATES+0x18),R16(A_MARIO_STATES+0x1a),
      R32(A_MARIO_STATES+M_HELD_OBJ),R32(A_MARIO_STATES+M_USED_OBJ),R32(DEMO_BOX+0x124),R16(DEMO_BOX+O_ACTIVE_FLAGS),
      R16(A_MARIO_STATES+M_INPUT),R32(A_MARIO_PLATFORM),floor?R32(floor+0x2c):0,floor,
      rfloat(A_MARIO_STATES+M_FLOOR_HEIGHT),rfloat(A_MARIO_STATES+0x6c),rfloat(A_MARIO_STATES+M_FORWARD_VEL),
      (int16_t)R16(A_MARIO_STATES+M_FACE_YAW),(int16_t)R16(A_MARIO_STATES+0x38),
      rfloat(A_MARIO_STATES+0x58),rfloat(A_MARIO_STATES+0x5c),
      rfloat(A_MARIO_STATES+M_VEL_X),rfloat(A_MARIO_STATES+M_VEL_Y),rfloat(A_MARIO_STATES+M_VEL_Z),
      rfloat(A_MARIO_STATES+M_POS_X),rfloat(A_MARIO_STATES+M_POS_Y),rfloat(A_MARIO_STATES+M_POS_Z),
      rfloat(mario+O_POS_X),rfloat(mario+O_POS_Y),rfloat(mario+O_POS_Z),
      rfloat(mario+GFX_POS_X),rfloat(mario+GFX_POS_Y),rfloat(mario+GFX_POS_Z),
      rfloat(DEMO_BOX+O_POS_X),rfloat(DEMO_BOX+O_POS_Y),rfloat(DEMO_BOX+O_POS_Z),
      rfloat(DEMO_BOX+0xac),rfloat(DEMO_BOX+0xb0),rfloat(DEMO_BOX+0xb4),rfloat(mario+0x1fc));
}
static void w32(uint32_t addr,uint32_t value,const char *field) {
    fprintf(stderr,"VPU_WRITE,step=%d,width=32,address=%08x,before=%08x,after=%08x,field=%s\n",demo_step,addr,R32(addr),value,field);
    demo_write32(addr,value);
}
static void w16(uint32_t addr,uint16_t value,const char *field) {
    fprintf(stderr,"VPU_WRITE,step=%d,width=16,address=%08x,before=%04x,after=%04x,field=%s\n",demo_step,addr,R16(addr),value,field);
    demo_write16(addr,value);
}
static void wf(uint32_t addr,float value,const char *field) {uint32_t b;memcpy(&b,&value,4);w32(addr,b,field);}
static void vec(uint32_t addr,float x,float y,float z,const char *field) {wf(addr,x,field);wf(addr+4,y,field);wf(addr+8,z,field);}
static void pose(float x,float y,float z) {
    uint32_t mario=R32(A_MARIO_OBJECT);
    vec(A_MARIO_STATES+M_POS_X,x,y,z,"movement");vec(mario+O_POS_X,x,y,z,"collision");vec(mario+GFX_POS_X,x,y,z,"display");
}
static void action_setup(uint32_t action,float speed,float vx,int slide) {
    w32(A_MARIO_STATES+M_ACTION,action,"action");
    w16(A_MARIO_STATES+0x18,0,"actionState");w16(A_MARIO_STATES+0x1a,0,"actionTimer");
    wf(A_MARIO_STATES+M_FORWARD_VEL,speed,"forwardVel");vec(A_MARIO_STATES+M_VEL_X,vx,0,0,"velocity");
    w16(A_MARIO_STATES+0x2c,0,"facePitch");w16(A_MARIO_STATES+0x2e,0x4000,"faceYaw");w16(A_MARIO_STATES+0x30,0,"faceRoll");
    if(slide){wf(A_MARIO_STATES+0x58,speed,"slideVelX");wf(A_MARIO_STATES+0x5c,0,"slideVelZ");w16(A_MARIO_STATES+0x38,0x4000,"slideYaw");}
}
static void demo_update(unsigned int pc) {
    if(pc!=DEMO_CAMERA){debugger_update_callback(pc);return;}
    if(demo_started&&demo_step<=148){
      demo_log("VPU_RENDER");
      fprintf(stderr,"VPU_SCREENSHOT,index=%d,requestTimer=%u,previousFramebuffer=1\n",demo_shots++,R32(A_GLOBAL_TIMER));
      demo_command(M64CMD_TAKE_NEXT_SCREENSHOT,0,NULL);
    }
    resume_from_breakpoint();
}
EXPORT m64p_error CALL PluginStartup(m64p_dynlib_handle core,void *ctx,void (*cb)(void *,int,const char *)) {
    m64p_error r=clean_plugin_startup(core,ctx,cb);if(r!=M64ERR_SUCCESS)return r;
    demo_write32=dlsym(core,"DebugMemWrite32");demo_write16=dlsym(core,"DebugMemWrite16");demo_command=dlsym(core,"CoreDoCommand");
    return demo_write32&&demo_write16&&demo_command?M64ERR_SUCCESS:M64ERR_INCOMPATIBLE;
}
EXPORT void CALL GetKeys(int control,BUTTONS *keys) {
    clean_get_keys(control,keys);
    if(control||!gTop)return;
    if(!demo_started&&(R16(A_CURR_AREA)!=1||R32(gTop+O_PYRAMID_PILLARS_TOUCHED)!=4))return;
    memset(keys,0,sizeof(*keys));
    if(!demo_armed){
      if(DSetCallbacks(debugger_init_callback,demo_update,debugger_vi_callback)!=M64ERR_SUCCESS||!add_exec_breakpoint(DEMO_CAMERA)){fprintf(stderr,"VPU_ERROR,arm\n");return;}
      demo_armed=1;
    }
    if(!demo_started){if(R32(gTop+O_ACTION)!=1||R32(gTop+O_TIMER)!=125)return;demo_started=1;demo_log("VPU_START");}
    if((DEMO_MODE==3||DEMO_MODE==5)&&demo_step==4){
      demo_log("VPU_BEFORE_WALK_PREP");pose(-1800,1280,-800);action_setup(0x04000440,20,20,0);
      keys->X_AXIS=28;keys->Y_AXIS=58;demo_log("VPU_AFTER_WALK_PREP");
    }
    if(demo_step==5){
      float x=(DEMO_MODE>=4)?63586:-1950,y=(DEMO_MODE==4||DEMO_MODE==5)?1741:67277;
      demo_log("VPU_BEFORE_CUT");
      if(R32(gTop+O_ACTION)!=1||R32(gTop+O_TIMER)!=130){fprintf(stderr,"VPU_ERROR,phase130\n");return;}
      pose(x,y,-939);vec(DEMO_BOX+O_POS_X,x-39,y,-939,"boxPosition");
      if(DEMO_MODE==1){action_setup(0x04008448,5,4,0);keys->Z_TRIG=1;keys->Y_AXIS=64;}
      else if(DEMO_MODE==3||DEMO_MODE==5){
        if(R32(A_MARIO_STATES+M_ACTION)!=0x04000440){fprintf(stderr,"VPU_ERROR,walking-preparation\n");return;}
        keys->Z_TRIG=1;keys->X_AXIS=33;keys->Y_AXIS=55;
      }else action_setup(0x00840452,20,20,1);
      demo_log("VPU_AFTER_CUT");
    }
    fprintf(stderr,"VPU_INPUT,step=%d,buttons=%u,x=%d,y=%d,A=0\n",demo_step+1,keys->Z_TRIG?8192:0,keys->X_AXIS,keys->Y_AXIS);
    ++demo_step;
}
