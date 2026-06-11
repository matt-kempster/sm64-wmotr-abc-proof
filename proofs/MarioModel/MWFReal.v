(* ====================================================================== *)
(* MWF_real -- the CONCRETE run invariant (Unwired STAGING).               *)
(*                                                                         *)
(* The v2 grounded capstone carries an ABSTRACT MWF with ~12 stability     *)
(* hypotheses (projections, per-cell store stability, entry/free/umbi      *)
(* crossings). This file instantiates MWF concretely so those hypotheses   *)
(* become PROVED lemmas, leaving only block-distinctness side conditions   *)
(* + the init condition + the genuinely-residual external contract.        *)
(*                                                                         *)
(* DESIGN RULES (each learned from a satisfiability repair):               *)
(*  - every row is load-CONDITIONAL (premise = the load returns a          *)
(*    Vint/Vptr): positive "the load succeeds" rows are jointly            *)
(*    unsatisfiable with the engine's free leaf (free kills loads);        *)
(*  - EXCEPT R0, the validity rows, which are positive but MONOTONE-SAFE:  *)
(*    valid_block survives stores, alloc and even free (nextblock-based),  *)
(*    and unchanged_on implies nextblock growth. R0 is FORCED: without     *)
(*    it an adversary ALLOCATES the fixed controller block fresh with      *)
(*    corrupt content under Hmwf_umbi's unchanged_on premise (which        *)
(*    constrains only blocks valid in m);                                  *)
(*  - the store window (CensusV2.store_window_ok) already excludes         *)
(*    [2,4) input, [12,16) action, [136,140) marioObj and [148,160)        *)
(*    {statusForCamera,marioBodyState,controller} -- so censused window    *)
(*    stores cannot touch any bm cell a row reads.                         *)
(*                                                                         *)
(* WIRING (the promotion step): a third grounded capstone section in       *)
(* NoAImpliesNoFlyLinked instantiates MWF := MWF_real, consuming the       *)
(* lemmas below for its Hmwf_* hypotheses.                                 *)
(* ====================================================================== *)

From Coq Require Import ZArith List Lia.
From compcert Require Import Coqlib Maps AST Integers Values Events Memory
  Globalenvs Ctypes Cop Clightdefs Clight ClightBigstep Linking Errors.
From SM64.Generated Require mario interaction.
From SM64.Proofs Require Import SymbolicLinking Flying Taint
  ActionValueFrame RealFrameValue RealFrameLinked AGates.
From SM64.Proofs Require Import CensusV2.

Import ListNotations.
Local Open Scope Z_scope.

(* ---- two cast-shape facts feeding the body-store discharge below ----
   sem_cast never turns a Vint INTO a Vptr (any types, any memory): on
   ptr32 the int<->pointer passthrough (cast_case_pointer) passes the
   Vint through unchanged, every other case lands in Vint/Vlong/Vfloat/
   Vsingle or fails. *)
Lemma sem_cast_vint_not_vptr : forall i t1 t2 m v,
    sem_cast (Vint i) t1 t2 m = Some v -> forall bb oo, v <> Vptr bb oo.
Proof.
  intros i t1 t2 m v H bb oo Heq; subst v.
  unfold sem_cast in H.
  destruct (classify_cast t1 t2); cbn in H;
    try discriminate H;
    try (destruct Archi.ptr64; discriminate H).
Qed.

(* a cast landing in tshort (Tint I16) is always cast_case_i2i -- even on
   ptr32, where only an I32 destination triggers the pointer passthrough --
   so the result is a Vint no matter what the source value was. *)
Lemma sem_cast_tint_tshort_vint : forall v2 m v,
    sem_cast v2 tint tshort m = Some v -> exists vi, v = Vint vi.
Proof.
  intros v2 m v H.
  unfold sem_cast in H.
  change (classify_cast tint tshort) with (cast_case_i2i I16 Signed) in H.
  cbv beta iota in H.
  destruct v2; try discriminate H.
  inversion H; subst; eauto.
Qed.

Section MWFReal.
  Variable lp : Clight.program.
  Hypothesis LO_mario : linkorder mario.prog lp.

  (* Mario's MarioState block (runtime, abstract -- see bm-is-runtime). *)
  Variable bm : block.
  (* the controller block + Mario's controller-pointer offset into it:
     fixed across the run (the ctl-ptr cell bm@156 is outside every
     write the run performs -- window-excluded, footprint-excluded). *)
  Variable bc : block.
  Variable oc0 : ptrofs.
  (* the chase-safe block set (still abstract; its instantiation is a
     separate brick -- the rows below only need its closure shape). *)
  Variable SafeB : block -> Prop.

  (* block-distinctness side conditions: the controller, the gms global
     and the censused stored globals are pairwise apart from Mario's
     block / each other / SafeB. Each is per-symbol satisfiable. *)
  Hypothesis Hbc_bm : bc <> bm.
  Hypothesis HSafeB_not_bm : forall b, SafeB b -> b <> bm.
  Hypothesis HSafeB_not_bc : ~ SafeB bc.
  Hypothesis Hgms_blk : forall gb,
      Genv.find_symbol (lp_ge lp) mario._gMarioState = Some gb ->
      gb <> bm /\ gb <> bc /\ ~ SafeB gb.
  Hypothesis Hglob_blk : forall gid bg,
      mem_id gid stored_globals = true ->
      Genv.find_symbol (lp_ge lp) gid = Some bg ->
      bg <> bm /\ bg <> bc /\ ~ SafeB bg.
  (* the gGlobalTimer block: the interaction helpers READ it and store
     its VALUE into object timestamp cells, so its cell carries the R8
     non-pointer row below.  Per-symbol satisfiable like Hgms_blk. *)
  Hypothesis Hgtimer_blk : forall gb,
      Genv.find_symbol (lp_ge lp) interaction._gGlobalTimer = Some gb ->
      gb <> bm /\ gb <> bc /\ ~ SafeB gb.
  (* the sInteractionHandlers block: the dispatch table is a WRITABLE
     static (gvar_readonly = false) holding the 31 handler funptrs, so its
     contents must be CARRIED (row R9 below), grounded on this block being
     disjoint from everything the run stores through.  Per-symbol
     satisfiable like Hgtimer_blk. *)
  Hypothesis Htable_blk : forall tb,
      Genv.find_symbol (lp_ge lp) interaction._sInteractionHandlers
        = Some tb ->
      tb <> bm /\ tb <> bc /\ ~ SafeB tb.

  (* ---------------- the invariant ---------------- *)

  Definition MWF_real (m : mem) : Prop :=
    (* R0: validity (positive, monotone-safe -- NEVER add positive
       LOAD facts here). Covers every block the rows read: without
       e.g. bc's validity, an adversary ALLOCATES it fresh with bad
       content under Hmwf_umbi's unchanged_on premise. *)
    (Mem.valid_block m bm /\ Mem.valid_block m bc
     /\ (forall gb, Genv.find_symbol (lp_ge lp) mario._gMarioState = Some gb ->
            Mem.valid_block m gb)
     /\ (forall b, SafeB b -> Mem.valid_block m b)
     /\ (forall gb, Genv.find_symbol (lp_ge lp) interaction._gGlobalTimer
            = Some gb -> Mem.valid_block m gb)
     /\ (forall tb, Genv.find_symbol (lp_ge lp)
            interaction._sInteractionHandlers = Some tb ->
            Mem.valid_block m tb))
    (* R1: the input A-bit is clear (conditional). *)
    /\ input_a_clear m bm
    (* R2: the controller pointer cell, IF a pointer, is (bc, oc0). *)
    /\ (forall b' o',
           Mem.load Mptr m bm 156 = Some (Vptr b' o') ->
           b' = bc /\ o' = oc0)
    (* R3: the controller's buttonPressed halfword, IF an int, has the
       A_BUTTON bit clear. *)
    /\ (forall v,
           Mem.load Mint16unsigned m bc
             (Ptrofs.unsigned (Ptrofs.add oc0 (Ptrofs.repr 18)))
             = Some (Vint v) ->
           Int.and v (Int.repr 32768) = Int.zero)
    (* R4: the action cell never holds a pointer (Vundef escape). *)
    /\ (forall av,
           Mem.load Mint32 m bm 12 = Some av ->
           av = Vundef \/ exists vi, av = Vint vi)
    (* R5: the gMarioState cell, IF a pointer, is (bm, 0). *)
    /\ (forall gb b o,
           Genv.find_symbol (lp_ge lp) mario._gMarioState = Some gb ->
           Mem.loadv Mptr m (Vptr gb Ptrofs.zero) = Some (Vptr b o) ->
           b = bm /\ o = Ptrofs.zero)
    (* R6: the tabled chase-root cells hold SafeB pointers. *)
    /\ (forall fld delta b' o',
           mem_id fld chase_root_fields = true ->
           field_offset (prog_comp_env mario.prog) fld mario_state_members
             = OK (delta, Full) ->
           Mem.loadv Mptr m
             (Vptr bm (Ptrofs.add Ptrofs.zero (Ptrofs.repr delta)))
             = Some (Vptr b' o') ->
           SafeB b')
    (* R7: SafeB is load-closed. *)
    /\ (forall b ofs b' o',
           SafeB b ->
           Mem.loadv Mptr m (Vptr b ofs) = Some (Vptr b' o') ->
           SafeB b')
    (* R8: the gGlobalTimer cell never holds a pointer.  Its value is
       stored into object rawData (SafeB) cells by the interaction
       helpers; a pointer there would breach R7 through that store. *)
    /\ (forall gb v,
           Genv.find_symbol (lp_ge lp) interaction._gGlobalTimer = Some gb ->
           Mem.load Mint32 m gb 0 = Some v ->
           forall bb oo, v <> Vptr bb oo)
    (* R9: ANY pointer-valued Mptr load from the sInteractionHandlers table
       block aims at a censused handler symbol (ofs 0).  Offset-free on
       purpose: the table is 31 x 8-byte {u32 interactType; funptr handler}
       entries, so every 4-aligned Mptr load hits either an Init_int32 slot
       (a Vint, never matches) or an Init_addrof handler slot -- and the
       offset-free form spares the walk from tracking the loop counter's
       range.  Conditional like R2/R5/R6 -- monotone-safe, never a positive
       load fact.  Consumer: the InterSurface indirect-call arm (find_funct
       on the loaded value then resolves to a pinned internal body). *)
    /\ (forall tb (ofs : Z) b o,
           Genv.find_symbol (lp_ge lp) interaction._sInteractionHandlers
             = Some tb ->
           Mem.load Mptr m tb ofs = Some (Vptr b o) ->
           exists fid,
             In fid interaction_handler_ids /\
             Genv.find_symbol (lp_ge lp) fid = Some b /\
             o = Ptrofs.zero).

  (* ---------------- the projection discharges ----------------
     Each is the v2 capstone hypothesis of the same shape, with
     MWF := MWF_real. *)

  Lemma mwf_real_valid : forall m, MWF_real m -> Mem.valid_block m bm.
  Proof. intros m M. exact (proj1 (proj1 M)). Qed.

  Lemma mwf_real_valid_bc : forall m, MWF_real m -> Mem.valid_block m bc.
  Proof. intros m M. exact (proj1 (proj2 (proj1 M))). Qed.

  (* R0's SafeB-validity conjunct: every chase-reachable block is valid.
     Feeds the local-vars / out-param arc (alloc_variables_hlocal needs
     SafeB blocks valid to prove a fresh local is SafeB-disjoint). *)
  Lemma mwf_real_safe_valid :
    forall m, MWF_real m -> forall b, SafeB b -> Mem.valid_block m b.
  Proof. intros m M. exact (proj1 (proj2 (proj2 (proj2 (proj1 M))))). Qed.

  (* Hmwf_inp *)
  Lemma mwf_real_inp : forall m, MWF_real m -> input_a_clear m bm.
  Proof. intros m M. exact (proj1 (proj2 M)). Qed.

  (* Hmwf_ctl (and, at the capstone's NoA_real, Hmwf_noa) *)
  Lemma mwf_real_ctl : forall m, MWF_real m -> ctl_a_clear m bm.
  Proof.
    intros m (_ & _ & R2 & R3 & _) bc' oc' v Hld156 Hldbtn.
    destruct (R2 _ _ Hld156) as [Eb Eo]. subst bc' oc'.
    exact (R3 _ Hldbtn).
  Qed.

  (* HactVint *)
  Lemma mwf_real_act_vint : forall m, MWF_real m -> forall av,
      Mem.load Mint32 m bm 12 = Some av ->
      av = Vundef \/ exists vi, av = Vint vi.
  Proof. intros m (_ & _ & _ & _ & R4 & _) av H. exact (R4 _ H). Qed.

  (* HPgms (conditional shape) *)
  Lemma mwf_real_pgms : forall m gb b o, MWF_real m ->
      Genv.find_symbol (lp_ge lp) mario._gMarioState = Some gb ->
      Mem.loadv Mptr m (Vptr gb Ptrofs.zero) = Some (Vptr b o) ->
      b = bm /\ o = Ptrofs.zero.
  Proof.
    intros m gb b o (_ & _ & _ & _ & _ & R5 & _) Hfs Hld.
    exact (R5 _ _ _ Hfs Hld).
  Qed.

  (* HchaseRoot *)
  Lemma mwf_real_chase_root : forall fld delta m b' o',
      mem_id fld chase_root_fields = true ->
      field_offset (prog_comp_env mario.prog) fld mario_state_members
        = OK (delta, Full) ->
      MWF_real m ->
      Mem.loadv Mptr m (Vptr bm (Ptrofs.add Ptrofs.zero (Ptrofs.repr delta)))
        = Some (Vptr b' o') ->
      SafeB b'.
  Proof.
    intros fld delta m b' o' Hmem Hfo (_ & _ & _ & _ & _ & _ & R6 & _) Hld.
    exact (R6 _ _ _ _ Hmem Hfo Hld).
  Qed.

  (* HchaseStep *)
  Lemma mwf_real_chase_step : forall m b ofs b' o',
      MWF_real m -> SafeB b ->
      Mem.loadv Mptr m (Vptr b ofs) = Some (Vptr b' o') -> SafeB b'.
  Proof.
    intros m b ofs b' o' (_ & _ & _ & _ & _ & _ & _ & R7 & _) Hs Hld.
    exact (R7 _ _ _ _ Hs Hld).
  Qed.

  (* HMWF_sglob *)
  Lemma mwf_real_sglob : forall m gb v, MWF_real m ->
      Genv.find_symbol (lp_ge lp) interaction._gGlobalTimer = Some gb ->
      Mem.load Mint32 m gb 0 = Some v ->
      forall bb oo, v <> Vptr bb oo.
  Proof.
    intros m gb v (_ & _ & _ & _ & _ & _ & _ & _ & R8 & _) Hfs Hld.
    exact (R8 _ _ Hfs Hld).
  Qed.

  (* the R9 projection: the table row the InterSurface indirect-call arm
     consumes. *)
  Lemma mwf_real_itab : forall m tb (ofs : Z) b o, MWF_real m ->
      Genv.find_symbol (lp_ge lp) interaction._sInteractionHandlers
        = Some tb ->
      Mem.load Mptr m tb ofs = Some (Vptr b o) ->
      exists fid,
        In fid interaction_handler_ids /\
        Genv.find_symbol (lp_ge lp) fid = Some b /\
        o = Ptrofs.zero.
  Proof.
    intros m tb ofs b o (_ & _ & _ & _ & _ & _ & _ & _ & _ & R9) Hfs Hld.
    exact (R9 _ _ _ _ Hfs Hld).
  Qed.

  (* ---------------- the row-transfer core ----------------
     Every "MWF_real survives operation X" lemma below reduces to:
     (a) validity monotonicity, (b) load transfer on the PINNED row
     cells (the bm windows / the controller block / the gms cell),
     (c) R1 and R7 re-established directly (each operation has its own
     argument: same-cell stored value, footprint, ptr-store refutation,
     or full transfer). *)

  (* the eight tabled chase-root cells, as literals (vm_compute over the
     generated composite layout) *)
  Lemma chase_root_offsets : forall fld delta,
      mem_id fld chase_root_fields = true ->
      field_offset (prog_comp_env mario.prog) fld mario_state_members
        = OK (delta, Full) ->
      delta = 136 \/ delta = 148 \/ delta = 152
      \/ delta = 124 \/ delta = 128 \/ delta = 132 \/ delta = 160
      \/ delta = 120.
  Proof.
    intros fld delta Hmem Hfo.
    change ((Pos.eqb fld mario._marioObj
             || (Pos.eqb fld mario._marioBodyState
                 || (Pos.eqb fld mario._statusForCamera
                     || (Pos.eqb fld mario._heldObj
                         || (Pos.eqb fld mario._usedObj
                             || (Pos.eqb fld mario._riddenObj
                                 || (Pos.eqb fld mario._animList
                                     || (Pos.eqb fld mario._interactObj
                                         || false))))))))%bool = true)
      in Hmem.
    repeat (apply orb_true_iff in Hmem; destruct Hmem as [Hm | Hmem]);
      try discriminate Hmem; apply Pos.eqb_eq in Hm; subst fld.
    - assert (E : field_offset (prog_comp_env mario.prog) mario._marioObj
                    mario_state_members = OK (136, Full))
        by (vm_compute; reflexivity).
      rewrite E in Hfo. inv Hfo. auto.
    - assert (E : field_offset (prog_comp_env mario.prog) mario._marioBodyState
                    mario_state_members = OK (152, Full))
        by (vm_compute; reflexivity).
      rewrite E in Hfo. inv Hfo. auto 7.
    - assert (E : field_offset (prog_comp_env mario.prog) mario._statusForCamera
                    mario_state_members = OK (148, Full))
        by (vm_compute; reflexivity).
      rewrite E in Hfo. inv Hfo. auto.
    - assert (E : field_offset (prog_comp_env mario.prog) mario._heldObj
                    mario_state_members = OK (124, Full))
        by (vm_compute; reflexivity).
      rewrite E in Hfo. inv Hfo. auto 7.
    - assert (E : field_offset (prog_comp_env mario.prog) mario._usedObj
                    mario_state_members = OK (128, Full))
        by (vm_compute; reflexivity).
      rewrite E in Hfo. inv Hfo. auto 8.
    - assert (E : field_offset (prog_comp_env mario.prog) mario._riddenObj
                    mario_state_members = OK (132, Full))
        by (vm_compute; reflexivity).
      rewrite E in Hfo. inv Hfo. auto 9.
    - assert (E : field_offset (prog_comp_env mario.prog) mario._animList
                    mario_state_members = OK (160, Full))
        by (vm_compute; reflexivity).
      rewrite E in Hfo. inv Hfo. auto 9.
    - assert (E : field_offset (prog_comp_env mario.prog) mario._interactObj
                    mario_state_members = OK (120, Full))
        by (vm_compute; reflexivity).
      rewrite E in Hfo. inv Hfo. auto 10.
  Qed.

  Definition bm_row_cell (ofs sz : Z) : Prop :=
    (12 <= ofs /\ ofs + sz <= 16)
    \/ (120 <= ofs /\ ofs + sz <= 140)
    \/ (148 <= ofs /\ ofs + sz <= 164).

  Lemma MWF_real_transfer : forall m m',
      (forall b, Mem.valid_block m b -> Mem.valid_block m' b) ->
      input_a_clear m' bm ->
      (forall ch b ofs v,
          (b = bm /\ bm_row_cell ofs (size_chunk ch))
          \/ b = bc
          \/ Genv.find_symbol (lp_ge lp) mario._gMarioState = Some b
          \/ Genv.find_symbol (lp_ge lp) interaction._gGlobalTimer = Some b
          \/ Genv.find_symbol (lp_ge lp) interaction._sInteractionHandlers
             = Some b ->
          Mem.load ch m' b ofs = Some v -> Mem.load ch m b ofs = Some v) ->
      (forall b ofs b' o', SafeB b ->
          Mem.loadv Mptr m' (Vptr b ofs) = Some (Vptr b' o') -> SafeB b') ->
      MWF_real m -> MWF_real m'.
  Proof.
    intros m m' Hval Hinp' Htr Hsafe'
           ((Vbm & Vbc & Vgms & Vsafe & Vgt & Vtb)
            & _ & R2 & R3 & R4 & R5 & R6 & R7 & R8 & R9).
    split;
      [ | split; [ exact Hinp'
        | split; [ | split; [ | split; [ | split; [ | split;
            [ | split; [ exact Hsafe' | split ]]]]]]]].
    - (* R0 *)
      split; [ exact (Hval _ Vbm)
             | split; [ exact (Hval _ Vbc) | split; [ | split; [ | split ] ] ] ].
      + intros gb Hfs. exact (Hval _ (Vgms _ Hfs)).
      + intros b Hb. exact (Hval _ (Vsafe _ Hb)).
      + intros gb Hfs. exact (Hval _ (Vgt _ Hfs)).
      + intros tb Hfs. exact (Hval _ (Vtb _ Hfs)).
    - (* R2 *)
      intros b' o' Hld. apply R2.
      apply (Htr Mptr bm 156 (Vptr b' o')); [ | exact Hld ].
      left. split; [ reflexivity | ]. right. right.
      change (size_chunk Mptr) with 4. lia.
    - (* R3 *)
      intros v Hld. apply R3.
      apply (Htr _ bc _ (Vint v)); [ right; left; reflexivity | exact Hld ].
    - (* R4 *)
      intros av Hld. apply R4.
      apply (Htr Mint32 bm 12 av); [ | exact Hld ].
      left. split; [ reflexivity | ]. left.
      change (size_chunk Mint32) with 4. lia.
    - (* R5 *)
      intros gb b o Hfs Hld. eapply R5; [ exact Hfs | ].
      change (Mem.loadv Mptr m' (Vptr gb Ptrofs.zero))
        with (Mem.load Mptr m' gb 0) in Hld.
      change (Mem.loadv Mptr m (Vptr gb Ptrofs.zero))
        with (Mem.load Mptr m gb 0).
      apply (Htr Mptr gb 0 (Vptr b o));
        [ right; right; left; exact Hfs | exact Hld ].
    - (* R6 *)
      intros fld delta b' o' Hmem Hfo Hld.
      eapply R6; [ exact Hmem | exact Hfo | ].
      destruct (chase_root_offsets _ _ Hmem Hfo)
        as [E | [E | [E | [E | [E | [E | [E | E]]]]]]]; subst delta.
      + change (Mem.loadv Mptr m'
                  (Vptr bm (Ptrofs.add Ptrofs.zero (Ptrofs.repr 136))))
          with (Mem.load Mptr m' bm 136) in Hld.
        change (Mem.loadv Mptr m
                  (Vptr bm (Ptrofs.add Ptrofs.zero (Ptrofs.repr 136))))
          with (Mem.load Mptr m bm 136).
        apply (Htr Mptr bm 136 (Vptr b' o')); [ | exact Hld ].
        left. split; [ reflexivity | ]. right. left.
        change (size_chunk Mptr) with 4. lia.
      + change (Mem.loadv Mptr m'
                  (Vptr bm (Ptrofs.add Ptrofs.zero (Ptrofs.repr 148))))
          with (Mem.load Mptr m' bm 148) in Hld.
        change (Mem.loadv Mptr m
                  (Vptr bm (Ptrofs.add Ptrofs.zero (Ptrofs.repr 148))))
          with (Mem.load Mptr m bm 148).
        apply (Htr Mptr bm 148 (Vptr b' o')); [ | exact Hld ].
        left. split; [ reflexivity | ]. right. right.
        change (size_chunk Mptr) with 4. lia.
      + change (Mem.loadv Mptr m'
                  (Vptr bm (Ptrofs.add Ptrofs.zero (Ptrofs.repr 152))))
          with (Mem.load Mptr m' bm 152) in Hld.
        change (Mem.loadv Mptr m
                  (Vptr bm (Ptrofs.add Ptrofs.zero (Ptrofs.repr 152))))
          with (Mem.load Mptr m bm 152).
        apply (Htr Mptr bm 152 (Vptr b' o')); [ | exact Hld ].
        left. split; [ reflexivity | ]. right. right.
        change (size_chunk Mptr) with 4. lia.
      + change (Mem.loadv Mptr m'
                  (Vptr bm (Ptrofs.add Ptrofs.zero (Ptrofs.repr 124))))
          with (Mem.load Mptr m' bm 124) in Hld.
        change (Mem.loadv Mptr m
                  (Vptr bm (Ptrofs.add Ptrofs.zero (Ptrofs.repr 124))))
          with (Mem.load Mptr m bm 124).
        apply (Htr Mptr bm 124 (Vptr b' o')); [ | exact Hld ].
        left. split; [ reflexivity | ]. right. left.
        change (size_chunk Mptr) with 4. lia.
      + change (Mem.loadv Mptr m'
                  (Vptr bm (Ptrofs.add Ptrofs.zero (Ptrofs.repr 128))))
          with (Mem.load Mptr m' bm 128) in Hld.
        change (Mem.loadv Mptr m
                  (Vptr bm (Ptrofs.add Ptrofs.zero (Ptrofs.repr 128))))
          with (Mem.load Mptr m bm 128).
        apply (Htr Mptr bm 128 (Vptr b' o')); [ | exact Hld ].
        left. split; [ reflexivity | ]. right. left.
        change (size_chunk Mptr) with 4. lia.
      + change (Mem.loadv Mptr m'
                  (Vptr bm (Ptrofs.add Ptrofs.zero (Ptrofs.repr 132))))
          with (Mem.load Mptr m' bm 132) in Hld.
        change (Mem.loadv Mptr m
                  (Vptr bm (Ptrofs.add Ptrofs.zero (Ptrofs.repr 132))))
          with (Mem.load Mptr m bm 132).
        apply (Htr Mptr bm 132 (Vptr b' o')); [ | exact Hld ].
        left. split; [ reflexivity | ]. right. left.
        change (size_chunk Mptr) with 4. lia.
      + change (Mem.loadv Mptr m'
                  (Vptr bm (Ptrofs.add Ptrofs.zero (Ptrofs.repr 160))))
          with (Mem.load Mptr m' bm 160) in Hld.
        change (Mem.loadv Mptr m
                  (Vptr bm (Ptrofs.add Ptrofs.zero (Ptrofs.repr 160))))
          with (Mem.load Mptr m bm 160).
        apply (Htr Mptr bm 160 (Vptr b' o')); [ | exact Hld ].
        left. split; [ reflexivity | ]. right. right.
        change (size_chunk Mptr) with 4. lia.
      + change (Mem.loadv Mptr m'
                  (Vptr bm (Ptrofs.add Ptrofs.zero (Ptrofs.repr 120))))
          with (Mem.load Mptr m' bm 120) in Hld.
        change (Mem.loadv Mptr m
                  (Vptr bm (Ptrofs.add Ptrofs.zero (Ptrofs.repr 120))))
          with (Mem.load Mptr m bm 120).
        apply (Htr Mptr bm 120 (Vptr b' o')); [ | exact Hld ].
        left. split; [ reflexivity | ]. right. left.
        change (size_chunk Mptr) with 4. lia.
    - (* R8 *)
      intros gb v Hfs Hld. eapply R8; [ exact Hfs | ].
      apply (Htr Mint32 gb 0 v);
        [ right; right; right; left; exact Hfs | exact Hld ].
    - (* R9 *)
      intros tb ofs b o Hfs Hld.
      eapply R9; [ exact Hfs | ].
      apply (Htr Mptr tb ofs (Vptr b o));
        [ right; right; right; right; exact Hfs | exact Hld ].
  Qed.

  (* ---------------- Hmwf_window ---------------- *)
  Lemma mwf_real_window : forall mm mm' ch (delta : Z) vv,
      MWF_real mm -> store_window_ok delta (size_chunk ch) = true ->
      Mem.store ch mm bm delta vv = Some mm' -> MWF_real mm'.
  Proof.
    intros mm mm' ch delta vv M Hwin Hst.
    unfold store_window_ok in Hwin.
    apply andb_true_iff in Hwin as [Hwin Hw148].
    apply andb_true_iff in Hwin as [Hwin Hw136].
    apply andb_true_iff in Hwin as [Hwin Hw12].
    apply andb_true_iff in Hwin as [_ Hw2].
    assert (W2 : delta + size_chunk ch <= 2 \/ 4 <= delta)
      by (apply orb_true_iff in Hw2 as [h|h]; apply Z.leb_le in h; auto).
    assert (W12 : delta + size_chunk ch <= 12 \/ 16 <= delta)
      by (apply orb_true_iff in Hw12 as [h|h]; apply Z.leb_le in h; auto).
    assert (W136 : delta + size_chunk ch <= 120 \/ 140 <= delta)
      by (apply orb_true_iff in Hw136 as [h|h]; apply Z.leb_le in h; auto).
    assert (W148 : delta + size_chunk ch <= 148 \/ 164 <= delta)
      by (apply orb_true_iff in Hw148 as [h|h]; apply Z.leb_le in h; auto).
    pose proof M as (_ & R1 & _).
    apply (MWF_real_transfer mm mm'); [ .. | exact M ].
    - intros b Hv. eapply Mem.store_valid_block_1; eauto.
    - (* R1: the [2,4) cell is window-excluded *)
      intros v Hld. apply R1.
      rewrite <- Hld. symmetry.
      eapply Mem.load_store_other; [ exact Hst | right ].
      change (size_chunk Mint16unsigned) with 2. lia.
    - (* the pinned row cells *)
      intros ch0 b ofs v Hrow Hld.
      rewrite <- Hld. symmetry.
      eapply Mem.load_store_other; [ exact Hst | ].
      destruct Hrow as [ [Eb Hcell] | [ Eb | [ Hfs | [ Hfs | Hfs ] ] ] ].
      + subst b. right. unfold bm_row_cell in Hcell. lia.
      + subst b. left. exact Hbc_bm.
      + left. exact (proj1 (Hgms_blk _ Hfs)).
      + left. exact (proj1 (Hgtimer_blk _ Hfs)).
      + left. exact (proj1 (Htable_blk _ Hfs)).
    - (* R7: SafeB blocks are not bm *)
      intros b ofs b' o' Hs Hld.
      destruct M as (_ & _ & _ & _ & _ & _ & _ & R7 & _).
      apply (R7 b ofs b' o' Hs).
      cbn in Hld |- *. rewrite <- Hld. symmetry.
      eapply Mem.load_store_other;
        [ exact Hst | left; exact (HSafeB_not_bm _ Hs) ].
  Qed.

  (* ---------------- the ACTION-CELL store row ----------------
     The one store the window deliberately excludes: writing the action
     field itself (bm, [12,16)).  MWF_real survives ANY non-pointer
     value there: R4 is re-established from the stored value (Vint
     stays Vint, everything else decodes to Vundef; a Vptr would
     SURVIVE a Mint32 round-trip on ptr64=false, hence the premise),
     and every other row's cell is disjoint from [12,16).  The taint
     side (the stored value being untainted) is NOT this lemma's job:
     action_sat is the separately-carried fact, updated by
     load_store_same at the consumer (the act-writer surface). *)
  Lemma mwf_real_act_store : forall mm mm' vv,
      MWF_real mm ->
      (forall bb oo, vv <> Vptr bb oo) ->
      Mem.store Mint32 mm bm 12 vv = Some mm' -> MWF_real mm'.
  Proof.
    intros mm mm' vv M Hnoptr Hst.
    destruct M as ((Vbm & Vbc & Vgms & Vsafe & Vgt & Vtb)
                   & R1 & R2 & R3 & R4 & R5 & R6 & R7 & R8 & R9).
    split; [ | split; [ | split; [ | split; [ | split;
      [ | split; [ | split; [ | split; [ | split ]]]]]]]].
    - (* R0: validity is store-stable *)
      split; [ eapply Mem.store_valid_block_1; eauto | ].
      split; [ eapply Mem.store_valid_block_1; eauto | ].
      split; [ | split; [ | split ] ].
      + intros gb Hfs. eapply Mem.store_valid_block_1;
          [ exact Hst | exact (Vgms _ Hfs) ].
      + intros b Hb. eapply Mem.store_valid_block_1;
          [ exact Hst | exact (Vsafe _ Hb) ].
      + intros gb Hfs. eapply Mem.store_valid_block_1;
          [ exact Hst | exact (Vgt _ Hfs) ].
      + intros tb Hfs. eapply Mem.store_valid_block_1;
          [ exact Hst | exact (Vtb _ Hfs) ].
    - (* R1: [2,4) ends before the store's [12,16) *)
      intros v Hld. apply R1.
      rewrite <- Hld. symmetry.
      eapply Mem.load_store_other; [ exact Hst | right; left ].
      change (size_chunk Mint16unsigned) with 2. lia.
    - (* R2: the store's [12,16) ends before [156,160) *)
      intros b' o' Hld. apply R2.
      rewrite <- Hld. symmetry.
      eapply Mem.load_store_other; [ exact Hst | right; right ].
      change (size_chunk Mint32) with 4. lia.
    - (* R3: bc is not bm *)
      intros v Hld. apply R3.
      rewrite <- Hld. symmetry.
      eapply Mem.load_store_other; [ exact Hst | left; exact Hbc_bm ].
    - (* R4: THE stored cell -- re-established from the stored value *)
      intros av Hld.
      rewrite (Mem.load_store_same _ _ _ _ _ _ Hst) in Hld.
      injection Hld as <-.
      destruct vv as [ | vi | | | | bb oo ].
      + left; reflexivity.
      + right; eexists; reflexivity.
      + left; reflexivity.
      + left; reflexivity.
      + left; reflexivity.
      + exfalso; exact (Hnoptr bb oo eq_refl).
    - (* R5: the gMarioState block is not bm *)
      intros gb b o Hfs Hld. eapply R5; [ exact Hfs | ].
      change (Mem.loadv Mptr mm' (Vptr gb Ptrofs.zero))
        with (Mem.load Mptr mm' gb 0) in Hld.
      change (Mem.loadv Mptr mm (Vptr gb Ptrofs.zero))
        with (Mem.load Mptr mm gb 0).
      rewrite <- Hld. symmetry.
      eapply Mem.load_store_other;
        [ exact Hst | left; exact (proj1 (Hgms_blk _ Hfs)) ].
    - (* R6: chase roots live at 120..136/148..160, past the store's end *)
      intros fld delta b' o' Hmem Hfo Hld.
      eapply R6; [ exact Hmem | exact Hfo | ].
      destruct (chase_root_offsets _ _ Hmem Hfo)
        as [E | [E | [E | [E | [E | [E | [E | E]]]]]]]; subst delta.
      + change (Mem.loadv Mptr mm'
                  (Vptr bm (Ptrofs.add Ptrofs.zero (Ptrofs.repr 136))))
          with (Mem.load Mptr mm' bm 136) in Hld.
        change (Mem.loadv Mptr mm
                  (Vptr bm (Ptrofs.add Ptrofs.zero (Ptrofs.repr 136))))
          with (Mem.load Mptr mm bm 136).
        rewrite <- Hld. symmetry.
        eapply Mem.load_store_other; [ exact Hst | right; right ].
        change (size_chunk Mint32) with 4. lia.
      + change (Mem.loadv Mptr mm'
                  (Vptr bm (Ptrofs.add Ptrofs.zero (Ptrofs.repr 148))))
          with (Mem.load Mptr mm' bm 148) in Hld.
        change (Mem.loadv Mptr mm
                  (Vptr bm (Ptrofs.add Ptrofs.zero (Ptrofs.repr 148))))
          with (Mem.load Mptr mm bm 148).
        rewrite <- Hld. symmetry.
        eapply Mem.load_store_other; [ exact Hst | right; right ].
        change (size_chunk Mint32) with 4. lia.
      + change (Mem.loadv Mptr mm'
                  (Vptr bm (Ptrofs.add Ptrofs.zero (Ptrofs.repr 152))))
          with (Mem.load Mptr mm' bm 152) in Hld.
        change (Mem.loadv Mptr mm
                  (Vptr bm (Ptrofs.add Ptrofs.zero (Ptrofs.repr 152))))
          with (Mem.load Mptr mm bm 152).
        rewrite <- Hld. symmetry.
        eapply Mem.load_store_other; [ exact Hst | right; right ].
        change (size_chunk Mint32) with 4. lia.
      + change (Mem.loadv Mptr mm'
                  (Vptr bm (Ptrofs.add Ptrofs.zero (Ptrofs.repr 124))))
          with (Mem.load Mptr mm' bm 124) in Hld.
        change (Mem.loadv Mptr mm
                  (Vptr bm (Ptrofs.add Ptrofs.zero (Ptrofs.repr 124))))
          with (Mem.load Mptr mm bm 124).
        rewrite <- Hld. symmetry.
        eapply Mem.load_store_other; [ exact Hst | right; right ].
        change (size_chunk Mint32) with 4. lia.
      + change (Mem.loadv Mptr mm'
                  (Vptr bm (Ptrofs.add Ptrofs.zero (Ptrofs.repr 128))))
          with (Mem.load Mptr mm' bm 128) in Hld.
        change (Mem.loadv Mptr mm
                  (Vptr bm (Ptrofs.add Ptrofs.zero (Ptrofs.repr 128))))
          with (Mem.load Mptr mm bm 128).
        rewrite <- Hld. symmetry.
        eapply Mem.load_store_other; [ exact Hst | right; right ].
        change (size_chunk Mint32) with 4. lia.
      + change (Mem.loadv Mptr mm'
                  (Vptr bm (Ptrofs.add Ptrofs.zero (Ptrofs.repr 132))))
          with (Mem.load Mptr mm' bm 132) in Hld.
        change (Mem.loadv Mptr mm
                  (Vptr bm (Ptrofs.add Ptrofs.zero (Ptrofs.repr 132))))
          with (Mem.load Mptr mm bm 132).
        rewrite <- Hld. symmetry.
        eapply Mem.load_store_other; [ exact Hst | right; right ].
        change (size_chunk Mint32) with 4. lia.
      + change (Mem.loadv Mptr mm'
                  (Vptr bm (Ptrofs.add Ptrofs.zero (Ptrofs.repr 160))))
          with (Mem.load Mptr mm' bm 160) in Hld.
        change (Mem.loadv Mptr mm
                  (Vptr bm (Ptrofs.add Ptrofs.zero (Ptrofs.repr 160))))
          with (Mem.load Mptr mm bm 160).
        rewrite <- Hld. symmetry.
        eapply Mem.load_store_other; [ exact Hst | right; right ].
        change (size_chunk Mint32) with 4. lia.
      + change (Mem.loadv Mptr mm'
                  (Vptr bm (Ptrofs.add Ptrofs.zero (Ptrofs.repr 120))))
          with (Mem.load Mptr mm' bm 120) in Hld.
        change (Mem.loadv Mptr mm
                  (Vptr bm (Ptrofs.add Ptrofs.zero (Ptrofs.repr 120))))
          with (Mem.load Mptr mm bm 120).
        rewrite <- Hld. symmetry.
        eapply Mem.load_store_other; [ exact Hst | right; right ].
        change (size_chunk Mint32) with 4. lia.
    - (* R7: SafeB blocks are not bm *)
      intros b ofs b' o' Hs Hld.
      apply (R7 b ofs b' o' Hs).
      cbn in Hld |- *. rewrite <- Hld. symmetry.
      eapply Mem.load_store_other;
        [ exact Hst | left; exact (HSafeB_not_bm _ Hs) ].
    - (* R8: the gGlobalTimer block is not bm *)
      intros gb v Hfs Hld. eapply R8; [ exact Hfs | ].
      rewrite <- Hld. symmetry.
      eapply Mem.load_store_other;
        [ exact Hst | left; exact (proj1 (Hgtimer_blk _ Hfs)) ].
    - (* R9: the table block is not bm *)
      intros tb ofs2 b o Hfs Hld.
      eapply R9; [ exact Hfs | ].
      rewrite <- Hld. symmetry.
      eapply Mem.load_store_other;
        [ exact Hst | left; exact (proj1 (Htable_blk _ Hfs)) ].
  Qed.

  (* ---------------- the chase-ROOT-cell store row ----------------
     The object-family helpers write the tabled root cells THEMSELVES
     (mario_grab_used_object: m->heldObj = m->usedObj; the drop/throw
     helpers: m->heldObj = NULL).  MWF_real survives storing any value
     that is SafeB-if-a-pointer into a root cell: R6 on the stored
     cell is re-established from the premise (a Vptr survives the
     Mptr round-trip on ptr64=false; everything else decodes away
     from Vptr), every OTHER root cell is >= 4 bytes apart (the 8
     root literals are 4-separated), and the low cells ([2,4) input,
     [12,16) action) end before 120. *)
  Lemma mwf_real_root_store : forall mm mm' fld delta vv,
      mem_id fld chase_root_fields = true ->
      field_offset (prog_comp_env mario.prog) fld mario_state_members
        = OK (delta, Full) ->
      (forall bb oo, vv = Vptr bb oo -> SafeB bb) ->
      MWF_real mm ->
      Mem.store Mptr mm bm delta vv = Some mm' -> MWF_real mm'.
  Proof.
    intros mm mm' fld delta vv Hmem Hfo Hsafe M Hst.
    pose proof (chase_root_offsets _ _ Hmem Hfo) as Hd7.
    destruct M as ((Vbm & Vbc & Vgms & Vsafe & Vgt & Vtb)
                   & R1 & R2 & R3 & R4 & R5 & R6 & R7 & R8 & R9).
    split; [ | split; [ | split; [ | split; [ | split;
      [ | split; [ | split; [ | split; [ | split ]]]]]]]].
    - (* R0: validity is store-stable *)
      split; [ eapply Mem.store_valid_block_1; eauto | ].
      split; [ eapply Mem.store_valid_block_1; eauto | ].
      split; [ | split; [ | split ] ].
      + intros gb Hfs. eapply Mem.store_valid_block_1;
          [ exact Hst | exact (Vgms _ Hfs) ].
      + intros b Hb. eapply Mem.store_valid_block_1;
          [ exact Hst | exact (Vsafe _ Hb) ].
      + intros gb Hfs. eapply Mem.store_valid_block_1;
          [ exact Hst | exact (Vgt _ Hfs) ].
      + intros tb Hfs. eapply Mem.store_valid_block_1;
          [ exact Hst | exact (Vtb _ Hfs) ].
    - (* R1: [2,4) ends before every root cell *)
      intros v Hld. apply R1.
      rewrite <- Hld. symmetry.
      eapply Mem.load_store_other; [ exact Hst | right; left ].
      change (size_chunk Mint16unsigned) with 2. lia.
    - (* R2: [156,160) is 4-separated from every root cell *)
      intros b' o' Hld. apply R2.
      rewrite <- Hld. symmetry.
      eapply Mem.load_store_other; [ exact Hst | right ].
      change (size_chunk Mptr) with 4. lia.
    - (* R3: bc is not bm *)
      intros v Hld. apply R3.
      rewrite <- Hld. symmetry.
      eapply Mem.load_store_other; [ exact Hst | left; exact Hbc_bm ].
    - (* R4: [12,16) ends before every root cell *)
      intros av Hld. apply R4.
      rewrite <- Hld. symmetry.
      eapply Mem.load_store_other; [ exact Hst | right; left ].
      change (size_chunk Mint32) with 4. lia.
    - (* R5: the gMarioState block is not bm *)
      intros gb b o Hfs Hld. eapply R5; [ exact Hfs | ].
      change (Mem.loadv Mptr mm' (Vptr gb Ptrofs.zero))
        with (Mem.load Mptr mm' gb 0) in Hld.
      change (Mem.loadv Mptr mm (Vptr gb Ptrofs.zero))
        with (Mem.load Mptr mm gb 0).
      rewrite <- Hld. symmetry.
      eapply Mem.load_store_other;
        [ exact Hst | left; exact (proj1 (Hgms_blk _ Hfs)) ].
    - (* R6: the stored cell via the premise; other roots 4-separated *)
      intros fld' delta' b' o' Hmem' Hfo' Hld.
      destruct (chase_root_offsets _ _ Hmem' Hfo')
        as [E | [E | [E | [E | [E | [E | [E | E]]]]]]]; subst delta'.
      + change (Mem.loadv Mptr mm'
                  (Vptr bm (Ptrofs.add Ptrofs.zero (Ptrofs.repr 136))))
          with (Mem.load Mptr mm' bm 136) in Hld.
        destruct (Z.eq_dec delta 136) as [-> | Hne].
        * rewrite (Mem.load_store_same _ _ _ _ _ _ Hst) in Hld.
          injection Hld as E.
          destruct vv as [ | vi | vl | vf | vs | bb oo ]; try discriminate E.
          injection E as E1 E2; subst.
          exact (Hsafe _ _ eq_refl).
        * eapply R6; [ exact Hmem' | exact Hfo' | ].
          change (Mem.loadv Mptr mm
                    (Vptr bm (Ptrofs.add Ptrofs.zero (Ptrofs.repr 136))))
            with (Mem.load Mptr mm bm 136).
          rewrite <- Hld. symmetry.
          eapply Mem.load_store_other; [ exact Hst | right ].
          change (size_chunk Mptr) with 4. lia.
      + change (Mem.loadv Mptr mm'
                  (Vptr bm (Ptrofs.add Ptrofs.zero (Ptrofs.repr 148))))
          with (Mem.load Mptr mm' bm 148) in Hld.
        destruct (Z.eq_dec delta 148) as [-> | Hne].
        * rewrite (Mem.load_store_same _ _ _ _ _ _ Hst) in Hld.
          injection Hld as E.
          destruct vv as [ | vi | vl | vf | vs | bb oo ]; try discriminate E.
          injection E as E1 E2; subst.
          exact (Hsafe _ _ eq_refl).
        * eapply R6; [ exact Hmem' | exact Hfo' | ].
          change (Mem.loadv Mptr mm
                    (Vptr bm (Ptrofs.add Ptrofs.zero (Ptrofs.repr 148))))
            with (Mem.load Mptr mm bm 148).
          rewrite <- Hld. symmetry.
          eapply Mem.load_store_other; [ exact Hst | right ].
          change (size_chunk Mptr) with 4. lia.
      + change (Mem.loadv Mptr mm'
                  (Vptr bm (Ptrofs.add Ptrofs.zero (Ptrofs.repr 152))))
          with (Mem.load Mptr mm' bm 152) in Hld.
        destruct (Z.eq_dec delta 152) as [-> | Hne].
        * rewrite (Mem.load_store_same _ _ _ _ _ _ Hst) in Hld.
          injection Hld as E.
          destruct vv as [ | vi | vl | vf | vs | bb oo ]; try discriminate E.
          injection E as E1 E2; subst.
          exact (Hsafe _ _ eq_refl).
        * eapply R6; [ exact Hmem' | exact Hfo' | ].
          change (Mem.loadv Mptr mm
                    (Vptr bm (Ptrofs.add Ptrofs.zero (Ptrofs.repr 152))))
            with (Mem.load Mptr mm bm 152).
          rewrite <- Hld. symmetry.
          eapply Mem.load_store_other; [ exact Hst | right ].
          change (size_chunk Mptr) with 4. lia.
      + change (Mem.loadv Mptr mm'
                  (Vptr bm (Ptrofs.add Ptrofs.zero (Ptrofs.repr 124))))
          with (Mem.load Mptr mm' bm 124) in Hld.
        destruct (Z.eq_dec delta 124) as [-> | Hne].
        * rewrite (Mem.load_store_same _ _ _ _ _ _ Hst) in Hld.
          injection Hld as E.
          destruct vv as [ | vi | vl | vf | vs | bb oo ]; try discriminate E.
          injection E as E1 E2; subst.
          exact (Hsafe _ _ eq_refl).
        * eapply R6; [ exact Hmem' | exact Hfo' | ].
          change (Mem.loadv Mptr mm
                    (Vptr bm (Ptrofs.add Ptrofs.zero (Ptrofs.repr 124))))
            with (Mem.load Mptr mm bm 124).
          rewrite <- Hld. symmetry.
          eapply Mem.load_store_other; [ exact Hst | right ].
          change (size_chunk Mptr) with 4. lia.
      + change (Mem.loadv Mptr mm'
                  (Vptr bm (Ptrofs.add Ptrofs.zero (Ptrofs.repr 128))))
          with (Mem.load Mptr mm' bm 128) in Hld.
        destruct (Z.eq_dec delta 128) as [-> | Hne].
        * rewrite (Mem.load_store_same _ _ _ _ _ _ Hst) in Hld.
          injection Hld as E.
          destruct vv as [ | vi | vl | vf | vs | bb oo ]; try discriminate E.
          injection E as E1 E2; subst.
          exact (Hsafe _ _ eq_refl).
        * eapply R6; [ exact Hmem' | exact Hfo' | ].
          change (Mem.loadv Mptr mm
                    (Vptr bm (Ptrofs.add Ptrofs.zero (Ptrofs.repr 128))))
            with (Mem.load Mptr mm bm 128).
          rewrite <- Hld. symmetry.
          eapply Mem.load_store_other; [ exact Hst | right ].
          change (size_chunk Mptr) with 4. lia.
      + change (Mem.loadv Mptr mm'
                  (Vptr bm (Ptrofs.add Ptrofs.zero (Ptrofs.repr 132))))
          with (Mem.load Mptr mm' bm 132) in Hld.
        destruct (Z.eq_dec delta 132) as [-> | Hne].
        * rewrite (Mem.load_store_same _ _ _ _ _ _ Hst) in Hld.
          injection Hld as E.
          destruct vv as [ | vi | vl | vf | vs | bb oo ]; try discriminate E.
          injection E as E1 E2; subst.
          exact (Hsafe _ _ eq_refl).
        * eapply R6; [ exact Hmem' | exact Hfo' | ].
          change (Mem.loadv Mptr mm
                    (Vptr bm (Ptrofs.add Ptrofs.zero (Ptrofs.repr 132))))
            with (Mem.load Mptr mm bm 132).
          rewrite <- Hld. symmetry.
          eapply Mem.load_store_other; [ exact Hst | right ].
          change (size_chunk Mptr) with 4. lia.
      + change (Mem.loadv Mptr mm'
                  (Vptr bm (Ptrofs.add Ptrofs.zero (Ptrofs.repr 160))))
          with (Mem.load Mptr mm' bm 160) in Hld.
        destruct (Z.eq_dec delta 160) as [-> | Hne].
        * rewrite (Mem.load_store_same _ _ _ _ _ _ Hst) in Hld.
          injection Hld as E.
          destruct vv as [ | vi | vl | vf | vs | bb oo ]; try discriminate E.
          injection E as E1 E2; subst.
          exact (Hsafe _ _ eq_refl).
        * eapply R6; [ exact Hmem' | exact Hfo' | ].
          change (Mem.loadv Mptr mm
                    (Vptr bm (Ptrofs.add Ptrofs.zero (Ptrofs.repr 160))))
            with (Mem.load Mptr mm bm 160).
          rewrite <- Hld. symmetry.
          eapply Mem.load_store_other; [ exact Hst | right ].
          change (size_chunk Mptr) with 4. lia.
      + change (Mem.loadv Mptr mm'
                  (Vptr bm (Ptrofs.add Ptrofs.zero (Ptrofs.repr 120))))
          with (Mem.load Mptr mm' bm 120) in Hld.
        destruct (Z.eq_dec delta 120) as [-> | Hne].
        * rewrite (Mem.load_store_same _ _ _ _ _ _ Hst) in Hld.
          injection Hld as E.
          destruct vv as [ | vi | vl | vf | vs | bb oo ]; try discriminate E.
          injection E as E1 E2; subst.
          exact (Hsafe _ _ eq_refl).
        * eapply R6; [ exact Hmem' | exact Hfo' | ].
          change (Mem.loadv Mptr mm
                    (Vptr bm (Ptrofs.add Ptrofs.zero (Ptrofs.repr 120))))
            with (Mem.load Mptr mm bm 120).
          rewrite <- Hld. symmetry.
          eapply Mem.load_store_other; [ exact Hst | right ].
          change (size_chunk Mptr) with 4. lia.
    - (* R7: SafeB blocks are not bm *)
      intros b ofs b' o' Hs Hld.
      apply (R7 b ofs b' o' Hs).
      cbn in Hld |- *. rewrite <- Hld. symmetry.
      eapply Mem.load_store_other;
        [ exact Hst | left; exact (HSafeB_not_bm _ Hs) ].
    - (* R8: the gGlobalTimer block is not bm *)
      intros gb v Hfs Hld. eapply R8; [ exact Hfs | ].
      rewrite <- Hld. symmetry.
      eapply Mem.load_store_other;
        [ exact Hst | left; exact (proj1 (Hgtimer_blk _ Hfs)) ].
    - (* R9: the table block is not bm *)
      intros tb ofs2 b o Hfs Hld.
      eapply R9; [ exact Hfs | ].
      rewrite <- Hld. symmetry.
      eapply Mem.load_store_other;
        [ exact Hst | left; exact (proj1 (Htable_blk _ Hfs)) ].
  Qed.

  (* ---------------- Hmwf_input ---------------- *)
  Lemma mwf_real_input : forall mm mm' vv,
      MWF_real mm -> Int.and vv (Int.repr 2) = Int.zero ->
      Mem.store Mint16unsigned mm bm 2 (Vint vv) = Some mm' -> MWF_real mm'.
  Proof.
    intros mm mm' vv M Hclr Hst.
    apply (MWF_real_transfer mm mm'); [ .. | exact M ].
    - intros b Hv. eapply Mem.store_valid_block_1; eauto.
    - (* R1: the stored value itself is A-clear (zero_ext keeps bit 1) *)
      intros v Hld.
      rewrite (Mem.load_store_same _ _ _ _ _ _ Hst) in Hld.
      cbn in Hld. injection Hld as <-.
      rewrite and2_zero_ext16. exact Hclr.
    - (* the pinned row cells: all disjoint from [2,4) *)
      intros ch0 b ofs v Hrow Hld.
      rewrite <- Hld. symmetry.
      eapply Mem.load_store_other; [ exact Hst | ].
      destruct Hrow as [ [Eb Hcell] | [ Eb | [ Hfs | [ Hfs | Hfs ] ] ] ].
      + subst b. right. unfold bm_row_cell in Hcell.
        change (size_chunk Mint16unsigned) with 2. lia.
      + subst b. left. exact Hbc_bm.
      + left. exact (proj1 (Hgms_blk _ Hfs)).
      + left. exact (proj1 (Hgtimer_blk _ Hfs)).
      + left. exact (proj1 (Htable_blk _ Hfs)).
    - (* R7 *)
      intros b ofs b' o' Hs Hld.
      destruct M as (_ & _ & _ & _ & _ & _ & _ & R7 & _).
      apply (R7 b ofs b' o' Hs).
      cbn in Hld |- *. rewrite <- Hld. symmetry.
      eapply Mem.load_store_other;
        [ exact Hst | left; exact (HSafeB_not_bm _ Hs) ].
  Qed.

  (* ---------------- Hmwf_glob ---------------- *)

  Lemma stored_globals_not_gms :
    mem_id mario._gMarioState stored_globals = false.
  Proof. vm_compute. reflexivity. Qed.

  Lemma stored_globals_not_gtimer :
    mem_id interaction._gGlobalTimer stored_globals = false.
  Proof. vm_compute. reflexivity. Qed.

  Lemma stored_globals_not_itab :
    mem_id interaction._sInteractionHandlers stored_globals = false.
  Proof. vm_compute. reflexivity. Qed.

  Lemma mwf_real_glob : forall gid, mem_id gid stored_globals = true ->
      forall bg, Genv.find_symbol (lp_ge lp) gid = Some bg ->
        bg <> bm /\
        (forall mm mm' ch0 (d : Z) vv,
            MWF_real mm -> Mem.store ch0 mm bg d vv = Some mm' -> MWF_real mm').
  Proof.
    intros gid Hgid bg Hfs.
    destruct (Hglob_blk _ _ Hgid Hfs) as (Hbm & Hbc & Hsafe).
    split; [ exact Hbm | ].
    intros mm mm' ch0 d vv M Hst.
    assert (Hgms_ne : forall gb,
        Genv.find_symbol (lp_ge lp) mario._gMarioState = Some gb -> bg <> gb).
    { intros gb Hfs2.
      eapply Genv.global_addresses_distinct; [ | exact Hfs | exact Hfs2 ].
      intro E. subst gid. rewrite stored_globals_not_gms in Hgid.
      discriminate Hgid. }
    assert (Hgt_ne : forall gb,
        Genv.find_symbol (lp_ge lp) interaction._gGlobalTimer = Some gb ->
        bg <> gb).
    { intros gb Hfs2.
      eapply Genv.global_addresses_distinct; [ | exact Hfs | exact Hfs2 ].
      intro E. subst gid. rewrite stored_globals_not_gtimer in Hgid.
      discriminate Hgid. }
    assert (Hitab_ne : forall gb,
        Genv.find_symbol (lp_ge lp) interaction._sInteractionHandlers = Some gb ->
        bg <> gb).
    { intros gb Hfs2.
      eapply Genv.global_addresses_distinct; [ | exact Hfs | exact Hfs2 ].
      intro E. subst gid. rewrite stored_globals_not_itab in Hgid.
      discriminate Hgid. }
    apply (MWF_real_transfer mm mm'); [ .. | exact M ].
    - intros b Hv. eapply Mem.store_valid_block_1; eauto.
    - intros v Hld. pose proof M as (_ & R1 & _). apply R1.
      rewrite <- Hld. symmetry.
      eapply Mem.load_store_other; [ exact Hst | left; congruence ].
    - intros ch1 b ofs v Hrow Hld.
      rewrite <- Hld. symmetry.
      eapply Mem.load_store_other; [ exact Hst | left ].
      destruct Hrow as [ [Eb _] | [ Eb | [ Hfs2 | [ Hfs2 | Hfs2 ] ] ] ].
      + subst b. congruence.
      + subst b. congruence.
      + intro E. exact (Hgms_ne _ Hfs2 (eq_sym E)).
      + intro E. exact (Hgt_ne _ Hfs2 (eq_sym E)).
      + intro E. exact (Hitab_ne _ Hfs2 (eq_sym E)).
    - intros b ofs b' o' Hs Hld.
      pose proof M as (_ & _ & _ & _ & _ & _ & _ & R7 & _).
      apply (R7 b ofs b' o' Hs).
      cbn in Hld |- *. rewrite <- Hld. symmetry.
      eapply Mem.load_store_other; [ exact Hst | left ].
      intro E. subst b. exact (Hsafe Hs).
  Qed.

  (* ---------------- Hmwf_chase ---------------- *)
  Lemma mwf_real_chase : forall mm ch bsafe (d : Z) vv mm',
      MWF_real mm -> SafeB bsafe ->
      (forall bb oo, vv <> Vptr bb oo) ->
      Mem.store ch mm bsafe d vv = Some mm' -> MWF_real mm'.
  Proof.
    intros mm ch bsafe d vv mm' M Hsb Hnoptr Hst.
    assert (Hsbm : bsafe <> bm) by exact (HSafeB_not_bm _ Hsb).
    apply (MWF_real_transfer mm mm'); [ .. | exact M ].
    - intros b Hv. eapply Mem.store_valid_block_1; eauto.
    - intros v Hld. pose proof M as (_ & R1 & _). apply R1.
      rewrite <- Hld. symmetry.
      eapply Mem.load_store_other; [ exact Hst | left; congruence ].
    - intros ch1 b ofs v Hrow Hld.
      rewrite <- Hld. symmetry.
      eapply Mem.load_store_other; [ exact Hst | left ].
      destruct Hrow as [ [Eb _] | [ Eb | [ Hfs2 | [ Hfs2 | Hfs2 ] ] ] ].
      + subst b. congruence.
      + subst b. intro E. subst bsafe. exact (HSafeB_not_bc Hsb).
      + intro E. subst b. exact (proj2 (proj2 (Hgms_blk _ Hfs2)) Hsb).
      + intro E. subst b. exact (proj2 (proj2 (Hgtimer_blk _ Hfs2)) Hsb).
      + intro E. subst b. exact (proj2 (proj2 (Htable_blk _ Hfs2)) Hsb).
    - (* R7: a non-pointer store cannot forge a chase pointer *)
      intros b ofs b' o' Hs Hld.
      pose proof M as (_ & _ & _ & _ & _ & _ & _ & R7 & _).
      cbn in Hld.
      destruct (Mem.load_pointer_store _ _ _ _ _ _ _ _ _ _ _ Hst Hld)
        as [ (Evv & _) | Hdis ].
      + exfalso. exact (Hnoptr _ _ Evv).
      + apply (R7 b ofs b' o' Hs). cbn.
        rewrite <- Hld. symmetry.
        eapply Mem.load_store_other; [ exact Hst | exact Hdis ].
  Qed.

  (* the chase-PTR store row: a store of a SafeB-IF-POINTER value into a
     SafeB block (sma stores targetAnim -- a chased SafeB pointer -- into
     o->...curAnim).  Same skeleton as mwf_real_chase; only R7's
     same-cell case changes: the stored pointer IS SafeB by premise. *)
  Lemma mwf_real_chase_ptr : forall mm ch bsafe (d : Z) vv mm',
      MWF_real mm -> SafeB bsafe ->
      (forall bb oo, vv = Vptr bb oo -> SafeB bb) ->
      Mem.store ch mm bsafe d vv = Some mm' -> MWF_real mm'.
  Proof.
    intros mm ch bsafe d vv mm' M Hsb Hsafe Hst.
    assert (Hsbm : bsafe <> bm) by exact (HSafeB_not_bm _ Hsb).
    apply (MWF_real_transfer mm mm'); [ .. | exact M ].
    - intros b Hv. eapply Mem.store_valid_block_1; eauto.
    - intros v Hld. pose proof M as (_ & R1 & _). apply R1.
      rewrite <- Hld. symmetry.
      eapply Mem.load_store_other; [ exact Hst | left; congruence ].
    - intros ch1 b ofs v Hrow Hld.
      rewrite <- Hld. symmetry.
      eapply Mem.load_store_other; [ exact Hst | left ].
      destruct Hrow as [ [Eb _] | [ Eb | [ Hfs2 | [ Hfs2 | Hfs2 ] ] ] ].
      + subst b. congruence.
      + subst b. intro E. subst bsafe. exact (HSafeB_not_bc Hsb).
      + intro E. subst b. exact (proj2 (proj2 (Hgms_blk _ Hfs2)) Hsb).
      + intro E. subst b. exact (proj2 (proj2 (Hgtimer_blk _ Hfs2)) Hsb).
      + intro E. subst b. exact (proj2 (proj2 (Htable_blk _ Hfs2)) Hsb).
    - (* R7: the stored pointer, when loaded back, is SafeB by premise *)
      intros b ofs b' o' Hs Hld.
      pose proof M as (_ & _ & _ & _ & _ & _ & _ & R7 & _).
      cbn in Hld.
      destruct (Mem.load_pointer_store _ _ _ _ _ _ _ _ _ _ _ Hst Hld)
        as [ (Evv & _) | Hdis ].
      + exact (Hsafe _ _ Evv).
      + apply (R7 b ofs b' o' Hs). cbn.
        rewrite <- Hld. symmetry.
        eapply Mem.load_store_other; [ exact Hst | exact Hdis ].
  Qed.

  (* ---- the CAPSTONE WRAPPER ROWS, discharged (the P5 payoff): the two
     rows the re-rooted frame wrapper carries about the root body's own
     stores.  Until 2026-06-10 both were ASSUMED at the live capstone. ---- *)

  (* Hchase_safe: the _marioObj chase-root row, restated without the
     add-zero normal form (the wrapper's shape).  Pure projection of R6. *)
  Lemma mwf_real_chase_safe : forall delta m b' o',
      field_offset (prog_comp_env mario.prog) mario._marioObj
        mario_state_members = OK (delta, Full) ->
      MWF_real m ->
      Mem.loadv Mptr m (Vptr bm (Ptrofs.repr delta)) = Some (Vptr b' o') ->
      SafeB b'.
  Proof.
    intros delta m b' o' Hfo HM Hld.
    eapply (mwf_real_chase_root mario._marioObj delta m b' o');
      [ vm_compute; reflexivity | exact Hfo | exact HM
      | rewrite Ptrofs.add_zero_l; exact Hld ].
  Qed.

  (* Hstore_safe: the two REAL body stores of f_execute_mario_action
     (prov_ok pins the Sassign to store1/store2), executed with the
     SafeB provenance the walk carries for _t'49/_t'13, preserve
     ctl_a_clear (= the capstone's NoA_real) and MWF_real.
       - the target block is the temp's block (store1_loc_is_t49_lp /
         store2_loc_is_t13_lp), SafeB by the carried gate;
       - the stored value is a Vint (store1: any source cast to tshort
         is i2i; store2: the RHS is Econst_int 0; bitfield carriers
         store Vint by construction) -- so mwf_real_chase applies and
         R7 survives via load_pointer_store;
       - ctl_a_clear m' then follows from MWF_real m' (mwf_real_ctl). *)
  Lemma mwf_real_store_safe :
    forall e le m a1 a2 tr le' m' out,
      ctl_a_clear m bm -> MWF_real m ->
      RealFrameValue.prov_ok (Sassign a1 a2) ->
      (forall b o, le ! mario._t'49 = Some (Vptr b o) -> SafeB b) ->
      (forall b o, le ! mario._t'13 = Some (Vptr b o) -> SafeB b) ->
      exec_stmt function_entry2 (lp_ge lp) e le m (Sassign a1 a2) tr le' m' out ->
      ctl_a_clear m' bm /\ MWF_real m'.
  Proof.
    intros e le m a1 a2 tr le' m' out Hno HM Hck T49 T13 Hexec.
    cbn [RealFrameValue.prov_ok] in Hck.
    assert (HM' : MWF_real m').
    { destruct Hck as [ [Ha1 Ha2] | [Ha1 Ha2] ]; subst a1 a2;
        inversion Hexec; subst.
      - (* store1: halfword store through _t'49 into its SafeB block *)
        match goal with
        | Hlv : eval_lvalue _ _ _ _ store1_lval _ _ _ |- _ =>
            apply store1_loc_is_t49_lp in Hlv as (dd & Hle)
        end.
        pose proof (T49 _ _ Hle) as Hsafe.
        (* the cast to tshort makes the stored value a Vint *)
        match goal with
        | Hca : sem_cast _ (typeof store1_rval) (typeof store1_lval) _
                  = Some _ |- _ =>
            apply sem_cast_tint_tshort_vint in Hca as (vi & ->)
        end.
        match goal with
        | Hal : assign_loc _ (typeof store1_lval) _ _ _ _ _ _ |- _ =>
            inversion Hal; subst
        end.
        + (* By_value: a Vint store into the SafeB block *)
          match goal with
          | Hst : Mem.storev _ _ (Vptr _ _) _ = Some m' |- _ => cbn in Hst
          end.
          eapply mwf_real_chase; [ exact HM | exact Hsafe | | eassumption ].
          intros bb oo Heq; discriminate Heq.
        + (* bitfield: the carrier store is a Vint store
             (the By_copy case is auto-refuted by inversion: v = Vint vi) *)
          match goal with
          | Hsb : store_bitfield _ _ _ _ _ _ _ _ _ _ |- _ =>
              inversion Hsb; subst
          end.
          match goal with
          | Hst : Mem.storev _ _ (Vptr _ _) (Vint _) = Some m' |- _ =>
              cbn in Hst
          end.
          eapply mwf_real_chase; [ exact HM | exact Hsafe | | eassumption ].
          intros bb oo Heq; discriminate Heq.
      - (* store2: word store of Vint 0 through _t'13 *)
        match goal with
        | Hlv : eval_lvalue _ _ _ _ store2_lval _ _ _ |- _ =>
            apply store2_loc_is_t13_lp in Hlv as (dd & Hle)
        end.
        pose proof (T13 _ _ Hle) as Hsafe.
        (* the RHS is Econst_int: it evaluates only to Vint 0 *)
        match goal with
        | Hev : eval_expr _ _ _ _ store2_rval _ |- _ =>
            unfold store2_rval in Hev;
            inversion Hev; subst;
            [ | match goal with
                | Hx : eval_lvalue _ _ _ _ (Econst_int _ _) _ _ _ |- _ =>
                    inversion Hx
                end ]
        end.
        match goal with
        | Hca : sem_cast (Vint _) _ _ _ = Some _ |- _ =>
            pose proof (sem_cast_vint_not_vptr _ _ _ _ _ Hca) as Hnp
        end.
        match goal with
        | Hal : assign_loc _ (typeof store2_lval) _ _ _ _ _ _ |- _ =>
            inversion Hal; subst
        end.
        + (* By_value *)
          match goal with
          | Hst : Mem.storev _ _ (Vptr _ _) _ = Some m' |- _ => cbn in Hst
          end.
          eapply mwf_real_chase; [ exact HM | exact Hsafe | | eassumption ].
          exact Hnp.
        + (* By_copy: the stored value is a Vptr, refuted by Hnp *)
          exfalso. eapply Hnp; reflexivity.
        + (* bitfield: the carrier store is a Vint store *)
          match goal with
          | Hsb : store_bitfield _ _ _ _ _ _ _ _ _ _ |- _ =>
              inversion Hsb; subst
          end.
          match goal with
          | Hst : Mem.storev _ _ (Vptr _ _) (Vint _) = Some m' |- _ =>
              cbn in Hst
          end.
          eapply mwf_real_chase; [ exact HM | exact Hsafe | | eassumption ].
          intros bb oo Heq; discriminate Heq.
    }
    split; [ | exact HM' ].
    intros bc' oc' v Hld156 Hldbtn.
    pose proof HM' as (_ & _ & R2 & R3 & _).
    destruct (R2 _ _ Hld156) as [Eb Eo]; subst bc' oc'.
    exact (R3 _ Hldbtn).
  Qed.

  (* the LOCAL-STORE row: a store into a fully watched-disjoint block b0 (a
     function stack local: b0 <> bm, b0 <> bc, ~SafeB b0, b0 distinct from
     every find_symbol global) preserves MWF_real.  Every MWF_real row reads
     bm / bc / gMarioState / gGlobalTimer / a SafeB block -- all <> b0 -- so
     each load is store_other and the row transfers unchanged.  This is the
     Hls_real brick the wwalk engine's Tier-2 indexed-local-store AND the
     out-param (oc) arm consume; the b0 <> bc premise is supplied at the
     capstone from local_blk's global clause + bc's symbol grounding (bc is
     the static controller block). *)
  Lemma mwf_real_local_store : forall mm ch b0 (d : Z) vv mm',
      MWF_real mm ->
      b0 <> bm -> b0 <> bc -> ~ SafeB b0 ->
      (forall gid bg, Genv.find_symbol (lp_ge lp) gid = Some bg -> b0 <> bg) ->
      Mem.store ch mm b0 d vv = Some mm' -> MWF_real mm'.
  Proof.
    intros mm ch b0 d vv mm' M Hbm Hbc HnS Hglob Hst.
    apply (MWF_real_transfer mm mm'); [ .. | exact M ].
    - (* R0 validity is monotone under store *)
      intros b Hv. eapply Mem.store_valid_block_1; eauto.
    - (* R1 input_a_clear: bm's input cell is untouched (b0 <> bm) *)
      intros v Hld. pose proof M as (_ & R1 & _). apply R1.
      rewrite <- Hld. symmetry.
      eapply Mem.load_store_other; [ exact Hst | left; congruence ].
    - (* the watched cells (bm / bc / gMarioState / gGlobalTimer) are all
         in blocks <> b0, so their loads transfer unchanged *)
      intros ch1 b ofs v Hrow Hld.
      rewrite <- Hld. symmetry.
      eapply Mem.load_store_other; [ exact Hst | left ].
      destruct Hrow as [ [Eb _] | [ Eb | [ Hfs2 | [ Hfs2 | Hfs2 ] ] ] ].
      + subst b. congruence.
      + subst b. congruence.
      + apply not_eq_sym. exact (Hglob _ _ Hfs2).
      + apply not_eq_sym. exact (Hglob _ _ Hfs2).
      + apply not_eq_sym. exact (Hglob _ _ Hfs2).
    - (* R7: SafeB blocks are <> b0 (b0 is not SafeB), so their loads are
         unchanged and SafeB-closure transfers *)
      intros b ofs b' o' Hs Hld.
      pose proof M as (_ & _ & _ & _ & _ & _ & _ & R7 & _).
      apply (R7 b ofs b' o' Hs). cbn in Hld |- *.
      rewrite <- Hld. symmetry.
      eapply Mem.load_store_other; [ exact Hst | left ].
      intro E. subst b. exact (HnS Hs).
  Qed.

  (* ---------------- Hmwf_umbi ---------------- *)
  Lemma mwf_real_umbi : forall mm mm',
      MWF_real mm ->
      Mem.unchanged_on (fun b o => ~ umbi_footprint bm b o) mm mm' ->
      input_a_clear mm' bm -> MWF_real mm'.
  Proof.
    intros mm mm' M Hunch Hinp'.
    pose proof M as ((Vbm & Vbc & Vgms & Vsafe & Vgt & Vtb) & _).
    apply (MWF_real_transfer mm mm'); [ .. | exact M ].
    - intros b Hv. eapply Mem.valid_block_unchanged_on; eauto.
    - exact Hinp'.
    - intros ch b ofs v Hrow Hld.
      assert (Vb : Mem.valid_block mm b).
      { destruct Hrow as [ [Eb _] | [ Eb | [ Hfs | [ Hfs | Hfs ] ] ] ];
          [ subst b; exact Vbm | subst b; exact Vbc
            | exact (Vgms _ Hfs) | exact (Vgt _ Hfs) | exact (Vtb _ Hfs) ]. }
      rewrite <- Hld. symmetry.
      eapply Mem.load_unchanged_on_1; [ exact Hunch | exact Vb | ].
      intros i Hi. unfold umbi_footprint.
      destruct Hrow as [ [Eb Hcell] | [ Eb | [ Hfs | [ Hfs | Hfs ] ] ] ].
      + subst b. intros [_ Hor]. unfold bm_row_cell in Hcell. lia.
      + subst b. intros [E _]. exact (Hbc_bm E).
      + intros [E _]. exact (proj1 (Hgms_blk _ Hfs) E).
      + intros [E _]. exact (proj1 (Hgtimer_blk _ Hfs) E).
      + intros [E _]. exact (proj1 (Htable_blk _ Hfs) E).
    - intros b ofs b' o' Hs Hld.
      pose proof M as (_ & _ & _ & _ & _ & _ & _ & R7 & _).
      apply (R7 b ofs b' o' Hs). cbn in Hld |- *.
      rewrite <- Hld. symmetry.
      eapply Mem.load_unchanged_on_1; [ exact Hunch | exact (Vsafe _ Hs) | ].
      intros i _ [E _]. exact (HSafeB_not_bm _ Hs E).
  Qed.

  (* ---------------- Hmwf_entry ---------------- *)
  Lemma mwf_real_entry : forall f vargs m e le m1,
      function_entry2 (lp_ge lp) f vargs m e le m1 ->
      MWF_real m -> MWF_real m1.
  Proof.
    intros f vargs m e le m1 Hentry M.
    pose proof M as ((Vbm & Vbc & Vgms & Vsafe & Vgt & Vtb) & _).
    assert (Hunch : Mem.unchanged_on (fun b _ => Mem.valid_block m b) m m1)
      by (eapply FieldNonInterference.function_entry2_unchanged_on; eauto).
    apply (MWF_real_transfer m m1); [ .. | exact M ].
    - intros b Hv. eapply Mem.valid_block_unchanged_on; eauto.
    - intros v Hld. pose proof M as (_ & R1 & _). apply R1.
      rewrite <- Hld. symmetry.
      eapply Mem.load_unchanged_on_1;
        [ exact Hunch | exact Vbm | intros; exact Vbm ].
    - intros ch b ofs v Hrow Hld.
      assert (Vb : Mem.valid_block m b).
      { destruct Hrow as [ [Eb _] | [ Eb | [ Hfs | [ Hfs | Hfs ] ] ] ];
          [ subst b; exact Vbm | subst b; exact Vbc
            | exact (Vgms _ Hfs) | exact (Vgt _ Hfs) | exact (Vtb _ Hfs) ]. }
      rewrite <- Hld. symmetry.
      eapply Mem.load_unchanged_on_1;
        [ exact Hunch | exact Vb | intros; exact Vb ].
    - intros b ofs b' o' Hs Hld.
      pose proof M as (_ & _ & _ & _ & _ & _ & _ & R7 & _).
      apply (R7 b ofs b' o' Hs). cbn in Hld |- *.
      rewrite <- Hld. symmetry.
      eapply Mem.load_unchanged_on_1;
        [ exact Hunch | exact (Vsafe _ Hs) | intros; exact (Vsafe _ Hs) ].
  Qed.

  (* ---------------- Hmwf_free ---------------- *)

  Lemma free_list_load_2 : forall l m m',
      Mem.free_list m l = Some m' ->
      forall ch b ofs v, Mem.load ch m' b ofs = Some v ->
                         Mem.load ch m b ofs = Some v.
  Proof.
    induction l as [ | [[b0 lo] hi] l IH ]; intros m m' Hfl ch b ofs v Hld.
    - cbn in Hfl. inv Hfl. exact Hld.
    - cbn in Hfl.
      destruct (Mem.free m b0 lo hi) as [m2|] eqn:E; [ | discriminate ].
      eapply Mem.load_free_2; [ exact E | ].
      eapply IH; [ exact Hfl | exact Hld ].
  Qed.

  Lemma free_list_valid_1 : forall l m m',
      Mem.free_list m l = Some m' ->
      forall b, Mem.valid_block m b -> Mem.valid_block m' b.
  Proof.
    induction l as [ | [[b0 lo] hi] l IH ]; intros m m' Hfl b Hv.
    - cbn in Hfl. inv Hfl. exact Hv.
    - cbn in Hfl.
      destruct (Mem.free m b0 lo hi) as [m2|] eqn:E; [ | discriminate ].
      eapply IH; [ exact Hfl | ].
      eapply Mem.valid_block_free_1; eauto.
  Qed.

  Lemma mwf_real_free : forall m2 m3 l,
      Mem.free_list m2 l = Some m3 -> MWF_real m2 -> MWF_real m3.
  Proof.
    intros m2 m3 l Hfl M.
    apply (MWF_real_transfer m2 m3); [ .. | exact M ].
    - intros b Hv. eapply free_list_valid_1; eauto.
    - intros v Hld. pose proof M as (_ & R1 & _). apply R1.
      eapply free_list_load_2; eauto.
    - intros ch b ofs v _ Hld. eapply free_list_load_2; eauto.
    - intros b ofs b' o' Hs Hld.
      pose proof M as (_ & _ & _ & _ & _ & _ & _ & R7 & _).
      apply (R7 b ofs b' o' Hs). cbn in Hld |- *.
      eapply free_list_load_2; eauto.
  Qed.

  (* ---------------- Hmwf_alloc (the local-vars entry brick) ----------------
     a single Mem.alloc preserves MWF_real: it only adds a fresh block, so every
     watched cell's load is unchanged and every valid block stays valid.
     Discharges ActWriterSurface's HMWF_alloc (consumed per-var by
     alloc_variables_carried at a local-var funcall entry). *)
  Lemma mwf_real_alloc : forall m lo hi m' b,
      Mem.alloc m lo hi = (m', b) -> MWF_real m -> MWF_real m'.
  Proof.
    intros m lo hi m' b Ha M.
    pose proof M as ((Vbm & Vbc & Vgms & Vsafe & Vgt & Vtb) & _).
    apply (MWF_real_transfer m m'); [ .. | exact M ].
    - intros bb Hv. eapply Mem.valid_block_alloc; eauto.
    - intros v Hld. pose proof M as (_ & R1 & _). apply R1.
      rewrite <- Hld. symmetry.
      eapply Mem.load_alloc_unchanged; [ exact Ha | exact Vbm ].
    - intros ch bb ofs v Hrow Hld.
      assert (Vb : Mem.valid_block m bb).
      { destruct Hrow as [ [Eb _] | [ Eb | [ Hfs | [ Hfs | Hfs ] ] ] ];
          [ subst bb; exact Vbm | subst bb; exact Vbc
            | exact (Vgms _ Hfs) | exact (Vgt _ Hfs) | exact (Vtb _ Hfs) ]. }
      rewrite <- Hld. symmetry.
      eapply Mem.load_alloc_unchanged; [ exact Ha | exact Vb ].
    - intros bb ofs b' o' Hs Hld.
      pose proof M as (_ & _ & _ & _ & _ & _ & _ & R7 & _).
      apply (R7 bb ofs b' o' Hs). cbn in Hld |- *.
      rewrite <- Hld. symmetry.
      eapply Mem.load_alloc_unchanged; [ exact Ha | exact (Vsafe _ Hs) ].
  Qed.

End MWFReal.
