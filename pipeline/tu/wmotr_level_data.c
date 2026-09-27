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
