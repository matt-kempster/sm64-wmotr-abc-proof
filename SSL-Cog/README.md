# SSL-Cog

Welcome to the SSL 0A research folder.

The question behind this work is whether **Inside the Ancient Pyramid** and
**Pyramid Puzzle** can be collected with 0 A presses. The current expectation
is that they cannot, but "probably impossible" is not the finish line. The goal
is to either prove the relevant routes impossible or find a concrete
counterexample that shows one of them works.

Both outcomes are useful. What matters is that the result is backed by source
analysis, a reproducible model, and machine-checked proof work rather than a
"trust me bro" argument.

## Projects in this folder

The four current projects cover the main ways the expected impossibility
could fail:

- `demo-warp/` studies whether the demo-input timer decrement can make the
  proposed one-byte change to Mario's Y float. It contains a local generated-
  Clight counterexample and keeps gameplay reachability as a separate open
  obligation.
- `ssl-parallel-universe/` studies whether movement inside the Pyramid can
  reach a parallel universe and break the usual reachability argument.
- `ssl-spawning-displacement-proof/` studies the JP spawning-displacement and
  stale-platform route, including whether an outside platform pointer can be
  reused by an inside object such as Spindel.
- `ssl-pyramid-item-proof/` studies whether an object, item, or useful object
  reference from outside the Pyramid can survive the area transition.

Start with the README in the project matching the route you care about. Each
project is self-contained because the hypotheses use different game versions,
source paths, models, and proof stacks.

Please read claims literally. A conditional theorem is still conditional, and
an open checklist item may contain the hard part of the route. The project
README and `docs/` files should always make that boundary clear.

## Standard project structure

New proof projects under `SSL-Cog/` should follow this layout:

```text
ssl-<route-name>-proof/
|-- README.md
|-- Makefile
|-- _CoqProject
|-- docs/
|   |-- goal.md
|   |-- claim.md
|   `-- checklist.md
|-- inputs/
|-- pipeline/
|-- generated/
`-- proofs/
```

The existing `ssl-parallel-universe/` name predates this naming pattern and is
fine as-is. For new folders, use a short lowercase kebab-case name that says
what route or mechanism is being investigated.

Here is what each part is for:

- `README.md` is the entry point. State the route being studied, the current
  result, the intended proof path, prerequisites, and exact build/check
  commands.
- `Makefile` provides the normal generation and proof targets. Keep commands
  local to the project so it can be checked independently.
- `_CoqProject` defines the project's Rocq/Coq load paths and proof modules.
- `docs/goal.md` is the durable recovery note: what the project is ultimately
  trying to prove or refute and the broad route being followed.
- `docs/claim.md` gives the precise current claim and scope, including game
  version, source revision, assumptions, definitions, and known boundaries.
- `docs/checklist.md` is the live status page. Record the current verdict,
  completed work, open obligations, and enough receipts for the next agent to
  continue without reconstructing the whole history.
- `inputs/` contains small C models, extracted source inputs, or other
  hand-maintained material used to produce proof artifacts.
- `pipeline/` contains reproducible scripts for source audits, Clight
  generation, environment setup, and end-to-end checks.
- `generated/` contains mechanically generated artifacts, especially CompCert
  Clight ASTs. Do not hand-edit these files; change the input or generator and
  regenerate them.
- `proofs/` contains the hand-written Rocq/Coq specifications, source-shape
  facts, supporting lemmas, and capstone theorems.

Projects may add files or directories when the route needs them, such as
`patches/`, a longer human-readable proof, or project-specific notes under
`docs/`. Those additions should supplement the common structure, not replace
it. Build output and local scratch files should stay ignored rather than
becoming part of the template.

## Agent workflow

When creating or extending a project:

1. Write the route and success condition in `docs/goal.md`.
2. Pin the exact version, assumptions, and current theorem boundary in
   `docs/claim.md`.
3. Add the smallest reproducible inputs and generation pipeline needed to
   audit the relevant source.
4. Keep generated files reproducible and never patch them by hand.
5. Put machine-checked statements in `proofs/` and expose normal checks through
   the `Makefile` and `pipeline/check.sh`.
6. Update `docs/checklist.md` whenever proof scope, proof status, or build
   behavior changes.
7. Keep the project README short enough to orient a new reader, and link to the
   detailed docs instead of turning it into a work log.

That is the whole idea: every plausible SSL escape hatch gets a focused,
reproducible project, and every project should be understandable by the next
person or agent who opens it.
