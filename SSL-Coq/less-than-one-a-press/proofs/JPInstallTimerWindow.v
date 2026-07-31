(**
  Arithmetic classification of the conditional Japanese pyramid-top
  installation schedule.

  The constants below are copied from the hash-gated timer sweep, not asserted
  to be a whole-program reachability result.  In that experiment top action
  timer [t] is first observed at global timer [361 + t], the delayed warp stops
  Area-1 object updates at global timer [383 + t], and the top's normal
  explosion/deallocation update is global timer 513.  The one-tick interval
  after that deallocation is decisive:

  - a freeze at or before 513 unloads the still-live top during area teardown;
  - a freeze at 514 retains the already-freed slot without another final floor
    query; and
  - a freeze at or after 515 permits an intervening Area-1 update to clear the
    platform pointer.

  The file proves that timer 131 is the unique timer in the behavior's
  0..150 range with the middle arithmetic shape.  Linking the observed global
  offsets and each lifecycle case to live Clight memory remains an explicitly
  separate refinement obligation.
*)

From Coq Require Import Lia ZArith.

Local Open Scope Z_scope.

Definition jp_top_install_global_timer (top_timer : Z) : Z :=
  361 + top_timer.

Definition jp_delayed_warp_freeze_global_timer (top_timer : Z) : Z :=
  jp_top_install_global_timer top_timer + 22.

Definition jp_top_explosion_free_global_timer : Z := 513.

Inductive JPInstallTimerClass : Type :=
| FreezeBeforeExplosion
| FreezeImmediatelyAfterExplosion
| LiveTickAfterExplosion.

Definition classify_jp_install_timer (top_timer : Z) : JPInstallTimerClass :=
  let freeze := jp_delayed_warp_freeze_global_timer top_timer in
  if Z.leb freeze jp_top_explosion_free_global_timer then
    FreezeBeforeExplosion
  else if Z.eqb freeze (jp_top_explosion_free_global_timer + 1) then
    FreezeImmediatelyAfterExplosion
  else
    LiveTickAfterExplosion.

Theorem jp_install_global_timer_is_affine :
  forall top_timer,
    jp_top_install_global_timer top_timer = 361 + top_timer.
Proof. reflexivity. Qed.

Theorem jp_delayed_warp_freeze_timer_is_affine :
  forall top_timer,
    jp_delayed_warp_freeze_global_timer top_timer = 383 + top_timer.
Proof. intros; unfold jp_delayed_warp_freeze_global_timer,
  jp_top_install_global_timer; lia. Qed.

Theorem jp_timer_at_most_130_freezes_before_explosion :
  forall top_timer,
    top_timer <= 130 ->
    classify_jp_install_timer top_timer = FreezeBeforeExplosion.
Proof.
  intros top_timer Htimer.
  unfold classify_jp_install_timer,
    jp_delayed_warp_freeze_global_timer,
    jp_top_install_global_timer,
    jp_top_explosion_free_global_timer.
  assert (Hbefore : (361 + top_timer + 22 <=? 513) = true).
  { apply Z.leb_le; lia. }
  rewrite Hbefore.
  reflexivity.
Qed.

Theorem jp_timer_131_freezes_immediately_after_explosion :
  classify_jp_install_timer 131 = FreezeImmediatelyAfterExplosion.
Proof. vm_compute. reflexivity. Qed.

Theorem jp_timer_at_least_132_has_live_tick_after_explosion :
  forall top_timer,
    132 <= top_timer ->
    classify_jp_install_timer top_timer = LiveTickAfterExplosion.
Proof.
  intros top_timer Htimer.
  unfold classify_jp_install_timer,
    jp_delayed_warp_freeze_global_timer,
    jp_top_install_global_timer,
    jp_top_explosion_free_global_timer.
  assert (Hafter : (361 + top_timer + 22 <=? 513) = false).
  { apply Z.leb_gt; lia. }
  assert (Hnot_exact : (361 + top_timer + 22 =? 513 + 1) = false).
  { apply Z.eqb_neq; lia. }
  rewrite Hafter, Hnot_exact.
  reflexivity.
Qed.

Theorem jp_timer_131_is_unique_immediate_post_explosion_freeze :
  forall top_timer,
    0 <= top_timer <= 150 ->
    classify_jp_install_timer top_timer =
      FreezeImmediatelyAfterExplosion ->
    top_timer = 131.
Proof.
  intros top_timer Hrange Hclass.
  destruct (Z_lt_le_dec top_timer 131) as [Hlt | Hge].
  - pose proof (jp_timer_at_most_130_freezes_before_explosion
                  top_timer ltac:(lia)) as Hbefore.
    rewrite Hbefore in Hclass.
    discriminate.
  - destruct (Z.eq_dec top_timer 131) as [Heq | Hneq].
    + exact Heq.
    + pose proof (jp_timer_at_least_132_has_live_tick_after_explosion
                    top_timer ltac:(lia)) as Hafter.
      rewrite Hafter in Hclass.
      discriminate.
Qed.

(** The exact remaining semantic bridge.  It is a definition of the required
    evidence, not an assumed axiom and is not consumed by the arithmetic
    theorems above. *)
Record JPInstallTimerWindowRefinement : Prop := {
  jp_timer_refinement_install_offset :
    forall top_timer,
      0 <= top_timer <= 150 ->
      jp_top_install_global_timer top_timer = 361 + top_timer;
  jp_timer_refinement_freeze_offset :
    forall top_timer,
      0 <= top_timer <= 150 ->
      jp_delayed_warp_freeze_global_timer top_timer = 383 + top_timer;
  jp_timer_refinement_early_case :
    forall top_timer,
      0 <= top_timer <= 130 ->
      classify_jp_install_timer top_timer = FreezeBeforeExplosion;
  jp_timer_refinement_exact_case :
    classify_jp_install_timer 131 = FreezeImmediatelyAfterExplosion;
  jp_timer_refinement_late_case :
    forall top_timer,
      132 <= top_timer <= 150 ->
      classify_jp_install_timer top_timer = LiveTickAfterExplosion
}.

Theorem jp_install_timer_window_arithmetic_refinement :
  JPInstallTimerWindowRefinement.
Proof.
  constructor.
  - intros; apply jp_install_global_timer_is_affine.
  - intros; apply jp_delayed_warp_freeze_timer_is_affine.
  - intros top_timer Hrange.
    apply jp_timer_at_most_130_freezes_before_explosion; lia.
  - exact jp_timer_131_freezes_immediately_after_explosion.
  - intros top_timer Hrange.
    apply jp_timer_at_least_132_has_live_tick_after_explosion; lia.
Qed.
