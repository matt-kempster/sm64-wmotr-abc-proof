(* ====================================================================== *)
(* MaxPerm.v -- a Clight big-step run never grows an old block's maximum  *)
(* permission (2026-11-03).                                                *)
(*                                                                        *)
(* THEOREM (exec_maxperm): after ANY exec_stmt / eval_funcall (the         *)
(* function_entry2 semantics), the block count has not dropped and every  *)
(* block valid before has no Max permission it lacked before.  Stores keep *)
(* permissions, allocation only adds a fresh block, free only removes,    *)
(* and external calls and builtins go through CompCert's own              *)
(* external_call_max_perm.  Nothing about any program is assumed.          *)
(*                                                                        *)
(* GOAL 2 uses it at the boot witness: a global's Max permissions there    *)
(* are those Genv.init_mem gave it (StartSat, the partition-cell bound of  *)
(* ObjWorld.surf_obj_ok).                                                  *)
(* ====================================================================== *)

From Coq Require Import ZArith List.
From compcert Require Import Coqlib Maps AST Integers Values Memory Events
  Globalenvs Ctypes Cop Clight ClightBigstep.
From SM64.Proofs Require Import Generic.PermWalk.
Import ListNotations.

Definition MP (m m' : mem) : Prop :=
  Ple (Mem.nextblock m) (Mem.nextblock m')
  /\ forall b o p, Mem.valid_block m b -> Mem.perm m' b o Max p -> Mem.perm m b o Max p.

Lemma MP_refl : forall m, MP m m.
Proof. intros m. split; [ apply Ple_refl | tauto ]. Qed.

Lemma MP_trans : forall m1 m2 m3, MP m1 m2 -> MP m2 m3 -> MP m1 m3.
Proof.
  intros m1 m2 m3 (N1 & P1) (N2 & P2). split; [ exact (Ple_trans _ _ _ N1 N2) | ].
  intros b o p Hv Hp. apply (P1 b o p Hv). apply (P2 b o p); [ | exact Hp ].
  unfold Mem.valid_block in *. eapply Plt_Ple_trans; eassumption.
Qed.

Lemma MP_of_PK : forall m m', PK m m' -> MP m m'.
Proof.
  intros m m' (N & P & _). split; [ exact N | ]. intros b o p Hv Hp. exact (proj2 (P b o Max p Hv) Hp).
Qed.

Section MPS.
  Variable ge : genv.

  Lemma MP_assign : forall ty m b o bf v m', assign_loc ge ty m b o bf v m' -> MP m m'.
  Proof. intros ty m b o bf v m' H. exact (MP_of_PK _ _ (PK_assign ge ty m b o bf v m' H)). Qed.

  Lemma MP_ext : forall ef vargs m t vres m', external_call ef ge vargs m t vres m' -> MP m m'.
  Proof.
    intros ef vargs m t vres m' H. split.
    - pose proof (external_call_nextblock _ _ _ _ _ _ _ H) as N. exact N.
    - intros b o p Hv Hp. eapply external_call_max_perm; eassumption.
  Qed.

  Definition stmt_M (e : env) (le : temp_env) (m : mem) (s : statement) (t : trace)
      (le' : temp_env) (m' : mem) (out : outcome) : Prop := MP m m'.
  Definition call_M (m : mem) (fd : fundef) (vs : list val) (t : trace) (m' : mem) (v : val) : Prop :=
    MP m m'.

  Theorem exec_maxperm :
    (forall e le m s t le' m' out, exec_stmt function_entry2 ge e le m s t le' m' out ->
       stmt_M e le m s t le' m' out) /\
    (forall m fd vs t m' v, eval_funcall function_entry2 ge m fd vs t m' v -> call_M m fd vs t m' v).
  Proof.
    apply exec_stmt_funcall_ind; unfold stmt_M, call_M; intros;
      repeat match goal with
      | H : assign_loc _ _ _ _ _ _ _ _ |- _ => exact (MP_assign _ _ _ _ _ _ _ H)
      | H : external_call _ _ _ _ _ _ _ |- _ => exact (MP_ext _ _ _ _ _ _ H)
      end;
      try (apply MP_refl);
      try (eapply MP_trans; eassumption);
      try assumption.
    - (* loop loop *) eapply MP_trans; [ eassumption | eapply MP_trans; eassumption ].
    - (* internal call *)
      match goal with
      | Hfe : function_entry2 _ _ _ _ _ _ _, Hb : MP ?M1 ?M2, Hf : Mem.free_list ?M2 _ = Some _ |- _ =>
          inv Hfe;
          match goal with Ha : alloc_variables _ _ _ _ _ _ |- _ =>
            destruct (av_old ge _ _ _ _ _ Ha) as (Na & Pa) end;
          destruct Hb as (Nb & Pb);
          split;
          [ rewrite (fl_next _ _ _ Hf); exact (Ple_trans _ _ _ Na Nb)
          | intros b o p Hv Hp;
            apply (proj2 (Pa b o Max p Hv));
            apply Pb; [ unfold Mem.valid_block in *; eapply Plt_Ple_trans; eassumption | ];
            exact (fl_back _ _ _ _ _ _ _ Hf Hp) ]
      end.
  Qed.

  Theorem funcall_maxperm : forall m fd vs t m' v,
      eval_funcall function_entry2 ge m fd vs t m' v -> MP m m'.
  Proof. intros m fd vs t m' v H. exact (proj2 exec_maxperm _ _ _ _ _ _ H). Qed.

  Theorem stmt_maxperm : forall e le m s t le' m' out,
      exec_stmt function_entry2 ge e le m s t le' m' out -> MP m m'.
  Proof. intros e le m s t le' m' out H. exact (proj1 exec_maxperm _ _ _ _ _ _ _ _ H). Qed.
End MPS.
