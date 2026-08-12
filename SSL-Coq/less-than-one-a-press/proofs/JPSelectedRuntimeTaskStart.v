(** A concrete first [Clight.step2] from the initialized null-argument JP
    [thread5_game_loop] task boundary.  This is only the task entry step; it
    does not establish the later castle-routing or Area-1 execution prefix. *)

From Coq Require Import List.
From compcert Require Import AST Clight Coqlib Ctypes Events Globalenvs Maps
  Memory Values.
From LessThanOneAPress.Generated Require Import jp_game_init.
From LessThanOneAPress.Proofs Require Import
  GameTypes CleanedClightPrograms ClightEndToEndRefinement ClightRefinement
  SelectedClightTarget JPOfficialInitialMemory JPThread5EntryResolution.

Import ListNotations.

Definition jp_thread5_entry_temps : Clight.temp_env :=
  PTree.set jp_game_init._arg Vnullptr
    (Clight.create_undef_temps jp_game_init.f_thread5_game_loop.(fn_temps)).

Lemma jp_thread5_game_loop_function_entry2 :
  forall initial_memory,
    Clight.function_entry2
      (Clight.globalenv jp_official_cleaned_slice)
      jp_game_init.f_thread5_game_loop [Vnullptr] initial_memory
      Clight.empty_env jp_thread5_entry_temps initial_memory.
Proof.
  intros initial_memory. constructor; cbn.
  - constructor.
  - repeat constructor; cbn; congruence.
  - vm_compute. intuition congruence.
  - constructor.
  - unfold jp_thread5_entry_temps. reflexivity.
Qed.

Theorem jp_thread5_game_loop_has_first_step :
  forall initial_memory,
    exists next_state,
      Clight.step2 (Clight.globalenv jp_official_cleaned_slice)
        (Clight.Callstate (Internal jp_game_init.f_thread5_game_loop)
          [Vnullptr] Clight.Kstop initial_memory)
        E0 next_state.
Proof.
  intros initial_memory.
  exists (Clight.State jp_game_init.f_thread5_game_loop
    jp_game_init.f_thread5_game_loop.(fn_body) Clight.Kstop
    Clight.empty_env jp_thread5_entry_temps initial_memory).
  apply Clight.step_internal_function.
  exact (jp_thread5_game_loop_function_entry2 initial_memory).
Qed.

Theorem jp_selected_runtime_task_start_exists :
  exists state,
    SelectedRuntimeTaskStart VersionJP jp_official_cleaned_slice state.
Proof.
  destruct jp_official_cleaned_initial_memory_exists as
    [initial_memory Hinitial_memory].
  destruct jp_thread5_game_loop_resolves_exact_body as
    [entry_block [Hentry_symbol Hentry_body]].
  exists (Clight.Callstate (Internal jp_game_init.f_thread5_game_loop)
    [Vnullptr] Clight.Kstop initial_memory).
  exists initial_memory, entry_block, jp_game_init.f_thread5_game_loop.
  split; [exact Hinitial_memory |].
  split; [exact Hentry_symbol |].
  split; [exact Hentry_body |].
  split; [reflexivity |].
  destruct (jp_thread5_game_loop_has_first_step initial_memory)
    as [next_state Hstep].
  exists E0, next_state. exact Hstep.
Qed.

(** For JP the selected semantic source and target are definitionally the same
    official cleaned program.  The concrete task-start witness above therefore
    makes the identity lockstep nonvacuous.  This closes only the JP
    source-to-selected boundary, not the OS handoff or later Area-1 prefix. *)
Theorem jp_selected_target_source_refinement_checked :
  forall projection,
    projection_version projection = VersionJP ->
    projection_program projection = jp_official_cleaned_slice ->
    SelectedTargetSourceRefinementObligation projection.
Proof.
  intros projection Hversion Hprogram.
  unfold SelectedTargetSourceRefinementObligation.
  split.
  - rewrite Hversion. exact jp_normalized_cleaned_units_official_link_structural.
  - unfold WholeLinkedSourceToSelectedTargetRefinementObligation.
    rewrite Hversion, Hprogram. cbn.
    exists (clight_identity_lockstep_components jp_official_cleaned_slice).
    destruct jp_selected_runtime_task_start_exists as [state Hstart].
    exists state, state. split; [exact Hstart |].
    split; [exact Hstart | reflexivity].
Qed.
