/* Original JP: supplied crawl and synchronized Y1400 positions; native
 * box push creates a632 gap, then the raised retry selects the static roof.
 * Optional side camera changes only six render-time Lakitu words and restores
 * them before the next input. This is not a controller-produced starting pose.
 * Derived from jp-ink-handsfree-demo/probe.c; unused variants retained below. */
#define SEARCH_MODE 12
#define GetKeys clean_get_keys
#define PluginStartup clean_plugin_startup
#include "../jp-clean-gap-search/jp_clean_gap_search_probe.c"
#undef PluginStartup
#undef GetKeys
#include <mupen64plus/m64p_frontend.h>
#define DEMO_HANDOFF 1
#ifndef DEMO_SIDE
#define DEMO_SIDE 0
#endif
#ifndef DEMO_DISPLAY
#define DEMO_DISPLAY 0
#endif
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
static int demo_camera_active;
static uint32_t demo_camera_saved[6];
static int demo_graphics_active;
static uint32_t demo_graphics_saved[8],demo_graphics_mario;

static void demo_restore_camera(void) {
    if (demo_graphics_active) {
        for (int i=0;i<3;++i) {
            demo_write(demo_graphics_mario+GFX_POS_X+4*i,demo_graphics_saved[i]);
            demo_write(DEMO_BOX+GFX_POS_X+4*i,demo_graphics_saved[i+4]);
        }
        /* The native renderer clears throwMatrix after drawing (rendering_graph_node.c854).
         * Restore that post-render state, not the nonnull pre-render floor matrix.
         * The stock replay independently verifies every logged matrix value. */
        demo_write(demo_graphics_mario+0x50,0);
        demo_write(DEMO_BOX+0x50,0);
        demo_graphics_active=0;
    }
    if (!demo_camera_active) return;
    for (int i=0;i<6;++i) demo_write(0x8033b328+0x80+4*i,demo_camera_saved[i]);
    demo_camera_active=0;
}

static void demo_side_camera(void) {
    if (!DEMO_SIDE || !demo_started || demo_step<5 || R16(A_CURR_AREA)!=1) return;
    const float camera_words[6]={-2100,1430,-1024,-2850,1435,-1250};
    for (int i=0;i<6;++i) {
        uint32_t bits; memcpy(&bits,camera_words+i,4);
        demo_camera_saved[i]=R32(0x8033b328+0x80+4*i);
        demo_write(0x8033b328+0x80+4*i,bits);
    }
    demo_camera_active=1;
    fprintf(stderr,"HANDS_CAMERA,step=%d,renderWords=6,restoredBeforeNextInput=1,focus=(-2100,1430,-1024),eye=(-2850,1435,-1250)\n",demo_step);
    if (DEMO_DISPLAY && (demo_step==5 || demo_step==6)) {
        demo_graphics_mario=R32(A_MARIO_OBJECT);
        for (int i=0;i<3;++i) {
            demo_graphics_saved[i]=R32(demo_graphics_mario+GFX_POS_X+4*i);
            demo_graphics_saved[i+4]=R32(DEMO_BOX+GFX_POS_X+4*i);
        }
        demo_graphics_saved[3]=R32(demo_graphics_mario+0x50);
        demo_graphics_saved[7]=R32(DEMO_BOX+0x50);
        demo_write(demo_graphics_mario+0x50,0);
        if (demo_step==5) {
            const float mario_xyz[3]={-2132,1400,-1024},box_xyz[3]={-2093,1400,-1024};
            for (int i=0;i<3;++i) {
                uint32_t bits;memcpy(&bits,mario_xyz+i,4);demo_write(demo_graphics_mario+GFX_POS_X+4*i,bits);
                memcpy(&bits,box_xyz+i,4);demo_write(DEMO_BOX+GFX_POS_X+4*i,bits);
            }
            demo_write(DEMO_BOX+0x50,0);
        }
        demo_graphics_active=1;
        fprintf(stderr,"HANDS_ILLUSTRATION,step=%d,renderOnly=1,pose=%s,marioXYZ=(%.9g,%.9g,%.9g),boxXYZ=(%.9g,%.9g,%.9g),marioMatrixCleared=1,boxMatrixCleared=%d,restoredBeforeNextInput=1\n",
            demo_step,demo_step==5?"supplied-starting-coordinates":"stored-display-coordinates",
            rfloat(demo_graphics_mario+GFX_POS_X),rfloat(demo_graphics_mario+GFX_POS_Y),rfloat(demo_graphics_mario+GFX_POS_Z),
            rfloat(DEMO_BOX+GFX_POS_X),rfloat(DEMO_BOX+GFX_POS_Y),rfloat(DEMO_BOX+GFX_POS_Z),demo_step==5);
    }
}

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
    fprintf(stderr,"HANDS_EXTRA,step=%d,tag=%s,depth=%.9g,hitbox=%.9g,forward=%.9g,yaw=%d,velocity=(%.9g,%.9g,%.9g),floor=%08x,used=%08x,boxForward=%.9g,boxVelocity=(%.9g,%.9g,%.9g)\n",
        demo_step,tag,rfloat(A_MARIO_STATES+M_QUICKSAND_DEPTH),rfloat(mario+0x1fc),
        rfloat(A_MARIO_STATES+0x54),(int16_t)R16(A_MARIO_STATES+M_FACE_YAW),
        rfloat(A_MARIO_STATES+M_VEL_X),rfloat(A_MARIO_STATES+M_VEL_Y),rfloat(A_MARIO_STATES+M_VEL_Z),
        floor,R32(A_MARIO_STATES+0x80),rfloat(DEMO_BOX+0xb8),
        rfloat(DEMO_BOX+0xac),rfloat(DEMO_BOX+0xb0),rfloat(DEMO_BOX+0xb4));
    uint32_t matrix=R32(mario+0x50);
    fprintf(stderr,"HANDS_MATRIX,step=%d,tag=%s,pointer=%08x,translation=(%.9g,%.9g,%.9g)\n",
        demo_step,tag,matrix,matrix?rfloat(matrix+48):0,matrix?rfloat(matrix+52):0,matrix?rfloat(matrix+56):0);
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
        demo_side_camera();
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
    demo_restore_camera();
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
        const float mario_xyz[3]={-2132,1400,-1024},box_xyz[3]={-2093,1400,-1024};
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
