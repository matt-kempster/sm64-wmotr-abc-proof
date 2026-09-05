(** A Rank 9A test target, not an execution witness.  Exact binary32 arithmetic
    and generated ring vertices prevent the easy but wrong dismissal that
    zero horizontal velocity alone makes a star ledge snap impossible.
    Wall selection, floor selection, coin placement and arrival remain open. *)
From Coq Require Import Bool Lia List ZArith.
From compcert Require Import AST Clight Floats Integers.
From LessThanOneAPress.Generated Require Import us_ssl_area2_macro jp_ssl_area2_macro.
From LessThanOneAPress.Proofs Require Import ASTFacts GameTypes CollisionMeshFacts
  Area2LowerTargetCut NoExitStarDialogBridge Area2Rank9AStarSource.

Import ListNotations.
Local Open Scope Z_scope.

(** A finite literal cache, not a general integer-to-float conversion.  Its
    round-trip receipt below checks every key used here.  Bit literals avoid
    repeatedly expanding CompCert's large [of_int] conversion proof terms. *)
Definition rank9a_literal_bits : list (Z * Z) :=
  [(0, 0); (1, 1065353216); (30, 1106247680); (60, 1114636288);
   (100, 1120403456); (150, 1125515264); (160, 1126170624);
   (3200, 1162346496); (3712, 1164443648); (3800, 1164804096);
   (3830, 1164926976); (3942, 1165385728); (3950, 1165418496);
   (3960, 1165459456); (1331, 1151754240); (-51, 3259760640);
   (-111, 3269328896)].
Definition rank9a_f32 z := Float32.of_bits (Int.repr
  (match find (fun entry => Z.eqb (fst entry) z) rank9a_literal_bits with
   | Some (_, bits) => bits | None => 0 end)).

Theorem rank9a_literal_cache_checked :
  forallb (fun entry => match Float32.to_int (rank9a_f32 (fst entry)) with
    | Some value => Int.eq value (Int.repr (fst entry)) | None => false end)
    rank9a_literal_bits = true.
Proof. vm_compute. reflexivity. Qed.
Definition rank9a_ledge_x :=
  Float32.sub (rank9a_f32 (-51))
    (Float32.mul (rank9a_f32 1) (rank9a_f32 60)).
Definition rank9a_candidate_ring_position : Vec3f :=
  {| vec_x := rank9a_ledge_x; vec_y := rank9a_f32 3942;
     vec_z := rank9a_f32 1331 |}.

Definition rank9a_ring_triangle version : option (Z * Z * Z) :=
  nth_error (match version with
    | VersionUS => area2_camera_free_roam_triangles_us
    | VersionJP => area2_camera_free_roam_triangles_jp end) 21%nat.

Definition rank9a_ring_vertices version : list (option (Z * Z * Z)) :=
  map (fun index => nth_error (match version with
    | VersionUS => area2_collision_vertices_us
    | VersionJP => area2_collision_vertices_jp end) index)
    [286%nat; 301%nat; 300%nat].

Theorem rank9a_candidate_uses_generated_west_ring_triangle : forall version,
  rank9a_ring_triangle version = Some (286, 301, 300) /\
  rank9a_ring_vertices version =
    [Some (-101, 3942, 1229); Some (-1535, 3942, 1536); Some (-101, 3942, 1434)].
Proof. intros []; vm_compute; split; reflexivity. Qed.

Definition rank9a_edge_cross ax az bx bz px pz :=
  (bx - ax) * (pz - az) - (bz - az) * (px - ax).

Theorem rank9a_candidate_is_strictly_inside_triangle_projection :
  rank9a_edge_cross (-101) 1229 (-1535) 1536 (-111) 1331 < 0 /\
  rank9a_edge_cross (-1535) 1536 (-101) 1434 (-111) 1331 < 0 /\
  rank9a_edge_cross (-101) 1434 (-101) 1229 (-111) 1331 < 0.
Proof. unfold rank9a_edge_cross. lia. Qed.

(** Lower wall sample Y=3830 is within the shaft wall; upper sample Y=3950
    is above it.  A resulting wall-normal snap reaches X=-111.  These checks
    grant that the query actually chooses that wall/floor: they do not prove
    absence of another wall, earlier landing/ceiling response or list change. *)
Theorem rank9a_candidate_binary32_window :
  Float32.to_bits (Float32.add (rank9a_f32 3800) (rank9a_f32 30)) =
    Float32.to_bits (rank9a_f32 3830) /\
  Float32.to_bits (Float32.add (rank9a_f32 3800) (rank9a_f32 150)) =
    Float32.to_bits (rank9a_f32 3950) /\
  Float32.cmp Cgt (rank9a_f32 3830) (rank9a_f32 3712) = true /\
  Float32.cmp Clt (rank9a_f32 3830) (rank9a_f32 3942) = true /\
  Float32.cmp Cgt (rank9a_f32 3950) (rank9a_f32 3942) = true /\
  Float32.to_bits (Float32.add (rank9a_f32 3800) (rank9a_f32 160)) =
    Float32.to_bits (rank9a_f32 3960) /\
  Float32.cmp Cgt
    (Float32.sub (rank9a_f32 3942) (rank9a_f32 3800)) (rank9a_f32 100) = true /\
  Float32.to_bits rank9a_ledge_x = Float32.to_bits (rank9a_f32 (-111)) /\
  position_in_lower_ring_target_air rank9a_candidate_ring_position = true.
Proof. vm_compute. repeat split; reflexivity. Qed.

(** Use the existing star-orbit mirror honestly: it settles at spawnY+245,
    not spawnY+250.  This is a vertical-overlap calculation only. *)
Theorem rank9a_candidate_prepared_star_height_window :
  forall spawn_y,
    prepared_settled_star_vertical_overlap_model spawn_y 3800 <->
    3505 <= spawn_y <= 3715.
Proof. intro spawn_y. unfold prepared_settled_star_vertical_overlap_model. lia. Qed.

Theorem rank9a_candidate_spawn_3560_has_vertical_overlap :
  prepared_settled_star_vertical_overlap_model 3560 3800 /\
  3560 + 245 = 3805.
Proof. unfold prepared_settled_star_vertical_overlap_model. lia. Qed.

(** Regression for the unhelpful attached-pole alternative: merely retaining
    X/Z at the pole while snapping to the normal 3200 floor is not ring entry. *)
Theorem rank9a_centered_floor_snap_is_not_ring_entry :
  position_in_lower_ring_target_air
    {| vec_x := rank9a_f32 0; vec_y := rank9a_f32 3200;
       vec_z := rank9a_f32 1331 |} = false.
Proof. vm_compute. reflexivity. Qed.

(** Initializer census only: these are the 15 individual yellow-coin records
    (encoded tags 31 and 32).  Even a generous 200-unit rectangular margin
    around the shaft contains none of their X/Z positions.  This does not
    classify formation children, enemy drops, transported coins or later
    live writes, and it does not equate an initializer to a reached object. *)
Definition rank9a_individual_coin_records version :=
  let data := gvar_init (match version with
    | VersionUS => us_ssl_area2_macro.v_ssl_seg7_area_2_macro_objs
    | VersionJP => jp_ssl_area2_macro.v_ssl_seg7_area_2_macro_objs end) in
  records_with_tag 31 data ++ records_with_tag 32 data.

Definition rank9a_coin_outside_expanded_shaft record := match record with
| [_; x; _; z; _] =>
    negb ((-302 <=? x) && (x <=? 302) && (1029 <=? z) && (z <=? 1634))
| _ => false end.

Theorem rank9a_individual_coin_initializer_census : forall version,
  length (rank9a_individual_coin_records version) = 15%nat /\
  forallb rank9a_coin_outside_expanded_shaft
    (rank9a_individual_coin_records version) = true.
Proof. intros []; vm_compute; split; reflexivity. Qed.

Definition Rank9AGeometricTestBoundary : Prop :=
  (forall version,
    rank9a_ring_triangle version = Some (286, 301, 300) /\
    rank9a_ring_vertices version =
      [Some (-101, 3942, 1229); Some (-1535, 3942, 1536); Some (-101, 3942, 1434)]) /\
  position_in_lower_ring_target_air rank9a_candidate_ring_position = true /\
  (forall spawn_y,
    prepared_settled_star_vertical_overlap_model spawn_y 3800 <->
    3505 <= spawn_y <= 3715) /\
  (forall version,
    length (rank9a_individual_coin_records version) = 15%nat /\
    forallb rank9a_coin_outside_expanded_shaft
      (rank9a_individual_coin_records version) = true).

Theorem rank9a_geometric_test_boundary_checked : Rank9AGeometricTestBoundary.
Proof.
  split; [exact rank9a_candidate_uses_generated_west_ring_triangle |].
  split.
  - vm_compute. reflexivity.
  - split; [exact rank9a_candidate_prepared_star_height_window |
      exact rank9a_individual_coin_initializer_census].
Qed.
