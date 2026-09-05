# Rank 12B offline contact census

From the active SSL project directory:

```sh
node instrumentation/rank12b-contact/check.js
node instrumentation/rank12b-contact/check.js --verbose
```

The checker reads only `build/pinned-sm64` source files. It parses all 1,080
Area-2 vertices and 1,558 triangles, confirms the target positions and ordinary
hitbox descriptors, checks the seven expected static-floor candidate lists
with both zero and one-unit box padding, and evaluates positive/negative
binary32 contact samples. Verbose output adds source vertices and the solids
surrounding the highest secret.

This is not an emulator run, a controller search, or a game-state fixture. It
does not modify game memory or establish that Mario can reach a listed point.
The JavaScript geometry scan is independently reproduced from the generated
US/JP initializers in `proofs/Area2Rank12BContact.v`. The quantified Float32
gate-footprint exclusion and selected Clight rejection tail are Coq theorems,
not conclusions drawn merely from the nearest-point samples printed here.

See [the audit](../../docs/notes/rank12b-cross-barrier-contact.md) for proof
boundaries, the Act-3 rim contact, the highest secret's underside, and the
remaining live-execution work.
