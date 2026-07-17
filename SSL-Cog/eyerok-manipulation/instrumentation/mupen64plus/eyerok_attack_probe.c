#define _GNU_SOURCE
#define M64P_PLUGIN_PROTOTYPES
#include <mupen64plus/m64p_common.h>
#include <mupen64plus/m64p_plugin.h>
#include <mupen64plus/m64p_debugger.h>
#include <dlfcn.h>
#include <math.h>
#include <stdint.h>
#include <stdio.h>
#include <string.h>

#ifndef ATTACK_SCENARIO
#define ATTACK_SCENARIO 0
#endif

#ifndef STEER_X
#define STEER_X 0
#endif

#ifndef STEER_Y
#define STEER_Y 0
#endif

#ifndef STEER_LABEL
#define STEER_LABEL "none"
#endif

#ifndef STEER_SWITCH_RELATIVE_POLL
#define STEER_SWITCH_RELATIVE_POLL 0
#endif

#ifndef STEER_AFTER_X
#define STEER_AFTER_X STEER_X
#endif

#ifndef STEER_AFTER_Y
#define STEER_AFTER_Y STEER_Y
#endif

#if ATTACK_SCENARIO < 0 || ATTACK_SCENARIO > 3
#error ATTACK_SCENARIO must be 0/1 (nonlethal/lethal long jump) or 2/3 (nonlethal/lethal slide kick)
#endif

#if STEER_X < -127 || STEER_X > 127 || STEER_Y < -127 || STEER_Y > 127
#error steering axes must be in [-127, 127]
#endif

#if STEER_AFTER_X < -127 || STEER_AFTER_X > 127 || STEER_AFTER_Y < -127 || STEER_AFTER_Y > 127
#error post-switch steering axes must be in [-127, 127]
#endif

#if STEER_SWITCH_RELATIVE_POLL < 0
#error steering switch poll must be nonnegative
#endif

#if ATTACK_SCENARIO == 0
#define SCENARIO_NAME "nonlethal_long_jump5"
#define MARIO_ACTION 0x03000888U
#define MARIO_ACTION_TIMER 0
#elif ATTACK_SCENARIO == 1
#define SCENARIO_NAME "lethal_long_jump5"
#define MARIO_ACTION 0x03000888U
#define MARIO_ACTION_TIMER 0
#elif ATTACK_SCENARIO == 2
#define SCENARIO_NAME "nonlethal_slide_kick5"
#define MARIO_ACTION 0x018008aaU
#define MARIO_ACTION_TIMER 7
#else
#define SCENARIO_NAME "lethal_slide_kick5"
#define MARIO_ACTION 0x018008aaU
#define MARIO_ACTION_TIMER 7
#endif

/* Authentic US ROM / matching source symbols (36fbf8d6 checkout). */
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
    O_ACTIVE_FLAGS    = 0x074,
    O_POS_X           = 0x0a0,
    O_POS_Y           = 0x0a4,
    O_POS_Z           = 0x0a8,
    O_VEL_Y           = 0x0b0,
    O_FORWARD_VEL     = 0x0b8,
    O_FACE_YAW        = 0x0d4,
    O_GRAVITY         = 0x0e4,
    O_FLOOR_HEIGHT    = 0x0e8,
    O_MOVE_FLAGS      = 0x0ec,
    O_RECEIVED_ATTACK = 0x0f8,
    O_BOSS_HANDS      = 0x0f8,
    O_BOSS_ACTIVE     = 0x100,
    O_BOSS_104        = 0x104,
    O_BOSS_108        = 0x108,
    O_BOSS_110        = 0x110,
    O_INTERACT_STATUS = 0x134,
    O_SIDE            = 0x144,
    O_ACTION          = 0x14c,
    O_TIMER           = 0x154,
    O_ANGLE_TO_MARIO  = 0x160,
    O_HOME_Y          = 0x168,
    O_HEALTH          = 0x184,
    O_PREV_ACTION     = 0x18c,
    O_BOSS_1AC        = 0x1ac,
    O_FLOOR           = 0x1c0,
    O_BEHAVIOR        = 0x20c,
    O_COLLISION       = 0x218,
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
static uint32_t gLastTimer = UINT32_MAX;
static int gWarpToArea2;
static int gStagedInstantWarp;
static int gPreparedIdle;
static int gInjectedFight;
static int gAttackPoseStaged;
static unsigned long long gPosePoll;
static uint32_t gBoss;
static uint32_t gHands[2];
static uint32_t gTarget;

static uint32_t fbits(float value) {
    union { float f; uint32_t u; } bits;
    bits.f = value;
    return bits.u;
}

static float rfloat(uint32_t address) {
    union { float f; uint32_t u; } bits;
    bits.u = R32(address);
    return bits.f;
}

static int32_t rs32(uint32_t address) { return (int32_t) R32(address); }

static uint32_t segment_virtual(unsigned segment, uint32_t offset) {
    uint32_t base = R32(A_SEGMENT_TABLE + segment * 4) & 0x1fffffffU;
    return 0x80000000U | (base + offset);
}

static void find_eyerok_objects(void) {
    uint32_t hand_behavior = segment_virtual(0x13, 0x52d0);
    uint32_t boss_behavior = segment_virtual(0x13, 0x52b4);
    int found = 0;
    unsigned i;

    gBoss = 0;
    gHands[0] = gHands[1] = 0;
    for (i = 0; i < OBJECT_COUNT; i++) {
        uint32_t object = A_OBJECT_POOL + i * OBJECT_SIZE;
        if (R16(object + O_ACTIVE_FLAGS) == 0) continue;
        if (R32(object + O_BEHAVIOR) == boss_behavior) gBoss = object;
        if (R32(object + O_BEHAVIOR) == hand_behavior && found < 2) {
            gHands[found++] = object;
        }
    }
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

static void stage_attack_pose(uint32_t hand) {
    const float tau = 6.2831853071795864769f;
    int32_t hand_face = rs32(hand + O_FACE_YAW);
    float angle = (float) ((int16_t) hand_face) * tau / 65536.0f;
    float x = rfloat(hand + O_POS_X) + sinf(angle) * 100.0f;
    float z = rfloat(hand + O_POS_Z) + cosf(angle) * 100.0f;
    float y = rfloat(hand + O_POS_Y) + 100.0f;

    /* This is the deliberately local Mario fixture. It is not reached by the
       controller script. All subsequent interaction, action, gravity, hand
       movement, collision loading, floor selection, and deletion are retail. */
    put_mario(x, y, z, -2.0f);
    W32(A_MARIO_STATES + 0x0c, MARIO_ACTION);
    W32(A_MARIO_STATES + 0x10, MARIO_ACTION);
    W16(A_MARIO_STATES + 0x18, 0);
    W16(A_MARIO_STATES + 0x1a, MARIO_ACTION_TIMER);
    W32(A_MARIO_STATES + 0x1c, 0);
    W32(A_MARIO_STATES + 0x20, 0);
    W32(A_MARIO_STATES + 0x54, fbits(5.0f));
    W32(A_MARIO_STATES + 0x58, 0);
    W32(A_MARIO_STATES + 0x5c, 0);
    W16(A_MARIO_STATES + 0x2e, (uint16_t) (hand_face + 0x8000));
    W8(A_MARIO_STATES + 0xb4, 0);             /* squishTimer */
    W32(A_MARIO_STATES + 0xc0, fbits(0.0f)); /* quicksandDepth */

    fprintf(stderr,
            "ATTACK_POSE scenario=%s hand=%08x x=%.3f y=%.3f z=%.3f "
            "handFace=%d marioFace=%d action=%08x actionTimer=%d "
            "velY=-2.000 forwardVel=5.000 A=up B=up "
            "squishTimer=0 quicksandDepth=0.000 "
            "steerLabel=%s steer=(%d,%d) afterFirstWallFrame=true\n",
            SCENARIO_NAME, hand, x, y, z, hand_face,
            (int16_t) (hand_face + 0x8000), MARIO_ACTION,
            MARIO_ACTION_TIMER, STEER_LABEL, STEER_X, STEER_Y);
}

static void csv_header(void) {
    fprintf(stderr,
        "CSV,poll,timer,scenario,area,boss,bossAction,bossTimer,numHands,activeHand,unk104,unk1AC,"
        "mAction,mActionTimer,mX,mY,mZ,mVelY,mForwardVel,mWall,mFloor,mFloorObject,mFloorHeight,mPlatform,mInput,mFlags,"
        "mSquishTimer,mQuicksandDepth,"
        "handIndex,hand,side,action,prevAction,actionTimer,health,received,interactStatus,angleToMario,faceYaw,"
        "posX,posY,posZ,velY,gravity,forwardVel,moveFlags,floor,floorHeight,collision,activeFlags,groundCollision\n");
}

static void log_frame(uint32_t timer) {
    uint32_t mario_floor = R32(A_MARIO_STATES + 0x68);
    unsigned i;

    for (i = 0; i < 2; i++) {
        uint32_t hand = gHands[i];
        uint32_t move_flags;
        if (hand == 0) continue;
        move_flags = R32(hand + O_MOVE_FLAGS);
        fprintf(stderr,
            "CSV,%llu,%u,%s,%u,%08x,%d,%d,%d,%d,%d,%d,"
            "%08x,%u,%.3f,%.3f,%.3f,%.3f,%.3f,%08x,%08x,%08x,%.3f,%08x,%04x,%08x,"
            "%u,%.3f,"
            "%u,%08x,%d,%d,%d,%d,%d,%d,%08x,%d,%d,"
            "%.3f,%.3f,%.3f,%.3f,%.3f,%.3f,%08x,%08x,%.3f,%08x,%04x,%d\n",
            gPoll, timer, SCENARIO_NAME, R16(A_CURR_AREA), gBoss,
            gBoss ? rs32(gBoss + O_ACTION) : -1,
            gBoss ? rs32(gBoss + O_TIMER) : -1,
            gBoss ? rs32(gBoss + O_BOSS_HANDS) : -1,
            gBoss ? rs32(gBoss + O_BOSS_ACTIVE) : -1,
            gBoss ? rs32(gBoss + O_BOSS_104) : -1,
            gBoss ? rs32(gBoss + O_BOSS_1AC) : -1,
            R32(A_MARIO_STATES + 0x0c), R16(A_MARIO_STATES + 0x1a),
            rfloat(A_MARIO_STATES + 0x3c), rfloat(A_MARIO_STATES + 0x40),
            rfloat(A_MARIO_STATES + 0x44), rfloat(A_MARIO_STATES + 0x4c),
            rfloat(A_MARIO_STATES + 0x54), R32(A_MARIO_STATES + 0x60),
            mario_floor, mario_floor ? R32(mario_floor + 0x2c) : 0,
            rfloat(A_MARIO_STATES + 0x70), R32(A_MARIO_PLATFORM),
            R16(A_MARIO_STATES + 0x02), R32(A_MARIO_STATES + 0x04),
            R8(A_MARIO_STATES + 0xb4), rfloat(A_MARIO_STATES + 0xc0),
            i, hand, rs32(hand + O_SIDE), rs32(hand + O_ACTION),
            rs32(hand + O_PREV_ACTION), rs32(hand + O_TIMER),
            rs32(hand + O_HEALTH), rs32(hand + O_RECEIVED_ATTACK),
            R32(hand + O_INTERACT_STATUS), rs32(hand + O_ANGLE_TO_MARIO),
            rs32(hand + O_FACE_YAW), rfloat(hand + O_POS_X),
            rfloat(hand + O_POS_Y), rfloat(hand + O_POS_Z),
            rfloat(hand + O_VEL_Y), rfloat(hand + O_GRAVITY),
            rfloat(hand + O_FORWARD_VEL), move_flags, R32(hand + O_FLOOR),
            rfloat(hand + O_FLOOR_HEIGHT), R32(hand + O_COLLISION),
            R16(hand + O_ACTIVE_FLAGS), !!(move_flags & 3));
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
    W16 = (write16_fn) dlsym(core, "DebugMemWrite16");
    W8 = (write8_fn) dlsym(core, "DebugMemWrite8");
    if (!R32 || !R16 || !R8 || !W32 || !W16 || !W8) return M64ERR_INCOMPATIBLE;
    gPoll = 0;
    fprintf(stderr, "ATTACK_SCENARIO,%s\n", SCENARIO_NAME);
    fprintf(stderr, "STEERING,%s,%d,%d,after_first_wall_frame\n",
            STEER_LABEL, STEER_X, STEER_Y);
    fprintf(stderr, "STEERING_SWITCH,%d,%d,%d,relative_to_pose_poll\n",
            STEER_SWITCH_RELATIVE_POLL, STEER_AFTER_X, STEER_AFTER_Y);
    csv_header();
    return M64ERR_SUCCESS;
}

EXPORT m64p_error CALL PluginShutdown(void) { return M64ERR_SUCCESS; }

EXPORT m64p_error CALL PluginGetVersion(m64p_plugin_type *type, int *version,
                                        int *api_version, const char **name,
                                        int *capabilities) {
    if (type) *type = M64PLUGIN_INPUT;
    if (version) *version = 0x000100;
    if (api_version) *api_version = 0x020100;
    if (name) *name = "US Eyerok attack/reboard probe";
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
    gPreparedIdle = 0;
    gInjectedFight = 0;
    gAttackPoseStaged = 0;
    gPosePoll = 0;
    gBoss = 0;
    gHands[0] = gHands[1] = 0;
    gTarget = 0;
    return 1;
}

EXPORT void CALL RomClosed(void) {}
EXPORT void CALL ControllerCommand(int control, unsigned char *command) { (void) control; (void) command; }
EXPORT void CALL ReadController(int control, unsigned char *command) { (void) control; (void) command; }
EXPORT void CALL SDL_KeyDown(int modifier, int key) { (void) modifier; (void) key; }
EXPORT void CALL SDL_KeyUp(int modifier, int key) { (void) modifier; (void) key; }
EXPORT void CALL RenderCallback(void) {}
EXPORT void CALL SendVRUWord(uint16_t length, uint16_t *word, uint8_t count) {
    (void) length; (void) word; (void) count;
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
EXPORT void CALL SetVRUWordMask(uint8_t length, uint8_t *mask) { (void) length; (void) mask; }

EXPORT void CALL GetKeys(int control, BUTTONS *keys) {
    unsigned long long slot;
    uint16_t area;
    uint32_t timer;

    memset(keys, 0, sizeof(*keys));
    if (control != 0) return;
    gPoll++;

    /* Debug-menu navigation only; the measured attack interval has A and B up. */
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
        fprintf(stderr, "SETUP request Area1->Area2 via sWarpDest level=%u\n", level);
    }

    if (gWarpToArea2 && gStagedInstantWarp < 60 && area == 2 && R32(A_MARIO_OBJECT) != 0) {
        put_mario(0.0f, 450.0f, -1320.0f, 0.0f);
        gStagedInstantWarp++;
        if (gStagedInstantWarp == 1) {
            fprintf(stderr, "SETUP Mario above genuine Area2 instant-warp triangle\n");
        }
    }

    if (area == 3) {
        find_eyerok_objects();
        if (!gPreparedIdle && gBoss && gHands[0] && gHands[1]
            && rfloat(gHands[0] + O_HOME_Y) < -1000.0f
            && rfloat(gHands[1] + O_HOME_Y) < -1000.0f
            && R32(gHands[0] + O_COLLISION) != 0
            && R32(gHands[1] + O_COLLISION) != 0) {
            /* Parent-only wake fixture. Both hands execute retail SLEEP->IDLE. */
            W32(gBoss + O_ACTION, 1);
            W32(gBoss + O_PREV_ACTION, 1);
            W32(gBoss + O_TIMER, 0);
            gPreparedIdle = 1;
            fprintf(stderr, "SETUP boss WAKE_UP; hand state untouched\n");
        } else if (!gInjectedFight && gPreparedIdle && gBoss && gHands[0] && gHands[1]
            && rs32(gHands[0] + O_ACTION) == 1
            && rs32(gHands[1] + O_ACTION) == 1
            && R32(gHands[0] + O_FLOOR) != 0
            && R32(gHands[1] + O_FLOOR) != 0) {
            int32_t side;
            gTarget = gHands[0];
            side = rs32(gTarget + O_SIDE);
            /* Scheduler-only fixture. A different active side makes the target
               execute retail IDLE->OPEN->SHOW_EYE and install its open mesh. */
            W32(gBoss + O_ACTION, 3);
            W32(gBoss + O_PREV_ACTION, 3);
            W32(gBoss + O_TIMER, 0);
            W32(gBoss + O_BOSS_HANDS, 2);
            W32(gBoss + O_BOSS_ACTIVE, (uint32_t) -side);
            W32(gBoss + O_BOSS_104, 0);
            W32(gBoss + O_BOSS_108, fbits(0.0f));
            W32(gBoss + O_BOSS_110, fbits(1.0f));
            W32(gBoss + O_BOSS_1AC, 0);
            put_mario(rfloat(gTarget + O_POS_X), rfloat(gTarget + O_POS_Y) + 20.0f,
                      rfloat(gTarget + O_POS_Z), 0.0f);
            gInjectedFight = 1;
            fprintf(stderr,
                    "SETUP FIGHT scheduler target=%08x targetSide=%d activeSide=%d; "
                    "no target hand action/physics/collision writes\n",
                    gTarget, side, -side);
        }
    }

    if (gInjectedFight && gTarget && !gAttackPoseStaged
        && rs32(gTarget + O_ACTION) == 3) {
#if ATTACK_SCENARIO == 1 || ATTACK_SCENARIO == 3
        /* The only hand-local write: model two prior hits. Retail code performs
           the final decrement and writes DIE, velocity, gravity, and flags. */
        W32(gTarget + O_HEALTH, 2);
        fprintf(stderr, "FIXTURE target health=2 (two prior hits only)\n");
#endif
        stage_attack_pose(gTarget);
        gAttackPoseStaged = 1;
        gPosePoll = gPoll;
    }

    /* The staged pose receives no controller input on its first retail frame.
       That frame performs the open-front-wall push from hand-local Z +100 to
       approximately +127 and zeros speed 5.  A bounded steering sweep starts
       only on the following frame; A and B remain released throughout. */
    if (gAttackPoseStaged && gPoll > gPosePoll) {
#if STEER_SWITCH_RELATIVE_POLL > 0
        unsigned long long relative_poll = gPoll - gPosePoll;
        if (relative_poll >= (unsigned long long) STEER_SWITCH_RELATIVE_POLL) {
            keys->X_AXIS = (int8_t) STEER_AFTER_X;
            keys->Y_AXIS = (int8_t) STEER_AFTER_Y;
        } else {
            keys->X_AXIS = (int8_t) STEER_X;
            keys->Y_AXIS = (int8_t) STEER_Y;
        }
#else
        keys->X_AXIS = (int8_t) STEER_X;
        keys->Y_AXIS = (int8_t) STEER_Y;
#endif
    }

    timer = R32(A_GLOBAL_TIMER);
    if (gInjectedFight && timer != gLastTimer) {
        gLastTimer = timer;
        log_frame(timer);
    }
}
