#define _GNU_SOURCE
#define M64P_PLUGIN_PROTOTYPES
#include <mupen64plus/m64p_common.h>
#include <mupen64plus/m64p_debugger.h>
#include <mupen64plus/m64p_plugin.h>
#include <dlfcn.h>
#include <stdint.h>
#include <stdio.h>
#include <string.h>

#ifndef VERSION_JP
#define VERSION_JP 0
#endif
#ifndef PRE_ACTION_TIMER
#define PRE_ACTION_TIMER 3
#endif
#ifndef TRACE_NEXT_FRAME
#define TRACE_NEXT_FRAME 0
#endif

#if VERSION_JP
enum {
    A_GLOBAL_TIMER = 0x8032c694,
    A_CURR_LEVEL = 0x8032ce98,
    A_MARIO_PLATFORM = 0x8032fed4,
    A_MARIO_STATES = 0x80339e00,
    A_CURR_AREA = 0x8033a75a,
    A_MARIO_OBJECT = 0x8035fde8,
};
#else
enum {
    A_GLOBAL_TIMER = 0x8032d5d4,
    A_CURR_LEVEL = 0x8032ddf8,
    A_MARIO_PLATFORM = 0x80330e14,
    A_MARIO_STATES = 0x8033b170,
    A_CURR_AREA = 0x8033baca,
    A_MARIO_OBJECT = 0x80361158,
};
#endif

enum {
    M_INPUT = 0x02,
    M_ACTION = 0x0c,
    M_PREV_ACTION = 0x10,
    M_ACTION_STATE = 0x18,
    M_ACTION_TIMER = 0x1a,
    M_ACTION_ARG = 0x1c,
    M_INTENDED_MAG = 0x20,
    M_FACE_PITCH = 0x2c,
    M_FACE_YAW = 0x2e,
    M_FACE_ROLL = 0x30,
    M_SLIDE_YAW = 0x38,
    M_POS_X = 0x3c,
    M_POS_Y = 0x40,
    M_POS_Z = 0x44,
    M_VEL_X = 0x48,
    M_VEL_Y = 0x4c,
    M_VEL_Z = 0x50,
    M_FORWARD_VEL = 0x54,
    M_SLIDE_VEL_X = 0x58,
    M_SLIDE_VEL_Z = 0x5c,
    M_WALL = 0x60,
    M_CEIL = 0x64,
    M_FLOOR = 0x68,
    M_CEIL_HEIGHT = 0x6c,
    M_FLOOR_HEIGHT = 0x70,
    M_FLOOR_ANGLE = 0x74,
    M_MARIO_OBJECT = 0x88,
    M_CONTROLLER = 0x9c,
    M_COLLIDED_INTERACT_TYPES = 0xa4,
    M_QUICKSAND_DEPTH = 0xc0,
};

enum {
    O_GFX_POS_X = 0x20,
    O_GFX_POS_Y = 0x24,
    O_GFX_POS_Z = 0x28,
    O_COLLIDED_INTERACT_TYPES = 0x70,
    O_NUM_COLLIDED_OBJECTS = 0x76,
    O_POS_X = 0xa0,
    O_POS_Y = 0xa4,
    O_POS_Z = 0xa8,
    O_VEL_Y = 0xb0,
};

enum {
    S_TYPE = 0x00,
    S_FORCE = 0x02,
    S_FLAGS = 0x04,
    S_VERTEX1 = 0x0a,
    S_VERTEX2 = 0x10,
    S_VERTEX3 = 0x16,
    S_NORMAL_X = 0x1c,
    S_NORMAL_Y = 0x20,
    S_NORMAL_Z = 0x24,
    S_ORIGIN_OFFSET = 0x28,
    S_OBJECT = 0x2c,
    C_BUTTON_DOWN = 0x10,
    C_BUTTON_PRESSED = 0x12,
};

enum {
    LEVEL_SSL = 8,
    ACT_IDLE = 0x0c400201,
    ACT_LONG_JUMP_LAND = 0x00000479,
    INPUT_A_PRESSED = 0x0002,
    INPUT_A_DOWN = 0x0080,
};

typedef unsigned int (*read32_fn)(unsigned int);
typedef unsigned short (*read16_fn)(unsigned int);
typedef unsigned char (*read8_fn)(unsigned int);
typedef void (*write32_fn)(unsigned int, unsigned int);
typedef void (*write16_fn)(unsigned int, unsigned short);

static read32_fn R32;
static read16_fn R16;
static read8_fn R8;
static write32_fn W32;
static write16_fn W16;
static ptr_DebugSetCallbacks DebugSetCallbacksApi;
static ptr_DebugSetRunState DebugSetRunStateApi;
static ptr_DebugGetCPUDataPtr DebugGetCPUDataPtrApi;
static ptr_DebugBreakpointCommand DebugBreakpointCommandApi;

static unsigned long long gPoll;
static uint32_t gLastSetupTimer;
static uint32_t gArmTimer;
static int gSetupFrames;
static int gArmed;
static int gDone;
static int gAPressedPolls;
static int gADownPolls;
static int gQstepBreakpointsInstalled;
static int gQstepLowerWallHits;
static int gQstepUpperWallHits;
static int gQstepFloorHits;
static int gQstepCeilHits;
static int gQstepCommitHits;
static int gTraceFrame;
static int gFrameCommitHits;
static int gQstepBreakpointIndices[5];

/*
 * These are instruction addresses in the matching retail ROM.  They came
 * from clean builds of decomp revision 36fbf8d693a9fc2bdec0c77402f8e96d07d2f461;
 * the output hashes match sm64.jp.sha1 and sm64.us.sha1.  The helper is the
 * file-local perform_ground_quarter_step (shown in the map as an offset from
 * stationary_ground_step), not a new function inserted into the ROM.
 */
#if VERSION_JP
enum {
    PC_QSTEP_LOWER_WALL_RETURN = 0x80255900,
    PC_QSTEP_UPPER_WALL_RETURN = 0x80255914,
    PC_QSTEP_FLOOR_RETURN = 0x80255930,
    PC_QSTEP_CEIL_RETURN = 0x80255944,
    PC_QSTEP_COMMIT = 0x80255ab4,
};
#else
enum {
    PC_QSTEP_LOWER_WALL_RETURN = 0x80255b28,
    PC_QSTEP_UPPER_WALL_RETURN = 0x80255b3c,
    PC_QSTEP_FLOOR_RETURN = 0x80255b58,
    PC_QSTEP_CEIL_RETURN = 0x80255b6c,
    PC_QSTEP_COMMIT = 0x80255cdc,
};
#endif

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

static int16_t rs16(uint32_t address) {
    return (int16_t) R16(address);
}

static float cpu_fpr_s(int reg) {
    float **simple = (float **) DebugGetCPUDataPtrApi(
        M64P_CPU_REG_COP1_SIMPLE_PTR);
    return simple == NULL || simple[reg] == NULL ? 0.0f : *simple[reg];
}

static void write_position(float x, float y, float z) {
    uint32_t marioObject = R32(A_MARIO_OBJECT);

    W32(A_MARIO_STATES + M_POS_X, fbits(x));
    W32(A_MARIO_STATES + M_POS_Y, fbits(y));
    W32(A_MARIO_STATES + M_POS_Z, fbits(z));
    if (marioObject != 0) {
        W32(marioObject + O_POS_X, fbits(x));
        W32(marioObject + O_POS_Y, fbits(y));
        W32(marioObject + O_POS_Z, fbits(z));
        W32(marioObject + O_GFX_POS_X, fbits(x));
        W32(marioObject + O_GFX_POS_Y, fbits(y));
        W32(marioObject + O_GFX_POS_Z, fbits(z));
        W32(marioObject + O_VEL_Y, 0);
    }
}

static void stage_idle_at_pre_sample(void) {
    uint32_t marioObject = R32(A_MARIO_OBJECT);

    write_position(5760.0f, 0.0f, 4856.0f);
    W32(A_MARIO_STATES + M_ACTION, ACT_IDLE);
    W32(A_MARIO_STATES + M_PREV_ACTION, ACT_IDLE);
    W16(A_MARIO_STATES + M_ACTION_STATE, 0);
    W16(A_MARIO_STATES + M_ACTION_TIMER, 0);
    W32(A_MARIO_STATES + M_ACTION_ARG, 0);
    W16(A_MARIO_STATES + M_FACE_PITCH, 0);
    W16(A_MARIO_STATES + M_FACE_YAW, 0);
    W16(A_MARIO_STATES + M_FACE_ROLL, 0);
    W32(A_MARIO_STATES + M_INTENDED_MAG, 0);
    W32(A_MARIO_STATES + M_VEL_X, 0);
    W32(A_MARIO_STATES + M_VEL_Y, 0);
    W32(A_MARIO_STATES + M_VEL_Z, 0);
    W32(A_MARIO_STATES + M_FORWARD_VEL, 0);
    W32(A_MARIO_STATES + M_SLIDE_VEL_X, 0);
    W32(A_MARIO_STATES + M_SLIDE_VEL_Z, 0);
    W32(A_MARIO_STATES + M_QUICKSAND_DEPTH, 0);
    W32(A_MARIO_STATES + M_COLLIDED_INTERACT_TYPES, 0);
    if (marioObject != 0) {
        W32(marioObject + O_COLLIDED_INTERACT_TYPES, 0);
        W16(marioObject + O_NUM_COLLIDED_OBJECTS, 0);
    }
}

static void stage_crossing_frame(void) {
    uint32_t marioObject = R32(A_MARIO_OBJECT);

    write_position(5760.0f, 0.0f, 4856.0f);
    /* Make the prepared fixture's platform state explicit rather than
       inheriting it from the setup frames. */
    W32(A_MARIO_PLATFORM, 0);
    W32(A_MARIO_STATES + M_ACTION, ACT_LONG_JUMP_LAND);
    W32(A_MARIO_STATES + M_PREV_ACTION, ACT_LONG_JUMP_LAND);
    W16(A_MARIO_STATES + M_ACTION_STATE, 0);
    W16(A_MARIO_STATES + M_ACTION_TIMER, PRE_ACTION_TIMER);
    W32(A_MARIO_STATES + M_ACTION_ARG, 0);
    W16(A_MARIO_STATES + M_FACE_PITCH, 0);
    W16(A_MARIO_STATES + M_FACE_YAW, 0);
    W16(A_MARIO_STATES + M_FACE_ROLL, 0);
    W16(A_MARIO_STATES + M_SLIDE_YAW, 0);
    W32(A_MARIO_STATES + M_INTENDED_MAG, 0);
    W32(A_MARIO_STATES + M_VEL_X, 0);
    W32(A_MARIO_STATES + M_VEL_Y, 0);
    W32(A_MARIO_STATES + M_VEL_Z, fbits(48.0f));
    W32(A_MARIO_STATES + M_FORWARD_VEL, fbits(48.0f));
    W32(A_MARIO_STATES + M_SLIDE_VEL_X, 0);
    W32(A_MARIO_STATES + M_SLIDE_VEL_Z, fbits(48.0f));
    W32(A_MARIO_STATES + M_QUICKSAND_DEPTH, 0);
    W32(A_MARIO_STATES + M_COLLIDED_INTERACT_TYPES, 0);
    if (marioObject != 0) {
        W32(marioObject + O_COLLIDED_INTERACT_TYPES, 0);
        W16(marioObject + O_NUM_COLLIDED_OBJECTS, 0);
    }
}

static void print_surface(uint32_t surface) {
    if (surface == 0) {
        fprintf(stderr, "surface=NULL");
        return;
    }
    fprintf(stderr,
            "surface=%08x,type=%d,force=%d,flags=%02x,owner=%08x,"
            "v1=(%d,%d,%d),v2=(%d,%d,%d),v3=(%d,%d,%d),"
            "normal=(%.9g,%.9g,%.9g),normalBits=(%08x,%08x,%08x),"
            "origin=%.9g,originBits=%08x",
            surface, rs16(surface + S_TYPE), rs16(surface + S_FORCE),
            R8(surface + S_FLAGS), R32(surface + S_OBJECT),
            rs16(surface + S_VERTEX1 + 0),
            rs16(surface + S_VERTEX1 + 2),
            rs16(surface + S_VERTEX1 + 4),
            rs16(surface + S_VERTEX2 + 0),
            rs16(surface + S_VERTEX2 + 2),
            rs16(surface + S_VERTEX2 + 4),
            rs16(surface + S_VERTEX3 + 0),
            rs16(surface + S_VERTEX3 + 2),
            rs16(surface + S_VERTEX3 + 4),
            rfloat(surface + S_NORMAL_X),
            rfloat(surface + S_NORMAL_Y),
            rfloat(surface + S_NORMAL_Z),
            R32(surface + S_NORMAL_X),
            R32(surface + S_NORMAL_Y),
            R32(surface + S_NORMAL_Z),
            rfloat(surface + S_ORIGIN_OFFSET),
            R32(surface + S_ORIGIN_OFFSET));
}

static int current_qstep(const int64_t *regs) {
    uint32_t innerSp = (uint32_t) regs[29];
    /* The caller's loop counter is at caller-sp+0x2c.  The local helper's
       0x40-byte frame therefore sees it at inner-sp+0x6c. */
    return (int) R32(innerSp + 0x6c) + 1;
}

static void print_qstep_prefix(const char *phase, unsigned int pc,
                               const int64_t *regs, uint32_t sp) {
    uint32_t intended = R32(sp + 0x44);
    fprintf(stderr,
            "LJQC_QSTEP,version=%s,preTimer=%d,qstep=%d,phase=%s,"
            "frame=%d,pc=%08x,sp=%08x,intendedPtr=%08x,"
            "intended=(%.9g,%.9g,%.9g),"
            "intendedBits=(%08x,%08x,%08x),",
            VERSION_JP ? "JP" : "US", PRE_ACTION_TIMER,
            current_qstep(regs), phase, gTraceFrame, pc, sp, intended,
            rfloat(intended + 0x0), rfloat(intended + 0x4),
            rfloat(intended + 0x8), R32(intended + 0x0),
            R32(intended + 0x4), R32(intended + 0x8));
}

static void disable_qstep_breakpoints(void) {
    int i;
    for (i = 0; i < 5; i++) {
        if (gQstepBreakpointIndices[i] >= 0) {
            DebugBreakpointCommandApi(M64P_BKP_CMD_DISABLE,
                                      (unsigned int) gQstepBreakpointIndices[i],
                                      NULL);
        }
    }
}

#if TRACE_NEXT_FRAME
static void enable_qstep_breakpoints(void) {
    int i;
    for (i = 0; i < 5; i++) {
        if (gQstepBreakpointIndices[i] >= 0) {
            DebugBreakpointCommandApi(M64P_BKP_CMD_ENABLE,
                                      (unsigned int) gQstepBreakpointIndices[i],
                                      NULL);
        }
    }
}
#endif

static void qstep_debugger_init(void) {}
static void qstep_debugger_vi(void) {}

static void qstep_debugger_update(unsigned int pc) {
    int64_t *regs = (int64_t *) DebugGetCPUDataPtrApi(M64P_CPU_REG_REG);
    uint32_t sp;

    if (regs == NULL) {
        fprintf(stderr, "LJQC_QSTEP_ERROR,reason=no-register-bank,pc=%08x\n",
                pc);
        DebugSetRunStateApi(M64P_DBG_RUNSTATE_RUNNING);
        return;
    }
    sp = (uint32_t) regs[29];

    if (pc == PC_QSTEP_LOWER_WALL_RETURN) {
        print_qstep_prefix("lower-wall-return", pc, regs, sp);
        fprintf(stderr, "wall=%08x\n", (uint32_t) regs[2]);
        gQstepLowerWallHits++;
    } else if (pc == PC_QSTEP_UPPER_WALL_RETURN) {
        print_qstep_prefix("upper-wall-return", pc, regs, sp);
        fprintf(stderr, "wall=%08x\n", (uint32_t) regs[2]);
        gQstepUpperWallHits++;
    } else if (pc == PC_QSTEP_FLOOR_RETURN) {
        uint32_t floor = R32(sp + 0x30);
        print_qstep_prefix("floor-return", pc, regs, sp);
        fprintf(stderr, "height=%.9g,heightBits=%08x,",
                cpu_fpr_s(0), fbits(cpu_fpr_s(0)));
        print_surface(floor);
        fputc('\n', stderr);
        gQstepFloorHits++;
    } else if (pc == PC_QSTEP_CEIL_RETURN) {
        uint32_t ceil = R32(sp + 0x34);
        print_qstep_prefix("ceil-return", pc, regs, sp);
        fprintf(stderr, "height=%.9g,heightBits=%08x,",
                cpu_fpr_s(0), fbits(cpu_fpr_s(0)));
        print_surface(ceil);
        fputc('\n', stderr);
        gQstepCeilHits++;
    } else if (pc == PC_QSTEP_COMMIT) {
        uint32_t floor = R32(A_MARIO_STATES + M_FLOOR);
        uint32_t ceil = R32(sp + 0x34);
        print_qstep_prefix("commit", pc, regs, sp);
        fprintf(stderr,
                "raw=(%.9g,%.9g,%.9g),rawBits=(%08x,%08x,%08x),"
                "floorHeight=%.9g,floorHeightBits=%08x,wall=%08x,"
                "ceil=%08x,ceilHeight=%.9g,ceilHeightBits=%08x,",
                rfloat(A_MARIO_STATES + M_POS_X),
                rfloat(A_MARIO_STATES + M_POS_Y),
                rfloat(A_MARIO_STATES + M_POS_Z),
                R32(A_MARIO_STATES + M_POS_X),
                R32(A_MARIO_STATES + M_POS_Y),
                R32(A_MARIO_STATES + M_POS_Z),
                rfloat(A_MARIO_STATES + M_FLOOR_HEIGHT),
                R32(A_MARIO_STATES + M_FLOOR_HEIGHT),
                R32(A_MARIO_STATES + M_WALL), ceil,
                rfloat(sp + 0x2c), R32(sp + 0x2c));
        print_surface(floor);
        fputc('\n', stderr);
        gQstepCommitHits++;
        gFrameCommitHits++;
        if (gFrameCommitHits == 4) disable_qstep_breakpoints();
    }

    DebugSetRunStateApi(M64P_DBG_RUNSTATE_RUNNING);
}

static void install_qstep_breakpoints(void) {
    static const uint32_t addresses[5] = {
        PC_QSTEP_LOWER_WALL_RETURN,
        PC_QSTEP_UPPER_WALL_RETURN,
        PC_QSTEP_FLOOR_RETURN,
        PC_QSTEP_CEIL_RETURN,
        PC_QSTEP_COMMIT,
    };
    m64p_breakpoint breakpoint;
    int i;

    if (addresses[0] == 0) {
        fprintf(stderr,
                "LJQC_QSTEP_UNAVAILABLE,version=%s,reason=no-retail-PC-receipt\n",
                VERSION_JP ? "JP" : "US");
        return;
    }
    if (DebugSetCallbacksApi(qstep_debugger_init, qstep_debugger_update,
                             qstep_debugger_vi) != M64ERR_SUCCESS) {
        fprintf(stderr,
                "LJQC_QSTEP_ERROR,version=%s,reason=set-callbacks-failed\n",
                VERSION_JP ? "JP" : "US");
        return;
    }

    breakpoint.flags = M64P_BKP_FLAG_ENABLED | M64P_BKP_FLAG_EXEC;
    for (i = 0; i < 5; i++) {
        breakpoint.address = addresses[i];
        breakpoint.endaddr = addresses[i];
        gQstepBreakpointIndices[i] = DebugBreakpointCommandApi(
            M64P_BKP_CMD_ADD_STRUCT, 0, &breakpoint);
        if (gQstepBreakpointIndices[i] < 0) {
            fprintf(stderr,
                    "LJQC_QSTEP_ERROR,version=%s,reason=add-breakpoint-failed,"
                    "pc=%08x\n",
                    VERSION_JP ? "JP" : "US", addresses[i]);
            disable_qstep_breakpoints();
            return;
        }
    }
    gQstepBreakpointsInstalled = 1;
    gTraceFrame = 1;
    gFrameCommitHits = 0;
    fprintf(stderr,
            "LJQC_QSTEP_ARMED,version=%s,preTimer=%d,"
            "lower=%08x,upper=%08x,floor=%08x,ceil=%08x,commit=%08x\n",
            VERSION_JP ? "JP" : "US", PRE_ACTION_TIMER,
            addresses[0], addresses[1], addresses[2], addresses[3],
            addresses[4]);
}

static void log_state(const char *tag) {
    uint32_t marioObject = R32(A_MARIO_OBJECT);
    uint32_t controller = R32(A_MARIO_STATES + M_CONTROLLER);
    uint32_t floor = R32(A_MARIO_STATES + M_FLOOR);
    uint16_t input = R16(A_MARIO_STATES + M_INPUT);
    uint16_t down = controller ? R16(controller + C_BUTTON_DOWN) : 0xffff;
    uint16_t pressed = controller ? R16(controller + C_BUTTON_PRESSED) : 0xffff;

    fprintf(stderr,
            "LJQC_%s,version=%s,preTimer=%d,poll=%llu,timer=%u,"
            "action=%08x,actionTimer=%u,input=%04x,buttonDown=%04x,"
            "buttonPressed=%04x,faceYaw=%d,floorAngle=%d,"
            "pos=(%.9g,%.9g,%.9g),posBits=(%08x,%08x,%08x),"
            "vel=(%.9g,%.9g,%.9g),forwardVel=%.9g,"
            "floorHeight=%.9g,floorHeightBits=%08x,"
            "quicksandDepth=%.9g,quicksandDepthBits=%08x,"
            "wall=%08x,ceil=%08x,ceilHeight=%.9g,ceilHeightBits=%08x,"
            "platform=%08x,"
            "raw=(%.9g,%.9g,%.9g),rawBits=(%08x,%08x,%08x),"
            "gfx=(%.9g,%.9g,%.9g),gfxBits=(%08x,%08x,%08x),",
            tag, VERSION_JP ? "JP" : "US", PRE_ACTION_TIMER,
            gPoll, R32(A_GLOBAL_TIMER),
            R32(A_MARIO_STATES + M_ACTION),
            R16(A_MARIO_STATES + M_ACTION_TIMER), input, down, pressed,
            (int) rs16(A_MARIO_STATES + M_FACE_YAW),
            (int) rs16(A_MARIO_STATES + M_FLOOR_ANGLE),
            rfloat(A_MARIO_STATES + M_POS_X),
            rfloat(A_MARIO_STATES + M_POS_Y),
            rfloat(A_MARIO_STATES + M_POS_Z),
            R32(A_MARIO_STATES + M_POS_X),
            R32(A_MARIO_STATES + M_POS_Y),
            R32(A_MARIO_STATES + M_POS_Z),
            rfloat(A_MARIO_STATES + M_VEL_X),
            rfloat(A_MARIO_STATES + M_VEL_Y),
            rfloat(A_MARIO_STATES + M_VEL_Z),
            rfloat(A_MARIO_STATES + M_FORWARD_VEL),
            rfloat(A_MARIO_STATES + M_FLOOR_HEIGHT),
            R32(A_MARIO_STATES + M_FLOOR_HEIGHT),
            rfloat(A_MARIO_STATES + M_QUICKSAND_DEPTH),
            R32(A_MARIO_STATES + M_QUICKSAND_DEPTH),
            R32(A_MARIO_STATES + M_WALL),
            R32(A_MARIO_STATES + M_CEIL),
            rfloat(A_MARIO_STATES + M_CEIL_HEIGHT),
            R32(A_MARIO_STATES + M_CEIL_HEIGHT),
            R32(A_MARIO_PLATFORM),
            marioObject ? rfloat(marioObject + O_POS_X) : 0.0f,
            marioObject ? rfloat(marioObject + O_POS_Y) : 0.0f,
            marioObject ? rfloat(marioObject + O_POS_Z) : 0.0f,
            marioObject ? R32(marioObject + O_POS_X) : 0,
            marioObject ? R32(marioObject + O_POS_Y) : 0,
            marioObject ? R32(marioObject + O_POS_Z) : 0,
            marioObject ? rfloat(marioObject + O_GFX_POS_X) : 0.0f,
            marioObject ? rfloat(marioObject + O_GFX_POS_Y) : 0.0f,
            marioObject ? rfloat(marioObject + O_GFX_POS_Z) : 0.0f,
            marioObject ? R32(marioObject + O_GFX_POS_X) : 0,
            marioObject ? R32(marioObject + O_GFX_POS_Y) : 0,
            marioObject ? R32(marioObject + O_GFX_POS_Z) : 0);
    print_surface(floor);
    fputc('\n', stderr);
}

EXPORT m64p_error CALL PluginStartup(m64p_dynlib_handle core, void *context,
                                     void (*debugCallback)(void *, int,
                                                           const char *)) {
    (void) context;
    (void) debugCallback;
    R32 = (read32_fn) dlsym(core, "DebugMemRead32");
    R16 = (read16_fn) dlsym(core, "DebugMemRead16");
    R8 = (read8_fn) dlsym(core, "DebugMemRead8");
    W32 = (write32_fn) dlsym(core, "DebugMemWrite32");
    W16 = (write16_fn) dlsym(core, "DebugMemWrite16");
    DebugSetCallbacksApi = (ptr_DebugSetCallbacks) dlsym(
        core, "DebugSetCallbacks");
    DebugSetRunStateApi = (ptr_DebugSetRunState) dlsym(
        core, "DebugSetRunState");
    DebugGetCPUDataPtrApi = (ptr_DebugGetCPUDataPtr) dlsym(
        core, "DebugGetCPUDataPtr");
    DebugBreakpointCommandApi = (ptr_DebugBreakpointCommand) dlsym(
        core, "DebugBreakpointCommand");
    if (!R32 || !R16 || !R8 || !W32 || !W16 || !DebugSetCallbacksApi
        || !DebugSetRunStateApi || !DebugGetCPUDataPtrApi
        || !DebugBreakpointCommandApi) {
        return M64ERR_INCOMPATIBLE;
    }
    return M64ERR_SUCCESS;
}

EXPORT m64p_error CALL PluginShutdown(void) { return M64ERR_SUCCESS; }

EXPORT m64p_error CALL PluginGetVersion(m64p_plugin_type *type, int *version,
                                        int *apiVersion, const char **name,
                                        int *capabilities) {
    if (type) *type = M64PLUGIN_INPUT;
    if (version) *version = 0x000100;
    if (apiVersion) *apiVersion = 0x020100;
    if (name) *name = "SSL Area-1 long-jump quicksand crossing probe";
    if (capabilities) *capabilities = 0;
    return M64ERR_SUCCESS;
}

EXPORT void CALL InitiateControllers(CONTROL_INFO info) {
    int index;
    for (index = 0; index < 4; index++) {
        info.Controls[index].Present = index == 0;
        info.Controls[index].RawData = 0;
        info.Controls[index].Plugin = PLUGIN_MEMPAK;
        info.Controls[index].Type = CONT_TYPE_STANDARD;
    }
}

EXPORT int CALL RomOpen(void) {
    gPoll = 0;
    gLastSetupTimer = UINT32_MAX;
    gArmTimer = UINT32_MAX;
    gSetupFrames = 0;
    gArmed = 0;
    gDone = 0;
    gAPressedPolls = 0;
    gADownPolls = 0;
    gQstepBreakpointsInstalled = 0;
    gQstepLowerWallHits = 0;
    gQstepUpperWallHits = 0;
    gQstepFloorHits = 0;
    gQstepCeilHits = 0;
    gQstepCommitHits = 0;
    gTraceFrame = 0;
    gFrameCommitHits = 0;
    memset(gQstepBreakpointIndices, 0xff, sizeof(gQstepBreakpointIndices));
    fprintf(stderr,
            "LJQC_HEADER,fixture=prepared-retail-frame,"
            "pre=(5760,0,4856),yaw=0,forwardVel=48,preTimer=%d,"
            "traceNext=%d\n",
            PRE_ACTION_TIMER, TRACE_NEXT_FRAME);
    return 1;
}

EXPORT void CALL RomClosed(void) {
    fprintf(stderr,
            "LJQC_SUMMARY,version=%s,preTimer=%d,armed=%d,done=%d,"
            "aPressedPolls=%d,aDownPolls=%d,qstepBreakpoints=%d,"
            "qstepLower=%d,qstepUpper=%d,qstepFloor=%d,qstepCeil=%d,"
            "qstepCommit=%d\n",
            VERSION_JP ? "JP" : "US", PRE_ACTION_TIMER,
            gArmed, gDone, gAPressedPolls, gADownPolls,
            gQstepBreakpointsInstalled, gQstepLowerWallHits,
            gQstepUpperWallHits, gQstepFloorHits, gQstepCeilHits,
            gQstepCommitHits);
}

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
EXPORT void CALL SendVRUWord(uint16_t length, uint16_t *word,
                             uint8_t language) {
    (void) length;
    (void) word;
    (void) language;
}
EXPORT void CALL SetMicState(int state) { (void) state; }
EXPORT void CALL ReadVRUResults(uint16_t *errorFlags, uint16_t *numResults,
                                uint16_t *micLevel, uint16_t *voiceLevel,
                                uint16_t *voiceLength, uint16_t *matches) {
    if (errorFlags) *errorFlags = 0;
    if (numResults) *numResults = 0;
    if (micLevel) *micLevel = 0;
    if (voiceLevel) *voiceLevel = 0;
    if (voiceLength) *voiceLength = 0;
    (void) matches;
}
EXPORT void CALL ClearVRUWords(uint8_t length) { (void) length; }
EXPORT void CALL SetVRUWordMask(uint8_t length, uint8_t *mask) {
    (void) length;
    (void) mask;
}

EXPORT void CALL GetKeys(int control, BUTTONS *keys) {
    unsigned long long slot;
    uint32_t timer;
    uint32_t controller;

    memset(keys, 0, sizeof(*keys));
    if (control != 0) return;
    gPoll++;

    if (gPoll >= 150 && gPoll < 156) keys->START_BUTTON = 1;
    for (slot = 220; slot <= 280; slot += 10) {
        if (gPoll >= slot && gPoll < slot + 2) keys->D_DPAD = 1;
    }
    if (gPoll >= 330 && gPoll < 336) keys->START_BUTTON = 1;

    controller = R32(A_MARIO_STATES + M_CONTROLLER);
    if (controller != 0) {
        if (R16(controller + C_BUTTON_PRESSED) & 0x8000) gAPressedPolls++;
        if (R16(controller + C_BUTTON_DOWN) & 0x8000) gADownPolls++;
    }

    if (R16(A_CURR_LEVEL) != LEVEL_SSL || R16(A_CURR_AREA) != 1
        || R32(A_MARIO_OBJECT) == 0) {
        return;
    }

    timer = R32(A_GLOBAL_TIMER);
    if (!gArmed) {
        if (timer == gLastSetupTimer) return;
        gLastSetupTimer = timer;
        if (gSetupFrames < 12) {
            stage_idle_at_pre_sample();
            gSetupFrames++;
            return;
        }

        if (R32(A_MARIO_STATES + M_FLOOR) == 0
            || R16(R32(A_MARIO_STATES + M_FLOOR) + S_TYPE) != 0) {
            fprintf(stderr,
                    "LJQC_SETUP_RETRY,version=%s,timer=%u,floor=%08x,type=%d\n",
                    VERSION_JP ? "JP" : "US", timer,
                    R32(A_MARIO_STATES + M_FLOOR),
                    R32(A_MARIO_STATES + M_FLOOR)
                        ? rs16(R32(A_MARIO_STATES + M_FLOOR) + S_TYPE) : -1);
            stage_idle_at_pre_sample();
            return;
        }

        stage_crossing_frame();
        gArmed = 1;
        gArmTimer = timer;
        log_state("PRE");
        install_qstep_breakpoints();
        return;
    }

    if (!gDone && timer != gArmTimer) {
#if TRACE_NEXT_FRAME
        if (gTraceFrame == 1) {
            log_state("POST");
            gTraceFrame = 2;
            gFrameCommitHits = 0;
            gArmTimer = timer;
            enable_qstep_breakpoints();
        } else {
            log_state("NEXT");
            gDone = 1;
        }
#else
        log_state("POST");
        gDone = 1;
#endif
    }
}
