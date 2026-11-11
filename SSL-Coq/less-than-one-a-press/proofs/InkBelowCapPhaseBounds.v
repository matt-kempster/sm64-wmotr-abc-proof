(** Stock vertical phase arithmetic, including the early non-monotone bob.

    Stored phase0 is the home pose. Stored phase(p+1) uses the pose after
    executing spinning timer p, matching the existing timer130/131 convention.
    HomeY1536, initial vertical velocity0, unit scale, pitch/roll0 and a fresh
    transform are explicit stock-pose inputs to this finite calculation.
    No theorem here identifies an arbitrary live throwMatrix or surface list
    with that calculation. In particular the loaded-plane lower bound in the
    final actual-gate theorem is retained, with ten units of slack. *)
From Coq Require Import Bool Lia List PeanoNat ZArith Reals.
From compcert Require Import AST Clight ClightBigstep Clightdefs Cop Ctypes Events Floats
  Integers Maps Memory Values.
From LessThanOneAPress.Generated Require Import us_obj_behaviors jp_obj_behaviors
  us_math_util jp_math_util.
From LessThanOneAPress.Proofs Require Import GameTypes Timer131Surface
  InkTimer130Geometry InkBelowCapPhaseGuard InkVerticalLiveSelection
  InkBackwardSource InkBackwardExecution Area2Rank12BContact Area2Rank9ACoinFlight
  ObjectContactNecessity PyramidTopSurface PyramidTopPU.
Import ListNotations.
Local Open Scope Z_scope.
Module BCP := us_obj_behaviors.

Definition ibcp_spin_body version := match version with
| VersionUS => us_obj_behaviors.f_bhv_pyramid_top_spinning
| VersionJP => jp_obj_behaviors.f_bhv_pyramid_top_spinning end.
Definition ibcp_abs_body version := match version with
| VersionUS => us_obj_behaviors.f_absf_2
| VersionJP => jp_obj_behaviors.f_absf_2 end.
Definition ibcp_vertical_choice version :=
  ibk_head (rank12b_drop_sequences 1 (fn_body (ibcp_spin_body version))).
Definition ibcp_early version := match rank12b_drop_sequences 2 (ibcp_vertical_choice version) with
| Sifthenelse _ early _ => early | _ => Sskip end.
Definition ibcp_early_abs_call version :=
  rank12b_drop_sequences 3 (ibk_head (ibcp_early version)).
Definition ibcp_early_sine_load version :=
  ibk_head (rank12b_drop_sequences 2 (ibk_head (ibcp_early version))).
Definition ibcp_early_height_store version :=
  rank12b_drop_sequences 3 (rank12b_drop_sequences 1 (ibcp_early version)).
Definition ibcp_store_rhs s := match s with Sassign _ a => a | _ => Econst_int Int.zero tint end.

Definition InkBelowCapEarlySourceCuts : Prop := forall version,
  ibcp_early_sine_load version = Sset BCP._t'36
    (Ederef (Ebinop Oadd (Evar BCP._gSineTable (tarray tfloat 0))
      (Ebinop Oshr (Ecast (Ebinop Omul (Etempvar BCP._t'35 tint)
        (Econst_int (Int.repr 8192) tint) tint) tushort)
        (Econst_int (Int.repr 4) tint) tint) (tptr tfloat)) tfloat) /\
  ibcp_early_abs_call version = Scall (Some BCP._t'1)
    (Evar BCP._absf_2 (Tfunction [tfloat] tfloat cc_default))
    [Ebinop Omul (Etempvar BCP._t'36 tfloat)
      (Econst_single (Float32.of_bits (Int.repr 1092616192)) tfloat) tfloat] /\
  ibcp_store_rhs (ibcp_early_height_store version) =
    Ebinop Oadd (Etempvar BCP._t'33 tfloat) (Etempvar BCP._t'1 tfloat) tfloat /\
  fn_body (ibcp_abs_body version) = Ssequence
    (Sifthenelse (Ebinop Olt (Etempvar BCP._f tfloat) (Econst_int Int.zero tint) tint)
      (Sset BCP._f (Ebinop Omul (Etempvar BCP._f tfloat)
        (Eunop Oneg (Econst_single (Float32.of_bits (Int.repr 1065353216)) tfloat)
          tfloat) tfloat)) Sskip)
    (Sreturn (Some (Etempvar BCP._f tfloat))).
Theorem ibcp_early_source_cuts_checked : InkBelowCapEarlySourceCuts.
Proof. intros []; repeat split; reflexivity. Qed.

Definition ibcp_sine_bits : list Z :=
  [0;1060439283;1065353216;1060439283;0;3207922931;3212836864;3207922931].
Definition ibcp_sine_table_samples words := map (fun n =>
  match nth_error words n with Some word => i130_initializer_float_bits word | None => None end)
  [0%nat;512%nat;1024%nat;1536%nat;2048%nat;2560%nat;3072%nat;3584%nat].
Definition InkBelowCapSineCycle : Prop :=
  ibcp_sine_table_samples (gvar_init us_math_util.v_gSineTable) =
    map (@Some Z) ibcp_sine_bits /\
  ibcp_sine_table_samples (gvar_init jp_math_util.v_gSineTable) =
    map (@Some Z) ibcp_sine_bits.
Theorem ibcp_generated_sine_cycle_checked : InkBelowCapSineCycle.
Proof. vm_compute; split; reflexivity. Qed.

Definition ibcp_source_sine_index timer := Int.shr
  (Int.zero_ext 16 (Int.mul (Int.repr (Z.of_nat timer)) (Int.repr 8192)))
  (Int.repr 4).
Definition InkBelowCapSineIndices : Prop :=
  map (fun timer => Int.unsigned (ibcp_source_sine_index timer)) (seq 0 60) =
  map (fun timer => Z.of_nat (Nat.modulo timer 8) * 512) (seq 0 60).
Theorem ibcp_generated_index_cycle_checked : InkBelowCapSineIndices.
Proof. vm_compute; reflexivity. Qed.

Definition ibcp_abs x := if Float32.cmp Clt x Float32.zero
  then Float32.mul x (Float32.neg (f32_of_Z 1)) else x.
Definition ibcp_early_center timer := Float32.add (f32_of_Z pyramid_top_home_y)
  (ibcp_abs (Float32.mul
    (Float32.of_bits (Int.repr (nth (Nat.modulo timer 8) ibcp_sine_bits 0)))
    (f32_of_Z 10))).
Fixpoint ibcp_spin_centers count state : list float32 := match count with
| O => []
| S n => let next := timer131_spin_step state in
  timer131_center_y next :: ibcp_spin_centers n next end.
Definition ibcp_centers := f32_of_Z pyramid_top_home_y ::
  map ibcp_early_center (seq 0 60) ++ ibcp_spin_centers 91 timer131_before_timer60.
Definition ibcp_loaded_base h := matrix_component_f32
  (f32_of_Z (-511)) (f32_of_Z (-255)) (f32_of_Z 512)
  (f32_of_Z 0) (f32_of_Z 1) (Float32.neg (f32_of_Z 0)) h.
Definition ibcp_cast_base h := match cast_transformed_component (ibcp_loaded_base h) Mem.empty with
| Some (Vint y) => Some (Int.signed y) | _ => None end.
Definition ibcp_bases := map ibcp_cast_base ibcp_centers.
Definition ibcp_base phase := match nth_error ibcp_bases phase with
| Some (Some y) => y | _ => 0 end.
Definition ibcp_pair_ok phase :=
  (0 <=? ibcp_base phase) && (ibcp_base phase <=? 32768) &&
  (0 <=? ibcp_base (phase + 2)%nat) && (ibcp_base (phase + 2)%nat <=? 32768) &&
  (ibcp_base phase - ibcp_base (phase + 2)%nat <=? 10).

(** There are150 successive two-update windows, not a monotonicity claim.
    Early bobbing can lower the base by ten units over such a window. *)
Definition InkBelowCapStockPhaseCertificate : Prop :=
  length ibcp_bases = 152%nat /\
  forallb (fun row => match row with Some _ => true | None => false end) ibcp_bases = true /\
  Float32.to_bits (ibcp_early_center 59) =
    Float32.to_bits (timer131_center_y timer131_before_timer60) /\
  map ibcp_base [0%nat;1%nat;2%nat;3%nat;60%nat;84%nat;85%nat;130%nat;131%nat;132%nat;150%nat;151%nat] =
    [1281;1281;1288;1291;1288;1288;1293;1518;1523;1528;1618;1623] /\
  forallb ibcp_pair_ok (seq 0 150) = true.

Theorem ibcp_stock_phase_certificate_checked : InkBelowCapStockPhaseCertificate.
Proof. vm_compute; repeat split; reflexivity. Qed.

Lemma ibcp_every_stock_window_has_bounded_drop : forall phase, (phase < 150)%nat ->
  0 <= ibcp_base phase <= 32768 /\
  0 <= ibcp_base (phase + 2)%nat <= 32768 /\
  ibcp_base phase - ibcp_base (phase + 2)%nat <= 10.
Proof.
  intros phase Hp.
  destruct ibcp_stock_phase_certificate_checked as (_ & _ & _ & _ & Hcheck).
  rewrite forallb_forall in Hcheck.
  specialize (Hcheck phase ltac:(apply in_seq; lia)).
  unfold ibcp_pair_ok in Hcheck.
  repeat rewrite andb_true_iff in Hcheck.
  repeat rewrite Z.leb_le in Hcheck. tauto.
Qed.

(** A reached floor-list gate at ANY of the150 stock two-update windows.
    The height premise describes the actual query's computed binary32 plane,
    not merely its vertices. The converted query remains at least100 below
    the old base; a separately raised display or a wrapping cast is outside
    that premise. No X/Z restriction or sampled-controller restriction occurs. *)
Definition InkBelowCapStockPhaseGate : Prop :=
  forall version ge e le m phase query height,
  (phase < 150)%nat ->
  -32768 <= Int.signed query <= 32767 ->
  Int.signed query + 100 <= ibcp_base phase ->
  rank9cf_finite height ->
  (IZR (ibcp_base (phase + 2)%nat - 10) <= rank9cf_real height <= 32768)%R ->
  le ! IVL._y = Some (Vint query) ->
  le ! IVL._height = Some (Vsingle height) ->
  ocn_exec ge e le m (ivl_stmt version 19) E0 le m Out_continue.

Theorem ibcp_every_bounded_stock_phase_rejects_this_surface : InkBelowCapStockPhaseGate.
Proof.
  intros version ge e le m phase query height Hp Hquery Hbody Fh Hheight Hy Hh.
  destruct (ibcp_every_stock_window_has_bounded_drop phase Hp) as (Bo & Br & Hdrop).
  exact (ibcpg_below_cap_query_rejects_this_surface version ge e le m query height
    (ibcp_base phase) (ibcp_base (phase + 2)%nat)
    Hquery Bo Br Hdrop Hbody Fh Hheight Hy Hh).
Qed.

Definition InkBelowCapPhaseBoundary : Prop :=
  InkBelowCapPhaseGuardBoundary /\ InkBelowCapStockPhaseCertificate /\
  InkBelowCapStockPhaseGate /\
  timer131_surface_source_shape_claim /\ InkBelowCapEarlySourceCuts /\
  InkBelowCapSineCycle /\ InkBelowCapSineIndices.

Theorem ibcp_below_cap_phase_boundary_checked : InkBelowCapPhaseBoundary.
Proof.
  split; [exact ibcpg_below_cap_phase_guard_checked|].
  split; [exact ibcp_stock_phase_certificate_checked|].
  split; [exact ibcp_every_bounded_stock_phase_rejects_this_surface|].
  split; [exact timer131_surface_source_shape_checked|].
  split; [exact ibcp_early_source_cuts_checked|].
  split; [exact ibcp_generated_sine_cycle_checked|].
  exact ibcp_generated_index_cycle_checked.
Qed.
