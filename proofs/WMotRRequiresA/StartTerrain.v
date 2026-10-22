(* spine: the GOAL-2 start witness's terrain -- the real loader run on the
   init_mem-based witness memory, with the frame facts StartSat needs. *)
(* ====================================================================== *)
(* StartTerrain (GOAL 2): load WMotR's real terrain into StartSat's        *)
(* witness, in the real boot order.                                        *)
(*                                                                          *)
(* The chain, computed once by vm_compute over every 34-TU link, from the  *)
(* link's real boot image (Genv.init_mem, computed by InitMemC.init_mem_c, *)
(* read-only and function permissions included):                           *)
(*   1. initiate_warp(LEVEL_WMOTR, 1, 0x0A, 0)'s sWarpDest stores and      *)
(*      warp_level's gCurrLevelNum store (EntryWarp: real code);           *)
(*   2. the main pool as one fresh block in main_pool_init's post-state    *)
(*      (TRUST 3.6; main_pool_init has no CompCert execution);             *)
(*   3. the generated alloc_surface_pools, then load_area_terrain(1,       *)
(*      wmotr_seg7_collision, NULL, NULL), run by the sound interpreter    *)
(*      (TerrainRun.world answers sqrtf and reset_red_coins_collected);    *)
(*   4. init_mario's cells (StartSat's three fresh blocks, eight stores).  *)
(* That is the real order: warp_level, then the level script (its          *)
(* FREE_LEVEL_POOL command calls alloc_surface_pools, LOAD_AREA's load_area *)
(* calls load_area_terrain), then init_mario.  (In the game main_pool_init  *)
(* runs once at boot, before the warp; the pool block is disjoint from     *)
(* every cell the warp writes, so placing it after the warp changes no     *)
(* load.)                                                                    *)
(*                                                                          *)
(* The checks on the result (all by vm_compute, each with a soundness      *)
(* lemma here):                                                             *)
(*   - FOOTPRINT: every block valid before the run that is not one of the  *)
(*     globals f_ids holds the same bytes after it (old_ok); with          *)
(*     InterpFrame.ex_keep (old blocks keep their permissions), every such *)
(*     block has the same loads;                                           *)
(*   - POINTERS: every pointer stored in an f_ids block or in the pool      *)
(*     block aims at the pool block or at a SafeB symbol, and every        *)
(*     pointer left in a freed stack frame at a valid block (frag_ok);     *)
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
  surface_collision.
Import ListNotations.
Module CM := SM64.Proofs.Interp.CMem.
Arguments Done {A}.
Arguments Stuck {A}.

Local Open Scope string_scope.
Local Open Scope Z_scope.

(* ---------------------------------------------------------------------- *)
(* The globals the pool init and the loader may write.                     *)
(* ---------------------------------------------------------------------- *)
(* (read off the run: exactly the old blocks whose bytes differ afterwards;
   old_ok re-checks it) *)
Definition f_ids : list ident :=
  [ id "sPoolStart"; id "sPoolEnd"; id "sPoolFreeSpace"; id "sPoolListHeadL"; id "sPoolListHeadR";
    id "sSurfaceNodePool"; id "sSurfacePool"; id "sSurfacePoolSize";
    id "gSurfacesAllocated"; id "gSurfaceNodesAllocated";
    id "gNumStaticSurfaces"; id "gNumStaticSurfaceNodes";
    id "gStaticSurfacePartition"; id "gMacroObjectDefaultParent" ].

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
(* FOOTPRINT: old blocks outside f_ids keep their bytes.                   *)
(* ---------------------------------------------------------------------- *)
Definition old_ok (ge : genv) (e L : mem) : bool :=
  range_ok (fun b => inFb ge b || blk_eqb ((Mem.mem_contents L) !! b) ((Mem.mem_contents e) !! b))
    (Pos.to_nat (Mem.nextblock e) - 1) 1.

Lemma old_ok_sound : forall ge e L, old_ok ge e L = true ->
    forall b o, Plt b (Mem.nextblock e) -> inFb ge b = false ->
      ZMap.get o ((Mem.mem_contents L) !! b) = ZMap.get o ((Mem.mem_contents e) !! b).
Proof.
  intros ge e L H b o Hb Hf.
  assert (R : inFb ge b || blk_eqb ((Mem.mem_contents L) !! b) ((Mem.mem_contents e) !! b) = true).
  { apply (range_ok_spec _ _ _ H); [ unfold Ple; apply Pos.le_1_l | ].
    unfold Plt in Hb. apply Pos2Nat.inj_lt in Hb. cbn [Pos.to_nat Pos.iter_op]. lia. }
  rewrite Hf in R. exact (blk_eqb_get _ _ R o).
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

Definition frag_ok (ge : genv) (bp : block) (L : mem) : bool :=
  forallb (fun b => blk_ptrs (safe_tgt ge bp (Mem.nextblock L)) ((Mem.mem_contents L) !! b))
    (bp :: fblks ge)
  && range_ok (fun b => blk_ptrs (lt_tgt (Mem.nextblock L)) ((Mem.mem_contents L) !! b))
       (Pos.to_nat (Mem.nextblock L) - Pos.to_nat (Pos.succ bp)) (Pos.succ bp).

Lemma frag_ok_sound : forall ge bp L, frag_ok ge bp L = true ->
    (forall b o, inFb ge b = true \/ b = bp ->
       mv_ok (safe_tgt ge bp (Mem.nextblock L)) (ZMap.get o ((Mem.mem_contents L) !! b)) = true)
    /\ (forall b o, Plt bp b -> Plt b (Mem.nextblock L) ->
       mv_ok (lt_tgt (Mem.nextblock L)) (ZMap.get o ((Mem.mem_contents L) !! b)) = true).
Proof.
  intros ge bp L H. apply andb_prop in H as [H1 H2]. rewrite forallb_forall in H1. split.
  - intros b o Hb. apply blk_ptrs_get. apply H1.
    destruct Hb as [Hb | ->]; [ right | left; reflexivity ].
    destruct (inFb_sym _ _ Hb) as (i & Hin & Hs). unfold fblks. apply in_flat_map.
    exists i. split; [ exact Hin | rewrite Hs; left; reflexivity ].
  - intros b o H3 H4. apply blk_ptrs_get. apply (range_ok_spec _ _ _ H2).
    + unfold Ple, Plt in *. apply Pos.le_succ_l. exact H3.
    + unfold Plt in *. apply Pos2Nat.inj_lt in H3. apply Pos2Nat.inj_lt in H4.
      rewrite Pos2Nat.inj_succ. lia.
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

Lemma world_keep : forall ef vargs m t v m', world ef vargs m = Some (t, v, m') -> acc_keep m m'.
Proof.
  intros ef vargs m t v m' H. unfold world in H.
  destruct ef; try discriminate H.
  destruct vargs as [| a [| a2 args]]; try discriminate H.
  - destruct (String.eqb name _); [ injection H as _ _ <-; apply acc_keep_refl | discriminate H ].
  - destruct a; try discriminate H.
    destruct (String.eqb name _); [ injection H as _ _ <-; apply acc_keep_refl | discriminate H ].
  - destruct a; discriminate H.
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

Definition s_chain (bm bo bc ab bt bs bar : block) (m3 : mem) : option mem :=
  match CM.store Mfloat32 m3 bm 64 (Vsingle ENTRY_Y) with
  | Some m3a =>
  match CM.store Mfloat32 m3a bo 36 (Vsingle ENTRY_Y) with
  | Some m3b =>
  match CM.store Mint16signed m3b bs 0 (Vint Int.zero) with
  | Some m4 =>
  match CM.store Mint32 m4 bm 12 (Vint ACT_SPAWN_NO_SPIN_AIRBORNE) with
  | Some m5 =>
  match CM.store Mint32 m5 bm 104 (Vptr bs Ptrofs.zero) with
  | Some m6 =>
  match CM.store Mint32 m6 bm 144 (Vptr bar Ptrofs.zero) with
  | Some m7 =>
  match CM.store Mint32 m7 bm 156 (Vptr bc Ptrofs.zero) with
  | Some m8 =>
  match CM.store Mint32 m8 bm 160 (Vptr ab Ptrofs.zero) with
  | Some m9 =>
  match CM.store Mint32 m9 bm 136 (Vptr bo Ptrofs.zero) with
  | Some m10 => CM.store Mint32 m10 ab 8 (Vptr bt Ptrofs.zero)
  | None => None end | None => None end | None => None end | None => None end | None => None end
  | None => None end | None => None end | None => None end | None => None end.

Definition terr_args (bcol : block) : list val :=
  [Vint (Int.repr 1); Vptr bcol Ptrofs.zero; Vint Int.zero; Vint Int.zero].

Definition nsurf_ok (m : mem) (bn : block) : bool :=
  match CM.load Mint32 m bn 0 with
  | Some (Vint n) => Z.eqb (Int.signed n) NSURF
  | _ => false
  end.

Definition wchk (ge : genv) (m0 : mem) : bool :=
  match Genv.find_symbol ge level_update._gMarioStates, Genv.find_symbol ge mario._gControllers,
        Genv.find_symbol ge mario._gMarioAnimsBuf, Genv.find_symbol ge object_list_processor._gObjectPool,
        Genv.find_symbol ge level_update._sWarpDest, Genv.find_symbol ge level_update._gCurrLevelNum with
  | Some bm, Some bc, Some ab, Some bo, Some bw, Some bL =>
  match sym ge "sPoolStart", sym ge "sPoolEnd", sym ge "sPoolFreeSpace",
        sym ge "sPoolListHeadL", sym ge "sPoolListHeadR",
        sym ge "wmotr_seg7_collision", sym ge "gSurfacesAllocated" with
  | Some s1, Some s2, Some s3, Some s4, Some s5, Some bcol, Some bn =>
  match e_chain bw bL m0 with
  | Some e6 =>
    let (P0, bp) := Mem.alloc e6 0 POOL in
    match apply_writes P0 (pool_writes s1 s2 s3 s4 s5 bp) 0 with
    | inl P =>
      match ex_call ge world FUEL P (Internal surface_load.f_alloc_surface_pools) [] with
      | Done (_, L1, _) =>
        match ex_call ge world FUEL L1 (Internal surface_load.f_load_area_terrain) (terr_args bcol) with
        | Done (_, L, _) =>
          let (m1, bt) := Mem.alloc L 0 24 in
          let (m2, bs) := Mem.alloc m1 0 48 in
          let (m3, bar) := Mem.alloc m2 0 60 in
          match s_chain bm bo bc ab bt bs bar m3 with
          | Some m11 =>
              old_ok ge e6 L && frag_ok ge bp L && wff_parts WFUEL ge bp m11
              && parts_ok WFUEL ge m11 && nsurf_ok m11 bn
          | None => false
          end
        | Stuck _ _ _ => false
        end
      | Stuck _ _ _ => false
      end
    | inr _ => false
    end
  | None => false
  end
  | _, _, _, _, _, _, _ => false
  end
  | _, _, _, _, _, _ => false
  end.

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
| WOut : forall s1 s2 s3 s4 s5 bcol bn e1 e2 e3 e4 e5 e6 P0 bp P t1 L1 v1 t2 L v2
                m1 bt m2 bs m3 bar m3a m3b m4 m5 m6 m7 m8 m9 m10 m11,
    Mem.store Mint8unsigned m0 bw 0 (Vint (Int.repr 1)) = Some e1 ->
    Mem.store Mint8unsigned e1 bw 1 (Vint (Int.repr LEVEL_WMOTR)) = Some e2 ->
    Mem.store Mint8unsigned e2 bw 2 (Vint (Int.repr WARP_AREA)) = Some e3 ->
    Mem.store Mint8unsigned e3 bw 3 (Vint (Int.repr WARP_NODE)) = Some e4 ->
    Mem.store Mint32 e4 bw 4 (Vint Int.zero) = Some e5 ->
    Mem.store Mint16signed e5 bL 0 (Vint (Int.repr LEVEL_WMOTR)) = Some e6 ->
    sym ge "wmotr_seg7_collision" = Some bcol ->
    Mem.alloc e6 0 POOL = (P0, bp) ->
    apply_writes P0 (pool_writes s1 s2 s3 s4 s5 bp) 0 = inl P ->
    sym ge "sPoolStart" = Some s1 -> sym ge "sPoolEnd" = Some s2 -> sym ge "sPoolFreeSpace" = Some s3 ->
    sym ge "sPoolListHeadL" = Some s4 -> sym ge "sPoolListHeadR" = Some s5 ->
    ex_call ge world FUEL P (Internal surface_load.f_alloc_surface_pools) [] = Done (t1, L1, v1) ->
    ex_call ge world FUEL L1 (Internal surface_load.f_load_area_terrain) (terr_args bcol)
      = Done (t2, L, v2) ->
    Mem.alloc L 0 24 = (m1, bt) -> Mem.alloc m1 0 48 = (m2, bs) -> Mem.alloc m2 0 60 = (m3, bar) ->
    Mem.store Mfloat32 m3 bm 64 (Vsingle ENTRY_Y) = Some m3a ->
    Mem.store Mfloat32 m3a bo 36 (Vsingle ENTRY_Y) = Some m3b ->
    Mem.store Mint16signed m3b bs 0 (Vint Int.zero) = Some m4 ->
    Mem.store Mint32 m4 bm 12 (Vint ACT_SPAWN_NO_SPIN_AIRBORNE) = Some m5 ->
    Mem.store Mint32 m5 bm 104 (Vptr bs Ptrofs.zero) = Some m6 ->
    Mem.store Mint32 m6 bm 144 (Vptr bar Ptrofs.zero) = Some m7 ->
    Mem.store Mint32 m7 bm 156 (Vptr bc Ptrofs.zero) = Some m8 ->
    Mem.store Mint32 m8 bm 160 (Vptr ab Ptrofs.zero) = Some m9 ->
    Mem.store Mint32 m9 bm 136 (Vptr bo Ptrofs.zero) = Some m10 ->
    Mem.store Mint32 m10 ab 8 (Vptr bt Ptrofs.zero) = Some m11 ->
    old_ok ge e6 L = true -> frag_ok ge bp L = true -> wff_parts WFUEL ge bp m11 = true ->
    parts_ok WFUEL ge m11 = true -> nsurf_ok m11 bn = true ->
    sym ge "gSurfacesAllocated" = Some bn ->
    wout ge m0 bm bc ab bo bw bL.

Ltac st_eq H := rewrite CM.store_eq in H.

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
  destruct (sym ge "sPoolStart") as [s1|] eqn:Hs1; [ | discriminate ].
  destruct (sym ge "sPoolEnd") as [s2|] eqn:Hs2; [ | discriminate ].
  destruct (sym ge "sPoolFreeSpace") as [s3|] eqn:Hs3; [ | discriminate ].
  destruct (sym ge "sPoolListHeadL") as [s4|] eqn:Hs4; [ | discriminate ].
  destruct (sym ge "sPoolListHeadR") as [s5|] eqn:Hs5; [ | discriminate ].
  destruct (sym ge "wmotr_seg7_collision") as [bcol|] eqn:Hcol; [ | discriminate ].
  destruct (sym ge "gSurfacesAllocated") as [bn|] eqn:Hbn; [ | discriminate ].
  destruct (e_chain bw bL m0) as [e6|] eqn:Ec; [ | discriminate ].
  unfold e_chain in Ec.
  destruct (CM.store Mint8unsigned m0 bw 0 _) as [e1|] eqn:E1; [ | discriminate ].
  destruct (CM.store Mint8unsigned e1 bw 1 _) as [e2|] eqn:E2; [ | discriminate ].
  destruct (CM.store Mint8unsigned e2 bw 2 _) as [e3|] eqn:E3; [ | discriminate ].
  destruct (CM.store Mint8unsigned e3 bw 3 _) as [e4|] eqn:E4; [ | discriminate ].
  destruct (CM.store Mint32 e4 bw 4 _) as [e5|] eqn:E5; [ | discriminate ].
  rename Ec into E6.
  destruct (Mem.alloc e6 0 POOL) as [P0 bp] eqn:AP.
  destruct (apply_writes P0 _ 0) as [P|] eqn:PW; [ | discriminate ].
  destruct (ex_call ge world FUEL P _ []) as [[[t1 L1] v1]| ? ? ?] eqn:R1; [ | discriminate ].
  destruct (ex_call ge world FUEL L1 _ _) as [[[t2 L] v2]| ? ? ?] eqn:R2; [ | discriminate ].
  destruct (Mem.alloc L 0 24) as [m1 bt] eqn:A1.
  destruct (Mem.alloc m1 0 48) as [m2 bs] eqn:A2.
  destruct (Mem.alloc m2 0 60) as [m3 bar] eqn:A3.
  destruct (s_chain bm bo bc ab bt bs bar m3) as [m11|] eqn:Sc; [ | discriminate ].
  unfold s_chain in Sc.
  destruct (CM.store Mfloat32 m3 bm 64 _) as [m3a|] eqn:S1a; [ | discriminate ].
  destruct (CM.store Mfloat32 m3a bo 36 _) as [m3b|] eqn:S1b; [ | discriminate ].
  destruct (CM.store Mint16signed m3b bs 0 _) as [m4|] eqn:S1; [ | discriminate ].
  destruct (CM.store Mint32 m4 bm 12 _) as [m5|] eqn:S2; [ | discriminate ].
  destruct (CM.store Mint32 m5 bm 104 _) as [m6|] eqn:S3; [ | discriminate ].
  destruct (CM.store Mint32 m6 bm 144 _) as [m7|] eqn:S4; [ | discriminate ].
  destruct (CM.store Mint32 m7 bm 156 _) as [m8|] eqn:S5; [ | discriminate ].
  destruct (CM.store Mint32 m8 bm 160 _) as [m9|] eqn:S6; [ | discriminate ].
  destruct (CM.store Mint32 m9 bm 136 _) as [m10|] eqn:S7; [ | discriminate ].
  rename Sc into S8.
  repeat match goal with H : CM.store _ _ _ _ _ = Some _ |- _ => rewrite CM.store_eq in H end.
  apply andb_prop in W as [W N5]. apply andb_prop in W as [W N4].
  apply andb_prop in W as [W N3]. apply andb_prop in W as [N1 N2].
  eapply WOut;
    [ exact E1 | exact E2 | exact E3 | exact E4 | exact E5 | exact E6 | exact Hcol | exact AP
    | exact PW | exact Hs1 | exact Hs2 | exact Hs3 | exact Hs4 | exact Hs5 | exact R1 | exact R2
    | exact A1 | exact A2 | exact A3 | exact S1a | exact S1b | exact S1 | exact S2 | exact S3
    | exact S4 | exact S5 | exact S6 | exact S7 | exact S8 | exact N1 | exact N2 | exact N3
    | exact N4 | exact N5 | exact Hbn ].
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

Lemma nonsafe_F : forallb (fun i => negb (mem_id i non_safeb_syms)) f_ids = true.
Proof. vm_compute. reflexivity. Qed.

Lemma nonsafe_notF : forall gid, mem_id gid non_safeb_syms = true -> mem_id gid f_ids = false.
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

Lemma neutral_frame : forall (ge : genv) thr e L bp,
    Mem.inject_neutral thr e -> Ple (Mem.nextblock L) thr ->
    acc_keep e L -> bp = Mem.nextblock e ->
    old_ok ge e L = true -> frag_ok ge bp L = true ->
    Mem.inject_neutral thr L.
Proof.
  intros ge thr e L bp N Hle [_ Ha] Hbp O F.
  pose proof (old_ok_sound _ _ _ O) as Oc. destruct (frag_ok_sound _ _ _ F) as (F1 & F2).
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
      + rewrite (Oc b o Hlt Fb).
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
