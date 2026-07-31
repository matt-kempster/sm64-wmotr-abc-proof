#define ROUTE_STICK_X 0
#define ROUTE_STICK_Y 0
#define ROUTE_HOLD_FRAMES 1
#define GetKeys LifecycleGetKeys
#include "../jp-lifecycle/jp_lifecycle_probe.c"
#undef GetKeys

/*
 * Search harness for the time at which the conditional three-view boundary is
 * installed.  The inherited fixture supplies the State and Object views.  On
 * the installation poll this wrapper replaces only the Graphics view with the
 * midpoint of a side face in the collision mesh that the top will construct
 * later in that same frame.
 *
 * This is deliberately an injected-boundary experiment.  Its purpose is to
 * distinguish explosion deallocation from area-unload deallocation and to
 * enumerate the exact first-Area-2 payloads; it is not evidence that gameplay
 * can create the required State/Object/Graphics split.
 */

static float predicted_top_x(unsigned timer) {
    switch (timer & 3u) {
        case 0: return -2047.0f;
        case 1: return -2007.0f;
        case 2: return -2047.0f;
        default: return -2087.0f;
    }
}

static int32_t predicted_face_yaw(unsigned timer) {
    int32_t yaw = (int32_t) R32(gTop + O_FACE_YAW);

    if (timer >= 60u) {
        int32_t velocity = (int32_t) R32(gTop + O_ANGLE_VEL_YAW) + 0x100;
        if (velocity > 0x1800) velocity = 0x1800;
        yaw += velocity;
    }
    return yaw;
}

static void install_predicted_mid_face_retry(void) {
    uint32_t mario_object = R32(A_MARIO_OBJECT);
    unsigned timer = (unsigned) R32(gTop + O_TIMER);
    int32_t yaw = predicted_face_yaw(timer);
    float radians = (float) (int16_t) yaw
        * (2.0f * 3.14159265358979323846f / 65536.0f);
    float sine = sinf(radians);
    float cosine = cosf(radians);
    float x = predicted_top_x(timer) - sine * 255.0f;
    float y = rfloat(gTop + O_POS_Y);
    float z = rfloat(gTop + O_POS_Z) - cosine * 255.0f;

    W32(mario_object + GFX_POS_X, fbits(x));
    W32(mario_object + GFX_POS_Y, fbits(y));
    W32(mario_object + GFX_POS_Z, fbits(z));
    fprintf(stderr,
            "TIMER_RETRY,timer=%u,predictedYaw=%08x,"
            "graphics=(%.6f,%.6f,%.6f),graphicsBits=(%08x,%08x,%08x)\n",
            timer, (uint32_t) yaw, x, y, z,
            R32(mario_object + GFX_POS_X),
            R32(mario_object + GFX_POS_Y),
            R32(mario_object + GFX_POS_Z));
}

EXPORT void CALL GetKeys(int control, BUTTONS *keys) {
    int installed_before = gBoundaryInstalled;

    LifecycleGetKeys(control, keys);
    if (control != 0) return;

    if (!installed_before && gBoundaryInstalled) {
        install_predicted_mid_face_retry();
    }
}
