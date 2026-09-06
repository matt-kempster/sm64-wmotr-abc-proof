From Coq Require Import List ZArith.
From compcert Require Import AST Clight Clightdefs ClightBigstep Cop Ctypes
  Events Floats Integers Maps Memory Values.
From Pedro.Generated Require Import us_mario_step jp_mario_step.
From Pedro.Proofs Require Import GameTypes.

Open Scope Z_scope.
Module GG := us_mario_step.

(** Select a suffix of the ORIGINAL generated statement. The shape theorem
    below checks the selection in both versions; this is not a replacement
    collision routine. The wall/floor/ceiling queries before this suffix and
    the outer ground-step loop remain separate execution obligations. *)
Fixpoint ground_right_suffix (count : nat) (body : statement) : statement :=
  match count, body with
  | O, _ => body
  | S n, Ssequence _ rest => ground_right_suffix n rest
  | _, _ => Sskip
  end.

Definition ground_gap_suffix (version : GameVersion) : statement :=
  ground_right_suffix 9 (fn_body
    (match version with
     | VersionUS => GG.f_perform_ground_quarter_step
     | VersionJP => jp_mario_step.f_perform_ground_quarter_step end)).

Definition ground_gap_guard : statement :=
  Sifthenelse
    (Ebinop Oge
      (Ebinop Oadd (Etempvar GG._floorHeight tfloat)
        (Econst_single (Float32.of_bits (Int.repr 1126170624)) tfloat) tfloat)
      (Etempvar GG._ceilHeight tfloat) tint)
    (Sreturn (Some (Econst_int (Int.repr 2) tint))) Sskip.

Theorem ground_gap_suffix_shape_us_jp :
  forall version, exists continuation,
    ground_gap_suffix version = Ssequence ground_gap_guard continuation.
Proof. intros []; eexists; reflexivity. Qed.

Theorem generated_ground_gap_returns_without_writes_us_jp :
  forall version ge environment locals memory floor_height ceiling_height,
    locals ! GG._floorHeight = Some (Vsingle floor_height) ->
    locals ! GG._ceilHeight = Some (Vsingle ceiling_height) ->
    Float32.cmp Cge
      (Float32.add floor_height (Float32.of_bits (Int.repr 1126170624)))
      ceiling_height = true ->
    exec_stmt function_entry2 ge environment locals memory
      (ground_gap_suffix version) E0 locals memory
      (Out_return (Some (Vint (Int.repr 2), tint))).
Proof.
  intros version ge environment locals memory floor_height ceiling_height
    Hfloor Hceiling Hgap.
  destruct (ground_gap_suffix_shape_us_jp version) as [continuation Hshape].
  rewrite Hshape. eapply exec_Sseq_2; [|discriminate].
  unfold ground_gap_guard.
  eapply exec_Sifthenelse with (b := true).
  - eapply eval_Ebinop.
    + eapply eval_Ebinop.
      * eapply eval_Etempvar. exact Hfloor.
      * constructor.
      * cbn. reflexivity.
    + eapply eval_Etempvar. exact Hceiling.
    + cbn. rewrite Hgap. reflexivity.
  - reflexivity.
  - eapply exec_Sreturn_some. constructor.
Qed.

Theorem cog_154_gap_satisfies_ground_return_test :
  Float32.cmp Cge
    (Float32.add (Float32.of_int (Int.repr (-2088)))
      (Float32.of_bits (Int.repr 1126170624)))
    (Float32.of_int (Int.repr (-1934))) = true.
Proof. vm_compute; reflexivity. Qed.

Definition cog_gap_return_claim : Prop :=
  forall version ge environment locals memory,
    locals ! GG._floorHeight =
      Some (Vsingle (Float32.of_int (Int.repr (-2088)))) ->
    locals ! GG._ceilHeight =
      Some (Vsingle (Float32.of_int (Int.repr (-1934)))) ->
    exec_stmt function_entry2 ge environment locals memory
      (ground_gap_suffix version) E0 locals memory
      (Out_return (Some (Vint (Int.repr 2), tint))).

Theorem checked_cog_gap_return_us_jp : cog_gap_return_claim.
Proof.
  intros version ge environment locals memory Hfloor Hceil.
  eapply generated_ground_gap_returns_without_writes_us_jp;
    [exact Hfloor | exact Hceil | exact cog_154_gap_satisfies_ground_return_test].
Qed.
