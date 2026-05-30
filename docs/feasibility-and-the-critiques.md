# Feasibility, and answers to the standard critiques

> A faithful capture (2026-05-29) of a back-and-forth prompted by two serious objections from
> people in the Lean world: (1) that proving theorems about even simple C is so hard that this
> project is a waste of money/tokens (with a random-maze benchmark as the supposedly-easier
> warm-up), and (2) that a compiling, `sorry`-free proof tells you nothing about whether the
> *fact* is true unless you can read and understand the statement. Both objections are partly
> right. This doc records where they bind, where they miss, and the standing discipline they
> imply. See also [trust-model.md](trust-model.md), [the-frame.md](the-frame.md),
> [object-set-and-glitches.md](object-set-and-glitches.md), [ROADMAP.md](ROADMAP.md).

The goal here is not to dismiss the skeptics — their priors are well-founded for the *strong*
reading of "verify C." It is to state precisely what we are and are not claiming, so the
optimism (where it exists) is legible and the risks (where they exist) are named.

## 1. "Proving theorems about even the simplest C is phenomenally hard" + the random maze

**The challenge.** Before doing SM64, write C that generates a random 10⁶×10⁶ maze with a
movable character, and prove (in a proof assistant) that the character either can or cannot
escape. Claimed to be "many orders of magnitude easier" than SM64 — and already so hard that
SM64 must be hopeless.

**Where it's right.**
- Per-function *semantic* verification of C is genuinely brutal, and we have the receipts:
  `ShadowSpec.v` proved one integer-returning function and required fighting `eval_lvalue`
  inversion, `Archi.ptr64` opacity, `sem_binary_operation` reduction, `vm_compute` vs `cbn`.
- The real crux of his maze is not the graph math; it is **binding the C execution to the
  abstract model** (proving the maze-gen + movement C actually computes the graph you reason
  about). SM64 has the identical crux — binding clightgen'd Clight to an abstract action model
  (`frame_step`, R3) — and **we have not built it yet.** His skepticism lands hardest there.
- The separate **Mario-y energy-bound** limb (needed for the full theorem, not the flight limb)
  requires quantitative float reasoning at scale; it is the part most exposed to "phenomenally
  difficult," and may be infeasible with current tooling.
- ROI is a fair worry independent of possibility: seL4 (full functional correctness of a ~10k-line
  C kernel) took ~20 person-years. "Possible" ≠ "worth it."

**Where it breaks.** On one axis: **impossibility-via-abstraction is a different complexity class
than deciding reachability over an unstructured instance.**
- A *safety/impossibility* property may use any **sound over-approximation**: a coarse abstraction
  that loses precision still proves "the bad state is unreachable" as long as the abstraction still
  cannot reach it. You only pay for precision where the abstraction is too coarse. This is the
  abstract-interpretation insight, and **Astrée verified the absence of runtime errors in Airbus
  flight-control C — real, huge, safety-critical C — soundly and at scale.** That is a direct
  existence proof against the strong reading. It is true for *full functional correctness*; it is
  much less true for *safety properties amenable to abstraction*, which is what we have.
- A **random** 10⁶×10⁶ maze is *adversarial to abstraction*: it has no exploitable structure, so
  the only invariant proving non-escape is essentially the exact reachable component — a huge,
  instance-specific object. SM64's action gating is the opposite: the programmers wrote **explicit
  guards** (`if (m->input & INPUT_A_PRESSED)`, `MARIO_WING_CAP`). A coarse abstraction — track only
  the action, the A-bit, and the jump-sequence chain — is sound *and* precise enough *because the
  structure was authored in*. The relevant state is small (an action enum + a few flags), not 10¹²
  cells. On the dimension his example is built to stress, the gating property is **easier than his
  maze, not harder.**
- His maze, taken literally, is itself infeasible by brute force (10¹² cells can't be reflected
  through a kernel, or even generated), so it *also* forces abstraction + a C-binding — the same
  shape as ours. The analogy is more symmetric than it first appears.

**The standing risk + the diagnostic.** The optimistic story assumes **every link in the A-chain
is an explicit guard.** The danger is a transition gated by *physical/stateful* conditions rather
than an input check — then the invariant Φ leaks out of "action + flags + A-bit" into object/physics
state and the small-state discount evaporates. R2 already showed the gate is *upstream* (a chain);
the open question is whether the chain stays inside explicitly-guarded discrete transitions.
Standing diagnostic, applied per link:

> **Is this gate a syntactic input/flag check (cheap), or does it require reasoning about
> `vel`/`pos`/floors (ShadowSpec-hard)?**

So far the gates are explicit. A physical gate is exactly where the critique could be vindicated.

**Bottom line.** Valid as a *caution* (the semantic bridge is the crux and is unbuilt; the y-bound
is genuinely hard; the labor is large). Invalid as a *difficulty ranking* for the flight-gating
limb: his maze is hard because it is random and astronomically large — properties that defeat
abstraction — while the gating property sits in the safety/abstract-interpretation sweet spot.

## 2. The law-of-excluded-middle sub-point: "can or cannot escape" is not LEM

"Prove that either it can get out or it cannot" has two readings:
- **Bare disjunction** `CanEscape ∨ ¬CanEscape` — a `Prop`, free by classical logic (`classic _`
  in Rocq, `Classical.em` in Lean), one line, touches nothing. **Contentless.** That it is trivial
  is the tell that it is *not* what is meant.
- **Decide it** — produce `Decidable CanEscape` / a term of `{CanEscape} + {¬CanEscape}`: actually
  determine the answer for the specific maze, prove the correct disjunct, and bind it to what the C
  computes. *Not* free.

So the objection is **not** "LEM is hard." LEM hands you the disjunction for free but gives **zero**
information about which side holds and **zero** connection to the program; all the difficulty lives
in the part LEM does not touch (deciding + binding). And note: "solving" the challenge with
`classic` would yield a green checkmark meaning *nothing* — the canonical vacuous theorem, which is
exactly the failure mode §3 is about. The two critiques meet here.

**Where we sit:** we are not even in "decide which." We have a strong conjecture (the ABC
community's well-founded prior that WMotR-A-free is impossible) and we formalize a proof of *that
one safety direction* via an invariant — not a state-space search. If the conjecture were wrong,
Φ would simply fail to be provable, and the burden would flip to exhibiting the concrete A-free
flight. Proving a believed direction is how most theorem-proving works; it is a strictly easier
framing than "you don't get to assume which way."

## 3. "A compiling proof ≠ a true fact" (autoformalization / "Did you prove it?")

**The claim.** A proof assistant certifies only "this proof derives this statement." It says
nothing about whether the statement *means* what you intended or corresponds to reality. So a
green checkmark — even with no `sorry` and no hidden axioms — is empty unless you can read and
understand the statement and its definitions. Therefore "throwing tokens" at it cannot, by itself,
yield the real-world assurance you want.

**This is correct, and we concede it fully.** The resolution is a partition:
- **Workflow A:** a human writes/understands the *statement*; the machine generates the *proof*.
  Kernel checks the proof; human checks the statement.
- **Workflow B:** the machine generates *both*, and the human reads neither.

The critique is a fatal description of **B**. It says nothing against **A** — which is the only
sound workflow, AI or not, by the de Bruijn principle:

> **The proof is the part you do NOT have to trust (the kernel checks it). The statement is the
> part you DO have to trust (so you must read it).**

An LLM emitting a 200,000-line proof of a 10-line statement you understand is therefore the
*ideal* division of labor, not a threat. We assign ownership exactly along that line: **humans own
the statement; tokens may own the proof.** The intermediate results are deliberately built as
readable statements — e.g. `flying_setters mario.prog = [set_jump_from_landing]` literally says
"exactly one function here passes a flying constant to a call," checkable by eye. That is the
opposite of Workflow B.

**The honest residue (where the critic stays right):**
1. **Statement-means-intent is irreducibly human.** No machine certifies that
   "`action ≠ ACT_FLYING`" captures "you can't fly." Mitigations: keep the statement tiny and
   concrete (a specific memory value); corroborate empirically against an emulator; provide a
   literate rendering for domain experts. The gap shrinks, never reaches zero — and we never claim
   it does.
2. **The model definitions are themselves an audit surface.** Our statement references `frame_step`
   (a model of one frame) + an input model. If those are large and unread, the critique bites
   *fully*. Hence `frame_step` is treated as **the** artifact humans must read, grounded line-by-line
   in real code ([the-frame.md](the-frame.md)), and the analysis machinery is forbidden from the
   statement (import restriction) so the reviewer's burden is the model + win condition, not the tooling.
3. **The TCB is real and scopes the claim.** What we prove is a statement *in CompCert-Clight
   semantics of the decompiled C* — not literally the N64 ROM. `clightgen`, CompCert's semantics,
   and the decomp-vs-IDO seam are trusted. The honest claim is narrow and explicit; never
   "Mario can't fly on real hardware, QED."

**Guardrails, per failure mode:**
- *Vacuity* (trivially-true because hypotheses can't hold) → a required **non-vacuity witness**
  (flying *is* reachable *with* A; `FrameTrace.v` ships this).
- *A statement that means something weaker* (the `reaches` vs `reaches_static` trap) → keep the
  statement's vocabulary tiny; analyses connect only via soundness lemmas *inside* the proof, where
  being wrong makes the proof *fail* rather than the theorem *lie*.
- *Notation/coercion games* → review with `Set Printing All`.
- *Hidden gaps/axioms* → `Print Assumptions` (every axiom/admit in the whole tree). Note this is a
  *proof-completeness* check; it does **nothing** for statement-correctness — a separate gap needing
  a separate tool (reading the statement).

## 4. "Does SM64 have memory leaks?" — No, and the reason helps us

Verified in the code: **no `malloc`/`free`/`calloc`/`realloc`** in the game/engine (the "free"
hits are all the *word* free — free lists, free-roam camera, comments). Instead:
- the **object pool is a fixed static array** `gObjectPool[OBJECT_POOL_CAPACITY]` (240,
  `object_list_processor.c:69`), every slot reset to `ACTIVE_FLAG_DEACTIVATED` on init (:549–551);
  objects are handed out from a free *list* threading that one fixed array — it never grows;
- the general allocator (**`main_pool`**, `memory.c`) is a **two-headed bump/stack allocator**
  (`sPoolListHeadL`/`R` growing inward), `main_pool_alloc`/`_free`/push-/pop-state — fixed footprint
  set at boot, reset at level boundaries.

A canonical leak needs dynamic allocation + a lost reference + **unbounded** accumulation. None of
the three is present; the worst case is *pool exhaustion* (a bounded, immediate alloc failure), not
slow growth. Terminology fix: it is **not** "everything on the heap" — there is no growing heap;
memory is static globals/BSS plus a fixed-size pool.

What SM64 *does* have is **corruption/aliasing within fixed-size regions** — stale pointers / slot
reuse (Spiny Adoption: `parentObj` into a deactivated-then-reused slot = use-after-deactivation),
union type-punning via `rawData`, OOB via glitches. Those are *contents* problems in a fixed
layout, not *lifetime* problems. (See [object-set-and-glitches.md](object-set-and-glitches.md).)

**Why it helps the proof.** In our fixed-array + freely-aliasing-pointers model, "leak" is not even
an expressible concept — there is no allocator state that grows over time, no allocation-lifetime
bookkeeping to verify. We reason only about the *contents* of a fixed, bounded chunk of memory under
a frame-step invariant. The absence of `malloc` removes an entire class of difficulty (unbounded
heap growth, allocator-metadata correctness over time) that we would otherwise have to model.

## Standing rules distilled (the discipline these critiques imply)

1. **Humans own the statement; tokens may own the proof.** Never let anything unread end up in the
   statement *or its definitions* (`frame_step`, the input/win model). This is the line between the
   sound and unsound workflows.
2. **Prefer impossibility/safety phrased for sound over-approximation.** That is the
   complexity-class discount that separates this from "verify arbitrary C." Coarse-but-sound beats
   precise-but-unbuildable.
3. **Per gate in any chain, ask: explicit input/flag guard, or physical-state reasoning?** The
   former is cheap; the latter is where the project could genuinely stall. Watch for it.
4. **The model and the TCB are the audit surface.** Spend human review there, not on proof bodies;
   keep both small and grounded in `file:line`.
5. **Scope every claim honestly:** "*this* statement, *these* definitions, under CompCert-Clight
   semantics of the decomp" — plus a non-vacuity witness and `Print Assumptions`. Never inflate it
   to "on real hardware."
