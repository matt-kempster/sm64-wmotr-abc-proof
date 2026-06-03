---
name: run-sm64-wmotr-abc-proof
description: Build, type-check, and verify the SM64 WMotR ABC-impossibility Rocq/CompCert proof. Use when asked to build/compile/check/verify the proof, run coqc on a .v file, check axioms / Print Assumptions, localize a slow or hanging proof, or confirm the tree is green before committing.
---

# Run the SM64 WMotR ABC proof

This "app" is a **Rocq (Coq 8.19.2) + CompCert 3.15 proof**, not a runnable
program. You "run" it by **type-checking `.v` files**: if `coqc` accepts them
(RC=0) the theorems hold. The driver is the three `pipeline/*.sh` wrappers —
**always use them, never call `coqc`/`make` directly.** Each wrapper sources
the opam switch itself, so the #1 failure mode (a switch-less `coqc` that prints
a false RC and a non-compiling commit) cannot happen.

All paths below are relative to the repo root (the `<unit>`).

## Prerequisites

The toolchain lives in a dedicated opam switch `sm64-proof` (Coq 8.19.2,
coq-compcert 3.15, clightgen, OCaml 5.2). It already exists on this machine.
To recreate from scratch:

```bash
opam repo add coq-released https://coq.inria.fr/opam/released
opam switch create sm64-proof ocaml-base-compiler.5.2.0 --no-switch
opam install coq-compcert
```

You never activate the switch by hand — the wrappers do it. (`source
pipeline/env.sh` activates it for a shell if you ever need to, and prints the
coqc/clightgen paths.)

## Run (agent path) — the three drivers

### 1. Full build — `pipeline/build.sh`

Sources the switch, then `make`. Builds every `.vo` in dependency order
(`generated/*.v` Clight ASTs, then `proofs/*.v`). This is the "is the whole
tree green?" check and what you run after editing an upstream file.

```bash
bash pipeline/build.sh            # == make (all)
bash pipeline/build.sh proofs     # == make proofs
```

**Slow:** a clean build is several minutes (the 113k-line `behavior_actions.v`
and the `vm_compute`-heavy `proofs/ActionValue.v`). Once built, `.vo` files are
cached — downstream files load them and never re-run the proof, so incremental
builds touch only what changed.

### 2. Single-file check with timing + hang localization — `pipeline/check.sh`

The day-to-day driver. Type-checks ONE `.v` file (its deps must already be
built) under `coqc -time`, redirecting the per-sentence timing to
`pipeline/_check_time.log` (gitignored) so it never floods the terminal. Prints
a short summary only.

```bash
bash pipeline/check.sh proofs/Frame.v
CHECK_TIMEOUT=120 bash pipeline/check.sh proofs/ActionValue.v   # custom limit (default 600s)
```

Output shape (exit code == coqc's RC):

- **Success (RC=0):** prints the 5 slowest sentences — free profiling to find
  the next bottleneck. Verified on `proofs/Frame.v`:
  ```
  RC=0  (limit 600s; full timing -> pipeline/_check_time.log)
  OK -- 5 slowest sentences:
  0.284s	Chars 1246 - 1293 [From~compcert~Require~Import~A...] ...
  ```
- **Timeout (RC=124):** prints the **last sentence that COMPLETED** — the next
  one is what hung. This is the key tool: it localizes a hang in seconds
  instead of waiting out a 30-minute `make`. Verified on `proofs/ActionValue.v`
  with `CHECK_TIMEOUT=25`:
  ```
  RC=124  (limit 25s; full timing -> pipeline/_check_time.log)
  TIMEOUT after 25s -- last sentence COMPLETED before the hang:
  Chars 51112 - 51377 [(match~goal~with~~|~Hlk:?T~!~m...] 0.003 secs
  ```
- **Error (other RC):** prints the Coq error with a few lines of context.

Full timing for any run is in `pipeline/_check_time.log`.

### 3. Axiom check — `pipeline/assumptions.sh`

The trust check. Prints `Print Assumptions` for one or more lemmas in an
already-built module. **"Closed under the global context" = no axioms.** The
module's `.vo` must already be built (run `build.sh` first).

```bash
bash pipeline/assumptions.sh SM64.Proofs.ActionFrame size_chunk_by_value
# -> Closed under the global context
bash pipeline/assumptions.sh SM64.Proofs.ActionWriters lemma1 lemma2 ...
```

First arg is the module's logical path (`SM64.Generated.*` or `SM64.Proofs.*`);
the rest are lemma names within it.

## Commit discipline (this is load-bearing)

Before committing ANY `.v` change: a switch-active RC=0 from `build.sh` (or
`check.sh` for a leaf file) **and** the relevant lemmas axiom-clean via
`assumptions.sh`. Never commit off a raw `coqc` RC, and **never batch the build
and the `git commit` in one shell invocation** — a killed/slow build can let an
unverified commit slip through (this has happened: commits 698c020, f4f6b08
were non-compiling files pushed off a false RC). Verify, *then* commit, as two
separate steps.

## Gotchas (battle scars)

- **A switch-less `coqc` lies.** Running `coqc` without `sm64-proof` active
  prints `[NOTE] ... --set-switch` and a meaningless RC, having never found the
  libraries. It looks like success. The wrappers exist precisely so this can't
  happen — that's why "always use the `.sh`" is a hard rule, not a preference.
- **`cbn [...] in *` HANGS.** The proof context routinely holds `sma_ge =
  globalenv mario.prog`, whose unfolding is enormous. Any `cbn`/`simpl`/
  `vm_compute ... in *` over the whole context can spin forever. Scope reductions
  to a single named hypothesis (`cbn [foo] in Hbar`). `check.sh`'s timeout
  localization is how you catch this.
- **`reflexivity` on genv equalities hangs.** Proving `genv_cenv sma_ge =
  mario_ce` needs `unfold ...; cbn [genv_cenv]; reflexivity` — plain
  `reflexivity` eagerly evaluates `Genv.globalenv` and never returns.
- **`proofs/ActionValue.v` currently hangs** (as of commit 8615831) at the
  `deref_loc`/`cbn` region near `Chars 51112` — found via `check.sh`. So a full
  `build.sh` does **not** currently complete; it builds every other file then
  stalls on ActionValue.v. Fixing that hang is open work.
- **Whole-file recompile is the only intra-file cache unit.** Rocq caches at the
  `.vo` (file) level; there is no within-file proof cache. Editing the last
  lemma of a 1100-line file re-runs all prior lemmas' tactics. Splitting heavy
  lemmas (e.g. the `vm_compute`-laden group setters) into their own file makes
  them a cached `.vo` and shrinks the edit-compile loop.
- **`generated/*.v` are DO-NOT-EDIT** (clightgen output; regenerate via
  `pipeline/clightgen.sh`, output must be byte-identical).

## Troubleshooting

| Symptom | Fix |
|---|---|
| `Cannot find a physical path bound to logical path X` | That module's `.vo` isn't built. Run `bash pipeline/build.sh` first. |
| `coqc` "succeeds" but nothing really checked; `[NOTE] --set-switch` in output | You called `coqc` directly without the switch. Use the `pipeline/*.sh` wrappers. |
| Build/check seems to run forever | `CHECK_TIMEOUT=30 bash pipeline/check.sh <file>` to localize — the last completed `Chars` line names the sentence before the hang. |
| `opam switch 'sm64-proof' not found` | Recreate it (see Prerequisites). |
