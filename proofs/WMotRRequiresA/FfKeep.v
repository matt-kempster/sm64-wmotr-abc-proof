(* ====================================================================== *)
(* FfKeep (GOAL 2): what FfKeepCheck.fk_ok says about an outcome's memory. *)
(*                                                                        *)
(* For an outcome g of a walk from m0 whose final memory m matches it     *)
(* (SymExec2.MMg), fk_ok g = true gives                                    *)
(*   - fk_action: the action cell holds a constant on the no-A list;       *)
(*   - fk_cell:   each fk_same cell of m is m0's;                          *)
(*   - fk_floor / fk_wall: m->floor (m->wall) is m0's, (NULL,) or a WMotR  *)
(*     surface of m0 in a world block off the regions;                     *)
(*   - fk_frame:  a cell of an old block outside every region's range is   *)
(*     m0's (the walk clobbers only regions, writes only region cells).   *)
(* ====================================================================== *)

From Coq Require Import ZArith List Bool Lia.
From compcert Require Import Coqlib Maps AST Integers Values Memory Globalenvs Ctypes Clight.
From SM64.Proofs Require Import Interp.SymExec2.
From SM64.Proofs.WMotRRequiresA Require Import FloorExec AirMatch NoAActions FfKeepCheck.
Import ListNotations.

Section FKS.
Variables (ge : genv) (nbase : positive) (R0 : list (positive * Z)) (gtab : list (ident * positive))
  (kv : list (positive * Z * memory_chunk * sval)) (m0 : mem)
  (uf : positive -> list (option val) -> Prop) (gp : meminj).
Hypothesis gp_old : forall b x, gp b = Some x -> Plt b (Mem.nextblock m0).
Variables (E : senv) (m : mem) (g : gst) (rM rO rLD kS : positive) (clok : list positive).
Hypothesis MM : MMg ge nbase R0 gtab kv m0 uf gp E m g.
Hypothesis HUS : forall vs, uf kS vs -> surf_on m0 vs.
Hypothesis OK : fk_ok nbase R0 kv rM rO rLD kS clok g = true.

Local Notation LD := (sload nbase R0 kv g).
Local Notation den := (SymExec2.den ge m0 E).

Lemma fk_ld : forall r o ch a, LD r o ch = Some a -> Mem.load ch m (e_blk E r) (addr E r o) = den a.
Proof.
  intros r o ch a L.
  exact (proj1 (sload_sound ge nbase R0 gtab kv (fun _ => None) (fun _ => false) m0 uf gp gp_old
                  E m g r o ch a MM L)).
Qed.

Lemma fk_init : forall r o ch, den (init_cell kv r o ch) = Mem.load ch m0 (e_blk E r) (addr E r o).
Proof.
  intros r o ch. destruct MM as (EO & _).
  exact (proj1 (init_cell_den ge nbase R0 gtab kv m0 gp E r o ch EO)).
Qed.

Lemma fk_sveq : forall a b, sveqb a b = true -> a = b.
Proof. intros a b H. unfold sveqb in H. destruct (sval_eq a b); [exact e | discriminate]. Qed.

Lemma fk_has : forall f, has (g_pc g) f = true -> fact_holds ge R0 m0 uf E f.
Proof.
  intros f H. unfold has in H. apply existsb_exists in H as (x & Hx & Hb).
  unfold fbeq in Hb. destruct (fact_eq f x) as [<- |]; [| discriminate].
  destruct MM as (_ & _ & _ & _ & _ & _ & PC & _). exact (proj2 (PC f Hx)).
Qed.

Lemma fk_parts :
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
  pose proof OK as H. unfold fk_ok in H. cbv zeta in H.
  repeat rewrite andb_true_iff in H. tauto.
Qed.

(* the action *)
Theorem fk_action : exists a, Mem.load Mint32 m (e_blk E rM) (addr E rM 12) = Some (Vint a)
  /\ In (Int.unsigned a) R_noA_list.
Proof using gp_old MM HUS OK.
  destruct fk_parts as (H & _).
  destruct (LD rM 12 Mint32) as [s|] eqn:L; [| discriminate H].
  destruct s as [v | | | | | | | | |]; try discriminate H. destruct v; try discriminate H.
  exists i. split; [rewrite (fk_ld _ _ _ _ L); reflexivity |].
  apply existsb_exists in H as (x & Hx & Hz). apply Z.eqb_eq in Hz. rewrite Hz. exact Hx.
Qed.

(* the kept cells *)
Theorem fk_cell : forall r o ch, In (r, o, ch) (fk_same rM rO rLD) ->
  Mem.load ch m (e_blk E r) (addr E r o) = Mem.load ch m0 (e_blk E r) (addr E r o).
Proof using gp_old MM HUS OK.
  intros r o ch Hin. destruct fk_parts as (_ & H & _).
  rewrite forallb_forall in H. specialize (H _ Hin). cbn beta iota in H.
  destruct (LD r o ch) as [a|] eqn:L; [| discriminate H].
  rewrite (fk_ld _ _ _ _ L), (fk_sveq _ _ H). apply fk_init.
Qed.

(* a stored surface *)
Definition fk_surf (p : sval) (v : val) : Prop :=
  exists b o, v = Vptr b o /\ den p = Some v
    /\ fact_holds ge R0 m0 uf E (Fworld p SZ_SURF)
    /\ styp m0 b o /\ ~ rblk (map den (wargs R0)) b.

Lemma fk_surf_of : forall p v, den p = Some v ->
  has (g_pc g) (Fworld p SZ_SURF) = true -> has (g_pc g) (Fuser kS (p :: wargs R0)) = true ->
  fk_surf p v.
Proof.
  intros p v D H1 H2. pose proof (fk_has _ H2) as U. cbn [fact_holds map] in U.
  rewrite D in U. destruct (HUS _ U) as (b & o & -> & St & Nr).
  exists b, o. split; [reflexivity |]. split; [exact D |].
  split; [exact (fk_has _ H1) |]. split; [exact St | exact Nr].
Qed.

Theorem fk_floor :
  Mem.load Mint32 m (e_blk E rM) (addr E rM 104) = Mem.load Mint32 m0 (e_blk E rM) (addr E rM 104)
  \/ exists p v, Mem.load Mint32 m (e_blk E rM) (addr E rM 104) = Some v /\ fk_surf p v.
Proof using gp_old MM HUS OK.
  destruct fk_parts as (_ & _ & H & _).
  destruct (LD rM 104 Mint32) as [p|] eqn:L; [| discriminate H].
  pose proof (fk_ld _ _ _ _ L) as D.
  apply orb_true_iff in H as [H | H].
  - left. rewrite D, (fk_sveq _ _ H). apply fk_init.
  - right. apply andb_true_iff in H as [H1 H2].
    destruct (den p) as [v|] eqn:Dp.
    + exists p, v. split; [exact D | exact (fk_surf_of p v Dp H1 H2)].
    + exfalso. pose proof (fk_has _ H1) as (b & o & Dp' & _). congruence.
Qed.

Theorem fk_wall :
  Mem.load Mint32 m (e_blk E rM) (addr E rM 96) = Mem.load Mint32 m0 (e_blk E rM) (addr E rM 96)
  \/ Mem.load Mint32 m (e_blk E rM) (addr E rM 96) = Some (Vint Int.zero)
  \/ exists p v, Mem.load Mint32 m (e_blk E rM) (addr E rM 96) = Some v /\ fk_surf p v.
Proof using gp_old MM HUS OK.
  destruct fk_parts as (_ & _ & _ & H & _).
  destruct (LD rM 96 Mint32) as [p|] eqn:L; [| discriminate H].
  pose proof (fk_ld _ _ _ _ L) as D.
  apply orb_true_iff in H as [H | H]; [apply orb_true_iff in H as [H | H] |].
  - left. rewrite D, (fk_sveq _ _ H). apply fk_init.
  - right; left. rewrite D, (fk_sveq _ _ H). reflexivity.
  - right; right. apply andb_true_iff in H as [H1 H2].
    destruct (den p) as [v|] eqn:Dp.
    + exists p, v. split; [exact D | exact (fk_surf_of p v Dp H1 H2)].
    + exfalso. pose proof (fk_has _ H1) as (b & o & Dp' & _). congruence.
Qed.

(* the frame: outside every region's range, nothing changed *)
Theorem fk_frame : forall b z ch, Plt b (Mem.nextblock m0) ->
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
End FKS.
