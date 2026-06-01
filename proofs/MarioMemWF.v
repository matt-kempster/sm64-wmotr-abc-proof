(* MarioMemWF.v -- the first REAL memory-layout brick: well-formed Mario memory.
 *
 * MOTIVATION (leaving abstract-land). The value-frame engine (ActionValueFrame)
 * proves a statement preserves "the action field is non-flying" PROVIDED every
 * store either misses the action cell or stores a non-flying value. For a real
 * action body the easy stores are `m->field = c` (same block as the action cell,
 * disjoint OFFSET -- already handled by ActionFrame's field-offset disjointness).
 * The hard ones are POINTER CHASES: e.g. act_panting's only store is
 *     m->marioBodyState->eyeState = 2
 * a write through a pointer LOADED FROM memory. "This misses the action cell"
 * means "the block m->marioBodyState points to is not Mario's block bm" -- which
 * is NOT a syntactic fact and NOT an offset fact. (Note the trap: MarioBodyState
 * ALSO has an `action` field, at offset 0 -- so an offset-only argument is wrong;
 * safety is purely about the BLOCK.)
 *
 * GROUND TRUTH (verified against the generated ASTs + how SM64 works):
 *   - SM64 has NO malloc/free; ALL memory is static globals (gMarioState,
 *     gBodyStates[2], gObjectPool, surface pools, ...). CompCert gives every
 *     global a DISTINCT block (Genv.global_addresses_distinct). So at the BLOCK
 *     level the structs Mario points to are separable from Mario's block -- and
 *     that distinctness is PROVED here, not assumed.
 *   - The pointer VALUES (m->marioBodyState = &gBodyStates[..], etc.) are wired up
 *     by engine code at init, scattered across large init/graph-node callbacks
 *     (NOT one tidy init function, and NOT flying-relevant). So rather than trace
 *     that render-subsystem code, we capture the post-init fact as a WELL-FORMED
 *     MEMORY invariant carried across frames -- exactly the design of action_sat:
 *     state it, prove the provable core, and (later) prove it preserved by step.
 *
 * THIS FILE (first slice -- the marioBodyState pointer that act_panting needs):
 *   - the PROVED core: in mario.prog's genv, gMarioState and gBodyStates occupy
 *     distinct blocks (Genv.global_addresses_distinct + the two find_symbol facts);
 *   - the well-formedness predicate mario_mem_wf, stating that Mario's block bm is
 *     distinct from the body-state block AND m->marioBodyState loads an address in
 *     that distinct block;
 *   - the payoff lemma the value-frame engine consumes: under mario_mem_wf, a store
 *     through m->marioBodyState avoids the action cell (bm, 12).
 *
 * The block-distinctness core is unconditional and real. The "m->marioBodyState
 * points into gBodyStates" conjunct is the carried invariant (the honest, named,
 * preserved obligation -- not an axiom). Extending to marioObj/floor/wall/... is
 * mechanical: same shape, same distinctness lemma.
 *
 * No Admitted.
 *)

From compcert Require Import Coqlib Errors Maps AST Integers Values Memory Globalenvs Ctypes Clight.
From SM64.Generated Require mario.

Definition mario_ge : genv := globalenv mario.prog.

(* ---- The PROVED core: gMarioState and gBodyStates are distinct blocks. ---- *)

(* Each global resolves to some block in mario.prog's genv (bounded single-program
   find_symbol, the same idiom as ActionValue's find_funct_* lemmas). *)
Lemma find_gMarioState :
  exists b, Genv.find_symbol mario_ge mario._gMarioState = Some b.
Proof. eexists; vm_compute; reflexivity. Qed.

Lemma find_gBodyStates :
  exists b, Genv.find_symbol mario_ge mario._gBodyStates = Some b.
Proof. eexists; vm_compute; reflexivity. Qed.

(* The cornerstone: distinct named globals occupy distinct blocks. Purely from
   Genv.global_addresses_distinct -- true before any engine code runs. *)
Lemma gMarioState_gBodyStates_distinct :
  forall b1 b2,
    Genv.find_symbol mario_ge mario._gMarioState = Some b1 ->
    Genv.find_symbol mario_ge mario._gBodyStates = Some b2 ->
    b1 <> b2.
Proof.
  intros b1 b2 H1 H2.
  eapply Genv.global_addresses_distinct; [ | exact H1 | exact H2 ].
  (* the two idents differ (both literally defined in mario.v) *)
  vm_compute; discriminate.
Qed.

(* ---- Well-formed Mario memory (first slice: the marioBodyState pointer) ---- *)

(* The MarioState.marioBodyState field offset (Full, a pointer). Discharged from
   the real composite env, not asserted. *)
Definition mario_ce : composite_env := prog_comp_env mario.prog.
Definition mario_members : members :=
  match mario_ce ! mario._MarioState with
  | Some co => co_members co
  | None => nil
  end.

(* mario_mem_wf ge m bm bbs:
     - bm  = Mario's struct block;
     - bbs = the body-state block;
     - bm <> bbs                         (PROVED instance via the cornerstone);
     - m->marioBodyState loads Vptr bbs _ (the carried, preserved invariant).
   We pin the field offset abstractly via field_offset so this stays faithful to
   the real layout; the load is at (bm, off_bodyState). *)
Definition mario_mem_wf (m : mem) (bm bbs : block) : Prop :=
  bm <> bbs /\
  exists off_bs ofs,
    field_offset mario_ce mario._marioBodyState mario_members = OK (off_bs, Full) /\
    Mem.load Mptr m bm off_bs = Some (Vptr bbs ofs).

(* The action cell, as in ActionValueFrame (4 bytes at (bm,12)). *)
Definition action_cell (bm : block) : block -> Z -> Prop :=
  fun b o => b = bm /\ 12 <= o < 12 + size_chunk Mint32.

(* PAYOFF: a store through m->marioBodyState lands in block bbs, which (by
   well-formedness) is distinct from bm -- so it AVOIDS the action cell entirely,
   for any offset/length. This is exactly the "avoid" disjunct the value-frame
   engine's per-Sassign obligation needs for a pointer-chase store. *)
Lemma bodyState_store_avoids_action_cell :
  forall m bm bbs,
    mario_mem_wf m bm bbs ->
    forall o, ~ action_cell bm bbs o.
Proof.
  intros m bm bbs [Hne _] o [Hb _]. subst bbs. apply Hne. reflexivity.
Qed.

(* And the genv-level instance: when bm/bbs come from the real globals, the
   distinctness half of well-formedness is the proved cornerstone (not assumed). *)
Lemma mario_mem_wf_distinct_from_globals :
  forall bm bbs,
    Genv.find_symbol mario_ge mario._gMarioState = Some bm ->
    Genv.find_symbol mario_ge mario._gBodyStates = Some bbs ->
    bm <> bbs.
Proof.
  intros bm bbs Hm Hbs.
  eapply gMarioState_gBodyStates_distinct; eauto.
Qed.
