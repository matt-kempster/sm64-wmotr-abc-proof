#define _GNU_SOURCE
#define M64P_PLUGIN_PROTOTYPES
#include <mupen64plus/m64p_common.h>
#include <mupen64plus/m64p_debugger.h>
#include <mupen64plus/m64p_plugin.h>
#include <dlfcn.h>
#include <math.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "addresses.h"

/* Observation only. The only game-facing output is ordinary controller input.
   Offsets below are the pinned US/JP include/types.h and struct Object layout. */
typedef unsigned int (*read32_fn)(unsigned int);
typedef unsigned short (*read16_fn)(unsigned int);
static read32_fn R32;
static read16_fn R16;
static uint32_t start_timer, last_timer;
static unsigned long long polls;
static int started;
struct input_interval { unsigned first, last; int x, y; char buttons[32]; };
static struct input_interval intervals[512];
static unsigned interval_count;
struct waypoint {
    unsigned first, last;
    float x, z;
    int magnitude;
    char space[16];
    float stop_distance;
};
static struct waypoint waypoints[128];
static unsigned waypoint_count;
static ptr_DebugSetCallbacks SetCallbacks;
static ptr_DebugSetRunState SetRunState;
static ptr_DebugGetCPUDataPtr GetCPUData;
static ptr_DebugBreakpointCommand BreakpointCommand;
static int trace_calls, trace_path, trace_installed, rng_pending, air_pending;
static unsigned rng_index, air_index, path_index;
static uint32_t rng_caller, rng_object, rng_behavior;
static uint16_t rng_before;
static uint32_t air_action, air_floor, air_input, air_arg;
static float air_x, air_y, air_z, air_floor_height;
static float air_intended_x, air_intended_y, air_intended_z;
static uint32_t lower_cog, upper_cog;

static float rf(uint32_t address) {
    uint32_t bits = R32(address);
    float value;
    memcpy(&value, &bits, sizeof(value));
    return value;
}

static int valid_surface(uint32_t surface) {
    return surface >= 0x80000000u && surface <= 0x807fffd0u
        && (surface & 3u) == 0;
}

static uint32_t surface_owner(uint32_t surface) {
    return valid_surface(surface) ? R32(surface + 0x2c) : 0;
}

static int valid_object(uint32_t object) {
    return object >= A_OBJECT_POOL && object < A_OBJECT_POOL + 240 * 0x260
        && (object - A_OBJECT_POOL) % 0x260 == 0;
}

static void describe_surface(const char *scope, unsigned seq, uint32_t surface) {
    unsigned i;
    if (!trace_path) return;
    fprintf(stderr, "CSURFACE,%s,rel=%u,scope=%s,seq=%u,surface=%08x,owner=%08x,valid=%u",
            VERSION_NAME, R32(A_GLOBAL_TIMER) - start_timer, scope, seq, surface,
            surface_owner(surface), valid_surface(surface));
    if (valid_surface(surface)) {
        fprintf(stderr, ",type=%d,flagsRoom=%u,nx=%.9g,ny=%.9g,nz=%.9g,offset=%.9g",
                (int16_t) R16(surface), R16(surface + 4), rf(surface + 0x1c),
                rf(surface + 0x20), rf(surface + 0x24), rf(surface + 0x28));
        for (i = 0; i < 3; ++i)
            fprintf(stderr, ",x%u=%d,y%u=%d,z%u=%d", i + 1,
                    (int16_t) R16(surface + 0x0a + i * 6), i + 1,
                    (int16_t) R16(surface + 0x0c + i * 6), i + 1,
                    (int16_t) R16(surface + 0x0e + i * 6));
    }
    fprintf(stderr, "\n");
}

static int observe_path(uint32_t pc, const int64_t *registers) {
    unsigned i;
    uint32_t m = A_MARIO_STATES;
    if (!trace_path) return 0;
    for (i = 0; i < sizeof(path_points) / sizeof(path_points[0]); ++i) {
        const struct path_point *point = &path_points[i];
        uint32_t floor, ceil, mario_object = R32(A_MARIO_OBJECT);
        if (pc != point->pc) continue;
        floor = R32(m + 0x68); ceil = R32(m + 0x64);
        fprintf(stderr, "CPATH,%s,seq=%u,rel=%u,timer=%u,routine=%s,phase=%s,"
                "action=%08x,prevAction=%08x,actionState=%u,actionTimer=%u,input=%04x,"
                "particles=%08x,active=%08x,speed=%.9g,vy=%.9g,x=%.9g,y=%.9g,z=%.9g,"
                "floor=%08x,floorOwner=%08x,floorHeight=%.9g,"
                "ceil=%08x,ceilOwner=%08x,ceilHeight=%.9g,platform=%08x",
                VERSION_NAME, path_index, R32(A_GLOBAL_TIMER) - start_timer,
                R32(A_GLOBAL_TIMER), point->routine, point->leaving ? "exit" : "enter",
                R32(m + 0x0c), R32(m + 0x10), R16(m + 0x18), R16(m + 0x1a), R16(m + 2),
                R32(m + 8), valid_object(mario_object) ? R32(mario_object + 0xe0) : 0,
                rf(m + 0x54), rf(m + 0x4c),
                rf(m + 0x3c), rf(m + 0x40), rf(m + 0x44), floor, surface_owner(floor),
                rf(m + 0x70), ceil, surface_owner(ceil), rf(m + 0x6c), R32(A_MARIO_PLATFORM));
        if (lower_cog && upper_cog)
            fprintf(stderr, ",lowerYaw=%d,lowerSpeed=%.9g,lowerTarget=%.9g,"
                    "upperYaw=%d,upperSpeed=%.9g,upperTarget=%.9g",
                    (int32_t) R32(lower_cog + 212), rf(lower_cog + 248), rf(lower_cog + 252),
                    (int32_t) R32(upper_cog + 212), rf(upper_cog + 248), rf(upper_cog + 252));
        if (point->returns_value)
            fprintf(stderr, ",result=%08x", (uint32_t) registers[2]);
        if (!point->leaving && strcmp(point->routine, "set_mario_action") == 0)
            fprintf(stderr, ",requestedAction=%08x,requestedArg=%u",
                    (uint32_t) registers[5], (uint32_t) registers[6]);
        if (!point->leaving && strcmp(point->routine, "spawn_particle") == 0)
            fprintf(stderr, ",requestedActive=%08x,requestedModel=%d",
                    (uint32_t) registers[4], (int16_t) registers[5]);
        fprintf(stderr, "\n");
        if (point->leaving && strcmp(point->routine, "update_mario_geometry_inputs") == 0) {
            describe_surface("geometryFloor", path_index, floor);
            describe_surface("geometryCeil", path_index, ceil);
        }
        ++path_index;
        return 1;
    }
    return 0;
}

static uint16_t camera_yaw(void) {
    uint32_t area = R32(A_MARIO_STATES + 0x90);
    uint32_t camera = R32(area + 0x24);
    return R16(camera + 2);
}

static void debugger_init(void) {}
static void debugger_vi(void) {}

static void debugger_update(unsigned int pc) {
    const int64_t *registers = (const int64_t *) GetCPUData(M64P_CPU_REG_REG);
    uint32_t timer = R32(A_GLOBAL_TIMER), m = A_MARIO_STATES;
    if (!registers) {
        fprintf(stderr, "COG_ERROR,reason=missing-register-observation\n");
        SetRunState(M64P_DBG_RUNSTATE_RUNNING);
        return;
    }
    if (pc == A_RANDOM_U16) {
        if (rng_pending) fprintf(stderr, "COG_ERROR,reason=nested-rng-call\n");
        rng_pending = 1;
        rng_before = R16(A_RANDOM_SEED16);
        rng_caller = (uint32_t) registers[31];
        rng_object = R32(A_CURRENT_OBJECT);
        rng_behavior = valid_object(rng_object) ? R32(rng_object + 0x20c) : 0;
    } else if (pc == PC_RNG_EXIT) {
        if (!rng_pending) fprintf(stderr, "COG_ERROR,reason=unpaired-rng-return\n");
        else fprintf(stderr, "CRNG,%s,seq=%u,rel=%u,timer=%u,caller=%08x,"
            "object=%08x,behavior=%08x,before=%u,after=%u,result=%u,particles=%08x\n",
            VERSION_NAME, rng_index++, timer - start_timer, timer, rng_caller,
            rng_object, rng_behavior, rng_before, R16(A_RANDOM_SEED16),
            (uint16_t) registers[2], R32(m + 8));
        rng_pending = 0;
    } else if (pc == PC_AIR_ENTRY) {
        if (air_pending || (uint32_t) registers[4] != m)
            fprintf(stderr, "COG_ERROR,reason=unexpected-air-entry\n");
        air_pending = 1;
        air_action = R32(m + 0x0c); air_floor = R32(m + 0x68);
        air_input = R16(m + 2); air_arg = (uint32_t) registers[6];
        air_x = rf(m + 0x3c); air_y = rf(m + 0x40); air_z = rf(m + 0x44);
        air_floor_height = rf(m + 0x70);
        air_intended_x = rf((uint32_t) registers[5]);
        air_intended_y = rf((uint32_t) registers[5] + 4);
        air_intended_z = rf((uint32_t) registers[5] + 8);
        describe_surface("airOldFloor", air_index, air_floor);
    } else if (pc == PC_AIR_EXIT) {
        uint32_t sp = (uint32_t) registers[29];
        uint32_t floor = R32(sp + 0x30), ceil = R32(sp + 0x34);
        float floor_height = rf(sp + 0x28), ceil_height = rf(sp + 0x2c);
        float qx = rf(sp + 0x40), qy = rf(sp + 0x44), qz = rf(sp + 0x48);
        if (!air_pending) fprintf(stderr, "COG_ERROR,reason=unpaired-air-return\n");
        else fprintf(stderr, "CAIR,%s,seq=%u,rel=%u,timer=%u,action=%08x,"
            "input=%04x,stepArg=%u,oldX=%.9g,oldY=%.9g,oldZ=%.9g,"
            "oldFloor=%08x,oldFloorHeight=%.9g,qx=%.9g,qy=%.9g,qz=%.9g,"
            "floor=%08x,floorOwner=%08x,floorHeight=%.9g,"
            "ceil=%08x,ceilOwner=%08x,ceilHeight=%.9g,result=%d,"
            "newX=%.9g,newY=%.9g,newZ=%.9g,newFloor=%08x,"
            "speed=%.9g,vy=%.9g,pedroCandidate=%u,ix=%.9g,iy=%.9g,iz=%.9g\n",
            VERSION_NAME, air_index++, timer - start_timer, timer,
            air_action, air_input, air_arg, air_x, air_y, air_z,
            air_floor, air_floor_height, qx, qy, qz, floor, surface_owner(floor),
            floor_height, ceil, surface_owner(ceil), ceil_height,
            (int32_t) registers[2], rf(m + 0x3c), rf(m + 0x40), rf(m + 0x44),
            R32(m + 0x68), rf(m + 0x54), rf(m + 0x4c),
            floor != 0 && qy <= floor_height && ceil_height - floor_height <= 160.0f,
            air_intended_x, air_intended_y, air_intended_z);
        describe_surface("airFloor", air_index - 1, floor);
        describe_surface("airCeil", air_index - 1, ceil);
        air_pending = 0;
    } else if (!observe_path(pc, registers)) {
        fprintf(stderr, "COG_ERROR,reason=unexpected-debug-stop,pc=%08x\n", pc);
    }
    SetRunState(M64P_DBG_RUNSTATE_RUNNING);
}

static uint32_t observed_code_hash(uint32_t start, unsigned count) {
    uint32_t hash = 2166136261u;
    unsigned i;
    for (i = 0; i < count; ++i) { hash ^= R32(start + i * 4); hash *= 16777619u; }
    return hash;
}

static void install_trace(void) {
    const uint32_t addresses[] = {A_RANDOM_U16, PC_RNG_EXIT, PC_AIR_ENTRY, PC_AIR_EXIT};
    m64p_breakpoint breakpoint;
    unsigned i;
    trace_installed = 1;
    if (observed_code_hash(A_RANDOM_U16, RNG_WORD_COUNT) != RNG_CODE_HASH
        || observed_code_hash(PC_AIR_ENTRY, AIR_WORD_COUNT) != AIR_CODE_HASH) {
        fprintf(stderr, "COG_ERROR,reason=loaded-code-does-not-match-test-elf\n");
        return;
    }
    if (trace_path) for (i = 0; i < sizeof(path_codes) / sizeof(path_codes[0]); ++i)
        if (observed_code_hash(path_codes[i].start, path_codes[i].count) != path_codes[i].hash) {
            fprintf(stderr, "COG_ERROR,reason=path-code-does-not-match-test-elf\n");
            return;
        }
    if (SetCallbacks(debugger_init, debugger_update, debugger_vi) != M64ERR_SUCCESS) {
        fprintf(stderr, "COG_ERROR,reason=debug-callback-installation\n");
        return;
    }
    memset(&breakpoint, 0, sizeof(breakpoint));
    breakpoint.flags = M64P_BKP_FLAG_ENABLED | M64P_BKP_FLAG_EXEC;
    for (i = 0; i < sizeof(addresses) / sizeof(addresses[0]); ++i) {
        breakpoint.address = addresses[i]; breakpoint.endaddr = addresses[i];
        if (BreakpointCommand(M64P_BKP_CMD_ADD_STRUCT, 0, &breakpoint) < 0)
            fprintf(stderr, "COG_ERROR,reason=debug-breakpoint-installation\n");
    }
    if (trace_path) for (i = 0; i < sizeof(path_points) / sizeof(path_points[0]); ++i) {
        breakpoint.address = path_points[i].pc; breakpoint.endaddr = path_points[i].pc;
        if (BreakpointCommand(M64P_BKP_CMD_ADD_STRUCT, 0, &breakpoint) < 0)
            fprintf(stderr, "COG_ERROR,reason=path-breakpoint-installation\n");
    }
}

static void snapshot(unsigned rel, uint32_t timer) {
    uint32_t m = A_MARIO_STATES;
    uint32_t mo = R32(A_MARIO_OBJECT);
    uint32_t floor = R32(m + 0x68), ceil = R32(m + 0x64);
    uint32_t wall = R32(m + 0x60);
    uint32_t cog_behavior = (R32(A_SEGMENT_TABLE + (BHV_TTC_COG >> 24) * 4)
        + (BHV_TTC_COG & 0x00ffffffu)) | 0x80000000u;
    unsigned slot, count = 0;
    fprintf(stderr,
        "CFRAME,%s,rel=%u,timer=%u,mode=%u,action=%08x,prevAction=%08x,"
        "actionState=%u,actionTimer=%u,input=%04x,particles=%08x,active=%08x,"
        "speed=%.9g,x=%.9g,y=%.9g,z=%.9g,vx=%.9g,vy=%.9g,vz=%.9g,"
        "yaw=%u,intendedYaw=%u,intendedMag=%.9g,cameraYaw=%u,"
        "floor=%08x,floorOwner=%08x,floorHeight=%.9g,"
        "floorType=%d,floorForce=%d,floorNX=%.9g,floorNY=%.9g,floorNZ=%.9g,"
        "ceil=%08x,ceilOwner=%08x,ceilHeight=%.9g,seed=%u,timeStop=%08x\n",
        VERSION_NAME, rel, timer, R16(A_TTC_SPEED_SETTING),
        R32(m + 0x0c), R32(m + 0x10), R16(m + 0x18), R16(m + 0x1a),
        R16(m + 2), R32(m + 8), R32(mo + 0xe0), rf(m + 0x54),
        rf(m + 0x3c), rf(m + 0x40), rf(m + 0x44),
        rf(m + 0x48), rf(m + 0x4c), rf(m + 0x50),
        R16(m + 0x2e), R16(m + 0x24), rf(m + 0x20), camera_yaw(),
        floor, surface_owner(floor), rf(m + 0x70),
        valid_surface(floor) ? (int16_t) R16(floor) : -1,
        valid_surface(floor) ? (int16_t) R16(floor + 2) : 0,
        valid_surface(floor) ? rf(floor + 0x1c) : 0.0f,
        valid_surface(floor) ? rf(floor + 0x20) : 0.0f,
        valid_surface(floor) ? rf(floor + 0x24) : 0.0f,
        ceil, surface_owner(ceil), rf(m + 0x6c), R16(A_RANDOM_SEED16),
        R32(A_TIME_STOP_STATE));
    for (slot = 0; slot < 240; ++slot) {
        uint32_t object = A_OBJECT_POOL + slot * 0x260;
        if (!R16(object + 0x74) || R32(object + 0x20c) != cog_behavior) continue;
        ++count;
        if (rf(object + 0xa0) == 1490 && rf(object + 0xa4) == -2088
                && rf(object + 0xa8) == -873) lower_cog = object;
        if (rf(object + 0xa0) == 1215 && rf(object + 0xa4) == -1781
                && rf(object + 0xa8) == -1215) upper_cog = object;
        fprintf(stderr,
            "CCOG,%s,rel=%u,slot=%u,object=%08x,x=%.9g,y=%.9g,z=%.9g,"
            "yaw=%d,angleVel=%d,speed=%.9g,target=%.9g,dir=%.9g\n",
            VERSION_NAME, rel, slot, object, rf(object + 0xa0),
            rf(object + 0xa4), rf(object + 0xa8), (int32_t) R32(object + 212),
            (int32_t) R32(object + 280), rf(object + 248), rf(object + 252),
            rf(object + 244));
    }
    if (count != 8)
        fprintf(stderr, "COG_ERROR,%s,rel=%u,reason=cog-count,count=%u\n",
                VERSION_NAME, rel, count);
    if (valid_surface(wall)) {
        fprintf(stderr, "CWALL,%s,rel=%u,surface=%08x,owner=%08x,type=%d,"
            "x1=%d,y1=%d,z1=%d,x2=%d,y2=%d,z2=%d,x3=%d,y3=%d,z3=%d\n",
            VERSION_NAME, rel, wall, surface_owner(wall), (int16_t) R16(wall),
            (int16_t) R16(wall + 0x0a), (int16_t) R16(wall + 0x0c),
            (int16_t) R16(wall + 0x0e), (int16_t) R16(wall + 0x10),
            (int16_t) R16(wall + 0x12), (int16_t) R16(wall + 0x14),
            (int16_t) R16(wall + 0x16), (int16_t) R16(wall + 0x18),
            (int16_t) R16(wall + 0x1a));
    }
}

EXPORT m64p_error CALL PluginStartup(m64p_dynlib_handle core, void *context,
    void (*debug_callback)(void *, int, const char *)) {
    (void) context; (void) debug_callback;
    R32 = (read32_fn) dlsym(core, "DebugMemRead32");
    R16 = (read16_fn) dlsym(core, "DebugMemRead16");
    SetCallbacks = (ptr_DebugSetCallbacks) dlsym(core, "DebugSetCallbacks");
    SetRunState = (ptr_DebugSetRunState) dlsym(core, "DebugSetRunState");
    GetCPUData = (ptr_DebugGetCPUDataPtr) dlsym(core, "DebugGetCPUDataPtr");
    BreakpointCommand = (ptr_DebugBreakpointCommand) dlsym(core, "DebugBreakpointCommand");
    return R32 && R16 && SetCallbacks && SetRunState && GetCPUData && BreakpointCommand
        ? M64ERR_SUCCESS : M64ERR_INCOMPATIBLE;
}
EXPORT m64p_error CALL PluginShutdown(void) { return M64ERR_SUCCESS; }
EXPORT m64p_error CALL PluginGetVersion(m64p_plugin_type *type, int *version,
    int *api_version, const char **name, int *capabilities) {
    if (type) *type = M64PLUGIN_INPUT;
    if (version) *version = 0x000100;
    if (api_version) *api_version = 0x020100;
    if (name) *name = "TTC cog placement observer (controller and reads only)";
    if (capabilities) *capabilities = 0;
    return M64ERR_SUCCESS;
}
EXPORT void CALL InitiateControllers(CONTROL_INFO info) {
    int i;
    for (i = 0; i < 4; ++i) {
        info.Controls[i].Present = i == 0;
        info.Controls[i].RawData = 0;
        info.Controls[i].Plugin = PLUGIN_NONE;
        info.Controls[i].Type = CONT_TYPE_STANDARD;
    }
}
EXPORT int CALL RomOpen(void) {
    const char *path = getenv("COG_INPUT_FILE");
    FILE *input;
    char line[160];
    polls = 0; started = 0; start_timer = 0; last_timer = UINT32_MAX;
    interval_count = 0; waypoint_count = 0;
    trace_calls = getenv("COG_TRACE_CALLS") != NULL;
    trace_path = getenv("COG_TRACE_PATH") != NULL;
    trace_installed = rng_pending = air_pending = 0;
    rng_index = air_index = path_index = 0;
    lower_cog = upper_cog = 0;
    if (!path) return 1;
    input = fopen(path, "r");
    if (!input) return 0;
    while (fgets(line, sizeof(line), input)) {
        struct input_interval row;
        if (line[0] == '#' || line[0] == '\n') continue;
        if (sscanf(line, "%u,%u,%d,%d,%31s", &row.first, &row.last,
                   &row.x, &row.y, row.buttons) != 5 || row.last < row.first
            || row.x < -80 || row.x > 80 || row.y < -80 || row.y > 80
            || interval_count == 512
            || (interval_count && row.first <= intervals[interval_count - 1].last)) {
            fprintf(stderr, "COG_ERROR,reason=invalid-controller-interval\n");
            fclose(input);
            return 0;
        }
        intervals[interval_count++] = row;
    }
    fclose(input);
    path = getenv("COG_WAYPOINT_FILE");
    if (!path) return 1;
    input = fopen(path, "r");
    if (!input) return 0;
    while (fgets(line, sizeof(line), input)) {
        struct waypoint row = {0};
        int columns;
        strcpy(row.space, "world");
        row.stop_distance = 20.0f;
        if (line[0] == '#' || line[0] == '\n') continue;
        columns = sscanf(line, "%u,%u,%f,%f,%d,%15[^,],%f", &row.first, &row.last,
                         &row.x, &row.z, &row.magnitude, row.space, &row.stop_distance);
        if ((columns != 5 && columns != 7)
            || row.last < row.first || !isfinite(row.x) || !isfinite(row.z)
            || (strcmp(row.space, "world") && strcmp(row.space, "cog") && strcmp(row.space, "cog_brake"))
            || !isfinite(row.stop_distance) || row.stop_distance < 0 || row.stop_distance > 20
            || row.magnitude < 0 || row.magnitude > 80 || waypoint_count == 128
            || (waypoint_count && row.first <= waypoints[waypoint_count - 1].last)) {
            fprintf(stderr, "COG_ERROR,reason=invalid-controller-waypoint\n");
            fclose(input);
            return 0;
        }
        waypoints[waypoint_count++] = row;
    }
    fclose(input);
    return 1;
}
EXPORT void CALL RomClosed(void) {}
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
    uint32_t timer;
    unsigned rel, i;
    memset(keys, 0, sizeof(*keys));
    if (control != 0) return;
    ++polls;
    if (R16(A_CURR_LEVEL) != 14 || R16(A_CURR_AREA) != 1
        || R32(A_MARIO_OBJECT) == 0 || R32(A_MARIO_STATES + 0x0c) == 0) {
        /* Ordinary title/file/star menu inputs; no debug level select. */
        if (polls >= 150 && polls < 156) keys->START_BUTTON = 1;
        if (polls >= 240 && polls % 60 < 3) keys->A_BUTTON = 1;
        return;
    }
    timer = R32(A_GLOBAL_TIMER);
    if (!started) { started = 1; start_timer = timer; }
    if (trace_calls && !trace_installed) install_trace();
    rel = timer - start_timer;
    for (i = 0; i < interval_count; ++i) {
        const struct input_interval *row = &intervals[i];
        if (rel < row->first || rel > row->last) continue;
        keys->X_AXIS = row->x; keys->Y_AXIS = row->y;
        if (strchr(row->buttons, 'A')) keys->A_BUTTON = 1;
        if (strchr(row->buttons, 'B')) keys->B_BUTTON = 1;
        if (strchr(row->buttons, 'Z')) keys->Z_TRIG = 1;
        if (strchr(row->buttons, 'R')) keys->R_TRIG = 1;
        if (strchr(row->buttons, 'L')) keys->L_TRIG = 1;
        break;
    }
    /* Optional controller steering, never a position store. CINPUT records
       the actual stick values so a successful trial can be replayed directly. */
    for (i = 0; i < waypoint_count; ++i) {
        const struct waypoint *row = &waypoints[i];
        double dx, dz, distance, angle, magnitude, target_x = row->x, target_z = row->z;
        if (rel < row->first || rel > row->last) continue;
        if (strcmp(row->space, "world") != 0) {
            double rotation;
            if (!lower_cog) {
                fprintf(stderr, "COG_ERROR,reason=missing-cog-for-controller-target\n");
                break;
            }
            /* This rotating target is only a controller steering aid. The
               recorded integer inputs must be replayed without this policy. */
            rotation = (uint16_t) R32(lower_cog + 212) * (6.283185307179586 / 65536.0);
            target_x = rf(lower_cog + 0xa0) + cos(rotation) * row->x + sin(rotation) * row->z;
            target_z = rf(lower_cog + 0xa8) - sin(rotation) * row->x + cos(rotation) * row->z;
        }
        dx = target_x - rf(A_MARIO_STATES + 0x3c);
        dz = target_z - rf(A_MARIO_STATES + 0x44);
        distance = hypot(dx, dz);
        angle = atan2(dx, dz) - camera_yaw() * (6.283185307179586 / 65536.0);
        magnitude = distance < row->stop_distance ? 0.0 : fmin(row->magnitude, 20.0 + distance / 2.0);
        if (strcmp(row->space, "cog_brake") == 0 && distance > 0.0
                && !(R32(A_MARIO_STATES + 0x0c) & 0x800u)) {
            /* Discovery-only coasting heuristic. It chooses neutral input;
               neither this estimate nor its target is a game-state update. */
            double closing = fmax(0.0, (rf(A_MARIO_STATES + 0x48) * dx
                                        + rf(A_MARIO_STATES + 0x50) * dz) / distance);
            if (distance <= closing * (closing + 1.0) / 2.0 + row->stop_distance)
                magnitude = 0.0;
        }
        keys->X_AXIS = (int) lround(magnitude * sin(angle));
        keys->Y_AXIS = (int) lround(-magnitude * cos(angle));
        break;
    }
    if (timer != last_timer) {
        last_timer = timer;
        fprintf(stderr, "CINPUT,%s,rel=%u,x=%d,y=%d,A=%u,B=%u,Z=%u,R=%u,L=%u\n",
                VERSION_NAME, rel, keys->X_AXIS, keys->Y_AXIS, keys->A_BUTTON,
                keys->B_BUTTON, keys->Z_TRIG, keys->R_TRIG, keys->L_TRIG);
        snapshot(rel, timer);
    }
}
