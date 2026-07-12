#define EYEROK_HOME_Y (-1534)
#define EYEROK_DIRECT_POSITION_Y_MAX (-934)
#define AREA3_STATIC_Y_MAX 896
#define HAND_COLLISION_TOP_MAX 507
#define UPWARD_TRAVEL_MAX 300
#define FIRST_HAND_Y_MAX 1196
#define SECOND_HAND_SUPPORT_MAX 1703
#define SECOND_HAND_Y_MAX 2003
#define HEIGHT_MIN (-12000)

#define ATTACKED_ASCENT_BUDGET 98
#define DIE_ASCENT_BUDGET 288
#define DOUBLE_POUND_ASCENT_BUDGET 285
#define RUNAWAY_DELTA 100

enum EyerokHandAction {
    EYEROK_HAND_SLEEP = 0,
    EYEROK_HAND_IDLE = 1,
    EYEROK_HAND_OPEN = 2,
    EYEROK_HAND_SHOW_EYE = 3,
    EYEROK_HAND_CLOSE = 4,
    EYEROK_HAND_RETREAT = 5,
    EYEROK_HAND_TARGET_MARIO = 6,
    EYEROK_HAND_SMASH = 7,
    EYEROK_HAND_FIST_PUSH = 8,
    EYEROK_HAND_FIST_SWEEP = 9,
    EYEROK_HAND_BEGIN_DOUBLE_POUND = 10,
    EYEROK_HAND_DOUBLE_POUND = 11,
    EYEROK_HAND_ATTACKED = 12,
    EYEROK_HAND_RECOVER = 13,
    EYEROK_HAND_BECOME_ACTIVE = 14,
    EYEROK_HAND_DIE = 15
};

enum EyerokSurfaceRank {
    EYEROK_FIRST_HAND = 0,
    EYEROK_SECOND_HAND = 1
};

enum EyerokVerticalMode {
    EYEROK_CONTROLLED = 0,
    EYEROK_BALLISTIC = 1,
    EYEROK_RUNAWAY = 2,
    EYEROK_DELETED = 3
};

struct EyerokVerticalState {
    int rank;
    int action;
    int mode;
    int y;
    int ascentBudget;
    int gravity;
    int grounded;
};

int eyerok_support_ceiling(int rank) {
    if (rank == EYEROK_FIRST_HAND) {
        return AREA3_STATIC_Y_MAX;
    }
    return SECOND_HAND_SUPPORT_MAX;
}

int eyerok_height_ceiling(int rank) {
    if (rank == EYEROK_FIRST_HAND) {
        return FIRST_HAND_Y_MAX;
    }
    return SECOND_HAND_Y_MAX;
}

int eyerok_clamp_height(int y, int ceiling) {
    if (y < HEIGHT_MIN) {
        return HEIGHT_MIN;
    }
    if (y > ceiling) {
        return ceiling;
    }
    return y;
}

void eyerok_vertical_init(struct EyerokVerticalState *state, int rank) {
    state->rank = rank;
    state->action = EYEROK_HAND_SLEEP;
    state->mode = EYEROK_CONTROLLED;
    state->y = EYEROK_HOME_Y;
    state->ascentBudget = 0;
    state->gravity = 0;
    state->grounded = 1;
}

void eyerok_controlled_position(
    struct EyerokVerticalState *state,
    int action,
    int requestedY
) {
    state->action = action;
    state->mode = EYEROK_CONTROLLED;
    state->y = eyerok_clamp_height(requestedY, EYEROK_DIRECT_POSITION_Y_MAX);
    state->ascentBudget = 0;
    state->grounded = 0;
}

void eyerok_land(struct EyerokVerticalState *state, int floorY) {
    state->mode = EYEROK_CONTROLLED;
    state->y = eyerok_clamp_height(floorY, eyerok_support_ceiling(state->rank));
    state->ascentBudget = 0;
    state->grounded = 1;
}

int eyerok_action_ascent_budget(int action) {
    if (action == EYEROK_HAND_ATTACKED) {
        return ATTACKED_ASCENT_BUDGET;
    }
    if (action == EYEROK_HAND_DIE) {
        return DIE_ASCENT_BUDGET;
    }
    if (action == EYEROK_HAND_DOUBLE_POUND) {
        return DOUBLE_POUND_ASCENT_BUDGET;
    }
    return 0;
}

int eyerok_start_authentic_impulse(
    struct EyerokVerticalState *state,
    int action
) {
    int budget = eyerok_action_ascent_budget(action);

    state->action = action;

    if (action == EYEROK_HAND_DOUBLE_POUND
        && state->grounded
        && state->gravity == 0) {
        state->mode = EYEROK_RUNAWAY;
        state->ascentBudget = 0;
        state->grounded = 0;
        return 0;
    }

    if (budget == 0) {
        return 0;
    }
    if (action == EYEROK_HAND_DOUBLE_POUND && state->gravity > -15) {
        return 0;
    }

    if (action == EYEROK_HAND_DOUBLE_POUND) {
        state->gravity = -15;
    } else {
        state->gravity = -4;
    }
    state->mode = EYEROK_BALLISTIC;
    state->ascentBudget = budget;
    state->grounded = 0;
    return 1;
}

void eyerok_safe_rise(struct EyerokVerticalState *state, int delta) {
    if (state->mode == EYEROK_BALLISTIC
        && delta >= 0
        && delta <= state->ascentBudget) {
        state->y = state->y + delta;
        state->ascentBudget = state->ascentBudget - delta;
    }
}

void eyerok_nonrising_frame(struct EyerokVerticalState *state, int nextY) {
    if (nextY >= HEIGHT_MIN && nextY <= state->y) {
        state->y = nextY;
    }
}

void eyerok_partial_update(struct EyerokVerticalState *state, int nextAction) {
    state->action = nextAction;
}

void eyerok_delete(struct EyerokVerticalState *state) {
    state->mode = EYEROK_DELETED;
    state->ascentBudget = 0;
    state->grounded = 0;
}

void eyerok_runaway_frame(struct EyerokVerticalState *state) {
    if (state->mode == EYEROK_RUNAWAY) {
        state->y = state->y + RUNAWAY_DELTA;
    }
}

int eyerok_safe_envelope(const struct EyerokVerticalState *state) {
    int ceiling = eyerok_height_ceiling(state->rank);

    return state->mode != EYEROK_RUNAWAY
        && state->ascentBudget >= 0
        && state->ascentBudget <= UPWARD_TRAVEL_MAX
        && state->y <= ceiling
        && state->y + state->ascentBudget <= ceiling;
}
