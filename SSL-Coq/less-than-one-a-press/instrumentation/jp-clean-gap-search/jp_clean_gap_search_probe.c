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

/* Slot 67 and list-0 addresses from the authenticated endpoint.  Write
 * breakpoints only observe stores made by the retail CPU; they do not alter
 * RAM.  The watched set is exactly the identity/tail data used by the entry
 * theorem. */
enum {
    A_SLOT67 = 0x80346038,
    A_SLOT67_NEXT = 0x80346098,
    A_SLOT67_PREV = 0x8034609c,
    A_SLOT67_ACTIVE_FLAGS = 0x803460ac,
    A_SLOT67_FLAGS = 0x803460c4,
    A_SLOT67_GRAPH_Y_OFFSET = 0x80346114,
    A_SLOT67_BEHAVIOR = 0x80346244,
    /* The list-0 sentinel object is 0x8033b870; its embedded ObjectNode links
     * use the same +0x60/+0x64 layout as a pool Object. */
    A_LIST0_SENTINEL_NEXT = 0x8033b8d0,
    A_LIST0_SENTINEL_PREV = 0x8033b8d4,
    A_STATE_MARIO_OBJECT = 0x80339e88,
    A_BHV_MARIO = 0x800eb1c0,
    BHV_MARIO_WORDS = 14,
    A_BEHAVIOR_CMD_TABLE = 0x8038b9b0,
    BEHAVIOR_CMD_TABLE_WORDS = 56,
};

/* Original-JP text addresses from a matching build whose SHA-1 is the retail
 * 8a20a5c8... hash.  These are execute breakpoints only: the probe never
 * patches code or game data. */
enum {
    A_INIT_MARIO = 0x802548bc,
    A_LOAD_MARIO_AREA = 0x8027aa0c,
    A_SPAWN_OBJECTS_FROM_INFO = 0x8029c830,
    A_CLEAR_OBJECTS = 0x8029ca60,
    A_UNLOAD_OBJECT = 0x802c9088,
    A_ALLOCATE_OBJECT = 0x802c9120,
    A_ALLOCATE_OBJECT_UNLOAD_CALL = 0x802c9174,
    A_STOP_SOUNDS_FROM_SOURCE = 0x803206f8,
    A_STOP_SOUNDS_IN_CONTINUOUS_BANKS = 0x80320890,
};

enum {
    OBJECT_SIZE = 0x260,
    OBJECT_COUNT = 240,
    O_PREV_OBJ = 0x06c,
    HEADER_NEXT = 0x060,
    HEADER_PREV = 0x064,
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
    O_HOME_X = 0x164,
    O_HOME_Z = 0x16c,
    O_BHV_PARAMS = 0x188,
    O_BEHAVIOR = 0x20c,
};

enum {
    M_INPUT = 0x02,
    M_ACTION = 0x0c,
    M_ACTION_TIMER = 0x1a,
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
    M_MARIO_OBJ = 0x88,
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
    ACT_DIVE = 0x0188088a,
    ACT_DIVE_SLIDE = 0x00880456,
    ACT_STOMACH_SLIDE = 0x008c0453,
    ACT_CRAZY_BOX_BOUNCE = 0x000008ae,
    ACT_TWIRLING = 0x108008a4,
    ACT_TORNADO_TWIRLING = 0x10020372,
    INTERACT_KOOPA_SHELL = 0x00080000,
    INTERACT_TORNADO = 0x01000000,
    ACTIVE_PARTICLE_FIRE = 0x00000800,
};

typedef unsigned int (*read32_fn)(unsigned int);
typedef unsigned short (*read16_fn)(unsigned int);

static read32_fn R32;
static read16_fn R16;
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
static uint32_t gShellBox;
static uint32_t gShell;
static uint32_t gJumpingBox;
static uint32_t gWestJumpingBox;
static uint32_t gEastNorthTweester;
static uint32_t gSoutheastTweester;
static uint32_t gWestTweester;
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
static int gMode9Stage;
static int gMode9WestRimStage;
static int gMode9DetectorDiveInputs;
static int gMode9RolloutInputs;
static int gMode9SurvivalBInputs;
static int gMode9WestBoxContact;
static int gMode9WestDetectorReached;
static int gMode9NorthwestDetectorReached;
static int gMode9SourceTweesterCaptured;
static int gMode9EastNorthTweesterCaptured;
static int gMode9WestTweesterCaptured;
static int gMode10NorthAvoidanceReached;
static float gMode9WestmostX = INFINITY;
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
static int gEntryIdentityLogged;
static int gPrefixTraceArmed;
static int gPrefixStage;
static unsigned gPrefixEpoch;
static unsigned gPrefixCellWriteCount;
static unsigned gPrefixAllocateObjectHits;
static unsigned gPrefixAllocatorFallbackHits;
static unsigned gPrefixUnloadObjectHits;
static unsigned gPrefixStopSoundsFromSourceHits;
static unsigned gPrefixStopSoundsContinuousHits;
static uint32_t gPrefixStopSoundsFromSourceEntrySP;
static uint32_t gPrefixStopSoundsContinuousEntrySP;
static int gPostTraceActive;
static int gPostTraceComplete;
static int gPostTraceSequential = 1;
static unsigned gPostTraceSamples;
static unsigned gPostTraceWatchedWrites;
static unsigned gPostTraceInvariantFailures;
static unsigned gPostMarioLevelInfoCalls;
static unsigned gPostMarioUpdateCalls;
static unsigned gPostMarioDebugSpawnCalls;
static unsigned gPostAllocateObjectCalls;
static unsigned gPostAllocatorFallbackCalls;
static unsigned gPostUnloadObjectCalls;
static unsigned gPostStopSoundsFromSourceCalls;
static unsigned gPostStopSoundsContinuousCalls;
static unsigned gPostSafeWatchedWrites;
static unsigned gPostUnsafeWatchedWrites;
static uint32_t gPostWatchWriteHash = 2166136261u;
static uint32_t gPostStartGlobalTimer;
static int gPostStartTopTimer;
static int gPostLastTopTimer;
static uint32_t gPostMarioLevelInfo;
static uint32_t gPostMarioUpdate;
static uint32_t gPostMarioDebugSpawn;
static uint32_t gPostBhvMarioHash;
static uint32_t gPostBehaviorCmdTableHash;
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

static void post_hash_word(uint32_t word) {
    gPostWatchWriteHash ^= word;
    gPostWatchWriteHash *= 16777619u;
}

static int pool_index(uint32_t object) {
    uint32_t offset;

    if (object < A_OBJECT_POOL) return -1;
    offset = object - A_OBJECT_POOL;
    if (offset % OBJECT_SIZE != 0 || offset / OBJECT_SIZE >= OBJECT_COUNT) {
        return -1;
    }
    return (int) (offset / OBJECT_SIZE);
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

static const char *watched_prefix_cell(uint32_t address) {
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

static void log_prefix_cell_write(uint32_t pc, uint64_t *registers) {
    uint32_t trigger_flags = 0;
    uint32_t accessed = 0;
    uint32_t instruction = R32(pc);
    uint32_t opcode = instruction >> 26;
    uint32_t base_register = (instruction >> 21) & 31;
    uint32_t source_register = (instruction >> 16) & 31;
    int32_t displacement = (int16_t) instruction;
    uint32_t effective_address = registers == NULL ? 0
        : (uint32_t) registers[base_register] + displacement;
    uint32_t source_value = registers == NULL ? 0
        : (uint32_t) registers[source_register];
    const char *cell;
    char mnemonic[32] = "unknown";
    char arguments[96] = "unknown";

    DBreakpointTriggeredBy(&trigger_flags, &accessed);
    if ((trigger_flags & M64P_BKP_FLAG_WRITE) == 0) return;
    cell = watched_prefix_cell(accessed | 0x80000000u);
    if (cell == NULL || gPrefixStage == 0) return;
    if (DDecodeOp != NULL) {
        DDecodeOp(instruction, mnemonic, arguments, (int) pc);
    }
    if (gEntryIdentityLogged) {
        const char *classification = "unsafe-unclassified";
        int safe = 0;
        if (!gPostTraceActive || gPostTraceComplete) return;
        if (effective_address == A_SLOT67_ACTIVE_FLAGS + 2 && opcode == 0x29) {
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
                "POST_ENTRY_WATCH_WRITE,ordinal=%u,globalTimer=%u,"
                "pc=%08x,instruction=%08x,op=%02x,mnemonic=%s,args=%s,"
                "target=%08x,accessedPhysical=%08x,cell=%s,"
                "gprSource=%08x,classification=%s,safe=%d\n",
                gPostTraceWatchedWrites, R32(A_GLOBAL_TIMER), pc,
                instruction, opcode, mnemonic, arguments, effective_address,
                accessed, cell, source_value, classification, safe);
        return;
    }
    gPrefixCellWriteCount++;
    fprintf(stderr,
            "PREFIX_CELL_WRITE,epoch=%u,ordinal=%u,stage=%d,timer=%u,"
            "pc=%08x,instruction=%08x,op=%02x,mnemonic=%s,args=%s,"
            "target=%08x,accessedPhysical=%08x,cell=%s,gprSource=%08x,"
            "flagNow=%08x,graphOffsetNow=%08x\n",
            gPrefixEpoch, gPrefixCellWriteCount, gPrefixStage,
            R32(A_GLOBAL_TIMER), pc, instruction, opcode, mnemonic, arguments,
            effective_address, accessed, cell, source_value,
            R32(A_SLOT67_FLAGS), R32(A_SLOT67_GRAPH_Y_OFFSET));
}

static void observe_post_callback(uint32_t pc) {
    if (!gPostTraceActive || gPostTraceComplete) return;
    if (pc == gPostMarioLevelInfo) gPostMarioLevelInfoCalls++;
    else if (pc == gPostMarioUpdate) gPostMarioUpdateCalls++;
    else if (pc == gPostMarioDebugSpawn) gPostMarioDebugSpawnCalls++;
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
    uint32_t argument0 = registers == NULL ? 0 : (uint32_t) registers[4];
    uint32_t argument1 = registers == NULL ? 0 : (uint32_t) registers[5];
    uint32_t return_pc = registers == NULL ? 0 : (uint32_t) registers[31];
    uint32_t mario_object = R32(A_MARIO_OBJECT);
    const char *stage = "unexpected";

    if (pc == A_ALLOCATE_OBJECT || pc == A_ALLOCATE_OBJECT_UNLOAD_CALL
        || pc == A_UNLOAD_OBJECT || pc == A_STOP_SOUNDS_FROM_SOURCE
        || pc == A_STOP_SOUNDS_IN_CONTINUOUS_BANKS) {
        if (gPrefixStage != 0 && !gEntryIdentityLogged) {
            if (pc == A_ALLOCATE_OBJECT) gPrefixAllocateObjectHits++;
            else if (pc == A_ALLOCATE_OBJECT_UNLOAD_CALL) {
                gPrefixAllocatorFallbackHits++;
            } else if (pc == A_UNLOAD_OBJECT) gPrefixUnloadObjectHits++;
            else if (pc == A_STOP_SOUNDS_FROM_SOURCE) {
                gPrefixStopSoundsFromSourceHits++;
                if (gPrefixStopSoundsFromSourceEntrySP == 0 && registers != NULL) {
                    gPrefixStopSoundsFromSourceEntrySP = (uint32_t) registers[29];
                }
            } else if (pc == A_STOP_SOUNDS_IN_CONTINUOUS_BANKS) {
                gPrefixStopSoundsContinuousHits++;
                if (gPrefixStopSoundsContinuousEntrySP == 0 && registers != NULL) {
                    gPrefixStopSoundsContinuousEntrySP = (uint32_t) registers[29];
                }
            }
        }
        if (gPostTraceActive && !gPostTraceComplete) {
            if (pc == A_ALLOCATE_OBJECT) gPostAllocateObjectCalls++;
            else if (pc == A_ALLOCATE_OBJECT_UNLOAD_CALL) {
                gPostAllocatorFallbackCalls++;
            } else if (pc == A_UNLOAD_OBJECT) gPostUnloadObjectCalls++;
            else if (pc == A_STOP_SOUNDS_FROM_SOURCE) {
                gPostStopSoundsFromSourceCalls++;
            } else if (pc == A_STOP_SOUNDS_IN_CONTINUOUS_BANKS) {
                gPostStopSoundsContinuousCalls++;
            }
        }
        resume_from_breakpoint();
        return;
    }

    if (pc != A_CLEAR_OBJECTS && pc != A_LOAD_MARIO_AREA
        && pc != A_SPAWN_OBJECTS_FROM_INFO && pc != A_INIT_MARIO) {
        log_prefix_cell_write(pc, registers);
        observe_post_callback(pc);
        resume_from_breakpoint();
        return;
    }

    if (pc == A_CLEAR_OBJECTS) {
        stage = "clear_objects";
        gPrefixStage = 1;
        gPrefixEpoch++;
        gPrefixCellWriteCount = 0;
        gPrefixAllocateObjectHits = 0;
        gPrefixAllocatorFallbackHits = 0;
        gPrefixUnloadObjectHits = 0;
        gPrefixStopSoundsFromSourceHits = 0;
        gPrefixStopSoundsContinuousHits = 0;
        gPrefixStopSoundsFromSourceEntrySP = 0;
        gPrefixStopSoundsContinuousEntrySP = 0;
    } else if (pc == A_LOAD_MARIO_AREA) {
        stage = "load_mario_area";
        if (gPrefixStage == 1) gPrefixStage = 2;
    } else if (pc == A_SPAWN_OBJECTS_FROM_INFO) {
        stage = "spawn_objects_from_info";
        if (gPrefixStage >= 2) gPrefixStage = 3;
    } else if (pc == A_INIT_MARIO) {
        stage = "init_mario";
        if (gPrefixStage >= 3) gPrefixStage = 4;
    }

    fprintf(stderr,
            "PREFIX_STAGE,stage=%s,sequence=%d,pc=%08x,returnPC=%08x,"
            "a0=%08x,a1=%08x,timer=%u,area=%u,marioObject=%08x,"
            "stateMarioObject=%08x\n",
            stage, gPrefixStage, pc, return_pc, argument0, argument1,
            R32(A_GLOBAL_TIMER), R16(A_CURR_AREA), mario_object,
            R32(A_MARIO_STATES + M_MARIO_OBJ));
    resume_from_breakpoint();
}

static uint32_t bhv_mario_word_hash(void);
static uint32_t behavior_cmd_table_word_hash(void);

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

static uint32_t word_hash(uint32_t address, unsigned word_count) {
    uint32_t hash = 2166136261u;
    unsigned index;

    for (index = 0; index < word_count; index++) {
        uint32_t word = R32(address + index * 4);
        hash ^= word;
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

static void start_post_entry_trace(int top_timer) {
    int armed;

    gPostMarioLevelInfo = R32(A_BHV_MARIO + 8 * 4);
    gPostMarioUpdate = R32(A_BHV_MARIO + 10 * 4);
    gPostMarioDebugSpawn = R32(A_BHV_MARIO + 12 * 4);
    gPostBhvMarioHash = bhv_mario_word_hash();
    gPostBehaviorCmdTableHash = behavior_cmd_table_word_hash();
    armed = add_write_breakpoint(A_BHV_MARIO, BHV_MARIO_WORDS * 4)
        && add_write_breakpoint(A_BEHAVIOR_CMD_TABLE,
                                BEHAVIOR_CMD_TABLE_WORDS * 4)
        && add_exec_breakpoint(gPostMarioLevelInfo)
        && add_exec_breakpoint(gPostMarioUpdate)
        && add_exec_breakpoint(gPostMarioDebugSpawn);
    if (!armed) {
        fprintf(stderr, "POST_ENTRY_TRACE_ERROR,kind=breakpoint-arm\n");
        return;
    }
    gPostTraceActive = 1;
    gPostStartGlobalTimer = R32(A_GLOBAL_TIMER);
    gPostStartTopTimer = top_timer;
    gPostLastTopTimer = top_timer - 1;
    fprintf(stderr,
            "POST_ENTRY_TRACE_START,globalTimer=%u,topAction=%d,topTimer=%d,"
            "marioObject=%08x,slot=67,behavior=%08x,oFlags=%08x,"
            "oGraphYOffsetBits=%08x,bhvMarioHash=%08x,"
            "behaviorCmdTable=%08x,behaviorCmdTableHash=%08x,"
            "levelInfoCallback=%08x,marioUpdateCallback=%08x,"
            "debugSpawnCallback=%08x,watchRanges=12,invariant=%d\n",
            gPostStartGlobalTimer, (int32_t) R32(gTop + O_ACTION), top_timer,
            R32(A_MARIO_OBJECT), R32(A_SLOT67_BEHAVIOR),
            R32(A_SLOT67_FLAGS), R32(A_SLOT67_GRAPH_Y_OFFSET),
            gPostBhvMarioHash, A_BEHAVIOR_CMD_TABLE,
            gPostBehaviorCmdTableHash, gPostMarioLevelInfo,
            gPostMarioUpdate, gPostMarioDebugSpawn, post_identity_holds());
}

static void observe_post_entry_trace(int top_timer) {
    if (!gPostTraceActive) {
        if (gEntryIdentityLogged && top_timer == 1) {
            start_post_entry_trace(top_timer);
        } else {
            return;
        }
    }
    if (gPostTraceComplete) return;
    gPostTraceSamples++;
    if (top_timer != gPostLastTopTimer + 1) gPostTraceSequential = 0;
    gPostLastTopTimer = top_timer;
    if (!post_identity_holds()) gPostTraceInvariantFailures++;
    if (top_timer == 132) {
        fprintf(stderr,
                "POST_ENTRY_TRACE_END,startGlobalTimer=%u,endGlobalTimer=%u,"
                "startTopTimer=%d,endTopTimer=%d,samples=%u,sequential=%d,"
                "watchedWrites=%u,invariantFailures=%u,"
                "safeWatchedWrites=%u,unsafeWatchedWrites=%u,"
                "watchWriteHash=%08x,"
                "marioObject=%08x,stateMarioObject=%08x,activeFlags=%04x,"
                "behavior=%08x,oFlags=%08x,oGraphYOffsetBits=%08x,"
                "next=%08x,prev=%08x,sentinelNext=%08x,sentinelPrev=%08x,"
                "bhvMarioHash=%08x,behaviorCmdTableHash=%08x,"
                "levelInfoCalls=%u,marioUpdateCalls=%u,"
                "debugSpawnCalls=%u,allocateObjectCalls=%u,"
                "allocatorFallbackCalls=%u,unloadObjectCalls=%u,"
                "stopSoundsFromSourceCalls=%u,"
                "stopSoundsContinuousCalls=%u,sqrtfFrame=all-path-store-free,"
                "invariant=%d\n",
                gPostStartGlobalTimer, R32(A_GLOBAL_TIMER),
                gPostStartTopTimer, top_timer, gPostTraceSamples,
                gPostTraceSequential, gPostTraceWatchedWrites,
                gPostTraceInvariantFailures, gPostSafeWatchedWrites,
                gPostUnsafeWatchedWrites, gPostWatchWriteHash,
                R32(A_MARIO_OBJECT),
                R32(A_STATE_MARIO_OBJECT), R16(A_SLOT67_ACTIVE_FLAGS),
                R32(A_SLOT67_BEHAVIOR), R32(A_SLOT67_FLAGS),
                R32(A_SLOT67_GRAPH_Y_OFFSET), R32(A_SLOT67_NEXT),
                R32(A_SLOT67_PREV), R32(A_LIST0_SENTINEL_NEXT),
                R32(A_LIST0_SENTINEL_PREV), bhv_mario_word_hash(),
                behavior_cmd_table_word_hash(),
                gPostMarioLevelInfoCalls, gPostMarioUpdateCalls,
                gPostMarioDebugSpawnCalls, gPostAllocateObjectCalls,
                gPostAllocatorFallbackCalls, gPostUnloadObjectCalls,
                gPostStopSoundsFromSourceCalls,
                gPostStopSoundsContinuousCalls, post_identity_holds());
        gPostTraceComplete = 1;
    }
}

static void arm_prefix_trace(void) {
    m64p_error callback_result;
    int armed;

    callback_result = DSetCallbacks(debugger_init_callback,
                                    debugger_update_callback,
                                    debugger_vi_callback);
    if (callback_result != M64ERR_SUCCESS) {
        fprintf(stderr,
                "PREFIX_BREAKPOINT_ERROR,kind=callback-arm,result=%d\n",
                callback_result);
        return;
    }
    armed = add_exec_breakpoint(A_CLEAR_OBJECTS)
        && add_exec_breakpoint(A_LOAD_MARIO_AREA)
        && add_exec_breakpoint(A_SPAWN_OBJECTS_FROM_INFO)
        && add_exec_breakpoint(A_INIT_MARIO)
        && add_exec_breakpoint(A_ALLOCATE_OBJECT)
        && add_exec_breakpoint(A_ALLOCATE_OBJECT_UNLOAD_CALL)
        && add_exec_breakpoint(A_UNLOAD_OBJECT)
        && add_exec_breakpoint(A_STOP_SOUNDS_FROM_SOURCE)
        && add_exec_breakpoint(A_STOP_SOUNDS_IN_CONTINUOUS_BANKS)
        && add_write_breakpoint(A_MARIO_OBJECT, 4)
        && add_write_breakpoint(A_STATE_MARIO_OBJECT, 4)
        && add_write_breakpoint(A_SLOT67_NEXT, 4)
        && add_write_breakpoint(A_SLOT67_PREV, 4)
        && add_write_breakpoint(A_SLOT67_ACTIVE_FLAGS, 2)
        && add_write_breakpoint(A_SLOT67_FLAGS, 4)
        && add_write_breakpoint(A_SLOT67_GRAPH_Y_OFFSET, 4)
        && add_write_breakpoint(A_SLOT67_BEHAVIOR, 4)
        && add_write_breakpoint(A_LIST0_SENTINEL_NEXT, 4)
        && add_write_breakpoint(A_LIST0_SENTINEL_PREV, 4);
    if (!armed) {
        fprintf(stderr, "PREFIX_BREAKPOINT_ERROR,kind=breakpoint-arm\n");
        return;
    }
    gPrefixTraceArmed = 1;
    fprintf(stderr,
            "PREFIX_BREAKPOINT_ARM,clear=%08x,load=%08x,spawn=%08x,"
            "init=%08x,allocate=%08x,allocatorFallback=%08x,"
            "unload=%08x,stopSource=%08x,stopContinuous=%08x,"
            "writeWatchCount=10\n",
            A_CLEAR_OBJECTS, A_LOAD_MARIO_AREA,
            A_SPAWN_OBJECTS_FROM_INFO, A_INIT_MARIO, A_ALLOCATE_OBJECT,
            A_ALLOCATE_OBJECT_UNLOAD_CALL, A_UNLOAD_OBJECT,
            A_STOP_SOUNDS_FROM_SOURCE,
            A_STOP_SOUNDS_IN_CONTINUOUS_BANKS);
}

static void observe_entry_identity(uint32_t mario_object) {
    uint32_t next;
    uint32_t prev;
    int slot;
    int state_matches;
    int tail_safe;
    int list_ring;

    if (gEntryIdentityLogged) return;
    next = R32(mario_object + HEADER_NEXT);
    prev = R32(mario_object + HEADER_PREV);
    slot = pool_index(mario_object);
    state_matches = R32(A_MARIO_STATES + M_MARIO_OBJ) == mario_object;
    tail_safe = (R32(mario_object + O_FLAGS) & 1) == 0
        && R32(mario_object + O_GRAPH_Y_OFFSET) == 0;
    list_ring = next == prev && next != 0
        && R32(next + HEADER_NEXT) == mario_object
        && R32(next + HEADER_PREV) == mario_object;
    fprintf(stderr,
            "PREFIX_CALL_REACH,epoch=%u,timer=%u,allocateObject=%u,"
            "allocatorFallback=%u,unloadObject=%u,"
            "stopSoundsFromSource=%u,sourceEntrySP=%08x,"
            "stopSoundsContinuous=%u,continuousEntrySP=%08x\n",
            gPrefixEpoch, R32(A_GLOBAL_TIMER),
            gPrefixAllocateObjectHits, gPrefixAllocatorFallbackHits,
            gPrefixUnloadObjectHits, gPrefixStopSoundsFromSourceHits,
            gPrefixStopSoundsFromSourceEntrySP,
            gPrefixStopSoundsContinuousHits,
            gPrefixStopSoundsContinuousEntrySP);
    fprintf(stderr,
            "ENTRY_IDENTITY,timer=%u,marioObject=%08x,slot=%d,"
            "stateMarioObject=%08x,activeFlags=%04x,behavior=%08x,"
            "oFlags=%08x,oGraphYOffsetBits=%08x,next=%08x,prev=%08x,"
            "sentinelNext=%08x,sentinelPrev=%08x,stateMatches=%d,"
            "tailSafe=%d,listRing=%d,prefixStage=%d\n",
            R32(A_GLOBAL_TIMER), mario_object, slot,
            R32(A_MARIO_STATES + M_MARIO_OBJ),
            R16(mario_object + O_ACTIVE_FLAGS),
            R32(mario_object + O_BEHAVIOR),
            R32(mario_object + O_FLAGS),
            R32(mario_object + O_GRAPH_Y_OFFSET), next, prev,
            next == 0 ? 0 : R32(next + HEADER_NEXT),
            next == 0 ? 0 : R32(next + HEADER_PREV),
            state_matches, tail_safe, list_ring, gPrefixStage);
    gEntryIdentityLogged = 1;
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
        if (closef(rfloat(object + O_POS_X), -5200.0f, 300.0f)
            && closef(rfloat(object + O_POS_Z), 1700.0f, 300.0f)
            && R32(object + O_INTERACT_TYPE) != 0) {
            gWestJumpingBox = object;
        }
        if (R32(object + O_INTERACT_TYPE) == INTERACT_TORNADO) {
            if (closef(rfloat(object + O_HOME_X), 1017.0f, 1.0f)
                && closef(rfloat(object + O_HOME_Z), 3832.0f, 1.0f)) {
                gEastNorthTweester = object;
            }
            if (closef(rfloat(object + O_HOME_X), 3066.0f, 1.0f)
                && closef(rfloat(object + O_HOME_Z), 400.0f, 1.0f)) {
                gSoutheastTweester = object;
            }
            if (closef(rfloat(object + O_HOME_X), -3600.0f, 1.0f)
                && closef(rfloat(object + O_HOME_Z), 2940.0f, 1.0f)) {
                gWestTweester = object;
            }
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
    DSetCallbacks = (ptr_DebugSetCallbacks) dlsym(core, "DebugSetCallbacks");
    DSetRunState = (ptr_DebugSetRunState) dlsym(core, "DebugSetRunState");
    DStep = (ptr_DebugStep) dlsym(core, "DebugStep");
    DGetCPUDataPtr =
        (ptr_DebugGetCPUDataPtr) dlsym(core, "DebugGetCPUDataPtr");
    DBreakpointCommand =
        (ptr_DebugBreakpointCommand) dlsym(core,
                                           "DebugBreakpointCommand");
    DDecodeOp = (ptr_DebugDecodeOp) dlsym(core, "DebugDecodeOp");
    DBreakpointTriggeredBy = (ptr_DebugBreakpointTriggeredBy)
        dlsym(core, "DebugBreakpointTriggeredBy");
    DVirtualToPhysical = (ptr_DebugVirtualToPhysical)
        dlsym(core, "DebugVirtualToPhysical");
    return R32 && R16 && DSetCallbacks && DSetRunState && DStep
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
            "mode9Stage=%d,mode9WestRimStage=%d,"
            "mode9DetectorDiveInputs=%d,"
            "mode9RolloutInputs=%d,mode9SurvivalBInputs=%d,"
            "mode9WestBoxContact=%d,mode9WestDetectorReached=%d,"
            "mode9NorthwestDetectorReached=%d,"
            "mode9SourceTweesterCaptured=%d,"
            "mode9EastNorthTweesterCaptured=%d,"
            "mode9WestTweesterCaptured=%d,"
            "mode10NorthAvoidanceReached=%d,"
            "mode9WestmostX=%.9g,"
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
            gMode9Stage, gMode9WestRimStage,
            gMode9DetectorDiveInputs,
            gMode9RolloutInputs, gMode9SurvivalBInputs,
            gMode9WestBoxContact, gMode9WestDetectorReached,
            gMode9NorthwestDetectorReached,
            gMode9SourceTweesterCaptured,
            gMode9EastNorthTweesterCaptured,
            gMode9WestTweesterCaptured,
            gMode10NorthAvoidanceReached,
            gMode9WestmostX,
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
    if (!gPrefixTraceArmed) arm_prefix_trace();
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
    observe_entry_identity(mario_object);
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
    observe_post_entry_trace(top_timer);

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

    /* A controller-only witness for the two eastern pillar detectors.  The
       first Tweester lift reaches the northeast detector.  Staying west of
       the southeast Tweester's home point then draws it south before the
       second collision, shortening the next lift enough to reach the
       southeast detector.  After that checkpoint the recorded bounded
       schedule heads back toward the Tweester and terminates in quicksand. */
    if (SEARCH_MODE == 7 && gUsedTornado) {
        float target_x;
        float target_z;

        if (pillars == 0) {
            target_x = 1789.0f;
            target_z = 764.0f;
        } else if (pillars == 1 && gTornadoCaptures == 1) {
            /* Stay west of the home point and draw the chasing Tweester
               south before collision, shortening the following lift. */
            target_x = 1789.0f;
            target_z = -800.0f;
        } else if (pillars == 1) {
            target_x = 1789.0f;
            target_z = -2579.0f;
        } else {
            target_x = 3066.0f;
            target_z = 400.0f;
        }

        steer_world(keys, target_x, target_z, 127.0f);
        goto log_frame;
    }

    /* Experimental continuations from the same two-pillar checkpoint through
       a stock east-to-west Tweester relay.  Mode 9 directly reuses mode 6's
       west-Tweester target after the northeast release.  Mode 10 changes only
       that leg: it first stays north of the central pyramid until x < -2000,
       avoiding the wall reflection measured in mode 9. */
    if ((SEARCH_MODE == 9 || SEARCH_MODE == 10) && gUsedTornado) {
        uint32_t action = R32(A_MARIO_STATES + M_ACTION);
        uint32_t timer = R32(A_GLOBAL_TIMER);
        uint32_t held_object = R32(A_MARIO_STATES + M_HELD_OBJ);
        uint32_t used_object = R32(A_MARIO_STATES + M_USED_OBJ);
        float mario_x = rfloat(A_MARIO_STATES + M_POS_X);
        float mario_z = rfloat(A_MARIO_STATES + M_POS_Z);
        float target_x;
        float target_z;
        float distance;

        if (pillars == 2 && mario_x < gMode9WestmostX) {
            gMode9WestmostX = mario_x;
        }
        if (pillars >= 2 && action == ACT_TORNADO_TWIRLING
            && used_object == gSoutheastTweester
            && !gMode9SourceTweesterCaptured) {
            gMode9SourceTweesterCaptured = 1;
            gMode9Stage = 3;
            fprintf(stderr,
                    "MODE9_STAGE,timer=%u,stage=3,label=source-tweester,"
                    "state=(%.9g,%.9g,%.9g),usedObj=%08x\n",
                    timer, mario_x, rfloat(A_MARIO_STATES + M_POS_Y),
                    mario_z, used_object);
        }
        if (pillars >= 2 && action == ACT_TORNADO_TWIRLING
            && used_object == gWestTweester
            && !gMode9WestTweesterCaptured) {
            gMode9WestTweesterCaptured = 1;
            gMode9Stage = 5;
            fprintf(stderr,
                    "MODE9_STAGE,timer=%u,stage=5,label=west-tweester,"
                    "state=(%.9g,%.9g,%.9g),usedObj=%08x\n",
                    timer, mario_x, rfloat(A_MARIO_STATES + M_POS_Y),
                    mario_z, used_object);
        }
        if (pillars >= 2 && action == ACT_TORNADO_TWIRLING
            && used_object == gEastNorthTweester
            && !gMode9EastNorthTweesterCaptured) {
            gMode9EastNorthTweesterCaptured = 1;
            gMode9Stage = 4;
            fprintf(stderr,
                    "MODE9_STAGE,timer=%u,stage=4,"
                    "label=east-north-tweester,"
                    "state=(%.9g,%.9g,%.9g),usedObj=%08x\n",
                    timer, mario_x, rfloat(A_MARIO_STATES + M_POS_Y),
                    mario_z, used_object);
        }
        if (gWestJumpingBox != 0
            && (held_object == gWestJumpingBox
                || (action == ACT_CRAZY_BOX_BOUNCE
                    && used_object == gWestJumpingBox))
            && !gMode9WestBoxContact) {
            gMode9WestBoxContact = 1;
            gMode9Stage = 7;
            fprintf(stderr,
                    "MODE9_STAGE,timer=%u,stage=7,label=west-box,"
                    "state=(%.9g,%.9g,%.9g),usedObj=%08x\n",
                    timer, mario_x, rfloat(A_MARIO_STATES + M_POS_Y),
                    mario_z, used_object);
        }
        if (pillars >= 3 && !gMode9WestDetectorReached) {
            gMode9WestDetectorReached = 1;
            gMode9Stage = 6;
            fprintf(stderr,
                    "MODE9_STAGE,timer=%u,stage=6,"
                    "label=southwest-detector,state=(%.9g,%.9g,%.9g)\n",
                    timer, mario_x,
                    rfloat(A_MARIO_STATES + M_POS_Y), mario_z);
        }
        if (pillars >= 4) {
            if (!gMode9NorthwestDetectorReached) {
                gMode9NorthwestDetectorReached = 1;
                gMode9Stage = 8;
                fprintf(stderr,
                        "MODE9_STAGE,timer=%u,stage=8,"
                        "label=northwest-detector,"
                        "state=(%.9g,%.9g,%.9g),topAction=%d,topTimer=%d\n",
                        timer, mario_x,
                        rfloat(A_MARIO_STATES + M_POS_Y), mario_z,
                        top_action, top_timer);
            }
            /* Pillar four is the decisive endpoint for this bounded mode:
               leave the controller neutral and retain TOP lifecycle samples. */
            goto log_frame;
        }
        if (pillars >= 3 && top_action != 0) {
            /* A defensive endpoint: stock activation should require all four
               detectors.  Preserve any contrary observation without input. */
            fprintf(stderr,
                    "MODE9_STAGE,timer=%u,stage=7,"
                    "label=early-top-action,pillars=%d,topAction=%d\n",
                    timer, pillars, top_action);
            goto log_frame;
        }
        if (pillars == 0) {
            target_x = 1789.0f;
            target_z = 764.0f;
        } else if (pillars == 1 && gTornadoCaptures == 1) {
            target_x = 1789.0f;
            target_z = -800.0f;
        } else if (pillars == 1) {
            target_x = 1789.0f;
            target_z = -2579.0f;
        } else if (pillars == 2 && gMode9Stage == 0 && timer < 1250) {
            /* The second Tweester reaches home and completes its 60-frame
               hide before this bound.  Waiting on the detector is dry and
               prevents the reset delay from being paid in quicksand. */
            goto log_frame;
        } else if (pillars == 2 && !gMode9SourceTweesterCaptured) {
            /* This ordinary-quicksand point lies inside the southeast
               Tweester's 1500-unit idle activation radius. */
            target_x = 1950.0f;
            target_z = -450.0f;
        } else if (pillars == 2 && !gMode9EastNorthTweesterCaptured) {
            target_x = 1017.0f;
            target_z = 3832.0f;
        } else if (pillars == 2 && !gMode9WestTweesterCaptured
                   && SEARCH_MODE == 10 && mario_x >= -2000.0f) {
            target_x = -2200.0f;
            target_z = 3500.0f;
        } else if (pillars == 2 && !gMode9WestTweesterCaptured) {
            if (SEARCH_MODE == 10 && !gMode10NorthAvoidanceReached) {
                gMode10NorthAvoidanceReached = 1;
                fprintf(stderr,
                        "MODE9_STAGE,timer=%u,stage=4,"
                        "label=mode10-north-avoidance,"
                        "state=(%.9g,%.9g,%.9g)\n",
                        timer, mario_x,
                        rfloat(A_MARIO_STATES + M_POS_Y), mario_z);
            }
            /* Exact mode-6 relay target.  A repeat capture of the source
               Tweester does not change this target. */
            target_x = -3600.0f;
            target_z = 2940.0f;
        } else if (pillars == 2 && gMode9WestTweesterCaptured) {
            target_x = -5883.0f;
            target_z = -2579.0f;
        } else if (pillars == 2 && gWestJumpingBox != 0
                   && R16(gWestJumpingBox + O_ACTIVE_FLAGS) != 0) {
            target_x = rfloat(gWestJumpingBox + O_POS_X);
            target_z = rfloat(gWestJumpingBox + O_POS_Z);
        } else if (pillars == 2) {
            target_x = -5200.0f;
            target_z = 1700.0f;
        } else if (pillars == 3 && gMode9WestBoxContact) {
            target_x = -5883.0f;
            target_z = 764.0f;
        } else if (pillars == 3 && gMode9WestRimStage == 0) {
            target_x = -5900.0f;
            target_z = 300.0f;
            if (mario_z > 200.0f) {
                gMode9WestRimStage = 1;
                fprintf(stderr,
                        "MODE9_STAGE,timer=%u,stage=6,westRimStage=1,"
                        "state=(%.9g,%.9g,%.9g)\n",
                        timer, mario_x,
                        rfloat(A_MARIO_STATES + M_POS_Y), mario_z);
            }
        } else if (pillars == 3 && gMode9WestRimStage == 1) {
            target_x = -5600.0f;
            target_z = 1200.0f;
            if (mario_z > 1100.0f) {
                gMode9WestRimStage = 2;
                fprintf(stderr,
                        "MODE9_STAGE,timer=%u,stage=6,westRimStage=2,"
                        "state=(%.9g,%.9g,%.9g)\n",
                        timer, mario_x,
                        rfloat(A_MARIO_STATES + M_POS_Y), mario_z);
            }
        } else if (pillars == 3 && gMode9WestRimStage == 2) {
            /* Approach from northeast of the box.  The resulting southwest
               heading is retained by CRAZY_BOX_BOUNCE and points at the
               northwest detector. */
            target_x = -4500.0f;
            target_z = 2500.0f;
            if (hypotf(target_x - mario_x, target_z - mario_z) < 160.0f) {
                gMode9WestRimStage = 3;
                fprintf(stderr,
                        "MODE9_STAGE,timer=%u,stage=6,westRimStage=3,"
                        "state=(%.9g,%.9g,%.9g)\n",
                        timer, mario_x,
                        rfloat(A_MARIO_STATES + M_POS_Y), mario_z);
            }
        } else if (pillars == 3 && gWestJumpingBox != 0
                   && R16(gWestJumpingBox + O_ACTIVE_FLAGS) != 0) {
            target_x = rfloat(gWestJumpingBox + O_POS_X);
            target_z = rfloat(gWestJumpingBox + O_POS_Z);
        } else if (pillars == 3) {
            target_x = -5200.0f;
            target_z = 1700.0f;
        } else {
            target_x = -2048.0f;
            target_z = -1024.0f;
        }

        distance = hypotf(target_x - mario_x, target_z - mario_z);
        steer_world(keys, target_x, target_z, 127.0f);

        if (pillars == 2 && !gMode9SourceTweesterCaptured
            && gMode9Stage == 0 && timer >= 1250
            && action == ACT_WALKING
            && rfloat(A_MARIO_STATES + M_FORWARD_VEL) >= 29.0f
            && timer - gLastMovementB >= 20) {
            keys->B_BUTTON = 1;
            gMode9Stage = 1;
            gMode9DetectorDiveInputs++;
            gBPressedFrames++;
            gLastMovementB = timer;
            fprintf(stderr,
                    "B_INPUT,timer=%u,label=mode9-detector-dive,"
                    "distance=%.9g,state=(%.9g,%.9g,%.9g),action=%08x\n",
                    timer, distance, mario_x,
                    rfloat(A_MARIO_STATES + M_POS_Y), mario_z, action);
        } else if (pillars == 2 && !gMode9SourceTweesterCaptured
                   && gMode9Stage == 1
                   && (action == ACT_DIVE_SLIDE
                       || (action == ACT_STOMACH_SLIDE
                           && R16(A_MARIO_STATES + M_ACTION_TIMER) >= 5))
                   && timer - gLastMovementB >= 20) {
            keys->B_BUTTON = 1;
            gMode9Stage = 2;
            gMode9RolloutInputs++;
            gBPressedFrames++;
            gLastMovementB = timer;
            fprintf(stderr,
                    "B_INPUT,timer=%u,label=mode9-activation-rollout,"
                    "distance=%.9g,state=(%.9g,%.9g,%.9g),action=%08x\n",
                    timer, distance, mario_x,
                    rfloat(A_MARIO_STATES + M_POS_Y), mario_z, action);
        } else if (pillars == 2 && !gMode9SourceTweesterCaptured
                   && gMode9Stage >= 2 && timer - gLastMovementB >= 20
                   && ((action == ACT_WALKING
                        && rfloat(A_MARIO_STATES + M_FORWARD_VEL) >= 29.0f)
                       || action == ACT_DIVE_SLIDE
                       || action == ACT_STOMACH_SLIDE)) {
            keys->B_BUTTON = 1;
            gMode9SurvivalBInputs++;
            gBPressedFrames++;
            gLastMovementB = timer;
            fprintf(stderr,
                    "B_INPUT,timer=%u,label=mode9-activation-survival,"
                    "distance=%.9g,state=(%.9g,%.9g,%.9g),action=%08x\n",
                    timer, distance, mario_x,
                    rfloat(A_MARIO_STATES + M_POS_Y), mario_z, action);
        } else if (pillars == 3
                   && !gMode9WestBoxContact && gWestJumpingBox != 0
                   && R16(gWestJumpingBox + O_ACTIVE_FLAGS) != 0
                   && held_object == 0 && action != ACT_CRAZY_BOX_BOUNCE
                   && action != ACT_TORNADO_TWIRLING
                   && action != ACT_TWIRLING && distance < 135.0f
                   && timer - gLastMovementB >= 20) {
            keys->B_BUTTON = 1;
            gBPressedFrames++;
            gLastMovementB = timer;
            fprintf(stderr,
                    "B_INPUT,timer=%u,label=mode9-west-jumping-box,"
                    "distance=%.9g,state=(%.9g,%.9g,%.9g),action=%08x,"
                    "box=%08x\n",
                    timer, distance, mario_x,
                    rfloat(A_MARIO_STATES + M_POS_Y), mario_z, action,
                    gWestJumpingBox);
        } else if (pillars == 3 && !gMode9WestBoxContact
                   && timer - gLastMovementB >= 20
                   && ((action == ACT_WALKING
                        && rfloat(A_MARIO_STATES + M_FORWARD_VEL) >= 29.0f)
                       || action == ACT_DIVE_SLIDE
                       || action == ACT_STOMACH_SLIDE)) {
            keys->B_BUTTON = 1;
            gMode9SurvivalBInputs++;
            gBPressedFrames++;
            gLastMovementB = timer;
            fprintf(stderr,
                    "B_INPUT,timer=%u,label=mode9-west-rim-movement,"
                    "distance=%.9g,state=(%.9g,%.9g,%.9g),action=%08x\n",
                    timer, distance, mario_x,
                    rfloat(A_MARIO_STATES + M_POS_Y), mario_z, action);
        }
        goto log_frame;
    }

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
            if ((SEARCH_MODE >= 3 && SEARCH_MODE <= 7)
                || SEARCH_MODE == 9 || SEARCH_MODE == 10) {
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
        } else if ((SEARCH_MODE >= 3 && SEARCH_MODE <= 7)
                   || SEARCH_MODE == 9 || SEARCH_MODE == 10) {
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
       eastern detectors and then crosses to the western pair. */
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
