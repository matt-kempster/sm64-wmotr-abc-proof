/* Visualization ONLY. Controller prefix is original; these screenshots then
 * substitute render positions/camera, never a controller-produced candidate. */
#define SEARCH_MODE 12
#define GetKeys clean_get_keys
#define PluginStartup clean_plugin_startup
#include "../jp-clean-gap-search/jp_clean_gap_search_probe.c"
#undef PluginStartup
#undef GetKeys
#include <mupen64plus/m64p_frontend.h>

#ifndef VIEW_CUTAWAY
#define VIEW_CUTAWAY 0
#endif

enum { VIEW_CAMERA = 0x802876d0, VIEW_LAKITU = 0x8033b328 };
static void (*view_write)(unsigned int, unsigned int);
static m64p_error (*view_command)(m64p_command, int, void *);
static int view_armed, view_active, view_index;
static uint32_t view_mario, view_mario_saved[4], view_top_saved[7];
static uint32_t view_camera_saved[6], view_snapshots[2][5];
static const float view_positions[3][3] = {
    {-1950.0f,1741.0f,-939.0f}, {-1882.0f,1741.0f,-939.0f},
    {-1882.0f,768.0f,-939.0f}
};

static void view_float(uint32_t address, float value) {
    uint32_t bits;
    memcpy(&bits, &value, sizeof(bits));
    view_write(address, bits);
}
static void view_vec(uint32_t address, const float *v) {
    for (int axis=0; axis<3; ++axis) view_float(address+axis*4,v[axis]);
}
static void view_restore(void) {
    if (!view_active) return;
    for (int axis=0; axis<3; ++axis) {
        view_write(view_mario+GFX_POS_X+axis*4,view_mario_saved[axis]);
        view_write(gTop+GFX_POS_X+axis*4,view_top_saved[axis]);
    }
    view_write(view_mario+0x50,view_mario_saved[3]);
    view_write(gTop+0x18,view_top_saved[3]);
    view_write(gTop+0x1c,view_top_saved[4]);
    view_write(gTop+0x50,view_top_saved[5]);
    view_write(gTop,view_top_saved[6]);
    for (int word=0; word<6; ++word)
        view_write(VIEW_LAKITU+0x80+word*4,view_camera_saved[word]);
    view_active=0;
}

static void view_update(unsigned int pc) {
    if (pc != VIEW_CAMERA) { debugger_update_callback(pc); return; }
    if (gTop && R32(gTop+O_ACTION)==1 && R16(A_CURR_AREA)==1) {
        uint32_t timer=R32(gTop+O_TIMER);
        /* Object timer increments after its behavior. After-behavior131
         * therefore renders the source timer130 pose. */
        if (timer == 131 || timer == 132) {
            int snapshot=timer-131;
            for (int axis=0; axis<3; ++axis)
                view_snapshots[snapshot][axis]=R32(gTop+GFX_POS_X+axis*4);
            view_snapshots[snapshot][3]=R32(gTop+0x18);
            view_snapshots[snapshot][4]=R32(gTop+0x1c);
        }
        /* Each pose lasts three render callbacks. Request on the third:
         * Rice captures the preceding completed framebuffer, which already
         * has this SAME held pose. The initial one-frame experiment exposed
         * that capture latency and is not the final screenshot receipt. */
        if (timer >= 133 && timer <= 150) {
            int index=(timer-133)/3;
            int phase=index%2, pose=index/2;
            view_mario=R32(A_MARIO_OBJECT);
            for (int axis=0; axis<3; ++axis) {
                view_mario_saved[axis]=R32(view_mario+GFX_POS_X+axis*4);
                view_top_saved[axis]=R32(gTop+GFX_POS_X+axis*4);
            }
            view_mario_saved[3]=R32(view_mario+0x50);
            view_top_saved[3]=R32(gTop+0x18);
            view_top_saved[4]=R32(gTop+0x1c);
            view_top_saved[5]=R32(gTop+0x50);
            view_top_saved[6]=R32(gTop);
            for (int word=0; word<6; ++word)
                view_camera_saved[word]=R32(VIEW_LAKITU+0x80+word*4);
            view_vec(view_mario+GFX_POS_X,view_positions[pose]);
            view_write(view_mario+0x50,0);
            for (int axis=0; axis<3; ++axis)
                view_write(gTop+GFX_POS_X+axis*4,view_snapshots[phase][axis]);
            view_write(gTop+0x18,view_snapshots[phase][3]);
            view_write(gTop+0x1c,view_snapshots[phase][4]);
            view_write(gTop+0x50,0);
#if VIEW_CUTAWAY
            /* Diagnostic cutaway: hide ONLY the top's render node. All
             * collision/movement state remains native and unchanged. */
            view_write(gTop,view_top_saved[6] | 0x10);
#endif
            {
#if VIEW_CUTAWAY
                const float focus_high[3]={-1950.0f,1650.0f,-939.0f};
                const float camera_high[3]={-1450.0f,2150.0f,-800.0f};
                const float focus_low[3]={-1940.0f,850.0f,-939.0f};
                const float camera_low[3]={-1700.0f,1000.0f,-1100.0f};
                const float *focus=pose==2 ? focus_low : focus_high;
                const float *camera=pose==2 ? camera_low : camera_high;
#else
                const float focus[3]={-2048.0f,1350.0f,-1024.0f};
                const float camera[3]={-500.0f,2450.0f,-1000.0f};
#endif
                view_vec(VIEW_LAKITU+0x80,focus);
                view_vec(VIEW_LAKITU+0x8c,camera);
            }
            view_active=1;
            fprintf(stderr,"CANDIDATE_RENDER,index=%d,phase=%d,pose=%d,globalTimer=%u,afterBehaviorTimer=%u,renderMario=(%.9g,%.9g,%.9g),nativeState=(%.9g,%.9g,%.9g),renderTop=(%.9g,%.9g,%.9g),topYaw=%u,visualizationOnly=1,cutaway=%d\n",
                index,130+phase,pose,R32(A_GLOBAL_TIMER),timer,
                rfloat(view_mario+GFX_POS_X),rfloat(view_mario+GFX_POS_Y),rfloat(view_mario+GFX_POS_Z),
                rfloat(A_MARIO_STATES+M_POS_X),rfloat(A_MARIO_STATES+M_POS_Y),rfloat(A_MARIO_STATES+M_POS_Z),
                rfloat(gTop+GFX_POS_X),rfloat(gTop+GFX_POS_Y),rfloat(gTop+GFX_POS_Z),R16(gTop+0x1c),VIEW_CUTAWAY);
            if ((timer-133)%3==2) {
                fprintf(stderr,"CANDIDATE_VIEW,index=%d,phase=%d,pose=%d,requestTimer=%u,previousRenderedTimer=%u,heldThreeFrames=1,cutaway=%d\n",
                    index,130+phase,pose,R32(A_GLOBAL_TIMER),R32(A_GLOBAL_TIMER)-1,VIEW_CUTAWAY);
                view_command(M64CMD_TAKE_NEXT_SCREENSHOT,0,NULL);
                ++view_index;
            }
        }
    }
    resume_from_breakpoint();
}

EXPORT m64p_error CALL PluginStartup(m64p_dynlib_handle core, void *context,
    void (*callback)(void *, int, const char *)) {
    m64p_error result=clean_plugin_startup(core,context,callback);
    if (result!=M64ERR_SUCCESS) return result;
    view_write=dlsym(core,"DebugMemWrite32");
    view_command=dlsym(core,"CoreDoCommand");
    return view_write && view_command ? M64ERR_SUCCESS : M64ERR_INCOMPATIBLE;
}

EXPORT void CALL GetKeys(int control, BUTTONS *keys) {
    view_restore();
    clean_get_keys(control,keys);
    if (control || !gTop || R16(A_CURR_AREA)!=1) return;
    if (R32(gTop+O_PYRAMID_PILLARS_TOUCHED)==4) {
        memset(keys,0,sizeof(*keys));
        if (!view_armed) {
            if (DSetCallbacks(debugger_init_callback,view_update,debugger_vi_callback)
                !=M64ERR_SUCCESS || !add_exec_breakpoint(VIEW_CAMERA)) {
                fprintf(stderr,"CANDIDATE_VIEW_ERROR,arm\n");
                return;
            }
            view_armed=1;
        }
    }
}
