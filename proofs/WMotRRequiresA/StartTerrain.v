(* spine: the GOAL-2 start witness's terrain -- the real loader run on the
   init_mem-based witness memory, with the frame facts StartSat needs. *)
(* ====================================================================== *)
(* StartTerrain (GOAL 2): run WMotR's real level entry on StartSat's      *)
(* witness, in the real boot order.                                        *)
(*                                                                          *)
(* The chain, computed once by vm_compute over every link, from the link's *)
(* real boot image (Genv.init_mem, computed by InitMemC.init_mem_c,        *)
(* read-only and function permissions included):                           *)
(*   1. initiate_warp(LEVEL_WMOTR, 1, 0x0A, 0)'s sWarpDest stores and      *)
(*      warp_level's gCurrLevelNum store (EntryWarp: real code);           *)
(*   2. the main pool as one fresh block in main_pool_init's post-state    *)
(*      (TRUST 3.6; main_pool_init has no CompCert execution);             *)
(*   3. THE REAL ENTRY (entry_g, 2026-11-03): sound_init;                  *)
(*      init_mario_from_save_file; select_gfx_pool; WMotR's level script   *)
(*      command by command through the REAL LevelScriptJumpTable          *)
(*      (INIT_LEVEL, ALLOC_LEVEL_POOL, MARIO, AREA, the OBJECTs, the       *)
(*      WARP_NODEs, TERRAIN, MACRO_OBJECTS, SET_BACKGROUND_MUSIC,          *)
(*      TERRAIN_TYPE, END_AREA, FREE_LEVEL_POOL, MARIO_POS); then          *)
(*      init_level, warp_level (load_area: the spawn infos,                *)
(*      load_area_terrain, the objects) and init_mario_after_warp (the     *)
(*      real init_mario: find_floor, set_mario_initial_action,             *)
(*      reset_camera).  Every Mario cell, the floor, the area, the camera, *)
(*      the objects and both partitions are what that code leaves;         *)
(*   4. the anim DMA stand-ins (two fresh blocks, the table and three list *)
(*      cells), gCurrCourseNum and init_controllers' controllerData store. *)
(*                                                                          *)
(* THE STAND-INS, in one place (each is labeled again where it is made):   *)
(*   S1  Mario's action when the castle warp fires: ACT_IDLE (any nonzero  *)
(*       action; init_mario overwrites it; init_mario_after_warp spawns    *)
(*       Mario only if it is nonzero, and init_mario_from_save_file leaves *)
(*       it 0);                                                             *)
(*   S2  gCurrActNum := 1 (the act select);                                 *)
(*   S3  the LOAD_* segment loads and the JUMP_LINKs to the global model   *)
(*       scripts are not run; AREA's geo layout is not run (geo_layout.c   *)
(*       is not linked): the real init_graph_node_root, then the area's    *)
(*       camera node (init_graph_node_camera, create_camera) as            *)
(*       geo_camera_main(GEO_CONTEXT_CREATE) would, then                   *)
(*       level_cmd_begin_area's four stores;                                *)
(*   S4  the dispatcher level_script_execute is not run: each command's    *)
(*       handler runs (the two JUMP_LINKed local scripts' commands in      *)
(*       place), and init_level's warp branch is entered directly;         *)
(*   S5  FREE_LEVEL_POOL's alloc_only_pool_resize: main_pool_free has no   *)
(*       CompCert execution (TRUST 3.6), so its effect is three stores,    *)
(*       then the REAL main_pool_alloc and the rest of the command;        *)
(*   S6  init_mario_after_warp's set_background_music (the unlinked audio  *)
(*       engine) and init_level's tail are not run;                        *)
(*   S7  the anim DMA shortcut: setup_game_memory's table (ROM data, read  *)
(*       off the boot image's gMarioAnims), the list's dmaTable /          *)
(*       currentAddr / bufTarget and the buffer's header;                  *)
(*   S8  main_pool_init's post-state (TRUST 3.6), gCurrCourseNum (the     *)
(*       real lvl_set_current_level's store, StartSat.course_set) and      *)
(*       gControllers[0].controllerData (init_controllers: osContInit is   *)
(*       hardware).                                                         *)
(*                                                                          *)
(* The checks on the result (all by vm_compute, each with a soundness      *)
(* lemma here):                                                             *)
(*   - FOOTPRINT: every block valid before the entry that is neither one   *)
(*     of the globals f_ids nor gMarioStates holds the same bytes after it *)
(*     (old_ok); with InterpFrame.ex_keep (old blocks keep their           *)
(*     permissions), every such block has the same loads;                  *)
(*   - POINTERS: every pointer stored in an f_ids block or in the pool     *)
(*     block aims at the pool block or at a SafeB symbol, and every        *)
(*     pointer in gMarioStates or a fresh block at a valid block (frag_ok);*)
(*   - CELLS: Mario's cells the frame reads, on the entry's result and on  *)
(*     the witness (cells_chk);                                             *)
(*   - LISTS: every word of both partitions is NULL or a list whose nodes  *)
(*     and surfaces live in the pool block, every surface of a WMotR type  *)
(*     (wff_parts); every floor-list surface passes TerrainBound's check   *)
(*     and is a floor triangle of the decoder (TerrainRun.parts_ok);       *)
(*   - gSurfacesAllocated = 1352 (non-vacuity).                            *)
(* ====================================================================== *)

From Coq Require Import String List ZArith Lia.
From compcert Require Import Coqlib Maps Integers Floats Values AST Memory Memdata Globalenvs
  Ctypes Clight ClightBigstep Events.
From SM64.Proofs Require Import Interp.ClightInterp Interp.LinkGenv Interp.MemBuild
  Interp.InitMemC Interp.InterpFrame.
From SM64.Proofs Require Interp.CMem.
From SM64.Proofs Require Import CensusV2 SpawnInit LinkedTwelve.
From SM64.Proofs.WMotRRequiresA Require Import FloorList FloorExec FfWorld WMotRWorld
  HeightInvariant WMotRLevel WMotREntry EntryWarp TerrainRun.
From SM64.Generated Require mario level_update object_list_processor surface_load
  surface_collision wmotr_script graph_node area memory camera interaction audio_external.
From SM64.Proofs.WMotRRequiresA Require ObjWorld.
From SM64.Proofs.WMotRRequiresA Require FfComplete.
From SM64.Proofs.NoAImpliesNoFly Require BootRun.
From SM64.Proofs.WMotRRequiresA Require CourseRun AnimData.
From SM64.Generated Require game_init area level_script sound_init platform_displacement.
From SM64.Proofs.WMotRRequiresA Require LevelFlank.
From SM64.Proofs Require AGates MWFReal.
From SM64.Proofs.WMotRRequiresA Require AudioInv.
Import ListNotations.
Module CM := SM64.Proofs.Interp.CMem.
Arguments Done {A}.
Arguments Stuck {A}.

Local Open Scope string_scope.
Local Open Scope Z_scope.

(* ---------------------------------------------------------------------- *)
(* The globals the pool init and the entry may write.                      *)
(* ---------------------------------------------------------------------- *)
(* (read off the run: exactly the old blocks whose bytes differ afterwards;
   old_ok re-checks it) *)
Definition f_ids : list ident :=
  [ id "sPoolStart"; id "sPoolEnd"; id "sPoolFreeSpace"; id "sPoolListHeadL"; id "sPoolListHeadR";
    id "sSurfaceNodePool"; id "sSurfacePool"; id "sSurfacePoolSize";
    id "gSurfacesAllocated"; id "gSurfaceNodesAllocated";
    id "gNumStaticSurfaces"; id "gNumStaticSurfaceNodes";
    id "gStaticSurfacePartition"; id "gMacroObjectDefaultParent";
    (* 2026-10-26: the object init (clear_objects, after
       init_graph_node_start) and Mario's spawn (spawn_objects_from_info) *)
    id "gMarioObject"; id "gObjectMemoryPool"; id "gObjectPool"; id "gObjectListArray";
    id "gObjectLists"; id "gObjParentGraphNode"; id "gFreeObjectList";
    id "gPlayerSpawnInfos"; id "sDebugLvSelectCheckFlag";
    (* 2026-10-26: the area's Camera (create_camera, gAreas[1].camera,
       reset_camera) *)
    id "gAreaData"; id "gCameraMovementFlags"; id "gCamera"; id "sFOVState";
    id "unused8032CFC8"; id "unused8032CFCC";
    (* 2026-11-02 (Step B): select_gfx_pool (the identity
       set_segment_base_addr, TRUST 2.2) and the level script's pool,
       AREA(1), act and OBJECT commands *)
    id "gGfxPool"; id "gGfxSPTask"; id "gDisplayListHead"; id "gGfxPoolEnd"; id "sSegmentTable";
    id "sLevelPool"; id "sCurrAreaIndex"; id "sCurrentCmd"; id "gCurrActNum"; id "gNumCalls";
    (* 2026-11-03: the real entry (entry_g): main_pool_alloc's state,
       load_area / warp_level's level globals (the warp transition, the
       current area, sWarpDest), init_mario_from_save_file's body and
       camera states and the HUD, camera.c's mode transition and
       sound_init / play_sound's audio cells *)
    id "gMainPoolState"; id "gWarpTransition"; id "gCurrAreaIndex"; id "gCurrentArea";
    id "gBodyStates"; id "gPlayerCameraState"; id "gHudDisplay"; id "sModeTransition";
    id "sWarpDest"; id "sCurrentSound"; id "sSoundBanks" ].

Definition inFb (ge : genv) (b : block) : bool :=
  existsb (fun i => match Genv.find_symbol ge i with Some b' => Pos.eqb b b' | None => false end) f_ids.

Lemma inFb_sym_false : forall (ge : genv) i b, Genv.find_symbol ge i = Some b ->
    mem_id i f_ids = false -> inFb ge b = false.
Proof.
  intros ge i b Hs Hm. unfold inFb. apply not_true_iff_false. intro E.
  apply existsb_exists in E as (i' & Hin & Hb).
  destruct (Genv.find_symbol ge i') as [b'|] eqn:Hs'; [ | discriminate ].
  apply Pos.eqb_eq in Hb. subst b'.
  assert (i' = i) by (eapply Genv.genv_vars_inj; eauto). subst i'.
  assert (T : mem_id i f_ids = true)
    by (unfold mem_id; apply existsb_exists; exists i; split; [ exact Hin | apply Pos.eqb_refl ]).
  congruence.
Qed.

Lemma inFb_sym : forall (ge : genv) b, inFb ge b = true ->
    exists i, In i f_ids /\ Genv.find_symbol ge i = Some b.
Proof.
  intros ge b E. apply existsb_exists in E as (i & Hin & Hb).
  destruct (Genv.find_symbol ge i) as [b'|] eqn:Hs; [ | discriminate ].
  apply Pos.eqb_eq in Hb. subst b'. exists i. split; assumption.
Qed.

(* ---------------------------------------------------------------------- *)
(* A check over a range of blocks.                                         *)
(* ---------------------------------------------------------------------- *)
Fixpoint range_ok (f : positive -> bool) (n : nat) (b : positive) : bool :=
  match n with
  | O => true
  | S n' => f b && range_ok f n' (Pos.succ b)
  end.

Lemma range_ok_spec : forall f n b, range_ok f n b = true ->
    forall b', Ple b b' -> (Pos.to_nat b' < Pos.to_nat b + n)%nat -> f b' = true.
Proof.
  induction n as [| n IH]; intros b H b' Hle Hlt;
    [ unfold Ple in Hle; apply Pos2Nat.inj_le in Hle; lia | ].
  cbn in H. apply andb_prop in H as [Hb Hr].
  destruct (Pos.eq_dec b b') as [<- | Hne]; [ exact Hb | ].
  apply (IH (Pos.succ b) Hr).
  - unfold Ple in *. apply Pos.le_succ_l. apply Pos.le_lteq in Hle as [Hl | E]; [ exact Hl | congruence ].
  - rewrite Pos2Nat.inj_succ. lia.
Qed.

(* ---------------------------------------------------------------------- *)
(* FOOTPRINT: old blocks outside f_ids and gMarioStates keep their bytes.  *)
(* ---------------------------------------------------------------------- *)
(* (gMarioStates is not an f_ids global: MWF_real's rows read it, so
   StartSat re-proves its rows from the cells the entry left, checked by
   cells_chk; frag_ok bounds its pointers) *)
Definition old_ok (ge : genv) (bm : block) (e L : mem) : bool :=
  range_ok (fun b => inFb ge b || Pos.eqb b bm || blk_eqb ((Mem.mem_contents L) !! b) ((Mem.mem_contents e) !! b))
    (Pos.to_nat (Mem.nextblock e) - 1) 1.

Lemma old_ok_sound : forall ge bm e L, old_ok ge bm e L = true ->
    forall b o, Plt b (Mem.nextblock e) -> inFb ge b = false -> b <> bm ->
      ZMap.get o ((Mem.mem_contents L) !! b) = ZMap.get o ((Mem.mem_contents e) !! b).
Proof.
  intros ge bm e L H b o Hb Hf Hm.
  assert (R : inFb ge b || Pos.eqb b bm || blk_eqb ((Mem.mem_contents L) !! b) ((Mem.mem_contents e) !! b) = true).
  { apply (range_ok_spec _ _ _ H); [ unfold Ple; apply Pos.le_1_l | ].
    unfold Plt in Hb. apply Pos2Nat.inj_lt in Hb. cbn [Pos.to_nat Pos.iter_op]. lia. }
  rewrite Hf in R. destruct (Pos.eqb b bm) eqn:E; [ apply Pos.eqb_eq in E; contradiction | ].
  exact (blk_eqb_get _ _ R o).
Qed.

(* ---------------------------------------------------------------------- *)
(* POINTERS.                                                                *)
(* ---------------------------------------------------------------------- *)
Definition lt_tgt (nb t : block) : bool := if plt t nb then true else false.

(* a pointer target the SafeB witness accepts: the pool block, or a symbol
   outside non_safeb_syms; and a valid block *)
Definition safe_tgt (ge : genv) (bp nb t : block) : bool :=
  lt_tgt nb t &&
  (Pos.eqb t bp || match Genv.invert_symbol ge t with
                   | Some i => negb (mem_id i non_safeb_syms)
                   | None => false
                   end).

Definition fblks (ge : genv) : list block :=
  flat_map (fun i => match Genv.find_symbol ge i with Some b => [b] | None => [] end) f_ids.

Definition frag_ok (ge : genv) (bm bp : block) (L : mem) : bool :=
  forallb (fun b => blk_ptrs (safe_tgt ge bp (Mem.nextblock L)) ((Mem.mem_contents L) !! b))
    (bp :: fblks ge)
  && range_ok (fun b => blk_ptrs (lt_tgt (Mem.nextblock L)) ((Mem.mem_contents L) !! b))
       (Pos.to_nat (Mem.nextblock L) - Pos.to_nat (Pos.succ bp)) (Pos.succ bp)
  && blk_ptrs (lt_tgt (Mem.nextblock L)) ((Mem.mem_contents L) !! bm).

Lemma frag_ok_sound : forall ge bm bp L, frag_ok ge bm bp L = true ->
    (forall b o, inFb ge b = true \/ b = bp ->
       mv_ok (safe_tgt ge bp (Mem.nextblock L)) (ZMap.get o ((Mem.mem_contents L) !! b)) = true)
    /\ (forall b o, Plt bp b -> Plt b (Mem.nextblock L) ->
       mv_ok (lt_tgt (Mem.nextblock L)) (ZMap.get o ((Mem.mem_contents L) !! b)) = true)
    /\ (forall o, mv_ok (lt_tgt (Mem.nextblock L)) (ZMap.get o ((Mem.mem_contents L) !! bm)) = true).
Proof.
  intros ge bm bp L H. apply andb_prop in H as [H H3]. apply andb_prop in H as [H1 H2].
  rewrite forallb_forall in H1. split; [ | split ].
  - intros b o Hb. apply blk_ptrs_get. apply H1.
    destruct Hb as [Hb | ->]; [ right | left; reflexivity ].
    destruct (inFb_sym _ _ Hb) as (i & Hin & Hs). unfold fblks. apply in_flat_map.
    exists i. split; [ exact Hin | rewrite Hs; left; reflexivity ].
  - intros b o H3' H4. apply blk_ptrs_get. apply (range_ok_spec _ _ _ H2).
    + unfold Ple, Plt in *. apply Pos.le_succ_l. exact H3'.
    + unfold Plt in *. apply Pos2Nat.inj_lt in H3'. apply Pos2Nat.inj_lt in H4.
      rewrite Pos2Nat.inj_succ. lia.
  - intros o. exact (blk_ptrs_get _ _ H3 o).
Qed.

Lemma safe_tgt_lt : forall ge bp nb t, safe_tgt ge bp nb t = true -> Plt t nb.
Proof.
  intros ge bp nb t H. unfold safe_tgt, lt_tgt in H. destruct (plt t nb); [ exact p | discriminate ].
Qed.

Lemma lt_tgt_lt : forall nb t, lt_tgt nb t = true -> Plt t nb.
Proof. intros nb t H. unfold lt_tgt in H. destruct (plt t nb); [ exact p | discriminate ]. Qed.

(* ---------------------------------------------------------------------- *)
(* LISTS: every partition word is NULL or a list living in the pool block. *)
(* ---------------------------------------------------------------------- *)
Definition styp_b (m : mem) (b : block) (o : ptrofs) : bool :=
  match CM.load Mint16signed m b (Ptrofs.unsigned o) with
  | Some (Vint t) => existsb (Z.eqb (Int.signed t)) [5; 10; 21; 55; 0]
  | _ => false
  end.

(* The literal list is wmotr_surface_types (wmotr_surface_types_value); it is
   kept literal so no tactic ever unfolds the 1352-triangle computation. *)
Lemma styp_b_sound : forall m b o, styp_b m b o = true -> styp m b o.
Proof.
  intros m b o H. unfold styp_b in H. rewrite CM.load_eq in H.
  destruct (Mem.load Mint16signed m b (Ptrofs.unsigned o)) as [[| t | | | |]|] eqn:L; try discriminate.
  apply existsb_exists in H as (z & Hin & Hz). apply Z.eqb_eq in Hz. subst z.
  exists t. split; [ exact L | rewrite wmotr_surface_types_value; exact Hin ].
Qed.

Fixpoint walk2 (fuel : nat) (m : mem) (bp : block) (v : val) : bool :=
  match v with
  | Vint i => Int.eq i Int.zero
  | Vptr bn on =>
      match fuel with
      | O => false
      | S f =>
          Pos.eqb bn bp
          && match CM.load Mint32 m bn (Ptrofs.unsigned (Ptrofs.add on (Ptrofs.repr SN_SURF))) with
             | Some (Vptr bs os) =>
                 Pos.eqb bs bp && Z.leb (Ptrofs.unsigned os + SZ_SURFACE) Ptrofs.modulus
                 && styp_b m bs os
             | _ => false
             end
          && match CM.load Mint32 m bn (Ptrofs.unsigned (Ptrofs.add on (Ptrofs.repr SN_NEXT))) with
             | Some nx => walk2 f m bp nx
             | None => false
             end
      end
  | _ => false
  end.

Lemma walk2_sound : forall fuel m bp (avoid : block -> Prop) v,
    walk2 fuel m bp v = true -> Mem.valid_block m bp -> ~ avoid bp ->
    wf_list m avoid v
    /\ (forall s, on_list m v s -> exists o, s = Vptr bp o
          /\ Ptrofs.unsigned o + SZ_SURFACE <= Ptrofs.modulus /\ styp m bp o).
Proof.
  induction fuel as [| f IH]; intros m bp avoid v W Vb Av;
    destruct v as [| i | | | | bn on]; cbn in W; try discriminate.
  - apply Int.same_if_eq in W. subst i. split; [ constructor | intros s Ho; inversion Ho ].
  - apply Int.same_if_eq in W. subst i. split; [ constructor | intros s Ho; inversion Ho ].
  - apply andb_prop in W as [W Wn]. apply andb_prop in W as [Wb Ws].
    apply Pos.eqb_eq in Wb. subst bn.
    rewrite CM.load_eq in Ws, Wn.
    destruct (Mem.load Mint32 m bp (Ptrofs.unsigned (Ptrofs.add on (Ptrofs.repr SN_SURF))))
      as [[| | | | | bs os]|] eqn:Ls; try discriminate.
    apply andb_prop in Ws as [Ws Wt]. apply andb_prop in Ws as [Wbs Wsz].
    apply Pos.eqb_eq in Wbs. subst bs. apply Z.leb_le in Wsz.
    destruct (Mem.load Mint32 m bp (Ptrofs.unsigned (Ptrofs.add on (Ptrofs.repr SN_NEXT))))
      as [nx|] eqn:Ln; [ | discriminate ].
    destruct (IH m bp avoid nx Wn Vb Av) as (Wf & Ho).
    split.
    + econstructor; [ exact Vb | exact Av | exact Ln | exact Wf ].
    + intros s Hs. inversion Hs as [bn0 on0 s0 Hl E1 E2 | bn0 on0 nx0 s0 Hl Hr E1 E2]; subst.
      * cbn in Hl. rewrite Ls in Hl. injection Hl as <-.
        exists os. split; [ reflexivity | split; [ exact Wsz | exact (styp_b_sound _ _ _ Wt) ] ].
      * cbn in Hl. rewrite Ln in Hl. injection Hl as <-. exact (Ho _ Hr).
Qed.

Definition zlist (n : nat) : list Z := map Z.of_nat (seq 0 n).

Lemma in_zlist : forall n k, 0 <= k < Z.of_nat n -> In k (zlist n).
Proof.
  intros n k Hk. unfold zlist. apply in_map_iff. exists (Z.to_nat k).
  split; [ lia | apply in_seq; lia ].
Qed.

Definition heads_ok (fuel : nat) (m : mem) (bp pb : block) : bool :=
  forallb (fun k => match CM.load Mint32 m pb (4 * k) with
                    | Some hd => walk2 fuel m bp hd
                    | None => false
                    end) (zlist 1536).

Definition wff_parts (fuel : nat) (ge : genv) (bp : block) (m : mem) : bool :=
  forallb (fun pid => match Genv.find_symbol ge pid with
                      | Some pb => heads_ok fuel m bp pb
                      | None => false
                      end) part_ids.

Lemma wff_parts_sound : forall fuel ge bp m, wff_parts fuel ge bp m = true ->
    forall pid pb k hd, In pid part_ids -> Genv.find_symbol ge pid = Some pb -> 0 <= k < 1536 ->
      Mem.load Mint32 m pb (4 * k) = Some hd -> walk2 fuel m bp hd = true.
Proof.
  intros fuel ge bp m H pid pb k hd Hin Hs Hk Hl.
  unfold wff_parts in H. rewrite forallb_forall in H. specialize (H pid Hin). rewrite Hs in H.
  unfold heads_ok in H. rewrite forallb_forall in H.
  specialize (H k (in_zlist 1536 k ltac:(lia))). rewrite CM.load_eq, Hl in H. exact H.
Qed.

(* ---------------------------------------------------------------------- *)
(* The run keeps old blocks' permissions.                                  *)
(* ---------------------------------------------------------------------- *)
Lemma apply_writes_keep : forall ws m k m', apply_writes m ws k = inl m' -> acc_keep m m'.
Proof.
  induction ws as [| w ws IH]; intros m k m' H; cbn in H.
  - injection H as <-. apply acc_keep_refl.
  - destruct (CM.store _ _ _ _ _) as [m1|] eqn:S; [ | discriminate ].
    exact (acc_keep_trans _ _ _ (cm_store_keep _ _ _ _ _ _ S) (IH _ _ _ H)).
Qed.

Lemma apply_writes_other : forall ws m k m' ch b z, apply_writes m ws k = inl m' ->
    (forall w, In w ws -> w_blk w <> b) -> Mem.load ch m' b z = Mem.load ch m b z.
Proof.
  induction ws as [| w ws IH]; intros m k m' ch b z H N; cbn in H.
  - injection H as <-. reflexivity.
  - destruct (CM.store _ _ _ _ _) as [m1|] eqn:S; [ | discriminate ].
    rewrite CM.store_eq in S.
    rewrite (IH _ _ _ ch b z H (fun w' Hw => N w' (or_intror Hw))).
    apply (Mem.load_store_other _ _ _ _ _ _ S). left. exact (not_eq_sym (N w (or_introl eq_refl))).
Qed.

Lemma apply_writes_nb : forall ws m k m', apply_writes m ws k = inl m' -> Mem.nextblock m' = Mem.nextblock m.
Proof.
  induction ws as [| w ws IH]; intros m k m' H; cbn in H.
  - injection H as <-. reflexivity.
  - destruct (CM.store _ _ _ _ _) as [m1|] eqn:S; [ | discriminate ].
    rewrite CM.store_eq in S. rewrite (IH _ _ _ H). exact (Mem.nextblock_store _ _ _ _ _ _ S).
Qed.

(* a property every store keeps holds after the writes *)
Lemma apply_writes_ind : forall (P : mem -> Prop) ws m k m', apply_writes m ws k = inl m' ->
    (forall w m1 m2, In w ws -> Mem.store (w_chunk w) m1 (w_blk w) (w_ofs w) (w_val w) = Some m2 ->
       P m1 -> P m2) ->
    P m -> P m'.
Proof.
  intros P. induction ws as [| w ws IH]; intros m k m' H St Pm; cbn in H.
  - injection H as <-. exact Pm.
  - destruct (CM.store _ _ _ _ _) as [m1|] eqn:S; [ | discriminate ].
    rewrite CM.store_eq in S.
    apply (IH m1 (Datatypes.S k) m' H); [ intros w' a b Hw; exact (St w' a b (or_intror Hw)) | ].
    exact (St w m m1 (or_introl eq_refl) S Pm).
Qed.

Lemma world_keep : forall ef vargs m t v m', world ef vargs m = Some (t, v, m') -> acc_keep m m'.
Proof.
  intros ef vargs m t v m' H. unfold world in H.
  destruct ef; try discriminate H.
  destruct vargs as [| a [| a2 args]]; try discriminate H; destruct a; try discriminate H.
  destruct (_ && _ && _); [ injection H as _ _ <-; apply acc_keep_refl | discriminate H ].
Qed.

(* ---------------------------------------------------------------------- *)
(* The chain.                                                               *)
(* ---------------------------------------------------------------------- *)
Definition e_chain (bw bL : block) (m0 : mem) : option mem :=
  match CM.store Mint8unsigned m0 bw 0 (Vint (Int.repr 1)) with
  | Some e1 =>
  match CM.store Mint8unsigned e1 bw 1 (Vint (Int.repr LEVEL_WMOTR)) with
  | Some e2 =>
  match CM.store Mint8unsigned e2 bw 2 (Vint (Int.repr WARP_AREA)) with
  | Some e3 =>
  match CM.store Mint8unsigned e3 bw 3 (Vint (Int.repr WARP_NODE)) with
  | Some e4 =>
  match CM.store Mint32 e4 bw 4 (Vint Int.zero) with
  | Some e5 => CM.store Mint16signed e5 bL 0 (Vint (Int.repr LEVEL_WMOTR))
  | None => None end | None => None end | None => None end | None => None end | None => None end.

(* Mario's object: its offset in gObjectPool, an ACCESSOR (2026-11-02).
   The witness's spawn order decides the slot; the checks below and in
   StartSat read Mario's cells at MARIO_OFF + field, and ow_chk checks
   gMarioObject / gMarioStates[0].marioObj against the same slot, so no
   fact about the start state assumes slot 0. *)
Definition MARIO_OFF : Z := 20672.

Lemma mario_off_range : 0 <= MARIO_OFF /\ MARIO_OFF + 608 <= 145920 /\ MARIO_OFF mod 8 = 0.
Proof. unfold MARIO_OFF. split; [ lia | split; [ lia | reflexivity ] ]. Qed.

Lemma mario_off_u : Ptrofs.unsigned (Ptrofs.repr MARIO_OFF) = MARIO_OFF.
Proof.
  apply Ptrofs.unsigned_repr. pose proof mario_off_range as R.
  unfold Ptrofs.max_unsigned, Ptrofs.modulus, Ptrofs.wordsize, Wordsize_Ptrofs.wordsize.
  destruct Archi.ptr64; cbn; lia.
Qed.

(* the DMA table setup_dma_table_list builds at boot (memory.c:559):
   load_dma_table_address DMAs the table's header from the ROM's
   gMarioAnims (count, srcAddr, then 209 (offset, size) entries:
   8 + 8 * 209 = 1680 bytes) and sets srcAddr to gMarioAnims itself.
   Here: the same 420 words read off the boot image's gMarioAnims, word 1
   replaced by &gMarioAnims. *)
Definition TAB_WORDS : nat := 420.
Definition tab_word (m0 : mem) (bga : block) (i : Z) : val :=
  if Z.eqb i 1 then Vptr bga Ptrofs.zero
  else match CM.load Mint32 m0 bga (4 * i) with Some (Vint v) => Vint v | _ => Vundef end.
Definition tab_writes (m0 : mem) (bd bga : block) : list wr :=
  map (fun i => W Mint32 bd (4 * i) (tab_word m0 bga i)) (zlist TAB_WORDS).
(* the list's currentAddr: the animation the witness's first frame sets
   (act_spawn_no_spin_airborne: MARIO_ANIM_GENERAL_FALL, 0x56) is the one
   loaded, so that frame DMAs nothing (the buffer's cells are the
   witness's zero header, as before) *)
Definition GF_ENT : Z := 8 + 8 * 86.
Definition cur_addr (m0 : mem) (bga : block) : val :=
  match CM.load Mint32 m0 bga GF_ENT with
  | Some (Vint o) => Vptr bga (Ptrofs.of_intu o)
  | _ => Vundef
  end.

(* the table and gMarioAnims' cells the pole walks read, on the witness *)
Definition tab_chk (m : mem) (bd bga : block) : bool :=
  match CM.load Mint32 m bd 0, CM.load Mint32 m bd 4 with
  | Some (Vint c), Some (Vptr b o) =>
      Int.eq c (Int.repr AnimData.ANIM_COUNT) && Pos.eqb b bga && Ptrofs.eq o Ptrofs.zero
  | _, _ => false
  end
  && forallb (fun e => let '(j, o, sz) := e in
       match CM.load Mint32 m bd (8 + 8 * j), CM.load Mint32 m bd (12 + 8 * j) with
       | Some (Vint o'), Some (Vint s') => Int.eq o' (Int.repr o) && Int.eq s' (Int.repr sz)
       | _, _ => false
       end) AnimData.anim_ent.
Definition ga_chk (m : mem) (bga : block) : bool :=
  forallb (fun c => let '(o, ch, z) := c in
       match CM.load ch m bga o with
       | Some (Vint v) => Int.eq v (Int.repr z)
       | _ => false
       end) AnimData.ga_cells.

Lemma tab_chk_sound : forall m bd bga, tab_chk m bd bga = true ->
    Mem.load Mint32 m bd 0 = Some (Vint (Int.repr AnimData.ANIM_COUNT))
    /\ Mem.load Mint32 m bd 4 = Some (Vptr bga Ptrofs.zero)
    /\ forall j o s, In (j, o, s) AnimData.anim_ent ->
         Mem.load Mint32 m bd (8 + 8 * j) = Some (Vint (Int.repr o))
         /\ Mem.load Mint32 m bd (12 + 8 * j) = Some (Vint (Int.repr s)).
Proof.
  intros m bd bga H. unfold tab_chk in H. apply andb_prop in H as [H1 H2].
  rewrite !CM.load_eq in H1.
  destruct (Mem.load Mint32 m bd 0) as [[| c | | | |]|]; try discriminate H1.
  destruct (Mem.load Mint32 m bd 4) as [[| | | | | b o]|]; try discriminate H1.
  apply andb_prop in H1 as [H1 Ho]. apply andb_prop in H1 as [Hc Hb].
  apply Int.same_if_eq in Hc. apply Pos.eqb_eq in Hb. pose proof (Ptrofs.eq_spec o Ptrofs.zero) as Eo.
  rewrite Ho in Eo. subst c b o. split; [ reflexivity | split; [ reflexivity | ] ].
  intros j o s Hin. rewrite forallb_forall in H2. specialize (H2 _ Hin). cbv beta iota in H2.
  rewrite !CM.load_eq in H2.
  destruct (Mem.load Mint32 m bd (8 + 8 * j)) as [[| o' | | | |]|]; try discriminate H2.
  destruct (Mem.load Mint32 m bd (12 + 8 * j)) as [[| s' | | | |]|]; try discriminate H2.
  apply andb_prop in H2 as [E1 E2]. apply Int.same_if_eq in E1. apply Int.same_if_eq in E2.
  subst. split; reflexivity.
Qed.

Lemma ga_chk_sound : forall m bga, ga_chk m bga = true ->
    forall o ch z, In (o, ch, z) AnimData.ga_cells -> Mem.load ch m bga o = Some (Vint (Int.repr z)).
Proof.
  intros m bga H o ch z Hin. unfold ga_chk in H. rewrite forallb_forall in H.
  specialize (H _ Hin). cbv beta iota in H. rewrite CM.load_eq in H.
  destruct (Mem.load ch m bga o) as [[| v | | | |]|]; try discriminate H.
  apply Int.same_if_eq in H. subst. reflexivity.
Qed.

Lemma tab_writes_shape : forall m0 bd bga w, In w (tab_writes m0 bd bga) ->
    w_chunk w = Mint32 /\ w_blk w = bd
    /\ (w_val w = Vptr bga Ptrofs.zero \/ forall b o, w_val w <> Vptr b o).
Proof.
  intros m0 bd bga w H. unfold tab_writes in H. apply in_map_iff in H as (i & <- & _).
  cbn [w_chunk w_blk w_val]. split; [ reflexivity | split; [ reflexivity | ] ].
  unfold tab_word. destruct (Z.eqb i 1); [ left; reflexivity | right ].
  intros b o; destruct (CM.load Mint32 m0 bga (4 * i)) as [[]|]; discriminate.
Qed.

(* init_mario_from_save_file's writes as stores on the boot image (the
   zero writes are left out: those cells are zero at boot) *)
Definition ifs_writes (bm bc ab bsi bpcs bbs bhud : block) : list wr :=
  [W Mint32 bm 140 (Vptr bsi Ptrofs.zero); W Mint32 bm 148 (Vptr bpcs Ptrofs.zero);
   W Mint32 bm 152 (Vptr bbs Ptrofs.zero); W Mint32 bm 156 (Vptr bc Ptrofs.zero);
   W Mint32 bm 160 (Vptr ab Ptrofs.zero); W Mint8signed bm 173 (Vint (Int.repr 4));
   W Mint16signed bm 174 (Vint (Int.repr 2176)); W Mint16signed bm 176 (Vint (Int.repr 189));
   W Mint16signed bhud 6 (Vint (Int.repr 8))].

Definition nsurf_ok (m : mem) (bn : block) : bool :=
  match CM.load Mint32 m bn 0 with
  | Some (Vint n) => Z.eqb (Int.signed n) NSURF
  | _ => false
  end.

(* the bytes of every old block after the run equal those after the stores *)
Fixpoint same_blocks (m1 m2 : mem) (n : nat) (b : positive) : bool :=
  match n with
  | O => true
  | S n' => blk_eqb ((Mem.mem_contents m1) !! b) ((Mem.mem_contents m2) !! b)
            && same_blocks m1 m2 n' (Pos.succ b)
  end.

(* the real init_mario_from_save_file, run on the boot image, writes
   exactly ifs_writes *)
Definition ifs_ok (ge : genv) (m0 : mem) (bm bc ab bsi bpcs bbs bhud : block) : bool :=
  match sym ge "init_mario_from_save_file" with
  | Some bi =>
    match Genv.find_funct ge (Vptr bi Ptrofs.zero) with
    | Some fi =>
      match ex_call ge BootRun.world FUEL m0 fi [] with
      | Done (_, mi, _) =>
        match apply_writes m0 (ifs_writes bm bc ab bsi bpcs bbs bhud) 0 with
        | inl mx => Pos.eqb (Mem.nextblock mi) (Mem.nextblock m0)
                    && same_blocks mi mx (Pos.to_nat (Mem.nextblock m0) - 1) 1
        | inr _ => false
        end
      | Stuck _ _ _ => false
      end
    | None => false
    end
  | None => false
  end.

(* Mario's object (pool offset MARIO_OFF, the slot spawn_objects_from_info gave it):
   oInteractStatus, numCollidedObjs, gfx.throwMatrix and collidedObjs[0..3]
   are zero on the witness (what the frame world reads of it) *)
Definition bo_cells : list (memory_chunk * Z) :=
  [(Mint32, 308); (Mint16signed, 118); (Mint32, 80);
   (Mint32, 120); (Mint32, 124); (Mint32, 128); (Mint32, 132)].
(* ... and its hitbox (2026-10-26, FfWorld.ff_HH / ff_HD): allocate_object
   (spawn_object.c) stores hitboxHeight = 100.0f and hitboxDownOffset =
   0.0f; checked on m11 by their bits *)
Definition f32_is (m : mem) (bo : block) (z : Z) (f : float32) : bool :=
  match CM.load Mfloat32 m bo z with
  | Some (Vsingle h) => Int.eq (Float32.to_bits h) (Float32.to_bits f)
  | _ => false
  end.
Definition bo_chk (m : mem) (bo : block) : bool :=
  forallb (fun c => let '(ch, z) := c in
             match CM.load ch m bo (MARIO_OFF + z) with Some (Vint i) => Int.eq i Int.zero | _ => false end)
          bo_cells
  && f32_is m bo (MARIO_OFF + 508) FFW_F100 && f32_is m bo (MARIO_OFF + 520) FFW_F0.

Lemma bo_chk_sound : forall m bo, bo_chk m bo = true ->
    forall ch z, In (ch, z) bo_cells -> Mem.load ch m bo (MARIO_OFF + z) = Some (Vint Int.zero).
Proof.
  intros m bo H ch z Hin. unfold bo_chk in H.
  apply andb_prop in H as [H _]. apply andb_prop in H as [H _]. rewrite forallb_forall in H.
  specialize (H _ Hin). cbv beta iota in H. rewrite CM.load_eq in H.
  destruct (Mem.load ch m bo (MARIO_OFF + z)) as [[| i | | | |]|]; try discriminate H.
  pose proof (Int.eq_spec i Int.zero) as E. rewrite H in E. subst i. reflexivity.
Qed.

Lemma f32_is_sound : forall m bo z f, f32_is m bo z f = true ->
    Mem.load Mfloat32 m bo z = Some (Vsingle f).
Proof.
  intros m bo z f H. unfold f32_is in H. rewrite CM.load_eq in H.
  destruct (Mem.load Mfloat32 m bo z) as [[| | | | h |]|]; try discriminate H.
  pose proof (Int.eq_spec (Float32.to_bits h) (Float32.to_bits f)) as E. rewrite H in E.
  rewrite <- (Float32.of_to_bits h), <- (Float32.of_to_bits f), E. reflexivity.
Qed.

(* ---------------------------------------------------------------------- *)
(* The death plane on every static floor cell (FfComplete.dp_lists): each *)
(* of the 256 FLOOR lists of gStaticSurfacePartition holds both of         *)
(* SURFACE_DEATH_PLANE's triangles, read off the loaded memory.            *)
(* ---------------------------------------------------------------------- *)
Definition i16_is (m : mem) (b : block) (z : Z) (ch : memory_chunk) (k : Z) : bool :=
  match CM.load ch m b z with Some (Vint i) => Int.eq i (Int.repr k) | _ => false end.

Lemma i16_is_ok : forall m b z ch k, i16_is m b z ch k = true ->
    Mem.load ch m b z = Some (Vint (Int.repr k)).
Proof.
  intros m b z ch k H. unfold i16_is in H. rewrite CM.load_eq in H.
  destruct (Mem.load ch m b z) as [[| i | | | |]|]; try discriminate H.
  apply Int.same_if_eq in H. subst i. reflexivity.
Qed.

Definition dp_tri_b (m : mem) (s : val) (x1 z1 x2 z2 x3 z3 : Z) : bool :=
  match s with
  | Vptr bs os =>
      match CM.load Mint16signed m bs (Ptrofs.unsigned (Ptrofs.add os (Ptrofs.repr 0))),
            CM.load Mint8signed m bs (Ptrofs.unsigned (Ptrofs.add os (Ptrofs.repr 4))) with
      | Some (Vint ty), Some (Vint fl) =>
          negb (Int.eq ty (Int.repr 114)) && Int.eq (Int.and fl (Int.repr 2)) Int.zero
          && i16_is m bs (Ptrofs.unsigned (Ptrofs.add os (Ptrofs.repr 10))) Mint16signed x1
          && i16_is m bs (Ptrofs.unsigned (Ptrofs.add os (Ptrofs.repr 14))) Mint16signed z1
          && i16_is m bs (Ptrofs.unsigned (Ptrofs.add os (Ptrofs.repr 16))) Mint16signed x2
          && i16_is m bs (Ptrofs.unsigned (Ptrofs.add os (Ptrofs.repr 20))) Mint16signed z2
          && i16_is m bs (Ptrofs.unsigned (Ptrofs.add os (Ptrofs.repr 22))) Mint16signed x3
          && i16_is m bs (Ptrofs.unsigned (Ptrofs.add os (Ptrofs.repr 26))) Mint16signed z3
          && f32_is m bs (Ptrofs.unsigned (Ptrofs.add os (Ptrofs.repr 28))) Float32.zero
          && f32_is m bs (Ptrofs.unsigned (Ptrofs.add os (Ptrofs.repr 32))) FfComplete.DP_NY
          && f32_is m bs (Ptrofs.unsigned (Ptrofs.add os (Ptrofs.repr 36))) Float32.zero
          && f32_is m bs (Ptrofs.unsigned (Ptrofs.add os (Ptrofs.repr 40))) FfComplete.DP_OO
      | _, _ => false
      end
  | _ => false
  end.

Lemma dp_tri_b_sound : forall m s x1 z1 x2 z2 x3 z3,
    dp_tri_b m s x1 z1 x2 z2 x3 z3 = true -> FfComplete.dp_tri m s x1 z1 x2 z2 x3 z3.
Proof.
  intros m s x1 z1 x2 z2 x3 z3 H. destruct s as [| | | | | bs os]; try discriminate H.
  unfold dp_tri_b in H. rewrite !CM.load_eq in H.
  destruct (Mem.load Mint16signed m bs (Ptrofs.unsigned (Ptrofs.add os (Ptrofs.repr 0)))) as [[| ty | | | |]|] eqn:Lt; try discriminate H.
  destruct (Mem.load Mint8signed m bs (Ptrofs.unsigned (Ptrofs.add os (Ptrofs.repr 4)))) as [[| fl | | | |]|] eqn:Lf; try discriminate H.
  repeat match goal with Hc : _ && _ = true |- _ => apply andb_prop in Hc as [Hc ?] end.
  exists bs, os, ty, fl. cbn [Mem.loadv].
  split; [reflexivity |]. split; [exact Lt |]. split; [apply negb_true_iff; assumption |].
  split; [exact Lf |]. split; [assumption |].
  do 6 (split; [apply i16_is_ok; assumption |]).
  do 3 (split; [apply f32_is_sound; assumption |]).
  apply f32_is_sound; assumption.
Qed.

Fixpoint find_b (fuel : nat) (m : mem) (p : val -> bool) (v : val) : bool :=
  match v with
  | Vptr bn on =>
      match fuel with
      | O => false
      | S f =>
          match CM.load Mint32 m bn (Ptrofs.unsigned (Ptrofs.add on (Ptrofs.repr SN_SURF))) with
          | Some s => p s
          | None => false
          end
          || match CM.load Mint32 m bn (Ptrofs.unsigned (Ptrofs.add on (Ptrofs.repr SN_NEXT))) with
             | Some nx => find_b f m p nx
             | None => false
             end
      end
  | _ => false
  end.

Lemma find_b_sound : forall fuel m p v, find_b fuel m p v = true ->
    exists s, on_list m v s /\ p s = true.
Proof.
  induction fuel as [| f IH]; intros m p v H; destruct v as [| | | | | bn on]; cbn in H;
    try discriminate H.
  rewrite !CM.load_eq in H.
  apply orb_prop in H as [H | H].
  - destruct (Mem.load Mint32 m bn (Ptrofs.unsigned (Ptrofs.add on (Ptrofs.repr SN_SURF))))
      as [s|] eqn:L; [| discriminate H].
    exists s. split; [apply ol_here; cbn [Mem.loadv]; exact L | exact H].
  - destruct (Mem.load Mint32 m bn (Ptrofs.unsigned (Ptrofs.add on (Ptrofs.repr SN_NEXT))))
      as [nx|] eqn:L; [| discriminate H].
    destruct (IH m p nx H) as (s & OL & Hp). exists s.
    split; [eapply ol_next; [cbn [Mem.loadv]; exact L | exact OL] | exact Hp].
Qed.

Definition dp_cell (fuel : nat) (m : mem) (pb : block) (k : Z) : bool :=
  match CM.load Mint32 m pb k with
  | Some hd => find_b fuel m (fun s => dp_tri_b m s 8192 (-8191) (-8191) (-8191) (-8191) 8192) hd
               && find_b fuel m (fun s => dp_tri_b m s 8192 (-8191) (-8191) 8192 8192 8192) hd
  | None => false
  end.

Definition dp_chk (fuel : nat) (ge : genv) (m : mem) : bool :=
  match Genv.find_symbol ge surface_collision._gStaticSurfacePartition with
  | Some pb => forallb (fun cz => forallb (fun cx => dp_cell fuel m pb (384 * cz + 24 * cx))
                                    (zlist 16)) (zlist 16)
  | None => false
  end.

Lemma dp_chk_sound : forall fuel ge m, dp_chk fuel ge m = true -> FfComplete.dp_lists ge m.
Proof.
  intros fuel ge m H cz cx Hz Hx. unfold dp_chk in H.
  destruct (Genv.find_symbol ge surface_collision._gStaticSurfacePartition) as [pb|] eqn:Hs;
    [| discriminate H].
  rewrite forallb_forall in H. specialize (H cz (in_zlist 16 cz ltac:(lia))).
  rewrite forallb_forall in H. specialize (H cx (in_zlist 16 cx ltac:(lia))).
  unfold dp_cell in H. rewrite CM.load_eq in H.
  destruct (Mem.load Mint32 m pb (384 * cz + 24 * cx)) as [hd|] eqn:L; [| discriminate H].
  apply andb_prop in H as [HA HB].
  destruct (find_b_sound _ _ _ _ HA) as (sA & OA & PA).
  destruct (find_b_sound _ _ _ _ HB) as (sB & OB & PB).
  exists pb, hd. split; [first [exact Hs | reflexivity] |].
  split.
  { cbn [Mem.loadv]. rewrite Ptrofs.unsigned_repr; [exact L |].
    change Ptrofs.max_unsigned with 4294967295. lia. }
  split; [exists sA; split; [exact OA | exact (dp_tri_b_sound _ _ _ _ _ _ _ _ PA)] |].
  exists sB; split; [exact OB | exact (dp_tri_b_sound _ _ _ _ _ _ _ _ PB)].
Qed.

Lemma bo_chk_hh : forall m bo, bo_chk m bo = true ->
    Mem.load Mfloat32 m bo (MARIO_OFF + 508) = Some (Vsingle FFW_F100)
    /\ Mem.load Mfloat32 m bo (MARIO_OFF + 520) = Some (Vsingle FFW_F0).
Proof.
  intros m bo H. unfold bo_chk in H. apply andb_prop in H as [H H2]. apply andb_prop in H as [_ H1].
  exact (conj (f32_is_sound _ _ _ _ H1) (f32_is_sound _ _ _ _ H2)).
Qed.

(* the objects phase runs from the witness: one real area_update_objects
   (update_objects over the spawned objects) is not stuck.  Stated inline
   as [done_b (ex_call ...)] in wchk: behind a wrapper Definition the
   kernel's conversion at Qed unfolded the wrapper's inner match first and
   ran the interpreter on FUEL (a 54-minute hang, 2026-10-26) *)
Definition done_b {A} (r : res A) : bool :=
  match r with Done _ => true | Stuck _ _ _ => false end.

(* one frame runs from the witness, A not pressed, and keeps the action *)
Definition frame_ok (ge : genv) (bm bo : block) (m : mem) : bool :=
  negb (BootRun.a_pressed_b bm m)
  && match ex_call ge BootRun.world FUEL m (Internal mario.f_execute_mario_action)
             [Vptr bo (Ptrofs.repr MARIO_OFF)] with
     | Done (_, m', _) => BootRun.ld32_is m' bm 12 BootRun.ACT_SPAWN_NO_SPIN_AIRBORNE
     | Stuck _ _ _ => false
     end.

(* ---------------------------------------------------------------------- *)
(* The area's Camera (2026-10-26; in the real entry since 2026-11-03).     *)
(* ---------------------------------------------------------------------- *)
(* The real path: AREA's level_cmd_begin_area runs process_geo_layout on
   WMotR's geo (levels/wmotr/areas/1/geo.inc.c:16, GEO_CAMERA(16, 0, 2000,
   6000, 0, 0, 0, geo_camera_main)).  geo_layout_cmd_node_camera reads
   pos/focus into stack Vec3fs and calls init_graph_node_camera(pool, NULL,
   pos, focus, func, mode) (graph_node.c:189), whose func call
   geo_camera_main(GEO_CONTEXT_CREATE) runs create_camera(gc, pool)
   (camera.c:3494); then level_script.c stores gAreas[areaIndex].camera =
   node->config.camera.  geo_layout.c is not linked, so entry_g's area_g
   (stand-in S3) builds the root and that camera node by the real
   init_graph_node_root / init_graph_node_camera / create_camera in the
   level pool, with the node's func NULL and create_camera called directly
   (geo_camera_main's GEO_CONTEXT_CREATE case is exactly that call); the
   real init_mario_after_warp then runs reset_camera on it. *)
Definition cf32 (z : Z) : val := Vsingle (Float32.of_int (Int.repr z)).
(* the GEO_CAMERA command's pos (0, 2000, 6000) and focus (0, 0, 0) *)
Definition sc_writes (sc : block) : list wr :=
  [W Mfloat32 sc 0 (cf32 0); W Mfloat32 sc 4 (cf32 2000); W Mfloat32 sc 8 (cf32 6000);
   W Mfloat32 sc 12 (cf32 0); W Mfloat32 sc 16 (cf32 0); W Mfloat32 sc 20 (cf32 0)].

(* The chains are stated over an abstract runner [run] (ex_call ge world
   FUEL in the notations): their proofs then never make the kernel reduce a
   concrete interpreter call. *)
Definition runT : Type := mem -> fundef -> list val -> res (trace * mem * val).

(* one full frame through the camera: gAreaData[1].camera still holds the
   created Camera, and from the witness the objects phase
   (area_update_objects) and then update_camera on that Camera (the
   render's geo_camera_main(GEO_CONTEXT_RENDER) call) both run *)
(* the cutscene cells (FfWorld.cam_w, 2026-11-01): sObjectCutscene and the
   Camera's cutscene byte (+0x30) are neither 144 nor 168, the Camera is
   past the globals and not the animation buffer's block *)
Definition cut_okb (n : int) : bool :=
  negb (Z.eqb (Int.unsigned n) 144) && negb (Z.eqb (Int.unsigned n) 168).

(* the camera pins, R3 and the audio state (FfWorld.cam_w / aud_w, the
   root rebuild 2026-11-02), read off the same memory: gCamera is the
   Camera or no pointer; sMarioCamState / sLuigiCamState aim into
   gPlayerCameraState; gSecondCameraFocus holds no pointer; the Camera's
   108 bytes are apart from both surface pools (ObjWorld.ow_spool's
   SP_OFF / NP_OFF in the main pool); AudioInv by its decision procedure *)
Definition ptr_is (o : option val) (f : block -> ptrofs -> bool) : bool :=
  match o with Some (Vptr b x) => f b x | _ => true end.

Definition apartb (cb : block) (co : ptrofs) (n : Z) (bp : block) (op : ptrofs) : bool :=
  negb (Pos.eqb bp cb) || (Ptrofs.unsigned op + n <=? Ptrofs.unsigned co)
  || (Ptrofs.unsigned co + CAM_SZ <=? Ptrofs.unsigned op).

(* R3' (2026-11-03): the Camera's 108 bytes miss every spawn-info cell of
   the surface pool's block (FfWorld.cam_si) *)
Definition sib (cb : block) (co : ptrofs) (bp : block) (op : ptrofs) : bool :=
  negb (Pos.eqb bp cb)
  || forallb (fun s => (s + 4 <=? Ptrofs.unsigned co) || (Ptrofs.unsigned co + CAM_SZ <=? s)) CAM_SI.

(* gTimeStopState = 0 (object_list_processor.c's boot zero) *)
Definition ts_chk (ge : genv) (m : mem) : bool :=
  match Genv.find_symbol ge object_list_processor._gTimeStopState with
  | Some b => match CM.load Mint32 m b 0 with Some (Vint n) => Int.eq n Int.zero | _ => false end
  | None => false
  end.

Lemma ts_chk_sound : forall ge m, ts_chk ge m = true ->
  forall b, Genv.find_symbol ge object_list_processor._gTimeStopState = Some b ->
    Mem.load Mint32 m b 0 = Some (Vint Int.zero).
Proof.
  intros ge m H b Hb. unfold ts_chk in H. rewrite Hb, CM.load_eq in H.
  destruct (Mem.load Mint32 m b 0) as [[| n | | | |]|]; try discriminate.
  pose proof (Int.eq_spec n Int.zero) as Q. rewrite H in Q. subst n. reflexivity.
Qed.

Definition pin_chk (ge : genv) (cam : val) (m : mem) : bool :=
  match Genv.find_symbol ge camera._gCamera, Genv.find_symbol ge camera._sMarioCamState,
        Genv.find_symbol ge camera._sLuigiCamState, Genv.find_symbol ge camera._gSecondCameraFocus,
        Genv.find_symbol ge camera._gPlayerCameraState,
        Genv.find_symbol ge surface_load._sSurfacePool, Genv.find_symbol ge surface_load._sSurfaceNodePool, cam with
  | Some bgc, Some bms, Some bls, Some bsf, Some bpcs, Some bsp, Some bnp, Vptr cb co =>
      ptr_is (CM.load Mint32 m bgc 0) (fun b x => Pos.eqb b cb && Ptrofs.eq x co)
      && ptr_is (CM.load Mint32 m bms 0) (fun b _ => Pos.eqb b bpcs)
      && ptr_is (CM.load Mint32 m bls 0) (fun b _ => Pos.eqb b bpcs)
      && ptr_is (CM.load Mint32 m bsf 0) (fun _ _ => false)
      && (Ptrofs.unsigned co + CAM_SZ <=? Ptrofs.max_unsigned)
      && ptr_is (CM.load Mint32 m bsp 0) (apartb cb co 110400)
      && ptr_is (CM.load Mint32 m bnp 0) (apartb cb co 56000)
      && ptr_is (CM.load Mint32 m bsp 0) (sib cb co)
      && AudioInv.aud_chk ge m
      && ObjWorld.ctr_b ge m && ts_chk ge m
  | _, _, _, _, _, _, _, _ => false
  end.

Lemma ptr_is_sound : forall o f b x, ptr_is o f = true -> o = Some (Vptr b x) -> f b x = true.
Proof. intros o f b x H ->. exact H. Qed.

Lemma pin_chk_sound : forall ge cb co m, pin_chk ge (Vptr cb co) m = true ->
  (forall b, Genv.find_symbol ge camera._gCamera = Some b ->
     forall bb oo, Mem.load Mint32 m b 0 = Some (Vptr bb oo) -> bb = cb /\ oo = co)
  /\ (forall x b, In x [camera._sMarioCamState; camera._sLuigiCamState] ->
       Genv.find_symbol ge x = Some b ->
       forall bb oo, Mem.load Mint32 m b 0 = Some (Vptr bb oo) ->
         Genv.find_symbol ge camera._gPlayerCameraState = Some bb)
  /\ (forall b, Genv.find_symbol ge camera._gSecondCameraFocus = Some b ->
       forall bb oo, Mem.load Mint32 m b 0 <> Some (Vptr bb oo))
  /\ Ptrofs.unsigned co + CAM_SZ <= Ptrofs.max_unsigned
  /\ (forall id n bs bp op, In (id, n) cam_pools -> Genv.find_symbol ge id = Some bs ->
        Mem.load Mint32 m bs 0 = Some (Vptr bp op) ->
        bp <> cb \/ Ptrofs.unsigned op + n <= Ptrofs.unsigned co
        \/ Ptrofs.unsigned co + CAM_SZ <= Ptrofs.unsigned op)
  /\ cam_si ge m cb co
  /\ AudioInv.AudioInv ge m
  /\ ObjWorld.ctr_ok ge m
  /\ (forall b, Genv.find_symbol ge object_list_processor._gTimeStopState = Some b ->
        Mem.load Mint32 m b 0 = Some (Vint Int.zero)).
Proof.
  intros ge cb co m H. unfold pin_chk in H.
  destruct (Genv.find_symbol ge camera._gCamera) as [bgc|] eqn:S1; [ | discriminate ].
  destruct (Genv.find_symbol ge camera._sMarioCamState) as [bms|] eqn:S2; [ | discriminate ].
  destruct (Genv.find_symbol ge camera._sLuigiCamState) as [bls|] eqn:S3; [ | discriminate ].
  destruct (Genv.find_symbol ge camera._gSecondCameraFocus) as [bsf|] eqn:S4; [ | discriminate ].
  destruct (Genv.find_symbol ge camera._gPlayerCameraState) as [bpcs|] eqn:S5; [ | discriminate ].
  destruct (Genv.find_symbol ge surface_load._sSurfacePool) as [bsp|] eqn:S6; [ | discriminate ].
  destruct (Genv.find_symbol ge surface_load._sSurfaceNodePool) as [bnp|] eqn:S7; [ | discriminate ].
  rewrite !CM.load_eq in H. cbv beta iota in H.
  repeat match type of H with (_ && _) = true => apply andb_prop in H as [H ?] end.
  rename H into P1.
  match goal with
  | A : AudioInv.aud_chk _ _ = true |- _ => pose proof (AudioInv.aud_chk_sound _ _ A) as AI
  end.
  match goal with
  | A : ObjWorld.ctr_b _ _ = true |- _ => pose proof (ObjWorld.ctr_b_sound _ _ A) as CT
  end.
  match goal with
  | A : ts_chk _ _ = true |- _ => pose proof (ts_chk_sound _ _ A) as TS
  end.
  split; [ | split; [ | split; [ | split; [ | split; [ | split; [ | split; [ | split ] ] ] ] ] ] ].
  - intros b Hb bb oo L. try rewrite S1 in Hb. injection Hb as <-.
    pose proof (ptr_is_sound _ _ _ _ P1 L) as E. cbn beta in E.
    apply andb_prop in E as [E1 E2]. apply Pos.eqb_eq in E1.
    split; [ exact E1 | ].
    pose proof (Ptrofs.eq_spec oo co) as Q. rewrite E2 in Q. exact Q.
  - intros x b Hx Hb bb oo L. cbn [In] in Hx.
    destruct Hx as [<- | [<- | []]].
    + rewrite S2 in Hb. injection Hb as <-.
      match goal with Hq : ptr_is (Mem.load Mint32 m bms 0) _ = true |- _ =>
        pose proof (ptr_is_sound _ _ _ _ Hq L) as E end.
      apply Pos.eqb_eq in E. subst bb. first [ reflexivity | exact S5 ].
    + rewrite S3 in Hb. injection Hb as <-.
      match goal with Hq : ptr_is (Mem.load Mint32 m bls 0) _ = true |- _ =>
        pose proof (ptr_is_sound _ _ _ _ Hq L) as E end.
      apply Pos.eqb_eq in E. subst bb. first [ reflexivity | exact S5 ].
  - intros b Hb bb oo L. try rewrite S4 in Hb. injection Hb as <-.
    match goal with Hq : ptr_is (Mem.load Mint32 m bsf 0) _ = true |- _ =>
      pose proof (ptr_is_sound _ _ _ _ Hq L) as E end.
    discriminate E.
  - match goal with Hq : (_ <=? Ptrofs.max_unsigned) = true |- _ => apply Z.leb_le in Hq; exact Hq end.
  - intros id n bs bp op Hin Hs L. cbn [cam_pools In] in Hin.
    assert (K : ptr_is (Mem.load Mint32 m bs 0) (apartb cb co n) = true ->
              bp <> cb \/ Ptrofs.unsigned op + n <= Ptrofs.unsigned co
              \/ Ptrofs.unsigned co + CAM_SZ <= Ptrofs.unsigned op).
    { intros Hq. pose proof (ptr_is_sound _ _ _ _ Hq L) as E. unfold apartb in E.
      apply orb_true_iff in E as [E | E]; [ apply orb_true_iff in E as [E | E] | ].
      - left. apply negb_true_iff, Pos.eqb_neq in E. exact E.
      - right; left. apply Z.leb_le in E. exact E.
      - right; right. apply Z.leb_le in E. exact E. }
    destruct Hin as [E | [E | []]]; injection E as <- <-.
    + rewrite S6 in Hs. injection Hs as <-. apply K; assumption.
    + rewrite S7 in Hs. injection Hs as <-. apply K; assumption.
  - intros bs bp op Hs L. rewrite S6 in Hs. injection Hs as <-.
    match goal with Hq : ptr_is (Mem.load Mint32 m bsp 0) (sib cb co) = true |- _ =>
      pose proof (ptr_is_sound _ _ _ _ Hq L) as E end.
    unfold sib in E. apply orb_true_iff in E as [E | E].
    + left. apply negb_true_iff, Pos.eqb_neq in E. exact E.
    + right. intros z Hz. pose proof (proj1 (forallb_forall _ _) E z Hz) as Q. cbn beta in Q.
      apply orb_true_iff in Q as [Q | Q]; apply Z.leb_le in Q; [ left | right ]; exact Q.
  - exact AI.
  - exact CT.
  - exact TS.
Qed.

Definition cut_chk (ge : genv) (cam : val) (m : mem) : bool :=
  match Genv.find_symbol ge camera._sObjectCutscene, Genv.find_symbol ge mario._gMarioAnimsBuf, cam with
  | Some bs, Some ab, Vptr cb co =>
      match CM.load Mint8unsigned m bs 0, CM.load Mint32 m ab 8,
            CM.load Mint8unsigned m cb (Ptrofs.unsigned co + 48) with
      | Some (Vint n1), Some (Vptr bt _), Some (Vint n2) =>
          cut_okb n1 && cut_okb n2 && Pos.leb (Genv.genv_next ge) cb && negb (Pos.eqb bt cb)
          && pin_chk ge cam m
      | _, _, _ => false
      end
  | _, _, _ => false
  end.

Lemma cut_okb_ok : forall n, cut_okb n = true -> cut_ok n.
Proof.
  intros n H. unfold cut_okb in H. apply andb_prop in H as [H1 H2].
  apply negb_true_iff, Z.eqb_neq in H1. apply negb_true_iff, Z.eqb_neq in H2. exact (conj H1 H2).
Qed.

Lemma cut_chk_sound : forall ge cam m, cut_chk ge cam m = true ->
  exists cb co, cam = Vptr cb co
    /\ (forall bs, Genv.find_symbol ge camera._sObjectCutscene = Some bs ->
          exists n, Mem.load Mint8unsigned m bs 0 = Some (Vint n) /\ cut_ok n)
    /\ Ple (Genv.genv_next ge) cb
    /\ (forall ab bt ot, Genv.find_symbol ge mario._gMarioAnimsBuf = Some ab ->
          Mem.load Mint32 m ab 8 = Some (Vptr bt ot) -> bt <> cb)
    /\ exists n, Mem.load Mint8unsigned m cb (Ptrofs.unsigned co + 48) = Some (Vint n) /\ cut_ok n.
Proof.
  intros ge cam m H. unfold cut_chk in H.
  destruct (Genv.find_symbol ge camera._sObjectCutscene) as [bs|] eqn:Hs; [ | discriminate ].
  destruct (Genv.find_symbol ge mario._gMarioAnimsBuf) as [ab|] eqn:Ha; [ | discriminate ].
  destruct cam as [| | | | | cb co]; try discriminate.
  rewrite !CM.load_eq in H.
  destruct (Mem.load Mint8unsigned m bs 0) as [[| n1 | | | |]|] eqn:L1; try discriminate.
  destruct (Mem.load Mint32 m ab 8) as [[| | | | | bt ot]|] eqn:L2; try discriminate.
  destruct (Mem.load Mint8unsigned m cb (Ptrofs.unsigned co + 48)) as [[| n2 | | | |]|] eqn:L3; try discriminate.
  apply andb_prop in H as [H _].
  apply andb_prop in H as [H H4]. apply andb_prop in H as [H H3]. apply andb_prop in H as [H1 H2].
  exists cb, co. split; [ reflexivity | ].
  split; [ intros bs' Hs'; injection Hs' as <-; exists n1; exact (conj L1 (cut_okb_ok _ H1)) | ].
  split; [ apply Pos.leb_le in H3; exact H3 | ].
  split; [ | exists n2; exact (conj L3 (cut_okb_ok _ H2)) ].
  intros ab' bt' ot' Ha' L'. injection Ha' as <-. rewrite L2 in L'. injection L' as <- _.
  apply negb_true_iff, Pos.eqb_neq in H4. exact H4.
Qed.

Lemma cut_chk_pin : forall ge cam m, cut_chk ge cam m = true -> pin_chk ge cam m = true.
Proof.
  intros ge cam m H. unfold cut_chk in H.
  repeat match type of H with
    | (match ?x with _ => _ end) = true => destruct x; try discriminate H
    end.
  apply andb_prop in H as [_ H]. exact H.
Qed.

Definition cam_frame_g (run : runT) (cutp : val -> mem -> bool) (bgad : block) (cam : val) (m : mem) : bool :=
  cutp cam m &&
  match CM.load Mint32 m bgad 96 with
  | Some v =>
      (if Val.eq v cam then true else false)
      && match run m (Internal area.f_area_update_objects) [] with
         | Done (_, m', _) =>
             match run m' (Internal camera.f_update_camera) [cam] with
             | Done _ => true
             | Stuck _ _ _ => false
             end
         | Stuck _ _ _ => false
         end
  | None => false
  end.

Notation cam_frame_ok ge := (cam_frame_g (ex_call ge BootRun.world FUEL) (cut_chk ge)).

(* ---------------------------------------------------------------------- *)
(* THE WHOLE FRAME (2026-11-02): HeightFrame.play_frame_step's segments,   *)
(* run from the witness: audio_game_loop_tick and select_gfx_pool          *)
(* (MidKeep.mid_call), read_controller_inputs, play_mode_normal's PRE      *)
(* slice (in PLAY_MODE_NORMAL), area_update_objects, the POST slice        *)
(* (update_camera among it); the render tail is the identity there         *)
(* (seg_rest / seg_render allow it once gMarioPlatform is still).  The     *)
(* object world and the frame-boundary counters are re-checked after the   *)
(* objects phase and after the POST slice.                                 *)
(* ---------------------------------------------------------------------- *)
Definition srunT : Type := env -> temp_env -> mem -> statement -> res (trace * temp_env * mem * outcome).

Definition pm_b (ge : genv) (m : mem) : bool :=
  match Genv.find_symbol ge level_update._sCurrPlayMode with
  | Some b => match CM.load Mint16signed m b 0 with Some (Vint i) => Int.eq i Int.zero | _ => false end
  | None => false
  end.

Definition in_wmotr_b (ge : genv) (m : mem) : bool :=
  match Genv.find_symbol ge level_update._gCurrLevelNum with
  | Some b => match CM.load Mint16signed m b 0 with
              | Some (Vint i) => Int.eq i (Int.repr LEVEL_WMOTR) | _ => false end
  | None => false
  end.

Definition plat_still_b (ge : genv) (m : mem) : bool :=
  match Genv.find_symbol ge platform_displacement._gMarioPlatform with
  | Some bp =>
      match CM.load Mint32 m bp 0 with
      | Some (Vint i) => Int.eq i Int.zero
      | Some (Vptr pb po) =>
          match Genv.find_symbol ge object_list_processor._gObjectPool with
          | Some pb' =>
              Pos.eqb pb pb'
              && forallb (fun k => match CM.loadv Mint32 m (Vptr pb (Ptrofs.add po (Ptrofs.repr (136 + 4 * k)))) with
                                   | Some (Vint j) => Int.eq j Int.zero | _ => false end) [35; 36; 37]
              && Z.eqb (Ptrofs.unsigned po mod 608) 0 && Z.ltb (Ptrofs.unsigned po) (240 * 608)
          | None => false
          end
      | _ => false
      end
  | None => false
  end.

Definition frame_g (run : runT) (srun : srunT) (ge : genv) (bm : block) (m : mem) : bool :=
  match run m (Internal sound_init.f_audio_game_loop_tick) [] with
  | Done (_, i1, _) =>
  match run i1 (Internal game_init.f_select_gfx_pool) [] with
  | Done (_, i, _) =>
  match run i (Internal game_init.f_read_controller_inputs) [] with
  | Done (_, m0, _) =>
    pm_b ge m0 &&
    match srun empty_env (create_undef_temps (fn_temps level_update.f_play_mode_normal)) m0 LevelFlank.lv_pre with
    | Done (_, le, ma, _) =>
      match run ma (Internal area.f_area_update_objects) [] with
      | Done (_, m3, _) =>
        ObjWorld.ow_chk ge bm m3 && ObjWorld.ctr_b ge m3 &&
        match srun empty_env le m3 LevelFlank.lv_post with
        | Done (_, _, m4, _) =>
            plat_still_b ge m4 && in_wmotr_b ge m4 && ObjWorld.ow_chk ge bm m4 && ObjWorld.ctr_b ge m4
        | Stuck _ _ _ => false
        end
      | Stuck _ _ _ => false
      end
    | Stuck _ _ _ => false
    end
  | Stuck _ _ _ => false
  end
  | Stuck _ _ _ => false
  end
  | Stuck _ _ _ => false
  end.

Notation frame_w ge := (frame_g (ex_call ge BootRun.world FUEL) (ex_stmt ge BootRun.world FUEL) ge).

Definition frame_ran (ge : genv) (bm : block) (m : mem) : Prop :=
  exists i1 i m0 le ma m3 m4,
    (exists t v, eval_funcall function_entry2 ge m (Internal sound_init.f_audio_game_loop_tick) [] t i1 v)
    /\ (exists t v, eval_funcall function_entry2 ge i1 (Internal game_init.f_select_gfx_pool) [] t i v)
    /\ (exists t v, eval_funcall function_entry2 ge i (Internal game_init.f_read_controller_inputs) [] t m0 v)
    /\ pm_b ge m0 = true
    /\ (exists t out, exec_stmt function_entry2 ge empty_env
                        (create_undef_temps (fn_temps level_update.f_play_mode_normal)) m0 LevelFlank.lv_pre
                        t le ma out)
    /\ (exists t v, eval_funcall function_entry2 ge ma (Internal area.f_area_update_objects) [] t m3 v)
    /\ ObjWorld.ow_chk ge bm m3 = true /\ ObjWorld.ctr_b ge m3 = true
    /\ (exists t le' out, exec_stmt function_entry2 ge empty_env le m3 LevelFlank.lv_post t le' m4 out)
    /\ plat_still_b ge m4 = true /\ in_wmotr_b ge m4 = true
    /\ ObjWorld.ow_chk ge bm m4 = true /\ ObjWorld.ctr_b ge m4 = true.

Lemma frame_g_sound : forall (ge : genv) (run : runT) (srun : srunT) bm m,
    (forall m f a t m' v, run m f a = Done (t, m', v) -> eval_funcall function_entry2 ge m f a t m' v) ->
    (forall e le m s t le' m' out, srun e le m s = Done (t, le', m', out) ->
       exec_stmt function_entry2 ge e le m s t le' m' out) ->
    frame_g run srun ge bm m = true -> frame_ran ge bm m.
Proof.
  intros ge run srun bm m Rs Ss H. unfold frame_g in H.
  destruct (run m _ _) as [[[t1 i1] v1]| ? ? ?] eqn:R1; [ | discriminate H ].
  destruct (run i1 _ _) as [[[t2 i] v2]| ? ? ?] eqn:R2; [ | discriminate H ].
  destruct (run i _ _) as [[[t3 m0] v3]| ? ? ?] eqn:R3; [ | discriminate H ].
  apply andb_prop in H as [Hpm H].
  destruct (srun _ _ m0 _) as [[[[t4 le] ma] o4]| ? ? ?] eqn:R4; [ | discriminate H ].
  destruct (run ma _ _) as [[[t5 m3] v5]| ? ? ?] eqn:R5; [ | discriminate H ].
  apply andb_prop in H as [H H6]. apply andb_prop in H as [Ho3 Hc3].
  destruct (srun _ le m3 _) as [[[[t6 le6] m4] o6]| ? ? ?] eqn:R6; [ | discriminate H6 ].
  apply andb_prop in H6 as [H6 Hc4]. apply andb_prop in H6 as [H6 Ho4]. apply andb_prop in H6 as [Hps Hw].
  exists i1, i, m0, le, ma, m3, m4.
  split; [ exists t1, v1; exact (Rs _ _ _ _ _ _ R1) | ].
  split; [ exists t2, v2; exact (Rs _ _ _ _ _ _ R2) | ].
  split; [ exists t3, v3; exact (Rs _ _ _ _ _ _ R3) | ].
  split; [ exact Hpm | ].
  split; [ exists t4, o4; exact (Ss _ _ _ _ _ _ _ _ R4) | ].
  split; [ exists t5, v5; exact (Rs _ _ _ _ _ _ R5) | ].
  split; [ exact Ho3 | split; [ exact Hc3 | ] ].
  split; [ exists t6, le6, o6; exact (Ss _ _ _ _ _ _ _ _ R6) | ].
  exact (conj Hps (conj Hw (conj Ho4 Hc4))).
Qed.

Lemma frame_w_sound : forall ge bm m, BootRun.world_ok ge -> frame_w ge bm m = true -> frame_ran ge bm m.
Proof.
  intros ge bm m Wk H.
  exact (frame_g_sound ge _ _ bm m (fun m f a t m' v R => ex_call_sound ge BootRun.world Wk _ _ _ _ _ _ _ R)
           (fun e le m s t le' m' out R => proj1 (ex_sound ge BootRun.world Wk FUEL) e le m s t le' m' out R) H).
Qed.

(* ====================================================================== *)
(* THE REAL ENTRY (2026-11-03).  From the main pool's post-state, the real *)
(* boot and level code, in the game's order, run by the sound interpreter: *)
(* sound_init (the sound thread's boot) and init_mario_from_save_file (the *)
(* file select); select_gfx_pool (the game loop); WMotR's level script,    *)
(* command by command, each through the REAL dispatch table                *)
(* LevelScriptJumpTable on the command's type byte with sCurrentCmd at the *)
(* command (INIT_LEVEL, ALLOC_LEVEL_POOL, MARIO; the area's OBJECT,        *)
(* WARP_NODE, TERRAIN, MACRO_OBJECTS, SET_BACKGROUND_MUSIC, TERRAIN_TYPE,  *)
(* END_AREA; FREE_LEVEL_POOL; MARIO_POS); then CALL(0,                     *)
(* lvl_init_or_update)'s init_level: its statements up to the warp branch, *)
(* warp_level's three (gCurrLevelNum, level_control_timer, load_area: the  *)
(* area's spawn infos, load_area_terrain, Mario's spawn), and              *)
(* init_mario_after_warp's first eight (load_mario_area, init_mario: the   *)
(* real find_floor, set_mario_initial_action, reset_camera, the warp       *)
(* cells).  The stand-ins, all here and in StartTerrain's header table:    *)
(*   S1  the castle action: gMarioState->action := ACT_IDLE before the     *)
(*       level script (init_mario_from_save_file leaves it 0, and          *)
(*       init_mario_after_warp spawns Mario only if it is nonzero; any     *)
(*       nonzero action is overwritten by init_mario);                     *)
(*   S2  gCurrActNum := 1 (the act select / title screen);                 *)
(*   S3  the LOAD_* segment loads, the three JUMP_LINKs to the global      *)
(*       model scripts and AREA's geo layout are not run (geo_layout.c is  *)
(*       not linked): AREA(1) is the real init_graph_node_root and the     *)
(*       area's camera node (init_graph_node_camera, create_camera), then  *)
(*       level_cmd_begin_area's four stores (sCurrAreaIndex, the root's    *)
(*       areaIndex, gAreas[1].unk04 / .camera);                             *)
(*   S4  the dispatcher level_script_execute is not run: each command's    *)
(*       handler runs (the JUMP_LINKed local scripts' commands in place);  *)
(*   S5  FREE_LEVEL_POOL's alloc_only_pool_resize has no CompCert          *)
(*       execution (main_pool_free's pointer difference, TRUST 3.6):       *)
(*       main_pool_free's effect as three stores, then the REAL            *)
(*       main_pool_alloc main_pool_realloc makes, resize's totalSpace      *)
(*       store, and the REAL rest of level_cmd_free_level_pool             *)
(*       (alloc_surface_pools);                                            *)
(*   S6  init_mario_after_warp's ninth statement (the background music:    *)
(*       set_background_music, the unlinked audio engine) and init_level's *)
(*       tail (the ACT_INTRO_CUTSCENE test) are not run.                    *)
(* ====================================================================== *)
Definition ACT_IDLE_Z : Z := 0x0C400201.

Definition L_ENT : ident := wmotr_script._level_wmotr_entry.
Definition L_LOC1 : ident := wmotr_script._script_func_local_1.
Definition L_LOC2 : ident := wmotr_script._script_func_local_2.

(* the commands, by word index (decoded from the generated script) *)
Definition cmds_head : list (ident * nat) := [(L_ENT, 0%nat); (L_ENT, 28%nat); (L_ENT, 29%nat)].
Definition cmds_area : list (ident * nat) :=
  [(L_ENT, 40%nat); (L_ENT, 46%nat); (L_ENT, 48%nat); (L_ENT, 50%nat); (L_ENT, 52%nat);
   (L_LOC1, 0%nat); (L_LOC1, 6%nat); (L_LOC1, 12%nat); (L_LOC1, 18%nat); (L_LOC1, 24%nat); (L_LOC1, 30%nat);
   (L_LOC2, 0%nat);
   (L_ENT, 58%nat); (L_ENT, 60%nat); (L_ENT, 62%nat); (L_ENT, 64%nat); (L_ENT, 65%nat)].
Definition FREE_POOL_CMD : nat := 66.
Definition cmds_tail : list (ident * nat) := [(L_ENT, 67%nat)].

(* the type byte of a command word *)
Definition cmd_type (c : ident * nat) : Z :=
  let l := if Pos.eqb (fst c) L_ENT then gvar_init wmotr_script.v_level_wmotr_entry
           else if Pos.eqb (fst c) L_LOC1 then gvar_init wmotr_script.v_script_func_local_1
           else gvar_init wmotr_script.v_script_func_local_2 in
  match nth_error l (snd c) with
  | Some (Init_int32 h) => Z.shiftr (Int.unsigned h) 24
  | _ => -1
  end.

(* non-vacuity of the decoding: INIT_LEVEL (0x1B), ALLOC_LEVEL_POOL (0x1D),
   MARIO (0x25); OBJECT (0x24), WARP_NODE (0x26) x4, the seven OBJECTs of
   the two JUMP_LINKed scripts, TERRAIN (0x2E), MACRO_OBJECTS (0x39),
   SET_BACKGROUND_MUSIC (0x36), TERRAIN_TYPE (0x31), END_AREA (0x20);
   FREE_LEVEL_POOL (0x1E); MARIO_POS (0x2B) *)
Lemma cmd_types :
  map cmd_type cmds_head = [27; 29; 37]
  /\ map cmd_type cmds_area = [36; 38; 38; 38; 38; 36; 36; 36; 36; 36; 36; 36; 46; 57; 54; 49; 32]
  /\ cmd_type (L_ENT, FREE_POOL_CMD) = 30 /\ map cmd_type cmds_tail = [43].
Proof. vm_compute. repeat split; reflexivity. Qed.

(* one level command: sCurrentCmd := the command; the handler the REAL
   LevelScriptJumpTable holds for its type byte; that handler, run *)
Definition run_cmd_g (run : runT) (ge : genv) (bcur btab : block) (m : mem) (c : ident * nat) : option mem :=
  match Genv.find_symbol ge (fst c) with
  | Some bs =>
    match CM.store Mint32 m bcur 0 (Vptr bs (Ptrofs.repr (4 * Z.of_nat (snd c)))) with
    | Some m1 =>
      match CM.load Mint8unsigned m1 bs (4 * Z.of_nat (snd c)) with
      | Some (Vint ty) =>
        match CM.load Mint32 m1 btab (4 * Int.unsigned ty) with
        | Some fp =>
          match Genv.find_funct ge fp with
          | Some fd => match run m1 fd [] with Done (_, m2, _) => Some m2 | Stuck _ _ _ => None end
          | None => None
          end
        | None => None
        end
      | _ => None
      end
    | None => None
    end
  | None => None
  end.

Fixpoint run_cmds_g (run : runT) (ge : genv) (bcur btab : block) (m : mem) (cs : list (ident * nat)) : option mem :=
  match cs with
  | [] => Some m
  | c :: r =>
    match run_cmd_g run ge bcur btab m c with
    | Some m1 => run_cmds_g run ge bcur btab m1 r
    | None => None
    end
  end.

(* a function's body as its top-level statements *)
Fixpoint spine (s : statement) : list statement :=
  match s with Ssequence a b => a :: spine b | s => [s] end.

Definition stmt_step (srun : srunT) (e : env) (acc : option (temp_env * mem)) (s : statement)
  : option (temp_env * mem) :=
  match acc with
  | Some (le, m) =>
    match srun e le m s with
    | Done (_, le', m', Out_normal) => Some (le', m')
    | _ => None
    end
  | None => None
  end.

(* statements lo .. lo + k - 1 of f's body, from f's entry (no arguments) *)
Definition slice_g (srun : srunT) (ge : genv) (f : function) (lo k : nat) (m : mem) : option mem :=
  match ev_entry ge f [] m with
  | Some (e, le, m1) =>
    match fold_left (stmt_step srun e) (firstn k (skipn lo (spine (fn_body f)))) (Some (le, m1)) with
    | Some (_, m2) => Some m2
    | None => None
    end
  | None => None
  end.

(* S3: AREA(1, wmotr_geo_0001F0) without the geo layout *)
Definition area_g (run : runT) (ge : genv) (bai bgad : block) (lpool : val) (m : mem) : option mem :=
  match off ge "GraphNodeRoot" "areaIndex", off ge "Area" "unk04", off ge "Area" "camera" with
  | Some oai, Some ou, Some oc =>
  match run m (Internal graph_node.f_init_graph_node_root)
          [lpool; Vint Int.zero; Vint Int.zero; Vint (Int.repr 160); Vint (Int.repr 120);
           Vint (Int.repr 160); Vint (Int.repr 120)] with
  | Done (_, Q1, Vptr rb ro) =>
    let (Q2, sc) := Mem.alloc Q1 0 24 in
    match apply_writes Q2 (sc_writes sc) 0 with
    | inl Q3 =>
      match run Q3 (Internal graph_node.f_init_graph_node_camera)
              [lpool; Vint Int.zero; Vptr sc Ptrofs.zero; Vptr sc (Ptrofs.repr 12); Vint Int.zero;
               Vint (Int.repr 16)] with
      | Done (_, Q4, gc) =>
        match run Q4 (Internal camera.f_create_camera) [gc; lpool] with
        | Done (_, Q5, _) =>
          match CM.free_list Q5 [(sc, 0, 24)] with
          | Some Q6 =>
            match CM.loadv Mint32 Q6 (Val.offset_ptr gc (Ptrofs.repr 24)) with
            | Some cam =>
              match CM.store Mint16signed Q6 bai 0 (Vint Int.one) with
              | Some Q7 =>
                match CM.store Mint8unsigned Q7 rb (Ptrofs.unsigned ro + oai) (Vint Int.one) with
                | Some Q8 =>
                  match CM.store Mint32 Q8 bgad (ssize ge "Area" + ou) (Vptr rb ro) with
                  | Some Q9 => CM.store Mint32 Q9 bgad (ssize ge "Area" + oc) cam
                  | None => None
                  end
                | None => None
                end
              | None => None
              end
            | None => None
            end
          | None => None
          end
        | Stuck _ _ _ => None
        end
      | Stuck _ _ _ => None
      end
    | inr _ => None
    end
  | _ => None
  end
  | _, _, _ => None
  end.

Definition ld_is (o : option val) (v : val) : bool :=
  match o with Some x => ObjWorld.veqb x v | None => false end.

(* S5: FREE_LEVEL_POOL.  Its first statement, alloc_only_pool_resize(
   sLevelPool, sLevelPool->usedSpace), has no CompCert execution:
   main_pool_free's sPoolFreeSpace += (uintptr_t) oldListHead - (uintptr_t)
   sPoolListHeadL subtracts two pointers as integers (TRUST 3.6).  Here:
   main_pool_realloc's test (the level pool's block is the last on the left
   list) and main_pool_free's walk (one step to the head) are checked, its
   effect is three stores (headL := block; block->next := NULL; freeSpace
   += head - block), then the REAL main_pool_alloc(size + 16, LEFT) that
   main_pool_realloc makes must return the same block, resize's own
   totalSpace store, and the REAL rest of level_cmd_free_level_pool
   (alloc_surface_pools) with sCurrentCmd at the command.  (lp: the level
   pool's offset in the main pool block; hp: the left head's) *)
Definition fp_size (u : int) : Z := Z.land (Int.unsigned u + 3) (Z.lnot 3).

Definition free_pool_g (run : runT) (srun : srunT) (ge : genv) (bcur blp s3 s4 bent : block) (m : mem)
  : option mem :=
  match CM.load Mint32 m blp 0 with
  | Some (Vptr bp lp) =>
    match CM.load Mint32 m bp (Ptrofs.unsigned lp + 4) with
    | Some (Vint u) =>
    match CM.load Mint32 m s4 0 with
    | Some (Vptr hb hp) =>
    match CM.load Mint32 m s3 0 with
    | Some (Vint fs) =>
      if Pos.eqb hb bp
         && ld_is (CM.load Mint32 m bp (Ptrofs.unsigned lp - 16 + 4)) (Vptr hb hp)
         && ld_is (CM.load Mint32 m bp (Ptrofs.unsigned hp + 4)) (Vint Int.zero) then
      match CM.store Mint32 m s4 0 (Vptr bp (Ptrofs.repr (Ptrofs.unsigned lp - 16))) with
      | Some m1 =>
        match CM.store Mint32 m1 bp (Ptrofs.unsigned lp - 16 + 4) (Vint Int.zero) with
        | Some m2 =>
          match CM.store Mint32 m2 s3 0
                  (Vint (Int.repr (Int.unsigned fs + (Ptrofs.unsigned hp - (Ptrofs.unsigned lp - 16))))) with
          | Some m3 =>
            match run m3 (Internal memory.f_main_pool_alloc) [Vint (Int.repr (fp_size u + 16)); Vint Int.zero] with
            | Done (_, m4, Vptr nb no) =>
              if Pos.eqb nb bp && Z.eqb (Ptrofs.unsigned no) (Ptrofs.unsigned lp) then
                match CM.store Mint32 m4 bp (Ptrofs.unsigned lp) (Vint (Int.repr (fp_size u))) with
                | Some m5 =>
                  match CM.store Mint32 m5 bcur 0 (Vptr bent (Ptrofs.repr (4 * Z.of_nat FREE_POOL_CMD))) with
                  | Some m6 => slice_g srun ge level_script.f_level_cmd_free_level_pool 1 100 m6
                  | None => None
                  end
                | None => None
                end
              else None
            | _ => None
            end
          | None => None
          end
        | None => None
        end
      | None => None
      end
      else None
    | _ => None
    end
    | _ => None
    end
    | _ => None
    end
  | _ => None
  end.

Definition entry_g (run : runT) (srun : srunT) (ge : genv) (P : mem) : option mem :=
  match Genv.find_symbol ge level_update._gMarioStates, sym ge "init_mario_from_save_file",
        sym ge "sCurrentCmd", Genv.find_symbol ge level_script._LevelScriptJumpTable, sym ge "sLevelPool",
        sym ge "sCurrAreaIndex", sym ge "gCurrActNum", Genv.find_symbol ge area._gAreaData,
        sym ge "sPoolFreeSpace", sym ge "sPoolListHeadL", Genv.find_symbol ge L_ENT with
  | Some bm, Some bif, Some bcur, Some btab, Some blp, Some bai, Some bact, Some bgad, Some s3, Some s4,
    Some bent =>
  match run P (Internal audio_external.f_sound_init) [] with
  | Done (_, R1, _) =>
  match Genv.find_funct ge (Vptr bif Ptrofs.zero) with
  | Some fif =>
  match run R1 fif [] with
  | Done (_, R2, _) =>
  (* S1, S2 *)
  match CM.store Mint32 R2 bm 12 (Vint (Int.repr ACT_IDLE_Z)) with
  | Some R3 =>
  match CM.store Mint16signed R3 bact 0 (Vint Int.one) with
  | Some R4 =>
  match run R4 (Internal game_init.f_select_gfx_pool) [] with
  | Done (_, R5, _) =>
  match run_cmds_g run ge bcur btab R5 cmds_head with
  | Some R6 =>
  match CM.load Mint32 R6 blp 0 with
  | Some lpool =>
  match area_g run ge bai bgad lpool R6 with
  | Some R7 =>
  match run_cmds_g run ge bcur btab R7 cmds_area with
  | Some R8 =>
  match free_pool_g run srun ge bcur blp s3 s4 bent R8 with
  | Some R9 =>
  match run_cmds_g run ge bcur btab R9 cmds_tail with
  | Some R10 =>
  (* CALL(0, lvl_init_or_update) = init_level (S6) *)
  match slice_g srun ge level_update.f_init_level 0 7 R10 with
  | Some R11 =>
  match slice_g srun ge level_update.f_warp_level 0 3 R11 with
  | Some R12 => slice_g srun ge level_update.f_init_mario_after_warp 0 8 R12
  | None => None end
  | None => None end
  | None => None end
  | None => None end
  | None => None end
  | None => None end
  | None => None end
  | None => None end
  | Stuck _ _ _ => None end
  | None => None end
  | None => None end
  | Stuck _ _ _ => None end
  | None => None end
  | Stuck _ _ _ => None end
  | _, _, _, _, _, _, _, _, _, _, _ => None
  end.

(* a notation (cf. cam_frame_ok): no constant the kernel would unfold *)
Notation entry ge := (entry_g (ex_call ge world FUEL) (ex_stmt ge world FUEL) ge).

(* the entry, in the semantics: SOME runner and statement runner that
   return only real executions (eval_funcall / exec_stmt) carry the
   chain to P' *)
Definition entry_made (ge : genv) (P P' : mem) : Prop :=
  exists (run : runT) (srun : srunT),
    (forall m f a t m' v, run m f a = Done (t, m', v) -> eval_funcall function_entry2 ge m f a t m' v)
    /\ (forall e le m s t le' m' out, srun e le m s = Done (t, le', m', out) ->
          exec_stmt function_entry2 ge e le m s t le' m' out)
    /\ entry_g run srun ge P = Some P'.

Lemma entry_sound : forall ge P P', world_ok ge -> entry ge P = Some P' -> entry_made ge P P'.
Proof.
  intros ge P P' Wk H. exists (ex_call ge world FUEL), (ex_stmt ge world FUEL).
  split; [ exact (fun m f a t m' v R => ex_call_sound ge world Wk _ _ _ _ _ _ _ R) | ].
  split; [ exact (fun e le m s t le' m' out R => proj1 (ex_sound ge world Wk FUEL) e le m s t le' m' out R) | ].
  exact H.
Qed.

(* ---- the entry keeps every old block's permissions ---- *)
Section KEEP.
Variable run : runT.
Variable srun : srunT.
Hypothesis Rk : forall m f a t m' v, run m f a = Done (t, m', v) -> acc_keep m m'.
Hypothesis Sk : forall e le m s t le' m' out, srun e le m s = Done (t, le', m', out) -> acc_keep m m'.

Lemma run_cmd_g_keep : forall ge bcur btab m c m', run_cmd_g run ge bcur btab m c = Some m' -> acc_keep m m'.
Proof.
  intros ge bcur btab m [s i] m' H. unfold run_cmd_g in H. cbn [fst snd] in H.
  destruct (Genv.find_symbol ge s) as [bs|]; [ | discriminate H ].
  destruct (CM.store Mint32 m bcur 0 _) as [m1|] eqn:S; [ | discriminate H ].
  destruct (CM.load Mint8unsigned m1 bs _) as [[| ty | | | |]|]; try discriminate H.
  destruct (CM.load Mint32 m1 btab _) as [fp|]; [ | discriminate H ].
  destruct (Genv.find_funct ge fp) as [fd|]; [ | discriminate H ].
  destruct (run m1 fd []) as [[[t m2] v]| ? ? ?] eqn:R; [ | discriminate H ].
  injection H as <-. exact (acc_keep_trans _ _ _ (cm_store_keep _ _ _ _ _ _ S) (Rk _ _ _ _ _ _ R)).
Qed.

Lemma run_cmds_g_keep : forall ge bcur btab cs m m', run_cmds_g run ge bcur btab m cs = Some m' -> acc_keep m m'.
Proof.
  intros ge bcur btab cs. induction cs as [| c r IH]; intros m m' H; cbn [run_cmds_g] in H.
  - injection H as <-. apply acc_keep_refl.
  - destruct (run_cmd_g run ge bcur btab m c) as [m1|] eqn:R; [ | discriminate H ].
    exact (acc_keep_trans _ _ _ (run_cmd_g_keep _ _ _ _ _ _ R) (IH _ _ H)).
Qed.

Lemma fold_none : forall e ss, fold_left (stmt_step srun e) ss None = None.
Proof. intros e ss. induction ss as [| s r IH]; [ reflexivity | exact IH ]. Qed.

Lemma stmts_keep : forall e ss le m le' m',
    fold_left (stmt_step srun e) ss (Some (le, m)) = Some (le', m') -> acc_keep m m'.
Proof.
  intros e ss. induction ss as [| s r IH]; intros le m le' m' H; cbn [fold_left] in H.
  - injection H as <- <-. apply acc_keep_refl.
  - destruct (stmt_step srun e (Some (le, m)) s) as [[le1 m1]|] eqn:St;
      [ | rewrite fold_none in H; discriminate H ].
    unfold stmt_step in St.
    destruct (srun e le m s) as [[[[t le2] m2] out]| ? ? ?] eqn:R; [ | discriminate St ].
    destruct out; try discriminate St. injection St as <- <-.
    exact (acc_keep_trans _ _ _ (Sk _ _ _ _ _ _ _ _ R) (IH _ _ _ _ H)).
Qed.

Lemma slice_g_keep : forall ge f lo k m m', slice_g srun ge f lo k m = Some m' -> acc_keep m m'.
Proof.
  intros ge f lo k m m' H. unfold slice_g in H.
  destruct (ev_entry ge f [] m) as [[[e le] m1]|] eqn:En; [ | discriminate H ].
  destruct (fold_left _ _ _) as [[le2 m2]|] eqn:F; [ | discriminate H ].
  injection H as <-.
  exact (acc_keep_trans _ _ _ (proj1 (ev_entry_keep ge _ _ _ _ _ _ En)) (stmts_keep _ _ _ _ _ _ F)).
Qed.

Lemma area_g_keep : forall ge bai bgad lpool m m', area_g run ge bai bgad lpool m = Some m' -> acc_keep m m'.
Proof.
  intros ge bai bgad lpool m m' H. unfold area_g in H.
  destruct (off ge "GraphNodeRoot" "areaIndex"); [ | discriminate H ].
  destruct (off ge "Area" "unk04"); [ | discriminate H ].
  destruct (off ge "Area" "camera"); [ | discriminate H ].
  destruct (run m _ _) as [[[t0 Q1] [| | | | | rb ro]]| ? ? ?] eqn:R0; try discriminate H.
  destruct (Mem.alloc Q1 0 24) as [Q2 sc] eqn:AS.
  destruct (apply_writes Q2 _ 0) as [Q3|] eqn:SW; [ | discriminate H ].
  destruct (run Q3 _ _) as [[[tg Q4] gc]| ? ? ?] eqn:R1; [ | discriminate H ].
  destruct (run Q4 _ _) as [[[tc Q5] vc]| ? ? ?] eqn:R2; [ | discriminate H ].
  destruct (CM.free_list Q5 _) as [Q6|] eqn:F; [ | discriminate H ].
  destruct (CM.loadv Mint32 Q6 _) as [cam|]; [ | discriminate H ].
  destruct (CM.store Mint16signed Q6 _ _ _) as [Q7|] eqn:S7; [ | discriminate H ].
  destruct (CM.store Mint8unsigned Q7 _ _ _) as [Q8|] eqn:S8; [ | discriminate H ].
  destruct (CM.store Mint32 Q8 _ _ _) as [Q9|] eqn:S9; [ | discriminate H ].
  pose proof (Rk _ _ _ _ _ _ R0) as K0.
  pose proof (alloc_keep _ _ _ _ _ AS) as K1.
  pose proof (alloc_keep_new _ _ _ _ _ AS) as Esc.
  pose proof (apply_writes_keep _ _ _ _ SW) as K2.
  pose proof (Rk _ _ _ _ _ _ R1) as K3.
  pose proof (Rk _ _ _ _ _ _ R2) as K4.
  pose proof (acc_keep_trans _ _ _ K0 (acc_keep_trans _ _ _ K1 (acc_keep_trans _ _ _ K2
                (acc_keep_trans _ _ _ K3 K4)))) as K14.
  destruct (cm_free_list_keep [(sc, 0, 24)] Q5 Q6 sc F) as (Nb & Fa).
  { intros b lo hi [E | []]. injection E as <- _ _. apply Ple_refl. }
  assert (K5 : acc_keep m Q6).
  { destruct K14 as (Np & Ap). split; [ rewrite Nb; exact Np | ].
    intros b Hb. rewrite Fa; [ exact (Ap b Hb) | ].
    rewrite Esc. exact (Plt_Ple_trans _ _ _ Hb (proj1 K0)). }
  refine (acc_keep_trans _ _ _ K5 _).
  refine (acc_keep_trans _ _ _ (cm_store_keep _ _ _ _ _ _ S7) _).
  refine (acc_keep_trans _ _ _ (cm_store_keep _ _ _ _ _ _ S8) _).
  refine (acc_keep_trans _ _ _ (cm_store_keep _ _ _ _ _ _ S9) _).
  exact (cm_store_keep _ _ _ _ _ _ H).
Qed.

Lemma free_pool_g_keep : forall ge bcur blp s3 s4 bent m m',
    free_pool_g run srun ge bcur blp s3 s4 bent m = Some m' -> acc_keep m m'.
Proof.
  intros ge bcur blp s3 s4 bent m m' H. unfold free_pool_g in H.
  destruct (CM.load Mint32 m blp 0) as [[| | | | | bp lp]|]; try discriminate H.
  destruct (CM.load Mint32 m bp (Ptrofs.unsigned lp + 4)) as [[| u | | | |]|]; try discriminate H.
  destruct (CM.load Mint32 m s4 0) as [[| | | | | hb hp]|]; try discriminate H.
  destruct (CM.load Mint32 m s3 0) as [[| fs | | | |]|]; try discriminate H.
  destruct (Pos.eqb hb bp && _ && _); [ | discriminate H ].
  destruct (CM.store Mint32 m s4 0 _) as [m1|] eqn:S1; [ | discriminate H ].
  destruct (CM.store Mint32 m1 bp _ _) as [m2|] eqn:S2; [ | discriminate H ].
  destruct (CM.store Mint32 m2 s3 0 _) as [m3|] eqn:S3; [ | discriminate H ].
  destruct (run m3 _ _) as [[[t m4] [| | | | | nb no]]| ? ? ?] eqn:R; try discriminate H.
  destruct (Pos.eqb nb bp && _); [ | discriminate H ].
  destruct (CM.store Mint32 m4 bp _ _) as [m5|] eqn:S5; [ | discriminate H ].
  destruct (CM.store Mint32 m5 bcur 0 _) as [m6|] eqn:S6; [ | discriminate H ].
  refine (acc_keep_trans _ _ _ (cm_store_keep _ _ _ _ _ _ S1) _).
  refine (acc_keep_trans _ _ _ (cm_store_keep _ _ _ _ _ _ S2) _).
  refine (acc_keep_trans _ _ _ (cm_store_keep _ _ _ _ _ _ S3) _).
  refine (acc_keep_trans _ _ _ (Rk _ _ _ _ _ _ R) _).
  refine (acc_keep_trans _ _ _ (cm_store_keep _ _ _ _ _ _ S5) _).
  refine (acc_keep_trans _ _ _ (cm_store_keep _ _ _ _ _ _ S6) _).
  exact (slice_g_keep _ _ _ _ _ _ H).
Qed.

Lemma entry_g_keep : forall ge P P', entry_g run srun ge P = Some P' -> acc_keep P P'.
Proof.
  intros ge P P' H. unfold entry_g in H.
  destruct (Genv.find_symbol ge level_update._gMarioStates) as [bm|]; [ | discriminate H ].
  destruct (sym ge "init_mario_from_save_file") as [bif|]; [ | discriminate H ].
  destruct (sym ge "sCurrentCmd") as [bcur|]; [ | discriminate H ].
  destruct (Genv.find_symbol ge level_script._LevelScriptJumpTable) as [btab|]; [ | discriminate H ].
  destruct (sym ge "sLevelPool") as [blp|]; [ | discriminate H ].
  destruct (sym ge "sCurrAreaIndex") as [bai|]; [ | discriminate H ].
  destruct (sym ge "gCurrActNum") as [bact|]; [ | discriminate H ].
  destruct (Genv.find_symbol ge area._gAreaData) as [bgad|]; [ | discriminate H ].
  destruct (sym ge "sPoolFreeSpace") as [s3|]; [ | discriminate H ].
  destruct (sym ge "sPoolListHeadL") as [s4|]; [ | discriminate H ].
  destruct (Genv.find_symbol ge L_ENT) as [bent|]; [ | discriminate H ].
  destruct (run P _ _) as [[[t1 R1] v1]| ? ? ?] eqn:E1; [ | discriminate H ].
  destruct (Genv.find_funct ge _) as [fif|]; [ | discriminate H ].
  destruct (run R1 fif []) as [[[t2 R2] v2]| ? ? ?] eqn:E2; [ | discriminate H ].
  destruct (CM.store Mint32 R2 bm 12 _) as [R3|] eqn:E3; [ | discriminate H ].
  destruct (CM.store Mint16signed R3 bact 0 _) as [R4|] eqn:E4; [ | discriminate H ].
  destruct (run R4 _ _) as [[[t5 R5] v5]| ? ? ?] eqn:E5; [ | discriminate H ].
  destruct (run_cmds_g run ge bcur btab R5 cmds_head) as [R6|] eqn:E6; [ | discriminate H ].
  destruct (CM.load Mint32 R6 blp 0) as [lpool|]; [ | discriminate H ].
  destruct (area_g run ge bai bgad lpool R6) as [R7|] eqn:E7; [ | discriminate H ].
  destruct (run_cmds_g run ge bcur btab R7 cmds_area) as [R8|] eqn:E8; [ | discriminate H ].
  destruct (free_pool_g run srun ge bcur blp s3 s4 bent R8) as [R9|] eqn:E9; [ | discriminate H ].
  destruct (run_cmds_g run ge bcur btab R9 cmds_tail) as [R10|] eqn:E10; [ | discriminate H ].
  destruct (slice_g srun ge level_update.f_init_level 0 7 R10) as [R11|] eqn:E11; [ | discriminate H ].
  destruct (slice_g srun ge level_update.f_warp_level 0 3 R11) as [R12|] eqn:E12; [ | discriminate H ].
  refine (acc_keep_trans _ _ _ (Rk _ _ _ _ _ _ E1) _).
  refine (acc_keep_trans _ _ _ (Rk _ _ _ _ _ _ E2) _).
  refine (acc_keep_trans _ _ _ (cm_store_keep _ _ _ _ _ _ E3) _).
  refine (acc_keep_trans _ _ _ (cm_store_keep _ _ _ _ _ _ E4) _).
  refine (acc_keep_trans _ _ _ (Rk _ _ _ _ _ _ E5) _).
  refine (acc_keep_trans _ _ _ (run_cmds_g_keep _ _ _ _ _ _ E6) _).
  refine (acc_keep_trans _ _ _ (area_g_keep _ _ _ _ _ _ E7) _).
  refine (acc_keep_trans _ _ _ (run_cmds_g_keep _ _ _ _ _ _ E8) _).
  refine (acc_keep_trans _ _ _ (free_pool_g_keep _ _ _ _ _ _ _ _ E9) _).
  refine (acc_keep_trans _ _ _ (run_cmds_g_keep _ _ _ _ _ _ E10) _).
  refine (acc_keep_trans _ _ _ (slice_g_keep _ _ _ _ _ _ E11) _).
  refine (acc_keep_trans _ _ _ (slice_g_keep _ _ _ _ _ _ E12) _).
  exact (slice_g_keep _ _ _ _ _ _ H).
Qed.
End KEEP.

Lemma entry_keep : forall ge P P', entry ge P = Some P' -> acc_keep P P'.
Proof.
  intros ge P P' H.
  exact (entry_g_keep (ex_call ge world FUEL) (ex_stmt ge world FUEL)
           (fun m f a t m' v R => ex_call_keep _ _ world_keep _ _ _ _ _ _ _ R)
           (fun e le m s t le' m' out R => proj1 (ex_keep _ _ world_keep FUEL) e le m s t le' m' out R) ge P P' H).
Qed.


(* ---- facts checked by vm on a memory: (chunk, block, offset, value) ---- *)
Definition cells_chk (m : mem) (l : list (memory_chunk * block * Z * val)) : bool :=
  forallb (fun c => let '(ch, b, z, v) := c in ld_is (CM.load ch m b z) v) l.

Lemma cells_chk_sound : forall m l, cells_chk m l = true ->
    forall ch b z v, In (ch, b, z, v) l -> Mem.load ch m b z = Some v.
Proof.
  intros m l H ch b z v Hin. unfold cells_chk in H. rewrite forallb_forall in H.
  specialize (H _ Hin). cbv beta iota in H. unfold ld_is in H. rewrite CM.load_eq in H.
  destruct (Mem.load ch m b z) as [x|]; [ | discriminate H ].
  unfold ObjWorld.veqb in H. destruct (Val.eq x v) as [-> | _]; [ reflexivity | discriminate H ].
Qed.

(* Mario's cells after the entry: the real init_mario_from_save_file /
   init_mario / set_mario_initial_action / init_mario_after_warp's, read
   by vm (wall, ceil NULL; the floor find_floor's hit, a static WMotR
   surface in the surface pool, of type SURFACE_NOT_SLIPPERY; the airborne
   warp's object as interactObj / usedObj; position (-67, 2669, -16), the
   warp node's; floorHeight 1669.0, WMotREntry.ENTRY_FH; the area
   &gAreaData[1]; Mario's object's gfx.pos[1] = pos[1]) *)
(* find_floor's hit under the spawn: floorHeight 1669.0 (bits 0x44D0A000) *)
Definition ENTRY_FH_Z : Z := 1669.
Definition ENTRY_FH : float32 := Float32.of_int (Int.repr ENTRY_FH_Z).
Definition FLOOR_AT : Z := 112592.     (* the floor surface, in the pool block *)
Definition WARP_OBJ_OFF : Z := 20064.  (* the airborne warp's object, in gObjectPool *)
Definition FLOOR_TYPE : Z := 21.       (* SURFACE_NOT_SLIPPERY (0x15) *)

Definition bm_cells (bm bo bc ab bsi bpcs bbs bgad bp : block) : list (memory_chunk * block * Z * val) :=
  [ (Mint32, bm, 12, Vint ACT_SPAWN_NO_SPIN_AIRBORNE);
    (Mint16unsigned, bm, 2, Vint Int.zero);
    (Mint16unsigned, bm, 24, Vint Int.zero); (Mint16unsigned, bm, 26, Vint Int.zero);
    (Mfloat32, bm, 64, Vsingle ENTRY_Y); (Mfloat32, bm, 76, Vsingle Float32.zero);
    (Mint32, bm, 96, Vint Int.zero); (Mint32, bm, 100, Vint Int.zero);
    (Mint32, bm, 104, Vptr bp (Ptrofs.repr FLOOR_AT));
    (Mfloat32, bm, 112, Vsingle ENTRY_FH);
    (Mint32, bm, 120, Vptr bo (Ptrofs.repr WARP_OBJ_OFF)); (Mint32, bm, 124, Vint Int.zero);
    (Mint32, bm, 128, Vptr bo (Ptrofs.repr WARP_OBJ_OFF)); (Mint32, bm, 132, Vint Int.zero);
    (Mint32, bm, 136, Vptr bo (Ptrofs.repr MARIO_OFF)); (Mint32, bm, 140, Vptr bsi Ptrofs.zero);
    (Mint32, bm, 144, Vptr bgad (Ptrofs.repr 60)); (Mint32, bm, 148, Vptr bpcs Ptrofs.zero);
    (Mint32, bm, 152, Vptr bbs Ptrofs.zero); (Mint32, bm, 156, Vptr bc Ptrofs.zero);
    (Mint32, bm, 160, Vptr ab Ptrofs.zero); (Mfloat32, bm, 192, Vsingle Float32.zero);
    (Mfloat32, bo, MARIO_OFF + 36, Vsingle ENTRY_Y);
    (Mint16signed, bp, FLOOR_AT, Vint (Int.repr FLOOR_TYPE)) ].

(* the level globals the real entry leaves: sWarpDest.type
   WARP_TYPE_NOT_WARPING (init_mario_after_warp), gCurrentArea =
   &gAreaData[1] (load_area), gCurrLevelNum = LEVEL_WMOTR (warp_level) *)
Definition glob_cells (bw bL bca bgad : block) : list (memory_chunk * block * Z * val) :=
  [ (Mint8unsigned, bw, 0, Vint Int.zero);
    (Mint32, bca, 0, Vptr bgad (Ptrofs.repr 60));
    (Mint16signed, bL, 0, Vint (Int.repr LEVEL_WMOTR)) ].

(* ---------------------------------------------------------------------- *)
(* The chain: the entry stores, the main pool, THE REAL ENTRY, then the    *)
(* stand-ins S7 / S8 (the anim DMA shortcut, gCurrCourseNum, the           *)
(* controller's pad pointer).  Returns e6, the pool block, the entry's     *)
(* result Lm, the DMA buffer and table blocks, and the witness m11.        *)
(* (AudioBoot reads m11 off this same definition.)                         *)
(* ---------------------------------------------------------------------- *)
Definition wit_chain (ge : genv) (m0 : mem) : option (mem * block * mem * block * block * mem) :=
  match Genv.find_symbol ge mario._gControllers, Genv.find_symbol ge mario._gMarioAnimsBuf,
        Genv.find_symbol ge level_update._sWarpDest, Genv.find_symbol ge level_update._gCurrLevelNum,
        Genv.find_symbol ge level_update._gCurrCourseNum, Genv.find_symbol ge game_init._gMarioAnims,
        Genv.find_symbol ge game_init._gControllerPads with
  | Some bc, Some ab, Some bw, Some bL, Some bC, Some bga, Some bpads =>
  match sym ge "sPoolStart", sym ge "sPoolEnd", sym ge "sPoolFreeSpace",
        sym ge "sPoolListHeadL", sym ge "sPoolListHeadR" with
  | Some s1, Some s2, Some s3, Some s4, Some s5 =>
  match e_chain bw bL m0 with
  | Some e6 =>
    let (P0, bp) := Mem.alloc e6 0 POOL in
    match apply_writes P0 (pool_writes s1 s2 s3 s4 s5 bp) 0 with
    | inl P =>
    match entry ge P with
    | Some Lm =>
    (* S7: the DMA table (setup_game_memory's, ROM data: read off the boot
       image's gMarioAnims, srcAddr := &gMarioAnims), the list's dmaTable,
       currentAddr (the animation the first frame sets is the loaded one,
       so that frame DMAs nothing) and bufTarget, and the buffer's zero
       header *)
    let (m1, bt) := Mem.alloc Lm 0 16384 in
    let (m3, bd) := Mem.alloc m1 0 1680 in
    match apply_writes m3 (tab_writes m0 bd bga) 0 with
    | inl z9 =>
    match CM.store Mint32 z9 ab 0 (Vptr bd Ptrofs.zero) with Some z10a =>
    match CM.store Mint32 z10a ab 4 (cur_addr m0 bga) with Some z10 =>
    match CM.store Mint32 z10 ab 8 (Vptr bt Ptrofs.zero) with Some z10b =>
    match CM.store Mint32 z10b bt 0 (Vint Int.zero) with Some z11 =>
    match CM.store Mint32 z11 bt 4 (Vint Int.zero) with Some z12 =>
    match CM.store Mint32 z12 bt 8 (Vint Int.zero) with Some z13 =>
    match CM.store Mint32 z13 bt 12 (Vint Int.zero) with Some z14 =>
    match CM.store Mint32 z14 bt 16 (Vint Int.zero) with Some z15 =>
    match CM.store Mint32 z15 bt 20 (Vint Int.zero) with Some z16 =>
    (* S8: gCurrCourseNum := COURSE_WMOTR, the store the real
       lvl_set_current_level(0, LEVEL_WMOTR) makes (CourseRun.course_runs);
       gControllers[0].controllerData := &gControllerPads[0], the store the
       real init_controllers makes at boot for player 1 (PollFlank reads
       the pad through it) *)
    match CM.store Mint16signed z16 bC 0 (Vint (Int.repr CourseRun.COURSE_WMOTR)) with Some z17 =>
    match CM.store Mint32 z17 bc 24 (Vptr bpads Ptrofs.zero) with Some m11 =>
      Some (e6, bp, Lm, bt, bd, m11)
    | None => None end | None => None end | None => None end | None => None end | None => None end
    | None => None end | None => None end | None => None end | None => None end | None => None end
    | None => None end
    | inr _ => None end
    | None => None end
    | inr _ => None end
  | None => None end
  | _, _, _, _, _ => None end
  | _, _, _, _, _, _, _ => None end.

Definition wchk (ge : genv) (m0 : mem) : bool :=
  match Genv.find_symbol ge level_update._gMarioStates, Genv.find_symbol ge mario._gControllers,
        Genv.find_symbol ge mario._gMarioAnimsBuf, Genv.find_symbol ge object_list_processor._gObjectPool,
        Genv.find_symbol ge level_update._sWarpDest, Genv.find_symbol ge level_update._gCurrLevelNum,
        Genv.find_symbol ge game_init._gMarioAnims,
        Genv.find_symbol ge level_update._gCurrentArea, Genv.find_symbol ge area._gAreaData with
  | Some bm, Some bc, Some ab, Some bo, Some bw, Some bL, Some bga, Some bca, Some bgad =>
  match sym ge "gPlayerSpawnInfos", sym ge "gPlayerCameraState", sym ge "gBodyStates",
        sym ge "gHudDisplay", sym ge "gSurfacesAllocated" with
  | Some bsi, Some bpcs, Some bbs, Some bhud, Some bn =>
  match wit_chain ge m0 with
  | Some (e6, bp, Lm, bt, bd, m11) =>
      old_ok ge bm e6 Lm && frag_ok ge bm bp Lm
      && cells_chk Lm (bm_cells bm bo bc ab bsi bpcs bbs bgad bp)
      && cells_chk m11 (bm_cells bm bo bc ab bsi bpcs bbs bgad bp ++ glob_cells bw bL bca bgad)
      && wff_parts WFUEL ge bp m11
      && parts_ok WFUEL ge m11 && nsurf_ok m11 bn
      && ifs_ok ge m0 bm bc ab bsi bpcs bbs bhud && frame_ok ge bm bo m11
      && tab_chk m11 bd bga && ga_chk m11 bga
      && ObjWorld.ow_chk ge bm m11 && bo_chk m11 bo
      && done_b (ex_call ge BootRun.world FUEL m11 (Internal area.f_area_update_objects) [])
      && match CM.load Mint32 m11 bgad 96 with Some cam => cam_frame_ok ge bgad cam m11 | None => false end
      && dp_chk WFUEL ge m11
      && frame_w ge bm m11
  | None => false
  end
  | _, _, _, _, _ => false end
  | _, _, _, _, _, _, _, _, _ => false end.

Definition wchk_gen (oge : option genv) (oast : option (AST.program (Ctypes.fundef function) type)) : bool :=
  match oge, oast with
  | Some ge, Some ast =>
      match alloc_globals_c (Genv.globalenv ast) Mem.empty (AST.prog_defs ast) with
      | Some m0 => wchk ge m0
      | None => false
      end
  | _, _ => false
  end.

Lemma wchk_gen_true : wchk_gen ge12 ast12 = true.
Proof. vm_cast_no_check (eq_refl true). Qed.

Lemma wchk_lp : forall lp, linked12 lp -> forall m0, Genv.init_mem lp = Some m0 ->
    wchk (globalenv lp) m0 = true.
Proof.
  intros lp H12 m0 Hinit.
  pose proof wchk_gen_true as W. unfold wchk_gen in W.
  rewrite (ge12_ok lp H12), (ast12_ok lp H12) in W.
  rewrite (init_mem_c _ _ Hinit) in W. exact W.
Qed.

(* ---------------------------------------------------------------------- *)
(* The chain, unpacked into memory equations.                              *)
(* ---------------------------------------------------------------------- *)
Inductive wout (ge : genv) (m0 : mem) (bm bc ab bo bw bL : block) : Prop :=
| WOut : forall s1 s2 s3 s4 s5 bn e1 e2 e3 e4 e5 e6 P0 bp P Lm m1 bt m3 bd
                z9 z10a z10 z10b z11 z12 z13 z14 z15 z16 z17 m11
                bsi bpcs bbs bhud bC bga bpads bca bgad camv,
    Mem.store Mint8unsigned m0 bw 0 (Vint (Int.repr 1)) = Some e1 ->
    Mem.store Mint8unsigned e1 bw 1 (Vint (Int.repr LEVEL_WMOTR)) = Some e2 ->
    Mem.store Mint8unsigned e2 bw 2 (Vint (Int.repr WARP_AREA)) = Some e3 ->
    Mem.store Mint8unsigned e3 bw 3 (Vint (Int.repr WARP_NODE)) = Some e4 ->
    Mem.store Mint32 e4 bw 4 (Vint Int.zero) = Some e5 ->
    Mem.store Mint16signed e5 bL 0 (Vint (Int.repr LEVEL_WMOTR)) = Some e6 ->
    Mem.alloc e6 0 POOL = (P0, bp) ->
    apply_writes P0 (pool_writes s1 s2 s3 s4 s5 bp) 0 = inl P ->
    sym ge "sPoolStart" = Some s1 -> sym ge "sPoolEnd" = Some s2 -> sym ge "sPoolFreeSpace" = Some s3 ->
    sym ge "sPoolListHeadL" = Some s4 -> sym ge "sPoolListHeadR" = Some s5 ->
    entry ge P = Some Lm ->
    Mem.alloc Lm 0 16384 = (m1, bt) -> Mem.alloc m1 0 1680 = (m3, bd) ->
    apply_writes m3 (tab_writes m0 bd bga) 0 = inl z9 ->
    Mem.store Mint32 z9 ab 0 (Vptr bd Ptrofs.zero) = Some z10a ->
    Mem.store Mint32 z10a ab 4 (cur_addr m0 bga) = Some z10 ->
    Mem.store Mint32 z10 ab 8 (Vptr bt Ptrofs.zero) = Some z10b ->
    Mem.store Mint32 z10b bt 0 (Vint Int.zero) = Some z11 ->
    Mem.store Mint32 z11 bt 4 (Vint Int.zero) = Some z12 ->
    Mem.store Mint32 z12 bt 8 (Vint Int.zero) = Some z13 ->
    Mem.store Mint32 z13 bt 12 (Vint Int.zero) = Some z14 ->
    Mem.store Mint32 z14 bt 16 (Vint Int.zero) = Some z15 ->
    Mem.store Mint32 z15 bt 20 (Vint Int.zero) = Some z16 ->
    Mem.store Mint16signed z16 bC 0 (Vint (Int.repr CourseRun.COURSE_WMOTR)) = Some z17 ->
    Mem.store Mint32 z17 bc 24 (Vptr bpads Ptrofs.zero) = Some m11 ->
    sym ge "gPlayerSpawnInfos" = Some bsi -> sym ge "gPlayerCameraState" = Some bpcs ->
    sym ge "gBodyStates" = Some bbs -> sym ge "gHudDisplay" = Some bhud ->
    Genv.find_symbol ge level_update._gCurrCourseNum = Some bC ->
    Genv.find_symbol ge game_init._gMarioAnims = Some bga ->
    Genv.find_symbol ge game_init._gControllerPads = Some bpads ->
    Genv.find_symbol ge level_update._gCurrentArea = Some bca ->
    Genv.find_symbol ge area._gAreaData = Some bgad ->
    sym ge "gSurfacesAllocated" = Some bn ->
    old_ok ge bm e6 Lm = true -> frag_ok ge bm bp Lm = true ->
    cells_chk Lm (bm_cells bm bo bc ab bsi bpcs bbs bgad bp) = true ->
    cells_chk m11 (bm_cells bm bo bc ab bsi bpcs bbs bgad bp ++ glob_cells bw bL bca bgad) = true ->
    wff_parts WFUEL ge bp m11 = true ->
    parts_ok WFUEL ge m11 = true -> nsurf_ok m11 bn = true ->
    ifs_ok ge m0 bm bc ab bsi bpcs bbs bhud = true -> frame_ok ge bm bo m11 = true ->
    tab_chk m11 bd bga = true -> ga_chk m11 bga = true ->
    ObjWorld.ow_chk ge bm m11 = true -> bo_chk m11 bo = true ->
    done_b (ex_call ge BootRun.world FUEL m11 (Internal area.f_area_update_objects) []) = true ->
    Mem.load Mint32 m11 bgad 96 = Some camv ->
    cam_frame_ok ge bgad camv m11 = true ->
    dp_chk WFUEL ge m11 = true ->
    frame_w ge bm m11 = true ->
    wout ge m0 bm bc ab bo bw bL.

Lemma wchk_sound : forall ge m0, wchk ge m0 = true ->
    forall bm bc ab bo bw bL,
      Genv.find_symbol ge level_update._gMarioStates = Some bm ->
      Genv.find_symbol ge mario._gControllers = Some bc ->
      Genv.find_symbol ge mario._gMarioAnimsBuf = Some ab ->
      Genv.find_symbol ge object_list_processor._gObjectPool = Some bo ->
      Genv.find_symbol ge level_update._sWarpDest = Some bw ->
      Genv.find_symbol ge level_update._gCurrLevelNum = Some bL ->
      wout ge m0 bm bc ab bo bw bL.
Proof.
  intros ge m0 W bm bc ab bo bw bL Hbm Hbc Hab Hbo Hbw HbL.
  unfold wchk in W. rewrite Hbm, Hbc, Hab, Hbo, Hbw, HbL in W.
  destruct (Genv.find_symbol ge game_init._gMarioAnims) as [bga|] eqn:Hga; [ | discriminate ].
  destruct (Genv.find_symbol ge level_update._gCurrentArea) as [bca|] eqn:Hca; [ | discriminate ].
  destruct (Genv.find_symbol ge area._gAreaData) as [bgad|] eqn:Hgad; [ | discriminate ].
  destruct (sym ge "gPlayerSpawnInfos") as [bsi|] eqn:Hsi; [ | discriminate ].
  destruct (sym ge "gPlayerCameraState") as [bpcs|] eqn:Hpcs; [ | discriminate ].
  destruct (sym ge "gBodyStates") as [bbs|] eqn:Hbs; [ | discriminate ].
  destruct (sym ge "gHudDisplay") as [bhud|] eqn:Hhud; [ | discriminate ].
  destruct (sym ge "gSurfacesAllocated") as [bn|] eqn:Hbn; [ | discriminate ].
  destruct (wit_chain ge m0) as [[[[[[e6 bp] Lm] bt] bd] m11]|] eqn:WC; [ | discriminate ].
  unfold wit_chain in WC. rewrite Hbc, Hab, Hbw, HbL, Hga in WC.
  destruct (Genv.find_symbol ge level_update._gCurrCourseNum) as [bC|] eqn:HcC; [ | discriminate ].
  destruct (Genv.find_symbol ge game_init._gControllerPads) as [bpads|] eqn:Hpads; [ | discriminate ].
  destruct (sym ge "sPoolStart") as [s1|] eqn:Hs1; [ | discriminate ].
  destruct (sym ge "sPoolEnd") as [s2|] eqn:Hs2; [ | discriminate ].
  destruct (sym ge "sPoolFreeSpace") as [s3|] eqn:Hs3; [ | discriminate ].
  destruct (sym ge "sPoolListHeadL") as [s4|] eqn:Hs4; [ | discriminate ].
  destruct (sym ge "sPoolListHeadR") as [s5|] eqn:Hs5; [ | discriminate ].
  destruct (e_chain bw bL m0) as [e6'|] eqn:Ec; [ | discriminate ].
  unfold e_chain in Ec.
  destruct (CM.store Mint8unsigned m0 bw 0 _) as [e1|] eqn:E1; [ | discriminate ].
  destruct (CM.store Mint8unsigned e1 bw 1 _) as [e2|] eqn:E2; [ | discriminate ].
  destruct (CM.store Mint8unsigned e2 bw 2 _) as [e3|] eqn:E3; [ | discriminate ].
  destruct (CM.store Mint8unsigned e3 bw 3 _) as [e4|] eqn:E4; [ | discriminate ].
  destruct (CM.store Mint32 e4 bw 4 _) as [e5|] eqn:E5; [ | discriminate ].
  rename Ec into E6.
  destruct (Mem.alloc e6' 0 POOL) as [P0 bp'] eqn:AP.
  destruct (apply_writes P0 _ 0) as [P|] eqn:PW; [ | discriminate ].
  destruct (entry_g _ _ _ P) as [Lm'|] eqn:EN; [ | discriminate ].
  destruct (Mem.alloc Lm' 0 16384) as [m1 bt'] eqn:A1.
  destruct (Mem.alloc m1 0 1680) as [m3 bd'] eqn:A4.
  destruct (apply_writes m3 _ 0) as [z9|] eqn:Z9; [ | discriminate ].
  destruct (CM.store Mint32 z9 ab 0 _) as [z10a|] eqn:Z10a; [ | discriminate ].
  destruct (CM.store Mint32 z10a ab 4 _) as [z10|] eqn:Z10; [ | discriminate ].
  destruct (CM.store Mint32 z10 ab 8 _) as [z10b|] eqn:Z10b; [ | discriminate ].
  destruct (CM.store Mint32 z10b bt' 0 _) as [z11|] eqn:Z11; [ | discriminate ].
  destruct (CM.store Mint32 z11 bt' 4 _) as [z12|] eqn:Z12; [ | discriminate ].
  destruct (CM.store Mint32 z12 bt' 8 _) as [z13|] eqn:Z13; [ | discriminate ].
  destruct (CM.store Mint32 z13 bt' 12 _) as [z14|] eqn:Z14; [ | discriminate ].
  destruct (CM.store Mint32 z14 bt' 16 _) as [z15|] eqn:Z15; [ | discriminate ].
  destruct (CM.store Mint32 z15 bt' 20 _) as [z16|] eqn:Z16; [ | discriminate ].
  destruct (CM.store Mint16signed z16 bC 0 _) as [z17|] eqn:Z17; [ | discriminate ].
  destruct (CM.store Mint32 z17 bc 24 _) as [m11'|] eqn:ZC; [ | discriminate ].
  injection WC as <- <- <- <- <- <-.
  repeat match goal with H : CM.store _ _ _ _ _ = Some _ |- _ => rewrite CM.store_eq in H end.
  apply andb_prop in W as [W N17]. apply andb_prop in W as [W N16].
  apply andb_prop in W as [W N15]. apply andb_prop in W as [W N14].
  apply andb_prop in W as [W N13]. apply andb_prop in W as [W N12].
  apply andb_prop in W as [W N11]. apply andb_prop in W as [W N10].
  apply andb_prop in W as [W N9]. apply andb_prop in W as [W N8].
  apply andb_prop in W as [W N7]. apply andb_prop in W as [W N6].
  apply andb_prop in W as [W N5]. apply andb_prop in W as [W N4].
  apply andb_prop in W as [W N3]. apply andb_prop in W as [N1 N2].
  rewrite CM.load_eq in N15.
  destruct (Mem.load Mint32 m11' bgad 96) as [camv|] eqn:LC; [ | discriminate N15 ].
  eapply WOut;
    [ exact E1 | exact E2 | exact E3 | exact E4 | exact E5 | exact E6 | exact AP
    | exact PW | exact Hs1 | exact Hs2 | exact Hs3 | exact Hs4 | exact Hs5 | exact EN
    | exact A1 | exact A4 | exact Z9 | exact Z10a | exact Z10 | exact Z10b
    | exact Z11 | exact Z12 | exact Z13 | exact Z14 | exact Z15 | exact Z16 | exact Z17 | exact ZC
    | exact Hsi | exact Hpcs | exact Hbs | exact Hhud | exact HcC | exact Hga | exact Hpads | exact Hca | exact Hgad
    | exact Hbn
    | exact N1 | exact N2 | exact N3 | exact N4 | exact N5 | exact N6 | exact N7 | exact N8 | exact N9
    | exact N10 | exact N11 | exact N12 | exact N13 | exact N14 | exact LC | exact N15 | exact N16 | exact N17 ].
Qed.

(* ifs_ok, in the semantics: the run of the function the link resolves
   init_mario_from_save_file to, from m0, ends in a memory with m0's
   nextblock whose every old block holds exactly the bytes of m0 after
   ifs_writes *)
Lemma same_blocks_sound : forall m1 m2 n b, same_blocks m1 m2 n b = true ->
    forall b', Ple b b' -> (Pos.to_nat b' < Pos.to_nat b + n)%nat ->
    forall o, ZMap.get o ((Mem.mem_contents m1) !! b') = ZMap.get o ((Mem.mem_contents m2) !! b').
Proof.
  induction n as [| n IH]; intros b H b' Hle Hlt o;
    [ unfold Ple in Hle; apply Pos2Nat.inj_le in Hle; lia | ].
  cbn in H. apply andb_prop in H as [Hb Hr].
  destruct (Pos.eq_dec b b') as [<- | Hne]; [ exact (blk_eqb_get _ _ Hb o) | ].
  apply (IH (Pos.succ b) Hr).
  - unfold Ple in *. apply Pos.le_succ_l. apply Pos.le_lteq in Hle as [Hl | E]; [ exact Hl | congruence ].
  - rewrite Pos2Nat.inj_succ. lia.
Qed.

Lemma ifs_ok_sound : forall ge m0 bm bc ab bsi bpcs bbs bhud,
    BootRun.world_ok ge -> ifs_ok ge m0 bm bc ab bsi bpcs bbs bhud = true ->
    exists bi fi t mi v mx,
      sym ge "init_mario_from_save_file" = Some bi
      /\ Genv.find_funct ge (Vptr bi Ptrofs.zero) = Some fi
      /\ eval_funcall function_entry2 ge m0 fi [] t mi v
      /\ apply_writes m0 (ifs_writes bm bc ab bsi bpcs bbs bhud) 0 = inl mx
      /\ Mem.nextblock mi = Mem.nextblock m0
      /\ forall b o, Plt b (Mem.nextblock m0) ->
           ZMap.get o ((Mem.mem_contents mi) !! b) = ZMap.get o ((Mem.mem_contents mx) !! b).
Proof.
  intros ge m0 bm bc ab bsi bpcs bbs bhud Wk H. unfold ifs_ok in H.
  destruct (sym ge "init_mario_from_save_file") as [bi|] eqn:Hbi; [ | discriminate ].
  destruct (Genv.find_funct ge (Vptr bi Ptrofs.zero)) as [fi|] eqn:Hfi; [ | discriminate ].
  destruct (ex_call ge BootRun.world FUEL m0 fi []) as [[[t mi] v]| ? ? ?] eqn:R; [ | discriminate ].
  destruct (apply_writes m0 _ 0) as [mx|] eqn:Ax; [ | discriminate ].
  apply andb_prop in H as [Hn Hs]. apply Pos.eqb_eq in Hn.
  exists bi, fi, t, mi, v, mx.
  split; [ first [ exact Hbi | reflexivity ] | ]. split; [ first [ exact Hfi | reflexivity ] | ].
  split; [ exact (ex_call_sound ge BootRun.world Wk _ _ _ _ _ _ _ R) | ].
  split; [ first [ exact Ax | reflexivity ] | ]. split; [ exact Hn | ].
  intros b o Hb. apply (same_blocks_sound _ _ _ _ Hs); [ unfold Ple; apply Pos.le_1_l | ].
  unfold Plt in Hb. apply Pos2Nat.inj_lt in Hb. cbn [Pos.to_nat Pos.iter_op]. lia.
Qed.

(* frame_ok, in the semantics *)
Lemma frame_ok_sound : forall ge bm bo m, BootRun.world_ok ge -> frame_ok ge bm bo m = true ->
    AGates.a_pressed_real bm m = false
    /\ exists t m' v, eval_funcall function_entry2 ge m (Internal mario.f_execute_mario_action)
                        [Vptr bo (Ptrofs.repr MARIO_OFF)] t m' v
       /\ Mem.load Mint32 m' bm 12 = Some (Vint (Int.repr BootRun.ACT_SPAWN_NO_SPIN_AIRBORNE)).
Proof.
  intros ge bm bo m Wk H. unfold frame_ok in H. apply andb_prop in H as [Ha H].
  split; [ exact (BootRun.nab _ _ Ha) | ].
  destruct (ex_call ge BootRun.world FUEL m _ _) as [[[t m'] v]| ? ? ?] eqn:R; [ | discriminate ].
  exists t, m', v. split; [ exact (ex_call_sound ge BootRun.world Wk _ _ _ _ _ _ _ R) | ].
  exact (BootRun.ld32_is_sound _ _ _ _ H).
Qed.

(* done_b, in the semantics *)
Lemma ex_done_sound : forall ge f args m, BootRun.world_ok ge ->
    done_b (ex_call ge BootRun.world FUEL m f args) = true ->
    exists t m' v, eval_funcall function_entry2 ge m f args t m' v.
Proof.
  intros ge f args m Wk H.
  destruct (ex_call ge BootRun.world FUEL m f args) as [[[t m'] v]| ? ? ?] eqn:R; [ | discriminate H ].
  exists t, m', v. exact (ex_call_sound ge BootRun.world Wk _ _ _ _ _ _ _ R).
Qed.

Lemma cam_frame_g_sound : forall (ge : genv) (run : runT) cutp bgad cam m,
    (forall m f a t m' v, run m f a = Done (t, m', v) -> eval_funcall function_entry2 ge m f a t m' v) ->
    cam_frame_g run cutp bgad cam m = true ->
    Mem.load Mint32 m bgad 96 = Some cam
    /\ exists t m' v, eval_funcall function_entry2 ge m (Internal area.f_area_update_objects) [] t m' v
       /\ exists t2 m2 v2, eval_funcall function_entry2 ge m' (Internal camera.f_update_camera) [cam] t2 m2 v2.
Proof.
  intros ge run cutp bgad cam m Rs H. unfold cam_frame_g in H. apply andb_prop in H as [_ H].
  rewrite CM.load_eq in H.
  destruct (Mem.load Mint32 m bgad 96) as [v0|]; [ | discriminate ].
  apply andb_prop in H as [He H].
  destruct (Val.eq v0 cam) as [<- | _]; [ | discriminate ].
  split; [ reflexivity | ].
  destruct (run m _ _) as [[[t m'] v]| ? ? ?] eqn:R; [ | discriminate ].
  destruct (run m' _ _) as [[[t2 m2] v2]| ? ? ?] eqn:R2; [ | discriminate ].
  exists t, m', v. split; [ exact (Rs _ _ _ _ _ _ R) | ].
  exists t2, m2, v2. exact (Rs _ _ _ _ _ _ R2).
Qed.

(* cam_frame_ok, in the semantics *)
Lemma cam_frame_ok_sound : forall ge bgad cam m, BootRun.world_ok ge ->
    cam_frame_ok ge bgad cam m = true ->
    Mem.load Mint32 m bgad 96 = Some cam
    /\ exists t m' v, eval_funcall function_entry2 ge m (Internal area.f_area_update_objects) [] t m' v
       /\ exists t2 m2 v2, eval_funcall function_entry2 ge m' (Internal camera.f_update_camera) [cam] t2 m2 v2.
Proof.
  intros ge bgad cam m Wk H.
  exact (cam_frame_g_sound ge (ex_call ge BootRun.world FUEL) _ bgad cam m (fun m f a t m' v R => ex_call_sound ge BootRun.world Wk _ _ _ _ _ _ _ R) H).
Qed.

(* ... and its cutscene cells *)
Lemma cam_frame_ok_cut : forall ge bgad cam m, cam_frame_ok ge bgad cam m = true -> cut_chk ge cam m = true.
Proof. intros ge bgad cam m H. unfold cam_frame_g in H. apply andb_prop in H as [H _]. exact H. Qed.

(* ... and the Camera cell it checked (no run needed) *)
Lemma cam_frame_ok_load : forall ge bgad cam m, cam_frame_ok ge bgad cam m = true ->
  Mem.load Mint32 m bgad 96 = Some cam.
Proof.
  intros ge bgad cam m H. unfold cam_frame_g in H. apply andb_prop in H as [_ H].
  rewrite CM.load_eq in H.
  destruct (Mem.load Mint32 m bgad 96) as [v0|]; [ | discriminate ].
  apply andb_prop in H as [He _].
  destruct (Val.eq v0 cam) as [<- | _]; [ reflexivity | discriminate ].
Qed.

Lemma nsurf_ok_sound : forall m bn, nsurf_ok m bn = true ->
    exists n, Mem.load Mint32 m bn 0 = Some (Vint n) /\ Int.signed n = NSURF.
Proof.
  intros m bn H. unfold nsurf_ok in H. rewrite CM.load_eq in H.
  destruct (Mem.load Mint32 m bn 0) as [[| n | | | |]|]; try discriminate.
  apply Z.eqb_eq in H. exists n. split; [ reflexivity | exact H ].
Qed.

(* ---------------------------------------------------------------------- *)
(* The two partitions are the definer's 6144 bytes in every 34-TU link.    *)
(* ---------------------------------------------------------------------- *)
Definition part_sizes_ok (oast : option (AST.program (Ctypes.fundef function) type)) : bool :=
  match oast with
  | Some ast =>
      forallb (fun pid => match (prog_defmap ast) ! pid with
                          | Some (Gvar v) => Z.eqb (init_data_list_size (gvar_init v)) 6144
                          | _ => false
                          end) part_ids
  | None => false
  end.

Lemma part_sizes_true : part_sizes_ok ast12 = true.
Proof. vm_compute. reflexivity. Qed.

Lemma part_def : forall lp, linked12 lp -> forall pid, In pid part_ids ->
    exists v, (prog_defmap lp) ! pid = Some (Gvar v) /\ init_data_list_size (gvar_init v) = 6144.
Proof.
  intros lp H12 pid Hin. pose proof part_sizes_true as P. rewrite (ast12_ok lp H12) in P.
  cbn [part_sizes_ok] in P. rewrite forallb_forall in P. specialize (P pid Hin).
  change (prog_defmap (program_of_program lp)) with (prog_defmap lp) in P.
  destruct ((prog_defmap lp) ! pid) as [[f | v]|]; try discriminate P.
  apply Z.eqb_eq in P. exists v. split; [ reflexivity | exact P ].
Qed.

(* every permission on a partition block of the boot image lies inside its
   6144 bytes *)
Lemma part_bound : forall lp, linked12 lp -> forall m, Genv.init_mem lp = Some m ->
    forall pid pb, In pid part_ids -> Genv.find_symbol (Genv.globalenv lp) pid = Some pb ->
    forall z k p, Mem.perm m pb z k p -> 0 <= z < 6144.
Proof.
  intros lp H12 m Hinit pid pb Hin Hs z k p Hp.
  destruct (part_def lp H12 pid Hin) as (v & Hd & Hsz).
  apply Genv.find_def_symbol in Hd as (b' & Hs' & Hfd).
  rewrite Hs in Hs'. injection Hs' as <-.
  assert (Hv : Genv.find_var_info (Genv.globalenv lp) pb = Some v)
    by (rewrite Genv.find_var_info_iff; exact Hfd).
  pose proof (Genv.init_mem_characterization _ _ Hv Hinit) as (_ & B & _).
  rewrite <- Hsz. exact (proj1 (B _ _ _ Hp)).
Qed.

(* ---------------------------------------------------------------------- *)
(* Small frame facts.                                                       *)
(* ---------------------------------------------------------------------- *)
Lemma store_keep : forall ch m b z v m', Mem.store ch m b z v = Some m' -> acc_keep m m'.
Proof. intros ch m b z v m' H. rewrite <- CM.store_eq in H. exact (cm_store_keep _ _ _ _ _ _ H). Qed.

Section TR_PTR64.
Local Transparent Archi.ptr64.
Lemma Mptr32 : Mptr = Mint32.
Proof. reflexivity. Qed.
End TR_PTR64.

(* the globals MWF_real's rows read (MWFReal.MWF_real_transfer's list):
   none is an f_ids global.  (gCameraMovementFlags, a stored global, IS
   written: reset_camera; MWF reads no row of it.  gMarioStates IS written
   by the entry: old_ok exempts it by name and StartSat re-proves its rows
   from the cells the entry left.) *)
Definition mwf_row_ids : list ident :=
  [ level_update._gMarioStates; mario._gControllers; mario._gMarioState;
    interaction._gGlobalTimer; interaction._sInteractionHandlers; mario._gMarioAnimsBuf ]
  ++ MWFReal.knockback_table_ids.

Lemma nonsafe_F : forallb (fun i => negb (mem_id i mwf_row_ids)) f_ids = true.
Proof. vm_compute. reflexivity. Qed.

Lemma nonsafe_notF : forall gid, mem_id gid mwf_row_ids = true -> mem_id gid f_ids = false.
Proof.
  intros gid H. apply not_true_iff_false. intro E.
  unfold mem_id in E. apply existsb_exists in E as (i & Hin & Hi). apply Pos.eqb_eq in Hi. subst i.
  pose proof nonsafe_F as F. rewrite forallb_forall in F. specialize (F gid Hin).
  rewrite H in F. discriminate.
Qed.

(* a pointer target the check accepted is the pool block or a SafeB symbol *)
Lemma safe_tgt_sym : forall (ge : genv) bp nb t, safe_tgt ge bp nb t = true ->
    t = bp \/ exists i, mem_id i non_safeb_syms = false /\ Genv.find_symbol ge i = Some t.
Proof.
  intros ge bp nb t H. unfold safe_tgt in H. apply andb_prop in H as [_ H].
  apply orb_prop in H as [H | H]; [ left; apply Pos.eqb_eq; exact H | right ].
  destruct (Genv.invert_symbol ge t) as [i|] eqn:Hi; [ | discriminate ].
  exists i. split; [ apply negb_true_iff; exact H | exact (Genv.invert_find_symbol _ _ Hi) ].
Qed.

(* ---------------------------------------------------------------------- *)
(* The loaded memory stays closed under the flat injection.                *)
(* ---------------------------------------------------------------------- *)
Lemma mv_inject_self : forall thr mv,
    (forall b' o' q n, mv = Fragment (Vptr b' o') q n -> Plt b' thr) ->
    memval_inject (Mem.flat_inj thr) mv mv.
Proof.
  intros thr [| x | v q n] H; constructor.
  destruct v; try (constructor; fail).
  apply (Val.inject_ptr _ b i b i 0); [ | rewrite Ptrofs.add_zero; reflexivity ].
  unfold Mem.flat_inj. destruct (plt b thr) as [_ | N]; [ reflexivity | ].
  exfalso. exact (N (H b i q n eq_refl)).
Qed.

Lemma neutral_frame : forall (ge : genv) thr e L bm bp,
    Mem.inject_neutral thr e -> Ple (Mem.nextblock L) thr ->
    acc_keep e L -> bp = Mem.nextblock e ->
    old_ok ge bm e L = true -> frag_ok ge bm bp L = true ->
    Mem.inject_neutral thr L.
Proof.
  intros ge thr e L bm bp N Hle [_ Ha] Hbp O F.
  pose proof (old_ok_sound _ _ _ _ O) as Oc. destruct (frag_ok_sound _ _ _ _ F) as (F1 & F2 & F3).
  assert (MV : forall b o, Mem.perm L b o Cur Readable ->
             memval_inject (Mem.flat_inj thr) (ZMap.get o ((Mem.mem_contents L) !! b))
                                              (ZMap.get o ((Mem.mem_contents L) !! b))).
  { intros b o Hp.
    assert (Vb : Plt b (Mem.nextblock L)) by exact (Mem.perm_valid_block _ _ _ _ _ Hp).
    assert (FR : forall ok, (forall t, ok t = true -> Plt t (Mem.nextblock L)) ->
                   mv_ok ok (ZMap.get o ((Mem.mem_contents L) !! b)) = true ->
                   memval_inject (Mem.flat_inj thr) (ZMap.get o ((Mem.mem_contents L) !! b))
                                                    (ZMap.get o ((Mem.mem_contents L) !! b))).
    { intros ok Hok Hmv. apply mv_inject_self. intros b' o' q n E. rewrite E in Hmv.
      cbn in Hmv. exact (Plt_Ple_trans _ _ _ (Hok _ Hmv) Hle). }
    destruct (plt b (Mem.nextblock e)) as [Hlt | Hge].
    - destruct (inFb ge b) eqn:Fb.
      + apply (FR _ (safe_tgt_lt ge bp (Mem.nextblock L))). exact (F1 b o (or_introl Fb)).
      + destruct (peq b bm) as [-> | Hnm].
        * apply (FR _ (lt_tgt_lt (Mem.nextblock L))). exact (F3 o).
        * rewrite (Oc b o Hlt Fb Hnm).
          assert (Hp' : Mem.perm e b o Cur Readable)
            by (unfold Mem.perm in *; rewrite <- (Ha b Hlt); exact Hp).
          assert (Hf : Mem.flat_inj thr b = Some (b, 0)).
          { unfold Mem.flat_inj. destruct (plt b thr) as [_ | NN]; [ reflexivity | ].
            exfalso. apply NN. exact (Plt_Ple_trans _ _ _ Vb Hle). }
          pose proof (Mem.mi_memval _ _ _ N b o b 0 Hf Hp') as R.
          rewrite Z.add_0_r in R. exact R.
    - destruct (peq b bp) as [-> | Hne].
      + apply (FR _ (safe_tgt_lt ge bp (Mem.nextblock L))). exact (F1 bp o (or_intror eq_refl)).
      + apply (FR _ (lt_tgt_lt (Mem.nextblock L))). apply F2; [ | exact Vb ].
        subst bp. unfold Plt in *. apply Pos.le_nlt in Hge.
        apply Pos.le_lteq in Hge as [Hl | E]; [ exact Hl | congruence ]. }
  constructor.
  - intros b1 b2 delta ofs k p Hf Hp. unfold Mem.flat_inj in Hf.
    destruct (plt b1 thr); [ injection Hf as <- <- | discriminate ].
    rewrite Z.add_0_r. exact Hp.
  - intros b1 b2 delta chunk ofs p Hf _. unfold Mem.flat_inj in Hf.
    destruct (plt b1 thr); [ injection Hf as <- <- | discriminate ]. apply Z.divide_0_r.
  - intros b1 ofs b2 delta Hf Hp. unfold Mem.flat_inj in Hf.
    destruct (plt b1 thr); [ injection Hf as <- <- | discriminate ].
    rewrite Z.add_0_r. exact (MV b1 ofs Hp).
Qed.
