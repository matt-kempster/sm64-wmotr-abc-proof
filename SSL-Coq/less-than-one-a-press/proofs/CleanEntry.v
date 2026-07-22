From Coq Require Import List ZArith.
From compcert Require Import Integers.
From LessThanOneAPress.Proofs Require Import
  GameTypes InputSemantics ObjectProvenance.

Local Open Scope Z_scope.

Definition valid_act (act : Int.int) : Prop :=
  1 <= Int.unsigned act <= 6.

Definition input_history_well_formed (s : GameState) : Prop :=
  state_current_buttons s = state_previous_buttons s.

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
  clean_triggers : no_trigger_consumed (state_triggers s);
  clean_puzzle_not_spawned : state_puzzle_star_spawned s = false;
  clean_no_act6_substitute : no_preexisting_act6_star s;
  clean_act3_static : act3_static_object_present s;
  clean_no_act3_substitute : no_preexisting_act3_substitute s;
  clean_hidden_controller : hidden_controller_present s;
  clean_target_provenance : target_provenance s;
  clean_macro_spawn : state_macro_spawn_valid s = true;
  clean_pool : state_pool_well_formed s = true;
  clean_lists : state_lists_well_formed s = true;
  clean_no_pending_interaction : state_pending_star_interaction s = false;
  clean_no_delayed_exit : state_delayed_star_exit s = false;
  clean_input_history : input_history_well_formed s;
  clean_platform : valid_platform_state s
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
