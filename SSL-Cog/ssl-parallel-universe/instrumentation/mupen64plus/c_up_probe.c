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

#ifndef PROBE_NAME
#define PROBE_NAME "unnamed"
#endif
#ifndef START_X
#define START_X 0.0f
#endif
#ifndef START_Y
#define START_Y 1408.0f
#endif
#ifndef START_Z
#define START_Z 2867.0f
#endif
#ifndef START_YAW
#define START_YAW 0x4000
#endif
#ifndef TRACE_FRAMES
#define TRACE_FRAMES 180
#endif

enum {
    A_GLOBAL_TIMER = 0x8032d5d4,
    A_CURR_LEVEL = 0x8032ddf8,
    A_MARIO_STATES = 0x8033b170,
    A_WARP_DEST = 0x8033b248,
    A_CURR_AREA = 0x8033baca,
    A_MARIO_OBJECT = 0x80361158,
};

enum {
    O_POS_X = 0x0a0,
    O_POS_Y = 0x0a4,
    O_POS_Z = 0x0a8,
    O_VEL_Y = 0x0b0,
};

enum {
    M_INPUT = 0x02,
    M_ACTION = 0x0c,
    M_PREV_ACTION = 0x10,
    M_ACTION_STATE = 0x18,
    M_ACTION_TIMER = 0x1a,
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
    M_FLOOR_ANGLE = 0x74,
};

enum {
    S_TYPE = 0x00,
    S_NORMAL_X = 0x1c,
    S_NORMAL_Y = 0x20,
    S_NORMAL_Z = 0x24,
};

enum {
    ACT_IDLE = 0x0c400201,
    ACT_WALKING = 0x04000440,
    ACT_BRAKING = 0x04000445,
    INPUT_A_PRESSED = 0x0002,
    INPUT_FIRST_PERSON = 0x0010,
    INPUT_A_DOWN = 0x0080,
};

typedef unsigned int (*read32_fn)(unsigned int);
typedef unsigned short (*read16_fn)(unsigned int);
typedef void (*write32_fn)(unsigned int, unsigned int);
typedef void (*write16_fn)(unsigned int, unsigned short);
typedef void (*write8_fn)(unsigned int, unsigned char);

static read32_fn R32;
static read16_fn R16;
static write32_fn W32;
static write16_fn W16;
static write8_fn W8;

static unsigned long long gPoll;
static uint32_t gLastTimer = UINT32_MAX;
static uint32_t gTraceStartTimer;
static int gWarpRequested;
static int gSetupPolls;
static int gArmed;
static int gStarted;
static int gTraceFrames;
static int gAPressedFrames;
static int gADownFrames;
static float gMaxAbsSpeed;
static float gMaxAbsHorizontal;

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

static void put_mario(float x, float y, float z) {
    uint32_t marioObject = R32(A_MARIO_OBJECT);

    W32(A_MARIO_STATES + M_POS_X, fbits(x));
    W32(A_MARIO_STATES + M_POS_Y, fbits(y));
    W32(A_MARIO_STATES + M_POS_Z, fbits(z));
    W32(A_MARIO_STATES + M_VEL_X, 0);
    W32(A_MARIO_STATES + M_VEL_Y, 0);
    W32(A_MARIO_STATES + M_VEL_Z, 0);
    W32(A_MARIO_STATES + M_FORWARD_VEL, 0);

    if (marioObject != 0) {
        W32(marioObject + O_POS_X, fbits(x));
        W32(marioObject + O_POS_Y, fbits(y));
        W32(marioObject + O_POS_Z, fbits(z));
        W32(marioObject + O_VEL_Y, 0);
    }
}

static void stage_idle_fixture(void) {
    put_mario(0.0f, 896.0f, -1500.0f);
    W32(A_MARIO_STATES + M_ACTION, ACT_IDLE);
    W32(A_MARIO_STATES + M_PREV_ACTION, ACT_IDLE);
    W16(A_MARIO_STATES + M_ACTION_STATE, 0);
    W16(A_MARIO_STATES + M_ACTION_TIMER, 0);
    W16(A_MARIO_STATES + M_FACE_YAW, 0);
}

static void arm_braking_fixture(void) {
    put_mario(0.0f, 896.0f, -1500.0f);
    W32(A_MARIO_STATES + M_ACTION, ACT_WALKING);
    W32(A_MARIO_STATES + M_PREV_ACTION, ACT_IDLE);
    W16(A_MARIO_STATES + M_ACTION_STATE, 0);
    W16(A_MARIO_STATES + M_ACTION_TIMER, 0);
    W16(A_MARIO_STATES + M_FACE_YAW, 0);
    W32(A_MARIO_STATES + M_FORWARD_VEL, fbits(32.0f));
    W32(A_MARIO_STATES + M_VEL_X, 0);
    W32(A_MARIO_STATES + M_VEL_Z, fbits(32.0f));
}

static void start_slope_fixture(void) {
    uint32_t marioObject = R32(A_MARIO_OBJECT);
    float yaw = (float) ((int16_t) START_YAW) * (float) M_PI / 32768.0f;

    W32(A_MARIO_STATES + M_POS_X, fbits(START_X));
    W32(A_MARIO_STATES + M_POS_Y, fbits(START_Y));
    W32(A_MARIO_STATES + M_POS_Z, fbits(START_Z));
    W16(A_MARIO_STATES + M_FACE_YAW, (uint16_t) START_YAW);
    W32(A_MARIO_STATES + M_VEL_X,
        fbits(rfloat(A_MARIO_STATES + M_FORWARD_VEL) * sinf(yaw)));
    W32(A_MARIO_STATES + M_VEL_Z,
        fbits(rfloat(A_MARIO_STATES + M_FORWARD_VEL) * cosf(yaw)));
    if (marioObject != 0) {
        W32(marioObject + O_POS_X, fbits(START_X));
        W32(marioObject + O_POS_Y, fbits(START_Y));
        W32(marioObject + O_POS_Z, fbits(START_Z));
    }
}

static void log_frame(uint32_t timer) {
    uint32_t floor = R32(A_MARIO_STATES + M_FLOOR);
    uint16_t input = R16(A_MARIO_STATES + M_INPUT);
    float x = rfloat(A_MARIO_STATES + M_POS_X);
    float z = rfloat(A_MARIO_STATES + M_POS_Z);
    float speed = rfloat(A_MARIO_STATES + M_FORWARD_VEL);
    float absSpeed = fabsf(speed);
    float absHorizontal = fmaxf(fabsf(x), fabsf(z));

    if (absSpeed > gMaxAbsSpeed) gMaxAbsSpeed = absSpeed;
    if (absHorizontal > gMaxAbsHorizontal) gMaxAbsHorizontal = absHorizontal;
    if (input & INPUT_A_PRESSED) gAPressedFrames++;
    if (input & INPUT_A_DOWN) gADownFrames++;

    fprintf(stderr,
            "CUP,%s,%u,%u,%08x,%04x,%d,%d,%.9g,%.9g,%.9g,%.9g,%.9g,%.9g,%08x,%04x,%.9g,%.9g,%.9g,%.9g\n",
            PROBE_NAME, timer - gTraceStartTimer, timer,
            R32(A_MARIO_STATES + M_ACTION), input,
            (int) ((int16_t) R16(A_MARIO_STATES + M_FACE_YAW)),
            (int) ((int16_t) R16(A_MARIO_STATES + M_FLOOR_ANGLE)),
            x, rfloat(A_MARIO_STATES + M_POS_Y), z, speed,
            rfloat(A_MARIO_STATES + M_VEL_X), rfloat(A_MARIO_STATES + M_VEL_Z),
            floor, floor ? R16(floor + S_TYPE) : 0xffff,
            rfloat(A_MARIO_STATES + M_FLOOR_HEIGHT),
            floor ? rfloat(floor + S_NORMAL_X) : 0.0f,
            floor ? rfloat(floor + S_NORMAL_Y) : 0.0f,
            floor ? rfloat(floor + S_NORMAL_Z) : 0.0f);
}

EXPORT m64p_error CALL PluginStartup(m64p_dynlib_handle core, void *context,
                                     void (*debugCallback)(void *, int, const char *)) {
    (void) context;
    (void) debugCallback;
    R32 = (read32_fn) dlsym(core, "DebugMemRead32");
    R16 = (read16_fn) dlsym(core, "DebugMemRead16");
    W32 = (write32_fn) dlsym(core, "DebugMemWrite32");
    W16 = (write16_fn) dlsym(core, "DebugMemWrite16");
    W8 = (write8_fn) dlsym(core, "DebugMemWrite8");
    if (!R32 || !R16 || !W32 || !W16 || !W8) return M64ERR_INCOMPATIBLE;
    return M64ERR_SUCCESS;
}

EXPORT m64p_error CALL PluginShutdown(void) { return M64ERR_SUCCESS; }

EXPORT m64p_error CALL PluginGetVersion(m64p_plugin_type *type, int *version,
                                        int *apiVersion, const char **name,
                                        int *capabilities) {
    if (type) *type = M64PLUGIN_INPUT;
    if (version) *version = 0x000100;
    if (apiVersion) *apiVersion = 0x020100;
    if (name) *name = "SSL Area 2 C-up probe";
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
    gLastTimer = UINT32_MAX;
    gTraceStartTimer = 0;
    gWarpRequested = 0;
    gSetupPolls = 0;
    gArmed = 0;
    gStarted = 0;
    gTraceFrames = 0;
    gAPressedFrames = 0;
    gADownFrames = 0;
    gMaxAbsSpeed = 0.0f;
    gMaxAbsHorizontal = 0.0f;
    fprintf(stderr,
            "CUP_HEADER,name,relativeFrame,timer,action,input,faceYaw,floorAngle,x,y,z,forwardVel,velX,velZ,floor,floorType,floorHeight,normalX,normalY,normalZ\n");
    fprintf(stderr,
            "CUP_SETUP,%s,start=(%.9g,%.9g,%.9g),yaw=%d,policy=C-up-only\n",
            PROBE_NAME, (double) START_X, (double) START_Y, (double) START_Z,
            (int) ((int16_t) START_YAW));
    return 1;
}

EXPORT void CALL RomClosed(void) {
    fprintf(stderr,
            "CUP_SUMMARY,%s,traceFrames=%d,maxAbsSpeed=%.9g,maxAbsHorizontal=%.9g,aPressedFrames=%d,aDownFrames=%d\n",
            PROBE_NAME, gTraceFrames, gMaxAbsSpeed, gMaxAbsHorizontal,
            gAPressedFrames, gADownFrames);
}

EXPORT void CALL ControllerCommand(int control, unsigned char *command) {
    (void) control;
    (void) command;
}
EXPORT void CALL ReadController(int control, unsigned char *command) {
    (void) control;
    (void) command;
}
EXPORT void CALL SDL_KeyDown(int modifier, int key) { (void) modifier; (void) key; }
EXPORT void CALL SDL_KeyUp(int modifier, int key) { (void) modifier; (void) key; }
EXPORT void CALL RenderCallback(void) {}
EXPORT void CALL SendVRUWord(uint16_t length, uint16_t *word, uint8_t language) {
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
    uint16_t area;
    uint32_t timer;

    memset(keys, 0, sizeof(*keys));
    if (control != 0) return;
    gPoll++;

    if (gPoll >= 150 && gPoll < 156) keys->START_BUTTON = 1;
    for (slot = 220; slot <= 280; slot += 10) {
        if (gPoll >= slot && gPoll < slot + 2) keys->D_DPAD = 1;
    }
    if (gPoll >= 330 && gPoll < 336) keys->START_BUTTON = 1;

    area = R16(A_CURR_AREA);
    if (!gWarpRequested && gPoll > 360 && area == 1 && R32(A_MARIO_OBJECT) != 0) {
        uint16_t level = R16(A_CURR_LEVEL);
        W8(A_WARP_DEST + 0, 2);
        W8(A_WARP_DEST + 1, (uint8_t) level);
        W8(A_WARP_DEST + 2, 2);
        W8(A_WARP_DEST + 3, 0x0a);
        W32(A_WARP_DEST + 4, 0);
        gWarpRequested = 1;
        fprintf(stderr, "CUP_WARP,%s,level=%u,area=2\n", PROBE_NAME, level);
    }

    if (gWarpRequested && area == 2 && R32(A_MARIO_OBJECT) != 0
        && !gArmed && !gStarted) {
        if (gSetupPolls < 24) {
            stage_idle_fixture();
            gSetupPolls++;
        } else {
            arm_braking_fixture();
            keys->U_CBUTTON = 1;
            gArmed = 1;
            fprintf(stderr, "CUP_ARM,%s,timer=%u\n", PROBE_NAME,
                    R32(A_GLOBAL_TIMER));
        }
    } else if (gArmed && !gStarted) {
        if (R32(A_MARIO_STATES + M_ACTION) == ACT_BRAKING
            && (R16(A_MARIO_STATES + M_INPUT) & INPUT_FIRST_PERSON)) {
            start_slope_fixture();
            gStarted = 1;
            gTraceStartTimer = R32(A_GLOBAL_TIMER);
            gLastTimer = UINT32_MAX;
            fprintf(stderr, "CUP_START,%s,timer=%u\n", PROBE_NAME, gTraceStartTimer);
        } else if (gSetupPolls++ < 30) {
            keys->U_CBUTTON = 1;
        } else {
            fprintf(stderr,
                    "CUP_SETUP_FAILED,%s,action=%08x,input=%04x\n",
                    PROBE_NAME, R32(A_MARIO_STATES + M_ACTION),
                    R16(A_MARIO_STATES + M_INPUT));
            gArmed = 0;
        }
    }

    if (gStarted && gTraceFrames < TRACE_FRAMES) {
        timer = R32(A_GLOBAL_TIMER);
        if (timer != gLastTimer) {
            gLastTimer = timer;
            log_frame(timer);
            gTraceFrames++;
        }
    }
}
