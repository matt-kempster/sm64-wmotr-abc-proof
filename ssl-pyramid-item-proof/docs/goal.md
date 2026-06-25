# Goal recovery note

This file backs up the active Codex goal for the SSL Pyramid proof work. If the
app-level goal state is lost, recreate it from this note rather than relying on
memory.

For the living, human-readable TODO map, see `checklist.md`. Codex should update
that checklist during each round of work when the proof frontier changes.

## Active objective

Build a formal Rocq/Coq + CompCert `clightgen` proof, using the
matt-kempster WMotR proof style/repository as the model, for SSL Pyramid
item-transfer impossibility:

- prove that no item from outside SSL's Pyramid can be brought into the
  Pyramid; or
- if that claim is false, provide a concrete counterexample.

The proof must specifically analyze the stale-pointer edge case because it may
enable cloning. In particular, check whether grabbing an item from outside the
Pyramid can create a stale pointer, and whether that stale pointer can permit
cloning of an in-Pyramid object such as a goomba. If that cloning channel is
possible, provide the counterexample instead of an impossibility proof.

## Working definition of "item"

For this proof, "item" should mean a gameplay-relevant `gObjectPool` object
identity, not just one SM64 interaction enum or one carry action. The primary
focus is on objects like cork boxes, shells, and similar portable, grabbable,
holdable, rideable, or otherwise Mario-linked objects whose identity might
plausibly be carried into SSL's Pyramid by a direct pointer, a saved object
reference, or a reused object-pool slot.

The theorem should distinguish at least three cases:

- direct transfer: the same live outside-Pyramid object identity crosses the
  area-change barrier;
- stale transfer: an outside-Pyramid object is unloaded, but some surviving
  reference still denotes that old object identity or allocation epoch after
  the Pyramid loads; and
- cloning-relevant slot reuse: a stale outside reference later aliases a newly
  allocated in-Pyramid object, such as a goomba, in a way that can duplicate or
  otherwise clone gameplay state.

Adjacent object classes are in scope exactly when they can affect that
transfer/cloning question. In particular, hats/caps, cap objects, special
interaction objects, or behavior-specific parent/child references should be
considered if their generated code stores a live `gObjectPool` pointer,
preserves an allocation epoch, creates a stale reference, changes Mario's
held/ridden/used/interacted object references, or can otherwise influence
whether an outside-Pyramid object identity reaches the Pyramid.

Pure counters or state effects, such as coins, timers, music, camera state, or
ordinary collected-item flags, are not the central target unless they preserve
or reconstruct an object identity relevant to transfer or cloning. The formal
development may later refine this prose into a precise Coq predicate, but it
must not silently exclude any object class without a mechanized or documented
reason for the exclusion.

## Repository workflow constraints

- Work in the GitHub-backed fork/repository, preserving matt-kempster's WMotR
  work separately from this SSL proof work.
- Commit and push concrete progress to `tra38/sm64-wmotr-abc-proof`.
- Do not open a pull request unless explicitly asked.

## Current proof route

The intended route is:

```text
pinned US SM64 decomp source
  -> CompCert clightgen-generated Clight ASTs
  -> Rocq lemmas over CompCert execution semantics
  -> an auditable SSL area-transition theorem
```

Generated Clight files are never hand-edited.
