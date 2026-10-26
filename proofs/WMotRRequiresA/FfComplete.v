(* ====================================================================== *)
(* FfComplete (GOAL 2): find_floor never misses over WMotR's death plane.  *)
(*                                                                          *)
(* FloorComplete proves find_floor_from_list complete (a passing surface    *)
(* on the list => a non-NULL result) and that the death plane passes at     *)
(* every in-bounds point above it.  This file walks find_floor's generated  *)
(* body: at an in-bounds (x, y, z) -- |x|, |z| < 8192 after the s16 casts,  *)
(* y >= -8269 -- with the death plane on every static floor cell            *)
(* ([dp_lists]), the floor find_floor stores into *pfloor is NOT NULL.      *)
(*                                                                          *)
(* Every path is followed: the two out-of-bounds early returns are closed   *)
(* by the bounds; the static call cannot return NULL (ffl_complete); the    *)
(* SURFACE_INTANGIBLE re-search cannot fire (no static floor has type 18);  *)
(* the dynamic floor replaces the static one only when dynamicHeight >      *)
(* height, and when the dynamic call missed, dynamicHeight is still -11000, *)
(* below every static floor height ([Hit_at] lower bound).                  *)
(* ====================================================================== *)

From Coq Require Import ZArith List Lia.
From compcert Require Import Coqlib Errors Maps AST Integers Floats Values Memory Events
  Globalenvs Ctypes Cop Clightdefs Clight ClightBigstep.
From SM64.Generated Require surface_collision.
From SM64.Proofs.WMotRRequiresA Require Import FloorList FloorHeight FloorComplete.
Import ListNotations.

(* ====================================================================== *)
(* WMotR's death plane passes at every in-bounds point above it            *)
(* ====================================================================== *)

(* the death plane's loaded normal and origin offset (surface_load.c's
   read_surface_data on the two COL_TRIs of SURFACE_DEATH_PLANE, all at
   y = -8191): normal (0, 1, 0), originOffset 8191.  StartTerrain's boot
   check reads them off the real loaded partition. *)
Definition DP_NY : float32 := Float32.of_bits (Int.repr 1065353216).   (* 1.0f, 0x3F800000 *)
Definition DP_OO : float32 := Float32.of_bits (Int.repr 1174403072).   (* 8191.0f, 0x45FFF800 *)
Definition DP_H : float32 := Float32.div (Float32.neg DP_OO) DP_NY.    (* -8191.0f *)

(* a death-plane triangle as loaded: a type that is not CAMERA_BOUNDARY,
   flags without NO_CAM_COLLISION, the (x, z) of its three vertices, and
   the plane's normal and offset *)
Definition dp_tri (m : mem) (s : val) (x1 z1 x2 z2 x3 z3 : Z) : Prop :=
  exists bs os ty fl, s = Vptr bs os
    /\ Mem.loadv Mint16signed m (Vptr bs (Ptrofs.add os (Ptrofs.repr 0))) = Some (Vint ty)
    /\ Int.eq ty (Int.repr 114) = false
    /\ Mem.loadv Mint8signed m (Vptr bs (Ptrofs.add os (Ptrofs.repr 4))) = Some (Vint fl)
    /\ Int.eq (Int.and fl (Int.repr 2)) Int.zero = true
    /\ Mem.loadv Mint16signed m (Vptr bs (Ptrofs.add os (Ptrofs.repr 10))) = Some (Vint (Int.repr x1))
    /\ Mem.loadv Mint16signed m (Vptr bs (Ptrofs.add os (Ptrofs.repr 14))) = Some (Vint (Int.repr z1))
    /\ Mem.loadv Mint16signed m (Vptr bs (Ptrofs.add os (Ptrofs.repr 16))) = Some (Vint (Int.repr x2))
    /\ Mem.loadv Mint16signed m (Vptr bs (Ptrofs.add os (Ptrofs.repr 20))) = Some (Vint (Int.repr z2))
    /\ Mem.loadv Mint16signed m (Vptr bs (Ptrofs.add os (Ptrofs.repr 22))) = Some (Vint (Int.repr x3))
    /\ Mem.loadv Mint16signed m (Vptr bs (Ptrofs.add os (Ptrofs.repr 26))) = Some (Vint (Int.repr z3))
    /\ Mem.loadv Mfloat32 m (Vptr bs (Ptrofs.add os (Ptrofs.repr 28))) = Some (Vsingle Float32.zero)
    /\ Mem.loadv Mfloat32 m (Vptr bs (Ptrofs.add os (Ptrofs.repr 32))) = Some (Vsingle DP_NY)
    /\ Mem.loadv Mfloat32 m (Vptr bs (Ptrofs.add os (Ptrofs.repr 36))) = Some (Vsingle Float32.zero)
    /\ Mem.loadv Mfloat32 m (Vptr bs (Ptrofs.add os (Ptrofs.repr 40))) = Some (Vsingle DP_OO).

(* collision.inc.c: COL_TRI(0, 1, 2) and COL_TRI(0, 2, 3) over the
   vertices (8192, -8191, -8191), (-8191, -8191, -8191), (-8191, -8191, 8192),
   (8192, -8191, 8192) *)
Definition dp_A (m : mem) (s : val) : Prop := dp_tri m s 8192 (-8191) (-8191) (-8191) (-8191) 8192.
Definition dp_B (m : mem) (s : val) : Prop := dp_tri m s 8192 (-8191) (-8191) 8192 8192 8192.

(* ---- exhaustive checks over an integer range ---- *)
Fixpoint zall (p : Z -> bool) (lo : Z) (n : nat) : bool :=
  match n with O => true | S k => p lo && zall p (Z.succ lo) k end.

Lemma zall_ok : forall p n lo, zall p lo n = true -> forall z, lo <= z < lo + Z.of_nat n -> p z = true.
Proof.
  intros p n. induction n as [| n IH]; intros lo H z Hz; cbn [zall] in H; [lia |].
  apply andb_prop in H as [H1 H2].
  destruct (Z.eq_dec z lo) as [-> | Hne]; [exact H1 |].
  apply (IH (Z.succ lo) H2). lia.
Qed.

Definition is_zero (f : float32) : bool :=
  if Float32.eq_dec f Float32.zero then true
  else if Float32.eq_dec f (Float32.neg Float32.zero) then true else false.

Lemma is_zero_ok : forall f, is_zero f = true -> f = Float32.zero \/ f = Float32.neg Float32.zero.
Proof.
  intros f H. unfold is_zero in H.
  destruct (Float32.eq_dec f Float32.zero) as [E | _]; [left; exact E |].
  destruct (Float32.eq_dec f (Float32.neg Float32.zero)) as [E | _]; [right; exact E | discriminate H].
Qed.

Definition px (z : Z) : bool := is_zero (Float32.mul (Float32.of_int (Int.repr z)) Float32.zero).
Definition pz (z : Z) : bool := is_zero (Float32.mul Float32.zero (Float32.of_int (Int.repr z))).
Definition py (z : Z) : bool :=
  negb (Float32.cmp Clt (Float32.sub (Float32.of_int (Int.repr z)) (Float32.add DP_H (Float32.neg c78)))
          Float32.zero).

Lemma px_all : zall px (-8191) (Z.to_nat 16383) = true.
Proof. vm_compute. reflexivity. Qed.
Lemma pz_all : zall pz (-8191) (Z.to_nat 16383) = true.
Proof. vm_compute. reflexivity. Qed.
Lemma py_all : zall py (-8269) (Z.to_nat 41037) = true.
Proof. vm_compute. reflexivity. Qed.

(* float equality through the bit patterns (vm never normalizes a float's
   proof fields) *)
Lemma f32_eq_bits : forall a b, Int.eq (Float32.to_bits a) (Float32.to_bits b) = true -> a = b.
Proof.
  intros a b H. apply Int.same_if_eq in H.
  rewrite <- (Float32.of_to_bits a), <- (Float32.of_to_bits b), H. reflexivity.
Qed.

Lemma dp_plane : forall X Z, -8192 < Int.signed X < 8192 -> -8192 < Int.signed Z < 8192 ->
  plane_h X Z Float32.zero DP_NY Float32.zero DP_OO = DP_H.
Proof.
  intros X Z HX HZ. unfold plane_h, DP_H.
  pose proof (zall_ok _ _ _ px_all (Int.signed X) ltac:(rewrite Z2Nat.id by lia; lia)) as A.
  pose proof (zall_ok _ _ _ pz_all (Int.signed Z) ltac:(rewrite Z2Nat.id by lia; lia)) as B.
  unfold px, pz in A, B. rewrite Int.repr_signed in A, B.
  destruct (is_zero_ok _ A) as [EA | EA]; destruct (is_zero_ok _ B) as [EB | EB]; rewrite EA, EB;
    apply f32_eq_bits; vm_compute; reflexivity.
Qed.

Lemma dp_y : forall Y, -8269 <= Int.signed Y <= 32767 ->
  Float32.cmp Clt (Float32.sub (Float32.of_int Y) (Float32.add DP_H (Float32.neg c78))) Float32.zero = false.
Proof.
  intros Y HY.
  pose proof (zall_ok _ _ _ py_all (Int.signed Y) ltac:(rewrite Z2Nat.id by lia; lia)) as A.
  unfold py in A. rewrite Int.repr_signed in A.
  destruct (Float32.cmp _ _ _); [discriminate A | reflexivity].
Qed.

(* the edge test, over the integers, when nothing overflows *)
Lemma edge_okZ : forall X Zi (xi zi xj zj : Z),
    -8192 <= Int.signed X <= 8192 -> -8192 <= Int.signed Zi <= 8192 ->
    -8192 <= xi <= 8192 -> -8192 <= zi <= 8192 -> -8192 <= xj <= 8192 -> -8192 <= zj <= 8192 ->
    edge_ok X Zi (Int.repr xi) (Int.repr zi) (Int.repr xj) (Int.repr zj)
    = negb ((zi - Int.signed Zi) * (xj - xi) - (xi - Int.signed X) * (zj - zi) <? 0).
Proof.
  intros X Zi xi zi xj zj HX HZ H1 H2 H3 H4.
  assert (S : forall a, -1073741824 <= a <= 1073741824 -> Int.signed (Int.repr a) = a).
  { intros a Ha. apply Int.signed_repr. unfold Int.min_signed, Int.max_signed. cbn. lia. }
  unfold edge_ok, Int.lt.
  rewrite (Int.sub_signed (Int.repr zi) Zi), (Int.sub_signed (Int.repr xj) (Int.repr xi)),
          (Int.sub_signed (Int.repr xi) X), (Int.sub_signed (Int.repr zj) (Int.repr zi)).
  rewrite (S zi), (S xj), (S xi), (S zj) by lia.
  rewrite !Int.mul_signed.
  rewrite (S (zi - Int.signed Zi)), (S (xj - xi)), (S (xi - Int.signed X)), (S (zj - zi)) by lia.
  rewrite Int.sub_signed.
  rewrite (S ((zi - Int.signed Zi) * (xj - xi))) by nia.
  rewrite (S ((xi - Int.signed X) * (zj - zi))) by nia.
  rewrite (S (_ - _)) by nia.
  change (Int.signed Int.zero) with 0.
  destruct (zlt _ 0) as [L | L]; cbn [negb];
    [apply Z.ltb_lt in L; rewrite L; reflexivity | apply Z.ge_le, Z.ltb_ge in L; rewrite L; reflexivity].
Qed.

Lemma dp_pass_A : forall m s X Y Z, dp_A m s ->
    -8192 < Int.signed X < 8192 -> -8192 < Int.signed Z < 8192 -> -8269 <= Int.signed Y <= 32767 ->
    Int.signed X + Int.signed Z <= 1 -> pass m s X Y Z.
Proof.
  intros m s X Y Z (bs & os & ty & fl & -> & Lt & Nt & Lf & Nf & L1 & L2 & L3 & L4 & L5 & L6 & L7 & L8 & L9 & L10)
    HX HZ HY HS.
  exists bs, os, ty, fl, (Int.repr 8192), (Int.repr (-8191)), (Int.repr (-8191)), (Int.repr (-8191)),
    (Int.repr (-8191)), (Int.repr 8192), Float32.zero, DP_NY, Float32.zero, DP_OO.
  split; [reflexivity |].
  do 12 (split; [assumption |]).
  rewrite !edge_okZ by lia.
  split; [apply negb_true_iff, Z.ltb_ge; nia |].
  split; [apply negb_true_iff, Z.ltb_ge; nia |].
  split; [apply negb_true_iff, Z.ltb_ge; nia |].
  split; [exact Nt |]. split; [exact Nf |].
  split; [vm_compute; reflexivity |].
  rewrite dp_plane by assumption. exact (dp_y Y HY).
Qed.

Lemma dp_pass_B : forall m s X Y Z, dp_B m s ->
    -8192 < Int.signed X < 8192 -> -8192 < Int.signed Z < 8192 -> -8269 <= Int.signed Y <= 32767 ->
    1 <= Int.signed X + Int.signed Z -> pass m s X Y Z.
Proof.
  intros m s X Y Z (bs & os & ty & fl & -> & Lt & Nt & Lf & Nf & L1 & L2 & L3 & L4 & L5 & L6 & L7 & L8 & L9 & L10)
    HX HZ HY HS.
  exists bs, os, ty, fl, (Int.repr 8192), (Int.repr (-8191)), (Int.repr (-8191)), (Int.repr 8192),
    (Int.repr 8192), (Int.repr 8192), Float32.zero, DP_NY, Float32.zero, DP_OO.
  split; [reflexivity |].
  do 12 (split; [assumption |]).
  rewrite !edge_okZ by lia.
  split; [apply negb_true_iff, Z.ltb_ge; nia |].
  split; [apply negb_true_iff, Z.ltb_ge; nia |].
  split; [apply negb_true_iff, Z.ltb_ge; nia |].
  split; [exact Nt |]. split; [exact Nf |].
  split; [vm_compute; reflexivity |].
  rewrite dp_plane by assumption. exact (dp_y Y HY).
Qed.

(* ---- the death plane on every static floor cell ---- *)

(* every cell [cz][cx] of gStaticSurfacePartition's FLOOR list (slot 0)
   holds both death-plane triangles *)
Definition dp_lists (ge : genv) (m : mem) : Prop :=
  forall cz cx, (0 <= cz < 16)%Z -> (0 <= cx < 16)%Z ->
    exists bp hd, Genv.find_symbol ge surface_collision._gStaticSurfacePartition = Some bp
      /\ Mem.loadv Mint32 m (Vptr bp (Ptrofs.repr (384 * cz + 24 * cx))) = Some hd
      /\ (exists s, on_list m hd s /\ dp_A m s)
      /\ (exists s, on_list m hd s /\ dp_B m s).

Lemma dp_cell_pass : forall ge m X Y Z cz cx, dp_lists ge m ->
    (0 <= cz < 16)%Z -> (0 <= cx < 16)%Z ->
    (-8192 < Int.signed X < 8192)%Z -> (-8192 < Int.signed Z < 8192)%Z ->
    (-8269 <= Int.signed Y <= 32767)%Z ->
    exists bp hd s, Genv.find_symbol ge surface_collision._gStaticSurfacePartition = Some bp
      /\ Mem.loadv Mint32 m (Vptr bp (Ptrofs.repr (384 * cz + 24 * cx))) = Some hd
      /\ on_list m hd s /\ pass m s X Y Z.
Proof.
  intros ge m X Y Z cz cx D Hz Hx HX HZ HY.
  destruct (D cz cx Hz Hx) as (bp & hd & Hs & Hl & (sA & OA & PA) & (sB & OB & PB)).
  destruct (Z_le_gt_dec (Int.signed X + Int.signed Z) 1) as [L | L].
  - exists bp, hd, sA. split; [exact Hs | split; [exact Hl | split; [exact OA |]]].
    exact (dp_pass_A m sA X Y Z PA HX HZ HY L).
  - exists bp, hd, sB. split; [exact Hs | split; [exact Hl | split; [exact OB |]]].
    apply (dp_pass_B m sB X Y Z PB HX HZ HY). lia.
Qed.

(* ---- dp_lists survives a step that keeps every cell off a set A that the
   static partition, its nodes and its surfaces avoid ---- *)

Lemma ld_fwd_A : forall m m' (A : block -> Prop),
    (forall ch b z, Mem.valid_block m b -> ~ A b -> Mem.load ch m' b z = Mem.load ch m b z) ->
    forall ch b z w, ~ A b -> Mem.load ch m b z = Some w -> Mem.load ch m' b z = Some w.
Proof.
  intros m m' A Hld ch b z w Na L. rewrite Hld; [exact L | | exact Na].
  eapply Mem.valid_access_valid_block.
  eapply Mem.valid_access_implies; [eapply Mem.load_valid_access; exact L | constructor].
Qed.

Lemma ol_fwd_A : forall m m' (A : block -> Prop) hd s,
    (forall ch b z w, ~ A b -> Mem.load ch m b z = Some w -> Mem.load ch m' b z = Some w) ->
    wf_list m A hd -> on_list m hd s -> on_list m' hd s.
Proof.
  intros m m' A hd s V W OL. revert W.
  induction OL as [bn on s Hl | bn on nx s Hl OL IH]; intros W; inv W.
  - apply ol_here. cbn [Mem.loadv] in *. eapply V; eassumption.
  - apply ol_next with nx; [cbn [Mem.loadv] in *; eapply V; eassumption |].
    apply IH.
    match goal with Hn : Mem.loadv _ _ _ = Some ?nx', Hw : wf_list _ _ ?nx' |- _ =>
      rewrite Hl in Hn; injection Hn as <-; exact Hw end.
Qed.

Lemma dp_tri_fwd : forall m m' (A : block -> Prop) s x1 z1 x2 z2 x3 z3,
    (forall ch b z w, ~ A b -> Mem.load ch m b z = Some w -> Mem.load ch m' b z = Some w) ->
    (forall b o, s = Vptr b o -> ~ A b) ->
    dp_tri m s x1 z1 x2 z2 x3 z3 -> dp_tri m' s x1 z1 x2 z2 x3 z3.
Proof.
  intros m m' A s x1 z1 x2 z2 x3 z3 V Hs
    (bs & os & ty & fl & -> & Lt & Nt & Lf & Nf & L1 & L2 & L3 & L4 & L5 & L6 & L7 & L8 & L9 & L10).
  pose proof (Hs bs os eq_refl) as Na.
  exists bs, os, ty, fl. split; [reflexivity |]. cbn [Mem.loadv] in *.
  split; [eapply V; eassumption |]. split; [exact Nt |].
  split; [eapply V; eassumption |]. split; [exact Nf |].
  repeat (split; [eapply V; eassumption |]). eapply V; eassumption.
Qed.

Theorem dp_lists_keep : forall (ge : genv) m m' (A : block -> Prop),
    (forall ch b z, Mem.valid_block m b -> ~ A b -> Mem.load ch m' b z = Mem.load ch m b z) ->
    (forall bp, Genv.find_symbol ge surface_collision._gStaticSurfacePartition = Some bp -> ~ A bp) ->
    (forall hd, part_head ge m hd -> wf_list m A hd) ->
    (forall hd b o, part_head ge m hd -> on_list m hd (Vptr b o) -> ~ A b) ->
    dp_lists ge m -> dp_lists ge m'.
Proof.
  intros ge m m' A Hld Hp Hw Hs D cz cx Hz Hx.
  pose proof (ld_fwd_A m m' A Hld) as V.
  destruct (D cz cx Hz Hx) as (bp & hd & Hb & Lh & (sA & OA & PA) & (sB & OB & PB)).
  assert (PH : part_head ge m hd).
  { exists surface_collision._gStaticSurfacePartition, bp, (Ptrofs.repr (384 * cz + 24 * cx)).
    split; [left; reflexivity | split; [exact Hb | exact Lh]]. }
  exists bp, hd. split; [exact Hb |].
  split; [cbn [Mem.loadv] in *; exact (V _ _ _ _ (Hp _ Hb) Lh) |].
  split.
  - exists sA. split; [exact (ol_fwd_A m m' A hd sA V (Hw hd PH) OA) |].
    exact (dp_tri_fwd m m' A sA _ _ _ _ _ _ V (fun b o E => Hs hd b o PH ltac:(rewrite <- E; exact OA)) PA).
  - exists sB. split; [exact (ol_fwd_A m m' A hd sB V (Hw hd PH) OB) |].
    exact (dp_tri_fwd m m' A sB _ _ _ _ _ _ V (fun b o E => Hs hd b o PH ltac:(rewrite <- E; exact OB)) PB).
Qed.

(* ---- find_floor_from_list calls, with completeness ---- *)

Lemma ffl_call_c : forall (ge : genv) e le m tid args targs tres cc t le' m' out,
    cenv_has ge -> ffl_pinned ge -> e ! surface_collision._find_floor_from_list = None ->
    exec_stmt function_entry2 ge e le m
      (Scall (Some tid) (Evar surface_collision._find_floor_from_list (Tfunction targs tres cc)) args)
      t le' m' out ->
    exists node x y z ph fl,
      eval_exprlist ge e le m args targs [node; x; y; z; ph]
      /\ out = Out_normal /\ le' = PTree.set tid fl le
      /\ ((m' = m /\ fl = Vint Int.zero)
          \/ (on_list m node fl /\ exists h, Mem.storev Mfloat32 m ph (Vsingle h) = Some m' /\ hok y h
                /\ ffl_hit m fl x z h))
      /\ (forall X Y Z s, x = Vint X -> y = Vint Y -> z = Vint Z -> on_list m node s ->
            pass m s X Y Z -> fl <> Vint Int.zero).
Proof.
  intros ge e le m tid args targs tres cc t le' m' out HC Hpin He H.
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
    destruct (ffl_args5 _ _ _ _ _ _ Hev) as (node & x & y & z & ph & ->);
    assert (Cp : forall X Y Z s, x = Vint X -> y = Vint Y -> z = Vint Z -> on_list m node s ->
                   pass m s X Y Z -> vres <> Vint Int.zero)
      by (intros X Y Z s -> -> -> OL P; exact (ffl_complete _ HC _ _ _ _ _ _ _ _ _ s Hev OL P));
    destruct (ffl_value_contract _ HC _ _ _ _ _ _ _ _ _ Hev) as [(-> & ->) | (Ho & h & Hst & Hk & Hh)] end.
  - do 6 eexists. split; [eassumption |]. split; [reflexivity |]. split; [reflexivity |].
    split; [left; auto | exact Cp].
  - do 6 eexists. split; [eassumption |]. split; [reflexivity |]. split; [reflexivity |].
    split; [right; eauto | exact Cp].
Qed.

(* ---- statement inversions ---- *)

Section X.
Variable ge : genv.
Variable e : env.

Lemma x_seq : forall le M s1 s2 t le' M' out,
    exec_stmt function_entry2 ge e le M (Ssequence s1 s2) t le' M' out ->
    (exists t1 le1 M1 t2, exec_stmt function_entry2 ge e le M s1 t1 le1 M1 Out_normal
       /\ exec_stmt function_entry2 ge e le1 M1 s2 t2 le' M' out)
    \/ (exec_stmt function_entry2 ge e le M s1 t le' M' out /\ out <> Out_normal).
Proof.
  intros le M s1 s2 t le' M' out H. inv H.
  - left. do 4 eexists. split; eassumption.
  - right. split; assumption.
Qed.

Lemma x_set : forall le M x a t le' M' out,
    exec_stmt function_entry2 ge e le M (Sset x a) t le' M' out ->
    exists v, eval_expr ge e le M a v /\ le' = PTree.set x v le /\ M' = M /\ out = Out_normal.
Proof. intros le M x a t le' M' out H. inv H. eauto. Qed.

Lemma x_asg : forall le M lhs rhs t le' M' out,
    exec_stmt function_entry2 ge e le M (Sassign lhs rhs) t le' M' out ->
    exists b ofs bf v v', eval_lvalue ge e le M lhs b ofs bf /\ eval_expr ge e le M rhs v
      /\ sem_cast v (typeof rhs) (typeof lhs) M = Some v'
      /\ assign_loc ge (typeof lhs) M b ofs bf v' M' /\ le' = le /\ out = Out_normal.
Proof.
  intros le M lhs rhs t le' M' out H. inv H.
  do 5 eexists. split; [eassumption |]. split; [eassumption |]. split; [eassumption |].
  split; [eassumption |]. split; reflexivity.
Qed.

Lemma x_ite : forall le M a s1 s2 t le' M' out,
    exec_stmt function_entry2 ge e le M (Sifthenelse a s1 s2) t le' M' out ->
    exists v b, eval_expr ge e le M a v /\ bool_val v (typeof a) M = Some b
      /\ exec_stmt function_entry2 ge e le M (if b then s1 else s2) t le' M' out.
Proof. intros le M a s1 s2 t le' M' out H. inv H. eauto. Qed.

Lemma ev_tv : forall le M x ty v, eval_expr ge e le M (Etempvar x ty) v -> le ! x = Some v.
Proof.
  intros le M x ty v H. inv H; [assumption |].
  match goal with Hl : eval_lvalue _ _ _ _ _ _ _ _ |- _ => inv Hl end.
Qed.

Lemma ev_ci : forall le M n ty v, eval_expr ge e le M (Econst_int n ty) v -> v = Vint n.
Proof.
  intros le M n ty v H. inv H; [reflexivity |].
  match goal with Hl : eval_lvalue _ _ _ _ _ _ _ _ |- _ => inv Hl end.
Qed.

(* a local float variable, read *)
Lemma ev_lvar : forall le M x b v, e ! x = Some (b, tfloat) ->
    eval_expr ge e le M (Evar x tfloat) v -> Mem.load Mfloat32 M b 0 = Some v.
Proof.
  intros le M x b v He H.
  assert (K : forall l ty, e ! x = Some (l, ty) -> l = b) by (intros l ty Hl; congruence).
  inv H.
  match goal with Hl : eval_lvalue _ _ _ _ (Evar _ _) _ _ _ |- _ => inv Hl end; [| congruence].
  match goal with Hd : deref_loc _ _ _ _ _ _ |- _ => inv Hd end; cbn [access_mode] in *;
    try discriminate.
  try match goal with Hm : By_value _ = By_value _ |- _ => injection Hm as <- end.
  repeat match goal with H1 : e ! x = Some (?l, _) |- _ =>
    tryif constr_eq l b then fail else (pose proof (K _ _ H1); subst l) end.
  cbn [Mem.loadv] in *. rewrite ?Ptrofs.unsigned_zero in *.
  match goal with Ha : access_mode _ = By_value _ |- _ => vm_compute in Ha; injection Ha as Ec; subst end.
  assumption.
Qed.

(* a local float variable, written *)
Lemma x_asg_lvar : forall le M x b rhs t le' M' out,
    e ! x = Some (b, tfloat) ->
    exec_stmt function_entry2 ge e le M (Sassign (Evar x tfloat) rhs) t le' M' out ->
    exists v v', eval_expr ge e le M rhs v /\ sem_cast v (typeof rhs) tfloat M = Some v'
      /\ Mem.store Mfloat32 M b 0 v' = Some M' /\ le' = le /\ out = Out_normal.
Proof.
  intros le M x b rhs t le' M' out He H.
  assert (K : forall l ty, e ! x = Some (l, ty) -> l = b) by (intros l ty Hl; congruence).
  apply x_asg in H as (b0 & ofs & bf & v & v' & Hl & Hv & Hc & Ha & -> & ->).
  inv Hl; [| congruence].
  match goal with H1 : e ! x = Some (b0, _) |- _ => pose proof (K _ _ H1) as -> end.
  cbn [typeof] in *.
  inv Ha; cbn [access_mode] in *; try discriminate.
  try match goal with Ha : access_mode _ = By_value _ |- _ => vm_compute in Ha; injection Ha as Ec; subst end.
  cbn [Mem.storev] in *. rewrite Ptrofs.unsigned_zero in *.
  exists v, v'. auto.
Qed.

(* *p, p a pointer temp *)
Lemma lv_deref_tv : forall le M p ty ty' b ofs bf bp op,
    le ! p = Some (Vptr bp op) ->
    eval_lvalue ge e le M (Ederef (Etempvar p ty) ty') b ofs bf -> b = bp /\ ofs = op /\ bf = Full.
Proof.
  intros le M p ty ty' b ofs bf bp op Hp H. inv H.
  match goal with Ht : eval_expr _ _ _ _ (Etempvar _ _) _ |- _ => apply ev_tv in Ht end.
  rewrite Hp in *. match goal with Hx : Some _ = Some _ |- _ => injection Hx as <- <- end. auto.
Qed.

End X.

(* a statement with no return inside cannot exit abruptly *)
Ltac noab S Hn :=
  lazymatch type of S with
  | exec_stmt _ _ _ _ _ (Ssequence _ _) _ _ _ _ =>
      let S1 := fresh "S" in let S2 := fresh "S" in let Hn' := fresh "Hn" in
      apply x_seq in S as [(? & ? & ? & ? & S1 & S2) | (S1 & Hn')]; [noab S2 Hn | noab S1 Hn']
  | exec_stmt _ _ _ _ _ (Sifthenelse _ _ _) _ _ _ _ =>
      let b := fresh "b" in let S' := fresh "S" in
      apply x_ite in S as (? & b & _ & _ & S'); destruct b; cbv beta iota in S'; noab S' Hn
  | _ => inv S; congruence
  end.

(* ---- the bounds tests (surface_collision.c: x, z outside +-LEVEL_BOUNDARY_MAX) ---- *)

Definition bnd_blk (xid t1 tr : ident) : statement :=
  Ssequence
    (Sifthenelse (Ebinop Ole (Etempvar xid tshort)
                   (Eunop Oneg (Econst_int (Int.repr 8192) tint) tint) tint)
      (Sset t1 (Econst_int (Int.repr 1) tint))
      (Sset t1 (Ecast (Ebinop Oge (Etempvar xid tshort) (Econst_int (Int.repr 8192) tint) tint) tbool)))
    (Sifthenelse (Etempvar t1 tint)
      (Ssequence (Sset tr (Evar surface_collision._height tfloat))
         (Sreturn (Some (Etempvar tr tfloat))))
      Sskip).

Lemma le_m8192 : forall X, (-8192 < Int.signed X)%Z -> Int.cmp Cle X (Int.neg (Int.repr 8192)) = false.
Proof.
  intros X H. cbn [Int.cmp]. unfold Int.lt.
  change (Int.signed (Int.neg (Int.repr 8192))) with (-8192)%Z.
  destruct (zlt (-8192) (Int.signed X)); [reflexivity | lia].
Qed.

Lemma ge_8192 : forall X, (Int.signed X < 8192)%Z -> Int.cmp Cge X (Int.repr 8192) = false.
Proof.
  intros X H. cbn [Int.cmp]. unfold Int.lt.
  change (Int.signed (Int.repr 8192)) with 8192%Z.
  destruct (zlt (Int.signed X) 8192); [reflexivity | lia].
Qed.

Lemma bnd_ok : forall (ge : genv) e le M xid t1 tr X t le' M' out,
    le ! xid = Some (Vint X) -> (-8192 < Int.signed X < 8192)%Z ->
    exec_stmt function_entry2 ge e le M (bnd_blk xid t1 tr) t le' M' out ->
    out = Out_normal /\ M' = M /\ exists v, le' = PTree.set t1 v le.
Proof.
  intros ge e le M xid t1 tr X t le' M' out Hx HX H. unfold bnd_blk in H.
  (* the first test is false, so t1 := (x >= 8192), which is false too *)
  assert (T1 : forall t0 le1 M1 o, exec_stmt function_entry2 ge e le M
      (Sifthenelse (Ebinop Ole (Etempvar xid tshort)
                   (Eunop Oneg (Econst_int (Int.repr 8192) tint) tint) tint)
      (Sset t1 (Econst_int (Int.repr 1) tint))
      (Sset t1 (Ecast (Ebinop Oge (Etempvar xid tshort) (Econst_int (Int.repr 8192) tint) tint) tbool)))
      t0 le1 M1 o -> o = Out_normal /\ M1 = M /\ le1 = PTree.set t1 (Vint Int.zero) le).
  { intros t0 le1 M1 o S.
    apply x_ite in S as (v & b & Hv & Hb & S).
    inv Hv; [| match goal with Hl : eval_lvalue _ _ _ _ _ _ _ _ |- _ => inv Hl end].
    match goal with Ha : eval_expr _ _ _ _ (Etempvar _ _) _ |- _ =>
      apply ev_tv in Ha; rewrite Hx in Ha; injection Ha as <- end.
    match goal with Ha : eval_expr _ _ _ _ (Eunop _ _ _) _ |- _ =>
      inv Ha; [| match goal with Hl : eval_lvalue _ _ _ _ _ _ _ _ |- _ => inv Hl end] end.
    match goal with Ha : eval_expr _ _ _ _ (Econst_int _ _) _ |- _ => apply ev_ci in Ha; subst end.
    match goal with Hu : sem_unary_operation _ _ _ _ = Some _ |- _ => cbn in Hu; injection Hu as <- end.
    match goal with Hs : sem_binary_operation _ Ole _ _ _ _ _ = Some ?w |- _ =>
      assert (Ew : Some w = Some (Val.of_bool (Int.cmp Cle X (Int.neg (Int.repr 8192)))))
        by (rewrite <- Hs; reflexivity);
      injection Ew as ->; clear Hs end.
    pose proof (le_m8192 X ltac:(lia)) as Q; cbn [Int.cmp] in Q; rewrite Q in Hb; clear Q. cbn in Hb. injection Hb as <-.
    cbv beta iota in S.
    apply x_set in S as (w & Hw & -> & -> & ->).
    split; [reflexivity | split; [reflexivity |]].
    inv Hw; [| match goal with Hl : eval_lvalue _ _ _ _ _ _ _ _ |- _ => inv Hl end].
    match goal with Ha : eval_expr _ _ _ _ (Ebinop _ _ _ _) _ |- _ =>
      inv Ha; [| match goal with Hl : eval_lvalue _ _ _ _ _ _ _ _ |- _ => inv Hl end] end.
    match goal with Ha : eval_expr _ _ _ _ (Etempvar _ _) _ |- _ =>
      apply ev_tv in Ha; rewrite Hx in Ha; injection Ha as <- end.
    match goal with Ha : eval_expr _ _ _ _ (Econst_int _ _) _ |- _ => apply ev_ci in Ha; subst end.
    match goal with Hs : sem_binary_operation _ Oge _ _ _ _ _ = Some ?w |- _ =>
      assert (Ew : Some w = Some (Val.of_bool (Int.cmp Cge X (Int.repr 8192))))
        by (rewrite <- Hs; reflexivity);
      injection Ew as ->; clear Hs end.
    pose proof (ge_8192 X ltac:(lia)) as Q; cbn [Int.cmp] in Q; rewrite ?Q in *; clear Q.
    match goal with Hc : sem_cast _ _ _ _ = Some ?w |- _ =>
      assert (Ew : Some w = Some (Vint Int.zero)) by (rewrite <- Hc; reflexivity);
      injection Ew as ->; clear Hc end.
    reflexivity. }
  apply x_seq in H as [(ta & le1 & M1 & tb & H1 & H2) | (H1 & Hn)].
  - destruct (T1 _ _ _ _ H1) as (_ & -> & ->).
    apply x_ite in H2 as (v & b & Hv & Hb & H2).
    apply ev_tv in Hv. rewrite PTree.gss in Hv. injection Hv as <-.
    cbn in Hb. injection Hb as <-. cbv beta iota in H2. inv H2.
    split; [reflexivity | split; [reflexivity |]]. eauto.
  - destruct (T1 _ _ _ _ H1) as (-> & _). congruence.
Qed.

(* ---- small evaluation facts ---- *)

Lemma ev_s16 : forall (ge : genv) e le M p pv v, le ! p = Some pv ->
    eval_expr ge e le M (Ecast (Ecast (Etempvar p tfloat) tshort) tshort) v -> v = ycast pv.
Proof.
  intros ge e le M p pv v Hp H.
  inv H; [| match goal with Hl : eval_lvalue _ _ _ _ _ _ _ _ |- _ => inv Hl end].
  match goal with Ha : eval_expr _ _ _ _ (Ecast _ _) _ |- _ =>
    inv Ha; [| match goal with Hl : eval_lvalue _ _ _ _ _ _ _ _ |- _ => inv Hl end] end.
  match goal with Ha : eval_expr _ _ _ _ (Etempvar _ _) _ |- _ =>
    apply ev_tv in Ha; rewrite Hp in Ha; injection Ha as <- end.
  cbn [typeof] in *. eapply ycast_ok; eassumption.
Qed.

Lemma ev_m11000 : forall (ge : genv) e le M v v',
    eval_expr ge e le M (Eunop Oneg (Econst_int (Int.repr 11000) tint) tint) v ->
    sem_cast v (typeof (Eunop Oneg (Econst_int (Int.repr 11000) tint) tint)) tfloat M = Some v' ->
    v' = Vsingle c11000.
Proof.
  intros ge e le M v v' Hev Hc.
  inv Hev; [| match goal with Hl : eval_lvalue _ _ _ _ (Eunop _ _ _) _ _ _ |- _ => inv Hl end].
  match goal with Hk : eval_expr _ _ _ _ (Econst_int _ _) _ |- _ => apply ev_ci in Hk; subst end.
  match goal with Hu : sem_unary_operation Oneg _ _ _ = Some _ |- _ =>
    unfold sem_unary_operation, sem_neg in Hu; cbn [typeof classify_neg] in Hu; injection Hu as <- end.
  unfold sem_cast in Hc. cbn [typeof classify_cast] in Hc. injection Hc as <-. reflexivity.
Qed.

(* an s16 value of ycast *)
Lemma ycast_s16 : forall v X, ycast v = Vint X -> Int.sign_ext 16 X = X.
Proof.
  intros v X H. unfold ycast in H. destruct v; try discriminate H.
  destruct (Float32.to_int f) as [i|]; [| discriminate H]. injection H as <-.
  rewrite !Int.sign_ext_idem by lia. reflexivity.
Qed.

(* the cast of a pointer temp to its own pointer type *)
Lemma cast_pp : forall v ty m vr, sem_cast v (tptr ty) (tptr ty) m = Some vr -> vr = v.
Proof. intros v ty m vr H. exact (cast_ptr_same ty noattr v m vr H). Qed.

(* a pointer compared == NULL is false or undefined, never true *)
Lemma cmp_eq_null : forall m b o v,
    cmp_ptr m Ceq (Vptr b o) (Vint (Int.repr 0)) = Some v -> v = Vfalse.
Proof.
  intros m b o v H. unfold cmp_ptr in H.
  change Archi.ptr64 with false in H. cbv beta iota in H.
  unfold Val.cmpu_bool in H. change Archi.ptr64 with false in H. cbv beta iota in H.
  change (Int.eq (Int.repr 0) Int.zero) with true in H. cbv beta iota in H.
  match type of H with
  | option_map _ (if ?c then _ else _) = _ => destruct c
  end.
  - cbv in H. injection H as <-. reflexivity.
  - cbv in H. discriminate H.
Qed.

(* ---- memory frames ---- *)

Lemma ld_keep_asg : forall (ce : composite_env) ty M b ofs bf v M' ch b' z w,
    assign_loc ce ty M b ofs bf v M' -> b' <> b ->
    Mem.load ch M b' z = Some w -> Mem.load ch M' b' z = Some w.
Proof.
  intros ce ty M b ofs bf v M' ch b' z w Ha Hne Hl.
  eapply Mem.load_unchanged_on; [exact (assign_loc_frame _ _ _ _ _ _ _ _ Ha) | | exact Hl].
  intros; exact Hne.
Qed.

Lemma asg_store : forall (ce : composite_env) ty M b ofs v M' ch,
    access_mode ty = By_value ch -> assign_loc ce ty M b ofs Full v M' ->
    Mem.store ch M b (Ptrofs.unsigned ofs) v = Some M'.
Proof.
  intros ce ty M b ofs v M' ch Hm Ha. inv Ha; try congruence.
  match goal with Hm' : access_mode _ = By_value _ |- _ => rewrite Hm in Hm'; injection Hm' as <- end.
  assumption.
Qed.

(* ---- the tests on the floor pointer and its fields ---- *)

Lemma gp_true : forall (ge : genv) e le M x b o v bg,
    le ! x = Some (Vptr b o) ->
    eval_expr ge e le M
      (Ebinop One (Etempvar x (tptr surf_t)) (Ecast (Econst_int (Int.repr 0) tint) (tptr tvoid)) tint) v ->
    bool_val v tint M = Some bg -> bg = true.
Proof.
  intros ge e le M x b o v bg Hn H Hb.
  repeat match goal with
         | H : eval_expr _ _ _ _ _ _ |- _ => inv H
         | H : eval_lvalue _ _ _ _ _ _ _ _ |- _ => inv H
         end.
  rewrite Hn in *. repeat match goal with Hx : Some _ = Some _ |- _ => inv Hx end.
  match goal with Hc : sem_cast (Vint _) _ _ _ = Some _ |- _ =>
    vm_compute in Hc; injection Hc as <- end.
  match goal with Hs : sem_binary_operation _ One _ _ _ _ _ = Some _ |- _ =>
    cbn in Hs; apply cmp_ne_null in Hs; subst end.
  cbn in Hb. injection Hb as <-. reflexivity.
Qed.

Lemma eqn_false : forall (ge : genv) e le M x b o v bg,
    le ! x = Some (Vptr b o) ->
    eval_expr ge e le M
      (Ebinop Oeq (Etempvar x (tptr surf_t)) (Ecast (Econst_int (Int.repr 0) tint) (tptr tvoid)) tint) v ->
    bool_val v tint M = Some bg -> bg = false.
Proof.
  intros ge e le M x b o v bg Hn H Hb.
  repeat match goal with
         | H : eval_expr _ _ _ _ _ _ |- _ => inv H
         | H : eval_lvalue _ _ _ _ _ _ _ _ |- _ => inv H
         end.
  rewrite Hn in *. repeat match goal with Hx : Some _ = Some _ |- _ => inv Hx end.
  match goal with Hc : sem_cast (Vint _) _ _ _ = Some _ |- _ =>
    vm_compute in Hc; injection Hc as <- end.
  match goal with Hs : sem_binary_operation _ Oeq _ _ _ _ _ = Some _ |- _ =>
    cbn in Hs; apply cmp_eq_null in Hs; subst end.
  cbn in Hb. injection Hb as <-. reflexivity.
Qed.

Lemma ev_deref_s : forall (ge : genv) e le M x tp sid l o,
    eval_expr ge e le M (Ederef (Etempvar x tp) (Tstruct sid noattr)) (Vptr l o) ->
    le ! x = Some (Vptr l o).
Proof.
  intros ge e le M x tp sid l o H.
  inv H. match goal with Hl : eval_lvalue _ _ _ _ (Ederef _ _) _ _ _ |- _ => inv Hl end.
  match goal with Hd : deref_loc _ _ _ _ _ _ |- _ => inv Hd end; cbn [access_mode] in *;
    try discriminate.
  match goal with Ht : eval_expr _ _ _ _ (Etempvar _ _) _ |- _ => apply ev_tv in Ht; exact Ht end.
Qed.

Lemma ev_eq18 : forall (ge : genv) e le M t ty v, le ! t = Some (Vint ty) -> Int.signed ty <> 18%Z ->
    eval_expr ge e le M
      (Ecast (Ebinop Oeq (Etempvar t tshort) (Econst_int (Int.repr 18) tint) tint) tbool) v ->
    v = Vint Int.zero.
Proof.
  intros ge e le M t ty v Ht Hne H.
  inv H; [| match goal with Hl : eval_lvalue _ _ _ _ _ _ _ _ |- _ => inv Hl end].
  match goal with Ha : eval_expr _ _ _ _ (Ebinop _ _ _ _) _ |- _ =>
    inv Ha; [| match goal with Hl : eval_lvalue _ _ _ _ _ _ _ _ |- _ => inv Hl end] end.
  match goal with Ha : eval_expr _ _ _ _ (Etempvar _ _) _ |- _ =>
    apply ev_tv in Ha; rewrite Ht in Ha; injection Ha as <- end.
  match goal with Ha : eval_expr _ _ _ _ (Econst_int _ _) _ |- _ => apply ev_ci in Ha; subst end.
  assert (E : Int.eq ty (Int.repr 18) = false).
  { apply Int.eq_false. intros ->. apply Hne. reflexivity. }
  match goal with Hs : sem_binary_operation _ Oeq _ _ _ _ _ = Some ?w |- _ =>
    assert (Ew : Some w = Some (Val.of_bool (Int.eq ty (Int.repr 18))))
      by (rewrite <- Hs; reflexivity);
    injection Ew as ->; clear Hs end.
  rewrite E in *.
  match goal with Hc : sem_cast _ _ _ _ = Some ?w |- _ =>
    assert (Ew : Some w = Some (Vint Int.zero)) by (rewrite <- Hc; reflexivity);
    injection Ew as ->; clear Hc end.
  reflexivity.
Qed.

Lemma ev_fgt : forall (ge : genv) e le M a b fa fb v,
    le ! a = Some (Vsingle fa) -> le ! b = Some (Vsingle fb) ->
    eval_expr ge e le M (Ebinop Ogt (Etempvar a tfloat) (Etempvar b tfloat) tint) v ->
    v = Val.of_bool (Float32.cmp Cgt fa fb).
Proof.
  intros ge e le M a b fa fb v Ha Hb H.
  inv H; [| match goal with Hl : eval_lvalue _ _ _ _ _ _ _ _ |- _ => inv Hl end].
  match goal with H1 : eval_expr _ _ _ _ (Etempvar a _) _ |- _ =>
    apply ev_tv in H1; rewrite Ha in H1; injection H1 as <- end.
  match goal with H1 : eval_expr _ _ _ _ (Etempvar b _) _ |- _ =>
    apply ev_tv in H1; rewrite Hb in H1; injection H1 as <- end.
  match goal with Hs : sem_binary_operation _ Ogt _ _ _ _ _ = Some ?w |- _ =>
    assert (Ew : Some w = Some (Val.of_bool (Float32.cmp Cgt fa fb)))
      by (rewrite <- Hs; reflexivity);
    injection Ew as ->; clear Hs end.
  reflexivity.
Qed.

(* the five arguments of a find_floor_from_list call *)
Lemma ev_args : forall (ge : genv) e le M sl xid yid zid hid bh X Y Z node x y z ph,
    e ! hid = Some (bh, tfloat) ->
    le ! xid = Some (Vint X) -> le ! yid = Some (Vint Y) -> le ! zid = Some (Vint Z) ->
    eval_exprlist ge e le M
      [Etempvar sl (tptr (Tstruct surface_collision._SurfaceNode noattr)); Etempvar xid tshort;
       Etempvar yid tshort; Etempvar zid tshort; Eaddrof (Evar hid tfloat) (tptr tfloat)]
      [tptr (Tstruct surface_collision._SurfaceNode noattr); tint; tint; tint; tptr tfloat]
      [node; x; y; z; ph] ->
    le ! sl = Some node /\ x = Vint X /\ y = Vint Y /\ z = Vint Z /\ ph = Vptr bh Ptrofs.zero.
Proof.
  intros ge e le M sl xid yid zid hid bh X Y Z node x y z ph He Lx Ly Lz H.
  assert (K : forall l ty, e ! hid = Some (l, ty) -> l = bh) by (intros l ty Hl; congruence).
  inv H. cbn [typeof] in *.
  match goal with C : sem_cast _ (tptr _) (tptr _) _ = Some node |- _ => apply cast_pp in C; subst node end.
  match goal with Ht : eval_expr _ _ _ _ (Etempvar sl _) _ |- _ => apply ev_tv in Ht end.
  match goal with R : eval_exprlist _ _ _ _ (_ :: _) _ _ |- _ => inv R end. cbn [typeof] in *.
  match goal with Ht : eval_expr _ _ _ _ (Etempvar xid _) _ |- _ =>
    apply ev_tv in Ht; rewrite Lx in Ht; injection Ht as <- end.
  match goal with C : sem_cast (Vint X) _ _ _ = Some ?w |- _ =>
    assert (Ew : Some w = Some (Vint X)) by (rewrite <- C; reflexivity);
    injection Ew as ->; clear C end.
  match goal with R : eval_exprlist _ _ _ _ (_ :: _) _ _ |- _ => inv R end. cbn [typeof] in *.
  match goal with Ht : eval_expr _ _ _ _ (Etempvar yid _) _ |- _ =>
    apply ev_tv in Ht; rewrite Ly in Ht; injection Ht as <- end.
  match goal with C : sem_cast (Vint Y) _ _ _ = Some ?w |- _ =>
    assert (Ew : Some w = Some (Vint Y)) by (rewrite <- C; reflexivity);
    injection Ew as ->; clear C end.
  match goal with R : eval_exprlist _ _ _ _ (_ :: _) _ _ |- _ => inv R end. cbn [typeof] in *.
  match goal with Ht : eval_expr _ _ _ _ (Etempvar zid _) _ |- _ =>
    apply ev_tv in Ht; rewrite Lz in Ht; injection Ht as <- end.
  match goal with C : sem_cast (Vint Z) _ _ _ = Some ?w |- _ =>
    assert (Ew : Some w = Some (Vint Z)) by (rewrite <- C; reflexivity);
    injection Ew as ->; clear C end.
  match goal with R : eval_exprlist _ _ _ _ (_ :: _) _ _ |- _ => inv R end. cbn [typeof] in *.
  match goal with C : sem_cast _ (tptr _) (tptr _) _ = Some ph |- _ => apply cast_pp in C; subst ph end.
  match goal with Ha : eval_expr _ _ _ _ (Eaddrof _ _) _ |- _ =>
    inv Ha; [| match goal with Hl : eval_lvalue _ _ _ _ (Eaddrof _ _) _ _ _ |- _ => inv Hl end] end.
  match goal with Hl : eval_lvalue _ _ _ _ (Evar _ _) _ _ _ |- _ => inv Hl end; [| congruence].
  match goal with H1 : e ! hid = Some (?l, _) |- _ => rewrite (K _ _ H1) end.
  auto.
Qed.

Section FC.
Variable ge : genv.
Variable m : mem.
Variables bpf bH bD : block.
Variable opf : ptrofs.
Variables xv yv zv : val.
Variables X Y Z : int.
Hypothesis HC : cenv_has ge.
Hypothesis Hpin : ffl_pinned ge.
Hypothesis HnvH : ~ Mem.valid_block m bH.
Hypothesis HnvD : ~ Mem.valid_block m bD.
Hypothesis HHD : bH <> bD.
Hypothesis Hpv : Mem.valid_block m bpf.
Hypothesis HyX : ycast xv = Vint X.
Hypothesis HyY : ycast yv = Vint Y.
Hypothesis HyZ : ycast zv = Vint Z.
Hypothesis HbX : (-8192 < Int.signed X < 8192)%Z.
Hypothesis HbY : (-8269 <= Int.signed Y <= 32767)%Z.
Hypothesis HbZ : (-8192 < Int.signed Z < 8192)%Z.
Hypothesis Hst : forall id b, In id ff_statics -> Genv.find_symbol ge id = Some b ->
  Mem.valid_block m b /\ b <> bpf.
Hypothesis Hdp : dp_lists ge m.
Hypothesis Hsp : forall bp, Genv.find_symbol ge surface_collision._gStaticSurfacePartition = Some bp ->
  bp <> bpf.
Hypothesis Hwfs : forall hd, floor_head ge m hd -> wf_list m (fun b => b = bpf) hd.
Hypothesis Hsf : forall hd b o, floor_head ge m hd -> on_list m hd (Vptr b o) ->
  Mem.valid_block m b /\ b <> bpf
  /\ exists ty, Mem.load Mint16signed m b (Ptrofs.unsigned o) = Some (Vint ty)
       /\ Int.signed ty <> 18%Z.
Hypothesis HB : forall h, Hit_at ge m h -> Float32.cmp Cgt c11000 h = false.

Local Notation e := (ffe bH bD).
Local Notation KP := (keep m (fun b => b = bpf)).

Lemma bH_v : bH <> bpf.
Proof. intros ->. contradiction. Qed.
Lemma bD_v : bD <> bpf.
Proof. intros ->. contradiction. Qed.

Lemma U_new : forall M M' ch b z v, Mem.unchanged_on KP m M -> ~ Mem.valid_block m b ->
    Mem.store ch M b z v = Some M' -> Mem.unchanged_on KP m M'.
Proof.
  intros M M' ch b z v U Hb Hs. eapply Mem.unchanged_on_trans; [exact U |].
  eapply Mem.store_unchanged_on; [exact Hs |]. intros i _ (Hv & _). exact (Hb Hv).
Qed.

Lemma U_pf : forall M M' ch z v, Mem.unchanged_on KP m M ->
    Mem.store ch M bpf z v = Some M' -> Mem.unchanged_on KP m M'.
Proof.
  intros M M' ch z v U Hs. eapply Mem.unchanged_on_trans; [exact U |].
  eapply Mem.store_unchanged_on; [exact Hs |]. intros i _ (_ & Hn). exact (Hn eq_refl).
Qed.

Lemma ld_fwd : forall M ch b z w, Mem.unchanged_on KP m M -> b <> bpf ->
    Mem.load ch m b z = Some w -> Mem.load ch M b z = Some w.
Proof.
  intros M ch b z w U Hne Hl. eapply Mem.load_unchanged_on; [exact U | | exact Hl].
  intros i _. split; [| exact Hne].
  eapply Mem.valid_access_valid_block.
  eapply Mem.valid_access_implies; [eapply Mem.load_valid_access; exact Hl | constructor].
Qed.

Lemma ol_fwd : forall M hd s, Mem.unchanged_on KP m M -> wf_list m (fun b => b = bpf) hd ->
    on_list m hd s -> on_list M hd s.
Proof.
  intros M hd s U W OL. revert W.
  induction OL as [bn on s Hl | bn on nx s Hl OL IH]; intros W; inv W.
  - apply ol_here. cbn [Mem.loadv] in *. eapply ld_fwd; eassumption.
  - apply ol_next with nx; [cbn [Mem.loadv] in *; eapply ld_fwd; eassumption |].
    apply IH.
    match goal with Hn : Mem.loadv _ _ _ = Some ?nx', Hw : wf_list _ _ ?nx' |- _ =>
      rewrite Hl in Hn; injection Hn as <-; exact Hw end.
Qed.

Lemma pass_fwd : forall M bs os, Mem.unchanged_on KP m M -> bs <> bpf ->
    pass m (Vptr bs os) X Y Z -> pass M (Vptr bs os) X Y Z.
Proof.
  intros M bs os U Hne
    (bs' & os' & ty & fl & x1 & z1 & x2 & z2 & x3 & z3 & nx & ny & nz & oo & Es & L1 & L2 & L3 & L4
     & L5 & L6 & L7 & L8 & L9 & L10 & L11 & L12 & R).
  injection Es as <- <-.
  exists bs, os, ty, fl, x1, z1, x2, z2, x3, z3, nx, ny, nz, oo.
  cbn [Mem.loadv] in *. split; [reflexivity |].
  repeat (split; [eapply ld_fwd; eassumption |]). exact R.
Qed.

Lemma ld_back : forall M ch b z, Mem.unchanged_on KP m M -> Mem.valid_block m b -> b <> bpf ->
    Mem.load ch M b z = Mem.load ch m b z.
Proof.
  intros M ch b z U Hv Hne. eapply Mem.load_unchanged_on_1; [exact U | exact Hv |].
  intros i _. split; assumption.
Qed.


Tactic Notation "sq" ident(S) ident(L) ident(M) :=
  try clear S;
  match goal with Hx : exec_stmt _ _ _ _ _ (Ssequence _ _) _ _ _ _ |- _ =>
    let Hn := fresh "Hn" in
    apply x_seq in Hx as [(? & L & M & ? & S & Hx) | (S & Hn)]; [| noab S Hn]
  end.

Ltac lk H := ptg; exact H.

(* THE WALK: every execution of find_floor's body, from the entry state,
   stores a non-NULL floor into *pfloor *)
Lemma body_c : forall le0 M0 t le' M' out,
    le0 ! surface_collision._xPos = Some xv -> le0 ! surface_collision._yPos = Some yv ->
    le0 ! surface_collision._zPos = Some zv ->
    le0 ! surface_collision._pfloor = Some (Vptr bpf opf) ->
    Mem.unchanged_on KP m M0 ->
    exec_stmt function_entry2 ge e le0 M0 (fn_body surface_collision.f_find_floor) t le' M' out ->
    exists F, Mem.loadv Mint32 M' (Vptr bpf opf) = Some F /\ F <> Vint Int.zero.
Proof using All.
  intros le0 M0 t le' M' out Lx Ly Lz Lp U0 Hx.
  cbn [fn_body surface_collision.f_find_floor] in Hx.
  (* height := -11000 *)
  sq S le1 M1.
  destruct (x_asg_lvar _ _ _ _ _ _ _ _ _ _ _ (ffe_H bH bD) S) as (v1 & v1' & _ & _ & St1 & -> & _).
  pose proof (U_new _ _ _ _ _ _ U0 HnvH St1) as U1.
  (* dynamicHeight := -11000 *)
  sq S le2 M2.
  destruct (x_asg_lvar _ _ _ _ _ _ _ _ _ _ _ (ffe_D bH bD) S) as (v2 & v2' & Ev2 & Ec2 & St2 & -> & _).
  pose proof (ev_m11000 _ _ _ _ _ _ Ev2 Ec2) as ->.
  pose proof (U_new _ _ _ _ _ _ U1 HnvD St2) as U2.
  assert (LD2 : Mem.load Mfloat32 M2 bD 0 = Some (Vsingle c11000))
    by (rewrite (Mem.load_store_same _ _ _ _ _ _ St2); reflexivity).
  (* x, y, z := the s16 casts *)
  sq S le3 M3. apply x_set in S as (vx & Evx & -> & -> & _).
  eapply ev_s16 in Evx; [| exact Lx]. rewrite HyX in Evx. subst vx.
  sq S le4 M4. apply x_set in S as (vy & Evy & -> & -> & _).
  eapply ev_s16 in Evy; [| lk Ly]. rewrite HyY in Evy. subst vy.
  sq S le5 M5. apply x_set in S as (vz & Evz & -> & -> & _).
  eapply ev_s16 in Evz; [| lk Lz]. rewrite HyZ in Evz. subst vz.
  (* *pfloor := NULL *)
  sq S le6 M6.
  apply x_asg in S as (b6 & o6 & bf6 & v6 & v6' & Hl6 & _ & _ & Ha6 & -> & _).
  eapply lv_deref_tv in Hl6 as (E6a & E6b & E6c); [| lk Lp]. subst b6 o6 bf6.
  cbn [typeof] in Ha6.
  pose proof Ha6 as St6. eapply (asg_store _ _ _ _ _ _ _ Mint32) in St6; [| reflexivity].
  pose proof (U_pf _ _ _ _ _ U2 St6) as U6.
  assert (LD6 : Mem.load Mfloat32 M6 bD 0 = Some (Vsingle c11000))
    by (rewrite (Mem.load_store_other _ _ _ _ _ _ St6) by (left; exact bD_v); exact LD2).
  clear St1 St2 St6 Ha6 U0 U1 U2 LD2.
  (* the x bounds test *)
  match goal with Hx : exec_stmt _ _ _ _ _ (Ssequence _ _) _ _ _ _ |- _ =>
    apply x_seq in Hx as [(? & le7 & M7 & ? & S & Hx) | (S & Hn)] end.
  2:{ eapply bnd_ok in S as (-> & _); [congruence | ptg; reflexivity | exact HbX]. }
  eapply bnd_ok in S as (_ & -> & (v7 & ->)); [| ptg; reflexivity | exact HbX].
  (* the z bounds test *)
  match goal with Hx : exec_stmt _ _ _ _ _ (Ssequence _ _) _ _ _ _ |- _ =>
    apply x_seq in Hx as [(? & le8 & M8 & ? & S & Hx) | (S & Hn)] end.
  2:{ eapply bnd_ok in S as (-> & _); [congruence | ptg; reflexivity | exact HbZ]. }
  eapply bnd_ok in S as (_ & -> & (v8 & ->)); [| ptg; reflexivity | exact HbZ].
  (* cellX, cellZ *)
  sq S le9 M9. apply x_set in S as (vcx & Ecx & -> & -> & _).
  destruct (ev_cellidx _ _ _ _ _ _ Ecx) as (ix & -> & Rx).
  sq S le10 M10. apply x_set in S as (vcz & Ecz & -> & -> & _).
  destruct (ev_cellidx _ _ _ _ _ _ Ecz) as (iz & -> & Rz).
  (* the dynamic list and its call *)
  sq S le11 M11. apply x_set in S as (vdl & _ & -> & -> & _).
  sq S le12 M12.
  apply x_seq in S as [(? & leA & MA & ? & Sc & Ss) | (Sc & Hn)]; [| noab Sc Hn].
  destruct (ffl_call _ _ _ _ _ _ _ _ _ _ _ _ _ HC Hpin
              (ffe_other bH bD surface_collision._find_floor_from_list ltac:(idne) ltac:(idne)) Sc)
    as (nd & ax & ay & az & aph & dF & Hargs & _ & -> & Hdc).
  eapply ev_args in Hargs;
    [| exact (ffe_D bH bD) | ptg; reflexivity | ptg; reflexivity | ptg; reflexivity].
  destruct Hargs as (_ & -> & -> & -> & ->).
  assert (DC : Mem.unchanged_on KP m MA
               /\ ((dF = Vint Int.zero /\ Mem.load Mfloat32 MA bD 0 = Some (Vsingle c11000))
                   \/ (exists b o, dF = Vptr b o))).
  { destruct Hdc as [(-> & ->) | (_ & h' & Hst' & _ & Hh')].
    - split; [exact U6 | left; split; [reflexivity | exact LD6]].
    - cbn [Mem.storev] in Hst'. rewrite Ptrofs.unsigned_zero in Hst'.
      split; [exact (U_new _ _ _ _ _ _ U6 HnvD Hst') |].
      right. destruct Hh' as (bs & os & _ & _ & _ & _ & _ & _ & _ & _ & _ & _ & _ & _ & Es & _). eauto. }
  clear Hdc Sc. destruct DC as (UA & DC).
  apply x_set in Ss as (vdf & Evdf & -> & -> & _).
  apply ev_tv in Evdf. rewrite PTree.gss in Evdf. injection Evdf as <-.
  (* the static list *)
  sq S le13 M13. apply x_set in S as (hd & Ehd & -> & -> & _).
  destruct (deref_field ge e _ _ (part_e surface_collision._gStaticSurfacePartition)
              surface_collision._SurfaceNode surface_collision._next
              (tptr (Tstruct surface_collision._SurfaceNode noattr)) hd SN_NEXT
              (fun co Hc => proj1 (sn_offsets_ge ge co HC Hc)) eq_refl Ehd) as (l & ofs & HA & Hld).
  destruct (ev_part ge e _ _ _ l ofs HC
              (ffe_other bH bD surface_collision._gStaticSurfacePartition ltac:(idne) ltac:(idne)) HA)
    as (iz' & ix' & Hz & Hx' & Hs & ->).
  assert (iz' = iz) by (revert Hz; ptg; intros E; congruence). subst iz'.
  assert (ix' = ix) by (revert Hx'; ptg; intros E; congruence). subst ix'.
  rewrite (part_ofs iz ix Rz Rx) in Hld. unfold SN_NEXT in Hld. rewrite Ptrofs.add_zero in Hld.
  destruct (dp_cell_pass ge m X Y Z (Int.signed iz) (Int.signed ix) Hdp Rz Rx HbX HbZ HbY)
    as (bp & hd0 & s0 & Hbp & Lhd0 & OL0 & P0).
  assert (l = bp) by congruence. subst l.
  cbn [Mem.loadv] in Hld, Lhd0.
  rewrite (ld_fwd _ _ _ _ _ UA (Hsp _ Hbp) Lhd0) in Hld. injection Hld as <-.
  assert (FH : floor_head ge m hd0).
  { exists surface_collision._gStaticSurfacePartition, bp, (Int.signed iz), (Int.signed ix).
    split; [left; reflexivity | split; [exact Hbp | split; [lia | split; [lia | exact Lhd0]]]]. }
  destruct (pass_ptr _ _ _ _ _ P0) as (bs0 & os0 & ->).
  destruct (Hsf _ _ _ FH OL0) as (_ & Hn0 & _).
  (* the static call: never NULL *)
  sq S le14 M14.
  apply x_seq in S as [(? & leS & MS & ? & Sc & Ss) | (Sc & Hn)]; [| noab Sc Hn].
  destruct (ffl_call_c _ _ _ _ _ _ _ _ _ _ _ _ _ HC Hpin
              (ffe_other bH bD surface_collision._find_floor_from_list ltac:(idne) ltac:(idne)) Sc)
    as (nd2 & ax2 & ay2 & az2 & aph2 & fl & Hargs2 & _ & -> & Hsc & Cp).
  eapply ev_args in Hargs2;
    [| exact (ffe_H bH bD) | ptg; reflexivity | ptg; reflexivity | ptg; reflexivity].
  destruct Hargs2 as (Lnd & -> & -> & -> & ->).
  assert (nd2 = hd0) by (revert Lnd; ptg; intros E; congruence). subst nd2.
  pose proof (Cp X Y Z _ eq_refl eq_refl eq_refl (ol_fwd _ _ _ UA (Hwfs _ FH) OL0)
                (pass_fwd _ _ _ UA Hn0 P0)) as Nfl.
  destruct Hsc as [(_ & ->) | (OLf & h & Sth & _ & Hhit)]; [congruence |].
  clear Cp Sc.
  pose proof Hhit as Hhit'.
  destruct Hhit' as (bf & ofl & X' & Z' & _ & _ & _ & _ & _ & _ & _ & _ & _ & _ & Ef & EX' & EZ' & _).
  subst fl. injection EX' as <-. injection EZ' as <-.
  pose proof (on_list_back _ _ _ (Hwfs _ FH) _ _ UA OLf) as OLm.
  destruct (Hsf _ _ _ FH OLm) as (Vbf & Nbf & ty & Lty & Nty).
  assert (Hh : Hit_at ge m h).
  { exists hd0, (Vptr bf ofl), (Vint X), (Vint Z). split; [exact FH | split; [exact OLm |]].
    split; [exact (hit_transfer _ _ _ _ _ _ _ (fun ch z => ld_back _ ch bf z UA Vbf Nbf) Hhit) |].
    split; [exists X; split; [reflexivity | exact (ycast_s16 _ _ HyX)]
           | exists Z; split; [reflexivity | exact (ycast_s16 _ _ HyZ)]]. }
  pose proof (HB h Hh) as HBh.
  cbn [Mem.storev] in Sth. rewrite Ptrofs.unsigned_zero in Sth.
  pose proof (U_new _ _ _ _ _ _ UA HnvH Sth) as US.
  assert (LH : Mem.load Mfloat32 MS bH 0 = Some (Vsingle h))
    by (rewrite (Mem.load_store_same _ _ _ _ _ _ Sth); reflexivity).
  assert (DS : (dF = Vint Int.zero /\ Mem.load Mfloat32 MS bD 0 = Some (Vsingle c11000))
               \/ (exists b o, dF = Vptr b o)).
  { destruct DC as [(E & L) | D]; [left; split; [exact E |] | right; exact D].
    rewrite (Mem.load_store_other _ _ _ _ _ _ Sth) by (left; exact (not_eq_sym HHD)). exact L. }
  clear DC UA.
  apply x_set in Ss as (vfl & Evfl & -> & -> & _).
  apply ev_tv in Evfl. rewrite PTree.gss in Evfl. injection Evfl as <-.
  (* the SURFACE_INTANGIBLE test: never re-searches *)
  sq S le15 M15.
  assert (IG : le15 ! surface_collision._floor = Some (Vptr bf ofl)
               /\ le15 ! surface_collision._dynamicFloor = Some dF
               /\ le15 ! surface_collision._pfloor = Some (Vptr bpf opf)
               /\ forall ch b z w, (b = bH \/ b = bD) ->
                    Mem.load ch MS b z = Some w -> Mem.load ch M15 b z = Some w).
  { apply x_seq in S as [(? & leJ & MJ & ? & S1 & S2) | (S1 & Hn)]; [| noab S1 Hn].
    apply x_set in S1 as (v13 & _ & -> & -> & _).
    apply x_ite in S2 as (v13' & b13 & _ & _ & S2).
    destruct b13; cbv beta iota in S2.
    - apply x_seq in S2 as [(? & leK & MK & ? & S3 & S4) | (S3 & Hn)]; [| noab S3 Hn].
      apply x_ite in S3 as (vg & bg & Evg & Hbg & S3).
      eapply gp_true in Evg; [| ptg; reflexivity | exact Hbg]. rewrite Evg in S3.
      cbv beta iota in S3.
      apply x_seq in S3 as [(? & leL & ML & ? & S5 & S6) | (S5 & Hn)]; [| noab S5 Hn].
      apply x_set in S5 as (v15 & Ev15 & -> & -> & _).
      eapply ev_field in Ev15; [| reflexivity | exact (fo_type _ HC) | reflexivity].
      destruct Ev15 as (l5 & o5 & Hb5 & L5).
      apply ev_deref_s in Hb5. revert Hb5; ptg; intros Hb5. injection Hb5 as <- <-.
      cbn [Mem.loadv] in L5. rewrite Ptrofs.add_zero in L5.
      rewrite (ld_fwd _ _ _ _ _ US Nbf Lty) in L5. injection L5 as <-.
      apply x_set in S6 as (w6 & Ew6 & -> & -> & _).
      eapply ev_eq18 in Ew6; [| ptg; reflexivity | exact Nty]. subst w6.
      apply x_ite in S4 as (v4 & b4 & Ev4 & Hb4 & S4).
      apply ev_tv in Ev4. revert Ev4; ptg; intros Ev4. injection Ev4 as <-.
      cbn in Hb4. injection Hb4 as <-. cbv beta iota in S4. inv S4.
      split; [ptg; reflexivity | split; [ptg; reflexivity | split; [ptg; exact Lp | auto]]].
    - apply x_asg in S2 as (bg & og & bfg & vg & vg' & Hlg & _ & _ & Hag & -> & _).
      eapply (lv_static ge bH bD) in Hlg as (Hsg & -> & ->); [| left; reflexivity].
      destruct (Hst _ _ ltac:(left; reflexivity) Hsg) as (Vg & _).
      split; [ptg; reflexivity | split; [ptg; reflexivity | split; [ptg; exact Lp |]]].
      intros ch b z w Hb Lw. eapply ld_keep_asg; [exact Hag | | exact Lw].
      intros ->. destruct Hb as [-> | ->]; contradiction. }
  clear S. destruct IG as (IGf & IGd & IGp & IGl).
  (* the miss counter: floor is not NULL *)
  sq S le16 M16.
  apply x_ite in S as (vm & bm & Evm & Hbm & S).
  eapply eqn_false in Evm; [| exact IGf | exact Hbm]. rewrite Evm in S. cbv beta iota in S. inv S.
  (* dynamicHeight > height ? *)
  sq S le17 M17.
  assert (DY : exists F, le17 ! surface_collision._floor = Some F /\ (exists b o, F = Vptr b o)
               /\ le17 ! surface_collision._pfloor = Some (Vptr bpf opf)).
  { apply x_seq in S as [(? & ? & ? & ? & S1 & S2) | (S1 & Hn)]; [| noab S1 Hn].
    apply x_set in S1 as (v9 & Ev9 & -> & -> & _).
    pose proof (ev_lvar _ _ _ _ _ _ _ (ffe_D bH bD) Ev9) as L9.
    apply x_seq in S2 as [(? & ? & ? & ? & S3 & S4) | (S3 & Hn)]; [| noab S3 Hn].
    apply x_set in S3 as (v10 & Ev10 & -> & -> & _).
    pose proof (ev_lvar _ _ _ _ _ _ _ (ffe_H bH bD) Ev10) as L10.
    rewrite (IGl _ _ _ _ (or_introl eq_refl) LH) in L10. injection L10 as <-.
    apply x_ite in S4 as (vc & bc & Evc & Hbc & S4).
    destruct DS as [(-> & LDn) | (bd & od & ->)].
    - rewrite (IGl _ _ _ _ (or_intror eq_refl) LDn) in L9. injection L9 as <-.
      eapply ev_fgt in Evc; [| ptg; reflexivity | ptg; reflexivity]. rewrite Evc in Hbc.
      rewrite HBh in Hbc. cbn in Hbc. injection Hbc as <-. cbv beta iota in S4. inv S4.
      exists (Vptr bf ofl). split; [ptg; exact IGf | split; [eauto | ptg; exact IGp]].
    - destruct bc; cbv beta iota in S4.
      + apply x_seq in S4 as [(? & ? & ? & ? & S5 & S6) | (S5 & Hn)]; [| noab S5 Hn].
        apply x_set in S5 as (vF & EvF & -> & -> & _).
        apply ev_tv in EvF. revert EvF; ptg; intros EvF. rewrite IGd in EvF. injection EvF as <-.
        apply x_seq in S6 as [(? & ? & ? & ? & S7 & S8) | (S7 & Hn)]; [| noab S7 Hn].
        apply x_set in S7 as (? & _ & -> & -> & _).
        apply x_asg in S8 as (? & ? & ? & ? & ? & _ & _ & _ & _ & -> & _).
        exists (Vptr bd od). split; [ptg; reflexivity | split; [eauto | ptg; exact IGp]].
      + inv S4. exists (Vptr bf ofl). split; [ptg; exact IGf | split; [eauto | ptg; exact IGp]]. }
  clear S. destruct DY as (F & LF & (bF & oF & ->) & LP).
  (* *pfloor := floor *)
  sq S le18 M18.
  apply x_asg in S as (b18 & o18 & bf18 & v18 & v18' & Hl18 & Ev18 & Ec18 & Ha18 & -> & _).
  eapply lv_deref_tv in Hl18 as (E18a & E18b & E18c); [| exact LP]. subst b18 o18 bf18.
  apply ev_tv in Ev18. rewrite LF in Ev18. injection Ev18 as <-.
  cbn [typeof] in Ec18, Ha18. apply cast_pp in Ec18. subst v18'.
  pose proof Ha18 as St18. eapply (asg_store _ _ _ _ _ _ _ Mint32) in St18; [| reflexivity].
  assert (L18 : Mem.load Mint32 M18 bpf (Ptrofs.unsigned opf) = Some (Vptr bF oF))
    by (rewrite (Mem.load_store_same _ _ _ _ _ _ St18); reflexivity).
  (* gNumCalls.floor++ *)
  sq S le19 M19.
  apply x_seq in S as [(? & ? & ? & ? & S1 & S2) | (S1 & Hn)]; [| noab S1 Hn].
  apply x_set in S1 as (? & _ & -> & -> & _).
  apply x_asg in S2 as (bc & oc & bfc & vc & vc' & Hlc & _ & _ & Hac & -> & _).
  destruct (lv_calls_floor ge bH bD HC _ _ _ _ _ Hlc) as (Hsc & -> & ->).
  destruct (Hst _ _ ltac:(right; right; left; reflexivity) Hsc) as (_ & Hnc).
  pose proof (ld_keep_asg _ _ _ _ _ _ _ _ _ _ _ _ Hac (not_eq_sym Hnc) L18) as L19.
  (* return height *)
  apply x_seq in Hx as [(? & ? & ? & ? & S1 & S2) | (S1 & Hn)]; [| noab S1 Hn].
  apply x_set in S1 as (? & _ & -> & -> & _).
  inv S2.
  exists (Vptr bF oF). split; [exact L19 | discriminate].
Qed.

End FC.

(* THE THEOREM: at an in-bounds point (the s16 casts of xPos, zPos inside
   +-LEVEL_BOUNDARY_MAX, yPos at or above the death plane's reach), with the
   death plane on every static floor cell, find_floor stores a non-NULL floor
   into *pfloor.  The other premises are what any caller's world fact gives:
   *pfloor and the statics apart from the lists, static floor surfaces whose
   type is not SURFACE_INTANGIBLE, and static floor heights >= -11000. *)
Theorem ff_complete : forall (ge : genv), cenv_has ge -> ffl_pinned ge ->
    forall m xv yv zv bpf opf t m' vres X Y Z,
      ycast xv = Vint X -> ycast yv = Vint Y -> ycast zv = Vint Z ->
      (-8192 < Int.signed X < 8192)%Z -> (-8269 <= Int.signed Y <= 32767)%Z ->
      (-8192 < Int.signed Z < 8192)%Z ->
      Mem.valid_block m bpf ->
      (forall id b, In id ff_statics -> Genv.find_symbol ge id = Some b ->
         Mem.valid_block m b /\ b <> bpf) ->
      dp_lists ge m ->
      (forall bp, Genv.find_symbol ge surface_collision._gStaticSurfacePartition = Some bp ->
         bp <> bpf) ->
      (forall hd, floor_head ge m hd -> wf_list m (fun b => b = bpf) hd) ->
      (forall hd b o, floor_head ge m hd -> on_list m hd (Vptr b o) ->
         Mem.valid_block m b /\ b <> bpf
         /\ exists ty, Mem.load Mint16signed m b (Ptrofs.unsigned o) = Some (Vint ty)
              /\ Int.signed ty <> 18%Z) ->
      (forall h, Hit_at ge m h -> Float32.cmp Cgt c11000 h = false) ->
      eval_funcall function_entry2 ge m (Internal surface_collision.f_find_floor)
        [xv; yv; zv; Vptr bpf opf] t m' vres ->
      exists F, Mem.loadv Mint32 m' (Vptr bpf opf) = Some F /\ F <> Vint Int.zero.
Proof.
  intros ge HC Hpin m xv yv zv bpf opf t m' vres X Y Z HyX HyY HyZ HbX HbY HbZ Hpv Hst Hdp Hsp
    Hwfs Hsf HB H.
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
  assert (U0 : Mem.unchanged_on (keep m (fun b => b = bpf)) m mB)
    by (eapply Mem.unchanged_on_trans; eapply Mem.alloc_unchanged_on; eassumption).
  match goal with Hb : bind_parameter_temps _ _ _ = Some _ |- _ =>
    cbn [bind_parameter_temps surface_collision.f_find_floor fn_params] in Hb; injection Hb as <- end.
  match goal with Hx : exec_stmt _ _ _ _ _ _ _ _ _ _ |- _ =>
    eapply (body_c ge m bpf bH bD opf xv yv zv X Y Z HC Hpin HnvH HnvD HHD Hpv HyX HyY HyZ
              HbX HbY HbZ Hst Hdp Hsp Hwfs Hsf HB) in Hx as (F & LF & NF);
      [| ptg; reflexivity | ptg; reflexivity | ptg; reflexivity | ptg; reflexivity | exact U0] end.
  match goal with Hf : Mem.free_list ?M _ = Some ?R |- _ =>
    first [ change (Mem.free_list M [(bH, 0, 4); (bD, 0, 4)] = Some R) in Hf
          | change (Mem.free_list M [(bD, 0, 4); (bH, 0, 4)] = Some R) in Hf ];
    cbn [Mem.free_list] in Hf end.
  assert (NpH : bpf <> bH) by (intros ->; contradiction).
  assert (NpD : bpf <> bD) by (intros ->; contradiction).
  match goal with Hf : (match Mem.free ?M ?b1 0 4 with Some _ => _ | None => _ end) = Some _ |- _ =>
    destruct (Mem.free M b1 0 4) as [M4|] eqn:F1; [| discriminate Hf] end.
  match goal with Hf : (match Mem.free ?M ?b1 0 4 with Some _ => _ | None => _ end) = Some _ |- _ =>
    destruct (Mem.free M b1 0 4) as [M5|] eqn:F2; [| discriminate Hf]; injection Hf as <- end.
  exists F. split; [| exact NF].
  cbn [Mem.loadv] in *.
  rewrite (Mem.load_free _ _ _ _ _ F2) by (left; first [exact NpH | exact NpD]).
  rewrite (Mem.load_free _ _ _ _ _ F1) by (left; first [exact NpH | exact NpD]).
  exact LF.
Qed.
