/* Keep the checked controller-only four-pillar route intact. This wrapper
 * stages Mario's positions once, after the game's own top starts spinning. */
#define SEARCH_MODE 12
#define GetKeys clean_get_keys
#define PluginStartup clean_plugin_startup
#define RomClosed clean_rom_closed
#include "../jp-clean-gap-search/jp_clean_gap_search_probe.c"
#undef RomClosed
#undef PluginStartup
#undef GetKeys

#ifndef DEMO_INSTALL_TIMER
#define DEMO_INSTALL_TIMER 131
#endif
#ifndef DEMO_LOW_X
#define DEMO_LOW_X -2200.0f
#endif
#ifndef DEMO_LOW_Y
#define DEMO_LOW_Y 768.0f
#endif
#ifndef DEMO_LOW_Z
#define DEMO_LOW_Z -1024.0f
#endif
#ifndef DEMO_MOVEMENT_X
#define DEMO_MOVEMENT_X DEMO_LOW_X
#endif
#ifndef DEMO_DISPLAY_X
#define DEMO_DISPLAY_X DEMO_LOW_X
#endif
#ifndef DEMO_DISPLAY_Y
#define DEMO_DISPLAY_Y 1938.8648681640625f
#endif
#ifndef DEMO_DISPLAY_Z
#define DEMO_DISPLAY_Z DEMO_LOW_Z
#endif

enum {
    A_APPLY_PLATFORM = 0x802c83f0,
    A_FIRST_GEOMETRY_FLOOR_RETURN = 0x802538a0,
    A_RETRY_GEOMETRY_FLOOR_RETURN = 0x802538e4,
    DEMO_SURFACE_OWNER = 0x2c,
    DEMO_STEERING_FRAMES = 60,
};

static void (*write_word)(unsigned int, unsigned int);
static int setup_done;
static int saw_warp;
static int saw_top_retire;
static uint32_t demo_top;
static uint32_t demo_warp;
static uint32_t last_pillars;
static uint32_t apply_return_pc;
static uint32_t area2_start;
static uint32_t last_timer;

static void write_position(uint32_t address, float x, float y, float z) {
    float values[] = {x, y, z};
    for (size_t axis = 0; axis < sizeof(values) / sizeof(values[0]); axis++) {
        uint32_t bits;
        memcpy(&bits, &values[axis], sizeof(bits));
        write_word(address + 4 * axis, bits);
    }
}

static void log_state(const char *tag) {
    uint32_t mario = R32(A_MARIO_OBJECT);
    uint32_t floor = R32(A_MARIO_STATES + M_FLOOR);
    fprintf(stderr,
            "%s,timer=%u,poll=%llu,area=%u,pillars=%u,top=%08x,"
            "topAction=%u,topTimer=%u,topActive=%u,platform=%08x,"
            "action=%08x,used=%08x,warp=%08x,held=%08x,depth=%.9g,"
            "floor=%08x,owner=%08x,floorY=%.9g,"
            "state=(%.9g,%.9g,%.9g),collision=(%.9g,%.9g,%.9g),"
            "display=(%.9g,%.9g,%.9g)\n",
            tag, R32(A_GLOBAL_TIMER), (unsigned long long)gPoll,
            R16(A_CURR_AREA), R32(demo_top + O_PYRAMID_PILLARS_TOUCHED),
            demo_top, R32(demo_top + O_ACTION), R32(demo_top + O_TIMER),
            R16(demo_top + O_ACTIVE_FLAGS), R32(A_MARIO_PLATFORM),
            R32(A_MARIO_STATES + M_ACTION), R32(A_MARIO_STATES + M_USED_OBJ),
            demo_warp, R32(A_MARIO_STATES + M_HELD_OBJ),
            rfloat(A_MARIO_STATES + M_QUICKSAND_DEPTH), floor,
            floor == 0 ? 0 : R32(floor + DEMO_SURFACE_OWNER),
            rfloat(A_MARIO_STATES + M_FLOOR_HEIGHT),
            rfloat(A_MARIO_STATES + M_POS_X), rfloat(A_MARIO_STATES + M_POS_Y),
            rfloat(A_MARIO_STATES + M_POS_Z), rfloat(mario + O_POS_X),
            rfloat(mario + O_POS_Y), rfloat(mario + O_POS_Z),
            rfloat(mario + GFX_POS_X), rfloat(mario + GFX_POS_Y),
            rfloat(mario + GFX_POS_Z));
}

static void demo_debugger_update(unsigned int pc) {
    if (pc == A_FIRST_GEOMETRY_FLOOR_RETURN || pc == A_RETRY_GEOMETRY_FLOOR_RETURN) {
        log_state(pc == A_FIRST_GEOMETRY_FLOOR_RETURN ? "DEMO_FIRST_FLOOR" : "DEMO_RETRY_FLOOR");
        DBreakpointCommand(M64P_BKP_CMD_REMOVE_ADDR, pc, NULL);
    } else if (pc == A_APPLY_PLATFORM) {
        if (R16(A_CURR_AREA) == 2) {
            const uint64_t *registers = DGetCPUDataPtr(M64P_CPU_REG_REG);
            log_state("DEMO_APPLY_ENTRY");
            DBreakpointCommand(M64P_BKP_CMD_REMOVE_ADDR, pc, NULL);
            apply_return_pc = registers ? (uint32_t)registers[31] : 0;
            if (!apply_return_pc || !add_exec_breakpoint(apply_return_pc)) {
                fprintf(stderr, "DEMO_ERROR,stage=apply-return-breakpoint\n");
            }
        }
    } else if (pc == apply_return_pc) {
        log_state("DEMO_APPLY_RETURN");
        DBreakpointCommand(M64P_BKP_CMD_REMOVE_ADDR, pc, NULL);
    } else {
        debugger_update_callback(pc);
        return;
    }
    resume_from_breakpoint();
}

EXPORT m64p_error CALL PluginStartup(
    m64p_dynlib_handle core, void *context,
    void (*debug_callback)(void *, int, const char *)) {
    m64p_error result = clean_plugin_startup(core, context, debug_callback);
    if (result != M64ERR_SUCCESS) return result;
    write_word = dlsym(core, "DebugMemWrite32");
    return write_word ? M64ERR_SUCCESS : M64ERR_INCOMPATIBLE;
}

EXPORT void CALL RomClosed(void) {
    clean_rom_closed();
    fprintf(stderr, "DEMO_RESULT,setup=%d,warp=%d,retired=%d,area2=%d\n",
            setup_done, saw_warp, saw_top_retire, area2_start != 0);
}

EXPORT void CALL GetKeys(int control, BUTTONS *keys) {
    uint16_t area;
    uint32_t timer;
    uint32_t mario;

    clean_get_keys(control, keys);
    if (control != 0 || !gTop || !gUpperWarp) return;
    if (!demo_top) {
        demo_top = gTop;
        demo_warp = gUpperWarp;
    }
    area = R16(A_CURR_AREA);
    timer = R32(A_GLOBAL_TIMER);
    mario = R32(A_MARIO_OBJECT);

    if (area == 1 && last_pillars < 4
        && R32(demo_top + O_PYRAMID_PILLARS_TOUCHED) != last_pillars) {
        last_pillars = R32(demo_top + O_PYRAMID_PILLARS_TOUCHED);
        log_state("DEMO_PILLAR");
    }

    /* Release the stick after all four detectors have counted. The
     * stock route otherwise picks up the west jumping box before timer 131. */
    if (area == 1 && last_pillars == 4) {
        memset(keys, 0, sizeof(*keys));
        if (!setup_done && R32(demo_top + O_ACTION) == 1
            && R32(demo_top + O_TIMER) == DEMO_INSTALL_TIMER) {
            log_state("DEMO_BEFORE_SETUP");
            if (R32(A_MARIO_PLATFORM) != 0 || R32(A_MARIO_STATES + M_HELD_OBJ) != 0) {
                fprintf(stderr, "DEMO_ERROR,stage=preexisting-owner-or-held-object\n");
                return;
            }
            if (DSetCallbacks(debugger_init_callback, demo_debugger_update,
                              debugger_vi_callback) != M64ERR_SUCCESS
                || !add_exec_breakpoint(A_APPLY_PLATFORM)) {
                fprintf(stderr, "DEMO_ERROR,stage=apply-entry-breakpoint\n");
                return;
            }
#ifdef DEMO_OBSERVE_RETRY
            if (R32(A_FIRST_GEOMETRY_FLOOR_RETURN - 8) != 0x0c0e0640
                || R32(A_RETRY_GEOMETRY_FLOOR_RETURN - 8) != 0x0c0e0640
                || !add_exec_breakpoint(A_FIRST_GEOMETRY_FLOOR_RETURN)
                || !add_exec_breakpoint(A_RETRY_GEOMETRY_FLOOR_RETURN)) {
                fprintf(stderr, "DEMO_ERROR,stage=geometry-floor-breakpoint\n");
                return;
            }
#endif
            write_position(A_MARIO_STATES + M_POS_X, DEMO_MOVEMENT_X, DEMO_LOW_Y, DEMO_LOW_Z);
            write_position(mario + O_POS_X, DEMO_LOW_X, DEMO_LOW_Y, DEMO_LOW_Z);
            write_position(mario + GFX_POS_X, DEMO_DISPLAY_X, DEMO_DISPLAY_Y, DEMO_DISPLAY_Z);
            setup_done = 1;
            log_state("DEMO_SETUP");
        }
    }

    if (area == 1 && setup_done && timer != last_timer) {
        if (!saw_warp && R32(A_MARIO_STATES + M_ACTION) == ACT_DISAPPEARED
            && R32(A_MARIO_STATES + M_USED_OBJ) == demo_warp) {
            saw_warp = 1;
            log_state("DEMO_WARP_ACCEPTED");
        }
        if (!saw_top_retire && R16(demo_top + O_ACTIVE_FLAGS) == 0) {
            saw_top_retire = 1;
            log_state("DEMO_TOP_RETIRED");
        }
        log_state("DEMO_AREA1");
    }

    if (area == 2) {
        if (!area2_start) {
            area2_start = timer;
            log_state("DEMO_ARRIVAL");
        }
        if (timer - area2_start < DEMO_STEERING_FRAMES) {
            keys->X_AXIS = -127;
            keys->Y_AXIS = -96;
        }
        if (timer != last_timer) {
            uint16_t input = R16(A_MARIO_STATES + M_INPUT);
            if (input & INPUT_A_PRESSED) gAPressedFrames++;
            if (input & INPUT_A_DOWN) gADownFrames++;
            if (keys->A_BUTTON) gControllerAFrames++;
            log_state("DEMO_AREA2");
        }
    }
    last_timer = timer;
}
