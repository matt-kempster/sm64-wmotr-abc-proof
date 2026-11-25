(* spine-root: GOAL-2 coverage -- the capstone's start premise holds for every value of the state a real WMotR entry carries over from the castle (docs/wmotr-entry-census.md). *)
(* ====================================================================== *)
(* StartCarry (GOAL 2, coverage track, 2026-11-07).                       *)
(*                                                                        *)
(* Every real way into WMotR is the castle's warp node 0x0A               *)
(* (docs/wmotr-entry-census.md §1), so the entry code is fixed.  What a   *)
(* real entry does NOT fix is the state it carries over from the castle   *)
(* or reads from the save file: Mario's cap flags (init_mario, B2), his   *)
(* lives / health / stars / keys / coins and the dialog counters (fields  *)
(* the entry never writes, census §3), and the act number (B1, 1..6) and  *)
(* the save-file / RNG / timer globals (§4).                              *)
(*                                                                        *)
(* carried_keep: the capstone's start premise (mem_ok_lp with MWF_real,   *)
(* PhiW, plat_still, obj_w) is insensitive to those cells: storing ANY    *)
(* int into any of them keeps it.  goal2_start_carried: so the premise    *)
(* holds on the real-entry witness with every combination of carried     *)
(* values, not only the boot image's (lives 4, health 0x880, act 1, an    *)
(* empty save).                                                           *)
(*                                                                        *)
(* 2026-11-14: every Mario field the entry never writes except m->input  *)
(* (census §3) is a carried cell, with any non-pointer value (the float  *)
(* fields too), and eleven more globals of census §4 are carried.        *)
(* 2026-11-25: m->input too (istore_keep, cs_input): any u16 whose       *)
(* A_PRESSED | A_DOWN | INTERACT_OBJ_GRABBABLE bits (0x882) are clear,   *)
(* exactly what the frame-boundary invariant reads (ffw ff_Ai, MWF R1).  *)
(*                                                                        *)
(* m->wall / m->ceil: the premise says nothing of them (2026-11-08).    *)
(* Not covered here (census §4d, open): the castle's residue in free     *)
(* object / pool slots, the anim buffer's block (S7), and m->input's     *)
(* 0x882 bits (a castle-frame fact).  Act 0 runs since the 2026-11-07 rewrite *)
(* (TRUST 2.2; act0_val7 below); the witness itself still enters at act  *)
(* 1 (StartTerrain S2).                                                   *)
(* ====================================================================== *)
From Coq Require Import ZArith Lia List Bool.
From compcert Require Import Coqlib Integers Floats Values AST Ctypes Cop Clight Clightdefs Memory Maps Globalenvs.
From SM64.Generated Require level_update mario object_list_processor area platform_displacement
  sound_init game_init wmotr_script level_script.
From SM64.Generated Require save_file behavior_script camera.
From SM64.Proofs Require Import SymbolicLinking RealFrameLinked LinkedTwelve CensusV2 MWFReal
  SpawnInit ActionValueFrame NoAImpliesNoFlyLinked AGates.
From SM64.Proofs Require NoAImpliesNoFlyTwelve ObjExtBodies.
From SM64.Proofs Require Import Generic.ClosedMem.
From SM64.Proofs Require Import HeightInvariant WMotRWorld FrameSplit.
From SM64.Proofs.WMotRRequiresA Require Import FfWorld AnimData AnimWorld RenderKeep ClearKeep PlatformEff.
From SM64.Proofs.WMotRRequiresA Require ObjWorld PollKeep PlatformKeep BhvVM StartSat StartTerrain HeightFrame WMotREntry.
Import ListNotations.
Local Open Scope Z_scope.

Module OW := ObjWorld.

(* ---------------------------------------------------------------------- *)
(* 1. The carried cells of gMarioStates (offsets from generated mario.v's *)
(*    struct MarioState; field_offsets_pinned pins them).     *)
(*      [4,8)     flags         (init_mario: 0 or 0x11 by the save's cap)  *)
(*      [168,170) numCoins      [170,172) numStars   172 numKeys           *)
(*      173       numLives      [174,176) health     [176,178) unkB0       *)
(*      [184,186) prevNumStarsForDialog                                     *)
(* ---------------------------------------------------------------------- *)
(*    2026-11-14, the rest of census §3 (RenderKeep.carried_rs2):          *)
(*      [0,2) unk00   [8,12) particleFlags   [20,24) terrainSoundAddend    *)
(*      [32,36) intendedMag   [36,38) intendedYaw   43 doubleJumpTimer     *)
(*      [56,58) slideYaw   [58,60) twirlYaw   [108,112) ceilHeight         *)
(*      [116,118) floorAngle   [164,168) collidedObjInteractTypes          *)
(*      181 fadeWarpOpacity   [196,200) gettingBlownGravity                *)
Definition carried_rs : list (Z * Z) := [(4, 8); (168, 178); (184, 186)] ++ carried_rs2.

Definition carried_cell (ch : memory_chunk) (z : Z) : bool :=
  existsb (fun r => (fst r <=? z) && (z + size_chunk ch <=? snd r)) carried_rs.

Lemma carried_cell_spec : forall ch z, carried_cell ch z = true ->
  (4 <= z /\ z + size_chunk ch <= 8) \/ (168 <= z /\ z + size_chunk ch <= 178)
  \/ (184 <= z /\ z + size_chunk ch <= 186)
  \/ (0 <= z /\ z + size_chunk ch <= 2) \/ (8 <= z /\ z + size_chunk ch <= 12)
  \/ (20 <= z /\ z + size_chunk ch <= 24) \/ (32 <= z /\ z + size_chunk ch <= 38)
  \/ (43 <= z /\ z + size_chunk ch <= 44) \/ (56 <= z /\ z + size_chunk ch <= 60)
  \/ (108 <= z /\ z + size_chunk ch <= 112) \/ (116 <= z /\ z + size_chunk ch <= 118)
  \/ (164 <= z /\ z + size_chunk ch <= 168) \/ (181 <= z /\ z + size_chunk ch <= 182)
  \/ (196 <= z /\ z + size_chunk ch <= 200).
Proof.
  intros ch z H. unfold carried_cell, carried_rs, carried_rs2 in H. cbn [app existsb fst snd] in H.
  repeat rewrite orb_true_iff in H. repeat rewrite andb_true_iff in H.
  rewrite !Z.leb_le in H.
  assert (F : false = true -> False) by discriminate. tauto.
Qed.

Lemma field_offsets_pinned :
  map (fun f => match field_offset (prog_comp_env mario.prog) f mario_state_members with
                | Errors.OK (d, _) => d | _ => -1 end)
      [mario._flags; mario._numCoins; mario._numStars; mario._numKeys; mario._numLives;
       mario._health; mario._unkB0; mario._prevNumStarsForDialog;
       mario._unk00; mario._particleFlags; mario._terrainSoundAddend; mario._intendedMag;
       mario._intendedYaw; mario._doubleJumpTimer; mario._slideYaw; mario._twirlYaw;
       mario._ceilHeight; mario._floorAngle; mario._collidedObjInteractTypes;
       mario._fadeWarpOpacity; mario._gettingBlownGravity]
  = [4; 168; 170; 172; 173; 174; 176; 184;
     0; 8; 20; 32; 36; 43; 56; 58; 108; 116; 164; 181; 196].
Proof. vm_compute. reflexivity. Qed.

(* a carried cell is apart from every cell the PhiW carry keeps *)
Lemma carried_bmk : forall ch z ch' z', carried_cell ch z = true -> bmk ch' z' ->
  z' + size_chunk ch' <= z \/ z + size_chunk ch <= z'.
Proof.
  intros ch z ch' z' H (_ & _ & _ & W1 & W2 & W3 & W4).
  pose proof (size_chunk_pos ch'). pose proof (size_chunk_pos ch).
  unfold carried_cell in H. apply existsb_exists in H as (r & Hin & Hr).
  apply andb_prop in Hr as [Hlo Hhi]. apply Z.leb_le in Hlo. apply Z.leb_le in Hhi.
  unfold carried_rs in Hin. apply in_app_or in Hin as [Hin | Hin].
  - cbn [In] in Hin. destruct Hin as [<- | [<- | [<- | []]]]; cbn [fst snd] in Hlo, Hhi; lia.
  - unfold carried_apart2, apart_rs in W4. rewrite forallb_forall in W4. specialize (W4 r Hin).
    apply orb_true_iff in W4. rewrite !Z.leb_le in W4. lia.
Qed.

Lemma carried_window : forall ch z, carried_cell ch z = true -> store_window_ok z (size_chunk ch) = true.
Proof.
  intros ch z H. apply carried_cell_spec in H. pose proof (size_chunk_pos ch) as Hs.
  assert (Mx : 200 <= Ptrofs.max_unsigned) by (vm_compute; intro E; discriminate E).
  unfold store_window_ok.
  repeat rewrite andb_true_iff. repeat rewrite orb_true_iff. rewrite !Z.leb_le, Z.ltb_lt.
  lia.
Qed.

(* ---------------------------------------------------------------------- *)
(* 1b. The act number does not change the entry (census B1, acts 1..6).   *)
(*     level_cmd_place_object places a command iff (mask & val7) or mask *)
(*     = 0x1F; every OBJECT of WMotR's script (the area's and the two     *)
(*     JUMP_LINKed local scripts') has mask 0x1F, its command's byte 2    *)
(*     (big-endian: bits 15..8 of the first word), read off generated/.   *)
(*     So for every act 1..6 the same objects are placed; the act cell    *)
(*     itself is a carried global the start premise does not read         *)
(*     (gstore_carried below).  Act 0 (census B1): the ROM line           *)
(*     `1 << (gCurrActNum - 1)` had no Clight execution; it is now       *)
(*     written `1 << ((gCurrActNum - 1) & 31)`, the ROM's sllv bits       *)
(*     (TRUST 2.2), and act0_val7 below shows it gives val7 = 0, so act 0 *)
(*     too places exactly the mask-0x1F commands, i.e. all of them.       *)
(* ---------------------------------------------------------------------- *)
Definition cmd_mask (c : ident * nat) : Z :=
  let l := if Pos.eqb (fst c) StartTerrain.L_ENT then gvar_init wmotr_script.v_level_wmotr_entry
           else if Pos.eqb (fst c) StartTerrain.L_LOC1 then gvar_init wmotr_script.v_script_func_local_1
           else gvar_init wmotr_script.v_script_func_local_2 in
  match nth_error l (snd c) with
  | Some (Init_int32 h) => Z.land (Z.shiftr (Int.unsigned h) 8) 255
  | _ => -1
  end.

Definition object_cmds : list (ident * nat) :=
  filter (fun c => Z.eqb (StartTerrain.cmd_type c) 36) StartTerrain.cmds_area.

Lemma object_masks : map cmd_mask object_cmds = [31; 31; 31; 31; 31; 31; 31; 31].
Proof. vm_compute. reflexivity. Qed.

(* val7's expression in the generated level_cmd_place_object *)
Definition val7_e : expr :=
  Ecast (Ebinop Oshl (Econst_int (Int.repr 1) tint)
           (Ebinop Oand (Ebinop Osub (Etempvar level_script._t'39 tshort) (Econst_int (Int.repr 1) tint) tint)
              (Econst_int (Int.repr 31) tint) tint) tint) tuchar.

Lemma place_object_val7 : exists rest,
  fn_body level_script.f_level_cmd_place_object =
    Ssequence (Ssequence (Sset level_script._t'39 (Evar level_script._gCurrActNum tshort))
                         (Sset level_script._val7 val7_e)) rest.
Proof. eexists. reflexivity. Qed.

(* at act 0 the rewritten line has an execution, and it is 0 (the ROM's
   sllv: 1 << 31, low byte 0) *)
Lemma act0_val7 : forall ge e le m, le ! level_script._t'39 = Some (Vint Int.zero) ->
  eval_expr ge e le m val7_e (Vint Int.zero).
Proof.
  intros ge e le m H. unfold val7_e.
  eapply eval_Ecast.
  - eapply eval_Ebinop.
    + constructor.
    + eapply eval_Ebinop.
      * eapply eval_Ebinop; [ constructor; exact H | constructor | reflexivity ].
      * constructor.
      * reflexivity.
    + reflexivity.
  - reflexivity.
Qed.

Section CARRY.
  Variable lp : Clight.program.
  Hypothesis H12 : linked12 lp.
  Notation G := (lp_ge lp).
  Variable bm : block.
  Hypothesis Hbm_sym : Genv.find_symbol G level_update._gMarioStates = Some bm.
  Variables (bc : block) (oc0 : ptrofs) (SafeB : block -> Prop).
  Hypothesis HSafeB_syms : SafeB_syms_ok lp SafeB.
  Hypothesis Hbc_sym : Genv.find_symbol G mario._gControllers = Some bc.
  Hypothesis Hoc0 : oc0 = Ptrofs.zero.
  Notation MWF := (MWF_real lp bm bc oc0 SafeB).

  (* the capstone's start premise (HeightFrame.wmotr_noA_height_bound_linked12) *)
  Definition start_premise (m : mem) : Prop :=
    mem_ok_lp bm MWF m /\ phiw lp bm m /\ PlatformKeep.plat_still lp m /\ OW.obj_w G bm m.

  Lemma hsp' : exists init, spawn_ok lp init bm bc oc0.
  Proof. exact (Hsp lp H12 bm Hbm_sym bc oc0 Hbc_sym Hoc0). Qed.

  (* ---- 2. one int store into a carried cell of gMarioStates ---- *)
  (* any non-pointer value: ints, and the float fields' singles *)
  Theorem mstore_keep : forall ch z v m m2, carried_cell ch z = true ->
    (forall b o, v <> Vptr b o) ->
    Mem.store ch m bm z v = Some m2 -> start_premise m -> start_premise m2.
  Proof.
    intros ch z v m m2 Hc Hnp St (Ok & Hphi & Hst & How).
    pose proof (carried_cell_spec ch z Hc) as Hcz.
    assert (LO : forall ch' b z', b <> bm -> Mem.load ch' m2 b z' = Mem.load ch' m b z')
      by (intros ch' b z' Ne; apply (Mem.load_store_other _ _ _ _ _ _ St); left; exact Ne).
    assert (LMd : forall ch' z', z' + size_chunk ch' <= z \/ z + size_chunk ch <= z' ->
              Mem.load ch' m2 bm z' = Mem.load ch' m bm z')
      by (intros ch' z' D; apply (Mem.load_store_other _ _ _ _ _ _ St); right; exact D).
    split.
    { (* mem_ok: a store inside MWF's store window, off the action cell *)
      destruct Ok as (Hv & Hsat & HM). destruct hsp' as (init & Hs).
      split; [ eapply Mem.store_valid_block_1; eauto | split ].
      - eapply action_sat_unchanged_on with (m := m); [ | exact Hv | exact Hsat ].
        eapply Mem.store_unchanged_on; [ exact St | ].
        intros i0 Hi [_ Hi2]. cbn in Hi2. lia.
      - exact (mwf_real_window lp bm bc oc0 SafeB (spawn_Hbc_bm lp init bm bc oc0 Hs)
                 (safeb_not_bm lp init bm bc oc0 SafeB Hs HSafeB_syms)
                 (gms_blk lp init bm bc oc0 SafeB Hs HSafeB_syms)
                 (gtimer_blk lp init bm bc oc0 SafeB Hs HSafeB_syms)
                 (table_blk lp init bm bc oc0 SafeB Hs HSafeB_syms)
                 (ktab_blk lp init bm bc oc0 SafeB Hs HSafeB_syms) m m2 ch z _ HM (carried_window ch z Hc) St). }
    split.
    { (* PhiW: RenderKeep.k_all_w with no global written *)
      pose proof Hphi as (_ & _ & _ & _ & Hf & _).
      pose proof Hf as (Hgn & (d & FWF) & FD).
      pose proof (ff_Lo _ _ _ _ FWF) as Lmo. unfold FFW_OBJ in Lmo.
      assert (HXs : forall id', In id' (@nil ident) -> existsb (Pos.eqb id') core_ids = false)
        by (intros id' []).
      assert (HXl : forall id', In id' (@nil ident) -> existsb (Pos.eqb id') lvl_rd_ids = false)
        by (intros id' []).
      assert (NB : Ple (Mem.nextblock m) (Mem.nextblock m2))
        by (rewrite (Mem.nextblock_store _ _ _ _ _ _ St); apply Ple_refl).
      assert (PM : forall b o k p, Plt b (Mem.nextblock m) -> Mem.perm m b o k p -> Mem.perm m2 b o k p)
        by (intros b o k p _ Hp; exact (Mem.perm_store_1 _ _ _ _ _ _ St _ _ _ _ Hp)).
      assert (LD : forall ch' b z', ~ rgb lp [] b -> b <> bm -> (b <> fw_bo d \/ owin (fw_oo d) ch' z') ->
                Mem.load ch' m2 b z' = Mem.load ch' m b z')
        by (intros ch' b z' _ Nb _; exact (LO _ _ _ Nb)).
      assert (LM : forall ch' z', bmk ch' z' -> Mem.load ch' m2 bm z' = Mem.load ch' m bm z')
        by (intros ch' z' Hk; apply LMd; exact (carried_bmk ch z ch' z' Hc Hk)).
      assert (Nr : ~ rgb lp [] bm) by (intros (id' & [] & _)).
      assert (Bmb : bm <> fw_bo d) by exact (not_eq_sym (ff_D1 _ _ _ _ FWF)).
      assert (RGa : forall b, rgb lp [] b -> b <> fw_bo d /\ tab_apart G m b)
        by (intros b (id' & [] & _)).
      assert (CL : forall gp0, closed_by gp0 m -> gp0 (fw_bo d) <> None ->
                (forall id0 b, Genv.find_symbol G id0 = Some b -> gp0 b <> None) ->
                exists gp', (forall b, gp0 b <> None -> gp' b <> None) /\ closed_by gp' m2).
      { intros gp0 HC0 _ HS0. exists gp0. split; [ intros b H; exact H | ].
        exact (store_mapped_closed gp0 m ch bm z v m2 HC0 (flat_bg gp0 m bm HC0 (HS0 _ _ Hbm_sym))
                 (inj_nonptr gp0 _ Hnp) St). }
      assert (FR : forall bt0 ot0 k0, In k0 hs_ids ->
                Mem.load Mint32 m (fw_bo d) (Ptrofs.unsigned (fw_oo d) + 60) = Some (Vptr bt0 ot0) ->
                Mem.load Mint32 m (fw_bo d) (Ptrofs.unsigned (fw_oo d) + 72) = Some (Vint Int.zero) ->
                (exists f, -1 <= f <= hs_le k0
                   /\ Mem.load Mint16signed m (fw_bo d) (Ptrofs.unsigned (fw_oo d) + 64) = Some (Vint (Int.repr f))) ->
                buf_ok m bt0 ot0 k0 -> Ptrofs.unsigned ot0 + BUFSZ < Ptrofs.modulus ->
                exists f, -1 <= f <= hs_le k0
                  /\ Mem.load Mint16signed m2 (fw_bo d) (Ptrofs.unsigned (fw_oo d) + 64) = Some (Vint (Int.repr f))).
      { intros bt0 ot0 k0 _ _ _ (f & Rf & L64) _ _. exists f. split; [ exact Rf | ].
        rewrite (LO _ _ _ (not_eq_sym Bmb)). exact L64. }
      exact (k_all_w lp bm [] HXs HXl m m2 (fw_bo d) (fw_oo d) Lmo NB PM LD LM Hbm_sym Nr Bmb RGa CL FR Hphi
               (phiw_surf_apart lp bm _ m Hphi)). }
    split.
    { (* plat_still: gMarioPlatform and an object slot, neither gMarioStates *)
      destruct (PlatformKeep.plat_p_sym lp H12) as (bgp & Hgp).
      assert (Ngp : bgp <> bm) by exact (symne_b G _ _ _ _ Hbm_sym Hgp ltac:(vm_compute; reflexivity)).
      intros bp v' Hbp Hl0. rewrite Hgp in Hbp. injection Hbp as <-.
      rewrite (LO _ _ _ Ngp) in Hl0.
      destruct (Hst bgp v' Hgp Hl0) as [Hz | (pb & po & -> & Hpb & Hk & Hal)]; [ left; exact Hz | right ].
      assert (Npb : pb <> bm) by exact (symne_b G _ _ _ _ Hbm_sym Hpb ltac:(vm_compute; reflexivity)).
      exists pb, po. split; [ reflexivity | split; [ exact Hpb | split; [ | exact Hal ] ] ].
      intros k Hk0. cbn [Mem.loadv] in *. rewrite (LO _ _ _ Npb). exact (Hk k Hk0). }
    (* obj_w: off its globals, the dynamic blocks, Mario's object-pointer
       cells and the scripts *)
    apply (PollKeep.obj_w_unch m m2 G bm); [ | | | | exact How ].
    - intros id b Hin Hs ch' z'. apply LO.
      exact (symne_b G _ _ _ _ Hbm_sym Hs
               (eqb_of_notin level_update._gMarioStates PollKeep.ow_ids id ltac:(vm_compute; reflexivity) Hin)).
    - intros b Hb ch' z'. apply LO. exact (glob_ne_dyn G _ _ b Hbm_sym Hb).
    - intros z' Hz'. apply LMd. cbn in Hz'. unfold MARIOOBJ_OFF in Hz'. cbn.
      destruct Hz' as [-> | Hz']; [ lia | ].
      repeat (destruct Hz' as [<- | Hz']; [ lia | ]). destruct Hz'.
    - intros s b Hin Hs ch' z'. apply LO.
      exact (symne_b G _ _ _ _ Hbm_sym Hs
               (eqb_of_notin level_update._gMarioStates (map BhvVM.v_s BhvVM.vm_tab) s
                  ltac:(vm_compute; reflexivity) Hin)).
  Qed.

  (* ---- 3. one int store into a carried global (no invariant reads it) ---- *)
  (* the act number, the save-file slot and buffer, the RNG and the
     clocks: read by the entry (B1-B6) or by later frames, never by the
     start premise *)
  Definition carried_gids : list ident :=
    [level_update._gCurrActNum; level_update._gCurrSaveFileNum; level_update._gCurrCourseStarFlags;
     (* 2026-11-14, census §4: the save buffer (B2-B6: cap, cannon, wing-cap
        switch, star flags), the RNG seed, the area clock, the camera mode
        (R button), and the castle / menu flags *)
     save_file._gSaveBuffer; behavior_script._gRandomSeed16; area._gAreaUpdateCounter;
     camera._sSelectionFlags; level_update._gNeverEnteredCastle; level_update._gHudDisplay;
     save_file._gSaveFileModified; save_file._gMainMenuDataModified;
     save_file._gLastCompletedCourseNum; save_file._gLastCompletedStarNum;
     save_file._gSpecialTripleJump].

  Lemma carried_gids_ok : forallb (fun id => gs_ok id
      && negb (existsb (Pos.eqb id) PollKeep.ow_ids)
      && negb (existsb (Pos.eqb id) (map BhvVM.v_s BhvVM.vm_tab))) carried_gids = true.
  Proof. vm_compute. reflexivity. Qed.

  (* a_down_real is a consequence of the premise: m->controller is
     &gControllers[0] (MWF R2, ffw) and its buttonDown has A clear (ctl_w) *)
  Lemma dm_pads : (prog_defmap game_init.prog) ! game_init._gControllerPads
                   = Some (Gvar game_init.v_gControllerPads).
  Proof. vm_compute. reflexivity. Qed.

  Lemma adown_of : forall m, start_premise m -> a_down_real bm m = false.
  Proof.
    intros m (Ok & Hphi & _ & _).
    pose proof Hphi as (_ & _ & _ & _ & Hf & _ & _ & Hl).
    pose proof Hf as (_ & (d & FWF) & _).
    pose proof Ok as (_ & _ & HM). pose proof HM as (_ & _ & R2 & _).
    pose proof (ff_Lc _ _ _ _ FWF) as Lc.
    destruct (ff_Wc _ _ _ _ FWF) as (b & o & Ev & _).
    unfold FFW_CTL in Lc. rewrite Ev in Lc.
    assert (Lc' : Mem.load Mptr m bm 156 = Some (Vptr b o)) by exact Lc.
    destruct (R2 _ _ Lc') as (-> & ->). subst oc0.
    destruct (linkorder_resolves_symbol lp game_init.prog game_init._gControllerPads _
                (StartSat.LO_gi lp H12) dm_pads) as (bp & Hbp).
    pose proof Hl as (_ & _ & _ & Hctl & _).
    destruct (Hctl bc bp Hbc_sym Hbp) as (_ & H16 & _).
    destruct (H16 16 (or_introl eq_refl)) as (v & Lv & Av).
    unfold a_down_real. rewrite Lc'.
    change (Ptrofs.unsigned (Ptrofs.add Ptrofs.zero (Ptrofs.repr 16))) with 16.
    rewrite Lv, Av. reflexivity.
  Qed.

  Theorem gstore_carried : forall id bg ch z i m m2, In id carried_gids ->
    Genv.find_symbol G id = Some bg -> Mem.store ch m bg z (Vint i) = Some m2 ->
    start_premise m -> start_premise m2.
  Proof.
    intros id bg ch z i m m2 Hin Hs St (Ok & Hphi & Hst & How).
    pose proof carried_gids_ok as K. rewrite forallb_forall in K. specialize (K id Hin).
    apply andb_prop in K as [K Ksc]. apply andb_prop in K as [Hok Hw].
    apply negb_true_iff in Hw. apply negb_true_iff in Ksc.
    assert (HD : a_down_real bm m = false) by exact (adown_of m (conj Ok (conj Hphi (conj Hst How)))).
    pose proof (gstore_keep lp H12 bm Hbm_sym bc oc0 SafeB Hbc_sym Hoc0 id bg ch z i m m2
                  Hs Hok Hw Ksc St (conj Ok (conj Hphi (conj HD (conj Hst How))))) as (Ok2 & Hphi2 & _ & Hst2 & How2).
    exact (conj Ok2 (conj Hphi2 (conj Hst2 How2))).
  Qed.

  (* ---- 3b. m->input (2026-11-25): one u16 store into bytes [2,4) ---- *)
  (* m->input is carried from the castle's last frame (census §3).  It sits
     in MWF's protected window, and PhiW reads it (ffw's ff_Li / ff_Ai), so
     mstore_keep does not apply: the store lemma below re-establishes MWF R1
     (mwf_real_input) and rebuilds ffw with the new value.  The value may be
     any u16 with INPUT_A_PRESSED | INPUT_A_DOWN | INPUT_INTERACT_OBJ_GRABBABLE
     (0x882) clear: exactly what the frame-boundary invariant reads. *)
  Lemma and2178_zero_ext16 : forall y,
    Int.and (Int.zero_ext 16 y) (Int.repr 2178) = Int.and y (Int.repr 2178).
  Proof.
    intro y. rewrite Int.zero_ext_and by lia. rewrite Int.and_assoc.
    assert (E : Int.eq (Int.and (Int.repr (two_p 16 - 1)) (Int.repr 2178)) (Int.repr 2178) = true)
      by (vm_compute; reflexivity).
    apply Int.same_if_eq in E. rewrite E. reflexivity.
  Qed.

  Lemma and2_of_2178 : forall y, Int.and y (Int.repr 2178) = Int.zero -> Int.and y (Int.repr 2) = Int.zero.
  Proof.
    intros y H.
    replace (Int.repr 2) with (Int.and (Int.repr 2178) (Int.repr 2)) by (vm_compute; reflexivity).
    rewrite <- Int.and_assoc, H. apply Int.and_zero_l.
  Qed.

  Section INP.
    Variables (i : int) (m m2 : mem).
    Hypothesis Hi : Int.and i (Int.repr 2178) = Int.zero.
    Hypothesis St : Mem.store Mint16unsigned m bm 2 (Vint i) = Some m2.

    Lemma LO : forall ch b z, b <> bm -> Mem.load ch m2 b z = Mem.load ch m b z.
    Proof. intros ch b z Ne. apply (Mem.load_store_other _ _ _ _ _ _ St). left. exact Ne. Qed.

    Lemma LMd : forall ch z, z + size_chunk ch <= 2 \/ 4 <= z -> Mem.load ch m2 bm z = Mem.load ch m bm z.
    Proof. intros ch z D. apply (Mem.load_store_other _ _ _ _ _ _ St). right. cbn [size_chunk]. exact D. Qed.

    Lemma Hnb : Ple (Mem.nextblock m) (Mem.nextblock m2).
    Proof. rewrite (Mem.nextblock_store _ _ _ _ _ _ St). apply Ple_refl. Qed.

    Lemma Hperm : forall b o k p, Plt b (Mem.nextblock m) -> Mem.perm m b o k p -> Mem.perm m2 b o k p.
    Proof. intros b o k p _ Hp. exact (Mem.perm_store_1 _ _ _ _ _ _ St _ _ _ _ Hp). Qed.

    Lemma Li2 : Mem.load Mint16unsigned m2 bm 2 = Some (Vint (Int.zero_ext 16 i)).
    Proof. rewrite (Mem.load_store_same _ _ _ _ _ _ St). reflexivity. Qed.

    Lemma Ai2 : Int.and (Int.zero_ext 16 i) (Int.repr 2178) = Int.zero.
    Proof. rewrite and2178_zero_ext16. exact Hi. Qed.

    Lemma bm_glob : Plt bm (Genv.genv_next G).
    Proof. exact (Genv.genv_symb_range _ _ Hbm_sym). Qed.

    Ltac offt := unfold OFS_ACTION, OFS_ASTATE, OFS_ATIMER, OFS_POSY, OFS_VELY, OFS_FLOORH, OFS_MARIOOBJ,
                   FFW_OBJ, FFW_ANIM, FFW_AREA, FFW_CTL, FFW_PCS, FFW_BODY, FFW_FLOOR, FFW_WALL, FFW_CEIL,
                   WALL_OFF, CEIL_OFF, FLOOR_OFF, HELD_OFF, RIDDEN_OFF, QSD_OFF, MARIOOBJ_OFF, USED_OFF in *;
                 try unfold Mptr in *; cbv [Archi.ptr64] in *; cbn [size_chunk] in *; lia.

    Section PH.
      Hypothesis Hf : ffw G bm m.

      Lemma Hmb : forall mb mo, Mem.load Mint32 m bm 136 = Some (Vptr mb mo) -> mb <> bm.
      Proof.
        intros mb mo L. destruct Hf as (_ & (d & F) & _).
        pose proof (ff_Lo _ _ _ _ F) as Lo. unfold FFW_OBJ in Lo. rewrite Lo in L.
        injection L as <- _. exact (ff_D1 _ _ _ _ F).
      Qed.

      Lemma i_hi : forall R, height_invariant bm R m -> height_invariant bm R m2.
      Proof.
        intros R (A & c & (H1 & H2 & H3 & H4 & H5 & H6 & bo & oo & H7 & H8) & Hb).
        split; [ intros v L; rewrite LMd in L by offt; exact (A v L) | ].
        exists c. split; [ | exact Hb ].
        unfold read_cells. rewrite !LMd by offt.
        split; [ exact H1 | split; [ exact H2 | split; [ exact H3 | split; [ exact H4 | split; [ exact H5 | split; [ exact H6 | ] ] ] ] ] ].
        exists bo, oo. split; [ exact H7 | ].
        assert (H7' : Mem.load Mint32 m bm 136 = Some (Vptr bo oo)) by exact H7.
        rewrite (LO _ _ _ (Hmb _ _ H7')). exact H8.
      Qed.

      Lemma surf_k : forall sv, (forall sb so, sv = Vptr sb so -> sb <> bm) -> surface_ok m sv -> surface_ok m2 sv.
      Proof.
        intros sv Hn [Hz | (x & o & t & -> & Hl & Hin)]; [ left; exact Hz | right ].
        exists x, o, t. rewrite (LO _ _ _ (Hn x o eq_refl)). exact (conj eq_refl (conj Hl Hin)).
      Qed.

      Lemma coll_k : forall cv, (forall cb co, cv = Vptr cb co -> cb <> bm) -> coll_obj_ok m cv -> coll_obj_ok m2 cv.
      Proof.
        intros cv Hn (x & o & t & -> & Hl & Hin & Hp & Hcn). pose proof (Hn x o eq_refl) as M.
        exists x, o, t. split; [ reflexivity | ]. rewrite (LO _ _ _ M). split; [ exact Hl | ]. split; [ exact Hin | ]. split.
        - intros Ht. destruct (Hp Ht) as (base & top & Hb & K1 & K2 & K3). exists base, top. rewrite !(LO _ x _ M). tauto.
        - intros Ht. destruct (Hcn Ht) as (y & Hy & K1). exists y. rewrite (LO _ x _ M). tauto.
      Qed.

      Lemma i_ww : wmotr_world bm m -> wmotr_world bm m2.
      Proof.
        intros (W1 & W2 & W3 & W4 & W5 & W6 & (mb & mo & s & n & L1 & L2 & L3 & L4 & L5 & L6)).
        pose proof Hf as (_ & (d & F) & _).
        pose proof (Hmb _ _ L1) as Nmb.
        split; [ | split; [ | split; [ | split; [ | split; [ | split ] ] ] ] ].
        - exact I.
        - exact I.
        - intros v L. rewrite LMd in L by offt. apply (surf_k v); [ | exact (W3 v L) ].
          intros sb so -> ->. change FLOOR_OFF with FFW_FLOOR in L.
          pose proof (ff_Spl _ _ _ _ F bm so L) as P. pose proof bm_glob as Q. unfold Plt, Ple in *. lia.
        - rewrite LMd by offt. exact W4.
        - rewrite LMd by offt. exact W5.
        - rewrite LMd by offt. exact W6.
        - exists mb, mo, s, n. rewrite LMd by offt. rewrite !(LO _ mb _ Nmb).
          split; [ exact L1 | split; [ exact L2 | split; [ exact L3 | split; [ exact L4 | split; [ exact L5 | ] ] ] ] ].
          intros j v Hj L. rewrite (LO _ _ _ Nmb) in L. apply (coll_k v); [ | exact (L6 j v Hj L) ].
          intros cb co ->.
          pose proof (ff_Lo _ _ _ _ F) as Lo. unfold FFW_OBJ in Lo. unfold MARIOOBJ_OFF in L1. rewrite Lo in L1. injection L1 as Eb Eo.
          subst mb mo.
          assert (Hj4 : 0 <= j < 4) by lia.
          change COLL_OFF with FFW_COLL in L.
          rewrite (ff_Co _ _ _ _ F j cb co Hj4 L). exact Nmb.
      Qed.

      Lemma i_aa : FrameSplit.anim_apart lp bm m -> FrameSplit.anim_apart lp bm m2.
      Proof.
        intros Han ab bt ot Hs Hl.
        assert (Nab : ab <> bm) by exact (symne_b G _ _ _ _ Hbm_sym Hs ltac:(vm_compute; reflexivity)).
        rewrite (LO _ _ _ Nab) in Hl.
        destruct (Han ab bt ot Hs Hl) as (A1 & A2). split.
        - intros off sb so Hoff Hl'. rewrite LMd in Hl' by offt. exact (A1 off sb so Hoff Hl').
        - intros mb mo j cb co Hl' Hj Hl2. rewrite LMd in Hl' by offt.
          rewrite (LO _ _ _ (Hmb mb mo Hl')) in Hl2. exact (A2 mb mo j cb co Hl' Hj Hl2).
      Qed.

      Lemma i_ma : mobj_apart bm m -> mobj_apart bm m2.
      Proof.
        intros A mb mo L. rewrite LMd in L by offt. destruct (A mb mo L) as (A1 & A2 & A3).
        split; [ exact A1 | split ].
        - intros off sb so Hoff L2. rewrite LMd in L2 by offt. exact (A2 off sb so Hoff L2).
        - intros j cb co Hj L2. rewrite (LO _ _ _ (Hmb mb mo L)) in L2. exact (A3 j cb co Hj L2).
      Qed.

      Lemma i_uo : used_ok bm m -> used_ok bm m2.
      Proof.
        apply used_ok_keep.
        - intros o ch Hin. cbn [In] in Hin.
          destruct Hin as [E | [E | [E | [E | []]]]]; injection E as <- <-; apply LMd; offt.
        - intros ub uo _ A z _. apply LO. exact (proj1 A).
        - intros mb mo L. apply LO. exact (Hmb mb mo L).
        - intros mb mo L j _. apply LO. exact (Hmb mb mo L).
      Qed.

      Lemma i_lw : lvl_w G m -> lvl_w G m2.
      Proof.
        intros LW. apply (lvl_w_unch G m m2); [ | | exact LW ].
        - intros b ch z Hb. apply LO.
          exact (lvl_rd_not_sym G m b _ bm LW (or_introl Hb) Hbm_sym ltac:(vm_compute; reflexivity)).
        - intros ab Hs. apply LO. exact (symne_b G _ _ _ _ Hbm_sym Hs ltac:(vm_compute; reflexivity)).
      Qed.

      (* the frame world: rebuilt with m->input's new value *)
      Section FF.
        Variable d : ffw_wit.
        Hypothesis F : ffw_facts G bm m d.

        Lemma Hld2 : forall ch b z, Plt b (Mem.nextblock m) -> ~ FloorExec.rblk (ff_rl_of bm d) b ->
          Mem.load ch m2 b z = Mem.load ch m b z.
        Proof. intros ch b z _ Nr. apply LO. intros ->. exact (Nr (ffw_rl_bm bm d)). Qed.

        Lemma W2 : FloorExec.Wff G m2 (fw_gp d) SZ_SURFACE (ff_rl_of bm d).
        Proof. exact (Wff_keep2 G m m2 _ Hnb Hperm Hld2 _ _ (fun b H => H) (ff_W _ _ _ _ F)). Qed.

        Lemma FD2 : AirMatch.floor_data G m -> AirMatch.floor_data G m2.
        Proof. exact (floor_data_keep2 G m m2 _ Hnb Hperm Hld2 _ (ff_W _ _ _ _ F)). Qed.

        Lemma HC2 : closed_by (fw_gp d) m2.
        Proof.
          exact (store_mapped_closed (fw_gp d) m Mint16unsigned bm 2 (Vint i) m2 (ff_HC _ _ _ _ F)
                   (flat_bg (fw_gp d) m bm (ff_HC _ _ _ _ F) (ff_HM _ _ _ _ F)) (inj_nonptr (fw_gp d) _ (vint_np i)) St).
        Qed.

        Lemma i_facts : ffw_facts G bm m2
          (mk_ffw_wit (fw_gp d) (fw_bfi d) (fw_bmiss d) (fw_bcalls d) (fw_bsin d) (fw_ab d) (fw_biom d)
             (fw_bmq d) (fw_brm d) (fw_blk d) (fw_bpc d) (fw_bsr d) (fw_bsrc d) (fw_bsms d) (fw_bbs d)
             (fw_bfa d) (fw_bo d) (fw_oo d) (fw_bt d) (fw_ot d) (fw_fl d) (fw_ar d) (Int.zero_ext 16 i) (fw_ctl d)).
        Proof.
          assert (Nbo : fw_bo d <> bm) by exact (ff_D1 _ _ _ _ F).
          assert (Nab : fw_ab d <> bm)
            by exact (symne_b G _ _ _ _ Hbm_sym (ff_S5 _ _ _ _ F) ltac:(vm_compute; reflexivity)).
          pose proof W2 as W2'. pose proof HC2 as HC2'. pose proof Li2 as Li2'. pose proof Ai2 as Ai2'.
          pose proof Hnb as Hnb'.
          pose proof F as F0. destruct F0.
          eapply mk_ffw_facts; ffw_simpl;
            first [ exact Li2' | exact Ai2' | assumption | exact HC2' | exact W2'
                  | (eapply wfl_mono; [ exact Hnb' | eassumption ])
                  | apply (wblk_mono _ _ _ _ _ Hnb'); assumption
                  | rewrite LMd by offt; assumption
                  | rewrite (LO _ _ _ Nbo); assumption
                  | rewrite (LO _ _ _ Nab); assumption
                  | let sb := fresh "sb" in let so := fresh "so" in let Hl := fresh "Hl" in
                    intros sb so Hl; rewrite LMd in Hl by offt;
                    match goal with H : forall sb' so', Mem.load _ m _ _ = _ -> _ |- _ => exact (H _ _ Hl) end
                  | let j := fresh "j" in let cb := fresh "cb" in let co := fresh "co" in
                    let Hj := fresh "Hj" in let Hl := fresh "Hl" in
                    intros j cb co Hj Hl; rewrite (LO _ _ _ Nbo) in Hl;
                    match goal with H : forall j' cb' co', 0 <= j' < 4 -> _ -> _ |- _ => exact (H j cb co Hj Hl) end ].
        Qed.
      End FF.

      Lemma i_ffw : ffw G bm m2.
      Proof.
        destruct Hf as (Hgn & (d & F) & FD).
        split; [ exact (Ple_trans _ _ _ Hgn Hnb) | ].
        split; [ exists (mk_ffw_wit (fw_gp d) (fw_bfi d) (fw_bmiss d) (fw_bcalls d) (fw_bsin d) (fw_ab d) (fw_biom d)
             (fw_bmq d) (fw_brm d) (fw_blk d) (fw_bpc d) (fw_bsr d) (fw_bsrc d) (fw_bsms d) (fw_bbs d)
             (fw_bfa d) (fw_bo d) (fw_oo d) (fw_bt d) (fw_ot d) (fw_fl d) (fw_ar d) (Int.zero_ext 16 i) (fw_ctl d));
                 exact (i_facts d F) | ].
        exact (FD2 d F FD).
      Qed.

      Lemma i_aw : AnimWorld.anim_w G bm m -> AnimWorld.anim_w G bm m2.
      Proof.
        intros (ab & bga & bauc & btab & otab & bt & ot & mb & mo & B & ST).
        pose proof Hf as (_ & (d & F) & _).
        destruct B as (S1 & S2 & S3 & L0 & L8 & Lm & Sy & D1 & D2 & D3 & D4 & (D5 & RG) & Z1 & Z2 & Z3 & P & T & GA & TA & AC & SM).
        assert (Nab : ab <> bm) by exact (symne_b G _ _ _ _ Hbm_sym S1 ltac:(vm_compute; reflexivity)).
        assert (Nga : bga <> bm) by exact (symne_b G _ _ _ _ Hbm_sym S2 ltac:(vm_compute; reflexivity)).
        assert (Ntab : btab <> bm) by exact (not_eq_sym (proj1 (Sy _ _ Hbm_sym))).
        assert (Nbt : bt <> bm) by exact (not_eq_sym (proj2 (Sy _ _ Hbm_sym))).
        assert (Nmb : mb <> bm) by exact (Hmb mb mo Lm).
        exists ab, bga, bauc, btab, otab, bt, ot, mb, mo. split.
        - refine (conj S1 (conj S2 (conj S3 (conj _ (conj _ (conj _ (conj Sy (conj D1 (conj D2 (conj D3 (conj D4
                 (conj (conj D5 _) (conj Z1 (conj Z2 (conj Z3 (conj _ (conj _ (conj _ (conj _ (conj _ SM)))))))))))))))))))).
          + rewrite (LO _ _ _ Nab). exact L0.
          + rewrite (LO _ _ _ Nab). exact L8.
          + rewrite LMd by offt. exact Lm.
          + intros id b Hin Hs. destruct (RG id b Hin Hs) as (Ne & _). split; [ exact Ne | ].
            exact (tab_apart_global G m2 _ _ _ b (Genv.genv_symb_range _ _ Hs) (W2 d F)).
          + intros j Hj. exact (Mem.perm_store_1 _ _ _ _ _ _ St _ _ _ _ (P j Hj)).
          + destruct T as (T1 & T2 & T3). unfold tab_ok. rewrite !(LO _ _ _ Ntab).
            refine (conj T1 (conj T2 _)). intros j o s' Hj. rewrite !(LO _ _ _ Ntab). exact (T3 j o s' Hj).
          + destruct GA as (G1 & G2). split.
            * intros o ch z Hin. rewrite (LO _ _ _ Nga). exact (G1 o ch z Hin).
            * intros j Hj. exact (Mem.perm_store_1 _ _ _ _ _ _ St _ _ _ _ (G2 j Hj)).
          + apply (tab_apart_keep G m m2 (fw_gp d) (ff_rl_of bm d) btab (ff_W _ _ _ _ F)); [ | exact TA | exact Hnb | exact Hperm | exact (Hld2 d) ].
            intros id bp _ Hs. exact (proj1 (Sy _ _ Hs)).
          + intros off b o Hoff Hl. apply (AC off b o Hoff). rewrite LMd in Hl by offt. exact Hl.
        - intros a La Ia. rewrite LMd in La by offt.
          eapply anim_st_keep; [ exact (ST a La Ia) | exact (LO _ _ _ Nab) | | ].
          + intros o ch _. exact (LO _ _ _ Nmb).
          + intros k rel ch v _ _. exact (LO _ _ _ Nbt).
      Qed.
    End PH.

    Lemma i_phiw : phiw lp bm m -> phiw lp bm m2.
    Proof.
      intros (Hh & Hw & Han & Hmo & Hf & Hu & Haw & Hl).
      exact (conj (i_hi Hf _ Hh) (conj (i_ww Hf Hw) (conj (i_aa Hf Han) (conj (i_ma Hf Hmo)
              (conj (i_ffw Hf) (conj (i_uo Hf Hu) (conj (i_aw Hf Haw) (i_lw Hl)))))))).
    Qed.

    Theorem istore_keep : start_premise m -> start_premise m2.
    Proof.
      intros (Ok & Hphi & Hst & How).
      split.
      { destruct Ok as (Hv & Hsat & HM). destruct hsp' as (init & Hs).
        split; [ eapply Mem.store_valid_block_1; eauto | split ].
        - eapply action_sat_unchanged_on with (m := m); [ | exact Hv | exact Hsat ].
          eapply Mem.store_unchanged_on; [ exact St | ].
          intros i0 Hi0 [_ Hi2]. cbn [size_chunk] in Hi0, Hi2. lia.
        - exact (mwf_real_input lp bm bc oc0 SafeB (spawn_Hbc_bm lp init bm bc oc0 Hs)
                   (safeb_not_bm lp init bm bc oc0 SafeB Hs HSafeB_syms)
                   (gms_blk lp init bm bc oc0 SafeB Hs HSafeB_syms)
                   (gtimer_blk lp init bm bc oc0 SafeB Hs HSafeB_syms)
                   (table_blk lp init bm bc oc0 SafeB Hs HSafeB_syms)
                   (ktab_blk lp init bm bc oc0 SafeB Hs HSafeB_syms) m m2 i HM (and2_of_2178 i Hi) St). }
      split; [ exact (i_phiw Hphi) | ].
      split.
      { (* plat_still: gMarioPlatform and an object slot, neither gMarioStates *)
        destruct (PlatformKeep.plat_p_sym lp H12) as (bgp & Hgp).
        assert (Ngp : bgp <> bm) by exact (symne_b G _ _ _ _ Hbm_sym Hgp ltac:(vm_compute; reflexivity)).
        intros bp v' Hbp Hl0. rewrite Hgp in Hbp. injection Hbp as <-.
        rewrite (LO _ _ _ Ngp) in Hl0.
        destruct (Hst bgp v' Hgp Hl0) as [Hz | (pb & po & -> & Hpb & Hk & Hal)]; [ left; exact Hz | right ].
        assert (Npb : pb <> bm) by exact (symne_b G _ _ _ _ Hbm_sym Hpb ltac:(vm_compute; reflexivity)).
        exists pb, po. split; [ reflexivity | split; [ exact Hpb | split; [ | exact Hal ] ] ].
        intros k Hk0. cbn [Mem.loadv] in *. rewrite (LO _ _ _ Npb). exact (Hk k Hk0). }
      (* obj_w: off its globals, the dynamic blocks, Mario's object-pointer
         cells and the scripts *)
      apply (PollKeep.obj_w_unch m m2 G bm); [ | | | | exact How ].
      - intros id b Hin Hs ch' z'. apply LO.
        exact (symne_b G _ _ _ _ Hbm_sym Hs
                 (eqb_of_notin level_update._gMarioStates PollKeep.ow_ids id ltac:(vm_compute; reflexivity) Hin)).
      - intros b Hb ch' z'. apply LO. exact (glob_ne_dyn G _ _ b Hbm_sym Hb).
      - intros z' Hz'. apply LMd. cbn in Hz'. unfold MARIOOBJ_OFF in Hz'.
        destruct Hz' as [-> | Hz']; [ cbn [size_chunk]; lia | ].
        repeat (destruct Hz' as [<- | Hz']; [ cbn [size_chunk]; lia | ]). destruct Hz'.
      - intros s b Hin Hs ch' z'. apply LO.
        exact (symne_b G _ _ _ _ Hbm_sym Hs
                 (eqb_of_notin level_update._gMarioStates (map BhvVM.v_s BhvVM.vm_tab) s
                    ltac:(vm_compute; reflexivity) Hin)).
    Qed.
  End INP.
End CARRY.

(* ---------------------------------------------------------------------- *)
(* 4. Any sequence of carried writes keeps the premise.                   *)
(* ---------------------------------------------------------------------- *)
Inductive carried_step (lp : Clight.program) (bm : block) : mem -> mem -> Prop :=
  | cs_mario : forall ch z v m m2, carried_cell ch z = true ->
      (forall b o, v <> Vptr b o) ->
      Mem.store ch m bm z v = Some m2 -> carried_step lp bm m m2
  | cs_glob : forall id bg ch z i m m2, In id carried_gids ->
      Genv.find_symbol (lp_ge lp) id = Some bg -> Mem.store ch m bg z (Vint i) = Some m2 ->
      carried_step lp bm m m2
  (* 2026-11-25: m->input, any u16 with the 0x882 bits clear *)
  | cs_input : forall i m m2, Int.and i (Int.repr 2178) = Int.zero ->
      Mem.store Mint16unsigned m bm 2 (Vint i) = Some m2 -> carried_step lp bm m m2.

Inductive carried (lp : Clight.program) (bm : block) : mem -> mem -> Prop :=
  | cr_refl : forall m, carried lp bm m m
  | cr_step : forall m1 m2 m3, carried_step lp bm m1 m2 -> carried lp bm m2 m3 -> carried lp bm m1 m3.

Theorem carried_keep : forall lp, linked12 lp -> forall bm bc SafeB,
    Genv.find_symbol (lp_ge lp) level_update._gMarioStates = Some bm ->
    Genv.find_symbol (lp_ge lp) mario._gControllers = Some bc ->
    SafeB_syms_ok lp SafeB ->
    forall m m', carried lp bm m m' ->
      start_premise lp bm bc Ptrofs.zero SafeB m -> start_premise lp bm bc Ptrofs.zero SafeB m'.
Proof.
  intros lp H12 bm bc SafeB Hbm Hbc Hsy m m' Hc. induction Hc as [m | m1 m2 m3 Hs _ IH]; [ tauto | ].
  intros P. apply IH.
  destruct Hs as [ch z v m m2' Hcc Hnp St | id bg ch z i m m2' Hin Hg St | i m m2' Hi St].
  - exact (mstore_keep lp H12 bm Hbm bc Ptrofs.zero SafeB Hsy Hbc eq_refl ch z v m m2' Hcc Hnp St P).
  - exact (gstore_carried lp H12 bm Hbm bc Ptrofs.zero SafeB Hbc eq_refl id bg ch z i m m2' Hin Hg St P).
  - exact (istore_keep lp H12 bm Hbm bc Ptrofs.zero SafeB Hsy Hbc eq_refl i m m2' Hi St P).
Qed.

(* ====================================================================== *)
(* THE COVERAGE GUARD: the real-entry witness of StartSat, with ANY       *)
(* values in the carried cells (Mario's cap flags, coins, stars, keys,    *)
(* lives, health, the dialog counters; the act number, the save slot,     *)
(* the course's star flags; since 2026-11-25 m->input, any u16 with       *)
(* 0x882 clear), meets the capstone's start premise.                      *)
(* ====================================================================== *)
Theorem goal2_start_carried : forall lp, linked12 lp ->
  exists m bm bc SafeB,
    Genv.find_symbol (lp_ge lp) level_update._gMarioStates = Some bm
    /\ Genv.find_symbol (lp_ge lp) mario._gControllers = Some bc
    /\ SafeB_syms_ok lp SafeB
    /\ HeightFrame.in_wmotr lp m
    /\ read_cells bm m (WMotREntry.entry_cells StartTerrain.ENTRY_FH)
    /\ forall m', carried lp bm m m' ->
         mem_ok_lp bm (MWF_real lp bm bc Ptrofs.zero SafeB) m' /\ phiw lp bm m'
         /\ PlatformKeep.plat_still lp m' /\ ObjWorld.obj_w (lp_ge lp) bm m'.
Proof.
  intros lp H12.
  destruct (StartSat.goal2_start_sat lp H12)
    as (m & bm & bc & SafeB & Hbm & Hbc & Hsy & Hok & Hphi & Hpl & Hrc & Hw & _ & _ & _ & How & _).
  exists m, bm, bc, SafeB.
  refine (conj Hbm (conj Hbc (conj Hsy (conj Hw (conj Hrc _))))).
  intros m' Hc.
  exact (carried_keep lp H12 bm bc SafeB Hbm Hbc Hsy m m' Hc (conj Hok (conj Hphi (conj Hpl How)))).
Qed.
