(* spine-root: NON-VACUITY WITNESS from the REAL boot image -- over every
   35-TU link, Genv.init_mem itself (not a memory built to look like it),
   then the real init_mario_from_save_file, then (i) one execute_mario_action
   frame, and (ii) WMotR's entry: the real terrain loader, the real
   init_mario and set_mario_initial_action, and one FULL real no-A frame
   that stores into gPlayerCameraState / gBodyStates. *)

(* Why (found 2026-10-22, tools/size0_globals.py): gPlayerCameraState and
   gBodyStates were declared, never defined, in the then 34-TU link
   (camera.c and mario_misc.c were not linked), so Genv.init_mem gave them
   SIZE-0 blocks.
   init_mario_from_save_file stores their addresses into
   m->statusForCamera / m->marioBodyState, and every execute_mario_action
   frame with a nonzero action stores through both (mario_reset_bodystate,
   update_mario_info_for_cam): no such frame from the real boot image had a
   CompCert execution, so the from-boot capstones held vacuously past the
   action-0 frames.  Repaired by linking camera.c (the 35th TU, which
   defines gPlayerCameraState, gCamera, gCameraMovementFlags,
   gCutsceneFocus) and, for the 17 other reached globals whose definer is
   still unlinked (gBodyStates among them), the 2.4 storage completion in
   pipeline/clightgen.sh.  This file is the guard that it stays repaired.

   What runs (the sound interpreter, Interp/ClightInterp.v, over the
   computable genv Interp/LinkGenv.v and the computable init_mem
   Interp/InitMemC.v, each proved equal to CompCert's):
   1. m0 = Genv.init_mem lp; the function the link resolves
      init_mario_from_save_file to runs: m1.  From m1 one execute_mario_action
      frame runs (the action init leaves is 0, so the frame does nothing; this
      is exactly the from-boot capstone's premise shape,
      NoAImpliesNoFlyTwelve.noA_never_flying_from_boot).
   2. WMotR's entry, from m1.  STAND-INS (not run; each is what the named
      real code would leave):
        - the main pool as one block in main_pool_init's post-state
          (TRUST 3.6; TerrainRun's pool_writes);
        - gCurrentArea := &gAreaData[1] (load_area), gMarioObject :=
          &gObjectPool[0] (the level script's Mario spawn);
        - gPlayerSpawnInfos[0].startPos := (-67, 2669, -16), the warp node
          0x0A object's position (init_mario_after_warp, level_update.c:372-374;
          values from the level script, WMotREntry);
        - Mario's animation DMA list: dmaTable := an empty table (count 0, so
          load_patchable_table loads nothing) and bufTarget := one animation
          whose index table points into zero values (setup_dma_table_list and
          the ROM's anim data are not run; TRUST 0.4).
      REAL code run: alloc_surface_pools, load_area_terrain(1,
      wmotr_seg7_collision, NULL, NULL) (WMotR's real terrain), init_mario,
      set_mario_initial_action(m, MARIO_SPAWN_AIRBORNE, 0).  Then one full
      execute_mario_action frame with A neither pressed nor held (the
      controller is gControllers[0], zero at boot): it starts and ends in
      ACT_SPAWN_NO_SPIN_AIRBORNE (6450), and gPlayerCameraState[0].action is
      6450 after it (update_mario_info_for_cam's store landed in the real
      storage).
   The world outside the link is a hypothesis (world_ok): sqrtf is the IEEE
   square root; play_sound, play_infinite_stairs_music,
   set_sound_moving_speed and reset_red_coins_collected (audio / ingame_menu,
   not linked) return without changing memory. *)

From Coq Require Import String List ZArith.
From compcert Require Import Coqlib Maps Integers Floats Values AST Memory Globalenvs
  Ctypes Clight ClightBigstep Events.
From SM64.Proofs Require Import Interp.ClightInterp Interp.LinkGenv Interp.MemBuild
  Interp.InitMemC.
From SM64.Proofs Require Interp.CMem.
From SM64.Proofs Require Import LinkedTwelve RealFrameLinked AGates EngineV2Consumer.
Require SM64.Generated.mario SM64.Generated.surface_load SM64.Generated.level_update.
Import ListNotations.
Module CM := SM64.Proofs.Interp.CMem.
Local Open Scope string_scope.

(* ---------------------------------------------------------------------- *)
(* The world outside the link                                              *)
(* ---------------------------------------------------------------------- *)

Definition world (ef : external_function) (args : list val) (m : mem)
    : option (trace * val * mem) :=
  match ef with
  | EF_external n _ =>
      if String.eqb n "sqrtf" then
        match args with [Vsingle x] => Some (E0, Vsingle (Float32.sqrt x), m) | _ => None end
      else if String.eqb n "play_sound" || String.eqb n "reset_red_coins_collected"
              || String.eqb n "play_infinite_stairs_music"
              || String.eqb n "set_sound_moving_speed"
      then Some (E0, Vundef, m)
      else None
  | _ => None
  end.

Definition world_ok (ge : genv) : Prop :=
  forall ef args m t v m', world ef args m = Some (t, v, m') -> external_call ef ge args m t v m'.

(* ---------------------------------------------------------------------- *)
(* Stand-ins                                                               *)
(* ---------------------------------------------------------------------- *)

Definition POOL : Z := 262144.

Definition pool_writes (s1 s2 s3 s4 s5 bp : block) : list wr :=
  [W Mint32 s1 0 (Vptr bp (Ptrofs.repr 16));
   W Mint32 s2 0 (Vptr bp (Ptrofs.repr (POOL - 16)));
   W Mint32 s3 0 (Vint (Int.repr (POOL - 32)));
   W Mint32 s4 0 (Vptr bp Ptrofs.zero);
   W Mint32 s5 0 (Vptr bp (Ptrofs.repr (POOL - 16)));
   W Mint32 bp 0 (Vint Int.zero); W Mint32 bp 4 (Vint Int.zero);
   W Mint32 bp (POOL - 16) (Vint Int.zero); W Mint32 bp (POOL - 12) (Vint Int.zero)].

(* the main pool (TRUST 3.6), on top of m *)
Definition pool_mem (ge : genv) (m : mem) : option mem :=
  match fresh m POOL, sym ge "sPoolStart", sym ge "sPoolEnd", sym ge "sPoolFreeSpace",
        sym ge "sPoolListHeadL", sym ge "sPoolListHeadR" with
  | Some (m1, bp), Some s1, Some s2, Some s3, Some s4, Some s5 =>
      match apply_writes m1 (pool_writes s1 s2 s3 s4 s5 bp) 0 with
      | inl m2 => Some m2
      | inr _ => None
      end
  | _, _, _, _, _, _ => None
  end.

Definition P (b : block) : val := Vptr b Ptrofs.zero.
Definition i32 (z : Z) : val := Vint (Int.repr z).

(* the level-entry cells the unrun code leaves (header, step 2) *)
Definition entry_mem (ge : genv) (m : mem) : option mem :=
  let o s f := match off ge s f with Some d => d | None => -100000 end in
  match sym ge "gCurrentArea", sym ge "gAreaData", sym ge "gMarioObject",
        sym ge "gObjectPool", sym ge "gPlayerSpawnInfos", sym ge "gMarioAnimsBuf" with
  | Some bca, Some bad, Some bmo, Some bop, Some bsi, Some bab =>
    match fresh m (ssize ge "DmaTable") with
    | Some (m1, btbl) =>
    match fresh m1 (ssize ge "Animation") with
    | Some (m2, banim) =>
    match fresh m2 64 with
    | Some (m3, bidx) =>
    match fresh m3 4096 with
    | Some (m4, bval) =>
      let ws := [ W Mint32 bca 0 (Vptr bad (Ptrofs.repr (ssize ge "Area")));
                  W Mint32 bmo 0 (P bop);
                  W Mint16signed bsi (o "SpawnInfo" "startPos") (i32 (-67));
                  W Mint16signed bsi (o "SpawnInfo" "startPos" + 2) (i32 2669);
                  W Mint16signed bsi (o "SpawnInfo" "startPos" + 4) (i32 (-16));
                  W Mint32 bab (o "DmaHandlerList" "dmaTable") (P btbl);
                  W Mint32 bab (o "DmaHandlerList" "bufTarget") (P banim);
                  W Mint32 banim (o "Animation" "index") (P bidx);
                  W Mint32 banim (o "Animation" "values") (P bval);
                  W Mint16unsigned bidx 0 (i32 256); W Mint16unsigned bidx 2 (i32 40);
                  W Mint16unsigned bidx 4 (i32 256); W Mint16unsigned bidx 6 (i32 40);
                  W Mint16unsigned bidx 8 (i32 256); W Mint16unsigned bidx 10 (i32 40) ] in
      match apply_writes m4 ws 0 with
      | inl m5 => Some m5
      | inr _ => None
      end
    | None => None end
    | None => None end
    | None => None end
    | None => None end
  | _, _, _, _, _, _ => None
  end.

(* ---------------------------------------------------------------------- *)
(* Checks on memories                                                      *)
(* ---------------------------------------------------------------------- *)

Definition ACT_SPAWN_NO_SPIN_AIRBORNE : Z := 6450.   (* 0x00001932 *)

Definition ld32_is (m : mem) (b : block) (z v : Z) : bool :=
  match CM.load Mint32 m b z with
  | Some (Vint i) => Int.eq i (Int.repr v)
  | _ => false
  end.

Definition a_pressed_b (bm : block) (m : mem) : bool :=
  match CM.load Mptr m bm 156 with
  | Some (Vptr bc oc) =>
      match CM.load Mint16unsigned m bc (Ptrofs.unsigned (Ptrofs.add oc (Ptrofs.repr 18))) with
      | Some (Vint v) => negb (Int.eq (Int.and v (Int.repr 32768)) Int.zero)
      | _ => true
      end
  | _ => true
  end.

Lemma a_pressed_b_eq : forall bm m, a_pressed_b bm m = a_pressed_real bm m.
Proof.
  intros. unfold a_pressed_b, a_pressed_real. rewrite !CM.load_eq.
  destruct (Mem.load Mptr m bm 156) as [[]|]; auto. rewrite CM.load_eq. reflexivity.
Qed.

Lemma ld32_is_sound : forall m b z v, ld32_is m b z v = true ->
    Mem.load Mint32 m b z = Some (Vint (Int.repr v)).
Proof.
  unfold ld32_is; intros m b z v H. rewrite CM.load_eq in H.
  destruct (Mem.load Mint32 m b z) as [[]|]; try discriminate.
  apply Int.same_if_eq in H. subst. reflexivity.
Qed.

(* ---------------------------------------------------------------------- *)
(* The run, generic in the fuel, the genv and the AST                     *)
(* ---------------------------------------------------------------------- *)

Definition FUEL : nat := Z.to_nat 2000000.

Definition ok_run (ge : genv) (fuel : nat) (m : mem) (f : fundef) (args : list val)
    (k : mem -> bool) : bool :=
  match ex_call ge world fuel m f args with
  | Done _ (_, m', _) => k m'
  | Stuck _ _ _ _ => false
  end.

(* everything after init_mario_from_save_file: (i) the boot frame, (ii) the entry *)
Definition after_init (ge : genv) (fuel : nat) (bm bpcs : block) (m1 : mem) : bool :=
  ok_run ge fuel m1 (Internal mario.f_execute_mario_action) [P bm] (fun _ => true)
  && negb (a_pressed_b bm m1)
  && match pool_mem ge m1, sym ge "wmotr_seg7_collision", sym ge "gObjectPool" with
     | Some m3, Some bcol, Some bop =>
       ok_run ge fuel m3 (Internal surface_load.f_alloc_surface_pools) [] (fun m4 =>
       ok_run ge fuel m4 (Internal surface_load.f_load_area_terrain)
              [i32 1; P bcol; Vint Int.zero; Vint Int.zero] (fun m5 =>
       match entry_mem ge m5 with
       | Some m10 =>
         ok_run ge fuel m10 (Internal mario.f_init_mario) [] (fun m11 =>
         ok_run ge fuel m11 (Internal level_update.f_set_mario_initial_action)
                [P bm; i32 18; i32 0] (fun m12 =>
           negb (a_pressed_b bm m12)
           && ld32_is m12 bm 12 ACT_SPAWN_NO_SPIN_AIRBORNE
           && ok_run ge fuel m12 (Internal mario.f_execute_mario_action) [P bop] (fun m13 =>
                ld32_is m13 bm 12 ACT_SPAWN_NO_SPIN_AIRBORNE
                && ld32_is m13 bpcs 0 ACT_SPAWN_NO_SPIN_AIRBORNE)))
       | None => false
       end))
     | _, _, _ => false
     end.

Definition boot_check (ge : genv) (ast : AST.program (Ctypes.fundef function) type)
    (fuel : nat) : bool :=
  match init_mem_c ast, Genv.find_symbol ge (id "init_mario_from_save_file"),
        Genv.find_symbol ge (id "gMarioStates"), Genv.find_symbol ge (id "gPlayerCameraState") with
  | Some m0, Some bi, Some bm, Some bpcs =>
      match Genv.find_funct ge (Vptr bi Ptrofs.zero) with
      | Some fi =>
          ok_run ge fuel m0 fi [] (after_init ge fuel bm bpcs)
          && match off ge "PlayerCameraState" "action" with Some 0 => true | _ => false end
      | None => false
      end
  | _, _, _, _ => false
  end.

Definition witness_gen (oge : option genv)
    (oast : option (AST.program (Ctypes.fundef function) type)) : bool :=
  match oge, oast with
  | Some ge, Some ast => boot_check ge ast FUEL
  | _, _ => false
  end.

Definition witness_ok : bool := witness_gen ge12 ast12.

(* THE COMPUTATION (about 4 minutes: init_mem of the link, the terrain
   loader over WMotR's 1352 surfaces, and the runs) *)
Lemma witness_ok_true : witness_ok = true.
Proof. vm_compute. reflexivity. Qed.

(* ---------------------------------------------------------------------- *)
(* Soundness                                                               *)
(* ---------------------------------------------------------------------- *)

Section Sound.
  Variable ge : genv.
  Hypothesis W : world_ok ge.
  Variable fuel : nat.

  Lemma ok_run_sound : forall m f args k, ok_run ge fuel m f args k = true ->
      exists t m' v, eval_funcall function_entry2 ge m f args t m' v /\ k m' = true.
  Proof.
    unfold ok_run; intros m f args k H.
    destruct (ex_call ge world fuel m f args) as [[[t m'] v]| ? ? ?] eqn:R; [ | discriminate].
    exists t, m', v. split; [ exact (ex_call_sound ge world W _ _ _ _ _ _ _ R) | exact H ].
  Qed.

  (* what after_init certifies, in the semantics *)
  Definition entry_ok (bm bpcs : block) (m1 : mem) : Prop :=
    (exists t m' v, eval_funcall function_entry2 ge m1 (Internal mario.f_execute_mario_action)
                      [P bm] t m' v)
    /\ a_pressed_real bm m1 = false
    /\ exists m3 bcol bop m4 m5 m10 m11 m12 m13 t4 v4 t5 v5 t11 v11 t12 v12 t13 v13,
      pool_mem ge m1 = Some m3
      /\ sym ge "wmotr_seg7_collision" = Some bcol /\ sym ge "gObjectPool" = Some bop
      /\ eval_funcall function_entry2 ge m3 (Internal surface_load.f_alloc_surface_pools) []
           t4 m4 v4
      /\ eval_funcall function_entry2 ge m4 (Internal surface_load.f_load_area_terrain)
           [i32 1; P bcol; Vint Int.zero; Vint Int.zero] t5 m5 v5
      /\ entry_mem ge m5 = Some m10
      /\ eval_funcall function_entry2 ge m10 (Internal mario.f_init_mario) [] t11 m11 v11
      /\ eval_funcall function_entry2 ge m11 (Internal level_update.f_set_mario_initial_action)
           [P bm; i32 18; i32 0] t12 m12 v12
      /\ a_pressed_real bm m12 = false
      /\ Mem.load Mint32 m12 bm 12 = Some (Vint (Int.repr ACT_SPAWN_NO_SPIN_AIRBORNE))
      /\ eval_funcall function_entry2 ge m12 (Internal mario.f_execute_mario_action) [P bop]
           t13 m13 v13
      /\ Mem.load Mint32 m13 bm 12 = Some (Vint (Int.repr ACT_SPAWN_NO_SPIN_AIRBORNE))
      /\ Mem.load Mint32 m13 bpcs 0 = Some (Vint (Int.repr ACT_SPAWN_NO_SPIN_AIRBORNE)).

  Lemma nab : forall bm m, negb (a_pressed_b bm m) = true -> a_pressed_real bm m = false.
  Proof.
    intros bm m H. rewrite <- a_pressed_b_eq. destruct (a_pressed_b bm m); [ discriminate | reflexivity ].
  Qed.

  Lemma after_init_sound : forall bm bpcs m1,
      after_init ge fuel bm bpcs m1 = true -> entry_ok bm bpcs m1.
  Proof.
    intros bm bpcs m1 H. unfold after_init in H.
    apply andb_prop in H as [H H2]. apply andb_prop in H as [H0 H1].
    destruct (ok_run_sound _ _ _ _ H0) as (t & m' & v & E0' & _).
    split; [ exists t, m', v; exact E0' | ].
    split; [ exact (nab _ _ H1) | ].
    destruct (pool_mem ge m1) as [m3|] eqn:Pm; [ | discriminate].
    destruct (sym ge "wmotr_seg7_collision") as [bcol|] eqn:Sc; [ | discriminate].
    destruct (sym ge "gObjectPool") as [bop|] eqn:So; [ | discriminate].
    destruct (ok_run_sound _ _ _ _ H2) as (t4 & m4 & v4 & E4 & K4).
    destruct (ok_run_sound _ _ _ _ K4) as (t5 & m5 & v5 & E5 & K5).
    destruct (entry_mem ge m5) as [m10|] eqn:Em; [ | discriminate].
    destruct (ok_run_sound _ _ _ _ K5) as (t11 & m11 & v11 & E11 & K11).
    destruct (ok_run_sound _ _ _ _ K11) as (t12 & m12 & v12 & E12 & K12).
    apply andb_prop in K12 as [K12 K13]. apply andb_prop in K12 as [Ka Kact].
    destruct (ok_run_sound _ _ _ _ K13) as (t13 & m13 & v13 & E13 & K).
    apply andb_prop in K as [Kb Kc].
    exists m3, bcol, bop, m4, m5, m10, m11, m12, m13, t4, v4, t5, v5, t11, v11, t12, v12, t13, v13.
    repeat split; auto using nab, ld32_is_sound.
  Qed.

  Lemma boot_check_sound : forall ast, boot_check ge ast fuel = true ->
      exists m0 bi bm bpcs fi t1 m1 v1,
        init_mem_c ast = Some m0
        /\ Genv.find_symbol ge (id "init_mario_from_save_file") = Some bi
        /\ Genv.find_funct ge (Vptr bi Ptrofs.zero) = Some fi
        /\ Genv.find_symbol ge (id "gMarioStates") = Some bm
        /\ Genv.find_symbol ge (id "gPlayerCameraState") = Some bpcs
        /\ eval_funcall function_entry2 ge m0 fi [] t1 m1 v1
        /\ entry_ok bm bpcs m1.
  Proof.
    intros ast H. unfold boot_check in H.
    destruct (init_mem_c ast) as [m0|] eqn:Hm0; [ | discriminate].
    destruct (Genv.find_symbol ge (id "init_mario_from_save_file")) as [bi|] eqn:Hbi;
      [ | discriminate].
    destruct (Genv.find_symbol ge (id "gMarioStates")) as [bm|] eqn:Hbm; [ | discriminate].
    destruct (Genv.find_symbol ge (id "gPlayerCameraState")) as [bpcs|] eqn:Hbp;
      [ | discriminate].
    destruct (Genv.find_funct ge (Vptr bi Ptrofs.zero)) as [fi|] eqn:Hfi; [ | discriminate].
    apply andb_prop in H as [H _].
    destruct (ok_run_sound _ _ _ _ H) as (t1 & m1 & v1 & E1 & K).
    exists m0, bi, bm, bpcs, fi, t1, m1, v1.
    repeat (split; [ first [ reflexivity | assumption ] | ]). exact (after_init_sound _ _ _ K).
  Qed.
End Sound.

(* ---------------------------------------------------------------------- *)
(* THE WITNESS                                                             *)
(* ---------------------------------------------------------------------- *)

Lemma id_ifs : id "init_mario_from_save_file" = mario._init_mario_from_save_file.
Proof. reflexivity. Qed.

(* Over every 34-TU link, given only what the four audio / menu externals
   and sqrtf do (world_ok):
   - the from-boot capstone's premises are jointly met with a real step:
     Genv.init_mem lp, the function the link resolves
     init_mario_from_save_file to, run from it, and one execute_mario_action
     frame from its result, with A not pressed;
   - from that same post-init memory, WMotR's entry (stand-ins above, real
     terrain loader, init_mario, set_mario_initial_action) reaches
     ACT_SPAWN_NO_SPIN_AIRBORNE with A not pressed, and one full real frame
     executes, ending with gPlayerCameraState[0].action = 6450: the store
     through m->statusForCamera that had no execution before camera.c was
     linked. *)
Theorem boot_frames_run : forall lp, linked12 lp -> world_ok (globalenv lp) ->
    exists m0 fd t1 m1 v1 bm bpcs,
      Genv.init_mem lp = Some m0
      /\ resolves_lp lp mario._init_mario_from_save_file fd
      /\ eval_funcall function_entry2 (lp_ge lp) m0 fd [] t1 m1 v1
      /\ Genv.find_symbol (lp_ge lp) (id "gMarioStates") = Some bm
      /\ Genv.find_symbol (lp_ge lp) (id "gPlayerCameraState") = Some bpcs
      /\ (exists m', execute_mario_action_step_lp lp m1 m')
      /\ entry_ok (globalenv lp) bm bpcs m1.
Proof.
  intros lp Hlink Hw.
  pose proof witness_ok_true as Wk. unfold witness_ok in Wk.
  rewrite (ge12_ok lp Hlink), (ast12_ok lp Hlink) in Wk. unfold witness_gen in Wk.
  destruct (boot_check_sound (globalenv lp) Hw FUEL (program_of_program lp) Wk)
    as (m0 & bi & bm & bpcs & fi & t1 & m1 & v1 & Hm0 & Hbi & Hfi & Hbm & Hbp & E1 & Ent).
  rewrite init_mem_c_eq in Hm0.
  exists m0, fi, t1, m1, v1, bm, bpcs.
  split; [ exact Hm0 | ].
  split; [ exists bi; rewrite <- id_ifs; split; [ exact Hbi | exact Hfi ] | ].
  split; [ exact E1 | ].
  split; [ exact Hbm | ].
  split; [ exact Hbp | ].
  split; [ | exact Ent ].
  destruct Ent as ((t & m' & v & E) & _).
  exists m'. exists bm, t, v. exact E.
Qed.

(* ---------------------------------------------------------------------- *)
(* The reached globals that had size-0 blocks now have storage: the four *)
(* camera.c defines (linked) and the 17 the 2.4 completion gives          *)
(* (pipeline/clightgen.sh).  In the linked program each one's initializer *)
(* is exactly sizeof its declared type in the linked composite env, and   *)
(* nonzero.                                                                *)
(* ---------------------------------------------------------------------- *)

Definition completed : list string :=
  [ "gPlayerCameraState"; "gCamera"; "gCameraMovementFlags"; "gCutsceneFocus"; "gBodyStates";
    "gCurGraphNodeRoot"; "gCurGraphNodeMasterList"; "gCurGraphNodeCamFrustum";
    "gCurGraphNodeCamera"; "gCurGraphNodeObject"; "gAreaUpdateCounter"; "gDmaIoMesg";
    "gMainReceivedMesg"; "gDmaMesgQueue"; "gSIEventMesgQueue"; "gDebugLevelSelect";
    "gShowDebugText"; "gDialogResponse"; "gPaintingMarioYEntry"; "gObjParentGraphNode";
    "gGlobalSoundSource" ].

Definition sizes_gen (oge : option genv)
    (oast : option (AST.program (Ctypes.fundef function) type)) : bool :=
  match oge, oast with
  | Some ge, Some ast =>
      let dm := prog_defmap ast in
      forallb (fun s => match PTree.get (id s) dm with
                        | Some (Gvar v) =>
                            Z.eqb (sizeof ge (gvar_info v)) (init_data_list_size (gvar_init v))
                            && negb (Z.eqb (init_data_list_size (gvar_init v)) 0)
                        | _ => false
                        end) completed
  | _, _ => false
  end.

Lemma completed_sizes : sizes_gen ge12 ast12 = true.
Proof. vm_compute. reflexivity. Qed.
