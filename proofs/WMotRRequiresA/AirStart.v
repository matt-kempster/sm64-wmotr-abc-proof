(* ====================================================================== *)
(* AirStart (unwired, GOAL 2): building the air-step walk's start state     *)
(* (AirRun.air_step_outcome's env_ok and closedness premises) from plain    *)
(* facts about the memory at the call.                                       *)
(*                                                                          *)
(* The injection is "every block valid at m0" (gpv), so closedness is the   *)
(* memory fact that a pointer stored in a valid block points at a valid    *)
(* block.  The environment E0 maps the walk's regions to Mario's state     *)
(* block (offset 0), Mario's object (any offset: a gObjectPool slot) and   *)
(* find_floor's three statics.                                              *)
(* ====================================================================== *)

From Coq Require Import List ZArith Lia.
From compcert Require Import Coqlib Maps AST Integers Floats Values Memory Ctypes Clight Globalenvs.
From SM64.Generated Require mario surface_collision.
From SM64.Proofs Require Import Interp.SymExec2.
From SM64.Proofs.WMotRRequiresA Require Import FloorExec AirRun.
From SM64.Proofs Require Import HeightInvariant HeightMoveCatalog WMotRLevel.
From SM64.Proofs.WMotRRequiresA Require Import AirMatch AirMove.
From compcert Require Import ClightBigstep.
From SM64.Generated Require mario_step.
From SM64.Proofs Require Import Interp.LinkGenv MarioModel.LinkedTwelve.
Import ListNotations.

Section START.
Variable G : genv.
Variable m0 : mem.

Definition gpv : meminj :=
  fun b => if plt b (Mem.nextblock m0) then Some (b, 0) else None.

Lemma gpv_old : forall b x, gpv b = Some x -> Plt b (Mem.nextblock m0).
Proof. intros b x. unfold gpv. destruct (plt b (Mem.nextblock m0)); [auto | discriminate]. Qed.

Lemma gpv_flat : forall b b' d, gpv b = Some (b', d) -> b' = b /\ d = 0.
Proof.
  intros b b' d. unfold gpv. destruct (plt b (Mem.nextblock m0)); [| discriminate].
  intros H. injection H as <- <-. auto.
Qed.

Lemma gpv_valid : forall b, Plt b (Mem.nextblock m0) -> gpv b <> None.
Proof. intros b H. unfold gpv. destruct (plt b (Mem.nextblock m0)); [discriminate | contradiction]. Qed.

(* closedness from the memory fact *)
Hypothesis Hclosed : forall ch b z b' o', Plt b (Mem.nextblock m0) ->
  Mem.load ch m0 b z = Some (Vptr b' o') -> Plt b' (Mem.nextblock m0).

Lemma gpv_closed : forall ch b z v, gpv b <> None -> Mem.load ch m0 b z = Some v -> val_old gpv v.
Proof.
  intros ch b z v H L. destruct v; cbn [val_old]; auto.
  apply gpv_valid. apply (Hclosed ch b z b0 i); [| exact L].
  destruct (gpv b) as [x|] eqn:E; [exact (gpv_old b x E) | congruence].
Qed.

(* the regions *)
Variables (bm bo bfi bmiss bcalls : block) (oo : ptrofs).

Definition E0 : senv :=
  mke (fun r => if Pos.eqb r RM then bm else if Pos.eqb r RO then bo
                else if Pos.eqb r RFI then bfi else if Pos.eqb r RMISS then bmiss else bcalls)
      (fun r => if Pos.eqb r RO then oo else Ptrofs.zero)
      (fun _ => None).

Hypothesis Vm : Plt bm (Mem.nextblock m0).
Hypothesis Vo : Plt bo (Mem.nextblock m0).
Hypothesis Sfi : Genv.find_symbol G surface_collision._gFindFloorIncludeSurfaceIntangible = Some bfi.
Hypothesis Smiss : Genv.find_symbol G surface_collision._gNumFindFloorMisses = Some bmiss.
Hypothesis Scalls : Genv.find_symbol G surface_collision._gNumCalls = Some bcalls.
Hypothesis Vfi : Plt bfi (Mem.nextblock m0).
Hypothesis Vmiss : Plt bmiss (Mem.nextblock m0).
Hypothesis Vcalls : Plt bcalls (Mem.nextblock m0).
(* Mario's state and object are not the statics, nor each other *)
Hypothesis Dmo : bm <> bo.
Hypothesis Dm : bm <> bfi /\ bm <> bmiss /\ bm <> bcalls.
Hypothesis Do : bo <> bfi /\ bo <> bmiss /\ bo <> bcalls.
Hypothesis Szm : 0 + szs G mario._MarioState <= Ptrofs.modulus.
Hypothesis Szo : Ptrofs.unsigned oo + szs G mario._Object <= Ptrofs.modulus.
(* the known cells: m->marioObj, m->action = ACT_FREEFALL *)
Hypothesis Kmo : Mem.load Mint32 m0 bm (fo G mario._MarioState mario._marioObj) = Some (Vptr bo oo).
Hypothesis Kact : Mem.load Mint32 m0 bm 12 = Some (Vint (Int.repr 16779404)).

Lemma statics_distinct : bfi <> bmiss /\ bfi <> bcalls /\ bmiss <> bcalls.
Proof.
  repeat split; intros E; subst;
    [ pose proof (Genv.global_addresses_distinct G (id1 := surface_collision._gFindFloorIncludeSurfaceIntangible)
                    (id2 := surface_collision._gNumFindFloorMisses) ltac:(discriminate) Sfi Smiss)
    | pose proof (Genv.global_addresses_distinct G (id1 := surface_collision._gFindFloorIncludeSurfaceIntangible)
                    (id2 := surface_collision._gNumCalls) ltac:(discriminate) Sfi Scalls)
    | pose proof (Genv.global_addresses_distinct G (id1 := surface_collision._gNumFindFloorMisses)
                    (id2 := surface_collision._gNumCalls) ltac:(discriminate) Smiss Scalls) ];
    congruence.
Qed.

Theorem start_env : env_ok G NB (R0 G) gtab (kv G) m0 gpv E0.
Proof.
  pose proof statics_distinct as (D1 & D2 & D3).
  destruct Dm as (Dm1 & Dm2 & Dm3). destruct Do as (Do1 & Do2 & Do3).
  assert (SzM0 : 0 <= szs G mario._MarioState) by (unfold szs; pose proof (sizeof_pos G (Tstruct mario._MarioState noattr)); lia).
  assert (SzO0 : 0 <= szs G mario._Object) by (unfold szs; pose proof (sizeof_pos G (Tstruct mario._Object noattr)); lia).
  pose proof (Ptrofs.unsigned_range oo) as Ro.
  assert (Mod : Ptrofs.modulus = 4294967296) by reflexivity.
  assert (Rs : forall r sz, r0_size (R0 G) r = Some sz ->
            (r = RM /\ sz = szs G mario._MarioState) \/ (r = RO /\ sz = szs G mario._Object)
            \/ (r = RFI /\ sz = 2) \/ (r = RMISS /\ sz = 4) \/ (r = RCALLS /\ sz = 6)).
  { intros r sz H. unfold r0_size, R0 in H. cbn [find fst] in H.
    destruct (Pos.eqb RM r) eqn:E1; [apply Pos.eqb_eq in E1; injection H as <-; auto |].
    destruct (Pos.eqb RO r) eqn:E2; [apply Pos.eqb_eq in E2; injection H as <-; auto |].
    destruct (Pos.eqb RFI r) eqn:E3; [apply Pos.eqb_eq in E3; injection H as <-; auto 6 |].
    destruct (Pos.eqb RMISS r) eqn:E4; [apply Pos.eqb_eq in E4; injection H as <-; auto 8 |].
    destruct (Pos.eqb RCALLS r) eqn:E5; [apply Pos.eqb_eq in E5; injection H as <-; auto 10 | discriminate]. }
  split; [| split; [| split; [| split; [| split]]]].
  - (* the regions' blocks are valid *)
    intros r _. apply gpv_valid. cbn [e_blk E0].
    destruct (Pos.eqb r RM); [exact Vm |]. destruct (Pos.eqb r RO); [exact Vo |].
    destruct (Pos.eqb r RFI); [exact Vfi |]. destruct (Pos.eqb r RMISS); [exact Vmiss | exact Vcalls].
  - (* sizes *)
    intros r sz H. destruct (Rs r sz H) as [(-> & ->) | [(-> & ->) | [(-> & ->) | [(-> & ->) | (-> & ->)]]]];
      cbn [e_base E0]; unfold RM, RO, RFI, RMISS, RCALLS; cbn [Pos.eqb]; rewrite ?Ptrofs.unsigned_zero;
      unfold Plt, NB; repeat split; try lia; exact Szo.
  - (* disjoint *)
    intros r sz r' sz' H H' N. left. cbn [e_blk E0].
    destruct (Rs r sz H) as [(-> & _) | [(-> & _) | [(-> & _) | [(-> & _) | (-> & _)]]]];
    destruct (Rs r' sz' H') as [(-> & _) | [(-> & _) | [(-> & _) | [(-> & _) | (-> & _)]]]];
      cbn; congruence.
  - (* the globals table *)
    intros id r H. unfold gfind, gtab in H. cbn [find fst] in H.
    destruct (Pos.eqb surface_collision._gFindFloorIncludeSurfaceIntangible id) eqn:E1;
      [apply Pos.eqb_eq in E1; subst id; injection H as <-; cbn [e_blk e_base E0]; unfold RM, RO, RFI, RMISS, RCALLS; cbn [Pos.eqb];
       refine (conj _ (conj _ _)); [unfold Plt, NB; lia | reflexivity | exact Sfi] |].
    destruct (Pos.eqb surface_collision._gNumFindFloorMisses id) eqn:E2;
      [apply Pos.eqb_eq in E2; subst id; injection H as <-; cbn [e_blk e_base E0]; unfold RM, RO, RFI, RMISS, RCALLS; cbn [Pos.eqb];
       refine (conj _ (conj _ _)); [unfold Plt, NB; lia | reflexivity | exact Smiss] |].
    destruct (Pos.eqb surface_collision._gNumCalls id) eqn:E3;
      [apply Pos.eqb_eq in E3; subst id; injection H as <-; cbn [e_blk e_base E0]; unfold RM, RO, RFI, RMISS, RCALLS; cbn [Pos.eqb];
       refine (conj _ (conj _ _)); [unfold Plt, NB; lia | reflexivity | exact Scalls] |].
    discriminate.
  - (* the known cells *)
    intros r o ch sv H. unfold kv in H. destruct H as [H | [H | []]]; injection H as <- <- <- <-.
    + split; [unfold Plt, NB, RM; lia |]. split; [cbn [sok nlt]; split; [cbn [nlt]; unfold Plt, NB, RO; lia | exact I] |].
      unfold addr. cbn [e_blk e_base E0 den]. unfold RM, RO; cbn [Pos.eqb].
      rewrite Ptrofs.unsigned_zero, Z.add_0_l, Ptrofs.add_zero. exact Kmo.
    + split; [unfold Plt, NB, RM; lia |]. split; [cbn [sok]; split; [cbn [nlt]; exact I | cbn [dold]; cbn; auto] |].
      unfold addr. cbn [e_blk e_base E0 den]. unfold RM, RO; cbn [Pos.eqb].
      rewrite Ptrofs.unsigned_zero, Z.add_0_l. exact Kact.
  - (* no fresh names yet *)
    intros n v H. discriminate.
Qed.

End START.


(* ---- the walk's start facts (pc0) from plain memory facts ---- *)
Section PC0.
Variable G : genv.
Variables (m0 : mem) (bm bo bfi bmiss bcalls : block) (oo : ptrofs).
Local Notation E := (E0 bm bo bfi bmiss bcalls oo).

(* a world pointer: a valid block that is none of the walk's regions *)
Definition wptr (v : val) (n : Z) : Prop :=
  exists b o, v = Vptr b o /\ Plt b (Mem.nextblock m0) /\ 0 <= n
    /\ Ptrofs.unsigned o + n <= Ptrofs.modulus
    /\ b <> bm /\ b <> bo /\ b <> bfi /\ b <> bmiss /\ b <> bcalls.

Lemma wptr_holds : forall p n v, den G m0 E p = Some v -> wptr v n ->
  fact_holds G (R0 G) m0 (ufW G m0 (gpv m0)) E (Fworld p n).
Proof.
  intros p n v D (b & o & -> & Vb & Hn & Ho & D1 & D2 & D3 & D4 & D5).
  cbn [fact_holds]. exists b, o. repeat split; try assumption.
  intros r sz _. left. cbn [e_blk E0].
  destruct (Pos.eqb r RM); [congruence |]. destruct (Pos.eqb r RO); [congruence |].
  destruct (Pos.eqb r RFI); [congruence |]. destruct (Pos.eqb r RMISS); congruence.
Qed.

Theorem pc0_mem : forall fl ar inp,
  Wff G m0 (gpv m0) (szs G mario._Surface)
    (map (den G m0 E) (wargs (R0 G))) ->
  Mem.load Mint16unsigned m0 bm 2 = Some (Vint inp) -> Int.and inp (Int.repr 2178) = Int.zero ->
  Mem.load Mint32 m0 bm (fo G mario._MarioState mario._floor) = Some fl ->
  wptr fl (szs G mario._Surface) ->
  (exists b o, fl = Vptr b o /\ styp m0 b o) ->
  Mem.load Mint32 m0 bm (fo G mario._MarioState mario._area) = Some ar ->
  wptr ar (szs G mario._Area) ->
  forall f, In f (pc0 G) -> fact_holds G (R0 G) m0 (ufW G m0 (gpv m0)) E f.
Proof.
  intros fl ar inp HW Li Ai Lf Wf Tf La Wa f Hf.
  assert (DI : forall o ch, den G m0 E (Sinit RM o ch) = Mem.load ch m0 bm o).
  { intros o ch. cbn [den e_blk e_base E0]. unfold RM, RO; cbn [Pos.eqb].
    rewrite Ptrofs.unsigned_zero, Z.add_0_l. reflexivity. }
  unfold pc0 in Hf. cbn [app In ffacts] in Hf.
  destruct Hf as [<- | [<- | [<- | [<- | [<- | [<- | []]]]]]].
  - cbn [fact_holds]. unfold ufW. rewrite Pos.eqb_refl. exact HW.
  - cbn [fact_holds]. exists inp. rewrite DI. split; [exact Li | exact Ai].
  - apply (wptr_holds _ _ fl); [rewrite DI; exact Lf | exact Wf].
  - apply (wptr_holds _ _ ar); [rewrite DI; exact La | exact Wa].
  - destruct Tf as (b & o & -> & T). apply (fty_holds G (R0 G) m0 _ E _ b o); [rewrite DI; exact Lf | exact T | auto].
  - destruct Tf as (b & o & -> & T). apply (fty_holds G (R0 G) m0 _ E _ b o); [rewrite DI; exact Lf | exact T | auto].
Qed.
End PC0.

(* ---- the layout facts the start needs, pinned on the real link ---- *)
Lemma layout12 : match ge12 with
  | Some g => Z.eqb (fo g mario._MarioState mario._marioObj) 136
              && Z.leb (szs g mario._MarioState) 4096 && Z.leb (szs g mario._Object) 4096
  | None => false end = true.
Proof. vm_compute. reflexivity. Qed.


Section LPS.
Variable lp : Clight.program.
Hypothesis H12 : linked12 lp.
Local Notation G := (globalenv lp).

Lemma layout_lp : fo G mario._MarioState mario._marioObj = 136
  /\ szs G mario._MarioState <= 4096 /\ szs G mario._Object <= 4096.
Proof.
  pose proof layout12 as L. rewrite (ge12_ok lp H12) in L.
  repeat rewrite andb_true_iff in L. destruct L as ((A & B) & C).
  apply Z.eqb_eq in A. apply Z.leb_le in B. apply Z.leb_le in C. auto.
Qed.

(* the air step from plain memory facts: Mario's state block (offset 0),
   his object (a pointer stored in m->marioObj, any offset), find_floor's
   statics, closedness, and the walk's start facts over E0 *)
Theorem air_step_move_mem : forall m0 bm bo oo bfi bmiss bcalls t m' vres c,
  (forall ch b z b' o', Plt b (Mem.nextblock m0) ->
     Mem.load ch m0 b z = Some (Vptr b' o') -> Plt b' (Mem.nextblock m0)) ->
  Plt bm (Mem.nextblock m0) -> Plt bo (Mem.nextblock m0) ->
  Genv.find_symbol G surface_collision._gFindFloorIncludeSurfaceIntangible = Some bfi ->
  Genv.find_symbol G surface_collision._gNumFindFloorMisses = Some bmiss ->
  Genv.find_symbol G surface_collision._gNumCalls = Some bcalls ->
  Plt bfi (Mem.nextblock m0) -> Plt bmiss (Mem.nextblock m0) -> Plt bcalls (Mem.nextblock m0) ->
  bm <> bo -> (bm <> bfi /\ bm <> bmiss /\ bm <> bcalls) -> (bo <> bfi /\ bo <> bmiss /\ bo <> bcalls) ->
  Ptrofs.unsigned oo + szs G mario._Object <= Ptrofs.modulus ->
  Mem.load Mint32 m0 bm OFS_MARIOOBJ = Some (Vptr bo oo) ->
  (forall f, In f (pc0 G) -> fact_holds G (R0 G) m0 (ufW G m0 (gpv m0)) (E0 bm bo bfi bmiss bcalls oo) f) ->
  eval_funcall function_entry2 G m0 (Internal mario_step.f_perform_air_step)
    [Vptr bm Ptrofs.zero; Vint Int.one] t m' vres ->
  read_cells bm m0 c -> budget_ok c -> c_action c = ACT_FREEFALL ->
  floor_data G m0 -> FloorRefreshOK wmotr_floor (R2 (c_posy c)) (R2 (c_floorh c)) ->
  exists c', read_cells bm m' c' /\ RM' c c'.
Proof.
  intros m0 bm bo oo bfi bmiss bcalls t m' vres c HC Vm Vo Sfi Smiss Scalls Vfi Vmiss Vcalls
    Dmo Dm Do Szo Kmo PC EV RC Hc Hact FD FRO.
  destruct layout_lp as (FO & SM & SO).
  assert (EO : env_ok G NB (R0 G) gtab (kv G) m0 (gpv m0) (E0 bm bo bfi bmiss bcalls oo)).
  { apply (start_env G m0 bm bo bfi bmiss bcalls oo); try assumption.
    - assert (Ptrofs.modulus = 4294967296) by reflexivity. lia.
    - rewrite FO. exact Kmo.
    - destruct RC as (HA & _). rewrite Hact in HA. exact HA. }
  exact (air_step_move lp H12 m0 (gpv m0) (E0 bm bo bfi bmiss bcalls oo) t m' vres c
           (gpv_old m0) (gpv_closed m0 HC) EO PC eq_refl EV RC Hc FD FRO).
Qed.

(* the same, with the walk's start facts as plain memory facts too *)
Theorem air_step_move_mem2 : forall m0 bm bo oo bfi bmiss bcalls t m' vres c fl ar inp,
  (forall ch b z b' o', Plt b (Mem.nextblock m0) ->
     Mem.load ch m0 b z = Some (Vptr b' o') -> Plt b' (Mem.nextblock m0)) ->
  Plt bm (Mem.nextblock m0) -> Plt bo (Mem.nextblock m0) ->
  Genv.find_symbol G surface_collision._gFindFloorIncludeSurfaceIntangible = Some bfi ->
  Genv.find_symbol G surface_collision._gNumFindFloorMisses = Some bmiss ->
  Genv.find_symbol G surface_collision._gNumCalls = Some bcalls ->
  Plt bfi (Mem.nextblock m0) -> Plt bmiss (Mem.nextblock m0) -> Plt bcalls (Mem.nextblock m0) ->
  bm <> bo -> (bm <> bfi /\ bm <> bmiss /\ bm <> bcalls) -> (bo <> bfi /\ bo <> bmiss /\ bo <> bcalls) ->
  Ptrofs.unsigned oo + szs G mario._Object <= Ptrofs.modulus ->
  Mem.load Mint32 m0 bm OFS_MARIOOBJ = Some (Vptr bo oo) ->
  (* the world's floor lists (FloorExec.Wff) *)
  Wff G m0 (gpv m0) (szs G mario._Surface)
    (map (den G m0 (E0 bm bo bfi bmiss bcalls oo)) (wargs (R0 G))) ->
  (* no A bits in m->input *)
  Mem.load Mint16unsigned m0 bm 2 = Some (Vint inp) -> Int.and inp (Int.repr 2178) = Int.zero ->
  (* m->floor and m->area are world objects; the floor has a WMotR type *)
  Mem.load Mint32 m0 bm (fo G mario._MarioState mario._floor) = Some fl ->
  wptr m0 bm bo bfi bmiss bcalls fl (szs G mario._Surface) ->
  (exists b o, fl = Vptr b o /\ styp m0 b o) ->
  Mem.load Mint32 m0 bm (fo G mario._MarioState mario._area) = Some ar ->
  wptr m0 bm bo bfi bmiss bcalls ar (szs G mario._Area) ->
  eval_funcall function_entry2 G m0 (Internal mario_step.f_perform_air_step)
    [Vptr bm Ptrofs.zero; Vint Int.one] t m' vres ->
  read_cells bm m0 c -> budget_ok c -> c_action c = ACT_FREEFALL ->
  floor_data G m0 -> FloorRefreshOK wmotr_floor (R2 (c_posy c)) (R2 (c_floorh c)) ->
  exists c', read_cells bm m' c' /\ RM' c c'.
Proof.
  intros m0 bm bo oo bfi bmiss bcalls t m' vres c fl ar inp HC Vm Vo Sfi Smiss Scalls Vfi Vmiss Vcalls
    Dmo Dm Do Szo Kmo HW Li Ai Lf Wf Tf La Wa EV RC Hc Hact FD FRO.
  apply (air_step_move_mem m0 bm bo oo bfi bmiss bcalls t m' vres c); try assumption.
  exact (pc0_mem G m0 bm bo bfi bmiss bcalls oo fl ar inp HW Li Ai Lf Wf Tf La Wa).
Qed.
End LPS.
