# Goal recovery note

This file is the durable recovery copy of the SSL Parallel Universe objective.

## Objective

Build a formal Rocq/Coq + CompCert `clightgen` project, following the structure
of `SSL-Coq/ssl-pyramid-item-proof`, that either proves Mario cannot enter a
parallel universe in SSL Area 2 or supplies a concrete counterexample.

## Result

The project found a counterexample in its source-shaped execution model.
The capstone is:

```text
SSLPU.Proofs.BLJDynamic.
  ssl_area2_grindel_dynamic_counterexample_certificate
```

It uses the Area 2 vertical Grindel at `(3297, 0, 95)`. A bounded normal long
jump reaches `-8.4` speed as the Grindel begins rising; nine immediate
rising-floor recycles fit on its top, and the tenth releases Mario toward the
positive X edge. The release establishes a floor-null landing anchor, repeated
BLJs grow speed, and target 21 reaches X `522262`. Its signed-16 alias `-2026`
lies in a concrete Area 2 floor triangle, so the final state satisfies the
project's PU predicate.

## Proof route

```text
pinned US source and SSL collision literals
  -> clightgen-generated CompCert Clight ASTs
  -> generated-program shape facts
  -> exact bootstrap and Grindel recycle recurrence
  -> audited static-floor release and floor-null arcs
  -> signed-16 Area 2 floor alias at a PU coordinate
  -> dynamic counterexample capstone
```

The earlier conditional theorem
`SSLPU.Proofs.ParallelUniverse.ssl_area2_no_parallel_universe` remains valid
for the bounded/clamped transition model. It does not imply the unqualified
gameplay claim because the dynamic Grindel route leaves that certificate.

## Verification boundary

The capstone combines generated Clight AST shape checks, exact rational
arithmetic, and an independent source/mesh audit. It has no admitted proof
holes or project-added axioms. A future strengthening may replace the rational
trace bridge with a full CompCert operational-semantics proof of the float32
execution, but that is not required to recover the current result.

## Completed extension: no new A press

The extension asks whether a PU remains reachable when `INPUT_A_PRESSED` is
always zero after entering Area 2, while `INPUT_A_DOWN` may be set or clear.
The formal model permits an arbitrary A-down schedule, covering A-up,
continuously held A, and holding A into Area 2 before releasing it.

The capstone is:

```text
SSLPU.Proofs.NoAPressed.
  ssl_area2_no_new_a_parallel_universe_certificate
```

The theorem combines generated Clight facts for warp initialization, input
materialization, C-up/slide updates, held-A jump kick, fresh-A BLJ gates, and
floor quarter steps with an independent audit of every Area 2 slippery
triangle and dynamic horizontal writer. Nine finite slippery components fit a
`16384` path budget, yielding a conservative no-A speed bound of `1024` and a
quarter-step bound of `256`. The first reusable signed-16 static-floor alias is
`54630` units beyond the local mesh window, so every accepted certified step
stays local and every floor-null step freezes X/Z.

The retail C-up probe remains supporting evidence: its largest measured
magnitude is `235.222733`, well below the proof's conservative ceiling. The
original unrestricted counterexample remains valid because it is allowed to
generate fresh A presses; the no-new-A extension is a separate impossibility
result.

## Repository workflow constraints

- Work on branch `codex/ssl-pyramid-item-proof` in the proof repository.
- Keep work inside `SSL-Coq/ssl-parallel-universe/` unless minimal external
  build wiring is required.
- Do not modify `SSL-Coq/ssl-pyramid-item-proof/` except to inspect its style.
- Commit after each logical change and update all files in `docs/` each time.
- Do not push without explicit user approval.

The repository root rename from `SSL-Cog/` to `SSL-Coq/` was committed as a
path-only migration, apart from the required documentation receipts in this
folder.
