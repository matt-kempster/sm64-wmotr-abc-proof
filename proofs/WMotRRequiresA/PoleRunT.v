(* ====================================================================== *)
(* PoleRunT (GOAL 2): the pole handlers walked with Mario's REAL           *)
(* animation data (2026-10-23).                                            *)
(*                                                                        *)
(* PoleRun's configuration, with set_mario_animation / _with_accel walked *)
(* INLINE (no contract): load_patchable_table reads the DMA table          *)
(* (region RTAB: count, srcAddr = gMarioAnims, the pole animations'       *)
(* entries) and dma_read copies gMarioAnims' cells into the buffer        *)
(* (DmaXc.c_dma, from OsDmaFloor.pi_dma_anim_spec, TRUST 0.8(f));          *)
(* return_mario_anim_y_translation is walked once per animation frame     *)
(* (RytXc.c_ryt) and returns a y translation in [-1, 174] (fact kY).       *)
(* The buffer region RBUF is the 0x4000-byte buffer at bufTarget.          *)
(*                                                                        *)
(* A walk starts from one of three animation states (avar):                *)
(*   AU st     nothing known (st: the start holds AnimWorld.anim_st);      *)
(*   AL k      handstand animation k loaded (its cells known);            *)
(*   AR ks     animID is none of ks and currentAddr names none of them.   *)
(* Each outcome passes PoleRun.pk_ok's checks, leaves the table alone     *)
(* (no_reg RTAB), and AnimEnd.anim_end_ok: in a pole action after the     *)
(* grab the animation state is anim_st again.                             *)
(* ====================================================================== *)

From Coq Require Import List ZArith Lia Reals.
From compcert Require Import Coqlib Maps AST Integers Floats Values Memory Events Globalenvs
  Ctypes Cop Clight ClightBigstep.
From SM64.Generated Require mario_step mario mario_actions_airborne mario_actions_automatic memory
  surface_collision level_update game_init graph_node.
From SM64.Proofs Require Import Interp.SymExec2 Interp.LinkGenv MarioModel.LinkedTwelve
  MarioModel.OsDmaFloor MarioModel.MathGeomGated HeightInvariant HeightMoveCatalog WMotRLevel WMotRWorld.
From SM64.Proofs.WMotRRequiresA Require Import FloorHeight FloorExec AirXc AirRun AirMatch SmaXc
  ExtInert FfClass AirStart FfKeepCheck RetOk FfRun AhwRun KbRun WithGe
  PoleXc PoleClass PoleKeep PoleSound FfWorld FpWalk PoleRun AnimData AnimWorld AnimEnd DmaXc RytXc.
Import ListNotations.

Module AUT := mario_actions_automatic.

Definition NBT : positive := 28.
Definition RTAB : positive := 25.   (* the DMA table gMarioAnimsBuf.dmaTable *)
Definition RGA : positive := 26.    (* gMarioAnims *)
Definition RAUC : positive := 27.   (* gAreaUpdateCounter *)
Definition kF : positive := 9.      (* the animation frame within bounds *)
Definition kBUF : positive := 11.   (* the buffer's placement *)
Definition kGA : positive := 12.    (* gMarioAnims' cells *)

(* the start's animation state *)
Inductive avar : Type := AU (st : bool) | AL (k : Z) | AR (ks : list Z).

Definition buf_kv (k : Z) : list (positive * Z * memory_chunk * sval) :=
  map (fun x => let '(rel, ch, v) := x in (RBUF, rel, ch, AnimEnd.bsv RBUF v)) (buf_cells k).
Definition loaded_kv (k : Z) : list (positive * Z * memory_chunk * sval) :=
  [(RO, 56, Mint16signed, Sconst (Vint (Int.repr k))); (RO, 60, Mint32, Sptr RBUF Ptrofs.zero);
   (RO, 72, Mint32, Sconst (Vint Int.zero)); (RLD, 4, Mint32, Sptr RGA (Ptrofs.repr (hs_off k)))]
  ++ buf_kv k.
Definition kF_fact (k : Z) : fact :=
  Fuser kF [Sinit RO 64 Mint16signed; Sconst (Vint (Int.repr (-1))); Sconst (Vint (Int.repr (hs_le k)))].
(* animID != k and currentAddr != k's address, as the walked tests read them *)
Definition nid_true (k : Z) : fact :=
  Fbool (Sbinop Cop.One (Sinit RO 56 Mint16signed) tI16 (Sconst (Vint (Int.repr k))) tI32) tI32 true.
Definition caddr_true (k : Z) : fact :=
  Fbool (Sbinop Cop.One (Sptr RGA (Ptrofs.repr (hs_off k))) tpu8 (Sinit RLD 4 Mint32) tpv) tI32 true.
Definition vfacts (ks : list Z) : list fact := flat_map (fun k => [nid_true k; caddr_true k]) ks.

(* the start holds anim_st: AU true, and every AL / AR start (those are the
   top-of-pole actions', in anim_acts, PoleStartT.avars_LR) *)
Definition av_st (v : avar) : bool := match v with AU st => st | _ => true end.
Definition av_kv (v : avar) : list (positive * Z * memory_chunk * sval) :=
  match v with AL k => loaded_kv k | _ => [] end.
Definition av_pc (v : avar) : list fact :=
  match v with AL k => [kF_fact k] | AR ks => vfacts ks | AU _ => [] end.

Section CFG.
Variable acn : Z.
Variable g : genv.
Variable v : avar.
Definition R0T : list (positive * Z) :=
  map (fun x => if Pos.eqb (fst x) RBUF then (RBUF, BUFSZ) else x) (R0F g)
  ++ [(RTAB, TABSZ); (RU, szs g mario._Object)].
Definition gtabT : list (ident * positive) :=
  gtabP ++ [(game_init._gMarioAnims, RGA); (graph_node._gAreaUpdateCounter, RAUC)].
Definition tab_kv : list (positive * Z * memory_chunk * sval) :=
  (RTAB, 0, Mint32, Sconst (Vint (Int.repr ANIM_COUNT))) :: (RTAB, 4, Mint32, Sptr RGA Ptrofs.zero) ::
  flat_map (fun x => let '(j, o, s) := x in
     [(RTAB, 8 + 8 * j, Mint32, Sconst (Vint (Int.repr o)));
      (RTAB, 12 + 8 * j, Mint32, Sconst (Vint (Int.repr s)))]) anim_ent.
Definition kvT : list (positive * Z * memory_chunk * sval) :=
  kvP acn g ++ [(RLD, 0, Mint32, Sptr RTAB Ptrofs.zero); (RLD, 8, Mint32, Sptr RBUF Ptrofs.zero)]
  ++ tab_kv ++ av_kv v.
Definition xcIT (id : ident) : option xcontract :=
  if Pos.eqb id mario._find_floor then Some (c_ff2 NBT R0T RFI RMISS RCALLS kW kH kS kL (szSP g))
  else if Pos.eqb id mario._find_ceil then Some (c_fc2 NBT R0T RCALLS kW kC (szSP g))
  else air_xc NBT R0T RFI RMISS RCALLS kW kH kS (szSP g) id.
Definition xcT (id : ident) : option xcontract :=
  match xcIT id with
  | Some k => Some k
  | None =>
    if Pos.eqb id memory._dma_read then Some (c_dma NBT R0T gtabT RBUF RIOM RMQ RRM RGA kBUF kGA ga_cells) else
    if Pos.eqb id mario._return_mario_anim_y_translation then
      Some (c_ryt g NBT R0T gtabT kvT jkeys 3000 RO kF kYp) else
    if Pos.eqb id mario._is_anim_at_end then Some xc_fresh else
    if Pos.eqb id mario._is_anim_past_frame then Some xc_fresh else
    if Pos.eqb id AUT._play_sound then Some xc_fresh else
    if Pos.eqb id AUT._set_sound_moving_speed then Some xc_fresh else None
  end.
Definition pc0T : list fact :=
  [Fuser kW (wargs R0T); Fbits (Sinit RM 2 Mint16unsigned) (Int.repr 2178);
   Fworld (Sinit RM (AirRun.fo g mario._MarioState mario._area) Mint32) (szs g mario._Area);
   Fworld (Sptr RSIN Ptrofs.zero) Ptrofs.modulus;
   Fworld (Sptr RAR Ptrofs.zero) 4;
   Fworld (Sptr RLV Ptrofs.zero) 2;
   Fuser kP [init_cell (kvP acn g) RO POLEPOS_OFF Mfloat32];
   Fworld (Sinit RM FFW_CTL Mint32) SZ_CTL;
   Fworld (Sptr RAUC Ptrofs.zero) 2;
   Fworld (Sptr RGA Ptrofs.zero) Ptrofs.modulus;
   Fuser kBUF [Sptr RBUF Ptrofs.zero];
   Fuser kGA [Sptr RGA Ptrofs.zero]]
  ++ av_pc v.
Definition g0T : gst := mkg nil pc0T NBT nil nil.

(* the consumer facts' meaning *)
Definition ufT (m0 : mem) (gp : meminj) : positive -> list (option val) -> Prop :=
  fun k vs =>
    if Pos.eqb k kW then Wff g m0 gp (szs g mario._Surface) vs
    else if Pos.eqb k kS then surf_on m0 vs
    else if Pos.eqb k kH then
      match vs with
      | [Some (Vsingle h); Some yv] => HPi (Hit_at g m0) (ycast yv) h /\ Hit_at g m0 h
      | _ => False
      end
    else if Pos.eqb k kL then
      match vs with
      | [Some (Vsingle h); Some yv] => HPi (Hit_at g m0) (ycast yv) h
      | _ => False
      end
    else if Pos.eqb k kC then
      match vs with
      | [Some (Vsingle h); Some yv] => ceil_ok yv h
      | _ => False
      end
    else if Pos.eqb k kP then
      match vs with
      | [Some (Vsingle p)] => F32 p = true /\ (-1000 <= R2 p)%R
      | _ => False
      end
    else if Pos.eqb k kF then
      match vs with
      | [x; Some (Vint lo); Some (Vint hi)] =>
          exists i, x = Some (Vint i) /\ (Int.signed lo <= Int.signed i <= Int.signed hi)%Z
      | _ => False
      end
    else if Pos.eqb k kYp then
      match vs with
      | [Some (Vint y)] => (-1 <= Int.signed y <= 174)%Z
      | _ => False
      end
    else if Pos.eqb k kBUF then
      exists b o, vs = [Some (Vptr b o)]
        /\ (forall id b', Genv.find_symbol g id = Some b' -> b' <> b)
        /\ Mem.range_perm m0 b (Ptrofs.unsigned o) (Ptrofs.unsigned o + BUFSZ) Cur Readable
        /\ Z.modulo (Ptrofs.unsigned o) 4 = 0 /\ Ptrofs.unsigned o + BUFSZ < Ptrofs.modulus
    else if Pos.eqb k kGA then
      exists b, vs = [Some (Vptr b Ptrofs.zero)]
        /\ forall o ch z, In (o, ch, z) ga_cells -> Mem.load ch m0 b o = Some (Vint (Int.repr z))
    else False.

(* each outcome: PoleRun's checks, the table untouched, the animation state *)
Definition pk_okT (c : cpath) : bool :=
  pole_ok NBT R0T kvT RM RO RU kP kC kH kL (fst c)
  && fkp_ok NBT R0T kvT RM RO RLD kS clokF (fst c) && no_reg RU (fst c) && no_reg RTAB (fst c)
  && ret_ok NBT R0T kvT RM c
  && anim_end_ok NBT R0T kvT RM RO RLD RBUF RGA kF (av_st v) (fst c).
End CFG.

Definition pole_walkT (acn : Z) (v : avar) (f : function) : bool :=
  with_ge ge12 false (fun g =>
    match sx_call g NBT (R0T g) gtabT (kvT acn g v) (xcT acn g v) jkeys mergeP true 3000 (g0T acn g v)
            (Internal f) argsF with
    | Some cs => forallb (pk_okT acn g v) cs
    | None => false end).

Lemma dm_dma : (prog_defmap memory.prog) ! memory._dma_read = Some (Gfun (Internal memory.f_dma_read)).
Proof. vm_compute. reflexivity. Qed.
Lemma dm_ryt : (prog_defmap mario.prog) ! mario._return_mario_anim_y_translation
  = Some (Gfun (Internal mario.f_return_mario_anim_y_translation)).
Proof. vm_compute. reflexivity. Qed.

Section LP.
Variable lp : Clight.program.
Hypothesis H12 : linked12 lp.
Local Notation G := (globalenv lp).
Hypothesis Hdma : os_dma_floor.
Hypothesis Hanim : pi_dma_anim_spec.  (* TRUST 0.8(f): the PI DMA copies the ROM bytes *)
Hypothesis Haudio : audio_inert.      (* LABELED OPEN PREMISE: audio, deferred *)

Variable acn : Z.
Variable v : avar.
Variable fK : function.
Hypothesis Hwalk : pole_walkT acn v fK = true.

Variables (m0 : mem) (gp : meminj).
Hypothesis GPO : forall b x, gp b = Some x -> Plt b (Mem.nextblock m0).
Hypothesis MC : forall ch b z v, gp b <> None -> Mem.load ch m0 b z = Some v -> val_old gp v.
Hypothesis FD : floor_data G m0.

Local Notation uf := (ufT G m0 gp).
Local Notation R0 := (R0T G).
Local Notation KV := (kvT acn G v).

Lemma ufT_kW : forall vs, uf kW vs -> Wff G m0 gp (szs G mario._Surface) vs.
Proof. intros vs H. exact H. Qed.
Lemma ufT_kH_in : forall h yv, HPi (Hit_at G m0) (ycast yv) h -> Hit_at G m0 h ->
  uf kH [Some (Vsingle h); Some yv].
Proof. intros h yv A B. cbn. split; assumption. Qed.
Lemma ufT_kS : forall vs, surf_on m0 vs -> uf kS vs.
Proof. intros vs H. exact H. Qed.
Lemma ufT_kL_in : forall h yv, HPi (Hit_at G m0) (ycast yv) h -> uf kL [Some (Vsingle h); Some yv].
Proof. intros h yv A. exact A. Qed.
Lemma ufT_kC_in : forall h yv, ceil_ok yv h -> uf kC [Some (Vsingle h); Some yv].
Proof. intros h yv A. exact A. Qed.
Lemma ufT_kP_out : forall vs, uf kP vs ->
  exists p, vs = [Some (Vsingle p)] /\ F32 p = true /\ (-1000 <= R2 p)%R.
Proof.
  intros vs H. cbn in H.
  destruct vs as [| [[| | | | p |]|] [| o r]]; try contradiction.
  exists p. split; [reflexivity | exact H].
Qed.
Lemma ufT_kC_out : forall vs, uf kC vs -> exists h yv, vs = [Some (Vsingle h); Some yv] /\ ceil_ok yv h.
Proof.
  intros vs H. cbn in H.
  destruct vs as [| [[| | | | h |]|] [| [yv|] [| o3 r]]]; try contradiction.
  exists h, yv. split; [reflexivity | exact H].
Qed.
Lemma ufT_kH_out : forall vs, uf kH vs -> exists h yv, vs = [Some (Vsingle h); Some yv]
                                               /\ HPi (Hit_at G m0) (ycast yv) h.
Proof.
  intros vs H. cbn in H.
  destruct vs as [| [[| | | | h |]|] [| [yv|] [| o3 r]]]; try contradiction.
  exists h, yv. split; [reflexivity | exact (proj1 H)].
Qed.
Lemma ufT_kL_out : forall vs, uf kL vs -> exists h yv, vs = [Some (Vsingle h); Some yv]
                                               /\ HPi (Hit_at G m0) (ycast yv) h.
Proof.
  intros vs H. cbn in H.
  destruct vs as [| [[| | | | h |]|] [| [yv|] [| o3 r]]]; try contradiction.
  exists h, yv. split; [reflexivity | exact H].
Qed.
Lemma ufT_kY_out : forall vs, uf kYp vs -> exists y, vs = [Some (Vint y)] /\ (-1 <= Int.signed y <= 174)%Z.
Proof.
  intros vs H. cbn in H.
  destruct vs as [| [[| y | | | |]|] [| o r]]; try contradiction.
  exists y. split; [reflexivity | exact H].
Qed.
Lemma ufT_kY_in : forall y, (-1 <= Int.signed y <= 174)%Z -> uf kYp [Some (Vint y)].
Proof. intros y H. exact H. Qed.
Lemma ufT_kF_out : forall x lo hi, uf kF [x; Some (Vint lo); Some (Vint hi)] ->
  exists i, x = Some (Vint i) /\ (Int.signed lo <= Int.signed i <= Int.signed hi)%Z.
Proof. intros x lo hi H. exact H. Qed.
Lemma ufT_kBUF : forall vs, uf kBUF vs -> exists b o, vs = [Some (Vptr b o)]
  /\ (forall id b', Genv.find_symbol G id = Some b' -> b' <> b)
  /\ Mem.range_perm m0 b (Ptrofs.unsigned o) (Ptrofs.unsigned o + BUFSZ) Cur Readable
  /\ Z.modulo (Ptrofs.unsigned o) 4 = 0 /\ Ptrofs.unsigned o + BUFSZ < Ptrofs.modulus.
Proof. intros vs H. exact H. Qed.
Lemma ufT_kGA : forall vs, uf kGA vs -> exists b, vs = [Some (Vptr b Ptrofs.zero)]
  /\ forall o ch z, In (o, ch, z) ga_cells -> Mem.load ch m0 b o = Some (Vint (Int.repr z)).
Proof. intros vs H. exact H. Qed.

Let XSI := air_xc_sound_link lp (linked12_LO_surf lp H12) (linked12_LO_math lp H12)
             (linked12_LO_mario lp H12) NBT R0 gtabT KV m0 uf gp
             RFI RMISS RCALLS kW kH kS (szs G mario._Surface) GPO eq_refl eq_refl eq_refl
             ufT_kW ufT_kH_in ufT_kS.

(* THE TABLE IS SOUND on the real link *)
Theorem xcT_sound : forall id k args g cps fd E m vargs t m' vres,
  xcT acn G v id = Some k -> k args g = Some cps -> sfun_lookup G id = Some fd ->
  MMg G NBT R0 gtabT KV m0 uf gp E m g ->
  Forall2 (fun a v => den G m0 E a = Some v /\ sok NBT (g_nx g) a) args vargs ->
  eval_funcall function_entry2 G m fd vargs t m' vres ->
  exists c, In c cps /\ CM G NBT R0 gtabT KV m0 uf gp E (g_nx g) (g_loc g) m' vres c.
Proof.
  intros id k args g cps fd E m vargs t m' vres Hx Hk Hl MM HA EV.
  unfold xcT in Hx. destruct (xcIT G id) as [k0|] eqn:Xi.
  - injection Hx as <-. unfold xcIT in Xi.
    destruct (Pos.eqb_spec id mario._find_floor) as [-> | N1].
    { injection Xi as <-.
      rewrite (sfun_res_h _ _ _ _ (res_link lp _ _ _ (linked12_LO_surf lp H12) dm_ff) Hl) in EV.
      exact (c_ff2_sound G NBT R0 gtabT KV m0 uf gp GPO RFI RMISS RCALLS kW kH kS kL
               (szs G mario._Surface) (cenv_has_link lp (linked12_LO_surf lp H12))
               (res_link lp _ _ _ (linked12_LO_surf lp H12) dm_ffl) eq_refl eq_refl eq_refl
               ufT_kW ufT_kS ufT_kH_in ufT_kL_in args g cps E m vargs t m' vres Hk MM HA EV). }
    destruct (Pos.eqb_spec id mario._find_ceil) as [-> | N2].
    { injection Xi as <-.
      rewrite (sfun_res_h _ _ _ _ (res_link lp _ _ _ (linked12_LO_surf lp H12) dm_fc) Hl) in EV.
      exact (c_fc2_sound G NBT R0 gtabT KV m0 uf gp GPO RCALLS kW kC
               (szs G mario._Surface) (cenv_has_link lp (linked12_LO_surf lp H12))
               (res_link lp _ _ _ (linked12_LO_surf lp H12) dm_fcl) eq_refl
               ufT_kW ufT_kC_in args g cps E m vargs t m' vres Hk MM HA EV). }
    exact (XSI id k0 args g cps fd E m vargs t m' vres Xi Hk Hl MM HA EV).
  - destruct (Pos.eqb_spec id memory._dma_read) as [-> | N0].
    { injection Hx as <-.
      rewrite (sfun_res_h _ _ _ _ (res_link lp _ _ _ (linked12_LO_memory lp H12) dm_dma) Hl) in EV.
      exact (c_dma_sound lp H12 Hdma Hanim NBT R0 gtabT KV m0 uf gp GPO RBUF RIOM RMQ RRM RGA kBUF kGA
               ga_cells ufT_kBUF ufT_kGA args g cps E m vargs t m' vres Hk MM HA EV). }
    destruct (Pos.eqb_spec id mario._return_mario_anim_y_translation) as [-> | N7].
    { injection Hx as <-.
      rewrite (sfun_res_h _ _ _ _ (res_link lp _ _ _ (linked12_LO_mario lp H12) dm_ryt) Hl) in EV.
      exact (c_ryt_sound G NBT R0 gtabT KV m0 uf gp GPO MC jkeys 3000 RO kF kYp ufT_kF_out ufT_kY_in
               args g cps E m vargs t m' vres Hk MM HA EV). }
    destruct (Pos.eqb_spec id mario._is_anim_at_end) as [-> | N2].
    { injection Hx as <-.
      rewrite (sfun_res_h _ _ _ _ (res_link lp _ _ _ (linked12_LO_mario lp H12) dm_iae) Hl) in EV.
      destruct (anim_end_value_contract _ _ _ _ _ _ EV) as (-> & i & ->).
      exact (xc_fresh_sound G NBT R0 gtabT KV (fun _ => None) (fun _ => false) m0 uf gp
               E m g (Vint i) args cps Hk MM I). }
    destruct (Pos.eqb_spec id mario._is_anim_past_frame) as [-> | N6].
    { injection Hx as <-.
      rewrite (sfun_res_h _ _ _ _ (res_link lp _ _ _ (linked12_LO_mario lp H12) dm_ipf) Hl) in EV.
      destruct (past_frame_value_contract _ _ _ _ _ _ EV) as (-> & i & ->).
      exact (xc_fresh_sound G NBT R0 gtabT KV (fun _ => None) (fun _ => false) m0 uf gp
               E m g (Vint i) args cps Hk MM I). }
    destruct (Pos.eqb_spec id AUT._play_sound) as [-> | N3].
    { injection Hx as <-. rewrite ps_aut in Hl.
      exact (ext_fresh_sound lp H12 _ _ ps_named ps_ni (audio_ps Haudio) NBT R0 gtabT KV m0 uf gp GPO
               args g cps fd E m vargs t m' vres Hk Hl MM EV). }
    destruct (Pos.eqb_spec id AUT._set_sound_moving_speed) as [-> | N4]; [| discriminate Hx].
    injection Hx as <-.
    exact (ext_fresh_sound_q lp H12 AUT.prog (linked12_LO_aut lp H12) _ _ ssms_named ssms_ni (audio_ssms Haudio)
             NBT R0 gtabT KV m0 uf gp GPO args g cps fd E m vargs t m' vres Hk Hl MM EV).
Qed.

Lemma polecheckT_lp : exists cs,
  sx_call G NBT R0 gtabT KV (xcT acn G v) jkeys mergeP true 3000 (g0T acn G v)
    (Internal fK) argsF = Some cs
  /\ forall c, In c cs -> pk_okT acn G v c = true.
Proof.
  pose proof Hwalk as W. unfold pole_walkT, with_ge in W. rewrite (ge12_ok lp H12) in W.
  exact (consume _ (pk_okT acn G v) W).
Qed.

(* the animation blocks, through the environment *)
Definition ast (E : senv) (m : mem) : Prop :=
  anim_st m (e_blk E RLD) (e_blk E RGA) (e_blk E RBUF) (e_base E RBUF) (e_blk E RO) (e_base E RO).

(* THE THEOREM: PoleRun.pole_final's, with the table kept and the
   animation state at the end *)
Theorem pole_finalT : forall E t m' vres c0,
  env_ok G NBT R0 gtabT KV m0 gp E ->
  (forall f, In f (pc0T acn G v) -> fact_nlt NBT f /\ fact_holds G R0 m0 uf E f) ->
  (av_st v = true -> ast E m0) ->
  eval_funcall function_entry2 G m0 (Internal fK)
    [Vptr (e_blk E RM) (Ptrofs.add (e_base E RM) Ptrofs.zero)] t m' vres ->
  read_cells (e_blk E RM) m0 c0 -> InRange c0 ->
  exists E' gs, Ext E E' NBT /\ MMg G NBT R0 gtabT KV m0 uf gp E' m' gs
    /\ fkp_ok NBT R0 KV RM RO RLD kS clokF gs = true /\ no_reg RU gs = true /\ no_reg RTAB gs = true
    /\ RET (e_blk E RM) m0 m' vres
    /\ (forall a, Mem.load Mint32 m' (e_blk E RM) 12 = Some (Vint a) -> In (Int.unsigned a) anim_acts ->
          ast E m')
    /\ exists c2, read_cells (e_blk E RM) m' c2
       /\ RangedMove wmotr_floor wmotr_pole wmotr_cannon c0 c2
       /\ In (Int.unsigned (c_action c2)) POLE_OUT
       /\ c_vely c2 = c_vely c0
       /\ (In (Int.unsigned (c_action c2)) POLE_ACTS3 ->
             Mem.load Mint32 m' (e_blk E RM) USED_OFF = Mem.load Mint32 m0 (e_blk E RM) USED_OFF
             /\ (forall z, z = O_POSY \/ z = HITBOX_DOWN_OFF \/ z = HITBOX_H_OFF ->
                   Mem.load Mfloat32 m' (e_blk E RU) (addr E RU z)
                   = Mem.load Mfloat32 m0 (e_blk E RU) (addr E RU z))
             /\ exists p, Mem.load Mfloat32 m' (e_blk E RO) (addr E RO POLEPOS_OFF) = Some (Vsingle p)
                  /\ F32 p = true /\ (-1000 <= R2 p)%R).
Proof.
  intros E t m' vres c0 EO PC ST EV RC IR.
  destruct polecheckT_lp as (cs & RUN & W).
  assert (MM0 : MMg G NBT R0 gtabT KV m0 uf gp E m0 (g0T acn G v)).
  { apply MMg_init; [exact EO | apply Ple_refl |]. exact PC. }
  assert (ARGS : Forall2 (fun a w => den G m0 E a = Some w /\ sok NBT (g_nx (g0T acn G v)) a) argsF
                   [Vptr (e_blk E RM) (Ptrofs.add (e_base E RM) Ptrofs.zero)]).
  { constructor; [| constructor].
    split; [reflexivity |]. cbn [sok nlt g0T g_nx]. split; [unfold Plt, Pos.lt; reflexivity | exact Logic.I]. }
  destruct (sx_call_sound G NBT R0 gtabT KV (xcT acn G v) jkeys mergeP true m0 uf gp
              GPO MC xcT_sound 3000 (g0T acn G v) _ argsF cs E m0 _ t m' vres RUN MM0 ARGS EV) as (c & Hin & CMc).
  destruct c as [gs r]. destruct CMc as (E' & X & MM & DR & _).
  pose proof (W _ Hin) as OK. unfold pk_okT in OK. cbn [fst] in OK.
  apply andb_true_iff in OK as [OK AE]. apply andb_true_iff in OK as [OK RT].
  apply andb_true_iff in OK as [OK NT]. apply andb_true_iff in OK as [OK NR].
  apply andb_true_iff in OK as [PO FK].
  exists E', gs. split; [exact X | split; [exact MM | split; [exact FK | split; [exact NR | split; [exact NT |]]]]].
  pose proof EO as (_ & _ & _ & GT & KVo & _).
  destruct (GT level_update._gMarioStates RM eq_refl) as (_ & BaM0 & HbM).
  destruct (GT mario._gMarioAnimsBuf RLD eq_refl) as (_ & BaL0 & _).
  destruct (GT game_init._gMarioAnims RGA eq_refl) as (_ & BaG0 & _).
  destruct (X RM ltac:(vm_compute; reflexivity)) as (BM & BaM & _).
  destruct (X RO ltac:(vm_compute; reflexivity)) as (BO & BaO & _).
  destruct (X RU ltac:(vm_compute; reflexivity)) as (BU & BaU & _).
  destruct (X RLD ltac:(vm_compute; reflexivity)) as (BL & BaL & _).
  destruct (X RGA ltac:(vm_compute; reflexivity)) as (BG & BaG & _).
  destruct (X RBUF ltac:(vm_compute; reflexivity)) as (BB & BaB & _).
  split; [rewrite <- BM; exact (ret_sound G NBT R0 gtabT KV m0 uf gp GPO RM E' m' gs MM
                                 ltac:(rewrite BaM; exact BaM0) r vres DR RT) |].
  split.
  { intros a La Ia. unfold ast.
    exact (anim_end_sound G NBT R0 gtabT KV m0 uf gp GPO RM RO RLD RBUF RGA kF ufT_kF_out E' m' gs MM
             (e_blk E RM) (e_blk E RLD) (e_blk E RGA) (e_blk E RBUF) (e_blk E RO) (e_base E RBUF) (e_base E RO)
             (conj BM (eq_trans BaM BaM0)) (conj BO BaO) (conj BL (eq_trans BaL BaL0))
             (conj BB BaB) (conj BG (eq_trans BaG BaG0))
             (av_st v) AE ST a La Ia). }
  rewrite <- BM in RC.
  destruct (pole_sound G NBT R0 gtabT KV m0 uf gp GPO RM RO RU kP kC kH kL
              ufT_kP_out ufT_kC_out ufT_kH_out ufT_kL_out ufT_kY_out FD E' m' gs MM
              ltac:(rewrite BaM; exact BaM0) c0 RC IR PO)
    as (c2 & RC2 & RM2 & Hout & Hv & Hk).
  exists c2. rewrite <- BM. split; [exact RC2 |]. split; [exact RM2 |]. split; [exact Hout |].
  split; [exact Hv |].
  intros H3. specialize (Hk H3).
  destruct (pole_keep_sound G NBT R0 gtabT KV m0 uf gp GPO RM RO RU kP kC
              ufT_kP_out ufT_kC_out ufT_kY_out E' m' gs MM ltac:(rewrite BaM; exact BaM0) Hk) as (U1 & U2 & U3).
  unfold addr. rewrite <- BU, <- BaU, <- BO, <- BaO.
  split; [exact U1 |]. split; [exact U2 | exact U3].
Qed.
End LP.

(* the walk theorem's statement *)
Definition pfinalT (lp : Clight.program) (acn : Z) (v : avar) (fK : function) : Prop :=
  forall (m0 : mem) (gp : meminj),
  (forall b x, gp b = Some x -> Plt b (Mem.nextblock m0)) ->
  (forall ch b z v, gp b <> None -> Mem.load ch m0 b z = Some v -> val_old gp v) ->
  floor_data (globalenv lp) m0 ->
  forall E t m' vres c0,
  env_ok (globalenv lp) NBT (R0T (globalenv lp)) gtabT (kvT acn (globalenv lp) v) m0 gp E ->
  (forall f, In f (pc0T acn (globalenv lp) v) ->
     fact_nlt NBT f /\ fact_holds (globalenv lp) (R0T (globalenv lp)) m0 (ufT (globalenv lp) m0 gp) E f) ->
  (av_st v = true -> ast E m0) ->
  eval_funcall function_entry2 (globalenv lp) m0 (Internal fK)
    [Vptr (e_blk E RM) (Ptrofs.add (e_base E RM) Ptrofs.zero)] t m' vres ->
  read_cells (e_blk E RM) m0 c0 -> InRange c0 ->
  exists E' gs, Ext E E' NBT
    /\ MMg (globalenv lp) NBT (R0T (globalenv lp)) gtabT (kvT acn (globalenv lp) v) m0
         (ufT (globalenv lp) m0 gp) gp E' m' gs
    /\ fkp_ok NBT (R0T (globalenv lp)) (kvT acn (globalenv lp) v) RM RO RLD kS clokF gs = true
    /\ no_reg RU gs = true /\ no_reg RTAB gs = true
    /\ RET (e_blk E RM) m0 m' vres
    /\ (forall a, Mem.load Mint32 m' (e_blk E RM) 12 = Some (Vint a) -> In (Int.unsigned a) anim_acts ->
          ast E m')
    /\ exists c2, read_cells (e_blk E RM) m' c2
       /\ RangedMove wmotr_floor wmotr_pole wmotr_cannon c0 c2
       /\ In (Int.unsigned (c_action c2)) POLE_OUT
       /\ c_vely c2 = c_vely c0
       /\ (In (Int.unsigned (c_action c2)) POLE_ACTS3 ->
             Mem.load Mint32 m' (e_blk E RM) USED_OFF = Mem.load Mint32 m0 (e_blk E RM) USED_OFF
             /\ (forall z, z = O_POSY \/ z = HITBOX_DOWN_OFF \/ z = HITBOX_H_OFF ->
                   Mem.load Mfloat32 m' (e_blk E RU) (addr E RU z)
                   = Mem.load Mfloat32 m0 (e_blk E RU) (addr E RU z))
             /\ exists p, Mem.load Mfloat32 m' (e_blk E RO) (addr E RO POLEPOS_OFF) = Some (Vsingle p)
                  /\ F32 p = true /\ (-1000 <= R2 p)%R).

Lemma pole_pfinalT : forall lp, linked12 lp -> os_dma_floor -> pi_dma_anim_spec -> audio_inert ->
  forall acn v fK, pole_walkT acn v fK = true -> pfinalT lp acn v fK.
Proof.
  intros lp H12 Hdma Han Ha acn v fK Hw m0 gp GPO MC FD.
  exact (pole_finalT lp H12 Hdma Han Ha acn v fK Hw m0 gp GPO MC FD).
Qed.
