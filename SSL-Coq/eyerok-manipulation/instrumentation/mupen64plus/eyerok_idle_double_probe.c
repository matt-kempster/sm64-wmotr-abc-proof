#define _GNU_SOURCE
#define M64P_PLUGIN_PROTOTYPES

#include <dlfcn.h>
#include <math.h>
#include <stdint.h>
#include <stdio.h>
#include <string.h>

#include <mupen64plus/m64p_common.h>
#include <mupen64plus/m64p_debugger.h>
#include <mupen64plus/m64p_plugin.h>

/*
 * Read/write instrumentation for the authentic North-American SM64 ROM.
 *
 * This is not a from-reset controller-only trace.  Inputs select SSL, then
 * transparent RAM setup changes areas and installs a source-reachable local
 * scheduler precondition.  It never writes positive hand velocity, hand
 * gravity, hand position, hand movement flags, or DOUBLE_POUND.
 */

enum {
    A_GLOBAL_TIMER   = 0x8032d5d4,
    A_CURR_LEVEL     = 0x8032ddf8,
    A_MARIO_STATES   = 0x8033b170,
    A_WARP_DEST      = 0x8033b248,
    A_SEGMENT_TABLE  = 0x8033b400,
    A_OBJECT_POOL    = 0x8033d488,
    A_MARIO_OBJECT   = 0x80361158,
    A_CURR_AREA      = 0x8033baca,
    A_MARIO_PLATFORM = 0x80330e34,
    OBJECT_SIZE      = 0x260,
    OBJECT_COUNT     = 240,
};

enum {
    O_PARENT       = 0x068,
    O_ACTIVE_FLAGS = 0x074,
    O_POS_X        = 0x0a0,
    O_POS_Y        = 0x0a4,
    O_POS_Z        = 0x0a8,
    O_VEL_Y        = 0x0b0,
    O_GRAVITY      = 0x0e4,
    O_FLOOR_HEIGHT = 0x0e8,
    O_MOVE_FLAGS   = 0x0ec,
    O_BOSS_HANDS   = 0x0f8,
    O_BOSS_ACTIVE  = 0x100,
    O_BOSS_104     = 0x104,
    O_BOSS_108     = 0x108,
    O_BOSS_110     = 0x110,
    O_SIDE         = 0x144,
    O_ACTION       = 0x14c,
    O_TIMER        = 0x154,
    O_HOME_X       = 0x164,
    O_HOME_Y       = 0x168,
    O_HOME_Z       = 0x16c,
    O_PREV_ACTION  = 0x18c,
    O_BOSS_1AC     = 0x1ac,
    O_FLOOR        = 0x1c0,
    O_BEHAVIOR     = 0x20c,
    O_COLLISION    = 0x218,
};

enum {
    HAND_SLEEP = 0,
    HAND_IDLE = 1,
    HAND_BEGIN_DOUBLE_POUND = 10,
    HAND_DOUBLE_POUND = 11,
};

typedef unsigned int (*read32_fn)(unsigned int);
typedef unsigned short (*read16_fn)(unsigned int);
typedef unsigned char (*read8_fn)(unsigned int);
typedef void (*write32_fn)(unsigned int, unsigned int);
typedef void (*write8_fn)(unsigned int, unsigned char);

static read32_fn R32;
static read16_fn R16;
static read8_fn R8;
static write32_fn W32;
static write8_fn W8;

static unsigned long long gPoll;
static uint32_t gLastTimer;
static uint32_t gBoss;
static uint32_t gHands[2];
static unsigned gWarpToArea2;
static unsigned gArea2StageFrames;
static unsigned gStagedIdle;
static unsigned gInjectedScheduler;
static unsigned gForbiddenRows;

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

static void find_eyerok_objects(void) {
    uint32_t bossBehavior = segment_virtual(0x13, 0x52b4);
    uint32_t handBehavior = segment_virtual(0x13, 0x52d0);
    unsigned found = 0;
    unsigned i;

    gBoss = 0;
    gHands[0] = 0;
    gHands[1] = 0;
    for (i = 0; i < OBJECT_COUNT; ++i) {
        uint32_t object = A_OBJECT_POOL + i * OBJECT_SIZE;
        if (R16(object + O_ACTIVE_FLAGS) == 0) {
            continue;
        }
        if (R32(object + O_BEHAVIOR) == bossBehavior) {
            gBoss = object;
        }
        if (R32(object + O_BEHAVIOR) == handBehavior && found < 2) {
            gHands[found++] = object;
        }
    }
}

static int hand_has_genuine_initialization(uint32_t hand) {
    float posY = rfloat(hand + O_POS_Y);
    float homeY = rfloat(hand + O_HOME_Y);
    return hand != 0
        && fabsf(homeY + 1534.0f) < 0.01f
        && fabsf(posY - homeY) < 0.01f
        && fabsf(rfloat(hand + O_VEL_Y)) < 0.01f
        && fabsf(rfloat(hand + O_GRAVITY)) < 0.01f
        && R32(hand + O_COLLISION) != 0
        && rs32(hand + O_ACTION) == HAND_SLEEP;
}

static int hand_has_genuine_floor(uint32_t hand) {
    float floorHeight = rfloat(hand + O_FLOOR_HEIGHT);
    return hand != 0
        && R32(hand + O_FLOOR) != 0
        && floorHeight > -1540.0f
        && floorHeight < -1528.0f
        && fabsf(rfloat(hand + O_POS_Y) + 1534.0f) < 0.01f
        && fabsf(rfloat(hand + O_VEL_Y)) < 0.01f
        && fabsf(rfloat(hand + O_GRAVITY)) < 0.01f
        && R32(hand + O_COLLISION) != 0
        && rs32(hand + O_ACTION) == HAND_IDLE;
}

static void put_mario_above_real_area2_instant_warp(void) {
    uint32_t marioObject = R32(A_MARIO_OBJECT);
    const float x = 0.0f;
    const float y = 450.0f;
    const float z = -1320.0f;

    W32(A_MARIO_STATES + 0x3c, fbits(x));
    W32(A_MARIO_STATES + 0x40, fbits(y));
    W32(A_MARIO_STATES + 0x44, fbits(z));
    W32(A_MARIO_STATES + 0x48, fbits(0.0f));
    W32(A_MARIO_STATES + 0x4c, fbits(0.0f));
    W32(A_MARIO_STATES + 0x50, fbits(0.0f));
    if (marioObject != 0) {
        W32(marioObject + O_POS_X, fbits(x));
        W32(marioObject + O_POS_Y, fbits(y));
        W32(marioObject + O_POS_Z, fbits(z));
        W32(marioObject + O_VEL_Y, fbits(0.0f));
    }
}

static void write_area2_warp_request(void) {
    uint16_t level = R16(A_CURR_LEVEL);
    W8(A_WARP_DEST + 0, 2);
    W8(A_WARP_DEST + 1, (uint8_t) level);
    W8(A_WARP_DEST + 2, 2);
    W8(A_WARP_DEST + 3, 0x0a);
    W32(A_WARP_DEST + 4, 0);
    fprintf(stderr,
            "FIXTURE area1_to_area2 writes=sWarpDest{type=2,level=%u,area=2,node=0x0a,arg=0}\n",
            level);
}

static void stage_idle_actions_only(void) {
    /*
     * The source state is initialized SLEEP at home with zero velocity and
     * gravity and a real collision pointer.  Only oAction is changed.  The
     * ordinary object loop then resets timer/prevAction, queries the real
     * arena floor, and performs ordinary movement.
     */
    W32(gHands[0] + O_ACTION, HAND_IDLE);
    W32(gHands[1] + O_ACTION, HAND_IDLE);
    fprintf(stderr,
            "FIXTURE initialized_sleep_to_idle writes=hand[0].action=1,hand[1].action=1 "
            "untouched=posY,velY,gravity,moveFlags,floor,collision,timer,prevAction\n");
}

static void inject_scheduler_precondition(void) {
    /*
     * Source-reachable local scheduler state: fight active, two live hands,
     * neither lock held, and negative double-pound phase.  Hand physics and
     * hand actions are untouched here.
     */
    W32(gBoss + O_ACTION, 3);
    W32(gBoss + O_BOSS_HANDS, 2);
    W32(gBoss + O_BOSS_ACTIVE, 0);
    W32(gBoss + O_BOSS_104, (uint32_t) -8);
    W32(gBoss + O_BOSS_108, fbits(0.0f));
    W32(gBoss + O_BOSS_110, fbits(1.0f));
    W32(gBoss + O_BOSS_1AC, 0);
    fprintf(stderr,
            "FIXTURE scheduler writes=boss{action=3,numHands=2,activeHand=0,"
            "unk104=-8,unk108=0,unk110=1,unk1AC=0} "
            "untouched=all_hand_physics,all_hand_actions\n");
}

static void print_csv_header(void) {
    fprintf(stderr,
            "CSV,poll,timer,area,boss,bossAction,bossTimer,numHands,activeHand,"
            "unk104,unk1AC,mAction,mActionTimer,mY,mVelY,mFloor,mFloorType,"
            "mFloorHeight,mPlatform,handIndex,hand,side,action,actionTimer,posY,"
            "velY,gravity,moveFlags,floor,floorType,floorHeight,collision,"
            "activeFlags,groundCollision,moveSkipped\n");
}

static void log_frame(uint32_t timer) {
    uint32_t marioFloor = R32(A_MARIO_STATES + 0x68);
    unsigned i;
    for (i = 0; i < 2; ++i) {
        uint32_t hand = gHands[i];
        uint32_t moveFlags;
        uint16_t activeFlags;
        int action;
        float velY;
        float gravity;
        if (hand == 0) {
            continue;
        }
        moveFlags = R32(hand + O_MOVE_FLAGS);
        activeFlags = R16(hand + O_ACTIVE_FLAGS);
        action = rs32(hand + O_ACTION);
        velY = rfloat(hand + O_VEL_Y);
        gravity = rfloat(hand + O_GRAVITY);
        if (action == HAND_DOUBLE_POUND && velY > 0.0f && fabsf(gravity) < 0.0001f
            && (activeFlags & 0x000aU) == 0) {
            ++gForbiddenRows;
        }
        fprintf(stderr,
                "CSV,%llu,%u,%u,%08x,%d,%d,%d,%d,%d,%d,%08x,%u,%.3f,%.3f,"
                "%08x,%04x,%.3f,%08x,%u,%08x,%d,%d,%d,%.3f,%.3f,%.3f,%08x,"
                "%08x,%04x,%.3f,%08x,%04x,%d,%d\n",
                gPoll, timer, R16(A_CURR_AREA), gBoss,
                gBoss ? rs32(gBoss + O_ACTION) : -1,
                gBoss ? rs32(gBoss + O_TIMER) : -1,
                gBoss ? rs32(gBoss + O_BOSS_HANDS) : -1,
                gBoss ? rs32(gBoss + O_BOSS_ACTIVE) : -1,
                gBoss ? rs32(gBoss + O_BOSS_104) : -1,
                gBoss ? rs32(gBoss + O_BOSS_1AC) : -1,
                R32(A_MARIO_STATES + 0x0c), R16(A_MARIO_STATES + 0x1a),
                rfloat(A_MARIO_STATES + 0x40), rfloat(A_MARIO_STATES + 0x4c),
                marioFloor, marioFloor ? R16(marioFloor) : 0,
                rfloat(A_MARIO_STATES + 0x70), R32(A_MARIO_PLATFORM),
                i, hand, rs32(hand + O_SIDE), action, rs32(hand + O_TIMER),
                rfloat(hand + O_POS_Y), velY, gravity, moveFlags,
                R32(hand + O_FLOOR),
                R32(hand + O_FLOOR) ? R16(R32(hand + O_FLOOR)) : 0,
                rfloat(hand + O_FLOOR_HEIGHT), R32(hand + O_COLLISION),
                activeFlags, !!(moveFlags & 3U), !!(activeFlags & 0x000aU));
    }
}

EXPORT m64p_error CALL PluginStartup(m64p_dynlib_handle core, void *context,
                                      void (*debug_callback)(void *, int, const char *)) {
    (void) context;
    (void) debug_callback;
    R32 = (read32_fn) dlsym(core, "DebugMemRead32");
    R16 = (read16_fn) dlsym(core, "DebugMemRead16");
    R8 = (read8_fn) dlsym(core, "DebugMemRead8");
    W32 = (write32_fn) dlsym(core, "DebugMemWrite32");
    W8 = (write8_fn) dlsym(core, "DebugMemWrite8");
    if (!R32 || !R16 || !R8 || !W32 || !W8) {
        return M64ERR_INCOMPATIBLE;
    }
    print_csv_header();
    return M64ERR_SUCCESS;
}

EXPORT m64p_error CALL PluginShutdown(void) {
    return M64ERR_SUCCESS;
}

EXPORT m64p_error CALL PluginGetVersion(m64p_plugin_type *type, int *version,
                                         int *apiVersion, const char **name,
                                         int *capabilities) {
    if (type) *type = M64PLUGIN_INPUT;
    if (version) *version = 0x000100;
    if (apiVersion) *apiVersion = 0x020100;
    if (name) *name = "US Eyerok IDLE-to-double probe";
    if (capabilities) *capabilities = 0;
    return M64ERR_SUCCESS;
}

EXPORT void CALL InitiateControllers(CONTROL_INFO info) {
    int i;
    for (i = 0; i < 4; ++i) {
        info.Controls[i].Present = (i == 0);
        info.Controls[i].RawData = 0;
        info.Controls[i].Plugin = PLUGIN_NONE;
        info.Controls[i].Type = CONT_TYPE_STANDARD;
    }
}

EXPORT int CALL RomOpen(void) {
    gPoll = 0;
    gLastTimer = UINT32_MAX;
    gBoss = 0;
    gHands[0] = 0;
    gHands[1] = 0;
    gWarpToArea2 = 0;
    gArea2StageFrames = 0;
    gStagedIdle = 0;
    gInjectedScheduler = 0;
    gForbiddenRows = 0;
    return 1;
}

EXPORT void CALL RomClosed(void) {
    fprintf(stderr,
            "VERDICT double_pound_airborne_gravity_zero_positive_velocity_rows=%u\n",
            gForbiddenRows);
}

EXPORT void CALL GetKeys(int control, BUTTONS *keys) {
    unsigned long long slot;
    uint16_t area;
    uint32_t timer;

    memset(keys, 0, sizeof(*keys));
    if (control != 0) {
        return;
    }
    ++gPoll;

    /* Controller-only navigation through the debug level-select menu to SSL. */
    if (gPoll >= 150 && gPoll < 156) keys->START_BUTTON = 1;
    for (slot = 220; slot <= 280; slot += 10) {
        if (gPoll >= slot && gPoll < slot + 2) keys->D_DPAD = 1;
    }
    if (gPoll >= 330 && gPoll < 336) keys->START_BUTTON = 1;

    area = R16(A_CURR_AREA);
    if (!gWarpToArea2 && gPoll > 360 && area == 1 && R32(A_MARIO_OBJECT) != 0) {
        write_area2_warp_request();
        gWarpToArea2 = 1;
    }

    if (gWarpToArea2 && area == 2 && R32(A_MARIO_OBJECT) != 0
        && gArea2StageFrames < 60) {
        put_mario_above_real_area2_instant_warp();
        ++gArea2StageFrames;
        if (gArea2StageFrames == 1) {
            fprintf(stderr,
                    "FIXTURE area2_instant_warp writes=MarioState{pos=(0,450,-1320),"
                    "vel=(0,0,0)},MarioObject{pos=(0,450,-1320),velY=0}; "
                    "selection=real_SURFACE_INSTANT_WARP_1D\n");
        }
    }

    if (area == 3) {
        find_eyerok_objects();
        if (!gStagedIdle && gBoss
            && hand_has_genuine_initialization(gHands[0])
            && hand_has_genuine_initialization(gHands[1])) {
            fprintf(stderr,
                    "VALIDATED initialized hands boss=%08x hand0=%08x hand1=%08x "
                    "homeY=-1534,posY=homeY,velY=0,gravity=0,collision=nonnull\n",
                    gBoss, gHands[0], gHands[1]);
            stage_idle_actions_only();
            gStagedIdle = 1;
        } else if (!gInjectedScheduler && gStagedIdle && gBoss
                   && hand_has_genuine_floor(gHands[0])
                   && hand_has_genuine_floor(gHands[1])) {
            fprintf(stderr,
                    "VALIDATED ordinary IDLE update floor0=%08x floor1=%08x "
                    "floorHeight0=%.3f floorHeight1=%.3f "
                    "posY=-1534,velY=0,gravity=0,collision=nonnull\n",
                    R32(gHands[0] + O_FLOOR), R32(gHands[1] + O_FLOOR),
                    rfloat(gHands[0] + O_FLOOR_HEIGHT),
                    rfloat(gHands[1] + O_FLOOR_HEIGHT));
            inject_scheduler_precondition();
            gInjectedScheduler = 1;
        }
    }

    timer = R32(A_GLOBAL_TIMER);
    if (gStagedIdle && timer != gLastTimer) {
        gLastTimer = timer;
        log_frame(timer);
    }
}

EXPORT void CALL ControllerCommand(int control, unsigned char *command) {
    (void) control;
    (void) command;
}

EXPORT void CALL ReadController(int control, unsigned char *command) {
    (void) control;
    (void) command;
}

EXPORT void CALL SDL_KeyDown(int keymod, int keysym) {
    (void) keymod;
    (void) keysym;
}

EXPORT void CALL SDL_KeyUp(int keymod, int keysym) {
    (void) keymod;
    (void) keysym;
}
