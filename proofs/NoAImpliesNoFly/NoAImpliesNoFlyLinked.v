(* spine-root: the NON-VACUOUS GOAL-1 capstone (no-A => no-fly) over the
   linked program lp; supersedes the vacuous mario_ge capstone now demoted to
   Unwired/NoAImpliesNoFlyVacuous.v. *)
(* ====================================================================== *)
(* THE NON-VACUOUS GOAL-1 CAPSTONE, OVER THE LINKED PROGRAM.               *)
(*                                                                        *)
(* The spine capstone NoAImpliesNoFly.noA_no_spawn_never_flying is         *)
(* VACUOUSLY true: it rests on the FALSE hypothesis reach_ext_action_cell  *)
(* (over mario.prog ALONE the action dispatchers mario_execute_*_action    *)
(* are underspecified Externals, so 'externals never write the action      *)
(* cell' is false -- they can write flying). This file re-states the SAME   *)
(* theorem over the LINKED program lp (mario.prog plus the action TUs),    *)
(* consuming the fully re-rooted frame wrapper                             *)
(* RealFrameLinked.execute_mario_action_preserves_real_reached_lp.         *)
(*                                                                        *)
(* OVER lp THERE IS NO reach_ext_action_cell. The dispatcher Scalls        *)
(* resolve to REAL Internal bodies and are traversed by the engine's       *)
(* funcall-IH; the residuals this capstone rests on all range over the     *)
(* linked genv and are SATISFIABLE (the ext residual ranges only over      *)
(* genuine math/runtime externals, where unchanged_on IS true). So this    *)
(* theorem is NON-VACUOUS -- the A button is provably load-bearing.        *)
(*                                                                        *)
(* THE CARRIED INVARIANT IS THE TAINT SET T (2026-06-03): the run carries   *)
(* `action notin T` (Taint.not_tainted, T = F + {ACT_SHOT_FROM_CANNON}),    *)
(* not merely "not flying" -- the cannon writes ACT_FLYING on a later,      *)
(* A-free frame, so the F-only invariant is not inductive and its           *)
(* per-funcall residual is unsatisfiable. T's entry edges are finite and    *)
(* A-gated (machine-checked enumeration in Taint.v); the no-fly conclusion  *)
(* follows from T >= F (not_tainted_not_flying).                            *)
(*                                                                        *)
(* The reach residuals below are a COARSER but HONEST decomposition:        *)
(* reach_value_preserves_reached over lp_ge at not_tainted is the value     *)
(* engine's per-funcall contract (dischargeable by                         *)
(* ActionValueFrame.exec_funcall_reach_value_reached at lp_ge -- the        *)
(* Phase-B A-gating work), NOT the conclusion, and NOT false.              *)
(* ====================================================================== *)

From compcert Require Import Coqlib Maps AST Integers Values Events Memory Globalenvs
  Ctypes Clight ClightBigstep Linking.
From Coq Require Import List. Import ListNotations.
From SM64.Generated Require mario.
From SM64.Proofs Require Import Flying Taint ActionValue ActionValueFrame ReachableRun
  RealFrameValue RealFrameLinked AGates.

Section NoAImpliesNoFlyLinked.
  (* The linked program -- ABSTRACT, never computed (no OOM). *)
  Variable lp : Clight.program.
  Hypothesis LO_mario : linkorder mario.prog lp.

  Variable bm : block.
  Variable MWF : mem -> Prop.

  (* ---- REAL flying, by the loaded action value (offset 12 -- which linking
     does NOT move; RealFrameLinked.linking_preserves_action_offset). ---- *)
  Definition mem_flying_lp (m : mem) : Prop :=
    exists v, Mem.load Mint32 m bm 12 = Some (Vint v) /\ is_flying_int v = true.

  (* THE CARRIED INVARIANT IS THE TAINT SET, NOT THE FLYING SET. Carrying
     merely "action is not flying" is NOT inductive: ACT_SHOT_FROM_CANNON is
     non-flying, yet its handler writes ACT_FLYING on a later, A-FREE frame
     (wing cap + pure physics) -- so the per-funcall residual over "nonflying"
     would be unsatisfiable at the cannon. We carry `action notin T` for the
     no-A taint closure T = F + {ACT_SHOT_FROM_CANNON} (Taint.is_tainted,
     entry edges machine-checked in Taint.v), which IS inductively A-gated.
     Since T contains F, the no-fly conclusion is free (not_tainted_not_flying).
     The price is an (honest) stronger init condition: the run starts with
     Mario's action outside T -- standing on the ground, not mid-cannon-shot. *)
  Definition mem_nontainted_lp (m : mem) : Prop := action_sat not_tainted m bm.

  Definition mem_ok_lp (m : mem) : Prop :=
    Mem.valid_block m bm /\ mem_nontainted_lp m /\
    marioObj_wf_lp lp m bm /\ gMarioState_wf_lp lp m bm /\ MWF m.

  Lemma mem_nontainted_not_flying_lp : forall m, mem_nontainted_lp m -> ~ mem_flying_lp m.
  Proof.
    intros m Hnt [v [Hld Hfly]]. specialize (Hnt v Hld).
    apply not_tainted_not_flying in Hnt. congruence.
  Qed.

  Lemma mem_ok_not_flying_lp : forall m, mem_ok_lp m -> ~ mem_flying_lp m.
  Proof. intros m [_ [Hnt _]]. exact (mem_nontainted_not_flying_lp m Hnt). Qed.

  (* ---- input layer (abstract, as in the spine capstone) ---- *)
  Variable Inp : Type.
  Variable a_pressed    : Inp -> bool.
  Variable spawn_flying : Inp -> bool.

  (* THE STEP IS REAL AND OVER THE LINKED GENV: every step performs one
     big-step eval_funcall of f_execute_mario_action at globalenv lp (the
     step_lp_real hypothesis), so every dispatcher Scall inside resolves to a
     real Internal body -- the flying logic is IN SCOPE. The relation between
     the input i and the pre-frame memory is left abstract here; the GROUNDED
     instantiation (NoARealInput below) ties i to the memory the frame reads,
     which is what makes input_grounds_noA dischargeable rather than assumed. *)
  Variable step_lp : Inp -> mem -> mem -> Prop.
  Hypothesis step_lp_real :
    forall i m m', step_lp i m m' -> execute_mario_action_step_lp lp m m'.

  Definition noA_run_real (is : list Inp) : Prop :=
    Forall (fun i => a_pressed i = false) is.
  Definition no_spawn_flying_run (is : list Inp) : Prop :=
    Forall (fun i => spawn_flying i = false) is.

  Variable NoA : mem -> Prop.
  Variable reached_id : ident -> Prop.
  Variable reached_fd : Clight.fundef -> Prop.

  (* ---- THE REACH RESIDUALS, ALL OVER THE LINKED GENV lp. None is the false
     reach_ext_action_cell; each ranges over lp and is satisfiable. ---- *)

  (* the value-engine per-funcall contract over lp, AT THE TAINT PREDICATE
     (dischargeable by the ge-generic exec_funcall_reach_value_reached at
     lp_ge -- Phase B / the A-gating). With Q := not_tainted this is the
     SATISFIABLE form: the T-internal flying writers (act_shot_from_cannon,
     act_flying_triple_jump) are dispatched only when the action is already
     in T, and the sole T-entry edges are A-gated (Taint.v). *)
  Hypothesis Hreach_val :
    reach_value_preserves_reached not_tainted bm (lp_ge lp) NoA MWF reached_fd.
  Hypothesis Hrest : reach_rest_marg_lp lp bm NoA.
  Hypothesis Hext :
    forall ef vargs mm tt vres mm',
      NoA mm -> meminv_lp lp not_tainted bm mm -> MWF mm ->
      external_call ef (lp_ge lp) vargs mm tt vres mm' ->
      NoA mm' /\ meminv_lp lp not_tainted bm mm' /\ MWF mm'.
  Hypothesis Hstore :
    forall e le mm a1 a2 tt le' mm' out,
      NoA mm -> RealFrameValue.prov_ok (Sassign a1 a2) ->
      exec_stmt function_entry2 (lp_ge lp) e le mm (Sassign a1 a2) tt le' mm' out -> NoA mm'.
  Hypothesis Hstoremwf :
    forall e le mm a1 a2 tt le' mm' out,
      NoA mm -> RealFrameValue.prov_ok (Sassign a1 a2) -> MWF mm ->
      exec_stmt function_entry2 (lp_ge lp) e le mm (Sassign a1 a2) tt le' mm' out -> MWF mm'.
  Hypothesis Hbcr :
    forall oid a al e le mm vf fd,
      RealFrameValue.reach_chk reached_id (Scall oid a al) ->
      eval_expr (lp_ge lp) e le mm a vf ->
      Genv.find_funct (lp_ge lp) vf = Some fd -> reached_fd fd.
  Hypothesis Hbodyrck :
    RealFrameValue.reach_chk reached_id (fn_body mario.f_execute_mario_action).

  (* input grounding: a no-A frame's starting memory satisfies NoA (same residual
     as the spine capstone's input_grounds_noA). *)
  Hypothesis input_grounds_noA :
    forall i m m', a_pressed i = false -> step_lp i m m' -> NoA m.

  (* THE PER-FRAME OBLIGATION, over lp: a real frame preserves mem_ok_lp. Discharged
     by the re-rooted wrapper -- NO reach_ext_action_cell involved. *)
  Lemma frame_preserves_mem_ok_lp :
    forall i m m',
      a_pressed i = false -> spawn_flying i = false ->
      mem_ok_lp m -> step_lp i m m' -> mem_ok_lp m'.
  Proof.
    intros i m m' Ha _ (Hv & Hsat & Hwf & Hgwf & HMWF) Hst.
    assert (HnoA : NoA m) by (eapply input_grounds_noA; eassumption).
    destruct (execute_mario_action_preserves_real_reached_lp lp LO_mario not_tainted bm NoA MWF reached_id reached_fd m m'
                Hreach_val Hrest Hext Hstore Hstoremwf Hbcr Hbodyrck
                HnoA HMWF Hv Hsat Hwf Hgwf (step_lp_real i m m' Hst))
      as (_ & Hv' & Hs' & Hw' & Hgw' & HMWF').
    exact (conj Hv' (conj Hs' (conj Hw' (conj Hgw' HMWF')))).
  Qed.

  Lemma combine_preconditions_lp :
    forall is,
      noA_run_real is -> no_spawn_flying_run is ->
      noA_run Inp (fun i => orb (a_pressed i) (spawn_flying i)) is.
  Proof.
    unfold noA_run_real, no_spawn_flying_run, noA_run.
    induction is as [| i rest IH]; intros HA HS.
    - constructor.
    - inversion HA; subst. inversion HS; subst.
      constructor; [ apply orb_false_iff; split; assumption | apply IH; assumption ].
  Qed.

  (* ====================================================================== *)
  (* THE NON-VACUOUS TETHERED THEOREM (over the linked program).            *)
  (* Same statement as noA_no_spawn_never_flying, but `step` is the REAL     *)
  (* eval_funcall at globalenv lp and there is NO false reach_ext_action_cell *)
  (* anywhere in its cone -- so it actually constrains the real game.        *)
  (* ====================================================================== *)
  Theorem noA_no_spawn_never_flying_lp :
    forall (init : mem) (is : list Inp) (m : mem),
      mem_ok_lp init ->
      noA_run_real is ->
      no_spawn_flying_run is ->
      reachable mem Inp step_lp init is m ->
      ~ mem_flying_lp m.
  Proof.
    intros init is m Hinit HnoA Hnospawn Hreach.
    eapply (noA_run_not_flying mem Inp
              (fun i => orb (a_pressed i) (spawn_flying i)) step_lp
              mem_flying_lp mem_ok_lp init).
    - exact Hinit.
    - intros i s s' Hd Hphi Hst.
      apply orb_false_iff in Hd. destruct Hd as [Ha Hsp].
      eapply frame_preserves_mem_ok_lp; eauto.
    - exact mem_ok_not_flying_lp.
    - exact (combine_preconditions_lp is HnoA Hnospawn).
    - exact Hreach.
  Qed.

End NoAImpliesNoFlyLinked.

(* ====================================================================== *)
(* THE GROUNDED CAPSTONE: the no-A invariant made CONCRETE.                *)
(*                                                                        *)
(* Above, NoA / Inp / a_pressed are abstract and input_grounds_noA is an   *)
(* ASSUMED bridge between them. Here they are real:                        *)
(*   - an input IS the pre-frame memory (Inp := mem; step_real ties them); *)
(*   - a_pressed is AGates.a_pressed_real: chase gMarioState->controller   *)
(*     (offset 156) and test buttonPressed (offset 18) & A_BUTTON (0x8000) *)
(*     -- the actual bit the real code's one INPUT_A_PRESSED-setting gate   *)
(*     reads (Taint.v census + AGates.ctl_a_gate_takes_else_lp);            *)
(*   - NoA is AGates.ctl_a_clear -- the controller A-bit is clear in        *)
(*     memory;                                                              *)
(*   - input_grounds_noA is PROVED (a_pressed_real_grounds_ctl), not        *)
(*     assumed.                                                             *)
(* The remaining residual surface is the same engine contract as above but  *)
(* now at the CONCRETE invariant: Phase B must discharge                    *)
(* reach_value_preserves_reached not_tainted bm (lp_ge lp) (ctl-A-clear)    *)
(* MWF reached_fd against the linked handler bodies, using the A-gate       *)
(* lemmas of AGates.v at the sites Taint.v pins.                            *)
(* ====================================================================== *)

Section NoARealInput.
  Variable lp : Clight.program.
  Hypothesis LO_mario : linkorder mario.prog lp.

  Variable bm : block.
  Variable MWF : mem -> Prop.

  (* the spawn-exclusion input bit stays abstract: it models the warp/level
     script (set_mario_initial_action, OUTSIDE the frame). *)
  Variable spawn_flying : mem -> bool.

  Variable reached_id : ident -> Prop.
  Variable reached_fd : Clight.fundef -> Prop.

  (* THE CONCRETE NO-A INVARIANT: the controller's A bit is clear in memory. *)
  Definition NoA_real (m : mem) : Prop := ctl_a_clear m bm.

  (* the step: the input IS the pre-frame memory, and the frame is one real
     eval_funcall of f_execute_mario_action over globalenv lp. *)
  Definition step_real (i m m' : mem) : Prop :=
    i = m /\ execute_mario_action_step_lp lp m m'.

  Lemma step_real_steps :
    forall i m m', step_real i m m' -> execute_mario_action_step_lp lp m m'.
  Proof. intros i m m' [_ H]; exact H. Qed.

  (* input_grounds_noA, PROVED: an A-silent frame start satisfies NoA_real. *)
  Lemma input_grounds_noA_real :
    forall i m m', a_pressed_real bm i = false -> step_real i m m' -> NoA_real m.
  Proof.
    intros i m m' Ha [Heq _]. subst i.
    exact (a_pressed_real_grounds_ctl bm m Ha).
  Qed.

  (* ---- the engine residuals, now at the CONCRETE invariant (the sharpened
     Phase-B target). Same shapes as the abstract section's. ---- *)
  Hypothesis Hreach_val :
    reach_value_preserves_reached not_tainted bm (lp_ge lp) NoA_real MWF reached_fd.
  Hypothesis Hrest : reach_rest_marg_lp lp bm NoA_real.
  Hypothesis Hext :
    forall ef vargs mm tt vres mm',
      NoA_real mm -> meminv_lp lp not_tainted bm mm -> MWF mm ->
      external_call ef (lp_ge lp) vargs mm tt vres mm' ->
      NoA_real mm' /\ meminv_lp lp not_tainted bm mm' /\ MWF mm'.
  Hypothesis Hstore :
    forall e le mm a1 a2 tt le' mm' out,
      NoA_real mm -> RealFrameValue.prov_ok (Sassign a1 a2) ->
      exec_stmt function_entry2 (lp_ge lp) e le mm (Sassign a1 a2) tt le' mm' out ->
      NoA_real mm'.
  Hypothesis Hstoremwf :
    forall e le mm a1 a2 tt le' mm' out,
      NoA_real mm -> RealFrameValue.prov_ok (Sassign a1 a2) -> MWF mm ->
      exec_stmt function_entry2 (lp_ge lp) e le mm (Sassign a1 a2) tt le' mm' out ->
      MWF mm'.
  Hypothesis Hbcr :
    forall oid a al e le mm vf fd,
      RealFrameValue.reach_chk reached_id (Scall oid a al) ->
      eval_expr (lp_ge lp) e le mm a vf ->
      Genv.find_funct (lp_ge lp) vf = Some fd -> reached_fd fd.
  Hypothesis Hbodyrck :
    RealFrameValue.reach_chk reached_id (fn_body mario.f_execute_mario_action).

  (* ==================================================================== *)
  (* THE GROUNDED THEOREM: same conclusion as the abstract capstone, but    *)
  (* "the player never presses A" now MEANS the A_BUTTON bit of the in-     *)
  (* memory controller at every frame boundary -- and the input-to-NoA      *)
  (* bridge is a proved lemma, not a hypothesis.                            *)
  (* ==================================================================== *)
  Theorem noA_no_spawn_never_flying_real :
    forall (init : mem) (is : list mem) (m : mem),
      mem_ok_lp lp bm MWF init ->
      Forall (fun i => a_pressed_real bm i = false) is ->
      Forall (fun i => spawn_flying i = false) is ->
      reachable mem mem step_real init is m ->
      ~ mem_flying_lp bm m.
  Proof.
    intros init is m Hinit HnoA Hns Hreach.
    exact (noA_no_spawn_never_flying_lp lp LO_mario bm MWF mem
             (a_pressed_real bm) spawn_flying step_real step_real_steps
             NoA_real reached_id reached_fd
             Hreach_val Hrest Hext Hstore Hstoremwf Hbcr Hbodyrck
             input_grounds_noA_real init is m Hinit HnoA Hns Hreach).
  Qed.

End NoARealInput.
