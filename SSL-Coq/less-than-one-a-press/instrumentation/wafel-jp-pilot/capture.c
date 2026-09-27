/* Observe the original replay or a supplied controller-only input schedule.
 * No gameplay state writes are added. */
#define M64P_PLUGIN_PROTOTYPES
#include <stdlib.h>
#include <mupen64plus/m64p_plugin.h>
static void pilot_observe_input(int control, BUTTONS *keys);
#define WARP_ACCEPT_INPUT_OBSERVER pilot_observe_input
#include "../jp-warp-acceptance/probe.c"

static int pilot_slot(uint32_t ptr) {
    if (ptr == 0) return -1;
    if (ptr < A_OBJECT_POOL || ptr >= A_OBJECT_POOL + OBJECT_COUNT * OBJECT_SIZE
        || (ptr - A_OBJECT_POOL) % OBJECT_SIZE != 0) return -2;
    return (int)((ptr - A_OBJECT_POOL) / OBJECT_SIZE);
}

static void pilot_override(BUTTONS *keys) {
    static FILE *input;
    static int initialized;
    unsigned long long poll;
    unsigned buttons;
    int x, y;
    if (!initialized) {
        const char *path = getenv("WAFEL_PILOT_INPUTS");
        initialized = 1;
        if (path && !(input = fopen(path, "r"))) abort();
    }
    if (!input) return;
    if (fscanf(input, "%llu %u %d %d", &poll, &buttons, &x, &y) != 4
        || poll != gPoll || (buttons & 0x8000) || buttons > 65535
        || x < -128 || x > 127 || y < -128 || y > 127) abort();
    memset(keys, 0, sizeof(*keys));
    keys->B_BUTTON = !!(buttons & 0x4000); keys->Z_TRIG = !!(buttons & 0x2000);
    keys->START_BUTTON = !!(buttons & 0x1000);
    keys->U_DPAD = !!(buttons & 0x0800); keys->D_DPAD = !!(buttons & 0x0400);
    keys->L_DPAD = !!(buttons & 0x0200); keys->R_DPAD = !!(buttons & 0x0100);
    keys->L_TRIG = !!(buttons & 0x0020); keys->R_TRIG = !!(buttons & 0x0010);
    keys->U_CBUTTON = !!(buttons & 0x0008); keys->D_CBUTTON = !!(buttons & 0x0004);
    keys->L_CBUTTON = !!(buttons & 0x0002); keys->R_CBUTTON = !!(buttons & 0x0001);
    keys->X_AXIS = x; keys->Y_AXIS = y;
}

static void pilot_observe_input(int control, BUTTONS *keys) {
    uint32_t object, floor;
    unsigned buttons, axis;
    if (control != 0) return;
    pilot_override(keys);
    buttons = (keys->A_BUTTON ? 0x8000 : 0) | (keys->B_BUTTON ? 0x4000 : 0)
        | (keys->Z_TRIG ? 0x2000 : 0) | (keys->START_BUTTON ? 0x1000 : 0)
        | (keys->U_DPAD ? 0x0800 : 0) | (keys->D_DPAD ? 0x0400 : 0)
        | (keys->L_DPAD ? 0x0200 : 0) | (keys->R_DPAD ? 0x0100 : 0)
        | (keys->L_TRIG ? 0x0020 : 0) | (keys->R_TRIG ? 0x0010 : 0)
        | (keys->U_CBUTTON ? 0x0008 : 0) | (keys->D_CBUTTON ? 0x0004 : 0)
        | (keys->L_CBUTTON ? 0x0002 : 0) | (keys->R_CBUTTON ? 0x0001 : 0);
    fprintf(stderr, "WAFEL_PILOT,{\"poll\":%llu,\"timer\":%u,\"area\":%u,"
        "\"buttons\":%u,\"stick\":[%d,%d]",
        (unsigned long long)gPoll, R32(A_GLOBAL_TIMER), R16(A_CURR_AREA),
        buttons, keys->X_AXIS, keys->Y_AXIS);
    object = R32(A_MARIO_OBJECT);
    if (R16(A_CURR_AREA) == 1 && pilot_slot(object) >= 0) {
        floor = R32(A_MARIO_STATES + M_FLOOR);
        fprintf(stderr, ",\"action\":%u,\"actionTimer\":%u,\"input\":%u,\"positions\":[",
            R32(A_MARIO_STATES + M_ACTION), R16(A_MARIO_STATES + M_ACTION_TIMER),
            R16(A_MARIO_STATES + M_INPUT));
        for (axis = 0; axis < 3; axis++) fprintf(stderr, "%s%u", axis ? "," : "", R32(A_MARIO_STATES + M_POS_X + 4 * axis));
        for (axis = 0; axis < 3; axis++) fprintf(stderr, ",%u", R32(object + O_POS_X + 4 * axis));
        for (axis = 0; axis < 3; axis++) fprintf(stderr, ",%u", R32(object + GFX_POS_X + 4 * axis));
        fprintf(stderr, "],\"floorHeight\":%u,\"floorNull\":%u,\"floorOwner\":%d,"
            "\"platform\":%d,\"marioSlot\":%d",
            R32(A_MARIO_STATES + M_FLOOR_HEIGHT), floor == 0,
            floor ? pilot_slot(R32(floor + SURFACE_OBJECT)) : -1,
            pilot_slot(R32(A_MARIO_PLATFORM)), pilot_slot(object));
        if (waOriginalTop) fprintf(stderr, ",\"topSlot\":%d,\"topTimer\":%u,\"topAction\":%u,\"pillars\":%u,\"topActive\":%u",
            pilot_slot(waOriginalTop), R32(waOriginalTop + O_TIMER), R32(waOriginalTop + O_ACTION),
            R32(waOriginalTop + O_PYRAMID_PILLARS_TOUCHED), R16(waOriginalTop + O_ACTIVE_FLAGS));
    }
    fprintf(stderr, "}\n");
#ifdef WAFEL_PILOT_EXTRA_INPUT
    WAFEL_PILOT_EXTRA_INPUT(control, keys);
#endif
}
