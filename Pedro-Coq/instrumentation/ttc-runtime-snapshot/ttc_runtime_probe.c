#define _GNU_SOURCE
#define M64P_PLUGIN_PROTOTYPES
#include <mupen64plus/m64p_common.h>
#include <mupen64plus/m64p_debugger.h>
#include <mupen64plus/m64p_plugin.h>
#include <dlfcn.h>
#include <stdint.h>
#include <stdio.h>
#include <string.h>

#ifndef VERSION_NAME
#define VERSION_NAME "unknown"
#endif
#ifndef A_GLOBAL_TIMER
#error A_GLOBAL_TIMER is required
#endif
#ifndef A_CURR_LEVEL
#error A_CURR_LEVEL is required
#endif
#ifndef A_CURR_AREA
#error A_CURR_AREA is required
#endif
#ifndef A_MARIO_STATES
#error A_MARIO_STATES is required
#endif
#ifndef A_MARIO_OBJECT
#error A_MARIO_OBJECT is required
#endif
#ifndef A_OBJECT_POOL
#error A_OBJECT_POOL is required
#endif
#ifndef A_OBJECT_LISTS
#error A_OBJECT_LISTS is required
#endif
#ifndef A_FREE_OBJECT_LIST
#error A_FREE_OBJECT_LIST is required
#endif
#ifndef A_TIME_STOP_STATE
#error A_TIME_STOP_STATE is required
#endif
#ifndef A_TTC_SPEED_SETTING
#error A_TTC_SPEED_SETTING is required
#endif
#ifndef A_CURRENT_OBJECT
#error A_CURRENT_OBJECT is required
#endif
#ifndef A_RANDOM_SEED16
#error A_RANDOM_SEED16 is required
#endif
#ifndef PC_RANDOM_U16_ENTRY
#error PC_RANDOM_U16_ENTRY is required
#endif
#ifndef PC_RANDOM_U16_RETURN
#error PC_RANDOM_U16_RETURN is required
#endif

enum {
    LEVEL_TTC = 14,
    OBJECT_COUNT = 240,
    OBJECT_SIZE = 0x260,
    OBJECT_NODE_SIZE = 0x68,
    NUM_OBJECT_LISTS = 13,
    OBJ_LIST_UNIMPORTANT = 12,
    NODE_NEXT = 0x60,
    NODE_PREV = 0x64,
    O_ACTIVE_FLAGS = 0x74,
    O_ACTIVE_PARTICLES = 0xe0,
    O_ACTION = 0x14c,
    O_TIMER = 0x154,
    O_BEHAVIOR = 0x20c,
    M_PARTICLE_FLAGS = 0x08,
    M_ACTION = 0x0c,
    M_POS_X = 0x3c,
    M_POS_Y = 0x40,
    M_POS_Z = 0x44,
    M_FORWARD_VEL = 0x54,
    PARTICLE_DUST = 1,
    ACTIVE_PARTICLE_DUST = 1,
    TIME_STOP_RELEVANT = 0x5a
};

typedef unsigned int (*read32_fn)(unsigned int);
typedef unsigned short (*read16_fn)(unsigned int);

static read32_fn R32;
static read16_fn R16;
static ptr_DebugSetCallbacks DebugSetCallbacksApi;
static ptr_DebugSetRunState DebugSetRunStateApi;
static ptr_DebugGetCPUDataPtr DebugGetCPUDataPtrApi;
static ptr_DebugBreakpointCommand DebugBreakpointCommandApi;
static unsigned long long poll_count;
static uint32_t last_timer;
static uint32_t start_timer;
static int started;
static int emitted;
static int rng_breakpoint_install_attempted;
static int rng_breakpoints_installed;
static int rng_breakpoint_indices[2] = { -1, -1 };
static unsigned rng_call_index;

struct rng_call_context {
    uint32_t timer;
    uint32_t caller;
    uint32_t object;
    uint32_t behavior;
    uint32_t mario_particle_flags;
    uint32_t mario_active_particles;
    int32_t action;
    int32_t object_timer;
    int slot;
    int list;
    uint16_t seed_before;
    uint16_t level;
    uint16_t area;
    uint16_t ttc_speed_setting;
};

static struct rng_call_context pending_rng_call;
static int rng_call_pending;

static float rfloat(uint32_t address) {
    union { uint32_t u; float f; } value;
    value.u = R32(address);
    return value.f;
}

static int pool_slot(uint32_t address) {
    uint32_t delta;
    if (address < A_OBJECT_POOL) return -1;
    delta = address - A_OBJECT_POOL;
    if (delta % OBJECT_SIZE != 0 || delta / OBJECT_SIZE >= OBJECT_COUNT) return -1;
    return (int) (delta / OBJECT_SIZE);
}

static int active_object_list(uint32_t target) {
    uint32_t list_array = R32(A_OBJECT_LISTS);
    int list_index;
    if (pool_slot(target) < 0 || list_array == 0) return -2;
    for (list_index = 0; list_index < NUM_OBJECT_LISTS; ++list_index) {
        uint32_t head = list_array + (uint32_t) list_index * OBJECT_NODE_SIZE;
        uint32_t node = R32(head + NODE_NEXT);
        int steps;
        for (steps = 0; node != head && steps < OBJECT_COUNT; ++steps) {
            if (node == target) return list_index;
            node = R32(node + NODE_NEXT);
        }
        if (node != head) return -2;
    }
    return -1;
}

static void rng_debugger_init(void) {}
static void rng_debugger_vi(void) {}

static uint32_t random_u16_signature_hash(void) {
    uint32_t hash = 2166136261u;
    unsigned word;
    /* Entry through the return instruction's delay slot, inclusive. */
    for (word = 0; word < 65; ++word) {
        hash ^= R32(PC_RANDOM_U16_ENTRY + word * 4);
        hash *= 16777619u;
    }
    return hash;
}

static void rng_debugger_update(unsigned int pc) {
    int64_t *registers =
        (int64_t *) DebugGetCPUDataPtrApi(M64P_CPU_REG_REG);

    if (registers == NULL) {
        fprintf(stderr,
                "TTC_RNG_ERROR,%s,reason=no-register-bank,pc=%08x\n",
                VERSION_NAME, pc);
        DebugSetRunStateApi(M64P_DBG_RUNSTATE_RUNNING);
        return;
    }

    if (pc == PC_RANDOM_U16_ENTRY) {
        uint32_t object = R32(A_CURRENT_OBJECT);
        if (rng_call_pending) {
            fprintf(stderr,
                    "TTC_RNG_ERROR,%s,reason=nested-entry,pc=%08x\n",
                    VERSION_NAME, pc);
        }
        pending_rng_call.timer = R32(A_GLOBAL_TIMER);
        pending_rng_call.caller = (uint32_t) registers[31];
        pending_rng_call.object = object;
        pending_rng_call.slot = pool_slot(object);
        pending_rng_call.list = active_object_list(object);
        pending_rng_call.behavior = object ? R32(object + O_BEHAVIOR) : 0;
        pending_rng_call.mario_particle_flags =
            R32(A_MARIO_STATES + M_PARTICLE_FLAGS);
        pending_rng_call.mario_active_particles = R32(A_MARIO_OBJECT)
            ? R32(R32(A_MARIO_OBJECT) + O_ACTIVE_PARTICLES) : 0;
        pending_rng_call.action = object
            ? (int32_t) R32(object + O_ACTION) : 0;
        pending_rng_call.object_timer = object
            ? (int32_t) R32(object + O_TIMER) : 0;
        pending_rng_call.seed_before = R16(A_RANDOM_SEED16);
        pending_rng_call.level = R16(A_CURR_LEVEL);
        pending_rng_call.area = R16(A_CURR_AREA);
        pending_rng_call.ttc_speed_setting = R16(A_TTC_SPEED_SETTING);
        rng_call_pending = 1;
    } else if (pc == PC_RANDOM_U16_RETURN) {
        if (!rng_call_pending) {
            fprintf(stderr,
                    "TTC_RNG_ERROR,%s,reason=return-without-entry,pc=%08x\n",
                    VERSION_NAME, pc);
        } else if (pending_rng_call.level == LEVEL_TTC
                   && pending_rng_call.area == 1) {
            uint16_t seed_after = R16(A_RANDOM_SEED16);
            fprintf(stderr,
                    "TTC_RNG,%s,call=%u,timer=%u,caller=%08x,"
                    "object=%08x,slot=%d,list=%d,behavior=%08x,action=%d,"
                    "objectTimer=%d,ttcSpeed=%u,seedBefore=%04x,seedAfter=%04x,"
                    "return=%04x,marioParticleFlags=%08x,"
                    "marioActiveParticles=%08x\n",
                    VERSION_NAME, rng_call_index++, pending_rng_call.timer,
                    pending_rng_call.caller, pending_rng_call.object,
                    pending_rng_call.slot, pending_rng_call.list,
                    pending_rng_call.behavior, pending_rng_call.action,
                    pending_rng_call.object_timer,
                    pending_rng_call.ttc_speed_setting,
                    pending_rng_call.seed_before, seed_after,
                    (uint16_t) registers[2],
                    pending_rng_call.mario_particle_flags,
                    pending_rng_call.mario_active_particles);
        }
        rng_call_pending = 0;
    }

    DebugSetRunStateApi(M64P_DBG_RUNSTATE_RUNNING);
}

static int install_rng_breakpoints(void) {
    static const uint32_t addresses[2] = {
        PC_RANDOM_U16_ENTRY,
        PC_RANDOM_U16_RETURN,
    };
    m64p_breakpoint breakpoint;
    int i;

    /* The full 65-word body hash and the independently checked seed accesses
       are common to the hash-pinned US and JP retail ROMs. */
    if (random_u16_signature_hash() != 0x0436edbe
        || R32(PC_RANDOM_U16_ENTRY) != 0x27bdfff8
        || R32(PC_RANDOM_U16_ENTRY + 4) != 0x3c0e8039
        || R32(PC_RANDOM_U16_ENTRY + 8) != 0x95ceeee0
        || R32(PC_RANDOM_U16_ENTRY + 12) != 0x2401560a
        || R32(PC_RANDOM_U16_ENTRY + 0x18) != 0x3c018039
        || R32(PC_RANDOM_U16_ENTRY + 0x1c) != 0xa420eee0
        || R32(PC_RANDOM_U16_ENTRY + 0x20) != 0x3c0f8039
        || R32(PC_RANDOM_U16_ENTRY + 0x24) != 0x95efeee0
        || R32(PC_RANDOM_U16_ENTRY + 0x34) != 0x3c098039
        || R32(PC_RANDOM_U16_ENTRY + 0x38) != 0x9529eee0
        || R32(PC_RANDOM_U16_ENTRY + 0x4c) != 0x3c018039
        || R32(PC_RANDOM_U16_ENTRY + 0x64) != 0xa438eee0
        || R32(PC_RANDOM_U16_ENTRY + 0x6c) != 0x3c0a8039
        || R32(PC_RANDOM_U16_ENTRY + 0x70) != 0x954aeee0
        || R32(PC_RANDOM_U16_ENTRY + 0xb4) != 0x3c018039
        || R32(PC_RANDOM_U16_ENTRY + 0xbc) != 0xa420eee0
        || R32(PC_RANDOM_U16_ENTRY + 0xc4) != 0x3c018039
        || R32(PC_RANDOM_U16_ENTRY + 0xcc) != 0xa429eee0
        || R32(PC_RANDOM_U16_ENTRY + 0xdc) != 0x3c018039
        || R32(PC_RANDOM_U16_ENTRY + 0xe4) != 0xa42ceee0
        || R32(PC_RANDOM_U16_ENTRY + 0xe8) != 0x3c028039
        || R32(PC_RANDOM_U16_ENTRY + 0xec) != 0x10000003
        || R32(PC_RANDOM_U16_ENTRY + 0xf0) != 0x9442eee0
        || R32(PC_RANDOM_U16_ENTRY + 0xf4) != 0x10000001
        || R32(PC_RANDOM_U16_ENTRY + 0xf8) != 0x00000000
        || R32(PC_RANDOM_U16_RETURN) != 0x03e00008
        || R32(PC_RANDOM_U16_RETURN + 4) != 0x27bd0008) {
        fprintf(stderr,
                "TTC_RNG_ERROR,%s,reason=retail-signature-mismatch\n",
                VERSION_NAME);
        return 0;
    }
    if (DebugSetCallbacksApi(rng_debugger_init, rng_debugger_update,
                             rng_debugger_vi) != M64ERR_SUCCESS) {
        fprintf(stderr,
                "TTC_RNG_ERROR,%s,reason=set-callbacks-failed\n",
                VERSION_NAME);
        return 0;
    }

    memset(&breakpoint, 0, sizeof(breakpoint));
    breakpoint.flags = M64P_BKP_FLAG_ENABLED | M64P_BKP_FLAG_EXEC;
    for (i = 0; i < 2; ++i) {
        breakpoint.address = addresses[i];
        breakpoint.endaddr = addresses[i];
        rng_breakpoint_indices[i] = DebugBreakpointCommandApi(
            M64P_BKP_CMD_ADD_STRUCT, 0, &breakpoint);
        if (rng_breakpoint_indices[i] < 0) {
            int added;
            fprintf(stderr,
                    "TTC_RNG_ERROR,%s,reason=add-breakpoint-failed,pc=%08x\n",
                    VERSION_NAME, addresses[i]);
            for (added = 0; added < i; ++added) {
                (void) DebugBreakpointCommandApi(
                    M64P_BKP_CMD_DISABLE,
                    (unsigned int) rng_breakpoint_indices[added], NULL);
            }
            return 0;
        }
    }
    rng_breakpoints_installed = 1;
    fprintf(stderr,
            "TTC_RNG_ARMED,%s,entry=%08x,return=%08x,seed=%08x,ttcSpeedAddress=%08x\n",
            VERSION_NAME, PC_RANDOM_U16_ENTRY, PC_RANDOM_U16_RETURN,
            A_RANDOM_SEED16, A_TTC_SPEED_SETTING);
    return 1;
}

static int mark_slot(unsigned char seen[OBJECT_COUNT], uint32_t address,
                     int expected_active, int list_index, int emit_rows) {
    int slot = pool_slot(address);
    uint16_t active;
    if (slot < 0 || seen[slot]) return 0;
    active = R16(address + O_ACTIVE_FLAGS);
    if (!!active != !!expected_active) return 0;
    seen[slot] = 1;
    if (emit_rows) {
        fprintf(stderr,
                "TTC_OBJECT,%s,slot=%d,list=%d,active=%04x,behavior=%08x,action=%d,timer=%d,next=%08x,prev=%08x\n",
                VERSION_NAME, slot, list_index, active,
                R32(address + O_BEHAVIOR), (int32_t) R32(address + O_ACTION),
                (int32_t) R32(address + O_TIMER), R32(address + NODE_NEXT),
                R32(address + NODE_PREV));
    }
    return 1;
}

static int validate_and_emit_partition(int emit_rows, int *free_count,
                                       int *unimportant_count,
                                       int *active_count) {
    unsigned char seen[OBJECT_COUNT];
    uint32_t list_array = R32(A_OBJECT_LISTS);
    uint32_t node;
    uint32_t previous;
    int total = 0;
    int list_index;
    int steps;
    memset(seen, 0, sizeof(seen));
    *free_count = *unimportant_count = *active_count = 0;
    if (list_array == 0) return 0;

    node = R32(A_FREE_OBJECT_LIST + NODE_NEXT);
    for (steps = 0; node != 0 && steps < OBJECT_COUNT; ++steps) {
        uint32_t next;
        if (!mark_slot(seen, node, 0, -1, emit_rows)) return 0;
        ++*free_count;
        ++total;
        next = R32(node + NODE_NEXT);
        node = next;
    }
    if (node != 0) return 0;

    for (list_index = 0; list_index < NUM_OBJECT_LISTS; ++list_index) {
        uint32_t head = list_array + (uint32_t) list_index * OBJECT_NODE_SIZE;
        node = R32(head + NODE_NEXT);
        previous = head;
        for (steps = 0; node != head && steps < OBJECT_COUNT; ++steps) {
            uint32_t next;
            if (R32(node + NODE_PREV) != previous) return 0;
            if (!mark_slot(seen, node, 1, list_index, emit_rows)) return 0;
            ++*active_count;
            if (list_index == OBJ_LIST_UNIMPORTANT) ++*unimportant_count;
            ++total;
            previous = node;
            next = R32(node + NODE_NEXT);
            node = next;
        }
        if (node != head || R32(head + NODE_PREV) != previous) return 0;
    }
    if (total != OBJECT_COUNT) return 0;
    for (steps = 0; steps < OBJECT_COUNT; ++steps)
        if (!seen[steps]) return 0;
    return 1;
}

static void emit_snapshot(uint32_t timer) {
    uint32_t mario = R32(A_MARIO_OBJECT);
    uint32_t particles = R32(A_MARIO_STATES + M_PARTICLE_FLAGS);
    uint32_t active_particles = R32(mario + O_ACTIVE_PARTICLES);
    uint32_t time_stop = R32(A_TIME_STOP_STATE);
    int free_count;
    int unimportant_count;
    int active_count;
    int valid = validate_and_emit_partition(0, &free_count,
                                            &unimportant_count,
                                            &active_count);
    fprintf(stderr,
            "TTC_SNAPSHOT,%s,timer=%u,level=%u,area=%u,ttcSpeed=%u,mario=%08x,marioSlot=%d,particleFlags=%08x,activeParticles=%08x,timeStop=%08x,free=%d,unimportant=%d,active=%d,reserve=%d,listIntegrity=%d,dustRequest=%d,dustBitClear=%d,normalTime=%d,action=%08x,forwardVel=%.9g,pos=(%.9g;%.9g;%.9g)\n",
            VERSION_NAME, timer, R16(A_CURR_LEVEL), R16(A_CURR_AREA),
            R16(A_TTC_SPEED_SETTING), mario,
            pool_slot(mario), particles, active_particles, time_stop,
            free_count, unimportant_count, active_count,
            free_count + unimportant_count, valid,
            !!(particles & PARTICLE_DUST),
            !(active_particles & ACTIVE_PARTICLE_DUST),
            !(time_stop & TIME_STOP_RELEVANT),
            R32(A_MARIO_STATES + M_ACTION),
            rfloat(A_MARIO_STATES + M_FORWARD_VEL),
            rfloat(A_MARIO_STATES + M_POS_X),
            rfloat(A_MARIO_STATES + M_POS_Y),
            rfloat(A_MARIO_STATES + M_POS_Z));
    if (valid)
        (void) validate_and_emit_partition(1, &free_count,
                                           &unimportant_count,
                                           &active_count);
}

EXPORT m64p_error CALL PluginStartup(m64p_dynlib_handle core, void *context,
                                     void (*debug_callback)(void *, int, const char *)) {
    (void) context; (void) debug_callback;
    R32 = (read32_fn) dlsym(core, "DebugMemRead32");
    R16 = (read16_fn) dlsym(core, "DebugMemRead16");
    DebugSetCallbacksApi = (ptr_DebugSetCallbacks) dlsym(
        core, "DebugSetCallbacks");
    DebugSetRunStateApi = (ptr_DebugSetRunState) dlsym(
        core, "DebugSetRunState");
    DebugGetCPUDataPtrApi = (ptr_DebugGetCPUDataPtr) dlsym(
        core, "DebugGetCPUDataPtr");
    DebugBreakpointCommandApi = (ptr_DebugBreakpointCommand) dlsym(
        core, "DebugBreakpointCommand");
    return R32 && R16 && DebugSetCallbacksApi && DebugSetRunStateApi
        && DebugGetCPUDataPtrApi && DebugBreakpointCommandApi
        ? M64ERR_SUCCESS : M64ERR_INCOMPATIBLE;
}
EXPORT m64p_error CALL PluginShutdown(void) { return M64ERR_SUCCESS; }
EXPORT m64p_error CALL PluginGetVersion(m64p_plugin_type *type, int *version,
                                        int *api_version, const char **name,
                                        int *capabilities) {
    if (type) *type = M64PLUGIN_INPUT;
    if (version) *version = 0x000100;
    if (api_version) *api_version = 0x020100;
    if (name) *name = "TTC runtime snapshot probe";
    if (capabilities) *capabilities = 0;
    return M64ERR_SUCCESS;
}
EXPORT void CALL InitiateControllers(CONTROL_INFO info) {
    int i;
    for (i = 0; i < 4; ++i) {
        info.Controls[i].Present = i == 0;
        info.Controls[i].RawData = 0;
        info.Controls[i].Plugin = PLUGIN_MEMPAK;
        info.Controls[i].Type = CONT_TYPE_STANDARD;
    }
}
EXPORT int CALL RomOpen(void) {
    poll_count = 0; last_timer = UINT32_MAX; start_timer = 0;
    started = emitted = 0;
    rng_breakpoint_install_attempted = rng_breakpoints_installed = 0;
    rng_call_index = 0;
    rng_call_pending = 0;
    rng_breakpoint_indices[0] = rng_breakpoint_indices[1] = -1;
    return 1;
}
EXPORT void CALL RomClosed(void) {
    int i;
    if (!rng_breakpoints_installed) return;
    for (i = 0; i < 2; ++i) {
        if (rng_breakpoint_indices[i] >= 0) {
            (void) DebugBreakpointCommandApi(
                M64P_BKP_CMD_DISABLE,
                (unsigned int) rng_breakpoint_indices[i], NULL);
        }
    }
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

EXPORT void CALL GetKeys(int control, BUTTONS *keys) {
    unsigned long long slot;
    uint32_t timer;
    unsigned rel;
    memset(keys, 0, sizeof(*keys));
    if (control != 0) return;
    ++poll_count;
    if (poll_count >= 150 && poll_count < 156) keys->START_BUTTON = 1;
    for (slot = 220; slot <= 340; slot += 10)
        if (poll_count >= slot && poll_count < slot + 2) keys->D_DPAD = 1;
    if (poll_count >= 380 && poll_count < 386) keys->START_BUTTON = 1;

    if (R16(A_CURR_LEVEL) != LEVEL_TTC || R16(A_CURR_AREA) != 1 ||
        R32(A_MARIO_OBJECT) == 0) return;
    if (!rng_breakpoint_install_attempted) {
        rng_breakpoint_install_attempted = 1;
        (void) install_rng_breakpoints();
    }
    timer = R32(A_GLOBAL_TIMER);
    if (!started) { started = 1; start_timer = timer; last_timer = UINT32_MAX; }
    rel = timer - start_timer;

    if (rel >= 15 && rel < 180) keys->Y_AXIS = 127;
    if ((rel >= 35 && rel < 38) || (rel >= 90 && rel < 93) ||
        (rel >= 145 && rel < 148)) keys->A_BUTTON = 1;

    if (timer != last_timer) {
        last_timer = timer;
        fprintf(stderr,
                "TTC_FRAME,%s,rel=%u,timer=%u,ttcSpeed=%u,action=%08x,particles=%08x,activeParticles=%08x,timeStop=%08x,forwardVel=%.9g,pos=(%.9g;%.9g;%.9g)\n",
                VERSION_NAME, rel, timer, R16(A_TTC_SPEED_SETTING),
                R32(A_MARIO_STATES + M_ACTION),
                R32(A_MARIO_STATES + M_PARTICLE_FLAGS),
                R32(R32(A_MARIO_OBJECT) + O_ACTIVE_PARTICLES),
                R32(A_TIME_STOP_STATE),
                rfloat(A_MARIO_STATES + M_FORWARD_VEL),
                rfloat(A_MARIO_STATES + M_POS_X),
                rfloat(A_MARIO_STATES + M_POS_Y),
                rfloat(A_MARIO_STATES + M_POS_Z));
        if (!emitted && (R32(A_MARIO_STATES + M_PARTICLE_FLAGS) & PARTICLE_DUST)) {
            emitted = 1;
            emit_snapshot(timer);
        }
    }
}
