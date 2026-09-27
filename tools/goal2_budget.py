#!/usr/bin/env python3
"""
GOAL-2 height budget per no-A airborne episode, in exact binary32.

This corrects E3 (docs/goal2-episode-graph-e3.md). E3 priced both landing
bounces with gravity -4. act_slide_kick flies under gravity -2
(apply_gravity, vendor/sm64/src/game/mario_step.c:543), so its bounce climbs
about twice as high.

It prints two numbers per chain, both relative to the floor the episode
launched or bounced from (a floor <= H*):
  top     the highest pos[1] the episode reaches     -> YMAX = H* + max top
  attach  the highest floor it can latch onto        -> must stay below the moat
          (landing snap: +78, surface_collision.c:459; ledge grab: +239,
           mario_step.c:348 + the 78 buffer + 1 for the s16 truncation,
           experiments/esbmc finding 2)

The frame model is the real order. act_* checks and bumps actionTimer, then
perform_air_step (mario_step.c:610) does 4 quarter steps of pos += vel/4, then
apply_gravity (vel -= g, clamped at -75).

Horizontal feasibility is ignored, as in goal2_ladder.py: we assume that any
floor configuration an edge needs exists. This over-approximates.
"""
import numpy as np

f = np.float32
SNAP = f(78)          # find_floor search buffer
LEDGE = f(239)        # ledge-grab window (238 + s16 truncation)
GP_WINDUP = [f(20 - 2 * t) for t in range(10)]   # act_ground_pound :926
GP_VEL = f(-50)       # :934
TERMINAL = f(-75)


def frame(y, v, g):
    for _ in range(4):
        y = f(y + f(v / f(4)))
    v = f(v - g)
    if v < TERMINAL:
        v = TERMINAL
    return y, v


def fly(y, v, g, frames):
    """Ballistic flight for `frames` frames; returns the trajectory."""
    traj = [(y, v)]
    for _ in range(frames):
        y, v = frame(y, v, g)
        traj.append((y, v))
    return traj


def apex(y, v, g):
    return max(p for p, _ in fly(y, v, g, 200))


def after_ground_pound(y):
    """Z from freefall at height y: windup, then the first quarter step down."""
    for dy in GP_WINDUP:
        y = f(y + dy)
    top = y
    first_q = f(y + f(GP_VEL / f(4)))
    return top, f(first_q + SNAP)


def freefall_from(y, v):
    """Freefall (g = 4) entered at (y, v): best of ride, Z->GP, ledge grab."""
    ride_top = apex(y, v, f(4))
    gp_top, gp_attach = max(after_ground_pound(p) for p, _ in fly(y, v, f(4), 60))
    # ledge grab needs vel <= 0 (mario_step.c:354); take the highest such point
    ledge_y = max(p for p, w in fly(y, v, f(4), 60) if w <= 0 or p == ride_top)
    return {
        "top": max(ride_top, gp_top),
        "attach": max(f(ride_top + SNAP), gp_attach, f(ledge_y + LEDGE)),
    }


def launch(v0, g):
    top = apex(f(0), f(v0), g)
    return {"top": top, "attach": f(top + SNAP)}


def bounce_then_freefall(g, timer_reset):
    """A landing bounce at terminal speed: vel = -vel/2 (airborne.c:1445/1604),
    then (after the >30-frame timer) freefall -> GP / ledge grab."""
    v_b = f(-TERMINAL / f(2))
    traj = fly(f(0), v_b, g, 80)
    top = max(p for p, _ in traj)
    worst = {"top": top, "attach": f(top + SNAP)}
    # earliest freefall frame: slide kick resets actionTimer at the bounce
    # (:1606), so it needs 30 more frames; butt-slide-air does not (:1445), so
    # freefall can start on any later frame.
    first = 30 if timer_reset else 1
    for y, v in traj[first:]:
        ff = freefall_from(y, v)
        worst = {k: max(worst[k], ff[k]) for k in worst}
    return worst


CHAINS = [
    ("ground dive, vel 20 (moving.c:491)", launch(20, f(4))),
    ("rollout, vel 30 (airborne.c:1355)", launch(30, f(4))),
    ("slide kick launch, vel 12, g 2 (mario.c:876)", launch(12, f(2))),
    ("walk off a ledge -> freefall (vel 0)", freefall_from(f(0), f(0))),
    ("butt-slide-air bounce 37.5, g 4, then freefall", bounce_then_freefall(f(4), False)),
    ("SLIDE-KICK bounce 37.5, g 2, then freefall", bounce_then_freefall(f(2), True)),
    ("  E3 priced the slide-kick bounce at g 4 (wrong)", launch(37.5, f(4))),
]

H_STAR = 2424.0       # goal2_ladder.py, entry-seeded (box top x2 scale; was 2372)
MOAT = 622.0          # next rung above H*: pole 4 grab window, 2994
COIN2_REACH = 3140.0 - 160.0

if __name__ == "__main__":
    print(f"{'chain':52s} {'top':>7s} {'attach':>7s}")
    for name, r in CHAINS:
        print(f"{name:52s} {float(r['top']):7.2f} {float(r['attach']):7.2f}")
    real = CHAINS[:-1]
    top = max(float(r["top"]) for _, r in real)
    att = max(float(r["attach"]) for _, r in real)
    print()
    print(f"max top    = {top:.2f}  -> YMAX = H* + top = {H_STAR + top:.2f};"
          f" coin #2 needs y >= {COIN2_REACH:.0f}: margin {COIN2_REACH - H_STAR - top:+.2f}")
    print(f"max attach = {att:.2f}  -> moat {MOAT:.0f}: margin {MOAT - att:+.2f}"
          f"  ({'GAP FACT HOLDS' if att < MOAT else '*** GAP FACT FAILS ***'})")
