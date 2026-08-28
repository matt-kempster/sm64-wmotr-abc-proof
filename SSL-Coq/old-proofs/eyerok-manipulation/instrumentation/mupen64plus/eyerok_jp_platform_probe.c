#define _GNU_SOURCE
#define M64P_PLUGIN_PROTOTYPES
#include <mupen64plus/m64p_common.h>
#include <mupen64plus/m64p_debugger.h>
#include <mupen64plus/m64p_plugin.h>
#include <dlfcn.h>
#include <stdint.h>
#include <stdio.h>
#include <string.h>

#ifndef INJECT_HAND_PLATFORM
#define INJECT_HAND_PLATFORM 0
#endif

#ifndef HAND_SIDE
#define HAND_SIDE 1
#endif

#ifndef LOG_ALLOCATION_CENSUS
#define LOG_ALLOCATION_CENSUS 0
#endif

#ifndef SKIP_AREA2_MACROS
#define SKIP_AREA2_MACROS 0
#endif

#if INJECT_HAND_PLATFORM != 0 && INJECT_HAND_PLATFORM != 1
#error INJECT_HAND_PLATFORM must be zero or one
#endif

#if HAND_SIDE != -1 && HAND_SIDE != 1
#error HAND_SIDE must be -1 or 1
#endif

#if LOG_ALLOCATION_CENSUS != 0 && LOG_ALLOCATION_CENSUS != 1
#error LOG_ALLOCATION_CENSUS must be zero or one
#endif

#if SKIP_AREA2_MACROS < 0 || SKIP_AREA2_MACROS > 50
#error SKIP_AREA2_MACROS must be between zero and fifty
#endif

/* Matching original-JP (VERSION_JP) addresses from sm64.jp.elf at
 * 36fbf8d693a9fc2bdec0c77402f8e96d07d2f461. */
enum {
    A_GLOBAL_TIMER = 0x8032c694,
    A_CURR_LEVEL = 0x8032ce98,
    A_MARIO_PLATFORM = 0x8032fed4,
    A_MARIO_STATES = 0x80339e00,
    A_WARP_DEST = 0x80339ed8,
    A_SEGMENT_TABLE = 0x8033a090,
    A_CURR_AREA = 0x8033a75a,
    A_TIME_STOP = 0x8033c110,
    A_OBJECT_POOL = 0x8033c118,
    A_MARIO_OBJECT = 0x8035fde8,
    A_APPLY_MARIO_PLATFORM_DISPLACEMENT = 0x802c83f0,
    A_ALLOCATE_OBJECT = 0x802c9120,
    A_UNLOAD_OBJECT = 0x802c9088,
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
    O_FACE_PITCH = 0x0d0,
    O_FACE_YAW = 0x0d4,
    O_FACE_ROLL = 0x0d8,
    O_ANGLE_VEL_PITCH = 0x114,
    O_ANGLE_VEL_YAW = 0x118,
    O_ANGLE_VEL_ROLL = 0x11c,
    O_SIDE = 0x144,
    O_ACTION = 0x14c,
    O_TIMER = 0x154,
    O_HOME_Y = 0x168,
    O_BEHAVIOR = 0x20c,
    O_COLLISION = 0x218,
};

enum {
    ACT_IDLE = 0x0c400201U,
    SURFACE_INSTANT_WARP_1D = 0x001d,
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
static ptr_DebugSetCallbacks DSetCallbacks;
static ptr_DebugSetRunState DSetRunState;
static ptr_DebugStep DStep;
static ptr_DebugGetCPUDataPtr DGetCPUDataPtr;
static ptr_DebugBreakpointCommand DBreakpointCommand;
static unsigned long long gPoll;
static uint32_t gLastTimer;
static int gWarpToArea2;
static int gStagedArea2Tunnel;
static int gStagedArea3WarpFloor;
static int gSeedWritten;
static int gAfterLogged;
static uint32_t gBoss;
static uint32_t gHand;
static float gSeedMarioX;
static float gSeedMarioY;
static float gSeedMarioZ;
static int gBreakpointsArmed;
static int gFirstApplyEntrySeen;
static int gFirstApplyReturnSeen;
static uint32_t gFirstApplyReturnPC;
static unsigned gAllocationCalls;
static unsigned gWatchedReuseAllocation;
static unsigned gWatchedUnloadCalls;
static int gPreviousWatchedActive;
static unsigned char gCensusActive[OBJECT_COUNT];
static int gAllocationSlot[OBJECT_COUNT + 1];
static int gCensusInitialized;
static int gMacroSkipWritten;

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

static int object_slot(uint32_t object) {
    uint32_t pool_end = A_OBJECT_POOL + OBJECT_COUNT * OBJECT_SIZE;
    if (object < A_OBJECT_POOL || object >= pool_end
        || (object - A_OBJECT_POOL) % OBJECT_SIZE != 0) {
        return -1;
    }
    return (int) ((object - A_OBJECT_POOL) / OBJECT_SIZE);
}

static int add_exec_breakpoint(uint32_t address) {
    m64p_breakpoint breakpoint;

    breakpoint.address = address;
    breakpoint.endaddr = address;
    breakpoint.flags = M64P_BKP_FLAG_ENABLED | M64P_BKP_FLAG_EXEC;
    return DBreakpointCommand(M64P_BKP_CMD_ADD_STRUCT, 0, &breakpoint) >= 0;
}

static int watched_active(void) {
    return gHand != 0 && R16(gHand + O_ACTIVE_FLAGS) != 0;
}

static void census_snapshot(void) {
    unsigned i;

    for (i = 0; i < OBJECT_COUNT; i++) {
        uint32_t object = A_OBJECT_POOL + i * OBJECT_SIZE;
        gCensusActive[i] = R16(object + O_ACTIVE_FLAGS) != 0;
    }
    gCensusInitialized = 1;
}

static void census_capture_completed_allocation(void) {
    unsigned i;
    int activated_slot = -1;
    unsigned activated_count = 0;

    if (!LOG_ALLOCATION_CENSUS) return;
    if (!gCensusInitialized) {
        census_snapshot();
        return;
    }

    for (i = 0; i < OBJECT_COUNT; i++) {
        uint32_t object = A_OBJECT_POOL + i * OBJECT_SIZE;
        int active = R16(object + O_ACTIVE_FLAGS) != 0;
        if (active && !gCensusActive[i]) {
            activated_slot = (int) i;
            activated_count++;
        }
        gCensusActive[i] = (unsigned char) active;
    }

    if (gAllocationCalls != 0 && activated_count == 1) {
        gAllocationSlot[gAllocationCalls] = activated_slot;
    } else if (gAllocationCalls != 0 && activated_count != 0) {
        fprintf(stderr,
                "JP_ALLOCATION_CENSUS_ERROR,allocation=%u,activated=%u\n",
                gAllocationCalls, activated_count);
    }
}

static void log_allocation_payloads(void) {
    unsigned allocation;

    if (!LOG_ALLOCATION_CENSUS) return;
    census_capture_completed_allocation();

    for (allocation = 1; allocation <= gAllocationCalls; allocation++) {
        int slot = gAllocationSlot[allocation];
        uint32_t object;
        uint32_t behavior;

        if (slot < 0) {
            fprintf(stderr,
                    "JP_ALLOCATION_CENSUS_ERROR,allocation=%u,slot=missing\n",
                    allocation);
            continue;
        }
        object = A_OBJECT_POOL + (uint32_t) slot * OBJECT_SIZE;
        behavior = R32(object + O_BEHAVIOR);
        fprintf(stderr,
                "JP_ALLOCATION_PAYLOAD,allocation=%u,slot=%d,address=%08x,"
                "active=%u,behavior=%08x,behaviorWords=(%08x,%08x,%08x),"
                "pos=(%.6f,%.6f,%.6f),posBits=(%08x,%08x,%08x),"
                "vel=(%.6f,%.6f,%.6f),velBits=(%08x,%08x,%08x),"
                "face=(%d,%d,%d),angleVel=(%d,%d,%d)\n",
                allocation, slot, object, R16(object + O_ACTIVE_FLAGS),
                behavior,
                behavior ? R32(behavior) : 0,
                behavior ? R32(behavior + 4) : 0,
                behavior ? R32(behavior + 8) : 0,
                rfloat(object + O_POS_X), rfloat(object + O_POS_Y),
                rfloat(object + O_POS_Z), R32(object + O_POS_X),
                R32(object + O_POS_Y), R32(object + O_POS_Z),
                rfloat(object + O_VEL_X), rfloat(object + O_VEL_Y),
                rfloat(object + O_VEL_Z), R32(object + O_VEL_X),
                R32(object + O_VEL_Y), R32(object + O_VEL_Z),
                rs32(object + O_FACE_PITCH), rs32(object + O_FACE_YAW),
                rs32(object + O_FACE_ROLL),
                rs32(object + O_ANGLE_VEL_PITCH),
                rs32(object + O_ANGLE_VEL_YAW),
                rs32(object + O_ANGLE_VEL_ROLL));
    }
}

static void skip_area2_macro_records(void) {
    uint32_t start = segment_virtual(7, 0);
    uint32_t candidate;
    int i;

    if (gMacroSkipWritten || SKIP_AREA2_MACROS == 0) return;

    for (candidate = start; candidate < start + 0x40000; candidate += 2) {
        if (rs16(candidate) == 68
            && rs16(candidate + 2) == 3263
            && rs16(candidate + 4) == 778
            && rs16(candidate + 6) == 3157
            && rs16(candidate + 8) == 0
            && rs16(candidate + 500) == 30) {
            for (i = 0; i < SKIP_AREA2_MACROS; i++) {
                uint32_t params = candidate + i * 10 + 8;
                W16(params, (uint16_t) (R16(params) | 0xff00U));
            }
            gMacroSkipWritten = 1;
            fprintf(stderr,
                    "JP_MACRO_SKIP_INJECTION,count=%d,address=%08x,"
                    "scope=allocation-identity-only\n",
                    SKIP_AREA2_MACROS, candidate);
            return;
        }
    }
    fprintf(stderr,
            "JP_MACRO_SKIP_ERROR,count=%d,reason=initializer-not-found,"
            "segment7=%08x,area2CommentOffset=(%d,%d,%d,%d,%d)\n",
            SKIP_AREA2_MACROS, start,
            rs16(start + 0x27cd4), rs16(start + 0x27cd6),
            rs16(start + 0x27cd8), rs16(start + 0x27cda),
            rs16(start + 0x27cdc));
}

static void log_breakpoint_slot(const char *tag) {
    uint32_t mario_object = R32(A_MARIO_OBJECT);

    fprintf(stderr,
            "%s,side=%d,timer=%u,area=%d,allocCalls=%u,reuseAllocation=%u,"
            "watchedUnloadCalls=%u,hand=%08x,slot=%d,active=%u,"
            "behavior=%08x,behaviorWords=(%08x,%08x,%08x),"
            "action=%d,objTimer=%d,pos=(%.6f,%.6f,%.6f),"
            "vel=(%.6f,%.6f,%.6f),face=(%d,%d,%d),"
            "angleVel=(%d,%d,%d),platform=%08x,timeStop=%08x,"
            "marioObject=%08x,mario=(%.6f,%.6f,%.6f)\n",
            tag, HAND_SIDE, R32(A_GLOBAL_TIMER), rs16(A_CURR_AREA),
            gAllocationCalls, gWatchedReuseAllocation, gWatchedUnloadCalls,
            gHand, object_slot(gHand),
            gHand ? R16(gHand + O_ACTIVE_FLAGS) : 0,
            gHand ? R32(gHand + O_BEHAVIOR) : 0,
            gHand ? R32(R32(gHand + O_BEHAVIOR)) : 0,
            gHand ? R32(R32(gHand + O_BEHAVIOR) + 4) : 0,
            gHand ? R32(R32(gHand + O_BEHAVIOR) + 8) : 0,
            gHand ? rs32(gHand + O_ACTION) : -1,
            gHand ? rs32(gHand + O_TIMER) : -1,
            gHand ? rfloat(gHand + O_POS_X) : 0.0f,
            gHand ? rfloat(gHand + O_POS_Y) : 0.0f,
            gHand ? rfloat(gHand + O_POS_Z) : 0.0f,
            gHand ? rfloat(gHand + O_VEL_X) : 0.0f,
            gHand ? rfloat(gHand + O_VEL_Y) : 0.0f,
            gHand ? rfloat(gHand + O_VEL_Z) : 0.0f,
            gHand ? rs32(gHand + O_FACE_PITCH) : 0,
            gHand ? rs32(gHand + O_FACE_YAW) : 0,
            gHand ? rs32(gHand + O_FACE_ROLL) : 0,
            gHand ? rs32(gHand + O_ANGLE_VEL_PITCH) : 0,
            gHand ? rs32(gHand + O_ANGLE_VEL_YAW) : 0,
            gHand ? rs32(gHand + O_ANGLE_VEL_ROLL) : 0,
            R32(A_MARIO_PLATFORM), R32(A_TIME_STOP), mario_object,
            rfloat(A_MARIO_STATES + 0x3c),
            rfloat(A_MARIO_STATES + 0x40),
            rfloat(A_MARIO_STATES + 0x44));
}

static void resume_from_breakpoint(void) {
    DSetRunState(M64P_DBG_RUNSTATE_RUNNING);
    DStep();
}

static void debugger_init_callback(void) {}
static void debugger_vi_callback(void) {}

static void debugger_update_callback(unsigned int pc) {
    uint64_t *registers =
        (uint64_t *) DGetCPUDataPtr(M64P_CPU_REG_REG);

    if (pc == A_UNLOAD_OBJECT && gSeedWritten) {
        uint32_t object = registers == NULL ? 0 : (uint32_t) registers[4];
        if (object == gHand) {
            gWatchedUnloadCalls++;
            log_breakpoint_slot("JP_HAND_UNLOAD_ENTRY");
        }
        resume_from_breakpoint();
        return;
    }

    if (pc == A_ALLOCATE_OBJECT && gSeedWritten) {
        census_capture_completed_allocation();
        int active = watched_active();
        if (active && !gPreviousWatchedActive
            && gWatchedReuseAllocation == 0 && gAllocationCalls != 0) {
            gWatchedReuseAllocation = gAllocationCalls;
            log_breakpoint_slot("JP_HAND_REUSED");
        }
        gPreviousWatchedActive = active;
        gAllocationCalls++;
        resume_from_breakpoint();
        return;
    }

    if (pc == A_APPLY_MARIO_PLATFORM_DISPLACEMENT) {
        if (!gSeedWritten || rs16(A_CURR_AREA) != 2
            || gFirstApplyEntrySeen) {
            resume_from_breakpoint();
            return;
        }
        if (watched_active() && !gPreviousWatchedActive
            && gWatchedReuseAllocation == 0) {
            gWatchedReuseAllocation = gAllocationCalls;
            log_breakpoint_slot("JP_HAND_REUSED_AT_APPLY");
        }
        gFirstApplyEntrySeen = 1;
        log_allocation_payloads();
        gFirstApplyReturnPC = registers == NULL
            ? 0 : (uint32_t) registers[31];
        fprintf(stderr,
                "JP_BREAKPOINT,kind=first-area2-apply-entry,pc=%08x,"
                "returnPC=%08x\n",
                pc, gFirstApplyReturnPC);
        log_breakpoint_slot("JP_FIRST_APPLY_ENTRY");
        DBreakpointCommand(M64P_BKP_CMD_REMOVE_ADDR,
                           A_APPLY_MARIO_PLATFORM_DISPLACEMENT, NULL);
        if (gFirstApplyReturnPC == 0
            || !add_exec_breakpoint(gFirstApplyReturnPC)) {
            fprintf(stderr, "JP_BREAKPOINT_ERROR,kind=return-arm\n");
        }
        resume_from_breakpoint();
        return;
    }

    if (pc == gFirstApplyReturnPC && gFirstApplyEntrySeen
        && !gFirstApplyReturnSeen) {
        gFirstApplyReturnSeen = 1;
        fprintf(stderr,
                "JP_BREAKPOINT,kind=first-area2-apply-return,pc=%08x\n",
                pc);
        log_breakpoint_slot("JP_FIRST_APPLY_RETURN");
        DBreakpointCommand(M64P_BKP_CMD_REMOVE_ADDR,
                           gFirstApplyReturnPC, NULL);
        resume_from_breakpoint();
        return;
    }

    fprintf(stderr, "JP_BREAKPOINT_UNEXPECTED,pc=%08x\n", pc);
    resume_from_breakpoint();
}

static void arm_debugger_callbacks(void) {
    if (gBreakpointsArmed) return;
    if (DSetCallbacks(debugger_init_callback, debugger_update_callback,
                      debugger_vi_callback) != M64ERR_SUCCESS) {
        fprintf(stderr, "JP_BREAKPOINT_ERROR,kind=callback-arm\n");
        return;
    }
    gBreakpointsArmed = 1;
    fprintf(stderr,
            "JP_BREAKPOINT_ARM,apply=%08x,allocate=%08x,unload=%08x\n",
            A_APPLY_MARIO_PLATFORM_DISPLACEMENT,
            A_ALLOCATE_OBJECT, A_UNLOAD_OBJECT);
}

static void arm_transition_breakpoints(void) {
    if (LOG_ALLOCATION_CENSUS) census_snapshot();
    if (!add_exec_breakpoint(A_ALLOCATE_OBJECT)
        || !add_exec_breakpoint(A_UNLOAD_OBJECT)) {
        fprintf(stderr, "JP_BREAKPOINT_ERROR,kind=transition-arm\n");
    }
}

static void put_mario(float x, float y, float z) {
    uint32_t mario_object = R32(A_MARIO_OBJECT);

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

    if (mario_object != 0) {
        W32(mario_object + O_POS_X, fbits(x));
        W32(mario_object + O_POS_Y, fbits(y));
        W32(mario_object + O_POS_Z, fbits(z));
        W32(mario_object + O_VEL_X, 0);
        W32(mario_object + O_VEL_Y, 0);
        W32(mario_object + O_VEL_Z, 0);
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
        if (R16(object + O_ACTIVE_FLAGS) == 0) {
            continue;
        }
        if (R32(object + O_BEHAVIOR) == boss_behavior) {
            gBoss = object;
        }
        if (R32(object + O_BEHAVIOR) == hand_behavior
            && rs32(object + O_SIDE) == HAND_SIDE) {
            gHand = object;
        }
    }
}

static void log_slot(const char *tag) {
    uint32_t floor = R32(A_MARIO_STATES + 0x68);
    uint32_t platform = R32(A_MARIO_PLATFORM);
    uint32_t slot = gHand;

    fprintf(stderr,
            "%s,inject=%d,side=%d,timer=%u,area=%d,floor=%08x,floorType=%d,"
            "floorObject=%08x,platform=%08x,platformSlot=%d,"
            "handSlot=%d,slotActive=%u,slotBehavior=%08x,slotAction=%d,"
            "slotTimer=%d,slotPos=(%.3f,%.3f,%.3f),"
            "slotVel=(%.3f,%.3f,%.3f),slotFace=(%d,%d,%d),"
            "slotAngleVel=(%d,%d,%d),slotCollision=%08x,"
            "mario=(%.3f,%.3f,%.3f),mVel=(%.3f,%.3f,%.3f),"
            "forwardVel=%.3f,timeStop=%08x\n",
            tag, INJECT_HAND_PLATFORM, HAND_SIDE, R32(A_GLOBAL_TIMER),
            rs16(A_CURR_AREA), floor, surface_type(floor),
            surface_object(floor), platform, object_slot(platform),
            object_slot(slot), slot ? R16(slot + O_ACTIVE_FLAGS) : 0,
            slot ? R32(slot + O_BEHAVIOR) : 0,
            slot ? rs32(slot + O_ACTION) : -1,
            slot ? rs32(slot + O_TIMER) : -1,
            slot ? rfloat(slot + O_POS_X) : 0.0f,
            slot ? rfloat(slot + O_POS_Y) : 0.0f,
            slot ? rfloat(slot + O_POS_Z) : 0.0f,
            slot ? rfloat(slot + O_VEL_X) : 0.0f,
            slot ? rfloat(slot + O_VEL_Y) : 0.0f,
            slot ? rfloat(slot + O_VEL_Z) : 0.0f,
            slot ? rs32(slot + O_FACE_PITCH) : 0,
            slot ? rs32(slot + O_FACE_YAW) : 0,
            slot ? rs32(slot + O_FACE_ROLL) : 0,
            slot ? rs32(slot + O_ANGLE_VEL_PITCH) : 0,
            slot ? rs32(slot + O_ANGLE_VEL_YAW) : 0,
            slot ? rs32(slot + O_ANGLE_VEL_ROLL) : 0,
            slot ? R32(slot + O_COLLISION) : 0,
            rfloat(A_MARIO_STATES + 0x3c),
            rfloat(A_MARIO_STATES + 0x40),
            rfloat(A_MARIO_STATES + 0x44),
            rfloat(A_MARIO_STATES + 0x48),
            rfloat(A_MARIO_STATES + 0x4c),
            rfloat(A_MARIO_STATES + 0x50),
            rfloat(A_MARIO_STATES + 0x54), R32(A_TIME_STOP));
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
    DSetCallbacks = (ptr_DebugSetCallbacks) dlsym(core, "DebugSetCallbacks");
    DSetRunState = (ptr_DebugSetRunState) dlsym(core, "DebugSetRunState");
    DStep = (ptr_DebugStep) dlsym(core, "DebugStep");
    DGetCPUDataPtr =
        (ptr_DebugGetCPUDataPtr) dlsym(core, "DebugGetCPUDataPtr");
    DBreakpointCommand = (ptr_DebugBreakpointCommand) dlsym(
        core, "DebugBreakpointCommand");
    if (!R32 || !R16 || !R8 || !W32 || !W16 || !W8
        || !DSetCallbacks || !DSetRunState || !DStep || !DGetCPUDataPtr
        || !DBreakpointCommand) {
        return M64ERR_INCOMPATIBLE;
    }
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
    if (name) *name = "JP Eyerok stale-platform probe";
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
    unsigned i;

    gPoll = 0;
    gLastTimer = UINT32_MAX;
    gWarpToArea2 = 0;
    gStagedArea2Tunnel = 0;
    gStagedArea3WarpFloor = 0;
    gSeedWritten = 0;
    gAfterLogged = 0;
    gBoss = 0;
    gHand = 0;
    gBreakpointsArmed = 0;
    gFirstApplyEntrySeen = 0;
    gFirstApplyReturnSeen = 0;
    gFirstApplyReturnPC = 0;
    gAllocationCalls = 0;
    gWatchedReuseAllocation = 0;
    gWatchedUnloadCalls = 0;
    gPreviousWatchedActive = 0;
    memset(gCensusActive, 0, sizeof(gCensusActive));
    for (i = 0; i <= OBJECT_COUNT; i++) gAllocationSlot[i] = -1;
    gCensusInitialized = 0;
    gMacroSkipWritten = 0;
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
    uint32_t floor;
    uint32_t timer;

    memset(keys, 0, sizeof(*keys));
    if (control != 0) {
        return;
    }
    gPoll++;

    arm_debugger_callbacks();

    if (gPoll == 1 || gPoll % 60 == 0) {
        fprintf(stderr,
                "JP_POLL,inject=%d,poll=%llu,timer=%u,level=%d,area=%d,"
                "marioObject=%08x\n",
                INJECT_HAND_PLATFORM, gPoll, R32(A_GLOBAL_TIMER),
                rs16(A_CURR_LEVEL), rs16(A_CURR_AREA), R32(A_MARIO_OBJECT));
    }

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

    if (area == 3 && !gStagedArea3WarpFloor) {
        find_eyerok_objects();
        if (gBoss && gHand && rs32(gBoss + O_ACTION) == 0
            && rs32(gHand + O_ACTION) == 0
            && rfloat(gHand + O_HOME_Y) < -1000.0f
            && R32(gHand + O_COLLISION) != 0) {
            /* One frame later the retail floor query selects the real static
             * 0x1d tunnel triangle.  The next controller poll precedes
             * check_instant_warp, which is the seed observation point. */
            put_mario(0.0f, 347.0f, -1100.0f);
            skip_area2_macro_records();
            gStagedArea2Tunnel = 60;
            gStagedArea3WarpFloor = 1;
            fprintf(stderr,
                    "JP_STAGE,inject=%d,timer=%u,hand=%08x,handSlot=%d,"
                    "boss=%08x,writes=mario_position+idle_action_only\n",
                    INJECT_HAND_PLATFORM, R32(A_GLOBAL_TIMER), gHand,
                    object_slot(gHand), gBoss);
        }
    }

    floor = R32(A_MARIO_STATES + 0x68);
    if (area == 3 && gStagedArea3WarpFloor && !gSeedWritten
        && surface_type(floor) == SURFACE_INSTANT_WARP_1D) {
        gSeedMarioX = rfloat(A_MARIO_STATES + 0x3c);
        gSeedMarioY = rfloat(A_MARIO_STATES + 0x40);
        gSeedMarioZ = rfloat(A_MARIO_STATES + 0x44);
        if (INJECT_HAND_PLATFORM) {
            W32(A_MARIO_PLATFORM, gHand);
        }
        log_slot("JP_SEED");
        gSeedWritten = 1;
        gPreviousWatchedActive = watched_active();
        arm_transition_breakpoints();
    }

    timer = R32(A_GLOBAL_TIMER);
    if (gSeedWritten && !gAfterLogged && timer != gLastTimer) {
        gLastTimer = timer;
        log_slot("JP_FRAME");
    }

    if (gSeedWritten && !gAfterLogged && area == 2) {
        fprintf(stderr,
                "JP_RESULT,inject=%d,seedMario=(%.3f,%.3f,%.3f),"
                "afterMario=(%.3f,%.3f,%.3f),delta=(%.3f,%.3f,%.3f)\n",
                INJECT_HAND_PLATFORM, gSeedMarioX, gSeedMarioY, gSeedMarioZ,
                rfloat(A_MARIO_STATES + 0x3c),
                rfloat(A_MARIO_STATES + 0x40),
                rfloat(A_MARIO_STATES + 0x44),
                rfloat(A_MARIO_STATES + 0x3c) - gSeedMarioX,
                rfloat(A_MARIO_STATES + 0x40) - gSeedMarioY,
                rfloat(A_MARIO_STATES + 0x44) - gSeedMarioZ);
        gAfterLogged = 1;
    }
}
