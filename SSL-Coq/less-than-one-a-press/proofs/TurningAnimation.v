From Coq Require Import List Lia ZArith.
From compcert Require Import Clight Floats Integers.
From LessThanOneAPress.Proofs Require Import GameTypes ClightFacts.

Import ListNotations.
Local Open Scope Z_scope.

(** * Turning Part 2 is not an animation-induced upwarp

    This module separates three claims:

    - generated US/JP Clight syntax fixes the turning selector, setter, loader,
      and renderer footprints;
    - a small coordinate-view model proves that a metadata-only animation
      transition cannot create a State/Object/Graphics split; and
    - an explicit counterexample explains why the corresponding linked-memory
      theorem still needs an animation-buffer separation premise.

    The coordinate model is not presented as an execution of the imported C.
    [TurningAnimationCoordinateFootprintRefinementObligation] below names the
    missing link. *)

(** ** Pinned asset-data mirror

    These constants mirror animation entry [anim_BD] in
    [assets/anims/anim_BC_BD.inc.c] after the pinned
    [tools/mario_anims_converter.py] table ordering.  Their arithmetic is
    checked here; [TurningPart2AssetMappingObligation] keeps the
    converter/source-to-memory connection explicit. *)

Definition turning_part1_animation_id : Z := 188.
Definition turning_part2_animation_id : Z := 189.
Definition mario_animation_entry_count : Z := 209.
Definition mario_animation_buffer_bytes : Z := 16384.
Definition turning_part2_payload_bytes : Z := 1804.

Definition turning_part2_flags : Z := 1.
Definition turning_part2_y_divisor : Z := 189.
Definition turning_part2_start_frame : Z := 1.
Definition turning_part2_loop_start : Z := 0.
Definition turning_part2_loop_end : Z := 18.

Definition animation_flag_hor_trans : Z := 8.
Definition animation_flag_vert_trans : Z := 16.
Definition animation_flag_6 : Z := 64.
Definition gameplay_translation_flag_mask : Z :=
  Z.lor animation_flag_hor_trans
    (Z.lor animation_flag_vert_trans animation_flag_6).

Definition turning_part2_root_y_values : list Z :=
  [87; 88; 90; 93; 96; 101; 108; 131; 165;
   204; 241; 271; 286; 280; 257; 228; 203; 192].

Definition turning_f32_189 : float32 :=
  Float32.of_int (Int.repr 189).

Definition turning_f32_quarter : float32 :=
  Float32.of_bits (Int.repr 1048576000).

Theorem turning_part2_asset_bounds_checked :
  0 <= turning_part2_animation_id < mario_animation_entry_count /\
  0 < turning_part2_payload_bytes <= mario_animation_buffer_bytes.
Proof.
  unfold turning_part2_animation_id, mario_animation_entry_count,
    turning_part2_payload_bytes, mario_animation_buffer_bytes.
  lia.
Qed.

Theorem turning_part2_has_no_gameplay_translation_flag :
  Z.land turning_part2_flags gameplay_translation_flag_mask = 0.
Proof.
  vm_compute.
  reflexivity.
Qed.

Theorem turning_part2_root_y_values_bounded :
  Forall (fun value => 87 <= value <= 286)
    turning_part2_root_y_values.
Proof.
  unfold turning_part2_root_y_values.
  repeat constructor; lia.
Qed.

(** The renderer performs this division in binary32.  The result is exactly
    [1.0f], not a 189-unit displacement. *)
Theorem turning_part2_translation_multiplier_binary32_checked :
  Float32.to_bits
    (Float32.div turning_f32_189 turning_f32_189) =
  Int.repr 1065353216.
Proof.
  vm_compute.
  reflexivity.
Qed.

(** The extremal raw root-Y samples, after Mario's ordinary one-quarter model
    scale, are exactly [21.75f] and [71.5f].  They are render-child offsets
    relative to [header.gfx.pos], not writes to that anchor. *)
Theorem turning_part2_render_y_extrema_binary32_checked :
  Float32.to_bits
    (Float32.mul
      (Float32.of_int (Int.repr 87))
      turning_f32_quarter) =
      Int.repr 1101922304 /\
  Float32.to_bits
    (Float32.mul
      (Float32.of_int (Int.repr 286))
      turning_f32_quarter) =
      Int.repr 1116667904.
Proof.
  vm_compute.
  split; reflexivity.
Qed.

(** A fresh switch to Part 2 has neither BACKWARD nor FLAG_2, so the source
    initializes [animFrame] to [startFrame - 1 = 0].  The immediately
    following end test compares [0 + 1] with loop end [18] and is false. *)
Theorem fresh_turning_part2_is_not_immediately_at_end :
  turning_part2_start_frame - 1 = 0 /\
  turning_part2_start_frame - 1 + 1 <>
    turning_part2_loop_end.
Proof.
  vm_compute.
  lia.
Qed.

(** ** Three gameplay coordinate views *)

Record TurningAnimationSnapshot : Type := {
  turning_state_position : Vec3f;
  turning_object_position : Vec3f;
  turning_graphics_anchor : Vec3f;
  turning_animation_id : Z;
  turning_animation_y_translation : Z;
  turning_animation_frame : Z
}.

Definition turning_gameplay_coordinates
    (snapshot : TurningAnimationSnapshot) : Vec3f * Vec3f * Vec3f :=
  (turning_state_position snapshot,
   turning_object_position snapshot,
   turning_graphics_anchor snapshot).

(** This is the exact footprint of the metadata branch in the small model.
    It deliberately excludes the separately called DMA and rendering
    functions; their concrete memory footprint is a refinement obligation. *)
Definition set_turning_part2_metadata
    (snapshot : TurningAnimationSnapshot) : TurningAnimationSnapshot := {|
  turning_state_position := turning_state_position snapshot;
  turning_object_position := turning_object_position snapshot;
  turning_graphics_anchor := turning_graphics_anchor snapshot;
  turning_animation_id := turning_part2_animation_id;
  turning_animation_y_translation := 189;
  turning_animation_frame := turning_part2_start_frame - 1
|}.

Inductive TurningPart2MetadataStep :
    TurningAnimationSnapshot -> TurningAnimationSnapshot -> Prop :=
| TurningPart2MetadataChanged :
    forall before,
      TurningPart2MetadataStep
        before (set_turning_part2_metadata before)
| TurningPart2MetadataAlreadySelected :
    forall before,
      turning_animation_id before = turning_part2_animation_id ->
      TurningPart2MetadataStep before before.

Theorem turning_part2_metadata_step_preserves_gameplay_coordinates :
  forall before after,
    TurningPart2MetadataStep before after ->
    turning_gameplay_coordinates after =
      turning_gameplay_coordinates before.
Proof.
  intros before after Hstep.
  destruct Hstep; cbn; reflexivity.
Qed.

Theorem turning_part2_metadata_step_preserves_each_gameplay_view :
  forall before after,
    TurningPart2MetadataStep before after ->
    turning_state_position after = turning_state_position before /\
    turning_object_position after = turning_object_position before /\
    turning_graphics_anchor after = turning_graphics_anchor before.
Proof.
  intros before after Hstep.
  destruct Hstep; cbn; repeat split; reflexivity.
Qed.

Definition three_views_synchronized
    (snapshot : TurningAnimationSnapshot) : Prop :=
  turning_state_position snapshot =
    turning_object_position snapshot /\
  turning_object_position snapshot =
    turning_graphics_anchor snapshot.

(** Consequently the setter cannot itself manufacture Ink's required
    State/Object/Graphics phase split from synchronized input. *)
Theorem turning_part2_metadata_cannot_create_ink_split :
  forall before after,
    TurningPart2MetadataStep before after ->
    three_views_synchronized before ->
    three_views_synchronized after.
Proof.
  intros before after Hstep Hsync.
  destruct Hstep; cbn in *; exact Hsync.
Qed.

(** Any collision/floor/fallback classifier that depends only on the three
    gameplay coordinate samples observes the same result. *)
Theorem turning_part2_preserves_every_coordinate_observer :
  forall (Result : Type)
         (observe : Vec3f * Vec3f * Vec3f -> Result)
         before after,
    TurningPart2MetadataStep before after ->
    observe (turning_gameplay_coordinates after) =
      observe (turning_gameplay_coordinates before).
Proof.
  intros Result observe before after Hstep.
  rewrite (turning_part2_metadata_step_preserves_gameplay_coordinates
    before after Hstep).
  reflexivity.
Qed.

(** ** Why a memory-separation premise is necessary *)

Definition TinyMemory : Type := nat -> Z.

Definition dma_write_one_cell
    (destination : nat) (payload : Z)
    (memory : TinyMemory) : TinyMemory :=
  fun address =>
    if Nat.eqb address destination then payload else memory address.

Theorem separated_one_cell_dma_preserves_coordinate :
  forall animation_destination coordinate_address payload memory,
    animation_destination <> coordinate_address ->
    dma_write_one_cell animation_destination payload memory
      coordinate_address =
    memory coordinate_address.
Proof.
  intros animation_destination coordinate_address payload memory Hneq.
  unfold dma_write_one_cell.
  apply Nat.eqb_neq in Hneq.
  rewrite Nat.eqb_sym, Hneq.
  reflexivity.
Qed.

(** Counterexample to an unconditional frame rule: an over-permissive model
    may make [bufTarget] alias a projected Mario coordinate.  The witness is
    not a retail-game state; retail initialization is expected to discharge
    the separation obligation below. *)
Theorem over_permissive_animation_dma_alias_counterexample :
  exists animation_destination coordinate_address memory,
    animation_destination = coordinate_address /\
    dma_write_one_cell animation_destination 1 memory
      coordinate_address <>
    memory coordinate_address.
Proof.
  exists 0%nat, 0%nat, (fun _ => 0).
  split; [reflexivity |].
  cbn.
  discriminate.
Qed.

(** ** Explicit remaining refinement obligations *)

Record TurningPart2AssetHeader : Type := {
  turning_asset_flags : Z;
  turning_asset_divisor : Z;
  turning_asset_start : Z;
  turning_asset_loop_start : Z;
  turning_asset_loop_end : Z;
  turning_asset_payload_size : Z;
  turning_asset_root_y : list Z
}.

Definition mirrored_turning_part2_asset : TurningPart2AssetHeader := {|
  turning_asset_flags := turning_part2_flags;
  turning_asset_divisor := turning_part2_y_divisor;
  turning_asset_start := turning_part2_start_frame;
  turning_asset_loop_start := turning_part2_loop_start;
  turning_asset_loop_end := turning_part2_loop_end;
  turning_asset_payload_size := turning_part2_payload_bytes;
  turning_asset_root_y := turning_part2_root_y_values
|}.

(** Connect the converter-produced table in linked US/JP memory to the pinned
    asset mirror above. *)
Definition TurningPart2AssetMappingObligation
    (project_asset :
      GameVersion -> Z -> option TurningPart2AssetHeader) : Prop :=
  forall version,
    project_asset version turning_part2_animation_id =
      Some mirrored_turning_part2_asset.

(** Give [dma_read] its target-specific frame rule: a successful Part-2 load
    writes only the dedicated animation block and cannot overlap the projected
    MarioState, Mario object, or GraphNodeObject anchor fields. *)
Definition MarioAnimationBufferSeparationObligation
    (animation_write_address gameplay_address : nat -> Prop) : Prop :=
  forall address,
    animation_write_address address ->
    ~ gameplay_address address.

(** The final linked transition theorem.  [executes_turning_part2] must be the
    actual Clight/compiled-step relation, not an oracle chosen to encode the
    conclusion. *)
Definition TurningAnimationCoordinateFootprintRefinementObligation
    (executes_turning_part2 :
      GameVersion -> Clight.state -> Clight.state -> Prop)
    (project_snapshot :
      GameVersion -> Clight.state -> option TurningAnimationSnapshot) : Prop :=
  forall version before after before_snapshot after_snapshot,
    executes_turning_part2 version before after ->
    project_snapshot version before = Some before_snapshot ->
    project_snapshot version after = Some after_snapshot ->
    turning_gameplay_coordinates after_snapshot =
      turning_gameplay_coordinates before_snapshot.

(** The collision-side residual is now correctly located: after animation
    metadata is shown not to write coordinates, any observed upwarp must be
    justified by the real motion/ground-step/floor execution (or an earlier
    platform/OOB writer), not by the numeric [0xBD] coincidence. *)
Definition TurningGroundStepUpwarpClassificationObligation
    (executes_turning_frame :
      GameVersion -> Clight.state -> Clight.state -> Prop)
    (coordinate_change_classified :
      GameVersion -> Clight.state -> Clight.state -> Prop) : Prop :=
  forall version before after,
    executes_turning_frame version before after ->
    coordinate_change_classified version before after.

(** ** Fully proved source/arithmetic boundary *)

Definition turning_animation_source_kernel : Prop :=
  turning_part2_selection_source_shape_us_claim /\
  turning_part2_selection_source_shape_jp_claim /\
  set_mario_animation_footprint_source_shape_us_claim /\
  set_mario_animation_footprint_source_shape_jp_claim /\
  load_patchable_table_source_shape_us_claim /\
  load_patchable_table_source_shape_jp_claim /\
  turning_animation_renderer_source_shape_us_claim /\
  turning_animation_renderer_source_shape_jp_claim /\
  turning_animation_holp_caveat_source_shape_us_claim /\
  turning_animation_holp_caveat_source_shape_jp_claim /\
  Float32.to_bits
    (Float32.div turning_f32_189 turning_f32_189) =
      Int.repr 1065353216 /\
  Z.land turning_part2_flags gameplay_translation_flag_mask = 0 /\
  0 <= turning_part2_animation_id < mario_animation_entry_count /\
  turning_part2_payload_bytes <= mario_animation_buffer_bytes.

Theorem turning_animation_source_kernel_checked :
  turning_animation_source_kernel.
Proof.
  unfold turning_animation_source_kernel.
  split; [exact turning_part2_selection_source_shape_us |].
  split; [exact turning_part2_selection_source_shape_jp |].
  split; [exact set_mario_animation_footprint_source_shape_us |].
  split; [exact set_mario_animation_footprint_source_shape_jp |].
  split; [exact load_patchable_table_source_shape_us |].
  split; [exact load_patchable_table_source_shape_jp |].
  split; [exact turning_animation_renderer_source_shape_us |].
  split; [exact turning_animation_renderer_source_shape_jp |].
  split; [exact turning_animation_holp_caveat_source_shape_us |].
  split; [exact turning_animation_holp_caveat_source_shape_jp |].
  split; [exact turning_part2_translation_multiplier_binary32_checked |].
  split; [exact turning_part2_has_no_gameplay_translation_flag |].
  unfold turning_part2_animation_id, mario_animation_entry_count,
    turning_part2_payload_bytes, mario_animation_buffer_bytes.
  lia.
Qed.
