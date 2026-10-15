From Coq Require Import List ZArith.
From compcert Require Import AST Clight Clightdefs ClightBigstep Coqlib Cop
  Ctypes Errors Events Globalenvs Integers Maps Memdata Memory Values.
From Demo.Generated Require Import us_level_update jp_level_update.
From Demo.Proofs Require Import DemoStartExecution DemoGameplayBoundary.
Import ListNotations.
Local Open Scope Z_scope.
Module W := us_level_update.

(** In the same normal frame in which Demo Next is scheduled with timer 20,
    the delayed dispatcher decrements that timer to 19 and takes no call path.
    This removes one concrete intervening scheduler obligation; it does not
    frame the object/camera calls earlier in play_mode_normal. *)
Definition demo_pending_dispatch_execution_claim : Prop :=
  forall (ge : Clight.genv) before operation timer,
    Genv.find_symbol ge W._sDelayedWarpOp = Some operation ->
    Genv.find_symbol ge W._sDelayedWarpTimer = Some timer ->
    operation <> timer ->
    Mem.load Mint16signed before operation 0 = Some (Vint (Int.repr 22)) ->
    Mem.load Mint16signed before timer 0 = Some (Vint (Int.repr 20)) ->
    Mem.valid_access before Mint16signed timer 0 Writable ->
    exists after,
      eval_funcall function_entry2 ge before
        (Internal W.f_initiate_delayed_warp) [] E0 after Vundef /\
      eval_funcall function_entry2 ge before
        (Internal jp_level_update.f_initiate_delayed_warp) [] E0 after Vundef /\
      Mem.load Mint16signed after operation 0 = Some (Vint (Int.repr 22)) /\
      Mem.load Mint16signed after timer 0 = Some (Vint (Int.repr 19)) /\
      (forall chunk b ofs, b <> timer ->
        Mem.load chunk after b ofs = Mem.load chunk before b ofs).

Theorem generated_scheduled_demo_warp_stays_pending_us_jp :
  demo_pending_dispatch_execution_claim.
Proof.
  intros ge before operation timer Hoperation Htimer Hseparate Hop Htimerread Hw.
  destruct (Mem.valid_access_store before Mint16signed timer 0
    (Vint (Int.repr 19)) Hw) as [after Hstore].
  assert (Hcall : eval_funcall function_entry2 ge before
    (Internal W.f_initiate_delayed_warp) [] E0 after Vundef).
  { eapply eval_funcall_internal with (e := empty_env)
      (le1 := create_undef_temps (fn_temps W.f_initiate_delayed_warp))
      (m1 := before) (m2 := after) (out := Out_normal).
    - constructor.
      + constructor.
      + constructor.
      + unfold list_disjoint. cbn. tauto.
      + constructor.
      + reflexivity.
    - cbn [W.f_initiate_delayed_warp fn_body]. game_control_stmt.
    - reflexivity.
    - reflexivity. }
  exists after. split; [exact Hcall |].
  split; [exact Hcall |]. split.
  - rewrite (Mem.load_store_other _ _ _ _ _ _ Hstore) by (left; congruence).
    exact Hop.
  - split.
    + rewrite (Mem.load_store_same _ _ _ _ _ _ Hstore). reflexivity.
    + intros chunk b ofs Hbt.
      rewrite (Mem.load_store_other _ _ _ _ _ _ Hstore) by (left; congruence).
      reflexivity.
Qed.

(** A real zero destination type makes the entire warp_area call a no-op.
    With a nonzero type it can invoke init_mario_after_warp, which clears the
    delayed operation; that alternate route cannot be erased from a frame
    theorem merely because a demo is active. *)
Definition demo_zero_destination_warp_area_execution_claim : Prop :=
  forall (ge : Clight.genv) m warp warp_co,
    Genv.find_symbol ge W._sWarpDest = Some warp ->
    (genv_cenv ge) ! W._WarpDest = Some warp_co ->
    field_offset (genv_cenv ge) W._type (co_members warp_co) = OK (0, Full) ->
    Mem.load Mint8unsigned m warp 0 = Some Vzero ->
    eval_funcall function_entry2 ge m (Internal W.f_warp_area) [] E0 m Vundef /\
    eval_funcall function_entry2 ge m (Internal jp_level_update.f_warp_area)
      [] E0 m Vundef.

Theorem generated_zero_destination_warp_area_skips_us_jp :
  demo_zero_destination_warp_area_execution_claim.
Proof.
  intros ge m warp warp_co Hwarp Hco Hfield Hload.
  assert (Hcall : eval_funcall function_entry2 ge m
    (Internal W.f_warp_area) [] E0 m Vundef).
  { eapply eval_funcall_internal with (e := empty_env)
      (le1 := create_undef_temps (fn_temps W.f_warp_area))
      (m1 := m) (m2 := m) (out := Out_normal).
    - constructor.
      + constructor.
      + constructor.
      + unfold list_disjoint. cbn. tauto.
      + constructor.
      + reflexivity.
    - cbn [W.f_warp_area fn_body]. game_control_stmt.
    - reflexivity.
    - reflexivity. }
  split; exact Hcall.
Qed.

Definition demo_start_warp_execution_claim : Prop :=
  demo_pending_dispatch_execution_claim /\
  demo_zero_destination_warp_area_execution_claim.

Theorem generated_demo_start_warp_execution_us_jp :
  demo_start_warp_execution_claim.
Proof.
  split.
  - exact generated_scheduled_demo_warp_stays_pending_us_jp.
  - exact generated_zero_destination_warp_area_skips_us_jp.
Qed.
