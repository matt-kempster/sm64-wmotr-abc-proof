(** Concrete entry-time layouts and memory observations.

    This file proves two deliberately limited facts:

    - the generated VERSION_US and VERSION_JP Clight composite environments
      have the retail 32-bit layouts used by the entry audit; and
    - once the listed [Mem.load] observations hold, MarioState, Object raw
      position, and Object graphical position are equal and the advertised
      action/depth fields really are present in memory.

    It does *not* prove that a clean retail execution reaches this
    postcondition.  The final definitions state that still-pending Clight
    execution/refinement obligation without assuming it as an axiom. *)

From Coq Require Import List ZArith.
From compcert Require Import
  AST Clight Ctypes Errors Events Floats Integers Linking Memory Smallstep
  Values.
From LessThanOneAPress.Generated Require Import
  us_mario us_level_update us_graph_node
  jp_mario jp_level_update jp_graph_node.

Import ListNotations.
Local Open Scope Z_scope.

Module UM := us_mario.
Module UL := us_level_update.
Module UG := us_graph_node.
Module JM := jp_mario.
Module JL := jp_level_update.
Module JG := jp_graph_node.

(** [field_offset] expects the member list as well as the composite
    environment.  Recovering that list from [prog_types] keeps the numerical
    certificates below connected to the generated translation unit. *)
Fixpoint generated_composite_description
    (name : ident) (definitions : list composite_definition)
    : option (struct_or_union * members) :=
  match definitions with
  | [] => None
  | Composite candidate kind fields _ :: rest =>
      if Pos.eqb name candidate
      then Some (kind, fields)
      else generated_composite_description name rest
  end.

Definition generated_field_offset
    (program : Clight.program) (composite field : ident)
    : option (res (Z * bitfield)) :=
  option_map
    (fun description =>
       let '(kind, fields) := description in
       match kind with
       | Struct =>
           field_offset (prog_comp_env program) field fields
       | Union =>
           union_field_offset (prog_comp_env program) field fields
       end)
    (generated_composite_description composite (prog_types program)).

(** * Generated VERSION_US layout certificates *)

Theorem us_mario_state_layout :
  sizeof (prog_comp_env UM.prog) (Tstruct UM._MarioState noattr) = 200 /\
  generated_field_offset UM.prog UM._MarioState UM._action =
    Some (OK (12, Full)) /\
  generated_field_offset UM.prog UM._MarioState UM._actionState =
    Some (OK (24, Full)) /\
  generated_field_offset UM.prog UM._MarioState UM._actionTimer =
    Some (OK (26, Full)) /\
  generated_field_offset UM.prog UM._MarioState UM._actionArg =
    Some (OK (28, Full)) /\
  generated_field_offset UM.prog UM._MarioState UM._framesSinceA =
    Some (OK (40, Full)) /\
  generated_field_offset UM.prog UM._MarioState UM._framesSinceB =
    Some (OK (41, Full)) /\
  generated_field_offset UM.prog UM._MarioState UM._pos =
    Some (OK (60, Full)) /\
  generated_field_offset UM.prog UM._MarioState UM._vel =
    Some (OK (72, Full)) /\
  generated_field_offset UM.prog UM._MarioState UM._forwardVel =
    Some (OK (84, Full)) /\
  generated_field_offset UM.prog UM._MarioState UM._floor =
    Some (OK (104, Full)) /\
  generated_field_offset UM.prog UM._MarioState UM._floorHeight =
    Some (OK (112, Full)) /\
  generated_field_offset UM.prog UM._MarioState UM._marioObj =
    Some (OK (136, Full)) /\
  generated_field_offset UM.prog UM._MarioState UM._controller =
    Some (OK (156, Full)) /\
  generated_field_offset UM.prog UM._MarioState UM._quicksandDepth =
    Some (OK (192, Full)).
Proof. vm_compute. repeat split; reflexivity. Qed.

Theorem us_object_layout :
  sizeof (prog_comp_env UM.prog) (Tstruct UM._Object noattr) = 608 /\
  sizeof (prog_comp_env UM.prog) (Tstruct UM._GraphNodeObject noattr) = 96 /\
  generated_field_offset UM.prog UM._Object UM._header =
    Some (OK (0, Full)) /\
  generated_field_offset UM.prog UM._Object UM._rawData =
    Some (OK (136, Full)) /\
  generated_field_offset UM.prog UM._ObjectNode UM._gfx =
    Some (OK (0, Full)) /\
  generated_field_offset UM.prog UM._GraphNodeObject UM._pos =
    Some (OK (32, Full)) /\
  generated_field_offset UM.prog UM._GraphNodeObject UM._throwMatrix =
    Some (OK (80, Full)) /\
  generated_field_offset UM.prog UM.__764 UM._asF32 =
    Some (OK (0, Full)).
Proof. vm_compute. repeat split; reflexivity. Qed.

Theorem us_controller_layout :
  sizeof (prog_comp_env UM.prog) (Tstruct UM._Controller noattr) = 28 /\
  generated_field_offset UM.prog UM._Controller UM._buttonDown =
    Some (OK (16, Full)) /\
  generated_field_offset UM.prog UM._Controller UM._buttonPressed =
    Some (OK (18, Full)).
Proof. vm_compute. repeat split; reflexivity. Qed.

(** * Generated VERSION_JP layout certificates *)

Theorem jp_mario_state_layout :
  sizeof (prog_comp_env JM.prog) (Tstruct JM._MarioState noattr) = 200 /\
  generated_field_offset JM.prog JM._MarioState JM._action =
    Some (OK (12, Full)) /\
  generated_field_offset JM.prog JM._MarioState JM._actionState =
    Some (OK (24, Full)) /\
  generated_field_offset JM.prog JM._MarioState JM._actionTimer =
    Some (OK (26, Full)) /\
  generated_field_offset JM.prog JM._MarioState JM._actionArg =
    Some (OK (28, Full)) /\
  generated_field_offset JM.prog JM._MarioState JM._framesSinceA =
    Some (OK (40, Full)) /\
  generated_field_offset JM.prog JM._MarioState JM._framesSinceB =
    Some (OK (41, Full)) /\
  generated_field_offset JM.prog JM._MarioState JM._pos =
    Some (OK (60, Full)) /\
  generated_field_offset JM.prog JM._MarioState JM._vel =
    Some (OK (72, Full)) /\
  generated_field_offset JM.prog JM._MarioState JM._forwardVel =
    Some (OK (84, Full)) /\
  generated_field_offset JM.prog JM._MarioState JM._floor =
    Some (OK (104, Full)) /\
  generated_field_offset JM.prog JM._MarioState JM._floorHeight =
    Some (OK (112, Full)) /\
  generated_field_offset JM.prog JM._MarioState JM._marioObj =
    Some (OK (136, Full)) /\
  generated_field_offset JM.prog JM._MarioState JM._controller =
    Some (OK (156, Full)) /\
  generated_field_offset JM.prog JM._MarioState JM._quicksandDepth =
    Some (OK (192, Full)).
Proof. vm_compute. repeat split; reflexivity. Qed.

Theorem jp_object_layout :
  sizeof (prog_comp_env JM.prog) (Tstruct JM._Object noattr) = 608 /\
  sizeof (prog_comp_env JM.prog) (Tstruct JM._GraphNodeObject noattr) = 96 /\
  generated_field_offset JM.prog JM._Object JM._header =
    Some (OK (0, Full)) /\
  generated_field_offset JM.prog JM._Object JM._rawData =
    Some (OK (136, Full)) /\
  generated_field_offset JM.prog JM._ObjectNode JM._gfx =
    Some (OK (0, Full)) /\
  generated_field_offset JM.prog JM._GraphNodeObject JM._pos =
    Some (OK (32, Full)) /\
  generated_field_offset JM.prog JM._GraphNodeObject JM._throwMatrix =
    Some (OK (80, Full)) /\
  generated_field_offset JM.prog JM.__727 JM._asF32 =
    Some (OK (0, Full)).
Proof. vm_compute. repeat split; reflexivity. Qed.

Theorem jp_controller_layout :
  sizeof (prog_comp_env JM.prog) (Tstruct JM._Controller noattr) = 28 /\
  generated_field_offset JM.prog JM._Controller JM._buttonDown =
    Some (OK (16, Full)) /\
  generated_field_offset JM.prog JM._Controller JM._buttonPressed =
    Some (OK (18, Full)).
Proof. vm_compute. repeat split; reflexivity. Qed.

(** The preprocessor expands [oPosX/Y/Z] to [rawData.asF32[6/7/8]].
    Together with the proved [rawData] offset, these are the concrete object
    offsets 0xA0, 0xA4, and 0xA8. *)
Definition object_raw_float_offset (index : Z) : Z := 136 + 4 * index.

Theorem object_raw_position_offsets :
  object_raw_float_offset 6 = 160 /\
  object_raw_float_offset 7 = 164 /\
  object_raw_float_offset 8 = 168.
Proof. vm_compute. repeat split; reflexivity. Qed.

(** * Concrete entry-time memory postcondition *)

Definition mario_state_action_offset : Z := 12.
Definition mario_state_action_state_offset : Z := 24.
Definition mario_state_action_timer_offset : Z := 26.
Definition mario_state_action_arg_offset : Z := 28.
Definition mario_state_frames_since_a_offset : Z := 40.
Definition mario_state_frames_since_b_offset : Z := 41.
Definition mario_state_position_offset : Z := 60.
Definition mario_state_velocity_offset : Z := 72.
Definition mario_state_forward_velocity_offset : Z := 84.
Definition mario_state_object_pointer_offset : Z := 136.
Definition mario_state_controller_pointer_offset : Z := 156.
Definition mario_state_quicksand_depth_offset : Z := 192.

Definition mario_object_graphics_position_offset : Z := 32.
Definition mario_object_throw_matrix_offset : Z := 80.
Definition mario_object_raw_position_offset : Z := 160.

Definition controller_button_down_offset : Z := 16.
Definition controller_button_pressed_offset : Z := 18.

Definition airborne_entry_action : int := Int.repr 6450.
Definition positive_f32_zero : float32 := Float32.of_bits Int.zero.

Record EntryControllerSample := {
  entry_controller_button_down : int;
  entry_controller_button_pressed : int
}.

Definition load_at
    (chunk : memory_chunk) (memory : mem)
    (storage : block) (base field : Z) : option val :=
  Mem.load chunk memory storage (base + field).

(** This is a postcondition over actual CompCert memory, not a hand-written
    replacement for [init_mario_after_warp].  The three coordinate samples are
    binary32 values and the action/depth values are fixed to the values written
    by the audited entry path. *)
Record RetailEntryMemoryPostcondition
    (memory : mem)
    (mario_state_block mario_object_block controller_block : block)
    (mario_state_base mario_object_base controller_base : Z)
    (x y z : float32)
    (controller_sample : EntryControllerSample) : Prop := {
  entry_state_object_pointer :
    load_at Mptr memory mario_state_block mario_state_base
      mario_state_object_pointer_offset =
    Some (Vptr mario_object_block (Ptrofs.repr mario_object_base));
  entry_state_controller_pointer :
    load_at Mptr memory mario_state_block mario_state_base
      mario_state_controller_pointer_offset =
    Some (Vptr controller_block (Ptrofs.repr controller_base));

  entry_state_x :
    load_at Mfloat32 memory mario_state_block mario_state_base
      mario_state_position_offset = Some (Vsingle x);
  entry_state_y :
    load_at Mfloat32 memory mario_state_block mario_state_base
      (mario_state_position_offset + 4) = Some (Vsingle y);
  entry_state_z :
    load_at Mfloat32 memory mario_state_block mario_state_base
      (mario_state_position_offset + 8) = Some (Vsingle z);

  entry_object_raw_x :
    load_at Mfloat32 memory mario_object_block mario_object_base
      mario_object_raw_position_offset = Some (Vsingle x);
  entry_object_raw_y :
    load_at Mfloat32 memory mario_object_block mario_object_base
      (mario_object_raw_position_offset + 4) = Some (Vsingle y);
  entry_object_raw_z :
    load_at Mfloat32 memory mario_object_block mario_object_base
      (mario_object_raw_position_offset + 8) = Some (Vsingle z);

  entry_object_graphics_x :
    load_at Mfloat32 memory mario_object_block mario_object_base
      mario_object_graphics_position_offset = Some (Vsingle x);
  entry_object_graphics_y :
    load_at Mfloat32 memory mario_object_block mario_object_base
      (mario_object_graphics_position_offset + 4) = Some (Vsingle y);
  entry_object_graphics_z :
    load_at Mfloat32 memory mario_object_block mario_object_base
      (mario_object_graphics_position_offset + 8) = Some (Vsingle z);
  entry_object_throw_matrix_null :
    load_at Mptr memory mario_object_block mario_object_base
      mario_object_throw_matrix_offset = Some (Vint Int.zero);

  entry_velocity_x_zero :
    load_at Mfloat32 memory mario_state_block mario_state_base
      mario_state_velocity_offset = Some (Vsingle positive_f32_zero);
  entry_velocity_y_zero :
    load_at Mfloat32 memory mario_state_block mario_state_base
      (mario_state_velocity_offset + 4) = Some (Vsingle positive_f32_zero);
  entry_velocity_z_zero :
    load_at Mfloat32 memory mario_state_block mario_state_base
      (mario_state_velocity_offset + 8) = Some (Vsingle positive_f32_zero);
  entry_forward_velocity_zero :
    load_at Mfloat32 memory mario_state_block mario_state_base
      mario_state_forward_velocity_offset = Some (Vsingle positive_f32_zero);

  entry_action_value :
    load_at Mint32 memory mario_state_block mario_state_base
      mario_state_action_offset = Some (Vint airborne_entry_action);
  entry_action_state_zero :
    load_at Mint16unsigned memory mario_state_block mario_state_base
      mario_state_action_state_offset = Some (Vint Int.zero);
  entry_action_timer_zero :
    load_at Mint16unsigned memory mario_state_block mario_state_base
      mario_state_action_timer_offset = Some (Vint Int.zero);
  entry_action_arg_zero :
    load_at Mint32 memory mario_state_block mario_state_base
      mario_state_action_arg_offset = Some (Vint Int.zero);
  entry_frames_since_a_value :
    load_at Mint8unsigned memory mario_state_block mario_state_base
      mario_state_frames_since_a_offset = Some (Vint (Int.repr 255));
  entry_frames_since_b_value :
    load_at Mint8unsigned memory mario_state_block mario_state_base
      mario_state_frames_since_b_offset = Some (Vint (Int.repr 255));
  entry_quicksand_depth_zero :
    load_at Mfloat32 memory mario_state_block mario_state_base
      mario_state_quicksand_depth_offset =
    Some (Vsingle positive_f32_zero);

  entry_controller_down_value :
    load_at Mint16unsigned memory controller_block controller_base
      controller_button_down_offset =
    Some (Vint (entry_controller_button_down controller_sample));
  entry_controller_pressed_value :
    load_at Mint16unsigned memory controller_block controller_base
      controller_button_pressed_offset =
    Some (Vint (entry_controller_button_pressed controller_sample))
}.

Record RetailEntryMemoryProjection
    (memory : mem)
    (mario_state_block mario_object_block : block)
    (mario_state_base mario_object_base : Z) : Prop := {
  projected_state_raw_x_equal :
    load_at Mfloat32 memory mario_state_block mario_state_base
      mario_state_position_offset =
    load_at Mfloat32 memory mario_object_block mario_object_base
      mario_object_raw_position_offset;
  projected_state_raw_y_equal :
    load_at Mfloat32 memory mario_state_block mario_state_base
      (mario_state_position_offset + 4) =
    load_at Mfloat32 memory mario_object_block mario_object_base
      (mario_object_raw_position_offset + 4);
  projected_state_raw_z_equal :
    load_at Mfloat32 memory mario_state_block mario_state_base
      (mario_state_position_offset + 8) =
    load_at Mfloat32 memory mario_object_block mario_object_base
      (mario_object_raw_position_offset + 8);
  projected_state_graphics_x_equal :
    load_at Mfloat32 memory mario_state_block mario_state_base
      mario_state_position_offset =
    load_at Mfloat32 memory mario_object_block mario_object_base
      mario_object_graphics_position_offset;
  projected_state_graphics_y_equal :
    load_at Mfloat32 memory mario_state_block mario_state_base
      (mario_state_position_offset + 4) =
    load_at Mfloat32 memory mario_object_block mario_object_base
      (mario_object_graphics_position_offset + 4);
  projected_state_graphics_z_equal :
    load_at Mfloat32 memory mario_state_block mario_state_base
      (mario_state_position_offset + 8) =
    load_at Mfloat32 memory mario_object_block mario_object_base
      (mario_object_graphics_position_offset + 8);
  projected_action_value :
    load_at Mint32 memory mario_state_block mario_state_base
      mario_state_action_offset = Some (Vint airborne_entry_action);
  projected_action_state_zero :
    load_at Mint16unsigned memory mario_state_block mario_state_base
      mario_state_action_state_offset = Some (Vint Int.zero);
  projected_action_timer_zero :
    load_at Mint16unsigned memory mario_state_block mario_state_base
      mario_state_action_timer_offset = Some (Vint Int.zero);
  projected_action_arg_zero :
    load_at Mint32 memory mario_state_block mario_state_base
      mario_state_action_arg_offset = Some (Vint Int.zero);
  projected_frames_since_a_value :
    load_at Mint8unsigned memory mario_state_block mario_state_base
      mario_state_frames_since_a_offset = Some (Vint (Int.repr 255));
  projected_frames_since_b_value :
    load_at Mint8unsigned memory mario_state_block mario_state_base
      mario_state_frames_since_b_offset = Some (Vint (Int.repr 255));
  projected_throw_matrix_null :
    load_at Mptr memory mario_object_block mario_object_base
      mario_object_throw_matrix_offset = Some (Vint Int.zero);
  projected_quicksand_depth_zero :
    load_at Mfloat32 memory mario_state_block mario_state_base
      mario_state_quicksand_depth_offset =
    Some (Vsingle positive_f32_zero)
}.

Theorem retail_entry_postcondition_projects :
  forall memory mario_state_block mario_object_block controller_block
    mario_state_base mario_object_base controller_base x y z controller_sample,
    RetailEntryMemoryPostcondition
      memory mario_state_block mario_object_block controller_block
      mario_state_base mario_object_base controller_base
      x y z controller_sample ->
    RetailEntryMemoryProjection
      memory mario_state_block mario_object_block
      mario_state_base mario_object_base.
Proof.
  intros memory mario_state_block mario_object_block controller_block
    mario_state_base mario_object_base controller_base
    x y z controller_sample post.
  destruct post.
  constructor; try assumption; congruence.
Qed.

(** * Pending retail execution/refinement boundary

    These are definitions of the concrete propositions that later work must
    prove.  Nothing below asserts that either proposition is inhabited.  In
    particular, the layout and projection theorem above do not establish
    clean-entry reachability, controller scheduling, linker completeness, or
    the call's required global-memory precondition. *)

Definition USArea2EntryLiveMemoryRefinementObligation
    (linked_program : Clight.program)
    (continuation : Clight.cont)
    (memory_before memory_after : mem)
    (mario_state_block mario_object_block controller_block : block)
    (mario_state_base mario_object_base controller_base : Z)
    (x y z : float32)
    (controller_sample : EntryControllerSample) : Prop :=
  linkorder UL.prog linked_program /\
  linkorder UM.prog linked_program /\
  linkorder UG.prog linked_program /\
  exists trace,
    @Smallstep.star _ _ Clight.step2
      (Clight.globalenv linked_program)
      (Clight.Callstate
        (Ctypes.Internal UL.f_init_mario_after_warp)
        [] continuation memory_before)
      trace
      (Clight.Returnstate Vundef continuation memory_after) /\
    RetailEntryMemoryPostcondition
      memory_after mario_state_block mario_object_block controller_block
      mario_state_base mario_object_base controller_base
      x y z controller_sample.

Definition JPArea2EntryLiveMemoryRefinementObligation
    (linked_program : Clight.program)
    (continuation : Clight.cont)
    (memory_before memory_after : mem)
    (mario_state_block mario_object_block controller_block : block)
    (mario_state_base mario_object_base controller_base : Z)
    (x y z : float32)
    (controller_sample : EntryControllerSample) : Prop :=
  linkorder JL.prog linked_program /\
  linkorder JM.prog linked_program /\
  linkorder JG.prog linked_program /\
  exists trace,
    @Smallstep.star _ _ Clight.step2
      (Clight.globalenv linked_program)
      (Clight.Callstate
        (Ctypes.Internal JL.f_init_mario_after_warp)
        [] continuation memory_before)
      trace
      (Clight.Returnstate Vundef continuation memory_after) /\
    RetailEntryMemoryPostcondition
      memory_after mario_state_block mario_object_block controller_block
      mario_state_base mario_object_base controller_base
      x y z controller_sample.
