From Coq Require Import List ZArith.
From compcert Require Import Integers.
From LessThanOneAPress.Proofs Require Import
  GameTypes InputSemantics ObjectProvenance.

Local Open Scope Z_scope.

Definition valid_act (act : Int.int) : Prop :=
  1 <= Int.unsigned act <= 6.

Definition input_history_well_formed (s : GameState) : Prop :=
  state_entry_button_down s = state_first_frame_previous_down_seed s.

Record CleanPyramidEntry (s : GameState) : Prop := {
  clean_supported_version :
    state_version s = VersionUS \/ state_version s = VersionJP;
  clean_level : state_level s = ssl_level_id;
  clean_course : state_course s = ssl_course_id;
  clean_act : valid_act (state_act s);
  clean_area : state_area s = pyramid_area_id;
  clean_selected_entrance :
    state_entrance s = LowerEntrance \/ state_entrance s = UpperEntrance;
  clean_act3_bit : star_bit (state_save_flags s) act3_index = false;
  clean_act6_bit : star_bit (state_save_flags s) act6_index = false;
  clean_backup_save_coherent : target_save_coherent s;
  clean_triggers : no_trigger_consumed (state_triggers s);
  clean_puzzle_not_spawned : state_puzzle_star_spawned s = false;
  clean_no_act6_substitute : no_preexisting_act6_star s;
  clean_act3_static : act3_static_object_present s;
  clean_no_act3_substitute : no_preexisting_act3_substitute s;
  clean_hidden_controller : hidden_controller_present s;
  clean_target_provenance : target_provenance s;
  clean_hidden_trigger_provenance : hidden_trigger_provenance s;
  clean_all_hidden_triggers_present : all_hidden_trigger_objects_present s;
  clean_hidden_trigger_refs_distinct : hidden_trigger_refs_distinct s;
  clean_macro_spawn : macro_spawn_state_valid s;
  clean_pool : state_pool_well_formed s = true;
  clean_lists : state_lists_well_formed s = true;
  clean_no_pending_interaction : state_pending_star_interaction s = false;
  clean_no_delayed_exit : state_delayed_star_exit s = false;
  clean_input_history : input_history_well_formed s;
  clean_platform : valid_platform_state s;
  clean_entry_snapshot :
    entry_snapshot_for (state_entrance s) (state_entry_snapshot s);
  clean_current_kinematics :
    state_mario_kinematics s = entry_kinematics (state_entry_snapshot s)
}.

Theorem clean_entry_target_bits_clear :
  forall s, CleanPyramidEntry s ->
    ~ newly_collected (state_save_flags s) (state_save_flags s) act3_index /\
    ~ newly_collected (state_save_flags s) (state_save_flags s) act6_index.
Proof.
  intros s Hclean. split; intro Hnew; destruct Hnew as [_ Hset].
  - rewrite (clean_act3_bit s Hclean) in Hset. discriminate.
  - rewrite (clean_act6_bit s Hclean) in Hset. discriminate.
Qed.

(* save_file_reload copies the backup slot over the active slot.  A clean
   entry represents a normally loaded coherent save, so this copy cannot be
   the first operation that sets either target bit. *)
Theorem clean_entry_backup_target_bits_clear :
  forall s, CleanPyramidEntry s ->
    star_bit (state_backup_save_flags s) act3_index = false /\
    star_bit (state_backup_save_flags s) act6_index = false.
Proof.
  intros s Hclean.
  pose proof (clean_backup_save_coherent s Hclean) as Hcoherent.
  unfold target_save_coherent in Hcoherent.
  split.
  - rewrite <- (proj1 Hcoherent).
    exact (clean_act3_bit s Hclean).
  - rewrite <- (proj2 Hcoherent).
    exact (clean_act6_bit s Hclean).
Qed.

Theorem clean_entry_save_reload_cannot_collect_target :
  forall s, CleanPyramidEntry s ->
    ~ newly_collected
        (state_save_flags s) (state_backup_save_flags s) act3_index /\
    ~ newly_collected
        (state_save_flags s) (state_backup_save_flags s) act6_index.
Proof.
  intros s Hclean.
  pose proof (clean_entry_backup_target_bits_clear s Hclean)
    as [Hbackup3 Hbackup6].
  split; intros [_ Hset].
  - rewrite Hbackup3 in Hset. discriminate.
  - rewrite Hbackup6 in Hset. discriminate.
Qed.

Theorem clean_entry_all_five_macro_respawn_bits_clear :
  forall s, CleanPyramidEntry s ->
    no_trigger_consumed (state_macro_respawn_state s).
Proof.
  intros s Hclean trigger.
  rewrite (clean_macro_spawn s Hclean trigger).
  - apply (clean_triggers s Hclean trigger).
  - destruct trigger; unfold all_hidden_triggers; simpl; tauto.
Qed.

Theorem clean_entry_active_trigger_is_fully_unconsumed :
  forall s trigger o,
    CleanPyramidEntry s ->
    valid_hidden_trigger_object s trigger o ->
    state_triggers s trigger = false /\
    state_macro_respawn_state s trigger = false /\
    object_macro_respawn_consumed o = false.
Proof.
  intros s trigger o _
    (_ & _ & _ & _ & _ & _ & _ & _ & _ & _ &
     Htrigger & Hmacro & Hobject).
  exact (conj Htrigger (conj Hmacro Hobject)).
Qed.
