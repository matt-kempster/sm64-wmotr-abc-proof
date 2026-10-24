(* ====================================================================== *)
(* CannonRun (GOAL 2): ACT_IN_CANNON's case of the automatic dispatcher,  *)
(* walked on the link.                                                     *)
(*                                                                        *)
(* act_in_cannon (mario_actions_automatic.c) stores                       *)
(* usedObj->oInteractStatus and m->statusForCamera's cameraEvent / usedObj *)
(* (state 0), reads the cannon's oAction / move angles (state 1) and the   *)
(* controller's stick (state 2), and copies pos into gfx.pos.  The walker  *)
(* config is PoleRun's regions (R0P: usedObj is region RU) with           *)
(*   - the known cells kvK and usedObj = RU, whose oPosY is one cannon     *)
(*     base's (WMotRWorld.cannon_obj_ok; walked once per WMotR cannon);    *)
(*   - the start facts of FfRun plus m->controller (a world object);       *)
(*   - set_mario_animation (SmaXc) and play_sound (SndXc, real body).      *)
(* m->input's A bits are clear, so the shot (and its set_mario_action) is  *)
(* pruned.  Each outcome passes CannonClass.cannon_ok, PoleKeep.fkp_ok and *)
(* ret_ok.                                                                 *)
(* ====================================================================== *)

From Coq Require Import List ZArith Reals.
From compcert Require Import Coqlib Maps AST Integers Floats Values Memory Events Globalenvs
  Ctypes Clight ClightBigstep.
From SM64.Generated Require mario_step mario mario_actions_airborne mario_actions_automatic memory
  surface_collision level_update.
From SM64.Proofs Require Import Interp.SymExec2 Interp.LinkGenv MarioModel.LinkedTwelve
  MarioModel.OsDmaFloor MarioModel.MathGeomGated HeightInvariant HeightMoveCatalog WMotRLevel WMotRWorld.
From SM64.Proofs.WMotRRequiresA Require Import FloorHeight FloorExec AirXc AirRun AirMatch SmaXc
  ExtInert SndXc FfClass AirStart FfKeepCheck RetOk FfRun AhwRun KbRun WithGe
  PoleXc PoleClass PoleKeep PoleSound FfWorld FpWalk PoleRun CannonClass.
Import ListNotations.

Module AUT := mario_actions_automatic.

Section CFG.
Variable acn : Z.
Variable yc : Z.      (* the seat: one of wmotr_cannon_list *)
Variable g : genv.
Definition kvC : list (positive * Z * memory_chunk * sval) :=
  kvK acn g ++
  [ (RM, USED_OFF, Mint32, Sptr RU Ptrofs.zero);
    (RU, O_POSY, Mfloat32, Sconst (f32z (yc - CANNON_SEAT))) ].
Definition xcC (id : ident) : option xcontract :=
  match xcIP g id with
  | Some k => Some k
  | None =>
    if Pos.eqb id mario._set_mario_animation then Some (c_sma NBP (R0P g) gtabP kvC RLD RBUF RIOM RMQ RRM kB) else
    if Pos.eqb id AUT._play_sound then Some (c_snd (R0P g) gtabP ps_regs) else None
  end.
Definition pc0C : list fact :=
  [Fuser kW (wargs (R0P g)); Fbits (Sinit RM 2 Mint16unsigned) (Int.repr 2178);
   Fworld (Sinit RM (AirRun.fo g mario._MarioState mario._floor) Mint32) (szs g mario._Surface);
   Fworld (Sinit RM (AirRun.fo g mario._MarioState mario._area) Mint32) (szs g mario._Area);
   Fworld (Sptr RSIN Ptrofs.zero) Ptrofs.modulus;
   Fworld (Sptr RAR Ptrofs.zero) 4;
   Fuser kB [Sinit RLD 8 Mint32; Sptr RBUF Ptrofs.zero];
   Fuser kS (Sinit RM (AirRun.fo g mario._MarioState mario._floor) Mint32 :: wargs (R0P g));
   (* m->controller: a world object (state 2 reads its stick) *)
   Fworld (Sinit RM FFW_CTL Mint32) SZ_CTL]
  ++ ffacts (Sinit RM (AirRun.fo g mario._MarioState mario._floor) Mint32).
Definition g0C : gst := mkg nil pc0C NBP nil nil.

(* each outcome: the move class and the kept cannon, the kept world, the return *)
Definition ck_ok (c : cpath) : bool :=
  cannon_ok NBP (R0P g) kvC RM RO RU yc (fst c)
  && fkp_ok NBP (R0P g) kvC RM RO RLD kS clokF (fst c)
  && ret_ok NBP (R0P g) kvC RM c.
End CFG.

Definition cannon_walk (acn yc : Z) (f : function) : bool :=
  with_ge ge12 false (fun g =>
    match sx_call g NBP (R0P g) gtabP (kvC acn yc g) (xcC acn yc g) jkeys mergeP true 3000 (g0C g)
            (Internal f) argsF with
    | Some cs => forallb (ck_ok acn yc g) cs
    | None => false end).

(* the walk at many seats, sharing one genv (the seats of WMotRLevel's
   cannon list: each home seat + 5k while the base rises) *)
Definition cannon_walk_all (acn : Z) (ycs : list Z) (f : function) : bool :=
  with_ge ge12 false (fun g =>
    forallb (fun yc =>
      match sx_call g NBP (R0P g) gtabP (kvC acn yc g) (xcC acn yc g) jkeys mergeP true 3000 (g0C g)
              (Internal f) argsF with
      | Some cs => forallb (ck_ok acn yc g) cs
      | None => false end) ycs).

Lemma cannon_walk_of_all : forall acn ycs f yc,
  cannon_walk_all acn ycs f = true -> In yc ycs -> cannon_walk acn yc f = true.
Proof.
  intros acn ycs f yc H Hin. unfold cannon_walk_all, with_ge in H. unfold cannon_walk, with_ge.
  destruct ge12 as [g|]; [| discriminate H].
  exact (proj1 (forallb_forall _ _) H yc Hin).
Qed.

Section LP.
Variable lp : Clight.program.
Hypothesis H12 : linked12 lp.
Local Notation G := (globalenv lp).
Hypothesis Hdma : os_dma_floor.

Variable acn yc : Z.
Variable fK : function.
Hypothesis Hwalk : cannon_walk acn yc fK = true.
Hypothesis Hyc : In yc wmotr_cannon_list.

Variables (m0 : mem) (gp : meminj).
Hypothesis GPO : forall b x, gp b = Some x -> Plt b (Mem.nextblock m0).
Hypothesis MC : forall ch b z v, gp b <> None -> Mem.load ch m0 b z = Some v -> val_old gp v.
Hypothesis FD : floor_data G m0.

Local Notation uf := (ufP G m0 gp).

Let XSI := air_xc_sound_link lp (linked12_LO_surf lp H12) (linked12_LO_math lp H12)
             (linked12_LO_mario lp H12) NBP (R0P G) gtabP (kvC acn yc G) m0 uf gp
             RFI RMISS RCALLS kW kH kS (szs G mario._Surface) GPO eq_refl eq_refl eq_refl
             (ufP_kW lp m0 gp) (ufP_kH_in lp m0 gp) (ufP_kS lp m0 gp).

(* THE TABLE IS SOUND on the real link *)
Theorem xcC_sound : forall id k args g cps fd E m vargs t m' vres,
  xcC acn yc G id = Some k -> k args g = Some cps -> sfun_lookup G id = Some fd ->
  MMg G NBP (R0P G) gtabP (kvC acn yc G) m0 uf gp E m g ->
  Forall2 (fun a v => den G m0 E a = Some v /\ sok NBP (g_nx g) a) args vargs ->
  eval_funcall function_entry2 G m fd vargs t m' vres ->
  exists c, In c cps /\ CM G NBP (R0P G) gtabP (kvC acn yc G) m0 uf gp E (g_nx g) (g_loc g) m' vres c.
Proof.
  intros id k args g cps fd E m vargs t m' vres Hx Hk Hl MM HA EV.
  unfold xcC in Hx. destruct (xcIP G id) as [k0|] eqn:Xi.
  - injection Hx as <-. unfold xcIP in Xi.
    destruct (Pos.eqb_spec id mario._find_floor) as [-> | N1].
    { injection Xi as <-.
      rewrite (sfun_res_h _ _ _ _ (res_link lp _ _ _ (linked12_LO_surf lp H12) dm_ff) Hl) in EV.
      exact (c_ff2_sound G NBP (R0P G) gtabP (kvC acn yc G) m0 uf gp GPO RFI RMISS RCALLS kW kH kS kL
               (szs G mario._Surface) (cenv_has_link lp (linked12_LO_surf lp H12))
               (res_link lp _ _ _ (linked12_LO_surf lp H12) dm_ffl) eq_refl eq_refl eq_refl
               (ufP_kW lp m0 gp) (ufP_kS lp m0 gp) (ufP_kH_in lp m0 gp) (ufP_kL_in lp m0 gp)
               args g cps E m vargs t m' vres Hk MM HA EV). }
    destruct (Pos.eqb_spec id mario._find_ceil) as [-> | N2].
    { injection Xi as <-.
      rewrite (sfun_res_h _ _ _ _ (res_link lp _ _ _ (linked12_LO_surf lp H12) dm_fc) Hl) in EV.
      exact (c_fc2_sound G NBP (R0P G) gtabP (kvC acn yc G) m0 uf gp GPO RCALLS kW kC
               (szs G mario._Surface) (cenv_has_link lp (linked12_LO_surf lp H12))
               (res_link lp _ _ _ (linked12_LO_surf lp H12) dm_fcl) eq_refl
               (ufP_kW lp m0 gp) (ufP_kC_in lp m0 gp) args g cps E m vargs t m' vres Hk MM HA EV). }
    exact (XSI id k0 args g cps fd E m vargs t m' vres Xi Hk Hl MM HA EV).
  - destruct (Pos.eqb_spec id mario._set_mario_animation) as [-> | N1].
    + injection Hx as <-.
      rewrite (sfun_res_h _ _ _ _ (res_link lp _ _ _ (linked12_LO_mario lp H12) dm_sma_h) Hl) in EV.
      exact (c_sma_sound lp H12 Hdma NBP (R0P G) gtabP (kvC acn yc G) m0 uf gp GPO MC RLD RBUF RIOM RMQ RRM kB
               (ufP_kB lp m0 gp) args g cps E m vargs t m' vres Hk MM HA EV).
    + destruct (Pos.eqb_spec id AUT._play_sound) as [-> | N3]; [| discriminate Hx].
      injection Hx as <-.
      rewrite (sfun_res _ _ _ _ (res_link lp _ _ _ (linked12_LO_audio_external lp H12) ps_defmap) Hl) in EV.
      exact (c_ps_sound lp NBP (R0P G) gtabP (kvC acn yc G) m0 uf gp GPO RSR RSRC
               args g cps E m vargs t m' vres Hk MM EV).
Qed.

Lemma cannoncheck_lp : exists cs,
  sx_call G NBP (R0P G) gtabP (kvC acn yc G) (xcC acn yc G) jkeys mergeP true 3000 (g0C G)
    (Internal fK) argsF = Some cs
  /\ forall c, In c cs -> ck_ok acn yc G c = true.
Proof.
  pose proof Hwalk as W. unfold cannon_walk, with_ge in W. rewrite (ge12_ok lp H12) in W.
  exact (consume _ (ck_ok acn yc G) W).
Qed.

Lemma pc0C_nlt : forall f, In f (pc0C G) -> fact_nlt NBP f.
Proof.
  intros f H. cbn [pc0C app ffacts In] in H.
  repeat (destruct H as [<- | H]; [cbn; repeat split; try (unfold Plt; cbn; lia); repeat constructor; unfold Plt; cbn; lia |]).
  contradiction.
Qed.

(* THE THEOREM: every execution of act_in_cannon from a memory the start
   state describes keeps the world (fkp_ok) and the cannon, stays in
   ACT_IN_CANNON, returns FALSE or keeps the two cells, and moves Phi's
   cells by one RangedMove *)
Theorem cannon_final : forall E t m' vres c0,
  env_ok G NBP (R0P G) gtabP (kvC acn yc G) m0 gp E ->
  (forall f, In f (pc0C G) -> fact_holds G (R0P G) m0 uf E f) ->
  eval_funcall function_entry2 G m0 (Internal fK)
    [Vptr (e_blk E RM) (Ptrofs.add (e_base E RM) Ptrofs.zero)] t m' vres ->
  read_cells (e_blk E RM) m0 c0 -> InRange c0 ->
  exists E' gs, Ext E E' NBP /\ MMg G NBP (R0P G) gtabP (kvC acn yc G) m0 uf gp E' m' gs
    /\ fkp_ok NBP (R0P G) (kvC acn yc G) RM RO RLD kS clokF gs = true
    /\ RET (e_blk E RM) m0 m' vres
    /\ (forall r o ch, In (r, o, ch) (cannon_cells RM RU) ->
          Mem.load ch m' (e_blk E r) (addr E r o) = Mem.load ch m0 (e_blk E r) (addr E r o))
    /\ exists c2, read_cells (e_blk E RM) m' c2
       /\ RangedMove wmotr_floor wmotr_pole wmotr_cannon c0 c2
       /\ c_action c2 = Int.repr ACT_IN_CANNON_Z.
Proof.
  intros E t m' vres c0 EO PC EV RC IR.
  destruct cannoncheck_lp as (cs & RUN & W).
  assert (MM0 : MMg G NBP (R0P G) gtabP (kvC acn yc G) m0 uf gp E m0 (g0C G)).
  { apply MMg_init; [exact EO | apply Ple_refl |].
    intros f Hf. split; [exact (pc0C_nlt f Hf) | exact (PC f Hf)]. }
  assert (ARGS : Forall2 (fun a v => den G m0 E a = Some v /\ sok NBP (g_nx (g0C G)) a) argsF
                   [Vptr (e_blk E RM) (Ptrofs.add (e_base E RM) Ptrofs.zero)]).
  { constructor; [| constructor].
    split; [reflexivity |]. cbn [sok nlt g0C g_nx]. split; [unfold Plt, Pos.lt; reflexivity | exact Logic.I]. }
  destruct (sx_call_sound G NBP (R0P G) gtabP (kvC acn yc G) (xcC acn yc G) jkeys mergeP true m0 uf gp
              GPO MC xcC_sound 3000 (g0C G) _ argsF cs E m0 _ t m' vres RUN MM0 ARGS EV) as (c & Hin & CMc).
  destruct c as [gs r]. destruct CMc as (E' & X & MM & DR & _).
  pose proof (W _ Hin) as OK. unfold ck_ok in OK. cbn [fst] in OK.
  apply andb_true_iff in OK as [OK RT]. apply andb_true_iff in OK as [CO FK].
  exists E', gs. split; [exact X | split; [exact MM | split; [exact FK |]]].
  destruct EO as (_ & _ & _ & GT & KV & _).
  destruct (GT level_update._gMarioStates RM eq_refl) as (_ & HbM & _).
  destruct (X RM ltac:(vm_compute; reflexivity)) as (BM & BaM & _).
  destruct (X RU ltac:(vm_compute; reflexivity)) as (BU & BaU & _).
  split; [rewrite <- BM; exact (ret_sound G NBP (R0P G) gtabP (kvC acn yc G) m0 uf gp GPO RM E' m' gs MM
                                 ltac:(rewrite BaM; exact HbM) r vres DR RT) |].
  rewrite <- BM in RC.
  destruct (cannon_sound G NBP (R0P G) gtabP (kvC acn yc G) m0 uf gp GPO RM RO RU yc Hyc E' m' gs MM
              ltac:(rewrite BaM; exact HbM) c0 RC IR CO)
    as (c2 & RC2 & RM2 & Ha & KP).
  split.
  - intros r0 o ch Hin0.
    assert (XR : e_blk E' r0 = e_blk E r0 /\ e_base E' r0 = e_base E r0).
    { destruct Hin0 as [E0 | [E0 | [E0 | [E0 | [E0 | []]]]]]; injection E0 as <- <- <-;
        first [exact (conj BM BaM) | exact (conj BU BaU)]. }
    destruct XR as (XB1 & XB2).
    pose proof (cannon_keep_sound G NBP (R0P G) gtabP (kvC acn yc G) m0 uf gp GPO RM RU E' m' gs MM KP
                  r0 o ch Hin0) as K.
    unfold addr in K |- *. rewrite XB1, XB2 in K. exact K.
  - exists c2. rewrite <- BM. split; [exact RC2 |]. split; [exact RM2 | exact Ha].
Qed.
End LP.

(* the walk theorem's statement, for one cannon on the link *)
Definition cfinal (lp : Clight.program) (acn yc : Z) (fK : function) : Prop :=
  forall (m0 : mem) (gp : meminj),
  (forall b x, gp b = Some x -> Plt b (Mem.nextblock m0)) ->
  (forall ch b z v, gp b <> None -> Mem.load ch m0 b z = Some v -> val_old gp v) ->
  floor_data (globalenv lp) m0 ->
  forall E t m' vres c0,
  env_ok (globalenv lp) NBP (R0P (globalenv lp)) gtabP (kvC acn yc (globalenv lp)) m0 gp E ->
  (forall f, In f (pc0C (globalenv lp)) ->
     fact_holds (globalenv lp) (R0P (globalenv lp)) m0 (ufP (globalenv lp) m0 gp) E f) ->
  eval_funcall function_entry2 (globalenv lp) m0 (Internal fK)
    [Vptr (e_blk E RM) (Ptrofs.add (e_base E RM) Ptrofs.zero)] t m' vres ->
  read_cells (e_blk E RM) m0 c0 -> InRange c0 ->
  exists E' gs, Ext E E' NBP
    /\ MMg (globalenv lp) NBP (R0P (globalenv lp)) gtabP (kvC acn yc (globalenv lp)) m0
         (ufP (globalenv lp) m0 gp) gp E' m' gs
    /\ fkp_ok NBP (R0P (globalenv lp)) (kvC acn yc (globalenv lp)) RM RO RLD kS clokF gs = true
    /\ RET (e_blk E RM) m0 m' vres
    /\ (forall r o ch, In (r, o, ch) (cannon_cells RM RU) ->
          Mem.load ch m' (e_blk E r) (addr E r o) = Mem.load ch m0 (e_blk E r) (addr E r o))
    /\ exists c2, read_cells (e_blk E RM) m' c2
       /\ RangedMove wmotr_floor wmotr_pole wmotr_cannon c0 c2
       /\ c_action c2 = Int.repr ACT_IN_CANNON_Z.

Lemma cannon_cfinal : forall lp, linked12 lp -> os_dma_floor ->
  forall acn yc fK, cannon_walk acn yc fK = true -> In yc wmotr_cannon_list -> cfinal lp acn yc fK.
Proof.
  intros lp H12 Hdma acn yc fK Hw Hy m0 gp GPO MC FD.
  exact (cannon_final lp H12 Hdma acn yc fK Hw Hy m0 gp GPO MC).
Qed.
