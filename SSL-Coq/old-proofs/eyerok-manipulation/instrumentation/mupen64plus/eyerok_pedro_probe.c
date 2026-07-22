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

#ifndef PEDRO_SPEED
#define PEDRO_SPEED 48
#endif

#ifndef PEDRO_LABEL
#define PEDRO_LABEL "ordinary48"
#endif

#if PEDRO_SPEED <= 0
#error PEDRO_SPEED must be positive
#endif

enum {
    A_GLOBAL_TIMER = 0x8032d5d4,
    A_CURR_LEVEL = 0x8032ddf8,
    A_MARIO_STATES = 0x8033b170,
    A_WARP_DEST = 0x8033b248,
    A_SEGMENT_TABLE = 0x8033b400,
    A_OBJECT_POOL = 0x8033d488,
    A_MARIO_OBJECT = 0x80361158,
    A_CURR_AREA = 0x8033baca,
    A_MARIO_PLATFORM = 0x80330e34,
    OBJECT_SIZE = 0x260,
    OBJECT_COUNT = 240,
};

enum {
    O_ACTIVE_FLAGS = 0x074,
    O_POS_X = 0x0a0,
    O_POS_Y = 0x0a4,
    O_POS_Z = 0x0a8,
    O_VEL_Y = 0x0b0,
    O_FACE_YAW = 0x0d4,
    O_SIDE = 0x144,
    O_ACTION = 0x14c,
    O_TIMER = 0x154,
    O_HOME_Y = 0x168,
    O_BEHAVIOR = 0x20c,
    O_COLLISION = 0x218,
};

enum {
    ACT_LONG_JUMP = 0x03000888U,
};

typedef unsigned int (*read32_fn)(unsigned int);
typedef unsigned short (*read16_fn)(unsigned int);
typedef unsigned char (*read8_fn)(unsigned int);
typedef void (*write32_fn)(unsigned int, unsigned int);
typedef void (*write16_fn)(unsigned int, unsigned short);
typedef void (*write8_fn)(unsigned int, unsigned char);

static read32_fn R32;
static read16_fn R16;
static read8_fn R8;
static write32_fn W32;
static write16_fn W16;
static write8_fn W8;
static unsigned long long gPoll;
static uint32_t gLastTimer;
static int gWarpToArea2;
static int gStagedInstantWarp;
static int gPoseStaged;
static uint32_t gBoss;
static uint32_t gHand;
static float gStartX;
static float gStartY;
static float gStartZ;

static uint32_t fbits(float value) {
    union {
        float f;
        uint32_t u;
    } bits;
    bits.f = value;
    return bits.u;
}

static float rfloat(uint32_t address) {
    union {
        float f;
        uint32_t u;
    } bits;
    bits.u = R32(address);
    return bits.f;
}

static int32_t rs32(uint32_t address) {
    return (int32_t) R32(address);
}

static uint32_t segment_virtual(unsigned segment, uint32_t offset) {
    uint32_t base = R32(A_SEGMENT_TABLE + segment * 4) & 0x1fffffffU;
    return 0x80000000U | (base + offset);
}

static uint32_t surface_object(uint32_t surface) {
    return surface != 0 ? R32(surface + 0x2c) : 0;
}

static void put_mario(float x, float y, float z, float vel_y) {
    uint32_t mario_object = R32(A_MARIO_OBJECT);

    W32(A_MARIO_STATES + 0x3c, fbits(x));
    W32(A_MARIO_STATES + 0x40, fbits(y));
    W32(A_MARIO_STATES + 0x44, fbits(z));
    W32(A_MARIO_STATES + 0x48, 0);
    W32(A_MARIO_STATES + 0x4c, fbits(vel_y));
    W32(A_MARIO_STATES + 0x50, 0);
    if (mario_object != 0) {
        W32(mario_object + O_POS_X, fbits(x));
        W32(mario_object + O_POS_Y, fbits(y));
        W32(mario_object + O_POS_Z, fbits(z));
        W32(mario_object + O_VEL_Y, fbits(vel_y));
    }
}

static void find_sleep_objects(void) {
    uint32_t hand_behavior = segment_virtual(0x13, 0x52d0);
    uint32_t boss_behavior = segment_virtual(0x13, 0x52b4);
    unsigned i;

    gBoss = 0;
    gHand = 0;
    for (i = 0; i < OBJECT_COUNT; i++) {
        uint32_t object = A_OBJECT_POOL + i * OBJECT_SIZE;
        if (R16(object + O_ACTIVE_FLAGS) == 0) {
            continue;
        }
        if (R32(object + O_BEHAVIOR) == boss_behavior) {
            gBoss = object;
        }
        if (R32(object + O_BEHAVIOR) == hand_behavior
            && rs32(object + O_SIDE) == 1) {
            gHand = object;
        }
    }
}

static void transform_sleep_local(float local_x, float local_z,
                                  float *world_x, float *world_z) {
    const float tau = 6.2831853071795864769f;
    float yaw = (float) ((int16_t) rs32(gHand + O_FACE_YAW)) * tau / 65536.0f;
    float sine = sinf(yaw);
    float cosine = cosf(yaw);

    *world_x = rfloat(gHand + O_POS_X)
               + 1.5f * (local_x * cosine + local_z * sine);
    *world_z = rfloat(gHand + O_POS_Z)
               + 1.5f * (-local_x * sine + local_z * cosine);
}

static void stage_pedro_entry(void) {
    float strip_x;
    float strip_z;

    /* Local z=-20.5 lies halfway across the one-unit ceiling sliver.  Both
       fixtures start just outside the outer thumb wall (world Z > -3116).
       Speed 48 remains in its radius-50 rejection band.  After retail's
       0.35 long-jump drag, speed 424 crosses more than 100 units in one
       quarter-step and ends on the wall-free internal half of the strip. */
    transform_sleep_local(185.0f, -20.5f, &gStartX, &gStartZ);
    transform_sleep_local(114.4f, -20.5f, &strip_x, &strip_z);
    gStartY = rfloat(gHand + O_POS_Y) + 2.0f;
    put_mario(gStartX, gStartY, gStartZ, 0.0f);

    W32(A_MARIO_STATES + 0x0c, ACT_LONG_JUMP);
    W32(A_MARIO_STATES + 0x10, ACT_LONG_JUMP);
    W16(A_MARIO_STATES + 0x18, 0);
    W16(A_MARIO_STATES + 0x1a, 0);
    W32(A_MARIO_STATES + 0x1c, 0);
    W32(A_MARIO_STATES + 0x20, 0);
    W32(A_MARIO_STATES + 0x54, fbits((float) PEDRO_SPEED));
    W32(A_MARIO_STATES + 0x58, 0);
    W32(A_MARIO_STATES + 0x5c, 0);
    W16(A_MARIO_STATES + 0x2e, 0x8000U);

    fprintf(stderr,
            "PEDRO_SETUP,label=%s,speed=%d,hand=%08x,boss=%08x,"
            "start=(%.3f,%.3f,%.3f),strip=(%.3f,%.3f),"
            "hand=(%.3f,%.3f,%.3f),yaw=%d,side=%d,"
            "writes=position+long_jump_action+speed+facing,no_hand_writes\n",
            PEDRO_LABEL, PEDRO_SPEED, gHand, gBoss,
            gStartX, gStartY, gStartZ, strip_x, strip_z,
            rfloat(gHand + O_POS_X), rfloat(gHand + O_POS_Y),
            rfloat(gHand + O_POS_Z), rs32(gHand + O_FACE_YAW),
            rs32(gHand + O_SIDE));
}

static void log_frame(uint32_t timer) {
    uint32_t floor = R32(A_MARIO_STATES + 0x68);
    uint32_t ceil = R32(A_MARIO_STATES + 0x64);
    float x = rfloat(A_MARIO_STATES + 0x3c);
    float y = rfloat(A_MARIO_STATES + 0x40);
    float z = rfloat(A_MARIO_STATES + 0x44);
    int cancelled_xz = fabsf(x - gStartX) < 0.01f && fabsf(z - gStartZ) < 0.01f;
    int pedro_y = gHand != 0 && fabsf(y - (rfloat(gHand + O_POS_Y) + 75.0f)) < 0.01f;

    fprintf(stderr,
            "CSV,%u,%s,%d,%u,%08x,%d,%d,%.3f,%.3f,%.3f,"
            "%.3f,%.3f,%.3f,%.3f,%08x,%08x,%.3f,%08x,%08x,%.3f,"
            "%08x,%d,%d,%.3f,%.3f,%.3f,%08x,%d,%d\n",
            timer, PEDRO_LABEL, PEDRO_SPEED, R16(A_CURR_AREA),
            gBoss, gBoss ? rs32(gBoss + O_ACTION) : -1,
            rs32(A_MARIO_STATES + 0x0c), x, y, z,
            rfloat(A_MARIO_STATES + 0x48), rfloat(A_MARIO_STATES + 0x4c),
            rfloat(A_MARIO_STATES + 0x50), rfloat(A_MARIO_STATES + 0x54),
            floor, surface_object(floor), rfloat(A_MARIO_STATES + 0x70),
            ceil, surface_object(ceil), rfloat(A_MARIO_STATES + 0x6c),
            R32(A_MARIO_PLATFORM), gHand ? rs32(gHand + O_ACTION) : -1,
            gHand ? rs32(gHand + O_TIMER) : -1,
            gHand ? rfloat(gHand + O_POS_X) : 0.0f,
            gHand ? rfloat(gHand + O_POS_Y) : 0.0f,
            gHand ? rfloat(gHand + O_POS_Z) : 0.0f,
            gHand ? R32(gHand + O_COLLISION) : 0,
            cancelled_xz, pedro_y);
}

EXPORT m64p_error CALL PluginStartup(m64p_dynlib_handle core, void *context,
                                     void (*debug_callback)(void *, int,
                                                            const char *)) {
    (void) context;
    (void) debug_callback;
    R32 = (read32_fn) dlsym(core, "DebugMemRead32");
    R16 = (read16_fn) dlsym(core, "DebugMemRead16");
    R8 = (read8_fn) dlsym(core, "DebugMemRead8");
    W32 = (write32_fn) dlsym(core, "DebugMemWrite32");
    W16 = (write16_fn) dlsym(core, "DebugMemWrite16");
    W8 = (write8_fn) dlsym(core, "DebugMemWrite8");
    if (!R32 || !R16 || !R8 || !W32 || !W16 || !W8) {
        return M64ERR_INCOMPATIBLE;
    }
    fprintf(stderr,
            "CSV_HEADER,timer,label,speed,area,boss,bossAction,mAction,"
            "mX,mY,mZ,mVelX,mVelY,mVelZ,mForwardVel,floor,floorObject,"
            "floorHeight,ceil,ceilObject,ceilHeight,platform,handAction,"
            "handTimer,handX,handY,handZ,collision,cancelledXZ,pedroY\n");
    return M64ERR_SUCCESS;
}

EXPORT m64p_error CALL PluginShutdown(void) {
    return M64ERR_SUCCESS;
}

EXPORT m64p_error CALL PluginGetVersion(m64p_plugin_type *type, int *version,
                                        int *api_version, const char **name,
                                        int *capabilities) {
    if (type) *type = M64PLUGIN_INPUT;
    if (version) *version = 0x000100;
    if (api_version) *api_version = 0x020100;
    if (name) *name = "US Eyerok sleep-Pedro probe";
    if (capabilities) *capabilities = 0;
    return M64ERR_SUCCESS;
}

EXPORT void CALL InitiateControllers(CONTROL_INFO info) {
    int i;
    for (i = 0; i < 4; i++) {
        info.Controls[i].Present = (i == 0);
        info.Controls[i].RawData = 0;
        info.Controls[i].Plugin = PLUGIN_MEMPAK;
        info.Controls[i].Type = CONT_TYPE_STANDARD;
    }
}

EXPORT int CALL RomOpen(void) {
    gPoll = 0;
    gLastTimer = UINT32_MAX;
    gWarpToArea2 = 0;
    gStagedInstantWarp = 0;
    gPoseStaged = 0;
    gBoss = 0;
    gHand = 0;
    return 1;
}

EXPORT void CALL RomClosed(void) {}
EXPORT void CALL ControllerCommand(int control, unsigned char *command) {
    (void) control;
    (void) command;
}
EXPORT void CALL ReadController(int control, unsigned char *command) {
    (void) control;
    (void) command;
}
EXPORT void CALL SDL_KeyDown(int modifier, int key) {
    (void) modifier;
    (void) key;
}
EXPORT void CALL SDL_KeyUp(int modifier, int key) {
    (void) modifier;
    (void) key;
}
EXPORT void CALL RenderCallback(void) {}
EXPORT void CALL SendVRUWord(uint16_t length, uint16_t *word, uint8_t count) {
    (void) length;
    (void) word;
    (void) count;
}
EXPORT void CALL SetMicState(int state) {
    (void) state;
}
EXPORT void CALL ReadVRUResults(uint16_t *a, uint16_t *b, uint16_t *c,
                                uint16_t *d, uint16_t *e, uint16_t *f) {
    if (a) *a = 0;
    if (b) *b = 0;
    if (c) *c = 0;
    if (d) *d = 0;
    if (e) *e = 0;
    (void) f;
}
EXPORT void CALL ClearVRUWords(uint8_t length) {
    (void) length;
}
EXPORT void CALL SetVRUWordMask(uint8_t length, uint8_t *mask) {
    (void) length;
    (void) mask;
}

EXPORT void CALL GetKeys(int control, BUTTONS *keys) {
    unsigned long long slot;
    uint16_t area;
    uint32_t timer;

    memset(keys, 0, sizeof(*keys));
    if (control != 0) {
        return;
    }
    gPoll++;

    if (gPoll >= 150 && gPoll < 156) keys->START_BUTTON = 1;
    for (slot = 220; slot <= 280; slot += 10) {
        if (gPoll >= slot && gPoll < slot + 2) keys->D_DPAD = 1;
    }
    if (gPoll >= 330 && gPoll < 336) keys->START_BUTTON = 1;

    area = R16(A_CURR_AREA);
    if (!gWarpToArea2 && gPoll > 360 && area == 1 && R32(A_MARIO_OBJECT) != 0) {
        uint16_t level = R16(A_CURR_LEVEL);
        W8(A_WARP_DEST + 0, 2);
        W8(A_WARP_DEST + 1, (uint8_t) level);
        W8(A_WARP_DEST + 2, 2);
        W8(A_WARP_DEST + 3, 0x0a);
        W32(A_WARP_DEST + 4, 0);
        gWarpToArea2 = 1;
    }

    if (gWarpToArea2 && gStagedInstantWarp < 60 && area == 2
        && R32(A_MARIO_OBJECT) != 0) {
        put_mario(0.0f, 450.0f, -1320.0f, 0.0f);
        gStagedInstantWarp++;
    }

    if (area == 3 && !gPoseStaged) {
        find_sleep_objects();
        if (gBoss && gHand && rs32(gBoss + O_ACTION) == 0
            && rs32(gHand + O_ACTION) == 0
            && rfloat(gHand + O_HOME_Y) < -1000.0f
            && R32(gHand + O_COLLISION) != 0) {
            stage_pedro_entry();
            gPoseStaged = 1;
        }
    }

    timer = R32(A_GLOBAL_TIMER);
    if (gPoseStaged && timer != gLastTimer) {
        gLastTimer = timer;
        log_frame(timer);
    }
}
