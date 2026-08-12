(**
  Finite and generated-Clight facts for the authentic-JP pyramid-top
  lifecycle fixture.

  The fixture starts at a deliberately injected *pre-installer* boundary at
  timer 131 of the spinning top.  It writes only the three position views
  used by the candidate retry schedule (Mario State, Mario Object, and Mario
  Graphics) and clears [gMarioPlatform].  The next retail frame performs the
  floor retry, requests the upper warp, selects a top-owned dynamic surface,
  and captures the top as [gMarioPlatform].  A separate fixture write makes
  the top enter its explosion path.  Nothing in this file claims that clean
  retail play can reach either injected premise.  The theorems below prove
  finite consequences and record exact observations from the hash-gated ROM
  run; they are not a linked whole-program CompCert execution proof.
*)

From Coq Require Import Lia List ZArith.
From compcert Require Import Clight Integers.
From LessThanOneAPress.Generated Require Import
  jp_area jp_level_update jp_mario_actions_cutscene jp_mario_step
  jp_object_list_processor jp_obj_behaviors jp_platform_displacement
  jp_spawn_object.
From LessThanOneAPress.Proofs Require Import
  ASTFacts ClightFacts JPSlotLifetime JPFirstApply.

Import ListNotations.
Local Open Scope nat_scope.

Module JPLCarea := jp_area.
Module JPLClevel := jp_level_update.
Module JPLCcutscene := jp_mario_actions_cutscene.
Module JPLCstep := jp_mario_step.
Module JPLCobjects := jp_object_list_processor.
Module JPLCbehaviors := jp_obj_behaviors.
Module JPLCplatform := jp_platform_displacement.
Module JPLCspawn := jp_spawn_object.

(** Source-order anchors extracted from the generated JP Clight functions. *)
Definition jp_lifecycle_clight_shape_claim : Prop :=
  ident_subsequenceb
    [JPLCcutscene._stop_and_set_height_to_floor;
     JPLCcutscene._level_trigger_warp]
    (direct_callees_s (fn_body JPLCcutscene.f_act_disappeared)) = true /\
  calls_ident_s JPLCbehaviors._bhv_pyramid_top_explode
    (fn_body JPLCbehaviors.f_bhv_pyramid_top_loop) = true /\
  calls_ident_s JPLCbehaviors._spawn_object
    (fn_body JPLCbehaviors.f_bhv_pyramid_top_explode) = true /\
  statement_mentions_int_s 30
    (fn_body JPLCbehaviors.f_bhv_pyramid_top_explode) = true /\
  assigns_field_named_s JPLCbehaviors._activeFlags
    (fn_body JPLCbehaviors.f_bhv_pyramid_top_explode) = true /\
  ident_subsequenceb
    [JPLCobjects._update_terrain_objects;
     JPLCobjects._apply_mario_platform_displacement;
     JPLCobjects._detect_object_collisions;
     JPLCobjects._update_non_terrain_objects;
     JPLCobjects._unload_deactivated_objects;
     JPLCobjects._update_mario_platform]
    (direct_callees_s (fn_body JPLCobjects.f_update_objects)) = true /\
  ident_subsequenceb
    [JPLClevel._warp_area; JPLClevel._area_update_objects]
    (direct_callees_s (fn_body JPLClevel.f_play_mode_normal)) = true /\
  ident_subsequenceb
    [JPLClevel._unload_mario_area; JPLClevel._load_area;
     JPLClevel._init_mario_after_warp]
    (direct_callees_s (fn_body JPLClevel.f_warp_area)) = true /\
  calls_ident_s JPLCspawn._deallocate_object
    (fn_body JPLCspawn.f_unload_object) = true /\
  statement_mentions_ident_s JPLCplatform._gMarioPlatform
    (fn_body JPLCplatform.f_apply_mario_platform_displacement) = true /\
  statement_mentions_ident_s JPLCplatform._gTimeStopState
    (fn_body JPLCplatform.f_apply_mario_platform_displacement) = true /\
  statement_mentions_ident_s JPLCplatform._gMarioObject
    (fn_body JPLCplatform.f_apply_mario_platform_displacement) = true /\
  calls_ident_s JPLCplatform._apply_platform_displacement
    (fn_body JPLCplatform.f_apply_mario_platform_displacement) = true /\
  calls_ident_s JPLCplatform._set_mario_pos
    (fn_body JPLCplatform.f_apply_platform_displacement) = true.

Theorem jp_lifecycle_clight_shape_checked :
  jp_lifecycle_clight_shape_claim.
Proof. vm_compute. repeat split. Qed.

(** The generated setter reached by the Mario branch writes the MarioState
    position global and does not even mention the Mario Object global.  This
    is a source-shape fact supporting the observed caller-return phase split;
    it is not by itself a small-step memory execution. *)
Definition jp_state_only_setter_clight_shape_claim : Prop :=
  statement_mentions_ident_s JPLCplatform._gMarioStates
    (fn_body JPLCplatform.f_set_mario_pos) = true /\
  statement_mentions_ident_s JPLCplatform._gMarioObject
    (fn_body JPLCplatform.f_set_mario_pos) = false.

Theorem jp_state_only_setter_clight_shape_checked :
  jp_state_only_setter_clight_shape_claim.
Proof. vm_compute. split; reflexivity. Qed.

(** Exact IEEE-754 binary32 bit patterns, represented as 32-bit words.
    These are not coordinate integers or mathematical-real replacements. *)
Record RawVec3 : Type := {
  raw_x : Int.int;
  raw_y : Int.int;
  raw_z : Int.int
}.

Definition raw_vec3 (x y z : Z) : RawVec3 :=
  {| raw_x := Int.repr x; raw_y := Int.repr y; raw_z := Int.repr z |}.

(** The only three position writes at the timer-131 install boundary. *)
Definition jp_timer131_installed_state_view : RawVec3 :=
  raw_vec3 3305734144 1145044992 3296722944.

Definition jp_timer131_installed_object_view : RawVec3 :=
  raw_vec3 3305111552 1145044992 3296722944.

Definition jp_timer131_installed_graphics_view : RawVec3 :=
  raw_vec3 3303587840 1155416064 3294724096.

(** All three views after the next retail frame has run the retry and warp
    interaction schedule. *)
Definition jp_retail_retry_captured_top_view : RawVec3 :=
  raw_vec3 3303587840 1155468822 3294724096.

(** State/Object/Graphics on the top at the early-free observation. *)
Definition jp_explosion_free_mario_view : RawVec3 :=
  raw_vec3 3304745090 1156620135 3292908471.

Definition jp_upper_spawn_before_first_apply : RawVec3 :=
  raw_vec3 0 1168891904 1132462080.

Definition jp_true_first_apply_after : RawVec3 :=
  raw_vec3 1136053216 1168891904 3297319343.

(** The function writes Mario State.  At its caller return, Mario Object and
    Mario Graphics still contain the destination spawn coordinates; the next
    Mario update synchronizes them to [jp_true_first_apply_after]. *)
Definition jp_true_first_apply_return_object : RawVec3 :=
  jp_upper_spawn_before_first_apply.

Definition jp_true_first_apply_return_graphics : RawVec3 :=
  jp_upper_spawn_before_first_apply.

Definition jp_first_area2_poll_synchronized_view : RawVec3 :=
  jp_true_first_apply_after.

(** Authentic original-JP code receipt.  ROM offset [0x1000] is loaded at
    virtual address [0x80246000], hence the raw-binary disassembly adjustment
    is [0x80245000].  The list spans [0x802c83f0..0x802c8454]. *)
Definition jp_apply_mario_platform_displacement_entry : Z := 2150401008.
Definition jp_apply_platform_displacement_target : Z := 2150400248.
Definition jp_apply_mario_platform_displacement_epilogue : Z := 2150401096.
Definition jp_observed_first_apply_caller_return : Z := 2150223816.

Local Open Scope Z_scope.

Definition jp_apply_mario_platform_displacement_code_words : list Z :=
    [666763232; 2948530196; 1007583283; 2379153108; 2947416092;
     1007648820; 2381299984; 838336576; 385875979; 0;
     1008304182; 2402942440; 320864263; 0; 2410151964;
     285212676; 0; 604241921; 202055742; 2409955356;
     268435457; 0; 2411659284; 666697760; 65011720; 0].

Theorem jp_retail_apply_disassembly_receipt_checked :
  length jp_apply_mario_platform_displacement_code_words = 26%nat /\
  nth_error jp_apply_mario_platform_displacement_code_words 0 =
    Some 666763232 /\
  nth_error jp_apply_mario_platform_displacement_code_words 18 =
    Some 202055742 /\
  nth_error jp_apply_mario_platform_displacement_code_words 24 =
    Some 65011720 /\
  jp_apply_mario_platform_displacement_entry = 2150401008%Z /\
  jp_apply_platform_displacement_target = 2150400248%Z /\
  jp_apply_mario_platform_displacement_epilogue = 2150401096%Z.
Proof. vm_compute. repeat split. Qed.

(** Decode the observed word rather than trusting its descriptive label.  At
    word 18 the retail JP routine contains a MIPS [jal]; combining its 26-bit
    field with the caller PC's high nibble yields the exact platform helper. *)
Definition mips_opcode (word : Z) : Z := Z.shiftr word 26.

Definition mips_jump_target (pc word : Z) : Z :=
  Z.lor (Z.land (pc + 4) 4026531840)
    (Z.shiftl (Z.land word 67108863) 2).

Theorem jp_retail_apply_word18_decodes_platform_displacement_call :
  let call_pc := jp_apply_mario_platform_displacement_entry + 18 * 4 in
  nth_error jp_apply_mario_platform_displacement_code_words 18 =
    Some 202055742 /\
  mips_opcode 202055742 = 3 /\
  mips_jump_target call_pc 202055742 =
    jp_apply_platform_displacement_target.
Proof. vm_compute. repeat split. Qed.

Local Close Scope Z_scope.

(** Object sample used by collision detection on the successful frame. *)
Definition jp_upper_trigger_collision_object_sample : RawVec3 :=
  raw_vec3 1136866788 1165660160 3289674026.

(** MarioState after that frame's action update and trigger behavior. *)
Definition jp_upper_trigger_consumed_state_sample : RawVec3 :=
  raw_vec3 1136914308 1165414400 3289593022.

Record JPPureYawTopPayload : Type := {
  top_pos_bits : RawVec3;
  top_vel_x_bits : Int.int;
  top_vel_y_bits : Int.int;
  top_vel_z_bits : Int.int;
  top_face_pitch_s32 : Int.int;
  top_face_yaw_s32 : Int.int;
  top_face_roll_s32 : Int.int;
  top_angle_vel_pitch_s32 : Int.int;
  top_angle_vel_yaw_s32 : Int.int;
  top_angle_vel_roll_s32 : Int.int
}.

Definition jp_exploded_top_payload : JPPureYawTopPayload :=
  {| top_pos_bits := raw_vec3 3305103360 1156235846 3296706560;
     top_vel_x_bits := Int.zero;
     top_vel_y_bits := Int.repr 1084227584;
     top_vel_z_bits := Int.zero;
     top_face_pitch_s32 := Int.zero;
     top_face_yaw_s32 := Int.repr 488448;
     top_face_roll_s32 := Int.zero;
     top_angle_vel_pitch_s32 := Int.zero;
     top_angle_vel_yaw_s32 := Int.repr 6144;
     top_angle_vel_roll_s32 := Int.zero |}.

Definition pure_yaw_payload (payload : JPPureYawTopPayload) : Prop :=
  top_face_pitch_s32 payload = Int.zero /\
  top_face_roll_s32 payload = Int.zero /\
  top_angle_vel_pitch_s32 payload = Int.zero /\
  top_angle_vel_roll_s32 payload = Int.zero /\
  top_angle_vel_yaw_s32 payload = Int.repr 6144.

Theorem observed_exploded_top_payload_is_pure_yaw :
  pure_yaw_payload jp_exploded_top_payload.
Proof. vm_compute. repeat split. Qed.

(**
  At the post-explosion poll the top is the free-list head.  Area teardown
  pushes 131 slots in front of it.  The destination consumes 84 slots before
  the true first apply.  Therefore the watched top is still free, now at
  depth 47.  This theorem is polymorphic in slot identity and does not smuggle
  an object-address assumption into arithmetic.
*)
Theorem jp_top_survives_true_first_apply_allocations_at_depth_47 :
  forall (Slot : Type) (tail bulk : list Slot) (top : Slot),
    length bulk = 131 ->
    nth_error
      (skipn 84 (free_list_after_early_release tail bulk top)) 47 =
      Some top.
Proof.
  intros Slot tail bulk top Hbulk.
  rewrite nth_error_skipn_plus.
  replace (84 + 47) with (length bulk) by lia.
  apply early_released_slot_has_exact_lifo_depth.
Qed.

Theorem jp_observed_free_list_lengths_and_depths_are_consistent :
  109 + 131 = 240 /\
  240 - 84 = 156 /\
  131 - 84 = 47 /\
  jp_pre_true_first_apply_fresh_allocations false = 84.
Proof. vm_compute. repeat split. Qed.

Inductive JPLifecycleMilestone : Type :=
| ThreeViewBoundaryInjectedAtTopTimer131
| RetailRetryCapturedTop
| ExplodedAndFreedAtDepth0
| TwoChangeAreaTicksComplete
| TrueFirstArea2ApplyEntered
| TrueFirstArea2ApplyReturned
| UpperTriggerConsumed.

Record JPLifecycleBoundaryTrace : Type := {
  trace_top_pool_slot : nat;
  trace_install_global_timer : nat;
  trace_retry_capture_global_timer : nat;
  trace_explosion_global_timer : nat;
  trace_first_area2_apply_timer : nat;
  trace_first_area2_poll_timer : nat;
  trace_trigger_consumed_timer : nat;
  trace_explosion_free_depth : nat;
  trace_explosion_free_length : nat;
  trace_pre_destination_depth : nat;
  trace_destination_allocations : nat;
  trace_first_poll_free_depth : nat;
  trace_first_poll_free_length : nat;
  trace_route_stick_x : Z;
  trace_route_stick_y : Z;
  trace_route_held_frames : nat;
  trace_a_pressed_frames : nat;
  trace_a_down_frames : nat;
  trace_controller_a_frames : nat;
  trace_initial_hidden_counter : nat;
  trace_final_hidden_counter : nat;
  trace_install_state_view : RawVec3;
  trace_install_object_view : RawVec3;
  trace_install_graphics_view : RawVec3;
  trace_retry_capture_view : RawVec3;
  trace_retry_action_word : Int.int;
  trace_retry_action_arg_word : Int.int;
  trace_upper_warp_address : Z;
  trace_retry_used_obj_address : Z;
  trace_retry_floor_owner_pool_slot : nat;
  trace_retry_platform_pool_slot : nat;
  trace_explosion_mario_view : RawVec3;
  trace_explosion_platform_pool_slot : nat;
  trace_first_apply_entry_pc : Z;
  trace_first_apply_caller_return_pc : Z;
  trace_first_apply_time_stop_state : Int.int;
  trace_platform_slot_at_first_apply : nat;
  trace_platform_slot_active_at_first_apply : bool;
  trace_before_first_apply : RawVec3;
  trace_after_first_apply : RawVec3;
  trace_return_object_view : RawVec3;
  trace_return_graphics_view : RawVec3;
  trace_first_poll_synchronized_view : RawVec3;
  trace_collision_object_sample : RawVec3;
  trace_consumed_state_sample : RawVec3;
  trace_top_payload : JPPureYawTopPayload
}.

Definition authenticated_jp_lifecycle_boundary_trace :
    JPLifecycleBoundaryTrace :=
  {| trace_top_pool_slot := 61;
     trace_install_global_timer := 492;
     trace_retry_capture_global_timer := 493;
     trace_explosion_global_timer := 513;
     trace_first_area2_apply_timer := 515;
     trace_first_area2_poll_timer := 516;
     trace_trigger_consumed_timer := 595;
     trace_explosion_free_depth := 0;
     trace_explosion_free_length := 109;
     trace_pre_destination_depth := 131;
     trace_destination_allocations := 84;
     trace_first_poll_free_depth := 47;
     trace_first_poll_free_length := 156;
     trace_route_stick_x := (-127)%Z;
     trace_route_stick_y := (-96)%Z;
     trace_route_held_frames := 60;
     trace_a_pressed_frames := 0;
     trace_a_down_frames := 0;
     trace_controller_a_frames := 0;
     trace_initial_hidden_counter := 0;
     trace_final_hidden_counter := 1;
     trace_install_state_view := jp_timer131_installed_state_view;
     trace_install_object_view := jp_timer131_installed_object_view;
     trace_install_graphics_view := jp_timer131_installed_graphics_view;
     trace_retry_capture_view := jp_retail_retry_captured_top_view;
     trace_retry_action_word := Int.repr 4864;
     trace_retry_action_arg_word := Int.repr 262145;
     trace_upper_warp_address := 2150914328%Z;
     trace_retry_used_obj_address := 2150914328%Z;
     trace_retry_floor_owner_pool_slot := 61;
     trace_retry_platform_pool_slot := 61;
     trace_explosion_mario_view := jp_explosion_free_mario_view;
     trace_explosion_platform_pool_slot := 61;
     trace_first_apply_entry_pc :=
       jp_apply_mario_platform_displacement_entry;
     trace_first_apply_caller_return_pc :=
       jp_observed_first_apply_caller_return;
     trace_first_apply_time_stop_state := Int.zero;
     trace_platform_slot_at_first_apply := 61;
     trace_platform_slot_active_at_first_apply := false;
     trace_before_first_apply := jp_upper_spawn_before_first_apply;
     trace_after_first_apply := jp_true_first_apply_after;
     trace_return_object_view := jp_true_first_apply_return_object;
     trace_return_graphics_view := jp_true_first_apply_return_graphics;
     trace_first_poll_synchronized_view :=
       jp_first_area2_poll_synchronized_view;
     trace_collision_object_sample := jp_upper_trigger_collision_object_sample;
     trace_consumed_state_sample := jp_upper_trigger_consumed_state_sample;
     trace_top_payload := jp_exploded_top_payload |}.

Definition boundary_trace_is_internally_consistent
    (trace : JPLifecycleBoundaryTrace) : Prop :=
  trace_retry_capture_global_timer trace =
    trace_install_global_timer trace + 1 /\
  trace_explosion_global_timer trace =
    trace_install_global_timer trace + 21 /\
  trace_first_area2_apply_timer trace =
    trace_explosion_global_timer trace + 2 /\
  trace_first_area2_poll_timer trace =
    trace_explosion_global_timer trace + 3 /\
  trace_trigger_consumed_timer trace =
    trace_first_area2_poll_timer trace + 79 /\
  trace_pre_destination_depth trace = 131 /\
  trace_destination_allocations trace = 84 /\
  trace_first_poll_free_depth trace =
    trace_pre_destination_depth trace - trace_destination_allocations trace /\
  trace_first_poll_free_length trace =
    240 - trace_destination_allocations trace /\
  trace_a_pressed_frames trace = 0 /\
  trace_a_down_frames trace = 0 /\
  trace_controller_a_frames trace = 0 /\
  trace_initial_hidden_counter trace = 0 /\
  trace_final_hidden_counter trace = 1 /\
  trace_first_apply_entry_pc trace =
    jp_apply_mario_platform_displacement_entry /\
  trace_first_apply_caller_return_pc trace =
    jp_observed_first_apply_caller_return /\
  trace_retry_action_word trace = Int.repr 4864 /\
  trace_retry_action_arg_word trace = Int.repr 262145 /\
  trace_retry_used_obj_address trace = trace_upper_warp_address trace /\
  trace_retry_floor_owner_pool_slot trace = trace_top_pool_slot trace /\
  trace_retry_platform_pool_slot trace = trace_top_pool_slot trace /\
  trace_explosion_platform_pool_slot trace = trace_top_pool_slot trace /\
  trace_first_apply_time_stop_state trace = Int.zero /\
  trace_platform_slot_at_first_apply trace = trace_top_pool_slot trace /\
  trace_platform_slot_active_at_first_apply trace = false /\
  trace_before_first_apply trace <> trace_after_first_apply trace /\
  trace_return_object_view trace = trace_before_first_apply trace /\
  trace_return_graphics_view trace = trace_before_first_apply trace /\
  trace_first_poll_synchronized_view trace =
    trace_after_first_apply trace /\
  pure_yaw_payload (trace_top_payload trace).

Theorem authenticated_jp_lifecycle_boundary_trace_checked :
  boundary_trace_is_internally_consistent
    authenticated_jp_lifecycle_boundary_trace.
Proof. vm_compute. repeat split; discriminate. Qed.

(** At the authentic caller return, only Mario State contains the platform
    displacement.  Mario Object and Mario Graphics still contain the Area-2
    spawn coordinates; the next retail update synchronizes all three views.
    This is a reachable phase split *from the injected fixture*, not from a
    proved clean Area-1 execution. *)
Theorem observed_true_first_apply_creates_state_object_graphics_phase_split :
  trace_after_first_apply authenticated_jp_lifecycle_boundary_trace <>
    trace_return_object_view authenticated_jp_lifecycle_boundary_trace /\
  trace_return_object_view authenticated_jp_lifecycle_boundary_trace =
    trace_return_graphics_view authenticated_jp_lifecycle_boundary_trace /\
  trace_first_poll_synchronized_view
      authenticated_jp_lifecycle_boundary_trace =
    trace_after_first_apply authenticated_jp_lifecycle_boundary_trace.
Proof. vm_compute. repeat split; discriminate. Qed.

(** This is the strongest bundled theorem justified by this file:
    conditional on the injected timer-131 three-view boundary and the
    hash-gated observations, the retail installer captures the top, the slot
    survives to a nontrivial true-first-apply displacement, and a zero-A
    continuation consumes the upper trigger.  It is not a clean-entry
    reachability theorem and does not set the Act-6 save bit. *)
Theorem observed_boundary_closes_lifecycle_and_upper_trigger_continuation :
  boundary_trace_is_internally_consistent
    authenticated_jp_lifecycle_boundary_trace /\
  trace_after_first_apply authenticated_jp_lifecycle_boundary_trace =
    jp_true_first_apply_after /\
  trace_collision_object_sample authenticated_jp_lifecycle_boundary_trace =
    jp_upper_trigger_collision_object_sample /\
  trace_final_hidden_counter authenticated_jp_lifecycle_boundary_trace = 1.
Proof.
  split.
  - exact authenticated_jp_lifecycle_boundary_trace_checked.
  - repeat split; reflexivity.
Qed.

(** A separate authenticated continuation starts from the same injected
    timer-131 boundary and drives the retail run through all five hidden-star
    controller increments.  This record deliberately includes the negative
    collection result: the star spawns, but no interaction, star dance, or
    Act-6 save-bit transition occurs. *)
Record JPFullRouteMilestone : Type := {
  full_milestone_counter : nat;
  full_milestone_timer : nat;
  full_milestone_mario_state : RawVec3
}.

Definition jp_full_route_counter_1_state : RawVec3 :=
  raw_vec3 1136914308 1165414400 3289593022.

Definition jp_full_route_counter_2_state : RawVec3 :=
  raw_vec3 3279851316 1161281536 3289820436.

Definition jp_full_route_counter_3_state : RawVec3 :=
  raw_vec3 1132248178 1156964352 3289812984.

Definition jp_full_route_counter_4_state : RawVec3 :=
  raw_vec3 3303140277 1150918656 3289778442.

Definition jp_full_route_counter_5_state : RawVec3 :=
  raw_vec3 3303976653 1150918656 1158245699.

Definition jp_act6_spawn_position : RawVec3 :=
  raw_vec3 1147207680 1152319488 1158864896.

Definition authenticated_jp_full_route_milestones :
    list JPFullRouteMilestone :=
  [{| full_milestone_counter := 1;
      full_milestone_timer := 595;
      full_milestone_mario_state := jp_full_route_counter_1_state |};
   {| full_milestone_counter := 2;
      full_milestone_timer := 693;
      full_milestone_mario_state := jp_full_route_counter_2_state |};
   {| full_milestone_counter := 3;
      full_milestone_timer := 748;
      full_milestone_mario_state := jp_full_route_counter_3_state |};
   {| full_milestone_counter := 4;
      full_milestone_timer := 869;
      full_milestone_mario_state := jp_full_route_counter_4_state |};
   {| full_milestone_counter := 5;
      full_milestone_timer := 1111;
      full_milestone_mario_state := jp_full_route_counter_5_state |}].

Record JPFullRouteObservation : Type := {
  full_route_milestones : list JPFullRouteMilestone;
  full_route_counter_transitions : nat;
  full_route_max_counter : nat;
  full_route_star_spawn_timer : nat;
  full_route_star_pool_slot : nat;
  full_route_star_pointer : Z;
  full_route_star_position : RawVec3;
  full_route_saw_star : bool;
  full_route_saw_star_interaction : bool;
  full_route_saw_star_dance : bool;
  full_route_initial_ssl_star_byte : nat;
  full_route_final_ssl_star_byte : nat;
  full_route_act6_bit_transition : bool;
  full_route_a_pressed_frames : nat;
  full_route_a_down_frames : nat;
  full_route_controller_a_frames : nat
}.

Definition authenticated_jp_full_route_observation :
    JPFullRouteObservation :=
  {| full_route_milestones := authenticated_jp_full_route_milestones;
     full_route_counter_transitions := 5;
     full_route_max_counter := 5;
     full_route_star_spawn_timer := 1115;
     full_route_star_pool_slot := 42;
     full_route_star_pointer := 2150900952%Z;
     full_route_star_position := jp_act6_spawn_position;
     full_route_saw_star := true;
     full_route_saw_star_interaction := false;
     full_route_saw_star_dance := false;
     full_route_initial_ssl_star_byte := 0;
     full_route_final_ssl_star_byte := 0;
     full_route_act6_bit_transition := false;
     full_route_a_pressed_frames := 0;
     full_route_a_down_frames := 0;
     full_route_controller_a_frames := 0 |}.

Definition full_route_observation_is_internally_consistent
    (observation : JPFullRouteObservation) : Prop :=
  map full_milestone_counter (full_route_milestones observation) =
    [1; 2; 3; 4; 5] /\
  map full_milestone_timer (full_route_milestones observation) =
    [595; 693; 748; 869; 1111] /\
  map full_milestone_mario_state (full_route_milestones observation) =
    [jp_full_route_counter_1_state;
     jp_full_route_counter_2_state;
     jp_full_route_counter_3_state;
     jp_full_route_counter_4_state;
     jp_full_route_counter_5_state] /\
  full_route_counter_transitions observation = 5 /\
  full_route_max_counter observation = 5 /\
  full_route_star_spawn_timer observation = 1115 /\
  full_route_star_pool_slot observation = 42 /\
  full_route_star_pointer observation = 2150900952%Z /\
  full_route_star_position observation = jp_act6_spawn_position /\
  full_route_saw_star observation = true /\
  full_route_saw_star_interaction observation = false /\
  full_route_saw_star_dance observation = false /\
  full_route_initial_ssl_star_byte observation = 0 /\
  full_route_final_ssl_star_byte observation = 0 /\
  full_route_act6_bit_transition observation = false /\
  full_route_a_pressed_frames observation = 0 /\
  full_route_a_down_frames observation = 0 /\
  full_route_controller_a_frames observation = 0.

Theorem authenticated_jp_full_route_observation_checked :
  full_route_observation_is_internally_consistent
    authenticated_jp_full_route_observation.
Proof. vm_compute. repeat split. Qed.

Theorem conditional_jp_full_route_reaches_spawn_but_not_collection :
  full_route_max_counter authenticated_jp_full_route_observation = 5 /\
  full_route_saw_star authenticated_jp_full_route_observation = true /\
  full_route_saw_star_interaction
    authenticated_jp_full_route_observation = false /\
  full_route_saw_star_dance authenticated_jp_full_route_observation = false /\
  full_route_initial_ssl_star_byte
    authenticated_jp_full_route_observation = 0 /\
  full_route_final_ssl_star_byte
    authenticated_jp_full_route_observation = 0 /\
  full_route_act6_bit_transition
    authenticated_jp_full_route_observation = false /\
  full_route_a_pressed_frames authenticated_jp_full_route_observation = 0 /\
  full_route_a_down_frames authenticated_jp_full_route_observation = 0 /\
  full_route_controller_a_frames authenticated_jp_full_route_observation = 0.
Proof. vm_compute. repeat split. Qed.

(** Remaining links, intentionally not postulated here:

    - construct the timer-131 three-view boundary and explosion premise from
      a clean retail Area-1 execution without debugger writes;
    - replay the executable entry/return receipt as a linked Clight memory
      execution, including the CompCert binary32 helper semantics;
    - overlap and collect the spawned Act-6 star and set its initially-clear
      save bit (the recorded continuation proves the star spawns but records
      byte [0 -> 0]); and
    - establish an Act-3 collection route or exclude that route. *)
