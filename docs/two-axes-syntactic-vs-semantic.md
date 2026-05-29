# Two axes: syntactic vs. semantic, and sound over-approximation

> A note unpacking the M0 caveat: "we have not yet proved the semantic statement that
> would actually matter for Mario — *because `set_timer` syntactically doesn't write
> `gUnrelated`, running it can never change `gUnrelated`'s value*." There are two separate
> issues hiding in that sentence. This doc pulls them apart. See also
> [M0-proof-explained.md](M0-proof-explained.md).

A natural first guess is that the caveat is only about *indirect* writes — that we checked
`Sassign` l-values but not assignments via pointers/indexing/etc. That's a real issue, but
it's a **different** one from the gap being flagged. There are two axes.

## Axis 1: syntactic vs. semantic (what the caveat was pointing at)

This gap exists **even if our analysis were perfect.** Look at what the two `Example`s
literally prove:

```coq
writes_global f_set_timer _gUnrelated = false
```

That is a statement about **our function `writes_global`** — "when you evaluate this
particular Rocq function on this AST, you get the boolean `false`." It is a fact about a
*computation over a data structure*.

It says **nothing whatsoever about what happens when the program runs.** The words "run
`set_timer`," "the value of `gUnrelated`," "memory," "before/after" do not appear anywhere
in the statement. CompCert *has* a formal definition of execution — an operational
semantics, a relation like `step state1 state2` describing how a Clight program transitions
memory states. The theorem that would matter for Mario is phrased in *that* vocabulary:

```coq
(* The semantic statement -- NOT yet proved *)
forall m m' args,
  (* if executing set_timer from memory m produces memory m' *)
  exec_function prog f_set_timer args m m' ->
  (* then gUnrelated has the same value in m' as in m *)
  load m' gUnrelated = load m gUnrelated.
```

The bridge between the two — "`writes_global f g = false` **implies** the semantic
preservation above" — is a theorem we have **not written**. That's the soundness lemma, and
it's the bulk of Milestone 2. Right now `writes_global` is just a function someone wrote;
nothing certifies that its `false` *means* anything about execution. It could have a bug and
return `false` for a function that obviously clobbers everything, and our two `Example`s
would still pass.

So axis 1 is: **we proved facts about our analysis, not facts about Mario's behavior.**
They're connected only by a lemma that doesn't exist yet.

## Axis 2: is the analysis a *sound over-approximation*? (the pointer/aliasing concern)

This is the indirect-write point — and it's exactly the thing that makes axis 1's soundness
lemma **hard or even false** as currently written. Two flavors:

**Indirect writes.** Our `writes_global` only inspects `Sassign` l-values rooted
syntactically at an `Evar`. Consider:

```c
int *p = &gUnrelated;
*p = 99;              // writes gUnrelated, but the l-value root is `p`, not `gUnrelated`
```

`writes_global` returns `false` here — but execution *does* change `gUnrelated`. So the
naive soundness lemma is **outright false** in the presence of aliasing. The `o->timer`
case in `set_timer` is benign (it writes through a parameter we happen to know is
unrelated), but only because *we* know `o` doesn't alias `gUnrelated` — the syntax alone
doesn't tell us that.

**Calls.** We also don't chase `Scall`/`Sbuiltin`. A function whose body is just
`clobber_everything();` returns `false` from `writes_global`, yet wrecks memory. (The
header in `ToyFrame.v` flags both of these as deliberate M0 scope-cuts.)

## How the two axes relate

This is the important part:

- Axis 2 is **why** axis 1 is the whole game. If you naively tried to prove the soundness
  lemma "`writes_global f g = false` ⇒ `g` is preserved," you would **get stuck or find it
  false** precisely at the pointer and call cases. The proof attempt is what *forces* you
  to either (a) strengthen the analysis (track aliasing, summarize callees) until the
  implication becomes true, or (b) make the analysis return a conservative `true`/"Unknown"
  whenever it can't rule out an indirect write — i.e. **over-approximate the write set**,
  never under-approximate it.

- The design docs already anticipate exactly this: the rule is *"unknown calls /
  unclassified writes become havoc (assume they write everything),"* so the analysis is
  **conservative by construction** — it's allowed to cry "maybe written" wrongly, but never
  "definitely not written" wrongly. Only a conservative analysis can have a true soundness
  lemma.

## Bottom line

The caveat was **not (only)** about the missing indirect-write cases. It was about the
deeper fact that *we haven't connected our analysis to execution semantics at all yet* — and
the missing-indirect-writes issue is precisely the obstacle that makes that connection
nontrivial. M0 sidesteps both by only claiming "the analysis computes these booleans on
this toy," where the toy is hand-built so the syntactic answer happens to coincide with the
semantic truth.
