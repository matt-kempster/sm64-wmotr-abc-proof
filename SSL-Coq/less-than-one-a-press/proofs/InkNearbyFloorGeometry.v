(** Source-data certificates for the proposed 923-unit crawl handoff.

    The region is the square within 100 units in X and Z of (-1882,-939).
    This is a spatial bound, NOT a bound on all pushes or controller motion.
    We reuse the generated initializer parser, source floor classification,
    signed edge tests and binary32 plane evaluator. Live list construction,
    other dynamic surfaces and reaching a crawling state remain open. *)
From Coq Require Import Bool Lia List ZArith.
From compcert Require Import Floats Integers.
From LessThanOneAPress.Proofs Require Import Area1FirstNull
  CollisionMeshFacts InkVerticalRetryGeometry Timer131Surface.
Import ListNotations.
Local Open Scope Z_scope.

Definition infg_is_floor vs : bool :=
  match area1_source_surface_kind vs with
  | Area1SourceFloor => true | _ => false end.

Definition infg_box_intersects
  (vs : Area1SourceVertex * Area1SourceVertex * Area1SourceVertex) : bool :=
  let '(a,b,c) := vs in
  let '(ax,_,az) := a in let '(bx,_,bz) := b in let '(cx,_,cz) := c in
  (Z.leb (Z.min ax (Z.min bx cx)) (-1782) &&
   Z.leb (-1982) (Z.max ax (Z.max bx cx))) &&
  (Z.leb (Z.min az (Z.min bz cz)) (-839) &&
   Z.leb (-1039) (Z.max az (Z.max bz cz))).

Definition infg_nearby_floor face : bool :=
  match area1_source_triangle_vertices area1_collision_vertices_us face with
  | Some vs => infg_is_floor vs && infg_box_intersects vs
  | None => false end.

Definition infg_nearby_faces :=
  filter infg_nearby_floor area1_source_triangle_stream_us.

Definition infg_horizontal_plane_check face : bool :=
  match area1_source_triangle_vertices area1_collision_vertices_us face with
  | Some vs =>
      let '((_,y,_),_,_) := vs in
      let '(nx,ny,nz) := area1_source_normal_components vs in
      ((Z.eqb nx 0 && Z.eqb nz 0) && negb (Z.eqb ny 0)) &&
      (Z.eqb y 768 || Z.eqb y 1280)
  | None => false end.

Theorem infg_nearby_source_inventory_checked :
  length infg_nearby_faces = 7%nat /\
  forallb infg_horizontal_plane_check infg_nearby_faces = true.
Proof. vm_compute. split; reflexivity. Qed.

(** This is an exact integer source-plane obstruction, not a theorem that
    a live Float32 floor traversal has run. Even a point on an extension of
    any of the seven planes cannot have height 818. *)
Theorem infg_no_818_on_nearby_source_floor_plane : forall face a b c x z,
  In face area1_source_triangle_stream_us ->
  infg_nearby_floor face = true ->
  area1_source_triangle_vertices area1_collision_vertices_us face = Some (a,b,c) ->
  let '(ax,ay,az) := a in
  let '(nx,ny,nz) := area1_source_normal_components (a,b,c) in
  nx * (x-ax) + ny * (818-ay) + nz * (z-az) <> 0.
Proof.
  intros face [[ax ay] az] [[bx byc] bz] [[cx cy] cz] x z Hin Hnear Hvertices.
  pose proof (proj2 infg_nearby_source_inventory_checked) as Hcheck.
  rewrite forallb_forall in Hcheck.
  assert (In face infg_nearby_faces) as Hmember.
  { exact (proj2 (filter_In infg_nearby_floor face area1_source_triangle_stream_us)
      (conj Hin Hnear)). }
  specialize (Hcheck face Hmember).
  unfold infg_horizontal_plane_check in Hcheck. rewrite Hvertices in Hcheck.
  cbn [area1_source_normal_components] in Hcheck |- *.
  repeat rewrite andb_true_iff in Hcheck.
  destruct Hcheck as [[[Hx Hz] Hny] Hy].
  apply Z.eqb_eq in Hx. apply Z.eqb_eq in Hz.
  apply negb_true_iff in Hny. apply Z.eqb_neq in Hny.
  rewrite Hx, Hz. rewrite Z.mul_0_l, Z.add_0_l, Z.mul_0_l, Z.add_0_r.
  clear Hin Hnear Hvertices Hmember Hx Hz.
  apply orb_true_iff in Hy. destruct Hy as [Hy|Hy];
    apply Z.eqb_eq in Hy; rewrite Z.mul_eq_0; intros [Hbad|Hbad];
    [exact (Hny Hbad)|lia|exact (Hny Hbad)|lia].
Qed.

Definition infg_query x y z : Area1IntegerQuery :=
  {| area1_query_x := x; area1_query_y := y; area1_query_z := z |}.

(** Early X/Z rejection avoids constructing irrelevant Float32 planes. *)
Definition infg_static_hits x y z :=
  filter (fun face =>
    match area1_source_triangle_vertices area1_collision_vertices_us face with
    | Some vs => if infg_is_floor vs
        then ivr_accepts area1_collision_vertices_us (infg_query x y z) face
        else false
    | None => false end) area1_source_triangle_stream_us.

Theorem infg_target_and_nearby_pad_queries_checked :
  infg_static_hits (-1882) 818 (-939) = [] /\
  infg_static_hits (-1882) 1741 (-939) = [(261,263,264)] /\
  infg_static_hits (-1950) 1741 (-939) = [(498,500,501)] /\
  infg_static_hits (-1950) 768 (-939) = [(498,500,501)] /\
  area1_loaded_plane_bits area1_collision_vertices_us (261,263,264) =
    Some (0,1065353216,0,3298820096) /\
  area1_loaded_plane_bits area1_collision_vertices_us (498,500,501) =
    Some (0,1065353216,0,3292528640).
Proof. vm_compute. repeat split; reflexivity. Qed.

(** Both selected generated meshes agree. These all-source-face checks
    do not assume a favorable dynamic/static list order. A live dynamic
    surface can still change which floor the game actually returns. *)
Theorem infg_source_mesh_versions_agree :
  area1_collision_vertices_us = area1_collision_vertices_jp /\
  area1_source_triangle_stream_us = area1_source_triangle_stream_jp.
Proof. vm_compute. split; reflexivity. Qed.

(** The already-certified timer-131 transformed top is too high at the pad
    query but eligible at the pushed high target. This is NOT a certificate
    for timer130 (the preceding producer update for a timer131 installation),
    for other dynamic actors, or for the subsequent warp continuation. *)
Definition infg_timer131_hits x y z :=
  filter (ivr_accepts timer131_vertices_s16 (infg_query x y z)) ivr_top_floors.

Theorem infg_timer131_high_query_pair_checked :
  infg_timer131_hits (-1950) 1741 (-939) = [] /\
  infg_timer131_hits (-1882) 1741 (-939) = [timer131_retry_face].
Proof. vm_compute. split; reflexivity. Qed.

Definition InkNearbyFloorGeometryBoundary : Prop :=
  (length infg_nearby_faces = 7%nat /\
   forallb infg_horizontal_plane_check infg_nearby_faces = true) /\
  (forall face a b c x z,
    In face area1_source_triangle_stream_us ->
    infg_nearby_floor face = true ->
    area1_source_triangle_vertices area1_collision_vertices_us face = Some (a,b,c) ->
    let '(ax,ay,az) := a in
    let '(nx,ny,nz) := area1_source_normal_components (a,b,c) in
    nx * (x-ax) + ny * (818-ay) + nz * (z-az) <> 0) /\
  (infg_static_hits (-1882) 818 (-939) = [] /\
   infg_static_hits (-1882) 1741 (-939) = [(261,263,264)] /\
   infg_static_hits (-1950) 1741 (-939) = [(498,500,501)] /\
   infg_static_hits (-1950) 768 (-939) = [(498,500,501)] /\
   area1_loaded_plane_bits area1_collision_vertices_us (261,263,264) =
     Some (0,1065353216,0,3298820096) /\
   area1_loaded_plane_bits area1_collision_vertices_us (498,500,501) =
     Some (0,1065353216,0,3292528640)) /\
  (area1_collision_vertices_us = area1_collision_vertices_jp /\
   area1_source_triangle_stream_us = area1_source_triangle_stream_jp) /\
  (infg_timer131_hits (-1950) 1741 (-939) = [] /\
   infg_timer131_hits (-1882) 1741 (-939) = [timer131_retry_face]).

Theorem infg_nearby_floor_geometry_checked : InkNearbyFloorGeometryBoundary.
Proof.
  split; [exact infg_nearby_source_inventory_checked|].
  split; [exact infg_no_818_on_nearby_source_floor_plane|].
  split; [exact infg_target_and_nearby_pad_queries_checked|].
  split; [exact infg_source_mesh_versions_agree|].
  exact infg_timer131_high_query_pair_checked.
Qed.
