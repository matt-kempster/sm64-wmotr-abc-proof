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
  LocalVarsSurface OutParamSurface WindSurface InterSurface.

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
  Hypothesis Hstore :
    forall e le mm a1 a2 tt le' mm' out,
      NoA mm -> RealFrameValue.prov_ok (Sassign a1 a2) ->
      exec_stmt function_entry2 (lp_ge lp) e le mm (Sassign a1 a2) tt le' mm' out -> NoA mm'.
  Hypothesis Hstoremwf :
    forall e le mm a1 a2 tt le' mm' out,
      NoA mm -> RealFrameValue.prov_ok (Sassign a1 a2) -> MWF mm ->
      exec_stmt function_entry2 (lp_ge lp) e le mm (Sassign a1 a2) tt le' mm' out -> MWF mm'.
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
    intros i m m' Ha _ (Hv & Hsat & Hwf & Hgwf & HMWF) Hst.
    assert (HnoA : NoA m) by (eapply input_grounds_noA; eassumption).
    destruct (execute_mario_action_preserves_real_reached_lp lp LO_mario not_tainted bm NoA MWF reached_id reached_fd m m'
                Hreach_val Hrest Hstore Hstoremwf Hbcr Hbodyrck
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
             Hreach_val Hrest Hstore Hstoremwf Hbcr Hbodyrck
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
     path goes through Hext_action/Hmwf_ext generically). THE REMAINING
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

  (* return values never alias Mario's block *)
  Hypothesis Hret_call : forall fd m0 vargs0 t0 m0' vres0,
      reached_v2 lp fd ->
      eval_funcall function_entry2 (lp_ge lp) m0 fd vargs0 t0 m0' vres0 ->
      forall b o, vres0 = Vptr b o -> b <> bm.
  Hypothesis Hret_ext : forall ef vargs0 m0 t0 vres0 m0',
      external_call ef (lp_ge lp) vargs0 m0 t0 vres0 m0' ->
      forall b o, vres0 = Vptr b o -> b <> bm.

  (* externals: the action cell + MWF survive external calls *)
  Hypothesis Hext_action :
    FieldNonInterference.reach_ext_preserves (action_cell bm) (lp_ge lp).
  Hypothesis Hmwf_ext : forall ef vargs m t vres m',
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

  (* ---- the wrapper residuals that are NOT engine-shaped (the root body's
     own provenance stores + the external meminv preservation), same shapes
     as the abstract section's. ---- *)
  Hypothesis Hrest : reach_rest_marg_lp lp bm (NoA_real bm).
  Hypothesis Hstore :
    forall e le mm a1 a2 tt le' mm' out,
      NoA_real bm mm -> RealFrameValue.prov_ok (Sassign a1 a2) ->
      exec_stmt function_entry2 (lp_ge lp) e le mm (Sassign a1 a2) tt le' mm' out ->
      NoA_real bm mm'.
  Hypothesis Hstoremwf :
    forall e le mm a1 a2 tt le' mm' out,
      NoA_real bm mm -> RealFrameValue.prov_ok (Sassign a1 a2) -> MWF mm ->
      exec_stmt function_entry2 (lp_ge lp) e le mm (Sassign a1 a2) tt le' mm' out ->
      MWF mm'.

  (* ==================================================================== *)
  (* THE V2 GROUNDED THEOREM: same conclusion as noA_no_spawn_never_       *)
  (* flying_real, but the reached set is CONCRETE and the engine contract  *)
  (* is PROVED -- the monolithic Hreach_val residual is GONE, replaced by  *)
  (* the per-cell/per-symbol surface above.                                *)
  (* ==================================================================== *)
  Theorem noA_no_spawn_never_flying_real_v2 :
    forall (init : mem) (is : list mem) (m : mem),
      mem_ok_lp lp bm MWF init ->
      Forall (fun i => a_pressed_real bm i = false) is ->
      Forall (fun i => spawn_flying i = false) is ->
      reachable mem mem (step_real lp) init is m ->
      ~ mem_flying_lp bm m.
  Proof.
    exact (noA_no_spawn_never_flying_real lp LO_mario bm MWF spawn_flying
             root_RID (reached_v2 lp)
             (reach_value_preserves_reached_v2 lp LO_mario bm SafeB
                (NoA_real bm) MWF
                Hmwf_inp Hmwf_ctl HactVint HPgms HchaseRoot HchaseStep
                HSafeNotBm Hmwf_window Hmwf_input Hmwf_glob Hmwf_chase
                Hmwf_umbi WL_exempt Hrest_pres Hret_call Hret_ext
                Hext_action Hmwf_ext Hmwf_entry Hmwf_free Hmwf_ctl)
             Hrest Hstore Hstoremwf
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
(*     Hret_ext), externals (Hext_action, Hmwf_ext), and the wrapper       *)
(*     residuals (Hrest/Hstore/Hstoremwf; the forall-ef Hext row is GONE   *)
(*     -- the body census forbids builtins, the engine refutes the case).  *)
(*                                                                        *)
(* The 24-hypothesis surface above becomes 15 here, and the initial        *)
(* condition mem_ok_lp lp bm (MWF_real ...) init is now a CHECKABLE        *)
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
       - f32_find_wall_collision: window writer (collision arg targets bm);
       - vec3f_copy / vec3s_set: object writers (dst chases m->marioObj->SafeB). *)
  Hypothesis Hocp_find_ceil :
    call_pres_ext_oc lp bm (NoA_real bm) MWF SafeB
      mario_actions_automatic._vec3f_find_ceil.
  Hypothesis Hwcp_fwc :
    call_pres_ext_wc lp bm (NoA_real bm) MWF
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
     quicksand body below. *)
  Hypothesis Hpres_sta_callees : forall fid f,
      mem_id fid stationary_callee_ids = true ->
      (prog_defmap mario_actions_stationary.prog) ! fid
        = Some (Gfun (Internal f)) ->
      body_pres lp (NoA_real bm) MWF bm f.
  (* mario_update_quicksand (mario_step.prog, pinned by LO_stp): the ONE
     out-of-TU helper the stationary/moving/object prologues call --
     WALKED (FloorsLeafSurface.qsand_pres); the proved Let is below,
     after the ext rows it consumes. *)
  (* the moving dispatcher is WALKED (MovingSurface.moving_pres; its
     two-store particleFlags epilogue is killed by the window census):
     PROVED from per-leaf-callee residuals keyed by the 39-id census
     moving_callee_ids, plus the shared quicksand body. *)
  Hypothesis Hpres_mov_callees : forall fid f,
      mem_id fid moving_callee_ids = true ->
      (prog_defmap mario_actions_moving.prog) ! fid
        = Some (Gfun (Internal f)) ->
      body_pres lp (NoA_real bm) MWF bm f.
  (* the airborne dispatcher is WALKED (AirborneSurface.airborne_pres):
     its whole-628-line-body residual is PROVED from per-leaf-callee
     residuals keyed by the 43-id census airborne_callee_ids (41 non-T
     act handlers + the 2 prologue helpers; the 3 T handlers are dead
     code under the dispatch kill). Discharge proceeds id by id. *)
  Hypothesis Hpres_air_callees : forall fid f,
      mem_id fid airborne_callee_ids = true ->
      (prog_defmap mario_actions_airborne.prog) ! fid
        = Some (Gfun (Internal f)) ->
      body_pres lp (NoA_real bm) MWF bm f.
  (* the submerged dispatcher is WALKED (SubmergedSurface.submerged_pres
     over the generic DispatchKit; the quicksandDepth store is killed by
     the window census, and the two headAngle chase-pair stores -- the
     ONLY dispatcher stores through a chased pointer -- by the MWF chase
     rows: the root load at bm@152 lands in SafeB, SafeB is bm-disjoint):
     PROVED from per-leaf-callee residuals keyed by the 33-id census
     submerged_callee_ids. *)
  Hypothesis Hpres_sub_callees : forall fid f,
      mem_id fid submerged_callee_ids = true ->
      (prog_defmap mario_actions_submerged.prog) ! fid
        = Some (Gfun (Internal f)) ->
      body_pres lp (NoA_real bm) MWF bm f.
  (* the cutscene dispatcher is WALKED (CutsceneSurface.cutscene_pres
     over the generic DispatchKit): its whole-body residual is PROVED
     from per-leaf-callee residuals keyed by the 51-id census
     cutscene_callee_ids (the prologue helper + the 50 act handlers;
     the particleFlags epilogue store is killed by the window census).
     Discharge proceeds id by id. *)
  Hypothesis Hpres_cut_callees : forall fid f,
      mem_id fid cutscene_callee_ids = true ->
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
  (* perform_ground_step (fn_vars <> nil: the walker cannot enter it
     yet) -- the named internal blocker consumed by sgs_row inside the
     B3 leaf discharge and by act_punching directly; dischargeable by
     an object-pool-aware walk *)
  Hypothesis Hcp_pgs :
    call_pres lp bm (NoA_real bm) MWF mario_step._perform_ground_step.
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
  (* vec3f_set(m->vel, 0, 0, 0) -- act_in_cannon's one special store site:
     writes ONLY through its dst = &m->vel, a 12-byte safe bm-window
     (vel @72; action cell @12 clear).  vec3f_set is EF_external in EVERY
     generated TU (no internal body anywhere) -- the same honest terminal
     external-call-model boundary as vec3f_copy above, same w1 gate. *)
  Hypothesis Hw1cp_v3fset_real :
    call_pres_ext_w1 lp bm (NoA_real bm) MWF
      mario_actions_automatic._vec3f_set.
  (* act_tornado_twirling is now WALKED (AutomaticLeafSurface's hybrid twl
     walker: the generic wwalk census + bespoke discharges for its two
     special call sites).  Its vec3f_copy(m->pos, nextPos) site rides the
     EXISTING Hw1cp_v3f_real row above; the one NEW residual is
     f32_find_wall_collision called with ALL out-ptrs aimed at the
     stack-local _nextPos elems -- the args_all_local (ol) gate, the same
     honest terminal-external class as find_wall_collisions above
     (f32_find_wall_collision is EF_external in EVERY generated TU:
     mario.v:12228, interaction.v:12264, mario_actions_automatic.v:8857). *)
  Hypothesis Holcp_f32fwc_real :
    call_pres_ext_ol lp bm (NoA_real bm) MWF SafeB
      mario_actions_automatic._f32_find_wall_collision.
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
         Hgms_blk Hgtimer_blk Htable_blk)
      (mwf_real_glob lp bm bc oc0 SafeB Hbc_bm Hglob_blk)
      (mwf_real_act_store lp bm bc oc0 SafeB Hbc_bm HSafeB_not_bm
         Hgms_blk Hgtimer_blk Htable_blk)
      SafeB HSafeB_not_bm
      (mwf_real_chase_root lp bm bc oc0 SafeB)
      (mwf_real_chase lp bm bc oc0 SafeB Hbc_bm HSafeB_not_bm
         HSafeB_not_bc Hgms_blk Hgtimer_blk Htable_blk)
      (mwf_real_root_store lp bm bc oc0 SafeB Hbc_bm HSafeB_not_bm
         Hgms_blk Hgtimer_blk Htable_blk)
      (mwf_real_sglob lp bm bc oc0 SafeB)
      (mwf_real_chase_step lp bm bc oc0 SafeB)
      (mwf_real_chase_ptr lp bm bc oc0 SafeB Hbc_bm HSafeB_not_bm
         HSafeB_not_bc Hgms_blk Hgtimer_blk Htable_blk)
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
     interaction.prog helpers, both Internal (walkable later):
       - mario_get_collided_object: marg-gated + SafeB-if-ptr RETURN (its
         result seeds the _object chase temp);
       - check_kick_or_punch_wall: the ordinary call_pres class. *)
  Hypothesis Hpres_ihandler : forall fid f,
      In fid interaction_handler_ids ->
      (prog_defmap interaction.prog) ! fid = Some (Gfun (Internal f)) ->
      body_pres_io lp bm (NoA_real bm) MWF SafeB f.
  Hypothesis Hcp_mgco_real :
    call_pres_mgco lp bm (NoA_real bm) MWF SafeB.
  Hypothesis Hcp_ckpw_real :
    call_pres lp bm (NoA_real bm) MWF
      interaction._check_kick_or_punch_wall.
  Let Hpres_inter : body_pres lp (NoA_real bm) MWF bm
      interaction.f_mario_process_interactions :=
    inter_pres lp LO_mario LO_int bm (NoA_real bm)
      (MWF_real lp bm bc oc0 SafeB) SafeB
      (mwf_real_ctl lp bm bc oc0 SafeB)
      (mwf_real_window lp bm bc oc0 SafeB Hbc_bm HSafeB_not_bm
         Hgms_blk Hgtimer_blk Htable_blk)
      (mwf_real_glob lp bm bc oc0 SafeB Hbc_bm Hglob_blk)
      (mwf_real_itab lp bm bc oc0 SafeB)
      Hcp_mgco_real Hcp_ckpw_real Hpres_ihandler.
  (* spawn_object: a TERMINAL EXTERNAL (EF_external in EVERY TU -- no
     internal body anywhere in generated/), the honest model boundary for
     the object-pool allocator.  It preserves the carried run facts, and
     its return value -- a slot of the static object pool -- is SafeB if
     a pointer at all (exactly what MWF_real's chase closure forces
     anyway: the spawned object is chase-reachable from the SafeB object
     lists). *)
  Hypothesis Hcp_spawn_real : call_pres_ext_sr lp bm (NoA_real bm) MWF SafeB
      behavior_actions._spawn_object.
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
         HSafeB_not_bc Hgms_blk Hgtimer_blk Htable_blk)
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
  Hypothesis Hret_call : forall fd m0 vargs0 t0 m0' vres0,
      reached_v2 lp fd ->
      eval_funcall function_entry2 (lp_ge lp) m0 fd vargs0 t0 m0' vres0 ->
      forall b o, vres0 = Vptr b o -> b <> bm.
  Hypothesis Hret_ext : forall ef vargs0 m0 t0 vres0 m0',
      external_call ef (lp_ge lp) vargs0 m0 t0 vres0 m0' ->
      forall b o, vres0 = Vptr b o -> b <> bm.
  Hypothesis Hext_action :
    FieldNonInterference.reach_ext_preserves (action_cell bm) (lp_ge lp).
  Hypothesis Hmwf_ext : forall ef vargs m t vres m',
      external_call ef (lp_ge lp) vargs m t vres m' ->
      Mem.valid_block m bm -> MWF m -> MWF m'.
  Hypothesis Hrest : reach_rest_marg_lp lp bm (NoA_real bm).
  Hypothesis Hstore :
    forall e le mm a1 a2 tt le' mm' out,
      NoA_real bm mm -> RealFrameValue.prov_ok (Sassign a1 a2) ->
      exec_stmt function_entry2 (lp_ge lp) e le mm (Sassign a1 a2) tt le' mm' out ->
      NoA_real bm mm'.
  Hypothesis Hstoremwf :
    forall e le mm a1 a2 tt le' mm' out,
      NoA_real bm mm -> RealFrameValue.prov_ok (Sassign a1 a2) -> MWF mm ->
      exec_stmt function_entry2 (lp_ge lp) e le mm (Sassign a1 a2) tt le' mm' out ->
      MWF mm'.

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

  (* ==================================================================== *)
  (* THE MWF-GROUNDED THEOREM: same conclusion as the v2 capstone, but    *)
  (* the carried invariant is the concrete MWF_real -- its 14 projection/ *)
  (* stability hypotheses are PROVED, not assumed.                        *)
  (* ==================================================================== *)
  Theorem noA_no_spawn_never_flying_real_mwf :
    forall (init : mem) (is : list mem) (m : mem),
      mem_ok_lp lp bm MWF init ->
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
             (mwf_real_window lp bm bc oc0 SafeB Hbc_bm HSafeB_not_bm Hgms_blk Hgtimer_blk Htable_blk)
             (mwf_real_input lp bm bc oc0 SafeB Hbc_bm HSafeB_not_bm Hgms_blk Hgtimer_blk Htable_blk)
             (mwf_real_glob lp bm bc oc0 SafeB Hbc_bm Hglob_blk)
             (mwf_real_chase lp bm bc oc0 SafeB Hbc_bm HSafeB_not_bm
                HSafeB_not_bc Hgms_blk Hgtimer_blk Htable_blk)
             (mwf_real_umbi lp bm bc oc0 SafeB Hbc_bm HSafeB_not_bm Hgms_blk Hgtimer_blk Htable_blk)
             WL_exempt
             (rest_pres_decompose lp LO_sta LO_mov LO_air LO_sub LO_cut
                LO_aut LO_obj LO_int LO_beh LO_lvl LO_stp Hrest_ext_only
                (NoA_real bm) (MWF_real lp bm bc oc0 SafeB) bm
                (stationary_pres lp LO_mario LO_sta LO_stp bm (NoA_real bm)
                   (MWF_real lp bm bc oc0 SafeB)
                   (mwf_real_ctl lp bm bc oc0 SafeB)
                   (mwf_real_window lp bm bc oc0 SafeB Hbc_bm HSafeB_not_bm
                      Hgms_blk Hgtimer_blk Htable_blk)
                   Hpres_sta_callees Hpres_qsand)
                (moving_pres lp LO_mario LO_mov LO_stp bm (NoA_real bm)
                   (MWF_real lp bm bc oc0 SafeB)
                   (mwf_real_ctl lp bm bc oc0 SafeB)
                   (mwf_real_window lp bm bc oc0 SafeB Hbc_bm HSafeB_not_bm
                      Hgms_blk Hgtimer_blk Htable_blk)
                   Hpres_mov_callees Hpres_qsand)
                (airborne_pres lp LO_mario LO_air bm (NoA_real bm)
                   (MWF_real lp bm bc oc0 SafeB)
                   (mwf_real_ctl lp bm bc oc0 SafeB)
                   Hpres_air_callees)
                (submerged_pres lp LO_mario LO_sub bm (NoA_real bm)
                   (MWF_real lp bm bc oc0 SafeB) SafeB
                   (mwf_real_ctl lp bm bc oc0 SafeB)
                   (mwf_real_window lp bm bc oc0 SafeB Hbc_bm HSafeB_not_bm
                      Hgms_blk Hgtimer_blk Htable_blk)
                   HSafeB_not_bm
                   (mwf_real_chase_root lp bm bc oc0 SafeB)
                   (mwf_real_chase lp bm bc oc0 SafeB Hbc_bm HSafeB_not_bm
                      HSafeB_not_bc Hgms_blk Hgtimer_blk Htable_blk)
                   Hpres_sub_callees)
                (cutscene_pres lp LO_mario LO_cut bm (NoA_real bm)
                   (MWF_real lp bm bc oc0 SafeB)
                   (mwf_real_ctl lp bm bc oc0 SafeB)
                   (mwf_real_window lp bm bc oc0 SafeB Hbc_bm HSafeB_not_bm
                      Hgms_blk Hgtimer_blk Htable_blk)
                   Hpres_cut_callees)
                (automatic_pres lp LO_mario LO_aut bm (NoA_real bm)
                   (MWF_real lp bm bc oc0 SafeB)
                   (mwf_real_ctl lp bm bc oc0 SafeB)
                   (mwf_real_window lp bm bc oc0 SafeB Hbc_bm HSafeB_not_bm
                      Hgms_blk Hgtimer_blk Htable_blk)
                   (automatic_leaf_callees_pres lp LO_mario LO_stp LO_aut bm
                      (NoA_real bm)
                      (MWF_real lp bm bc oc0 SafeB)
                      (mwf_real_ctl lp bm bc oc0 SafeB)
                      (mwf_real_window lp bm bc oc0 SafeB Hbc_bm
                         HSafeB_not_bm Hgms_blk Hgtimer_blk Htable_blk)
                      (mwf_real_glob lp bm bc oc0 SafeB Hbc_bm Hglob_blk)
                      (mwf_real_act_store lp bm bc oc0 SafeB Hbc_bm
                         HSafeB_not_bm Hgms_blk Hgtimer_blk Htable_blk)
                      SafeB HSafeB_not_bm
                      (mwf_real_chase_root lp bm bc oc0 SafeB)
                      (mwf_real_chase lp bm bc oc0 SafeB Hbc_bm
                         HSafeB_not_bm HSafeB_not_bc Hgms_blk Hgtimer_blk Htable_blk)
                      (mwf_real_root_store lp bm bc oc0 SafeB Hbc_bm
                         HSafeB_not_bm Hgms_blk Hgtimer_blk Htable_blk)
                      (mwf_real_sglob lp bm bc oc0 SafeB)
                      (mwf_real_chase_step lp bm bc oc0 SafeB)
                      (mwf_real_chase_ptr lp bm bc oc0 SafeB Hbc_bm
                         HSafeB_not_bm HSafeB_not_bc Hgms_blk Hgtimer_blk Htable_blk)
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
                      Hwcp_fwc
                      Hscp_v3f
                      Hscp_v3s
                      (* tornado: f32_find_wall_collision's stack-local
                         (&nextPos[i]) call shape -- the ol gate *)
                      Holcp_f32fwc_real
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
                      Hgms_blk Hgtimer_blk Htable_blk)
                   (object_callees_pres lp LO_mario LO_stp LO_int LO_obj bm
                      (NoA_real bm)
                      (MWF_real lp bm bc oc0 SafeB)
                      (mwf_real_ctl lp bm bc oc0 SafeB)
                      (mwf_real_window lp bm bc oc0 SafeB Hbc_bm
                         HSafeB_not_bm Hgms_blk Hgtimer_blk Htable_blk)
                      (mwf_real_glob lp bm bc oc0 SafeB Hbc_bm Hglob_blk)
                      (mwf_real_act_store lp bm bc oc0 SafeB Hbc_bm
                         HSafeB_not_bm Hgms_blk Hgtimer_blk Htable_blk)
                      SafeB HSafeB_not_bm
                      (mwf_real_chase_root lp bm bc oc0 SafeB)
                      (mwf_real_chase lp bm bc oc0 SafeB Hbc_bm
                         HSafeB_not_bm HSafeB_not_bc Hgms_blk Hgtimer_blk Htable_blk)
                      (mwf_real_root_store lp bm bc oc0 SafeB Hbc_bm
                         HSafeB_not_bm Hgms_blk Hgtimer_blk Htable_blk)
                      (mwf_real_sglob lp bm bc oc0 SafeB)
                      (mwf_real_chase_step lp bm bc oc0 SafeB)
                      (mwf_real_chase_ptr lp bm bc oc0 SafeB Hbc_bm
                         HSafeB_not_bm HSafeB_not_bc Hgms_blk
                         Hgtimer_blk Htable_blk)
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
                      Hgms_blk Hgtimer_blk Htable_blk)
                   (mwf_real_glob lp bm bc oc0 SafeB Hbc_bm Hglob_blk)
                   (floors_callees_pres lp LO_mario LO_stp LO_int LO_lvl bm
                      (NoA_real bm)
                      (MWF_real lp bm bc oc0 SafeB)
                      (mwf_real_ctl lp bm bc oc0 SafeB)
                      (mwf_real_window lp bm bc oc0 SafeB Hbc_bm
                         HSafeB_not_bm Hgms_blk Hgtimer_blk Htable_blk)
                      (mwf_real_glob lp bm bc oc0 SafeB Hbc_bm Hglob_blk)
                      (mwf_real_act_store lp bm bc oc0 SafeB Hbc_bm
                         HSafeB_not_bm Hgms_blk Hgtimer_blk Htable_blk)
                      SafeB HSafeB_not_bm
                      (mwf_real_chase_root lp bm bc oc0 SafeB)
                      (mwf_real_chase lp bm bc oc0 SafeB Hbc_bm
                         HSafeB_not_bm HSafeB_not_bc Hgms_blk Hgtimer_blk Htable_blk)
                      (mwf_real_root_store lp bm bc oc0 SafeB Hbc_bm
                         HSafeB_not_bm Hgms_blk Hgtimer_blk Htable_blk)
                      (mwf_real_sglob lp bm bc oc0 SafeB)
                      (mwf_real_chase_step lp bm bc oc0 SafeB)
                      (mwf_real_chase_ptr lp bm bc oc0 SafeB Hbc_bm
                         HSafeB_not_bm HSafeB_not_bc Hgms_blk
                         Hgtimer_blk Htable_blk)
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
                            HSafeB_not_bm Hgms_blk Hgtimer_blk Htable_blk)
                         (mwf_real_glob lp bm bc oc0 SafeB Hbc_bm
                            Hglob_blk)
                         Hpres_warp_ext))
                   (warp_pres lp LO_mario LO_lvl bm (NoA_real bm)
                      (MWF_real lp bm bc oc0 SafeB)
                      (mwf_real_ctl lp bm bc oc0 SafeB)
                      (mwf_real_window lp bm bc oc0 SafeB Hbc_bm
                         HSafeB_not_bm Hgms_blk Hgtimer_blk Htable_blk)
                      (mwf_real_glob lp bm bc oc0 SafeB Hbc_bm Hglob_blk)
                      Hpres_warp_ext))
                Hpres_inter Hpres_wind
                (warp_pres lp LO_mario LO_lvl bm (NoA_real bm)
                   (MWF_real lp bm bc oc0 SafeB)
                   (mwf_real_ctl lp bm bc oc0 SafeB)
                   (mwf_real_window lp bm bc oc0 SafeB Hbc_bm HSafeB_not_bm
                      Hgms_blk Hgtimer_blk Htable_blk)
                   (mwf_real_glob lp bm bc oc0 SafeB Hbc_bm Hglob_blk)
                   Hpres_warp_ext))
             Hret_call Hret_ext Hext_action Hmwf_ext
             (mwf_real_entry lp bm bc oc0 SafeB Hbc_bm)
             (mwf_real_free lp bm bc oc0 SafeB Hbc_bm)
             Hrest Hstore Hstoremwf).
  Qed.

End NoARealInputMWF.
