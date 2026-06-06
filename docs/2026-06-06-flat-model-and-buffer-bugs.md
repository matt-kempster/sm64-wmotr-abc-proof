# The flat-memory model: what CompCert assumes for us, and how to weaken it

> A faithful capture of a 2026-06-06 back-and-forth about the scariest *semantic* gap
> in the project: CompCert's block-structured memory model silently rules out
> buffer-overrun-style bugs, and SM64 is full of those. This doc is deliberately
> **upfront about what CompCert is assuming on our behalf**, why that matters for an
> A-Button-Challenge result, and what a migration to a flat (single-layout, concrete)
> memory model would actually entail — framed as a *dial* we can turn down monotonically,
> not a burn-it-down rewrite. See also [trust-model.md](trust-model.md),
> [two-axes-syntactic-vs-semantic.md](two-axes-syntactic-vs-semantic.md),
> [pointer-writes-and-block-disjointness.md](pointer-writes-and-block-disjointness.md),
> [theorem-scope.md](theorem-scope.md).

---

## 0. The question that started it

> A common bug in C programs is buffer overflow. In this proof, are we *assuming* no
> buffer overflow, are we *proving* it, or somewhere in between?

**Somewhere in between — in a precise way that is worth pinning down**, because it's the
one place where "the proof is about SM64" quietly becomes "the proof is about the
*defined-C model* of SM64."

---

## 1. What CompCert assumes for us (the honest ledger)

CompCert's memory is **block-structured**. Every allocation — every global, every
local, the object pool, the surface pool — is its own mathematically **disjoint** block,
addressed by `(block, offset)`. There is no flat address space. Two consequences, and
both are *assumptions handed to us for free*:

1. **Disjointness is total and automatic.** `gObjectPool` and `gMarioStates` are
   different blocks, so **no write through one can ever land in the other** — not because
   we proved it, but because the model has no way to express it. This is the workhorse
   behind our entire anti-aliasing story (block-distinctness hypotheses `bc ≠ bm`,
   "globals aren't Mario's block", the R6 pointer-chase closure). It is doing enormous
   load-bearing work *for* us.

2. **Out-of-bounds access is `stuck`, not corrupting.** Computing `&gObjects[51]` on a
   50-element array is fine, but the load/store *through* it has **no semantic rule**.
   The formal execution simply has no next step — the derivation tree ends. Not "writes
   the neighbor," not "crashes." It just stops.

Our theorem quantifies over **all executions the semantics admits**. So an execution that
would need that OOB write doesn't *exist* past the stuck point — it is covered vacuously.
That is the "in between":

- We do **not** assume no-overflow as a hypothesis. We never write `Hypothesis
  no_overflow`. ✔
- For the cells we actually watch, the walks **prove genuine no-wild-write facts**: every
  store in every walked body is pinned to a concrete block + offset window and shown to
  miss the action cell. That part is *proved*, store by store. ✔
- But any strategy that *relies on* a stuck (OOB) transition is **outside the quantifier**
  — neither proved safe nor proved dangerous. It's simply **out of model scope**. ⚠️

Slogan: **within the C model it's proved; outside the C model it's out of scope,
explicitly — never silently assumed.** The danger is only if someone *reads* "no-A ⇒
no-fly" as a claim about the N64 rather than about Clight-over-block-memory.

---

## 2. Why this matters for SM64 specifically

This is not a hypothetical corner. The most *interesting* potential ABC frontier is
exactly the OOB class:

> If there were a bug where the game does `gObjects[i]` with `i` pushed out of bounds, and
> `m->action` happens to live exactly where `gObjects[51]` lands, then **no-A ⇒ no-fly
> might genuinely become FALSE** — and our current theorem would say nothing about it,
> because that run is stuck/out-of-scope.

We must **not foreclose** that. The goal of weakening the model is to let the proof
eventually *adjudicate* such a candidate — possibly proving no-fly survives it, possibly
proving it **breaks** no-fly (which would be the most interesting outcome of all) —
instead of structurally assuming it can't happen.

### A correction on terminology (important)

Two things were conflated in the conversation and must be kept apart:

- **Buffer overrun / OOB access** — needs only the *flat structure* of memory: that
  `gObjects[51]` lands on whatever physically sits next to the array. This is the class
  the flat model directly addresses.
- **Arbitrary Code Execution (ACE)** — strictly **stronger**: it treats *code as data*,
  redirecting the instruction pointer (e.g. via a corrupted jump-table index) to execute
  attacker-chosen bytes as instructions. ACE *uses* OOB as a primitive but goes beyond a
  flat data model into control-flow hijack.
- **And a factual note:** as of this writing, **ACE has not been found in (unmodified,
  no-external-hardware) SM64.** It is established in other N64 contexts and is actively
  hunted, but citing "SM64 ACE" as a known exploit is an overclaim. What unambiguously
  *does* exist in SM64 is the OOB/buffer-style class. The flat model is aimed at *that*
  class; ACE would additionally require the ISA floor (§7).

---

## 3. The escape route, level by level

Is the OOB gap hopeless? No. Three escalating options.

**(a) Prove the stuck states unreachable (stay in CompCert).** Prove that under no-A
inputs, every array index is in-bounds, every deref valid. Then "defined runs only" stops
being a caveat, because *all* runs are defined. This is classic memory-safety verification
— harder than our current "this store misses that cell" walks (it needs arithmetic
invariants on indices), but it's the principled within-model answer. Note the dual use:
for a *known* bug you'd instead prove `i` **can** reach 51 — formally certifying the bug.

**(b) A single-layout *concrete* (flat) model — the main subject of this doc.** Replace
block memory with flat N64 RAM: memory is bytes at concrete addresses, and `gObjects[51]`
reads *whatever actually sits next to the array* — which is **knowable**, because the
matching decomp fixes the exact link map (see §4).

**(c) Drop to the MIPS ISA.** Maximum fidelity, zero UB, but our entire C-structure-aware
walker becomes useless. The "burn it down" option; noted for completeness (§7).

---

## 4. Why a *single-layout concrete* model — and why not CompCertS

The naive thought is "use CompCertS" (CompCert with pointers-as-integers). **It doesn't
give us what we need.** To preserve *compiler freedom*, CompCertS quantifies over **all**
valid memory layouts: a value is only defined if it means the same thing under *every*
compatible block placement. But "what's adjacent to `gObjects`" is *exactly* the thing
that differs between layouts — so the corrupting access **still** doesn't get a useful
defined semantics. CompCertS legalizes pointer↔int casts and arithmetic, not cross-object
corruption. (It's also a research fork of a much older CompCert; porting to our
3.15 / Coq-8.19 pipeline would itself be a project.)

What we want is the **opposite** move: **pin one single layout** — the real N64 link map —
and interpret the *same* Clight ASTs over flat RAM at those concrete addresses.

This is tractable for SM64 in a way it would be **hopeless** for a normal C program,
because the **matching decomp** fixes a single, total, byte-exact layout:

- RDRAM is one flat array (`0x80000000`–`0x80400000`, 4 MB; 8 MB with the Expansion Pak).
- The linker map (`sm64.map`) assigns **every** symbol an absolute address — `gMarioStates`,
  the object pool, the surface pool, the gfx pools — byte-exact, because the build
  reproduces the ROM.

So in a flat model, `&gObjects[51]` isn't "undefined neighbor"; it's a **computable
address**, and "what lives there" is a `vm_compute` over the map: the symbol whose range
contains it. If that address overlaps `gMarioStates.action`, the flat semantics says —
concretely, provably — that the write lands on Mario's action field. **The nightmare
scenario stops being hand-waved and becomes a theorem the model can state.**

---

## 5. The reframe that satisfies "continually weaken the model": a *dial*, not a switch

"Migrate to a flat model" sounds like a one-time jump that invalidates everything. The
better architecture — and the one that honors *never foreclose the OOB case* — makes the
watched-memory boundary a **parameter you turn down monotonically.**

Today the model has a hard binary: accesses are either *defined* (in-bounds, block-local)
or *stuck* (OOB), and the capstone quantifies over defined runs. Replace that binary with
a **region predicate** `Defined : addr → Prop` naming *which* flat addresses currently
have honest semantics. The theorem becomes: *for every run staying within `Defined`,
no-fly.*

- **Dial at minimum** = today's proof. `Defined` = "every access in-bounds in its block."
  All current block-model work is the instance at this setting.
- **Turning the dial up** = enlarging `Defined` to cover specific OOB sites with their
  *real flat behavior*. Each turn is **additive**: not redoing prior work, but shrinking
  the "stuck / out-of-scope" residual.
- **Dial at maximum** = full flat RDRAM, `Defined` = everything, zero stuck states — the
  honest no-UB endpoint (for memory; see §7).

This *is* "continually weaken the CompCert model": a sequence of monotone steps, each
moving a class of behaviors from *assumed-impossible* to *modeled*, with no-fly re-proved
at each setting. You never declare `gObjects[51]` impossible — at worst it's *currently
outside `Defined`*, a **named** address region, with a defined procedure to pull it inside.

> **The one rule we refuse to break:** never bake "OOB impossible" in as a silent
> assumption anywhere load-bearing. The dial framing makes this structural — every gap is
> a *named* region outside `Defined`, never a hidden `Hypothesis`.

---

## 6. What a migration actually costs (the ledger)

The proof splits into two strata (cf. [two-axes-syntactic-vs-semantic.md](two-axes-syntactic-vs-semantic.md)).

**Syntactic stratum — survives verbatim.** All Clight variants share the same AST;
`clightgen` output is unchanged. Every `vm_compute` pin, census, walk check, gate census,
params-shape lemma — i.e. the **bulk of the line count and *all* of the recent grind** —
is a statement about syntax trees, not memory. Untouched by a memory-model swap.

**Semantic stratum — this is what swaps.** Everything mentioning `Mem.load`/`Mem.store`/
`Vptr`: the MWF rows, the walker's preservation lemmas, the frame rule (`MWF_real_transfer`).
Notably, **some of it gets *easier***: our block-distinctness hypotheses (`bc ≠ bm`,
"globals aren't Mario's block") are *currently assumed residuals* — with a pinned link map
they become **computable** disjoint-interval facts. The dial **removes** trust here, it
doesn't add it.

**The migration shape (additive, not a rewrite):**

1. Keep the block-model proof as the workhorse — exactly what we build now.
2. Prove **one bridge theorem**: *while a run stays in `Defined`, flat-RAM semantics and
   block semantics produce the same trace.* This is the single hard new artifact — a
   CompCert-style simulation/refinement proof, genuinely multi-month — but proved **once**.
   The ~200 walked bodies *feed* it: each walk already proves "this store lands at block
   `b`, offset window `[d, d+sz)`" — that **is** the in-`Defined` side condition the bridge
   consumes. The current grind is the *input* to the flat future, not wasted by it.
3. Restate the capstone over the flat semantics via the bridge.
4. Any genuinely-OOB site that matters gets handled **locally** in the flat model, named,
   with the actual neighbor symbol identified — turning the dial exactly far enough to
   adjudicate that candidate.

**What's irreducibly new per dial-turn:** for each OOB site pulled into `Defined`, you lose
block-disjointness as the anti-aliasing hammer *for that site* and are back to interval
arithmetic over concrete addresses. Manageable site-by-site — which is precisely why it's
a dial and not a flip.

**Make the proof dial-ready now (cheap):** state `body_pres`/`MWF` against an abstract
`Defined`-style region rather than hard-coding "block-local," so the flat extension is a
*re-instantiation*, not a refactor. We're already most of the way there — the invariant is
parameterized over `NoA`/`MWF`, and the walks already emit per-store address-range facts.

---

## 7. The boundary that remains even at max dial (two no-UB thresholds)

"No UB" has **two** thresholds, and the flat model only crosses the first:

1. **Flat memory** (this doc): defined *memory corruption*. `gObjects[51]` has a real,
   computable effect. Buffer-overrun-class bugs become statable and adjudicable.
2. **MIPS ISA** (the §3(c) floor): defined *everything*. Cache coherence, the
   data-cache-writeback tricks real ACE chains rely on, DMA, branch-delay slots, MMIO —
   these live **below** even flat-C. The flat model does **not** model them.

So: the flat model gets us confidence about **buffer-style / OOB data bugs**. It does
**not** get us ACE (which needs code-as-data + the ISA floor). Be precise about which
threshold any future claim is standing on.

---

## 8. Bonus: is this reusable for a B-Button Challenge?

Mostly yes, by design — the stack already splits into a button-agnostic carrier and a thin
A-specific layer:

- **Reusable near-verbatim:** all leaf-family walk lemmas are stated over *abstract*
  `NoA`/`MWF` predicates (`body_pres lp NoA MWF bm f` takes the invariant as a parameter).
  The 200+ walked bodies, the walker, DispatchKit, the chase/window/global store rows,
  `MWF_real_transfer`, the block/layout machinery — none of it mentions the A button.
- **B-specific (same shape, new constants):** the taint set `T` (→ `T_B` = B-gated
  actions), the controller bit masks `input_a_clear`/`ctl_a_clear` (→ `input_b_clear`, a
  different bit), and the gate census in `AGates.v` (different press-check sites, identical
  kill pattern).
- **One structural caveat:** this machinery proves **impossibility** (safety). BBC
  questions of the form "*X is impossible without B*" reuse it directly. Questions of the
  form "*X is still possible without B*" are existence proofs — you'd exhibit an input
  trace, a different and much easier kind of theorem.

---

## 9. Recommended stance for the project

- Keep grinding the **block model** now — it's what makes the remaining ~199 leaf proofs
  tractable, and it's the prerequisite/input for *either* future. Nothing current is
  wasted.
- Build **dial-ready** (abstract `Defined` region) so the flat extension re-instantiates
  rather than refactors.
- Treat the **flat-model bridge** as a named, deferred arc — opened when a *specific*
  ABC-relevant OOB candidate surfaces, then turned exactly far enough to adjudicate it.
- **Never** encode "OOB impossible" as a load-bearing assumption. Every memory-model gap
  stays a *named region*, visible in the statement — consistent with the project's whole
  trust story ([trust-model.md](trust-model.md)): you audit the *statement*, so the
  statement must wear its scope on its sleeve.

### Cross-references / sources
- SM64 link map (absolute symbol addresses): `sm64.map` in the decomp / aglab2's mirror.
- N64 RAM map: Hack64 wiki `super_mario_64:ram_memory_map`.
- ACE background (note: N64-general, *not* a known unmodified-SM64 exploit): TASVideos
  `ArbitraryCodeExecutionHowTo`; `shogihax` (N64 RCE via Morita Shogi 64).
- Related research models: CompCertS / quasi-concrete memory (Kang et al.) — discussed in
  §4 as *not* the right fit, vs. the single-layout concrete model we actually want.
