From Coq Require Import Bool Lia List ZArith.
From compcert Require Import AST Clight Coqlib Events Globalenvs Integers Memory Values.
From Demo.Proofs Require Import DemoExecutionHistory DemoInputOriginObservation
 DemoGameplayConsumptionObservation DemoAreaSceneObservation.
Local Open Scope Z_scope.

(** A total raw memory probe, not a scene-owner classifier. No stream/header,
    level equality, active flag, index range, successful materialization or
    permitted phase determines whether an actual input read is observed. *)
Inductive demo_gameplay_scene_probe_result : Type :=
| SceneProbeMissingSymbol
| SceneProbeUnreadableCurrent (current_global : block)
| SceneProbeNull (current_global : block)
| SceneProbeInvalidCurrent (current_global : block) (value : val)
| SceneProbeUnavailableField (current_global area : block) (offset : ptrofs)
    (field : demo_area_snapshot_field) (observed : option val)
| SceneProbePresent (snapshot : demo_area_scene_snapshot).

Definition demo_scene_probe_field_address offset field : Z :=
 Ptrofs.unsigned (Ptrofs.add offset (Ptrofs.repr (snapshot_field_delta field))).
Definition demo_scene_probe_field_load memory area offset field : option val :=
 Mem.load (snapshot_field_chunk field) memory area
   (demo_scene_probe_field_address offset field).

(** Present reads all eight typed fields. The first failed typed field is
    retained explicitly with its raw option-value diagnostic. In particular,
    Some Vundef is not silently interpreted as an integer index/flags value.
    The six pointer fields accept every loaded val, including null/Vundef. *)
Definition demo_scene_probe_area_fields memory current area offset : demo_gameplay_scene_probe_result :=
 match demo_scene_probe_field_load memory area offset SnapshotAreaIndex with
 | Some (Vint index) =>
   match demo_scene_probe_field_load memory area offset SnapshotAreaFlags with
   | Some (Vint flags) =>
     match demo_scene_probe_field_load memory area offset SnapshotAreaGeometry with
     | Some geometry =>
       match demo_scene_probe_field_load memory area offset SnapshotAreaTerrain with
       | Some terrain =>
         match demo_scene_probe_field_load memory area offset SnapshotAreaRooms with
         | Some rooms =>
           match demo_scene_probe_field_load memory area offset SnapshotAreaMacros with
           | Some macros =>
             match demo_scene_probe_field_load memory area offset SnapshotAreaObjects with
             | Some objects =>
               match demo_scene_probe_field_load memory area offset SnapshotAreaCamera with
               | Some camera => SceneProbePresent
                 {| snapshot_current_global := current;
                    snapshot_area_block := area;
                    snapshot_area_offset := offset;
                    snapshot_area_index := index;
                    snapshot_area_flags := flags;
                    snapshot_area_geometry := geometry;
                    snapshot_area_terrain := terrain;
                    snapshot_area_rooms := rooms;
                    snapshot_area_macros := macros;
                    snapshot_area_objects := objects;
                    snapshot_area_camera := camera |}
               | unavailable => SceneProbeUnavailableField current area offset SnapshotAreaCamera unavailable
               end
             | unavailable => SceneProbeUnavailableField current area offset SnapshotAreaObjects unavailable
             end
           | unavailable => SceneProbeUnavailableField current area offset SnapshotAreaMacros unavailable
           end
         | unavailable => SceneProbeUnavailableField current area offset SnapshotAreaRooms unavailable
         end
       | unavailable => SceneProbeUnavailableField current area offset SnapshotAreaTerrain unavailable
       end
     | unavailable => SceneProbeUnavailableField current area offset SnapshotAreaGeometry unavailable
     end
   | unavailable => SceneProbeUnavailableField current area offset SnapshotAreaFlags unavailable
   end
 | unavailable => SceneProbeUnavailableField current area offset SnapshotAreaIndex unavailable
 end.

Definition demo_gameplay_scene_probe (ge : Clight.genv) memory : demo_gameplay_scene_probe_result :=
 match Genv.find_symbol ge AS._gCurrentArea with
 | None => SceneProbeMissingSymbol
 | Some current =>
   match Mem.load Mptr memory current 0 with
   | None => SceneProbeUnreadableCurrent current
   | Some (Vptr area offset) => demo_scene_probe_area_fields memory current area offset
   | Some (Vint integer) =>
     if Int.eq integer Int.zero then SceneProbeNull current
     else SceneProbeInvalidCurrent current (Vint integer)
   | Some invalid => SceneProbeInvalidCurrent current invalid
   end
 end.

Lemma demo_scene_probe_fields_present : forall memory current area offset snapshot,
 demo_scene_probe_area_fields memory current area offset = SceneProbePresent snapshot ->
 snapshot_current_global snapshot = current /\
 snapshot_area_block snapshot = area /\ snapshot_area_offset snapshot = offset /\
 forall field, demo_scene_probe_field_load memory area offset field =
   Some (snapshot_field_value snapshot field).
Proof.
 intros memory current area offset snapshot Hprobe.
 unfold demo_scene_probe_area_fields in Hprobe.
 destruct (demo_scene_probe_field_load memory area offset SnapshotAreaIndex)
   as [indexvalue|] eqn:Hindex; [destruct indexvalue |]; try discriminate.
 destruct (demo_scene_probe_field_load memory area offset SnapshotAreaFlags)
   as [flagsvalue|] eqn:Hflags; [destruct flagsvalue |]; try discriminate.
 destruct (demo_scene_probe_field_load memory area offset SnapshotAreaGeometry)
   as [geometry|] eqn:Hgeometry; try discriminate.
 destruct (demo_scene_probe_field_load memory area offset SnapshotAreaTerrain)
   as [terrain|] eqn:Hterrain; try discriminate.
 destruct (demo_scene_probe_field_load memory area offset SnapshotAreaRooms)
   as [rooms|] eqn:Hrooms; try discriminate.
 destruct (demo_scene_probe_field_load memory area offset SnapshotAreaMacros)
   as [macros|] eqn:Hmacros; try discriminate.
 destruct (demo_scene_probe_field_load memory area offset SnapshotAreaObjects)
   as [objects|] eqn:Hobjects; try discriminate.
 destruct (demo_scene_probe_field_load memory area offset SnapshotAreaCamera)
   as [camera|] eqn:Hcamera; try discriminate.
 inversion Hprobe; subst snapshot. repeat split; try reflexivity.
 intros []; cbn [snapshot_field_value]; assumption.
Qed.

Theorem demo_gameplay_scene_probe_present_holds : forall ge memory snapshot,
 demo_area_snapshot_layout ge ->
 demo_gameplay_scene_probe ge memory = SceneProbePresent snapshot ->
 demo_area_snapshot_holds ge memory snapshot.
Proof.
 intros ge memory snapshot Hlayout Hprobe. unfold demo_gameplay_scene_probe in Hprobe.
 destruct (Genv.find_symbol ge AS._gCurrentArea) as [current|] eqn:Hsymbol; try discriminate.
 destruct (Mem.load Mptr memory current 0) as [value|] eqn:Hcurrent; try discriminate.
 destruct value; try discriminate.
 - destruct (Int.eq i Int.zero); discriminate.
 - destruct (demo_scene_probe_fields_present _ _ _ _ _ Hprobe)
     as (Hglobal & Harea & Hoffset & Hfields).
   split; [exact Hlayout |]. split; [rewrite Hglobal; exact Hsymbol |].
   split; [rewrite Hglobal,Harea,Hoffset; exact Hcurrent |].
   intros field. unfold snapshot_field_address.
   rewrite Harea,Hoffset. apply Hfields.
Qed.

Theorem demo_gameplay_scene_probe_null_holds : forall ge memory current,
 demo_gameplay_scene_probe ge memory = SceneProbeNull current ->
 Genv.find_symbol ge AS._gCurrentArea = Some current /\
 Mem.load Mptr memory current 0 = Some Vzero.
Proof.
 intros ge memory current Hprobe. unfold demo_gameplay_scene_probe in Hprobe.
 destruct (Genv.find_symbol ge AS._gCurrentArea) as [global|] eqn:Hsymbol; try discriminate.
 destruct (Mem.load Mptr memory global 0) as [value|] eqn:Hcurrent; try discriminate.
 destruct value; try discriminate.
 - destruct (Int.eq i Int.zero) eqn:Hzero; try discriminate.
   pose proof (Int.eq_spec i Int.zero) as Heq. rewrite Hzero in Heq. subst i.
   inversion Hprobe; subst current. split; [reflexivity | exact Hcurrent].
 - unfold demo_scene_probe_area_fields in Hprobe.
   repeat match type of Hprobe with
   | context [match ?term with _ => _ end] => destruct term; try discriminate
   end.
Qed.

(** Pair the existing, unfiltered actual input-read observation with the probe
    at exactly the same source memory index. Failure is an observable result,
    never a reason to drop that input-read observation. *)
Definition demo_gameplay_scene_observation us prog
    (history : demo_execution_history prog) index controller offset field value result : Prop :=
 demo_gameplay_consumption_observation us prog history index controller offset field value /\
 demo_gameplay_scene_probe (Clight.globalenv prog) (origin_history_memory history index) = result.

Theorem demo_actual_read_has_scene_probe : forall us prog history index controller offset field value,
 demo_gameplay_consumption_observation us prog history index controller offset field value ->
 exists result, demo_gameplay_scene_observation us prog history index controller offset field value result.
Proof. intros. eexists. split; [eassumption | reflexivity]. Qed.

Theorem demo_paired_scene_observation_is_actual_read :
 forall us prog history index controller offset field value result,
 demo_gameplay_scene_observation us prog history index controller offset field value result ->
 demo_gameplay_consumption_observation us prog history index controller offset field value /\
 Clight.step2 (Clight.globalenv prog) (history_state history index) E0
   (history_state history (S index)).
Proof.
 intros us prog history index controller offset field value result [Hread Hprobe].
 split; [exact Hread | eapply demo_gameplay_consumption_history_step; exact Hread].
Qed.

Theorem demo_paired_present_scene_snapshot_at :
 forall us prog history index controller offset field value snapshot,
 demo_area_snapshot_layout (Clight.globalenv prog) ->
 demo_gameplay_scene_observation us prog history index controller offset field value
   (SceneProbePresent snapshot) -> demo_area_snapshot_at history index snapshot.
Proof.
 intros us prog history index controller offset field value snapshot Hlayout [Hread Hprobe].
 split.
 - destruct Hread as [Hbound _]. unfold history_index_valid. lia.
 - eapply demo_gameplay_scene_probe_present_holds; eassumption.
Qed.

Theorem demo_paired_null_scene_snapshot_at :
 forall us prog history index controller offset field value current,
 demo_gameplay_scene_observation us prog history index controller offset field value
   (SceneProbeNull current) -> demo_no_current_area_at history index.
Proof.
 intros us prog history index controller offset field value current [Hread Hprobe].
 split.
 - destruct Hread as [Hbound _]. unfold history_index_valid. lia.
 - exists current. apply demo_gameplay_scene_probe_null_holds. exact Hprobe.
Qed.

Definition demo_gameplay_scene_observation_claim : Prop :=
 (forall ge memory snapshot,
   demo_area_snapshot_layout ge ->
   demo_gameplay_scene_probe ge memory = SceneProbePresent snapshot ->
   demo_area_snapshot_holds ge memory snapshot) /\
 (forall ge memory current,
   demo_gameplay_scene_probe ge memory = SceneProbeNull current ->
   Genv.find_symbol ge AS._gCurrentArea = Some current /\
   Mem.load Mptr memory current 0 = Some Vzero) /\
 (forall us prog history index controller offset field value,
   demo_gameplay_consumption_observation us prog history index controller offset field value ->
   exists result, demo_gameplay_scene_observation us prog history index controller offset field value result) /\
 (forall us prog history index controller offset field value result,
   demo_gameplay_scene_observation us prog history index controller offset field value result ->
   demo_gameplay_consumption_observation us prog history index controller offset field value /\
   Clight.step2 (Clight.globalenv prog) (history_state history index) E0
     (history_state history (S index))).

Theorem checked_demo_gameplay_scene_observation : demo_gameplay_scene_observation_claim.
Proof.
 split; [exact demo_gameplay_scene_probe_present_holds |].
 split; [exact demo_gameplay_scene_probe_null_holds |].
 split; [exact demo_actual_read_has_scene_probe | exact demo_paired_scene_observation_is_actual_read].
Qed.
