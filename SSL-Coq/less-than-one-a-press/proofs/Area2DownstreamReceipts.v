(** Lightweight finite mirrors of the conditional JP downstream receipts.

    The values below are copied from the hash-gated observations documented
    and originally checked in [JPLifecycleTrace] and [StateFirstInstaller].
    They are intentionally repeated here so this downstream boundary does not
    load those modules' large generated-Clight dependency closures together.

    These checks establish only the internal consistency of that finite
    mirror.  Hash/ROM/log authentication remains an external instrumentation
    receipt.  They do not prove that either injected observation is clean-entry
    or linked-Clight reachable, and the two observations are not one execution. *)

From Coq Require Import List ZArith.
From compcert Require Import Floats Integers.
From LessThanOneAPress.Proofs Require Import
  GameTypes InputSemantics.

Import ListNotations.
Local Open Scope Z_scope.

Record DownstreamRawVec3 : Type := {
  downstream_raw_x : Int.int;
  downstream_raw_y : Int.int;
  downstream_raw_z : Int.int
}.

Definition downstream_raw_vec3 (x y z : Z) : DownstreamRawVec3 := {|
  downstream_raw_x := Int.repr x;
  downstream_raw_y := Int.repr y;
  downstream_raw_z := Int.repr z
|}.

Definition downstream_raw_vec3_as_vec3f
    (raw : DownstreamRawVec3) : Vec3f := {|
  vec_x := Float32.of_bits (downstream_raw_x raw);
  vec_y := Float32.of_bits (downstream_raw_y raw);
  vec_z := Float32.of_bits (downstream_raw_z raw)
|}.

Record ConditionalJPTriggerMilestone : Type := {
  downstream_milestone_counter : nat;
  downstream_milestone_timer : nat;
  downstream_milestone_mario_state : DownstreamRawVec3;
  downstream_milestone_overlap_observed : bool
}.

Definition conditional_jp_trigger_milestones :
    list ConditionalJPTriggerMilestone :=
  [{| downstream_milestone_counter := 1;
      downstream_milestone_timer := 595;
      downstream_milestone_mario_state :=
        downstream_raw_vec3 1136914308 1165414400 3289593022;
      downstream_milestone_overlap_observed := true |};
   {| downstream_milestone_counter := 2;
      downstream_milestone_timer := 693;
      downstream_milestone_mario_state :=
        downstream_raw_vec3 3279851316 1161281536 3289820436;
      downstream_milestone_overlap_observed := true |};
   {| downstream_milestone_counter := 3;
      downstream_milestone_timer := 748;
      downstream_milestone_mario_state :=
        downstream_raw_vec3 1132248178 1156964352 3289812984;
      downstream_milestone_overlap_observed := true |};
   {| downstream_milestone_counter := 4;
      downstream_milestone_timer := 869;
      downstream_milestone_mario_state :=
        downstream_raw_vec3 3303140277 1150918656 3289778442;
      downstream_milestone_overlap_observed := true |};
   {| downstream_milestone_counter := 5;
      downstream_milestone_timer := 1111;
      downstream_milestone_mario_state :=
        downstream_raw_vec3 3303976653 1150918656 1158245699;
      downstream_milestone_overlap_observed := true |}].

Definition conditional_jp_trigger_order : list HiddenTrigger :=
  [TriggerUpper; TriggerLowerWest; TriggerLowerEast;
   TriggerMiddleWest; TriggerMiddleNorth].

Definition conditional_jp_trigger_milestone_pairs :
    list (ConditionalJPTriggerMilestone * HiddenTrigger) :=
  combine conditional_jp_trigger_milestones conditional_jp_trigger_order.

Definition milestone_overlap_flag_is_true
    (pair : ConditionalJPTriggerMilestone * HiddenTrigger) : Prop :=
  downstream_milestone_overlap_observed (fst pair) = true.

Theorem conditional_jp_milestone_overlap_flags_are_true :
  Forall milestone_overlap_flag_is_true conditional_jp_trigger_milestone_pairs.
Proof. repeat constructor; reflexivity. Qed.

Theorem conditional_jp_milestone_order_and_times_are_exact :
  map snd conditional_jp_trigger_milestone_pairs =
      conditional_jp_trigger_order /\
  map (fun pair => downstream_milestone_counter (fst pair))
      conditional_jp_trigger_milestone_pairs = [1; 2; 3; 4; 5]%nat /\
  map (fun pair => downstream_milestone_timer (fst pair))
      conditional_jp_trigger_milestone_pairs =
        [595; 693; 748; 869; 1111]%nat.
Proof. vm_compute. repeat split. Qed.

Record ConditionalJPFullRouteReceipt : Type := {
  downstream_full_route_max_counter : nat;
  downstream_full_route_saw_star : bool;
  downstream_full_route_saw_star_interaction : bool;
  downstream_full_route_act6_bit_transition : bool
}.

Definition conditional_jp_full_route_receipt :
    ConditionalJPFullRouteReceipt := {|
  downstream_full_route_max_counter := 5;
  downstream_full_route_saw_star := true;
  downstream_full_route_saw_star_interaction := false;
  downstream_full_route_act6_bit_transition := false
|}.

Definition conditional_jp_act6_pickup_collision_sample : Vec3f := {|
  vec_x := f32_bits 1147626532;
  vec_y := f32_bits 1151016960;
  vec_z := f32_bits 1158849374
|}.

Definition conditional_jp_act6_pickup_overlap_observed : bool := true.

Record ConditionalJPAct6PickupReceipt : Type := {
  downstream_pickup_star_pointer : Z;
  downstream_pickup_used_object : Z;
  downstream_pickup_save_before : Z;
  downstream_pickup_save_after : Z;
  downstream_pickup_a_pressed_frames : Z;
  downstream_pickup_a_down_frames : Z;
  downstream_pickup_controller_a_frames : Z
}.

Definition conditional_jp_act6_pickup_receipt :
    ConditionalJPAct6PickupReceipt := {|
  downstream_pickup_star_pointer := 2150893048;
  downstream_pickup_used_object := 2150893048;
  downstream_pickup_save_before := 0;
  downstream_pickup_save_after := 32;
  downstream_pickup_a_pressed_frames := 0;
  downstream_pickup_a_down_frames := 0;
  downstream_pickup_controller_a_frames := 0
|}.

Definition conditional_jp_pickup_is_new_act6_collection
    (receipt : ConditionalJPAct6PickupReceipt) : Prop :=
  Z.testbit (downstream_pickup_save_before receipt) 5 = false /\
  Z.testbit (downstream_pickup_save_after receipt) 5 = true /\
  downstream_pickup_used_object receipt =
    downstream_pickup_star_pointer receipt /\
  downstream_pickup_a_pressed_frames receipt = 0 /\
  downstream_pickup_a_down_frames receipt = 0 /\
  downstream_pickup_controller_a_frames receipt = 0.

Definition downstream_zero_a_frame : FrameInput := {|
  frame_previous_down := Int.zero;
  frame_current_down := Int.zero
|}.

Definition conditional_jp_act6_pickup_a_projection : list FrameInput :=
  repeat downstream_zero_a_frame 828.

Lemma repeat_downstream_zero_a_frame_has_no_a_edge :
  forall count,
    fewer_than_one_a_press (repeat downstream_zero_a_frame count).
Proof.
  intros count. unfold fewer_than_one_a_press.
  induction count as [| count IH]; cbn.
  - constructor.
  - constructor.
    + vm_compute. reflexivity.
    + exact IH.
Qed.

Definition ConditionalJPDownstreamReceipt : Prop :=
  Forall milestone_overlap_flag_is_true conditional_jp_trigger_milestone_pairs /\
  downstream_full_route_max_counter conditional_jp_full_route_receipt = 5%nat /\
  downstream_full_route_saw_star conditional_jp_full_route_receipt = true /\
  downstream_full_route_saw_star_interaction
    conditional_jp_full_route_receipt = false /\
  downstream_full_route_act6_bit_transition
    conditional_jp_full_route_receipt = false /\
  conditional_jp_act6_pickup_overlap_observed = true /\
  conditional_jp_pickup_is_new_act6_collection
    conditional_jp_act6_pickup_receipt /\
  fewer_than_one_a_press conditional_jp_act6_pickup_a_projection.

Theorem conditional_jp_downstream_receipt_checked :
  ConditionalJPDownstreamReceipt.
Proof.
  unfold ConditionalJPDownstreamReceipt.
  split; [exact conditional_jp_milestone_overlap_flags_are_true |].
  split; [reflexivity |].
  split; [reflexivity |].
  split; [reflexivity |].
  split; [reflexivity |].
  split; [reflexivity |].
  split.
  - vm_compute. repeat split; reflexivity.
  - apply repeat_downstream_zero_a_frame_has_no_a_edge.
Qed.

Definition every_trigger_consumed (_ : HiddenTrigger) : bool := true.

Theorem all_five_consumed_alone_does_not_imply_act6_collection :
  all_five_consumed every_trigger_consumed /\
  ~ newly_collected Int.zero Int.zero act6_index.
Proof.
  split.
  - intros trigger _. destruct trigger; reflexivity.
  - intros [Hclear Hset]. vm_compute in Hclear, Hset. discriminate.
Qed.

Theorem recorded_five_counter_prefix_has_no_recorded_collection :
  downstream_full_route_max_counter conditional_jp_full_route_receipt = 5%nat /\
  downstream_full_route_saw_star conditional_jp_full_route_receipt = true /\
  downstream_full_route_saw_star_interaction
    conditional_jp_full_route_receipt = false /\
  downstream_full_route_act6_bit_transition
    conditional_jp_full_route_receipt = false.
Proof. vm_compute. repeat split. Qed.
