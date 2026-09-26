/* ESBMC harness (compositional): ONE real perform_air_quarter_step (vendor mario_step.c,
 * unmodified) against CONTRACT stubs of the collision engine.
 *
 * Question: with the vertical velocity v at frame start, how high can one air
 * step put Mario?  Claim under test (GOAL-2 Δ_pot airborne arm):
 *
 *     pos1' <= pos1 + max(v,0) + 238        (+238 = glitchy ledge-grab window)
 *
 * plus preservation of the side invariant the claim needs:
 *
 *     floorHeight <= pos1 + FH_SLACK        (referenced floor not far above)
 *
 * Stubs encode ONLY facts read off the real engine (cite lines):
 *   find_floor            surface_collision.c:459  floor height <= (s16)y + 78, or NULL
 *   vec3f_find_ceil       mario.c:550               any ceiling (over-approx)
 *   resolve_and_return_wall_collisions  pushes x/z only (find_wall_collisions_from_list)
 *   find_water_level, atan2s, terrain sound: arbitrary.
 */
#include <sm64.h>
#include "types.h"

extern float nondet_float(void);
extern int nondet_int(void);
extern short nondet_short(void);
extern unsigned int nondet_uint(void);

s32 perform_air_quarter_step(struct MarioState *m, Vec3f intendedPos, u32 stepArg);

static struct Surface sFloorA, sCeilA, sWallA, sLedgeFloor;
static struct Object sMarioObj;

#define FH_SLACK 79.0f

static struct Surface *nondet_surface(struct Surface *s) {
    if (nondet_int()) return NULL;
    s->type = nondet_short();
    s->normal.x = nondet_float(); s->normal.y = nondet_float(); s->normal.z = nondet_float();
    return s;
}

f32 find_floor(f32 x, f32 y, f32 z, struct Surface **pfloor) {
    f32 h = nondet_float();
    struct Surface *f = nondet_surface(nondet_int() ? &sFloorA : &sLedgeFloor);
    *pfloor = f;
    if (f == NULL) return -11000.0f;               /* FLOOR_LOWER_LIMIT */
    __ESBMC_assume(h == h);                         /* not NaN */
    __ESBMC_assume(h >= -8192.0f);
    __ESBMC_assume(h <= (f32)(s16) y + 78.0f);      /* the 78-unit snap buffer */
    return h;
}

f32 vec3f_find_ceil(Vec3f pos, f32 height, struct Surface **ceil) {
    f32 c = nondet_float();
    __ESBMC_assume(c == c);
    *ceil = nondet_surface(&sCeilA);
    return c;
}

struct Surface *resolve_and_return_wall_collisions(Vec3f pos, f32 offset, f32 radius) {
    pos[0] = nondet_float();                        /* walls push horizontally only */
    pos[2] = nondet_float();
    __ESBMC_assume(pos[0] > -1e5f && pos[0] < 1e5f && pos[2] > -1e5f && pos[2] < 1e5f);
    return nondet_surface(&sWallA);
}

/* WMOTR LEVEL CONTRACT: no water boxes in levels/wmotr -> FLOOR_LOWER_LIMIT. */
f32 find_water_level(f32 x, f32 z) { return -11000.0f; }
s16 atan2s(f32 y, f32 x) { return nondet_short(); }
u32 mario_get_terrain_sound_addend(struct MarioState *m) { return nondet_uint(); }
void vec3f_copy(Vec3f dest, Vec3f src) { dest[0] = src[0]; dest[1] = src[1]; dest[2] = src[2]; }
void vec3s_set(Vec3s dest, s16 x, s16 y, s16 z) { dest[0] = x; dest[1] = y; dest[2] = z; }

int main(void) {
    struct MarioState m;
    Vec3f ip;
    m.marioObj = &sMarioObj;
    m.floor = nondet_surface(&sFloorA);
    m.ceil = nondet_surface(&sCeilA);
    m.action = nondet_uint();
    m.flags = nondet_uint();
    m.faceAngle[1] = nondet_short();

    f32 y0 = nondet_float(), v0 = nondet_float(), fh = nondet_float();
    __ESBMC_assume(y0 >= -8000.0f && y0 <= 8000.0f);
    __ESBMC_assume(v0 >= -75.0f && v0 <= 100.0f);
    __ESBMC_assume(fh >= -11000.0f && fh <= y0 + FH_SLACK);
    m.pos[0] = nondet_float(); m.pos[1] = y0; m.pos[2] = nondet_float();
    m.vel[0] = nondet_float(); m.vel[1] = v0; m.vel[2] = nondet_float();
    __ESBMC_assume(m.pos[0] > -1e5f && m.pos[0] < 1e5f && m.pos[2] > -1e5f && m.pos[2] < 1e5f);
    __ESBMC_assume(m.vel[0] > -1e4f && m.vel[0] < 1e4f && m.vel[2] > -1e4f && m.vel[2] < 1e4f);
    m.floorHeight = fh;

    /* intendedPos exactly as perform_air_step computes it (mario_step.c:619-621) */
    ip[0] = m.pos[0] + m.vel[0] / 4.0f;
    ip[1] = m.pos[1] + m.vel[1] / 4.0f;
    ip[2] = m.pos[2] + m.vel[2] / 4.0f;

    s32 r = perform_air_quarter_step(&m, ip, nondet_uint());

    f32 q = v0 > 0.0f ? v0 / 4.0f : 0.0f;
#ifdef PROP_GAIN
    /* per-qstep: rise <= max(v,0)/4, or a terminal snap (LANDED / LEDGE) of <= 239 */
    __ESBMC_assert(m.pos[1] <= y0 + q + 0.001f
                   || ((r == AIR_STEP_LANDED || r == AIR_STEP_GRABBED_LEDGE) && m.pos[1] <= y0 + 239.0f),
                   "qstep: non-terminal rise <= v/4; terminal snap <= 239");
#endif
#ifdef PROP_STALE
    __ESBMC_assert(m.floorHeight <= m.pos[1] + FH_SLACK + 18.75f + 0.01f, "qstep: stale floorHeight grows <= one quarter step");
#endif
    return 0;
}
