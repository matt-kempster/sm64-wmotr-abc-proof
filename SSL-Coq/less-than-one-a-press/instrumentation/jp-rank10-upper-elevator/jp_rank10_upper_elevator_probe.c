#include <stdlib.h>

#define ALLOW_SETUP_A 0
#define SEARCH_MODE 12
#define GetKeys Rank10BaseGetKeys
#define RomClosed Rank10BaseRomClosed
#define PluginStartup Rank10BasePluginStartup
#include "../jp-clean-gap-search/jp_clean_gap_search_probe.c"
#undef GetKeys
#undef RomClosed
#undef PluginStartup

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
    R10_ACT_MOVE_PUNCHING = 0x00800457,
    R10_ACT_JUMP_KICK = 0x018008ac,
};

#define R10_A_AIR_QSTEP             0x80255e84u
#define R10_A_AFTER_UPPER_WALL      0x80255ebcu
#define R10_A_AFTER_LOWER_WALL      0x80255ed0u
#define R10_A_AFTER_FLOOR           0x80255eecu
#define R10_A_AFTER_CEIL            0x80255f00u
#define R10_A_AIR_QSTEP_RETURN      0x802562a4u
#define R10_A_FIND_WALL_COLLISIONS  0x80380e8cu
#define R10_A_FIND_CEIL             0x80381264u
#define R10_A_FIND_FLOOR            0x80381900u

static uint32_t gRank10Elevator;
static uint32_t gRank10MarioObject;
static uint32_t gRank10FirstRolloutWall;
static uint32_t gRank10FirstJumpKickWall;
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
static unsigned gRank10JumpKickInputTimer = UINT32_MAX;
static unsigned gRank10JumpKickTimer = UINT32_MAX;
static unsigned gRank10HeldAArmTimer = UINT32_MAX;
static int gRank10HeldAArmed;
static int gRank10PassiveDebuggerArmed;
static int gRank10ResumeInitialized;
static int gRank10StateSaveRequested;
typedef m64p_error (*rank10_core_do_command_fn)(int, int, void *);
static rank10_core_do_command_fn gRank10CoreDoCommand;
static int gRank10QueryArmed;
static int gRank10QueryActive;
static unsigned gRank10QuerySteps;
static unsigned gRank10QueryCompleteSteps;
static unsigned gRank10QuerySequenceFailures;
static unsigned gRank10QueryPhaseFailures;
static unsigned gRank10QueryWrongMario;
static unsigned gRank10QueryNonzeroStepArg;
static unsigned gRank10QueryVerticalMismatches;
static unsigned gRank10QueryFloorOwnerMismatches;
static unsigned gRank10QueryWallOwnerMismatches;
static unsigned gRank10QueryCeilOwnerMismatches;
static unsigned gRank10QueryWallCalls;
static unsigned gRank10QueryFloorCalls;
static unsigned gRank10QueryCeilCalls;
static unsigned gRank10QueryWallCallsTotal;
static unsigned gRank10QueryFloorCallsTotal;
static unsigned gRank10QueryCeilCallsTotal;
static unsigned gRank10QueryOrder;
static unsigned gRank10QueryUpperPost;
static unsigned gRank10QueryLowerPost;
static unsigned gRank10QueryFloorPost;
static unsigned gRank10QueryCeilPost;
static unsigned gRank10QueryResultCounts[7];
static unsigned gRank10QueryOtherResults;
static uint32_t gRank10QueryAction;
static uint32_t gRank10QueryStepArg;
static uint32_t gRank10QueryUpperWall;
static uint32_t gRank10QueryLowerWall;
static uint32_t gRank10QueryFloor;
static uint32_t gRank10QueryCeil;
static float gRank10QueryIntendedX;
static float gRank10QueryIntendedY;
static float gRank10QueryIntendedZ;
static float gRank10QueryFloorHeight;
static float gRank10QueryCeilHeight;
static float gRank10QueryMaxRelativeY = -INFINITY;
static int gRank10QueryExpectedRelativeHalf;
static int gRank10QueryExpectedVelocity;
static int gRank10QueryCurrentRelativeHalf;

static int rank10_handle_query_breakpoint(
    uint32_t pc, const uint64_t *registers) {
    uint32_t sp;

    if (pc == R10_A_AIR_QSTEP) {
        uint32_t intended;
        uint32_t action = R32(A_MARIO_STATES + M_ACTION);

        if (action != R10_ACT_JUMP_KICK
            && action != R10_ACT_FORWARD_ROLLOUT) return 1;
        if (gRank10QueryActive) gRank10QueryPhaseFailures++;
        gRank10QueryActive = 1;
        gRank10QuerySteps++;
        gRank10QueryAction = action;
        if (gRank10QuerySteps == 1) {
            gRank10QueryExpectedRelativeHalf = 0;
            gRank10QueryExpectedVelocity =
                action == R10_ACT_JUMP_KICK ? 20 : 30;
        }
        if ((gRank10QuerySteps - 1) % 4 == 0) {
            /* The elevator descends ten units before Mario's four quarters. */
            gRank10QueryExpectedRelativeHalf += 20;
        }
        gRank10QueryExpectedRelativeHalf +=
            gRank10QueryExpectedVelocity / 2;
        gRank10QueryCurrentRelativeHalf =
            gRank10QueryExpectedRelativeHalf;
        if (gRank10QuerySteps % 4 == 0) {
            gRank10QueryExpectedVelocity -= 4;
        }
        gRank10QueryOrder = 0;
        gRank10QueryWallCalls = 0;
        gRank10QueryFloorCalls = 0;
        gRank10QueryCeilCalls = 0;
        gRank10QueryUpperPost = 0;
        gRank10QueryLowerPost = 0;
        gRank10QueryFloorPost = 0;
        gRank10QueryCeilPost = 0;
        gRank10QueryUpperWall = 0;
        gRank10QueryLowerWall = 0;
        gRank10QueryFloor = 0;
        gRank10QueryCeil = 0;
        gRank10QueryFloorHeight = -INFINITY;
        gRank10QueryCeilHeight = -INFINITY;
        if (registers == NULL) {
            gRank10QueryPhaseFailures++;
            return 1;
        }
        if ((uint32_t) registers[4] != A_MARIO_STATES) {
            gRank10QueryWrongMario++;
        }
        intended = (uint32_t) registers[5];
        gRank10QueryStepArg = (uint32_t) registers[6];
        if (gRank10QueryStepArg != 0) gRank10QueryNonzeroStepArg++;
        gRank10QueryIntendedX = rfloat(intended);
        gRank10QueryIntendedY = rfloat(intended + 4);
        gRank10QueryIntendedZ = rfloat(intended + 8);
        return 1;
    }

    if (pc != R10_A_AFTER_UPPER_WALL
        && pc != R10_A_AFTER_LOWER_WALL
        && pc != R10_A_AFTER_FLOOR
        && pc != R10_A_AFTER_CEIL
        && pc != R10_A_AIR_QSTEP_RETURN
        && pc != R10_A_FIND_WALL_COLLISIONS
        && pc != R10_A_FIND_FLOOR
        && pc != R10_A_FIND_CEIL) return 0;
    if (!gRank10QueryActive) return 1;
    if (registers == NULL) {
        gRank10QueryPhaseFailures++;
        return 1;
    }
    sp = (uint32_t) registers[29];

    if (pc == R10_A_FIND_WALL_COLLISIONS) {
        gRank10QueryWallCalls++;
        gRank10QueryWallCallsTotal++;
        gRank10QueryOrder = gRank10QueryOrder * 10 + 1;
    } else if (pc == R10_A_FIND_FLOOR) {
        gRank10QueryFloorCalls++;
        gRank10QueryFloorCallsTotal++;
        gRank10QueryOrder = gRank10QueryOrder * 10 + 2;
    } else if (pc == R10_A_FIND_CEIL) {
        gRank10QueryCeilCalls++;
        gRank10QueryCeilCallsTotal++;
        gRank10QueryOrder = gRank10QueryOrder * 10 + 3;
    } else if (pc == R10_A_AFTER_UPPER_WALL) {
        gRank10QueryUpperWall = R32(sp + 60);
        gRank10QueryUpperPost++;
    } else if (pc == R10_A_AFTER_LOWER_WALL) {
        gRank10QueryLowerWall = R32(sp + 56);
        gRank10QueryLowerPost++;
    } else if (pc == R10_A_AFTER_FLOOR) {
        gRank10QueryFloorHeight = rfloat(sp + 40);
        gRank10QueryFloor = R32(sp + 48);
        gRank10QueryFloorPost++;
    } else if (pc == R10_A_AFTER_CEIL) {
        gRank10QueryCeilHeight = rfloat(sp + 44);
        gRank10QueryCeil = R32(sp + 52);
        gRank10QueryCeilPost++;
    } else {
        uint32_t result = (uint32_t) registers[2];
        uint32_t upper_owner = gRank10QueryUpperWall == 0 ? 0
            : R32(gRank10QueryUpperWall + R10_SURFACE_OBJECT);
        uint32_t lower_owner = gRank10QueryLowerWall == 0 ? 0
            : R32(gRank10QueryLowerWall + R10_SURFACE_OBJECT);
        uint32_t floor_owner = gRank10QueryFloor == 0 ? 0
            : R32(gRank10QueryFloor + R10_SURFACE_OBJECT);
        uint32_t ceil_owner = gRank10QueryCeil == 0 ? 0
            : R32(gRank10QueryCeil + R10_SURFACE_OBJECT);
        float relative_y = gRank10QueryIntendedY - gRank10QueryFloorHeight;
        float expected_relative_y =
            (float) gRank10QueryCurrentRelativeHalf / 2.0f;
        int complete = gRank10QueryWallCalls == 2
            && gRank10QueryFloorCalls == 1
            && gRank10QueryCeilCalls == 1
            && gRank10QueryOrder == 1123
            && gRank10QueryUpperPost == 1
            && gRank10QueryLowerPost == 1
            && gRank10QueryFloorPost == 1
            && gRank10QueryCeilPost == 1;

        if (complete) gRank10QueryCompleteSteps++;
        else gRank10QuerySequenceFailures++;
        if (relative_y != expected_relative_y) {
            gRank10QueryVerticalMismatches++;
        }
        if (relative_y > gRank10QueryMaxRelativeY) {
            gRank10QueryMaxRelativeY = relative_y;
        }
        if (gRank10QueryFloor == 0
            || floor_owner != gRank10Elevator) {
            gRank10QueryFloorOwnerMismatches++;
        }
        if ((gRank10QueryUpperWall != 0
                && upper_owner != gRank10Elevator)
            || (gRank10QueryLowerWall != 0
                && lower_owner != gRank10Elevator)) {
            gRank10QueryWallOwnerMismatches++;
        }
        if (gRank10QueryCeil == 0 || ceil_owner != 0) {
            gRank10QueryCeilOwnerMismatches++;
        }
        if (result <= 6) gRank10QueryResultCounts[result]++;
        else gRank10QueryOtherResults++;
        fprintf(stderr,
                "RANK10_QSTEP,index=%u,timer=%u,action=%08x,stepArg=%u,"
                "intended=(%.9g,%.9g,%.9g),order=%04u,"
                "upperWall=%08x,upperOwner=%08x,"
                "lowerWall=%08x,lowerOwner=%08x,"
                "floor=%08x,floorOwner=%08x,floorHeight=%.9g,"
                "ceil=%08x,ceilOwner=%08x,ceilHeight=%.9g,"
                "relativeY=%.9g,expectedRelativeY=%.9g,"
                "result=%u,complete=%d\n",
                gRank10QuerySteps, R32(A_GLOBAL_TIMER),
                gRank10QueryAction, gRank10QueryStepArg,
                gRank10QueryIntendedX, gRank10QueryIntendedY,
                gRank10QueryIntendedZ, gRank10QueryOrder,
                gRank10QueryUpperWall, upper_owner,
                gRank10QueryLowerWall, lower_owner,
                gRank10QueryFloor, floor_owner,
                gRank10QueryFloorHeight, gRank10QueryCeil, ceil_owner,
                gRank10QueryCeilHeight, relative_y, expected_relative_y,
                result, complete);
        gRank10QueryActive = 0;
    }
    return 1;
}

static void rank10_debugger_update_callback(unsigned int pc) {
    uint64_t *registers =
        (uint64_t *) DGetCPUDataPtr(M64P_CPU_REG_REG);
    if (rank10_handle_query_breakpoint(pc, registers)) {
        resume_from_breakpoint();
        return;
    }
    debugger_update_callback(pc);
}

static void rank10_arm_query_breakpoints(void) {
    int armed;

    if (gRank10QueryArmed || getenv("RANK10_QUERY_TRACE") == NULL
        || gRank10Stage < 4) return;
    DSetCallbacks(debugger_init_callback, rank10_debugger_update_callback,
                  debugger_vi_callback);
    armed = add_exec_breakpoint(R10_A_AIR_QSTEP)
        && add_exec_breakpoint(R10_A_AFTER_UPPER_WALL)
        && add_exec_breakpoint(R10_A_AFTER_LOWER_WALL)
        && add_exec_breakpoint(R10_A_AFTER_FLOOR)
        && add_exec_breakpoint(R10_A_AFTER_CEIL)
        && add_exec_breakpoint(R10_A_AIR_QSTEP_RETURN)
        && add_exec_breakpoint(R10_A_FIND_WALL_COLLISIONS)
        && add_exec_breakpoint(R10_A_FIND_FLOOR)
        && add_exec_breakpoint(R10_A_FIND_CEIL);
    if (!armed) {
        fprintf(stderr, "RANK10_QUERY_ERROR,kind=breakpoint-arm\n");
        return;
    }
    gRank10QueryArmed = 1;
    fprintf(stderr,
            "RANK10_QUERY_ARM,timer=%u,qstep=%08x,wall=%08x,"
            "floor=%08x,ceil=%08x\n",
            R32(A_GLOBAL_TIMER), R10_A_AIR_QSTEP,
            R10_A_FIND_WALL_COLLISIONS, R10_A_FIND_FLOOR,
            R10_A_FIND_CEIL);
}
static unsigned gRank10JumpKickFrames;
static unsigned gRank10JumpKickWallFrames;
static unsigned gRank10JumpKickElevatorWallFrames;
static unsigned gRank10JumpKickFloorOwnerFrames;
static unsigned gRank10JumpKickOutsideInnerCenterFrames;
static float gRank10JumpKickMaxRelativeY = -INFINITY;
static float gRank10JumpKickMaxX = -INFINITY;
static float gRank10JumpKickMaxOutward = -INFINITY;
static float gRank10RolloutMaxRelativeY = -INFINITY;
static float gRank10RolloutMaxX = -INFINITY;

static const float gRank10ExpectedDescentRelativeY[17] = {
    534.0f, 530.0f, 522.0f, 510.0f, 494.0f, 474.0f,
    450.0f, 422.0f, 390.0f, 354.0f, 314.0f, 270.0f,
    222.0f, 170.0f, 114.0f, 54.0f, 0.0f,
};

static const float gRank10HeldLaunchX[4] = { 250.0f, -250.0f, 0.0f, 0.0f };
static const float gRank10HeldLaunchZ[4] = { 256.0f, 256.0f, 506.0f, 6.0f };
static const float gRank10HeldDirectionX[4] = { 1.0f, -1.0f, 0.0f, 0.0f };
static const float gRank10HeldDirectionZ[4] = { 0.0f, 0.0f, 1.0f, -1.0f };
static const uint16_t gRank10HeldYaw[4] = { 0x4000, 0xc000, 0x0000, 0x8000 };
static const char *gRank10HeldPoseName[4] = { "east", "west", "north", "south" };

static int rank10_is_held_mode(void) {
    return RANK10_MODE >= 2 && RANK10_MODE <= 5;
}

static unsigned rank10_held_pose(void) {
    return (unsigned) (RANK10_MODE - 2);
}

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

static void rank10_apply_held_a_jump_kick_schedule(BUTTONS *keys) {
    uint32_t action = R32(A_MARIO_STATES + M_ACTION);
    float x = rfloat(A_MARIO_STATES + M_POS_X);
    float z = rfloat(A_MARIO_STATES + M_POS_Z);
    float forward_vel = rfloat(A_MARIO_STATES + M_FORWARD_VEL);
    unsigned pose;
    float launch_x;
    float launch_z;
    float direction_x;
    float direction_z;

    if (!rank10_is_held_mode() || gRank10LandingTimer == UINT32_MAX) return;
    pose = rank10_held_pose();
    launch_x = gRank10HeldLaunchX[pose];
    launch_z = gRank10HeldLaunchZ[pose];
    direction_x = gRank10HeldDirectionX[pose];
    direction_z = gRank10HeldDirectionZ[pose];

    switch (gRank10Stage) {
        case 0:
            if (action == R10_ACT_IDLE) {
                fprintf(stderr,
                        "RANK10_POSE,timer=%u,pose=%s,launch=(%.9g,%.9g),"
                        "direction=(%.9g,%.9g)\n",
                        R32(A_GLOBAL_TIMER), gRank10HeldPoseName[pose],
                        launch_x, launch_z, direction_x, direction_z);
                rank10_set_stage(1, "held-a-move-to-launch");
            }
            break;
        case 1:
            steer_world(keys, launch_x, launch_z, 24.0f);
            if (hypotf(x - launch_x, z - launch_z) < 10.0f) {
                memset(keys, 0, sizeof(*keys));
                rank10_set_stage(2, "held-a-settle-at-launch");
            }
            break;
        case 2:
            if (action == R10_ACT_IDLE && fabsf(forward_vel) < 1.0f
                && R32(A_GLOBAL_TIMER) - gRank10StageTimer >= 4) {
                rank10_set_stage(3, "held-a-accelerate-outward");
            }
            break;
        case 3: {
            int16_t face_yaw = (int16_t) R16(
                A_MARIO_STATES + M_FACE_YAW);
            int16_t launch_error = (int16_t) (
                face_yaw - (int16_t) gRank10HeldYaw[pose]);

            if (launch_error < 0) launch_error = -launch_error;
            steer_world(keys, x + direction_x * 1000.0f,
                        z + direction_z * 1000.0f, 127.0f);
            if (action == ACT_WALKING && forward_vel >= 10.0f
                && forward_vel < 28.0f
                && hypotf(x - launch_x, z - launch_z) < 120.0f
                && launch_error < 0x0800) {
                keys->B_BUTTON = 1;
                gRank10JumpKickInputTimer = R32(A_GLOBAL_TIMER);
                rank10_set_stage(4, "held-a-punch-input");
            }
            break;
        }
        case 4:
            steer_world(keys, x + direction_x * 1000.0f,
                        z + direction_z * 1000.0f, 127.0f);
            if (action == R10_ACT_JUMP_KICK) {
                gRank10JumpKickTimer = R32(A_GLOBAL_TIMER);
                rank10_set_stage(5, "held-a-jump-kick-observed");
            } else if (R32(A_GLOBAL_TIMER) > gRank10JumpKickInputTimer + 3
                       && action != R10_ACT_MOVE_PUNCHING) {
                memset(keys, 0, sizeof(*keys));
                rank10_set_stage(7, "held-a-jump-kick-not-entered");
            }
            break;
        case 5:
            steer_world(keys, x + direction_x * 1000.0f,
                        z + direction_z * 1000.0f, 127.0f);
            if (action != R10_ACT_JUMP_KICK
                && R32(A_GLOBAL_TIMER) > gRank10JumpKickTimer + 1) {
                memset(keys, 0, sizeof(*keys));
                rank10_set_stage(6, "held-a-jump-kick-ended");
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
        if (timer != gRank10FirstTimer + gRank10Area2Frames - 1
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

    if (action == R10_ACT_JUMP_KICK) {
        float forward_vel = rfloat(A_MARIO_STATES + M_FORWARD_VEL);
        unsigned pose = rank10_held_pose();
        float outward = rfloat(A_MARIO_STATES + M_POS_X)
                * gRank10HeldDirectionX[pose]
            + (rfloat(A_MARIO_STATES + M_POS_Z) - 256.0f)
                * gRank10HeldDirectionZ[pose];
        gRank10JumpKickFrames++;
        if (relative_y > gRank10JumpKickMaxRelativeY) {
            gRank10JumpKickMaxRelativeY = relative_y;
        }
        if (rfloat(A_MARIO_STATES + M_POS_X) > gRank10JumpKickMaxX) {
            gRank10JumpKickMaxX = rfloat(A_MARIO_STATES + M_POS_X);
        }
        if (outward > gRank10JumpKickMaxOutward) {
            gRank10JumpKickMaxOutward = outward;
        }
        if (wall != 0) {
            gRank10JumpKickWallFrames++;
            if (wall_owner == gRank10Elevator) {
                gRank10JumpKickElevatorWallFrames++;
            }
            if (gRank10FirstJumpKickWall == 0) {
                gRank10FirstJumpKickWall = wall;
                fprintf(stderr,
                        "RANK10_FIRST_JUMP_WALL,timer=%u,wall=%08x,"
                        "owner=%08x,type=%d,lowerY=%d,upperY=%d,"
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
            gRank10JumpKickFloorOwnerFrames++;
        }
        if (rfloat(A_MARIO_STATES + M_POS_X) < -410.0f
            || rfloat(A_MARIO_STATES + M_POS_X) > 411.0f
            || rfloat(A_MARIO_STATES + M_POS_Z) < -154.0f
            || rfloat(A_MARIO_STATES + M_POS_Z) > 667.0f) {
            gRank10JumpKickOutsideInnerCenterFrames++;
        }
        fprintf(stderr,
                "RANK10_JUMP_KICK_FRAME,timer=%u,actionState=%u,"
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
                ceil, platform, elevator_y, relative_y);
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

EXPORT m64p_error CALL PluginStartup(
    m64p_dynlib_handle core, void *context,
    void (*debug_callback)(void *, int, const char *)) {
    m64p_error result = Rank10BasePluginStartup(
        core, context, debug_callback);
    if (result == M64ERR_SUCCESS) {
        gRank10CoreDoCommand = (rank10_core_do_command_fn) dlsym(
            core, "CoreDoCommand");
    }
    return result;
}

EXPORT void CALL GetKeys(int control, BUTTONS *keys) {
    const char *state_path;

    /* Rank 10 authenticates the unchanged ROM and reuses the already accepted
       Area-1 controller receipt.  Do not reinstall that probe's 19 prefix
       breakpoints here: they add substantial debugger overhead but supply no
       Rank-10 fact.  Likewise suppress its running minimum-gap diagnostics;
       the Rank-10 logger records the relevant Mario/elevator separation. */
    if (!gRank10ResumeInitialized && getenv("RANK10_RESUME_STATE") != NULL) {
        /* The checkpoint is taken at timer 2808 in the accepted prefix.
           Continue the input schedule beyond the level-select keystrokes. */
        gPoll = 2807;
        gRank10ResumeInitialized = 1;
    }
    if (!gRank10PassiveDebuggerArmed && getenv("RANK10_NO_DEBUG") == NULL) {
        DSetCallbacks(debugger_init_callback, debugger_update_callback,
                      debugger_vi_callback);
        gRank10PassiveDebuggerArmed = 1;
    }
    if (!gPrefixTraceArmed) gPrefixTraceArmed = 1;
    gPostTraceActive = 1;
    gPostTraceComplete = 1;
    gMinGfxMinusObjectY = -INFINITY;
    Rank10BaseGetKeys(control, keys);
    if (control != 0) return;

    state_path = getenv("RANK10_SAVE_STATE");
    if (!gRank10StateSaveRequested && state_path != NULL
        && gRank10CoreDoCommand != NULL
        && R16(A_CURR_AREA) == 1
        && R32(A_MARIO_STATES + M_ACTION) == ACT_DISAPPEARED
        && gUpperWarp != 0
        && R32(A_MARIO_STATES + M_USED_OBJ) == gUpperWarp) {
        /* M64CMD_STATE_SAVE is command 11 in m64p_types.h; ParamInt=1 makes
           ParamPtr an explicit filename.  This saves emulator state only and
           never writes N64 game memory. */
        m64p_error save_result = gRank10CoreDoCommand(
            11, 1, (void *) state_path);
        gRank10StateSaveRequested = 1;
        fprintf(stderr,
                "RANK10_STATE_SAVE,timer=%u,path=%s,result=%d\n",
                R32(A_GLOBAL_TIMER), state_path, save_result);
    }

    /* Preserve the established Area-1 route, then arm held A only after the
       upper warp has already put Mario in ACT_DISAPPEARED.  This supplies an
       honest Area-2 held-state experiment with no Area-2 A edge, but it is not
       an end-to-end zero-edge witness: the arming edge belongs to the final
       Area-1 warp frame and is reported separately. */
    if (rank10_is_held_mode() && !gRank10HeldAArmed
        && R16(A_CURR_AREA) == 1
        && R32(A_MARIO_STATES + M_ACTION) == ACT_DISAPPEARED
        && R32(A_MARIO_STATES + M_USED_OBJ) == gUpperWarp) {
        gRank10HeldAArmed = 1;
        gRank10HeldAArmTimer = R32(A_GLOBAL_TIMER);
        fprintf(stderr, "RANK10_HELD_ARM,timer=%u,boundary=area1-disappeared\n",
                gRank10HeldAArmTimer);
    }
    if (rank10_is_held_mode() && gRank10HeldAArmed) {
        keys->A_BUTTON = 1;
    }

    if (R16(A_CURR_AREA) != 2
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
    rank10_apply_held_a_jump_kick_schedule(keys);
    rank10_arm_query_breakpoints();
    if (rank10_is_held_mode() && gRank10HeldAArmed) keys->A_BUTTON = 1;
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
    if (rank10_is_held_mode()) {
        fprintf(stderr,
                "RANK10_HELD_RESULT,pose=%s,armTimer=%u,inputTimer=%u,"
                "jumpKickTimer=%u,"
                "jumpKickFrames=%u,jumpKickMaxRelativeY=%.9g,"
                "jumpKickMaxX=%.9g,jumpKickMaxOutward=%.9g,"
                "jumpKickWallFrames=%u,"
                "jumpKickElevatorWallFrames=%u,"
                "jumpKickFloorOwnerFrames=%u,"
                "jumpKickOutsideInnerCenterFrames=%u,"
                "firstJumpKickWall=%08x\n",
                gRank10HeldPoseName[rank10_held_pose()],
                gRank10HeldAArmTimer, gRank10JumpKickInputTimer,
                gRank10JumpKickTimer,
                gRank10JumpKickFrames, gRank10JumpKickMaxRelativeY,
                gRank10JumpKickMaxX, gRank10JumpKickMaxOutward,
                gRank10JumpKickWallFrames,
                gRank10JumpKickElevatorWallFrames,
                gRank10JumpKickFloorOwnerFrames,
                gRank10JumpKickOutsideInnerCenterFrames,
                gRank10FirstJumpKickWall);
    }
    if (gRank10QueryArmed) {
        fprintf(stderr,
                "RANK10_QUERY_RESULT,steps=%u,complete=%u,"
                "sequenceFailures=%u,phaseFailures=%u,wrongMario=%u,"
                "nonzeroStepArg=%u,verticalMismatches=%u,"
                "floorOwnerMismatches=%u,wallOwnerMismatches=%u,"
                "ceilOwnerMismatches=%u,maxRelativeY=%.9g,"
                "wallCalls=%u,floorCalls=%u,"
                "ceilCalls=%u,result0=%u,result1=%u,result2=%u,"
                "result3=%u,result4=%u,result5=%u,result6=%u,"
                "otherResults=%u,activeAtClose=%d\n",
                gRank10QuerySteps, gRank10QueryCompleteSteps,
                gRank10QuerySequenceFailures, gRank10QueryPhaseFailures,
                gRank10QueryWrongMario, gRank10QueryNonzeroStepArg,
                gRank10QueryVerticalMismatches,
                gRank10QueryFloorOwnerMismatches,
                gRank10QueryWallOwnerMismatches,
                gRank10QueryCeilOwnerMismatches,
                gRank10QueryMaxRelativeY,
                gRank10QueryWallCallsTotal, gRank10QueryFloorCallsTotal,
                gRank10QueryCeilCallsTotal,
                gRank10QueryResultCounts[0],
                gRank10QueryResultCounts[1],
                gRank10QueryResultCounts[2],
                gRank10QueryResultCounts[3],
                gRank10QueryResultCounts[4],
                gRank10QueryResultCounts[5],
                gRank10QueryResultCounts[6],
                gRank10QueryOtherResults, gRank10QueryActive);
    }
    Rank10BaseRomClosed();
}
