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
From SM64.Generated Require mario surface_collision memory camera audio_external sound_init level_update
  game_init libultra_osContInit.
From SM64.Proofs Require Import HeightInvariant HeightMoveCatalog WMotRLevel Generic.ClosedMem.
From SM64.Proofs.WMotRRequiresA Require Import FloorList FloorHeight FloorExec AirMatch AirStart RetOk.
Import ListNotations.

(* the level-phase globals the frame world pins (lvl_w below): blocks of
   their own, which no proved row writes.  The first two since 2026-10-23;
   the warp cells since 2026-10-24; the controller globals since
   2026-10-23 (ctl_w; the poll, PollFlank, writes only gControllers'
   button cells and the pads, which ctl_w re-establishes). *)
Definition lvl_ids : list ident :=
  [mario._gCurrLevelNum; sound_init._sPlayingInfiniteStairs;
   level_update._sWarpDest; level_update._sCurrPlayMode; level_update._sDelayedWarpOp;
   level_update._sSourceWarpNodeId; level_update._gCurrDemoInput; level_update._gCurrCreditsEntry;
   (* the controller globals (ctl_w, 2026-10-23, PollFlank: the real
      controller poll reads them; gCurrDemoInput is above) *)
   mario._gControllers; game_init._gControllerPads; game_init._gPlayer1Controller;
   game_init._gPlayer3Controller; libultra_osContInit.___osMaxControllers].

Definition lvl_sym (G : genv) (b : block) : Prop :=
  exists id, In id lvl_ids /\ Genv.find_symbol G id = Some b.

Lemma lvl_sym_ids : forall (G : genv) b, lvl_sym G b -> exists id, In id lvl_ids /\ Genv.find_symbol G id = Some b.
Proof. intros G b H. exact H. Qed.

Lemma lvl_sym_of : forall (G : genv) id b, In id lvl_ids -> Genv.find_symbol G id = Some b -> lvl_sym G b.
Proof. intros G id b Hin H. exists id. split; [exact Hin | exact H]. Qed.

(* split a lvl_sym hypothesis into one goal per concrete global *)
Ltac lvl_cases H :=
  let id := fresh "id" in let Hin := fresh "Hin" in
  apply lvl_sym_ids in H; destruct H as (id & Hin & H);
  unfold lvl_ids in Hin; cbn [In] in Hin;
  repeat (destruct Hin as [<- | Hin]); try contradiction.

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

(* the walk's fifteen regions as pointers, in FfRun.R0F's order (two since
   camera.c is linked: gLakituState, which the real
   set_camera_shake_from_hit writes, and gPlayerCameraState, the
   m->statusForCamera the ledge climbs and the cannon write through; the
   last three since audio/external.c is linked: sSoundRequests,
   sSoundRequestCount and sSoundMovingSpeed, which the real play_sound and
   set_sound_moving_speed write; the sixteenth, 2026-10-23: gBodyStates,
   m->marioBodyState's target, which mario_reset_bodystate and
   update_mario_info_for_cam write through) *)
Definition ff_rl (bm bo : block) (oo : ptrofs) (bfi bmiss bcalls ab bt biom bmq brm blk bpc bsr bsrc bsms bbs : block)
  : list (option val) :=
  map Some [Vptr bm Ptrofs.zero; Vptr bo oo; Vptr bfi Ptrofs.zero; Vptr bmiss Ptrofs.zero;
            Vptr bcalls Ptrofs.zero; Vptr ab Ptrofs.zero; Vptr bt Ptrofs.zero;
            Vptr biom Ptrofs.zero; Vptr bmq Ptrofs.zero; Vptr brm Ptrofs.zero;
            Vptr blk Ptrofs.zero; Vptr bpc Ptrofs.zero;
            Vptr bsr Ptrofs.zero; Vptr bsrc Ptrofs.zero; Vptr bsms Ptrofs.zero;
            Vptr bbs Ptrofs.zero].

(* a world object: a valid block that is none of the regions *)
Definition wblk (m : mem) (rl : list (option val)) (v : val) (n : Z) : Prop :=
  exists b o, v = Vptr b o /\ Plt b (Mem.nextblock m) /\ 0 <= n
    /\ Ptrofs.unsigned o + n <= Ptrofs.modulus /\ ~ rblk rl b.

(* ---- the frame world's witnesses, as one record (2026-10-24) ----------- *)
(* HOW TO ADD AN ffw FACT (see also .claude/skills/proof-discipline):
     1. a new witness (a block, a value): a field of `ffw_wit` below, plus
        its name in `ffw_unpack`'s destruct of d (end of this file's FFW
        part) and in `ffw_rebuild`'s `mk_ffw_wit` (it copies d's fields);
     2. a new fact: a field of `ffw_facts`, plus its hypothesis name in
        `ffw_unpack` (pose proof ... as [...] and the cbn list); a
        memory-free fact needs nothing else (`ffw_rebuild`'s closer takes it
        from F by `assumption`);
     3. if the fact READS memory: the cell goes in `ffw_bm_cells` (a cell of
        Mario's state block) or a new disjunct of `ffw_read` (a cell
        elsewhere: then also `ffw_read_split`); every keep proof then gets
        one more goal "this cell is unchanged", closed by its own closer;
     4. StartSat.ffw11 establishes the new fact at the start.
   Consumers never destruct ffw positionally: `ffw_unpack EX` names every
   witness and fact (gp, bfi, ..., HC, S1, ..., LBS) and keeps the record
   hypothesis FWF; they rebuild ffw with `ffw_rebuild` / `ffw_rebuild_off` /
   `ffw_keep_off`, whose premises are about the read set, not the list of
   conjuncts. *)
Record ffw_wit : Type := mk_ffw_wit {
  fw_gp : meminj;
  fw_bfi : block; fw_bmiss : block; fw_bcalls : block; fw_bsin : block; fw_ab : block;
  fw_biom : block; fw_bmq : block; fw_brm : block; fw_blk : block; fw_bpc : block;
  fw_bsr : block; fw_bsrc : block; fw_bsms : block; fw_bbs : block;
  fw_bo : block; fw_oo : ptrofs; fw_bt : block; fw_ot : ptrofs;
  fw_fl : val; fw_ar : val; fw_inp : int; fw_ctl : val }.

(* the walk's region list, of a witness record *)
Definition ff_rl_of (bm : block) (d : ffw_wit) : list (option val) :=
  ff_rl bm (fw_bo d) (fw_oo d) (fw_bfi d) (fw_bmiss d) (fw_bcalls d) (fw_ab d) (fw_bt d)
    (fw_biom d) (fw_bmq d) (fw_brm d) (fw_blk d) (fw_bpc d) (fw_bsr d) (fw_bsrc d) (fw_bsms d) (fw_bbs d).

(* the globals among the regions (all but Mario's state, his object and
   the animation buffer) *)
Definition ffw_reg_ids : list ident :=
  [surface_collision._gFindFloorIncludeSurfaceIntangible; surface_collision._gNumFindFloorMisses;
   surface_collision._gNumCalls; mario._gMarioAnimsBuf; memory._gDmaIoMesg; memory._gDmaMesgQueue;
   memory._gMainReceivedMesg; camera._gLakituState; camera._gPlayerCameraState;
   audio_external._sSoundRequests; audio_external._sSoundRequestCount; audio_external._sSoundMovingSpeed;
   mario._gBodyStates].

(* the cells of Mario's state block ffw reads (besides the surface cells
   floor / wall / ceil, ffw_surf_cells) *)
Definition ffw_bm_cells : list (Z * memory_chunk) :=
  [(FFW_OBJ, Mint32); (FFW_ANIM, Mint32); (FFW_AREA, Mint32); (2, Mint16unsigned);
   (FFW_CTL, Mint32); (FFW_PCS, Mint32); (FFW_BODY, Mint32)].
Definition ffw_surf_cells : list (Z * memory_chunk) :=
  [(FFW_FLOOR, Mint32); (FFW_WALL, Mint32); (FFW_CEIL, Mint32)].

Section FFW.
Variable G : genv.
Variable bm : block.

Record ffw_facts (m : mem) (d : ffw_wit) : Prop := mk_ffw_facts {
  (* closedness *)
  ff_HC : closed_by (fw_gp d) m;
  ff_HS : forall id b, Genv.find_symbol G id = Some b -> fw_gp d b <> None;
  ff_HM : fw_gp d bm <> None;
  ff_S1 : Genv.find_symbol G surface_collision._gFindFloorIncludeSurfaceIntangible = Some (fw_bfi d);
  ff_S2 : Genv.find_symbol G surface_collision._gNumFindFloorMisses = Some (fw_bmiss d);
  ff_S3 : Genv.find_symbol G surface_collision._gNumCalls = Some (fw_bcalls d);
  ff_S4 : Genv.find_symbol G mario._gSineTable = Some (fw_bsin d);
  ff_S5 : Genv.find_symbol G mario._gMarioAnimsBuf = Some (fw_ab d);
  ff_S6 : Genv.find_symbol G memory._gDmaIoMesg = Some (fw_biom d);
  ff_S7 : Genv.find_symbol G memory._gDmaMesgQueue = Some (fw_bmq d);
  ff_S8 : Genv.find_symbol G memory._gMainReceivedMesg = Some (fw_brm d);
  ff_SL : Genv.find_symbol G camera._gLakituState = Some (fw_blk d);
  ff_SP : Genv.find_symbol G camera._gPlayerCameraState = Some (fw_bpc d);
  ff_SR : Genv.find_symbol G audio_external._sSoundRequests = Some (fw_bsr d);
  ff_SRC : Genv.find_symbol G audio_external._sSoundRequestCount = Some (fw_bsrc d);
  ff_SMS : Genv.find_symbol G audio_external._sSoundMovingSpeed = Some (fw_bsms d);
  ff_SBS : Genv.find_symbol G mario._gBodyStates = Some (fw_bbs d);
  (* Mario's object; the animation list and its DMA buffer *)
  ff_Lo : Mem.load Mint32 m bm FFW_OBJ = Some (Vptr (fw_bo d) (fw_oo d));
  ff_Soo : Ptrofs.unsigned (fw_oo d) + SZ_OBJECT <= Ptrofs.modulus;
  ff_La : Mem.load Mint32 m bm FFW_ANIM = Some (Vptr (fw_ab d) Ptrofs.zero);
  ff_Lb : Mem.load Mint32 m (fw_ab d) 8 = Some (Vptr (fw_bt d) (fw_ot d));
  ff_Sot : Ptrofs.unsigned (fw_ot d) + 24 <= Ptrofs.modulus;
  (* the object and the buffer are blocks of their own *)
  ff_D1 : fw_bo d <> bm;
  ff_D2 : fw_bt d <> bm;
  ff_D3 : fw_bt d <> fw_bo d;
  (* (gAudioRandom too: play_mario_jump_sound reads it, a world cell) *)
  ff_D4 : forall b, In b [fw_bfi d; fw_bmiss d; fw_bcalls d; fw_bsin d; fw_ab d; fw_biom d; fw_bmq d;
                          fw_brm d; fw_blk d; fw_bpc d; fw_bsr d; fw_bsrc d; fw_bsms d; fw_bbs d]
                \/ Genv.find_symbol G mario._gAudioRandom = Some b
                (* gCurrLevelNum: add_tree_leaf_particles reads it (the pole walks);
                   sPlayingInfiniteStairs: play_infinite_stairs_music reads it (lvl_w);
                   the warp and controller globals (lvl_w's warp_w / ctl_w) *)
                \/ lvl_sym G b -> b <> fw_bo d /\ b <> fw_bt d;
  (* the collision partition *)
  ff_W : Wff G m (fw_gp d) SZ_SURFACE (ff_rl_of bm d);
  (* m->floor, m->area *)
  ff_Lf : Mem.load Mint32 m bm FFW_FLOOR = Some (fw_fl d);
  ff_Wf : wblk m (ff_rl_of bm d) (fw_fl d) SZ_SURFACE;
  (* m->wall, m->ceil *)
  ff_Wc0 : forall off sb so, off = FFW_WALL \/ off = FFW_CEIL -> Mem.load Mint32 m bm off = Some (Vptr sb so) ->
             ~ rblk (ff_rl_of bm d) sb;
  ff_Lar : Mem.load Mint32 m bm FFW_AREA = Some (fw_ar d);
  ff_War : wblk m (ff_rl_of bm d) (fw_ar d) SZ_AREA;
  (* m->input: INPUT_A_PRESSED | INPUT_A_DOWN | INPUT_INTERACT_OBJ_GRABBABLE clear *)
  ff_Li : Mem.load Mint16unsigned m bm 2 = Some (Vint (fw_inp d));
  ff_Ai : Int.and (fw_inp d) (Int.repr 2178) = Int.zero;
  (* m->controller *)
  ff_Lc : Mem.load Mint32 m bm FFW_CTL = Some (fw_ctl d);
  ff_Wc : wblk m (ff_rl_of bm d) (fw_ctl d) SZ_CTL;
  (* the collided objects *)
  ff_Co : forall i cb co, 0 <= i < 4 ->
            Mem.load Mint32 m (fw_bo d) (Ptrofs.unsigned (fw_oo d) + FFW_COLL + 4 * i) = Some (Vptr cb co) ->
            cb = fw_bo d;
  (* m->statusForCamera = &gPlayerCameraState[0] (init_mario_from_save_file,
     mario.c; nothing else writes the cell) *)
  ff_LPC : Mem.load Mint32 m bm FFW_PCS = Some (Vptr (fw_bpc d) Ptrofs.zero);
  (* m->marioBodyState = &gBodyStates[0] (init_mario_from_save_file,
     mario.c; nothing else writes the cell).  2026-10-23: FOUND (phantom
     forall) -- without it (and gBodyStates as a region) the per-call rows
     of mario_reset_bodystate / update_mario_info_for_cam ranged over
     memories whose marioBodyState pointed into Mario's own state or a
     surface, which the real stores through it then break *)
  ff_LBS : Mem.load Mint32 m bm FFW_BODY = Some (Vptr (fw_bbs d) Ptrofs.zero) }.

Definition ffw (m : mem) : Prop :=
  Ple (Genv.genv_next G) (Mem.nextblock m)
  /\ (exists d, ffw_facts m d)
  /\ floor_data G m.

(* ---- the regions, of a witness record ---- *)

Lemma ffw_rl_bm : forall d, rblk (ff_rl_of bm d) bm.
Proof. intros d. exists Ptrofs.zero. cbn. auto. Qed.

Lemma ffw_rl_bo : forall d, rblk (ff_rl_of bm d) (fw_bo d).
Proof. intros d. exists (fw_oo d). cbn. auto. Qed.

Lemma ffw_rl_bt : forall d, rblk (ff_rl_of bm d) (fw_bt d).
Proof. intros d. exists Ptrofs.zero. cbn. auto 10. Qed.

(* ... keyed on the facts (so the record need not be named) *)
Lemma ffw_rlF_bm : forall m d, ffw_facts m d -> rblk (ff_rl_of bm d) bm.
Proof. intros m d _. apply ffw_rl_bm. Qed.

Lemma ffw_rlF_bo : forall m d, ffw_facts m d -> rblk (ff_rl_of bm d) (fw_bo d).
Proof. intros m d _. apply ffw_rl_bo. Qed.

Lemma ffw_rlF_bt : forall m d, ffw_facts m d -> rblk (ff_rl_of bm d) (fw_bt d).
Proof. intros m d _. apply ffw_rl_bt. Qed.

(* every region is Mario's state, his object, the buffer, or a global of
   ffw_reg_ids *)
Lemma ffw_rl_cases : forall m d x, ffw_facts m d -> rblk (ff_rl_of bm d) x ->
  x = bm \/ x = fw_bo d \/ x = fw_bt d
  \/ exists id, In id ffw_reg_ids /\ Genv.find_symbol G id = Some x.
Proof.
  intros m d x F (o & Hin).
  pose proof (ff_S1 _ _ F). pose proof (ff_S2 _ _ F). pose proof (ff_S3 _ _ F). pose proof (ff_S5 _ _ F).
  pose proof (ff_S6 _ _ F). pose proof (ff_S7 _ _ F). pose proof (ff_S8 _ _ F). pose proof (ff_SL _ _ F).
  pose proof (ff_SP _ _ F). pose proof (ff_SR _ _ F). pose proof (ff_SRC _ _ F). pose proof (ff_SMS _ _ F).
  pose proof (ff_SBS _ _ F).
  unfold ff_rl_of, ff_rl in Hin. cbn [map In] in Hin.
  repeat (destruct Hin as [E | Hin];
          [ injection E as E _; subst x;
            first [ left; reflexivity | right; left; reflexivity | right; right; left; reflexivity
                  | right; right; right; eexists; split; [| eassumption]; unfold ffw_reg_ids; cbn [In]; auto 20 ]
          | ]).
  destruct Hin.
Qed.

(* a global of ffw_reg_ids is a region *)
Lemma ffw_rl_sym : forall m d id b, ffw_facts m d -> In id ffw_reg_ids ->
  Genv.find_symbol G id = Some b -> rblk (ff_rl_of bm d) b.
Proof.
  intros m d id b F Hin Hs. exists Ptrofs.zero.
  pose proof (ff_S1 _ _ F) as S1. pose proof (ff_S2 _ _ F) as S2. pose proof (ff_S3 _ _ F) as S3.
  pose proof (ff_S5 _ _ F) as S5. pose proof (ff_S6 _ _ F) as S6. pose proof (ff_S7 _ _ F) as S7.
  pose proof (ff_S8 _ _ F) as S8. pose proof (ff_SL _ _ F) as SL. pose proof (ff_SP _ _ F) as SP.
  pose proof (ff_SR _ _ F) as SR. pose proof (ff_SRC _ _ F) as SRC. pose proof (ff_SMS _ _ F) as SMS.
  pose proof (ff_SBS _ _ F) as SBS.
  unfold ffw_reg_ids in Hin. cbn [In] in Hin.
  repeat (destruct Hin as [<- | Hin];
          [ first [ rewrite S1 in Hs | rewrite S2 in Hs | rewrite S3 in Hs | rewrite S5 in Hs
                  | rewrite S6 in Hs | rewrite S7 in Hs | rewrite S8 in Hs | rewrite SL in Hs
                  | rewrite SP in Hs | rewrite SR in Hs | rewrite SRC in Hs | rewrite SMS in Hs
                  | rewrite SBS in Hs ];
            injection Hs as <-; unfold ff_rl_of, ff_rl; cbn [map In]; auto 20
          | ]).
  destruct Hin.
Qed.

(* ... and is not Mario's object or the buffer (ffw's D4) *)
Lemma ffw_reg_apart : forall m d id b, ffw_facts m d -> In id ffw_reg_ids ->
  Genv.find_symbol G id = Some b -> b <> fw_bo d /\ b <> fw_bt d.
Proof.
  intros m d id b F Hin Hs. apply (ff_D4 _ _ F). left.
  pose proof (ff_S1 _ _ F) as S1. pose proof (ff_S2 _ _ F) as S2. pose proof (ff_S3 _ _ F) as S3.
  pose proof (ff_S5 _ _ F) as S5. pose proof (ff_S6 _ _ F) as S6. pose proof (ff_S7 _ _ F) as S7.
  pose proof (ff_S8 _ _ F) as S8. pose proof (ff_SL _ _ F) as SL. pose proof (ff_SP _ _ F) as SP.
  pose proof (ff_SR _ _ F) as SR. pose proof (ff_SRC _ _ F) as SRC. pose proof (ff_SMS _ _ F) as SMS.
  pose proof (ff_SBS _ _ F) as SBS.
  unfold ffw_reg_ids in Hin. cbn [In] in Hin.
  repeat (destruct Hin as [<- | Hin];
          [ first [ rewrite S1 in Hs | rewrite S2 in Hs | rewrite S3 in Hs | rewrite S5 in Hs
                  | rewrite S6 in Hs | rewrite S7 in Hs | rewrite S8 in Hs | rewrite SL in Hs
                  | rewrite SP in Hs | rewrite SR in Hs | rewrite SRC in Hs | rewrite SMS in Hs
                  | rewrite SBS in Hs ];
            injection Hs as <-; cbn [In]; auto 20
          | ]).
  destruct Hin.
Qed.

(* a block that is none of the regions *)
Lemma ffw_rl_not : forall m d x, ffw_facts m d -> x <> bm -> x <> fw_bo d -> x <> fw_bt d ->
  (forall id, In id ffw_reg_ids -> Genv.find_symbol G id <> Some x) -> ~ rblk (ff_rl_of bm d) x.
Proof.
  intros m d x F N1 N2 N3 N4 R.
  destruct (ffw_rl_cases m d x F R) as [E | [E | [E | (id & Hin & Hs)]]];
    [exact (N1 E) | exact (N2 E) | exact (N3 E) | exact (N4 id Hin Hs)].
Qed.

(* ... a global outside ffw_reg_ids *)
Lemma ffw_rl_not_sym : forall m d id x, ffw_facts m d -> Genv.find_symbol G id = Some x ->
  existsb (Pos.eqb id) ffw_reg_ids = false -> x <> bm -> x <> fw_bo d -> x <> fw_bt d ->
  ~ rblk (ff_rl_of bm d) x.
Proof.
  intros m d id x F Hs Hn N1 N2 N3. apply (ffw_rl_not m d x F N1 N2 N3).
  intros id' Hin Hs'.
  assert (E : id' = id) by (eapply Genv.genv_vars_inj; [exact Hs' | exact Hs]). subst id'.
  assert (T : existsb (Pos.eqb id) ffw_reg_ids = true)
    by (apply existsb_exists; exists id; split; [exact Hin | apply Pos.eqb_refl]).
  rewrite T in Hn. discriminate Hn.
Qed.

(* ---- rebuilding ffw at a later memory ---------------------------------- *)
(* the cells ffw reads inside the regions (besides the surface cells):
   Mario's state (ffw_bm_cells), the animation list's dmaTable cell, and
   his object's collided-object cells *)
Definition ffw_read (d : ffw_wit) (ch : memory_chunk) (b : block) (z : Z) : Prop :=
  (b = bm /\ In (z, ch) ffw_bm_cells)
  \/ (b = fw_ab d /\ z = 8 /\ ch = Mint32)
  \/ (b = fw_bo d /\ ch = Mint32
      /\ exists i, 0 <= i < 4 /\ z = Ptrofs.unsigned (fw_oo d) + FFW_COLL + 4 * i).

(* ... and with the surface cells *)
Definition ffw_read_s (d : ffw_wit) (ch : memory_chunk) (b : block) (z : Z) : Prop :=
  ffw_read d ch b z \/ (b = bm /\ In (z, ch) ffw_surf_cells).

Definition ffw_kept (d : ffw_wit) (m m' : mem) : Prop :=
  forall ch b z, ffw_read d ch b z -> Mem.load ch m' b z = Mem.load ch m b z.

Definition ffw_kept_s (d : ffw_wit) (m m' : mem) : Prop :=
  forall ch b z, ffw_read_s d ch b z -> Mem.load ch m' b z = Mem.load ch m b z.

(* the surface cells after: the floor a world surface (of the old memory),
   the wall and the ceiling, when pointers, off the regions *)
Definition ffw_surf_ok (d : ffw_wit) (m m' : mem) : Prop :=
  (exists fl', Mem.load Mint32 m' bm FFW_FLOOR = Some fl' /\ wblk m (ff_rl_of bm d) fl' SZ_SURFACE)
  /\ (forall off sb so, off = FFW_WALL \/ off = FFW_CEIL ->
        Mem.load Mint32 m' bm off = Some (Vptr sb so) -> ~ rblk (ff_rl_of bm d) sb).

Lemma wblk_mono : forall m m' rl v n, Ple (Mem.nextblock m) (Mem.nextblock m') ->
  wblk m rl v n -> wblk m' rl v n.
Proof.
  intros m m' rl v n H (b & o & -> & P & R). exists b, o.
  split; [reflexivity |]. split; [exact (Plt_Ple_trans _ _ _ P H) | exact R].
Qed.

Lemma ffw_surf_ok_kept : forall m m' d, ffw_facts m d ->
  (forall z ch, In (z, ch) ffw_surf_cells -> Mem.load ch m' bm z = Mem.load ch m bm z) ->
  ffw_surf_ok d m m'.
Proof.
  intros m m' d F K. split.
  - exists (fw_fl d). split; [| exact (ff_Wf _ _ F)].
    rewrite K by (unfold ffw_surf_cells; cbn [In]; auto). exact (ff_Lf _ _ F).
  - intros off sb so Hoff Hl. rewrite K in Hl.
    + exact ((ff_Wc0 _ _ F) off sb so Hoff Hl).
    + unfold ffw_surf_cells. cbn [In]. destruct Hoff as [-> | ->]; auto.
Qed.

(* THE REBUILD: ffw holds at m' when m' keeps the read set, the world facts
   (Wff, floor_data) hold there, memory only grew, and the closing
   injection grew *)
Theorem ffw_rebuild : forall m m' d gp',
  ffw_facts m d ->
  Ple (Genv.genv_next G) (Mem.nextblock m') ->
  Ple (Mem.nextblock m) (Mem.nextblock m') ->
  (forall b, fw_gp d b <> None -> gp' b <> None) -> closed_by gp' m' ->
  Wff G m' gp' SZ_SURFACE (ff_rl_of bm d) -> floor_data G m' ->
  ffw_kept d m m' -> ffw_surf_ok d m m' ->
  ffw m'.
Proof.
  intros m m' d gp' F Hgn Hnb Hinc HC' W' FD' K ((fl' & Lf' & Wf') & WC').
  assert (KM : forall z ch, In (z, ch) ffw_bm_cells -> Mem.load ch m' bm z = Mem.load ch m bm z)
    by (intros z ch H; apply K; left; split; [reflexivity | exact H]).
  split; [exact Hgn |]. split; [| exact FD'].
  exists (mk_ffw_wit gp' (fw_bfi d) (fw_bmiss d) (fw_bcalls d) (fw_bsin d) (fw_ab d) (fw_biom d)
            (fw_bmq d) (fw_brm d) (fw_blk d) (fw_bpc d) (fw_bsr d) (fw_bsrc d) (fw_bsms d) (fw_bbs d)
            (fw_bo d) (fw_oo d) (fw_bt d) (fw_ot d) fl' (fw_ar d) (fw_inp d) (fw_ctl d)).
  (* every field: unchanged (memory-free), a kept cell, or the new value;
     the closer below does not depend on the field order *)
  pose proof F as F0. destruct F0.
  eapply mk_ffw_facts;
    cbn [fw_gp fw_bfi fw_bmiss fw_bcalls fw_bsin fw_ab fw_biom fw_bmq fw_brm fw_blk fw_bpc
         fw_bsr fw_bsrc fw_bsms fw_bbs fw_bo fw_oo fw_bt fw_ot fw_fl fw_ar fw_inp fw_ctl];
    first [ assumption | exact HC' | exact W' | exact Lf' | exact WC'
          | exact (wblk_mono _ _ _ _ _ Hnb Wf')
          | apply (wblk_mono _ _ _ _ _ Hnb); assumption
          | apply Hinc; assumption
          | let id := fresh "id" in let b := fresh "b" in let Hs := fresh "Hs" in
            intros id b Hs; exact (Hinc b (ff_HS _ _ F id b Hs))
          | rewrite KM by (unfold ffw_bm_cells; cbn [In]; auto 10); assumption
          | rewrite K by (right; left; auto); assumption
          | let i := fresh "i" in let cb := fresh "cb" in let co := fresh "co" in
            let Hi := fresh "Hi" in let Hl := fresh "Hl" in
            intros i cb co Hi Hl; rewrite K in Hl;
            [ match goal with H : forall i' cb' co', 0 <= i' < 4 -> _ -> cb' = _ |- _ =>
                exact (H i cb co Hi Hl) end
            | right; right; split; [reflexivity |]; split; [reflexivity |]; exists i; auto ] ].
Qed.

(* ---- transfer: a memory that differs from m only inside Mario's object ---- *)

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
  intros Hmo Hne Hab HC' (Hgn & (d & F) & FD).
  pose proof (ff_Lo _ _ F) as Lo. rewrite Hmo in Lo. injection Lo as Ebo Eoo.
  assert (Ho : rblk (ff_rl_of bm d) bo0) by (rewrite Ebo; apply ffw_rl_bo).
  assert (Gbo : fw_gp d bo0 = Some (bo0, 0)).
  { pose proof (closed_load _ _ _ _ _ _ (ff_HC _ _ F) (ff_HM _ _ F) Hmo) as P. cbn in P.
    destruct (fw_gp d bo0) as [[b' dl]|] eqn:G0; [| congruence].
    destruct (closed_flat _ _ _ _ _ (ff_HC _ _ F) G0) as (-> & ->). reflexivity. }
  pose proof (Hab _ (ff_S5 _ _ F)) as Hab0.
  apply (ffw_rebuild m m' d (fw_gp d) F).
  - rewrite Hnb. exact Hgn.
  - rewrite Hnb. apply Ple_refl.
  - exact (fun b H => H).
  - exact (HC' _ (ff_HC _ _ F) Gbo).
  - exact (Wff_keep _ _ Ho (ff_W _ _ F)).
  - exact (floor_data_keep _ _ Ho (ff_W _ _ F) FD).
  - intros ch b z [(-> & _) | [(-> & -> & ->) | (-> & -> & i & Hi & ->)]].
    + apply Hld. congruence.
    + apply Hld. exact Hab0.
    + rewrite <- Ebo, <- Eoo. exact (Hldc i Hi).
  - apply (ffw_surf_ok_kept m m' d F). intros z ch _. apply Hld. congruence.
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

(* THE REBUILD over a frame: m' agrees with m off the regions (what a walk
   over ff_rl leaves), keeps the read set and only grew *)
Theorem ffw_rebuild_off : forall m m' d gp',
  Ple (Genv.genv_next G) (Mem.nextblock m) -> ffw_facts m d -> floor_data G m ->
  Ple (Mem.nextblock m) (Mem.nextblock m') ->
  (forall b ofs k p, Plt b (Mem.nextblock m) -> Mem.perm m b ofs k p -> Mem.perm m' b ofs k p) ->
  (forall ch b z, Plt b (Mem.nextblock m) -> ~ rblk (ff_rl_of bm d) b ->
     Mem.load ch m' b z = Mem.load ch m b z) ->
  (forall b, fw_gp d b <> None -> gp' b <> None) -> closed_by gp' m' ->
  ffw_kept d m m' -> ffw_surf_ok d m m' ->
  ffw m'.
Proof.
  intros m m' d gp' Hgn F FD Hnb Hperm Hld Hinc HC' K S.
  apply (ffw_rebuild m m' d gp' F (Ple_trans _ _ _ Hgn Hnb) Hnb Hinc HC'); [| | exact K | exact S].
  - exact (Wff_keep2 m m' _ Hnb Hperm Hld _ _ Hinc (ff_W _ _ F)).
  - exact (floor_data_keep2 m m' _ Hnb Hperm Hld _ (ff_W _ _ F) FD).
Qed.

(* ... and the surface cells kept too *)
Theorem ffw_keep_off : forall m m' d gp',
  Ple (Genv.genv_next G) (Mem.nextblock m) -> ffw_facts m d -> floor_data G m ->
  Ple (Mem.nextblock m) (Mem.nextblock m') ->
  (forall b ofs k p, Plt b (Mem.nextblock m) -> Mem.perm m b ofs k p -> Mem.perm m' b ofs k p) ->
  (forall ch b z, Plt b (Mem.nextblock m) -> ~ rblk (ff_rl_of bm d) b ->
     Mem.load ch m' b z = Mem.load ch m b z) ->
  (forall b, fw_gp d b <> None -> gp' b <> None) -> closed_by gp' m' ->
  ffw_kept_s d m m' ->
  ffw m'.
Proof.
  intros m m' d gp' Hgn F FD Hnb Hperm Hld Hinc HC' K.
  apply (ffw_rebuild_off m m' d gp' Hgn F FD Hnb Hperm Hld Hinc HC').
  - intros ch b z H. apply K. left. exact H.
  - apply (ffw_surf_ok_kept m m' d F). intros z ch H. apply K. right. split; [reflexivity | exact H].
Qed.
End FFW.

(* ---- consumer tactics -------------------------------------------------- *)
(* ffw_unpack EX, for EX : exists d, ffw_facts G bm m d: names every witness
   and fact (fresh names, so a name taken in the context gets a suffix) and
   keeps the record hypothesis FWF : ffw_facts G bm m {| ... |}, which the
   rebuild lemmas take.  Adding a field touches only this tactic. *)
Ltac ffw_unpack EX :=
  let d := fresh "d" in let FWF := fresh "FWF" in
  destruct EX as [d FWF];
  let gp := fresh "gp" in let bfi := fresh "bfi" in let bmiss := fresh "bmiss" in
  let bcalls := fresh "bcalls" in let bsin := fresh "bsin" in let ab := fresh "ab" in
  let biom := fresh "biom" in let bmq := fresh "bmq" in let brm := fresh "brm" in
  let blk := fresh "blk" in let bpc := fresh "bpc" in let bsr := fresh "bsr" in
  let bsrc := fresh "bsrc" in let bsms := fresh "bsms" in let bbs := fresh "bbs" in
  let bo := fresh "bo" in let oo := fresh "oo" in let bt := fresh "bt" in let ot := fresh "ot" in
  let fl := fresh "fl" in let ar := fresh "ar" in let inp := fresh "inp" in let ctl := fresh "ctl" in
  destruct d as [gp bfi bmiss bcalls bsin ab biom bmq brm blk bpc bsr bsrc bsms bbs bo oo bt ot fl ar inp ctl];
  let HC := fresh "HC" in let HS := fresh "HS" in let HM := fresh "HM" in
  let S1 := fresh "S1" in let S2 := fresh "S2" in let S3 := fresh "S3" in let S4 := fresh "S4" in
  let S5 := fresh "S5" in let S6 := fresh "S6" in let S7 := fresh "S7" in let S8 := fresh "S8" in
  let SL := fresh "SL" in let SP := fresh "SP" in let SR := fresh "SR" in let SRC := fresh "SRC" in
  let SMS := fresh "SMS" in let SBS := fresh "SBS" in
  let Lo := fresh "Lo" in let Soo := fresh "Soo" in let La := fresh "La" in let Lb := fresh "Lb" in
  let Sot := fresh "Sot" in let D1 := fresh "D1" in let D2 := fresh "D2" in let D3 := fresh "D3" in
  let D4 := fresh "D4" in let W := fresh "W" in let Lf := fresh "Lf" in let Wf := fresh "Wf" in
  let Wc0 := fresh "Wc0" in let Lar := fresh "Lar" in let War := fresh "War" in let Li := fresh "Li" in
  let Ai := fresh "Ai" in let Lc := fresh "Lc" in let Wc := fresh "Wc" in let Co := fresh "Co" in
  let LPC := fresh "LPC" in let LBS := fresh "LBS" in
  pose proof FWF as [HC HS HM S1 S2 S3 S4 S5 S6 S7 S8 SL SP SR SRC SMS SBS Lo Soo La Lb Sot D1 D2 D3 D4
                     W Lf Wf Wc0 Lar War Li Ai Lc Wc Co LPC LBS];
  (cbn [ff_rl_of fw_gp fw_bfi fw_bmiss fw_bcalls fw_bsin fw_ab fw_biom fw_bmq fw_brm fw_blk fw_bpc
        fw_bsr fw_bsrc fw_bsms fw_bbs fw_bo fw_oo fw_bt fw_ot fw_fl fw_ar fw_inp fw_ctl]
     in HC, HS, HM, S1, S2, S3, S4, S5, S6, S7, S8, SL, SP, SR, SRC, SMS, SBS, Lo, Soo, La, Lb, Sot,
        D1, D2, D3, D4, W, Lf, Wf, Wc0, Lar, War, Li, Ai, Lc, Wc, Co, LPC, LBS).

(* reduce the record's projections (and ff_rl_of) in a hypothesis / the goal *)
Ltac ffw_simpl_in H :=
  cbn [ff_rl_of fw_gp fw_bfi fw_bmiss fw_bcalls fw_bsin fw_ab fw_biom fw_bmq fw_brm fw_blk fw_bpc
       fw_bsr fw_bsrc fw_bsms fw_bbs fw_bo fw_oo fw_bt fw_ot fw_fl fw_ar fw_inp fw_ctl] in H.
Ltac ffw_simpl :=
  cbn [ff_rl_of fw_gp fw_bfi fw_bmiss fw_bcalls fw_bsin fw_ab fw_biom fw_bmq fw_brm fw_blk fw_bpc
       fw_bsr fw_bsrc fw_bsms fw_bbs fw_bo fw_oo fw_bt fw_ot fw_fl fw_ar fw_inp fw_ctl].

(* ... from ffw itself: Hgn, the facts as above, FD *)
Ltac ffw_unpack_all Hf :=
  let Hgn := fresh "Hgn" in let EX := fresh "EX" in let FD := fresh "FD" in
  destruct Hf as (Hgn & EX & FD); ffw_unpack EX.

(* split a hypothesis H : ffw_read d ch b z (or ffw_read_s) into one goal
   per cell; each goal is "Mem.load ch m' b z = Mem.load ch m b z" at a
   concrete cell (the collided-object goal keeps its index i, 0 <= i < 4) *)
Ltac ffw_in_split Hin :=
  cbn [In] in Hin;
  repeat (let E := fresh "E" in destruct Hin as [E | Hin]; [injection E as <- <- | ]);
  try contradiction.

Ltac ffw_read_split H :=
  let Hin := fresh "Hin" in let i := fresh "i" in let Hi := fresh "Hi" in
  destruct H as [(-> & Hin) | [(-> & -> & ->) | (-> & -> & i & Hi & ->)]];
  [ unfold ffw_bm_cells in Hin; ffw_in_split Hin | | ];
  cbn [fw_gp fw_ab fw_bo fw_oo].

Ltac ffw_read_s_split H :=
  let H1 := fresh "H1" in let Hin := fresh "Hin" in
  destruct H as [H1 | (-> & Hin)];
  [ ffw_read_split H1 | unfold ffw_surf_cells in Hin; ffw_in_split Hin ].


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
(* the controller cells (2026-10-23, PollFlank): what the real
   read_controller_inputs (game_init.c) reads to turn the polled pad bytes
   into Mario's controller.  gControllers[0].controllerData is the pad of
   the first plugged-in port (init_controllers, game_init.c: one of
   gControllerPads[0..3]); every pad's button word, when an int, has A
   clear (the last poll stored it from an A-free PIF record, or left it);
   gPlayer1Controller / gPlayer3Controller are &gControllers[0] /
   &gControllers[2] (their static initializers; nothing reassigns them);
   gCurrDemoInput is NULL (no demo plays in WMotR: only the title screen's
   demo sets it).  Without these the poll's A-free result is not provable:
   a demo, a stale A in a pad, or a controller pointer elsewhere each make
   gControllers[0] report A from an A-free PIF image. *)
Definition ctl_w (G : genv) (m : mem) : Prop :=
  forall bc bp, Genv.find_symbol G mario._gControllers = Some bc ->
    Genv.find_symbol G game_init._gControllerPads = Some bp ->
    (forall j, j = 0 \/ j = 1 ->
       Mem.load Mint32 m bc (28 * j + 24) = Some (Vint Int.zero)
       \/ exists k, 0 <= k < 4 /\ Mem.load Mint32 m bc (28 * j + 24) = Some (Vptr bp (Ptrofs.repr (6 * k))))
    /\ (forall z, z = 16 \/ z = 18 -> exists v,
          Mem.load Mint16unsigned m bc z = Some (Vint v) /\ Int.and v (Int.repr 32768) = Int.zero)
    /\ (forall k n, 0 <= k < 4 -> Mem.load Mint16unsigned m bp (6 * k) = Some (Vint n) ->
          Int.and n (Int.repr 32768) = Int.zero)
    /\ (forall b1, Genv.find_symbol G game_init._gPlayer1Controller = Some b1 ->
          Mem.load Mint32 m b1 0 = Some (Vptr bc Ptrofs.zero))
    /\ (forall b3, Genv.find_symbol G game_init._gPlayer3Controller = Some b3 ->
          Mem.load Mint32 m b3 0 = Some (Vptr bc (Ptrofs.repr 56)))
    /\ (forall bd, Genv.find_symbol G game_init._gCurrDemoInput = Some bd ->
          Mem.load Mint32 m bd 0 = Some (Vint Int.zero))
    /\ (forall bx, Genv.find_symbol G libultra_osContInit.___osMaxControllers = Some bx ->
          forall x, Mem.load Mint8unsigned m bx 0 = Some (Vint x) -> Int.unsigned x <= 4).

(* The warp cells (2026-10-24).  FOUND (phantom forall): the level phase's
   labeled spec (HeightFrame.seg_level_spec: the action cell unchanged, Phi
   kept) was claimed from ANY frame-world memory, but the real
   play_mode_normal rewrites Mario's action and y in ways that memory did
   not rule out: warp_area runs init_mario_after_warp whenever
   sWarpDest.type is not WARP_TYPE_NOT_WARPING (level_update.c:463-473,
   389-390); a demo (gCurrDemoInput non-NULL) or the credits
   (gCurrCreditsEntry non-NULL) trigger warps; and initiate_delayed_warp
   follows sSourceWarpNodeId through area_get_warp_node, whose NULL (a node
   the area does not have) leaves no execution.  In the game, inside WMotR:
     - in PLAY_MODE_NORMAL (0) sWarpDest.type is NOT_WARPING (0): the level
       is entered by warp_level, which ends with init_mario_after_warp's
       sWarpDest.type = NOT_WARPING (:397); every warp WMotR can start goes
       to another level (its nodes F0 / F1 / F3 lead to the castle,
       levels/wmotr/script.c), so initiate_warp sets CHANGE_LEVEL and the
       same play_mode_normal call leaves NORMAL (:993-995);
     - gCurrDemoInput and gCurrCreditsEntry are NULL (boot values; only the
       demo / credits flows set them);
     - a pending delayed warp (sDelayedWarpOp non-zero) came from
       level_trigger_warp with sSourceWarpNodeId SUCCESS (0xF0), DEATH
       (0xF1) or WARP_FLOOR (0xF3) (:705-747; WMotR has no warp objects).
   The instant and painting warps need floor types WMotR does not have,
   which the frame world already pins (wmotr_world's floor clause).
   StartSat proves these on the witness (its Z18 is the real :397 store);
   every proved row keeps them (the blocks are apart from all regions). *)
Definition warp_w (G : genv) (m : mem) : Prop :=
  (forall bp bw, Genv.find_symbol G level_update._sCurrPlayMode = Some bp ->
     Genv.find_symbol G level_update._sWarpDest = Some bw ->
     Mem.load Mint16signed m bp 0 = Some (Vint Int.zero) ->
     Mem.load Mint8unsigned m bw 0 = Some (Vint Int.zero))
  /\ (forall b, Genv.find_symbol G level_update._gCurrDemoInput = Some b ->
     Mem.load Mint32 m b 0 = Some (Vint Int.zero))
  /\ (forall b, Genv.find_symbol G level_update._gCurrCreditsEntry = Some b ->
     Mem.load Mint32 m b 0 = Some (Vint Int.zero))
  /\ (forall bo bs, Genv.find_symbol G level_update._sDelayedWarpOp = Some bo ->
     Genv.find_symbol G level_update._sSourceWarpNodeId = Some bs ->
     Mem.load Mint16signed m bo 0 <> Some (Vint Int.zero) ->
     exists n, Mem.load Mint16signed m bs 0 = Some (Vint (Int.repr n)) /\ In n [240; 241; 243]).

Definition lvl_w (G : genv) (m : mem) : Prop :=
  (forall b, Genv.find_symbol G mario._gCurrLevelNum = Some b ->
     Mem.load Mint16signed m b 0 = Some (Vint (Int.repr LEVEL_WMOTR)))
  /\ (forall b, Genv.find_symbol G sound_init._sPlayingInfiniteStairs = Some b ->
     Mem.load Mint8unsigned m b 0 = Some (Vint Int.zero))
  /\ warp_w G m
  /\ ctl_w G m.

(* lvl_w reads only the lvl_ids globals' blocks *)
Lemma lvl_w_unch : forall (G : genv) m m',
  (forall b ch z, lvl_sym G b -> Mem.load ch m' b z = Mem.load ch m b z) ->
  lvl_w G m -> lvl_w G m'.
Proof.
  intros G m m' U (L1 & L2 & (W1 & W2 & W3 & W4) & CW).
  assert (U' : forall id b, Genv.find_symbol G id = Some b -> In id lvl_ids -> forall ch z,
             Mem.load ch m' b z = Mem.load ch m b z)
    by (intros id b Hs Hin ch z; exact (U b ch z (lvl_sym_of G id b Hin Hs))).
  split; [| split; [| split]].
  - intros b Hs. rewrite (U' _ b Hs ltac:(unfold lvl_ids; cbn [In]; auto 20)). exact (L1 b Hs).
  - intros b Hs. rewrite (U' _ b Hs ltac:(unfold lvl_ids; cbn [In]; auto 20)). exact (L2 b Hs).
  - split; [| split; [| split]].
    + intros bp bw Hp Hw. rewrite (U' _ bp Hp ltac:(unfold lvl_ids; cbn [In]; auto 20)), (U' _ bw Hw ltac:(unfold lvl_ids; cbn [In]; auto 20)).
      exact (W1 bp bw Hp Hw).
    + intros b Hs. rewrite (U' _ b Hs ltac:(unfold lvl_ids; cbn [In]; auto 20)). exact (W2 b Hs).
    + intros b Hs. rewrite (U' _ b Hs ltac:(unfold lvl_ids; cbn [In]; auto 20)). exact (W3 b Hs).
    + intros bo bs Ho Hs. rewrite (U' _ bo Ho ltac:(unfold lvl_ids; cbn [In]; auto 20)), (U' _ bs Hs ltac:(unfold lvl_ids; cbn [In]; auto 20)).
      exact (W4 bo bs Ho Hs).
  - intros bc bp Sc Sp.
    destruct (CW bc bp Sc Sp) as (L24 & B16 & PA & P1 & P3 & DM & MX).
    pose proof (U' _ bc Sc ltac:(unfold lvl_ids; cbn [In]; auto 20)) as Kc.
    pose proof (U' _ bp Sp ltac:(unfold lvl_ids; cbn [In]; auto 20)) as Kp.
    split; [intros j Hj; rewrite !Kc; exact (L24 j Hj) |].
    split; [intros z Hz; rewrite Kc; exact (B16 z Hz) |].
    split; [intros k' n Hk' Hl; rewrite Kp in Hl; exact (PA k' n Hk' Hl) |].
    split; [intros b1 S1; rewrite (U' _ b1 S1 ltac:(unfold lvl_ids; cbn [In]; auto 20)); exact (P1 b1 S1) |].
    split; [intros b3 S3; rewrite (U' _ b3 S3 ltac:(unfold lvl_ids; cbn [In]; auto 20)); exact (P3 b3 S3) |].
    split; [intros bd Sd; rewrite (U' _ bd Sd ltac:(unfold lvl_ids; cbn [In]; auto 20)); exact (DM bd Sd) |].
    intros bx Sx; rewrite (U' _ bx Sx ltac:(unfold lvl_ids; cbn [In]; auto 20)); exact (MX bx Sx).
Qed.

(* ---- the level cells and the frame world's regions ---- *)
(* the lvl_ids globals are none of ffw's regions (given they are not
   Mario's state block: AnimKeep.lvl_ne_bm) *)
Lemma ffw_lvl_not_rl : forall (G : genv) bm m d b, ffw_facts G bm m d ->
  (forall b', lvl_sym G b' -> b' <> bm) -> lvl_sym G b -> ~ rblk (ff_rl_of bm d) b.
Proof.
  intros G bm m d b F Hne Hs.
  pose proof (ff_D4 _ _ _ _ F b (or_intror (or_intror Hs))) as (No & Nt).
  pose proof (lvl_sym_ids G b Hs) as (id & Hin & Hb).
  apply (ffw_rl_not_sym G bm m d id b F Hb); [| exact (Hne b Hs) | exact No | exact Nt].
  unfold lvl_ids in Hin. cbn [In] in Hin.
  repeat (destruct Hin as [<- | Hin]; [reflexivity |]). destruct Hin.
Qed.

(* a frame that keeps every block off ffw's regions keeps lvl_w *)
Theorem lvl_w_keep_rl : forall (G : genv) bm m m' d, ffw_facts G bm m d ->
  (forall b, lvl_sym G b -> b <> bm) ->
  Ple (Genv.genv_next G) (Mem.nextblock m) ->
  (forall ch b z, Plt b (Mem.nextblock m) -> ~ rblk (ff_rl_of bm d) b ->
     Mem.load ch m' b z = Mem.load ch m b z) ->
  lvl_w G m -> lvl_w G m'.
Proof.
  intros G bm m m' d F Hne Hgn OFF. apply lvl_w_unch. intros b ch z Hs. apply OFF.
  - pose proof (lvl_sym_ids _ _ Hs) as (id & _ & Hs').
    exact (Plt_Ple_trans _ _ _ (Genv.genv_symb_range _ _ Hs') Hgn).
  - exact (ffw_lvl_not_rl G bm m d b F Hne Hs).
Qed.
