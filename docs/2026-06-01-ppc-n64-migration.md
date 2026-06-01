# Model migration to ppc32 / N64-faithful layout (2026-06-01, part 4)

## Why
SM64 runs on the N64: MIPS o32 ABI — **32-bit pointers, big-endian**. The proof
toolchain had been the default x86_64 CompCert (`Archi.ptr64 = true`, 64-bit,
little-endian), so the Clight model used the wrong pointer size, endianness, and
**struct field offsets**. Claiming "this models SM64-on-N64" was therefore false.

## What changed
Rebuilt `coq-compcert` 3.15 for **`ppc-eabi`** (PowerPC ppc32, big-endian) — the
closest CompCert backend to the N64 (CompCert has no MIPS backend). Now
`Archi.ptr64 = false`, `Archi.big_endian = true`.

- **`pipeline/install-toolchain.sh`** reconfigures + rebuilds CompCert for
  `ppc-eabi` (external Flocq/MenhirLib; runtime C lib skipped — no ppc cross-asm;
  Coq dev installed), with a `ptr64=false /\ big_endian=true` verification step.
  The switch is now reproducibly N64-faithful.
- **`generated/*.v`** regenerated with the ppc `clightgen` (`make regen`):
  `bitsize 32`, big-endian, ppc builtins; anonymous-composite idents shift
  (`__218`→`__317`) — no proof references them.
- **Offsets recomputed**: `action@12` and `flags@4` UNCHANGED (no pointers
  precede them in `MarioState`); `marioBodyState` 200→**152**, `hurtCounter`
  238→**178** (4-byte pointers shrink later offsets). `ResetBodystate.v` updated.

## ptr64=false proof consequences (these bit; will bite again)
1. **`sem_cast` of a pointer through a pointer-sized int type now SUCCEEDS**
   (`classify_cast = cast_case_pointer`), returning the `Vptr`. Under ptr64=true
   it returned `None`. So a function's return value can no longer be inferred
   `Vint` just because its cast typechecks. `ActionValue.v` gained
   `exec_flows_into_isint` (the `_action` temp stays `Vint` — the body only
   assigns `Econst_int`/`Etempvar` to it) to pin `rv = Vint` at the two
   setter-result sites.
2. **A `Mem.load Mint32` can now legitimately yield a `Vptr`** (a 4-byte load can
   hold a pointer fragment). This **reopens Obstacle 2** (word-scalar field loads
   like `t1 = m->flags` are not provably non-pointer from `mem_wf`). The
   ptr64=true "truncation" shortcut was false here and was removed from
   `ValueFrameStmt.v`. The intended fix remains: restrict `tmps_off_bm` to
   chase-rooted temps (the flags temp is never a chase root).

## Status
Whole tree green under ppc (`bash pipeline/build.sh` RC=0). Key lemmas axiom-clean
(CompCert classical/Events base; none of VST's `prop_ext`/`eq_rect_eq`). The
statement-level bundle frame (`exec_body_nf`) and its chase-load / pointer-copy
dischargers survive the migration unchanged. Remaining to climb the scoreboard:
Obstacle 1 (direct-store `assign_avoids` discharge — mechanical, ptr64-independent)
and Obstacle 2 (the `tmps_off_bm` restriction). Commit: `6a90bd7`.
