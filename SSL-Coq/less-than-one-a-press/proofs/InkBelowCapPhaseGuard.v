(** A phase-independent, binary32 obstruction at the actual floor-list gate.

    The old and retry base heights below are integer bounds, not a substituted
    floor routine. The actual loaded-plane height is allowed to lie TEN units
    below the retry base. Its lower bound remains an explicit live-geometry
    obligation. This file does not infer a binary32 plane bound merely from
    vertex minima, nor does it infer the integer query bound from a wrapping
    display coordinate or an earlier synchronized pose. *)
From Coq Require Import Bool Lia List ZArith Reals Lra.
From Flocq Require Import BinarySingleNaN Binary Core.
From compcert Require Import AST Clight ClightBigstep Clightdefs Cop Ctypes Events Floats
  Integers Maps Memory Values.
From LessThanOneAPress.Proofs Require Import GameTypes Area2Rank9ACoinFlight
  Area2Rank12BContact InkVerticalLiveSelection ObjectContactNecessity.
Import ListNotations.
Local Open Scope Z_scope.
Local Transparent Float32.cmp Float32.compare.

Definition ibcpg_negative78 :=
  Float32.neg (Float32.of_bits (Int.repr 1117519872)).
Definition ibcpg_difference query height :=
  Float32.sub (Float32.of_int query) (Float32.add height ibcpg_negative78).

Lemma ibcpg_negative78_exact :
  ibcpg_negative78 = rank9cf_integer (-78).
Proof. apply rank9cf_bits_injective; vm_compute; reflexivity. Qed.

(** This covers every signed-16 query integer and every finite binary32
    height meeting the bounds. It is not a sampling of display heights. *)
Theorem ibcpg_below_body_buffer_is_negative : forall query height old_base retry_base,
  -32768 <= Int.signed query <= 32767 ->
  0 <= old_base <= 32768 -> 0 <= retry_base <= 32768 ->
  old_base - retry_base <= 10 ->
  Int.signed query + 100 <= old_base ->
  rank9cf_finite height ->
  (IZR (retry_base - 10) <= rank9cf_real height <= 32768)%R ->
  rank9cf_finite (ibcpg_difference query height) /\
  (rank9cf_real (ibcpg_difference query height) <= -2)%R /\
  Float32.cmp Clt (ibcpg_difference query height) Float32.zero = true.
Proof.
  intros query height old_base retry_base Hq Hbo Hbr Hdrop Hbody Fh Hheight.
  destruct (rank9cf_integer_exact (Int.signed query) ltac:(lia)) as [Rq Fq].
  unfold rank9cf_integer in Rq, Fq. rewrite Int.repr_signed in Rq, Fq.
  destruct (rank9cf_integer_exact (-78) ltac:(lia)) as [Rn Fn].
  rewrite <- ibcpg_negative78_exact in Rn, Fn.
  assert (Hsum : (IZR (retry_base - 88) <=
      rank9cf_real height + rank9cf_real ibcpg_negative78 <= IZR 32768)%R).
  { rewrite Rn, minus_IZR in *. cbn in *. lra. }
  destruct (rank9cf_add_range height ibcpg_negative78 (retry_base - 88) 32768
    Fh Fn ltac:(lia) ltac:(lia) ltac:(lia) Hsum) as [Fsum Rsum].
  assert (Rqbounds : (-32768 <= rank9cf_real (Float32.of_int query) <= 32767)%R).
  { rewrite Rq. split; apply IZR_le; lia. }
  assert (Rbody : (IZR (Int.signed query) + 100 <= IZR old_base)%R).
  { pose proof (IZR_le _ _ Hbody). rewrite plus_IZR in H. exact H. }
  assert (Rdrop : (IZR old_base - IZR retry_base <= 10)%R).
  { pose proof (IZR_le _ _ Hdrop). rewrite minus_IZR in H. exact H. }
  assert (Rdiff : (IZR (-65536) <= rank9cf_real (Float32.of_int query) -
      rank9cf_real (Float32.add height ibcpg_negative78) <= IZR (-2))%R).
  { rewrite minus_IZR in Rsum. cbn in Rsum |- *. rewrite Rq in *. lra. }
  destruct (rank12b_sub_range (Float32.of_int query)
    (Float32.add height ibcpg_negative78) (-65536) (-2)
    Fq Fsum ltac:(lia) ltac:(lia) ltac:(lia) Rdiff) as [Fd Rd].
  change (rank9cf_finite (ibcpg_difference query height)) in Fd.
  change ((-65536 <= rank9cf_real (ibcpg_difference query height) <= -2)%R) in Rd.
  split; [exact Fd|]. split; [lra|].
  unfold Float32.cmp, Float32.compare.
  rewrite Bcompare_correct; try exact Fd; try reflexivity.
  change (match Rcompare (rank9cf_real (ibcpg_difference query height)) 0 with
    | Lt => true | _ => false end = true).
  destruct (Rcompare_spec (rank9cf_real (ibcpg_difference query height)) 0);
    cbn; try reflexivity; lra.
Qed.

Definition ibcpg_source_guard := Ebinop Olt
  (Ebinop Osub (Etempvar IVL._y tint)
    (Ebinop Oadd (Etempvar IVL._height tfloat)
      (Eunop Oneg (Econst_single (Float32.of_bits (Int.repr 1117519872)) tfloat)
        tfloat) tfloat) tfloat)
  (Econst_single Float32.zero tfloat) tint.

Lemma ibcpg_generated_gate : forall version,
  ivl_stmt version 19 = Sifthenelse ibcpg_source_guard Scontinue Sskip.
Proof. intros []; reflexivity. Qed.

Lemma ibcpg_actual_guard_evaluates : forall ge e le m query height,
  le ! IVL._y = Some (Vint query) ->
  le ! IVL._height = Some (Vsingle height) ->
  Float32.cmp Clt (ibcpg_difference query height) Float32.zero = true ->
  eval_expr ge e le m ibcpg_source_guard (Vint Int.one).
Proof.
  intros ge e le m query height Hq Hh Htest. unfold ibcpg_source_guard.
  eapply eval_Ebinop.
  - eapply eval_Ebinop.
    + apply eval_Etempvar. exact Hq.
    + eapply eval_Ebinop.
      * apply eval_Etempvar. exact Hh.
      * eapply eval_Eunop; [constructor|reflexivity].
      * reflexivity.
    + reflexivity.
  - constructor.
  - change (Some (Val.of_bool (Float32.cmp Clt
      (ibcpg_difference query height) Float32.zero)) = Some (Vint Int.one)).
    rewrite Htest. reflexivity.
Qed.

(** The true source branch is continue: it precedes the height-output store
    and the selected-surface store. This constructs the actual gate execution
    and returns unchanged memory and locals. Reaching this gate with these
    live plane values and covering all candidate nodes remain explicit work. *)
Definition InkBelowCapActualFloorGate : Prop :=
  forall version ge e le m query height old_base retry_base,
  -32768 <= Int.signed query <= 32767 ->
  0 <= old_base <= 32768 -> 0 <= retry_base <= 32768 ->
  old_base - retry_base <= 10 ->
  Int.signed query + 100 <= old_base ->
  rank9cf_finite height ->
  (IZR (retry_base - 10) <= rank9cf_real height <= 32768)%R ->
  le ! IVL._y = Some (Vint query) ->
  le ! IVL._height = Some (Vsingle height) ->
  ocn_exec ge e le m (ivl_stmt version 19) E0 le m Out_continue.

Theorem ibcpg_below_cap_query_rejects_this_surface : InkBelowCapActualFloorGate.
Proof.
  intros version ge e le m query height old_base retry_base
    Hq Hbo Hbr Hdrop Hbody Fh Hheight Hquery Hloaded.
  destruct (ibcpg_below_body_buffer_is_negative _ _ _ _ Hq Hbo Hbr Hdrop
    Hbody Fh Hheight) as (_ & _ & Hreject).
  rewrite ibcpg_generated_gate.
  eapply exec_Sifthenelse with (v1 := Vint Int.one) (b := true).
  - eapply ibcpg_actual_guard_evaluates; eauto.
  - reflexivity.
  - constructor.
Qed.

Definition InkBelowCapPhaseGuardBoundary : Prop := InkBelowCapActualFloorGate.
Theorem ibcpg_below_cap_phase_guard_checked : InkBelowCapPhaseGuardBoundary.
Proof. exact ibcpg_below_cap_query_rejects_this_surface. Qed.
