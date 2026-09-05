(** Rank 12B: contact across terrain, without a presumed gate crossing.
    No controller reachability is assumed for geometric samples. The static
    floor census and the two gate-footprint exclusions are different facts.
    The selected overlap tail below is real Clight execution; its sqrtf input
    prefix and the whole frame still need live reads and an exact call effect. *)
From Coq Require Import Bool Lia List ZArith Reals Lra.
From Flocq Require Import BinarySingleNaN Binary Core.
From compcert Require Import AST Clight ClightBigstep Clightdefs Cop Coqlib
  Ctypes Events Floats Globalenvs IEEE754_extra Integers Maps Memory Values.
From LessThanOneAPress.Generated Require Import
  us_object_collision jp_object_collision us_behavior_data jp_behavior_data
  us_obj_behaviors jp_obj_behaviors.
From LessThanOneAPress.Proofs Require Import
  ASTFacts GameTypes CollisionRegions CollisionMeshFacts PyramidTopPU
  Area1FirstNull Area2DownstreamGeometry Area2Rank9ACoinFlight
  UpperElevatorQueryResolution
  CleanedClightPrograms ClightLinkExecution GlobalInterfaceStructural
  JPSourceSymbolTransport JPWarpLevelEntryResolution LinkedClightPrograms
  NormalizedClightPrograms SelectedClightTarget SuccessfulMakeProgramResolution
  USViewportRepairedNamesNorepet USViewportRepairedProgramSelection
  USWarpLevelRepairReceipt USWarpLevelSourceUnionReceipt USWholeASTTagRepair.
Import ListNotations.
Import Clightdefs.ClightNotations.
Local Open Scope Z_scope.
Local Transparent Float32.cmp Float32.compare.
Module RC := us_object_collision.
Module RJ := jp_object_collision.
Module DG := Area2DownstreamGeometry.

(** * Binary32 distance bounds, including every fractional X/Z in the boxes. *)
Definition rank12b_stable z := rank9cf_round (IZR z) = IZR z.

Lemma rank12b_large_endpoints_stable :
  rank12b_stable 268435456 /\ rank12b_stable 536870912.
Proof.
  split; unfold rank12b_stable.
  - replace (IZR 268435456) with
      (rank9cf_real (Float32.of_bits (Int.repr 1300234240))) by (vm_compute; ring).
    unfold rank9cf_round, rank9cf_real. apply round_generic;
      [apply valid_rnd_round_mode | apply generic_format_B2R].
  - replace (IZR 536870912) with
      (rank9cf_real (Float32.of_bits (Int.repr 1308622848))) by (vm_compute; ring).
    unfold rank9cf_round, rank9cf_real. apply round_generic;
      [apply valid_rnd_round_mode | apply generic_format_B2R].
Qed.

Lemma rank12b_round_range : forall lo hi x,
  rank12b_stable lo -> rank12b_stable hi ->
  (IZR lo <= x <= IZR hi)%R ->
  (IZR lo <= rank9cf_round x <= IZR hi)%R.
Proof.
  intros lo hi x Hl Hh Hx. split.
  - rewrite <- Hl. unfold rank9cf_round. apply round_le;
      [apply FLT_exp_valid; reflexivity | apply valid_rnd_round_mode | lra].
  - rewrite <- Hh. unfold rank9cf_round. apply round_le;
      [apply FLT_exp_valid; reflexivity | apply valid_rnd_round_mode | lra].
Qed.

Lemma rank12b_no_overflow : forall lo hi x,
  -536870912 <= lo -> hi <= 536870912 ->
  rank12b_stable lo -> rank12b_stable hi ->
  (IZR lo <= x <= IZR hi)%R ->
  (Rabs (rank9cf_round x) < bpow radix2 128)%R.
Proof.
  intros lo hi x Hl Hh Sl Sh Hx.
  pose proof (rank12b_round_range lo hi x Sl Sh Hx) as H.
  apply IZR_le in Hl. apply IZR_le in Hh.
  replace (bpow radix2 128) with
    (340282366920938463463374607431768211456)%R by reflexivity.
  apply Rabs_lt; lra.
Qed.

Lemma rank12b_mul_range : forall x y lo hi,
  rank9cf_finite x -> rank9cf_finite y ->
  -536870912 <= lo -> hi <= 536870912 ->
  rank12b_stable lo -> rank12b_stable hi ->
  (IZR lo <= rank9cf_real x * rank9cf_real y <= IZR hi)%R ->
  rank9cf_finite (Float32.mul x y) /\
  (IZR lo <= rank9cf_real (Float32.mul x y) <= IZR hi)%R.
Proof.
  intros x y lo hi Fx Fy Hl Hh Sl Sh Hxy.
  pose proof (Bmult_correct 24 128 eq_refl eq_refl Float32.binop_nan
    mode_NE x y) as H. fold rank9cf_round in H.
  rewrite Rlt_bool_true in H by (eapply rank12b_no_overflow; eauto).
  destruct H as [Hr [Hf _]]. unfold rank9cf_finite in Fx, Fy.
  rewrite Fx, Fy in Hf. split; [exact Hf |].
  change (rank9cf_real (Float32.mul x y) =
    rank9cf_round (rank9cf_real x * rank9cf_real y)) in Hr.
  rewrite Hr. eapply rank12b_round_range; eauto.
Qed.

Lemma rank12b_add_range : forall x y lo hi,
  rank9cf_finite x -> rank9cf_finite y ->
  -536870912 <= lo -> hi <= 536870912 ->
  rank12b_stable lo -> rank12b_stable hi ->
  (IZR lo <= rank9cf_real x + rank9cf_real y <= IZR hi)%R ->
  rank9cf_finite (Float32.add x y) /\
  (IZR lo <= rank9cf_real (Float32.add x y) <= IZR hi)%R.
Proof.
  intros x y lo hi Fx Fy Hl Hh Sl Sh Hxy.
  pose proof (Bplus_correct 24 128 eq_refl eq_refl Float32.binop_nan
    mode_NE x y Fx Fy) as H. fold rank9cf_round in H.
  rewrite Rlt_bool_true in H by (eapply rank12b_no_overflow; eauto).
  destruct H as [Hr [Hf _]]. split; [exact Hf |].
  change (rank9cf_real (Float32.add x y) =
    rank9cf_round (rank9cf_real x + rank9cf_real y)) in Hr.
  rewrite Hr. eapply rank12b_round_range; eauto.
Qed.

Lemma rank12b_sub_range : forall x y lo hi,
  rank9cf_finite x -> rank9cf_finite y ->
  -65536 <= lo -> hi <= 65536 -> lo <= hi ->
  (IZR lo <= rank9cf_real x - rank9cf_real y <= IZR hi)%R ->
  rank9cf_finite (Float32.sub x y) /\
  (IZR lo <= rank9cf_real (Float32.sub x y) <= IZR hi)%R.
Proof.
  intros x y lo hi Fx Fy Hl Hh Ho Hxy.
  pose proof (Bminus_correct 24 128 eq_refl eq_refl Float32.binop_nan
    mode_NE x y Fx Fy) as H. fold rank9cf_round in H.
  rewrite Rlt_bool_true in H by (eapply rank9cf_round_no_overflow; eauto).
  destruct H as [Hr [Hf _]]. split; [exact Hf |].
  change (rank9cf_real (Float32.sub x y) =
    rank9cf_round (rank9cf_real x - rank9cf_real y)) in Hr.
  rewrite Hr. eapply rank9cf_round_range; eauto.
Qed.

Lemma rank12b_nonzero_real_is_finite : forall f,
  rank9cf_real f <> 0%R -> rank9cf_finite f.
Proof. intros [] H; try reflexivity; exfalso; apply H; reflexivity. Qed.

Lemma rank12b_sqrt_far : forall squared,
  (65536 <= rank9cf_real squared <= 536870912)%R ->
  rank9cf_finite (Float32.sqrt squared) /\
  (256 <= rank9cf_real (Float32.sqrt squared) <= 32768)%R.
Proof.
  intros squared Hs.
  pose proof (Bsqrt_correct 24 128 eq_refl eq_refl Float32.unop_nan
    mode_NE squared) as [Hr _].
  change (rank9cf_real (Float32.sqrt squared) =
    rank9cf_round (sqrt (rank9cf_real squared))) in Hr.
  assert (Hsqrt : (256 <= sqrt (rank9cf_real squared) <= 32768)%R).
  { pose proof (sqrt_pos (rank9cf_real squared)).
    pose proof (sqrt_def (rank9cf_real squared) ltac:(lra)). nra. }
  pose proof (rank9cf_round_range 256 32768 _ ltac:(lia) ltac:(lia)
    ltac:(lia) Hsqrt) as Hrange.
  rewrite <- Hr in Hrange. split; [apply rank12b_nonzero_real_is_finite; lra | exact Hrange].
Qed.

Definition rank12b_far_axis f :=
  (rank9cf_real f <= -256 \/ 256 <= rank9cf_real f)%R.

Theorem rank12b_far_axis_bounds_actual_distance : forall dx dz,
  rank9cf_finite dx -> rank9cf_finite dz ->
  (-16384 <= rank9cf_real dx <= 16384)%R ->
  (-16384 <= rank9cf_real dz <= 16384)%R ->
  (rank12b_far_axis dx \/ rank12b_far_axis dz) ->
  let distance := Float32.sqrt
    (Float32.add (Float32.mul dx dx) (Float32.mul dz dz)) in
  rank9cf_finite distance /\ (256 <= rank9cf_real distance <= 32768)%R.
Proof.
  intros dx dz Fx Fz Hx Hz Hfar distance.
  destruct rank12b_large_endpoints_stable as [Ssquare Ssum].
  assert (S0 : rank12b_stable 0) by (apply rank9cf_round_integer; lia).
  assert (Smin : rank12b_stable 65536) by (apply rank9cf_round_integer; lia).
  destruct (rank12b_mul_range dx dx 0 268435456 Fx Fx ltac:(lia) ltac:(lia)
    S0 Ssquare ltac:(nra)) as [Fxx Hxx].
  destruct (rank12b_mul_range dz dz 0 268435456 Fz Fz ltac:(lia) ltac:(lia)
    S0 Ssquare ltac:(nra)) as [Fzz Hzz].
  assert (Hmin : (65536 <= rank9cf_real (Float32.mul dx dx) +
    rank9cf_real (Float32.mul dz dz))%R).
  { unfold rank12b_far_axis in Hfar. destruct Hfar as [Hfar | Hfar].
    - destruct (rank12b_mul_range dx dx 65536 268435456 Fx Fx ltac:(lia)
        ltac:(lia) Smin Ssquare ltac:(destruct Hfar; nra)) as [_ H]. lra.
    - destruct (rank12b_mul_range dz dz 65536 268435456 Fz Fz ltac:(lia)
        ltac:(lia) Smin Ssquare ltac:(destruct Hfar; nra)) as [_ H]. lra. }
  destruct (rank12b_add_range _ _ 65536 536870912 Fxx Fzz ltac:(lia)
    ltac:(lia) Smin Ssum ltac:(lra)) as [_ Hsum].
  apply rank12b_sqrt_far. exact Hsum.
Qed.

(** * Exact target roster and generous full gate footprints. *)
Inductive Rank12BTarget := ContactAct3 | ContactAct6 | ContactSecret (trigger : HiddenTrigger).
Definition rank12b_targets := [ContactAct3; ContactAct6] ++ map ContactSecret all_hidden_triggers.
Definition rank12b_target_xyz target : Z * Z * Z := match target with
| ContactAct3 => (500,5050,-500) | ContactAct6 => (900,1400,2350)
| ContactSecret trigger => match DG.hidden_trigger_source_record trigger with
    | _ :: x :: y :: z :: _ => (x,y,z) | _ => (0,0,0) end end.
Definition rank12b_target_position target := match target with
| ContactAct3 => act3_static_position | ContactAct6 => hidden_controller_position
| ContactSecret trigger => hidden_trigger_position trigger end.
Definition rank12b_target_hitbox target := match target with
| ContactSecret _ => hidden_trigger_hitbox | _ => collect_star_hitbox end.
Definition rank12b_radius target : Z := match target with
| ContactSecret _ => 137 | _ => 117 end.
Definition rank12b_height target : Z := match target with
| ContactSecret _ => 100 | _ => 50 end.

Lemma rank12b_target_coordinates_exact : forall target,
  let position := rank12b_target_position target in
  rank9cf_real (vec_x position) = IZR (DG.x_of (rank12b_target_xyz target)) /\
  rank9cf_real (vec_z position) = IZR (DG.z_of (rank12b_target_xyz target)) /\
  rank9cf_finite (vec_x position) /\ rank9cf_finite (vec_z position).
Proof.
  intro target.
  assert (Hx : vec_x (rank12b_target_position target) =
    rank9cf_integer (DG.x_of (rank12b_target_xyz target))).
  { apply rank9cf_bits_injective. destruct target as [| |[]]; vm_compute; reflexivity. }
  assert (Hz : vec_z (rank12b_target_position target) =
    rank9cf_integer (DG.z_of (rank12b_target_xyz target))).
  { apply rank9cf_bits_injective. destruct target as [| |[]]; vm_compute; reflexivity. }
  cbn zeta. rewrite Hx, Hz.
  destruct (rank9cf_integer_exact (DG.x_of (rank12b_target_xyz target))) as [Rx Fx];
    [destruct target as [| |[]]; cbn; lia |].
  destruct (rank9cf_integer_exact (DG.z_of (rank12b_target_xyz target))) as [Rz Fz];
    [destruct target as [| |[]]; cbn; lia |].
  auto.
Qed.

Inductive Rank12BGate := ElevatorFootprint | SecondPoleAperture.
Definition rank12b_gate_bounds gate : Z * Z * Z * Z := match gate with
| ElevatorFootprint => (-460,461,-204,717)
| SecondPoleAperture => (-101,102,1229,1434) end.
Definition rank12b_in_gate_xz gate position :=
  let '(xlo,xhi,zlo,zhi) := rank12b_gate_bounds gate in
  rank9cf_finite (vec_x position) /\ rank9cf_finite (vec_z position) /\
  (IZR xlo <= rank9cf_real (vec_x position) <= IZR xhi)%R /\
  (IZR zlo <= rank9cf_real (vec_z position) <= IZR zhi)%R.

Lemma rank12b_raw_gate_separation : forall gate target position,
  rank12b_in_gate_xz gate position ->
  let dx := (rank9cf_real (vec_x position) -
    rank9cf_real (vec_x (rank12b_target_position target)))%R in
  let dz := (rank9cf_real (vec_z position) -
    rank9cf_real (vec_z (rank12b_target_position target)))%R in
  (-16384 <= dx <= 16384)%R /\ (-16384 <= dz <= 16384)%R /\
  ((dx <= -256 \/ 256 <= dx) \/ (dz <= -256 \/ 256 <= dz))%R.
Proof.
  intros gate target position H.
  destruct (rank12b_target_coordinates_exact target) as [Hx [Hz _]].
  rewrite Hx, Hz. destruct gate, target as [| |[]];
    cbn [rank12b_in_gate_xz rank12b_gate_bounds] in H;
    cbn [rank12b_target_xyz DG.hidden_trigger_source_record DG.x_of DG.z_of];
    destruct H as [_ [_ [Hpx Hpz]]]; repeat split; try lra;
    first [left; left; lra | left; right; lra | right; left; lra | right; right; lra].
Qed.

Lemma rank12b_sub_preserves_separation : forall x y,
  rank9cf_finite x -> rank9cf_finite y ->
  (-16384 <= rank9cf_real x - rank9cf_real y <= 16384)%R ->
  ((rank9cf_real x - rank9cf_real y <= -256) \/
    (256 <= rank9cf_real x - rank9cf_real y))%R ->
  rank12b_far_axis (Float32.sub x y).
Proof.
  intros x y Fx Fy Hrange [H | H]; unfold rank12b_far_axis.
  - destruct (rank12b_sub_range x y (-16384) (-256) Fx Fy
      ltac:(lia) ltac:(lia) ltac:(lia) ltac:(lra)) as [_ Hr]. left; lra.
  - destruct (rank12b_sub_range x y 256 16384 Fx Fy
      ltac:(lia) ltac:(lia) ltac:(lia) ltac:(lra)) as [_ Hr]. right; lra.
Qed.

Theorem rank12b_every_gate_position_is_horizontally_far : forall gate target position,
  rank12b_in_gate_xz gate position ->
  let distance := horizontal_distance position (rank12b_target_position target) in
  rank9cf_finite distance /\ (256 <= rank9cf_real distance <= 32768)%R.
Proof.
  intros gate target position Hgate distance.
  pose proof (rank12b_raw_gate_separation gate target position Hgate) as [Hx [Hz Hfar]].
  destruct (rank12b_target_coordinates_exact target) as [_ [_ [Ftx Ftz]]].
  assert (Fm : rank9cf_finite (vec_x position) /\ rank9cf_finite (vec_z position)).
  { destruct gate; cbn [rank12b_in_gate_xz rank12b_gate_bounds] in Hgate; tauto. }
  destruct Fm as [Fmx Fmz].
  destruct (rank12b_sub_range _ _ (-16384) 16384 Fmx Ftx
    ltac:(lia) ltac:(lia) ltac:(lia) Hx) as [Fx Hdx].
  destruct (rank12b_sub_range _ _ (-16384) 16384 Fmz Ftz
    ltac:(lia) ltac:(lia) ltac:(lia) Hz) as [Fz Hdz].
  apply rank12b_far_axis_bounds_actual_distance; try assumption.
  destruct Hfar as [Hfar | Hfar]; [left | right];
    eapply rank12b_sub_preserves_separation; eauto.
Qed.

Lemma rank12b_cmp_lt_false : forall x y,
  rank9cf_finite x -> rank9cf_finite y ->
  (rank9cf_real y < rank9cf_real x)%R -> Float32.cmp Clt x y = false.
Proof.
  intros x y Fx Fy H. unfold Float32.cmp, Float32.compare.
  rewrite Bcompare_correct by assumption. rewrite Rcompare_Gt by exact H. reflexivity.
Qed.

Theorem rank12b_no_contact_from_either_gate_footprint : forall gate target position,
  rank12b_in_gate_xz gate position ->
  hitboxes_overlap position mario_standard_hitbox_f32
    (rank12b_target_position target) (rank12b_target_hitbox target) = false.
Proof.
  intros gate target position Hgate.
  destruct (rank12b_every_gate_position_is_horizontally_far gate target position Hgate)
    as [Fd Hd].
  assert (Hr : (rank9cf_real (Float32.add (hitbox_radius mario_standard_hitbox_f32)
    (hitbox_radius (rank12b_target_hitbox target))) < 256)%R).
  { destruct target; vm_compute; lra. }
  assert (Fr : rank9cf_finite (Float32.add (hitbox_radius mario_standard_hitbox_f32)
    (hitbox_radius (rank12b_target_hitbox target)))).
  { destruct target; reflexivity. }
  unfold hitboxes_overlap. rewrite rank12b_cmp_lt_false by (try assumption; lra).
  reflexivity.
Qed.

(** * All 1,558 static faces, not a selection of convenient floor samples.
    The box is padded by ONE unit on every face. This only makes the census
    more conservative. A live query must still justify its source triangle
    and relate its rounded height/raw Object pose to this geometric box. *)
Definition rank12b_words version := match version with
| VersionUS => DG.area2_collision_words_us | VersionJP => DG.area2_collision_words_jp end.
Definition rank12b_vertices version := collision_vertices_from_words 1080 (rank12b_words version).
Definition rank12b_triangles version := area1_parse_surface_groups 32 (skipn 3242 (rank12b_words version)).
Definition rank12b_faces version :=
  combine (seq 0 (length (rank12b_triangles version)))
    (map (area1_source_triangle_vertices (rank12b_vertices version)) (rank12b_triangles version)).
Definition rank12b_box target : (Z * Z * Z) * (Z * Z * Z) :=
  let '(x,y,z) := rank12b_target_xyz target in
  let r := rank12b_radius target + 1 in
  ((x-r,y-161,z-r), (x+r,y+rank12b_height target+1,z+r)).
Definition rank12b_min3 a b c := Z.min a (Z.min b c).
Definition rank12b_max3 a b c := Z.max a (Z.max b c).
Definition rank12b_axis_meets a b c lo hi :=
  (rank12b_min3 a b c <=? hi) && (lo <=? rank12b_max3 a b c).
Definition rank12b_face_meets target vertices :=
  let '(a,b,c) := vertices in
  let '(lo,hi) := rank12b_box target in
  (0 <? DG.y_of (area1_source_normal_components vertices)) &&
  rank12b_axis_meets (DG.x_of a) (DG.x_of b) (DG.x_of c) (DG.x_of lo) (DG.x_of hi) &&
  rank12b_axis_meets (DG.y_of a) (DG.y_of b) (DG.y_of c) (DG.y_of lo) (DG.y_of hi) &&
  rank12b_axis_meets (DG.z_of a) (DG.z_of b) (DG.z_of c) (DG.z_of lo) (DG.z_of hi).
Definition rank12b_candidates version target :=
  map fst (filter (fun face => match snd face with
    | Some vertices => rank12b_face_meets target vertices | None => false end)
    (rank12b_faces version)).
Definition rank12b_expected target : list nat := match target with
| ContactAct3 => [1092;1093;1094;1095;1096;1097]
| ContactAct6 => []
| ContactSecret TriggerLowerWest => [647;659]
| ContactSecret TriggerLowerEast => [636;640]
| ContactSecret TriggerMiddleWest => [1377;1378;1379]
| ContactSecret TriggerMiddleNorth => [1375;1377;1378]
| ContactSecret TriggerUpper => [668;669] end%nat.

Theorem rank12b_entire_mesh_census : forall version,
  length (rank12b_vertices version) = 1080%nat /\
  length (rank12b_triangles version) = 1558%nat /\
  forallb (fun face => match snd face with Some _ => true | None => false end)
    (rank12b_faces version) = true /\
  forall target, rank12b_candidates version target = rank12b_expected target.
Proof.
  intros version. assert (Hw : rank12b_words version = DG.area2_collision_words_us).
  { destruct version; [reflexivity | symmetry; exact DG.area2_collision_words_are_version_identical]. }
  unfold rank12b_candidates, rank12b_faces, rank12b_triangles, rank12b_vertices.
  rewrite Hw. split; [vm_compute; reflexivity |]. split; [vm_compute; reflexivity |].
  split.
  - vm_compute; reflexivity.
  - intros [| |[]]; vm_compute; reflexivity.
Qed.

Definition rank12b_point_in_vertex_box (p : R * R * R) vertices : Prop :=
  let '(x,y,z) := p in let '(a,b,c) := vertices in
  (IZR (rank12b_min3 (DG.x_of a) (DG.x_of b) (DG.x_of c)) <= x <=
   IZR (rank12b_max3 (DG.x_of a) (DG.x_of b) (DG.x_of c)))%R /\
  (IZR (rank12b_min3 (DG.y_of a) (DG.y_of b) (DG.y_of c)) <= y <=
   IZR (rank12b_max3 (DG.y_of a) (DG.y_of b) (DG.y_of c)))%R /\
  (IZR (rank12b_min3 (DG.z_of a) (DG.z_of b) (DG.z_of c)) <= z <=
   IZR (rank12b_max3 (DG.z_of a) (DG.z_of b) (DG.z_of c)))%R.
Definition rank12b_point_in_contact_box target (p : R * R * R) : Prop :=
  let '(x,y,z) := p in let '(lo,hi) := rank12b_box target in
  (IZR (DG.x_of lo) <= x <= IZR (DG.x_of hi))%R /\
  (IZR (DG.y_of lo) <= y <= IZR (DG.y_of hi))%R /\
  (IZR (DG.z_of lo) <= z <= IZR (DG.z_of hi))%R.

Lemma rank12b_axis_meets_sound : forall a b c lo hi p,
  (IZR (rank12b_min3 a b c) <= p <= IZR (rank12b_max3 a b c))%R ->
  (IZR lo <= p <= IZR hi)%R -> rank12b_axis_meets a b c lo hi = true.
Proof.
  intros a b c lo hi p Ht Hb. apply andb_true_iff. split; apply Z.leb_le;
    apply le_IZR; lra.
Qed.

Theorem rank12b_no_omitted_geometric_floor : forall version target ordinal vertices point,
  In (ordinal, Some vertices) (rank12b_faces version) ->
  0 < DG.y_of (area1_source_normal_components vertices) ->
  rank12b_point_in_vertex_box point vertices ->
  rank12b_point_in_contact_box target point ->
  In ordinal (rank12b_expected target).
Proof.
  intros version target ordinal vertices point Hin Hup Hv Hb.
  rewrite <- (proj2 (proj2 (proj2 (rank12b_entire_mesh_census version))) target).
  unfold rank12b_candidates. apply in_map_iff. exists (ordinal, Some vertices).
  split; [reflexivity |]. apply filter_In. split; [exact Hin |]. cbn [snd].
  unfold rank12b_face_meets.
  destruct vertices as [[a b] c], point as [[x y] z].
  unfold rank12b_point_in_vertex_box in Hv.
  unfold rank12b_point_in_contact_box in Hb.
  destruct (rank12b_box target) as [lo hi].
  destruct Hv as [Hx [Hy Hz]], Hb as [Bx [By Bz]].
  repeat rewrite andb_true_iff. repeat split; try (apply Z.ltb_lt; exact Hup);
    eapply rank12b_axis_meets_sound; eauto.
Qed.

(** This sample is on a real sloped rim, not on the Y=4815 flat platform.
    It is only a contact/support geometry witness: no live wall response,
    floor selection, action, tangibility, or controller prefix is supplied. *)
Definition rank12b_act3_rim_vertices : Area1SourceVertex * Area1SourceVertex * Area1SourceVertex :=
  ((387,4927,-716),(387,4927,-409),(427,4887,-450)).
Definition rank12b_act3_rim_sample : Vec3f :=
  {| vec_x := rank9cf_integer 400; vec_y := rank9cf_integer 4914; vec_z := rank9cf_integer (-500) |}.
Theorem rank12b_act3_rim_is_a_source_contact_candidate : forall version,
  In (1093%nat, Some rank12b_act3_rim_vertices) (rank12b_faces version) /\
  DG.point_in_closed_triangle_xz (400,4914,-500)
    (387,4927,-716) (387,4927,-409) (427,4887,-450) /\
  4914 + 400 = 4927 + 387 /\
  hitboxes_overlap rank12b_act3_rim_sample mario_standard_hitbox_f32
    act3_static_position collect_star_hitbox = true.
Proof.
  intro version. split.
  - apply nth_error_In with (n := 1093%nat). destruct version; vm_compute; reflexivity.
  - split; [right; vm_compute; repeat split; discriminate |].
    split; [reflexivity | vm_compute; reflexivity].
Qed.

(** * Resolve the actual contact helper in both selected linked programs. *)
Definition rank12b_body version := match version with
| VersionUS => RC.f_detect_object_hitbox_overlap
| VersionJP => RJ.f_detect_object_hitbox_overlap end.

Lemma rank12b_us_source_member :
  In (RC._detect_object_hitbox_overlap, Gfun (Internal (rank12b_body VersionUS)))
    (unit_global_definitions us_units).
Proof.
  eapply source_unit_definition_enters_source_union with (unit := us_nlist_at 12 us_units).
  - exact (us_nlist_at_nIn _ 12 us_units).
  - change (In (RC._detect_object_hitbox_overlap, Gfun (Internal (rank12b_body VersionUS)))
      RC.global_definitions).
    apply nth_error_In with (n := ueqr_definition_index RC._detect_object_hitbox_overlap RC.global_definitions).
    vm_compute; reflexivity.
Qed.

Lemma rank12b_us_selection :
  us_normalized_global_definition_map ! RC._detect_object_hitbox_overlap =
    Some (Gfun (Internal (rank12b_body VersionUS))).
Proof.
  eapply (checked_internal_selection_is_exact
    (unit_global_definitions us_units) us_normalized_global_definition_map).
  - exact us_internal_identifiers_are_unique_checked.
  - exact us_all_internal_identifiers_selected_checked.
  - exact (normalized_definition_map_has_source_provenance (unit_global_definitions us_units)).
  - exact rank12b_us_source_member.
Qed.

(** Keep conversion from evaluating the entire normalized game map at this
    concrete identifier; use the proved selection certificate explicitly. *)
Local Opaque normalize_global_definition_map normalize_global_definitions.
Lemma rank12b_us_selected_member :
  In (RC._detect_object_hitbox_overlap, Gfun (Internal (rank12b_body VersionUS)))
    us_viewport_repaired_global_definitions.
Proof.
  unfold us_viewport_repaired_global_definitions. apply fixed_point_enters_mapped_list.
  - reflexivity.
  - exact (every_selected_internal_body_is_preserved_verbatim
      (unit_global_definitions us_units) RC._detect_object_hitbox_overlap
      (rank12b_body VersionUS) rank12b_us_selection).
Qed.

Theorem rank12b_selected_contact_body_resolves : forall version,
  exists function_block,
    Genv.find_symbol (Clight.globalenv (selected_clight_target version))
      RC._detect_object_hitbox_overlap = Some function_block /\
    Genv.find_funct_ptr (Clight.globalenv (selected_clight_target version))
      function_block = Some (Internal (rank12b_body version)).
Proof.
  intros [].
  - eapply program_definitions_resolve_internal_globalenv.
    + exact us_viewport_repaired_program_definitions_checked.
    + exact us_viewport_repaired_definition_names_norepet.
    + exact rank12b_us_selected_member.
  - eapply (official_link_resolves_internal_globalenv jp_cleaned_units
      jp_official_cleaned_slice jp_cleaned_units_official_link (nlist_at 12 jp_cleaned_units)).
    + exact (nlist_at_nIn _ 12 jp_cleaned_units).
    + vm_compute; reflexivity.
Qed.

Fixpoint rank12b_drop_sequences count body := match count, body with
| S count', Ssequence _ rest => rank12b_drop_sequences count' rest
| _, _ => body end.
Definition rank12b_after_sqrt version := rank12b_drop_sequences 7 (fn_body (rank12b_body version)).
Definition rank12b_inside_radius version := match rank12b_after_sqrt version with
| Ssequence (Sifthenelse _ inside _) _ => inside | _ => Sskip end.
Definition rank12b_radius_test := Ebinop Ogt (Etempvar RC._collisionRadius tfloat)
  (Etempvar RC._distance tfloat) tint.
Definition rank12b_return_zero := Sreturn (Some (Econst_int Int.zero tint)).

Theorem rank12b_generated_radius_tail_is_exact : forall version,
  rank12b_after_sqrt version = Ssequence
    (Sifthenelse rank12b_radius_test (rank12b_inside_radius version) Sskip)
    rank12b_return_zero /\
  direct_callees_s (fn_body (rank12b_body version)) = [RC._sqrtf].
Proof. intros []; split; reflexivity. Qed.

(** This executes the selected tail itself, not a substitute contact formula.
    The generated configurations explicitly return zero on radial rejection.
    sqrtf has already returned: its exact result/effect is not invented here. *)
Theorem rank12b_radius_rejection_executes_without_writes :
  forall version environment locals memory radius distance,
    locals ! RC._collisionRadius = Some (Vsingle radius) ->
    locals ! RC._distance = Some (Vsingle distance) ->
    Float32.cmp Cgt radius distance = false ->
    ClightBigstep.Clight2.exec_stmt
      (Clight.globalenv (selected_clight_target version)) environment locals memory
      (rank12b_after_sqrt version) E0 locals memory (Out_return (Some (Vint Int.zero, tint))).
Proof.
  intros version environment locals memory radius distance Hr Hd Hno.
  rewrite (proj1 (rank12b_generated_radius_tail_is_exact version)).
  eapply exec_Sseq_1 with (t1 := E0) (t2 := E0).
  - eapply exec_Sifthenelse with (v1 := Vint Int.zero) (b := false).
    + eapply eval_Ebinop; [apply eval_Etempvar; exact Hr | apply eval_Etempvar; exact Hd |].
      change (Some (Val.of_bool (Float32.cmp Cgt radius distance)) = Some (Vint Int.zero)).
      rewrite Hno; reflexivity.
    + reflexivity.
    + constructor.
  - apply exec_Sreturn_some. constructor.
Qed.

Theorem rank12b_gate_rejection_executes_in_selected_clight :
  forall version gate target position environment locals memory,
    rank12b_in_gate_xz gate position ->
    locals ! RC._collisionRadius = Some (Vsingle
      (Float32.add (hitbox_radius mario_standard_hitbox_f32)
        (hitbox_radius (rank12b_target_hitbox target)))) ->
    locals ! RC._distance = Some (Vsingle
      (horizontal_distance position (rank12b_target_position target))) ->
    ClightBigstep.Clight2.exec_stmt
      (Clight.globalenv (selected_clight_target version)) environment locals memory
      (rank12b_after_sqrt version) E0 locals memory (Out_return (Some (Vint Int.zero, tint))).
Proof.
  intros version gate target position environment locals memory Hg Hr Hd.
  eapply rank12b_radius_rejection_executes_without_writes; [exact Hr | exact Hd |].
  destruct (rank12b_every_gate_position_is_horizontally_far gate target position Hg) as [Fd Hdistance].
  assert (Fr : rank9cf_finite (Float32.add (hitbox_radius mario_standard_hitbox_f32)
    (hitbox_radius (rank12b_target_hitbox target)))) by (destruct target; reflexivity).
  assert (Hradius : (rank9cf_real (Float32.add (hitbox_radius mario_standard_hitbox_f32)
    (hitbox_radius (rank12b_target_hitbox target))) < 256)%R) by (destruct target; vm_compute; lra).
  unfold Float32.cmp, Float32.compare. rewrite Bcompare_correct by assumption.
  rewrite Rcompare_Lt by (unfold rank9cf_real in Hradius, Hdistance; lra). reflexivity.
Qed.

(** Static descriptor receipts: these are initialized bytes, not a claim that
    an arbitrary live object's dimensions have already been derived. *)
Theorem rank12b_stock_hitbox_descriptors_are_exact :
  firstn 2 (skipn 4 (gvar_init us_behavior_data.v_bhvMario)) =
    [Init_int32 (Int.repr 587202560); Init_int32 (Int.repr (37 * 65536 + 160))] /\
  firstn 2 (skipn 4 (gvar_init jp_behavior_data.v_bhvMario)) =
    [Init_int32 (Int.repr 587202560); Init_int32 (Int.repr (37 * 65536 + 160))] /\
  firstn 2 (skipn 2 (gvar_init us_behavior_data.v_bhvHiddenStarTrigger)) =
    [Init_int32 (Int.repr 587202560); Init_int32 (Int.repr (100 * 65536 + 100))] /\
  firstn 2 (skipn 2 (gvar_init jp_behavior_data.v_bhvHiddenStarTrigger)) =
    [Init_int32 (Int.repr 587202560); Init_int32 (Int.repr (100 * 65536 + 100))] /\
  gvar_init us_obj_behaviors.v_sCollectStarHitbox =
    [Init_int32 (Int.repr 4096); Init_int8 Int.zero; Init_int8 Int.zero;
     Init_int8 Int.zero; Init_int8 Int.zero; Init_int16 (Int.repr 80);
     Init_int16 (Int.repr 50); Init_int16 Int.zero; Init_int16 Int.zero] /\
  gvar_init jp_obj_behaviors.v_sCollectStarHitbox = gvar_init us_obj_behaviors.v_sCollectStarHitbox.
Proof. repeat split; reflexivity. Qed.

Theorem rank12b_highest_secret_has_only_its_platform : forall version ordinal vertices point,
  In (ordinal, Some vertices) (rank12b_faces version) ->
  0 < DG.y_of (area1_source_normal_components vertices) ->
  rank12b_point_in_vertex_box point vertices ->
  rank12b_point_in_contact_box (ContactSecret TriggerUpper) point ->
  ordinal = 668%nat \/ ordinal = 669%nat.
Proof.
  intros version ordinal vertices point Hin Hup Hv Hb.
  pose proof (rank12b_no_omitted_geometric_floor version (ContactSecret TriggerUpper)
    ordinal vertices point Hin Hup Hv Hb) as H. cbn in H. intuition congruence.
Qed.

Theorem rank12b_settled_act6_has_no_static_standing_candidate : forall version ordinal vertices point,
  In (ordinal, Some vertices) (rank12b_faces version) ->
  0 < DG.y_of (area1_source_normal_components vertices) ->
  rank12b_point_in_vertex_box point vertices ->
  ~ rank12b_point_in_contact_box ContactAct6 point.
Proof.
  intros version ordinal vertices point Hin Hup Hv Hb.
  exact (rank12b_no_omitted_geometric_floor version ContactAct6 ordinal vertices point Hin Hup Hv Hb).
Qed.

(** A below-platform sample is deliberately retained as an OPEN installer
    target. The floor census cannot exclude an airborne contact by definition. *)
Theorem rank12b_upper_secret_airborne_boundary_samples :
  hitboxes_overlap
    {| vec_x := rank9cf_integer 260; vec_y := rank9cf_integer 3753; vec_z := rank9cf_integer (-600) |}
    mario_standard_hitbox_f32 (hidden_trigger_position TriggerUpper) hidden_trigger_hitbox = true /\
  hitboxes_overlap
    {| vec_x := rank9cf_integer 260; vec_y := rank9cf_integer 3752; vec_z := rank9cf_integer (-600) |}
    mario_standard_hitbox_f32 (hidden_trigger_position TriggerUpper) hidden_trigger_hitbox = false.
Proof. vm_compute; split; reflexivity. Qed.

Definition rank12b_upper_secret_underside : list (nat * option
  (Area1SourceVertex * Area1SourceVertex * Area1SourceVertex)) :=
  [(664%nat, Some ((387,3785,-716),(131,3785,-460),(131,3785,-716)));
   (665%nat, Some ((387,3785,-716),(387,3785,-460),(131,3785,-460)))].
Theorem rank12b_upper_secret_underside_source : forall version,
  firstn 2 (skipn 664 (rank12b_faces version)) = rank12b_upper_secret_underside /\
  3913 - 3785 = 128 /\ 3785 - 160 = 3625 /\ 3913 - 160 = 3753.
Proof. intros []; vm_compute; repeat split; reflexivity. Qed.

Theorem rank12b_ceiling_respecting_underpass_cannot_touch_secret : forall position,
  rank9cf_finite (hitbox_top position mario_standard_hitbox_f32) ->
  (rank9cf_real (hitbox_top position mario_standard_hitbox_f32) <= 3785)%R ->
  hitboxes_overlap position mario_standard_hitbox_f32
    (hidden_trigger_position TriggerUpper) hidden_trigger_hitbox = false.
Proof.
  intros position Fm Hm.
  assert (Ft : rank9cf_finite (hitbox_bottom
    (hidden_trigger_position TriggerUpper) hidden_trigger_hitbox)) by reflexivity.
  assert (Ht : rank9cf_real (hitbox_bottom
    (hidden_trigger_position TriggerUpper) hidden_trigger_hitbox) = 3913%R).
  { assert (Hbits : hitbox_bottom (hidden_trigger_position TriggerUpper)
      hidden_trigger_hitbox = rank9cf_integer 3913).
    { apply rank9cf_bits_injective; vm_compute; reflexivity. }
    rewrite Hbits. exact (proj1 (rank9cf_integer_exact 3913 ltac:(lia))). }
  assert (Hcmp : Float32.cmp Clt (hitbox_top position mario_standard_hitbox_f32)
    (hitbox_bottom (hidden_trigger_position TriggerUpper) hidden_trigger_hitbox) = true).
  { unfold Float32.cmp, Float32.compare. rewrite Bcompare_correct by assumption.
    rewrite Rcompare_Lt by (unfold rank9cf_real in Ht, Hm; lra). reflexivity. }
  unfold hitboxes_overlap. rewrite Hcmp. rewrite andb_false_r, andb_false_r. reflexivity.
Qed.

Definition Rank12BContactBoundary : Prop :=
  (forall version, exists function_block,
    Genv.find_symbol (Clight.globalenv (selected_clight_target version))
      RC._detect_object_hitbox_overlap = Some function_block /\
    Genv.find_funct_ptr (Clight.globalenv (selected_clight_target version))
      function_block = Some (Internal (rank12b_body version))) /\
  (forall gate target position, rank12b_in_gate_xz gate position ->
    hitboxes_overlap position mario_standard_hitbox_f32
      (rank12b_target_position target) (rank12b_target_hitbox target) = false) /\
  (forall version gate target position environment locals memory,
    rank12b_in_gate_xz gate position ->
    locals ! RC._collisionRadius = Some (Vsingle
      (Float32.add (hitbox_radius mario_standard_hitbox_f32)
        (hitbox_radius (rank12b_target_hitbox target)))) ->
    locals ! RC._distance = Some (Vsingle
      (horizontal_distance position (rank12b_target_position target))) ->
    ClightBigstep.Clight2.exec_stmt
      (Clight.globalenv (selected_clight_target version)) environment locals memory
      (rank12b_after_sqrt version) E0 locals memory (Out_return (Some (Vint Int.zero, tint)))) /\
  (forall version target ordinal vertices point,
    In (ordinal, Some vertices) (rank12b_faces version) ->
    0 < DG.y_of (area1_source_normal_components vertices) ->
    rank12b_point_in_vertex_box point vertices ->
    rank12b_point_in_contact_box target point -> In ordinal (rank12b_expected target)) /\
  (forall version, rank12b_candidates version ContactAct6 = [] /\
    rank12b_candidates version (ContactSecret TriggerUpper) = [668;669]%nat) /\
  (forall position,
    rank9cf_finite (hitbox_top position mario_standard_hitbox_f32) ->
    (rank9cf_real (hitbox_top position mario_standard_hitbox_f32) <= 3785)%R ->
    hitboxes_overlap position mario_standard_hitbox_f32
      (hidden_trigger_position TriggerUpper) hidden_trigger_hitbox = false) /\
  (forall version,
    In (1093%nat, Some rank12b_act3_rim_vertices) (rank12b_faces version) /\
    hitboxes_overlap rank12b_act3_rim_sample mario_standard_hitbox_f32
      act3_static_position collect_star_hitbox = true).

Theorem rank12b_contact_boundary_checked : Rank12BContactBoundary.
Proof.
  split; [exact rank12b_selected_contact_body_resolves |].
  split; [exact rank12b_no_contact_from_either_gate_footprint |].
  split; [exact rank12b_gate_rejection_executes_in_selected_clight |].
  split; [exact rank12b_no_omitted_geometric_floor |]. split.
  - intro version. pose proof (proj2 (proj2 (proj2 (rank12b_entire_mesh_census version)))) as H.
    split; apply H.
  - split; [exact rank12b_ceiling_respecting_underpass_cannot_touch_secret |].
    intro version. destruct (rank12b_act3_rim_is_a_source_contact_candidate version) as [Hin [_ [_ Hcontact]]]. auto.
Qed.
