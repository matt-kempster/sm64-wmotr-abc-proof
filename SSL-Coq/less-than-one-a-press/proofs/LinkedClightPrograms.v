From Coq Require Import List.
From compcert Require Import AST Clight Coqlib Ctypes Linking.
From LessThanOneAPress.Generated Require Import
  us_game_init us_mario
  us_mario_actions_airborne us_mario_actions_automatic
  us_mario_actions_cutscene us_mario_actions_moving
  us_mario_actions_object us_mario_actions_stationary
  us_mario_actions_submerged us_mario_step us_interaction us_save_file
  us_object_collision us_object_list_processor us_behavior_script
  us_level_script us_graph_node us_rendering_graph_node us_spawn_object
  us_object_helpers us_debug us_memory us_mario_misc us_obj_behaviors
  us_obj_behaviors_2 us_behavior_actions us_behavior_data us_area
  us_level_update us_platform_displacement us_math_util
  us_surface_collision us_surface_load us_macro_special_objects
  us_ssl_script us_ssl_area1_macro us_ssl_area2_macro us_ssl_collision
  jp_game_init jp_mario
  jp_mario_actions_airborne jp_mario_actions_automatic
  jp_mario_actions_cutscene jp_mario_actions_moving
  jp_mario_actions_object jp_mario_actions_stationary
  jp_mario_actions_submerged jp_mario_step jp_interaction jp_save_file
  jp_object_collision jp_object_list_processor jp_behavior_script
  jp_level_script jp_graph_node jp_rendering_graph_node jp_spawn_object
  jp_object_helpers jp_debug jp_memory jp_mario_misc jp_obj_behaviors
  jp_obj_behaviors_2 jp_behavior_actions jp_behavior_data jp_area
  jp_level_update jp_platform_displacement jp_math_util
  jp_surface_collision jp_surface_load jp_macro_special_objects
  jp_ssl_script jp_ssl_area1_macro jp_ssl_area2_macro jp_ssl_collision.

(** CompCert's [Ctypes.link_program] contains a proof-produced composite
    environment, so the executable compatibility checks are audited through
    its AST-program and composite-definition projections.  The projection
    theorem below lets a failed AST check refute an actual Clight link result;
    no hand-written merged program is substituted. *)

Fixpoint map_nlist {A B : Type} (f : A -> B) (xs : nlist A) : nlist B :=
  match xs with
  | nbase x => nbase (f x)
  | ncons x rest => ncons (f x) (map_nlist f rest)
  end.

Definition program_components (p : Clight.program) : AST.program Clight.fundef type :=
  Ctypes.program_of_program p.

Definition composite_components (p : Clight.program) :
    list Ctypes.composite_definition := Ctypes.prog_types p.

Lemma clight_link_projects_program_components :
  forall (p q linked : Clight.program),
    link p q = Some linked ->
    link (program_components p) (program_components q) =
    Some (program_components linked).
Proof.
  intros p q linked Hlink.
  Local Transparent Ctypes.Linker_program.
  unfold link, Ctypes.Linker_program, Ctypes.link_program in Hlink.
  destruct (link (Ctypes.program_of_program p) (Ctypes.program_of_program q))
    as [ap |] eqn:Hast; try discriminate.
  destruct (Ctypes.lift_option
    (link (Ctypes.prog_types p) (Ctypes.prog_types q)))
    as [[typs Htypes] | Htypes]; try discriminate.
  destruct (Ctypes.link_build_composite_env
    (Ctypes.prog_types p) (Ctypes.prog_types q) typs
    (Ctypes.prog_comp_env p) (Ctypes.prog_comp_env q)
    (Ctypes.prog_comp_env_eq p) (Ctypes.prog_comp_env_eq q)
    Htypes) as (env & Henv & Hextends).
  inversion Hlink; subst linked.
  destruct ap.
  exact Hast.
Qed.

Lemma clight_link_list_projects_program_components :
  forall (units : nlist Clight.program) linked,
    link_list units = Some linked ->
    link_list (map_nlist program_components units) =
    Some (program_components linked).
Proof.
  induction units as [unit | unit rest IH]; cbn.
  - intros linked Hlink. now inversion Hlink.
  - intros linked Hlink.
    destruct (link_list rest) as [rest_linked |] eqn:Hrest; try discriminate.
    specialize (IH rest_linked eq_refl).
    rewrite IH.
    eapply clight_link_projects_program_components.
    exact Hlink.
Qed.

Definition us_units : nlist Clight.program :=
  ncons us_game_init.prog
  (ncons us_mario.prog
  (ncons us_mario_actions_airborne.prog
  (ncons us_mario_actions_automatic.prog
  (ncons us_mario_actions_cutscene.prog
  (ncons us_mario_actions_moving.prog
  (ncons us_mario_actions_object.prog
  (ncons us_mario_actions_stationary.prog
  (ncons us_mario_actions_submerged.prog
  (ncons us_mario_step.prog
  (ncons us_interaction.prog
  (ncons us_save_file.prog
  (ncons us_object_collision.prog
  (ncons us_object_list_processor.prog
  (ncons us_behavior_script.prog
  (ncons us_level_script.prog
  (ncons us_graph_node.prog
  (ncons us_rendering_graph_node.prog
  (ncons us_spawn_object.prog
  (ncons us_object_helpers.prog
  (ncons us_debug.prog
  (ncons us_memory.prog
  (ncons us_mario_misc.prog
  (ncons us_obj_behaviors.prog
  (ncons us_obj_behaviors_2.prog
  (ncons us_behavior_actions.prog
  (ncons us_behavior_data.prog
  (ncons us_area.prog
  (ncons us_level_update.prog
  (ncons us_platform_displacement.prog
  (ncons us_math_util.prog
  (ncons us_surface_collision.prog
  (ncons us_surface_load.prog
  (ncons us_macro_special_objects.prog
  (ncons us_ssl_script.prog
  (ncons us_ssl_area1_macro.prog
  (ncons us_ssl_area2_macro.prog
    (nbase us_ssl_collision.prog))))))))))))))))))))))))))))))))))))).

Definition jp_units : nlist Clight.program :=
  ncons jp_game_init.prog
  (ncons jp_mario.prog
  (ncons jp_mario_actions_airborne.prog
  (ncons jp_mario_actions_automatic.prog
  (ncons jp_mario_actions_cutscene.prog
  (ncons jp_mario_actions_moving.prog
  (ncons jp_mario_actions_object.prog
  (ncons jp_mario_actions_stationary.prog
  (ncons jp_mario_actions_submerged.prog
  (ncons jp_mario_step.prog
  (ncons jp_interaction.prog
  (ncons jp_save_file.prog
  (ncons jp_object_collision.prog
  (ncons jp_object_list_processor.prog
  (ncons jp_behavior_script.prog
  (ncons jp_level_script.prog
  (ncons jp_graph_node.prog
  (ncons jp_rendering_graph_node.prog
  (ncons jp_spawn_object.prog
  (ncons jp_object_helpers.prog
  (ncons jp_debug.prog
  (ncons jp_memory.prog
  (ncons jp_mario_misc.prog
  (ncons jp_obj_behaviors.prog
  (ncons jp_obj_behaviors_2.prog
  (ncons jp_behavior_actions.prog
  (ncons jp_behavior_data.prog
  (ncons jp_area.prog
  (ncons jp_level_update.prog
  (ncons jp_platform_displacement.prog
  (ncons jp_math_util.prog
  (ncons jp_surface_collision.prog
  (ncons jp_surface_load.prog
  (ncons jp_macro_special_objects.prog
  (ncons jp_ssl_script.prog
  (ncons jp_ssl_area1_macro.prog
  (ncons jp_ssl_area2_macro.prog
    (nbase jp_ssl_collision.prog))))))))))))))))))))))))))))))))))))).

Definition option_is_some {A : Type} (value : option A) : bool :=
  match value with Some _ => true | None => false end.

Definition us_ast_link_succeeds : bool :=
  option_is_some (link_list (map_nlist program_components us_units)).

Definition us_composite_link_succeeds : bool :=
  option_is_some (link_list (map_nlist composite_components us_units)).

Definition jp_ast_link_succeeds : bool :=
  option_is_some (link_list (map_nlist program_components jp_units)).

Definition jp_composite_link_succeeds : bool :=
  option_is_some (link_list (map_nlist composite_components jp_units)).

Inductive program_link_audit : Type :=
| ProgramLinkSuccess : AST.program Clight.fundef type -> program_link_audit
| ProgramLinkFailure : nat -> program_link_audit.

Fixpoint audit_program_links
    (units : nlist (AST.program Clight.fundef type)) : program_link_audit :=
  match units with
  | nbase unit => ProgramLinkSuccess unit
  | ncons unit rest =>
      match audit_program_links rest with
      | ProgramLinkFailure distance => ProgramLinkFailure (S distance)
      | ProgramLinkSuccess linked =>
          match link unit linked with
          | Some result => ProgramLinkSuccess result
          | None => ProgramLinkFailure O
          end
      end
  end.

Inductive composite_link_audit : Type :=
| CompositeLinkSuccess :
    list Ctypes.composite_definition -> composite_link_audit
| CompositeLinkFailure : nat -> composite_link_audit.

Fixpoint audit_composite_links
    (units : nlist (list Ctypes.composite_definition)) :
    composite_link_audit :=
  match units with
  | nbase unit => CompositeLinkSuccess unit
  | ncons unit rest =>
      match audit_composite_links rest with
      | CompositeLinkFailure distance => CompositeLinkFailure (S distance)
      | CompositeLinkSuccess linked =>
          match link unit linked with
          | Some result => CompositeLinkSuccess result
          | None => CompositeLinkFailure O
          end
      end
  end.

Theorem us_ast_link_fails_checked : us_ast_link_succeeds = false.
Proof. vm_compute. reflexivity. Qed.

Theorem us_composite_link_fails_checked :
  us_composite_link_succeeds = false.
Proof. vm_compute. reflexivity. Qed.

Theorem jp_ast_link_fails_checked : jp_ast_link_succeeds = false.
Proof. vm_compute. reflexivity. Qed.

Theorem jp_composite_link_fails_checked :
  jp_composite_link_succeeds = false.
Proof. vm_compute. reflexivity. Qed.

Theorem us_ast_link_is_none :
  link_list (map_nlist program_components us_units) = None.
Proof. vm_compute. reflexivity. Qed.

Theorem jp_ast_link_is_none :
  link_list (map_nlist program_components jp_units) = None.
Proof. vm_compute. reflexivity. Qed.

Theorem us_first_ast_link_failure_checked :
  audit_program_links (map_nlist program_components us_units) =
  ProgramLinkFailure 34%nat.
Proof. vm_compute. reflexivity. Qed.

Theorem jp_first_ast_link_failure_checked :
  audit_program_links (map_nlist program_components jp_units) =
  ProgramLinkFailure 34%nat.
Proof. vm_compute. reflexivity. Qed.

Theorem us_first_composite_link_failure_checked :
  audit_composite_links (map_nlist composite_components us_units) =
  CompositeLinkFailure 27%nat.
Proof. vm_compute. reflexivity. Qed.

Theorem jp_first_composite_link_failure_checked :
  audit_composite_links (map_nlist composite_components jp_units) =
  CompositeLinkFailure 27%nat.
Proof. vm_compute. reflexivity. Qed.

Theorem us_compcert_clight_link_list_has_no_result :
  forall linked, link_list us_units <> Some linked.
Proof.
  intros linked Hlinked.
  pose proof
    (clight_link_list_projects_program_components us_units linked Hlinked)
    as Hcomponents.
  rewrite us_ast_link_is_none in Hcomponents.
  discriminate.
Qed.

Theorem jp_compcert_clight_link_list_has_no_result :
  forall linked, link_list jp_units <> Some linked.
Proof.
  intros linked Hlinked.
  pose proof
    (clight_link_list_projects_program_components jp_units linked Hlinked)
    as Hcomponents.
  rewrite jp_ast_link_is_none in Hcomponents.
  discriminate.
Qed.

Fixpoint nlist_length {A : Type} (units : nlist A) : nat :=
  match units with
  | nbase _ => 1%nat
  | ncons _ rest => S (nlist_length rest)
  end.

Record GeneratedClightCoverageManifest : Type := {
  coverage_units : nlist Clight.program;
  coverage_unit_count : nat;
  coverage_count_exact : nlist_length coverage_units = coverage_unit_count;
  coverage_ast_link_succeeds : bool;
  coverage_composite_link_succeeds : bool
}.

Definition us_generated_coverage_manifest : GeneratedClightCoverageManifest :=
  {| coverage_units := us_units;
     coverage_unit_count := 38%nat;
     coverage_count_exact := eq_refl;
     coverage_ast_link_succeeds := us_ast_link_succeeds;
     coverage_composite_link_succeeds := us_composite_link_succeeds |}.

Definition jp_generated_coverage_manifest : GeneratedClightCoverageManifest :=
  {| coverage_units := jp_units;
     coverage_unit_count := 38%nat;
     coverage_count_exact := eq_refl;
     coverage_ast_link_succeeds := jp_ast_link_succeeds;
     coverage_composite_link_succeeds := jp_composite_link_succeeds |}.

(** This is deliberately a failure certificate, not a linked-program
    environment.  In particular, no [Genv.globalenv] is constructed and this
    file does not instantiate [TargetLinkedProgram]. *)
Theorem generated_whole_program_link_is_blocked :
  coverage_ast_link_succeeds us_generated_coverage_manifest = false /\
  coverage_composite_link_succeeds us_generated_coverage_manifest = false /\
  coverage_ast_link_succeeds jp_generated_coverage_manifest = false /\
  coverage_composite_link_succeeds jp_generated_coverage_manifest = false.
Proof.
  vm_compute.
  repeat split.
Qed.
