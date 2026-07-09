(* ====================================================================== *)
(* ENGINE-V2 CONSUMER (SPINE: consumed by the v2 grounded capstone).       *)
(*                                                                         *)
(* Instantiates the invariant-aware census engine                          *)
(* (ActionValueFrame.exec_funcall_reach_value_v2) over the linked          *)
(* program lp and exports the capstone-shaped per-funcall contract         *)
(*   reach_value_preserves_reached not_tainted bm (lp_ge lp) NoA MWF       *)
(*     reached_v2                                                          *)
(* for a CONCRETE reached set: the 15 censused mario.c bodies              *)
(* (CensusV2.censused_body) + the bridged update_mario_button_inputs +     *)
(* the named rest surface (exempt whitelist + the root's residual          *)
(* callees, each keyed by its lp symbol resolution).                       *)
(*                                                                         *)
(* WHAT IS PROVED HERE (no longer assumed):                                *)
(*  - leaf A (Hbody): the 15-body census dispatch (body_TI_C_dispatch);    *)
(*  - the store leaf (chk_assign): every censused store preserves          *)
(*    valid/action_sat/MWF given the per-cell stability premises;          *)
(*  - the call-marg leaf (chk_call_marg) and all TI-maintenance and        *)
(*    census-structure leaves (chk_ti_set/chk_ti_optc/chk_seq*/chk_if/     *)
(*    chk_loop/chk_sw) -- including the gate kill and dispatch kill;       *)
(*  - the umbi bridge: AGates.umbi_funcall_marg_preserves_lp lifts to      *)
(*    the engine's Hbridged (its footprint misses the action cell);        *)
(*  - the WRITER leaf is REFUTED, not assumed: no censused/bridged-umbi    *)
(*    body IS set_mario_action (record inequalities), so at this scope     *)
(*    the engine never owes a writer obligation (W := True);               *)
(*  - the CALL-RESOLUTION closure (call_resolves_v2): the census tables    *)
(*    every callee ident, all censused bodies have fn_vars = nil (so the   *)
(*    engine's TI carries e = empty_env and callee Evars evaluate          *)
(*    globally), and the 8 mario.prog-internal class-M callees resolve     *)
(*    by linkorder to the censused/bridged bodies (per-symbol defmap       *)
(*    computes); the 2 MarioState*-taking externals + the exempt           *)
(*    whitelist land on the named rest surface.                            *)
(*                                                                         *)
(* THE RESIDUAL SURFACE (the section hypotheses below) -- each NAMED,      *)
(* satisfiable, and per-cell/per-symbol dischargeable:                     *)
(*  - MWF projections (input/ctl A-clear) + per-cell stability             *)
(*    (window stores, the A-clear input store, whitelisted globals,        *)
(*    non-pointer SafeB stores, the umbi footprint, unchanged-on-bm,       *)
(*    externals) -- discharged when MWF is INSTANTIATED concretely;        *)
(*  - the chase closure premises (HactVint/HPgms/HchaseRoot/HchaseStep/    *)
(*    HSafeNotBm) -- the SafeB instantiation;                              *)
(*  - WL_exempt + Hrest_pres: per-symbol facts about what the named        *)
(*    callee symbols resolve to in lp (the handlers' preservation is the   *)
(*    REMAINING CRUX -- it is where the A-gating taint closure of          *)
(*    Taint.v/AGates.v gets consumed next);                                *)
(*  - return-value facts (Hret_call/ext) + the NoA-from-MWF projection     *)
(*    (Hmwf_noa -- at the capstone this IS Hmwf_ctl).                      *)
(*                                                                         *)
(* WIRED: NoAImpliesNoFlyLinked's v2 grounded capstone instantiates        *)
(* reached_id := root_RID, reached_fd := reached_v2, Hbcr :=               *)
(* root_call_resolves, Hbodyrck := root_body_reach_chk and Hreach_val :=   *)
(* reach_value_preserves_reached_v2, swapping the monolithic per-funcall   *)
(* residual for the surface above.                                         *)
(* ====================================================================== *)

From Coq Require Import ZArith List Lia Classical.
From compcert Require Import Coqlib Maps AST Integers Values Events Memory
  Globalenvs Ctypes Cop Clightdefs Clight ClightBigstep Linking.
From SM64.Generated Require mario.
From SM64.Proofs Require Import SymbolicLinking Flying Taint
  ActionValueFrame RealFrameValue RealFrameLinked AGates.
From SM64.Proofs Require Import CensusV2.

Import ListNotations.
Local Open Scope Z_scope.

Section V2Consumer.
  Variable lp : Clight.program.
  Hypothesis LO_mario : linkorder mario.prog lp.
  Variable bm : block.
  Variable SafeB : block -> Prop.
  Variable NoA MWF : mem -> Prop.

  (* ---------------- the concrete reach surface ---------------- *)

  (* a named symbol's lp resolution (zero-offset function pointer) *)
  Definition resolves_lp (fid : ident) (fd : Clight.fundef) : Prop :=
    exists b, Genv.find_symbol (lp_ge lp) fid = Some b /\
              Genv.find_funct (lp_ge lp) (Vptr b Ptrofs.zero) = Some fd.

  (* execute_mario_action's callees that are NOT censused bodies and NOT
     the bridged umbi: the 7 action dispatch handlers + interactions +
     special floors + the two sound/particle helpers not already on the
     exempt whitelist. Extracted from the generated AST of
     f_execute_mario_action (the only Scall callee idents in its body
     besides the censused 8 and play_sound). *)
  Definition root_residual_callees : list ident :=
    mario._mario_execute_stationary_action ::
    mario._mario_execute_moving_action ::
    mario._mario_execute_airborne_action ::
    mario._mario_execute_submerged_action ::
    mario._mario_execute_cutscene_action ::
    mario._mario_execute_automatic_action ::
    mario._mario_execute_object_action ::
    mario._mario_handle_special_floors ::
    mario._mario_process_interactions ::
    mario._spawn_wind_particles ::
    mario._play_infinite_stairs_music :: nil.

  (* the two class-M callees that are mario.prog EXTERNALS (their bodies
     live in TUs not yet linkorder-pinned): their lp resolutions are
     per-symbol rest residuals, like the handlers *)
  Definition mptr_external_callees : list ident :=
    mario._stub_mario_step_1 :: mario._level_trigger_warp :: nil.

  (* the not-yet-walked reach surface, keyed per symbol *)
  Definition rest_fd (fd : Clight.fundef) : Prop :=
    exists fid,
      (mem_id fid exempt_callees = true \/
       mem_id fid root_residual_callees = true \/
       mem_id fid mptr_external_callees = true) /\
      resolves_lp fid fd.

  Definition bridged_fd (fd : Clight.fundef) : Prop :=
    fd = Internal mario.f_update_mario_button_inputs \/ rest_fd fd.

  (* the writer classification EXCLUDES the bridged surface: a rest-symbol
     resolution is covered by its whole-funcall residual regardless of
     what record it is, so the writer leaf only ever owes the pinned
     internals -- where it is refutable. *)
  Definition writer_fd (fd : Clight.fundef) : Prop :=
    fd = Internal mario.f_set_mario_action /\ ~ bridged_fd fd.

  Definition reached_v2 (fd : Clight.fundef) : Prop :=
    (exists f, fd = Internal f /\ censused_body f) \/ bridged_fd fd.

  (* ---------------- the residual surface ---------------- *)

  (* MWF projections: the run invariant contains the two A-clear cells *)
  Hypothesis Hmwf_inp : forall m, MWF m -> input_a_clear m bm.
  Hypothesis Hmwf_ctl : forall m, MWF m -> ctl_a_clear m bm.

  (* chk_ti_set's per-cell closure premises *)
  Hypothesis HactVint : forall mm, MWF mm -> forall av,
      Mem.load Mint32 mm bm 12 = Some av ->
      av = Vundef \/ exists vi, av = Vint vi.
  (* CONDITIONAL on the load (the Sset execution supplies the evidence):
     a positive "the load succeeds" row would make MWF jointly
     unsatisfiable with Hmwf_free (an adversarial free kills the load). *)
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

  (* chk_assign's store-stability premises *)
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

  (* umbi stability: MWF survives a change confined to the umbi footprint
     (m->input + framesSinceA/B) that re-establishes input_a_clear *)
  Hypothesis Hmwf_umbi : forall mm mm',
      MWF mm ->
      Mem.unchanged_on (fun b o => ~ umbi_footprint bm b o) mm mm' ->
      input_a_clear mm' bm -> MWF mm'.

  (* per-symbol: the whitelisted callee symbols resolve to marg-exempt
     definitions (their first param is not MarioState* ) *)
  Hypothesis WL_exempt : forall e le m fid fty vf fd,
      mem_id fid exempt_callees = true ->
      eval_expr (lp_ge lp) e le m (Evar fid fty) vf ->
      Genv.find_funct (lp_ge lp) vf = Some fd ->
      marg_exempt fd = true.

  (* per-symbol: the rest surface preserves the carried facts -- but ONLY
     where lp resolves the symbol to an INTERNAL body. A rest symbol that
     lp keeps External (math/runtime: sqrtf, play_sound, find_floor ...)
     carries NO obligation here: the engine's External path goes through
     the reached-gated Hext_action/Hmwf_ext rows below. (Stating this
     leaf over all fundefs was a phantom: both engine leaves that consume
     it -- Hbridged/Hexempt -- are Internal-shaped.) THIS is the
     remaining crux at this scope: for the 7 dispatch handlers +
     interactions + special floors it is exactly where the A-gating taint
     closure (Taint.v + AGates.v kills) gets consumed; for the exempt
     whitelist it is per-symbol frame reasoning (vec3 family etc.). *)
  Hypothesis Hrest_pres : forall m f vargs t m' vres,
      rest_fd (Internal f) ->
      (marg_exempt (Internal f) = false -> marg_ok bm vargs) ->
      sargs_ok (Internal f) vargs ->
      eval_funcall function_entry2 (lp_ge lp) m (Internal f) vargs t m' vres ->
      NoA m -> MWF m -> Mem.valid_block m bm -> action_sat not_tainted m bm ->
      Mem.valid_block m' bm /\ action_sat not_tainted m' bm /\ MWF m'.

  (* NOTE (task #99): the return-value hypothesis (Hret_call: every reached
     funcall result avoids bm) is GONE. The v2 engine no longer takes it --
     TI is preserved across a censused call's set_opttemp purely because the
     census forces the result temp UNTABLED (chk_ti_optc uses call_optid_ok,
     never the ret value). The standalone row was a latent vacuity (reached
     Externals CAN return Vptr bm), so removing it de-vacuifies the capstone. *)

  (* externals, REACHED-GATED: with builtins census-refuted, the engine's
     only external_call site is a reached External fundef, and
     reached_v2 (External ef) unpacks to a NAMED rest symbol resolving to
     ef in lp -- a per-symbol model-boundary surface (EF_external rows for
     play_sound, the math helpers, ...). The previous forall-ef rows
     (including the now-DELETED Hret_ext) were FALSE for the real program:
     EF_memcpy writes any writable cell, EF_vload can return Vptr bm 0. *)
  Hypothesis Hext_action : forall ef targs tres cc vargs m t vres m',
      reached_v2 (External ef targs tres cc) ->
      external_call ef (lp_ge lp) vargs m t vres m' ->
      Mem.unchanged_on (action_cell bm) m m'.
  Hypothesis Hmwf_ext : forall ef targs tres cc vargs m t vres m',
      reached_v2 (External ef targs tres cc) ->
      external_call ef (lp_ge lp) vargs m t vres m' ->
      Mem.valid_block m bm -> MWF m -> MWF m'.
  (* MWF crosses function entry/exit by the PRECISE operations there:
     entry allocates fresh Vundef blocks (writes no existing memory);
     exit frees them (free only KILLS loads, never changes a surviving
     load's value). Load-CONDITIONAL MWF rows satisfy both for free; a
     blunt unchanged-on-bm leaf would be UNSATISFIABLE for the intended
     MWF (its controller-chase rows live off bm). *)
  Hypothesis Hmwf_entry : forall f vargs m e le m1,
      function_entry2 (lp_ge lp) f vargs m e le m1 -> MWF m -> MWF m1.
  Hypothesis Hmwf_free : forall m2 m3 l,
      Mem.free_list m2 l = Some m3 -> MWF m2 -> MWF m3.

  (* NoA is a PROJECTION of the carried run invariant: at the capstone's
     instantiation (NoA := ctl_a_clear, MWF carrying it) this IS Hmwf_ctl.
     The engine derives every mid-walk NoA fact from the threaded MWF --
     a blunt forall-stmt NoA-stability leaf would be FALSE for the real lp
     (an adversarial Sassign through the controller chase sets the A bit). *)
  Hypothesis Hmwf_noa : forall m, MWF m -> NoA m.

  (* ---------------- the empty-env bricks ---------------- *)

  (* every censused body has fn_vars = nil (checked against the generated
     AST), so its entry environment is exactly empty_env -- this is what
     forces every censused callee Evar through eval_Evar_global and makes
     the call resolution per-symbol decidable. *)
  Lemma censused_body_novars :
    forall f, censused_body f -> fn_vars f = nil.
  Proof.
    intros f HC.
    destruct HC as
      [-> | [-> | [-> | [-> | [-> | [-> | [-> | [-> | [-> | [-> | [-> | [-> | [-> | [-> | ->]]]]]]]]]]]]]];
      reflexivity.
  Qed.

  Lemma entry_novars_empty_env :
    forall ge f vargs m e le m1,
      function_entry2 ge f vargs m e le m1 -> fn_vars f = nil ->
      e = empty_env.
  Proof.
    intros ge f vargs m e le m1 Hentry Hnil. inv Hentry.
    match goal with
    | Ha : alloc_variables _ _ _ (fn_vars f) _ _ |- _ =>
        rewrite Hnil in Ha; inv Ha
    end.
    reflexivity.
  Qed.

  (* a function-typed Evar at the empty env evaluates to its global's
     zero-offset function pointer (local case refuted by PTree.gempty;
     Tfunction's access mode is By_reference) *)
  Lemma eval_Evar_funct_empty :
    forall le m fid tyl rty cc vf,
      eval_expr (lp_ge lp) empty_env le m (Evar fid (Tfunction tyl rty cc)) vf ->
      exists b, Genv.find_symbol (lp_ge lp) fid = Some b /\
                vf = Vptr b Ptrofs.zero.
  Proof.
    intros le m fid tyl rty cc vf Hev.
    inv Hev.
    match goal with
    | Hl : eval_lvalue _ _ _ _ (Evar _ _) _ _ _ |- _ => inv Hl
    end.
    - (* local: refuted at the empty env *)
      match goal with
      | He : empty_env ! _ = Some _ |- _ =>
          rewrite PTree.gempty in He; discriminate He
      end.
    - (* global: deref at By_reference hands back the pointer *)
      match goal with
      | Hd : deref_loc _ _ _ _ _ _ |- _ => inv Hd
      end;
        try (match goal with
             | Hac : access_mode _ = _ |- _ => cbn in Hac; discriminate Hac
             end).
      eexists. split; [ eassumption | reflexivity ].
  Qed.

  (* ---------------- the per-symbol resolutions ---------------- *)
  (* linkorder pins every mario.prog-internal class-M callee to its real
     body in lp; each defmap lookup is a bounded mario.prog-only compute. *)

  Lemma resolve_umbi :
    exists b,
      Genv.find_symbol (lp_ge lp) mario._update_mario_button_inputs = Some b /\
      Genv.find_funct (lp_ge lp) (Vptr b Ptrofs.zero)
        = Some (Internal mario.f_update_mario_button_inputs).
  Proof.
    apply (linkorder_resolves_funct lp mario.prog _ _ LO_mario).
    vm_compute. reflexivity.
  Qed.

  Lemma resolve_umji :
    exists b,
      Genv.find_symbol (lp_ge lp) mario._update_mario_joystick_inputs = Some b /\
      Genv.find_funct (lp_ge lp) (Vptr b Ptrofs.zero)
        = Some (Internal mario.f_update_mario_joystick_inputs).
  Proof.
    apply (linkorder_resolves_funct lp mario.prog _ _ LO_mario).
    vm_compute. reflexivity.
  Qed.

  Lemma resolve_ugeo :
    exists b,
      Genv.find_symbol (lp_ge lp) mario._update_mario_geometry_inputs = Some b /\
      Genv.find_funct (lp_ge lp) (Vptr b Ptrofs.zero)
        = Some (Internal mario.f_update_mario_geometry_inputs).
  Proof.
    apply (linkorder_resolves_funct lp mario.prog _ _ LO_mario).
    vm_compute. reflexivity.
  Qed.

  Lemma resolve_dpsan :
    exists b,
      Genv.find_symbol (lp_ge lp) mario._debug_print_speed_action_normal = Some b /\
      Genv.find_funct (lp_ge lp) (Vptr b Ptrofs.zero)
        = Some (Internal mario.f_debug_print_speed_action_normal).
  Proof.
    apply (linkorder_resolves_funct lp mario.prog _ _ LO_mario).
    vm_compute. reflexivity.
  Qed.

  Lemma resolve_mgtsa :
    exists b,
      Genv.find_symbol (lp_ge lp) mario._mario_get_terrain_sound_addend = Some b /\
      Genv.find_funct (lp_ge lp) (Vptr b Ptrofs.zero)
        = Some (Internal mario.f_mario_get_terrain_sound_addend).
  Proof.
    apply (linkorder_resolves_funct lp mario.prog _ _ LO_mario).
    vm_compute. reflexivity.
  Qed.

  Lemma resolve_mfis :
    exists b,
      Genv.find_symbol (lp_ge lp) mario._mario_floor_is_slippery = Some b /\
      Genv.find_funct (lp_ge lp) (Vptr b Ptrofs.zero)
        = Some (Internal mario.f_mario_floor_is_slippery).
  Proof.
    apply (linkorder_resolves_funct lp mario.prog _ _ LO_mario).
    vm_compute. reflexivity.
  Qed.

  Lemma resolve_mgfc :
    exists b,
      Genv.find_symbol (lp_ge lp) mario._mario_get_floor_class = Some b /\
      Genv.find_funct (lp_ge lp) (Vptr b Ptrofs.zero)
        = Some (Internal mario.f_mario_get_floor_class).
  Proof.
    apply (linkorder_resolves_funct lp mario.prog _ _ LO_mario).
    vm_compute. reflexivity.
  Qed.

  Lemma resolve_uarcf :
    exists b,
      Genv.find_symbol (lp_ge lp) mario._update_and_return_cap_flags = Some b /\
      Genv.find_funct (lp_ge lp) (Vptr b Ptrofs.zero)
        = Some (Internal mario.f_update_and_return_cap_flags).
  Proof.
    apply (linkorder_resolves_funct lp mario.prog _ _ LO_mario).
    vm_compute. reflexivity.
  Qed.

  (* ---------------- THE CALL-RESOLUTION CLOSURE (proved) ---------------- *)
  (* every censused call resolves into reached_v2: class-M callees are
     whitelist-tabled function Evars -- the 8 mario.prog internals resolve
     (linkorder) to censused/bridged bodies, the 2 externals land on the
     rest surface; class-E callees land on the rest surface by
     construction. Uses the e = empty_env strengthening of the engine's TI
     (all censused bodies have fn_vars = nil). *)
  Lemma call_resolves_v2 :
    forall bc le m optid a al vf fd,
      chk bc (Scall optid a al) = true ->
      eval_expr (lp_ge lp) empty_env le m a vf ->
      Genv.find_funct (lp_ge lp) vf = Some fd ->
      reached_v2 fd.
  Proof.
    intros bc le m optid a al vf fd HC Hevf Hff.
    change ((call_optid_ok bc optid
             && (call_head_is_mptr bc al && callee_in_mptr a
                 || call_callee_exempt a)) = true) in HC.
    apply andb_true_iff in HC as [_ HC].
    apply orb_true_iff in HC as [HM | HE].
    - (* class M *)
      apply andb_true_iff in HM as [_ HMc].
      destruct (callee_in_mptr_shape _ HMc)
        as (fid & tyl & rty & cc & Ea & Hfid). subst a.
      destruct (eval_Evar_funct_empty _ _ _ _ _ _ _ Hevf)
        as (b & Hsym & Evf). subst vf.
      unfold mem_id, mptr_callees in Hfid; cbn [existsb] in Hfid.
      repeat (apply orb_true_iff in Hfid; destruct Hfid as [Hfid | Hfid]);
        try discriminate Hfid; apply Pos.eqb_eq in Hfid; subst fid.
      + (* umbi: the bridged body *)
        destruct resolve_umbi as (b' & Hsym' & Hff').
        assert (b = b') by congruence. subst b'.
        right. left. congruence.
      + (* umji *)
        destruct resolve_umji as (b' & Hsym' & Hff').
        assert (b = b') by congruence. subst b'.
        assert (Efd : fd = Internal mario.f_update_mario_joystick_inputs) by congruence.
        subst fd. left. eexists. split; [ reflexivity | ].
        unfold censused_body. do 7 right. left. reflexivity.
      + (* ugeo *)
        destruct resolve_ugeo as (b' & Hsym' & Hff').
        assert (b = b') by congruence. subst b'.
        assert (Efd : fd = Internal mario.f_update_mario_geometry_inputs) by congruence.
        subst fd. left. eexists. split; [ reflexivity | ].
        unfold censused_body. do 9 right. left. reflexivity.
      + (* dpsan *)
        destruct resolve_dpsan as (b' & Hsym' & Hff').
        assert (b = b') by congruence. subst b'.
        assert (Efd : fd = Internal mario.f_debug_print_speed_action_normal) by congruence.
        subst fd. left. eexists. split; [ reflexivity | ].
        unfold censused_body. do 3 right. left. reflexivity.
      + (* mgtsa *)
        destruct resolve_mgtsa as (b' & Hsym' & Hff').
        assert (b = b') by congruence. subst b'.
        assert (Efd : fd = Internal mario.f_mario_get_terrain_sound_addend) by congruence.
        subst fd. left. eexists. split; [ reflexivity | ].
        unfold censused_body. do 1 right. left. reflexivity.
      + (* mfis *)
        destruct resolve_mfis as (b' & Hsym' & Hff').
        assert (b = b') by congruence. subst b'.
        assert (Efd : fd = Internal mario.f_mario_floor_is_slippery) by congruence.
        subst fd. left. eexists. split; [ reflexivity | ].
        unfold censused_body. do 2 right. left. reflexivity.
      + (* mgfc *)
        destruct resolve_mgfc as (b' & Hsym' & Hff').
        assert (b = b') by congruence. subst b'.
        assert (Efd : fd = Internal mario.f_mario_get_floor_class) by congruence.
        subst fd. left. eexists. split; [ reflexivity | ].
        unfold censused_body. left. reflexivity.
      + (* uarcf *)
        destruct resolve_uarcf as (b' & Hsym' & Hff').
        assert (b = b') by congruence. subst b'.
        assert (Efd : fd = Internal mario.f_update_and_return_cap_flags) by congruence.
        subst fd. left. eexists. split; [ reflexivity | ].
        unfold censused_body. do 4 right. left. reflexivity.
      + (* stub_mario_step_1: rest *)
        right. right. exists mario._stub_mario_step_1.
        split; [ right; right; reflexivity | ].
        exists b. split; [ exact Hsym | exact Hff ].
      + (* level_trigger_warp: rest *)
        right. right. exists mario._level_trigger_warp.
        split; [ right; right; reflexivity | ].
        exists b. split; [ exact Hsym | exact Hff ].
    - (* class E: the exempt whitelist *)
      destruct (call_callee_exempt_shape _ HE)
        as (fid & tyl & rty & cc & Ea & Hfid). subst a.
      destruct (eval_Evar_funct_empty _ _ _ _ _ _ _ Hevf)
        as (b & Hsym & Evf). subst vf.
      right. right. exists fid.
      split; [ left; exact Hfid | ].
      exists b. split; [ exact Hsym | exact Hff ].
  Qed.

  (* ---------------- the ROOT call-resolution layer ---------------- *)
  (* execute_mario_action's own body walk (RealFrameLinked's
     exec_body_prov_reached_lp) consumes a per-call resolution residual
     (Hbcr) keyed by the v1 reach_chk census. Here both are DISCHARGED for
     the concrete reach set: the root's 20 callee idents resolve into
     reached_v2 -- the 8 censused internals by linkorder, the rest onto the
     named rest surface. *)

  Definition root_called_ids : list ident :=
    mario._mario_reset_bodystate ::
    mario._update_mario_inputs ::
    mario._mario_handle_special_floors ::
    mario._mario_process_interactions ::
    mario._mario_execute_stationary_action ::
    mario._mario_execute_moving_action ::
    mario._mario_execute_airborne_action ::
    mario._mario_execute_submerged_action ::
    mario._mario_execute_cutscene_action ::
    mario._mario_execute_automatic_action ::
    mario._mario_execute_object_action ::
    mario._sink_mario_in_quicksand ::
    mario._squish_mario_model ::
    mario._set_submerged_cam_preset_and_spawn_bubbles ::
    mario._update_mario_health ::
    mario._update_mario_info_for_cam ::
    mario._mario_update_hitbox_and_cap_model ::
    mario._spawn_wind_particles ::
    mario._play_sound ::
    mario._play_infinite_stairs_music :: nil.

  Definition root_RID (fid : ident) : Prop :=
    mem_id fid root_called_ids = true.

  (* the root body's call census closes at this id set (computed against
     the generated AST) *)
  Lemma root_body_reach_chk :
    RealFrameValue.reach_chk root_RID (fn_body mario.f_execute_mario_action).
  Proof.
    cbn [RealFrameValue.reach_chk RealFrameValue.reach_chk_ls
         fn_body mario.f_execute_mario_action];
      unfold root_RID; repeat split; reflexivity.
  Qed.

  Lemma resolve_mrb :
    exists b,
      Genv.find_symbol (lp_ge lp) mario._mario_reset_bodystate = Some b /\
      Genv.find_funct (lp_ge lp) (Vptr b Ptrofs.zero)
        = Some (Internal mario.f_mario_reset_bodystate).
  Proof.
    apply (linkorder_resolves_funct lp mario.prog _ _ LO_mario).
    vm_compute. reflexivity.
  Qed.

  Lemma resolve_umi :
    exists b,
      Genv.find_symbol (lp_ge lp) mario._update_mario_inputs = Some b /\
      Genv.find_funct (lp_ge lp) (Vptr b Ptrofs.zero)
        = Some (Internal mario.f_update_mario_inputs).
  Proof.
    apply (linkorder_resolves_funct lp mario.prog _ _ LO_mario).
    vm_compute. reflexivity.
  Qed.

  Lemma resolve_smq :
    exists b,
      Genv.find_symbol (lp_ge lp) mario._sink_mario_in_quicksand = Some b /\
      Genv.find_funct (lp_ge lp) (Vptr b Ptrofs.zero)
        = Some (Internal mario.f_sink_mario_in_quicksand).
  Proof.
    apply (linkorder_resolves_funct lp mario.prog _ _ LO_mario).
    vm_compute. reflexivity.
  Qed.

  Lemma resolve_squish :
    exists b,
      Genv.find_symbol (lp_ge lp) mario._squish_mario_model = Some b /\
      Genv.find_funct (lp_ge lp) (Vptr b Ptrofs.zero)
        = Some (Internal mario.f_squish_mario_model).
  Proof.
    apply (linkorder_resolves_funct lp mario.prog _ _ LO_mario).
    vm_compute. reflexivity.
  Qed.

  Lemma resolve_sscpasb :
    exists b,
      Genv.find_symbol (lp_ge lp)
        mario._set_submerged_cam_preset_and_spawn_bubbles = Some b /\
      Genv.find_funct (lp_ge lp) (Vptr b Ptrofs.zero)
        = Some (Internal mario.f_set_submerged_cam_preset_and_spawn_bubbles).
  Proof.
    apply (linkorder_resolves_funct lp mario.prog _ _ LO_mario).
    vm_compute. reflexivity.
  Qed.

  Lemma resolve_umh :
    exists b,
      Genv.find_symbol (lp_ge lp) mario._update_mario_health = Some b /\
      Genv.find_funct (lp_ge lp) (Vptr b Ptrofs.zero)
        = Some (Internal mario.f_update_mario_health).
  Proof.
    apply (linkorder_resolves_funct lp mario.prog _ _ LO_mario).
    vm_compute. reflexivity.
  Qed.

  Lemma resolve_umifc :
    exists b,
      Genv.find_symbol (lp_ge lp) mario._update_mario_info_for_cam = Some b /\
      Genv.find_funct (lp_ge lp) (Vptr b Ptrofs.zero)
        = Some (Internal mario.f_update_mario_info_for_cam).
  Proof.
    apply (linkorder_resolves_funct lp mario.prog _ _ LO_mario).
    vm_compute. reflexivity.
  Qed.

  Lemma resolve_muhacm :
    exists b,
      Genv.find_symbol (lp_ge lp) mario._mario_update_hitbox_and_cap_model
        = Some b /\
      Genv.find_funct (lp_ge lp) (Vptr b Ptrofs.zero)
        = Some (Internal mario.f_mario_update_hitbox_and_cap_model).
  Proof.
    apply (linkorder_resolves_funct lp mario.prog _ _ LO_mario).
    vm_compute. reflexivity.
  Qed.

  (* THE Hbcr DISCHARGE: every root-census call resolves into reached_v2.
     Exactly the shape of the capstone's (empty-env-sharpened) Hbcr. *)
  Lemma root_call_resolves :
    forall oid a al le mm vf fd,
      RealFrameValue.reach_chk root_RID (Scall oid a al) ->
      eval_expr (lp_ge lp) empty_env le mm a vf ->
      Genv.find_funct (lp_ge lp) vf = Some fd ->
      reached_v2 fd.
  Proof.
    intros oid a al le mm vf fd Hrc Hevf Hff.
    cbn [RealFrameValue.reach_chk] in Hrc.
    destruct a; try contradiction.
    destruct t; try contradiction.
    destruct (eval_Evar_funct_empty _ _ _ _ _ _ _ Hevf)
      as (b & Hsym & Evf). subst vf.
    unfold root_RID, mem_id, root_called_ids in Hrc; cbn [existsb] in Hrc.
    repeat (apply orb_true_iff in Hrc; destruct Hrc as [Hrc | Hrc]);
      try discriminate Hrc; apply Pos.eqb_eq in Hrc; subst i.
    - (* mario_reset_bodystate: censused slot 11 *)
      destruct resolve_mrb as (b' & Hsym' & Hff').
      assert (b' = b) by congruence. subst b'.
      assert (Efd : fd = Internal mario.f_mario_reset_bodystate) by congruence.
      subst fd. left. eexists. split; [ reflexivity | ].
      unfold censused_body. do 10 right. left. reflexivity.
    - (* update_mario_inputs: censused slot 9 *)
      destruct resolve_umi as (b' & Hsym' & Hff').
      assert (b' = b) by congruence. subst b'.
      assert (Efd : fd = Internal mario.f_update_mario_inputs) by congruence.
      subst fd. left. eexists. split; [ reflexivity | ].
      unfold censused_body. do 8 right. left. reflexivity.
    - (* mario_handle_special_floors: rest *)
      right. right. exists mario._mario_handle_special_floors.
      split; [ right; left; reflexivity | ].
      exists b. split; [ exact Hsym | exact Hff ].
    - (* mario_process_interactions: rest *)
      right. right. exists mario._mario_process_interactions.
      split; [ right; left; reflexivity | ].
      exists b. split; [ exact Hsym | exact Hff ].
    - (* the 7 dispatch handlers: rest *)
      right. right. exists mario._mario_execute_stationary_action.
      split; [ right; left; reflexivity | ].
      exists b. split; [ exact Hsym | exact Hff ].
    - right. right. exists mario._mario_execute_moving_action.
      split; [ right; left; reflexivity | ].
      exists b. split; [ exact Hsym | exact Hff ].
    - right. right. exists mario._mario_execute_airborne_action.
      split; [ right; left; reflexivity | ].
      exists b. split; [ exact Hsym | exact Hff ].
    - right. right. exists mario._mario_execute_submerged_action.
      split; [ right; left; reflexivity | ].
      exists b. split; [ exact Hsym | exact Hff ].
    - right. right. exists mario._mario_execute_cutscene_action.
      split; [ right; left; reflexivity | ].
      exists b. split; [ exact Hsym | exact Hff ].
    - right. right. exists mario._mario_execute_automatic_action.
      split; [ right; left; reflexivity | ].
      exists b. split; [ exact Hsym | exact Hff ].
    - right. right. exists mario._mario_execute_object_action.
      split; [ right; left; reflexivity | ].
      exists b. split; [ exact Hsym | exact Hff ].
    - (* sink_mario_in_quicksand: censused slot 14 *)
      destruct resolve_smq as (b' & Hsym' & Hff').
      assert (b' = b) by congruence. subst b'.
      assert (Efd : fd = Internal mario.f_sink_mario_in_quicksand) by congruence.
      subst fd. left. eexists. split; [ reflexivity | ].
      unfold censused_body. do 13 right. left. reflexivity.
    - (* squish_mario_model: censused slot 13 *)
      destruct resolve_squish as (b' & Hsym' & Hff').
      assert (b' = b) by congruence. subst b'.
      assert (Efd : fd = Internal mario.f_squish_mario_model) by congruence.
      subst fd. left. eexists. split; [ reflexivity | ].
      unfold censused_body. do 12 right. left. reflexivity.
    - (* set_submerged_cam_preset_and_spawn_bubbles: censused slot 6 *)
      destruct resolve_sscpasb as (b' & Hsym' & Hff').
      assert (b' = b) by congruence. subst b'.
      assert (Efd : fd
                    = Internal mario.f_set_submerged_cam_preset_and_spawn_bubbles)
        by congruence.
      subst fd. left. eexists. split; [ reflexivity | ].
      unfold censused_body. do 5 right. left. reflexivity.
    - (* update_mario_health: censused slot 7 *)
      destruct resolve_umh as (b' & Hsym' & Hff').
      assert (b' = b) by congruence. subst b'.
      assert (Efd : fd = Internal mario.f_update_mario_health) by congruence.
      subst fd. left. eexists. split; [ reflexivity | ].
      unfold censused_body. do 6 right. left. reflexivity.
    - (* update_mario_info_for_cam: censused slot 12 *)
      destruct resolve_umifc as (b' & Hsym' & Hff').
      assert (b' = b) by congruence. subst b'.
      assert (Efd : fd = Internal mario.f_update_mario_info_for_cam) by congruence.
      subst fd. left. eexists. split; [ reflexivity | ].
      unfold censused_body. do 11 right. left. reflexivity.
    - (* mario_update_hitbox_and_cap_model: censused slot 15 (last) *)
      destruct resolve_muhacm as (b' & Hsym' & Hff').
      assert (b' = b) by congruence. subst b'.
      assert (Efd : fd = Internal mario.f_mario_update_hitbox_and_cap_model)
        by congruence.
      subst fd. left. eexists. split; [ reflexivity | ].
      unfold censused_body. do 14 right. reflexivity.
    - (* spawn_wind_particles: rest *)
      right. right. exists mario._spawn_wind_particles.
      split; [ right; left; reflexivity | ].
      exists b. split; [ exact Hsym | exact Hff ].
    - (* play_sound: rest via the exempt whitelist *)
      right. right. exists mario._play_sound.
      split; [ left; reflexivity | ].
      exists b. split; [ exact Hsym | exact Hff ].
    - (* play_infinite_stairs_music: rest *)
      right. right. exists mario._play_infinite_stairs_music.
      split; [ right; left; reflexivity | ].
      exists b. split; [ exact Hsym | exact Hff ].
  Qed.

  (* ---------------- the writer refutation bricks ---------------- *)

  (* every censused body has exactly 1 parameter; set_mario_action has 3 *)
  Lemma censused_body_not_writer :
    forall f, censused_body f -> f <> mario.f_set_mario_action.
  Proof.
    intros f HC E. subst f.
    destruct HC as
      [E | [E | [E | [E | [E | [E | [E | [E | [E | [E | [E | [E | [E | [E | E]]]]]]]]]]]]]];
      apply (f_equal (fun g => List.length (fn_params g))) in E;
      vm_compute in E; discriminate E.
  Qed.

  Lemma umbi_not_writer :
    mario.f_update_mario_button_inputs <> mario.f_set_mario_action.
  Proof.
    intro E.
    apply (f_equal (fun g => List.length (fn_params g))) in E.
    vm_compute in E. discriminate E.
  Qed.

  (* ---------------- THE EXPORT ---------------- *)

  Theorem reach_value_preserves_reached_v2 :
    reach_value_preserves_reached not_tainted bm (lp_ge lp) NoA MWF reached_v2.
  Proof.
    assert (HV2 : reach_value_preserves_v2 not_tainted bm (lp_ge lp) NoA MWF
                    writer_fd (fun _ => True) reached_v2).
    { apply (exec_funcall_reach_value_v2 not_tainted bm (lp_ge lp) NoA MWF
               writer_fd (fun _ => True) bridged_fd reached_v2
               body_census
               (fun bc e le => TI_of not_tainted bm SafeB bc e le
                               /\ e = empty_env)
               (fun bc s => chk bc s = true)).
      - (* Hbody: censused dispatch + the empty-env fact at entry *)
        intros f vargs0 m0 e le m1 Hr _ Hentry _ Hnb Hmarg0.
        assert (HC : censused_body f).
        { destruct Hr as [(f0 & Ef & HC0) | Hb].
          - injection Ef as Ef. subst f0. exact HC0.
          - exfalso. exact (Hnb Hb). }
        destruct (body_TI_C_dispatch not_tainted bm SafeB (lp_ge lp)
                    f vargs0 m0 e le m1 HC Hentry Hmarg0)
          as (bc & HTI & HCk).
        exists bc. split; [ split; [ exact HTI | ] | exact HCk ].
        exact (entry_novars_empty_env _ _ _ _ _ _ _ Hentry
                 (censused_body_novars _ HC)).
      - (* Hbridged: umbi (proved) / rest (residual) *)
        intros f vargs0 m0 t0 m0' vres0 _ Hb Hmargc Hsargs Hevf Hno0 Hmwf0 Hv0 Hsat0.
        destruct Hb as [Eumbi | Hrest].
        + injection Eumbi as Eumbi. subst f.
          assert (Hmarg0 : marg_ok bm vargs0) by (apply Hmargc; reflexivity).
          destruct (umbi_funcall_marg_preserves_lp lp LO_mario
                      m0 vargs0 t0 m0' vres0 bm Hmarg0
                      (Hmwf_ctl _ Hmwf0) (Hmwf_inp _ Hmwf0) Hevf)
            as (Hinp' & Hunch).
          assert (Hac : Mem.unchanged_on (action_cell bm) m0 m0').
          { eapply Mem.unchanged_on_implies; [ exact Hunch | ].
            intros b ofs Hcell _. destruct Hcell as [-> Hr'].
            intros (_ & Hor). cbn [size_chunk] in Hr'. lia. }
          split; [ | split ].
          * eapply Mem.valid_block_unchanged_on; [ exact Hac | exact Hv0 ].
          * eapply action_sat_unchanged_on;
              [ exact Hac | exact Hv0 | exact Hsat0 ].
          * eapply Hmwf_umbi; [ exact Hmwf0 | exact Hunch | exact Hinp' ].
        + exact (Hrest_pres m0 f vargs0 t0 m0' vres0
                   Hrest Hmargc Hsargs Hevf Hno0 Hmwf0 Hv0 Hsat0).
      - (* Hassign: the censused store leaf *)
        intros bc e le m0 a1 a2 loc ofs bf v2 v m0'
               Hlv Hev2 Hcast Has [HTI _] HC Hmwf0 Hv0 Hsat0.
        exact (chk_assign lp LO_mario not_tainted MWF bm SafeB bc e le m0
                 a1 a2 loc ofs bf v2 v m0'
                 Hmwf_window Hmwf_input Hmwf_glob HSafeNotBm Hmwf_chase
                 Hlv Hev2 Hcast Has HTI HC Hmwf0 Hv0 Hsat0).
      - (* Hcallmarg *)
        intros bc e le m0 optid a al tyargs vargs0 vf fd0
               [HTI _] HC Hevf Hff Hnex Hargs.
        exact (chk_call_marg lp WL_exempt not_tainted bm SafeB bc e le m0
                 optid a al tyargs vargs0 vf fd0 HTI HC Hevf Hff Hnex Hargs).
      - (* Hexempt: censused/umbi are non-exempt (compute); rest is the
           residual *)
        intros f vargs0 m0 t0 m0' vres0 Hr Hex Hsargs Hevf Hno0 Hmwf0 Hv0 Hsat0.
        destruct Hr as [(f0 & Ef & HC0) | [Eumbi | Hrest]].
        + exfalso. injection Ef as Ef. subst f0.
          rewrite (censused_body_nonexempt _ HC0) in Hex. discriminate Hex.
        + exfalso. injection Eumbi as Eumbi. subst f.
          vm_compute in Hex. discriminate Hex.
        + apply (Hrest_pres m0 f vargs0 t0 m0' vres0
                   Hrest); try assumption.
          intro HF. rewrite Hex in HF. discriminate HF.
      - (* HTI_set *)
        intros bc e le m0 id a v Hmwf0 Hsat0 Hev0 [HTI Hee] HC.
        split; [ | exact Hee ].
        exact (chk_ti_set lp LO_mario not_tainted MWF bm SafeB bc e le m0
                 id a v HactVint HPgms HchaseRoot HchaseStep
                 Hmwf0 (Hmwf_inp _ Hmwf0) Hsat0 Hev0 HTI HC).
      - (* HTI_optc: no ret premise -- the census keeps the result temp untabled *)
        intros bc e optid a al v le HC [HTI Hee].
        split; [ | exact Hee ].
        exact (chk_ti_optc not_tainted bm SafeB bc e optid a al v le HC HTI).
      - (* HCbuiltin: censused bodies have no builtins *)
        intros bc optid ef tyargs al HC.
        cbn in HC. discriminate HC.
      - (* Hcall_reached: PROVED -- the per-symbol resolution closure *)
        intros bc e le m0 optid a al vf fd0 [_ Hee] HC Hevf Hff.
        subst e.
        exact (call_resolves_v2 bc le m0 optid a al vf fd0 HC Hevf Hff).
      - (* Hcallwriter: W := True *)
        intros. exact I.
      - (* Hw: REFUTED -- the pinned internals are not the writer record *)
        intros m0 fd0 vargs0 t0 m0' vres0 Hr _ _ _ _ Hwr _ _.
        exfalso. destruct Hwr as [Efd Hnb].
        destruct Hr as [(f0 & Ef & HC0) | Hb]; [ | exact (Hnb Hb) ].
        rewrite Efd in Ef. injection Ef as Ef.
        exact (censused_body_not_writer f0 HC0 (eq_sym Ef)).
      - (* Hext_action (reached-gated) *)
        exact Hext_action.
      - (* Hmwf_ext *)
        exact Hmwf_ext.
      - (* Hmwf_entry *)
        exact Hmwf_entry.
      - (* Hmwf_free *)
        exact Hmwf_free.
      - (* Hmwf_noa *)
        exact Hmwf_noa.
      - (* HCseq1 *)
        intros bc s1 s2 HC. exact (chk_seq1 bc s1 s2 HC).
      - (* HCseq2 *)
        intros bc e le m0 s1 s2 t1 le1 m1 HC Hex1.
        exact (chk_seq2 lp bc e le m0 s1 s2 t1 le1 m1 HC Hex1).
      - (* HCif: the gate kill *)
        intros bc e le m0 a s1 s2 v1 b HC _ _ [HTI _] Hev0 Hbv.
        exact (chk_if lp not_tainted bm SafeB bc e le m0 a s1 s2 v1 b
                 HC HTI Hev0 Hbv).
      - (* HCloop *)
        exact chk_loop.
      - (* HCsw: the dispatch kill *)
        intros bc e le m0 a ls v n HC _ _ [HTI _] Hev0 Hsa.
        exact (chk_sw lp bm SafeB bc e le m0 a ls v n HC HTI Hev0 Hsa). }
    intros m fd vargs t m' vres Hrf HnoA HMWF Hmarg Hsargs Hev Hv Hsat.
    exact (HV2 m fd vargs t m' vres Hrf HnoA HMWF Hmarg (fun _ => I)
             Hsargs Hev Hv Hsat).
  Qed.

End V2Consumer.
