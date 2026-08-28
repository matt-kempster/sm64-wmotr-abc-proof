#define JP_FULL_ROUTE_GET_KEYS DownstreamGetKeys
#define JP_FULL_ROUTE_ROM_CLOSED DownstreamRomClosed
#include "../jp-full-route/jp_full_route_probe.c"
#undef JP_FULL_ROUTE_GET_KEYS
#undef JP_FULL_ROUTE_ROM_CLOSED

/*
 * Conditional controller reconstruction for the published lower-entrance
 * one-A route.  The inherited hash-gated JP fixture loads SSL Area 2.  This
 * wrapper then stages the real Mario and real second-pole objects at the
 * top-of-pole action.  From that explicit injected boundary onward, gameplay
 * changes only through controller input: one A rising edge performs the pole
 * jump, that same press remains held during the useful ascent, and the
 * inherited downstream controller supplies stick/B/Z after A is released.
 *
 * This is deliberately not a clean lower-entrance trace.  It isolates and
 * records the controller suffix so that a later clean prefix can be joined
 * without confusing the pole jump with the Grindel landing.
 */

enum {
    LOWER_M_PREV_ACTION = 0x10,
    LOWER_M_ACTION_STATE_TIMER = 0x18,
    LOWER_M_FACE_ANGLE = 0x2c,
    LOWER_M_VEL_X = 0x48,
    LOWER_M_VEL_Y = 0x4c,
    LOWER_M_VEL_Z = 0x50,
    LOWER_M_FORWARD_VEL = 0x54,
    LOWER_M_INTERACT_OBJ = 0x78,
    LOWER_O_MARIO_POLE_YAW_VEL = 0x10c,
    LOWER_O_MARIO_POLE_POS = 0x110,
    LOWER_O_MOVE_ANGLE_YAW = 0x0c8,
    LOWER_O_FACE_ANGLE_YAW = 0x0d4,
};

enum {
    LOWER_ACT_TOP_OF_POLE_JUMP = 0x0300088d,
    LOWER_ACT_TOP_OF_POLE = 0x00100345,
    LOWER_A_HOLD_POLLS = 34,
};

static uint32_t gLowerPole;
static uint32_t gLowerGrindel;
static uint32_t gLowerStageTimer;
static unsigned gLowerArea2Poll;
static int gLowerStaged;
static int gLowerSawPoleJump;
static int gLowerSawSixthFloorLanding;
static int gLowerSawGrindelLanding;
static int gLowerAtGrindelBase;
static int gLowerMisalignmentStage;
static int gLowerEgressStage;
static int gLowerInjectedAFrames;
static int gLowerInputChanges;
static int gLowerHavePreviousInput;
static uint32_t gLowerLastAction = UINT32_MAX;
static BUTTONS gLowerPreviousInput;

static uint32_t lower_find_second_pole(void) {
    unsigned index;

    for (index = 0; index < OBJECT_COUNT; index++) {
        uint32_t candidate = pool_pointer(index);
        if (R16(candidate + O_ACTIVE_FLAGS) != 0
            && rfloat(candidate + O_POS_X) == 0.0f
            && rfloat(candidate + O_POS_Y) == 3200.0f
            && rfloat(candidate + O_POS_Z) == 1331.0f) {
            return candidate;
        }
    }
    return 0;
}

static uint32_t lower_find_upper_grindel(void) {
    unsigned index;

    for (index = 0; index < OBJECT_COUNT; index++) {
        uint32_t candidate = pool_pointer(index);
        if (R16(candidate + O_ACTIVE_FLAGS) != 0
            && rfloat(candidate + O_POS_X) == -870.0f
            && rfloat(candidate + O_POS_Y) == 3840.0f
            && rfloat(candidate + O_POS_Z) == 105.0f) {
            return candidate;
        }
    }
    return 0;
}

static void lower_stage_top_of_second_pole(uint32_t pole) {
    uint32_t mario = R32(A_MARIO_OBJECT);
    uint32_t face_word = R32(A_MARIO_STATES + LOWER_M_FACE_ANGLE);

    W32(A_MARIO_STATES + M_ACTION, LOWER_ACT_TOP_OF_POLE);
    W32(A_MARIO_STATES + LOWER_M_PREV_ACTION, LOWER_ACT_TOP_OF_POLE);
    W32(A_MARIO_STATES + LOWER_M_ACTION_STATE_TIMER, 0);
    W32(A_MARIO_STATES + M_ACTION_ARG, 0);
    W32(A_MARIO_STATES + LOWER_M_FACE_ANGLE,
        (face_word & 0xffff0000u) | 0x9e57u);
    W32(A_MARIO_STATES + M_POS_X, fbits(0.0f));
    W32(A_MARIO_STATES + M_POS_Y, fbits(4020.0f));
    W32(A_MARIO_STATES + M_POS_Z, fbits(1331.0f));
    W32(A_MARIO_STATES + LOWER_M_VEL_X, 0);
    W32(A_MARIO_STATES + LOWER_M_VEL_Y, 0);
    W32(A_MARIO_STATES + LOWER_M_VEL_Z, 0);
    /* Pole actions retain approach speed.  This conditional search value is
       kept explicit; a clean prefix must derive it before this can be called
       a reconstruction of the published route. */
    W32(A_MARIO_STATES + LOWER_M_FORWARD_VEL, fbits(32.0f));
    W32(A_MARIO_STATES + LOWER_M_INTERACT_OBJ, pole);
    W32(A_MARIO_STATES + M_USED_OBJ, pole);
    W32(mario + LOWER_O_MARIO_POLE_YAW_VEL, 0);
    W32(mario + LOWER_O_MARIO_POLE_POS, fbits(820.0f));
    W32(mario + O_POS_X, fbits(0.0f));
    W32(mario + O_POS_Y, fbits(4020.0f));
    W32(mario + O_POS_Z, fbits(1331.0f));
    W32(mario + GFX_POS_X, fbits(0.0f));
    W32(mario + GFX_POS_Y, fbits(4020.0f));
    W32(mario + GFX_POS_Z, fbits(1331.0f));
}

static void lower_log_input_change(const BUTTONS *keys) {
    uint32_t timer = R32(A_GLOBAL_TIMER);
    uint32_t action = R32(A_MARIO_STATES + M_ACTION);

    if (gLowerHavePreviousInput
        && memcmp(keys, &gLowerPreviousInput, sizeof(*keys)) == 0) {
        return;
    }
    gLowerPreviousInput = *keys;
    gLowerHavePreviousInput = 1;
    gLowerInputChanges++;
    fprintf(stderr,
            "LOWER_INPUT,%u,%u,%u,%u,%u,%d,%d,%08x,%.9g,%.9g,%.9g\n",
            timer, gLowerArea2Poll,
            (unsigned) keys->A_BUTTON, (unsigned) keys->B_BUTTON,
            (unsigned) keys->Z_TRIG,
            (int) keys->X_AXIS, (int) keys->Y_AXIS, action,
            rfloat(A_MARIO_STATES + M_POS_X),
            rfloat(A_MARIO_STATES + M_POS_Y),
            rfloat(A_MARIO_STATES + M_POS_Z));
}

EXPORT void CALL GetKeys(int control, BUTTONS *keys) {
    uint16_t area;
    uint32_t action;
    float floor_height;

    DownstreamGetKeys(control, keys);
    if (control != 0) return;

    area = R16(A_CURR_AREA);
    if (!gBoundaryInstalled || area != 2 || R32(A_MARIO_OBJECT) == 0) {
        return;
    }
    gLowerArea2Poll++;

    if (!gLowerStaged) {
        gLowerPole = lower_find_second_pole();
        gLowerGrindel = lower_find_upper_grindel();
        if (gLowerPole == 0 || gLowerGrindel == 0) return;

        lower_stage_top_of_second_pole(gLowerPole);
        memset(keys, 0, sizeof(*keys));
        keys->A_BUTTON = 1;
        gLowerInjectedAFrames = 1;
        gControllerAFrames++;
        gLowerStageTimer = R32(A_GLOBAL_TIMER);
        gLowerStaged = 1;
        fprintf(stderr,
                "LOWER_ONE_A_STAGE,timer=%u,pole=%08x,mario=%08x,"
                "grindel=%08x,grindelPos=(%.9g,%.9g,%.9g),"
                "action=%08x,pos=(%.9g,%.9g,%.9g),faceYaw=9e57\n",
                gLowerStageTimer, gLowerPole, R32(A_MARIO_OBJECT),
                gLowerGrindel,
                rfloat(gLowerGrindel + O_POS_X),
                rfloat(gLowerGrindel + O_POS_Y),
                rfloat(gLowerGrindel + O_POS_Z),
                R32(A_MARIO_STATES + M_ACTION),
                rfloat(A_MARIO_STATES + M_POS_X),
                rfloat(A_MARIO_STATES + M_POS_Y),
                rfloat(A_MARIO_STATES + M_POS_Z));
        lower_log_input_change(keys);
        return;
    }

    /* One ABC press is one rising edge.  Keep the same press held through the
       pole-jump arc; releasing immediately invokes strengthened ascent gravity
       and destroys the published route's useful flight. */
    if (gLowerArea2Poll <= LOWER_A_HOLD_POLLS) {
        keys->A_BUTTON = 1;
        gLowerInjectedAFrames++;
        gControllerAFrames++;
    } else {
        keys->A_BUTTON = 0;
    }
    action = R32(A_MARIO_STATES + M_ACTION);
    floor_height = rfloat(A_MARIO_STATES + M_FLOOR_HEIGHT);
    if (action != gLowerLastAction) {
        gLowerLastAction = action;
        fprintf(stderr,
                "LOWER_ACTION,timer=%u,relative=%u,action=%08x,"
                "pos=(%.9g,%.9g,%.9g),platform=%08x,"
                "grindelPos=(%.9g,%.9g,%.9g),moveYaw=%04x,faceYaw=%04x\n",
                R32(A_GLOBAL_TIMER), R32(A_GLOBAL_TIMER) - gLowerStageTimer,
                action,
                rfloat(A_MARIO_STATES + M_POS_X),
                rfloat(A_MARIO_STATES + M_POS_Y),
                rfloat(A_MARIO_STATES + M_POS_Z), R32(A_MARIO_PLATFORM),
                rfloat(gLowerGrindel + O_POS_X),
                rfloat(gLowerGrindel + O_POS_Y),
                rfloat(gLowerGrindel + O_POS_Z),
                R16(gLowerGrindel + LOWER_O_MOVE_ANGLE_YAW + 2),
                R16(gLowerGrindel + LOWER_O_FACE_ANGLE_YAW + 2));
    }

    /* This is an exploratory conditional pole-to-Grindel input search, not a
       claim that the video used this direct line.  Aim west of the live
       Grindel's centre so the first supported landing is close to its base. */
    if (!gLowerAtGrindelBase && !gLowerSawGrindelLanding
        && rfloat(A_MARIO_STATES + M_POS_Y) == 3840.0f
        && rfloat(A_MARIO_STATES + M_POS_X) < -640.0f
        && rfloat(A_MARIO_STATES + M_POS_X) > -1120.0f
        && rfloat(A_MARIO_STATES + M_POS_Z) > 329.0f
        && rfloat(A_MARIO_STATES + M_POS_Z) < 430.0f) {
        gLowerAtGrindelBase = 1;
        fprintf(stderr,
                "LOWER_GRINDEL_BASE,timer=%u,relative=%u,action=%08x,"
                "pos=(%.9g,%.9g,%.9g)\n",
                R32(A_GLOBAL_TIMER), R32(A_GLOBAL_TIMER) - gLowerStageTimer,
                action,
                rfloat(A_MARIO_STATES + M_POS_X),
                rfloat(A_MARIO_STATES + M_POS_Y),
                rfloat(A_MARIO_STATES + M_POS_Z));
    }

    if (!gLowerSawGrindelLanding && !gLowerAtGrindelBase) {
        keys->B_BUTTON = 0;
        keys->Z_TRIG = 0;
        steer_world_direct(keys,
            rfloat(gLowerGrindel + O_POS_X) - 260.0f,
            rfloat(gLowerGrindel + O_POS_Z));
    } else if (!gLowerSawGrindelLanding) {
        float x = rfloat(A_MARIO_STATES + M_POS_X);
        float z = rfloat(A_MARIO_STATES + M_POS_Z);

        keys->B_BUTTON = 0;
        keys->Z_TRIG = 0;
        if (gLowerMisalignmentStage == 0) {
            /* First line up with the corner's one-unit Z band while Mario is
               still supported by the safe base.  A diagonal approach carries
               too much +Z momentum and misses the floor-only column. */
            steer_world_direct(keys, -1040.0f, 336.0f);
            if (rfloat(A_MARIO_STATES + M_POS_Y) == 3840.0f
                && x <= -1020.0f && z >= 334.0f && z <= 338.0f) {
                gLowerMisalignmentStage = 1;
                fprintf(stderr,
                        "LOWER_MISALIGNMENT,timer=%u,stage=1,"
                        "pos=(%.9g,%.9g,%.9g)\n",
                        R32(A_GLOBAL_TIMER), x,
                        rfloat(A_MARIO_STATES + M_POS_Y),
                        z);
            }
        } else {
            /* With bounds [-1094,-646] x [-119,329], truncation at this
               far/far corner selects the one-unit floor-only square. */
            steer_world_direct(keys, -1094.5f, 329.5f);
        }
    }
    if (action == LOWER_ACT_TOP_OF_POLE_JUMP && !gLowerSawPoleJump) {
        gLowerSawPoleJump = 1;
        fprintf(stderr,
                "LOWER_POLE_JUMP,timer=%u,relative=%u,action=%08x,"
                "pos=(%.9g,%.9g,%.9g),forwardVel=%.9g\n",
                R32(A_GLOBAL_TIMER), R32(A_GLOBAL_TIMER) - gLowerStageTimer,
                action,
                rfloat(A_MARIO_STATES + M_POS_X),
                rfloat(A_MARIO_STATES + M_POS_Y),
                rfloat(A_MARIO_STATES + M_POS_Z),
                rfloat(A_MARIO_STATES + ROUTE_M_FORWARD_VEL));
    }
    if (gLowerSawPoleJump && !gLowerSawSixthFloorLanding
        && floor_height == 3942.0f
        && action != LOWER_ACT_TOP_OF_POLE_JUMP) {
        gLowerSawSixthFloorLanding = 1;
        fprintf(stderr,
                "LOWER_SIXTH_FLOOR,timer=%u,relative=%u,action=%08x,"
                "pos=(%.9g,%.9g,%.9g),floor=%.9g\n",
                R32(A_GLOBAL_TIMER), R32(A_GLOBAL_TIMER) - gLowerStageTimer,
                action,
                rfloat(A_MARIO_STATES + M_POS_X),
                rfloat(A_MARIO_STATES + M_POS_Y),
                rfloat(A_MARIO_STATES + M_POS_Z), floor_height);
    }
    if (!gLowerSawGrindelLanding
        && R32(A_MARIO_PLATFORM) == gLowerGrindel) {
        gLowerSawGrindelLanding = 1;
        fprintf(stderr,
                "LOWER_GRINDEL_LANDING,timer=%u,relative=%u,action=%08x,"
                "pos=(%.9g,%.9g,%.9g),grindelPos=(%.9g,%.9g,%.9g)\n",
                R32(A_GLOBAL_TIMER), R32(A_GLOBAL_TIMER) - gLowerStageTimer,
                action,
                rfloat(A_MARIO_STATES + M_POS_X),
                rfloat(A_MARIO_STATES + M_POS_Y),
                rfloat(A_MARIO_STATES + M_POS_Z),
                rfloat(gLowerGrindel + O_POS_X),
                rfloat(gLowerGrindel + O_POS_Y),
                rfloat(gLowerGrindel + O_POS_Z));
    }

    /* The direct upper-trigger line runs back across the pole aperture and
       can re-grab the pole.  Follow the north rim east first, then move north
       with X clearance, before releasing control to the existing route. */
    if (gLowerSawSixthFloorLanding && !gLowerSawGrindelLanding
        && gRouteMaxCounter <= 0
        && gLowerEgressStage < 2) {
        float x = rfloat(A_MARIO_STATES + M_POS_X);
        float z = rfloat(A_MARIO_STATES + M_POS_Z);

        keys->B_BUTTON = 0;
        keys->Z_TRIG = 0;
        if (gLowerEgressStage == 0) {
            steer_world_direct(keys, 420.0f, 1120.0f);
            if (x >= 340.0f) {
                gLowerEgressStage = 1;
                fprintf(stderr,
                        "LOWER_EGRESS,timer=%u,stage=1,pos=(%.9g,%.9g,%.9g)\n",
                        R32(A_GLOBAL_TIMER), x,
                        rfloat(A_MARIO_STATES + M_POS_Y), z);
            }
        } else {
            steer_world_direct(keys, 420.0f, 650.0f);
            if (z <= 760.0f) {
                gLowerEgressStage = 2;
                fprintf(stderr,
                        "LOWER_EGRESS,timer=%u,stage=2,pos=(%.9g,%.9g,%.9g)\n",
                        R32(A_GLOBAL_TIMER), x,
                        rfloat(A_MARIO_STATES + M_POS_Y), z);
            }
        }
    }
    lower_log_input_change(keys);
}

EXPORT void CALL RomClosed(void) {
    fprintf(stderr,
            "LOWER_ONE_A_RESULT,staged=%d,pole=%08x,stageTimer=%u,"
            "grindel=%08x,poleJump=%d,sixthFloor=%d,grindelLanding=%d,"
            "grindelBase=%d,misalignmentStage=%d,egressStage=%d,"
            "inputChanges=%d,injectedAFrames=%d,"
            "aPressedFrames=%d,aDownFrames=%d,controllerAFrames=%d,"
            "maxCounter=%d,sawFive=%d,sawAct6Star=%d,act6BitTransition=%d\n",
            gLowerStaged, gLowerPole, gLowerStageTimer, gLowerGrindel,
            gLowerSawPoleJump, gLowerSawSixthFloorLanding,
            gLowerSawGrindelLanding, gLowerAtGrindelBase,
            gLowerMisalignmentStage, gLowerEgressStage,
            gLowerInputChanges, gLowerInjectedAFrames,
            gAPressedFrames, gADownFrames, gControllerAFrames,
            gRouteMaxCounter, gRouteSawFive, gRouteSawAct6Star,
            gSawAct6BitTransition);
    DownstreamRomClosed();
}
