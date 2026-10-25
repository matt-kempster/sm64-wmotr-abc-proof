(* spine-root: the GOAL-2 start-premise guard -- the capstone's premise is met by a memory built from the real boot image (not vacuous). *)
(* ====================================================================== *)
(* StartSat (GOAL 2): the capstone's start premise is satisfiable.        *)
(*                                                                        *)
(* wmotr_noA_height_bound_linked12 quantifies over start memories with   *)
(* mem_ok_lp (GOAL 1's MWF_real) and PhiW (the height invariant plus the *)
(* frame world: WMotR surfaces, the anim layout, Mario's object apart,   *)
(* closedness, the collision partition, the controller).  If no memory   *)
(* met both, the capstone would be vacuously true.                        *)
(*                                                                        *)
(* goal2_start_sat builds one, from the real boot image of ANY 17-TU     *)
(* link: Genv.init_mem lp, three fresh blocks (the anim DMA buffer, one   *)
(* floor surface, the area), and ten stores -- the cells the level load   *)
(* and init_mario / set_mario_initial_action / setup_dma_table_list set   *)
(* AT THE REAL WMotR ENTRY (WMotREntry.v, read off the generated level    *)
(* script and level_update.c): m->pos[1] := 2669 and marioObj->gfx.pos[1] *)
(* := 2669 (the bhvAirborneWarp at warp node 0x0A), m->action :=         *)
(* ACT_SPAWN_NO_SPIN_AIRBORNE (MARIO_SPAWN_AIRBORNE's case), plus         *)
(* m->floor, m->area, m->controller := &gControllers[0], m->animList :=  *)
(* &gMarioAnimsBuf, m->marioObj := &gObjectPool[0], the floor's type,    *)
(* list->bufTarget.  vel, actionState, actionTimer are the zero init_mario*)
(* writes (= the boot image's BSS).  The height cells read back are       *)
(* exactly entry_cells, so the budget is the real entry's (margin 127).   *)
(* Each MWF_real step is a proved store brick.                            *)
(*                                                                        *)
(* What it does NOT say: that the memory the real game reaches at WMotR  *)
(* entry is this one or satisfies PhiW.  The level loader (surface_load,  *)
(* area.c) is not linked: gCurrLevelNum / gMarioSpawnInfo have no storage *)
(* in the 17-TU link, so in_wmotr is unreachable from boot by real code  *)
(* (TRUST.md 0.4).  It rules out the empty-premise form of vacuity and   *)
(* pins the height cells to the real entry values.                        *)
(* (Since then area.c is linked, so in_wmotr holds by real code, and,     *)
(* 2026-10-22, surface_load.c: the collision partitions have their real   *)
(* storage.  2026-10-22, later: the witness carries WMotR's REAL terrain: *)
(* between the entry stores and init_mario's cells, the real boot order  *)
(* runs main_pool_init's post-state (TRUST 3.6) and the generated         *)
(* alloc_surface_pools + load_area_terrain on the init_mem image          *)
(* (StartTerrain), so both partitions hold the loader's 1352 surfaces,    *)
(* floor_data and static_agree hold on the witness, and MWF_real / PhiW   *)
(* are re-proved across the load.)                                        *)
(* ====================================================================== *)

From Coq Require Import ZArith List Lia Reals Lra.
From Flocq Require Import Binary.
From compcert Require Import Coqlib Maps AST Integers Floats Values Memory
  Globalenvs Ctypes Clight ClightBigstep Events Linking.
From SM64.Generated Require mario level_update interaction mario_actions_moving
  surface_collision memory game_init object_list_processor area surface_load camera platform_displacement
  graph_node rendering_graph_node mario_anim_data audio_external sound_init libultra_osContInit.
From SM64.Proofs Require Import RealFrameLinked ActionValueFrame Taint CensusV2 MWFReal SpawnInit
  LinkedTwelve InitMemSat BootMWF NoAImpliesNoFlyLinked ClosedMem.
From SM64.Proofs.WMotRRequiresA Require Import HeightInvariant NoAActions WMotRWorld
  FloorList FloorHeight FloorExec AirMatch FfWorld FrameSplit HeightFrame WMotREntry
  EntryWarp WMotRLevel.
From SM64.Proofs Require Import Interp.ClightInterp Interp.MemBuild Interp.InterpFrame.
From SM64.Proofs.WMotRRequiresA Require Import FpuFloor FpuValue TerrainRun StartTerrain.
From SM64.Proofs.WMotRRequiresA Require CourseRun AnimData AnimWorld PlatformKeep.
From SM64.Proofs.NoAImpliesNoFly Require BootRun.
From SM64.Proofs Require AGates LinkedTwelve InitMemSat.
Import ListNotations.
Arguments Done {A}.
Arguments Stuck {A}.

Local Open Scope Z_scope.

(* ---------------------------------------------------------------------- *)
(* Part 1: generic facts about the boot image.                             *)
(* ---------------------------------------------------------------------- *)

(* a linked gvar keeps a TU's flags and size: write permission over it *)
Lemma lo_gvar_writable : forall (q lp : Clight.program) m id b vq,
    linkorder q lp -> Genv.init_mem lp = Some m ->
    (prog_defmap q) ! id = Some (Gvar vq) ->
    gvar_readonly vq = false -> gvar_volatile vq = false -> gvar_init vq <> nil ->
    Genv.find_symbol (Genv.globalenv lp) id = Some b ->
    Mem.range_perm m b 0 (init_data_list_size (gvar_init vq)) Cur Writable.
Proof.
  intros q lp m id b vq LOq Hinit Hdm Hro Hvo Hne Hfs.
  Local Transparent Linker_program.
  unfold linkorder, Linker_program, linkorder_program in LOq.
  destruct LOq as [LOast _].
  destruct (prog_defmap_linkorder _ _ _ _ LOast Hdm) as (gd' & Hgd' & Hlo).
  change (prog_defmap (program_of_program lp)) with (prog_defmap lp) in Hgd'.
  inv Hlo. match goal with H : linkorder _ _ |- _ => inv H end.
  match goal with H : linkorder i1 i2 |- _ => rename H into Hi end.
  cbn in Hro, Hvo, Hne |- *. subst.
  assert (Hsz : init_data_list_size i1 <= init_data_list_size i2).
  { inv Hi; [ lia | contradiction | ]. cbn. pose proof (init_data_list_size_pos i2). lia. }
  apply Genv.find_def_symbol in Hgd' as (b' & Hfs' & Hfd).
  change (Genv.globalenv (program_of_program lp)) with (Genv.globalenv lp) in Hfs', Hfd.
  rewrite Hfs in Hfs'. injection Hfs' as <-.
  pose proof Hinit as GI. apply Genv.init_mem_characterization_gen in GI.
  specialize (GI b _ Hfd). cbn in GI. destruct GI as (RP & _).
  intros z Hz. apply RP. lia.
Qed.

(* a linked non-volatile gvar is readable over its initializer *)
Lemma lo_gvar_readable : forall (q lp : Clight.program) m id b vq,
    linkorder q lp -> Genv.init_mem lp = Some m ->
    (prog_defmap q) ! id = Some (Gvar vq) ->
    gvar_volatile vq = false -> gvar_init vq <> nil ->
    Genv.find_symbol (Genv.globalenv lp) id = Some b ->
    Mem.range_perm m b 0 (init_data_list_size (gvar_init vq)) Cur Readable.
Proof.
  intros q lp m id b vq LOq Hinit Hdm Hvo Hne Hfs.
  Local Transparent Linker_program.
  unfold linkorder, Linker_program, linkorder_program in LOq.
  destruct LOq as [LOast _].
  destruct (prog_defmap_linkorder _ _ _ _ LOast Hdm) as (gd' & Hgd' & Hlo).
  change (prog_defmap (program_of_program lp)) with (prog_defmap lp) in Hgd'.
  inv Hlo. match goal with H : linkorder _ _ |- _ => inv H end.
  match goal with H : linkorder i1 i2 |- _ => rename H into Hi end.
  cbn in Hvo, Hne |- *. subst.
  assert (Hsz : init_data_list_size i1 <= init_data_list_size i2).
  { inv Hi; [ lia | contradiction | ]. cbn. pose proof (init_data_list_size_pos i2). lia. }
  apply Genv.find_def_symbol in Hgd' as (b' & Hfs' & Hfd).
  change (Genv.globalenv (program_of_program lp)) with (Genv.globalenv lp) in Hfs', Hfd.
  rewrite Hfs in Hfs'. injection Hfs' as <-.
  pose proof Hinit as GI. apply Genv.init_mem_characterization_gen in GI.
  specialize (GI b _ Hfd). cbn in GI. destruct GI as (RP & _).
  intros z Hz. eapply Mem.perm_implies; [ apply RP; lia | ].
  unfold Genv.perm_globvar. cbn.
  repeat match goal with |- context [if ?c then _ else _] => destruct c end; first [ constructor | discriminate ].
Qed.

(* the global ids whose every TU initializer is all .bss (or absent) *)
Definition zero_ids : list ident :=
  [ level_update._gMarioStates; object_list_processor._gObjectPool;
    surface_collision._gStaticSurfacePartition;
    surface_collision._gDynamicSurfacePartition;
    (* the controller pads (game_init.c; PollFlank's ctl_w at the start) *)
    game_init._gControllerPads;
    (* osContInit.c's __osMaxControllers: 0 at boot (osContInit sets 4) *)
    libultra_osContInit.___osMaxControllers;
    (* gControllers (game_init.c): .bss *)
    mario._gControllers ].

Definition tu_zero_ok (q : Clight.program) : bool :=
  forallb (fun id => match (prog_defmap q) ! id with
                     | Some (Gvar v) => all_space (gvar_init v)
                     | _ => true
                     end) zero_ids.

Lemma tus_zero : forallb tu_zero_ok (mario.prog :: tu_rest) = true.
Proof. vm_compute. reflexivity. Qed.

Lemma zero_gvar : forall lp id v, linked12 lp -> In id zero_ids ->
    (prog_defmap lp) ! id = Some (Gvar v) -> all_space (gvar_init v) = true.
Proof.
  intros lp id v H12 Hid Hdm.
  assert (K : forall q, In q (mario.prog :: tu_rest) ->
            (prog_defmap q) ! id = Some (Gvar v) -> all_space (gvar_init v) = true).
  { intros q Hq Hqd. pose proof tus_zero as T.
    rewrite forallb_forall in T. specialize (T q Hq). unfold tu_zero_ok in T.
    rewrite forallb_forall in T. specialize (T id Hid). rewrite Hqd in T. exact T. }
  destruct (link_chain_gvar_origin tu_rest mario.prog lp id v H12 Hdm) as [Hm | (q & Hin & Hq)].
  - exact (K _ (in_eq _ _) Hm).
  - exact (K _ (in_cons _ _ _ Hin) Hq).
Qed.

Definition zeros (ch : memory_chunk) : val :=
  decode_val ch (List.map Byte (List.repeat Byte.zero (size_chunk_nat ch))).

Lemma boot_zero : forall lp m id b ch z v, linked12 lp -> Genv.init_mem lp = Some m ->
    In id zero_ids -> Genv.find_symbol (Genv.globalenv lp) id = Some b ->
    Mem.load ch m b z = Some v -> v = zeros ch.
Proof.
  intros lp m id b ch z v H12 Hinit Hid Hfs Hld.
  destruct (init_mem_load_sym_gvar lp m id b ch z v Hinit Hfs Hld) as (gv & Hdm).
  exact (init_mem_load_zero lp m id b gv ch z v Hinit Hfs Hdm (zero_gvar lp id gv H12 Hid Hdm) Hld).
Qed.

Lemma zeros_i32 : zeros Mint32 = Vint Int.zero.
Proof. reflexivity. Qed.
Lemma zeros_u16 : zeros Mint16unsigned = Vint Int.zero.
Proof. reflexivity. Qed.
Lemma zeros_s16 : zeros Mint16signed = Vint Int.zero.
Proof. reflexivity. Qed.
Lemma zeros_f32 : zeros Mfloat32 = Vsingle Float32.zero.
Proof. vm_compute. reflexivity. Qed.

(* the boot image is closed under the flat injection, for any bigger bound *)
Lemma boot_neutral : forall (lp : Clight.program) m thr, Genv.init_mem lp = Some m ->
    Ple (Mem.nextblock m) thr -> Mem.inject_neutral thr m.
Proof.
  intros lp m thr Hinit Hle.
  unfold Genv.init_mem in Hinit.
  eapply Genv.alloc_globals_neutral with (thr := thr) (ge := Genv.globalenv lp).
  all: first [ exact Hinit | exact Hle | apply Mem.empty_inject_neutral
             | (intros id b Hfs; eapply Plt_Ple_trans; [ | exact Hle ];
                eapply Genv.find_symbol_not_fresh; [ exact Hinit | exact Hfs ]) ].
Qed.

(* SafeB_syms_ok for an object-block set that starts AT genv_next
   (SpawnInit.safeb_wit_sat asks for strictly above) *)
Lemma safeb_wit_sat_le :
  forall (lp : Clight.program) (objblks : block -> Prop) (symok : ident -> Prop),
    (forall b, objblks b -> Ple (Genv.genv_next (lp_ge lp)) b) ->
    (forall id, symok id -> mem_id id non_safeb_syms = false) ->
    (forall id, mem_id id safe_ptr_syms = true -> symok id) ->
    SafeB_syms_ok lp (SafeB_wit lp objblks symok).
Proof.
  intros lp objblks symok Hfresh Hok Hgobj. split; [ | split ].
  - intros id b Hs [Hobj | (id' & Hid' & Hs')].
    + exfalso. apply (Plt_strict b).
      eapply Plt_Ple_trans; [ eapply Genv.genv_symb_range; exact Hs | apply Hfresh; exact Hobj ].
    + assert (E : id = id') by (eapply Genv.genv_vars_inj; [ exact Hs | exact Hs' ]).
      subst id'. destruct Hid' as [Hk | ->]; [ exact (Hok _ Hk) | vm_compute; reflexivity ].
  - intros b Hs. right. exists mario_actions_moving._sFloorAlignMatrix.
    split; [ right; reflexivity | exact Hs ].
  - intros id b Hg Hs. right. exists id.
    split; [ left; exact (Hgobj id Hg) | exact Hs ].
Qed.

(* widening SafeB by blocks that hold no pointer *)
Lemma mwf_real_widen : forall lp bm bc oc0 (S S' N : block -> Prop) m,
    MWF_real lp bm bc oc0 S m ->
    (forall b, S' b -> S b \/ N b) -> (forall b, S b -> S' b) ->
    (forall b, N b -> Mem.valid_block m b) ->
    (forall b ofs b' o', N b -> Mem.loadv Mptr m (Vptr b ofs) = Some (Vptr b' o') -> False) ->
    (forall ab, Genv.find_symbol (lp_ge lp) mario._gMarioAnimsBuf = Some ab -> ~ S' ab) ->
    MWF_real lp bm bc oc0 S' m.
Proof.
  intros lp bm bc oc0 S S' N m M Hsplit Hin Hval Hnp Hab.
  destruct M as ((Vbm & Vbc & Vgms & Vsafe & Vgt & Vtb & Vkt & Hnb)
                 & R1 & R2 & R3 & R4 & R5 & R6 & R7 & R8 & R9 & R10 & R11 & R12 & R13 & R14).
  refine (conj (conj Vbm (conj Vbc (conj Vgms (conj _ (conj Vgt (conj Vtb (conj Vkt Hnb)))))))
          (conj R1 (conj R2 (conj R3 (conj R4 (conj R5 (conj _ (conj _
            (conj R8 (conj R9 (conj R10 (conj R11 (conj _ (conj R13 _)))))))))))))).
  - intros b Hb. destruct (Hsplit b Hb) as [H | H]; [ exact (Vsafe _ H) | exact (Hval _ H) ].
  - intros fld delta b' o' H1 H2 H3. exact (Hin _ (R6 _ _ _ _ H1 H2 H3)).
  - intros b ofs b' o' Hb Hld. destruct (Hsplit b Hb) as [H | H].
    + exact (Hin _ (R7 _ _ _ _ H Hld)).
    + exfalso. exact (Hnp _ _ _ _ H Hld).
  - intros ab ofs b' o' Hfs Hld. exact (Hin _ (R12 _ _ _ _ Hfs Hld)).
  - intros ab Hfs. destruct (R14 ab Hfs) as (A1 & A2 & _ & A4).
    exact (conj A1 (conj A2 (conj (Hab _ Hfs) A4))).
Qed.

(* the anim list's dmaTable store, at (ab, 0), of a SafeB-if-pointer value
   (MWFReal.mwf_real_anim_cur_store at offset 0; used by the witness) *)
Lemma mwf_anim_tab_store : forall lp bm bc oc0 SafeB, bc <> bm -> forall mm mm' ab vv,
    MWF_real lp bm bc oc0 SafeB mm ->
    Genv.find_symbol (lp_ge lp) mario._gMarioAnimsBuf = Some ab ->
    (forall b o, vv = Vptr b o -> SafeB b) ->
    Mem.store Mptr mm ab 0 vv = Some mm' -> MWF_real lp bm bc oc0 SafeB mm'.
Proof.
  intros lp bm bc oc0 SafeB Hbc mm mm' ab vv M Hfs Hvv Hst.
  pose proof M as (_ & _ & _ & _ & _ & _ & _ & R7 & _ & _ & _ & _ & R12 & R13 & R14).
  destruct (R14 ab Hfs) as (Abm & Abc & Asafe & Aval).
  assert (DS : forall id gb, Genv.find_symbol (lp_ge lp) id = Some gb ->
              Pos.eqb mario._gMarioAnimsBuf id = false -> ab <> gb).
  { intros id gb Hfs2 N E. subst gb.
    eapply Genv.global_addresses_distinct; [ | exact Hfs | exact Hfs2 | reflexivity ].
    intro E. subst id. rewrite Pos.eqb_refl in N. discriminate. }
  apply (MWF_real_transfer_core lp bm bc oc0 SafeB Hbc mm mm'); [ .. | exact M ].
  - intros b Hv. eapply Mem.store_valid_block_1; eauto.
  - intros v Hld. pose proof M as (_ & R1 & _). apply R1.
    rewrite <- Hld. symmetry.
    eapply Mem.load_store_other; [ exact Hst | left; congruence ].
  - intros ch1 b ofs v Hrow Hld.
    rewrite <- Hld. symmetry.
    eapply Mem.load_store_other; [ exact Hst | left ].
    destruct Hrow as [ [Eb _] | [ Eb | [ Hfs2 | [ Hfs2 | [ Hfs2 | Hkt ] ] ] ] ].
    + subst b. congruence.
    + subst b. congruence.
    + intro E. exact (DS _ _ Hfs2 eq_refl (eq_sym E)).
    + intro E. exact (DS _ _ Hfs2 eq_refl (eq_sym E)).
    + intro E. exact (DS _ _ Hfs2 eq_refl (eq_sym E)).
    + destruct Hkt as (gid2 & Hg2 & Hfs2). intro E. subst b.
      eapply Genv.global_addresses_distinct; [ | exact Hfs | exact Hfs2 | reflexivity ].
      intros <-. vm_compute in Hg2. discriminate Hg2.
  - intros b ofs b' o' Hs Hld.
    apply (R7 b ofs b' o' Hs).
    cbn in Hld |- *. rewrite <- Hld. symmetry.
    eapply Mem.load_store_other; [ exact Hst | left ].
    intro E. subst b. exact (Asafe Hs).
  - intros ab' ofs b' o' Hfs' Hld.
    rewrite Hfs in Hfs'. injection Hfs' as <-.
    destruct (zeq ofs 0) as [-> | Hne0].
    + rewrite (Mem.load_store_same _ _ _ _ _ _ Hst) in Hld.
      injection Hld as Ev.
      destruct vv; cbn in Ev; try discriminate Ev.
      injection Ev as <- <-. exact (Hvv _ _ eq_refl).
    + destruct (zle (ofs + 4) 0) as [Hl | Hl].
      * apply (R12 ab ofs b' o' Hfs). rewrite <- Hld. symmetry.
        eapply Mem.load_store_other; [ exact Hst | right; left; exact Hl ].
      * destruct (zle (0 + 4) ofs) as [Hr | Hr].
        -- apply (R12 ab ofs b' o' Hfs). rewrite <- Hld. symmetry.
           eapply Mem.load_store_other; [ exact Hst | right; right; exact Hr ].
        -- exfalso. apply Mem.load_valid_access in Hld.
           destruct Hld as [_ Hal]. change (align_chunk Mptr) with 4 in Hal.
           destruct Hal as [k Hk]. lia.
  - intros ab' bt ot mb mo Hfs' H1 H2.
    rewrite Hfs in Hfs'. injection Hfs' as <-.
    apply (R13 ab bt ot mb mo Hfs).
    + rewrite <- H1. symmetry.
      eapply Mem.load_store_other; [ exact Hst | right; right; change (size_chunk Mptr) with 4; lia ].
    + rewrite <- H2. symmetry.
      eapply Mem.load_store_other; [ exact Hst | left; congruence ].
Qed.

(* ---------------------------------------------------------------------- *)
(* Part 2: the witness memory.                                             *)
(* ---------------------------------------------------------------------- *)

Lemma symne : forall (lp : Clight.program) id1 id2 b1 b2,
    Genv.find_symbol (lp_ge lp) id1 = Some b1 ->
    Genv.find_symbol (lp_ge lp) id2 = Some b2 ->
    Pos.eqb id1 id2 = false -> b1 <> b2.
Proof.
  intros lp id1 id2 b1 b2 H1 H2 E.
  eapply Genv.global_addresses_distinct; [ | exact H1 | exact H2 ].
  intros ->. rewrite Pos.eqb_refl in E. discriminate.
Qed.

(* m's collision partitions and pool are the ones WMotR's real terrain load
   leaves, started from the level-entry memory m_ent: main_pool_init's
   post-state on a fresh pool block (TRUST 3.6), then the generated
   alloc_surface_pools and load_area_terrain(1, wmotr_seg7_collision, NULL,
   NULL) -- an execution of both under the FPU floor's value clause
   (FpuValue.sqrtf_value, TRUST 3.5).  reset_red_coins_collected runs its
   real body (ingame_menu.c linked, 2026-10-22). *)
Definition terrain_loaded (lp : Clight.program) (m_ent m : mem) : Prop :=
  exists P0 bpl P bcol L1 Lm,
    Mem.alloc m_ent 0 POOL = (P0, bpl)
    /\ (exists s1 s2 s3 s4 s5,
          sym (lp_ge lp) "sPoolStart"%string = Some s1 /\ sym (lp_ge lp) "sPoolEnd"%string = Some s2
          /\ sym (lp_ge lp) "sPoolFreeSpace"%string = Some s3
          /\ sym (lp_ge lp) "sPoolListHeadL"%string = Some s4
          /\ sym (lp_ge lp) "sPoolListHeadR"%string = Some s5
          /\ apply_writes P0 (pool_writes s1 s2 s3 s4 s5 bpl) 0 = inl P)
    /\ sym (lp_ge lp) "wmotr_seg7_collision"%string = Some bcol
    /\ (sqrtf_value ->
          exists t1 v1 t2 v2,
            eval_funcall function_entry2 (lp_ge lp) P
              (Internal surface_load.f_alloc_surface_pools) [] t1 L1 v1
            /\ eval_funcall function_entry2 (lp_ge lp) L1
                 (Internal surface_load.f_load_area_terrain) (terr_args bcol) t2 Lm v2)
    /\ (forall ch b z,
          (b = bpl \/ exists pid, In pid part_ids /\ Genv.find_symbol (lp_ge lp) pid = Some b) ->
          Mem.load ch m b z = Mem.load ch Lm b z).

(* non-vacuity of the load: the loader allocated WMotR's 1352 surfaces *)
Definition nsurf_is (lp : Clight.program) (m : mem) : Prop :=
  exists bn n, sym (lp_ge lp) "gSurfacesAllocated"%string = Some bn
    /\ Mem.load Mint32 m bn 0 = Some (Vint n) /\ Int.signed n = NSURF.

(* NON-VACUITY OF THE FRAME (2026-10-22): from m, with A not pressed, one
   real execute_mario_action frame executes (the externals answered as in
   BootRun: sqrtf by the FPU floor's value clause; the audio calls run
   their real linked bodies), and Mario
   is still in ACT_SPAWN_NO_SPIN_AIRBORNE afterwards *)
Definition frame_runs (lp : Clight.program) (bm : block) (m : mem) : Prop :=
  sqrtf_value ->
  AGates.a_pressed_real bm m = false
  /\ exists bo t m' v,
       eval_funcall function_entry2 (lp_ge lp) m (Internal mario.f_execute_mario_action)
         [Vptr bo Ptrofs.zero] t m' v
       /\ Mem.load Mint32 m' bm 12 = Some (Vint (Int.repr BootRun.ACT_SPAWN_NO_SPIN_AIRBORNE)).

(* the witness's init_mario_from_save_file cells are that function's: run
   from the boot image, the function the link resolves it to ends in a
   memory with the same nextblock whose every block holds exactly the bytes
   of the boot image after ifs_writes (the cells the witness stores) *)
Definition ifs_tether (lp : Clight.program) (m0 : mem) (bm bc : block) : Prop :=
  sqrtf_value ->
  exists ab bsi bpcs bbs bhud fd t mi v mx,
    Genv.find_symbol (lp_ge lp) mario._gMarioAnimsBuf = Some ab
    /\ sym (lp_ge lp) "gPlayerSpawnInfos"%string = Some bsi
    /\ sym (lp_ge lp) "gPlayerCameraState"%string = Some bpcs
    /\ sym (lp_ge lp) "gBodyStates"%string = Some bbs
    /\ sym (lp_ge lp) "gHudDisplay"%string = Some bhud
    /\ (exists bi, Genv.find_symbol (lp_ge lp) mario._init_mario_from_save_file = Some bi
                  /\ Genv.find_funct (lp_ge lp) (Vptr bi Ptrofs.zero) = Some fd)
    /\ eval_funcall function_entry2 (lp_ge lp) m0 fd [] t mi v
    /\ apply_writes m0 (ifs_writes bm bc ab bsi bpcs bbs bhud) 0 = inl mx
    /\ Mem.nextblock mi = Mem.nextblock m0
    /\ forall b o, Plt b (Mem.nextblock m0) ->
         ZMap.get o ((Mem.mem_contents mi) !! b) = ZMap.get o ((Mem.mem_contents mx) !! b).

(* gCurrCourseNum on the witness is what the REAL lvl_set_current_level
   stores: run from the boot image with (0, LEVEL_WMOTR) -- the level
   script's CALL(0, lvl_set_current_level), levels/menu/script.c:61 -- it
   ends with gCurrCourseNum = COURSE_WMOTR (23), the value m carries
   (CourseRun.course_runs: no external answered, unconditional) *)
Definition course_set (lp : Clight.program) (m0 m : mem) : Prop :=
  exists bC t m' v,
    Genv.find_symbol (lp_ge lp) level_update._gCurrCourseNum = Some bC
    /\ Mem.load Mint16signed m bC 0 = Some (Vint (Int.repr CourseRun.COURSE_WMOTR))
    /\ eval_funcall function_entry2 (lp_ge lp) m0
         (Internal level_update.f_lvl_set_current_level) CourseRun.lscl_args t m' v
    /\ Mem.load Mint16signed m' bC 0 = Some (Vint (Int.repr CourseRun.COURSE_WMOTR)).

Section Witness.
  Variable lp : Clight.program.
  Hypothesis H12 : linked12 lp.
  Variable m0 : mem.
  Hypothesis Hinit : Genv.init_mem lp = Some m0.
  Variables bm bc : block.
  Hypothesis Hbm : Genv.find_symbol (lp_ge lp) level_update._gMarioStates = Some bm.
  Hypothesis Hbc : Genv.find_symbol (lp_ge lp) mario._gControllers = Some bc.

  Lemma LO_gi : linkorder game_init.prog lp.
  Proof.
    exact (link_chain_linkorder_in _ _ _ _ (in_cons _ _ _ (in_cons _ _ _ (in_cons _ _ _ (in_cons _ _ _ (in_cons _ _ _ (in_cons _ _ _ (in_cons _ _ _ (in_cons _ _ _ (in_cons _ _ _ (in_cons _ _ _ (in_cons _ _ _ (in_cons _ _ _ (in_cons _ _ _ (in_cons _ _ _ (in_eq _ _))))))))))))))) H12).
  Qed.
  Lemma LO_olp : linkorder object_list_processor.prog lp.
  Proof.
    exact (link_chain_linkorder_in _ _ _ _ (in_cons _ _ _ (in_cons _ _ _ (in_cons _ _ _ (in_cons _ _ _ (in_cons _ _ _ (in_cons _ _ _ (in_cons _ _ _ (in_cons _ _ _ (in_cons _ _ _ (in_cons _ _ _ (in_cons _ _ _ (in_cons _ _ _ (in_cons _ _ _ (in_cons _ _ _ (in_cons _ _ _ (in_eq _ _)))))))))))))))) H12).
  Qed.

  Lemma genv_next_eq : Genv.genv_next (lp_ge lp) = Mem.nextblock m0.
  Proof. exact (Genv.init_mem_genv_next _ Hinit). Qed.

  Lemma sym_old : forall id b, Genv.find_symbol (lp_ge lp) id = Some b -> Plt b (Mem.nextblock m0).
  Proof. intros id b H. rewrite <- genv_next_eq. eapply Genv.genv_symb_range; exact H. Qed.

  Lemma fresh_not_sym : forall id b b', Genv.find_symbol (lp_ge lp) id = Some b ->
      Ple (Mem.nextblock m0) b' -> b <> b'.
  Proof.
    intros id b b' H Hle E. subst b'. pose proof (sym_old _ _ H) as Hp.
    exact (Plt_strict _ (Plt_Ple_trans _ _ _ Hp Hle)).
  Qed.

  Ltac dm := vm_compute; reflexivity.

  (* the definers' entries *)
  Lemma dm_gms : (prog_defmap level_update.prog) ! level_update._gMarioStates
                 = Some (Gvar level_update.v_gMarioStates).
  Proof. dm. Qed.
  Lemma dm_ab : (prog_defmap game_init.prog) ! game_init._gMarioAnimsBuf
                = Some (Gvar game_init.v_gMarioAnimsBuf).
  Proof. dm. Qed.
  Lemma dm_pool : (prog_defmap object_list_processor.prog) ! object_list_processor._gObjectPool
                  = Some (Gvar object_list_processor.v_gObjectPool).
  Proof. dm. Qed.
  Lemma dm_fi : (prog_defmap object_list_processor.prog)
                  ! object_list_processor._gFindFloorIncludeSurfaceIntangible
                = Some (Gvar object_list_processor.v_gFindFloorIncludeSurfaceIntangible).
  Proof. dm. Qed.
  Lemma dm_miss : (prog_defmap object_list_processor.prog)
                    ! object_list_processor._gNumFindFloorMisses
                  = Some (Gvar object_list_processor.v_gNumFindFloorMisses).
  Proof. dm. Qed.
  Lemma dm_calls : (prog_defmap object_list_processor.prog) ! object_list_processor._gNumCalls
                   = Some (Gvar object_list_processor.v_gNumCalls).
  Proof. dm. Qed.
  Lemma dm_sin : (prog_defmap mario.prog) ! mario._gSineTable = Some (Gvar mario.v_gSineTable).
  Proof. dm. Qed.
  Lemma dm_iom : (prog_defmap memory.prog) ! memory._gDmaIoMesg = Some (Gvar memory.v_gDmaIoMesg).
  Proof. dm. Qed.
  Lemma dm_mq : (prog_defmap memory.prog) ! memory._gDmaMesgQueue
                = Some (Gvar memory.v_gDmaMesgQueue).
  Proof. dm. Qed.
  Lemma dm_rm : (prog_defmap memory.prog) ! memory._gMainReceivedMesg
                = Some (Gvar memory.v_gMainReceivedMesg).
  Proof. dm. Qed.
  Lemma dm_lak : (prog_defmap camera.prog) ! camera._gLakituState
                = Some (Gvar camera.v_gLakituState).
  Proof. dm. Qed.
  (* the audio globals play_sound / set_sound_moving_speed write (walk regions) *)
  Lemma dm_sr : (prog_defmap audio_external.prog) ! audio_external._sSoundRequests
                = Some (Gvar audio_external.v_sSoundRequests).
  Proof. dm. Qed.
  Lemma dm_src : (prog_defmap audio_external.prog) ! audio_external._sSoundRequestCount
                = Some (Gvar audio_external.v_sSoundRequestCount).
  Proof. dm. Qed.
  Lemma dm_sms : (prog_defmap audio_external.prog) ! audio_external._sSoundMovingSpeed
                = Some (Gvar audio_external.v_sSoundMovingSpeed).
  Proof. dm. Qed.
  (* sFloorAlignMatrix (mario_actions_moving.c): the only non-NULL target
     of Mario's gfx.throwMatrix (FfWorld.ffw's last conjunct) *)
  Lemma dm_fam : (prog_defmap mario_actions_moving.prog) ! mario_actions_moving._sFloorAlignMatrix
                = Some (Gvar mario_actions_moving.v_sFloorAlignMatrix).
  Proof. dm. Qed.

  (* the collision partitions' definer, surface_load.c (linked 2026-10-22):
     6144 bytes each (16 x 16 cells x 3 lists x one 8-byte SurfaceNode) *)
  Lemma dm_spart : (prog_defmap surface_load.prog) ! surface_collision._gStaticSurfacePartition
                   = Some (Gvar surface_load.v_gStaticSurfacePartition).
  Proof. dm. Qed.
  Lemma dm_dpart : (prog_defmap surface_load.prog) ! surface_collision._gDynamicSurfacePartition
                   = Some (Gvar surface_load.v_gDynamicSurfacePartition).
  Proof. dm. Qed.
  Lemma part_size : init_data_list_size (gvar_init surface_load.v_gStaticSurfacePartition) = 6144
                    /\ init_data_list_size (gvar_init surface_load.v_gDynamicSurfacePartition) = 6144.
  Proof. split; reflexivity. Qed.

  Lemma ex_sym : forall q id gd, linkorder q lp -> (prog_defmap q) ! id = Some gd ->
      exists b, Genv.find_symbol (lp_ge lp) id = Some b.
  Proof. intros q id gd LO H. exact (linkorder_resolves_symbol lp q id gd LO H). Qed.

  (* write permission from the definer *)
  Lemma wr_sym : forall q id vq b, linkorder q lp -> (prog_defmap q) ! id = Some (Gvar vq) ->
      gvar_readonly vq = false -> gvar_volatile vq = false -> gvar_init vq <> nil ->
      Genv.find_symbol (lp_ge lp) id = Some b ->
      Mem.range_perm m0 b 0 (init_data_list_size (gvar_init vq)) Cur Writable.
  Proof. intros. eapply lo_gvar_writable; eassumption. Qed.

  Lemma valid_ex : forall ch b z lo hi, Mem.range_perm m0 b lo hi Cur Writable ->
      lo <= z -> z + size_chunk ch <= hi -> (align_chunk ch | z) ->
      exists v, Mem.load ch m0 b z = Some v.
  Proof.
    intros ch b z lo hi RP H1 H2 Ha.
    destruct (Mem.valid_access_load m0 ch b z) as (v & Hv); [ | exists v; exact Hv ].
    split; [ | exact Ha ].
    intros x Hx. eapply Mem.perm_implies; [ apply RP; lia | constructor ].
  Qed.

  (* ==================================================================== *)
  (* The construction, as hypotheses: three allocations, eight stores.    *)
  (* ==================================================================== *)
  Section Steps.
    Variables ab bo bfi bmiss bcalls bsin biom bmq brm blk bsr bsrc bsms bfa : block.
    Hypothesis Hab : Genv.find_symbol (lp_ge lp) mario._gMarioAnimsBuf = Some ab.
    Hypothesis Hbo : Genv.find_symbol (lp_ge lp) object_list_processor._gObjectPool = Some bo.
    Hypothesis Hfi : Genv.find_symbol (lp_ge lp)
                       surface_collision._gFindFloorIncludeSurfaceIntangible = Some bfi.
    Hypothesis Hmiss : Genv.find_symbol (lp_ge lp) surface_collision._gNumFindFloorMisses = Some bmiss.
    Hypothesis Hcalls : Genv.find_symbol (lp_ge lp) surface_collision._gNumCalls = Some bcalls.
    Hypothesis Hsin : Genv.find_symbol (lp_ge lp) mario._gSineTable = Some bsin.
    Hypothesis Hiom : Genv.find_symbol (lp_ge lp) memory._gDmaIoMesg = Some biom.
    Hypothesis Hmq : Genv.find_symbol (lp_ge lp) memory._gDmaMesgQueue = Some bmq.
    Hypothesis Hrm : Genv.find_symbol (lp_ge lp) memory._gMainReceivedMesg = Some brm.
    Hypothesis Hlk : Genv.find_symbol (lp_ge lp) camera._gLakituState = Some blk.
    Hypothesis Hsr : Genv.find_symbol (lp_ge lp) audio_external._sSoundRequests = Some bsr.
    Hypothesis Hsrc : Genv.find_symbol (lp_ge lp) audio_external._sSoundRequestCount = Some bsrc.
    Hypothesis Hsms : Genv.find_symbol (lp_ge lp) audio_external._sSoundMovingSpeed = Some bsms.
    Hypothesis Hfa : Genv.find_symbol (lp_ge lp) mario_actions_moving._sFloorAlignMatrix = Some bfa.
    Variables bw bL : block.
    Hypothesis Hbw : Genv.find_symbol (lp_ge lp) level_update._sWarpDest = Some bw.
    Hypothesis HbL : Genv.find_symbol (lp_ge lp) level_update._gCurrLevelNum = Some bL.

    (* the level entry, run as real code from the boot image (EntryWarp):
       initiate_warp(LEVEL_WMOTR, 1, 0x0A, 0)'s five sWarpDest stores, then
       warp_level's head gCurrLevelNum = sWarpDest.levelNum *)
    Variables (e1 e2 e3 e4 e5 e6 : mem).
    Hypothesis E1 : Mem.store Mint8unsigned m0 bw 0 (Vint (Int.repr 1)) = Some e1.
    Hypothesis E2 : Mem.store Mint8unsigned e1 bw 1 (Vint (Int.repr LEVEL_WMOTR)) = Some e2.
    Hypothesis E3 : Mem.store Mint8unsigned e2 bw 2 (Vint (Int.repr WARP_AREA)) = Some e3.
    Hypothesis E4 : Mem.store Mint8unsigned e3 bw 3 (Vint (Int.repr WARP_NODE)) = Some e4.
    Hypothesis E5 : Mem.store Mint32 e4 bw 4 (Vint Int.zero) = Some e5.
    Hypothesis E6 : Mem.store Mint16signed e5 bL 0 (Vint (Int.repr LEVEL_WMOTR)) = Some e6.

    (* the level's terrain (StartTerrain), as the level script loads it:
       the main pool in main_pool_init's post-state (TRUST 3.6), then the
       generated alloc_surface_pools and load_area_terrain(1,
       wmotr_seg7_collision, NULL, NULL), run by the sound interpreter;
       old_ok / frag_ok are the footprint and pointer checks on the result *)
    Variables (P0 P L1 Lm : mem) (bpl s1 s2 s3 s4 s5 bcol bn : block)
      (t1 t2 : trace) (v1 v2 : val).
    Hypothesis AP : Mem.alloc e6 0 POOL = (P0, bpl).
    Hypothesis PW : apply_writes P0 (pool_writes s1 s2 s3 s4 s5 bpl) 0 = inl P.
    Hypothesis Hs1 : sym (lp_ge lp) "sPoolStart"%string = Some s1.
    Hypothesis Hs2 : sym (lp_ge lp) "sPoolEnd"%string = Some s2.
    Hypothesis Hs3 : sym (lp_ge lp) "sPoolFreeSpace"%string = Some s3.
    Hypothesis Hs4 : sym (lp_ge lp) "sPoolListHeadL"%string = Some s4.
    Hypothesis Hs5 : sym (lp_ge lp) "sPoolListHeadR"%string = Some s5.
    Hypothesis Hcol : sym (lp_ge lp) "wmotr_seg7_collision"%string = Some bcol.
    Hypothesis Hbn : sym (lp_ge lp) "gSurfacesAllocated"%string = Some bn.
    Hypothesis RA : ex_call (lp_ge lp) TerrainRun.world FUEL P
                      (Internal surface_load.f_alloc_surface_pools) [] = Done (t1, L1, v1).
    Hypothesis RT : ex_call (lp_ge lp) TerrainRun.world FUEL L1
                      (Internal surface_load.f_load_area_terrain) (terr_args bcol) = Done (t2, Lm, v2).
    Hypothesis OK : old_ok (lp_ge lp) e6 Lm = true.
    Hypothesis FR : frag_ok (lp_ge lp) bpl Lm = true.

    Variables (m1 m2 m2b m3 m3a m3b m4 m5 m6 m7 m8 m9 m10 ms m11 : mem) (bt bs bar bd : block).
    Hypothesis A1 : Mem.alloc Lm 0 16384 = (m1, bt).
    Hypothesis A2 : Mem.alloc m1 0 48 = (m2, bs).
    Hypothesis A3 : Mem.alloc m2 0 60 = (m2b, bar).
    (* the anim DMA table stand-in (setup_game_memory's table is ROM data) *)
    Hypothesis A4 : Mem.alloc m2b 0 1680 = (m3, bd).
    (* the entry height (WMotREntry): init_mario's pos := startPos and
       gfx.pos := pos, at the airborne warp's y *)
    Hypothesis S1a : Mem.store Mfloat32 m3 bm 64 (Vsingle ENTRY_Y) = Some m3a.
    Hypothesis S1b : Mem.store Mfloat32 m3a bo 36 (Vsingle ENTRY_Y) = Some m3b.
    Hypothesis S1 : Mem.store Mint16signed m3b bs 0 (Vint Int.zero) = Some m4.
    (* the entry action: set_mario_initial_action's MARIO_SPAWN_AIRBORNE case *)
    Hypothesis S2 : Mem.store Mint32 m4 bm 12 (Vint ACT_SPAWN_NO_SPIN_AIRBORNE) = Some m5.
    Hypothesis S3 : Mem.store Mint32 m5 bm 104 (Vptr bs Ptrofs.zero) = Some m6.
    Hypothesis S4 : Mem.store Mint32 m6 bm 144 (Vptr bar Ptrofs.zero) = Some m7.
    Hypothesis S5 : Mem.store Mint32 m7 bm 156 (Vptr bc Ptrofs.zero) = Some m8.
    Hypothesis S6 : Mem.store Mint32 m8 bm 160 (Vptr ab Ptrofs.zero) = Some m9.
    Hypothesis S7 : Mem.store Mint32 m9 bm 136 (Vptr bo Ptrofs.zero) = Some m10.
    Hypothesis S8 : Mem.store Mint32 m10 ab 8 (Vptr bt Ptrofs.zero) = Some ms.
    (* init_mario_from_save_file's nonzero cells (the same bytes the real
       function writes on the boot image: StartTerrain.ifs_ok), the area's
       terrainType (WMotR's TERRAIN_TYPE), the DMA table's count and the
       anim buffer's header *)
    Variables (bsi bpcs bbs bhud bC bga bpads : block)
      (z1 z2 z3 z4 z5 z6 z7 z8 z9 z10a z10 z11 z12 z13 z14 z15 z16 z17 z18 : mem).
    Hypothesis Hsi : sym (lp_ge lp) "gPlayerSpawnInfos"%string = Some bsi.
    Hypothesis Hpcs : sym (lp_ge lp) "gPlayerCameraState"%string = Some bpcs.
    Hypothesis Hbbs : sym (lp_ge lp) "gBodyStates"%string = Some bbs.
    Hypothesis Hhud : sym (lp_ge lp) "gHudDisplay"%string = Some bhud.
    Hypothesis HcC : Genv.find_symbol (lp_ge lp) level_update._gCurrCourseNum = Some bC.
    Hypothesis Hga : Genv.find_symbol (lp_ge lp) game_init._gMarioAnims = Some bga.
    Hypothesis Hpads : Genv.find_symbol (lp_ge lp) game_init._gControllerPads = Some bpads.
    Hypothesis Z1 : Mem.store Mint32 ms bm 140 (Vptr bsi Ptrofs.zero) = Some z1.
    Hypothesis Z2 : Mem.store Mint32 z1 bm 148 (Vptr bpcs Ptrofs.zero) = Some z2.
    Hypothesis Z3 : Mem.store Mint32 z2 bm 152 (Vptr bbs Ptrofs.zero) = Some z3.
    Hypothesis Z4 : Mem.store Mint8signed z3 bm 173 (Vint (Int.repr 4)) = Some z4.
    Hypothesis Z5 : Mem.store Mint16signed z4 bm 174 (Vint (Int.repr 2176)) = Some z5.
    Hypothesis Z6 : Mem.store Mint16signed z5 bm 176 (Vint (Int.repr 189)) = Some z6.
    Hypothesis Z7 : Mem.store Mint16signed z6 bhud 6 (Vint (Int.repr 8)) = Some z7.
    Hypothesis Z8 : Mem.store Mint16unsigned z7 bar 2 (Vint (Int.repr TERRAIN_SNOW)) = Some z8.
    (* the DMA table: the boot image's gMarioAnims header, srcAddr :=
       &gMarioAnims (StartTerrain.tab_writes); the list's dmaTable and
       currentAddr (the animation the first frame sets is the loaded one) *)
    Hypothesis Z9 : apply_writes z8 (tab_writes m0 bd bga) 0 = inl z9.
    Hypothesis Z10a : Mem.store Mint32 z9 ab 0 (Vptr bd Ptrofs.zero) = Some z10a.
    Hypothesis Z10 : Mem.store Mint32 z10a ab 4 (cur_addr m0 bga) = Some z10.
    Hypothesis Z11 : Mem.store Mint32 z10 bt 0 (Vint Int.zero) = Some z11.
    Hypothesis Z12 : Mem.store Mint32 z11 bt 4 (Vint Int.zero) = Some z12.
    Hypothesis Z13 : Mem.store Mint32 z12 bt 8 (Vint Int.zero) = Some z13.
    Hypothesis Z14 : Mem.store Mint32 z13 bt 12 (Vint Int.zero) = Some z14.
    Hypothesis Z15 : Mem.store Mint32 z14 bt 16 (Vint Int.zero) = Some z15.
    Hypothesis Z16 : Mem.store Mint32 z15 bt 20 (Vint Int.zero) = Some z16.
    (* gCurrCourseNum := COURSE_WMOTR (course_set: the real
       lvl_set_current_level stores exactly this) *)
    Hypothesis Z17 : Mem.store Mint16signed z16 bC 0 (Vint (Int.repr CourseRun.COURSE_WMOTR)) = Some z17.
    (* gControllers[0].controllerData := &gControllerPads[0] (the real
       init_controllers' store at boot, port 0 plugged in) *)
    Hypothesis ZC : Mem.store Mint32 z17 bc 24 (Vptr bpads Ptrofs.zero) = Some z18.
    (* sWarpDest.type := WARP_TYPE_NOT_WARPING: init_mario_after_warp's last
       store (level_update.c:397), which ends warp_level (2026-10-24) *)
    Hypothesis Z18 : Mem.store Mint8unsigned z18 bw 0 (Vint Int.zero) = Some m11.
    (* the list checks on the witness itself *)
    Hypothesis WP : wff_parts WFUEL (lp_ge lp) bpl m11 = true.
    Hypothesis PO : parts_ok WFUEL (lp_ge lp) m11 = true.
    Hypothesis NS : nsurf_ok m11 bn = true.
    Hypothesis IF : ifs_ok (lp_ge lp) m0 bm bc ab bsi bpcs bbs bhud = true.
    Hypothesis FO : frame_ok (lp_ge lp) bm bo m11 = true.
    Hypothesis TC : tab_chk m11 bd bga = true.
    Hypothesis GC : ga_chk m11 bga = true.

    (* ---- blocks ---- *)
    Lemma nb_e : Mem.nextblock e6 = Mem.nextblock m0.
    Proof.
      rewrite (Mem.nextblock_store _ _ _ _ _ _ E6), (Mem.nextblock_store _ _ _ _ _ _ E5),
        (Mem.nextblock_store _ _ _ _ _ _ E4), (Mem.nextblock_store _ _ _ _ _ _ E3),
        (Mem.nextblock_store _ _ _ _ _ _ E2), (Mem.nextblock_store _ _ _ _ _ _ E1).
      reflexivity.
    Qed.
    Lemma bpl_eq : bpl = Mem.nextblock m0.
    Proof. rewrite (Mem.alloc_result _ _ _ _ _ AP). exact nb_e. Qed.
    (* the load keeps every old block's permissions (InterpFrame.ex_keep) *)
    Lemma keep_PL : acc_keep P0 Lm.
    Proof.
      refine (acc_keep_trans _ _ _ (apply_writes_keep _ _ _ _ PW) _).
      refine (acc_keep_trans _ _ _ (ex_call_keep _ _ world_keep _ _ _ _ _ _ _ RA) _).
      exact (ex_call_keep _ _ world_keep _ _ _ _ _ _ _ RT).
    Qed.
    Lemma keep_eL : acc_keep e6 Lm.
    Proof. exact (acc_keep_trans _ _ _ (alloc_keep _ _ _ _ _ AP) keep_PL). Qed.
    Definition NL : block := Mem.nextblock Lm.
    Lemma nb0_NL : Plt (Mem.nextblock m0) NL.
    Proof.
      unfold NL. destruct keep_PL as (Hle & _).
      rewrite (Mem.nextblock_alloc _ _ _ _ _ AP), nb_e in Hle. unfold Ple, Plt in *. lia.
    Qed.
    Lemma bpl_lt : Plt bpl NL.
    Proof. rewrite bpl_eq. exact nb0_NL. Qed.
    Lemma bpl_ge : Ple (Mem.nextblock m0) bpl.
    Proof. rewrite bpl_eq. apply Ple_refl. Qed.
    Lemma bt_eq : bt = NL.
    Proof. exact (Mem.alloc_result _ _ _ _ _ A1). Qed.
    Lemma bs_eq : bs = Pos.succ NL.
    Proof. rewrite (Mem.alloc_result _ _ _ _ _ A2), (Mem.nextblock_alloc _ _ _ _ _ A1). reflexivity. Qed.
    Lemma bar_eq : bar = Pos.succ (Pos.succ NL).
    Proof.
      rewrite (Mem.alloc_result _ _ _ _ _ A3), (Mem.nextblock_alloc _ _ _ _ _ A2),
        (Mem.nextblock_alloc _ _ _ _ _ A1). reflexivity.
    Qed.
    Lemma bd_eq : bd = Pos.succ (Pos.succ (Pos.succ NL)).
    Proof.
      rewrite (Mem.alloc_result _ _ _ _ _ A4), (Mem.nextblock_alloc _ _ _ _ _ A3),
        (Mem.nextblock_alloc _ _ _ _ _ A2), (Mem.nextblock_alloc _ _ _ _ _ A1). reflexivity.
    Qed.
    Lemma nb3 : Mem.nextblock m3 = Pos.succ (Pos.succ (Pos.succ (Pos.succ NL))).
    Proof.
      rewrite (Mem.nextblock_alloc _ _ _ _ _ A4),
        (Mem.nextblock_alloc _ _ _ _ _ A3), (Mem.nextblock_alloc _ _ _ _ _ A2),
        (Mem.nextblock_alloc _ _ _ _ _ A1). reflexivity.
    Qed.
    Ltac znb := rewrite (Mem.nextblock_store _ _ _ _ _ _ Z18), (Mem.nextblock_store _ _ _ _ _ _ ZC), (Mem.nextblock_store _ _ _ _ _ _ Z17), (Mem.nextblock_store _ _ _ _ _ _ Z16), (Mem.nextblock_store _ _ _ _ _ _ Z15),
        (Mem.nextblock_store _ _ _ _ _ _ Z14), (Mem.nextblock_store _ _ _ _ _ _ Z13),
        (Mem.nextblock_store _ _ _ _ _ _ Z12), (Mem.nextblock_store _ _ _ _ _ _ Z11),
        (Mem.nextblock_store _ _ _ _ _ _ Z10), (Mem.nextblock_store _ _ _ _ _ _ Z10a), (apply_writes_nb _ _ _ _ Z9),
        (Mem.nextblock_store _ _ _ _ _ _ Z8), (Mem.nextblock_store _ _ _ _ _ _ Z7),
        (Mem.nextblock_store _ _ _ _ _ _ Z6), (Mem.nextblock_store _ _ _ _ _ _ Z5),
        (Mem.nextblock_store _ _ _ _ _ _ Z4), (Mem.nextblock_store _ _ _ _ _ _ Z3),
        (Mem.nextblock_store _ _ _ _ _ _ Z2), (Mem.nextblock_store _ _ _ _ _ _ Z1).
    Lemma nb11 : Mem.nextblock m11 = Mem.nextblock m3.
    Proof.
      znb.
      rewrite (Mem.nextblock_store _ _ _ _ _ _ S8), (Mem.nextblock_store _ _ _ _ _ _ S7),
        (Mem.nextblock_store _ _ _ _ _ _ S6), (Mem.nextblock_store _ _ _ _ _ _ S5),
        (Mem.nextblock_store _ _ _ _ _ _ S4), (Mem.nextblock_store _ _ _ _ _ _ S3),
        (Mem.nextblock_store _ _ _ _ _ _ S2), (Mem.nextblock_store _ _ _ _ _ _ S1),
        (Mem.nextblock_store _ _ _ _ _ _ S1b), (Mem.nextblock_store _ _ _ _ _ _ S1a).
      reflexivity.
    Qed.

    Lemma fresh_ge : forall b, b = bt \/ b = bs \/ b = bar -> Ple (Mem.nextblock m0) b.
    Proof.
      intros b [-> | [-> | ->]]; [ rewrite bt_eq | rewrite bs_eq | rewrite bar_eq ];
        pose proof nb0_NL; unfold Ple, Plt in *; lia.
    Qed.
    Lemma fresh_lt : forall b, b = bt \/ b = bs \/ b = bar -> Plt b (Mem.nextblock m11).
    Proof.
      intros b H. rewrite nb11, nb3.
      destruct H as [-> | [-> | ->]]; [ rewrite bt_eq | rewrite bs_eq | rewrite bar_eq ];
        unfold Plt; lia.
    Qed.
    Lemma bt_bs : bt <> bs.
    Proof. rewrite bt_eq, bs_eq. intro E. lia. Qed.
    Lemma bt_bar : bt <> bar.
    Proof. rewrite bt_eq, bar_eq. intro E. lia. Qed.
    Lemma bs_bar : bs <> bar.
    Proof. rewrite bs_eq, bar_eq. intro E. lia. Qed.
    Lemma bt_bd : bt <> bd.
    Proof. rewrite bt_eq, bd_eq. intro E. lia. Qed.
    Lemma bs_bd : bs <> bd.
    Proof. rewrite bs_eq, bd_eq. intro E. lia. Qed.
    Lemma bar_bd : bar <> bd.
    Proof. rewrite bar_eq, bd_eq. intro E. lia. Qed.
    Lemma bd_ge : Ple (Mem.nextblock m0) bd.
    Proof. rewrite bd_eq. pose proof nb0_NL. unfold Ple, Plt in *. lia. Qed.
    Lemma bd_lt : Plt bd (Mem.nextblock m11).
    Proof. rewrite nb11, nb3, bd_eq. unfold Plt. lia. Qed.
    Lemma sym_ne_bd : forall id b, Genv.find_symbol (lp_ge lp) id = Some b -> b <> bd.
    Proof. intros id b H. exact (fresh_not_sym id b bd H bd_ge). Qed.
    Lemma bpl_bd : bpl <> bd.
    Proof. rewrite bd_eq. pose proof bpl_lt. intro E. unfold Plt in *. lia. Qed.
    (* the new cells' symbols *)
    Lemma sym_lt' : forall s b, sym (lp_ge lp) s = Some b -> Plt b (Mem.nextblock m0).
    Proof. intros s b H. exact (sym_old _ _ H). Qed.
    Lemma sym_ne_fresh : forall id b b', Genv.find_symbol (lp_ge lp) id = Some b ->
        b' = bt \/ b' = bs \/ b' = bar -> b <> b'.
    Proof. intros id b b' H F. exact (fresh_not_sym id b b' H (fresh_ge b' F)). Qed.
    Lemma old_lt : forall b, Plt b (Mem.nextblock m0) -> Plt b (Mem.nextblock m11).
    Proof. intros b H. rewrite nb11, nb3. pose proof nb0_NL. unfold Plt in *. lia. Qed.
    Lemma sym_ne_bpl : forall id b, Genv.find_symbol (lp_ge lp) id = Some b -> b <> bpl.
    Proof. intros id b H. exact (fresh_not_sym id b bpl H bpl_ge). Qed.
    Lemma bpl_fresh : forall b, b = bt \/ b = bs \/ b = bar -> bpl <> b.
    Proof.
      intros b [-> | [-> | ->]]; [ rewrite bt_eq | rewrite bs_eq | rewrite bar_eq ];
        pose proof bpl_lt; intro E; unfold Plt in *; lia.
    Qed.
    Lemma sym_lt : forall id b, Genv.find_symbol (lp_ge lp) id = Some b -> Plt b (Mem.nextblock m11).
    Proof. intros id b H. exact (old_lt _ (sym_old _ _ H)). Qed.

    (* the symbol blocks, pairwise *)
    Lemma ab_bm : ab <> bm.        Proof. exact (symne lp _ _ _ _ Hab Hbm eq_refl). Qed.
    Lemma bo_bm : bo <> bm.        Proof. exact (symne lp _ _ _ _ Hbo Hbm eq_refl). Qed.
    Lemma bo_ab : bo <> ab.        Proof. exact (symne lp _ _ _ _ Hbo Hab eq_refl). Qed.
    Lemma bc_bm : bc <> bm.        Proof. exact (symne lp _ _ _ _ Hbc Hbm eq_refl). Qed.
    Lemma bc_ab : bc <> ab.        Proof. exact (symne lp _ _ _ _ Hbc Hab eq_refl). Qed.
    Lemma bc_bo : bc <> bo.        Proof. exact (symne lp _ _ _ _ Hbc Hbo eq_refl). Qed.
    Lemma bs_bm : bs <> bm.
    Proof. intro E. exact (sym_ne_fresh _ _ _ Hbm (or_intror (or_introl eq_refl)) (eq_sym E)). Qed.
    Lemma bs_ab : bs <> ab.
    Proof. intro E. exact (sym_ne_fresh _ _ _ Hab (or_intror (or_introl eq_refl)) (eq_sym E)). Qed.
    Lemma bt_bo : bt <> bo.
    Proof. intro E. exact (sym_ne_fresh _ _ _ Hbo (or_introl eq_refl) (eq_sym E)). Qed.

    (* ---- loads: unchanged cells read the boot image ---- *)
    Lemma valid_0_e : forall b, Mem.valid_block m0 b -> Mem.valid_block e6 b.
    Proof. intros b H. unfold Mem.valid_block. rewrite nb_e. exact H. Qed.
    Lemma valid_e_L : forall b, Mem.valid_block e6 b -> Mem.valid_block Lm b.
    Proof. intros b H. unfold Mem.valid_block in *. exact (Plt_Ple_trans _ _ _ H (proj1 keep_eL)). Qed.
    Lemma valid_0_3 : forall b, Mem.valid_block m0 b -> Mem.valid_block m3 b.
    Proof.
      intros b H. eapply Mem.valid_block_alloc; [ exact A4 | ].
      eapply Mem.valid_block_alloc; [ exact A3 | ].
      eapply Mem.valid_block_alloc; [ exact A2 | ].
      eapply Mem.valid_block_alloc; [ exact A1 | exact (valid_e_L _ (valid_0_e _ H)) ].
    Qed.
    (* the load changes no old block outside f_ids (old_ok) and keeps its
       permissions (keep_eL): same loads *)
    Lemma ld_Le : forall ch b z, Plt b (Mem.nextblock e6) -> inFb (lp_ge lp) b = false ->
        Mem.load ch Lm b z = Mem.load ch e6 b z.
    Proof.
      intros ch b z Hb Hf. apply load_same; [ exact (proj2 keep_eL b Hb) | ].
      intros o. exact (old_ok_sound _ _ _ OK b o Hb Hf).
    Qed.
    (* the entry stores touch only sWarpDest and gCurrLevelNum *)
    Lemma ld_e : forall ch b z, b <> bw -> b <> bL -> Mem.load ch e6 b z = Mem.load ch m0 b z.
    Proof.
      intros ch b z N1 N2.
      rewrite (Mem.load_store_other _ _ _ _ _ _ E6) by (left; congruence).
      rewrite (Mem.load_store_other _ _ _ _ _ _ E5) by (left; congruence).
      rewrite (Mem.load_store_other _ _ _ _ _ _ E4) by (left; congruence).
      rewrite (Mem.load_store_other _ _ _ _ _ _ E3) by (left; congruence).
      rewrite (Mem.load_store_other _ _ _ _ _ _ E2) by (left; congruence).
      rewrite (Mem.load_store_other _ _ _ _ _ _ E1) by (left; congruence).
      reflexivity.
    Qed.
    Lemma ld_3e : forall ch b z, Mem.valid_block Lm b -> Mem.load ch m3 b z = Mem.load ch Lm b z.
    Proof.
      intros ch b z H.
      assert (V1 : Mem.valid_block m1 b) by (eapply Mem.valid_block_alloc; [ exact A1 | exact H ]).
      assert (V2 : Mem.valid_block m2 b) by (eapply Mem.valid_block_alloc; [ exact A2 | exact V1 ]).
      assert (V2b : Mem.valid_block m2b b) by (eapply Mem.valid_block_alloc; [ exact A3 | exact V2 ]).
      rewrite (Mem.load_alloc_unchanged _ _ _ _ _ A4 _ _ _ V2b),
        (Mem.load_alloc_unchanged _ _ _ _ _ A3 _ _ _ V2),
        (Mem.load_alloc_unchanged _ _ _ _ _ A2 _ _ _ V1),
        (Mem.load_alloc_unchanged _ _ _ _ _ A1 _ _ _ H). reflexivity.
    Qed.

    Lemma ld_3 : forall ch b z, Mem.valid_block m0 b -> b <> bw -> b <> bL ->
        inFb (lp_ge lp) b = false -> Mem.load ch m3 b z = Mem.load ch m0 b z.
    Proof.
      intros ch b z H0 N1 N2 Nf. rewrite (ld_3e ch b z (valid_e_L _ (valid_0_e _ H0))).
      rewrite (ld_Le ch b z (valid_0_e _ H0) Nf). exact (ld_e ch b z N1 N2).
    Qed.

    Definition cells_bm : list Z := [12; 104; 144; 156; 160; 136; 64; 140; 148; 152; 172; 176].
    Definition untouched (ch : memory_chunk) (b : block) (z : Z) : Prop :=
      b <> bs
      /\ (b = bm -> forall d, In d cells_bm -> z + size_chunk ch <= d \/ d + 4 <= z)
      /\ (b = ab -> 8 <= z /\ (z + size_chunk ch <= 8 \/ 12 <= z))
      /\ (b = bhud -> z + size_chunk ch <= 6 \/ 8 <= z)
      /\ (b = bo -> z + size_chunk ch <= 36 \/ 40 <= z)
      /\ b <> bw /\ b <> bL /\ inFb (lp_ge lp) b = false /\ b <> bC
      /\ (b = bc -> z + size_chunk ch <= 24 \/ 28 <= z).

    Lemma ld_back : forall ch b z, Mem.valid_block m0 b -> untouched ch b z ->
        Mem.load ch m11 b z = Mem.load ch m0 b z.
    Proof.
      intros ch b z Hv U.
      destruct U as (Nbs & Ubm & Uab & Uhud & Ubo & Nbw & NbL & Nf & NbC & Nbc).
      assert (Nbt : b <> bt) by (intro E; subst b; exact (Plt_strict _ (Plt_Ple_trans _ _ _ Hv (fresh_ge _ (or_introl eq_refl))))).
      assert (Nbar : b <> bar) by (intro E; subst b; exact (Plt_strict _ (Plt_Ple_trans _ _ _ Hv (fresh_ge _ (or_intror (or_intror eq_refl)))))).
      assert (Nbd : b <> bd) by (intro E; subst b; exact (Plt_strict _ (Plt_Ple_trans _ _ _ Hv bd_ge))).
      assert (Kz : forall d w, In d cells_bm -> w <= 4 -> b <> bm \/ z + size_chunk ch <= d \/ d + w <= z).
      { intros d w Hd Hw. destruct (peq b bm) as [E | N]; [ right; destruct (Ubm E d Hd); [ left | right ]; lia | left; exact N ]. }
      assert (Kab0 : b <> ab \/ z + size_chunk ch <= 0 \/ 0 + 4 <= z).
      { destruct (peq b ab) as [E | N]; [ right; right; pose proof (proj1 (Uab E)); lia | left; exact N ]. }
      assert (Kab4 : b <> ab \/ z + size_chunk ch <= 4 \/ 4 + 4 <= z).
      { destruct (peq b ab) as [E | N]; [ right; right; pose proof (proj1 (Uab E)); lia | left; exact N ]. }
      assert (Khud : b <> bhud \/ z + size_chunk ch <= 6 \/ 6 + 2 <= z).
      { destruct (peq b bhud) as [E | N]; [ right; destruct (Uhud E); [ left | right ]; lia | left; exact N ]. }
      rewrite (Mem.load_store_other _ _ _ _ _ _ Z18) by (left; exact Nbw).
      rewrite (Mem.load_store_other _ _ _ _ _ _ ZC)
        by (destruct (peq b bc) as [E | N];
            [ right; cbn [size_chunk]; destruct (Nbc E); [ left | right ]; lia | left; exact N ]).
      rewrite (Mem.load_store_other _ _ _ _ _ _ Z17) by (left; exact NbC).
      rewrite (Mem.load_store_other _ _ _ _ _ _ Z16) by (left; congruence).
      rewrite (Mem.load_store_other _ _ _ _ _ _ Z15) by (left; congruence).
      rewrite (Mem.load_store_other _ _ _ _ _ _ Z14) by (left; congruence).
      rewrite (Mem.load_store_other _ _ _ _ _ _ Z13) by (left; congruence).
      rewrite (Mem.load_store_other _ _ _ _ _ _ Z12) by (left; congruence).
      rewrite (Mem.load_store_other _ _ _ _ _ _ Z11) by (left; congruence).
      rewrite (Mem.load_store_other _ _ _ _ _ _ Z10) by exact Kab4.
      rewrite (Mem.load_store_other _ _ _ _ _ _ Z10a) by exact Kab0.
      rewrite (apply_writes_other _ _ _ _ _ _ _ Z9)
        by (intros w Hw; rewrite (proj1 (proj2 (tab_writes_shape _ _ _ _ Hw))); congruence).
      rewrite (Mem.load_store_other _ _ _ _ _ _ Z8) by (left; congruence).
      rewrite (Mem.load_store_other _ _ _ _ _ _ Z7) by exact Khud.
      rewrite (Mem.load_store_other _ _ _ _ _ _ Z6) by (exact (Kz 176 2 ltac:(cbn; tauto) ltac:(lia))).
      rewrite (Mem.load_store_other _ _ _ _ _ _ Z5) by (destruct (Kz 172 4 ltac:(cbn; tauto) ltac:(lia)) as [N | [N | N]]; [ left; exact N | right; left; cbn [size_chunk]; lia | right; right; cbn [size_chunk]; lia ]).
      rewrite (Mem.load_store_other _ _ _ _ _ _ Z4) by (destruct (Kz 172 4 ltac:(cbn; tauto) ltac:(lia)) as [N | [N | N]]; [ left; exact N | right; left; cbn [size_chunk]; lia | right; right; cbn [size_chunk]; lia ]).
      rewrite (Mem.load_store_other _ _ _ _ _ _ Z3) by exact (Kz 152 4 ltac:(cbn; tauto) ltac:(lia)).
      rewrite (Mem.load_store_other _ _ _ _ _ _ Z2) by exact (Kz 148 4 ltac:(cbn; tauto) ltac:(lia)).
      rewrite (Mem.load_store_other _ _ _ _ _ _ Z1) by exact (Kz 140 4 ltac:(cbn; tauto) ltac:(lia)).
      assert (Uab' : b = ab -> z + size_chunk ch <= 8 \/ 12 <= z) by (intro E; exact (proj2 (Uab E))).
      clear Uab. rename Uab' into Uab.
      assert (Cbm : forall d, In d cells_bm -> b = bm -> z + size_chunk ch <= d \/ d + 4 <= z)
        by (intros d Hd E; exact (Ubm E d Hd)).
      assert (Kbm : forall d, In d cells_bm -> b <> bm \/ z + size_chunk ch <= d \/ d + 4 <= z).
      { intros d Hd. destruct (peq b bm) as [E | N]; [ right; exact (Cbm d Hd E) | left; exact N ]. }
      assert (Kab : b <> ab \/ z + size_chunk ch <= 8 \/ 8 + 4 <= z).
      { destruct (peq b ab) as [E | N]; [ right; destruct (Uab E); [ left; lia | right; lia ] | left; exact N ]. }
      assert (Ksym : forall d, In d cells_bm -> b <> bm \/ z + size_chunk ch <= d \/ d + size_chunk Mint32 <= z)
        by exact Kbm.
      rewrite (Mem.load_store_other _ _ _ _ _ _ S8) by
        (destruct Kab as [N | N]; [ left; congruence | right; exact N ]).
      rewrite (Mem.load_store_other _ _ _ _ _ _ S7) by
        (destruct (Ksym 136 ltac:(cbn; tauto)) as [N | N]; [ left; congruence | right; exact N ]).
      rewrite (Mem.load_store_other _ _ _ _ _ _ S6) by
        (destruct (Ksym 160 ltac:(cbn; tauto)) as [N | N]; [ left; congruence | right; exact N ]).
      rewrite (Mem.load_store_other _ _ _ _ _ _ S5) by
        (destruct (Ksym 156 ltac:(cbn; tauto)) as [N | N]; [ left; congruence | right; exact N ]).
      rewrite (Mem.load_store_other _ _ _ _ _ _ S4) by
        (destruct (Ksym 144 ltac:(cbn; tauto)) as [N | N]; [ left; congruence | right; exact N ]).
      rewrite (Mem.load_store_other _ _ _ _ _ _ S3) by
        (destruct (Ksym 104 ltac:(cbn; tauto)) as [N | N]; [ left; congruence | right; exact N ]).
      rewrite (Mem.load_store_other _ _ _ _ _ _ S2) by
        (destruct (Ksym 12 ltac:(cbn; tauto)) as [N | N]; [ left; congruence | right; exact N ]).
      rewrite (Mem.load_store_other _ _ _ _ _ _ S1) by (left; congruence).
      rewrite (Mem.load_store_other _ _ _ _ _ _ S1b) by
        (destruct (peq b bo) as [E | N];
         [ right; destruct (Ubo E) as [H | H]; [ left; exact H | right; cbn [size_chunk]; lia ]
         | left; exact N ]).
      rewrite (Mem.load_store_other _ _ _ _ _ _ S1a) by
        (destruct (Ksym 64 ltac:(cbn; tauto)) as [N | N]; [ left; congruence | right; exact N ]).
      exact (ld_3 ch b z Hv Nbw NbL Nf).
    Qed.

    (* ---- MWF_real, store by store ---- *)
    (* SafeB: the SafeB symbols, the main-pool block (the loader's lists and
       surfaces live there and the pool globals point into it), init_mario's
       anim buffer and area *)
    Definition SB1 : block -> Prop :=
      SafeB_wit lp (fun b => b = bpl) (fun id => mem_id id non_safeb_syms = false).
    Definition SBw : block -> Prop :=
      SafeB_wit lp (fun b => b = bpl \/ b = bt \/ b = bar \/ b = bd)
        (fun id => mem_id id non_safeb_syms = false).

    Lemma Sy_1 : SafeB_syms_ok lp SB1.
    Proof.
      apply safeb_wit_sat_le;
        [ intros b ->; rewrite genv_next_eq; exact bpl_ge
        | intros id H; exact H | exact gobj_not_nonsafe ].
    Qed.
    Lemma Sy_w : SafeB_syms_ok lp SBw.
    Proof.
      apply safeb_wit_sat_le;
        [ intros b [-> | [Hb | [Hb | ->]]]; rewrite genv_next_eq;
          [ exact bpl_ge | apply fresh_ge; tauto | apply fresh_ge; tauto | exact bd_ge ]
        | intros id H; exact H | exact gobj_not_nonsafe ].
    Qed.

    Lemma Hsp : spawn_ok lp m0 bm bc Ptrofs.zero.
    Proof. split; [ exact Hinit | split; [ exact Hbm | split; [ exact Hbc | reflexivity ] ] ]. Qed.

    Ltac dfacts Sy :=
      pose proof (linked12_LO_mario lp H12) as LOm;
      pose proof (spawn_Hbc_bm lp m0 bm bc Ptrofs.zero Hsp) as D1;
      pose proof (safeb_not_bm lp m0 bm bc Ptrofs.zero _ Hsp Sy) as D2;
      pose proof (safeb_not_bc lp m0 bm bc Ptrofs.zero _ Hsp Sy) as D2';
      pose proof (gms_blk lp m0 bm bc Ptrofs.zero _ Hsp Sy) as D3;
      pose proof (gtimer_blk lp m0 bm bc Ptrofs.zero _ Hsp Sy) as D4;
      pose proof (table_blk lp m0 bm bc Ptrofs.zero _ Hsp Sy) as D5;
      pose proof (ktab_blk lp m0 bm bc Ptrofs.zero _ Hsp Sy) as D6;
      pose proof (glob_blk lp m0 bm bc Ptrofs.zero _ Hsp Sy) as D7.

    Lemma mwf_e6 : MWF_real lp bm bc Ptrofs.zero (SafeB_boot lp) e6.
    Proof.
      pose proof (SafeB_boot_syms_ok lp) as Sy. dfacts Sy.
      pose proof (boot_mwf lp H12 m0 Hinit bm bc Hbm Hbc) as M0.
      assert (Sw : SafeB_boot lp bw).
      { right. exists level_update._sWarpDest. split; [ left; vm_compute; reflexivity | exact Hbw ]. }
      assert (SL : SafeB_boot lp bL).
      { right. exists level_update._gCurrLevelNum. split; [ left; vm_compute; reflexivity | exact HbL ]. }
      assert (NP : forall i bb oo, Vint i <> Vptr bb oo) by (intros i bb oo E; discriminate E).
      assert (M1 : MWF_real lp bm bc Ptrofs.zero (SafeB_boot lp) e1)
        by (eapply (mwf_real_chase lp) with (mm := m0) (bsafe := bw); try eassumption; apply NP).
      assert (M2 : MWF_real lp bm bc Ptrofs.zero (SafeB_boot lp) e2)
        by (eapply (mwf_real_chase lp) with (mm := e1) (bsafe := bw); try eassumption; apply NP).
      assert (M3 : MWF_real lp bm bc Ptrofs.zero (SafeB_boot lp) e3)
        by (eapply (mwf_real_chase lp) with (mm := e2) (bsafe := bw); try eassumption; apply NP).
      assert (M4 : MWF_real lp bm bc Ptrofs.zero (SafeB_boot lp) e4)
        by (eapply (mwf_real_chase lp) with (mm := e3) (bsafe := bw); try eassumption; apply NP).
      assert (M5 : MWF_real lp bm bc Ptrofs.zero (SafeB_boot lp) e5)
        by (eapply (mwf_real_chase lp) with (mm := e4) (bsafe := bw); try eassumption; apply NP).
      eapply (mwf_real_chase lp) with (mm := e5) (bsafe := bL); try eassumption; apply NP.
    Qed.

    (* the pool block joins SafeB while it is still fresh (no pointers) *)
    Lemma mwf_P0 : MWF_real lp bm bc Ptrofs.zero SB1 P0.
    Proof.
      pose proof (SafeB_boot_syms_ok lp) as Sy. dfacts Sy.
      pose proof mwf_e6 as M6.
      assert (M : MWF_real lp bm bc Ptrofs.zero (SafeB_boot lp) P0)
        by (eapply (mwf_real_alloc lp); try eassumption).
      apply (mwf_real_widen lp bm bc Ptrofs.zero (SafeB_boot lp) SB1 (fun b => b = bpl) P0 M).
      - intros b [E | H]; [ right; exact E | left; right; exact H ].
      - intros b [[] | H]. right. exact H.
      - intros b ->. exact (Mem.valid_new_block _ _ _ _ _ AP).
      - intros b ofs b' o' -> Hld. cbn [Mem.loadv] in Hld.
        pose proof (Mem.load_alloc_same _ _ _ _ _ AP _ _ _ Hld). discriminate.
      - intros ab' Hab'. exact (safeb_of_nonfam_sym lp SB1 Sy_1 _ _ Hab' eq_refl).
    Qed.

    Lemma sym_nf : forall id b, Genv.find_symbol (lp_ge lp) id = Some b ->
        mem_id id non_safeb_syms = true -> Plt b (Mem.nextblock e6) /\ inFb (lp_ge lp) b = false.
    Proof.
      intros id b Hs Hn. split; [ rewrite nb_e; exact (sym_old _ _ Hs) | ].
      exact (inFb_sym_false _ _ _ Hs (nonsafe_notF _ Hn)).
    Qed.

    Lemma ld_LP : forall ch b z, Plt b (Mem.nextblock e6) -> inFb (lp_ge lp) b = false ->
        Mem.load ch Lm b z = Mem.load ch P0 b z.
    Proof.
      intros ch b z Hb Hf. rewrite (ld_Le ch b z Hb Hf). symmetry.
      exact (Mem.load_alloc_unchanged _ _ _ _ _ AP _ _ _ Hb).
    Qed.

    (* across the loader: every MWF row reads a non-SafeB symbol the load
       does not touch; SafeB stays load-closed by frag_ok *)
    Lemma mwf_L : MWF_real lp bm bc Ptrofs.zero SB1 Lm.
    Proof.
      pose proof Sy_1 as Sy. dfacts Sy.
      pose proof mwf_P0 as M.
      pose proof M as (_ & R1 & _ & _ & _ & _ & _ & R7 & _).
      assert (Fs : forall b, inFb (lp_ge lp) b = true \/ b = bpl -> forall z b' o',
                 Mem.load Mint32 Lm b z = Some (Vptr b' o') -> SB1 b').
      { intros b Hb z b' o' Hl.
        pose proof (load_ptr_ok _ _ _ _ _ _ (fun o => proj1 (frag_ok_sound _ _ _ FR) b o Hb) Hl) as T.
        destruct (safe_tgt_sym _ _ _ _ T) as [-> | (i & Hi & Hs)]; [ left; reflexivity | ].
        right. exists i. split; [ left; exact Hi | exact Hs ]. }
      assert (Bm : Plt bm (Mem.nextblock e6) /\ inFb (lp_ge lp) bm = false)
        by (apply (sym_nf _ _ Hbm); vm_compute; reflexivity).
      eapply (MWF_real_transfer lp) with (m := P0); try eassumption.
      - intros b Hv. unfold Mem.valid_block in *. exact (Plt_Ple_trans _ _ _ Hv (proj1 keep_PL)).
      - intros v Hl. apply (R1 v). rewrite <- (ld_LP _ _ _ (proj1 Bm) (proj2 Bm)). exact Hl.
      - intros ch b ofs v Hrow Hl.
        assert (Hnf : Plt b (Mem.nextblock e6) /\ inFb (lp_ge lp) b = false).
        { destruct Hrow as [ [-> _] | [ -> | [ Hs | [ Hs | [ Hs | [ (gid & Hg & Hs) | Hs ] ] ] ] ] ].
          - exact Bm.
          - apply (sym_nf _ _ Hbc). vm_compute. reflexivity.
          - apply (sym_nf _ _ Hs). vm_compute. reflexivity.
          - apply (sym_nf _ _ Hs). vm_compute. reflexivity.
          - apply (sym_nf _ _ Hs). vm_compute. reflexivity.
          - apply (sym_nf _ _ Hs). unfold non_safeb_syms. apply mem_id_app_r, mem_id_app_r. exact Hg.
          - apply (sym_nf _ _ Hs). vm_compute. reflexivity. }
        rewrite <- (ld_LP _ _ _ (proj1 Hnf) (proj2 Hnf)). exact Hl.
      - intros b ofs b' o' Hs Hl. rewrite Mptr32 in Hl. cbn [Mem.loadv] in Hl.
        destruct Hs as [-> | (id & Hid & Hfs)]; [ exact (Fs _ (or_intror eq_refl) _ _ _ Hl) | ].
        destruct (inFb (lp_ge lp) b) eqn:Fb; [ exact (Fs b (or_introl Fb) _ _ _ Hl) | ].
        assert (Hb : Plt b (Mem.nextblock e6)) by (rewrite nb_e; exact (sym_old _ _ Hfs)).
        apply (R7 b ofs b' o' (or_intror (ex_intro _ id (conj Hid Hfs)))).
        rewrite Mptr32. cbn [Mem.loadv]. rewrite <- (ld_LP _ _ _ Hb Fb). exact Hl.
    Qed.

    Lemma mwf_m3 : MWF_real lp bm bc Ptrofs.zero SB1 m3.
    Proof.
      pose proof Sy_1 as Sy. dfacts Sy. pose proof mwf_L as ML.
      eapply (mwf_real_alloc lp); try eassumption.
      eapply (mwf_real_alloc lp); try eassumption.
      eapply (mwf_real_alloc lp); try eassumption.
      eapply (mwf_real_alloc lp); try eassumption.
    Qed.

    Lemma bt_valid3 : Mem.valid_block m3 bt.
    Proof.
      eapply Mem.valid_block_alloc; [ exact A4 | ].
      eapply Mem.valid_block_alloc; [ exact A3 | ].
      eapply Mem.valid_block_alloc; [ exact A2 | ].
      exact (Mem.valid_new_block _ _ _ _ _ A1).
    Qed.

    Lemma bar_valid3 : Mem.valid_block m3 bar.
    Proof. eapply Mem.valid_block_alloc; [ exact A4 | exact (Mem.valid_new_block _ _ _ _ _ A3) ]. Qed.
    Lemma bd_valid3 : Mem.valid_block m3 bd.
    Proof. exact (Mem.valid_new_block _ _ _ _ _ A4). Qed.

    Lemma bar_noptr3 : forall ofs b' o', Mem.loadv Mptr m3 (Vptr bar ofs) = Some (Vptr b' o') -> False.
    Proof.
      intros ofs b' o' Hld. cbn [Mem.loadv] in Hld.
      rewrite (Mem.load_alloc_unchanged _ _ _ _ _ A4 _ _ _ (Mem.valid_new_block _ _ _ _ _ A3)) in Hld.
      pose proof (Mem.load_alloc_same _ _ _ _ _ A3 _ _ _ Hld). discriminate.
    Qed.
    Lemma bd_noptr3 : forall ofs b' o', Mem.loadv Mptr m3 (Vptr bd ofs) = Some (Vptr b' o') -> False.
    Proof.
      intros ofs b' o' Hld. cbn [Mem.loadv] in Hld.
      pose proof (Mem.load_alloc_same _ _ _ _ _ A4 _ _ _ Hld). discriminate.
    Qed.

    Lemma bt_noptr3 : forall ofs b' o', Mem.loadv Mptr m3 (Vptr bt ofs) = Some (Vptr b' o') -> False.
    Proof.
      intros ofs b' o' Hld. cbn [Mem.loadv] in Hld.
      assert (V1 : Mem.valid_block m1 bt) by exact (Mem.valid_new_block _ _ _ _ _ A1).
      assert (V2 : Mem.valid_block m2 bt) by (eapply Mem.valid_block_alloc; [ exact A2 | exact V1 ]).
      assert (V2b : Mem.valid_block m2b bt) by (eapply Mem.valid_block_alloc; [ exact A3 | exact V2 ]).
      rewrite (Mem.load_alloc_unchanged _ _ _ _ _ A4 _ _ _ V2b),
        (Mem.load_alloc_unchanged _ _ _ _ _ A3 _ _ _ V2),
        (Mem.load_alloc_unchanged _ _ _ _ _ A2 _ _ _ V1) in Hld.
      pose proof (Mem.load_alloc_same _ _ _ _ _ A1 _ _ _ Hld). discriminate.
    Qed.

    Lemma mwf_w3 : MWF_real lp bm bc Ptrofs.zero SBw m3.
    Proof.
      apply (mwf_real_widen lp bm bc Ptrofs.zero SB1 SBw (fun b => b = bt \/ b = bar \/ b = bd) m3 mwf_m3).
      - intros b [[E | E] | H]; [ left; left; exact E | right; exact E | left; right; exact H ].
      - intros b [E | H]; [ left; left; exact E | right; exact H ].
      - intros b [-> | [-> | ->]]; [ exact bt_valid3 | exact bar_valid3 | exact bd_valid3 ].
      - intros b ofs b' o' [-> | [-> | ->]] Hld;
          [ exact (bt_noptr3 _ _ _ Hld) | exact (bar_noptr3 _ _ _ Hld) | exact (bd_noptr3 _ _ _ Hld) ].
      - intros ab' Hab'. exact (safeb_of_nonfam_sym lp SBw Sy_w _ _ Hab' eq_refl).
    Qed.

    Lemma bs_not_sbw : ~ SBw bs.
    Proof.
      intros [[E | [E | [E | E]]] | (id & _ & Hfs)];
        [ exact (bpl_fresh bs (or_intror (or_introl eq_refl)) (eq_sym E))
        | exact (bt_bs (eq_sym E)) | exact (bs_bar E) | exact (bs_bd E) | ].
      exact (sym_ne_fresh _ _ _ Hfs (or_intror (or_introl eq_refl)) eq_refl).
    Qed.

    Lemma ab_m9 : Mem.load Mint32 m9 ab 8 = Mem.load Mint32 m0 ab 8.
    Proof.
      pose proof ab_bm as N1. pose proof bs_ab as N2. pose proof bo_ab as N3.
      rewrite (Mem.load_store_other _ _ _ _ _ _ S6) by (left; congruence).
      rewrite (Mem.load_store_other _ _ _ _ _ _ S5) by (left; congruence).
      rewrite (Mem.load_store_other _ _ _ _ _ _ S4) by (left; congruence).
      rewrite (Mem.load_store_other _ _ _ _ _ _ S3) by (left; congruence).
      rewrite (Mem.load_store_other _ _ _ _ _ _ S2) by (left; congruence).
      rewrite (Mem.load_store_other _ _ _ _ _ _ S1) by (left; congruence).
      rewrite (Mem.load_store_other _ _ _ _ _ _ S1b) by (left; congruence).
      rewrite (Mem.load_store_other _ _ _ _ _ _ S1a) by (left; congruence).
      apply ld_3; [ exact (Genv.find_symbol_not_fresh _ _ Hinit Hab)
                  | exact (symne lp _ _ _ _ Hab Hbw eq_refl)
                  | exact (symne lp _ _ _ _ Hab HbL eq_refl)
                  | exact (inFb_sym_false _ _ _ Hab ltac:(vm_compute; reflexivity)) ].
    Qed.

    Lemma mobj_m10 : Mem.load Mint32 m10 bm 136 = Some (Vptr bo Ptrofs.zero).
    Proof. rewrite (Mem.load_store_same _ _ _ _ _ _ S7). reflexivity. Qed.

    Theorem mwf_w11 : MWF_real lp bm bc Ptrofs.zero SBw m11.
    Proof.
      pose proof Sy_w as Sy.
      pose proof (linked12_LO_mario lp H12) as LOm.
      pose proof (spawn_Hbc_bm lp m0 bm bc Ptrofs.zero Hsp) as D1.
      pose proof (safeb_not_bm lp m0 bm bc Ptrofs.zero _ Hsp Sy) as D2.
      pose proof (safeb_not_bc lp m0 bm bc Ptrofs.zero _ Hsp Sy) as D2'.
      pose proof (gms_blk lp m0 bm bc Ptrofs.zero _ Hsp Sy) as D3.
      pose proof (gtimer_blk lp m0 bm bc Ptrofs.zero _ Hsp Sy) as D4.
      pose proof (table_blk lp m0 bm bc Ptrofs.zero _ Hsp Sy) as D5.
      pose proof (ktab_blk lp m0 bm bc Ptrofs.zero _ Hsp Sy) as D6.
      pose proof (glob_blk lp m0 bm bc Ptrofs.zero _ Hsp Sy) as D7.
      pose proof mwf_w3 as M3.
      assert (M3a : MWF_real lp bm bc Ptrofs.zero SBw m3a).
      { eapply (mwf_real_window lp) with (mm := m3) (mm' := m3a); try eassumption. reflexivity. }
      assert (M3b : MWF_real lp bm bc Ptrofs.zero SBw m3b).
      { eapply (mwf_real_chase lp) with (mm := m3a) (mm' := m3b) (bsafe := bo); try eassumption.
        - right. exists object_list_processor._gObjectPool. split; [ left; reflexivity | exact Hbo ].
        - intros bb oo E. discriminate E. }
      assert (M4 : MWF_real lp bm bc Ptrofs.zero SBw m4).
      { eapply (mwf_real_local_store lp) with (mm := m3b) (mm' := m4) (b0 := bs); try eassumption.
        - exact bs_bm.
        - intro E. exact (sym_ne_fresh _ _ _ Hbc (or_intror (or_introl eq_refl)) (eq_sym E)).
        - exact bs_not_sbw.
        - intros gid bg Hg E. exact (sym_ne_fresh _ _ _ Hg (or_intror (or_introl eq_refl)) (eq_sym E)). }
      assert (M5 : MWF_real lp bm bc Ptrofs.zero SBw m5).
      { eapply (mwf_real_act_store lp) with (mm := m4) (mm' := m5); try eassumption. intros bb oo E. discriminate E. }
      assert (M6 : MWF_real lp bm bc Ptrofs.zero SBw m6).
      { eapply (mwf_real_window lp) with (mm := m5) (mm' := m6); try eassumption. reflexivity. }
      assert (M7 : MWF_real lp bm bc Ptrofs.zero SBw m7).
      { eapply (mwf_real_root_store lp) with (mm := m6) (mm' := m7) (fld := mario._area) (delta := 144);
          try eassumption; [ reflexivity | discriminate | vm_compute; reflexivity | ].
        intros bb oo E. injection E as <- _. left. right. right. left. reflexivity. }
      assert (M8 : MWF_real lp bm bc Ptrofs.zero SBw m8).
      { eapply (mwf_real_pin_store lp) with (mm := m7) (mm' := m8); try eassumption. left. split; reflexivity. }
      assert (M9 : MWF_real lp bm bc Ptrofs.zero SBw m9).
      { eapply (mwf_real_pin_store lp) with (mm := m8) (mm' := m9); try eassumption.
        right. split; [ reflexivity | exists ab; split; [ exact Hab | reflexivity ] ]. }
      assert (M10 : MWF_real lp bm bc Ptrofs.zero SBw m10).
      { eapply (mwf_real_mobj_store lp) with (mm := m9) (mm' := m10); try eassumption; [ reflexivity | | ].
        - intros bb oo E. injection E as <- <-. right.
          exists object_list_processor._gObjectPool. split; [ left; reflexivity | exact Hbo ].
        - intros ab' bt' ot' bb oo Hab' Hld _.
          rewrite Hab in Hab'. injection Hab' as <-.
          exfalso. change (Mem.load Mint32 m9 ab 8 = Some (Vptr bt' ot')) in Hld.
          rewrite ab_m9 in Hld.
          eapply boot_bss_noptr with (id := mario._gMarioAnimsBuf) (b := ab) (chunk := Mint32) (ofs := 8);
            first [ exact H12 | exact Hinit | reflexivity | exact Hab | exact Hld ]. }
      assert (Ms : MWF_real lp bm bc Ptrofs.zero SBw ms).
      { eapply (mwf_real_buf_store lp) with (mm := m10) (mm' := ms) (ab := ab); try eassumption.
        - intros b o E. injection E as <- _. left. right. left. reflexivity.
        - intros b o mb mo E Hl. injection E as <- _.
          change (Mem.load Mint32 m10 bm 136 = Some (Vptr mb mo)) in Hl.
          rewrite mobj_m10 in Hl. injection Hl as <- _. exact bt_bo. }
      assert (SY : forall s b, sym (lp_ge lp) s = Some b -> mem_id (id s) non_safeb_syms = false -> SBw b).
      { intros s0 b Hs Hn. right. exists (id s0). split; [ left; exact Hn | exact Hs ]. }
      assert (NP : forall i bb oo, Vint i <> Vptr bb oo) by (intros i bb oo E; discriminate E).
      assert (Mz1 : MWF_real lp bm bc Ptrofs.zero SBw z1).
      { eapply (mwf_real_window lp) with (mm := ms) (mm' := z1); try eassumption. reflexivity. }
      assert (Mz2 : MWF_real lp bm bc Ptrofs.zero SBw z2).
      { eapply (mwf_real_root_store lp) with (mm := z1) (mm' := z2) (fld := mario._statusForCamera) (delta := 148);
          try eassumption; [ reflexivity | discriminate | vm_compute; reflexivity | ].
        intros bb oo E. injection E as <- _. exact (SY _ _ Hpcs ltac:(vm_compute; reflexivity)). }
      assert (Mz3 : MWF_real lp bm bc Ptrofs.zero SBw z3).
      { eapply (mwf_real_root_store lp) with (mm := z2) (mm' := z3) (fld := mario._marioBodyState) (delta := 152);
          try eassumption; [ reflexivity | discriminate | vm_compute; reflexivity | ].
        intros bb oo E. injection E as <- _. exact (SY _ _ Hbbs ltac:(vm_compute; reflexivity)). }
      assert (Mz4 : MWF_real lp bm bc Ptrofs.zero SBw z4).
      { eapply (mwf_real_window lp) with (mm := z3) (mm' := z4); try eassumption. reflexivity. }
      assert (Mz5 : MWF_real lp bm bc Ptrofs.zero SBw z5).
      { eapply (mwf_real_window lp) with (mm := z4) (mm' := z5); try eassumption. reflexivity. }
      assert (Mz6 : MWF_real lp bm bc Ptrofs.zero SBw z6).
      { eapply (mwf_real_window lp) with (mm := z5) (mm' := z6); try eassumption. reflexivity. }
      assert (Mz7 : MWF_real lp bm bc Ptrofs.zero SBw z7).
      { (* gHudDisplay is a stored global (not SafeB): the glob brick *)
        eapply (proj2 (mwf_real_glob lp bm bc Ptrofs.zero SBw D1 D7 (id "gHudDisplay"%string)
                         ltac:(vm_compute; reflexivity) bhud Hhud)); eassumption. }
      assert (Mz8 : MWF_real lp bm bc Ptrofs.zero SBw z8).
      { eapply (mwf_real_chase lp) with (mm := z7) (mm' := z8) (bsafe := bar); try eassumption;
          [ left; right; right; left; reflexivity | apply NP ]. }
      assert (Sga : SBw bga).
      { right. exists game_init._gMarioAnims. split; [ left; vm_compute; reflexivity | exact Hga ]. }
      assert (Mz9 : MWF_real lp bm bc Ptrofs.zero SBw z9).
      { apply (apply_writes_ind (MWF_real lp bm bc Ptrofs.zero SBw) _ _ _ _ Z9); [ | exact Mz8 ].
        intros w mm mm' Hw Hs Hm.
        destruct (tab_writes_shape _ _ _ _ Hw) as (_ & Eb & Hv). rewrite Eb in Hs.
        eapply (mwf_real_chase_ptr lp) with (mm := mm) (mm' := mm') (bsafe := bd); try eassumption;
          [ left; right; right; right; reflexivity | ].
        intros bb oo E. destruct Hv as [Hv | Hv]; [ rewrite Hv in E; injection E as <- _; exact Sga
                                                  | exfalso; exact (Hv _ _ E) ]. }
      assert (Mz10a : MWF_real lp bm bc Ptrofs.zero SBw z10a).
      { eapply (mwf_anim_tab_store lp bm bc Ptrofs.zero SBw D1) with (mm := z9) (ab := ab); try eassumption.
        intros b o E. injection E as <- _. left. right. right. right. reflexivity. }
      assert (Mz10 : MWF_real lp bm bc Ptrofs.zero SBw z10).
      { eapply (mwf_real_anim_cur_store lp) with (mm := z10a) (ab := ab); try eassumption.
        intros b o E. unfold cur_addr in E.
        revert E; match goal with |- context [match ?x with _ => _ end] => destruct x as [[]|] end; intro E; try discriminate E.
        injection E as <- _. exact Sga. }
      assert (Bt : SBw bt) by (left; right; left; reflexivity).
      assert (Mz11 : MWF_real lp bm bc Ptrofs.zero SBw z11)
        by (eapply (mwf_real_chase lp) with (mm := z10) (bsafe := bt); try eassumption; apply NP).
      assert (Mz12 : MWF_real lp bm bc Ptrofs.zero SBw z12)
        by (eapply (mwf_real_chase lp) with (mm := z11) (bsafe := bt); try eassumption; apply NP).
      assert (Mz13 : MWF_real lp bm bc Ptrofs.zero SBw z13)
        by (eapply (mwf_real_chase lp) with (mm := z12) (bsafe := bt); try eassumption; apply NP).
      assert (Mz14 : MWF_real lp bm bc Ptrofs.zero SBw z14)
        by (eapply (mwf_real_chase lp) with (mm := z13) (bsafe := bt); try eassumption; apply NP).
      assert (Mz15 : MWF_real lp bm bc Ptrofs.zero SBw z15)
        by (eapply (mwf_real_chase lp) with (mm := z14) (bsafe := bt); try eassumption; apply NP).
      assert (Mz16 : MWF_real lp bm bc Ptrofs.zero SBw z16)
        by (eapply (mwf_real_chase lp) with (mm := z15) (bsafe := bt); try eassumption; apply NP).
      assert (SC : SBw bC).
      { right. exists level_update._gCurrCourseNum. split; [ left; vm_compute; reflexivity | exact HcC ]. }
      assert (Mz17 : MWF_real lp bm bc Ptrofs.zero SBw z17)
        by (eapply (mwf_real_chase lp) with (mm := z16) (bsafe := bC); try eassumption; apply NP).
      (* gControllers[0].controllerData: the controller block, off
         buttonPressed (18) *)
      assert (Mz18 : MWF_real lp bm bc Ptrofs.zero SBw z18).
      { eapply (mwf_real_bc_store lp) with (mm := z17) (mm' := z18); try eassumption.
      intros v Hl. pose proof Mz17 as (_ & _ & _ & R3 & _). apply R3.
      rewrite <- Hl. symmetry. apply (Mem.load_store_other _ _ _ _ _ _ ZC). right. left.
      change (Ptrofs.unsigned (Ptrofs.add Ptrofs.zero (Ptrofs.repr 18))) with 18.
      cbn [size_chunk]. lia. }
      assert (SW : SBw bw).
      { right. exists level_update._sWarpDest. split; [ left; vm_compute; reflexivity | exact Hbw ]. }
      eapply (mwf_real_chase lp) with (mm := z18) (bsafe := bw); try eassumption; apply NP.
    Qed.

    (* ---- the facts PhiW reads ---- *)
    Ltac al := apply Z.mod_divide; [ cbn; discriminate | reflexivity ].

    Lemma rp_gms : Mem.range_perm m0 bm 0 200 Cur Writable.
    Proof.
      exact (wr_sym _ _ _ bm (linked12_LO_lvl lp H12) dm_gms eq_refl eq_refl
               ltac:(cbn; discriminate) Hbm).
    Qed.
    Lemma rp_pool : Mem.range_perm m0 bo 0 145920 Cur Writable.
    Proof.
      exact (wr_sym _ _ _ bo LO_olp dm_pool eq_refl eq_refl ltac:(cbn; discriminate) Hbo).
    Qed.

    Lemma unt_bm : forall ch z,
        (forall d, In d cells_bm -> z + size_chunk ch <= d \/ d + 4 <= z) -> untouched ch bm z.
    Proof.
      intros ch z H. split; [ intro E; exact (bs_bm (eq_sym E)) | ].
      split; [ intros _; exact H | ].
      split; [ intros E; exfalso; exact (ab_bm (eq_sym E)) | ].
      split; [ intros E; exfalso; exact (symne lp _ _ _ _ Hbm Hhud eq_refl E) | ].
      split; [ intros E; exfalso; exact (bo_bm (eq_sym E)) | ].
      split; [ exact (symne lp _ _ _ _ Hbm Hbw eq_refl) | ].
      split; [ exact (symne lp _ _ _ _ Hbm HbL eq_refl) | ].
      split; [ exact (inFb_sym_false _ _ _ Hbm ltac:(vm_compute; reflexivity)) | ].
      split; [ exact (symne lp _ _ _ _ Hbm HcC eq_refl) | intros E; exfalso; exact (symne lp _ _ _ _ Hbm Hbc eq_refl E) ].
    Qed.
    Lemma bs_bo : bs <> bo.
    Proof. intro E. exact (sym_ne_fresh _ _ _ Hbo (or_intror (or_introl eq_refl)) (eq_sym E)). Qed.
    (* Mario's object, off gfx.pos[1] (offset 36) *)
    Lemma unt_bo : forall ch z, z + size_chunk ch <= 36 \/ 40 <= z -> untouched ch bo z.
    Proof.
      intros ch z Hz. split; [ intro E; exact (bs_bo (eq_sym E)) | ].
      split; [ intros E; exfalso; exact (bo_bm E) | ].
      split; [ intros E; exfalso; exact (bo_ab E) | ].
      split; [ intros E; exfalso; exact (symne lp _ _ _ _ Hbo Hhud eq_refl E) | ].
      split; [ intros _; exact Hz | ].
      split; [ exact (symne lp _ _ _ _ Hbo Hbw eq_refl) | ].
      split; [ exact (symne lp _ _ _ _ Hbo HbL eq_refl) | ].
      split; [ exact (inFb_sym_false _ _ _ Hbo ltac:(vm_compute; reflexivity)) | ].
      split; [ exact (symne lp _ _ _ _ Hbo HcC eq_refl) | intros E; exfalso; exact (symne lp _ _ _ _ Hbo Hbc eq_refl E) ].
    Qed.

    Ltac cells := intros d Hd; cbn [cells_bm In] in Hd;
      repeat (destruct Hd as [<- | Hd]; [ cbn [size_chunk]; lia | ]); destruct Hd.

    Lemma z_bm : forall ch z, 0 <= z -> z + size_chunk ch <= 200 -> (align_chunk ch | z) ->
        (forall d, In d cells_bm -> z + size_chunk ch <= d \/ d + 4 <= z) ->
        Mem.load ch m11 bm z = Some (zeros ch).
    Proof.
      intros ch z H0 H1 Ha Hc.
      rewrite (ld_back ch bm z (Genv.find_symbol_not_fresh _ _ Hinit Hbm) (unt_bm ch z Hc)).
      destruct (valid_ex ch bm z 0 200 rp_gms H0 H1 Ha) as (v & Hv). rewrite Hv. f_equal.
      exact (boot_zero lp m0 _ bm ch z v H12 Hinit (or_introl eq_refl) Hbm Hv).
    Qed.
    Lemma z_bm_any : forall ch z v,
        (forall d, In d cells_bm -> z + size_chunk ch <= d \/ d + 4 <= z) ->
        Mem.load ch m11 bm z = Some v -> v = zeros ch.
    Proof.
      intros ch z v Hc Hl.
      rewrite (ld_back ch bm z (Genv.find_symbol_not_fresh _ _ Hinit Hbm) (unt_bm ch z Hc)) in Hl.
      exact (boot_zero lp m0 _ bm ch z v H12 Hinit (or_introl eq_refl) Hbm Hl).
    Qed.
    Lemma z_bo : forall ch z, 40 <= z -> z + size_chunk ch <= 145920 -> (align_chunk ch | z) ->
        Mem.load ch m11 bo z = Some (zeros ch).
    Proof.
      intros ch z H0 H1 Ha.
      rewrite (ld_back ch bo z (Genv.find_symbol_not_fresh _ _ Hinit Hbo) (unt_bo ch z (or_intror H0))).
      destruct (valid_ex ch bo z 0 145920 rp_pool ltac:(lia) H1 Ha) as (v & Hv). rewrite Hv. f_equal.
      exact (boot_zero lp m0 _ bo ch z v H12 Hinit (or_intror (or_introl eq_refl)) Hbo Hv).
    Qed.
    Lemma z_bo_any : forall ch z v, 40 <= z -> Mem.load ch m11 bo z = Some v -> v = zeros ch.
    Proof.
      intros ch z v Hz Hl.
      rewrite (ld_back ch bo z (Genv.find_symbol_not_fresh _ _ Hinit Hbo) (unt_bo ch z (or_intror Hz))) in Hl.
      exact (boot_zero lp m0 _ bo ch z v H12 Hinit (or_intror (or_introl eq_refl)) Hbo Hl).
    Qed.
    Ltac peel S := rewrite (Mem.load_store_other _ _ _ _ _ _ S)
      by (first [ left; congruence | right; cbn [size_chunk]; lia ]).

    (* Hhud in find_symbol form, so dz's eassumption sees it *)
    Lemma Hhud_fs : Genv.find_symbol (lp_ge lp) (id "gHudDisplay"%string) = Some bhud.
    Proof. exact Hhud. Qed.

    (* block disequalities among symbols and the fresh blocks *)
    Ltac fr := first [ left; reflexivity | right; left; reflexivity | right; right; reflexivity ].
    Ltac dz := first [ congruence
      | exact bt_bs | exact bt_bar | exact bs_bar | exact bt_bd | exact bs_bd | exact bar_bd
      | apply not_eq_sym; first [ exact bt_bs | exact bt_bar | exact bs_bar | exact bt_bd
                                | exact bs_bd | exact bar_bd ]
      | eapply symne; [ eassumption | eassumption | reflexivity ]
      | eapply sym_ne_bd; eassumption
      | apply not_eq_sym; eapply sym_ne_bd; eassumption
      | eapply sym_ne_fresh; [ eassumption | fr ]
      | apply not_eq_sym; eapply sym_ne_fresh; [ eassumption | fr ]
      | exact bpl_bd | apply not_eq_sym; exact bpl_bd
      | eapply sym_ne_bpl; eassumption | apply not_eq_sym; eapply sym_ne_bpl; eassumption
      | (apply bpl_fresh; fr) | (apply not_eq_sym; apply bpl_fresh; fr) ].
    Ltac peel2 S := rewrite (Mem.load_store_other _ _ _ _ _ _ S)
      by (first [ right; cbn [size_chunk]; lia | left; dz ]).
    Ltac peelW := rewrite (apply_writes_other _ _ _ _ _ _ _ Z9)
      by (let w := fresh "w" in let Hw := fresh "Hw" in
          intros w Hw; rewrite (proj1 (proj2 (tab_writes_shape _ _ _ _ Hw))); dz).
    Ltac peelZ := peel2 Z18; peel2 ZC; peel2 Z17; peel2 Z16; peel2 Z15; peel2 Z14; peel2 Z13; peel2 Z12; peel2 Z11; peel2 Z10;
      peel2 Z10a; peelW; peel2 Z8; peel2 Z7; peel2 Z6; peel2 Z5; peel2 Z4; peel2 Z3; peel2 Z2; peel2 Z1.

    Lemma L_act : Mem.load Mint32 m11 bm 12 = Some (Vint ACT_SPAWN_NO_SPIN_AIRBORNE).
    Proof.
      pose proof ab_bm. peelZ; peel S8; peel S7; peel S6; peel S5; peel S4; peel S3.
      rewrite (Mem.load_store_same _ _ _ _ _ _ S2). reflexivity.
    Qed.
    Lemma L_floor : Mem.load Mint32 m11 bm 104 = Some (Vptr bs Ptrofs.zero).
    Proof.
      pose proof ab_bm. peelZ; peel S8; peel S7; peel S6; peel S5; peel S4.
      rewrite (Mem.load_store_same _ _ _ _ _ _ S3). reflexivity.
    Qed.
    Lemma L_area : Mem.load Mint32 m11 bm 144 = Some (Vptr bar Ptrofs.zero).
    Proof.
      pose proof ab_bm. peelZ; peel S8; peel S7; peel S6; peel S5.
      rewrite (Mem.load_store_same _ _ _ _ _ _ S4). reflexivity.
    Qed.
    Lemma L_ctl : Mem.load Mint32 m11 bm 156 = Some (Vptr bc Ptrofs.zero).
    Proof.
      pose proof ab_bm. peelZ; peel S8; peel S7; peel S6.
      rewrite (Mem.load_store_same _ _ _ _ _ _ S5). reflexivity.
    Qed.
    Lemma L_anim : Mem.load Mint32 m11 bm 160 = Some (Vptr ab Ptrofs.zero).
    Proof.
      pose proof ab_bm. peelZ; peel S8; peel S7.
      rewrite (Mem.load_store_same _ _ _ _ _ _ S6). reflexivity.
    Qed.
    Lemma L_obj : Mem.load Mint32 m11 bm 136 = Some (Vptr bo Ptrofs.zero).
    Proof.
      pose proof ab_bm. peelZ; peel S8.
      rewrite (Mem.load_store_same _ _ _ _ _ _ S7). reflexivity.
    Qed.
    (* m->statusForCamera = &gPlayerCameraState[0] (init_mario_from_save_file) *)
    Lemma L_pcs : Mem.load Mint32 m11 bm 148 = Some (Vptr bpcs Ptrofs.zero).
    Proof.
      peel2 Z18; peel2 ZC; peel2 Z17; peel2 Z16; peel2 Z15; peel2 Z14; peel2 Z13; peel2 Z12; peel2 Z11; peel2 Z10;
      peel2 Z10a; peelW; peel2 Z8; peel2 Z7; peel2 Z6; peel2 Z5; peel2 Z4; peel2 Z3.
      rewrite (Mem.load_store_same _ _ _ _ _ _ Z2). reflexivity.
    Qed.
    (* m->marioBodyState = &gBodyStates[0] (init_mario_from_save_file) *)
    Lemma L_body : Mem.load Mint32 m11 bm 152 = Some (Vptr bbs Ptrofs.zero).
    Proof.
      peel2 Z18; peel2 ZC; peel2 Z17; peel2 Z16; peel2 Z15; peel2 Z14; peel2 Z13; peel2 Z12; peel2 Z11; peel2 Z10;
      peel2 Z10a; peelW; peel2 Z8; peel2 Z7; peel2 Z6; peel2 Z5; peel2 Z4.
      rewrite (Mem.load_store_same _ _ _ _ _ _ Z3). reflexivity.
    Qed.
    Lemma L_buf : Mem.load Mint32 m11 ab 8 = Some (Vptr bt Ptrofs.zero).
    Proof. peelZ. rewrite (Mem.load_store_same _ _ _ _ _ _ S8). reflexivity. Qed.
    Lemma L_styp : Mem.load Mint16signed m11 bs 0 = Some (Vint Int.zero).
    Proof.
      pose proof bs_ab. pose proof bs_bm.
      peelZ; peel S8; peel S7; peel S6; peel S5; peel S4; peel S3; peel S2.
      rewrite (Mem.load_store_same _ _ _ _ _ _ S1). reflexivity.
    Qed.
    Lemma L_posy : Mem.load Mfloat32 m11 bm 64 = Some (Vsingle ENTRY_Y).
    Proof.
      pose proof ab_bm. pose proof bs_bm. pose proof bo_bm.
      peelZ; peel S8; peel S7; peel S6; peel S5; peel S4; peel S3; peel S2; peel S1; peel S1b.
      rewrite (Mem.load_store_same _ _ _ _ _ _ S1a). reflexivity.
    Qed.
    Lemma L_gfx : Mem.load Mfloat32 m11 bo 36 = Some (Vsingle ENTRY_Y).
    Proof.
      pose proof bo_ab. pose proof bs_bo. pose proof bo_bm.
      peelZ; peel S8; peel S7; peel S6; peel S5; peel S4; peel S3; peel S2; peel S1.
      rewrite (Mem.load_store_same _ _ _ _ _ _ S1b). reflexivity.
    Qed.

    (* the pool block and both partitions read exactly what the loader left *)
    Lemma ld_loader : forall ch b z,
        (b = bpl \/ exists pid, In pid part_ids /\ Genv.find_symbol (lp_ge lp) pid = Some b) ->
        Mem.load ch m11 b z = Mem.load ch Lm b z.
    Proof.
      intros ch b z Hb.
      assert (V : Mem.valid_block Lm b).
      { destruct Hb as [-> | (pid & _ & Hs)]; [ exact bpl_lt | ].
        exact (valid_e_L _ (valid_0_e _ (Genv.find_symbol_not_fresh _ _ Hinit Hs))). }
      assert (N : b <> bm /\ b <> bo /\ b <> ab /\ b <> bs).
      { destruct Hb as [-> | (pid & Hin & Hs)].
        - split; [ exact (not_eq_sym (sym_ne_bpl _ _ Hbm)) | ].
          split; [ exact (not_eq_sym (sym_ne_bpl _ _ Hbo)) | ].
          split; [ exact (not_eq_sym (sym_ne_bpl _ _ Hab))
                 | exact (bpl_fresh _ (or_intror (or_introl eq_refl))) ].
        - destruct Hin as [<- | [<- | []]];
            (split; [ exact (symne lp _ _ _ _ Hs Hbm eq_refl) | ]);
            (split; [ exact (symne lp _ _ _ _ Hs Hbo eq_refl) | ]);
            (split; [ exact (symne lp _ _ _ _ Hs Hab eq_refl)
                    | exact (sym_ne_fresh _ _ _ Hs (or_intror (or_introl eq_refl))) ]). }
      destruct N as (N1 & N2 & N3 & N4). pose proof Hhud_fs as Hh.
      destruct Hb as [-> | (pid & Hin & Hs)]; [ | destruct Hin as [<- | [<- | []]] ];
      peelZ; peel S8; peel S7; peel S6; peel S5; peel S4; peel S3; peel S2; peel S1; peel S1b; peel S1a;
      exact (ld_3e _ _ _ V).
    Qed.

    (* the height cells: the real WMotR entry's (WMotREntry.entry_cells),
       with floorHeight the boot image's 0.0 (the witness loads no terrain,
       so it has no find_floor hit to store; Phi asks only >= -11000 here) *)
    Definition c0 : cells := entry_cells Float32.zero.

    Lemma read_c0 : read_cells bm m11 c0.
    Proof.
      unfold read_cells, c0, entry_cells, OFS_ACTION, OFS_ASTATE, OFS_ATIMER, OFS_POSY, OFS_VELY, OFS_FLOORH, OFS_MARIOOBJ.
      cbn [c_action c_state c_timer c_posy c_vely c_floorh c_gfxy].
      split; [ exact L_act | ].
      split; [ rewrite (z_bm Mint16unsigned 24) by (cbn [size_chunk align_chunk]; try lia; try al; cells); reflexivity | ].
      split; [ rewrite (z_bm Mint16unsigned 26) by (cbn [size_chunk align_chunk]; try lia; try al; cells); reflexivity | ].
      split; [ exact L_posy | ].
      split; [ rewrite (z_bm Mfloat32 76) by (cbn [size_chunk align_chunk]; try lia; try al; cells); exact (f_equal Some zeros_f32) | ].
      split; [ rewrite (z_bm Mfloat32 112) by (cbn [size_chunk align_chunk]; try lia; try al; cells); exact (f_equal Some zeros_f32) | ].
      exists bo, Ptrofs.zero. split; [ exact L_obj | ].
      change (Ptrofs.unsigned Ptrofs.zero + OFS_GFXY) with 36. exact L_gfx.
    Qed.

    Lemma budget_c0 : budget_ok c0.
    Proof. apply entry_budget; [ reflexivity | replace (R2 Float32.zero) with 0%R by reflexivity; lra ]. Qed.

    Lemma act_noA : action_sat R_noA m11 bm.
    Proof. intros v Hl. rewrite L_act in Hl. injection Hl as <-. exact entry_action_noA. Qed.

    Lemma hinv : height_invariant bm R_noA m11.
    Proof. split; [ exact act_noA | exists c0; split; [ exact read_c0 | exact budget_c0 ] ]. Qed.

    (* the WMotR world *)
    Lemma world11 : wmotr_world bm m11.
    Proof.
      unfold wmotr_world, HELD_OFF, RIDDEN_OFF, QSD_OFF.
      split; [ intros v Hl; apply z_bm_any in Hl;
               [ rewrite Hl; left; reflexivity | unfold WALL_OFF; cbn [size_chunk]; cells ] | ].
      split; [ intros v Hl; apply z_bm_any in Hl;
               [ rewrite Hl; left; reflexivity | unfold CEIL_OFF; cbn [size_chunk]; cells ] | ].
      split; [ intros v Hl; change FLOOR_OFF with 104 in Hl; rewrite L_floor in Hl; injection Hl as <-;
               exists bs, Ptrofs.zero, Int.zero; split; [ reflexivity | ];
               split; [ exact L_styp | rewrite wmotr_surface_types_value; cbn; tauto ] | ].
      split; [ rewrite (z_bm Mint32 124) by (cbn [size_chunk align_chunk]; try lia; try al; cells); reflexivity | ].
      split; [ rewrite (z_bm Mint32 132) by (cbn [size_chunk align_chunk]; try lia; try al; cells); reflexivity | ].
      split; [ rewrite (z_bm Mfloat32 192) by (cbn [size_chunk align_chunk]; try lia; try al; cells); exact (f_equal Some zeros_f32) | ].
      exists bo, Ptrofs.zero, Int.zero, Int.zero.
      split; [ exact L_obj | ].
      split; [ change (Ptrofs.unsigned Ptrofs.zero + O_INTERACT_STATUS) with 308;
               rewrite (z_bo Mint32 308) by (cbn [size_chunk align_chunk]; try lia; try al); reflexivity | ].
      split; [ reflexivity | ].
      split; [ change (Ptrofs.unsigned Ptrofs.zero + NUMCOLL_OFF) with 118;
               rewrite (z_bo Mint16signed 118) by (cbn [size_chunk align_chunk]; try lia; try al); reflexivity | ].
      split; [ rewrite Int.signed_zero; lia | ].
      intros i v Hi. exfalso. rewrite Int.signed_zero in Hi. lia.
    Qed.

    Lemma not_ptr0 : forall ch b o, zeros ch = Vptr b o -> False.
    Proof. intros ch b o E. destruct ch; discriminate E. Qed.

    Lemma coll_noptr : forall i cb co, 0 <= i < 4 -> Mem.load Mint32 m11 bo (Ptrofs.unsigned Ptrofs.zero + COLL_OFF + 4 * i)
                                       = Some (Vptr cb co) -> False.
    Proof.
      intros i cb co Hi Hl.
      assert (Hz : 40 <= Ptrofs.unsigned Ptrofs.zero + COLL_OFF + 4 * i)
        by (change (Ptrofs.unsigned Ptrofs.zero) with 0; unfold COLL_OFF; lia).
      exact (not_ptr0 _ _ _ (eq_sym (z_bo_any _ _ _ Hz Hl))).
    Qed.

    Lemma wc_noptr : forall off sb so, off = WALL_OFF \/ off = CEIL_OFF ->
        Mem.load Mint32 m11 bm off = Some (Vptr sb so) -> False.
    Proof.
      intros off sb so Hoff Hl. apply z_bm_any in Hl.
      - exact (not_ptr0 _ _ _ (eq_sym Hl)).
      - destruct Hoff as [-> | ->]; unfold WALL_OFF, CEIL_OFF; cbn [size_chunk]; cells.
    Qed.

    Lemma anim_ok : anim_apart lp bm m11.
    Proof.
      intros ab' bt' ot' Hab' Hl. rewrite Hab in Hab'. injection Hab' as <-.
      change (Mem.load Mint32 m11 ab 8 = Some (Vptr bt' ot')) in Hl.
      rewrite L_buf in Hl. injection Hl as <- <-.
      split.
      - intros off sb so Hoff Hl.
        destruct Hoff as [E | [E | E]].
        + exfalso. exact (wc_noptr off sb so (or_introl E) Hl).
        + exfalso. exact (wc_noptr off sb so (or_intror E) Hl).
        + subst off. change FLOOR_OFF with 104 in Hl. rewrite L_floor in Hl.
          injection Hl as <- _. exact bt_bs.
      - intros mb mo i cb co Hm Hi Hl. change MARIOOBJ_OFF with 136 in Hm. rewrite L_obj in Hm.
        injection Hm as <- <-. exfalso. exact (coll_noptr _ _ _ Hi Hl).
    Qed.

    Lemma mobj_ok : mobj_apart bm m11.
    Proof.
      intros mb mo Hm. change MARIOOBJ_OFF with 136 in Hm. rewrite L_obj in Hm.
      injection Hm as <- <-.
      split; [ unfold OBJ_SIZE; vm_compute; discriminate | ].
      split.
      - intros off sb so Hoff Hl.
        destruct Hoff as [E | [E | E]].
        + exfalso. exact (wc_noptr off sb so (or_introl E) Hl).
        + exfalso. exact (wc_noptr off sb so (or_intror E) Hl).
        + subst off. change FLOOR_OFF with 104 in Hl. rewrite L_floor in Hl.
          injection Hl as <- _. exact bs_bo.
      - intros i cb co Hi Hl. exfalso. exact (coll_noptr _ _ _ Hi Hl).
    Qed.

    (* ---- the frame world ffw ---- *)
    Definition thr : block := Mem.nextblock m11.

    Lemma vinj_ptr : forall b o, Plt b thr -> Val.inject (Mem.flat_inj thr) (Vptr b o) (Vptr b o).
    Proof.
      intros b o H. econstructor; [ unfold Mem.flat_inj; destruct (plt b thr); [ reflexivity | contradiction ] | ].
      rewrite Ptrofs.add_zero. reflexivity.
    Qed.

    Lemma neutral11 : Mem.inject_neutral thr m11.
    Proof.
      assert (T : thr = Pos.succ (Pos.succ (Pos.succ (Pos.succ NL))))
        by (unfold thr; rewrite nb11, nb3; reflexivity).
      pose proof nb0_NL as HNL.
      assert (P00 : Ple (Mem.nextblock m0) thr) by (rewrite T; unfold Ple, Plt in *; lia).
      pose proof (boot_neutral lp m0 thr Hinit P00) as N00.
      assert (Lbw : Plt bw thr) by exact (sym_lt _ _ Hbw).
      assert (LbL : Plt bL thr) by exact (sym_lt _ _ HbL).
      pose proof (Mem.store_inject_neutral _ _ _ _ _ _ _ E1 N00 Lbw (Val.inject_int _ _)) as Ne1.
      pose proof (Mem.store_inject_neutral _ _ _ _ _ _ _ E2 Ne1 Lbw (Val.inject_int _ _)) as Ne2.
      pose proof (Mem.store_inject_neutral _ _ _ _ _ _ _ E3 Ne2 Lbw (Val.inject_int _ _)) as Ne3.
      pose proof (Mem.store_inject_neutral _ _ _ _ _ _ _ E4 Ne3 Lbw (Val.inject_int _ _)) as Ne4.
      pose proof (Mem.store_inject_neutral _ _ _ _ _ _ _ E5 Ne4 Lbw (Val.inject_int _ _)) as Ne5.
      pose proof (Mem.store_inject_neutral _ _ _ _ _ _ _ E6 Ne5 LbL (Val.inject_int _ _)) as N0.
      (* the load: unchanged blocks keep the boot image's closure, the
         loader's pointers aim below nextblock (frag_ok) *)
      assert (NLm : Mem.inject_neutral thr Lm).
      { apply (neutral_frame (lp_ge lp) thr e6 Lm bpl N0);
          [ | exact keep_eL | rewrite bpl_eq, nb_e; reflexivity | exact OK | exact FR ].
        rewrite T. unfold NL, Ple. lia. }
      pose proof (Mem.alloc_inject_neutral _ _ _ _ _ _ A1 NLm ltac:(rewrite T; unfold NL, Plt; lia)) as N1.
      pose proof (Mem.alloc_inject_neutral _ _ _ _ _ _ A2 N1
                    ltac:(rewrite T, (Mem.nextblock_alloc _ _ _ _ _ A1); unfold NL, Plt; lia)) as N2.
      pose proof (Mem.alloc_inject_neutral _ _ _ _ _ _ A3 N2
                    ltac:(rewrite T, (Mem.nextblock_alloc _ _ _ _ _ A2),
                            (Mem.nextblock_alloc _ _ _ _ _ A1); unfold NL, Plt; lia)) as N2b.
      pose proof (Mem.alloc_inject_neutral _ _ _ _ _ _ A4 N2b
                    ltac:(rewrite T, (Mem.nextblock_alloc _ _ _ _ _ A3), (Mem.nextblock_alloc _ _ _ _ _ A2),
                            (Mem.nextblock_alloc _ _ _ _ _ A1); unfold NL, Plt; lia)) as N3.
      assert (Lbm : Plt bm thr) by exact (sym_lt _ _ Hbm).
      assert (Lab : Plt ab thr) by exact (sym_lt _ _ Hab).
      assert (Lbo : Plt bo thr) by exact (sym_lt _ _ Hbo).
      assert (Lbc : Plt bc thr) by exact (sym_lt _ _ Hbc).
      assert (Lbt : Plt bt thr) by exact (fresh_lt _ (or_introl eq_refl)).
      assert (Lbs : Plt bs thr) by exact (fresh_lt _ (or_intror (or_introl eq_refl))).
      assert (Lbar : Plt bar thr) by exact (fresh_lt _ (or_intror (or_intror eq_refl))).
      pose proof (Mem.store_inject_neutral _ _ _ _ _ _ _ S1a N3 Lbm (Val.inject_single _ _)) as N3a.
      pose proof (Mem.store_inject_neutral _ _ _ _ _ _ _ S1b N3a Lbo (Val.inject_single _ _)) as N3b.
      pose proof (Mem.store_inject_neutral _ _ _ _ _ _ _ S1 N3b Lbs (Val.inject_int _ _)) as N4.
      pose proof (Mem.store_inject_neutral _ _ _ _ _ _ _ S2 N4 Lbm (Val.inject_int _ _)) as N5.
      pose proof (Mem.store_inject_neutral _ _ _ _ _ _ _ S3 N5 Lbm (vinj_ptr _ _ Lbs)) as N6.
      pose proof (Mem.store_inject_neutral _ _ _ _ _ _ _ S4 N6 Lbm (vinj_ptr _ _ Lbar)) as N7.
      pose proof (Mem.store_inject_neutral _ _ _ _ _ _ _ S5 N7 Lbm (vinj_ptr _ _ Lbc)) as N8.
      pose proof (Mem.store_inject_neutral _ _ _ _ _ _ _ S6 N8 Lbm (vinj_ptr _ _ Lab)) as N9.
      pose proof (Mem.store_inject_neutral _ _ _ _ _ _ _ S7 N9 Lbm (vinj_ptr _ _ Lbo)) as N10.
      pose proof (Mem.store_inject_neutral _ _ _ _ _ _ _ S8 N10 Lab (vinj_ptr _ _ Lbt)) as Ns.
      assert (Lbsi : Plt bsi thr) by exact (sym_lt _ _ Hsi).
      assert (Lbpcs : Plt bpcs thr) by exact (sym_lt _ _ Hpcs).
      assert (Lbbs : Plt bbs thr) by exact (sym_lt _ _ Hbbs).
      assert (Lhud : Plt bhud thr) by exact (sym_lt _ _ Hhud).
      assert (Lbd : Plt bd thr) by exact bd_lt.
      pose proof (Mem.store_inject_neutral _ _ _ _ _ _ _ Z1 Ns Lbm (vinj_ptr _ _ Lbsi)) as W1.
      pose proof (Mem.store_inject_neutral _ _ _ _ _ _ _ Z2 W1 Lbm (vinj_ptr _ _ Lbpcs)) as W2.
      pose proof (Mem.store_inject_neutral _ _ _ _ _ _ _ Z3 W2 Lbm (vinj_ptr _ _ Lbbs)) as W3.
      pose proof (Mem.store_inject_neutral _ _ _ _ _ _ _ Z4 W3 Lbm (Val.inject_int _ _)) as W4.
      pose proof (Mem.store_inject_neutral _ _ _ _ _ _ _ Z5 W4 Lbm (Val.inject_int _ _)) as W5.
      pose proof (Mem.store_inject_neutral _ _ _ _ _ _ _ Z6 W5 Lbm (Val.inject_int _ _)) as W6.
      pose proof (Mem.store_inject_neutral _ _ _ _ _ _ _ Z7 W6 Lhud (Val.inject_int _ _)) as W7.
      pose proof (Mem.store_inject_neutral _ _ _ _ _ _ _ Z8 W7 Lbar (Val.inject_int _ _)) as W8.
      assert (Lga : Plt bga thr) by exact (sym_lt _ _ Hga).
      assert (W9 : Mem.inject_neutral thr z9).
      { apply (apply_writes_ind (Mem.inject_neutral thr) _ _ _ _ Z9); [ | exact W8 ].
        intros w mm mm' Hw Hs Hm.
        destruct (tab_writes_shape _ _ _ _ Hw) as (_ & Eb & Hv). rewrite Eb in Hs.
        apply (Mem.store_inject_neutral _ _ _ _ _ _ _ Hs Hm Lbd).
        destruct Hv as [-> | Hv]; [ exact (vinj_ptr _ _ Lga) | ].
        destruct (w_val w); try constructor. exfalso. exact (Hv _ _ eq_refl). }
      pose proof (Mem.store_inject_neutral _ _ _ _ _ _ _ Z10a W9 Lab (vinj_ptr _ _ Lbd)) as W10a.
      assert (W10 : Mem.inject_neutral thr z10).
      { apply (Mem.store_inject_neutral _ _ _ _ _ _ _ Z10 W10a Lab).
        unfold cur_addr. match goal with |- context [match ?x with _ => _ end] => destruct x as [[]|] end; try constructor.
        exact (vinj_ptr _ _ Lga). }
      pose proof (Mem.store_inject_neutral _ _ _ _ _ _ _ Z11 W10 Lbt (Val.inject_int _ _)) as W11.
      pose proof (Mem.store_inject_neutral _ _ _ _ _ _ _ Z12 W11 Lbt (Val.inject_int _ _)) as W12.
      pose proof (Mem.store_inject_neutral _ _ _ _ _ _ _ Z13 W12 Lbt (Val.inject_int _ _)) as W13.
      pose proof (Mem.store_inject_neutral _ _ _ _ _ _ _ Z14 W13 Lbt (Val.inject_int _ _)) as W14.
      pose proof (Mem.store_inject_neutral _ _ _ _ _ _ _ Z15 W14 Lbt (Val.inject_int _ _)) as W15.
      pose proof (Mem.store_inject_neutral _ _ _ _ _ _ _ Z16 W15 Lbt (Val.inject_int _ _)) as W16.
      assert (LbC : Plt bC thr) by exact (sym_lt _ _ HcC).
      pose proof (Mem.store_inject_neutral _ _ _ _ _ _ _ Z17 W16 LbC (Val.inject_int _ _)) as W17.
      assert (Lpads : Plt bpads thr) by exact (sym_lt _ _ Hpads).
      pose proof (Mem.store_inject_neutral _ _ _ _ _ _ _ ZC W17 Lbc (vinj_ptr _ _ Lpads)) as W18.
      assert (Lbw17 : Plt bw thr) by exact (sym_lt _ _ Hbw).
      exact (Mem.store_inject_neutral _ _ _ _ _ _ _ Z18 W18 Lbw17 (Val.inject_int _ _)).
    Qed.

    Lemma closed11 : closed_by (Mem.flat_inj thr) m11.
    Proof.
      split.
      - intros b b' d H. unfold Mem.flat_inj in H.
        destruct (plt b thr); [ injection H as <- <-; auto | discriminate ].
      - exact (Mem.neutral_inject m11 neutral11).
    Qed.

    Lemma flat_some : forall b, Plt b thr -> Mem.flat_inj thr b <> None.
    Proof. intros b H. unfold Mem.flat_inj. destruct (plt b thr); [ discriminate | contradiction ]. Qed.

    (* every old block keeps the boot image's permissions, both ways *)
    Lemma keep_0_11 : acc_keep m0 m11.
    Proof.
      eapply acc_keep_trans; [ exact (store_keep _ _ _ _ _ _ E1) | ].
      eapply acc_keep_trans; [ exact (store_keep _ _ _ _ _ _ E2) | ].
      eapply acc_keep_trans; [ exact (store_keep _ _ _ _ _ _ E3) | ].
      eapply acc_keep_trans; [ exact (store_keep _ _ _ _ _ _ E4) | ].
      eapply acc_keep_trans; [ exact (store_keep _ _ _ _ _ _ E5) | ].
      eapply acc_keep_trans; [ exact (store_keep _ _ _ _ _ _ E6) | ].
      eapply acc_keep_trans; [ exact keep_eL | ].
      eapply acc_keep_trans; [ exact (alloc_keep _ _ _ _ _ A1) | ].
      eapply acc_keep_trans; [ exact (alloc_keep _ _ _ _ _ A2) | ].
      eapply acc_keep_trans; [ exact (alloc_keep _ _ _ _ _ A3) | ].
      eapply acc_keep_trans; [ exact (alloc_keep _ _ _ _ _ A4) | ].
      eapply acc_keep_trans; [ exact (store_keep _ _ _ _ _ _ S1a) | ].
      eapply acc_keep_trans; [ exact (store_keep _ _ _ _ _ _ S1b) | ].
      eapply acc_keep_trans; [ exact (store_keep _ _ _ _ _ _ S1) | ].
      eapply acc_keep_trans; [ exact (store_keep _ _ _ _ _ _ S2) | ].
      eapply acc_keep_trans; [ exact (store_keep _ _ _ _ _ _ S3) | ].
      eapply acc_keep_trans; [ exact (store_keep _ _ _ _ _ _ S4) | ].
      eapply acc_keep_trans; [ exact (store_keep _ _ _ _ _ _ S5) | ].
      eapply acc_keep_trans; [ exact (store_keep _ _ _ _ _ _ S6) | ].
      eapply acc_keep_trans; [ exact (store_keep _ _ _ _ _ _ S7) | ].
      eapply acc_keep_trans; [ exact (store_keep _ _ _ _ _ _ S8) | ].
      eapply acc_keep_trans; [ exact (store_keep _ _ _ _ _ _ Z1) | ].
      eapply acc_keep_trans; [ exact (store_keep _ _ _ _ _ _ Z2) | ].
      eapply acc_keep_trans; [ exact (store_keep _ _ _ _ _ _ Z3) | ].
      eapply acc_keep_trans; [ exact (store_keep _ _ _ _ _ _ Z4) | ].
      eapply acc_keep_trans; [ exact (store_keep _ _ _ _ _ _ Z5) | ].
      eapply acc_keep_trans; [ exact (store_keep _ _ _ _ _ _ Z6) | ].
      eapply acc_keep_trans; [ exact (store_keep _ _ _ _ _ _ Z7) | ].
      eapply acc_keep_trans; [ exact (store_keep _ _ _ _ _ _ Z8) | ].
      eapply acc_keep_trans; [ exact (apply_writes_keep _ _ _ _ Z9) | ].
      eapply acc_keep_trans; [ exact (store_keep _ _ _ _ _ _ Z10a) | ].
      eapply acc_keep_trans; [ exact (store_keep _ _ _ _ _ _ Z10) | ].
      eapply acc_keep_trans; [ exact (store_keep _ _ _ _ _ _ Z11) | ].
      eapply acc_keep_trans; [ exact (store_keep _ _ _ _ _ _ Z12) | ].
      eapply acc_keep_trans; [ exact (store_keep _ _ _ _ _ _ Z13) | ].
      eapply acc_keep_trans; [ exact (store_keep _ _ _ _ _ _ Z14) | ].
      eapply acc_keep_trans; [ exact (store_keep _ _ _ _ _ _ Z15) | ].
      eapply acc_keep_trans; [ exact (store_keep _ _ _ _ _ _ Z16) | ].
      eapply acc_keep_trans; [ exact (store_keep _ _ _ _ _ _ Z17) | ].
      eapply acc_keep_trans; [ exact (store_keep _ _ _ _ _ _ ZC) | ].
      exact (store_keep _ _ _ _ _ _ Z18).
    Qed.

    Lemma perm_0_11 : forall b z k p, Plt b (Mem.nextblock m0) ->
        (Mem.perm m11 b z k p <-> Mem.perm m0 b z k p).
    Proof. intros b z k p Hb. exact (perm_same m11 m0 b z k p (proj2 keep_0_11 b Hb)). Qed.

    Lemma pfwd : forall b z k p, Mem.perm m0 b z k p -> Mem.perm m11 b z k p.
    Proof.
      intros b z k p H. exact (proj2 (perm_0_11 b z k p (Mem.perm_valid_block _ _ _ _ _ H)) H).
    Qed.

    (* every partition word is a list the walk accepted *)
    Lemma wf_head : forall hd, part_head (lp_ge lp) m11 hd -> walk2 WFUEL m11 bpl hd = true.
    Proof.
      intros hd (pid & pb & o & Hin & Hfs & Hl). cbn [Mem.loadv] in Hl.
      pose proof (Mem.load_valid_access _ _ _ _ _ Hl) as (RP & Al).
      assert (Pz : Mem.perm m0 pb (Ptrofs.unsigned o) Cur Readable).
      { apply (perm_0_11 _ _ _ _ (sym_old _ _ Hfs)). apply RP. cbn [size_chunk]. lia. }
      pose proof (part_bound lp H12 m0 Hinit pid pb Hin Hfs _ _ _ Pz) as Bz.
      destruct Al as (k & Hk). cbn [align_chunk] in Hk.
      apply (wff_parts_sound _ _ _ _ WP pid pb k hd Hin Hfs); [ lia | ].
      rewrite <- Hl. f_equal. lia.
    Qed.

    Lemma bpl_valid11 : Mem.valid_block m11 bpl.
    Proof. unfold Mem.valid_block. rewrite nb11, nb3. pose proof bpl_lt. unfold Plt in *. lia. Qed.
    Lemma bpl_not_static : ~ is_static (lp_ge lp) bpl.
    Proof. intros (id & _ & Hs). exact (sym_ne_bpl _ _ Hs eq_refl). Qed.

    Ltac neq :=
      first [ exact bt_bs | exact bt_bar | exact bs_bar
            | apply not_eq_sym; first [ exact bt_bs | exact bt_bar | exact bs_bar ]
            | eapply symne; [ eassumption | eassumption | reflexivity ]
            | eapply sym_ne_fresh; [ eassumption
                                   | first [ left; reflexivity | right; left; reflexivity
                                           | right; right; reflexivity ] ]
            | apply not_eq_sym; eapply sym_ne_fresh;
              [ eassumption
              | first [ left; reflexivity | right; left; reflexivity | right; right; reflexivity ] ]
            | eapply sym_ne_bpl; eassumption
            | apply not_eq_sym; eapply sym_ne_bpl; eassumption
            | exact (bpl_fresh _ (or_introl eq_refl))
            | apply not_eq_sym; exact (bpl_fresh _ (or_introl eq_refl)) ].

    Ltac norl := let o := fresh "o" in let Hin := fresh "Hin" in
      intros (o & Hin); cbn [ff_rl map In] in Hin;
      repeat (destruct Hin as [Hin | Hin];
              [ injection Hin as Hin; revert Hin; neq | ]);
      destruct Hin.

    Lemma Hpcs_fs : Genv.find_symbol (lp_ge lp) camera._gPlayerCameraState = Some bpcs.
    Proof. exact Hpcs. Qed.
    Lemma Hbbs_fs : Genv.find_symbol (lp_ge lp) mario._gBodyStates = Some bbs.
    Proof. exact Hbbs. Qed.

    Definition RL : list (option val) := ff_rl bm bo Ptrofs.zero bfi bmiss bcalls ab bt biom bmq brm blk bpcs bsr bsrc bsms bbs bfa.

    Lemma bpl_not_rl : ~ rblk RL bpl.
    Proof. unfold RL. norl. Qed.

    (* the partitions' lists: nodes and surfaces in the pool block, every
       surface of a WMotR type (StartTerrain.walk2) *)
    Lemma part_lists : forall hd, part_head (lp_ge lp) m11 hd ->
        wf_list m11 (fun b => is_static (lp_ge lp) b \/ rblk RL b) hd
        /\ (forall s, on_list m11 hd s -> exists o, s = Vptr bpl o
              /\ Ptrofs.unsigned o + SZ_SURFACE <= Ptrofs.modulus /\ styp m11 bpl o).
    Proof.
      intros hd Hp. apply (walk2_sound WFUEL m11 bpl _ hd (wf_head _ Hp) bpl_valid11).
      intros [H | H]; [ exact (bpl_not_static H) | exact (bpl_not_rl H) ].
    Qed.

    Lemma wff11 : Wff (lp_ge lp) m11 (Mem.flat_inj thr) SZ_SURFACE RL.
    Proof.
      unfold Wff, RL.
      split.
      { intros id sz Hin. cbn [w_cells In] in Hin.
        destruct Hin as [E | [E | [E | []]]]; injection E as <- <-.
        - exists bfi. split; [ exact Hfi | ].
          intros z Hz. apply pfwd.
          exact (wr_sym _ _ _ bfi LO_olp dm_fi eq_refl eq_refl ltac:(cbn; discriminate) Hfi z Hz).
        - exists bmiss. split; [ exact Hmiss | ].
          intros z Hz. apply pfwd.
          exact (wr_sym _ _ _ bmiss LO_olp dm_miss eq_refl eq_refl ltac:(cbn; discriminate) Hmiss z Hz).
        - exists bcalls. split; [ exact Hcalls | ].
          intros z Hz. apply pfwd.
          exact (wr_sym _ _ _ bcalls LO_olp dm_calls eq_refl eq_refl ltac:(cbn; discriminate) Hcalls z Hz). }
      split.
      { intros id bp Hid Hfs. split; [ exact (sym_lt _ _ Hfs) | ].
        split.
        - destruct Hid as [<- | [<- | []]]; norl.
        - intros (id' & Hin' & Hfs').
          assert (E : id' = id) by (eapply Genv.genv_vars_inj; [ exact Hfs' | exact Hfs ]). subst id'.
          destruct Hid as [<- | [<- | []]]; cbn [ff_statics In] in Hin';
            repeat (destruct Hin' as [E | Hin']; [ cbv in E; discriminate E | ]); destruct Hin'. }
      split; [ intros hd Hp; exact (proj1 (part_lists _ Hp)) | ].
      split.
      { intros hd s Hp Ho. destruct (proj2 (part_lists _ Hp) s Ho) as (o & -> & Hsz & _).
        exists bpl, o. split; [ reflexivity | ].
        split; [ exact bpl_valid11 | ].
        split; [ exact Hsz | ].
        split; [ exact bpl_not_rl | exact (flat_some _ bpl_valid11) ]. }
      split.
      { intros hd b o Hp Ho. destruct (proj2 (part_lists _ Hp) _ Ho) as (o' & E & _ & St).
        injection E as -> ->. exact St. }
      split.
      { (* the pool block is allocated after init_mem: dynamic *)
        intros hd Hp. split.
        - refine (proj1 (walk2_sound WFUEL m11 bpl _ hd (wf_head _ Hp) bpl_valid11 _)).
          rewrite genv_next_eq. intros H. cbv beta in H. pose proof bpl_ge as G. unfold Plt, Ple in *. lia.
        - intros b o Ho. destruct (proj2 (part_lists _ Hp) _ Ho) as (o' & E & _ & _).
          injection E as -> _. rewrite genv_next_eq. exact bpl_ge. }
      unfold SZ_SURFACE. lia.
    Qed.

    (* GOAL 2's floor premise and the decoder agreement, on the witness *)
    Lemma floor_data11 : floor_data (lp_ge lp) m11.
    Proof. exact (parts_ok_floor_data _ _ _ PO). Qed.
    Lemma static_agree11 : static_agree (lp_ge lp) m11.
    Proof. exact (parts_ok_agree _ _ _ PO). Qed.


    (* ---- the animation world (AnimWorld.anim_w) on the witness ---- *)
    Lemma keep_1_11 : acc_keep m1 m11.
    Proof.
      eapply acc_keep_trans; [ exact (alloc_keep _ _ _ _ _ A2) | ].
      eapply acc_keep_trans; [ exact (alloc_keep _ _ _ _ _ A3) | ].
      eapply acc_keep_trans; [ exact (alloc_keep _ _ _ _ _ A4) | ].
      eapply acc_keep_trans; [ exact (store_keep _ _ _ _ _ _ S1a) | ].
      eapply acc_keep_trans; [ exact (store_keep _ _ _ _ _ _ S1b) | ].
      eapply acc_keep_trans; [ exact (store_keep _ _ _ _ _ _ S1) | ].
      eapply acc_keep_trans; [ exact (store_keep _ _ _ _ _ _ S2) | ].
      eapply acc_keep_trans; [ exact (store_keep _ _ _ _ _ _ S3) | ].
      eapply acc_keep_trans; [ exact (store_keep _ _ _ _ _ _ S4) | ].
      eapply acc_keep_trans; [ exact (store_keep _ _ _ _ _ _ S5) | ].
      eapply acc_keep_trans; [ exact (store_keep _ _ _ _ _ _ S6) | ].
      eapply acc_keep_trans; [ exact (store_keep _ _ _ _ _ _ S7) | ].
      eapply acc_keep_trans; [ exact (store_keep _ _ _ _ _ _ S8) | ].
      eapply acc_keep_trans; [ exact (store_keep _ _ _ _ _ _ Z1) | ].
      eapply acc_keep_trans; [ exact (store_keep _ _ _ _ _ _ Z2) | ].
      eapply acc_keep_trans; [ exact (store_keep _ _ _ _ _ _ Z3) | ].
      eapply acc_keep_trans; [ exact (store_keep _ _ _ _ _ _ Z4) | ].
      eapply acc_keep_trans; [ exact (store_keep _ _ _ _ _ _ Z5) | ].
      eapply acc_keep_trans; [ exact (store_keep _ _ _ _ _ _ Z6) | ].
      eapply acc_keep_trans; [ exact (store_keep _ _ _ _ _ _ Z7) | ].
      eapply acc_keep_trans; [ exact (store_keep _ _ _ _ _ _ Z8) | ].
      eapply acc_keep_trans; [ exact (apply_writes_keep _ _ _ _ Z9) | ].
      eapply acc_keep_trans; [ exact (store_keep _ _ _ _ _ _ Z10a) | ].
      eapply acc_keep_trans; [ exact (store_keep _ _ _ _ _ _ Z10) | ].
      eapply acc_keep_trans; [ exact (store_keep _ _ _ _ _ _ Z11) | ].
      eapply acc_keep_trans; [ exact (store_keep _ _ _ _ _ _ Z12) | ].
      eapply acc_keep_trans; [ exact (store_keep _ _ _ _ _ _ Z13) | ].
      eapply acc_keep_trans; [ exact (store_keep _ _ _ _ _ _ Z14) | ].
      eapply acc_keep_trans; [ exact (store_keep _ _ _ _ _ _ Z15) | ].
      eapply acc_keep_trans; [ exact (store_keep _ _ _ _ _ _ Z16) | ].
      eapply acc_keep_trans; [ exact (store_keep _ _ _ _ _ _ Z17) | ].
      eapply acc_keep_trans; [ exact (store_keep _ _ _ _ _ _ ZC) | ].
      exact (store_keep _ _ _ _ _ _ Z18).
    Qed.

    Lemma L_tab : Mem.load Mint32 m11 ab 0 = Some (Vptr bd Ptrofs.zero).
    Proof.
      peel2 Z18; peel2 ZC; peel2 Z17; peel2 Z16; peel2 Z15; peel2 Z14; peel2 Z13; peel2 Z12; peel2 Z11; peel2 Z10.
      rewrite (Mem.load_store_same _ _ _ _ _ _ Z10a). reflexivity.
    Qed.

    Lemma bt_perm : Mem.range_perm m11 bt 0 16384 Cur Readable.
    Proof.
      intros z Hz.
      assert (P1 : Mem.perm m1 bt z Cur Freeable) by (eapply Mem.perm_alloc_2; [ exact A1 | lia ]).
      assert (V1 : Plt bt (Mem.nextblock m1)).
      { rewrite (Mem.nextblock_alloc _ _ _ _ _ A1), (Mem.alloc_result _ _ _ _ _ A1). apply Plt_succ. }
      apply (proj2 (perm_same m11 m1 bt z Cur Readable (proj2 keep_1_11 bt V1))).
      eapply Mem.perm_implies; [ exact P1 | constructor ].
    Qed.

    Lemma dm_ga : (prog_defmap mario_anim_data.prog) ! game_init._gMarioAnims
                  = Some (Gvar mario_anim_data.v_gMarioAnims).
    Proof. reflexivity. Qed.

    Lemma ga_perm : Mem.range_perm m11 bga 0 AnimData.GA_SIZE Cur Readable.
    Proof.
      intros z Hz. apply pfwd. rewrite <- AnimData.ga_size in Hz.
      refine (lo_gvar_readable _ _ _ _ _ _ (linked12_LO_mario_anim_data lp H12) Hinit dm_ga
                eq_refl ltac:(discriminate) Hga z Hz).
    Qed.

    Lemma anim11 : AnimWorld.anim_w (lp_ge lp) bm m11.
    Proof.
      assert (Eau : exists gd, (prog_defmap rendering_graph_node.prog) ! graph_node._gAreaUpdateCounter = Some gd).
      { destruct ((prog_defmap rendering_graph_node.prog) ! graph_node._gAreaUpdateCounter) as [gd|] eqn:E;
          [ exists gd; reflexivity | vm_compute in E; discriminate E ]. }
      destruct Eau as (gd & Egd).
      destruct (ex_sym _ _ _ (linked12_LO_rendering_graph_node lp H12) Egd) as (bauc & Hau).
      pose proof (tab_chk_sound _ _ _ TC) as (T0 & T4 & TE).
      eapply (AnimWorld.anim_w_other (lp_ge lp) bm m11 _ ab bga bauc bd Ptrofs.zero bt Ptrofs.zero bo Ptrofs.zero);
        [ | exact L_act | ].
      2:{ intros H. vm_compute in H. repeat (destruct H as [H | H]; [ discriminate H | ]). exact H. }
      unfold AnimWorld.anim_base. rewrite !Ptrofs.unsigned_zero.
      split; [ exact Hab | ]. split; [ exact Hga | ]. split; [ exact Hau | ].
      split; [ exact L_tab | ]. split; [ exact L_buf | ]. split; [ exact L_obj | ].
      split; [ intros id b Hs; split; [ exact (sym_ne_bd _ _ Hs) | exact (sym_ne_fresh _ _ _ Hs (or_introl eq_refl)) ] | ].
      split; [ exact (not_eq_sym bt_bd) | ].
      split; [ exact (not_eq_sym (sym_ne_bd _ _ Hbo)) | ].
      split; [ exact bt_bo | ].
      split; [ exact (symne lp _ _ _ _ Hbo Hga eq_refl) | ].
      split; [ split; [ exact (symne lp _ _ _ _ Hbo Hau eq_refl) | ] | ].
      { (* the flanks' globals (the render globals and the platform step's
           D_8032FEC0): apart from Mario's object (a gObjectPool slot) and
           off the partition (its nodes live in the pool block) *)
        intros id b Hin Hs. split.
        - unfold AnimWorld.flank_gvars, RenderAnim.render_gvars in Hin. cbn [app] in Hin.
          repeat (destruct Hin as [<- | Hin]; [ exact (symne lp _ _ _ _ Hs Hbo eq_refl) | ]).
          destruct Hin.
        - intros hd Hp.
          destruct (walk2_sound WFUEL m11 bpl (fun x => x = b) hd (wf_head _ Hp) bpl_valid11
                      (not_eq_sym (sym_ne_bpl _ _ Hs))) as (Wl & On).
          split; [ exact Wl | ]. intros b' o Ho. destruct (On _ Ho) as (o' & E & _). injection E as -> _.
          exact (not_eq_sym (sym_ne_bpl _ _ Hs)). }
      split; [ unfold AnimWorld.TABSZ, AnimData.ANIM_COUNT; change Ptrofs.modulus with 4294967296; lia | ].
      split; [ unfold AnimWorld.BUFSZ; change Ptrofs.modulus with 4294967296; lia | ].
      split; [ reflexivity | ].
      split; [ exact bt_perm | ].
      split.
      { unfold AnimWorld.tab_ok. rewrite Ptrofs.unsigned_zero.
        split; [ exact T0 | ]. split; [ exact T4 | ].
        intros j o s' Hj. rewrite !Z.add_0_l. exact (TE j o s' Hj). }
      split; [ split; [ exact (ga_chk_sound _ _ GC) | exact ga_perm ] | ].
      split.
      { intros hd Hp. destruct (walk2_sound WFUEL m11 bpl (fun b => b = bd) hd (wf_head _ Hp) bpl_valid11 bpl_bd)
          as (Wl & On).
        split; [ exact Wl | ]. intros b o Ho. destruct (On _ Ho) as (o' & E & _). injection E as -> _.
        exact bpl_bd. }
      split; [ | exact Hbm ].
      intros off b o [-> | ->] Hl.
      - rewrite L_area in Hl. injection Hl as <- _. exact bar_bd.
      - rewrite L_ctl in Hl. injection Hl as <- _. exact (sym_ne_bd _ _ Hbc).
    Qed.

    Lemma ffw11 : ffw (lp_ge lp) bm m11.
    Proof.
      split.
      { rewrite genv_next_eq, nb11, nb3. pose proof nb0_NL. unfold Ple, Plt in *. lia. }
      split.
      2: exact floor_data11.
      pose proof Hpcs_fs as Hpcs'. pose proof Hbbs_fs as Hbbs'.
      exists (Mem.flat_inj thr), bfi, bmiss, bcalls, bsin, ab, biom, bmq, brm, blk, bpcs, bsr, bsrc, bsms, bbs, bfa, bo, Ptrofs.zero,
        bt, Ptrofs.zero, (Vptr bs Ptrofs.zero), (Vptr bar Ptrofs.zero), Int.zero, (Vptr bc Ptrofs.zero).
      split; [ exact closed11 | ].
      split; [ intros id b Hfs; exact (flat_some _ (sym_lt _ _ Hfs)) | ].
      split; [ exact (flat_some _ (sym_lt _ _ Hbm)) | ].
      do 15 (split; [ assumption | ]).
      split; [ exact L_obj | ].
      split; [ unfold SZ_OBJECT; vm_compute; discriminate | ].
      split; [ exact L_anim | ].
      split; [ exact L_buf | ].
      split; [ vm_compute; discriminate | ].
      split; [ exact bo_bm | ].
      split; [ intro E; exact (sym_ne_fresh _ _ _ Hbm (or_introl eq_refl) (eq_sym E)) | ].
      split; [ exact bt_bo | ].
      split; [ intros b [Hin | [Hin | Hin]];
               [ cbn [In] in Hin; repeat (destruct Hin as [<- | Hin]; [ split; neq | ]); destruct Hin
               | split; neq | lvl_cases Hin; split; neq ] | ].
      split; [ exact wff11 | ].
      split; [ exact L_floor | ].
      split.
      { exists bs, Ptrofs.zero. split; [ reflexivity | ].
        split; [ exact (fresh_lt _ (or_intror (or_introl eq_refl))) | ].
        split; [ unfold SZ_SURFACE; lia | ].
        split; [ unfold SZ_SURFACE; vm_compute; discriminate | ].
        fold RL. unfold RL. norl. }
      split; [ intros off sb so Hoff Hl; exfalso; exact (wc_noptr off sb so Hoff Hl) | ].
      split; [ exact L_area | ].
      split.
      { exists bar, Ptrofs.zero. split; [ reflexivity | ].
        split; [ exact (fresh_lt _ (or_intror (or_intror eq_refl))) | ].
        split; [ unfold SZ_AREA; lia | ].
        split; [ unfold SZ_AREA; vm_compute; discriminate | ].
        norl. }
      split; [ rewrite (z_bm Mint16unsigned 2) by (cbn [size_chunk align_chunk]; try lia; try al; cells); reflexivity | ].
      split; [ reflexivity | ].
      split; [ exact L_ctl | ].
      split.
      { exists bc, Ptrofs.zero. split; [ reflexivity | ].
        split; [ exact (sym_lt _ _ Hbc) | ].
        split; [ unfold SZ_CTL; lia | ].
        split; [ unfold SZ_CTL; vm_compute; discriminate | ].
        norl. }
      split; [ intros i cb co Hi Hl; exfalso; exact (coll_noptr _ _ _ Hi Hl) | ].
      split; [ exact L_pcs | ].
      split; [ exact L_body | ].
      (* Mario's gfx.throwMatrix: the zero-filled pool's NULL *)
      left. change (Ptrofs.unsigned Ptrofs.zero + FFW_THROW) with 80.
      rewrite (z_bo Mint32 80) by (cbn [size_chunk align_chunk]; try lia; try al); reflexivity.
    Qed.

    (* ---- the level: gCurrLevelNum = LEVEL_WMOTR, by real code ---- *)
    Lemma bL_valid0 : Mem.valid_block m0 bL.
    Proof. exact (Genv.find_symbol_not_fresh _ _ Hinit HbL). Qed.

    Lemma L_lvl : Mem.load Mint16signed m11 bL 0 = Some (Vint (Int.repr LEVEL_WMOTR)).
    Proof.
      assert (N1 : bL <> bm) by exact (symne lp _ _ _ _ HbL Hbm eq_refl).
      assert (N2 : bL <> ab) by exact (symne lp _ _ _ _ HbL Hab eq_refl).
      assert (N3 : bL <> bo) by exact (symne lp _ _ _ _ HbL Hbo eq_refl).
      assert (N4 : bL <> bs) by (intro E; exact (sym_ne_fresh _ _ _ HbL (or_intror (or_introl eq_refl)) E)).
      peelZ; peel S8; peel S7; peel S6; peel S5; peel S4; peel S3; peel S2; peel S1; peel S1b; peel S1a.
      rewrite (ld_3e _ _ _ (valid_e_L _ (valid_0_e _ bL_valid0))).
      rewrite (ld_Le _ _ _ (valid_0_e _ bL_valid0)
                 (inFb_sym_false _ _ _ HbL ltac:(vm_compute; reflexivity))).
      rewrite (Mem.load_store_same _ _ _ _ _ _ E6). reflexivity.
    Qed.

    Lemma in_wmotr11 : in_wmotr lp m11.
    Proof. exists bL. split; [ exact HbL | exact L_lvl ]. Qed.

    (* ---- sPlayingInfiniteStairs: the boot image's 0 (sound_init.c's
       `static u8 sPlayingInfiniteStairs = FALSE`), untouched by the entry ---- *)
    Lemma dm_spis : (prog_defmap sound_init.prog) ! sound_init._sPlayingInfiniteStairs
                    = Some (Gvar sound_init.v_sPlayingInfiniteStairs).
    Proof. vm_compute. reflexivity. Qed.

    Lemma boot_spis : forall b, Genv.find_symbol (lp_ge lp) sound_init._sPlayingInfiniteStairs = Some b ->
        Mem.load Mint8unsigned m0 b 0 = Some (Vint Int.zero).
    Proof.
      intros b Hb.
      pose proof (linked12_LO_sound_init lp H12) as LOq.
      Local Transparent Linker_program.
      unfold linkorder, Linker_program, linkorder_program in LOq.
      destruct LOq as [LOast _].
      destruct (prog_defmap_linkorder _ _ _ _ LOast dm_spis) as (gd' & Hgd' & Hlo).
      change (prog_defmap (program_of_program lp)) with (prog_defmap lp) in Hgd'.
      inv Hlo. match goal with H : linkorder _ _ |- _ => inv H end.
      match goal with H : linkorder _ i2 |- _ => inv H end.
      apply Genv.find_def_symbol in Hgd' as (b' & Hfs' & Hfd).
      change (Genv.globalenv (program_of_program lp)) with (Genv.globalenv lp) in Hfs', Hfd.
      change (Genv.find_symbol (Genv.globalenv lp) sound_init._sPlayingInfiniteStairs = Some b) in Hb.
      rewrite Hb in Hfs'. injection Hfs' as <-.
      pose proof Hinit as GI. apply Genv.init_mem_characterization_gen in GI.
      specialize (GI b _ Hfd). cbn in GI. destruct GI as (_ & _ & Hli & _).
      specialize (Hli eq_refl). cbn in Hli. destruct Hli as [Hl _].
      rewrite Hl. reflexivity.
    Qed.

    Lemma L_spis : forall b, Genv.find_symbol (lp_ge lp) sound_init._sPlayingInfiniteStairs = Some b ->
        Mem.load Mint8unsigned m11 b 0 = Some (Vint Int.zero).
    Proof.
      intros bsp Hsp.
      assert (V0 : Mem.valid_block m0 bsp) by exact (Genv.find_symbol_not_fresh _ _ Hinit Hsp).
      assert (N1 : bsp <> bm) by exact (symne lp _ _ _ _ Hsp Hbm eq_refl).
      assert (N2 : bsp <> ab) by exact (symne lp _ _ _ _ Hsp Hab eq_refl).
      assert (N3 : bsp <> bo) by exact (symne lp _ _ _ _ Hsp Hbo eq_refl).
      assert (N4 : bsp <> bs) by (intro E; exact (sym_ne_fresh _ _ _ Hsp (or_intror (or_introl eq_refl)) E)).
      assert (N5 : bsp <> bL) by exact (symne lp _ _ _ _ Hsp HbL eq_refl).
      assert (N6 : bsp <> bw) by exact (symne lp _ _ _ _ Hsp Hbw eq_refl).
      peelZ; peel S8; peel S7; peel S6; peel S5; peel S4; peel S3; peel S2; peel S1; peel S1b; peel S1a.
      rewrite (ld_3e _ _ _ (valid_e_L _ (valid_0_e _ V0))).
      rewrite (ld_Le _ _ _ (valid_0_e _ V0)
                 (inFb_sym_false _ _ _ Hsp ltac:(vm_compute; reflexivity))).
      peel E6; peel E5; peel E4; peel E3; peel E2; peel E1.
      exact (boot_spis bsp Hsp).
    Qed.

    (* ---- the controller cells (FfWorld.ctl_w, PollFlank): the boot
       image's static initializers (gPlayer1Controller = &gControllers[0],
       gPlayer3Controller = &gControllers[2], gCurrDemoInput = NULL), the
       .bss pads, and init_controllers' controllerData store (Z18) ---- *)
    Lemma dm_p1 : (prog_defmap game_init.prog) ! game_init._gPlayer1Controller
                  = Some (Gvar game_init.v_gPlayer1Controller).
    Proof. vm_compute. reflexivity. Qed.
    Lemma dm_p3 : (prog_defmap game_init.prog) ! game_init._gPlayer3Controller
                  = Some (Gvar game_init.v_gPlayer3Controller).
    Proof. vm_compute. reflexivity. Qed.
    Lemma dm_demo : (prog_defmap game_init.prog) ! game_init._gCurrDemoInput
                  = Some (Gvar game_init.v_gCurrDemoInput).
    Proof. vm_compute. reflexivity. Qed.

    Ltac boot_lsid LOq dmx Hb :=
      unfold linkorder, Linker_program, linkorder_program in LOq;
      let LOast := fresh "LOast" in
      destruct LOq as [LOast _];
      let gd' := fresh "gd'" in let Hgd' := fresh "Hgd'" in let Hlo := fresh "Hlo" in
      destruct (prog_defmap_linkorder _ _ _ _ LOast dmx) as (gd' & Hgd' & Hlo);
      change (prog_defmap (program_of_program lp)) with (prog_defmap lp) in Hgd';
      inv Hlo; match goal with H : linkorder _ _ |- _ => inv H end;
      match goal with H : linkorder _ ?i2 |- _ => inv H end;
      let b' := fresh "b'" in let Hfs' := fresh "Hfs'" in let Hfd := fresh "Hfd" in
      apply Genv.find_def_symbol in Hgd' as (b' & Hfs' & Hfd);
      change (Genv.globalenv (program_of_program lp)) with (Genv.globalenv lp) in Hfs', Hfd;
      rewrite Hb in Hfs'; injection Hfs' as <-;
      let GI := fresh "GI" in
      pose proof Hinit as GI; apply Genv.init_mem_characterization_gen in GI;
      specialize (GI _ _ Hfd); cbn in GI;
      let Hli := fresh "Hli" in
      destruct GI as (_ & _ & Hli & _); specialize (Hli eq_refl); cbn in Hli.

    Lemma boot_p1 : forall b, Genv.find_symbol (lp_ge lp) game_init._gPlayer1Controller = Some b ->
        Mem.load Mint32 m0 b 0 = Some (Vptr bc Ptrofs.zero).
    Proof.
      intros b Hb. change (Genv.find_symbol (Genv.globalenv lp) game_init._gPlayer1Controller = Some b) in Hb.
      Local Transparent Linker_program.
      pose proof LO_gi as LOq.
      boot_lsid LOq dm_p1 Hb.
      destruct Hli as ((bx & Hx & Hl) & _).
      change (Genv.find_symbol (lp_ge lp) mario._gControllers = Some bx) in Hx.
      rewrite Hbc in Hx. injection Hx as <-. exact Hl.
    Qed.
    Lemma boot_p3 : forall b, Genv.find_symbol (lp_ge lp) game_init._gPlayer3Controller = Some b ->
        Mem.load Mint32 m0 b 0 = Some (Vptr bc (Ptrofs.repr 56)).
    Proof.
      intros b Hb. change (Genv.find_symbol (Genv.globalenv lp) game_init._gPlayer3Controller = Some b) in Hb.
      Local Transparent Linker_program.
      pose proof LO_gi as LOq.
      boot_lsid LOq dm_p3 Hb.
      destruct Hli as ((bx & Hx & Hl) & _).
      change (Genv.find_symbol (lp_ge lp) mario._gControllers = Some bx) in Hx.
      rewrite Hbc in Hx. injection Hx as <-. exact Hl.
    Qed.
    Lemma boot_demo : forall b, Genv.find_symbol (lp_ge lp) game_init._gCurrDemoInput = Some b ->
        Mem.load Mint32 m0 b 0 = Some (Vint Int.zero).
    Proof.
      intros b Hb. change (Genv.find_symbol (Genv.globalenv lp) game_init._gCurrDemoInput = Some b) in Hb.
      Local Transparent Linker_program.
      pose proof LO_gi as LOq.
      boot_lsid LOq dm_demo Hb.
      destruct Hli as (Hl & _). exact Hl.
    Qed.

    (* a symbol block none of the witness stores touch *)
    Ltac unt_tac Hs :=
      split; [ let E := fresh "E" in intro E; exact (sym_ne_fresh _ _ _ Hs (or_intror (or_introl eq_refl)) E) | ];
      split; [ let E := fresh "E" in intro E; exfalso; exact (symne lp _ _ _ _ Hs Hbm eq_refl E) | ];
      split; [ let E := fresh "E" in intro E; exfalso; exact (symne lp _ _ _ _ Hs Hab eq_refl E) | ];
      split; [ let E := fresh "E" in intro E; exfalso; exact (symne lp _ _ _ _ Hs Hhud_fs eq_refl E) | ];
      split; [ let E := fresh "E" in intro E; exfalso; exact (symne lp _ _ _ _ Hs Hbo eq_refl E) | ];
      split; [ exact (symne lp _ _ _ _ Hs Hbw eq_refl) | ];
      split; [ exact (symne lp _ _ _ _ Hs HbL eq_refl) | ];
      split; [ exact (inFb_sym_false _ _ _ Hs ltac:(vm_compute; reflexivity)) | ];
      split; [ exact (symne lp _ _ _ _ Hs HcC eq_refl) | let E := fresh "E" in intros E; exfalso; exact (symne lp _ _ _ _ Hs Hbc eq_refl E) ].

    Lemma dm_ctl : (prog_defmap game_init.prog) ! mario._gControllers
                   = Some (Gvar game_init.v_gControllers).
    Proof. reflexivity. Qed.

    Lemma ctl11 : ctl_w (lp_ge lp) m11.
    Proof.
      assert (Nbcw : bc <> bw) by exact (symne lp _ _ _ _ Hbc Hbw eq_refl).
      intros bc' bp Sc Sp.
      rewrite Hbc in Sc. injection Sc as <-.
      rewrite Hpads in Sp. injection Sp as <-.
      assert (Vc : Mem.valid_block m0 bc) by exact (Genv.find_symbol_not_fresh _ _ Hinit Hbc).
      assert (Uc : forall ch z, z + size_chunk ch <= 24 \/ 28 <= z -> untouched ch bc z).
      { intros ch z Hz.
        split; [ intro E; exact (sym_ne_fresh _ _ _ Hbc (or_intror (or_introl eq_refl)) E) | ].
        split; [ intro E; exfalso; exact (symne lp _ _ _ _ Hbc Hbm eq_refl E) | ].
        split; [ intro E; exfalso; exact (symne lp _ _ _ _ Hbc Hab eq_refl E) | ].
        split; [ intro E; exfalso; exact (symne lp _ _ _ _ Hbc Hhud_fs eq_refl E) | ].
        split; [ intro E; exfalso; exact (symne lp _ _ _ _ Hbc Hbo eq_refl E) | ].
        split; [ exact (symne lp _ _ _ _ Hbc Hbw eq_refl) | ].
        split; [ exact (symne lp _ _ _ _ Hbc HbL eq_refl) | ].
        split; [ exact (inFb_sym_false _ _ _ Hbc ltac:(vm_compute; reflexivity)) | ].
        split; [ exact (symne lp _ _ _ _ Hbc HcC eq_refl) | intros _; exact Hz ]. }
      assert (RPc : Mem.range_perm m0 bc 0 84 Cur Writable)
        by exact (wr_sym _ _ _ bc LO_gi dm_ctl eq_refl eq_refl ltac:(cbn; discriminate) Hbc).
      assert (Zc : forall ch z, z + size_chunk ch <= 24 \/ 28 <= z -> 0 <= z -> z + size_chunk ch <= 84 ->
                (align_chunk ch | z) -> Mem.load ch m11 bc z = Some (zeros ch)).
      { intros ch z Hz H0 H84 Ha.
        destruct (valid_ex ch bc z 0 84 RPc H0 H84 Ha) as (v & Hl).
        rewrite (ld_back ch bc z Vc (Uc ch z Hz)), Hl.
        rewrite (boot_zero lp m0 _ bc _ _ _ H12 Hinit
                   (in_cons _ _ _ (in_cons _ _ _ (in_cons _ _ _ (in_cons _ _ _ (in_cons _ _ _ (in_cons _ _ _ (in_eq _ _)))))))
                   Hbc Hl).
        reflexivity. }
      split.
      { intros j [-> | ->].
        - right. exists 0. split; [ lia | ].
          change (28 * 0 + 24) with 24. rewrite (Mem.load_store_other _ _ _ _ _ _ Z18) by (left; exact Nbcw).
          rewrite (Mem.load_store_same _ _ _ _ _ _ ZC). reflexivity.
        - left. change (28 * 1 + 24) with 52.
          rewrite (Zc Mint32 52 ltac:(right; lia) ltac:(lia) ltac:(cbn; lia)
                     ltac:(apply Z.mod_divide; [ cbn; discriminate | reflexivity ])).
          reflexivity. }
      split.
      { intros z [-> | ->]; exists Int.zero; split; try reflexivity;
          match goal with |- Mem.load _ _ _ ?zz = _ =>
            rewrite (Zc Mint16unsigned zz ltac:(cbn; left; lia) ltac:(lia) ltac:(cbn; lia)
                       ltac:(apply Z.mod_divide; [ cbn; discriminate | reflexivity ])) end;
          reflexivity. }
      split.
      { intros k n Hk Hl.
        assert (V0 : Mem.valid_block m0 bpads) by exact (Genv.find_symbol_not_fresh _ _ Hinit Hpads).
        rewrite (ld_back Mint16unsigned bpads (6 * k) V0) in Hl by (unt_tac Hpads).
        pose proof (boot_zero lp m0 _ bpads _ _ _ H12 Hinit
                      (in_cons _ _ _ (in_cons _ _ _ (in_cons _ _ _ (in_cons _ _ _ (in_eq _ _)))))
                      Hpads Hl) as E.
        assert (Zr : zeros Mint16unsigned = Vint Int.zero) by reflexivity.
        rewrite Zr in E. injection E as ->. reflexivity. }
      split.
      { intros b1 Sy1.
        assert (V0 : Mem.valid_block m0 b1) by exact (Genv.find_symbol_not_fresh _ _ Hinit Sy1).
        rewrite (ld_back Mint32 b1 0 V0) by (unt_tac Sy1). exact (boot_p1 b1 Sy1). }
      split.
      { intros b3 Sy3.
        assert (V0 : Mem.valid_block m0 b3) by exact (Genv.find_symbol_not_fresh _ _ Hinit Sy3).
        rewrite (ld_back Mint32 b3 0 V0) by (unt_tac Sy3). exact (boot_p3 b3 Sy3). }
      split.
      { intros bd' Syd.
        assert (V0 : Mem.valid_block m0 bd') by exact (Genv.find_symbol_not_fresh _ _ Hinit Syd).
        rewrite (ld_back Mint32 bd' 0 V0) by (unt_tac Syd). exact (boot_demo bd' Syd). }
      intros bx Syx x Hl.
      assert (V0 : Mem.valid_block m0 bx) by exact (Genv.find_symbol_not_fresh _ _ Hinit Syx).
      rewrite (ld_back Mint8unsigned bx 0 V0) in Hl by (unt_tac Syx).
      pose proof (boot_zero lp m0 _ bx _ _ _ H12 Hinit
                    (in_cons _ _ _ (in_cons _ _ _ (in_cons _ _ _ (in_cons _ _ _ (in_cons _ _ _ (in_eq _ _))))))
                    Syx Hl) as E.
      assert (Zr : zeros Mint8unsigned = Vint Int.zero) by reflexivity.
      rewrite Zr in E. injection E as Ex. subst x. rewrite Int.unsigned_zero. lia.
    Qed.

    (* ---- the warp cells (FfWorld.warp_w, 2026-10-24): sWarpDest.type is
       NOT_WARPING by Z18 (init_mario_after_warp's last store); the demo and
       credits pointers and the delayed-warp op keep their boot zeros ---- *)
    Lemma dm_cdi : (prog_defmap game_init.prog) ! game_init._gCurrDemoInput = Some (Gvar game_init.v_gCurrDemoInput).
    Proof. vm_compute. reflexivity. Qed.

    Lemma boot_cdi : forall b, Genv.find_symbol (lp_ge lp) level_update._gCurrDemoInput = Some b ->
        Mem.load Mint32 m0 b 0 = Some (Vint Int.zero).
    Proof.
      intros b Hb.
      pose proof (LO_gi) as LOq.
      Local Transparent Linker_program.
      unfold linkorder, Linker_program, linkorder_program in LOq.
      destruct LOq as [LOast _].
      destruct (prog_defmap_linkorder _ _ _ _ LOast dm_cdi) as (gd' & Hgd' & Hlo).
      change (prog_defmap (program_of_program lp)) with (prog_defmap lp) in Hgd'.
      inv Hlo. match goal with H : linkorder _ _ |- _ => inv H end.
      match goal with H : linkorder _ i2 |- _ => inv H end.
      apply Genv.find_def_symbol in Hgd' as (b' & Hfs' & Hfd).
      change (Genv.globalenv (program_of_program lp)) with (Genv.globalenv lp) in Hfs', Hfd.
      change (Genv.find_symbol (Genv.globalenv lp) game_init._gCurrDemoInput = Some b) in Hb.
      rewrite Hb in Hfs'. injection Hfs' as <-.
      pose proof Hinit as GI. apply Genv.init_mem_characterization_gen in GI.
      specialize (GI b _ Hfd). cbn in GI. destruct GI as (_ & _ & Hli & _).
      specialize (Hli eq_refl). cbn in Hli. destruct Hli as [Hl _].
      rewrite Hl. reflexivity.
    Qed.

    Lemma L_cdi : forall b, Genv.find_symbol (lp_ge lp) level_update._gCurrDemoInput = Some b ->
        Mem.load Mint32 m11 b 0 = Some (Vint Int.zero).
    Proof.
      intros bsp Hsp.
      assert (V0 : Mem.valid_block m0 bsp) by exact (Genv.find_symbol_not_fresh _ _ Hinit Hsp).
      assert (N1 : bsp <> bm) by exact (symne lp _ _ _ _ Hsp Hbm eq_refl).
      assert (N2 : bsp <> ab) by exact (symne lp _ _ _ _ Hsp Hab eq_refl).
      assert (N3 : bsp <> bo) by exact (symne lp _ _ _ _ Hsp Hbo eq_refl).
      assert (N4 : bsp <> bs) by (intro E; exact (sym_ne_fresh _ _ _ Hsp (or_intror (or_introl eq_refl)) E)).
      assert (N5 : bsp <> bL) by exact (symne lp _ _ _ _ Hsp HbL eq_refl).
      assert (N6 : bsp <> bw) by exact (symne lp _ _ _ _ Hsp Hbw eq_refl).
      peelZ; peel S8; peel S7; peel S6; peel S5; peel S4; peel S3; peel S2; peel S1; peel S1b; peel S1a.
      rewrite (ld_3e _ _ _ (valid_e_L _ (valid_0_e _ V0))).
      rewrite (ld_Le _ _ _ (valid_0_e _ V0)
                 (inFb_sym_false _ _ _ Hsp ltac:(vm_compute; reflexivity))).
      peel E6; peel E5; peel E4; peel E3; peel E2; peel E1.
      exact (boot_cdi bsp Hsp).
    Qed.

    Lemma dm_cce : (prog_defmap area.prog) ! area._gCurrCreditsEntry = Some (Gvar area.v_gCurrCreditsEntry).
    Proof. vm_compute. reflexivity. Qed.

    Lemma boot_cce : forall b, Genv.find_symbol (lp_ge lp) level_update._gCurrCreditsEntry = Some b ->
        Mem.load Mint32 m0 b 0 = Some (Vint Int.zero).
    Proof.
      intros b Hb.
      pose proof (linked12_LO_area lp H12) as LOq.
      Local Transparent Linker_program.
      unfold linkorder, Linker_program, linkorder_program in LOq.
      destruct LOq as [LOast _].
      destruct (prog_defmap_linkorder _ _ _ _ LOast dm_cce) as (gd' & Hgd' & Hlo).
      change (prog_defmap (program_of_program lp)) with (prog_defmap lp) in Hgd'.
      inv Hlo. match goal with H : linkorder _ _ |- _ => inv H end.
      match goal with H : linkorder _ i2 |- _ => inv H end.
      apply Genv.find_def_symbol in Hgd' as (b' & Hfs' & Hfd).
      change (Genv.globalenv (program_of_program lp)) with (Genv.globalenv lp) in Hfs', Hfd.
      change (Genv.find_symbol (Genv.globalenv lp) area._gCurrCreditsEntry = Some b) in Hb.
      rewrite Hb in Hfs'. injection Hfs' as <-.
      pose proof Hinit as GI. apply Genv.init_mem_characterization_gen in GI.
      specialize (GI b _ Hfd). cbn in GI. destruct GI as (_ & _ & Hli & _).
      specialize (Hli eq_refl). cbn in Hli. destruct Hli as [Hl _].
      rewrite Hl. reflexivity.
    Qed.

    Lemma L_cce : forall b, Genv.find_symbol (lp_ge lp) level_update._gCurrCreditsEntry = Some b ->
        Mem.load Mint32 m11 b 0 = Some (Vint Int.zero).
    Proof.
      intros bsp Hsp.
      assert (V0 : Mem.valid_block m0 bsp) by exact (Genv.find_symbol_not_fresh _ _ Hinit Hsp).
      assert (N1 : bsp <> bm) by exact (symne lp _ _ _ _ Hsp Hbm eq_refl).
      assert (N2 : bsp <> ab) by exact (symne lp _ _ _ _ Hsp Hab eq_refl).
      assert (N3 : bsp <> bo) by exact (symne lp _ _ _ _ Hsp Hbo eq_refl).
      assert (N4 : bsp <> bs) by (intro E; exact (sym_ne_fresh _ _ _ Hsp (or_intror (or_introl eq_refl)) E)).
      assert (N5 : bsp <> bL) by exact (symne lp _ _ _ _ Hsp HbL eq_refl).
      assert (N6 : bsp <> bw) by exact (symne lp _ _ _ _ Hsp Hbw eq_refl).
      peelZ; peel S8; peel S7; peel S6; peel S5; peel S4; peel S3; peel S2; peel S1; peel S1b; peel S1a.
      rewrite (ld_3e _ _ _ (valid_e_L _ (valid_0_e _ V0))).
      rewrite (ld_Le _ _ _ (valid_0_e _ V0)
                 (inFb_sym_false _ _ _ Hsp ltac:(vm_compute; reflexivity))).
      peel E6; peel E5; peel E4; peel E3; peel E2; peel E1.
      exact (boot_cce bsp Hsp).
    Qed.

    Lemma dm_dwo : (prog_defmap level_update.prog) ! level_update._sDelayedWarpOp = Some (Gvar level_update.v_sDelayedWarpOp).
    Proof. vm_compute. reflexivity. Qed.

    Definition dwo_tu_ok (q : Clight.program) : bool :=
      match (prog_defmap q) ! level_update._sDelayedWarpOp with
      | Some (Gvar v) => match gvar_init v with [Init_space z] => Z.eqb z 2 | _ => false end
      | Some (Gfun _) => false
      | None => true
      end.

    Lemma dwo_tus : forallb dwo_tu_ok (mario.prog :: LinkedTwelve.tu_rest) = true.
    Proof. vm_compute. reflexivity. Qed.

    Lemma boot_dwo : forall b, Genv.find_symbol (lp_ge lp) level_update._sDelayedWarpOp = Some b ->
        Mem.load Mint16signed m0 b 0 = Some (Vint Int.zero).
    Proof.
      intros b Hb.
      pose proof (linked12_LO_lvl lp H12) as LOq.
      Local Transparent Linker_program.
      unfold linkorder, Linker_program, linkorder_program in LOq.
      destruct LOq as [LOast _].
      destruct (prog_defmap_linkorder _ _ _ _ LOast dm_dwo) as (gd' & Hgd' & Hlo).
      change (prog_defmap (program_of_program lp)) with (prog_defmap lp) in Hgd'.
      inv Hlo. match goal with H : linkorder _ _ |- _ => inv H end.
      (* sDelayedWarpOp is a tentative definition (Init_space 2, a "common"
         initializer), so linkorder alone lets the link carry any 2-byte
         initializer.  It is static to level_update.c and no other TU defines
         it (dwo_tus), so the link's initializer is level_update's own. *)
      match goal with H : linkorder _ ?i2 |- _ =>
        assert (Iv : i2 = [Init_space 2]); [ | subst i2; clear H ] end.
      { pose proof dwo_tus as T. cbn [forallb] in T. apply andb_true_iff in T as [T0 T1].
        destruct (InitMemSat.link_chain_gvar_origin _ _ _ _ _
                    (H12 : link_chain mario.prog LinkedTwelve.tu_rest = Some lp) Hgd')
          as [Hq | (q & Hin & Hq)].
        - unfold dwo_tu_ok in T0. rewrite Hq in T0. cbn in T0. clear -T0.
          match type of T0 with (match ?l with _ => _ end) = true => destruct l as [| d [| d' l]] end;
            try discriminate; destruct d; try discriminate. apply Z.eqb_eq in T0. subst. reflexivity.
        - rewrite forallb_forall in T1. specialize (T1 q Hin).
          unfold dwo_tu_ok in T1. rewrite Hq in T1. cbn in T1. clear -T1.
          match type of T1 with (match ?l with _ => _ end) = true => destruct l as [| d [| d' l]] end;
            try discriminate; destruct d; try discriminate. apply Z.eqb_eq in T1. subst. reflexivity. }
      apply Genv.find_def_symbol in Hgd' as (b' & Hfs' & Hfd).
      change (Genv.globalenv (program_of_program lp)) with (Genv.globalenv lp) in Hfs', Hfd.
      change (Genv.find_symbol (Genv.globalenv lp) level_update._sDelayedWarpOp = Some b) in Hb.
      rewrite Hb in Hfs'. injection Hfs' as <-.
      pose proof Hinit as GI. apply Genv.init_mem_characterization_gen in GI.
      specialize (GI b _ Hfd). cbn in GI. destruct GI as (_ & _ & Hli & _).
      specialize (Hli eq_refl). cbn in Hli. destruct Hli as [Hl _].
      apply (Hl Mint16signed 0).
      - lia.
      - cbn. lia.
      - apply Z.divide_0_r.
    Qed.

    Lemma L_dwo : forall b, Genv.find_symbol (lp_ge lp) level_update._sDelayedWarpOp = Some b ->
        Mem.load Mint16signed m11 b 0 = Some (Vint Int.zero).
    Proof.
      intros bsp Hsp.
      assert (V0 : Mem.valid_block m0 bsp) by exact (Genv.find_symbol_not_fresh _ _ Hinit Hsp).
      assert (N1 : bsp <> bm) by exact (symne lp _ _ _ _ Hsp Hbm eq_refl).
      assert (N2 : bsp <> ab) by exact (symne lp _ _ _ _ Hsp Hab eq_refl).
      assert (N3 : bsp <> bo) by exact (symne lp _ _ _ _ Hsp Hbo eq_refl).
      assert (N4 : bsp <> bs) by (intro E; exact (sym_ne_fresh _ _ _ Hsp (or_intror (or_introl eq_refl)) E)).
      assert (N5 : bsp <> bL) by exact (symne lp _ _ _ _ Hsp HbL eq_refl).
      assert (N6 : bsp <> bw) by exact (symne lp _ _ _ _ Hsp Hbw eq_refl).
      peelZ; peel S8; peel S7; peel S6; peel S5; peel S4; peel S3; peel S2; peel S1; peel S1b; peel S1a.
      rewrite (ld_3e _ _ _ (valid_e_L _ (valid_0_e _ V0))).
      rewrite (ld_Le _ _ _ (valid_0_e _ V0)
                 (inFb_sym_false _ _ _ Hsp ltac:(vm_compute; reflexivity))).
      peel E6; peel E5; peel E4; peel E3; peel E2; peel E1.
      exact (boot_dwo bsp Hsp).
    Qed.

    Lemma L_wtype : Mem.load Mint8unsigned m11 bw 0 = Some (Vint Int.zero).
    Proof. rewrite (Mem.load_store_same _ _ _ _ _ _ Z18). reflexivity. Qed.

    Lemma warp11 : warp_w (lp_ge lp) m11.
    Proof.
      split; [ | split; [ exact L_cdi | split; [ exact L_cce | ] ] ].
      - intros bp bw' _ Hw _. rewrite Hbw in Hw. injection Hw as <-. exact L_wtype.
      - intros bo' bs' Ho _ Hn. exfalso. exact (Hn (L_dwo bo' Ho)).
    Qed.

    Lemma lvl11 : lvl_w (lp_ge lp) m11.
    Proof.
      split; [ | split; [ exact L_spis | split; [ exact warp11 | exact ctl11 ] ] ].
      intros b Hb. change (Genv.find_symbol (lp_ge lp) level_update._gCurrLevelNum = Some b) in Hb.
      rewrite HbL in Hb. injection Hb as <-. exact L_lvl.
    Qed.

    (* ---- gMarioPlatform: the boot image's NULL (platform_displacement.c's
       `struct Object *gMarioPlatform = NULL`), untouched by the entry, so
       the run's platform fact (PlatformKeep.plat_still) holds (2026-10-24) ---- *)
    Lemma dm_gmp : (prog_defmap platform_displacement.prog) ! platform_displacement._gMarioPlatform
                    = Some (Gvar platform_displacement.v_gMarioPlatform).
    Proof. vm_compute. reflexivity. Qed.

    Lemma boot_gmp : forall b, Genv.find_symbol (lp_ge lp) platform_displacement._gMarioPlatform = Some b ->
        Mem.load Mint32 m0 b 0 = Some (Vint Int.zero).
    Proof.
      intros b Hb.
      pose proof (linked12_LO_platform_displacement lp H12) as LOq.
      Local Transparent Linker_program.
      unfold linkorder, Linker_program, linkorder_program in LOq.
      destruct LOq as [LOast _].
      destruct (prog_defmap_linkorder _ _ _ _ LOast dm_gmp) as (gd' & Hgd' & Hlo).
      change (prog_defmap (program_of_program lp)) with (prog_defmap lp) in Hgd'.
      inv Hlo. match goal with H : linkorder _ _ |- _ => inv H end.
      match goal with H : linkorder _ i2 |- _ => inv H end.
      apply Genv.find_def_symbol in Hgd' as (b' & Hfs' & Hfd).
      change (Genv.globalenv (program_of_program lp)) with (Genv.globalenv lp) in Hfs', Hfd.
      change (Genv.find_symbol (Genv.globalenv lp) platform_displacement._gMarioPlatform = Some b) in Hb.
      rewrite Hb in Hfs'. injection Hfs' as <-.
      pose proof Hinit as GI. apply Genv.init_mem_characterization_gen in GI.
      specialize (GI b _ Hfd). cbn in GI. destruct GI as (_ & _ & Hli & _).
      specialize (Hli eq_refl). cbn in Hli. destruct Hli as [Hl _].
      rewrite Hl. reflexivity.
    Qed.

    Lemma L_gmp : forall b, Genv.find_symbol (lp_ge lp) platform_displacement._gMarioPlatform = Some b ->
        Mem.load Mint32 m11 b 0 = Some (Vint Int.zero).
    Proof.
      intros bsp Hsp.
      assert (V0 : Mem.valid_block m0 bsp) by exact (Genv.find_symbol_not_fresh _ _ Hinit Hsp).
      assert (N1 : bsp <> bm) by exact (symne lp _ _ _ _ Hsp Hbm eq_refl).
      assert (N2 : bsp <> ab) by exact (symne lp _ _ _ _ Hsp Hab eq_refl).
      assert (N3 : bsp <> bo) by exact (symne lp _ _ _ _ Hsp Hbo eq_refl).
      assert (N4 : bsp <> bs) by (intro E; exact (sym_ne_fresh _ _ _ Hsp (or_intror (or_introl eq_refl)) E)).
      assert (N5 : bsp <> bL) by exact (symne lp _ _ _ _ Hsp HbL eq_refl).
      assert (N6 : bsp <> bw) by exact (symne lp _ _ _ _ Hsp Hbw eq_refl).
      peelZ; peel S8; peel S7; peel S6; peel S5; peel S4; peel S3; peel S2; peel S1; peel S1b; peel S1a.
      rewrite (ld_3e _ _ _ (valid_e_L _ (valid_0_e _ V0))).
      rewrite (ld_Le _ _ _ (valid_0_e _ V0)
                 (inFb_sym_false _ _ _ Hsp ltac:(vm_compute; reflexivity))).
      peel E6; peel E5; peel E4; peel E3; peel E2; peel E1.
      exact (boot_gmp bsp Hsp).
    Qed.

    Lemma plat11 : PlatformKeep.plat_still lp m11.
    Proof.
      intros bp v Hb Hl. left. rewrite (L_gmp bp Hb) in Hl. injection Hl as <-. reflexivity.
    Qed.

    (* the entry stores ARE the real code's: the generated initiate_warp body
       runs m0 -> e5, and warp_level's head runs e5 -> e6 *)
    Lemma entry_runs :
      eval_funcall function_entry2 (lp_ge lp) m0 (Internal level_update.f_initiate_warp)
        iw_args E0 e5 Vundef
      /\ forall le, exec_stmt function_entry2 (lp_ge lp) empty_env le e5 warp_level_head E0
                     (PTree.set level_update._t'2 (Vint (Int.repr LEVEL_WMOTR)) le) e6 Out_normal.
    Proof.
      split.
      - eapply (initiate_warp_runs lp H12 bw bL Hbw HbL);
          [ exact (boot_levelnum lp H12 bL HbL m0 Hinit) | vm_compute; reflexivity
          | exact E1 | exact E2 | exact E3 | exact E4 | exact E5 ].
      - intros le. eapply (warp_level_head_runs lp H12 bw bL Hbw HbL); [ | exact E6 ].
        rewrite (Mem.load_store_other _ _ _ _ _ _ E5) by (right; cbn; lia).
        rewrite (Mem.load_store_other _ _ _ _ _ _ E4) by (right; cbn; lia).
        rewrite (Mem.load_store_other _ _ _ _ _ _ E3) by (right; cbn; lia).
        rewrite (Mem.load_store_same _ _ _ _ _ _ E2). reflexivity.
    Qed.

    (* ---- the witness ---- *)
    Lemma loaded11 : terrain_loaded lp e6 m11.
    Proof.
      exists P0, bpl, P, bcol, L1, Lm.
      split; [ exact AP | ].
      split; [ exists s1, s2, s3, s4, s5; tauto | ].
      split; [ exact Hcol | ].
      split; [ | exact ld_loader ].
      intros Hv. pose proof (world_ok_of (lp_ge lp) Hv) as Wk.
      exists t1, v1, t2, v2. split.
      - exact (ex_call_sound _ _ Wk _ _ _ _ _ _ _ RA).
      - exact (ex_call_sound _ _ Wk _ _ _ _ _ _ _ RT).
    Qed.

    Lemma nsurf11 : nsurf_is lp m11.
    Proof.
      destruct (nsurf_ok_sound _ _ NS) as (n & Hl & Hn). exists bn, n. tauto.
    Qed.

    Theorem witness11 :
      SafeB_syms_ok lp SBw
      /\ mem_ok_lp bm (MWF_real lp bm bc Ptrofs.zero SBw) m11
      /\ PhiW lp bm m11 /\ PlatformKeep.plat_still lp m11
      /\ read_cells bm m11 (entry_cells Float32.zero)
      /\ in_wmotr lp m11
      /\ floor_data (lp_ge lp) m11 /\ static_agree (lp_ge lp) m11 /\ nsurf_is lp m11
      /\ exists bL' m_iw m_ent le',
           Genv.find_symbol (lp_ge lp) level_update._gCurrLevelNum = Some bL'
           /\ eval_funcall function_entry2 (lp_ge lp) m0
                (Internal level_update.f_initiate_warp) iw_args E0 m_iw Vundef
           /\ exec_stmt function_entry2 (lp_ge lp) empty_env (PTree.empty val) m_iw
                warp_level_head E0 le' m_ent Out_normal
           /\ Mem.load Mint16signed m11 bL' 0 = Mem.load Mint16signed m_ent bL' 0
           /\ terrain_loaded lp m_ent m11
           /\ frame_runs lp bm m11 /\ ifs_tether lp m0 bm bc /\ course_set lp m0 m11.
    Proof.
      split; [ exact Sy_w | ].
      split.
      - split; [ exact (mwf_real_valid lp bm bc Ptrofs.zero SBw m11 mwf_w11) | ].
        split; [ | exact mwf_w11 ].
        intros v Hl. rewrite L_act in Hl. injection Hl as <-. reflexivity.
      - assert (Hu : used_ok bm m11).
        { apply (used_ok_other bm m11 _ L_act). vm_compute. intuition discriminate. }
        split; [ exact (conj hinv (conj world11 (conj anim_ok (conj mobj_ok (conj ffw11 (conj Hu (conj anim11 lvl11))))))) | ].
        split; [ exact plat11 | ].
        split; [ exact read_c0 | split; [ exact in_wmotr11 | ] ].
        split; [ exact floor_data11 | split; [ exact static_agree11 | split; [ exact nsurf11 | ] ] ].
        destruct entry_runs as (R1 & R2).
        exists bL, e5, e6, (PTree.set level_update._t'2 (Vint (Int.repr LEVEL_WMOTR)) (PTree.empty val)). split; [ exact HbL | split; [ exact R1 | split; [ exact (R2 _) | ] ] ].
        split; [ rewrite L_lvl, (Mem.load_store_same _ _ _ _ _ _ E6); reflexivity | ].
        split; [ exact loaded11 | ].
        split; [ | split ].
        + intros Hv. pose proof (BootRun.world_ok_of (lp_ge lp) Hv) as Wk.
          destruct (frame_ok_sound _ _ _ _ Wk FO) as (Ha & t & m' & v & Ev & Hl).
          split; [ exact Ha | exists bo, t, m', v; split; [ exact Ev | exact Hl ] ].
        + intros Hv. pose proof (BootRun.world_ok_of (lp_ge lp) Hv) as Wk.
          destruct (ifs_ok_sound _ _ _ _ _ _ _ _ _ Wk IF)
            as (bi & fi & t & mi & v & mx & Hbi0 & Hfi0 & Ev & Ax & Hn & Hc).
          exists ab, bsi, bpcs, bbs, bhud, fi, t, mi, v, mx.
          split; [ exact Hab | ]. split; [ exact Hsi | ]. split; [ exact Hpcs | ].
          split; [ exact Hbbs | ]. split; [ exact Hhud | ].
          split; [ exists bi; split; [ rewrite <- BootRun.id_ifs; exact Hbi0 | exact Hfi0 ] | ].
          tauto.
        + destruct (CourseRun.course_runs lp H12) as (m0' & bC' & t & m' & v & Hi' & HC' & Ev & Hl).
          rewrite Hinit in Hi'. injection Hi' as <-.
          change (Genv.find_symbol (lp_ge lp) level_update._gCurrCourseNum = Some bC') in HC'.
          rewrite HcC in HC'. injection HC' as <-.
          exists bC, t, m', v.
          split; [ exact HcC | split; [ | ] ].
          { assert (NCw : bC <> bw) by exact (symne lp _ _ _ _ HcC Hbw eq_refl).
            rewrite (Mem.load_store_other _ _ _ _ _ _ Z18) by (left; exact NCw).
            rewrite (Mem.load_store_other _ _ _ _ _ _ ZC) by (left; exact (symne lp _ _ _ _ HcC Hbc eq_refl)).
            exact (Mem.load_store_same _ _ _ _ _ _ Z17). }
          split; [ exact Ev | exact Hl ].
    Qed.
End Steps.

  Lemma store_ex : forall m ch b z v,
      (forall x, z <= x < z + size_chunk ch -> Mem.perm m b x Cur Writable) ->
      (align_chunk ch | z) -> exists m', Mem.store ch m b z v = Some m'.
  Proof.
    intros m ch b z v Hp Ha.
    destruct (Mem.valid_access_store m ch b z v) as [m' H]; [ split; assumption | exists m'; exact H ].
  Qed.

  Ltac fwd := repeat first [ eapply Mem.perm_store_1; [ eassumption | ]
                           | eapply Mem.perm_alloc_1; [ eassumption | ] ].

  Lemma dm_wd : (prog_defmap level_update.prog) ! level_update._sWarpDest
                 = Some (Gvar level_update.v_sWarpDest).
  Proof. dm. Qed.

  Theorem start_sat_lp :
    exists SafeB m, SafeB_syms_ok lp SafeB
      /\ mem_ok_lp bm (MWF_real lp bm bc Ptrofs.zero SafeB) m /\ PhiW lp bm m
      /\ PlatformKeep.plat_still lp m
      /\ read_cells bm m (entry_cells Float32.zero)
      /\ in_wmotr lp m
      /\ floor_data (lp_ge lp) m /\ static_agree (lp_ge lp) m /\ nsurf_is lp m
      /\ exists bL m_iw m_ent le',
           Genv.find_symbol (lp_ge lp) level_update._gCurrLevelNum = Some bL
           /\ eval_funcall function_entry2 (lp_ge lp) m0
                (Internal level_update.f_initiate_warp) iw_args E0 m_iw Vundef
           /\ exec_stmt function_entry2 (lp_ge lp) empty_env (PTree.empty val) m_iw
                warp_level_head E0 le' m_ent Out_normal
           /\ Mem.load Mint16signed m bL 0 = Mem.load Mint16signed m_ent bL 0
           /\ terrain_loaded lp m_ent m
           /\ frame_runs lp bm m /\ ifs_tether lp m0 bm bc /\ course_set lp m0 m.
  Proof.
    assert (Eab : exists ab, Genv.find_symbol (lp_ge lp) mario._gMarioAnimsBuf = Some ab)
      by exact (ex_sym _ _ _ LO_gi dm_ab).
    destruct Eab as (ab & Hab).
    destruct (ex_sym _ _ _ LO_olp dm_pool) as (bo & Hbo).
    assert (Efi : exists b, Genv.find_symbol (lp_ge lp)
                    surface_collision._gFindFloorIncludeSurfaceIntangible = Some b)
      by exact (ex_sym _ _ _ LO_olp dm_fi).
    destruct Efi as (bfi & Hfi).
    assert (Emiss : exists b, Genv.find_symbol (lp_ge lp) surface_collision._gNumFindFloorMisses = Some b)
      by exact (ex_sym _ _ _ LO_olp dm_miss).
    destruct Emiss as (bmiss & Hmiss).
    assert (Ecalls : exists b, Genv.find_symbol (lp_ge lp) surface_collision._gNumCalls = Some b)
      by exact (ex_sym _ _ _ LO_olp dm_calls).
    destruct Ecalls as (bcalls & Hcalls).
    destruct (ex_sym _ _ _ (linked12_LO_mario lp H12) dm_sin) as (bsin & Hsin).
    destruct (ex_sym _ _ _ (linked12_LO_memory lp H12) dm_iom) as (biom & Hiom).
    destruct (ex_sym _ _ _ (linked12_LO_memory lp H12) dm_mq) as (bmq & Hmq).
    destruct (ex_sym _ _ _ (linked12_LO_memory lp H12) dm_rm) as (brm & Hrm).
    destruct (ex_sym _ _ _ (linked12_LO_camera lp H12) dm_lak) as (blk & Hlk).
    destruct (ex_sym _ _ _ (linked12_LO_audio_external lp H12) dm_sr) as (bsr & Hsr).
    destruct (ex_sym _ _ _ (linked12_LO_audio_external lp H12) dm_src) as (bsrc & Hsrc).
    destruct (ex_sym _ _ _ (linked12_LO_audio_external lp H12) dm_sms) as (bsms & Hsms).
    destruct (ex_sym _ _ _ (linked12_LO_mov lp H12) dm_fam) as (bfa & Hfa).
    destruct (ex_sym _ _ _ (linked12_LO_lvl lp H12) dm_wd) as (bw & Hbw).
    destruct (ex_sym _ _ _ (linked12_LO_area lp H12) dm_lvlnum) as (bL & HbL).
    (* the whole chain, computed once over every 34-TU link (StartTerrain) *)
    destruct (wchk_sound _ _ (wchk_lp lp H12 m0 Hinit) bm bc ab bo bw bL Hbm Hbc Hab Hbo Hbw HbL)
      as [s1 s2 s3 s4 s5 bcol bn e1 e2 e3 e4 e5 e6 P0 bpl P t1 L1 v1 t2 Lm v2
          m1 bt m2 bs m2b bar m3 bd m3a m3b m4 m5 m6 m7 m8 m9 m10 ms
          bsi bpcs bbs bhud bC bga bpads z1 z2 z3 z4 z5 z6 z7 z8 z9 z10a z10 z11 z12 z13 z14 z15 z16 z17 z18 m11
          E1 E2 E3 E4 E5 E6 Hcol AP PW Hs1 Hs2 Hs3 Hs4 Hs5 RA RT A1 A2 A3 A4
          S1a S1b S1 S2 S3 S4 S5 S6 S7 S8 Hsi Hpcs Hbbs Hhud HcC Hga Hpads
          Z1 Z2 Z3 Z4 Z5 Z6 Z7 Z8 Z9 Z10a Z10 Z11 Z12 Z13 Z14 Z15 Z16 Z17 ZC Z18
          OK FR WP PO NS Hbn IF FO TC GC].
    exists (SBw bpl bt bar bd), m11.
    eapply witness11; eassumption.
  Qed.
End Witness.

(* ====================================================================== *)
(* THE GUARD: for every 23-TU link, the GOAL-2 capstone's start premise   *)
(* (with the SafeB row HSafeB_syms) is met by a memory built from the     *)
(* link's real boot image.                                                *)
(* ====================================================================== *)
Theorem goal2_start_sat : forall lp, linked12 lp ->
  exists m bm bc SafeB,
    Genv.find_symbol (lp_ge lp) level_update._gMarioStates = Some bm
    /\ Genv.find_symbol (lp_ge lp) mario._gControllers = Some bc
    /\ SafeB_syms_ok lp SafeB
    /\ mem_ok_lp bm (MWF_real lp bm bc Ptrofs.zero SafeB) m
    /\ PhiW lp bm m
    (* gMarioPlatform is NULL (its boot value), so the capstone's platform
       premise PlatformKeep.plat_still holds (2026-10-24) *)
    /\ PlatformKeep.plat_still lp m
    /\ read_cells bm m (entry_cells Float32.zero)
    (* the game is in WMotR, and that cell is what the real entry code
       stored: initiate_warp(LEVEL_WMOTR, 1, 0x0A, 0) from the boot image,
       then warp_level's gCurrLevelNum = sWarpDest.levelNum *)
    /\ in_wmotr lp m
    (* WMotR's REAL terrain is loaded: GOAL 2's floor premise (TRUST 0.8)
       and the decoder agreement hold on m, with 1352 surfaces allocated *)
    /\ floor_data (lp_ge lp) m /\ static_agree (lp_ge lp) m /\ nsurf_is lp m
    /\ exists m_boot bL m_iw m_ent le',
         Genv.init_mem lp = Some m_boot
         /\ Genv.find_symbol (lp_ge lp) level_update._gCurrLevelNum = Some bL
         /\ eval_funcall function_entry2 (lp_ge lp) m_boot
              (Internal level_update.f_initiate_warp) iw_args E0 m_iw Vundef
         /\ exec_stmt function_entry2 (lp_ge lp) empty_env (PTree.empty val) m_iw
              warp_level_head E0 le' m_ent Out_normal
         /\ Mem.load Mint16signed m bL 0 = Mem.load Mint16signed m_ent bL 0
         (* ... and those partitions are what the real loader builds from
            the entry memory (the level script's FREE_LEVEL_POOL / LOAD_AREA) *)
         /\ terrain_loaded lp m_ent m
         (* ... and the memory is not a dead end: one real frame runs from it
            (2026-10-22), and its init_mario_from_save_file cells are the
            ones the real function writes on the boot image *)
         /\ frame_runs lp bm m /\ ifs_tether lp m_boot bm bc
         (* ... and gCurrCourseNum is COURSE_WMOTR, the value the real
            lvl_set_current_level(0, LEVEL_WMOTR) stores (2026-10-22) *)
         /\ course_set lp m_boot m.
Proof.
  intros lp H12.
  destruct (linked12_init_mem lp H12) as (m0 & Hinit).
  destruct (spawn_symbols_resolve lp H12) as (bm & bc & Hbm & Hbc).
  destruct (start_sat_lp lp H12 m0 Hinit bm bc Hbm Hbc)
    as (SafeB & m & Hs & Hok & Hphi & Hpl & Hrc & Hw & Hfd & Hsa & Hns
        & (bL & m_iw & m_ent & le' & HbL & Hiw & Hwl & Hld & Htl & Hfr & Hif & Hcs)).
  exists m, bm, bc, SafeB.
  refine (conj Hbm (conj Hbc (conj Hs (conj Hok (conj Hphi (conj Hpl (conj Hrc (conj Hw
            (conj Hfd (conj Hsa (conj Hns _))))))))))).
  exists m0, bL, m_iw, m_ent, le'.
  exact (conj Hinit (conj HbL (conj Hiw (conj Hwl (conj Hld (conj Htl (conj Hfr (conj Hif Hcs)))))))).
Qed.
