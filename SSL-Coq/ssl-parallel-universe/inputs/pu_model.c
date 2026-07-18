#define SSL_AREA_2 2
#define SSL_AREA2_MIN (-8192)
#define SSL_AREA2_MAX 8191
#define FIRST_PARALLEL_UNIVERSE 32768
#define MAX_NORMAL_STEP 4096

struct PUState {
    int area;
    int x;
    int z;
};

int pu_abs(int value) {
    if (value < 0) {
        return -value;
    }
    return value;
}

int clamp_area2_coord(int value) {
    if (value < SSL_AREA2_MIN) {
        return SSL_AREA2_MIN;
    }
    if (value > SSL_AREA2_MAX) {
        return SSL_AREA2_MAX;
    }
    return value;
}

int clamp_normal_step(int delta) {
    if (delta < -MAX_NORMAL_STEP) {
        return -MAX_NORMAL_STEP;
    }
    if (delta > MAX_NORMAL_STEP) {
        return MAX_NORMAL_STEP;
    }
    return delta;
}

int is_parallel_universe_coord(int value) {
    return pu_abs(value) >= FIRST_PARALLEL_UNIVERSE;
}

int in_parallel_universe(struct PUState *state) {
    if (is_parallel_universe_coord(state->x)) {
        return 1;
    }
    if (is_parallel_universe_coord(state->z)) {
        return 1;
    }
    return 0;
}

void ssl_area2_normal_step(struct PUState *state, int dx, int dz) {
    int nextX;
    int nextZ;

    if (state->area != SSL_AREA_2) {
        return;
    }

    nextX = state->x + clamp_normal_step(dx);
    nextZ = state->z + clamp_normal_step(dz);

    state->x = clamp_area2_coord(nextX);
    state->z = clamp_area2_coord(nextZ);
}

int ssl_area2_step_enters_parallel_universe(
    struct PUState *state,
    int dx,
    int dz
) {
    ssl_area2_normal_step(state, dx, dz);
    return in_parallel_universe(state);
}
