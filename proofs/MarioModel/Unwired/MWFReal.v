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
From SM64.Generated Require mario.
From SM64.Proofs Require Import SymbolicLinking Flying Taint
  ActionValueFrame RealFrameValue RealFrameLinked AGates.
From SM64.Proofs Require Import CensusV2.

Import ListNotations.
Local Open Scope Z_scope.

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

  (* ---------------- the invariant ---------------- *)

  Definition MWF_real (m : mem) : Prop :=
    (* R0: validity (positive, monotone-safe -- NEVER add positive
       LOAD facts here). *)
    (Mem.valid_block m bm /\ Mem.valid_block m bc)
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
           SafeB b').

  (* ---------------- the projection discharges ----------------
     Each is the v2 capstone hypothesis of the same shape, with
     MWF := MWF_real. *)

  Lemma mwf_real_valid : forall m, MWF_real m -> Mem.valid_block m bm.
  Proof. intros m M. exact (proj1 (proj1 M)). Qed.

  Lemma mwf_real_valid_bc : forall m, MWF_real m -> Mem.valid_block m bc.
  Proof. intros m M. exact (proj2 (proj1 M)). Qed.

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
    intros m b ofs b' o' (_ & _ & _ & _ & _ & _ & _ & R7) Hs Hld.
    exact (R7 _ _ _ _ Hs Hld).
  Qed.

End MWFReal.
