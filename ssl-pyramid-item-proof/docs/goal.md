# Goal recovery note

This file backs up the active Codex goal for the SSL Pyramid proof work. If the
app-level goal state is lost, recreate it from this note rather than relying on
memory.

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

For this proof, "item" should not be read as only one SM64 interaction type.
The intended focus includes portable or rideable objects such as cork boxes,
shells, and similar objects whose identity might plausibly be carried, ridden,
held, used, or otherwise preserved through Mario/object references across the
area-change barrier.

The proof should also account for adjacent object classes if they can affect
the same impossibility or cloning question. For example, hats/caps or other
special objects should be considered in scope if their generated code stores a
live `gObjectPool` object pointer, preserves an allocation epoch, creates a
stale reference, or can otherwise influence whether an outside-Pyramid object
identity reaches the Pyramid. The formal development may later refine this into
a precise predicate, but it must not silently exclude such cases unless a
mechanized or documented argument justifies the exclusion.

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
