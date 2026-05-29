# Pointer writes, block disjointness, and why leak #1 is not gargantuan

> A faithful capture of a back-and-forth about the scariest conservativeness leak in the
> frame analysis: indirect/pointer writes (`*p = …`, `arr[i] = …`). The fear was that a
> sound frame summary for SM64 would require proving *every* pointer write in the codebase
> "well-behaved" — a gargantuan amount of code. It doesn't. This doc records why, and where
> it genuinely does get hard. See also
> [two-axes-syntactic-vs-semantic.md](two-axes-syntactic-vs-semantic.md) and
> [open-vs-closed-world.md](open-vs-closed-world.md).

## The setup: the two halves of the WMotR-style argument

The intuition behind "WMotR is not 0xA" is `grep`-shaped:

> "Symbol `S` is only manipulated in these few places; you can't reach those places; so `S`
> keeps its initial value; so the thing it gates never happens; QED."

That factors into two claims that multiply:

1. **Sole-writer (frame):** the only program points that write `S` are P₁…Pₙ — a
   structural `grep`, not a textual one.
2. **Unreachability (callgraph):** under the ABC constraints, none of P₁…Pₙ is reachable
   from the entrypoint.

The current `writes_global` (Frame.v) is the toy core of half 1, but it only sees
`Sassign` whose l-value is rooted at an `Evar`. Three leaks make it not-yet-sound for the
impossibility *direction*:

1. **Indirect writes** — stores through pointers/arrays (root is `Ederef`/`Ebinop`) are
   missed.
2. **Function pointers** — indirect calls have no static `Evar` target.
3. **Closed world** — `prog` is one TU; "only writer in the program" needs every TU plus
   externals/builtins.

This doc is about leak #1, the one that looked fatal.

## The fear, stated plainly

SM64 writes through pointers *constantly* — `obj->field = …`, `gMarioState->… = …`,
`sp->… = …`. If soundness required showing each such write lands where it's "supposed to,"
we'd be hand-verifying essentially the whole game. Not viable.

## The reframe: you never prove pointer writes well-behaved. You prove the *target* unescaped.

CompCert's memory model is **block-based**. Every global, every stack variable, every
allocation is a distinct numbered block. A store through pointer `p` can only affect block
`b` if `p` *actually holds an address in block `b`*. **Distinct blocks do not alias — that
is free, by construction.**

So flip the question:

- ❌ "Is this write well-behaved?" — asked thousands of times, once per write.
- ✅ "Can the address of the gating symbol `S` ever end up in *any* pointer at all?" —
  asked **once**, about `S`.

The payoff:

> If `&S` is **never taken** anywhere reachable under ABC, then **no** pointer write in the
> entire program can touch `S`, regardless of how many such writes exist. They are all
> storing into other blocks. The thousands of `obj->field = …` are simply *irrelevant to
> `S`*.

The cost therefore scales with **how aliased `S` is**, not with how many writes the program
contains.

Mechanically: the sound over-approximation is *"a store through a pointer may hit any block
whose address has escaped."* Cheap to **state**. The discharge for a specific `S` is **"`S`
never escapes"** — an address-taken scan, much closer to `grep` than to a correctness
proof.

## We have already done the core move once

`proofs/ToyReach.v`'s `store_to_fresh_preserves_existing` proves a store to a not-yet-valid
block preserves an already-valid block, with distinctness *derived* from
`Mem.valid_not_valid_diff` — i.e. "different blocks, so the write cannot reach you,"
composed via `Mem.load_store_other`. That **is** the pointer-disjointness argument in toy
form. Scaling it up is swapping the discriminator "fresh vs. valid" for "escaped-set vs.
`S`."

## The honest residue: where block separation is *not* enough

Block-based separation collapses the easy case — a plain global flag whose address is never
taken. It does **not** save you in two regimes:

1. **Gate lives in a runtime-indexed pool/array** — `gObjectPool[i].rawData[…]`. Now
   disjointness is not "different block," it is "different *index in the same block*," which
   needs reasoning about the index *values*, not just provenance.
2. **Gate lives behind a heavily-aliased struct** — `gMarioState->…`, object fields reached
   through pointers passed everywhere. Then `&S`-equivalent addresses genuinely flow into
   the soup, and you have a real points-to problem.

Much of SM64's interesting state is in regime 2 (object fields, Mario state). So the
question that decides "tractable" vs. "gargantuan" is not about pointer writes in the
abstract — it is: **which symbol does the property actually gate on, and is it a separable
global or buried in the object pool / behind aliased structs?**

## What the WMotR argument actually needs (per the project's plan)

There is no single gating symbol. The argument, roughly:

- In WMotR you must collect the 8 red coins to spawn the star.
- To collect all 8, you must collect the lowest and the highest.
- That forces **bounds arguments about all code that can modify Mario's y-value**: given
  Mario's vanilla moveset and the dearth of objects in WMotR, he cannot generate enough
  energy to make those code paths raise his y enough to reach the highest coin.
- Therefore you cannot get both coins. QED-shaped.

That "energy bound on Mario's y" is the super-hard step (punted for now). Note this lands
squarely in **regime 2**: Mario's y-position lives behind `gMarioState`/object structs, so
the cheap address-not-taken discharge will *not* apply directly. The frame/escape machinery
buys us the *structural* half (which code can touch y at all); the bound itself is a
separate, harder quantitative argument over the moveset.

## Proposed next concrete steps (smallest-first)

1. **Escape / address-taken analysis** (syntactic, `reflexivity`): scan for
   `Eaddrof (Evar S …)` and array-decay uses of `S`. Headline: "`S`'s address is never
   taken in shadow.c," honest about the array/aggregate-decay subtlety.
2. **Havoc frame lemma, proved once:** a store through any pointer preserves `S` *given*
   `S ∉ escaped`. This is `store_to_fresh_preserves_existing` generalized from "fresh" to
   "non-escaped."

These build the cheap regime end-to-end. Regime 2 (Mario y) is acknowledged as the real
research risk and is deliberately deferred.
