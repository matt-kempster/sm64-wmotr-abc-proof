# Goal

Prove, for the pinned `VERSION_US` and `VERSION_JP` programs:

> It is possible to enter a Pedro spot formed by the Tic Tock Clock cogs at
> suitable rotations, then manipulate RNG while Mario remains in that spot,
> keeping the relevant cogs frozen.

Here **cogs** means `bhvTTCCog`, not `bhvTTCSpinner`. Preserve exact cog yaw
angles in the target; do not substitute the former spinner-angle interval
claim. RANDOM-mode cogs can select zero target speed, unlike the old spinner
schedule, so the mechanism requires its own proof.

Exhibit a reachable entry and legal controller continuations with distinct,
predictable global `gRandomSeed16` traces while preserving Mario's Pedro state
and the relevant cog angles. State a finite preservation duration explicitly;
arbitrarily long freezing additionally requires a repeatable control strategy.

The previous universal claim about every stock Pedro spot is not part of the
active target. Existing spinner results remain useful prior work.

## Gameplay restrictions

Use ordinary game entry and legal controller inputs in authentic US/JP games.
Exclude arbitrary code execution (ACE), out-of-bounds corruption, and
arbitrary changes to game memory or code. Do not use cheats, forced RNG seeds,
or edited save states. An ordinary save or emulator checkpoint must have provenance
from normal gameplay. Instrumentation may observe the game without changing
guest memory, CPU registers, or instructions.

The user subsequently authorized a limited discovery experiment that starts
Mario near the cogs. A separate, explicitly labeled test build may configure
the initial TTC level, RANDOM mode, and Mario's spawn position/orientation.
After initialization, use controller inputs and observation only. Preserve
the stock cog, RNG, collision, dust, and movement functions. This exception
does not authorize forced cog rotations/speeds, RNG selection, corruption,
or general runtime memory changes, and it cannot establish normal entry.

CompCert memory operations describe assignments made by the generated stock
program. A lemma conditional on a memory image does not establish that the
image can be reached using the permitted controller inputs. Reachability
must be proved separately before such a lemma can support the final claim.

## Semantic target

The final claims must be stated over executions of the mechanically generated
and properly linked CompCert Clight programs. Geometry must be derived from the
generated TTC macro and cog collision initializers. Emulator traces may supply
witness discovery and regression evidence, but do not replace the Clight proof.

No theorem may silently extend the result to EU, Shindou, or iQue.

See [`ttc-cog-plan.md`](ttc-cog-plan.md) for the execution plan and evidence
boundaries.
