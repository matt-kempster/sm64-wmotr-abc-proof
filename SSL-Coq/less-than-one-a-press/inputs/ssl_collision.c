#include <PR/ultratypes.h>
#include "sm64.h"

#include "level_misc_macros.h"
#include "special_presets.h"
#include "surface_terrains.h"

/*
 * Collision-only wrapper for the static and object collision data that can
 * participate in an SSL Area 2/Area 3 route or in the Area 1 predecessor of
 * a clean pyramid entry.  Keeping the include order from levels/ssl/leveldata.c
 * makes the generated initializers directly comparable with the pinned
 * decomp translation unit.
 */
#include "levels/ssl/areas/1/collision.inc.c"
#include "levels/ssl/pyramid_top/collision.inc.c"
#include "levels/ssl/tox_box/collision.inc.c"
#include "actors/breakable_box/collision.inc.c"
#include "actors/exclamation_box_outline/collision.inc.c"
#include "actors/cannon_lid/collision.inc.c"
#include "actors/wooden_signpost/collision.inc.c"
#include "levels/ssl/areas/2/collision.inc.c"
#include "levels/ssl/areas/3/collision.inc.c"
#include "levels/ssl/grindel/collision.inc.c"
#include "levels/ssl/spindel/collision.inc.c"
#include "levels/ssl/moving_pyramid_wall/collision.inc.c"
#include "levels/ssl/pyramid_elevator/collision.inc.c"
#include "levels/ssl/eyerok_col/collision.inc.c"
