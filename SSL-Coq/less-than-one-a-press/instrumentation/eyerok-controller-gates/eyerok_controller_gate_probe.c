/*
 * Controller-only Eyerok gate/chase probe after the ordinary Area-3 entry.
 *
 * The inherited harness is used only to reach the real Area-2 instant-warp
 * surface quickly.  It discloses those pre-boundary writes.  Once Area 3 is
 * observed, this override never calls the inherited GetKeys again and makes
 * no memory write: it supplies analog-stick input, discovers the live boss
 * and hands, and logs retail state.
 */

#define GetKeys FixtureGetKeys
#define RomClosed FixtureRomClosed
#include "../../../old-proofs/eyerok-manipulation/instrumentation/mupen64plus/eyerok_idle_double_probe.c"
#undef GetKeys
#undef RomClosed

#ifndef SELECTION_X
#define SELECTION_X 0.0f
#endif
#ifndef KITE_X
#define KITE_X 0.0f
#endif
#ifndef KITE_Z
#define KITE_Z -1800.0f
#endif
#ifndef SMASH_SIDE_SIGN
#define SMASH_SIDE_SIGN 1
#endif
#ifndef SMASH_ANGLE_MAG
#define SMASH_ANGLE_MAG 0x4000
#endif
#ifndef SMASH_TARGET_RADIUS
#define SMASH_TARGET_RADIUS 180.0f
#endif

enum {
    M_AREA = 0x90,
    M_VEL_X = 0x48,
    M_VEL_Y = 0x4c,
    M_VEL_Z = 0x50,
    M_FORWARD_VEL = 0x54,
    M_FLOOR = 0x68,
    M_FLOOR_HEIGHT = 0x70,
    AREA_CAMERA = 0x24,
    CAMERA_YAW = 0x02,
    SURFACE_OBJECT = 0x2c,
    O_FORWARD_VEL = 0x0b8,
    O_MOVE_YAW = 0x0c8,
    O_FACE_YAW = 0x0d4,
    O_BOSS_COUNTER = 0x0fc,
};

enum {
    HAND_TARGET_MARIO = 6,
    HAND_SMASH = 7,
    HAND_FIST_PUSH = 8,
    HAND_FIST_SWEEP = 9,
};

enum ProbePhase {
    PHASE_SEEK_WAKE = 0,
    PHASE_RETURN_TO_STRIP = 1,
    PHASE_WAIT_FOR_TARGET = 2,
    PHASE_KITE_TARGET = 3,
    PHASE_SET_SMASH_SIDE = 4,
    PHASE_OBSERVE_SWEEP = 5,
    PHASE_DONE = 6,
};

static enum ProbePhase gPhase;
static uint32_t gArea3BoundaryTimer;
static uint32_t gTargetHand;
static uint32_t gTargetSelectionTimer;
static uint32_t gSweepTimer;
static uint32_t gLastGateTimer = UINT32_MAX;
static unsigned gArea3Polls;
static unsigned gSawWake;
static unsigned gSawStripBeforeFight;
static unsigned gSawDeterministicTarget;
static unsigned gSawReleasedChase;
static unsigned gSawSmash;
static unsigned gSawSweep;
static unsigned gAInputPolls;
static unsigned gBInputPolls;
static unsigned gHandFloorFrames;
static unsigned gHandPlatformFrames;
static float gSelectionMarioZ;
static float gSelectionHandZ;
static float gFarthestHandZ;

static int clamp_axis_gate(int value) {
    if (value < -127) return -127;
    if (value > 127) return 127;
    return value;
}

static int16_t rs16_gate(uint32_t address) {
    return (int16_t) R16(address);
}

static void steer_world_gate(BUTTONS *keys, float target_x, float target_z) {
    uint32_t area = R32(A_MARIO_STATES + M_AREA);
    uint32_t camera = area == 0 ? 0 : R32(area + AREA_CAMERA);
    int16_t cameraYaw = camera == 0 ? 0 : rs16_gate(camera + CAMERA_YAW);
    float x = rfloat(A_MARIO_STATES + 0x3c);
    float z = rfloat(A_MARIO_STATES + 0x44);
    float vx = rfloat(A_MARIO_STATES + M_VEL_X);
    float vz = rfloat(A_MARIO_STATES + M_VEL_Z);
    float dx = target_x - (x + vx * 4.0f);
    float dz = target_z - (z + vz * 4.0f);
    float distance = sqrtf(dx * dx + dz * dz);
    float desired = atan2f(dx, dz);
    float cameraRadians = (float) cameraYaw
        * (2.0f * 3.14159265358979323846f / 65536.0f);
    float controllerAngle = desired - cameraRadians;
    float magnitude = distance < 80.0f ? distance * 1.5f : 127.0f;

    keys->X_AXIS = (int8_t) clamp_axis_gate(
        (int) lrintf(sinf(controllerAngle) * magnitude));
    keys->Y_AXIS = (int8_t) clamp_axis_gate(
        (int) lrintf(-cosf(controllerAngle) * magnitude));
}

static void steer_to_smash_side(BUTTONS *keys, uint32_t hand) {
    int16_t faceYaw = rs16_gate(hand + O_FACE_YAW);
    int16_t desiredYaw = (int16_t)
        (faceYaw + (SMASH_SIDE_SIGN > 0
                    ? SMASH_ANGLE_MAG : -SMASH_ANGLE_MAG));
    float radians = (float) desiredYaw
        * (2.0f * 3.14159265358979323846f / 65536.0f);
    float targetX = rfloat(hand + O_POS_X)
        + sinf(radians) * SMASH_TARGET_RADIUS;
    float targetZ = rfloat(hand + O_POS_Z)
        + cosf(radians) * SMASH_TARGET_RADIUS;
    steer_world_gate(keys, targetX, targetZ);
}

static uint32_t find_hand_with_action(int action) {
    unsigned i;
    for (i = 0; i < 2; ++i) {
        if (gHands[i] != 0 && rs32(gHands[i] + O_ACTION) == action) {
            return gHands[i];
        }
    }
    return 0;
}

static void print_gate_header(void) {
    fprintf(stderr,
            "GATE_HEADER,timer,phase,marioX,marioY,marioZ,marioAction,"
            "marioForwardVel,marioVelY,floor,floorOwner,floorHeight,platform,"
            "bossAction,bossTimer,bossCounter,bossActive,"
            "bossDouble,bossEyeLock,hand,side,handAction,handTimer,handX,"
            "handY,handZ,handForwardVel,handMoveYaw,handFaceYaw,handMoveFlags\n");
}

static void log_gate_frame(uint32_t timer) {
    uint32_t hand = gTargetHand;
    uint32_t floor = R32(A_MARIO_STATES + M_FLOOR);
    uint32_t floorOwner = floor == 0 ? 0 : R32(floor + SURFACE_OBJECT);
    uint32_t platform = R32(A_MARIO_PLATFORM);
    if (hand == 0) {
        hand = gHands[0] != 0 ? gHands[0] : gHands[1];
    }
    if (hand != 0 && rfloat(hand + O_POS_Z) > gFarthestHandZ) {
        gFarthestHandZ = rfloat(hand + O_POS_Z);
    }
    if (hand != 0 && floorOwner == hand) ++gHandFloorFrames;
    if (hand != 0 && platform == hand) ++gHandPlatformFrames;
    fprintf(stderr,
            "GATE,%u,%d,%.6f,%.6f,%.6f,%08x,%.6f,%.6f,%08x,%08x,%.6f,%08x,"
            "%d,%d,%d,%d,%d,%d,"
            "%08x,%d,%d,%d,%.6f,%.6f,%.6f,%.6f,%d,%d,%08x\n",
            timer, (int) gPhase,
            rfloat(A_MARIO_STATES + 0x3c),
            rfloat(A_MARIO_STATES + 0x40),
            rfloat(A_MARIO_STATES + 0x44),
            R32(A_MARIO_STATES + 0x0c),
            rfloat(A_MARIO_STATES + M_FORWARD_VEL),
            rfloat(A_MARIO_STATES + M_VEL_Y),
            floor, floorOwner,
            rfloat(A_MARIO_STATES + M_FLOOR_HEIGHT), platform,
            gBoss ? rs32(gBoss + O_ACTION) : -1,
            gBoss ? rs32(gBoss + O_TIMER) : -1,
            gBoss ? rs32(gBoss + O_BOSS_COUNTER) : -1,
            gBoss ? rs32(gBoss + O_BOSS_ACTIVE) : -1,
            gBoss ? rs32(gBoss + O_BOSS_104) : -1,
            gBoss ? rs32(gBoss + O_BOSS_1AC) : -1,
            hand,
            hand ? rs32(hand + O_SIDE) : 0,
            hand ? rs32(hand + O_ACTION) : -1,
            hand ? rs32(hand + O_TIMER) : -1,
            hand ? rfloat(hand + O_POS_X) : 0.0f,
            hand ? rfloat(hand + O_POS_Y) : 0.0f,
            hand ? rfloat(hand + O_POS_Z) : 0.0f,
            hand ? rfloat(hand + O_FORWARD_VEL) : 0.0f,
            hand ? rs32(hand + O_MOVE_YAW) : 0,
            hand ? rs32(hand + O_FACE_YAW) : 0,
            hand ? R32(hand + O_MOVE_FLAGS) : 0);
}

static void mark_phase(enum ProbePhase next, const char *reason) {
    fprintf(stderr,
            "GATE_PHASE,timer=%u,old=%d,new=%d,reason=%s,"
            "mario=(%.6f,%.6f,%.6f)\n",
            R32(A_GLOBAL_TIMER), (int) gPhase, (int) next, reason,
            rfloat(A_MARIO_STATES + 0x3c),
            rfloat(A_MARIO_STATES + 0x40),
            rfloat(A_MARIO_STATES + 0x44));
    gPhase = next;
}

EXPORT void CALL GetKeys(int control, BUTTONS *keys) {
    uint16_t area = R16(A_CURR_AREA);
    uint32_t timer;
    uint32_t found;
    float marioZ;

    if (area != 3) {
        FixtureGetKeys(control, keys);
        return;
    }

    memset(keys, 0, sizeof(*keys));
    if (control != 0) return;
    ++gPoll;
    ++gArea3Polls;

    find_eyerok_objects();
    timer = R32(A_GLOBAL_TIMER);
    marioZ = rfloat(A_MARIO_STATES + 0x44);

    if (gArea3BoundaryTimer == 0 && gBoss != 0
        && gHands[0] != 0 && gHands[1] != 0) {
        gArea3BoundaryTimer = timer;
        gFarthestHandZ = -1000000.0f;
        print_gate_header();
        fprintf(stderr,
                "GATE_BOUNDARY,timer=%u,area=3,boss=%08x,hand0=%08x,"
                "hand1=%08x,postBoundaryMemoryWrites=zero,"
                "postBoundaryButtons=stick-and-dialog-B-only,"
                "selectionX=%.3f,kiteX=%.3f,kiteZ=%.3f,smashSide=%d,"
                "smashAngleMagnitude=%d,smashTargetRadius=%.3f\n",
                timer, gBoss, gHands[0], gHands[1],
                (double) SELECTION_X, (double) KITE_X, (double) KITE_Z,
                SMASH_SIDE_SIGN, SMASH_ANGLE_MAG,
                (double) SMASH_TARGET_RADIUS);
    }

    switch (gPhase) {
        case PHASE_SEEK_WAKE:
            /* The two sleeping meshes close the center line near Z=-3118.
               Walk around their positive-X edge, then turn inward far enough
               behind them to enter the boss's strict 500-unit wake radius. */
            if (marioZ > -3240.0f) {
                steer_world_gate(keys, 650.0f, -3260.0f);
            } else {
                steer_world_gate(keys, 300.0f, -3500.0f);
            }
            if (gBoss != 0 && rs32(gBoss + O_ACTION) != 0) {
                gSawWake = 1;
                mark_phase(PHASE_RETURN_TO_STRIP, "boss-left-sleep");
            }
            break;
        case PHASE_RETURN_TO_STRIP:
            steer_world_gate(keys, SELECTION_X, -2994.0f);
            if (marioZ >= -3000.0f && marioZ < -2993.0f) {
                gSawStripBeforeFight =
                    gBoss != 0 && rs32(gBoss + O_ACTION) != 3;
                mark_phase(PHASE_WAIT_FOR_TARGET, "inside-target-strip");
            }
            break;
        case PHASE_WAIT_FOR_TARGET:
            steer_world_gate(keys, SELECTION_X, -2994.0f);
            /* The mandatory intro is an NPC dialog.  B is an ordinary
               source-supported page/close button and supplies no A edge. */
            if (gBoss != 0 && rs32(gBoss + O_ACTION) == 2
                && timer % 20 == 0) {
                keys->B_BUTTON = 1;
            }
            found = find_hand_with_action(HAND_TARGET_MARIO);
            if (found != 0) {
                gTargetHand = found;
                gTargetSelectionTimer = timer;
                gSelectionMarioZ = marioZ;
                gSelectionHandZ = rfloat(found + O_POS_Z);
                gSawDeterministicTarget =
                    marioZ >= -3293.0f && marioZ < -2993.0f;
                mark_phase(PHASE_KITE_TARGET, "retail-target-selected");
            }
            break;
        case PHASE_KITE_TARGET:
            steer_world_gate(keys, KITE_X, KITE_Z);
            if (marioZ >= -2993.0f && gTargetHand != 0
                && rs32(gTargetHand + O_ACTION) == HAND_TARGET_MARIO
                && rfloat(gTargetHand + O_FORWARD_VEL) > 0.0f) {
                gSawReleasedChase = 1;
            }
            if (gTargetHand != 0
                && rs32(gTargetHand + O_ACTION) == HAND_SMASH) {
                gSawSmash = 1;
                mark_phase(PHASE_SET_SMASH_SIDE, "target-became-smash");
            }
            break;
        case PHASE_SET_SMASH_SIDE:
            steer_to_smash_side(keys, gTargetHand);
            if (gTargetHand != 0
                && rs32(gTargetHand + O_ACTION) == HAND_FIST_SWEEP) {
                gSawSweep = 1;
                gSweepTimer = timer;
                mark_phase(PHASE_OBSERVE_SWEEP, "smash-became-sweep");
            } else if (gTargetHand != 0
                       && rs32(gTargetHand + O_ACTION) == 5) {
                mark_phase(PHASE_DONE, "smash-retreated-without-sweep");
            }
            break;
        case PHASE_OBSERVE_SWEEP:
            memset(keys, 0, sizeof(*keys));
            if (timer > gSweepTimer + 80) {
                mark_phase(PHASE_DONE, "sweep-observation-complete");
            }
            break;
        case PHASE_DONE:
            memset(keys, 0, sizeof(*keys));
            break;
    }

    if (keys->A_BUTTON) ++gAInputPolls;
    if (keys->B_BUTTON) ++gBInputPolls;
    if (gArea3BoundaryTimer != 0 && timer != gLastGateTimer) {
        gLastGateTimer = timer;
        log_gate_frame(timer);
    }
}

EXPORT void CALL RomClosed(void) {
    fprintf(stderr,
            "GATE_VERDICT,boundaryTimer=%u,area3Polls=%u,sawWake=%u,"
            "sawStripBeforeFight=%u,sawDeterministicTarget=%u,"
            "selectionTimer=%u,selectionMarioZ=%.6f,selectionHandZ=%.6f,"
            "sawReleasedChase=%u,sawSmash=%u,sawSweep=%u,sweepTimer=%u,"
            "farthestHandZ=%.6f,aInputPolls=%u,bInputPolls=%u,"
            "handFloorFrames=%u,handPlatformFrames=%u,"
            "postBoundaryMemoryWrites=0\n",
            gArea3BoundaryTimer, gArea3Polls, gSawWake,
            gSawStripBeforeFight, gSawDeterministicTarget,
            gTargetSelectionTimer, gSelectionMarioZ, gSelectionHandZ,
            gSawReleasedChase, gSawSmash, gSawSweep, gSweepTimer,
            gFarthestHandZ, gAInputPolls, gBInputPolls,
            gHandFloorFrames, gHandPlatformFrames);
    FixtureRomClosed();
}
