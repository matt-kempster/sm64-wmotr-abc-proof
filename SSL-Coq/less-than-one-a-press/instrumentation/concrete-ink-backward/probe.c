/* Exact checkpoint observer for the conditional mechanics fixture.
 * The only setup writes are the existing pillar/three-position fixture.
 * Accepted return and disappearing-action entry are observation only. */
#define GetKeys LifecycleGetKeys
#define debugger_update_callback LifecycleDebuggerUpdate
#include "../jp-lifecycle/jp_lifecycle_probe.c"
#undef debugger_update_callback
#undef GetKeys

#ifndef INK_ACTUAL_Y
#define INK_ACTUAL_Y 768.0f
#endif
#ifndef INK_DISPLAY_WORD
#define INK_DISPLAY_WORD 0x44f25bad
#endif
enum { INK_HANDLER_CALL = 0x80250318, INK_HANDLER_RETURN = 0x80250320,
       INK_HANDLER = 0x8024dd68, INK_DISAPPEARED = 0x80257794 };
static unsigned inkPending, inkAccepted;

static void ink_snapshot(const char *stage) {
    uint32_t object = R32(A_MARIO_OBJECT), floor = R32(A_MARIO_STATES + M_FLOOR);
    unsigned i;
    fprintf(stderr, "BACKWARD_INK,stage=%s,timer=%u,area=%u,action=%08x,arg=%08x,used=%08x,upper=%08x,top=%08x,floor=%08x,owner=%08x,platform=%08x,positions=",
            stage, R32(A_GLOBAL_TIMER), R16(A_CURR_AREA), R32(A_MARIO_STATES + M_ACTION),
            R32(A_MARIO_STATES + M_ACTION_ARG), R32(A_MARIO_STATES + M_USED_OBJ), gUpperWarp, gTop,
            floor, floor ? R32(floor + SURFACE_OBJECT) : 0, R32(A_MARIO_PLATFORM));
    for (i = 0; i < 3; i++) fprintf(stderr, "%08x:", R32(A_MARIO_STATES + M_POS_X + 4*i));
    for (i = 0; i < 3; i++) fprintf(stderr, "%08x:", R32(object + O_POS_X + 4*i));
    for (i = 0; i < 3; i++) fprintf(stderr, "%08x%s", R32(object + GFX_POS_X + 4*i), i==2 ? "\n" : ":");
}

static void ink_debugger(unsigned int pc) {
    const uint64_t *regs = DGetCPUDataPtr(M64P_CPU_REG_REG);
    if (pc == INK_HANDLER_CALL && regs && (uint32_t)regs[25] == INK_HANDLER
            && (uint32_t)regs[6] == gUpperWarp) {
        inkPending = 1; ink_snapshot("handler-entry");
        resume_from_breakpoint(); return;
    }
    if (pc == INK_HANDLER_RETURN && inkPending) {
        inkPending = 0;
        if (regs && (uint32_t)regs[2] == 1) {
            inkAccepted = 1; ink_snapshot("accepted-return");
        }
        resume_from_breakpoint(); return;
    }
    if (pc == INK_DISAPPEARED && inkAccepted) {
        ink_snapshot("disappeared-entry");
        resume_from_breakpoint(); return;
    }
    LifecycleDebuggerUpdate(pc);
}

EXPORT void CALL GetKeys(int control, BUTTONS *keys) {
    int before = gBoundaryInstalled;
    LifecycleGetKeys(control, keys);
    if (control != 0 || before || !gBoundaryInstalled) return;
    uint32_t object = R32(A_MARIO_OBJECT);
    W32(A_MARIO_STATES + M_POS_Y, fbits(INK_ACTUAL_Y));
    W32(object + O_POS_X, fbits(-2200.0f));
    W32(object + O_POS_Y, fbits(768.0f));
    W32(object + O_POS_Z, fbits(-1024.0f));
    W32(object + GFX_POS_X, fbits(-2200.0f));
    W32(object + GFX_POS_Y, INK_DISPLAY_WORD);
    W32(object + GFX_POS_Z, fbits(-1024.0f));
    ink_snapshot("setup");
    if (DSetCallbacks(debugger_init_callback, ink_debugger, debugger_vi_callback) != M64ERR_SUCCESS
            || !add_exec_breakpoint(INK_HANDLER_CALL)
            || !add_exec_breakpoint(INK_HANDLER_RETURN)
            || !add_exec_breakpoint(INK_DISAPPEARED)) {
        fprintf(stderr, "BACKWARD_INK_ERROR,kind=arm\n");
    }
}
