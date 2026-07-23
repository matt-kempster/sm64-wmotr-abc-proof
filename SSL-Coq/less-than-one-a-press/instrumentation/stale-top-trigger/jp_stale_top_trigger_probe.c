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

#ifndef STAGE_AT_AREA2_BOUNDARY
#define STAGE_AT_AREA2_BOUNDARY 1
#endif

#ifndef TRACE_FRAMES
#define TRACE_FRAMES 360
#endif

/*
 * VERSION_JP addresses for the authenticated original-JP ROM.  The probe is
 * deliberately hash-gated by run.sh and must not be used with another ROM.
 */
enum {
    A_GLOBAL_TIMER = 0x8032c694,
    A_CURR_LEVEL = 0x8032ce98,
    A_MARIO_PLATFORM = 0x8032fed4,
    A_MARIO_STATES = 0x80339e00,
    A_WARP_DEST = 0x80339ed8,
    A_CURR_AREA = 0x8033a75a,
    A_OBJECT_POOL = 0x8033c118,
    A_MARIO_OBJECT = 0x8035fde8,
};

enum {
    OBJECT_SIZE = 0x260,
    OBJECT_COUNT = 240,
    STALE_TOP_SLOT = 60,

    O_ACTIVE_FLAGS = 0x074,
    O_POS_X = 0x0a0,
    O_POS_Y = 0x0a4,
    O_POS_Z = 0x0a8,
    O_VEL_X = 0x0ac,
    O_VEL_Y = 0x0b0,
    O_VEL_Z = 0x0b4,
    O_FACE_PITCH = 0x0d0,
    O_FACE_YAW = 0x0d4,
    O_FACE_ROLL = 0x0d8,
    O_HIDDEN_STAR_TRIGGER_COUNTER = 0x0f4,
    O_ANGLE_VEL_PITCH = 0x114,
    O_ANGLE_VEL_YAW = 0x118,
    O_ANGLE_VEL_ROLL = 0x11c,
    O_ACTION = 0x14c,
    O_BEHAVIOR = 0x20c,
};

enum {
    M_INPUT = 0x02,
    M_ACTION = 0x0c,
    M_POS_X = 0x3c,
    M_POS_Y = 0x40,
    M_POS_Z = 0x44,
    M_VEL_X = 0x48,
    M_VEL_Y = 0x4c,
    M_VEL_Z = 0x50,
    M_FORWARD_VEL = 0x54,
    M_FLOOR = 0x68,
    M_FLOOR_HEIGHT = 0x70,
};

enum {
    INPUT_A_PRESSED = 0x0002,
    INPUT_A_DOWN = 0x0080,
};

typedef unsigned int (*read32_fn)(unsigned int);
typedef unsigned short (*read16_fn)(unsigned int);
typedef void (*write32_fn)(unsigned int, unsigned int);
typedef void (*write8_fn)(unsigned int, unsigned char);

static read32_fn R32;
static read16_fn R16;
static write32_fn W32;
static write8_fn W8;

static uint64_t gPoll;
static uint32_t gLastTimer;
static uint32_t gStartTimer;
static uint32_t gUpperTriggerObject;
static uint32_t gHiddenStarController;
static int32_t gInitialCounter;
static int32_t gMaxCounter;
static int gWarpRequested;
static int gStarted;
static int gPrintedPreStage;
static int gBoundaryObserved;
static int gFrames;
static int gAPressedFrames;
static int gADownFrames;
static int gControllerAFrames;
static int gAct3RegionFrames;
static int gUpperRegionFrames;
static int gTriggerEverInactive;

static const char *fixture_mode(void) {
    return STAGE_AT_AREA2_BOUNDARY ? "area2-boundary" : "pre-transition-only";
}

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

static uint32_t stale_top_slot(void) {
    return A_OBJECT_POOL + STALE_TOP_SLOT * OBJECT_SIZE;
}

static int32_t hidden_counter(void) {
    if (gHiddenStarController == 0) {
        return -1;
    }
    return (int32_t) R32(gHiddenStarController
                          + O_HIDDEN_STAR_TRIGGER_COUNTER);
}

static int within_cylinder(float x, float y, float z,
                           float cx, float cy, float cz,
                           float radius, float below, float above) {
    float dx = x - cx;
    float dz = z - cz;
    return dx * dx + dz * dz <= radius * radius
        && y >= cy - below && y <= cy + above;
}

static void find_hidden_star_objects(void) {
    unsigned i;

    gUpperTriggerObject = 0;
    gHiddenStarController = 0;
    for (i = 0; i < OBJECT_COUNT; i++) {
        uint32_t object = A_OBJECT_POOL + i * OBJECT_SIZE;
        if (R16(object + O_ACTIVE_FLAGS) == 0) {
            continue;
        }

        if (rfloat(object + O_POS_X) == 260.0f
            && rfloat(object + O_POS_Y) == 3913.0f
            && rfloat(object + O_POS_Z) == -600.0f) {
            gUpperTriggerObject = object;
        }

        if (rfloat(object + O_POS_X) == 900.0f
            && rfloat(object + O_POS_Y) == 1400.0f
            && rfloat(object + O_POS_Z) == 2350.0f) {
            gHiddenStarController = object;
        }
    }

    gInitialCounter = hidden_counter();
    gMaxCounter = gInitialCounter;
    fprintf(stderr,
            "OBJECTS,upper=%08x,upperActive=%u,upperBehavior=%08x,"
            "controller=%08x,counter=%d,controllerAction=%d\n",
            gUpperTriggerObject,
            gUpperTriggerObject
                ? R16(gUpperTriggerObject + O_ACTIVE_FLAGS) : 0,
            gUpperTriggerObject
                ? R32(gUpperTriggerObject + O_BEHAVIOR) : 0,
            gHiddenStarController,
            gInitialCounter,
            gHiddenStarController
                ? (int32_t) R32(gHiddenStarController + O_ACTION) : -1);
}

static void log_slot(const char *tag) {
    uint32_t slot = stale_top_slot();

    fprintf(stderr,
            "%s,mode=%s,timer=%u,level=%u,area=%u,slot=%08x,"
            "active=%u,behavior=%08x,"
            "pos=(%.6f,%.6f,%.6f),vel=(%.6f,%.6f,%.6f),"
            "face=(%d,%d,%d),angleVel=(%d,%d,%d),"
            "platform=%08x,mario=(%.6f,%.6f,%.6f),"
            "marioAction=%08x,marioInput=%04x\n",
            tag, fixture_mode(), R32(A_GLOBAL_TIMER), R16(A_CURR_LEVEL),
            R16(A_CURR_AREA), slot, R16(slot + O_ACTIVE_FLAGS),
            R32(slot + O_BEHAVIOR),
            rfloat(slot + O_POS_X), rfloat(slot + O_POS_Y),
            rfloat(slot + O_POS_Z),
            rfloat(slot + O_VEL_X), rfloat(slot + O_VEL_Y),
            rfloat(slot + O_VEL_Z),
            (int32_t) R32(slot + O_FACE_PITCH),
            (int32_t) R32(slot + O_FACE_YAW),
            (int32_t) R32(slot + O_FACE_ROLL),
            (int32_t) R32(slot + O_ANGLE_VEL_PITCH),
            (int32_t) R32(slot + O_ANGLE_VEL_YAW),
            (int32_t) R32(slot + O_ANGLE_VEL_ROLL),
            R32(A_MARIO_PLATFORM),
            rfloat(A_MARIO_STATES + M_POS_X),
            rfloat(A_MARIO_STATES + M_POS_Y),
            rfloat(A_MARIO_STATES + M_POS_Z),
            R32(A_MARIO_STATES + M_ACTION),
            R16(A_MARIO_STATES + M_INPUT));
}

static void stage_stale_top(void) {
    uint32_t slot = stale_top_slot();

    /*
     * Raw fields from the JP exploded-pyramid-top displacement candidate.
     * Activity flags, behavior, collision, and list links are not modified.
     * update_mario_platform() dereferences these raw fields without checking
     * those lifecycle fields.
     */
    W32(slot + O_POS_X, fbits(-2047.0f));
    W32(slot + O_POS_Y, fbits(1778.071045f));
    W32(slot + O_POS_Z, fbits(-1023.0f));
    W32(slot + O_VEL_X, fbits(0.0f));
    W32(slot + O_VEL_Y, fbits(5.0f));
    W32(slot + O_VEL_Z, fbits(0.0f));
    W32(slot + O_FACE_PITCH, 0);
    W32(slot + O_FACE_YAW, 0);
    W32(slot + O_FACE_ROLL, 0);
    W32(slot + O_ANGLE_VEL_PITCH, 0);
    W32(slot + O_ANGLE_VEL_YAW, 0x1800);
    W32(slot + O_ANGLE_VEL_ROLL, 0);
    W32(A_MARIO_PLATFORM, slot);
}

static void apply_witness_input(BUTTONS *keys, unsigned rel) {
    /*
     * No buttons are pressed.  The stick is held toward the trigger through
     * relative frame 59 and is neutral beginning at relative frame 60.
     */
    if (rel < 60) {
        keys->X_AXIS = 0;
        keys->Y_AXIS = -127;
    }
}

static void log_frame(uint32_t timer, const BUTTONS *keys) {
    float x = rfloat(A_MARIO_STATES + M_POS_X);
    float y = rfloat(A_MARIO_STATES + M_POS_Y);
    float z = rfloat(A_MARIO_STATES + M_POS_Z);
    uint16_t input = R16(A_MARIO_STATES + M_INPUT);
    int act3 = within_cylinder(x, y, z, 500.0f, 5050.0f, -500.0f,
                               140.0f, 100.0f, 180.0f);
    int upper = within_cylinder(x, y, z, 260.0f, 3913.0f, -600.0f,
                                160.0f, 120.0f, 200.0f);
    unsigned trigger_active = gUpperTriggerObject
        ? R16(gUpperTriggerObject + O_ACTIVE_FLAGS) : 0;
    int32_t counter = hidden_counter();

    if ((input & INPUT_A_PRESSED) != 0) {
        gAPressedFrames++;
    }
    if ((input & INPUT_A_DOWN) != 0) {
        gADownFrames++;
    }
    if (keys->A_BUTTON) {
        gControllerAFrames++;
    }
    if (act3) {
        gAct3RegionFrames++;
    }
    if (upper) {
        gUpperRegionFrames++;
    }
    if (gUpperTriggerObject != 0 && trigger_active == 0) {
        gTriggerEverInactive = 1;
    }
    if (counter > gMaxCounter) {
        gMaxCounter = counter;
    }

    fprintf(stderr,
            "TRACE,mode=%s,rel=%u,timer=%u,"
            "controllerA=%u,controllerB=%u,controllerZ=%u,"
            "axis=(%d,%d),action=%08x,input=%04x,"
            "aPressed=%u,aDown=%u,"
            "mario=(%.6f,%.6f,%.6f),"
            "vel=(%.6f,%.6f,%.6f),forwardVel=%.6f,"
            "floor=%08x,floorHeight=%.6f,platform=%08x,"
            "act3Region=%d,upperRegion=%d,"
            "trigger=%08x,triggerActive=%u,triggerBehavior=%08x,"
            "controller=%08x,counter=%d,controllerAction=%d\n",
            fixture_mode(), timer - gStartTimer, timer,
            keys->A_BUTTON, keys->B_BUTTON, keys->Z_TRIG,
            keys->X_AXIS, keys->Y_AXIS,
            R32(A_MARIO_STATES + M_ACTION), input,
            (input & INPUT_A_PRESSED) != 0,
            (input & INPUT_A_DOWN) != 0,
            x, y, z,
            rfloat(A_MARIO_STATES + M_VEL_X),
            rfloat(A_MARIO_STATES + M_VEL_Y),
            rfloat(A_MARIO_STATES + M_VEL_Z),
            rfloat(A_MARIO_STATES + M_FORWARD_VEL),
            R32(A_MARIO_STATES + M_FLOOR),
            rfloat(A_MARIO_STATES + M_FLOOR_HEIGHT),
            R32(A_MARIO_PLATFORM),
            act3, upper,
            gUpperTriggerObject, trigger_active,
            gUpperTriggerObject
                ? R32(gUpperTriggerObject + O_BEHAVIOR) : 0,
            gHiddenStarController, counter,
            gHiddenStarController
                ? (int32_t) R32(gHiddenStarController + O_ACTION) : -1);
}

EXPORT m64p_error CALL PluginStartup(
    m64p_dynlib_handle core,
    void *context,
    void (*debug_callback)(void *, int, const char *)) {
    (void) context;
    (void) debug_callback;

    R32 = (read32_fn) dlsym(core, "DebugMemRead32");
    R16 = (read16_fn) dlsym(core, "DebugMemRead16");
    W32 = (write32_fn) dlsym(core, "DebugMemWrite32");
    W8 = (write8_fn) dlsym(core, "DebugMemWrite8");
    if (!R32 || !R16 || !W32 || !W8) {
        return M64ERR_INCOMPATIBLE;
    }
    return M64ERR_SUCCESS;
}

EXPORT m64p_error CALL PluginShutdown(void) {
    return M64ERR_SUCCESS;
}

EXPORT m64p_error CALL PluginGetVersion(
    m64p_plugin_type *type,
    int *version,
    int *api_version,
    const char **name,
    int *capabilities) {
    if (type) {
        *type = M64PLUGIN_INPUT;
    }
    if (version) {
        *version = 0x000100;
    }
    if (api_version) {
        *api_version = 0x020100;
    }
    if (name) {
        *name = "SSL JP stale-top upper-trigger proof fixture";
    }
    if (capabilities) {
        *capabilities = 0;
    }
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
    gPoll = 0;
    gLastTimer = UINT32_MAX;
    gStartTimer = 0;
    gUpperTriggerObject = 0;
    gHiddenStarController = 0;
    gInitialCounter = -1;
    gMaxCounter = -1;
    gWarpRequested = 0;
    gStarted = 0;
    gPrintedPreStage = 0;
    gBoundaryObserved = 0;
    gFrames = 0;
    gAPressedFrames = 0;
    gADownFrames = 0;
    gControllerAFrames = 0;
    gAct3RegionFrames = 0;
    gUpperRegionFrames = 0;
    gTriggerEverInactive = 0;

    fprintf(stderr,
            "PROBE,version=JP,mode=%s,traceFrames=%d,"
            "schedule=axis(0,-127)-rel0-through-rel59;"
            "all-buttons-zero\n",
            fixture_mode(), TRACE_FRAMES);
    return 1;
}

EXPORT void CALL RomClosed(void) {
    fprintf(stderr,
            "RESULT,version=JP,mode=%s,frames=%d,"
            "aPressedFrames=%d,aDownFrames=%d,controllerAFrames=%d,"
            "act3RegionFrames=%d,upperRegionFrames=%d,"
            "triggerEverInactive=%d,initialCounter=%d,"
            "finalCounter=%d,maxCounter=%d,"
            "controllerAction=%d\n",
            fixture_mode(), gFrames,
            gAPressedFrames, gADownFrames, gControllerAFrames,
            gAct3RegionFrames, gUpperRegionFrames,
            gTriggerEverInactive, gInitialCounter,
            hidden_counter(), gMaxCounter,
            gHiddenStarController
                ? (int32_t) R32(gHiddenStarController + O_ACTION) : -1);
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

EXPORT void CALL RenderCallback(void) {
}

EXPORT void CALL SendVRUWord(uint16_t length, uint16_t *word,
                             uint8_t language) {
    (void) length;
    (void) word;
    (void) language;
}

EXPORT void CALL SetMicState(int state) {
    (void) state;
}

EXPORT void CALL ReadVRUResults(uint16_t *error_flags,
                                uint16_t *num_results,
                                uint16_t *mic_level,
                                uint16_t *voice_level,
                                uint16_t *voice_length,
                                uint16_t *matches) {
    if (error_flags) {
        *error_flags = 0;
    }
    if (num_results) {
        *num_results = 0;
    }
    if (mic_level) {
        *mic_level = 0;
    }
    if (voice_level) {
        *voice_level = 0;
    }
    if (voice_length) {
        *voice_length = 0;
    }
    (void) matches;
}

EXPORT void CALL ClearVRUWords(uint8_t length) {
    (void) length;
}

EXPORT void CALL SetVRUWordMask(uint8_t length, uint8_t *mask) {
    (void) length;
    (void) mask;
}

EXPORT void CALL GetKeys(int control, BUTTONS *keys) {
    uint64_t slot;
    uint16_t area;
    uint32_t timer;
    unsigned rel;

    memset(keys, 0, sizeof(*keys));
    if (control != 0) {
        return;
    }
    gPoll++;

    /*
     * Deterministic menu navigation with the retail level-select cheat:
     * enter file select, move to SSL, and start.  These inputs precede the
     * modeled Area-2 execution.
     */
    if (gPoll >= 150 && gPoll < 156) {
        keys->START_BUTTON = 1;
    }
    for (slot = 220; slot <= 280; slot += 10) {
        if (gPoll >= slot && gPoll < slot + 2) {
            keys->D_DPAD = 1;
        }
    }
    if (gPoll >= 330 && gPoll < 336) {
        keys->START_BUTTON = 1;
    }

    area = R16(A_CURR_AREA);
    if (!gWarpRequested && gPoll > 360 && area == 1
        && R32(A_MARIO_OBJECT) != 0) {
        uint16_t level = R16(A_CURR_LEVEL);

        /*
         * Request normal upper-pyramid node 0x14.  This is a setup fixture,
         * not part of a controller-only course-entry trace.
         */
        W8(A_WARP_DEST + 0, 2);
        W8(A_WARP_DEST + 1, (uint8_t) level);
        W8(A_WARP_DEST + 2, 2);
        W8(A_WARP_DEST + 3, 0x14);
        W32(A_WARP_DEST + 4, 0);
        gWarpRequested = 1;
        fprintf(stderr,
                "WARP_FIXTURE,level=%u,destLevel=%u,destArea=2,"
                "destNode=0x14,arg=0\n",
                level, level);
    }

    /*
     * Negative predecessor test: write the exact payload only while Area 1
     * still exists.  Area unload/reload is then allowed to run unmodified.
     */
    if (!STAGE_AT_AREA2_BOUNDARY && gWarpRequested && area == 1
        && R32(A_MARIO_OBJECT) != 0) {
        stage_stale_top();
        if (!gPrintedPreStage) {
            gPrintedPreStage = 1;
            log_slot("PRE_TRANSITION_STAGE");
        }
    }

    timer = R32(A_GLOBAL_TIMER);
    if (gWarpRequested && area == 2 && R32(A_MARIO_OBJECT) != 0) {
        if (!gBoundaryObserved) {
            find_hidden_star_objects();
            log_slot("AREA2_BEFORE");
            if (STAGE_AT_AREA2_BOUNDARY) {
                stage_stale_top();
                log_slot("AREA2_STAGED");
            }
            gBoundaryObserved = 1;
        }

        if (!gStarted) {
            gStarted = 1;
            gStartTimer = timer;
            gLastTimer = UINT32_MAX;
            fprintf(stderr,
                    "START,mode=%s,timer=%u,mario=(%.6f,%.6f,%.6f),"
                    "platform=%08x\n",
                    fixture_mode(), timer,
                    rfloat(A_MARIO_STATES + M_POS_X),
                    rfloat(A_MARIO_STATES + M_POS_Y),
                    rfloat(A_MARIO_STATES + M_POS_Z),
                    R32(A_MARIO_PLATFORM));
        }

        rel = timer - gStartTimer;
        apply_witness_input(keys, rel);
        if (timer != gLastTimer && gFrames < TRACE_FRAMES) {
            gLastTimer = timer;
            log_frame(timer, keys);
            gFrames++;
        }
    }
}
