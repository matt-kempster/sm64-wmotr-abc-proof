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

#ifndef RANK1_BOUNDARY_AUDIT
#define RANK1_BOUNDARY_AUDIT 0
#endif

#ifndef RANK1_BOUNDARY_REPEAT_UNTIL
#define RANK1_BOUNDARY_REPEAT_UNTIL 349
#endif

#ifndef RANK4_WARP_TOP_AUDIT
#define RANK4_WARP_TOP_AUDIT 0
#endif

#ifndef RANK5_STATE_SPLIT_AUDIT
#define RANK5_STATE_SPLIT_AUDIT 0
#endif

#ifndef RANK13_18_COPY_AUDIT
#define RANK13_18_COPY_AUDIT 0
#endif

#if RANK13_18_COPY_AUDIT && !RANK5_STATE_SPLIT_AUDIT
#error "RANK13_18_COPY_AUDIT requires RANK5_STATE_SPLIT_AUDIT"
#endif

#if RANK4_WARP_TOP_AUDIT && !RANK1_BOUNDARY_AUDIT
#error "RANK4_WARP_TOP_AUDIT requires RANK1_BOUNDARY_AUDIT"
#endif

#if RANK5_STATE_SPLIT_AUDIT && !RANK1_BOUNDARY_AUDIT
#error "RANK5_STATE_SPLIT_AUDIT requires RANK1_BOUNDARY_AUDIT"
#endif

/* Authenticated original-JP virtual addresses.  run.sh hash-gates the ROM. */
enum {
    A_GLOBAL_TIMER = 0x8032c694,
    A_MARIO_PLATFORM = 0x8032fed4,
    A_MARIO_STATES = 0x80339e00,
    A_MAIN_POOL_FREE_SPACE = 0x8033a110,
    A_MAIN_POOL_START = 0x8033a114,
    A_MAIN_POOL_END = 0x8033a118,
    A_MAIN_POOL_LEFT_HEAD = 0x8033a11c,
    A_MAIN_POOL_RIGHT_HEAD = 0x8033a120,
    A_CURR_AREA = 0x8033a75a,
    A_TIME_STOP_STATE = 0x8033c110,
    A_OBJECT_POOL = 0x8033c118,
    A_MARIO_OBJECT = 0x8035fde8,
    A_CURRENT_OBJECT = 0x8035fdf0,
    A_SURFACE_NODES_ALLOCATED = 0x8035fdfc,
    A_SURFACES_ALLOCATED = 0x8035fe00,
    A_NUM_STATIC_SURFACE_NODES = 0x8035fe04,
    A_NUM_STATIC_SURFACES = 0x8035fe08,
    A_STATIC_SURFACE_PARTITION = 0x8038be98,
    A_DYNAMIC_SURFACE_PARTITION = 0x8038d698,
    A_SURFACE_NODE_POOL_CELL = 0x8038ee98,
    A_SURFACE_POOL_CELL = 0x8038ee9c,
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
    A_SLOT67_PLATFORM = 0x8034624c,
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

#if RANK1_BOUNDARY_AUDIT
enum {
    A_MAIN_POOL_INIT = 0x80277ac4,
    A_MAIN_POOL_ALLOC = 0x80277b70,
    A_MAIN_POOL_FREE = 0x80277c88,
    A_MAIN_POOL_REALLOC = 0x80277da8,
    A_MAIN_POOL_PUSH_STATE = 0x80277e38,
    A_MAIN_POOL_POP_STATE = 0x80277ee8,
    A_UPDATE_OBJECTS = 0x8029cf08,
    A_POST_APPLY_MARIO_PLATFORM = 0x8029cfc8,
    A_DETECT_OBJECT_COLLISIONS = 0x802c8c44,
    A_POST_DETECT_OBJECT_COLLISIONS = 0x8029cfec,
    A_POST_NON_TERRAIN_OBJECTS = 0x8029d010,
    A_POST_UNLOAD_DEACTIVATED_OBJECTS = 0x8029d034,
    A_POST_MARIO_PLATFORM = 0x8029d058,
    A_APPLY_MARIO_PLATFORM_DISPLACEMENT = 0x802c83f0,
    A_APPLY_PLATFORM_DISPLACEMENT_CALLSITE = 0x802c8438,
    A_POST_COPY_MARIO_STATE_TO_OBJECT = 0x8029c30c,
    A_BHV_MARIO_RETURN = 0x8029c3a4,
    A_PLATFORM_GLOBAL_CLEAR_AWAY = 0x802c7fec,
    A_PLATFORM_OBJECT_CLEAR_AWAY = 0x802c7ff8,
    A_PLATFORM_GLOBAL_OWNER_STORE = 0x802c8028,
    A_PLATFORM_OBJECT_OWNER_STORE = 0x802c8040,
    A_PLATFORM_GLOBAL_CLEAR_OWNERLESS = 0x802c8048,
    A_PLATFORM_OBJECT_CLEAR_OWNERLESS = 0x802c8054,
    A_UPDATE_MARIO_PLATFORM = 0x802c7f20,
    A_POST_PLATFORM_FIND_FLOOR = 0x802c7f88,
    A_CLEAR_DYNAMIC_SURFACES = 0x803835a4,
    A_LOAD_OBJECT_COLLISION_MODEL = 0x803839cc,
    A_ADD_SURFACE = 0x80382a2c,
    A_LOAD_OBJECT_SURFACES = 0x80383828,
    A_SURFACE_LOAD_TEXT_START = 0x80382490,
    A_SURFACE_LOAD_TEXT_END = 0x80383b70,
    A_FIND_FLOOR = 0x80381900,
    /* Common epilogue of the hash-authenticated JP find_floor body.  At this
     * instruction the original stack frame still holds x/y/z and pfloor at
     * +0x40/+0x44/+0x48/+0x4c, respectively. */
    A_FIND_FLOOR_RETURN = 0x80381b90,
    A_FIND_FLOOR_TEXT_END = 0x80381ba0,
    A_SQRTF = 0x80322b20,
    A_SET_CAMERA_SHAKE_FROM_POINT = 0x8027f440,
    A_CREATE_SOUND_SPAWNER = 0x802c9664,
    A_CREATE_SOUND_SPAWNER_STORE = 0x802c9694,
    A_CUR_OBJ_PLAY_SOUND_2 = 0x802c9700,
    A_PLAY_SOUND = 0x8031dc78,
    A_PLAY_SOUND_STORE_0 = 0x8031dc98,
    A_PLAY_SOUND_STORE_1 = 0x8031dc9c,
    A_PLAY_SOUND_COUNT_STORE = 0x8031dca4,
    A_PLAY_PUZZLE_JINGLE = 0x80321228,
    A_PLAY_PUZZLE_JINGLE_STORE = 0x80321248,
    A_SOUND_REQUEST_BASE = 0x80360128,
    A_SOUND_REQUEST_END = 0x80360928,
    A_SOUND_REQUEST_COUNT = 0x80331e34,
    A_PUZZLE_MUSIC_STATE = 0x8033211c,
    A_OBJECT_LIST_ARRAY = 0x8033b870,
    OBJECT_NODE_SIZE = 0x68,
    OBJECT_LIST_COUNT = 13,
    SURFACE_NODE_BYTES = 56000,
    SURFACE_BYTES = 110400,
    SURFACE_NODE_SIZE = 8,
    SURFACE_SIZE = 48,
    SURFACE_CAPACITY = 2300,
    SURFACE_NODE_CAPACITY = 7000,
    SURFACE_PARTITION_BYTES = 0x1800,
    SURFACE_OBJECT = 0x2c,
};
#endif

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
    O_COLLISION_DATA = 0x218,
};

enum {
    M_INPUT = 0x02,
    M_ACTION = 0x0c,
    M_ACTION_TIMER = 0x1a,
    M_INTENDED_YAW = 0x24,
    M_FACE_YAW = 0x2e,
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
    ACT_STOMACH_SLIDE_STOP = 0x00000386,
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
static uint32_t gToxBox1;
static uint32_t gToxBox2;
static uint32_t gToxBox3;
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
static int gMode11DetourStage;
static int gMode11TopApproach;
static int gMode12Stage;
static int gMode12RolloutInputs;
static int gMode12DiveInputs;
static int gMode12ToxInventoryLogged;
static int gMode12PillarsComplete;
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

#if RANK1_BOUNDARY_AUDIT
struct rank1_surface_receipt {
    uint32_t owner;
    uint32_t behavior;
    int16_t list_index;
    uint8_t owner_seen;
    uint8_t inserted;
    uint8_t owner_active_at_store;
    uint8_t unsafe_query_returns;
    uint16_t node_references;
    uint16_t query_returns;
};

struct rank1_writer_count {
    uint32_t pc;
    uint32_t count;
};

static struct rank1_surface_receipt gRank1SurfaceReceipts[SURFACE_CAPACITY];
static struct rank1_writer_count gRank1PoolWriterCounts[64];
static struct rank1_writer_count gRank1PartitionWriterCounts[32];
static uint8_t gRank1SeenNodes[SURFACE_NODE_CAPACITY];
static unsigned gRank1PoolWriterKinds;
static unsigned gRank1PartitionWriterKinds;
static int gRank1AuditState;
#if !RANK4_WARP_TOP_AUDIT && !RANK5_STATE_SPLIT_AUDIT
static int gRank1BreakpointsArmed;
#endif
static uint32_t gRank1StartTimer;
static uint32_t gRank1EndTimer;
static uint32_t gRank1NodeBase;
static uint32_t gRank1SurfaceBase;
static uint32_t gRank1SurfaceEnd;
static uint32_t gRank1StaticNodes;
static uint32_t gRank1StaticSurfaces;
static uint32_t gRank1StartFreeSpace;
static uint32_t gRank1StartLeftHead;
static uint32_t gRank1StartRightHead;
static uint32_t gRank1MinLeftHead;
static uint32_t gRank1MinRightHead;
static uint32_t gRank1PoolWrites;
static uint32_t gRank1SafePoolWrites;
static uint32_t gRank1UnsafePoolWrites;
static uint32_t gRank1NodeWrites;
static uint32_t gRank1SurfaceWrites;
static uint32_t gRank1DynamicPartitionWrites;
static uint32_t gRank1StaticPartitionWrites;
static uint32_t gRank1AllocatorGlobalWrites;
static uint32_t gRank1SurfacePointerWrites;
static uint32_t gRank1AllocatorCalls[6];
static uint32_t gRank1ClearDynamicCalls;
static uint32_t gRank1CollisionModelCalls;
static uint32_t gRank1LoadObjectSurfacesCalls;
static uint32_t gRank1OwnerStores;
static uint32_t gRank1AddSurfaceCalls;
static uint32_t gRank1InactiveCollisionModelCalls;
static uint32_t gRank1InactiveOwnerStores;
static uint32_t gRank1OwnerFailures;
static uint32_t gRank1ListFailures;
static uint32_t gRank1FindFloorCalls;
static uint32_t gRank1FindFloorReturns;
static uint32_t gRank1FindFloorBeforeClear;
static uint32_t gRank1FindFloorReturnFailures;
static uint32_t gRank1DynamicFindFloorReturns;
static uint32_t gRank1PlatformFindFloorCalls;
static uint32_t gRank1PostPlatformCalls;
static uint32_t gRank1OutsideCalls[8];
static uint32_t gRank1OutsideDestinationStores;
static uint32_t gRank1OutsideDestinationFailures;
static uint32_t gRank1EventHash = 2166136261u;
static uint32_t gRank1PlatformQueryXBits;
static uint32_t gRank1PlatformQueryYBits;
static uint32_t gRank1PlatformQueryZBits;
static uint32_t gRank1SelectedFloor;
static uint32_t gRank1SelectedPlatform;
static uint32_t gRank1SelectedOwner;
static int gRank1SelectedStaticMembership;
static int gRank1SelectedDynamicMembership;
static int gRank1ObjectListsIntact;
static int gRank1StaticListsIntact;
static int gRank1DynamicListsIntact;
static int gRank1StaticNodeCoverage;
static int gRank1DynamicNodeCoverage;
static int gRank1OwnerEndValidity;
static int gRank1OwnerEndSafety;
static uint32_t gRank1EndInvalidSurfaces;
static uint32_t gRank1PendingCleanupSurfaces;
static uint32_t gRank1SelectedWords[12];
static uint32_t gRank1FramesChecked;
static uint32_t gRank1FrameFailures;
static uint64_t gRank1OutsideCallSums[8];
static uint32_t gRank1OutsideCallMaxima[8];
static uint64_t gRank1OutsideDestinationStoreSum;
static uint32_t gRank1OutsideDestinationStoreMaximum;
static uint64_t gRank1FindFloorCallSum;
static uint64_t gRank1FindFloorReturnSum;
static uint64_t gRank1DynamicFindFloorReturnSum;
static uint64_t gRank1FindFloorReturnFailureSum;
static uint64_t gRank1FindFloorBeforeClearSum;
static uint64_t gRank1EndInvalidSurfaceSum;
static uint64_t gRank1PendingCleanupSurfaceSum;
static uint64_t gRank1InactiveOwnerStoreSum;
static uint64_t gRank1InactiveCollisionModelCallSum;
static uint32_t gRank1StaticSelectionFrames;
static uint32_t gRank1DynamicSelectionFrames;
static uint32_t gRank1OwnedSelectionFrames;
#endif

#if RANK4_WARP_TOP_AUDIT
static int gRank4BreakpointsArmed;
static int gRank4Initialized;
static int gRank4TopRetired;
static uint32_t gRank4CanonicalTop;
static uint32_t gRank4CanonicalUpperWarp;
static uint32_t gRank4TopBehavior;
static uint32_t gRank4WarpBehavior;
static uint32_t gRank4TopCollisionData;
static uint32_t gRank4FramesChecked;
static uint32_t gRank4FrameFailures;
static uint32_t gRank4TopActiveFrames;
static uint32_t gRank4TopAbsentFrames;
static uint32_t gRank4WarpActiveFrames;
static uint32_t gRank4TopBehaviorMaximum;
static uint32_t gRank4TopCollisionMaximum;
static uint32_t gRank4UpperWarpMaximum;
static uint32_t gRank4TopResurrections;
static uint32_t gRank4TopPositionWrites;
static uint32_t gRank4LiveTopPositionWrites;
static uint32_t gRank4RetiredSlotPositionWrites;
static uint32_t gRank4TopIdentityWrites;
static uint32_t gRank4LiveTopIdentityWrites;
static uint32_t gRank4RetiredSlotIdentityWrites;
static uint32_t gRank4WarpPositionWrites;
static uint32_t gRank4WarpCollisionWrites;
static uint32_t gRank4WarpIdentityWrites;
static uint32_t gRank4TopCollisionLoadCalls;
static uint32_t gRank4BadTopCollisionLoadCalls;
static uint32_t gRank4UpperWarpCollisionLoadCalls;
static struct rank1_writer_count gRank4TopPositionWriterCounts[16];
static unsigned gRank4TopPositionWriterKinds;
static float gRank4TopMinX = INFINITY;
static float gRank4TopMaxX = -INFINITY;
static float gRank4TopMinY = INFINITY;
static float gRank4TopMaxY = -INFINITY;
static float gRank4TopMinZ = INFINITY;
static float gRank4TopMaxZ = -INFINITY;
#endif

#if RANK5_STATE_SPLIT_AUDIT
enum rank5_phase {
    RANK5_PHASE_INACTIVE = 0,
    RANK5_PHASE_PRE_APPLY,
    RANK5_PHASE_IN_APPLY,
    RANK5_PHASE_POST_APPLY,
    RANK5_PHASE_POST_COLLISION,
    RANK5_PHASE_POST_COPY,
    RANK5_PHASE_POST_NON_TERRAIN,
    RANK5_PHASE_POST_UNLOAD,
    RANK5_PHASE_POST_FINAL_QUERY,
};

static int gRank5BreakpointsArmed;
static int gRank5Initialized;
static int gRank5Complete;
static enum rank5_phase gRank5Phase;
static uint32_t gRank5FrameTimer;
static uint32_t gRank5FramesStarted;
static uint32_t gRank5FramesFinished;
static uint32_t gRank5OrderFailures;
static uint32_t gRank5IdentityFailures;
static uint32_t gRank5IdentityWrites;
static unsigned gRank5IdentityWriterKinds;
static uint32_t gRank5CodeWrites;
static uint32_t gRank5EntryStateObjectMismatches;
static uint32_t gRank5ApplyEntryStateObjectMismatches;
static uint32_t gRank5PostApplyStateObjectMismatches;
static uint32_t gRank5CollisionStateObjectMismatches;
static uint32_t gRank5ApplyEntries;
static uint32_t gRank5ApplyReturns;
static uint32_t gRank5ApplyHelperCalls;
static uint32_t gRank5NonnullApplyEntries;
static uint32_t gRank5InvalidApplyOwners;
static uint32_t gRank5ApplyStateChanges;
static uint32_t gRank5ApplyObjectChanges;
static uint32_t gRank5ApplyGraphicsChanges;
static uint32_t gRank5ApplyStateWrites;
static uint32_t gRank5ApplyObjectWrites;
static uint32_t gRank5ApplyGraphicsWrites;
static uint32_t gRank5PostApplyStateWrites;
static uint32_t gRank5PostApplyObjectWrites;
static uint32_t gRank5PostApplyGraphicsWrites;
static uint32_t gRank5UpperWarpApplyEntries;
static uint32_t gRank5UpperWarpNonnullApplyEntries;
static uint32_t gRank5UpperWarpApplyStateChanges;
static uint32_t gRank5CollisionEntries;
static uint32_t gRank5CollisionReturns;
static uint32_t gRank5PrecollisionObjectChanges;
static uint32_t gRank5CopyReturns;
static uint32_t gRank5CopyReceiverFailures;
static uint32_t gRank5CopyStateObjectMismatches;
static uint32_t gRank5BhvMarioReturns;
static uint32_t gRank5PostCopyStateWrites;
static uint32_t gRank5PostCopyObjectWrites;
static unsigned gRank5PostCopyStateWriterKinds;
static unsigned gRank5PostCopyObjectWriterKinds;
static uint32_t gRank5PreapplyStateWrites;
static uint32_t gRank5PreapplyObjectWrites;
static uint32_t gRank5PostCopyTailMismatches;
static uint32_t gRank5PostNonTerrainChecks;
static uint32_t gRank5PostUnloadChecks;
static uint32_t gRank5PostFinalQueryChecks;
static uint32_t gRank5PlatformWrites;
static uint32_t gRank5GlobalPlatformWrites;
static uint32_t gRank5ObjectPlatformWrites;
static uint32_t gRank5NonnullPlatformWrites;
static uint32_t gRank5UnexpectedPlatformWrites;
static uint32_t gRank5WriteDecodeFailures;
static unsigned gRank5PlatformWriterKinds;
static uint32_t gRank5ApplyPlatform;
static int gRank5ApplyObjectAtUpperWarp;
static uint32_t gRank5FirstApplyStateChangeTimer;
static uint32_t gRank5FirstApplyStateChangePlatform;
static uint32_t gRank5ApplyBeforeState[3];
static uint32_t gRank5ApplyBeforeObject[3];
static uint32_t gRank5ApplyBeforeGraphics[3];
static uint32_t gRank5FirstApplyBeforeState[3];
static uint32_t gRank5FirstApplyAfterState[3];
static struct rank1_writer_count gRank5PostCopyStateWriters[16];
static struct rank1_writer_count gRank5PostCopyObjectWriters[16];
static struct rank1_writer_count gRank5PlatformWriters[16];
static struct rank1_writer_count gRank5IdentityWriters[16];
#endif

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

#if RANK1_BOUNDARY_AUDIT
static int add_rank1_write_breakpoints(uint32_t address, uint32_t size) {
    int cached = add_write_breakpoint(address, size);
    int uncached = add_write_breakpoint(address ^ 0x20000000u, size);
    return cached && uncached;
}

static void rank1_hash_word(uint32_t word) {
    gRank1EventHash ^= word;
    gRank1EventHash *= 16777619u;
}

static int rank1_in_range(uint32_t address, uint32_t width,
                          uint32_t start, uint32_t end) {
    return width != 0 && address >= start && address <= end
        && width <= end - address;
}

static int rank1_overlaps_range(uint32_t address, uint32_t width,
                                uint32_t start, uint32_t end) {
    uint64_t access_end = (uint64_t) address + width;
    return width != 0 && (uint64_t) address < end && access_end > start;
}

/* KSEG0 and KSEG1 name the same first 512 MiB of physical memory.  Normalize
 * either CPU alias before classifying a triggered write so that an uncached
 * pointer cannot evade the protected-range test. */
static uint32_t rank1_kseg0_address(uint32_t address) {
    uint32_t segment = address & 0xe0000000u;
    if (segment == 0x80000000u || segment == 0xa0000000u) {
        return 0x80000000u | (address & 0x1fffffffu);
    }
    return address;
}

static uint32_t rank1_effective_address(uint32_t instruction,
                                        uint64_t *registers) {
    unsigned base = (instruction >> 21) & 31;
    int32_t displacement = (int16_t) instruction;
    return registers == NULL ? 0
        : (uint32_t) registers[base] + displacement;
}

static uint32_t rank1_source_value(uint32_t instruction,
                                   uint64_t *registers) {
    unsigned source = (instruction >> 16) & 31;
    return registers == NULL ? 0 : (uint32_t) registers[source];
}

/* Decode the exact byte interval touched by one big-endian R4300 store.
 * Left/right stores do not begin at the same address as an ordinary store:
 * SWL/SDL extend right from the effective address, while SWR/SDR extend left
 * from the containing aligned word.  Returning false lets the Rank-5 path
 * fail closed using the debugger-reported physical access. */
static int rank1_decode_store_range(uint32_t instruction,
                                    uint64_t *registers,
                                    uint32_t *target, unsigned *width) {
    uint32_t address;

    if (registers == NULL || target == NULL || width == NULL) return 0;
    address = rank1_effective_address(instruction, registers);
    *target = address;
    switch (instruction >> 26) {
        case 0x28: *width = 1; return 1; /* sb */
        case 0x29: *width = 2; return 1; /* sh */
        case 0x2a:                         /* swl */
            *width = 4 - (address & 3);
            return 1;
        case 0x2b: *width = 4; return 1; /* sw */
        case 0x2c:                         /* sdl */
            *width = 8 - (address & 7);
            return 1;
        case 0x2d:                         /* sdr */
            *target = address & ~7u;
            *width = (address & 7) + 1;
            return 1;
        case 0x2e:                         /* swr */
            *target = address & ~3u;
            *width = (address & 3) + 1;
            return 1;
        case 0x38: *width = 4; return 1; /* sc */
        case 0x39: *width = 4; return 1; /* swc1 */
        case 0x3a: *width = 4; return 1; /* swc2 */
        case 0x3c: *width = 8; return 1; /* scd */
        case 0x3d: *width = 8; return 1; /* sdc1 */
        case 0x3e: *width = 8; return 1; /* sdc2 */
        case 0x3f: *width = 8; return 1; /* sd */
        default: return 0;
    }
}

/* Only these GPR stores expose the exact complete u32 written to a watched
 * platform cell through the existing GPR snapshot.  Coprocessor stores must
 * not be classified from the same-numbered GPR.  Partial and 64-bit stores
 * are still range-decoded, but their platform value is failed closed. */
static int rank1_store_u32_value_known(uint32_t instruction,
                                       unsigned width) {
    uint32_t opcode = instruction >> 26;
    return width == 4
        && (opcode == 0x2a || opcode == 0x2b || opcode == 0x2e);
}

static void rank1_count_writer(struct rank1_writer_count *counts,
                               unsigned *kinds, unsigned capacity,
                               uint32_t pc) {
    unsigned i;

    for (i = 0; i < *kinds; i++) {
        if (counts[i].pc == pc) {
            counts[i].count++;
            return;
        }
    }
    if (*kinds < capacity) {
        counts[*kinds].pc = pc;
        counts[*kinds].count = 1;
        (*kinds)++;
    } else {
        gRank1UnsafePoolWrites++;
    }
}

#if RANK4_WARP_TOP_AUDIT
static int rank4_top_pose_safe(uint32_t object) {
    float x = rfloat(object + O_POS_X);
    float y = rfloat(object + O_POS_Y);
    float z = rfloat(object + O_POS_Z);

    return isfinite(x) && isfinite(y) && isfinite(z)
        && x >= -2087.0f && x <= -2007.0f
        && y >= 1536.0f && y < 1879.0f
        && z == -1023.0f;
}

static void rank4_update_top_envelope(uint32_t object) {
    float x = rfloat(object + O_POS_X);
    float y = rfloat(object + O_POS_Y);
    float z = rfloat(object + O_POS_Z);

    if (x < gRank4TopMinX) gRank4TopMinX = x;
    if (x > gRank4TopMaxX) gRank4TopMaxX = x;
    if (y < gRank4TopMinY) gRank4TopMinY = y;
    if (y > gRank4TopMaxY) gRank4TopMaxY = y;
    if (z < gRank4TopMinZ) gRank4TopMinZ = z;
    if (z > gRank4TopMaxZ) gRank4TopMaxZ = z;
}

/* Return true exactly when this store overlaps one of the already-discovered
 * canonical top/upper-warp cells.  The debugger stops before the store.  Top
 * position stores are permitted here because the collision-call checkpoint
 * below validates the resulting pose before any triangles can be installed;
 * every warp position/identity store is a trace failure, while top identity
 * stores are split between the live identity (a failure) and a retired slot
 * whose later collision loads remain independently checked. */
static int rank4_note_write(uint32_t pc, uint32_t target, uint32_t source,
                            unsigned width) {
    int watched = 0;

    if (!gRank4Initialized || R16(A_CURR_AREA) != 1
        || R32(A_GLOBAL_TIMER) < 348
        || R32(A_GLOBAL_TIMER) >= 2810) return 0;
    if (rank1_overlaps_range(target, width,
                             gRank4CanonicalTop + O_POS_X,
                             gRank4CanonicalTop + O_POS_Z + 4)) {
        watched = 1;
        gRank4TopPositionWrites++;
        rank1_count_writer(gRank4TopPositionWriterCounts,
                           &gRank4TopPositionWriterKinds, 16, pc);
        if (gRank4TopRetired) gRank4RetiredSlotPositionWrites++;
        else gRank4LiveTopPositionWrites++;
    }
    if (rank1_overlaps_range(target, width,
                             gRank4CanonicalTop + O_BEHAVIOR,
                             gRank4CanonicalTop + O_BEHAVIOR + 4)
        || rank1_overlaps_range(target, width,
                                gRank4CanonicalTop + O_COLLISION_DATA,
                                gRank4CanonicalTop + O_COLLISION_DATA + 4)) {
        watched = 1;
        gRank4TopIdentityWrites++;
        if (gRank4TopRetired) gRank4RetiredSlotIdentityWrites++;
        else gRank4LiveTopIdentityWrites++;
        fprintf(stderr,
                "RANK4_TOP_IDENTITY_WRITE,timer=%u,pc=%08x,target=%08x,"
                "value=%08x,"
                "active=%04x,behavior=%08x,collision=%08x,retired=%d\n",
                R32(A_GLOBAL_TIMER), pc, target, source,
                R16(gRank4CanonicalTop + O_ACTIVE_FLAGS),
                R32(gRank4CanonicalTop + O_BEHAVIOR),
                R32(gRank4CanonicalTop + O_COLLISION_DATA),
                gRank4TopRetired);
    }
    if (rank1_overlaps_range(target, width,
                             gRank4CanonicalUpperWarp + O_POS_X,
                             gRank4CanonicalUpperWarp + O_POS_Z + 4)) {
        watched = 1;
        gRank4WarpPositionWrites++;
    }
    if (rank1_overlaps_range(target, width,
                             gRank4CanonicalUpperWarp + O_COLLISION_DATA,
                             gRank4CanonicalUpperWarp
                                 + O_COLLISION_DATA + 4)) {
        watched = 1;
        gRank4WarpCollisionWrites++;
    }
    if (rank1_overlaps_range(target, width,
                             gRank4CanonicalUpperWarp + O_BEHAVIOR,
                             gRank4CanonicalUpperWarp + O_BEHAVIOR + 4)) {
        watched = 1;
        gRank4WarpIdentityWrites++;
    }
    return watched;
}

static void rank4_note_collision_load_call(uint32_t owner) {
    uint32_t collision_data;

    if (!gRank4Initialized || R16(A_CURR_AREA) != 1
        || R32(A_GLOBAL_TIMER) < 348
        || R32(A_GLOBAL_TIMER) >= 2810) return;
    collision_data = pool_index(owner) < 0
        ? 0 : R32(owner + O_COLLISION_DATA);
    if (owner == gRank4CanonicalUpperWarp) {
        gRank4UpperWarpCollisionLoadCalls++;
    }
    if (collision_data == gRank4TopCollisionData) {
        gRank4TopCollisionLoadCalls++;
        if (owner != gRank4CanonicalTop
            || R32(owner + O_BEHAVIOR) != gRank4TopBehavior
            || !rank4_top_pose_safe(owner)) {
            gRank4BadTopCollisionLoadCalls++;
            fprintf(stderr,
                    "RANK4_FAILURE,kind=top-collision-owner-or-pose,"
                    "timer=%u,owner=%08x,behavior=%08x,collision=%08x,"
                    "x=%.9g,y=%.9g,z=%.9g\n",
                    R32(A_GLOBAL_TIMER), owner,
                    pool_index(owner) < 0 ? 0
                        : R32(owner + O_BEHAVIOR), collision_data,
                    pool_index(owner) < 0 ? 0.0f
                        : rfloat(owner + O_POS_X),
                    pool_index(owner) < 0 ? 0.0f
                        : rfloat(owner + O_POS_Y),
                    pool_index(owner) < 0 ? 0.0f
                        : rfloat(owner + O_POS_Z));
        }
        if (owner == gRank4CanonicalTop
            && R16(owner + O_ACTIVE_FLAGS) == 0) {
            gRank4TopRetired = 1;
        }
    }
}

static void rank4_observe_frame(void) {
    uint32_t timer = R32(A_GLOBAL_TIMER);
    uint32_t top_behavior_count = 0;
    uint32_t top_collision_count = 0;
    uint32_t upper_warp_count = 0;
    int frame_safe = 1;
    unsigned i;

    if (!gRank4Initialized || R16(A_CURR_AREA) != 1
        || timer < 348 || timer >= 2810) return;
    for (i = 0; i < OBJECT_COUNT; i++) {
        uint32_t object = A_OBJECT_POOL + i * OBJECT_SIZE;
        uint32_t behavior;
        uint32_t collision_data;
        if (R16(object + O_ACTIVE_FLAGS) == 0) continue;
        behavior = R32(object + O_BEHAVIOR);
        collision_data = R32(object + O_COLLISION_DATA);
        if (behavior == gRank4TopBehavior) {
            top_behavior_count++;
            if (object != gRank4CanonicalTop) frame_safe = 0;
        }
        if (collision_data == gRank4TopCollisionData) {
            top_collision_count++;
            if (object != gRank4CanonicalTop
                || behavior != gRank4TopBehavior) frame_safe = 0;
        }
        if (behavior == gRank4WarpBehavior
            && ((R32(object + O_BHV_PARAMS) >> 16) & 0xff) == 0x1e) {
            upper_warp_count++;
            if (object != gRank4CanonicalUpperWarp) frame_safe = 0;
        }
    }
    if (top_behavior_count > gRank4TopBehaviorMaximum) {
        gRank4TopBehaviorMaximum = top_behavior_count;
    }
    if (top_collision_count > gRank4TopCollisionMaximum) {
        gRank4TopCollisionMaximum = top_collision_count;
    }
    if (upper_warp_count > gRank4UpperWarpMaximum) {
        gRank4UpperWarpMaximum = upper_warp_count;
    }
    if (top_behavior_count > 1 || top_collision_count > 1
        || upper_warp_count != 1) frame_safe = 0;

    if (R16(gRank4CanonicalTop + O_ACTIVE_FLAGS) != 0
        && R32(gRank4CanonicalTop + O_BEHAVIOR) == gRank4TopBehavior) {
        gRank4TopActiveFrames++;
        if (gRank4TopRetired) {
            gRank4TopResurrections++;
            frame_safe = 0;
        }
        if (R32(gRank4CanonicalTop + O_COLLISION_DATA)
                != gRank4TopCollisionData
            || !rank4_top_pose_safe(gRank4CanonicalTop)) {
            frame_safe = 0;
        }
        rank4_update_top_envelope(gRank4CanonicalTop);
    } else {
        gRank4TopAbsentFrames++;
        gRank4TopRetired = 1;
    }

    if (R16(gRank4CanonicalUpperWarp + O_ACTIVE_FLAGS) != 0
        && R32(gRank4CanonicalUpperWarp + O_BEHAVIOR)
            == gRank4WarpBehavior
        && ((R32(gRank4CanonicalUpperWarp + O_BHV_PARAMS) >> 16) & 0xff)
            == 0x1e) {
        gRank4WarpActiveFrames++;
        if (rfloat(gRank4CanonicalUpperWarp + O_POS_X) != -2048.0f
            || rfloat(gRank4CanonicalUpperWarp + O_POS_Y) != 768.0f
            || rfloat(gRank4CanonicalUpperWarp + O_POS_Z) != -1024.0f
            || R32(gRank4CanonicalUpperWarp + O_COLLISION_DATA) != 0) {
            frame_safe = 0;
        }
    } else {
        frame_safe = 0;
    }
    gRank4FramesChecked++;
    if (!frame_safe) {
        gRank4FrameFailures++;
        fprintf(stderr,
                "RANK4_FAILURE,kind=frame-census,timer=%u,"
                "topBehaviors=%u,topCollisions=%u,upperWarps=%u,"
                "topActive=%04x,warpActive=%04x\n",
                timer, top_behavior_count, top_collision_count,
                upper_warp_count,
                R16(gRank4CanonicalTop + O_ACTIVE_FLAGS),
                R16(gRank4CanonicalUpperWarp + O_ACTIVE_FLAGS));
    }
}

static void arm_rank4_warp_top_audit(void) {
    int armed;

    if (gRank4BreakpointsArmed || gTop == 0 || gUpperWarp == 0) return;
    gRank4CanonicalTop = gTop;
    gRank4CanonicalUpperWarp = gUpperWarp;
    gRank4TopBehavior = R32(gTop + O_BEHAVIOR);
    gRank4WarpBehavior = R32(gUpperWarp + O_BEHAVIOR);
    gRank4TopCollisionData = R32(gTop + O_COLLISION_DATA);
    armed = gRank4TopBehavior != 0 && gRank4WarpBehavior != 0
        && gRank4TopCollisionData != 0
        && R32(gUpperWarp + O_COLLISION_DATA) == 0
        && add_rank1_write_breakpoints(gTop + O_POS_X, 12)
        && add_rank1_write_breakpoints(gTop + O_BEHAVIOR, 4)
        && add_rank1_write_breakpoints(gTop + O_COLLISION_DATA, 4)
        && add_rank1_write_breakpoints(gUpperWarp + O_POS_X, 12)
        && add_rank1_write_breakpoints(gUpperWarp + O_BEHAVIOR, 4)
        && add_rank1_write_breakpoints(gUpperWarp + O_COLLISION_DATA, 4)
        && add_exec_breakpoint(A_LOAD_OBJECT_SURFACES);
    if (!armed) {
        fprintf(stderr, "RANK4_WARP_TOP_ERROR,kind=breakpoint-arm\n");
        return;
    }
    gRank4BreakpointsArmed = 1;
    gRank4Initialized = 1;
    fprintf(stderr,
            "RANK4_WARP_TOP_ARM,timer=%u,top=%08x,topSlot=%d,"
            "topBehavior=%08x,topCollision=%08x,upperWarp=%08x,"
            "upperWarpSlot=%d,warpBehavior=%08x,warpCollision=%08x,"
            "warpX=%.9g,warpY=%.9g,warpZ=%.9g,readOnly=1\n",
            R32(A_GLOBAL_TIMER), gRank4CanonicalTop,
            pool_index(gRank4CanonicalTop), gRank4TopBehavior,
            gRank4TopCollisionData, gRank4CanonicalUpperWarp,
            pool_index(gRank4CanonicalUpperWarp), gRank4WarpBehavior,
            R32(gRank4CanonicalUpperWarp + O_COLLISION_DATA),
            rfloat(gRank4CanonicalUpperWarp + O_POS_X),
            rfloat(gRank4CanonicalUpperWarp + O_POS_Y),
            rfloat(gRank4CanonicalUpperWarp + O_POS_Z));
}
#endif

static int rank1_valid_object_node(uint32_t node, uint32_t sentinel) {
    return node == sentinel || pool_index(node) >= 0;
}

/* Validate every object-list ring while locating one object.  The returned
 * index is unique when the rings are intact, or -1 when the object is absent. */
static int rank1_object_list_index(uint32_t object, int *rings_intact) {
    int found = -1;
    int found_count = 0;
    unsigned list_index;

    *rings_intact = 1;
    for (list_index = 0; list_index < OBJECT_LIST_COUNT; list_index++) {
        uint32_t sentinel = A_OBJECT_LIST_ARRAY
            + list_index * OBJECT_NODE_SIZE;
        uint32_t node = R32(sentinel + HEADER_NEXT);
        uint32_t previous = sentinel;
        unsigned steps = 0;

        if (!rank1_valid_object_node(node, sentinel)) {
            *rings_intact = 0;
            continue;
        }
        while (node != sentinel) {
            uint32_t next;
            if (pool_index(node) < 0 || steps++ >= OBJECT_COUNT) {
                *rings_intact = 0;
                break;
            }
            if (R32(node + HEADER_PREV) != previous) {
                *rings_intact = 0;
                break;
            }
            if (node == object) {
                found = (int) list_index;
                found_count++;
            }
            next = R32(node + HEADER_NEXT);
            if (!rank1_valid_object_node(next, sentinel)) {
                *rings_intact = 0;
                break;
            }
            previous = node;
            node = next;
        }
        if (node == sentinel
            && (R32(sentinel + HEADER_PREV) != previous
                || R32(previous + HEADER_NEXT) != sentinel)) {
            *rings_intact = 0;
        }
    }
    if (found_count > 1) *rings_intact = 0;
    return found_count == 1 ? found : -1;
}

#if RANK5_STATE_SPLIT_AUDIT
static void rank5_read_state(uint32_t words[3]) {
    words[0] = R32(A_MARIO_STATES + M_POS_X);
    words[1] = R32(A_MARIO_STATES + M_POS_Y);
    words[2] = R32(A_MARIO_STATES + M_POS_Z);
}

static void rank5_read_object(uint32_t words[3]) {
    uint32_t mario = R32(A_MARIO_OBJECT);
    words[0] = mario == 0 ? 0 : R32(mario + O_POS_X);
    words[1] = mario == 0 ? 0 : R32(mario + O_POS_Y);
    words[2] = mario == 0 ? 0 : R32(mario + O_POS_Z);
}

static void rank5_read_graphics(uint32_t words[3]) {
    uint32_t mario = R32(A_MARIO_OBJECT);
    words[0] = mario == 0 ? 0 : R32(mario + GFX_POS_X);
    words[1] = mario == 0 ? 0 : R32(mario + GFX_POS_Y);
    words[2] = mario == 0 ? 0 : R32(mario + GFX_POS_Z);
}

static int rank5_vec_equal(const uint32_t left[3],
                           const uint32_t right[3]) {
    return left[0] == right[0] && left[1] == right[1]
        && left[2] == right[2];
}

static int rank5_state_object_equal(void) {
    uint32_t state[3];
    uint32_t object[3];
    rank5_read_state(state);
    rank5_read_object(object);
    return rank5_vec_equal(state, object);
}

static int rank5_mario_identity_holds(void) {
    return R32(A_MARIO_OBJECT) == A_SLOT67
        && R32(A_STATE_MARIO_OBJECT) == A_SLOT67
        && R16(A_SLOT67_ACTIVE_FLAGS) != 0
        && R32(A_SLOT67_BEHAVIOR) == A_BHV_MARIO
        && R32(A_SLOT67_NEXT) == A_LIST0_SENTINEL_NEXT - HEADER_NEXT
        && R32(A_SLOT67_PREV) == A_LIST0_SENTINEL_PREV - HEADER_PREV
        && R32(A_LIST0_SENTINEL_NEXT) == A_SLOT67
        && R32(A_LIST0_SENTINEL_PREV) == A_SLOT67;
}

static int rank5_object_at_upper_warp(void) {
    float x = rfloat(A_SLOT67 + O_POS_X);
    float y = rfloat(A_SLOT67 + O_POS_Y);
    float z = rfloat(A_SLOT67 + O_POS_Z);
    float dx = x + 2048.0f;
    float dz = z + 1024.0f;

    return isfinite(x) && isfinite(y) && isfinite(z)
        && dx * dx + dz * dz < 187.0f * 187.0f
        && y <= 818.0f && y + 160.0f >= 768.0f;
}

static int rank5_apply_owner_is_live(uint32_t owner) {
    int rings_intact;
    int list_index;

    if (pool_index(owner) < 0 || R16(owner + O_ACTIVE_FLAGS) == 0
        || R32(owner + O_BEHAVIOR) == 0) return 0;
    list_index = rank1_object_list_index(owner, &rings_intact);
    return rings_intact && list_index >= 0;
}

static void rank5_note_tail_check(uint32_t *counter) {
    (*counter)++;
    if (!rank5_state_object_equal()) gRank5PostCopyTailMismatches++;
    if (!rank5_mario_identity_holds()) gRank5IdentityFailures++;
}

static void rank5_finish_frame(void) {
    if (gRank5Phase != RANK5_PHASE_POST_FINAL_QUERY) {
        gRank5OrderFailures++;
    }
    if (!rank5_state_object_equal()) gRank5PostCopyTailMismatches++;
    if (!rank5_mario_identity_holds()) gRank5IdentityFailures++;
    gRank5FramesFinished++;
    gRank5Phase = RANK5_PHASE_INACTIVE;
}

static void rank5_start_frame(uint32_t timer) {
    gRank5FrameTimer = timer;
    gRank5FramesStarted++;
    gRank5Phase = RANK5_PHASE_PRE_APPLY;
    if (!rank5_state_object_equal()) gRank5EntryStateObjectMismatches++;
    if (!rank5_mario_identity_holds()) gRank5IdentityFailures++;
}

static int rank5_watches_range(uint32_t target, uint32_t width) {
    return rank1_overlaps_range(target, width,
                                A_MARIO_STATES + M_POS_X,
                                A_MARIO_STATES + M_POS_X + 12)
        || rank1_overlaps_range(target, width, A_SLOT67 + O_POS_X,
                                A_SLOT67 + O_POS_X + 12)
        || rank1_overlaps_range(target, width, A_SLOT67 + GFX_POS_X,
                                A_SLOT67 + GFX_POS_X + 12)
        || rank1_overlaps_range(target, width, A_MARIO_PLATFORM,
                                A_MARIO_PLATFORM + 4)
        || rank1_overlaps_range(target, width, A_SLOT67_PLATFORM,
                                A_SLOT67_PLATFORM + 4)
        || rank1_overlaps_range(target, width, A_MARIO_OBJECT,
                                A_MARIO_OBJECT + 4)
        || rank1_overlaps_range(target, width, A_STATE_MARIO_OBJECT,
                                A_STATE_MARIO_OBJECT + 4)
        || rank1_overlaps_range(target, width, A_SLOT67_NEXT,
                                A_SLOT67_PREV + 4)
        || rank1_overlaps_range(target, width, A_SLOT67_ACTIVE_FLAGS,
                                A_SLOT67_ACTIVE_FLAGS + 2)
        || rank1_overlaps_range(target, width, A_SLOT67_BEHAVIOR,
                                A_SLOT67_BEHAVIOR + 4)
        || rank1_overlaps_range(target, width, A_LIST0_SENTINEL_NEXT,
                                A_LIST0_SENTINEL_PREV + 4)
        || rank1_overlaps_range(target, width, A_BHV_MARIO,
                                A_BHV_MARIO + BHV_MARIO_WORDS * 4)
        || rank1_overlaps_range(target, width, A_BEHAVIOR_CMD_TABLE,
                                A_BEHAVIOR_CMD_TABLE
                                    + BEHAVIOR_CMD_TABLE_WORDS * 4);
}

static int rank5_note_undecoded_write(uint32_t accessed) {
    uint32_t accessed_word = 0x80000000u
        | ((accessed & 0x1fffffffu) & ~3u);

    if (!gRank5Initialized || gRank5Complete
        || gRank5Phase == RANK5_PHASE_INACTIVE
        || !rank5_watches_range(accessed_word, 4)) return 0;
    gRank5WriteDecodeFailures++;
    return 1;
}

static int rank5_note_write(uint32_t pc, uint32_t target,
                            uint32_t source, uint32_t width,
                            int u32_value_known) {
    int watched = 0;
    int expected_platform_writer = 0;

    if (!gRank5Initialized || gRank5Complete
        || gRank5Phase == RANK5_PHASE_INACTIVE) return 0;
    if (rank1_overlaps_range(target, width,
                             A_MARIO_STATES + M_POS_X,
                             A_MARIO_STATES + M_POS_X + 12)) {
        watched = 1;
        if (gRank5Phase == RANK5_PHASE_IN_APPLY) {
            gRank5ApplyStateWrites++;
        } else if (gRank5Phase == RANK5_PHASE_POST_APPLY) {
            gRank5PostApplyStateWrites++;
        } else if (gRank5Phase == RANK5_PHASE_PRE_APPLY) {
            gRank5PreapplyStateWrites++;
        } else if (gRank5Phase >= RANK5_PHASE_POST_COPY) {
            gRank5PostCopyStateWrites++;
            rank1_count_writer(gRank5PostCopyStateWriters,
                               &gRank5PostCopyStateWriterKinds, 16, pc);
        }
    }
    if (rank1_overlaps_range(target, width, A_SLOT67 + O_POS_X,
                             A_SLOT67 + O_POS_X + 12)) {
        watched = 1;
        if (gRank5Phase == RANK5_PHASE_IN_APPLY) {
            gRank5ApplyObjectWrites++;
        } else if (gRank5Phase == RANK5_PHASE_POST_APPLY) {
            gRank5PostApplyObjectWrites++;
        } else if (gRank5Phase == RANK5_PHASE_PRE_APPLY) {
            gRank5PreapplyObjectWrites++;
        } else if (gRank5Phase >= RANK5_PHASE_POST_COPY) {
            gRank5PostCopyObjectWrites++;
            rank1_count_writer(gRank5PostCopyObjectWriters,
                               &gRank5PostCopyObjectWriterKinds, 16, pc);
        }
    }
    if (rank1_overlaps_range(target, width, A_SLOT67 + GFX_POS_X,
                             A_SLOT67 + GFX_POS_X + 12)) {
        watched = 1;
        if (gRank5Phase == RANK5_PHASE_IN_APPLY) {
            gRank5ApplyGraphicsWrites++;
        } else if (gRank5Phase == RANK5_PHASE_POST_APPLY) {
            gRank5PostApplyGraphicsWrites++;
        }
    }
    if (rank1_overlaps_range(target, width, A_MARIO_PLATFORM,
                             A_MARIO_PLATFORM + 4)) {
        watched = 1;
        gRank5PlatformWrites++;
        gRank5GlobalPlatformWrites++;
        if (!u32_value_known || target != A_MARIO_PLATFORM || width != 4) {
            gRank5WriteDecodeFailures++;
        } else if (source != 0) {
            gRank5NonnullPlatformWrites++;
        }
        expected_platform_writer =
            pc == A_PLATFORM_GLOBAL_CLEAR_AWAY
            || pc == A_PLATFORM_GLOBAL_OWNER_STORE
            || pc == A_PLATFORM_GLOBAL_CLEAR_OWNERLESS;
        if (!expected_platform_writer) gRank5UnexpectedPlatformWrites++;
        rank1_count_writer(gRank5PlatformWriters,
                           &gRank5PlatformWriterKinds, 16, pc);
    }
    if (rank1_overlaps_range(target, width, A_SLOT67_PLATFORM,
                             A_SLOT67_PLATFORM + 4)) {
        watched = 1;
        gRank5PlatformWrites++;
        gRank5ObjectPlatformWrites++;
        if (!u32_value_known || target != A_SLOT67_PLATFORM || width != 4) {
            gRank5WriteDecodeFailures++;
        } else if (source != 0) {
            gRank5NonnullPlatformWrites++;
        }
        expected_platform_writer =
            pc == A_PLATFORM_OBJECT_CLEAR_AWAY
            || pc == A_PLATFORM_OBJECT_OWNER_STORE
            || pc == A_PLATFORM_OBJECT_CLEAR_OWNERLESS;
        if (!expected_platform_writer) gRank5UnexpectedPlatformWrites++;
        rank1_count_writer(gRank5PlatformWriters,
                           &gRank5PlatformWriterKinds, 16, pc);
    }
    if (rank1_overlaps_range(target, width, A_MARIO_OBJECT,
                             A_MARIO_OBJECT + 4)
        || rank1_overlaps_range(target, width, A_STATE_MARIO_OBJECT,
                                A_STATE_MARIO_OBJECT + 4)
        || rank1_overlaps_range(target, width, A_SLOT67_NEXT,
                                A_SLOT67_PREV + 4)
        || rank1_overlaps_range(target, width, A_SLOT67_ACTIVE_FLAGS,
                                A_SLOT67_ACTIVE_FLAGS + 2)
        || rank1_overlaps_range(target, width, A_SLOT67_BEHAVIOR,
                                A_SLOT67_BEHAVIOR + 4)
        || rank1_overlaps_range(target, width, A_LIST0_SENTINEL_NEXT,
                                A_LIST0_SENTINEL_PREV + 4)) {
        watched = 1;
        gRank5IdentityWrites++;
        rank1_count_writer(gRank5IdentityWriters,
                           &gRank5IdentityWriterKinds, 16, pc);
    }
    if (rank1_overlaps_range(target, width, A_BHV_MARIO,
                             A_BHV_MARIO + BHV_MARIO_WORDS * 4)
        || rank1_overlaps_range(target, width, A_BEHAVIOR_CMD_TABLE,
                                A_BEHAVIOR_CMD_TABLE
                                    + BEHAVIOR_CMD_TABLE_WORDS * 4)) {
        watched = 1;
        gRank5CodeWrites++;
    }
    return watched;
}

static int rank5_is_exec_breakpoint(uint32_t pc) {
    switch (pc) {
        case A_UPDATE_OBJECTS:
        case A_APPLY_MARIO_PLATFORM_DISPLACEMENT:
        case A_APPLY_PLATFORM_DISPLACEMENT_CALLSITE:
        case A_POST_APPLY_MARIO_PLATFORM:
        case A_DETECT_OBJECT_COLLISIONS:
        case A_POST_DETECT_OBJECT_COLLISIONS:
        case A_POST_COPY_MARIO_STATE_TO_OBJECT:
        case A_BHV_MARIO_RETURN:
        case A_POST_NON_TERRAIN_OBJECTS:
        case A_POST_UNLOAD_DEACTIVATED_OBJECTS:
        case A_POST_MARIO_PLATFORM:
            return 1;
        default:
            return 0;
    }
}

static int rank5_handle_exec(uint32_t pc) {
    uint32_t timer = R32(A_GLOBAL_TIMER);

    if (!gRank5Initialized || !rank5_is_exec_breakpoint(pc)) return 0;
    if (pc == A_UPDATE_OBJECTS) {
        if (gRank5Phase != RANK5_PHASE_INACTIVE) rank5_finish_frame();
        if (timer >= 2810) {
            gRank5Complete = 1;
        } else if (timer >= 348 && R16(A_CURR_AREA) == 1) {
            rank5_start_frame(timer);
        }
        return 1;
    }
    if (gRank5Complete || gRank5Phase == RANK5_PHASE_INACTIVE) return 1;
    if (pc == A_APPLY_MARIO_PLATFORM_DISPLACEMENT) {
        int rings_intact;
        int mario_list;

        if (gRank5Phase != RANK5_PHASE_PRE_APPLY) gRank5OrderFailures++;
        gRank5ApplyEntries++;
        gRank5ApplyPlatform = R32(A_MARIO_PLATFORM);
        gRank5ApplyObjectAtUpperWarp = rank5_object_at_upper_warp();
        rank5_read_state(gRank5ApplyBeforeState);
        rank5_read_object(gRank5ApplyBeforeObject);
        rank5_read_graphics(gRank5ApplyBeforeGraphics);
        if (gRank5ApplyPlatform != 0) {
            gRank5NonnullApplyEntries++;
            if (!rank5_apply_owner_is_live(gRank5ApplyPlatform)) {
                gRank5InvalidApplyOwners++;
            }
        }
        if (gRank5ApplyObjectAtUpperWarp) {
            gRank5UpperWarpApplyEntries++;
            if (gRank5ApplyPlatform != 0) {
                gRank5UpperWarpNonnullApplyEntries++;
            }
            fprintf(stderr,
                    "RANK5_UPPER_WARP_APPLY,timer=%u,platform=%08x,"
                    "timeStop=%08x,state=%08x:%08x:%08x,"
                    "object=%08x:%08x:%08x,graphics=%08x:%08x:%08x\n",
                    timer, gRank5ApplyPlatform, R32(A_TIME_STOP_STATE),
                    gRank5ApplyBeforeState[0], gRank5ApplyBeforeState[1],
                    gRank5ApplyBeforeState[2], gRank5ApplyBeforeObject[0],
                    gRank5ApplyBeforeObject[1], gRank5ApplyBeforeObject[2],
                    gRank5ApplyBeforeGraphics[0],
                    gRank5ApplyBeforeGraphics[1],
                    gRank5ApplyBeforeGraphics[2]);
        }
        if (!rank5_state_object_equal()) {
            gRank5ApplyEntryStateObjectMismatches++;
        }
        if (!rank5_mario_identity_holds()) gRank5IdentityFailures++;
        mario_list = rank1_object_list_index(A_SLOT67, &rings_intact);
        if (!rings_intact || mario_list != 0) gRank5IdentityFailures++;
        gRank5Phase = RANK5_PHASE_IN_APPLY;
        return 1;
    }
    if (pc == A_APPLY_PLATFORM_DISPLACEMENT_CALLSITE) {
        if (gRank5Phase != RANK5_PHASE_IN_APPLY) gRank5OrderFailures++;
        gRank5ApplyHelperCalls++;
        return 1;
    }
    if (pc == A_POST_APPLY_MARIO_PLATFORM) {
        uint32_t after_state[3];
        uint32_t after_object[3];
        uint32_t after_graphics[3];
        int state_changed;

        if (gRank5Phase != RANK5_PHASE_IN_APPLY) gRank5OrderFailures++;
        gRank5ApplyReturns++;
        rank5_read_state(after_state);
        rank5_read_object(after_object);
        rank5_read_graphics(after_graphics);
        state_changed = !rank5_vec_equal(gRank5ApplyBeforeState,
                                         after_state);
        if (state_changed) {
            gRank5ApplyStateChanges++;
            if (gRank5ApplyObjectAtUpperWarp) {
                gRank5UpperWarpApplyStateChanges++;
            }
            if (gRank5FirstApplyStateChangeTimer == 0) {
                unsigned i;
                gRank5FirstApplyStateChangeTimer = gRank5FrameTimer;
                gRank5FirstApplyStateChangePlatform = gRank5ApplyPlatform;
                for (i = 0; i < 3; i++) {
                    gRank5FirstApplyBeforeState[i] =
                        gRank5ApplyBeforeState[i];
                    gRank5FirstApplyAfterState[i] = after_state[i];
                }
            }
        }
        if (!rank5_vec_equal(gRank5ApplyBeforeObject, after_object)) {
            gRank5ApplyObjectChanges++;
        }
        if (!rank5_vec_equal(gRank5ApplyBeforeGraphics, after_graphics)) {
            gRank5ApplyGraphicsChanges++;
        }
        if (!rank5_state_object_equal()) {
            gRank5PostApplyStateObjectMismatches++;
        }
        gRank5Phase = RANK5_PHASE_POST_APPLY;
        return 1;
    }
    if (pc == A_DETECT_OBJECT_COLLISIONS) {
        uint32_t object[3];

        if (gRank5Phase != RANK5_PHASE_POST_APPLY) gRank5OrderFailures++;
        gRank5CollisionEntries++;
        rank5_read_object(object);
        if (!rank5_vec_equal(gRank5ApplyBeforeObject, object)) {
            gRank5PrecollisionObjectChanges++;
        }
        if (!rank5_state_object_equal()) {
            gRank5CollisionStateObjectMismatches++;
        }
        return 1;
    }
    if (pc == A_POST_DETECT_OBJECT_COLLISIONS) {
        uint32_t object[3];

        if (gRank5Phase != RANK5_PHASE_POST_APPLY) gRank5OrderFailures++;
        gRank5CollisionReturns++;
        rank5_read_object(object);
        if (!rank5_vec_equal(gRank5ApplyBeforeObject, object)) {
            gRank5PrecollisionObjectChanges++;
        }
        if (!rank5_state_object_equal()) {
            gRank5CollisionStateObjectMismatches++;
        }
        gRank5Phase = RANK5_PHASE_POST_COLLISION;
        return 1;
    }
    if (pc == A_POST_COPY_MARIO_STATE_TO_OBJECT) {
        if (gRank5Phase != RANK5_PHASE_POST_COLLISION) {
            gRank5OrderFailures++;
        }
        gRank5CopyReturns++;
        if (R32(A_CURRENT_OBJECT) != A_SLOT67
            || !rank5_mario_identity_holds()) {
            gRank5CopyReceiverFailures++;
        }
        if (!rank5_state_object_equal()) {
            gRank5CopyStateObjectMismatches++;
        }
        gRank5Phase = RANK5_PHASE_POST_COPY;
        return 1;
    }
    if (pc == A_BHV_MARIO_RETURN) {
        if (gRank5Phase != RANK5_PHASE_POST_COPY) gRank5OrderFailures++;
        gRank5BhvMarioReturns++;
        if (!rank5_state_object_equal()) gRank5PostCopyTailMismatches++;
        return 1;
    }
    if (pc == A_POST_NON_TERRAIN_OBJECTS) {
        if (gRank5Phase != RANK5_PHASE_POST_COPY) gRank5OrderFailures++;
        rank5_note_tail_check(&gRank5PostNonTerrainChecks);
        gRank5Phase = RANK5_PHASE_POST_NON_TERRAIN;
        return 1;
    }
    if (pc == A_POST_UNLOAD_DEACTIVATED_OBJECTS) {
        if (gRank5Phase != RANK5_PHASE_POST_NON_TERRAIN) {
            gRank5OrderFailures++;
        }
        rank5_note_tail_check(&gRank5PostUnloadChecks);
        gRank5Phase = RANK5_PHASE_POST_UNLOAD;
        return 1;
    }
    if (pc == A_POST_MARIO_PLATFORM) {
        if (gRank5Phase != RANK5_PHASE_POST_UNLOAD) gRank5OrderFailures++;
        rank5_note_tail_check(&gRank5PostFinalQueryChecks);
        gRank5Phase = RANK5_PHASE_POST_FINAL_QUERY;
        return 1;
    }
    return 1;
}

static void arm_rank5_state_split_audit(void) {
    static const uint32_t exec_addresses[] = {
        A_UPDATE_OBJECTS,
        A_APPLY_MARIO_PLATFORM_DISPLACEMENT,
        A_APPLY_PLATFORM_DISPLACEMENT_CALLSITE,
        A_POST_APPLY_MARIO_PLATFORM,
        A_DETECT_OBJECT_COLLISIONS,
        A_POST_DETECT_OBJECT_COLLISIONS,
        A_POST_COPY_MARIO_STATE_TO_OBJECT,
        A_BHV_MARIO_RETURN,
        A_POST_NON_TERRAIN_OBJECTS,
        A_POST_UNLOAD_DEACTIVATED_OBJECTS,
        A_POST_MARIO_PLATFORM,
    };
    unsigned i;
    int armed = 1;

    if (gRank5BreakpointsArmed) return;
    for (i = 0; i < sizeof(exec_addresses) / sizeof(exec_addresses[0]); i++) {
        if (!add_exec_breakpoint(exec_addresses[i])) armed = 0;
    }
    if (!add_rank1_write_breakpoints(A_MARIO_STATES + M_POS_X, 12)
        || !add_rank1_write_breakpoints(A_SLOT67 + O_POS_X, 12)
        || !add_rank1_write_breakpoints(A_SLOT67 + GFX_POS_X, 12)
        || !add_rank1_write_breakpoints(A_MARIO_PLATFORM, 4)
        || !add_rank1_write_breakpoints(A_SLOT67_PLATFORM, 4)
        || !add_rank1_write_breakpoints(A_MARIO_OBJECT, 4)
        || !add_rank1_write_breakpoints(A_STATE_MARIO_OBJECT, 4)
        || !add_rank1_write_breakpoints(A_SLOT67_NEXT, 8)
        || !add_rank1_write_breakpoints(A_SLOT67_ACTIVE_FLAGS, 2)
        || !add_rank1_write_breakpoints(A_SLOT67_BEHAVIOR, 4)
        || !add_rank1_write_breakpoints(A_LIST0_SENTINEL_NEXT, 8)
        || !add_rank1_write_breakpoints(A_BHV_MARIO,
                                        BHV_MARIO_WORDS * 4)
        || !add_rank1_write_breakpoints(A_BEHAVIOR_CMD_TABLE,
                                        BEHAVIOR_CMD_TABLE_WORDS * 4)) {
        armed = 0;
    }
    if (!armed) {
        fprintf(stderr, "RANK5_STATE_SPLIT_ERROR,kind=breakpoint-arm\n");
        return;
    }
    gRank5BreakpointsArmed = 1;
    gRank5Initialized = 1;
    fprintf(stderr,
            "RANK5_STATE_SPLIT_ARM,timer=%u,mario=%08x,slot=%d,"
            "platform=%08x,timeStop=%08x,apply=%08x,copyReturn=%08x,"
            "readOnly=1\n",
            R32(A_GLOBAL_TIMER), R32(A_MARIO_OBJECT),
            pool_index(R32(A_MARIO_OBJECT)), R32(A_MARIO_PLATFORM),
            R32(A_TIME_STOP_STATE), A_APPLY_MARIO_PLATFORM_DISPLACEMENT,
            A_POST_COPY_MARIO_STATE_TO_OBJECT);
}

static void rank5_print_result(void) {
    unsigned i;
    int invariant = gRank5Initialized && gRank5BreakpointsArmed
        && gRank5Complete
        && gRank5FramesStarted == 2462
        && gRank5FramesFinished == gRank5FramesStarted
        && gRank5OrderFailures == 0
        && gRank5IdentityFailures == 0
        && gRank5IdentityWrites == 0
        && gRank5CodeWrites == 0
        && gRank5EntryStateObjectMismatches == 0
        && gRank5ApplyEntryStateObjectMismatches == 0
        && gRank5PostApplyStateObjectMismatches == 0
        && gRank5CollisionStateObjectMismatches == 0
        && gRank5ApplyEntries == gRank5FramesStarted
        && gRank5ApplyReturns == gRank5FramesStarted
        && gRank5CollisionEntries == gRank5FramesStarted
        && gRank5CollisionReturns == gRank5FramesStarted
        && gRank5CopyReturns == gRank5FramesStarted
        && gRank5BhvMarioReturns == gRank5FramesStarted
        && gRank5PostNonTerrainChecks == gRank5FramesStarted
        && gRank5PostUnloadChecks == gRank5FramesStarted
        && gRank5PostFinalQueryChecks == gRank5FramesStarted
        && gRank5ApplyHelperCalls == 0
        && gRank5NonnullApplyEntries == 0
        && gRank5InvalidApplyOwners == 0
        && gRank5ApplyStateChanges == 0
        && gRank5ApplyObjectChanges == 0
        && gRank5ApplyGraphicsChanges == 0
        && gRank5ApplyStateWrites == 0
        && gRank5ApplyObjectWrites == 0
        && gRank5ApplyGraphicsWrites == 0
        && gRank5PostApplyStateWrites == 0
        && gRank5PostApplyObjectWrites == 0
        && gRank5PostApplyGraphicsWrites == 0
        && gRank5UpperWarpApplyEntries > 0
        && gRank5UpperWarpNonnullApplyEntries == 0
        && gRank5UpperWarpApplyStateChanges == 0
        && gRank5PrecollisionObjectChanges == 0
        && gRank5CopyReceiverFailures == 0
        && gRank5CopyStateObjectMismatches == 0
        && gRank5PreapplyStateWrites == 0
        && gRank5PreapplyObjectWrites == 0
        && gRank5PostCopyStateWrites == 0
        && gRank5PostCopyObjectWrites == 0
        && gRank5PostCopyTailMismatches == 0
        && gRank5GlobalPlatformWrites == gRank5FramesStarted
        && gRank5ObjectPlatformWrites == gRank5FramesStarted
        && gRank5NonnullPlatformWrites == 0
        && gRank5UnexpectedPlatformWrites == 0
        && gRank5WriteDecodeFailures == 0;

    for (i = 0; i < gRank5PlatformWriterKinds; i++) {
        fprintf(stderr, "RANK5_PLATFORM_WRITER,pc=%08x,count=%u\n",
                gRank5PlatformWriters[i].pc,
                gRank5PlatformWriters[i].count);
    }
    for (i = 0; i < gRank5PostCopyStateWriterKinds; i++) {
        fprintf(stderr,
                "RANK5_POSTCOPY_STATE_WRITER,pc=%08x,count=%u\n",
                gRank5PostCopyStateWriters[i].pc,
                gRank5PostCopyStateWriters[i].count);
    }
    for (i = 0; i < gRank5PostCopyObjectWriterKinds; i++) {
        fprintf(stderr,
                "RANK5_POSTCOPY_OBJECT_WRITER,pc=%08x,count=%u\n",
                gRank5PostCopyObjectWriters[i].pc,
                gRank5PostCopyObjectWriters[i].count);
    }
    for (i = 0; i < gRank5IdentityWriterKinds; i++) {
        fprintf(stderr, "RANK5_IDENTITY_WRITER,pc=%08x,count=%u\n",
                gRank5IdentityWriters[i].pc,
                gRank5IdentityWriters[i].count);
    }
    fprintf(stderr,
            "RANK5_STATE_SPLIT_RESULT,firstTimer=348,"
            "exclusiveEndTimer=2810,framesStarted=%u,framesFinished=%u,"
            "orderFailures=%u,identityFailures=%u,identityWrites=%u,"
            "codeWrites=%u,entryMismatches=%u,applyEntryMismatches=%u,"
            "postApplyMismatches=%u,collisionMismatches=%u,"
            "applyEntries=%u,applyReturns=%u,helperCalls=%u,"
            "nonnullApplyEntries=%u,invalidApplyOwners=%u,"
            "applyChanges=%u:%u:%u,applyWrites=%u:%u:%u,"
            "postApplyWrites=%u:%u:%u,"
            "upperWarpApplyEntries=%u,upperWarpNonnull=%u,"
            "upperWarpStateChanges=%u,collisionEntries=%u,"
            "collisionReturns=%u,precollisionObjectChanges=%u,"
            "copyReturns=%u,copyReceiverFailures=%u,"
            "copyMismatches=%u,bhvMarioReturns=%u,"
            "preapplyWrites=%u:%u,postcopyWrites=%u:%u,"
            "postcopyTailMismatches=%u,tailChecks=%u:%u:%u,"
            "platformWrites=%u:%u,nonnullPlatformWrites=%u,"
            "unexpectedPlatformWrites=%u,writeDecodeFailures=%u,"
            "firstApplyChange=%u:%08x,"
            "invariant=%d\n",
            gRank5FramesStarted, gRank5FramesFinished,
            gRank5OrderFailures, gRank5IdentityFailures,
            gRank5IdentityWrites, gRank5CodeWrites,
            gRank5EntryStateObjectMismatches,
            gRank5ApplyEntryStateObjectMismatches,
            gRank5PostApplyStateObjectMismatches,
            gRank5CollisionStateObjectMismatches,
            gRank5ApplyEntries, gRank5ApplyReturns,
            gRank5ApplyHelperCalls, gRank5NonnullApplyEntries,
            gRank5InvalidApplyOwners, gRank5ApplyStateChanges,
            gRank5ApplyObjectChanges, gRank5ApplyGraphicsChanges,
            gRank5ApplyStateWrites, gRank5ApplyObjectWrites,
            gRank5ApplyGraphicsWrites, gRank5PostApplyStateWrites,
            gRank5PostApplyObjectWrites, gRank5PostApplyGraphicsWrites,
            gRank5UpperWarpApplyEntries,
            gRank5UpperWarpNonnullApplyEntries,
            gRank5UpperWarpApplyStateChanges, gRank5CollisionEntries,
            gRank5CollisionReturns, gRank5PrecollisionObjectChanges,
            gRank5CopyReturns, gRank5CopyReceiverFailures,
            gRank5CopyStateObjectMismatches, gRank5BhvMarioReturns,
            gRank5PreapplyStateWrites, gRank5PreapplyObjectWrites,
            gRank5PostCopyStateWrites, gRank5PostCopyObjectWrites,
            gRank5PostCopyTailMismatches, gRank5PostNonTerrainChecks,
            gRank5PostUnloadChecks, gRank5PostFinalQueryChecks,
            gRank5GlobalPlatformWrites, gRank5ObjectPlatformWrites,
            gRank5NonnullPlatformWrites,
            gRank5UnexpectedPlatformWrites,
            gRank5WriteDecodeFailures,
            gRank5FirstApplyStateChangeTimer,
            gRank5FirstApplyStateChangePlatform, invariant);
}
#endif

#if RANK13_18_COPY_AUDIT
#include "../jp-ranks13-18/jp_ranks13_18_probe.h"
#endif

static int rank1_surface_index(uint32_t surface) {
    uint32_t offset;
    if (surface < gRank1SurfaceBase) return -1;
    offset = surface - gRank1SurfaceBase;
    if (offset % SURFACE_SIZE != 0
        || offset / SURFACE_SIZE >= SURFACE_CAPACITY) return -1;
    return (int) (offset / SURFACE_SIZE);
}

static int rank1_node_index(uint32_t node) {
    uint32_t offset;
    if (node < gRank1NodeBase) return -1;
    offset = node - gRank1NodeBase;
    if (offset % SURFACE_NODE_SIZE != 0
        || offset / SURFACE_NODE_SIZE >= SURFACE_NODE_CAPACITY) return -1;
    return (int) (offset / SURFACE_NODE_SIZE);
}

static int rank1_scan_partition(uint32_t base, int dynamic,
                                uint32_t final_nodes,
                                uint32_t final_surfaces,
                                int *coverage) {
    unsigned cell;
    int intact = 1;
    uint32_t first_node = dynamic ? gRank1StaticNodes : 0;
    uint32_t last_node = dynamic ? final_nodes : gRank1StaticNodes;
    uint32_t first_surface = dynamic ? gRank1StaticSurfaces : 0;
    uint32_t last_surface = dynamic ? final_surfaces : gRank1StaticSurfaces;

    memset(gRank1SeenNodes, 0, sizeof(gRank1SeenNodes));
    if (dynamic) {
        unsigned i;
        for (i = 0; i < SURFACE_CAPACITY; i++) {
            gRank1SurfaceReceipts[i].node_references = 0;
        }
    }
    for (cell = 0; cell < 16u * 16u; cell++) {
        unsigned list_index;
        for (list_index = 0; list_index < 3; list_index++) {
            uint32_t node = R32(base + (cell * 3u + list_index) * 8u);
            int have_priority = 0;
            int previous_priority = 0;
            unsigned steps = 0;

            while (node != 0) {
                int node_index = rank1_node_index(node);
                uint32_t surface;
                int surface_index;
                int priority;
                uint32_t next;

                if (node_index < 0 || (uint32_t) node_index < first_node
                    || (uint32_t) node_index >= last_node
                    || steps++ >= SURFACE_NODE_CAPACITY) {
                    intact = 0;
                    break;
                }
                if (gRank1SeenNodes[node_index] != 0) {
                    intact = 0;
                    break;
                }
                gRank1SeenNodes[node_index] = 1;
                surface = R32(node + 4);
                surface_index = rank1_surface_index(surface);
                if (surface_index < 0
                    || (uint32_t) surface_index < first_surface
                    || (uint32_t) surface_index >= last_surface) {
                    intact = 0;
                    break;
                }
                priority = (int16_t) R16(surface + 0x0c);
                if (list_index == 1) priority = -priority;
                else if (list_index == 2) priority = 0;
                if (have_priority && priority > previous_priority) intact = 0;
                previous_priority = priority;
                have_priority = 1;
                if (dynamic) {
                    struct rank1_surface_receipt *receipt =
                        &gRank1SurfaceReceipts[surface_index];
                    if (!receipt->owner_seen || !receipt->inserted
                        || receipt->owner == 0
                        || R32(surface + SURFACE_OBJECT) != receipt->owner) {
                        intact = 0;
                    }
                    receipt->node_references++;
                } else if (R32(surface + SURFACE_OBJECT) != 0) {
                    intact = 0;
                }
                next = R32(node);
                if (next != 0 && rank1_node_index(next) < 0) {
                    intact = 0;
                    break;
                }
                node = next;
            }
        }
    }
    *coverage = 1;
    if (last_node > SURFACE_NODE_CAPACITY || first_node > last_node) {
        *coverage = 0;
    } else {
        uint32_t i;
        for (i = first_node; i < last_node; i++) {
            if (gRank1SeenNodes[i] != 1) *coverage = 0;
        }
    }
    return intact;
}

static float rank1_float_from_bits(uint32_t bits) {
    union { uint32_t u; float f; } value;
    value.u = bits;
    return value.f;
}

static int rank1_floor_membership(uint32_t partition, uint32_t selected,
                                  uint32_t x_bits, uint32_t z_bits) {
    int16_t x = (int16_t) (int32_t)
        rank1_float_from_bits(x_bits);
    int16_t z = (int16_t) (int32_t)
        rank1_float_from_bits(z_bits);
    int cell_x;
    int cell_z;
    uint32_t node;
    unsigned steps = 0;
    int matches = 0;

    if (selected == 0 || x <= -8192 || x >= 8192
        || z <= -8192 || z >= 8192) return 0;
    cell_x = ((x + 8192) / 1024) & 15;
    cell_z = ((z + 8192) / 1024) & 15;
    node = R32(partition + ((cell_z * 16 + cell_x) * 3) * 8);
    while (node != 0 && steps++ < SURFACE_NODE_CAPACITY) {
        if (rank1_node_index(node) < 0) return 0;
        if (R32(node + 4) == selected) matches++;
        node = R32(node);
    }
    return node == 0 ? matches : 0;
}

static int rank1_selected_floor_membership(uint32_t partition,
                                           uint32_t selected) {
    return rank1_floor_membership(partition, selected,
                                  gRank1PlatformQueryXBits,
                                  gRank1PlatformQueryZBits);
}

static int rank1_safe_surface_record_store(uint32_t target,
                                           unsigned width) {
    uint32_t offset = target - gRank1SurfaceBase;
    uint32_t field_offset = offset % SURFACE_SIZE;
    uint32_t index = offset / SURFACE_SIZE;
    return index >= gRank1StaticSurfaces && index < SURFACE_CAPACITY
        && field_offset + width <= SURFACE_SIZE
        && (width == 1 || width == 2 || width == 4);
}

static void rank1_note_pool_write(uint32_t pc, uint32_t instruction,
                                  uint32_t target, uint32_t source,
                                  unsigned width) {
    int safe = 0;

    gRank1PoolWrites++;
    rank1_count_writer(gRank1PoolWriterCounts, &gRank1PoolWriterKinds,
                       64, pc);
    if (rank1_in_range(target, width, gRank1NodeBase,
                       gRank1NodeBase + SURFACE_NODE_BYTES)) {
        uint32_t offset = target - gRank1NodeBase;
        int node_index = rank1_node_index(target - offset % 8);
        gRank1NodeWrites++;
        safe = pc >= A_SURFACE_LOAD_TEXT_START
            && pc < A_SURFACE_LOAD_TEXT_END && width == 4
            && (offset % 8 == 0 || offset % 8 == 4)
            && node_index >= 0
            && (uint32_t) node_index >= gRank1StaticNodes;
        if (safe && offset % 8 == 4) {
            int surface_index = rank1_surface_index(source);
            safe = surface_index >= 0
                && (uint32_t) surface_index >= gRank1StaticSurfaces;
        } else if (safe && source != 0) {
            int next_index = rank1_node_index(source);
            safe = next_index >= 0
                && (uint32_t) next_index >= gRank1StaticNodes;
        }
    } else if (rank1_in_range(target, width, gRank1SurfaceBase,
                              gRank1SurfaceEnd)) {
        int surface_index = rank1_surface_index(
            target - (target - gRank1SurfaceBase) % SURFACE_SIZE);
        gRank1SurfaceWrites++;
        safe = pc >= A_SURFACE_LOAD_TEXT_START
            && pc < A_SURFACE_LOAD_TEXT_END
            && rank1_safe_surface_record_store(target, width);
        if (safe && pc == 0x80383904 && width == 4
            && (target - gRank1SurfaceBase) % SURFACE_SIZE
                == SURFACE_OBJECT) {
            int rings_intact;
            int list_index = rank1_object_list_index(source, &rings_intact);
            struct rank1_surface_receipt *receipt =
                &gRank1SurfaceReceipts[surface_index];
            gRank1OwnerStores++;
            receipt->owner = source;
            receipt->behavior = pool_index(source) < 0
                ? 0 : R32(source + O_BEHAVIOR);
            receipt->list_index = (int16_t) list_index;
            receipt->owner_seen = 1;
            receipt->owner_active_at_store = pool_index(source) >= 0
                && R16(source + O_ACTIVE_FLAGS) != 0;
            if (source != R32(A_CURRENT_OBJECT) || pool_index(source) < 0
                || list_index < 0 || !rings_intact) {
                safe = 0;
                gRank1OwnerFailures++;
            }
            if (!receipt->owner_active_at_store) {
                gRank1InactiveOwnerStores++;
            }
        }
    }
    if (safe) gRank1SafePoolWrites++;
    else gRank1UnsafePoolWrites++;
    rank1_hash_word(pc);
    rank1_hash_word(instruction);
    rank1_hash_word(target);
    rank1_hash_word(source);
    rank1_hash_word(safe);
}

static void rank1_note_partition_write(uint32_t pc, uint32_t instruction,
                                       uint32_t target, uint32_t source,
                                       unsigned width, int dynamic) {
    int safe = 0;
    uint32_t base = dynamic ? A_DYNAMIC_SURFACE_PARTITION
                            : A_STATIC_SURFACE_PARTITION;

    rank1_count_writer(gRank1PartitionWriterCounts,
                       &gRank1PartitionWriterKinds, 32, pc);
    if (dynamic) {
        int next_index = source == 0 ? (int) gRank1StaticNodes
                                     : rank1_node_index(source);
        gRank1DynamicPartitionWrites++;
        safe = pc >= A_SURFACE_LOAD_TEXT_START
            && pc < A_SURFACE_LOAD_TEXT_END && width == 4
            && (target - base) % 8 == 0
            && (source == 0 || (next_index >= 0
                && (uint32_t) next_index >= gRank1StaticNodes));
    } else {
        gRank1StaticPartitionWrites++;
    }
    if (!safe) gRank1UnsafePoolWrites++;
    rank1_hash_word(pc);
    rank1_hash_word(instruction);
    rank1_hash_word(target);
    rank1_hash_word(source);
    rank1_hash_word(safe);
}

static void rank1_note_allocator_global_write(uint32_t pc,
                                              uint32_t instruction,
                                              uint32_t target,
                                              uint32_t source,
                                              unsigned width) {
    int safe = width == 4;
    gRank1AllocatorGlobalWrites++;
    if (target == A_MAIN_POOL_LEFT_HEAD) {
        safe = safe && source >= gRank1SurfaceEnd
            && source <= R32(A_MAIN_POOL_RIGHT_HEAD);
        if (source < gRank1MinLeftHead) gRank1MinLeftHead = source;
    } else if (target == A_MAIN_POOL_RIGHT_HEAD) {
        safe = safe && source >= R32(A_MAIN_POOL_LEFT_HEAD)
            && source <= R32(A_MAIN_POOL_END);
        if (source < gRank1MinRightHead) gRank1MinRightHead = source;
    } else if (target != A_MAIN_POOL_FREE_SPACE) {
        safe = 0;
    }
    if (!safe) gRank1UnsafePoolWrites++;
    fprintf(stderr,
            "RANK1_ALLOCATOR_WRITE,ordinal=%u,timer=%u,pc=%08x,"
            "instruction=%08x,target=%08x,value=%08x,safe=%d\n",
            gRank1AllocatorGlobalWrites, R32(A_GLOBAL_TIMER), pc,
            instruction, target, source, safe);
}

static int rank1_handle_write(uint32_t pc, uint64_t *registers,
                              uint32_t accessed) {
    uint32_t instruction = R32(pc);
    unsigned width = 0;
    uint32_t raw_target = 0;
    int decoded = rank1_decode_store_range(instruction, registers,
                                           &raw_target, &width);
    uint32_t target = rank1_kseg0_address(raw_target);
    uint32_t source = rank1_source_value(instruction, registers);
    uint32_t physical = target & 0x1fffffffu;
    int watched = 0;

#if RANK13_18_COPY_AUDIT
    if (!decoded) {
        if (rank13_note_undecoded_write(accessed)) watched = 1;
    } else if (rank13_note_write(pc, target, width)) {
        watched = 1;
    }
#endif
#if RANK5_STATE_SPLIT_AUDIT
    if (!decoded) {
        if (rank5_note_undecoded_write(accessed)) watched = 1;
    } else {
        uint32_t accessed_word = 0x80000000u
            | ((accessed & 0x1fffffffu) & ~3u);
        if (gRank5Initialized && !gRank5Complete
            && gRank5Phase != RANK5_PHASE_INACTIVE
            && rank5_watches_range(target, width)
            && !rank1_overlaps_range(target, width, accessed_word,
                                     accessed_word + 4)) {
            gRank5WriteDecodeFailures++;
        }
        if (rank5_note_write(pc, target, source, width,
                             rank1_store_u32_value_known(instruction,
                                                         width))) {
            watched = 1;
        }
    }
#else
    (void) accessed;
    (void) decoded;
#endif
#if RANK4_WARP_TOP_AUDIT
    if (rank4_note_write(pc, target, source, width)) watched = 1;
#endif
    if (rank1_overlaps_range(target, width, gRank1NodeBase,
                             gRank1NodeBase + SURFACE_NODE_BYTES)
        || rank1_overlaps_range(target, width, gRank1SurfaceBase,
                                gRank1SurfaceEnd)) {
        watched = 1;
        if (gRank1AuditState == 2) {
            rank1_note_pool_write(pc, instruction, target, source, width);
        }
    } else if (rank1_overlaps_range(target, width,
                                    A_DYNAMIC_SURFACE_PARTITION,
                                    A_DYNAMIC_SURFACE_PARTITION
                                        + SURFACE_PARTITION_BYTES)) {
        watched = 1;
        if (gRank1AuditState == 2) {
            rank1_note_partition_write(pc, instruction, target, source,
                                       width, 1);
        }
    } else if (rank1_overlaps_range(target, width,
                                    A_STATIC_SURFACE_PARTITION,
                                    A_STATIC_SURFACE_PARTITION
                                        + SURFACE_PARTITION_BYTES)) {
        watched = 1;
        if (gRank1AuditState == 2) {
            rank1_note_partition_write(pc, instruction, target, source,
                                       width, 0);
        }
    } else if (physical >= (A_MAIN_POOL_FREE_SPACE & 0x1fffffffu)
               && physical <= (A_MAIN_POOL_RIGHT_HEAD & 0x1fffffffu)) {
        watched = 1;
        if (gRank1AuditState == 2) {
            rank1_note_allocator_global_write(pc, instruction, target,
                                              source, width);
        }
    } else if (physical >= (A_SURFACE_NODE_POOL_CELL & 0x1fffffffu)
               && physical < ((A_SURFACE_POOL_CELL + 4) & 0x1fffffffu)) {
        watched = 1;
        if (gRank1AuditState == 2) {
            gRank1SurfacePointerWrites++;
            gRank1UnsafePoolWrites++;
        }
    }
    return watched;
}

static void rank1_start_audit(void) {
    memset(gRank1SurfaceReceipts, 0, sizeof(gRank1SurfaceReceipts));
    memset(gRank1PoolWriterCounts, 0, sizeof(gRank1PoolWriterCounts));
    memset(gRank1PartitionWriterCounts, 0,
           sizeof(gRank1PartitionWriterCounts));
    memset(gRank1AllocatorCalls, 0, sizeof(gRank1AllocatorCalls));
    memset(gRank1OutsideCalls, 0, sizeof(gRank1OutsideCalls));
    gRank1PoolWriterKinds = 0;
    gRank1PartitionWriterKinds = 0;
    gRank1PoolWrites = 0;
    gRank1SafePoolWrites = 0;
    gRank1UnsafePoolWrites = 0;
    gRank1NodeWrites = 0;
    gRank1SurfaceWrites = 0;
    gRank1DynamicPartitionWrites = 0;
    gRank1StaticPartitionWrites = 0;
    gRank1AllocatorGlobalWrites = 0;
    gRank1SurfacePointerWrites = 0;
    gRank1ClearDynamicCalls = 0;
    gRank1CollisionModelCalls = 0;
    gRank1LoadObjectSurfacesCalls = 0;
    gRank1OwnerStores = 0;
    gRank1AddSurfaceCalls = 0;
    gRank1InactiveCollisionModelCalls = 0;
    gRank1InactiveOwnerStores = 0;
    gRank1OwnerFailures = 0;
    gRank1ListFailures = 0;
    gRank1FindFloorCalls = 0;
    gRank1FindFloorReturns = 0;
    gRank1FindFloorBeforeClear = 0;
    gRank1FindFloorReturnFailures = 0;
    gRank1DynamicFindFloorReturns = 0;
    gRank1PlatformFindFloorCalls = 0;
    gRank1PostPlatformCalls = 0;
    gRank1OutsideDestinationStores = 0;
    gRank1OutsideDestinationFailures = 0;
    gRank1EventHash = 2166136261u;
    gRank1SelectedFloor = 0;
    gRank1SelectedPlatform = 0;
    gRank1SelectedOwner = 0;
    gRank1EndInvalidSurfaces = 0;
    gRank1PendingCleanupSurfaces = 0;
    gRank1StartTimer = R32(A_GLOBAL_TIMER);
    gRank1NodeBase = R32(A_SURFACE_NODE_POOL_CELL);
    gRank1SurfaceBase = R32(A_SURFACE_POOL_CELL);
    gRank1SurfaceEnd = gRank1SurfaceBase + SURFACE_BYTES;
    gRank1StaticNodes = R32(A_NUM_STATIC_SURFACE_NODES);
    gRank1StaticSurfaces = R32(A_NUM_STATIC_SURFACES);
    gRank1StartFreeSpace = R32(A_MAIN_POOL_FREE_SPACE);
    gRank1StartLeftHead = R32(A_MAIN_POOL_LEFT_HEAD);
    gRank1StartRightHead = R32(A_MAIN_POOL_RIGHT_HEAD);
    gRank1MinLeftHead = gRank1StartLeftHead;
    gRank1MinRightHead = gRank1StartRightHead;
    gRank1AuditState = 2;
    fprintf(stderr,
            "RANK1_BOUNDARY_START,timer=%u,nodeBase=%08x,surfaceBase=%08x,"
            "surfaceEnd=%08x,staticNodes=%u,staticSurfaces=%u,"
            "mainPoolFree=%u,leftHead=%08x,rightHead=%08x,"
            "rangeSeparated=%d\n",
            gRank1StartTimer, gRank1NodeBase, gRank1SurfaceBase,
            gRank1SurfaceEnd, gRank1StaticNodes, gRank1StaticSurfaces,
            gRank1StartFreeSpace, gRank1StartLeftHead,
            gRank1StartRightHead,
            gRank1NodeBase + SURFACE_NODE_BYTES + 16 == gRank1SurfaceBase
                && gRank1SurfaceEnd <= gRank1StartLeftHead);
}

static void rank1_finish_audit(void) {
    uint32_t final_nodes = R32(A_SURFACE_NODES_ALLOCATED);
    uint32_t final_surfaces = R32(A_SURFACES_ALLOCATED);
    unsigned i;
    int rings_intact;
    int dummy_list;
    int invariant;

    gRank1EndTimer = R32(A_GLOBAL_TIMER);
    gRank1StaticListsIntact = rank1_scan_partition(
        A_STATIC_SURFACE_PARTITION, 0, final_nodes, final_surfaces,
        &gRank1StaticNodeCoverage);
    gRank1DynamicListsIntact = rank1_scan_partition(
        A_DYNAMIC_SURFACE_PARTITION, 1, final_nodes, final_surfaces,
        &gRank1DynamicNodeCoverage);
    dummy_list = rank1_object_list_index(0, &rings_intact);
    (void) dummy_list;
    gRank1ObjectListsIntact = rings_intact;
    gRank1OwnerEndValidity = 1;
    for (i = gRank1StaticSurfaces;
         i < final_surfaces && i < SURFACE_CAPACITY; i++) {
        struct rank1_surface_receipt *receipt = &gRank1SurfaceReceipts[i];
        if (receipt->owner_seen) {
            int end_rings;
            int end_list = rank1_object_list_index(receipt->owner,
                                                   &end_rings);
            uint32_t surface = gRank1SurfaceBase + i * SURFACE_SIZE;
            if (!receipt->inserted || receipt->node_references == 0
                || pool_index(receipt->owner) < 0 || !end_rings
                || end_list != receipt->list_index
                || R16(receipt->owner + O_ACTIVE_FLAGS) == 0
                || R32(receipt->owner + O_BEHAVIOR) != receipt->behavior
                || R32(surface + SURFACE_OBJECT) != receipt->owner) {
                gRank1OwnerEndValidity = 0;
                gRank1EndInvalidSurfaces++;
                /* Dynamic partitions are cleared before the first query of
                 * the next update.  An owner that dies after installation is
                 * therefore harmless at this boundary exactly when every
                 * query which actually returned its surface observed a live,
                 * correctly linked owner at return time. */
                if (receipt->inserted && receipt->node_references != 0
                    && receipt->unsafe_query_returns == 0) {
                    gRank1PendingCleanupSurfaces++;
                }
            }
        }
    }
    gRank1OwnerEndSafety =
        gRank1EndInvalidSurfaces == gRank1PendingCleanupSurfaces;
    gRank1SelectedStaticMembership = rank1_selected_floor_membership(
        A_STATIC_SURFACE_PARTITION, gRank1SelectedFloor);
    gRank1SelectedDynamicMembership = rank1_selected_floor_membership(
        A_DYNAMIC_SURFACE_PARTITION, gRank1SelectedFloor);
    if (gRank1SelectedFloor != 0
        && rank1_surface_index(gRank1SelectedFloor) >= 0) {
        for (i = 0; i < 12; i++) {
            gRank1SelectedWords[i] = R32(gRank1SelectedFloor + i * 4);
        }
        gRank1SelectedOwner = R32(gRank1SelectedFloor + SURFACE_OBJECT);
    }
    for (i = 0; i < gRank1PoolWriterKinds; i++) {
        fprintf(stderr, "RANK1_POOL_WRITER,pc=%08x,count=%u\n",
                gRank1PoolWriterCounts[i].pc,
                gRank1PoolWriterCounts[i].count);
    }
    for (i = 0; i < gRank1PartitionWriterKinds; i++) {
        fprintf(stderr, "RANK1_PARTITION_WRITER,pc=%08x,count=%u\n",
                gRank1PartitionWriterCounts[i].pc,
                gRank1PartitionWriterCounts[i].count);
    }
    fprintf(stderr,
            "RANK1_SELECTED_FLOOR,queryBits=(%08x,%08x,%08x),"
            "surface=%08x,platform=%08x,owner=%08x,staticMembership=%d,"
            "dynamicMembership=%d,words=%08x:%08x:%08x:%08x:%08x:%08x:"
            "%08x:%08x:%08x:%08x:%08x:%08x\n",
            gRank1PlatformQueryXBits, gRank1PlatformQueryYBits,
            gRank1PlatformQueryZBits, gRank1SelectedFloor,
            gRank1SelectedPlatform, gRank1SelectedOwner,
            gRank1SelectedStaticMembership,
            gRank1SelectedDynamicMembership,
            gRank1SelectedWords[0], gRank1SelectedWords[1],
            gRank1SelectedWords[2], gRank1SelectedWords[3],
            gRank1SelectedWords[4], gRank1SelectedWords[5],
            gRank1SelectedWords[6], gRank1SelectedWords[7],
            gRank1SelectedWords[8], gRank1SelectedWords[9],
            gRank1SelectedWords[10], gRank1SelectedWords[11]);
    fprintf(stderr,
            "RANK1_OUTSIDE_CALLS,sqrtf=%u,cameraShake=%u,"
            "createSoundSpawner=%u,curObjPlaySound2=%u,playSound=%u,"
            "puzzleJingle=%u,stopSoundsSource=%u,stopSoundsContinuous=%u,"
            "destinationStores=%u,destinationFailures=%u\n",
            gRank1OutsideCalls[0], gRank1OutsideCalls[1],
            gRank1OutsideCalls[2], gRank1OutsideCalls[3],
            gRank1OutsideCalls[4], gRank1OutsideCalls[5],
            gRank1OutsideCalls[6], gRank1OutsideCalls[7],
            gRank1OutsideDestinationStores,
            gRank1OutsideDestinationFailures);
    invariant = gRank1EndTimer == gRank1StartTimer + 1
        && gRank1NodeBase == R32(A_SURFACE_NODE_POOL_CELL)
        && gRank1SurfaceBase == R32(A_SURFACE_POOL_CELL)
        && R32(A_MAIN_POOL_LEFT_HEAD) >= gRank1SurfaceEnd
        && R32(A_MAIN_POOL_LEFT_HEAD) <= R32(A_MAIN_POOL_RIGHT_HEAD)
        && R32(A_MAIN_POOL_START) <= gRank1NodeBase
        && gRank1UnsafePoolWrites == 0
        && gRank1SurfacePointerWrites == 0
        && gRank1StaticPartitionWrites == 0
        && gRank1ClearDynamicCalls == 1
        && gRank1OwnerStores == gRank1AddSurfaceCalls
        && gRank1OwnerFailures == 0 && gRank1ListFailures == 0
        && gRank1ObjectListsIntact && gRank1StaticListsIntact
        && gRank1DynamicListsIntact && gRank1StaticNodeCoverage
        && gRank1DynamicNodeCoverage && gRank1OwnerEndSafety
        && gRank1FindFloorReturns == gRank1FindFloorCalls
        && gRank1FindFloorBeforeClear == 0
        && gRank1FindFloorReturnFailures == 0
        && gRank1PlatformFindFloorCalls == 1
        && gRank1PostPlatformCalls == 1
        && gRank1SelectedFloor != 0
        && gRank1SelectedStaticMembership
            + gRank1SelectedDynamicMembership == 1
        && gRank1SelectedPlatform == gRank1SelectedOwner
        && gRank1OutsideDestinationFailures == 0;
    fprintf(stderr,
            "RANK1_BOUNDARY_END,startTimer=%u,endTimer=%u,"
            "poolWrites=%u,safePoolWrites=%u,unsafePoolWrites=%u,"
            "nodeWrites=%u,surfaceWrites=%u,dynamicPartitionWrites=%u,"
            "staticPartitionWrites=%u,allocatorGlobalWrites=%u,"
            "surfacePointerWrites=%u,allocatorCalls=%u:%u:%u:%u:%u:%u,"
            "startHeads=%08x:%08x,minHeads=%08x:%08x,"
            "endHeads=%08x:%08x,endFree=%u,"
            "clearDynamicCalls=%u,collisionModelCalls=%u,"
            "loadObjectSurfacesCalls=%u,ownerStores=%u,addSurfaceCalls=%u,"
            "inactiveCollisionModelCalls=%u,inactiveOwnerStores=%u,"
            "ownerFailures=%u,listFailures=%u,findFloorCalls=%u,"
            "findFloorReturns=%u,findFloorBeforeClear=%u,"
            "findFloorReturnFailures=%u,dynamicFindFloorReturns=%u,"
            "platformFindFloorCalls=%u,postPlatformCalls=%u,"
            "finalNodes=%u,finalSurfaces=%u,objectListsIntact=%d,"
            "staticListsIntact=%d,dynamicListsIntact=%d,"
            "staticNodeCoverage=%d,dynamicNodeCoverage=%d,"
            "ownerEndValidity=%d,endInvalidSurfaces=%u,"
            "pendingCleanupSurfaces=%u,ownerEndSafety=%d,"
            "eventHash=%08x,invariant=%d\n",
            gRank1StartTimer, gRank1EndTimer, gRank1PoolWrites,
            gRank1SafePoolWrites, gRank1UnsafePoolWrites,
            gRank1NodeWrites, gRank1SurfaceWrites,
            gRank1DynamicPartitionWrites, gRank1StaticPartitionWrites,
            gRank1AllocatorGlobalWrites, gRank1SurfacePointerWrites,
            gRank1AllocatorCalls[0], gRank1AllocatorCalls[1],
            gRank1AllocatorCalls[2], gRank1AllocatorCalls[3],
            gRank1AllocatorCalls[4], gRank1AllocatorCalls[5],
            gRank1StartLeftHead, gRank1StartRightHead,
            gRank1MinLeftHead, gRank1MinRightHead,
            R32(A_MAIN_POOL_LEFT_HEAD), R32(A_MAIN_POOL_RIGHT_HEAD),
            R32(A_MAIN_POOL_FREE_SPACE),
            gRank1ClearDynamicCalls, gRank1CollisionModelCalls,
            gRank1LoadObjectSurfacesCalls, gRank1OwnerStores,
            gRank1AddSurfaceCalls, gRank1InactiveCollisionModelCalls,
            gRank1InactiveOwnerStores, gRank1OwnerFailures,
            gRank1ListFailures, gRank1FindFloorCalls,
            gRank1FindFloorReturns, gRank1FindFloorBeforeClear,
            gRank1FindFloorReturnFailures,
            gRank1DynamicFindFloorReturns,
            gRank1PlatformFindFloorCalls, gRank1PostPlatformCalls,
            final_nodes, final_surfaces, gRank1ObjectListsIntact,
            gRank1StaticListsIntact, gRank1DynamicListsIntact,
            gRank1StaticNodeCoverage, gRank1DynamicNodeCoverage,
            gRank1OwnerEndValidity, gRank1EndInvalidSurfaces,
            gRank1PendingCleanupSurfaces, gRank1OwnerEndSafety,
            gRank1EventHash, invariant);
    gRank1FramesChecked++;
    if (!invariant) gRank1FrameFailures++;
    for (i = 0; i < 8; i++) {
        gRank1OutsideCallSums[i] += gRank1OutsideCalls[i];
        if (gRank1OutsideCalls[i] > gRank1OutsideCallMaxima[i]) {
            gRank1OutsideCallMaxima[i] = gRank1OutsideCalls[i];
        }
    }
    gRank1OutsideDestinationStoreSum += gRank1OutsideDestinationStores;
    if (gRank1OutsideDestinationStores
        > gRank1OutsideDestinationStoreMaximum) {
        gRank1OutsideDestinationStoreMaximum =
            gRank1OutsideDestinationStores;
    }
    gRank1FindFloorCallSum += gRank1FindFloorCalls;
    gRank1FindFloorReturnSum += gRank1FindFloorReturns;
    gRank1DynamicFindFloorReturnSum += gRank1DynamicFindFloorReturns;
    gRank1FindFloorReturnFailureSum += gRank1FindFloorReturnFailures;
    gRank1FindFloorBeforeClearSum += gRank1FindFloorBeforeClear;
    gRank1EndInvalidSurfaceSum += gRank1EndInvalidSurfaces;
    gRank1PendingCleanupSurfaceSum += gRank1PendingCleanupSurfaces;
    gRank1InactiveOwnerStoreSum += gRank1InactiveOwnerStores;
    gRank1InactiveCollisionModelCallSum +=
        gRank1InactiveCollisionModelCalls;
    if (gRank1SelectedStaticMembership) gRank1StaticSelectionFrames++;
    if (gRank1SelectedDynamicMembership) gRank1DynamicSelectionFrames++;
    if (gRank1SelectedOwner != 0) gRank1OwnedSelectionFrames++;
    gRank1AuditState = 3;
}

static int rank1_allocator_index(uint32_t pc) {
    switch (pc) {
        case A_MAIN_POOL_INIT: return 0;
        case A_MAIN_POOL_ALLOC: return 1;
        case A_MAIN_POOL_FREE: return 2;
        case A_MAIN_POOL_REALLOC: return 3;
        case A_MAIN_POOL_PUSH_STATE: return 4;
        case A_MAIN_POOL_POP_STATE: return 5;
        default: return -1;
    }
}

static const char *rank1_allocator_name(int index) {
    static const char *const names[] = {
        "init", "alloc", "free", "realloc", "push", "pop"
    };
    return index >= 0 && index < 6 ? names[index] : "unknown";
}

static int rank1_outside_index(uint32_t pc) {
    switch (pc) {
        case A_SQRTF: return 0;
        case A_SET_CAMERA_SHAKE_FROM_POINT: return 1;
        case A_CREATE_SOUND_SPAWNER: return 2;
        case A_CUR_OBJ_PLAY_SOUND_2: return 3;
        case A_PLAY_SOUND: return 4;
        case A_PLAY_PUZZLE_JINGLE: return 5;
        case A_STOP_SOUNDS_FROM_SOURCE: return 6;
        case A_STOP_SOUNDS_IN_CONTINUOUS_BANKS: return 7;
        default: return -1;
    }
}

static int rank1_handle_breakpoint(uint32_t pc, uint64_t *registers) {
    uint32_t trigger_flags = 0;
    uint32_t accessed = 0;
    int allocator_index;
    int outside_index;
#if RANK5_STATE_SPLIT_AUDIT
    int rank5_handled = 0;
#endif

    DBreakpointTriggeredBy(&trigger_flags, &accessed);
    if ((trigger_flags & M64P_BKP_FLAG_WRITE) != 0
        && rank1_handle_write(pc, registers, accessed)) return 1;
    if ((trigger_flags & M64P_BKP_FLAG_EXEC) == 0) return 0;
#if RANK5_STATE_SPLIT_AUDIT
    rank5_handled = rank5_handle_exec(pc);
#endif
#if RANK13_18_COPY_AUDIT
    if (rank13_handle_exec(pc, registers)) rank5_handled = 1;
#endif
    if (pc == A_UPDATE_OBJECTS) {
        if (gRank1AuditState == 1) rank1_start_audit();
        else if (gRank1AuditState == 2) {
            rank1_finish_audit();
            if (R32(A_GLOBAL_TIMER) < RANK1_BOUNDARY_REPEAT_UNTIL) {
                rank1_start_audit();
            }
        }
        return 1;
    }
#if RANK4_WARP_TOP_AUDIT
    if (pc == A_LOAD_OBJECT_SURFACES) {
        rank4_note_collision_load_call(R32(A_CURRENT_OBJECT));
    }
#endif
    if (gRank1AuditState != 2) {
#if RANK5_STATE_SPLIT_AUDIT
        return rank5_handled;
#else
        return 0;
#endif
    }
    allocator_index = rank1_allocator_index(pc);
    if (allocator_index >= 0) {
        gRank1AllocatorCalls[allocator_index]++;
        fprintf(stderr,
                "RANK1_ALLOCATOR_CALL,kind=%s,ordinal=%u,timer=%u,"
                "pc=%08x,returnPC=%08x,a0=%08x,a1=%08x,free=%u,"
                "leftHead=%08x,rightHead=%08x\n",
                rank1_allocator_name(allocator_index),
                gRank1AllocatorCalls[allocator_index],
                R32(A_GLOBAL_TIMER), pc,
                registers == NULL ? 0 : (uint32_t) registers[31],
                registers == NULL ? 0 : (uint32_t) registers[4],
                registers == NULL ? 0 : (uint32_t) registers[5],
                R32(A_MAIN_POOL_FREE_SPACE),
                R32(A_MAIN_POOL_LEFT_HEAD),
                R32(A_MAIN_POOL_RIGHT_HEAD));
        if (R32(A_MAIN_POOL_LEFT_HEAD) < gRank1SurfaceEnd
            || R32(A_MAIN_POOL_LEFT_HEAD) > R32(A_MAIN_POOL_RIGHT_HEAD)) {
            gRank1UnsafePoolWrites++;
        }
        return 1;
    }
    if (pc == A_CLEAR_DYNAMIC_SURFACES) {
        gRank1ClearDynamicCalls++;
        return 1;
    }
    if (pc == A_LOAD_OBJECT_COLLISION_MODEL) {
        uint32_t owner = R32(A_CURRENT_OBJECT);
        int rings_intact;
        int list_index = rank1_object_list_index(owner, &rings_intact);
        gRank1CollisionModelCalls++;
        if (pool_index(owner) >= 0
            && R16(owner + O_ACTIVE_FLAGS) == 0) {
            gRank1InactiveCollisionModelCalls++;
        }
        if (pool_index(owner) < 0 || R32(owner + O_COLLISION_DATA) == 0
            || list_index < 0 || !rings_intact) {
            gRank1OwnerFailures++;
        }
        return 1;
    }
    if (pc == A_LOAD_OBJECT_SURFACES) {
        gRank1LoadObjectSurfacesCalls++;
        return 1;
    }
    if (pc == A_ADD_SURFACE) {
        uint32_t surface = registers == NULL ? 0
                                             : (uint32_t) registers[4];
        uint32_t dynamic = registers == NULL ? 0
                                             : (uint32_t) registers[5];
        int surface_index = rank1_surface_index(surface);
        gRank1AddSurfaceCalls++;
        if (dynamic != 1 || surface_index < 0
            || !gRank1SurfaceReceipts[surface_index].owner_seen
            || R32(surface + SURFACE_OBJECT)
                != gRank1SurfaceReceipts[surface_index].owner) {
            gRank1OwnerFailures++;
        } else {
            gRank1SurfaceReceipts[surface_index].inserted = 1;
        }
        return 1;
    }
    if (pc == A_FIND_FLOOR) {
        uint32_t return_pc = registers == NULL ? 0
                                               : (uint32_t) registers[31];
        gRank1FindFloorCalls++;
        if (gRank1ClearDynamicCalls == 0) {
            gRank1FindFloorBeforeClear++;
        }
        if (return_pc == A_POST_PLATFORM_FIND_FLOOR) {
            uint32_t mario = R32(A_MARIO_OBJECT);
            gRank1PlatformFindFloorCalls++;
            gRank1PlatformQueryXBits = R32(mario + O_POS_X);
            gRank1PlatformQueryYBits = R32(mario + O_POS_Y);
            gRank1PlatformQueryZBits = R32(mario + O_POS_Z);
        }
        return 1;
    }
    if (pc == A_FIND_FLOOR_RETURN) {
        uint32_t sp = registers == NULL ? 0 : (uint32_t) registers[29];
        uint32_t x_bits = sp == 0 ? 0 : R32(sp + 0x40);
        uint32_t y_bits = sp == 0 ? 0 : R32(sp + 0x44);
        uint32_t z_bits = sp == 0 ? 0 : R32(sp + 0x48);
        uint32_t pfloor = sp == 0 ? 0 : R32(sp + 0x4c);
        uint32_t surface = pfloor == 0 ? 0 : R32(pfloor);
        uint32_t current_surfaces = R32(A_SURFACES_ALLOCATED);
        int surface_index = rank1_surface_index(surface);
        int static_matches = surface == 0 ? 0 : rank1_floor_membership(
            A_STATIC_SURFACE_PARTITION, surface, x_bits, z_bits);
        int dynamic_matches = surface == 0 ? 0 : rank1_floor_membership(
            A_DYNAMIC_SURFACE_PARTITION, surface, x_bits, z_bits);
        uint32_t owner = 0;
        int owner_list = -1;
        int rings_intact = 0;
        int safe = sp != 0 && pfloor != 0;

        gRank1FindFloorReturns++;
        if (surface != 0) {
            safe = safe && surface_index >= 0
                && (uint32_t) surface_index < current_surfaces
                && (static_matches > 0) + (dynamic_matches > 0) == 1;
        }
        if (dynamic_matches > 0 && surface_index >= 0
            && (unsigned) surface_index < SURFACE_CAPACITY) {
            struct rank1_surface_receipt *receipt =
                &gRank1SurfaceReceipts[surface_index];
            owner = R32(surface + SURFACE_OBJECT);
            owner_list = rank1_object_list_index(owner, &rings_intact);
            receipt->query_returns++;
            gRank1DynamicFindFloorReturns++;
            if (!receipt->owner_seen || !receipt->inserted
                || receipt->owner != owner || pool_index(owner) < 0
                || R16(owner + O_ACTIVE_FLAGS) == 0 || !rings_intact
                || owner_list != receipt->list_index
                || R32(owner + O_BEHAVIOR) != receipt->behavior) {
                receipt->unsafe_query_returns++;
                safe = 0;
            }
        }
        if (!safe) gRank1FindFloorReturnFailures++;
        rank1_hash_word(A_FIND_FLOOR_RETURN);
        rank1_hash_word(x_bits);
        rank1_hash_word(y_bits);
        rank1_hash_word(z_bits);
        rank1_hash_word(surface);
        rank1_hash_word(owner);
        rank1_hash_word(safe);
        if (!safe || (R32(A_GLOBAL_TIMER) == 2700
                      && dynamic_matches > 0)) {
            fprintf(stderr,
                    "RANK1_FIND_FLOOR_RETURN,timer=%u,ordinal=%u,"
                    "queryBits=(%08x,%08x,%08x),pfloor=%08x,"
                    "surface=%08x,surfaceIndex=%d,staticMatches=%d,"
                    "dynamicMatches=%d,owner=%08x,ownerList=%d,"
                    "ownerActive=%u,safe=%d\n",
                    R32(A_GLOBAL_TIMER), gRank1FindFloorReturns,
                    x_bits, y_bits, z_bits, pfloor, surface,
                    surface_index, static_matches, dynamic_matches,
                    owner, owner_list,
                    pool_index(owner) < 0 ? 0
                        : (unsigned) R16(owner + O_ACTIVE_FLAGS),
                    safe);
        }
        return 1;
    }
    if (pc == A_POST_PLATFORM_FIND_FLOOR) {
        uint32_t sp = registers == NULL ? 0 : (uint32_t) registers[29];
        gRank1SelectedFloor = sp == 0 ? 0 : R32(sp + 60);
        return 1;
    }
    if (pc == A_POST_MARIO_PLATFORM) {
        gRank1PostPlatformCalls++;
        gRank1SelectedPlatform = R32(A_MARIO_PLATFORM);
        return 1;
    }
    if (pc == A_CREATE_SOUND_SPAWNER_STORE
        || pc == A_PLAY_SOUND_STORE_0 || pc == A_PLAY_SOUND_STORE_1
        || pc == A_PLAY_SOUND_COUNT_STORE
        || pc == A_PLAY_PUZZLE_JINGLE_STORE) {
        uint32_t instruction = R32(pc);
        uint32_t target = rank1_effective_address(instruction, registers);
        int safe = 0;
        gRank1OutsideDestinationStores++;
        if (pc == A_CREATE_SOUND_SPAWNER_STORE) {
            safe = pool_index(target - O_MARIO_PARTICLE_FLAGS) >= 0
                && (target - A_OBJECT_POOL) % OBJECT_SIZE
                    == O_MARIO_PARTICLE_FLAGS;
        } else if (pc == A_PLAY_SOUND_STORE_0) {
            safe = target >= A_SOUND_REQUEST_BASE
                && target < A_SOUND_REQUEST_END
                && (target - A_SOUND_REQUEST_BASE) % 8 == 0;
        } else if (pc == A_PLAY_SOUND_STORE_1) {
            safe = target >= A_SOUND_REQUEST_BASE + 4
                && target < A_SOUND_REQUEST_END
                && (target - (A_SOUND_REQUEST_BASE + 4)) % 8 == 0;
        } else if (pc == A_PLAY_SOUND_COUNT_STORE) {
            safe = target == A_SOUND_REQUEST_COUNT;
        } else {
            safe = target == A_PUZZLE_MUSIC_STATE;
        }
        if (!safe) gRank1OutsideDestinationFailures++;
        rank1_hash_word(pc);
        rank1_hash_word(target);
        rank1_hash_word(safe);
        return 1;
    }
    outside_index = rank1_outside_index(pc);
    if (outside_index >= 0) {
        gRank1OutsideCalls[outside_index]++;
        rank1_hash_word(pc);
        if (registers != NULL) {
            rank1_hash_word((uint32_t) registers[4]);
            rank1_hash_word((uint32_t) registers[5]);
            rank1_hash_word((uint32_t) registers[29]);
        }
        return 1;
    }
#if RANK5_STATE_SPLIT_AUDIT
    return rank5_handled;
#else
    return 0;
#endif
}

#if !RANK4_WARP_TOP_AUDIT && !RANK5_STATE_SPLIT_AUDIT
static void arm_rank1_boundary_audit(void) {
    static const uint32_t exec_addresses[] = {
        A_UPDATE_OBJECTS,
        A_MAIN_POOL_INIT, A_MAIN_POOL_ALLOC, A_MAIN_POOL_FREE,
        A_MAIN_POOL_REALLOC, A_MAIN_POOL_PUSH_STATE, A_MAIN_POOL_POP_STATE,
        A_CLEAR_DYNAMIC_SURFACES, A_LOAD_OBJECT_COLLISION_MODEL,
        A_LOAD_OBJECT_SURFACES, A_ADD_SURFACE, A_FIND_FLOOR,
        A_FIND_FLOOR_RETURN,
        A_POST_PLATFORM_FIND_FLOOR, A_POST_MARIO_PLATFORM,
        A_SQRTF, A_SET_CAMERA_SHAKE_FROM_POINT,
        A_CREATE_SOUND_SPAWNER, A_CREATE_SOUND_SPAWNER_STORE,
        A_CUR_OBJ_PLAY_SOUND_2, A_PLAY_SOUND,
        A_PLAY_SOUND_STORE_0, A_PLAY_SOUND_STORE_1,
        A_PLAY_SOUND_COUNT_STORE, A_PLAY_PUZZLE_JINGLE,
        A_PLAY_PUZZLE_JINGLE_STORE,
    };
    unsigned i;
    int armed = 1;

    if (gRank1BreakpointsArmed) return;
    gRank1NodeBase = R32(A_SURFACE_NODE_POOL_CELL);
    gRank1SurfaceBase = R32(A_SURFACE_POOL_CELL);
    gRank1SurfaceEnd = gRank1SurfaceBase + SURFACE_BYTES;
    for (i = 0; i < sizeof(exec_addresses) / sizeof(exec_addresses[0]); i++) {
        if (!add_exec_breakpoint(exec_addresses[i])) armed = 0;
    }
    if (!add_rank1_write_breakpoints(gRank1NodeBase, SURFACE_NODE_BYTES)
        || !add_rank1_write_breakpoints(gRank1SurfaceBase, SURFACE_BYTES)
        || !add_rank1_write_breakpoints(A_STATIC_SURFACE_PARTITION,
                                        SURFACE_PARTITION_BYTES)
        || !add_rank1_write_breakpoints(A_DYNAMIC_SURFACE_PARTITION,
                                        SURFACE_PARTITION_BYTES)
        || !add_rank1_write_breakpoints(A_MAIN_POOL_FREE_SPACE, 0x14)
        || !add_rank1_write_breakpoints(A_SURFACE_NODE_POOL_CELL, 8)) {
        armed = 0;
    }
    if (!armed) {
        fprintf(stderr, "RANK1_BOUNDARY_ERROR,kind=breakpoint-arm\n");
        return;
    }
    gRank1BreakpointsArmed = 1;
    gRank1AuditState = 1;
    fprintf(stderr,
            "RANK1_BOUNDARY_ARM,timer=%u,updateObjects=%08x,findFloor=%08x,"
            "nodeRange=%08x-%08x,surfaceRange=%08x-%08x,"
            "staticPartition=%08x-%08x,dynamicPartition=%08x-%08x,"
            "readOnly=1\n",
            R32(A_GLOBAL_TIMER), A_UPDATE_OBJECTS, A_FIND_FLOOR,
            gRank1NodeBase, gRank1NodeBase + SURFACE_NODE_BYTES,
            gRank1SurfaceBase, gRank1SurfaceEnd,
            A_STATIC_SURFACE_PARTITION,
            A_STATIC_SURFACE_PARTITION + SURFACE_PARTITION_BYTES,
            A_DYNAMIC_SURFACE_PARTITION,
            A_DYNAMIC_SURFACE_PARTITION + SURFACE_PARTITION_BYTES);
}
#endif
#endif

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

#if RANK1_BOUNDARY_AUDIT
    if (rank1_handle_breakpoint(pc, registers)) {
        resume_from_breakpoint();
        return;
    }
#endif

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
    uint32_t node_pool;
    uint32_t surface_pool;
    int slot;
    int state_matches;
    int tail_safe;
    int list_ring;

    if (gEntryIdentityLogged) return;
    next = R32(mario_object + HEADER_NEXT);
    prev = R32(mario_object + HEADER_PREV);
    node_pool = R32(A_SURFACE_NODE_POOL_CELL);
    surface_pool = R32(A_SURFACE_POOL_CELL);
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
    fprintf(stderr,
            "ENTRY_SURFACE_POOLS,timer=%u,nodeBase=%08x,nodeEnd=%08x,"
            "surfaceBase=%08x,surfaceEnd=%08x,nodeBytes=56000,"
            "surfaceBytes=110400,separated=%d,mainPoolStart=%08x,"
            "mainPoolEnd=%08x,leftHead=%08x,rightHead=%08x,"
            "freeSpace=%u,liveEpoch=%d\n",
            R32(A_GLOBAL_TIMER), node_pool, node_pool + 56000,
            surface_pool, surface_pool + 110400,
            node_pool + 56016 == surface_pool,
            R32(A_MAIN_POOL_START), R32(A_MAIN_POOL_END),
            R32(A_MAIN_POOL_LEFT_HEAD), R32(A_MAIN_POOL_RIGHT_HEAD),
            R32(A_MAIN_POOL_FREE_SPACE),
            surface_pool + 110400 <= R32(A_MAIN_POOL_LEFT_HEAD)
                && R32(A_MAIN_POOL_LEFT_HEAD)
                    <= R32(A_MAIN_POOL_RIGHT_HEAD));
    gEntryIdentityLogged = 1;
#if RANK1_BOUNDARY_AUDIT && !RANK4_WARP_TOP_AUDIT \
    && !RANK5_STATE_SPLIT_AUDIT
    arm_rank1_boundary_audit();
#endif
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
        if (closef(rfloat(object + O_HOME_X), -1284.0f, 1.0f)
            && closef(rfloat(object + O_HOME_Z), -5895.0f, 1.0f)) {
            gToxBox1 = object;
        }
        if (closef(rfloat(object + O_HOME_X), 1283.0f, 1.0f)
            && closef(rfloat(object + O_HOME_Z), -4865.0f, 1.0f)) {
            gToxBox2 = object;
        }
        if (closef(rfloat(object + O_HOME_X), 4873.0f, 1.0f)
            && closef(rfloat(object + O_HOME_Z), -3335.0f, 1.0f)) {
            gToxBox3 = object;
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
#if RANK13_18_COPY_AUDIT
    rank13_print_result();
#endif
#if RANK5_STATE_SPLIT_AUDIT
    rank5_print_result();
#endif
#if RANK4_WARP_TOP_AUDIT
    unsigned rank4_writer_index;
    int rank4_invariant = gRank4Initialized
        && gRank4BreakpointsArmed
        && gRank4FramesChecked == 2462
        && gRank4FrameFailures == 0
        && gRank4TopBehaviorMaximum == 1
        && gRank4TopCollisionMaximum == 1
        && gRank4UpperWarpMaximum == 1
        && gRank4TopActiveFrames + gRank4TopAbsentFrames
            == gRank4FramesChecked
        && gRank4WarpActiveFrames == gRank4FramesChecked
        && gRank4TopResurrections == 0
        && gRank4TopPositionWrites
            == gRank4LiveTopPositionWrites
                + gRank4RetiredSlotPositionWrites
        && gRank4TopIdentityWrites
            == gRank4LiveTopIdentityWrites
                + gRank4RetiredSlotIdentityWrites
        && gRank4LiveTopIdentityWrites == 0
        && gRank4WarpPositionWrites == 0
        && gRank4WarpCollisionWrites == 0
        && gRank4WarpIdentityWrites == 0
        && gRank4TopCollisionLoadCalls > 0
        && gRank4BadTopCollisionLoadCalls == 0
        && gRank4UpperWarpCollisionLoadCalls == 0;
    for (rank4_writer_index = 0;
         rank4_writer_index < gRank4TopPositionWriterKinds;
         rank4_writer_index++) {
        fprintf(stderr,
                "RANK4_TOP_POSITION_WRITER,pc=%08x,count=%u\n",
                gRank4TopPositionWriterCounts[rank4_writer_index].pc,
                gRank4TopPositionWriterCounts[rank4_writer_index].count);
    }
    fprintf(stderr,
            "RANK4_WARP_TOP_RESULT,firstTimer=348,exclusiveEndTimer=2810,"
            "framesChecked=%u,frameFailures=%u,top=%08x,topSlot=%d,"
            "topBehavior=%08x,topCollision=%08x,upperWarp=%08x,"
            "upperWarpSlot=%d,warpBehavior=%08x,"
            "topActiveFrames=%u,topAbsentFrames=%u,warpActiveFrames=%u,"
            "topBehaviorMaximum=%u,topCollisionMaximum=%u,"
            "upperWarpMaximum=%u,topResurrections=%u,"
            "topPositionWrites=%u,liveTopPositionWrites=%u,"
            "retiredSlotPositionWrites=%u,topIdentityWrites=%u,"
            "liveTopIdentityWrites=%u,retiredSlotIdentityWrites=%u,"
            "warpPositionWrites=%u,"
            "warpCollisionWrites=%u,warpIdentityWrites=%u,"
            "topCollisionLoadCalls=%u,badTopCollisionLoadCalls=%u,"
            "upperWarpCollisionLoadCalls=%u,"
            "topX=%.9g:%.9g,topY=%.9g:%.9g,topZ=%.9g:%.9g,"
            "invariant=%d\n",
            gRank4FramesChecked, gRank4FrameFailures,
            gRank4CanonicalTop, pool_index(gRank4CanonicalTop),
            gRank4TopBehavior, gRank4TopCollisionData,
            gRank4CanonicalUpperWarp,
            pool_index(gRank4CanonicalUpperWarp), gRank4WarpBehavior,
            gRank4TopActiveFrames, gRank4TopAbsentFrames,
            gRank4WarpActiveFrames, gRank4TopBehaviorMaximum,
            gRank4TopCollisionMaximum, gRank4UpperWarpMaximum,
            gRank4TopResurrections, gRank4TopPositionWrites,
            gRank4LiveTopPositionWrites,
            gRank4RetiredSlotPositionWrites,
            gRank4TopIdentityWrites, gRank4LiveTopIdentityWrites,
            gRank4RetiredSlotIdentityWrites,
            gRank4WarpPositionWrites, gRank4WarpCollisionWrites,
            gRank4WarpIdentityWrites, gRank4TopCollisionLoadCalls,
            gRank4BadTopCollisionLoadCalls,
            gRank4UpperWarpCollisionLoadCalls,
            gRank4TopMinX, gRank4TopMaxX,
            gRank4TopMinY, gRank4TopMaxY,
            gRank4TopMinZ, gRank4TopMaxZ, rank4_invariant);
#endif
#if RANK1_BOUNDARY_AUDIT && RANK1_BOUNDARY_REPEAT_UNTIL > 349
    fprintf(stderr,
            "RANK1_REPEAT_RESULT,firstTimer=348,exclusiveEndTimer=%u,"
            "framesChecked=%u,frameFailures=%u,invariant=%d\n",
            (unsigned) RANK1_BOUNDARY_REPEAT_UNTIL,
            gRank1FramesChecked, gRank1FrameFailures,
            gRank1FramesChecked
                == (uint32_t) (RANK1_BOUNDARY_REPEAT_UNTIL - 348)
                && gRank1FrameFailures == 0);
    fprintf(stderr,
            "RANK1_REPEAT_AGGREGATE,"
            "outsideSums=%llu:%llu:%llu:%llu:%llu:%llu:%llu:%llu,"
            "outsideMaxima=%u:%u:%u:%u:%u:%u:%u:%u,"
            "destinationStoreSum=%llu,destinationStoreMaximum=%u,"
            "findFloorCallSum=%llu,findFloorReturnSum=%llu,"
            "dynamicFindFloorReturnSum=%llu,"
            "findFloorReturnFailureSum=%llu,"
            "findFloorBeforeClearSum=%llu,endInvalidSurfaceSum=%llu,"
            "pendingCleanupSurfaceSum=%llu,inactiveOwnerStoreSum=%llu,"
            "inactiveCollisionModelCallSum=%llu,"
            "staticSelectionFrames=%u,dynamicSelectionFrames=%u,"
            "ownedSelectionFrames=%u\n",
            (unsigned long long) gRank1OutsideCallSums[0],
            (unsigned long long) gRank1OutsideCallSums[1],
            (unsigned long long) gRank1OutsideCallSums[2],
            (unsigned long long) gRank1OutsideCallSums[3],
            (unsigned long long) gRank1OutsideCallSums[4],
            (unsigned long long) gRank1OutsideCallSums[5],
            (unsigned long long) gRank1OutsideCallSums[6],
            (unsigned long long) gRank1OutsideCallSums[7],
            gRank1OutsideCallMaxima[0], gRank1OutsideCallMaxima[1],
            gRank1OutsideCallMaxima[2], gRank1OutsideCallMaxima[3],
            gRank1OutsideCallMaxima[4], gRank1OutsideCallMaxima[5],
            gRank1OutsideCallMaxima[6], gRank1OutsideCallMaxima[7],
            (unsigned long long) gRank1OutsideDestinationStoreSum,
            gRank1OutsideDestinationStoreMaximum,
            (unsigned long long) gRank1FindFloorCallSum,
            (unsigned long long) gRank1FindFloorReturnSum,
            (unsigned long long) gRank1DynamicFindFloorReturnSum,
            (unsigned long long) gRank1FindFloorReturnFailureSum,
            (unsigned long long) gRank1FindFloorBeforeClearSum,
            (unsigned long long) gRank1EndInvalidSurfaceSum,
            (unsigned long long) gRank1PendingCleanupSurfaceSum,
            (unsigned long long) gRank1InactiveOwnerStoreSum,
            (unsigned long long) gRank1InactiveCollisionModelCallSum,
            gRank1StaticSelectionFrames, gRank1DynamicSelectionFrames,
            gRank1OwnedSelectionFrames);
#endif
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
            "mode11DetourStage=%d,mode11TopApproach=%d,"
            "mode12Stage=%d,mode12RolloutInputs=%d,"
            "mode12DiveInputs=%d,mode12PillarsComplete=%d,"
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
            gMode11DetourStage, gMode11TopApproach,
            gMode12Stage, gMode12RolloutInputs, gMode12DiveInputs,
            gMode12PillarsComplete,
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
#if RANK4_WARP_TOP_AUDIT
    arm_rank4_warp_top_audit();
    rank4_observe_frame();
#endif
#if RANK5_STATE_SPLIT_AUDIT
    arm_rank5_state_split_audit();
#endif
#if RANK13_18_COPY_AUDIT
    arm_rank13_copy_audit();
#endif
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

    /* Video-derived reconstruction of pannenkoek2012's 2013 1x-A route.
       The outside portion uses the east jumping box to enter a fast stomach
       slide, then converts that slide (or a later speed-kick dive slide) into
       a B rollout against each pillar's flared base.  Keep this schedule
       separate from the Tweester relay modes so every observed transition is
       attributable to ordinary controller input and stock actions. */
    if (SEARCH_MODE == 12) {
        uint32_t action = R32(A_MARIO_STATES + M_ACTION);
        uint32_t timer = R32(A_GLOBAL_TIMER);
        uint32_t held_object = R32(A_MARIO_STATES + M_HELD_OBJ);
        float mario_x = rfloat(A_MARIO_STATES + M_POS_X);
        float mario_z = rfloat(A_MARIO_STATES + M_POS_Z);
        int16_t face_yaw = (int16_t) R16(A_MARIO_STATES + M_FACE_YAW);
        int face_south_error =
            (int16_t) (face_yaw - (int16_t) 0x8000);
        float target_x = 1789.0f;
        float target_z = 764.0f;
        float steer_strength = 127.0f;
        float distance;
        float west_box_distance = INFINITY;

        if (face_south_error < 0) face_south_error = -face_south_error;
        if (pillars == 4) gMode12PillarsComplete = 1;
        if (gWestJumpingBox != 0) {
            west_box_distance = hypotf(
                rfloat(gWestJumpingBox + O_POS_X) - mario_x,
                rfloat(gWestJumpingBox + O_POS_Z) - mario_z);
        }

        if (gMode12Stage >= 58 && !gMode12ToxInventoryLogged) {
            unsigned object_index;
            for (object_index = 0; object_index < OBJECT_COUNT;
                 object_index++) {
                uint32_t candidate = pool_pointer(object_index);
                if (R16(candidate + O_ACTIVE_FLAGS) == 0
                    || R32(candidate + O_COLLISION_DATA) == 0
                    || rfloat(candidate + O_POS_Z) > -3000.0f) continue;
                fprintf(stderr,
                        "MODE12_MAZE_OBJECT,index=%u,object=%08x,"
                        "pos=(%.9g,%.9g,%.9g),home=(%.9g,%.9g),"
                        "action=%u,objectTimer=%u,behavior=%08x,"
                        "collision=%08x\n",
                        object_index, candidate,
                        rfloat(candidate + O_POS_X),
                        rfloat(candidate + O_POS_Y),
                        rfloat(candidate + O_POS_Z),
                        rfloat(candidate + O_HOME_X),
                        rfloat(candidate + O_HOME_Z),
                        R32(candidate + O_ACTION), R32(candidate + O_TIMER),
                        R32(candidate + O_BEHAVIOR),
                        R32(candidate + O_COLLISION_DATA));
            }
            gMode12ToxInventoryLogged = 1;
        }

        if (gMode12Stage >= 58 && (timer % 30) == 0 && gToxBox1 != 0) {
            fprintf(stderr,
                    "MODE12_TOX1,timer=%u,stage=%d,pos=(%.9g,%.9g,%.9g),"
                    "action=%u,objectTimer=%u\n",
                    timer, gMode12Stage,
                    rfloat(gToxBox1 + O_POS_X), rfloat(gToxBox1 + O_POS_Y),
                    rfloat(gToxBox1 + O_POS_Z), R32(gToxBox1 + O_ACTION),
                    R32(gToxBox1 + O_TIMER));
        }

        if (gMode12PillarsComplete) {
            int west_box_active = gWestJumpingBox != 0
                && R16(gWestJumpingBox + O_ACTIVE_FLAGS) != 0;

            if (gMode12Stage < 8) {
                gMode12Stage = 8;
                fprintf(stderr,
                        "MODE12_STAGE,timer=%u,stage=8,"
                        "label=opened-top-west-box-approach,"
                        "state=(%.9g,%.9g,%.9g),topAction=%d\n",
                        timer, mario_x,
                        rfloat(A_MARIO_STATES + M_POS_Y), mario_z,
                        top_action);
            }
            if (held_object == gWestJumpingBox
                || action == ACT_CRAZY_BOX_BOUNCE || !west_box_active) {
                target_x = -2048.0f;
                target_z = -1024.0f;
                if (gMode12Stage == 8 || gMode12Stage == 80) {
                    gMode12Stage = 9;
                    fprintf(stderr,
                            "MODE12_STAGE,timer=%u,stage=9,"
                            "label=west-box-to-upper-warp,"
                            "state=(%.9g,%.9g,%.9g),action=%08x,"
                            "heldObj=%08x,boxActive=%d\n",
                            timer, mario_x,
                            rfloat(A_MARIO_STATES + M_POS_Y), mario_z,
                            action, held_object, west_box_active);
                }
            } else if (gMode12Stage == 8) {
                /* Approach the box from northwest so its inherited launch
                   heading points southeast toward the opened pyramid,
                   rather than northeast into the western Tweester. */
                target_x = -5580.0f;
                target_z = 2030.0f;
                steer_strength = 60.0f;
                if (hypotf(target_x - mario_x, target_z - mario_z)
                    < 80.0f) {
                    gMode12Stage = 80;
                    fprintf(stderr,
                            "MODE12_STAGE,timer=%u,stage=80,"
                            "label=west-box-southeast-alignment,"
                            "state=(%.9g,%.9g,%.9g),faceYaw=%d\n",
                            timer, mario_x,
                            rfloat(A_MARIO_STATES + M_POS_Y), mario_z,
                            face_yaw);
                }
            } else {
                target_x = rfloat(gWestJumpingBox + O_POS_X);
                target_z = rfloat(gWestJumpingBox + O_POS_Z);
            }
        } else if (pillars == 0 && gMode12Stage == 0 && held_object == 0
            && action != ACT_CRAZY_BOX_BOUNCE && gJumpingBox != 0
            && R16(gJumpingBox + O_ACTIVE_FLAGS) != 0) {
            target_x = rfloat(gJumpingBox + O_POS_X);
            target_z = rfloat(gJumpingBox + O_POS_Z);
            gMode12Stage = 0;
        } else if (pillars == 0) {
            target_x = 1789.0f;
            target_z = 764.0f;
            if (gMode12Stage < 1) {
                gMode12Stage = 1;
                fprintf(stderr,
                        "MODE12_STAGE,timer=%u,stage=1,"
                        "label=east-box-to-northeast-pillar,"
                        "state=(%.9g,%.9g,%.9g),action=%08x,heldObj=%08x\n",
                        timer, mario_x,
                        rfloat(A_MARIO_STATES + M_POS_Y), mario_z,
                        action, held_object);
            }
        } else if (pillars == 1) {
            if (gMode12Stage < 2) {
                gMode12Stage = 2;
                fprintf(stderr,
                        "MODE12_STAGE,timer=%u,stage=2,"
                        "label=northeast-detector,"
                        "state=(%.9g,%.9g,%.9g),pillars=%d\n",
                        timer, mario_x,
                        rfloat(A_MARIO_STATES + M_POS_Y), mario_z, pillars);
            }
            target_x = 1789.0f;
            target_z = -2579.0f;
            if (gMode12Stage < 3) {
                gMode12Stage = 3;
                fprintf(stderr,
                        "MODE12_STAGE,timer=%u,stage=3,"
                        "label=southeast-pillar-approach,"
                        "state=(%.9g,%.9g,%.9g)\n",
                        timer, mario_x,
                        rfloat(A_MARIO_STATES + M_POS_Y), mario_z);
            }
        } else if (pillars == 2) {
            if (gMode12Stage < 4) {
                gMode12Stage = 4;
                fprintf(stderr,
                        "MODE12_STAGE,timer=%u,stage=4,"
                        "label=southeast-runway-gap,"
                        "state=(%.9g,%.9g,%.9g)\n",
                        timer, mario_x,
                        rfloat(A_MARIO_STATES + M_POS_Y), mario_z);
            }
            if (gMode12Stage == 4) {
                float dx = mario_x - 1789.0f;
                float dz = mario_z + 2579.0f;
                float radius = hypotf(dx, dz);
                float radial_x = radius < 1.0f ? 1.0f : dx / radius;
                float radial_z = radius < 1.0f ? 0.0f : dz / radius;
                float correction = (145.0f - radius) / 145.0f;
                float heading_x = -radial_z + correction * radial_x;
                float heading_z = radial_x + correction * radial_z;

                /* A tangent-plus-radial controller builds running speed on
                   a bounded circle instead of chasing a time-indexed point
                   off the small top.  Launch only at the south-facing arc. */
                target_x = mario_x + heading_x * 1000.0f;
                target_z = mario_z + heading_z * 1000.0f;
                if (rfloat(A_MARIO_STATES + M_POS_Y) > 850.0f
                    && action == ACT_WALKING
                    && rfloat(A_MARIO_STATES + M_FORWARD_VEL) >= 29.0f
                    && face_south_error < 0x1000) {
                    gMode12Stage = 40;
                    fprintf(stderr,
                            "MODE12_STAGE,timer=%u,stage=40,"
                            "label=southeast-runway-launch,"
                            "state=(%.9g,%.9g,%.9g),forwardVel=%.9g,"
                            "faceYaw=%d,intendedYaw=%d,southError=%d\n",
                            timer, mario_x,
                            rfloat(A_MARIO_STATES + M_POS_Y), mario_z,
                            rfloat(A_MARIO_STATES + M_FORWARD_VEL),
                            face_yaw,
                            (int16_t) R16(A_MARIO_STATES + M_INTENDED_YAW),
                            face_south_error);
                }
            } else if (gMode12Stage == 40) {
                target_x = 1900.0f;
                target_z = -4000.0f;
                if (mario_z <= -3900.0f) {
                    gMode12Stage = 5;
                    fprintf(stderr,
                            "MODE12_STAGE,timer=%u,stage=5,"
                            "label=south-safe-seam,"
                            "state=(%.9g,%.9g,%.9g)\n",
                            timer, mario_x,
                            rfloat(A_MARIO_STATES + M_POS_Y), mario_z);
                }
            } else if (gMode12Stage == 5) {
                /* Follow the clearance-checked centers of the stock hard
                   Tox-box walkways.  The apparent direct west strip is a
                   steep sliding surface bordered by instant quicksand. */
                target_x = 1100.0f;
                target_z = -4000.0f;
                steer_strength = 40.0f;
                if (mario_x <= 1150.0f) gMode12Stage = 51;
            } else if (gMode12Stage == 51) {
                target_x = 1100.0f;
                target_z = -4700.0f;
                steer_strength = 40.0f;
                if (mario_z <= -4650.0f) gMode12Stage = 52;
            } else if (gMode12Stage == 52) {
                target_x = 600.0f;
                target_z = -4700.0f;
                steer_strength = 40.0f;
                if (mario_x <= 650.0f) gMode12Stage = 53;
            } else if (gMode12Stage == 53) {
                target_x = 600.0f;
                target_z = -5200.0f;
                steer_strength = 40.0f;
                if (mario_z <= -5150.0f) gMode12Stage = 54;
            } else if (gMode12Stage == 54) {
                target_x = -1400.0f;
                target_z = -5200.0f;
                steer_strength = 40.0f;
                if (mario_x <= -1350.0f) gMode12Stage = 55;
            } else if (gMode12Stage == 55) {
                target_x = -1400.0f;
                target_z = -5100.0f;
                steer_strength = 32.0f;
                if (mario_z >= -5150.0f) gMode12Stage = 56;
            } else if (gMode12Stage == 56) {
                target_x = -1500.0f;
                target_z = -5100.0f;
                steer_strength = 32.0f;
                if (mario_x <= -1450.0f) gMode12Stage = 57;
            } else if (gMode12Stage == 57) {
                target_x = -1500.0f;
                target_z = -5000.0f;
                steer_strength = 32.0f;
                if (mario_z >= -5050.0f) gMode12Stage = 58;
            } else if (gMode12Stage == 58) {
                target_x = -2300.0f;
                target_z = -5000.0f;
                /* Clear Tox Box 1's later crossing window rather than
                   lingering in its east-west lane. */
                steer_strength = 90.0f;
                if (mario_x <= -2250.0f) gMode12Stage = 59;
            } else if (gMode12Stage == 59) {
                /* Begin the turn before the geometric center; at full
                   running speed a center-triggered turn reaches the west
                   edge before Mario's face yaw catches up. */
                target_x = -2450.0f;
                target_z = -5700.0f;
                steer_strength = 90.0f;
                if (mario_z <= -5650.0f) gMode12Stage = 60;
            } else if (gMode12Stage == 60) {
                target_x = -3500.0f;
                target_z = -5700.0f;
                steer_strength = 40.0f;
                if (mario_x <= -3450.0f) gMode12Stage = 61;
            } else if (gMode12Stage == 61) {
                target_x = -3500.0f;
                target_z = -5000.0f;
                steer_strength = 40.0f;
                if (mario_z >= -5050.0f) gMode12Stage = 62;
            } else if (gMode12Stage == 62) {
                target_x = -4900.0f;
                target_z = -5000.0f;
                steer_strength = 40.0f;
                if (mario_x <= -4850.0f) gMode12Stage = 63;
            } else if (gMode12Stage == 63) {
                target_x = -4900.0f;
                target_z = -4600.0f;
                steer_strength = 40.0f;
                if (mario_z >= -4650.0f) {
                    gMode12Stage = 6;
                    fprintf(stderr,
                            "MODE12_STAGE,timer=%u,stage=6,"
                            "label=southwest-pillar-approach,"
                            "state=(%.9g,%.9g,%.9g)\n",
                            timer, mario_x,
                            rfloat(A_MARIO_STATES + M_POS_Y), mario_z);
                }
            } else {
                target_x = -5883.0f;
                target_z = -2579.0f;
            }
        } else if (pillars == 3) {
            target_x = -5883.0f;
            target_z = 764.0f;
            if (gMode12Stage < 7) {
                gMode12Stage = 7;
                fprintf(stderr,
                        "MODE12_STAGE,timer=%u,stage=7,"
                        "label=northwest-pillar-approach,"
                        "state=(%.9g,%.9g,%.9g)\n",
                        timer, mario_x,
                        rfloat(A_MARIO_STATES + M_POS_Y), mario_z);
            }
        } else {
            target_x = -5883.0f;
            target_z = 764.0f;
        }

        distance = hypotf(target_x - mario_x, target_z - mario_z);
        steer_world(keys, target_x, target_z, steer_strength);

        if (gMode12PillarsComplete && gMode12Stage == 80
            && held_object == 0 && action != ACT_CRAZY_BOX_BOUNCE
            && gWestJumpingBox != 0
            && R16(gWestJumpingBox + O_ACTIVE_FLAGS) != 0
            && west_box_distance < 135.0f
            && timer - gLastMovementB >= 20) {
            keys->B_BUTTON = 1;
            gBPressedFrames++;
            gLastMovementB = timer;
            fprintf(stderr,
                    "B_INPUT,timer=%u,label=mode12-west-jumping-box,"
                    "distance=%.9g,state=(%.9g,%.9g,%.9g),action=%08x\n",
                    timer, west_box_distance, mario_x,
                    rfloat(A_MARIO_STATES + M_POS_Y), mario_z, action);
        } else if (gMode12PillarsComplete && gMode12Stage >= 9
                   && action == ACT_STOMACH_SLIDE
                   && R16(A_MARIO_STATES + M_ACTION_TIMER) == 5
                   && distance < 1600.0f
                   && timer - gLastMovementB >= 5) {
            keys->B_BUTTON = 1;
            gBPressedFrames++;
            gMode12RolloutInputs++;
            gLastMovementB = timer;
            fprintf(stderr,
                    "B_INPUT,timer=%u,label=mode12-top-rollout,"
                    "distance=%.9g,state=(%.9g,%.9g,%.9g),action=%08x\n",
                    timer, distance, mario_x,
                    rfloat(A_MARIO_STATES + M_POS_Y), mario_z, action);
        } else if (gMode12PillarsComplete && gMode12Stage >= 9
                   && action == ACT_DIVE_SLIDE && distance < 1200.0f
                   && timer - gLastMovementB >= 5) {
            keys->B_BUTTON = 1;
            gBPressedFrames++;
            gMode12RolloutInputs++;
            gLastMovementB = timer;
            fprintf(stderr,
                    "B_INPUT,timer=%u,label=mode12-top-dive-rollout,"
                    "distance=%.9g,state=(%.9g,%.9g,%.9g),action=%08x\n",
                    timer, distance, mario_x,
                    rfloat(A_MARIO_STATES + M_POS_Y), mario_z, action);
        } else if (gMode12PillarsComplete && gMode12Stage >= 9
                   && action == ACT_WALKING
                   && rfloat(A_MARIO_STATES + M_FORWARD_VEL) >= 29.0f
                   && distance > 300.0f && distance < 1600.0f
                   && timer - gLastMovementB >= 20) {
            keys->B_BUTTON = 1;
            gBPressedFrames++;
            gMode12DiveInputs++;
            gLastMovementB = timer;
            fprintf(stderr,
                    "B_INPUT,timer=%u,label=mode12-top-speed-kick,"
                    "distance=%.9g,state=(%.9g,%.9g,%.9g),action=%08x\n",
                    timer, distance, mario_x,
                    rfloat(A_MARIO_STATES + M_POS_Y), mario_z, action);
        } else if (pillars == 0 && held_object == 0
            && action != ACT_CRAZY_BOX_BOUNCE && gJumpingBox != 0
            && R16(gJumpingBox + O_ACTIVE_FLAGS) != 0
            && distance < 135.0f && timer - gLastMovementB >= 20) {
            keys->B_BUTTON = 1;
            gBPressedFrames++;
            gLastMovementB = timer;
            fprintf(stderr,
                    "B_INPUT,timer=%u,label=mode12-east-jumping-box,"
                    "distance=%.9g,state=(%.9g,%.9g,%.9g),action=%08x\n",
                    timer, distance, mario_x,
                    rfloat(A_MARIO_STATES + M_POS_Y), mario_z, action);
        } else if (pillars <= 2
                   && (gMode12Stage < 5 || gMode12Stage == 40)
                   && action == ACT_STOMACH_SLIDE
                   && R16(A_MARIO_STATES + M_ACTION_TIMER) == 5
                   && distance < (gMode12Stage == 40 ? 2000.0f : 500.0f)
                   && timer - gLastMovementB >= 5) {
            keys->B_BUTTON = 1;
            gBPressedFrames++;
            gMode12RolloutInputs++;
            gLastMovementB = timer;
            fprintf(stderr,
                    "B_INPUT,timer=%u,label=mode12-pillar-rollout,"
                    "distance=%.9g,state=(%.9g,%.9g,%.9g),action=%08x\n",
                    timer, distance, mario_x,
                    rfloat(A_MARIO_STATES + M_POS_Y), mario_z, action);
        } else if (pillars <= 2
                   && (gMode12Stage < 5 || gMode12Stage == 40)
                   && action == ACT_DIVE_SLIDE
                   && distance < (gMode12Stage == 40 ? 1600.0f : 400.0f)
                   && timer - gLastMovementB >= 5) {
            keys->B_BUTTON = 1;
            gBPressedFrames++;
            gMode12RolloutInputs++;
            gLastMovementB = timer;
            fprintf(stderr,
                    "B_INPUT,timer=%u,label=mode12-dive-rollout,"
                    "distance=%.9g,state=(%.9g,%.9g,%.9g),action=%08x\n",
                    timer, distance, mario_x,
                    rfloat(A_MARIO_STATES + M_POS_Y), mario_z, action);
        } else if (pillars <= 2
                   && (gMode12Stage < 5 || gMode12Stage == 40)
                   && action == ACT_WALKING
                   && rfloat(A_MARIO_STATES + M_FORWARD_VEL) >= 29.0f
                   && distance > 300.0f
                   && distance < (gMode12Stage == 40 ? 2000.0f : 900.0f)
                   && timer - gLastMovementB >= 20) {
            keys->B_BUTTON = 1;
            gBPressedFrames++;
            gMode12DiveInputs++;
            gLastMovementB = timer;
            fprintf(stderr,
                    "B_INPUT,timer=%u,label=mode12-speed-kick,"
                    "distance=%.9g,state=(%.9g,%.9g,%.9g),action=%08x\n",
                    timer, distance, mario_x,
                    rfloat(A_MARIO_STATES + M_POS_Y), mario_z, action);
        }
        goto log_frame;
    }

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
       avoiding the wall reflection measured in mode 9.  Mode 11 takes a
       wider, three-leg northern detour, then continues toward the activated
       top instead of stopping at the fourth detector. */
    if ((SEARCH_MODE == 9 || SEARCH_MODE == 10 || SEARCH_MODE == 11)
        && gUsedTornado) {
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
            if (SEARCH_MODE != 11) {
                /* Pillar four is the decisive endpoint for modes 9 and 10:
                   leave the controller neutral and retain lifecycle samples. */
                goto log_frame;
            }
            if (!gMode11TopApproach) {
                gMode11TopApproach = 1;
                fprintf(stderr,
                        "MODE9_STAGE,timer=%u,stage=9,"
                        "label=mode11-top-approach,"
                        "state=(%.9g,%.9g,%.9g),topAction=%d,topTimer=%d\n",
                        timer, mario_x,
                        rfloat(A_MARIO_STATES + M_POS_Y), mario_z,
                        top_action, top_timer);
            }
            steer_world(keys, -2048.0f, -1024.0f, 127.0f);
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
                   && SEARCH_MODE == 11 && gMode11DetourStage == 0) {
            target_x = 1100.0f;
            target_z = 5900.0f;
            if (mario_z >= 5600.0f) {
                gMode11DetourStage = 1;
                fprintf(stderr,
                        "MODE9_STAGE,timer=%u,stage=4,"
                        "label=mode11-north-leg,"
                        "state=(%.9g,%.9g,%.9g)\n",
                        timer, mario_x,
                        rfloat(A_MARIO_STATES + M_POS_Y), mario_z);
            }
        } else if (pillars == 2 && !gMode9WestTweesterCaptured
                   && SEARCH_MODE == 11 && gMode11DetourStage == 1) {
            target_x = -3800.0f;
            target_z = 5700.0f;
            if (mario_x <= -300.0f) {
                gMode11DetourStage = 2;
                fprintf(stderr,
                        "MODE9_STAGE,timer=%u,stage=4,"
                        "label=mode11-west-leg,"
                        "state=(%.9g,%.9g,%.9g)\n",
                        timer, mario_x,
                        rfloat(A_MARIO_STATES + M_POS_Y), mario_z);
            }
        } else if (pillars == 2 && !gMode9WestTweesterCaptured
                   && SEARCH_MODE == 11 && gMode11DetourStage == 2) {
            target_x = -3600.0f;
            target_z = 2940.0f;
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

        if (SEARCH_MODE == 11 && pillars == 2
            && gMode11DetourStage >= 1
            && (action == ACT_STOMACH_SLIDE
                || action == ACT_STOMACH_SLIDE_STOP)
            && timer - gLastMovementB >= 20) {
            keys->B_BUTTON = 1;
            gMode9SurvivalBInputs++;
            gBPressedFrames++;
            gLastMovementB = timer;
            fprintf(stderr,
                    "B_INPUT,timer=%u,label=mode11-north-rim-rollout,"
                    "distance=%.9g,state=(%.9g,%.9g,%.9g),action=%08x\n",
                    timer, distance, mario_x,
                    rfloat(A_MARIO_STATES + M_POS_Y), mario_z, action);
        } else if (pillars == 2 && !gMode9SourceTweesterCaptured
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
                || SEARCH_MODE == 9 || SEARCH_MODE == 10
                || SEARCH_MODE == 11) {
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
                   || SEARCH_MODE == 9 || SEARCH_MODE == 10
                   || SEARCH_MODE == 11) {
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
