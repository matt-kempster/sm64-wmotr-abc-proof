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
From SM64.Generated Require mario mario_actions_stationary
  mario_actions_moving mario_actions_airborne mario_actions_submerged
  mario_actions_cutscene mario_actions_automatic mario_actions_object
  interaction behavior_actions level_update mario_step.
From SM64.Proofs Require Import Flying Taint ActionValue ActionValueFrame ReachableRun
  RealFrameValue RealFrameLinked AGates SymbolicLinking FieldNonInterference.
From SM64.Proofs Require Import CensusV2 EngineV2Consumer.
From SM64.Proofs Require Import MWFReal RestSurface AirborneSurface
  DispatchKit CutsceneSurface AutomaticSurface StationarySurface
  MovingSurface ObjectSurface SubmergedSurface FloorsSurface WarpSurface
  ActWriterSurface ObjectLeafSurface FloorsLeafSurface AutomaticLeafSurface
  LocalVarsSurface OutParamSurface WindSurface InterSurface
  MarioStepSurface PerformAirStepSurface PerformWaterStepSurface BullySurface
  RetSurface StationaryLeafSurface MovingLeafSurface AirborneLeafSurface
  MboCSurface SubmergedLeafSurface CutsceneLeafSurface.

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

  (* 2026-06-10: the POSITIVE wf pair (marioObj_wf_lp/gMarioState_wf_lp --
     "the chase loads SUCCEED with the right values") is GONE from the
     carried invariant: preserving load-success across a callee needs
     cell-unchanged facts no body walk provides, which made the funcall
     rest row (reach_rest_marg_lp, DELETED) undischargeable. The engines
     only use the chase rows on loads the exec derivation itself performed,
     so the CONDITIONAL forms (RealFrameLinked.gms_cond_lp/mobj_cond_lp)
     suffice -- and those are projections of MWF, carried below via the
     H*_of_mwf rows. Init got strictly EASIER. *)
  Definition mem_ok_lp (m : mem) : Prop :=
    Mem.valid_block m bm /\ mem_nontainted_lp m /\ MWF m.

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
  Variable SafeB : block -> Prop.

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
  (* the three MWF projections that REPLACED the funcall-level rest row
     (reach_rest_marg_lp, DELETED 2026-06-10): with the carried wf rows
     CONDITIONAL, everything the wrapper needs after a reached funcall is
     a projection of the MWF the value engine already returns. All three
     are PROVED at the MWF_real grounding (mwf_real_ctl; R6 + the SafeB
     distinctness facts; R5 verbatim). *)
  Hypothesis Hnoa_of_mwf : forall m, MWF m -> NoA m.
  Hypothesis Hmobj_of_mwf : forall m, MWF m -> mobj_cond_lp lp m bm.
  Hypothesis Hgms_of_mwf : forall m, MWF m -> gms_cond_lp lp m bm.
  (* the chase-root row of MWF at the marioObj cell: its value, if a
     pointer, is SafeB. At the MWF_real grounding this is PROVED
     (MWFReal.mwf_real_chase_root at fld := _marioObj). *)
  Hypothesis Hchase_safe : forall delta mm b' o',
      field_offset (prog_comp_env mario.prog) mario._marioObj mario_state_members
        = Errors.OK (delta, Full) ->
      MWF mm ->
      Mem.loadv Mptr mm (Vptr bm (Ptrofs.repr delta)) = Some (Vptr b' o') ->
      SafeB b'.
  (* THE RESTATED STORE ROW (execution-relative): the walk hands the row
     the SafeB provenance of _t'49/_t'13. The previous forall-le pair was
     FALSE for the real lp (adversarial le -> store1 hits the controller
     A-cell). *)
  Hypothesis Hstore_safe :
    forall e le mm a1 a2 tt le' mm' out,
      NoA mm -> MWF mm -> RealFrameValue.prov_ok (Sassign a1 a2) ->
      (forall b o, le ! mario._t'49 = Some (Vptr b o) -> SafeB b) ->
      (forall b o, le ! mario._t'13 = Some (Vptr b o) -> SafeB b) ->
      exec_stmt function_entry2 (lp_ge lp) e le mm (Sassign a1 a2) tt le' mm' out ->
      NoA mm' /\ MWF mm'.
  Hypothesis Hbcr :
    forall oid a al le mm vf fd,
      RealFrameValue.reach_chk reached_id (Scall oid a al) ->
      eval_expr (lp_ge lp) empty_env le mm a vf ->
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
    intros i m m' Ha _ (Hv & Hsat & HMWF) Hst.
    assert (HnoA : NoA m) by (eapply input_grounds_noA; eassumption).
    destruct (execute_mario_action_preserves_real_reached_lp lp LO_mario not_tainted bm NoA MWF SafeB reached_id reached_fd m m'
                Hreach_val Hnoa_of_mwf Hmobj_of_mwf Hgms_of_mwf
                Hchase_safe Hstore_safe Hbcr Hbodyrck
                HnoA HMWF Hv Hsat (step_lp_real i m m' Hst))
      as (_ & Hv' & Hs' & HMWF').
    exact (conj Hv' (conj Hs' HMWF')).
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
  Variable SafeB : block -> Prop.

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
  (* the three MWF projections replacing the rest row (see the abstract
     section's comment). All three are PROVED at the MWF_real grounding. *)
  Hypothesis Hnoa_of_mwf : forall m, MWF m -> NoA_real m.
  Hypothesis Hmobj_of_mwf : forall m, MWF m -> mobj_cond_lp lp m bm.
  Hypothesis Hgms_of_mwf : forall m, MWF m -> gms_cond_lp lp m bm.
  (* the chase-root row of MWF at the marioObj cell: its value, if a
     pointer, is SafeB. At the MWF_real grounding this is PROVED
     (MWFReal.mwf_real_chase_root at fld := _marioObj). *)
  Hypothesis Hchase_safe : forall delta mm b' o',
      field_offset (prog_comp_env mario.prog) mario._marioObj mario_state_members
        = Errors.OK (delta, Full) ->
      MWF mm ->
      Mem.loadv Mptr mm (Vptr bm (Ptrofs.repr delta)) = Some (Vptr b' o') ->
      SafeB b'.
  Hypothesis Hstore_safe :
    forall e le mm a1 a2 tt le' mm' out,
      NoA_real mm -> MWF mm -> RealFrameValue.prov_ok (Sassign a1 a2) ->
      (forall b o, le ! mario._t'49 = Some (Vptr b o) -> SafeB b) ->
      (forall b o, le ! mario._t'13 = Some (Vptr b o) -> SafeB b) ->
      exec_stmt function_entry2 (lp_ge lp) e le mm (Sassign a1 a2) tt le' mm' out ->
      NoA_real mm' /\ MWF mm'.
  Hypothesis Hbcr :
    forall oid a al le mm vf fd,
      RealFrameValue.reach_chk reached_id (Scall oid a al) ->
      eval_expr (lp_ge lp) empty_env le mm a vf ->
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
      mem_ok_lp bm MWF init ->
      Forall (fun i => a_pressed_real bm i = false) is ->
      Forall (fun i => spawn_flying i = false) is ->
      reachable mem mem step_real init is m ->
      ~ mem_flying_lp bm m.
  Proof.
    intros init is m Hinit HnoA Hns Hreach.
    exact (noA_no_spawn_never_flying_lp lp LO_mario bm MWF mem
             (a_pressed_real bm) spawn_flying step_real step_real_steps
             NoA_real reached_id reached_fd SafeB
             Hreach_val Hnoa_of_mwf Hmobj_of_mwf Hgms_of_mwf
             Hchase_safe Hstore_safe Hbcr Hbodyrck
             input_grounds_noA_real init is m Hinit HnoA Hns Hreach).
  Qed.

End NoARealInput.

(* ====================================================================== *)
(* THE V2 GROUNDED CAPSTONE: the reached set made CONCRETE.                *)
(*                                                                        *)
(* Above, reached_id / reached_fd / Hreach_val / Hbcr / Hbodyrck are       *)
(* abstract: the engine contract Hreach_val is one MONOLITHIC residual     *)
(* over an unspecified reached set. Here they are real:                    *)
(*   - reached_id := EngineV2Consumer.root_RID -- the 20 callee idents     *)
(*     of the REAL f_execute_mario_action body (generated AST);            *)
(*   - reached_fd := EngineV2Consumer.reached_v2 lp -- the 15 censused     *)
(*     mario.c bodies + the bridged update_mario_button_inputs + the       *)
(*     NAMED per-symbol rest surface (7 dispatch handlers, interactions,   *)
(*     special floors, the exempt whitelist, 2 externals);                 *)
(*   - Hbodyrck := root_body_reach_chk (PROVED: reflexivity over the       *)
(*     generated root body);                                               *)
(*   - Hbcr := root_call_resolves (PROVED: every Tfunction-pinned Evar     *)
(*     callee the root reaches at empty_env resolves into reached_v2,      *)
(*     by per-symbol linkorder resolution);                                *)
(*   - Hreach_val := reach_value_preserves_reached_v2 (PROVED from the     *)
(*     engine: the 15-body census walk, the store/call/TI leaves, the     *)
(*     gate kill, the dispatch kill, the umbi bridge, the REFUTED writer   *)
(*     leaf, and the call-resolution closure are all DISCHARGED).          *)
(*                                                                        *)
(* What the monolithic engine residual DECOMPOSES INTO is this section's   *)
(* hypothesis surface -- each named, satisfiable, per-cell/per-symbol:     *)
(*   - MWF projections + per-cell store stability (discharged when MWF is  *)
(*     instantiated concretely -- a definition, not a proof debt);         *)
(*   - the SafeB chase closure (HchaseRoot/HchaseStep/HSafeNotBm);         *)
(*   - WL_exempt + Hrest_pres: PER-SYMBOL facts about the named callee     *)
(*     symbols' lp resolutions. Hrest_pres at the 7 dispatch handlers is   *)
(*     THE REMAINING CRUX -- exactly where the A-gating taint closure      *)
(*     (Taint.v census + AGates.v kills) gets consumed next;               *)
(*   - return-value non-aliasing + external facts (NoA needs no own        *)
(*     stability hypotheses: it is a projection of MWF via Hmwf_ctl).      *)
(* ====================================================================== *)

Section NoARealInputV2.
  Variable lp : Clight.program.
  Hypothesis LO_mario : linkorder mario.prog lp.

  Variable bm : block.
  Variable SafeB : block -> Prop.
  Variable MWF : mem -> Prop.

  (* the spawn-exclusion input bit stays abstract (warp/level script). *)
  Variable spawn_flying : mem -> bool.

  (* ---- the engine-v2 residual surface (EngineV2Consumer's hypotheses,
     at the CONCRETE invariant NoA_real bm = the controller A-bit is clear).
     Each is named, satisfiable, and per-cell/per-symbol dischargeable. ---- *)

  (* MWF projections: the run invariant contains the two A-clear cells *)
  Hypothesis Hmwf_inp : forall m, MWF m -> input_a_clear m bm.
  Hypothesis Hmwf_ctl : forall m, MWF m -> ctl_a_clear m bm.

  (* the SafeB chase closure *)
  Hypothesis HactVint : forall mm, MWF mm -> forall av,
      Mem.load Mint32 mm bm 12 = Some av ->
      av = Vundef \/ exists vi, av = Vint vi.
  (* CONDITIONAL on the load (the Sset execution supplies the evidence):
     a positive "the load succeeds" row would make MWF jointly
     unsatisfiable with Hmwf_free below. *)
  Hypothesis HPgms : forall mm gb b o, MWF mm ->
      Genv.find_symbol (lp_ge lp) mario._gMarioState = Some gb ->
      Mem.loadv Mptr mm (Vptr gb Ptrofs.zero) = Some (Vptr b o) ->
      b = bm /\ o = Ptrofs.zero.
  Hypothesis HchaseRoot : forall fld delta mm b' o',
      mem_id fld chase_root_fields = true ->
      field_offset (prog_comp_env mario.prog) fld mario_state_members
        = Errors.OK (delta, Full) ->
      MWF mm ->
      Mem.loadv Mptr mm (Vptr bm (Ptrofs.add Ptrofs.zero (Ptrofs.repr delta)))
        = Some (Vptr b' o') ->
      SafeB b'.
  Hypothesis HchaseStep : forall mm b ofs b' o',
      MWF mm -> SafeB b ->
      Mem.loadv Mptr mm (Vptr b ofs) = Some (Vptr b' o') -> SafeB b'.
  Hypothesis HSafeNotBm : forall bsafe, SafeB bsafe -> bsafe <> bm.

  (* per-cell store stability of MWF *)
  Hypothesis Hmwf_window : forall mm mm' ch (delta : Z) vv,
      MWF mm -> store_window_ok delta (size_chunk ch) = true ->
      Mem.store ch mm bm delta vv = Some mm' -> MWF mm'.
  Hypothesis Hmwf_input : forall mm mm' vv,
      MWF mm -> Int.and vv (Int.repr 2) = Int.zero ->
      Mem.store Mint16unsigned mm bm 2 (Vint vv) = Some mm' -> MWF mm'.
  Hypothesis Hmwf_glob : forall gid, mem_id gid stored_globals = true ->
      forall bg, Genv.find_symbol (lp_ge lp) gid = Some bg ->
        bg <> bm /\
        (forall mm mm' ch0 (d : Z) vv,
            MWF mm -> Mem.store ch0 mm bg d vv = Some mm' -> MWF mm').
  Hypothesis Hmwf_chase : forall mm ch bsafe (d : Z) vv mm',
      MWF mm -> SafeB bsafe ->
      (forall bb oo, vv <> Vptr bb oo) ->
      Mem.store ch mm bsafe d vv = Some mm' -> MWF mm'.
  Hypothesis Hmwf_umbi : forall mm mm',
      MWF mm ->
      Mem.unchanged_on (fun b o => ~ umbi_footprint bm b o) mm mm' ->
      input_a_clear mm' bm -> MWF mm'.

  (* per-symbol: the whitelisted callee symbols resolve to marg-exempt
     definitions (their first param is not a MarioState ptr) *)
  Hypothesis WL_exempt : forall e le m fid fty vf fd,
      mem_id fid exempt_callees = true ->
      eval_expr (lp_ge lp) e le m (Evar fid fty) vf ->
      Genv.find_funct (lp_ge lp) vf = Some fd ->
      marg_exempt fd = true.

  (* per-symbol: the rest surface preserves the carried facts -- ONLY
     where lp resolves the symbol to an INTERNAL body (a rest symbol lp
     keeps External carries no obligation here: the engine's External
     path goes through the reached-gated Hext_action/Hmwf_ext). THE REMAINING
     CRUX at this scope: at the 7 dispatch handlers + interactions +
     special floors this is exactly where the A-gating taint closure
     (Taint.v + AGates.v kills) gets consumed; at the exempt whitelist
     it is per-symbol frame reasoning (vec3 family). The MWF-grounded
     section below decomposes this per symbol via RestSurface.v. *)
  Hypothesis Hrest_pres : forall m f vargs t m' vres,
      rest_fd lp (Internal f) ->
      (marg_exempt (Internal f) = false -> marg_ok bm vargs) ->
      sargs_ok (Internal f) vargs ->
      eval_funcall function_entry2 (lp_ge lp) m (Internal f) vargs t m' vres ->
      NoA_real bm m -> MWF m -> Mem.valid_block m bm ->
      action_sat not_tainted m bm ->
      Mem.valid_block m' bm /\ action_sat not_tainted m' bm /\ MWF m'.

  (* RETURN-VALUE NON-ALIASING, REFINED (RetSurface): identical to the
     real_mwf section's refinement below.  The opaque forall-reached row is
     PROVED for every reached fundef whose return type cannot carry a Vptr
     through the return cast (Tvoid / Tint I8/I16/IBool / Tfloat,
     ret_fd_safe = true, ZERO new trust on ptr64 = false).  What stays
     assumed is the SHARPER residual: only the Tint I32 returns (the 4
     getters + the 7 dispatchers, status ints) and the External fundefs. *)
  Hypothesis Hret_unsafe : forall fd m0 vargs0 t0 m0' vres0,
      reached_v2 lp fd ->
      RetSurface.ret_fd_safe fd = false ->
      eval_funcall function_entry2 (lp_ge lp) m0 fd vargs0 t0 m0' vres0 ->
      forall b o, vres0 = Vptr b o -> b <> bm.
  (* section-local Let (not a persistent Lemma -- the real_mwf section below
     defines its own module-level Lemma Hret_call) *)
  Let Hret_call : forall fd m0 vargs0 t0 m0' vres0,
      reached_v2 lp fd ->
      eval_funcall function_entry2 (lp_ge lp) m0 fd vargs0 t0 m0' vres0 ->
      forall b o, vres0 = Vptr b o -> b <> bm :=
    RetSurface.ret_avoids_bm_of_unsafe function_entry2 (lp_ge lp) bm
      (reached_v2 lp) Hret_unsafe.

  (* externals, REACHED-GATED (per-symbol surface: reached_v2 lp (External
     ef) carries a named rest symbol resolving to ef). The forall-ef forms
     -- including the DELETED Hret_ext -- were FALSE for the real program
     (EF_memcpy / EF_vload counterexamples). *)
  Hypothesis Hext_action : forall ef targs tres cc vargs m t vres m',
      reached_v2 lp (External ef targs tres cc) ->
      external_call ef (lp_ge lp) vargs m t vres m' ->
      Mem.unchanged_on (action_cell bm) m m'.
  Hypothesis Hmwf_ext : forall ef targs tres cc vargs m t vres m',
      reached_v2 lp (External ef targs tres cc) ->
      external_call ef (lp_ge lp) vargs m t vres m' ->
      Mem.valid_block m bm -> MWF m -> MWF m'.
  (* MWF crosses function entry/exit by the PRECISE operations there:
     entry allocates fresh Vundef blocks (writes no existing memory);
     exit frees them (free only KILLS loads). Load-CONDITIONAL MWF rows
     satisfy both for free; a blunt unchanged-on-bm leaf would be
     UNSATISFIABLE for the intended MWF (controller-chase rows off bm). *)
  Hypothesis Hmwf_entry : forall f vargs m e le m1,
      function_entry2 (lp_ge lp) f vargs m e le m1 -> MWF m -> MWF m1.
  Hypothesis Hmwf_free : forall m2 m3 l,
      Mem.free_list m2 l = Some m3 -> MWF m2 -> MWF m3.

  (* NO separate NoA-stability hypotheses: NoA_real bm = ctl_a_clear is a
     PROJECTION of MWF (Hmwf_ctl), and the engine derives every mid-walk
     NoA fact from the threaded MWF. A forall-stmt NoA-stability leaf
     would be FALSE for the real lp (an adversarial Sassign through the
     controller chase sets the A bit) -- so it must not appear here. *)

  (* ---- the wrapper rows that are NOT engine-shaped (the root body's own
     provenance stores + the wf-pair projections), same shapes as the
     abstract section's. ---- *)
  (* the gMarioState symbol block is never a chase target: a genv symbol
     block vs the runtime blocks SafeB collects (same trust class and
     discharge path as the mwf section's Hgms_blk, of which it is a
     projection). The ONLY new primitive the funcall rest row
     (reach_rest_marg_lp, DELETED 2026-06-10) decomposed into at this
     scope -- NoA is already a projection (Hmwf_ctl) and the wf-pair
     projections are PROVED below from the chase rows. *)
  Hypothesis Hgms_not_safe : forall gb,
      Genv.find_symbol (lp_ge lp) mario._gMarioState = Some gb -> ~ SafeB gb.

  (* the marioObj conditional row is a projection of MWF: a pointer in the
     marioObj cell is SafeB (HchaseRoot at the computed offset 136), hence
     off bm and off gMarioState's block. *)
  Lemma Hmobj_of_mwf : forall m, MWF m -> mobj_cond_lp lp m bm.
  Proof.
    intros m HM b o Hld.
    assert (Hsafe : SafeB b).
    { eapply (HchaseRoot mario._marioObj 136 m b o);
        [ vm_compute; reflexivity
        | exact marioObj_offset_mario
        | exact HM
        | rewrite Ptrofs.add_zero_l; exact Hld ]. }
    split; [ exact (HSafeNotBm b Hsafe) | ].
    intros gb Hgb Heq. subst b. exact (Hgms_not_safe gb Hgb Hsafe).
  Qed.
  (* the gMarioState conditional row is HPgms, eta-wrapped. *)
  Lemma Hgms_of_mwf : forall m, MWF m -> gms_cond_lp lp m bm.
  Proof.
    intros m HM gb b o Hgb Hld. exact (HPgms m gb b o HM Hgb Hld).
  Qed.

  (* the chase-root row of MWF at the marioObj cell: its value, if a
     pointer, is SafeB. At the MWF_real grounding this is PROVED
     (MWFReal.mwf_real_chase_root at fld := _marioObj). *)
  Hypothesis Hchase_safe : forall delta mm b' o',
      field_offset (prog_comp_env mario.prog) mario._marioObj mario_state_members
        = Errors.OK (delta, Full) ->
      MWF mm ->
      Mem.loadv Mptr mm (Vptr bm (Ptrofs.repr delta)) = Some (Vptr b' o') ->
      SafeB b'.
  Hypothesis Hstore_safe :
    forall e le mm a1 a2 tt le' mm' out,
      NoA_real bm mm -> MWF mm -> RealFrameValue.prov_ok (Sassign a1 a2) ->
      (forall b o, le ! mario._t'49 = Some (Vptr b o) -> SafeB b) ->
      (forall b o, le ! mario._t'13 = Some (Vptr b o) -> SafeB b) ->
      exec_stmt function_entry2 (lp_ge lp) e le mm (Sassign a1 a2) tt le' mm' out ->
      NoA_real bm mm' /\ MWF mm'.

  (* ==================================================================== *)
  (* THE V2 GROUNDED THEOREM: same conclusion as noA_no_spawn_never_       *)
  (* flying_real, but the reached set is CONCRETE and the engine contract  *)
  (* is PROVED -- the monolithic Hreach_val residual is GONE, replaced by  *)
  (* the per-cell/per-symbol surface above.                                *)
  (* ==================================================================== *)
  Theorem noA_no_spawn_never_flying_real_v2 :
    forall (init : mem) (is : list mem) (m : mem),
      mem_ok_lp bm MWF init ->
      Forall (fun i => a_pressed_real bm i = false) is ->
      Forall (fun i => spawn_flying i = false) is ->
      reachable mem mem (step_real lp) init is m ->
      ~ mem_flying_lp bm m.
  Proof.
    exact (noA_no_spawn_never_flying_real lp LO_mario bm MWF spawn_flying
             root_RID (reached_v2 lp) SafeB
             (reach_value_preserves_reached_v2 lp LO_mario bm SafeB
                (NoA_real bm) MWF
                Hmwf_inp Hmwf_ctl HactVint HPgms HchaseRoot HchaseStep
                HSafeNotBm Hmwf_window Hmwf_input Hmwf_glob Hmwf_chase
                Hmwf_umbi WL_exempt Hrest_pres Hret_call
                Hext_action Hmwf_ext Hmwf_entry Hmwf_free Hmwf_ctl)
             Hmwf_ctl Hmobj_of_mwf Hgms_of_mwf Hchase_safe Hstore_safe
             (root_call_resolves lp LO_mario)
             root_body_reach_chk).
  Qed.

End NoARealInputV2.

(* ====================================================================== *)
(* THE MWF-GROUNDED CAPSTONE: the run invariant made CONCRETE.             *)
(*                                                                        *)
(* Above, MWF is an abstract Variable carried through the run, with 14     *)
(* stability/projection hypotheses about it (Hmwf_inp/ctl, HactVint,       *)
(* HPgms, HchaseRoot/Step, HSafeNotBm, Hmwf_window/input/glob/chase/       *)
(* umbi/entry/free). Here MWF is a DEFINITION --                           *)
(* MWFReal.MWF_real lp bm bc oc0 SafeB: eight rows over the REAL layout    *)
(* (input halfword @2, action word @12, controller ptr @156, controller    *)
(* button halfword @+18, chase roots @136/148/152, gMarioState's cell),    *)
(* every load row CONDITIONAL -- and ALL 14 of those hypotheses are        *)
(* PROVED (the MWFReal.mwf_real lemmas).                                   *)
(*                                                                        *)
(* What remains is exactly the part a definition cannot supply:            *)
(*   - FIVE block-distinctness facts (bc <> bm, SafeB vs bm/bc,            *)
(*     gMarioState's block, the stored_globals blocks): static-layout      *)
(*     facts about the run's concrete blocks, per-symbol dischargeable     *)
(*     at initialization (globals get distinct genv blocks; bm/bc are      *)
(*     runtime struct blocks the globals point INTO, never equal to a      *)
(*     genv symbol block);                                                 *)
(*   - the per-symbol callee surface: WL_exempt + Hrest_pres (THE          *)
(*     REMAINING CRUX -- the 7 dispatch handlers, where the A-gating       *)
(*     taint closure gets consumed), return non-aliasing (Hret_call/       *)
(*     return non-aliasing (Hret_call), the reached-gated externals       *)
(*     (Hext_action, Hmwf_ext); the funcall rest row Hrest and the         *)
(*     forall-ef Hext / forall-le store rows are GONE (FALSE or            *)
(*     undischargeable -- restated 2026-06-10).                            *)
(*                                                                        *)
(* The 24-hypothesis surface above becomes 15 here, and the initial        *)
(* condition mem_ok_lp bm (MWF_real ...) init is now a CHECKABLE           *)
(* property of one concrete memory, not a promise about an abstract        *)
(* invariant.                                                              *)
(* ====================================================================== *)

Section NoARealInputMWF.
  Variable lp : Clight.program.
  Hypothesis LO_mario : linkorder mario.prog lp.

  Variable bm : block.    (* Mario's MarioState block *)
  Variable bc : block.    (* the controller struct's block *)
  Variable oc0 : ptrofs.  (* the controller struct's offset within bc *)
  Variable SafeB : block -> Prop.  (* blocks the pointer chase can reach *)

  (* the spawn-exclusion input bit stays abstract (warp/level script). *)
  Variable spawn_flying : mem -> bool.

  Notation MWF := (MWF_real lp bm bc oc0 SafeB).

  (* ---- block-distinctness residuals: static-layout facts about the
     run's concrete blocks (bm is a runtime block -- gMarioState has
     gvar_init nil -- and bc is the controller block row R2 points to;
     genv symbol blocks are distinct from both). Satisfiable, and
     per-symbol dischargeable from the run's initialization. ---- *)
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
  Hypothesis Hgtimer_blk : forall gb,
      Genv.find_symbol (lp_ge lp) interaction._gGlobalTimer = Some gb ->
      gb <> bm /\ gb <> bc /\ ~ SafeB gb.
  (* the sInteractionHandlers table block: a static interaction.c global,
     distinct from Mario's runtime block / the controller struct / the
     object pool -- same trust class and discharge path as Hgtimer_blk *)
  Hypothesis Htable_blk : forall tb,
      Genv.find_symbol (lp_ge lp) interaction._sInteractionHandlers = Some tb ->
      tb <> bm /\ tb <> bc /\ ~ SafeB tb.
  (* the knockback-table blocks (sBackward/sForwardKnockbackActions):
     static interaction.c globals, distinct from Mario's runtime block /
     the controller struct / the object pool -- same trust class and
     discharge path as Hgtimer_blk / Htable_blk.  Grounds MWF_real's R10
     (untainted knockback-table contents, the dka return-value row). *)
  Hypothesis Hktab_blk : forall gid kb,
      mem_id gid knockback_table_ids = true ->
      Genv.find_symbol (lp_ge lp) gid = Some kb ->
      kb <> bm /\ kb <> bc /\ ~ SafeB kb.
  (* sFloorAlignMatrix IS in the SafeB reach closure: a static f32[2][4][4]
     global whose address Mario's gfx legitimately holds (the real code does
     `marioObj->gfx.throwMatrix = &sFloorAlignMatrix[i]` in align_with_floor).
     The POSITIVE dual of the ~SafeB rows above -- a distinct static global
     (so consistent with them via genv-symbol injectivity: its block is none
     of bm / bc / gMarioState / gtimer / table / ktab) and bm-disjoint (bm is
     the runtime gMarioState block).  Grounds MovingLeafSurface's Hsfam_safe;
     dischargeable when SafeB is concretized as the chase/reach closure. *)
  Hypothesis Hsfam_safe : forall gb,
      Genv.find_symbol (lp_ge lp) mario_actions_moving._sFloorAlignMatrix
        = Some gb -> SafeB gb.

  (* ---- the OUT-PARAM ARC residuals (find_floor phantom -> honest swap).
     Two TRUE, standard-CompCert, per-symbol-dischargeable facts that let
     the ledge cluster's find_floor out-param call use the FAITHFUL gated
     spec `call_pres_ext_oc` instead of the phantom-false `call_pres_ext`:
       - Hbc_sym: the controller struct bc IS a static global (gControllers)
         -- so an out-param landing in a local is bc-disjoint via local_blk's
         global clause.  (Grounds the b<>bc premise of mwf_real_local_store.)
       - Hglob_valid: every genv symbol block is valid in any MWF memory
         (globals come from init_mem and validity is monotone) -- needed to
         prove a fresh stack local is disjoint from every global block. ---- *)
  Hypothesis Hbc_sym :
    exists gid, Genv.find_symbol (lp_ge lp) gid = Some bc.
  Hypothesis Hglob_valid :
    forall m, MWF m -> forall gid bg,
        Genv.find_symbol (lp_ge lp) gid = Some bg -> Mem.valid_block m bg.
  (* find_floor as a faithful OUT-PARAM writer: carried-preservation GATED
     on the out-param being a caller stack local (local_blk).  TRUE in the
     intended model; replaces the FALSE `call_pres_ext find_floor`. *)
  Hypothesis Hocp_find_floor :
    call_pres_ext_oc lp bm (NoA_real bm) MWF SafeB mario._find_floor.
  (* the SHARED pole/tornado/hang external residuals -- the HONEST gated
     refinements that let set_pole_position's body be WALKED (replacing the old
     opaque Hcp_spp whole-function residual).  Each is GATED on the real call
     shape (true in the intended model; the walker verifies the gate at every
     call site) and per-symbol dischargeable, exactly like Hocp_find_floor:
       - vec3f_find_ceil: out-param writer (call into &_ceil stack local);
       - f32_find_wall_collision: writes floats ONLY through its pointer
         args; its three real call shapes (set_pole_position: all-window;
         tornado: all-local; push_mario_out_of_object: MIXED window+local)
         are all instances of ONE union gate, args_window_or_local (wol) --
         a single row, with the wc/ol forms derived (call_pres_ext_wc_of_wol
         / call_pres_ext_ol_of_wol);
       - vec3f_copy / vec3s_set: object writers (dst chases m->marioObj->SafeB). *)
  Hypothesis Hocp_find_ceil :
    call_pres_ext_oc lp bm (NoA_real bm) MWF SafeB
      mario_actions_automatic._vec3f_find_ceil.
  Hypothesis Hwolcp_fwc :
    call_pres_ext_wol lp bm (NoA_real bm) MWF SafeB
      mario_actions_automatic._f32_find_wall_collision.
  Hypothesis Hscp_v3f :
    call_pres_ext_sc lp bm (NoA_real bm) MWF SafeB
      mario_actions_automatic._vec3f_copy.
  Hypothesis Hscp_v3s :
    call_pres_ext_sc lp bm (NoA_real bm) MWF SafeB
      mario_actions_automatic._vec3s_set.

  (* ---- the surviving per-symbol residuals, now stated at the CONCRETE
     invariant MWF_real (same shapes as the v2 section's; see the
     comments there). ---- *)
  Hypothesis WL_exempt : forall e le m fid fty vf fd,
      mem_id fid exempt_callees = true ->
      eval_expr (lp_ge lp) e le m (Evar fid fty) vf ->
      Genv.find_funct (lp_ge lp) vf = Some fd ->
      marg_exempt fd = true.
  (* ---- the rest surface, decomposed PER SYMBOL (RestSurface.v).
     ELEVEN per-TU linkorder pins (LO_mario's class, link-time facts)
     + the negative pin (the exempt whitelist + the music helper stay
     External in lp) pin every rest symbol's Internal resolution to THE
     real generated body -- so the v2 section's whole-surface Hrest_pres
     residual becomes 11 named per-real-body preservation residuals (the
     stub is PROVED). Each survivor is a statement about ONE clightgen'd
     AST object: THE REMAINING CRUX, where the A-gating taint closure
     (Taint.v + AGates.v kills) gets consumed by the engine-v2 census
     walk over that TU. ---- *)
  Hypothesis LO_sta : linkorder mario_actions_stationary.prog lp.
  Hypothesis LO_mov : linkorder mario_actions_moving.prog lp.
  Hypothesis LO_air : linkorder mario_actions_airborne.prog lp.
  Hypothesis LO_sub : linkorder mario_actions_submerged.prog lp.
  Hypothesis LO_cut : linkorder mario_actions_cutscene.prog lp.
  Hypothesis LO_aut : linkorder mario_actions_automatic.prog lp.
  Hypothesis LO_obj : linkorder mario_actions_object.prog lp.
  Hypothesis LO_int : linkorder interaction.prog lp.
  Hypothesis LO_beh : linkorder behavior_actions.prog lp.
  Hypothesis LO_lvl : linkorder level_update.prog lp.
  Hypothesis LO_stp : linkorder mario_step.prog lp.
  Hypothesis Hrest_ext_only : forall fid f,
      mem_id fid exempt_callees = true \/
      fid = mario._play_infinite_stairs_music ->
      ~ resolves_lp lp fid (Internal f).
  (* the stationary dispatcher is WALKED (StationarySurface.stationary_pres
     over the generic DispatchKit; the particleFlags epilogue store is
     killed by the window census): PROVED from per-leaf-callee residuals
     keyed by the 37-id census stationary_callee_ids, plus the shared
     quicksand body below.

     StationaryLeafSurface (slices 1-6): the clean stationary-step cluster +
     act_shivering + act_waking_up + the act3 caller-action stop cluster
     (act_braking_stop / act_butt_slide_stop, via stopping_step) + the dasma
     held-object cluster (act_hold_heavy_idle / act_slide_kick_slide_stop, via
     ObjectLeafSurface.dasma_row reused) + act_ground_pound_land (dasma + the
     landing_step act3 twin) are now WALKED (stationary_leaf_callees_pres), so
     the assumed surface here shrinks to the FILTERED remainder sta_rest_ids
     (27 leaves).  Finishing the family deletes this hypothesis entirely. *)
  (* the stationary family's audio externals (raise/lower_background_noise,
     stop_sound, play_mario_heavy_landing_sound, play_sound_if_no_flag) --
     EF_external in every linked TU, write no Mario state: the SAME honest
     model-boundary class as the obj_ext audio rows. *)
  Hypothesis Hpres_sta_ext : forall fid,
      mem_id fid StationaryLeafSurface.sta_ext_ids = true ->
      call_pres_ext lp bm (NoA_real bm) MWF fid.
  (* The stationary family is now COMPLETE: every leaf in
     stationary_callee_ids is WALKED (StationaryLeafSurface), so the filtered
     remainder sta_rest_ids vm_computes to [].  This formerly-assumed rest
     hypothesis is therefore PROVED vacuously here -- the residual is DELETED
     from the capstone surface (no longer an assumption). *)
  Let Hpres_sta_rest : forall fid f,
      mem_id fid sta_rest_ids = true ->
      (prog_defmap mario_actions_stationary.prog) ! fid
        = Some (Gfun (Internal f)) ->
      body_pres lp (NoA_real bm) MWF bm f :=
    ltac:(intros fid f H _; vm_compute in H; discriminate H).
  (* mario_update_quicksand (mario_step.prog, pinned by LO_stp): the ONE
     out-of-TU helper the stationary/moving/object prologues call --
     WALKED (FloorsLeafSurface.qsand_pres); the proved Let is below,
     after the ext rows it consumes. *)
  (* the moving dispatcher is WALKED (MovingSurface.moving_pres; its
     two-store particleFlags epilogue is killed by the window census):
     PROVED from per-leaf-callee residuals keyed by the 39-id census
     moving_callee_ids, plus the shared quicksand body.  MovingLeafSurface
     .moving_leaf_callees_pres SHRINKS that 39-id residual to the
     mov_rest_ids leaves still un-walked: the knockback cluster (7 leaves
     -- act_{,soft_,hard_}{backward,forward}_ground_kb + act_ground_bonk,
     bottoming out in common_ground_knockback_action) is WALKED, so the
     residual surface is the un-walked 32. *)
  (* mov_rest_ids = nil: ALL 39 moving leaves are now WALKED (act_walking, the
     LAST, closes the family) -- so this residual is VACUOUS, no longer
     ASSUMED but PROVED (its mem_id-true premise is unsatisfiable). *)
  Lemma Hpres_mov_rest : forall fid f,
      mem_id fid MovingLeafSurface.mov_rest_ids = true ->
      (prog_defmap mario_actions_moving.prog) ! fid
        = Some (Gfun (Internal f)) ->
      body_pres lp (NoA_real bm) MWF bm f.
  Proof. intros fid f H _; vm_compute in H; discriminate H. Qed.
  (* the moving family's pure audio externals (mov_ext_ids): the honest
     model boundary -- play_mario_{heavy_,}landing_sound{,_once} /
     play_sound_if_no_flag.  Discharged via the obj_ext boundary below. *)
  Hypothesis Hpres_mov_ext : forall fid,
      mem_id fid MovingLeafSurface.mov_ext_ids = true ->
      call_pres_ext lp bm (NoA_real bm) MWF fid.
  (* the airborne dispatcher is WALKED (AirborneSurface.airborne_pres):
     its whole-628-line-body residual is PROVED from per-leaf-callee
     residuals keyed by the 43-id census airborne_callee_ids (41 non-T
     act handlers + the 2 prologue helpers; the 3 T handlers are dead
     code under the dispatch kill).  AirborneLeafSurface SHRINKS the
     43-id census to the un-walked airborne_rest_ids: SLICE A1 walks
     the two prologue helpers (check_common_airborne_cancels +
     play_far_fall_sound); SLICE A2 walks the three clean common_air_
     action_step wrappers (act_freefall / act_hold_freefall /
     act_wall_kick_air) under the Hcp_caas_real residual below.
     Discharge proceeds id by id.  SLICE A29 (act_riding_hoot, the LAST
     leaf) emptied airborne_rest_ids -> the Hpres_air_rest residual is
     GONE (discharged inline at the airborne_leaf_callees_pres call site
     by a vacuous-membership refutation). *)
  (* common_air_action_step: the BIG shared air-physics helper (the air
     analogue of perform_ground_step's Hcp_pgs) -- an INTERNAL
     mario_actions_airborne.prog function, carried as a call_pres_ACT residual
     (2nd-arg untainted_scalar gated, NOT plain call_pres) and discharged later
     by walking its body.  WHY the act-gate: caas forwards its 2nd PARAM
     _landAction straight to set_mario_action(m,_landAction,0), so a marg-only
     call_pres (gating arg0=bm only) would be PHANTOM-FALSE -- an adversarial
     tainted landAction would set m->action into the flying/taint set, breaking
     action_sat.  Every air-act caller passes an untainted-const landAction
     (e.g. ACT_FREEFALL_LAND), so caas rides the sids (untainted-2nd-arg) gate
     exactly like set_mario_action; its other stores are window /
     indexed-window + untainted-const actions.  Its presence DECOMPOSES the
     11 common_air_action_step-dependent act handlers from whole-cloth
     leaves into thin wrappers (SLICE A2 walks 3 of them). *)
  Hypothesis Hcp_caas_real :
    call_pres_act lp bm (NoA_real bm) MWF
      mario_actions_airborne._common_air_action_step.
  (* common_air_knockback_step DISCHARGED (2nd airborne keystone): it was a
     PHANTOM-FALSE call_pres residual -- the body forwards TWO param-actions
     (_landAction, _hardFallAction) to set_mario_action, so plain call_pres
     (which quantifies over all vargs) admitted a tainted action and broke
     action_sat.  The 7 knockback handlers now ride AirborneLeafSurface's
     cakbs dual-action hybrid walker (body_pres_of_cakbs_walk), which gates
     both action args untainted via the lift cakbs_funcall_pres.  No residual. *)
  (* perform_air_step is now WALKED, not assumed: its whole body is proved to
     preserve the carried run facts (PerformAirStepSurface.pas_cp, the air twin
     of MarioStepSurface.pgs_cp -- a loop-tolerant fn_var walk; the Lemma
     Hcp_pas below instantiates it at MWF_real).  The old opaque whole-body
     residual is therefore DECOMPOSED (not collapsed) into perform_air_step's
     honest callees one call-graph level down:
       - perform_air_quarter_step(m, intendedPos, stepArg): intendedPos is
         pas's OWN stack array but the MIDDLE arg (stepArg is last), so the mo
         class (last_arg_local) does NOT fit -- the honest gate is the paqs
         class (arg0 marg AND arg1 local: call_pres_paqs).  A marg-only
         call_pres would be phantom-FALSE (an unconstrained intendedPos could
         alias bm's action cell).  Now WALKED, not assumed: the whole
         perform_air_quarter_step body is proved to preserve the carried run
         facts (PerformAirStepSurface.paqs_cp, a loop-tolerant fn_var walk --
         _nextPos is paqs's OWN stack array; the Lemma Hcp_paqs_real below
         instantiates it at MWF_real).  Its gWaterSurfacePseudoFloor store
         rides the stored_globals census (mwf_real_glob); resolve / find_floor
         / vec3f_find_ceil / find_water_level / vec3f_copy(window) / atan2s
         ride the SAME gated-external rows the pgqs walk consumes; the entry
         vec3f_copy(nextPos, intendedPos) (both LOCAL) rides the ol gate
         DERIVED from Hwolcp_v3f_real (call_pres_ext_ol_of_wol).  Its one
         genuinely NEW residual is the deeper INTERNAL (mario_step.prog) helper
         check_ledge_grab (Hcp_clg_real below): a fn_var-walking bool-returning
         predicate, dischargeable later by the same machinery.
       - apply_gravity(m): marg INTERNAL -- now WALKED zero-residual (Lemma
         Hcp_ag below), together with its two clean callees apply_twirl_gravity
         (Hcp_atg) + should_strengthen_gravity_for_jump_ascent (Hcp_ssg); its
         only chase store is m->marioBodyState->wingFlutter = 1 (cact gate).
       - apply_vertical_wind(m): also marg INTERNAL, a CLEAN window-writer
         (no calls, no fn_vars, only m->vel[1] indexed-window stores) -- now
         WALKED zero-residual (Lemma Hcp_avw below, the air twin of msfv_row).
       - mario_get_terrain_sound_addend(m): the already-WALKED marg row
         (Hcp_mgtsa_real, shared with pgs).
       - vec3f_copy / vec3s_set: the ungated obj_ext externals (Hpres_obj_ext).
     decompose, not collapse. *)
  (* mario_blow_off_cap: act_getting_blown's cap-blow-off helper (INTERNAL
     interaction.prog).  It spawns a cap Object and stores through that fresh
     non-Mario block; that spawn-into-cact chase pattern needs the spawn/wind
     arc the base wwalk engine does not yet carry, so it is carried as a
     call_pres residual (the air analogue of Hcp_caas_real / Hcp_pas_real) and
     discharged later by walking its body.  Its presence DECOMPOSES
     act_getting_blown (all root-window stores otherwise) into a thin wrapper. *)
  (* Hcp_mboc_real (mario_blow_off_cap) is now WALKED and PROVED below
     (Lemma Hcp_mboc_real, after Hcp_spawn_real), resting on the honest
     spawn_object / save_file_set_cap_pos external boundaries -- see
     MboCSurface.mboc_cp.  No longer an assumed hypothesis. *)
  (* approach_f32: the asymptotic-approach math helper.  EF_external in EVERY
     generated TU (Gfun(External ...), no internal body anywhere) -- the same
     honest terminal external-call model boundary as atan2s/sqrtf, and (unlike
     them) not already in obj_ext_ids/floors_ext_ids. *)
  Hypothesis Hcpx_approach_f32_real :
    call_pres_ext lp bm (NoA_real bm) MWF
      mario_actions_airborne._approach_f32.
  (* the submerged dispatcher is WALKED (SubmergedSurface.submerged_pres
     over the generic DispatchKit; the quicksandDepth store is killed by
     the window census, and the two headAngle chase-pair stores -- the
     ONLY dispatcher stores through a chased pointer -- by the MWF chase
     rows: the root load at bm@152 lands in SafeB, SafeB is bm-disjoint).
     Its 33-id census residual is now SHRUNK leaf by leaf by
     SubmergedLeafSurface.submerged_leaf_callees_pres.

     SLICE 1: act_metal_water_standing WALKED (a pure body_pres_of_wwalk
     walk: three set_mario_action(const) cancels, a head-anim switch
     [set_mario_animation], an is_anim_at_end gate, the stop_and_set_height_
     to_floor step, window stores to actionState/particleFlags; NO chase
     stores).  The shared helper rows is_anim_at_end / set_mario_animation
     are WALKED inside the leaf surface; set_mario_action is the reusable
     smact_pres keystone.  As of SLICE 15 ALL 33 census ids are WALKED, so there
     is NO Hpres_sub_rest catch-all hypothesis any more -- the family discharge
     is submerged_leaf_callees_pres_full, whose vacuous rest premise is proved
     inline (sub_rest_ids computes to []). *)
  (* stop_and_set_height_to_floor (mario_step.prog) needs NO hypothesis --
     DISCHARGED in-surface (SubmergedLeafSurface.sub_sashf_row, the SAME walk as
     AutomaticLeafSurface.Hsasthf): writes pos/vel (window) + copies into
     marioObj's gfx pos/angle through the chased marioObj pointer (a NON-bm
     SafeB pool block, action cell untouched).  ids=[mario_set_forward_vel]
     (sub_msfv_row); xids=[vec3f_copy; vec3s_set] ride the EXISTING obj_ext
     boundary (Hpres_obj_ext, already assumed by the whirlpool slice) -- NO new
     trust. *)
  (* SLICE 2/3/5 metal-water sound+speed helpers are now DISCHARGED in-surface
     (SubmergedLeafSurface): play_metal_water_jumping_sound (sub_pmwjs_row, ids=
     [play_sound_if_no_flag]), update_metal_water_jump_speed (sub_umwjs_row, xids=
     [approach_f32]), play_metal_water_walking_sound (sub_pmwws_row, ids=
     [is_anim_past_frame] + xids=[play_sound]), update_metal_water_walking_speed
     (sub_umwws_row, xids=[approach_s32]) -- all window stores, all callees already
     proved or obj_ext, NO hypothesis needed.  set_mario_anim_with_accel is now
     DISCHARGED inside SubmergedLeafSurface as call_pres_np3 (sub_smawa_row, reusing
     MovingLeafSurface.mov_smawa_row) and threaded through the two metal-water-walking
     leaves via the np3 channel -- NO hypothesis needed. *)
  (* SLICE 6 (the water-IDLE cluster: water_idle/hold + water_action_end/hold):
     common_idle_step is the shared swim-idle step.  Writes m->faceAngle
     (window) + chases m->marioBodyState->headAngle (a SafeB chase-root block) +
     calls update_swimming_yaw/pitch/speed, perform_water_step, update_water_
     pitch, set_mario_animation/set_mario_anim_with_accel.  NEVER the action
     cell (the act handlers dispatch set_mario_action themselves), so a genuine
     call_pres for any caller.  Honest residual (body walk = chase machinery +
     perform_water_step, a later unit).  The four idle leaves reduce to it + the
     already-walked is_anim_at_end + the set_mario_action/dasma sids. *)
  Hypothesis Hcp_cis_real :
    call_pres lp bm (NoA_real bm) MWF
      mario_actions_submerged._common_idle_step.
  (* SLICE 7 (the metal-water FALLING pair): the two step helpers, each a
     genuine call_pres for any caller (neither touches the action cell).
     - stationary_slow_down writes m->angleVel/forwardVel/vel/faceAngle
       (window) from approach_f32/approach_s32 + the gSineTable trig;
     - perform_water_step writes m->vel (window) + chases marioObj's SafeB
       gfx pos/angle pool via vec3f_copy/vec3s_set.
     The faceAngle nudge reads gSineTable (a global LOAD, no store), so the
     pair needs NO external/global row -- set_mario_animation is the already-
     walked sub_sma_row, the action select is the set_mario_action/dasma sids. *)
  (* stationary_slow_down needs NO hypothesis: DISCHARGED inside
     SubmergedLeafSurface (sub_ssd_row) -- window stores; ids=[get_buoyancy]
     (sub_gb_row -> sns_cp), xids=[approach_f32, approach_s32] (obj_ext). *)
  (* perform_water_step is now WALKED end-to-end (PerformWaterStepSurface.pws_cp,
     the water twin of perform_air_step): its m->vel window store + the
     nextPos[i] local stores + the two gated out-param calls all preserve the
     carried facts.  perform_water_full_step (pwfs) is ITSELF walked there
     (pwfs_cp), resting only on the SAME resolve / find_floor / vec3f_find_ceil /
     vec3f_copy-window / vec3f_set-window externals the paqs walk already
     carries; vec3f_copy/vec3s_set in perform_water_step ride the obj_ext
     boundary (marioObj SafeB chase pool).  apply_water_current (apw) -- pws's
     sole internal sub-callee -- is ALSO now WALKED (PerformWaterStepSurface.
     apw_cp, a loop-tolerant walk of the whirlpool body): every store is step[i]
     through the _step float* PARAM (a LOCAL under the paqs gate, so Hls_real
     closes it), and the only calls are sqrtf / atan2s (obj_ext); NO m-store.
     So the WHOLE perform_water_step subtree is discharged with NO residual
     beyond the standard mwf_real + obj_ext rows -- the Lemma Hcp_pws_real below
     consumes apw_cp inline (no Hcp_apw hypothesis). *)
  (* SLICE 9 (act_drowning): play_sound_if_no_flag is the flag-gated sound
     helper (m->flags window + a sound, never the action cell) -- the SAME
     genuine-call_pres class the airborne/stationary surfaces' Hpsinf uses.
     Honest residual (body walk = play_sound obj_ext + the flag store).  The
     drowning leaf reuses the slice-7 step residuals + sub_sma_row/sub_iae_row
     + the SHARED level_trigger_warp, plus a 3-temp cact (marioBodyState
     eyeState writes + marioObj animFrame read). *)
  (* play_sound_if_no_flag needs NO hypothesis: DISCHARGED inside
     SubmergedLeafSurface (sub_psinf_row) -- window store m->flags + lone call
     play_sound (obj_ext). *)
  (* SLICE 11 (knockback pair): common_water_knockback_step is action-
     preserving WHEN its endAction param (the THIRD vargs element) is
     untainted -- exactly call_pres_act3.  DISCHARGED inside
     SubmergedLeafSurface (sub_cwks_row) via call_pres_act3_of_wwalk_p4: the
     ternary action arg `health>=0x100 ? endAction : ACT_WATER_DEATH` lowers
     to an I32 cast of the untainted endAction param / const into the action
     temp (wsrc_chk's act-temp cast arm); callees are the ssd/sma/iae rows +
     perform_water_step (Hcp_pws) + set_mario_action (keystone).  NO hyp. *)
  (* SLICE 12 (cancel gate): transition_submerged_to_walking needs NO
     hypothesis -- DISCHARGED in-surface (sub_tstw_row, the ws hybrid walker):
     its body is the wwalk engine generic arm plus the lone vec3s_set(m->
     angleVel,0,0,0) special site (angleVel @50; a 6-byte write strictly INSIDE
     a 12-byte-safe bm-window, action cell @12 clear -- store_window_ok 50 12 =
     true), which rides the SHARED Hw1cp_v3sset_real boundary below;
     set_camera_mode is obj_ext, set_mario_action is the keystone.
     stop_shell_music (the nullary audio external) is discharged zero-trust via
     Hpres_obj_ext below.
     The angleVel-window terminal external, SHARED by both submerged helpers
     (transition_submerged_to_walking + check_water_jump) that call
     vec3s_set(m->angleVel): vec3s_set is EF_external in EVERY generated TU (no
     internal body anywhere) -- the same honest terminal external-call-model
     boundary as vec3f_set's m->vel window (Hw1cp_v3fset_real), same w1 gate,
     here for the 6-byte angleVel write. *)
  Hypothesis Hw1cp_v3sset_real :
    call_pres_ext_w1 lp bm (NoA_real bm) MWF
      mario._vec3s_set.
  (* SLICE 13 (throw/punch pair): the four swimming helpers + the throw/grab
     helpers are honest INTERNAL residuals (all internal in their TUs),
     dischargeable by walking their bodies later.  The three terminal
     externals (approach_s32 / segmented_to_virtual / play_shell_music) are
     obj_ext, discharged zero-trust via Hpres_obj_ext below. *)
  (* update_swimming_yaw + update_swimming_pitch need NO hypothesis: both are
     DISCHARGED inside SubmergedLeafSurface (sub_usy_row / sub_usp_row via
     call_pres_of_wwalk) -- pure window stores into Mario's own faceAngle/
     angleVel, the lone approach_s32 call (yaw) rides the obj_ext boundary. *)
  (* update_swimming_speed needs NO hypothesis: DISCHARGED inside
     SubmergedLeafSurface (sub_uss_row) -- window stores + get_buoyancy
     (sub_gb_row, whose sole call swimming_near_surface is sns_cp). *)
  (* update_water_pitch needs NO hypothesis: DISCHARGED inside
     SubmergedLeafSurface (sub_uwp_row) -- chase stores through m->marioObj
     (chase root), no calls (sins = gSineTable load). *)
  (* mario_throw_held_object needs NO hypothesis -- DISCHARGED in-surface
     (SubmergedLeafSurface.sub_mtho_row, reusing the already-proved
     ObjectLeafSurface.mtho_row; the SAME interaction.prog body the object/
     stationary/airborne families walk).  Its 3 terminal externals ride the
     obj_ext boundary -- NO new trust. *)
  (* check_water_grab (cwg) is now DISCHARGED in-surface (SubmergedLeafSurface.
     sub_cwg_row): a getter->root-store leaf whose body is fully walked.  Its
     ONE internal dependency -- call_pres_mgco for mario_get_collided_object
     (the SafeB pointer-return brick) -- is fed the already-proved Hcp_mgco_real
     below, so this leaf adds NO new hypothesis. *)
  (* SLICE 14 (the swimming cluster -- 7 leaves): the swim helpers are honest
     INTERNAL residuals (check_water_jump / play_swimming_noise /
     reset_bob_variables / common_swimming_step in mario_actions_submerged.prog,
     set_anim_to_frame in mario.prog), each dischargeable by walking its body
     later; NONE writes the action cell.  set_mario_action /
     drop_and_set_mario_action (the action cancels) reuse the keystone +
     dasma_row; play_sound / stop_shell_music reuse the obj_ext boundary.
     approach_f32 is the ONE new terminal external (the pure-math float
     approach builtin -- EF_external in every TU, the honest model boundary). *)
  (* check_water_jump needs NO hypothesis -- DISCHARGED in-surface
     (sub_cwj_row, the SAME ws hybrid walker as tstw): the A-gated body is the
     wwalk engine generic arm plus vec3s_set(m->angleVel,0,0,0) (rides the
     SHARED Hw1cp_v3sset_real boundary above) + m->vel[1]=62 (window store) +
     set_mario_action (keystone).  NO new trust beyond the shared angleVel
     window external. *)
  (* set_anim_to_frame needs NO hypothesis: DISCHARGED inside
     SubmergedLeafSurface (sub_satf_row) -- a bespoke walk of its body
     (fn_vars=nil, no calls).  It chases m->marioObj to a SafeB block, forms
     &animInfo (same block), and the 4 scalar stores all go THROUGH that chased
     animInfo pointer, never the action cell. *)
  (* play_swimming_noise needs NO hypothesis: DISCHARGED inside
     SubmergedLeafSurface (sub_psn_row) -- no stores, lone call play_sound
     (obj_ext). *)
  (* reset_bob_variables needs NO hypothesis: DISCHARGED inside
     SubmergedLeafSurface (sub_rbv_row) -- three direct static-global stores
     (sBobTimer/sBobIncrement/sBobHeight, all now in CensusV2.stored_globals). *)
  (* common_swimming_step needs NO hypothesis: now WALKED inside
     SubmergedLeafSurface (sub_css_row) -- window faceAngle stores + a
     marioBodyState->headAngle chase store + the discharged swim helper rows +
     find_floor_slope.  Its slice-14 slot is now fed Hcp_ffs_real (find_floor_
     slope, walked above), the SOLE deep callee that was not already a leaf row /
     obj_ext.  NET: -1 residual (Hcp_css_real eliminated), zero new trust. *)
  (* SLICE 14's approach_f32 needs NO hypothesis: mario_actions_submerged.
     _approach_f32 is the SAME string-shared positive as mario_actions_airborne.
     _approach_f32, so the airborne Hcpx_approach_f32_real (above) covers it. *)
  (* SLICE 15 (the last two submerged leaves -- act_water_plunge +
     act_caught_in_whirlpool, both straight-line switch bodies): swimming_near_
     surface is a PURE read-only body (a m->pos/waterLevel read returning a
     flag), so it is DISCHARGED OUTRIGHT inside SubmergedLeafSurface (sns_cp via
     the pure_walk tool) -- NO hypothesis here.  This CLOSES the submerged leaf
     census -- every one of the 33 ids is now positively WALKED, so
     Hpres_sub_rest is ELIMINATED (the family discharge uses
     submerged_leaf_callees_pres_full, whose vacuous rest premise is proved
     inline).  whirlpool's sqrtf/atan2s/vec3f_copy/vec3s_set are obj_ext (NO new
     trust); level_trigger_warp reuses the SHARED Hcp_ltw. *)
  (* the cutscene dispatcher is WALKED (CutsceneSurface.cutscene_pres
     over the generic DispatchKit): its whole-body residual is PROVED
     from per-leaf-callee residuals keyed by the 51-id census
     cutscene_callee_ids (the prologue helper + the 50 act handlers;
     the particleFlags epilogue store is killed by the window census).
     Discharge proceeds id by id. *)
  (* SLICE 1 of the cutscene leaf family is now WALKED (CutsceneLeafSurface.
     cutscene_leaf_callees_pres): the death-cluster prologue helper
     common_death_handler (set_mario_animation + level_trigger_warp + the
     m->marioBodyState->eyeState chase store + stop_and_set_height_to_floor)
     and the two cleanest death leaves act_electrocution / act_suffocation
     (play_sound_if_no_flag + common_death_handler + return 0).  The remaining
     49 leaves stay under this shrunk residual over cut_rest_ids. *)
  Hypothesis Hpres_cut_rest : forall fid f,
      mem_id fid CutsceneLeafSurface.cut_rest_ids = true ->
      (prog_defmap mario_actions_cutscene.prog) ! fid
        = Some (Gfun (Internal f)) ->
      body_pres lp (NoA_real bm) MWF bm f.
  (* the automatic dispatcher is WALKED (AutomaticSurface.automatic_pres
     over the generic DispatchKit; the quicksandDepth store is killed by
     the window census): PROVED from per-leaf-callee residuals keyed by
     the 17-id census automatic_callee_ids.  ALL 17 leaves are now WALKED
     (AutomaticLeafSurface.automatic_leaf_callees_pres with NO rest
     residual -- B14 walked act_in_cannon via the hybrid cnn walker
     CONSUMING the engine-v2 cannon-fire kill: under MWF's input_a_clear
     projection the gated cannon fire is dead code).  The discharged tree
     surfaces only the named external/gated rows below (its one NEW row is
     vec3f_set, the w1 dst-window terminal external, Hw1cp_v3fset_real). *)
  (* the object dispatcher is WALKED (ObjectSurface.object_pres) and its
     leaf census is FULLY DISCHARGED (ObjectLeafSurface.object_callees_pres
     with NO residual premise: ccoc + the six B3 leaves + the three B5
     grab leaves + the B6 punching subtree -- mups / mario_check_object_grab
     / play_mario_action_sound / play_sound_and_spawn_particles /
     check_common_action_exits / is_anim_past_end / mario_obj_angle_to_object
     -- all walked).  The discharged trees surface only the object-family
     EXTERNAL rows (obj_ext_ids, the warp_ext_ids model class) and the
     named internal Hcp_pgs blocker below. *)
  Hypothesis Hpres_obj_ext : forall fid,
      mem_id fid obj_ext_ids = true ->
      call_pres_ext lp bm (NoA_real bm) MWF fid.
  (* perform_ground_step is now WALKED (MarioStepSurface.pgs_cp, the
     loop-tolerant fn_var walk): the opaque whole-body residual is
     DECOMPOSED into two deeper internal rows (+ the vec3f_copy/vec3s_set
     obj_ext rows already carried above).  The Lemma Hcp_pgs below (after
     aut_local_store) instantiates the walk at MWF_real.
       - perform_ground_quarter_step(m, intendedPos): intendedPos is
         pgs's OWN stack array, so the honest gate is the marg-AND-local
         mo class (a plain marg call_pres would be PHANTOM-FALSE: an
         unconstrained intendedPos could alias bm's action cell).
       - mario_get_terrain_sound_addend(m): plain marg internal row
         (Internal in mario.prog; EF_external in mario_step.prog). *)
  (* perform_ground_quarter_step is now WALKED (MarioStepSurface.pgqs_cp,
     Lemma Hcp_pgqs_real below).  Its one genuinely NEW residual is
     find_water_level(x, z): a pure float terrain query, EF_external in
     EVERY generated TU (mario.v:12252, mario_step.v:5662, shadow.v,
     behavior_actions.v) -- the same honest terminal-external
     model-boundary class as atan2s. *)
  Hypothesis Hxcp_fwl_real :
    call_pres_ext lp bm (NoA_real bm) MWF mario_step._find_water_level.
  (* mario_get_terrain_sound_addend, WALKED (MarioStepSurface.mgtsa_cp):
     EF_external in mario_step.prog but INTERNAL in mario.prog; its body
     is MEMORY-PURE (no stores, no calls -- chase loads + one Sswitch),
     so the generic pure_walk memory-identity lemma discharges it with
     NOTHING assumed in its place. *)
  Lemma Hcp_mgtsa_real :
    call_pres lp bm (NoA_real bm) MWF
      mario_step._mario_get_terrain_sound_addend.
  Proof.
    exact (mgtsa_cp lp LO_mario bm (NoA_real bm)
             (MWF_real lp bm bc oc0 SafeB)
             (mwf_real_ctl lp bm bc oc0 SafeB)).
  Qed.
  (* set_pole_position (B10 pole-cluster scaffold): the 730-line shared pole
     helper is NO LONGER an opaque residual -- it is now PROVED by walking the
     whole body (AutomaticLeafSurface.Hcp_spp via call_pres_of_lwalk3), resting
     instead on the four gated leaf-external residuals above (Hocp_find_ceil /
     Hwcp_fwc / Hscp_v3f / Hscp_v3s) + the already-present Hocp_find_floor and
     the set_mario_action keystone.  The six pole act handlers reduce to it. *)
  (* B11 top-of-pole pair: return_mario_anim_y_translation is the SOLE shared
     helper for act_top_of_pole + act_top_of_pole_transition, both now WALKED
     (AutomaticLeafSurface, automatic_rest_ids 6 -> 4).  Its OWN body is now
     WALKED too (AutomaticLeafSurface.Hrmayt): one chase-root marioObj load +
     the out-param Scall + a read/return.  That walk REDUCES it to the gated
     preservation of its SOLE out-param helper, the INTERNAL multi-pointer
     writer find_mario_anim_flags_and_translation (writes its 1st arg
     obj->animInfo via geo_update + the caller's stack-local out-param).  The
     residual was the oc2-GATED (arg0 cond-safe /\ last-arg local)
     call_pres_ext_oc2.  That internal body is now ITSELF WALKED
     (AutomaticLeafSurface.famft_body_pres_oc2 + Lemma Hoc2_famft): its only
     memory writers are the obj->animInfo write by geo_update_animation_frame
     (arg0 in obj's SafeB block) and the *(translation+i) out-param writes fed
     by retrieve_animation_index (&animIndex, the fn's own stack local) plus two
     write-free segmented_to_virtual calls.  So the single oc2 residual
     DECOMPOSES into two strictly DEEPER, true-in-model terminal EXTERNAL
     residuals one call-graph level down (segmented_to_virtual is already wired
     via Hpres_obj_ext _segmented_to_virtual):
       - geo_update_animation_frame: writes through its arg0 &obj->..animInfo
         (obj is the cond-safe arg0)  -> call_pres_ext_sc (arg0_safe);
       - retrieve_animation_index: writes through its last arg &animIndex (a
         local stack block)            -> call_pres_ext_oc (last_arg_local).
     decompose, not collapse. *)
  Hypothesis Hscp_geo_real :
    call_pres_ext_sc lp bm (NoA_real bm) MWF SafeB
      mario._geo_update_animation_frame.
  Hypothesis Hocp_rai_real :
    call_pres_ext_oc lp bm (NoA_real bm) MWF SafeB
      mario._retrieve_animation_index.
  (* B11 act_hang_moving: update_hang_moving is the SOLE shared helper gating the
     act_hang_moving leaf.  Its WHOLE BODY is now WALKED (AutomaticLeafSurface.
     uhm_body_pres / Huhm) -- the forwardVel/slideYaw/slideVel* direct Mario-field
     stores, faceAngle[1]/vel[0..2] indexed stores, and the _nextPos[0..2] local
     stores are all discharged in-body.  The old opaque whole-helper residual
     Huhm_real is therefore DECOMPOSED (not collapsed) into update_hang_moving's
     two honest leaf callees one call-graph level down:
       - approach_s32 : a pure-math integer-clamp EF_external (no Mem write)
                        -> call_pres_ext (Hcpx_approach_real);
       - perform_hanging_step : the internal hang-physics helper, called as
         perform_hanging_step(m, nextPos) with arg0 = Mario (bm,0) AND the last
         arg = the caller's _nextPos stack local; its body directly stores
         nextPos[1], so a marg-only call_pres is phantom-FALSE -- the honest
         residual is the marg-AND-local gate call_pres_mo (Hcp_php_real). *)
  Hypothesis Hcpx_approach_real :
    call_pres_ext lp bm (NoA_real bm) MWF
      mario_actions_automatic._approach_s32.
  (* perform_hanging_step is now WALKED, not assumed: its whole body is
     proved to preserve under the marg-AND-local gate
     (AutomaticLeafSurface.Hcp_php via call_pres_mo_of_body).  The old opaque
     whole-helper residual Hcp_php_real is therefore DECOMPOSED (not collapsed)
     into the body's two honest gated-external leaf callees one call-graph
     level down -- each a RESOLUTION-AWARE call_pres_ext_* over the body that
     fid resolves to IN lp (so dischargeable later by walking that body):
       - resolve_and_return_wall_collisions(nextPos, 1.0f, 1.0f): writes
         through its FIRST arg = the caller's _nextPos stack local, so the
         honest gate is args_all_local (call_pres_ext_ol).  Its INTERNAL
         mario.prog body is now ITSELF WALKED (AutomaticLeafSurface.
         Hocp_resolve via rwc_walk_pres + call_pres_ext_ol_of_body): all its
         stores hit the stack-local _collisionData struct or go through the
         gate-local _pos param ptr.  The old internal residual
         Hocp_resolve_real is therefore replaced by the body's SOLE callee,
         find_wall_collisions(&collisionData) -- a genuine EF_external in
         EVERY TU (no internal body anywhere in generated/), called with its
         one pointer arg = &(stack-local struct), hence the same
         args_all_local gate.  This is the honest terminal external-call-model
         boundary, not a future walk.
       - vec3f_copy(&m->pos, nextPos): writes ONLY through its dst = &m->pos,
         a 12-byte safe bm-window (action cell @12 clear), src = nextPos local,
         so the honest gate is arg0_window (call_pres_ext_w1). *)
  Hypothesis Holcp_fwc_real :
    call_pres_ext_ol lp bm (NoA_real bm) MWF SafeB
      mario._find_wall_collisions.
  Hypothesis Hw1cp_v3f_real :
    call_pres_ext_w1 lp bm (NoA_real bm) MWF
      mario_actions_automatic._vec3f_copy.
  (* vec3f_copy(_startPos, m->pos) in act_walking: dst = arg0 = the caller's
     _startPos stack-local array, src = arg1 = m->pos (a safe bm-window, action
     cell @12 clear).  vec3f_copy writes ONLY through its dst (arg0); here the
     dst is a LOCAL, not a window, so the honest gate is the UNION gate (wol:
     every ptr arg window-or-local) -- STRICTLY MORE PERMISSIVE than the w1
     gate Hw1cp_v3f_real above (which only covers a window dst).  Same
     EF_external-in-every-TU terminal-external boundary as vec3f_copy / vec3f_set
     above; one extra honest row for the local-dst call shape. *)
  Hypothesis Hwolcp_v3f_real :
    call_pres_ext_wol lp bm (NoA_real bm) MWF SafeB
      mario_actions_automatic._vec3f_copy.
  (* vec3f_set(m->vel, 0, 0, 0) -- act_in_cannon's one special store site:
     writes ONLY through its dst = &m->vel, a 12-byte safe bm-window
     (vel @72; action cell @12 clear).  vec3f_set is EF_external in EVERY
     generated TU (no internal body anywhere) -- the same honest terminal
     external-call-model boundary as vec3f_copy above, same w1 gate. *)
  Hypothesis Hw1cp_v3fset_real :
    call_pres_ext_w1 lp bm (NoA_real bm) MWF
      mario_actions_automatic._vec3f_set.
  (* SLICE A29: vec3f_set called with dst = marioObj->header.gfx.pos -- a SafeB
     object-pool CHASE dst -- in act_riding_hoot.  vec3f_set is EF_external in
     EVERY generated TU; the SAME honest terminal external-call-model boundary
     as Hscp_v3f (vec3f_copy) / Hscp_v3s (vec3s_set), gated on its pointer arg
     landing in the SafeB chase pool (the sc class).  Distinct from
     Hw1cp_v3fset_real above (the w1/window class for the m->vel dst). *)
  Hypothesis Hscp_v3fset_real :
    call_pres_ext_sc lp bm (NoA_real bm) MWF SafeB
      mario_actions_automatic._vec3f_set.
  (* act_tornado_twirling is now WALKED (AutomaticLeafSurface's hybrid twl
     walker: the generic wwalk census + bespoke discharges for its two
     special call sites).  Its vec3f_copy(m->pos, nextPos) site rides the
     EXISTING Hw1cp_v3f_real row above; the one NEW residual is
     f32_find_wall_collision called with ALL out-ptrs aimed at the
     stack-local _nextPos elems -- the args_all_local (ol) gate, the same
     honest terminal-external class as find_wall_collisions above
     (f32_find_wall_collision is EF_external in EVERY generated TU:
     mario.v:12228, interaction.v:12264, mario_actions_automatic.v:8857).
     That ol-gated row is now DERIVED from the single union-gated
     Hwolcp_fwc above (call_pres_ext_ol_of_wol) -- one fwc row total. *)
  (* the special-floors LEAF CENSUS is FULLY DISCHARGED
     (FloorsLeafSurface.floors_callees_pres): check_death_barrier /
     pss_begin_slide / pss_end_slide / check_lava_boost are all WALKED,
     their callee trees bottoming out in the act-writer keystone, the
     walked update_mario_sound_and_camera / level_control_timer /
     level_trigger_warp bodies (the latter SHARED with the warp surface
     below), and the shared obj_ext rows.  What remains is the marg-free
     call_pres_ext row for the TWO floors-only external leaves
     (raise_background_noise / spawn_default_star) -- the same model
     class as warp_ext_ids. *)
  Hypothesis Hpres_floors_ext : forall fid,
      mem_id fid floors_ext_ids = true ->
      call_pres_ext lp bm (NoA_real bm) MWF fid.
  (* mario_update_quicksand, WALKED (FloorsLeafSurface.qsand_pres: umsc
     + the act-writer pair + m-> field stores), consuming only ext rows
     already on the surface: NO residual of its own. *)
  Let Hpres_qsand : body_pres lp (NoA_real bm) MWF bm
      mario_step.f_mario_update_quicksand :=
    qsand_pres lp LO_mario LO_stp LO_int bm (NoA_real bm) MWF
      (mwf_real_ctl lp bm bc oc0 SafeB)
      (mwf_real_window lp bm bc oc0 SafeB Hbc_bm HSafeB_not_bm
         Hgms_blk Hgtimer_blk Htable_blk Hktab_blk)
      (mwf_real_glob lp bm bc oc0 SafeB Hbc_bm Hglob_blk)
      (mwf_real_act_store lp bm bc oc0 SafeB Hbc_bm HSafeB_not_bm
         Hgms_blk Hgtimer_blk Htable_blk Hktab_blk)
      SafeB HSafeB_not_bm
      (mwf_real_chase_root lp bm bc oc0 SafeB)
      (mwf_real_chase lp bm bc oc0 SafeB Hbc_bm HSafeB_not_bm
         HSafeB_not_bc Hgms_blk Hgtimer_blk Htable_blk Hktab_blk)
      (mwf_real_root_store lp bm bc oc0 SafeB Hbc_bm HSafeB_not_bm
         Hgms_blk Hgtimer_blk Htable_blk Hktab_blk)
      (mwf_real_sglob lp bm bc oc0 SafeB)
      (mwf_real_chase_step lp bm bc oc0 SafeB)
      (mwf_real_chase_ptr lp bm bc oc0 SafeB Hbc_bm HSafeB_not_bm
         HSafeB_not_bc Hgms_blk Hgtimer_blk Htable_blk Hktab_blk)
      (Hpres_obj_ext mario._set_camera_mode eq_refl)
      (Hpres_obj_ext interaction._segmented_to_virtual eq_refl)
      (Hpres_obj_ext interaction._stop_shell_music eq_refl)
      (Hpres_obj_ext interaction._obj_set_held_state eq_refl)
      (Hpres_floors_ext mario._raise_background_noise eq_refl).
  (* the interactions dispatcher is WALKED (InterSurface.inter_pres -- the
     FIRST indirect-call walk: the sInteractionHandlers function-pointer
     loop, every handler-slot load pinned by the offset-free MWF table row
     consumed via mwf_real_itab): the old whole-body Hpres_inter residual
     is PROVED from the 29 census-keyed interact_* handler bodies (the
     GATED class body_pres_io: explicit m/interactType/object args -- a
     plain body_pres would be a phantom forall-object) + the two named
     interaction.prog helpers:
       - mario_get_collided_object: marg-gated + SafeB-if-ptr RETURN (its
         result seeds the _object chase temp) -- WALKED, PROVED below
         (InterSurface.mgco_cp: read-only body, the return chases
         marioObj->collidedObjs[i] through the root+step SafeB rows);
       - check_kick_or_punch_wall: the ordinary call_pres class,
         Internal in interaction.prog (walkable later). *)
  (* the out-param arc's local-store MWF brick, GROUNDED at MWF_real:
     a store into a watched-disjoint stack block (local_blk) preserves
     MWF_real.  The b<>bc obligation of mwf_real_local_store is discharged
     from local_blk's global clause + Hbc_sym (bc is the gControllers
     global).  This is the `Hls_real` the ledge cluster consumes. *)
  Lemma aut_local_store :
    forall m ch b (d : Z) v m',
      local_blk lp bm SafeB b ->
      Mem.store ch m b d v = Some m' -> MWF m -> MWF m'.
  Proof.
    intros m ch b d v m' Hlb Hst HM.
    destruct Hlb as (Hbm & HnS & Hglob).
    destruct Hbc_sym as (gidc & Hfindc).
    pose proof (Hglob _ _ Hfindc) as Hbc.
    eapply mwf_real_local_store; eauto.
  Qed.

  (* push_mario_out_of_object, WALKED (InterSurface.pmoo_cp): chase loads
     through the object param (memory-pure), local scalar stores
     (newMarioX/newMarioZ), m->pos[i] safe-window stores, find_floor
     (&_floor, the oc gate), sqrtf/atan2s (obj_ext), and the MIXED
     f32_find_wall_collision(&newMarioX, &m->pos[1], &newMarioZ, c, c)
     riding the NEW union-gated Hwolcp_fwc row.  The object param is only
     ever LOADED through, so plain marg call_pres is the honest class.
     NOTHING new assumed beyond the wol row above. *)
  Lemma Hcp_pmoo_real :
    call_pres lp bm (NoA_real bm) MWF
      interaction._push_mario_out_of_object.
  Proof.
    exact (pmoo_cp lp LO_mario LO_int bm (NoA_real bm)
             (MWF_real lp bm bc oc0 SafeB) SafeB
             (mwf_real_ctl lp bm bc oc0 SafeB)
             (mwf_real_window lp bm bc oc0 SafeB Hbc_bm HSafeB_not_bm
                Hgms_blk Hgtimer_blk Htable_blk Hktab_blk)
             (mwf_real_alloc lp bm bc oc0 SafeB Hbc_bm)
             (fun m l m' Hf HM =>
                mwf_real_free lp bm bc oc0 SafeB Hbc_bm m m' l Hf HM)
             (mwf_real_safe_valid lp bm bc oc0 SafeB)
             Hglob_valid
             aut_local_store
             Hocp_find_floor
             Hwolcp_fwc
             (Hpres_obj_ext interaction._sqrtf eq_refl)
             (Hpres_obj_ext interaction._atan2s eq_refl)).
  Qed.

  (* perform_water_step WALKED (PerformWaterStepSurface.pws_cp, the water twin
     of pas/pmoo above): discharges the old whole-function Hcp_pws_real residual,
     resting on the SAME mwf_real rows + the resolve (itself WALKED, via
     AutomaticLeafSurface.Hocp_resolve) / find_floor / vec3f_find_ceil oc rows +
     the vec3f_copy / vec3f_set w1-window rows the pwfs walk needs + the obj_ext
     vec3f_copy / vec3s_set boundary + apw_cp (apply_water_current, ALSO walked
     -- a loop-tolerant whirlpool-body walk resting only on Hls_real + obj_ext
     sqrtf / atan2s).  The WHOLE perform_water_step subtree is thus discharged
     with NO residual beyond the standard mwf_real + obj_ext boundary rows. *)
  Lemma Hcp_pws_real :
    call_pres lp bm (NoA_real bm) MWF
      mario_actions_submerged._perform_water_step.
  Proof.
    exact (PerformWaterStepSurface.pws_cp lp LO_mario LO_sub bm (NoA_real bm)
             (MWF_real lp bm bc oc0 SafeB) SafeB
             (mwf_real_ctl lp bm bc oc0 SafeB)
             (mwf_real_window lp bm bc oc0 SafeB Hbc_bm HSafeB_not_bm
                Hgms_blk Hgtimer_blk Htable_blk Hktab_blk)
             (mwf_real_alloc lp bm bc oc0 SafeB Hbc_bm)
             (fun m l m' Hf HM =>
                mwf_real_free lp bm bc oc0 SafeB Hbc_bm m m' l Hf HM)
             (mwf_real_safe_valid lp bm bc oc0 SafeB)
             Hglob_valid
             aut_local_store
             (AutomaticLeafSurface.Hocp_resolve lp LO_mario bm (NoA_real bm)
                (MWF_real lp bm bc oc0 SafeB)
                (mwf_real_ctl lp bm bc oc0 SafeB)
                SafeB
                (mwf_real_alloc lp bm bc oc0 SafeB Hbc_bm)
                (fun m l m' Hf HM =>
                   mwf_real_free lp bm bc oc0 SafeB Hbc_bm m m' l Hf HM)
                (mwf_real_safe_valid lp bm bc oc0 SafeB)
                Hglob_valid
                aut_local_store
                Holcp_fwc_real)
             Hocp_find_floor
             Hocp_find_ceil
             Hw1cp_v3f_real
             Hw1cp_v3fset_real
             (PerformWaterStepSurface.apw_cp lp LO_sub bm (NoA_real bm)
                (MWF_real lp bm bc oc0 SafeB) SafeB
                (mwf_real_ctl lp bm bc oc0 SafeB)
                (mwf_real_alloc lp bm bc oc0 SafeB Hbc_bm)
                (fun m l m' Hf HM =>
                   mwf_real_free lp bm bc oc0 SafeB Hbc_bm m m' l Hf HM)
                aut_local_store
                (Hpres_obj_ext mario._sqrtf eq_refl)
                (Hpres_obj_ext interaction._atan2s eq_refl))
             (Hpres_obj_ext mario_step._vec3f_copy eq_refl)
             (Hpres_obj_ext mario._vec3s_set eq_refl)).
  Qed.

  (* find_floor_slope (mario.prog): the slope reader common_swimming_step calls
     in the WATER_STEP_HIT_FLOOR switch arm.  It is MEMORY-PURE w.r.t. bm/globals
     -- the only "write" is find_floor's out-param into the function's OWN
     stack-local _floor (lids=[_floor], oc gate), the rest are gSineTable/pos
     reads + atan2s slope math.  Walked via the lwalk2 oc-arc (the SAME
     MovingLeafSurface.mov_ffs_row pattern) resting ONLY on the EXISTING capstone
     rows Hocp_find_floor (find_floor's out-param oc gate) + atan2s (obj_ext).
     This Lemma is what fills the old Hcp_css_real slot -- NO new trust. *)
  Definition cap_ffs_lids : list ident := mario._floor :: nil.
  Definition cap_ffs_oc_pids : list ident := mario._find_floor :: nil.
  Definition cap_ffs_xids : list ident := mario._atan2s :: nil.
  Example cap_ffs_pin :
    (prog_defmap mario.prog) ! mario._find_floor_slope
    = Some (Gfun (Internal mario.f_find_floor_slope)).
  Proof. vm_compute. reflexivity. Qed.
  Example cap_ffs_pok :
    match fn_params mario.f_find_floor_slope with
    | (i, ty) :: ps =>
        Pos.eqb i mario_actions_airborne._m
        && proj_sumbool (type_eq ty tyMSp)
        && negb (mem_id mario_actions_airborne._m (map fst ps))
    | nil => false
    end = true.
  Proof. vm_compute. reflexivity. Qed.
  Example cap_ffs_walk :
    wwalk_chk' cap_ffs_lids cap_ffs_oc_pids nil nil nil nil
      false nil nil nil nil cap_ffs_xids nil nil
      (fn_body mario.f_find_floor_slope) = true.
  Proof. vm_compute. reflexivity. Qed.

  Lemma Hcp_ffs_real :
    call_pres lp bm (NoA_real bm) MWF mario._find_floor_slope.
  Proof.
    apply (call_pres_of_lwalk2 lp LO_mario bm (NoA_real bm)
             (MWF_real lp bm bc oc0 SafeB)
             (mwf_real_ctl lp bm bc oc0 SafeB)
             (mwf_real_window lp bm bc oc0 SafeB Hbc_bm HSafeB_not_bm
                Hgms_blk Hgtimer_blk Htable_blk Hktab_blk)
             (mwf_real_glob lp bm bc oc0 SafeB Hbc_bm Hglob_blk)
             (mwf_real_act_store lp bm bc oc0 SafeB Hbc_bm HSafeB_not_bm
                Hgms_blk Hgtimer_blk Htable_blk Hktab_blk)
             SafeB HSafeB_not_bm
             (mwf_real_chase_root lp bm bc oc0 SafeB)
             (mwf_real_chase lp bm bc oc0 SafeB Hbc_bm HSafeB_not_bm
                HSafeB_not_bc Hgms_blk Hgtimer_blk Htable_blk Hktab_blk)
             (mwf_real_root_store lp bm bc oc0 SafeB Hbc_bm HSafeB_not_bm
                Hgms_blk Hgtimer_blk Htable_blk Hktab_blk)
             (mwf_real_sglob lp bm bc oc0 SafeB)
             (mwf_real_chase_step lp bm bc oc0 SafeB)
             (mwf_real_chase_ptr lp bm bc oc0 SafeB Hbc_bm HSafeB_not_bm
                HSafeB_not_bc Hgms_blk Hgtimer_blk Htable_blk Hktab_blk)
             (mwf_real_alloc lp bm bc oc0 SafeB Hbc_bm)
             (fun m l m' Hf HM =>
                mwf_real_free lp bm bc oc0 SafeB Hbc_bm m m' l Hf HM)
             mario.prog mario._find_floor_slope mario.f_find_floor_slope
             nil nil cap_ffs_xids nil cap_ffs_lids cap_ffs_oc_pids nil nil
             LO_mario cap_ffs_pin cap_ffs_pok).
    - intros g Hg Hin; vm_compute in Hin;
        destruct Hin as [Heq | []]; subst g; vm_compute in Hg; discriminate.
    - intros g HH; discriminate HH.
    - intros g HH; discriminate HH.
    - intros g Hg Hin; vm_compute in Hin;
        destruct Hin as [Heq | []]; subst g; vm_compute in Hg; discriminate.
    - intros g HH; discriminate HH.
    - intros g Hg Hin; vm_compute in Hin;
        destruct Hin as [Heq | []]; subst g; vm_compute in Hg; discriminate.
    - intros g HH; discriminate HH.
    - intros g HH; discriminate HH.
    - vm_compute; intro Hin; destruct Hin as [Heq | []]; discriminate Heq.
    - intros lid Hl; unfold cap_ffs_lids in Hl; cbn [mem_id existsb] in Hl;
        apply orb_true_iff in Hl as [Hm | Hf];
        [ apply Pos.eqb_eq in Hm; subst lid; vm_compute; left; reflexivity
        | discriminate Hf ].
    - exact (mwf_real_safe_valid lp bm bc oc0 SafeB).
    - exact Hglob_valid.
    - exact aut_local_store.
    - intros fid' H; discriminate H.
    - intros fid' H; discriminate H.
    - intros fid' H; unfold cap_ffs_xids in H; cbn [mem_id existsb] in H;
        apply orb_true_iff in H as [Hm | H];
        [ apply Pos.eqb_eq in Hm; subst fid';
          exact (Hpres_obj_ext mario._atan2s eq_refl)
        | discriminate H ].
    - intros fid' H; discriminate H.
    - intros fid' H; unfold cap_ffs_oc_pids in H; cbn [mem_id existsb] in H;
        apply orb_true_iff in H as [Hm | H];
        [ apply Pos.eqb_eq in Hm; subst fid'; exact Hocp_find_floor
        | discriminate H ].
    - intros fid' H; discriminate H.
    - intros fid' H; discriminate H.
    - exact cap_ffs_walk.
  Qed.

  (* spawn_object: a TERMINAL EXTERNAL (EF_external in EVERY TU -- no
     internal body anywhere in generated/), the honest model boundary for
     the object-pool allocator.  It preserves the carried run facts, and
     its return value -- a slot of the static object pool -- is SafeB if
     a pointer at all (exactly what MWF_real's chase closure forces
     anyway: the spawned object is chase-reachable from the SafeB object
     lists).  Declared BEFORE the io block: star_or_key consumes it via
     the plain-ext weakening below. *)
  Hypothesis Hcp_spawn_real : call_pres_ext_sr lp bm (NoA_real bm) MWF SafeB
      behavior_actions._spawn_object.
  (* the plain-ext weakening (forget the SafeB-return claim; NoA from the
     MWF grounding) -- star_or_key's xids row, ZERO new trust. *)
  Lemma Hcpx_so_real :
    call_pres_ext lp bm (NoA_real bm) MWF interaction._spawn_object.
  Proof.
    intros fd m0 vargs0 t0 m1 vres0 Hevf Hres HN HM HV HS.
    destruct (Hcp_spawn_real fd m0 vargs0 t0 m1 vres0 Hevf Hres
                HN HM HV HS) as (HV' & HS' & HM' & _).
    exact (conj HV' (conj HS' (conj HM'
             (mwf_real_ctl lp bm bc oc0 SafeB m1 HM')))).
  Qed.

  (* save_file_set_cap_pos: an EF_external save-file boundary in EVERY
     generated TU (scalar f32 args, void return, no Mario pointer) -- the
     honest terminal external-call model class, like atan2s/sqrtf.  The ONLY
     new residual introduced by discharging Hcp_mboc_real: an internal-body
     assumption DECOMPOSED into this external boundary plus the already-
     standing spawn_object row. *)
  Hypothesis Hcp_savefile_real :
    call_pres_ext lp bm (NoA_real bm) MWF interaction._save_file_set_cap_pos.

  (* SLICE A22 DISCHARGED: mario_blow_off_cap WALKED (the spawn/wind arc).
     Its body's stores all land in SafeB object-pool blocks (the capObject
     chase) or Mario's window (m->flags, offset 4, action-disjoint); its
     callees are the pure reader does_mario_have_normal_cap_on_head (ZERO
     residual, pure_walk), spawn_object (Hcp_spawn_real, SafeB return), and
     save_file_set_cap_pos (Hcp_savefile_real).  The opaque internal-body
     residual is GONE, replaced by mboc_cp resting only on honest boundaries. *)
  Lemma Hcp_mboc_real :
    call_pres lp bm (NoA_real bm) MWF interaction._mario_blow_off_cap.
  Proof.
    exact (mboc_cp lp LO_int LO_mario bm (NoA_real bm) MWF SafeB
             (mwf_real_ctl lp bm bc oc0 SafeB)
             HSafeB_not_bm
             (mwf_real_chase lp bm bc oc0 SafeB Hbc_bm HSafeB_not_bm
                HSafeB_not_bc Hgms_blk Hgtimer_blk Htable_blk Hktab_blk)
             (* HMWF_flags: a Mint32 store at (bm,4) is window-disjoint *)
             (fun mm mm' vv HM Hst =>
                mwf_real_window lp bm bc oc0 SafeB Hbc_bm HSafeB_not_bm
                  Hgms_blk Hgtimer_blk Htable_blk Hktab_blk mm mm' Mint32 4 vv
                  HM eq_refl Hst)
             Hcp_spawn_real
             Hcp_savefile_real).
  Qed.

  (* interact_bully's action-computing leaf: bully_knock_back_mario, a
     call_pres_ret_act (its result is the untainted action fed to
     drop_and_set_mario_action).  The WHOLE interact_bully body is WALKED
     (InterSurface io arc) resting only on this one leaf -- the refinement
     that emptied io_rest_ids.  bkbm is now WALKED too (BullySurface.bkbm_row,
     a self-contained mid-walk keyed to interaction._mario since the param is
     `mario` not the canonical _m=86): the opaque whole-body assumption is
     GONE, replaced by the proved row resting only on the 2 static-helper
     externals init_bully_collision_data / transfer_bully_speed -- terminal
     boundary rows (EF_external in interaction.prog), the same accepted
     external-call model class as atan2s/sqrtf/spawn_object. *)
  Hypothesis Hcpx_ibcd_real :
    call_pres_ext lp bm (NoA_real bm) MWF
      interaction._init_bully_collision_data.
  Hypothesis Hcpx_tbs_real :
    call_pres_ext lp bm (NoA_real bm) MWF
      interaction._transfer_bully_speed.
  Lemma Hcpra_bkbm_real :
    call_pres_ret_act lp bm (NoA_real bm) MWF
      interaction._bully_knock_back_mario.
  Proof.
    exact (BullySurface.bkbm_row lp LO_mario LO_int bm (NoA_real bm) MWF SafeB
             (mwf_real_ctl lp bm bc oc0 SafeB)
             (mwf_real_window lp bm bc oc0 SafeB Hbc_bm HSafeB_not_bm
                Hgms_blk Hgtimer_blk Htable_blk Hktab_blk)
             HSafeB_not_bm
             (mwf_real_chase_root lp bm bc oc0 SafeB)
             (mwf_real_chase lp bm bc oc0 SafeB Hbc_bm HSafeB_not_bm
                HSafeB_not_bc Hgms_blk Hgtimer_blk Htable_blk Hktab_blk)
             (mwf_real_alloc lp bm bc oc0 SafeB Hbc_bm)
             (fun m l m' Hf HM =>
                mwf_real_free lp bm bc oc0 SafeB Hbc_bm m m' l Hf HM)
             Hcpx_ibcd_real Hcpx_tbs_real
             (Hpres_obj_ext interaction._atan2s eq_refl)
             (Hpres_obj_ext interaction._sqrtf eq_refl)).
  Qed.

  (* the io REST census row: the handlers not yet walked.  Every handler
     walk (InterSurface's io arc) removes its id from io_rest_ids and this
     row covers strictly less; io_rest_ids is now EMPTY (every interact_*
     handler walked) so this row is vacuous. *)
  Hypothesis Hio_rest : forall fid f,
      mem_id fid io_rest_ids = true ->
      (prog_defmap interaction.prog) ! fid = Some (Gfun (Internal f)) ->
      body_pres_io lp bm (NoA_real bm) MWF SafeB f.
  Lemma Hpres_ihandler : forall fid f,
      In fid interaction_handler_ids ->
      (prog_defmap interaction.prog) ! fid = Some (Gfun (Internal f)) ->
      body_pres_io lp bm (NoA_real bm) MWF SafeB f.
  Proof.
    exact (ihandler_pres_split lp LO_mario LO_int bm (NoA_real bm)
             (MWF_real lp bm bc oc0 SafeB) SafeB
             (mwf_real_ctl lp bm bc oc0 SafeB)
             (mwf_real_window lp bm bc oc0 SafeB Hbc_bm HSafeB_not_bm
                Hgms_blk Hgtimer_blk Htable_blk Hktab_blk)
             (mwf_real_glob lp bm bc oc0 SafeB Hbc_bm Hglob_blk)
             (mwf_real_act_store lp bm bc oc0 SafeB Hbc_bm HSafeB_not_bm
                Hgms_blk Hgtimer_blk Htable_blk Hktab_blk)
             HSafeB_not_bm
             (mwf_real_chase_root lp bm bc oc0 SafeB)
             (mwf_real_chase lp bm bc oc0 SafeB Hbc_bm HSafeB_not_bm
                HSafeB_not_bc Hgms_blk Hgtimer_blk Htable_blk Hktab_blk)
             (mwf_real_root_store lp bm bc oc0 SafeB Hbc_bm HSafeB_not_bm
                Hgms_blk Hgtimer_blk Htable_blk Hktab_blk)
             (mwf_real_sglob lp bm bc oc0 SafeB)
             (mwf_real_chase_step lp bm bc oc0 SafeB)
             (mwf_real_chase_ptr lp bm bc oc0 SafeB Hbc_bm HSafeB_not_bm
                HSafeB_not_bc Hgms_blk Hgtimer_blk Htable_blk Hktab_blk)
             Hcp_pmoo_real
             (mwf_real_ktab lp bm bc oc0 SafeB)
             (moato_row lp LO_mario LO_int bm (NoA_real bm)
                (MWF_real lp bm bc oc0 SafeB)
                (mwf_real_ctl lp bm bc oc0 SafeB)
                (mwf_real_window lp bm bc oc0 SafeB Hbc_bm HSafeB_not_bm
                   Hgms_blk Hgtimer_blk Htable_blk Hktab_blk)
                (mwf_real_glob lp bm bc oc0 SafeB Hbc_bm Hglob_blk)
                (mwf_real_act_store lp bm bc oc0 SafeB Hbc_bm HSafeB_not_bm
                   Hgms_blk Hgtimer_blk Htable_blk Hktab_blk)
                SafeB HSafeB_not_bm
                (mwf_real_chase_root lp bm bc oc0 SafeB)
                (mwf_real_chase lp bm bc oc0 SafeB Hbc_bm HSafeB_not_bm
                   HSafeB_not_bc Hgms_blk Hgtimer_blk Htable_blk Hktab_blk)
                (mwf_real_root_store lp bm bc oc0 SafeB Hbc_bm HSafeB_not_bm
                   Hgms_blk Hgtimer_blk Htable_blk Hktab_blk)
                (mwf_real_sglob lp bm bc oc0 SafeB)
                (mwf_real_chase_step lp bm bc oc0 SafeB)
                (mwf_real_chase_ptr lp bm bc oc0 SafeB Hbc_bm HSafeB_not_bm
                   HSafeB_not_bc Hgms_blk Hgtimer_blk Htable_blk Hktab_blk)
                (Hpres_obj_ext interaction._atan2s eq_refl))
             (msfv_row lp LO_mario bm (NoA_real bm)
                (MWF_real lp bm bc oc0 SafeB)
                (mwf_real_ctl lp bm bc oc0 SafeB)
                (mwf_real_window lp bm bc oc0 SafeB Hbc_bm HSafeB_not_bm
                   Hgms_blk Hgtimer_blk Htable_blk Hktab_blk)
                (mwf_real_glob lp bm bc oc0 SafeB Hbc_bm Hglob_blk)
                (mwf_real_act_store lp bm bc oc0 SafeB Hbc_bm HSafeB_not_bm
                   Hgms_blk Hgtimer_blk Htable_blk Hktab_blk)
                SafeB HSafeB_not_bm
                (mwf_real_chase_root lp bm bc oc0 SafeB)
                (mwf_real_chase lp bm bc oc0 SafeB Hbc_bm HSafeB_not_bm
                   HSafeB_not_bc Hgms_blk Hgtimer_blk Htable_blk Hktab_blk)
                (mwf_real_root_store lp bm bc oc0 SafeB Hbc_bm HSafeB_not_bm
                   Hgms_blk Hgtimer_blk Htable_blk Hktab_blk)
                (mwf_real_sglob lp bm bc oc0 SafeB)
                (mwf_real_chase_step lp bm bc oc0 SafeB)
                (mwf_real_chase_ptr lp bm bc oc0 SafeB Hbc_bm HSafeB_not_bm
                   HSafeB_not_bc Hgms_blk Hgtimer_blk Htable_blk Hktab_blk))
             (Hpres_obj_ext interaction._set_camera_shake_from_hit eq_refl)
             (call_pres_of_body lp bm (NoA_real bm)
                (MWF_real lp bm bc oc0 SafeB)
                (mwf_real_ctl lp bm bc oc0 SafeB)
                mario.prog mario._update_mario_sound_and_camera
                mario.f_update_mario_sound_and_camera LO_mario
                umsc_pin
                (umsc_pres lp LO_mario bm (NoA_real bm)
                   (MWF_real lp bm bc oc0 SafeB)
                   (mwf_real_ctl lp bm bc oc0 SafeB)
                   (mwf_real_window lp bm bc oc0 SafeB Hbc_bm HSafeB_not_bm
                      Hgms_blk Hgtimer_blk Htable_blk Hktab_blk)
                   (mwf_real_glob lp bm bc oc0 SafeB Hbc_bm Hglob_blk)
                   (mwf_real_act_store lp bm bc oc0 SafeB Hbc_bm HSafeB_not_bm
                      Hgms_blk Hgtimer_blk Htable_blk Hktab_blk)
                   SafeB HSafeB_not_bm
                   (mwf_real_chase_root lp bm bc oc0 SafeB)
                   (mwf_real_chase lp bm bc oc0 SafeB Hbc_bm HSafeB_not_bm
                      HSafeB_not_bc Hgms_blk Hgtimer_blk Htable_blk Hktab_blk)
                   (mwf_real_root_store lp bm bc oc0 SafeB Hbc_bm HSafeB_not_bm
                      Hgms_blk Hgtimer_blk Htable_blk Hktab_blk)
                   (mwf_real_sglob lp bm bc oc0 SafeB)
                   (mwf_real_chase_step lp bm bc oc0 SafeB)
                   (mwf_real_chase_ptr lp bm bc oc0 SafeB Hbc_bm HSafeB_not_bm
                      HSafeB_not_bc Hgms_blk Hgtimer_blk Htable_blk Hktab_blk)
                   (Hpres_obj_ext mario._set_camera_mode eq_refl)
                   (Hpres_floors_ext mario._raise_background_noise eq_refl)))
             (Hpres_obj_ext interaction._play_sound eq_refl)
             (dasma_row lp LO_mario LO_stp LO_int bm (NoA_real bm)
                (MWF_real lp bm bc oc0 SafeB)
                (mwf_real_ctl lp bm bc oc0 SafeB)
                (mwf_real_window lp bm bc oc0 SafeB Hbc_bm HSafeB_not_bm
                   Hgms_blk Hgtimer_blk Htable_blk Hktab_blk)
                (mwf_real_glob lp bm bc oc0 SafeB Hbc_bm Hglob_blk)
                (mwf_real_act_store lp bm bc oc0 SafeB Hbc_bm HSafeB_not_bm
                   Hgms_blk Hgtimer_blk Htable_blk Hktab_blk)
                SafeB HSafeB_not_bm
                (mwf_real_chase_root lp bm bc oc0 SafeB)
                (mwf_real_chase lp bm bc oc0 SafeB Hbc_bm HSafeB_not_bm
                   HSafeB_not_bc Hgms_blk Hgtimer_blk Htable_blk Hktab_blk)
                (mwf_real_root_store lp bm bc oc0 SafeB Hbc_bm HSafeB_not_bm
                   Hgms_blk Hgtimer_blk Htable_blk Hktab_blk)
                (mwf_real_sglob lp bm bc oc0 SafeB)
                (mwf_real_chase_step lp bm bc oc0 SafeB)
                (mwf_real_chase_ptr lp bm bc oc0 SafeB Hbc_bm HSafeB_not_bm
                   HSafeB_not_bc Hgms_blk Hgtimer_blk Htable_blk Hktab_blk)
                (Hpres_obj_ext interaction._segmented_to_virtual eq_refl)
                (Hpres_obj_ext interaction._stop_shell_music eq_refl)
                (Hpres_obj_ext interaction._obj_set_held_state eq_refl))
             Hcpra_bkbm_real
             (msrah_row lp LO_mario LO_int bm (NoA_real bm)
                (MWF_real lp bm bc oc0 SafeB)
                (mwf_real_ctl lp bm bc oc0 SafeB)
                (mwf_real_window lp bm bc oc0 SafeB Hbc_bm HSafeB_not_bm
                   Hgms_blk Hgtimer_blk Htable_blk Hktab_blk)
                (mwf_real_glob lp bm bc oc0 SafeB Hbc_bm Hglob_blk)
                (mwf_real_act_store lp bm bc oc0 SafeB Hbc_bm HSafeB_not_bm
                   Hgms_blk Hgtimer_blk Htable_blk Hktab_blk)
                SafeB HSafeB_not_bm
                (mwf_real_chase_root lp bm bc oc0 SafeB)
                (mwf_real_chase lp bm bc oc0 SafeB Hbc_bm HSafeB_not_bm
                   HSafeB_not_bc Hgms_blk Hgtimer_blk Htable_blk Hktab_blk)
                (mwf_real_root_store lp bm bc oc0 SafeB Hbc_bm HSafeB_not_bm
                   Hgms_blk Hgtimer_blk Htable_blk Hktab_blk)
                (mwf_real_sglob lp bm bc oc0 SafeB)
                (mwf_real_chase_step lp bm bc oc0 SafeB)
                (mwf_real_chase_ptr lp bm bc oc0 SafeB Hbc_bm HSafeB_not_bm
                   HSafeB_not_bc Hgms_blk Hgtimer_blk Htable_blk Hktab_blk)
                (Hpres_obj_ext interaction._segmented_to_virtual eq_refl)
                (Hpres_obj_ext interaction._stop_shell_music eq_refl)
                (Hpres_obj_ext interaction._obj_set_held_state eq_refl))
             (smact_pres lp LO_mario LO_stp bm (NoA_real bm)
                (MWF_real lp bm bc oc0 SafeB)
                (mwf_real_ctl lp bm bc oc0 SafeB)
                (mwf_real_window lp bm bc oc0 SafeB Hbc_bm HSafeB_not_bm
                   Hgms_blk Hgtimer_blk Htable_blk Hktab_blk)
                (mwf_real_glob lp bm bc oc0 SafeB Hbc_bm Hglob_blk)
                (mwf_real_act_store lp bm bc oc0 SafeB Hbc_bm HSafeB_not_bm
                   Hgms_blk Hgtimer_blk Htable_blk Hktab_blk)
                SafeB HSafeB_not_bm
                (mwf_real_chase_root lp bm bc oc0 SafeB)
                (mwf_real_chase lp bm bc oc0 SafeB Hbc_bm HSafeB_not_bm
                   HSafeB_not_bc Hgms_blk Hgtimer_blk Htable_blk Hktab_blk)
                (mwf_real_root_store lp bm bc oc0 SafeB Hbc_bm HSafeB_not_bm
                   Hgms_blk Hgtimer_blk Htable_blk Hktab_blk)
                (mwf_real_sglob lp bm bc oc0 SafeB)
                (mwf_real_chase_step lp bm bc oc0 SafeB)
                (mwf_real_chase_ptr lp bm bc oc0 SafeB Hbc_bm HSafeB_not_bm
                   HSafeB_not_bc Hgms_blk Hgtimer_blk Htable_blk Hktab_blk))
             (msro_row lp LO_mario LO_int bm (NoA_real bm)
                (MWF_real lp bm bc oc0 SafeB)
                (mwf_real_ctl lp bm bc oc0 SafeB)
                (mwf_real_window lp bm bc oc0 SafeB Hbc_bm HSafeB_not_bm
                   Hgms_blk Hgtimer_blk Htable_blk Hktab_blk)
                (mwf_real_glob lp bm bc oc0 SafeB Hbc_bm Hglob_blk)
                (mwf_real_act_store lp bm bc oc0 SafeB Hbc_bm HSafeB_not_bm
                   Hgms_blk Hgtimer_blk Htable_blk Hktab_blk)
                SafeB HSafeB_not_bm
                (mwf_real_chase_root lp bm bc oc0 SafeB)
                (mwf_real_chase lp bm bc oc0 SafeB Hbc_bm HSafeB_not_bm
                   HSafeB_not_bc Hgms_blk Hgtimer_blk Htable_blk Hktab_blk)
                (mwf_real_root_store lp bm bc oc0 SafeB Hbc_bm HSafeB_not_bm
                   Hgms_blk Hgtimer_blk Htable_blk Hktab_blk)
                (mwf_real_sglob lp bm bc oc0 SafeB)
                (mwf_real_chase_step lp bm bc oc0 SafeB)
                (mwf_real_chase_ptr lp bm bc oc0 SafeB Hbc_bm HSafeB_not_bm
                   HSafeB_not_bc Hgms_blk Hgtimer_blk Htable_blk Hktab_blk)
                (Hpres_obj_ext interaction._stop_shell_music eq_refl))
             (Hpres_obj_ext interaction._segmented_to_virtual eq_refl)
             (Hpres_obj_ext interaction._bhv_spawn_star_no_level_exit
                eq_refl)
             (Hpres_obj_ext interaction._atan2s eq_refl)
             (Hpres_obj_ext interaction._save_file_get_flags eq_refl)
             (Hpres_obj_ext interaction._virtual_to_segmented eq_refl)
             (Hpres_obj_ext interaction._play_cap_music eq_refl)
             (Hpres_obj_ext interaction._play_shell_music eq_refl)
             (mdho_row lp LO_mario LO_int bm (NoA_real bm)
                (MWF_real lp bm bc oc0 SafeB)
                (mwf_real_ctl lp bm bc oc0 SafeB)
                (mwf_real_window lp bm bc oc0 SafeB Hbc_bm HSafeB_not_bm
                   Hgms_blk Hgtimer_blk Htable_blk Hktab_blk)
                (mwf_real_glob lp bm bc oc0 SafeB Hbc_bm Hglob_blk)
                (mwf_real_act_store lp bm bc oc0 SafeB Hbc_bm HSafeB_not_bm
                   Hgms_blk Hgtimer_blk Htable_blk Hktab_blk)
                SafeB HSafeB_not_bm
                (mwf_real_chase_root lp bm bc oc0 SafeB)
                (mwf_real_chase lp bm bc oc0 SafeB Hbc_bm HSafeB_not_bm
                   HSafeB_not_bc Hgms_blk Hgtimer_blk Htable_blk Hktab_blk)
                (mwf_real_root_store lp bm bc oc0 SafeB Hbc_bm HSafeB_not_bm
                   Hgms_blk Hgtimer_blk Htable_blk Hktab_blk)
                (mwf_real_sglob lp bm bc oc0 SafeB)
                (mwf_real_chase_step lp bm bc oc0 SafeB)
                (mwf_real_chase_ptr lp bm bc oc0 SafeB Hbc_bm HSafeB_not_bm
                   HSafeB_not_bc Hgms_blk Hgtimer_blk Htable_blk Hktab_blk)
                (Hpres_obj_ext interaction._segmented_to_virtual eq_refl)
                (Hpres_obj_ext interaction._stop_shell_music eq_refl)
                (Hpres_obj_ext interaction._obj_set_held_state eq_refl))
             (Hpres_obj_ext interaction._set_camera_mode eq_refl)
             (Hpres_obj_ext interaction._save_file_get_total_star_count
                eq_refl)
             (mwf_real_input lp bm bc oc0 SafeB Hbc_bm HSafeB_not_bm
                Hgms_blk Hgtimer_blk Htable_blk Hktab_blk)
             (fun mm v HMx Hld =>
                mwf_real_inp lp bm bc oc0 SafeB mm HMx v Hld)
             (mwf_real_alloc lp bm bc oc0 SafeB Hbc_bm)
             (fun m l m' Hf HM =>
                mwf_real_free lp bm bc oc0 SafeB Hbc_bm m m' l Hf HM)
             (Hpres_obj_ext interaction._save_file_collect_star_or_key
                eq_refl)
             (Hpres_obj_ext interaction._drop_queued_background_music
                eq_refl)
             (Hpres_obj_ext interaction._fadeout_level_music eq_refl)
             Hcpx_so_real
             Hio_rest).
  Qed.
  Lemma Hcp_mgco_real :
    call_pres_mgco lp bm (NoA_real bm) MWF SafeB.
  Proof.
    exact (mgco_cp lp LO_mario LO_int bm (NoA_real bm)
             (MWF_real lp bm bc oc0 SafeB) SafeB
             (mwf_real_chase_step lp bm bc oc0 SafeB)
             (mwf_real_window lp bm bc oc0 SafeB Hbc_bm HSafeB_not_bm
                Hgms_blk Hgtimer_blk Htable_blk Hktab_blk)
             (mwf_real_glob lp bm bc oc0 SafeB Hbc_bm Hglob_blk)
             (mwf_real_act_store lp bm bc oc0 SafeB Hbc_bm HSafeB_not_bm
                Hgms_blk Hgtimer_blk Htable_blk Hktab_blk)
             HSafeB_not_bm
             (mwf_real_chase_root lp bm bc oc0 SafeB)
             (mwf_real_root_store lp bm bc oc0 SafeB Hbc_bm HSafeB_not_bm
                Hgms_blk Hgtimer_blk Htable_blk Hktab_blk)).
  Qed.

  (* check_kick_or_punch_wall, WALKED (InterSurface.ckpw_cp): straight-line
     body with 3 detector[i] stack-array stores (local_idx arm), the
     m->action := ACT_BACKWARD_AIR_KB inline UNTAINTED constant store
     (const_act_assign_pres -- the value is statically not in the taint
     set, checked by the walker's wact_const census), one safe
     particleFlags window store, and three call classes: the WALKED
     resolve_and_return_wall_collisions (ol, dst = &detector), the WALKED
     mario_set_forward_vel (msfv_row, marg internal), and play_sound
     (pure-audio obj_ext external).  NOTHING new assumed. *)
  Lemma Hcp_ckpw_real :
    call_pres lp bm (NoA_real bm) MWF
      interaction._check_kick_or_punch_wall.
  Proof.
    exact (ckpw_cp lp LO_mario LO_int bm (NoA_real bm)
             (MWF_real lp bm bc oc0 SafeB) SafeB
             (mwf_real_ctl lp bm bc oc0 SafeB)
             (mwf_real_window lp bm bc oc0 SafeB Hbc_bm HSafeB_not_bm
                Hgms_blk Hgtimer_blk Htable_blk Hktab_blk)
             (mwf_real_act_store lp bm bc oc0 SafeB Hbc_bm HSafeB_not_bm
                Hgms_blk Hgtimer_blk Htable_blk Hktab_blk)
             (mwf_real_alloc lp bm bc oc0 SafeB Hbc_bm)
             (fun m l m' Hf HM =>
                mwf_real_free lp bm bc oc0 SafeB Hbc_bm m m' l Hf HM)
             (mwf_real_safe_valid lp bm bc oc0 SafeB)
             Hglob_valid
             aut_local_store
             (AutomaticLeafSurface.Hocp_resolve lp LO_mario bm (NoA_real bm)
                (MWF_real lp bm bc oc0 SafeB)
                (mwf_real_ctl lp bm bc oc0 SafeB)
                SafeB
                (mwf_real_alloc lp bm bc oc0 SafeB Hbc_bm)
                (fun m l m' Hf HM =>
                   mwf_real_free lp bm bc oc0 SafeB Hbc_bm m m' l Hf HM)
                (mwf_real_safe_valid lp bm bc oc0 SafeB)
                Hglob_valid
                aut_local_store
                Holcp_fwc_real)
             (msfv_row lp LO_mario bm (NoA_real bm)
                (MWF_real lp bm bc oc0 SafeB)
                (mwf_real_ctl lp bm bc oc0 SafeB)
                (mwf_real_window lp bm bc oc0 SafeB Hbc_bm HSafeB_not_bm
                   Hgms_blk Hgtimer_blk Htable_blk Hktab_blk)
                (mwf_real_glob lp bm bc oc0 SafeB Hbc_bm Hglob_blk)
                (mwf_real_act_store lp bm bc oc0 SafeB Hbc_bm HSafeB_not_bm
                   Hgms_blk Hgtimer_blk Htable_blk Hktab_blk)
                SafeB HSafeB_not_bm
                (mwf_real_chase_root lp bm bc oc0 SafeB)
                (mwf_real_chase lp bm bc oc0 SafeB Hbc_bm HSafeB_not_bm
                   HSafeB_not_bc Hgms_blk Hgtimer_blk Htable_blk Hktab_blk)
                (mwf_real_root_store lp bm bc oc0 SafeB Hbc_bm HSafeB_not_bm
                   Hgms_blk Hgtimer_blk Htable_blk Hktab_blk)
                (mwf_real_sglob lp bm bc oc0 SafeB)
                (mwf_real_chase_step lp bm bc oc0 SafeB)
                (mwf_real_chase_ptr lp bm bc oc0 SafeB Hbc_bm HSafeB_not_bm
                   HSafeB_not_bc Hgms_blk Hgtimer_blk Htable_blk Hktab_blk))
             (Hpres_obj_ext interaction._play_sound eq_refl)).
  Qed.
  Let Hpres_inter : body_pres lp (NoA_real bm) MWF bm
      interaction.f_mario_process_interactions :=
    inter_pres lp LO_mario LO_int bm (NoA_real bm)
      (MWF_real lp bm bc oc0 SafeB) SafeB
      (mwf_real_ctl lp bm bc oc0 SafeB)
      (mwf_real_window lp bm bc oc0 SafeB Hbc_bm HSafeB_not_bm
         Hgms_blk Hgtimer_blk Htable_blk Hktab_blk)
      (mwf_real_glob lp bm bc oc0 SafeB Hbc_bm Hglob_blk)
      (mwf_real_itab lp bm bc oc0 SafeB)
      Hcp_mgco_real Hcp_ckpw_real Hpres_ihandler.
  (* wind is WALKED (WindSurface.wind_pres -- the first loop-tolerant
     walk): the sargs gate (body_pres_s) pins yaw/pitch to Vint at entry,
     the spawn row pins _wind's block into SafeB across the pinned
     _t'1->_wind transfer, and the two rawData stores are Vint stores
     into the SafeB block, killed by the value-aware chase row.  NO
     whole-body wind residual remains -- only the spawn_object row. *)
  Let Hpres_wind : body_pres_s lp (NoA_real bm) MWF bm
      behavior_actions.f_spawn_wind_particles :=
    wind_pres lp bm (NoA_real bm) MWF SafeB
      (mwf_real_ctl lp bm bc oc0 SafeB)
      HSafeB_not_bm
      (mwf_real_chase lp bm bc oc0 SafeB Hbc_bm HSafeB_not_bm
         HSafeB_not_bc Hgms_blk Hgtimer_blk Htable_blk Hktab_blk)
      Hcp_spawn_real.
  (* the warp trigger is WALKED (WarpSurface.warp_pres: its 33 stores are
     all window- or stored_globals-class; its one internal callee,
     music_changed_through_warp, is store-free and walked too): what
     remains is the marg-free call_pres_ext row for each of its FIVE
     named external leaves (play_transition / play_sound / fadeout_music /
     area_get_warp_node / get_current_background_music) -- link-time
     facts about helpers that never touch Mario's block or the watched
     cells. *)
  Hypothesis Hpres_warp_ext : forall fid,
      mem_id fid warp_ext_ids = true ->
      call_pres_ext lp bm (NoA_real bm) MWF fid.
  (* RETURN-VALUE NON-ALIASING, REFINED (RetSurface): the opaque
     forall-reached row is now PROVED for every reached fundef whose
     return type cannot carry a Vptr through the return cast
     (Tvoid / Tint I8/I16/IBool / Tfloat -- ret_fd_safe = true: ~17 of
     the reached functions, with ZERO new trust, since on ptr64 = false
     only a Tint I32 / Tpointer target selects cast_case_pointer).  What
     stays assumed is the SHARPER residual: only the Tint I32 returns
     (the 4 getters + the 7 dispatchers, whose result is a status int,
     not a pointer) and the External fundefs (the honest terminal-
     external model boundary, e.g. EF_vload). *)
  Hypothesis Hret_unsafe : forall fd m0 vargs0 t0 m0' vres0,
      reached_v2 lp fd ->
      RetSurface.ret_fd_safe fd = false ->
      eval_funcall function_entry2 (lp_ge lp) m0 fd vargs0 t0 m0' vres0 ->
      forall b o, vres0 = Vptr b o -> b <> bm.
  Lemma Hret_call : forall fd m0 vargs0 t0 m0' vres0,
      reached_v2 lp fd ->
      eval_funcall function_entry2 (lp_ge lp) m0 fd vargs0 t0 m0' vres0 ->
      forall b o, vres0 = Vptr b o -> b <> bm.
  Proof.
    exact (RetSurface.ret_avoids_bm_of_unsafe function_entry2 (lp_ge lp) bm
             (reached_v2 lp) Hret_unsafe).
  Qed.

  (* externals, REACHED-GATED (per-symbol surface: reached_v2 lp (External
     ef) carries a named rest symbol resolving to ef). The forall-ef forms
     -- including the DELETED Hret_ext -- were FALSE for the real program
     (EF_memcpy / EF_vload counterexamples). *)
  Hypothesis Hext_action : forall ef targs tres cc vargs m t vres m',
      reached_v2 lp (External ef targs tres cc) ->
      external_call ef (lp_ge lp) vargs m t vres m' ->
      Mem.unchanged_on (action_cell bm) m m'.
  Hypothesis Hmwf_ext : forall ef targs tres cc vargs m t vres m',
      reached_v2 lp (External ef targs tres cc) ->
      external_call ef (lp_ge lp) vargs m t vres m' ->
      Mem.valid_block m bm -> MWF m -> MWF m'.
  (* the chase-root row of MWF at the marioObj cell: its value, if a
     pointer, is SafeB. PROVED here: the R6 projection
     MWFReal.mwf_real_chase_safe. *)
  Lemma Hchase_safe : forall delta mm b' o',
      field_offset (prog_comp_env mario.prog) mario._marioObj mario_state_members
        = Errors.OK (delta, Full) ->
      MWF mm ->
      Mem.loadv Mptr mm (Vptr bm (Ptrofs.repr delta)) = Some (Vptr b' o') ->
      SafeB b'.
  Proof. exact (mwf_real_chase_safe lp bm bc oc0 SafeB). Qed.
  (* the two REAL body stores (through the SafeB-pinned temps _t'49/_t'13)
     preserve NoA_real /\ MWF_real. PROVED here
     (MWFReal.mwf_real_store_safe: target block SafeB by the carried gate,
     stored value a Vint by cast shape, R7 via load_pointer_store).
     Until 2026-06-10 this row was ASSUMED at the live capstone. *)
  Lemma Hstore_safe :
    forall e le mm a1 a2 tt le' mm' out,
      NoA_real bm mm -> MWF mm -> RealFrameValue.prov_ok (Sassign a1 a2) ->
      (forall b o, le ! mario._t'49 = Some (Vptr b o) -> SafeB b) ->
      (forall b o, le ! mario._t'13 = Some (Vptr b o) -> SafeB b) ->
      exec_stmt function_entry2 (lp_ge lp) e le mm (Sassign a1 a2) tt le' mm' out ->
      NoA_real bm mm' /\ MWF mm'.
  Proof.
    exact (mwf_real_store_safe lp bm bc oc0 SafeB Hbc_bm HSafeB_not_bm
             HSafeB_not_bc Hgms_blk Hgtimer_blk Htable_blk Hktab_blk).
  Qed.

  (* perform_ground_quarter_step, WALKED (MarioStepSurface.pgqs_cp): the
     mo-gated worker behind pgs.  Its gWaterSurfacePseudoFloor originOffset
     store rides the stored_globals census row (mwf_real_glob);
     resolve_and_return_wall_collisions is the WALKED AutomaticLeafSurface
     body (ident-coincident across TUs), leaving its sole terminal external
     find_wall_collisions (Holcp_fwc_real); find_floor / vec3f_find_ceil
     ride the existing oc rows, vec3f_copy / vec3f_set the w1 rows, atan2s
     the obj_ext census; find_water_level is the one NEW terminal external
     (Hxcp_fwl_real). *)
  Lemma Hcp_pgqs_real :
    call_pres_mo lp bm (NoA_real bm) MWF SafeB
      mario_step._perform_ground_quarter_step.
  Proof.
    exact (pgqs_cp lp LO_mario LO_stp bm (NoA_real bm)
             (MWF_real lp bm bc oc0 SafeB) SafeB
             (mwf_real_ctl lp bm bc oc0 SafeB)
             (mwf_real_window lp bm bc oc0 SafeB Hbc_bm HSafeB_not_bm
                Hgms_blk Hgtimer_blk Htable_blk Hktab_blk)
             (mwf_real_alloc lp bm bc oc0 SafeB Hbc_bm)
             (fun m l m' Hf HM =>
                mwf_real_free lp bm bc oc0 SafeB Hbc_bm m m' l Hf HM)
             (mwf_real_safe_valid lp bm bc oc0 SafeB)
             Hglob_valid
             aut_local_store
             (mwf_real_glob lp bm bc oc0 SafeB Hbc_bm Hglob_blk
                mario_step._gWaterSurfacePseudoFloor eq_refl)
             (AutomaticLeafSurface.Hocp_resolve lp LO_mario bm (NoA_real bm)
                (MWF_real lp bm bc oc0 SafeB)
                (mwf_real_ctl lp bm bc oc0 SafeB)
                SafeB
                (mwf_real_alloc lp bm bc oc0 SafeB Hbc_bm)
                (fun m l m' Hf HM =>
                   mwf_real_free lp bm bc oc0 SafeB Hbc_bm m m' l Hf HM)
                (mwf_real_safe_valid lp bm bc oc0 SafeB)
                Hglob_valid
                aut_local_store
                Holcp_fwc_real)
             Hocp_find_floor
             Hocp_find_ceil
             Hxcp_fwl_real
             Hw1cp_v3f_real
             Hw1cp_v3fset_real
             (Hpres_obj_ext mario_step._atan2s eq_refl)).
  Qed.

  (* perform_ground_step, WALKED: the MarioStepSurface walk instantiated
     at MWF_real (frame bricks from MWFReal; the deeper pgqs row now the
     Lemma above, mgtsa still assumed; vec3f_copy/vec3s_set from the
     obj_ext census). *)
  Lemma Hcp_pgs :
    call_pres lp bm (NoA_real bm) MWF mario_step._perform_ground_step.
  Proof.
    exact (pgs_cp lp LO_mario LO_stp bm (NoA_real bm)
             (MWF_real lp bm bc oc0 SafeB) SafeB
             (mwf_real_ctl lp bm bc oc0 SafeB)
             (mwf_real_window lp bm bc oc0 SafeB Hbc_bm HSafeB_not_bm
                Hgms_blk Hgtimer_blk Htable_blk Hktab_blk)
             (mwf_real_alloc lp bm bc oc0 SafeB Hbc_bm)
             (fun m l m' Hf HM =>
                mwf_real_free lp bm bc oc0 SafeB Hbc_bm m m' l Hf HM)
             (mwf_real_safe_valid lp bm bc oc0 SafeB)
             Hglob_valid
             aut_local_store
             Hcp_pgqs_real
             Hcp_mgtsa_real
             (Hpres_obj_ext mario_step._vec3f_copy eq_refl)
             (Hpres_obj_ext mario_step._vec3s_set eq_refl)).
  Qed.

  (* apply_vertical_wind, WALKED zero-residual (PerformAirStepSurface.avw_*
     via call_pres_of_wwalk): a CLEAN window-writer (no calls, no fn_vars;
     m->vel[1] indexed-window stores, m->floor->type a chase READ).  The air
     twin of msfv_row -- same MWF_real kit. *)
  Lemma Hcp_avw :
    call_pres lp bm (NoA_real bm) MWF mario_step._apply_vertical_wind.
  Proof.
    apply (call_pres_of_wwalk lp LO_mario bm (NoA_real bm)
             (MWF_real lp bm bc oc0 SafeB)
             (mwf_real_ctl lp bm bc oc0 SafeB)
             (mwf_real_window lp bm bc oc0 SafeB Hbc_bm HSafeB_not_bm
                Hgms_blk Hgtimer_blk Htable_blk Hktab_blk)
             (mwf_real_glob lp bm bc oc0 SafeB Hbc_bm Hglob_blk)
             (mwf_real_act_store lp bm bc oc0 SafeB Hbc_bm HSafeB_not_bm
                Hgms_blk Hgtimer_blk Htable_blk Hktab_blk)
             SafeB HSafeB_not_bm
             (mwf_real_chase_root lp bm bc oc0 SafeB)
             (mwf_real_chase lp bm bc oc0 SafeB Hbc_bm HSafeB_not_bm
                HSafeB_not_bc Hgms_blk Hgtimer_blk Htable_blk Hktab_blk)
             (mwf_real_root_store lp bm bc oc0 SafeB Hbc_bm HSafeB_not_bm
                Hgms_blk Hgtimer_blk Htable_blk Hktab_blk)
             (mwf_real_sglob lp bm bc oc0 SafeB)
             (mwf_real_chase_step lp bm bc oc0 SafeB)
             (mwf_real_chase_ptr lp bm bc oc0 SafeB Hbc_bm HSafeB_not_bm
                HSafeB_not_bc Hgms_blk Hgtimer_blk Htable_blk Hktab_blk)
             mario_step.prog mario_step._apply_vertical_wind
             mario_step.f_apply_vertical_wind nil nil nil nil
             LO_stp avw_pin avw_vars avw_params);
      try (intros fid' Hfid'; discriminate Hfid').
    exact avw_walk.
  Qed.

  (* apply_twirl_gravity / should_strengthen_gravity_for_jump_ascent, WALKED
     zero-residual (PerformAirStepSurface.atg_*/ssg_* via call_pres_of_wwalk):
     both NO-call, NO-fn_var clean bodies (twirl writes m->angleVel[i]
     indexed-window; ssg is a pure reader).  apply_gravity's two callees. *)
  Lemma Hcp_atg :
    call_pres lp bm (NoA_real bm) MWF mario_step._apply_twirl_gravity.
  Proof.
    apply (call_pres_of_wwalk lp LO_mario bm (NoA_real bm)
             (MWF_real lp bm bc oc0 SafeB)
             (mwf_real_ctl lp bm bc oc0 SafeB)
             (mwf_real_window lp bm bc oc0 SafeB Hbc_bm HSafeB_not_bm
                Hgms_blk Hgtimer_blk Htable_blk Hktab_blk)
             (mwf_real_glob lp bm bc oc0 SafeB Hbc_bm Hglob_blk)
             (mwf_real_act_store lp bm bc oc0 SafeB Hbc_bm HSafeB_not_bm
                Hgms_blk Hgtimer_blk Htable_blk Hktab_blk)
             SafeB HSafeB_not_bm
             (mwf_real_chase_root lp bm bc oc0 SafeB)
             (mwf_real_chase lp bm bc oc0 SafeB Hbc_bm HSafeB_not_bm
                HSafeB_not_bc Hgms_blk Hgtimer_blk Htable_blk Hktab_blk)
             (mwf_real_root_store lp bm bc oc0 SafeB Hbc_bm HSafeB_not_bm
                Hgms_blk Hgtimer_blk Htable_blk Hktab_blk)
             (mwf_real_sglob lp bm bc oc0 SafeB)
             (mwf_real_chase_step lp bm bc oc0 SafeB)
             (mwf_real_chase_ptr lp bm bc oc0 SafeB Hbc_bm HSafeB_not_bm
                HSafeB_not_bc Hgms_blk Hgtimer_blk Htable_blk Hktab_blk)
             mario_step.prog mario_step._apply_twirl_gravity
             mario_step.f_apply_twirl_gravity nil nil nil nil
             LO_stp atg_pin atg_vars atg_params);
      try (intros fid' Hfid'; discriminate Hfid').
    exact atg_walk.
  Qed.

  Lemma Hcp_ssg :
    call_pres lp bm (NoA_real bm) MWF
      mario_step._should_strengthen_gravity_for_jump_ascent.
  Proof.
    apply (call_pres_of_wwalk lp LO_mario bm (NoA_real bm)
             (MWF_real lp bm bc oc0 SafeB)
             (mwf_real_ctl lp bm bc oc0 SafeB)
             (mwf_real_window lp bm bc oc0 SafeB Hbc_bm HSafeB_not_bm
                Hgms_blk Hgtimer_blk Htable_blk Hktab_blk)
             (mwf_real_glob lp bm bc oc0 SafeB Hbc_bm Hglob_blk)
             (mwf_real_act_store lp bm bc oc0 SafeB Hbc_bm HSafeB_not_bm
                Hgms_blk Hgtimer_blk Htable_blk Hktab_blk)
             SafeB HSafeB_not_bm
             (mwf_real_chase_root lp bm bc oc0 SafeB)
             (mwf_real_chase lp bm bc oc0 SafeB Hbc_bm HSafeB_not_bm
                HSafeB_not_bc Hgms_blk Hgtimer_blk Htable_blk Hktab_blk)
             (mwf_real_root_store lp bm bc oc0 SafeB Hbc_bm HSafeB_not_bm
                Hgms_blk Hgtimer_blk Htable_blk Hktab_blk)
             (mwf_real_sglob lp bm bc oc0 SafeB)
             (mwf_real_chase_step lp bm bc oc0 SafeB)
             (mwf_real_chase_ptr lp bm bc oc0 SafeB Hbc_bm HSafeB_not_bm
                HSafeB_not_bc Hgms_blk Hgtimer_blk Htable_blk Hktab_blk)
             mario_step.prog
             mario_step._should_strengthen_gravity_for_jump_ascent
             mario_step.f_should_strengthen_gravity_for_jump_ascent
             nil nil nil nil
             LO_stp ssg_pin ssg_vars ssg_params);
      try (intros fid' Hfid'; discriminate Hfid').
    exact ssg_walk.
  Qed.

  (* apply_gravity, WALKED (PerformAirStepSurface.ag_* via call_pres_of_wwalk_
     cact): ids=[apply_twirl_gravity; should_strengthen_gravity_for_jump_ascent]
     supplied by Hcp_atg/Hcp_ssg; the one chase store m->marioBodyState->
     wingFlutter = 1 (a const int) rides cact=[_t'17] (the MWF chase rows). *)
  Lemma Hcp_ag :
    call_pres lp bm (NoA_real bm) MWF mario_step._apply_gravity.
  Proof.
    apply (call_pres_of_wwalk_cact lp LO_mario bm (NoA_real bm)
             (MWF_real lp bm bc oc0 SafeB)
             (mwf_real_ctl lp bm bc oc0 SafeB)
             (mwf_real_window lp bm bc oc0 SafeB Hbc_bm HSafeB_not_bm
                Hgms_blk Hgtimer_blk Htable_blk Hktab_blk)
             (mwf_real_glob lp bm bc oc0 SafeB Hbc_bm Hglob_blk)
             (mwf_real_act_store lp bm bc oc0 SafeB Hbc_bm HSafeB_not_bm
                Hgms_blk Hgtimer_blk Htable_blk Hktab_blk)
             SafeB HSafeB_not_bm
             (mwf_real_chase_root lp bm bc oc0 SafeB)
             (mwf_real_chase lp bm bc oc0 SafeB Hbc_bm HSafeB_not_bm
                HSafeB_not_bc Hgms_blk Hgtimer_blk Htable_blk Hktab_blk)
             (mwf_real_root_store lp bm bc oc0 SafeB Hbc_bm HSafeB_not_bm
                Hgms_blk Hgtimer_blk Htable_blk Hktab_blk)
             (mwf_real_sglob lp bm bc oc0 SafeB)
             (mwf_real_chase_step lp bm bc oc0 SafeB)
             (mwf_real_chase_ptr lp bm bc oc0 SafeB Hbc_bm HSafeB_not_bm
                HSafeB_not_bc Hgms_blk Hgtimer_blk Htable_blk Hktab_blk)
             mario_step.prog mario_step._apply_gravity
             mario_step.f_apply_gravity
             (mario_step._apply_twirl_gravity
                :: mario_step._should_strengthen_gravity_for_jump_ascent :: nil)
             nil (mario_step._t'17 :: nil) nil nil
             LO_stp ag_pin ag_vars ag_params ag_cact_nonparam).
    - intros fid' Hfid'.
      apply orb_true_iff in Hfid' as [Hm | Hfid'].
      + apply Pos.eqb_eq in Hm; subst fid'; exact Hcp_atg.
      + apply orb_true_iff in Hfid' as [Hm | Hfid']; [ | discriminate Hfid' ].
        apply Pos.eqb_eq in Hm; subst fid'; exact Hcp_ssg.
    - intros fid' Hfid'; discriminate Hfid'.
    - intros fid' Hfid'; discriminate Hfid'.
    - intros fid' Hfid'; discriminate Hfid'.
    - exact ag_walk.
  Qed.

  (* check_ledge_grab, WALKED (PerformAirStepSurface.clg_cp): paqs's one
     deeper INTERNAL callee (mario_step.prog).  A bool-returning ledge-grab
     predicate with its OWN fn_vars (_ledgeFloor : Surface*, _ledgePos :
     f32[3] stack array); only _m is gated (marg) -- the other 3 pointer
     params (wall/intendedPos/nextPos) are READ-ONLY.  On the full-success
     path it writes m->pos (WINDOW vec3f_copy, w1) / m->floor (pointer field,
     safe window) / m->floorHeight / m->floorAngle (safe fields) /
     m->faceAngle[i] (short idx, idx16) + its OWN _ledgePos[i] stack stores
     (local idx).  ALL its gated callees are SHARED with the pgqs/paqs walks
     (find_floor oc = Hocp_find_floor; window vec3f_copy w1 = Hw1cp_v3f_real;
     atan2s = the obj_ext row) -- so this discharge adds ZERO new capstone
     rows.  Instantiated at MWF_real (frame bricks from MWFReal). *)
  Lemma Hcp_clg_real :
    call_pres lp bm (NoA_real bm) MWF mario_step._check_ledge_grab.
  Proof.
    exact (PerformAirStepSurface.clg_cp lp LO_mario LO_stp bm (NoA_real bm)
             (MWF_real lp bm bc oc0 SafeB) SafeB
             (mwf_real_ctl lp bm bc oc0 SafeB)
             (mwf_real_window lp bm bc oc0 SafeB Hbc_bm HSafeB_not_bm
                Hgms_blk Hgtimer_blk Htable_blk Hktab_blk)
             (mwf_real_alloc lp bm bc oc0 SafeB Hbc_bm)
             (fun m l m' Hf HM =>
                mwf_real_free lp bm bc oc0 SafeB Hbc_bm m m' l Hf HM)
             (mwf_real_safe_valid lp bm bc oc0 SafeB)
             Hglob_valid
             aut_local_store
             Hocp_find_floor
             Hw1cp_v3f_real
             (Hpres_obj_ext mario_step._atan2s eq_refl)).
  Qed.

  (* perform_air_quarter_step, WALKED (PerformAirStepSurface.paqs_cp): the
     paqs-gated worker behind pas (arg0 marg AND arg1 = intendedPos local --
     the air twin of pgqs's mo gate, but intendedPos is a MIDDLE param so the
     gate carries BOTH).  _nextPos is paqs's OWN stack array (fn_var), so the
     out-param locality comes from alloc_variables (not a pointer param).  Its
     gWaterSurfacePseudoFloor originOffset store rides the stored_globals
     census row (mwf_real_glob); resolve_and_return_wall_collisions is the
     WALKED AutomaticLeafSurface body (ident-coincident across TUs), leaving
     its sole terminal external find_wall_collisions (Holcp_fwc_real);
     find_floor / vec3f_find_ceil ride the oc rows, the window vec3f_copy /
     atan2s ride the w1 / obj_ext rows, find_water_level the Hxcp_fwl_real
     row -- ALL shared with the pgqs walk.  The entry vec3f_copy(nextPos,
     intendedPos) (both LOCAL) rides the ol gate DERIVED from the union row
     Hwolcp_v3f_real (call_pres_ext_ol_of_wol).  Its one genuinely NEW residual
     is the deeper INTERNAL check_ledge_grab (Hcp_clg_real). *)
  Lemma Hcp_paqs_real :
    PerformAirStepSurface.call_pres_paqs lp bm (NoA_real bm) MWF SafeB
      mario_step._perform_air_quarter_step.
  Proof.
    exact (PerformAirStepSurface.paqs_cp lp LO_mario LO_stp bm (NoA_real bm)
             (MWF_real lp bm bc oc0 SafeB) SafeB
             (mwf_real_ctl lp bm bc oc0 SafeB)
             (mwf_real_window lp bm bc oc0 SafeB Hbc_bm HSafeB_not_bm
                Hgms_blk Hgtimer_blk Htable_blk Hktab_blk)
             (mwf_real_alloc lp bm bc oc0 SafeB Hbc_bm)
             (fun m l m' Hf HM =>
                mwf_real_free lp bm bc oc0 SafeB Hbc_bm m m' l Hf HM)
             (mwf_real_safe_valid lp bm bc oc0 SafeB)
             Hglob_valid
             aut_local_store
             (mwf_real_glob lp bm bc oc0 SafeB Hbc_bm Hglob_blk
                mario_step._gWaterSurfacePseudoFloor eq_refl)
             (AutomaticLeafSurface.Hocp_resolve lp LO_mario bm (NoA_real bm)
                (MWF_real lp bm bc oc0 SafeB)
                (mwf_real_ctl lp bm bc oc0 SafeB)
                SafeB
                (mwf_real_alloc lp bm bc oc0 SafeB Hbc_bm)
                (fun m l m' Hf HM =>
                   mwf_real_free lp bm bc oc0 SafeB Hbc_bm m m' l Hf HM)
                (mwf_real_safe_valid lp bm bc oc0 SafeB)
                Hglob_valid
                aut_local_store
                Holcp_fwc_real)
             Hocp_find_floor
             Hocp_find_ceil
             Hxcp_fwl_real
             (call_pres_ext_ol_of_wol lp bm (NoA_real bm)
                (MWF_real lp bm bc oc0 SafeB) SafeB
                mario_actions_automatic._vec3f_copy Hwolcp_v3f_real)
             Hw1cp_v3f_real
             (Hpres_obj_ext mario_step._atan2s eq_refl)
             Hcp_clg_real).
  Qed.

  (* perform_air_step, WALKED (PerformAirStepSurface.pas_cp): the air twin of
     pgs, instantiated at MWF_real (frame bricks from MWFReal; the deeper paqs
     row is the paqs-gated residual Hcp_paqs_real, apply_gravity the WALKED
     Lemma Hcp_ag, apply_vertical_wind the WALKED Lemma Hcp_avw, mgtsa the
     already-walked Lemma, vec3f_copy/vec3s_set from the obj_ext census). *)
  Lemma Hcp_pas :
    call_pres lp bm (NoA_real bm) MWF mario_step._perform_air_step.
  Proof.
    exact (pas_cp lp LO_mario LO_stp bm (NoA_real bm)
             (MWF_real lp bm bc oc0 SafeB) SafeB
             (mwf_real_ctl lp bm bc oc0 SafeB)
             (mwf_real_window lp bm bc oc0 SafeB Hbc_bm HSafeB_not_bm
                Hgms_blk Hgtimer_blk Htable_blk Hktab_blk)
             (mwf_real_alloc lp bm bc oc0 SafeB Hbc_bm)
             (fun m l m' Hf HM =>
                mwf_real_free lp bm bc oc0 SafeB Hbc_bm m m' l Hf HM)
             (mwf_real_safe_valid lp bm bc oc0 SafeB)
             Hglob_valid
             aut_local_store
             Hcp_paqs_real
             Hcp_mgtsa_real
             Hcp_ag
             Hcp_avw
             (Hpres_obj_ext mario_step._vec3f_copy eq_refl)
             (Hpres_obj_ext mario_step._vec3s_set eq_refl)).
  Qed.

  (* ==================================================================== *)
  (* THE MWF-GROUNDED THEOREM: same conclusion as the v2 capstone, but    *)
  (* the carried invariant is the concrete MWF_real -- its 14 projection/ *)
  (* stability hypotheses are PROVED, not assumed.                        *)
  (* ==================================================================== *)
  Theorem noA_no_spawn_never_flying_real_mwf :
    forall (init : mem) (is : list mem) (m : mem),
      mem_ok_lp bm MWF init ->
      Forall (fun i => a_pressed_real bm i = false) is ->
      Forall (fun i => spawn_flying i = false) is ->
      reachable mem mem (step_real lp) init is m ->
      ~ mem_flying_lp bm m.
  Proof.
    exact (noA_no_spawn_never_flying_real_v2 lp LO_mario bm SafeB
             (MWF_real lp bm bc oc0 SafeB) spawn_flying
             (mwf_real_inp lp bm bc oc0 SafeB)
             (mwf_real_ctl lp bm bc oc0 SafeB)
             (mwf_real_act_vint lp bm bc oc0 SafeB)
             (mwf_real_pgms lp bm bc oc0 SafeB)
             (mwf_real_chase_root lp bm bc oc0 SafeB)
             (mwf_real_chase_step lp bm bc oc0 SafeB)
             HSafeB_not_bm
             (mwf_real_window lp bm bc oc0 SafeB Hbc_bm HSafeB_not_bm Hgms_blk Hgtimer_blk Htable_blk Hktab_blk)
             (mwf_real_input lp bm bc oc0 SafeB Hbc_bm HSafeB_not_bm Hgms_blk Hgtimer_blk Htable_blk Hktab_blk)
             (mwf_real_glob lp bm bc oc0 SafeB Hbc_bm Hglob_blk)
             (mwf_real_chase lp bm bc oc0 SafeB Hbc_bm HSafeB_not_bm
                HSafeB_not_bc Hgms_blk Hgtimer_blk Htable_blk Hktab_blk)
             (mwf_real_umbi lp bm bc oc0 SafeB Hbc_bm HSafeB_not_bm Hgms_blk Hgtimer_blk Htable_blk Hktab_blk)
             WL_exempt
             (rest_pres_decompose lp LO_sta LO_mov LO_air LO_sub LO_cut
                LO_aut LO_obj LO_int LO_beh LO_lvl LO_stp Hrest_ext_only
                (NoA_real bm) (MWF_real lp bm bc oc0 SafeB) bm
                (stationary_pres lp LO_mario LO_sta LO_stp bm (NoA_real bm)
                   (MWF_real lp bm bc oc0 SafeB)
                   (mwf_real_ctl lp bm bc oc0 SafeB)
                   (mwf_real_window lp bm bc oc0 SafeB Hbc_bm HSafeB_not_bm
                      Hgms_blk Hgtimer_blk Htable_blk Hktab_blk)
                   (* SLICES 1-4: standing_against_wall/start_crawling/
                      stop_crawling/shivering/waking_up/braking_stop WALKED;
                      rest stays Hpres_sta_rest, audio externals via
                      Hpres_sta_ext *)
                   (stationary_leaf_callees_pres lp LO_mario LO_stp LO_sta LO_int bm
                      (NoA_real bm) (MWF_real lp bm bc oc0 SafeB)
                      (mwf_real_ctl lp bm bc oc0 SafeB)
                      (mwf_real_window lp bm bc oc0 SafeB Hbc_bm
                         HSafeB_not_bm Hgms_blk Hgtimer_blk Htable_blk Hktab_blk)
                      (mwf_real_glob lp bm bc oc0 SafeB Hbc_bm Hglob_blk)
                      (mwf_real_act_store lp bm bc oc0 SafeB Hbc_bm
                         HSafeB_not_bm Hgms_blk Hgtimer_blk Htable_blk Hktab_blk)
                      SafeB HSafeB_not_bm
                      (mwf_real_chase_root lp bm bc oc0 SafeB)
                      (mwf_real_chase lp bm bc oc0 SafeB Hbc_bm
                         HSafeB_not_bm HSafeB_not_bc Hgms_blk Hgtimer_blk Htable_blk Hktab_blk)
                      (mwf_real_root_store lp bm bc oc0 SafeB Hbc_bm
                         HSafeB_not_bm Hgms_blk Hgtimer_blk Htable_blk Hktab_blk)
                      (mwf_real_sglob lp bm bc oc0 SafeB)
                      (mwf_real_chase_step lp bm bc oc0 SafeB)
                      (mwf_real_chase_ptr lp bm bc oc0 SafeB Hbc_bm
                         HSafeB_not_bm HSafeB_not_bc Hgms_blk Hgtimer_blk Htable_blk Hktab_blk)
                      (* SLICE 17 cclc landing keystone: the carried MWF_real
                         pins Mario's input halfword A-clear (mwf_real_inp) --
                         the mid-frame fact the cclc A-gate kill consumes (the
                         SAME term the automatic cannon consumer below uses).
                         NO new trust. *)
                      (mwf_real_inp lp bm bc oc0 SafeB)
                      (* SLICE 18: the input-AND store prefix of lava_boost --
                         storing into the umbi footprint (input + framesSinceA/B)
                         while keeping the A-bit clear preserves MWF_real
                         (mwf_real_umbi).  NO new trust: the same MWF_real
                         preservation lemma the cannon umbi arc is built on. *)
                      (mwf_real_umbi lp bm bc oc0 SafeB Hbc_bm HSafeB_not_bm
                         Hgms_blk Hgtimer_blk Htable_blk Hktab_blk)
                      (Hpres_obj_ext mario_step._vec3f_copy eq_refl)
                      (Hpres_obj_ext mario._vec3s_set eq_refl)
                      (Hpres_obj_ext mario._load_patchable_table eq_refl)
                      (Hpres_obj_ext mario._play_sound eq_refl)
                      Hpres_sta_ext
                      Hcp_pgs
                      (Hpres_obj_ext interaction._segmented_to_virtual eq_refl)
                      (Hpres_obj_ext interaction._stop_shell_music eq_refl)
                      (Hpres_obj_ext interaction._obj_set_held_state eq_refl)
                      (Hpres_obj_ext interaction._sqrtf eq_refl)
                      (Hpres_obj_ext interaction._atan2s eq_refl)
                      (* SLICE 14: act_idle's find_floor_height_relative_polar
                         (the out-param helper) -- the PROVED oc-arc walk from
                         AutomaticLeafSurface, reusing the SAME 6 oc-arc terms
                         the automatic consumer below already supplies.  NOT new
                         trust: Hffhrp is fully discharged. *)
                      (AutomaticLeafSurface.Hffhrp lp LO_mario bm (NoA_real bm)
                         (MWF_real lp bm bc oc0 SafeB)
                         (mwf_real_ctl lp bm bc oc0 SafeB)
                         (mwf_real_window lp bm bc oc0 SafeB Hbc_bm
                            HSafeB_not_bm Hgms_blk Hgtimer_blk Htable_blk Hktab_blk)
                         (mwf_real_glob lp bm bc oc0 SafeB Hbc_bm Hglob_blk)
                         (mwf_real_act_store lp bm bc oc0 SafeB Hbc_bm
                            HSafeB_not_bm Hgms_blk Hgtimer_blk Htable_blk Hktab_blk)
                         SafeB HSafeB_not_bm
                         (mwf_real_chase_root lp bm bc oc0 SafeB)
                         (mwf_real_chase lp bm bc oc0 SafeB Hbc_bm
                            HSafeB_not_bm HSafeB_not_bc Hgms_blk Hgtimer_blk Htable_blk Hktab_blk)
                         (mwf_real_root_store lp bm bc oc0 SafeB Hbc_bm
                            HSafeB_not_bm Hgms_blk Hgtimer_blk Htable_blk Hktab_blk)
                         (mwf_real_sglob lp bm bc oc0 SafeB)
                         (mwf_real_chase_step lp bm bc oc0 SafeB)
                         (mwf_real_chase_ptr lp bm bc oc0 SafeB Hbc_bm
                            HSafeB_not_bm HSafeB_not_bc Hgms_blk Hgtimer_blk Htable_blk Hktab_blk)
                         Hocp_find_floor
                         (mwf_real_alloc lp bm bc oc0 SafeB Hbc_bm)
                         (fun m l m' Hf HM =>
                            mwf_real_free lp bm bc oc0 SafeB Hbc_bm m m' l Hf HM)
                         (mwf_real_safe_valid lp bm bc oc0 SafeB)
                         Hglob_valid
                         aut_local_store)
                      (* SLICE 16: set_camera_mode (obj_ext) -- the camera
                         external check_common_stationary_cancels's two helpers
                         (set_water_plunge_action / update_mario_sound_and_camera)
                         call.  Discharged via the obj_ext boundary. *)
                      (Hpres_obj_ext mario._set_camera_mode eq_refl)
                      (* SLICE 21: act_first_person's level_trigger_warp -- the
                         SHARED warp-trigger body the floors family already
                         walks (WarpSurface.warp_pres), lifted to a call_pres
                         via call_pres_of_body.  NO new trust: the same warp
                         body the floors/warp surfaces discharge. *)
                      (call_pres_of_body lp bm (NoA_real bm)
                         (MWF_real lp bm bc oc0 SafeB)
                         (mwf_real_ctl lp bm bc oc0 SafeB)
                         level_update.prog level_update._level_trigger_warp
                         level_update.f_level_trigger_warp LO_lvl
                         floors_warp_internal
                         (warp_pres lp LO_mario LO_lvl bm (NoA_real bm)
                            (MWF_real lp bm bc oc0 SafeB)
                            (mwf_real_ctl lp bm bc oc0 SafeB)
                            (mwf_real_window lp bm bc oc0 SafeB Hbc_bm
                               HSafeB_not_bm Hgms_blk Hgtimer_blk Htable_blk Hktab_blk)
                            (mwf_real_glob lp bm bc oc0 SafeB Hbc_bm Hglob_blk)
                            Hpres_warp_ext))
                      (* SLICE 21: save_file_get_total_star_count -- the pure
                         save-buffer READER (obj_ext model class). *)
                      (Hpres_obj_ext interaction._save_file_get_total_star_count
                         eq_refl)
                      (* SLICE 22: act_shockwave_bounce's vec3f_set(m->vel,...)
                         -- the SAME w1 dst-window terminal-external row the
                         cannon uses (vec3f_set is EF_external in every TU). *)
                      Hw1cp_v3fset_real
                      Hpres_sta_rest)
                   Hpres_qsand)
                (moving_pres lp LO_mario LO_mov LO_stp bm (NoA_real bm)
                   (MWF_real lp bm bc oc0 SafeB)
                   (mwf_real_ctl lp bm bc oc0 SafeB)
                   (mwf_real_window lp bm bc oc0 SafeB Hbc_bm HSafeB_not_bm
                      Hgms_blk Hgtimer_blk Htable_blk Hktab_blk)
                   (* the 39-id moving residual is SHRUNK to the un-walked
                      32 (mov_rest_ids): the 7-leaf knockback cluster is
                      WALKED via common_ground_knockback_action. *)
                   (moving_leaf_callees_pres lp LO_mario LO_stp LO_mov LO_int
                      LO_obj bm
                      (NoA_real bm) (MWF_real lp bm bc oc0 SafeB)
                      (mwf_real_ctl lp bm bc oc0 SafeB)
                      (mwf_real_window lp bm bc oc0 SafeB Hbc_bm HSafeB_not_bm
                         Hgms_blk Hgtimer_blk Htable_blk Hktab_blk)
                      (mwf_real_glob lp bm bc oc0 SafeB Hbc_bm Hglob_blk)
                      (mwf_real_act_store lp bm bc oc0 SafeB Hbc_bm
                         HSafeB_not_bm Hgms_blk Hgtimer_blk Htable_blk Hktab_blk)
                      SafeB HSafeB_not_bm
                      (mwf_real_chase_root lp bm bc oc0 SafeB)
                      (mwf_real_chase lp bm bc oc0 SafeB Hbc_bm
                         HSafeB_not_bm HSafeB_not_bc Hgms_blk Hgtimer_blk Htable_blk Hktab_blk)
                      (mwf_real_root_store lp bm bc oc0 SafeB Hbc_bm
                         HSafeB_not_bm Hgms_blk Hgtimer_blk Htable_blk Hktab_blk)
                      (mwf_real_sglob lp bm bc oc0 SafeB)
                      (mwf_real_chase_step lp bm bc oc0 SafeB)
                      (mwf_real_chase_ptr lp bm bc oc0 SafeB Hbc_bm
                         HSafeB_not_bm HSafeB_not_bc Hgms_blk Hgtimer_blk Htable_blk Hktab_blk)
                      (* ALIGN-WITH-FLOOR: sFloorAlignMatrix is SafeB (positive
                         per-symbol reach-closure fact -- act_crawling walked). *)
                      Hsfam_safe
                      (Hpres_obj_ext mario._sqrtf eq_refl)
                      (Hpres_obj_ext mario._play_sound eq_refl)
                      (Hpres_obj_ext mario._load_patchable_table eq_refl)
                      Hpres_mov_ext
                      Hcp_pgs
                      (* SLICE M3: the obj_ext boundary the set_jumping_action
                         arc reaches (atan2s/approach_s32 + dasma trio). *)
                      Hpres_obj_ext
                      (* LANDING KEYSTONE: the clc walk's two MWF rows --
                         ktab-load-untainted + input-A-clear (NO new trust). *)
                      (mwf_real_ktab lp bm bc oc0 SafeB)
                      (mwf_real_inp lp bm bc oc0 SafeB)
                      (* LANDING KEYSTONE part 3: the input-clear store MWF row
                         (store A-clear halfword at input cell -- NO new trust). *)
                      (mwf_real_input lp bm bc oc0 SafeB Hbc_bm HSafeB_not_bm
                         Hgms_blk Hgtimer_blk Htable_blk Hktab_blk)
                      (* SLICE M-DEC: the stack-frame rows for the local-vars
                         arc (check_ground_dive_or_punch's _filler) -- NO new
                         trust (mwf_real_alloc / mwf_real_free). *)
                      (mwf_real_alloc lp bm bc oc0 SafeB Hbc_bm)
                      (fun m l m' Hf HM =>
                         mwf_real_free lp bm bc oc0 SafeB Hbc_bm m m' l Hf HM)
                      (* act_walking (THE LAST moving leaf): the local-vars +
                         out-param kit -- HSafeValid / HGlobValid / Hls_real /
                         find_floor (oc) / find_wall_collisions (ol) -- all
                         shared with the automatic family (NO new trust), plus
                         the ONE new honest vec3f_copy wol row (local dst). *)
                      (mwf_real_safe_valid lp bm bc oc0 SafeB)
                      Hglob_valid
                      aut_local_store
                      Hocp_find_floor
                      Holcp_fwc_real
                      Hwolcp_v3f_real
                      Hpres_mov_rest)
                   Hpres_qsand)
                (airborne_pres lp LO_mario LO_air bm (NoA_real bm)
                   (MWF_real lp bm bc oc0 SafeB)
                   (mwf_real_ctl lp bm bc oc0 SafeB)
                   (* the 43-id airborne residual is SHRUNK to the un-walked
                      airborne_rest_ids: SLICE A1 walks the two prologue
                      helpers (check_common_airborne_cancels + play_far_fall_
                      sound) via the SAME shared rows the moving family uses
                      (swpa / dasma / play_sound) -- NO new trust. *)
                   (airborne_leaf_callees_pres lp LO_mario LO_stp LO_air LO_int bm
                      (NoA_real bm) (MWF_real lp bm bc oc0 SafeB)
                      (mwf_real_ctl lp bm bc oc0 SafeB)
                      (mwf_real_window lp bm bc oc0 SafeB Hbc_bm HSafeB_not_bm
                         Hgms_blk Hgtimer_blk Htable_blk Hktab_blk)
                      (mwf_real_glob lp bm bc oc0 SafeB Hbc_bm Hglob_blk)
                      (mwf_real_act_store lp bm bc oc0 SafeB Hbc_bm
                         HSafeB_not_bm Hgms_blk Hgtimer_blk Htable_blk Hktab_blk)
                      SafeB HSafeB_not_bm
                      (mwf_real_chase_root lp bm bc oc0 SafeB)
                      (mwf_real_chase lp bm bc oc0 SafeB Hbc_bm
                         HSafeB_not_bm HSafeB_not_bc Hgms_blk Hgtimer_blk Htable_blk Hktab_blk)
                      (mwf_real_root_store lp bm bc oc0 SafeB Hbc_bm
                         HSafeB_not_bm Hgms_blk Hgtimer_blk Htable_blk Hktab_blk)
                      (mwf_real_sglob lp bm bc oc0 SafeB)
                      (mwf_real_chase_step lp bm bc oc0 SafeB)
                      (mwf_real_chase_ptr lp bm bc oc0 SafeB Hbc_bm
                         HSafeB_not_bm HSafeB_not_bc Hgms_blk Hgtimer_blk Htable_blk Hktab_blk)
                      (Hpres_obj_ext mario._play_sound eq_refl)
                      Hpres_obj_ext
                      Hcp_caas_real
                      (Hpres_obj_ext mario._sqrtf eq_refl)
                      (Hpres_obj_ext mario._atan2s eq_refl)
                      Hcpx_approach_f32_real
                      (Hpres_obj_ext mario._load_patchable_table eq_refl)
                      (Hpres_floors_ext mario._raise_background_noise eq_refl)
                      (Hpres_obj_ext mario._set_camera_mode eq_refl)
                      Hcp_pas
                      Hcpx_approach_real
                      (* SLICE A21: act_lava_boost's low-health
                         level_trigger_warp -- the SHARED warp-trigger body
                         the floors/warp surfaces already walk (warp_pres
                         lifted via call_pres_of_body).  NO new trust. *)
                      (call_pres_of_body lp bm (NoA_real bm)
                         (MWF_real lp bm bc oc0 SafeB)
                         (mwf_real_ctl lp bm bc oc0 SafeB)
                         level_update.prog level_update._level_trigger_warp
                         level_update.f_level_trigger_warp LO_lvl
                         floors_warp_internal
                         (warp_pres lp LO_mario LO_lvl bm (NoA_real bm)
                            (MWF_real lp bm bc oc0 SafeB)
                            (mwf_real_ctl lp bm bc oc0 SafeB)
                            (mwf_real_window lp bm bc oc0 SafeB Hbc_bm
                               HSafeB_not_bm Hgms_blk Hgtimer_blk Htable_blk Hktab_blk)
                            (mwf_real_glob lp bm bc oc0 SafeB Hbc_bm Hglob_blk)
                            Hpres_warp_ext))
                      (* SLICE A22: act_getting_blown's mario_blow_off_cap --
                         carried as an internal call_pres residual (spawn arc
                         pending), the air analogue of Hcp_caas_real. *)
                      Hcp_mboc_real
                      (* SLICE A29: act_riding_hoot WALKED (the LAST
                         airborne_rest leaf) via a bespoke hybrid walker (the
                         act_in_cannon precedent MINUS the A-gate).  Its
                         externals: vec3s_set/vec3f_set object writers whose
                         dst chases marioObj into the SafeB pool (sc:
                         Hscp_v3s / NEW Hscp_v3fset_real), the
                         vec3f_set(m->vel,0,0,0) Mario-window writer (w1:
                         Hw1cp_v3fset_real), and the entry/exit stack-frame
                         MWF rows (fn_vars=nil: mwf_real_alloc/free, PROVED
                         terms, no new trust).  airborne_rest_ids is now nil
                         => Hpres_air_rest DISCHARGED (vacuous rest). *)
                      Hscp_v3s
                      Hscp_v3fset_real
                      Hw1cp_v3fset_real
                      (mwf_real_alloc lp bm bc oc0 SafeB Hbc_bm)
                      (fun m l m' Hf HM =>
                         mwf_real_free lp bm bc oc0 SafeB Hbc_bm m m' l Hf HM)
                      ltac:(intros fid f H _; vm_compute in H; discriminate H)))
                (submerged_pres lp LO_mario LO_sub bm (NoA_real bm)
                   (MWF_real lp bm bc oc0 SafeB) SafeB
                   (mwf_real_ctl lp bm bc oc0 SafeB)
                   (mwf_real_window lp bm bc oc0 SafeB Hbc_bm HSafeB_not_bm
                      Hgms_blk Hgtimer_blk Htable_blk Hktab_blk)
                   HSafeB_not_bm
                   (mwf_real_chase_root lp bm bc oc0 SafeB)
                   (mwf_real_chase lp bm bc oc0 SafeB Hbc_bm HSafeB_not_bm
                      HSafeB_not_bc Hgms_blk Hgtimer_blk Htable_blk Hktab_blk)
                   (* SLICE 1: act_metal_water_standing WALKED; the 33-id
                      census is shrunk to the un-walked 32 (sub_rest_ids). *)
                   (submerged_leaf_callees_pres_full lp LO_mario LO_stp LO_sub LO_int bm
                      (NoA_real bm) (MWF_real lp bm bc oc0 SafeB)
                      (mwf_real_ctl lp bm bc oc0 SafeB)
                      (mwf_real_window lp bm bc oc0 SafeB Hbc_bm
                         HSafeB_not_bm Hgms_blk Hgtimer_blk Htable_blk Hktab_blk)
                      (mwf_real_glob lp bm bc oc0 SafeB Hbc_bm Hglob_blk)
                      (mwf_real_act_store lp bm bc oc0 SafeB Hbc_bm
                         HSafeB_not_bm Hgms_blk Hgtimer_blk Htable_blk Hktab_blk)
                      SafeB HSafeB_not_bm
                      (mwf_real_chase_root lp bm bc oc0 SafeB)
                      (mwf_real_chase lp bm bc oc0 SafeB Hbc_bm
                         HSafeB_not_bm HSafeB_not_bc Hgms_blk Hgtimer_blk Htable_blk Hktab_blk)
                      (mwf_real_root_store lp bm bc oc0 SafeB Hbc_bm
                         HSafeB_not_bm Hgms_blk Hgtimer_blk Htable_blk Hktab_blk)
                      (mwf_real_sglob lp bm bc oc0 SafeB)
                      (mwf_real_chase_step lp bm bc oc0 SafeB)
                      (mwf_real_chase_ptr lp bm bc oc0 SafeB Hbc_bm
                         HSafeB_not_bm HSafeB_not_bc Hgms_blk Hgtimer_blk Htable_blk Hktab_blk)
                      (Hpres_obj_ext mario._load_patchable_table eq_refl)
                      (* stop_and_set_height_to_floor DISCHARGED in-surface
                         (sub_sashf_row) -- NO hyp; vec3f_copy/vec3s_set ride the
                         existing obj_ext boundary, msfv proved inline. *)
                      Hcp_pas
                      (* SLICE 4 (hold-metal variants): drop_and_set_mario_action
                         is the already-PROVED dasma_row (ObjectLeafSurface),
                         the SAME reusable term the interact_bully/stationary
                         consumers feed -- NO new trust. *)
                      (dasma_row lp LO_mario LO_stp LO_int bm (NoA_real bm)
                         (MWF_real lp bm bc oc0 SafeB)
                         (mwf_real_ctl lp bm bc oc0 SafeB)
                         (mwf_real_window lp bm bc oc0 SafeB Hbc_bm HSafeB_not_bm
                            Hgms_blk Hgtimer_blk Htable_blk Hktab_blk)
                         (mwf_real_glob lp bm bc oc0 SafeB Hbc_bm Hglob_blk)
                         (mwf_real_act_store lp bm bc oc0 SafeB Hbc_bm
                            HSafeB_not_bm Hgms_blk Hgtimer_blk Htable_blk Hktab_blk)
                         SafeB HSafeB_not_bm
                         (mwf_real_chase_root lp bm bc oc0 SafeB)
                         (mwf_real_chase lp bm bc oc0 SafeB Hbc_bm HSafeB_not_bm
                            HSafeB_not_bc Hgms_blk Hgtimer_blk Htable_blk Hktab_blk)
                         (mwf_real_root_store lp bm bc oc0 SafeB Hbc_bm
                            HSafeB_not_bm Hgms_blk Hgtimer_blk Htable_blk Hktab_blk)
                         (mwf_real_sglob lp bm bc oc0 SafeB)
                         (mwf_real_chase_step lp bm bc oc0 SafeB)
                         (mwf_real_chase_ptr lp bm bc oc0 SafeB Hbc_bm
                            HSafeB_not_bm HSafeB_not_bc Hgms_blk Hgtimer_blk Htable_blk Hktab_blk)
                         (Hpres_obj_ext interaction._segmented_to_virtual eq_refl)
                         (Hpres_obj_ext interaction._stop_shell_music eq_refl)
                         (Hpres_obj_ext interaction._obj_set_held_state eq_refl))
                      (* SLICE 5 (metal-water WALKING pair): perform_ground_step
                         is the already-PROVED Hcp_pgs Lemma (NO new trust);
                         set_mario_anim_with_accel is now DISCHARGED in-surface
                         (sub_smawa_row, np3 channel, NO hyp). *)
                      Hcp_pgs
                      (* SLICE 6 (water-IDLE cluster): common_idle_step honest
                         residual; the 4 idle leaves reduce to it + sids. *)
                      Hcp_cis_real
                      (* SLICE 7 (metal-water FALLING pair): stationary_slow_down
                         is now DISCHARGED in-surface (sub_ssd_row, NO hyp);
                         perform_water_step honest residual. *)
                      Hcp_pws_real
                      (* SLICE 8 (act_water_death): level_trigger_warp is the
                         SHARED warp-trigger body the floors/warp surfaces
                         already walk (call_pres_of_body + warp_pres) -- the
                         SAME term act_lava_boost feeds above, NO new trust.
                         The leaf reuses the slice-7 step residuals + a cact
                         chase store of m->marioBodyState->eyeState. *)
                      (call_pres_of_body lp bm (NoA_real bm)
                         (MWF_real lp bm bc oc0 SafeB)
                         (mwf_real_ctl lp bm bc oc0 SafeB)
                         level_update.prog level_update._level_trigger_warp
                         level_update.f_level_trigger_warp LO_lvl
                         floors_warp_internal
                         (warp_pres lp LO_mario LO_lvl bm (NoA_real bm)
                            (MWF_real lp bm bc oc0 SafeB)
                            (mwf_real_ctl lp bm bc oc0 SafeB)
                            (mwf_real_window lp bm bc oc0 SafeB Hbc_bm
                               HSafeB_not_bm Hgms_blk Hgtimer_blk Htable_blk Hktab_blk)
                            (mwf_real_glob lp bm bc oc0 SafeB Hbc_bm Hglob_blk)
                            Hpres_warp_ext))
                      (* SLICE 9 (act_drowning): play_sound_if_no_flag now
                         DISCHARGED in-surface (sub_psinf_row, NO hyp); the leaf
                         reuses everything else. *)
                      (* SLICE 10 (act_water_shocked): the two terminal
                         externals are obj_ext_ids members (Hpres_obj_ext) --
                         NO new trust.  The leaf's ternary-const set_mario_action
                         (wact) + marioBodyState/marioObj chases (cact) reuse the
                         set_mario_action keystone + the slice-7 step residuals. *)
                      (Hpres_obj_ext mario._play_sound eq_refl)
                      (Hpres_obj_ext interaction._set_camera_shake_from_hit eq_refl)
                      (* SLICE 11 (kb pair): cwks is DISCHARGED in-surface
                         (sub_cwks_row, call_pres_act3_of_wwalk_p4) -- NO hyp. *)
                      (* SLICE 12 (cancel gate): transition_submerged_to_walking
                         is DISCHARGED in-surface (sub_tstw_row, ws hybrid walker)
                         -- NO hyp; its angleVel vec3s_set rides the shared
                         Hw1cp_v3sset_real boundary appended below.
                         stop_shell_music zero-trust via the obj_ext boundary. *)
                      (Hpres_obj_ext interaction._stop_shell_music eq_refl)
                      (* SLICE 13 (throw/punch): mario_throw_held_object is now
                         DISCHARGED in-surface (sub_mtho_row, reusing
                         ObjectLeafSurface.mtho_row) -- NO hyp; check_water_grab
                         is ALSO now discharged in-surface (sub_cwg_row), fed the
                         proved Hcp_mgco_real (mario_get_collided_object SafeB
                         pointer-return brick) below.  approach_s32 /
                         segmented_to_virtual / play_shell_music / obj_set_held_
                         state zero-trust via the obj_ext boundary. *)
                      Hcp_mgco_real
                      (Hpres_obj_ext mario_actions_object._approach_s32 eq_refl)
                      (Hpres_obj_ext interaction._segmented_to_virtual eq_refl)
                      (Hpres_obj_ext interaction._play_shell_music eq_refl)
                      (Hpres_obj_ext interaction._obj_set_held_state eq_refl)
                      (* SLICE 14 (the swimming cluster -- 7 leaves): the swim
                         helpers are honest internal residuals; set_mario_action
                         / drop_and_set_mario_action / play_sound /
                         stop_shell_music reuse the keystone + dasma_row +
                         obj_ext boundary (NO new trust); approach_f32 is the
                         ONE new terminal-external boundary row. *)
                      (* check_water_jump DISCHARGED in-surface (sub_cwj_row,
                         ws hybrid walker) -- NO hyp; shares Hw1cp_v3sset_real. *)
                      (* set_anim_to_frame DISCHARGED in-surface (sub_satf_row,
                         bespoke body walk: chases m->marioObj to a SafeB block,
                         all 4 scalar stores go through the chased animInfo ptr,
                         never the action cell) -- NO hyp. *)
                      Hcp_ffs_real Hcpx_approach_f32_real
                      (* SLICE 15 (the last two leaves -- CLOSES the family):
                         swimming_near_surface is a PURE read-only body, so it is
                         DISCHARGED outright inside SubmergedLeafSurface (sns_cp
                         via pure_walk) -- NO hypothesis.  The four whirlpool
                         externals ride the obj_ext boundary (NO new trust).
                         submerged_leaf_callees_pres_full discharges the now-empty
                         rest premise inline -- NO Hpres_sub_rest.
                         NOTE: mario_actions_submerged._approach_f32 is the SAME
                         string-shared positive as airborne's, so the airborne
                         Hcpx_approach_f32_real covers it -- NO Hcpx_af32_real. *)
                      (Hpres_obj_ext mario_actions_submerged._sqrtf eq_refl)
                      (Hpres_obj_ext mario_actions_submerged._atan2s eq_refl)
                      (Hpres_obj_ext mario_actions_submerged._vec3f_copy eq_refl)
                      (Hpres_obj_ext mario_actions_submerged._vec3s_set eq_refl)
                      (* SLICE 12/14 ws walker externals (tstw + cwj bodies):
                         set_camera_mode rides the obj_ext boundary (NO new
                         trust); the angleVel vec3s_set window is the ONE new
                         terminal-external boundary row (Hw1cp_v3sset_real). *)
                      (Hpres_obj_ext mario._set_camera_mode eq_refl)
                      Hw1cp_v3sset_real))
                (cutscene_pres lp LO_mario LO_cut bm (NoA_real bm)
                   (MWF_real lp bm bc oc0 SafeB)
                   (mwf_real_ctl lp bm bc oc0 SafeB)
                   (mwf_real_window lp bm bc oc0 SafeB Hbc_bm HSafeB_not_bm
                      Hgms_blk Hgtimer_blk Htable_blk Hktab_blk)
                   (CutsceneLeafSurface.cutscene_leaf_callees_pres lp LO_mario
                      LO_stp LO_cut bm (NoA_real bm) (MWF_real lp bm bc oc0 SafeB)
                      (mwf_real_ctl lp bm bc oc0 SafeB)
                      (mwf_real_window lp bm bc oc0 SafeB Hbc_bm HSafeB_not_bm
                         Hgms_blk Hgtimer_blk Htable_blk Hktab_blk)
                      (mwf_real_glob lp bm bc oc0 SafeB Hbc_bm Hglob_blk)
                      (mwf_real_act_store lp bm bc oc0 SafeB Hbc_bm HSafeB_not_bm
                         Hgms_blk Hgtimer_blk Htable_blk Hktab_blk)
                      SafeB HSafeB_not_bm
                      (mwf_real_chase_root lp bm bc oc0 SafeB)
                      (mwf_real_chase lp bm bc oc0 SafeB Hbc_bm HSafeB_not_bm
                         HSafeB_not_bc Hgms_blk Hgtimer_blk Htable_blk Hktab_blk)
                      (mwf_real_root_store lp bm bc oc0 SafeB Hbc_bm HSafeB_not_bm
                         Hgms_blk Hgtimer_blk Htable_blk Hktab_blk)
                      (mwf_real_sglob lp bm bc oc0 SafeB)
                      (mwf_real_chase_step lp bm bc oc0 SafeB)
                      (mwf_real_chase_ptr lp bm bc oc0 SafeB Hbc_bm HSafeB_not_bm
                         HSafeB_not_bc Hgms_blk Hgtimer_blk Htable_blk Hktab_blk)
                      (Hpres_obj_ext mario._play_sound eq_refl)
                      (Hpres_obj_ext mario._load_patchable_table eq_refl)
                      (Hpres_obj_ext mario._vec3f_copy eq_refl)
                      (Hpres_obj_ext mario._vec3s_set eq_refl)
                      (call_pres_of_body lp bm (NoA_real bm)
                         (MWF_real lp bm bc oc0 SafeB)
                         (mwf_real_ctl lp bm bc oc0 SafeB)
                         level_update.prog level_update._level_trigger_warp
                         level_update.f_level_trigger_warp LO_lvl
                         floors_warp_internal
                         (warp_pres lp LO_mario LO_lvl bm (NoA_real bm)
                            (MWF_real lp bm bc oc0 SafeB)
                            (mwf_real_ctl lp bm bc oc0 SafeB)
                            (mwf_real_window lp bm bc oc0 SafeB Hbc_bm
                               HSafeB_not_bm Hgms_blk Hgtimer_blk Htable_blk Hktab_blk)
                            (mwf_real_glob lp bm bc oc0 SafeB Hbc_bm Hglob_blk)
                            Hpres_warp_ext))
                      Hpres_cut_rest))
                (automatic_pres lp LO_mario LO_aut bm (NoA_real bm)
                   (MWF_real lp bm bc oc0 SafeB)
                   (mwf_real_ctl lp bm bc oc0 SafeB)
                   (mwf_real_window lp bm bc oc0 SafeB Hbc_bm HSafeB_not_bm
                      Hgms_blk Hgtimer_blk Htable_blk Hktab_blk)
                   (automatic_leaf_callees_pres lp LO_mario LO_stp LO_aut bm
                      (NoA_real bm)
                      (MWF_real lp bm bc oc0 SafeB)
                      (mwf_real_ctl lp bm bc oc0 SafeB)
                      (mwf_real_window lp bm bc oc0 SafeB Hbc_bm
                         HSafeB_not_bm Hgms_blk Hgtimer_blk Htable_blk Hktab_blk)
                      (mwf_real_glob lp bm bc oc0 SafeB Hbc_bm Hglob_blk)
                      (mwf_real_act_store lp bm bc oc0 SafeB Hbc_bm
                         HSafeB_not_bm Hgms_blk Hgtimer_blk Htable_blk Hktab_blk)
                      SafeB HSafeB_not_bm
                      (mwf_real_chase_root lp bm bc oc0 SafeB)
                      (mwf_real_chase lp bm bc oc0 SafeB Hbc_bm
                         HSafeB_not_bm HSafeB_not_bc Hgms_blk Hgtimer_blk Htable_blk Hktab_blk)
                      (mwf_real_root_store lp bm bc oc0 SafeB Hbc_bm
                         HSafeB_not_bm Hgms_blk Hgtimer_blk Htable_blk Hktab_blk)
                      (mwf_real_sglob lp bm bc oc0 SafeB)
                      (mwf_real_chase_step lp bm bc oc0 SafeB)
                      (mwf_real_chase_ptr lp bm bc oc0 SafeB Hbc_bm
                         HSafeB_not_bm HSafeB_not_bc Hgms_blk Hgtimer_blk Htable_blk Hktab_blk)
                      (* B14 cannon kill: the carried MWF_real pins Mario's
                         input halfword A-clear (mwf_real_inp) -- the
                         mid-frame fact act_in_cannon's fire-gate kill
                         consumes.  NO new trust. *)
                      (mwf_real_inp lp bm bc oc0 SafeB)
                      (Hpres_obj_ext mario._vec3s_set eq_refl)
                      (Hpres_obj_ext mario._set_camera_mode eq_refl)
                      (Hpres_obj_ext mario._load_patchable_table eq_refl)
                      (Hpres_obj_ext mario_step._vec3f_copy eq_refl)
                      (Hpres_obj_ext mario._play_sound eq_refl)
                      (* ledge cluster: find_floor as a FAITHFUL out-param
                         writer (call_pres_ext_oc, gated on local out-param)
                         + the local-vars-arc stack-frame MWF bricks
                         (alloc/free/local-store preserve MWF_real, and the
                         SafeB/global validity projections) *)
                      Hocp_find_floor
                      (* the four SHARED gated leaf-external residuals that
                         set_pole_position's WALK reduces to (oc/wc/sc) *)
                      Hocp_find_ceil
                      (call_pres_ext_wc_of_wol lp bm (NoA_real bm) MWF SafeB
                         mario_actions_automatic._f32_find_wall_collision
                         Hwolcp_fwc)
                      Hscp_v3f
                      Hscp_v3s
                      (* tornado: f32_find_wall_collision's stack-local
                         (&nextPos[i]) call shape -- the ol gate *)
                      (call_pres_ext_ol_of_wol lp bm (NoA_real bm) MWF SafeB
                         mario_actions_automatic._f32_find_wall_collision
                         Hwolcp_fwc)
                      (mwf_real_alloc lp bm bc oc0 SafeB Hbc_bm)
                      (fun m l m' Hf HM =>
                         mwf_real_free lp bm bc oc0 SafeB Hbc_bm m m' l Hf HM)
                      (mwf_real_safe_valid lp bm bc oc0 SafeB)
                      Hglob_valid
                      aut_local_store
                      (* B10 pole scaffold: segmented_to_virtual (obj_ext).
                         set_pole_position is now WALKED, not assumed. *)
                      (Hpres_obj_ext interaction._segmented_to_virtual eq_refl)
                      (* act_holding_pole externals (now WALKED, not in rest):
                         set_sound_moving_speed + virtual_to_segmented, both
                         obj_ext_ids audio/translation externals. *)
                      (Hpres_obj_ext mario._set_sound_moving_speed eq_refl)
                      (Hpres_obj_ext interaction._virtual_to_segmented eq_refl)
                      (* B11: find_mario_anim_flags_and_translation is now WALKED
                         (famft_body_pres_oc2); its oc2 residual decomposed into
                         these two terminal EXTERNAL writers (geo_update via arg0
                         SafeB, retrieve_animation_index via &animIndex local). *)
                      Hscp_geo_real
                      Hocp_rai_real
                      (* B11: update_hang_moving WALKED; its two honest leaf
                         callees (approach_s32 ext + perform_hanging_step mo).
                         perform_hanging_step is itself now WALKED, and so is
                         its resolve_and_return_wall_collisions leaf -- what
                         remains here is resolve's SOLE terminal external
                         find_wall_collisions (ol) + vec3f_copy (w1). *)
                      Hcpx_approach_real
                      Holcp_fwc_real
                      Hw1cp_v3f_real
                      (* B14: act_in_cannon's vec3f_set(m->vel,0,0,0) site --
                         the w1 dst-window terminal external *)
                      Hw1cp_v3fset_real))
                (object_pres lp LO_mario LO_obj LO_stp bm (NoA_real bm)
                   (MWF_real lp bm bc oc0 SafeB)
                   (mwf_real_ctl lp bm bc oc0 SafeB)
                   (mwf_real_window lp bm bc oc0 SafeB Hbc_bm HSafeB_not_bm
                      Hgms_blk Hgtimer_blk Htable_blk Hktab_blk)
                   (object_callees_pres lp LO_mario LO_stp LO_int LO_obj bm
                      (NoA_real bm)
                      (MWF_real lp bm bc oc0 SafeB)
                      (mwf_real_ctl lp bm bc oc0 SafeB)
                      (mwf_real_window lp bm bc oc0 SafeB Hbc_bm
                         HSafeB_not_bm Hgms_blk Hgtimer_blk Htable_blk Hktab_blk)
                      (mwf_real_glob lp bm bc oc0 SafeB Hbc_bm Hglob_blk)
                      (mwf_real_act_store lp bm bc oc0 SafeB Hbc_bm
                         HSafeB_not_bm Hgms_blk Hgtimer_blk Htable_blk Hktab_blk)
                      SafeB HSafeB_not_bm
                      (mwf_real_chase_root lp bm bc oc0 SafeB)
                      (mwf_real_chase lp bm bc oc0 SafeB Hbc_bm
                         HSafeB_not_bm HSafeB_not_bc Hgms_blk Hgtimer_blk Htable_blk Hktab_blk)
                      (mwf_real_root_store lp bm bc oc0 SafeB Hbc_bm
                         HSafeB_not_bm Hgms_blk Hgtimer_blk Htable_blk Hktab_blk)
                      (mwf_real_sglob lp bm bc oc0 SafeB)
                      (mwf_real_chase_step lp bm bc oc0 SafeB)
                      (mwf_real_chase_ptr lp bm bc oc0 SafeB Hbc_bm
                         HSafeB_not_bm HSafeB_not_bc Hgms_blk
                         Hgtimer_blk Htable_blk Hktab_blk)
                      (Hpres_obj_ext mario._play_sound eq_refl)
                      (Hpres_obj_ext mario._vec3s_set eq_refl)
                      (Hpres_obj_ext mario_step._vec3f_copy eq_refl)
                      (Hpres_obj_ext mario._set_camera_mode eq_refl)
                      (Hpres_obj_ext interaction._segmented_to_virtual
                         eq_refl)
                      (Hpres_obj_ext interaction._stop_shell_music eq_refl)
                      (Hpres_obj_ext interaction._obj_set_held_state
                         eq_refl)
                      (Hpres_obj_ext mario._load_patchable_table eq_refl)
                      (Hpres_obj_ext mario_actions_object._approach_s32
                         eq_refl)
                      (Hpres_obj_ext interaction._atan2s eq_refl)
                      (Hpres_obj_ext interaction._virtual_to_segmented
                         eq_refl)
                      Hcp_pgs)
                   Hpres_qsand)
                (floors_pres lp LO_mario LO_int LO_lvl bm (NoA_real bm)
                   (MWF_real lp bm bc oc0 SafeB)
                   (mwf_real_ctl lp bm bc oc0 SafeB)
                   (mwf_real_window lp bm bc oc0 SafeB Hbc_bm HSafeB_not_bm
                      Hgms_blk Hgtimer_blk Htable_blk Hktab_blk)
                   (mwf_real_glob lp bm bc oc0 SafeB Hbc_bm Hglob_blk)
                   (floors_callees_pres lp LO_mario LO_stp LO_int LO_lvl bm
                      (NoA_real bm)
                      (MWF_real lp bm bc oc0 SafeB)
                      (mwf_real_ctl lp bm bc oc0 SafeB)
                      (mwf_real_window lp bm bc oc0 SafeB Hbc_bm
                         HSafeB_not_bm Hgms_blk Hgtimer_blk Htable_blk Hktab_blk)
                      (mwf_real_glob lp bm bc oc0 SafeB Hbc_bm Hglob_blk)
                      (mwf_real_act_store lp bm bc oc0 SafeB Hbc_bm
                         HSafeB_not_bm Hgms_blk Hgtimer_blk Htable_blk Hktab_blk)
                      SafeB HSafeB_not_bm
                      (mwf_real_chase_root lp bm bc oc0 SafeB)
                      (mwf_real_chase lp bm bc oc0 SafeB Hbc_bm
                         HSafeB_not_bm HSafeB_not_bc Hgms_blk Hgtimer_blk Htable_blk Hktab_blk)
                      (mwf_real_root_store lp bm bc oc0 SafeB Hbc_bm
                         HSafeB_not_bm Hgms_blk Hgtimer_blk Htable_blk Hktab_blk)
                      (mwf_real_sglob lp bm bc oc0 SafeB)
                      (mwf_real_chase_step lp bm bc oc0 SafeB)
                      (mwf_real_chase_ptr lp bm bc oc0 SafeB Hbc_bm
                         HSafeB_not_bm HSafeB_not_bc Hgms_blk
                         Hgtimer_blk Htable_blk Hktab_blk)
                      (Hpres_obj_ext mario._play_sound eq_refl)
                      (Hpres_obj_ext mario._set_camera_mode eq_refl)
                      (Hpres_obj_ext interaction._segmented_to_virtual
                         eq_refl)
                      (Hpres_obj_ext interaction._stop_shell_music eq_refl)
                      (Hpres_obj_ext interaction._obj_set_held_state
                         eq_refl)
                      (Hpres_floors_ext mario._raise_background_noise
                         eq_refl)
                      (Hpres_floors_ext interaction._spawn_default_star
                         eq_refl)
                      (warp_pres lp LO_mario LO_lvl bm (NoA_real bm)
                         (MWF_real lp bm bc oc0 SafeB)
                         (mwf_real_ctl lp bm bc oc0 SafeB)
                         (mwf_real_window lp bm bc oc0 SafeB Hbc_bm
                            HSafeB_not_bm Hgms_blk Hgtimer_blk Htable_blk Hktab_blk)
                         (mwf_real_glob lp bm bc oc0 SafeB Hbc_bm
                            Hglob_blk)
                         Hpres_warp_ext))
                   (warp_pres lp LO_mario LO_lvl bm (NoA_real bm)
                      (MWF_real lp bm bc oc0 SafeB)
                      (mwf_real_ctl lp bm bc oc0 SafeB)
                      (mwf_real_window lp bm bc oc0 SafeB Hbc_bm
                         HSafeB_not_bm Hgms_blk Hgtimer_blk Htable_blk Hktab_blk)
                      (mwf_real_glob lp bm bc oc0 SafeB Hbc_bm Hglob_blk)
                      Hpres_warp_ext))
                Hpres_inter Hpres_wind
                (warp_pres lp LO_mario LO_lvl bm (NoA_real bm)
                   (MWF_real lp bm bc oc0 SafeB)
                   (mwf_real_ctl lp bm bc oc0 SafeB)
                   (mwf_real_window lp bm bc oc0 SafeB Hbc_bm HSafeB_not_bm
                      Hgms_blk Hgtimer_blk Htable_blk Hktab_blk)
                   (mwf_real_glob lp bm bc oc0 SafeB Hbc_bm Hglob_blk)
                   Hpres_warp_ext))
             Hret_unsafe Hext_action Hmwf_ext
             (mwf_real_entry lp bm bc oc0 SafeB Hbc_bm)
             (mwf_real_free lp bm bc oc0 SafeB Hbc_bm)
             (fun gb Hgb => proj2 (proj2 (Hgms_blk gb Hgb)))
             Hchase_safe Hstore_safe).
  Qed.

End NoARealInputMWF.
