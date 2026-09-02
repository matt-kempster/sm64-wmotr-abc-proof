(** Rank 15: a memory-faithful selected-Clight projection boundary.

    The former bridge in [EyerokRank15DynamicSupport] asked for one complete
    hand-envelope transition after every Clight small step.  The generated C
    does not have that granularity: [cur_obj_move_y_and_get_water_level]
    stores velocity, may store its clamp, and only later stores position.
    This file authenticates that order in both generated regions and replaces
    the bridge with nonempty connected chunks of actual [Clight.step2] steps.

    A projected endpoint is not an arbitrary function result.  It contains
    successful [Mem.load] observations of both concrete object-pool slots,
    including pose, velocity, gravity, action, floor pointer, behavior, active
    flags, and list links.  It also reads the selected surface's owner, follows
    a real path from the SURFACE-list head, and checks the left-before-right
    link while both hands are live.  Thus a bad pose, owner, list link, write,
    or slot reuse makes the projection fail at a particular Clight state.

    The theorem at the end is deliberately conditional on constructing the
    chunks from an accepted live start.  It is nevertheless strictly stronger
    than the old arbitrary projector: the observations are determinate from
    memory and the two slots are proved byte-disjoint.  The remaining missing
    work is now the reached-chunk classification, especially the unresolved
    sound/spawner calls; it is not hidden inside an unconstrained projection. *)

From Coq Require Import Bool Lia List ZArith.
From compcert Require Import AST Clight Events Floats Globalenvs Integers
  Memory Smallstep Values.
From LessThanOneAPress.Proofs Require Import
  ASTFacts ClightFacts ClightProjectionChronology EntryMemory
  EyerokRank15DynamicSupport FirstTargetRefinement GameTypes
  OrdinaryArea1EntryMemory RetailExternalFrames
  SelectedClightTarget.

Import ListNotations.
Local Open Scope Z_scope.

(** * Generated ordering receipts *)

Fixpoint rank15_signed_int_constant (expression : expr) : option Z :=
  match expression with
  | Econst_int value _ => Some (Int.signed value)
  | Eunop Oneg inner _ =>
      match rank15_signed_int_constant inner with
      | Some value => Some (- value)
      | None => None
      end
  | Ecast inner _ => rank15_signed_int_constant inner
  | _ => None
  end.

Fixpoint rank15_call_int_argument_s
    (callee : ident) (argument : nat) (statement : statement) :
    list (option Z) :=
  match statement with
  | Scall _ (Evar called _) arguments =>
      if Pos.eqb called callee then
        match nth_error arguments argument with
        | Some expression => [rank15_signed_int_constant expression]
        | None => [None]
        end
      else []
  | Ssequence first second | Sloop first second =>
      rank15_call_int_argument_s callee argument first ++
      rank15_call_int_argument_s callee argument second
  | Sifthenelse _ yes no =>
      rank15_call_int_argument_s callee argument yes ++
      rank15_call_int_argument_s callee argument no
  | Sswitch _ cases =>
      rank15_call_int_argument_ls callee argument cases
  | Slabel _ body => rank15_call_int_argument_s callee argument body
  | _ => []
  end
with rank15_call_int_argument_ls
    (callee : ident) (argument : nat) (cases : labeled_statements) :
    list (option Z) :=
  match cases with
  | LSnil => []
  | LScons _ body rest =>
      rank15_call_int_argument_s callee argument body ++
      rank15_call_int_argument_ls callee argument rest
  end.

Fixpoint rank15_vertical_store_order_s
    (array_field : ident) (statement : statement) : list Z :=
  match statement with
  | Sassign lhs _ =>
      if expression_is_array_slot array_field 10 lhs then [10]
      else if expression_is_array_slot array_field 7 lhs then [7]
      else []
  | Ssequence first second | Sloop first second =>
      rank15_vertical_store_order_s array_field first ++
      rank15_vertical_store_order_s array_field second
  | Sifthenelse _ yes no =>
      rank15_vertical_store_order_s array_field yes ++
      rank15_vertical_store_order_s array_field no
  | Sswitch _ cases =>
      rank15_vertical_store_order_ls array_field cases
  | Slabel _ body => rank15_vertical_store_order_s array_field body
  | _ => []
  end
with rank15_vertical_store_order_ls
    (array_field : ident) (cases : labeled_statements) : list Z :=
  match cases with
  | LSnil => []
  | LScons _ body rest =>
      rank15_vertical_store_order_s array_field body ++
      rank15_vertical_store_order_ls array_field rest
  end.

Definition EyerokRank15LiveOrderingReceipt : Prop :=
  rank15_call_int_argument_s UEye._eyerok_spawn_hand 0
      (fn_body UEye.f_eyerok_boss_act_sleep) = [Some (-1); Some 1] /\
  rank15_call_int_argument_s JEye._eyerok_spawn_hand 0
      (fn_body JEye.f_eyerok_boss_act_sleep) = [Some (-1); Some 1] /\
  rank15_call_int_argument_s UEye._eyerok_spawn_hand 1
      (fn_body UEye.f_eyerok_boss_act_sleep) = [Some 88; Some 89] /\
  rank15_call_int_argument_s JEye._eyerok_spawn_hand 1
      (fn_body JEye.f_eyerok_boss_act_sleep) = [Some 88; Some 89] /\
  rank15_vertical_store_order_s UOH._asF32
      (fn_body UOH.f_cur_obj_move_y_and_get_water_level) = [10; 10; 7] /\
  rank15_vertical_store_order_s JOH._asF32
      (fn_body JOH.f_cur_obj_move_y_and_get_water_level) = [10; 10; 7].

Theorem eyerok_rank15_live_ordering_receipt_checked :
  EyerokRank15LiveOrderingReceipt.
Proof.
  unfold EyerokRank15LiveOrderingReceipt.
  vm_compute. repeat split; reflexivity.
Qed.

(** These calls are not speculative names: each is present in the generated
    hand/movement source and remains an unresolved external declaration in
    the owning generated unit.  Reachability and an exact effect still have
    to be proved at the selected whole-program callsite. *)
Definition EyerokRank15OutsideCallSyntaxReceipt : Prop :=
  calls_ident_s UEye._cur_obj_play_sound_2
      (fn_body UEye.f_eyerok_boss_act_sleep) = true /\
  calls_ident_s UEye._create_sound_spawner
      (fn_body UEye.f_eyerok_hand_act_die) = true /\
  calls_ident_s UOH._sqrtf (fn_body UOH.f_cur_obj_move_standard) = true /\
  calls_ident_s JEye._cur_obj_play_sound_2
      (fn_body JEye.f_eyerok_boss_act_sleep) = true /\
  calls_ident_s JEye._create_sound_spawner
      (fn_body JEye.f_eyerok_hand_act_die) = true /\
  calls_ident_s JOH._sqrtf (fn_body JOH.f_cur_obj_move_standard) = true /\
  direct_external_call UEye.prog UEye._cur_obj_play_sound_2 = true /\
  direct_external_call UEye.prog UEye._create_sound_spawner = true /\
  direct_external_call UOH.prog UOH._sqrtf = true /\
  direct_external_call JEye.prog JEye._cur_obj_play_sound_2 = true /\
  direct_external_call JEye.prog JEye._create_sound_spawner = true /\
  direct_external_call JOH.prog JOH._sqrtf = true.

Theorem eyerok_rank15_outside_call_syntax_receipt_checked :
  EyerokRank15OutsideCallSyntaxReceipt.
Proof.
  unfold EyerokRank15OutsideCallSyntaxReceipt, direct_external_call.
  vm_compute. repeat split; reflexivity.
Qed.

(** * Concrete object/list binding *)

Definition rank15_object_pool_ident (version : GameVersion) : ident :=
  match version with VersionUS => UOL._gObjectPool | VersionJP => JOL._gObjectPool end.

Definition rank15_object_list_array_ident (version : GameVersion) : ident :=
  match version with
  | VersionUS => UOL._gObjectListArray
  | VersionJP => JOL._gObjectListArray
  end.

Definition rank15_object_lists_ident (version : GameVersion) : ident :=
  match version with VersionUS => UOL._gObjectLists | VersionJP => JOL._gObjectLists end.

Definition rank15_hand_behavior_ident (version : GameVersion) : ident :=
  match version with VersionUS => UBD._bhvEyerokHand | VersionJP => JBD._bhvEyerokHand end.

Definition rank15_surface_list_index : Z := 9.
Definition rank15_surface_owner_offset : Z := 44.
Definition rank15_position_x_offset : Z := object_raw_float_offset 6.
Definition rank15_position_y_offset : Z := object_raw_float_offset 7.
Definition rank15_position_z_offset : Z := object_raw_float_offset 8.
Definition rank15_velocity_y_offset : Z := object_raw_float_offset 10.
Definition rank15_gravity_offset : Z := object_raw_float_offset 23.
Definition rank15_floor_height_offset : Z := object_raw_float_offset 24.
Definition rank15_action_offset : Z := object_raw_float_offset 49.
Definition rank15_floor_pointer_offset : Z := object_raw_float_offset 78.

Definition EyerokRank15ObservedLayoutReceipt : Prop :=
  rank15_position_x_offset = 160 /\
  rank15_position_y_offset = 164 /\
  rank15_position_z_offset = 168 /\
  rank15_velocity_y_offset = 176 /\
  rank15_gravity_offset = 228 /\
  rank15_floor_height_offset = 232 /\
  rank15_action_offset = 332 /\
  rank15_floor_pointer_offset = 448 /\
  rank15_surface_owner_offset = 44 /\
  rank15_surface_list_index * object_list_node_size = 936.

Theorem eyerok_rank15_observed_layout_receipt_checked :
  EyerokRank15ObservedLayoutReceipt.
Proof.
  unfold EyerokRank15ObservedLayoutReceipt,
    rank15_position_x_offset, rank15_position_y_offset,
    rank15_position_z_offset, rank15_velocity_y_offset,
    rank15_gravity_offset, rank15_floor_height_offset,
    rank15_action_offset, rank15_floor_pointer_offset,
    rank15_surface_owner_offset, rank15_surface_list_index,
    object_raw_float_offset, object_list_node_size.
  repeat split; reflexivity.
Qed.

Record Rank15LiveBinding : Type := {
  rank15_binding_version : GameVersion;
  rank15_binding_pool_block : block;
  rank15_binding_list_array_block : block;
  rank15_binding_lists_cell_block : block;
  rank15_binding_behavior_block : block;
  rank15_binding_earlier_slot : nat;
  rank15_binding_later_slot : nat;
  rank15_binding_earlier_valid :
    (rank15_binding_earlier_slot < object_pool_capacity)%nat;
  rank15_binding_later_valid :
    (rank15_binding_later_slot < object_pool_capacity)%nat;
  rank15_binding_slots_distinct :
    rank15_binding_earlier_slot <> rank15_binding_later_slot;
  rank15_binding_pool_symbol :
    Genv.find_symbol
      (Clight.globalenv (selected_clight_target rank15_binding_version))
      (rank15_object_pool_ident rank15_binding_version) =
      Some rank15_binding_pool_block;
  rank15_binding_list_array_symbol :
    Genv.find_symbol
      (Clight.globalenv (selected_clight_target rank15_binding_version))
      (rank15_object_list_array_ident rank15_binding_version) =
      Some rank15_binding_list_array_block;
  rank15_binding_lists_cell_symbol :
    Genv.find_symbol
      (Clight.globalenv (selected_clight_target rank15_binding_version))
      (rank15_object_lists_ident rank15_binding_version) =
      Some rank15_binding_lists_cell_block;
  rank15_binding_behavior_symbol :
    Genv.find_symbol
      (Clight.globalenv (selected_clight_target rank15_binding_version))
      (rank15_hand_behavior_ident rank15_binding_version) =
      Some rank15_binding_behavior_block
}.

Definition rank15_slot_pointer
    (binding : Rank15LiveBinding) (slot : nat) : val :=
  Vptr (rank15_binding_pool_block binding)
    (Ptrofs.repr (object_slot_offset slot)).

Definition rank15_surface_list_head_offset : Z :=
  rank15_surface_list_index * object_list_node_size.

(** A finite proof path from the live SURFACE-list head to a pool slot.  The
    inductive path cannot be supplied by merely choosing two detached objects
    whose [next]/[prev] fields happen to point at one another. *)
Inductive Rank15SurfaceListContains
    (memory : Mem.mem) (binding : Rank15LiveBinding) : nat -> Prop :=
| rank15_surface_list_first : forall slot,
    (slot < object_pool_capacity)%nat ->
    Mem.load Mptr memory (rank15_binding_list_array_block binding)
      (rank15_surface_list_head_offset + object_next_offset) =
      Some (rank15_slot_pointer binding slot) ->
    Rank15SurfaceListContains memory binding slot
| rank15_surface_list_next : forall previous slot,
    Rank15SurfaceListContains memory binding previous ->
    (slot < object_pool_capacity)%nat ->
    Mem.load Mptr memory (rank15_binding_pool_block binding)
      (object_slot_offset previous + object_next_offset) =
      Some (rank15_slot_pointer binding slot) ->
    Rank15SurfaceListContains memory binding slot.

(** * Exact memory observations *)

Record Rank15HandCells : Type := {
  rank15_cells_active_flags : int;
  rank15_cells_next : val;
  rank15_cells_previous : val;
  rank15_cells_behavior : val;
  rank15_cells_pos_x : float32;
  rank15_cells_pos_y : float32;
  rank15_cells_pos_z : float32;
  rank15_cells_vel_y : float32;
  rank15_cells_gravity : float32;
  rank15_cells_floor_height : float32;
  rank15_cells_action : int;
  rank15_cells_floor : val;
  rank15_cells_floor_owner : option val
}.

Record Rank15HandCellLoads
    (memory : Mem.mem) (binding : Rank15LiveBinding)
    (slot : nat) (cells : Rank15HandCells) : Prop := {
  rank15_load_active_flags :
    Mem.load Mint16signed memory (rank15_binding_pool_block binding)
      (object_slot_offset slot + object_active_flags_offset) =
      Some (Vint (rank15_cells_active_flags cells));
  rank15_load_next :
    Mem.load Mptr memory (rank15_binding_pool_block binding)
      (object_slot_offset slot + object_next_offset) =
      Some (rank15_cells_next cells);
  rank15_load_previous :
    Mem.load Mptr memory (rank15_binding_pool_block binding)
      (object_slot_offset slot + object_previous_offset) =
      Some (rank15_cells_previous cells);
  rank15_load_behavior :
    Mem.load Mptr memory (rank15_binding_pool_block binding)
      (object_slot_offset slot + object_behavior_offset) =
      Some (rank15_cells_behavior cells);
  rank15_load_pos_x :
    Mem.load Mfloat32 memory (rank15_binding_pool_block binding)
      (object_slot_offset slot + rank15_position_x_offset) =
      Some (Vsingle (rank15_cells_pos_x cells));
  rank15_load_pos_y :
    Mem.load Mfloat32 memory (rank15_binding_pool_block binding)
      (object_slot_offset slot + rank15_position_y_offset) =
      Some (Vsingle (rank15_cells_pos_y cells));
  rank15_load_pos_z :
    Mem.load Mfloat32 memory (rank15_binding_pool_block binding)
      (object_slot_offset slot + rank15_position_z_offset) =
      Some (Vsingle (rank15_cells_pos_z cells));
  rank15_load_vel_y :
    Mem.load Mfloat32 memory (rank15_binding_pool_block binding)
      (object_slot_offset slot + rank15_velocity_y_offset) =
      Some (Vsingle (rank15_cells_vel_y cells));
  rank15_load_gravity :
    Mem.load Mfloat32 memory (rank15_binding_pool_block binding)
      (object_slot_offset slot + rank15_gravity_offset) =
      Some (Vsingle (rank15_cells_gravity cells));
  rank15_load_floor_height :
    Mem.load Mfloat32 memory (rank15_binding_pool_block binding)
      (object_slot_offset slot + rank15_floor_height_offset) =
      Some (Vsingle (rank15_cells_floor_height cells));
  rank15_load_action :
    Mem.load Mint32 memory (rank15_binding_pool_block binding)
      (object_slot_offset slot + rank15_action_offset) =
      Some (Vint (rank15_cells_action cells));
  rank15_load_floor :
    Mem.load Mptr memory (rank15_binding_pool_block binding)
      (object_slot_offset slot + rank15_floor_pointer_offset) =
      Some (rank15_cells_floor cells)
}.

Definition Rank15FloorOwnerLoad
    (memory : Mem.mem) (floor : val) (owner : option val) : Prop :=
  match floor with
  | Vptr surface_block surface_offset =>
      exists owner_value,
        owner = Some owner_value /\
        Mem.load Mptr memory surface_block
          (Ptrofs.unsigned
            (Ptrofs.add surface_offset
              (Ptrofs.repr rank15_surface_owner_offset))) = Some owner_value
  | _ => floor = Vnullptr /\ owner = None
  end.

Definition rank15_float_upper_bound (value : float32) (bound : Z) : Prop :=
  Int.min_signed <= bound <= Int.max_signed /\
  Float32.cmp Cle value (Float32.of_int (Int.repr bound)) = true.

(** The envelope uses mathematical integers.  Merely converting an arbitrary
    negative envelope with [Int.repr] can turn it into a positive ceiling.
    Range validity is part of the live projection, not an implicit promise. *)
Lemma rank15_projected_height_bound_cannot_wrap : forall value bound,
  rank15_float_upper_bound value bound ->
  Int.signed (Int.repr bound) = bound.
Proof.
  intros value bound [Hrange _]. apply Int.signed_repr. exact Hrange.
Qed.

Definition rank15_wrapped_height_bound : Z := 2000 - Int.modulus.

Definition Rank15HeightWrapRegression : Prop :=
  rank15_wrapped_height_bound < 0 /\
  rank15_area2_floor_query_min < 2000 /\
  Float32.cmp Cle (Float32.of_int (Int.repr 2000))
    (Float32.of_int (Int.repr rank15_wrapped_height_bound)) = true /\
  ~ rank15_float_upper_bound (Float32.of_int (Int.repr 2000))
      rank15_wrapped_height_bound.

Theorem rank15_height_wrap_regression_checked : Rank15HeightWrapRegression.
Proof. vm_compute. intuition discriminate. Qed.

Definition EyerokRank15HeightEncodingBoundary : Prop :=
  (forall value bound,
    rank15_float_upper_bound value bound ->
    Int.signed (Int.repr bound) = bound) /\
  Rank15HeightWrapRegression.

Theorem eyerok_rank15_height_encoding_boundary_checked :
  EyerokRank15HeightEncodingBoundary.
Proof.
  exact (conj rank15_projected_height_bound_cannot_wrap
    rank15_height_wrap_regression_checked).
Qed.

Definition rank15_hand_mode_matches_active
    (mode : Rank15HandEnvelopeMode) (active : int) : Prop :=
  match mode with
  | Rank15Deleted => active = Int.zero
  | Rank15Controlled | Rank15Ballistic => active <> Int.zero
  end.

Definition rank15_hand_identity_and_membership
    (memory : Mem.mem) (binding : Rank15LiveBinding) (slot : nat)
    (hand : Rank15HandEnvelope) (cells : Rank15HandCells) : Prop :=
  rank15_cells_behavior cells =
    Vptr (rank15_binding_behavior_block binding) (Ptrofs.repr 0) /\
  rank15_hand_mode_matches_active
    (rank15_hand_mode hand) (rank15_cells_active_flags cells) /\
  (rank15_hand_mode hand <> Rank15Deleted ->
    Rank15SurfaceListContains memory binding slot).

Definition rank15_pair_list_order
    (binding : Rank15LiveBinding) (pair : Rank15HandPair)
    (earlier later : Rank15HandCells) : Prop :=
  rank15_hand_mode (rank15_earlier_hand pair) <> Rank15Deleted ->
  rank15_hand_mode (rank15_later_hand pair) <> Rank15Deleted ->
  rank15_cells_next earlier =
      rank15_slot_pointer binding (rank15_binding_later_slot binding) /\
  rank15_cells_previous later =
      rank15_slot_pointer binding (rank15_binding_earlier_slot binding).

Inductive Rank15EarlierFloorClassified
    (cells : Rank15HandCells) : Prop :=
| rank15_earlier_no_floor :
    rank15_cells_floor_owner cells = None ->
    Rank15EarlierFloorClassified cells
| rank15_earlier_static_floor :
    rank15_cells_floor_owner cells = Some Vnullptr ->
    rank15_float_upper_bound (rank15_cells_floor_height cells)
      rank15_arena_floor_y_cap ->
    Rank15EarlierFloorClassified cells.

Inductive Rank15LaterFloorClassified
    (binding : Rank15LiveBinding) (pair : Rank15HandPair)
    (cells : Rank15HandCells) : Prop :=
| rank15_later_no_floor :
    rank15_cells_floor_owner cells = None ->
    Rank15LaterFloorClassified binding pair cells
| rank15_later_static_floor :
    rank15_cells_floor_owner cells = Some Vnullptr ->
    rank15_float_upper_bound (rank15_cells_floor_height cells)
      rank15_area3_floor_y_cap ->
    Rank15LaterFloorClassified binding pair cells
| rank15_later_earlier_hand_floor :
    rank15_cells_floor_owner cells =
      Some (rank15_slot_pointer binding
        (rank15_binding_earlier_slot binding)) ->
    rank15_float_upper_bound (rank15_cells_floor_height cells)
      (rank15_hand_y (rank15_earlier_hand pair) +
        rank15_hand_surface_offset_cap) ->
    Rank15LaterFloorClassified binding pair cells.

Record Rank15MemoryFaithfulPairProjection
    (state : Clight.state) (binding : Rank15LiveBinding)
    (pair : Rank15HandPair) (earlier later : Rank15HandCells) : Prop := {
  rank15_projection_lists_pointer_live :
    Mem.load Mptr (clight_state_memory state)
      (rank15_binding_lists_cell_block binding) 0 =
      Some (Vptr (rank15_binding_list_array_block binding) (Ptrofs.repr 0));
  rank15_projection_earlier_loads :
    Rank15HandCellLoads (clight_state_memory state) binding
      (rank15_binding_earlier_slot binding) earlier;
  rank15_projection_later_loads :
    Rank15HandCellLoads (clight_state_memory state) binding
      (rank15_binding_later_slot binding) later;
  rank15_projection_earlier_floor_owner_load :
    Rank15FloorOwnerLoad (clight_state_memory state)
      (rank15_cells_floor earlier) (rank15_cells_floor_owner earlier);
  rank15_projection_later_floor_owner_load :
    Rank15FloorOwnerLoad (clight_state_memory state)
      (rank15_cells_floor later) (rank15_cells_floor_owner later);
  rank15_projection_earlier_identity :
    rank15_hand_identity_and_membership (clight_state_memory state) binding
      (rank15_binding_earlier_slot binding)
      (rank15_earlier_hand pair) earlier;
  rank15_projection_later_identity :
    rank15_hand_identity_and_membership (clight_state_memory state) binding
      (rank15_binding_later_slot binding)
      (rank15_later_hand pair) later;
  rank15_projection_list_order :
    rank15_pair_list_order binding pair earlier later;
  rank15_projection_earlier_y_bound :
    rank15_float_upper_bound (rank15_cells_pos_y earlier)
      (rank15_hand_y (rank15_earlier_hand pair));
  rank15_projection_later_y_bound :
    rank15_float_upper_bound (rank15_cells_pos_y later)
      (rank15_hand_y (rank15_later_hand pair));
  rank15_projection_earlier_floor :
    Rank15EarlierFloorClassified earlier;
  rank15_projection_later_floor :
    Rank15LaterFloorClassified binding pair later
}.

(** The selected surface owner is determinate once the floor pointer and
    memory are fixed. *)
Lemma rank15_floor_owner_load_is_determinate :
  forall memory floor first second,
    Rank15FloorOwnerLoad memory floor first ->
    Rank15FloorOwnerLoad memory floor second ->
    first = second.
Proof.
  intros memory floor first second Hfirst Hsecond.
  destruct floor; cbn in Hfirst, Hsecond;
    try (destruct Hfirst as [_ Hfirst];
         destruct Hsecond as [_ Hsecond]; congruence).
  destruct Hfirst as [first_owner [Hfirst_owner Hfirst_load]].
  destruct Hsecond as [second_owner [Hsecond_owner Hsecond_load]].
  subst first second. congruence.
Qed.

(** The raw observation is a function of memory, rather than a free label. *)
Lemma rank15_hand_cell_loads_are_determinate :
  forall memory binding slot first second,
    Rank15HandCellLoads memory binding slot first ->
    Rank15HandCellLoads memory binding slot second ->
    Rank15FloorOwnerLoad memory
      (rank15_cells_floor first) (rank15_cells_floor_owner first) ->
    Rank15FloorOwnerLoad memory
      (rank15_cells_floor second) (rank15_cells_floor_owner second) ->
    first = second.
Proof.
  intros memory binding slot
    [a1 n1 p1 b1 x1 y1 z1 vy1 g1 fh1 ac1 f1 fo1]
    [a2 n2 p2 b2 x2 y2 z2 vy2 g2 fh2 ac2 f2 fo2]
    Hfirst Hsecond Howner1 Howner2.
  destruct Hfirst as
    [Ha1 Hn1 Hp1 Hb1 Hx1 Hy1 Hz1 Hvy1 Hg1 Hfh1 Hac1 Hf1].
  destruct Hsecond as
    [Ha2 Hn2 Hp2 Hb2 Hx2 Hy2 Hz2 Hvy2 Hg2 Hfh2 Hac2 Hf2].
  cbn in *.
  assert (a1 = a2) by congruence.
  assert (n1 = n2) by congruence.
  assert (p1 = p2) by congruence.
  assert (b1 = b2) by congruence.
  assert (x1 = x2) by congruence.
  assert (y1 = y2) by congruence.
  assert (z1 = z2) by congruence.
  assert (vy1 = vy2) by congruence.
  assert (g1 = g2) by congruence.
  assert (fh1 = fh2) by congruence.
  assert (ac1 = ac2) by congruence.
  assert (f1 = f2) by congruence.
  subst.
  assert (fo1 = fo2) by
    (eapply rank15_floor_owner_load_is_determinate; eauto).
  now subst.
Qed.

Definition rank15_observed_object_offsets : list Z :=
  [object_next_offset; object_previous_offset; object_active_flags_offset;
   rank15_position_x_offset; rank15_position_y_offset;
   rank15_position_z_offset; rank15_velocity_y_offset;
   rank15_gravity_offset; rank15_floor_height_offset; rank15_action_offset;
   rank15_floor_pointer_offset; object_behavior_offset].

Lemma rank15_observed_object_offset_is_in_bounds : forall offset,
  In offset rank15_observed_object_offsets -> 0 <= offset < object_size.
Proof.
  intros offset Hoffset.
  unfold rank15_observed_object_offsets in Hoffset.
  repeat (destruct Hoffset as [Hoffset | Hoffset];
    [subst offset; unfold object_next_offset, object_previous_offset,
       object_active_flags_offset, rank15_position_x_offset,
       rank15_position_y_offset, rank15_position_z_offset,
       rank15_velocity_y_offset, rank15_gravity_offset,
       rank15_floor_height_offset, rank15_action_offset,
       rank15_floor_pointer_offset, object_behavior_offset,
       object_raw_float_offset, object_size; lia |]).
  contradiction.
Qed.

Theorem rank15_bound_slots_observed_cells_do_not_alias :
  forall binding earlier_offset later_offset,
    In earlier_offset rank15_observed_object_offsets ->
    In later_offset rank15_observed_object_offsets ->
    object_slot_offset (rank15_binding_earlier_slot binding) + earlier_offset <>
    object_slot_offset (rank15_binding_later_slot binding) + later_offset.
Proof.
  intros binding earlier_offset later_offset Hearlier Hlater.
  eapply distinct_object_slot_in_bounds_offsets_are_distinct.
  - exact (rank15_binding_slots_distinct binding).
  - now apply rank15_observed_object_offset_is_in_bounds.
  - now apply rank15_observed_object_offset_is_in_bounds.
Qed.

(** * Connected chunks and the live barrier *)

Record Rank15MemoryFaithfulFrame (binding : Rank15LiveBinding) : Type := {
  rank15_frame_state : Clight.state;
  rank15_frame_pair : Rank15HandPair;
  rank15_frame_earlier_cells : Rank15HandCells;
  rank15_frame_later_cells : Rank15HandCells;
  rank15_frame_projection :
    Rank15MemoryFaithfulPairProjection rank15_frame_state binding
      rank15_frame_pair rank15_frame_earlier_cells rank15_frame_later_cells
}.

Record Rank15ClassifiedClightChunk
    (binding : Rank15LiveBinding)
    (before after : Rank15MemoryFaithfulFrame binding) : Type := {
  rank15_chunk_steps : list
    (ConcreteClightStep
      (selected_clight_target (rank15_binding_version binding)));
  rank15_chunk_nonempty : rank15_chunk_steps <> [];
  rank15_chunk_connected :
    ConcreteClightStepsConnected
      (selected_clight_target (rank15_binding_version binding))
      rank15_chunk_steps (rank15_frame_state _ before)
      (rank15_frame_state _ after);
  rank15_chunk_pair_step :
    Rank15HandPairStep (rank15_frame_pair _ before)
      (rank15_frame_pair _ after)
}.

Lemma rank15_classified_chunk_is_real_execution :
  forall binding before after
      (chunk : Rank15ClassifiedClightChunk binding before after),
    @Smallstep.star _ _ Clight.step2
      (Clight.globalenv
        (selected_clight_target (rank15_binding_version binding)))
      (rank15_frame_state _ before)
      (concrete_clight_steps_trace (rank15_chunk_steps _ _ _ chunk))
      (rank15_frame_state _ after).
Proof.
  intros. eapply concrete_clight_steps_connected_star.
  exact (rank15_chunk_connected _ _ _ chunk).
Qed.

Inductive Rank15MemoryFaithfulLiveRun
    (binding : Rank15LiveBinding)
    (start : Rank15MemoryFaithfulFrame binding) :
    Rank15MemoryFaithfulFrame binding -> Prop :=
| rank15_live_run_start :
    rank15_frame_pair _ start = rank15_initial_pair ->
    Rank15MemoryFaithfulLiveRun binding start start
| rank15_live_run_step : forall before after,
    Rank15MemoryFaithfulLiveRun binding start before ->
    Rank15ClassifiedClightChunk binding before after ->
    Rank15MemoryFaithfulLiveRun binding start after.

Theorem rank15_memory_faithful_run_reaches_abstract_pair :
  forall binding start final,
    Rank15MemoryFaithfulLiveRun binding start final ->
    Rank15HandPairReachable (rank15_frame_pair _ final).
Proof.
  intros binding start final Hrun.
  induction Hrun as [Hstart | before after Hprefix IH chunk].
  - rewrite Hstart. exact rank15_pair_reachable_initial.
  - eapply rank15_pair_reachable_step.
    + exact IH.
    + exact (rank15_chunk_pair_step _ _ _ chunk).
Qed.

Theorem rank15_memory_faithful_run_misses_area2_query :
  forall binding start final,
    Rank15MemoryFaithfulLiveRun binding start final ->
    rank15_hand_y (rank15_later_hand (rank15_frame_pair _ final)) +
        rank15_hand_surface_offset_cap + rank15_granted_mario_rise <
      rank15_area2_floor_query_min.
Proof.
  intros binding start final Hrun.
  pose proof (rank15_memory_faithful_run_reaches_abstract_pair
    binding start final Hrun) as Hreachable.
  exact (proj2 (proj2 (proj2 (proj2 (proj2
    (rank15_reachable_vertical_ceiling _ Hreachable)))))).
Qed.

(** A memory-faithful frame alone could still be a fabricated raw Clight
    state.  The accepted wrapper connects it by a concrete finite step list to
    the selected program's real task-entry construction.  This is a genuine
    reachability premise, not an arbitrary "start is valid" proposition. *)
Record Rank15AcceptedLiveRun (binding : Rank15LiveBinding) : Type := {
  rank15_accepted_origin : Clight.state;
  rank15_accepted_start : Rank15MemoryFaithfulFrame binding;
  rank15_accepted_final : Rank15MemoryFaithfulFrame binding;
  rank15_accepted_prefix_steps : list
    (ConcreteClightStep
      (selected_clight_target (rank15_binding_version binding)));
  rank15_accepted_origin_is_runtime_start :
    SelectedRuntimeTaskStart (rank15_binding_version binding)
      (selected_clight_target (rank15_binding_version binding))
      rank15_accepted_origin;
  rank15_accepted_prefix_connected :
    ConcreteClightStepsConnected
      (selected_clight_target (rank15_binding_version binding))
      rank15_accepted_prefix_steps rank15_accepted_origin
      (rank15_frame_state _ rank15_accepted_start);
  rank15_accepted_projected_suffix :
    Rank15MemoryFaithfulLiveRun binding rank15_accepted_start
      rank15_accepted_final
}.

Theorem rank15_accepted_live_run_misses_area2_query :
  forall binding (run : Rank15AcceptedLiveRun binding),
    rank15_hand_y
        (rank15_later_hand
          (rank15_frame_pair _ (rank15_accepted_final _ run))) +
        rank15_hand_surface_offset_cap + rank15_granted_mario_rise <
      rank15_area2_floor_query_min.
Proof.
  intros binding run.
  exact (rank15_memory_faithful_run_misses_area2_query binding
    (rank15_accepted_start _ run) (rank15_accepted_final _ run)
    (rank15_accepted_projected_suffix _ run)).
Qed.

(** A vocabulary for the first failed endpoint/chunk.  Each constructor names
    concrete data that the live replay must report, instead of collapsing all
    failures into an existential "projection did not work" premise. *)
Inductive Rank15LiveProjectionEscape : Type :=
| Rank15PoseEscape (state : Clight.state) (slot : nat)
| Rank15FloorOwnerEscape (state : Clight.state) (floor owner : val)
| Rank15ListOrderEscape (state : Clight.state) (earlier_next later_prev : val)
| Rank15WriteEscape (step : ConcreteClightStep
    (selected_clight_target VersionUS))
| Rank15JPWriteEscape (step : ConcreteClightStep
    (selected_clight_target VersionJP))
| Rank15LifetimeEscape (state : Clight.state) (slot : nat)
    (active : int) (behavior : val)
| Rank15OutsideCallEscape (state : Clight.state) (external : external_function)
| Rank15ChunkTransitionEscape
    (before after : Clight.state) (before_pair after_pair : Rank15HandPair).

Definition EyerokRank15MemoryFaithfulProjectionBoundary : Prop :=
  EyerokRank15LiveOrderingReceipt /\
  EyerokRank15OutsideCallSyntaxReceipt /\
  EyerokRank15ObservedLayoutReceipt /\
  EyerokRank15HeightEncodingBoundary /\
  (forall memory binding slot first second,
    Rank15HandCellLoads memory binding slot first ->
    Rank15HandCellLoads memory binding slot second ->
    Rank15FloorOwnerLoad memory
      (rank15_cells_floor first) (rank15_cells_floor_owner first) ->
    Rank15FloorOwnerLoad memory
      (rank15_cells_floor second) (rank15_cells_floor_owner second) ->
    first = second) /\
  (forall binding earlier_offset later_offset,
    In earlier_offset rank15_observed_object_offsets ->
    In later_offset rank15_observed_object_offsets ->
    object_slot_offset (rank15_binding_earlier_slot binding) + earlier_offset <>
    object_slot_offset (rank15_binding_later_slot binding) + later_offset) /\
  (forall before after,
    rank15_hand_mode before = Rank15Deleted ->
    Rank15FirstHandStep before after ->
    rank15_hand_mode after = Rank15Deleted) /\
  (forall earlier before after,
    rank15_hand_mode before = Rank15Deleted ->
    Rank15LaterHandStep earlier before after ->
    rank15_hand_mode after = Rank15Deleted) /\
  forall binding (run : Rank15AcceptedLiveRun binding),
    rank15_hand_y
        (rank15_later_hand
          (rank15_frame_pair _ (rank15_accepted_final _ run))) +
        rank15_hand_surface_offset_cap + rank15_granted_mario_rise <
      rank15_area2_floor_query_min.

Theorem eyerok_rank15_memory_faithful_projection_boundary_holds :
  EyerokRank15MemoryFaithfulProjectionBoundary.
Proof.
  unfold EyerokRank15MemoryFaithfulProjectionBoundary.
  refine (conj eyerok_rank15_live_ordering_receipt_checked _).
  refine (conj eyerok_rank15_outside_call_syntax_receipt_checked _).
  refine (conj eyerok_rank15_observed_layout_receipt_checked _).
  refine (conj eyerok_rank15_height_encoding_boundary_checked _).
  refine (conj rank15_hand_cell_loads_are_determinate _).
  refine (conj rank15_bound_slots_observed_cells_do_not_alias _).
  refine (conj rank15_first_deleted_mode_is_absorbing _).
  refine (conj rank15_later_deleted_mode_is_absorbing _).
  exact rank15_accepted_live_run_misses_area2_query.
Qed.

Print Assumptions eyerok_rank15_memory_faithful_projection_boundary_holds.
