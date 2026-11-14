/* Read-only original-JP observations for native small-box delivery. */
#define M64P_PLUGIN_PROTOTYPES
#include <mupen64plus/m64p_plugin.h>
static void delivery_observe(int control, BUTTONS *keys);
#define WAFEL_PILOT_EXTRA_INPUT delivery_observe
#include "../wafel-jp-pilot/capture.c"
static void delivery_observe(int control, BUTTONS *keys) {
 uint32_t box=A_OBJECT_POOL+23*OBJECT_SIZE;
 if(control || R16(A_CURR_AREA)!=1 || pilot_slot(R32(A_MARIO_OBJECT))<0)return;
 if(keys->A_BUTTON)abort();
 fprintf(stderr,"SMALLBOX_DELIVERY,{\"poll\":%llu,\"timer\":%u,\"used\":%d,\"held\":%d,\"boxBits\":[%u,%u,%u],\"boxHeld\":%u,\"boxAction\":%u,\"boxActive\":%u,\"boxBehavior\":%u}\n",
 (unsigned long long)gPoll,R32(A_GLOBAL_TIMER),pilot_slot(R32(A_MARIO_STATES+M_USED_OBJ)),pilot_slot(R32(A_MARIO_STATES+M_HELD_OBJ)),
 R32(box+O_POS_X),R32(box+O_POS_Y),R32(box+O_POS_Z),R32(box+0x124),R32(box+O_ACTION),R16(box+O_ACTIVE_FLAGS),R32(box+O_BEHAVIOR));
}
