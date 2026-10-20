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
From SM64.Proofs Require Import Interp.SymExec2 HeightInvariant HeightMoveCatalog WMotRLevel HeightFloatSteps.
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

(* the path fact "!(v1 > 0.0f)" *)
Definition velnp (v1 : sval) (f : fact) : bool :=
  match f with
  | Fbool (Sbinop Ogt a t1 (Sconst (Vsingle z)) t2) ty false =>
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

(* an air action whose mode does not depend on its state: plain M_Air *)
Definition air_indep (a : int) : bool :=
  is_air a && negb (Int.eq a ACT_FREEFALL) && negb (Int.eq a ACT_BUTT_SLIDE_AIR)
  && negb (Int.eq a ACT_SLIDE_KICK) && negb (Int.eq a ACT_GROUND_POUND).

Lemma air_indep_mode : forall a s, air_indep a = true -> mode_of_action a s = M_Air.
Proof.
  intros a s H. unfold air_indep in H. repeat rewrite andb_true_iff in H.
  destruct H as [[[[Ha Hf] Hb] Hk] Hg]. apply negb_true_iff in Hf, Hb, Hk, Hg.
  unfold mode_of_action. rewrite Hf, Hb, Hk, Hg, Ha. reflexivity.
Qed.

(* a term that denotes an int whenever its default does: the default, an int
   constant, an int-to-int cast, or an int + int *)
Definition int_cast (t1 t2 : type) : bool :=
  match classify_cast t1 t2 with
  | cast_case_i2i _ _ => true
  | cast_case_pointer => negb Archi.ptr64
  | _ => false
  end.
Definition is_tint (t : type) : bool := match t with Tint _ _ _ => true | _ => false end.
Fixpoint int_sv (d : sval) (s : sval) : bool :=
  sveqb s d ||
  match s with
  | Sconst (Vint _) => true
  | Scast a t1 t2 => int_cast t1 t2 && int_sv d a
  | Sbinop Cop.Oadd a t1 b t2 => is_tint t1 && is_tint t2 && int_sv d a && int_sv d b
  | _ => false
  end.

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

(* the walk's known entry action (from kv) is freefall: only freefall's
   entry may switch to GROUND_POUND *)
Definition entry_ff : bool :=
  match ci (ic rM oA Mint32) with Some a0 => Int.eq a0 ACT_FREEFALL | None => false end.

(* the walk's known entry action is not ground pound (an entry switch keeps
   vel[1], which a ground-pound fall cannot hand to a plain air action) *)
Definition entry_nogp : bool :=
  match ci (ic rM oA Mint32) with Some a0 => negb (Int.eq a0 ACT_GROUND_POUND) | None => false end.

Definition entry_sw (md : mode) (a s t : int) : bool :=
  mode_eqb md M_Air
  || (entry_ff && Int.eq a ACT_GROUND_POUND && Int.eq s Int.zero && Int.eq t Int.zero).

(* a constant action of the knockback family / freefall *)
Definition is_ae (a1 : sval) : bool := match ci a1 with Some a => air_entry a | None => false end.
(* ... or ground pound *)
Definition is_pe (a1 : sval) : bool := match ci a1 with Some a => fro_entry a | None => false end.

Definition step_ok (pc : list fact) (sa ss st sy sv sf sg : sval) (args : list sval) : bool :=
  match args with
  | _ :: Sconst (Vint cl) :: _ :: rest =>
      lsveqb (firstn 7 rest) (map (ic_of kv) (pkeys rM rO)) &&
      match skipn 7 rest with
      | [a1; s1; t1; y1; v1; f1; g1] =>
          sveqb sy y1 && sveqb sf f1 && sveqb sg g1 &&
          ( (* stay *)
            (Int.eq cl Int.zero && sveqb sa a1 && sveqb ss s1 && sveqb st t1 && sveqb sv v1)
          || (* wall switch (from ground pound: vel[1] ends <= 0) *)
            (Int.eq cl Int.zero && is_pe a1
             && consts_ok sa ss st (fun md _ _ _ => mode_eqb md M_Air)
             && ((sveqb sv v1 && (is_ae a1 || existsb (velnp v1) pc))
                 || (sveqb sv (Sconst (Vsingle Float32.zero)) && existsb (velpos v1) pc)))
          || (* wall hit that keeps the action: vel[1] zeroed when it was > 0 *)
            (Int.eq cl Int.zero && is_ae a1 && sveqb sa a1 && sveqb ss s1 && sveqb st t1
             && sveqb sv (Sconst (Vsingle Float32.zero)) && existsb (velpos v1) pc)
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
                && entry_nogp && consts_ok sa ss st entry_sw
      | Some args => step_ok (g_pc g) sa ss st sy sv sf sg args
      end
  | _, _, _, _, _, _, _, _ => false
  end.

(* act_air_hit_wall (no air step): height, floor and gfx kept, a plain air
   action, vel[1] kept or zeroed when it was > 0, state and timer ints *)
Definition ahw_ok (g : gst) : bool :=
  match LD g rM oMO Mint32, LD g rM oA Mint32, LD g rM oS Mint16unsigned, LD g rM oT Mint16unsigned,
        LD g rM oY Mfloat32, LD g rM oV Mfloat32, LD g rM oF Mfloat32, LD g rO oG Mfloat32 with
  | Some (Sptr r0 z0), Some sa, Some ss, Some st, Some sy, Some sv, Some sf, Some sg =>
      Pos.eqb r0 rO && Ptrofs.eq z0 Ptrofs.zero &&
      match kmargs kM (g_pc g) with
      | None => sveqb sy (ic rM oY Mfloat32) && sveqb sf (ic rM oF Mfloat32)
                && sveqb sg (ic rO oG Mfloat32)
                && (sveqb sv (ic rM oV Mfloat32)
                    || (sveqb sv (Sconst (Vsingle Float32.zero))
                        && existsb (velpos (ic rM oV Mfloat32)) (g_pc g)))
                && match ci sa with Some a => air_indep a | None => false end
                && int_sv (ic rM oS Mint16unsigned) ss && int_sv (ic rM oT Mint16unsigned) st
      | Some _ => false
      end
  | _, _, _, _, _, _, _, _ => false
  end.

(* ---- act_ground_pound ------------------------------------------------- *)
Definition tu16 : type := Tint I16 Unsigned noattr.
Definition ts16 : type := Tint I16 Signed noattr.
Definition tyeqb (a b : type) : bool := if type_eq a b then true else false.
Definition has_fact (pc : list fact) (f : fact) : bool :=
  existsb (fun x => if fact_eq x f then true else false) pc.

(* the path facts "actionState == 0" (b) and "actionTimer < 10" *)
Definition f_st0 (b : bool) : fact :=
  Fbool (Sbinop Cop.Oeq (ic rM oS Mint16unsigned) tu16 (Sconst (Vint Int.zero)) ti32) ti32 b.
Definition f_lt10 : fact :=
  Fbool (Sbinop Cop.Olt (ic rM oT Mint16unsigned) tu16 (Sconst (Vint (Int.repr 10))) ti32) ti32 true.
(* m->actionTimer++ *)
Definition t_tick : sval :=
  Scast (Sbinop Cop.Oadd (ic rM oT Mint16unsigned) tu16 (Sconst (Vint Int.one)) ti32) ti32 tu16.
(* m->pos[1] += 20 - 2 * m->actionTimer *)
Definition t_rise : sval :=
  Sbinop Cop.Oadd (ic rM oY Mfloat32) tf
    (Scast (Sbinop Cop.Osub (Sconst (Vint (Int.repr 20))) ti32
              (Sbinop Cop.Omul (Sconst (Vint (Int.repr 2))) ti32 (ic rM oT Mint16unsigned) tu16) ti32)
           ti32 tf) tf.
(* the path fact "!(++actionTimer >= curAnim->loopEnd + 4)": the windup goes on *)
Definition lend_fact (x : sval) : fact :=
  Fbool (Sbinop Cop.Oge t_tick tu16
           (Sbinop Cop.Oadd (Sldres Mint16signed x) ts16 (Sconst (Vint (Int.repr 4))) ti32) ti32) ti32 false.
Definition get_lend (f : fact) : option sval :=
  match f with Fbool (Sbinop _ _ _ (Sbinop _ (Sldres _ x) _ _ _) _) _ _ => Some x | _ => None end.
Definition is_lend (f : fact) : bool :=
  match get_lend f with
  | Some x => if fact_eq f (lend_fact x) then true else false
  | None => false
  end.
Definition nz_const (s : sval) : bool := match ci s with Some k => negb (Int.eq k Int.zero) | None => false end.

(* vel[1] = -50.0f *)
Definition fm50 : float32 := Float32.of_bits (Int.repr 3259498496).   (* 0xC2480000 *)

(* act_ground_pound state 0 (no air step): the windup rise (S_gp_windup)
   or none (S_gp_hold) *)
Definition gpw_ok (g : gst) : bool :=
  match LD g rM oMO Mint32, LD g rM oA Mint32, LD g rM oS Mint16unsigned, LD g rM oT Mint16unsigned,
        LD g rM oY Mfloat32, LD g rM oV Mfloat32, LD g rM oF Mfloat32, LD g rO oG Mfloat32 with
  | Some (Sptr r0 z0), Some sa, Some ss, Some st, Some sy, Some sv, Some sf, Some sg =>
      Pos.eqb r0 rO && Ptrofs.eq z0 Ptrofs.zero &&
      match kmargs kM (g_pc g) with
      | Some _ => false
      | None =>
          sveqb (ic rM oA Mint32) (Sconst (Vint ACT_GROUND_POUND))
          && sveqb sa (Sconst (Vint ACT_GROUND_POUND)) && int_sv (ic rM oS Mint16unsigned) ss
          && sveqb st t_tick && sveqb sv (Sconst (Vsingle fm50)) && sveqb sf (ic rM oF Mfloat32)
          && has_fact (g_pc g) (f_st0 true)
          && ((has_fact (g_pc g) f_lt10 && sveqb sy t_rise && sveqb sg t_rise)
              || (sveqb sy (ic rM oY Mfloat32) && sveqb sg (ic rO oG Mfloat32)
                  && (has_fact (g_pc g) f_lt10 || existsb is_lend (g_pc g) || nz_const ss)))
      end
  | _, _, _, _, _, _, _, _ => false
  end.

(* each outcome of act_ground_pound: past the windup (the step's entry is a
   ground-pound fall, state <> 0) an ff_ok outcome, else the windup *)
Definition gp_ok (g : gst) : bool :=
  (sveqb (ic rM oA Mint32) (Sconst (Vint ACT_GROUND_POUND)) && has_fact (g_pc g) (f_st0 false)
   && ff_ok g)
  || gpw_ok g.
End CLASS.

(* the Cop steps of those terms *)
Lemma cop_eq_i : forall (ge : genv) s k m,
  sem_binary_operation ge Cop.Oeq (Vint s) tu16 (Vint k) ti32 m = Some (Val.of_bool (Int.eq s k)).
Proof. reflexivity. Qed.
Lemma cop_lt_i : forall (ge : genv) s k m,
  sem_binary_operation ge Cop.Olt (Vint s) tu16 (Vint k) ti32 m = Some (Val.of_bool (Int.lt s k)).
Proof. reflexivity. Qed.
Lemma cop_ge_i : forall (ge : genv) s k m,
  sem_binary_operation ge Cop.Oge (Vint s) tu16 (Vint k) ti32 m = Some (Val.of_bool (negb (Int.lt s k))).
Proof. reflexivity. Qed.
Lemma cop_add_u16 : forall (ge : genv) s k m,
  sem_binary_operation ge Cop.Oadd (Vint s) tu16 (Vint k) ti32 m = Some (Vint (Int.add s k)).
Proof. reflexivity. Qed.
Lemma cop_add_s16 : forall (ge : genv) s k m,
  sem_binary_operation ge Cop.Oadd (Vint s) ts16 (Vint k) ti32 m = Some (Vint (Int.add s k)).
Proof. reflexivity. Qed.
Lemma cop_mul_i : forall (ge : genv) a t m,
  sem_binary_operation ge Cop.Omul (Vint a) ti32 (Vint t) tu16 m = Some (Vint (Int.mul a t)).
Proof. reflexivity. Qed.
Lemma cop_sub_i : forall (ge : genv) a b m,
  sem_binary_operation ge Cop.Osub (Vint a) ti32 (Vint b) ti32 m = Some (Vint (Int.sub a b)).
Proof. reflexivity. Qed.
Lemma cop_add_f : forall (ge : genv) a b m,
  sem_binary_operation ge Cop.Oadd (Vsingle a) tf (Vsingle b) tf m = Some (Vsingle (Float32.add a b)).
Proof. reflexivity. Qed.
Lemma cast_u16 : forall x m, sem_cast (Vint x) ti32 tu16 m = Some (Vint (Int.zero_ext 16 x)).
Proof. reflexivity. Qed.
Lemma cast_i2f : forall n m, sem_cast (Vint n) ti32 tf m = Some (Vsingle (Float32.of_int n)).
Proof. reflexivity. Qed.

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

Lemma cgt_false_np : forall v, F32 v = true -> Float32.cmp Cgt v Float32.zero = false -> R2 v <= 0.
Proof.
  intros v Fv H. unfold Float32.cmp, Float32.compare in H.
  rewrite Binary.Bcompare_correct in H by first [exact Fv | reflexivity].
  destruct (Rcompare_spec (R2 v) (R2 Float32.zero)) as [L | L | L]; simpl in H; try discriminate;
    replace (R2 Float32.zero) with 0 in L by reflexivity; lra.
Qed.

Local Opaque Float32.cmp Float32.compare.

Lemma add_int_int : forall (ge : genv) i j sz1 sg1 a1 sz2 sg2 a2 m,
  exists k, sem_binary_operation ge Cop.Oadd (Vint i) (Tint sz1 sg1 a1) (Vint j) (Tint sz2 sg2 a2) m
            = Some (Vint k).
Proof. intros. destruct sz1, sg1, sz2, sg2; cbn; eexists; reflexivity. Qed.

Lemma int_sv_den : forall ge m0 E d i, SymExec2.den ge m0 E d = Some (Vint i) ->
  forall s, int_sv d s = true -> exists j, SymExec2.den ge m0 E s = Some (Vint j).
Proof.
  intros ge m0 E d i Hd s. induction s; intros H; cbn [int_sv] in H;
    apply orb_true_iff in H as [H | H];
    try (apply sveqb_eq in H; subst; exists i; exact Hd); try discriminate H.
  - destruct v; try discriminate H. exists i0. reflexivity.
  - destruct op; try discriminate H. repeat rewrite andb_true_iff in H.
    destruct H as [[[T1 T2] H1] H2].
    destruct (IHs1 H1) as (j1 & D1). destruct (IHs2 H2) as (j2 & D2).
    destruct t1; try discriminate T1. destruct t2; try discriminate T2.
    cbn [SymExec2.den]. rewrite D1, D2.
    exact (add_int_int ge j1 j2 i0 s a i1 s0 a0 m0).
  - apply andb_true_iff in H as [C H1]. destruct (IHs H1) as (j & D).
    cbn [SymExec2.den]. rewrite D. unfold sem_cast.
    unfold int_cast in C. destruct (classify_cast t1 t2); try discriminate C.
    + destruct Archi.ptr64; [discriminate C |]. exists j. reflexivity.
    + eexists. reflexivity.
Qed.


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
Hypothesis Hact : pas_entry (c_action c0) (state_of c0) = true.
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

Lemma velnp_sound : forall v1 x f, In f (g_pc g) -> velnp v1 f = true ->
  den v1 = Some (Vsingle x) -> F32 x = true -> R2 x <= 0.
Proof.
  intros v1 x f I H D Fx.
  destruct f as [c ty b | | |]; try discriminate H.
  destruct c as [| | | | | | | [] a t1 [[]| | | | | | | | |] t2 | |]; try discriminate H.
  destruct b; [discriminate H |].
  cbn [velnp] in H. repeat rewrite andb_true_iff in H.
  destruct H as [[[[Ea T1] T2] Z] Ty].
  apply sveqb_eq in Ea. subst a. apply is_tf_eq in T1. apply is_tf_eq in T2. subst t1 t2.
  destruct (Float32.eq_dec f Float32.zero) as [-> |]; [| discriminate Z].
  destruct (type_eq ty ti32) as [-> |]; [| discriminate Ty].
  destruct MM as (_ & _ & _ & _ & _ & _ & PC & _).
  destruct (PC _ I) as [_ (w & Dw & Bw)].
  cbn [SymExec2.den] in Dw. rewrite D in Dw. cbn in Dw. injection Dw as <-.
  destruct (Float32.cmp Cgt x Float32.zero) eqn:C; [cbn in Bw; discriminate Bw |].
  exact (cgt_false_np x Fx C).
Qed.

Local Notation MC := (MoveChain wmotr_floor wmotr_pole wmotr_cannon).
Local Notation RMv := (RangedMove wmotr_floor wmotr_pole wmotr_cannon).

Lemma Inrange_of : forall c c1, RM' c c1 -> InRange c1.
Proof. intros c c1 [H _]. exact H. Qed.

(* an outcome that stays in freefall is a floor refresh again *)
Definition fro_ff (c : cells) : Prop :=
  fro_entry (c_action c) = true -> FloorRefreshOK wmotr_floor (R2 (c_posy c)) (R2 (c_floorh c)).

Lemma not_ae_ground : forall a s, mode_of_action a s = M_Ground -> fro_entry a = true -> False.
Proof. intros a s H A. exact (fro_entry_ground a s A H). Qed.

Lemma is_ae_sound : forall a1 x, is_ae a1 = true -> den a1 = Some (Vint x) -> air_entry x = true.
Proof.
  intros a1 x H D. unfold is_ae in H. destruct (ci a1) as [a|] eqn:C; [| discriminate H].
  apply ci_some in C. subst a1. cbn [SymExec2.den] in D. injection D as <-. exact H.
Qed.

Lemma is_pe_sound : forall a1 x, is_pe a1 = true -> den a1 = Some (Vint x) -> fro_entry x = true.
Proof.
  intros a1 x H D. unfold is_pe in H. destruct (ci a1) as [a|] eqn:C; [| discriminate H].
  apply ci_some in C. subst a1. cbn [SymExec2.den] in D. injection D as <-. exact H.
Qed.

Lemma mode_c0 : c_action c0 <> ACT_GROUND_POUND -> mode_of c0 = M_Freefall \/ mode_of c0 = M_Air.
Proof.
  intros N. destruct (pas_entry_mode _ _ Hact) as [X | [X | (X & _)]]; auto. contradiction.
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
    apply orb_true_iff in OK as [OK | OK];
      [apply orb_true_iff in OK as [OK | OK]; [apply orb_true_iff in OK as [OK | OK] |] |].
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
      pose proof (is_pe_sound a1 _ Ea1 DA1) as AE1.
      destruct (consts_ok_inv _ _ _ _ CK) as (a & s & t & -> & -> & -> & Md).
      apply mode_eqb_eq in Md. cbn [SymExec2.den] in MA, MS, MT.
      assert (Hv2 : exists v2, Mem.load Mfloat32 m bm oV = Some (Vsingle v2)
                    /\ ((v2 = c_vely c1 /\ (air_entry (c_action c1) = true \/ R2 (c_vely c1) <= 0))
                        \/ (v2 = Float32.zero /\ 0 < R2 (c_vely c1)))).
      { apply orb_true_iff in VV as [VV | VV].
        - apply andb_true_iff in VV as [VV P]. apply sveqb_eq in VV. subst sv.
          exists (c_vely c1). rewrite MV', DV1. split; [reflexivity |]. left. split; [reflexivity |].
          apply orb_true_iff in P as [P | P]; [left; exact (is_ae_sound a1 _ P DA1) | right].
          apply existsb_exists in P as (f & If' & Pf).
          exact (velnp_sound v1 (c_vely c1) f If' Pf DV1 (proj1 (proj2 IR1))).
        - apply andb_true_iff in VV as [VV P]. apply sveqb_eq in VV. subst sv.
          exists Float32.zero. split; [exact MV' |]. right. split; [reflexivity |].
          apply existsb_exists in P as (f & If' & Pf).
          exact (velpos_sound v1 (c_vely c1) f If' Pf DV1 (proj1 (proj2 IR1))). }
      destruct Hv2 as (v2 & LV & Hv2).
      set (c2 := mkCells a s t (c_posy c1) v2 (c_floorh c1) (c_gfxy c1)).
      exists c2. split; [| split; [| intros _; apply FR1; pose proof (Int.eq_spec cl Int.zero) as X;
                                    rewrite Ec in X; exact X]].
      * exact (mk_read c2 g1 LMO MA MS MT MY LV MF Lg DG1).
      * eapply rt_trans; [apply rt_step; exact RM1 | apply rt_step].
        assert (M1 : mode_of c1 <> M_Ground) by exact (fro_entry_ground _ _ AE1).
        split.
        -- destruct Hv2 as [(-> & _) | (-> & _)];
             [ apply (inrange_same c1 c2 IR1); reflexivity
             | apply (inrange_vel0 c1 c2 IR1); reflexivity ].
        -- apply S_switch; [reflexivity | reflexivity | reflexivity |].
           apply Sw_plain.
           ++ exact M1.
           ++ exact Md.
           ++ cbn [c_vely c2]. destruct Hv2 as [(-> & _) | (-> & P)]; [apply Rle_refl |].
              replace (R2 Float32.zero) with 0 by reflexivity. lra.
           ++ intros N1 N2. cbn [c_vely c2].
              destruct Hv2 as [(-> & [Ae | Np]) | (-> & _)].
              ** exfalso. destruct (air_entry_mode _ (state_of c1) Ae); contradiction.
              ** exact Np.
              ** replace (R2 Float32.zero) with 0 by reflexivity. lra.
    + (* wall hit keeping the action, vel[1] zeroed *)
      repeat rewrite andb_true_iff in OK. destruct OK as [[[[[[Ec Ae] Ea] Es] Et] Ev] P].
      apply sveqb_eq in Ea, Es, Et, Ev. subst sa ss st sv.
      pose proof (is_ae_sound a1 _ Ae DA1) as AE1.
      assert (M1 : mode_of c1 = M_Freefall \/ mode_of c1 = M_Air) by exact (air_entry_mode _ _ AE1).
      assert (P1 : 0 < R2 (c_vely c1)).
      { apply existsb_exists in P as (f & If' & Pf).
        exact (velpos_sound v1 (c_vely c1) f If' Pf DV1 (proj1 (proj2 IR1))). }
      set (c2 := mkCells (c_action c1) (c_state c1) (c_timer c1) (c_posy c1) Float32.zero
                         (c_floorh c1) (c_gfxy c1)).
      exists c2. split; [| split].
      * rewrite DA1 in MA. rewrite DS1 in MS. rewrite DT1 in MT. cbn [SymExec2.den] in MV'.
        exact (mk_read c2 g1 LMO MA MS MT MY MV' MF Lg DG1).
      * eapply rt_trans; [apply rt_step; exact RM1 | apply rt_step].
        split; [apply (inrange_vel0 c1 c2 IR1); reflexivity |].
        apply S_switch; [reflexivity | reflexivity | reflexivity |].
        assert (M2 : mode_of c2 = mode_of c1) by reflexivity.
        assert (V2 : R2 (c_vely c2) <= R2 (c_vely c1))
          by (cbn [c_vely c2]; replace (R2 Float32.zero) with 0 by reflexivity; lra).
        destruct M1 as [M1 | M1].
        -- apply Sw_freefall; [rewrite M2; exact M1 | exact V2 | left; exact M1].
        -- apply Sw_plain; [rewrite M1; discriminate | rewrite M2; exact M1 | exact V2 |].
           intros _ N. exfalso. exact (N M1).
      * intros _. apply FR1. pose proof (Int.eq_spec cl Int.zero) as X. rewrite Ec in X. exact X.
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
      exists c2. split; [| split; [| intros Ea; exfalso; exact (not_ae_ground _ _ Md Ea)]].
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
    repeat rewrite andb_true_iff in OK. destruct OK as [[[[[Ey Ev] Ef] Eg] NG] CK].
    apply sveqb_eq in Ey, Ev, Ef, Eg. subst sy sv sf sg.
    destruct (consts_ok_inv _ _ _ _ CK) as (a & s & t & -> & -> & -> & SW).
    cbn [SymExec2.den] in MA, MS, MT.
    set (c2 := mkCells a s t (c_posy c0) (c_vely c0) (c_floorh c0) (c_gfxy c0)).
    assert (M0' : mode_of c0 = M_Freefall \/ mode_of c0 = M_Air).
    { apply mode_c0. unfold entry_nogp in NG.
      destruct (ci (init_cell kv rM oA Mint32)) as [a0|] eqn:C; [| discriminate NG].
      apply ci_some in C. rewrite C in DA0. cbn [SymExec2.den] in DA0. injection DA0 as <-.
      intros X. rewrite X, Int.eq_true in NG. discriminate NG. }
    exists c2. split; [| split].
    + rewrite DY0 in MY. rewrite DV0 in MV'. rewrite DF0 in MF.
      exact (mk_read c2 _ LMO MA MS MT MY MV' MF Lg DG0).
    + apply rt_step. split; [apply (inrange_same c0 c2 IR0); reflexivity |].
      apply S_switch; [reflexivity | reflexivity | reflexivity |].
      unfold entry_sw in SW. apply orb_true_iff in SW as [SW | SW].
      * apply mode_eqb_eq in SW. apply Sw_plain.
        -- destruct M0' as [X | X]; rewrite X; discriminate.
        -- exact SW.
        -- apply Rle_refl.
        -- intros N1 N2. exfalso. destruct M0'; contradiction.
      * repeat rewrite andb_true_iff in SW. destruct SW as [[[Eff Ea] Es] Et].
        assert (M0 : mode_of c0 = M_Freefall).
        { apply mode_ff_of. unfold entry_ff in Eff.
          destruct (ci (init_cell kv rM oA Mint32)) as [a0|] eqn:C; [| discriminate Eff].
          apply ci_some in C. rewrite C in DA0. cbn [SymExec2.den] in DA0. injection DA0 as <-.
          pose proof (Int.eq_spec a0 ACT_FREEFALL) as X. rewrite Eff in X. exact X. }
        pose proof (Int.eq_spec a ACT_GROUND_POUND) as X. rewrite Ea in X.
        pose proof (Int.eq_spec s Int.zero) as Y. rewrite Es in Y.
        pose proof (Int.eq_spec t Int.zero) as W. rewrite Et in W.
        subst s t. apply Sw_gp; [exact M0 | exact X | reflexivity | reflexivity].
    + intros _. exact FRO.
Qed.

(* act_air_hit_wall's outcomes, from any plain-air start: one S_switch *)
Theorem ahw_sound : mode_of c0 = M_Air -> ahw_ok nbase R0 kv rM rO kM g = true ->
  exists c2, read_cells bm m c2 /\ MC c0 c2 /\ fro_ff c2.
Proof.
  intros M0 OK. unfold ahw_ok in OK.
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
  destruct (kmargs kM (g_pc g)) as [args|]; [discriminate OK |].
  repeat rewrite andb_true_iff in OK. destruct OK as [[[[[[Ey Ef] Eg] VV] Ca] Is] It].
  apply sveqb_eq in Ey, Ef, Eg. subst sy sf sg.
  destruct (ci sa) as [a|] eqn:Ci; [| discriminate Ca]. apply ci_some in Ci. subst sa.
  destruct (int_sv_den ge m0 E _ _ DS0 ss Is) as (s & Ds).
  destruct (int_sv_den ge m0 E _ _ DT0 st It) as (t & Dt).
  rewrite Ds in MS. rewrite Dt in MT. cbn [SymExec2.den] in MA.
  assert (Hv2 : exists v2, Mem.load Mfloat32 m bm oV = Some (Vsingle v2)
                /\ (v2 = c_vely c0 \/ (v2 = Float32.zero /\ 0 < R2 (c_vely c0)))).
  { apply orb_true_iff in VV as [VV | VV].
    - apply sveqb_eq in VV. subst sv. exists (c_vely c0). rewrite MV', DV0. auto.
    - apply andb_true_iff in VV as [VV P]. apply sveqb_eq in VV. subst sv.
      exists Float32.zero. split; [exact MV' |]. right. split; [reflexivity |].
      apply existsb_exists in P as (f & If' & Pf).
      exact (velpos_sound _ (c_vely c0) f If' Pf DV0 (proj1 (proj2 IR0))). }
  destruct Hv2 as (v2 & LV & Hv2).
  set (c2 := mkCells a s t (c_posy c0) v2 (c_floorh c0) (c_gfxy c0)).
  assert (M2 : mode_of c2 = M_Air) by exact (air_indep_mode a _ Ca).
  exists c2. split; [| split].
  - rewrite DY0 in MY. rewrite DF0 in MF.
    exact (mk_read c2 _ LMO MA MS MT MY LV MF Lg DG0).
  - apply rt_step. split.
    + destruct Hv2 as [-> | (-> & _)];
        [ apply (inrange_same c0 c2 IR0); reflexivity
        | apply (inrange_vel0 c0 c2 IR0); reflexivity ].
    + apply S_switch; [reflexivity | reflexivity | reflexivity |].
      apply Sw_plain.
      * rewrite M0. discriminate.
      * exact M2.
      * cbn [c_vely c2]. destruct Hv2 as [-> | (-> & P)]; [apply Rle_refl |].
        replace (R2 Float32.zero) with 0 by reflexivity. lra.
      * intros _ N. exfalso. exact (N M0).
  - intros _. exact FRO.
Qed.

(* ---- act_ground_pound -------------------------------------------------- *)
Lemma fbool_in : forall c ty b, has_fact (g_pc g) (Fbool c ty b) = true ->
  exists w, den c = Some w /\ bool_val w ty m0 = Some b.
Proof.
  intros c ty b H. unfold has_fact in H. apply existsb_exists in H as (f & I & Hf).
  destruct (fact_eq f (Fbool c ty b)) as [-> |]; [| discriminate Hf].
  destruct MM as (_ & _ & _ & _ & _ & _ & PC & _). destruct (PC _ I) as [_ FH]. exact FH.
Qed.

Lemma st0_sound : forall b, has_fact (g_pc g) (f_st0 kv rM b) = true ->
  Int.eq (c_state c0) Int.zero = b.
Proof.
  intros b H. destruct (fbool_in _ _ _ H) as (w & D & B).
  pose proof entry_vals as EV. cbn [map pkeys mkeys app ic_of cvals] in EV.
  injection EV as _ DS0 _ _ _ _ _.
  cbn [SymExec2.den] in D. rewrite DS0 in D. cbv beta iota in D. rewrite cop_eq_i in D.
  injection D as <-.
  destruct (Int.eq (c_state c0) Int.zero); destruct b; cbn in B; first [reflexivity | discriminate B].
Qed.

Lemma lt10_sound : (timer_of c0 <= 32770)%Z -> has_fact (g_pc g) (f_lt10 kv rM) = true ->
  (timer_of c0 < 10)%Z.
Proof.
  intros Ht H. destruct (fbool_in _ _ _ H) as (w & D & B).
  pose proof entry_vals as EV. cbn [map pkeys mkeys app ic_of cvals] in EV.
  injection EV as _ _ DT0 _ _ _ _.
  cbn [SymExec2.den] in D. rewrite DT0 in D. cbv beta iota in D. rewrite cop_lt_i in D.
  injection D as <-.
  unfold timer_of in *.
  destruct (Int.lt (c_timer c0) (Int.repr 10)) eqn:L; cbn in B; [| discriminate B].
  unfold Int.lt in L. destruct (zlt _ _) as [Z1 |]; [| discriminate L].
  rewrite Int.signed_eq_unsigned in Z1 by (change Int.max_signed with 2147483647%Z; lia).
  change (Int.signed (Int.repr 10)) with 10%Z in Z1. exact Z1.
Qed.

Lemma tick_den : (timer_of c0 <= 32770)%Z ->
  exists t', den (t_tick kv rM) = Some (Vint t') /\ Int.unsigned t' = (timer_of c0 + 1)%Z.
Proof.
  intros Ht.
  pose proof entry_vals as EV. cbn [map pkeys mkeys app ic_of cvals] in EV.
  injection EV as _ _ DT0 _ _ _ _.
  unfold t_tick. cbn [SymExec2.den]. rewrite DT0. cbv beta iota. rewrite cop_add_u16.
  cbv beta iota. rewrite cast_u16.
  eexists. split; [reflexivity |].
  unfold timer_of in *. pose proof (Int.unsigned_range (c_timer c0)) as R.
  rewrite Int.zero_ext_mod by (cbn; lia).
  unfold Int.add. rewrite Int.unsigned_one.
  rewrite Int.unsigned_repr by (unfold Int.max_unsigned, Int.modulus; cbn; lia).
  apply Z.mod_small. change (two_p 16) with 65536%Z. lia.
Qed.

Local Transparent Float32.of_int.
Lemma gp_o : forall t, (Int.unsigned t < 10)%Z ->
  F32 (Float32.of_int (Int.sub (Int.repr 20) (Int.mul (Int.repr 2) t))) = true
  /\ R2 (Float32.of_int (Int.sub (Int.repr 20) (Int.mul (Int.repr 2) t))) = IZR (20 - 2 * Int.unsigned t).
Proof.
  intros t Ht. pose proof (Int.unsigned_range t) as R.
  assert (S : Int.signed (Int.sub (Int.repr 20) (Int.mul (Int.repr 2) t)) = (20 - 2 * Int.unsigned t)%Z).
  { unfold Int.sub, Int.mul.
    rewrite (Int.unsigned_repr 20) by (change Int.max_unsigned with 4294967295%Z; lia).
    rewrite (Int.unsigned_repr 2) by (change Int.max_unsigned with 4294967295%Z; lia).
    rewrite (Int.unsigned_repr (2 * Int.unsigned t)) by (change Int.max_unsigned with 4294967295%Z; lia).
    apply Int.signed_repr. change Int.min_signed with (-2147483648)%Z. change Int.max_signed with 2147483647%Z. lia. }
  unfold Float32.of_int. rewrite S.
  destruct (IEEE754_extra.BofZ_exact 24 128 eq_refl eq_refl (20 - 2 * Int.unsigned t)) as (B & Fi & _).
  { assert (H24 : (2 ^ 24 = 16777216)%Z) by reflexivity. rewrite H24. lia. }
  split; [exact Fi | exact B].
Qed.

Lemma rise_den : (timer_of c0 < 10)%Z ->
  exists o, den (t_rise kv rM) = Some (Vsingle (Float32.add (c_posy c0) o))
    /\ F32 o = true /\ R2 o = IZR (20 - 2 * timer_of c0).
Proof.
  intros Ht.
  pose proof entry_vals as EV. cbn [map pkeys mkeys app ic_of cvals] in EV.
  injection EV as _ _ DT0 DY0 _ _ _.
  unfold t_rise. cbn [SymExec2.den]. rewrite DT0, DY0. cbv beta iota. rewrite cop_mul_i.
  cbv beta iota. rewrite cop_sub_i. cbv beta iota. rewrite cast_i2f. cbv beta iota. rewrite cop_add_f.
  exists (Float32.of_int (Int.sub (Int.repr 20) (Int.mul (Int.repr 2) (c_timer c0)))).
  split; [reflexivity |].
  exact (gp_o _ Ht).
Qed.

Lemma lend_sound : forall f t', In f (g_pc g) -> is_lend kv rM f = true ->
  den (t_tick kv rM) = Some (Vint t') -> (Int.unsigned t' <= 32771)%Z -> (Int.unsigned t' <= 32770)%Z.
Proof.
  intros f t' I H Dt Ht.
  unfold is_lend in H. destruct (get_lend f) as [x|]; [| discriminate H].
  destruct (fact_eq f (lend_fact kv rM x)) as [-> |]; [| discriminate H].
  destruct MM as (_ & _ & _ & _ & _ & _ & PC & _).
  destruct (PC _ I) as [_ (w & Dw & Bw)].
  cbn [SymExec2.den] in Dw. rewrite Dt in Dw.
  destruct (SymExec2.den ge m0 E x) as [u|]; [| discriminate Dw].
  destruct u; cbv beta iota in Dw; try discriminate Dw.
  change (Val.load_result Mint16signed (Vint i)) with (Vint (Int.sign_ext 16 i)) in Dw.
  rewrite cop_add_s16 in Dw. cbv beta iota in Dw. rewrite cop_ge_i in Dw. injection Dw as <-.
  set (L := Int.add (Int.sign_ext 16 i) (Int.repr 4)) in *.
  destruct (Int.lt t' L) eqn:Q; cbn in Bw; [| discriminate Bw].
  pose proof (Int.sign_ext_range 16 i ltac:(cbn; lia)) as SR. change (two_p (16 - 1)) with 32768%Z in SR.
  assert (SL : Int.signed L = (Int.signed (Int.sign_ext 16 i) + 4)%Z).
  { unfold L. rewrite Int.add_signed. change (Int.signed (Int.repr 4)) with 4%Z.
    apply Int.signed_repr. change Int.min_signed with (-2147483648)%Z. change Int.max_signed with 2147483647%Z. lia. }
  unfold Int.lt in Q. destruct (zlt _ _) as [Z1 |]; [| discriminate Q].
  rewrite Int.signed_eq_unsigned in Z1 by (change Int.max_signed with 2147483647%Z; lia).
  lia.
Qed.

Lemma fm50_v : F32 fm50 = true /\ R2 fm50 = -50.
Proof. split; [vm_compute; reflexivity |]. unfold fm50. vm_compute (Float32.of_bits _). unfold Binary.B2R, Defs.F2R. simpl. lra. Qed.

Theorem gpw_sound : gpw_ok nbase R0 kv rM rO kM g = true ->
  exists c2, read_cells bm m c2 /\ MC c0 c2 /\ fro_ff c2.
Proof using gp_old MM HbM HO0 RC0 Hb FRO.
  intros OK. unfold gpw_ok in OK.
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
  pose proof Hb as (IR0 & _ & _ & _ & _ & Hgw & _).
  pose proof entry_vals as EV. cbn [map pkeys mkeys app ic_of cvals] in EV.
  injection EV as DA0 DS0 DT0 DY0 DV0 DF0 DG0.
  destruct (kmargs kM (g_pc g)) as [args|]; [discriminate OK |].
  repeat rewrite andb_true_iff in OK. destruct OK as [[[[[[[EA Ea] Is] Et] Ev] Ef] S0] W].
  apply sveqb_eq in EA, Ea, Et, Ev, Ef. subst sa st sv sf.
  rewrite EA in DA0. cbn [SymExec2.den] in DA0. injection DA0 as A0.
  pose proof (st0_sound true S0) as S0'. apply Int.same_if_eq in S0'.
  assert (Hs0 : state_of c0 = 0%Z) by (unfold state_of; rewrite S0'; reflexivity).
  assert (Hm0 : mode_of c0 = M_PoundWindup)
    by (unfold mode_of; rewrite <- A0, mode_of_action_GP_eq, Hs0; reflexivity).
  specialize (Hgw (eq_sym A0) Hs0).
  destruct (tick_den Hgw) as (t' & Dt & Ut).
  destruct (int_sv_den ge m0 E _ _ DS0 ss Is) as (s' & Ds).
  rewrite Ds in MS. rewrite Dt in MT. cbn [SymExec2.den] in MA, MV'. rewrite DF0 in MF.
  destruct fm50_v as (F50 & R50).
  pose proof (y_hi (c0) Hb) as Yhi.
  destruct IR0 as (Fy & Fv & Fg & Hylo & Hglo & Hfl & Hvlo & Hvhi).
  apply orb_true_iff in W as [W | W].
  - (* the rise *)
    repeat rewrite andb_true_iff in W. destruct W as [[L10 Ey] Eg].
    apply sveqb_eq in Ey, Eg. subst sy sg.
    pose proof (lt10_sound Hgw L10) as T10.
    destruct (rise_den T10) as (o & Do & Fo & Ro).
    assert (Ro' : 0 <= R2 o <= 20).
    { rewrite Ro. unfold timer_of in *. pose proof (Int.unsigned_range (c_timer c0)).
      rewrite minus_IZR, mult_IZR. split.
      - assert (IZR (Int.unsigned (c_timer c0)) <= 9) by (apply IZR_le; lia). lra.
      - assert (0 <= IZR (Int.unsigned (c_timer c0))) by (apply IZR_le; lia). lra. }
    destruct (windup_add (c_posy c0) o Fy Fo Ro' (conj Hylo Yhi)) as [Fy' _].
    pose proof (windup_add_ge (c_posy c0) o Fy Fo Ro' (conj Hylo Yhi)) as Yge.
    set (y' := Float32.add (c_posy c0) o) in *.
    rewrite Do in MY.
    set (c2 := mkCells ACT_GROUND_POUND s' t' y' fm50 (c_floorh c0) y').
    exists c2. split; [| split].
    + exact (mk_read c2 _ LMO MA MS MT MY MV' MF Lg Do).
    + apply rt_step. split.
      * unfold InRange; cbn [c_posy c_vely c_gfxy c_floorh c2].
        rewrite R50. repeat split; try assumption; try lra; apply Hfl.
      * apply (S_gp_windup _ _ _ c0 c2 o Hm0 T10 eq_refl Fo).
        -- rewrite Ro. reflexivity.
        -- reflexivity.
        -- exact R50.
        -- unfold timer_of at 1. cbn [c_timer c2]. exact Ut.
        -- reflexivity.
    + intros _. cbn [c_posy c_floorh c2].
      destruct FRO as [Hf | (Hf & Hl)]; [left; exact Hf | right; split; [exact Hf | lra]].
  - (* no rise *)
    repeat rewrite andb_true_iff in W. destruct W as [[Ey Eg] TB].
    apply sveqb_eq in Ey, Eg. subst sy sg.
    rewrite DY0 in MY.
    set (c2 := mkCells ACT_GROUND_POUND s' t' (c_posy c0) fm50 (c_floorh c0) (c_gfxy c0)).
    exists c2. split; [| split].
    + exact (mk_read c2 _ LMO MA MS MT MY MV' MF Lg DG0).
    + apply rt_step. split.
      * unfold InRange; cbn [c_posy c_vely c_gfxy c_floorh c2].
        rewrite R50. repeat split; try assumption; try lra; apply Hfl.
      * apply (S_gp_hold _ _ _ c0 c2 Hm0 eq_refl eq_refl R50).
        -- unfold timer_of at 1. cbn [c_timer c2]. exact Ut.
        -- reflexivity.
        -- intros Hs2. unfold timer_of. cbn [c_timer c2]. rewrite Ut.
           apply orb_true_iff in TB as [TB | TB]; [apply orb_true_iff in TB as [TB | TB] |].
           ++ pose proof (lt10_sound Hgw TB). lia.
           ++ apply existsb_exists in TB as (f & If & Hf).
              pose proof (lend_sound f t' If Hf Dt ltac:(lia)). lia.
           ++ exfalso. unfold nz_const in TB. destruct (ci ss) as [k|] eqn:C; [| discriminate TB].
              apply ci_some in C. subst ss. cbn [SymExec2.den] in Ds. injection Ds as <-.
              unfold state_of in Hs2. cbn [c_state c2] in Hs2.
              assert (Kz : k = Int.zero) by (rewrite <- (Int.repr_unsigned k), Hs2; reflexivity).
              subst k. rewrite Int.eq_true in TB. discriminate TB.
    + intros _. exact FRO.
Qed.
Lemma entry_act : forall a, sveqb (init_cell kv rM oA Mint32) (Sconst (Vint a)) = true -> c_action c0 = a.
Proof.
  intros a H. apply sveqb_eq in H.
  pose proof entry_vals as EV. cbn [map pkeys mkeys app ic_of cvals] in EV.
  injection EV as DA0 _ _ _ _ _ _. rewrite H in DA0. cbn [SymExec2.den] in DA0. injection DA0 as <-.
  reflexivity.
Qed.

End SOUND.

(* every outcome of act_ground_pound that gp_ok accepts is a MoveChain from
   the entry cells (past the windup through ff_sound: its step's entry is a
   ground-pound fall) *)
Theorem gp_sound : forall ge nbase Rz gtab kv m0 uf gp
  (gp_old : forall b x, gp b = Some x -> Plt b (Mem.nextblock m0))
  rM rO kM (HUM : forall vs, uf kM vs -> MV vs) E m g
  (MM : MMg ge nbase Rz gtab kv m0 uf gp E m g) (HbM : e_base E rM = Ptrofs.zero)
  (HO0 : Mem.load Mint32 m0 (e_blk E rM) oMO = Some (Vptr (e_blk E rO) (e_base E rO)))
  c0 (RC0 : read_cells (e_blk E rM) m0 c0) (Hb : budget_ok c0)
  (FRO : FloorRefreshOK wmotr_floor (R2 (c_posy c0)) (R2 (c_floorh c0))),
  gp_ok nbase Rz kv rM rO kM g = true ->
  exists c2, read_cells (e_blk E rM) m c2 /\ MoveChain wmotr_floor wmotr_pole wmotr_cannon c0 c2
    /\ fro_ff c2.
Proof.
  intros. unfold gp_ok in H. apply orb_true_iff in H as [H | H].
  - repeat rewrite andb_true_iff in H. destruct H as [[EA S1] OK].
    assert (A0 : c_action c0 = ACT_GROUND_POUND) by (eapply entry_act; eassumption).
    assert (S0 : Int.eq (c_state c0) Int.zero = false) by (eapply st0_sound; eassumption).
    assert (Hact : pas_entry (c_action c0) (state_of c0) = true).
    { unfold pas_entry. rewrite A0. apply orb_true_iff. right.
      rewrite Int.eq_true. cbn [andb]. apply negb_true_iff. apply Z.eqb_neq. unfold state_of.
      intros Z. rewrite <- (Int.repr_unsigned (c_state c0)), Z in S0. discriminate S0. }
    exact (ff_sound ge nbase Rz gtab kv m0 uf gp gp_old rM rO kM HUM E m g MM HbM HO0 c0 RC0 Hact Hb FRO OK).
  - exact (gpw_sound ge nbase Rz gtab kv m0 uf gp gp_old rM rO kM E m g MM HbM HO0 c0 RC0 Hb FRO H).
Qed.
