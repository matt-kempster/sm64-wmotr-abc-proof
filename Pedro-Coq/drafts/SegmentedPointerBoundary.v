(** UNVERIFIED DRAFT: this file is intentionally outside [_CoqProject]. *)

From Coq Require Import ZArith.
From compcert Require Import Archi AST Clight ClightBigstep Clightdefs Cop
  Ctypes Integers Maps Memory Values.
From Pedro.Generated Require Import us_memory jp_memory.

Module UM := us_memory.
Module JM := jp_memory.

(** The first computation in retail [segmented_to_virtual] extracts the
    high byte of its pointer-typed argument.  This definition names the exact
    expression emitted by [clightgen] for both supported versions. *)
Definition segment_index_expression (addr : ident) : expr :=
  Ebinop Oshr
    (Ecast (Etempvar addr (tptr tvoid)) tuint)
    (Econst_int (Int.repr 24) tint)
    tuint.

Definition first_sequence_statement (body : statement) : option statement :=
  match body with
  | Ssequence first _ => Some first
  | _ => None
  end.

(** Exact generated-AST receipt.  The US and JP translation units agree on
    the operation, types, and shift count; only their generated identifiers
    are referenced through their respective modules. *)
Theorem generated_segmented_to_virtual_first_shift_us_jp :
  first_sequence_statement (fn_body UM.f_segmented_to_virtual) =
    Some (Sset UM._segment (segment_index_expression UM._addr)) /\
  first_sequence_statement (fn_body JM.f_segmented_to_virtual) =
    Some (Sset JM._segment (segment_index_expression JM._addr)).
Proof.
  split; reflexivity.
Qed.

(** The configured CompCert target is 32-bit.  Consequently the standard
    Clight cast from [void *] to [unsigned int] is the pointer case, whose
    semantic result remains a symbolic [Vptr]; it does not expose an N64
    numeric address. *)
Lemma configured_pointer_width_is_32 : Archi.ptr64 = false.
Proof.
  reflexivity.
Qed.

Lemma pointer_to_uint_cast_preserves_vptr :
  forall block offset memory,
    sem_cast (Vptr block offset) (tptr tvoid) tuint memory =
      Some (Vptr block offset).
Proof.
  intros. reflexivity.
Qed.

(** Integer right shift has no semantic case for a symbolic pointer value.
    This is the exact [sem_binary_operation] requested by the generated
    expression after the preceding cast. *)
Lemma uint_right_shift_of_vptr_is_none :
  forall (cenv : composite_env) block offset memory,
    sem_binary_operation cenv Oshr
      (Vptr block offset) tuint
      (Vint (Int.repr 24)) tint memory = None.
Proof.
  intros. reflexivity.
Qed.

Lemma eval_tempvar_binding :
  forall ge e le memory id ty value,
    eval_expr ge e le memory (Etempvar id ty) value ->
    le ! id = Some value.
Proof.
  intros. inversion H; auto.
  match goal with
  | Hlv : eval_lvalue _ _ _ _ (Etempvar _ _) _ _ _ |- _ => inversion Hlv
  end.
Qed.

Lemma eval_const_int_value :
  forall ge e le memory integer ty value,
    eval_expr ge e le memory (Econst_int integer ty) value ->
    value = Vint integer.
Proof.
  intros. inversion H; auto.
  match goal with
  | Hlv : eval_lvalue _ _ _ _ (Econst_int _ _) _ _ _ |- _ => inversion Hlv
  end.
Qed.

(** A symbolic CompCert pointer bound to the generated argument temp makes
    the first expression stuck: the cast preserves the [Vptr], then [Oshr]
    returns [None], contradicting the premise required by [eval_Ebinop]. *)
Theorem segment_index_expression_cannot_eval_from_vptr :
  forall ge e le memory addr block offset value,
    le ! addr = Some (Vptr block offset) ->
    ~ eval_expr ge e le memory (segment_index_expression addr) value.
Proof.
  intros ge e le memory addr block offset value Haddr Heval.
  unfold segment_index_expression in Heval.
  inversion Heval; subst.
  all: try match goal with
    Hlv : eval_lvalue _ _ _ _ (Ebinop _ _ _ _) _ _ _ |- _ => inversion Hlv
  end.
  match goal with
  | Hcast_eval : eval_expr _ _ _ _ (Ecast _ _) _ |- _ =>
      inversion Hcast_eval; subst
  end.
  all: try match goal with
    Hlv : eval_lvalue _ _ _ _ (Ecast _ _) _ _ _ |- _ => inversion Hlv
  end.
  match goal with
  | Htemp : eval_expr _ _ _ _ (Etempvar _ _) ?loaded |- _ =>
      pose proof (eval_tempvar_binding _ _ _ _ _ _ _ Htemp) as Hget;
      assert (loaded = Vptr block offset) by congruence;
      subst loaded
  end.
  match goal with
  | Hcast : sem_cast (Vptr block offset) _ _ _ = Some ?casted |- _ =>
      change (sem_cast (Vptr block offset) (tptr tvoid) tuint memory =
        Some casted) in Hcast;
      rewrite pointer_to_uint_cast_preserves_vptr in Hcast;
      inversion Hcast; subst
  end.
  match goal with
  | Hconst : eval_expr _ _ _ _ (Econst_int _ _) ?count |- _ =>
      pose proof (eval_const_int_value _ _ _ _ _ _ _ Hconst);
      subst count
  end.
  match goal with
  | Hshift : sem_binary_operation _ Oshr
      (Vptr block offset) _ _ _ _ = Some _ |- _ =>
      change (sem_binary_operation ge Oshr
        (Vptr block offset) tuint
        (Vint (Int.repr 24)) tint memory = Some value) in Hshift;
      rewrite uint_right_shift_of_vptr_is_none in Hshift;
      discriminate
  end.
Qed.

Corollary us_segmented_first_shift_cannot_eval_from_vptr :
  forall ge e le memory block offset value,
    le ! UM._addr = Some (Vptr block offset) ->
    ~ eval_expr ge e le memory
        (segment_index_expression UM._addr) value.
Proof.
  eauto using segment_index_expression_cannot_eval_from_vptr.
Qed.

Corollary jp_segmented_first_shift_cannot_eval_from_vptr :
  forall ge e le memory block offset value,
    le ! JM._addr = Some (Vptr block offset) ->
    ~ eval_expr ge e le memory
        (segment_index_expression JM._addr) value.
Proof.
  eauto using segment_index_expression_cannot_eval_from_vptr.
Qed.

Definition segmented_pointer_boundary_claim : Prop :=
  first_sequence_statement (fn_body UM.f_segmented_to_virtual) =
    Some (Sset UM._segment (segment_index_expression UM._addr)) /\
  first_sequence_statement (fn_body JM.f_segmented_to_virtual) =
    Some (Sset JM._segment (segment_index_expression JM._addr)) /\
  Archi.ptr64 = false /\
  (forall block offset memory,
    sem_cast (Vptr block offset) (tptr tvoid) tuint memory =
      Some (Vptr block offset)) /\
  (forall (cenv : composite_env) block offset memory,
    sem_binary_operation cenv Oshr
      (Vptr block offset) tuint
      (Vint (Int.repr 24)) tint memory = None) /\
  (forall ge e le memory block offset value,
    le ! UM._addr = Some (Vptr block offset) ->
    ~ eval_expr ge e le memory
        (segment_index_expression UM._addr) value) /\
  (forall ge e le memory block offset value,
    le ! JM._addr = Some (Vptr block offset) ->
    ~ eval_expr ge e le memory
        (segment_index_expression JM._addr) value).

Theorem checked_segmented_pointer_boundary_us_jp :
  segmented_pointer_boundary_claim.
Proof.
  unfold segmented_pointer_boundary_claim.
  repeat split.
  - exact (proj1 generated_segmented_to_virtual_first_shift_us_jp).
  - exact (proj2 generated_segmented_to_virtual_first_shift_us_jp).
  - exact configured_pointer_width_is_32.
  - exact pointer_to_uint_cast_preserves_vptr.
  - exact uint_right_shift_of_vptr_is_none.
  - exact us_segmented_first_shift_cannot_eval_from_vptr.
  - exact jp_segmented_first_shift_cannot_eval_from_vptr.
Qed.
