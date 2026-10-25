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
From SM64.Generated Require mario game_init graph_node level_update surface_collision memory camera audio_external sound_init.
From SM64.Proofs.WMotRRequiresA Require Import AnimData AnimWorld FloorList FloorExec FfWorld.
From SM64.Proofs.WMotRRequiresA Require WMotRWorld.
Import ListNotations.
Local Open Scope Z_scope.

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

Theorem anim_w_keep : forall m m' d,
  ffw_facts ge bm m d ->
  anim_w ge bm m ->
  Ple (Mem.nextblock m) (Mem.nextblock m') ->
  (forall b ofs k p, Plt b (Mem.nextblock m) -> Mem.perm m b ofs k p -> Mem.perm m' b ofs k p) ->
  (forall ch b z, Plt b (Mem.nextblock m) -> ~ rblk (ff_rl_of bm d) b ->
     Mem.load ch m' b z = Mem.load ch m b z) ->
  Mem.load Mint32 m' bm 136 = Mem.load Mint32 m bm 136 ->
  Mem.load Mint32 m' (fw_ab d) 0 = Mem.load Mint32 m (fw_ab d) 0 ->
  Mem.load Mint32 m' (fw_ab d) 8 = Mem.load Mint32 m (fw_ab d) 8 ->
  Mem.load Mint32 m' bm 144 = Mem.load Mint32 m bm 144 ->
  Mem.load Mint32 m' bm 156 = Mem.load Mint32 m bm 156 ->
  ((forall a, Mem.load Mint32 m' bm 12 = Some (Vint a) -> ~ In (Int.unsigned a) anim_acts)
   \/ (Mem.load Mint32 m' bm 12 = Mem.load Mint32 m bm 12
       /\ anim_cells_kept m m' (fw_ab d) (fw_bo d) (fw_oo d) (fw_bt d) (fw_ot d))) ->
  anim_w ge bm m'.
Proof.
  intros m m' d F AW Hnb KP OFF K136 K0 K8 K144 K156 HK.
  pose proof (ff_S5 _ _ _ _ F) as S5. pose proof (ff_Lo _ _ _ _ F) as Lo.
  pose proof (ff_Lb _ _ _ _ F) as Lb. pose proof (ff_W _ _ _ _ F) as W.
  destruct AW as (ab' & bga & bauc & btab & otab & bt' & ot' & mb & mo & B & ST).
  pose proof B as (Sab & Sga & Sau & L0 & L8 & Lm & Sy & D1 & D2 & D3 & D4 & D5
                   & _ & _ & _ & _ & _ & _ & _ & _ & Hbm).
  assert (ab' = fw_ab d) by congruence. subst ab'.
  rewrite Lb in L8. injection L8 as <- <-.
  change FFW_OBJ with 136 in Lo. rewrite Lo in Lm. injection Lm as <- <-.
  assert (NT : forall id b, Genv.find_symbol ge id = Some b -> b <> btab)
    by (intros id b H; exact (proj1 (Sy id b H))).
  assert (Ntab : ~ rblk (ff_rl_of bm d) btab).
  { apply (ffw_rl_not ge bm m d btab F).
    - exact (not_eq_sym (NT _ _ Hbm)).
    - congruence.
    - congruence.
    - intros id _ Hs. exact (NT _ _ Hs eq_refl). }
  assert (Nga : ~ rblk (ff_rl_of bm d) bga).
  { pose proof (proj2 (Sy _ _ Sga)) as Gbt.
    apply (ffw_rl_not_sym ge bm m d _ bga F Sga); [reflexivity | | congruence | congruence].
    exact (symne_ids _ _ _ _ Sga Hbm eq_refl). }

  pose proof (anim_base_keep ge bm m m' (fw_gp d) _ (fw_ab d) bga bauc btab otab (fw_bt d) (fw_ot d)
                (fw_bo d) (fw_oo d) B W Ntab Nga Hnb KP OFF K136 K0 K8 K144 K156) as B'.
  exists (fw_ab d), bga, bauc, btab, otab, (fw_bt d), (fw_ot d), (fw_bo d), (fw_oo d). split; [exact B' |].
  intros a La Ia. destruct HK as [N | (K12 & K4 & Km & Kb)].
  - exfalso. exact (N a La Ia).
  - rewrite K12 in La.
    exact (anim_st_keep m m' (fw_ab d) bga (fw_bt d) (fw_ot d) (fw_bo d) (fw_oo d) (ST a La Ia) K4 Km Kb).
Qed.

(* the two globals are not Mario's state block *)
Lemma lvl_ne_bm : forall m, anim_w ge bm m -> forall b, lvl_sym ge b -> b <> bm.
Proof.
  intros m AW b Hs.
  destruct AW as (ab' & bga & bauc & btab & otab & bt' & ot' & mb & mo & B & _).
  pose proof B as (_ & _ & _ & _ & _ & _ & _ & _ & _ & _ & _ & _
                   & _ & _ & _ & _ & _ & _ & _ & _ & Hbm).
  lvl_cases Hs; exact (symne_ids _ _ _ _ Hs Hbm eq_refl).
Qed.

(* the frame world's level cells (FfWorld.lvl_w) are globals' blocks off
   the walk's regions, so a walk's frame (unchanged outside the regions)
   keeps them *)
Theorem lvl_w_keep : forall m m' d,
  ffw_facts ge bm m d ->
  anim_w ge bm m ->
  Ple (Genv.genv_next ge) (Mem.nextblock m) ->
  (forall ch b z, Plt b (Mem.nextblock m) -> ~ rblk (ff_rl_of bm d) b ->
     Mem.load ch m' b z = Mem.load ch m b z) ->
  lvl_w ge m -> lvl_w ge m'.
Proof.
  intros m m' d F AW Hgn OFF. exact (lvl_w_keep_rl ge bm m m' d F (lvl_ne_bm m AW) Hgn OFF).
Qed.

(* ... and any change that leaves the two globals' blocks alone *)
Lemma lvl_w_keep_ne : forall m m' (P : block -> Prop),
  (forall b, lvl_sym ge b -> P b) ->
  (forall ch b z, P b -> Mem.load ch m' b z = Mem.load ch m b z) ->
  lvl_w ge m -> lvl_w ge m'.
Proof.
  intros m m' P HP HL. apply lvl_w_unch. intros b ch z Hs. exact (HL ch b z (HP b Hs)).
Qed.

End AK.
