(* ====================================================================== *)
(* THE AUTOMATIC-FAMILY LEAF SURFACE (SPINE: automatic_leaf_callees_pres   *)
(* SHRINKS the capstone's automatic census via an incremental rest-split). *)
(*                                                                        *)
(* automatic_callee_ids (AutomaticSurface) is the 17 act_* leaves the     *)
(* automatic dispatcher delegates to. This file walks them one cluster at *)
(* a time: automatic_callee_ids = <walked prefix> ++ automatic_rest_ids,  *)
(* the capstone consumes the proved prefix and assumes only the shrinking  *)
(* rest (the object-family object_callee_ids_rest pattern).               *)
(*                                                                        *)
(* SLICE 1: check_common_automatic_cancels -- its sole callee is          *)
(* set_water_plunge_action, ALREADY proved as ObjectLeafSurface.swpa_row  *)
(* (no chase, no wact): census 17 -> 16.                                 *)
(* ====================================================================== *)

From Coq Require Import ZArith Lia List.
From compcert Require Import Coqlib Maps AST Integers Values Events Memory
  Globalenvs Ctypes Cop Clightdefs Clight ClightBigstep Linking Errors.
From SM64.Generated Require mario mario_step mario_actions_automatic.
From SM64.Proofs Require Import SymbolicLinking Flying Taint
  ActionValueFrame RealFrameValue RealFrameLinked AGates.
From SM64.Proofs Require Import CensusV2 EngineV2Consumer RestSurface
  AirborneSurface DispatchKit FloorsSurface AutomaticSurface.
From SM64.Proofs Require Import ActWriterSurface ObjectLeafSurface.

Import ListNotations.

(* the 16 leaves NOT yet walked (the tail of automatic_callee_ids): every
   slice moves ids out of here into the proved set. *)
Definition automatic_rest_ids : list ident :=
  mario_actions_automatic._act_holding_pole ::
  mario_actions_automatic._act_grab_pole_slow ::
  mario_actions_automatic._act_grab_pole_fast ::
  mario_actions_automatic._act_climbing_pole ::
  mario_actions_automatic._act_top_of_pole_transition ::
  mario_actions_automatic._act_top_of_pole ::
  mario_actions_automatic._act_start_hanging ::
  mario_actions_automatic._act_hanging ::
  mario_actions_automatic._act_hang_moving ::
  mario_actions_automatic._act_ledge_grab ::
  mario_actions_automatic._act_ledge_climb_slow ::
  mario_actions_automatic._act_ledge_climb_down ::
  mario_actions_automatic._act_ledge_climb_fast ::
  mario_actions_automatic._act_grabbed ::
  mario_actions_automatic._act_in_cannon ::
  mario_actions_automatic._act_tornado_twirling :: nil.

(* sanity: automatic_callee_ids = ccac :: automatic_rest_ids, definitionally *)
Example automatic_split_ok :
  automatic_callee_ids
  = mario_actions_automatic._check_common_automatic_cancels
      :: automatic_rest_ids.
Proof. vm_compute. reflexivity. Qed.

(* ---- ccac pins/shape ---- *)
Definition ccac_ids : list ident := mario._set_water_plunge_action :: nil.

Example ccac_pin :
  (prog_defmap mario_actions_automatic.prog)
    ! mario_actions_automatic._check_common_automatic_cancels
  = Some (Gfun (Internal
      mario_actions_automatic.f_check_common_automatic_cancels)).
Proof. vm_compute. reflexivity. Qed.
Example ccac_vars :
  fn_vars mario_actions_automatic.f_check_common_automatic_cancels = nil.
Proof. reflexivity. Qed.
Example ccac_params_ok :
  match fn_params mario_actions_automatic.f_check_common_automatic_cancels with
  | (i, ty) :: ps =>
      (Pos.eqb i mario_actions_airborne._m
       && proj_sumbool (type_eq ty tyMSp)
       && negb (mem_id mario_actions_airborne._m (map fst ps)))%bool
  | nil => false
  end = true.
Proof. vm_compute. reflexivity. Qed.
Example ccac_walk :
  wwalk_chk false nil ccac_ids nil nil nil nil nil
    (fn_body mario_actions_automatic.f_check_common_automatic_cancels) = true.
Proof. vm_compute. reflexivity. Qed.

(* ====================================================================== *)
(* The rows.                                                              *)
(* ====================================================================== *)

Section AutomaticLeafRows.
  Variable lp : Clight.program.
  Hypothesis LO_mario : linkorder mario.prog lp.
  Hypothesis LO_mario_step : linkorder mario_step.prog lp.
  Hypothesis LO_aut : linkorder mario_actions_automatic.prog lp.

  Variable bm : block.
  Variable NoA MWF : mem -> Prop.

  Hypothesis HNoA_of_MWF : forall m, MWF m -> NoA m.
  Hypothesis HMWF_window : forall mm mm' ch (delta : Z) vv,
      MWF mm -> store_window_ok delta (size_chunk ch) = true ->
      Mem.store ch mm bm delta vv = Some mm' -> MWF mm'.
  Hypothesis HMWF_glob : forall gid,
      mem_id gid stored_globals = true ->
      forall bg, Genv.find_symbol (lp_ge lp) gid = Some bg ->
      bg <> bm /\
      (forall mm mm' ch0 (d : Z) vv,
          MWF mm -> Mem.store ch0 mm bg d vv = Some mm' -> MWF mm').
  Hypothesis HMWF_act : forall mm mm' vv,
      MWF mm ->
      (forall bb oo, vv <> Vptr bb oo) ->
      Mem.store Mint32 mm bm 12 vv = Some mm' -> MWF mm'.

  Variable SafeB : block -> Prop.
  Hypothesis HSafeNotBm : forall b, SafeB b -> b <> bm.
  Hypothesis HchaseRoot : forall fld delta m b' o',
      mem_id fld chase_root_fields = true ->
      field_offset (prog_comp_env mario.prog) fld mario_state_members
        = OK (delta, Full) ->
      MWF m ->
      Mem.loadv Mptr m
        (Vptr bm (Ptrofs.add Ptrofs.zero (Ptrofs.repr delta)))
        = Some (Vptr b' o') ->
      SafeB b'.
  Hypothesis HMWF_chase : forall mm ch bsafe (d : Z) vv mm',
      MWF mm -> SafeB bsafe ->
      (forall bb oo, vv <> Vptr bb oo) ->
      Mem.store ch mm bsafe d vv = Some mm' -> MWF mm'.
  Hypothesis HMWF_root : forall mm mm' fld (delta : Z) vv,
      mem_id fld chase_root_fields = true ->
      field_offset (prog_comp_env mario.prog) fld mario_state_members
        = OK (delta, Full) ->
      (forall bb oo, vv = Vptr bb oo -> SafeB bb) ->
      MWF mm ->
      Mem.store Mptr mm bm delta vv = Some mm' -> MWF mm'.
  Hypothesis HMWF_sglob : forall m gb v,
      MWF m ->
      Genv.find_symbol (lp_ge lp) interaction._gGlobalTimer = Some gb ->
      Mem.load Mint32 m gb 0 = Some v ->
      forall bb oo, v <> Vptr bb oo.
  Hypothesis HchaseStep : forall m b ofs b' o',
      MWF m -> SafeB b ->
      Mem.loadv Mptr m (Vptr b ofs) = Some (Vptr b' o') ->
      SafeB b'.
  Hypothesis HMWF_chase_safe : forall mm ch bsafe (d : Z) vv mm',
      MWF mm -> SafeB bsafe ->
      (forall bb oo, vv = Vptr bb oo -> SafeB bb) ->
      Mem.store ch mm bsafe d vv = Some mm' -> MWF mm'.

  (* ext rows consumed by set_water_plunge_action (obj_ext_ids: SHARED) *)
  Hypothesis Hcpx_v3s :
    call_pres_ext lp bm NoA MWF mario._vec3s_set.
  Hypothesis Hcpx_scm :
    call_pres_ext lp bm NoA MWF mario._set_camera_mode.

  (* the shrinking residual: the 16 leaves not yet walked *)
  Hypothesis Hpres_aut_rest : forall fid f,
      mem_id fid automatic_rest_ids = true ->
      (prog_defmap mario_actions_automatic.prog) ! fid
        = Some (Gfun (Internal f)) ->
      body_pres lp NoA MWF bm f.

  (* set_water_plunge_action's call_pres row, reused from the object family *)
  Let Hswpa : call_pres lp bm NoA MWF mario._set_water_plunge_action :=
    swpa_row lp LO_mario LO_mario_step bm NoA MWF HNoA_of_MWF HMWF_window
      HMWF_glob HMWF_act SafeB HSafeNotBm HchaseRoot HMWF_chase HMWF_root
      HMWF_sglob HchaseStep HMWF_chase_safe Hcpx_v3s Hcpx_scm.

  Lemma ccac_ids_rows :
    forall fid, mem_id fid ccac_ids = true ->
      call_pres lp bm NoA MWF fid.
  Proof.
    intros fid H. unfold ccac_ids in H. cbn [mem_id existsb] in H.
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact Hswpa | ].
    discriminate H.
  Qed.

  (* ---- check_common_automatic_cancels: ids = [set_water_plunge_action] *)
  Lemma ccac_pres :
    body_pres lp NoA MWF bm
      mario_actions_automatic.f_check_common_automatic_cancels.
  Proof.
    apply (body_pres_of_wwalk lp LO_mario bm NoA MWF HNoA_of_MWF
             HMWF_window HMWF_glob HMWF_act SafeB HSafeNotBm HchaseRoot
             HMWF_chase HMWF_root HMWF_sglob HchaseStep HMWF_chase_safe
             mario_actions_automatic.f_check_common_automatic_cancels
             ccac_ids nil nil nil nil
             ccac_vars ccac_params_ok).
    - exact ccac_ids_rows.
    - intros fid' H. discriminate H.
    - intros fid' H. discriminate H.
    - intros fid' H. discriminate H.
    - intros fid' H. discriminate H.
    - exact ccac_walk.
  Qed.

  (* ================================================================== *)
  (* THE PAYOFF: the capstone's automatic-leaf census, with ccac PROVED  *)
  (* and the remaining 16 deferred to the (smaller) rest residual.       *)
  (* ================================================================== *)
  Lemma automatic_leaf_callees_pres :
    forall fid f,
      mem_id fid automatic_callee_ids = true ->
      (prog_defmap mario_actions_automatic.prog) ! fid
        = Some (Gfun (Internal f)) ->
      body_pres lp NoA MWF bm f.
  Proof.
    intros fid f H Hdm.
    rewrite automatic_split_ok in H. cbn [mem_id existsb] in H.
    apply orb_true_iff in H as [Hm | Hrest].
    { apply Pos.eqb_eq in Hm. subst fid.
      rewrite ccac_pin in Hdm. injection Hdm as <-. exact ccac_pres. }
    exact (Hpres_aut_rest fid f Hrest Hdm).
  Qed.

End AutomaticLeafRows.
