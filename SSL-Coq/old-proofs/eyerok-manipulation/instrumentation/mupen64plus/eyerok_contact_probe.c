#define _GNU_SOURCE
#define M64P_PLUGIN_PROTOTYPES
#include <mupen64plus/m64p_common.h>
#include <mupen64plus/m64p_plugin.h>
#include <mupen64plus/m64p_debugger.h>
#include <dlfcn.h>
#include <stdint.h>
#include <stdio.h>
#include <string.h>

#ifndef CONTACT_MODE
#define CONTACT_MODE 0
#endif

#if CONTACT_MODE < 0 || CONTACT_MODE > 2
#error CONTACT_MODE must be 0 (stationary), 1 (B-only), or 2 (held-A)
#endif

#if CONTACT_MODE == 0
#define CONTACT_MODE_NAME "stationary"
#elif CONTACT_MODE == 1
#define CONTACT_MODE_NAME "b_only"
#else
#define CONTACT_MODE_NAME "held_a"
#endif

/* Authentic US ROM / matching build symbols (36fbf8d6 source checkout). */
enum {
    A_GLOBAL_TIMER    = 0x8032d5d4,
    A_CURR_LEVEL      = 0x8032ddf8,
    A_MARIO_STATES    = 0x8033b170,
    A_WARP_DEST       = 0x8033b248,
    A_SEGMENT_TABLE   = 0x8033b400,
    A_OBJECT_POOL     = 0x8033d488,
    A_OBJECT_LISTS    = 0x803610e8,
    A_MARIO_OBJECT    = 0x80361158,
    A_CURR_AREA       = 0x8033baca,
    A_MARIO_PLATFORM  = 0x80330e34,
    OBJECT_SIZE       = 0x260,
    OBJECT_COUNT      = 240,
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
    O_FACE_YAW     = 0x0d4,
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
static int gContactStaged;
static int gContactSetupFrames;
static int gDiveStaged;
static uint32_t gContactHand;
static uint32_t gBoss;
static uint32_t gHands[2];

static uint32_t fbits(float f) {
    union { float f; uint32_t u; } v;
    v.f = f;
    return v.u;
}

static float rfloat(uint32_t addr) {
    union { float f; uint32_t u; } v;
    v.u = R32(addr);
    return v.f;
}

static int32_t rs32(uint32_t addr) { return (int32_t) R32(addr); }

static uint32_t segment_virtual(unsigned seg, uint32_t offset) {
    uint32_t base = R32(A_SEGMENT_TABLE + seg * 4) & 0x1fffffffU;
    return 0x80000000U | (base + offset);
}

static void find_eyerok_objects(void) {
    uint32_t handBehavior = segment_virtual(0x13, 0x52d0);
    uint32_t bossBehavior = segment_virtual(0x13, 0x52b4);
    int found = 0;
    unsigned i;
    gBoss = 0;
    gHands[0] = gHands[1] = 0;
    for (i = 0; i < OBJECT_COUNT; i++) {
        uint32_t obj = A_OBJECT_POOL + i * OBJECT_SIZE;
        if (R16(obj + O_ACTIVE_FLAGS) == 0) continue;
        if (R32(obj + O_BEHAVIOR) == bossBehavior) gBoss = obj;
        if (R32(obj + O_BEHAVIOR) == handBehavior && found < 2) gHands[found++] = obj;
    }
}

static void put_mario(float x, float y, float z) {
    uint32_t mo = R32(A_MARIO_OBJECT);
    W32(A_MARIO_STATES + 0x3c, fbits(x));
    W32(A_MARIO_STATES + 0x40, fbits(y));
    W32(A_MARIO_STATES + 0x44, fbits(z));
    W32(A_MARIO_STATES + 0x48, 0);
    W32(A_MARIO_STATES + 0x4c, 0);
    W32(A_MARIO_STATES + 0x50, 0);
    if (mo != 0) {
        W32(mo + O_POS_X, fbits(x));
        W32(mo + O_POS_Y, fbits(y));
        W32(mo + O_POS_Z, fbits(z));
        W32(mo + O_VEL_Y, 0);
    }
}

static void prepare_initialized_idle_hands(void) {
    /* Wake the parent only. Each hand's real SLEEP handler performs its
       animation, sets IDLE, and installs the common closed collision mesh. */
    W32(gBoss + O_ACTION, 1);
    W32(gBoss + O_PREV_ACTION, 1);
    W32(gBoss + O_TIMER, 0);
    fprintf(stderr,
            "SETUP boss set WAKE_UP; hands left untouched for authentic SLEEP->IDLE\n");
}

static void inject_grounded_idle_fight(void) {
    /* Scheduler-only fixture after authentic hand SLEEP->IDLE initialization.
       No hand position, velocity, gravity, flags, floor, or collision writes. */
    W32(gBoss + O_ACTION, 3);
    W32(gBoss + O_PREV_ACTION, 3);
    W32(gBoss + O_TIMER, 0);
    W32(gBoss + O_BOSS_HANDS, 2);
    W32(gBoss + O_BOSS_ACTIVE, 0);
    W32(gBoss + O_BOSS_104, (uint32_t) -8);
    W32(gBoss + O_BOSS_108, fbits(0.0f));
    W32(gBoss + O_BOSS_110, fbits(1.0f));
    W32(gBoss + O_BOSS_1AC, 0);
    put_mario(0.0f, -1450.0f, -3500.0f);
    fprintf(stderr,
            "SETUP scheduler-only FIGHT boss=%08x hand0=%08x hand1=%08x; hands untouched\n",
            gBoss, gHands[0], gHands[1]);
}

static void csv_header(void) {
    fprintf(stderr,
        "CSV,poll,timer,area,boss,bossAction,bossTimer,numHands,activeHand,unk104,unk1AC,"
        "mAction,mActionTimer,mX,mY,mZ,mVelY,mFloor,mFloorObject,mFloorHeight,mPlatform,mInput,mCeil,mCeilObject,mCeilHeight,"
        "handIndex,hand,side,action,actionTimer,posX,posY,posZ,faceYaw,velY,gravity,moveFlags,floor,floorHeight,"
        "collision,activeFlags,groundCollision,moveSkipped\n");
}

static void log_frame(uint32_t timer) {
    unsigned i;
    uint32_t mAction = R32(A_MARIO_STATES + 0x0c);
    unsigned mTimer = R16(A_MARIO_STATES + 0x1a);
    float mY = rfloat(A_MARIO_STATES + 0x40);
    float mX = rfloat(A_MARIO_STATES + 0x3c);
    float mZ = rfloat(A_MARIO_STATES + 0x44);
    float mVy = rfloat(A_MARIO_STATES + 0x4c);
    uint32_t mFloor = R32(A_MARIO_STATES + 0x68);
    uint32_t mFloorObject = mFloor ? R32(mFloor + 0x2c) : 0;
    float mFloorH = rfloat(A_MARIO_STATES + 0x70);
    uint32_t platform = R32(A_MARIO_PLATFORM);
    uint16_t mInput = R16(A_MARIO_STATES + 0x02);
    uint32_t mCeil = R32(A_MARIO_STATES + 0x64);
    uint32_t mCeilObject = mCeil ? R32(mCeil + 0x2c) : 0;
    float mCeilH = rfloat(A_MARIO_STATES + 0x6c);
    for (i = 0; i < 2; i++) {
        uint32_t h = gHands[i];
        uint32_t flags;
        uint16_t active;
        if (!h) continue;
        flags = R32(h + O_MOVE_FLAGS);
        active = R16(h + O_ACTIVE_FLAGS);
        fprintf(stderr,
            "CSV,%llu,%u,%u,%08x,%d,%d,%d,%d,%d,%d,%08x,%u,%.3f,%.3f,%.3f,%.3f,%08x,%08x,%.3f,%08x,%04x,%08x,%08x,%.3f,"
            "%u,%08x,%d,%d,%d,%.3f,%.3f,%.3f,%d,%.3f,%.3f,%08x,%08x,%.3f,%08x,%04x,%d,%d\n",
            gPoll, timer, R16(A_CURR_AREA), gBoss,
            gBoss ? rs32(gBoss + O_ACTION) : -1,
            gBoss ? rs32(gBoss + O_TIMER) : -1,
            gBoss ? rs32(gBoss + O_BOSS_HANDS) : -1,
            gBoss ? rs32(gBoss + O_BOSS_ACTIVE) : -1,
            gBoss ? rs32(gBoss + O_BOSS_104) : -1,
            gBoss ? rs32(gBoss + O_BOSS_1AC) : -1,
            mAction, mTimer, mX, mY, mZ, mVy, mFloor, mFloorObject, mFloorH,
            platform, mInput, mCeil, mCeilObject, mCeilH,
            i, h, rs32(h + O_SIDE), rs32(h + O_ACTION), rs32(h + O_TIMER),
            rfloat(h + O_POS_X), rfloat(h + O_POS_Y), rfloat(h + O_POS_Z),
            rs32(h + O_FACE_YAW), rfloat(h + O_VEL_Y), rfloat(h + O_GRAVITY),
            flags, R32(h + O_FLOOR), rfloat(h + O_FLOOR_HEIGHT), R32(h + O_COLLISION),
            active, !!(flags & 3), !!(active & 0x0a));
    }
}

EXPORT m64p_error CALL PluginStartup(m64p_dynlib_handle core, void *context,
                                     void (*debug_callback)(void *, int, const char *)) {
    (void) context; (void) debug_callback;
    R32 = (read32_fn) dlsym(core, "DebugMemRead32");
    R16 = (read16_fn) dlsym(core, "DebugMemRead16");
    R8 = (read8_fn) dlsym(core, "DebugMemRead8");
    W32 = (write32_fn) dlsym(core, "DebugMemWrite32");
    W16 = (write16_fn) dlsym(core, "DebugMemWrite16");
    W8 = (write8_fn) dlsym(core, "DebugMemWrite8");
    if (!R32 || !R16 || !R8 || !W32 || !W16 || !W8) return M64ERR_INCOMPATIBLE;
    gPoll = 0;
    fprintf(stderr, "CONTACT_MODE,%s\n", CONTACT_MODE_NAME);
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
    if (name) *name = "US Eyerok transparent-setup probe";
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
    gPoll = 0; gLastTimer = UINT32_MAX;
    gWarpToArea2 = gStagedInstantWarp = gPreparedIdle = gInjectedFight = gContactStaged = 0;
    gContactSetupFrames = gDiveStaged = 0;
    gContactHand = 0;
    gBoss = gHands[0] = gHands[1] = 0;
    return 1;
}
EXPORT void CALL RomClosed(void) {}
EXPORT void CALL ControllerCommand(int c, unsigned char *p) { (void)c; (void)p; }
EXPORT void CALL ReadController(int c, unsigned char *p) { (void)c; (void)p; }
EXPORT void CALL SDL_KeyDown(int m, int k) { (void)m; (void)k; }
EXPORT void CALL SDL_KeyUp(int m, int k) { (void)m; (void)k; }
EXPORT void CALL RenderCallback(void) {}
EXPORT void CALL SendVRUWord(uint16_t l, uint16_t *w, uint8_t n) { (void)l;(void)w;(void)n; }
EXPORT void CALL SetMicState(int s) { (void)s; }
EXPORT void CALL ReadVRUResults(uint16_t *a,uint16_t *b,uint16_t *c,uint16_t *d,uint16_t *e,uint16_t *f) {
    if (a) *a = 0;
    if (b) *b = 0;
    if (c) *c = 0;
    if (d) *d = 0;
    if (e) *e = 0;
    (void) f;
}
EXPORT void CALL ClearVRUWords(uint8_t l) { (void)l; }
EXPORT void CALL SetVRUWordMask(uint8_t l, uint8_t *m) { (void)l;(void)m; }

EXPORT void CALL GetKeys(int control, BUTTONS *keys) {
    unsigned long long slot;
    uint16_t area;
    uint32_t timer;
    memset(keys, 0, sizeof(*keys));
    if (control != 0) return;
    gPoll++;

    /* Built-in level-select cheat navigation to SSL (setup only). */
    if (gPoll >= 150 && gPoll < 156) keys->START_BUTTON = 1;
    for (slot = 220; slot <= 280; slot += 10)
        if (gPoll >= slot && gPoll < slot + 2) keys->D_DPAD = 1;
    if (gPoll >= 330 && gPoll < 336) keys->START_BUTTON = 1;

    /* gCurrAreaIndex is s16; a byte read at its big-endian address sees 0. */
    area = R16(A_CURR_AREA);
    /* In mode 2 A is held continuously throughout Area 3. By the contact
     * trial this is a down level, not a new edge (the 0.5-A case). */
#if CONTACT_MODE == 2
    if (area == 3) keys->A_BUTTON = 1;
#endif
    if (gPoll == 150 || gPoll == 330 || gPoll == 360 || gPoll == 400 ||
        gPoll == 500 || gPoll == 700 || gPoll == 900) {
        uint32_t mf = R32(A_MARIO_STATES + 0x68);
        fprintf(stderr,
                "PROBE poll=%llu timer=%08x level16=%04x area=%u mario=%08x seg13=%08x "
                "mpos=(%.1f,%.1f,%.1f) floor=%08x floorType=%04x floorH=%.1f\n",
                gPoll, R32(A_GLOBAL_TIMER), R16(A_CURR_LEVEL), area,
                R32(A_MARIO_OBJECT), R32(A_SEGMENT_TABLE + 0x13 * 4),
                rfloat(A_MARIO_STATES + 0x3c), rfloat(A_MARIO_STATES + 0x40),
                rfloat(A_MARIO_STATES + 0x44), mf, mf ? R16(mf) : 0,
                rfloat(A_MARIO_STATES + 0x70));
    }
    if (!gWarpToArea2 && gPoll > 360 && area == 1 && R32(A_MARIO_OBJECT) != 0) {
        uint16_t level = R16(A_CURR_LEVEL);
        W8(A_WARP_DEST + 0, 2);       /* WARP_TYPE_CHANGE_AREA */
        W8(A_WARP_DEST + 1, (uint8_t) level);
        W8(A_WARP_DEST + 2, 2);
        W8(A_WARP_DEST + 3, 0x0a);
        W32(A_WARP_DEST + 4, 0);
        gWarpToArea2 = 1;
        fprintf(stderr, "SETUP request Area1->Area2 via sWarpDest level=%u\n", level);
    }

    if (gWarpToArea2 && gStagedInstantWarp < 60 && area == 2 && R32(A_MARIO_OBJECT) != 0) {
        /* Above the genuine Area-2 SURFACE_INSTANT_WARP_1D triangles. */
        put_mario(0.0f, 450.0f, -1320.0f);
        gStagedInstantWarp++;
        if (gStagedInstantWarp == 1)
            fprintf(stderr, "SETUP Mario above Area2 instant-warp triangle x=0 y=450 z=-1320\n");
    }

    if (area == 3) {
        find_eyerok_objects();
        /* Phase one occurs only after real SET_HOME and collision selection.
           One ordinary IDLE update then gives both objects real floor fields. */
        if (!gPreparedIdle && gBoss && gHands[0] && gHands[1]
            && rfloat(gHands[0] + O_HOME_Y) < -1000.0f
            && rfloat(gHands[1] + O_HOME_Y) < -1000.0f
            && R32(gHands[0] + O_COLLISION) != 0
            && R32(gHands[1] + O_COLLISION) != 0) {
            prepare_initialized_idle_hands();
            gPreparedIdle = 1;
        } else if (!gInjectedFight && gPreparedIdle && gBoss && gHands[0] && gHands[1]
            && rs32(gHands[0] + O_ACTION) == 1
            && rs32(gHands[1] + O_ACTION) == 1
            && R32(gHands[0] + O_FLOOR) != 0
            && R32(gHands[1] + O_FLOOR) != 0
            && R32(gHands[0] + O_COLLISION) == R32(gHands[1] + O_COLLISION)
            && rfloat(gHands[0] + O_FLOOR_HEIGHT) > -1540.0f
            && rfloat(gHands[0] + O_FLOOR_HEIGHT) < -1528.0f
            && rfloat(gHands[1] + O_FLOOR_HEIGHT) > -1540.0f
            && rfloat(gHands[1] + O_FLOOR_HEIGHT) < -1528.0f) {
            inject_grounded_idle_fight();
            gInjectedFight = 1;
        }
    }

    if (gInjectedFight && !gContactStaged) {
        unsigned i;
        for (i = 0; i < 2; i++) {
            uint32_t h = gHands[i];
            int32_t action = rs32(h + O_ACTION);
            int32_t actionTimer = rs32(h + O_TIMER);
            float topY = rfloat(h + O_POS_Y) + 306.0f;
            int active = rs32(h + O_SIDE) == rs32(gBoss + O_BOSS_ACTIVE);
            int early = action == 10 || (action == 11 && actionTimer <= 2);

            if (!active || !early)
                continue;

            /* spawn_object_relative_with_scale initializes all axes to 1.5;
             * the loop's X rewrite leaves Y at 1.5. Closed top=204*1.5=306. */
            if (R32(A_MARIO_PLATFORM) == h
                && rfloat(A_MARIO_STATES + 0x70) > topY - 0.5f
                && rfloat(A_MARIO_STATES + 0x70) < topY + 0.5f) {
                gContactStaged = 1;
                gContactHand = h;
                fprintf(stderr,
                        "CONTACT acquired hand floor/platform authentically hand=%08x floorH=%.3f topY=%.3f setupFrames=%d\n",
                        h, rfloat(A_MARIO_STATES + 0x70), topY, gContactSetupFrames);
                break;
            }

            put_mario(rfloat(h + O_POS_X), topY, rfloat(h + O_POS_Z));
#if CONTACT_MODE == 2
            /* State 1 prevents held A from taking the jump-kick branch during
             * the one-or-more-frame dynamic-surface preload. */
            W32(A_MARIO_STATES + 0x0c, 0x00800457); /* ACT_MOVE_PUNCHING */
            W32(A_MARIO_STATES + 0x10, 0x00800457);
            W16(A_MARIO_STATES + 0x18, 1);
#else
            W32(A_MARIO_STATES + 0x0c, 0x0c400201); /* ACT_IDLE */
            W32(A_MARIO_STATES + 0x10, 0x0c400201);
            W16(A_MARIO_STATES + 0x18, 0);
#endif
            W16(A_MARIO_STATES + 0x1a, 0);
            W32(A_MARIO_STATES + 0x54, 0);
            gContactSetupFrames++;
            fprintf(stderr,
                    "CONTACT preload hand=%08x action=%d timer=%d topY=%.3f platform=%08x mode=%s\n",
                    h, action, actionTimer, topY, R32(A_MARIO_PLATFORM), CONTACT_MODE_NAME);
            break;
        }
    }

    if (gContactStaged && !gDiveStaged && gContactHand
        && rs32(gContactHand + O_ACTION) == 11
        && rs32(gContactHand + O_TIMER) == 2
        && (R32(gContactHand + O_MOVE_FLAGS) & 3)
        && R32(A_MARIO_PLATFORM) == gContactHand) {
        float topY = rfloat(gContactHand + O_POS_Y) + 306.0f;

#if CONTACT_MODE == 0
        /* No writes here: measure a stationary Mario already authenticated on
         * the hand floor/platform. */
        gDiveStaged = 1;
        fprintf(stderr,
                "CONTACT stationary release hand=%08x topY=%.3f A=up B=up\n",
                gContactHand, topY);
#elif CONTACT_MODE == 1
        /* Source-valid speed-kick predecessor. The retail input/action code
         * must consume the one B edge and produce ACT_DIVE itself. */
        /* Start 125 world units toward the rear of this yaw-zero hand. The
         * ensuing retail dive traverses the interior instead of running out
         * through the front edge on the final +10 step. */
        put_mario(rfloat(gContactHand + O_POS_X), topY,
                  rfloat(gContactHand + O_POS_Z) - 125.0f);
        W32(A_MARIO_STATES + 0x0c, 0x04000440); /* ACT_WALKING */
        W32(A_MARIO_STATES + 0x10, 0x0c400201); /* ACT_IDLE */
        W16(A_MARIO_STATES + 0x18, 0);
        W16(A_MARIO_STATES + 0x1a, 0);
        W32(A_MARIO_STATES + 0x1c, 0);
        W32(A_MARIO_STATES + 0x54, fbits(29.0f));
        W16(A_MARIO_STATES + 0x2e, 0);
        keys->B_BUTTON = 1;
        keys->Y_AXIS = 127;
        gDiveStaged = 1;
        fprintf(stderr,
                "CONTACT B-only entry hand=%08x topY=%.3f rearZOffset=-125 stagedAction=04000440 forwardVel=29 faceYaw=0 input=B+stick127 A=up\n",
                gContactHand, topY);
#else
        /* Reset only the documented MOVE_PUNCHING state precondition. A has
         * already been down for dozens of polls, so retail code must see
         * INPUT_A_DOWN without INPUT_A_PRESSED and enter JUMP_KICK itself. */
        put_mario(rfloat(gContactHand + O_POS_X), topY,
                  rfloat(gContactHand + O_POS_Z));
        W32(A_MARIO_STATES + 0x0c, 0x00800457); /* ACT_MOVE_PUNCHING */
        W32(A_MARIO_STATES + 0x10, 0x00800457);
        W16(A_MARIO_STATES + 0x18, 0);
        W16(A_MARIO_STATES + 0x1a, 0);
        W32(A_MARIO_STATES + 0x1c, 0);
        W32(A_MARIO_STATES + 0x54, 0);
        W16(A_MARIO_STATES + 0x2e, 0);          /* face yaw */
        gDiveStaged = 1;
        fprintf(stderr,
                "CONTACT held-A entry hand=%08x topY=%.3f stagedAction=00800457 state=0 forwardVel=0 A=continuously-down-since-area-entry B=up\n",
                gContactHand, topY);
#endif
    }

    timer = R32(A_GLOBAL_TIMER);
    if (gInjectedFight && timer != gLastTimer) {
        gLastTimer = timer;
        log_frame(timer);
    }
}
