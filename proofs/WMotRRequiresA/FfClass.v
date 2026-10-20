(* ====================================================================== *)
(* FfClass (unwired, GOAL 2): each outcome of the real act_freefall is a  *)
(* HeightMoveCatalog MoveChain of Phi's cells.                            *)
(*                                                                        *)
(* The walk of act_freefall (with AirSum.c_pas answering perform_air_step) *)
(* ends in outcomes of four kinds (the census of the 348 outcomes):       *)
(*   entry switch  B / Z before the air step: DIVE (Sw_plain) or          *)
(*                 GROUND_POUND (Sw_gp); the four moving cells untouched; *)
(*   stay          the air step only (class 0): the cells are its cells;  *)
(*   wall switch   class 0, then AIR_HIT_WALL / BACKWARD_AIR_KB /          *)
(*                 SOFT_BONK, vel[1] kept or zeroed when it was > 0       *)
(*                 (Sw_plain after the step);                             *)
(*   attach        class 1 (landing) or 2 (ledge grab), then a ground     *)
(*                 action (FREEFALL_LAND, the hard-fall knockback, feet   *)
(*                 stuck, LEDGE_GRAB): one S_attach from the entry cells  *)
(*                 at the height the step snapped to.                     *)
(* ff_ok checks one of these syntactically on the outcome; ff_sound turns *)
(* it into read_cells + MoveChain, using the step's fact (AirSum.MV).     *)
(* ====================================================================== *)

From Coq Require Import ZArith Reals List Lia Lra Bool Relations.
From compcert Require Import Coqlib Maps AST Integers Floats Values Memory Ctypes Cop Clight.
From Flocq Require Import Raux.
From SM64.Proofs Require Import Interp.SymExec2 HeightInvariant HeightMoveCatalog WMotRLevel.
From SM64.Proofs.WMotRRequiresA Require Import FloorHeight AirMatch AirMove AirSum.
Import ListNotations.
Local Open Scope R_scope.
Local Transparent Float32.cmp Float32.compare.

Lemma mode_eq_dec : forall a b : mode, {a = b} + {a <> b}.
Proof. decide equality. Defined.
Definition mode_eqb (a b : mode) : bool := if mode_eq_dec a b then true else false.

Definition ci (s : sval) : option int := match s with Sconst (Vint i) => Some i | _ => None end.

(* the path fact "v1 > 0.0f" *)
Definition velpos (v1 : sval) (f : fact) : bool :=
  match f with
  | Fbool (Sbinop Ogt a t1 (Sconst (Vsingle z)) t2) ty true =>
      sveqb a v1 && is_tf t1 && is_tf t2 && (if Float32.eq_dec z Float32.zero then true else false)
      && (if type_eq ty ti32 then true else false)
  | _ => false
  end.

Definition kmargs (kM : positive) (pc : list fact) : option (list sval) :=
  match find (fun f => match f with Fuser k _ => Pos.eqb k kM | _ => false end) pc with
  | Some (Fuser _ a) => Some a
  | _ => None
  end.

Definition lsveqb (a b : list sval) : bool := if list_eq_dec sval_eq a b then true else false.

Section CLASS.
Variables (nbase : positive) (R0 : list (positive * Z)) (kv : list (positive * Z * memory_chunk * sval)).
Variables (rM rO kM : positive).
Local Notation LD := (sload nbase R0 kv).
Local Notation ic := (init_cell kv).

(* the final action/state/timer are constants with a mode the predicate accepts *)
Definition consts_ok (sa ss st : sval) (P : mode -> int -> int -> int -> bool) : bool :=
  match ci sa, ci ss, ci st with
  | Some a, Some s, Some t => P (mode_of_action a (Int.unsigned s)) a s t
  | _, _, _ => false
  end.

Definition entry_sw (md : mode) (a s t : int) : bool :=
  mode_eqb md M_Air || (Int.eq a ACT_GROUND_POUND && Int.eq s Int.zero && Int.eq t Int.zero).

Definition step_ok (pc : list fact) (sa ss st sy sv sf sg : sval) (args : list sval) : bool :=
  match args with
  | _ :: Sconst (Vint cl) :: _ :: rest =>
      lsveqb (firstn 7 rest) (map (ic_of kv) (pkeys rM rO)) &&
      match skipn 7 rest with
      | [a1; s1; t1; y1; v1; f1; g1] =>
          sveqb sy y1 && sveqb sf f1 && sveqb sg g1 &&
          ( (* stay *)
            (Int.eq cl Int.zero && sveqb sa a1 && sveqb ss s1 && sveqb st t1 && sveqb sv v1)
          || (* wall switch *)
            (Int.eq cl Int.zero && sveqb a1 (Sconst (Vint ACT_FREEFALL))
             && consts_ok sa ss st (fun md _ _ _ => mode_eqb md M_Air)
             && (sveqb sv v1 || (sveqb sv (Sconst (Vsingle Float32.zero)) && existsb (velpos v1) pc)))
          || (* attach *)
            ((Int.eq cl Int.one || Int.eq cl (Int.repr 2)) && sveqb sv v1
             && consts_ok sa ss st (fun md a _ _ => mode_eqb md M_Ground
                                      && (negb (Int.eq a ACT_LEDGE_GRAB) || Int.eq cl (Int.repr 2)))))
      | _ => false
      end
  | _ => false
  end.

Definition ff_ok (g : gst) : bool :=
  match LD g rM oMO Mint32, LD g rM oA Mint32, LD g rM oS Mint16unsigned, LD g rM oT Mint16unsigned,
        LD g rM oY Mfloat32, LD g rM oV Mfloat32, LD g rM oF Mfloat32, LD g rO oG Mfloat32 with
  | Some (Sptr r0 z0), Some sa, Some ss, Some st, Some sy, Some sv, Some sf, Some sg =>
      Pos.eqb r0 rO && Ptrofs.eq z0 Ptrofs.zero &&
      match kmargs kM (g_pc g) with
      | None => sveqb sy (ic rM oY Mfloat32) && sveqb sv (ic rM oV Mfloat32)
                && sveqb sf (ic rM oF Mfloat32) && sveqb sg (ic rO oG Mfloat32)
                && consts_ok sa ss st entry_sw
      | Some args => step_ok (g_pc g) sa ss st sy sv sf sg args
      end
  | _, _, _, _, _, _, _, _ => false
  end.
End CLASS.

(* ---------------------------------------------------------------------- *)
(* Small facts                                                            *)
(* ---------------------------------------------------------------------- *)

Lemma sveqb_eq : forall a b, sveqb a b = true -> a = b.
Proof. intros a b H. unfold sveqb in H. destruct (sval_eq a b); [exact e | discriminate]. Qed.

Lemma lsveqb_eq : forall a b, lsveqb a b = true -> a = b.
Proof. intros a b H. unfold lsveqb in H. destruct (list_eq_dec sval_eq a b); [exact e | discriminate]. Qed.

Lemma mode_eqb_eq : forall a b, mode_eqb a b = true -> a = b.
Proof. intros a b H. unfold mode_eqb in H. destruct (mode_eq_dec a b); [exact e | discriminate]. Qed.

Lemma ci_some : forall s i, ci s = Some i -> s = Sconst (Vint i).
Proof. intros s i H. destruct s as [[]| | | | | | | | |]; try discriminate. injection H as <-. reflexivity. Qed.

Lemma consts_ok_inv : forall sa ss st P, consts_ok sa ss st P = true ->
  exists a s t, sa = Sconst (Vint a) /\ ss = Sconst (Vint s) /\ st = Sconst (Vint t)
                /\ P (mode_of_action a (Int.unsigned s)) a s t = true.
Proof.
  intros sa ss st P H. unfold consts_ok in H.
  destruct (ci sa) as [a|] eqn:A; [| discriminate].
  destruct (ci ss) as [s|] eqn:B; [| discriminate].
  destruct (ci st) as [t|] eqn:C; [| discriminate].
  exists a, s, t. rewrite (ci_some _ _ A), (ci_some _ _ B), (ci_some _ _ C). auto.
Qed.

Lemma cgt_true_pos : forall v, F32 v = true -> Float32.cmp Cgt v Float32.zero = true -> 0 < R2 v.
Proof.
  intros v Fv H. unfold Float32.cmp, Float32.compare in H.
  rewrite Binary.Bcompare_correct in H by first [exact Fv | reflexivity].
  destruct (Rcompare_spec (R2 v) (R2 Float32.zero)) as [L | L | L]; simpl in H; try discriminate;
    replace (R2 Float32.zero) with 0 in L by reflexivity; lra.
Qed.

Local Opaque Float32.cmp Float32.compare.

Lemma mode_ff_of : forall c, c_action c = ACT_FREEFALL -> mode_of c = M_Freefall.
Proof. intros c H. unfold mode_of, mode_of_action. rewrite H, Int.eq_true. reflexivity. Qed.

(* ---------------------------------------------------------------------- *)
(* Soundness                                                              *)
(* ---------------------------------------------------------------------- *)

Section SOUND.
Variables (ge : genv) (nbase : positive) (R0 : list (positive * Z)) (gtab : list (ident * positive))
  (kv : list (positive * Z * memory_chunk * sval)) (m0 : mem)
  (uf : positive -> list (option val) -> Prop) (gp : meminj).
Hypothesis gp_old : forall b x, gp b = Some x -> Plt b (Mem.nextblock m0).
Variables (rM rO kM : positive).
Hypothesis HUM : forall vs, uf kM vs -> MV vs.
Variables (E : senv) (m : mem) (g : gst).
Hypothesis MM : MMg ge nbase R0 gtab kv m0 uf gp E m g.
Hypothesis HbM : e_base E rM = Ptrofs.zero.
Local Notation bm := (e_blk E rM).
(* the entry: Mario's object is the object region; the entry cells c0 *)
Hypothesis HO0 : Mem.load Mint32 m0 bm oMO = Some (Vptr (e_blk E rO) (e_base E rO)).
Variable c0 : cells.
Hypothesis RC0 : read_cells bm m0 c0.
Hypothesis Hact : c_action c0 = ACT_FREEFALL.
Hypothesis Hb : budget_ok c0.
Hypothesis FRO : FloorRefreshOK wmotr_floor (R2 (c_posy c0)) (R2 (c_floorh c0)).

Local Notation den := (SymExec2.den ge m0 E).
Local Notation LD := (sload nbase R0 kv g).

Lemma AM : forall o, addr E rM o = o.
Proof. intros o. unfold addr. rewrite HbM, Ptrofs.unsigned_zero. reflexivity. Qed.

Lemma ld_m : forall o ch s, LD rM o ch = Some s -> Mem.load ch m bm o = den s.
Proof.
  intros o ch s L. rewrite <- (AM o).
  exact (proj1 (sload_sound ge nbase R0 gtab kv (fun _ => None) (fun _ => false) m0 uf gp gp_old
                  E m g rM o ch s MM L)).
Qed.

Lemma ld_o : forall o ch s, LD rO o ch = Some s -> Mem.load ch m (e_blk E rO) (addr E rO o) = den s.
Proof.
  intros o ch s L.
  exact (proj1 (sload_sound ge nbase R0 gtab kv (fun _ => None) (fun _ => false) m0 uf gp gp_old
                  E m g rO o ch s MM L)).
Qed.

Lemma env : env_ok ge nbase R0 gtab kv m0 gp E.
Proof. destruct MM as (EO & _). exact EO. Qed.

Lemma ic_m : forall o ch, den (init_cell kv rM o ch) = Mem.load ch m0 bm o.
Proof.
  intros o ch. rewrite (proj1 (init_cell_den ge nbase R0 gtab kv m0 gp E rM o ch env)). rewrite AM.
  reflexivity.
Qed.

Lemma ic_o : forall o ch, den (init_cell kv rO o ch) = Mem.load ch m0 (e_blk E rO) (addr E rO o).
Proof. intros o ch. exact (proj1 (init_cell_den ge nbase R0 gtab kv m0 gp E rO o ch env)). Qed.

(* the entry cells, as the step's fact lists them *)
Lemma entry_vals : map den (map (ic_of kv) (pkeys rM rO)) = map Some (cvals c0).
Proof.
  destruct RC0 as (A & S & T & Y & V & F & bo & oo & LO & GY).
  change Mptr with Mint32 in LO. change OFS_MARIOOBJ with oMO in LO. rewrite HO0 in LO.
  injection LO as <- <-.
  cbn [map pkeys mkeys app ic_of cvals]. rewrite !ic_m, ic_o.
  change oA with OFS_ACTION. change oS with OFS_ASTATE. change oT with OFS_ATIMER.
  change oY with OFS_POSY. change oV with OFS_VELY. change oF with OFS_FLOORH.
  unfold addr. change oG with OFS_GFXY.
  rewrite A, S, T, Y, V, F, GY. reflexivity.
Qed.

(* the final cells are read_cells when each load is known *)
Lemma mk_read : forall c2 s,
  LD rM oMO Mint32 = Some (Sptr rO Ptrofs.zero) ->
  Mem.load Mint32 m bm oA = Some (Vint (c_action c2)) ->
  Mem.load Mint16unsigned m bm oS = Some (Vint (c_state c2)) ->
  Mem.load Mint16unsigned m bm oT = Some (Vint (c_timer c2)) ->
  Mem.load Mfloat32 m bm oY = Some (Vsingle (c_posy c2)) ->
  Mem.load Mfloat32 m bm oV = Some (Vsingle (c_vely c2)) ->
  Mem.load Mfloat32 m bm oF = Some (Vsingle (c_floorh c2)) ->
  LD rO oG Mfloat32 = Some s -> den s = Some (Vsingle (c_gfxy c2)) ->
  read_cells bm m c2.
Proof.
  intros c2 s LMO A S T Y V F LG DG.
  pose proof (ld_m _ _ _ LMO) as M. cbn [SymExec2.den] in M. rewrite Ptrofs.add_zero in M.
  pose proof (ld_o _ _ _ LG) as G. rewrite DG in G.
  unfold read_cells. repeat split; try assumption.
  exists (e_blk E rO), (e_base E rO). split; [exact M |]. unfold addr in G. exact G.
Qed.

Lemma inrange_same : forall c c', InRange c ->
  c_posy c' = c_posy c -> c_vely c' = c_vely c -> c_floorh c' = c_floorh c -> c_gfxy c' = c_gfxy c ->
  InRange c'.
Proof. intros c c' H A B C D. unfold InRange in *. rewrite A, B, C, D. exact H. Qed.

Lemma inrange_vel0 : forall c c', InRange c ->
  c_posy c' = c_posy c -> c_vely c' = Float32.zero -> c_floorh c' = c_floorh c -> c_gfxy c' = c_gfxy c ->
  InRange c'.
Proof.
  intros c c' H A B C D. unfold InRange in *. rewrite A, B, C, D.
  replace (R2 Float32.zero) with 0 by reflexivity.
  destruct H as (H1 & _ & H3 & H4 & H5 & [H6 H7] & _). repeat split; try assumption; try reflexivity; lra.
Qed.

(* the step's fact, at the entry cells *)
Lemma step_fact : forall n1 cl r rest a1 s1 t1 y1 v1 f1 g1,
  In (Fuser kM (n1 :: Sconst (Vint cl) :: r :: rest)) (g_pc g) ->
  firstn 7 rest = map (ic_of kv) (pkeys rM rO) -> skipn 7 rest = [a1; s1; t1; y1; v1; f1; g1] ->
  exists c1, PMc cl c0 c1
    /\ den a1 = Some (Vint (c_action c1)) /\ den s1 = Some (Vint (c_state c1))
    /\ den t1 = Some (Vint (c_timer c1)) /\ den y1 = Some (Vsingle (c_posy c1))
    /\ den v1 = Some (Vsingle (c_vely c1)) /\ den f1 = Some (Vsingle (c_floorh c1))
    /\ den g1 = Some (Vsingle (c_gfxy c1)).
Proof.
  intros n1 cl r rest a1 s1 t1 y1 v1 f1 g1 I H7 S7.
  destruct MM as (_ & _ & _ & _ & _ & _ & PC & _).
  destruct (PC _ I) as [_ FH]. cbn [fact_holds] in FH. apply HUM in FH.
  rewrite <- (firstn_skipn 7 rest), H7, S7 in FH.
  destruct (FH c0) as (cl' & rv & c1 & Heq & P).
  - rewrite <- entry_vals. reflexivity.
  - exact Hact.
  - exact Hb.
  - exact FRO.
  - cbn [map app pkeys mkeys ic_of cvals] in Heq.
    injection Heq as _ Ecl _ _ _ _ _ _ _ _ A S T Y V F G. subst cl'.
    exists c1. auto 10.
Qed.

Lemma velpos_sound : forall v1 x f, In f (g_pc g) -> velpos v1 f = true ->
  den v1 = Some (Vsingle x) -> F32 x = true -> 0 < R2 x.
Proof.
  intros v1 x f I H D Fx.
  destruct f as [c ty b | | |]; try discriminate H.
  destruct c as [| | | | | | | [] a t1 [[]| | | | | | | | |] t2 | |]; try discriminate H.
  destruct b; [| discriminate H].
  cbn [velpos] in H. repeat rewrite andb_true_iff in H.
  destruct H as [[[[Ea T1] T2] Z] Ty].
  apply sveqb_eq in Ea. subst a. apply is_tf_eq in T1. apply is_tf_eq in T2. subst t1 t2.
  destruct (Float32.eq_dec f Float32.zero) as [-> |]; [| discriminate Z].
  destruct (type_eq ty ti32) as [-> |]; [| discriminate Ty].
  destruct MM as (_ & _ & _ & _ & _ & _ & PC & _).
  destruct (PC _ I) as [_ (w & Dw & Bw)].
  cbn [SymExec2.den] in Dw. rewrite D in Dw. cbn in Dw. injection Dw as <-.
  destruct (Float32.cmp Cgt x Float32.zero) eqn:C; [exact (cgt_true_pos x Fx C) |].
  cbn in Bw. discriminate Bw.
Qed.

Local Notation MC := (MoveChain wmotr_floor wmotr_pole wmotr_cannon).
Local Notation RMv := (RangedMove wmotr_floor wmotr_pole wmotr_cannon).

Lemma Inrange_of : forall c c1, RM' c c1 -> InRange c1.
Proof. intros c c1 [H _]. exact H. Qed.

(* an outcome that stays in freefall is a floor refresh again *)
Definition fro_ff (c : cells) : Prop :=
  c_action c = ACT_FREEFALL -> FloorRefreshOK wmotr_floor (R2 (c_posy c)) (R2 (c_floorh c)).

Lemma not_ff_mode : forall a s md, mode_of_action a s = md -> md <> M_Freefall -> a <> ACT_FREEFALL.
Proof.
  intros a s md H N ->. apply N. rewrite <- H. unfold mode_of_action. rewrite Int.eq_true. reflexivity.
Qed.

Theorem ff_sound : ff_ok nbase R0 kv rM rO kM g = true ->
  exists c2, read_cells bm m c2 /\ MC c0 c2 /\ fro_ff c2.
Proof.
  intros OK. unfold ff_ok in OK.
  destruct (LD rM oMO Mint32) as [smo|] eqn:LMO; [| discriminate OK].
  destruct smo as [| r0 z0 | | | | | | | |]; try discriminate OK.
  destruct (LD rM oA Mint32) as [sa|] eqn:La; [| discriminate OK].
  destruct (LD rM oS Mint16unsigned) as [ss|] eqn:Ls; [| discriminate OK].
  destruct (LD rM oT Mint16unsigned) as [st|] eqn:Lt; [| discriminate OK].
  destruct (LD rM oY Mfloat32) as [sy|] eqn:Ly; [| discriminate OK].
  destruct (LD rM oV Mfloat32) as [sv|] eqn:Lv; [| discriminate OK].
  destruct (LD rM oF Mfloat32) as [sf|] eqn:Lf; [| discriminate OK].
  destruct (LD rO oG Mfloat32) as [sg|] eqn:Lg; [| discriminate OK].
  apply andb_true_iff in OK as [OK0 OK]. apply andb_true_iff in OK0 as [E0 Ez].
  apply Pos.eqb_eq in E0. subst r0.
  pose proof (Ptrofs.eq_spec z0 Ptrofs.zero) as Z0. rewrite Ez in Z0. subst z0.
  pose proof (ld_m _ _ _ La) as MA. pose proof (ld_m _ _ _ Ls) as MS. pose proof (ld_m _ _ _ Lt) as MT.
  pose proof (ld_m _ _ _ Ly) as MY. pose proof (ld_m _ _ _ Lv) as MV'. pose proof (ld_m _ _ _ Lf) as MF.
  pose proof Hb as (IR0 & _).
  pose proof entry_vals as EV. cbn [map pkeys mkeys app ic_of cvals] in EV.
  injection EV as DA0 DS0 DT0 DY0 DV0 DF0 DG0.
  destruct (kmargs kM (g_pc g)) as [args|] eqn:K.
  - (* the air step ran *)
    unfold kmargs in K.
    destruct (find _ (g_pc g)) as [f|] eqn:Fd; [| discriminate K].
    destruct (find_some _ _ Fd) as [If Kf].
    destruct f as [| | | k args']; try discriminate K. injection K as ->.
    apply Pos.eqb_eq in Kf. subst k.
    unfold step_ok in OK.
    destruct args as [| n1 [| sc rest0]]; try discriminate OK.
    destruct sc as [[| cl | | | |] | | | | | | | | |]; try discriminate OK.
    destruct rest0 as [| r rest]; try discriminate OK.
    apply andb_true_iff in OK as [H7 OK]. apply lsveqb_eq in H7.
    destruct (skipn 7 rest) as [| a1 [| s1 [| t1 [| y1 [| v1 [| f1 [| g1 [|]]]]]]]] eqn:S7;
      try discriminate OK.
    destruct (step_fact n1 cl r rest a1 s1 t1 y1 v1 f1 g1 If H7 S7)
      as (c1 & (RM1 & AI & AO & FR1) & DA1 & DS1 & DT1 & DY1 & DV1 & DF1 & DG1).
    repeat rewrite andb_true_iff in OK. destruct OK as [[[Ey Ef] Eg] OK].
    apply sveqb_eq in Ey, Ef, Eg. subst sy sf sg.
    rewrite DY1 in MY. rewrite DF1 in MF.
    pose proof (Inrange_of _ _ RM1) as IR1.
    apply orb_true_iff in OK as [OK | OK]; [apply orb_true_iff in OK as [OK | OK] |].
    + (* stay *)
      repeat rewrite andb_true_iff in OK. destruct OK as [[[[Ec Ea] Es] Et] Ev].
      apply sveqb_eq in Ea, Es, Et, Ev. subst sa ss st sv.
      exists c1. split; [| split].
      * rewrite DA1 in MA. rewrite DS1 in MS. rewrite DT1 in MT. rewrite DV1 in MV'.
        exact (mk_read c1 g1 LMO MA MS MT MY MV' MF Lg DG1).
      * apply rt_step. exact RM1.
      * intros _. apply FR1. pose proof (Int.eq_spec cl Int.zero) as X. rewrite Ec in X. exact X.
    + (* wall switch *)
      repeat rewrite andb_true_iff in OK. destruct OK as [[[Ec Ea1] CK] VV].
      apply sveqb_eq in Ea1. subst a1. cbn [SymExec2.den] in DA1. injection DA1 as DA1.
      destruct (consts_ok_inv _ _ _ _ CK) as (a & s & t & -> & -> & -> & Md).
      apply mode_eqb_eq in Md. cbn [SymExec2.den] in MA, MS, MT.
      assert (Hv2 : exists v2, Mem.load Mfloat32 m bm oV = Some (Vsingle v2)
                    /\ (v2 = c_vely c1 \/ (v2 = Float32.zero /\ 0 < R2 (c_vely c1)))).
      { apply orb_true_iff in VV as [VV | VV].
        - apply sveqb_eq in VV. subst sv. exists (c_vely c1). rewrite MV', DV1. auto.
        - apply andb_true_iff in VV as [VV P]. apply sveqb_eq in VV. subst sv.
          exists Float32.zero. split; [exact MV' |]. right. split; [reflexivity |].
          apply existsb_exists in P as (f & If' & Pf).
          exact (velpos_sound v1 (c_vely c1) f If' Pf DV1 (proj1 (proj2 IR1))). }
      destruct Hv2 as (v2 & LV & Hv2).
      set (c2 := mkCells a s t (c_posy c1) v2 (c_floorh c1) (c_gfxy c1)).
      exists c2. split; [| split; [| intros Ea; exfalso; exact (not_ff_mode _ _ _ Md ltac:(discriminate) Ea)]].
      * exact (mk_read c2 g1 LMO MA MS MT MY LV MF Lg DG1).
      * eapply rt_trans; [apply rt_step; exact RM1 | apply rt_step].
        assert (M1 : mode_of c1 = M_Freefall) by (apply mode_ff_of; symmetry; exact DA1).
        split.
        -- destruct Hv2 as [-> | (-> & _)];
             [ apply (inrange_same c1 c2 IR1); reflexivity
             | apply (inrange_vel0 c1 c2 IR1); reflexivity ].
        -- apply S_switch; [reflexivity | reflexivity | reflexivity |].
           apply Sw_plain.
           ++ rewrite M1. discriminate.
           ++ exact Md.
           ++ cbn [c_vely c2]. destruct Hv2 as [-> | (-> & P)]; [apply Rle_refl |].
              replace (R2 Float32.zero) with 0 by reflexivity. lra.
           ++ intros N. exfalso. exact (N M1).
    + (* attach *)
      repeat rewrite andb_true_iff in OK. destruct OK as [[Ecl Ev] CK].
      apply sveqb_eq in Ev. subst sv. rewrite DV1 in MV'.
      destruct (consts_ok_inv _ _ _ _ CK) as (a & s & t & -> & -> & -> & Md).
      apply andb_true_iff in Md as [Md LG]. apply mode_eqb_eq in Md.
      cbn [SymExec2.den] in MA, MS, MT.
      assert (NZ : cl <> Int.zero).
      { intros ->. apply orb_true_iff in Ecl as [X | X]; vm_compute in X; discriminate X. }
      destruct (AI NZ) as (h & AOK & Lh & Gh).
      set (c2 := mkCells a s t (c_posy c1) (c_vely c1) (c_floorh c1) (c_gfxy c1)).
      exists c2. split; [| split; [| intros Ea; exfalso; exact (not_ff_mode _ _ _ Md ltac:(discriminate) Ea)]].
      * exact (mk_read c2 g1 LMO MA MS MT MY MV' MF Lg DG1).
      * apply rt_step. split; [apply (inrange_same c1 c2 IR1); reflexivity |].
        apply (S_attach _ _ _ c0 c2 h AOK).
        -- exact Lh.
        -- left. exact Gh.
        -- change (mode_of c2) with (mode_of_action a (Int.unsigned s)). rewrite Md. exact Logic.I.
        -- cbn [c_action c2 c_floorh]. intros EL. subst a.
           rewrite Int.eq_true in LG. cbn [negb orb] in LG.
           apply AO. pose proof (Int.eq_spec cl (Int.repr 2)) as X. rewrite LG in X. exact X.
  - (* B / Z before the air step *)
    repeat rewrite andb_true_iff in OK. destruct OK as [[[[Ey Ev] Ef] Eg] CK].
    apply sveqb_eq in Ey, Ev, Ef, Eg. subst sy sv sf sg.
    destruct (consts_ok_inv _ _ _ _ CK) as (a & s & t & -> & -> & -> & SW).
    cbn [SymExec2.den] in MA, MS, MT.
    set (c2 := mkCells a s t (c_posy c0) (c_vely c0) (c_floorh c0) (c_gfxy c0)).
    assert (M0 : mode_of c0 = M_Freefall) by exact (mode_ff_of c0 Hact).
    exists c2. split; [| split].
    + rewrite DY0 in MY. rewrite DV0 in MV'. rewrite DF0 in MF.
      exact (mk_read c2 _ LMO MA MS MT MY MV' MF Lg DG0).
    + apply rt_step. split; [apply (inrange_same c0 c2 IR0); reflexivity |].
      apply S_switch; [reflexivity | reflexivity | reflexivity |].
      unfold entry_sw in SW. apply orb_true_iff in SW as [SW | SW].
      * apply mode_eqb_eq in SW. apply Sw_plain.
        -- rewrite M0. discriminate.
        -- exact SW.
        -- apply Rle_refl.
        -- intros N. exfalso. exact (N M0).
      * repeat rewrite andb_true_iff in SW. destruct SW as [[Ea Es] Et].
        pose proof (Int.eq_spec a ACT_GROUND_POUND) as X. rewrite Ea in X.
        pose proof (Int.eq_spec s Int.zero) as Y. rewrite Es in Y.
        pose proof (Int.eq_spec t Int.zero) as W. rewrite Et in W.
        subst s t. apply Sw_gp; [exact M0 | exact X | reflexivity | reflexivity].
    + intros Ea. change (a = ACT_FREEFALL) in Ea. exfalso. unfold entry_sw in SW. apply orb_true_iff in SW as [SW | SW].
      * apply mode_eqb_eq in SW. exact (not_ff_mode _ _ _ SW ltac:(discriminate) Ea).
      * subst a. vm_compute in SW. discriminate SW.
Qed.
End SOUND.
