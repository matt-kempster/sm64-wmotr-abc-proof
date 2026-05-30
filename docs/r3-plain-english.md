# R3 in plain English: where we are and what's next

(Companion to the technical `r3-action-value-plan.md`. No Coq, no jargon.)

## The goal

A **machine-checked proof** -- one a computer verifies, with no room for
hand-waving -- of one claim about Super Mario 64:

> You cannot complete "Wing Mario over the Rainbow" without pressing the A button.

Why this claim: that star needs the high red coins -> reaching them needs wing-cap
**flight** -> flight is the game's `ACT_FLYING` state -> so if *entering ACT_FLYING
always requires an A press*, the A-Button Challenge can't do this level. The middle
claim -- "you must press A to fly" -- is what we actually prove, on the real
compiled SM64 source.

## The key idea

We stop trying to track Mario's state through raw memory (intractable) and instead
use two facts true of the actual code, turning the problem into a **finite map**:

1. **Each frame, the game picks Mario's behavior by a direct switch on his current
   action.** Action `X` runs handler `act_X`, which may set the next action. No
   hidden indirection.
2. **`set_mario_action` never *invents* a flying value** -- it passes its argument
   through or downgrades it to something non-flying. So Mario becomes flying only
   if the value handed in was *already* flying.

Put together, the whole game becomes a **map of arrows between action states**:
node = an action (~150 of them), arrow `X -> Y` = "while in X, Mario can become Y."
A handful of arrows (5, all enumerated) lead into a flying state.

"You must press A to fly" becomes: **on this map, every route into a flying state
crosses an arrow that requires pressing A.** That is a finite, checkable property --
a computer can walk the map exhaustively, the way we already do for call graphs.

Even better, two things we found make it cleaner than feared:
- **Every flying arrow uses a literal constant** (`ACT_FLYING`, `ACT_FLYING_TRIPLE_JUMP`)
  at the call site -- never a computed variable. So "what value gets written" needs
  no data-flow detective work for the flying cases.
- **The A-gate sits at the jump-entry arrows** (pressing A to jump *does* locally
  check the A button), not at the flying arrows themselves. So the "needs A" part
  is a handful of *local* checks, not a spooky global argument.

## What's proved and solid

1. **The memory engine** -- running game code (through calls and loops) leaves any
   region nothing touches unchanged. Hard, done, verified.
2. **The honest top statement** -- "a no-A run never reaches flying," grounded in
   the real memory layout, with the hard part quarantined as labeled assumptions.
3. **The bridge** connecting the engine to that statement.
4. **The trustworthy scans** -- the 5 flying-introduction sites; every action change
   goes through a known, enumerated set of writers; a static call graph.

## What's next, in six steps

The easy half (a computer just checks it):
- **P1** -- read off the map of arrows from every handler.
- **P2** -- mark which arrows require A (the jump-entry ones).
- **P3** -- compute: from any normal state you can't reach flying without crossing
  an A-arrow.

The hard half (the real proof -- making the map faithful to the actual game):
- **P4** -- prove a real frame actually moves Mario along an arrow on the map (the
  value-tracking upgrade of the memory engine -- the genuinely new work).
- **P5** -- prove each A-arrow really does require the A button in the code.
- **P6** -- assemble it so the top theorem becomes unconditional.

## Do we need more files?

For the core argument, **almost certainly not** -- all seven Mario action-handler
files are already loaded. New files are needed only for two long-known edge cases:
the level-warp data (the one non-jump way to spawn flying, which WMotR's level does
not contain) and stitching the separate files into one whole-program unit.

## The honest status

The scaffolding, the engine, and the blueprint are built and verified. The
**load-bearing wall is P4** -- proving a real frame follows the map. That's the
hard, new part; the rest is either cheap (P1-P3) or bounded and mechanical (P5).
Recommended first move is P1: it's low-risk and its output tells us exactly how big
P4/P5 really are before we invest in them.
