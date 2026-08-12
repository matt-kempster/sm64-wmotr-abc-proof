(** Source-independent exactness of the JP object-pool variable shape. *)

From Coq Require Import Bool List ZArith.
From compcert Require Import AST Clight Ctypes Linking Memory.
From LessThanOneAPress.Generated Require Import jp_object_list_processor.
From LessThanOneAPress.Proofs Require Import
  JPDestinationChronologyCertificate.

Import ListNotations.
Local Open Scope Z_scope.

Lemma jp_object_pool_linkorder_and_shape_are_exact :
  forall definition,
    linkorder (Gvar jp_object_list_processor.v_gObjectPool) definition ->
    jp_object_pool_global_shape definition = true ->
    definition = Gvar jp_object_list_processor.v_gObjectPool.
Proof.
  intros definition Horder Hshape.
  destruct definition as [function_definition |
    [variable_info variable_init variable_readonly variable_volatile]];
    try discriminate Hshape.
  cbn [jp_object_pool_global_shape] in Hshape.
  destruct variable_init as [| initializer rest]
    eqn:Hinitializer; try discriminate Hshape.
  destruct rest as [| second rest].
  2: destruct initializer; discriminate Hshape.
  destruct initializer; try discriminate Hshape.
  change (((z =? 145920) && negb variable_readonly) &&
    negb variable_volatile = true) in Hshape.
  apply Bool.andb_true_iff in Hshape.
  destruct Hshape as [Hleft Hvolatile].
  apply Bool.andb_true_iff in Hleft.
  destruct Hleft as [Hbytes Hreadonly].
  apply Z.eqb_eq in Hbytes.
  apply Bool.negb_true_iff in Hreadonly.
  apply Bool.negb_true_iff in Hvolatile.
  subst variable_readonly variable_volatile z.
  inversion Horder; subst;
  match goal with
  | Hvariable : linkorder jp_object_list_processor.v_gObjectPool _ |- _ =>
      unfold jp_object_list_processor.v_gObjectPool in Hvariable;
      inversion Hvariable; subst
  end;
  match goal with
  | Hinfo : @linkorder type _ _ variable_info |- _ =>
      change (gvar_info jp_object_list_processor.v_gObjectPool =
        variable_info) in Hinfo;
      subst variable_info
  end;
  reflexivity.
Qed.
