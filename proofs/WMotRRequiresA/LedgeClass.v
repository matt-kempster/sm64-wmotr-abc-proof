(* ====================================================================== *)
(* LedgeClass (GOAL 2): each outcome of a walk of the real act_ledge_grab *)
(* / act_ledge_climb_down is ONE HeightMoveCatalog S_attach of Phi's      *)
(* cells, from a grounded (ledge) action.                                 *)
(*                                                                        *)
(* The handlers end in one of three shapes (mario_actions_automatic.c):   *)
(*   switch: set_mario_action into a climb (TRUE): pos[1], gfx.pos[1],     *)
(*     vel[1] are the entry's -- attach at h = pos[1] (grounded);          *)
(*   snap: stop_and_set_height_to_floor: pos[1] = gfx.pos[1] =             *)
(*     floorHeight, vel[1] = 0 -- attach at h = floorHeight, a floor       *)
(*     refresh (the dispatch's fresh floor) or -11000;                     *)
(*   let go (let_go_of_ledge, TRUE): SOFT_BONK, vel[1] = 0, gfx kept,      *)
(*     pos[1] = y - 100.0f under a find_floor height F (attach at h = y,   *)
(*     grounded), or F itself, not below y - 100.0f (attach at h = F: a    *)
(*     WMotR floor at most y + 80, or -11000).                             *)
(* floorHeight is the entry's on every outcome.  ledge_sound turns        *)
(* ledge_ok into read_cells + a RangedMove; letgo_sound turns letgo_ok    *)
(* into LedgeRun.LETGO's facts (pos[1] at most 101 below the entry's).    *)
(* ====================================================================== *)

From Coq Require Import ZArith Reals List Lia Lra Bool.
From compcert Require Import Coqlib Maps AST Integers Floats Values Memory Ctypes Cop Clight.
From Flocq Require Import Core.
From SM64.Proofs Require Import Interp.SymExec2 HeightInvariant HeightMoveCatalog WMotRLevel.
From SM64.Proofs.WMotRRequiresA Require Import HeightFloatSteps FloorList FloorHeight FloorBound AirMatch
  FfClass WMotRWorld PoleFloat PoleClass PoleSound.
Import ListNotations.

Local Open Scope R_scope.

Definition c100 : float32 := Float32.of_bits (Int.repr 1120403456).   (* 100.0f *)
Definition SB_A : Z := 16910518.
(* the actions an outcome may end in: LEDGE_GRAB, LEDGE_CLIMB_SLOW_1,
   LEDGE_CLIMB_DOWN, LEDGE_CLIMB_FAST, SOFT_BONK; and (the climbs,
   2026-10-22) LEDGE_CLIMB_SLOW_2, update_ledge_climb's ACT_IDLE, and
   check_common_action_exits' no-A exits ACT_WALKING, ACT_BEGIN_SLIDING
   (set_mario_action makes it BUTT_SLIDE / STOMACH_SLIDE) and ACT_FREEFALL *)
Definition LEDGE_OUT : list Z :=
  [134218571; 1356; 1358; 1359; 16910518; 1357; 205521409; 67109952; 8651858; 9176147; 16779404]%Z.
(* the ledge handlers walked: LEDGE_GRAB, LEDGE_CLIMB_DOWN,
   LEDGE_CLIMB_SLOW_1 / _2 (one handler), LEDGE_CLIMB_FAST *)
Definition LEDGE_IN : list Z := [134218571; 1358; 1356; 1357; 1359]%Z.

Section CLS.
Variables (nbase : positive) (R0 : list (positive * Z)) (kv : list (positive * Z * memory_chunk * sval)).
Variables (rM rO kH kL : positive).
Local Notation ic := (init_cell kv).

Definition sY : sval := ic rM oY Mfloat32.
Definition ym100 : sval := Sbinop Osub sY tf (Sconst (Vsingle c100)) tf.

(* a find_floor height at the entry's pos[1] *)
Definition ffh (pc : list fact) (s : sval) : bool :=
  hasf pc (Fuser kH [s; sY]) || hasf pc (Fuser kL [s; sY]).

(* let_go_of_ledge's pos[1]: y - 100.0f with a find_floor height below it,
   or that height, not below y - 100.0f *)
Definition lgy (pc : list fact) (s : sval) : bool :=
  (sveqb s ym100
   && existsb (fun f => match f with
        | Fbool (Sbinop Olt x t1 d t2) ty true =>
            sveqb d ym100 && is_tf t1 && is_tf t2 && tyeqb ty ti32 && ffh pc x
        | _ => false end) pc)
  || existsb (fun f => match f with
       | Fbool (Sbinop Olt x t1 d t2) ty false =>
           sveqb x s && sveqb d ym100 && is_tf t1 && is_tf t2 && tyeqb ty ti32 && ffh pc s
       | _ => false end) pc.

Definition ledge_ok (g : gst) : bool :=
  let LD := sload nbase R0 kv g in
  match LD rM oMO Mint32, LD rM oA Mint32, LD rM oS Mint16unsigned, LD rM oT Mint16unsigned,
        LD rM oY Mfloat32, LD rM oV Mfloat32, LD rM oF Mfloat32, LD rO oG Mfloat32 with
  | Some (Sptr r0 z0), Some (Sconst (Vint a)), Some ss, Some st, Some sy, Some sv, Some sf, Some sg =>
      Pos.eqb r0 rO && Ptrofs.eq z0 Ptrofs.zero
      && zin (Int.unsigned a) LEDGE_OUT
      && int_sv (ic rM oS Mint16unsigned) ss && int_sv (ic rM oT Mint16unsigned) st
      && sveqb sf (ic rM oF Mfloat32)
      && ((sveqb sy sY && sveqb sg (ic rO oG Mfloat32) && sveqb sv (ic rM oV Mfloat32))
          || (sveqb sy (ic rM oF Mfloat32) && sveqb sg sy && is_pz sv)
          || (sveqb sg (ic rO oG Mfloat32) && is_pz sv && lgy (g_pc g) sy)
          || (sveqb sy sY && sveqb sg sY && sveqb sv (ic rM oV Mfloat32)))
  | _, _, _, _, _, _, _, _ => false
  end.

(* the let-go's shape (for the return value) *)
Definition letgo_ok (g : gst) : bool :=
  let LD := sload nbase R0 kv g in
  match LD rM oA Mint32, LD rM oY Mfloat32, LD rM oF Mfloat32 with
  | Some (Sconst (Vint a)), Some sy, Some sf =>
      Z.eqb (Int.unsigned a) SB_A && sveqb sf (ic rM oF Mfloat32) && lgy (g_pc g) sy
  | _, _, _ => false
  end.
End CLS.

(* ---- constants ---- *)
Lemma B2R_c100 : R2 c100 = 100.
Proof. unfold c100. vm_compute (Float32.of_bits _). unfold Binary.B2R, F2R. simpl. lra. Qed.
Lemma F32_c100 : F32 c100 = true.  Proof. vm_compute. reflexivity. Qed.

(* y - 100.0f, rounded: below y, at most 101 below *)
Lemma sub100 : forall y, F32 y = true -> -11000 <= R2 y <= 16000 ->
  F32 (Float32.sub y c100) = true
  /\ R2 (Float32.sub y c100) <= R2 y /\ R2 y - 101 <= R2 (Float32.sub y c100).
Proof.
  intros y Fy Ry.
  destruct (f32_sub_val y c100 Fy F32_c100) as (A & F).
  { rewrite B2R_c100. eapply Rle_trans; [| apply (bpow_le radix2 15 100); lia]. simpl.
    apply Rabs_le. lra. }
  rewrite B2R_c100 in A. split; [exact F |]. rewrite A. split.
  - rewrite <- (rnd_B2R y) at 2. apply rnd_mono. lra.
  - pose proof (rnd_err (R2 y - 100) 15 ltac:(lia) ltac:(simpl; apply Rabs_le; lra)) as Er.
    assert (Hb : bpow radix2 (15 - 24) <= 1) by (change 1 with (bpow radix2 0); apply bpow_le; lia).
    apply Rabs_le_inv in Er. lra.
Qed.

Lemma hitb_of : forall ge m0, floor_data ge m0 -> HitB (Hit_at ge m0).
Proof. intros ge m0 FD x H. destruct (FD x H) as (A & B & _). exact (conj A B). Qed.

Section LS.
Variables (ge : genv) (R0 : list (positive * Z)) (m0 : mem) (uf : positive -> list (option val) -> Prop)
  (E : senv).
Variables (kv : list (positive * Z * memory_chunk * sval)) (rM kH kL : positive).
Variable pc : list fact.
Hypothesis PC : forall f, In f pc -> fact_holds ge R0 m0 uf E f.
Hypothesis HUH : forall vs, uf kH vs -> exists h yv, vs = [Some (Vsingle h); Some yv]
                                              /\ HPi (Hit_at ge m0) (ycast yv) h.
Hypothesis HUL : forall vs, uf kL vs -> exists h yv, vs = [Some (Vsingle h); Some yv]
                                              /\ HPi (Hit_at ge m0) (ycast yv) h.
Hypothesis FD : floor_data ge m0.

Local Notation den := (SymExec2.den ge m0 E).
Local Notation sY := (sY kv rM).
Local Notation ym100 := (ym100 kv rM).

Lemma den_lt : forall a b x y,
  den a = Some (Vsingle x) -> den b = Some (Vsingle y) ->
  den (Sbinop Olt a tf b tf) = Some (Val.of_bool (Float32.cmp Clt x y)).
Proof. intros a b x y Da Db. cbn [SymExec2.den]. rewrite Da, Db. reflexivity. Qed.

Lemma fbool_lt : forall a b x y bv,
  In (Fbool (Sbinop Olt a tf b tf) ti32 bv) pc ->
  den a = Some (Vsingle x) -> den b = Some (Vsingle y) ->
  Float32.cmp Clt x y = bv.
Proof.
  intros a b x y bv I Da Db. pose proof (PC _ I) as (v & D & B).
  rewrite (den_lt a b x y Da Db) in D. injection D as <-.
  destruct (Float32.cmp Clt x y), bv; try reflexivity; exfalso;
    unfold Val.of_bool, bool_val in B; cbn in B; discriminate B.
Qed.

(* a find_floor height at the entry's y: -11000, or a WMotR floor at most
   y + 80 *)
Lemma ffh_sound : forall x y0, ffh kv rM kH kL pc x = true ->
  den sY = Some (Vsingle y0) -> F32 y0 = true -> -11000 <= R2 y0 <= 16000 ->
  exists h, den x = Some (Vsingle h) /\ F32 h = true /\ -11000 <= R2 h
    /\ (R2 h = -11000 \/ (wmotr_floor (R2 h) /\ R2 h <= R2 y0 + 80)).
Proof.
  intros x y0 H Dy Fy Ry. unfold ffh in H.
  assert (U : exists h yv, den x = Some (Vsingle h) /\ den sY = Some yv /\ HPi (Hit_at ge m0) (ycast yv) h).
  { apply orb_true_iff in H as [H | H];
      pose proof (PC _ (hasf_in _ _ H)) as U; cbn [fact_holds map] in U;
      [destruct (HUH _ U) as (h & yv & E1 & P) | destruct (HUL _ U) as (h & yv & E1 & P)];
      injection E1 as D1 D2; exists h, yv; auto. }
  destruct U as (h & yv & Dh & Dyv & P). rewrite Dy in Dyv. injection Dyv as <-.
  destruct (ff_height_bound _ y0 h (hitb_of ge m0 FD) Fy ltac:(lra) P) as [-> | (Hh & Le)].
  - exists c11000. split; [exact Dh |]. rewrite B2R_c11000.
    split; [exact F32_c11000 |]. split; [lra | left; reflexivity].
  - destruct (FD h Hh) as (Fh & _ & Wh).
    rewrite Rmax_left in Le by lra.
    exists h. split; [exact Dh |]. split; [exact Fh |].
    split; [exact (wmotr_floor_low _ Wh) | right; split; [exact Wh | lra]].
Qed.

(* the let-go's pos[1] *)
Theorem lgy_sound : forall s y0, lgy kv rM kH kL pc s = true ->
  den sY = Some (Vsingle y0) -> F32 y0 = true -> -11000 <= R2 y0 <= 16000 ->
  exists y', den s = Some (Vsingle y') /\ F32 y' = true /\ -11000 <= R2 y'
    /\ R2 y0 - 101 <= R2 y'
    /\ (R2 y' <= R2 y0 \/ R2 y' = -11000 \/ (wmotr_floor (R2 y') /\ R2 y' <= R2 y0 + 241)).
Proof.
  intros s y0 H Dy Fy Ry.
  destruct (sub100 y0 Fy Ry) as (Fs & S1 & S2).
  assert (Dm : den ym100 = Some (Vsingle (Float32.sub y0 c100))).
  { unfold LedgeClass.ym100. cbn [SymExec2.den]. rewrite Dy. reflexivity. }
  unfold lgy in H. apply orb_true_iff in H as [H | H].
  - apply andb_true_iff in H as [Es H]. apply sveqb_eq in Es. subst s.
    apply existsb_exists in H as (f & I & Hm). crush Hm. norm.
    match goal with Hf : ffh _ _ _ _ _ _ = true |- _ =>
      destruct (ffh_sound _ y0 Hf Dy Fy Ry) as (h & Dh & Fh & Lh & _) end.
    pose proof (fbool_lt _ _ h _ true I Dh Dm) as G.
    pose proof (cmp_lt_true _ _ Fh Fs G).
    exists (Float32.sub y0 c100). split; [exact Dm |]. split; [exact Fs |].
    split; [lra |]. split; [exact S2 | left; exact S1].
  - apply existsb_exists in H as (f & I & Hm). crush Hm. norm.
    match goal with Hf : ffh _ _ _ _ _ _ = true |- _ =>
      destruct (ffh_sound _ y0 Hf Dy Fy Ry) as (h & Dh & Fh & Lh & Hc) end.
    pose proof (fbool_lt _ _ h _ false I Dh Dm) as G.
    pose proof (cmp_lt_false _ _ Fh Fs G).
    exists h. split; [exact Dh |]. split; [exact Fh |]. split; [exact Lh |].
    split; [lra |]. right. destruct Hc as [Hc | (W & Hc)]; [left; exact Hc | right; split; [exact W | lra]].
Qed.
End LS.

(* ---- the outcome actions' modes ---- *)
Lemma ledge_out_cap : forall a st tm v, In (Int.unsigned a) LEDGE_OUT -> v <= 43 ->
  launch_cap (mode_of_action a st) tm v.
Proof.
  intros a st tm v H Hv. rewrite <- (Int.repr_unsigned a).
  unfold LEDGE_OUT in H.
  repeat (destruct H as [H | H]; [rewrite <- H;
    first [ replace (mode_of_action _ st) with M_Ground
              by (unfold mode_of_action, roll_prep; vm_compute; reflexivity); exact I
          | replace (mode_of_action _ st) with M_Freefall
              by (unfold mode_of_action, roll_prep; vm_compute; reflexivity); cbn; lra
          | replace (mode_of_action _ st) with M_Air
              by (unfold mode_of_action, roll_prep; vm_compute; reflexivity); cbn; lra ] |]).
  destruct H.
Qed.

Lemma ledge_in_ground : forall a st, (exists z, In z LEDGE_IN /\ a = Int.repr z) ->
  mode_of_action a st = M_Ground.
Proof.
  intros a st (z & Hz & ->). unfold LEDGE_IN in Hz.
  repeat (destruct Hz as [<- | Hz]; [unfold mode_of_action, roll_prep; vm_compute; reflexivity |]).
  destruct Hz.
Qed.

(* the entry's floor refresh is an attach height *)
Lemma fro_attach : forall c, FloorRefreshOK wmotr_floor (R2 (c_posy c)) (R2 (c_floorh c)) ->
  AttachOK wmotr_floor wmotr_pole wmotr_cannon c (R2 (c_floorh c)).
Proof.
  intros c [H | (W & L)].
  - right; right; right; right; right; left. exact H.
  - right; left. exact (conj W L).
Qed.

(* ---- ledge_ok / letgo_ok, at the outcome's memory ---- *)
Section LC2.
Variables (ge : genv) (nbase : positive) (R0 : list (positive * Z)) (gtab : list (ident * positive))
  (kv : list (positive * Z * memory_chunk * sval)) (m0 : mem)
  (uf : positive -> list (option val) -> Prop) (gp : meminj).
Hypothesis gp_old : forall b x, gp b = Some x -> Plt b (Mem.nextblock m0).
Variables (rM rO kH kL : positive).
Hypothesis HUH : forall vs, uf kH vs -> exists h yv, vs = [Some (Vsingle h); Some yv]
                                              /\ HPi (Hit_at ge m0) (ycast yv) h.
Hypothesis HUL : forall vs, uf kL vs -> exists h yv, vs = [Some (Vsingle h); Some yv]
                                              /\ HPi (Hit_at ge m0) (ycast yv) h.
Hypothesis FD : floor_data ge m0.
Variables (E : senv) (m : mem) (g : gst).
Hypothesis MM : MMg ge nbase R0 gtab kv m0 uf gp E m g.
Hypothesis HbM : e_base E rM = Ptrofs.zero.
Local Notation bm := (e_blk E rM).
Local Notation den := (SymExec2.den ge m0 E).
Local Notation LD := (sload nbase R0 kv g).

Lemma lld : forall r o ch s, LD r o ch = Some s -> Mem.load ch m (e_blk E r) (addr E r o) = den s.
Proof.
  intros r o ch s L.
  exact (proj1 (sload_sound ge nbase R0 gtab kv (fun _ => None) (fun _ => false) m0 uf gp gp_old
                  E m g r o ch s MM L)).
Qed.

Lemma lic : forall r o ch, den (init_cell kv r o ch) = Mem.load ch m0 (e_blk E r) (addr E r o).
Proof.
  intros r o ch. destruct MM as (EO & _).
  exact (proj1 (init_cell_den ge nbase R0 gtab kv m0 gp E r o ch EO)).
Qed.

Lemma lAM : forall o, addr E rM o = o.
Proof. intros o. unfold addr. rewrite HbM, Ptrofs.unsigned_zero. reflexivity. Qed.

Lemma lpc : forall f, In f (g_pc g) -> fact_holds ge R0 m0 uf E f.
Proof. intros f Hx. destruct MM as (_ & _ & _ & _ & _ & _ & PC & _). exact (proj2 (PC f Hx)). Qed.

Variable c0 : cells.
Hypothesis RC0 : read_cells bm m0 c0.
Hypothesis Hb0 : budget_ok c0.

Lemma y0_facts : den (LedgeClass.sY kv rM) = Some (Vsingle (c_posy c0))
  /\ F32 (c_posy c0) = true /\ -11000 <= R2 (c_posy c0) <= 16000.
Proof.
  destruct RC0 as (_ & _ & _ & Y0 & _).
  pose proof (budget_ok_y c0 Hb0) as Hy. unfold PHI_YMAX, PHI_K, PHI_A in Hy.
  destruct Hb0 as ((FY & _ & _ & LY & _) & _).
  split; [unfold LedgeClass.sY; rewrite lic, lAM; exact Y0 |].
  split; [exact FY | lra].
Qed.

Theorem letgo_sound : letgo_ok nbase R0 kv rM kH kL g = true ->
  exists y', Mem.load Mfloat32 m bm OFS_POSY = Some (Vsingle y')
    /\ Mem.load Mfloat32 m bm OFS_FLOORH = Mem.load Mfloat32 m0 bm OFS_FLOORH
    /\ Mem.load Mint32 m bm 12 = Some (Vint (Int.repr SB_A))
    /\ R2 (c_posy c0) - 101 <= R2 y'.
Proof.
  intros OK. unfold letgo_ok in OK. cbv zeta in OK.
  repeat match type of OK with
  | context [match ?x with _ => _ end] => let Ex := fresh "Ex" in destruct x eqn:Ex; try discriminate OK
  end.
  subst.
  repeat rewrite andb_true_iff in OK. destruct OK as ((Ea & EF) & LG).
  apply Z.eqb_eq in Ea. apply sveqb_eq in EF. subst.
  destruct y0_facts as (Dy & Fy & Ry).
  destruct (lgy_sound ge R0 m0 uf E kv rM kH kL (g_pc g) lpc HUH HUL FD _ _ LG Dy Fy Ry)
    as (y' & Dy' & _ & _ & Low & _).
  exists y'.
  match goal with H : LD rM oY _ = Some _ |- _ => pose proof (lld _ _ _ _ H) as LY end.
  match goal with H : LD rM oF _ = Some _ |- _ => pose proof (lld _ _ _ _ H) as LF end.
  match goal with H : LD rM oA _ = Some _ |- _ => pose proof (lld _ _ _ _ H) as LA end.
  rewrite lAM, Dy' in LY. rewrite lAM, lic, lAM in LF. rewrite lAM in LA. cbn [SymExec2.den] in LA.
  split; [exact LY |]. split; [exact LF |].
  split; [rewrite <- Ea, Int.repr_unsigned; exact LA | exact Low].
Qed.

Hypothesis Hacn : exists z, In z LEDGE_IN /\ c_action c0 = Int.repr z.
Hypothesis FRO0 : FloorRefreshOK wmotr_floor (R2 (c_posy c0)) (R2 (c_floorh c0)).
(* Mario's object is the walk's region rO *)
Hypothesis HO0 : Mem.load Mint32 m0 bm oMO = Some (Vptr (e_blk E rO) (e_base E rO)).

Lemma gfx0 : Mem.load Mfloat32 m0 (e_blk E rO) (Ptrofs.unsigned (e_base E rO) + oG)
  = Some (Vsingle (c_gfxy c0)).
Proof.
  destruct RC0 as (_ & _ & _ & _ & _ & _ & bo0 & oo0 & LO0 & GY0).
  change Mptr with Mint32 in LO0. change OFS_MARIOOBJ with oMO in LO0.
  rewrite HO0 in LO0. injection LO0 as <- <-. exact GY0.
Qed.

(* the common end: an attach at h, from the outcome's cells *)
Lemma ledge_finish : forall i js jt y v gy h,
  Mem.load Mint32 m bm oA = Some (Vint i) ->
  Mem.load Mint16unsigned m bm oS = Some (Vint js) ->
  Mem.load Mint16unsigned m bm oT = Some (Vint jt) ->
  Mem.load Mfloat32 m bm oY = Some (Vsingle y) ->
  Mem.load Mfloat32 m bm oV = Some (Vsingle v) ->
  Mem.load Mfloat32 m bm oF = Some (Vsingle (c_floorh c0)) ->
  Mem.load Mint32 m bm oMO = Some (Vptr (e_blk E rO) (e_base E rO)) ->
  Mem.load Mfloat32 m (e_blk E rO) (Ptrofs.unsigned (e_base E rO) + oG) = Some (Vsingle gy) ->
  In (Int.unsigned i) LEDGE_OUT ->
  F32 y = true -> F32 v = true -> F32 gy = true ->
  -11000 <= R2 y -> -11000 <= R2 gy -> -75 <= R2 v <= 43 ->
  AttachOK wmotr_floor wmotr_pole wmotr_cannon c0 h -> R2 y <= h ->
  (gy = y \/ gy = c_gfxy c0) ->
  exists c2, read_cells bm m c2 /\ RangedMove wmotr_floor wmotr_pole wmotr_cannon c0 c2.
Proof.
  intros i js jt y v gy h LA LS LT LY LV LF LM LG Hin Fy Fv Fg Ly Lg Rv AO Yh Hg.
  pose proof Hb0 as ((FY0 & FV0 & FG0 & LY0 & LG0 & (FF0 & LF0) & VR0) & _).
  set (c2 := mkCells i js jt y v (c_floorh c0) gy).
  exists c2. split.
  { unfold read_cells. cbn [c2 c_action c_state c_timer c_posy c_vely c_floorh c_gfxy].
    refine (conj LA (conj LS (conj LT (conj LY (conj LV (conj LF _)))))).
    exists (e_blk E rO), (e_base E rO). change Mptr with Mint32. split; [exact LM | exact LG]. }
  split.
  - unfold InRange. cbn [c2 c_posy c_vely c_gfxy c_floorh]. repeat split; try assumption; lra.
  - apply S_attach with (h := h).
    + exact AO.
    + cbn [c2 c_posy]. exact Yh.
    + destruct Hg as [-> | ->]; [left; reflexivity | right].
      split; [reflexivity | unfold mode_of; exact (ledge_in_ground _ _ Hacn)].
    + unfold mode_of. cbn [c2 c_action c_vely]. apply ledge_out_cap; [exact Hin | lra].
    + intros _. cbn [c2 c_floorh]. exact (fro_attach c0 FRO0).
Qed.

Theorem ledge_sound : ledge_ok nbase R0 kv rM rO kH kL g = true ->
  exists c2, read_cells bm m c2 /\ RangedMove wmotr_floor wmotr_pole wmotr_cannon c0 c2.
Proof.
  intros OK. unfold ledge_ok in OK. cbv zeta in OK.
  repeat match type of OK with
  | context [match ?x with _ => _ end] => let Ex := fresh "Ex" in destruct x eqn:Ex; try discriminate OK
  end.
  subst.
  repeat rewrite andb_true_iff in OK.
  destruct OK as ((((((R1 & Z0) & Zin) & IS) & IT) & EF) & SH).
  apply Pos.eqb_eq in R1. subst. apply Ptrofs.same_if_eq in Z0. subst.
  apply sveqb_eq in EF. subst.
  pose proof RC0 as (A0 & S0 & T0 & Y0 & V0 & F0 & _).
  pose proof Hb0 as ((FY0 & FV0 & FG0 & LY0 & LG0 & (FF0 & LF0) & VR0) & _).
  destruct y0_facts as (Dy0 & _ & Ry0).
  assert (DS0 : den (init_cell kv rM oS Mint16unsigned) = Some (Vint (c_state c0)))
    by (rewrite lic, lAM; exact S0).
  assert (DT0 : den (init_cell kv rM oT Mint16unsigned) = Some (Vint (c_timer c0)))
    by (rewrite lic, lAM; exact T0).
  match goal with H : int_sv _ ?s = true, H' : LD rM oS _ = Some ?s |- _ =>
    destruct (int_sv_den ge m0 E _ _ DS0 s H) as (js & Ds); pose proof (lld _ _ _ _ H') as LS end.
  match goal with H : int_sv _ ?s = true, H' : LD rM oT _ = Some ?s |- _ =>
    destruct (int_sv_den ge m0 E _ _ DT0 s H) as (jt & Dt); pose proof (lld _ _ _ _ H') as LT end.
  rewrite lAM, Ds in LS. rewrite lAM, Dt in LT.
  match goal with H' : LD rM oF _ = Some _ |- _ => pose proof (lld _ _ _ _ H') as LF end.
  rewrite lAM, lic, lAM in LF. change OFS_FLOORH with oF in F0. rewrite F0 in LF.
  match goal with H' : LD rM oA _ = Some _ |- _ => pose proof (lld _ _ _ _ H') as LA end.
  rewrite lAM in LA. cbn [SymExec2.den] in LA.
  match goal with H' : LD rM oMO _ = Some _ |- _ => pose proof (lld _ _ _ _ H') as LM end.
  rewrite lAM in LM. cbn [SymExec2.den] in LM. rewrite Ptrofs.add_zero in LM.
  match goal with H' : LD rM oY _ = Some _ |- _ => pose proof (lld _ _ _ _ H') as LY end.
  match goal with H' : LD rM oV _ = Some _ |- _ => pose proof (lld _ _ _ _ H') as LV end.
  match goal with H' : LD rO oG _ = Some _ |- _ => pose proof (lld _ _ _ _ H') as LG end.
  rewrite lAM in LY, LV. unfold addr in LG.
  assert (Hin : In (Int.unsigned i) LEDGE_OUT) by exact (zin_in _ _ Zin).
  assert (MG0 : mode_of c0 = M_Ground) by (unfold mode_of; exact (ledge_in_ground _ _ Hacn)).
  pose proof gfx0 as G0.
  apply orb_true_iff in SH as [SH | SH4]; [apply orb_true_iff in SH as [SH | SH]; [apply orb_true_iff in SH as [SH | SH] |] |].
  - (* switch: pos[1], gfx.pos[1], vel[1] kept; attach at h = pos[1] (grounded) *)
    repeat rewrite andb_true_iff in SH. destruct SH as ((Ey & Eg) & Ev).
    apply sveqb_eq in Ey, Eg, Ev. subst.
    rewrite Dy0 in LY. rewrite lic in LG. unfold addr in LG. rewrite G0 in LG.
    rewrite lic, lAM in LV. change OFS_VELY with oV in V0. rewrite V0 in LV.
    apply (ledge_finish i js jt (c_posy c0) (c_vely c0) (c_gfxy c0) (R2 (c_posy c0))
             LA LS LT LY LV LF LM LG Hin FY0 FV0 FG0 LY0 LG0 VR0); [| lra | right; reflexivity].
    left. split; [exact MG0 | lra].
  - (* snap: pos[1] = gfx.pos[1] = floorHeight, vel[1] = 0; attach at h = floorHeight *)
    repeat rewrite andb_true_iff in SH. destruct SH as ((Ey & Eg) & Pz).
    apply sveqb_eq in Ey, Eg. subst.
    destruct (is_pz_sound _ Pz) as (z & -> & Fz & Rz). cbn [SymExec2.den] in LV.
    rewrite lic, lAM, F0 in LY. rewrite lic, lAM, F0 in LG.
    apply (ledge_finish i js jt (c_floorh c0) z (c_floorh c0) (R2 (c_floorh c0))
             LA LS LT LY LV LF LM LG Hin FF0 Fz FF0 LF0 LF0 ltac:(lra) (fro_attach c0 FRO0)
             ltac:(lra) (or_introl eq_refl)).
  - (* let go: gfx kept, vel[1] = 0, pos[1] from lgy *)
    repeat rewrite andb_true_iff in SH. destruct SH as ((Eg & Pz) & LGY).
    apply sveqb_eq in Eg. subst.
    destruct (is_pz_sound _ Pz) as (z & -> & Fz & Rz). cbn [SymExec2.den] in LV.
    rewrite lic in LG. unfold addr in LG. rewrite G0 in LG.
    destruct (lgy_sound ge R0 m0 uf E kv rM kH kL (g_pc g) lpc HUH HUL FD _ _ LGY Dy0 FY0 Ry0)
      as (y' & Dy' & Fy' & Ly' & _ & Hc).
    rewrite Dy' in LY.
    destruct Hc as [Hc | [Hc | (W & Hc)]].
    + apply (ledge_finish i js jt y' z (c_gfxy c0) (R2 (c_posy c0))
               LA LS LT LY LV LF LM LG Hin Fy' Fz FG0 Ly' LG0 ltac:(lra)); [| exact Hc | right; reflexivity].
      left. split; [exact MG0 | lra].
    + apply (ledge_finish i js jt y' z (c_gfxy c0) (R2 y')
               LA LS LT LY LV LF LM LG Hin Fy' Fz FG0 Ly' LG0 ltac:(lra)); [| lra | right; reflexivity].
      right; right; right; right; right; left. exact Hc.
    + apply (ledge_finish i js jt y' z (c_gfxy c0) (R2 y')
               LA LS LT LY LV LF LM LG Hin Fy' Fz FG0 Ly' LG0 ltac:(lra)); [| lra | right; reflexivity].
      right; left. split; [exact W | exact Hc].
  - (* climb_up_ledge: pos[1] kept, gfx.pos := pos, vel[1] kept; attach at
       h = pos[1] (grounded) *)
    repeat rewrite andb_true_iff in SH4. destruct SH4 as ((Ey & Eg) & Ev).
    apply sveqb_eq in Ey, Eg, Ev. subst.
    rewrite Dy0 in LY, LG.
    rewrite lic, lAM in LV. change OFS_VELY with oV in V0. rewrite V0 in LV.
    apply (ledge_finish i js jt (c_posy c0) (c_vely c0) (c_posy c0) (R2 (c_posy c0))
             LA LS LT LY LV LF LM LG Hin FY0 FV0 FY0 LY0 LY0 VR0); [| lra | left; reflexivity].
    left. split; [exact MG0 | lra].
Qed.
End LC2.

