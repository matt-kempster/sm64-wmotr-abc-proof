#include <PR/ultratypes.h>

#include "sm64.h"
#include "audio/external.h"
#include "engine/behavior_script.h"
#include "engine/math_util.h"
#include "game_init.h"
#include "object_constants.h"
#include "object_fields.h"
#include "object_helpers.h"
#include "object_list_processor.h"
#include "spawn_sound.h"

/* Translation shim for the canonical Grindel/Thwomp behavior source. */
#define o gCurrentObject
#include "behaviors/thwomp.inc.c"
