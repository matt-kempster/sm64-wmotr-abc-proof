(* ====================================================================== *)
(* CollWalk (GOAL 2): the real detect_object_collisions keeps the object  *)
(* phase's invariant (ClearKeep.Pc), 2026-11-06.                          *)
(*                                                                        *)
(* The walk of generated/object_collision.v:                              *)
(*   clear_object_collision(head)    each node of the list: numColl = 0,  *)
(*                                   types = 0, the timer (raw[5]) - 1;  *)
(*   detect_object_hitbox_overlap(a, b)  a.coll[a.n] = b, b.coll[b.n] = a,*)
(*                                   the types ORs, a.n++, b.n++ (after   *)
(*                                   the >= 4 tests);                     *)
(*   detect_object_hurtbox_overlap(a, b) b.raw[66] |= 2 or &= ~2;         *)
(*   check_collision_in_list(a, b, head) b over the nodes after a's      *)
(*                                   cursor to the head;                 *)
(*   check_player / pushable / destructive_object_collision, the lists'  *)
(*                                   outer loops;                         *)
(*   detect_object_collisions        the seven clears and the three.     *)
(* Each store is one of CollKeep.coll_store_pc's (a collision cell of a   *)
(* slot of a walked list, with the value the code stores); the rings are  *)
(* unchanged by them, so the walk's ring facts hold throughout.  The two *)
(* objects of a hitbox test are distinct (NoDup of the rings: b ranges    *)
(* over the nodes after a, or another list), so Mario's new partner is    *)
(* another listed object (ow_mario's kind_ok).                            *)
(* PHANTOM CHECK: the only premise is Pc (and sqrtf's memory, TRUST 4.1). *)
(* ====================================================================== *)

From Coq Require Import ZArith Lia List Bool.
From compcert Require Import Coqlib Integers Floats Values AST Ctypes Cop Clight
  ClightBigstep Clightdefs Memory Maps Globalenvs Events Errors Linking.
From SM64.Generated Require object_collision object_list_processor level_update mario math_util.
From SM64.Proofs Require Import SymbolicLinking RealFrameLinked LinkedTwelve CensusV2 MWFReal
  SpawnInit ActionValueFrame NoAImpliesNoFlyLinked AGates.
From SM64.Proofs Require MtxfBody.
From SM64.Proofs Require Import HeightInvariant WMotRWorld FrameSplit.
From SM64.Proofs.WMotRRequiresA Require Import RenderAnim FpuFloor.
From SM64.Proofs.WMotRRequiresA Require ObjWorld ObjLoop ObjPhase PollKeep PlatformKeep ClearKeep
  CollKeep PlatformWalk.
Import ListNotations.
Local Open Scope Z_scope.
Local Transparent Archi.ptr64.

Module OW := ObjWorld.
Module OLP := object_list_processor.
Module OC := object_collision.

Definition tobj : type := tptr (Tstruct OC._Object noattr).
Definition tnd : type := tptr (Tstruct OC._ObjectNode noattr).

(* ---------------------------------------------------------------------- *)
(* 1. Generic facts.                                                       *)
(* ---------------------------------------------------------------------- *)
Lemma seq_assoc : forall (G : genv) e le m a b c t le' m' out,
  exec_stmt function_entry2 G e le m (Ssequence (Ssequence a b) c) t le' m' out ->
  exists t', exec_stmt function_entry2 G e le m (Ssequence a (Ssequence b c)) t' le' m' out.
Proof.
  intros G e le m a b c t le' m' out H. inv H.
  - match goal with H1 : exec_stmt _ _ _ _ _ (Ssequence a b) _ _ _ Out_normal |- _ => inv H1 end.
    + eexists. eapply exec_Sseq_1; [ eassumption | eapply exec_Sseq_1; eassumption ].
    + congruence.
  - match goal with H1 : exec_stmt _ _ _ _ _ (Ssequence a b) _ _ _ _ |- _ => inv H1 end.
    + eexists. eapply exec_Sseq_1; [ eassumption | eapply exec_Sseq_2; eassumption ].
    + eexists. eapply exec_Sseq_2; eassumption.
Qed.

Lemma seq_assoc_r : forall (G : genv) e le m a b c t le' m' out,
  exec_stmt function_entry2 G e le m (Ssequence a (Ssequence b c)) t le' m' out ->
  exists t', exec_stmt function_entry2 G e le m (Ssequence (Ssequence a b) c) t' le' m' out.
Proof.
  intros G e le m a b c t le' m' out H. inv H.
  - match goal with H1 : exec_stmt _ _ _ _ _ (Ssequence b c) _ _ _ _ |- _ => inv H1 end.
    + eexists. eapply exec_Sseq_1; [ eapply exec_Sseq_1; eassumption | eassumption ].
    + eexists. eapply exec_Sseq_2; [ eapply exec_Sseq_1; eassumption | assumption ].
  - eexists. eapply exec_Sseq_2; [ eapply exec_Sseq_2; eassumption | assumption ].
Qed.

Lemma fentry : forall (G : genv) f m vargs t m' vr,
  eval_funcall function_entry2 G m (Internal f) vargs t m' vr -> fn_vars f = [] ->
  exists le le' out, bind_parameter_temps (fn_params f) vargs (create_undef_temps (fn_temps f)) = Some le
    /\ exec_stmt function_entry2 G empty_env le m (fn_body f) t le' m' out.
Proof.
  intros G f m vargs t m' vr H Hv.
  remember (Internal f) as fd eqn:Efd.
  destruct H as [mm ff va tt ee lea leb mm1 mm2 oo vv mm3 Hfe Hx Hor Hfr | ];
    [ injection Efd as Eff; subst ff | discriminate Efd ].
  destruct Hfe as [_ _ _ Hav Hb].
  rewrite Hv in Hav. inversion Hav; subst ee mm1.
  cbn in Hfr. injection Hfr as <-. eauto.
Qed.

Lemma cmp_self_o : forall (G : genv) m v r,
  sem_binary_operation G One v tobj v tobj m = Some r -> r = Vint Int.zero.
Proof.
  intros G m v r H. cbn in H. unfold cmp_ptr in H.
  destruct v; cbn [Archi.ptr64 Val.cmpu_bool] in H; try discriminate H.
  - unfold Int.cmpu in H. rewrite Int.eq_true in H. cbn in H. injection H as <-. reflexivity.
  - destruct (eq_block b b) as [_ | N]; [ | exfalso; exact (N eq_refl) ].
    match type of H with context [if ?c then _ else _] => destruct c end; [ | discriminate H ].
    cbn [option_map] in H. unfold Ptrofs.cmpu in H. rewrite Ptrofs.eq_true in H.
    cbn in H. injection H as <-. reflexivity.
Qed.

Lemma cast_po : forall v v' m, sem_cast v tnd tobj m = Some v' -> v' = v.
Proof. intros v v' m H. destruct v; cbn in H; try discriminate; injection H; intros <-; reflexivity. Qed.
Lemma cast_oo : forall v v' m, sem_cast v tobj tobj m = Some v' -> v' = v.
Proof. intros v v' m H. destruct v; cbn in H; try discriminate; injection H; intros <-; reflexivity. Qed.

(* an integer operator's result on 32-bit int operands is an int *)
Lemma binop_vint : forall (G : genv) m op v1 t1 v2 t2 v, sem_binary_operation G op v1 t1 v2 t2 m = Some v -> In op [Oadd; Osub; Oor; Oand] ->
  In t1 [tint; tuint; tshort] -> In t2 [tint; tuint] -> exists x, v = Vint x.
Proof.
  intros G m op v1 t1 v2 t2 v H Hop H1 H2.
  destruct Hop as [<- | [<- | [<- | [<- | []]]]];
  destruct H1 as [<- | [<- | [<- | []]]]; destruct H2 as [<- | [<- | []]];
  destruct v1, v2; cbn in H; try discriminate H.
  all: repeat match type of H with context [if ?c then _ else _] => destruct c end.
  all: try discriminate H; injection H; intros <-; eauto.
Qed.

Lemma cast_vint : forall x t1 t2 v m, sem_cast (Vint x) t1 t2 m = Some v -> In t1 [tint; tuint] -> In t2 [tint; tuint; tshort] -> exists y, v = Vint y.
Proof.
  intros x t1 t2 v m H H1 H2.
  destruct H1 as [<- | [<- | []]]; destruct H2 as [<- | [<- | [<- | []]]];
    cbn in H; injection H; intros <-; eauto.
Qed.

Lemma u_add : forall o d, 0 <= d -> Ptrofs.unsigned o + d <= Ptrofs.max_unsigned ->
  Ptrofs.unsigned (Ptrofs.add o (Ptrofs.repr d)) = Ptrofs.unsigned o + d.
Proof.
  intros o d H0 H1. pose proof (Ptrofs.unsigned_range o) as R.
  rewrite Ptrofs.add_unsigned, (Ptrofs.unsigned_repr d) by lia. apply Ptrofs.unsigned_repr. lia.
Qed.

Lemma maxu : Ptrofs.max_unsigned = 4294967295.
Proof. reflexivity. Qed.

Lemma u2 : forall a b, 0 <= a -> 0 <= b -> a + b <= Ptrofs.max_unsigned ->
  Ptrofs.unsigned (Ptrofs.add (Ptrofs.repr a) (Ptrofs.repr b)) = a + b.
Proof.
  intros a b Ha Hb Hs. rewrite Ptrofs.add_unsigned.
  rewrite (Ptrofs.unsigned_repr a), (Ptrofs.unsigned_repr b) by lia. apply Ptrofs.unsigned_repr. lia.
Qed.

Lemma u3 : forall a b c, 0 <= a -> 0 <= b -> 0 <= c -> a + b + c <= Ptrofs.max_unsigned ->
  Ptrofs.unsigned (Ptrofs.add (Ptrofs.add (Ptrofs.repr a) (Ptrofs.repr b)) (Ptrofs.repr c)) = a + (b + c).
Proof.
  intros a b c Ha Hb Hc Hs. rewrite (Ptrofs.add_unsigned _ (Ptrofs.repr c)), u2 by lia.
  rewrite (Ptrofs.unsigned_repr c) by lia. rewrite Ptrofs.unsigned_repr by lia. lia.
Qed.

Lemma u_slot : forall k, 0 <= k < OW.NSLOT -> Ptrofs.unsigned (Ptrofs.repr (k * OW.OSZ)) = k * OW.OSZ.
Proof. intros k Hk. apply Ptrofs.unsigned_repr. rewrite maxu. unfold OW.OSZ, OW.NSLOT in *. lia. Qed.

Lemma slot_inj : forall pool k k', 0 <= k < OW.NSLOT -> 0 <= k' < OW.NSLOT ->
  OW.slot_v pool k = OW.slot_v pool k' -> k = k'.
Proof.
  intros pool k k' Hk Hk' E0. unfold OW.slot_v in E0.
  assert (E : Ptrofs.repr (k * OW.OSZ) = Ptrofs.repr (k' * OW.OSZ)) by congruence.
  apply (f_equal Ptrofs.unsigned) in E. rewrite !u_slot in E by assumption.
  unfold OW.OSZ in E. lia.
Qed.

(* a slot's cell at d *)
Lemma slot_cell : forall k d, 0 <= k < OW.NSLOT -> 0 <= d < 608 ->
  Ptrofs.unsigned (Ptrofs.add (Ptrofs.repr (k * OW.OSZ)) (Ptrofs.repr d)) = k * OW.OSZ + d.
Proof.
  intros k d Hk Hd. rewrite u_add, u_slot by (try rewrite u_slot by exact Hk; rewrite ?maxu; unfold OW.OSZ, OW.NSLOT in *; lia).
  reflexivity.
Qed.

(* lists *)
Lemma all_some_len : forall {A} (l : list (option A)) r, OW.all_some l = Some r -> length r = length l.
Proof.
  intros A l. induction l as [| x l IH]; intros r H; cbn in H.
  - injection H as <-. reflexivity.
  - destruct x as [x|]; [ | discriminate H ].
    destruct (OW.all_some l) as [r'|] eqn:E; [ | discriminate H ]. injection H as <-.
    cbn. f_equal. exact (IH r' eq_refl).
Qed.

Lemma in_nth_concat : forall (rs : list (list Z)) i k, In k (nth i rs []) -> In k (concat rs).
Proof.
  induction rs as [| l rs IH]; intros i k H; [ destruct i; contradiction | ].
  cbn. apply in_or_app. destruct i as [| i]; [ left; exact H | right; exact (IH i k H) ].
Qed.

Lemma in_concat_nth : forall (rs : list (list Z)) k, In k (concat rs) ->
  exists i, (i < length rs)%nat /\ In k (nth i rs []).
Proof.
  induction rs as [| l rs IH]; intros k H; [ contradiction | ].
  cbn in H. apply in_app_or in H as [H | H].
  - exists 0%nat. split; [ cbn; lia | exact H ].
  - destruct (IH k H) as (i & Hi & Hk). exists (S i). split; [ cbn; lia | exact Hk ].
Qed.

Lemma nodup_app_disj : forall (l1 l2 : list Z) x, NoDup (l1 ++ l2) -> In x l1 -> In x l2 -> False.
Proof.
  induction l1 as [| y l1 IH]; intros l2 x H H1 H2; [ contradiction | ].
  cbn in H. apply NoDup_cons_iff in H as (Hni & Hnd). destruct H1 as [<- | H1].
  - apply Hni. apply in_or_app. right. exact H2.
  - exact (IH l2 x Hnd H1 H2).
Qed.

Lemma nodup_nth : forall (rs : list (list Z)) i, NoDup (concat rs) -> NoDup (nth i rs []).
Proof.
  induction rs as [| l rs IH]; intros i H; [ destruct i; constructor | ].
  cbn in H. destruct i as [| i]; cbn.
  - exact (NoDup_app_remove_r _ _ H).
  - exact (IH i (NoDup_app_remove_l _ _ H)).
Qed.

Lemma nodup_disj : forall (rs : list (list Z)) i j k, NoDup (concat rs) -> i <> j ->
  In k (nth i rs []) -> In k (nth j rs []) -> False.
Proof.
  induction rs as [| l rs IH]; intros i j k H Ne Hi Hj; [ destruct i; contradiction | ].
  cbn in H. destruct i as [| i], j as [| j]; cbn in Hi, Hj.
  - exact (Ne eq_refl).
  - exact (nodup_app_disj _ _ _ H Hi (in_nth_concat _ _ _ Hj)).
  - exact (nodup_app_disj _ _ _ H Hj (in_nth_concat _ _ _ Hi)).
  - exact (IH i j k (NoDup_app_remove_l _ _ H) ltac:(congruence) Hi Hj).
Qed.

(* the nodes after a node of a duplicate-free list do not hold it *)
Lemma nodup_after : forall (l pre post : list Z) k, NoDup l -> l = pre ++ k :: post -> ~ In k post.
Proof.
  intros l pre post k H -> Hin. apply NoDup_remove_2 in H. apply H. apply in_or_app. right. exact Hin.
Qed.

(* a while loop whose every round either breaks with Q or goes on with Inv *)
Section WH.
  Variable G : genv.
  Variables (c : expr) (body : statement).
  Variable Inv : temp_env -> mem -> Prop.
  Variable Q : mem -> Prop.
  Hypothesis Hstep : forall le m t le1 m1 out1, Inv le m ->
    exec_stmt function_entry2 G empty_env le m (Ssequence (Sifthenelse c Sskip Sbreak) body) t le1 m1 out1 ->
    (out1 = Out_break /\ Q m1) \/ (out1 = Out_normal /\ Inv le1 m1).

  Lemma while_keep : forall le m t le' m' out, Inv le m ->
    exec_stmt function_entry2 G empty_env le m (Swhile c body) t le' m' out -> Q m' /\ out = Out_normal.
  Proof.
    intros le m t le' m' out HI H. unfold Swhile in H.
    remember empty_env as e0 eqn:Ee in H.
    remember (Sloop (Ssequence (Sifthenelse c Sskip Sbreak) body) Sskip) as S eqn:ES.
    revert HI. induction H; intros HI; try discriminate ES; injection ES as E1 E2; subst.
    - destruct (Hstep _ _ _ _ _ _ HI H) as [(-> & HQ) | (-> & _)].
      + inv H0. split; [ exact HQ | reflexivity ].
      + inv H0.
    - inv H1. inv H2.
    - destruct (Hstep _ _ _ _ _ _ HI H) as [(-> & _) | (-> & HI1)]; [ inv H0 | ].
      inv H1. exact (IHexec_stmt3 eq_refl eq_refl HI1).
  Qed.
End WH.

(* a statement with no store and no call leaves memory alone *)
Fixpoint pure (s : statement) : bool :=
  match s with
  | Sskip | Sset _ _ | Sbreak | Scontinue | Sreturn _ | Sgoto _ => true
  | Ssequence s1 s2 | Sifthenelse _ s1 s2 | Sloop s1 s2 => pure s1 && pure s2
  | Slabel _ s1 => pure s1
  | _ => false
  end.

Lemma pure_mem : forall (G : genv) e le m s t le' m' out,
  exec_stmt function_entry2 G e le m s t le' m' out -> pure s = true -> m' = m.
Proof.
  intros G e le m s t le' m' out H. induction H; intros Hp; cbn [pure] in Hp; try discriminate Hp.
  all: repeat match goal with Ha : (_ && _) = true |- _ => apply andb_prop in Ha; destruct Ha end.
  all: try reflexivity.
  all: try (match goal with IH : pure (if ?b then _ else _) = true -> _ |- _ => destruct b end).
  all: repeat match goal with IH : pure ?s = true -> ?a = ?b, Hs : pure ?s = true |- _ =>
                let E := fresh "E" in pose proof (IH Hs) as E; clear IH; subst a end.
  all: try reflexivity.
  all: match goal with IH : pure _ = true -> _ = _ |- _ =>
         apply IH; cbn [pure];
         repeat match goal with Hb : pure _ = true |- _ => rewrite Hb; clear Hb end; reflexivity end.
Qed.

Lemma exl3 : forall (G : genv) e le m a1 a2 a3 tys vs, eval_exprlist G e le m [a1; a2; a3] tys vs ->
  exists ty1 ty2 ty3 v1 v2 v3 w1 w2 w3, tys = [ty1; ty2; ty3] /\ vs = [w1; w2; w3]
    /\ eval_expr G e le m a1 v1 /\ sem_cast v1 (typeof a1) ty1 m = Some w1
    /\ eval_expr G e le m a2 v2 /\ sem_cast v2 (typeof a2) ty2 m = Some w2
    /\ eval_expr G e le m a3 v3 /\ sem_cast v3 (typeof a3) ty3 m = Some w3.
Proof.
  intros G e le m a1 a2 a3 tys vs H. inv H.
  match goal with Hx : eval_exprlist _ _ _ _ (_ :: _ :: nil) _ _ |- _ => inv Hx end.
  match goal with Hx : eval_exprlist _ _ _ _ (_ :: nil) _ _ |- _ => inv Hx end.
  match goal with Hx : eval_exprlist _ _ _ _ nil _ _ |- _ => inv Hx end. eauto 30.
Qed.

(* ---------------------------------------------------------------------- *)
(* 2. The walk tactics.                                                    *)
(* ---------------------------------------------------------------------- *)
(* flatten the head of H *)
Ltac fl H := repeat (apply seq_assoc in H; destruct H as (? & H)).

(* H : exec (x = a; rest)  ->  H : exec rest, Ev : eval a v *)
Ltac sx H Ev :=
  fl H;
  let H1 := fresh "S" in let Hn := fresh "N" in
  apply seq_inv in H; destruct H as [(? & ? & ? & ? & H1 & H) | (H1 & Hn)];
  [ apply set_inv in H1; destruct H1 as (? & Ev & -> & -> & _)
  | apply set_inv in H1; destruct H1 as (_ & _ & _ & _ & H1); exfalso; exact (Hn H1) ].

Lemma break_inv : forall (G : genv) e le m t le' m' out,
  exec_stmt function_entry2 G e le m Sbreak t le' m' out -> m' = m /\ le' = le /\ out = Out_break.
Proof. intros. inv H. auto. Qed.

Ltac sx_ H := let E := fresh "E" in sx H E; clear E.

(* H : exec (lhs = rhs; rest)  ->  A : exec (lhs = rhs) ending in m1, H : exec rest *)
Ltac sa H A m1 :=
  fl H; let Hn := fresh "N" in
  apply seq_inv in H; destruct H as [(? & ? & m1 & ? & A & H) | (A & Hn)];
  [ | exfalso; apply assign_inv in A; destruct A as (_ & _ & _ & _ & _ & _ & _ & _ & _ & _ & A); exact (Hn A) ].

Lemma ifas_inv : forall (G : genv) le m c x a l r t le' m' out,
  exec_stmt function_entry2 G empty_env le m (Sifthenelse c (Ssequence (Sset x a) (Sassign l r)) Sskip) t le' m' out ->
  out = Out_normal /\ ((m' = m /\ le' = le) \/ exists v t2, eval_expr G empty_env le m a v /\
     exec_stmt function_entry2 G empty_env (PTree.set x v le) m (Sassign l r) t2 le' m' Out_normal).
Proof.
  intros G le m c x a l r t le' m' out H. apply if_inv in H as (cv & cb & _ & _ & H). destruct cb; cbv iota in H.
  - apply seq_inv in H as [(t1 & le1 & m1 & t2 & H1 & H2) | (H1 & Hn)].
    + apply set_inv in H1 as (v & Ev & -> & -> & _).
      pose proof H2 as H3. apply assign_inv in H3 as (_ & _ & _ & _ & _ & _ & _ & _ & _ & _ & ->).
      split; [ reflexivity | right; eauto ].
    + apply set_inv in H1 as (_ & _ & _ & _ & H1). exfalso. exact (Hn H1).
  - apply skip_inv in H as (-> & -> & ->). split; [ reflexivity | left; auto ].
Qed.

(* H : exec (if c then s1 else s2; rest) with s1, s2 each a skip, return or
   break: the run either stops there (memory unchanged) or goes on with rest *)
Ltac sif H Ec Eb :=
  fl H;
  let H1 := fresh "S" in let Hn := fresh "N" in
  let cb := fresh "cb" in
  apply seq_inv in H; destruct H as [(? & ? & ? & ? & H1 & H) | (H1 & Hn)];
  apply if_inv in H1; destruct H1 as (? & cb & Ec & Eb & H1); destruct cb; cbv iota in H1;
  first [ apply skip_inv in H1; destruct H1 as (-> & -> & H1); try (exfalso; exact (Hn H1))
        | apply ret_inv in H1; destruct H1 as (-> & ? & ? & H1); try discriminate H1
        | apply break_inv in H1; destruct H1 as (-> & -> & H1); try discriminate H1
        | idtac ].

Lemma sz_ok_oc : ObjLoop.sz_ok (prog_comp_env OC.prog) OC._ObjectNode OW.NODESZ = true.
Proof. vm_compute. reflexivity. Qed.

(* ev_fun / ev_gvar with the expression first, so the type is known *)
Lemma evf : forall (G : genv) m le id ty v, eval_expr G empty_env le m (Evar id ty) v ->
  access_mode ty = By_reference -> exists b, Genv.find_symbol G id = Some b /\ v = Vptr b Ptrofs.zero.
Proof. intros G m le id ty v H A. exact (ev_fun G empty_env m le id ty v (PTree.gempty _ _) A H). Qed.

Lemma evg : forall (G : genv) m le id ty v ch, eval_expr G empty_env le m (Evar id ty) v ->
  access_mode ty = By_value ch -> exists b, Genv.find_symbol G id = Some b /\ Mem.loadv ch m (Vptr b Ptrofs.zero) = Some v.
Proof. intros G m le id ty v ch H A. exact (ev_gvar G empty_env m le id ty v ch (PTree.gempty _ _) A H). Qed.

Section CW.
  Variable lp : Clight.program.
  Hypothesis H12 : linked12 lp.
  Notation G := (lp_ge lp).
  Variable bm : block.
  Hypothesis Hbm_sym : Genv.find_symbol G level_update._gMarioStates = Some bm.
  Variables (bc : block) (oc0 : ptrofs) (SafeB : block -> Prop).
  Hypothesis HSafeB_syms : SafeB_syms_ok lp SafeB.
  Hypothesis Hbc_sym : Genv.find_symbol G mario._gControllers = Some bc.
  Hypothesis Hoc0 : oc0 = Ptrofs.zero.
  Hypothesis Hsq : sqrtf_spec.
  Notation Pc := (ClearKeep.Pc lp bm bc oc0 SafeB).

  (* ---- 3. object_collision.c's layout in the linked program ---- *)
  Lemma cenv_oc : forall id co, (prog_comp_env OC.prog) ! id = Some co -> (genv_cenv G) ! id = Some co.
  Proof.
    intros id co H. pose proof (linked12_LO_object_collision lp H12) as LO.
    Local Transparent Linker_program.
    unfold linkorder, Linker_program, linkorder_program in LO. destruct LO as [_ HCo].
    exact (HCo id co H).
  Qed.

  Ltac fot := apply (fo_ok_lift (prog_comp_env OC.prog)); [ vm_compute; reflexivity | exact cenv_oc ].
  Lemma fo_ncoll : forall co, (genv_cenv G) ! OC._Object = Some co ->
    field_offset G OC._numCollidedObjs (co_members co) = OK (118, Full).
  Proof. fot. Qed.
  Lemma fo_types : forall co, (genv_cenv G) ! OC._Object = Some co ->
    field_offset G OC._collidedObjInteractTypes (co_members co) = OK (112, Full).
  Proof. fot. Qed.
  Lemma fo_colls : forall co, (genv_cenv G) ! OC._Object = Some co ->
    field_offset G OC._collidedObjs (co_members co) = OK (120, Full).
  Proof. fot. Qed.
  Lemma fo_raw : forall co, (genv_cenv G) ! OC._Object = Some co ->
    field_offset G OC._rawData (co_members co) = OK (136, Full).
  Proof. fot. Qed.
  Lemma fo_hdr : forall co, (genv_cenv G) ! OC._Object = Some co ->
    field_offset G OC._header (co_members co) = OK (0, Full).
  Proof. fot. Qed.
  Lemma fo_nx : forall co, (genv_cenv G) ! OC._ObjectNode = Some co ->
    field_offset G OC._next (co_members co) = OK (96, Full).
  Proof. fot. Qed.
  Lemma ufo_s32 : forall co, (genv_cenv G) ! OC.__764 = Some co ->
    union_field_offset G OC._asS32 (co_members co) = OK (0, Full).
  Proof. apply (PlatformWalk.ufo_ok_lift (prog_comp_env OC.prog)); [ vm_compute; reflexivity | exact cenv_oc ]. Qed.
  Lemma ufo_u32 : forall co, (genv_cenv G) ! OC.__764 = Some co ->
    union_field_offset G OC._asU32 (co_members co) = OK (0, Full).
  Proof. apply (PlatformWalk.ufo_ok_lift (prog_comp_env OC.prog)); [ vm_compute; reflexivity | exact cenv_oc ]. Qed.
  Lemma sz_nd : sizeof G (Tstruct OC._ObjectNode noattr) = OW.NODESZ.
  Proof. exact (ObjLoop.sz_ok_lift _ _ _ _ sz_ok_oc cenv_oc). Qed.

  Local Ltac kill_r :=
    try (match goal with Ha : access_mode _ = _ |- _ => cbn in Ha; discriminate Ha end);
    try (match goal with Ht : typeof _ = _ |- _ => cbn in Ht; discriminate Ht end);
    try (match goal with Hb : load_bitfield _ _ _ _ _ _ _ _ |- _ => inv Hb end).

  (* o->collidedObjs[n], written *)
  Lemma lv_coll : forall m le x n b o bf,
    eval_lvalue G empty_env le m
      (Ederef (Ebinop Oadd (Efield (Ederef (Etempvar x tobj) (Tstruct OC._Object noattr)) OC._collidedObjs (tarray tobj 4))
         (Etempvar n tshort) (tptr tobj)) tobj) b o bf ->
    exists o0 i, le ! x = Some (Vptr b o0) /\ le ! n = Some (Vint i) /\ bf = Full /\
      o = Ptrofs.add (Ptrofs.add o0 (Ptrofs.repr 120)) (Ptrofs.mul (Ptrofs.repr 4) (Ptrofs.of_ints i)).
  Proof.
    intros m le x n b o bf H. inv H.
    match goal with Hb : eval_expr _ _ _ _ (Ebinop _ _ _ _) _ |- _ =>
      apply ev_binop in Hb; destruct Hb as (v1 & v2 & E1 & E2 & E3) end.
    apply ev_temp in E2. inv E1. cbn [typeof] in E3.
    match goal with H0 : deref_loc _ _ _ _ _ _ |- _ => inv H0 end; kill_r.
    match goal with Hl : eval_lvalue _ _ _ _ (Efield _ _ _) _ _ _ |- _ =>
      destruct (lv_fld G empty_env m le x OC._Object OC._collidedObjs _ _ _ _ 120 fo_colls Hl) as (o0 & Hx & -> & _) end.
    destruct v2; cbn in E3; try discriminate E3.
    injection E3 as <- <-. exists o0, i. repeat split; auto.
  Qed.

  (* o->rawData.as{S,U}32[idx], written *)
  Lemma lv_rawk : forall m le x fu ety idx b o bf,
    (forall co, (genv_cenv G) ! OC.__764 = Some co -> union_field_offset G fu (co_members co) = OK (0, Full)) ->
    eval_lvalue G empty_env le m
      (Ederef (Ebinop Oadd (Efield (Efield (Ederef (Etempvar x tobj) (Tstruct OC._Object noattr))
          OC._rawData (Tunion OC.__764 noattr)) fu (tarray ety 80))
         (Econst_int (Int.repr idx) tint) (tptr ety)) ety) b o bf ->
    exists b0 o0, le ! x = Some (Vptr b0 o0) /\ bf = Full /\
      sem_binary_operation G Oadd (Vptr b0 (Ptrofs.add (Ptrofs.add o0 (Ptrofs.repr 136)) (Ptrofs.repr 0)))
        (tarray ety 80) (Vint (Int.repr idx)) tint m = Some (Vptr b o).
  Proof.
    intros m le x fu ety idx b o bf Hu HL.
    inv HL.
    match goal with Hb : eval_expr _ _ _ _ (Ebinop _ _ _ _) _ |- _ =>
      apply ev_binop in Hb; destruct Hb as (v1 & v2 & E1 & E2 & E3) end.
    apply ev_const in E2. subst v2.
    inv E1. cbn [typeof] in E3.
    match goal with H0 : deref_loc _ _ _ _ _ _ |- _ => inv H0 end; kill_r.
    all: match goal with H : eval_lvalue _ _ _ _ (Efield _ _ _) _ _ _ |- _ => inv H end; kill_r.
    all: match goal with Ht : typeof _ = Tunion _ _ |- _ => cbn in Ht; injection Ht as <- <- end.
    all: match goal with Hf : union_field_offset _ _ (co_members ?co) = OK _, Hc : _ ! _ = Some ?co |- _ =>
           rewrite (Hu _ Hc) in Hf; injection Hf; intros; subst end.
    all: match goal with He : eval_expr _ _ _ _ (Efield _ _ _) _ |- _ => inv He end.
    all: match goal with Hd2 : deref_loc (typeof (Efield _ _ _)) _ _ _ _ _ |- _ =>
           cbn [typeof] in Hd2; inv Hd2 end; kill_r.
    all: match goal with Hl : eval_lvalue _ _ _ _ (Efield _ _ _) _ _ _ |- _ => inv Hl end; kill_r.
    all: match goal with Ht : typeof _ = Tstruct _ _ |- _ => cbn in Ht; injection Ht as <- <- end.
    all: match goal with Hf : field_offset _ _ (co_members ?co) = OK _, Hc : _ ! _ = Some ?co |- _ =>
           rewrite (fo_raw _ Hc) in Hf; injection Hf; intros; subst end.
    all: match goal with He : eval_expr _ _ _ _ (Ederef _ _) _ |- _ => inv He end.
    all: match goal with Hd2 : deref_loc (typeof (Ederef _ _)) _ _ _ _ _ |- _ =>
           cbn [typeof] in Hd2; inv Hd2 end; kill_r.
    all: match goal with Hl : eval_lvalue _ _ _ _ (Ederef _ _) _ _ _ |- _ => inv Hl end.
    all: match goal with Ht : eval_expr _ _ _ _ (Etempvar _ _) _ |- _ => apply ev_temp in Ht end.
    all: do 2 eexists; split; [ eassumption | split; [ reflexivity | exact E3 ] ].
  Qed.

  Lemma ofs4 : forall k, 0 <= k < 80 ->
    Ptrofs.mul (Ptrofs.repr 4) (Ptrofs.of_ints (Int.repr k)) = Ptrofs.repr (4 * k).
  Proof.
    intros k Hk. unfold Ptrofs.of_ints. rewrite Int.signed_repr by (cbn; lia).
    unfold Ptrofs.mul. rewrite !Ptrofs.unsigned_repr by (rewrite maxu; lia). reflexivity.
  Qed.

  Lemma raw_k : forall b0 b k0 k o m ety, 0 <= k0 < OW.NSLOT -> 0 <= k < 80 -> In ety [tint; tuint] ->
    sem_binary_operation G Oadd (Vptr b0 (Ptrofs.add (Ptrofs.add (Ptrofs.repr (k0 * OW.OSZ)) (Ptrofs.repr 136)) (Ptrofs.repr 0)))
      (tarray ety 80) (Vint (Int.repr k)) tint m = Some (Vptr b o) ->
    b = b0 /\ Ptrofs.unsigned o = k0 * OW.OSZ + (136 + 4 * k).
  Proof.
    intros b0 b k0 k o m ety Hk0 Hk Hty H.
    assert (E : Ptrofs.add (Ptrofs.add (Ptrofs.repr (k0 * OW.OSZ)) (Ptrofs.repr 136)) (Ptrofs.repr 0)
                = Ptrofs.add (Ptrofs.repr (k0 * OW.OSZ)) (Ptrofs.repr 136)) by apply Ptrofs.add_zero.
    rewrite E in H.
    destruct Hty as [<- | [<- | []]].
    all: match type of H with sem_binary_operation _ _ ?v1 (tarray ?ty _) ?v2 _ _ = _ =>
           assert (E2 : sem_binary_operation G Oadd v1 (tarray ty 80) v2 tint m
                        = Some (Vptr b0 (Ptrofs.add (Ptrofs.add (Ptrofs.repr (k0 * OW.OSZ)) (Ptrofs.repr 136))
                                          (Ptrofs.mul (Ptrofs.repr 4) (Ptrofs.of_ints (Int.repr k)))))) by reflexivity end.
    all: rewrite E2 in H; injection H as <- <-; split; [ reflexivity | ].
    all: rewrite ofs4 by exact Hk.
    all: unfold OW.OSZ, OW.NSLOT in *.
    all: rewrite u3; rewrite ?maxu; lia.
  Qed.

  Lemma coll_ofs : forall k i, 0 <= k < OW.NSLOT -> 0 <= Int.signed i < 4 ->
    Ptrofs.unsigned (Ptrofs.add (Ptrofs.add (Ptrofs.repr (k * OW.OSZ)) (Ptrofs.repr 120))
                       (Ptrofs.mul (Ptrofs.repr 4) (Ptrofs.of_ints i))) = k * OW.OSZ + (120 + 4 * Int.signed i).
  Proof.
    intros k i Hk Hi.
    assert (E : Ptrofs.mul (Ptrofs.repr 4) (Ptrofs.of_ints i) = Ptrofs.repr (4 * Int.signed i)).
    { unfold Ptrofs.of_ints, Ptrofs.mul. rewrite !Ptrofs.unsigned_repr by (rewrite maxu; lia). reflexivity. }
    rewrite E. unfold OW.OSZ, OW.NSLOT in *.
    rewrite u3; rewrite ?maxu; lia.
  Qed.

  (* p->header.next, read *)
  Lemma ev_hn : forall m le x v,
    eval_expr G empty_env le m (Efield (Efield (Ederef (Etempvar x tobj) (Tstruct OC._Object noattr))
        OC._header (Tstruct OC._ObjectNode noattr)) OC._next tnd) v ->
    exists b o, le ! x = Some (Vptr b o) /\
      Mem.loadv Mint32 m (Vptr b (Ptrofs.add (Ptrofs.add o (Ptrofs.repr 0)) (Ptrofs.repr 96))) = Some v.
  Proof.
    intros m le x v H. inv H.
    match goal with Hl : eval_lvalue _ _ _ _ (Efield _ _ _) _ _ _ |- _ => inv Hl end; kill_r.
    match goal with Ht : typeof _ = Tstruct _ _ |- _ => cbn in Ht; injection Ht as <- <- end.
    match goal with Hf : field_offset _ _ (co_members ?co) = OK _, Hc : _ ! _ = Some ?co |- _ =>
      rewrite (fo_nx _ Hc) in Hf; injection Hf; intros; subst end.
    match goal with He : eval_expr _ _ _ _ (Efield _ _ _) _ |- _ => inv He end.
    cbn [typeof] in *. match goal with Hd2 : deref_loc (Tstruct _ _) _ _ _ _ _ |- _ => inv Hd2 end; kill_r.
    match goal with Hl : eval_lvalue _ _ _ _ (Efield _ _ _) _ _ _ |- _ =>
      destruct (lv_fld G empty_env m le x OC._Object OC._header _ _ _ _ 0 fo_hdr Hl) as (o0 & Hx & -> & _) end.
    match goal with Hd : deref_loc tnd _ _ _ _ _ |- _ => inv Hd end; kill_r.
    match goal with Ha : access_mode _ = By_value _ |- _ => cbn in Ha; injection Ha as <- end.
    eexists _, o0. split; [ exact Hx | eassumption ].
  Qed.

  (* (gObjectLists + i)->next, read *)
  Lemma ev_headnx : forall m le t i v,
    eval_expr G empty_env le m (Efield (Ederef (Ebinop Oadd (Etempvar t tnd) (Econst_int (Int.repr i) tint) tnd)
        (Tstruct OC._ObjectNode noattr)) OC._next tnd) v ->
    exists b o, le ! t = Some (Vptr b o) /\
      Mem.loadv Mint32 m (Vptr b (Ptrofs.add (Ptrofs.add o (Ptrofs.mul (Ptrofs.repr OW.NODESZ) (Ptrofs.of_ints (Int.repr i))))
                                   (Ptrofs.repr 96))) = Some v.
  Proof.
    intros m le t i v H. inv H.
    match goal with Hl : eval_lvalue _ _ _ _ (Efield _ _ _) _ _ _ |- _ => inv Hl end; kill_r.
    match goal with Ht : typeof _ = Tstruct _ _ |- _ => cbn in Ht; injection Ht as <- <- end.
    match goal with Hf : field_offset _ _ (co_members ?co) = OK _, Hc : _ ! _ = Some ?co |- _ =>
      rewrite (fo_nx _ Hc) in Hf; injection Hf; intros; subst end.
    match goal with He : eval_expr _ _ _ _ (Ederef _ _) _ |- _ => inv He end.
    cbn [typeof] in *. match goal with Hd2 : deref_loc (Tstruct _ _) _ _ _ _ _ |- _ => inv Hd2 end; kill_r.
    match goal with Hl : eval_lvalue _ _ _ _ (Ederef _ _) _ _ _ |- _ => inv Hl end.
    match goal with Hb : eval_expr _ _ _ _ (Ebinop _ _ _ _) _ |- _ =>
      apply ev_binop in Hb; destruct Hb as (v1 & v2 & E1 & E2 & E3) end.
    apply ev_temp in E1. apply ev_const in E2. subst v2. cbn [typeof] in E3.
    destruct v1 as [| | | | | b0 o0]; try (cbn in E3; discriminate E3).
    assert (E : sem_binary_operation G Oadd (Vptr b0 o0) tnd (Vint (Int.repr i)) tint m
                = Some (Vptr b0 (Ptrofs.add o0 (Ptrofs.mul (Ptrofs.repr (sizeof G (Tstruct OC._ObjectNode noattr)))
                                                        (Ptrofs.of_ints (Int.repr i)))))) by reflexivity.
    rewrite E, sz_nd in E3. injection E3 as <- <-.
    match goal with Hd : deref_loc tnd _ _ _ _ _ |- _ => inv Hd end; kill_r.
    match goal with Ha : access_mode _ = By_value _ |- _ => cbn in Ha; injection Ha as <- end.
    exists b0, o0. split; [ exact E1 | assumption ].
  Qed.

  (* (struct Object * ) (gObjectLists + i), an argument *)
  Lemma ev_hdarg : forall m le t i v b o, eval_expr G empty_env le m (Ecast (Ebinop Oadd (Etempvar t tnd) (Econst_int (Int.repr i) tint) tnd) tobj) v -> le ! t = Some (Vptr b o) ->
    v = Vptr b (Ptrofs.add o (Ptrofs.mul (Ptrofs.repr OW.NODESZ) (Ptrofs.of_ints (Int.repr i)))).
  Proof.
    intros m le t i v b o H Ht. apply ev_cast in H as (v1 & H & C). cbn [typeof] in C.
    apply ev_binop in H as (w1 & w2 & E1 & E2 & E3). apply ev_temp in E1. apply ev_const in E2.
    subst w2. rewrite Ht in E1. injection E1 as <-. cbn [typeof] in E3.
    assert (E : sem_binary_operation G Oadd (Vptr b o) tnd (Vint (Int.repr i)) tint m
                = Some (Vptr b (Ptrofs.add o (Ptrofs.mul (Ptrofs.repr (sizeof G (Tstruct OC._ObjectNode noattr)))
                                                       (Ptrofs.of_ints (Int.repr i)))))) by reflexivity.
    rewrite E, sz_nd in E3. injection E3 as <-. exact (cast_po _ _ _ C).
  Qed.

  Lemma hd_ofs : forall i, (i < OW.NLIST)%nat ->
    Ptrofs.add Ptrofs.zero (Ptrofs.mul (Ptrofs.repr OW.NODESZ) (Ptrofs.of_ints (Int.repr (Z.of_nat i))))
    = Ptrofs.repr (Z.of_nat i * OW.NODESZ).
  Proof. intros i Hi. exact (ObjLoop.ofs_idx _ Hi). Qed.

  Lemma sne : forall id1 id2 b1 b2, Genv.find_symbol G id1 = Some b1 -> Genv.find_symbol G id2 = Some b2 ->
    id1 <> id2 -> b1 <> b2.
  Proof. intros id1 id2 b1 b2 H1 H2 Ne ->. apply Ne. eapply Genv.genv_vars_inj; eassumption. Qed.

  (* ---- 4. The walk's invariant: Pc, with the rings fixed ---- *)
  Section RW.
  Variables pool la gol gmo : block.
  Hypothesis Hpool : Genv.find_symbol G OLP._gObjectPool = Some pool.
  Hypothesis Hla : Genv.find_symbol G OLP._gObjectListArray = Some la.
  Hypothesis Hgol : Genv.find_symbol G OLP._gObjectLists = Some gol.
  Hypothesis Hgmo : Genv.find_symbol G OLP._gMarioObject = Some gmo.
  Variable rs : list (list Z).

  Definition R (m : mem) : Prop := Pc m /\ OW.rings m pool la = Some rs.

  Lemma pool_la : la <> pool.
  Proof. apply (sne _ _ _ _ Hla Hpool). vm_compute. discriminate. Qed.
  Lemma pool_gol : gol <> pool.
  Proof. apply (sne _ _ _ _ Hgol Hpool). vm_compute. discriminate. Qed.
  Lemma pool_gmo : gmo <> pool.
  Proof. apply (sne _ _ _ _ Hgmo Hpool). vm_compute. discriminate. Qed.

  Lemma R_core : forall m, R m -> exists fl sdp gdi fs, OW.ow_core G pool la fl gol gmo sdp gdi bm m rs fs.
  Proof.
    intros m ((_ & _ & _ & _ & (pool' & la' & fl & gol' & gmo' & sdp & gdi & rs' & fs & S1 & S2 & S3 & S4 & S5 & S6 & S7 & Hc)) & Hr).
    rewrite Hpool in S1. injection S1 as <-. rewrite Hla in S2. injection S2 as <-.
    rewrite Hgol in S4. injection S4 as <-. rewrite Hgmo in S5. injection S5 as <-.
    rewrite (OW.ow_rings _ _ _ _ _ _ _ _ _ _ _ _ Hc) in Hr. injection Hr as <-.
    exists fl, sdp, gdi, fs. exact Hc.
  Qed.

  Lemma R_len : forall m, R m -> length rs = OW.NLIST.
  Proof.
    intros m (_ & Hr). unfold OW.rings in Hr. rewrite (all_some_len _ _ Hr), map_length, seq_length. reflexivity.
  Qed.

  Lemma R_ring : forall m i, R m -> (i < OW.NLIST)%nat -> OW.ring_i m pool la i = Some (nth i rs []).
  Proof. intros m i (_ & Hr) Hi. exact (ObjLoop.rings_nth _ _ _ _ Hr i Hi). Qed.

  Lemma R_range : forall m k, R m -> In k (concat rs) -> 0 <= k < OW.NSLOT.
  Proof.
    intros m k HR Hk. destruct (in_concat_nth _ _ Hk) as (i & Hi & Hin). rewrite (R_len m HR) in Hi.
    destruct (ObjLoop.ring_i_spec _ _ _ _ _ (R_ring m i HR Hi)) as (_ & Hall). exact (proj1 (Hall k Hin)).
  Qed.

  Lemma R_nodup : forall m, R m -> NoDup (concat rs).
  Proof.
    intros m HR. destruct (R_core m HR) as (fl & sdp & gdi & fs & Hc).
    exact (NoDup_app_remove_r _ _ (proj1 (OW.ow_part _ _ _ _ _ _ _ _ _ _ _ _ Hc))).
  Qed.

  Lemma R_gol : forall m, R m -> Mem.load Mint32 m gol 0 = Some (Vptr la Ptrofs.zero).
  Proof.
    intros m HR. destruct (R_core m HR) as (fl & sdp & gdi & fs & Hc). exact (OW.ow_gol _ _ _ _ _ _ _ _ _ _ _ _ Hc).
  Qed.

  Lemma R_ncoll : forall m k, R m -> In k (concat rs) ->
    exists n, Mem.load Mint16signed m pool (k * OW.OSZ + 118) = Some (Vint n) /\ 0 <= Int.signed n <= 4.
  Proof.
    intros m k HR Hk. destruct (R_core m HR) as (fl & sdp & gdi & fs & Hc).
    exact (OW.ow_ncoll _ _ _ _ _ _ _ _ _ _ _ _ Hc k Hk).
  Qed.

  (* the node after a node of ring i, and the head's *)
  Lemma R_next : forall m i pre k post, R m -> (i < OW.NLIST)%nat -> nth i rs [] = pre ++ k :: post ->
    Mem.load Mint32 m pool (k * OW.OSZ + OW.O_NEXT) = Some (ObjLoop.first_v pool la (Z.of_nat i * OW.NODESZ) post).
  Proof.
    intros m i pre k post HR Hi E. destruct (ObjLoop.ring_i_order _ _ _ _ _ (R_ring m i HR Hi)) as (_ & H).
    exact (H pre k post E).
  Qed.
  Lemma R_head : forall m i, R m -> (i < OW.NLIST)%nat ->
    Mem.load Mint32 m la (Z.of_nat i * OW.NODESZ + OW.O_NEXT) = Some (ObjLoop.first_v pool la (Z.of_nat i * OW.NODESZ) (nth i rs [])).
  Proof. intros m i HR Hi. exact (proj1 (ObjLoop.ring_i_order _ _ _ _ _ (R_ring m i HR Hi))). Qed.

  (* Mario's partner: a listed object but him has its kind pinned *)
  Lemma partner : forall m k j, R m -> In k (concat rs) -> In j (concat rs) -> j <> k ->
    CollKeep.mario_at pool gmo m k -> j <> k /\ OW.kind_ok pool m j.
  Proof.
    intros m k j HR Hk Hj Ne Hma. split; [ exact Ne | ].
    destruct (R_core m HR) as (fl & sdp & gdi & fs & Hc).
    destruct (OW.ow_mario _ _ _ _ _ _ _ _ _ _ _ _ Hc) as (km & Hin & Hg & _ & Hko).
    unfold CollKeep.mario_at in Hma. rewrite Hg in Hma.
    assert (Hs : OW.slot_v pool km = OW.slot_v pool k) by congruence.
    apply slot_inj in Hs; [ subst km | exact (R_range m _ HR (in_nth_concat _ _ _ Hin)) | exact (R_range m k HR Hk) ].
    exact (Hko j Hj Ne).
  Qed.

  (* one store of the code *)
  Lemma cstore : forall m m2 k off ch v, R m -> 0 <= k < OW.NSLOT -> CollKeep.coll_cell off ch ->
    CollKeep.coll_val pool gmo m k off v -> Mem.store ch m pool (k * OW.OSZ + off) v = Some m2 -> R m2.
  Proof.
    intros m m2 k off ch v (HP & Hr) Hk Hc Hv St. split.
    - eapply CollKeep.coll_store_pc; eassumption.
    - rewrite <- Hr. apply (PollKeep.rings_eq m m2 pool la).
      + intros ch' k' off' H1 H2 H3 H4. eapply Mem.load_store_other; [ exact St | right ].
        unfold OW.OSZ in *.
        destruct (CollKeep.dj_ccl off ch k k' off' (size_chunk ch') Hc ltac:(lia) ltac:(lia)
                    ltac:(destruct ch'; cbn; lia) (or_intror H4)) as [D | D]; [ left; exact D | right; exact D ].
      + intros z. unfold OW.ld32. rewrite !OW.CM.load_eq. eapply Mem.load_store_other; [ exact St | left; exact pool_la ].
  Qed.

  Lemma cload : forall m m2 k off ch v k' off' ch', Mem.store ch m pool (k * OW.OSZ + off) v = Some m2 ->
    CollKeep.coll_cell off ch -> CollKeep.coll_cell off' ch' -> (k' <> k \/ off' <> off) ->
    Mem.load ch' m2 pool (k' * OW.OSZ + off') = Mem.load ch' m pool (k' * OW.OSZ + off').
  Proof.
    intros m m2 k off ch v k' off' ch' St Hc Hc' Ne. eapply Mem.load_store_other; [ exact St | right ].
    destruct (CollKeep.cc_same off ch off' ch' k k' Hc Hc') as [(-> & -> & ->) | D];
      [ exfalso; destruct Ne; congruence | unfold OW.OSZ; lia ].
  Qed.

  Lemma cv_int : forall m k off x, off = 112 \/ off = 156 \/ off = 400 -> CollKeep.coll_val pool gmo m k off (Vint x).
  Proof.
    intros m k off x H. split; [ intros E; exfalso; lia | split; [ intros E; exfalso; lia | intros _; eauto ] ].
  Qed.

  Lemma cv_ptr : forall m k off j, 120 <= off < 136 -> 0 <= j < OW.NSLOT ->
    (CollKeep.mario_at pool gmo m k -> j <> k /\ OW.kind_ok pool m j) ->
    CollKeep.coll_val pool gmo m k off (OW.slot_v pool j).
  Proof.
    intros m k off j H Hj Hm. split; [ intros E; exfalso; lia | split; [ intros _; eauto | intros E; exfalso; lia ] ].
  Qed.

  Lemma cv_n : forall m k x, Int.sign_ext 16 x = x -> 0 <= Int.signed x <= 4 ->
    (CollKeep.mario_at pool gmo m k -> forall i, 0 <= i < Int.signed x ->
       (exists n, Mem.load Mint16signed m pool (k * OW.OSZ + 118) = Some (Vint n) /\ i < Int.signed n)
       \/ (exists j, 0 <= j < OW.NSLOT /\ j <> k /\ OW.kind_ok pool m j
            /\ Mem.load Mint32 m pool (k * OW.OSZ + 120 + 4 * i) = Some (OW.slot_v pool j))) ->
    CollKeep.coll_val pool gmo m k 118 (Vint x).
  Proof.
    intros m k x H1 H2 H3. split; [ intros _; exists x; auto | split; [ intros E; exfalso; lia | intros E; exfalso; lia ] ].
  Qed.

  Lemma cc_n : CollKeep.coll_cell 118 Mint16signed.
  Proof. right; left; auto. Qed.
  Lemma cc_t : CollKeep.coll_cell 112 Mint32.
  Proof. left; auto. Qed.
  Lemma cc_c : forall i, 0 <= i < 4 -> CollKeep.coll_cell (120 + 4 * i) Mint32.
  Proof. intros i Hi. right; right; left; eauto. Qed.
  Lemma cc_5 : CollKeep.coll_cell 156 Mint32.
  Proof. right; right; right; left; auto. Qed.
  Lemma cc_66 : CollKeep.coll_cell 400 Mint32.
  Proof. right; right; right; right; auto. Qed.

  (* ---- 5. The code's stores, as stores into a slot's cells ---- *)
  Lemma slot_eq : forall le x k b o, le ! x = Some (OW.slot_v pool k) -> le ! x = Some (Vptr b o) ->
    b = pool /\ o = Ptrofs.repr (k * OW.OSZ).
  Proof. intros le x k b o H1 H2. rewrite H1 in H2. injection H2 as <- <-. auto. Qed.

  (* p->f = a2 *)
  Lemma asg_fld : forall le m t le' m' out x f ty a2 d ch k, exec_stmt function_entry2 G empty_env le m
      (Sassign (Efield (Ederef (Etempvar x tobj) (Tstruct OC._Object noattr)) f ty) a2) t le' m' out ->
    (forall co, (genv_cenv G) ! OC._Object = Some co -> field_offset G f (co_members co) = OK (d, Full)) ->
    access_mode ty = By_value ch -> 0 <= d < 608 ->
    le ! x = Some (OW.slot_v pool k) -> 0 <= k < OW.NSLOT ->
    exists v2 v, eval_expr G empty_env le m a2 v2 /\ sem_cast v2 (typeof a2) ty m = Some v /\
      Mem.store ch m pool (k * OW.OSZ + d) v = Some m' /\ le' = le /\ out = Out_normal.
  Proof.
    intros le m t le' m' out x f ty a2 d ch k H Hfo Ham Hd Hx Hk.
    apply assign_inv in H as (b & o & bf & v2 & v & Hlv & Ev & Hc & Has & -> & ->).
    destruct (lv_fld G empty_env m le x OC._Object f ty b o bf d Hfo Hlv) as (o0 & Hx' & -> & ->).
    destruct (slot_eq _ _ _ _ _ Hx Hx') as (-> & ->). cbn [typeof] in Hc, Has.
    pose proof (store_by_value G ty m pool _ Full v m' ch Ham eq_refl Has) as St.
    rewrite slot_cell in St by assumption.
    exists v2, v. auto.
  Qed.

  (* p->rawData.as{S,U}32[idx] = a2 *)
  Lemma asg_raw : forall le m t le' m' out x fu ety idx a2 k, exec_stmt function_entry2 G empty_env le m
      (Sassign (Ederef (Ebinop Oadd (Efield (Efield (Ederef (Etempvar x tobj) (Tstruct OC._Object noattr))
          OC._rawData (Tunion OC.__764 noattr)) fu (tarray ety 80)) (Econst_int (Int.repr idx) tint) (tptr ety)) ety)
        a2) t le' m' out ->
    (forall co, (genv_cenv G) ! OC.__764 = Some co -> union_field_offset G fu (co_members co) = OK (0, Full)) ->
    In ety [tint; tuint] -> 0 <= idx < 80 ->
    le ! x = Some (OW.slot_v pool k) -> 0 <= k < OW.NSLOT ->
    exists v2 v, eval_expr G empty_env le m a2 v2 /\ sem_cast v2 (typeof a2) ety m = Some v /\
      Mem.store Mint32 m pool (k * OW.OSZ + (136 + 4 * idx)) v = Some m' /\ le' = le /\ out = Out_normal.
  Proof.
    intros le m t le' m' out x fu ety idx a2 k H Hu Hty Hidx Hx Hk.
    apply assign_inv in H as (b & o & bf & v2 & v & Hlv & Ev & Hc & Has & -> & ->).
    destruct (lv_rawk m le x fu ety idx b o bf Hu Hlv) as (b0 & o0 & Hx' & -> & E3).
    destruct (slot_eq _ _ _ _ _ Hx Hx') as (-> & ->).
    destruct (raw_k _ _ _ _ _ _ _ Hk Hidx Hty E3) as (-> & Eo).
    cbn [typeof] in Hc, Has.
    assert (Ham : access_mode ety = By_value Mint32) by (destruct Hty as [<- | [<- | []]]; reflexivity).
    pose proof (store_by_value G ety m pool _ Full v m' Mint32 Ham eq_refl Has) as St.
    rewrite Eo in St. exists v2, v. auto.
  Qed.

  (* p->collidedObjs[n] = y *)
  Lemma asg_coll : forall le m t le' m' out x n y k i vy, exec_stmt function_entry2 G empty_env le m
      (Sassign (Ederef (Ebinop Oadd (Efield (Ederef (Etempvar x tobj) (Tstruct OC._Object noattr)) OC._collidedObjs
          (tarray tobj 4)) (Etempvar n tshort) (tptr tobj)) tobj) (Etempvar y tobj)) t le' m' out ->
    le ! x = Some (OW.slot_v pool k) -> 0 <= k < OW.NSLOT ->
    le ! n = Some (Vint i) -> le ! y = Some vy -> 0 <= Int.signed i < 4 ->
    Mem.store Mint32 m pool (k * OW.OSZ + (120 + 4 * Int.signed i)) vy = Some m' /\ le' = le /\ out = Out_normal.
  Proof.
    intros le m t le' m' out x n y k i vy H Hx Hk Hn Hy Hi.
    apply assign_inv in H as (b & o & bf & v2 & v & Hlv & Ev & Hc & Has & -> & ->).
    destruct (lv_coll m le x n b o bf Hlv) as (o0 & i' & Hx' & Hn' & -> & ->).
    destruct (slot_eq _ _ _ _ _ Hx Hx') as (-> & ->). rewrite Hn in Hn'. injection Hn' as <-.
    apply ev_temp in Ev. rewrite Hy in Ev. injection Ev as <-.
    cbn [typeof] in Hc, Has. apply cast_oo in Hc. subst v.
    pose proof (store_by_value G tobj m pool _ Full vy m' Mint32 eq_refl eq_refl Has) as St.
    rewrite coll_ofs in St by assumption. auto.
  Qed.

  Lemma hd_cell : forall i, (i < OW.NLIST)%nat ->
    Ptrofs.unsigned (Ptrofs.add (Ptrofs.add (Ptrofs.repr (Z.of_nat i * OW.NODESZ)) (Ptrofs.repr 0)) (Ptrofs.repr 96))
    = Z.of_nat i * OW.NODESZ + OW.O_NEXT.
  Proof.
    intros i Hi. unfold OW.NLIST, OW.NODESZ, OW.O_NEXT in *.
    rewrite u3; rewrite ?maxu; lia.
  Qed.

  Lemma slot_nx : forall k, 0 <= k < OW.NSLOT ->
    Ptrofs.unsigned (Ptrofs.add (Ptrofs.add (Ptrofs.repr (k * OW.OSZ)) (Ptrofs.repr 0)) (Ptrofs.repr 96))
    = k * OW.OSZ + OW.O_NEXT.
  Proof.
    intros k Hk. unfold OW.NSLOT, OW.OSZ, OW.O_NEXT in *.
    rewrite u3; rewrite ?maxu; lia.
  Qed.

  Ltac lk := repeat first [ rewrite PTree.gss | rewrite PTree.gso by neq ]; first [ reflexivity | eassumption ].

  Lemma fun_oc : forall id f, (prog_defmap OC.prog) ! id = Some (Gfun (Internal f)) ->
    forall b fd, Genv.find_symbol G id = Some b -> Genv.find_funct G (Vptr b Ptrofs.zero) = Some fd -> fd = Internal f.
  Proof. intros id f Hdm. exact (ObjPhase.fun_of lp _ _ _ (linked12_LO_object_collision lp H12) Hdm). Qed.

  (* p->f, read, at a slot *)
  Lemma ev_slot : forall le m x f ty v d ch k, eval_expr G empty_env le m (Efield (Ederef (Etempvar x tobj) (Tstruct OC._Object noattr)) f ty) v ->
    (forall co, (genv_cenv G) ! OC._Object = Some co -> field_offset G f (co_members co) = OK (d, Full)) ->
    access_mode ty = By_value ch -> 0 <= d < 608 ->
    le ! x = Some (OW.slot_v pool k) -> 0 <= k < OW.NSLOT ->
    Mem.load ch m pool (k * OW.OSZ + d) = Some v.
  Proof.
    intros le m x f ty v d ch k H Hfo Ham Hd Hx Hk.
    destruct (ev_fld G empty_env m le x OC._Object f ty v ch d Hfo Ham H) as (b & o & Hx' & Hl).
    destruct (slot_eq _ _ _ _ _ Hx Hx') as (-> & ->). cbn [Mem.loadv] in Hl.
    rewrite slot_cell in Hl by assumption. exact Hl.
  Qed.

  Lemma op_ge_si : forall a b m, sem_binary_operation G Oge (Vint a) tshort (Vint b) tint m
                                 = Some (Val.of_bool (negb (Int.lt a b))).
  Proof. reflexivity. Qed.

  (* if (n >= 4) return 0; went on: n < 4 *)
  Lemma guard4 : forall le m x cv n,
    eval_expr G empty_env le m (Ebinop Oge (Etempvar x tshort) (Econst_int (Int.repr 4) tint) tint) cv ->
    bool_val cv tint m = Some false -> le ! x = Some (Vint n) -> Int.signed n < 4.
  Proof.
    intros le m x cv n Ec Eb Hx. apply ev_binop in Ec as (v1 & v2 & E1 & E2 & E3).
    apply ev_temp in E1. apply ev_const in E2. subst v2. rewrite Hx in E1. injection E1 as <-.
    cbn [typeof] in E3. rewrite op_ge_si in E3. injection E3 as <-. rewrite bool_of_bool in Eb.
    injection Eb as Eb. destruct (Int.lt n (Int.repr 4)) eqn:El; [ | discriminate Eb ].
    apply lt_true in El. change (Int.signed (Int.repr 4)) with 4 in El. exact El.
  Qed.

  (* t = sqrtf(...): memory unchanged (TRUST 4.1) *)
  Lemma call_sqrtf : forall le m tmp args t le' m' out,
    exec_stmt function_entry2 G empty_env le m
      (Scall (Some tmp) (Evar OC._sqrtf (Tfunction (tfloat :: nil) tfloat cc_default)) args) t le' m' out ->
    m' = m /\ out = Out_normal /\ exists v, le' = PTree.set tmp v le.
  Proof.
    intros le m tmp args t le' m' out H.
    apply call_inv in H as (tya & tyr & cc & vf & vargs & fd & vres & Hcf & Evf & Eal & Hff & _ & Hcall & -> & ->).
    destruct (evf G m le OC._sqrtf _ vf Evf eq_refl) as (bf & Hs & ->).
    change OC._sqrtf with math_util._sqrtf in Hs.
    rewrite (MtxfBody.sqrtf_memid lp H12 Hsq bf fd m vargs t m' vres Hs Hff Hcall).
    split; [ reflexivity | split; [ reflexivity | exists vres; reflexivity ] ].
  Qed.

  (* ---- 6. clear_object_collision(head of list i) ---- *)
  Definition Icl (i : nat) (le : temp_env) (m : mem) : Prop :=
    R m /\ le ! OC._a = Some (ObjLoop.head_v la i)
    /\ exists pre post, nth i rs [] = pre ++ post
       /\ le ! OC._sp4 = Some (ObjLoop.first_v pool la (Z.of_nat i * OW.NODESZ) post).

  Lemma clear_ok : forall i m vargs t m' vr, (i < OW.NLIST)%nat -> R m -> vargs = [ObjLoop.head_v la i] ->
    eval_funcall function_entry2 G m (Internal OC.f_clear_object_collision) vargs t m' vr -> R m'.
  Proof.
    intros i m vargs t m' vr Hi HR -> Hev.
    destruct (fentry _ _ _ _ _ _ _ Hev eq_refl) as (le & le' & out & Hb & Hx).
    cbn in Hb. injection Hb as <-.
    unfold OC.f_clear_object_collision in Hx; cbn [fn_body] in Hx.
    sx Hx E1. sx Hx E2.
    destruct (ev_hn _ _ _ _ E1) as (b & o & Ha & Hl). getnorm Ha.
    injection Ha as <- <-. cbn [Mem.loadv] in Hl. rewrite hd_cell, (R_head m i HR Hi) in Hl by exact Hi.
    injection Hl as <-.
    apply ev_cast in E2 as (w & Ew & Cw). apply ev_temp in Ew. getnorm Ew. injection Ew as <-.
    cbn [typeof] in Cw. apply cast_po in Cw. subst.
    refine (proj1 (while_keep G _ _ (Icl i) R _ _ _ _ _ _ _ _ Hx)).
    2: { split; [ exact HR | split; [ lk | exists [], (nth i rs []); split; [ reflexivity | lk ] ] ]. }
    clear Hx. clear dependent m. clear dependent t.
    intros le m t le1 m1 out1 (HR & Ha & pre & post & Epp & Hs) H.
    apply seq_inv in H. destruct H as [(t1 & le2 & m2 & t2 & H1 & H) | (H1 & Hn)].
    2: { apply if_inv in H1 as (cv & cb & Ec & Eb & H1). destruct cb; cbv iota in H1.
         - apply skip_inv in H1 as (_ & _ & E). exfalso. exact (Hn E).
         - apply break_inv in H1 as (-> & -> & ->). left. split; [ reflexivity | exact HR ]. }
    apply if_inv in H1 as (cv & cb & Ec & Eb & H1).
    destruct post as [| k post].
    { exfalso. apply ev_binop in Ec as (v1 & v2 & E1 & E2 & E3). apply ev_temp in E1. apply ev_temp in E2.
      rewrite Hs in E1. rewrite Ha in E2. injection E1 as <-. injection E2 as <-. cbn [typeof ObjLoop.first_v] in E3.
      unfold ObjLoop.head_v in E3. apply cmp_self_o in E3. subst cv. cbn in Eb. injection Eb as <-.
      cbv iota in H1. apply break_inv in H1 as (_ & _ & E). discriminate E. }
    destruct cb; cbv iota in H1; [ | apply break_inv in H1 as (_ & _ & E); discriminate E ].
    apply skip_inv in H1 as (-> & -> & _).
    assert (Hin : In k (nth i rs [])) by (rewrite Epp; apply in_or_app; right; left; reflexivity).
    pose proof (R_range m k HR (in_nth_concat _ _ _ Hin)) as Hk.
    cbn [ObjLoop.first_v] in Hs.
    (* numCollidedObjs = 0 *)
    fl H. apply seq_inv in H. destruct H as [(t3 & le3 & m3 & t4 & A & H) | (A & Hn)];
      [ | exfalso; apply assign_inv in A as (_ & _ & _ & _ & _ & _ & _ & _ & _ & _ & A); exact (Hn A) ].
    destruct (asg_fld _ _ _ _ _ _ _ _ _ _ 118 Mint16signed k A fo_ncoll (eq_refl : access_mode tshort = By_value Mint16signed) ltac:(lia) Hs Hk)
      as (v2 & v & Ev & Hc & St & -> & _).
    apply ev_const in Ev. subst v2. cbn [typeof] in Hc. rewrite cast_i_s in Hc. injection Hc as <-.
    assert (R3 : R m3).
    { refine (cstore m m3 k 118 Mint16signed _ HR Hk cc_n _ St).
      apply cv_n; [ apply sext16_idem | change (Int.signed (Int.sign_ext 16 (Int.repr 0))) with 0; lia | ].
      intros _ i0 Hi0. change (Int.signed (Int.sign_ext 16 (Int.repr 0))) with 0 in Hi0. lia. }
    clear St HR A.
    (* collidedObjInteractTypes = 0 *)
    fl H. apply seq_inv in H. destruct H as [(t5 & le5 & m5 & t6 & A & H) | (A & Hn)];
      [ | exfalso; apply assign_inv in A as (_ & _ & _ & _ & _ & _ & _ & _ & _ & _ & A); exact (Hn A) ].
    destruct (asg_fld _ _ _ _ _ _ _ _ _ _ 112 Mint32 k A fo_types (eq_refl : access_mode tuint = By_value Mint32) ltac:(lia) Hs Hk)
      as (v2 & v & Ev & Hc & St & -> & _).
    apply ev_const in Ev. subst v2. cbn [typeof] in Hc.
    destruct (cast_vint _ _ _ _ _ Hc ltac:(cbn; auto) ltac:(cbn; auto)) as (xt & ->).
    assert (R5 : R m5) by exact (cstore m3 m5 k 112 Mint32 _ R3 Hk cc_t (cv_int m3 k 112 xt ltac:(auto)) St).
    clear St R3 A Hc.
    (* the timer: if (t'2 > 0) t'3 = timer, timer = t'3 - 1 *)
    sx H E5. fl H. apply seq_inv in H. destruct H as [(t7 & le7 & m7 & t8 & B & H) | (B & Hn)].
    2: { exfalso. apply if_inv in B as (? & cb & _ & _ & B). destruct cb; cbv iota in B.
         - apply seq_inv in B as [(? & ? & ? & ? & B1 & B2) | (B1 & Hn1)].
           + apply assign_inv in B2 as (_ & _ & _ & _ & _ & _ & _ & _ & _ & _ & B2). exact (Hn B2).
           + apply set_inv in B1 as (_ & _ & _ & _ & B1). exact (Hn1 B1).
         - apply skip_inv in B as (_ & _ & E). exact (Hn E). }
    assert (K7 : le7 ! OC._sp4 = Some (OW.slot_v pool k) /\ le7 ! OC._a = Some (ObjLoop.head_v la i)).
    { rewrite (ObjLoop.nosets_keep _ _ _ _ _ _ _ _ _ B OC._sp4 ltac:(vm_compute; reflexivity)).
      rewrite (ObjLoop.nosets_keep _ _ _ _ _ _ _ _ _ B OC._a ltac:(vm_compute; reflexivity)).
      split; lk. }
    assert (R7 : R m7).
    { apply if_inv in B as (? & cb & _ & _ & B). destruct cb; cbv iota in B.
      - apply seq_inv in B as [(? & ? & ? & ? & B1 & B2) | (B1 & Hn1)];
          [ | apply set_inv in B1 as (_ & _ & _ & _ & B1); exfalso; exact (Hn1 B1) ].
        apply set_inv in B1 as (? & _ & -> & -> & _).
        destruct (asg_raw _ _ _ _ _ _ _ _ _ 5 _ k B2 ufo_s32 ltac:(cbn; auto) ltac:(lia) ltac:(lk) Hk)
          as (v2 & v & Ev & Hc & St & _ & _).
        apply ev_binop in Ev as (? & ? & _ & _ & E3). cbn [typeof] in E3, Hc.
        destruct (binop_vint _ _ _ _ _ _ _ _ E3 ltac:(cbn; auto) ltac:(cbn; auto) ltac:(cbn; auto)) as (y5 & ->).
        apply cast_tint_id in Hc. subst v.
        exact (cstore m5 m7 k 156 Mint32 _ R5 Hk cc_5 (cv_int m5 k 156 y5 ltac:(auto)) St).
      - apply skip_inv in B as (-> & _ & _). exact R5. }
    clear B R5. destruct K7 as (Hs7 & Ha7).
    (* the cursor: sp4 = sp4->header.next *)
    sx H E6. apply set_inv in H as (? & E7 & -> & -> & ->).
    destruct (ev_hn _ _ _ _ E6) as (b & o & Hb & Hl). rewrite Hs7 in Hb. injection Hb as <- <-.
    cbn [Mem.loadv] in Hl. rewrite slot_nx in Hl by exact Hk.
    rewrite (R_next m7 i pre k post R7 Hi Epp) in Hl. injection Hl as <-.
    apply ev_cast in E7 as (w & Ew & Cw). apply ev_temp in Ew. getnorm Ew. injection Ew as <-.
    cbn [typeof] in Cw. apply cast_po in Cw. subst.
    right. split; [ reflexivity | ].
    split; [ exact R7 | split; [ lk | ] ].
    exists (pre ++ [k]), post. split; [ rewrite Epp, <- app_assoc; reflexivity | lk ].
  Qed.

  (* ---- 7. detect_object_hitbox_overlap(a, b), two distinct listed objects ---- *)
  Lemma cv_partner : forall m k j off, R m -> In k (concat rs) -> In j (concat rs) -> j <> k -> 120 <= off < 136 ->
    CollKeep.coll_val pool gmo m k off (OW.slot_v pool j).
  Proof.
    intros m k j off HR Hk Hj Ne Ho.
    apply cv_ptr; [ exact Ho | exact (R_range m j HR Hj) | intros Hma; exact (partner m k j HR Hk Hj Ne Hma) ].
  Qed.

  (* n++ after collidedObjs[n] = j *)
  Lemma cv_inc : forall m k j n, R m -> In k (concat rs) -> In j (concat rs) -> j <> k ->
    0 <= Int.signed n < 4 ->
    Mem.load Mint16signed m pool (k * OW.OSZ + 118) = Some (Vint n) ->
    Mem.load Mint32 m pool (k * OW.OSZ + (120 + 4 * Int.signed n)) = Some (OW.slot_v pool j) ->
    CollKeep.coll_val pool gmo m k 118 (Vint (Int.sign_ext 16 (Int.add n (Int.repr 1)))).
  Proof.
    intros m k j n HR Hk Hj Ne Hn Ln Lc.
    assert (Es : Int.signed (Int.sign_ext 16 (Int.add n (Int.repr 1))) = Int.signed n + 1) by (apply sx_add1; lia).
    apply cv_n; [ apply sext16_idem | lia | ].
    intros Hma i Hi. rewrite Es in Hi.
    destruct (Z.eq_dec i (Int.signed n)) as [-> | Ne'].
    - right. exists j. split; [ exact (R_range m j HR Hj) | ].
      destruct (partner m k j HR Hk Hj Ne Hma) as (Nj & Kj). split; [ exact Nj | split; [ exact Kj | ] ].
      replace (k * OW.OSZ + 120 + 4 * Int.signed n) with (k * OW.OSZ + (120 + 4 * Int.signed n)) by lia. exact Lc.
    - left. exists n. split; [ exact Ln | lia ].
  Qed.

  Lemma ld_same_ptr : forall m m2 z j, Mem.store Mint32 m pool z (OW.slot_v pool j) = Some m2 ->
    Mem.load Mint32 m2 pool z = Some (OW.slot_v pool j).
  Proof. intros m m2 z j St. rewrite (Mem.load_store_same _ _ _ _ _ _ St). reflexivity. Qed.

  Ltac ccs := first [ exact cc_n | exact cc_t | exact cc_5 | exact cc_66 | (apply cc_c; lia)
                    | (left; congruence) | (right; lia) ].

  Lemma hit_ok : forall m ka kb t m' vr, R m -> In ka (concat rs) -> In kb (concat rs) -> ka <> kb ->
    eval_funcall function_entry2 G m (Internal OC.f_detect_object_hitbox_overlap)
      [OW.slot_v pool ka; OW.slot_v pool kb] t m' vr -> R m'.
  Proof.
    intros m ka kb t m' vr HR Ha Hb Nab Hev.
    pose proof (R_range m ka HR Ha) as Hka. pose proof (R_range m kb HR Hb) as Hkb.
    destruct (fentry _ _ _ _ _ _ _ Hev eq_refl) as (le & le' & out & Hbd & H).
    cbn in Hbd. injection Hbd as <-.
    unfold OC.f_detect_object_hitbox_overlap in H; cbn [fn_body] in H.
    do 16 sx_ H.
    fl H. apply seq_inv in H. destruct H as [(? & ? & ? & ? & Q & H) | (Q & Hn)];
      apply call_sqrtf in Q as (-> & Eo & ? & ->); [ | exfalso; exact (Hn Eo) ].
    sx_ H.
    match type of H with exec_stmt _ _ _ ?le0 _ (Ssequence ?S _) _ _ _ _ =>
      assert (Hbig : forall t1 le1 m1 out1, exec_stmt function_entry2 G empty_env le0 m S t1 le1 m1 out1 -> R m1) end.
    2: { fl H. apply seq_inv in H. destruct H as [(? & ? & m1 & ? & B & H) | (B & Hn)].
         - pose proof (Hbig _ _ _ _ B) as R1. apply ret_inv in H as (-> & _). exact R1.
         - exact (Hbig _ _ _ _ B). }
    intros t1 le1 mF out1 B. clear H.
    apply if_inv in B as (? & cb & _ & _ & B). destruct cb; cbv iota in B;
      [ | apply skip_inv in B as (-> & _ & _); exact HR ].
    do 4 sx_ B.
    sif B Ec1 Eb1; try assumption.
    sif B Ec2 Eb2; try assumption.
    sx B E11. sif B Ec3 Eb3; try assumption.
    sx B E10. sif B Ec4 Eb4; try assumption.
    (* the two counts, below 4 *)
    destruct (R_ncoll m ka HR Ha) as (na & Lna & Rna).
    destruct (R_ncoll m kb HR Hb) as (nb & Lnb & Rnb).
    pose proof (ev_slot _ _ _ _ _ _ _ _ _ E11 fo_ncoll eq_refl ltac:(lia) ltac:(lk) Hka) as L.
    rewrite Lna in L. injection L as <-.
    pose proof (ev_slot _ _ _ _ _ _ _ _ _ E10 fo_ncoll eq_refl ltac:(lia) ltac:(lk) Hkb) as L.
    rewrite Lnb in L. injection L as <-.
    pose proof (guard4 _ _ _ _ _ Ec3 Eb3 ltac:(lk)) as Hna.
    pose proof (guard4 _ _ _ _ _ Ec4 Eb4 ltac:(lk)) as Hnb.
    clear Ec1 Eb1 Ec2 Eb2 Ec3 Eb3 Ec4 Eb4 E11 E10.
    (* a->collidedObjs[a->numCollidedObjs] = b *)
    sx B E9. pose proof (ev_slot _ _ _ _ _ _ _ _ _ E9 fo_ncoll eq_refl ltac:(lia) ltac:(lk) Hka) as L.
    rewrite Lna in L. injection L as <-. clear E9.
    sa B A1 m1.
    destruct (asg_coll _ _ _ _ _ _ _ _ _ ka na (OW.slot_v pool kb) A1 ltac:(lk) Hka ltac:(lk) ltac:(lk) ltac:(lia))
      as (St1 & -> & _).
    pose proof (cstore m m1 ka (120 + 4 * Int.signed na) Mint32 _ HR Hka (cc_c (Int.signed na) ltac:(lia))
                  (cv_partner m ka kb (120 + 4 * Int.signed na) HR Ha Hb (not_eq_sym Nab) ltac:(lia)) St1) as R1.
    (* b->collidedObjs[b->numCollidedObjs] = a *)
    sx B E8. pose proof (ev_slot _ _ _ _ _ _ _ _ _ E8 fo_ncoll eq_refl ltac:(lia) ltac:(lk) Hkb) as L.
    rewrite (cload _ _ _ _ _ _ _ _ _ St1) in L by ccs. rewrite Lnb in L. injection L as <-. clear E8.
    sa B A2 m2.
    destruct (asg_coll _ _ _ _ _ _ _ _ _ kb nb (OW.slot_v pool ka) A2 ltac:(lk) Hkb ltac:(lk) ltac:(lk) ltac:(lia))
      as (St2 & -> & _).
    pose proof (cstore m1 m2 kb (120 + 4 * Int.signed nb) Mint32 _ R1 Hkb (cc_c (Int.signed nb) ltac:(lia))
                  (cv_partner m1 kb ka (120 + 4 * Int.signed nb) R1 Hb Ha Nab ltac:(lia)) St2) as R2.
    (* the two type ORs *)
    sx_ B. sx_ B. sa B A3 m3.
    destruct (asg_fld _ _ _ _ _ _ _ _ _ _ 112 Mint32 ka A3 fo_types (eq_refl : access_mode tuint = By_value Mint32) ltac:(lia) ltac:(lk) Hka)
      as (v2 & v & Ev & Hc & St3 & -> & _).
    apply ev_binop in Ev as (? & ? & _ & _ & E3). cbn [typeof] in E3, Hc.
    destruct (binop_vint _ _ _ _ _ _ _ _ E3 ltac:(cbn; auto) ltac:(cbn; auto) ltac:(cbn; auto)) as (z3 & ->).
    destruct (cast_vint _ _ _ _ _ Hc ltac:(cbn; auto) ltac:(cbn; auto)) as (y3 & ->).
    pose proof (cstore m2 m3 ka 112 Mint32 _ R2 Hka cc_t (cv_int m2 ka 112 y3 ltac:(auto)) St3) as R3.
    clear E3 Hc.
    sx_ B. sx_ B. sa B A4 m4.
    destruct (asg_fld _ _ _ _ _ _ _ _ _ _ 112 Mint32 kb A4 fo_types (eq_refl : access_mode tuint = By_value Mint32) ltac:(lia) ltac:(lk) Hkb)
      as (v2' & v' & Ev & Hc & St4 & -> & _).
    apply ev_binop in Ev as (? & ? & _ & _ & E3). cbn [typeof] in E3, Hc.
    destruct (binop_vint _ _ _ _ _ _ _ _ E3 ltac:(cbn; auto) ltac:(cbn; auto) ltac:(cbn; auto)) as (z4 & ->).
    destruct (cast_vint _ _ _ _ _ Hc ltac:(cbn; auto) ltac:(cbn; auto)) as (y4 & ->).
    pose proof (cstore m3 m4 kb 112 Mint32 _ R3 Hkb cc_t (cv_int m3 kb 112 y4 ltac:(auto)) St4) as R4.
    clear E3 Hc.
    (* a->numCollidedObjs++ *)
    assert (L4 : Mem.load Mint16signed m4 pool (ka * OW.OSZ + 118) = Some (Vint na)).
    { rewrite (cload _ _ _ _ _ _ _ _ _ St4), (cload _ _ _ _ _ _ _ _ _ St3), (cload _ _ _ _ _ _ _ _ _ St2),
        (cload _ _ _ _ _ _ _ _ _ St1) by ccs. exact Lna. }
    assert (C4 : Mem.load Mint32 m4 pool (ka * OW.OSZ + (120 + 4 * Int.signed na)) = Some (OW.slot_v pool kb)).
    { rewrite (cload _ _ _ _ _ _ _ _ _ St4), (cload _ _ _ _ _ _ _ _ _ St3), (cload _ _ _ _ _ _ _ _ _ St2) by ccs.
      exact (ld_same_ptr _ _ _ _ St1). }
    sx B E3. pose proof (ev_slot _ _ _ _ _ _ _ _ _ E3 fo_ncoll eq_refl ltac:(lia) ltac:(lk) Hka) as L.
    rewrite L4 in L. injection L as <-. clear E3.
    sa B A5 m5.
    destruct (asg_fld _ _ _ _ _ _ _ _ _ _ 118 Mint16signed ka A5 fo_ncoll (eq_refl : access_mode tshort = By_value Mint16signed) ltac:(lia) ltac:(lk) Hka)
      as (v5 & v5' & Ev & Hc & St5 & -> & _).
    apply ev_binop in Ev as (w1 & w2 & E1 & E2 & E3). apply ev_temp in E1. apply ev_const in E2. subst w2.
    getnorm E1. injection E1 as <-. cbn [typeof] in E3, Hc. rewrite op_add_s in E3. injection E3 as <-.
    rewrite cast_i_s in Hc. injection Hc as <-.
    pose proof (cstore m4 m5 ka 118 Mint16signed _ R4 Hka cc_n
                  (cv_inc m4 ka kb na R4 Ha Hb (not_eq_sym Nab) ltac:(lia) L4 C4) St5) as R5.
    (* b->numCollidedObjs++ *)
    assert (L5 : Mem.load Mint16signed m5 pool (kb * OW.OSZ + 118) = Some (Vint nb)).
    { rewrite (cload _ _ _ _ _ _ _ _ _ St5), (cload _ _ _ _ _ _ _ _ _ St4), (cload _ _ _ _ _ _ _ _ _ St3),
        (cload _ _ _ _ _ _ _ _ _ St2), (cload _ _ _ _ _ _ _ _ _ St1) by ccs. exact Lnb. }
    assert (C5 : Mem.load Mint32 m5 pool (kb * OW.OSZ + (120 + 4 * Int.signed nb)) = Some (OW.slot_v pool ka)).
    { rewrite (cload _ _ _ _ _ _ _ _ _ St5), (cload _ _ _ _ _ _ _ _ _ St4), (cload _ _ _ _ _ _ _ _ _ St3) by ccs.
      exact (ld_same_ptr _ _ _ _ St2). }
    sx B E2. pose proof (ev_slot _ _ _ _ _ _ _ _ _ E2 fo_ncoll eq_refl ltac:(lia) ltac:(lk) Hkb) as L.
    rewrite L5 in L. injection L as <-. clear E2.
    sa B A6 m6.
    destruct (asg_fld _ _ _ _ _ _ _ _ _ _ 118 Mint16signed kb A6 fo_ncoll (eq_refl : access_mode tshort = By_value Mint16signed) ltac:(lia) ltac:(lk) Hkb)
      as (v6 & v6' & Ev & Hc & St6 & -> & _).
    apply ev_binop in Ev as (w1 & w2 & E1 & E2 & E3). apply ev_temp in E1. apply ev_const in E2. subst w2.
    getnorm E1. injection E1 as <-. cbn [typeof] in E3, Hc. rewrite op_add_s in E3. injection E3 as <-.
    rewrite cast_i_s in Hc. injection Hc as <-.
    pose proof (cstore m5 m6 kb 118 Mint16signed _ R5 Hkb cc_n
                  (cv_inc m5 kb ka nb R5 Hb Ha Nab ltac:(lia) L5 C5) St6) as R6.
    apply ret_inv in B as (-> & _). exact R6.
  Qed.

  (* ---- 8. detect_object_hurtbox_overlap(a, b): b->rawData[66] |= 2 / &= ~2 ---- *)
  Lemma r66 : forall le m c x a op e2 t le' m' out k, exec_stmt function_entry2 G empty_env le m
      (Sifthenelse c (Ssequence (Sset x a)
        (Sassign (Ederef (Ebinop Oadd (Efield (Efield (Ederef (Etempvar OC._b tobj) (Tstruct OC._Object noattr))
            OC._rawData (Tunion OC.__764 noattr)) OC._asU32 (tarray tuint 80)) (Econst_int (Int.repr 66) tint)
            (tptr tuint)) tuint)
          (Ebinop op (Etempvar x tuint) e2 tuint))) Sskip) t le' m' out ->
    R m -> le ! OC._b = Some (OW.slot_v pool k) -> 0 <= k < OW.NSLOT -> x <> OC._b ->
    In op [Oor; Oand] -> typeof e2 = tint ->
    R m' /\ out = Out_normal /\ (le' = le \/ exists v, le' = PTree.set x v le).
  Proof.
    intros le m c x a op e2 t le' m' out k H HR Hb Hk Nx Hop Ht.
    apply ifas_inv in H as (-> & [(-> & ->) | (v & t2 & _ & A)]).
    - auto.
    - destruct (asg_raw _ _ _ _ _ _ _ _ _ 66 _ k A ufo_u32 ltac:(cbn; auto) ltac:(lia) ltac:(rewrite PTree.gso by exact (not_eq_sym Nx); exact Hb) Hk)
        as (v2 & v' & Ev & Hc & St & -> & _).
      apply ev_binop in Ev as (? & ? & _ & _ & E3). cbn [typeof] in E3, Hc. rewrite Ht in E3.
      destruct (binop_vint _ _ _ _ _ _ _ _ E3 ltac:(destruct Hop as [<- | [<- | []]]; cbn; auto) ltac:(cbn; auto) ltac:(cbn; auto)) as (z66 & ->).
      destruct (cast_vint _ _ _ _ _ Hc ltac:(cbn; auto) ltac:(cbn; auto)) as (y0 & ->).
      split; [ exact (cstore m m' k 400 Mint32 _ HR Hk cc_66 (cv_int m k 400 y0 ltac:(auto)) St) | ].
      split; [ reflexivity | right; exists v; reflexivity ].
  Qed.

  Lemma hurt_ok : forall m ka kb t m' vr, R m -> In ka (concat rs) -> In kb (concat rs) ->
    eval_funcall function_entry2 G m (Internal OC.f_detect_object_hurtbox_overlap)
      [OW.slot_v pool ka; OW.slot_v pool kb] t m' vr -> R m'.
  Proof.
    intros m ka kb t m' vr HR Ha Hb Hev.
    pose proof (R_range m kb HR Hb) as Hkb.
    destruct (fentry _ _ _ _ _ _ _ Hev eq_refl) as (le & le' & out & Hbd & H).
    cbn in Hbd. injection Hbd as <-.
    unfold OC.f_detect_object_hurtbox_overlap in H; cbn [fn_body] in H.
    do 16 sx_ H.
    fl H. apply seq_inv in H. destruct H as [(? & ? & ? & ? & Q & H) | (Q & Hn)];
      apply call_sqrtf in Q as (-> & Eo & ? & ->); [ | exfalso; exact (Hn Eo) ].
    sx_ H. sx_ H.
    fl H. apply seq_inv in H. destruct H as [(? & le1 & m1 & ? & B & H) | (B & Hn)].
    2: { exfalso. apply ifas_inv in B as (E & _). exact (Hn E). }
    destruct (r66 _ _ _ _ _ _ _ _ _ _ _ kb B HR ltac:(lk) Hkb ltac:(neq) ltac:(cbn; auto) eq_refl)
      as (R1 & _ & Hle1).
    assert (Hb1 : le1 ! OC._b = Some (OW.slot_v pool kb))
      by (destruct Hle1 as [-> | (v & ->)]; lk).
    clear B Hle1.
    match type of H with exec_stmt _ _ _ ?le0 _ (Ssequence ?S _) _ _ _ _ =>
      assert (Hbig : forall t1 le2 m2 out1, exec_stmt function_entry2 G empty_env le0 m1 S t1 le2 m2 out1 -> R m2) end.
    2: { fl H. apply seq_inv in H. destruct H as [(? & ? & m2 & ? & B & H) | (B & Hn)].
         - pose proof (Hbig _ _ _ _ B) as R2. apply ret_inv in H as (-> & _). exact R2.
         - exact (Hbig _ _ _ _ B). }
    intros t1 le2 m2 out1 B. clear H.
    apply if_inv in B as (? & cb & _ & _ & B). destruct cb; cbv iota in B;
      [ | apply skip_inv in B as (-> & _ & _); exact R1 ].
    do 4 sx_ B.
    sif B Ec1 Eb1; try assumption.
    sif B Ec2 Eb2; try assumption.
    sx_ B.
    fl B. apply seq_inv in B. destruct B as [(? & le3 & m3 & ? & B & H) | (B & Hn)].
    2: { exfalso. apply ifas_inv in B as (E & _). exact (Hn E). }
    destruct (r66 _ _ _ _ _ _ _ _ _ _ _ kb B R1 ltac:(lk) Hkb ltac:(neq) ltac:(cbn; auto) eq_refl)
      as (R3 & _ & _).
    apply ret_inv in H as (-> & _). exact R3.
  Qed.

  (* ---- 9. check_collision_in_list(a, b, head j) ---- *)
  Lemma dm_hit : (prog_defmap OC.prog) ! OC._detect_object_hitbox_overlap
                 = Some (Gfun (Internal OC.f_detect_object_hitbox_overlap)).
  Proof. vm_compute. reflexivity. Qed.
  Lemma dm_hurt : (prog_defmap OC.prog) ! OC._detect_object_hurtbox_overlap
                  = Some (Gfun (Internal OC.f_detect_object_hurtbox_overlap)).
  Proof. vm_compute. reflexivity. Qed.
  Lemma dm_ccl : (prog_defmap OC.prog) ! OC._check_collision_in_list
                 = Some (Gfun (Internal OC.f_check_collision_in_list)).
  Proof. vm_compute. reflexivity. Qed.
  Lemma dm_clear : (prog_defmap OC.prog) ! OC._clear_object_collision
                   = Some (Gfun (Internal OC.f_clear_object_collision)).
  Proof. vm_compute. reflexivity. Qed.
  Lemma dm_player : (prog_defmap OC.prog) ! OC._check_player_object_collision
                    = Some (Gfun (Internal OC.f_check_player_object_collision)).
  Proof. vm_compute. reflexivity. Qed.
  Lemma dm_push : (prog_defmap OC.prog) ! OC._check_pushable_object_collision
                  = Some (Gfun (Internal OC.f_check_pushable_object_collision)).
  Proof. vm_compute. reflexivity. Qed.
  Lemma dm_destr : (prog_defmap OC.prog) ! OC._check_destructive_object_collision
                   = Some (Gfun (Internal OC.f_check_destructive_object_collision)).
  Proof. vm_compute. reflexivity. Qed.
  Lemma dm_detect : (prog_defmap OC.prog) ! OC._detect_object_collisions
                    = Some (Gfun (Internal OC.f_detect_object_collisions)).
  Proof. vm_compute. reflexivity. Qed.

  (* f(a, b), a and b temps *)
  Lemma call_ab : forall le m tmp fid f tyr t le' m' out ka kb, exec_stmt function_entry2 G empty_env le m
      (Scall tmp (Evar fid (Tfunction (tobj :: tobj :: nil) tyr cc_default))
         [Etempvar OC._a tobj; Etempvar OC._b tobj]) t le' m' out ->
    (prog_defmap OC.prog) ! fid = Some (Gfun (Internal f)) ->
    le ! OC._a = Some (OW.slot_v pool ka) -> le ! OC._b = Some (OW.slot_v pool kb) ->
    exists t' vr, eval_funcall function_entry2 G m (Internal f) [OW.slot_v pool ka; OW.slot_v pool kb] t' m' vr
      /\ out = Out_normal /\ le' = set_opttemp tmp vr le.
  Proof.
    intros le m tmp fid f tyr t le' m' out ka kb H Hdm Ha Hb.
    apply call_inv in H as (tya & tyr' & cc & vf & vargs & fd & vres & Hcf & Evf & Eal & Hff & _ & Hcall & -> & ->).
    cbn in Hcf. injection Hcf as <- <- <-.
    destruct (evf G m le fid _ vf Evf eq_refl) as (bf & Hs & ->).
    rewrite (fun_oc _ _ Hdm bf fd Hs Hff) in Hcall.
    destruct (ObjLoop.exl2 _ _ _ _ _ _ _ _ Eal) as (ty1 & ty2 & v1 & v2 & w1 & w2 & E & -> & E1 & C1 & E2 & C2).
    injection E as <- <-. apply ev_temp in E1. apply ev_temp in E2. rewrite Ha in E1. rewrite Hb in E2.
    injection E1 as <-. injection E2 as <-. cbn [typeof] in C1, C2. apply cast_oo in C1. apply cast_oo in C2.
    subst. eauto.
  Qed.

  Definition Iccl (ka : Z) (j : nat) (le : temp_env) (m : mem) : Prop :=
    R m /\ le ! OC._a = Some (OW.slot_v pool ka) /\ le ! OC._c = Some (ObjLoop.head_v la j)
    /\ exists pre post, nth j rs [] = pre ++ post /\ ~ In ka post
       /\ le ! OC._b = Some (ObjLoop.first_v pool la (Z.of_nat j * OW.NODESZ) post).

  Lemma ccl_ok : forall m ka j pre post t m' vr, R m -> In ka (concat rs) -> (j < OW.NLIST)%nat ->
    nth j rs [] = pre ++ post -> ~ In ka post ->
    eval_funcall function_entry2 G m (Internal OC.f_check_collision_in_list)
      [OW.slot_v pool ka; ObjLoop.first_v pool la (Z.of_nat j * OW.NODESZ) post; ObjLoop.head_v la j] t m' vr ->
    R m'.
  Proof.
    intros m ka j pre post t m' vr HR Ha Hj Epp Nin Hev.
    destruct (fentry _ _ _ _ _ _ _ Hev eq_refl) as (le & le' & out & Hbd & H).
    cbn in Hbd. injection Hbd as <-.
    unfold OC.f_check_collision_in_list in H; cbn [fn_body] in H.
    sx_ H.
    apply if_inv in H as (? & cb & _ & _ & H). destruct cb; cbv iota in H;
      [ | apply skip_inv in H as (-> & _ & _); exact HR ].
    refine (proj1 (while_keep G _ _ (Iccl ka j) R _ _ _ _ _ _ _ _ H)).
    2: { split; [ exact HR | split; [ lk | split; [ lk | ] ] ].
         exists pre, post. split; [ exact Epp | split; [ exact Nin | lk ] ]. }
    clear H. clear dependent m. clear dependent t.
    intros le m t le1 m1 out1 (HR & Hsa & Hlc & pre1 & post1 & Epp1 & Nin1 & Hlb) H.
    apply seq_inv in H. destruct H as [(t1 & le2 & m2 & t2 & H1 & H) | (H1 & Hn)].
    2: { apply if_inv in H1 as (cv & cb & Ec & Eb & H1). destruct cb; cbv iota in H1.
         - apply skip_inv in H1 as (_ & _ & E). exfalso. exact (Hn E).
         - apply break_inv in H1 as (-> & -> & ->). left. split; [ reflexivity | exact HR ]. }
    apply if_inv in H1 as (cv & cb & Ec & Eb & H1).
    destruct post1 as [| kb post1].
    { exfalso. apply ev_binop in Ec as (v1 & v2 & E1 & E2 & E3). apply ev_temp in E1. apply ev_temp in E2.
      rewrite Hlb in E1. rewrite Hlc in E2. injection E1 as <-. injection E2 as <-.
      cbn [typeof ObjLoop.first_v] in E3. unfold ObjLoop.head_v in E3. apply cmp_self_o in E3. subst cv.
      cbn in Eb. injection Eb as <-. cbv iota in H1. apply break_inv in H1 as (_ & _ & E). discriminate E. }
    destruct cb; cbv iota in H1; [ | apply break_inv in H1 as (_ & _ & E); discriminate E ].
    apply skip_inv in H1 as (-> & -> & _).
    assert (Hin : In kb (nth j rs [])) by (rewrite Epp1; apply in_or_app; right; left; reflexivity).
    pose proof (in_nth_concat _ _ _ Hin) as Hb. pose proof (R_range m kb HR Hb) as Hkb.
    assert (Nab : ka <> kb) by (intros ->; apply Nin1; left; reflexivity).
    cbn [ObjLoop.first_v] in Hlb.
    (* t'5 = b's timer; if (t'5 == 0) { if (hitbox(a, b) && b->hurtboxRadius != 0) hurtbox(a, b) } *)
    sx_ H. fl H. apply seq_inv in H. destruct H as [(? & le3 & m3 & ? & X & H) | (X & Hn)].
    2: { exfalso. exact (Hn (ObjLoop.plain_out _ _ _ _ _ _ _ _ _ X ltac:(vm_compute; reflexivity))). }
    assert (KX : R m3 /\ le3 ! OC._a = Some (OW.slot_v pool ka) /\ le3 ! OC._b = Some (OW.slot_v pool kb)
                 /\ le3 ! OC._c = Some (ObjLoop.head_v la j)).
    { rewrite (ObjLoop.nosets_keep _ _ _ _ _ _ _ _ _ X OC._a ltac:(vm_compute; reflexivity)).
      rewrite (ObjLoop.nosets_keep _ _ _ _ _ _ _ _ _ X OC._b ltac:(vm_compute; reflexivity)).
      rewrite (ObjLoop.nosets_keep _ _ _ _ _ _ _ _ _ X OC._c ltac:(vm_compute; reflexivity)).
      split; [ | split; [ lk | split; lk ] ].
      apply if_inv in X as (? & cb & _ & _ & X). destruct cb; cbv iota in X;
        [ | apply skip_inv in X as (-> & _ & _); exact HR ].
      fl X. apply seq_inv in X. destruct X as [(? & le4 & m4 & ? & C & X) | (C & Hn)].
      2: { exfalso. exact (Hn (ObjLoop.plain_out _ _ _ _ _ _ _ _ _ C eq_refl)). }
      destruct (call_ab _ _ _ _ _ _ _ _ _ _ ka kb C dm_hit ltac:(lk) ltac:(lk)) as (t' & vr' & Hc & _ & ->).
      pose proof (hit_ok m ka kb t' m4 vr' HR Ha Hb Nab Hc) as R4. clear C Hc.
      apply seq_inv in X. destruct X as [(? & le5 & m5 & ? & D & X) | (D & Hn)].
      2: { exfalso. exact (Hn (ObjLoop.plain_out _ _ _ _ _ _ _ _ _ D ltac:(vm_compute; reflexivity))). }
      pose proof (pure_mem _ _ _ _ _ _ _ _ _ D ltac:(vm_compute; reflexivity)) as ->.
      assert (L5 : le5 ! OC._a = Some (OW.slot_v pool ka) /\ le5 ! OC._b = Some (OW.slot_v pool kb)).
      { rewrite (ObjLoop.nosets_keep _ _ _ _ _ _ _ _ _ D OC._a ltac:(vm_compute; reflexivity)).
        rewrite (ObjLoop.nosets_keep _ _ _ _ _ _ _ _ _ D OC._b ltac:(vm_compute; reflexivity)).
        split; cbn [set_opttemp]; lk. }
      destruct L5 as (L5a & L5b). clear D.
      apply if_inv in X as (? & cb & _ & _ & X). destruct cb; cbv iota in X;
        [ | apply skip_inv in X as (-> & _ & _); exact R4 ].
      destruct (call_ab _ _ _ _ _ _ _ _ _ _ ka kb X dm_hurt L5a L5b) as (t'' & vr'' & Hc & _ & _).
      exact (hurt_ok m4 ka kb t'' _ vr'' R4 Ha Hb Hc). }
    destruct KX as (R3 & L3a & L3b & L3c). clear X.
    (* b = b->header.next *)
    sx H E4. apply set_inv in H as (? & E5 & -> & -> & ->).
    destruct (ev_hn _ _ _ _ E4) as (b & o & Hb4 & Hl). rewrite L3b in Hb4. injection Hb4 as <- <-.
    cbn [Mem.loadv] in Hl. rewrite slot_nx in Hl by exact Hkb.
    rewrite (R_next m3 j pre1 kb post1 R3 Hj Epp1) in Hl. injection Hl as <-.
    apply ev_cast in E5 as (w & Ew & Cw). apply ev_temp in Ew. getnorm Ew. injection Ew as <-.
    cbn [typeof] in Cw. apply cast_po in Cw. subst.
    right. split; [ reflexivity | ].
    split; [ exact R3 | split; [ lk | split; [ lk | ] ] ].
    exists (pre1 ++ [kb]), post1. split; [ rewrite Epp1, <- app_assoc; reflexivity | ].
    split; [ intros Hk; apply Nin1; right; exact Hk | lk ].
  Qed.

  (* ---- 10. The three list walks ---- *)
  Lemma call_ccl : forall le m a2 a3 t le' m' out ka j pre post, exec_stmt function_entry2 G empty_env le m
      (Scall None (Evar OC._check_collision_in_list (Tfunction (tobj :: tobj :: tobj :: nil) tvoid cc_default))
         [Etempvar OC._sp18 tobj; a2; a3]) t le' m' out ->
    R m -> In ka (concat rs) -> (j < OW.NLIST)%nat -> nth j rs [] = pre ++ post -> ~ In ka post ->
    le ! OC._sp18 = Some (OW.slot_v pool ka) -> typeof a2 = tobj -> typeof a3 = tobj ->
    (forall v, eval_expr G empty_env le m a2 v -> v = ObjLoop.first_v pool la (Z.of_nat j * OW.NODESZ) post) ->
    (forall v, eval_expr G empty_env le m a3 v -> v = ObjLoop.head_v la j) ->
    R m' /\ le' = le /\ out = Out_normal.
  Proof.
    intros le m a2 a3 t le' m' out ka j pre post H HR Ha Hj Epp Nin Hs T2 T3 V2 V3.
    apply call_inv in H as (tya & tyr & cc & vf & vargs & fd & vres & Hcf & Evf & Eal & Hff & _ & Hcall & -> & ->).
    cbn in Hcf. injection Hcf as <- <- <-.
    destruct (evf G m le _ _ vf Evf eq_refl) as (bf & Hsy & ->).
    rewrite (fun_oc _ _ dm_ccl bf fd Hsy Hff) in Hcall.
    destruct (exl3 _ _ _ _ _ _ _ _ _ Eal)
      as (ty1 & ty2 & ty3 & v1 & v2 & v3 & w1 & w2 & w3 & E & -> & E1 & C1 & E2 & C2 & E3 & C3).
    injection E as <- <- <-. apply ev_temp in E1. rewrite Hs in E1. injection E1 as <-.
    rewrite (V2 _ E2), T2 in C2. rewrite (V3 _ E3), T3 in C3. cbn [typeof] in C1.
    apply cast_oo in C1. apply cast_oo in C2. apply cast_oo in C3. subst.
    split; [ exact (ccl_ok m ka j pre post _ _ _ HR Ha Hj Epp Nin Hcall) | auto ].
  Qed.

  Lemma ev_gol : forall le m v, R m -> eval_expr G empty_env le m (Evar OC._gObjectLists tnd) v ->
    v = Vptr la Ptrofs.zero.
  Proof.
    intros le m v HR Ev. destruct (evg G m le _ _ v Mint32 Ev eq_refl) as (bg & Hs & Hl).
    change OC._gObjectLists with OLP._gObjectLists in Hs. rewrite Hgol in Hs. injection Hs as <-.
    cbn [Mem.loadv] in Hl. rewrite Ptrofs.unsigned_zero, (R_gol m HR) in Hl. injection Hl as <-. reflexivity.
  Qed.

  Lemma hd_nx : forall j, (j < OW.NLIST)%nat ->
    Ptrofs.unsigned (Ptrofs.add (Ptrofs.repr (Z.of_nat j * OW.NODESZ)) (Ptrofs.repr 96)) = Z.of_nat j * OW.NODESZ + OW.O_NEXT.
  Proof.
    intros j Hj. unfold OW.NLIST, OW.NODESZ, OW.O_NEXT in *.
    rewrite u2; rewrite ?maxu; lia.
  Qed.

  (* check_collision_in_list(sp18, gObjectLists[j].next, &gObjectLists[j]), j another list *)
  Lemma callj : forall le m t le' m' out tx ty tz (j : nat) ka i, exec_stmt function_entry2 G empty_env le m
      (Ssequence (Sset tx (Evar OC._gObjectLists tnd))
        (Ssequence (Sset ty (Efield (Ederef (Ebinop Oadd (Etempvar tx tnd) (Econst_int (Int.repr (Z.of_nat j)) tint) tnd)
                               (Tstruct OC._ObjectNode noattr)) OC._next tnd))
          (Ssequence (Sset tz (Evar OC._gObjectLists tnd))
            (Scall None (Evar OC._check_collision_in_list (Tfunction (tobj :: tobj :: tobj :: nil) tvoid cc_default))
               [Etempvar OC._sp18 tobj; Ecast (Etempvar ty tnd) tobj;
                Ecast (Ebinop Oadd (Etempvar tz tnd) (Econst_int (Int.repr (Z.of_nat j)) tint) tnd) tobj])))) t le' m' out ->
    R m -> le ! OC._sp18 = Some (OW.slot_v pool ka) -> In ka (nth i rs []) -> (j < OW.NLIST)%nat -> i <> j ->
    tx <> OC._sp18 -> ty <> OC._sp18 -> tz <> OC._sp18 -> ty <> tz ->
    R m' /\ out = Out_normal /\ exists v1 v2 v3, le' = PTree.set tz v3 (PTree.set ty v2 (PTree.set tx v1 le)).
  Proof.
    intros le m t le' m' out tx ty tz j ka i H HR Hs Hin Hj Nij N1 N2 N3 N4.
    sx H E1. sx H E2. sx H E3.
    pose proof (ev_gol _ _ _ HR E1) as ->. pose proof (ev_gol _ _ _ HR E3) as ->.
    destruct (ev_headnx _ _ _ _ _ E2) as (b & o & Hb & Hl). rewrite PTree.gss in Hb. injection Hb as <- <-.
    cbn [Mem.loadv] in Hl. rewrite hd_ofs, hd_nx, (R_head m j HR Hj) in Hl by exact Hj. injection Hl as <-.
    pose proof (in_nth_concat _ _ _ Hin) as Ha.
    destruct (call_ccl _ _ _ _ _ _ _ _ ka j [] (nth j rs []) H HR Ha Hj eq_refl
                (fun Hin' => nodup_disj rs i j ka (R_nodup m HR) Nij Hin Hin')
                ltac:(rewrite PTree.gso by exact (not_eq_sym N3); rewrite PTree.gso by exact (not_eq_sym N2);
                      rewrite PTree.gso by exact (not_eq_sym N1); exact Hs)
                eq_refl eq_refl) as (Hm & -> & ->).
    - intros v Ev. apply ev_cast in Ev as (w & Ew & Cw). apply ev_temp in Ew.
      rewrite PTree.gso in Ew by exact N4. rewrite PTree.gss in Ew. injection Ew as <-.
      cbn [typeof] in Cw. exact (cast_po _ _ _ Cw).
    - intros v Ev. rewrite (ev_hdarg _ _ _ _ _ la Ptrofs.zero Ev ltac:(apply PTree.gss)).
      rewrite hd_ofs by exact Hj. reflexivity.
    - split; [ exact Hm | split; [ reflexivity | eauto ] ].
  Qed.

  (* check_collision_in_list(sp18, sp18->header.next, sp1C), the list's own *)
  Lemma selfc : forall le m t le' m' out tn ka i pre post, exec_stmt function_entry2 G empty_env le m
      (Ssequence (Sset tn (Efield (Efield (Ederef (Etempvar OC._sp18 tobj) (Tstruct OC._Object noattr))
                                    OC._header (Tstruct OC._ObjectNode noattr)) OC._next tnd))
        (Scall None (Evar OC._check_collision_in_list (Tfunction (tobj :: tobj :: tobj :: nil) tvoid cc_default))
           [Etempvar OC._sp18 tobj; Ecast (Etempvar tn tnd) tobj; Etempvar OC._sp1C tobj])) t le' m' out ->
    R m -> (i < OW.NLIST)%nat -> nth i rs [] = pre ++ ka :: post ->
    le ! OC._sp18 = Some (OW.slot_v pool ka) -> le ! OC._sp1C = Some (ObjLoop.head_v la i) ->
    tn <> OC._sp18 -> tn <> OC._sp1C ->
    R m' /\ out = Out_normal /\ exists v, le' = PTree.set tn v le.
  Proof.
    intros le m t le' m' out tn ka i pre post H HR Hi Epp Hs Hc N1 N2.
    sx H E1.
    assert (Hin : In ka (nth i rs [])) by (rewrite Epp; apply in_or_app; right; left; reflexivity).
    pose proof (in_nth_concat _ _ _ Hin) as Ha. pose proof (R_range m ka HR Ha) as Hk.
    destruct (ev_hn _ _ _ _ E1) as (b & o & Hb & Hl). rewrite Hs in Hb. injection Hb as <- <-.
    cbn [Mem.loadv] in Hl. rewrite slot_nx, (R_next m i pre ka post HR Hi Epp) in Hl by exact Hk.
    injection Hl as <-.
    destruct (call_ccl _ _ _ _ _ _ _ _ ka i (pre ++ [ka]) post H HR Ha Hi ltac:(rewrite Epp, <- app_assoc; reflexivity)
                (nodup_after _ _ _ _ (nodup_nth rs i (R_nodup m HR)) Epp)
                ltac:(rewrite PTree.gso by exact (not_eq_sym N1); exact Hs)
                eq_refl eq_refl) as (Hm & -> & ->).
    - intros v Ev. apply ev_cast in Ev as (w & Ew & Cw). apply ev_temp in Ew. rewrite PTree.gss in Ew.
      injection Ew as <-. cbn [typeof] in Cw. exact (cast_po _ _ _ Cw).
    - intros v Ev. apply ev_temp in Ev. rewrite PTree.gso in Ev by exact (not_eq_sym N2). rewrite Hc in Ev.
      injection Ev as <-. reflexivity.
    - split; [ exact Hm | split; [ reflexivity | eauto ] ].
  Qed.

  (* sp18 = sp18->header.next *)
  Lemma adv : forall le m t le' m' out tn i pre ka post, exec_stmt function_entry2 G empty_env le m
      (Ssequence (Sset tn (Efield (Efield (Ederef (Etempvar OC._sp18 tobj) (Tstruct OC._Object noattr))
                                    OC._header (Tstruct OC._ObjectNode noattr)) OC._next tnd))
        (Sset OC._sp18 (Ecast (Etempvar tn tnd) tobj))) t le' m' out ->
    R m -> (i < OW.NLIST)%nat -> nth i rs [] = pre ++ ka :: post ->
    le ! OC._sp18 = Some (OW.slot_v pool ka) -> tn <> OC._sp18 ->
    m' = m /\ out = Out_normal
    /\ le' ! OC._sp18 = Some (ObjLoop.first_v pool la (Z.of_nat i * OW.NODESZ) post)
    /\ (forall x, x <> OC._sp18 -> x <> tn -> le' ! x = le ! x).
  Proof.
    intros le m t le' m' out tn i pre ka post H HR Hi Epp Hs N1.
    sx H E1. apply set_inv in H as (v & E2 & -> & -> & ->).
    assert (Hin : In ka (nth i rs [])) by (rewrite Epp; apply in_or_app; right; left; reflexivity).
    pose proof (R_range m ka HR (in_nth_concat _ _ _ Hin)) as Hk.
    destruct (ev_hn _ _ _ _ E1) as (b & o & Hb & Hl). rewrite Hs in Hb. injection Hb as <- <-.
    cbn [Mem.loadv] in Hl. rewrite slot_nx, (R_next m i pre ka post HR Hi Epp) in Hl by exact Hk.
    injection Hl as <-.
    apply ev_cast in E2 as (w & Ew & Cw). apply ev_temp in Ew. rewrite PTree.gss in Ew. injection Ew as <-.
    cbn [typeof] in Cw. apply cast_po in Cw. subst v.
    split; [ reflexivity | split; [ reflexivity | split; [ apply PTree.gss | ] ] ].
    intros xv Nx Nt. rewrite PTree.gso by exact Nx. rewrite PTree.gso by exact Nt. reflexivity.
  Qed.

  Definition Iout (i : nat) (le : temp_env) (m : mem) : Prop :=
    R m /\ le ! OC._sp1C = Some (ObjLoop.head_v la i)
    /\ exists pre post, nth i rs [] = pre ++ post
       /\ le ! OC._sp18 = Some (ObjLoop.first_v pool la (Z.of_nat i * OW.NODESZ) post).

  (* the loop's head: the cursor at the head ends it *)
  Ltac ohead H :=
    let pre := fresh "pre" in let post := fresh "post" in
    let HR := fresh "HR" in let Hc := fresh "Hc" in let Epp := fresh "Epp" in let Hs := fresh "Hs" in
    let ka := fresh "ka" in
    intros ? ? ? ? ? ? (HR & Hc & pre & post & Epp & Hs) H;
    apply seq_inv in H;
    let t1 := fresh "t" in let le2 := fresh "le" in let m2 := fresh "m" in let t2 := fresh "t" in
    let H1 := fresh "H" in let Hn := fresh "Hn" in
    destruct H as [(t1 & le2 & m2 & t2 & H1 & H) | (H1 & Hn)];
    [ | apply if_inv in H1; destruct H1 as (? & [|] & ? & ? & H1); cbv iota in H1;
        [ apply skip_inv in H1; destruct H1 as (_ & _ & H1); exfalso; exact (Hn H1)
        | apply break_inv in H1; destruct H1 as (-> & -> & ->); left; split; [ reflexivity | exact HR ] ] ];
    let cv := fresh "cv" in let Ec := fresh "Ec" in let Eb := fresh "Eb" in
    apply if_inv in H1; destruct H1 as (cv & ? & Ec & Eb & H1);
    destruct post as [| ka post];
    [ exfalso; apply ev_binop in Ec; destruct Ec as (? & ? & E1 & E2 & E3);
      apply ev_temp in E1; apply ev_temp in E2;
      rewrite Hs in E1; rewrite Hc in E2; injection E1; intros <-; injection E2; intros <-;
      cbn [typeof ObjLoop.first_v] in E3; unfold ObjLoop.head_v in E3; apply cmp_self_o in E3; subst cv;
      cbn in Eb; injection Eb; intros <-; cbv iota in H1;
      apply break_inv in H1; destruct H1 as (_ & _ & E); discriminate E
    | ];
    match goal with Hb : bool_val _ _ _ = Some ?b |- _ =>
      destruct b; cbv iota in H1; [ | apply break_inv in H1; destruct H1 as (_ & _ & E); discriminate E ] end;
    apply skip_inv in H1; destruct H1 as (-> & -> & _);
    cbn [ObjLoop.first_v] in Hs.

  (* the loop's start: sp1C = gObjectLists + i; sp18 = sp1C->header.next *)
  Lemma ostart : forall le m t le' m' out t1 t2 (i : nat), exec_stmt function_entry2 G empty_env le m
      (Ssequence (Sset t1 (Evar OC._gObjectLists tnd))
        (Ssequence (Sset OC._sp1C (Ecast (Ebinop Oadd (Etempvar t1 tnd) (Econst_int (Int.repr (Z.of_nat i)) tint) tnd) tobj))
          (Ssequence (Sset t2 (Efield (Efield (Ederef (Etempvar OC._sp1C tobj) (Tstruct OC._Object noattr))
                                        OC._header (Tstruct OC._ObjectNode noattr)) OC._next tnd))
            (Sset OC._sp18 (Ecast (Etempvar t2 tnd) tobj))))) t le' m' out ->
    R m -> (i < OW.NLIST)%nat -> t1 <> OC._sp1C -> t2 <> OC._sp1C -> t1 <> t2 ->
    m' = m /\ out = Out_normal /\ Iout i le' m.
  Proof.
    intros le m t le' m' out t1 t2 i H HR Hi N1 N2 N3.
    sx H E1. sx H E2. sx H E3. apply set_inv in H as (v & E4 & -> & -> & ->).
    pose proof (ev_gol _ _ _ HR E1) as ->.
    rewrite (ev_hdarg _ _ _ _ _ la Ptrofs.zero E2 ltac:(apply PTree.gss)), hd_ofs in * by exact Hi.
    destruct (ev_hn _ _ _ _ E3) as (b & o & Hb & Hl). rewrite PTree.gss in Hb. injection Hb as <- <-.
    cbn [Mem.loadv] in Hl. rewrite hd_cell, (R_head m i HR Hi) in Hl by exact Hi. injection Hl as <-.
    apply ev_cast in E4 as (w & Ew & Cw). apply ev_temp in Ew. rewrite PTree.gss in Ew. injection Ew as <-.
    cbn [typeof] in Cw. apply cast_po in Cw. subst v.
    split; [ reflexivity | split; [ reflexivity | ] ].
    split; [ exact HR | split ].
    - rewrite PTree.gso by neq. rewrite PTree.gso by exact (not_eq_sym N2). apply PTree.gss.
    - exists [], (nth i rs []). split; [ reflexivity | apply PTree.gss ].
  Qed.

  Ltac blk H B m1 :=
    let Hn := fresh "Hn" in
    apply seq_inv in H; destruct H as [(? & ? & m1 & ? & B & H) | (B & Hn)];
    [ | exfalso; exact (Hn (ObjLoop.plain_out _ _ _ _ _ _ _ _ _ B ltac:(vm_compute; reflexivity))) ].

  Lemma player_ok : forall m t m' vr, R m ->
    eval_funcall function_entry2 G m (Internal OC.f_check_player_object_collision) [] t m' vr -> R m'.
  Proof.
    intros m t m' vr HR Hev.
    destruct (fentry _ _ _ _ _ _ _ Hev eq_refl) as (le & le' & out & Hbd & H).
    cbn in Hbd. injection Hbd as <-.
    unfold OC.f_check_player_object_collision in H; cbn [fn_body] in H.
    apply seq_assoc_r in H as (? & H). blk H Sb mw1. fl Sb. destruct (ostart _ _ _ _ _ _ _ _ 0 Sb HR ltac:(cbv; lia) ltac:(neq) ltac:(neq) ltac:(neq))
      as (-> & _ & HI). clear Sb.
    refine (proj1 (while_keep G _ _ (Iout 0) R _ _ _ _ _ _ _ _ H)); [ | exact HI ].
    clear H HI. clear dependent m. clear dependent t.
    ohead H.
    assert (Hin : In ka (nth 0 rs [])) by (rewrite Epp; apply in_or_app; right; left; reflexivity).
    blk H Sb mw1. destruct (selfc _ _ _ _ _ _ _ _ 0 _ _ Sb HR ltac:(cbv; lia) Epp Hs Hc ltac:(neq) ltac:(neq))
      as (R1 & _ & v & ->). clear Sb.
    blk H Sb mw2. destruct (callj _ _ _ _ _ _ _ _ _ 10 ka 0 Sb R1 ltac:(lk) Hin ltac:(cbv; lia) ltac:(lia) ltac:(neq) ltac:(neq) ltac:(neq) ltac:(neq)) as (R2 & _ & ? & ? & ? & ->). clear Sb.
    blk H Sb mw3. destruct (callj _ _ _ _ _ _ _ _ _ 6 ka 0 Sb R2 ltac:(lk) Hin ltac:(cbv; lia) ltac:(lia) ltac:(neq) ltac:(neq) ltac:(neq) ltac:(neq)) as (R3 & _ & ? & ? & ? & ->). clear Sb.
    blk H Sb mw4. destruct (callj _ _ _ _ _ _ _ _ _ 4 ka 0 Sb R3 ltac:(lk) Hin ltac:(cbv; lia) ltac:(lia) ltac:(neq) ltac:(neq) ltac:(neq) ltac:(neq)) as (R4 & _ & ? & ? & ? & ->). clear Sb.
    blk H Sb mw5. destruct (callj _ _ _ _ _ _ _ _ _ 5 ka 0 Sb R4 ltac:(lk) Hin ltac:(cbv; lia) ltac:(lia) ltac:(neq) ltac:(neq) ltac:(neq) ltac:(neq)) as (R5 & _ & ? & ? & ? & ->). clear Sb.
    blk H Sb mw6. destruct (callj _ _ _ _ _ _ _ _ _ 9 ka 0 Sb R5 ltac:(lk) Hin ltac:(cbv; lia) ltac:(lia) ltac:(neq) ltac:(neq) ltac:(neq) ltac:(neq)) as (R6 & _ & ? & ? & ? & ->). clear Sb.
    blk H Sb mw7. destruct (callj _ _ _ _ _ _ _ _ _ 2 ka 0 Sb R6 ltac:(lk) Hin ltac:(cbv; lia) ltac:(lia) ltac:(neq) ltac:(neq) ltac:(neq) ltac:(neq)) as (R7 & _ & ? & ? & ? & ->). clear Sb.
    destruct (adv _ _ _ _ _ _ _ 0 pre ka post H R7 ltac:(cbv; lia) Epp ltac:(lk) ltac:(neq)) as (-> & -> & Hs' & Hk').
    right. split; [ reflexivity | ]. split; [ exact R7 | split ].
    - rewrite Hk' by neq. lk.
    - exists (pre ++ [ka]), post. split; [ rewrite Epp, <- app_assoc; reflexivity | exact Hs' ].
  Qed.

  Lemma push_ok : forall m t m' vr, R m ->
    eval_funcall function_entry2 G m (Internal OC.f_check_pushable_object_collision) [] t m' vr -> R m'.
  Proof.
    intros m t m' vr HR Hev.
    destruct (fentry _ _ _ _ _ _ _ Hev eq_refl) as (le & le' & out & Hbd & H).
    cbn in Hbd. injection Hbd as <-.
    unfold OC.f_check_pushable_object_collision in H; cbn [fn_body] in H.
    apply seq_assoc_r in H as (? & H). blk H Sb mw1. fl Sb. destruct (ostart _ _ _ _ _ _ _ _ 5 Sb HR ltac:(cbv; lia) ltac:(neq) ltac:(neq) ltac:(neq))
      as (-> & _ & HI). clear Sb.
    refine (proj1 (while_keep G _ _ (Iout 5) R _ _ _ _ _ _ _ _ H)); [ | exact HI ].
    clear H HI. clear dependent m. clear dependent t.
    ohead H.
    blk H Sb mw1. destruct (selfc _ _ _ _ _ _ _ _ 5 _ _ Sb HR ltac:(cbv; lia) Epp Hs Hc ltac:(neq) ltac:(neq))
      as (R1 & _ & v & ->). clear Sb.
    destruct (adv _ _ _ _ _ _ _ 5 pre ka post H R1 ltac:(cbv; lia) Epp ltac:(lk) ltac:(neq)) as (-> & -> & Hs' & Hk').
    right. split; [ reflexivity | ]. split; [ exact R1 | split ].
    - rewrite Hk' by neq. lk.
    - exists (pre ++ [ka]), post. split; [ rewrite Epp, <- app_assoc; reflexivity | exact Hs' ].
  Qed.

  Lemma destr_ok : forall m t m' vr, R m ->
    eval_funcall function_entry2 G m (Internal OC.f_check_destructive_object_collision) [] t m' vr -> R m'.
  Proof.
    intros m t m' vr HR Hev.
    destruct (fentry _ _ _ _ _ _ _ Hev eq_refl) as (le & le' & out & Hbd & H).
    cbn in Hbd. injection Hbd as <-.
    unfold OC.f_check_destructive_object_collision in H; cbn [fn_body] in H.
    apply seq_assoc_r in H as (? & H). blk H Sb mw1. fl Sb. destruct (ostart _ _ _ _ _ _ _ _ 2 Sb HR ltac:(cbv; lia) ltac:(neq) ltac:(neq) ltac:(neq))
      as (-> & _ & HI). clear Sb.
    refine (proj1 (while_keep G _ _ (Iout 2) R _ _ _ _ _ _ _ _ H)); [ | exact HI ].
    clear H HI. clear dependent m. clear dependent t.
    ohead H.
    assert (Hin : In ka (nth 2 rs [])) by (rewrite Epp; apply in_or_app; right; left; reflexivity).
    (* the test (a pure block), then the calls *)
    blk H X mw1. apply seq_inv in X. destruct X as [(? & lep & mp & ? & P & X) | (P & Hn)].
    2: { exfalso. exact (Hn (ObjLoop.plain_out _ _ _ _ _ _ _ _ _ P ltac:(vm_compute; reflexivity))). }
    pose proof (pure_mem _ _ _ _ _ _ _ _ _ P ltac:(vm_compute; reflexivity)) as ->.
    assert (K1 : lep ! OC._sp18 = Some (OW.slot_v pool ka) /\ lep ! OC._sp1C = Some (ObjLoop.head_v la 2)).
    { rewrite (ObjLoop.nosets_keep _ _ _ _ _ _ _ _ _ P OC._sp18 ltac:(vm_compute; reflexivity)).
      rewrite (ObjLoop.nosets_keep _ _ _ _ _ _ _ _ _ P OC._sp1C ltac:(vm_compute; reflexivity)). auto. }
    destruct K1 as (Hs1 & Hc1). clear P.
    pose proof (ObjLoop.nosets_keep _ _ _ _ _ _ _ _ _ X OC._sp18 ltac:(vm_compute; reflexivity)) as K18.
    pose proof (ObjLoop.nosets_keep _ _ _ _ _ _ _ _ _ X OC._sp1C ltac:(vm_compute; reflexivity)) as K1C.
    assert (R1 : R mw1).
    { apply if_inv in X as (? & cb & _ & _ & X). destruct cb; cbv iota in X;
        [ | apply skip_inv in X as (-> & _ & _); exact HR ].
      blk X Sb mw2. destruct (selfc _ _ _ _ _ _ _ _ 2 _ _ Sb HR ltac:(cbv; lia) Epp Hs1 Hc1 ltac:(neq) ltac:(neq))
        as (R2 & _ & v & ->). clear Sb.
      blk X Sb mw3. destruct (callj _ _ _ _ _ _ _ _ _ 4 ka 2 Sb R2 ltac:(lk) Hin ltac:(cbv; lia) ltac:(lia) ltac:(neq) ltac:(neq) ltac:(neq) ltac:(neq)) as (R3 & _ & ? & ? & ? & ->). clear Sb.
      blk X Sb mw4. destruct (callj _ _ _ _ _ _ _ _ _ 5 ka 2 Sb R3 ltac:(lk) Hin ltac:(cbv; lia) ltac:(lia) ltac:(neq) ltac:(neq) ltac:(neq) ltac:(neq)) as (R4 & _ & ? & ? & ? & ->). clear Sb.
      destruct (callj _ _ _ _ _ _ _ _ _ 9 ka 2 X R4 ltac:(lk) Hin ltac:(cbv; lia) ltac:(lia) ltac:(neq) ltac:(neq) ltac:(neq) ltac:(neq)) as (R5 & _ & _). exact R5. }
    clear X.
    destruct (adv _ _ _ _ _ _ _ 2 pre ka post H R1 ltac:(cbv; lia) Epp ltac:(rewrite K18; exact Hs1) ltac:(neq))
      as (-> & -> & Hs' & Hk').
    right. split; [ reflexivity | ]. split; [ exact R1 | split ].
    - rewrite Hk' by neq. rewrite K1C. exact Hc1.
    - exists (pre ++ [ka]), post. split; [ rewrite Epp, <- app_assoc; reflexivity | exact Hs' ].
  Qed.

  (* ---- 11. detect_object_collisions ---- *)
  Lemma clr : forall le m t le' m' out tx (i : nat), exec_stmt function_entry2 G empty_env le m
      (Ssequence (Sset tx (Evar OC._gObjectLists tnd))
        (Scall None (Evar OC._clear_object_collision (Tfunction (tobj :: nil) tvoid cc_default))
          [Ecast (Ebinop Oadd (Etempvar tx tnd) (Econst_int (Int.repr (Z.of_nat i)) tint) tnd) tobj])) t le' m' out -> R m -> (i < OW.NLIST)%nat ->
    R m' /\ out = Out_normal.
  Proof.
    intros le m t le' m' out tx i H HR Hi.
    sx H E1. pose proof (ev_gol _ _ _ HR E1) as ->.
    apply call_inv in H as (tya & tyr & cc & vf & vargs & fd & vres & Hcf & Evf & Eal & Hff & _ & Hcall & -> & ->).
    cbn in Hcf. injection Hcf as <- <- <-.
    destruct (evf G m _ _ _ vf Evf eq_refl) as (bf & Hsy & ->).
    rewrite (fun_oc _ _ dm_clear bf fd Hsy Hff) in Hcall.
    destruct (ObjLoop.exl1 _ _ _ _ _ _ _ Eal) as (ty1 & v1 & w1 & E & -> & Ev & C). injection E as <-.
    rewrite (ev_hdarg _ _ _ _ _ la Ptrofs.zero Ev ltac:(apply PTree.gss)), hd_ofs in C by exact Hi.
    cbn [typeof] in C. apply cast_oo in C. subst w1.
    split; [ exact (clear_ok i m _ _ _ _ Hi HR eq_refl Hcall) | reflexivity ].
  Qed.

  Lemma call0 : forall le m fid f t le' m' out,
    (prog_defmap OC.prog) ! fid = Some (Gfun (Internal f)) ->
    exec_stmt function_entry2 G empty_env le m (Scall None (Evar fid (Tfunction nil tvoid cc_default)) nil) t le' m' out ->
    exists t' vr, eval_funcall function_entry2 G m (Internal f) [] t' m' vr /\ out = Out_normal.
  Proof.
    intros le m fid f t le' m' out Hdm H.
    apply call_inv in H as (tya & tyr & cc & vf & vargs & fd & vres & Hcf & Evf & Eal & Hff & _ & Hcall & -> & ->).
    cbn in Hcf. injection Hcf as <- <- <-.
    destruct (evf G m le _ _ vf Evf eq_refl) as (bf & Hsy & ->).
    rewrite (fun_oc _ _ Hdm bf fd Hsy Hff) in Hcall. inv Eal. eauto.
  Qed.

  Lemma detect_ok : forall m t m' vr, R m ->
    eval_funcall function_entry2 G m (Internal OC.f_detect_object_collisions) [] t m' vr -> R m'.
  Proof.
    intros m t m' vr HR Hev.
    destruct (fentry _ _ _ _ _ _ _ Hev eq_refl) as (le & le' & out & Hbd & H).
    cbn in Hbd. injection Hbd as <-.
    unfold OC.f_detect_object_collisions in H; cbn [fn_body] in H.
    blk H Sb mw1. destruct (clr _ _ _ _ _ _ _ 10 Sb HR ltac:(cbv; lia)) as (R1 & _). clear Sb.
    blk H Sb mw2. destruct (clr _ _ _ _ _ _ _ 0 Sb R1 ltac:(cbv; lia)) as (R2 & _). clear Sb.
    blk H Sb mw3. destruct (clr _ _ _ _ _ _ _ 5 Sb R2 ltac:(cbv; lia)) as (R3 & _). clear Sb.
    blk H Sb mw4. destruct (clr _ _ _ _ _ _ _ 4 Sb R3 ltac:(cbv; lia)) as (R4 & _). clear Sb.
    blk H Sb mw5. destruct (clr _ _ _ _ _ _ _ 6 Sb R4 ltac:(cbv; lia)) as (R5 & _). clear Sb.
    blk H Sb mw6. destruct (clr _ _ _ _ _ _ _ 9 Sb R5 ltac:(cbv; lia)) as (R6 & _). clear Sb.
    blk H Sb mw7. destruct (clr _ _ _ _ _ _ _ 2 Sb R6 ltac:(cbv; lia)) as (R7 & _). clear Sb.
    blk H Sb mw8. destruct (call0 _ _ _ _ _ _ _ _ dm_player Sb) as (t1 & v1 & C & _).
    pose proof (player_ok _ _ _ _ R7 C) as R8. clear Sb C.
    blk H Sb mw9. destruct (call0 _ _ _ _ _ _ _ _ dm_destr Sb) as (t2 & v2 & C & _).
    pose proof (destr_ok _ _ _ _ R8 C) as R9. clear Sb C.
    destruct (call0 _ _ _ _ _ _ _ _ dm_push H) as (t3 & v3 & C & _).
    exact (push_ok _ _ _ _ R9 C).
  Qed.
  End RW.

  (* ---- 12. The row: the real detect_object_collisions keeps Pc ---- *)
  Theorem detect_keeps : ObjPhase.call_keeps G Pc OLP._detect_object_collisions.
  Proof.
    intros bf fd m vargs t m' vr Hs Hf HP Hev.
    rewrite (fun_oc _ _ dm_detect bf fd Hs Hf) in Hev.
    assert (Ev : vargs = []).
    { inv Hev. match goal with He : function_entry2 _ _ _ _ _ _ _ |- _ => destruct He as [_ _ _ _ Hb] end.
      cbn in Hb. destruct vargs; [ reflexivity | discriminate Hb ]. }
    subst vargs.
    pose proof HP as (_ & _ & _ & _ & (pool & la & fl & gol & gmo & sdp & gdi & rs & fs & S1 & S2 & S3 & S4 & S5 & S6 & S7 & Hc)).
    pose proof (OW.ow_rings _ _ _ _ _ _ _ _ _ _ _ _ Hc) as Hr.
    enough (X : R pool la rs m') by exact (proj1 X).
    eapply detect_ok; first [ exact Hev | exact (conj HP Hr) | eassumption ].
  Qed.
End CW.
