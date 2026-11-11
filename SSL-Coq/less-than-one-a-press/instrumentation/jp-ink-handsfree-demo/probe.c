/* Three separate original-JP executions: controller-only low component;
 * one position-only high hands-free cut; supplied-crawl/position handoff.
 * All use the stock camera. Never join their histories into one route. */
#define SEARCH_MODE 12
#define GetKeys clean_get_keys
#define PluginStartup clean_plugin_startup
#include "../jp-clean-gap-search/jp_clean_gap_search_probe.c"
#undef PluginStartup
#undef GetKeys
#include <mupen64plus/m64p_frontend.h>
#ifndef DEMO_HANDOFF
#define DEMO_HANDOFF 0
#endif
#ifndef DEMO_CLEAN
#define DEMO_CLEAN 0
#endif
#if !DEMO_HANDOFF
#include <controls.h>
#endif
#if DEMO_CLEAN
#define DEMO_LAST_FRAME ((int)(sizeof(demo_pads)/sizeof(demo_pads[0])))
#else
#define DEMO_LAST_FRAME 148
#endif

enum { DEMO_CAMERA = 0x802876d0, DEMO_BOX = A_OBJECT_POOL+(DEMO_CLEAN?47:49)*OBJECT_SIZE };
static void (*demo_write)(unsigned int, unsigned int);
static m64p_error (*demo_command)(m64p_command, int, void *);
static int demo_armed, demo_started, demo_step, demo_cut, demo_shots;

static void demo_log(const char *tag) {
    uint32_t mario=R32(A_MARIO_OBJECT), floor=R32(A_MARIO_STATES+M_FLOOR);
    fprintf(stderr,"%s,step=%d,timer=%u,poll=%llu,area=%u,topTimer=%u,topAction=%u,action=%08x,held=%08x,box=%08x,boxHeld=%u,boxActive=%u,input=%u,platform=%08x,floorOwner=%08x,floorY=%.9g,state=(%.9g,%.9g,%.9g),collision=(%.9g,%.9g,%.9g),display=(%.9g,%.9g,%.9g),boxXYZ=(%.9g,%.9g,%.9g)\n",
        tag,demo_step,R32(A_GLOBAL_TIMER),(unsigned long long)gPoll,R16(A_CURR_AREA),
        R32(gTop+O_TIMER),R32(gTop+O_ACTION),R32(A_MARIO_STATES+M_ACTION),
        R32(A_MARIO_STATES+M_HELD_OBJ),DEMO_BOX,R32(DEMO_BOX+0x124),R16(DEMO_BOX+O_ACTIVE_FLAGS),
        R16(A_MARIO_STATES+M_INPUT),R32(A_MARIO_PLATFORM),floor?R32(floor+0x2c):0,
        rfloat(A_MARIO_STATES+M_FLOOR_HEIGHT),
        rfloat(A_MARIO_STATES+M_POS_X),rfloat(A_MARIO_STATES+M_POS_Y),rfloat(A_MARIO_STATES+M_POS_Z),
        rfloat(mario+O_POS_X),rfloat(mario+O_POS_Y),rfloat(mario+O_POS_Z),
        rfloat(mario+GFX_POS_X),rfloat(mario+GFX_POS_Y),rfloat(mario+GFX_POS_Z),
        rfloat(DEMO_BOX+O_POS_X),rfloat(DEMO_BOX+O_POS_Y),rfloat(DEMO_BOX+O_POS_Z));
}
#if !DEMO_CLEAN
static void demo_vec(uint32_t address, const float value[3]) {
    for (int axis=0;axis<3;++axis) {
        uint32_t bits; memcpy(&bits,value+axis,4);
        fprintf(stderr,"HANDS_WRITE,step=%d,address=%08x,before=%08x,after=%08x\n",demo_step,address+4*axis,R32(address+4*axis),bits);
        demo_write(address+4*axis,bits);
    }
}
#endif
static void demo_update(unsigned int pc) {
    if (pc!=DEMO_CAMERA) { debugger_update_callback(pc);return; }
    if (demo_started && demo_step<=DEMO_LAST_FRAME) {
        demo_log("HANDS_RENDER");
        fprintf(stderr,"HANDS_SCREENSHOT,index=%d,requestTimer=%u,previousFramebuffer=1\n",demo_shots++,R32(A_GLOBAL_TIMER));
        demo_command(M64CMD_TAKE_NEXT_SCREENSHOT,0,NULL);
    }
    resume_from_breakpoint();
}
EXPORT m64p_error CALL PluginStartup(m64p_dynlib_handle core,void *context,
        void (*callback)(void *,int,const char *)) {
    m64p_error result=clean_plugin_startup(core,context,callback);
    if (result!=M64ERR_SUCCESS)return result;
    demo_write=dlsym(core,"DebugMemWrite32");demo_command=dlsym(core,"CoreDoCommand");
    return demo_write&&demo_command?M64ERR_SUCCESS:M64ERR_INCOMPATIBLE;
}
EXPORT void CALL GetKeys(int control,BUTTONS *keys) {
    clean_get_keys(control,keys);
#if DEMO_CLEAN
    if(control)return;
    (void)demo_cut;
    memset(keys,0,sizeof(*keys));
    demo_step=(int)gPoll;
    if(gPoll<=sizeof(demo_pads)/sizeof(demo_pads[0])) {
        unsigned b=demo_pads[gPoll-1].buttons;
        keys->X_AXIS=demo_pads[gPoll-1].x;keys->Y_AXIS=demo_pads[gPoll-1].y;
        keys->A_BUTTON=!!(b&0x8000);keys->B_BUTTON=!!(b&0x4000);keys->Z_TRIG=!!(b&0x2000);
        keys->START_BUTTON=!!(b&0x1000);keys->U_DPAD=!!(b&0x0800);keys->D_DPAD=!!(b&0x0400);
        keys->L_DPAD=!!(b&0x0200);keys->R_DPAD=!!(b&0x0100);keys->L_TRIG=!!(b&0x0020);keys->R_TRIG=!!(b&0x0010);
        keys->U_CBUTTON=!!(b&8);keys->D_CBUTTON=!!(b&4);keys->L_CBUTTON=!!(b&2);keys->R_CBUTTON=!!(b&1);
        fprintf(stderr,"HANDS_INPUT,step=%d,buttons=%u,x=%d,y=%d,A=%u\n",demo_step,b,keys->X_AXIS,keys->Y_AXIS,keys->A_BUTTON);
    }
    if(gPoll==350) {
        if(DSetCallbacks(debugger_init_callback,demo_update,debugger_vi_callback)!=M64ERR_SUCCESS
                ||!add_exec_breakpoint(DEMO_CAMERA)) {fprintf(stderr,"HANDS_ERROR,arm\n");return;}
        demo_armed=demo_started=1;demo_log("HANDS_CLEAN_START");
    }
#elif DEMO_HANDOFF
    if(control||!gTop)return;
    if(!demo_started && (R16(A_CURR_AREA)!=1||R32(gTop+O_PYRAMID_PILLARS_TOUCHED)!=4))return;
    memset(keys,0,sizeof(*keys));
    if(!demo_armed) {
        if(DSetCallbacks(debugger_init_callback,demo_update,debugger_vi_callback)!=M64ERR_SUCCESS
                ||!add_exec_breakpoint(DEMO_CAMERA)) {fprintf(stderr,"HANDS_ERROR,arm\n");return;}
        demo_armed=1;
    }
    if(!demo_started) {
        if(R32(gTop+O_ACTION)!=1||R32(gTop+O_TIMER)!=125)return;
        demo_started=1;demo_log("HANDS_HANDOFF_START");
    }
    if(demo_step==4) {
        uint32_t address=A_MARIO_STATES+M_ACTION;
        fprintf(stderr,"HANDS_WRITE,step=%d,address=%08x,before=%08x,after=04008448,field=action\n",demo_step,address,R32(address));
        demo_write(address,0x04008448);
        keys->Z_TRIG=1;keys->Y_AXIS=64;
        demo_log("HANDS_SUPPLIED_CRAWL");
    }
    if(demo_step==5&&!demo_cut) {
        uint32_t mario=R32(A_MARIO_OBJECT);
        const float mario_xyz[3]={-1950,1741,-939},box_xyz[3]={-1989,1741,-939};
        demo_log("HANDS_BEFORE_CUT");
        if(R32(A_MARIO_STATES+M_ACTION)!=0x04008448||rfloat(mario+0x1fc)!=100.0f
                ||R32(A_MARIO_STATES+M_HELD_OBJ)!=0||R32(DEMO_BOX+0x124)!=0) {
            fprintf(stderr,"HANDS_ERROR,expected-native-short-crawl-and-free-box\n");return;
        }
        fprintf(stderr,"HANDS_HITBOX,height=%.9g\n",rfloat(mario+0x1fc));
        demo_vec(A_MARIO_STATES+M_POS_X,mario_xyz);demo_vec(mario+O_POS_X,mario_xyz);
        demo_vec(mario+GFX_POS_X,mario_xyz);demo_vec(DEMO_BOX+O_POS_X,box_xyz);
        demo_cut=1;demo_log("HANDS_AFTER_CUT");
        keys->Z_TRIG=1;keys->Y_AXIS=64;
    }
    fprintf(stderr,"HANDS_INPUT,step=%d,buttons=%u,x=%d,y=%d,A=0\n",demo_step,keys->Z_TRIG?8192:0,keys->X_AXIS,keys->Y_AXIS);
    ++demo_step;
#else
    if(control||!gTop||R16(A_CURR_AREA)!=1)return;
    if(R32(gTop+O_PYRAMID_PILLARS_TOUCHED)!=4)return;
    memset(keys,0,sizeof(*keys));
    if(!demo_armed) {
        if(DSetCallbacks(debugger_init_callback,demo_update,debugger_vi_callback)!=M64ERR_SUCCESS
                ||!add_exec_breakpoint(DEMO_CAMERA)) {fprintf(stderr,"HANDS_ERROR,arm\n");return;}
        demo_armed=1;
    }
    if(!demo_started) {
        if(R32(gTop+O_ACTION)!=1||R32(gTop+O_TIMER)!=0)return;
        demo_started=1;demo_log("HANDS_START");
    }
    if(demo_step==6&&!demo_cut) {
        demo_log("HANDS_BEFORE_CUT");
        if(R32(A_MARIO_STATES+M_ACTION)!=ACT_DIVE||R32(A_MARIO_STATES+M_HELD_OBJ)!=0) {
            fprintf(stderr,"HANDS_ERROR,expected-native-unheld-dive\n");return;
        }
        const float mario_xyz[3]={-2559,1741,-1535},box_xyz[3]={-2559,1741,-1465};
        demo_vec(A_MARIO_STATES+M_POS_X,mario_xyz);
        demo_vec(R32(A_MARIO_OBJECT)+O_POS_X,mario_xyz);
        demo_vec(R32(A_MARIO_OBJECT)+GFX_POS_X,mario_xyz);
        demo_vec(DEMO_BOX+O_POS_X,box_xyz);
        demo_cut=1;demo_log("HANDS_AFTER_CUT");
    }
    if(demo_step<146) {
        keys->X_AXIS=demo_pads[demo_step].x;keys->Y_AXIS=demo_pads[demo_step].y;
        keys->B_BUTTON=!!(demo_pads[demo_step].buttons&0x4000);
        keys->Z_TRIG=!!(demo_pads[demo_step].buttons&0x2000);
        fprintf(stderr,"HANDS_INPUT,step=%d,buttons=%u,x=%d,y=%d,A=0\n",demo_step,demo_pads[demo_step].buttons,keys->X_AXIS,keys->Y_AXIS);
    }
    ++demo_step;
#endif
}
