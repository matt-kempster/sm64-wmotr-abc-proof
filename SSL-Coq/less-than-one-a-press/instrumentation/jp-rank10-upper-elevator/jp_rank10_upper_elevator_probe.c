#define ALLOW_SETUP_A 0
#define SEARCH_MODE 12
#define GetKeys Rank10BaseGetKeys
#define RomClosed Rank10BaseRomClosed
#include "../jp-clean-gap-search/jp_clean_gap_search_probe.c"
#undef GetKeys
#undef RomClosed

#ifndef RANK10_MODE
#define RANK10_MODE 0
#endif

enum {
    R10_M_FLAGS = 0x04,
    R10_M_ACTION_STATE = 0x18,
    R10_M_CAP_TIMER = 0x26,
    R10_M_WALL = 0x60,
    R10_M_CEIL = 0x64,
    R10_SURFACE_TYPE = 0x00,
    R10_SURFACE_LOWER_Y = 0x06,
    R10_SURFACE_UPPER_Y = 0x08,
    R10_SURFACE_VERTEX1 = 0x0a,
    R10_SURFACE_VERTEX2 = 0x10,
    R10_SURFACE_VERTEX3 = 0x16,
    R10_SURFACE_NORMAL_X = 0x1c,
    R10_SURFACE_NORMAL_Y = 0x20,
    R10_SURFACE_NORMAL_Z = 0x24,
    R10_SURFACE_OBJECT = 0x2c,
    R10_ACT_IDLE = 0x0c400201,
    R10_ACT_FORWARD_ROLLOUT = 0x010008a6,
};

static uint32_t gRank10Elevator;
static uint32_t gRank10MarioObject;
static uint32_t gRank10FirstRolloutWall;
static uint32_t gRank10FirstTimer = UINT32_MAX;
static uint32_t gRank10LastTimer = UINT32_MAX;
static uint32_t gRank10LastAction = UINT32_MAX;
static uint32_t gRank10LandingTimer = UINT32_MAX;
static uint32_t gRank10LastElevatorAction = UINT32_MAX;
static unsigned gRank10Area2Frames;
static unsigned gRank10SequentialFailures;
static unsigned gRank10ElevatorCandidates;
static unsigned gRank10ElevatorPlatformFrames;
static unsigned gRank10ElevatorFloorFrames;
static unsigned gRank10NonWingFrames;
static unsigned gRank10APressedFrames;
static unsigned gRank10ADownFrames;
static unsigned gRank10ControllerAFrames;
static unsigned gRank10ControllerBFrames;
static unsigned gRank10IdentityMismatchFrames;
static unsigned gRank10ElevatorIdentityFailureFrames;
static unsigned gRank10FloorOwnerMismatchFrames;
static unsigned gRank10DescentMismatchFrames;
static unsigned gRank10Stage;
static unsigned gRank10StageTimer;
static unsigned gRank10DiveTimer = UINT32_MAX;
static unsigned gRank10RolloutTimer = UINT32_MAX;
static unsigned gRank10RolloutFrames;
static unsigned gRank10RolloutWallStops;
static unsigned gRank10RolloutWallFrames;
static unsigned gRank10RolloutElevatorWallFrames;
static unsigned gRank10RolloutFloorOwnerFrames;
static unsigned gRank10RolloutOutsideInnerCenterFrames;
static float gRank10RolloutMaxRelativeY = -INFINITY;
static float gRank10RolloutMaxX = -INFINITY;

static const float gRank10ExpectedDescentRelativeY[17] = {
    534.0f, 530.0f, 522.0f, 510.0f, 494.0f, 474.0f,
    450.0f, 422.0f, 390.0f, 354.0f, 314.0f, 270.0f,
    222.0f, 170.0f, 114.0f, 54.0f, 0.0f,
};

static uint32_t rank10_find_elevator(void) {
    uint32_t found = 0;
    unsigned count = 0;
    unsigned index;

    for (index = 0; index < OBJECT_COUNT; index++) {
        uint32_t object = pool_pointer(index);
        float x;
        float y;
        float z;

        if (R16(object + O_ACTIVE_FLAGS) == 0
            || R32(object + O_COLLISION_DATA) == 0) continue;
        x = rfloat(object + O_POS_X);
        y = rfloat(object + O_POS_Y);
        z = rfloat(object + O_POS_Z);
        if (x == 0.0f && z == 256.0f && y >= 100.0f && y <= 5000.0f) {
            found = object;
            count++;
        }
    }
    gRank10ElevatorCandidates = count;
    return count == 1 ? found : 0;
}

static void rank10_set_stage(unsigned stage, const char *label) {
    gRank10Stage = stage;
    gRank10StageTimer = R32(A_GLOBAL_TIMER);
    fprintf(stderr,
            "RANK10_STAGE,timer=%u,stage=%u,label=%s,action=%08x,"
            "mario=(%.9g,%.9g,%.9g),forwardVel=%.9g\n",
            gRank10StageTimer, stage, label,
            R32(A_MARIO_STATES + M_ACTION),
            rfloat(A_MARIO_STATES + M_POS_X),
            rfloat(A_MARIO_STATES + M_POS_Y),
            rfloat(A_MARIO_STATES + M_POS_Z),
            rfloat(A_MARIO_STATES + M_FORWARD_VEL));
}

static void rank10_apply_rollout_schedule(BUTTONS *keys) {
    uint32_t action = R32(A_MARIO_STATES + M_ACTION);
    float x = rfloat(A_MARIO_STATES + M_POS_X);
    float z = rfloat(A_MARIO_STATES + M_POS_Z);
    float forward_vel = rfloat(A_MARIO_STATES + M_FORWARD_VEL);

    if (RANK10_MODE != 1 || gRank10LandingTimer == UINT32_MAX) return;

    switch (gRank10Stage) {
        case 0:
            if (action == R10_ACT_IDLE) {
                rank10_set_stage(1, "walk-to-west-runway-start");
            }
            break;
        case 1:
            steer_world(keys, -350.0f, 256.0f, 24.0f);
            if (hypotf(x + 350.0f, z - 256.0f) < 12.0f) {
                memset(keys, 0, sizeof(*keys));
                rank10_set_stage(2, "settle-at-west-runway-start");
            }
            break;
        case 2:
            if (action == R10_ACT_IDLE && fabsf(forward_vel) < 1.0f
                && R32(A_GLOBAL_TIMER) - gRank10StageTimer >= 4) {
                rank10_set_stage(3, "move-to-orbit-entry");
            }
            break;
        case 3:
            steer_world(keys, -337.0f, 6.0f, 24.0f);
            if (hypotf(x + 337.0f, z - 6.0f) < 10.0f) {
                memset(keys, 0, sizeof(*keys));
                rank10_set_stage(4, "settle-at-orbit-entry");
            }
            break;
        case 4:
            if (action == R10_ACT_IDLE && fabsf(forward_vel) < 1.0f
                && R32(A_GLOBAL_TIMER) - gRank10StageTimer >= 4) {
                rank10_set_stage(5, "bounded-clockwise-speed-build");
            }
            break;
        case 5: {
            float dx = x + 187.0f;
            float dz = z - 6.0f;
            float radius = hypotf(dx, dz);
            float radial_x = radius < 1.0f ? -1.0f : dx / radius;
            float radial_z = radius < 1.0f ? 0.0f : dz / radius;
            float correction = (150.0f - radius) / 75.0f;
            float heading_x = radial_z + correction * radial_x;
            float heading_z = -radial_x + correction * radial_z;
            int16_t face_yaw = (int16_t) R16(
                A_MARIO_STATES + M_FACE_YAW);
            int16_t launch_error = (int16_t) (face_yaw - 0x2aaa);

            if (launch_error < 0) launch_error = -launch_error;
            steer_world(keys, x + heading_x * 1000.0f,
                        z + heading_z * 1000.0f, 127.0f);
            if (action == ACT_WALKING && forward_vel >= 29.0f
                && x >= -285.0f && x <= -240.0f
                && z >= 115.0f && z <= 175.0f
                && launch_error < 0x0800) {
                steer_world(keys, x + 866.0f, z + 500.0f, 127.0f);
                keys->B_BUTTON = 1;
                gRank10DiveTimer = R32(A_GLOBAL_TIMER);
                rank10_set_stage(6, "sixty-degree-speed-kick-dive-input");
            }
            break;
        }
        case 6:
            steer_world(keys, x + 866.0f, z + 500.0f, 127.0f);
            if (action == ACT_DIVE_SLIDE) {
                keys->B_BUTTON = 1;
                gRank10RolloutTimer = R32(A_GLOBAL_TIMER);
                rank10_set_stage(7, "dive-slide-rollout-input");
            }
            break;
        case 7:
            steer_world(keys, x + 866.0f, z + 500.0f, 127.0f);
            if (action != ACT_DIVE_SLIDE
                && action != R10_ACT_FORWARD_ROLLOUT
                && R32(A_GLOBAL_TIMER) > gRank10RolloutTimer + 1) {
                memset(keys, 0, sizeof(*keys));
                rank10_set_stage(8, "rollout-ended");
            }
            break;
        default:
            break;
    }
}

static void rank10_log_frame(const BUTTONS *keys) {
    uint32_t timer = R32(A_GLOBAL_TIMER);
    uint32_t action = R32(A_MARIO_STATES + M_ACTION);
    uint32_t floor = R32(A_MARIO_STATES + M_FLOOR);
    uint32_t floor_owner = floor == 0 ? 0
        : R32(floor + R10_SURFACE_OBJECT);
    uint32_t platform = R32(A_MARIO_PLATFORM);
    uint32_t wall = R32(A_MARIO_STATES + R10_M_WALL);
    uint32_t wall_owner = wall == 0 ? 0
        : R32(wall + R10_SURFACE_OBJECT);
    uint32_t ceil = R32(A_MARIO_STATES + R10_M_CEIL);
    uint32_t flags = R32(A_MARIO_STATES + R10_M_FLAGS);
    uint16_t input = R16(A_MARIO_STATES + M_INPUT);
    float elevator_y = gRank10Elevator == 0 ? NAN
        : rfloat(gRank10Elevator + O_POS_Y);
    uint32_t elevator_action = gRank10Elevator == 0 ? UINT32_MAX
        : R32(gRank10Elevator + O_ACTION);
    float relative_y = rfloat(A_MARIO_STATES + M_POS_Y) - elevator_y;

    if (gRank10FirstTimer == UINT32_MAX) gRank10FirstTimer = timer;
    if (gRank10LastTimer != UINT32_MAX && timer != gRank10LastTimer + 1) {
        gRank10SequentialFailures++;
    }
    gRank10LastTimer = timer;
    gRank10Area2Frames++;
    if (R32(A_MARIO_OBJECT) != gRank10MarioObject
        || R32(A_MARIO_STATES + M_MARIO_OBJ) != gRank10MarioObject) {
        gRank10IdentityMismatchFrames++;
    }
    if (R16(gRank10Elevator + O_ACTIVE_FLAGS) == 0
        || rfloat(gRank10Elevator + O_POS_X) != 0.0f
        || rfloat(gRank10Elevator + O_POS_Z) != 256.0f) {
        gRank10ElevatorIdentityFailureFrames++;
    }
    if (platform == gRank10Elevator && gRank10Elevator != 0) {
        gRank10ElevatorPlatformFrames++;
        if (gRank10LandingTimer == UINT32_MAX) gRank10LandingTimer = timer;
    }
    if (floor_owner == gRank10Elevator && gRank10Elevator != 0) {
        gRank10ElevatorFloorFrames++;
    } else {
        gRank10FloorOwnerMismatchFrames++;
    }
    if ((flags & 8u) == 0 && R16(A_MARIO_STATES + R10_M_CAP_TIMER) == 0) {
        gRank10NonWingFrames++;
    }
    if ((input & INPUT_A_PRESSED) != 0) gRank10APressedFrames++;
    if ((input & INPUT_A_DOWN) != 0) gRank10ADownFrames++;
    if (keys->A_BUTTON) gRank10ControllerAFrames++;
    if (keys->B_BUTTON) gRank10ControllerBFrames++;

    if (gRank10Area2Frames <= 17) {
        uint32_t expected_action = gRank10Area2Frames == 17
            ? 0x00001333u : 0x00001932u;
        if (timer != 2830u + gRank10Area2Frames
            || action != expected_action
            || rfloat(A_MARIO_STATES + M_POS_X) != 0.0f
            || rfloat(A_MARIO_STATES + M_POS_Z) != 256.0f
            || floor_owner != gRank10Elevator
            || elevator_y != 4966.0f
            || relative_y !=
                gRank10ExpectedDescentRelativeY[gRank10Area2Frames - 1]) {
            gRank10DescentMismatchFrames++;
        }
    }

    if (action == R10_ACT_FORWARD_ROLLOUT) {
        float forward_vel = rfloat(A_MARIO_STATES + M_FORWARD_VEL);
        gRank10RolloutFrames++;
        if (relative_y > gRank10RolloutMaxRelativeY) {
            gRank10RolloutMaxRelativeY = relative_y;
        }
        if (rfloat(A_MARIO_STATES + M_POS_X) > gRank10RolloutMaxX) {
            gRank10RolloutMaxX = rfloat(A_MARIO_STATES + M_POS_X);
        }
        if (forward_vel == 0.0f) gRank10RolloutWallStops++;
        if (wall != 0) {
            gRank10RolloutWallFrames++;
            if (wall_owner == gRank10Elevator) {
                gRank10RolloutElevatorWallFrames++;
            }
            if (gRank10FirstRolloutWall == 0) {
                gRank10FirstRolloutWall = wall;
                fprintf(stderr,
                        "RANK10_FIRST_WALL,timer=%u,wall=%08x,owner=%08x,"
                        "type=%d,lowerY=%d,upperY=%d,"
                        "v1=(%d,%d,%d),v2=(%d,%d,%d),v3=(%d,%d,%d),"
                        "normal=(%.9g,%.9g,%.9g)\n",
                        timer, wall, wall_owner,
                        (int16_t) R16(wall + R10_SURFACE_TYPE),
                        (int16_t) R16(wall + R10_SURFACE_LOWER_Y),
                        (int16_t) R16(wall + R10_SURFACE_UPPER_Y),
                        (int16_t) R16(wall + R10_SURFACE_VERTEX1),
                        (int16_t) R16(wall + R10_SURFACE_VERTEX1 + 2),
                        (int16_t) R16(wall + R10_SURFACE_VERTEX1 + 4),
                        (int16_t) R16(wall + R10_SURFACE_VERTEX2),
                        (int16_t) R16(wall + R10_SURFACE_VERTEX2 + 2),
                        (int16_t) R16(wall + R10_SURFACE_VERTEX2 + 4),
                        (int16_t) R16(wall + R10_SURFACE_VERTEX3),
                        (int16_t) R16(wall + R10_SURFACE_VERTEX3 + 2),
                        (int16_t) R16(wall + R10_SURFACE_VERTEX3 + 4),
                        rfloat(wall + R10_SURFACE_NORMAL_X),
                        rfloat(wall + R10_SURFACE_NORMAL_Y),
                        rfloat(wall + R10_SURFACE_NORMAL_Z));
            }
        }
        if (floor_owner == gRank10Elevator) {
            gRank10RolloutFloorOwnerFrames++;
        }
        if (rfloat(A_MARIO_STATES + M_POS_X) < -410.0f
            || rfloat(A_MARIO_STATES + M_POS_X) > 411.0f
            || rfloat(A_MARIO_STATES + M_POS_Z) < -154.0f
            || rfloat(A_MARIO_STATES + M_POS_Z) > 667.0f) {
            gRank10RolloutOutsideInnerCenterFrames++;
        }
        fprintf(stderr,
                "RANK10_ROLLOUT_FRAME,timer=%u,actionState=%u,"
                "mario=(%.9g,%.9g,%.9g),velocity=(%.9g,%.9g,%.9g),"
                "forwardVel=%.9g,floor=%08x,floorOwner=%08x,"
                "floorHeight=%.9g,wall=%08x,wallOwner=%08x,ceil=%08x,"
                "platform=%08x,elevatorY=%.9g,relativeY=%.9g\n",
                timer, R16(A_MARIO_STATES + R10_M_ACTION_STATE),
                rfloat(A_MARIO_STATES + M_POS_X),
                rfloat(A_MARIO_STATES + M_POS_Y),
                rfloat(A_MARIO_STATES + M_POS_Z),
                rfloat(A_MARIO_STATES + M_VEL_X),
                rfloat(A_MARIO_STATES + M_VEL_Y),
                rfloat(A_MARIO_STATES + M_VEL_Z), forward_vel,
                floor, floor_owner,
                rfloat(A_MARIO_STATES + M_FLOOR_HEIGHT), wall, wall_owner,
                ceil, platform,
                elevator_y, relative_y);
    }

    if (action != gRank10LastAction || gRank10Area2Frames <= 4
        || gRank10LandingTimer == UINT32_MAX
        || elevator_action != gRank10LastElevatorAction
        || (gRank10Area2Frames % 30) == 0) {
        fprintf(stderr,
                "RANK10_FRAME,timer=%u,area2Frame=%u,action=%08x,"
                "actionState=%u,actionTimer=%u,input=%04x,keys=%u:%u:%d:%d,"
                "marioBits=(%08x,%08x,%08x),mario=(%.9g,%.9g,%.9g),"
                "velocity=(%.9g,%.9g,%.9g),forwardVel=%.9g,"
                "floor=%08x,floorOwner=%08x,floorHeight=%.9g,"
                "platform=%08x,elevator=%08x,elevatorY=%.9g,"
                "relativeY=%.9g,elevatorAction=%u,elevatorTimer=%u,"
                "flags=%08x,capTimer=%u\n",
                timer, gRank10Area2Frames, action,
                R16(A_MARIO_STATES + R10_M_ACTION_STATE),
                R16(A_MARIO_STATES + M_ACTION_TIMER), input,
                keys->A_BUTTON, keys->B_BUTTON,
                keys->X_AXIS, keys->Y_AXIS,
                R32(A_MARIO_STATES + M_POS_X),
                R32(A_MARIO_STATES + M_POS_Y),
                R32(A_MARIO_STATES + M_POS_Z),
                rfloat(A_MARIO_STATES + M_POS_X),
                rfloat(A_MARIO_STATES + M_POS_Y),
                rfloat(A_MARIO_STATES + M_POS_Z),
                rfloat(A_MARIO_STATES + M_VEL_X),
                rfloat(A_MARIO_STATES + M_VEL_Y),
                rfloat(A_MARIO_STATES + M_VEL_Z),
                rfloat(A_MARIO_STATES + M_FORWARD_VEL),
                floor, floor_owner,
                rfloat(A_MARIO_STATES + M_FLOOR_HEIGHT), platform,
                gRank10Elevator, elevator_y,
                relative_y, elevator_action,
                gRank10Elevator == 0 ? UINT32_MAX
                    : R32(gRank10Elevator + O_TIMER),
                flags, R16(A_MARIO_STATES + R10_M_CAP_TIMER));
    }
    gRank10LastAction = action;
    gRank10LastElevatorAction = elevator_action;
}

EXPORT void CALL GetKeys(int control, BUTTONS *keys) {
    Rank10BaseGetKeys(control, keys);
    if (control != 0 || R16(A_CURR_AREA) != 2
        || R32(A_MARIO_OBJECT) == 0) return;

    if (gRank10Elevator == 0) {
        gRank10Elevator = rank10_find_elevator();
        gRank10MarioObject = R32(A_MARIO_OBJECT);
        fprintf(stderr,
                "RANK10_AREA2_START,timer=%u,marioObject=%08x,"
                "stateMarioObject=%08x,marioSlot=%u,elevator=%08x,"
                "candidates=%u,"
                "mode=%d\n",
                R32(A_GLOBAL_TIMER), R32(A_MARIO_OBJECT),
                R32(A_MARIO_STATES + M_MARIO_OBJ),
                (R32(A_MARIO_OBJECT) - A_OBJECT_POOL) / OBJECT_SIZE,
                gRank10Elevator,
                gRank10ElevatorCandidates, RANK10_MODE);
    }
    rank10_apply_rollout_schedule(keys);
    rank10_log_frame(keys);
}

EXPORT void CALL RomClosed(void) {
    fprintf(stderr,
            "RANK10_RESULT,mode=%d,firstTimer=%u,lastTimer=%u,"
            "area2Frames=%u,sequentialFailures=%u,elevator=%08x,"
            "elevatorCandidates=%u,landingTimer=%u,"
            "elevatorPlatformFrames=%u,elevatorFloorFrames=%u,"
            "nonWingFrames=%u,aPressedFrames=%u,aDownFrames=%u,"
            "controllerAFrames=%u,controllerBFrames=%u,stage=%u,"
            "identityMismatchFrames=%u,elevatorIdentityFailureFrames=%u,"
            "floorOwnerMismatchFrames=%u,descentMismatchFrames=%u,"
            "diveTimer=%u,rolloutTimer=%u,rolloutFrames=%u,"
            "rolloutWallStops=%u,rolloutMaxRelativeY=%.9g,"
            "rolloutMaxX=%.9g,rolloutWallFrames=%u,"
            "rolloutElevatorWallFrames=%u,rolloutFloorOwnerFrames=%u,"
            "rolloutOutsideInnerCenterFrames=%u,firstRolloutWall=%08x\n",
            RANK10_MODE, gRank10FirstTimer, gRank10LastTimer,
            gRank10Area2Frames, gRank10SequentialFailures,
            gRank10Elevator, gRank10ElevatorCandidates, gRank10LandingTimer,
            gRank10ElevatorPlatformFrames, gRank10ElevatorFloorFrames,
            gRank10NonWingFrames, gRank10APressedFrames,
            gRank10ADownFrames, gRank10ControllerAFrames,
            gRank10ControllerBFrames, gRank10Stage,
            gRank10IdentityMismatchFrames,
            gRank10ElevatorIdentityFailureFrames,
            gRank10FloorOwnerMismatchFrames, gRank10DescentMismatchFrames,
            gRank10DiveTimer, gRank10RolloutTimer, gRank10RolloutFrames,
            gRank10RolloutWallStops, gRank10RolloutMaxRelativeY,
            gRank10RolloutMaxX, gRank10RolloutWallFrames,
            gRank10RolloutElevatorWallFrames,
            gRank10RolloutFloorOwnerFrames,
            gRank10RolloutOutsideInnerCenterFrames,
            gRank10FirstRolloutWall);
    Rank10BaseRomClosed();
}
