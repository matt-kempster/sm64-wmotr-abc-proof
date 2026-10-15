From Coq Require Import Bool Lia List ZArith.
From compcert Require Import AST Clight Clightdefs Coqlib Cop Ctypes Errors
  Events Globalenvs Integers Maps Memdata Memory Values.
From Demo.Generated Require Import us_area jp_area us_level_update jp_level_update.
From Demo.Proofs Require Import DemoExecutionHistory DemoInputOriginObservation
  DemoAreaInitialization.
Import ListNotations.
Local Open Scope Z_scope.
Module AS := us_area.

(** Raw observations only: no owner level, input identity, active flag,
    successful allocation or materialized-terrain assertion occurs here.
    Missing/invalid snapshots must remain a coverage/coherence obligation of
    the full specification, rather than excluding an original controller read. *)
Record demo_area_scene_snapshot := {
 snapshot_current_global : block;
 snapshot_area_block : block;
 snapshot_area_offset : ptrofs;
 snapshot_area_index : int;
 snapshot_area_flags : int;
 snapshot_area_geometry : val;
 snapshot_area_terrain : val;
 snapshot_area_rooms : val;
 snapshot_area_macros : val;
 snapshot_area_objects : val;
 snapshot_area_camera : val
}.

Inductive demo_area_snapshot_field :=
| SnapshotAreaIndex | SnapshotAreaFlags | SnapshotAreaGeometry | SnapshotAreaTerrain
| SnapshotAreaRooms | SnapshotAreaMacros | SnapshotAreaObjects | SnapshotAreaCamera.

Definition snapshot_field_id field : ident :=
 match field with
 | SnapshotAreaIndex => AS._index | SnapshotAreaFlags => AS._flags
 | SnapshotAreaGeometry => AS._unk04 | SnapshotAreaTerrain => AS._terrainData
 | SnapshotAreaRooms => AS._surfaceRooms | SnapshotAreaMacros => AS._macroObjects
 | SnapshotAreaObjects => AS._objectSpawnInfos | SnapshotAreaCamera => AS._camera
 end.
Definition snapshot_field_delta field : Z :=
 match field with
 | SnapshotAreaIndex => 0 | SnapshotAreaFlags => 1 | SnapshotAreaGeometry => 4
 | SnapshotAreaTerrain => 8 | SnapshotAreaRooms => 12 | SnapshotAreaMacros => 16
 | SnapshotAreaObjects => 32 | SnapshotAreaCamera => 36
 end.
Definition snapshot_field_type field : type :=
 match field with
 | SnapshotAreaIndex | SnapshotAreaFlags => tschar
 | SnapshotAreaGeometry => tptr (Tstruct AS._GraphNodeRoot noattr)
 | SnapshotAreaTerrain | SnapshotAreaMacros => tptr tshort
 | SnapshotAreaRooms => tptr tschar
 | SnapshotAreaObjects => tptr (Tstruct AS._SpawnInfo noattr)
 | SnapshotAreaCamera => tptr (Tstruct AS._Camera noattr)
 end.
Definition snapshot_field_chunk field : memory_chunk :=
 match field with SnapshotAreaIndex | SnapshotAreaFlags => Mint8signed | _ => Mptr end.
Definition snapshot_field_value snapshot field : val :=
 match field with
 | SnapshotAreaIndex => Vint (snapshot_area_index snapshot)
 | SnapshotAreaFlags => Vint (snapshot_area_flags snapshot)
 | SnapshotAreaGeometry => snapshot_area_geometry snapshot
 | SnapshotAreaTerrain => snapshot_area_terrain snapshot
 | SnapshotAreaRooms => snapshot_area_rooms snapshot
 | SnapshotAreaMacros => snapshot_area_macros snapshot
 | SnapshotAreaObjects => snapshot_area_objects snapshot
 | SnapshotAreaCamera => snapshot_area_camera snapshot
 end.
Definition snapshot_field_address snapshot field : Z :=
 Ptrofs.unsigned (Ptrofs.add (snapshot_area_offset snapshot)
   (Ptrofs.repr (snapshot_field_delta field))).

Definition demo_area_snapshot_layout (ge : Clight.genv) : Prop :=
 exists co, (genv_cenv ge) ! AS._Area = Some co /\
   co_members co = clear_area_members /\ co_sizeof co = 60.

Definition demo_area_snapshot_holds ge m snapshot : Prop :=
 demo_area_snapshot_layout ge /\
 Genv.find_symbol ge AS._gCurrentArea = Some (snapshot_current_global snapshot) /\
 Mem.load Mptr m (snapshot_current_global snapshot) 0 =
   Some (Vptr (snapshot_area_block snapshot) (snapshot_area_offset snapshot)) /\
 forall field, Mem.load (snapshot_field_chunk field) m (snapshot_area_block snapshot)
   (snapshot_field_address snapshot field) = Some (snapshot_field_value snapshot field).

Definition demo_area_snapshot_at {prog} (history : demo_execution_history prog) index snapshot : Prop :=
 history_index_valid history index /\
 demo_area_snapshot_holds (Clight.globalenv prog) (origin_history_memory history index) snapshot.

Definition demo_no_current_area_at {prog} (history : demo_execution_history prog) index : Prop :=
 history_index_valid history index /\ exists global,
 Genv.find_symbol (Clight.globalenv prog) AS._gCurrentArea = Some global /\
 Mem.load Mptr (origin_history_memory history index) global 0 = Some Vzero.

Lemma generated_area_snapshot_layout_us_jp : forall us ge,
 genv_cenv ge = prog_comp_env (clear_area_program us) -> demo_area_snapshot_layout ge.
Proof.
 intros us ge Henv.
 destruct (generated_clear_area_layout_exists_us_jp us ge Henv) as [layout _].
 exists (clear_area_co ge layout). split; [exact (clear_area_lookup ge layout) |].
 split; [exact (clear_area_members_match ge layout) | exact (clear_area_size ge layout)].
Qed.

Lemma snapshot_field_layout : forall ge field,
 demo_area_snapshot_layout ge ->
 exists co, (genv_cenv ge) ! AS._Area = Some co /\
 field_offset (genv_cenv ge) (snapshot_field_id field) (co_members co) =
   OK (snapshot_field_delta field, Full) /\
 access_mode (snapshot_field_type field) = By_value (snapshot_field_chunk field).
Proof.
 intros ge field (co & Hlookup & Hmembers & Hsize).
 exists co. split; [exact Hlookup |]. rewrite Hmembers.
 destruct field; split; reflexivity.
Qed.

(** These expressions are selected from generated field loads, not a new
    hand-written gameplay routine. Index/geometry/terrain/rooms/macros/objects
    occur in load_area; flags in load_mario_area; camera in basic_update. *)
Definition snapshot_source_function (us : bool) field : function :=
 match field with
 | SnapshotAreaFlags => if us then AS.f_load_mario_area else jp_area.f_load_mario_area
 | SnapshotAreaCamera => if us then us_level_update.f_basic_update else jp_level_update.f_basic_update
 | _ => if us then AS.f_load_area else jp_area.f_load_area
 end.
Definition snapshot_source_pointer_temp field : ident :=
 match field with
 | SnapshotAreaIndex => AS._t'16 | SnapshotAreaFlags => AS._t'7
 | SnapshotAreaGeometry => AS._t'2 | SnapshotAreaTerrain => AS._t'8
 | SnapshotAreaRooms => AS._t'12 | SnapshotAreaMacros => AS._t'14
 | SnapshotAreaObjects => AS._t'4 | SnapshotAreaCamera => us_level_update._t'2
 end.
Definition snapshot_first_expr (a b : option expr) : option expr :=
 match a with Some _ => a | None => b end.
Fixpoint snapshot_find_field (wanted : ident) (s : statement) : option expr :=
 match s with
 | Sset _ (Efield (Ederef (Etempvar _ _) (Tstruct tag _)) field ty) =>
     if Pos.eqb tag AS._Area && Pos.eqb field wanted
     then match s with Sset _ expression => Some expression | _ => None end
     else None
 | Ssequence a b => snapshot_first_expr (snapshot_find_field wanted a) (snapshot_find_field wanted b)
 | Sifthenelse _ a b => snapshot_first_expr (snapshot_find_field wanted a) (snapshot_find_field wanted b)
 | _ => None
 end.
Definition snapshot_source_expression us field : expr :=
 match snapshot_find_field (snapshot_field_id field) (fn_body (snapshot_source_function us field)) with
 | Some expression => expression | None => Econst_int Int.zero tint end.

Lemma generated_snapshot_source_expression_us_jp : forall us field,
 snapshot_source_expression us field =
 Efield (Ederef (Etempvar (snapshot_source_pointer_temp field) (tptr (Tstruct AS._Area noattr)))
   (Tstruct AS._Area noattr)) (snapshot_field_id field) (snapshot_field_type field).
Proof. intros [] []; reflexivity. Qed.

Definition snapshot_current_area_expression (us : bool) : expr :=
 match fn_body (if us then AS.f_load_area else jp_area.f_load_area) with
 | Ssequence (Ssequence (Sset _ expression) _) _ => expression
 | _ => Econst_int Int.zero tint
 end.
Lemma generated_snapshot_current_area_expression_us_jp : forall us,
 snapshot_current_area_expression us = Evar AS._gCurrentArea (tptr (Tstruct AS._Area noattr)).
Proof. intros []; reflexivity. Qed.

Theorem demo_area_snapshot_supplies_actual_field_read : forall us ge e le m snapshot field,
 demo_area_snapshot_holds ge m snapshot ->
 le ! (snapshot_source_pointer_temp field) =
   Some (Vptr (snapshot_area_block snapshot) (snapshot_area_offset snapshot)) ->
 eval_expr ge e le m (snapshot_source_expression us field) (snapshot_field_value snapshot field).
Proof.
 intros us ge e le m snapshot field (Hlayout & Hsymbol & Hcurrent & Hfields) Hpointer.
 destruct (snapshot_field_layout ge field Hlayout) as (co & Hco & Hoffset & Hmode).
 rewrite generated_snapshot_source_expression_us_jp.
 eapply eval_Elvalue.
 - eapply eval_Efield_struct with (co := co) (delta := snapshot_field_delta field) (bf := Full).
   + eapply eval_Elvalue with (loc := snapshot_area_block snapshot)
       (ofs := snapshot_area_offset snapshot) (bf := Full).
     * apply eval_Ederef. apply eval_Etempvar. exact Hpointer.
     * apply deref_loc_copy. reflexivity.
   + reflexivity.
   + exact Hco.
   + exact Hoffset.
 - apply deref_loc_value with (chunk := snapshot_field_chunk field); [exact Hmode |].
   change (Mem.load (snapshot_field_chunk field) m (snapshot_area_block snapshot)
     (snapshot_field_address snapshot field) = Some (snapshot_field_value snapshot field)).
   apply Hfields.
Qed.

Theorem demo_area_snapshot_supplies_actual_current_read : forall us ge le m snapshot,
 demo_area_snapshot_holds ge m snapshot ->
 eval_expr ge empty_env le m (snapshot_current_area_expression us)
   (Vptr (snapshot_area_block snapshot) (snapshot_area_offset snapshot)).
Proof.
 intros us ge le m snapshot (Hlayout & Hsymbol & Hcurrent & Hfields).
 rewrite generated_snapshot_current_area_expression_us_jp.
 eapply eval_Elvalue with (loc := snapshot_current_global snapshot) (ofs := Ptrofs.zero) (bf := Full).
 - apply eval_Evar_global; [reflexivity | exact Hsymbol].
 - apply deref_loc_value with (chunk := Mptr); [reflexivity | exact Hcurrent].
Qed.

(** Exact byte footprint of the pointer and observed fields. This deliberately
    does not freeze all scene objects/camera/terrain bytes: legitimate updates
    mutate them. Materialization and ownership have separate history receipts. *)
Definition demo_area_snapshot_bytes snapshot b byte : Prop :=
 (b = snapshot_current_global snapshot /\ 0 <= byte < size_chunk Mptr) \/
 exists field, b = snapshot_area_block snapshot /\
   snapshot_field_address snapshot field <= byte <
     snapshot_field_address snapshot field + size_chunk (snapshot_field_chunk field).

Lemma snapshot_region_history_load : forall prog (history : demo_execution_history prog)
    first past snapshot chunk b offset value,
 origin_region_history history first past (demo_area_snapshot_bytes snapshot) ->
 (forall byte, offset <= byte < offset + size_chunk chunk -> demo_area_snapshot_bytes snapshot b byte) ->
 Mem.load chunk (origin_history_memory history first) b offset = Some value ->
 Mem.load chunk (origin_history_memory history past) b offset = Some value.
Proof.
 intros prog history first past snapshot chunk b offset value [Hbounds Hframes] Hregion Hload.
 eapply origin_region_history_preserves_load; [|exact Hload].
 split; [exact Hbounds |]. intros index Hindex.
 eapply Mem.unchanged_on_implies; [apply Hframes; exact Hindex |].
 intros block byte [Hblock Hbyte] Hvalid. subst block. apply Hregion. exact Hbyte.
Qed.

Theorem demo_area_snapshot_transport : forall prog (history : demo_execution_history prog)
    first past snapshot,
 demo_area_snapshot_at history first snapshot ->
 origin_region_history history first past (demo_area_snapshot_bytes snapshot) ->
 demo_area_snapshot_at history past snapshot.
Proof.
 intros prog history first past snapshot [Hfirst [Hlayout [Hsymbol [Hcurrent Hfields]]]] Hframe.
 split.
 - destruct Hframe as [Hbounds _]. unfold history_index_valid, history_interval in *. lia.
 - split; [exact Hlayout |]. split; [exact Hsymbol |]. split.
   + eapply snapshot_region_history_load; [exact Hframe | |exact Hcurrent].
     intros byte Hbyte. left. split; [reflexivity | exact Hbyte].
   + intros field. eapply snapshot_region_history_load; [exact Hframe | |apply Hfields].
     intros byte Hbyte. right. exists field. split; [reflexivity | exact Hbyte].
Qed.

Definition demo_area_scene_observation_claim : Prop :=
 (forall us ge e le m snapshot field,
   demo_area_snapshot_holds ge m snapshot ->
   le ! (snapshot_source_pointer_temp field) =
     Some (Vptr (snapshot_area_block snapshot) (snapshot_area_offset snapshot)) ->
   eval_expr ge e le m (snapshot_source_expression us field) (snapshot_field_value snapshot field)) /\
 (forall prog (history : demo_execution_history prog) first past snapshot,
   demo_area_snapshot_at history first snapshot ->
   origin_region_history history first past (demo_area_snapshot_bytes snapshot) ->
   demo_area_snapshot_at history past snapshot).

Theorem generated_area_scene_observation_us_jp : demo_area_scene_observation_claim.
Proof. split; [exact demo_area_snapshot_supplies_actual_field_read | exact demo_area_snapshot_transport]. Qed.
