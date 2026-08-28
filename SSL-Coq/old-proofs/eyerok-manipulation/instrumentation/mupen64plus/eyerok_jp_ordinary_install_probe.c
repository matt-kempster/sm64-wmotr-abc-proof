#define _GNU_SOURCE
#define M64P_PLUGIN_PROTOTYPES
#include <mupen64plus/m64p_common.h>
#include <mupen64plus/m64p_debugger.h>
#include <mupen64plus/m64p_plugin.h>
#include <dlfcn.h>
#include <stdint.h>
#include <stdio.h>
#include <string.h>

#ifndef INSTALL_CASE
#define INSTALL_CASE 1
#endif

#ifndef HAND_SIDE
#define HAND_SIDE 1
#endif

#if INSTALL_CASE < 1 || INSTALL_CASE > 2
#error INSTALL_CASE must be 1 (fist push) or 2 (one-hand show-eye)
#endif

#if HAND_SIDE != -1 && HAND_SIDE != 1
#error HAND_SIDE must be -1 or 1
#endif

#if INSTALL_CASE == 1
#define INSTALL_NAME "fist_push"
#else
#define INSTALL_NAME "one_hand_show_eye"
#endif

/* Matching original-JP addresses from the byte-identical pinned build used by
 * the stale-platform probe. */
enum {
    A_GLOBAL_TIMER = 0x8032c694,
    A_CURR_LEVEL = 0x8032ce98,
    A_MARIO_STATES = 0x80339e00,
    A_WARP_DEST = 0x80339ed8,
    A_SEGMENT_TABLE = 0x8033a090,
    A_CURR_AREA = 0x8033a75a,
    A_OBJECT_POOL = 0x8033c118,
    A_MARIO_OBJECT = 0x8035fde8,
    OBJECT_SIZE = 0x260,
    OBJECT_COUNT = 240,
};

enum {
    O_ACTIVE_FLAGS = 0x074,
    O_POS_X = 0x0a0,
    O_POS_Y = 0x0a4,
    O_POS_Z = 0x0a8,
    O_VEL_X = 0x0ac,
    O_VEL_Y = 0x0b0,
    O_VEL_Z = 0x0b4,
    O_FORWARD_VEL = 0x0b8,
    O_MOVE_YAW = 0x0c8,
    O_FACE_YAW = 0x0d4,
    O_GRAVITY = 0x0e4,
    O_FLOOR_HEIGHT = 0x0e8,
    O_MOVE_FLAGS = 0x0ec,
    O_NUM_HANDS = 0x0f8,
    O_ACTIVE_HAND = 0x100,
    O_UNK104 = 0x104,
    O_SIDE = 0x144,
    O_ACTION = 0x14c,
    O_TIMER = 0x154,
    O_ANGLE_TO_MARIO = 0x160,
    O_HOME_Y = 0x168,
    O_UNK1AC = 0x1ac,
    O_FLOOR = 0x1c0,
    O_BEHAVIOR = 0x20c,
    O_COLLISION = 0x218,
};

enum {
    ACT_IDLE = 0x0c400201U,
    EYEROK_BOSS_WAKE_UP = 1,
    EYEROK_BOSS_FIGHT = 3,
    EYEROK_HAND_IDLE = 1,
    EYEROK_HAND_FIST_PUSH = 8,
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
static int gStagedArea2Tunnel;
static int gPhase;
static uint32_t gBoss;
static uint32_t gHand;

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

static int16_t rs16(uint32_t address) {
    return (int16_t) R16(address);
}

static uint32_t segment_virtual(unsigned segment, uint32_t offset) {
    uint32_t base = R32(A_SEGMENT_TABLE + segment * 4) & 0x1fffffffU;
    return 0x80000000U | (base + offset);
}

static uint32_t surface_object(uint32_t surface) {
    return surface != 0 ? R32(surface + 0x2c) : 0;
}

static int surface_type(uint32_t surface) {
    return surface != 0 ? rs16(surface) : -1;
}

static void put_mario(float x, float y, float z) {
    uint32_t mario = R32(A_MARIO_OBJECT);

    W32(A_MARIO_STATES + 0x3c, fbits(x));
    W32(A_MARIO_STATES + 0x40, fbits(y));
    W32(A_MARIO_STATES + 0x44, fbits(z));
    W32(A_MARIO_STATES + 0x48, 0);
    W32(A_MARIO_STATES + 0x4c, 0);
    W32(A_MARIO_STATES + 0x50, 0);
    W32(A_MARIO_STATES + 0x54, 0);
    W32(A_MARIO_STATES + 0x0c, ACT_IDLE);
    W32(A_MARIO_STATES + 0x10, ACT_IDLE);
    W16(A_MARIO_STATES + 0x18, 0);
    W16(A_MARIO_STATES + 0x1a, 0);
    W32(A_MARIO_STATES + 0x1c, 0);
    W32(A_MARIO_STATES + 0x20, 0);
    if (mario != 0) {
        W32(mario + O_POS_X, fbits(x));
        W32(mario + O_POS_Y, fbits(y));
        W32(mario + O_POS_Z, fbits(z));
        W32(mario + O_VEL_X, 0);
        W32(mario + O_VEL_Y, 0);
        W32(mario + O_VEL_Z, 0);
    }
}

static void find_eyerok_objects(void) {
    uint32_t hand_behavior = segment_virtual(0x13, 0x52b0);
    uint32_t boss_behavior = segment_virtual(0x13, 0x5294);
    unsigned i;

    gBoss = 0;
    gHand = 0;
    for (i = 0; i < OBJECT_COUNT; i++) {
        uint32_t object = A_OBJECT_POOL + i * OBJECT_SIZE;
        if (R16(object + O_ACTIVE_FLAGS) == 0) continue;
        if (R32(object + O_BEHAVIOR) == boss_behavior) gBoss = object;
        if (R32(object + O_BEHAVIOR) == hand_behavior
            && rs32(object + O_SIDE) == HAND_SIDE) {
            gHand = object;
        }
    }
}

static void log_frame(uint32_t timer) {
    uint32_t floor = gHand ? R32(gHand + O_FLOOR) : 0;

    fprintf(stderr,
            "INSTALL_FRAME,case=%s,side=%d,poll=%llu,timer=%u,phase=%d,"
            "boss=%08x,bossAction=%d,numHands=%d,activeHand=%d,"
            "hand=%08x,handAction=%d,handTimer=%d,"
            "pos=(%.6f,%.6f,%.6f),vel=(%.6f,%.6f,%.6f),"
            "forwardVel=%.6f,moveYaw=%d,faceYaw=%d,angleToMario=%d,"
            "gravity=%.6f,moveFlags=%08x,floor=%08x,floorType=%d,"
            "floorObject=%08x,floorHeight=%.6f,collision=%08x,"
            "mario=(%.6f,%.6f,%.6f)\n",
            INSTALL_NAME, HAND_SIDE, gPoll, timer, gPhase,
            gBoss, gBoss ? rs32(gBoss + O_ACTION) : -1,
            gBoss ? rs32(gBoss + O_NUM_HANDS) : -1,
            gBoss ? rs32(gBoss + O_ACTIVE_HAND) : -2,
            gHand, gHand ? rs32(gHand + O_ACTION) : -1,
            gHand ? rs32(gHand + O_TIMER) : -1,
            gHand ? rfloat(gHand + O_POS_X) : 0.0f,
            gHand ? rfloat(gHand + O_POS_Y) : 0.0f,
            gHand ? rfloat(gHand + O_POS_Z) : 0.0f,
            gHand ? rfloat(gHand + O_VEL_X) : 0.0f,
            gHand ? rfloat(gHand + O_VEL_Y) : 0.0f,
            gHand ? rfloat(gHand + O_VEL_Z) : 0.0f,
            gHand ? rfloat(gHand + O_FORWARD_VEL) : 0.0f,
            gHand ? rs32(gHand + O_MOVE_YAW) : 0,
            gHand ? rs32(gHand + O_FACE_YAW) : 0,
            gHand ? rs32(gHand + O_ANGLE_TO_MARIO) : 0,
            gHand ? rfloat(gHand + O_GRAVITY) : 0.0f,
            gHand ? R32(gHand + O_MOVE_FLAGS) : 0,
            floor, surface_type(floor), surface_object(floor),
            gHand ? rfloat(gHand + O_FLOOR_HEIGHT) : 0.0f,
            gHand ? R32(gHand + O_COLLISION) : 0,
            rfloat(A_MARIO_STATES + 0x3c),
            rfloat(A_MARIO_STATES + 0x40),
            rfloat(A_MARIO_STATES + 0x44));
}

static void stage_action(void) {
    W32(gBoss + O_ACTION, EYEROK_BOSS_FIGHT);
    W32(gBoss + O_UNK104, 0);
    W32(gBoss + O_UNK1AC, 0);
#if INSTALL_CASE == 1
    int32_t move_yaw;

    W32(gBoss + O_NUM_HANDS, 2);
    W32(gBoss + O_ACTIVE_HAND, (uint32_t) HAND_SIDE);
    move_yaw = rs32(gHand + O_ANGLE_TO_MARIO) + 0x800;
    W32(gHand + O_ACTION, EYEROK_HAND_FIST_PUSH);
    W32(gHand + O_MOVE_YAW, (uint32_t) move_yaw);
    W32(gHand + O_FORWARD_VEL, 0);
    W32(gHand + O_GRAVITY, fbits(-4.0f));
    fprintf(stderr,
            "INSTALL_FIXTURE,case=%s,side=%d,writes=boss_fight_fields+"
            "hand_action_8+source_transition_moveYaw_gravity_forwardVel,"
            "angleToMario=%d,moveYaw=%d,target=(0,700,-900),"
            "scope=conditional_action_body_not_controller_reachability\n",
            INSTALL_NAME, HAND_SIDE, rs32(gHand + O_ANGLE_TO_MARIO), move_yaw);
#else
    W32(gBoss + O_NUM_HANDS, 1);
    W32(gBoss + O_ACTIVE_HAND, (uint32_t) -HAND_SIDE);
    fprintf(stderr,
            "INSTALL_FIXTURE,case=%s,side=%d,writes=boss_fight_fields+"
            "one_hand_count+opposite_active_side,no_hand_action_or_motion_write,"
            "target=(0,700,-900),scope=conditional_scheduler_not_controller_reachability\n",
            INSTALL_NAME, HAND_SIDE);
#endif
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
    return M64ERR_SUCCESS;
}

EXPORT m64p_error CALL PluginShutdown(void) { return M64ERR_SUCCESS; }

EXPORT m64p_error CALL PluginGetVersion(m64p_plugin_type *type, int *version,
                                        int *api_version, const char **name,
                                        int *capabilities) {
    if (type) *type = M64PLUGIN_INPUT;
    if (version) *version = 0x000100;
    if (api_version) *api_version = 0x020100;
    if (name) *name = "JP Eyerok ordinary-install probe";
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
    gStagedArea2Tunnel = 0;
    gPhase = 0;
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
EXPORT void CALL SetMicState(int state) { (void) state; }
EXPORT void CALL ReadVRUResults(uint16_t *a, uint16_t *b, uint16_t *c,
                                uint16_t *d, uint16_t *e, uint16_t *f) {
    if (a) *a = 0;
    if (b) *b = 0;
    if (c) *c = 0;
    if (d) *d = 0;
    if (e) *e = 0;
    (void) f;
}
EXPORT void CALL ClearVRUWords(uint8_t length) { (void) length; }
EXPORT void CALL SetVRUWordMask(uint8_t length, uint8_t *mask) {
    (void) length;
    (void) mask;
}

EXPORT void CALL GetKeys(int control, BUTTONS *keys) {
    unsigned long long slot;
    uint16_t area;
    uint32_t timer;

    memset(keys, 0, sizeof(*keys));
    if (control != 0) return;
    gPoll++;

    if (gPoll >= 150 && gPoll < 156) keys->START_BUTTON = 1;
    for (slot = 220; slot <= 280; slot += 10) {
        if (gPoll >= slot && gPoll < slot + 2) keys->D_DPAD = 1;
    }
    if (gPoll >= 330 && gPoll < 336) keys->START_BUTTON = 1;

    area = R16(A_CURR_AREA);
    if (!gWarpToArea2 && gPoll > 360 && area == 1
        && R32(A_MARIO_OBJECT) != 0) {
        uint16_t level = R16(A_CURR_LEVEL);
        W8(A_WARP_DEST + 0, 2);
        W8(A_WARP_DEST + 1, (uint8_t) level);
        W8(A_WARP_DEST + 2, 2);
        W8(A_WARP_DEST + 3, 0x0a);
        W32(A_WARP_DEST + 4, 0);
        gWarpToArea2 = 1;
    }

    if (gWarpToArea2 && gStagedArea2Tunnel < 60 && area == 2
        && R32(A_MARIO_OBJECT) != 0) {
        put_mario(0.0f, 450.0f, -1320.0f);
        gStagedArea2Tunnel++;
    }

    if (area == 3) {
        find_eyerok_objects();
        if (gPhase == 0 && gBoss && gHand
            && rs32(gBoss + O_ACTION) == 0
            && rs32(gHand + O_ACTION) == 0
            && rfloat(gHand + O_HOME_Y) < -1000.0f
            && R32(gHand + O_COLLISION) != 0) {
            W32(gBoss + O_ACTION, EYEROK_BOSS_WAKE_UP);
            gPhase = 1;
            fprintf(stderr,
                    "INSTALL_WAKE_FIXTURE,case=%s,side=%d,writes=boss_action_1_only,"
                    "hand_wake_and_closed_collision=retail\n",
                    INSTALL_NAME, HAND_SIDE);
        }

        if (gPhase == 1) {
            put_mario(0.0f, -1400.0f, -2500.0f);
            if (gBoss && gHand && rs32(gHand + O_ACTION) == EYEROK_HAND_IDLE
                && rs32(gBoss + O_NUM_HANDS) == 2) {
                put_mario(0.0f, 700.0f, -900.0f);
                gPhase = 2;
            }
        } else if (gPhase == 2) {
            put_mario(0.0f, 700.0f, -900.0f);
            stage_action();
            gPhase = 3;
        } else if (gPhase >= 3) {
            put_mario(0.0f, 700.0f, -900.0f);
        }
    }

    timer = R32(A_GLOBAL_TIMER);
    if (gPhase >= 2 && timer != gLastTimer) {
        gLastTimer = timer;
        log_frame(timer);
    }
}
