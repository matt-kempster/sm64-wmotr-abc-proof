# CompCert execution scope

> Status snapshot: 2026-08-20. This document defines what the current proof can
> decide, what needs an external-effect refinement, and what is outside the
> present execution model.

## The decision boundary

The active execution witnesses are finite runs of CompCert Clight `step2`.
Those runs contain successful, defined source-level operations only. If a load,
store, pointer dereference, or indirect call is invalid in CompCert's semantics,
execution has no next Clight step at that operation. Therefore an exploit whose
essential event is a successful out-of-bounds overwrite or an arbitrary jump
cannot be proved as a counterexample in the current model.

At the formal-library level, a successful `Mem.load` implies readable
`valid_access`, a successful `Mem.store` implies writable `valid_access`, and a
Clight call step requires the global environment to return a function.  See
the official [memory semantics](https://compcert.org/doc/html/compcert.common.Memory.html)
and [Clight call rules](https://compcert.org/doc/html/compcert.cfrontend.Clight.html).

That is a limitation of the model, not a disproof of the retail game exploit.
CompCert's reference interpreter is faithful to the formal C semantics and
stops when it reaches undefined behavior, while the generated machine code has
no corresponding run-time check and may crash or continue with any behavior.
CompCert's own correctness results consequently preserve safety-enforcing
specifications; they do not say that a particular post-undefined-behavior
machine-code continuation is impossible. See the official
[interpreter manual](https://compcert.org/man/manual004.html),
[Clight semantics](https://compcert.org/doc/html/compcert.cfrontend.Clight.html),
and [compiler-correctness qualification](https://compcert.org/doc/html/compcert.driver.Complements.html).

There is a second, independent boundary. Upstream CompCert generates code for
PowerPC, ARM/AArch64, x86, and RISC-V, not the N64's MIPS processor. This
project uses CompCert's Clight and memory semantics as its source execution
model; it does not currently obtain a CompCert theorem connecting those runs
to the retail MIPS ROM. The selected-Clight-to-retail bridge therefore remains
a project proof obligation. CompCert's supported targets and unverified
assembler/linker boundary are described in its official
[manual introduction](https://compcert.org/man/manual001.html).

## What the model excludes

The current Clight-run proofs cannot contain any of the following as a
successful step:

- a load or store outside the relevant CompCert allocation block, without the
  required permission, or at an invalid alignment;
- dereferencing an out-of-bounds or otherwise invalid pointer;
- using a function value that does not resolve to a function in the Clight
  global environment;
- continuing in Clight after one of those operations has become stuck;
- arbitrary code execution by jumping into data, injected instructions, or an
  interior machine-code address;
- a raw MIPS-only continuation after source undefined behavior;
- asynchronous DMA, interrupts, self-modifying code, or other hardware writes
  unless they are added as explicit semantic transitions.

CompCert permits pointer arithmetic to form an out-of-bounds pointer, but its
manual says that dereferencing or comparing that pointer is undefined. It also
keeps the byte representation of pointers opaque, so a route that depends on
partially overwriting or inspecting pointer bytes is not an ordinary typed
Clight route. These details are documented in the official
[CompCert C language manual](https://compcert.org/man/manual005.html).

## What the model does not exclude

“Memory corruption” is too broad a label for proof triage. The following can
still be valid Clight behavior and must be proved or disproved normally:

- an in-bounds store through the wrong but valid alias;
- a store to the wrong field or logical object slot while remaining inside the
  allocated object-pool block;
- a valid interior pointer whose actual access remains inside the allocation;
- stale or reused SM64 object-pool bytes, because SM64's logical object free
  list does not itself call CompCert `Mem.free` on the global pool block;
- retargeting a function pointer to another function already registered in the
  program, if the pointer-changing store is itself defined;
- ordinary collision, scheduler, surface-owner, object-lifecycle, Float32, and
  signed-integer behavior;
- ISO C behaviors that CompCert deliberately defines, including its modular
  signed-overflow semantics;
- an explicit external or volatile effect once its semantics and protected
  memory footprint are supplied.

CompCert models calls to unresolved `EF_external` functions through a
parameterized relation constrained by general external-call properties. That
does not give this project the concrete effect of an N64 library, OS, or engine
routine. Such a route is neither excluded nor ready for a retail conclusion:
the callsite must first receive a precise effect or frame specification. The
official [external-call semantics](https://compcert.org/doc/html/compcert.common.Events.html)
make this parameterization explicit.

For the Timer-131 entry, the project now uses a deliberately smaller retail-
machine extension instead of leaving three such effects abstract.
`InkTimer131RetailMipsCode.v` authenticates and scans the complete JP bodies of
`sqrtf`, both sound roots, and every transitive sound helper;
`InkTimer131RetailMipsFrames.v` proves their ordinary store footprints miss the
entire object pool when the call stack does.  The live receipt supplies that
stack fact for the reached continuous-bank call.  This closes those three
specific effects without an IDO-to-Clight bridge, but it is not a general MIPS
or hardware semantics: forged control flow, invalid accesses, ACE, DMA,
interrupt writers, and self-modifying code remain outside its premise.

## Route triage

| Route or escape | Current status | Consequence for research |
|---|---|---|
| Rank 1 collision/query sampling, callbacks, scheduler, live surface owner, and object-pool lifetime | Defined Clight mechanisms | Keep proving or searching them now. |
| Rank 1 in-bounds alias or same-slot mutation | Defined Clight mechanism | Keep it open until pointer and store provenance are linked. |
| Rank 1 out-of-bounds pointer installation or ACE continuation | Outside the current Clight run | Do not call it disproved; defer it until a retail machine model exists. |
| Rank 2 normal Graphics writers and negative-quicksand/dialog amplification | Defined Clight mechanisms | These remain legitimate proof targets. |
| Rank 2 wrong live slot/list identity, bounded same-slot overwrite, or retarget to a known behavior | Defined Clight mechanisms | Keep them open and demand the first valid store or identity change. |
| Rank 2 out-of-bounds overwrite, fabricated invalid-pointer dereference, ACE, or DMA installer | Outside the current Clight run | The current proof can neither construct nor refute the retail exploit. |
| Rank 3 ordinary platform displacement and a defined platform-pointer/payload install | Defined Clight mechanisms | Keep proving the stock installation and scheduler/owner boundary. |
| Rank 3 out-of-bounds platform-pointer fabrication or post-UB machine continuation | Outside the current Clight run | Defer without treating the stock Clight no-go as a retail disproof. |
| Any reachable unresolved external writer | Parameterized Clight boundary | Specify the exact call effect or protected-cell frame before route work; the three Timer-131 pre-entry routines now have a targeted retail-MIPS frame. |
| False collision cache, hitbox mutation, wrong object slot, Goomba, Eyerok, PU, or ordinary collision glitch | Usually defined Clight mechanisms | Do not discard them merely because they sound like corruption or a glitch. |
| Animation metadata update | Defined and already narrowed | Continue to use the source proof. |
| Actual animation-buffer DMA overlap, interrupt write, or raw hardware transfer | Machine/external-model extension | Defer unless a concrete witness justifies adding the missing semantics. |

This triage does not lower the probability of an excluded retail mechanism. It
only says that current Clight theorems cannot decide it. Conversely, a route is
not promising merely because it is in scope; it still needs a clean reachable
witness.

## Required wording in project claims

Use these verdicts consistently:

- **Disproved in the current Clight model:** a theorem rules out every witness
  satisfying the explicitly named defined-execution premises.
- **Outside the current execution model:** the essential step is invalid in
  Clight or exists only at the MIPS/hardware level. No retail verdict follows.
- **Open external refinement:** Clight contains a parameterized external call,
  but the project has not supplied its concrete effect or frame.
- **Retail counterexample or retail disproof:** reserved for evidence connected
  to the actual ROM execution model, including the relevant undefined or
  hardware behavior if the route uses it.

It is incorrect to say “CompCert proves that out-of-bounds exploits or ACE
cannot happen in SM64.” The correct statement is: “the project's current
CompCert Clight runs have no witness for that event, so this proof cannot decide
the corresponding retail route.”

## Formalization

`proofs/CompCertRouteScope.v` hardcodes the distinction. It proves from
CompCert's actual memory model that every successful load/store has the needed
access permission, proves that every Clight transition into a call state names
a registered function, and checks route-scope tables for ranks 1–3 and the
generic memory family. Its research disposition is:

1. analyze defined internal Clight mechanisms now;
2. specify a reachable external effect before relying on it; and
3. defer invalid-access, ACE, post-undefined-behavior, DMA, interrupt, and
   self-modifying-code routes until a machine-level model exists.

Closing the third category would require a retail MIPS operational semantics,
the ROM/RAM and object-layout map, device and interrupt behavior, a connection
from the selected sources to that binary, and a deliberate semantics for what
happens after the relevant source undefined behavior. That extension is
possible in principle, but it is not the current research priority.
