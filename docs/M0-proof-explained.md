# Milestone 0: where the proof actually lives

A natural first confusion: `generated/toy.v` is 424 lines long — so where's the proof?

**It isn't in `toy.v` at all.** That file is the *generated* artifact (the Clight AST),
and per our pipeline convention it contains no proofs — it's pure data. The proof lives in
`proofs/ToyFrame.v`. There are three layers.

## Layer 1: `generated/toy.v` is *data*, not proof

Those 424 lines are CompCert's translation of `toy.c` into a Rocq **value** — the
program's syntax tree. Most of the file is boilerplate declarations of `__builtin_*`
functions; the parts that matter:

- Each C name gets a numeric `ident`:
  ```coq
  Definition _clobber    : ident := $"clobber".
  Definition _gUnrelated : ident := $"gUnrelated".
  ```
- `clobber`'s body, as a tree:
  ```coq
  Definition f_clobber := {| ...
    fn_body := (Sassign (Evar _gUnrelated tint) (Econst_int (Int.repr 7) tint)) |}.
  ```
  Read that as: "a `Sassign` (assignment statement) whose left side is `Evar _gUnrelated`
  (the variable `gUnrelated`) and whose right side is the constant `7`."
- `set_timer`'s body is a `Sassign` into
  `(Efield (Ederef (Etempvar _o ...)) _timer ...)` — i.e. `o->timer = 0`. Note its l-value
  is rooted at `_o` (a parameter), **not** at any global.

No `Theorem`, no `Proof`, no `Qed` anywhere in the file. That's intentional: generated
files are inert data that proofs are written *against*.

## Layer 2: the analysis (`ToyFrame.v`)

A small **computable function** — ordinary functional code, still no proof yet. It walks
the syntax tree and answers one yes/no question: *does function `f` contain a direct
assignment to global `g`?*

- `lvalue_global`: given the left-hand side of an assignment, peel off `Ederef`/`Efield`
  and see whether it bottoms out at an `Evar` (a global). For `gUnrelated` →
  `Some _gUnrelated`. For `o->timer`, the root is `Etempvar _o`, which isn't an `Evar`, so
  → `None`.
- `writes_global_s`: recurse over the statement tree. At an `Sassign`, check if its
  l-value root equals `g`. At sequences/ifs/loops/switches, recurse into the branches and
  OR the results. Everything else → `false`.
- `writes_global`: apply that to a function's body.

## Layer 3: the actual proofs (`ToyFrame.v`)

The two theorems (Rocq calls them `Example`):

```coq
Example clobber_writes_gUnrelated :
  writes_global f_clobber _gUnrelated = true.
Proof. reflexivity. Qed.

Example set_timer_does_not_write_gUnrelated :
  writes_global f_set_timer _gUnrelated = false.
Proof. reflexivity. Qed.
```

Each states an equation: "running our analysis on this generated function gives this
boolean." The proof is the single tactic **`reflexivity`**.

Why does `reflexivity` work? Because everything here is *computation*, not abstract
reasoning. `writes_global f_clobber _gUnrelated` isn't an opaque symbol — Rocq can actually
**evaluate** it: it unfolds `f_clobber` (from `toy.v`), sees `Sassign (Evar _gUnrelated
...) ...`, runs `lvalue_global` → `Some _gUnrelated`, compares it to `_gUnrelated` with
`Pos.eqb` → `true`. So the left side *reduces to* `true`, and `true = true` holds by
reflexivity. `Qed` makes the kernel re-check that reduction. If the analysis had computed
`false`, `reflexivity` would simply fail and the file wouldn't compile.

So the "proof" is really: **Rocq's kernel mechanically evaluated our analysis over the real
generated AST and confirmed the answers.**

## The honest caveat

What we proved is **syntactic**: "the analysis function returns these booleans." We have
*not yet* proved the semantic statement that would actually matter for Mario — "because
`set_timer` syntactically doesn't write `gUnrelated`, running it can never change
`gUnrelated`'s value." Connecting `writes_global f = false` to a real preservation
guarantee against CompCert's Clight operational semantics is **Milestone 2**. M0 only
proves the *pipeline* works: generate → load the AST → compute over it → kernel-check the
result. The `writesOf`-checked-by-`reflexivity` shape is exactly the one the design docs
call for; M0 establishes it at toy scale.
