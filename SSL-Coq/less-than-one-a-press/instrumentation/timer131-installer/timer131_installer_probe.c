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

    GFX_POS_X = 0x020,
    GFX_POS_Y = 0x024,
    GFX_POS_Z = 0x028,
    O_ACTIVE_FLAGS = 0x074,
    O_POS_X = 0x0a0,
    O_POS_Y = 0x0a4,
    O_POS_Z = 0x0a8,
    O_PYRAMID_PILLARS_TOUCHED = 0x0f4,
    O_ACTION = 0x14c,
    O_TIMER = 0x154,
    O_BHV_PARAMS = 0x188,
};

enum {
    M_INPUT = 0x02,
    M_ACTION = 0x0c,
    M_ACTION_ARG = 0x1c,
    M_POS_X = 0x3c,
    M_POS_Y = 0x40,
    M_POS_Z = 0x44,
    M_FLOOR = 0x68,
    M_FLOOR_HEIGHT = 0x70,
    M_USED_OBJ = 0x80,
};

enum {
    SURFACE_OBJECT = 0x2c,
    ACT_DISAPPEARED = 0x00001300,
};

typedef unsigned int (*read32_fn)(unsigned int);
typedef unsigned short (*read16_fn)(unsigned int);
typedef void (*write32_fn)(unsigned int, unsigned int);

static read32_fn R32;
static read16_fn R16;
static write32_fn W32;

static uint64_t gPoll;
static uint32_t gTop;
static uint32_t gUpperWarp;
static uint32_t gInstallGlobalTimer;
static int gArmed;
static int gInstalled;
static int gLoggedNext;
static int gRetryCopied;
static int gRetryOwnerTop;
static int gWarpAction;
static int gUsedObjWarp;
static int gPlatformTop;
static int gAPressedFrames;
static int gADownFrames;
static int gControllerAFrames;

static float rfloat(uint32_t address) {
    union {
        float f;
        uint32_t u;
    } bits;
    bits.u = R32(address);
    return bits.f;
}

static uint32_t fbits(float value) {
    union {
        float f;
        uint32_t u;
    } bits;
    bits.f = value;
    return bits.u;
}

static int pool_index(uint32_t pointer) {
    uint32_t delta;

    if (pointer < A_OBJECT_POOL) return -1;
    delta = pointer - A_OBJECT_POOL;
    if (delta >= OBJECT_COUNT * OBJECT_SIZE || delta % OBJECT_SIZE != 0) {
        return -1;
    }
    return (int) (delta / OBJECT_SIZE);
}

static uint32_t pool_pointer(unsigned index) {
    return A_OBJECT_POOL + index * OBJECT_SIZE;
}

static void find_area1_objects(void) {
    unsigned i;

    gTop = 0;
    gUpperWarp = 0;
    for (i = 0; i < OBJECT_COUNT; i++) {
        uint32_t object = pool_pointer(i);
        if (R16(object + O_ACTIVE_FLAGS) == 0) continue;
        if (fabsf(rfloat(object + O_POS_X) - -2047.0f) < 0.5f
            && fabsf(rfloat(object + O_POS_Y) - 1536.0f) < 1.0f
            && fabsf(rfloat(object + O_POS_Z) - -1023.0f) < 0.5f) {
            gTop = object;
        }
        if (rfloat(object + O_POS_X) == -2048.0f
            && rfloat(object + O_POS_Y) == 768.0f
            && rfloat(object + O_POS_Z) == -1024.0f
            && ((R32(object + O_BHV_PARAMS) >> 16) & 0xff) == 0x1e) {
            gUpperWarp = object;
        }
    }
}

static void install_three_view_boundary(void) {
    uint32_t mario_object = R32(A_MARIO_OBJECT);

    /* First floor query: State view. */
    W32(A_MARIO_STATES + M_POS_X, fbits(-2200.0f));
    W32(A_MARIO_STATES + M_POS_Y, fbits(768.0f));
    W32(A_MARIO_STATES + M_POS_Z, fbits(-1024.0f));

    /* Collision pass: Object view at the upper warp's exact center. */
    W32(mario_object + O_POS_X, R32(gUpperWarp + O_POS_X));
    W32(mario_object + O_POS_Y, R32(gUpperWarp + O_POS_Y));
    W32(mario_object + O_POS_Z, R32(gUpperWarp + O_POS_Z));

    /* OOB retry: strict interior of timer-131 top face (1,4,3). */
    W32(mario_object + GFX_POS_X, fbits(-1641.0f));
    W32(mario_object + GFX_POS_Y, fbits(1456.0f));
    W32(mario_object + GFX_POS_Z, fbits(-783.0f));

    W32(A_MARIO_PLATFORM, 0);
}

static void log_install(void) {
    uint32_t mario_object = R32(A_MARIO_OBJECT);

    fprintf(stderr,
            "INSTALL,poll=%llu,globalTimer=%u,area=%u,top=%08x,slot=%d,"
            "topAction=%d,topTimer=%d,top=(%.6f,%.6f,%.6f),"
            "topBits=(%08x,%08x,%08x),"
            "state=(%.6f,%.6f,%.6f),object=(%.6f,%.6f,%.6f),"
            "graphics=(%.6f,%.6f,%.6f),action=%08x,arg=%08x,"
            "usedObj=%08x,platform=%08x,upperWarp=%08x\n",
            (unsigned long long) gPoll, R32(A_GLOBAL_TIMER), R16(A_CURR_AREA),
            gTop, pool_index(gTop), (int32_t) R32(gTop + O_ACTION),
            (int32_t) R32(gTop + O_TIMER),
            rfloat(gTop + O_POS_X), rfloat(gTop + O_POS_Y),
            rfloat(gTop + O_POS_Z), R32(gTop + O_POS_X),
            R32(gTop + O_POS_Y), R32(gTop + O_POS_Z),
            rfloat(A_MARIO_STATES + M_POS_X),
            rfloat(A_MARIO_STATES + M_POS_Y),
            rfloat(A_MARIO_STATES + M_POS_Z),
            rfloat(mario_object + O_POS_X), rfloat(mario_object + O_POS_Y),
            rfloat(mario_object + O_POS_Z),
            rfloat(mario_object + GFX_POS_X),
            rfloat(mario_object + GFX_POS_Y),
            rfloat(mario_object + GFX_POS_Z),
            R32(A_MARIO_STATES + M_ACTION),
            R32(A_MARIO_STATES + M_ACTION_ARG),
            R32(A_MARIO_STATES + M_USED_OBJ), R32(A_MARIO_PLATFORM),
            gUpperWarp);
}

static void log_next(void) {
    uint32_t mario_object = R32(A_MARIO_OBJECT);
    uint32_t floor = R32(A_MARIO_STATES + M_FLOOR);
    uint32_t owner = floor == 0 ? 0 : R32(floor + SURFACE_OBJECT);
    uint32_t action = R32(A_MARIO_STATES + M_ACTION);
    uint32_t used_obj = R32(A_MARIO_STATES + M_USED_OBJ);
    uint32_t platform = R32(A_MARIO_PLATFORM);

    gRetryCopied =
        R32(A_MARIO_STATES + M_POS_X) == fbits(-1641.0f)
        && R32(A_MARIO_STATES + M_POS_Z) == fbits(-783.0f);
    gRetryOwnerTop = owner == gTop;
    gWarpAction = action == ACT_DISAPPEARED;
    gUsedObjWarp = used_obj == gUpperWarp;
    gPlatformTop = platform == gTop;

    fprintf(stderr,
            "NEXT,poll=%llu,globalTimer=%u,area=%u,top=%08x,slot=%d,"
            "topAction=%d,topTimer=%d,top=(%.6f,%.6f,%.6f),"
            "topBits=(%08x,%08x,%08x),"
            "state=(%.6f,%.6f,%.6f),stateBits=(%08x,%08x,%08x),"
            "object=(%.6f,%.6f,%.6f),graphics=(%.6f,%.6f,%.6f),"
            "floor=%08x,floorOwner=%08x,floorHeight=%.6f,"
            "action=%08x,arg=%08x,usedObj=%08x,platform=%08x,"
            "retryCopied=%d,retryOwnerTop=%d,warpAction=%d,"
            "usedObjWarp=%d,platformTop=%d\n",
            (unsigned long long) gPoll, R32(A_GLOBAL_TIMER), R16(A_CURR_AREA),
            gTop, pool_index(gTop), (int32_t) R32(gTop + O_ACTION),
            (int32_t) R32(gTop + O_TIMER),
            rfloat(gTop + O_POS_X), rfloat(gTop + O_POS_Y),
            rfloat(gTop + O_POS_Z), R32(gTop + O_POS_X),
            R32(gTop + O_POS_Y), R32(gTop + O_POS_Z),
            rfloat(A_MARIO_STATES + M_POS_X),
            rfloat(A_MARIO_STATES + M_POS_Y),
            rfloat(A_MARIO_STATES + M_POS_Z),
            R32(A_MARIO_STATES + M_POS_X),
            R32(A_MARIO_STATES + M_POS_Y),
            R32(A_MARIO_STATES + M_POS_Z),
            rfloat(mario_object + O_POS_X), rfloat(mario_object + O_POS_Y),
            rfloat(mario_object + O_POS_Z),
            rfloat(mario_object + GFX_POS_X),
            rfloat(mario_object + GFX_POS_Y),
            rfloat(mario_object + GFX_POS_Z),
            floor, owner, rfloat(A_MARIO_STATES + M_FLOOR_HEIGHT),
            action, R32(A_MARIO_STATES + M_ACTION_ARG), used_obj, platform,
            gRetryCopied, gRetryOwnerTop, gWarpAction, gUsedObjWarp,
            gPlatformTop);
}

EXPORT m64p_error CALL PluginStartup(
    m64p_dynlib_handle core,
    void *context,
    void (*debug_callback)(void *, int, const char *)) {
    (void) context;
    (void) debug_callback;
    R32 = (read32_fn) dlsym(core, "DebugMemRead32");
    R16 = (read16_fn) dlsym(core, "DebugMemRead16");
    W32 = (write32_fn) dlsym(core, "DebugMemWrite32");
    return R32 && R16 && W32 ? M64ERR_SUCCESS : M64ERR_INCOMPATIBLE;
}

EXPORT m64p_error CALL PluginShutdown(void) { return M64ERR_SUCCESS; }

EXPORT m64p_error CALL PluginGetVersion(
    m64p_plugin_type *type, int *version, int *api_version,
    const char **name, int *capabilities) {
    if (type) *type = M64PLUGIN_INPUT;
    if (version) *version = 0x000100;
    if (api_version) *api_version = 0x020100;
    if (name) *name = "SSL JP timer-131 three-view installer";
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
    gPoll = 0;
    gTop = 0;
    gUpperWarp = 0;
    gInstallGlobalTimer = 0;
    gArmed = 0;
    gInstalled = 0;
    gLoggedNext = 0;
    gRetryCopied = 0;
    gRetryOwnerTop = 0;
    gWarpAction = 0;
    gUsedObjWarp = 0;
    gPlatformTop = 0;
    gAPressedFrames = 0;
    gADownFrames = 0;
    gControllerAFrames = 0;
    fprintf(stderr,
            "PROBE,version=JP,boundary=conditional-timer131-three-view,"
            "state=(-2200,768,-1024),object=upper-warp-center,"
            "graphics=(-1641,1456,-783),controllerA=zero\n");
    return 1;
}

EXPORT void CALL RomClosed(void) {
    fprintf(stderr,
            "RESULT,armed=%d,installed=%d,next=%d,retryCopied=%d,"
            "retryOwnerTop=%d,warpAction=%d,usedObjWarp=%d,platformTop=%d,"
            "aPressedFrames=%d,aDownFrames=%d,controllerAFrames=%d\n",
            gArmed, gInstalled, gLoggedNext, gRetryCopied, gRetryOwnerTop,
            gWarpAction, gUsedObjWarp, gPlatformTop, gAPressedFrames,
            gADownFrames, gControllerAFrames);
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
    uint64_t slot;
    uint16_t area;
    uint32_t global_timer;

    memset(keys, 0, sizeof(*keys));
    if (control != 0) return;
    gPoll++;

    /* Retail level-select menu navigation, before the injected boundary. */
    if (gPoll >= 150 && gPoll < 156) keys->START_BUTTON = 1;
    for (slot = 220; slot <= 280; slot += 10) {
        if (gPoll >= slot && gPoll < slot + 2) keys->D_DPAD = 1;
    }
    if (gPoll >= 330 && gPoll < 336) keys->START_BUTTON = 1;

    area = R16(A_CURR_AREA);
    if (!gArmed && gPoll > 360 && area == 1 && R32(A_MARIO_OBJECT) != 0) {
        find_area1_objects();
        if (gTop != 0 && gUpperWarp != 0) {
            W32(gTop + O_PYRAMID_PILLARS_TOUCHED, 4);
            gArmed = 1;
            fprintf(stderr,
                    "ARM,poll=%llu,globalTimer=%u,top=%08x,slot=%d,"
                    "upperWarp=%08x,upperParams=%08x\n",
                    (unsigned long long) gPoll, R32(A_GLOBAL_TIMER), gTop,
                    pool_index(gTop), gUpperWarp,
                    R32(gUpperWarp + O_BHV_PARAMS));
        }
    }

    if (gArmed && !gInstalled && area == 1
        && R32(gTop + O_ACTION) == 1 && R32(gTop + O_TIMER) == 131) {
        install_three_view_boundary();
        gInstallGlobalTimer = R32(A_GLOBAL_TIMER);
        gInstalled = 1;
        log_install();
    }

    global_timer = R32(A_GLOBAL_TIMER);
    if (gInstalled && !gLoggedNext && global_timer != gInstallGlobalTimer) {
        log_next();
        gLoggedNext = 1;
    }

    if (gInstalled) {
        uint16_t input = R16(A_MARIO_STATES + M_INPUT);
        if ((input & 0x0002) != 0) gAPressedFrames++;
        if ((input & 0x0080) != 0) gADownFrames++;
        if (keys->A_BUTTON) gControllerAFrames++;
    }
}
