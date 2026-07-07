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

(* ====================================================================== *)
(* THE #95 REPAIR (2026-07-05).  vec3f_find_ceil is an INTERNAL function   *)
(* of mario.prog (mario.c:547) yet sat on the exempt whitelist, making    *)
(* the old negative pin REFUTABLE for every twelve-TU link                 *)
(* (LinkedTwelve.capstone_negative_pin_refuted) and the real_mwf capstone  *)
(* vacuous.  The pin now covers only the SIXTEEN genuinely-external ids   *)
(* (exempt_ext_ids); vec3f_find_ceil becomes a THIRTEENTH pinned real     *)
(* body whose preservation is PROVED below (vfc_pres) from existing trust *)
(* only: its body performs no stores -- two loads through the pos param   *)
(* and one call to find_ceil, which stays External.                       *)
(* ====================================================================== *)

Definition exempt_ext_ids : list ident :=
  filter (fun i => negb (Pos.eqb i mario._vec3f_find_ceil)) exempt_callees.

Lemma mem_id_filter_neq : forall fid bad l,
    Pos.eqb fid bad = false ->
    mem_id fid (filter (fun i => negb (Pos.eqb i bad)) l) = mem_id fid l.
Proof.
  intros fid bad l Hne. unfold mem_id in *.
  induction l as [| a l IH]; [ reflexivity | ].
  cbn [filter]. destruct (Pos.eqb a bad) eqn:Eab.
  - apply Pos.eqb_eq in Eab. subst a.
    cbn [negb existsb]. rewrite Hne, IH. reflexivity.
  - cbn [negb existsb]. rewrite IH. reflexivity.
Qed.

Lemma exempt_split : forall fid,
    mem_id fid exempt_callees = true ->
    fid = mario._vec3f_find_ceil \/ mem_id fid exempt_ext_ids = true.
Proof.
  intros fid Hmem.
  destruct (Pos.eqb fid mario._vec3f_find_ceil) eqn:E.
  - left. apply Pos.eqb_eq. exact E.
  - right. unfold exempt_ext_ids. rewrite mem_id_filter_neq by exact E.
    exact Hmem.
Qed.

Lemma mario_defmap_vfc :
  (prog_defmap mario.prog) ! mario._vec3f_find_ceil
    = Some (Gfun (Internal mario.f_vec3f_find_ceil)).
Proof. vm_compute. reflexivity. Qed.

Lemma find_ceil_in_ext :
  mem_id mario._find_ceil exempt_ext_ids = true.
Proof. vm_compute. reflexivity. Qed.

Lemma find_ceil_in_exempt :
  mem_id mario._find_ceil exempt_callees = true.
Proof. vm_compute. reflexivity. Qed.

(* generic frame: freeing bm-distinct blocks preserves validity + the
   action-cell fact *)
Lemma vfc_free_list_frame :
  forall (Q : int -> Prop) bm l m m',
    Forall (fun blh => let '(b,_,_) := blh in b <> bm) l ->
    Mem.free_list m l = Some m' ->
    Mem.valid_block m bm -> action_sat Q m bm ->
    Mem.valid_block m' bm /\ action_sat Q m' bm.
Proof.
  intros Q bm l. induction l as [| [[b lo] hi] l IH]; intros m m' Hall Hfl Hv Hs.
  - cbn [Mem.free_list] in Hfl. injection Hfl as <-. split; assumption.
  - cbn [Mem.free_list] in Hfl.
    destruct (Mem.free m b lo hi) as [ m1 | ] eqn:Hf; [ | discriminate Hfl ].
    inversion Hall as [| ? ? Hhd Htl ]; subst.
    assert (Hv1 : Mem.valid_block m1 bm)
      by (eapply Mem.valid_block_free_1; eauto).
    assert (Hs1 : action_sat Q m1 bm).
    { unfold action_sat in *. intros v Hld. apply Hs.
      rewrite <- Hld. symmetry.
      eapply Mem.load_unchanged_on_1
        with (P := fun bb o => bb = bm /\ 12 <= o < 12 + size_chunk Mint32);
        [ eapply Mem.free_unchanged_on; [ exact Hf | ]
        | exact Hv
        | intros i Hi; split; [ reflexivity | exact Hi ] ].
      intros i Hi [Hb _]; subst b; exact (Hhd eq_refl). }
    exact (IH m1 m' Htl Hfl Hv1 Hs1).
Qed.

Lemma blocks_of_env_filler : forall ge bfil,
  blocks_of_env ge (PTree.set mario._filler (bfil, tarray tuchar 4) empty_env)
    = (bfil, 0, sizeof ge (tarray tuchar 4)) :: nil.
Proof.
  intros ge bfil. unfold blocks_of_env.
  replace (PTree.elements (PTree.set mario._filler (bfil, tarray tuchar 4) empty_env))
    with ((mario._filler, (bfil, tarray tuchar 4)) :: (@nil (positive * (block*type))))
    by (vm_compute; reflexivity).
  cbn [map block_of_binding]. reflexivity.
Qed.

Section RestSurface.
  Variable lp : Clight.program.

  (* ---- the per-TU linkorder pins (link-time facts).  LO_mario is now
     needed HERE too: it pins the thirteenth internal case,
     vec3f_find_ceil's real mario.prog body. ---- *)
  Hypothesis LO_mario : linkorder mario.prog lp.
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
      mem_id fid exempt_ext_ids = true \/
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
      f = mario_step.f_stub_mario_step_1 \/
      f = mario.f_vec3f_find_ceil.
  Proof.
    intros f (fid & Hmem & Hres).
    destruct Hmem as [Hex | [Hroot | Hmptr]].
    - (* exempt whitelist: vec3f_find_ceil is PINNED to mario's real body
         (the #95 repair); the sixteen others are refuted by the pin *)
      destruct (exempt_split _ Hex) as [-> | Hex'].
      + do 12 right.
        eapply resolves_pin; [ exact LO_mario | exact mario_defmap_vfc | exact Hres ].
      + exfalso. exact (Hrest_ext_only fid f (or_introl Hex') Hres).
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
      + do 11 right; left.
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
      body_pres NoA MWF bm mario.f_vec3f_find_ceil ->
      forall m f vargs t m' vres,
        rest_fd lp (Internal f) ->
        (marg_exempt (Internal f) = false -> marg_ok bm vargs) ->
        sargs_ok (Internal f) vargs ->
        eval_funcall function_entry2 (lp_ge lp) m (Internal f) vargs t m' vres ->
        NoA m -> MWF m -> Mem.valid_block m bm ->
        action_sat not_tainted m bm ->
        Mem.valid_block m' bm /\ action_sat not_tainted m' bm /\ MWF m'.
  Proof.
    intros NoA MWF bm Hsta Hmov Hair Hsub Hcut Haut Hobj Hflo Hint Hwnd Hwrp Hvfc
           m f vargs t m' vres Hrest Hmarg Hsargs Hevf Hno Hmwf Hv Hsat.
    destruct (rest_internal_cases f Hrest) as
      [-> | [-> | [-> | [-> | [-> | [-> | [-> | [-> | [-> | [-> | [-> | [-> | ->]]]]]]]]]]]].
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
    - exact (Hvfc m vargs t m' vres Hmarg Hevf Hno Hmwf Hv Hsat).
  Qed.

  (* THE THIRTEENTH BODY, WALKED (the #95 repair): vec3f_find_ceil's real
     mario.prog body performs NO stores of its own -- two loads through the
     pos param, one call to find_ceil (which the repaired pin keeps
     External, so the blanket reached-external rows cover it), and a
     return.  ZERO new trust: the premises below are the capstone's
     existing alloc/free bricks, the repaired pin's find_ceil instance,
     and its Hext_action / Hmwf_ext rows. *)
  Lemma vfc_pres :
    forall (NoA MWF : mem -> Prop) (bm : block),
      (forall m lo hi m' b, Mem.alloc m lo hi = (m', b) -> MWF m -> MWF m') ->
      (forall m2 m3 l, Mem.free_list m2 l = Some m3 -> MWF m2 -> MWF m3) ->
      (forall f, ~ resolves_lp lp mario._find_ceil (Internal f)) ->
      (forall ef targs tres cc vargs m t vres m',
          resolves_lp lp mario._find_ceil (External ef targs tres cc) ->
          external_call ef (lp_ge lp) vargs m t vres m' ->
          Mem.unchanged_on (action_cell bm) m m') ->
      (forall ef targs tres cc vargs m t vres m',
          resolves_lp lp mario._find_ceil (External ef targs tres cc) ->
          external_call ef (lp_ge lp) vargs m t vres m' ->
          Mem.valid_block m bm -> MWF m -> MWF m') ->
      body_pres NoA MWF bm mario.f_vec3f_find_ceil.
  Proof.
    intros NoA MWF bm Halloc Hfree Hnint Hext_act Hext_mwf.
    unfold body_pres.
    intros m vargs t m' vres _ Hevf Hno Hmwf Hv Hsat.
    unfold mario.f_vec3f_find_ceil in Hevf.
    inv Hevf.
    match goal with He : function_entry2 _ _ _ _ _ _ _ |- _ => rename He into Hentry end.
    match goal with Hx : exec_stmt _ _ _ _ _ _ _ _ _ _ |- _ => rename Hx into Hexec end.
    match goal with Hf : Mem.free_list _ _ = Some _ |- _ => rename Hf into Hfl end.
    (* ENTRY: one alloc of the filler *)
    inv Hentry.
    match goal with Ha : alloc_variables _ _ _ _ _ _ |- _ =>
      cbn [fn_vars] in Ha; inv Ha end.
    match goal with Ha : alloc_variables _ _ _ nil _ _ |- _ => inv Ha end.
    match goal with Hal : Mem.alloc _ _ _ = _ |- _ => rename Hal into Halc end.
    (* entry facts *)
    match goal with Halc : Mem.alloc _ _ _ = (?mA, ?bfil) |- _ =>
      assert (HmwfA : MWF mA) by (eapply Halloc; [ exact Halc | exact Hmwf ]);
      assert (HvA : Mem.valid_block mA bm)
        by (eapply Mem.valid_block_alloc; [ exact Halc | exact Hv ]);
      assert (Hunch_al : Mem.unchanged_on (action_cell bm) m mA)
        by (eapply Mem.alloc_unchanged_on; exact Halc);
      assert (Hbfil_ne : bfil <> bm)
        by (intro EE; subst bfil;
            exact (Mem.fresh_block_alloc _ _ _ _ _ Halc Hv));
      assert (HsatA : action_sat not_tainted mA bm)
        by (eapply action_sat_unchanged_on; [ exact Hunch_al | exact Hv | exact Hsat ])
    end.
    (* BODY: Ssequence (Sset; (Sset; Scall)) (Sreturn _t'1).
       Case A (exec_Sseq_1): walk the calls; case B (exec_Sseq_2): the
       inner statements only ever produce Out_normal -- contradiction. *)
    cbn [fn_body] in Hexec.
    assert (Hne_ids : mario._find_ceil <> mario._filler)
      by (intro EE; vm_compute in EE; discriminate EE).
    inv Hexec.
    - (* outer seq_1: inner part normal, then the Sreturn *)
      match goal with
      | Hs : exec_stmt _ _ _ _ _ (Ssequence _ _) _ _ _ Out_normal |- _ =>
          rename Hs into Hinner
      end.
      match goal with
      | Hr : exec_stmt _ _ _ _ _ (Sreturn _) _ _ _ _ |- _ => rename Hr into Hret
      end.
      inv Hinner.
      + (* inner seq_1: Sset _t'2 normal, then (Sset _t'3; Scall) *)
        match goal with
        | Hs : exec_stmt _ _ _ _ _ (Sset mario._t'2 _) _ _ _ _ |- _ =>
            rename Hs into Hset2
        end.
        match goal with
        | Hs : exec_stmt _ _ _ _ _ (Ssequence _ _) _ _ _ Out_normal |- _ =>
            rename Hs into Hinner2
        end.
        inv Hset2.
        inv Hinner2.
        * (* Sset _t'3 normal, then the Scall *)
          match goal with
          | Hs : exec_stmt _ _ _ _ _ (Sset mario._t'3 _) _ _ _ _ |- _ =>
              rename Hs into Hset3
          end.
          match goal with
          | Hs : exec_stmt _ _ _ _ _ (Scall _ _ _) _ _ _ _ |- _ =>
              rename Hs into Hcall
          end.
          inv Hset3.
          inv Hcall.
          match goal with
          | He : eval_expr _ _ _ _ (Evar mario._find_ceil _) _ |- _ =>
              rename He into Hevf_fc
          end.
          match goal with
          | Hf : eval_funcall _ _ _ _ _ _ _ _ |- _ => rename Hf into Hfc_call
          end.
          match goal with
          | Hff0 : Genv.find_funct _ _ = Some _ |- _ => rename Hff0 into Hff
          end.
          (* the callee expression: global find_ceil, By_reference deref *)
          inv Hevf_fc;
            match goal with
            | Hlv : eval_lvalue _ _ _ _ (Evar mario._find_ceil _) _ _ _ |- _ =>
                inv Hlv
            | _ => idtac
            end;
            try match goal with
                | Hloc : PTree.get mario._find_ceil
                           (PTree.set mario._filler _ empty_env) = Some _ |- _ =>
                    rewrite PTree.gso in Hloc by exact Hne_ids;
                    rewrite PTree.gempty in Hloc; discriminate Hloc
                end.
          match goal with
          | Hd : deref_loc _ _ _ _ _ _ |- _ => inv Hd; try discriminate
          end.
          match goal with
          | Hsym : Genv.find_symbol _ mario._find_ceil = Some ?bf |- _ =>
              rename Hsym into Hfc_sym
          end.
          (* the resolution *)
          match goal with
          | Hff : Genv.find_funct _ (Vptr ?bf Ptrofs.zero) = Some ?fd |- _ =>
              assert (Hres : resolves_lp lp mario._find_ceil fd)
                by (exists bf; split; [ exact Hfc_sym | exact Hff ]);
              destruct fd as [ fint | ef targs tres cc ]
          end.
          { exfalso. exact (Hnint fint Hres). }
          (* External: the nested funcall is one external_call *)
          inv Hfc_call.
          match goal with
          | Hec : external_call _ _ _ ?mSrc _ _ ?mDst |- _ =>
              rename Hec into Hext;
              assert (HmwfB : MWF mDst)
                by (eapply Hext_mwf;
                    [ exact Hres | exact Hext | exact HvA | exact HmwfA ]);
              assert (HunchB : Mem.unchanged_on (action_cell bm) mSrc mDst)
                by (eapply Hext_act; [ exact Hres | exact Hext ]);
              assert (HvB : Mem.valid_block mDst bm)
                by (eapply external_call_valid_block; [ exact Hext | exact HvA ]);
              assert (HsatB : action_sat not_tainted mDst bm)
                by (eapply action_sat_unchanged_on;
                    [ exact HunchB | exact HvA | exact HsatA ])
          end.
          (* the Sreturn is pure *)
          inv Hret.
          (* exit: free the filler block *)
          rewrite blocks_of_env_filler in Hfl.
          split; [ | split ].
          -- refine (proj1 (vfc_free_list_frame not_tainted bm _ _ _ _ Hfl HvB HsatB)).
             constructor; [ exact Hbfil_ne | constructor ].
          -- refine (proj2 (vfc_free_list_frame not_tainted bm _ _ _ _ Hfl HvB HsatB)).
             constructor; [ exact Hbfil_ne | constructor ].
          -- exact (Hfree _ _ _ Hfl HmwfB).
        * (* inner2 seq_2: Sset _t'3 with a non-normal outcome -- impossible *)
          match goal with
          | Hs : exec_stmt _ _ _ _ _ (Sset mario._t'3 _) _ _ _ _ |- _ => inv Hs
          end.
          match goal with
          | Hne : Out_normal <> Out_normal |- _ => exact (False_ind _ (Hne eq_refl))
          end.
      + (* inner seq_2: Sset _t'2 with a non-normal outcome -- impossible *)
        match goal with
        | Hs : exec_stmt _ _ _ _ _ (Sset mario._t'2 _) _ _ _ _ |- _ => inv Hs
        end.
        match goal with
        | Hne : Out_normal <> Out_normal |- _ => exact (False_ind _ (Hne eq_refl))
        end.
    - (* outer seq_2: the inner part with a non-normal outcome -- its leaves
         (Sset/Scall) only produce Out_normal *)
      match goal with
      | Hs : exec_stmt _ _ _ _ _ (Ssequence _ _) _ _ _ ?o,
        Hne : ?o <> Out_normal |- _ => rename Hs into HB; rename Hne into HneB
      end.
      inv HB.
      + match goal with
        | Hs : exec_stmt _ _ _ _ _ (Ssequence (Sset mario._t'3 _) _) _ _ _ _ |- _ =>
            rename Hs into HB2
        end.
        inv HB2.
        * match goal with
          | Hs : exec_stmt _ _ _ _ _ (Scall _ _ _) _ _ _ _ |- _ => inv Hs
          end.
          exact (False_ind _ (HneB eq_refl)).
        * match goal with
          | Hs : exec_stmt _ _ _ _ _ (Sset mario._t'3 _) _ _ _ _ |- _ => inv Hs
          end.
          match goal with
          | Hne : Out_normal <> Out_normal |- _ =>
              exact (False_ind _ (Hne eq_refl))
          end.
      + match goal with
        | Hs : exec_stmt _ _ _ _ _ (Sset mario._t'2 _) _ _ _ _ |- _ => inv Hs
        end.
        match goal with
        | Hne : Out_normal <> Out_normal |- _ =>
            exact (False_ind _ (Hne eq_refl))
        end.
  Qed.

End RestSurface.
