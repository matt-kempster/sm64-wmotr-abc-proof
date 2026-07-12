# Goal recovery note

This file is the durable recovery copy of the SSL Parallel Universe objective.

## Objective

Build a formal Rocq/Coq + CompCert `clightgen` project, following the structure
of `SSL-Cog/ssl-pyramid-item-proof`, that either proves Mario cannot enter a
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

## Repository workflow constraints

- Work on branch `codex/ssl-pyramid-item-proof` in the proof repository.
- Keep work inside `SSL-Cog/ssl-parallel-universe/` unless minimal external
  build wiring is required.
- Do not modify `SSL-Cog/ssl-pyramid-item-proof/` except to inspect its style.
- Commit after each logical change and update all files in `docs/` each time.
- Do not push without explicit user approval.
