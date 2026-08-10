(** Transparent receipt for the conditional JP timer-131 State-first probe.

    The record below transcribes exact words printed by the hash-gated retail
    replay in [instrumentation/timer131-state-first/expected-trace.txt].  Its
    checked theorem prevents the proof-facing copy from drifting away from
    those words.  It does not authenticate that log, prove the IDO/VR4300
    [trunc.w.s; mfc1; sh; lh] execution, execute linked Clight, or provide a
    clean zero-A writer for the injected State/Object split.  Those boundaries
    boundaries are named explicitly at the end and are not premises of the
    checked theorem. *)

From Coq Require Import Bool ZArith.

Local Open Scope Z_scope.

Record RawVec3Words : Type := {
  raw_word_x : Z;
  raw_word_y : Z;
  raw_word_z : Z
}.

Definition raw_vec3_words (x y z : Z) : RawVec3Words :=
  {| raw_word_x := x; raw_word_y := y; raw_word_z := z |}.

Record SignedTerrainQuery : Type := {
  terrain_query_x : Z;
  terrain_query_y : Z;
  terrain_query_z : Z
}.

Definition signed_terrain_query (x y z : Z) : SignedTerrainQuery :=
  {| terrain_query_x := x;
     terrain_query_y := y;
     terrain_query_z := z |}.

Record Area1StateFirstRetailTrace : Type := {
  state_first_trace_is_jp : bool;
  state_first_trace_area : Z;
  state_first_trace_top_slot : Z;

  state_first_trace_install_global_timer : Z;
  state_first_trace_install_top_action : Z;
  state_first_trace_install_top_timer : Z;
  state_first_trace_install_top_words : RawVec3Words;
  state_first_trace_install_state_words : RawVec3Words;
  state_first_trace_install_object_words : RawVec3Words;
  state_first_trace_install_graphics_words : RawVec3Words;
  state_first_trace_install_action : Z;
  state_first_trace_install_action_arg : Z;
  state_first_trace_install_used_object : Z;
  state_first_trace_install_platform : Z;

  state_first_trace_top_pointer : Z;
  state_first_trace_upper_warp_pointer : Z;

  state_first_trace_post_global_timer : Z;
  state_first_trace_post_top_action : Z;
  state_first_trace_post_top_timer : Z;
  state_first_trace_post_top_words : RawVec3Words;
  state_first_trace_post_state_words : RawVec3Words;
  state_first_trace_post_object_words : RawVec3Words;
  state_first_trace_post_graphics_words : RawVec3Words;
  state_first_trace_post_floor_pointer : Z;
  state_first_trace_post_floor_owner : Z;
  state_first_trace_post_floor_height_word : Z;
  state_first_trace_post_action : Z;
  state_first_trace_post_action_arg : Z;
  state_first_trace_post_used_object : Z;
  state_first_trace_post_platform : Z;

  state_first_trace_armed : bool;
  state_first_trace_installed : bool;
  state_first_trace_post_observed : bool;
  state_first_trace_retry_copied : bool;
  state_first_trace_state_coordinates_preserved : bool;
  state_first_trace_floor_owner_is_top : bool;
  state_first_trace_warp_action_selected : bool;
  state_first_trace_used_object_is_warp : bool;
  state_first_trace_platform_is_top : bool;
  state_first_trace_a_pressed_frames : Z;
  state_first_trace_a_down_frames : Z;
  state_first_trace_controller_a_frames : Z
}.

(** All words and pointers are recorded as unsigned hexadecimal values in the
    external log and as their transparent [Z] representations here. *)
Definition jp_area1_state_first_retail_trace : Area1StateFirstRetailTrace :=
  {| state_first_trace_is_jp := true;
     state_first_trace_area := 1;
     state_first_trace_top_slot := 61;

     state_first_trace_install_global_timer := 492;
     state_first_trace_install_top_action := 1;
     state_first_trace_install_top_timer := 131;
     state_first_trace_install_top_words :=
       raw_vec3_words 3305103360 1155416646 3296706560;
       (* c4ffe000 / 44de4246 / c47fc000 *)
     state_first_trace_install_state_words :=
       raw_vec3_words 3303587840 1199798528 3294724096;
       (* c4e8c000 / 47837900 / c4618000 *)
     state_first_trace_install_object_words :=
       raw_vec3_words 3305111552 1145044992 3296722944;
       (* c5000000 / 44400000 / c4800000 *)
     state_first_trace_install_graphics_words :=
       raw_vec3_words 3301777408 1152778240 3292774400;
       (* c4cd2000 / 44b60000 / c443c000 *)
     state_first_trace_install_action := 205521409; (* 0c400201 *)
     state_first_trace_install_action_arg := 0;
     state_first_trace_install_used_object := 0;
     state_first_trace_install_platform := 0;

     state_first_trace_top_pointer := 2150912504;        (* 803451f8 *)
     state_first_trace_upper_warp_pointer := 2150914328; (* 80345918 *)

     state_first_trace_post_global_timer := 493;
     state_first_trace_post_top_action := 1;
     state_first_trace_post_top_timer := 132;
     state_first_trace_post_top_words :=
       raw_vec3_words 3305271296 1155457606 3296706560;
       (* c5027000 / 44dee246 / c47fc000 *)
     state_first_trace_post_state_words :=
       raw_vec3_words 3303587840 1155464726 3294724096;
       (* c4e8c000 / 44defe16 / c4618000 *)
     state_first_trace_post_object_words :=
       raw_vec3_words 3303587840 1155464726 3294724096;
     state_first_trace_post_graphics_words :=
       raw_vec3_words 3303587840 1155464726 3294724096;
     state_first_trace_post_floor_pointer := 2149169936; (* 8019bb10 *)
     state_first_trace_post_floor_owner := 2150912504;
     state_first_trace_post_floor_height_word := 1155464726;
     state_first_trace_post_action := 4864;       (* 00001300 *)
     state_first_trace_post_action_arg := 262145; (* 00040001 *)
     state_first_trace_post_used_object := 2150914328;
     state_first_trace_post_platform := 2150912504;

     state_first_trace_armed := true;
     state_first_trace_installed := true;
     state_first_trace_post_observed := true;
     state_first_trace_retry_copied := false;
     state_first_trace_state_coordinates_preserved := true;
     state_first_trace_floor_owner_is_top := true;
     state_first_trace_warp_action_selected := true;
     state_first_trace_used_object_is_warp := true;
     state_first_trace_platform_is_top := true;
     state_first_trace_a_pressed_frames := 0;
     state_first_trace_a_down_frames := 0;
     state_first_trace_controller_a_frames := 0 |}.

Definition Area1StateFirstRetailTraceClaim : Prop :=
  state_first_trace_is_jp jp_area1_state_first_retail_trace = true /\
  state_first_trace_area jp_area1_state_first_retail_trace = 1 /\
  state_first_trace_top_slot jp_area1_state_first_retail_trace = 61 /\
  state_first_trace_install_global_timer
    jp_area1_state_first_retail_trace = 492 /\
  state_first_trace_install_top_action
    jp_area1_state_first_retail_trace = 1 /\
  state_first_trace_install_top_timer jp_area1_state_first_retail_trace = 131 /\
  state_first_trace_install_top_words jp_area1_state_first_retail_trace =
    raw_vec3_words 3305103360 1155416646 3296706560 /\
  state_first_trace_post_global_timer
    jp_area1_state_first_retail_trace = 493 /\
  state_first_trace_post_top_action
    jp_area1_state_first_retail_trace = 1 /\
  state_first_trace_post_top_timer jp_area1_state_first_retail_trace = 132 /\
  state_first_trace_post_top_words jp_area1_state_first_retail_trace =
    raw_vec3_words 3305271296 1155457606 3296706560 /\
  state_first_trace_install_state_words jp_area1_state_first_retail_trace =
    raw_vec3_words 3303587840 1199798528 3294724096 /\
  state_first_trace_install_object_words jp_area1_state_first_retail_trace =
    raw_vec3_words 3305111552 1145044992 3296722944 /\
  state_first_trace_install_graphics_words jp_area1_state_first_retail_trace =
    raw_vec3_words 3301777408 1152778240 3292774400 /\
  state_first_trace_install_action jp_area1_state_first_retail_trace =
    205521409 /\
  state_first_trace_install_action_arg jp_area1_state_first_retail_trace = 0 /\
  state_first_trace_install_used_object jp_area1_state_first_retail_trace = 0 /\
  state_first_trace_install_platform jp_area1_state_first_retail_trace = 0 /\
  state_first_trace_post_state_words jp_area1_state_first_retail_trace =
    raw_vec3_words 3303587840 1155464726 3294724096 /\
  state_first_trace_post_object_words jp_area1_state_first_retail_trace =
    state_first_trace_post_state_words jp_area1_state_first_retail_trace /\
  state_first_trace_post_graphics_words jp_area1_state_first_retail_trace =
    state_first_trace_post_state_words jp_area1_state_first_retail_trace /\
  state_first_trace_post_floor_height_word
    jp_area1_state_first_retail_trace = 1155464726 /\
  state_first_trace_top_pointer jp_area1_state_first_retail_trace =
    2150912504 /\
  state_first_trace_upper_warp_pointer jp_area1_state_first_retail_trace =
    2150914328 /\
  state_first_trace_post_floor_pointer jp_area1_state_first_retail_trace =
    2149169936 /\
  state_first_trace_post_floor_owner jp_area1_state_first_retail_trace =
    state_first_trace_top_pointer jp_area1_state_first_retail_trace /\
  state_first_trace_post_platform jp_area1_state_first_retail_trace =
    state_first_trace_top_pointer jp_area1_state_first_retail_trace /\
  state_first_trace_post_used_object jp_area1_state_first_retail_trace =
    state_first_trace_upper_warp_pointer jp_area1_state_first_retail_trace /\
  state_first_trace_post_action jp_area1_state_first_retail_trace = 4864 /\
  state_first_trace_post_action_arg jp_area1_state_first_retail_trace = 262145 /\
  state_first_trace_armed jp_area1_state_first_retail_trace = true /\
  state_first_trace_installed jp_area1_state_first_retail_trace = true /\
  state_first_trace_post_observed jp_area1_state_first_retail_trace = true /\
  state_first_trace_retry_copied jp_area1_state_first_retail_trace = false /\
  state_first_trace_state_coordinates_preserved
    jp_area1_state_first_retail_trace = true /\
  state_first_trace_floor_owner_is_top jp_area1_state_first_retail_trace = true /\
  state_first_trace_warp_action_selected jp_area1_state_first_retail_trace = true /\
  state_first_trace_used_object_is_warp jp_area1_state_first_retail_trace = true /\
  state_first_trace_platform_is_top jp_area1_state_first_retail_trace = true /\
  state_first_trace_a_pressed_frames jp_area1_state_first_retail_trace = 0 /\
  state_first_trace_a_down_frames jp_area1_state_first_retail_trace = 0 /\
  state_first_trace_controller_a_frames jp_area1_state_first_retail_trace = 0.

Theorem jp_area1_state_first_retail_trace_record_checked :
  Area1StateFirstRetailTraceClaim.
Proof.
  unfold Area1StateFirstRetailTraceClaim,
    jp_area1_state_first_retail_trace.
  cbn.
  repeat split; reflexivity.
Qed.

(** Focused continuation receipt from the second hash-gated replay.  This
    starts from the same injected State-first boundary and observes the top's
    early free, the authentic first destination-area platform apply, and the
    upper hidden-star trigger.  As above, this is transparent data rather than
    an execution theorem. *)
Record Area1StateFirstLifecycleTrace : Type := {
  state_first_lifecycle_explosion_timer : Z;
  state_first_lifecycle_explosion_slot : Z;
  state_first_lifecycle_explosion_active : Z;
  state_first_lifecycle_explosion_platform : Z;
  state_first_lifecycle_explosion_free_depth : Z;
  state_first_lifecycle_explosion_mario_words : RawVec3Words;

  state_first_lifecycle_first_apply_timer : Z;
  state_first_lifecycle_first_apply_area : Z;
  state_first_lifecycle_first_apply_active : Z;
  state_first_lifecycle_first_apply_platform : Z;
  state_first_lifecycle_first_apply_free_depth : Z;
  state_first_lifecycle_first_apply_before_words : RawVec3Words;
  state_first_lifecycle_first_apply_after_words : RawVec3Words;
  state_first_lifecycle_first_apply_object_words : RawVec3Words;
  state_first_lifecycle_first_apply_entry_seen : bool;
  state_first_lifecycle_first_apply_return_seen : bool;

  state_first_lifecycle_first_area2_poll_timer : Z;
  state_first_lifecycle_first_area2_poll_platform : Z;
  state_first_lifecycle_first_area2_words : RawVec3Words;

  state_first_lifecycle_trigger_before_timer : Z;
  state_first_lifecycle_trigger_before_active : Z;
  state_first_lifecycle_trigger_before_counter : Z;
  state_first_lifecycle_trigger_before_words : RawVec3Words;
  state_first_lifecycle_trigger_after_timer : Z;
  state_first_lifecycle_trigger_after_active : Z;
  state_first_lifecycle_trigger_after_counter : Z;
  state_first_lifecycle_trigger_after_words : RawVec3Words;

  state_first_lifecycle_a_pressed_frames : Z;
  state_first_lifecycle_a_down_frames : Z;
  state_first_lifecycle_controller_a_frames : Z
}.

Definition jp_area1_state_first_lifecycle_trace :
    Area1StateFirstLifecycleTrace :=
  {| state_first_lifecycle_explosion_timer := 513;
     state_first_lifecycle_explosion_slot := 61;
     state_first_lifecycle_explosion_active := 0;
     state_first_lifecycle_explosion_platform := 2150912504;
     state_first_lifecycle_explosion_free_depth := 0;
     state_first_lifecycle_explosion_mario_words :=
       raw_vec3_words 3304745090 1156620135 3292908471;

     state_first_lifecycle_first_apply_timer := 515;
     state_first_lifecycle_first_apply_area := 2;
     state_first_lifecycle_first_apply_active := 0;
     state_first_lifecycle_first_apply_platform := 2150912504;
     state_first_lifecycle_first_apply_free_depth := 47;
     state_first_lifecycle_first_apply_before_words :=
       raw_vec3_words 0 1168891904 1132462080;
     state_first_lifecycle_first_apply_after_words :=
       raw_vec3_words 1136053216 1168891904 3297319343;
     state_first_lifecycle_first_apply_object_words :=
       raw_vec3_words 0 1168891904 1132462080;
     state_first_lifecycle_first_apply_entry_seen := true;
     state_first_lifecycle_first_apply_return_seen := true;

     state_first_lifecycle_first_area2_poll_timer := 516;
     state_first_lifecycle_first_area2_poll_platform := 0;
     state_first_lifecycle_first_area2_words :=
       raw_vec3_words 1136053216 1168891904 3297319343;

     state_first_lifecycle_trigger_before_timer := 594;
     state_first_lifecycle_trigger_before_active := 257;
     state_first_lifecycle_trigger_before_counter := 0;
     state_first_lifecycle_trigger_before_words :=
       raw_vec3_words 1136866788 1165660160 3289674026;
     state_first_lifecycle_trigger_after_timer := 595;
     state_first_lifecycle_trigger_after_active := 0;
     state_first_lifecycle_trigger_after_counter := 1;
     state_first_lifecycle_trigger_after_words :=
       raw_vec3_words 1136914308 1165414400 3289593022;

     state_first_lifecycle_a_pressed_frames := 0;
     state_first_lifecycle_a_down_frames := 0;
     state_first_lifecycle_controller_a_frames := 0 |}.

Definition Area1StateFirstLifecycleTraceClaim : Prop :=
  state_first_lifecycle_explosion_timer
    jp_area1_state_first_lifecycle_trace = 513 /\
  state_first_lifecycle_explosion_slot
    jp_area1_state_first_lifecycle_trace = 61 /\
  state_first_lifecycle_explosion_active
    jp_area1_state_first_lifecycle_trace = 0 /\
  state_first_lifecycle_explosion_platform
    jp_area1_state_first_lifecycle_trace =
      state_first_trace_top_pointer jp_area1_state_first_retail_trace /\
  state_first_lifecycle_explosion_free_depth
    jp_area1_state_first_lifecycle_trace = 0 /\
  state_first_lifecycle_explosion_mario_words
    jp_area1_state_first_lifecycle_trace =
      raw_vec3_words 3304745090 1156620135 3292908471 /\
  state_first_lifecycle_first_apply_timer
    jp_area1_state_first_lifecycle_trace = 515 /\
  state_first_lifecycle_first_apply_area
    jp_area1_state_first_lifecycle_trace = 2 /\
  state_first_lifecycle_first_apply_active
    jp_area1_state_first_lifecycle_trace = 0 /\
  state_first_lifecycle_first_apply_platform
    jp_area1_state_first_lifecycle_trace =
      state_first_trace_top_pointer jp_area1_state_first_retail_trace /\
  state_first_lifecycle_first_apply_free_depth
    jp_area1_state_first_lifecycle_trace = 47 /\
  state_first_lifecycle_first_apply_before_words
    jp_area1_state_first_lifecycle_trace =
      raw_vec3_words 0 1168891904 1132462080 /\
  state_first_lifecycle_first_apply_after_words
    jp_area1_state_first_lifecycle_trace =
      raw_vec3_words 1136053216 1168891904 3297319343 /\
  state_first_lifecycle_first_apply_object_words
    jp_area1_state_first_lifecycle_trace =
      state_first_lifecycle_first_apply_before_words
        jp_area1_state_first_lifecycle_trace /\
  state_first_lifecycle_first_apply_entry_seen
    jp_area1_state_first_lifecycle_trace = true /\
  state_first_lifecycle_first_apply_return_seen
    jp_area1_state_first_lifecycle_trace = true /\
  state_first_lifecycle_first_area2_poll_timer
    jp_area1_state_first_lifecycle_trace = 516 /\
  state_first_lifecycle_first_area2_poll_platform
    jp_area1_state_first_lifecycle_trace = 0 /\
  state_first_lifecycle_first_area2_words
    jp_area1_state_first_lifecycle_trace =
      state_first_lifecycle_first_apply_after_words
        jp_area1_state_first_lifecycle_trace /\
  state_first_lifecycle_trigger_before_timer
    jp_area1_state_first_lifecycle_trace = 594 /\
  state_first_lifecycle_trigger_before_active
    jp_area1_state_first_lifecycle_trace = 257 /\
  state_first_lifecycle_trigger_before_counter
    jp_area1_state_first_lifecycle_trace = 0 /\
  state_first_lifecycle_trigger_before_words
    jp_area1_state_first_lifecycle_trace =
      raw_vec3_words 1136866788 1165660160 3289674026 /\
  state_first_lifecycle_trigger_after_timer
    jp_area1_state_first_lifecycle_trace = 595 /\
  state_first_lifecycle_trigger_after_active
    jp_area1_state_first_lifecycle_trace = 0 /\
  state_first_lifecycle_trigger_after_counter
    jp_area1_state_first_lifecycle_trace = 1 /\
  state_first_lifecycle_trigger_after_words
    jp_area1_state_first_lifecycle_trace =
      raw_vec3_words 1136914308 1165414400 3289593022 /\
  state_first_lifecycle_a_pressed_frames
    jp_area1_state_first_lifecycle_trace = 0 /\
  state_first_lifecycle_a_down_frames
    jp_area1_state_first_lifecycle_trace = 0 /\
  state_first_lifecycle_controller_a_frames
    jp_area1_state_first_lifecycle_trace = 0.

Theorem jp_area1_state_first_lifecycle_record_checked :
  Area1StateFirstLifecycleTraceClaim.
Proof.
  unfold Area1StateFirstLifecycleTraceClaim,
    jp_area1_state_first_lifecycle_trace,
    jp_area1_state_first_retail_trace.
  cbn.
  repeat split; reflexivity.
Qed.

(** The State input is finite and signed-32 representable, but its Y component
    is not signed-16 representable.  This boundary must therefore connect the
    authenticated target [trunc.w.s; mfc1; sh; lh] execution, not merely an
    ISO-C reading of the cast, to the exact narrowed query. *)
Definition Area1StateFirstConcreteShLhCastRefinementObligation
    (target_casts_to_query :
      RawVec3Words -> SignedTerrainQuery -> Prop) : Prop :=
  target_casts_to_query
    (state_first_trace_install_state_words
      jp_area1_state_first_retail_trace)
    (signed_terrain_query (-1862) 1778 (-902)).

(** Hash-gating and parsing the external trace are intentionally outside this
    transparent value receipt. *)
Definition Area1StateFirstRomLogAuthenticationObligation
    (authenticated_observation : Area1StateFirstRetailTrace -> Prop) : Prop :=
  authenticated_observation jp_area1_state_first_retail_trace.

Definition Area1StateFirstLifecycleRomLogAuthenticationObligation
    (authenticated_observation : Area1StateFirstLifecycleTrace -> Prop) : Prop :=
  authenticated_observation jp_area1_state_first_lifecycle_trace.

(** This is the end-to-end boundary: the concrete linked JP Clight execution
    must reach and produce precisely this observation from the injected
    prestate.  Clean gameplay reachability of that prestate is a further,
    separate obligation. *)
Definition Area1StateFirstLinkedClightExecutionObligation
    (executes_linked_observation : Area1StateFirstRetailTrace -> Prop) : Prop :=
  executes_linked_observation jp_area1_state_first_retail_trace.

Definition Area1StateFirstLifecycleLinkedClightExecutionObligation
    (executes_linked_observation : Area1StateFirstLifecycleTrace -> Prop) : Prop :=
  executes_linked_observation jp_area1_state_first_lifecycle_trace.
