/* Read-only original-JP observer for controller-produced western Fly Guy use.
 * No game-memory write API or gameplay setup cut is added here. */
#define M64P_PLUGIN_PROTOTYPES
#include <mupen64plus/m64p_plugin.h>
static void fly_observe(int control, BUTTONS *keys);
#define WAFEL_PILOT_EXTRA_INPUT fly_observe
#include "../wafel-jp-pilot/capture.c"

static void fly_observe(int control, BUTTONS *keys) {
    uint32_t fly=A_OBJECT_POOL+45*OBJECT_SIZE;
    /* Pinned original-JP Object offsets from include/object_fields.h. */
    static const unsigned offsets[]={0xa0,0xa4,0xa8,0xac,0xb0,0xb4,0xb8,
        0xc4,0xc8,0xcc,0xd0,0xd4,0xd8,0xf4,0xf8,0x100,0x104,0x108,0x10c,
        0x14c,0x150,0x154,0x15c,0x164,0x168,0x16c,0x190,0x134,0x2c,0x30,0x34};
    unsigned i;
    if(control || R16(A_CURR_AREA)!=1 || pilot_slot(R32(A_MARIO_OBJECT))<0)return;
    if(keys->A_BUTTON)abort();
    fprintf(stderr,"FLY_NATIVE,{\"poll\":%llu,\"timer\":%u,\"used\":%d,\"held\":%d,\"flyActive\":%u,\"flyBehavior\":%u,\"flyWords\":[",
        (unsigned long long)gPoll,R32(A_GLOBAL_TIMER),
        pilot_slot(R32(A_MARIO_STATES+M_USED_OBJ)),pilot_slot(R32(A_MARIO_STATES+M_HELD_OBJ)),
        R16(fly+O_ACTIVE_FLAGS),R32(fly+O_BEHAVIOR));
    for(i=0;i<sizeof(offsets)/sizeof(offsets[0]);i++)fprintf(stderr,"%s%u",i?",":"",R32(fly+offsets[i]));
    fprintf(stderr,"]}\n");
}
