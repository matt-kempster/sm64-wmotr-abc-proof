(* ====================================================================== *)
(* WallList (unwired, GOAL 2): the VALUE contract of the real              *)
(* find_wall_collisions_from_list (surface_collision.c), proved from its   *)
(* generated Clight body.                                                  *)
(*                                                                          *)
(* The loop walks a SurfaceNode list and, for each wall it collides with,  *)
(* pushes data->x / data->z, records the wall in data->walls if fewer than *)
(* four are recorded, and counts it.  The contract: for some count c >= 0, *)
(*   - the result is c;                                                     *)
(*   - numWalls becomes min(nw0 + c, 4) (nw0 = its entry value);           *)
(*   - every newly recorded wall is a surface read off the list;           *)
(*   - nothing else changes but data->x, data->z, numWalls and the walls   *)
(*     slots from nw0 on.                                                  *)
(* ====================================================================== *)

From Coq Require Import ZArith List Lia.
From compcert Require Import Coqlib Errors Maps AST Integers Floats Values Memory Events
  Globalenvs Ctypes Cop Clightdefs Clight ClightBigstep.
From SM64.Generated Require surface_collision.
From SM64.Proofs Require Import WMotRRequiresA.Unwired.FloorList.
Import ListNotations.

Local Notation SC := surface_collision.prog.

Definition wcd_ty : type := Tstruct surface_collision._WallCollisionData noattr.

Definition wcd_members : members :=
  [Member_plain surface_collision._x tfloat; Member_plain surface_collision._y tfloat;
   Member_plain surface_collision._z tfloat; Member_plain surface_collision._offsetY tfloat;
   Member_plain surface_collision._radius tfloat;
   Member_plain surface_collision._filler (tarray tuchar 2);
   Member_plain surface_collision._numWalls tshort;
   Member_plain surface_collision._walls (tarray (tptr (Tstruct surface_collision._Surface noattr)) 4)].

Lemma wcd_members_eq :
    match (prog_comp_env SC) ! surface_collision._WallCollisionData with
    | Some co => co_members co | None => nil end = wcd_members.
Proof. vm_compute. reflexivity. Qed.

(* the WallCollisionData offsets, in any genv that has the TU's composites *)
Lemma wcd_ofs : forall (ge : genv) co fld d,
    cenv_has ge -> (genv_cenv ge) ! surface_collision._WallCollisionData = Some co ->
    field_offset ge fld wcd_members = OK (d, Full) ->
    field_offset ge fld (co_members co) = OK (d, Full).
Proof.
  intros ge co fld d HC H F. pose proof wcd_members_eq as M.
  destruct ((prog_comp_env SC) ! surface_collision._WallCollisionData) as [co0|] eqn:E0;
    [| discriminate M].
  rewrite (HC _ _ E0) in H. injection H as <-. rewrite M. exact F.
Qed.

Lemma load_result_32 : forall M b z s, Mem.load Mint32 M b z = Some s ->
  Val.load_result Mint32 s = s.
Proof.
  intros M b z s H. apply Mem.load_type in H.
  destruct s; cbn in H |- *; try contradiction; reflexivity.
Qed.

(* statements whose executions end normally or by continue *)
Fixpoint nbr_chk (s : statement) : bool :=
  match s with
  | Sskip | Sset _ _ | Sassign _ _ | Scontinue => true
  | Ssequence s1 s2 => nbr_chk s1 && nbr_chk s2
  | Sifthenelse _ s1 s2 => nbr_chk s1 && nbr_chk s2
  | _ => false
  end.

Lemma nbr_out : forall (ge : genv) e le m s t le' m' out,
  exec_stmt function_entry2 ge e le m s t le' m' out -> nbr_chk s = true ->
  out = Out_normal \/ out = Out_continue.
Proof.
  intros ge e le m s t le' m' out H.
  induction H; intros Hc; cbn [nbr_chk] in Hc; try discriminate Hc; auto;
    repeat match goal with Hx : _ && _ = true |- _ => apply andb_prop in Hx as [? ?] end; auto.
  destruct b; auto.
Qed.

Section WL.
Variable ge : genv.
Variable m : mem.
Variable avoid : block -> Prop.
Variable bd : block.
Variable od : ptrofs.
Variable node0 : val.
Variable nw0 : Z.
Hypothesis HC : cenv_has ge.
Hypothesis Hav : avoid bd.
Hypothesis Hro : Ptrofs.unsigned od + 40 <= Ptrofs.modulus.
Hypothesis Hnw0 : 0 <= nw0 <= 4.

Local Notation o := (Ptrofs.unsigned od).
Local Notation e := empty_env.

(* the cells the loop may write *)
Definition ww (b : block) (i : Z) : Prop :=
  b = bd /\ (o <= i < o + 4 \/ o + 8 <= i < o + 12 \/ o + 22 <= i < o + 24
             \/ o + 24 + 4 * nw0 <= i < o + 40).

Definition keptw (b : block) (i : Z) : Prop := Mem.valid_block m b /\ ~ ww b i.

Definition UOw (M : mem) : Prop :=
  Mem.unchanged_on keptw m M
  /\ (forall b i k p, Mem.valid_block m b -> (Mem.perm m b i k p <-> Mem.perm M b i k p)).

Definition nwof (c : Z) : Z := Z.min (nw0 + c) 4.

Definition WW (n : Z) (M : mem) : Prop :=
  forall i, nw0 <= i < n -> exists s, Mem.load Mint32 M bd (o + 24 + 4 * i) = Some s
    /\ on_list m node0 s.

Definition J (c : Z) (le : temp_env) (M : mem) : Prop :=
  UOw M
  /\ le ! surface_collision._data = Some (Vptr bd od)
  /\ le ! surface_collision._numCols = Some (Vint (Int.repr c)) /\ 0 <= c
  /\ Mem.load Mint16signed M bd (o + 22) = Some (Vint (Int.repr (nwof c)))
  /\ WW (nwof c) M
  /\ exists nd, le ! surface_collision._surfaceNode = Some nd /\ wf_list m avoid nd
       /\ (forall s, on_list m nd s -> on_list m node0 s).

Definition Jx (le : temp_env) (M : mem) : Prop := exists c, J c le M.

(* mid-body: J, plus the current surface (off the list) *)
Definition K (c : Z) (le : temp_env) (M : mem) : Prop :=
  J c le M /\ exists s, le ! surface_collision._surf = Some s /\ on_list m node0 s
    /\ Val.load_result Mint32 s = s.

Definition untrw (x : ident) : Prop :=
  x <> surface_collision._data /\ x <> surface_collision._numCols
  /\ x <> surface_collision._surfaceNode /\ x <> surface_collision._surf.

Lemma K_set : forall c le M x v, K c le M -> untrw x -> K c (PTree.set x v le) M.
Proof.
  intros c le M x v ((U & Hd & Hn & Hc & Hl & HW & nd & Hnd & Hw & Hr) & s & Hs & Ho & Hlr)
    (N1 & N2 & N3 & N4).
  split; [split; [exact U |] |].
  - split; [rewrite PTree.gso by congruence; exact Hd |].
    split; [rewrite PTree.gso by congruence; exact Hn |].
    split; [exact Hc | split; [exact Hl | split; [exact HW |]]].
    exists nd. rewrite PTree.gso by congruence. auto.
  - exists s. rewrite PTree.gso by congruence. auto.
Qed.

Lemma tri_set_w : forall c x a R, untrw x -> tri ge e (K c) (Sset x a) (K c) R.
Proof. intros c x a R Hx. apply tri_set. intros le M v HK _. exact (K_set c le M x v HK Hx). Qed.

Lemma tri_cont : forall (P Q R : temp_env -> mem -> Prop),
    (forall le M, P le M -> R le M) -> tri ge e P Scontinue Q R.
Proof. intros P Q R PR le M t le' M' out HP H. inv H. right; split; [discriminate | auto]. Qed.

(* ---- reading and writing fields of *data ---- *)

Lemma data_lv : forall le M fld ty b ofs bf d,
    le ! surface_collision._data = Some (Vptr bd od) ->
    field_offset ge fld wcd_members = OK (d, Full) ->
    eval_lvalue ge e le M
      (Efield (Ederef (Etempvar surface_collision._data (tptr wcd_ty)) wcd_ty) fld ty) b ofs bf ->
    b = bd /\ ofs = Ptrofs.add od (Ptrofs.repr d) /\ bf = Full.
Proof.
  intros le M fld ty b ofs bf d Hd F H.
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

Lemma data_rd : forall le M fld ty v d ch,
    le ! surface_collision._data = Some (Vptr bd od) ->
    field_offset ge fld wcd_members = OK (d, Full) ->
    access_mode ty = By_value ch ->
    eval_expr ge e le M
      (Efield (Ederef (Etempvar surface_collision._data (tptr wcd_ty)) wcd_ty) fld ty) v ->
    Mem.load ch M bd (Ptrofs.unsigned (Ptrofs.add od (Ptrofs.repr d))) = Some v.
Proof.
  intros le M fld ty v d ch Hd F Ham H.
  inv H. match goal with Hl : eval_lvalue _ _ _ _ _ _ _ _ |- _ =>
    destruct (data_lv _ _ _ _ _ _ _ _ Hd F Hl) as (-> & -> & ->) end.
  match goal with Hx : deref_loc _ _ _ _ _ _ |- _ => inv Hx end; cbn [typeof] in *; try congruence.
  match goal with Hl : Mem.loadv ?c _ _ = Some _ |- _ =>
    assert (Ec : c = ch) by congruence; subst c; exact Hl end.
Qed.

Lemma ptrofs_mod : Ptrofs.modulus = 4294967296.
Proof. reflexivity. Qed.

Lemma ofs_d : forall d, 0 <= d < 40 -> Ptrofs.unsigned (Ptrofs.add od (Ptrofs.repr d)) = o + d.
Proof.
  intros d Hd. pose proof (Ptrofs.unsigned_range od). pose proof ptrofs_mod.
  rewrite Ptrofs.add_unsigned, (Ptrofs.unsigned_repr d) by (unfold Ptrofs.max_unsigned; lia).
  apply Ptrofs.unsigned_repr. unfold Ptrofs.max_unsigned. lia.
Qed.

(* a store into written cells only *)
Lemma UOw_store : forall M M' ch ofs v,
    UOw M -> Mem.store ch M bd ofs v = Some M' ->
    (forall i, ofs <= i < ofs + size_chunk ch -> ww bd i) -> UOw M'.
Proof.
  intros M M' ch ofs v (U & P) Hs Hb. split.
  - eapply Mem.unchanged_on_trans; [exact U |].
    eapply Mem.store_unchanged_on; [exact Hs |].
    intros i Hi (Hv & Hn). exact (Hn (Hb i Hi)).
  - intros b' i k p Hv. rewrite (P b' i k p Hv).
    split; intro HH; [eapply Mem.perm_store_1; eauto | eapply Mem.perm_store_2; eauto].
Qed.

(* the pushes: data->x (offset 0) and data->z (offset 8) *)
Lemma tri_push : forall c fld d rhs R,
    field_offset ge fld wcd_members = OK (d, Full) -> (d = 0 \/ d = 8) ->
    tri ge e (K c)
      (Sassign (Efield (Ederef (Etempvar surface_collision._data (tptr wcd_ty)) wcd_ty) fld tfloat) rhs)
      (K c) R.
Proof.
  intros c fld d rhs R F Hd. apply tri_assign.
  intros le M b ofs bf v v' M' ((U & Hdt & Hn & Hc & Hl & HW & Hcur) & Hs) Hlv _ _ Ha.
  destruct (data_lv _ _ _ _ _ _ _ _ Hdt F Hlv) as (-> & -> & ->).
  inv Ha; cbn [typeof access_mode] in *; try discriminate.
  match goal with Hm : access_mode tfloat = By_value _ |- _ => change (access_mode tfloat) with (By_value Mfloat32) in Hm; injection Hm as <- end.
  cbn [Mem.storev] in *. rewrite ofs_d in * by lia.
  match goal with Hst : Mem.store _ _ _ _ _ = Some _ |- _ => rename Hst into ST end.
  split; [split; [| split; [exact Hdt | split; [exact Hn | split; [exact Hc |]]]] | exact Hs].
  - apply (UOw_store _ _ _ _ _ U ST). intros i Hi. cbn in Hi. split; [reflexivity | lia].
  - split; [rewrite (Mem.load_store_other _ _ _ _ _ _ ST) by (right; right; cbn [size_chunk]; lia); exact Hl |].
    split; [| exact Hcur].
    intros i Hi. destruct (HW i Hi) as (s & Hls & Hos). exists s.
    rewrite (Mem.load_store_other _ _ _ _ _ _ ST) by (right; right; cbn [size_chunk]; unfold nwof in Hi; lia).
    auto.
Qed.

(* the body's pieces, cut out of the generated AST *)
Definition wl_loop : statement :=
  match fn_body surface_collision.f_find_wall_collisions_from_list with
  | Ssequence _ (Ssequence _ (Ssequence _ (Ssequence _ (Ssequence _ (Ssequence _ (Ssequence l _)))))) => l
  | _ => Sskip end.
Definition wl_s1 : statement := match wl_loop with Sloop s1 _ => s1 | _ => Sskip end.
Definition wl_body : statement := match wl_s1 with Ssequence _ b => b | _ => Sskip end.

Definition surf_ptr : type := tptr (Tstruct surface_collision._Surface noattr).
Definition dfld (fld : ident) (ty : type) : expr :=
  Efield (Ederef (Etempvar surface_collision._data (tptr wcd_ty)) wcd_ty) fld ty.

(* the record step: numWalls < 4 ? walls[numWalls++] = surf; numCols++ *)
Definition wl_tail : statement :=
  Ssequence
    (Ssequence
      (Sset surface_collision._t'7 (dfld surface_collision._numWalls tshort))
      (Sifthenelse (Ebinop Olt (Etempvar surface_collision._t'7 tshort) (Econst_int (Int.repr 4) tint) tint)
        (Ssequence
          (Ssequence
            (Sset surface_collision._t'6 (dfld surface_collision._numWalls tshort))
            (Sassign (dfld surface_collision._numWalls tshort)
              (Ebinop Oadd (Etempvar surface_collision._t'6 tshort) (Econst_int (Int.repr 1) tint) tint)))
          (Sassign
            (Ederef
              (Ebinop Oadd (dfld surface_collision._walls (tarray surf_ptr 4))
                (Etempvar surface_collision._t'6 tshort) (tptr surf_ptr)) surf_ptr)
            (Etempvar surface_collision._surf surf_ptr)))
        Sskip))
    (Sset surface_collision._numCols
      (Ebinop Oadd (Etempvar surface_collision._numCols tint) (Econst_int (Int.repr 1) tint) tint)).

Lemma k5 : forall k, 0 <= k <= 4 -> k = 0 \/ k = 1 \/ k = 2 \/ k = 3 \/ k = 4.
Proof. intros. lia. Qed.

Lemma guard_eval : forall le M v1 k b,
    le ! surface_collision._t'7 = Some (Vint (Int.repr k)) -> 0 <= k <= 4 ->
    eval_expr ge e le M
      (Ebinop Olt (Etempvar surface_collision._t'7 tshort) (Econst_int (Int.repr 4) tint) tint) v1 ->
    bool_val v1 tint M = Some b ->
    (b = true <-> k < 4).
Proof.
  intros le M v1 k b Ht Hk H Hb.
  inv H; [| match goal with Hl : eval_lvalue _ _ _ _ (Ebinop _ _ _ _) _ _ _ |- _ => inv Hl end].
  match goal with Ht7 : eval_expr _ _ _ _ (Etempvar _ _) _ |- _ =>
    inv Ht7; [| match goal with Hl : eval_lvalue _ _ _ _ (Etempvar _ _) _ _ _ |- _ => inv Hl end] end.
  match goal with Hk4 : eval_expr _ _ _ _ (Econst_int _ _) _ |- _ =>
    inv Hk4; [| match goal with Hl : eval_lvalue _ _ _ _ (Econst_int _ _) _ _ _ |- _ => inv Hl end] end.
  rewrite Ht in *. match goal with Hx : Some _ = Some _ |- _ => inv Hx end.
  match goal with Hs : sem_binary_operation _ _ _ _ _ _ _ = Some _ |- _ => rename Hs into Hsem end.
  destruct (k5 k Hk) as [-> | [-> | [-> | [-> | ->]]]];
    vm_compute in Hsem; injection Hsem as <-; vm_compute in Hb; injection Hb as <-;
    split; intros; first [reflexivity | lia | discriminate].
Qed.

Lemma incr_eval : forall le M v3 v4 k,
    le ! surface_collision._t'6 = Some (Vint (Int.repr k)) -> 0 <= k <= 3 ->
    eval_expr ge e le M
      (Ebinop Oadd (Etempvar surface_collision._t'6 tshort) (Econst_int (Int.repr 1) tint) tint) v3 ->
    sem_cast v3 tint tshort M = Some v4 ->
    v4 = Vint (Int.repr (k + 1)).
Proof.
  intros le M v3 v4 k Ht Hk H Hc.
  inv H; [| match goal with Hl : eval_lvalue _ _ _ _ (Ebinop _ _ _ _) _ _ _ |- _ => inv Hl end].
  match goal with Ht6 : eval_expr _ _ _ _ (Etempvar _ _) _ |- _ =>
    inv Ht6; [| match goal with Hl : eval_lvalue _ _ _ _ (Etempvar _ _) _ _ _ |- _ => inv Hl end] end.
  match goal with Hk4 : eval_expr _ _ _ _ (Econst_int _ _) _ |- _ =>
    inv Hk4; [| match goal with Hl : eval_lvalue _ _ _ _ (Econst_int _ _) _ _ _ |- _ => inv Hl end] end.
  rewrite Ht in *. match goal with Hx : Some _ = Some _ |- _ => inv Hx end.
  match goal with Hs : sem_binary_operation _ _ _ _ _ _ _ = Some _ |- _ => rename Hs into Hsem end.
  assert (k = 0 \/ k = 1 \/ k = 2 \/ k = 3) as Hk' by lia.
  destruct Hk' as [-> | [-> | [-> | ->]]];
    vm_compute in Hsem; injection Hsem as <-; vm_compute in Hc; injection Hc as <-; reflexivity.
Qed.

Lemma cols_eval : forall le M v0 c,
    le ! surface_collision._numCols = Some (Vint (Int.repr c)) ->
    eval_expr ge e le M
      (Ebinop Oadd (Etempvar surface_collision._numCols tint) (Econst_int (Int.repr 1) tint) tint) v0 ->
    v0 = Vint (Int.repr (c + 1)).
Proof.
  intros le M v0 c Ht H.
  inv H; [| match goal with Hl : eval_lvalue _ _ _ _ (Ebinop _ _ _ _) _ _ _ |- _ => inv Hl end].
  match goal with Ht6 : eval_expr _ _ _ _ (Etempvar _ _) _ |- _ =>
    inv Ht6; [| match goal with Hl : eval_lvalue _ _ _ _ (Etempvar _ _) _ _ _ |- _ => inv Hl end] end.
  match goal with Hk4 : eval_expr _ _ _ _ (Econst_int _ _) _ |- _ =>
    inv Hk4; [| match goal with Hl : eval_lvalue _ _ _ _ (Econst_int _ _) _ _ _ |- _ => inv Hl end] end.
  rewrite Ht in *. match goal with Hx : Some _ = Some _ |- _ => inv Hx end.
  match goal with Hs : sem_binary_operation _ _ _ _ _ _ _ = Some _ |- _ => rename Hs into Hsem end.
  cbn in Hsem. unfold sem_add, sem_binarith, sem_cast, classify_cast, Ctypesdefs.tint in Hsem. cbv [Archi.ptr64] in Hsem. cbn in Hsem.
  injection Hsem as <-. f_equal.
  apply Int.eqm_samerepr. apply Int.eqm_add; [apply Int.eqm_sym; apply Int.eqm_unsigned_repr |].
  apply Int.eqm_sym; apply Int.eqm_unsigned_repr.
Qed.

Lemma walls_lv : forall le M loc ofs bf k,
    le ! surface_collision._data = Some (Vptr bd od) ->
    le ! surface_collision._t'6 = Some (Vint (Int.repr k)) -> 0 <= k <= 3 ->
    eval_lvalue ge e le M
      (Ederef
        (Ebinop Oadd (dfld surface_collision._walls (tarray surf_ptr 4))
          (Etempvar surface_collision._t'6 tshort) (tptr surf_ptr)) surf_ptr) loc ofs bf ->
    loc = bd /\ Ptrofs.unsigned ofs = o + 24 + 4 * k /\ bf = Full.
Proof.
  intros le M loc ofs bf k Hd Ht Hk H.
  inv H.
  match goal with Ha : eval_expr _ _ _ _ (Ebinop _ _ _ _) _ |- _ =>
    inv Ha; [| match goal with Hl : eval_lvalue _ _ _ _ (Ebinop _ _ _ _) _ _ _ |- _ => inv Hl end] end.
  match goal with Ht6 : eval_expr _ _ _ _ (Etempvar _ _) _ |- _ =>
    inv Ht6; [| match goal with Hl : eval_lvalue _ _ _ _ (Etempvar _ _) _ _ _ |- _ => inv Hl end] end.
  rewrite Ht in *. match goal with Hx : Some _ = Some _ |- _ => inv Hx end.
  match goal with Hw : eval_expr _ _ _ _ (dfld _ _) _ |- _ =>
    unfold dfld in Hw; inv Hw; match goal with Hl : eval_lvalue _ _ _ _ (Efield _ _ _) _ _ _ |- _ =>
      destruct (data_lv _ _ surface_collision._walls _ _ _ _ 24 Hd eq_refl Hl) as (-> & -> & ->) end end.
  match goal with Hx : deref_loc _ _ _ _ _ _ |- _ => inv Hx end; cbn [typeof dfld access_mode] in *;
    try discriminate.
  match goal with Hs : sem_binary_operation _ _ _ _ _ _ _ = Some _ |- _ => rename Hs into Hsem end.
  cbn [sem_binary_operation typeof dfld] in Hsem. unfold sem_add in Hsem. cbn in Hsem.
  injection Hsem as <- <-. cbv [Archi.ptr64]. split; [reflexivity | split; [| reflexivity]].
  rewrite Ptrofs.add_assoc.
  assert (Hc : Ptrofs.add (Ptrofs.repr 24) (Ptrofs.mul (Ptrofs.repr 4) (Ptrofs.of_ints (Int.repr k)))
               = Ptrofs.repr (24 + 4 * k)).
  { assert (k = 0 \/ k = 1 \/ k = 2 \/ k = 3) as Hk' by lia.
    destruct Hk' as [-> | [-> | [-> | ->]]]; reflexivity. }
  rewrite Hc, ofs_d by lia. lia.
Qed.

Lemma tri_tail : forall c R, tri ge e (K c) wl_tail (J (c + 1)) R.
Proof.
  intros c R le M t le' M' out HK H.
  pose proof HK as ((U & Hdt & Hn & Hc & Hl & HW & Hcur) & s & Hs & Hos & Hlr).
  assert (Hk0 : nw0 <= nwof c <= 4) by (unfold nwof; lia).
  unfold wl_tail in H. xinv.
  - (* numWalls < 4: record the wall *)
    left; split; [reflexivity |].
    (* t'7 := numWalls; the guard *)
    match goal with H7 : eval_expr _ _ le ?MM (dfld surface_collision._numWalls tshort) ?v |- _ =>
      pose proof (data_rd le MM surface_collision._numWalls tshort v 22 Mint16signed Hdt eq_refl eq_refl H7)
        as L7 end.
    rewrite ofs_d in L7 by lia. rewrite Hl in L7. injection L7 as <-.
    match goal with Hg : eval_expr _ _ _ _ (Ebinop Olt _ _ _) ?v1, Hb : bool_val ?v1 _ _ = Some ?b |- _ =>
      pose proof (guard_eval _ _ _ (nwof c) b ltac:(apply PTree.gss) ltac:(lia) Hg Hb) as G end.

    destruct G as (G & _). specialize (G eq_refl).
    set (k := nwof c) in *.
    assert (Ek : k = nw0 + c) by (unfold k, nwof in *; lia).
    match goal with H6 : eval_expr _ _ ?L ?MM (dfld surface_collision._numWalls tshort) ?v |- _ =>
      assert (Hd1 : L ! surface_collision._data = Some (Vptr bd od)) by (ptg; exact Hdt);
      pose proof (data_rd L MM surface_collision._numWalls tshort v 22 Mint16signed Hd1 eq_refl eq_refl H6)
        as L6; rewrite ofs_d in L6 by lia; rewrite Hl in L6; injection L6 as <- end.
    match goal with Hl1 : eval_lvalue _ _ ?L ?MM (dfld surface_collision._numWalls tshort) _ _ _ |- _ =>
      assert (Hd2 : L ! surface_collision._data = Some (Vptr bd od)) by (ptg; exact Hdt);
      destruct (data_lv L MM surface_collision._numWalls tshort _ _ _ 22 Hd2 eq_refl Hl1) as (-> & -> & ->) end.
    match goal with Hi : eval_expr _ _ ?L ?MM (Ebinop Oadd (Etempvar surface_collision._t'6 _) _ _) ?v3,
                    Hcst : sem_cast ?v3 _ _ _ = Some ?v4 |- _ =>
      pose proof (incr_eval L MM v3 v4 k ltac:(ptg; reflexivity) ltac:(lia) Hi Hcst) as -> end.
    match goal with Ha : assign_loc _ (typeof (dfld surface_collision._numWalls tshort)) _ _ _ _ _ _ |- _ =>
      inv Ha; cbn [typeof dfld access_mode] in *; try discriminate end.
    match goal with Hm : access_mode tshort = By_value _ |- _ =>
      change (access_mode tshort) with (By_value Mint16signed) in Hm; injection Hm as <- end.
    match goal with Hst : Mem.storev _ _ _ _ = Some _ |- _ =>
      cbn [Mem.storev] in Hst; rewrite ofs_d in Hst by lia; rename Hst into ST1 end.
    match goal with Hl2 : eval_lvalue _ _ ?L ?MM (Ederef _ _) _ _ _ |- _ =>
      destruct (walls_lv L MM _ _ _ k Hd2 ltac:(ptg; reflexivity) ltac:(lia) Hl2) as (-> & Eo & ->) end.
    match goal with Hsv : eval_expr _ _ _ _ (Etempvar surface_collision._surf _) _ |- _ =>
      inv Hsv; [| match goal with Hl3 : eval_lvalue _ _ _ _ (Etempvar _ _) _ _ _ |- _ => inv Hl3 end] end.
    match goal with Hx : (PTree.set _ _ _) ! surface_collision._surf = Some _ |- _ =>
      progress (repeat rewrite PTree.gso in Hx by idne); rewrite Hs in Hx; injection Hx as <- end.
    match goal with Hcst : sem_cast s _ _ _ = Some _ |- _ => apply cast_ptr_same in Hcst; subst end.
    match goal with Ha : assign_loc _ _ _ _ _ _ _ _ |- _ =>
      inv Ha; cbn [typeof dfld access_mode surf_ptr] in *; try discriminate end.
    match goal with Hm : access_mode _ = By_value _ |- _ =>
      change (access_mode (tptr (Tstruct surface_collision._Surface noattr))) with (By_value Mint32) in Hm;
      injection Hm as <- end.
    match goal with Hst : Mem.storev _ _ _ _ = Some _ |- _ =>
      cbn [Mem.storev] in Hst; rewrite Eo in Hst; rename Hst into ST2 end.
    change Mptr with Mint32 in ST2.
    match goal with Hcl : eval_expr _ _ ?L _ (Ebinop Oadd (Etempvar surface_collision._numCols _) _ _) _ |- _ =>
      pose proof (cols_eval L _ _ c ltac:(ptg; exact Hn) Hcl) as -> end.
    assert (Enw : nwof (c + 1) = k + 1) by (unfold nwof; lia).
    split; [| split; [ptg; exact Hdt | split; [ptg; reflexivity | split; [lia | split; [| split]]]]].
    + apply (UOw_store _ _ _ _ _ (UOw_store _ _ _ _ _ U ST1 ltac:(intros i Hi; cbn [size_chunk] in Hi; split; [reflexivity | lia])) ST2).
      intros i Hi. cbn [size_chunk] in Hi. split; [reflexivity | lia].
    + rewrite Enw. rewrite (Mem.load_store_other _ _ _ _ _ _ ST2) by (right; left; cbn [size_chunk]; lia).
      rewrite (Mem.load_store_same _ _ _ _ _ _ ST1).
      assert (k = 0 \/ k = 1 \/ k = 2 \/ k = 3) as Hk' by lia.
      destruct Hk' as [-> | [-> | [-> | ->]]]; reflexivity.
    + rewrite Enw. intros i Hi.
      destruct (Z.eq_dec i k) as [-> | Hne].
      * exists s. split; [| exact Hos].
        rewrite (Mem.load_store_same _ _ _ _ _ _ ST2). rewrite Hlr. reflexivity.
      * destruct (HW i ltac:(lia)) as (s' & Hls & Hos'). exists s'. split; [| exact Hos'].
        rewrite (Mem.load_store_other _ _ _ _ _ _ ST2) by (right; cbn [size_chunk];
          destruct (Z_lt_ge_dec i k); [left; lia | right; lia]).
        rewrite (Mem.load_store_other _ _ _ _ _ _ ST1) by (right; right; cbn [size_chunk]; lia).
        exact Hls.
    + destruct Hcur as (nd & Hnd & Hw & Hr). exists nd. split; [ptg; exact Hnd | auto].
  - (* numWalls = 4: count only *)
    left; split; [reflexivity |].
    (* t'7 := numWalls; the guard *)
    match goal with H7 : eval_expr _ _ le ?MM (dfld surface_collision._numWalls tshort) ?v |- _ =>
      pose proof (data_rd le MM surface_collision._numWalls tshort v 22 Mint16signed Hdt eq_refl eq_refl H7)
        as L7 end.
    rewrite ofs_d in L7 by lia. rewrite Hl in L7. injection L7 as <-.
    match goal with Hg : eval_expr _ _ _ _ (Ebinop Olt _ _ _) ?v1, Hb : bool_val ?v1 _ _ = Some ?b |- _ =>
      pose proof (guard_eval _ _ _ (nwof c) b ltac:(apply PTree.gss) ltac:(lia) Hg Hb) as G end.
    destruct G as (_ & G).
    assert (E4 : nwof c = 4) by (destruct (Z_lt_ge_dec (nwof c) 4) as [Hlt | ]; [specialize (G Hlt); discriminate | lia]).
    match goal with Hcl : eval_expr _ _ ?L _ (Ebinop Oadd (Etempvar surface_collision._numCols _) _ _) _ |- _ =>
      pose proof (cols_eval L _ _ c ltac:(ptg; exact Hn) Hcl) as -> end.
    assert (Enw : nwof (c + 1) = nwof c) by (unfold nwof in *; lia).
    split; [exact U |]. split; [ptg; exact Hdt |]. split; [ptg; reflexivity |].
    split; [lia |]. rewrite Enw. split; [exact Hl | split; [exact HW |]].
    destruct Hcur as (nd & Hnd & Hw & Hr). exists nd. split; [ptg; exact Hnd | auto].
Qed.

(* the loop body's head: surf = node->surface; node = node->next *)
Lemma tri_head : forall c REST Q R,
    tri ge e (K c) REST Q R ->
    tri ge e (J c)
      (Ssequence
        (Sset surface_collision._surf
          (Efield (Ederef (Etempvar surface_collision._surfaceNode (tptr sn_ty)) sn_ty)
             surface_collision._surface surf_pty))
        (Ssequence
          (Sset surface_collision._surfaceNode
            (Efield (Ederef (Etempvar surface_collision._surfaceNode (tptr sn_ty)) sn_ty)
               surface_collision._next (tptr sn_ty)))
          REST)) Q R.
Proof.
  intros c REST Q R T le M t le' M' out HJ H.
  pose proof HJ as (U & Hdt & Hn & Hc & Hl & HW & nd & Hnd & Hw & Hr).
  inv H; [| match goal with Hs : exec_stmt _ _ _ _ _ (Sset _ _) _ _ _ _ |- _ => inv Hs end; congruence].
  match goal with Hs : exec_stmt _ _ _ _ _ (Sset _ _) _ _ _ _ |- _ => inv Hs end.
  match goal with H2 : exec_stmt _ _ _ _ _ (Ssequence _ _) _ _ _ _ |- _ => inv H2 end;
    [| match goal with Hs : exec_stmt _ _ _ _ _ (Sset _ _) _ _ _ _ |- _ => inv Hs end; congruence].
  match goal with Hs : exec_stmt _ _ _ _ _ (Sset _ _) _ _ _ _ |- _ => inv Hs end.
  match goal with Hx : eval_expr _ _ le _ (Efield _ surface_collision._surface _) ?v |- _ =>
    destruct (sn_surf _ _ _ _ _ _ HC Hnd Hx) as (bn & on & -> & Ls) end.
  inversion Hw as [| bn' on' nx Hv Hna Hnx Hw']; subst bn' on'.
  assert (Hbn : bn <> bd) by (intros ->; exact (Hna Hav)).
  assert (LM : forall MM z ch, UOw MM -> Mem.load ch MM bn z = Mem.load ch m bn z).
  { intros MM z ch UU. eapply Mem.load_unchanged_on_1; [exact (proj1 UU) | exact Hv |].
    intros i _. split; [exact Hv |]. intros (Eb & _). exact (Hbn Eb). }
  cbn [Mem.loadv] in Ls, Hnx. rewrite (LM _ _ _ U) in Ls.
  match goal with Hx : eval_expr _ _ ?L _ (Efield _ surface_collision._next _) ?v |- _ =>
    assert (Hnd' : L ! surface_collision._surfaceNode = Some (Vptr bn on)) by (ptg; exact Hnd);
    destruct (sn_next _ _ _ _ _ _ HC Hnd' Hx) as (bn' & on' & Eb & Ln); injection Eb as <- <- end.
  cbn [Mem.loadv] in Ln. rewrite (LM _ _ _ U), Hnx in Ln. injection Ln as <-.
  eapply T; [| eassumption].
  split; [split; [exact U |] |].
  - split; [ptg; exact Hdt |]. split; [ptg; exact Hn |]. split; [exact Hc |].
    split; [exact Hl | split; [exact HW |]].
    exists nx. split; [ptg; reflexivity |]. split; [exact Hw' |].
    intros s Hs. apply Hr. eapply ol_next; [cbn [Mem.loadv]; exact Hnx | exact Hs].
  - eexists. split; [ptg; reflexivity |].
    split; [apply Hr; apply ol_here; cbn [Mem.loadv]; exact Ls |].
    exact (load_result_32 _ _ _ _ Ls).
Qed.

Lemma J_set : forall c le M x v, J c le M -> untrw x -> J c (PTree.set x v le) M.
Proof.
  intros c le M x v (U & Hd & Hn & Hc & Hl & HW & nd & Hnd & Hw & Hr) (N1 & N2 & N3 & N4).
  split; [exact U |].
  split; [rewrite PTree.gso by congruence; exact Hd |].
  split; [rewrite PTree.gso by congruence; exact Hn |].
  split; [exact Hc | split; [exact Hl | split; [exact HW |]]].
  exists nd. rewrite PTree.gso by congruence. auto.
Qed.

Lemma wl_body_nbr : nbr_chk wl_body = true.
Proof. vm_compute. reflexivity. Qed.

Ltac untrw_ok := split; [idne | split; [idne | split; idne]].

Ltac solve_w :=
  lazymatch goal with
  | |- tri _ _ _ (Ssequence (Ssequence (Sset surface_collision._t'7 _) _) _) _ _ =>
      eapply tri_tail
  | |- tri _ _ _ (Ssequence _ _) _ _ => eapply tri_seq; [solve_w | solve_w]
  | |- tri _ _ _ (Sifthenelse _ _ _) _ _ => eapply tri_ite; [solve_w | solve_w]
  | |- tri _ _ _ Sskip _ _ => eapply tri_skip
  | |- tri _ _ _ Scontinue _ _ =>
      eapply tri_cont; let HH := fresh in intros ? ? (HH & _); eexists; exact HH
  | |- tri _ _ _ (Sset _ _) _ _ => eapply tri_set_w; untrw_ok
  | |- tri _ _ _ (Sassign (Efield _ surface_collision._x _) _) _ _ =>
      eapply tri_push; [reflexivity | left; reflexivity]
  | |- tri _ _ _ (Sassign (Efield _ surface_collision._z _) _) _ _ =>
      eapply tri_push; [reflexivity | right; reflexivity]
  end.

Lemma wl_body_tri : forall c, tri ge e (J c) wl_body (J (c + 1)) Jx.
Proof.
  intros c. cbv [wl_body wl_s1 wl_loop fn_body surface_collision.f_find_wall_collisions_from_list Swhile].
  eapply tri_head. solve_w.
Qed.

(* the loop: each round keeps the invariant *)
Lemma wl_iter : forall le M t le1 M1 out1,
    exec_stmt function_entry2 ge e le M wl_s1 t le1 M1 out1 -> Jx le M ->
    Jx le1 M1 /\ (out1 = Out_normal \/ out1 = Out_continue \/ out1 = Out_break).
Proof.
  intros le M t le1 M1 out1 H (c & HJ).
  cbv [wl_s1] in H. change (match wl_loop with Sloop s1 _ => s1 | _ => Sskip end)
    with (Ssequence (Sifthenelse
      (Ebinop One (Etempvar surface_collision._surfaceNode (tptr sn_ty))
         (Ecast (Econst_int (Int.repr 0) tint) (tptr tvoid)) tint) Sskip Sbreak) wl_body) in H.
  inv H.
  - match goal with Hg : exec_stmt _ _ _ _ _ (Sifthenelse _ _ _) _ _ _ _ |- _ => inv Hg end.
    match goal with Hx : exec_stmt _ _ _ _ _ (if ?b then _ else _) _ _ _ _ |- _ =>
      destruct b; inv Hx end.
    match goal with Hb : exec_stmt _ _ _ _ _ wl_body _ _ _ _ |- _ =>
      pose proof (nbr_out _ _ _ _ _ _ _ _ _ Hb wl_body_nbr) as Ho;
      destruct (wl_body_tri c _ _ _ _ _ _ HJ Hb) as [(-> & HQ) | (_ & HR)] end.
    + split; [exists (c + 1); exact HQ | auto].
    + split; [exact HR | destruct Ho as [-> | ->]; auto].
  - match goal with Hg : exec_stmt _ _ _ _ _ (Sifthenelse _ _ _) _ _ _ _ |- _ => inv Hg end.
    match goal with Hx : exec_stmt _ _ _ _ _ (if ?b then _ else _) _ _ _ _ |- _ =>
      destruct b; inv Hx end; [congruence |].
    split; [exists c; exact HJ | auto].
Qed.

Lemma wl_loop_spec : forall le M t le' M' out,
    exec_stmt function_entry2 ge e le M wl_loop t le' M' out -> Jx le M ->
    out = Out_normal /\ Jx le' M'.
Proof.
  intros le M t le' M' out H.
  change wl_loop with (Sloop wl_s1 Sskip) in H.
  remember (Sloop wl_s1 Sskip) as S eqn:ES. remember empty_env as ee eqn:Ee. revert ES Ee.
  induction H; intros ES Ee HI; try discriminate ES; subst e.
  - injection ES as -> ->.
    match goal with Hx : exec_stmt _ _ _ _ _ wl_s1 _ _ _ _, Hb : out_break_or_return _ _ |- _ =>
      destruct (wl_iter _ _ _ _ _ _ Hx HI) as (HI1 & Ho); inv Hb end.
    + split; [reflexivity | exact HI1].
    + destruct Ho as [Ho | [Ho | Ho]]; discriminate Ho.
  - injection ES as -> ->.
    match goal with Hs : exec_stmt _ _ _ _ _ Sskip _ _ _ _, Hb : out_break_or_return _ _ |- _ =>
      inv Hs; inv Hb end.
  - injection ES as -> ->.
    match goal with Hx : exec_stmt _ _ _ _ _ wl_s1 _ _ _ _ |- _ =>
      destruct (wl_iter _ _ _ _ _ _ Hx HI) as (HI1 & _) end.
    match goal with Hs : exec_stmt _ _ _ _ _ Sskip _ _ _ _ |- _ => inv Hs end.
    apply IHexec_stmt3; auto.
Qed.

Lemma J0 : forall le,
    wf_list m avoid node0 ->
    Mem.load Mint16signed m bd (o + 22) = Some (Vint (Int.repr nw0)) ->
    le ! surface_collision._data = Some (Vptr bd od) ->
    le ! surface_collision._numCols = Some (Vint (Int.repr 0)) ->
    le ! surface_collision._surfaceNode = Some node0 ->
    J 0 le m.
Proof.
  intros le Hw Hl Hd Hn Hs.
  assert (E0 : nwof 0 = nw0) by (unfold nwof; lia).
  split; [split; [apply Mem.unchanged_on_refl | tauto] |].
  split; [exact Hd | split; [exact Hn | split; [lia |]]].
  rewrite E0. split; [exact Hl | split; [intros i Hi; lia |]].
  exists node0. auto.
Qed.

(* THE CONTRACT (within the section's assumptions on the data block) *)
Theorem wfl_contract : forall t m' vres,
    wf_list m avoid node0 ->
    Mem.load Mint16signed m bd (o + 22) = Some (Vint (Int.repr nw0)) ->
    eval_funcall function_entry2 ge m (Internal surface_collision.f_find_wall_collisions_from_list)
      [node0; Vptr bd od] t m' vres ->
    exists c, 0 <= c /\ vres = Vint (Int.repr c) /\ UOw m'
      /\ Mem.load Mint16signed m' bd (o + 22) = Some (Vint (Int.repr (nwof c)))
      /\ WW (nwof c) m'.
Proof.
  intros t m' vres Hw Hl H.
  inv H.
  match goal with He : function_entry2 _ _ _ _ _ _ _ |- _ => inv He end.
  match goal with Ha : alloc_variables _ _ _ _ _ _ |- _ =>
    cbn [surface_collision.f_find_wall_collisions_from_list fn_vars] in Ha; inv Ha end.
  match goal with Hb : bind_parameter_temps _ _ _ = Some _ |- _ =>
    cbn [bind_parameter_temps surface_collision.f_find_wall_collisions_from_list fn_params] in Hb;
    injection Hb as <- end.
  match goal with Hx : exec_stmt _ _ _ _ _ _ _ _ _ _ |- _ =>
    cbv [fn_body surface_collision.f_find_wall_collisions_from_list Swhile] in Hx; rename Hx into HB end.
  xinv.
  all: match goal with Hk : eval_expr _ _ _ _ (Econst_int (Int.repr 0) _) _ |- _ =>
         inv Hk; [| match goal with Hl0 : eval_lvalue _ _ _ _ (Econst_int _ _) _ _ _ |- _ => inv Hl0 end] end.
  all: match goal with Hlp : exec_stmt _ _ _ ?L ?MM (Sloop _ _) _ _ _ _ |- _ =>
         assert (HJ0 : Jx L MM) by
           (exists 0; apply J0; [exact Hw | exact Hl | ptg; reflexivity | ptg; reflexivity | ptg; reflexivity]);
         destruct (wl_loop_spec _ _ _ _ _ _ Hlp HJ0) as (Ho & (c & HJ)) end.
  all: try congruence.
  all: match goal with Hr : exec_stmt _ _ _ _ _ (Sreturn _) _ _ _ _ |- _ => inv Hr end.
  all: match goal with Ht : eval_expr _ _ _ _ (Etempvar _ _) _ |- _ =>
         inv Ht; [| match goal with Hl0 : eval_lvalue _ _ _ _ (Etempvar _ _) _ _ _ |- _ => inv Hl0 end] end.
  all: destruct HJ as (U & Hd & Hn & Hc & Hl' & HW & _).
  all: match goal with Hx : _ ! surface_collision._numCols = Some _ |- _ => rewrite Hn in Hx; inv Hx end.
  all: match goal with Hf : Mem.free_list _ _ = Some _ |- _ =>
         cbn [blocks_of_env PTree.elements Mem.free_list] in Hf; injection Hf as <- end.
  all: match goal with Ho : outcome_result_value _ _ _ _ |- _ =>
         cbn [fn_return surface_collision.f_find_wall_collisions_from_list] in Ho; destruct Ho as (_ & Hcs) end.
  all: unfold sem_cast, classify_cast, Ctypesdefs.tint in Hcs; cbv [Archi.ptr64] in Hcs; cbn in Hcs.
  all: injection Hcs as <-.
  all: exists c; split; [exact Hc |]; split; [reflexivity |]; auto.
Qed.

End WL.
