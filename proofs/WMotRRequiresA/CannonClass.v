(* ====================================================================== *)
(* CannonClass (GOAL 2): each outcome of a walk of the real act_in_cannon  *)
(* (no A: the shot is pruned) is ONE HeightMoveCatalog S_attach of Phi's   *)
(* cells, and keeps the cannon.                                            *)
(*                                                                        *)
(* act_in_cannon (mario_actions_automatic.c) in state 0 seats Mario at     *)
(* usedObj->oPosY + 350 (the walk knows the cannon's oPosY, so the seat is *)
(* a folded constant, one of WMotR's cannon heights) with vel := 0; in    *)
(* states 1 and 2 (A clear) it only aims; every path ends with             *)
(* gfx.pos := pos.  cannon_ok checks, on an outcome, that the action is   *)
(* still ACT_IN_CANNON (as at the entry), pos[1] is the entry's or the    *)
(* seat, gfx.pos[1] = pos[1], vel[1] is the entry's or +0, floorHeight is  *)
(* the entry's, and (cannon_keep) usedObj and the cannon's oPosY,         *)
(* interaction type and hitbox cells are untouched.  cannon_sound turns    *)
(* it into read_cells + a RangedMove + those facts.                        *)
(* ====================================================================== *)

From Coq Require Import ZArith Reals List Lia Lra Bool.
From compcert Require Import Coqlib Maps AST Integers Floats Values Memory Ctypes Cop Clight.
From SM64.Proofs Require Import Interp.SymExec2 HeightInvariant HeightMoveCatalog WMotRLevel.
From SM64.Proofs.WMotRRequiresA Require Import FloorHeight AirMatch FfClass WMotRWorld PoleClass PoleSound.
Import ListNotations.

Local Open Scope R_scope.

Section CLS.
Variables (nbase : positive) (R0 : list (positive * Z)) (kv : list (positive * Z * memory_chunk * sval)).
Variables (rM rO rU : positive) (yc : Z).
Local Notation ic := (init_cell kv).

(* the cells the cannon's outcome must leave as they were *)
Definition cannon_cells : list (positive * Z * memory_chunk) :=
  [(rM, USED_OFF, Mint32); (rU, O_POSY, Mfloat32); (rU, O_INTERACT_TYPE, Mint32);
   (rU, HITBOX_DOWN_OFF, Mfloat32); (rU, HITBOX_H_OFF, Mfloat32)].

Definition cannon_keep (g : gst) : bool :=
  forallb (fun k : positive * Z * memory_chunk => let '(r, o, ch) := k in
     match sload nbase R0 kv g r o ch with Some a => sveqb a (ic r o ch) | None => false end)
    cannon_cells.

Definition cannon_ok (g : gst) : bool :=
  let LD := sload nbase R0 kv g in
  match LD rM oMO Mint32, LD rM oA Mint32, LD rM oS Mint16unsigned, LD rM oT Mint16unsigned,
        LD rM oY Mfloat32, LD rM oV Mfloat32, LD rM oF Mfloat32, LD rO oG Mfloat32 with
  | Some (Sptr r0 z0), Some (Sconst (Vint a)), Some ss, Some st, Some sy, Some sv, Some sf, Some sg =>
      Pos.eqb r0 rO && Ptrofs.eq z0 Ptrofs.zero
      && Z.eqb (Int.unsigned a) ACT_IN_CANNON_Z
      && sveqb (ic rM oA Mint32) (Sconst (Vint a))
      && int_sv (ic rM oS Mint16unsigned) ss && int_sv (ic rM oT Mint16unsigned) st
      && (sveqb sv (ic rM oV Mfloat32) || is_pz sv)
      && sveqb sf (ic rM oF Mfloat32)
      && sveqb sg sy
      && (sveqb sy (ic rM oY Mfloat32) || cfin sy yc yc)
      && cannon_keep g
  | _, _, _, _, _, _, _, _ => false
  end.
End CLS.

Lemma in_cannon_ground : forall st, mode_of_action (Int.repr ACT_IN_CANNON_Z) st = M_Ground.
Proof.
  intros st. unfold mode_of_action, roll_prep, ACT_IN_CANNON_Z.
  destruct (Z.eqb st 0); vm_compute; reflexivity.
Qed.

Lemma in_cannon_not_ledge : Int.repr ACT_IN_CANNON_Z <> ACT_LEDGE_GRAB.
Proof. vm_compute. discriminate. Qed.

(* ---- cannon_ok, at the outcome's memory ---- *)
Section CS.
Variables (ge : genv) (nbase : positive) (R0 : list (positive * Z)) (gtab : list (ident * positive))
  (kv : list (positive * Z * memory_chunk * sval)) (m0 : mem)
  (uf : positive -> list (option val) -> Prop) (gp : meminj).
Hypothesis gp_old : forall b x, gp b = Some x -> Plt b (Mem.nextblock m0).
Variables (rM rO rU : positive) (yc : Z).
Hypothesis Hyc : In yc wmotr_cannon_list.
Variables (E : senv) (m : mem) (g : gst).
Hypothesis MM : MMg ge nbase R0 gtab kv m0 uf gp E m g.
Hypothesis HbM : e_base E rM = Ptrofs.zero.
Local Notation bm := (e_blk E rM).
Local Notation den := (SymExec2.den ge m0 E).
Local Notation LD := (sload nbase R0 kv g).

Lemma cld : forall r o ch s, LD r o ch = Some s -> Mem.load ch m (e_blk E r) (addr E r o) = den s.
Proof.
  intros r o ch s L.
  exact (proj1 (sload_sound ge nbase R0 gtab kv (fun _ => None) (fun _ => false) m0 uf gp gp_old
                  E m g r o ch s MM L)).
Qed.

Lemma cic : forall r o ch, den (init_cell kv r o ch) = Mem.load ch m0 (e_blk E r) (addr E r o).
Proof.
  intros r o ch. destruct MM as (EO & _).
  exact (proj1 (init_cell_den ge nbase R0 gtab kv m0 gp E r o ch EO)).
Qed.

Lemma cAM : forall o, addr E rM o = o.
Proof. intros o. unfold addr. rewrite HbM, Ptrofs.unsigned_zero. reflexivity. Qed.

Lemma ckept : forall r o ch, match LD r o ch with
  | Some u => sveqb u (init_cell kv r o ch) | None => false end = true ->
  Mem.load ch m (e_blk E r) (addr E r o) = Mem.load ch m0 (e_blk E r) (addr E r o).
Proof.
  intros r o ch H. destruct (LD r o ch) as [u|] eqn:L; [| discriminate H].
  apply sveqb_eq in H. subst u. rewrite (cld _ _ _ _ L). apply cic.
Qed.

Theorem cannon_keep_sound : cannon_keep nbase R0 kv rM rU g = true ->
  forall r o ch, In (r, o, ch) (cannon_cells rM rU) ->
    Mem.load ch m (e_blk E r) (addr E r o) = Mem.load ch m0 (e_blk E r) (addr E r o).
Proof.
  intros H r o ch Hin. unfold cannon_keep in H.
  pose proof (proj1 (forallb_forall _ _) H _ Hin) as K. cbn beta iota in K.
  exact (ckept r o ch K).
Qed.

Variable c0 : cells.
Hypothesis RC0 : read_cells bm m0 c0.
Hypothesis IR0 : InRange c0.

Theorem cannon_sound : cannon_ok nbase R0 kv rM rO rU yc g = true ->
  exists c2, read_cells bm m c2
    /\ RangedMove wmotr_floor wmotr_pole wmotr_cannon c0 c2
    /\ c_action c2 = Int.repr ACT_IN_CANNON_Z
    /\ cannon_keep nbase R0 kv rM rU g = true.
Proof.
  intros OK. unfold cannon_ok in OK. cbv zeta in OK.
  repeat match type of OK with
  | context [match ?x with _ => _ end] => let Ex := fresh "Ex" in destruct x eqn:Ex; try discriminate OK
  end.
  subst.
  repeat rewrite andb_true_iff in OK.
  destruct OK as ((((((((((R1 & Z0) & ZA) & IA) & IS) & IT) & EV) & EF) & EG) & YB) & KP).
  apply Pos.eqb_eq in R1. subst. apply Ptrofs.same_if_eq in Z0. subst.
  apply sveqb_eq in EF, EG. subst.
  apply Z.eqb_eq in ZA.
  assert (Ei : i = Int.repr ACT_IN_CANNON_Z) by (rewrite <- ZA; symmetry; apply Int.repr_unsigned).
  subst i.
  destruct RC0 as (A0 & S0 & T0 & Y0 & V0 & F0 & bo0 & oo0 & LO0 & GY0).
  (* the entry action *)
  apply sveqb_eq in IA.
  assert (DA : den (init_cell kv rM oA Mint32) = Mem.load Mint32 m0 bm oA) by (rewrite cic, cAM; reflexivity).
  rewrite IA in DA. cbn [SymExec2.den] in DA. change OFS_ACTION with oA in A0.
  rewrite A0 in DA. injection DA as Ea0.
  assert (MG : mode_of c0 = M_Ground).
  { unfold mode_of. rewrite <- Ea0. apply in_cannon_ground. }
  assert (DS0 : den (init_cell kv rM oS Mint16unsigned) = Some (Vint (c_state c0)))
    by (rewrite cic, cAM; exact S0).
  assert (DT0 : den (init_cell kv rM oT Mint16unsigned) = Some (Vint (c_timer c0)))
    by (rewrite cic, cAM; exact T0).
  match goal with H : int_sv _ ?s = true, H' : LD rM oS _ = Some ?s |- _ =>
    destruct (int_sv_den ge m0 E _ _ DS0 s H) as (js & Ds); pose proof (cld _ _ _ _ H') as LS end.
  match goal with H : int_sv _ ?s = true, H' : LD rM oT _ = Some ?s |- _ =>
    destruct (int_sv_den ge m0 E _ _ DT0 s H) as (jt & Dt); pose proof (cld _ _ _ _ H') as LT end.
  rewrite cAM, Ds in LS. rewrite cAM, Dt in LT.
  match goal with H' : LD rM oF _ = Some _ |- _ => pose proof (cld _ _ _ _ H') as LF end.
  rewrite cAM, cic, cAM in LF.
  match goal with H' : LD rM oA _ = Some _ |- _ => pose proof (cld _ _ _ _ H') as LA end.
  rewrite cAM in LA. cbn [SymExec2.den] in LA.
  match goal with H' : LD rM oMO _ = Some _ |- _ => pose proof (cld _ _ _ _ H') as LM end.
  rewrite cAM in LM. cbn [SymExec2.den] in LM. rewrite Ptrofs.add_zero in LM.
  match goal with H' : LD rM oY _ = Some ?s |- _ => pose proof (cld _ _ _ _ H') as LY end.
  match goal with H' : LD rO oG _ = Some _ |- _ => pose proof (cld _ _ _ _ H') as LG end.
  match goal with H' : LD rM oV _ = Some _ |- _ => pose proof (cld _ _ _ _ H') as LV end.
  rewrite cAM in LY, LV.
  destruct IR0 as (FY0 & FV0 & FG0 & LY0 & LG0 & (FF0 & LF0) & VR0).
  (* vel[1]: the entry's, or +0 *)
  assert (VV : exists v, Mem.load Mfloat32 m bm oV = Some (Vsingle v) /\ F32 v = true /\ -75 <= R2 v <= 43).
  { apply orb_true_iff in EV as [EV | EV].
    - apply sveqb_eq in EV. subst. rewrite cic, cAM in LV. change OFS_VELY with oV in V0.
      rewrite V0 in LV. exists (c_vely c0). split; [exact LV |]. split; [exact FV0 | lra].
    - destruct (is_pz_sound _ EV) as (z & -> & Fz & Rz). cbn [SymExec2.den] in LV.
      exists z. split; [exact LV |]. split; [exact Fz | lra]. }
  destruct VV as (v2 & LV2 & Fv2 & Rv2).
  (* pos[1]: the entry's, or the seat *)
  assert (MV : exists y, Mem.load Mfloat32 m bm oY = Some (Vsingle y)
             /\ Mem.load Mfloat32 m (e_blk E rO) (addr E rO oG) = Some (Vsingle y)
             /\ F32 y = true /\ -11000 <= R2 y
             /\ exists h, AttachOK wmotr_floor wmotr_pole wmotr_cannon c0 h /\ R2 y <= h).
  { apply orb_true_iff in YB as [YB | YB].
    - apply sveqb_eq in YB. subst.
      rewrite cic, cAM in LY, LG. change OFS_POSY with oY in Y0. rewrite Y0 in LY, LG.
      exists (c_posy c0). split; [exact LY |]. split; [exact LG |]. split; [exact FY0 |]. split; [lra |].
      exists (R2 (c_posy c0)). split; [left; split; [exact MG | lra] | lra].
    - assert (Hb : (-16777216 <= yc <= 16777216)%Z).
      { rewrite cannon_list_value in Hyc. destruct Hyc as [<- | [<- | []]]; lia. }
      destruct (cfin_sound _ yc yc ltac:(lia) ltac:(lia) ltac:(lia) YB) as (k & -> & Fk & Rk).
      cbn [SymExec2.den] in LY, LG.
      exists k. split; [exact LY |]. split; [exact LG |]. split; [exact Fk |].
      split.
      + rewrite cannon_list_value in Hyc.
        destruct Hyc as [<- | [<- | []]]; lra.
      + exists (IZR yc). split; [| lra].
        right; right; right; right; left. exists yc. split; [exact Hyc | reflexivity]. }
  destruct MV as (y & LY' & LG' & Fy & Ry & h & AO & Hh).
  set (c2 := mkCells (Int.repr ACT_IN_CANNON_Z) js jt y v2 (c_floorh c0) y).
  exists c2.
  split.
  { unfold read_cells. cbn [c2 c_action c_state c_timer c_posy c_vely c_floorh c_gfxy].
    change OFS_ACTION with oA. change OFS_ASTATE with oS. change OFS_ATIMER with oT.
    change OFS_POSY with oY. change OFS_VELY with oV. change OFS_FLOORH with oF.
    change OFS_FLOORH with oF in F0.
    refine (conj LA (conj LS (conj LT (conj LY' (conj LV2 (conj _ _)))))).
    - rewrite LF. exact F0.
    - exists (e_blk E rO), (e_base E rO). change Mptr with Mint32. change OFS_MARIOOBJ with oMO.
      split; [exact LM |]. unfold addr in LG'. change OFS_GFXY with oG. exact LG'. }
  split.
  { split.
    - unfold InRange. cbn [c2 c_posy c_vely c_gfxy c_floorh].
      repeat split; try assumption; lra.
    - apply S_attach with (h := h).
      + exact AO.
      + cbn [c2 c_posy]. exact Hh.
      + left. reflexivity.
      + unfold mode_of. cbn [c2 c_action]. rewrite in_cannon_ground. exact I.
      + cbn [c2 c_action]. intros H. exfalso. exact (in_cannon_not_ledge H). }
  split; [reflexivity | exact KP].
Qed.
End CS.
