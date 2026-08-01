#define _GNU_SOURCE
#define M64P_PLUGIN_PROTOTYPES

#include <mupen64plus/m64p_common.h>
#include <mupen64plus/m64p_debugger.h>
#include <mupen64plus/m64p_plugin.h>

#include <dlfcn.h>
#include <math.h>
#include <stdint.h>
#include <stdio.h>
#include <string.h>

#ifndef ALLOW_SETUP_A
#define ALLOW_SETUP_A 0
#endif

#ifndef SEARCH_MODE
#define SEARCH_MODE 0
#endif

/* Authenticated original-JP virtual addresses.  run.sh hash-gates the ROM. */
enum {
    A_GLOBAL_TIMER = 0x8032c694,
    A_MARIO_PLATFORM = 0x8032fed4,
    A_MARIO_STATES = 0x80339e00,
    A_CURR_AREA = 0x8033a75a,
    A_OBJECT_POOL = 0x8033c118,
    A_MARIO_OBJECT = 0x8035fde8,
};

enum {
    OBJECT_SIZE = 0x260,
    OBJECT_COUNT = 240,
    O_PREV_OBJ = 0x06c,
    GFX_POS_X = 0x020,
    GFX_POS_Y = 0x024,
    GFX_POS_Z = 0x028,
    O_ACTIVE_FLAGS = 0x074,
    O_FLAGS = 0x08c,
    O_POS_X = 0x0a0,
    O_POS_Y = 0x0a4,
    O_POS_Z = 0x0a8,
    O_GRAPH_Y_OFFSET = 0x0dc,
    O_ACTIVE_PARTICLE_FLAGS = 0x0e0,
    O_MARIO_PARTICLE_FLAGS = 0x0f4,
    O_PYRAMID_PILLARS_TOUCHED = 0x0f4,
    O_INTERACT_TYPE = 0x130,
    O_ACTION = 0x14c,
    O_TIMER = 0x154,
    O_BHV_PARAMS = 0x188,
};

enum {
    M_INPUT = 0x02,
    M_ACTION = 0x0c,
    M_POS_X = 0x3c,
    M_POS_Y = 0x40,
    M_POS_Z = 0x44,
    M_VEL_X = 0x48,
    M_VEL_Y = 0x4c,
    M_VEL_Z = 0x50,
    M_FORWARD_VEL = 0x54,
    M_FLOOR = 0x68,
    M_FLOOR_HEIGHT = 0x70,
    M_HELD_OBJ = 0x7c,
    M_USED_OBJ = 0x80,
    M_AREA = 0x90,
    M_QUICKSAND_DEPTH = 0xc0,
    AREA_CAMERA = 0x24,
    CAMERA_YAW = 0x02,
};

enum {
    INPUT_A_PRESSED = 0x0002,
    INPUT_A_DOWN = 0x0080,
    ACT_DISAPPEARED = 0x00001300,
    ACT_RIDING_SHELL_GROUND = 0x20810446,
    ACT_RIDING_SHELL_JUMP = 0x0281089a,
    ACT_RIDING_SHELL_FALL = 0x0081089b,
    ACT_WALKING = 0x04000440,
    ACT_DIVE_SLIDE = 0x00880456,
    ACT_STOMACH_SLIDE = 0x008c0453,
    ACT_CRAZY_BOX_BOUNCE = 0x000008ae,
    ACT_TWIRLING = 0x108008a4,
    ACT_TORNADO_TWIRLING = 0x10020372,
    INTERACT_KOOPA_SHELL = 0x00080000,
    ACTIVE_PARTICLE_FIRE = 0x00000800,
};

typedef unsigned int (*read32_fn)(unsigned int);
typedef unsigned short (*read16_fn)(unsigned int);

static read32_fn R32;
static read16_fn R16;
static uint64_t gPoll;
static uint32_t gTop;
static uint32_t gUpperWarp;
static uint32_t gShellBox;
static uint32_t gShell;
static uint32_t gJumpingBox;
static int gLastPillars = -1;
static int gLastTopAction = -1;
static int gLastTopTimer = -1;
static int gArea1Frames;
static int gGapSamples;
static int gGap45;
static int gGap960;
static int gWarpDisappeared;
static int gWarpUsedObj;
static int gPlatformTop;
static int gSawShell;
static int gRodeShell;
static int gBPressedFrames;
static int gTravelStage;
static int gUsedTornado;
static int gTornadoCaptures;
static uint32_t gLastMovementB;
static uint32_t gLastAction = UINT32_MAX;
static float gMaxStateY = -INFINITY;
static uint32_t gMaxStateYTimer;
static uint32_t gMaxStateYAction;
static float gMaxStateYX;
static float gMaxStateYZ;
static int gAPressedFrames;
static int gADownFrames;
static int gControllerAFrames;
static int gFireFrames;
static int gSawFirePrevObj;
static int gSawFireParticle;
static float gMaxMarioGraphYOffset = -INFINITY;
static float gMaxGfxMinusObjectY = -INFINITY;
static float gMinGfxMinusObjectY = INFINITY;
static float gMaxStateMinusObjectY = -INFINITY;
static float gMaxGfxMinusStateY = -INFINITY;
static uint32_t gMaxGapTimer;
static uint32_t gMaxGapAction;
static float gMaxGapStateY;
static float gMaxGapObjectY;
static float gMaxGapGraphicsY;

static float rfloat(uint32_t address) {
    union { float f; uint32_t u; } bits;
    bits.u = R32(address);
    return bits.f;
}

static uint32_t pool_pointer(unsigned index) {
    return A_OBJECT_POOL + index * OBJECT_SIZE;
}

static int closef(float a, float b, float epsilon) {
    return fabsf(a - b) < epsilon;
}

static void find_area1_objects(void) {
    unsigned i;

    for (i = 0; i < OBJECT_COUNT; i++) {
        uint32_t object = pool_pointer(i);
        if (R16(object + O_ACTIVE_FLAGS) == 0) continue;
        if (closef(rfloat(object + O_POS_X), -2047.0f, 0.5f)
            && closef(rfloat(object + O_POS_Z), -1023.0f, 0.5f)
            && rfloat(object + O_POS_Y) >= 1535.0f) {
            gTop = object;
        }
        if (rfloat(object + O_POS_X) == -2048.0f
            && rfloat(object + O_POS_Y) == 768.0f
            && rfloat(object + O_POS_Z) == -1024.0f
            && ((R32(object + O_BHV_PARAMS) >> 16) & 0xff) == 0x1e) {
            gUpperWarp = object;
        }
        if (closef(rfloat(object + O_POS_X), 5840.0f, 1.0f)
            && closef(rfloat(object + O_POS_Z), 2500.0f, 1.0f)
            && ((R32(object + O_BHV_PARAMS) >> 16) & 0xff) == 3) {
            gShellBox = object;
        }
        if (R32(object + O_INTERACT_TYPE) == INTERACT_KOOPA_SHELL) {
            gShell = object;
            gSawShell = 1;
        }
        if (closef(rfloat(object + O_POS_X), 1120.0f, 1.0f)
            && closef(rfloat(object + O_POS_Z), 6480.0f, 1.0f)
            && R32(object + O_INTERACT_TYPE) != 0) {
            gJumpingBox = object;
        }
    }
}

static int clamp_axis(int value) {
    if (value < -127) return -127;
    if (value > 127) return 127;
    return value;
}

static void steer_world(BUTTONS *keys, float target_x, float target_z,
                        float magnitude) {
    uint32_t area = R32(A_MARIO_STATES + M_AREA);
    uint32_t camera = area == 0 ? 0 : R32(area + AREA_CAMERA);
    int16_t camera_yaw = camera == 0 ? 0 : (int16_t) R16(camera + CAMERA_YAW);
    float x = rfloat(A_MARIO_STATES + M_POS_X);
    float z = rfloat(A_MARIO_STATES + M_POS_Z);
    float dx = target_x - x;
    float dz = target_z - z;
    float distance = sqrtf(dx * dx + dz * dz);
    float desired = atan2f(dx, dz);
    float camera_radians = (float) camera_yaw
        * (2.0f * 3.14159265358979323846f / 65536.0f);
    float controller_angle = desired - camera_radians;

    if (magnitude > distance * 2.0f) magnitude = distance * 2.0f;
    keys->X_AXIS = (int8_t) clamp_axis(
        (int) lrintf(sinf(controller_angle) * magnitude));
    keys->Y_AXIS = (int8_t) clamp_axis(
        (int) lrintf(-cosf(controller_angle) * magnitude));
}

static void observe_gap(void) {
    uint32_t mario_object = R32(A_MARIO_OBJECT);
    float state_y;
    float object_y;
    float graphics_y;
    float gfx_object;
    float state_object;
    float gfx_state;
    float graph_y_offset;
    uint32_t prev_obj;
    uint32_t active_particle_flags;
    uint32_t mario_particle_flags;

    if (mario_object == 0 || R16(A_CURR_AREA) != 1) return;
    state_y = rfloat(A_MARIO_STATES + M_POS_Y);
    object_y = rfloat(mario_object + O_POS_Y);
    graphics_y = rfloat(mario_object + GFX_POS_Y);
    if (!isfinite(state_y) || !isfinite(object_y) || !isfinite(graphics_y)) {
        fprintf(stderr,
                "NONFINITE,timer=%u,stateBits=%08x,objectBits=%08x,gfxBits=%08x\n",
                R32(A_GLOBAL_TIMER), R32(A_MARIO_STATES + M_POS_Y),
                R32(mario_object + O_POS_Y), R32(mario_object + GFX_POS_Y));
        return;
    }
    gfx_object = graphics_y - object_y;
    state_object = state_y - object_y;
    gfx_state = graphics_y - state_y;
    graph_y_offset = rfloat(mario_object + O_GRAPH_Y_OFFSET);
    prev_obj = R32(mario_object + O_PREV_OBJ);
    active_particle_flags = R32(mario_object + O_ACTIVE_PARTICLE_FLAGS);
    mario_particle_flags = R32(mario_object + O_MARIO_PARTICLE_FLAGS);
    gGapSamples++;
    if (graph_y_offset > gMaxMarioGraphYOffset) {
        gMaxMarioGraphYOffset = graph_y_offset;
    }
    if (prev_obj != 0
        || ((active_particle_flags | mario_particle_flags)
            & ACTIVE_PARTICLE_FIRE) != 0) {
        gFireFrames++;
        if (prev_obj != 0 && !gSawFirePrevObj) {
            gSawFirePrevObj = 1;
            fprintf(stderr,
                    "FIRE_LINK,timer=%u,prevObj=%08x,activeParticleFlags=%08x,"
                    "marioParticleFlags=%08x,"
                    "action=%08x,gfxMinusObjectY=%.9g,oFlags=%08x,"
                    "oGraphYOffset=%.9g\n",
                    R32(A_GLOBAL_TIMER), prev_obj, active_particle_flags,
                    mario_particle_flags,
                    R32(A_MARIO_STATES + M_ACTION), gfx_object,
                    R32(mario_object + O_FLAGS), graph_y_offset);
        }
        if (((active_particle_flags | mario_particle_flags)
             & ACTIVE_PARTICLE_FIRE) != 0) {
            gSawFireParticle = 1;
        }
    }
    if (state_y > gMaxStateY) {
        gMaxStateY = state_y;
        gMaxStateYTimer = R32(A_GLOBAL_TIMER);
        gMaxStateYAction = R32(A_MARIO_STATES + M_ACTION);
        gMaxStateYX = rfloat(A_MARIO_STATES + M_POS_X);
        gMaxStateYZ = rfloat(A_MARIO_STATES + M_POS_Z);
    }
    if (R32(A_MARIO_STATES + M_ACTION) != gLastAction) {
        gLastAction = R32(A_MARIO_STATES + M_ACTION);
        if (gLastAction == ACT_TORNADO_TWIRLING) gTornadoCaptures++;
        fprintf(stderr,
                "ACTION,timer=%u,action=%08x,state=(%.9g,%.9g,%.9g),"
                "heldObj=%08x,usedObj=%08x,forwardVel=%.9g\n",
                R32(A_GLOBAL_TIMER), gLastAction,
                rfloat(A_MARIO_STATES + M_POS_X), state_y,
                rfloat(A_MARIO_STATES + M_POS_Z),
                R32(A_MARIO_STATES + M_HELD_OBJ),
                R32(A_MARIO_STATES + M_USED_OBJ),
                rfloat(A_MARIO_STATES + M_FORWARD_VEL));
    }
    if (gfx_object > gMaxGfxMinusObjectY) {
        gMaxGfxMinusObjectY = gfx_object;
        gMaxGapTimer = R32(A_GLOBAL_TIMER);
        gMaxGapAction = R32(A_MARIO_STATES + M_ACTION);
        gMaxGapStateY = state_y;
        gMaxGapObjectY = object_y;
        gMaxGapGraphicsY = graphics_y;
        fprintf(stderr,
                "MAX_GAP,timer=%u,gfxMinusObjectY=%.9g,stateY=%.9g,"
                "objectY=%.9g,graphicsY=%.9g,action=%08x,floor=%08x,"
                "floorHeight=%.9g,quicksandDepth=%.9g,platform=%08x\n",
                gMaxGapTimer, gfx_object, state_y, object_y, graphics_y,
                gMaxGapAction, R32(A_MARIO_STATES + M_FLOOR),
                rfloat(A_MARIO_STATES + M_FLOOR_HEIGHT),
                rfloat(A_MARIO_STATES + M_QUICKSAND_DEPTH),
                R32(A_MARIO_PLATFORM));
    }
    if (gfx_object < gMinGfxMinusObjectY) {
        gMinGfxMinusObjectY = gfx_object;
        fprintf(stderr,
                "MIN_GAP,timer=%u,gfxMinusObjectY=%.9g,stateY=%.9g,"
                "objectY=%.9g,graphicsY=%.9g,action=%08x,"
                "quicksandDepth=%.9g\n",
                R32(A_GLOBAL_TIMER), gfx_object, state_y, object_y,
                graphics_y, R32(A_MARIO_STATES + M_ACTION),
                rfloat(A_MARIO_STATES + M_QUICKSAND_DEPTH));
    }
    if (state_object > gMaxStateMinusObjectY) {
        gMaxStateMinusObjectY = state_object;
    }
    if (gfx_state > gMaxGfxMinusStateY) gMaxGfxMinusStateY = gfx_state;
    if (!gGap45 && gfx_object > 45.0f) {
        gGap45 = 1;
        fprintf(stderr,
                "GAP45,timer=%u,gfxMinusObjectY=%.9g,stateY=%.9g,"
                "objectY=%.9g,graphicsY=%.9g,action=%08x,"
                "quicksandDepth=%.9g\n",
                R32(A_GLOBAL_TIMER), gfx_object, state_y, object_y,
                graphics_y, R32(A_MARIO_STATES + M_ACTION),
                rfloat(A_MARIO_STATES + M_QUICKSAND_DEPTH));
    }
    if (gfx_object >= 960.0f) {
        gGap960 = 1;
        fprintf(stderr,
                "GAP960,timer=%u,gfxMinusObjectY=%.9g,state=(%.9g,%.9g,%.9g),"
                "object=(%.9g,%.9g,%.9g),graphics=(%.9g,%.9g,%.9g),"
                "action=%08x,usedObj=%08x,platform=%08x\n",
                R32(A_GLOBAL_TIMER), gfx_object,
                rfloat(A_MARIO_STATES + M_POS_X), state_y,
                rfloat(A_MARIO_STATES + M_POS_Z),
                rfloat(mario_object + O_POS_X), object_y,
                rfloat(mario_object + O_POS_Z),
                rfloat(mario_object + GFX_POS_X), graphics_y,
                rfloat(mario_object + GFX_POS_Z),
                R32(A_MARIO_STATES + M_ACTION),
                R32(A_MARIO_STATES + M_USED_OBJ), R32(A_MARIO_PLATFORM));
    }
}

static void observe_top(void) {
    int pillars;
    int action;
    int timer;

    if (gTop == 0 || R16(gTop + O_ACTIVE_FLAGS) == 0) return;
    pillars = (int32_t) R32(gTop + O_PYRAMID_PILLARS_TOUCHED);
    action = (int32_t) R32(gTop + O_ACTION);
    timer = (int32_t) R32(gTop + O_TIMER);
    if (pillars != gLastPillars || action != gLastTopAction
        || (action == 1 && (timer == 120 || timer == 126 || timer == 130
                            || timer == 131 || timer == 132
                            || timer == 140 || timer == 150))) {
        fprintf(stderr,
                "TOP,timer=%u,pillars=%d,action=%d,objectTimer=%d,"
                "position=(%.9g,%.9g,%.9g),platform=%08x\n",
                R32(A_GLOBAL_TIMER), pillars, action, timer,
                rfloat(gTop + O_POS_X), rfloat(gTop + O_POS_Y),
                rfloat(gTop + O_POS_Z), R32(A_MARIO_PLATFORM));
    }
    gLastPillars = pillars;
    gLastTopAction = action;
    gLastTopTimer = timer;
}

EXPORT m64p_error CALL PluginStartup(
    m64p_dynlib_handle core, void *context,
    void (*debug_callback)(void *, int, const char *)) {
    (void) context;
    (void) debug_callback;
    R32 = (read32_fn) dlsym(core, "DebugMemRead32");
    R16 = (read16_fn) dlsym(core, "DebugMemRead16");
    return R32 && R16 ? M64ERR_SUCCESS : M64ERR_INCOMPATIBLE;
}

EXPORT m64p_error CALL PluginShutdown(void) { return M64ERR_SUCCESS; }

EXPORT m64p_error CALL PluginGetVersion(
    m64p_plugin_type *type, int *version, int *api_version,
    const char **name, int *capabilities) {
    if (type) *type = M64PLUGIN_INPUT;
    if (version) *version = 0x000100;
    if (api_version) *api_version = 0x020100;
    if (name) *name = "SSL JP clean three-view gap search";
    if (capabilities) *capabilities = 0;
    return M64ERR_SUCCESS;
}

EXPORT void CALL InitiateControllers(CONTROL_INFO info) {
    int i;
    for (i = 0; i < 4; i++) {
        info.Controls[i].Present = i == 0;
        info.Controls[i].RawData = 0;
        info.Controls[i].Plugin = PLUGIN_MEMPAK;
        info.Controls[i].Type = CONT_TYPE_STANDARD;
    }
}

EXPORT int CALL RomOpen(void) {
    fprintf(stderr,
            "SEARCH,version=JP,boundary=level-select-initialized-area1,"
            "postEntryInput=controller-only,inputPluginMemoryWrites=zero,"
            "allowSetupA=%d,searchMode=%d\n",
            ALLOW_SETUP_A, SEARCH_MODE);
    return 1;
}

EXPORT void CALL RomClosed(void) {
    fprintf(stderr,
            "RESULT,area1Frames=%d,gapSamples=%d,gap45=%d,gap960=%d,"
            "maxGfxMinusObjectY=%.9g,minGfxMinusObjectY=%.9g,"
            "maxStateMinusObjectY=%.9g,maxGfxMinusStateY=%.9g,"
            "maxGapTimer=%u,maxGapAction=%08x,maxGapStateY=%.9g,"
            "maxGapObjectY=%.9g,maxGapGraphicsY=%.9g,"
            "maxCleanStateY=%.9g,maxStateYTimer=%u,maxStateYAction=%08x,"
            "maxStateYX=%.9g,maxStateYZ=%.9g,maxMarioGraphYOffset=%.9g,"
            "fireFrames=%d,sawFirePrevObj=%d,sawFireParticle=%d,"
            "usedTornado=%d,tornadoCaptures=%d,"
            "pillars=%d,topAction=%d,topTimer=%d,sawShell=%d,rodeShell=%d,"
            "bPressedFrames=%d,"
            "warpDisappeared=%d,warpUsedObj=%d,platformTop=%d,"
            "aPressedFrames=%d,aDownFrames=%d,controllerAFrames=%d\n",
            gArea1Frames, gGapSamples, gGap45, gGap960,
            gMaxGfxMinusObjectY, gMinGfxMinusObjectY,
            gMaxStateMinusObjectY, gMaxGfxMinusStateY,
            gMaxGapTimer, gMaxGapAction, gMaxGapStateY,
            gMaxGapObjectY, gMaxGapGraphicsY,
            gMaxStateY, gMaxStateYTimer, gMaxStateYAction,
            gMaxStateYX, gMaxStateYZ, gMaxMarioGraphYOffset,
            gFireFrames, gSawFirePrevObj, gSawFireParticle,
            gUsedTornado, gTornadoCaptures,
            gLastPillars, gLastTopAction, gLastTopTimer,
            gSawShell, gRodeShell, gBPressedFrames,
            gWarpDisappeared, gWarpUsedObj, gPlatformTop,
            gAPressedFrames, gADownFrames, gControllerAFrames);
}

EXPORT void CALL ControllerCommand(int control, unsigned char *command) {
    (void) control; (void) command;
}
EXPORT void CALL ReadController(int control, unsigned char *command) {
    (void) control; (void) command;
}
EXPORT void CALL SDL_KeyDown(int modifier, int key) { (void) modifier; (void) key; }
EXPORT void CALL SDL_KeyUp(int modifier, int key) { (void) modifier; (void) key; }
EXPORT void CALL RenderCallback(void) {}
EXPORT void CALL SendVRUWord(uint16_t length, uint16_t *word, uint8_t language) {
    (void) length; (void) word; (void) language;
}
EXPORT void CALL SetMicState(int state) { (void) state; }
EXPORT void CALL ReadVRUResults(uint16_t *error_flags, uint16_t *num_results,
                                uint16_t *mic_level, uint16_t *voice_level,
                                uint16_t *voice_length, uint16_t *matches) {
    if (error_flags) *error_flags = 0;
    if (num_results) *num_results = 0;
    if (mic_level) *mic_level = 0;
    if (voice_level) *voice_level = 0;
    if (voice_length) *voice_length = 0;
    (void) matches;
}
EXPORT void CALL ClearVRUWords(uint8_t length) { (void) length; }
EXPORT void CALL SetVRUWordMask(uint8_t length, uint8_t *mask) {
    (void) length; (void) mask;
}

EXPORT void CALL GetKeys(int control, BUTTONS *keys) {
    uint16_t area;
    uint32_t mario_object;
    uint16_t input;
    int pillars;
    int top_action;
    int top_timer;

    memset(keys, 0, sizeof(*keys));
    if (control != 0) return;
    gPoll++;

    /* Retail level-select navigation.  Gameplay itself is controller-only. */
    if (gPoll >= 150 && gPoll < 156) keys->START_BUTTON = 1;
    for (uint64_t slot = 220; slot <= 280; slot += 10) {
        if (gPoll >= slot && gPoll < slot + 2) keys->D_DPAD = 1;
    }
    if (gPoll >= 330 && gPoll < 336) keys->START_BUTTON = 1;

    area = R16(A_CURR_AREA);
    mario_object = R32(A_MARIO_OBJECT);
    if (area != 1 || mario_object == 0) return;
    gArea1Frames++;
    if (gTop == 0 || gUpperWarp == 0) find_area1_objects();
    else if (gShell == 0) find_area1_objects();
    observe_gap();
    observe_top();

    input = R16(A_MARIO_STATES + M_INPUT);
    if ((input & INPUT_A_PRESSED) != 0) gAPressedFrames++;
    if ((input & INPUT_A_DOWN) != 0) gADownFrames++;
    if (keys->A_BUTTON) gControllerAFrames++;

    if (R32(A_MARIO_STATES + M_ACTION) == ACT_DISAPPEARED) {
        gWarpDisappeared = 1;
        if (R32(A_MARIO_STATES + M_USED_OBJ) == gUpperWarp) {
            gWarpUsedObj = 1;
        }
        if (R32(A_MARIO_PLATFORM) == gTop) gPlatformTop = 1;
    }

    if (gTop == 0) return;
    pillars = (int32_t) R32(gTop + O_PYRAMID_PILLARS_TOUCHED);
    top_action = (int32_t) R32(gTop + O_ACTION);
    top_timer = (int32_t) R32(gTop + O_TIMER);

    if (R32(A_MARIO_STATES + M_ACTION) == ACT_RIDING_SHELL_GROUND
        || R32(A_MARIO_STATES + M_ACTION) == ACT_RIDING_SHELL_JUMP
        || R32(A_MARIO_STATES + M_ACTION) == ACT_RIDING_SHELL_FALL) {
        gRodeShell = 1;
    }
    if (R32(A_MARIO_STATES + M_ACTION) == ACT_TORNADO_TWIRLING
        || R32(A_MARIO_STATES + M_ACTION) == ACT_TWIRLING) {
        gUsedTornado = 1;
    }

    /* Keep independently reproducible schedules separate.  Mode 1 steers
       into the east quicksand using only the stick; mode 2 applies no
       gameplay input.  Mode 0 is the jumping-box/B-movement search below. */
    if (SEARCH_MODE == 1) {
        steer_world(keys, 7000.0f, 6500.0f, 127.0f);
        goto log_frame;
    }
    if (SEARCH_MODE == 2) goto log_frame;

    /* First obtain the stock Area-1 shell using only ordinary movement and
       B attacks.  Its action is the largest dry stock Graphics-Y writer. */
    if (!gRodeShell) {
        float target_x;
        float target_z;
        float mario_x = rfloat(A_MARIO_STATES + M_POS_X);
        float mario_z = rfloat(A_MARIO_STATES + M_POS_Z);

        if (gShell != 0) {
            target_x = rfloat(gShell + O_POS_X);
            target_z = rfloat(gShell + O_POS_Z);
        } else if (R32(A_MARIO_STATES + M_HELD_OBJ) != 0
                   || R32(A_MARIO_STATES + M_ACTION)
                        == ACT_CRAZY_BOX_BOUNCE) {
            if (SEARCH_MODE >= 3 && SEARCH_MODE <= 6) {
                target_x = -5125.0f;
                target_z = -3138.0f;
            } else {
                target_x = 5840.0f;
                target_z = 2500.0f;
            }
        } else if (R32(A_GLOBAL_TIMER) < 500 && gJumpingBox != 0) {
            target_x = rfloat(gJumpingBox + O_POS_X);
            target_z = rfloat(gJumpingBox + O_POS_Z);
        } else if (SEARCH_MODE == 6 && gTornadoCaptures >= 4) {
            target_x = -2048.0f;
            target_z = -1024.0f;
        } else if (SEARCH_MODE == 6 && gUsedTornado) {
            target_x = -3600.0f;
            target_z = 2940.0f;
        } else if (SEARCH_MODE == 5 && gTornadoCaptures >= 2) {
            target_x = -2048.0f;
            target_z = -1024.0f;
        } else if (SEARCH_MODE == 5 && gUsedTornado) {
            target_x = -3600.0f;
            target_z = 2940.0f;
        } else if (SEARCH_MODE == 4 && gUsedTornado) {
            target_x = -2048.0f;
            target_z = -1024.0f;
        } else if (SEARCH_MODE >= 3 && SEARCH_MODE <= 6) {
            target_x = -5125.0f;
            target_z = -3138.0f;
        } else if (gTravelStage == 0) {
            target_x = 7000.0f;
            target_z = 6500.0f;
            if (mario_x > 6700.0f) gTravelStage = 1;
        } else if (gTravelStage == 1) {
            target_x = 7200.0f;
            target_z = 3500.0f;
            if (mario_z < 3800.0f) gTravelStage = 2;
        } else {
            target_x = 5840.0f;
            target_z = 2500.0f;
        }
        float dx = target_x - rfloat(A_MARIO_STATES + M_POS_X);
        float dz = target_z - rfloat(A_MARIO_STATES + M_POS_Z);
        float distance = sqrtf(dx * dx + dz * dz);

        steer_world(keys, target_x, target_z, 127.0f);
        if (gJumpingBox != 0 && R32(A_GLOBAL_TIMER) < 500
            && distance < 135.0f
            && R32(A_GLOBAL_TIMER) - gLastMovementB >= 20) {
            keys->B_BUTTON = 1;
            gBPressedFrames++;
            gLastMovementB = R32(A_GLOBAL_TIMER);
            fprintf(stderr,
                    "B_INPUT,timer=%u,label=jumping-box,distance=%.9g,"
                    "state=(%.9g,%.9g,%.9g),action=%08x,box=%08x\n",
                    gLastMovementB, distance,
                    rfloat(A_MARIO_STATES + M_POS_X),
                    rfloat(A_MARIO_STATES + M_POS_Y),
                    rfloat(A_MARIO_STATES + M_POS_Z),
                    R32(A_MARIO_STATES + M_ACTION), gJumpingBox);
        } else if (R32(A_GLOBAL_TIMER) >= 500
            && R32(A_GLOBAL_TIMER) - gLastMovementB >= 20
            && ((R32(A_MARIO_STATES + M_ACTION) == ACT_WALKING
                 && rfloat(A_MARIO_STATES + M_FORWARD_VEL) >= 29.0f)
                || R32(A_MARIO_STATES + M_ACTION) == ACT_DIVE_SLIDE
                || R32(A_MARIO_STATES + M_ACTION) == ACT_STOMACH_SLIDE)) {
            keys->B_BUTTON = 1;
            gBPressedFrames++;
            gLastMovementB = R32(A_GLOBAL_TIMER);
            fprintf(stderr,
                    "B_INPUT,timer=%u,label=movement,forwardVel=%.9g,"
                    "state=(%.9g,%.9g,%.9g),action=%08x\n",
                    gLastMovementB,
                    rfloat(A_MARIO_STATES + M_FORWARD_VEL),
                    rfloat(A_MARIO_STATES + M_POS_X),
                    rfloat(A_MARIO_STATES + M_POS_Y),
                    rfloat(A_MARIO_STATES + M_POS_Z),
                    R32(A_MARIO_STATES + M_ACTION));
        }
        if (SEARCH_MODE == 0 && gShell == 0 && distance < 180.0f
            && (gPoll % 8) == 0) {
            keys->B_BUTTON = 1;
            gBPressedFrames++;
            fprintf(stderr,
                    "B_INPUT,timer=%u,label=shell-box,distance=%.9g,"
                    "state=(%.9g,%.9g,%.9g),action=%08x,box=%08x\n",
                    R32(A_GLOBAL_TIMER), distance,
                    rfloat(A_MARIO_STATES + M_POS_X),
                    rfloat(A_MARIO_STATES + M_POS_Y),
                    rfloat(A_MARIO_STATES + M_POS_Z),
                    R32(A_MARIO_STATES + M_ACTION), gShellBox);
        }
        if (ALLOW_SETUP_A && gShell == 0 && distance < 260.0f
            && rfloat(A_MARIO_STATES + M_POS_Y) < 900.0f
            && (gPoll % 2) == 0) {
            keys->A_BUTTON = 1;
            gControllerAFrames++;
        }
        goto log_frame;
    }

    /* Visit all four real touch detectors.  The order starts with the two
       western detectors and leaves the nearest eastern detector last. */
    switch (pillars) {
        case 0: steer_world(keys, 1789.0f, 764.0f, 127.0f); break;
        case 1: steer_world(keys, 1789.0f, -2579.0f, 127.0f); break;
        case 2: steer_world(keys, -5883.0f, -2579.0f, 127.0f); break;
        case 3: steer_world(keys, -5883.0f, 764.0f, 127.0f); break;
        default:
            /* Hold outside the radius, then enter near timer 128. */
            if (top_action == 1 && top_timer < 126) {
                steer_world(keys, -1800.0f, -800.0f, 70.0f);
            } else {
                steer_world(keys, -2048.0f, -1024.0f, 127.0f);
            }
            break;
    }

    if (ALLOW_SETUP_A && gRodeShell && (gPoll % 45) == 0) {
        keys->A_BUTTON = 1;
        gControllerAFrames++;
    }
log_frame:
    if (gArea1Frames % 30 == 0) {
        fprintf(stderr,
                "FRAME,timer=%u,pillars=%d,topAction=%d,topTimer=%d,"
                "axis=(%d,%d),state=(%.9g,%.9g,%.9g),forwardVel=%.9g,"
                "action=%08x,usedObj=%08x,platform=%08x,"
                "quicksandDepth=%.9g,travelStage=%d\n",
                R32(A_GLOBAL_TIMER), pillars, top_action, top_timer,
                keys->X_AXIS, keys->Y_AXIS,
                rfloat(A_MARIO_STATES + M_POS_X),
                rfloat(A_MARIO_STATES + M_POS_Y),
                rfloat(A_MARIO_STATES + M_POS_Z),
                rfloat(A_MARIO_STATES + M_FORWARD_VEL),
                R32(A_MARIO_STATES + M_ACTION),
                R32(A_MARIO_STATES + M_USED_OBJ), R32(A_MARIO_PLATFORM),
                rfloat(A_MARIO_STATES + M_QUICKSAND_DEPTH), gTravelStage);
    }
}
