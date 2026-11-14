/* Stock JP Buddy movement diagnostic. The conditional cases replace only
 * usedObj during a native small-box pickup. This does NOT construct cloning. */
#define SEARCH_MODE 12
#define GetKeys prefix_get_keys
#define PluginStartup prefix_plugin_startup
#include "../jp-clean-gap-search/jp_clean_gap_search_probe.c"
#undef PluginStartup
#undef GetKeys
#ifndef BUDDY_MODE
#define BUDDY_MODE 1
#endif
enum { BUDDY=A_OBJECT_POOL+15*OBJECT_SIZE, SMALL_BOX=A_OBJECT_POOL+23*OBJECT_SIZE };
static void (*buddy_write32)(unsigned int,unsigned int);
static void (*buddy_write16)(unsigned int,unsigned short);
static int started,step,retargeted,released;
static uint32_t last_native_timer;
static void bw32(uint32_t a,uint32_t v,const char *label) {
    fprintf(stderr,"BUDDY_WRITE,step=%d,width=32,address=%08x,before=%08x,after=%08x,label=%s\n",step,a,R32(a),v,label);
    buddy_write32(a,v);
}
static void bw16(uint32_t a,uint16_t v,const char *label) {
    fprintf(stderr,"BUDDY_WRITE,step=%d,width=16,address=%08x,before=%04x,after=%04x,label=%s\n",step,a,R16(a),v,label);
    buddy_write16(a,v);
}
static void bf(uint32_t a,float v,const char *label) {uint32_t b;memcpy(&b,&v,4);bw32(a,b,label);}
static void bv(uint32_t a,float x,float y,float z,const char *label) {bf(a,x,label);bf(a+4,y,label);bf(a+8,z,label);}
static void buddy_log(const char *tag) {
    uint32_t m=R32(A_MARIO_OBJECT);
    fprintf(stderr,"%s,mode=%d,step=%d,timer=%u,poll=%llu,area=%u,action=%08x,used=%08x,held=%08x,M=(%.9g,%.9g,%.9g),C=(%.9g,%.9g,%.9g),D=(%.9g,%.9g,%.9g),buddy=(%.9g,%.9g,%.9g),buddyBits=(%08x,%08x,%08x),buddyHeld=%u,buddyAction=%u,buddyActive=%u,buddyBehavior=%08x,buddyCommand=%08x,buddySpeed=%.9g,buddyVelY=%.9g,input=%u\n",
      tag,BUDDY_MODE,step,R32(A_GLOBAL_TIMER),(unsigned long long)gPoll,R16(A_CURR_AREA),R32(A_MARIO_STATES+M_ACTION),R32(A_MARIO_STATES+M_USED_OBJ),R32(A_MARIO_STATES+M_HELD_OBJ),
      rfloat(A_MARIO_STATES+M_POS_X),rfloat(A_MARIO_STATES+M_POS_Y),rfloat(A_MARIO_STATES+M_POS_Z),
      rfloat(m+O_POS_X),rfloat(m+O_POS_Y),rfloat(m+O_POS_Z),rfloat(m+GFX_POS_X),rfloat(m+GFX_POS_Y),rfloat(m+GFX_POS_Z),
      rfloat(BUDDY+O_POS_X),rfloat(BUDDY+O_POS_Y),rfloat(BUDDY+O_POS_Z),R32(BUDDY+O_POS_X),R32(BUDDY+O_POS_Y),R32(BUDDY+O_POS_Z),
      R32(BUDDY+0x124),R32(BUDDY+O_ACTION),R16(BUDDY+O_ACTIVE_FLAGS),R32(BUDDY+O_BEHAVIOR),R32(BUDDY+0x1cc),rfloat(BUDDY+0xb8),rfloat(BUDDY+0xb0),R16(A_MARIO_STATES+M_INPUT));
}
EXPORT m64p_error CALL PluginStartup(m64p_dynlib_handle core,void *ctx,void (*cb)(void *,int,const char *)) {
    m64p_error r=prefix_plugin_startup(core,ctx,cb);if(r!=M64ERR_SUCCESS)return r;
    buddy_write32=dlsym(core,"DebugMemWrite32");buddy_write16=dlsym(core,"DebugMemWrite16");
    return buddy_write32&&buddy_write16?M64ERR_SUCCESS:M64ERR_INCOMPATIBLE;
}
EXPORT void CALL GetKeys(int control,BUTTONS *keys) {
    prefix_get_keys(control,keys);
    if(control||!gTop||R16(A_CURR_AREA)!=1)return;
    if(!started){
      if(R32(A_GLOBAL_TIMER)!=last_native_timer){buddy_log("BUDDY_NATIVE");last_native_timer=R32(A_GLOBAL_TIMER);}
      if(R32(gTop+O_ACTION)!=1||R32(gTop+O_TIMER)!=125)return;
      if(R32(A_MARIO_STATES+M_HELD_OBJ)){fprintf(stderr,"BUDDY_ERROR,alreadyheld\n");return;}
      started=1;buddy_log("BUDDY_BEFORE_CUT");
      uint32_t m=R32(A_MARIO_OBJECT);
      bv(A_MARIO_STATES+M_POS_X,5900,51,3380,"movement");bv(m+O_POS_X,5900,51,3380,"collision");bv(m+GFX_POS_X,5900,51,3380,"storedGraphics");
      bw32(A_MARIO_STATES+M_ACTION,0x0c400201,"idle");bw16(A_MARIO_STATES+0x18,0,"actionState");bw16(A_MARIO_STATES+0x1a,0,"actionTimer");
      bf(A_MARIO_STATES+M_FORWARD_VEL,0,"forward");bv(A_MARIO_STATES+M_VEL_X,0,0,0,"velocity");
      bw16(A_MARIO_STATES+0x2c,0,"facePitch");bw16(A_MARIO_STATES+0x2e,0,"faceYaw");bw16(A_MARIO_STATES+0x30,0,"faceRoll");
      buddy_log("BUDDY_AFTER_CUT");
    }
    memset(keys,0,sizeof(*keys));
    if(step==0)keys->B_BUTTON=1;
    buddy_log("BUDDY_OBSERVE");
    if(!retargeted&&R32(A_MARIO_STATES+M_ACTION)==0x00000383&&R32(A_MARIO_STATES+M_USED_OBJ)==SMALL_BOX){
      if(BUDDY_MODE!=3)bw32(A_MARIO_STATES+M_USED_OBJ,BUDDY,"conditionalUsedObjRetarget");
      retargeted=1;
    }
    if(retargeted&&!released&&R32(A_MARIO_STATES+M_ACTION)==0x08000207){
      if(BUDDY_MODE==2)keys->B_BUTTON=1;else keys->Z_TRIG=1;
      released=1;
    }
    fprintf(stderr,"BUDDY_INPUT,step=%d,A=%d,B=%d,Z=%d,x=%d,y=%d\n",step,keys->A_BUTTON,keys->B_BUTTON,keys->Z_TRIG,keys->X_AXIS,keys->Y_AXIS);
    ++step;
}
