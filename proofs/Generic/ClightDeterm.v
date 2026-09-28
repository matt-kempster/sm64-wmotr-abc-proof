(* Clight expression evaluation is deterministic.  CompCert proves this
   only for its whole-step semantics, not for Clight's eval_expr /
   eval_lvalue; GOAL 2's Clight walks (CoinLink.v) pin the values a real
   body loads by building one evaluation and appealing to this. *)

From compcert Require Import Coqlib Integers Values AST Ctypes Cop Clight Memory Maps
  Globalenvs.

Section DETERM.
Variable ge : genv.
Variable e : env.
Variable le : temp_env.
Variable m : mem.

Lemma deref_loc_determ : forall ty b ofs bf v1 v2,
  deref_loc ty m b ofs bf v1 -> deref_loc ty m b ofs bf v2 -> v1 = v2.
Proof.
  intros ty b ofs bf v1 v2 H1 H2.
  inv H1; inv H2; try congruence.
  match goal with
  | H : load_bitfield _ _ _ _ _ _ _ _, H' : load_bitfield _ _ _ _ _ _ _ _ |- _ =>
      inv H; inv H'; congruence
  end.
Qed.

Ltac use_ih :=
  repeat match goal with
  | IH : forall _ _ _, eval_lvalue ?g ?e ?l ?m ?a _ _ _ -> _,
    H : eval_lvalue ?g ?e ?l ?m ?a _ _ _ |- _ =>
      destruct (IH _ _ _ H) as (? & ? & ?); clear H; subst
  | IH : forall _, eval_expr ?g ?e ?l ?m ?a _ -> _ = _,
    H : eval_expr ?g ?e ?l ?m ?a _ |- _ =>
      pose proof (IH _ H); clear H; subst
  end.

Lemma eval_determ :
  (forall a v, eval_expr ge e le m a v -> forall v', eval_expr ge e le m a v' -> v = v') /\
  (forall a b ofs bf, eval_lvalue ge e le m a b ofs bf ->
     forall b' ofs' bf', eval_lvalue ge e le m a b' ofs' bf' -> b = b' /\ ofs = ofs' /\ bf = bf').
Proof.
  apply eval_expr_lvalue_ind; intros;
    match goal with
    | H : eval_expr _ _ _ _ _ _ |- _ = _ => inv H
    | H : eval_lvalue _ _ _ _ _ _ _ _ |- _ /\ _ => inv H
    end;
    (* a non-lvalue shape paired with an Elvalue derivation *)
    try match goal with H : eval_lvalue _ _ _ _ ?a _ _ _ |- _ =>
          lazymatch a with
          | Econst_int _ _ => inv H | Econst_float _ _ => inv H
          | Econst_single _ _ => inv H | Econst_long _ _ => inv H
          | Etempvar _ _ => inv H | Eaddrof _ _ => inv H | Eunop _ _ _ => inv H
          | Ebinop _ _ _ _ => inv H | Ecast _ _ => inv H
          | Esizeof _ _ => inv H | Ealignof _ _ => inv H
          end end;
    use_ih; try congruence; auto.
  all: try (eapply deref_loc_determ; eauto; fail).
  all: try match goal with H : Vptr _ _ = Vptr _ _ |- _ => inv H end; auto.
  all: repeat match goal with
       | H : ?x = ?p, H' : ?x = ?q |- _ =>
           tryif is_var x then fail else
           (tryif constr_eq p q then clear H' else (rewrite H in H'; inv H'))
       end; auto.
  all: try (split; [ reflexivity | ]; congruence).
  all: try (split; [ reflexivity | ]; split; congruence).
  all: try (split; congruence).
  all: repeat match goal with H : Vptr _ _ = Vptr _ _ |- _ => inv H end; auto.
  all: repeat split; congruence.
Qed.

Lemma eval_expr_determ : forall a v v',
  eval_expr ge e le m a v -> eval_expr ge e le m a v' -> v = v'.
Proof. intros. eapply (proj1 eval_determ); eauto. Qed.

End DETERM.
