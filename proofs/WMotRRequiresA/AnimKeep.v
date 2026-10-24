(* ====================================================================== *)
(* AnimKeep (GOAL 2): a call that keeps the frame world keeps the          *)
(* animation world (AnimWorld.anim_w) too.                                 *)
(*                                                                        *)
(* Every proved row rebuilds FfWorld.ffw after its call from              *)
(*   - the world fact Wff over ffw's region list ff_rl (Mario, his object, *)
(*     the DMA globals, the buffer, the camera globals...),               *)
(*   - the call changing memory only inside those blocks, keeping old      *)
(*     blocks and their permissions,                                       *)
(*   - the cells it must leave alone (FfKeepCheck.fk_same: marioObj,       *)
(*     the list's dmaTable and bufTarget...).                             *)
(* anim_w_keep turns the same facts into anim_w after the call: the table *)
(* and gMarioAnims are neither on ff_rl nor written; the animation state  *)
(* is either not needed (the action after is not a pole action after the *)
(* grab) or untouched.                                                    *)
(* ====================================================================== *)

From Coq Require Import ZArith List Bool Lia.
From compcert Require Import Coqlib Maps AST Integers Values Memory Globalenvs Clight.
From SM64.Generated Require mario game_init graph_node level_update surface_collision memory camera audio_external sound_init
  mario_actions_moving.
From SM64.Proofs.WMotRRequiresA Require Import AnimData AnimWorld FloorList FloorExec FfWorld.
From SM64.Proofs.WMotRRequiresA Require WMotRWorld.
Import ListNotations.
Local Open Scope Z_scope.

Lemma ff_rl_not : forall bm bo oo bfi bmiss bcalls ab bt biom bmq brm blk bpc bsr bsrc bsms bbs bfa x,
  bm <> x -> bo <> x -> bfi <> x -> bmiss <> x -> bcalls <> x -> ab <> x -> bt <> x ->
  biom <> x -> bmq <> x -> brm <> x -> blk <> x -> bpc <> x -> bsr <> x -> bsrc <> x -> bsms <> x -> bbs <> x -> bfa <> x ->
  ~ rblk (ff_rl bm bo oo bfi bmiss bcalls ab bt biom bmq brm blk bpc bsr bsrc bsms bbs bfa) x.
Proof.
  intros bm bo oo bfi bmiss bcalls ab bt biom bmq brm blk bpc bsr bsrc bsms bbs bfa x N1 N2 N3 N4 N5 N6 N7 N8 N9 N10 N11 N12 N13 N14 N15 N16 N17
    (o & Hin).
  unfold ff_rl in Hin. cbn in Hin.
  repeat (destruct Hin as [Hin | Hin]; [injection Hin as Hin _; congruence |]). exact Hin.
Qed.

Section AK.
Variable ge : genv.
Variable bm : block.

(* the pole actions after the grab are used_ok's actions *)
Lemma not_used_not_anim : forall a, ~ In a WMotRWorld.used_acts -> ~ In a anim_acts.
Proof.
  intros a N H. apply N. cbn in H |- *.
  repeat (destruct H as [H | H]; [subst a; tauto |]). destruct H.
Qed.

Lemma symne_ids : forall id1 id2 b1 b2, Genv.find_symbol ge id1 = Some b1 ->
  Genv.find_symbol ge id2 = Some b2 -> Pos.eqb id1 id2 = false -> b1 <> b2.
Proof.
  intros id1 id2 b1 b2 H1 H2 N. apply Pos.eqb_neq in N.
  exact (Genv.global_addresses_distinct ge N H1 H2).
Qed.

(* the cells anim_st reads, unchanged *)
Definition anim_cells_kept (m m' : mem) (ab bo : block) (oo : ptrofs) (bt : block) (ot : ptrofs) : Prop :=
  Mem.load Mint32 m' ab 4 = Mem.load Mint32 m ab 4
  /\ (forall o ch, In (o, ch) [(56, Mint16signed); (60, Mint32); (64, Mint16signed); (72, Mint32)] ->
        Mem.load ch m' bo (Ptrofs.unsigned oo + o) = Mem.load ch m bo (Ptrofs.unsigned oo + o))
  /\ (forall k rel ch v, In k hs_ids -> In (rel, ch, v) (buf_cells k) ->
        Mem.load ch m' bt (Ptrofs.unsigned ot + rel) = Mem.load ch m bt (Ptrofs.unsigned ot + rel)).

Theorem anim_w_keep : forall m m' gp bfi bmiss bcalls ab biom bmq brm blk bpc bsr bsrc bsms bbs bfa bo oo bt ot,
  Genv.find_symbol ge surface_collision._gFindFloorIncludeSurfaceIntangible = Some bfi ->
  Genv.find_symbol ge surface_collision._gNumFindFloorMisses = Some bmiss ->
  Genv.find_symbol ge surface_collision._gNumCalls = Some bcalls ->
  Genv.find_symbol ge mario._gMarioAnimsBuf = Some ab ->
  Genv.find_symbol ge memory._gDmaIoMesg = Some biom ->
  Genv.find_symbol ge memory._gDmaMesgQueue = Some bmq ->
  Genv.find_symbol ge memory._gMainReceivedMesg = Some brm ->
  Genv.find_symbol ge camera._gLakituState = Some blk ->
  Genv.find_symbol ge camera._gPlayerCameraState = Some bpc ->
  Genv.find_symbol ge audio_external._sSoundRequests = Some bsr ->
  Genv.find_symbol ge audio_external._sSoundRequestCount = Some bsrc ->
  Genv.find_symbol ge audio_external._sSoundMovingSpeed = Some bsms ->
  Genv.find_symbol ge mario._gBodyStates = Some bbs ->
  Genv.find_symbol ge mario_actions_moving._sFloorAlignMatrix = Some bfa ->
  Mem.load Mint32 m bm FFW_OBJ = Some (Vptr bo oo) ->
  Mem.load Mint32 m ab 8 = Some (Vptr bt ot) ->
  Wff ge m gp SZ_SURFACE (ff_rl bm bo oo bfi bmiss bcalls ab bt biom bmq brm blk bpc bsr bsrc bsms bbs bfa) ->
  anim_w ge bm m ->
  Ple (Mem.nextblock m) (Mem.nextblock m') ->
  (forall b ofs k p, Plt b (Mem.nextblock m) -> Mem.perm m b ofs k p -> Mem.perm m' b ofs k p) ->
  (forall ch b z, Plt b (Mem.nextblock m) ->
     ~ rblk (ff_rl bm bo oo bfi bmiss bcalls ab bt biom bmq brm blk bpc bsr bsrc bsms bbs bfa) b ->
     Mem.load ch m' b z = Mem.load ch m b z) ->
  Mem.load Mint32 m' bm 136 = Mem.load Mint32 m bm 136 ->
  Mem.load Mint32 m' ab 0 = Mem.load Mint32 m ab 0 ->
  Mem.load Mint32 m' ab 8 = Mem.load Mint32 m ab 8 ->
  Mem.load Mint32 m' bm 144 = Mem.load Mint32 m bm 144 ->
  Mem.load Mint32 m' bm 156 = Mem.load Mint32 m bm 156 ->
  ((forall a, Mem.load Mint32 m' bm 12 = Some (Vint a) -> ~ In (Int.unsigned a) anim_acts)
   \/ (Mem.load Mint32 m' bm 12 = Mem.load Mint32 m bm 12 /\ anim_cells_kept m m' ab bo oo bt ot)) ->
  anim_w ge bm m'.
Proof.
  intros m m' gp bfi bmiss bcalls ab biom bmq brm blk bpc bsr bsrc bsms bbs bfa bo oo bt ot
    S1 S2 S3 S5 S6 S7 S8 SL SP SR SRC SMS SBS SFA Lo Lb W AW Hnb KP OFF K136 K0 K8 K144 K156 HK.
  destruct AW as (ab' & bga & bauc & btab & otab & bt' & ot' & mb & mo & B & ST).
  pose proof B as (Sab & Sga & Sau & L0 & L8 & Lm & Sy & D1 & D2 & D3 & D4 & D5
                   & _ & _ & _ & _ & _ & _ & _ & _ & Hbm).
  assert (ab' = ab) by congruence. subst ab'.
  rewrite Lb in L8. injection L8 as <- <-.
  change FFW_OBJ with 136 in Lo. rewrite Lo in Lm. injection Lm as <- <-.
  assert (NT : forall id b, Genv.find_symbol ge id = Some b -> b <> btab)
    by (intros id b H; exact (proj1 (Sy id b H))).
  assert (Ntab : ~ rblk (ff_rl bm bo oo bfi bmiss bcalls ab bt biom bmq brm blk bpc bsr bsrc bsms bbs bfa) btab).
  { apply ff_rl_not; first [exact (NT _ _ Hbm) | exact (NT _ _ S1) | exact (NT _ _ S2) | exact (NT _ _ S3)
      | exact (NT _ _ S5) | exact (NT _ _ S6) | exact (NT _ _ S7) | exact (NT _ _ S8) | exact (NT _ _ SL)
      | exact (NT _ _ SP) | exact (NT _ _ SR) | exact (NT _ _ SRC) | exact (NT _ _ SMS) | exact (NT _ _ SBS) | exact (NT _ _ SFA) | congruence]. }
  assert (Nga : ~ rblk (ff_rl bm bo oo bfi bmiss bcalls ab bt biom bmq brm blk bpc bsr bsrc bsms bbs bfa) bga).
  { pose proof (proj2 (Sy _ _ Sga)) as Gbt.
    apply ff_rl_not; first [ congruence
      | exact (symne_ids _ _ _ _ Hbm Sga eq_refl) | exact (symne_ids _ _ _ _ S1 Sga eq_refl)
      | exact (symne_ids _ _ _ _ S2 Sga eq_refl) | exact (symne_ids _ _ _ _ S3 Sga eq_refl)
      | exact (symne_ids _ _ _ _ S5 Sga eq_refl) | exact (symne_ids _ _ _ _ S6 Sga eq_refl)
      | exact (symne_ids _ _ _ _ S7 Sga eq_refl) | exact (symne_ids _ _ _ _ S8 Sga eq_refl)
      | exact (symne_ids _ _ _ _ SL Sga eq_refl) | exact (symne_ids _ _ _ _ SP Sga eq_refl)
      | exact (symne_ids _ _ _ _ SR Sga eq_refl) | exact (symne_ids _ _ _ _ SRC Sga eq_refl)
      | exact (symne_ids _ _ _ _ SMS Sga eq_refl) | exact (symne_ids _ _ _ _ SBS Sga eq_refl)
      | exact (symne_ids _ _ _ _ SFA Sga eq_refl) ]. }

  pose proof (anim_base_keep ge bm m m' gp _ ab bga bauc btab otab bt ot bo oo B W Ntab Nga Hnb KP OFF
                K136 K0 K8 K144 K156) as B'.
  exists ab, bga, bauc, btab, otab, bt, ot, bo, oo. split; [exact B' |].
  intros a La Ia. destruct HK as [N | (K12 & K4 & Km & Kb)].
  - exfalso. exact (N a La Ia).
  - rewrite K12 in La. exact (anim_st_keep m m' ab bga bt ot bo oo (ST a La Ia) K4 Km Kb).
Qed.

(* the frame world's level cells (FfWorld.lvl_w) are globals' blocks off
   the walk's regions, so a walk's frame (unchanged outside the regions)
   keeps them *)
Theorem lvl_w_keep : forall m m' bfi bmiss bcalls ab biom bmq brm blk bpc bsr bsrc bsms bbs bfa bo oo bt,
  Genv.find_symbol ge surface_collision._gFindFloorIncludeSurfaceIntangible = Some bfi ->
  Genv.find_symbol ge surface_collision._gNumFindFloorMisses = Some bmiss ->
  Genv.find_symbol ge surface_collision._gNumCalls = Some bcalls ->
  Genv.find_symbol ge mario._gMarioAnimsBuf = Some ab ->
  Genv.find_symbol ge memory._gDmaIoMesg = Some biom ->
  Genv.find_symbol ge memory._gDmaMesgQueue = Some bmq ->
  Genv.find_symbol ge memory._gMainReceivedMesg = Some brm ->
  Genv.find_symbol ge camera._gLakituState = Some blk ->
  Genv.find_symbol ge camera._gPlayerCameraState = Some bpc ->
  Genv.find_symbol ge audio_external._sSoundRequests = Some bsr ->
  Genv.find_symbol ge audio_external._sSoundRequestCount = Some bsrc ->
  Genv.find_symbol ge audio_external._sSoundMovingSpeed = Some bsms ->
  Genv.find_symbol ge mario._gBodyStates = Some bbs ->
  Genv.find_symbol ge mario_actions_moving._sFloorAlignMatrix = Some bfa ->
  anim_w ge bm m ->
  (forall b, Genv.find_symbol ge mario._gCurrLevelNum = Some b
             \/ Genv.find_symbol ge sound_init._sPlayingInfiniteStairs = Some b -> b <> bo /\ b <> bt) ->
  Ple (Genv.genv_next ge) (Mem.nextblock m) ->
  (forall ch b z, Plt b (Mem.nextblock m) ->
     ~ rblk (ff_rl bm bo oo bfi bmiss bcalls ab bt biom bmq brm blk bpc bsr bsrc bsms bbs bfa) b ->
     Mem.load ch m' b z = Mem.load ch m b z) ->
  lvl_w ge m -> lvl_w ge m'.
Proof.
  intros m m' bfi bmiss bcalls ab biom bmq brm blk bpc bsr bsrc bsms bbs bfa bo oo bt
    S1 S2 S3 S5 S6 S7 S8 SL SP SR SRC SMS SBS SFA AW D4 Hgn OFF (LV1 & LV2).
  destruct AW as (ab' & bga & bauc & btab & otab & bt' & ot' & mb & mo & B & _).
  pose proof B as (_ & _ & _ & _ & _ & _ & _ & _ & _ & _ & _ & _
                   & _ & _ & _ & _ & _ & _ & _ & _ & Hbm).
  assert (K : forall id b, Genv.find_symbol ge id = Some b ->
            (id = mario._gCurrLevelNum \/ id = sound_init._sPlayingInfiniteStairs) ->
            forall ch z, Mem.load ch m' b z = Mem.load ch m b z).
  { intros id b Hs Hid ch z. apply OFF.
    - exact (Plt_Ple_trans _ _ _ (Genv.genv_symb_range _ _ Hs) Hgn).
    - assert (Dob : b <> bo /\ b <> bt)
        by (apply D4; destruct Hid as [-> | ->]; [left | right]; exact Hs).
      destruct Dob as (Do & Dt).
      destruct Hid as [-> | ->];
        apply ff_rl_not; try congruence;
        first [ exact (symne_ids _ _ _ _ Hbm Hs eq_refl)
              | exact (symne_ids _ _ _ _ S1 Hs eq_refl) | exact (symne_ids _ _ _ _ S2 Hs eq_refl)
              | exact (symne_ids _ _ _ _ S3 Hs eq_refl) | exact (symne_ids _ _ _ _ S5 Hs eq_refl)
              | exact (symne_ids _ _ _ _ S6 Hs eq_refl) | exact (symne_ids _ _ _ _ S7 Hs eq_refl)
              | exact (symne_ids _ _ _ _ S8 Hs eq_refl) | exact (symne_ids _ _ _ _ SL Hs eq_refl)
              | exact (symne_ids _ _ _ _ SP Hs eq_refl) | exact (symne_ids _ _ _ _ SR Hs eq_refl)
              | exact (symne_ids _ _ _ _ SRC Hs eq_refl) | exact (symne_ids _ _ _ _ SMS Hs eq_refl)
              | exact (symne_ids _ _ _ _ SBS Hs eq_refl) | exact (symne_ids _ _ _ _ SFA Hs eq_refl) ]. }

  split.
  - intros b Hs. rewrite (K _ b Hs (or_introl eq_refl)). exact (LV1 b Hs).
  - intros b Hs. rewrite (K _ b Hs (or_intror eq_refl)). exact (LV2 b Hs).
Qed.

(* ... and any change that leaves the two globals' blocks alone *)
Lemma lvl_w_keep_ne : forall m m' (P : block -> Prop),
  (forall b, Genv.find_symbol ge mario._gCurrLevelNum = Some b
             \/ Genv.find_symbol ge sound_init._sPlayingInfiniteStairs = Some b -> P b) ->
  (forall ch b z, P b -> Mem.load ch m' b z = Mem.load ch m b z) ->
  lvl_w ge m -> lvl_w ge m'.
Proof.
  intros m m' P HP HL (LV1 & LV2). split.
  - intros b Hs. rewrite (HL _ b 0 (HP b (or_introl Hs))). exact (LV1 b Hs).
  - intros b Hs. rewrite (HL _ b 0 (HP b (or_intror Hs))). exact (LV2 b Hs).
Qed.

(* the two globals are not Mario's state block *)
Lemma lvl_ne_bm : forall m, anim_w ge bm m -> forall b,
  Genv.find_symbol ge mario._gCurrLevelNum = Some b
  \/ Genv.find_symbol ge sound_init._sPlayingInfiniteStairs = Some b -> b <> bm.
Proof.
  intros m AW b Hs.
  destruct AW as (ab' & bga & bauc & btab & otab & bt' & ot' & mb & mo & B & _).
  pose proof B as (_ & _ & _ & _ & _ & _ & _ & _ & _ & _ & _ & _
                   & _ & _ & _ & _ & _ & _ & _ & _ & Hbm).
  destruct Hs as [Hs | Hs]; exact (symne_ids _ _ _ _ Hs Hbm eq_refl).
Qed.
End AK.
