(* ====================================================================== *)
(* THE REST SURFACE, DECOMPOSED PER SYMBOL (SPINE: consumed by the         *)
(* MWF-grounded capstone).                                                 *)
(*                                                                        *)
(* The consumer's Hrest_pres residual quantifies over WHATEVER Internal    *)
(* body lp resolves a rest symbol to -- for an abstract lp that is an      *)
(* adversarial unknown. This file pins it down:                            *)
(*                                                                        *)
(*  - ELEVEN per-TU linkorder pins (the 7 action TUs + interaction +       *)
(*    behavior_actions + level_update + mario_step) -- the same class of   *)
(*    hypothesis as LO_mario, each discharged at final link time by        *)
(*    link_linkorder. Under a pin, a rest symbol's Internal resolution     *)
(*    is THE real generated body (resolves_pin: find_symbol/find_funct    *)
(*    are functional, so the pinned existence forces uniqueness).          *)
(*  - ONE negative pin (Hrest_ext_only): the exempt whitelist + the        *)
(*    music helper stay External in lp. Satisfiable for the intended      *)
(*    12-TU link: none of the generated TUs defines any of those symbols  *)
(*    internally (checked: no `Definition f_<sym>` anywhere under          *)
(*    generated/), and a link of agreeing Externals is that External.     *)
(*                                                                        *)
(* PAYOFF (rest_pres_decompose): the whole-surface residual becomes a      *)
(* 12-way case split over CONCRETE generated bodies -- and the stub        *)
(* (f_stub_mario_step_1, body = Sskip) is discharged outright, leaving    *)
(* ELEVEN named per-real-body preservation residuals. Each survivor is a  *)
(* statement about ONE clightgen'd AST object, dischargeable by the       *)
(* engine-v2 census walk over that TU (where the A-gating taint closure   *)
(* of Taint.v/AGates.v gets consumed).                                    *)
(* ====================================================================== *)

From Coq Require Import ZArith List.
From compcert Require Import Coqlib Maps AST Integers Values Events Memory
  Globalenvs Ctypes Cop Clightdefs Clight ClightBigstep Linking.
From SM64.Generated Require mario mario_actions_stationary
  mario_actions_moving mario_actions_airborne mario_actions_submerged
  mario_actions_cutscene mario_actions_automatic mario_actions_object
  interaction behavior_actions level_update mario_step.
From SM64.Proofs Require Import SymbolicLinking Flying Taint
  ActionValueFrame RealFrameValue RealFrameLinked AGates.
From SM64.Proofs Require Import CensusV2 EngineV2Consumer.

Import ListNotations.

Section RestSurface.
  Variable lp : Clight.program.

  (* ---- the per-TU linkorder pins (LO_mario's class; link-time facts) ---- *)
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

  (* ---- the negative pin: whitelisted math/runtime symbols + the music
     helper have NO Internal resolution in lp (they stay External in the
     intended 12-TU link; no generated TU carries a body for any of them) ---- *)
  Hypothesis Hrest_ext_only : forall fid f,
      mem_id fid exempt_callees = true \/
      fid = mario._play_infinite_stairs_music ->
      ~ resolves_lp lp fid (Internal f).

  (* uniqueness direction of the per-symbol resolution: the pinned
     existence (linkorder_resolves_funct) + functionality of
     find_symbol/find_funct force any Internal resolution of the symbol
     to BE the pinned body. *)
  Lemma resolves_pin :
    forall (q : Clight.program) (fid : ident) (f_real f : Clight.function),
      linkorder q lp ->
      (prog_defmap q) ! fid = Some (Gfun (Internal f_real)) ->
      resolves_lp lp fid (Internal f) ->
      f = f_real.
  Proof.
    intros q fid f_real f LOq Hdm Hres.
    destruct Hres as (b & Hsym & Hff).
    destruct (linkorder_resolves_funct lp q fid f_real LOq Hdm)
      as (b' & Hsym' & Hff').
    unfold lp_ge in Hsym, Hff.
    rewrite Hsym in Hsym'. injection Hsym' as <-.
    rewrite Hff in Hff'. injection Hff' as Hf. exact Hf.
  Qed.

  (* THE CASE SPLIT: a rest symbol's Internal resolution is one of the
     TWELVE real generated bodies. *)
  Lemma rest_internal_cases :
    forall f,
      rest_fd lp (Internal f) ->
      f = mario_actions_stationary.f_mario_execute_stationary_action \/
      f = mario_actions_moving.f_mario_execute_moving_action \/
      f = mario_actions_airborne.f_mario_execute_airborne_action \/
      f = mario_actions_submerged.f_mario_execute_submerged_action \/
      f = mario_actions_cutscene.f_mario_execute_cutscene_action \/
      f = mario_actions_automatic.f_mario_execute_automatic_action \/
      f = mario_actions_object.f_mario_execute_object_action \/
      f = interaction.f_mario_handle_special_floors \/
      f = interaction.f_mario_process_interactions \/
      f = behavior_actions.f_spawn_wind_particles \/
      f = level_update.f_level_trigger_warp \/
      f = mario_step.f_stub_mario_step_1.
  Proof.
    intros f (fid & Hmem & Hres).
    destruct Hmem as [Hex | [Hroot | Hmptr]].
    - (* exempt whitelist: refuted by the negative pin *)
      exfalso. exact (Hrest_ext_only fid f (or_introl Hex) Hres).
    - (* the root's residual callees: 10 pinned bodies + the refuted music *)
      unfold mem_id, root_residual_callees in Hroot.
      cbn [existsb] in Hroot.
      repeat (apply orb_true_iff in Hroot; destruct Hroot as [H | Hroot]);
        try discriminate Hroot; apply Pos.eqb_eq in H; subst fid.
      + left.
        eapply resolves_pin; [ exact LO_sta | | exact Hres ]; vm_compute; reflexivity.
      + do 1 right; left.
        eapply resolves_pin; [ exact LO_mov | | exact Hres ]; vm_compute; reflexivity.
      + do 2 right; left.
        eapply resolves_pin; [ exact LO_air | | exact Hres ]; vm_compute; reflexivity.
      + do 3 right; left.
        eapply resolves_pin; [ exact LO_sub | | exact Hres ]; vm_compute; reflexivity.
      + do 4 right; left.
        eapply resolves_pin; [ exact LO_cut | | exact Hres ]; vm_compute; reflexivity.
      + do 5 right; left.
        eapply resolves_pin; [ exact LO_aut | | exact Hres ]; vm_compute; reflexivity.
      + do 6 right; left.
        eapply resolves_pin; [ exact LO_obj | | exact Hres ]; vm_compute; reflexivity.
      + do 7 right; left.
        eapply resolves_pin; [ exact LO_int | | exact Hres ]; vm_compute; reflexivity.
      + do 8 right; left.
        eapply resolves_pin; [ exact LO_int | | exact Hres ]; vm_compute; reflexivity.
      + do 9 right; left.
        eapply resolves_pin; [ exact LO_beh | | exact Hres ]; vm_compute; reflexivity.
      + (* play_infinite_stairs_music: refuted by the negative pin *)
        exfalso. exact (Hrest_ext_only _ f (or_intror eq_refl) Hres).
    - (* the two MarioState*-taking externals of mario.prog *)
      unfold mem_id, mptr_external_callees in Hmptr.
      cbn [existsb] in Hmptr.
      repeat (apply orb_true_iff in Hmptr; destruct Hmptr as [H | Hmptr]);
        try discriminate Hmptr; apply Pos.eqb_eq in H; subst fid.
      + do 11 right.
        eapply resolves_pin; [ exact LO_stp | | exact Hres ]; vm_compute; reflexivity.
      + do 10 right; left.
        eapply resolves_pin; [ exact LO_lvl | | exact Hres ]; vm_compute; reflexivity.
  Qed.

  (* the per-body residual shape: ONE real generated body preserves the
     carried run facts across its whole funcall. *)
  Definition body_pres (NoA MWF : mem -> Prop) (bm : block)
                       (f : Clight.function) : Prop :=
    forall m vargs t m' vres,
      (marg_exempt (Internal f) = false -> marg_ok bm vargs) ->
      eval_funcall function_entry2 (lp_ge lp) m (Internal f) vargs t m' vres ->
      NoA m -> MWF m -> Mem.valid_block m bm ->
      action_sat not_tainted m bm ->
      Mem.valid_block m' bm /\ action_sat not_tainted m' bm /\ MWF m'.

  (* the sargs-gated twin, for a body whose WHOLE signature is sub-32-bit
     integer (spawn_wind_particles: (tshort, tshort)).  For such a body
     plain body_pres is a forall-vargs PHANTOM -- and in wind's case FALSE:
     an adversarial Vptr yaw/pitch would be stored raw into the SafeB
     spawned-object block (ptr32 cast_case_pointer passes a Vptr through
     the inline s32 store cast), breaking MWF_real's chase closure.  The
     honest residual carries the signature-derived Vint gate, which EVERY
     real call site satisfies (the engine's Scall case discharges it from
     the exec_Scall type_of_fundef pin). *)
  Definition body_pres_s (NoA MWF : mem -> Prop) (bm : block)
                         (f : Clight.function) : Prop :=
    forall m vargs t m' vres,
      (marg_exempt (Internal f) = false -> marg_ok bm vargs) ->
      sargs_ok (Internal f) vargs ->
      eval_funcall function_entry2 (lp_ge lp) m (Internal f) vargs t m' vres ->
      NoA m -> MWF m -> Mem.valid_block m bm ->
      action_sat not_tainted m bm ->
      Mem.valid_block m' bm /\ action_sat not_tainted m' bm /\ MWF m'.

  (* the stub, DISCHARGED: body = Sskip, no vars -- the funcall is the
     identity on memory (entry allocates nothing, free frees nothing). *)
  Lemma stub_pres :
    forall (NoA MWF : mem -> Prop) (bm : block),
      body_pres NoA MWF bm mario_step.f_stub_mario_step_1.
  Proof.
    intros NoA MWF bm m vargs t m' vres _ Hevf Hno Hmwf Hv Hsat.
    inv Hevf.
    match goal with
    | He : function_entry2 _ _ _ _ _ _ _ |- _ => rename He into Hentry
    end.
    match goal with
    | Hx : exec_stmt _ _ _ _ _ _ _ _ _ _ |- _ => rename Hx into Hexec
    end.
    match goal with
    | Hf : Mem.free_list _ _ = Some _ |- _ => rename Hf into Hfree
    end.
    (* entry allocates fn_vars = nil: e = empty_env, memory untouched *)
    inv Hentry.
    match goal with
    | Ha : alloc_variables _ _ _ _ _ _ |- _ =>
        change (fn_vars mario_step.f_stub_mario_step_1)
          with (@nil (ident * type)) in Ha;
        inv Ha
    end.
    (* the body is Sskip: memory and outcome unchanged *)
    change (fn_body mario_step.f_stub_mario_step_1) with Sskip in Hexec.
    inv Hexec.
    (* exit frees blocks_of_env of the empty env: nothing *)
    change (blocks_of_env (lp_ge lp) empty_env)
      with (@nil (block * Z * Z)) in Hfree.
    cbn [Mem.free_list] in Hfree.
    injection Hfree as <-.
    exact (conj Hv (conj Hsat Hmwf)).
  Qed.

  (* THE DECOMPOSITION: the consumer's whole-surface Hrest_pres from the
     ELEVEN per-real-body residuals (the stub is proved). *)
  Lemma rest_pres_decompose :
    forall (NoA MWF : mem -> Prop) (bm : block),
      body_pres NoA MWF bm
        mario_actions_stationary.f_mario_execute_stationary_action ->
      body_pres NoA MWF bm
        mario_actions_moving.f_mario_execute_moving_action ->
      body_pres NoA MWF bm
        mario_actions_airborne.f_mario_execute_airborne_action ->
      body_pres NoA MWF bm
        mario_actions_submerged.f_mario_execute_submerged_action ->
      body_pres NoA MWF bm
        mario_actions_cutscene.f_mario_execute_cutscene_action ->
      body_pres NoA MWF bm
        mario_actions_automatic.f_mario_execute_automatic_action ->
      body_pres NoA MWF bm
        mario_actions_object.f_mario_execute_object_action ->
      body_pres NoA MWF bm interaction.f_mario_handle_special_floors ->
      body_pres NoA MWF bm interaction.f_mario_process_interactions ->
      body_pres_s NoA MWF bm behavior_actions.f_spawn_wind_particles ->
      body_pres NoA MWF bm level_update.f_level_trigger_warp ->
      forall m f vargs t m' vres,
        rest_fd lp (Internal f) ->
        (marg_exempt (Internal f) = false -> marg_ok bm vargs) ->
        sargs_ok (Internal f) vargs ->
        eval_funcall function_entry2 (lp_ge lp) m (Internal f) vargs t m' vres ->
        NoA m -> MWF m -> Mem.valid_block m bm ->
        action_sat not_tainted m bm ->
        Mem.valid_block m' bm /\ action_sat not_tainted m' bm /\ MWF m'.
  Proof.
    intros NoA MWF bm Hsta Hmov Hair Hsub Hcut Haut Hobj Hflo Hint Hwnd Hwrp
           m f vargs t m' vres Hrest Hmarg Hsargs Hevf Hno Hmwf Hv Hsat.
    destruct (rest_internal_cases f Hrest) as
      [-> | [-> | [-> | [-> | [-> | [-> | [-> | [-> | [-> | [-> | [-> | ->]]]]]]]]]]].
    - exact (Hsta m vargs t m' vres Hmarg Hevf Hno Hmwf Hv Hsat).
    - exact (Hmov m vargs t m' vres Hmarg Hevf Hno Hmwf Hv Hsat).
    - exact (Hair m vargs t m' vres Hmarg Hevf Hno Hmwf Hv Hsat).
    - exact (Hsub m vargs t m' vres Hmarg Hevf Hno Hmwf Hv Hsat).
    - exact (Hcut m vargs t m' vres Hmarg Hevf Hno Hmwf Hv Hsat).
    - exact (Haut m vargs t m' vres Hmarg Hevf Hno Hmwf Hv Hsat).
    - exact (Hobj m vargs t m' vres Hmarg Hevf Hno Hmwf Hv Hsat).
    - exact (Hflo m vargs t m' vres Hmarg Hevf Hno Hmwf Hv Hsat).
    - exact (Hint m vargs t m' vres Hmarg Hevf Hno Hmwf Hv Hsat).
    - exact (Hwnd m vargs t m' vres Hmarg Hsargs Hevf Hno Hmwf Hv Hsat).
    - exact (Hwrp m vargs t m' vres Hmarg Hevf Hno Hmwf Hv Hsat).
    - exact (stub_pres NoA MWF bm m vargs t m' vres Hmarg Hevf
               Hno Hmwf Hv Hsat).
  Qed.

End RestSurface.
