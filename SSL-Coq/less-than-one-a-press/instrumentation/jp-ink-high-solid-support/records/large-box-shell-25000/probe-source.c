/* Original JP: supplied high air + live large-box floor, native B landing, then shell fallback nudge. No ground action is supplied. */
#define SEARCH_MODE 12
#define GetKeys clean_get_keys
#define PluginStartup clean_plugin_startup
#include "../jp-clean-gap-search/jp_clean_gap_search_probe.c"
#undef PluginStartup
#undef GetKeys
#include <mupen64plus/m64p_frontend.h>
#define DEMO_MODE 1
#define ACTOR_SLOT 13
enum { DEMO_CAMERA=0x802876d0, DEMO_BOX=A_OBJECT_POOL+ACTOR_SLOT*OBJECT_SIZE };
static void (*demo_write32)(unsigned int,unsigned int);
static void (*demo_write16)(unsigned int,unsigned short);
static m64p_error (*demo_command)(m64p_command,int,void *);
static int demo_armed,demo_started,demo_step,demo_shots;
static uint32_t entry_shell(void);

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
    fprintf(stderr,"ENTRY_ACTOR,step=%d,ridden=%08x,slot=%d,behavior=%08x,type=%u,subtype=%u,status=%u,radius=%.9g,height=%.9g\n",
      demo_step,R32(A_MARIO_STATES+0x84),ACTOR_SLOT,R32(DEMO_BOX+O_BEHAVIOR),R32(DEMO_BOX+O_INTERACT_TYPE),R32(DEMO_BOX+0x190),R32(DEMO_BOX+0x134),rfloat(DEMO_BOX+0x1f8),rfloat(DEMO_BOX+0x1fc));
    uint32_t shell=A_OBJECT_POOL+69*OBJECT_SIZE;
    fprintf(stderr,"ENTRY_AUXSHELL,step=%d,slot=%d,behavior=%08x,type=%u,subtype=%u,status=%u,radius=%.9g,height=%.9g,xyz=(%.9g,%.9g,%.9g)\n",demo_step,shell?(int)((shell-A_OBJECT_POOL)/OBJECT_SIZE):-1,shell?R32(shell+O_BEHAVIOR):0,shell?R32(shell+O_INTERACT_TYPE):0,shell?R32(shell+0x190):0,shell?R32(shell+0x134):0,shell?rfloat(shell+0x1f8):0,shell?rfloat(shell+0x1fc):0,shell?rfloat(shell+O_POS_X):0,shell?rfloat(shell+O_POS_Y):0,shell?rfloat(shell+O_POS_Z):0);
}
static void w32(uint32_t addr,uint32_t value,const char *field) {
    fprintf(stderr,"ENTRY_WRITE,step=%d,width=32,address=%08x,before=%08x,after=%08x,field=%s\n",demo_step,addr,R32(addr),value,field);
    demo_write32(addr,value);
}
static void w16(uint32_t addr,uint16_t value,const char *field) {
    fprintf(stderr,"ENTRY_WRITE,step=%d,width=16,address=%08x,before=%04x,after=%04x,field=%s\n",demo_step,addr,R16(addr),value,field);
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
    if(demo_started&&demo_step<=55){
      demo_log("ENTRY_RENDER");
      fprintf(stderr,"ENTRY_SCREENSHOT,index=%d,requestTimer=%u,previousFramebuffer=1\n",demo_shots++,R32(A_GLOBAL_TIMER));
      demo_command(M64CMD_TAKE_NEXT_SCREENSHOT,0,NULL);
    }
    resume_from_breakpoint();
}
EXPORT m64p_error CALL PluginStartup(m64p_dynlib_handle core,void *ctx,void (*cb)(void *,int,const char *)) {
    m64p_error r=clean_plugin_startup(core,ctx,cb);if(r!=M64ERR_SUCCESS)return r;
    demo_write32=dlsym(core,"DebugMemWrite32");demo_write16=dlsym(core,"DebugMemWrite16");demo_command=dlsym(core,"CoreDoCommand");
    return demo_write32&&demo_write16&&demo_command?M64ERR_SUCCESS:M64ERR_INCOMPATIBLE;
}
static uint32_t entry_shell(void) {
    for(int i=0;i<240;i++) {
        uint32_t o=A_OBJECT_POOL+i*OBJECT_SIZE;
        if(R16(o+O_ACTIVE_FLAGS)&&R32(o+O_INTERACT_TYPE)==INTERACT_KOOPA_SHELL) return o;
    }
    return 0;
}
EXPORT void CALL GetKeys(int control,BUTTONS *keys) {
    clean_get_keys(control,keys);
    if(control||!gTop)return;
    if(!demo_started&&(R16(A_CURR_AREA)!=1||R32(gTop+O_PYRAMID_PILLARS_TOUCHED)!=4))return;
    memset(keys,0,sizeof(*keys));
    if(!demo_armed){
      if(DSetCallbacks(debugger_init_callback,demo_update,debugger_vi_callback)!=M64ERR_SUCCESS||!add_exec_breakpoint(DEMO_CAMERA)){fprintf(stderr,"ENTRY_ERROR,arm\n");return;}
      demo_armed=1;
    }
    if(!demo_started){if(R32(gTop+O_ACTION)!=1||R32(gTop+O_TIMER)!=125)return;demo_started=1;demo_log("ENTRY_START");}
    if(demo_step==0)w32(A_OBJECT_POOL+32*OBJECT_SIZE+O_ACTION,4,"shellBoxAction");
    if(demo_step==4){
      demo_log("ENTRY_BEFORE_CUT");
      if(R32(gTop+O_ACTION)!=1||R32(gTop+O_TIMER)!=129){fprintf(stderr,"ENTRY_ERROR,phase129\n");return;}
      uint32_t shell=entry_shell();
      if(!shell){fprintf(stderr,"ENTRY_ERROR,missing-shell\n");return;}
      pose(-1950,25001,-939);
      action_setup(0x0100088c,32,32,0);
      wf(A_MARIO_STATES+M_VEL_Y,-16,"velocity");
      vec(DEMO_BOX+O_POS_X,-1849,24800,-939,"supportPosition");
      keys->B_BUTTON=1;
      demo_log("ENTRY_AFTER_CUT");
    }
    if(demo_step==5){
      demo_log("ENTRY_BEFORE_NUDGE_CUT");
      if(R32(gTop+O_TIMER)!=130){fprintf(stderr,"ENTRY_ERROR,phase130\n");return;}
      if(R32(A_MARIO_STATES+M_ACTION)!=0x00880456u){fprintf(stderr,"ENTRY_ERROR,no-native-dive-slide\n");return;}
      uint32_t shell=entry_shell();
      if(!shell){fprintf(stderr,"ENTRY_ERROR,missing-shell\n");return;}
      vec(shell+O_POS_X,-1971,25000,-939,"shellPosition");
      demo_log("ENTRY_AFTER_NUDGE_CUT");
    }
    if(demo_step<=55){
      uint32_t shell=entry_shell();
      fprintf(stderr,"ENTRY_SHELL,step=%d,slot=%d,action=%u,status=%u,xyz=(%.9g,%.9g,%.9g)\n",demo_step,shell?(int)((shell-A_OBJECT_POOL)/OBJECT_SIZE):-1,shell?R32(shell+O_ACTION):0,shell?R32(shell+0x134):0,shell?rfloat(shell+O_POS_X):0,shell?rfloat(shell+O_POS_Y):0,shell?rfloat(shell+O_POS_Z):0);
      fprintf(stderr,"ENTRY_INPUT,step=%d,buttons=%u,x=%d,y=%d,A=0\n",demo_step+1,keys->B_BUTTON?16384:0,keys->X_AXIS,keys->Y_AXIS);
    }
    ++demo_step;
}
