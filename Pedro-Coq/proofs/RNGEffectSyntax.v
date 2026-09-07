From Coq Require Import Bool List ZArith.
From compcert Require Import AST Clight Cop Ctypes Integers.
From Pedro.Proofs Require Import ASTFacts.
Import ListNotations.

(** The inventory records every call expression, including computed calls.
    Its completeness result is about generated syntax. It does not identify
    a computed callee with a runtime function pointer or prove reachability. *)
Fixpoint call_expressions (body : statement) : list expr :=
  match body with
  | Scall _ target _ => [target]
  | Ssequence a b | Sloop a b => call_expressions a ++ call_expressions b
  | Sifthenelse _ a b => call_expressions a ++ call_expressions b
  | Sswitch _ cases => case_call_expressions cases
  | Slabel _ body => call_expressions body
  | _ => []
  end
with case_call_expressions (cases : labeled_statements) : list expr :=
  match cases with
  | LSnil => []
  | LScons _ body rest => call_expressions body ++ case_call_expressions rest
  end.

Inductive call_occurs (target : expr) : statement -> Prop :=
| call_here : forall result args, call_occurs target (Scall result target args)
| call_seq_left : forall a b, call_occurs target a -> call_occurs target (Ssequence a b)
| call_seq_right : forall a b, call_occurs target b -> call_occurs target (Ssequence a b)
| call_loop_left : forall a b, call_occurs target a -> call_occurs target (Sloop a b)
| call_loop_right : forall a b, call_occurs target b -> call_occurs target (Sloop a b)
| call_if_left : forall e a b, call_occurs target a -> call_occurs target (Sifthenelse e a b)
| call_if_right : forall e a b, call_occurs target b -> call_occurs target (Sifthenelse e a b)
| call_switch : forall e cases, call_occurs_cases target cases -> call_occurs target (Sswitch e cases)
| call_label : forall label body, call_occurs target body -> call_occurs target (Slabel label body)
with call_occurs_cases (target : expr) : labeled_statements -> Prop :=
| call_case_head : forall label body rest,
    call_occurs target body -> call_occurs_cases target (LScons label body rest)
| call_case_tail : forall label body rest,
    call_occurs_cases target rest -> call_occurs_cases target (LScons label body rest).

Scheme call_occurs_induction := Induction for call_occurs Sort Prop
with call_occurs_cases_induction := Induction for call_occurs_cases Sort Prop.
Combined Scheme call_occurs_mutual from call_occurs_induction, call_occurs_cases_induction.

Theorem call_expression_inventory_complete :
  (forall target body, call_occurs target body -> In target (call_expressions body)) /\
  (forall target cases, call_occurs_cases target cases -> In target (case_call_expressions cases)).
Proof.
  assert (H : forall target,
    (forall body, call_occurs target body -> In target (call_expressions body)) /\
    (forall cases, call_occurs_cases target cases -> In target (case_call_expressions cases))).
  { intro target. apply (call_occurs_mutual target
      (fun body _ => In target (call_expressions body))
      (fun cases _ => In target (case_call_expressions cases)));
      simpl; intros; try apply in_or_app; intuition. }
  split; intros target.
  - exact (proj1 (H target)).
  - exact (proj2 (H target)).
Qed.

Definition named_target (wanted : list ident) (target : expr) : bool :=
  match target with
  | Evar name _ => existsb (Pos.eqb name) wanted
  | _ => false
  end.

Definition direct_named_calls (wanted : list ident) (body : statement) : list ident :=
  flat_map (fun target => match target with
    | Evar name _ => if named_target wanted target then [name] else []
    | _ => [] end) (call_expressions body).

Lemma direct_named_calls_complete :
  forall wanted body name ty,
    In name wanted -> call_occurs (Evar name ty) body ->
    In name (direct_named_calls wanted body).
Proof.
  intros wanted body name ty Hwanted Hcall.
  unfold direct_named_calls. apply in_flat_map.
  exists (Evar name ty). split.
  - eapply (proj1 call_expression_inventory_complete). exact Hcall.
  - simpl. assert (existsb (Pos.eqb name) wanted = true) as H.
    { apply existsb_exists. exists name. split; [exact Hwanted | apply Pos.eqb_refl]. }
    rewrite H. simpl; auto.
Qed.

(** Count references to primitive names outside the direct-callee position.
    A zero result exposes that the selected source bodies do not take or pass
    such a function value. This is a syntax check, not a general alias proof. *)
Fixpoint named_reference_outside_call (wanted : list ident) (body : statement) : bool :=
  let mentions e := existsb (fun id => expression_mentions_ident id e) wanted in
  match body with
  | Scall _ (Evar name ty) args => existsb mentions args
  | Scall _ target args => mentions target || existsb mentions args
  | Sassign a b => mentions a || mentions b
  | Sset _ e | Sreturn (Some e) => mentions e
  | Sbuiltin _ _ _ args => existsb mentions args
  | Ssequence a b | Sloop a b => named_reference_outside_call wanted a || named_reference_outside_call wanted b
  | Sifthenelse e a b => mentions e || named_reference_outside_call wanted a || named_reference_outside_call wanted b
  | Sswitch e cases => mentions e || named_reference_outside_cases wanted cases
  | Slabel _ body => named_reference_outside_call wanted body
  | _ => false
  end
with named_reference_outside_cases (wanted : list ident) (cases : labeled_statements) : bool :=
  match cases with
  | LSnil => false
  | LScons _ body rest => named_reference_outside_call wanted body || named_reference_outside_cases wanted rest
  end.

Fixpoint field_assignment (field : ident) (body : statement) : bool :=
  match body with
  | Sassign (Efield _ name _) _ => Pos.eqb name field
  | Ssequence a b | Sloop a b => field_assignment field a || field_assignment field b
  | Sifthenelse _ a b => field_assignment field a || field_assignment field b
  | Sswitch _ cases => field_assignment_cases field cases
  | Slabel _ body => field_assignment field body
  | _ => false
  end
with field_assignment_cases (field : ident) (cases : labeled_statements) : bool :=
  match cases with
  | LSnil => false
  | LScons _ body rest => field_assignment field body || field_assignment_cases field rest
  end.

Definition computed_call (target : expr) : bool :=
  match target with Evar _ _ => false | _ => true end.

Definition named_call_sites (wanted : list ident)
    (definitions : list (ident * globdef Clight.fundef type)) : list (ident * ident) :=
  flat_map (fun entry => match snd entry with
    | Gfun (Internal f) => map (fun callee => (fst entry, callee))
        (direct_named_calls wanted (fn_body f))
    | _ => [] end) definitions.

Theorem named_call_sites_complete :
  forall wanted definitions caller f callee ty,
    In (caller, Gfun (Internal f)) definitions -> In callee wanted ->
    call_occurs (Evar callee ty) (fn_body f) ->
    In (caller, callee) (named_call_sites wanted definitions).
Proof.
  intros wanted definitions caller f callee ty Hfunction Hcallee Hcall.
  unfold named_call_sites. apply in_flat_map.
  exists (caller, Gfun (Internal f)). split; [exact Hfunction |].
  simpl. apply in_map. eapply direct_named_calls_complete; eauto.
Qed.
