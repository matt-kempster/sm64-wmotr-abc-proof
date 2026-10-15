# Demo sequence / level source audit

## Question and verdict

The requested property concerns a demo's recorded inputs running as gameplay in
a different demo level. It is stronger than showing that startup reads an input
pointer and a level number from the same buffer. This independent source review
found **no normal-execution mismatch witness**, and it does **not** establish a
whole-game impossibility theorem. The all-executions claim remains **open** at
the reachability and memory-preservation boundary described below.

An arbitrary well-formed local state can contain a valid demo-record pointer
alongside a different current level. The real playback function does not compare
the two. That observation is a missing runtime check, not evidence that normal
gameplay can reach the state. In particular, initializing a mismatched state in
an emulator or Coq memory would not by itself disprove impossibility from boot.

## Source and version boundary

The reviewed source is the SM64 decomp repository at
`9921382a68bb0c865e5e45eb594d9c64db59b1af` (`ique hotfix`). The neighboring
checkout currently has a different HEAD and local instrumentation, so pinned
`git show <revision>:<path>` contents take precedence over that checkout's
working files. The new Demo pipeline records this pinned revision and generates
separate US and JP translation units. US and JP are distinct programs; no
conclusion about EU, Shindou, iQue, arbitrary ROM patches, or emulator behavior
follows merely from those two configurations.
The generated Clight uses CompCert's PowerPC 32-bit, big-endian EABI
configuration with `TARGET_N64=1`, `NON_MATCHING=1` and `AVOID_UB=1`; graphics
flags are US F3DEX2/shared versus JP F3D-old. The local code theorems concern
that translation configuration. Matching it to all retail-binary behavior
is an additional refinement obligation, especially around undefined behavior.

`assets/demo_data.json` gives the US stream-file order as bitdw, wf, ccm, bbh,
jrb, hmc, pss. JP omits the bitdw file and uses wf, ccm, bbh, jrb, hmc, pss.
**Correction:** the filename bitdw does not identify the dispatched course:
header 30 selects the Bowser 1 arena; BITDW course is level 17. The extracted
authentic demo headers are:

| Stream | Header level byte | File length |
| --- | ---: | ---: |
| BBH | 4 | 988 |
| CCM | 5 | 1320 |
| HMC | 7 | 980 |
| JRB | 12 | 620 |
| WF | 24 | 672 |
| PSS | 27 | 748 |
| bitdw file / Bowser 1 arena (US) | 30 | 1412 |

The named authentic files end in a zero-timer record. `unused.bin` is outside
the selectable table and does not have the normal four-byte level header.
The WF table entry intentionally requests an extra 368 bytes; an argument
about a whole loaded range must retain that detail. Table/header facts are
data checks, not a proof that DMA actually returns those bytes in every run.

## What startup actually does

In `src/menu/title_screen.c`, `run_level_id_or_demo` first clears
`gCurrDemoInput`. On the idle countdown branch it:

1. Calls `load_patchable_table(&gDemoInputsBuf, gDemoInputListID)`.
2. Advances `gDemoInputListID` and wraps it at the table count. This is the
   **next** demo's index; it is not the level of the currently playing demo.
3. Installs `((struct DemoInput *) gDemoInputsBuf.bufTarget) + 1` as the
   current-record pointer, skipping the four-byte header.
4. Returns the signed first timer byte of that **same** `bufTarget` as the
   level, with save file and act set to one.

Thus an ordinary successful load cannot select the inputs from table entry
`i` but independently select the level from entry `i+1`: both selections use
the buffer just loaded. An incremented `gDemoInputListID` during playback is
expected behavior and is not a demo-level mismatch.

`src/game/memory.c:load_patchable_table` performs a bounds check on its
index and copies only if the source address differs from `currentAddr`. Its
return value is not checked by startup. Consequently a semantic startup
theorem must specify successful/authentic load behavior and safe index,
table, cached address, destination, and DMA memory effects, or prove those
properties from initialization. The source assignment order alone does not
discharge them.

## How the selected level reaches gameplay

`levels/intro/script.c` receives the return from `lvl_intro_update` through
`CALL_LOOP`. Values 100 and 101 select file/level menus; an ordinary demo
level instead takes `script_intro_L4` and exits into
`level_main_scripts_entry`. These transitions do not contain an independent
demo-index-to-level lookup.

`levels/scripts.c:level_main_scripts_entry` calls
`lvl_init_from_save_file` with the interpreter register. In
`src/game/level_update.c` that function sets `gCurrLevelNum = levelNum` and
returns the same `levelNum`. The main script then executes the menu entry
which calls `lvl_set_current_level`. That function again writes
`gCurrLevelNum = levelNum`, and its active-demo check returns zero, skipping
the act-selection menu. The main level table obtains `gCurrLevelNum` and
dispatches to the corresponding level entry.

`src/engine/level_script.c:level_cmd_call` and
`level_cmd_call_loop` pass the current register to the real called function
and assign its return back into the register. This identifies the real
dataflow to prove. Listing the scripts, constants, or call syntax does not
prove execution of the interpreter, preservation of its stacks/register,
or the authenticity of indirect call targets.

`src/game/game_init.c:read_controller_inputs` calls `run_demo_inputs` each
frame, including transition frames. During the title fade, the new demo
pointer may coexist with a stale `gCurrLevelNum` before level initialization.
That is not automatically gameplay in the old demo level: the title scene is
still active. A faithful definition must identify the loaded gameplay level
and the relevant frame boundary, instead of treating every instantaneous
pointer/level-number inequality as the user's desync.

## Playback and ordinary exits

`src/game/game_init.c:run_demo_inputs` reads only the active demo records and
controller objects; it does not consult `gCurrLevelNum`. It clears player-two
input, preserves only the physical Start bit for player one, supplies the
record's stick/button values, decrements its byte timer, and advances one
record when the timer reaches zero. A zero timer supplies `END_DEMO`.
Playback has no runtime header-to-current-level check.

In `src/game/level_update.c:play_mode_normal`, an active demo and `END_DEMO`
schedule `WARP_OP_DEMO_END` in PSS or `WARP_OP_DEMO_NEXT` elsewhere. Physical
Start also schedules the latter when the transition/delayed-warp guards allow
it. `initiate_delayed_warp` intercepts an active demo **before** the ordinary
warp-node destination switch: demo end calls `warp_special(-8)`, while the
other intercepted operations call `warp_special(-2)`. The main script sends
those negative results to splash/title scripts. A pending ordinary death,
star exit, warp object, or floor warp therefore does not simply enter its
ordinary destination while demo playback continues, provided this actual
branch is reached with the demo pointer intact.

HMC's green pool is an important apparent exception to check. Its script
uses `bhvWarp` and warp node `0x0B` leading to COTMC. CCM's slide entry also
uses an ordinary warp object, leading to CCM area two. These are delayed
warp paths, not `PAINTING_WARP_NODE` paths, so the demo interception applies.
They are not demonstrated cross-level demo exploits.

## Painting path and the concrete demo scripts

`src/game/level_update.c:initiate_painting_warp` has **no** active-demo guard.
When its area/floor/action conditions hold, it can call `initiate_warp` with
the painting node's destination and schedule a level change while leaving
`gCurrDemoInput` in place. Therefore a theorem for arbitrary area/floor memory
cannot justify impossibility solely from delayed-warp interception.

The relevant finite source census is favorable: none of
`levels/{bowser_1,wf,ccm,bbh,jrb,hmc,pss}/script.c` declares a
`PAINTING_WARP_NODE` or `INSTANT_WARP`, including their script-local branches.
In pinned `include/level_commands.h`, these are opcode `0x27` with byte length
`0x08`, and opcode `0x28` with byte length `0x0C`, respectively. Ordinary
`WARP_NODE` is opcode `0x26` with byte length `0x08`. A generated-data checker
must decode command boundaries and lengths; searching arbitrary initializer
bytes for `0x27`/`0x28` would misclassify data bytes inside other commands.
The current finite check scans the initialized script arrays in those seven
translation units. It does not recursively follow `JUMP_LINK`/`EXECUTE`
pointers into other translation units such as `script_func_global_N`.
Consequently its result is an absence certificate for the listed arrays,
not a closed control-flow theorem for all executed scripts.
The original census used `bitdw` in place of `bowser_1` and therefore omitted
the actual first US demo arena. That intended-coverage error is corrected.
`DemoScriptDispatchFacts.v` now parses the generated numeric dispatch table
and each selected EXECUTE initializer to certify all seven header-to-entry
routes, including 30 to Bowser 1 and the distinct 17 to BITDW course.
`src/game/area.c:clear_areas` clears both area fields to NULL. The painting
entry path first requires a non-NULL `paintingWarpNodes`. Consequently an
ordinary execution that actually constructs and preserves these demo areas
does not take that bypass. This still needs the construction/preservation
argument; the absence of a declaration is not a whole-program memory frame.

## Mechanized surface versus remaining work

Demo-Coq's pipeline targets separate US and JP units for title startup,
controller playback, level update, the level-script interpreter, the main,
intro and menu scripts, star selection, memory/DMA helpers, and the seven
demo-level scripts. Generated AST facts and any local Clight execution
theorems should be read with their literal statements and printed
assumptions. This note is an independent source audit; it does not claim a
semantic proof merely because a source path or generated unit is listed.
Area and in-game-menu units are now generated too. `clear_areas` above remains
a source observation until its execution and callers are proved.

`DemoDispatchFacts.v` checks additional exact generated subtrees in both US
and JP: the non-null delayed-demo branch contains only the operation test
and `warp_special(-8)`/`warp_special(-2)` choice; both interpreter call
commands load the script register, pass it as the second argument to the
indirect call, and capture the result back into the register. A direct-write
census checks that the two level initialization functions write their
`levelNum` parameter to `gCurrLevelNum`, and the save-file initializer's only
explicit return expression is that parameter. The targeted pipeline build
passes and this combined dispatch certificate is closed under the global
context. These are syntax equalities, not proofs about the indirect callees'
effects, actual branch reachability, or complete interpreter execution.

Subsequent semantic work now executes the real first-title body (with the
named loader still an execution premise), the real active-demo level selector
and interpreter CALL command, null-table painting rejection, the delayed-demo
branch with internal `warp_special`, transition completion at zero destination,
and complete pause rejection with its real dialog helper. See
[gameplay-execution.md](gameplay-execution.md),
[gameplay-boundary.md](gameplay-boundary.md) and
[pause-exclusion.md](pause-exclusion.md) for literal scope. In particular,
`warp_special` does not clear an existing ordinary destination, which wins
over the negative title code during transition completion. Its zero-state
invariant remains necessary. The finite retail search is recorded separately
in [gameplay-search.md](gameplay-search.md).

To close the requested normal-execution impossibility claim, the remaining
work includes:

1. Define desync at a real loaded-gameplay/consumed-input boundary and define
   the permitted starts and external events. Distinguish level changes from
   within-level physics/timing desynchronization and from title transitions.
2. Prove authentic startup/DMA/index/cached-address invariants, connect
   the selected buffer/header to the installed pointer, and preserve that
   provenance over record timer updates and all reached calls.
3. Prove the interpreter and concrete script route preserve the selected
   level until the matching level is actually loaded. Include the real
   register, command pointers, stack, indirect calls, and allocations.
4. Prove construction and preservation of the demo areas' absent painting
   and instant-warp data, and semantic coverage of every level-changing
   path, including debug/paused/credits alternatives according to the
   chosen initial-state scope.
5. Establish that all reached stores and hardware DMA effects preserve
   the protected pointer, handler, level state, script state, and authentic
   records except at the authorized updates. A direct-writer census does
   not exclude an indirect out-of-bounds store or prior corruption.

The old `SSL-Coq/old-proofs/demo-warp` project concerns demo-timer aliasing
with Mario's Y byte. Its own report distinguishes generated syntax and
arithmetic normal-state certificates from a complete Clight initialization
and all-frame preservation proof. Those results must not be reused as if
they already established the new level/sequence reachability invariant.

**Current source-level conclusion:** ordinary startup pairs the stream and
level in one buffer, the known ordinary warp paths return demos to title,
and the seven authentic demo scripts supply no painting bypass. No normal
desync was demonstrated. The all-executions impossibility claim remains open;
arbitrary-state replay capability is not a boot-reachable counterexample.
