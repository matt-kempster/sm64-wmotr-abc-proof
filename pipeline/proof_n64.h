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

/* set_segment_base_addr (2026-11-02, approved): the ROM body stores
   `(uintptr_t) addr & 0x1FFFFFFF` (memory.c:69), undefined on a pointer in
   CompCert, so select_gfx_pool (every frame) had NO execution and the frame
   capstones were vacuous (FOUND, TRUST.md 2.2).  Same address model as
   segmented_to_virtual above: the table holds the address unmasked.  The
   value is read back only by move_segment_table_to_dmem (gSPSegment words
   for the RSP), and every caller discards the result
   (SegTableCensus, vm-checked).  The ROM body stays in the TU, renamed
   rom_set_segment_base_addr; memory.c's own load_segment* (boot / level
   load, not walked) call that one. */
extern uintptr_t sSegmentTable[32];
uintptr_t set_segment_base_addr(s32 segment, void *addr) {
    sSegmentTable[segment] = (uintptr_t) addr;
    return sSegmentTable[segment];
}
#define set_segment_base_addr rom_set_segment_base_addr
#endif

/* level_cmd_place_object (engine/level_script.c only: the Makefile builds
   it from pipeline/tu/level_script.c with -DPROOF_LEVEL_SCRIPT_C=1;
   2026-11-07, approved).  Its first line, `u8 val7 = 1 << (gCurrActNum - 1)`,
   shifts by -1 at act 0 (a real entry, docs/wmotr-entry-census.md B1):
   undefined in C, so that OBJECT command had no execution.  The ROM's sllv
   takes the shift mod 32 (1 << 31; the u8 store keeps 0).  The function-like
   macro renames only the ROM DEFINITION to rom_level_cmd_place_object (the
   jump table's entry is not followed by `(`, so it keeps naming
   level_cmd_place_object), and the wrapper TU defines that one after the
   vendor file: the vendor body with the shift written `& 31`.  Nothing
   calls the rom_ one (unreferenced static: clightgen omits it).
   TRUST.md 2.2 register. */
#ifdef PROOF_LEVEL_SCRIPT_C
static void level_cmd_place_object(void);
#define level_cmd_place_object(v) rom_level_cmd_place_object(v)
#endif

#endif
