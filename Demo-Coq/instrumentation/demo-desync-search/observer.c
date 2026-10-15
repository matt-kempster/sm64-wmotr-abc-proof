#define _GNU_SOURCE
#define M64P_PLUGIN_PROTOTYPES
#include <mupen64plus/m64p_common.h>
#include <mupen64plus/m64p_debugger.h>
#include <mupen64plus/m64p_plugin.h>
#include <dlfcn.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "addresses.h"

/* Observation only: no DebugMemWrite export, cheats, save-state loading, or
 * game-memory pointer is requested. All game-facing output is controller input.
 * Breakpoints observe real routine entries; they do not change game registers. */
typedef unsigned int (*read32_fn)(unsigned int);
typedef unsigned short (*read16_fn)(unsigned int);
typedef unsigned char (*read8_fn)(unsigned int);
static read32_fn R32;
static read16_fn R16;
static read8_fn R8;
static ptr_DebugSetCallbacks SetCallbacks;
static ptr_DebugSetRunState SetRunState;
static ptr_DebugBreakpointCommand BreakpointCommand;
static unsigned polls, installed, episode, consumed_frame, consumed_ptr;
static unsigned input_calls, gameplay_calls, mismatch_calls, errors;
static unsigned active_base, active_level, active_size, active_terminal;
static unsigned start_at, start_frames, gameplay_origin;
static const struct stream *active_stream;
static unsigned previous_ptr, previous_timer;
static int had_demo;

static unsigned hash_bytes(unsigned address, unsigned count, int immutable) {
    unsigned hash = 2166136261u, i;
    for (i = 0; i < count; ++i) {
        if (immutable && i >= 4 && i % 4 == 0) continue;
        hash = (hash ^ R8(address + i)) * 16777619u;
    }
    return hash;
}
static int rdram(unsigned p, unsigned n) {
    return p >= 0x80000000u && n <= 0x800000u && p <= 0x80800000u - n;
}
static int bytes_equal(unsigned base, const struct stream *s) {
    unsigned i;
    for (i = 0; i < s->size; ++i) if (R8(base + i) != s->data[i]) return 0;
    return 1;
}
static void error(const char *reason) {
    ++errors;
    fprintf(stderr, "DERROR,%s,frame=%u,reason=%s\n", VERSION_NAME,
            R32(A_GLOBAL_TIMER), reason);
}
static void debugger_init(void) {}
static void debugger_vi(void) {}
static void debugger_update(unsigned pc) {
    unsigned frame = R32(A_GLOBAL_TIMER), ptr = R32(A_CURR_DEMO_INPUT);
    if (pc == PC_RUN_DEMO_INPUTS) {
        if (!ptr) { had_demo = 0; consumed_ptr = 0; }
        else {
            unsigned base = R32(A_DEMO_INPUTS_BUF + 8), i;
            ++input_calls;
            if (!had_demo) {
                const struct stream *found = NULL;
                if (!rdram(base, 0x800) || ptr != base + 4) error("invalid-initial-demo-pointer");
                else for (i = 0; i < STREAM_COUNT; ++i) {
                    const struct stream *s = &streams[i];
                    if (hash_bytes(base, s->size, 0) == s->hash && bytes_equal(base, s)) { found = s; break; }
                }
                if (!found) error("initial-stream-not-authenticated");
                else {
                    ++episode; active_base = base; active_level = found->level;
                    active_size = found->size; active_terminal = base + found->size - 4;
                    active_stream = found; previous_ptr = 0;
                    gameplay_origin = UINT32_MAX;
                    fprintf(stderr, "DLOAD,%s,episode=%u,frame=%u,stream=%s,level=%u,base=%08x,ptr=%08x,hash=%08x,nextIndex=%u\n",
                            VERSION_NAME, episode, frame, found->name, found->level,
                            base, ptr, found->hash, R16(A_DEMO_INDEX));
                }
            }
            had_demo = 1; consumed_frame = frame; consumed_ptr = ptr;
            if (ptr < active_base + 4 || ptr > active_terminal || (ptr - active_base) % 4)
                error("input-pointer-outside-authenticated-records");
            else if (active_stream) {
                unsigned offset = ptr - active_base, j;
                for (j = 1; j < 4; ++j) if (R8(ptr + j) != active_stream->data[offset + j])
                    error("record-input-bytes-changed");
                if (previous_ptr) {
                    unsigned expected_ptr = previous_ptr + (previous_timer == 1 ? 4 : 0);
                    if (ptr != expected_ptr) error("record-pointer-progression");
                    if (expected_ptr < active_base + 4 || expected_ptr > active_terminal)
                        error("expected-record-outside-stream");
                    else {
                        unsigned expected_timer = previous_timer > 1 ? previous_timer - 1
                            : active_stream->data[expected_ptr - active_base];
                        if (R8(ptr) != expected_timer) error("record-timer-progression");
                    }
                }
                previous_ptr = ptr; previous_timer = R8(ptr);
            }
            if (ptr == active_terminal && R8(ptr) != 0) error("terminal-timer-not-zero");
        }
    } else if (pc == PC_UPDATE_LEVEL) {
        unsigned area = R32(A_CURRENT_AREA), level = R16(A_CURR_LEVEL);
        if (ptr) {
            const struct terrain *terrain_match = NULL;
            unsigned terrain = rdram(area, 0xc) ? R32(area + 8) : 0, ti, byte;
            unsigned painting = rdram(area, 0x3c) ? R32(area + 0x18) : ~0u;
            unsigned instant = rdram(area, 0x3c) ? R32(area + 0x1c) : ~0u;
            ++gameplay_calls;
            if (gameplay_origin == UINT32_MAX) gameplay_origin = frame;
            if (consumed_frame != frame || !consumed_ptr) error("no-same-frame-consumed-demo-input");
            if (!rdram(area, 0x3c) || !R32(A_MARIO_OBJECT)) error("missing-loaded-gameplay-area");
            if (rdram(terrain, TERRAIN_PREFIX_SIZE)) for (ti = 0; ti < TERRAIN_COUNT; ++ti) {
                for (byte = 0; byte < TERRAIN_PREFIX_SIZE; ++byte)
                    if (R8(terrain + byte) != terrains[ti].data[byte]) break;
                if (byte == TERRAIN_PREFIX_SIZE) { terrain_match = &terrains[ti]; break; }
            }
            if (!terrain_match) {
                if (!errors) {
                    fprintf(stderr, "DTERRAIN_DIFF,%s,frame=%u,address=%08x,bytes=", VERSION_NAME, frame, terrain);
                    for (byte = 0; byte < 64; ++byte) fprintf(stderr, "%02x", R8(terrain + byte));
                    fprintf(stderr, "\n");
                }
                error("terrain-prefix-not-authenticated");
            }
            if (level != active_level || (terrain_match && terrain_match->level != active_level)) ++mismatch_calls;
            fprintf(stderr, "DGAME,%s,episode=%u,frame=%u,relative=%u,level=%u,expected=%u,consumed=%08x,next=%08x,area=%08x,areaIndex=%u,terrain=%08x,terrainName=%s,terrainLevel=%u,terrainPrefixBytes=%u,painting=%08x,instant=%08x,mode=%u,mismatch=%u\n",
                    VERSION_NAME, episode, frame, frame - gameplay_origin, level,
                    active_level, consumed_ptr, ptr, area, rdram(area, 1) ? R8(area) : 0,
                    terrain, terrain_match ? terrain_match->name : "NONE", terrain_match ? terrain_match->level : 0,
                    TERRAIN_PREFIX_SIZE, painting, instant, R16(A_PLAY_MODE),
                    level != active_level || (terrain_match && terrain_match->level != active_level));
        }
    } else error("unexpected-breakpoint");
    SetRunState(M64P_DBG_RUNSTATE_RUNNING);
}
static void install(void) {
    m64p_breakpoint b;
    unsigned i, j;
    installed = 1;
    for (i = 0; i < CODE_COUNT; ++i) {
        unsigned h = 2166136261u;
        for (j = 0; j < codes[i].count; ++j) h = (h ^ R32(codes[i].start + j * 4)) * 16777619u;
        if (h != codes[i].hash) { error("loaded-code-does-not-match-retail-elf"); return; }
    }
    if (SetCallbacks(debugger_init, debugger_update, debugger_vi) != M64ERR_SUCCESS) {
        error("debug-callback-installation"); return;
    }
    memset(&b, 0, sizeof(b)); b.flags = M64P_BKP_FLAG_ENABLED | M64P_BKP_FLAG_EXEC;
    b.address = b.endaddr = PC_RUN_DEMO_INPUTS;
    if (BreakpointCommand(M64P_BKP_CMD_ADD_STRUCT, 0, &b) < 0) error("input-breakpoint-installation");
    b.address = b.endaddr = PC_UPDATE_LEVEL;
    if (BreakpointCommand(M64P_BKP_CMD_ADD_STRUCT, 0, &b) < 0) error("gameplay-breakpoint-installation");
    fprintf(stderr, "DINSTALL,%s,frame=%u,codeHashesChecked=%u\n", VERSION_NAME, R32(A_GLOBAL_TIMER), (unsigned)CODE_COUNT);
}
EXPORT m64p_error CALL PluginStartup(m64p_dynlib_handle core, void *ctx, void (*cb)(void *, int, const char *)) {
    (void)ctx; (void)cb;
    R32 = (read32_fn)dlsym(core, "DebugMemRead32");
    R16 = (read16_fn)dlsym(core, "DebugMemRead16");
    R8 = (read8_fn)dlsym(core, "DebugMemRead8");
    SetCallbacks = (ptr_DebugSetCallbacks)dlsym(core, "DebugSetCallbacks");
    SetRunState = (ptr_DebugSetRunState)dlsym(core, "DebugSetRunState");
    BreakpointCommand = (ptr_DebugBreakpointCommand)dlsym(core, "DebugBreakpointCommand");
    return R32 && R16 && R8 && SetCallbacks && SetRunState && BreakpointCommand ? M64ERR_SUCCESS : M64ERR_INCOMPATIBLE;
}
EXPORT m64p_error CALL PluginShutdown(void) { return M64ERR_SUCCESS; }
EXPORT m64p_error CALL PluginGetVersion(m64p_plugin_type *t, int *v, int *a, const char **n, int *c) {
    if (t) *t = M64PLUGIN_INPUT;
    if (v) *v = 0x100;
    if (a) *a = 0x020100;
    if (n) *n = "Demo level/input observer (controller and reads only)";
    if (c) *c = 0;
    return M64ERR_SUCCESS;
}
EXPORT void CALL InitiateControllers(CONTROL_INFO i) {
    int c; for (c = 0; c < 4; ++c) { i.Controls[c].Present = c == 0; i.Controls[c].RawData = 0; i.Controls[c].Plugin = PLUGIN_NONE; i.Controls[c].Type = CONT_TYPE_STANDARD; }
}
EXPORT int CALL RomOpen(void) {
    const char *s = getenv("DEMO_START_AT"), *f = getenv("DEMO_START_FRAMES");
    polls = installed = episode = input_calls = gameplay_calls = mismatch_calls = errors = 0;
    consumed_ptr = 0; had_demo = 0; active_base = active_level = active_size = active_terminal = 0;
    gameplay_origin = UINT32_MAX; start_at = s ? (unsigned)strtoul(s, NULL, 10) : UINT32_MAX;
    active_stream = NULL; previous_ptr = previous_timer = 0;
    start_frames = f ? (unsigned)strtoul(f, NULL, 10) : 1;
    return 1;
}
EXPORT void CALL RomClosed(void) {
    fprintf(stderr, "DSUMMARY,%s,polls=%u,episodes=%u,inputCalls=%u,gameplayCalls=%u,mismatchCalls=%u,errors=%u\n",
            VERSION_NAME, polls, episode, input_calls, gameplay_calls, mismatch_calls, errors);
}
EXPORT void CALL GetKeys(int control, BUTTONS *keys) {
    unsigned frame = R32(A_GLOBAL_TIMER);
    memset(keys, 0, sizeof(*keys)); if (control) return;
    ++polls; if (!installed && polls >= 10) install();
    if (start_at != UINT32_MAX && gameplay_origin != UINT32_MAX
            && frame >= gameplay_origin + start_at
            && frame - gameplay_origin - start_at < start_frames)
        keys->START_BUTTON = 1;
    if (keys->START_BUTTON) fprintf(stderr, "DINPUT,%s,frame=%u,button=START\n", VERSION_NAME, frame);
}
EXPORT void CALL ControllerCommand(int c,unsigned char*p){(void)c;(void)p;}
EXPORT void CALL ReadController(int c,unsigned char*p){(void)c;(void)p;}
EXPORT void CALL SDL_KeyDown(int m,int k){(void)m;(void)k;}
EXPORT void CALL SDL_KeyUp(int m,int k){(void)m;(void)k;}
EXPORT void CALL RenderCallback(void) {}
EXPORT void CALL SendVRUWord(uint16_t l,uint16_t*w,uint8_t n){(void)l;(void)w;(void)n;}
EXPORT void CALL SetMicState(int s){(void)s;}
EXPORT void CALL ReadVRUResults(uint16_t*a,uint16_t*b,uint16_t*c,uint16_t*d,uint16_t*e,uint16_t*f){if(a)*a=0;if(b)*b=0;if(c)*c=0;if(d)*d=0;if(e)*e=0;(void)f;}
EXPORT void CALL ClearVRUWords(uint8_t l){(void)l;}
EXPORT void CALL SetVRUWordMask(uint8_t l,uint8_t*m){(void)l;(void)m;}
