#define JP_FULL_ROUTE_GET_KEYS Rank11BaseGetKeys
#define JP_FULL_ROUTE_ROM_CLOSED Rank11BaseRomClosed
#include "../jp-full-route/jp_full_route_probe.c"
#undef JP_FULL_ROUTE_GET_KEYS
#undef JP_FULL_ROUTE_ROM_CLOSED

/* A conditional retail timing diagnostic, NOT a clean entry or TAS movie.
 * The inherited fixture loads Area 2.  Exactly once, this wrapper stages a
 * zero-speed holding-pole state on the real second pole.  It then uses only
 * controller input: climb into a handstand, wait, descend and press Z either
 * on the last return-animation frame (mode 0) or after holding (mode 1).
 * Every additional fixture write is printed; neither tables nor code change.
 */
#ifndef RANK11_RELEASE_MODE
#define RANK11_RELEASE_MODE 0
#endif

enum {
    R11_HOLDING = 0x08100340,
    R11_TOP_TRANSITION = 0x00100344,
    R11_TOP = 0x00100345,
    R11_SOFT_BONK = 0x010208b6,
    R11_ANIM_ID = 0x38,
    R11_ANIM_FRAME = 0x40,
    R11_POLE_POS = 0x110,
};

static uint32_t gR11Pole, gR11Start, gR11LastTimer = UINT32_MAX;
static unsigned gR11Writes, gR11TopPolls, gR11Phase, gR11Polls;
static int gR11Staged, gR11ReleaseSent, gR11SawRelease;
static float gR11MaxY, gR11MinZAboveRing = 1000000.0f;

static void rank11_stage_word(uint32_t address, uint32_t value) {
    W32(address, value);
    gR11Writes++;
    fprintf(stderr, "R11_FIXTURE_WRITE,address=%08x,value=%08x\n", address, value);
}

static uint32_t rank11_find_pole(void) {
    unsigned i;
    for (i = 0; i < OBJECT_COUNT; i++) {
        uint32_t p = pool_pointer(i);
        if (R16(p + O_ACTIVE_FLAGS) != 0
            && rfloat(p + O_POS_X) == 0.0f
            && rfloat(p + O_POS_Y) == 3200.0f
            && rfloat(p + O_POS_Z) == 1331.0f) return p;
    }
    return 0;
}

static void rank11_stage(uint32_t mario) {
    static const unsigned position_offsets[] = {M_POS_X, M_POS_Y, M_POS_Z};
    static const unsigned object_offsets[] = {O_POS_X, O_POS_Y, O_POS_Z};
    static const unsigned graphics_offsets[] = {GFX_POS_X, GFX_POS_Y, GFX_POS_Z};
    static const float position[] = {0.0f, 4020.0f, 1331.0f};
    unsigned i;
    rank11_stage_word(A_MARIO_STATES + M_ACTION, R11_HOLDING);
    rank11_stage_word(A_MARIO_STATES + 0x10, R11_HOLDING);
    rank11_stage_word(A_MARIO_STATES + 0x18, 0);
    rank11_stage_word(A_MARIO_STATES + M_ACTION_ARG, 0);
    rank11_stage_word(A_MARIO_STATES + 0x2c,
                     R32(A_MARIO_STATES + 0x2c) & 0xffff0000u);
    for (i = 0; i < 3; i++) {
        rank11_stage_word(A_MARIO_STATES + position_offsets[i], fbits(position[i]));
        rank11_stage_word(mario + object_offsets[i], fbits(position[i]));
        rank11_stage_word(mario + graphics_offsets[i], fbits(position[i]));
        rank11_stage_word(A_MARIO_STATES + 0x48 + 4 * i, 0);
    }
    rank11_stage_word(A_MARIO_STATES + 0x54, 0);
    rank11_stage_word(A_MARIO_STATES + 0x78, gR11Pole);
    rank11_stage_word(A_MARIO_STATES + M_USED_OBJ, gR11Pole);
    rank11_stage_word(mario + 0x10c, 0);
    rank11_stage_word(mario + R11_POLE_POS, fbits(820.0f));
    rank11_stage_word(A_MARIO_PLATFORM, 0);
    gR11Start = R32(A_GLOBAL_TIMER);
    gR11Staged = 1;
    fprintf(stderr, "R11_STAGE,timer=%u,mode=%d,pole=%08x,behavior=%08x,"
            "mario=%08x,fixtureWrites=%u,pos=(0,4020,1331),speed=0\n",
            gR11Start, RANK11_RELEASE_MODE, gR11Pole,
            R32(gR11Pole + O_BEHAVIOR), mario, gR11Writes);
}

EXPORT void CALL GetKeys(int control, BUTTONS *keys) {
    uint32_t mario, action, timer, floor, owner = 0;
    int animation, frame;
    float y, z;
    Rank11BaseGetKeys(control, keys);
    if (control != 0 || !gBoundaryInstalled || R16(A_CURR_AREA) != 2) return;
    mario = R32(A_MARIO_OBJECT);
    if (mario == 0) return;
    if (!gR11Staged) {
        gR11Pole = rank11_find_pole();
        if (gR11Pole == 0) return;
        rank11_stage(mario);
    }
    memset(keys, 0, sizeof(*keys));
    action = R32(A_MARIO_STATES + M_ACTION);
    animation = (int16_t) R16(mario + R11_ANIM_ID);
    frame = (int16_t) R16(mario + R11_ANIM_FRAME);
    if (gR11Phase == 0) {
        keys->Y_AXIS = 127;
        if (action == R11_TOP) gR11Phase = 1;
    }
    if (gR11Phase == 1) {
        keys->Y_AXIS = 0;
        /* Also check that a Z edge at the stable handstand does not release. */
        keys->Z_TRIG = (gR11TopPolls == 2);
        if (++gR11TopPolls >= 60) gR11Phase = 2;
    }
    if (gR11Phase == 2 && !gR11ReleaseSent) {
        keys->Y_AXIS = -127;
        /* Neutralize the last return frame in both modes so the delayed
           comparison cannot add a holding-pole spin before its Z press. */
        if (action == R11_TOP_TRANSITION && animation == 12 && frame == 0)
            keys->Y_AXIS = 0;
        if ((RANK11_RELEASE_MODE == 0 && action == R11_TOP_TRANSITION
             && animation == 12 && frame == 0)
            || (RANK11_RELEASE_MODE == 1 && action == R11_HOLDING)) {
            keys->Z_TRIG = 1;
            keys->Y_AXIS = 0;
            gR11ReleaseSent = 1;
            fprintf(stderr, "R11_Z_REQUEST,timer=%u,action=%08x,anim=%d,"
                    "frame=%d,y=%.9g,vy=%.9g\n", R32(A_GLOBAL_TIMER),
                    action, animation, frame, rfloat(A_MARIO_STATES + M_POS_Y),
                    rfloat(A_MARIO_STATES + 0x4c));
        }
    }
    timer = R32(A_GLOBAL_TIMER);
    y = rfloat(A_MARIO_STATES + M_POS_Y);
    z = rfloat(A_MARIO_STATES + M_POS_Z);
    if (y > gR11MaxY) gR11MaxY = y;
    if (y >= 3942.0f && z < gR11MinZAboveRing) gR11MinZAboveRing = z;
    if (!gR11SawRelease && action == R11_SOFT_BONK) {
        gR11SawRelease = 1;
        fprintf(stderr, "R11_FIRST_BONK,timer=%u,pos=(%.9g,%.9g,%.9g),"
                "forwardVel=%.9g,vy=%.9g\n", timer,
                rfloat(A_MARIO_STATES + M_POS_X), y, z,
                rfloat(A_MARIO_STATES + 0x54), rfloat(A_MARIO_STATES + 0x4c));
    }
    if (timer == gR11LastTimer) return;
    gR11LastTimer = timer;
    gR11Polls++;
    floor = R32(A_MARIO_STATES + M_FLOOR);
    if (floor >= 0x80000000u && floor <= 0x807fffccu && !(floor & 3u))
        owner = R32(floor + SURFACE_OBJECT);
    if (gR11Polls <= 155)
        fprintf(stderr, "R11_FRAME,timer=%u,relative=%u,action=%08x,arg=%u,"
                "anim=%d,frame=%d,pos=(%.9g,%.9g,%.9g),vy=%.9g,"
                "forwardVel=%.9g,polePos=%.9g,floor=%08x,owner=%08x,"
                "platform=%08x,input=%04x,A=%u,Z=%u,stickY=%d\n", timer,
                timer - gR11Start, action, R32(A_MARIO_STATES + M_ACTION_ARG),
                animation, frame, rfloat(A_MARIO_STATES + M_POS_X), y, z,
                rfloat(A_MARIO_STATES + 0x4c), rfloat(A_MARIO_STATES + 0x54),
                rfloat(mario + R11_POLE_POS), floor, owner, R32(A_MARIO_PLATFORM),
                R16(A_MARIO_STATES + 2), (unsigned) keys->A_BUTTON,
                (unsigned) keys->Z_TRIG, (int) keys->Y_AXIS);
}

EXPORT void CALL RomClosed(void) {
    fprintf(stderr, "R11_RESULT,mode=%d,staged=%d,fixtureWrites=%u,"
            "topPolls=%u,releaseSent=%d,sawBonk=%d,maxY=%.9g,"
            "minZWhileYAtLeast3942=%.9g,aPressedFrames=%d,aDownFrames=%d,"
            "controllerAFrames=%d\n", RANK11_RELEASE_MODE, gR11Staged,
            gR11Writes, gR11TopPolls, gR11ReleaseSent, gR11SawRelease,
            gR11MaxY, gR11MinZAboveRing, gAPressedFrames, gADownFrames,
            gControllerAFrames);
    Rank11BaseRomClosed();
}
