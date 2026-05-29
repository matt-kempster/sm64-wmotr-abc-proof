# Trust model: how will we be confident we proved anything?

> A faithful capture of a back-and-forth on the scariest question in the project: when the
> super-hard proof is eventually thousands of lines long, how does anyone confirm we proved
> *true* reachability and not, say, *direct/static* reachability? A reviewer can't be
> expected to read thousands of lines of Coq and spot a subtle weakening of the statement.
> That would not be acceptable. This doc records the answer and the concrete enforcement
> ideas. See also [pointer-writes-and-block-disjointness.md](pointer-writes-and-block-disjointness.md).

## The reframe that dissolves most of the fear: nobody audits the proof body

The proof's length is irrelevant to trust. **Coq's kernel checks the proof, mechanically.**
The kernel is small (a few thousand lines of well-understood logic), independently
re-implemented by multiple checkers, scrutinized for decades. A wrong proof does not
typecheck — it is *rejected*. The proof body cannot make a false statement true.

Consequence: a 200-line proof and a 200,000-line proof of the *same statement* earn the
*same* confidence. Size costs effort to produce, never trust to consume. (This is the
"de Bruijn criterion": trust rests on a small checker, not on reading the proof.)

What you audit is **the statement** — short by construction.

## The real catch: the statement references definitions

A 20-line theorem can still mention `reaches`, `mario_y`, `coin_collected`, an input model,
a win condition. The `reaches` vs `reaches_static` worry is exactly the failure mode: a
short, innocent-looking statement that quietly means something weaker. So the true audit
surface is:

> the final statement **+ the transitive closure of every definition it names** + the TCB.

That is far smaller than the proof, and it is *declarative* (definitions, not tactic
scripts), hence readable. But it is the thing that must be reviewed by hand.

## The distinction that makes it tractable at scale: trusted vs. verified

Our analyses — `reaches`, `writes_global`, the frame/escape machinery — must **not** appear
in the final statement. They appear only *inside* the proof, as tools, each carrying a
**proven soundness lemma** that connects it to CompCert's real execution semantics (e.g.
"static reachability over-approximates true reachability").

Therefore our analyses are **verified, not trusted.** If `reaches_static` is secretly
weaker than true reachability, the soundness lemma about it is *false* and the proof that
uses it **does not go through** — the kernel rejects it. A buggy analysis is a *failed
proof*, not a false theorem. The thousands of subtle lines being subtle is fine: subtle-and-
wrong gets rejected; subtle-and-right is still right. The only thing the machine cannot
catch is a wrong **final statement**, and that is the short, declarative thing we audit.

## Mechanical backstop against buried admits

`Print Assumptions <top theorem>` prints **every axiom and every `Admitted`** in the entire
dependency tree, at any depth. "Closed under the global context" = zero gaps anywhere. A
single `admit` 40,000 lines deep cannot hide. This is the direct, one-command answer to
"could a subtle gap hide in thousands of lines."

## The irreducible residue (not buried — these are the real limits)

1. **Statement-means-reality is a human judgment.** No machine certifies that "the
   star-collected flag is set" captures "you beat WMotR." We can only make it tiny,
   concrete (a specific memory bit), and reviewable.
2. **The Trusted Computing Base is real:** Coq kernel (cheap); CompCert's Clight semantics
   (the *definition* of execution — peer-reviewed, shared); and **clightgen** (C→AST
   translator — a bug here means we proved things about a different program).
3. **C-vs-ROM gap.** The decomp byte-matches the real ROM under the *original* compiler
   (IDO); we reason under *CompCert's* C semantics, and we pass `NON_MATCHING`/`AVOID_UB`.
   That seam must be documented as an explicit assumption.

## How the residue is made defensible

- **Phrase the top theorem purely in CompCert whole-program execution + a tiny input model**
  (controller bytes per frame, A-bit never set) **+ a tiny win condition** (one memory
  flag). The hand-audit then reduces to three small concrete things.
- **Prove non-vacuity** ("when A *is* allowed, the win *is* reachable in our model") so we
  cannot have accidentally proved an empty precondition (the classic vacuous theorem).
- **Corroborate the win/input model empirically against an emulator** — make those
  definitions executable, confirm "star collected = bit X" lights up exactly when it does
  on hardware. Converts the formal-to-real gap from argument into evidence.
- **A literate rendering** of just the statement + definitions, in TASer/ABC vocabulary,
  for domain experts who can't read Coq but can confirm "yes, that's what winning means."

## Can we enforce this concretely? (vocabulary, not size)

A line-count cap on definitions was considered and rejected as the *primary* control: size
is a gameable proxy (a tiny definition can be wrong; a big one can be split). The real
target is the **vocabulary the statement may mention**. Concrete mechanisms, strongest
first:

1. **Keystone — enforce by imports.** Put the top theorem + model in one file (e.g.
   `proofs/Spec.v`) and **forbid it from importing any analysis module.** If it never
   `Require`s `Frame`/`Reach`, it is physically incapable of naming `reaches` — the name is
   out of scope. Enforcement is a one-line CI check: `Spec.v`'s imports ⊆ {CompCert.*, its
   own model}. Ungameable (you can't name what you didn't import), and just dependency
   hygiene, not Machiavellian. Analyses then connect to the statement only through proven
   soundness lemmas *inside* the proof — exactly where "verified, not trusted" lives.
2. **`Print Assumptions` CI gate** → must be "Closed under the global context."
3. **`Set Printing All` review of the statement** — notations/implicits/coercions can make a
   displayed theorem look like it says something it doesn't (a named failure:
   Pollack-inconsistency). Review with all sugar off to see the raw meaning.
4. **Required non-vacuity witness theorem** — CI requires both impossibility and the
   "reachable when A allowed" witness to compile; weakening the spec into vacuity breaks it.
5. **Soft LOC budget on the spec file** — demoted to a smoke alarm, not a correctness gate:
   if the trusted file suddenly triples, a human looks.

## Worked instance: the R3 invariant Φ is internal; `frame_step` is the audited artifact

The "must press A to fly" temporal proof (R3, see [the-frame.md](the-frame.md)) is proved by
exhibiting a strengthening invariant Φ on Mario's state ("action ∉ the flying-reachable set").
A natural worry: must reviewers read and agree with Φ, lest we prove something vacuous? **No.**
Φ is the *same category* as `reaches`/`writes_global`: a proof-internal tool that **must not
appear in the final theorem**. The harness lemma (`proofs/FrameTrace.v`,
`noA_run_not_flying`) takes Φ only as hypotheses — base case `Φ init`, no-A preservation
`a_pressed i = false → Φ s → step i s s' → Φ s'`, and safety `Φ s → ¬flying s` — and concludes
`noA_run is → reachable init is s → ¬flying s`, in which **Φ does not occur.** A wrong Φ cannot
mislead: too strong fails the base case, too weak fails safety, not-an-invariant fails
preservation. Any wrong Φ = a *failed proof*, never a false theorem.

Two clarifications this pins down:

- **"Top-level `Definition`" is not the trust axis.** A `Definition Φ` referenced only by
  lemmas is exactly as un-audited as something inlined in a tactic script. The audit surface is
  *the statement + the closure of definitions it names* — not every `Definition` in the repo.
  Making Φ a clean named definition is for *our* readability, not a trust cost.
- **Φ-internalization does not buy non-vacuity.** It guards Φ-being-*wrong*, not the theorem
  being *empty*. Vacuity is guarded separately (the non-vacuity witness — `FrameTrace.v` ships a
  concrete control proving flying *is* reachable *with* A, so the no-A hypothesis is doing real
  work — plus `Print Assumptions` and `Set Printing All`).

So reviewer attention belongs on the statement's vocabulary, where the heavyweight item is
**`frame_step` itself** — the model. *That* is the definition needing human agreement ("yes,
this faithfully captures one SM64 frame"), which is why `the-frame.md` grounds it in concrete
`file:line` and flags the interpreter abstraction as a named, trusted step. Φ is cheap;
`frame_step` is where model-faithfulness scrutiny lives.

## Prior art (honestly labeled)

Established and load-bearing: **TCB minimization** (seL4: a small reviewed spec over a huge
proof; CompCert: trust the short statement + semantics, not the compiler); the **de Bruijn
criterion** (small checker ⇒ proof size irrelevant to trust); **`Print Assumptions`** axiom
auditing; **Pollack-consistency / "what you see is what you proved"** (Wiedijk) on statements
misrepresenting themselves.

Proposed here, directionally standard but not a named technique: the **import-allowlist on
the spec file** plus the CI gates above — a packaging of TCB-isolation discipline into
mechanical checks. The pieces are standard; bolting them to CI as hard gates is engineering,
not new theory.

## Standing decision

When the real top-level theorem is written, it MUST be phrased only in CompCert
whole-program execution + a tiny input/win model, isolated in its own import-restricted
file, gated by `Print Assumptions` and a non-vacuity witness. This is the rule that keeps
`reaches` (and friends) out of the lede years from now. Not yet set up (project is still
3 proof files); recorded so it is retrofitted deliberately, not forgotten.
