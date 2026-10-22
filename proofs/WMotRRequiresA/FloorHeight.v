(* ====================================================================== *)
(* FloorHeight (unwired, GOAL 2): the VALUE find_floor returns, proved from *)
(* its generated Clight body (surface_collision.c).                         *)
(*                                                                          *)
(* find_floor's result is read from its local `height`, which is only ever  *)
(* -11000 (the initial value), a height find_floor_from_list stored after   *)
(* its test  y - (h + -78.0f) < 0.0f  came out false (FloorList.hok, with   *)
(* y = the s16 cast of yPos), or the same for the SURFACE_INTANGIBLE        *)
(* re-search, whose y is (s32)(height - 200.0f).  Every stored height is   *)
(* also a HIT (FloorList.ffl_hit): the plane height of a surface on a      *)
(* partition list of the entry memory, at an (x, z) inside it.  [HPi Hit   *)
(* ys h] is exactly that set; [ff_height] proves every execution returns   *)
(* a member.                                                                *)
(* ====================================================================== *)

From Coq Require Import ZArith List Lia.
From compcert Require Import Coqlib Errors Maps AST Integers Floats Values Memory Events
  Globalenvs Ctypes Cop Clightdefs Clight ClightBigstep.
From SM64.Generated Require surface_collision.
From SM64.Proofs.WMotRRequiresA Require Import FloorList.
Import ListNotations.

Definition c11000 : float32 := Float32.of_int (Int.neg (Int.repr 11000)).
Definition c200 : float32 := Float32.of_bits (Int.repr 1128792064).   (* 200.0f *)

(* the heights find_floor's `height` / `dynamicHeight` can hold, given the
   set Hit of heights find_floor_from_list can store *)
Inductive HPi (Hit : float32 -> Prop) (ys : val) : float32 -> Prop :=
  | hp_init : HPi Hit ys c11000
  | hp_ok : forall h, hok ys h -> Hit h -> HPi Hit ys h
  | hp_re : forall h0 y' h, HPi Hit ys h0 ->
      Float32.to_int (Float32.sub h0 c200) = Some y' -> hok (Vint y') h -> Hit h -> HPi Hit ys h.

Lemma HPi_mono : forall (H1 H2 : float32 -> Prop) ys h,
    (forall x, H1 x -> H2 x) -> HPi H1 ys h -> HPi H2 ys h.
Proof.
  intros H1 H2 ys h Hm H. induction H.
  - apply hp_init.
  - apply hp_ok; auto.
  - eapply hp_re; eauto.
Qed.

(* ---- the partition cell find_floor reads: slot 0 (FLOORS) of cell ------ *)
(* (cellZ, cellX), each index in [0, 16) by the body's mask               *)

Lemma sn_size : forall (ge : genv), cenv_has ge -> sizeof ge sn_ty = 8.
Proof.
  intros ge HC. unfold sn_ty. cbn [sizeof].
  assert (E : match (prog_comp_env surface_collision.prog) ! surface_collision._SurfaceNode with
              | Some co => co_sizeof co | None => 0 end = 8) by (vm_compute; reflexivity).
  destruct ((prog_comp_env surface_collision.prog) ! surface_collision._SurfaceNode) as [co|] eqn:E0; [| discriminate].
  rewrite (HC _ _ E0). exact E.
Qed.

(* the s16 cast is the identity on s16 values *)
Lemma sext16_small : forall x, (-32768 <= Int.signed x < 32768)%Z -> Int.sign_ext 16 x = x.
Proof.
  intros x Hx.
  destruct (Int.eqmod_sign_ext 16 x ltac:(cbn; lia)) as (k & Ek).
  pose proof (Int.sign_ext_range 16 x ltac:(cbn; lia)) as R.
  pose proof (Int.unsigned_signed x) as U.
  change (two_p 16) with 65536%Z in Ek. change (two_p (16 - 1)) with 32768%Z in R.
  assert (S : Int.signed (Int.sign_ext 16 x) = Int.signed x).
  { destruct (Int.lt x Int.zero); rewrite U in Ek; change Int.modulus with 4294967296%Z in Ek; lia. }
  rewrite <- (Int.repr_signed (Int.sign_ext 16 x)), S. apply Int.repr_signed.
Qed.

Ltac ev_inv1 :=
  match goal with
  | H : eval_expr _ _ _ _ (Econst_int _ _) _ |- _ =>
      inv H; [| match goal with Hl : eval_lvalue _ _ _ _ (Econst_int _ _) _ _ _ |- _ => inv Hl end]
  | H : eval_expr _ _ _ _ (Ebinop _ _ _ _) _ |- _ =>
      inv H; [| match goal with Hl : eval_lvalue _ _ _ _ (Ebinop _ _ _ _) _ _ _ |- _ => inv Hl end]
  end.

Definition c15_e : expr :=
  Ebinop Osub
    (Ebinop Odiv
       (Ebinop Omul (Econst_int (Int.repr 2) tint) (Econst_int (Int.repr 8192) tint) tint)
       (Ebinop Oshl (Econst_int (Int.repr 1) tint) (Econst_int (Int.repr 10) tint) tint) tint)
    (Econst_int (Int.repr 1) tint) tint.

Lemma ev_c15 : forall (ge : genv) e le m v, eval_expr ge e le m c15_e v -> v = Vint (Int.repr 15).
Proof.
  intros ge e le m v H. unfold c15_e in H.
  repeat ev_inv1.
  repeat match goal with
         | H : sem_binary_operation _ _ _ _ _ _ _ = Some _ |- _ =>
             vm_compute in H; injection H as <-
         end.
  vm_compute. reflexivity.
Qed.

Definition cell_e (t : ident) : expr :=
  Ecast
    (Ebinop Oand
       (Ebinop Odiv
          (Ebinop Oadd (Etempvar t tshort) (Econst_int (Int.repr 8192) tint) tint)
          (Ebinop Oshl (Econst_int (Int.repr 1) tint) (Econst_int (Int.repr 10) tint) tint) tint)
       c15_e tint) tshort.

Lemma ev_cellidx : forall (ge : genv) e le m t v, eval_expr ge e le m (cell_e t) v ->
  exists i, v = Vint i /\ (0 <= Int.signed i < 16)%Z.
Proof.
  intros ge e le m t v H. unfold cell_e in H.
  inv H; [| match goal with Hl : eval_lvalue _ _ _ _ (Ecast _ _) _ _ _ |- _ => inv Hl end].
  match goal with Ha : eval_expr _ _ _ _ (Ebinop Oand _ _ _) _ |- _ =>
    inv Ha; [| match goal with Hl : eval_lvalue _ _ _ _ (Ebinop _ _ _ _) _ _ _ |- _ => inv Hl end] end.
  match goal with Hc : eval_expr _ _ _ _ c15_e _ |- _ => apply ev_c15 in Hc; subst end.
  match goal with Hb : sem_binary_operation _ Oand ?v1 _ _ _ _ = Some ?w |- _ =>
    destruct v1 as [| i0 | | | |]; cbn in Hb; try discriminate Hb end.
  match goal with Hb : sem_and _ _ _ _ _ = Some ?w |- _ =>
    assert (Ew : Some w = Some (Vint (Int.and i0 (Int.repr 15)))) by (rewrite <- Hb; reflexivity);
    injection Ew as ->; clear Hb end.
  match goal with Hs : sem_cast _ _ _ _ = Some ?w |- _ =>
    assert (Ew : Some w = Some (Vint (Int.sign_ext 16 (Int.and i0 (Int.repr 15)))))
      by (rewrite <- Hs; reflexivity);
    injection Ew as ->; clear Hs end.
  set (a := Int.and _ _).
  assert (Ua : (Int.unsigned a <= 15)%Z).
  { unfold a. rewrite Int.and_commut. exact (Int.and_le (Int.repr 15) _). }
  assert (Sa : Int.signed a = Int.unsigned a).
  { apply Int.signed_eq_unsigned. unfold Int.max_signed. cbn. lia. }
  pose proof (Int.unsigned_range a) as Ra.
  exists (Int.sign_ext 16 a). rewrite sext16_small by lia. split; [reflexivity | lia].
Qed.

Definition floor_head (ge : genv) (m : mem) (hd : val) : Prop :=
  exists id bp z x, In id part_ids /\ Genv.find_symbol ge id = Some bp
    /\ (0 <= z < 16)%Z /\ (0 <= x < 16)%Z
    /\ Mem.loadv Mint32 m (Vptr bp (Ptrofs.repr (384 * z + 24 * x))) = Some hd.

Lemma floor_head_part : forall ge m hd, floor_head ge m hd -> part_head ge m hd.
Proof.
  intros ge m hd (id & bp & z & x & Hin & Hs & _ & _ & Hl). exists id, bp, (Ptrofs.repr (384 * z + 24 * x)). auto.
Qed.

Local Notation SN := (Tstruct surface_collision._SurfaceNode noattr).

Definition part_e (pid : ident) : expr :=
  Ebinop Oadd
    (Ederef
      (Ebinop Oadd
        (Ederef
          (Ebinop Oadd
            (Evar pid (tarray (tarray (tarray SN 3) 16) 16))
            (Etempvar surface_collision._cellZ tshort)
            (tptr (tarray (tarray SN 3) 16)))
          (tarray (tarray SN 3) 16))
        (Etempvar surface_collision._cellX tshort)
        (tptr (tarray SN 3)))
      (tarray SN 3))
    (Econst_int (Int.repr 0) tint)
    (tptr SN).

(* an array-typed lvalue evaluates to its address *)
Definition arr_ev (ge : genv) e le m a : Prop :=
  forall v, eval_expr ge e le m a v -> exists l o, eval_lvalue ge e le m a l o Full /\ v = Vptr l o.

Lemma arr_ev_var : forall (ge : genv) e le m x t n, arr_ev ge e le m (Evar x (Tarray t n noattr)).
Proof.
  intros ge e le m x t n v H. inv H;
  match goal with H1 : deref_loc _ _ _ _ _ _ |- _ => cbn [typeof] in H1; inv H1 end;
    cbn in *; try discriminate.
  all: try match goal with Hl : eval_lvalue _ _ _ _ _ _ _ (Bits _ _ _ _) |- _ => inv Hl end.
  all: eexists _, _; split; [eassumption | reflexivity].
Qed.
Lemma arr_ev_deref : forall (ge : genv) e le m a t n, arr_ev ge e le m (Ederef a (Tarray t n noattr)).
Proof.
  intros ge e le m a t n v H. inv H;
  match goal with H1 : deref_loc _ _ _ _ _ _ |- _ => cbn [typeof] in H1; inv H1 end;
    cbn in *; try discriminate.
  all: try match goal with Hl : eval_lvalue _ _ _ _ _ _ _ (Bits _ _ _ _) |- _ => inv Hl end.
  all: eexists _, _; split; [eassumption | reflexivity].
Qed.

Lemma ev_padd : forall (ge : genv) e le m a b t n sz pty v,
    eval_expr ge e le m (Ebinop Oadd a b pty) v ->
    typeof a = Tarray t n noattr -> typeof b = Tint sz Signed noattr ->
    arr_ev ge e le m a ->
    exists l o i, eval_lvalue ge e le m a l o Full /\ eval_expr ge e le m b (Vint i)
      /\ v = Vptr l (Ptrofs.add o (Ptrofs.mul (Ptrofs.repr (sizeof ge t)) (Ptrofs.of_ints i))).
Proof.
  intros ge e le m a b t n sz pty v H Ht Hb' HA.
  inv H; [| match goal with Hl : eval_lvalue _ _ _ _ (Ebinop _ _ _ _) _ _ _ |- _ => inv Hl end].
  match goal with Ha : eval_expr _ _ _ _ a _ |- _ =>
    destruct (HA _ Ha) as (l & o & Hl & ->) end.
  match goal with Hb : sem_binary_operation _ _ _ _ ?v2 _ _ = Some _ |- _ =>
    cbn [sem_binary_operation] in Hb; rewrite Ht, Hb' in Hb;
    unfold sem_add in Hb; cbn [classify_add typeconv remove_attributes] in Hb;
    destruct sz; destruct v2; cbn in Hb; try discriminate Hb; injection Hb as <- end.
  all: eexists _, _, _; split; [eassumption | split; [eassumption | reflexivity]].
Qed.

Lemma ev_part : forall (ge : genv) e le m pid l o, cenv_has ge -> e ! pid = None ->
    eval_expr ge e le m (part_e pid) (Vptr l o) ->
    exists iz ix, le ! surface_collision._cellZ = Some (Vint iz)
      /\ le ! surface_collision._cellX = Some (Vint ix) /\ Genv.find_symbol ge pid = Some l
      /\ o = Ptrofs.add (Ptrofs.add (Ptrofs.add Ptrofs.zero
              (Ptrofs.mul (Ptrofs.repr 384) (Ptrofs.of_ints iz)))
              (Ptrofs.mul (Ptrofs.repr 24) (Ptrofs.of_ints ix)))
              (Ptrofs.mul (Ptrofs.repr 8) (Ptrofs.of_ints (Int.repr 0))).
Proof.
  intros ge e le m pid l o HC Hn H. unfold part_e in H.
  pose proof (sn_size ge HC) as S8.
  destruct (ev_padd _ _ _ _ _ _ _ _ _ _ _ H eq_refl eq_refl (arr_ev_deref _ _ _ _ _ _ _)) as (l1 & o1 & i0 & L1 & E0 & V1).
  inv L1.
  match goal with Hx : eval_expr _ _ _ _ (Ebinop _ _ (Etempvar surface_collision._cellX _) _) _ |- _ =>
  destruct (ev_padd _ _ _ _ _ _ _ _ _ _ _ Hx eq_refl eq_refl (arr_ev_deref _ _ _ _ _ _ _)) as (l2 & o2 & ix & L2 & EX & V2) end.
  inv L2.
  match goal with Hx : eval_expr _ _ _ _ (Ebinop _ _ (Etempvar surface_collision._cellZ _) _) _ |- _ =>
  destruct (ev_padd _ _ _ _ _ _ _ _ _ _ _ Hx eq_refl eq_refl (arr_ev_var _ _ _ _ _ _ _)) as (l3 & o3 & iz & L3 & EZ & V3) end.
  inv L3; [congruence |].
  inv V3. inv V2. injection V1 as -> ->.
  inv E0; [| match goal with Hl : eval_lvalue _ _ _ _ (Econst_int _ _) _ _ _ |- _ => inv Hl end].
  inv EX; [| match goal with Hl : eval_lvalue _ _ _ _ (Etempvar _ _) _ _ _ |- _ => inv Hl end].
  inv EZ; [| match goal with Hl : eval_lvalue _ _ _ _ (Etempvar _ _) _ _ _ |- _ => inv Hl end].
  exists iz, ix. split; [assumption | split; [assumption | split; [assumption |]]].
  unfold sn_ty in S8. cbn [sizeof] in S8 |- *. rewrite S8. reflexivity.
Qed.

Lemma part_ofs : forall iz ix, (0 <= Int.signed iz < 16)%Z -> (0 <= Int.signed ix < 16)%Z ->
    Ptrofs.add (Ptrofs.add (Ptrofs.add Ptrofs.zero
      (Ptrofs.mul (Ptrofs.repr 384) (Ptrofs.of_ints iz)))
      (Ptrofs.mul (Ptrofs.repr 24) (Ptrofs.of_ints ix)))
      (Ptrofs.mul (Ptrofs.repr 8) (Ptrofs.of_ints (Int.repr 0)))
    = Ptrofs.repr (384 * Int.signed iz + 24 * Int.signed ix).
Proof.
  intros iz ix Z X.
  assert (M : Ptrofs.max_unsigned = 4294967295%Z) by reflexivity.
  assert (R : forall k, (0 <= k <= 100000)%Z -> Ptrofs.unsigned (Ptrofs.repr k) = k)
    by (intros k Hk; apply Ptrofs.unsigned_repr; lia).
  unfold Ptrofs.of_ints, Ptrofs.add, Ptrofs.mul.
  change (Int.signed (Int.repr 0)) with 0%Z.
  rewrite Ptrofs.unsigned_zero, (R 384), (R 24), (R 8), (R 0), (R (Int.signed iz)), (R (Int.signed ix))
    by lia.
  rewrite (R (384 * Int.signed iz)) by lia. rewrite (R (24 * Int.signed ix)) by lia.
  rewrite (R (0 + 384 * Int.signed iz)) by lia.
  rewrite (R (0 + 384 * Int.signed iz + 24 * Int.signed ix)) by lia.
  rewrite (R (8 * 0)) by lia. f_equal. lia.
Qed.

(* an s16 value: what find_floor's `s16 x = (s16) xPos` holds *)
Definition s16v (v : val) : Prop := exists i, v = Vint i /\ Int.sign_ext 16 i = i.

(* a hit at an s16 (x, z): find_floor passes its s16 locals x, z
   (surface_collision.c:353-355) to find_floor_from_list.
   FOUND 2026-10-22: without the s16 bound this set was FALSE as a model of
   the game's hits.  For an arbitrary 32-bit x, z the three edge tests
   (int32, wrapping) pass at points far outside the triangle, where the plane
   height of any SLOPED floor is huge, so floor_data (|h| <= 16384, a WMotR
   floor height) held only for partitions whose floor lists hold no sloped
   surface: never for WMotR's loaded terrain. *)
Definition ffl_hit16 (m : mem) (s xv zv : val) (h : float32) : Prop :=
  ffl_hit m s xv zv h /\ s16v xv /\ s16v zv.

(* a height find_floor_from_list stored: a hit on a surface of a FLOOR
   list (slot 0 of a partition cell) of memory m, at an s16 (x, z) *)
Definition Hit_at (ge : genv) (m : mem) (h : float32) : Prop :=
  exists hd s xv zv, floor_head ge m hd /\ on_list m hd s /\ ffl_hit16 m s xv zv h.

(* the s16 cast of yPos, as the body computes it *)
Definition ycast (v : val) : val :=
  match v with
  | Vsingle f => match Float32.to_int f with
                 | Some i => Vint (Int.sign_ext 16 (Int.sign_ext 16 i))
                 | None => Vundef
                 end
  | _ => Vundef
  end.

(* ---- moving list / hit facts between memories that agree off W ---- *)

Lemma ol_transfer : forall mb (W : block -> Prop) hd, wf_list mb W hd ->
    forall M s, (forall b z, ~ W b -> Mem.load Mint32 M b z = Mem.load Mint32 mb b z) ->
    on_list M hd s -> on_list mb hd s.
Proof.
  intros mb W hd Hw. induction Hw as [| bn on nx Hv Hav Hld Hw IH]; intros M s F OL; inv OL.
  - apply ol_here. cbn [Mem.loadv] in *. rewrite <- (F _ _ Hav). assumption.
  - cbn [Mem.loadv] in *.
    match goal with Hn : Mem.load _ M _ _ = Some ?nx' |- _ =>
      rewrite (F _ _ Hav) in Hn; rewrite Hld in Hn; injection Hn as <- end.
    eapply ol_next; [exact Hld | eapply IH; eauto].
Qed.

Lemma wf_weaken : forall m (A A' : block -> Prop) hd, wf_list m A hd ->
    (forall b, Mem.valid_block m b -> ~ A b -> ~ A' b) -> wf_list m A' hd.
Proof.
  intros m A A' hd W Hw. induction W as [| bn on nx Hv Hav Hld W IH]; [constructor |].
  apply wf_cons with nx; auto.
Qed.

Lemma hit_transfer : forall M mb b o xv zv h,
    (forall ch z, Mem.load ch M b z = Mem.load ch mb b z) ->
    ffl_hit M (Vptr b o) xv zv h -> ffl_hit mb (Vptr b o) xv zv h.
Proof.
  intros M mb b o xv zv h F (bs & os & X & Z & x1 & z1 & x2 & z2 & x3 & z3 & nx & ny & nz & oo & Es & R).
  injection Es as <- <-. cbn [Mem.loadv] in R. rewrite !F in R.
  exists b, o, X, Z, x1, z1, x2, z2, x3, z3, nx, ny, nz, oo. split; [reflexivity |]. exact R.
Qed.

Lemma hit16_transfer : forall M mb b o xv zv h,
    (forall ch z, Mem.load ch M b z = Mem.load ch mb b z) ->
    ffl_hit16 M (Vptr b o) xv zv h -> ffl_hit16 mb (Vptr b o) xv zv h.
Proof.
  intros M mb b o xv zv h F (H & S). exact (conj (hit_transfer M mb b o xv zv h F H) S).
Qed.

(* triples whose abrupt exits see the outcome (the returned value) *)
Section TRH.
Variable ge : genv.
Variable e : env.

Definition trh (P : temp_env -> mem -> Prop) (s : statement)
    (Q : temp_env -> mem -> Prop) (R : outcome -> mem -> Prop) : Prop :=
  forall le M t le' M' out, P le M ->
    exec_stmt function_entry2 ge e le M s t le' M' out ->
    (out = Out_normal /\ Q le' M') \/ (out <> Out_normal /\ R out M').

Lemma trh_seq : forall P s1 Q s2 Q' R,
    trh P s1 Q R -> trh Q s2 Q' R -> trh P (Ssequence s1 s2) Q' R.
Proof.
  intros P s1 Q s2 Q' R T1 T2 le M t le' M' out HP H. inv H.
  - match goal with H1 : exec_stmt _ _ _ _ _ s1 _ _ _ Out_normal,
                    H2 : exec_stmt _ _ _ _ _ s2 _ _ _ _ |- _ =>
      destruct (T1 _ _ _ _ _ _ HP H1) as [(_ & HQ) | (Hn & _)];
        [exact (T2 _ _ _ _ _ _ HQ H2) | congruence] end.
  - match goal with H1 : exec_stmt _ _ _ _ _ s1 _ _ _ _, Hne : _ <> Out_normal |- _ =>
      destruct (T1 _ _ _ _ _ _ HP H1) as [(-> & _) | (_ & HR)];
        [congruence | right; split; assumption] end.
Qed.

Lemma trh_ite : forall P a s1 s2 Q R,
    trh P s1 Q R -> trh P s2 Q R -> trh P (Sifthenelse a s1 s2) Q R.
Proof.
  intros P a s1 s2 Q R T1 T2 le M t le' M' out HP H. inv H.
  match goal with Hx : exec_stmt _ _ _ _ _ (if ?b then _ else _) _ _ _ _ |- _ =>
    destruct b; [exact (T1 _ _ _ _ _ _ HP Hx) | exact (T2 _ _ _ _ _ _ HP Hx)] end.
Qed.

Lemma trh_skip : forall P R, trh P Sskip P R.
Proof. intros P R le M t le' M' out HP H. inv H. left; auto. Qed.

Lemma trh_ret : forall (P : temp_env -> mem -> Prop) a Q (R : outcome -> mem -> Prop),
    (forall le M v, P le M -> eval_expr ge e le M a v -> R (Out_return (Some (v, typeof a))) M) ->
    trh P (Sreturn (Some a)) Q R.
Proof.
  intros P a Q R PR le M t le' M' out HP H.
  inv H; right; split; try discriminate; eauto.
Qed.

Lemma trh_set : forall (P : temp_env -> mem -> Prop) x a R,
    (forall le M v, P le M -> eval_expr ge e le M a v -> P (PTree.set x v le) M) ->
    trh P (Sset x a) P R.
Proof. intros P x a R HS le M t le' M' out HP H. inv H. left; eauto. Qed.

Lemma trh_assign : forall (P : temp_env -> mem -> Prop) lhs rhs R,
    (forall le M b ofs bf v v' M', P le M ->
       eval_lvalue ge e le M lhs b ofs bf -> eval_expr ge e le M rhs v ->
       sem_cast v (typeof rhs) (typeof lhs) M = Some v' ->
       assign_loc ge (typeof lhs) M b ofs bf v' M' -> P le M') ->
    trh P (Sassign lhs rhs) P R.
Proof. intros P lhs rhs R HS le M t le' M' out HP H. inv H. left; eauto. Qed.
End TRH.

Lemma ycast_ok : forall yp v1 v M M',
    sem_cast yp tfloat tshort M = Some v1 -> sem_cast v1 tshort tshort M' = Some v -> v = ycast yp.
Proof.
  intros yp v1 v M M' H1 H2. unfold sem_cast in H1.
  destruct (intsize_eq I16 IBool) as [Hb|_]; [discriminate Hb |].
  destruct yp; cbn in H1; try discriminate H1.
  unfold ycast. unfold cast_single_int in H1.
  destruct (Float32.to_int f) as [i|]; [| discriminate H1].
  injection H1 as <-. unfold sem_cast in H2. cbn in H2. injection H2 as <-. reflexivity.
Qed.

Lemma sub_single : forall (ge : genv) hv c w m,
    sem_binary_operation ge Osub hv tfloat (Vsingle c) tfloat m = Some w ->
    exists h, hv = Vsingle h /\ w = Vsingle (Float32.sub h c).
Proof.
  intros ge hv c w m H. destruct hv; cbn in H; try discriminate H.
  all: try (injection H as <-; eauto).
  all: try (destruct Archi.ptr64; discriminate H).
Qed.

(* the temps that only ever hold copies of a height cell *)
Definition hts : list ident :=
  [surface_collision._t'7; surface_collision._t'9; surface_collision._t'10;
   surface_collision._t'11; surface_collision._t'14; surface_collision._t'16;
   surface_collision._t'17].

Section FH.
Variable ge : genv.
Variables bH bD bpf : block.
Variable opf : ptrofs.
Variable mb : mem.
Hypothesis HC : cenv_has ge.
Hypothesis Hpin : ffl_pinned ge.
Hypothesis HHD : bH <> bD.
Hypothesis HpH : bpf <> bH.
Hypothesis HpD : bpf <> bD.
Hypothesis Hgl : forall id b, In id ff_statics -> Genv.find_symbol ge id = Some b -> b <> bH /\ b <> bD.
Hypothesis Hsp : forall id b, In id ff_statics -> Genv.find_symbol ge id = Some b -> b <> bpf.
(* the blocks find_floor writes *)
Definition Wr (b : block) : Prop := b = bH \/ b = bD \/ b = bpf \/ is_static ge b.
Hypothesis Hpart : forall id bp, In id part_ids -> Genv.find_symbol ge id = Some bp -> ~ Wr bp.
Hypothesis Hwf : forall hd, part_head ge mb hd -> wf_list mb Wr hd.
Hypothesis Hsurf : forall hd s, part_head ge mb hd -> on_list mb hd s ->
  exists b o, s = Vptr b o /\ ~ Wr b.
Variable ys : val.
Local Notation e := (ffe bH bD).
Local Notation HP := (HPi (Hit_at ge mb) ys).

(* the list head read so far is a floor head; the cell indices are in range *)
Definition SLp (le : temp_env) : Prop :=
  (forall sl, le ! surface_collision._surfaceList = Some sl -> sl = Vundef \/ floor_head ge mb sl)
  /\ (forall c v, (c = surface_collision._cellX \/ c = surface_collision._cellZ) -> le ! c = Some v ->
       v = Vundef \/ exists i, v = Vint i /\ (0 <= Int.signed i < 16)%Z)
  /\ (forall c v, (c = surface_collision._x \/ c = surface_collision._z) -> le ! c = Some v ->
       v = Vundef \/ s16v v).

Lemma SLp_set : forall le x v, SLp le -> x <> surface_collision._surfaceList ->
    x <> surface_collision._cellX -> x <> surface_collision._cellZ ->
    x <> surface_collision._x -> x <> surface_collision._z -> SLp (PTree.set x v le).
Proof.
  intros le x v (S1 & S2 & S3) H1 H2 H3 H4 H5. split; [| split].
  - intros sl Hl. rewrite PTree.gso in Hl by congruence. eauto.
  - intros c w Hc Hl. rewrite PTree.gso in Hl by (destruct Hc as [-> | ->]; congruence). eauto.
  - intros c w Hc Hl. rewrite PTree.gso in Hl by (destruct Hc as [-> | ->]; congruence). eauto.
Qed.

Definition HH (le : temp_env) (M : mem) : Prop :=
  (le ! surface_collision._y = Some ys \/ le ! surface_collision._y = Some Vundef)
  /\ (exists yp, le ! surface_collision._yPos = Some yp /\ ycast yp = ys)
  /\ (forall id h, In id hts -> le ! id = Some (Vsingle h) -> HP h)
  /\ (forall h, Mem.load Mfloat32 M bH 0 = Some (Vsingle h) -> HP h)
  /\ (forall h, Mem.load Mfloat32 M bD 0 = Some (Vsingle h) -> HP h)
  /\ le ! surface_collision._pfloor = Some (Vptr bpf opf)
  /\ SLp le
  /\ (forall ch b z, ~ Wr b -> Mem.load ch M b z = Mem.load ch mb b z).

Definition RH (out : outcome) (M : mem) : Prop :=
  forall v ty, out = Out_return (Some (v, ty)) ->
    ty = tfloat /\ forall h, v = Vsingle h -> HP h.

Ltac idne := let HH := fresh in intro HH; cbv in HH; discriminate HH.
Ltac nin := let H := fresh in intro H; cbv in H;
  repeat (destruct H as [H|H]; [discriminate H |]); exact H.
Ltac inh := cbv; repeat (first [left; reflexivity | right]).

Lemma HH_set_other : forall le M x v, HH le M ->
    ~ In x hts -> x <> surface_collision._y -> x <> surface_collision._yPos ->
    x <> surface_collision._pfloor -> x <> surface_collision._surfaceList ->
    x <> surface_collision._cellX -> x <> surface_collision._cellZ ->
    x <> surface_collision._x -> x <> surface_collision._z ->
    HH (PTree.set x v le) M.
Proof.
  intros le M x v (Y & YP & T & CH & CD & PF & SL & MF) Hx Hy Hyp Hpf Hsl Hcx Hcz Hxx Hzz.
  split; [rewrite PTree.gso by congruence; exact Y |].
  split; [rewrite PTree.gso by congruence; exact YP |].
  split; [intros id h Hin Hl; rewrite PTree.gso in Hl by (intros ->; contradiction); eauto |].
  split; [exact CH | split; [exact CD |]].
  split; [rewrite PTree.gso by congruence; exact PF |].
  split; [| exact MF].
  apply SLp_set; assumption.
Qed.

(* a height variable's value *)
Lemma ev_cell : forall le M x v,
    (x = surface_collision._height \/ x = surface_collision._dynamicHeight) ->
    HH le M -> eval_expr ge e le M (Evar x tfloat) v ->
    v = Vundef \/ exists h, v = Vsingle h /\ HP h.
Proof.
  intros le M x v Hx (_ & _ & _ & CH & CD & _) H.
  inv H. match goal with Hl : eval_lvalue _ _ _ _ (Evar _ _) _ _ _ |- _ => inv Hl end.
  - match goal with Hd : deref_loc _ _ _ _ _ _ |- _ => inv Hd end; cbn in *; try discriminate.
    match goal with Ha : By_value _ = By_value _ |- _ => inv Ha end.
    match goal with Hl : Mem.load _ _ _ _ = Some _, He : e ! x = Some _ |- _ =>
      rewrite Ptrofs.unsigned_zero in Hl; rename Hl into HL; rename He into HE end.
    pose proof (Mem.load_type _ _ _ _ _ HL) as Ty.
    destruct v; cbn in Ty; try contradiction; [left; reflexivity | right; exists f; split; [reflexivity |]].
    destruct Hx as [-> | ->].
    + rewrite ffe_H in HE. inv HE. exact (CH _ HL).
    + rewrite ffe_D in HE. inv HE. exact (CD _ HL).
  - destruct Hx as [-> | ->]; [rewrite ffe_H in * | rewrite ffe_D in *]; discriminate.
Qed.

Lemma HH_set_y : forall R,
  trh ge e HH (Sset surface_collision._y
                 (Ecast (Ecast (Etempvar surface_collision._yPos tfloat) tshort) tshort)) HH R.
Proof.
  intros R. apply trh_set. intros le M v (Y & (yp & Hyp & Hc) & T & CH & CD & PF & SL & MF) Hev.
  inv Hev; [| match goal with Hl : eval_lvalue _ _ _ _ (Ecast _ _) _ _ _ |- _ => inv Hl end].
  match goal with Hk : eval_expr _ _ _ _ (Ecast _ _) _ |- _ =>
    inv Hk; [| match goal with Hl : eval_lvalue _ _ _ _ (Ecast _ _) _ _ _ |- _ => inv Hl end] end.
  match goal with Ht : eval_expr _ _ _ _ (Etempvar _ _) _ |- _ =>
    inv Ht; [| match goal with Hl : eval_lvalue _ _ _ _ (Etempvar _ _) _ _ _ |- _ => inv Hl end] end.
  match goal with Hx : le ! surface_collision._yPos = Some _ |- _ => rewrite Hyp in Hx; inv Hx end.
  cbn [typeof] in *.
  match goal with H1 : sem_cast _ tfloat tshort _ = Some ?v1,
                  H2 : sem_cast ?v1 tshort tshort _ = Some _ |- _ =>
    pose proof (ycast_ok _ _ _ _ _ H1 H2) as Ev end.
  subst v. rewrite Hc.
  split; [left; apply PTree.gss |].
  split; [eexists; split; [rewrite PTree.gso by idne; exact Hyp | exact Hc] |].
  split; [intros id h Hin Hl; rewrite PTree.gso in Hl by (intros ->; revert Hin; nin); eauto |].
  split; [exact CH | split; [exact CD |]].
  split; [rewrite PTree.gso by idne; exact PF |].
  split; [| exact MF].
  apply SLp_set; [exact SL | idne | idne | idne | idne | idne].
Qed.

(* s16 x = (s16) xPos; s16 z = (s16) zPos: an s16 value (or no value) *)
Lemma s16_cast : forall (v1 v : val) p M M',
    sem_cast p tfloat tshort M = Some v1 -> sem_cast v1 tshort tshort M' = Some v -> s16v v.
Proof.
  intros v1 v p M M' H1 H2. pose proof (ycast_ok _ _ _ _ _ H1 H2) as E. subst v.
  unfold ycast. destruct p; cbn in H1; try discriminate H1.
  unfold sem_cast in H1. cbn in H1. unfold cast_single_int in H1.
  destruct (Float32.to_int f) as [i|]; [| discriminate H1].
  exists (Int.sign_ext 16 (Int.sign_ext 16 i)). split; [reflexivity |].
  rewrite !Int.sign_ext_idem by (cbn; lia). reflexivity.
Qed.

Lemma HH_set_xz : forall c p R, (c = surface_collision._x \/ c = surface_collision._z) ->
  trh ge e HH (Sset c (Ecast (Ecast (Etempvar p tfloat) tshort) tshort)) HH R.
Proof.
  intros c p R Hc. apply trh_set. intros le M v (Y & YP & T & CH & CD & PF & (S1 & S2 & S3) & MF) Hev.
  inv Hev; [| match goal with Hl : eval_lvalue _ _ _ _ (Ecast _ _) _ _ _ |- _ => inv Hl end].
  match goal with Hk : eval_expr _ _ _ _ (Ecast _ _) _ |- _ =>
    inv Hk; [| match goal with Hl : eval_lvalue _ _ _ _ (Ecast _ _) _ _ _ |- _ => inv Hl end] end.
  cbn [typeof] in *.
  assert (Sv : s16v v)
    by (match goal with H1 : sem_cast _ tfloat tshort _ = Some ?v1,
                        H2 : sem_cast ?v1 tshort tshort _ = Some _ |- _ =>
          exact (s16_cast _ _ _ _ _ H1 H2) end).
  assert (N : forall x, x = surface_collision._y \/ x = surface_collision._yPos
                \/ x = surface_collision._pfloor \/ x = surface_collision._surfaceList
                \/ x = surface_collision._cellX \/ x = surface_collision._cellZ
                \/ In x hts -> x <> c).
  { intros x Hx <-. destruct Hc as [-> | ->]; cbv in Hx;
      repeat (destruct Hx as [Hx | Hx]; [discriminate Hx |]); try discriminate Hx; exact Hx. }
  split; [rewrite PTree.gso by (apply N; left; reflexivity); exact Y |].
  split; [destruct YP as (yp & ? & ?); exists yp;
          rewrite PTree.gso by (apply N; right; left; reflexivity); auto |].
  split; [intros id h Hin Hl;
          rewrite PTree.gso in Hl by (apply N; do 6 right; exact Hin); eauto |].
  split; [exact CH | split; [exact CD |]].
  split; [rewrite PTree.gso by (apply N; right; right; left; reflexivity); exact PF |].
  split; [| exact MF]. split; [| split].
  - intros sl Hl. rewrite PTree.gso in Hl by (apply N; right; right; right; left; reflexivity). eauto.
  - intros c' w Hc' Hl. rewrite PTree.gso in Hl
      by (destruct Hc' as [-> | ->]; apply N; do 4 right; [left | right; left]; reflexivity). eauto.
  - intros c' w Hc' Hl. destruct (peq c' c) as [-> | Hne].
    + rewrite PTree.gss in Hl. injection Hl as <-. right. exact Sv.
    + rewrite PTree.gso in Hl by exact Hne. eauto.
Qed.

(* the x / z argument of a find_floor_from_list call: s16 *)
Lemma xz_arg_ok : forall c, (c = surface_collision._x \/ c = surface_collision._z) ->
    forall le M v x, HH le M -> eval_expr ge e le M (Etempvar c tshort) v ->
    sem_cast v (typeof (Etempvar c tshort)) tint M = Some x -> s16v x.
Proof.
  intros c Hc le M v x (_ & _ & _ & _ & _ & _ & (_ & _ & S3) & _) Hev Hcst.
  inv Hev; [| match goal with Hl : eval_lvalue _ _ _ _ (Etempvar _ _) _ _ _ |- _ => inv Hl end].
  match goal with Hx : le ! c = Some ?w |- _ => destruct (S3 _ _ Hc Hx) as [-> | (i & -> & Hi)] end.
  - cbn in Hcst. discriminate Hcst.
  - cbn in Hcst. injection Hcst as <-. exists i. auto.
Qed.

Lemma HH_set_ht : forall tk x R, In tk hts ->
    (x = surface_collision._height \/ x = surface_collision._dynamicHeight) ->
    trh ge e HH (Sset tk (Evar x tfloat)) HH R.
Proof.
  intros tk x R Hk Hx. apply trh_set. intros le M v HI Hev.
  pose proof (ev_cell le M x v Hx HI Hev) as Hv.
  destruct HI as (Y & YP & T & CH & CD & PF & SL & MF).
  assert (Hy : tk <> surface_collision._y) by (intros ->; revert Hk; nin).
  assert (Hyp : tk <> surface_collision._yPos) by (intros ->; revert Hk; nin).
  assert (Hpf : tk <> surface_collision._pfloor) by (intros ->; revert Hk; nin).
  assert (Hsl : tk <> surface_collision._surfaceList) by (intros ->; revert Hk; nin).
  split; [rewrite PTree.gso by exact (not_eq_sym Hy); exact Y |].
  split; [destruct YP as (yp & ? & ?); exists yp; rewrite PTree.gso by exact (not_eq_sym Hyp); auto |].
  split; [| split; [exact CH | split; [exact CD |]]].
  - intros id h Hin Hl. destruct (peq id tk) as [-> | Hne].
    + rewrite PTree.gss in Hl. injection Hl as ->.
      destruct Hv as [Hd | (h' & Hh & Hp)]; [discriminate Hd | injection Hh as ->; exact Hp].
    + rewrite PTree.gso in Hl by exact Hne. eauto.
  - split; [rewrite PTree.gso by exact (not_eq_sym Hpf); exact PF |].
    split; [| exact MF].
    apply SLp_set; [exact SL | exact Hsl | intros ->; revert Hk; nin | intros ->; revert Hk; nin
                   | intros ->; revert Hk; nin | intros ->; revert Hk; nin].
Qed.

(* the cell indices: in [0, 16) by the mask *)
Lemma HH_set_cell : forall c t R,
    (c = surface_collision._cellX \/ c = surface_collision._cellZ) ->
    trh ge e HH (Sset c (cell_e t)) HH R.
Proof.
  intros c t R Hc. apply trh_set. intros le M v HI Hev.
  destruct (ev_cellidx _ _ _ _ _ _ Hev) as (i & -> & Ri).
  destruct HI as (Y & YP & T & CH & CD & PF & (S1 & S2 & S3) & MF).
  assert (N : forall x, x = surface_collision._y \/ x = surface_collision._yPos
                \/ x = surface_collision._pfloor \/ x = surface_collision._surfaceList
                \/ In x hts -> x <> c).
  { intros x Hx <-. destruct Hc as [-> | ->]; cbv in Hx;
      repeat (destruct Hx as [Hx | Hx]; [discriminate Hx |]); try discriminate Hx; exact Hx. }
  split; [rewrite PTree.gso by (apply N; left; reflexivity); exact Y |].
  split; [destruct YP as (yp & ? & ?); exists yp;
          rewrite PTree.gso by (apply N; right; left; reflexivity); auto |].
  split; [intros id h Hin Hl; rewrite PTree.gso in Hl by (apply N; right; right; right; right; exact Hin);
          eauto |].
  split; [exact CH | split; [exact CD |]].
  split; [rewrite PTree.gso by (apply N; right; right; left; reflexivity); exact PF |].
  split; [| exact MF]. split; [| split].
  - intros sl Hl. rewrite PTree.gso in Hl by (apply N; right; right; right; left; reflexivity). eauto.
  - intros c' w Hc' Hl. destruct (peq c' c) as [-> | Hne].
    + rewrite PTree.gss in Hl. injection Hl as <-. right. exists i. auto.
    + rewrite PTree.gso in Hl by exact Hne. eauto.
  - intros c' w Hc' Hl. rewrite PTree.gso in Hl
      by (destruct Hc as [-> | ->]; destruct Hc' as [-> | ->]; idne). eauto.
Qed.

Ltac base_id A :=
  lazymatch A with
  | Evar ?x _ => x
  | Ebinop _ ?a1 _ _ => base_id a1
  | Ederef ?a1 _ => base_id a1
  end.

Lemma HH_set_sl : forall pid R, In pid part_ids ->
    trh ge e HH
      (Sset surface_collision._surfaceList
         (Efield (Ederef (part_e pid) (Tstruct surface_collision._SurfaceNode noattr))
            surface_collision._next (tptr (Tstruct surface_collision._SurfaceNode noattr)))) HH R.
Proof.
  intros pid R Hin. apply trh_set. intros le M v HI Hev.
  destruct HI as (Y & YP & T & CH & CD & PF & (S1 & S2 & S3) & MF).
  destruct (deref_field ge e le M (part_e pid) surface_collision._SurfaceNode surface_collision._next
              (tptr (Tstruct surface_collision._SurfaceNode noattr)) v SN_NEXT
              (fun co Hc => proj1 (sn_offsets_ge ge co HC Hc)) eq_refl Hev) as (l & ofs & HA & Hld).
  assert (Hne : e ! pid = None)
    by (apply ffe_other; destruct Hin as [<- | [<- | []]]; idne).
  destruct (ev_part ge e le M pid l ofs HC Hne HA) as (iz & ix & Hz & Hx & Hs & ->).
  destruct (S2 _ _ (or_intror eq_refl) Hz) as [Ez | (iz' & Ez & Rz)]; [discriminate Ez |].
  injection Ez as <-.
  destruct (S2 _ _ (or_introl eq_refl) Hx) as [Ex | (ix' & Ex & Rx)]; [discriminate Ex |].
  injection Ex as <-.
  rewrite (part_ofs iz ix Rz Rx) in Hld. unfold SN_NEXT in Hld. rewrite Ptrofs.add_zero in Hld.
  pose proof (Hpart pid l Hin Hs) as Nw.
  split; [rewrite PTree.gso by idne; exact Y |].
  split; [destruct YP as (yp & ? & ?); exists yp; rewrite PTree.gso by idne; auto |].
  split; [intros id h Hi Hl; rewrite PTree.gso in Hl by (intros ->; revert Hi; nin); eauto |].
  split; [exact CH | split; [exact CD |]].
  split; [rewrite PTree.gso by idne; exact PF |].
  split; [| exact MF]. split; [| split].
  - intros sl Hl. rewrite PTree.gss in Hl. injection Hl as <-. right.
    exists pid, l, (Int.signed iz), (Int.signed ix).
    split; [exact Hin | split; [exact Hs | split; [lia | split; [lia |]]]].
    cbn [Mem.loadv] in *. rewrite <- (MF _ _ _ Nw). exact Hld.
  - intros c w Hc Hl. rewrite PTree.gso in Hl by (destruct Hc as [-> | ->]; idne). eauto.
  - intros c w Hc Hl. rewrite PTree.gso in Hl by (destruct Hc as [-> | ->]; idne). eauto.
Qed.

Lemma HH_assign_cell : forall x rhs R,
    (x = surface_collision._height \/ x = surface_collision._dynamicHeight) ->
    (forall le M v v' h, HH le M -> eval_expr ge e le M rhs v ->
       sem_cast v (typeof rhs) tfloat M = Some v' -> v' = Vsingle h -> HP h) ->
    trh ge e HH (Sassign (Evar x tfloat) rhs) HH R.
Proof.
  intros x rhs R Hx Hr. apply trh_assign.
  intros le M b ofs bf v v' M' HI Hl Hev Hc Ha.
  cbn [typeof] in Hc.
  pose proof (fun h => Hr _ _ _ _ h HI Hev Hc) as Hv.
  destruct HI as (Y & YP & T & CH & CD & PF & SL & MF).
  inv Hl; [| destruct Hx as [-> | ->]; [rewrite ffe_H in * | rewrite ffe_D in *]; discriminate].
  inv Ha; cbn [access_mode] in *; try discriminate.
  try match goal with Hm : access_mode _ = By_value _ |- _ =>
    change (access_mode (typeof (Evar _ tfloat))) with (By_value Mfloat32) in Hm; inv Hm end.
  cbn [Mem.storev] in *. rewrite Ptrofs.unsigned_zero in *.
  match goal with Hs : Mem.store _ _ _ _ _ = Some _ |- _ => rename Hs into HS end.
  assert (Hcell : forall h, Mem.load Mfloat32 M' b 0 = Some (Vsingle h) -> HP h).
  { intros h Hld. rewrite (Mem.load_store_same _ _ _ _ _ _ HS) in Hld. injection Hld as Hld.
    destruct v'; cbn in Hld; try discriminate Hld. apply Hv. exact Hld. }
  assert (Hb : b = bH \/ b = bD)
    by (destruct Hx as [-> | ->];
        match goal with He : (ffe _ _) ! _ = Some _ |- _ =>
          first [rewrite ffe_H in He | rewrite ffe_D in He]; inv He end; auto).
  assert (MF' : forall ch b' z, ~ Wr b' -> Mem.load ch M' b' z = Mem.load ch mb b' z).
  { intros ch b' z Nw. rewrite <- (MF _ _ _ Nw). eapply Mem.load_store_other; [exact HS |].
    left. intros ->. apply Nw. destruct Hb as [-> | ->]; [left | right; left]; reflexivity. }
  split; [exact Y | split; [exact YP | split; [exact T |]]].
  destruct Hb as [-> | ->].
  - split; [exact Hcell | split; [| split; [exact PF | split; [exact SL | exact MF']]]].
    intros h Hld. apply CD. erewrite <- Mem.load_store_other; [exact Hld | exact HS |].
    left. exact (not_eq_sym HHD).
  - split; [| split; [exact Hcell | split; [exact PF | split; [exact SL | exact MF']]]].
    intros h Hld. apply CH. erewrite <- Mem.load_store_other; [exact Hld | exact HS |].
    left. exact HHD.
Qed.

Lemma HH_assign_other : forall lhs rhs R,
    (forall le M b ofs bf, HH le M -> eval_lvalue ge e le M lhs b ofs bf ->
       b = bpf \/ is_static ge b) ->
    trh ge e HH (Sassign lhs rhs) HH R.
Proof.
  intros lhs rhs R Hb. apply trh_assign.
  intros le M b ofs bf v v' M' HI Hl _ _ Ha.
  pose proof (Hb _ _ _ _ _ HI Hl) as Wb.
  assert (N1 : b <> bH) by (destruct Wb as [-> | (id & Hin & Hs)];
                             [exact HpH | exact (proj1 (Hgl id b Hin Hs))]).
  assert (N2 : b <> bD) by (destruct Wb as [-> | (id & Hin & Hs)];
                             [exact HpD | exact (proj2 (Hgl id b Hin Hs))]).
  destruct HI as (Y & YP & T & CH & CD & PF & SL & MF).
  assert (K : forall ch b' z, b' <> b -> Mem.load ch M' b' z = Mem.load ch M b' z).
  { intros ch b' z Hn. inv Ha.
    - cbn [Mem.storev] in *. eapply Mem.load_store_other; [eassumption | left; exact Hn].
    - eapply Mem.load_storebytes_other; [eassumption | left; exact Hn].
    - match goal with Hs : ?T |- _ => lazymatch T with context [store_bitfield] => inv Hs end end.
      eapply Mem.load_store_other; [eassumption | left; exact Hn]. }
  split; [exact Y | split; [exact YP | split; [exact T |]]].
  split; [intros h Hl'; apply CH; rewrite <- (K _ bH _ (not_eq_sym N1)); exact Hl' |].
  split; [intros h Hl'; apply CD; rewrite <- (K _ bD _ (not_eq_sym N2)); exact Hl' |].
  split; [exact PF | split; [exact SL |]].
  intros ch b' z Nw. rewrite <- (MF _ _ _ Nw). apply K.
  intros ->. apply Nw. right; right. exact Wb.
Qed.

Lemma lv_pf : forall ty ty' le M b ofs bf, HH le M ->
    eval_lvalue ge e le M (Ederef (Etempvar surface_collision._pfloor ty) ty') b ofs bf ->
    b = bpf \/ is_static ge b.
Proof.
  intros ty ty' le M b ofs bf (_ & _ & _ & _ & _ & Hp & _) H. inv H.
  match goal with Ht : eval_expr _ _ _ _ (Etempvar _ _) _ |- _ =>
    inv Ht; [| match goal with Hl : eval_lvalue _ _ _ _ (Etempvar _ _) _ _ _ |- _ => inv Hl end] end.
  match goal with Hx : le ! _ = Some (Vptr _ _) |- _ => rewrite Hp in Hx; inv Hx end.
  left. reflexivity.
Qed.

Lemma lv_st : forall x ty, In x ff_statics ->
    forall le M b ofs bf, HH le M -> eval_lvalue ge e le M (Evar x ty) b ofs bf ->
    b = bpf \/ is_static ge b.
Proof.
  intros x ty Hin le M b ofs bf _ Hl.
  destruct (lv_static ge bH bD x le M ty b ofs bf Hin Hl) as (Hs & _ & _).
  right. exists x. auto.
Qed.

Lemma lv_ncf : forall le M b ofs bf, HH le M ->
    eval_lvalue ge e le M
      (Efield (Evar surface_collision._gNumCalls (Tstruct surface_collision._NumTimesCalled noattr))
         surface_collision._floor tshort) b ofs bf ->
    b = bpf \/ is_static ge b.
Proof.
  intros le M b ofs bf _ Hl.
  destruct (lv_calls_floor ge bH bD HC le M b ofs bf Hl) as (Hs & _ & _).
  right. exists surface_collision._gNumCalls. split; [inh | exact Hs].
Qed.

Lemma c11000_ok : forall le M v v' h, HH le M ->
    eval_expr ge e le M (Eunop Oneg (Econst_int (Int.repr 11000) tint) tint) v ->
    sem_cast v (typeof (Eunop Oneg (Econst_int (Int.repr 11000) tint) tint)) tfloat M = Some v' ->
    v' = Vsingle h -> HP h.
Proof.
  intros le M v v' h _ Hev Hc ->.
  inv Hev; [| match goal with Hl : eval_lvalue _ _ _ _ (Eunop _ _ _) _ _ _ |- _ => inv Hl end].
  match goal with Hk : eval_expr _ _ _ _ (Econst_int _ _) _ |- _ =>
    inv Hk; [| match goal with Hl : eval_lvalue _ _ _ _ (Econst_int _ _) _ _ _ |- _ => inv Hl end] end.
  match goal with Hu : sem_unary_operation Oneg _ _ _ = Some _ |- _ =>
    unfold sem_unary_operation, sem_neg in Hu; cbn [typeof classify_neg] in Hu; injection Hu as <- end.
  unfold sem_cast in Hc. cbn [typeof classify_cast] in Hc. injection Hc as Hc.
  subst h. exact (hp_init _ ys).
Qed.

Lemma ht_rhs_ok : forall tk, In tk hts ->
    forall le M v v' h, HH le M -> eval_expr ge e le M (Etempvar tk tfloat) v ->
    sem_cast v (typeof (Etempvar tk tfloat)) tfloat M = Some v' -> v' = Vsingle h -> HP h.
Proof.
  intros tk Hk le M v v' h (_ & _ & T & _) Hev Hc ->.
  inv Hev; [| match goal with Hl : eval_lvalue _ _ _ _ (Etempvar _ _) _ _ _ |- _ => inv Hl end].
  destruct v; cbn in Hc; try discriminate Hc. injection Hc as ->. eauto.
Qed.

Lemma ya_ok : forall le M v y h, HH le M ->
    eval_expr ge e le M (Etempvar surface_collision._y tshort) v ->
    sem_cast v (typeof (Etempvar surface_collision._y tshort)) tint M = Some y ->
    hok y h -> Hit_at ge mb h -> HP h.
Proof.
  intros le M v y h (Y & _) Hev Hc Hk Ht.
  inv Hev; [| match goal with Hl : eval_lvalue _ _ _ _ (Etempvar _ _) _ _ _ |- _ => inv Hl end].
  assert (Ey : y = v)
    by (destruct v; cbn in Hc; try discriminate Hc; injection Hc as <-; reflexivity).
  subst y.
  destruct Y as [Y | Y]; rewrite Y in *;
    match goal with Hx : Some _ = Some _ |- _ => inv Hx end.
  - apply hp_ok; assumption.
  - destruct Hk as (yi & Hk & _). discriminate Hk.
Qed.

Lemma yre_ok : forall le M v y h, HH le M ->
    eval_expr ge e le M
      (Ecast (Ebinop Osub (Etempvar surface_collision._t'14 tfloat)
                (Econst_single (Float32.of_bits (Int.repr 1128792064)) tfloat) tfloat) tint) v ->
    sem_cast v (typeof (Ecast (Ebinop Osub (Etempvar surface_collision._t'14 tfloat)
                (Econst_single (Float32.of_bits (Int.repr 1128792064)) tfloat) tfloat) tint))
      tint M = Some y ->
    hok y h -> Hit_at ge mb h -> HP h.
Proof.
  intros le M v y h (_ & _ & T & _) Hev Hc Hk Ht.
  inv Hev; [| match goal with Hl : eval_lvalue _ _ _ _ (Ecast _ _) _ _ _ |- _ => inv Hl end].
  match goal with Hk : eval_expr _ _ _ _ (Ebinop _ _ _ _) _ |- _ =>
    inv Hk; [| match goal with Hl : eval_lvalue _ _ _ _ (Ebinop _ _ _ _) _ _ _ |- _ => inv Hl end] end.
  match goal with Ht : eval_expr _ _ _ _ (Etempvar _ _) _ |- _ =>
    inv Ht; [| match goal with Hl : eval_lvalue _ _ _ _ (Etempvar _ _) _ _ _ |- _ => inv Hl end] end.
  match goal with Ht : eval_expr _ _ _ _ (Econst_single _ _) _ |- _ =>
    inv Ht; [| match goal with Hl : eval_lvalue _ _ _ _ (Econst_single _ _) _ _ _ |- _ => inv Hl end] end.
  cbn [typeof] in *.
  match goal with Hb : sem_binary_operation _ Osub _ tfloat (Vsingle _) tfloat _ = Some _ |- _ =>
    destruct (sub_single _ _ _ _ _ Hb) as (h0 & -> & ->) end.
  match goal with Hs : sem_cast (Vsingle _) tfloat tint _ = Some _ |- _ =>
    unfold sem_cast in Hs; cbn in Hs; try unfold cast_single_int in Hs;
    destruct (Float32.to_int (Float32.sub h0 (Float32.of_bits (Int.repr 1128792064)))) as [i|] eqn:Ti;
    [injection Hs as <- | discriminate Hs] end.
  unfold sem_cast in Hc. cbn in Hc. injection Hc as <-.
  eapply hp_re; [eapply T; [| eassumption]; inh | exact Ti | exact Hk | exact Ht].
Qed.

Lemma HH_call : forall tk tres cc loc bL a1 a2 a3 R,
    ((loc = surface_collision._height /\ bL = bH)
     \/ (loc = surface_collision._dynamicHeight /\ bL = bD)) ->
    ~ In tk hts -> tk <> surface_collision._y -> tk <> surface_collision._yPos ->
    tk <> surface_collision._pfloor -> tk <> surface_collision._surfaceList ->
    tk <> surface_collision._cellX -> tk <> surface_collision._cellZ ->
    tk <> surface_collision._x -> tk <> surface_collision._z ->
    (forall le M v y h, HH le M -> eval_expr ge e le M a2 v ->
       sem_cast v (typeof a2) tint M = Some y -> hok y h -> Hit_at ge mb h -> HP h) ->
    (forall le M v x, HH le M -> eval_expr ge e le M a1 v ->
       sem_cast v (typeof a1) tint M = Some x -> s16v x) ->
    (forall le M v x, HH le M -> eval_expr ge e le M a3 v ->
       sem_cast v (typeof a3) tint M = Some x -> s16v x) ->
    trh ge e HH
      (Scall (Some tk)
         (Evar surface_collision._find_floor_from_list
            (Tfunction [tptr (Tstruct surface_collision._SurfaceNode noattr); tint; tint; tint;
                        tptr tfloat] tres cc))
         [Etempvar surface_collision._surfaceList
            (tptr (Tstruct surface_collision._SurfaceNode noattr));
          a1; a2; a3; Eaddrof (Evar loc tfloat) (tptr tfloat)])
      HH R.
Proof.
  intros tk tres cc loc bL a1 a2 a3 R Hloc Hn1 Hn2 Hn3 Hn4 Hn5 Hn6 Hn7 Hn8 Hn9 Ha2 Ha1 Ha3.
  intros le M t le' M' out HI H.
  assert (Hn : e ! surface_collision._find_floor_from_list = None) by (apply ffe_other; idne).
  destruct (ffl_call _ _ _ _ _ _ _ _ _ _ _ _ _ HC Hpin Hn H)
    as (node & x & y & z & ph & fl0 & Hargs & -> & -> & Hres).
  left; split; [reflexivity |].
  pose proof (HH_set_other _ _ tk fl0 HI Hn1 Hn2 Hn3 Hn4 Hn5 Hn6 Hn7 Hn8 Hn9) as HI'.
  destruct Hres as [(-> & _) | (Hon & h & Hstv & Hk & Hhit)]; [exact HI' |].
  pose proof HI as (_ & _ & _ & _ & _ & _ & SL & MF).
  repeat match goal with Hl : eval_exprlist _ _ _ _ (_ :: _) _ _ |- _ => inv Hl end.
  (* the list head: a partition head of mb *)
  match goal with Ht : eval_expr _ _ _ _ (Etempvar surface_collision._surfaceList _) _ |- _ =>
    inv Ht; [| match goal with Hl : eval_lvalue _ _ _ _ (Etempvar _ _) _ _ _ |- _ => inv Hl end] end.
  match goal with Hc : sem_cast _ (typeof (Etempvar surface_collision._surfaceList _)) _ _ = Some _ |- _ =>
    cbn [typeof] in Hc; apply cast_ptr_same in Hc; subst end.
  match goal with Hx : le ! surface_collision._surfaceList = Some _ |- _ =>
    destruct (proj1 SL _ Hx) as [-> | FH] end.
  { inv Hon. }
  pose proof (floor_head_part _ _ _ FH) as PH.
  pose proof (ol_transfer _ _ _ (Hwf _ PH) M _ (fun b z Nw => MF Mint32 b z Nw) Hon) as OL.
  destruct (Hsurf _ _ PH OL) as (bs & os & -> & Nws).
  pose proof (hit_transfer M mb bs os _ _ _ (fun ch z => MF ch bs z Nws) Hhit) as Hhit'.
  assert (Sx : s16v x)
    by (match goal with He : eval_expr _ _ _ _ a1 ?v, Hc : sem_cast ?v (typeof a1) tint _ = Some x |- _ =>
          exact (Ha1 _ _ _ _ HI He Hc) end).
  assert (Sz : s16v z)
    by (match goal with He : eval_expr _ _ _ _ a3 ?v, Hc : sem_cast ?v (typeof a3) tint _ = Some z |- _ =>
          exact (Ha3 _ _ _ _ HI He Hc) end).
  assert (Ht : Hit_at ge mb h)
    by (do 4 eexists; split; [exact FH | split; [exact OL | exact (conj Hhit' (conj Sx Sz))]]).
  match goal with He : eval_expr _ _ _ _ a2 ?v, Hc : sem_cast ?v (typeof a2) tint _ = Some ?yy,
                  Hk : hok ?yy h |- _ => pose proof (Ha2 _ _ _ _ _ HI He Hc Hk Ht) as Hh end.
  match goal with Ha : eval_expr _ _ _ _ (Eaddrof _ _) _ |- _ =>
    inv Ha; [| match goal with Hl : eval_lvalue _ _ _ _ (Eaddrof _ _) _ _ _ |- _ => inv Hl end] end.
  match goal with Hl : eval_lvalue _ _ _ _ (Evar _ _) _ _ _ |- _ => inv Hl end;
    [| destruct Hloc as [(-> & _) | (-> & _)];
       [rewrite ffe_H in * | rewrite ffe_D in *]; discriminate].
  match goal with Hx : (ffe _ _) ! loc = Some (?bb, _) |- _ =>
    assert (Eb : bb = bL)
      by (destruct Hloc as [(-> & ->) | (-> & ->)];
          [rewrite ffe_H in Hx | rewrite ffe_D in Hx]; congruence);
    subst bb end.
  match goal with Hc : sem_cast _ (typeof (Eaddrof _ _)) _ _ = Some _ |- _ =>
    cbn [typeof] in Hc; apply cast_ptr_same in Hc; subst end.
  cbn [Mem.storev] in Hstv. rewrite Ptrofs.unsigned_zero in Hstv.
  destruct HI' as (Y & YP & T & CH & CD & PF & SL' & MF').
  assert (MF'' : forall ch b' z, ~ Wr b' -> Mem.load ch M' b' z = Mem.load ch mb b' z).
  { intros ch b' zz Nw. rewrite <- (MF' _ _ _ Nw). eapply Mem.load_store_other; [exact Hstv |].
    left. intros ->. apply Nw.
    destruct Hloc as [(_ & ->) | (_ & ->)]; [left | right; left]; reflexivity. }
  split; [exact Y | split; [exact YP | split; [exact T |]]].
  destruct Hloc as [(-> & ->) | (-> & ->)].
  - split; [| split; [| split; [exact PF | split; [exact SL' | exact MF'']]]].
    + intros h' Hl. rewrite (Mem.load_store_same _ _ _ _ _ _ Hstv) in Hl.
      cbn in Hl. injection Hl as <-. exact Hh.
    + intros h' Hl. erewrite Mem.load_store_other in Hl;
        [exact (CD _ Hl) | exact Hstv | left; exact (not_eq_sym HHD)].
  - split; [| split; [| split; [exact PF | split; [exact SL' | exact MF'']]]].
    + intros h' Hl. erewrite Mem.load_store_other in Hl;
        [exact (CH _ Hl) | exact Hstv | left; exact HHD].
    + intros h' Hl. rewrite (Mem.load_store_same _ _ _ _ _ _ Hstv) in Hl.
      cbn in Hl. injection Hl as <-. exact Hh.
Qed.

Lemma HH_ret : forall tk, In tk hts ->
    trh ge e HH (Sreturn (Some (Etempvar tk tfloat))) HH RH.
Proof.
  intros tk Hk. apply trh_ret. intros le M v (_ & _ & T & _) Hev v' ty Ho.
  injection Ho as <- <-. split; [reflexivity |]. intros h ->.
  inv Hev; [| match goal with Hl : eval_lvalue _ _ _ _ (Etempvar _ _) _ _ _ |- _ => inv Hl end].
  eauto.
Qed.

Ltac cellok := first [left; reflexivity | right; reflexivity].
Ltac locok := first [left; split; reflexivity | right; split; reflexivity].

Ltac solve_trh :=
  lazymatch goal with
  | |- trh _ _ _ (Ssequence _ _) _ _ => eapply (trh_seq _ _ _ _ HH); [solve_trh | solve_trh]
  | |- trh _ _ _ (Sifthenelse _ _ _) _ _ => eapply trh_ite; [solve_trh | solve_trh]
  | |- trh _ _ _ Sskip _ _ => apply trh_skip
  | |- trh _ _ _ (Sreturn _) _ _ => apply HH_ret; inh
  | |- trh _ _ _ (Scall _ _ _) _ _ =>
      eapply HH_call; [locok | nin | idne | idne | idne | idne | idne | idne | idne | idne
                      | first [exact ya_ok | exact yre_ok]
                      | apply xz_arg_ok; left; reflexivity | apply xz_arg_ok; right; reflexivity]
  | |- trh _ _ _ (Sset surface_collision._y _) _ _ => apply HH_set_y
  | |- trh _ _ _ (Sset surface_collision._x _) _ _ => apply HH_set_xz; left; reflexivity
  | |- trh _ _ _ (Sset surface_collision._z _) _ _ => apply HH_set_xz; right; reflexivity
  | |- trh _ _ _ (Sset surface_collision._surfaceList (Efield (Ederef ?A _) _ _)) _ _ =>
      let pid := base_id A in apply (HH_set_sl pid); inh
  | |- trh _ _ _ (Sset surface_collision._cellX _) _ _ => apply HH_set_cell; left; reflexivity
  | |- trh _ _ _ (Sset surface_collision._cellZ _) _ _ => apply HH_set_cell; right; reflexivity
  | |- trh _ _ _ (Sset _ _) _ _ =>
      first [ apply HH_set_ht; [inh | cellok]
            | apply trh_set; let HI := fresh in intros ? ? ? HI _;
              apply HH_set_other; [exact HI | nin | idne | idne | idne | idne | idne | idne
                                  | idne | idne] ]
  | |- trh _ _ _ (Sassign (Ederef (Etempvar surface_collision._pfloor _) _) _) _ _ =>
      apply HH_assign_other; apply lv_pf
  | |- trh _ _ _ (Sassign (Efield _ _ _) _) _ _ =>
      apply HH_assign_other; exact lv_ncf
  | |- trh _ _ _ (Sassign _ _) _ _ =>
      first [ apply HH_assign_cell; [cellok | first [exact c11000_ok | apply ht_rhs_ok; inh]]
            | apply HH_assign_other; apply lv_st; inh ]
  end.

Lemma ff_body_trh : trh ge e HH (fn_body surface_collision.f_find_floor) HH RH.
Proof. cbn [fn_body surface_collision.f_find_floor]. solve_trh. Qed.

(* ---- the floor find_floor reports is NULL, or the height is a hit ---- *)

Definition nn (v : val) : Prop := v = Vundef \/ v = Vint Int.zero.
Definition HitC (b : block) (M : mem) : Prop :=
  exists h, Mem.load Mfloat32 M b 0 = Some (Vsingle h) /\ Hit_at ge mb h.
Definition fr_ids : list ident := [surface_collision._floor; surface_collision._dynamicFloor].

(* floor / dynamicFloor are NULL, or their height cell holds a hit *)
Definition FR (le : temp_env) (M : mem) : Prop :=
  (forall v, le ! surface_collision._dynamicFloor = Some v -> nn v \/ HitC bD M)
  /\ (forall v, le ! surface_collision._floor = Some v -> nn v \/ HitC bH M).
(* before the final store *pfloor is NULL; after it, NULL or height is a hit *)
Definition PF0 (M : mem) : Prop :=
  forall f, Mem.load Mint32 M bpf (Ptrofs.unsigned opf) = Some f -> nn f.
Definition PF1 (M : mem) : Prop :=
  forall f, Mem.load Mint32 M bpf (Ptrofs.unsigned opf) = Some f -> nn f \/ HitC bH M.
Definition HH0 (le : temp_env) (M : mem) : Prop :=
  HH le M /\ le ! surface_collision._floor = Some Vundef
  /\ le ! surface_collision._dynamicFloor = Some Vundef.
Definition HHF (le : temp_env) (M : mem) : Prop := HH le M /\ FR le M /\ PF0 M.
Definition HH1 (le : temp_env) (M : mem) : Prop := HH le M /\ PF1 M.
Definition HHk (tk : ident) (bL : block) (le : temp_env) (M : mem) : Prop :=
  HHF le M /\ forall v, le ! tk = Some v -> nn v \/ HitC bL M.
Definition RHF (out : outcome) (M : mem) : Prop :=
  RH out M /\ forall v ty, out = Out_return (Some (v, ty)) ->
    forall f, Mem.load Mint32 M bpf (Ptrofs.unsigned opf) = Some f ->
      nn f \/ exists h, v = Vsingle h /\ Hit_at ge mb h.

Definition TT (out : outcome) (M : mem) : Prop := True.

Lemma assign_load_other : forall ty M b ofs bf v M' ch b' z,
    assign_loc ge ty M b ofs bf v M' -> b' <> b -> Mem.load ch M' b' z = Mem.load ch M b' z.
Proof.
  intros ty M b ofs bf v M' ch b' z Ha Hn. inv Ha.
  - cbn [Mem.storev] in *. eapply Mem.load_store_other; [eassumption | left; exact Hn].
  - eapply Mem.load_storebytes_other; [eassumption | left; exact Hn].
  - match goal with Hs : ?T |- _ => lazymatch T with context [store_bitfield] => inv Hs end end.
    eapply Mem.load_store_other; [eassumption | left; exact Hn].
Qed.

Lemma HitC_same : forall b M M', Mem.load Mfloat32 M' b 0 = Mem.load Mfloat32 M b 0 ->
  HitC b M -> HitC b M'.
Proof. intros b M M' E (h & Hl & Hh). exists h. rewrite E. auto. Qed.

Lemma static_ne : forall b, is_static ge b -> b <> bH /\ b <> bD /\ b <> bpf.
Proof.
  intros b (id & Hin & Hs). destruct (Hgl id b Hin Hs) as (N1 & N2).
  split; [exact N1 | split; [exact N2 | exact (Hsp id b Hin Hs)]].
Qed.

Lemma normal_set : forall le M x a t le' M' out,
    exec_stmt function_entry2 ge e le M (Sset x a) t le' M' out -> out = Out_normal.
Proof. intros. inv H. reflexivity. Qed.
Lemma normal_assign : forall le M l r t le' M' out,
    exec_stmt function_entry2 ge e le M (Sassign l r) t le' M' out -> out = Out_normal.
Proof. intros. inv H. reflexivity. Qed.

(* a temp set (not floor / dynamicFloor) *)
Lemma lift_set : forall x a R, ~ In x fr_ids ->
    trh ge e HH (Sset x a) HH TT -> trh ge e HHF (Sset x a) HHF R.
Proof.
  intros x a R Hn T le M t le' M' out (HI & (F1 & F2) & P) Hx.
  destruct (T _ _ _ _ _ _ HI Hx) as [(_ & HQ) | (Hne & _)];
    [| exfalso; exact (Hne (normal_set _ _ _ _ _ _ _ _ Hx))].
  inv Hx. left. split; [reflexivity |]. split; [exact HQ |]. split; [| exact P].
  split; intros w Hl; rewrite PTree.gso in Hl by (intro E; apply Hn; rewrite <- E; inh); eauto.
Qed.

Lemma lift_set1 : forall x a R,
    trh ge e HH (Sset x a) HH TT -> trh ge e HH1 (Sset x a) HH1 R.
Proof.
  intros x a R T le M t le' M' out (HI & P) Hx.
  destruct (T _ _ _ _ _ _ HI Hx) as [(_ & HQ) | (Hne & _)];
    [| exfalso; exact (Hne (normal_set _ _ _ _ _ _ _ _ Hx))].
  inv Hx. left. split; [reflexivity |]. split; [exact HQ | exact P].
Qed.

Lemma lift_set0 : forall x a R, ~ In x fr_ids ->
    trh ge e HH (Sset x a) HH TT -> trh ge e HH0 (Sset x a) HH0 R.
Proof.
  intros x a R Hn T le M t le' M' out (HI & F1 & F2) Hx.
  destruct (T _ _ _ _ _ _ HI Hx) as [(_ & HQ) | (Hne & _)];
    [| exfalso; exact (Hne (normal_set _ _ _ _ _ _ _ _ Hx))].
  inv Hx. left. split; [reflexivity |]. split; [exact HQ |].
  split; rewrite PTree.gso by (intro E; apply Hn; rewrite <- E; inh); assumption.
Qed.

Lemma lift_assign0 : forall l r R,
    trh ge e HH (Sassign l r) HH TT -> trh ge e HH0 (Sassign l r) HH0 R.
Proof.
  intros l r R T le M t le' M' out (HI & F1 & F2) Hx.
  destruct (T _ _ _ _ _ _ HI Hx) as [(_ & HQ) | (Hne & _)];
    [| exfalso; exact (Hne (normal_assign _ _ _ _ _ _ _ _ Hx))].
  inv Hx. left. split; [reflexivity |]. split; [exact HQ | split; assumption].
Qed.

(* a store into a static cell *)
Lemma lift_static : forall lhs rhs R,
    (forall le M b ofs bf, eval_lvalue ge e le M lhs b ofs bf -> is_static ge b) ->
    trh ge e HH (Sassign lhs rhs) HH TT ->
    trh ge e HHF (Sassign lhs rhs) HHF R /\ trh ge e HH1 (Sassign lhs rhs) HH1 R.
Proof.
  intros lhs rhs R Hs T. split.
  - intros le M t le' M' out (HI & (F1 & F2) & P) Hx.
    destruct (T _ _ _ _ _ _ HI Hx) as [(_ & HQ) | (Hne & _)];
      [| exfalso; exact (Hne (normal_assign _ _ _ _ _ _ _ _ Hx))].
    inv Hx. left. split; [reflexivity |].
    match goal with Hl : eval_lvalue _ _ _ _ _ ?b _ _, Ha : assign_loc _ _ _ _ _ _ _ _ |- _ =>
      destruct (static_ne b (Hs _ _ _ _ _ Hl)) as (N1 & N2 & N3);
      pose proof (fun ch b' z Hn => assign_load_other _ _ _ _ _ _ _ ch b' z Ha Hn) as K end.
    split; [exact HQ |]. split.
    + split; intros w Hl.
      * destruct (F1 w Hl) as [? | Hc]; [left; assumption | right].
        eapply HitC_same; [apply K; congruence | exact Hc].
      * destruct (F2 w Hl) as [? | Hc]; [left; assumption | right].
        eapply HitC_same; [apply K; congruence | exact Hc].
    + intros f Hl. apply P. rewrite <- (K _ _ _ (not_eq_sym N3)). exact Hl.
  - intros le M t le' M' out (HI & P) Hx.
    destruct (T _ _ _ _ _ _ HI Hx) as [(_ & HQ) | (Hne & _)];
      [| exfalso; exact (Hne (normal_assign _ _ _ _ _ _ _ _ Hx))].
    inv Hx. left. split; [reflexivity |].
    match goal with Hl : eval_lvalue _ _ _ _ _ ?b _ _, Ha : assign_loc _ _ _ _ _ _ _ _ |- _ =>
      destruct (static_ne b (Hs _ _ _ _ _ Hl)) as (N1 & N2 & N3);
      pose proof (fun ch b' z Hn => assign_load_other _ _ _ _ _ _ _ ch b' z Ha Hn) as K end.
    split; [exact HQ |].
    intros f Hl. rewrite (K _ _ _ (not_eq_sym N3)) in Hl.
    destruct (P f Hl) as [? | Hc]; [left; assumption | right].
    eapply HitC_same; [apply K; congruence | exact Hc].
Qed.

Lemma lv_st' : forall x ty, In x ff_statics ->
    forall le M b ofs bf, eval_lvalue ge e le M (Evar x ty) b ofs bf -> is_static ge b.
Proof.
  intros x ty Hin le M b ofs bf Hl.
  destruct (lv_static ge bH bD x le M ty b ofs bf Hin Hl) as (Hs & _ & _).
  exists x. auto.
Qed.

Lemma lv_ncf' : forall le M b ofs bf,
    eval_lvalue ge e le M
      (Efield (Evar surface_collision._gNumCalls (Tstruct surface_collision._NumTimesCalled noattr))
         surface_collision._floor tshort) b ofs bf -> is_static ge b.
Proof.
  intros le M b ofs bf Hl.
  destruct (lv_calls_floor ge bH bD HC le M b ofs bf Hl) as (Hs & _ & _).
  exists surface_collision._gNumCalls. split; [inh | exact Hs].
Qed.

(* a find_floor_from_list call: NULL, or the height it stores is a hit *)
Lemma HHF_call : forall tk tres cc loc bL a1 a2 a3 R,
    ((loc = surface_collision._height /\ bL = bH)
     \/ (loc = surface_collision._dynamicHeight /\ bL = bD)) ->
    ~ In tk fr_ids ->
    trh ge e HH
      (Scall (Some tk)
         (Evar surface_collision._find_floor_from_list
            (Tfunction [tptr (Tstruct surface_collision._SurfaceNode noattr); tint; tint; tint;
                        tptr tfloat] tres cc))
         [Etempvar surface_collision._surfaceList
            (tptr (Tstruct surface_collision._SurfaceNode noattr));
          a1; a2; a3; Eaddrof (Evar loc tfloat) (tptr tfloat)])
      HH TT ->
    (forall le M v x, HH le M -> eval_expr ge e le M a1 v ->
       sem_cast v (typeof a1) tint M = Some x -> s16v x) ->
    (forall le M v x, HH le M -> eval_expr ge e le M a3 v ->
       sem_cast v (typeof a3) tint M = Some x -> s16v x) ->
    trh ge e HHF
      (Scall (Some tk)
         (Evar surface_collision._find_floor_from_list
            (Tfunction [tptr (Tstruct surface_collision._SurfaceNode noattr); tint; tint; tint;
                        tptr tfloat] tres cc))
         [Etempvar surface_collision._surfaceList
            (tptr (Tstruct surface_collision._SurfaceNode noattr));
          a1; a2; a3; Eaddrof (Evar loc tfloat) (tptr tfloat)])
      (HHk tk bL) R.
Proof.
  intros tk tres cc loc bL a1 a2 a3 R Hloc Hn T Ha1 Ha3 le M t le' M' out (HI & (F1 & F2) & P) H.
  assert (Hne : e ! surface_collision._find_floor_from_list = None) by (apply ffe_other; idne).
  destruct (T _ _ _ _ _ _ HI H) as [(_ & HQ) | (Hno & _)].
  2:{ destruct (ffl_call _ _ _ _ _ _ _ _ _ _ _ _ _ HC Hpin Hne H) as (? & ? & ? & ? & ? & ? & _ & Ho & _).
      contradiction. }
  destruct (ffl_call _ _ _ _ _ _ _ _ _ _ _ _ _ HC Hpin Hne H)
    as (node & x & y & z & ph & fl0 & Hargs & -> & -> & Hres).
  left; split; [reflexivity |].
  assert (Ntk : forall i, In i fr_ids -> i <> tk) by (intros i Hi E; subst; contradiction).
  assert (FRset : forall M1, FR le M1 -> FR (PTree.set tk fl0 le) M1).
  { intros M1 (G1 & G2). split; intros w Hl;
      rewrite PTree.gso in Hl by (apply Ntk; inh); eauto. }
  destruct Hres as [(-> & ->) | (Hon & h & Hstv & Hk & Hhit)].
  { split; [split; [exact HQ | split; [exact (FRset _ (conj F1 F2)) | exact P]] |].
    intros w Hl. rewrite PTree.gss in Hl. injection Hl as <-. left; right; reflexivity. }
  pose proof HI as (_ & _ & _ & _ & _ & _ & SL & MF).
  repeat match goal with Hl : eval_exprlist _ _ _ _ (_ :: _) _ _ |- _ => inv Hl end.
  match goal with Ht : eval_expr _ _ _ _ (Etempvar surface_collision._surfaceList _) _ |- _ =>
    inv Ht; [| match goal with Hl : eval_lvalue _ _ _ _ (Etempvar _ _) _ _ _ |- _ => inv Hl end] end.
  match goal with Hc : sem_cast _ (typeof (Etempvar surface_collision._surfaceList _)) _ _ = Some _ |- _ =>
    cbn [typeof] in Hc; apply cast_ptr_same in Hc; subst end.
  match goal with Hx : le ! surface_collision._surfaceList = Some _ |- _ =>
    destruct (proj1 SL _ Hx) as [-> | FH] end.
  { inv Hon. }
  pose proof (floor_head_part _ _ _ FH) as PH.
  pose proof (ol_transfer _ _ _ (Hwf _ PH) M _ (fun b z Nw => MF Mint32 b z Nw) Hon) as OL.
  destruct (Hsurf _ _ PH OL) as (bs & os & -> & Nws).
  pose proof (hit_transfer M mb bs os _ _ _ (fun ch z => MF ch bs z Nws) Hhit) as Hhit'.
  assert (Sx : s16v x)
    by (match goal with He : eval_expr _ _ _ _ a1 ?v, Hc : sem_cast ?v (typeof a1) tint _ = Some x |- _ =>
          exact (Ha1 _ _ _ _ HI He Hc) end).
  assert (Sz : s16v z)
    by (match goal with He : eval_expr _ _ _ _ a3 ?v, Hc : sem_cast ?v (typeof a3) tint _ = Some z |- _ =>
          exact (Ha3 _ _ _ _ HI He Hc) end).
  assert (Ht : Hit_at ge mb h)
    by (do 4 eexists; split; [exact FH | split; [exact OL | exact (conj Hhit' (conj Sx Sz))]]).
  match goal with Ha : eval_expr _ _ _ _ (Eaddrof _ _) _ |- _ =>
    inv Ha; [| match goal with Hl : eval_lvalue _ _ _ _ (Eaddrof _ _) _ _ _ |- _ => inv Hl end] end.
  match goal with Hl : eval_lvalue _ _ _ _ (Evar _ _) _ _ _ |- _ => inv Hl end;
    [| destruct Hloc as [(-> & _) | (-> & _)];
       [rewrite ffe_H in * | rewrite ffe_D in *]; discriminate].
  match goal with Hx : (ffe _ _) ! loc = Some (?bb, _) |- _ =>
    assert (Eb : bb = bL)
      by (destruct Hloc as [(-> & ->) | (-> & ->)];
          [rewrite ffe_H in Hx | rewrite ffe_D in Hx]; congruence);
    subst bb end.
  match goal with Hc : sem_cast _ (typeof (Eaddrof _ _)) _ _ = Some _ |- _ =>
    cbn [typeof] in Hc; apply cast_ptr_same in Hc; subst end.
  cbn [Mem.storev] in Hstv. rewrite Ptrofs.unsigned_zero in Hstv.
  assert (Cnew : HitC bL M').
  { exists h. split; [| exact Ht]. rewrite (Mem.load_store_same _ _ _ _ _ _ Hstv). reflexivity. }
  assert (K : forall ch b zz, b <> bL -> Mem.load ch M' b zz = Mem.load ch M b zz)
    by (intros ch b zz Hb; eapply Mem.load_store_other; [exact Hstv | left; exact Hb]).
  assert (Keep : forall b, b = bH \/ b = bD -> HitC b M -> HitC b M').
  { intros b Hb Hc. destruct (peq b bL) as [-> | Hne'];
      [exact Cnew | eapply HitC_same; [exact (K _ _ _ Hne') | exact Hc]]. }
  assert (NpL : bpf <> bL) by (destruct Hloc as [(_ & ->) | (_ & ->)]; assumption).
  split.
  - split; [exact HQ |]. split.
    + apply FRset. split; intros w Hl.
      * destruct (F1 w Hl) as [? | Hc]; [left; assumption | right; apply Keep; auto].
      * destruct (F2 w Hl) as [? | Hc]; [left; assumption | right; apply Keep; auto].
    + intros f Hl. apply P. rewrite <- (K _ _ _ NpL). exact Hl.
  - intros w Hl. rewrite PTree.gss in Hl. injection Hl as <-. right. exact Cnew.
Qed.

(* floor / dynamicFloor := the call's result *)
Lemma HHF_take : forall d tk ty bL R,
    ((d = surface_collision._dynamicFloor /\ bL = bD) \/ (d = surface_collision._floor /\ bL = bH)) ->
    trh ge e HH (Sset d (Etempvar tk ty)) HH TT ->
    trh ge e (HHk tk bL) (Sset d (Etempvar tk ty)) HHF R.
Proof.
  intros d tk ty bL R Hd T le M t le' M' out ((HI & (F1 & F2) & P) & Kt) Hx.
  destruct (T _ _ _ _ _ _ HI Hx) as [(_ & HQ) | (Hne & _)];
    [| exfalso; exact (Hne (normal_set _ _ _ _ _ _ _ _ Hx))].
  inv Hx.
  match goal with Ht : eval_expr _ _ _ _ (Etempvar _ _) _ |- _ =>
    inv Ht; [| match goal with Hl : eval_lvalue _ _ _ _ (Etempvar _ _) _ _ _ |- _ => inv Hl end] end.
  left. split; [reflexivity |]. split; [exact HQ |]. split; [| exact P].
  destruct Hd as [(-> & ->) | (-> & ->)]; split; intros w Hl.
  - rewrite PTree.gss in Hl. injection Hl as <-. auto.
  - rewrite PTree.gso in Hl by idne. eauto.
  - rewrite PTree.gso in Hl by idne. eauto.
  - rewrite PTree.gss in Hl. injection Hl as <-. auto.
Qed.

Local Notation SF := (Tstruct surface_collision._Surface noattr).

Lemma ev_height_var : forall le M x b w,
    (x = surface_collision._height /\ b = bH) \/ (x = surface_collision._dynamicHeight /\ b = bD) ->
    eval_expr ge e le M (Evar x tfloat) w -> Mem.load Mfloat32 M b 0 = Some w.
Proof.
  intros le M x b w Hx H.
  inv H. match goal with Hl : eval_lvalue _ _ _ _ (Evar _ _) _ _ _ |- _ => inv Hl end.
  - match goal with Hd : deref_loc _ _ _ _ _ _ |- _ => inv Hd end; cbn in *; try discriminate.
    match goal with Ha : By_value _ = By_value _ |- _ => inv Ha end.
    match goal with Hl : Mem.load _ _ _ _ = Some _, He : e ! x = Some _ |- _ =>
      rewrite Ptrofs.unsigned_zero in Hl; destruct Hx as [(-> & ->) | (-> & ->)];
      [rewrite ffe_H in He | rewrite ffe_D in He]; inv He; exact Hl end.
  - destruct Hx as [(-> & _) | (-> & _)]; [rewrite ffe_H in * | rewrite ffe_D in *]; discriminate.
Qed.

Definition swap_blk (ty1 : type) : statement :=
  Ssequence (Sset surface_collision._floor (Etempvar surface_collision._dynamicFloor ty1))
    (Ssequence (Sset surface_collision._t'11 (Evar surface_collision._dynamicHeight tfloat))
       (Sassign (Evar surface_collision._height tfloat) (Etempvar surface_collision._t'11 tfloat))).

Lemma swap_exec : forall ty1 le M t le' M' out,
    exec_stmt function_entry2 ge e le M (swap_blk ty1) t le' M' out ->
    out = Out_normal /\ exists v0 w w',
      le ! surface_collision._dynamicFloor = Some v0 /\ Mem.load Mfloat32 M bD 0 = Some w
      /\ sem_cast w tfloat tfloat M = Some w' /\ Mem.store Mfloat32 M bH 0 w' = Some M'
      /\ le' = PTree.set surface_collision._t'11 w (PTree.set surface_collision._floor v0 le).
Proof.
  intros ty1 le M t le' M' out H. unfold swap_blk in H.
  inv H; [| match goal with H1 : exec_stmt _ _ _ _ _ (Sset _ _) _ _ _ ?o, Hn : ?o <> Out_normal |- _ =>
             apply normal_set in H1; contradiction end].
  match goal with H2 : exec_stmt _ _ _ _ _ (Ssequence _ _) _ _ _ _ |- _ =>
    inv H2; [| match goal with H1 : exec_stmt _ _ _ _ _ (Sset _ _) _ _ _ ?o, Hn : ?o <> Out_normal |- _ =>
                apply normal_set in H1; contradiction end] end.
  repeat match goal with Hs : exec_stmt _ _ _ _ _ (Sset _ _) _ _ _ _ |- _ => inv Hs end.
  match goal with Ha : exec_stmt _ _ _ _ _ (Sassign _ _) _ _ _ _ |- _ => inv Ha end.
  split; [reflexivity |].
  match goal with Ht : eval_expr _ _ _ _ (Etempvar surface_collision._dynamicFloor _) ?v0 |- _ =>
    inv Ht; [| match goal with Hl : eval_lvalue _ _ _ _ (Etempvar _ _) _ _ _ |- _ => inv Hl end] end.
  match goal with Hd : eval_expr _ _ _ _ (Evar surface_collision._dynamicHeight _) ?w |- _ =>
    pose proof (ev_height_var _ _ _ _ _ (or_intror (conj eq_refl eq_refl)) Hd) as Lw end.
  match goal with Ht : eval_expr _ _ _ _ (Etempvar surface_collision._t'11 _) _ |- _ =>
    inv Ht; [| match goal with Hl : eval_lvalue _ _ _ _ (Etempvar _ _) _ _ _ |- _ => inv Hl end] end.
  match goal with Hx : (PTree.set _ _ _) ! surface_collision._t'11 = Some _ |- _ =>
    rewrite PTree.gss in Hx; injection Hx as <- end.
  match goal with Hl : eval_lvalue _ _ _ _ (Evar surface_collision._height _) _ _ _ |- _ =>
    inv Hl; [| rewrite ffe_H in *; discriminate] end.
  match goal with He : e ! surface_collision._height = Some _ |- _ => rewrite ffe_H in He; inv He end.
  match goal with Ha : assign_loc _ _ _ _ _ _ _ _ |- _ => inv Ha; cbn in *; try discriminate end.
  match goal with Ha : By_value _ = By_value _ |- _ => inv Ha end.
  cbn [Mem.storev] in *. rewrite Ptrofs.unsigned_zero in *.
  do 3 eexists. split; [eassumption | split; [exact Lw | split; [eassumption | split; [eassumption |]]]].
  reflexivity.
Qed.

(* if (dynamicHeight > height) { floor = dynamicFloor; height = dynamicHeight; } *)
Lemma HHF_swap : forall ty1 R,
    trh ge e HH (swap_blk ty1) HH TT -> trh ge e HHF (swap_blk ty1) HHF R.
Proof.
  intros ty1 R T le M t le' M' out (HI & (F1 & F2) & P) H.
  destruct (swap_exec _ _ _ _ _ _ _ H) as (-> & v0 & w & w' & Hd & Lw & Cw & Sw & ->).
  destruct (T _ _ _ _ _ _ HI H) as [(_ & HQ) | (Hne & _)]; [| congruence].
  left. split; [reflexivity |]. split; [exact HQ |].
  assert (K : forall ch b z, b <> bH -> Mem.load ch M' b z = Mem.load ch M b z)
    by (intros ch b z Hb; eapply Mem.load_store_other; [exact Sw | left; exact Hb]).
  split; [split; intros u Hl |].
  - rewrite PTree.gso in Hl by idne. rewrite PTree.gso in Hl by idne.
    destruct (F1 u Hl) as [? | Hc]; [left; assumption | right].
    eapply HitC_same; [exact (K _ _ _ (not_eq_sym HHD)) | exact Hc].
  - rewrite PTree.gso in Hl by idne. rewrite PTree.gss in Hl. injection Hl as <-.
    destruct (F1 v0 Hd) as [? | (h & Lh & Hh)]; [left; assumption | right].
    rewrite Lw in Lh. injection Lh as ->. cbn in Cw. injection Cw as <-.
    exists h. split; [| exact Hh]. rewrite (Mem.load_store_same _ _ _ _ _ _ Sw). reflexivity.
  - intros f Hl. apply P. rewrite <- (K _ _ _ HpH). exact Hl.
Qed.

Definition pf_lhs : expr :=
  Ederef (Etempvar surface_collision._pfloor (tptr (tptr SF))) (tptr SF).

Lemma pf_exec : forall rhs le M t le' M' out,
    HH le M -> exec_stmt function_entry2 ge e le M (Sassign pf_lhs rhs) t le' M' out ->
    out = Out_normal /\ le' = le /\ exists v v', eval_expr ge e le M rhs v
      /\ sem_cast v (typeof rhs) (tptr SF) M = Some v'
      /\ Mem.store Mint32 M bpf (Ptrofs.unsigned opf) v' = Some M'.
Proof.
  intros rhs le M t le' M' out (_ & _ & _ & _ & _ & Hp & _) H. inv H.
  split; [reflexivity | split; [reflexivity |]].
  match goal with Hl : eval_lvalue _ _ _ _ pf_lhs _ _ _ |- _ => unfold pf_lhs in Hl; inv Hl end.
  match goal with Ht : eval_expr _ _ _ _ (Etempvar _ _) _ |- _ =>
    inv Ht; [| match goal with Hl : eval_lvalue _ _ _ _ (Etempvar _ _) _ _ _ |- _ => inv Hl end] end.
  match goal with Hx : _ ! surface_collision._pfloor = Some (Vptr ?l _) |- _ =>
    lazymatch l with bpf => fail | _ => rewrite Hp in Hx; inv Hx end end.
  unfold pf_lhs in *. cbn [typeof] in *.
  match goal with Ha : assign_loc _ _ _ _ _ _ _ _ |- _ => inv Ha; cbn in *; try discriminate end.
  match goal with Ha : By_value _ = By_value _ |- _ => inv Ha end.
  do 2 eexists. split; [eassumption | split; [eassumption | eassumption]].
Qed.

(* *pfloor = NULL, the first store: every later state has *pfloor NULL *)
Lemma pf_null : forall R,
    trh ge e HH (Sassign pf_lhs (Ecast (Econst_int (Int.repr 0) tint) (tptr tvoid))) HH TT ->
    trh ge e HH0 (Sassign pf_lhs (Ecast (Econst_int (Int.repr 0) tint) (tptr tvoid))) HHF R.
Proof.
  intros R T le M t le' M' out (HI & U1 & U2) H.
  destruct (pf_exec _ _ _ _ _ _ _ HI H) as (-> & -> & v & v' & Hev & Hc & Hs).
  destruct (T _ _ _ _ _ _ HI H) as [(_ & HQ) | (Hne & _)]; [| congruence].
  left. split; [reflexivity |]. split; [exact HQ |].
  inv Hev; [| match goal with Hl : eval_lvalue _ _ _ _ (Ecast _ _) _ _ _ |- _ => inv Hl end].
  match goal with Hk : eval_expr _ _ _ _ (Econst_int _ _) _ |- _ =>
    inv Hk; [| match goal with Hl : eval_lvalue _ _ _ _ (Econst_int _ _) _ _ _ |- _ => inv Hl end] end.
  match goal with Hc1 : sem_cast (Vint _) _ _ _ = Some _ |- _ => cbn in Hc1; injection Hc1 as <- end.
  cbn in Hc. injection Hc as <-.
  split; [split; intros u Hl; left |].
  - rewrite U2 in Hl. injection Hl as <-. left; reflexivity.
  - rewrite U1 in Hl. injection Hl as <-. left; reflexivity.
  - intros f Hl. rewrite (Mem.load_store_same _ _ _ _ _ _ Hs) in Hl. injection Hl as <-.
    right. reflexivity.
Qed.

(* *pfloor = floor, the last store *)
Lemma pf_floor : forall R,
    trh ge e HH (Sassign pf_lhs (Etempvar surface_collision._floor (tptr SF))) HH TT ->
    trh ge e HHF (Sassign pf_lhs (Etempvar surface_collision._floor (tptr SF))) HH1 R.
Proof.
  intros R T le M t le' M' out (HI & (F1 & F2) & P) H.
  destruct (pf_exec _ _ _ _ _ _ _ HI H) as (-> & -> & v & v' & Hev & Hc & Hs).
  destruct (T _ _ _ _ _ _ HI H) as [(_ & HQ) | (Hne & _)]; [| congruence].
  left. split; [reflexivity |]. split; [exact HQ |].
  inv Hev; [| match goal with Hl : eval_lvalue _ _ _ _ (Etempvar _ _) _ _ _ |- _ => inv Hl end].
  cbn [typeof] in Hc. apply cast_ptr_same in Hc. subst v'.
  intros f Hl. rewrite (Mem.load_store_same _ _ _ _ _ _ Hs) in Hl. injection Hl as <-.
  match goal with Hx : le ! surface_collision._floor = Some _ |- _ => destruct (F2 _ Hx) as [N | Hc] end.
  - left. destruct N as [-> | ->]; [left | right]; reflexivity.
  - right. eapply HitC_same; [| exact Hc].
    eapply Mem.load_store_other; [exact Hs | left; exact (not_eq_sym HpH)].
Qed.

Definition ret_blk (tk : ident) : statement :=
  Ssequence (Sset tk (Evar surface_collision._height tfloat))
    (Sreturn (Some (Etempvar tk tfloat))).

Lemma ret_exec : forall tk le M t le' M' out,
    exec_stmt function_entry2 ge e le M (ret_blk tk) t le' M' out ->
    M' = M /\ exists v, Mem.load Mfloat32 M bH 0 = Some v /\ out = Out_return (Some (v, tfloat)).
Proof.
  intros tk le M t le' M' out H. unfold ret_blk in H.
  inv H; [| match goal with H1 : exec_stmt _ _ _ _ _ (Sset _ _) _ _ _ ?o, Hn : ?o <> Out_normal |- _ =>
             apply normal_set in H1; contradiction end].
  match goal with Hs : exec_stmt _ _ _ _ _ (Sset _ _) _ _ _ _ |- _ => inv Hs end.
  match goal with Hr : exec_stmt _ _ _ _ _ (Sreturn _) _ _ _ _ |- _ => inv Hr end.
  match goal with Ht : eval_expr _ _ _ _ (Etempvar _ _) _ |- _ =>
    inv Ht; [| match goal with Hl : eval_lvalue _ _ _ _ (Etempvar _ _) _ _ _ |- _ => inv Hl end] end.
  match goal with Hx : (PTree.set _ _ _) ! _ = Some _ |- _ => rewrite PTree.gss in Hx; injection Hx as <- end.
  split; [reflexivity |].
  match goal with Hd : eval_expr _ _ _ _ (Evar surface_collision._height _) ?w |- _ =>
    exists w; split; [exact (ev_height_var _ _ _ _ _ (or_introl (conj eq_refl eq_refl)) Hd) | reflexivity] end.
Qed.

Lemma ret_F : forall tk Q, trh ge e HH (ret_blk tk) HH RH -> trh ge e HHF (ret_blk tk) Q RHF.
Proof.
  intros tk Q T le M t le' M' out (HI & _ & P) H.
  destruct (ret_exec _ _ _ _ _ _ _ H) as (-> & v & Lv & ->).
  destruct (T _ _ _ _ _ _ HI H) as [(Ho & _) | (Hne & HR)]; [discriminate Ho |].
  right. split; [exact Hne |]. split; [exact HR |].
  intros v' ty E f Hl. left. exact (P f Hl).
Qed.

Lemma ret_1 : forall tk Q, trh ge e HH (ret_blk tk) HH RH -> trh ge e HH1 (ret_blk tk) Q RHF.
Proof.
  intros tk Q T le M t le' M' out (HI & P) H.
  destruct (ret_exec _ _ _ _ _ _ _ H) as (-> & v & Lv & ->).
  destruct (T _ _ _ _ _ _ HI H) as [(Ho & _) | (Hne & HR)]; [discriminate Ho |].
  right. split; [exact Hne |]. split; [exact HR |].
  intros v' ty E f Hl. injection E as <- <-.
  destruct (P f Hl) as [N | (h & Lh & Hh)]; [left; exact N | right].
  rewrite Lv in Lh. injection Lh as ->. exists h. auto.
Qed.

Lemma lift_staticF : forall lhs rhs R,
    (forall le M b ofs bf, eval_lvalue ge e le M lhs b ofs bf -> is_static ge b) ->
    trh ge e HH (Sassign lhs rhs) HH TT -> trh ge e HHF (Sassign lhs rhs) HHF R.
Proof. intros. apply lift_static; assumption. Qed.
Lemma lift_static1 : forall lhs rhs R,
    (forall le M b ofs bf, eval_lvalue ge e le M lhs b ofs bf -> is_static ge b) ->
    trh ge e HH (Sassign lhs rhs) HH TT -> trh ge e HH1 (Sassign lhs rhs) HH1 R.
Proof. intros. apply lift_static; assumption. Qed.

Ltac lvF := first [exact lv_ncf' | apply lv_st'; inh].

Ltac solve_1 :=
  lazymatch goal with
  | |- trh _ _ _ (Ssequence (Sset ?tk (Evar surface_collision._height _)) (Sreturn _)) _ _ =>
      apply (ret_1 tk); unfold ret_blk; solve_trh
  | |- trh _ _ _ (Ssequence _ _) _ _ => eapply (trh_seq _ _ _ _ HH1); [solve_1 | solve_1]
  | |- trh _ _ _ (Sset _ _) _ _ => apply lift_set1; solve_trh
  | |- trh _ _ _ (Sassign _ _) _ _ => apply lift_static1; [lvF | solve_trh]
  end.

Ltac solve_F :=
  lazymatch goal with
  | |- trh _ _ _ (Ssequence (Sset surface_collision._floor
                     (Etempvar surface_collision._dynamicFloor ?t)) _) _ _ =>
      apply (HHF_swap t); unfold swap_blk; solve_trh
  | |- trh _ _ _ (Ssequence (Sassign (Ederef (Etempvar surface_collision._pfloor _) _) _) _) _ _ =>
      eapply (trh_seq _ _ _ _ HH1); [apply pf_floor; unfold pf_lhs; solve_trh | solve_1]
  | |- trh _ _ _ (Ssequence (Sset ?tk (Evar surface_collision._height _)) (Sreturn _)) _ _ =>
      apply (ret_F tk); unfold ret_blk; solve_trh
  | |- trh _ _ _ (Ssequence (Scall (Some _) _ _) (Sset _ _)) _ _ =>
      eapply trh_seq; [eapply HHF_call; [locok | nin | solve_trh
                                         | apply xz_arg_ok; left; reflexivity
                                         | apply xz_arg_ok; right; reflexivity]
                      | eapply HHF_take; [locok | solve_trh]]
  | |- trh _ _ _ (Ssequence (Ssequence _ (Scall (Some _) _ _)) (Sset _ _)) _ _ =>
      eapply trh_seq;
        [eapply trh_seq; [solve_F | eapply HHF_call; [locok | nin | solve_trh
                                         | apply xz_arg_ok; left; reflexivity
                                         | apply xz_arg_ok; right; reflexivity]]
        | eapply HHF_take; [locok | solve_trh]]
  | |- trh _ _ _ (Ssequence _ _) _ _ => eapply (trh_seq _ _ _ _ HHF); [solve_F | solve_F]
  | |- trh _ _ _ (Sifthenelse _ _ _) _ _ => eapply trh_ite; [solve_F | solve_F]
  | |- trh _ _ _ Sskip _ _ => apply trh_skip
  | |- trh _ _ _ (Sset _ _) _ _ => apply lift_set; [nin | solve_trh]
  | |- trh _ _ _ (Sassign _ _) _ _ => apply lift_staticF; [lvF | solve_trh]
  end.

(* THE BODY, with the floor relation: every return is RHF *)
Lemma ff_body_trhF : trh ge e HH0 (fn_body surface_collision.f_find_floor) HHF RHF.
Proof.
  cbn [fn_body surface_collision.f_find_floor].
  eapply (trh_seq _ _ _ _ HH0); [apply lift_assign0; solve_trh |].
  eapply (trh_seq _ _ _ _ HH0); [apply lift_assign0; solve_trh |].
  do 3 (eapply (trh_seq _ _ _ _ HH0); [apply lift_set0; [nin | solve_trh] |]).
  eapply (trh_seq _ _ _ _ HHF); [apply pf_null; unfold pf_lhs; solve_trh |].
  solve_F.
Qed.





End FH.

(* THE VALUE: whatever find_floor returns is in HPi for the s16 cast of its
   yPos argument, where every stored height is a hit on a surface of a
   partition list of the entry memory. *)
Theorem ff_height : forall (ge : genv), cenv_has ge -> ffl_pinned ge ->
    forall m xv yv zv bpf opf t m' vres,
      Mem.valid_block m bpf ->
      (forall id b, In id ff_statics -> Genv.find_symbol ge id = Some b -> Mem.valid_block m b) ->
      (forall id bp, In id part_ids -> Genv.find_symbol ge id = Some bp ->
         Mem.valid_block m bp /\ ~ is_static ge bp /\ bp <> bpf) ->
      (forall hd, part_head ge m hd -> wf_list m (fun b => is_static ge b \/ b = bpf) hd) ->
      (forall hd s, part_head ge m hd -> on_list m hd s ->
         exists b o, s = Vptr b o /\ Mem.valid_block m b /\ ~ is_static ge b /\ b <> bpf) ->
      (forall id b, In id ff_statics -> Genv.find_symbol ge id = Some b -> b <> bpf) ->
      eval_funcall function_entry2 ge m (Internal surface_collision.f_find_floor)
        [xv; yv; zv; Vptr bpf opf] t m' vres ->
      exists h, vres = Vsingle h /\ HPi (Hit_at ge m) (ycast yv) h
        /\ forall f, Mem.loadv Mint32 m' (Vptr bpf opf) = Some f -> nn f \/ Hit_at ge m h.
Proof.
  intros ge HC Hpin m xv yv zv bpf opf t m' vres Hpv Hsv Hpt Hwfm Hsm Hsp H.
  inv H.
  match goal with He : function_entry2 _ _ _ _ _ _ _ |- _ => inv He end.
  match goal with Ha : alloc_variables _ _ _ _ _ _ |- _ =>
    cbn [surface_collision.f_find_floor fn_vars] in Ha; inv Ha end.
  match goal with Ha : alloc_variables _ _ _ _ _ _ |- _ => inv Ha end.
  match goal with Ha : alloc_variables _ _ _ [] _ _ |- _ => inv Ha end.
  match goal with
  | A1 : Mem.alloc m 0 _ = (?M1, ?b1), A2 : Mem.alloc ?M1 0 _ = (?M2, ?b2) |- _ =>
      rename b1 into bH, b2 into bD, A1 into HA1, A2 into HA2, M1 into mA, M2 into mB
  end.
  assert (HnvH : ~ Mem.valid_block m bH) by exact (Mem.fresh_block_alloc _ _ _ _ _ HA1).
  assert (HnvD : ~ Mem.valid_block m bD)
    by (intro HH; exact (Mem.fresh_block_alloc _ _ _ _ _ HA2 (Mem.valid_block_alloc _ _ _ _ _ HA1 _ HH))).
  assert (HHD : bH <> bD)
    by (intros E; subst; exact (Mem.fresh_block_alloc _ _ _ _ _ HA2 (Mem.valid_new_block _ _ _ _ _ HA1))).
  assert (Vne : forall b, Mem.valid_block m b -> b <> bH /\ b <> bD)
    by (intros b Hb; split; intros ->; contradiction).
  assert (Hgl : forall id b, In id ff_statics -> Genv.find_symbol ge id = Some b -> b <> bH /\ b <> bD)
    by (intros id b Hin Hs; exact (Vne b (Hsv id b Hin Hs))).
  (* old blocks read the same in mB *)
  assert (LU : forall ch b z, Mem.valid_block m b -> Mem.load ch mB b z = Mem.load ch m b z).
  { intros ch b z Hb.
    rewrite (Mem.load_alloc_unchanged _ _ _ _ _ HA2 _ _ _ (Mem.valid_block_alloc _ _ _ _ _ HA1 _ Hb)).
    exact (Mem.load_alloc_unchanged _ _ _ _ _ HA1 _ _ _ Hb). }
  set (Wr0 := fun b => b = bH \/ b = bD \/ b = bpf \/ is_static ge b).
  assert (PH : forall hd, part_head ge mB hd <-> part_head ge m hd).
  { intros hd; split; intros (id & bp & o & Hin & Hs & Hl); exists id, bp, o;
      (split; [exact Hin | split; [exact Hs |]]); cbn [Mem.loadv] in *;
      destruct (Hpt id bp Hin Hs) as (Vb & _);
      [rewrite <- (LU _ _ _ Vb) | rewrite (LU _ _ _ Vb)]; exact Hl. }
  assert (WFm : forall hd, part_head ge m hd ->
                  wf_list m (fun b => is_static ge b \/ b = bpf \/ ~ Mem.valid_block m b) hd).
  { intros hd P. eapply wf_weaken; [exact (Hwfm hd P) |].
    intros b Vb Na [Hs | [Hb | Hn]]; [apply Na; left; exact Hs | apply Na; right; exact Hb | exact (Hn Vb)]. }
  assert (OLm : forall hd s, part_head ge m hd -> on_list mB hd s -> on_list m hd s).
  { intros hd s P OL. eapply ol_transfer; [exact (WFm hd P) | | exact OL].
    intros b z Nw. apply LU. destruct (Coqlib.plt b (Mem.nextblock m)) as [V | V]; [exact V |].
    exfalso. apply Nw. right; right. exact V. }
  assert (FHm : forall hd, floor_head ge mB hd -> floor_head ge m hd).
  { intros hd (id & bp & z & x & Hin & Hs & Rz & Rx & Hl); exists id, bp, z, x;
      do 4 (split; [assumption |]); cbn [Mem.loadv] in *;
      destruct (Hpt id bp Hin Hs) as (Vb & _); rewrite <- (LU _ _ _ Vb); exact Hl. }
  assert (Hit_back : forall h, Hit_at ge mB h -> Hit_at ge m h).
  { intros h (hd & s & x & z & F & OL & Ht).
    apply FHm in F. pose proof (floor_head_part _ _ _ F) as P.
    pose proof (OLm _ _ P OL) as OL'.
    destruct (Hsm _ _ P OL') as (b & o & -> & Vb & _ & _).
    exists hd, (Vptr b o), x, z. split; [exact F | split; [exact OL' |]].
    exact (hit16_transfer mB m b o x z h (fun ch z' => LU ch b z' Vb) Ht). }
  (* the section's hypotheses, at mb := mB *)
  assert (Hpart : forall id bp, In id part_ids -> Genv.find_symbol ge id = Some bp -> ~ Wr0 bp).
  { intros id bp Hin Hs. destruct (Hpt id bp Hin Hs) as (Vb & Ns & Np).
    destruct (Vne _ Vb) as (N1 & N2).
    intros [E | [E | [E | E]]]; [exact (N1 E) | exact (N2 E) | exact (Np E) | exact (Ns E)]. }
  assert (Hwf : forall hd, part_head ge mB hd -> wf_list mB Wr0 hd).
  { intros hd P. apply PH in P. pose proof (Hwfm hd P) as W.
    clear P. induction W as [| bn on nx Hv Hav Hld W IH]; [constructor |].
    apply wf_cons with nx.
    - exact (Mem.valid_block_alloc _ _ _ _ _ HA2 _ (Mem.valid_block_alloc _ _ _ _ _ HA1 _ Hv)).
    - destruct (Vne _ Hv) as (N1 & N2).
      intros [E | [E | [E | E]]]; [exact (N1 E) | exact (N2 E) | apply Hav; right; exact E
                                    | apply Hav; left; exact E].
    - cbn [Mem.loadv] in *. rewrite (LU _ _ _ Hv). exact Hld.
    - exact IH. }
  assert (Hsurf : forall hd s, part_head ge mB hd -> on_list mB hd s ->
                    exists b o, s = Vptr b o /\ ~ Wr0 b).
  { intros hd s P OL. apply PH in P. pose proof (OLm _ _ P OL) as OL'.
    destruct (Hsm _ _ P OL') as (b & o & -> & Vb & Ns & Np).
    exists b, o. split; [reflexivity |]. destruct (Vne _ Vb) as (N1 & N2).
    intros [E | [E | [E | E]]]; [exact (N1 E) | exact (N2 E) | exact (Np E) | exact (Ns E)]. }
  destruct (Vne _ Hpv) as (HpH & HpD).
  match goal with Hb : bind_parameter_temps _ _ _ = Some ?L |- _ =>
    assert (HI : HH ge bH bD bpf opf mB (ycast yv) L mB);
    [cbn [bind_parameter_temps surface_collision.f_find_floor fn_params] in Hb; injection Hb as <- |]
  end.
  { split; [right; reflexivity |].
    split; [exists yv; split; reflexivity |].
    split.
    { intros id h Hin Hl. cbv in Hin.
      repeat (destruct Hin as [<- | Hin]; [cbv in Hl; discriminate Hl |]). contradiction. }
    split.
    { intros h Hl.
      rewrite (Mem.load_alloc_unchanged _ _ _ _ _ HA2 _ _ _ (Mem.valid_new_block _ _ _ _ _ HA1)) in Hl.
      apply (Mem.load_alloc_same _ _ _ _ _ HA1) in Hl. discriminate Hl. }
    split.
    { intros h Hl. apply (Mem.load_alloc_same _ _ _ _ _ HA2) in Hl. discriminate Hl. }
    split; [reflexivity |].
    split; [split; [intros sl Hl; left; cbv in Hl; injection Hl as <-; reflexivity
                   | split; intros c v Hc Hl; left; destruct Hc as [-> | ->]; cbv in Hl;
                     injection Hl as <-; reflexivity] |].
    intros; reflexivity. }
  match goal with Hb : bind_parameter_temps _ _ _ = Some ?L |- _ =>
    assert (HI0 : HH0 ge bH bD bpf opf mB (ycast yv) L mB);
    [split; [exact HI |];
     cbn [bind_parameter_temps surface_collision.f_find_floor fn_params] in Hb; injection Hb as <-;
     split; reflexivity |]
  end.
  match goal with Hx : exec_stmt _ _ _ _ _ _ _ _ _ _ |- _ =>
    destruct (ff_body_trhF ge bH bD bpf opf mB HC Hpin HHD HpH HpD Hgl Hsp Hpart Hwf Hsurf (ycast yv)
                _ _ _ _ _ _ HI0 Hx)
      as [(-> & _) | (_ & HR & HF)] end.
  { match goal with Ho : outcome_result_value _ _ _ _ |- _ => cbn in Ho; contradiction end. }
  match goal with Ho : outcome_result_value _ _ _ _ |- _ =>
    cbn [fn_return surface_collision.f_find_floor] in Ho; rename Ho into HO end.
  destruct out as [| | | [[v ty]|]]; cbn in HO; try contradiction.
  destruct HO as (_ & Hc).
  destruct (HR v ty eq_refl) as (-> & Hv).
  pose proof (HF _ _ eq_refl) as HF'.
  destruct v; cbn in Hc; try discriminate Hc. injection Hc as <-.
  exists f. split; [reflexivity |].
  split; [exact (HPi_mono _ _ _ _ Hit_back (Hv f eq_refl)) |].
  (* the frees of height / dynamicHeight leave *pfloor alone *)
  assert (NpH : bpf <> bH) by exact HpH. assert (NpD : bpf <> bD) by exact HpD.
  match goal with Hf : Mem.free_list ?M _ = Some ?R |- _ =>
    first [ change (Mem.free_list M [(bH, 0, 4); (bD, 0, 4)] = Some R) in Hf
          | change (Mem.free_list M [(bD, 0, 4); (bH, 0, 4)] = Some R) in Hf ];
    cbn [Mem.free_list] in Hf; rename M into M3 end.
  match goal with Hf : (match Mem.free ?M ?b1 0 4 with Some _ => _ | None => _ end) = Some _ |- _ =>
    destruct (Mem.free M b1 0 4) as [M4|] eqn:F1; [| discriminate Hf] end.
  match goal with Hf : (match Mem.free ?M ?b1 0 4 with Some _ => _ | None => _ end) = Some _ |- _ =>
    destruct (Mem.free M b1 0 4) as [M5|] eqn:F2; [| discriminate Hf]; injection Hf as <- end.
  intros fl Hl. cbn [Mem.loadv] in Hl.
  erewrite (Mem.load_free _ _ _ _ _ F2) in Hl by (left; congruence).
  erewrite (Mem.load_free _ _ _ _ _ F1) in Hl by (left; congruence).
  destruct (HF' fl Hl) as [N | (h' & Eh & Hh)]; [left; exact N | right].
  injection Eh as <-. exact (Hit_back _ Hh).
Qed.
