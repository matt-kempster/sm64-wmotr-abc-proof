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

/* VIRTUAL_TO_PHYSICAL: the ROM does (uintptr_t)(addr) & 0x1FFFFFFF.  Bitwise AND
   on a pointer is undefined in CompCert, so the model had NO execution for any
   frame that DMA-loads a new Mario animation (set_mario_animation,
   set_mario_anim_with_accel: 33 of 300 recorded real frames).
   Same bits: every RDRAM address is KSEG0, x = 0x80000000 + y with
   0 <= y < 2^29, and 0x80000000 is a multiple of 2^29, so
   x & 0x1FFFFFFF = y = x - 0x80000000.  Pointer minus integer is defined in
   CompCert (vendor's own VIRTUAL_TO_PHYSICAL2, macros.h:70, has this form). */
#undef VIRTUAL_TO_PHYSICAL
#define VIRTUAL_TO_PHYSICAL(addr) ((uintptr_t)((unsigned char *)(addr) - 0x80000000U))

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
