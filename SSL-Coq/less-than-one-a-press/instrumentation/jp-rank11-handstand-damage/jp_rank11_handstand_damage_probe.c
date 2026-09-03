#define JP_RANK11_GET_KEYS HandstandBaseGetKeys
#define JP_RANK11_ROM_CLOSED HandstandBaseRomClosed
#include "../jp-rank11-pole-release/jp_rank11_pole_release_probe.c"
#undef JP_RANK11_GET_KEYS
#undef JP_RANK11_ROM_CLOSED

/* PAYOFF FIXTURE, NOT AN INSTALLER.  The inherited loader and pole fixture
 * are unchanged.  The only additional writes relocate one genuine, already
 * spawned regular Goomba.  No Mario action, velocity, animation, collision
 * status, table or code is written to manufacture the damage response.
 * Mode 0 collides at the steady handstand, mode 1 at ordinary holding, and
 * mode 2 on the last reverse-animation frame (before its pole reset).
 */
#ifndef HANDSTAND_DAMAGE_MODE
#define HANDSTAND_DAMAGE_MODE 0
#endif

enum {
    H11_HOME_X = 0x164, H11_HOME_Y = 0x168, H11_HOME_Z = 0x16c,
    H11_DAMAGE = 0x180, H11_INTANGIBLE_TIMER = 0x09c,
    H11_BACKWARD_AIR_KB = 0x010208b0,
    H11_FORWARD_AIR_KB = 0x010208b1,
};

static uint32_t gH11Goomba, gH11Timer = UINT32_MAX;
static unsigned gH11ReadyPolls, gH11ExtraWrites, gH11Samples;
static int gH11Placed, gH11SawKnockback, gH11Crossed;
static float gH11ContactY, gH11FirstY, gH11MinZ = 1000000.0f;

static uint32_t handstand_find_goomba(void) {
    unsigned i;
    uint32_t found = 0;
    for (i = 0; i < OBJECT_COUNT; i++) {
        uint32_t object = pool_pointer(i);
        /* Exact first singleton's home X/Z from ssl/areas/2/macro.inc.c,
         * plus its ordinary interaction and damage fields.  bhvGoomba does
         * DROP_TO_FLOOR before SET_HOME, so home Y is NOT the spawn's 778.
         * Require a unique match and print the real behavior and home Y. */
        if (R16(object + O_ACTIVE_FLAGS) != 0
            && rfloat(object + H11_HOME_X) == 3263.0f
            && rfloat(object + H11_HOME_Z) == 3157.0f
            && R32(object + ROUTE_O_INTERACT_TYPE) == 0x8000u
            && R32(object + H11_DAMAGE) == 1u) {
            if (found) return 0;
            found = object;
        }
    }
    return found;
}

static void handstand_place_goomba(float y) {
    static const unsigned offsets[] = {O_POS_X, O_POS_Y, O_POS_Z};
    float coordinates[] = {0.0f, y, 1371.0f};
    unsigned i;
    fprintf(stderr, "H11_BEFORE_GOOMBA,timer=%u,object=%08x,behavior=%08x,"
            "action=%u,flags=%04x,intangible=%d,pos=(%.9g,%.9g,%.9g),"
            "home=(%.9g,%.9g,%.9g)\n", R32(A_GLOBAL_TIMER), gH11Goomba,
            R32(gH11Goomba + O_BEHAVIOR), R32(gH11Goomba + O_ACTION),
            R16(gH11Goomba + O_ACTIVE_FLAGS),
            (int32_t) R32(gH11Goomba + H11_INTANGIBLE_TIMER),
            rfloat(gH11Goomba + O_POS_X), rfloat(gH11Goomba + O_POS_Y),
            rfloat(gH11Goomba + O_POS_Z), rfloat(gH11Goomba + H11_HOME_X),
            rfloat(gH11Goomba + H11_HOME_Y), rfloat(gH11Goomba + H11_HOME_Z));
    for (i = 0; i < 3; i++) {
        W32(gH11Goomba + offsets[i], fbits(coordinates[i]));
        gH11ExtraWrites++;
        fprintf(stderr, "H11_FIXTURE_WRITE,address=%08x,value=%08x\n",
                gH11Goomba + offsets[i], fbits(coordinates[i]));
    }
    gH11Placed = 1;
    gH11ContactY = y;
    fprintf(stderr, "H11_PLACED,timer=%u,mode=%d,object=%08x,"
            "marioAction=%08x,y=%.9g,vy=%.9g,forwardVel=%.9g,extraWrites=%u\n",
            R32(A_GLOBAL_TIMER), HANDSTAND_DAMAGE_MODE, gH11Goomba,
            R32(A_MARIO_STATES + M_ACTION), y,
            rfloat(A_MARIO_STATES + ROUTE_M_VEL_Y),
            rfloat(A_MARIO_STATES + ROUTE_M_FORWARD_VEL), gH11ExtraWrites);
}

EXPORT void CALL GetKeys(int control, BUTTONS *keys) {
    uint32_t action, timer, mario;
    float x, y, z;
    int ready = 0;
    HandstandBaseGetKeys(control, keys);
    if (control != 0 || !gR11Staged || R16(A_CURR_AREA) != 2) return;
    mario = R32(A_MARIO_OBJECT);
    if (!mario) return;
    action = R32(A_MARIO_STATES + M_ACTION);
    timer = R32(A_GLOBAL_TIMER);
    x = rfloat(A_MARIO_STATES + M_POS_X);
    y = rfloat(A_MARIO_STATES + M_POS_Y);
    z = rfloat(A_MARIO_STATES + M_POS_Z);

    if (HANDSTAND_DAMAGE_MODE == 1 || gH11Placed) {
        memset(keys, 0, sizeof(*keys));
    } else if (HANDSTAND_DAMAGE_MODE == 0 && action == R11_TOP) {
        memset(keys, 0, sizeof(*keys));
    }
    if (timer == gH11Timer) return;
    gH11Timer = timer;

    if (!gH11Placed) {
        if (HANDSTAND_DAMAGE_MODE == 0 && action == R11_TOP && y == 4194.0f)
            ready = ++gH11ReadyPolls >= 10;
        if (HANDSTAND_DAMAGE_MODE == 1 && action == R11_HOLDING && y == 4020.0f)
            ready = ++gH11ReadyPolls >= 10;
        if (HANDSTAND_DAMAGE_MODE == 2 && action == R11_TOP_TRANSITION
            && (int16_t) R16(mario + R11_ANIM_ID) == 12
            && (int16_t) R16(mario + R11_ANIM_FRAME) == 0 && y == 4070.0f)
            ready = 1;
        if (ready) {
            gH11Goomba = handstand_find_goomba();
            if (gH11Goomba) {
                handstand_place_goomba(y);
                memset(keys, 0, sizeof(*keys));
            }
        }
    }
    /* Unlike the inherited R11_FRAME, this is logged AFTER our override and
     * is the controller input actually returned for the next update. */
    fprintf(stderr, "H11_INPUT,timer=%u,action=%08x,anim=%d,frame=%d,"
            "X=%d,Y=%d,A=%u,B=%u,Z=%u\n", timer, action,
            (int16_t) R16(mario + R11_ANIM_ID),
            (int16_t) R16(mario + R11_ANIM_FRAME),
            (int) keys->X_AXIS, (int) keys->Y_AXIS,
            (unsigned) keys->A_BUTTON, (unsigned) keys->B_BUTTON,
            (unsigned) keys->Z_TRIG);
    if (gH11Placed) {
        if (y >= 3942.0f && z < gH11MinZ) gH11MinZ = z;
        if (!gH11SawKnockback && (action == H11_BACKWARD_AIR_KB
                                 || action == H11_FORWARD_AIR_KB)) {
            gH11SawKnockback = 1;
            gH11FirstY = y;
            fprintf(stderr, "H11_FIRST_KNOCKBACK,timer=%u,action=%08x,"
                    "pos=(%.9g,%.9g,%.9g),vy=%.9g,forwardVel=%.9g\n",
                    timer, action, x, y, z,
                    rfloat(A_MARIO_STATES + ROUTE_M_VEL_Y),
                    rfloat(A_MARIO_STATES + ROUTE_M_FORWARD_VEL));
        }
        /* South target-air box from Area2LowerTargetCut, not merely high Y. */
        if (!gH11Crossed && x >= -101.0f && x <= 102.0f
            && y >= 3942.0f && y <= 6144.0f && z >= 922.0f && z <= 1229.0f) {
            gH11Crossed = 1;
            fprintf(stderr, "H11_TARGET,timer=%u,action=%08x,"
                    "pos=(%.9g,%.9g,%.9g),floor=%08x,floorHeight=%.9g\n",
                    timer, action, x, y, z, R32(A_MARIO_STATES + M_FLOOR),
                    rfloat(A_MARIO_STATES + M_FLOOR_HEIGHT));
        }
        if (++gH11Samples <= 110)
            fprintf(stderr, "H11_FRAME,timer=%u,action=%08x,"
                    "pos=(%.9g,%.9g,%.9g),bits=(%u,%u,%u),vy=%.9g,"
                    "forwardVel=%.9g,floor=%08x,floorHeight=%.9g,"
                    "goombaPos=(%.9g,%.9g,%.9g),A=%u,B=%u,Z=%u\n",
                    timer, action, x, y, z,
                    R32(A_MARIO_STATES + M_POS_X), R32(A_MARIO_STATES + M_POS_Y),
                    R32(A_MARIO_STATES + M_POS_Z),
                    rfloat(A_MARIO_STATES + ROUTE_M_VEL_Y),
                    rfloat(A_MARIO_STATES + ROUTE_M_FORWARD_VEL),
                    R32(A_MARIO_STATES + M_FLOOR),
                    rfloat(A_MARIO_STATES + M_FLOOR_HEIGHT),
                    rfloat(gH11Goomba + O_POS_X), rfloat(gH11Goomba + O_POS_Y),
                    rfloat(gH11Goomba + O_POS_Z), (unsigned) keys->A_BUTTON,
                    (unsigned) keys->B_BUTTON, (unsigned) keys->Z_TRIG);
    }
}

EXPORT void CALL RomClosed(void) {
    fprintf(stderr, "H11_RESULT,mode=%d,placed=%d,extraWrites=%u,"
            "contactY=%.9g,sawKnockback=%d,firstY=%.9g,crossed=%d,"
            "minZAboveRing=%.9g,aPressedFrames=%d,aDownFrames=%d,controllerAFrames=%d\n",
            HANDSTAND_DAMAGE_MODE, gH11Placed, gH11ExtraWrites, gH11ContactY,
            gH11SawKnockback, gH11FirstY, gH11Crossed, gH11MinZ,
            gAPressedFrames, gADownFrames, gControllerAFrames);
    HandstandBaseRomClosed();
}
