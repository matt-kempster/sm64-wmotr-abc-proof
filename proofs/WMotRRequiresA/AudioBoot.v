(* kept: AudioInv at boot (2026-11-02).  Consumed by the deferred root
   rebuild (FfWorld.lvl_w's aud_w clause, proved at the start witness). *)
(* ====================================================================== *)
(* AudioBoot.v -- AudioInv holds on the boot images, by vm.               *)
(*                                                                        *)
(* Two memories, both computed from the real 53-TU link:                 *)
(*   - Genv.init_mem (the boot image);                                     *)
(*   - the GOAL-2 start witness, m11 of StartTerrain.wchk's chain.         *)
(* StartTerrain exposes only wchk's bool, so wit11 below is that chain     *)
(* with the final checks dropped and m11 returned (generated from wchk's   *)
(* text; the computation is the same).  THE WITNESS IS NAMED ONCE:         *)
(* aud_wit.  When the real-order witness replaces StartTerrain's chain,     *)
(* re-point that one line.                                                 *)
(*                                                                        *)
(* Both memories have NO pointer in any audio block (the audio thread and *)
(* audio_init are not linked: the audio state is its zero initializers).  *)
(* ====================================================================== *)
From Coq Require Import String List ZArith Lia.
From compcert Require Import Coqlib Maps Integers Floats Values AST Memory Memdata Globalenvs
  Ctypes Clight ClightBigstep Events.
From SM64.Proofs Require Import Interp.ClightInterp Interp.LinkGenv Interp.MemBuild
  Interp.InitMemC Interp.InterpFrame.
From SM64.Proofs Require Interp.CMem.
From SM64.Proofs Require Import CensusV2 SpawnInit LinkedTwelve.
From SM64.Proofs.WMotRRequiresA Require Import FloorList FloorExec FfWorld WMotRWorld
  HeightInvariant WMotRLevel WMotREntry EntryWarp TerrainRun StartTerrain.
From SM64.Generated Require mario level_update object_list_processor surface_load
  surface_collision wmotr_script graph_node area memory camera interaction game_init.
From SM64.Proofs.WMotRRequiresA Require ObjWorld.
From SM64.Proofs.NoAImpliesNoFly Require BootRun.
From SM64.Proofs.WMotRRequiresA Require Import AudioInv.
Import ListNotations.
Module CM := SM64.Proofs.Interp.CMem.
Arguments Done {A}.

(* StartTerrain.wchk's chain (the real-order Step-B chain, 2026-11-02),
   returning its memory m11 *)
Definition wit11 (ge : genv) (m0 : mem) : option mem :=
  match Genv.find_symbol ge level_update._gMarioStates, Genv.find_symbol ge mario._gControllers,
        Genv.find_symbol ge mario._gMarioAnimsBuf, Genv.find_symbol ge object_list_processor._gObjectPool,
        Genv.find_symbol ge level_update._sWarpDest, Genv.find_symbol ge level_update._gCurrLevelNum,
        Genv.find_symbol ge level_update._gCurrCourseNum, Genv.find_symbol ge game_init._gMarioAnims,
        Genv.find_symbol ge game_init._gControllerPads,
        Genv.find_symbol ge level_update._gCurrentArea, Genv.find_symbol ge area._gAreaData with
  | Some bm, Some bc, Some ab, Some bo, Some bw, Some bL, Some bC, Some bga, Some bpads, Some bca, Some bgad =>
  match sym ge "gPlayerSpawnInfos", sym ge "gPlayerCameraState", sym ge "gBodyStates",
        sym ge "gHudDisplay" with
  | Some bsi, Some bpcs, Some bbs, Some bhud =>
  match sym ge "sPoolStart", sym ge "sPoolEnd", sym ge "sPoolFreeSpace",
        sym ge "sPoolListHeadL", sym ge "sPoolListHeadR",
        sym ge "wmotr_seg7_collision", sym ge "gSurfacesAllocated" with
  | Some s1, Some s2, Some s3, Some s4, Some s5, Some bcol, Some bn =>
  match sym ge "gObjParentGraphNode", sym ge "bhvMario",
        off ge "SpawnInfo" "behaviorArg", off ge "SpawnInfo" "behaviorScript",
        sym ge "wmotr_seg7_macro_objs" with
  | Some bpg, Some bmb, Some oba, Some obs, Some bmac =>
  match e_chain bw bL m0 with
  | Some e6 =>
    let (P0, bp) := Mem.alloc e6 0 POOL in
    match apply_writes P0 (pool_writes s1 s2 s3 s4 s5 bp) 0 with
    | inl P =>
      (* the game loop's select_gfx_pool before the level script runs
         (Step B, 2026-11-02: with the identity set_segment_base_addr,
         TRUST 2.2) *)
      match ex_call ge world FUEL P (Internal game_init.f_select_gfx_pool) [] with
      | Done (_, Pgfx, _) =>
      (* level_cmd_init_level: init_graph_node_start(NULL,
         &gObjParentGraphNode); clear_objects() *)
      match ex_call ge world FUEL Pgfx (Internal graph_node.f_init_graph_node_start)
              [Vint Int.zero; Vptr bpg Ptrofs.zero] with
      | Done (_, PG, _) =>
      match ex_call ge world FUEL PG (Internal object_list_processor.f_clear_objects) [] with
      | Done (_, PO, _) =>
      (* LOAD_AREA's geo: the area's Camera (cam_chain) *)
      match cam_chain ge bgad PO with
      | Some (Pc, cam) =>
      (* ALLOC_LEVEL_POOL, AREA(1), the act, the OBJECT commands (lvl_objs) *)
      match lvl_objs ge Pc with
      | Some Pq =>
      match ex_call ge world FUEL Pq (Internal surface_load.f_alloc_surface_pools) [] with
      | Done (_, L1, _) =>
        match ex_call ge world FUEL L1 (Internal surface_load.f_load_area_terrain) (terr_args2 bcol bmac) with
        | Done (_, L00, _) =>
        (* load_area: the area's spawn infos (the placed objects) *)
        match area_spawn ge bgad L00 with
        | Some L0 =>
        (* load_mario_area: spawn_objects_from_info(0, gMarioSpawnInfo);
           the two SpawnInfo cells level_cmd_init_mario sets (behaviorArg 1,
           behaviorScript bhvMario) are stores (level_script.c is not
           linked, TRUST) *)
        match CM.store Mint32 L0 bsi oba (Vint (Int.repr 1)) with
        | Some La =>
        match CM.store Mint32 La bsi obs (Vptr bmb Ptrofs.zero) with
        | Some Lb =>
        match ex_call ge world FUEL Lb (Internal object_list_processor.f_spawn_objects_from_info)
                [Vint Int.zero; Vptr bsi Ptrofs.zero] with
        | Done (_, L, _) =>
          let (m1, bt) := Mem.alloc L 0 16384 in
          let (m2, bs) := Mem.alloc m1 0 48 in
          let (m2b, bar) := Mem.alloc m2 0 60 in
          let (m3, bd) := Mem.alloc m2b 0 1680 in
          match s_chain bm bo bc ab bt bs bar m3 with
          | Some ms =>
            match x_chain bm ab bt bar bd bsi bpcs bbs bhud bC bc bpads bw bca bgad (tab_writes m0 bd bga) (cur_addr m0 bga) ms with
            | Some m11 => Some m11
            | None => None
            end
          | None => None
          end
        | Stuck _ _ _ => None
        end
        | None => None end
        | None => None end
        | None => None end
        | Stuck _ _ _ => None
        end
      | Stuck _ _ _ => None
      end
      | None => None end
      | None => None end
      | Stuck _ _ _ => None end
      | Stuck _ _ _ => None end
      | Stuck _ _ _ => None end
    | inr _ => None
    end
  | None => None
  end
  | _, _, _, _, _ => None
  end
  | _, _, _, _, _, _, _ => None
  end
  | _, _, _, _ => None
  end
  | _, _, _, _, _, _, _, _, _, _, _ => None
  end.


(* THE WITNESS (re-point here) *)
Definition aud_wit (ge : genv) (m0 : mem) : option mem := wit11 ge m0.

Definition aud_boot_gen (oge : option genv) (oast : option (AST.program (Ctypes.fundef function) type)) : bool :=
  match oge, oast with
  | Some ge, Some ast =>
      match alloc_globals_c (Genv.globalenv ast) Mem.empty (AST.prog_defs ast) with
      | Some m0 => aud_chk ge m0 && match aud_wit ge m0 with Some m => aud_chk ge m | None => false end
      | None => false
      end
  | _, _ => false
  end.

Lemma aud_boot_gen_true : aud_boot_gen ge12 ast12 = true.
Proof. vm_cast_no_check (eq_refl true). Qed.

Lemma aud_boot_chk : forall lp, linked12 lp -> forall m0, Genv.init_mem lp = Some m0 ->
    aud_chk (globalenv lp) m0 = true
    /\ exists m, aud_wit (globalenv lp) m0 = Some m /\ aud_chk (globalenv lp) m = true.
Proof.
  intros lp H12 m0 Hinit.
  pose proof aud_boot_gen_true as W. unfold aud_boot_gen in W.
  rewrite (ge12_ok lp H12), (ast12_ok lp H12) in W.
  rewrite (init_mem_c _ _ Hinit) in W.
  apply andb_prop in W as [W0 W1]. split; [ exact W0 | ].
  destruct (aud_wit (globalenv lp) m0) as [m|]; [ | discriminate W1 ].
  exists m. split; [ reflexivity | exact W1 ].
Qed.

(* THE RESULT: AudioInv on the boot image and on the start witness *)
Theorem audio_inv_boot : forall lp, linked12 lp -> forall m0, Genv.init_mem lp = Some m0 ->
    AudioInv (globalenv lp) m0
    /\ exists m, aud_wit (globalenv lp) m0 = Some m /\ AudioInv (globalenv lp) m.
Proof.
  intros lp H12 m0 Hinit.
  destruct (aud_boot_chk lp H12 m0 Hinit) as (C0 & m & Ew & C1).
  split; [ exact (aud_chk_sound _ _ C0) | exists m; split; [ exact Ew | exact (aud_chk_sound _ _ C1) ] ].
Qed.
