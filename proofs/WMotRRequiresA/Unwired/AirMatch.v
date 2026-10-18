(* ====================================================================== *)
(* AirMatch (unwired, GOAL 2): reading the air-step walk's outcomes as     *)
(* catalog moves.  Piece 1: the pos[1] terms.                               *)
(*                                                                          *)
(* The walk (SymExec2 over the real perform_air_step) leaves pos[1] as one *)
(* of: the 4-quarter sum, k real quarter adds followed by j adds of +0.0f  *)
(* (a ceiling zeroed vel; each remaining quarter computes pos + 0/4), or a *)
(* floor height.  [qrec] recognises the quarter sums syntactically, and    *)
(* [qrec_den] says what they denote: exactly quarter_steps k y q when j=0, *)
(* and the same REAL otherwise (x + 0.0f = x as a real, for every float).  *)
(* ====================================================================== *)

From Coq Require Import ZArith Reals List Lia Lra.
From compcert Require Import Coqlib Maps AST Integers Floats Values Memory Ctypes Cop Clight.
From Flocq Require Import Binary Bits Defs Raux Zaux Generic_fmt FLT.
From SM64.Proofs Require Import Interp.SymExec2 HeightInvariant HeightBudgetArith WMotRLevel.
From SM64.Proofs.WMotRRequiresA Require Import HeightFloatSteps.
From SM64.Proofs.WMotRRequiresA.Unwired Require Import FloorList FloorHeight FloorBound.
Import ListNotations.

Local Open Scope R_scope.
Local Transparent Float32.add Float32.div Float32.cmp Float32.compare.

(* ---- x + 0.0f is x, as a real ---- *)

Lemma add_zero_R2 : forall x, R2 (Float32.add x Float32.zero) = R2 x.
Proof.
  intros [s | s | s pl Hpl | s mx ex Hx].
  - destruct s; reflexivity.
  - destruct s; reflexivity.
  - reflexivity.
  - unfold Float32.add.
    set (x := B754_finite 24 128 s mx ex Hx).
    assert (Fx : is_finite 24 128 x = true) by reflexivity.
    pose proof (Bplus_correct 24 128 eq_refl eq_refl Float32.binop_nan BinarySingleNaN.mode_NE x Float32.zero Fx eq_refl) as HB.
    replace (R2 Float32.zero) with 0%R in HB by reflexivity.
    rewrite Rplus_0_r in HB.
    rewrite (round_generic radix2 (SpecFloat.fexp 24 128) (BinarySingleNaN.round_mode BinarySingleNaN.mode_NE) (B2R 24 128 x)
               (generic_format_B2R 24 128 x)) in HB.
    rewrite Rlt_bool_true in HB by exact (abs_B2R_lt_emax 24 128 x).
    exact (proj1 HB).
Qed.

Lemma add_zero_F32 : forall x, F32 x = true -> F32 (Float32.add x Float32.zero) = true.
Proof.
  intros x Fx. unfold Float32.add.
  pose proof (Bplus_correct 24 128 eq_refl eq_refl Float32.binop_nan BinarySingleNaN.mode_NE x Float32.zero Fx eq_refl) as HB.
  replace (R2 Float32.zero) with 0%R in HB by reflexivity.
  rewrite Rplus_0_r in HB.
  rewrite (round_generic radix2 (SpecFloat.fexp 24 128) (BinarySingleNaN.round_mode BinarySingleNaN.mode_NE) (B2R 24 128 x)
             (generic_format_B2R 24 128 x)) in HB.
  rewrite Rlt_bool_true in HB by exact (abs_B2R_lt_emax 24 128 x).
  destruct HB as (_ & H & _). first [exact H | rewrite H; exact Fx | rewrite H, Fx; reflexivity].
Qed.

(* ---- the pos[1] term recogniser ---- *)

Definition tf : type := Tfloat Ctypes.F32 noattr.

Definition is_tf (t : type) : bool := if type_eq t tf then true else false.

Definition is_f (v : val) (f : float32) : bool :=
  match v with Vsingle g => if Float32.eq_dec g f then true else false | _ => false end.

(* the quarter q = vel[1] / 4.0f, with vel[1] the entry cell (rM, oV) *)
Definition is_q (rM : positive) (oV : Z) (a : sval) : bool :=
  match a with
  | Sbinop Cop.Odiv (Sinit r o Mfloat32) t1 (Sconst v) t2 =>
      Pos.eqb r rM && Z.eqb o oV && is_tf t1 && is_tf t2 && is_f v f4
  | _ => false
  end.

(* k real quarter adds on the entry cell (rM, oY), then j adds of +0.0f *)
Fixpoint qrec (rM : positive) (oY oV : Z) (a : sval) : option (nat * nat) :=
  match a with
  | Sinit r o Mfloat32 => if Pos.eqb r rM && Z.eqb o oY then Some (O, O) else None
  | Sbinop Cop.Oadd a1 t1 a2 t2 =>
      if is_tf t1 && is_tf t2 then
        match qrec rM oY oV a1 with
        | Some (k, j) =>
            if is_q rM oV a2 then (match j with O => Some (S k, O) | _ => None end)
            else match a2 with
                 | Sconst v => if is_f v Float32.zero then Some (k, S j) else None
                 | _ => None
                 end
        | None => None
        end
      else None
  | _ => None
  end.

Fixpoint add_zeros (j : nat) (x : float32) : float32 :=
  match j with O => x | S j' => Float32.add (add_zeros j' x) Float32.zero end.

Lemma add_zeros_R2 : forall j x, R2 (add_zeros j x) = R2 x.
Proof. induction j; intros x; cbn [add_zeros]; [reflexivity | rewrite add_zero_R2; apply IHj]. Qed.

Lemma add_zeros_F32 : forall j x, F32 x = true -> F32 (add_zeros j x) = true.
Proof. induction j; intros x H; cbn [add_zeros]; [exact H | apply add_zero_F32, IHj, H]. Qed.

Lemma is_tf_eq : forall t, is_tf t = true -> t = tf.
Proof. unfold is_tf; intros t H. destruct (type_eq t tf); [exact e | discriminate]. Qed.

Lemma is_f_eq : forall v f, is_f v f = true -> v = Vsingle f.
Proof.
  unfold is_f; intros w f H. destruct w as [| | | | g |]; try discriminate.
  destruct (Float32.eq_dec g f); [subst; reflexivity | discriminate].
Qed.

Section DEN.
Variables (ge : genv) (m0 : mem) (E : senv) (bm : block) (rM : positive) (oY oV : Z) (y v : float32).
Hypothesis HbM : e_blk E rM = bm.
Hypothesis Hbase : e_base E rM = Ptrofs.zero.
Hypothesis HY : Mem.load Mfloat32 m0 bm oY = Some (Vsingle y).
Hypothesis HV : Mem.load Mfloat32 m0 bm oV = Some (Vsingle v).

Lemma is_q_den : forall a, is_q rM oV a = true -> den ge m0 E a = Some (Vsingle (Float32.div v f4)).
Proof.
  intros a H. destruct a; try discriminate. destruct op; try discriminate.
  destruct a1; try discriminate. destruct ch; try discriminate. destruct a2; try discriminate.
  cbn [is_q] in H. repeat rewrite andb_true_iff in H.
  destruct H as ((((Hr & Ho) & H1) & H2) & Hf).
  apply Pos.eqb_eq in Hr. apply Z.eqb_eq in Ho. apply is_tf_eq in H1. apply is_tf_eq in H2.
  apply is_f_eq in Hf. rewrite Hr, Ho, H1, H2, Hf.
  cbn [den]. unfold addr. rewrite HbM, Hbase, Ptrofs.unsigned_zero, Z.add_0_l, HV. reflexivity.
Qed.

Lemma qrec_den : forall a kq jz, qrec rM oY oV a = Some (kq, jz) ->
  den ge m0 E a = Some (Vsingle (add_zeros jz (quarter_steps kq y (Float32.div v f4)))).
Proof.
  induction a; intros kq jz H; cbn [qrec] in H; try discriminate.
  - destruct ch; try discriminate.
    destruct (Pos.eqb r rM && Z.eqb ofs oY) eqn:E1; [| discriminate]. injection H as <- <-.
    apply andb_true_iff in E1 as (Hr & Ho). apply Pos.eqb_eq in Hr. apply Z.eqb_eq in Ho. rewrite Hr, Ho.
    cbn [den]. unfold addr. rewrite HbM, Hbase, Ptrofs.unsigned_zero, Z.add_0_l, HY. reflexivity.
  - destruct op; try discriminate.
    destruct (is_tf t1 && is_tf t2) eqn:T; [| discriminate].
    apply andb_true_iff in T as (T1 & T2). apply is_tf_eq in T1. apply is_tf_eq in T2. rewrite T1, T2.
    destruct (qrec rM oY oV a1) as [[k1 j1]|] eqn:R1; [| discriminate].
    specialize (IHa1 _ _ eq_refl).
    destruct (is_q rM oV a2) eqn:Q.
    + destruct j1; [| discriminate]. injection H as <- <-.
      cbn [den]. rewrite IHa1, (is_q_den _ Q). reflexivity.
    + destruct a2; try discriminate. destruct (is_f v0 Float32.zero) eqn:Z0; [| discriminate].
      apply is_f_eq in Z0. rewrite Z0. injection H as <- <-.
      cbn [den]. rewrite IHa1. reflexivity.
Qed.

End DEN.

(* ---- the vel[1] outcomes sit at or below gravity's ---- *)

(* the walk leaves vel[1] as -75 (the clamp branch) or vel - 4.0f (the other
   one); both are <= gravity f4 vel as reals, branch facts not needed *)
Lemma vel_clamp_le : forall v, F32 v = true -> Rabs (R2 v) <= 128 ->
  R2 fm75 <= R2 (gravity f4 v).
Proof.
  intros v Fv Hv. rewrite B2R_fm75.
  destruct (gravity_spec2 f4 v F32_f4 Fv (or_intror B2R_f4) Hv) as [(_ & H) | (H & _)]; lra.
Qed.

Lemma vel_sub_le : forall v, F32 v = true -> Rabs (R2 v) <= 128 ->
  R2 (Float32.sub v f4) <= R2 (gravity f4 v).
Proof.
  intros v Fv Hv.
  destruct (f32_sub_val v f4 Fv F32_f4) as [Hval Hfin].
  { rewrite B2R_f4. eapply Rle_trans; [| apply (bpow_le radix2 8 100); lia].
    simpl. apply Rabs_le. apply Rabs_le_inv in Hv. split; lra. }
  unfold gravity. destruct (Float32.cmp Clt (Float32.sub v f4) fm75) eqn:Hc; [| lra].
  unfold Float32.cmp, Float32.compare in Hc.
  rewrite Binary.Bcompare_correct in Hc by first [exact Hfin | exact F32_fm75].
  rewrite Hval in Hc |- *.
  destruct (Rcompare_spec (rnd (R2 v - R2 f4)) (R2 fm75)) as [H | H | H];
    simpl in Hc; try discriminate; lra.
Qed.

Lemma sub_ge_m75 : forall v, F32 v = true -> Rabs (R2 v) <= 128 ->
  Float32.cmp Clt (Float32.sub v f4) fm75 = false ->
  R2 fm75 <= R2 (Float32.sub v f4) /\ F32 (Float32.sub v f4) = true.
Proof.
  intros v Fv Hv Hc.
  destruct (f32_sub_val v f4 Fv F32_f4) as [Hval Hfin].
  { rewrite B2R_f4. eapply Rle_trans; [| apply (bpow_le radix2 8 100); lia].
    simpl. apply Rabs_le. apply Rabs_le_inv in Hv. split; lra. }
  split; [| exact Hfin].
  unfold Float32.cmp, Float32.compare in Hc.
  rewrite Binary.Bcompare_correct in Hc by first [exact Hfin | exact F32_fm75].
  destruct (Rcompare_spec (R2 (Float32.sub v f4)) (R2 fm75)) as [H | H | H];
    simpl in Hc; try discriminate; lra.
Qed.

(* ---- classifying one walk outcome ---- *)

Definition fm4 : float32 := Float32.of_bits (Int.repr 3229614080).  (* 0xC0800000 *)

Lemma B2R_fm4 : R2 fm4 = -4.
Proof. unfold fm4. vm_compute (Float32.of_bits _). unfold Binary.B2R, F2R. simpl. lra. Qed.

(* the MarioState / Object cells the classes speak about *)
Definition oA : Z := 12.   Definition oS : Z := 24.   Definition oT : Z := 26.
Definition oY : Z := 64.   Definition oV : Z := 76.   Definition oG : Z := 36.

Inductive aclass : Type :=
  | Cair                 (* 4 real quarters, vel to gravity's or below *)
  | Ccut (k : nat).      (* k real quarters then +0.0f adds, vel = -4 *)

Definition vel_grav (rM : positive) (a : sval) : bool :=
  match a with
  | Sbinop Cop.Osub (Sinit r o Mfloat32) t1 (Sconst c) t2 =>
      Pos.eqb r rM && Z.eqb o oV && is_tf t1 && is_tf t2 && is_f c f4
  | Sconst c => is_f c fm75
  | _ => false
  end.

(* the path's fact that the clamp branch was not taken: !(vel - 4.0f < -75.0f) *)
Definition is_gfact (rM : positive) (f : fact) : bool :=
  match f with
  | Fbool (Sbinop Cop.Olt (Sbinop Cop.Osub (Sinit r o Mfloat32) t1 (Sconst c1) t2) t3 (Sconst c2) t4) _ false =>
      Pos.eqb r rM && Z.eqb o oV && is_tf t1 && is_tf t2 && is_tf t3 && is_tf t4
      && is_f c1 f4 && is_f c2 fm75
  | _ => false
  end.

(* vel[1] is the clamp, or vel - 4.0f on a path that did not clamp *)
Definition vel_ok (rM : positive) (pc : list fact) (a : sval) : bool :=
  match a with
  | Sconst _ => vel_grav rM a
  | _ => vel_grav rM a && existsb (is_gfact rM) pc
  end.

Definition vel_cut (a : sval) : bool :=
  match a with Sconst c => is_f c fm4 | _ => false end.

Definition sveqb (a b : sval) : bool := if sval_eq a b then true else false.

Section CLS.
Variable ld : positive -> Z -> memory_chunk -> option sval.  (* the outcome's cells *)
Variable ic : positive -> Z -> memory_chunk -> sval.          (* the entry's cells *)
Variable pc : list fact.                                      (* the outcome's path facts *)
Variables rM rO : positive.

Definition same_cell (o : Z) (ch : memory_chunk) : bool :=
  match ld rM o ch with Some a => sveqb a (ic rM o ch) | None => false end.

(* a landing: pos[1] = gfx.pos[1] := the entry floorHeight cell, or a value
   find_floor returned (a fresh name), named by find_floor's height fact
   Fuser kH [height; yPos] (FloorExec.c_ff) with yPos a quarter-step term *)
Variable kH : positive.
Definition oF : Z := 112.
Definition hfact (n : positive) (f : fact) : bool :=
  match f with
  | Fuser k [Sfresh n'; ya] =>
      Pos.eqb k kH && Pos.eqb n' n
      && match qrec rM oY oV ya with Some (kq, _) => Nat.leb kq 4 | None => false end
  | _ => false
  end.
Definition is_land (a : sval) : bool :=
  match a with
  | Sinit r o Mfloat32 => Pos.eqb r rM && Z.eqb o oF
  | Sfresh n => existsb (hfact n) pc
  | _ => false
  end.

(* the step did not land: the path took the branch
   !(nextPos[1] <= floorHeight) (mario_step.c perform_air_quarter_step),
   with floorHeight the entry m->floorHeight (a floorless quarter) or a
   find_floor height (is_land's two forms); a zero-quarter cut leaves pos *)
Definition is_above (py : sval) (f : fact) : bool :=
  match f with
  | Fbool (Sbinop Cop.Ole a t1 x t2) _ false => sveqb a py && is_tf t1 && is_tf t2 && is_land x
  | _ => false
  end.
Definition above (py : sval) : bool := existsb (is_above py) pc.

Definition aclass_of : option aclass :=
  if same_cell oA Mint32 && same_cell oS Mint16unsigned && same_cell oT Mint16unsigned then
    match ld rM oY Mfloat32, ld rM oV Mfloat32, ld rO oG Mfloat32 with
    | Some py, Some vy, Some gy =>
        if sveqb gy py then
          match qrec rM oY oV py with
          | Some (k, j) =>
              if vel_cut vy then
                (if Nat.leb k 4 && (Nat.eqb k 0 || above py) then Some (Ccut k) else None)
              else if vel_ok rM pc vy then
                (match k, j with 4%nat, O => if above py then Some Cair else None | _, _ => None end)
              else None
          | None => None
          end
        else None
    | _, _, _ => None
    end
  else None.

Definition land_ok : bool :=
  same_cell oA Mint32 && same_cell oS Mint16unsigned && same_cell oT Mint16unsigned
  && match ld rM oY Mfloat32, ld rM oV Mfloat32, ld rO oG Mfloat32 with
     | Some py, Some vy, Some gy => sveqb gy py && is_land py && (vel_cut vy || vel_ok rM pc vy)
     | _, _, _ => false
     end.

(* every outcome: m->marioObj still points at Mario's object, and
   floorHeight is the entry cell or a find_floor height *)
Definition oMO : Z := 136.
Definition cells_ok : bool :=
  match ld rM oMO Mint32 with
  | Some (Sptr r o) => Pos.eqb r rO && Ptrofs.eq o Ptrofs.zero
  | _ => false
  end
  && match ld rM oF Mfloat32 with Some a => is_land a | None => false end.

Definition outcome_ok : bool :=
  cells_ok && match aclass_of with Some _ => true | None => land_ok end.
End CLS.

(* ---- what a class says about the outcome's memory ---- *)

Section CLS_SOUND.
Variables (ge : genv) (nbase : positive) (R0 : list (positive * Z)) (gtab : list (ident * positive))
  (kv : list (positive * Z * memory_chunk * sval)) (m0 : mem)
  (uf : positive -> list (option val) -> Prop) (gp : meminj).
Hypothesis gp_old : forall b x, gp b = Some x -> Plt b (Mem.nextblock m0).
Variables (E : senv) (m : mem) (g : gst) (rM rO : positive) (y v : float32).
Variable kH : positive.
Hypothesis MM : MMg ge nbase R0 gtab kv m0 uf gp E m g.
(* the height fact's meaning (AirRun.ufW) *)
Hypothesis HUH : forall vs, uf kH vs ->
  exists h yv, vs = [Some (Vsingle h); Some yv] /\ HPi (Hit_at ge m0) (ycast yv) h /\ Hit_at ge m0 h.
Hypothesis HbM : e_base E rM = Ptrofs.zero.
Hypothesis HbO : e_base E rO = Ptrofs.zero.
Hypothesis HY : Mem.load Mfloat32 m0 (e_blk E rM) oY = Some (Vsingle y).
Hypothesis HV : Mem.load Mfloat32 m0 (e_blk E rM) oV = Some (Vsingle v).

Local Notation LD := (sload nbase R0 kv g).
Local Notation IC := (init_cell kv).

Lemma ld_sound : forall r o ch a, LD r o ch = Some a ->
  Mem.load ch m (e_blk E r) (addr E r o) = den ge m0 E a.
Proof.
  intros r o ch a L.
  exact (proj1 (sload_sound ge nbase R0 gtab kv (fun _ => None) (fun _ => false) m0 uf gp gp_old
                  E m g r o ch a MM L)).
Qed.

Lemma addr_M : forall o, addr E rM o = o.
Proof. intros o. unfold addr. rewrite HbM, Ptrofs.unsigned_zero. lia. Qed.
Lemma addr_O : forall o, addr E rO o = o.
Proof. intros o. unfold addr. rewrite HbO, Ptrofs.unsigned_zero. lia. Qed.

Lemma same_cell_sound : forall o ch, same_cell LD IC rM o ch = true ->
  Mem.load ch m (e_blk E rM) o = Mem.load ch m0 (e_blk E rM) o.
Proof.
  intros o ch H. unfold same_cell in H.
  destruct (LD rM o ch) as [a|] eqn:L; [| discriminate].
  unfold sveqb in H. destruct (sval_eq a (IC rM o ch)) as [->|]; [| discriminate].
  pose proof (ld_sound _ _ _ _ L) as D. rewrite addr_M in D. rewrite D.
  destruct MM as (EO & _).
  rewrite (proj1 (init_cell_den ge nbase R0 gtab kv m0 gp E rM o ch EO)), addr_M. reflexivity.
Qed.

Lemma vel_grav_den : forall a, vel_grav rM a = true ->
  den ge m0 E a = Some (Vsingle (Float32.sub v f4)) \/ den ge m0 E a = Some (Vsingle fm75).
Proof.
  intros a H. destruct a; try discriminate.
  - cbn [vel_grav] in H. apply is_f_eq in H. right. cbn [den]. rewrite H. reflexivity.
  - destruct op; try discriminate. destruct a1; try discriminate. destruct ch; try discriminate.
    destruct a2; try discriminate.
    cbn [vel_grav] in H. repeat rewrite andb_true_iff in H.
    destruct H as ((((Hr & Ho) & H1) & H2) & Hf).
    apply Pos.eqb_eq in Hr. apply Z.eqb_eq in Ho. apply is_tf_eq in H1. apply is_tf_eq in H2.
    apply is_f_eq in Hf. rewrite Hr, Ho, H1, H2, Hf.
    left. cbn [den]. rewrite HbM, Ptrofs.unsigned_zero, Z.add_0_l. rewrite HV. reflexivity.
Qed.

Lemma vel_ok_den : forall a, vel_ok rM (g_pc g) a = true ->
  (den ge m0 E a = Some (Vsingle (Float32.sub v f4))
   /\ Float32.cmp Clt (Float32.sub v f4) fm75 = false)
  \/ den ge m0 E a = Some (Vsingle fm75).
Proof.
  intros a H.
  assert (G : vel_grav rM a = true) by (destruct a; cbn [vel_ok] in H;
    first [exact H | apply andb_true_iff in H; apply H]).
  destruct (vel_grav_den a G) as [D | D]; [left | right; exact D].
  split; [exact D |].
  destruct a; cbn [vel_ok] in H; try (cbn [vel_grav] in G; discriminate).
  - cbn [den] in D. injection D as D. cbn [vel_grav] in G. apply is_f_eq in G. rewrite G in D.
    injection D as D. rewrite <- D. vm_compute. reflexivity.
  -  apply andb_true_iff in H as [_ H].
    apply existsb_exists in H as (f & Hin & Hf).
    destruct MM as (_ & _ & _ & _ & _ & _ & PC & _).
    destruct (PC f Hin) as [_ FH].
    destruct f as [c ty b | | |]; try discriminate.
    destruct c; try discriminate. destruct op0; try discriminate.
    destruct c1; try discriminate. destruct op0; try discriminate.
    destruct c1_1; try discriminate. destruct ch; try discriminate.
    destruct c1_2; try discriminate. destruct c2; try discriminate. destruct b; try discriminate.
    cbn [is_gfact] in Hf. repeat rewrite andb_true_iff in Hf.
    destruct Hf as (((((((Hr & Ho) & H1) & H2) & H3) & H4) & Hc1) & Hc2).
    apply Pos.eqb_eq in Hr. apply Z.eqb_eq in Ho.
    apply is_tf_eq in H1. apply is_tf_eq in H2. apply is_tf_eq in H3. apply is_tf_eq in H4.
    apply is_f_eq in Hc1. apply is_f_eq in Hc2.
    rewrite Hr, Ho, H1, H2, H3, H4, Hc1, Hc2 in FH.
    destruct FH as (w & Dw & Bw).
    cbn [den] in Dw. rewrite HbM, Ptrofs.unsigned_zero, Z.add_0_l, HV in Dw.
    cbn in Dw. injection Dw as <-.
    unfold Float32.cmp, cmp_of_comparison.
    destruct (Float32.compare (Float32.sub v f4) fm75) as [[]|]; try reflexivity.
    exfalso. revert Bw. unfold bool_val. destruct (classify_bool ty); cbn;
      try rewrite (Int.eq_false _ _ Int.one_not_zero); cbn; congruence.
Qed.

Lemma vel_cut_den : forall a, vel_cut a = true -> den ge m0 E a = Some (Vsingle fm4).
Proof.
  intros a H. destruct a; try discriminate. cbn [vel_cut] in H. apply is_f_eq in H.
  cbn [den]. rewrite H. reflexivity.
Qed.

(* entry cells unchanged *)
Definition keeps_asT : Prop :=
  Mem.load Mint32 m (e_blk E rM) oA = Mem.load Mint32 m0 (e_blk E rM) oA
  /\ Mem.load Mint16unsigned m (e_blk E rM) oS = Mem.load Mint16unsigned m0 (e_blk E rM) oS
  /\ Mem.load Mint16unsigned m (e_blk E rM) oT = Mem.load Mint16unsigned m0 (e_blk E rM) oT.

Theorem aclass_air : aclass_of LD IC (g_pc g) rM rO kH = Some Cair ->
  F32 v = true -> Rabs (R2 v) <= 128 ->
  keeps_asT
  /\ Mem.load Mfloat32 m (e_blk E rM) oY = Some (Vsingle (air_step_y y v))
  /\ Mem.load Mfloat32 m (e_blk E rO) oG = Some (Vsingle (air_step_y y v))
  /\ exists v', Mem.load Mfloat32 m (e_blk E rM) oV = Some (Vsingle v')
                /\ F32 v' = true /\ R2 fm75 <= R2 v' <= R2 (gravity f4 v).
Proof.
  intros H Fv Hv. unfold aclass_of in H.
  destruct (same_cell LD IC rM oA Mint32) eqn:SA; [| discriminate].
  destruct (same_cell LD IC rM oS Mint16unsigned) eqn:SS; [| discriminate].
  destruct (same_cell LD IC rM oT Mint16unsigned) eqn:ST; [| discriminate].
  cbn [andb] in H.
  destruct (LD rM oY Mfloat32) as [py|] eqn:LY; [| discriminate].
  destruct (LD rM oV Mfloat32) as [vy|] eqn:LV; [| discriminate].
  destruct (LD rO oG Mfloat32) as [gy|] eqn:LG; [| discriminate].
  destruct (sveqb gy py) eqn:GE; [| discriminate].
  unfold sveqb in GE. destruct (sval_eq gy py) as [->|]; [| discriminate].
  destruct (qrec rM oY oV py) as [[k j]|] eqn:Q; [| discriminate].
  destruct (vel_cut vy); [match type of H with (if ?b then _ else _) = _ => destruct b; discriminate end |].
  destruct (vel_ok rM (g_pc g) vy) eqn:VG; [| discriminate].
  destruct k as [|[|[|[|[|k]]]]]; try discriminate. destruct j; [| discriminate].
  match type of H with (if ?b then _ else _) = _ => destruct b; [| discriminate] end.
  pose proof (qrec_den ge m0 E (e_blk E rM) rM oY oV y v eq_refl HbM HY HV py 4 0 Q) as QD.
  cbn [add_zeros] in QD. rewrite <- air_step_y_quarter_steps in QD.
  pose proof (ld_sound _ _ _ _ LY) as DY. pose proof (ld_sound _ _ _ _ LV) as DV.
  pose proof (ld_sound _ _ _ _ LG) as DG.
  rewrite addr_M in DY, DV. rewrite addr_O in DG. rewrite QD in DY, DG.
  split; [repeat split; apply same_cell_sound; assumption |].
  split; [exact DY | split; [exact DG |]].
  destruct (vel_ok_den _ VG) as [(D & C) | D]; rewrite D in DV.
  - destruct (sub_ge_m75 v Fv Hv C) as [L F].
    eexists; split; [exact DV | split; [exact F | split; [exact L | apply vel_sub_le; assumption]]].
  - eexists; split; [exact DV | split; [exact F32_fm75 | split; [lra | apply vel_clamp_le; assumption]]].
Qed.

Theorem aclass_cut : forall k, aclass_of LD IC (g_pc g) rM rO kH = Some (Ccut k) ->
  keeps_asT /\ (k <= 4)%nat
  /\ exists p, R2 p = R2 (quarter_steps k y (Float32.div v f4))
     /\ Mem.load Mfloat32 m (e_blk E rM) oY = Some (Vsingle p)
     /\ Mem.load Mfloat32 m (e_blk E rO) oG = Some (Vsingle p)
     /\ Mem.load Mfloat32 m (e_blk E rM) oV = Some (Vsingle fm4)
     /\ exists j, p = add_zeros j (quarter_steps k y (Float32.div v f4)).
Proof.
  intros k0 H. unfold aclass_of in H.
  destruct (same_cell LD IC rM oA Mint32) eqn:SA; [| discriminate].
  destruct (same_cell LD IC rM oS Mint16unsigned) eqn:SS; [| discriminate].
  destruct (same_cell LD IC rM oT Mint16unsigned) eqn:ST; [| discriminate].
  cbn [andb] in H.
  destruct (LD rM oY Mfloat32) as [py|] eqn:LY; [| discriminate].
  destruct (LD rM oV Mfloat32) as [vy|] eqn:LV; [| discriminate].
  destruct (LD rO oG Mfloat32) as [gy|] eqn:LG; [| discriminate].
  destruct (sveqb gy py) eqn:GE; [| discriminate].
  unfold sveqb in GE. destruct (sval_eq gy py) as [->|]; [| discriminate].
  destruct (qrec rM oY oV py) as [[k j]|] eqn:Q; [| discriminate].
  destruct (vel_cut vy) eqn:VC.
  2:{ destruct (vel_ok rM (g_pc g) vy); [| discriminate].
      destruct k as [|[|[|[|[|k]]]]]; try discriminate; destruct j; try discriminate;
      match type of H with (if ?b then _ else _) = _ => destruct b; discriminate end. }
  destruct (Nat.leb k 4) eqn:K4; [| discriminate]. cbn [andb] in H.
  match type of H with (if ?b then _ else _) = _ => destruct b; [| discriminate] end.
  injection H as <-.
  apply Nat.leb_le in K4.
  pose proof (qrec_den ge m0 E (e_blk E rM) rM oY oV y v eq_refl HbM HY HV py k j Q) as QD.
  pose proof (ld_sound _ _ _ _ LY) as DY. pose proof (ld_sound _ _ _ _ LV) as DV.
  pose proof (ld_sound _ _ _ _ LG) as DG.
  rewrite addr_M in DY, DV. rewrite addr_O in DG. rewrite QD in DY, DG.
  rewrite (vel_cut_den _ VC) in DV.
  split; [repeat split; apply same_cell_sound; assumption |]. split; [exact K4 |].
  eexists; split; [apply add_zeros_R2 | split; [exact DY | split; [exact DG | split; [exact DV | eexists; reflexivity]]]].
Qed.
Lemma ole_den : forall vp x w,
  sem_binary_operation ge Cop.Ole vp tf (Vsingle x) tf m0 = Some w ->
  exists p, vp = Vsingle p /\ w = Val.of_bool (Float32.cmp Cle p x).
Proof.
  intros vp x w H. destruct vp; cbn in H; try discriminate.
  injection H as <-. eexists; split; reflexivity.
Qed.

(* the non-landing fact: pos[1] ended NOT <= the floor height it was
   compared with, the entry floorHeight cell or a find_floor hit *)
Lemma above_sound : forall py, LD rM oY Mfloat32 = Some py ->
  above (g_pc g) rM kH py = true ->
  exists p x, Mem.load Mfloat32 m (e_blk E rM) oY = Some (Vsingle p)
    /\ Float32.cmp Cle p x = false
    /\ (Mem.load Mfloat32 m0 (e_blk E rM) oF = Some (Vsingle x) \/ Hit_at ge m0 x).
Proof.
  intros py LY AB. unfold above in AB. apply existsb_exists in AB as (f & If & Hf).
  pose proof MM as (_ & _ & _ & _ & _ & _ & PC & _).
  destruct (PC f If) as [_ FH].
  destruct f as [c ty b | | |]; try discriminate.
  destruct c as [ | | | | | | | op a t1 x t2 | | ]; try discriminate.
  destruct op; try discriminate. destruct b; try discriminate.
  cbn [is_above] in Hf. repeat rewrite andb_true_iff in Hf.
  destruct Hf as (((Ha & H1) & H2) & HL).
  unfold sveqb in Ha. destruct (sval_eq a py) as [->|]; [| discriminate].
  apply is_tf_eq in H1. apply is_tf_eq in H2. subst t1 t2.
  cbn [fact_holds] in FH. destruct FH as (w & Dw & Bw).
  pose proof (ld_sound _ _ _ _ LY) as DY. rewrite addr_M in DY.
  assert (DX : exists xv, den ge m0 E x = Some (Vsingle xv)
             /\ (Mem.load Mfloat32 m0 (e_blk E rM) oF = Some (Vsingle xv) \/ Hit_at ge m0 xv)).
  { destruct x; try discriminate.
    - destruct ch; try discriminate. cbn [is_land] in HL. apply andb_true_iff in HL as (Hr & Ho).
      apply Pos.eqb_eq in Hr. apply Z.eqb_eq in Ho. subst.
      cbn [den] in Dw |- *. rewrite HbM, Ptrofs.unsigned_zero, Z.add_0_l in Dw |- *.
      destruct (Mem.load Mfloat32 m0 (e_blk E rM) oF) as [xv|] eqn:LF;
        [| destruct (den ge m0 E py); discriminate].
      destruct xv as [| | | | f |];
        try (destruct (den ge m0 E py) as [vp|]; [| discriminate]; destruct vp; cbn in Dw; discriminate).
      exists f. split; [reflexivity | left; reflexivity].
    - cbn [is_land] in HL. apply existsb_exists in HL as (f & If' & Hf').
      destruct f as [| | | k args]; cbn [hfact] in Hf'; try discriminate.
      destruct args as [| a0 [| ya [|]]]; cbn [hfact] in Hf'; try discriminate;
        destruct a0; cbn [hfact] in Hf'; try discriminate.
      repeat rewrite andb_true_iff in Hf'. destruct Hf' as ((Hk & Hn) & _).
      apply Pos.eqb_eq in Hk. apply Pos.eqb_eq in Hn. subst.
      destruct (PC _ If') as (_ & FH'). cbn [fact_holds map] in FH'.
      destruct (HUH _ FH') as (h & yv & Evs & _ & HT). injection Evs as E1 _.
      exists h. split; [exact E1 | right; exact HT]. }
  destruct DX as (xv & Dx & Hx).
  cbn [den] in Dw. rewrite Dx, <- DY in Dw.
  destruct (Mem.load Mfloat32 m (e_blk E rM) oY) as [vp|]; [| discriminate].
  cbn in Dw. destruct (ole_den vp xv w Dw) as (p & -> & ->).
  exists p, xv. split; [reflexivity | split; [| exact Hx]].
  destruct (Float32.cmp Cle p xv); [| reflexivity].
  exfalso. revert Bw. unfold bool_val. destruct (classify_bool ty); cbn;
    try rewrite (Int.eq_false _ _ Int.one_not_zero); cbn; congruence.
Qed.

Theorem aclass_above : forall c, aclass_of LD IC (g_pc g) rM rO kH = Some c ->
  c = Ccut 0 \/
  exists p x, Mem.load Mfloat32 m (e_blk E rM) oY = Some (Vsingle p)
    /\ Float32.cmp Cle p x = false
    /\ (Mem.load Mfloat32 m0 (e_blk E rM) oF = Some (Vsingle x) \/ Hit_at ge m0 x).
Proof.
  intros c H. unfold aclass_of in H.
  destruct (same_cell LD IC rM oA Mint32 && same_cell LD IC rM oS Mint16unsigned
            && same_cell LD IC rM oT Mint16unsigned); [| discriminate].
  destruct (LD rM oY Mfloat32) as [py|] eqn:LY; [| discriminate].
  destruct (LD rM oV Mfloat32) as [vy|]; [| discriminate].
  destruct (LD rO oG Mfloat32) as [gy|]; [| discriminate].
  destruct (sveqb gy py); [| discriminate].
  destruct (qrec rM oY oV py) as [[k j]|]; [| discriminate].
  destruct (vel_cut vy).
  - destruct (Nat.leb k 4); [| discriminate]. cbn [andb] in H.
    destruct (Nat.eqb k 0) eqn:K0.
    + injection H as <-. apply Nat.eqb_eq in K0. subst. left. reflexivity.
    + cbn [orb] in H. destruct (above (g_pc g) rM kH py) eqn:AB; [| discriminate].
      right. exact (above_sound py LY AB).
  - destruct (vel_ok rM (g_pc g) vy); [| discriminate].
    destruct k as [|[|[|[|[|k]]]]]; try discriminate; destruct j; try discriminate.
    destruct (above (g_pc g) rM kH py) eqn:AB; [| discriminate].
    right. exact (above_sound py LY AB).
Qed.

Lemma cells_sound : cells_ok LD (g_pc g) rM rO kH = true ->
  Mem.load Mint32 m (e_blk E rM) oMO = Some (Vptr (e_blk E rO) Ptrofs.zero)
  /\ (Mem.load Mfloat32 m (e_blk E rM) oF = Mem.load Mfloat32 m0 (e_blk E rM) oF
      \/ exists x, Mem.load Mfloat32 m (e_blk E rM) oF = Some (Vsingle x) /\ Hit_at ge m0 x).
Proof.
  intros H. unfold cells_ok in H. apply andb_true_iff in H as (H1 & H2).
  split.
  - destruct (LD rM oMO Mint32) as [a|] eqn:L; [| discriminate].
    destruct a as [| r0 i | | | | | | | |]; try discriminate. apply andb_true_iff in H1 as (Hr & Ho).
    apply Pos.eqb_eq in Hr. subst. pose proof (Ptrofs.eq_spec i Ptrofs.zero) as Ei. rewrite Ho in Ei. subst.
    pose proof (ld_sound _ _ _ _ L) as D. rewrite addr_M in D. rewrite D. cbn [den].
    rewrite HbO. reflexivity.
  - destruct (LD rM oF Mfloat32) as [a|] eqn:L; [| discriminate].
    pose proof (ld_sound _ _ _ _ L) as D. rewrite addr_M in D. rewrite D.
    destruct a; try discriminate.
    + destruct ch; try discriminate. cbn [is_land] in H2. apply andb_true_iff in H2 as (Hr & Ho).
      apply Pos.eqb_eq in Hr. apply Z.eqb_eq in Ho. subst. left.
      cbn [den]. rewrite HbM, Ptrofs.unsigned_zero, Z.add_0_l. reflexivity.
    + cbn [is_land] in H2. apply existsb_exists in H2 as (f & If & Hf).
      destruct f as [| | | k args]; cbn [hfact] in Hf; try discriminate.
      destruct args as [| a0 [| ya [|]]]; cbn [hfact] in Hf; try discriminate;
        destruct a0; cbn [hfact] in Hf; try discriminate.
      repeat rewrite andb_true_iff in Hf. destruct Hf as ((Hk & Hn) & _).
      apply Pos.eqb_eq in Hk. apply Pos.eqb_eq in Hn. subst.
      pose proof MM as (_ & _ & _ & _ & _ & _ & PC & _).
      destruct (PC _ If) as (_ & FH). cbn [fact_holds map] in FH.
      destruct (HUH _ FH) as (h & yv & Evs & _ & HT). injection Evs as E1 _.
      right. exists h. split; [exact E1 | exact HT].
Qed.

Theorem land_sound : land_ok LD IC (g_pc g) rM rO kH = true ->
  F32 v = true -> Rabs (R2 v) <= 128 ->
  keeps_asT
  /\ Mem.load Mfloat32 m (e_blk E rO) oG = Mem.load Mfloat32 m (e_blk E rM) oY
  /\ (Mem.load Mfloat32 m (e_blk E rM) oY = Mem.load Mfloat32 m0 (e_blk E rM) oF
      \/ exists h kq jz, Mem.load Mfloat32 m (e_blk E rM) oY = Some (Vsingle h) /\ (kq <= 4)%nat
           /\ HPi (Hit_at ge m0) (ycast (Vsingle (add_zeros jz (quarter_steps kq y (Float32.div v f4))))) h
           /\ Hit_at ge m0 h)
  /\ exists v', Mem.load Mfloat32 m (e_blk E rM) oV = Some (Vsingle v')
       /\ F32 v' = true /\ R2 fm75 <= R2 v' /\ (R2 v' <= R2 (gravity f4 v) \/ v' = fm4).
Proof.
  intros H Fv Hv. unfold land_ok in H.
  destruct (same_cell LD IC rM oA Mint32) eqn:SA; [| discriminate].
  destruct (same_cell LD IC rM oS Mint16unsigned) eqn:SS; [| discriminate].
  destruct (same_cell LD IC rM oT Mint16unsigned) eqn:ST; [| discriminate].
  cbn [andb] in H.
  destruct (LD rM oY Mfloat32) as [py|] eqn:LY; [| discriminate].
  destruct (LD rM oV Mfloat32) as [vy|] eqn:LV; [| discriminate].
  destruct (LD rO oG Mfloat32) as [gy|] eqn:LG; [| discriminate].
  repeat rewrite andb_true_iff in H. destruct H as ((GE & L) & VO).
  unfold sveqb in GE. destruct (sval_eq gy py) as [->|]; [| discriminate].
  pose proof (ld_sound _ _ _ _ LY) as DY. pose proof (ld_sound _ _ _ _ LV) as DV.
  pose proof (ld_sound _ _ _ _ LG) as DG.
  rewrite addr_M in DY, DV. rewrite addr_O in DG.
  split; [repeat split; apply same_cell_sound; assumption |].
  split; [congruence |]. split.
  - rewrite DY. destruct py; try discriminate.
    + destruct ch; try discriminate. cbn [is_land] in L. apply andb_true_iff in L as (Hr & Ho).
      apply Pos.eqb_eq in Hr. apply Z.eqb_eq in Ho. rewrite Hr, Ho. left.
      cbn [den]. rewrite HbM, Ptrofs.unsigned_zero, Z.add_0_l. reflexivity.
    + cbn [is_land] in L. apply existsb_exists in L as (f & If & Hf).
      destruct f as [| | | k args]; cbn [hfact] in Hf; try discriminate.
      destruct args as [| a0 [| ya [|]]]; cbn [hfact] in Hf; try discriminate;
        destruct a0; cbn [hfact] in Hf; try discriminate.
      repeat rewrite andb_true_iff in Hf. destruct Hf as ((Hk & Hn) & Hq).
      apply Pos.eqb_eq in Hk. apply Pos.eqb_eq in Hn. subst.
      destruct (qrec rM oY oV ya) as [[kq jz]|] eqn:Q; [| discriminate]. apply Nat.leb_le in Hq.
      pose proof MM as (_ & _ & _ & _ & _ & _ & PC & _).
      destruct (PC _ If) as (_ & FH). cbn [fact_holds map] in FH.
      rewrite (qrec_den ge m0 E (e_blk E rM) rM oY oV y v eq_refl HbM HY HV ya kq jz Q) in FH.
      destruct (HUH _ FH) as (h & yv & Evs & HP & HT). cbn [den] in Evs.
      injection Evs as E1 E2. subst yv.
      right. exists h, kq, jz. split; [cbn [den]; exact E1 | split; [exact Hq | split; [exact HP | exact HT]]].
  - apply orb_true_iff in VO as [VC | VK].
    + rewrite (vel_cut_den _ VC) in DV. eexists; split; [exact DV |].
      split; [reflexivity |]. split; [rewrite B2R_fm75, B2R_fm4; lra | right; reflexivity].
    + destruct (vel_ok_den _ VK) as [(D & C) | D]; rewrite D in DV.
      * destruct (sub_ge_m75 v Fv Hv C) as [L75 F].
        eexists; split; [exact DV | split; [exact F | split; [exact L75 | left; apply vel_sub_le; assumption]]].
      * eexists; split; [exact DV | split; [exact F32_fm75 | split; [lra | left; apply vel_clamp_le; assumption]]].
Qed.
End CLS_SOUND.

(* ---- the landed height, as a real bound ---- *)

(* what land_sound's facts mean for a world whose hits are finite and
   moderate (FloorBound.HitB): the landed height is a hit (find_floor
   reported a floor, so not the -11000 sentinel) at most 80 above that
   quarter's yPos, hence at most y + max(v, 0) + 81 *)
Theorem land_height : forall Hit kq jz y v h, HitB Hit -> (kq <= 4)%nat ->
  F32 y = true -> F32 v = true -> Rabs (R2 v) <= 128 -> -11000 <= R2 y <= 15000 ->
  HPi Hit (ycast (Vsingle (add_zeros jz (quarter_steps kq y (Float32.div v f4))))) h -> Hit h ->
  R2 h <= R2 y + Rmax 0 (R2 v) + 81.
Proof.
  intros Hit kq jz y v h HB Hk Fy Fv Hv Hy H Hh.
  destruct (quarter_steps_up kq y v Hk Fy Fv ltac:(apply Rabs_le; lra) Hv) as (Fq & Up & Dn & _).
  destruct (quarter_spec v Fv Hv) as (Fq4 & Hqe & _).
  assert (Hqb : Rabs (R2 (Float32.div v f4)) <= 33).
  { apply Rabs_le_inv in Hv, Hqe. apply Rabs_le. lra. }
  destruct (quarter_steps_spec kq y (Float32.div v f4) Hk Fy Fq4 ltac:(apply Rabs_le; lra) Hqb)
    as (_ & (Lo & _) & _).
  assert (Hk4 : INR kq <= 4) by (replace 4 with (INR 4) by (simpl; lra); apply le_INR; exact Hk).
  pose proof (pos_INR kq) as Hk0.
  set (f := add_zeros jz (quarter_steps kq y (Float32.div v f4))) in *.
  assert (Ef : R2 f = R2 (quarter_steps kq y (Float32.div v f4))) by apply add_zeros_R2.
  assert (Ff : F32 f = true) by (apply add_zeros_F32; exact Fq).
  apply Rabs_le_inv in Hqb.
  assert (Hlo : -12000 <= R2 f) by (rewrite Ef; nra).
  assert (Hup : R2 f <= R2 y + Rmax 0 (R2 v) + / 128).
  { rewrite Ef. destruct (Rle_or_lt 0 (R2 v)) as [P | N].
    - rewrite Rmax_right by exact P. exact (Up P).
    - rewrite Rmax_left by lra. pose proof (Dn ltac:(lra)). lra. }
  assert (Hv' : Rmax 0 (R2 v) <= 128)
    by (apply Rabs_le_inv in Hv; apply Rmax_lub; lra).
  assert (HM : Rmax (R2 f) (-11000) <= R2 y + Rmax 0 (R2 v) + 1).
  { pose proof (Rmax_l 0 (R2 v)). apply Rmax_lub; lra. }
  destruct (ff_height_bound Hit f h HB Ff ltac:(pose proof (Rmax_l 0 (R2 v)); lra) H)
    as [E | (Ht & B)]; [| lra].
  subst h. rewrite B2R_c11000. pose proof (Rmax_l 0 (R2 v)). lra.
Qed.

(* ---- a landing is an attach to a WMotR floor ---- *)

(* the level data find_floor reads (TRUST 0.8(d), stated over the frame
   memory): every hit on a floor list of m0 is a finite height of a WMotR
   floor *)
Definition floor_data (ge : genv) (m0 : mem) : Prop :=
  forall h, Hit_at ge m0 h -> F32 h = true /\ Rabs (R2 h) <= 16384 /\ wmotr_floor (R2 h).

(* a landing on a fresh height meets HeightMoveCatalog.AttachOK's floor case *)
Theorem land_attach : forall ge m0 kq jz y v h, floor_data ge m0 -> (kq <= 4)%nat ->
  F32 y = true -> F32 v = true -> Rabs (R2 v) <= 128 -> -11000 <= R2 y <= 15000 -> R2 v <= 43 ->
  HPi (Hit_at ge m0) (ycast (Vsingle (add_zeros jz (quarter_steps kq y (Float32.div v f4))))) h ->
  Hit_at ge m0 h ->
  wmotr_floor (R2 h) /\ R2 h <= R2 y + STEP_UP.
Proof.
  intros ge m0 kq jz y v h FD Hk Fy Fv Hv Hy H43 HP Hh.
  assert (HB : HitB (Hit_at ge m0)) by (intros x Hx; destruct (FD x Hx) as (F & B & _); auto).
  pose proof (land_height _ kq jz y v h HB Hk Fy Fv Hv Hy HP Hh) as Le.
  split; [exact (proj2 (proj2 (FD h Hh))) |].
  assert (Rmax 0 (R2 v) <= 43) by (apply Rmax_lub; lra).
  unfold STEP_UP. lra.
Qed.

(* ---- a step that does not land ends above -11000 ---- *)

Lemma cle_false_gt : forall p x, F32 p = true -> F32 x = true ->
  Float32.cmp Cle p x = false -> R2 x < R2 p.
Proof.
  intros p x Fp Fx H. unfold Float32.cmp, Float32.compare in H.
  rewrite Binary.Bcompare_correct in H by assumption.
  destruct (Rcompare_spec (R2 p) (R2 x)) as [L | L | L]; simpl in H; try discriminate; lra.
Qed.

(* the compared height is the entry floorHeight (ranged by Phi's InRange)
   or a find_floor hit (a WMotR floor, so >= -11000: WMotRLevel) *)
Theorem above_low : forall ge m0 p x, floor_data ge m0 -> F32 p = true ->
  Float32.cmp Cle p x = false ->
  (F32 x = true /\ -11000 <= R2 x) \/ Hit_at ge m0 x ->
  -11000 < R2 p.
Proof.
  intros ge m0 p x FD Fp C [(Fx & Lx) | Hx].
  - pose proof (cle_false_gt p x Fp Fx C). lra.
  - destruct (FD x Hx) as (Fx & _ & Wx).
    pose proof (cle_false_gt p x Fp Fx C). pose proof (wmotr_floor_low _ Wx). lra.
Qed.
