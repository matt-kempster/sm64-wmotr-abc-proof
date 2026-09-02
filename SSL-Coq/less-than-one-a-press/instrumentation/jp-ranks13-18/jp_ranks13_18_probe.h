/* Read-only extension of the authenticated Rank-5 controller replay.
 * Included only by jp_clean_gap_search_probe.c with RANK13_18_COPY_AUDIT=1.
 * Every memory watch observes CPU stores; no RAM/code/pose is installed. */

enum {
    R13_STATE_POINTER = 0x8032c9d8,
    R13_HANDLERS = 0x8032c9f0,
    R13_EXECUTE_ACTION = 0x80254604,
    R13_POST_INPUTS = 0x80254664,
    R13_INTERACTIONS = 0x80250218,
    R13_HANDLER_CALL = 0x80250318,
    R13_HANDLER_RETURN = 0x80250320,
    R13_INTERACTION_TAIL = 0x80250344,
    R13_POST_INTERACTIONS = 0x8025467c,
    R13_ACCEPT_NONFADING_WARP = 0x8024de6c,
    R13_WARP_HANDLER = 0x8024dd68,
    R13_DISAPPEARED = 0x80257794,
    R13_POST_DISAPPEARED = 0x8025d5b4,
    R13_FLOOR_SNAP_STORE = 0x802557c0,
    R13_POST_FLOOR_SNAP = 0x802557c4,
    R13_COPY = 0x8029c000,
    R13_COPY_INDEX = 0x8029c02c,
    R13_COPY_X_STORE = 0x8029c0e8,
    R13_COPY_Y_STORE = 0x8029c118,
    R13_COPY_Z_STORE = 0x8029c148,
};

enum rank13_stage {
    R13_IDLE, R13_FRAME, R13_ACTION, R13_INPUTS_DONE,
    R13_IN_INTERACTIONS, R13_ACTIONS, R13_IN_COPY, R13_COPIED
};

static const struct {
    uint32_t start, end, word_fnv;
} rank13_immutable_ranges[] = {
    {0x8024c000, 0x8029c3b4, 0xb0b82bed},
    {R13_HANDLERS, R13_HANDLERS + 31 * 8, 0x9c829df6},
    {0x803355b4, 0x803357a0, 0x998bbc13},
};

static int gRank13Armed;
static enum rank13_stage gRank13Stage;
static uint32_t gRank13Frames, gRank13ActionEntries, gRank13InputReturns;
static uint32_t gRank13InteractionEntries, gRank13InteractionReturns;
static uint32_t gRank13CopyEntries, gRank13CopyIndices, gRank13CopyReturns;
static uint32_t gRank13CopyStoreCounts[3], gRank13CopyReadbacks[3];
static uint32_t gRank13Failures, gRank13DecodeFailures;
static uint32_t gRank13ImmutableWrites, gRank13StatePointerWrites;
static uint32_t gRank13CurrentWritesInCopy, gRank13StateWritesInCopy;
static uint32_t gRank13ObjectWritesOutsideCopy;
static uint32_t gRank13CopyMask, gRank13CopySource[3];
static uint32_t gRank13HandlerCalls, gRank13HandlerReturns;
static uint32_t gRank13HandlerIndex, gRank13HandlerObject, gRank13HandlerTarget;
static uint32_t gRank13HandlerCounts[31], gRank13HandlerNonzero[31];
static int gRank13HandlerPending, gRank13HandlerBroke;
static int gRank13WarpWindow;
static int gRank13FloorWindow;
static uint32_t gRank13AcceptedWarps, gRank13WarpReturns, gRank13LaterHandlers;
static uint32_t gRank13WarpXZStores, gRank13WarpYStores, gRank13BadWarpYStores;
static uint32_t gRank13WarpFloorWrites, gRank13WarpFloor, gRank13WarpFloorHeight;
static uint32_t gRank13WarpState[3], gRank13DisappearedCalls;
static uint32_t gRank13DisappearedReturns, gRank13FloorSnapChecks;
static uint32_t gRank13FinalQueries;
static uint32_t gRank13WatchedFloor, gRank13PoolPointerWrites;

static int rank13_active(void) {
    return gRank13Armed && gRank5Initialized && !gRank5Complete
        && gRank5Phase != RANK5_PHASE_INACTIVE;
}

static int rank13_in_immutable_range(uint32_t target, uint32_t width) {
    unsigned i;
    for (i = 0; i < sizeof(rank13_immutable_ranges)
                         / sizeof(rank13_immutable_ranges[0]); i++) {
        if (rank1_overlaps_range(target, width, rank13_immutable_ranges[i].start,
                                 rank13_immutable_ranges[i].end)) return 1;
    }
    return 0;
}

static int rank13_extra_range(uint32_t target, uint32_t width) {
    return rank13_in_immutable_range(target, width)
        || rank1_overlaps_range(target, width, R13_STATE_POINTER, R13_STATE_POINTER + 4)
        || rank1_overlaps_range(target, width, A_CURRENT_OBJECT, A_CURRENT_OBJECT + 4)
        || rank1_overlaps_range(target, width, A_SURFACE_POOL_CELL, A_SURFACE_POOL_CELL + 4)
        || rank1_overlaps_range(target, width, A_MARIO_STATES + M_FLOOR,
                                A_MARIO_STATES + M_FLOOR_HEIGHT + 4);
}

static int rank13_note_undecoded_write(uint32_t accessed) {
    uint32_t word = 0x80000000u | ((accessed & 0x1fffffffu) & ~3u);
    if (!rank13_active()) return 0;
    if (rank13_extra_range(word, 4) || rank5_watches_range(word, 4)
        || (gRank13FloorWindow && gRank13WarpFloor != 0
            && rank1_overlaps_range(word, 4, gRank13WarpFloor,
                                    gRank13WarpFloor + SURFACE_SIZE))) {
        gRank13DecodeFailures++;
        return 1;
    }
    return 0;
}

static int rank13_note_write(uint32_t pc, uint32_t target, uint32_t width) {
    unsigned component;
    int watched = 0;
    if (!rank13_active()) return 0;
    if (rank13_in_immutable_range(target, width)) {
        gRank13ImmutableWrites++;
        watched = 1;
    }
    if (rank1_overlaps_range(target, width, R13_STATE_POINTER, R13_STATE_POINTER + 4)) {
        gRank13StatePointerWrites++;
        watched = 1;
    }
    if (rank1_overlaps_range(target, width, A_SURFACE_POOL_CELL, A_SURFACE_POOL_CELL + 4)) {
        gRank13PoolPointerWrites++;
        watched = 1;
    }
    if (rank1_overlaps_range(target, width, A_CURRENT_OBJECT, A_CURRENT_OBJECT + 4)) {
        if (gRank13Stage == R13_IN_COPY) gRank13CurrentWritesInCopy++;
        watched = 1;
    }
    if (rank1_overlaps_range(target, width, A_MARIO_STATES + M_POS_X,
                             A_MARIO_STATES + M_POS_X + 12)) {
        watched = 1;
        if (gRank13Stage == R13_IN_COPY) gRank13StateWritesInCopy++;
        if (gRank13WarpWindow) {
            if (target == A_MARIO_STATES + M_POS_Y && width == 4) {
                gRank13WarpYStores++;
                if (pc != R13_FLOOR_SNAP_STORE) gRank13BadWarpYStores++;
            } else {
                gRank13WarpXZStores++;
            }
        }
    }
    if (rank1_overlaps_range(target, width, A_SLOT67 + O_POS_X,
                             A_SLOT67 + O_POS_X + 12)) {
        static const uint32_t stores[3] = {
            R13_COPY_X_STORE, R13_COPY_Y_STORE, R13_COPY_Z_STORE
        };
        watched = 1;
        if (gRank13Stage != R13_IN_COPY) {
            gRank13ObjectWritesOutsideCopy++;
        } else {
            for (component = 0; component < 3; component++) {
                if (pc == stores[component]
                    && target == A_SLOT67 + O_POS_X + 4 * component
                    && width == 4 && gRank13CopyMask == (1u << component) - 1) {
                    gRank13CopyMask |= 1u << component;
                    gRank13CopyStoreCounts[component]++;
                    break;
                }
            }
            if (component == 3) gRank13Failures++;
        }
    }
    if (gRank13FloorWindow
        && (rank1_overlaps_range(target, width, A_MARIO_STATES + M_FLOOR,
                                 A_MARIO_STATES + M_FLOOR_HEIGHT + 4)
            || (gRank13WarpFloor != 0
                && rank1_overlaps_range(target, width, gRank13WarpFloor,
                                        gRank13WarpFloor + SURFACE_SIZE)))) {
        gRank13WarpFloorWrites++;
        watched = 1;
    }
    return watched;
}

static void rank13_snapshot(const char *kind) {
    uint32_t floor = R32(A_MARIO_STATES + M_FLOOR);
    uint32_t owner = 0;
    int valid_floor = floor >= gRank1SurfaceBase
        && floor <= gRank1SurfaceEnd - SURFACE_SIZE
        && (floor - gRank1SurfaceBase) % SURFACE_SIZE == 0;
    if (valid_floor) owner = R32(floor + SURFACE_OBJECT);
    if (floor != 0 && !valid_floor) gRank13Failures++;
    fprintf(stderr,
            "RANK13_WARP_SNAPSHOT,kind=%s,timer=%u,action=%08x,used=%08x,"
            "state=%08x:%08x:%08x,object=%08x:%08x:%08x,"
            "floor=%08x,floorHeight=%08x,owner=%08x\n",
            kind, R32(A_GLOBAL_TIMER), R32(A_MARIO_STATES + M_ACTION),
            R32(A_MARIO_STATES + M_USED_OBJ),
            R32(A_MARIO_STATES + M_POS_X), R32(A_MARIO_STATES + M_POS_Y),
            R32(A_MARIO_STATES + M_POS_Z), R32(A_SLOT67 + O_POS_X),
            R32(A_SLOT67 + O_POS_Y), R32(A_SLOT67 + O_POS_Z),
            floor, R32(A_MARIO_STATES + M_FLOOR_HEIGHT), owner);
}

static void rank13_begin_warp_window(void) {
    gRank13WarpWindow = 1;
    gRank13FloorWindow = 1;
    gRank13WarpFloor = R32(A_MARIO_STATES + M_FLOOR);
    gRank13WarpFloorHeight = R32(A_MARIO_STATES + M_FLOOR_HEIGHT);
    rank5_read_state(gRank13WarpState);
    if (gRank13WarpFloor != 0 && gRank13WarpFloor != gRank13WatchedFloor) {
        if (gRank13WarpFloor < gRank1SurfaceBase
            || gRank13WarpFloor > gRank1SurfaceEnd - SURFACE_SIZE
            || (gRank13WarpFloor - gRank1SurfaceBase) % SURFACE_SIZE != 0
            || !add_rank1_write_breakpoints(gRank13WarpFloor, SURFACE_SIZE)) {
            gRank13Failures++;
        } else gRank13WatchedFloor = gRank13WarpFloor;
    }
}

static int rank13_handle_exec(uint32_t pc, uint64_t *registers) {
    uint32_t sp, component;
    if (!rank13_active()) return 0;
    sp = registers == NULL ? 0 : (uint32_t) registers[29];
    switch (pc) {
        case A_UPDATE_OBJECTS:
            if (gRank13Frames != 0 && gRank13Stage != R13_COPIED) gRank13Failures++;
            gRank13Frames++;
            gRank13Stage = R13_FRAME;
            if (gRank13FloorWindow) gRank13Failures++;
            gRank13WarpWindow = gRank13FloorWindow = 0;
            gRank13HandlerBroke = gRank13HandlerPending = 0;
            return 1;
        case R13_EXECUTE_ACTION:
            if (gRank13Stage != R13_FRAME || R32(R13_STATE_POINTER) != A_MARIO_STATES
                || R32(A_CURRENT_OBJECT) != A_SLOT67 || registers == NULL
                || (uint32_t) registers[4] != A_SLOT67) gRank13Failures++;
            gRank13ActionEntries++;
            gRank13Stage = R13_ACTION;
            return 1;
        case R13_POST_INPUTS:
            if (gRank13Stage != R13_ACTION) gRank13Failures++;
            gRank13InputReturns++;
            gRank13Stage = R13_INPUTS_DONE;
            if (R32(A_MARIO_STATES + M_ACTION) == ACT_DISAPPEARED
                && R32(A_MARIO_STATES + M_USED_OBJ) == gUpperWarp)
                rank13_begin_warp_window();
            if (R32(A_GLOBAL_TIMER) >= 2807) rank13_snapshot("post-inputs");
            return 1;
        case R13_INTERACTIONS:
            if (gRank13Stage != R13_INPUTS_DONE || registers == NULL
                || (uint32_t) registers[4] != A_MARIO_STATES) gRank13Failures++;
            gRank13InteractionEntries++;
            gRank13Stage = R13_IN_INTERACTIONS;
            return 1;
        case R13_HANDLER_CALL:
            if (gRank13Stage != R13_IN_INTERACTIONS || sp == 0 || registers == NULL
                || gRank13HandlerPending || gRank13HandlerBroke) gRank13Failures++;
            if (gRank13WarpWindow) gRank13LaterHandlers++;
            gRank13HandlerIndex = sp == 0 ? 31 : R32(sp + 44);
            gRank13HandlerTarget = registers == NULL ? 0 : (uint32_t) registers[25];
            gRank13HandlerObject = registers == NULL ? 0 : (uint32_t) registers[6];
            if (gRank13HandlerIndex >= 31 || registers == NULL
                || (uint32_t) registers[4] != A_MARIO_STATES
                || (uint32_t) registers[5] != R32(R13_HANDLERS + 8 * gRank13HandlerIndex)
                || gRank13HandlerTarget != R32(R13_HANDLERS + 8 * gRank13HandlerIndex + 4)
                || pool_index(gRank13HandlerObject) < 0) gRank13Failures++;
            else gRank13HandlerCounts[gRank13HandlerIndex]++;
            gRank13HandlerCalls++;
            gRank13HandlerPending = 1;
            return 1;
        case R13_ACCEPT_NONFADING_WARP:
            if (!gRank13HandlerPending || gRank13HandlerIndex != 4
                || gRank13HandlerTarget != R13_WARP_HANDLER
                || gRank13HandlerObject != gUpperWarp || gRank13WarpWindow)
                gRank13Failures++;
            gRank13AcceptedWarps++;
            rank13_begin_warp_window();
            rank13_snapshot("accept-nonfading");
            return 1;
        case R13_HANDLER_RETURN:
            if (!gRank13HandlerPending || registers == NULL) gRank13Failures++;
            gRank13HandlerPending = 0;
            gRank13HandlerReturns++;
            if (registers != NULL && (uint32_t) registers[2] != 0) {
                gRank13HandlerBroke = 1;
                if (gRank13HandlerIndex < 31) gRank13HandlerNonzero[gRank13HandlerIndex]++;
            }
            if (gRank13WarpWindow) {
                gRank13WarpReturns++;
                if (registers == NULL || (uint32_t) registers[2] != 1
                    || R32(A_MARIO_STATES + M_ACTION) != ACT_DISAPPEARED
                    || R32(A_MARIO_STATES + M_USED_OBJ) != gUpperWarp) gRank13Failures++;
                rank13_snapshot("warp-return-one");
            }
            return 1;
        case R13_INTERACTION_TAIL:
            if (gRank13HandlerPending) gRank13Failures++;
            return 1;
        case R13_POST_INTERACTIONS:
            if (gRank13Stage != R13_IN_INTERACTIONS || gRank13HandlerPending)
                gRank13Failures++;
            gRank13InteractionReturns++;
            gRank13Stage = R13_ACTIONS;
            if (gRank13WarpWindow) rank13_snapshot("post-interactions");
            return 1;
        case R13_DISAPPEARED:
            if (R32(A_GLOBAL_TIMER) >= 2807) {
                if (gRank13Stage != R13_ACTIONS || registers == NULL
                    || (uint32_t) registers[4] != A_MARIO_STATES) gRank13Failures++;
                gRank13DisappearedCalls++;
                rank13_snapshot("disappeared-entry");
            }
            return 1;
        case R13_POST_DISAPPEARED:
            if (R32(A_GLOBAL_TIMER) >= 2807) {
                gRank13DisappearedReturns++;
                if (registers == NULL || (uint32_t) registers[2] != 0) gRank13Failures++;
                rank13_snapshot("disappeared-return-zero");
            }
            return 1;
        case R13_POST_FLOOR_SNAP:
            if (gRank13WarpWindow) {
                gRank13FloorSnapChecks++;
                if (R32(A_MARIO_STATES + M_POS_Y) != gRank13WarpFloorHeight)
                    gRank13Failures++;
            }
            return 1;
        case R13_COPY:
            if (gRank13Stage != R13_ACTIONS || R32(R13_STATE_POINTER) != A_MARIO_STATES
                || R32(A_CURRENT_OBJECT) != A_SLOT67 || !rank5_mario_identity_holds())
                gRank13Failures++;
            gRank13CopyEntries++;
            gRank13Stage = R13_IN_COPY;
            gRank13CopyMask = 0;
            rank5_read_state(gRank13CopySource);
            if (R32(A_GLOBAL_TIMER) >= 2807) rank13_snapshot("copy-entry");
            return 1;
        case R13_COPY_INDEX:
            if (gRank13Stage != R13_IN_COPY || sp == 0 || R32(sp + 4) != 0)
                gRank13Failures++;
            gRank13CopyIndices++;
            return 1;
        case R13_COPY_X_STORE + 4:
        case R13_COPY_Y_STORE + 4:
        case R13_COPY_Z_STORE + 4:
            component = pc == R13_COPY_X_STORE + 4 ? 0
                : pc == R13_COPY_Y_STORE + 4 ? 1 : 2;
            gRank13CopyReadbacks[component]++;
            if (gRank13Stage != R13_IN_COPY || gRank13CopyMask != (2u << component) - 1
                || R32(A_SLOT67 + O_POS_X + 4 * component) != gRank13CopySource[component]
                || R32(A_MARIO_STATES + M_POS_X + 4 * component) != gRank13CopySource[component])
                gRank13Failures++;
            return 1;
        case A_POST_COPY_MARIO_STATE_TO_OBJECT:
            if (gRank13Stage != R13_IN_COPY || gRank13CopyMask != 7
                || !rank5_state_object_equal() || R32(A_CURRENT_OBJECT) != A_SLOT67)
                gRank13Failures++;
            gRank13CopyReturns++;
            gRank13Stage = R13_COPIED;
            if (gRank13WarpWindow) {
                if (R32(A_MARIO_STATES + M_POS_X) != gRank13WarpState[0]
                    || R32(A_MARIO_STATES + M_POS_Z) != gRank13WarpState[2]) gRank13Failures++;
                rank13_snapshot("copy-return");
                gRank13WarpWindow = 0;
            }
            return 1;
        case A_POST_PLATFORM_FIND_FLOOR:
            if (R32(A_GLOBAL_TIMER) >= 2807) {
                gRank13FinalQueries++;
                if (!gRank13FloorWindow || gRank13Stage != R13_COPIED || sp == 0
                    || R32(sp + 60) != gRank13WarpFloor
                    || R32(A_MARIO_STATES + M_FLOOR) != gRank13WarpFloor
                    || R32(A_MARIO_STATES + M_FLOOR_HEIGHT) != gRank13WarpFloorHeight)
                    gRank13Failures++;
                fprintf(stderr, "RANK13_FINAL_QUERY,timer=%u,floor=%08x,"
                        "object=%08x:%08x:%08x\n", R32(A_GLOBAL_TIMER),
                        sp == 0 ? 0 : R32(sp + 60), R32(A_SLOT67 + O_POS_X),
                        R32(A_SLOT67 + O_POS_Y), R32(A_SLOT67 + O_POS_Z));
                gRank13FloorWindow = 0;
            }
            return 1;
        default: return 0;
    }
}

static void arm_rank13_copy_audit(void) {
    static const uint32_t addresses[] = {
        R13_EXECUTE_ACTION, R13_POST_INPUTS, R13_INTERACTIONS, R13_HANDLER_CALL,
        R13_HANDLER_RETURN, R13_INTERACTION_TAIL, R13_POST_INTERACTIONS,
        R13_ACCEPT_NONFADING_WARP, R13_DISAPPEARED, R13_POST_DISAPPEARED,
        R13_POST_FLOOR_SNAP, R13_COPY, R13_COPY_INDEX,
        R13_COPY_X_STORE + 4, R13_COPY_Y_STORE + 4, R13_COPY_Z_STORE + 4,
        A_POST_PLATFORM_FIND_FLOOR
    };
    unsigned i;
    if (gRank13Armed || !gRank5Initialized) return;
    gRank1SurfaceBase = R32(A_SURFACE_POOL_CELL);
    gRank1SurfaceEnd = gRank1SurfaceBase + SURFACE_BYTES;
    for (i = 0; i < sizeof(addresses) / sizeof(addresses[0]); i++) {
        if (!add_exec_breakpoint(addresses[i])) gRank13Failures++;
    }
    for (i = 0; i < sizeof(rank13_immutable_ranges) / sizeof(rank13_immutable_ranges[0]); i++) {
        uint32_t address, hash = 2166136261u;
        for (address = rank13_immutable_ranges[i].start;
             address < rank13_immutable_ranges[i].end; address += 4) {
            hash ^= R32(address);
            hash *= 16777619u;
        }
        if (hash != rank13_immutable_ranges[i].word_fnv
            || !add_rank1_write_breakpoints(rank13_immutable_ranges[i].start,
                rank13_immutable_ranges[i].end - rank13_immutable_ranges[i].start))
            gRank13Failures++;
        fprintf(stderr, "RANK13_CODE,start=%08x,end=%08x,wordFNV=%08x,expected=%08x\n",
                rank13_immutable_ranges[i].start, rank13_immutable_ranges[i].end,
                hash, rank13_immutable_ranges[i].word_fnv);
    }
    if (!add_rank1_write_breakpoints(R13_STATE_POINTER, 4)
        || !add_rank1_write_breakpoints(A_CURRENT_OBJECT, 4)
        || !add_rank1_write_breakpoints(A_SURFACE_POOL_CELL, 4)
        || !add_rank1_write_breakpoints(A_MARIO_STATES + M_FLOOR, 12)) gRank13Failures++;
    gRank13Armed = 1;
    fprintf(stderr, "RANK13_ARM,timer=%u,readOnly=1\n", R32(A_GLOBAL_TIMER));
}

static void rank13_print_result(void) {
    unsigned i;
    int invariant = gRank13Armed && gRank5Complete && gRank13Failures == 0
        && gRank13Frames == 2462 && gRank13ActionEntries == gRank13Frames
        && gRank13InputReturns == gRank13Frames
        && gRank13InteractionEntries == gRank13Frames
        && gRank13InteractionReturns == gRank13Frames
        && gRank13CopyEntries == gRank13Frames && gRank13CopyIndices == gRank13Frames
        && gRank13CopyReturns == gRank13Frames && gRank13HandlerCalls == gRank13HandlerReturns
        && gRank13DecodeFailures == 0 && gRank13ImmutableWrites == 0
        && gRank13PoolPointerWrites == 0
        && gRank13StatePointerWrites == 0 && gRank13CurrentWritesInCopy == 0
        && gRank13StateWritesInCopy == 0 && gRank13ObjectWritesOutsideCopy == 0
        && gRank13AcceptedWarps == 1 && gRank13WarpReturns == gRank13AcceptedWarps
        && gRank13LaterHandlers == 0 && gRank13WarpXZStores == 0
        && gRank13BadWarpYStores == 0 && gRank13WarpFloorWrites == 0
        && gRank13WarpYStores == gRank13FloorSnapChecks && gRank13FloorSnapChecks == 3
        && gRank13DisappearedCalls == 3 && gRank13DisappearedReturns == 3
        && gRank13FinalQueries == 3 && !gRank13FloorWindow;
    for (i = 0; i < 3; i++) {
        invariant = invariant && gRank13CopyStoreCounts[i] == gRank13Frames
            && gRank13CopyReadbacks[i] == gRank13Frames;
        fprintf(stderr, "RANK13_COPY_COMPONENT,component=%u,stores=%u,readbacks=%u\n",
                i, gRank13CopyStoreCounts[i], gRank13CopyReadbacks[i]);
    }
    for (i = 0; i < 31; i++) {
        if (gRank13HandlerCounts[i] != 0) fprintf(stderr,
            "RANK13_HANDLER,index=%u,calls=%u,nonzeroReturns=%u\n",
            i, gRank13HandlerCounts[i], gRank13HandlerNonzero[i]);
    }
    fprintf(stderr, "RANK13_RESULT,frames=%u,actionEntries=%u,inputReturns=%u,"
            "interactionEntries=%u,interactionReturns=%u,copyEntries=%u,copyIndices=%u,"
            "copyReturns=%u,handlerCalls=%u,handlerReturns=%u,failures=%u,decodeFailures=%u,"
            "immutableWrites=%u,statePointerWrites=%u,currentWritesInCopy=%u,stateWritesInCopy=%u,"
            "objectWritesOutsideCopy=%u,acceptedWarps=%u,warpReturns=%u,laterHandlers=%u,"
            "warpXZStores=%u,warpYStores=%u,badWarpYStores=%u,warpFloorWrites=%u,"
            "floorSnapChecks=%u,disappearedCalls=%u,disappearedReturns=%u,finalQueries=%u,"
            "poolPointerWrites=%u,invariant=%d\n",
            gRank13Frames, gRank13ActionEntries, gRank13InputReturns, gRank13InteractionEntries,
            gRank13InteractionReturns, gRank13CopyEntries, gRank13CopyIndices, gRank13CopyReturns,
            gRank13HandlerCalls, gRank13HandlerReturns, gRank13Failures, gRank13DecodeFailures,
            gRank13ImmutableWrites, gRank13StatePointerWrites, gRank13CurrentWritesInCopy,
            gRank13StateWritesInCopy, gRank13ObjectWritesOutsideCopy, gRank13AcceptedWarps,
            gRank13WarpReturns, gRank13LaterHandlers, gRank13WarpXZStores, gRank13WarpYStores,
            gRank13BadWarpYStores, gRank13WarpFloorWrites, gRank13FloorSnapChecks,
            gRank13DisappearedCalls, gRank13DisappearedReturns, gRank13FinalQueries,
            gRank13PoolPointerWrites, invariant);
}
