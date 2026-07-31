#ifndef RETRY_X
#define RETRY_X -1862.0f
#endif
#ifndef RETRY_Y
#define RETRY_Y 1778.0f
#endif
#ifndef RETRY_Z
#define RETRY_Z -902.0f
#endif

#define GetKeys LifecycleGetKeys
#include "../jp-lifecycle/jp_lifecycle_probe.c"
#undef GetKeys

/*
 * Search harness for capture-preserving timer-131 Graphics samples.  The
 * inherited fixture first installs its documented three-view state; before
 * that frame executes, this wrapper changes only the Graphics retry sample.
 */
EXPORT void CALL GetKeys(int control, BUTTONS *keys) {
    int installed_before = gBoundaryInstalled;

    LifecycleGetKeys(control, keys);
    if (control != 0) return;

    if (!installed_before && gBoundaryInstalled) {
        uint32_t mario_object = R32(A_MARIO_OBJECT);
        W32(mario_object + GFX_POS_X, fbits(RETRY_X));
        W32(mario_object + GFX_POS_Y, fbits(RETRY_Y));
        W32(mario_object + GFX_POS_Z, fbits(RETRY_Z));
        fprintf(stderr,
                "RETRY_OVERRIDE,timer=%u,graphics=(%.6f,%.6f,%.6f),"
                "graphicsBits=(%08x,%08x,%08x)\n",
                R32(A_GLOBAL_TIMER),
                rfloat(mario_object + GFX_POS_X),
                rfloat(mario_object + GFX_POS_Y),
                rfloat(mario_object + GFX_POS_Z),
                R32(mario_object + GFX_POS_X),
                R32(mario_object + GFX_POS_Y),
                R32(mario_object + GFX_POS_Z));
    }
}
