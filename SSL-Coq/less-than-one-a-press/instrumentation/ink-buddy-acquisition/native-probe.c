/* Read-only original-JP observer for a complete all-A-off input history.
 * This wrapper imports no memory-write API and supplies no gameplay cut. */
#define M64P_PLUGIN_PROTOTYPES
#include <mupen64plus/m64p_plugin.h>
static void buddy_acquisition_observe(int control, BUTTONS *keys);
#define WAFEL_PILOT_EXTRA_INPUT buddy_acquisition_observe
#include "../wafel-jp-pilot/capture.c"

static void buddy_acquisition_observe(int control, BUTTONS *keys) {
    uint32_t buddy=A_OBJECT_POOL+15*OBJECT_SIZE, box=A_OBJECT_POOL+49*OBJECT_SIZE;
    if (control || R16(A_CURR_AREA)!=1 || pilot_slot(R32(A_MARIO_OBJECT))<0) return;
    if (keys->A_BUTTON) abort();
    fprintf(stderr,"BUDDY_ACQUIRE,{\"poll\":%llu,\"timer\":%u,\"action\":%u,\"actionState\":%u,\"used\":%d,\"held\":%d,\"interact\":%d,\"buddyBits\":[%u,%u,%u],\"buddyHeld\":%u,\"buddyAction\":%u,\"buddyActive\":%u,\"buddyBehavior\":%u,\"boxBits\":[%u,%u,%u],\"boxHeld\":%u,\"boxAction\":%u,\"boxActive\":%u,\"boxBehavior\":%u}\n",
        (unsigned long long)gPoll,R32(A_GLOBAL_TIMER),R32(A_MARIO_STATES+M_ACTION),R16(A_MARIO_STATES+0x18),
        pilot_slot(R32(A_MARIO_STATES+M_USED_OBJ)),pilot_slot(R32(A_MARIO_STATES+M_HELD_OBJ)),pilot_slot(R32(A_MARIO_STATES+0x78)),
        R32(buddy+O_POS_X),R32(buddy+O_POS_Y),R32(buddy+O_POS_Z),R32(buddy+0x124),R32(buddy+O_ACTION),R16(buddy+O_ACTIVE_FLAGS),R32(buddy+O_BEHAVIOR),
        R32(box+O_POS_X),R32(box+O_POS_Y),R32(box+O_POS_Z),R32(box+0x124),R32(box+O_ACTION),R16(box+O_ACTIVE_FLAGS),R32(box+O_BEHAVIOR));
}
