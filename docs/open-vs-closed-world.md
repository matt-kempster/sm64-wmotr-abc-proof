# Open- vs. closed-world reasoning, and the honest decidability boundary

Two related questions came up:

1. The Tier-2 toy preservation claim needed an *assumed* aliasing precondition
   ("`o` doesn't point at `gUnrelated`"). That's unsatisfying. A guaranteed
   entrypoint makes it go away — why?
2. Is the eventual soundness lemma secretly Gödel/Rice-impossible, and was the
   earlier framing immodest about it?

This doc answers both, and records what we actually proved.
See also [two-axes-syntactic-vs-semantic.md](two-axes-syntactic-vs-semantic.md).

## Why the precondition existed, and why an entrypoint dissolves it

Reasoning about `set_timer(o)` *in isolation* universally quantifies `o` — "for
**any** pointer `o`…", which includes the pathological `o = &gUnrelated`. The
precondition `b_o <> b_gUnrelated` is you manually carving that case back out. It
feels circular because you're assuming part of what makes the conclusion true.

With a guaranteed entrypoint, `o` is no longer arbitrary — it is whatever the
call sites actually pass, so the pointer acquires **provenance**, and
non-aliasing stops being an assumption and becomes a **derived fact**:

- `set_timer(&obj)` for a stack local `obj`: that block comes from `Mem.alloc`
  during execution, which CompCert guarantees is **fresh** — distinct from every
  previously-allocated block, and the globals were all allocated first (in
  `init_mem`). So `b_obj <> b_gUnrelated` falls out of **allocation freshness**.
- `set_timer(gObjects[i])` pointing at a different global: distinct globals ⇒
  distinct blocks (`Genv.find_symbol` injective). Again derived.

The precondition didn't vanish; it got **discharged** by knowing where the
pointer came from.

## The two regimes — and why the endgame forces the closed-world one

- **Open-world / modular:** reason about a function in isolation, *assuming*
  preconditions on its parameters. Composable, but each assumption is a debt to
  repay at every call site — and against a truly arbitrary caller you simply
  cannot.
- **Closed-world / whole-program:** fix the entrypoint, then *prove* an
  invariant over **all reachable states**. No free assumptions; the
  "preconditions" become theorems about reachability.

The punchline: the endgame impossibility theorem is **inherently** closed-world.
"No no-A trace reaches `starCollected`" means "over all states reachable from
the game's entrypoint, this never holds." You cannot phrase an impossibility
result with free preconditions about intermediate state without begging the
question ("Mario can't get the star, assuming he's in a state where he won't").
This is the same shape the design conversations reached for `gObjects[10]` never
equaling `QUX`: not a Hoare triple with assumptions, but a quantification over
whole-program executions.

## What we actually proved (and what we did NOT)

`proofs/ToyReach.v` proves, fully machine-checked, no `Admitted`, **no aliasing
precondition**:

```coq
Theorem store_to_fresh_preserves_existing :
  forall chunk m b_fresh ofs v m' chunk' b_glob ofs',
    ~ Mem.valid_block m b_fresh ->     (* fresh: just allocated *)
    Mem.valid_block m b_glob ->        (* already existed, e.g. a global *)
    Mem.store chunk m b_fresh ofs v = Some m' ->
    Mem.load chunk' m' b_glob ofs' = Mem.load chunk' m b_glob ofs'.
```

This is the **semantic crux** of the closed-world argument: the distinctness of
`b_fresh` and `b_glob` is *derived* from `valid_block` vs. `~ valid_block`, not
assumed. It is a fact about CompCert's real memory semantics, not about our
analysis function.

It is **not yet** the whole-program theorem "after `main` runs, `gUnrelated <>
7`." Lifting it requires wiring through CompCert's `eval_funcall` =
`function_entry` (`alloc_variables`, which produces the fresh block) →
`exec_stmt` (the store) → `free_list`, plus reading `gUnrelated`'s initial value
out of `Genv.init_mem`. That is mechanical but lengthy, and is the declared next
step — deliberately not faked with an `Admitted`. (`experiments/toy/toy.c` now
has the `main` entrypoint this lift will target.)

## Is the soundness lemma Gödel/Rice-impossible? No — but here's where undecidability really bites

Rice's theorem (no algorithm decides any nontrivial semantic property of
arbitrary programs) and the halting problem are real. If the goal were "a
decision procedure giving the *exact* set of globals any function preserves,"
that is impossible. But that is not the soundness lemma. The escape is an
asymmetry:

```
soundness:  writes_global f g = false  ->  execution of f preserves g
```

This is a **one-directional implication**, and the analysis is **conservative**:
it may answer `true` ("maybe writes") whenever unsure. An analyzer that returns
`true` for everything is *trivially sound* (it just proves nothing). Rice
forbids **precision**, not **soundness**. We deliberately surrender precision
(the docs' "unknown → havoc" rule). Therefore:

- **Soundness is provable, not Rice-blocked.** It is a theorem about *our
  function composed with CompCert's semantics*, proved by **induction on the
  operational semantics** — not a decision procedure over arbitrary programs.
  The existence proof that this class is achievable is CompCert itself: its
  ~100k-line machine-checked refinement theorem is far harder than ours, and we
  build on top of it. seL4, FSCQ, Verdi are the same shape.

- **Where Rice/halting actually bites is completeness.** There will be real SM64
  functions that *do* preserve a global but where proving it needs deciding
  something undecidable (e.g. "this loop counter never hits 12"), so a sound
  analysis is *forced* to answer "Unknown/havoc." We don't get a wrong answer —
  we get a useless-for-that-case one.

- **Where Gödel-proper bites is the trusted base, unavoidably but not
  specially.** Gödel's second theorem means Coq's kernel cannot prove its own
  consistency, so every theorem rests on "assume CIC is consistent." That is the
  floor under all proofs, not an extra obstruction to this one (it is why
  Lean4Lean / external checkers exist).

- **We only ever phrase SAFETY properties** (an inductive invariant over
  reachable states — "bad state never reached"), never liveness/termination.
  Safety invariants don't require deciding halting. This is a structural reason
  the project isn't doomed — and a constraint on what we may state.

### The honest correction

Calling the WMotR endgame merely "weeks-not-minutes labor" was immodest. Split
it:

- **`writes_global` soundness (with havoc):** genuinely just labor — bounded,
  standard, definitely provable.
- **The WMotR impossibility endgame:** **real research risk; it may not be
  reachable.** Not because it is logically impossible (if Mario genuinely cannot
  get the star, a witnessing invariant exists), but because a *sound* analysis
  precise enough to discharge it may demand an impractical amount of bespoke
  invariant engineering. The failure mode is "our conservative analysis keeps
  saying Unknown exactly where we need a real answer, and closing the gap by hand
  doesn't scale" — not "undecidable." That is the genuine risk, flagged plainly.
