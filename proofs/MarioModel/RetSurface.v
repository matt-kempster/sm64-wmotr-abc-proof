(* ====================================================================== *)
(* THE RETURN-VALUE SURFACE: a reached function never RETURNS a pointer    *)
(* into Mario's block UNLESS its return type can carry one (SPINE:         *)
(* consumed by the MWF-grounded capstone to discharge the bulk of          *)
(* Hret_call with ZERO new trust).                                         *)
(*                                                                        *)
(* The bottom line.  The v2 engine's Hret_call leaf asks: for every        *)
(* reached funcall whose result is a pointer Vptr b o, b <> bm.  On        *)
(* ptr64 = false a Vptr can only survive a return cast through             *)
(* cast_case_pointer, and classify_cast picks cast_case_pointer ONLY when  *)
(* the TARGET (= fn_return) is Tint I32 or a pointer type.  So a reached   *)
(* Internal whose fn_return is Tvoid / Tint I8/I16/IBool / Tfloat can      *)
(* NEVER return a Vptr at all -- its Hret_call obligation is vacuous,      *)
(* discharged here with no assumption about the program.                   *)
(*                                                                        *)
(* This eliminates the ~17 void/sub-word-int-returning reached functions   *)
(* (11 void censused + update_mario_button_inputs + the void rest          *)
(* dispatch helpers + level_trigger_warp's s16 return) from the residual   *)
(* surface.  What remains -- ret_fd_safe fd = false -- is exactly the      *)
(* Tint I32 returns (the 4 getters + the 7 dispatchers, whose int result   *)
(* is a status code, not a pointer) and the External fundefs (the honest   *)
(* terminal-external model boundary, e.g. EF_vload).  Those stay as the    *)
(* SHARPER residual Hret_unsafe at the capstone.                           *)
(* ====================================================================== *)

From Coq Require Import List.
From compcert Require Import Coqlib Maps AST Integers Floats Values Memory
  Ctypes Cop Clight ClightBigstep.

(* A return type that can NEVER let a Vptr through sem_cast on ptr64=false:
   only Tint I32 and Tpointer select cast_case_pointer (the sole Vptr-
   producing cast case besides the struct/union/void passthroughs, which
   classify_cast never picks for an int/float target). *)
Definition ret_ty_safe (t : type) : bool :=
  match t with
  | Tvoid => true
  | Tint I32 _ _ => false
  | Tint _ _ _ => true        (* I8 / I16 / IBool *)
  | Tfloat _ _ => true
  | _ => false                (* Tint I32, Tlong, Tpointer, struct/union/... *)
  end.

Definition ret_fd_safe (fd : Clight.fundef) : bool :=
  match fd with
  | Internal f => ret_ty_safe (fn_return f)
  | External _ _ _ _ => false
  end.

(* ---------------------------------------------------------------------- *)
(* sem_cast into a non-I32 int / float target never produces a Vptr.      *)
(* ---------------------------------------------------------------------- *)

(* classify_cast into a sub-word int target is one of the numeric cast
   cases -- never pointer / struct / union / void. *)
Lemma classify_cast_to_subint_numeric : forall t1 sz si a,
  sz <> I32 ->
  match classify_cast t1 (Tint sz si a) with
  | cast_case_pointer => False
  | cast_case_struct _ _ => False
  | cast_case_union _ _ => False
  | cast_case_void => False
  | _ => True
  end.
Proof.
  intros t1 sz si a Hsz.
  destruct sz; try (exfalso; apply Hsz; reflexivity);
  destruct t1; cbn;
  first
    [ exact I
    | match goal with
      | |- context[match ?ff with F32 => _ | F64 => _ end] => destruct ff; cbn; exact I
      end
    | destruct Archi.ptr64; cbn; exact I ].
Qed.

Lemma classify_cast_to_float_numeric : forall t1 sz a,
  match classify_cast t1 (Tfloat sz a) with
  | cast_case_pointer => False
  | cast_case_struct _ _ => False
  | cast_case_union _ _ => False
  | cast_case_void => False
  | _ => True
  end.
Proof.
  intros t1 sz a.
  destruct sz; destruct t1; cbn;
  first
    [ exact I
    | match goal with
      | |- context[match ?ff with F32 => _ | F64 => _ end] => destruct ff; cbn; exact I
      end
    | destruct Archi.ptr64; cbn; exact I ].
Qed.

(* A cast that OUTPUTS a Vptr must have had a Vptr INPUT: every sem_cast
   case but the pointer / struct / union / void passthroughs builds a
   fresh non-pointer value. *)
Lemma sem_cast_Vptr_through : forall v t1 t2 m b o,
  sem_cast v t1 t2 m = Some (Vptr b o) -> v = Vptr b o.
Proof.
  intros v t1 t2 m b o Hsc.
  unfold sem_cast in Hsc.
  destruct (classify_cast t1 t2); destruct v;
    repeat (match type of Hsc with
            | context[match ?x with Some _ => _ | None => _ end] => destruct x
            | context[if ?c then _ else _] => destruct c
            end);
    try discriminate Hsc; try (inversion Hsc; reflexivity).
Qed.

Lemma sem_cast_int_not_ptr : forall v t1 sz si a m b o,
  sz <> I32 -> sem_cast v t1 (Tint sz si a) m = Some (Vptr b o) -> False.
Proof.
  intros v t1 sz si a m b o Hsz Hsc.
  pose proof (sem_cast_Vptr_through _ _ _ _ _ _ Hsc) as Hv. subst v.
  pose proof (classify_cast_to_subint_numeric t1 sz si a Hsz) as Hnum.
  unfold sem_cast in Hsc.
  destruct (classify_cast t1 (Tint sz si a)); cbn in Hnum; try exact Hnum;
    (repeat (match type of Hsc with
             | context[if ?c then _ else _] => destruct c
             end);
     discriminate Hsc).
Qed.

Lemma sem_cast_float_not_ptr : forall v t1 sz a m b o,
  sem_cast v t1 (Tfloat sz a) m = Some (Vptr b o) -> False.
Proof.
  intros v t1 sz a m b o Hsc.
  pose proof (sem_cast_Vptr_through _ _ _ _ _ _ Hsc) as Hv. subst v.
  pose proof (classify_cast_to_float_numeric t1 sz a) as Hnum.
  unfold sem_cast in Hsc.
  destruct (classify_cast t1 (Tfloat sz a)); cbn in Hnum; try exact Hnum;
    (repeat (match type of Hsc with
             | context[if ?c then _ else _] => destruct c
             end);
     discriminate Hsc).
Qed.

(* ---------------------------------------------------------------------- *)
(* THE STRUCTURAL LEMMA: a safe-return-type Internal funcall never         *)
(* returns a Vptr.                                                         *)
(* ---------------------------------------------------------------------- *)

Lemma eval_funcall_ret_safe :
  forall fe ge m f vargs t m' vres,
    eval_funcall fe ge m (Internal f) vargs t m' vres ->
    ret_ty_safe (fn_return f) = true ->
    forall b o, vres <> Vptr b o.
Proof.
  intros fe ge m f vargs t m' vres Hev Hsafe b o Hvp. subst vres.
  inv Hev.
  match goal with
  | H : outcome_result_value ?out ?rt (Vptr b o) ?mm |- _ => rename H into Hout
  end.
  unfold ret_ty_safe in Hsafe.
  unfold outcome_result_value in Hout.
  destruct (fn_return f) eqn:Eret; try discriminate Hsafe.
  - (* Tvoid *)
    destruct out as [ | | | [[v' t']| ]];
      try (exact Hout); try discriminate Hout.
    destruct Hout as [Hne _]. exact (Hne eq_refl).
  - (* Tint i s a, i <> I32 *)
    destruct i; try discriminate Hsafe;
      destruct out as [ | | | [[v' t']| ]];
      try (exact Hout);
      destruct Hout as [_ Hsc];
      (eapply sem_cast_int_not_ptr; [ | exact Hsc ]); discriminate.
  - (* Tfloat f a *)
    destruct out as [ | | | [[v' t']| ]];
      try (exact Hout);
      destruct Hout as [_ Hsc];
      eapply sem_cast_float_not_ptr; exact Hsc.
Qed.

(* ---------------------------------------------------------------------- *)
(* THE ASSEMBLY: Hret_call for ANY reached predicate reduces to the        *)
(* SHARPER residual restricted to ret_fd_safe fd = false (Tint I32 / ptr   *)
(* returning Internals + all Externals).                                   *)
(* ---------------------------------------------------------------------- *)

Lemma ret_avoids_bm_of_unsafe :
  forall fe ge bm (reached : Clight.fundef -> Prop),
    (forall fd m0 vargs0 t0 m0' vres0,
        reached fd -> ret_fd_safe fd = false ->
        eval_funcall fe ge m0 fd vargs0 t0 m0' vres0 ->
        forall b o, vres0 = Vptr b o -> b <> bm) ->
    forall fd m0 vargs0 t0 m0' vres0,
      reached fd ->
      eval_funcall fe ge m0 fd vargs0 t0 m0' vres0 ->
      forall b o, vres0 = Vptr b o -> b <> bm.
Proof.
  intros fe ge bm reached Hunsafe fd m0 vargs0 t0 m0' vres0 Hr Hev b o Hvp.
  destruct (ret_fd_safe fd) eqn:Esafe.
  - (* safe-return: the structural lemma rules out vres0 = Vptr *)
    exfalso. destruct fd as [f | ef targs tres cc].
    + cbn in Esafe.
      exact (eval_funcall_ret_safe fe ge m0 f vargs0 t0 m0' vres0 Hev Esafe b o Hvp).
    + cbn in Esafe. discriminate Esafe.
  - (* unsafe-return: the sharper residual *)
    exact (Hunsafe fd m0 vargs0 t0 m0' vres0 Hr Esafe Hev b o Hvp).
Qed.
