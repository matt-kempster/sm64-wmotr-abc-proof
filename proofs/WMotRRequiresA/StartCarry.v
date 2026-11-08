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
(* Not covered here (census §3 / §4, open): m->wall / m->ceil (stale     *)
(* castle pointers; approved restatement, next), the castle's residue in *)
(* free object / pool slots, the anim buffer's block (S7), act 0 (B1     *)
(* FOUND, decision pending), and m->input (A bits: the ABC premise).      *)
(* ====================================================================== *)
From Coq Require Import ZArith Lia List Bool.
From compcert Require Import Coqlib Integers Floats Values AST Ctypes Clight Memory Maps Globalenvs.
From SM64.Generated Require level_update mario object_list_processor area platform_displacement
  sound_init game_init wmotr_script.
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
Definition carried_cell (ch : memory_chunk) (z : Z) : bool :=
  ((4 <=? z) && (z + size_chunk ch <=? 8))
  || ((168 <=? z) && (z + size_chunk ch <=? 178))
  || ((184 <=? z) && (z + size_chunk ch <=? 186)).

Lemma carried_cell_spec : forall ch z, carried_cell ch z = true ->
  (4 <= z /\ z + size_chunk ch <= 8) \/ (168 <= z /\ z + size_chunk ch <= 178)
  \/ (184 <= z /\ z + size_chunk ch <= 186).
Proof.
  intros ch z H. unfold carried_cell in H.
  repeat rewrite orb_true_iff in H. repeat rewrite andb_true_iff in H.
  rewrite !Z.leb_le in H. tauto.
Qed.

Lemma field_offsets_pinned :
  map (fun f => match field_offset (prog_comp_env mario.prog) f mario_state_members with
                | Errors.OK (d, _) => d | _ => -1 end)
      [mario._flags; mario._numCoins; mario._numStars; mario._numKeys; mario._numLives;
       mario._health; mario._unkB0; mario._prevNumStarsForDialog]
  = [4; 168; 170; 172; 173; 174; 176; 184].
Proof. vm_compute. reflexivity. Qed.

(* a carried cell is apart from every cell the PhiW carry keeps *)
Lemma carried_bmk : forall ch z ch' z', carried_cell ch z = true -> bmk ch' z' ->
  z' + size_chunk ch' <= z \/ z + size_chunk ch <= z'.
Proof.
  intros ch z ch' z' H (_ & _ & _ & W3). apply carried_cell_spec in H.
  pose proof (size_chunk_pos ch'). unfold carried_apart in W3. lia.
Qed.

Lemma carried_window : forall ch z, carried_cell ch z = true -> store_window_ok z (size_chunk ch) = true.
Proof.
  intros ch z H. apply carried_cell_spec in H. pose proof (size_chunk_pos ch) as Hs.
  assert (Mx : 186 <= Ptrofs.max_unsigned) by (vm_compute; intro E; discriminate E).
  unfold store_window_ok.
  repeat match goal with |- context [?a <=? ?b] => destruct (Z.leb_spec a b) end;
  repeat match goal with |- context [?a <? ?b] => destruct (Z.ltb_spec a b) end;
  cbn; try reflexivity; lia.
Qed.

(* ---------------------------------------------------------------------- *)
(* 1b. The act number does not change the entry (census B1, acts 1..6).   *)
(*     level_cmd_place_object places a command iff (mask & val7) or mask *)
(*     = 0x1F; every OBJECT of WMotR's script (the area's and the two     *)
(*     JUMP_LINKed local scripts') has mask 0x1F, its command's byte 2    *)
(*     (big-endian: bits 15..8 of the first word), read off generated/.   *)
(*     So for every act 1..6 the same objects are placed; the act cell    *)
(*     itself is a carried global the start premise does not read         *)
(*     (gstore_carried below).  Act 0 has no Clight execution (census B1, *)
(*     FOUND, decision pending).                                          *)
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
  Theorem mstore_keep : forall ch z i m m2, carried_cell ch z = true ->
    Mem.store ch m bm z (Vint i) = Some m2 -> start_premise m -> start_premise m2.
  Proof.
    intros ch z i m m2 Hc St (Ok & Hphi & Hst & How).
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
        exact (store_mapped_closed gp0 m ch bm z (Vint i) m2 HC0 (flat_bg gp0 m bm HC0 (HS0 _ _ Hbm_sym))
                 (inj_nonptr gp0 _ (vint_np i)) St). }
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
    [level_update._gCurrActNum; level_update._gCurrSaveFileNum; level_update._gCurrCourseStarFlags].

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
End CARRY.

(* ---------------------------------------------------------------------- *)
(* 4. Any sequence of carried writes keeps the premise.                   *)
(* ---------------------------------------------------------------------- *)
Inductive carried_step (lp : Clight.program) (bm : block) : mem -> mem -> Prop :=
  | cs_mario : forall ch z i m m2, carried_cell ch z = true ->
      Mem.store ch m bm z (Vint i) = Some m2 -> carried_step lp bm m m2
  | cs_glob : forall id bg ch z i m m2, In id carried_gids ->
      Genv.find_symbol (lp_ge lp) id = Some bg -> Mem.store ch m bg z (Vint i) = Some m2 ->
      carried_step lp bm m m2.

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
  intros P. apply IH. destruct Hs as [ch z i m m2' Hcc St | id bg ch z i m m2' Hin Hg St].
  - exact (mstore_keep lp H12 bm Hbm bc Ptrofs.zero SafeB Hsy Hbc eq_refl ch z i m m2' Hcc St P).
  - exact (gstore_carried lp H12 bm Hbm bc Ptrofs.zero SafeB Hbc eq_refl id bg ch z i m m2' Hin Hg St P).
Qed.

(* ====================================================================== *)
(* THE COVERAGE GUARD: the real-entry witness of StartSat, with ANY       *)
(* values in the carried cells (Mario's cap flags, coins, stars, keys,    *)
(* lives, health, the dialog counters; the act number, the save slot,     *)
(* the course's star flags), meets the capstone's start premise.         *)
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
