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

#ifndef ROUTE_STICK_X
#define ROUTE_STICK_X -127
#endif
#ifndef ROUTE_STICK_Y
#define ROUTE_STICK_Y -96
#endif
#ifndef INSTALL_TIMER
#define INSTALL_TIMER 131
#endif
#ifndef ROUTE_HOLD_FRAMES
#define ROUTE_HOLD_FRAMES 60
#endif
#ifndef BOUNDARY_POST_OWNER
#define BOUNDARY_POST_OWNER 0
#endif
#ifndef STATE_X
#define STATE_X -2200
#endif
#ifndef STATE_Y
#define STATE_Y 768
#endif
#ifndef STATE_Z
#define STATE_Z -1024
#endif
#ifndef GRAPHICS_X
#define GRAPHICS_X -1862
#endif
#ifndef GRAPHICS_Y
#define GRAPHICS_Y 1778
#endif
#ifndef GRAPHICS_Z
#define GRAPHICS_Z -902
#endif

/* Authenticated original-JP virtual addresses.  run.sh hash-gates the ROM. */
enum {
    A_GLOBAL_TIMER = 0x8032c694,
    A_CURR_LEVEL = 0x8032ce98,
    A_MARIO_PLATFORM = 0x8032fed4,
    A_TIME_STOP_STATE = 0x8033c110,
    A_MARIO_STATES = 0x80339e00,
    A_CURR_AREA = 0x8033a75a,
    A_OBJECT_POOL = 0x8033c118,
    A_MARIO_OBJECT = 0x8035fde8,
    A_APPLY_MARIO_PLATFORM_DISPLACEMENT = 0x802c83f0,
    A_SLOT67 = 0x80346038,
    A_SLOT67_NEXT = 0x80346098,
    A_SLOT67_PREV = 0x8034609c,
    A_SLOT67_ACTIVE_FLAGS = 0x803460ac,
    A_SLOT67_FLAGS = 0x803460c4,
    A_SLOT67_GRAPH_Y_OFFSET = 0x80346114,
    A_SLOT67_BEHAVIOR = 0x80346244,
    A_LIST0_SENTINEL_NEXT = 0x8033b8d0,
    A_LIST0_SENTINEL_PREV = 0x8033b8d4,
    A_STATE_MARIO_OBJECT = 0x80339e88,
    A_BHV_MARIO = 0x800eb1c0,
    BHV_MARIO_WORDS = 14,
    A_BEHAVIOR_CMD_TABLE = 0x8038b9b0,
    BEHAVIOR_CMD_TABLE_WORDS = 56,
    A_ALLOCATE_OBJECT = 0x802c9120,
    A_ALLOCATE_OBJECT_UNLOAD_CALL = 0x802c9174,
    A_UNLOAD_OBJECT = 0x802c9088,
    A_STOP_SOUNDS_FROM_SOURCE = 0x803206f8,
    A_STOP_SOUNDS_IN_CONTINUOUS_BANKS = 0x80320890,
    A_PRINT_TEXT_FMT_INT = 0x802d57f8,
    A_PRINT_TEXT = 0x802d5a74,
    A_DEBUG_PRINT_TEXT_CALLSITE = 0x802c99dc,
    A_DEBUG_PRINT_TEXT_FMT_INT_CALLSITE = 0x802c9a08,
};

enum {
    OBJECT_SIZE = 0x260,
    OBJECT_COUNT = 240,

    GFX_POS_X = 0x020,
    GFX_POS_Y = 0x024,
    GFX_POS_Z = 0x028,
    HEADER_NEXT = 0x060,
    O_ACTIVE_FLAGS = 0x074,
    O_FLAGS = 0x08c,
    O_POS_X = 0x0a0,
    O_POS_Y = 0x0a4,
    O_POS_Z = 0x0a8,
    O_VEL_X = 0x0ac,
    O_VEL_Y = 0x0b0,
    O_VEL_Z = 0x0b4,
    O_FACE_PITCH = 0x0d0,
    O_FACE_YAW = 0x0d4,
    O_FACE_ROLL = 0x0d8,
    O_PYRAMID_PILLARS_TOUCHED = 0x0f4,
    O_ANGLE_VEL_PITCH = 0x114,
    O_ANGLE_VEL_YAW = 0x118,
    O_ANGLE_VEL_ROLL = 0x11c,
    O_ACTION = 0x14c,
    O_TIMER = 0x154,
    O_PREV_ACTION = 0x18c,
    O_BHV_PARAMS = 0x188,
    O_BEHAVIOR = 0x20c,
    O_GRAPH_Y_OFFSET = 0x0dc,
};

enum {
    M_ACTION = 0x0c,
    M_ACTION_ARG = 0x1c,
    M_POS_X = 0x3c,
    M_POS_Y = 0x40,
    M_POS_Z = 0x44,
    M_FLOOR = 0x68,
    M_FLOOR_HEIGHT = 0x70,
    M_USED_OBJ = 0x80,
    SURFACE_OBJECT = 0x2c,
};

enum {
    ACT_DISAPPEARED = 0x00001300,
    WARP_OBJECT_ACTION_ARG_2 = 0x00040002,
};

typedef unsigned int (*read32_fn)(unsigned int);
typedef unsigned short (*read16_fn)(unsigned int);
typedef void (*write32_fn)(unsigned int, unsigned int);

static read32_fn R32;
static read16_fn R16;
static write32_fn W32;
static ptr_DebugSetCallbacks DSetCallbacks;
static ptr_DebugSetRunState DSetRunState;
static ptr_DebugStep DStep;
static ptr_DebugGetCPUDataPtr DGetCPUDataPtr;
static ptr_DebugBreakpointCommand DBreakpointCommand;
static ptr_DebugDecodeOp DDecodeOp;
static ptr_DebugBreakpointTriggeredBy DBreakpointTriggeredBy;
static ptr_DebugVirtualToPhysical DVirtualToPhysical;

static uint64_t gPoll;
static uint32_t gTop;
static uint32_t gUpperWarp;
static uint32_t gWatchedSlot;
static uint32_t gPreviousTimer;
static int gPuzzleArmed;
static int gBoundaryInstalled;
static int gSawExplosionFree;
static int gSawArea2;
static uint32_t gArea2StartTimer;
static uint32_t gUpperTrigger;
static uint32_t gHiddenStarController;
static int32_t gInitialHiddenCounter;
static int32_t gMaxHiddenCounter;
static int gAPressedFrames;
static int gADownFrames;
static int gControllerAFrames;
static int gTriggerEverInactive;
static int gBreakpointTraceArmed;
static int gFirstApplyEntrySeen;
static int gFirstApplyReturnSeen;
static uint32_t gFirstApplyReturnPC;
static int gPostTraceActive;
static int gPostTraceComplete;
static int gPostTraceSequential = 1;
static unsigned gPostTraceSamples;
static unsigned gPostTraceWatchedWrites;
static unsigned gPostTraceInvariantFailures;
static unsigned gPostSafeWatchedWrites;
static unsigned gPostUnsafeWatchedWrites;
static unsigned gPostMarioLevelInfoCalls;
static unsigned gPostMarioUpdateCalls;
static unsigned gPostMarioDebugSpawnCalls;
static unsigned gPostAllocateObjectCalls;
static unsigned gPostAllocatorFallbackCalls;
static unsigned gPostUnloadObjectCalls;
static unsigned gPostStopSoundsFromSourceCalls;
static unsigned gPostStopSoundsContinuousCalls;
static unsigned gPostPrintTextCalls;
static unsigned gPostPrintTextFmtIntCalls;
static unsigned gPostDebugPrintTextCallsites;
static unsigned gPostDebugPrintTextFmtIntCallsites;
static uint32_t gPostWatchWriteHash = 2166136261u;
static uint32_t gPostStartGlobalTimer;
static uint32_t gPostLastGlobalTimer;
static uint32_t gPostMarioLevelInfo;
static uint32_t gPostMarioUpdate;
static uint32_t gPostMarioDebugSpawn;
static uint32_t gPostBhvMarioHash;
static uint32_t gPostBehaviorCmdTableHash;

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

static void post_hash_word(uint32_t word) {
    gPostWatchWriteHash ^= word;
    gPostWatchWriteHash *= 16777619u;
}

static uint32_t word_hash(uint32_t address, unsigned word_count) {
    uint32_t hash = 2166136261u;
    unsigned index;

    for (index = 0; index < word_count; index++) {
        hash ^= R32(address + index * 4);
        hash *= 16777619u;
    }
    return hash;
}

static uint32_t bhv_mario_word_hash(void) {
    return word_hash(A_BHV_MARIO, BHV_MARIO_WORDS);
}

static uint32_t behavior_cmd_table_word_hash(void) {
    return word_hash(A_BEHAVIOR_CMD_TABLE, BEHAVIOR_CMD_TABLE_WORDS);
}

static int post_identity_holds(void) {
    return R32(A_MARIO_OBJECT) == A_SLOT67
        && R32(A_STATE_MARIO_OBJECT) == A_SLOT67
        && R16(A_SLOT67_ACTIVE_FLAGS) == 0x0101
        && R32(A_SLOT67_BEHAVIOR) == A_BHV_MARIO
        && R32(A_SLOT67_NEXT) == 0x8033b870
        && R32(A_SLOT67_PREV) == 0x8033b870
        && R32(A_LIST0_SENTINEL_NEXT) == A_SLOT67
        && R32(A_LIST0_SENTINEL_PREV) == A_SLOT67
        && (R32(A_SLOT67_FLAGS) & 1) == 0
        && R32(A_SLOT67_GRAPH_Y_OFFSET) == 0
        && bhv_mario_word_hash() == gPostBhvMarioHash
        && behavior_cmd_table_word_hash() == gPostBehaviorCmdTableHash;
}

static int pool_index(uint32_t pointer) {
    uint32_t delta;

    if (pointer < A_OBJECT_POOL) {
        return -1;
    }
    delta = pointer - A_OBJECT_POOL;
    if (delta >= OBJECT_COUNT * OBJECT_SIZE || delta % OBJECT_SIZE != 0) {
        return -1;
    }
    return (int) (delta / OBJECT_SIZE);
}

static uint32_t pool_pointer(unsigned index) {
    return A_OBJECT_POOL + index * OBJECT_SIZE;
}

static int is_free_slot(uint32_t pointer) {
    int index = pool_index(pointer);
    return index >= 0 && R16(pointer + O_ACTIVE_FLAGS) == 0;
}

/*
 * The free-list sentinel address is not needed.  Free objects form one
 * singly-linked chain ending in NULL.  Find the longest valid chain starting
 * at an inactive pool slot; its head is the free-list head.
 */
static int free_chain_from(uint32_t head, int target_index, int *target_depth) {
    unsigned char seen[OBJECT_COUNT];
    uint32_t cursor = head;
    int length = 0;

    memset(seen, 0, sizeof(seen));
    *target_depth = -1;
    while (cursor != 0) {
        int index = pool_index(cursor);
        if (index < 0 || !is_free_slot(cursor) || seen[index]) {
            return -1;
        }
        seen[index] = 1;
        if (index == target_index) {
            *target_depth = length;
        }
        length++;
        cursor = R32(cursor + HEADER_NEXT);
    }
    return length;
}

static int watched_free_depth(int *chain_length, int *head_index) {
    int target_index = pool_index(gWatchedSlot);
    int best_length = -1;
    int best_depth = -1;
    int best_head = -1;
    unsigned i;

    for (i = 0; i < OBJECT_COUNT; i++) {
        uint32_t candidate = pool_pointer(i);
        int depth;
        int length;
        if (!is_free_slot(candidate)) {
            continue;
        }
        length = free_chain_from(candidate, target_index, &depth);
        if (length > best_length) {
            best_length = length;
            best_depth = depth;
            best_head = (int) i;
        }
    }
    *chain_length = best_length;
    *head_index = best_head;
    return best_depth;
}

static int active_count(void) {
    int count = 0;
    unsigned i;
    for (i = 0; i < OBJECT_COUNT; i++) {
        if (R16(pool_pointer(i) + O_ACTIVE_FLAGS) != 0) {
            count++;
        }
    }
    return count;
}

static int32_t hidden_counter(void) {
    if (gHiddenStarController == 0) return -1;
    return (int32_t) R32(gHiddenStarController
                          + O_PYRAMID_PILLARS_TOUCHED);
}

static void find_area2_hidden_objects(void) {
    unsigned i;

    gUpperTrigger = 0;
    gHiddenStarController = 0;
    for (i = 0; i < OBJECT_COUNT; i++) {
        uint32_t object = pool_pointer(i);
        if (R16(object + O_ACTIVE_FLAGS) == 0) continue;
        if (rfloat(object + O_POS_X) == 260.0f
            && rfloat(object + O_POS_Y) == 3913.0f
            && rfloat(object + O_POS_Z) == -600.0f) {
            gUpperTrigger = object;
        }
        if (rfloat(object + O_POS_X) == 900.0f
            && rfloat(object + O_POS_Y) == 1400.0f
            && rfloat(object + O_POS_Z) == 2350.0f) {
            gHiddenStarController = object;
        }
    }
    gInitialHiddenCounter = hidden_counter();
    gMaxHiddenCounter = gInitialHiddenCounter;
    fprintf(stderr,
            "AREA2_OBJECTS,upper=%08x,upperActive=%u,controller=%08x,"
            "counter=%d\n",
            gUpperTrigger,
            gUpperTrigger ? R16(gUpperTrigger + O_ACTIVE_FLAGS) : 0,
            gHiddenStarController, gInitialHiddenCounter);
}

static void find_area1_objects(void) {
    unsigned i;

    gTop = 0;
    gUpperWarp = 0;
    for (i = 0; i < OBJECT_COUNT; i++) {
        uint32_t object = pool_pointer(i);
        if (R16(object + O_ACTIVE_FLAGS) == 0) {
            continue;
        }
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

    /* First floor query: Mario State view. */
    W32(A_MARIO_STATES + M_POS_X, fbits((float) STATE_X));
    W32(A_MARIO_STATES + M_POS_Y, fbits((float) STATE_Y));
    W32(A_MARIO_STATES + M_POS_Z, fbits((float) STATE_Z));

    /* Collision pass: Mario Object view at the upper warp center. */
    W32(mario_object + O_POS_X, R32(gUpperWarp + O_POS_X));
    W32(mario_object + O_POS_Y, R32(gUpperWarp + O_POS_Y));
    W32(mario_object + O_POS_Z, R32(gUpperWarp + O_POS_Z));

    /* Null-floor retry: Graphics view inside the timer-131 top face. */
    W32(mario_object + GFX_POS_X, fbits((float) GRAPHICS_X));
    W32(mario_object + GFX_POS_Y, fbits((float) GRAPHICS_Y));
    W32(mario_object + GFX_POS_Z, fbits((float) GRAPHICS_Z));

    W32(A_MARIO_PLATFORM, 0);
    gWatchedSlot = gTop;
}

static void install_post_owner_boundary(void) {
    uint32_t mario_object = R32(A_MARIO_OBJECT);
    float x = rfloat(gTop + O_POS_X);
    float y = rfloat(gTop + O_POS_Y) + 256.0f;
    float z = rfloat(gTop + O_POS_Z);

    W32(A_MARIO_STATES + M_ACTION, ACT_DISAPPEARED);
    W32(A_MARIO_STATES + M_ACTION_ARG, WARP_OBJECT_ACTION_ARG_2);
    W32(A_MARIO_STATES + M_USED_OBJ, gUpperWarp);
    W32(A_MARIO_STATES + M_POS_X, fbits(x));
    W32(A_MARIO_STATES + M_POS_Y, fbits(y));
    W32(A_MARIO_STATES + M_POS_Z, fbits(z));
    W32(A_MARIO_STATES + M_FLOOR_HEIGHT, fbits(y));
    W32(mario_object + O_POS_X, fbits(x));
    W32(mario_object + O_POS_Y, fbits(y));
    W32(mario_object + O_POS_Z, fbits(z));
    W32(mario_object + GFX_POS_X, fbits(x));
    W32(mario_object + GFX_POS_Y, fbits(y));
    W32(mario_object + GFX_POS_Z, fbits(z));
    W32(A_MARIO_PLATFORM, gTop);
    gWatchedSlot = gTop;
}

static void install_boundary(void) {
    if (BOUNDARY_POST_OWNER) {
        install_post_owner_boundary();
    } else {
        install_three_view_boundary();
    }
}

static void log_lifecycle(const char *tag) {
    int chain_length;
    int head_index;
    int depth = watched_free_depth(&chain_length, &head_index);
    uint32_t slot = gWatchedSlot;
    uint32_t mario_object = R32(A_MARIO_OBJECT);
    uint32_t floor = R32(A_MARIO_STATES + M_FLOOR);
    uint32_t floor_owner = floor == 0 ? 0 : R32(floor + SURFACE_OBJECT);

    fprintf(stderr,
            "%s,timer=%u,area=%u,activeCount=%d,top=%08x,slot=%d,"
            "active=%u,behavior=%08x,action=%d,prevAction=%d,objTimer=%d,"
            "pos=(%.6f,%.6f,%.6f),vel=(%.6f,%.6f,%.6f),"
            "face=(%d,%d,%d),angleVel=(%d,%d,%d),"
            "platform=%08x,timeStopState=%08x,marioAction=%08x,"
            "actionArg=%08x,usedObj=%08x,"
            "mario=(%.6f,%.6f,%.6f),object=(%.6f,%.6f,%.6f),"
            "graphics=(%.6f,%.6f,%.6f),floor=%08x,floorOwner=%08x,"
            "floorHeight=%.6f,"
            "marioBits=(%08x,%08x,%08x),"
            "objectBits=(%08x,%08x,%08x),"
            "graphicsBits=(%08x,%08x,%08x),"
            "upper=%08x,triggerActive=%u,counter=%d,"
            "freeDepth=%d,freeLength=%d,freeHead=%d\n",
            tag, R32(A_GLOBAL_TIMER), R16(A_CURR_AREA), active_count(),
            slot, pool_index(slot), R16(slot + O_ACTIVE_FLAGS),
            R32(slot + O_BEHAVIOR), (int32_t) R32(slot + O_ACTION),
            (int32_t) R32(slot + O_PREV_ACTION),
            (int32_t) R32(slot + O_TIMER),
            rfloat(slot + O_POS_X), rfloat(slot + O_POS_Y),
            rfloat(slot + O_POS_Z), rfloat(slot + O_VEL_X),
            rfloat(slot + O_VEL_Y), rfloat(slot + O_VEL_Z),
            (int32_t) R32(slot + O_FACE_PITCH),
            (int32_t) R32(slot + O_FACE_YAW),
            (int32_t) R32(slot + O_FACE_ROLL),
            (int32_t) R32(slot + O_ANGLE_VEL_PITCH),
            (int32_t) R32(slot + O_ANGLE_VEL_YAW),
            (int32_t) R32(slot + O_ANGLE_VEL_ROLL),
            R32(A_MARIO_PLATFORM), R32(A_TIME_STOP_STATE),
            R32(A_MARIO_STATES + M_ACTION),
            R32(A_MARIO_STATES + M_ACTION_ARG),
            R32(A_MARIO_STATES + M_USED_OBJ),
            rfloat(A_MARIO_STATES + M_POS_X),
            rfloat(A_MARIO_STATES + M_POS_Y),
            rfloat(A_MARIO_STATES + M_POS_Z),
            rfloat(mario_object + O_POS_X),
            rfloat(mario_object + O_POS_Y),
            rfloat(mario_object + O_POS_Z),
            rfloat(mario_object + GFX_POS_X),
            rfloat(mario_object + GFX_POS_Y),
            rfloat(mario_object + GFX_POS_Z),
            floor, floor_owner,
            rfloat(A_MARIO_STATES + M_FLOOR_HEIGHT),
            R32(A_MARIO_STATES + M_POS_X),
            R32(A_MARIO_STATES + M_POS_Y),
            R32(A_MARIO_STATES + M_POS_Z),
            R32(mario_object + O_POS_X),
            R32(mario_object + O_POS_Y),
            R32(mario_object + O_POS_Z),
            R32(mario_object + GFX_POS_X),
            R32(mario_object + GFX_POS_Y),
            R32(mario_object + GFX_POS_Z),
            gUpperTrigger,
            gUpperTrigger ? R16(gUpperTrigger + O_ACTIVE_FLAGS) : 0,
            hidden_counter(),
            depth, chain_length, head_index);
}

static int add_exec_breakpoint(uint32_t address) {
    m64p_breakpoint breakpoint;

    breakpoint.address = address;
    breakpoint.endaddr = address;
    breakpoint.flags = M64P_BKP_FLAG_ENABLED | M64P_BKP_FLAG_EXEC;
    return DBreakpointCommand(M64P_BKP_CMD_ADD_STRUCT, 0, &breakpoint) >= 0;
}

static int add_write_breakpoint(uint32_t address, uint32_t size) {
    m64p_breakpoint breakpoint;

    breakpoint.address = DVirtualToPhysical(address);
    breakpoint.endaddr = breakpoint.address + size - 1;
    breakpoint.flags = M64P_BKP_FLAG_ENABLED | M64P_BKP_FLAG_WRITE;
    return DBreakpointCommand(M64P_BKP_CMD_ADD_STRUCT, 0, &breakpoint) >= 0;
}

static const char *post_watched_cell(uint32_t address) {
    if (address >= A_BHV_MARIO
        && address < A_BHV_MARIO + BHV_MARIO_WORDS * 4) {
        return "bhvMario.commandBytes";
    }
    if (address >= A_BEHAVIOR_CMD_TABLE
        && address < A_BEHAVIOR_CMD_TABLE + BEHAVIOR_CMD_TABLE_WORDS * 4) {
        return "BehaviorCmdTable.dispatchBytes";
    }
    switch (address) {
        case A_MARIO_OBJECT: return "gMarioObject";
        case A_STATE_MARIO_OBJECT: return "MarioState.object";
        case A_SLOT67_NEXT: return "slot67.next";
        case A_SLOT67_PREV: return "slot67.prev";
        case A_SLOT67_ACTIVE_FLAGS: return "slot67.activeFlags";
        case A_SLOT67_FLAGS: return "slot67.oFlags";
        case A_SLOT67_GRAPH_Y_OFFSET: return "slot67.oGraphYOffset";
        case A_SLOT67_BEHAVIOR: return "slot67.behavior";
        case A_LIST0_SENTINEL_NEXT: return "list0.next";
        case A_LIST0_SENTINEL_PREV: return "list0.prev";
        default: return NULL;
    }
}

static void log_post_watched_write(uint32_t pc, uint64_t *registers) {
    uint32_t trigger_flags = 0;
    uint32_t accessed = 0;
    uint32_t instruction;
    uint32_t opcode;
    uint32_t base_register;
    uint32_t source_register;
    int32_t displacement;
    uint32_t effective_address;
    uint32_t source_value;
    const char *cell;
    const char *classification = "unsafe-unclassified";
    int safe = 0;
    char mnemonic[32] = "unknown";
    char arguments[96] = "unknown";

    DBreakpointTriggeredBy(&trigger_flags, &accessed);
    if (!gPostTraceActive || gPostTraceComplete
        || (trigger_flags & M64P_BKP_FLAG_WRITE) == 0) {
        return;
    }
    cell = post_watched_cell(accessed | 0x80000000u);
    if (cell == NULL) return;
    instruction = R32(pc);
    opcode = instruction >> 26;
    base_register = (instruction >> 21) & 31;
    source_register = (instruction >> 16) & 31;
    displacement = (int16_t) instruction;
    effective_address = registers == NULL ? 0
        : (uint32_t) registers[base_register] + displacement;
    source_value = registers == NULL ? 0
        : (uint32_t) registers[source_register];
    if (DDecodeOp != NULL) {
        DDecodeOp(instruction, mnemonic, arguments, (int) pc);
    }
    if (effective_address == A_SLOT67_ACTIVE_FLAGS + 2
        && opcode == 0x29 && source_value == 0) {
        classification = "disjoint-slot67-padding-halfword";
        safe = 1;
    }
    gPostTraceWatchedWrites++;
    if (safe) gPostSafeWatchedWrites++;
    else gPostUnsafeWatchedWrites++;
    post_hash_word(R32(A_GLOBAL_TIMER));
    post_hash_word(pc);
    post_hash_word(instruction);
    post_hash_word(effective_address);
    post_hash_word(opcode);
    post_hash_word(source_value);
    fprintf(stderr,
            "SPINNING_POST_WATCH_WRITE,ordinal=%u,globalTimer=%u,"
            "pc=%08x,instruction=%08x,op=%02x,mnemonic=%s,args=%s,"
            "target=%08x,accessedPhysical=%08x,cell=%s,gprSource=%08x,"
            "classification=%s,safe=%d\n",
            gPostTraceWatchedWrites, R32(A_GLOBAL_TIMER), pc, instruction,
            opcode, mnemonic, arguments, effective_address, accessed, cell,
            source_value, classification, safe);
}

static void start_spinning_post_entry_trace(void) {
    int armed;

    find_area1_objects();
    if (gTop == 0 || R32(A_GLOBAL_TIMER) != 348
        || R32(A_MARIO_OBJECT) != A_SLOT67) {
        return;
    }
    gPostMarioLevelInfo = R32(A_BHV_MARIO + 8 * 4);
    gPostMarioUpdate = R32(A_BHV_MARIO + 10 * 4);
    gPostMarioDebugSpawn = R32(A_BHV_MARIO + 12 * 4);
    gPostBhvMarioHash = bhv_mario_word_hash();
    gPostBehaviorCmdTableHash = behavior_cmd_table_word_hash();
    armed = add_write_breakpoint(A_MARIO_OBJECT, 4)
        && add_write_breakpoint(A_STATE_MARIO_OBJECT, 4)
        && add_write_breakpoint(A_SLOT67_NEXT, 4)
        && add_write_breakpoint(A_SLOT67_PREV, 4)
        && add_write_breakpoint(A_SLOT67_ACTIVE_FLAGS, 2)
        && add_write_breakpoint(A_SLOT67_FLAGS, 4)
        && add_write_breakpoint(A_SLOT67_GRAPH_Y_OFFSET, 4)
        && add_write_breakpoint(A_SLOT67_BEHAVIOR, 4)
        && add_write_breakpoint(A_LIST0_SENTINEL_NEXT, 4)
        && add_write_breakpoint(A_LIST0_SENTINEL_PREV, 4)
        && add_write_breakpoint(A_BHV_MARIO, BHV_MARIO_WORDS * 4)
        && add_write_breakpoint(A_BEHAVIOR_CMD_TABLE,
                                BEHAVIOR_CMD_TABLE_WORDS * 4)
        && add_exec_breakpoint(gPostMarioLevelInfo)
        && add_exec_breakpoint(gPostMarioUpdate)
        && add_exec_breakpoint(gPostMarioDebugSpawn)
        && add_exec_breakpoint(A_ALLOCATE_OBJECT)
        && add_exec_breakpoint(A_ALLOCATE_OBJECT_UNLOAD_CALL)
        && add_exec_breakpoint(A_UNLOAD_OBJECT)
        && add_exec_breakpoint(A_STOP_SOUNDS_FROM_SOURCE)
        && add_exec_breakpoint(A_STOP_SOUNDS_IN_CONTINUOUS_BANKS)
        && add_exec_breakpoint(A_PRINT_TEXT)
        && add_exec_breakpoint(A_PRINT_TEXT_FMT_INT)
        && add_exec_breakpoint(A_DEBUG_PRINT_TEXT_CALLSITE)
        && add_exec_breakpoint(A_DEBUG_PRINT_TEXT_FMT_INT_CALLSITE);
    if (!armed) {
        fprintf(stderr, "SPINNING_POST_TRACE_ERROR,kind=breakpoint-arm\n");
        return;
    }
    gPostTraceActive = 1;
    gPostStartGlobalTimer = R32(A_GLOBAL_TIMER);
    gPostLastGlobalTimer = gPostStartGlobalTimer - 1;
    fprintf(stderr,
            "SPINNING_POST_TRACE_START,globalTimer=%u,topAction=%d,"
            "topTimer=%d,marioObject=%08x,slot=67,behavior=%08x,"
            "oFlags=%08x,oGraphYOffsetBits=%08x,bhvMarioHash=%08x,"
            "behaviorCmdTable=%08x,behaviorCmdTableHash=%08x,"
            "levelInfoCallback=%08x,marioUpdateCallback=%08x,"
            "debugSpawnCallback=%08x,watchRanges=12,invariant=%d\n",
            gPostStartGlobalTimer, (int32_t) R32(gTop + O_ACTION),
            (int32_t) R32(gTop + O_TIMER), R32(A_MARIO_OBJECT),
            R32(A_SLOT67_BEHAVIOR), R32(A_SLOT67_FLAGS),
            R32(A_SLOT67_GRAPH_Y_OFFSET), gPostBhvMarioHash,
            A_BEHAVIOR_CMD_TABLE, gPostBehaviorCmdTableHash,
            gPostMarioLevelInfo, gPostMarioUpdate, gPostMarioDebugSpawn,
            post_identity_holds());
}

static void observe_spinning_post_entry_trace(void) {
    uint32_t timer;

    if (!gPostTraceActive) {
        start_spinning_post_entry_trace();
    }
    if (!gPostTraceActive || gPostTraceComplete) return;
    timer = R32(A_GLOBAL_TIMER);
    if (timer == gPostLastGlobalTimer) return;
    gPostTraceSamples++;
    if (timer != gPostLastGlobalTimer + 1) gPostTraceSequential = 0;
    gPostLastGlobalTimer = timer;
    if (!post_identity_holds()) gPostTraceInvariantFailures++;
    if (R32(gTop + O_ACTION) == 1 && R32(gTop + O_TIMER) == INSTALL_TIMER) {
        fprintf(stderr,
                "SPINNING_POST_TRACE_END,startGlobalTimer=%u,"
                "endGlobalTimer=%u,endTopAction=%d,endTopTimer=%d,"
                "samples=%u,sequential=%d,watchedWrites=%u,"
                "invariantFailures=%u,safeWatchedWrites=%u,"
                "unsafeWatchedWrites=%u,watchWriteHash=%08x,"
                "marioObject=%08x,stateMarioObject=%08x,activeFlags=%04x,"
                "behavior=%08x,oFlags=%08x,oGraphYOffsetBits=%08x,"
                "next=%08x,prev=%08x,sentinelNext=%08x,sentinelPrev=%08x,"
                "bhvMarioHash=%08x,behaviorCmdTableHash=%08x,"
                "levelInfoCalls=%u,marioUpdateCalls=%u,debugSpawnCalls=%u,"
                "allocateObjectCalls=%u,allocatorFallbackCalls=%u,"
                "unloadObjectCalls=%u,stopSoundsFromSourceCalls=%u,"
                "stopSoundsContinuousCalls=%u,sqrtfFrame=all-path-store-free,"
                "printTextCalls=%u,printTextFmtIntCalls=%u,"
                "debugPrintTextCallsites=%u,debugPrintTextFmtIntCallsites=%u,"
                "fixture=top-pillar-count-only,invariant=%d\n",
                gPostStartGlobalTimer, timer,
                (int32_t) R32(gTop + O_ACTION),
                (int32_t) R32(gTop + O_TIMER), gPostTraceSamples,
                gPostTraceSequential, gPostTraceWatchedWrites,
                gPostTraceInvariantFailures, gPostSafeWatchedWrites,
                gPostUnsafeWatchedWrites, gPostWatchWriteHash,
                R32(A_MARIO_OBJECT), R32(A_STATE_MARIO_OBJECT),
                R16(A_SLOT67_ACTIVE_FLAGS), R32(A_SLOT67_BEHAVIOR),
                R32(A_SLOT67_FLAGS), R32(A_SLOT67_GRAPH_Y_OFFSET),
                R32(A_SLOT67_NEXT), R32(A_SLOT67_PREV),
                R32(A_LIST0_SENTINEL_NEXT), R32(A_LIST0_SENTINEL_PREV),
                bhv_mario_word_hash(), behavior_cmd_table_word_hash(),
                gPostMarioLevelInfoCalls, gPostMarioUpdateCalls,
                gPostMarioDebugSpawnCalls, gPostAllocateObjectCalls,
                gPostAllocatorFallbackCalls, gPostUnloadObjectCalls,
                gPostStopSoundsFromSourceCalls,
                gPostStopSoundsContinuousCalls, gPostPrintTextCalls,
                gPostPrintTextFmtIntCalls, gPostDebugPrintTextCallsites,
                gPostDebugPrintTextFmtIntCallsites, post_identity_holds());
        gPostTraceComplete = 1;
    }
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

    if (gPostTraceActive && gPostTraceComplete
        && pc != A_APPLY_MARIO_PLATFORM_DISPLACEMENT
        && pc != gFirstApplyReturnPC) {
        resume_from_breakpoint();
        return;
    }
    if (gPostTraceActive && !gPostTraceComplete) {
        if (pc == gPostMarioLevelInfo) gPostMarioLevelInfoCalls++;
        else if (pc == gPostMarioUpdate) gPostMarioUpdateCalls++;
        else if (pc == gPostMarioDebugSpawn) gPostMarioDebugSpawnCalls++;
        else if (pc == A_ALLOCATE_OBJECT) gPostAllocateObjectCalls++;
        else if (pc == A_ALLOCATE_OBJECT_UNLOAD_CALL) {
            gPostAllocatorFallbackCalls++;
        } else if (pc == A_UNLOAD_OBJECT) gPostUnloadObjectCalls++;
        else if (pc == A_STOP_SOUNDS_FROM_SOURCE) {
            gPostStopSoundsFromSourceCalls++;
        } else if (pc == A_STOP_SOUNDS_IN_CONTINUOUS_BANKS) {
            gPostStopSoundsContinuousCalls++;
        } else if (pc == A_PRINT_TEXT) {
            gPostPrintTextCalls++;
        } else if (pc == A_PRINT_TEXT_FMT_INT) {
            gPostPrintTextFmtIntCalls++;
        } else if (pc == A_DEBUG_PRINT_TEXT_CALLSITE) {
            gPostDebugPrintTextCallsites++;
        } else if (pc == A_DEBUG_PRINT_TEXT_FMT_INT_CALLSITE) {
            gPostDebugPrintTextFmtIntCallsites++;
        } else if (pc != A_APPLY_MARIO_PLATFORM_DISPLACEMENT
                   && pc != gFirstApplyReturnPC) {
            log_post_watched_write(pc, registers);
        }
        if (pc == gPostMarioLevelInfo || pc == gPostMarioUpdate
            || pc == gPostMarioDebugSpawn || pc == A_ALLOCATE_OBJECT
            || pc == A_ALLOCATE_OBJECT_UNLOAD_CALL || pc == A_UNLOAD_OBJECT
            || pc == A_STOP_SOUNDS_FROM_SOURCE
            || pc == A_STOP_SOUNDS_IN_CONTINUOUS_BANKS
            || pc == A_PRINT_TEXT || pc == A_PRINT_TEXT_FMT_INT
            || pc == A_DEBUG_PRINT_TEXT_CALLSITE
            || pc == A_DEBUG_PRINT_TEXT_FMT_INT_CALLSITE
            || (pc != A_APPLY_MARIO_PLATFORM_DISPLACEMENT
                && pc != gFirstApplyReturnPC)) {
            resume_from_breakpoint();
            return;
        }
    }
    if (pc == A_APPLY_MARIO_PLATFORM_DISPLACEMENT
        && (!gBoundaryInstalled || R16(A_CURR_AREA) != 2)) {
        resume_from_breakpoint();
        return;
    }
    if (pc == A_APPLY_MARIO_PLATFORM_DISPLACEMENT
        && !gFirstApplyEntrySeen) {
        gFirstApplyEntrySeen = 1;
        gFirstApplyReturnPC = registers == NULL
            ? 0 : (uint32_t) registers[31];
        fprintf(stderr,
                "BREAKPOINT_HIT,kind=true-first-apply-entry,pc=%08x,"
                "returnPC=%08x,area=%u,platform=%08x,slot=%d\n",
                pc, gFirstApplyReturnPC, R16(A_CURR_AREA),
                R32(A_MARIO_PLATFORM), pool_index(R32(A_MARIO_PLATFORM)));
        log_lifecycle("FIRST_APPLY_ENTRY");

        DBreakpointCommand(M64P_BKP_CMD_REMOVE_ADDR,
                           A_APPLY_MARIO_PLATFORM_DISPLACEMENT, NULL);
        if (gFirstApplyReturnPC == 0
            || !add_exec_breakpoint(gFirstApplyReturnPC)) {
            fprintf(stderr, "BREAKPOINT_ERROR,kind=return-arm\n");
        }
    } else if (pc == gFirstApplyReturnPC
               && gFirstApplyEntrySeen && !gFirstApplyReturnSeen) {
        gFirstApplyReturnSeen = 1;
        fprintf(stderr,
                "BREAKPOINT_HIT,kind=true-first-apply-return,pc=%08x,"
                "area=%u,platform=%08x,slot=%d\n",
                pc, R16(A_CURR_AREA), R32(A_MARIO_PLATFORM),
                pool_index(R32(A_MARIO_PLATFORM)));
        log_lifecycle("FIRST_APPLY_RETURN");
        DBreakpointCommand(M64P_BKP_CMD_REMOVE_ADDR,
                           gFirstApplyReturnPC, NULL);
    } else {
        fprintf(stderr, "BREAKPOINT_UNEXPECTED,pc=%08x\n", pc);
    }
    resume_from_breakpoint();
}

static void arm_first_apply_breakpoint_trace(void) {
    m64p_error callback_result;

    callback_result = DSetCallbacks(debugger_init_callback,
                                    debugger_update_callback,
                                    debugger_vi_callback);
    if (callback_result != M64ERR_SUCCESS) {
        fprintf(stderr,
                "BREAKPOINT_ERROR,kind=callback-arm,callbackResult=%d\n",
                callback_result);
        return;
    }
    gBreakpointTraceArmed = 1;
    fprintf(stderr,
            "BREAKPOINT_ARM,kind=callbacks-for-preinstalled-entry,"
            "address=%08x\n",
            A_APPLY_MARIO_PLATFORM_DISPLACEMENT);
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
    DSetCallbacks = (ptr_DebugSetCallbacks) dlsym(core, "DebugSetCallbacks");
    DSetRunState = (ptr_DebugSetRunState) dlsym(core, "DebugSetRunState");
    DStep = (ptr_DebugStep) dlsym(core, "DebugStep");
    DGetCPUDataPtr =
        (ptr_DebugGetCPUDataPtr) dlsym(core, "DebugGetCPUDataPtr");
    DBreakpointCommand =
        (ptr_DebugBreakpointCommand) dlsym(core,
                                           "DebugBreakpointCommand");
    DDecodeOp = (ptr_DebugDecodeOp) dlsym(core, "DebugDecodeOp");
    DBreakpointTriggeredBy =
        (ptr_DebugBreakpointTriggeredBy) dlsym(core,
                                               "DebugBreakpointTriggeredBy");
    DVirtualToPhysical =
        (ptr_DebugVirtualToPhysical) dlsym(core,
                                          "DebugVirtualToPhysical");
    return R32 && R16 && W32 && DSetCallbacks && DSetRunState && DStep
        && DGetCPUDataPtr && DBreakpointCommand && DDecodeOp
        && DBreakpointTriggeredBy && DVirtualToPhysical
        ? M64ERR_SUCCESS : M64ERR_INCOMPATIBLE;
}

EXPORT m64p_error CALL PluginShutdown(void) { return M64ERR_SUCCESS; }

EXPORT m64p_error CALL PluginGetVersion(
    m64p_plugin_type *type, int *version, int *api_version,
    const char **name, int *capabilities) {
    if (type) *type = M64PLUGIN_INPUT;
    if (version) *version = 0x000100;
    if (api_version) *api_version = 0x020100;
    if (name) *name = "SSL JP lifecycle boundary trace";
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
    gWatchedSlot = 0;
    gPreviousTimer = UINT32_MAX;
    gPuzzleArmed = 0;
    gBoundaryInstalled = 0;
    gSawExplosionFree = 0;
    gSawArea2 = 0;
    gArea2StartTimer = 0;
    gUpperTrigger = 0;
    gHiddenStarController = 0;
    gInitialHiddenCounter = -1;
    gMaxHiddenCounter = -1;
    gAPressedFrames = 0;
    gADownFrames = 0;
    gControllerAFrames = 0;
    gTriggerEverInactive = 0;
    gBreakpointTraceArmed = 0;
    gFirstApplyEntrySeen = 0;
    gFirstApplyReturnSeen = 0;
    gFirstApplyReturnPC = 0;
    gPostTraceActive = 0;
    gPostTraceComplete = 0;
    gPostTraceSequential = 1;
    gPostTraceSamples = 0;
    gPostTraceWatchedWrites = 0;
    gPostTraceInvariantFailures = 0;
    gPostSafeWatchedWrites = 0;
    gPostUnsafeWatchedWrites = 0;
    gPostMarioLevelInfoCalls = 0;
    gPostMarioUpdateCalls = 0;
    gPostMarioDebugSpawnCalls = 0;
    gPostAllocateObjectCalls = 0;
    gPostAllocatorFallbackCalls = 0;
    gPostUnloadObjectCalls = 0;
    gPostStopSoundsFromSourceCalls = 0;
    gPostStopSoundsContinuousCalls = 0;
    gPostPrintTextCalls = 0;
    gPostPrintTextFmtIntCalls = 0;
    gPostDebugPrintTextCallsites = 0;
    gPostDebugPrintTextFmtIntCallsites = 0;
    gPostWatchWriteHash = 2166136261u;
    gPostStartGlobalTimer = 0;
    gPostLastGlobalTimer = 0;
    gPostMarioLevelInfo = 0;
    gPostMarioUpdate = 0;
    gPostMarioDebugSpawn = 0;
    gPostBhvMarioHash = 0;
    gPostBehaviorCmdTableHash = 0;
    fprintf(stderr,
            "PROBE,version=JP,boundary=%s,"
            "installTimer=%d,controllerButtons=zero,routeStick=(%d,%d),"
            "routeFrames=0..%d,state=(%d,%d,%d),"
            "graphics=(%d,%d,%d)\n",
            BOUNDARY_POST_OWNER ? "post-owner" : "three-view",
            INSTALL_TIMER, ROUTE_STICK_X, ROUTE_STICK_Y,
            ROUTE_HOLD_FRAMES - 1,
            STATE_X, STATE_Y, STATE_Z,
            GRAPHICS_X, GRAPHICS_Y, GRAPHICS_Z);
    return 1;
}

EXPORT void CALL RomClosed(void) {
    fprintf(stderr,
            "RESULT,armed=%d,boundaryInstalled=%d,explosionFree=%d,area2=%d,"
            "aPressedFrames=%d,aDownFrames=%d,controllerAFrames=%d,"
            "triggerEverInactive=%d,initialCounter=%d,finalCounter=%d,"
            "maxCounter=%d,breakpointArmed=%d,firstApplyEntry=%d,"
            "firstApplyReturn=%d\n",
            gPuzzleArmed, gBoundaryInstalled, gSawExplosionFree, gSawArea2,
            gAPressedFrames, gADownFrames, gControllerAFrames,
            gTriggerEverInactive, gInitialHiddenCounter, hidden_counter(),
            gMaxHiddenCounter, gBreakpointTraceArmed,
            gFirstApplyEntrySeen, gFirstApplyReturnSeen);
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
    uint32_t timer;

    memset(keys, 0, sizeof(*keys));
    if (control != 0) return;
    gPoll++;

    /* run.sh installs the execution breakpoint before starting the CPU. */
    if (!gBreakpointTraceArmed) {
        arm_first_apply_breakpoint_trace();
    }

    /* Retail level-select menu navigation; all of this precedes the boundary. */
    if (gPoll >= 150 && gPoll < 156) keys->START_BUTTON = 1;
    for (slot = 220; slot <= 280; slot += 10) {
        if (gPoll >= slot && gPoll < slot + 2) keys->D_DPAD = 1;
    }
    if (gPoll >= 330 && gPoll < 336) keys->START_BUTTON = 1;

    area = R16(A_CURR_AREA);
    if (area == 1 && R32(A_MARIO_OBJECT) != 0) {
        observe_spinning_post_entry_trace();
    }
    if (!gPuzzleArmed && gPoll > 360 && area == 1 && R32(A_MARIO_OBJECT) != 0) {
        find_area1_objects();
        if (gTop != 0 && gUpperWarp != 0) {
            W32(gTop + O_PYRAMID_PILLARS_TOUCHED, 4);
            gPuzzleArmed = 1;
            fprintf(stderr,
                    "SPINNING_FIXTURE_WRITE,globalTimer=%u,target=%08x,"
                    "value=00000004,top=%08x,slot=%d,"
                    "classification=distinct-slot61-field,safe=1\n",
                    R32(A_GLOBAL_TIMER),
                    gTop + O_PYRAMID_PILLARS_TOUCHED, gTop,
                    pool_index(gTop));
            fprintf(stderr,
                    "ARM,top=%08x,slot=%d,upperWarp=%08x,"
                    "upperParams=%08x\n",
                    gTop, pool_index(gTop), gUpperWarp,
                    R32(gUpperWarp + O_BHV_PARAMS));
        }
    }

    if (gPuzzleArmed && !gBoundaryInstalled && area == 1
        && R32(gTop + O_ACTION) == 1
        && R32(gTop + O_TIMER) == INSTALL_TIMER) {
        install_boundary();
        gBoundaryInstalled = 1;
        log_lifecycle("INSTALL");
    }

    timer = R32(A_GLOBAL_TIMER);
    if (gBoundaryInstalled && area == 2) {
        uint16_t input = R16(A_MARIO_STATES + 0x02);
        int32_t counter;

        if (!gSawArea2) {
            gArea2StartTimer = timer;
            find_area2_hidden_objects();
        }
        if (timer - gArea2StartTimer < ROUTE_HOLD_FRAMES) {
            keys->X_AXIS = ROUTE_STICK_X;
            keys->Y_AXIS = ROUTE_STICK_Y;
        }
        if ((input & 0x0002) != 0) gAPressedFrames++;
        if ((input & 0x0080) != 0) gADownFrames++;
        if (keys->A_BUTTON) gControllerAFrames++;
        if (gUpperTrigger != 0
            && R16(gUpperTrigger + O_ACTIVE_FLAGS) == 0) {
            gTriggerEverInactive = 1;
        }
        counter = hidden_counter();
        if (counter > gMaxHiddenCounter) gMaxHiddenCounter = counter;
    }

    if (gBoundaryInstalled && timer != gPreviousTimer) {
        gPreviousTimer = timer;
        log_lifecycle(area == 1 ? "TRACE_A1" : "TRACE_A2");
        if (!gSawExplosionFree && R16(gWatchedSlot + O_ACTIVE_FLAGS) == 0) {
            gSawExplosionFree = 1;
            log_lifecycle("EXPLOSION_FREE");
        }
        if (!gSawArea2 && area == 2) {
            gSawArea2 = 1;
            log_lifecycle("FIRST_AREA2_POLL");
        }
    }
}
