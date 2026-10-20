(* ====================================================================== *)
(* WallFind (unwired, GOAL 2): the VALUE contract of the real              *)
(* find_wall_collisions (surface_collision.c), proved from its generated   *)
(* Clight body through WallList.wfl_contract.                              *)
(*                                                                          *)
(* For some total c >= 0 (the collisions of both partition lists):         *)
(*   - the result is c;                                                     *)
(*   - numWalls = min(c, 4), and each recorded wall is a surface read off  *)
(*     a partition list of the entry memory;                               *)
(*   - nothing else changes but colData->x, ->z, ->numWalls, ->walls and   *)
(*     gNumCalls.wall, and no permission changes.                          *)
(* ====================================================================== *)

From Coq Require Import ZArith List Lia.
From compcert Require Import Coqlib Errors Maps AST Integers Floats Values Memory Events
  Globalenvs Ctypes Cop Clightdefs Clight ClightBigstep.
From SM64.Generated Require surface_collision.
From SM64.Proofs Require Import WMotRRequiresA.FloorList WMotRRequiresA.WallList.
Import ListNotations.

Local Notation SC := surface_collision.prog.

Definition wfl_pinned (ge : genv) : Prop :=
  forall bf f, Genv.find_symbol ge surface_collision._find_wall_collisions_from_list = Some bf ->
    Genv.find_funct_ptr ge bf = Some f ->
    f = Internal surface_collision.f_find_wall_collisions_from_list.

Lemma wfl_call : forall (ge : genv) le m tid args targs tres cc t le' m' out,
    wfl_pinned ge ->
    exec_stmt function_entry2 ge empty_env le m
      (Scall (Some tid)
         (Evar surface_collision._find_wall_collisions_from_list (Tfunction targs tres cc)) args)
      t le' m' out ->
    exists vargs vres t', eval_exprlist ge empty_env le m args targs vargs
      /\ out = Out_normal /\ le' = PTree.set tid vres le
      /\ eval_funcall function_entry2 ge m
           (Internal surface_collision.f_find_wall_collisions_from_list) vargs t' m' vres.
Proof.
  intros ge le m tid args targs tres cc t le' m' out Hpin H.
  inv H.
  cbn [typeof classify_fun] in *.
  match goal with Hc : fun_case_f _ _ _ = fun_case_f _ _ _ |- _ => inv Hc end.
  match goal with Hv : eval_expr _ _ _ _ (Evar _ _) _ |- _ => inv Hv end.
  match goal with Hl : eval_lvalue _ _ _ _ (Evar _ _) _ _ _ |- _ => inv Hl end;
    [rewrite PTree.gempty in *; discriminate |].
  match goal with Hd : deref_loc _ _ _ _ _ _ |- _ => inv Hd end;
    cbn [access_mode] in *; try discriminate.
  match goal with Hf : Genv.find_funct _ (Vptr _ _) = Some _ |- _ =>
    cbn [Genv.find_funct] in Hf; rewrite pred_dec_true in Hf by reflexivity;
    rewrite (Hpin _ _ ltac:(eassumption) Hf) in * end.
  do 3 eexists. split; [eassumption |]. split; [reflexivity |]. split; [reflexivity |].
  eassumption.
Qed.

(* NumTimesCalled.wall is at offset 4 *)
Lemma ntc_wall_ofs : forall (ge : genv) co, cenv_has ge ->
    (genv_cenv ge) ! surface_collision._NumTimesCalled = Some co ->
    field_offset ge surface_collision._wall (co_members co) = OK (4, Full).
Proof.
  intros ge co HC H.
  assert (M : match (prog_comp_env SC) ! surface_collision._NumTimesCalled with
              | Some co => co_members co | None => nil end
              = [Member_plain surface_collision._floor tshort;
                 Member_plain surface_collision._ceil tshort;
                 Member_plain surface_collision._wall tshort]) by (vm_compute; reflexivity).
  destruct ((prog_comp_env SC) ! surface_collision._NumTimesCalled) as [co0|] eqn:E0;
    [| discriminate M].
  rewrite (HC _ _ E0) in H. injection H as <-. rewrite M. reflexivity.
Qed.

(* every return of these statements returns temp x (an int) *)
Definition is_tint (ty : type) : bool :=
  match ty with
  | Tint I32 Signed {| attr_volatile := false; attr_alignas := None |} => true
  | _ => false
  end.

Lemma is_tint_eq : forall ty, is_tint ty = true -> ty = Tint I32 Signed noattr.
Proof.
  intros ty H. destruct ty as [| [] [] [[] []] | | | | | | |]; try discriminate H. reflexivity.
Qed.

Fixpoint rx_chk (x : ident) (s : statement) : bool :=
  match s with
  | Sskip | Sset _ _ | Sassign _ _ | Scall _ _ _ => true
  | Sreturn (Some (Etempvar y ty)) => Pos.eqb y x && is_tint ty
  | Ssequence s1 s2 => rx_chk x s1 && rx_chk x s2
  | Sifthenelse _ s1 s2 => rx_chk x s1 && rx_chk x s2
  | _ => false
  end.

Lemma rx_out : forall (ge : genv) e le m s t le' m' out x,
  exec_stmt function_entry2 ge e le m s t le' m' out -> rx_chk x s = true ->
  out = Out_normal \/ exists v, out = Out_return (Some (v, Tint I32 Signed noattr)) /\ le' ! x = Some v.
Proof.
  intros ge e le m s t le' m' out x H.
  induction H; intros Hc; cbn [rx_chk] in Hc; try discriminate Hc; auto.
  - apply andb_prop in Hc as [Hc1 Hc2]. exact (IHexec_stmt2 Hc2).
  - apply andb_prop in Hc as [Hc1 Hc2]. destruct (IHexec_stmt Hc1) as [-> | ?]; [congruence | auto].
  - apply andb_prop in Hc as [Hc1 Hc2]. apply IHexec_stmt. destruct b; assumption.
  - match goal with Hev : eval_expr _ _ _ _ ?a _ |- _ =>
      destruct a as [| | | | | y ty | | | | | | | |]; try discriminate Hc end.
    apply andb_prop in Hc as [Hy Ht]. apply Pos.eqb_eq in Hy. subst y.
    rewrite (is_tint_eq _ Ht) in *.
    right. exists v. split; [reflexivity |].
    inv H; [assumption | match goal with Hl : eval_lvalue _ _ _ _ (Etempvar _ _) _ _ _ |- _ => inv Hl end].
Qed.

Ltac wf_inlist := cbn; repeat (first [left; reflexivity | right]).
Ltac wf_base A :=
  lazymatch A with
  | Evar ?x _ => x
  | Ebinop _ ?a1 _ _ => wf_base a1
  | Ederef ?a1 _ => wf_base a1
  end.

Section WF.
Variable ge : genv.
Variable avoid : block -> Prop.
Variable m : mem.
Variable bd : block.
Variable od : ptrofs.
Hypothesis HC : cenv_has ge.
Hypothesis Hpin : wfl_pinned ge.
Hypothesis Hav : avoid bd.
Hypothesis Hro : Ptrofs.unsigned od + 40 <= Ptrofs.modulus.
Hypothesis Hcl : forall b, Genv.find_symbol ge surface_collision._gNumCalls = Some b ->
  avoid b /\ b <> bd.
Hypothesis Hpart : forall id bp, In id part_ids -> Genv.find_symbol ge id = Some bp ->
  Mem.valid_block m bp /\ ~ avoid bp.
Hypothesis Hwf : forall hd, part_head ge m hd -> wf_list m avoid hd.

Local Notation o := (Ptrofs.unsigned od).
Local Notation e := empty_env.

(* the cells find_wall_collisions may write *)
Definition wF (b : block) (i : Z) : Prop :=
  (b = bd /\ (o <= i < o + 4 \/ o + 8 <= i < o + 12 \/ o + 22 <= i < o + 40))
  \/ (Genv.find_symbol ge surface_collision._gNumCalls = Some b /\ 4 <= i < 6).

Definition keptF (b : block) (i : Z) : Prop := Mem.valid_block m b /\ ~ wF b i.

Definition UOF (M : mem) : Prop :=
  Mem.unchanged_on keptF m M
  /\ (forall b i k p, Mem.valid_block m b -> (Mem.perm m b i k p <-> Mem.perm M b i k p)).

(* a wall find_wall_collisions reports: a surface on a partition list of m *)
Definition WS (s : val) : Prop := exists hd, part_head ge m hd /\ on_list m hd s.


Lemma UOF_ld : forall M b z ch, UOF M -> Mem.valid_block m b -> ~ avoid b ->
  Mem.load ch M b z = Mem.load ch m b z.
Proof.
  intros M b z ch (U & _) Hv Hna. eapply Mem.load_unchanged_on_1; [exact U | exact Hv |].
  intros i _. split; [exact Hv |].
  intros [(-> & _) | (Hs & _)]; [exact (Hna Hav) | exact (Hna (proj1 (Hcl _ Hs)))].
Qed.

Lemma UOF_keep : forall M, UOF M -> Mem.unchanged_on (keep m avoid) m M.
Proof.
  intros M (U & _). eapply Mem.unchanged_on_implies; [exact U |].
  intros b i (Hv & Hna) _. split; [exact Hv |].
  intros [(-> & _) | (Hs & _)]; [exact (Hna Hav) | exact (Hna (proj1 (Hcl _ Hs)))].
Qed.

Lemma wf_to_M : forall M hd, UOF M -> wf_list m avoid hd -> wf_list M avoid hd.
Proof.
  intros M hd U W. induction W as [| bn on nx Hv Hna Hld W IH]; [constructor |].
  apply wf_cons with nx.
  - eapply Mem.valid_block_unchanged_on; [exact (proj1 U) | exact Hv].
  - exact Hna.
  - cbn [Mem.loadv] in *. rewrite (UOF_ld _ _ _ _ U Hv Hna). exact Hld.
  - exact IH.
Qed.

(* a field of *tid, for a temp tid holding the colData pointer *)
Lemma pf_lv : forall tid le M fld ty b ofs bf d,
    le ! tid = Some (Vptr bd od) ->
    field_offset ge fld wcd_members = OK (d, Full) ->
    eval_lvalue ge e le M (Efield (Ederef (Etempvar tid (tptr wcd_ty)) wcd_ty) fld ty) b ofs bf ->
    b = bd /\ ofs = Ptrofs.add od (Ptrofs.repr d) /\ bf = Full.
Proof.
  intros tid le M fld ty b ofs bf d Hd F H.
  inv H; cbn [typeof] in *; [| discriminate].
  match goal with Ha : eval_expr _ _ _ _ (Ederef _ _) _ |- _ => inv Ha end.
  match goal with Hl : eval_lvalue _ _ _ _ (Ederef _ _) _ _ _ |- _ => inv Hl end.
  match goal with Ht : eval_expr _ _ _ _ (Etempvar _ _) _ |- _ =>
    inv Ht; [| match goal with Hl : eval_lvalue _ _ _ _ (Etempvar _ _) _ _ _ |- _ => inv Hl end] end.
  match goal with Ht : wcd_ty = Tstruct _ _ |- _ => unfold wcd_ty in Ht; injection Ht as <- _ end.
  rewrite Hd in *. match goal with Hx : Some _ = Some _ |- _ => inv Hx end.
  match goal with Hx : deref_loc _ _ _ _ _ _ |- _ => inv Hx end;
    cbn [typeof access_mode wcd_ty] in *; try discriminate.
  match goal with Hc : (genv_cenv ge) ! _ = Some ?co, Hf : field_offset _ _ _ = OK _ |- _ =>
    rewrite (wcd_ofs ge co fld d HC Hc F) in Hf; injection Hf as <- <- end.
  auto.
Qed.

Lemma ofs_d' : forall d, 0 <= d < 40 -> Ptrofs.unsigned (Ptrofs.add od (Ptrofs.repr d)) = o + d.
Proof.
  intros d Hd. pose proof (Ptrofs.unsigned_range od). pose proof ptrofs_mod.
  rewrite Ptrofs.add_unsigned, (Ptrofs.unsigned_repr d) by (unfold Ptrofs.max_unsigned; lia).
  apply Ptrofs.unsigned_repr. unfold Ptrofs.max_unsigned. lia.
Qed.

Lemma UOF_store : forall M M' ch b ofs v,
    UOF M -> Mem.store ch M b ofs v = Some M' ->
    (forall i, ofs <= i < ofs + size_chunk ch -> wF b i) -> UOF M'.
Proof.
  intros M M' ch b ofs v (U & P) Hs Hb. split.
  - eapply Mem.unchanged_on_trans; [exact U |].
    eapply Mem.store_unchanged_on; [exact Hs |].
    intros i Hi (Hv & Hn). exact (Hn (Hb i Hi)).
  - intros b' i k p Hv. rewrite (P b' i k p Hv).
    split; intro HH; [eapply Mem.perm_store_1; eauto | eapply Mem.perm_store_2; eauto].
Qed.

(* ---- the states along the body ---- *)
Definition WSi (n : Z) (M : mem) : Prop :=
  (forall i, 0 <= i < n -> exists s, Mem.load Mint32 M bd (o + 24 + 4 * i) = Some s /\ WS s)
  /\ Mem.unchanged_on (fun b i => b = bd /\ o + 24 + 4 * n <= i < o + 40) m M.

Definition G (c : Z) (le : temp_env) (M : mem) : Prop :=
  UOF M
  /\ le ! surface_collision._colData = Some (Vptr bd od)
  /\ le ! surface_collision._numCollisions = Some (Vint (Int.repr c)) /\ 0 <= c
  /\ Mem.load Mint16signed M bd (o + 22) = Some (Vint (Int.repr (Z.min c 4)))
  /\ WSi (Z.min c 4) M.

Definition Gx (le : temp_env) (M : mem) : Prop := exists c, G c le M.
Definition GN (le : temp_env) (M : mem) : Prop :=
  Gx le M /\ exists hd, le ! surface_collision._node = Some hd /\ part_head ge m hd.
Definition P0 (le : temp_env) (M : mem) : Prop :=
  M = m /\ le ! surface_collision._colData = Some (Vptr bd od).
Definition P1 (le : temp_env) (M : mem) : Prop :=
  P0 le M /\ le ! surface_collision._numCollisions = Some (Vint (Int.repr 0)).

Lemma tri_set_P0 : forall x a R, x <> surface_collision._colData -> tri ge e P0 (Sset x a) P0 R.
Proof.
  intros x a R N. apply tri_set. intros le M v (-> & Hd) _.
  split; [reflexivity | rewrite PTree.gso by congruence; exact Hd].
Qed.

Lemma tri_set_P1 : forall x a R, x <> surface_collision._colData ->
  x <> surface_collision._numCollisions -> tri ge e P1 (Sset x a) P1 R.
Proof.
  intros x a R N1 N2. apply tri_set. intros le M v ((-> & Hd) & Hn) _.
  split; [split; [reflexivity |] |]; rewrite PTree.gso by congruence; assumption.
Qed.

Lemma Gx_set : forall le M x v, Gx le M -> x <> surface_collision._colData ->
  x <> surface_collision._numCollisions -> Gx (PTree.set x v le) M.
Proof.
  intros le M x v (c & U & Hd & Hn & Hc & Hl & HW) N1 N2. exists c.
  split; [exact U |]. split; [rewrite PTree.gso by congruence; exact Hd |].
  split; [rewrite PTree.gso by congruence; exact Hn |]. auto.
Qed.

Lemma tri_set_Gx : forall x a R, x <> surface_collision._colData ->
  x <> surface_collision._numCollisions -> tri ge e Gx (Sset x a) Gx R.
Proof. intros x a R N1 N2. apply tri_set. intros le M v HG _. exact (Gx_set _ _ _ _ HG N1 N2). Qed.

Lemma tri_set_GN : forall x a R, x <> surface_collision._colData ->
  x <> surface_collision._numCollisions -> x <> surface_collision._node -> tri ge e GN (Sset x a) GN R.
Proof.
  intros x a R N1 N2 N3. apply tri_set. intros le M v (HG & hd & Hh & Hp) _.
  split; [exact (Gx_set _ _ _ _ HG N1 N2) |]. exists hd. rewrite PTree.gso by congruence. auto.
Qed.

Lemma tri_nc0 : forall R,
  tri ge e P0 (Sset surface_collision._numCollisions (Econst_int (Int.repr 0) tint)) P1 R.
Proof.
  intros R. apply tri_set2. intros le M v (-> & Hd) Hev.
  inv Hev; [| match goal with Hl : eval_lvalue _ _ _ _ (Econst_int _ _) _ _ _ |- _ => inv Hl end].
  split; [split; [reflexivity | rewrite PTree.gso by idne; exact Hd] | apply PTree.gss].
Qed.

Lemma tri_assign2 : forall (P P' : temp_env -> mem -> Prop) lhs rhs R,
    (forall le M b ofs bf v v' M', P le M ->
       eval_lvalue ge e le M lhs b ofs bf -> eval_expr ge e le M rhs v ->
       sem_cast v (typeof rhs) (typeof lhs) M = Some v' ->
       assign_loc ge (typeof lhs) M b ofs bf v' M' -> P' le M') ->
    tri ge e P (Sassign lhs rhs) P' R.
Proof. intros P P' lhs rhs R HS le M t le' M' out HP H. inv H. left; eauto. Qed.

Lemma tri_nw0 : forall R,
  tri ge e P1
    (Sassign (Efield (Ederef (Etempvar surface_collision._colData (tptr wcd_ty)) wcd_ty)
                surface_collision._numWalls tshort) (Econst_int (Int.repr 0) tint)) Gx R.
Proof.
  intros R. apply tri_assign2.
  intros le M b ofs bf v v' M' ((-> & Hd) & Hn) Hlv Hev Hc Ha.
  destruct (pf_lv _ _ _ surface_collision._numWalls _ _ _ _ 22 Hd eq_refl Hlv) as (-> & -> & ->).
  inv Hev; [| match goal with Hl : eval_lvalue _ _ _ _ (Econst_int _ _) _ _ _ |- _ => inv Hl end].
  vm_compute in Hc. injection Hc as <-.
  inv Ha; cbn [typeof access_mode] in *; try discriminate.
  match goal with Hm : access_mode tshort = By_value _ |- _ =>
    change (access_mode tshort) with (By_value Mint16signed) in Hm; injection Hm as <- end.
  cbn [Mem.storev] in *. rewrite ofs_d' in * by lia.
  match goal with Hst : Mem.store _ _ _ _ _ = Some _ |- _ => rename Hst into ST end.
  exists 0. split; [| split; [exact Hd | split; [exact Hn | split; [lia | split]]]].
  - apply (UOF_store m M' _ _ _ _ (conj (Mem.unchanged_on_refl _ _) (fun _ _ _ _ _ => iff_refl _)) ST).
    intros i Hi. cbn [size_chunk] in Hi. left. split; [reflexivity | lia].
  - rewrite (Mem.load_store_same _ _ _ _ _ _ ST). reflexivity.
  - split; [intros i Hi; lia |].
    eapply Mem.store_unchanged_on; [exact ST |].
    intros i Hi (_ & Hr). cbn [size_chunk] in Hi. lia.
Qed.

Lemma tri_node : forall pid A R,
    In pid part_ids -> gaddr pid A = true ->
    tri ge e Gx
      (Sset surface_collision._node
         (Efield (Ederef A (Tstruct surface_collision._SurfaceNode noattr))
            surface_collision._next (tptr (Tstruct surface_collision._SurfaceNode noattr))))
      GN R.
Proof.
  intros pid A R Hin Ga. apply tri_set2. intros le M v HG Hx.
  destruct (deref_field ge e le M A surface_collision._SurfaceNode surface_collision._next
              (tptr (Tstruct surface_collision._SurfaceNode noattr)) v SN_NEXT
              (fun co Hc => proj1 (sn_offsets_ge ge co HC Hc)) eq_refl Hx)
    as (l & ofs & HA & Hld).
  destruct (gaddr_eval ge e le M pid (PTree.gempty _ _) A _ Ga HA) as (bp & o' & Hs & Eq). inv Eq.
  destruct (Hpart pid bp Hin Hs) as (Hvb & Hna).
  destruct HG as (c & U & Hd & Hn & Hc & Hl & HW).
  split.
  - exists c. split; [exact U |]. split; [rewrite PTree.gso by idne; exact Hd |].
    split; [rewrite PTree.gso by idne; exact Hn |]. auto.
  - exists v. split; [apply PTree.gss |].
    exists pid, bp, (Ptrofs.add o' (Ptrofs.repr SN_NEXT)). split; [exact Hin |]. split; [exact Hs |].
    cbn [Mem.loadv] in *. rewrite <- (UOF_ld _ _ _ _ U Hvb Hna). exact Hld.
Qed.

Lemma add_eval : forall le M v t3 c c1,
    le ! surface_collision._numCollisions = Some (Vint (Int.repr c)) ->
    le ! t3 = Some (Vint (Int.repr c1)) ->
    eval_expr ge e le M
      (Ebinop Oadd (Etempvar surface_collision._numCollisions tint) (Etempvar t3 tint) tint) v ->
    v = Vint (Int.repr (c + c1)).
Proof.
  intros le M v t3 c c1 Hn Ht H.
  inv H; [| match goal with Hl : eval_lvalue _ _ _ _ (Ebinop _ _ _ _) _ _ _ |- _ => inv Hl end].
  repeat match goal with Hx : eval_expr _ _ _ _ (Etempvar _ _) _ |- _ =>
    inv Hx; [| match goal with Hl : eval_lvalue _ _ _ _ (Etempvar _ _) _ _ _ |- _ => inv Hl end] end.
  rewrite Hn, Ht in *.
  repeat match goal with Hx : Some _ = Some _ |- _ => inv Hx end.
  match goal with Hs : sem_binary_operation _ _ _ _ _ _ _ = Some _ |- _ => rename Hs into Hsem end.
  cbn in Hsem. unfold sem_add, sem_binarith, sem_cast, classify_cast, Ctypesdefs.tint in Hsem.
  cbv [Archi.ptr64] in Hsem. cbn in Hsem.
  injection Hsem as <-. f_equal.
  apply Int.eqm_samerepr. apply Int.eqm_add; apply Int.eqm_sym; apply Int.eqm_unsigned_repr.
Qed.

(* the call of find_wall_collisions_from_list on the current list, and the sum *)
Lemma tri_wc : forall t3 R,
    t3 <> surface_collision._colData -> t3 <> surface_collision._numCollisions ->
    tri ge e GN
      (Ssequence
        (Scall (Some t3)
          (Evar surface_collision._find_wall_collisions_from_list
            (Tfunction (tptr (Tstruct surface_collision._SurfaceNode noattr) ::
                        tptr (Tstruct surface_collision._WallCollisionData noattr) :: nil) tint cc_default))
          (Etempvar surface_collision._node (tptr (Tstruct surface_collision._SurfaceNode noattr)) ::
           Etempvar surface_collision._colData (tptr (Tstruct surface_collision._WallCollisionData noattr)) :: nil))
        (Sset surface_collision._numCollisions
          (Ebinop Oadd (Etempvar surface_collision._numCollisions tint) (Etempvar t3 tint) tint)))
      Gx R.
Proof.
  intros t3 R N1 N2 le M t le' M' out (HG & hd & Hh & Hph) H.
  inv H;
    [| match goal with Hs : exec_stmt _ _ _ _ _ (Scall _ _ _) _ _ _ _ |- _ =>
         destruct (wfl_call _ _ _ _ _ _ _ _ _ _ _ _ Hpin Hs) as (? & ? & ? & _ & Ho & _); congruence end].
  match goal with Hs : exec_stmt _ _ _ _ _ (Scall _ _ _) _ _ _ _ |- _ =>
    destruct (wfl_call _ _ _ _ _ _ _ _ _ _ _ _ Hpin Hs) as (vargs & vres & t' & Hargs & _ & -> & Hev) end.
  match goal with Hs : exec_stmt _ _ _ _ _ (Sset _ _) _ _ _ _ |- _ => inv Hs end.
  destruct HG as (c & U & Hd & Hn & Hc & Hl & HW).
  (* the arguments *)
  inv Hargs.
  match goal with Ht : eval_expr _ _ _ _ (Etempvar surface_collision._node _) _ |- _ =>
    inv Ht; [| match goal with Hl0 : eval_lvalue _ _ _ _ (Etempvar _ _) _ _ _ |- _ => inv Hl0 end] end.
  match goal with Hcs : sem_cast _ (typeof (Etempvar surface_collision._node _)) _ _ = Some _ |- _ =>
    cbn [typeof] in Hcs; apply cast_ptr_same in Hcs; subst end.
  match goal with Hl2 : eval_exprlist _ _ _ _ (_ :: _) _ _ |- _ => inv Hl2 end.
  match goal with Ht : eval_expr _ _ _ _ (Etempvar surface_collision._colData _) _ |- _ =>
    inv Ht; [| match goal with Hl0 : eval_lvalue _ _ _ _ (Etempvar _ _) _ _ _ |- _ => inv Hl0 end] end.
  match goal with Hcs : sem_cast _ (typeof (Etempvar surface_collision._colData _)) _ _ = Some _ |- _ =>
    cbn [typeof] in Hcs; apply cast_ptr_same in Hcs; subst end.
  match goal with Hl2 : eval_exprlist _ _ _ _ nil _ _ |- _ => inv Hl2 end.
  rewrite Hh in *. rewrite Hd in *.
  repeat match goal with Hx : Some _ = Some _ |- _ => inv Hx end.
  try match goal with Hp : part_head ge m ?h |- _ => rename h into hd end.
  (* the callee's contract *)
  assert (Hw0 : wf_list M avoid hd) by exact (wf_to_M M hd U (Hwf hd Hph)).
  destruct (wfl_contract ge M avoid bd od hd (Z.min c 4) HC Hav Hro ltac:(lia) _ _ _ Hw0 Hl Hev)
    as (c1 & Hc1 & -> & (U1 & P1) & Hl1 & HW1).
  match goal with Hx : eval_expr _ _ ?L ?MM (Ebinop Oadd _ _ _) ?vv |- _ =>
    pose proof (add_eval L MM vv t3 c c1 ltac:(rewrite PTree.gso by congruence; exact Hn)
                  ltac:(apply PTree.gss) Hx) as -> end.
  left; split; [reflexivity |].
  assert (Hbd : Mem.valid_block M bd).
  { apply Mem.load_valid_access in Hl. eapply Mem.valid_access_valid_block.
    eapply Mem.valid_access_implies; [exact Hl | constructor]. }
  exists (c + c1).
  split; [split |].
  - eapply Mem.unchanged_on_trans; [exact (proj1 U) |].
    eapply Mem.unchanged_on_implies; [exact U1 |].
    intros b i (Hv & Hnw) HvM. split; [exact HvM |].
    intros (-> & Hr). apply Hnw. left. split; [reflexivity | unfold nwof in *; lia].
  - intros b i k p Hv. rewrite ((proj2 U) b i k p Hv). apply P1.
    eapply Mem.valid_block_unchanged_on; [exact (proj1 U) | exact Hv].
  - split; [rewrite PTree.gso by congruence; rewrite PTree.gso by congruence; exact Hd |].
    split; [apply PTree.gss |]. split; [lia |].
    split; [rewrite Hl1; unfold nwof; do 3 f_equal; lia |].
    destruct HW as (HW & HW2). destruct HW1 as (HW1 & HW12). split; cycle 1.
    { eapply Mem.unchanged_on_trans.
      - eapply Mem.unchanged_on_implies; [exact HW2 |]. intros b' i (-> & Hr) _. split; [reflexivity | lia].
      - eapply Mem.unchanged_on_implies; [exact HW12 |]. intros b' i (-> & Hr) _.
        split; [reflexivity | unfold nwof; lia]. }
    intros i Hi.
    destruct (Z_lt_ge_dec i (Z.min c 4)) as [Hlt | Hge].
    + destruct (HW i ltac:(lia)) as (s0 & Hls & Hws). exists s0. split; [| exact Hws].
      rewrite <- Hls. eapply Mem.load_unchanged_on_1; [exact U1 | exact Hbd |].
      intros j Hj. split; [exact Hbd |]. intros (_ & Hr). cbn [size_chunk] in Hj. lia.
    + destruct (HW1 i ltac:(unfold nwof; lia)) as (s0 & Hls & Hos). exists s0. split; [exact Hls |].
      exists hd. split; [exact Hph |].
      exact (on_list_back _ _ _ (Hwf hd Hph) _ _ (UOF_keep _ U) Hos).
Qed.

Lemma lv_calls_wall : forall le M b ofs bf,
    eval_lvalue ge e le M
      (Efield (Evar surface_collision._gNumCalls (Tstruct surface_collision._NumTimesCalled noattr))
         surface_collision._wall tshort) b ofs bf ->
    Genv.find_symbol ge surface_collision._gNumCalls = Some b
    /\ ofs = Ptrofs.add Ptrofs.zero (Ptrofs.repr 4) /\ bf = Full.
Proof.
  intros le M b ofs bf H. inv H; cbn [typeof] in *; try discriminate.
  match goal with Ha : eval_expr _ _ _ _ (Evar _ _) _ |- _ => inv Ha end.
  match goal with Hd : deref_loc _ _ _ _ _ _ |- _ => inv Hd end;
    cbn [access_mode] in *; try discriminate;
    [| match goal with Hb : load_bitfield _ _ _ _ _ _ _ _ |- _ => inv Hb end].
  match goal with Hl : eval_lvalue _ _ _ _ (Evar _ _) _ _ _ |- _ => inv Hl end;
    [rewrite PTree.gempty in *; discriminate |].
  match goal with Ht : Tstruct _ _ = Tstruct _ _ |- _ => injection Ht as <- _ end.
  match goal with Hc : (genv_cenv ge) ! _ = Some ?co, Hf : field_offset _ _ _ = OK _ |- _ =>
    rewrite (ntc_wall_ofs _ _ HC Hc) in Hf; injection Hf as <- <- end.
  auto.
Qed.

Lemma tri_calls : forall rhs R,
    tri ge e Gx
      (Sassign (Efield (Evar surface_collision._gNumCalls
                          (Tstruct surface_collision._NumTimesCalled noattr))
                  surface_collision._wall tshort) rhs) Gx R.
Proof.
  intros rhs R. apply tri_assign.
  intros le M b ofs bf v v' M' (c & U & Hd & Hn & Hc & Hl & HW) Hlv _ _ Ha.
  destruct (lv_calls_wall _ _ _ _ _ Hlv) as (Hs & -> & ->).
  destruct (Hcl _ Hs) as (_ & Hne).
  inv Ha; cbn [typeof access_mode] in *; try discriminate.
  match goal with Hm : access_mode tshort = By_value _ |- _ =>
    change (access_mode tshort) with (By_value Mint16signed) in Hm; injection Hm as <- end.
  cbn [Mem.storev] in *.
  match goal with Hst : Mem.store _ _ _ _ _ = Some _ |- _ => rename Hst into ST end.
  rewrite Ptrofs.add_zero_l, Ptrofs.unsigned_repr in ST by (unfold Ptrofs.max_unsigned; rewrite ptrofs_mod; lia).
  exists c. split; [| split; [exact Hd | split; [exact Hn | split; [exact Hc | split]]]].
  - apply (UOF_store _ _ _ _ _ _ U ST). intros i Hi. cbn [size_chunk] in Hi. right. auto.
  - rewrite (Mem.load_store_other _ _ _ _ _ _ ST) by (left; congruence). exact Hl.
  - destruct HW as (HW & HW2). split.
    + intros i Hi. destruct (HW i Hi) as (s0 & Hls & Hws). exists s0. split; [| exact Hws].
      rewrite (Mem.load_store_other _ _ _ _ _ _ ST) by (left; congruence). exact Hls.
    + eapply Mem.unchanged_on_trans; [exact HW2 |].
      eapply Mem.store_unchanged_on; [exact ST |]. intros i _ (Eb & _). exact (Hne Eb).
Qed.

Ltac solve_wf :=
  lazymatch goal with
  | |- tri _ _ _ (Ssequence (Scall _ _ _) (Sset _ _)) _ _ => eapply tri_wc; idne
  | |- tri _ _ _ (Ssequence _ _) _ _ => eapply tri_seq; [solve_wf | solve_wf]
  | |- tri _ _ _ (Sifthenelse _ _ _) _ _ => eapply tri_ite; [solve_wf | solve_wf]
  | |- tri _ _ _ Sskip _ _ => eapply tri_skip
  | |- tri _ _ Gx (Sreturn _) _ _ => eapply tri_ret; intros ? ? ?; assumption
  | |- tri _ _ P0 (Sset surface_collision._numCollisions _) _ _ => eapply tri_nc0
  | |- tri _ _ Gx (Sset surface_collision._node (Efield (Ederef ?A _) _ _)) _ _ =>
      let pid := wf_base A in eapply (tri_node pid); [wf_inlist | reflexivity]
  | |- tri _ _ P0 (Sset _ _) _ _ => eapply tri_set_P0; idne
  | |- tri _ _ P1 (Sset _ _) _ _ => eapply tri_set_P1; idne
  | |- tri _ _ Gx (Sset _ _) _ _ => eapply tri_set_Gx; idne
  | |- tri _ _ GN (Sset _ _) _ _ => eapply tri_set_GN; idne
  | |- tri _ _ P1 (Sassign _ _) _ _ => eapply tri_nw0
  | |- tri _ _ Gx (Sassign _ _) _ _ => eapply tri_calls
  end.

Lemma fwc_body_tri :
  tri ge e P0 (fn_body surface_collision.f_find_wall_collisions) (fun _ _ => False) Gx.
Proof. cbv [fn_body surface_collision.f_find_wall_collisions]. solve_wf. Qed.

Lemma pf_rd : forall tid le M fld v d,
    le ! tid = Some (Vptr bd od) ->
    field_offset ge fld wcd_members = OK (d, Full) -> 0 <= d < 40 ->
    eval_expr ge e le M (Efield (Ederef (Etempvar tid (tptr wcd_ty)) wcd_ty) fld tfloat) v ->
    Mem.load Mfloat32 M bd (o + d) = Some v.
Proof.
  intros tid le M fld v d Hd F Hr H.
  inv H. match goal with Hl : eval_lvalue _ _ _ _ _ _ _ _ |- _ =>
    destruct (pf_lv _ _ _ _ _ _ _ _ _ Hd F Hl) as (-> & -> & ->) end.
  match goal with Hx : deref_loc _ _ _ _ _ _ |- _ => inv Hx end; cbn [typeof] in *; try discriminate.
  match goal with Hm : access_mode tfloat = By_value _ |- _ =>
    change (access_mode tfloat) with (By_value Mfloat32) in Hm; injection Hm as <- end.
  cbn [Mem.loadv] in *. rewrite ofs_d' in * by lia. assumption.
Qed.

(* the body reads colData->x and colData->z from the entry memory, before
   anything can return *)
Lemma body_reads : forall le t le' M' out,
    le ! surface_collision._colData = Some (Vptr bd od) ->
    exec_stmt function_entry2 ge e le m (fn_body surface_collision.f_find_wall_collisions) t le' M' out ->
    (exists v, Mem.load Mfloat32 m bd o = Some v) /\ (exists v, Mem.load Mfloat32 m bd (o + 8) = Some v).
Proof.
  intros le t le' M' out Hd H.
  cbv [fn_body surface_collision.f_find_wall_collisions] in H.
  inv H; [| match goal with Hs : exec_stmt _ _ _ _ _ (Sset _ _) _ _ _ _ |- _ => inv Hs end; congruence].
  match goal with Hs : exec_stmt _ _ _ _ _ (Sset _ _) _ _ _ _ |- _ => inv Hs end.
  match goal with H2 : exec_stmt _ _ _ _ _ (Ssequence _ _) _ _ _ _ |- _ => inv H2 end.
  - (* x read normally; then z *)
    match goal with H3 : exec_stmt _ _ _ _ _ (Ssequence (Sset surface_collision._t'7 _) _) _ _ _ _ |- _ =>
      inv H3 end;
      [| match goal with Hs : exec_stmt _ _ _ _ _ (Sset surface_collision._t'7 _) _ _ _ _ |- _ => inv Hs end; congruence].
    match goal with Hs : exec_stmt _ _ _ _ _ (Sset surface_collision._t'7 _) _ _ _ _ |- _ => inv Hs end.
    match goal with Hs : exec_stmt _ _ _ _ _ (Sset surface_collision._x _) _ _ _ _ |- _ => inv Hs end.
    split.
    + match goal with Hx : eval_expr _ _ _ _ (Efield _ surface_collision._x _) ?v |- _ =>
        rename Hx into HX end.
      eexists. rewrite <- (Z.add_0_r (Ptrofs.unsigned od)).
      refine (pf_rd _ _ _ surface_collision._x _ 0 _ eq_refl _ HX).
      * rewrite PTree.gso by idne; exact Hd.
      * lia.
    + match goal with H4 : exec_stmt _ _ _ _ _ (Ssequence (Ssequence (Sset surface_collision._t'6 _) _) _) _ _ _ _ |- _ =>
        inv H4 end;
      match goal with H5 : exec_stmt _ _ _ _ _ (Ssequence (Sset surface_collision._t'6 _) _) _ _ _ _ |- _ =>
        inv H5 end;
      match goal with Hs : exec_stmt _ _ _ _ _ (Sset surface_collision._t'6 _) _ _ _ _ |- _ => inv Hs end;
      match goal with Hx : eval_expr _ _ _ _ (Efield _ surface_collision._z _) ?v |- _ =>
        exists v; refine (pf_rd _ _ _ surface_collision._z _ 8 _ eq_refl _ Hx);
        [repeat rewrite PTree.gso by idne; exact Hd | lia] end.
  - match goal with H3 : exec_stmt _ _ _ _ _ (Ssequence (Sset surface_collision._t'7 _) _) _ _ _ _ |- _ =>
      inv H3 end;
      match goal with Hs : exec_stmt _ _ _ _ _ (Sset surface_collision._t'7 _) _ _ _ _ |- _ => inv Hs end;
      [match goal with Hs : exec_stmt _ _ _ _ _ (Sset surface_collision._x _) _ _ _ _ |- _ => inv Hs end;
       congruence | congruence].
Qed.

Theorem fwc_contract : forall t m' vres,
    eval_funcall function_entry2 ge m (Internal surface_collision.f_find_wall_collisions)
      [Vptr bd od] t m' vres ->
    exists c, 0 <= c /\ vres = Vint (Int.repr c) /\ UOF m'
      /\ Mem.load Mint16signed m' bd (o + 22) = Some (Vint (Int.repr (Z.min c 4)))
      /\ WSi (Z.min c 4) m'
      /\ (exists v, Mem.load Mfloat32 m bd o = Some v) /\ (exists v, Mem.load Mfloat32 m bd (o + 8) = Some v).
Proof.
  intros t m' vres H. inv H.
  match goal with He : function_entry2 _ _ _ _ _ _ _ |- _ => inv He end.
  match goal with Ha : alloc_variables _ _ _ _ _ _ |- _ =>
    cbn [surface_collision.f_find_wall_collisions fn_vars] in Ha; inv Ha end.
  match goal with Hb : bind_parameter_temps _ _ _ = Some _ |- _ =>
    cbn [bind_parameter_temps surface_collision.f_find_wall_collisions fn_params] in Hb;
    injection Hb as <- end.
  match goal with Hx : exec_stmt _ _ _ _ _ _ _ _ _ _ |- _ => rename Hx into HB end.
  assert (HP : P0 (PTree.set surface_collision._colData (Vptr bd od)
                     (create_undef_temps (fn_temps surface_collision.f_find_wall_collisions))) m)
    by (split; [reflexivity | apply PTree.gss]).
  destruct (body_reads _ _ _ _ _ (PTree.gss _ _ _) HB) as (RX & RZ).
  destruct (fwc_body_tri _ _ _ _ _ _ HP HB) as [(_ & F) | (Hno & (c & U & Hd & Hn & Hc & Hl & HW))];
    [destruct F |].
  destruct (rx_out _ _ _ _ _ _ _ _ _ surface_collision._numCollisions HB eq_refl)
    as [-> | (v & -> & Hv)]; [congruence |].
  rewrite Hn in Hv. injection Hv as <-.
  match goal with Hf : Mem.free_list _ _ = Some _ |- _ =>
    cbn [blocks_of_env PTree.elements Mem.free_list] in Hf; injection Hf as <- end.
  match goal with Ho : outcome_result_value _ _ _ _ |- _ =>
    cbn [fn_return surface_collision.f_find_wall_collisions] in Ho; destruct Ho as (_ & Hcs) end.
  unfold sem_cast, classify_cast, Ctypesdefs.tint in Hcs; cbv [Archi.ptr64] in Hcs; cbn in Hcs.
  injection Hcs as <-.
  exists c. split; [exact Hc | split; [reflexivity | split; [exact U | split; [exact Hl |
    split; [exact HW | split; [exact RX | exact RZ]]]]]].
Qed.

End WF.

