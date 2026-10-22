/* Proof-only C rewrites: force-included (clightgen -include) BEFORE every TU.

   Each rewrite replaces C whose CompCert meaning is undefined, but whose N64
   meaning is fixed, with C that CompCert defines AND that computes the same bits
   the ROM computes.  One TRUST.md 2.2 row per rewrite; tools/ub_sites.py lists
   every site this file changes, and experiments/oracle's difftest checks them
   on real frames.

   Mechanism: vendor headers include "macros.h" with quotes from include/, which
   bypasses -I shadowing.  So pull macros.h in first (its MACROS_H guard makes
   every later #include a no-op) and then redefine. */
#ifndef PROOF_N64_H
#define PROOF_N64_H

#include "macros.h"

/* VIRTUAL_TO_PHYSICAL / PHYSICAL_TO_VIRTUAL / VIRTUAL_TO_PHYSICAL2: the
   decomp's own NO_SEGMENTED_MEMORY bodies (macros.h:73-75, verbatim), the
   same address model as segmented_to_virtual below.  The ROM bodies
   ((uintptr_t)p & 0x1FFFFFFF, | 0x80000000, - 0x80000000U) round-trip on
   the N64 only together with the ROM segmented_to_virtual (segment 0 adds
   KSEG0 back).  Mixing them with the identity segmented_to_virtual left
   every read of a relocated Mario animation pointer out of bounds (no
   execution; FOUND 2026-10-22, TRUST.md 2.2).  NO_SEGMENTED_MEMORY itself
   is not defined: it also changes memory.c, macro_special_objects.c,
   level_commands.h and segment_symbols.h, which stay as in the ROM.
   (2026-09-26 .. 2026-10-22 this was `p - 0x80000000U`, the ROM's bits.) */
#undef VIRTUAL_TO_PHYSICAL
#undef PHYSICAL_TO_VIRTUAL
#undef VIRTUAL_TO_PHYSICAL2
#define VIRTUAL_TO_PHYSICAL(addr)   ((uintptr_t)(addr))
#define PHYSICAL_TO_VIRTUAL(addr)   ((uintptr_t)(addr))
#define VIRTUAL_TO_PHYSICAL2(addr)  ((void *)(addr))

/* segmented_to_virtual / virtual_to_segmented (memory.c only: the Makefile
   passes -DPROOF_MEMORY_C=1 to that one recipe).  The ROM bodies shift and
   mask the pointer ((uintptr_t)addr >> 24, & 0x00FFFFFF, & 0x1FFFFFFF):
   undefined on a pointer in CompCert, so EVERY real call on &bhvXxx (or any
   pointer) had no execution.  We take the decomp's own NO_SEGMENTED_MEMORY
   bodies (memory.c:98-105, verbatim), for these two functions ONLY:
   NO_SEGMENTED_MEMORY itself is not defined, so load_segment & co.,
   move_segment_table_to_dmem, macros.h and segment_symbols.h are unchanged.
   The ROM bodies stay in the TU, renamed rom_*; nothing calls them.
   Why identity is the game's behavior: TRUST.md 2.2 register. */
#ifdef PROOF_MEMORY_C
#include <PR/ultratypes.h>
void *segmented_to_virtual(const void *addr) {
    return (void *) addr;
}

void *virtual_to_segmented(u32 segment, const void *addr) {
    return (void *) addr;
}
#define segmented_to_virtual rom_segmented_to_virtual
#define virtual_to_segmented rom_virtual_to_segmented
#endif

#endif
