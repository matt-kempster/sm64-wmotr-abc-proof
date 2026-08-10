(** Linked JP platform-global dataflow.

    This file moves one part of the installer argument from an abstract event
    model to CompCert's memory and [Clight.step2] semantics.  It proves the
    exact dataflow once execution reaches the generated fragments:

      [Surface.object] expression -> temporary -> [gMarioPlatform] store;
      [gMarioPlatform] load -> the apply function's [platform] temporary.

    The source receipt below establishes that those fragments occur in the
    generated JP bodies.  The semantic lemmas execute the exact statements
    over an abstract Clight global environment, conditional on explicit
    expression-evaluation, symbol, store/load, and frame premises.  This file
    does not yet specialize those lemmas to the official linked global
    environment, connect the generated function bodies to official-link
    definitions, resolve the concrete global block, prove allocation bounds
    or writable permissions, or establish reachability.  In particular, it
    does not prove that [find_floor] returns a particular live surface, that
    its branch is taken, or that intervening linked execution preserves the
    platform cell. *)

From Coq Require Import Bool List ZArith.
From compcert Require Import AST Clight Clightdefs Coqlib Ctypes Errors Events
  Globalenvs Integers Linking Maps Memory Smallstep Values.
From LessThanOneAPress.Generated Require Import jp_platform_displacement.

Import ListNotations.
Import Clightdefs.ClightNotations.
Local Open Scope Z_scope.

Module JPLPGPlatform := jp_platform_displacement.

Definition jp_object_pointer_type : type :=
  tptr (Tstruct JPLPGPlatform._Object noattr).

Definition jp_surface_pointer_type : type :=
  tptr (Tstruct JPLPGPlatform._Surface noattr).

Definition jp_surface_object_expression : expr :=
  Efield
    (Ederef
      (Etempvar JPLPGPlatform._t'8 jp_surface_pointer_type)
      (Tstruct JPLPGPlatform._Surface noattr))
    JPLPGPlatform._object jp_object_pointer_type.

Definition jp_platform_global_store : statement :=
  Sassign
    (Evar JPLPGPlatform._gMarioPlatform jp_object_pointer_type)
    (Etempvar JPLPGPlatform._t'9 jp_object_pointer_type).

Definition jp_surface_owner_to_platform_fragment : statement :=
  Ssequence
    (Sset JPLPGPlatform._t'9 jp_surface_object_expression)
    jp_platform_global_store.

Definition jp_apply_platform_global_load : statement :=
  Sset JPLPGPlatform._platform
    (Evar JPLPGPlatform._gMarioPlatform jp_object_pointer_type).

(** This recognizer couples the field-load destination to the global-store
    source.  It is intentionally only a generated-AST receipt. *)
Definition is_surface_owner_to_platform_fragment (s : statement) : bool :=
  match s with
  | Ssequence
      (Sset loaded
        (Efield (Ederef (Etempvar _ _) _) field _))
      (Sassign (Evar global _) (Etempvar stored _)) =>
      Pos.eqb loaded stored &&
      Pos.eqb field JPLPGPlatform._object &&
      Pos.eqb global JPLPGPlatform._gMarioPlatform
  | _ => false
  end.

Fixpoint contains_surface_owner_to_platform_fragment_s
    (s : statement) : bool :=
  is_surface_owner_to_platform_fragment s ||
  match s with
  | Ssequence first second | Sloop first second =>
      contains_surface_owner_to_platform_fragment_s first ||
      contains_surface_owner_to_platform_fragment_s second
  | Sifthenelse _ yes no =>
      contains_surface_owner_to_platform_fragment_s yes ||
      contains_surface_owner_to_platform_fragment_s no
  | Sswitch _ cases =>
      contains_surface_owner_to_platform_fragment_ls cases
  | Slabel _ body => contains_surface_owner_to_platform_fragment_s body
  | _ => false
  end
with contains_surface_owner_to_platform_fragment_ls
    (cases : labeled_statements) : bool :=
  match cases with
  | LSnil => false
  | LScons _ body rest =>
      contains_surface_owner_to_platform_fragment_s body ||
      contains_surface_owner_to_platform_fragment_ls rest
  end.

(** Unlike the boolean inventory above, this executable search returns the
    actual statement encountered in the generated tree.  Consequently the
    checked equality below couples every identifier and every type annotation
    of the source occurrence to the exact fragment used by the semantic
    theorem. *)
Fixpoint find_surface_owner_to_platform_fragment_s
    (s : statement) : option statement :=
  if is_surface_owner_to_platform_fragment s
  then Some s
  else
    match s with
    | Ssequence first second | Sloop first second =>
        match find_surface_owner_to_platform_fragment_s first with
        | Some found => Some found
        | None => find_surface_owner_to_platform_fragment_s second
        end
    | Sifthenelse _ yes no =>
        match find_surface_owner_to_platform_fragment_s yes with
        | Some found => Some found
        | None => find_surface_owner_to_platform_fragment_s no
        end
    | Sswitch _ cases => find_surface_owner_to_platform_fragment_ls cases
    | Slabel _ body => find_surface_owner_to_platform_fragment_s body
    | _ => None
    end
with find_surface_owner_to_platform_fragment_ls
    (cases : labeled_statements) : option statement :=
  match cases with
  | LSnil => None
  | LScons _ body rest =>
      match find_surface_owner_to_platform_fragment_s body with
      | Some found => Some found
      | None => find_surface_owner_to_platform_fragment_ls rest
      end
  end.

Theorem jp_generated_platform_global_dataflow_receipt :
  find_surface_owner_to_platform_fragment_s
    (fn_body JPLPGPlatform.f_update_mario_platform) =
      Some jp_surface_owner_to_platform_fragment /\
  exists tail,
    fn_body JPLPGPlatform.f_apply_mario_platform_displacement =
      Ssequence jp_apply_platform_global_load tail.
Proof.
  split.
  - vm_compute. reflexivity.
  - eexists. reflexivity.
Qed.

(** A successful pointer store frames any load from a distinct block.  This
    is a memory-semantic fact; identifying the concrete official global blocks
    and proving them distinct remains a separate link-resolution obligation. *)
Lemma jp_platform_cell_store_frames_distinct_global_load :
  forall before after value platform_block other_block
      read_chunk read_offset,
    platform_block <> other_block ->
    Mem.store Mptr before platform_block 0 value = Some after ->
    Mem.load read_chunk after other_block read_offset =
      Mem.load read_chunk before other_block read_offset.
Proof.
  intros before after value platform_block other_block read_chunk read_offset
    Hseparate Hstore.
  eapply Mem.load_store_other; eauto.
Qed.

Section LINKED_STEPS.

Variable jp_ge : Clight.genv.

Lemma jp_surface_object_temp_step :
  forall function continuation environment locals memory owner,
    @eval_expr jp_ge environment locals memory
      jp_surface_object_expression owner ->
    Clight.step2 jp_ge
      (State function
        (Sset JPLPGPlatform._t'9 jp_surface_object_expression)
        continuation environment locals memory)
      E0
      (State function Sskip continuation environment
        (PTree.set JPLPGPlatform._t'9 owner locals) memory).
Proof.
  intros. now apply Clight.step_set.
Qed.

Lemma jp_platform_global_store_step :
  forall function continuation environment locals before
      platform_block owner_block owner_offset after,
    environment ! JPLPGPlatform._gMarioPlatform = None ->
    Genv.find_symbol jp_ge JPLPGPlatform._gMarioPlatform =
      Some platform_block ->
    locals ! JPLPGPlatform._t'9 =
      Some (Vptr owner_block owner_offset) ->
    Mem.store Mptr before platform_block 0
      (Vptr owner_block owner_offset) = Some after ->
    Clight.step2 jp_ge
      (State function
        jp_platform_global_store
        continuation environment locals before)
      E0
      (State function Sskip continuation environment locals after).
Proof.
  intros function continuation environment locals before platform_block
    owner_block owner_offset after Hnotlocal Hsymbol Htemp Hstore.
  unfold jp_platform_global_store.
  eapply Clight.step_assign with
    (loc := platform_block) (ofs := Ptrofs.zero) (bf := Full)
    (v2 := Vptr owner_block owner_offset)
    (v := Vptr owner_block owner_offset).
  - now apply eval_Evar_global.
  - now apply eval_Etempvar.
  - reflexivity.
  - eapply assign_loc_value with (chunk := Mptr).
    + reflexivity.
    + change (Mem.store Mptr before platform_block 0
        (Vptr owner_block owner_offset) = Some after).
      exact Hstore.
Qed.

(** The two data-bearing steps are proved separately above and below.  Their
    exact four-step [Smallstep.star] composition additionally includes the
    structural sequence/skip transitions and remains an explicit composition
    obligation rather than being hidden behind an unstable proof script. *)

Lemma jp_platform_global_load_step :
  forall function continuation environment locals memory
      platform_block owner,
    environment ! JPLPGPlatform._gMarioPlatform = None ->
    Genv.find_symbol jp_ge JPLPGPlatform._gMarioPlatform =
      Some platform_block ->
    Mem.load Mptr memory platform_block 0 = Some owner ->
    Clight.step2 jp_ge
      (State function jp_apply_platform_global_load
        continuation environment locals memory)
      E0
      (State function Sskip continuation environment
        (PTree.set JPLPGPlatform._platform owner locals) memory).
Proof.
  intros function continuation environment locals memory platform_block owner
    Hnotlocal Hsymbol Hload.
  apply Clight.step_set.
  eapply eval_Elvalue with
    (loc := platform_block) (ofs := Ptrofs.zero) (bf := Full).
  - now apply eval_Evar_global.
  - eapply deref_loc_value with (chunk := Mptr).
    + reflexivity.
    + change (Mem.load Mptr memory platform_block 0 = Some owner).
      exact Hload.
Qed.

(** This is the conditional memory-chronology theorem.  The explicit equality
    is the
    exact frame still required from intervening linked steps: it cannot be
    obtained from source syntax alone. *)
Theorem jp_stored_platform_owner_is_true_apply_loaded_owner_under_frame :
  forall function continuation environment locals stored_memory apply_memory
      platform_block owner_block owner_offset,
    environment ! JPLPGPlatform._gMarioPlatform = None ->
    Genv.find_symbol jp_ge JPLPGPlatform._gMarioPlatform =
      Some platform_block ->
    Mem.load Mptr stored_memory platform_block 0 =
      Some (Vptr owner_block owner_offset) ->
    Mem.load Mptr apply_memory platform_block 0 =
      Mem.load Mptr stored_memory platform_block 0 ->
    Clight.step2 jp_ge
      (State function jp_apply_platform_global_load
        continuation environment locals apply_memory)
      E0
      (State function Sskip continuation environment
        (PTree.set JPLPGPlatform._platform
          (Vptr owner_block owner_offset) locals) apply_memory).
Proof.
  intros function continuation environment locals stored_memory apply_memory
    platform_block owner_block owner_offset Hnotlocal Hsymbol Hstored Hframe.
  eapply jp_platform_global_load_step; eauto.
  rewrite Hframe. exact Hstored.
Qed.

Theorem jp_successful_platform_store_is_immediately_loadable :
  forall before after platform_block owner_block owner_offset,
    Mem.store Mptr before platform_block 0
      (Vptr owner_block owner_offset) = Some after ->
    Mem.load Mptr after platform_block 0 =
      Some (Vptr owner_block owner_offset).
Proof.
  intros before after platform_block owner_block owner_offset Hstore.
  pose proof (Mem.load_store_same Mptr before platform_block 0
    (Vptr owner_block owner_offset) after Hstore) as Hload.
  exact Hload.
Qed.

(** A successful platform-cell store, followed by execution that preserves
    the cell's pointer-sized load, supplies the exact value consumed by the
    apply statement.  This is the strongest chronology result in this file;
    its frame premise remains the linked-execution obligation. *)
Theorem jp_successful_platform_store_is_true_apply_loaded_owner_under_frame :
  forall function continuation environment locals before stored_memory
      apply_memory platform_block owner_block owner_offset,
    environment ! JPLPGPlatform._gMarioPlatform = None ->
    Genv.find_symbol jp_ge JPLPGPlatform._gMarioPlatform =
      Some platform_block ->
    Mem.store Mptr before platform_block 0
      (Vptr owner_block owner_offset) = Some stored_memory ->
    Mem.load Mptr apply_memory platform_block 0 =
      Mem.load Mptr stored_memory platform_block 0 ->
    Clight.step2 jp_ge
      (State function jp_apply_platform_global_load
        continuation environment locals apply_memory)
      E0
      (State function Sskip continuation environment
        (PTree.set JPLPGPlatform._platform
          (Vptr owner_block owner_offset) locals) apply_memory).
Proof.
  intros function continuation environment locals before stored_memory
    apply_memory platform_block owner_block owner_offset Hnotlocal Hsymbol
    Hstore Hframe.
  eapply jp_stored_platform_owner_is_true_apply_loaded_owner_under_frame.
  - exact Hnotlocal.
  - exact Hsymbol.
  - exact (jp_successful_platform_store_is_immediately_loadable
      before stored_memory platform_block owner_block owner_offset Hstore).
  - exact Hframe.
Qed.

End LINKED_STEPS.

(** Checked generated-AST boundary.  The memory-semantic theorems above
    remain universally quantified over concrete evaluation, symbol, store,
    load, and intervening-frame premises rather than being hidden inside this
    compact syntax certificate. *)
Definition JPGeneratedPlatformASTBoundary : Prop :=
  find_surface_owner_to_platform_fragment_s
    (fn_body JPLPGPlatform.f_update_mario_platform) =
      Some jp_surface_owner_to_platform_fragment /\
  (exists tail,
    fn_body JPLPGPlatform.f_apply_mario_platform_displacement =
      Ssequence jp_apply_platform_global_load tail).

Theorem jp_generated_platform_ast_boundary_checked :
  JPGeneratedPlatformASTBoundary.
Proof.
  exact jp_generated_platform_global_dataflow_receipt.
Qed.
