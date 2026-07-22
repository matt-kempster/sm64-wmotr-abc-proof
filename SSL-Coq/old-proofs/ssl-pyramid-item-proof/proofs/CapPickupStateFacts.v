From Coq Require Import List.
Import ListNotations.
From compcert Require Import Clight.
From SSLPyramid.Generated Require Import
  area interaction level_update mario object_list_processor.
From SSLPyramid.Proofs Require Import
  ASTFacts OutsideObjectChannels TransitionFacts.

Module A := area.
Module I := interaction.
Module L := level_update.
Module M := mario.
Module O := object_list_processor.

Record cap_pickup_identity_audit := {
  cap_pickup_reads_cap_kind_from_object_behavior : bool;
  cap_pickup_writes_transient_interact_obj_from_cap : bool;
  cap_pickup_writes_held_obj : bool;
  cap_pickup_writes_used_obj : bool;
  cap_pickup_writes_ridden_obj : bool;
  cap_pickup_writes_mario_obj : bool;
  cap_pickup_writes_cap_timer : bool;
  cap_pickup_writes_mario_flags : bool;
  cap_pickup_mentions_cap_object_status_word : bool;
  cap_pickup_mentions_mario_obj_for_sound_origin : bool;
  cap_pickup_calls_spawn_object : bool;
  cap_pickup_calls_set_mario_action : bool;
  cap_pickup_calls_play_cap_music : bool
}.

Definition cap_pickup_generated_identity_audit
    : cap_pickup_identity_audit := {|
  cap_pickup_reads_cap_kind_from_object_behavior :=
    event_subsequenceb
      [Event_call I._get_mario_cap_flag]
      (statement_events_s (fn_body I.f_interact_cap));
  cap_pickup_writes_transient_interact_obj_from_cap :=
    event_subsequenceb
      [Event_assign_field_from_temp I._interactObj I._o]
      (statement_events_s (fn_body I.f_interact_cap));
  cap_pickup_writes_held_obj :=
    assigns_field_s I._heldObj (fn_body I.f_interact_cap);
  cap_pickup_writes_used_obj :=
    assigns_field_s I._usedObj (fn_body I.f_interact_cap);
  cap_pickup_writes_ridden_obj :=
    assigns_field_s I._riddenObj (fn_body I.f_interact_cap);
  cap_pickup_writes_mario_obj :=
    assigns_field_s I._marioObj (fn_body I.f_interact_cap);
  cap_pickup_writes_cap_timer :=
    assigns_field_s I._capTimer (fn_body I.f_interact_cap);
  cap_pickup_writes_mario_flags :=
    assigns_field_s I._flags (fn_body I.f_interact_cap);
  cap_pickup_mentions_cap_object_status_word :=
    statement_mentions_field_s I._asS32 (fn_body I.f_interact_cap);
  cap_pickup_mentions_mario_obj_for_sound_origin :=
    statement_mentions_field_s I._marioObj (fn_body I.f_interact_cap);
  cap_pickup_calls_spawn_object :=
    event_subsequenceb
      [Event_call I._spawn_object]
      (statement_events_s (fn_body I.f_interact_cap));
  cap_pickup_calls_set_mario_action :=
    event_subsequenceb
      [Event_call I._set_mario_action]
      (statement_events_s (fn_body I.f_interact_cap));
  cap_pickup_calls_play_cap_music :=
    event_subsequenceb
      [Event_call I._play_cap_music]
      (statement_events_s (fn_body I.f_interact_cap))
|}.

Theorem cap_pickup_generated_identity_audit_exact :
  cap_pickup_generated_identity_audit =
  {| cap_pickup_reads_cap_kind_from_object_behavior := true;
     cap_pickup_writes_transient_interact_obj_from_cap := true;
     cap_pickup_writes_held_obj := false;
     cap_pickup_writes_used_obj := false;
     cap_pickup_writes_ridden_obj := false;
     cap_pickup_writes_mario_obj := false;
     cap_pickup_writes_cap_timer := true;
     cap_pickup_writes_mario_flags := true;
     cap_pickup_mentions_cap_object_status_word := true;
     cap_pickup_mentions_mario_obj_for_sound_origin := true;
     cap_pickup_calls_spawn_object := false;
     cap_pickup_calls_set_mario_action := true;
     cap_pickup_calls_play_cap_music := true |}.
Proof. vm_compute; reflexivity. Qed.

Definition cap_pickup_durable_identity_reconstruction_risk : bool :=
  risk_direct_object_transfer cap_powerup_state_risk ||
  risk_stale_pointer_or_cloning cap_powerup_state_risk ||
  cap_pickup_writes_held_obj cap_pickup_generated_identity_audit ||
  cap_pickup_writes_used_obj cap_pickup_generated_identity_audit ||
  cap_pickup_writes_ridden_obj cap_pickup_generated_identity_audit ||
  cap_pickup_writes_mario_obj cap_pickup_generated_identity_audit ||
  cap_pickup_calls_spawn_object cap_pickup_generated_identity_audit.

Theorem cap_pickup_durable_identity_reconstruction_risk_is_false :
  cap_pickup_durable_identity_reconstruction_risk = false.
Proof. vm_compute; reflexivity. Qed.

Record cap_timer_update_identity_audit := {
  cap_timer_update_writes_cap_timer : bool;
  cap_timer_update_writes_mario_flags : bool;
  cap_timer_update_calls_spawn_object : bool;
  cap_timer_update_writes_held_obj : bool;
  cap_timer_update_writes_used_obj : bool;
  cap_timer_update_writes_ridden_obj : bool;
  cap_timer_update_writes_interact_obj : bool
}.

Definition generated_cap_timer_update_identity_audit
    : cap_timer_update_identity_audit := {|
  cap_timer_update_writes_cap_timer :=
    assigns_field_s M._capTimer
      (fn_body M.f_update_and_return_cap_flags);
  cap_timer_update_writes_mario_flags :=
    assigns_field_s M._flags
      (fn_body M.f_update_and_return_cap_flags);
  cap_timer_update_calls_spawn_object :=
    event_subsequenceb
      [Event_call M._spawn_object]
      (statement_events_s (fn_body M.f_update_and_return_cap_flags));
  cap_timer_update_writes_held_obj :=
    assigns_field_s M._heldObj
      (fn_body M.f_update_and_return_cap_flags);
  cap_timer_update_writes_used_obj :=
    assigns_field_s M._usedObj
      (fn_body M.f_update_and_return_cap_flags);
  cap_timer_update_writes_ridden_obj :=
    assigns_field_s M._riddenObj
      (fn_body M.f_update_and_return_cap_flags);
  cap_timer_update_writes_interact_obj :=
    assigns_field_s M._interactObj
      (fn_body M.f_update_and_return_cap_flags)
|}.

Theorem generated_cap_timer_update_identity_audit_exact :
  generated_cap_timer_update_identity_audit =
  {| cap_timer_update_writes_cap_timer := true;
     cap_timer_update_writes_mario_flags := true;
     cap_timer_update_calls_spawn_object := false;
     cap_timer_update_writes_held_obj := false;
     cap_timer_update_writes_used_obj := false;
     cap_timer_update_writes_ridden_obj := false;
     cap_timer_update_writes_interact_obj := false |}.
Proof. vm_compute; reflexivity. Qed.

Theorem cap_pickup_transient_interact_obj_not_observed_before_cleanup :
  statement_mentions_field_s L._interactObj
    (fn_body A.f_load_area) = false /\
  statement_mentions_field_s L._interactObj
    (fn_body A.f_load_mario_area) = false /\
  field_mentioners O.prog L._interactObj = [] /\
  statement_mentions_field_before_call_s L._init_mario L._interactObj
    (fn_body L.f_init_mario_after_warp) = false.
Proof. vm_compute; repeat split; reflexivity. Qed.

Theorem wing_cap_channels_are_cap_state_only_after_pickup_audit :
  map (fun classification =>
         (classified_channel_id classification,
          classified_route classification,
          risk_direct_object_transfer
            (classified_risk classification),
          risk_stale_pointer_or_cloning
            (classified_risk classification),
          risk_ordinary_state_only
            (classified_risk classification)))
      (filter
        (fun classification =>
           match classified_channel_id classification with
           | ChannelFirstWingCapBox
           | ChannelSecondWingCapBox
           | ChannelThirdWingCapBox => true
           | _ => false
           end)
        outside_pyramid_channel_classifications_shell_first) =
  [(ChannelFirstWingCapBox, CapTimerAndFlagsState, false, false, true);
   (ChannelSecondWingCapBox, CapTimerAndFlagsState, false, false, true);
   (ChannelThirdWingCapBox, CapTimerAndFlagsState, false, false, true)] /\
  cap_pickup_durable_identity_reconstruction_risk = false /\
  cap_pickup_writes_transient_interact_obj_from_cap
    cap_pickup_generated_identity_audit = true /\
  cap_timer_update_calls_spawn_object
    generated_cap_timer_update_identity_audit = false.
Proof. vm_compute; repeat split; reflexivity. Qed.
