From Coq Require Import Bool Lia List ZArith.
From SSLEyerok.Proofs Require Import HeightMilestones MarioHandContact.

Import ListNotations.
Local Open Scope Z_scope.

(** Exact integer arithmetic for the source-audited attack/reboard schedules.
    Heights are relative to the hand's home Y unless a theorem says
    [absolute].  The negative lethal result in this module is deliberately
    scoped to Mario's ordinary -4-gravity bounce trace.  In particular,
    ACT_LONG_JUMP keeps -2 gravity after [interact_bounce_top], so it has a
    later vertical re-entry window formalized below.  This module proves the
    timing, floor-buffer, and interior-witness arithmetic; the source audit
    supplies the update order, mesh writes, animation length, interaction
    branches, and action-specific gravity constants. *)

(** The narrow branch where a candidate floor is above Mario's query point,
    but by no more than the source's 78-unit tolerance.  This predicate is a
    necessary vertical filter only; X/Z containment, floor priority, the
    quarter-step result, and action-specific landing or snap logic are all
    separate. *)
Definition floor_above_query_within_buffer (query_y floor_y : Z) : Prop :=
  0 <= floor_y - query_y <= floor_query_vertical_buffer.

Definition nonlethal_positive_origin_trace : list Z :=
  [26; 48; 66; 80; 90; 96; 98].

Definition nonlethal_complete_origin_trace : list Z :=
  [26; 48; 66; 80; 90; 96; 98; 96; 90; 80; 66; 48; 26; 0; 0].

(** Mario's position after the automatic second bounce and each subsequent
    air step, ending at the entry position of the frame where ATTACKED changes
    to RECOVER and installs the closed mesh.  This is specifically the
    standard [-4]-gravity trace; it is not a quantification over every Mario
    action that [interact_bounce_top] can preserve. *)
Definition standard_gravity_nonlethal_second_bounce_mario_trace : list Z :=
  [180; 206; 228; 246; 260; 270; 276; 278; 276; 270; 260].

(** Every airborne frame in the standard [-4]-gravity lethal response,
    including the home-height row immediately before the ground flag sets.
    At the second automatic bounce we use the smaller, more favorable
    post-bounce gap 357 even though the frame's actual floor query occurred
    earlier with a larger gap. *)
Definition standard_gravity_lethal_airborne_floor_gaps : list Z :=
  [347; 367; 387; 407; 427; 447; 357; 345; 333; 321; 309; 297; 285;
   273; 261; 249; 237; 225; 213; 201; 189; 177; 165; 153].

Definition standard_gravity_lethal_first_grounded_gap : Z := 191.

(** In an inherited ACT_LONG_JUMP, Mario keeps -2 gravity after the automatic
    30-unit bounce.  The source-shaped lethal schedule has late open-top gaps
    63 and 7.  Both pass the vertical 78-unit filter, so the standard-gravity
    153-unit argument is not a universal impossibility proof. *)
Definition lethal_long_jump_late_open_top_gaps : list Z := [63; 7].

Definition open_side_wall_entry_distance : Z := 50.
Definition air_quarter_divisor : Z := 4.
Definition one_quarter_fifty_unit_crossing_speed : Z :=
  air_quarter_divisor * open_side_wall_entry_distance.

Definition eyerok_home_y : Z := -1534.
Definition closed_reboard_relative_y : Z := 306.
Definition standard_gravity_recovery_mario_query_y : Z := 260.
Definition standard_gravity_recovery_closed_top_gap : Z :=
  closed_reboard_relative_y - standard_gravity_recovery_mario_query_y.

(** These constants transcribe the independently recorded inherited-
    ACT_LONG_JUMP fixture.  The lemmas below certify only the exact height
    arithmetic of those observations.  They do not derive the fixture from
    controller input, execute the C semantics, or prove that the trace is
    reachable from the start of the fight. *)
Definition recorded_nonlethal_open_reboard_floor_absolute_y : Z := -1027.
Definition recorded_recovery_closed_floor_absolute_y : Z := -1228.
Definition recorded_target_mario_origin_rise : Z := 300.
Definition recorded_target_mario_closed_floor_absolute_y : Z := -928.
Definition area3_tunnel_upward_floor_min_absolute_y : Z := -562.
Definition area3_tunnel_floor_query_min_absolute_y : Z :=
  area3_tunnel_upward_floor_min_absolute_y - floor_query_vertical_buffer.

(** Both local normal-double catches use a 20-unit initial Mario velocity and
    the ordinary [-4] air-gravity schedule, whose positive displacements sum
    to 60.  Applying that same narrow suffix envelope at the recorded later
    TARGET_MARIO top still cannot reach the tunnel floor's query threshold.
    This says nothing about other actions or externally supplied impulses. *)
Definition local_twenty_launch_positive_rise : Z := 60.
Definition recorded_target_plus_local_twenty_launch_peak : Z :=
  recorded_target_mario_closed_floor_absolute_y +
    local_twenty_launch_positive_rise.

(** The lethal inherited-long-jump fixture reaches the vertical windows
    [63;7] at hand-relative world Z=127.  The open top's positive-Z source
    extent is 51, hence 51*1.5=76.5 after the hand transform.  Doubled world
    coordinates preserve the half unit exactly. *)
Definition recorded_lethal_hand_relative_world_z_twice : Z := 254.
Definition scaled_open_top_positive_z_extent_twice : Z := 153.

(** In the recorded lethal long-jump schedule, the hand is already grounded
    at home and retains the open top at absolute Y=-1027.  On its last live
    timer-39 row Mario is at -984 with velocity -22.  A hypothetical next
    Mario update would reach only -1006; the following -24 update would cross
    the top at -1030, but the DIE handler deletes the surface first.  Rocq
    certifies only this arithmetic.  The runtime analyzer and source audit
    supply the selected-floor/platform observations and deletion order. *)
Definition recorded_lethal_final_live_mario_absolute_y : Z := -984.
Definition recorded_lethal_final_live_mario_velocity_y : Z := -22.
Definition recorded_lethal_projected_next_mario_absolute_y : Z :=
  recorded_lethal_final_live_mario_absolute_y +
    recorded_lethal_final_live_mario_velocity_y.
Definition recorded_lethal_projected_second_velocity_y : Z := -24.
Definition recorded_lethal_projected_second_mario_absolute_y : Z :=
  recorded_lethal_projected_next_mario_absolute_y +
    recorded_lethal_projected_second_velocity_y.

(** Source-audited SLIDE_KICK initialization raises forward speed to at least
    32.  Its own wall case is stronger than this arithmetic observation: any
    AIR_STEP_HIT_WALL writes BACKWARD_AIR_KB. *)
Definition slow_common_air_wall_limit : Z := 16.
Definition slide_kick_entry_min_forward_speed : Z := 32.

Lemma nonlethal_attack_origin_peak_is_98 :
  Forall (fun y => y <= 98) nonlethal_positive_origin_trace /\
  In 98 nonlethal_positive_origin_trace.
Proof.
  split.
  - repeat constructor; lia.
  - cbn. tauto.
Qed.

Lemma nonlethal_complete_origin_trace_ends_at_home :
  last nonlethal_complete_origin_trace 0 = 0.
Proof. reflexivity. Qed.

Lemma standard_gravity_open_mesh_rejects_listed_second_bounce_arc :
  Forall
    (fun mario_y =>
      ~ floor_above_query_within_buffer mario_y open_hand_top_offset)
    standard_gravity_nonlethal_second_bounce_mario_trace.
Proof.
  unfold standard_gravity_nonlethal_second_bounce_mario_trace,
    floor_above_query_within_buffer,
    open_hand_top_offset, floor_query_vertical_buffer.
  repeat constructor; lia.
Qed.

(** This is conditional height eligibility only: if Mario has query Y=260
    when RECOVER installs the grounded closed top at relative Y=306, the
    46-unit gap passes the source's vertical filter.  It does not prove that
    the floor query selects the hand, that a snap occurs, or that the listed
    state is reached.  In particular, the baseline ROM fixture fell to the
    arena and did not reboard. *)
Lemma standard_gravity_recovery_closed_top_is_height_eligible :
  standard_gravity_recovery_closed_top_gap = 46 /\
  floor_above_query_within_buffer
    standard_gravity_recovery_mario_query_y closed_reboard_relative_y.
Proof.
  unfold standard_gravity_recovery_closed_top_gap,
    standard_gravity_recovery_mario_query_y, closed_reboard_relative_y,
    floor_above_query_within_buffer, floor_query_vertical_buffer. lia.
Qed.

Lemma grounded_closed_top_absolute_y_is_minus_1228 :
  eyerok_home_y + closed_reboard_relative_y = -1228.
Proof. reflexivity. Qed.

Lemma recorded_nonlethal_long_jump_height_arithmetic :
  eyerok_home_y + open_hand_top_offset =
    recorded_nonlethal_open_reboard_floor_absolute_y /\
  eyerok_home_y + closed_hand_top_offset =
    recorded_recovery_closed_floor_absolute_y /\
  eyerok_home_y + recorded_target_mario_origin_rise +
      closed_hand_top_offset =
    recorded_target_mario_closed_floor_absolute_y /\
  area3_tunnel_floor_query_min_absolute_y = -640 /\
  recorded_target_mario_closed_floor_absolute_y <
    area3_tunnel_floor_query_min_absolute_y /\
  recorded_target_plus_local_twenty_launch_peak = -868 /\
  recorded_target_plus_local_twenty_launch_peak <
    area3_tunnel_floor_query_min_absolute_y.
Proof.
  unfold eyerok_home_y, open_hand_top_offset, closed_hand_top_offset,
    recorded_nonlethal_open_reboard_floor_absolute_y,
    recorded_recovery_closed_floor_absolute_y,
    recorded_target_mario_origin_rise,
    recorded_target_mario_closed_floor_absolute_y,
    recorded_target_plus_local_twenty_launch_peak,
    local_twenty_launch_positive_rise,
    area3_tunnel_floor_query_min_absolute_y,
    area3_tunnel_upward_floor_min_absolute_y,
    floor_query_vertical_buffer.
  repeat split; lia.
Qed.

Lemma standard_gravity_lethal_airborne_open_mesh_never_passes_floor_buffer :
  Forall (fun gap => floor_query_vertical_buffer < gap)
    standard_gravity_lethal_airborne_floor_gaps.
Proof.
  unfold standard_gravity_lethal_airborne_floor_gaps,
    floor_query_vertical_buffer.
  repeat constructor; lia.
Qed.

Lemma standard_gravity_lethal_first_grounded_gap_exceeds_floor_buffer :
  floor_query_vertical_buffer < standard_gravity_lethal_first_grounded_gap.
Proof. reflexivity. Qed.

Lemma long_jump_late_open_top_gaps_pass_vertical_filter :
  Forall
    (fun gap => 0 <= gap <= floor_query_vertical_buffer)
    lethal_long_jump_late_open_top_gaps.
Proof.
  unfold lethal_long_jump_late_open_top_gaps,
    floor_query_vertical_buffer.
  repeat constructor; lia.
Qed.

Lemma recorded_lethal_long_jump_is_outside_open_top_z_extent :
  scaled_open_top_positive_z_extent_twice <
    recorded_lethal_hand_relative_world_z_twice.
Proof. reflexivity. Qed.

Lemma recorded_lethal_long_jump_needs_two_more_vertical_updates :
  recorded_lethal_final_live_mario_absolute_y -
      recorded_nonlethal_open_reboard_floor_absolute_y = 43 /\
  recorded_lethal_projected_next_mario_absolute_y = -1006 /\
  recorded_lethal_projected_next_mario_absolute_y -
      recorded_nonlethal_open_reboard_floor_absolute_y = 21 /\
  recorded_lethal_projected_second_mario_absolute_y = -1030 /\
  recorded_lethal_projected_second_mario_absolute_y <
      recorded_nonlethal_open_reboard_floor_absolute_y.
Proof. repeat split; reflexivity. Qed.

Lemma slide_kick_entry_speed_exceeds_slow_common_air_wall_limit :
  slow_common_air_wall_limit < slide_kick_entry_min_forward_speed.
Proof. reflexivity. Qed.

(** Covering 50 units in one of four equal arithmetic quarter steps requires
    whole-frame speed 200.  This is not an exact wall-solver threshold: wall
    normals, quarter-step truncation, collision pushes, and steering are not
    represented here. *)
Lemma one_quarter_fifty_unit_crossing_speed_is_two_hundred :
  one_quarter_fifty_unit_crossing_speed = 200.
Proof. reflexivity. Qed.

Lemma two_hundred_four_exceeds_one_quarter_fifty_unit_crossing_speed :
  one_quarter_fifty_unit_crossing_speed < 204.
Proof. reflexivity. Qed.

Definition source_audit_records_automatic_top_hit_reads_a : bool := false.

(** The first conjunct records the independent source-audit premise; this
    arithmetic module does not derive the C control-flow fact itself. *)
Lemma recorded_automatic_top_hit_a_gate_is_absent :
  source_audit_records_automatic_top_hit_reads_a = false /\
  (forall schedule frame,
    always_released_a schedule -> ~ a_press_edge schedule frame) /\
  (forall schedule frame,
    continuously_held_a schedule -> ~ a_press_edge schedule frame).
Proof.
  split.
  - reflexivity.
  - split.
    + exact always_released_has_no_press_edge.
    + exact continuously_held_has_no_press_edge.
Qed.

Definition attacked_reboard_certificate : Prop :=
  Forall (fun y => y <= 98) nonlethal_positive_origin_trace /\
  In 98 nonlethal_positive_origin_trace /\
  last nonlethal_complete_origin_trace 0 = 0 /\
  Forall
    (fun mario_y =>
      ~ floor_above_query_within_buffer mario_y open_hand_top_offset)
    standard_gravity_nonlethal_second_bounce_mario_trace /\
  standard_gravity_recovery_closed_top_gap = 46 /\
  floor_above_query_within_buffer
    standard_gravity_recovery_mario_query_y closed_reboard_relative_y /\
  eyerok_home_y + closed_reboard_relative_y = -1228 /\
  eyerok_home_y + open_hand_top_offset =
    recorded_nonlethal_open_reboard_floor_absolute_y /\
  eyerok_home_y + closed_hand_top_offset =
    recorded_recovery_closed_floor_absolute_y /\
  eyerok_home_y + recorded_target_mario_origin_rise +
      closed_hand_top_offset =
    recorded_target_mario_closed_floor_absolute_y /\
  area3_tunnel_floor_query_min_absolute_y = -640 /\
  recorded_target_mario_closed_floor_absolute_y <
    area3_tunnel_floor_query_min_absolute_y /\
  recorded_target_plus_local_twenty_launch_peak = -868 /\
  recorded_target_plus_local_twenty_launch_peak <
    area3_tunnel_floor_query_min_absolute_y /\
  Forall (fun gap => floor_query_vertical_buffer < gap)
    standard_gravity_lethal_airborne_floor_gaps /\
  floor_query_vertical_buffer < standard_gravity_lethal_first_grounded_gap /\
  Forall
    (fun gap => 0 <= gap <= floor_query_vertical_buffer)
    lethal_long_jump_late_open_top_gaps /\
  scaled_open_top_positive_z_extent_twice <
    recorded_lethal_hand_relative_world_z_twice /\
  recorded_lethal_final_live_mario_absolute_y -
      recorded_nonlethal_open_reboard_floor_absolute_y = 43 /\
  recorded_lethal_projected_next_mario_absolute_y = -1006 /\
  recorded_lethal_projected_next_mario_absolute_y -
      recorded_nonlethal_open_reboard_floor_absolute_y = 21 /\
  recorded_lethal_projected_second_mario_absolute_y = -1030 /\
  recorded_lethal_projected_second_mario_absolute_y <
      recorded_nonlethal_open_reboard_floor_absolute_y /\
  slow_common_air_wall_limit < slide_kick_entry_min_forward_speed /\
  one_quarter_fifty_unit_crossing_speed = 200 /\
  one_quarter_fifty_unit_crossing_speed < 204 /\
  source_audit_records_automatic_top_hit_reads_a = false.

Theorem attacked_reboard_certificate_holds :
  attacked_reboard_certificate.
Proof.
  unfold attacked_reboard_certificate.
  refine (conj (proj1 nonlethal_attack_origin_peak_is_98) _).
  refine (conj (proj2 nonlethal_attack_origin_peak_is_98) _).
  refine (conj nonlethal_complete_origin_trace_ends_at_home _).
  refine (conj
    standard_gravity_open_mesh_rejects_listed_second_bounce_arc _).
  refine (conj
    (proj1 standard_gravity_recovery_closed_top_is_height_eligible) _).
  refine (conj
    (proj2 standard_gravity_recovery_closed_top_is_height_eligible) _).
  refine (conj grounded_closed_top_absolute_y_is_minus_1228 _).
  destruct recorded_nonlethal_long_jump_height_arithmetic as
    (Hopen & Hrecover & Htarget & Hquery & Hbelow & Hsuffix & Hsuffix_below).
  refine (conj Hopen _).
  refine (conj Hrecover _).
  refine (conj Htarget _).
  refine (conj Hquery _).
  refine (conj Hbelow _).
  refine (conj Hsuffix _).
  refine (conj Hsuffix_below _).
  refine (conj
    standard_gravity_lethal_airborne_open_mesh_never_passes_floor_buffer _).
  refine (conj
    standard_gravity_lethal_first_grounded_gap_exceeds_floor_buffer _).
  refine (conj long_jump_late_open_top_gaps_pass_vertical_filter _).
  refine (conj recorded_lethal_long_jump_is_outside_open_top_z_extent _).
  destruct recorded_lethal_long_jump_needs_two_more_vertical_updates as
    (Hfinal & Hnext & Hnext_gap & Hsecond & Hsecond_cross).
  refine (conj Hfinal _).
  refine (conj Hnext _).
  refine (conj Hnext_gap _).
  refine (conj Hsecond _).
  refine (conj Hsecond_cross _).
  refine (conj
    slide_kick_entry_speed_exceeds_slow_common_air_wall_limit _).
  refine (conj
    one_quarter_fifty_unit_crossing_speed_is_two_hundred _).
  refine (conj
    two_hundred_four_exceeds_one_quarter_fifty_unit_crossing_speed _).
  repeat split; assumption || reflexivity.
Qed.
