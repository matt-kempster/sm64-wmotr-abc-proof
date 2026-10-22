(* ====================================================================== *)
(* CeilHeight (GOAL 2): the VALUE find_ceil returns, proved from its        *)
(* generated Clight body (surface_collision.c), as FloorHeight does for     *)
(* find_floor.                                                              *)
(*                                                                          *)
(* find_ceil reads its result from its local `height`.  That local only    *)
(* ever holds 20000 (its initial value), a height find_ceil_from_list      *)
(* stored after the test  y - (h - -78.0f) > 0.0f  came out false (y is    *)
(* the s16 cast of posY), or a copy of `dynamicHeight`, which only holds   *)
(* the same kinds of value.  So the result is 20000 or a height that       *)
(* passed that test, and the s16 cast of posY is defined (the Clight cast   *)
(* is partial, so an execution that gets past it has one).                 *)
(*                                                                          *)
(* The *pceil pointer must point into a block of the entry memory, and      *)
(* gNumCalls must be one: find_ceil allocates `height` as a new block, so  *)
(* a dangling pceil (or gNumCalls block) can name it, and the store        *)
(* *pceil = NULL then overwrites the 20000 with 0.0f (find_ceil returns    *)
(* 0.0f for posX >= 8192, posY = 1000: neither 20000 nor a passed test).   *)
(* That is why the old open premise PoleXc.find_ceil_height, which had no  *)
(* such hypotheses, was FALSE; [fc_height] is the true statement.          *)
(* ====================================================================== *)

From Coq Require Import ZArith List Lia.
From compcert Require Import Coqlib Errors Maps AST Integers Floats Values Memory Events
  Globalenvs Ctypes Cop Clightdefs Clight ClightBigstep.
From SM64.Generated Require surface_collision.
From SM64.Proofs.WMotRRequiresA Require Import FloorList CeilList FloorHeight.
Import ListNotations.

(* find_ceil_from_list's test passed for the stored height h, at int y *)
Definition cok (yv : val) (h : float32) : Prop :=
  exists yi, yv = Vint yi
    /\ Float32.cmp Cgt (Float32.sub (Float32.of_int yi) (Float32.sub h (Float32.neg c78)))
         Float32.zero = false.

Definition cchk_expr : expr :=
  Ebinop Ogt
    (Ebinop Osub (Etempvar surface_collision._y tint)
       (Ebinop Osub (Etempvar surface_collision._height tfloat)
          (Eunop Oneg (Econst_single c78 tfloat) tfloat) tfloat) tfloat)
    (Econst_single (Float32.of_bits (Int.repr 0)) tfloat) tint.

Lemma cchk_eval : forall (ge : genv) e le m v hv yv,
    le ! surface_collision._height = Some hv -> le ! surface_collision._y = Some yv ->
    eval_expr ge e le m cchk_expr v -> bool_val v tint m = Some false ->
    exists h, hv = Vsingle h /\ cok yv h.
Proof.
  intros ge e le m v hv yv Hh Hy H Hb. unfold cchk_expr in H.
  repeat match goal with
         | H : eval_expr _ _ _ _ _ _ |- _ => inv H
         | H : eval_lvalue _ _ _ _ _ _ _ _ |- _ => inv H
         end.
  rewrite Hh in *. rewrite Hy in *.
  repeat match goal with Hx : Some _ = Some _ |- _ => inv Hx end.
  match goal with Hu : sem_unary_operation Oneg _ _ _ = Some _ |- _ => cbn in Hu; inv Hu end.
  cbn [typeof] in *.
  match goal with Ha : sem_binary_operation _ Osub _ tfloat (Vsingle _) tfloat _ = Some _ |- _ =>
    destruct (sub_single _ _ _ _ _ Ha) as (h & -> & ->) end.
  match goal with Hs : sem_binary_operation _ Osub _ tint _ _ _ = Some _ |- _ =>
    destruct (sub_int_single _ _ _ _ _ Hs) as (yi & -> & ->) end.
  match goal with Hc : sem_binary_operation _ Ogt _ _ _ _ _ = Some _ |- _ =>
    cbn in Hc; inv Hc end.
  eexists; split; [reflexivity |]. eexists; split; [reflexivity |].
  destruct (Float32.cmp Cgt _ _); [| reflexivity].
  cbn in Hb. discriminate Hb.
Qed.

(* ---- find_ceil_from_list: memory unchanged, or one passed height stored ---- *)

Definition InvY (yv ph : val) (le : temp_env) : Prop :=
  le ! surface_collision._y = Some yv /\ le ! surface_collision._pheight = Some ph.

Lemma fclh_iter : forall ge e m le t le1 m1 out1 yv ph,
    exec_stmt function_entry2 ge e le m fcl_s1 t le1 m1 out1 ->
    InvY yv ph le ->
    (out1 = Out_break /\ m1 = m)
    \/ (out1 = Out_continue /\ m1 = m /\ InvY yv ph le1)
    \/ (out1 = Out_break /\ exists h, Mem.storev Mfloat32 m ph (Vsingle h) = Some m1 /\ cok yv h).
Proof.
  intros ge e m le t le1 m1 out1 yv ph H (Hy & Hph).
  cbv [fcl_s1 fcl_loop surface_collision.f_find_ceil_from_list fn_body Swhile] in H.
  xinv.
  all: try (left; split; reflexivity).
  all: try (right; left; split; [reflexivity | split; [reflexivity |]];
            split; ptg; assumption).
  (* the ceiling: the test passed, pheight written *)
  all: right; right; split; [reflexivity |].
  all: match goal with
       | Hc : eval_expr _ _ ?L _ (Ebinop Ogt (Ebinop Osub (Etempvar surface_collision._y tint) _ tfloat) _ tint) ?v,
         Hb : bool_val ?v _ _ = Some false |- _ =>
           lazymatch L with context [PTree.set surface_collision._height ?hv _] =>
             let Hhh := fresh "Hhh" in let Hyy := fresh "Hyy" in
             assert (Hhh : L ! surface_collision._height = Some hv) by (ptg; reflexivity);
             assert (Hyy : L ! surface_collision._y = Some yv) by (ptg; exact Hy);
             destruct (cchk_eval _ _ _ _ _ _ _ Hhh Hyy Hc Hb) as (h0 & -> & Hk)
           end
       end.
  all: repeat match goal with Hl : eval_lvalue _ _ _ _ (Ederef _ _) _ _ _ |- _ => inv Hl end.
  all: repeat match goal with Ht : eval_expr _ _ _ _ (Etempvar _ _) _ |- _ =>
         inv Ht; [| match goal with Hl : eval_lvalue _ _ _ _ (Etempvar _ _) _ _ _ |- _ => inv Hl end]
       end.
  all: repeat match goal with Hx : (PTree.set _ _ _) ! _ = Some _ |- _ =>
         progress (repeat first [ rewrite PTree.gss in Hx
                                | rewrite PTree.gso in Hx by (let HH := fresh in intro HH; cbv in HH; discriminate HH) ])
       end.
  all: repeat match goal with Hx : Some _ = Some _ |- _ => inv Hx end.
  all: match goal with Hc : sem_cast (Vsingle _) _ _ _ = Some _ |- _ => cbn in Hc; inv Hc end.
  all: match goal with Ha : assign_loc _ _ _ _ _ _ _ _ |- _ => inv Ha end;
       try (cbn in *; discriminate).
  all: match goal with Hp : _ ! surface_collision._pheight = Some (Vptr _ _) |- _ =>
         rewrite Hph in Hp; inv Hp end.
  all: match goal with Hm : access_mode _ = By_value _ |- _ => cbn in Hm; inv Hm end.
  all: exists h0; split; [eassumption | exact Hk].
Qed.

Lemma fclh_loop_spec : forall ge e m le t le' m' out yv ph,
    exec_stmt function_entry2 ge e le m fcl_loop t le' m' out ->
    InvY yv ph le ->
    m' = m \/ exists h, Mem.storev Mfloat32 m ph (Vsingle h) = Some m' /\ cok yv h.
Proof.
  intros ge e m le t le' m' out yv ph H.
  rewrite fcl_loop_shape in H.
  remember (Sloop fcl_s1 Sskip) as S eqn:ES. revert ES.
  induction H; intros ES HI; try discriminate ES.
  - injection ES as -> ->.
    match goal with Hx : exec_stmt _ _ _ _ _ fcl_s1 _ _ _ _,
                    Hb : out_break_or_return _ _ |- _ =>
      destruct (fclh_iter _ _ _ _ _ _ _ _ _ _ Hx HI)
        as [(-> & ->) | [(-> & _ & _) | (-> & h & Hst & Hk)]];
      inv Hb
    end.
    + left; reflexivity.
    + right; eauto.
  - injection ES as -> ->.
    match goal with Hs : exec_stmt _ _ _ _ _ Sskip _ _ _ _,
                    Hb : out_break_or_return _ _ |- _ => inv Hs; inv Hb end.
  - injection ES as -> ->.
    match goal with Hx : exec_stmt _ _ _ _ _ fcl_s1 _ _ _ _,
                    Hn : out_normal_or_continue _ |- _ =>
      destruct (fclh_iter _ _ _ _ _ _ _ _ _ _ Hx HI)
        as [(-> & _) | [(-> & -> & HI') | (-> & _)]];
      [inv Hn | | inv Hn]
    end.
    match goal with Hs : exec_stmt _ _ _ _ _ Sskip _ _ _ _ |- _ => inv Hs end.
    eauto.
Qed.

Theorem fclh_value : forall (ge : genv) m node x y z ph t m' vres,
    eval_funcall function_entry2 ge m
      (Internal surface_collision.f_find_ceil_from_list) [node; x; y; z; ph] t m' vres ->
    m' = m \/ exists h, Mem.storev Mfloat32 m ph (Vsingle h) = Some m' /\ cok y h.
Proof.
  intros ge m node x y z ph t m' vres H.
  inv H.
  match goal with He : function_entry2 _ _ _ _ _ _ _ |- _ => inv He end.
  match goal with Ha : alloc_variables _ _ _ _ _ _ |- _ => inv Ha end.
  match goal with Hb : bind_parameter_temps _ _ _ = Some _ |- _ =>
    cbn [bind_parameter_temps surface_collision.f_find_ceil_from_list fn_params] in Hb;
    injection Hb as <- end.
  match goal with Hf : Mem.free_list _ _ = Some _ |- _ =>
    cbn [blocks_of_env PTree.elements Mem.free_list] in Hf; injection Hf as <- end.
  match goal with Hx : exec_stmt _ _ _ _ _ _ _ _ _ _ |- _ => rewrite fcl_body_shape in Hx end.
  xinv.
  all: repeat match goal with H : exec_stmt _ _ _ _ _ (Sreturn _) _ _ _ _ |- _ => inv H end.
  all: match goal with Hl : exec_stmt _ _ _ ?L _ ?S _ _ _ _ |- _ =>
         let HI := fresh "HI" in
         assert (HI : InvY y ph L) by (split; ptg; reflexivity);
         exact (fclh_loop_spec _ _ _ _ _ _ _ _ _ _ Hl HI) end.
Qed.

Lemma fclh_args5 : forall (ge : genv) m vargs t m' vres,
    eval_funcall function_entry2 ge m (Internal surface_collision.f_find_ceil_from_list)
      vargs t m' vres ->
    exists node x y z ph, vargs = [node; x; y; z; ph].
Proof. exact fcl_args5. Qed.

Lemma fclh_call : forall (ge : genv) e le m tid args targs tres cc t le' m' out,
    fcl_pinned ge -> e ! surface_collision._find_ceil_from_list = None ->
    exec_stmt function_entry2 ge e le m
      (Scall (Some tid) (Evar surface_collision._find_ceil_from_list (Tfunction targs tres cc)) args)
      t le' m' out ->
    exists node x y z ph fl,
      eval_exprlist ge e le m args targs [node; x; y; z; ph]
      /\ out = Out_normal /\ le' = PTree.set tid fl le
      /\ (m' = m \/ exists h, Mem.storev Mfloat32 m ph (Vsingle h) = Some m' /\ cok y h).
Proof.
  intros ge e le m tid args targs tres cc t le' m' out Hpin He H.
  inv H.
  cbn [typeof classify_fun] in *.
  match goal with Hc : fun_case_f _ _ _ = fun_case_f _ _ _ |- _ => inv Hc end.
  match goal with Hv : eval_expr _ _ _ _ (Evar _ _) _ |- _ => inv Hv end.
  match goal with Hl : eval_lvalue _ _ _ _ (Evar _ _) _ _ _ |- _ => inv Hl end; [congruence |].
  match goal with Hd : deref_loc _ _ _ _ _ _ |- _ => inv Hd end;
    cbn [access_mode] in *; try discriminate.
  match goal with Hf : Genv.find_funct _ (Vptr _ _) = Some _ |- _ =>
    cbn [Genv.find_funct] in Hf; rewrite pred_dec_true in Hf by reflexivity;
    rewrite (Hpin _ _ ltac:(eassumption) Hf) in * end.
  match goal with Hev : eval_funcall _ _ _ _ _ _ _ _ |- _ =>
    destruct (fclh_args5 _ _ _ _ _ _ Hev) as (node & x & y & z & ph & ->);
    pose proof (fclh_value _ _ _ _ _ _ _ _ _ _ Hev) as Hr end.
  do 6 eexists. split; [eassumption |]. split; [reflexivity |]. split; [reflexivity |]. exact Hr.
Qed.

(* ---- find_ceil's body ---- *)

Definition c20000 : float32 := Float32.of_int (Int.repr 20000).

(* the temps that only ever hold copies of a height cell *)
Definition cts : list ident :=
  [surface_collision._t'5; surface_collision._t'7; surface_collision._t'8;
   surface_collision._t'9; surface_collision._t'10; surface_collision._t'11].

Section FCH.
Variable ge : genv.
Variables bH bD bpf : block.
Variable opf : ptrofs.
Variable yv : val.
Hypothesis Hcpin : fcl_pinned ge.
Hypothesis HHD : bH <> bD.
Hypothesis HpH : bpf <> bH.
Hypothesis HpD : bpf <> bD.
Hypothesis Hgl : forall b, Genv.find_symbol ge surface_collision._gNumCalls = Some b -> b <> bH /\ b <> bD.

Local Notation e := (ffe bH bD).
Local Notation Y := (ycast yv).

Definition okv (v : val) : Prop := exists h, v = Vsingle h /\ (h = c20000 \/ cok Y h).

Definition CH (hs ds ys : bool) (le : temp_env) (M : mem) : Prop :=
  le ! surface_collision._posY = Some yv
  /\ le ! surface_collision._pceil = Some (Vptr bpf opf)
  /\ (forall tk v, In tk cts -> le ! tk = Some v -> v = Vundef \/ okv v)
  /\ (hs = true -> forall v, Mem.load Mfloat32 M bH 0 = Some v -> okv v)
  /\ (ds = true -> forall v, Mem.load Mfloat32 M bD 0 = Some v -> okv v)
  /\ (ys = true -> le ! surface_collision._y = Some Y /\ exists yi, Y = Vint yi).

Definition RC (out : outcome) (M : mem) : Prop :=
  forall v ty, out = Out_return (Some (v, ty)) ->
    ty = tfloat /\ (v = Vundef \/ okv v) /\ exists yi, Y = Vint yi.

Ltac idne := let HH := fresh in intro HH; cbv in HH; discriminate HH.
Ltac nin := let H := fresh in intro H; cbv in H;
  repeat (destruct H as [H|H]; [discriminate H |]); exact H.
Ltac inh := cbv; repeat (first [left; reflexivity | right]).

Lemma CH_set_other : forall hs ds ys x a R,
    ~ In x cts -> x <> surface_collision._posY -> x <> surface_collision._pceil ->
    x <> surface_collision._y ->
    trh ge e (CH hs ds ys) (Sset x a) (CH hs ds ys) R.
Proof.
  intros hs ds ys x a R Hn Hp Hc Hy. apply trh_set.
  intros le M v (P & C & T & H1 & D1 & Y1) _.
  split; [rewrite PTree.gso by congruence; exact P |].
  split; [rewrite PTree.gso by congruence; exact C |].
  split; [intros tk w Hin Hl; rewrite PTree.gso in Hl by (intros ->; contradiction); eauto |].
  split; [exact H1 | split; [exact D1 |]].
  intros Ht. destruct (Y1 Ht) as (Yl & Yi). split; [rewrite PTree.gso by congruence; exact Yl | exact Yi].
Qed.

Lemma ev_var : forall le M x b w,
    (x = surface_collision._height /\ b = bH) \/ (x = surface_collision._dynamicHeight /\ b = bD) ->
    eval_expr ge e le M (Evar x tfloat) w -> Mem.load Mfloat32 M b 0 = Some w.
Proof.
  intros le M x b w Hx H.
  inv H. match goal with Hl : eval_lvalue _ _ _ _ (Evar _ _) _ _ _ |- _ => inv Hl end.
  - match goal with Hd : deref_loc _ _ _ _ _ _ |- _ => inv Hd end; cbn in *; try discriminate.
    match goal with Ha : By_value _ = By_value _ |- _ => inv Ha end.
    match goal with Hl : Mem.load _ _ _ _ = Some _, He : (ffe _ _) ! x = Some _ |- _ =>
      rewrite Ptrofs.unsigned_zero in Hl; destruct Hx as [(-> & ->) | (-> & ->)];
      [rewrite ffe_H in He | rewrite ffe_D in He]; inv He; exact Hl end.
  - destruct Hx as [(-> & _) | (-> & _)]; [rewrite ffe_H in * | rewrite ffe_D in *]; discriminate.
Qed.

Lemma lv_var : forall le M x b ty bb ofs bf,
    (x = surface_collision._height /\ b = bH) \/ (x = surface_collision._dynamicHeight /\ b = bD) ->
    eval_lvalue ge e le M (Evar x ty) bb ofs bf -> bb = b /\ ofs = Ptrofs.zero /\ bf = Full.
Proof.
  intros le M x b ty bb ofs bf Hx H. inv H.
  - destruct Hx as [(-> & ->) | (-> & ->)];
      [rewrite ffe_H in * | rewrite ffe_D in *];
      match goal with He : Some _ = Some _ |- _ => inv He end; auto.
  - destruct Hx as [(-> & _) | (-> & _)]; [rewrite ffe_H in * | rewrite ffe_D in *]; discriminate.
Qed.

Lemma CH_set_ld : forall hs ds ys tk x b R,
    In tk cts ->
    (x = surface_collision._height /\ b = bH /\ hs = true)
    \/ (x = surface_collision._dynamicHeight /\ b = bD /\ ds = true) ->
    trh ge e (CH hs ds ys) (Sset tk (Evar x tfloat)) (CH hs ds ys) R.
Proof.
  intros hs ds ys tk x b R Hk Hx. apply trh_set.
  intros le M v (P & C & T & H1 & D1 & Y1) Hev.
  assert (Hok : okv v).
  { destruct Hx as [(-> & -> & Hs) | (-> & -> & Hs)].
    - apply (H1 Hs). exact (ev_var _ _ _ _ _ (or_introl (conj eq_refl eq_refl)) Hev).
    - apply (D1 Hs). exact (ev_var _ _ _ _ _ (or_intror (conj eq_refl eq_refl)) Hev). }
  assert (Npy : tk <> surface_collision._posY) by (intros ->; revert Hk; nin).
  assert (Npc : tk <> surface_collision._pceil) by (intros ->; revert Hk; nin).
  assert (Ny : tk <> surface_collision._y) by (intros ->; revert Hk; nin).
  split; [rewrite PTree.gso by congruence; exact P |].
  split; [rewrite PTree.gso by congruence; exact C |].
  split.
  { intros tk' w Hin Hl. destruct (peq tk' tk) as [-> | Hne].
    - rewrite PTree.gss in Hl. injection Hl as <-. right; exact Hok.
    - rewrite PTree.gso in Hl by exact Hne. eauto. }
  split; [exact H1 | split; [exact D1 |]].
  intros Ht. destruct (Y1 Ht) as (Yl & Yi). split; [rewrite PTree.gso by congruence; exact Yl | exact Yi].
Qed.

Lemma CH_set_y : forall hs ds R,
  trh ge e (CH hs ds false)
    (Sset surface_collision._y (Ecast (Ecast (Etempvar surface_collision._posY tfloat) tshort) tshort))
    (CH hs ds true) R.
Proof.
  intros hs ds R le M t le' M' out HI H. inv H. left. split; [reflexivity |].
  destruct HI as (P & C & T & H1 & D1 & _).
  match goal with Hx : eval_expr _ _ _ _ _ _ |- _ => rename Hx into Hev end.
  inv Hev; [| match goal with Hl : eval_lvalue _ _ _ _ (Ecast _ _) _ _ _ |- _ => inv Hl end].
  match goal with Hk : eval_expr _ _ _ _ (Ecast _ _) _ |- _ =>
    inv Hk; [| match goal with Hl : eval_lvalue _ _ _ _ (Ecast _ _) _ _ _ |- _ => inv Hl end] end.
  match goal with Ht : eval_expr _ _ _ _ (Etempvar _ _) _ |- _ =>
    inv Ht; [| match goal with Hl : eval_lvalue _ _ _ _ (Etempvar _ _) _ _ _ |- _ => inv Hl end] end.
  match goal with Hx : le ! surface_collision._posY = Some _ |- _ => rewrite P in Hx; inv Hx end.
  cbn [typeof] in *.
  match goal with H1 : sem_cast _ tfloat tshort _ = Some ?v1,
                  H2 : sem_cast ?v1 tshort tshort _ = Some ?vv |- _ =>
    pose proof (ycast_ok _ _ _ _ _ H1 H2) as Ev;
    assert (Hi : exists yi, vv = Vint yi)
      by (destruct v1; cbn in H2; try discriminate H2; injection H2 as <-; eauto) end.
  subst. destruct Hi as (yi & Hi).
  split; [rewrite PTree.gso by idne; exact P |].
  split; [rewrite PTree.gso by idne; exact C |].
  split; [intros tk w Hin Hl; rewrite PTree.gso in Hl by (intros ->; revert Hin; nin); eauto |].
  split; [exact H1 | split; [exact D1 |]].
  intros _. split; [apply PTree.gss | exists yi; exact Hi].
Qed.

Lemma assign_load_other' : forall ty M b ofs bf v M' ch b' z,
    assign_loc ge ty M b ofs bf v M' -> b' <> b -> Mem.load ch M' b' z = Mem.load ch M b' z.
Proof.
  intros ty M b ofs bf v M' ch b' z Ha Hn. inv Ha.
  - cbn [Mem.storev] in *. eapply Mem.load_store_other; [eassumption | left; exact Hn].
  - eapply Mem.load_storebytes_other; [eassumption | left; exact Hn].
  - match goal with Hs : ?T |- _ => lazymatch T with context [store_bitfield] => inv Hs end end.
    eapply Mem.load_store_other; [eassumption | left; exact Hn].
Qed.

Lemma CH_assign_other : forall hs ds ys lhs rhs R,
    (forall le M b ofs bf, CH hs ds ys le M -> eval_lvalue ge e le M lhs b ofs bf -> b <> bH /\ b <> bD) ->
    trh ge e (CH hs ds ys) (Sassign lhs rhs) (CH hs ds ys) R.
Proof.
  intros hs ds ys lhs rhs R Hl. apply trh_assign.
  intros le M b ofs bf v v' M' HI Hlv _ _ Ha.
  destruct (Hl _ _ _ _ _ HI Hlv) as (N1 & N2).
  destruct HI as (P & C & T & H1 & D1 & Y1).
  split; [exact P | split; [exact C | split; [exact T |]]].
  split; [intros Hs w Hw; rewrite (assign_load_other' _ _ _ _ _ _ _ _ _ _ Ha (not_eq_sym N1)) in Hw; eauto |].
  split; [intros Hs w Hw; rewrite (assign_load_other' _ _ _ _ _ _ _ _ _ _ Ha (not_eq_sym N2)) in Hw; eauto |].
  exact Y1.
Qed.

Lemma lv_pceil : forall hs ds ys le M b ofs bf ty,
    CH hs ds ys le M ->
    eval_lvalue ge e le M (Ederef (Etempvar surface_collision._pceil
       (tptr (tptr (Tstruct surface_collision._Surface noattr)))) ty) b ofs bf ->
    b <> bH /\ b <> bD.
Proof.
  intros hs ds ys le M b ofs bf ty (_ & C & _) H. inv H.
  match goal with Ht : eval_expr _ _ _ _ (Etempvar _ _) _ |- _ =>
    inv Ht; [| match goal with Hl : eval_lvalue _ _ _ _ (Etempvar _ _) _ _ _ |- _ => inv Hl end] end.
  rewrite C in *. match goal with Hx : Some _ = Some _ |- _ => inv Hx end. auto.
Qed.

Lemma lv_ncalls : forall hs ds ys le M b ofs bf,
    CH hs ds ys le M ->
    eval_lvalue ge e le M
      (Efield (Evar surface_collision._gNumCalls (Tstruct surface_collision._NumTimesCalled noattr))
         surface_collision._ceil tshort) b ofs bf ->
    b <> bH /\ b <> bD.
Proof.
  intros hs ds ys le M b ofs bf _ H. inv H; cbn [typeof] in *; try discriminate.
  match goal with Ha : eval_expr _ _ _ _ (Evar _ _) _ |- _ => inv Ha end.
  match goal with Hd : deref_loc _ _ _ _ _ _ |- _ => inv Hd end;
    cbn [access_mode] in *; try discriminate;
    [| match goal with Hb : load_bitfield _ _ _ _ _ _ _ _ |- _ => inv Hb end].
  match goal with Hl : eval_lvalue _ _ _ _ (Evar _ _) _ _ _ |- _ => inv Hl end.
  - match goal with Hx : (ffe _ _) ! _ = Some _ |- _ => rewrite ffe_other in Hx by idne; discriminate Hx end.
  - eauto.
Qed.

Lemma CH_assign_init : forall x b hs ds hs' ds' R,
    (x = surface_collision._height /\ b = bH /\ hs' = true /\ ds' = ds)
    \/ (x = surface_collision._dynamicHeight /\ b = bD /\ ds' = true /\ hs' = hs) ->
    trh ge e (CH hs ds false) (Sassign (Evar x tfloat) (Econst_int (Int.repr 20000) tint))
      (CH hs' ds' false) R.
Proof.
  intros x b hs ds hs' ds' R Hx le M t le' M' out HI H. inv H. left. split; [reflexivity |].
  match goal with Hl : eval_lvalue _ _ _ _ (Evar _ _) _ _ _ |- _ =>
    destruct (lv_var _ _ x b _ _ _ _ ltac:(destruct Hx as [(? & ? & _) | (? & ? & _)]; [left | right]; auto) Hl)
      as (-> & -> & ->) end.
  match goal with Hk : eval_expr _ _ _ _ (Econst_int _ _) _ |- _ =>
    inv Hk; [| match goal with Hl : eval_lvalue _ _ _ _ (Econst_int _ _) _ _ _ |- _ => inv Hl end] end.
  match goal with Hc : sem_cast _ _ _ _ = Some _ |- _ => cbn in Hc; inv Hc end.
  match goal with Ha : assign_loc _ _ _ _ _ _ _ _ |- _ => inv Ha end; cbn in *; try discriminate.
  match goal with Hm : By_value _ = By_value _ |- _ => inv Hm end.
  match goal with Hs : Mem.store _ _ _ _ _ = Some _ |- _ =>
    assert (HS : Mem.store Mfloat32 M b 0 (Vsingle c20000) = Some M') by exact Hs; clear Hs end.
  destruct HI as (P & C & T & H1 & D1 & Y1).
  assert (Okc : okv (Vsingle c20000)) by (exists c20000; auto).
  split; [exact P | split; [exact C | split; [exact T |]]].
  destruct Hx as [(-> & -> & -> & ->) | (-> & -> & -> & ->)].
  - split; [intros _ w Hw; rewrite (Mem.load_store_same _ _ _ _ _ _ ltac:(eassumption)) in Hw;
            injection Hw as <-; exact Okc |].
    split; [| exact Y1].
    intros Hs w Hw. erewrite Mem.load_store_other in Hw by (eassumption || (left; congruence)). eauto.
  - split; [intros Hs w Hw; erewrite Mem.load_store_other in Hw by (eassumption || (left; congruence)); eauto |].
    split; [| exact Y1].
    intros _ w Hw. rewrite (Mem.load_store_same _ _ _ _ _ _ ltac:(eassumption)) in Hw.
    injection Hw as <-. exact Okc.
Qed.

Lemma CH_assign_t9 : forall R,
  trh ge e (CH true true true)
    (Sassign (Evar surface_collision._height tfloat) (Etempvar surface_collision._t'9 tfloat))
    (CH true true true) R.
Proof.
  intros R le M t le' M' out HI H. inv H. left. split; [reflexivity |].
  match goal with Hl : eval_lvalue _ _ _ _ (Evar _ _) _ _ _ |- _ =>
    destruct (lv_var _ _ _ bH _ _ _ _ (or_introl (conj eq_refl eq_refl)) Hl) as (-> & -> & ->) end.
  destruct HI as (P & C & T & H1 & D1 & Y1).
  match goal with Ht : eval_expr _ _ _ _ (Etempvar _ _) _ |- _ =>
    inv Ht; [| match goal with Hl : eval_lvalue _ _ _ _ (Etempvar _ _) _ _ _ |- _ => inv Hl end] end.
  match goal with Hx : _ ! ?k = Some ?w |- _ =>
    destruct (T k _ ltac:(inh) Hx) as [-> | (h & -> & Hh)] end;
  match goal with Hc : sem_cast _ _ _ _ = Some _ |- _ => cbn in Hc; try discriminate Hc; inv Hc end.
  match goal with Ha : assign_loc _ _ _ _ _ _ _ _ |- _ => inv Ha end; cbn in *; try discriminate.
  match goal with Hm : By_value _ = By_value _ |- _ => inv Hm end.
  match goal with Hs : Mem.store _ _ _ _ _ = Some _ |- _ =>
    assert (HS : Mem.store Mfloat32 M bH 0 (Vsingle h) = Some M') by exact Hs; clear Hs end.
  split; [exact P | split; [exact C | split; [exact T |]]].
  split; [intros _ w Hw; rewrite (Mem.load_store_same _ _ _ _ _ _ ltac:(eassumption)) in Hw;
          injection Hw as <-; exists h; auto |].
  split; [| exact Y1].
  intros Hs w Hw. erewrite Mem.load_store_other in Hw by (eassumption || (left; congruence)). eauto.
Qed.

Lemma CH_call : forall tk tres cc loc bL R,
    ((loc = surface_collision._height /\ bL = bH)
     \/ (loc = surface_collision._dynamicHeight /\ bL = bD)) ->
    ~ In tk cts -> tk <> surface_collision._posY -> tk <> surface_collision._pceil ->
    tk <> surface_collision._y ->
    trh ge e (CH true true true)
      (Scall (Some tk)
         (Evar surface_collision._find_ceil_from_list
            (Tfunction [tptr (Tstruct surface_collision._SurfaceNode noattr); tint; tint; tint;
                        tptr tfloat] tres cc))
         [Etempvar surface_collision._surfaceList
            (tptr (Tstruct surface_collision._SurfaceNode noattr));
          Etempvar surface_collision._x tshort; Etempvar surface_collision._y tshort;
          Etempvar surface_collision._z tshort; Eaddrof (Evar loc tfloat) (tptr tfloat)])
      (CH true true true) R.
Proof.
  intros tk tres cc loc bL R Hloc Hn1 Hn2 Hn3 Hn4.
  intros le M t le' M' out HI H.
  assert (Hn : e ! surface_collision._find_ceil_from_list = None) by (apply ffe_other; idne).
  destruct (fclh_call _ _ _ _ _ _ _ _ _ _ _ _ _ Hcpin Hn H)
    as (node & x & y & z & ph & fl0 & Hargs & -> & -> & Hres).
  left; split; [reflexivity |].
  destruct HI as (P & C & T & H1 & D1 & Y1).
  destruct (Y1 eq_refl) as (Yl & yi & Yi).
  assert (HI' : CH true true true (PTree.set tk fl0 le) M).
  { split; [rewrite PTree.gso by congruence; exact P |].
    split; [rewrite PTree.gso by congruence; exact C |].
    split; [intros tk' w Hin Hl; rewrite PTree.gso in Hl by (intros ->; contradiction); eauto |].
    split; [exact H1 | split; [exact D1 |]].
    intros _. split; [rewrite PTree.gso by congruence; exact Yl | exists yi; exact Yi]. }
  destruct Hres as [-> | (h & Hstv & Hk)]; [exact HI' |].
  repeat match goal with Hl : eval_exprlist _ _ _ _ (_ :: _) _ _ |- _ => inv Hl end.
  (* y: the s16 y, cast to int *)
  match goal with Ht : eval_expr _ _ _ _ (Etempvar surface_collision._y _) _ |- _ =>
    inv Ht; [| match goal with Hl : eval_lvalue _ _ _ _ (Etempvar _ _) _ _ _ |- _ => inv Hl end] end.
  match goal with Hx : le ! surface_collision._y = Some _ |- _ => rewrite Yl in Hx; inv Hx end.
  rewrite Yi in *.
  match goal with Hc : sem_cast (Vint yi) _ tint _ = Some y |- _ => cbn in Hc; inv Hc end.
  (* ph = &loc *)
  match goal with Ha : eval_expr _ _ _ _ (Eaddrof _ _) _ |- _ =>
    inv Ha; [| match goal with Hl : eval_lvalue _ _ _ _ (Eaddrof _ _) _ _ _ |- _ => inv Hl end] end.
  match goal with Hl : eval_lvalue _ _ _ _ (Evar _ _) _ _ _ |- _ =>
    destruct (lv_var _ _ loc bL _ _ _ _ ltac:(destruct Hloc as [(-> & ->) | (-> & ->)]; [left | right]; auto) Hl)
      as (-> & -> & _) end.
  match goal with Hc : sem_cast _ (typeof (Eaddrof _ _)) _ _ = Some _ |- _ =>
    cbn [typeof] in Hc; apply cast_ptr_same in Hc; subst end.
  cbn [Mem.storev] in Hstv. rewrite Ptrofs.unsigned_zero in Hstv.
  assert (Okh : okv (Vsingle h)) by (exists h; split; [reflexivity | right; rewrite Yi; exact Hk]).
  destruct HI' as (P' & C' & T' & _ & _ & Y1').
  split; [exact P' | split; [exact C' | split; [exact T' |]]].
  destruct Hloc as [(-> & ->) | (-> & ->)].
  - split; [intros _ w Hw; rewrite (Mem.load_store_same _ _ _ _ _ _ Hstv) in Hw;
            injection Hw as <-; exact Okh |].
    split; [| exact Y1'].
    intros Hs w Hw. erewrite Mem.load_store_other in Hw by (eassumption || (left; congruence)). eauto.
  - split; [intros Hs w Hw; erewrite Mem.load_store_other in Hw by (eassumption || (left; congruence)); eauto |].
    split; [| exact Y1'].
    intros _ w Hw. rewrite (Mem.load_store_same _ _ _ _ _ _ Hstv) in Hw.
    injection Hw as <-. exact Okh.
Qed.

Lemma CH_ret : forall tk, In tk cts ->
    trh ge e (CH true true true) (Sreturn (Some (Etempvar tk tfloat))) (CH true true true) RC.
Proof.
  intros tk Hk. apply trh_ret. intros le M v (_ & _ & T & _ & _ & Y1) Hev v' ty Ho.
  injection Ho as <- <-. split; [reflexivity |].
  inv Hev; [| match goal with Hl : eval_lvalue _ _ _ _ (Etempvar _ _) _ _ _ |- _ => inv Hl end].
  split; [eauto | exact (proj2 (Y1 eq_refl))].
Qed.

Ltac solve_c :=
  lazymatch goal with
  | |- trh _ _ _ (Ssequence _ _) _ _ => eapply (trh_seq _ _ _ _ (CH true true true)); [solve_c | solve_c]
  | |- trh _ _ _ (Sifthenelse _ _ _) _ _ => eapply trh_ite; [solve_c | solve_c]
  | |- trh _ _ _ Sskip _ _ => apply trh_skip
  | |- trh _ _ _ (Sreturn _) _ _ => apply CH_ret; inh
  | |- trh _ _ _ (Scall _ _ _) _ _ =>
      eapply CH_call; [first [left; split; reflexivity | right; split; reflexivity]
                      | nin | idne | idne | idne]
  | |- trh _ _ _ (Sset ?tk (Evar surface_collision._height _)) _ _ =>
      eapply (CH_set_ld _ _ _ tk _ bH); [inh | left; auto]
  | |- trh _ _ _ (Sset ?tk (Evar surface_collision._dynamicHeight _)) _ _ =>
      eapply (CH_set_ld _ _ _ tk _ bD); [inh | right; auto]
  | |- trh _ _ _ (Sset _ _) _ _ => apply CH_set_other; [nin | idne | idne | idne]
  | |- trh _ _ _ (Sassign (Evar surface_collision._height _) (Etempvar _ _)) _ _ => apply CH_assign_t9
  | |- trh _ _ _ (Sassign (Ederef _ _) _) _ _ => apply CH_assign_other; intros; eapply lv_pceil; eassumption
  | |- trh _ _ _ (Sassign (Efield _ _ _) _) _ _ => apply CH_assign_other; intros; eapply lv_ncalls; eassumption
  end.

Lemma fc_body_trh :
  trh ge e (CH false false false) (fn_body surface_collision.f_find_ceil) (CH true true true) RC.
Proof.
  cbn [fn_body surface_collision.f_find_ceil].
  eapply (trh_seq _ _ _ _ (CH true false false));
    [apply (CH_assign_init _ bH); left; auto |].
  eapply (trh_seq _ _ _ _ (CH true true false));
    [apply (CH_assign_init _ bD); right; auto |].
  eapply (trh_seq _ _ _ _ (CH true true false)); [apply CH_set_other; [nin | idne | idne | idne] |].
  eapply (trh_seq _ _ _ _ (CH true true true)); [apply CH_set_y |].
  solve_c.
Qed.
End FCH.

(* THE VALUE: find_ceil returns 20000 or a height that passed
   find_ceil_from_list's test at the s16 cast of posY (which is defined),
   for a *pceil and a gNumCalls in blocks of the entry memory. *)
Theorem fc_height : forall (ge : genv), fcl_pinned ge ->
    forall m xv yv zv bpf opf t m' vres,
      Mem.valid_block m bpf ->
      (forall b, Genv.find_symbol ge surface_collision._gNumCalls = Some b -> Mem.valid_block m b) ->
      eval_funcall function_entry2 ge m (Internal surface_collision.f_find_ceil)
        [xv; yv; zv; Vptr bpf opf] t m' vres ->
      exists h yi, vres = Vsingle h /\ ycast yv = Vint yi
        /\ (h = c20000
            \/ Float32.cmp Cgt (Float32.sub (Float32.of_int yi) (Float32.sub h (Float32.neg c78)))
                 Float32.zero = false).
Proof.
  intros ge Hcpin m xv yv zv bpf opf t m' vres Hpv Hsv H.
  inv H.
  match goal with He : function_entry2 _ _ _ _ _ _ _ |- _ => inv He end.
  match goal with Ha : alloc_variables _ _ _ _ _ _ |- _ =>
    cbn [surface_collision.f_find_ceil fn_vars] in Ha; inv Ha end.
  match goal with Ha : alloc_variables _ _ _ _ _ _ |- _ => inv Ha end.
  match goal with Ha : alloc_variables _ _ _ [] _ _ |- _ => inv Ha end.
  match goal with
  | A1 : Mem.alloc m 0 _ = (?M1, ?b1), A2 : Mem.alloc ?M1 0 _ = (?M2, ?b2) |- _ =>
      rename b1 into bH, b2 into bD, A1 into HA1, A2 into HA2, M1 into mA, M2 into mB
  end.
  assert (HHD : bH <> bD)
    by (intros E; subst; exact (Mem.fresh_block_alloc _ _ _ _ _ HA2 (Mem.valid_new_block _ _ _ _ _ HA1))).
  assert (Vne : forall b, Mem.valid_block m b -> b <> bH /\ b <> bD).
  { intros b Hb. split; intros ->.
    - exact (Mem.fresh_block_alloc _ _ _ _ _ HA1 Hb).
    - exact (Mem.fresh_block_alloc _ _ _ _ _ HA2 (Mem.valid_block_alloc _ _ _ _ _ HA1 _ Hb)). }
  destruct (Vne _ Hpv) as (HpH & HpD).
  assert (Hgl : forall b, Genv.find_symbol ge surface_collision._gNumCalls = Some b -> b <> bH /\ b <> bD)
    by (intros b Hs; exact (Vne b (Hsv b Hs))).
  match goal with Hb : bind_parameter_temps _ _ _ = Some ?L |- _ =>
    assert (HI : CH bH bD bpf opf yv false false false L mB);
    [cbn [bind_parameter_temps surface_collision.f_find_ceil fn_params] in Hb; injection Hb as <- |]
  end.
  { split; [reflexivity |]. split; [reflexivity |].
    split; [| split; [discriminate | split; discriminate]].
    intros tk v Hin Hl. left. cbv in Hin.
    repeat (destruct Hin as [<- | Hin]; [cbv in Hl; injection Hl as <-; reflexivity |]). contradiction. }
  match goal with Hx : exec_stmt _ _ _ _ _ _ _ _ _ _ |- _ =>
    destruct (fc_body_trh ge bH bD bpf opf yv Hcpin HHD HpH HpD Hgl _ _ _ _ _ _ HI Hx)
      as [(-> & _) | (_ & HR)] end.
  { match goal with Ho : outcome_result_value _ _ _ _ |- _ => cbn in Ho; contradiction end. }
  match goal with Ho : outcome_result_value _ _ _ _ |- _ =>
    cbn [fn_return surface_collision.f_find_ceil] in Ho; rename Ho into HO end.
  destruct out as [| | | [[v ty]|]]; cbn in HO; try contradiction.
  destruct HO as (_ & Hc).
  destruct (HR v ty eq_refl) as (-> & Hv & yi & Yi).
  destruct Hv as [-> | (h & -> & Hh)]; [cbn in Hc; discriminate Hc |].
  cbn in Hc. injection Hc as <-.
  exists h, yi. split; [reflexivity |]. split; [exact Yi |].
  destruct Hh as [-> | (yi' & Ey & Hk)]; [left; reflexivity | right].
  rewrite Yi in Ey. injection Ey as <-. exact Hk.
Qed.
