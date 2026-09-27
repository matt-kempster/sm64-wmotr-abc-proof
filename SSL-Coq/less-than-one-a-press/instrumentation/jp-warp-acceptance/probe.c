/* Read-only extension of the stock zero-A four-pillar replay.
 * This records the agreed checkpoint BEFORE act_disappeared runs.
 * No position, action, pointer, timer, or game-memory payload is supplied. */
#define GetKeys CleanGetKeys
#define RomClosed CleanRomClosed
#define debugger_update_callback CleanDebuggerUpdate
#include "../jp-clean-gap-search/jp_clean_gap_search_probe.c"
#undef debugger_update_callback
#undef RomClosed
#undef GetKeys

static unsigned waArmed, waPending, waAccepted, waSnapshots, waFailures;
static unsigned waDisappeared, waCopied, waFinal;
static uint32_t waTimer;
static uint32_t waOriginalTop;

/* Stock bhvPyramidTop, authenticated by the existing Rank-4 identity audit.
 * Do not reuse the route controller's position-based gTop heuristic: that
 * heuristic may later identify a fragment at a similar position. */
static unsigned wa_live_tops(uint32_t *found) {
    unsigned slot, count = 0;
    for (slot = 0; slot < OBJECT_COUNT; slot++) {
        uint32_t object = pool_pointer(slot);
        if (R16(object + O_ACTIVE_FLAGS) != 0
            && R32(object + O_BEHAVIOR) == 0x800ebeb4) {
            *found = object;
            count++;
        }
    }
    return count;
}

static void wa_snapshot(const char *stage, uint32_t result) {
    uint32_t object = R32(A_MARIO_OBJECT);
    uint32_t floor = R32(A_MARIO_STATES + M_FLOOR);
    int valid_floor = floor >= gRank1SurfaceBase
        && floor <= gRank1SurfaceEnd - SURFACE_SIZE
        && (floor - gRank1SurfaceBase) % SURFACE_SIZE == 0;
    unsigned axis;
    uint32_t words[9];
    uint32_t live_top = 0;
    unsigned top_count = wa_live_tops(&live_top);
    if (object != A_SLOT67 || R32(A_MARIO_STATES + M_MARIO_OBJ) != object
        || (floor != 0 && !valid_floor)) waFailures++;
    for (axis = 0; axis < 3; axis++) {
        words[axis] = R32(A_MARIO_STATES + M_POS_X + 4 * axis);
        words[axis + 3] = R32(object + O_POS_X + 4 * axis);
        words[axis + 6] = R32(object + GFX_POS_X + 4 * axis);
    }
    waSnapshots++;
    fprintf(stderr,
        "WARP_ACCEPT_SAMPLE,stage=%s,timer=%u,area=%u,result=%u,"
        "action=%08x,arg=%08x,used=%08x,upper=%08x,"
        "state=%08x:%08x:%08x,collision=%08x:%08x:%08x,"
        "display=%08x:%08x:%08x,floor=%08x,height=%08x,owner=%08x,"
        "platform=%08x,originalTopSlot=%08x,originalSlotActive=%u,"
        "originalSlotBehavior=%08x,liveTopCount=%u,liveTop=%08x\n",
        stage, R32(A_GLOBAL_TIMER), R16(A_CURR_AREA), result,
        R32(A_MARIO_STATES + M_ACTION), R32(A_MARIO_STATES + 0x1c),
        R32(A_MARIO_STATES + M_USED_OBJ), gUpperWarp,
        words[0], words[1], words[2], words[3], words[4], words[5],
        words[6], words[7], words[8], floor,
        R32(A_MARIO_STATES + M_FLOOR_HEIGHT),
        valid_floor ? R32(floor + SURFACE_OBJECT) : 0,
        R32(A_MARIO_PLATFORM), waOriginalTop,
        waOriginalTop ? R16(waOriginalTop + O_ACTIVE_FLAGS) : 0,
        waOriginalTop ? R32(waOriginalTop + O_BEHAVIOR) : 0,
        top_count, live_top);
}

static void wa_debugger_update(unsigned int pc) {
    const uint64_t *regs = DGetCPUDataPtr(M64P_CPU_REG_REG);
    if (R16(A_CURR_AREA) == 1 && rank13_active()) {
        if (pc == R13_HANDLER_CALL && regs != NULL
            && (uint32_t) regs[25] == R13_WARP_HANDLER
            && (uint32_t) regs[6] == gUpperWarp) {
            if (waPending || waAccepted) waFailures++;
            waPending = 1;
            waTimer = R32(A_GLOBAL_TIMER);
            wa_snapshot("handler-entry", 0);
        }
        if (pc == R13_ACCEPT_NONFADING_WARP && waPending)
            wa_snapshot("nonfading-branch", 0);
        if (pc == R13_HANDLER_RETURN && waPending) {
            waPending = 0;
            if (regs == NULL || (uint32_t) regs[2] != 1
                || R32(A_MARIO_STATES + M_ACTION) != ACT_DISAPPEARED
                || R32(A_MARIO_STATES + 0x1c) != 0x00040002
                || R32(A_MARIO_STATES + M_USED_OBJ) != gUpperWarp
                || waDisappeared != 0) waFailures++;
            waAccepted++;
            wa_snapshot("accepted-return", regs ? (uint32_t) regs[2] : 0);
        }
        if (waAccepted && R32(A_GLOBAL_TIMER) == waTimer) {
            if (pc == R13_DISAPPEARED) {
                waDisappeared++;
                wa_snapshot("disappeared-entry", 0);
            }
            if (pc == R13_POST_DISAPPEARED)
                wa_snapshot("disappeared-return", regs ? (uint32_t) regs[2] : 1);
            if (pc == A_POST_COPY_MARIO_STATE_TO_OBJECT) {
                waCopied++;
                wa_snapshot("copy-return", 0);
            }
            if (pc == A_POST_MARIO_PLATFORM) {
                waFinal++;
                wa_snapshot("final-platform-return", 0);
            }
        }
    }
#ifdef WARP_ACCEPT_DEBUG_OBSERVER
    WARP_ACCEPT_DEBUG_OBSERVER(pc);
#endif
    CleanDebuggerUpdate(pc);
}

EXPORT void CALL GetKeys(int control, BUTTONS *keys) {
    CleanGetKeys(control, keys);
    if (control == 0 && R32(A_GLOBAL_TIMER) == 348 && R16(A_CURR_AREA) == 1) {
        if (wa_live_tops(&waOriginalTop) != 1 || waOriginalTop != pool_pointer(61))
            waFailures++;
    }
    if (control == 0 && !waArmed && gPrefixTraceArmed) {
        if (DSetCallbacks(debugger_init_callback, wa_debugger_update,
                         debugger_vi_callback) != M64ERR_SUCCESS) waFailures++;
        else waArmed = 1;
    }
#ifdef WARP_ACCEPT_INPUT_OBSERVER
    WARP_ACCEPT_INPUT_OBSERVER(control, keys);
#endif
}

EXPORT void CALL RomClosed(void) {
    CleanRomClosed();
#ifdef WARP_ACCEPT_CLOSE_OBSERVER
    WARP_ACCEPT_CLOSE_OBSERVER();
#endif
    fprintf(stderr,
        "WARP_ACCEPT_RESULT,armed=%u,accepted=%u,pending=%u,snapshots=%u,"
        "disappeared=%u,copied=%u,final=%u,topIdentified=%u,failures=%u\n",
        waArmed, waAccepted, waPending, waSnapshots, waDisappeared,
        waCopied, waFinal, waOriginalTop == pool_pointer(61), waFailures);
}
