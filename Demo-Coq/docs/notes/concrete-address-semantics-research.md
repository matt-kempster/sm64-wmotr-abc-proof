# Concrete-address semantics: bounded primary-source research

Research date: 2026-10-15. This is a read-only research result, not a migrated
semantics, checked compatibility result, new execution proof, or gameplay verdict.
No toolchain was installed and no external artifact was compiled.

The inspected primary sources do not provide a demonstrated drop-in replacement
for the project's unchanged CompCert 3.15 generated Clight AST, existing `step2`
histories, and retail N64 MIPS execution. That is a bounded search finding, not a
claim that no suitable framework exists anywhere.

## CompCertS: an existing verified compiler extension

[CompCertS's author-hosted development](https://www.cs.yale.edu/homes/wilke-pierre/jar18/)
includes a complete Coq compiler development and an online listing. Its documented
requirements are Coq 8.4pl6 and OCaml 4.01.0. The
[development index](https://www.cs.yale.edu/homes/wilke-pierre/jar18/doc/)
identifies the base as CompCert 2.4 and lists PowerPC, ARM and x86 targets.

It represents pointer arithmetic symbolically. Dereferences normalize a symbolic
address to a block/offset pointer; normalization must hold for every legal block
placement. This supports operations such as setting and then clearing aligned
pointer tag bits. It does not automatically resolve an arbitrary fixed N64
integer address to a block. This limitation is material for physical/KSEG address
construction. See the
[paper's Section 2.3](https://cs.yale.edu/homes/wilke-pierre/itp-17.pdf) and
[NormaliseSpec Coq definitions](https://www.cs.yale.edu/homes/wilke-pierre/jar18/doc/html/NormaliseSpec.html).

The actual [Clight Coq listing](https://www.cs.yale.edu/homes/wilke-pierre/jar18/doc/html/Clight.html)
changes temporary values to `expr_sym`, uses `Mem.loadv` for dereferences, and
uses memory-dependent `Genv.find_funct m ge vf` for calls. Function records also
have extra fields. Thus neither its AST types nor its execution theorems are the
project's existing interfaces. An indirect-call rule exists, but numerical N64
callback compatibility has not been established.

## MoreC: concrete addresses, but a smaller language and no function-pointer proof

The [ITP 2024 paper](https://drops.dagstuhl.de/storage/00lipics/lipics-vol309-itp2024/LIPIcs.ITP.2024.36/LIPIcs.ITP.2024.36.pdf)
defines data pointers as machine integers and allows integer-addressed byte loads
and stores; its allocation oracle is instantiated and its source/target
refinement proved. The formal proof of concept is a small RTL-like language and a
tagged RISC-like target, not Clight or N64 MIPS. Section 7 explicitly leaves
function pointers to future work. Its public/private protection target is also
different from an unmodified retail N64.

The [official artifact](https://github.com/hope-pdx/MoreC) lists `Mem.v`, `RTL.v`,
`Mach.v`, `SourceMem.v`, `Matching.v`, `Sim.v`, and `TopLevel.v`; its README names
Coq 8.18.0, OCaml 4.14.1 and coq-equations 1.3. The raw code links were unavailable
through the browser fetcher during this bounded review; the listed file scope,
toolchain and missing function-pointer result are supported by the README and
paper. There is no inspected Clight 3.15 adapter.

## Quasi-concrete memory: useful theory, not a full Clight compiler adapter

Kang et al.'s [PLDI 2015 paper](https://software.imdea.org/advent-project/pubs/pldi2015-cast.pdf)
formalizes integer-pointer casts in Coq: casting exposes a block's concrete
address, integer arithmetic can then manipulate it, and integer-to-pointer casts
resolve exposed concrete blocks. Its verified examples and identity compilers
use a separate small language. The
[author project page](https://sf.snu.ac.kr/intptrcast/) supplies the development
archive. This does not establish whole Clight AST coverage or the native
callback and fixed-placement facts needed here.

## A concrete technical direction, with the unproved obligations exposed

The most direct project-specific direction would be a concrete-address operational
semantics over the existing Clight 3.15 syntax, rather than editing the helper
bodies. This is proposed engineering work, not a result supplied by these
artifacts. A credible correspondence would need all of the following:

1. A concrete byte memory and explicit 32-bit address interpretation covering
   casts, bitwise arithmetic, numerical dereferences, and indirect calls to
   actual internal function bodies. Loads must read that memory; callbacks must
   resolve checked loaded code, rather than using a dereference oracle or
   replacing game callees with externals.
2. A proved relation between symbolic blocks and concrete regions, including
   globals, heap and stack lifetimes, typed byte encoding, aliasing, and frames.
   Existing ordinary-Clight local results require transport lemmas under this
   relation; they do not transfer by changing an import.
3. An authenticated, epoch-sensitive placement/loading relation for the linked
   image, overlays, segment tables, callback addresses and data bytes. ROM/ELF
   metadata alone does not prove that an image is currently active.
4. Actual execution correspondence to retail MIPS: instruction and calling
   conventions, 32-bit wraparound, signedness, endianness, alignment, floating
   point, KSEG/physical aliases, and the permitted DMA/SI/EEPROM/scheduler effects.
   Existing CompCertS or MoreC compiler theorems do not certify an IDO-produced
   retail binary.

The existing ordinary-Clight stuckness result remains a result about that
semantics. Giving the same helper AST a defined alternative concrete execution
would neither refute the stuckness theorem nor, by itself, prove native
correctness or the full no-desync claim.
