#define ROUTE_HOLD_FRAMES 1
#define GetKeys LifecycleGetKeys
#define RomClosed LifecycleRomClosed
#include "../jp-lifecycle/jp_lifecycle_probe.c"
#undef GetKeys
#undef RomClosed

#ifndef JP_FULL_ROUTE_GET_KEYS
#define JP_FULL_ROUTE_GET_KEYS GetKeys
#endif
#ifndef JP_FULL_ROUTE_ROM_CLOSED
#define JP_FULL_ROUTE_ROM_CLOSED RomClosed
#endif

#ifndef THIRD_AIM_X
#define THIRD_AIM_X 260.0f
#endif
#ifndef THIRD_AIM_Z
#define THIRD_AIM_Z -600.0f
#endif
#ifndef THIRD_BRAKE_FRAMES
#define THIRD_BRAKE_FRAMES 20u
#endif
#ifndef ENABLE_ROUTE_DIVE
#define ENABLE_ROUTE_DIVE 0
#endif
#ifndef ENABLE_RAMP_RETURN
#define ENABLE_RAMP_RETURN 0
#endif
#ifndef ENABLE_PICKUP_ROUTE
#define ENABLE_PICKUP_ROUTE 0
#endif
#ifndef PICKUP_AIM_X
#define PICKUP_AIM_X 900.0f
#endif

/*
 * Search-only controller layered on the hash-gated JP lifecycle probe.
 * The inherited fixture supplies the candidate Area-1 boundary; this file
 * changes controller input only after Area 2 is live.  It never supplies A or
 * writes a Mario/object/save coordinate.  ENABLE_ROUTE_DIVE optionally adds
 * ordinary B-only speed-kick/rollout probes.
 */

enum {
    ROUTE_M_AREA = 0x90,
    ROUTE_M_VEL_X = 0x48,
    ROUTE_M_VEL_Y = 0x4c,
    ROUTE_M_VEL_Z = 0x50,
    ROUTE_M_FORWARD_VEL = 0x54,
    ROUTE_M_ACTION_TIMER = 0x1a,
    ROUTE_AREA_CAMERA = 0x24,
    ROUTE_CAMERA_YAW = 0x02,
    ROUTE_O_INTERACT_TYPE = 0x130,
    /* JP primary file-A SaveBuffer is 0x80207c50.  courseStars begins at
       offset 0x0c and SSL is course index 7, so its byte is 0x80207c63,
       the low byte of this aligned word. */
    ROUTE_A_SSL_STAR_WORD = 0x80207c60,
    ROUTE_A_SSL_BACKUP_STAR_WORD = 0x80207c98,
};

enum {
    ROUTE_INTERACT_STAR_OR_KEY = 0x00001000,
    ROUTE_ACT_STAR_DANCE_EXIT = 0x00001302,
    ROUTE_ACT_STAR_DANCE_WATER = 0x00001303,
    ROUTE_ACT_FALL_AFTER_STAR_GRAB = 0x00001904,
    ROUTE_ACT_STAR_DANCE_NO_EXIT = 0x00001307,
    ROUTE_ACT_DIVE_SLIDE = 0x00880456,
    ROUTE_ACT_STOMACH_SLIDE = 0x008c0453,
    ROUTE_ACT_FREEFALL_LAND = 0x04000471,
};

struct RoutePoint {
    float x;
    float y;
    float z;
    const char *name;
};

static const struct RoutePoint gRoutePoints[] = {
    {  260.0f, 3913.0f, -600.0f, "upper-trigger" },
    { -260.0f, 2940.0f, -600.0f, "second-trigger" },
    { THIRD_AIM_X, 1967.0f, THIRD_AIM_Z, "third-trigger" },
    {-1940.0f, 1229.0f, -600.0f, "fourth-trigger" },
    {-1940.0f, 1229.0f, 2320.0f, "fifth-trigger" },
    {  900.0f, 1400.0f, 2350.0f, "act6-star" },
};

static uint32_t gRouteLastTimer = UINT32_MAX;
static int32_t gRouteMaxCounter = -1;
static int gRouteCounterTransitions;
static int gRouteSawFive;
static int gRouteSawStarDance;
static int gRouteSawAct6Star;
static int gRouteSawAct6Interaction;
static uint32_t gRouteAct6Star;
static int gRouteDivePulse;
static int gRouteSpeedKickCount;
static int gRouteRolloutPulse;
static int gRouteBPressedFrames;
static int gRampReturnStage;
static uint32_t gCounter2StartTimer;
static int gInitialSSLStarByte = -1;
static int gFinalSSLStarByte = -1;
static int gInitialSSLBackupStarByte = -1;
static int gFinalSSLBackupStarByte = -1;
static int gSawAct6BitTransition;

static int clamp_axis(int value) {
    if (value < -127) return -127;
    if (value > 127) return 127;
    return value;
}

static void steer_world(BUTTONS *keys, float target_x, float target_y,
                        float target_z) {
    uint32_t area = R32(A_MARIO_STATES + ROUTE_M_AREA);
    uint32_t camera = area == 0 ? 0 : R32(area + ROUTE_AREA_CAMERA);
    int16_t camera_yaw = camera == 0
        ? 0 : (int16_t) R16(camera + ROUTE_CAMERA_YAW);
    float x = rfloat(A_MARIO_STATES + M_POS_X);
    float y = rfloat(A_MARIO_STATES + M_POS_Y);
    float z = rfloat(A_MARIO_STATES + M_POS_Z);
    float vx = rfloat(A_MARIO_STATES + ROUTE_M_VEL_X);
    float vy = rfloat(A_MARIO_STATES + ROUTE_M_VEL_Y);
    float vz = rfloat(A_MARIO_STATES + ROUTE_M_VEL_Z);
    float lead = 12.0f;
    float dx;
    float dz;

    if (vy < -1.0f && y > target_y) {
        lead = (y - target_y) / -vy;
        if (lead > 12.0f) lead = 12.0f;
        if (lead < 2.0f) lead = 2.0f;
    }
    dx = target_x - (x + vx * lead);
    dz = target_z - (z + vz * lead);
    float distance = sqrtf(dx * dx + dz * dz);
    float desired = atan2f(dx, dz);
    float camera_radians = (float) camera_yaw
        * (2.0f * 3.14159265358979323846f / 65536.0f);
    float controller_angle = desired - camera_radians;
    float magnitude = distance < 60.0f ? distance * 2.0f : 127.0f;

    /* SM64's atan2s convention is yaw 0 along +Z, so X is sine and
       negative Y is cosine of the desired camera-relative yaw. */
    keys->X_AXIS = (int8_t) clamp_axis((int) lrintf(sinf(controller_angle) * magnitude));
    keys->Y_AXIS = (int8_t) clamp_axis((int) lrintf(-cosf(controller_angle) * magnitude));
}

static void steer_world_direct(BUTTONS *keys, float target_x,
                               float target_z) {
    uint32_t area = R32(A_MARIO_STATES + ROUTE_M_AREA);
    uint32_t camera = area == 0 ? 0 : R32(area + ROUTE_AREA_CAMERA);
    int16_t camera_yaw = camera == 0
        ? 0 : (int16_t) R16(camera + ROUTE_CAMERA_YAW);
    float x = rfloat(A_MARIO_STATES + M_POS_X);
    float z = rfloat(A_MARIO_STATES + M_POS_Z);
    float dx = target_x - x;
    float dz = target_z - z;
    float distance = sqrtf(dx * dx + dz * dz);
    float desired = atan2f(dx, dz);
    float camera_radians = (float) camera_yaw
        * (2.0f * 3.14159265358979323846f / 65536.0f);
    float controller_angle = desired - camera_radians;
    float magnitude = distance < 60.0f ? distance * 2.0f : 127.0f;

    keys->X_AXIS = (int8_t) clamp_axis(
        (int) lrintf(sinf(controller_angle) * magnitude));
    keys->Y_AXIS = (int8_t) clamp_axis(
        (int) lrintf(-cosf(controller_angle) * magnitude));
}

static unsigned route_index(void) {
    int32_t counter = hidden_counter();
    /* The controller deactivates shortly after counter 5 and its reclaimed
       slot no longer reports the counter.  Preserve the achieved route phase
       so the post-cutscene controller continues toward the spawned star. */
    if (gRouteSawFive || gRouteMaxCounter >= 5) return 5;
    if (counter < 0) return 0;
    if (counter > 5) return 5;
    return (unsigned) counter;
}

static void observe_act6_star(void) {
    unsigned i;

    if (gRouteAct6Star != 0 && R32(gRouteAct6Star + 0x134) != 0) {
        gRouteSawAct6Interaction = 1;
    }

    for (i = 0; i < OBJECT_COUNT; i++) {
        uint32_t object = pool_pointer(i);
        uint16_t active = R16(object + O_ACTIVE_FLAGS);
        uint32_t params = R32(object + O_BHV_PARAMS);
        uint32_t interact = R32(object + ROUTE_O_INTERACT_TYPE);

        if (active != 0 && ((params >> 24) & 0x1f) == 5
            && interact == ROUTE_INTERACT_STAR_OR_KEY) {
            if (!gRouteSawAct6Star || gRouteAct6Star != object) {
                fprintf(stderr,
                        "ROUTE_ACT6_STAR,timer=%u,slot=%u,pointer=%08x,"
                        "active=%04x,action=%u,position=(%.6f,%.6f,%.6f)\n",
                        R32(A_GLOBAL_TIMER), i, object, active,
                        R32(object + O_ACTION),
                        rfloat(object + O_POS_X), rfloat(object + O_POS_Y),
                        rfloat(object + O_POS_Z));
            }
            gRouteSawAct6Star = 1;
            gRouteAct6Star = object;
            if (R32(object + 0x134) != 0) {
                gRouteSawAct6Interaction = 1;
            }
            return;
        }
    }
}

static int route_is_star_dance(uint32_t action) {
    return action == ROUTE_ACT_STAR_DANCE_EXIT
        || action == ROUTE_ACT_STAR_DANCE_WATER
        || action == ROUTE_ACT_FALL_AFTER_STAR_GRAB
        || action == ROUTE_ACT_STAR_DANCE_NO_EXIT;
}

static void observe_pickup_hitboxes(uint32_t timer) {
    uint32_t mario;

    if (!ENABLE_PICKUP_ROUTE || gRouteAct6Star == 0
        || (timer != 1342 && timer != 1343)) return;
    mario = R32(A_MARIO_OBJECT);
    fprintf(stderr,
            "ROUTE_PICKUP_HITBOX,timer=%u,mario=%08x,"
            "marioPosBits=(%08x,%08x,%08x),marioRadiusBits=%08x,"
            "marioHeightBits=%08x,marioDownBits=%08x,"
            "marioIntangible=%d,marioCollisions=%u,star=%08x,"
            "active=%04x,action=%u,starPosBits=(%08x,%08x,%08x),"
            "starRadiusBits=%08x,starHeightBits=%08x,starDownBits=%08x,"
            "starIntangible=%d,starCollisions=%u,interactType=%08x,"
            "interactStatus=%08x,params=%08x\n",
            timer, mario,
            R32(mario + 0x0a0), R32(mario + 0x0a4),
            R32(mario + 0x0a8), R32(mario + 0x1f8),
            R32(mario + 0x1fc), R32(mario + 0x208),
            (int32_t) R32(mario + 0x09c), (unsigned) R16(mario + 0x076),
            gRouteAct6Star, R16(gRouteAct6Star + 0x074),
            R32(gRouteAct6Star + O_ACTION),
            R32(gRouteAct6Star + 0x0a0), R32(gRouteAct6Star + 0x0a4),
            R32(gRouteAct6Star + 0x0a8), R32(gRouteAct6Star + 0x1f8),
            R32(gRouteAct6Star + 0x1fc), R32(gRouteAct6Star + 0x208),
            (int32_t) R32(gRouteAct6Star + 0x09c),
            (unsigned) R16(gRouteAct6Star + 0x076),
            R32(gRouteAct6Star + ROUTE_O_INTERACT_TYPE),
            R32(gRouteAct6Star + 0x134),
            R32(gRouteAct6Star + O_BHV_PARAMS));
}

static void route_press_b(BUTTONS *keys, uint32_t timer,
                          const char *label) {
    if (!keys->B_BUTTON) {
        gRouteBPressedFrames++;
    }
    keys->B_BUTTON = 1;
    fprintf(stderr,
            "ROUTE_PICKUP_INPUT,timer=%u,input=B,label=%s,"
            "action=%08x,mario=(%.6f,%.6f,%.6f)\n",
            timer, label, R32(A_MARIO_STATES + M_ACTION),
            rfloat(A_MARIO_STATES + M_POS_X),
            rfloat(A_MARIO_STATES + M_POS_Y),
            rfloat(A_MARIO_STATES + M_POS_Z));
}

EXPORT void CALL JP_FULL_ROUTE_ROM_CLOSED(void) {
    fprintf(stderr,
            "ROUTE_RESULT,maxCounter=%d,counterTransitions=%d,sawFive=%d,"
            "sawAct6Star=%d,sawAct6Interaction=%d,sawStarDance=%d,"
            "divePulse=%d,speedKickCount=%d,"
            "bPressedFrames=%d,"
            "initialSSLStars=%02x,finalSSLStars=%02x,"
            "initialBackupSSLStars=%02x,finalBackupSSLStars=%02x,"
            "act6BitTransition=%d,act6StarPointer=%08x,usedObj=%08x,"
            "aPressedFrames=%d,aDownFrames=%d,controllerAFrames=%d\n",
            gRouteMaxCounter, gRouteCounterTransitions, gRouteSawFive,
            gRouteSawAct6Star, gRouteSawAct6Interaction, gRouteSawStarDance,
            gRouteDivePulse, gRouteSpeedKickCount,
            gRouteBPressedFrames,
            gInitialSSLStarByte & 0xff, gFinalSSLStarByte & 0xff,
            gInitialSSLBackupStarByte & 0xff,
            gFinalSSLBackupStarByte & 0xff,
            gSawAct6BitTransition,
            gRouteAct6Star, R32(A_MARIO_STATES + M_USED_OBJ),
            gAPressedFrames, gADownFrames, gControllerAFrames);
    LifecycleRomClosed();
}

EXPORT void CALL JP_FULL_ROUTE_GET_KEYS(int control, BUTTONS *keys) {
    int installed_before = gBoundaryInstalled;
    uint16_t area;
    uint32_t timer;
    unsigned index;
    int32_t counter;

    LifecycleGetKeys(control, keys);
    if (control != 0) return;

    /* Use the timer-131 midpoint retry that remains top-supported through
       the delayed warp, rather than the transient near-base diagnostic. */
    if (!installed_before && gBoundaryInstalled) {
        uint32_t mario_object = R32(A_MARIO_OBJECT);
        W32(mario_object + GFX_POS_X, fbits(-1862.0f));
        W32(mario_object + GFX_POS_Y, fbits(1778.0f));
        W32(mario_object + GFX_POS_Z, fbits(-902.0f));
        fprintf(stderr,
                "ROUTE_RETRY,timer=%u,graphicsBits=(%08x,%08x,%08x)\n",
                R32(A_GLOBAL_TIMER),
                R32(mario_object + GFX_POS_X),
                R32(mario_object + GFX_POS_Y),
                R32(mario_object + GFX_POS_Z));
    }

    area = R16(A_CURR_AREA);
    if (!gBoundaryInstalled || area != 2) return;

    gFinalSSLStarByte = (int) (R32(ROUTE_A_SSL_STAR_WORD) & 0xff);
    gFinalSSLBackupStarByte =
        (int) (R32(ROUTE_A_SSL_BACKUP_STAR_WORD) & 0xff);
    if (gInitialSSLStarByte < 0) {
        gInitialSSLStarByte = gFinalSSLStarByte;
        gInitialSSLBackupStarByte = gFinalSSLBackupStarByte;
        fprintf(stderr,
                "ROUTE_SAVE_INITIAL,timer=%u,sslStars=%02x,"
                "backupSSLStars=%02x\n",
                R32(A_GLOBAL_TIMER), gInitialSSLStarByte,
                gInitialSSLBackupStarByte);
    }
    if ((gInitialSSLStarByte & 0x20) == 0
        && (gFinalSSLStarByte & 0x20) != 0
        && !gSawAct6BitTransition) {
        gSawAct6BitTransition = 1;
        fprintf(stderr,
                "ROUTE_SAVE_ACT6,timer=%u,initial=%02x,current=%02x\n",
                R32(A_GLOBAL_TIMER), gInitialSSLStarByte,
                gFinalSSLStarByte);
        fprintf(stderr,
                "ROUTE_PICKUP_RESULT,timer=%u,star=%08x,usedObj=%08x,"
                "action=%08x,input=%04x,initialSSLStars=%02x,"
                "finalSSLStars=%02x,backupSSLStars=%02x,"
                "marioBits=(%08x,%08x,%08x),aPressedFrames=%d,"
                "aDownFrames=%d,controllerAFrames=%d\n",
                R32(A_GLOBAL_TIMER), gRouteAct6Star,
                R32(A_MARIO_STATES + M_USED_OBJ),
                R32(A_MARIO_STATES + M_ACTION),
                R16(A_MARIO_STATES + 0x02),
                gInitialSSLStarByte, gFinalSSLStarByte,
                gFinalSSLBackupStarByte,
                R32(A_MARIO_STATES + M_POS_X),
                R32(A_MARIO_STATES + M_POS_Y),
                R32(A_MARIO_STATES + M_POS_Z),
                gAPressedFrames, gADownFrames, gControllerAFrames);
    }

    /* Every route is A-edge-free.  B is enabled only by the explicit
       ENABLE_ROUTE_DIVE search mode below. */
    keys->A_BUTTON = 0;
    keys->B_BUTTON = 0;
    keys->Z_TRIG = 0;
    keys->START_BUTTON = 0;
    keys->L_TRIG = 0;
    keys->R_TRIG = 0;
    keys->U_CBUTTON = 0;
    keys->D_CBUTTON = 0;
    keys->L_CBUTTON = 0;
    keys->R_CBUTTON = 0;
    keys->U_DPAD = 0;
    keys->D_DPAD = 0;
    keys->L_DPAD = 0;
    keys->R_DPAD = 0;

    counter = hidden_counter();
    if (counter >= 5) gRouteSawFive = 1;
    index = route_index();
    if (counter == 2 && gCounter2StartTimer == 0) {
        gCounter2StartTimer = R32(A_GLOBAL_TIMER);
    }
    if (gRouteSawFive) {
        if (ENABLE_RAMP_RETURN && gRampReturnStage == 0) {
            float y = rfloat(A_MARIO_STATES + M_POS_Y);
            float z = rfloat(A_MARIO_STATES + M_POS_Z);

            steer_world(keys, 700.0f, 1338.0f, 2700.0f);
            if (y >= 1260.0f && z >= 2550.0f) {
                gRampReturnStage = 1;
                fprintf(stderr,
                        "ROUTE_RAMP_RETURN,timer=%u,mario=(%.6f,%.6f,%.6f)\n",
                        R32(A_GLOBAL_TIMER),
                        rfloat(A_MARIO_STATES + M_POS_X), y, z);
            }
        } else {
            steer_world(keys, gRoutePoints[index].x, gRoutePoints[index].y,
                        gRoutePoints[index].z);
        }
    } else if (counter == 0) {
        /* Preserve the already authenticated upper-trigger schedule. */
        uint32_t relative = R32(A_GLOBAL_TIMER) - gArea2StartTimer;
        keys->X_AXIS = relative < 60 ? -127 : 0;
        keys->Y_AXIS = relative < 60 ? -96 : 0;
    } else if (counter == 2
               && R32(A_GLOBAL_TIMER) - gCounter2StartTimer
                    < THIRD_BRAKE_FRAMES) {
        /* Let the second-trigger landing shed inherited lateral velocity
           before selecting the edge used for the third-trigger fall. */
        keys->X_AXIS = 0;
        keys->Y_AXIS = 0;
    } else {
        steer_world(keys, gRoutePoints[index].x, gRoutePoints[index].y,
                    gRoutePoints[index].z);
    }

    timer = R32(A_GLOBAL_TIMER);
    if (ENABLE_PICKUP_ROUTE) {
        /* A fixed no-A continuation discovered against the stable timer-131
           boundary.  The first four B edges preserve speed across the long
           moving-sand traverse.  Each Z/B pair is an ordinary slide kick;
           the second supplies the final 12 units of vertical displacement
           needed to overlap the spawned star. */
        if (timer >= 801 && counter == 3) {
            steer_world(keys, -2200.0f, 1229.0f, -600.0f);
        }
        if (timer >= 1065) {
            /* No velocity prediction: preserving the source-discovered
               schedule is essential because the predictive route helper
               turns too late and falls from the east edge. */
            steer_world_direct(keys, PICKUP_AIM_X, 2350.0f);
        }
        if (timer == 801 || timer == 835
            || timer == 883 || timer == 919
            || timer == 1066 || timer == 1341) {
            route_press_b(keys, timer,
                timer == 1341 ? "pickup-slide-kick" : "route-speed");
        }
        if (timer == 1065 || timer == 1340) {
            keys->Z_TRIG = 1;
            fprintf(stderr,
                    "ROUTE_PICKUP_INPUT,timer=%u,input=Z,label=%s,"
                    "action=%08x,mario=(%.6f,%.6f,%.6f)\n",
                    timer,
                    timer == 1340 ? "pickup-crouch" : "plateau-crouch",
                    R32(A_MARIO_STATES + M_ACTION),
                    rfloat(A_MARIO_STATES + M_POS_X),
                    rfloat(A_MARIO_STATES + M_POS_Y),
                    rfloat(A_MARIO_STATES + M_POS_Z));
        }
    }

    if (ENABLE_ROUTE_DIVE
        && R32(A_MARIO_STATES + M_ACTION) == ROUTE_ACT_FREEFALL_LAND
        && R16(A_MARIO_STATES + ROUTE_M_ACTION_TIMER) >= 3
        && rfloat(A_MARIO_STATES + ROUTE_M_FORWARD_VEL) >= 29.0f) {
        keys->B_BUTTON = 1;
        gRouteDivePulse = 1;
        gRouteSpeedKickCount++;
        gRouteBPressedFrames++;
        fprintf(stderr,
                "ROUTE_SPEED_KICK,timer=%u,count=%d,actionTimer=%u,"
                "forwardVel=%.6f,"
                "mario=(%.6f,%.6f,%.6f)\n",
                R32(A_GLOBAL_TIMER),
                gRouteSpeedKickCount,
                R16(A_MARIO_STATES + ROUTE_M_ACTION_TIMER),
                rfloat(A_MARIO_STATES + ROUTE_M_FORWARD_VEL),
                rfloat(A_MARIO_STATES + M_POS_X),
                rfloat(A_MARIO_STATES + M_POS_Y),
                rfloat(A_MARIO_STATES + M_POS_Z));
    }

    if (counter > gRouteMaxCounter && counter <= 5) {
        fprintf(stderr,
                "ROUTE_COUNTER,timer=%u,old=%d,new=%d,target=%s,"
                "mario=(%.6f,%.6f,%.6f),action=%08x\n",
                R32(A_GLOBAL_TIMER), gRouteMaxCounter, counter,
                gRoutePoints[index].name,
                rfloat(A_MARIO_STATES + M_POS_X),
                rfloat(A_MARIO_STATES + M_POS_Y),
                rfloat(A_MARIO_STATES + M_POS_Z),
                R32(A_MARIO_STATES + M_ACTION));
        if (gRouteMaxCounter >= 0) gRouteCounterTransitions++;
        gRouteMaxCounter = counter;
    }
    observe_act6_star();
    if (gRouteAct6Star != 0
        && route_is_star_dance(R32(A_MARIO_STATES + M_ACTION))
        && R32(A_MARIO_STATES + M_USED_OBJ) == gRouteAct6Star) {
        gRouteSawAct6Interaction = 1;
    }
    observe_pickup_hitboxes(timer);
    if (ENABLE_ROUTE_DIVE && gRouteAct6Star != 0 && !gRouteRolloutPulse
        && R32(gRouteAct6Star + O_ACTION) == 3) {
        float dx = rfloat(gRouteAct6Star + O_POS_X)
                 - rfloat(A_MARIO_STATES + M_POS_X);
        float dz = rfloat(gRouteAct6Star + O_POS_Z)
                 - rfloat(A_MARIO_STATES + M_POS_Z);
        float distance = sqrtf(dx * dx + dz * dz);
        float forward_vel = rfloat(A_MARIO_STATES + ROUTE_M_FORWARD_VEL);

        /* A dive/stomach slide accepts a B edge into a +30 rollout without
           any A edge.  Keep the older speed-kick fallback for a fresh
           high-speed ground approach. */
        if (distance < 250.0f
            && (R32(A_MARIO_STATES + M_ACTION) == ROUTE_ACT_DIVE_SLIDE
                || R32(A_MARIO_STATES + M_ACTION)
                     == ROUTE_ACT_STOMACH_SLIDE)) {
            keys->B_BUTTON = 1;
            gRouteRolloutPulse = 1;
            gRouteBPressedFrames++;
            fprintf(stderr,
                    "ROUTE_ROLLOUT,timer=%u,distance=%.6f,forwardVel=%.6f,"
                    "mario=(%.6f,%.6f,%.6f),star=(%.6f,%.6f,%.6f)\n",
                    R32(A_GLOBAL_TIMER), distance, forward_vel,
                    rfloat(A_MARIO_STATES + M_POS_X),
                    rfloat(A_MARIO_STATES + M_POS_Y),
                    rfloat(A_MARIO_STATES + M_POS_Z),
                    rfloat(gRouteAct6Star + O_POS_X),
                    rfloat(gRouteAct6Star + O_POS_Y),
                    rfloat(gRouteAct6Star + O_POS_Z));
        } else if (distance < 175.0f && forward_vel >= 29.0f) {
            keys->B_BUTTON = 1;
            gRouteRolloutPulse = 1;
            gRouteBPressedFrames++;
            fprintf(stderr,
                    "ROUTE_DIVE,timer=%u,distance=%.6f,forwardVel=%.6f,"
                    "mario=(%.6f,%.6f,%.6f),star=(%.6f,%.6f,%.6f)\n",
                    R32(A_GLOBAL_TIMER), distance, forward_vel,
                    rfloat(A_MARIO_STATES + M_POS_X),
                    rfloat(A_MARIO_STATES + M_POS_Y),
                    rfloat(A_MARIO_STATES + M_POS_Z),
                    rfloat(gRouteAct6Star + O_POS_X),
                    rfloat(gRouteAct6Star + O_POS_Y),
                    rfloat(gRouteAct6Star + O_POS_Z));
        }
    }
    if (route_is_star_dance(R32(A_MARIO_STATES + M_ACTION))) {
        gRouteSawStarDance = 1;
    }

    if (timer != gRouteLastTimer && timer % 5 == 0) {
        uint32_t state_area = R32(A_MARIO_STATES + ROUTE_M_AREA);
        uint32_t camera = state_area == 0
            ? 0 : R32(state_area + ROUTE_AREA_CAMERA);
        int16_t camera_yaw = camera == 0
            ? 0 : (int16_t) R16(camera + ROUTE_CAMERA_YAW);
        gRouteLastTimer = timer;
        fprintf(stderr,
                "ROUTE_TRACE,timer=%u,counter=%d,target=%s,"
                "axis=(%d,%d),cameraYaw=%d,action=%08x,"
                "mario=(%.6f,%.6f,%.6f),forwardVel=%.6f,"
                "floorHeight=%.6f\n",
                timer, counter, gRoutePoints[index].name,
                keys->X_AXIS, keys->Y_AXIS, camera_yaw,
                R32(A_MARIO_STATES + M_ACTION),
                rfloat(A_MARIO_STATES + M_POS_X),
                rfloat(A_MARIO_STATES + M_POS_Y),
                rfloat(A_MARIO_STATES + M_POS_Z),
                rfloat(A_MARIO_STATES + ROUTE_M_FORWARD_VEL),
                rfloat(A_MARIO_STATES + M_FLOOR_HEIGHT));
    }
}
