/* Exact retail call observations. No writes to emulated memory/registers.
 * Replay identity, not XYZ alone, identifies an observed case. The regions
 * below are an explicitly partial footprint; unobserved memory is NOT framed.
 */
#define M64P_PLUGIN_PROTOTYPES
#include <mupen64plus/m64p_plugin.h>
static void handoff_debug(unsigned int pc);
static void handoff_input(int control, BUTTONS *keys);
static void handoff_close(void);
#define WARP_ACCEPT_DEBUG_OBSERVER handoff_debug
#define WARP_ACCEPT_CLOSE_OBSERVER handoff_close
#define WAFEL_PILOT_EXTRA_INPUT handoff_input
#include "../wafel-jp-pilot/capture.c"

enum {
    H_START = 0x80322b30, H_START_RETURN = 0x80248b84,
    H_PADS = 0x80322bf4, H_NATIVE = 0x80384694,
    H_NATIVE_RETURN = 0x8038469c, H_QUEUE = 0x80339c08,
    H_PAD_ARRAY = 0x80339c88, H_PIF = 0x80365ce0,
    H_LAST_CMD = 0x80365d20, H_COMMAND = 0x8035fdf4,
    H_CURRENT_OBJECT = 0x8035fdf0
};
static unsigned hArmed, hFirst, hEnd, hFailures, hCalls, hReturns, hNative, hUpdates;
static uint32_t hPadReturn;
static unsigned hStartPending, hPadPending;
static unsigned hId;

static void h_bytes(uint32_t address, unsigned size) {
    unsigned i;
    for (i = 0; i < size; i++) {
        uint32_t at = address + i;
        fprintf(stderr, "%02x", (R32(at & ~3u) >> (24 - 8 * (at & 3))) & 255);
    }
}

static void h_region(const char *name, uint32_t address, unsigned size) {
    fprintf(stderr, "{\"name\":\"%s\",\"address\":%u,\"bytes\":\"", name, address);
    h_bytes(address, size);
    fprintf(stderr, "\"}");
}

static void h_sample(const char *kind, const char *name, unsigned id, uint32_t pc, uint64_t *r) {
    uint32_t object = R32(A_MARIO_OBJECT);
    if (pilot_slot(object) < 0 || r == NULL) { hFailures++; return; }
    fprintf(stderr, "R1_HANDOFF,{\"kind\":\"%s\",\"name\":\"%s\",\"id\":%u,"
        "\"pc\":%u,\"poll\":%llu,\"timer\":%u,\"area\":%u,\"sp\":%u,\"ra\":%u,"
        "\"args\":[%u,%u,%u,%u],\"v0\":%u,\"regions\":[",
        kind, name, id, pc, (unsigned long long)gPoll, R32(A_GLOBAL_TIMER),
        R16(A_CURR_AREA), (uint32_t)r[29], (uint32_t)r[31],
        (uint32_t)r[4], (uint32_t)r[5], (uint32_t)r[6], (uint32_t)r[7], (uint32_t)r[2]);
    h_region("gSIEventMesgQueue", H_QUEUE, 24); fprintf(stderr, ",");
    h_region("gControllerPads", H_PAD_ARRAY, 24); fprintf(stderr, ",");
    h_region("__osContPifRam", H_PIF, 64); fprintf(stderr, ",");
    h_region("__osContLastCmd", H_LAST_CMD, 1); fprintf(stderr, ",");
    h_region("gMarioStates.pos", A_MARIO_STATES + M_POS_X, 12); fprintf(stderr, ",");
    h_region("marioObject.pos", object + O_POS_X, 12); fprintf(stderr, ",");
    h_region("marioObject.gfx.pos", object + GFX_POS_X, 12);
    fprintf(stderr, "]}\n");
}

static void handoff_debug(unsigned int pc) {
    uint64_t *r = DGetCPUDataPtr(M64P_CPU_REG_REG);
    /* Input acquisition itself advances gPoll. Pair returns by pending ID,
     * including a return that crosses the last requested poll boundary. */
    if (!hArmed || r == NULL) return;
    if (pc == H_START_RETURN && hStartPending) {
        h_sample("return", "osContStartReadData", hStartPending, pc, r);
        hStartPending = 0; hReturns++; return;
    }
    if (pc == hPadReturn && hPadPending) {
        h_sample("return", "osContGetReadData", hPadPending, pc, r);
        hPadPending = 0; hReturns++; return;
    }
    if (gPoll < hFirst || gPoll >= hEnd) return;
    if (pc == H_START && (uint32_t)r[31] == H_START_RETURN) {
        if (hStartPending) { hFailures++; return; }
        hStartPending = ++hId; hCalls++;
        h_sample("entry", "osContStartReadData", hStartPending, pc, r);
    } else if (pc == H_PADS) {
        if (hPadPending) { hFailures++; return; }
        if (!hPadReturn) {
            hPadReturn = (uint32_t)r[31];
            if (!add_exec_breakpoint(hPadReturn)) abort();
        }
        if (hPadReturn != (uint32_t)r[31]) { hFailures++; return; }
        hPadPending = ++hId; hCalls++;
        h_sample("entry", "osContGetReadData", hPadPending, pc, r);
    } else if (pc == H_NATIVE) {
        uint32_t command = R32(H_COMMAND), receiver = R32(H_CURRENT_OBJECT);
        if (R32(command + 4) != (uint32_t)r[25] || pilot_slot(receiver) < 0) {
            hFailures++; return;
        }
        fprintf(stderr, "R1_HANDOFF,{\"kind\":\"native\",\"poll\":%llu,\"timer\":%u,"
            "\"pc\":%u,\"command\":%u,\"opcode\":%u,\"callee\":%u,\"receiver\":%u,\"slot\":%d}\n",
            (unsigned long long)gPoll, R32(A_GLOBAL_TIMER), pc, command,
            R32(command), (uint32_t)r[25], receiver, pilot_slot(receiver));
        hNative++;
    } else if (pc == A_POST_MARIO_PLATFORM) {
        uint32_t o = R32(A_MARIO_OBJECT);
        fprintf(stderr, "R1_HANDOFF,{\"kind\":\"checkpoint\",\"poll\":%llu,\"timer\":%u,"
            "\"area\":%u,\"rawY\":%u,\"stateY\":%u,\"displayY\":%u,"
            "\"platform\":%u,\"objectPlatform\":%u,\"top\":%u,\"topTimer\":%u}\n",
            (unsigned long long)gPoll, R32(A_GLOBAL_TIMER), R16(A_CURR_AREA),
            R32(o+O_POS_Y), R32(A_MARIO_STATES+M_POS_Y), R32(o+GFX_POS_Y),
            R32(A_MARIO_PLATFORM), R32(o+0x214), pool_pointer(61),
            R32(pool_pointer(61)+O_TIMER));
        hUpdates++;
    }
}

static void handoff_input(int control, BUTTONS *keys) {
    (void)keys;
    if (control || hArmed || !waArmed || gPoll < 350 || R16(A_CURR_AREA) != 1) return;
    hFirst = getenv("R1_HANDOFF_FIRST") ? (unsigned)strtoul(getenv("R1_HANDOFF_FIRST"),NULL,10) : 2651;
    hEnd = hFirst + 30;
    if (R32(H_START) != 0x27bdffe0 || R32(H_START_RETURN-8) != 0x0c0c8acc
        || R32(H_NATIVE) != 0x0320f809 || R32(H_NATIVE_RETURN) != 0x3c188036) {
        fprintf(stderr,"R1_HANDOFF_ERROR,instructions=%08x:%08x:%08x:%08x\n",
            R32(H_START),R32(H_START_RETURN-8),R32(H_NATIVE),R32(H_NATIVE_RETURN));
        abort();
    }
    if (!add_exec_breakpoint(H_START) || !add_exec_breakpoint(H_START_RETURN)
        || !add_exec_breakpoint(H_PADS) || !add_exec_breakpoint(H_NATIVE)
        || !add_exec_breakpoint(A_POST_MARIO_PLATFORM)) abort();
    hArmed = 1;
}

static void handoff_close(void) {
    fprintf(stderr, "R1_HANDOFF_RESULT,{\"first\":%u,\"endExclusive\":%u,\"entries\":%u,"
        "\"returns\":%u,\"nativeCalls\":%u,\"checkpoints\":%u,\"pending\":%u,\"failures\":%u}\n",
        hFirst, hEnd, hCalls, hReturns, hNative, hUpdates,
        (hStartPending != 0) + (hPadPending != 0), hFailures);
}
