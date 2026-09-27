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

#endif
