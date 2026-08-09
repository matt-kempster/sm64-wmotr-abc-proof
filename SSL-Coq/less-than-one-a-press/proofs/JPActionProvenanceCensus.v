(** Receiver-neutral action-writer and long-jump-constructor census for all
    38 generated JP translation units.

    This is a syntax theorem.  It narrows the no-A action-provenance task but
    does not prove pointer non-aliasing, indirect-call flow, or reachability of
    the inventoried bodies. *)

From Coq Require Import List ZArith.
From compcert Require Import AST.
From LessThanOneAPress.Proofs Require Import
  JPQuicksandDepth JPGeneratedWriterCensus.

Import ListNotations.

Definition jp_generated_direct_action_assignment_sites : list ident :=
  internal_field_assignment_sites
    JGC_Mario._action jp_generated_definitions.

(** The field name is receiver-neutral.  In particular,
    [update_mario_info_for_cam] writes the camera/body-state action fields,
    while the other entries contain a direct MarioState action assignment. *)
Theorem jp_generated_action_direct_assignment_census :
  jp_generated_direct_action_assignment_sites =
  [JGC_Mario._set_mario_action;
   JGC_Mario._update_mario_info_for_cam;
   JGC_Mario._init_mario;
   JGC_Mario._init_mario_from_save_file;
   JGC_Air._act_air_throw;
   JGC_Auto._act_ledge_climb_slow;
   JGC_Interaction._bounce_back_from_attack;
   JGC_Interaction._check_kick_or_punch_wall].
Proof. vm_compute. reflexivity. Qed.

Definition ident_member (needle : ident) (haystack : list ident) : bool :=
  existsb (Pos.eqb needle) haystack.

Definition jp_generated_action_writer_long_jump_literal_overlap : list ident :=
  filter
    (fun writer =>
       ident_member writer
         (internal_int_literal_sites 50333832 jp_generated_definitions))
    jp_generated_direct_action_assignment_sites.

(** None of the direct [_action]-field assignment bodies also contains the
    [ACT_LONG_JUMP] literal.  The ordinary constructor instead flows through
    [act_crouch_slide]'s literal call to [set_jumping_action]. *)
Theorem jp_generated_direct_action_writers_do_not_embed_long_jump_literal :
  jp_generated_action_writer_long_jump_literal_overlap = [].
Proof. vm_compute. reflexivity. Qed.

(** One capstone for the exact generated boundary.  The final conjunct is the
    source-shape link between the unique ordinary constructor and its
    [INPUT_A_PRESSED] guard.  It is not a whole-program control-flow theorem:
    aliased writes, corrupt action values, and a generic value propagated
    through an indirect call still require live-memory provenance. *)
Definition JPGeneratedActionProvenanceSyntaxKernel : Prop :=
  jp_generated_direct_action_assignment_sites =
    [JGC_Mario._set_mario_action;
     JGC_Mario._update_mario_info_for_cam;
     JGC_Mario._init_mario;
     JGC_Mario._init_mario_from_save_file;
     JGC_Air._act_air_throw;
     JGC_Auto._act_ledge_climb_slow;
     JGC_Interaction._bounce_back_from_attack;
     JGC_Interaction._check_kick_or_punch_wall] /\
  jp_generated_action_writer_long_jump_literal_overlap = [] /\
  internal_two_literal_call_sites
    JGC_Move._set_jumping_action 50333832 0 jp_generated_definitions =
      [JGC_Move._act_crouch_slide] /\
  internal_two_literal_call_sites
    JGC_Move._set_mario_action 50333832 0 jp_generated_definitions = [] /\
  jp_long_jump_a_edge_source_shape_claim.

Theorem jp_generated_action_provenance_syntax_kernel_checked :
  JPGeneratedActionProvenanceSyntaxKernel.
Proof.
  unfold JPGeneratedActionProvenanceSyntaxKernel.
  repeat split.
Qed.
