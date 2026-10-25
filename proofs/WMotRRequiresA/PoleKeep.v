(* ====================================================================== *)
(* PoleKeep (GOAL 2): FfKeepCheck.fk_ok for the pole walks.                *)
(*                                                                        *)
(* fk_ok rejects an outcome whose action is a pole action (it has no      *)
(* usedObj facts); a pole walk ends in one as often as not.  fkp_ok is    *)
(* fk_ok with that clause dropped: the action is a constant on the no-A   *)
(* list, and the cells the frame world reads are kept exactly as fk_ok   *)
(* keeps them.  The usedObj facts a pole action needs are PoleClass's.   *)
(* The lemmas are FfKeep's, over fkp_ok.                                  *)
(* ====================================================================== *)

From Coq Require Import ZArith List Bool Lia.
From compcert Require Import Coqlib Maps AST Integers Values Memory Globalenvs Ctypes Clight.
From SM64.Proofs Require Import Interp.SymExec2.
From SM64.Proofs.WMotRRequiresA Require Import FloorExec AirMatch NoAActions WMotRWorld FfKeepCheck FfKeep.
Import ListNotations.

Section FKP.
Variables (nbase : positive) (R0 : list (positive * Z)) (kv : list (positive * Z * memory_chunk * sval)).
Variables (rM rO rLD kS : positive) (clok : list positive).

Definition fkp_ok (g : gst) : bool :=
  let LD := sload nbase R0 kv g in
  let same (k : positive * Z * memory_chunk) :=
    let '(r, o, ch) := k in
    match LD r o ch with Some a => sveqb a (init_cell kv r o ch) | None => false end in
  let surf (p : sval) := has (g_pc g) (Fuser kS (p :: wargs R0)) in
  match LD rM 12 Mint32 with
  | Some (Sconst (Vint a)) => existsb (Z.eqb (Int.unsigned a)) R_noA_list
  | _ => false
  end
  && forallb same (fk_same rM rO rLD)
  && match LD rM 104 Mint32 with
     | Some p => sveqb p (init_cell kv rM 104 Mint32) || (has (g_pc g) (Fworld p SZ_SURF) && surf p)
     | None => false
     end
  && match LD rM 96 Mint32 with
     | Some p => sveqb p (init_cell kv rM 96 Mint32) || sveqb p (Sconst (Vint Int.zero))
                 || (has (g_pc g) (Fworld p SZ_SURF) && surf p)
     | None => false
     end
  && forallb (fun r => existsb (Pos.eqb r) clok) (g_cl g).
End FKP.

(* the walk wrote no cell of region rx *)
Definition no_reg (rx : positive) (g : gst) : bool :=
  forallb (fun e : positive * Z * memory_chunk * sval => let '(r, _, _, _) := e in negb (Pos.eqb r rx))
    (g_sm g).

Section FKPS.
Variables (ge : genv) (nbase : positive) (R0 : list (positive * Z)) (gtab : list (ident * positive))
  (kv : list (positive * Z * memory_chunk * sval)) (m0 : mem)
  (uf : positive -> list (option val) -> Prop) (gp : meminj).
Hypothesis gp_old : forall b x, gp b = Some x -> Plt b (Mem.nextblock m0).
Variables (E : senv) (m : mem) (g : gst) (rM rO rLD kS : positive) (clok : list positive).
Hypothesis MM : MMg ge nbase R0 gtab kv m0 uf gp E m g.
Hypothesis HUS : forall vs, uf kS vs -> surf_on ge m0 vs.
Hypothesis OK : fkp_ok nbase R0 kv rM rO rLD kS clok g = true.

Local Notation LD := (sload nbase R0 kv g).
Local Notation den := (SymExec2.den ge m0 E).

Lemma fkp_ld : forall r o ch a, LD r o ch = Some a -> Mem.load ch m (e_blk E r) (addr E r o) = den a.
Proof.
  intros r o ch a L.
  exact (proj1 (sload_sound ge nbase R0 gtab kv (fun _ => None) (fun _ => false) m0 uf gp gp_old
                  E m g r o ch a MM L)).
Qed.

Lemma fkp_init : forall r o ch, den (init_cell kv r o ch) = Mem.load ch m0 (e_blk E r) (addr E r o).
Proof.
  intros r o ch. destruct MM as (EO & _).
  exact (proj1 (init_cell_den ge nbase R0 gtab kv m0 gp E r o ch EO)).
Qed.

Lemma fkp_has : forall f, has (g_pc g) f = true -> fact_holds ge R0 m0 uf E f.
Proof.
  intros f H. unfold has in H. apply existsb_exists in H as (x & Hx & Hb).
  unfold fbeq in Hb. destruct (fact_eq f x) as [<- |]; [| discriminate].
  destruct MM as (_ & _ & _ & _ & _ & _ & PC & _). exact (proj2 (PC f Hx)).
Qed.

Lemma fkp_parts :
  match LD rM 12 Mint32 with
  | Some (Sconst (Vint a)) => existsb (Z.eqb (Int.unsigned a)) R_noA_list
  | _ => false
  end = true
  /\ forallb (fun k => let '(r, o, ch) := k in
       match LD r o ch with Some a => sveqb a (init_cell kv r o ch) | None => false end)
       (fk_same rM rO rLD) = true
  /\ match LD rM 104 Mint32 with
     | Some p => sveqb p (init_cell kv rM 104 Mint32)
                 || (has (g_pc g) (Fworld p SZ_SURF) && has (g_pc g) (Fuser kS (p :: wargs R0)))
     | None => false
     end = true
  /\ match LD rM 96 Mint32 with
     | Some p => sveqb p (init_cell kv rM 96 Mint32) || sveqb p (Sconst (Vint Int.zero))
                 || (has (g_pc g) (Fworld p SZ_SURF) && has (g_pc g) (Fuser kS (p :: wargs R0)))
     | None => false
     end = true
  /\ forallb (fun r => existsb (Pos.eqb r) clok) (g_cl g) = true.
Proof.
  pose proof OK as H. unfold fkp_ok in H. cbv zeta in H.
  repeat rewrite andb_true_iff in H. tauto.
Qed.

(* the action: a constant on the no-A list *)
Theorem fkp_action : exists a, Mem.load Mint32 m (e_blk E rM) (addr E rM 12) = Some (Vint a)
  /\ In (Int.unsigned a) R_noA_list.
Proof using gp_old MM HUS OK.
  destruct fkp_parts as (H & _).
  destruct (LD rM 12 Mint32) as [s|] eqn:L; [| discriminate H].
  destruct s as [v | | | | | | | | |]; try discriminate H. destruct v; try discriminate H.
  exists i. split; [rewrite (fkp_ld _ _ _ _ L); reflexivity |].
  apply existsb_exists in H as (x & Hx & Hz). apply Z.eqb_eq in Hz. rewrite Hz. exact Hx.
Qed.

(* the kept cells *)
Theorem fkp_cell : forall r o ch, In (r, o, ch) (fk_same rM rO rLD) ->
  Mem.load ch m (e_blk E r) (addr E r o) = Mem.load ch m0 (e_blk E r) (addr E r o).
Proof using gp_old MM HUS OK.
  intros r o ch Hin. destruct fkp_parts as (_ & H & _).
  rewrite forallb_forall in H. specialize (H _ Hin). cbn beta iota in H.
  destruct (LD r o ch) as [a|] eqn:L; [| discriminate H].
  rewrite (fkp_ld _ _ _ _ L), (fk_sveq _ _ H). apply fkp_init.
Qed.

Lemma fkp_surf_of : forall p v, den p = Some v ->
  has (g_pc g) (Fworld p SZ_SURF) = true -> has (g_pc g) (Fuser kS (p :: wargs R0)) = true ->
  fk_surf ge R0 m0 uf E p v.
Proof.
  intros p v D H1 H2. pose proof (fkp_has _ H2) as U. cbn [fact_holds map] in U.
  rewrite D in U. destruct (HUS _ U) as (b & o & -> & St & Nr & Pl).
  exists b, o. split; [reflexivity |]. split; [exact D |].
  split; [exact (fkp_has _ H1) |]. split; [exact St | split; [exact Nr | exact Pl]].
Qed.

Theorem fkp_floor :
  Mem.load Mint32 m (e_blk E rM) (addr E rM 104) = Mem.load Mint32 m0 (e_blk E rM) (addr E rM 104)
  \/ exists p v, Mem.load Mint32 m (e_blk E rM) (addr E rM 104) = Some v /\ fk_surf ge R0 m0 uf E p v.
Proof using gp_old MM HUS OK.
  destruct fkp_parts as (_ & _ & H & _).
  destruct (LD rM 104 Mint32) as [p|] eqn:L; [| discriminate H].
  pose proof (fkp_ld _ _ _ _ L) as D.
  apply orb_true_iff in H as [H | H].
  - left. rewrite D, (fk_sveq _ _ H). apply fkp_init.
  - right. apply andb_true_iff in H as [H1 H2].
    destruct (den p) as [v|] eqn:Dp.
    + exists p, v. split; [exact D | exact (fkp_surf_of p v Dp H1 H2)].
    + exfalso. pose proof (fkp_has _ H1) as (b & o & Dp' & _). congruence.
Qed.

Theorem fkp_wall :
  Mem.load Mint32 m (e_blk E rM) (addr E rM 96) = Mem.load Mint32 m0 (e_blk E rM) (addr E rM 96)
  \/ Mem.load Mint32 m (e_blk E rM) (addr E rM 96) = Some (Vint Int.zero)
  \/ exists p v, Mem.load Mint32 m (e_blk E rM) (addr E rM 96) = Some v /\ fk_surf ge R0 m0 uf E p v.
Proof using gp_old MM HUS OK.
  destruct fkp_parts as (_ & _ & _ & H & _).
  destruct (LD rM 96 Mint32) as [p|] eqn:L; [| discriminate H].
  pose proof (fkp_ld _ _ _ _ L) as D.
  apply orb_true_iff in H as [H | H]; [apply orb_true_iff in H as [H | H] |].
  - left. rewrite D, (fk_sveq _ _ H). apply fkp_init.
  - right; left. rewrite D, (fk_sveq _ _ H). reflexivity.
  - right; right. apply andb_true_iff in H as [H1 H2].
    destruct (den p) as [v|] eqn:Dp.
    + exists p, v. split; [exact D | exact (fkp_surf_of p v Dp H1 H2)].
    + exfalso. pose proof (fkp_has _ H1) as (b & o & Dp' & _). congruence.
Qed.

(* the frame: outside every region's range, nothing changed *)
Theorem fkp_frame : forall b z ch, Plt b (Mem.nextblock m0) ->
  (forall r sz, r0_size R0 r = Some sz ->
     e_blk E r <> b \/ Ptrofs.unsigned (e_base E r) + sz <= z
     \/ z + size_chunk ch <= Ptrofs.unsigned (e_base E r)) ->
  Mem.load ch m b z = Mem.load ch m0 b z.
Proof using gp_old MM HUS OK.
  intros b z ch Hb Hout.
  pose proof MM as (_ & _ & ENT & FR & _ & _ & _ & LOC & _).
  apply FR; [exact Hb | |].
  - intros [[[r o] ch'] sv] IN. cbn [skey cell_disj].
    destruct (ENT _ _ _ _ IN) as (IB & _). unfold inb in IB.
    destruct (Pos.ltb r nbase) eqn:Lt.
    + destruct (r0_size R0 r) as [sz|] eqn:S; [| discriminate IB].
      apply andb_true_iff in IB as [I1 I2]. apply Z.leb_le in I1. apply Z.leb_le in I2.
      unfold addr. destruct (Hout r sz S) as [N | [N | N]]; [left; exact N | right; left; lia | right; right; lia].
    + left. apply andb_true_iff in IB as [IB _]. apply andb_true_iff in IB as [IB _].
      apply existsb_exists in IB as (r' & Hr' & Er). apply Pos.eqb_eq in Er. subst r'.
      destruct (LOC r Hr') as (_ & _ & _ & Nold & _). intros Eq. rewrite <- Eq in Hb. exact (Nold Hb).
  - intros r _. unfold rng_disj. destruct (r0_size R0 r) as [sz|] eqn:S; [| exact I].
    exact (Hout r sz S).
Qed.

(* the same frame without region rx's range, when the walk wrote no cell
   of rx and rx is no clobber region *)
Theorem fkp_frame_except : forall rx, no_reg rx g = true -> ~ In rx clok ->
  forall b z ch, Plt b (Mem.nextblock m0) ->
  (forall r sz, r <> rx -> r0_size R0 r = Some sz ->
     e_blk E r <> b \/ Ptrofs.unsigned (e_base E r) + sz <= z
     \/ z + size_chunk ch <= Ptrofs.unsigned (e_base E r)) ->
  Mem.load ch m b z = Mem.load ch m0 b z.
Proof using gp_old MM HUS OK.
  intros rx NR NC b z ch Hb Hout.
  destruct fkp_parts as (_ & _ & _ & _ & CL).
  pose proof MM as (_ & _ & ENT & FR & _ & _ & _ & LOC & _).
  apply FR; [exact Hb | |].
  - intros [[[r o] ch'] sv] IN. cbn [skey cell_disj].
    assert (Nr : r <> rx).
    { unfold no_reg in NR. rewrite forallb_forall in NR. specialize (NR _ IN). cbn in NR.
      intros ->. rewrite Pos.eqb_refl in NR. discriminate NR. }
    destruct (ENT _ _ _ _ IN) as (IB & _). unfold inb in IB.
    destruct (Pos.ltb r nbase) eqn:Lt.
    + destruct (r0_size R0 r) as [sz|] eqn:S; [| discriminate IB].
      apply andb_true_iff in IB as [I1 I2]. apply Z.leb_le in I1. apply Z.leb_le in I2.
      unfold addr. destruct (Hout r sz Nr S) as [N | [N | N]]; [left; exact N | right; left; lia | right; right; lia].
    + left. apply andb_true_iff in IB as [IB _]. apply andb_true_iff in IB as [IB _].
      apply existsb_exists in IB as (r' & Hr' & Er). apply Pos.eqb_eq in Er. subst r'.
      destruct (LOC r Hr') as (_ & _ & _ & Nold & _). intros Eq. rewrite <- Eq in Hb. exact (Nold Hb).
  - intros r Hr. unfold rng_disj. destruct (r0_size R0 r) as [sz|] eqn:S; [| exact I].
    assert (Nr : r <> rx).
    { intros ->. apply NC. rewrite forallb_forall in CL. specialize (CL _ Hr).
      apply existsb_exists in CL as (x & Hx & Ex). apply Pos.eqb_eq in Ex. subst. exact Hx. }
    exact (Hout r sz Nr S).
Qed.
End FKPS.
