/* GOAL-2 level-data translation unit (pipeline/tu/, TRUST.md 0.8).
 *
 * The real build puts these arrays in other TUs: levels/wmotr/leveldata.c
 * (terrain + macro objects, next to display lists we do not need) and the
 * actor group files (object collision meshes).  This wrapper #includes the
 * SAME vendor .inc.c files verbatim, with leveldata.c's header prelude, so
 * clightgen emits exactly their initializers and nothing else.  Nothing here
 * is hand-written data. */
#include <ultra64.h>
#include "sm64.h"
#include "surface_terrains.h"
#include "moving_texture_macros.h"
#include "level_misc_macros.h"
#include "macro_presets.h"
#include "special_presets.h"

#include "make_const_nonconst.h"
/* WMotR area 1 static terrain and macro-object list (leveldata.c:13-14) */
#include "levels/wmotr/areas/1/collision.inc.c"
#include "levels/wmotr/areas/1/macro.inc.c"
/* the collision meshes of the only WMotR objects that load collision
   (behavior_data.c: bhvExclamationBox, bhvCannonClosed) */
#include "actors/exclamation_box_outline/collision.inc.c"
#include "actors/cannon_lid/collision.inc.c"
/* the warp pipe's mesh: interact_warp compares o->collisionData against it
   (interaction.c:881,889); without a definition it is a size-0 block and
   that compare has no execution (tools/size0_globals.py, 2026-10-22) */
#include "actors/warp_pipe/collision.inc.c"
/* the animation tables of the WMotR closure's animated objects (2026-10-26,
   B3 iii-b; FOUND by the BhvVM census, now BhvVM.closure_data_linked /
   vm_data_args_linked): behavior_data.c's
   LOAD_ANIMATIONS / the natives' cur_obj_init_animation read them through
   o->oAnimations, and while only declared they were size-0 blocks, so the
   placed bob-omb buddy's first ANIMATE had no execution.  The real build
   puts them in the actor group files (actors/common0.c: bobomb;
   group3 / group10 / group15 / common1: the rest); these are the same
   vendor .inc.c files, verbatim. */
#include "actors/bobomb/anims/data.inc.c"
#include "actors/bobomb/anims/table.inc.c"
#include "actors/blue_fish/anims/data.inc.c"
#include "actors/blue_fish/anims/table.inc.c"
#include "actors/bowser_key/anims/data.inc.c"
#include "actors/bowser_key/anims/table.inc.c"
#include "actors/peach/anims/data.inc.c"
#include "actors/peach/anims/table.inc.c"
#include "actors/toad/anims/data.inc.c"
#include "actors/toad/anims/table.inc.c"
