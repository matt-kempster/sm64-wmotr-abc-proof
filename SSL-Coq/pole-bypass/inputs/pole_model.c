#define FIFTH_FLOOR_Y 3200
#define POLE_PARAMETER 92
#define POLE_HEIGHT (POLE_PARAMETER * 10)
#define POLE_TOP_OFFSET 100
#define POLE_TOP_Y (FIFTH_FLOOR_Y + POLE_HEIGHT - POLE_TOP_OFFSET)

#define SIXTH_FLOOR_Y 3942
#define SIXTH_FLOOR_HOLE_RADIUS 101
#define POLE_PUSH_RADIUS 70

#define SOFT_BONK_SPEED 2
#define POLE_JUMP_INITIAL_SPEED 24
#define POLE_JUMP_FRAME_SPEED_LOWER_BOUND 22
#define POLE_JUMP_Y_VELOCITY 62
#define NORMAL_GRAVITY 4

enum PoleRouteMode {
    POLE_ROUTE_HOLDING = 0,
    POLE_ROUTE_TOP = 1,
    POLE_ROUTE_SOFT_BONK = 2,
    POLE_ROUTE_JUMP = 3,
    POLE_ROUTE_BELOW_RING = 4,
    POLE_ROUTE_SIXTH_FLOOR = 5
};

struct PoleRouteState {
    int mode;
    int radialDistance;
    int y;
    int verticalVelocity;
    int forwardSpeed;
    int aPresses;
};

void pole_route_init(struct PoleRouteState *state) {
    state->mode = POLE_ROUTE_HOLDING;
    state->radialDistance = 0;
    state->y = POLE_TOP_Y;
    state->verticalVelocity = 0;
    state->forwardSpeed = 0;
    state->aPresses = 0;
}

void pole_route_input(
    struct PoleRouteState *state,
    int aPressed,
    int zPressed,
    int climbToTop
) {
    if (aPressed) {
        state->aPresses = state->aPresses + 1;
    }

    if (state->mode == POLE_ROUTE_HOLDING) {
        if (aPressed) {
            state->mode = POLE_ROUTE_JUMP;
            state->verticalVelocity = POLE_JUMP_Y_VELOCITY;
            state->forwardSpeed = POLE_JUMP_FRAME_SPEED_LOWER_BOUND;
        } else if (zPressed) {
            state->mode = POLE_ROUTE_SOFT_BONK;
            state->verticalVelocity = 0;
            state->forwardSpeed = SOFT_BONK_SPEED;
        } else if (climbToTop) {
            state->mode = POLE_ROUTE_TOP;
        }
    } else if (state->mode == POLE_ROUTE_TOP) {
        if (aPressed) {
            state->mode = POLE_ROUTE_JUMP;
            state->verticalVelocity = POLE_JUMP_Y_VELOCITY;
            state->forwardSpeed = POLE_JUMP_FRAME_SPEED_LOWER_BOUND;
        } else if (zPressed) {
            state->mode = POLE_ROUTE_HOLDING;
        }
    }
}

int conservative_pole_push(int radialDistance) {
    if (radialDistance < POLE_PUSH_RADIUS) {
        return POLE_PUSH_RADIUS;
    }
    return radialDistance;
}

void pole_route_air_frame(struct PoleRouteState *state) {
    if (state->mode == POLE_ROUTE_SOFT_BONK) {
        state->radialDistance = conservative_pole_push(state->radialDistance);
        state->radialDistance = state->radialDistance + state->forwardSpeed;
        state->y = state->y + state->verticalVelocity;
        state->verticalVelocity = state->verticalVelocity - NORMAL_GRAVITY;

        if (state->y < SIXTH_FLOOR_Y) {
            state->mode = POLE_ROUTE_BELOW_RING;
        } else if (state->radialDistance >= SIXTH_FLOOR_HOLE_RADIUS) {
            state->mode = POLE_ROUTE_SIXTH_FLOOR;
        }
    } else if (state->mode == POLE_ROUTE_JUMP) {
        state->radialDistance = state->radialDistance + state->forwardSpeed;
        state->y = state->y + state->verticalVelocity;
        state->verticalVelocity = state->verticalVelocity - NORMAL_GRAVITY;

        if (state->radialDistance >= SIXTH_FLOOR_HOLE_RADIUS
            && state->y >= SIXTH_FLOOR_Y) {
            state->mode = POLE_ROUTE_SIXTH_FLOOR;
        }
    }
}

int soft_bonk_misses_sixth_floor(void) {
    struct PoleRouteState state;
    int frames = 0;

    pole_route_init(&state);
    pole_route_input(&state, 0, 1, 0);

    while (state.mode == POLE_ROUTE_SOFT_BONK && frames < 8) {
        pole_route_air_frame(&state);
        frames = frames + 1;
    }

    return state.mode == POLE_ROUTE_BELOW_RING
        && state.radialDistance < SIXTH_FLOOR_HOLE_RADIUS;
}

int one_a_jump_clears_sixth_floor_hole(void) {
    struct PoleRouteState state;
    int frames = 0;

    pole_route_init(&state);
    pole_route_input(&state, 0, 0, 1);
    pole_route_input(&state, 1, 0, 0);

    while (state.mode == POLE_ROUTE_JUMP && frames < 5) {
        pole_route_air_frame(&state);
        frames = frames + 1;
    }

    return state.mode == POLE_ROUTE_SIXTH_FLOOR
        && state.aPresses == 1;
}
