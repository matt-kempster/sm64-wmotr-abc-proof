(* ====================================================================== *)
(* FfWorld (GOAL 2): what the act_freefall walk needs from the memory at   *)
(* its call, as a fact the frame carries (`ffw`, a conjunct of FrameSplit's *)
(* `fworld`).                                                              *)
(*                                                                         *)
(* The walk (FfRun.ff_move) runs the real act_freefall over ten regions:   *)
(* Mario's state block, his object, find_floor's three statics, the        *)
(* animation list gMarioAnimsBuf, its DMA buffer, and memory.c's three DMA  *)
(* globals.  Everything else it reads is "world": the collision partition, *)
(* m->floor, m->area and gSineTable.  `ffw` says, of a memory:             *)
(*   - it is closed by a flat injection gp that maps every global symbol  *)
(*     and Mario's state block (ClosedMem.closed_by: a pointer stored in a   *)
(*     mapped block points at a mapped block; ClightClosed proves every    *)
(*     Clight call keeps this);                                             *)
(*   - Mario's object, the animation list (&gMarioAnimsBuf, as             *)
(*     init_mario_from_save_file sets it) and its buffer are where the     *)
(*     walk's regions say, and the object and the buffer are blocks of     *)
(*     their own (a gObjectPool slot; a main_pool allocation);              *)
(*   - the collision partition is well-formed lists of WMotR surfaces, off *)
(*     the regions (FloorExec.Wff), and every floor height on it is a WMotR *)
(*     floor (AirMatch.floor_data, TRUST 0.8(d));                          *)
(*   - m->floor, m->area and m->controller point at world objects off the  *)
(*     regions, and m->wall and m->ceil, when pointers, at blocks off them; *)
(*   - every collided object of Mario's is in his object's block (in the   *)
(*     game: all objects are gObjectPool slots);                           *)
(*   - m->input has neither INPUT_A_PRESSED nor INPUT_A_DOWN (no-A), nor   *)
(*     INPUT_INTERACT_OBJ_GRABBABLE (only interact_grabbable sets it,      *)
(*     interaction.c:1657, and WMotR has nothing grabbable: WMotRWorld);  *)
(*   (2026-10-22: the conjunct that in an air action floorHeight is a      *)
(*   floor refresh of y was DROPPED: every row that read it already has the *)
(*   dispatch's FfWorld.fresh as its precondition, and a pole frame that  *)
(*   drops Mario to FREEFALL at the pole base cannot re-establish it from *)
(*   the code alone.)                                                      *)
(* Offsets and sizes are the generated AST's (pinned in FfRow on the link). *)
(* ffw survives the frame's two stores into Mario's object (ffw_keep).      *)
(* ====================================================================== *)

From Coq Require Import ZArith List Lia Reals.
From compcert Require Import Coqlib Maps AST Integers Floats Values Memory Ctypes Clight Globalenvs.
From SM64.Generated Require mario surface_collision memory camera audio_external sound_init
  mario_actions_moving.
From SM64.Proofs Require Import HeightInvariant HeightMoveCatalog WMotRLevel Generic.ClosedMem.
From SM64.Proofs.WMotRRequiresA Require Import FloorList FloorHeight FloorExec AirMatch AirStart RetOk.
Import ListNotations.

(* the MarioState fields and struct sizes the walk reads (generated AST) *)
Definition FFW_OBJ : Z := 136.      (* marioObj *)
Definition FFW_WALL : Z := 96.      (* wall *)
Definition FFW_CEIL : Z := 100.     (* ceil *)
Definition FFW_FLOOR : Z := 104.    (* floor *)
Definition FFW_AREA : Z := 144.     (* area *)
Definition FFW_ANIM : Z := 160.     (* animList *)
Definition FFW_CTL : Z := 156.      (* controller *)
Definition SZ_OBJECT : Z := 608.
Definition SZ_SURFACE : Z := 48.
Definition SZ_AREA : Z := 60.
Definition SZ_CTL : Z := 18.        (* up to Controller.buttonDown, a u16 at 16 *)
Definition FFW_COLL : Z := 120.     (* Object.collidedObjs[4] *)
Definition FFW_PCS : Z := 148.      (* statusForCamera *)
Definition FFW_BODY : Z := 152.     (* marioBodyState *)
Definition FFW_THROW : Z := 80.     (* Object.header.gfx.throwMatrix *)

(* the walk's fifteen regions as pointers, in FfRun.R0F's order (two since
   camera.c is linked: gLakituState, which the real
   set_camera_shake_from_hit writes, and gPlayerCameraState, the
   m->statusForCamera the ledge climbs and the cannon write through; the
   last three since audio/external.c is linked: sSoundRequests,
   sSoundRequestCount and sSoundMovingSpeed, which the real play_sound and
   set_sound_moving_speed write; the sixteenth, 2026-10-23: gBodyStates,
   m->marioBodyState's target, which mario_reset_bodystate and
   update_mario_info_for_cam write through; the seventeenth, 2026-10-24:
   sFloorAlignMatrix, Mario's gfx.throwMatrix target, which
   sink_mario_in_quicksand writes through) *)
Definition ff_rl (bm bo : block) (oo : ptrofs) (bfi bmiss bcalls ab bt biom bmq brm blk bpc bsr bsrc bsms bbs bfa : block)
  : list (option val) :=
  map Some [Vptr bm Ptrofs.zero; Vptr bo oo; Vptr bfi Ptrofs.zero; Vptr bmiss Ptrofs.zero;
            Vptr bcalls Ptrofs.zero; Vptr ab Ptrofs.zero; Vptr bt Ptrofs.zero;
            Vptr biom Ptrofs.zero; Vptr bmq Ptrofs.zero; Vptr brm Ptrofs.zero;
            Vptr blk Ptrofs.zero; Vptr bpc Ptrofs.zero;
            Vptr bsr Ptrofs.zero; Vptr bsrc Ptrofs.zero; Vptr bsms Ptrofs.zero;
            Vptr bbs Ptrofs.zero; Vptr bfa Ptrofs.zero].

(* a world object: a valid block that is none of the regions *)
Definition wblk (m : mem) (rl : list (option val)) (v : val) (n : Z) : Prop :=
  exists b o, v = Vptr b o /\ Plt b (Mem.nextblock m) /\ 0 <= n
    /\ Ptrofs.unsigned o + n <= Ptrofs.modulus /\ ~ rblk rl b.

Section FFW.
Variable G : genv.
Variable bm : block.

Definition ffw (m : mem) : Prop :=
  Ple (Genv.genv_next G) (Mem.nextblock m)
  /\ (exists gp bfi bmiss bcalls bsin ab biom bmq brm blk bpc bsr bsrc bsms bbs bfa bo oo bt ot fl ar inp ctl,
      (* closedness *)
      closed_by gp m
      /\ (forall id b, Genv.find_symbol G id = Some b -> gp b <> None) /\ gp bm <> None
      /\ Genv.find_symbol G surface_collision._gFindFloorIncludeSurfaceIntangible = Some bfi
      /\ Genv.find_symbol G surface_collision._gNumFindFloorMisses = Some bmiss
      /\ Genv.find_symbol G surface_collision._gNumCalls = Some bcalls
      /\ Genv.find_symbol G mario._gSineTable = Some bsin
      /\ Genv.find_symbol G mario._gMarioAnimsBuf = Some ab
      /\ Genv.find_symbol G memory._gDmaIoMesg = Some biom
      /\ Genv.find_symbol G memory._gDmaMesgQueue = Some bmq
      /\ Genv.find_symbol G memory._gMainReceivedMesg = Some brm
      /\ Genv.find_symbol G camera._gLakituState = Some blk
      /\ Genv.find_symbol G camera._gPlayerCameraState = Some bpc
      /\ Genv.find_symbol G audio_external._sSoundRequests = Some bsr
      /\ Genv.find_symbol G audio_external._sSoundRequestCount = Some bsrc
      /\ Genv.find_symbol G audio_external._sSoundMovingSpeed = Some bsms
      /\ Genv.find_symbol G mario._gBodyStates = Some bbs
      /\ Genv.find_symbol G mario_actions_moving._sFloorAlignMatrix = Some bfa
      (* Mario's object; the animation list and its DMA buffer *)
      /\ Mem.load Mint32 m bm FFW_OBJ = Some (Vptr bo oo)
      /\ Ptrofs.unsigned oo + SZ_OBJECT <= Ptrofs.modulus
      /\ Mem.load Mint32 m bm FFW_ANIM = Some (Vptr ab Ptrofs.zero)
      /\ Mem.load Mint32 m ab 8 = Some (Vptr bt ot) /\ Ptrofs.unsigned ot + 24 <= Ptrofs.modulus
      (* the object and the buffer are blocks of their own *)
      /\ bo <> bm /\ bt <> bm /\ bt <> bo
      (* (gAudioRandom too: play_mario_jump_sound reads it, a world cell) *)
      /\ (forall b, In b [bfi; bmiss; bcalls; bsin; ab; biom; bmq; brm; blk; bpc; bsr; bsrc; bsms; bbs; bfa]
                    \/ Genv.find_symbol G mario._gAudioRandom = Some b
                    (* gCurrLevelNum: add_tree_leaf_particles reads it (the pole walks);
                       sPlayingInfiniteStairs: play_infinite_stairs_music reads it (lvl_w) *)
                    \/ (Genv.find_symbol G mario._gCurrLevelNum = Some b
                        \/ Genv.find_symbol G sound_init._sPlayingInfiniteStairs = Some b) -> b <> bo /\ b <> bt)
      (* the collision partition *)
      /\ Wff G m gp SZ_SURFACE (ff_rl bm bo oo bfi bmiss bcalls ab bt biom bmq brm blk bpc bsr bsrc bsms bbs bfa)
      (* m->floor, m->area *)
      /\ Mem.load Mint32 m bm FFW_FLOOR = Some fl
      /\ wblk m (ff_rl bm bo oo bfi bmiss bcalls ab bt biom bmq brm blk bpc bsr bsrc bsms bbs bfa) fl SZ_SURFACE
      (* m->wall, m->ceil *)
      /\ (forall off sb so, off = FFW_WALL \/ off = FFW_CEIL -> Mem.load Mint32 m bm off = Some (Vptr sb so) ->
            ~ rblk (ff_rl bm bo oo bfi bmiss bcalls ab bt biom bmq brm blk bpc bsr bsrc bsms bbs bfa) sb)
      /\ Mem.load Mint32 m bm FFW_AREA = Some ar
      /\ wblk m (ff_rl bm bo oo bfi bmiss bcalls ab bt biom bmq brm blk bpc bsr bsrc bsms bbs bfa) ar SZ_AREA
      (* m->input: INPUT_A_PRESSED | INPUT_A_DOWN | INPUT_INTERACT_OBJ_GRABBABLE clear *)
      /\ Mem.load Mint16unsigned m bm 2 = Some (Vint inp) /\ Int.and inp (Int.repr 2178) = Int.zero
      (* m->controller *)
      /\ Mem.load Mint32 m bm FFW_CTL = Some ctl
      /\ wblk m (ff_rl bm bo oo bfi bmiss bcalls ab bt biom bmq brm blk bpc bsr bsrc bsms bbs bfa) ctl SZ_CTL
      (* the collided objects *)
      /\ (forall i cb co, 0 <= i < 4 ->
            Mem.load Mint32 m bo (Ptrofs.unsigned oo + FFW_COLL + 4 * i) = Some (Vptr cb co) -> cb = bo)
      (* m->statusForCamera = &gPlayerCameraState[0] (init_mario_from_save_file,
         mario.c; nothing else writes the cell) *)
      /\ Mem.load Mint32 m bm FFW_PCS = Some (Vptr bpc Ptrofs.zero)
      (* m->marioBodyState = &gBodyStates[0] (init_mario_from_save_file,
         mario.c; nothing else writes the cell).  2026-10-23: FOUND (phantom
         forall) -- without it (and gBodyStates as a region) the per-call rows
         of mario_reset_bodystate / update_mario_info_for_cam ranged over
         memories whose marioBodyState pointed into Mario's own state or a
         surface, which the real stores through it then break *)
      /\ Mem.load Mint32 m bm FFW_BODY = Some (Vptr bbs Ptrofs.zero)
      (* Mario's object's gfx.throwMatrix is NULL or points into
         sFloorAlignMatrix (2026-10-24).  In the game spawn_object /
         geo_obj_init set it to NULL, align_with_floor (crawling, the
         slides) to &sFloorAlignMatrix[m->unk00], and the renderer
         (geo_process_object) back to NULL; no other code writes Mario's.
         FOUND (phantom forall): without it the row of
         sink_mario_in_quicksand ranged over memories whose throwMatrix
         pointed into Mario's state or a surface, which its store
         ( *throwMatrix )[3][1] -= quicksandDepth then writes *)
      /\ (Mem.load Mint32 m bo (Ptrofs.unsigned oo + FFW_THROW) = Some (Vint Int.zero)
          \/ exists o, Mem.load Mint32 m bo (Ptrofs.unsigned oo + FFW_THROW) = Some (Vptr bfa o)))
  /\ floor_data G m.

(* ---- transfer: a memory that differs from m only inside Mario's object ---- *)

Lemma rl_obj : forall bo oo bfi bmiss bcalls ab bt biom bmq brm blk bpc bsr bsrc bsms bbs bfa,
  rblk (ff_rl bm bo oo bfi bmiss bcalls ab bt biom bmq brm blk bpc bsr bsrc bsms bbs bfa) bo.
Proof. intros. exists oo. cbn. auto 10. Qed.

(* a store into a mapped block keeps closedness when the value is closed, or
   is stored as a 16-bit integer (a pointer's bytes then are Undef) *)
Lemma store_closed : forall gp m m' ch b z v,
  Mem.store ch m b z v = Some m' -> closed_by gp m -> gp b = Some (b, 0) ->
  (ch = Mint16signed \/ forall b' o', v <> Vptr b' o') ->
  closed_by gp m'.
Proof.
  intros gp m m' ch b z v Hst HC Hb Hv.
  destruct v;
    try (refine (store_mapped_closed _ _ _ _ _ _ _ HC Hb _ Hst); constructor).
  destruct Hv as [-> | Hv]; [| exfalso; eapply Hv; reflexivity].
  rewrite (Mem.store_similar_chunks Mint16signed Mint16signed _ Vundef) in Hst
    by reflexivity.
  exact (store_mapped_closed _ _ _ _ _ _ _ HC Hb (Val.val_inject_undef _ _) Hst).
Qed.

Section KEEP.
Variables (m m' : mem) (bo0 : block) (oo0 : ptrofs).
Hypothesis Hnb : Mem.nextblock m' = Mem.nextblock m.
Hypothesis Hperm : forall b ofs k p, Mem.perm m b ofs k p -> Mem.perm m' b ofs k p.
Hypothesis Hld : forall ch b z, b <> bo0 -> Mem.load ch m' b z = Mem.load ch m b z.
(* the collided-object cells of Mario's object *)
(* the throwMatrix cell of Mario's object *)
Hypothesis Hldt : Mem.load Mint32 m' bo0 (Ptrofs.unsigned oo0 + FFW_THROW)
  = Mem.load Mint32 m bo0 (Ptrofs.unsigned oo0 + FFW_THROW).
Hypothesis Hldc : forall i, 0 <= i < 4 ->
  Mem.load Mint32 m' bo0 (Ptrofs.unsigned oo0 + FFW_COLL + 4 * i)
  = Mem.load Mint32 m bo0 (Ptrofs.unsigned oo0 + FFW_COLL + 4 * i).

Lemma wf_fwd : forall (A : block -> Prop) hd, (forall b, ~ A b -> b <> bo0) ->
  wf_list m A hd -> wf_list m' A hd.
Proof.
  intros A hd HA W. induction W as [| bn on nx Hv Hav Hl W IH]; [constructor |].
  apply wf_cons with nx; [unfold Mem.valid_block; rewrite Hnb; exact Hv | exact Hav | | exact IH].
  cbn [Mem.loadv] in *. rewrite (Hld _ _ _ (HA _ Hav)). exact Hl.
Qed.

Lemma part_back : forall rl hd, (forall id bp, In id part_ids -> Genv.find_symbol G id = Some bp ->
    ~ rblk rl bp) -> rblk rl bo0 ->
  part_head G m' hd -> part_head G m hd.
Proof.
  intros rl hd Hp Ho (id & bp & o & Hin & Hs & Hl). exists id, bp, o. split; [exact Hin |]. split; [exact Hs |].
  cbn [Mem.loadv] in *. rewrite Hld in Hl; [exact Hl |]. intros ->. exact (Hp _ _ Hin Hs Ho).
Qed.

Lemma floor_back : forall rl hd, (forall id bp, In id part_ids -> Genv.find_symbol G id = Some bp ->
    ~ rblk rl bp) -> rblk rl bo0 ->
  floor_head G m' hd -> floor_head G m hd.
Proof.
  intros rl hd Hp Ho (id & bp & z & x & Hin & Hs & Hz & Hx & Hl). exists id, bp, z, x.
  split; [exact Hin |]. split; [exact Hs |]. split; [exact Hz |]. split; [exact Hx |].
  cbn [Mem.loadv] in *. rewrite Hld in Hl; [exact Hl |]. intros ->. exact (Hp _ _ Hin Hs Ho).
Qed.

Lemma Wff_keep : forall gp rl, rblk rl bo0 -> Wff G m gp SZ_SURFACE rl -> Wff G m' gp SZ_SURFACE rl.
Proof.
  intros gp rl Ho (W1 & W2 & W3 & W4 & W5 & W6 & W7).
  assert (Hp : forall id bp, In id part_ids -> Genv.find_symbol G id = Some bp -> ~ rblk rl bp)
    by (intros id bp Hi Hs; exact (proj1 (proj2 (W2 id bp Hi Hs)))).
  assert (HA : forall b, ~ (is_static G b \/ rblk rl b) -> b <> bo0)
    by (intros b Hb ->; apply Hb; right; exact Ho).
  assert (OL : forall hd s, part_head G m' hd -> on_list m' hd s -> part_head G m hd /\ on_list m hd s).
  { intros hd s Hh Ho'. pose proof (part_back rl hd Hp Ho Hh) as Hh0. split; [exact Hh0 |].
    apply (ol_transfer m _ hd (W3 hd Hh0) m' s); [| exact Ho'].
    intros b z Hb. exact (Hld _ _ _ (HA b Hb)). }
  split; [| split; [| split; [| split; [| split; [| split]]]]].
  - intros id sz Hi. destruct (W1 id sz Hi) as (b & Hs & Hr). exists b. split; [exact Hs |].
    intros ofs Hofs. exact (Hperm _ _ _ _ (Hr ofs Hofs)).
  - intros id bp Hi Hs. rewrite Hnb. exact (W2 id bp Hi Hs).
  - intros hd Hh. exact (wf_fwd _ hd HA (W3 hd (part_back rl hd Hp Ho Hh))).
  - intros hd s Hh Ho'. destruct (OL hd s Hh Ho') as (Hh0 & Ho0).
    destruct (W4 hd s Hh0 Ho0) as (b & o & -> & Hpl & Hsz & Hr & Hg).
    exists b, o. rewrite Hnb. auto 10.
  - intros hd b o Hh Ho'. destruct (OL hd _ Hh Ho') as (Hh0 & Ho0).
    destruct (W5 hd b o Hh0 Ho0) as (t & Hl & Hin). exists t. split; [| exact Hin].
    rewrite Hld; [exact Hl |]. intros ->.
    destruct (W4 hd _ Hh0 Ho0) as (b' & o' & E & _ & _ & Hr & _). injection E as <- _. exact (Hr Ho).
  - intros hd b o Hh Ho'. destruct (OL hd _ Hh Ho') as (Hh0 & Ho0). exact (W6 hd b o Hh0 Ho0).
  - exact W7.
Qed.

Lemma floor_data_keep : forall gp rl, rblk rl bo0 -> Wff G m gp SZ_SURFACE rl ->
  floor_data G m -> floor_data G m'.
Proof.
  intros gp rl Ho (W1 & W2 & W3 & W4 & _) FD h (hd & s & xv & zv & Hh & Hol & Hhit).
  assert (Hp : forall id bp, In id part_ids -> Genv.find_symbol G id = Some bp -> ~ rblk rl bp)
    by (intros id bp Hi Hs; exact (proj1 (proj2 (W2 id bp Hi Hs)))).
  pose proof (floor_back rl hd Hp Ho Hh) as Hh0.
  assert (Hol0 : on_list m hd s).
  { apply (ol_transfer m _ hd (W3 hd (floor_head_part _ _ _ Hh0)) m' s); [| exact Hol].
    intros b z Hb. apply Hld. intros ->. apply Hb. right. exact Ho. }
  destruct (W4 hd s (floor_head_part _ _ _ Hh0) Hol0) as (b & o & -> & _ & _ & Hr & _).
  apply FD. exists hd, (Vptr b o), xv, zv. split; [exact Hh0 |]. split; [exact Hol0 |].
  apply (hit16_transfer m' m b o xv zv h); [| exact Hhit].
  intros ch z. apply Hld. intros ->. exact (Hr Ho).
Qed.

Lemma wblk_keep : forall rl v n, wblk m rl v n -> wblk m' rl v n.
Proof. intros rl v n (b & o & -> & H). exists b, o. rewrite Hnb. auto. Qed.

(* bo0 is Mario's object: then ffw survives *)
Theorem ffw_keep :
  Mem.load Mint32 m bm FFW_OBJ = Some (Vptr bo0 oo0) -> bo0 <> bm ->
  (forall ab, Genv.find_symbol G mario._gMarioAnimsBuf = Some ab -> ab <> bo0) ->
  (forall gp, closed_by gp m -> gp bo0 = Some (bo0, 0) -> closed_by gp m') ->
  ffw m -> ffw m'.
Proof.
  intros Hmo Hne Hab HC' (Hgn & EX & FD).
  destruct EX as (gp & bfi & bmiss & bcalls & bsin & ab & biom & bmq & brm & blk & bpc & bsr & bsrc & bsms & bbs & bfa & bo & oo & bt & ot & fl & ar & inp & ctl &
                  HC & HS & HM & S1 & S2 & S3 & S4 & S5 & S6 & S7 & S8 & SL & SP & SR & SRC & SMS & SBS & SFA & Lo & Soo & La & Lb & Sot & D1 & D2 & D3 & D4 &
                  W & Lf & Wf & Wc0 & Lar & War & Li & Ai & Lc & Wc & Co & LPC & LBS & LTM).
  rewrite Hmo in Lo. injection Lo as <- <-.
  assert (Ho : rblk (ff_rl bm bo0 oo0 bfi bmiss bcalls ab bt biom bmq brm blk bpc bsr bsrc bsms bbs bfa) bo0) by apply rl_obj.
  pose proof (Hab ab S5) as Hab0.
  assert (Gbo : gp bo0 = Some (bo0, 0)).
  { pose proof (closed_load _ _ _ _ _ _ HC HM Hmo) as P. cbn in P.
    destruct (gp bo0) as [[b' d]|] eqn:G0; [| congruence].
    destruct (closed_flat _ _ _ _ _ HC G0) as (-> & ->). reflexivity. }
  split; [rewrite Hnb; exact Hgn |].
  split.
  - exists gp, bfi, bmiss, bcalls, bsin, ab, biom, bmq, brm, blk, bpc, bsr, bsrc, bsms, bbs, bfa, bo0, oo0, bt, ot, fl, ar, inp, ctl.
    split; [exact (HC' gp HC Gbo) |]. split; [exact HS |]. split; [exact HM |].
    rewrite !Hld by congruence.
    repeat (split; [assumption |]).
    split; [exact (Wff_keep _ _ Ho W) |].
    split; [exact Lf |]. split; [exact (wblk_keep _ _ _ Wf) |].
    split; [intros off sb so Hoff Hl; rewrite Hld in Hl by congruence; exact (Wc0 off sb so Hoff Hl) |].
    split; [exact Lar |]. split; [exact (wblk_keep _ _ _ War) |].
    split; [exact Li |]. split; [exact Ai |].
    split; [exact Lc |]. split; [exact (wblk_keep _ _ _ Wc) |].
    split; [intros i cb co Hi Hl; rewrite Hldc in Hl by exact Hi; exact (Co i cb co Hi Hl) |].
    split; [first [exact LPC | rewrite Hld by congruence; exact LPC] |].
    split; [first [exact LBS | rewrite Hld by congruence; exact LBS] |].
    rewrite Hldt. exact LTM.

  - exact (floor_data_keep _ _ Ho W FD).
Qed.
End KEEP.

(* ---- transfer: a memory that agrees with m off the regions rl (what a walk
   of a call over rl leaves: SymExec2.MMg, FfKeep.fk_frame) ---- *)

Lemma ol_transfer_v : forall mb (W : block -> Prop) hd, wf_list mb W hd ->
    forall M s, (forall b z, ~ W b -> Mem.valid_block mb b -> Mem.load Mint32 M b z = Mem.load Mint32 mb b z) ->
    on_list M hd s -> on_list mb hd s.
Proof.
  intros mb W hd Hw. induction Hw as [| bn on nx Hv Hav Hld Hw IH]; intros M s F OL; inv OL.
  - apply ol_here. cbn [Mem.loadv] in *. rewrite <- (F _ _ Hav Hv). assumption.
  - cbn [Mem.loadv] in *.
    match goal with Hn : Mem.load _ M _ _ = Some ?nx' |- _ =>
      rewrite (F _ _ Hav Hv) in Hn; rewrite Hld in Hn; injection Hn as <- end.
    eapply ol_next; [exact Hld | eapply IH; eauto].
Qed.

Section KEEP2.
Variables (m m' : mem) (rl : list (option val)).
Hypothesis Hnb : Ple (Mem.nextblock m) (Mem.nextblock m').
Hypothesis Hperm : forall b ofs k p, Plt b (Mem.nextblock m) -> Mem.perm m b ofs k p -> Mem.perm m' b ofs k p.
Hypothesis Hld : forall ch b z, Plt b (Mem.nextblock m) -> ~ rblk rl b -> Mem.load ch m' b z = Mem.load ch m b z.

Lemma plt_fwd : forall b, Plt b (Mem.nextblock m) -> Plt b (Mem.nextblock m').
Proof. intros b H. exact (Plt_Ple_trans _ _ _ H Hnb). Qed.

Lemma wf_fwd2 : forall (A : block -> Prop) hd, (forall b, ~ A b -> ~ rblk rl b) ->
  wf_list m A hd -> wf_list m' A hd.
Proof.
  intros A hd HA W. induction W as [| bn on nx Hv Hav Hl W IH]; [constructor |].
  apply wf_cons with nx; [exact (plt_fwd _ Hv) | exact Hav | | exact IH].
  cbn [Mem.loadv] in *. rewrite (Hld _ _ _ Hv (HA _ Hav)). exact Hl.
Qed.

Lemma part_back2 : forall hd, (forall id bp, In id part_ids -> Genv.find_symbol G id = Some bp ->
    Plt bp (Mem.nextblock m) /\ ~ rblk rl bp) ->
  part_head G m' hd -> part_head G m hd.
Proof.
  intros hd Hp (id & bp & o & Hin & Hs & Hl). exists id, bp, o. split; [exact Hin |]. split; [exact Hs |].
  cbn [Mem.loadv] in *. destruct (Hp _ _ Hin Hs) as (P & R). rewrite Hld in Hl by assumption. exact Hl.
Qed.

Lemma floor_back2 : forall hd, (forall id bp, In id part_ids -> Genv.find_symbol G id = Some bp ->
    Plt bp (Mem.nextblock m) /\ ~ rblk rl bp) ->
  floor_head G m' hd -> floor_head G m hd.
Proof.
  intros hd Hp (id & bp & z & x & Hin & Hs & Hz & Hx & Hl). exists id, bp, z, x.
  split; [exact Hin |]. split; [exact Hs |]. split; [exact Hz |]. split; [exact Hx |].
  cbn [Mem.loadv] in *. destruct (Hp _ _ Hin Hs) as (P & R). rewrite Hld in Hl by assumption. exact Hl.
Qed.

Lemma Wff_keep2 : forall gp gp', (forall b, gp b <> None -> gp' b <> None) ->
  Wff G m gp SZ_SURFACE rl -> Wff G m' gp' SZ_SURFACE rl.
Proof using Hnb Hperm Hld.
  intros gp gp' Hg (W1 & W2 & W3 & W4 & W5 & W6 & W7).
  assert (Hp : forall id bp, In id part_ids -> Genv.find_symbol G id = Some bp ->
            Plt bp (Mem.nextblock m) /\ ~ rblk rl bp)
    by (intros id bp Hi Hs; destruct (W2 id bp Hi Hs) as (A & B & _); exact (conj A B)).
  assert (OL : forall hd s, part_head G m' hd -> on_list m' hd s -> part_head G m hd /\ on_list m hd s).
  { intros hd s Hh Ho'. pose proof (part_back2 hd Hp Hh) as Hh0. split; [exact Hh0 |].
    apply (ol_transfer_v m _ hd (W3 hd Hh0) m' s); [| exact Ho'].
    intros b z Hb Hv. apply Hld; [exact Hv |]. intros Hr. apply Hb. right. exact Hr. }
  split; [| split; [| split; [| split; [| split; [| split]]]]].
  - intros id sz Hi. destruct (W1 id sz Hi) as (b & Hs & Hr). exists b. split; [exact Hs |].
    intros ofs Hofs. apply Hperm; [exact (Mem.perm_valid_block _ _ _ _ _ (Hr ofs Hofs)) | exact (Hr ofs Hofs)].
  - intros id bp Hi Hs. destruct (W2 id bp Hi Hs) as (A & B & C).
    split; [exact (plt_fwd _ A) | split; assumption].
  - intros hd Hh. apply (wf_fwd2 _ hd); [| exact (W3 hd (part_back2 hd Hp Hh))].
    intros b Hb Hr. apply Hb. right. exact Hr.
  - intros hd s Hh Ho'. destruct (OL hd s Hh Ho') as (Hh0 & Ho0).
    destruct (W4 hd s Hh0 Ho0) as (b & o & -> & Hpl & Hsz & Hr & Hgb).
    exists b, o. split; [reflexivity |]. split; [exact (plt_fwd _ Hpl) |].
    split; [exact Hsz |]. split; [exact Hr | exact (Hg _ Hgb)].
  - intros hd b o Hh Ho'. destruct (OL hd _ Hh Ho') as (Hh0 & Ho0).
    destruct (W5 hd b o Hh0 Ho0) as (t & Hl & Hin). exists t. split; [| exact Hin].
    destruct (W4 hd _ Hh0 Ho0) as (b' & o' & E & Hpl & _ & Hr & _). injection E as <- <-.
    rewrite Hld by assumption. exact Hl.
  - intros hd b o Hh Ho'. destruct (OL hd _ Hh Ho') as (Hh0 & Ho0). exact (W6 hd b o Hh0 Ho0).
  - exact W7.
Qed.

Lemma floor_data_keep2 : forall gp, Wff G m gp SZ_SURFACE rl ->
  floor_data G m -> floor_data G m'.
Proof using Hnb Hperm Hld.
  intros gp (W1 & W2 & W3 & W4 & _) FD h (hd & s & xv & zv & Hh & Hol & Hhit).
  assert (Hp : forall id bp, In id part_ids -> Genv.find_symbol G id = Some bp ->
            Plt bp (Mem.nextblock m) /\ ~ rblk rl bp)
    by (intros id bp Hi Hs; destruct (W2 id bp Hi Hs) as (A & B & _); exact (conj A B)).
  pose proof (floor_back2 hd Hp Hh) as Hh0.
  assert (Hol0 : on_list m hd s).
  { apply (ol_transfer_v m _ hd (W3 hd (floor_head_part _ _ _ Hh0)) m' s); [| exact Hol].
    intros b z Hb Hv. apply Hld; [exact Hv |]. intros Hr. apply Hb. right. exact Hr. }
  destruct (W4 hd s (floor_head_part _ _ _ Hh0) Hol0) as (b & o & -> & Hpl & _ & Hr & _).
  apply FD. exists hd, (Vptr b o), xv, zv. split; [exact Hh0 |]. split; [exact Hol0 |].
  apply (hit16_transfer m' m b o xv zv h); [| exact Hhit].
  intros ch z. apply Hld; assumption.
Qed.

Lemma wblk_keep2 : forall rl' v n, wblk m rl' v n -> wblk m' rl' v n.
Proof using Hnb Hperm Hld. intros rl' v n (b & o & -> & P & H). exists b, o. split; [reflexivity |]. split; [exact (plt_fwd _ P) | exact H]. Qed.
End KEEP2.
End FFW.

(* ---- the dispatch's floor refresh (FrameStage) ------------------------- *)
(* Mario's floorHeight is a floor refresh of his height: what
   update_mario_inputs leaves (update_mario_geometry_inputs's find_floor),
   and what an airborne handler's walk needs at its entry; and, unless the
   action is ACT_SOFT_BONK (0x010208B6), with 101 units of slack:
   floorHeight is -11000 or at most pos[1] + 140.
   FOUND 2026-10-22 (the ledge walks): let_go_of_ledge (mario_actions_
   automatic.c:490) moves pos[1] down by 100 (or to the floor below, when
   that is higher), does NOT refresh floorHeight, and returns
   set_mario_action(SOFT_BONK) = TRUE; the dispatch loop then runs
   act_soft_bonk on the stale floor.  `fh <= y + 241` alone is not kept by
   that drop; the slack is.  In the game update_mario_inputs' find_floor
   gives at most pos[1] + 80 (FloorBound.ff_height_bound), and soft bonk
   without A returns FALSE (its one TRUE is the A-gated wall kick:
   SbRet0), so the stale floor goes no further than act_soft_bonk. *)
Definition SB_ACT : Z := 16910518.
Definition FRESH_SLACK : R := 140.

Definition fresh_fl (bm : block) (m : mem) : Prop :=
  forall y fh, Mem.load Mfloat32 m bm OFS_POSY = Some (Vsingle y) ->
    Mem.load Mfloat32 m bm OFS_FLOORH = Some (Vsingle fh) ->
    FloorRefreshOK wmotr_floor (R2 y) (R2 fh)
    /\ (Mem.load Mint32 m bm 12 = Some (Vint (Int.repr SB_ACT))
        \/ (R2 fh = -11000)%R \/ (R2 fh <= R2 y + FRESH_SLACK)%R).

(* ... and the two other inputs the dispatchers' prologues read
   (2026-10-23, AirSplit.air_pro_rows, PROVED in ProRows): m->waterLevel
   is -11000 and m->input has no INPUT_SQUISHED (0x0040).
   FOUND (phantom forall): the prologue row's precondition was the floor
   refresh alone, so a memory with a high waterLevel sent the real
   check_common_airborne_cancels / _automatic_cancels into
   set_water_plunge_action (ACT_WATER_PLUNGE), and one with INPUT_SQUISHED
   into drop_and_set_mario_action(ACT_SQUISHED); neither is in R_noA, so
   the row was FALSE as stated.  In the game update_mario_inputs (mario.c)
   sets m->waterLevel = find_water_level(x, z), which is -11000 where the
   area has no water regions (WMotR has none: its level script loads no
   water box), and recomputes m->input from 0; INPUT_SQUISHED is set only
   when the ceiling is under 150 units above Mario's floor
   (update_mario_geometry_inputs's squish test), and the narrowest WMotR
   floor/ceiling gap is 276 (tools/goal2_squish_scan.py).  Mario's
   handlers do not write either cell (FfKeepCheck.fk_same keeps both
   across every walked case). *)
Definition WL_OFF : Z := 118.      (* MarioState.waterLevel (s16), pinned in ProRows *)

Definition inputs_ok (bm : block) (m : mem) : Prop :=
  Mem.load Mint16signed m bm WL_OFF = Some (Vint (Int.repr (-11000)))
  /\ forall inp, Mem.load Mint16unsigned m bm 2 = Some (Vint inp) -> Int.and inp (Int.repr 64) = Int.zero.

Definition fresh (bm : block) (m : mem) : Prop := fresh_fl bm m /\ inputs_ok bm m.

Lemma fresh_fro : forall bm m y fh, fresh bm m ->
  Mem.load Mfloat32 m bm OFS_POSY = Some (Vsingle y) ->
  Mem.load Mfloat32 m bm OFS_FLOORH = Some (Vsingle fh) ->
  FloorRefreshOK wmotr_floor (R2 y) (R2 fh).
Proof. intros bm m y fh H Ly Lf. exact (proj1 (proj1 H y fh Ly Lf)). Qed.

(* ... when the action is an airborne or an automatic one ((action &
   ACT_GROUP_MASK) == ACT_GROUP_AIRBORNE (0x080) or ACT_GROUP_AUTOMATIC
   (0x140)): the cases of execute_mario_action's dispatch that need it.
   AUTOMATIC since 2026-10-21.  FOUND: with the airborne group only, the
   automatic dispatcher's row was FALSE over stale floors: its handlers
   return TRUE into airborne actions (a pole's Z / low-health SOFT_BONK,
   let_go_of_ledge's SOFT_BONK, start_hanging's FREEFALL), and the row then
   owes fresh_at, i.e. a fresh floor, which nothing gave it at the entry of
   a non-airborne action.  In the game the dispatch is entered with the
   floor update_mario_inputs refreshed, and every handler that returns TRUE
   leaves it fresh.  The two input cells (inputs_ok) hold in every action
   (2026-10-23). *)
Definition fresh_at (bm : block) (m : mem) : Prop :=
  (forall a, Mem.load Mint32 m bm 12 = Some (Vint a) ->
    (Int.and a (Int.repr 448) = Int.repr 128 \/ Int.and a (Int.repr 448) = Int.repr 320) ->
    fresh_fl bm m)
  /\ inputs_ok bm m.

Lemma fresh_at_of : forall bm m, fresh bm m -> fresh_at bm m.
Proof. intros bm m (H & I). split; [intros a _ _; exact H | exact I]. Qed.

Lemma fresh_at_inputs : forall bm m, fresh_at bm m -> inputs_ok bm m.
Proof. intros bm m H. exact (proj2 H). Qed.

(* the airborne half *)
Lemma fresh_at_air : forall bm m a, fresh_at bm m -> Mem.load Mint32 m bm 12 = Some (Vint a) ->
  Int.and a (Int.repr 448) = Int.repr 128 -> fresh bm m.
Proof. intros bm m a (H & I) L E. exact (conj (H a L (or_introl E)) I). Qed.

(* the automatic half *)
Lemma fresh_at_auto : forall bm m a, fresh_at bm m -> Mem.load Mint32 m bm 12 = Some (Vint a) ->
  Int.and a (Int.repr 448) = Int.repr 320 -> fresh bm m.
Proof. intros bm m a (H & I) L E. exact (conj (H a L (or_intror E)) I). Qed.

(* the input cells, kept *)
Lemma inputs_ok_keep : forall bm m m',
  Mem.load Mint16signed m' bm WL_OFF = Mem.load Mint16signed m bm WL_OFF ->
  Mem.load Mint16unsigned m' bm 2 = Mem.load Mint16unsigned m bm 2 ->
  inputs_ok bm m -> inputs_ok bm m'.
Proof.
  intros bm m m' E1 E2 (W & I). split; [rewrite E1; exact W |].
  intros inp L. rewrite E2 in L. exact (I inp L).
Qed.

(* a handler that returned FALSE or kept the two cells (RetOk.RET), and
   that returns FALSE when entered in SOFT_BONK; the input cells kept *)
Lemma fresh_ret : forall bm m0 m' vres, fresh bm m0 -> RET bm m0 m' vres ->
  (Mem.load Mint32 m0 bm 12 = Some (Vint (Int.repr SB_ACT)) -> vres = Vint Int.zero) ->
  Mem.load Mint16signed m' bm WL_OFF = Mem.load Mint16signed m0 bm WL_OFF ->
  Mem.load Mint16unsigned m' bm 2 = Mem.load Mint16unsigned m0 bm 2 ->
  vres = Vint Int.zero \/ fresh bm m'.
Proof.
  intros bm m0 m' vres (F & I) [Z | (Y & H)] S K1 K2; [left; exact Z |].
  destruct (Val.eq vres (Vint Int.zero)) as [Z | NZ]; [left; exact Z | right].
  split; [| exact (inputs_ok_keep bm m0 m' K1 K2 I)].
  intros y fh Ly Lf. rewrite Y in Ly. rewrite H in Lf.
  destruct (F y fh Ly Lf) as (A & [B | B]); [exfalso; exact (NZ (S B)) |].
  split; [exact A | right; exact B].
Qed.

(* ... for a handler entered in a constant action other than SOFT_BONK *)
Lemma fresh_ret_ns : forall bm m0 m' vres n,
  Mem.load Mint32 m0 bm 12 = Some (Vint (Int.repr n)) ->
  Int.eq (Int.repr n) (Int.repr SB_ACT) = false ->
  fresh bm m0 -> RET bm m0 m' vres ->
  Mem.load Mint16signed m' bm WL_OFF = Mem.load Mint16signed m0 bm WL_OFF ->
  Mem.load Mint16unsigned m' bm 2 = Mem.load Mint16unsigned m0 bm 2 ->
  vres = Vint Int.zero \/ fresh bm m'.
Proof.
  intros bm m0 m' vres n L N F R K1 K2. apply (fresh_ret bm m0 m' vres F R); [| exact K1 | exact K2].
  intros L'. rewrite L in L'. assert (E : Int.repr n = Int.repr SB_ACT) by congruence.
  rewrite E, Int.eq_true in N. discriminate N.
Qed.

(* the frame world's level cells (2026-10-23, ProRows): gCurrLevelNum is
   LEVEL_WMOTR and sound_init.c's sPlayingInfiniteStairs is FALSE.  What
   the real play_infinite_stairs_music, which execute_mario_action calls
   every frame, reads to stay out of the audio code: it plays (or stops)
   the endless-stairs music only in the castle (LEVEL_CASTLE = 6) or when
   sPlayingInfiniteStairs differs from its verdict.
   FOUND (phantom forall): FrameSplit.seg_any_rows asked the real call to
   keep the frame world from ANY fworld memory; fworld did not constrain
   gCurrLevelNum, so a castle memory (area 2, under 70 stars, room 6,
   z < 2540) or one with sPlayingInfiniteStairs = 1 sent it into
   play_secondary_music / func_80321080 and the sequence player (the
   unlinked load_sequence: GOAL 1's Hls keeps mem_ok, not the frame
   world) -- the row was not provable as stated.  In the game the level is
   WMotR for the whole visit (HeightFrame.in_wmotr), and the flag is FALSE
   at the visit's entry (the castle's last frame clears it: Mario enters
   the painting away from the endless stairs) and stays FALSE (the call's
   verdict outside the castle is FALSE). *)
Definition lvl_w (G : genv) (m : mem) : Prop :=
  (forall b, Genv.find_symbol G mario._gCurrLevelNum = Some b ->
     Mem.load Mint16signed m b 0 = Some (Vint (Int.repr LEVEL_WMOTR)))
  /\ (forall b, Genv.find_symbol G sound_init._sPlayingInfiniteStairs = Some b ->
     Mem.load Mint8unsigned m b 0 = Some (Vint Int.zero)).
