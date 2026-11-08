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
(* goal2_start_sat builds one from the real boot image of ANY linked12    *)
(* link (2026-11-03: by RUNNING THE REAL ENTRY).  From Genv.init_mem lp:  *)
(* initiate_warp(LEVEL_WMOTR, 1, 0x0A, 0) and warp_level's head as real   *)
(* code (EntryWarp), main_pool_init's post-state on a fresh pool block,   *)
(* then StartTerrain.entry_g: sound_init, init_mario_from_save_file, the  *)
(* level script's commands run one by one through the real handlers      *)
(* (level_script.c is linked: ALLOC_LEVEL_POOL, AREA, the OBJECT          *)
(* commands, LOAD_AREA, TERRAIN, ...), init_level, warp_level and         *)
(* init_mario_after_warp -- which set Mario's cells, his floor (find_floor's *)
(* hit, ENTRY_FH = 1669.0), gCurrentArea and the area's Camera.  Only the  *)
(* stand-ins in StartTerrain's header table are not real code (the anim   *)
(* DMA shortcut, gCurrCourseNum, the controller's pad pointer and the     *)
(* rest of the list).  Mario's cells are read off the result by vm        *)
(* (StartTerrain.bm_cells), so the height cells are exactly entry_cells    *)
(* ENTRY_FH and the budget is the real entry's (margin 127).               *)
(*                                                                        *)
(* What it does NOT say: that the game reaches this memory from boot      *)
(* through the menus (the title / file-select path and the boot sequence  *)
(* up to the level script are not run), and the stand-ins remain.         *)
(* ====================================================================== *)

From Coq Require Import ZArith List Lia Reals Lra.
From Flocq Require Import Binary.
From compcert Require Import Coqlib Maps AST Integers Floats Values Memory
  Globalenvs Ctypes Clight ClightBigstep Events Linking IEEE754_extra.
From SM64.Generated Require mario level_update interaction mario_actions_moving
  surface_collision memory game_init object_list_processor area surface_load camera platform_displacement
  graph_node rendering_graph_node mario_anim_data audio_external sound_init libultra_osContInit.
From SM64.Proofs Require Import RealFrameLinked ActionValueFrame Taint CensusV2 MWFReal SpawnInit
  LinkedTwelve InitMemSat BootMWF NoAImpliesNoFlyLinked ClosedMem.
From SM64.Proofs.WMotRRequiresA Require Import HeightInvariant NoAActions WMotRWorld
  FloorList FloorHeight FloorExec AirMatch FfWorld FrameSplit HeightFrame WMotREntry
  EntryWarp WMotRLevel.
From SM64.Proofs Require Import Interp.ClightInterp Interp.MemBuild Interp.InterpFrame.
From SM64.Proofs Require Generic.MaxPerm.
From SM64.Proofs.WMotRRequiresA Require Import FpuFloor FpuValue TerrainRun StartTerrain.
From SM64.Proofs.WMotRRequiresA Require CourseRun AnimData AnimWorld PlatformKeep ObjWorld ObjPhase
  MidKeep PollFlank LevelFlank.
From SM64.Generated Require graph_node area camera.
From SM64.Proofs.NoAImpliesNoFly Require BootRun.
From SM64.Proofs Require AGates LinkedTwelve InitMemSat.
From SM64.Proofs.WMotRRequiresA Require AudioInv.
From SM64.Generated Require object_list_processor.
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
    mario._gControllers;
    (* gEnvironmentRegions (object_list_processor.c): .bss; the real
       load_area_terrain stores NULL into it (FfWorld.env_w) *)
    object_list_processor._gEnvironmentRegions;
    (* gShowDebugText (main.c, FALSE): a common .bss byte in the linked TUs *)
    mario._gShowDebugText ].

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

(* MWF_real across a step that WRITES gMarioStates (the real entry,
   2026-11-03): the rows over the other globals (the controller,
   gMarioState, gGlobalTimer, the handler table, the knockback tables)
   transfer from m; the rows over gMarioStates' cells, SafeB's load closure
   and the anim list's rows are given on m' directly *)
Lemma mwf_real_rebuild : forall lp bm bc oc0 (S : block -> Prop) m m',
    MWF_real lp bm bc oc0 S m ->
    Ple (Mem.nextblock m) (Mem.nextblock m') ->
    AGates.input_a_clear m' bm ->
    (forall ch b ofs v,
        b = bc
        \/ Genv.find_symbol (lp_ge lp) mario._gMarioState = Some b
        \/ Genv.find_symbol (lp_ge lp) interaction._gGlobalTimer = Some b
        \/ Genv.find_symbol (lp_ge lp) interaction._sInteractionHandlers = Some b
        \/ (exists gid, mem_id gid knockback_table_ids = true
              /\ Genv.find_symbol (lp_ge lp) gid = Some b) ->
        Mem.load ch m' b ofs = Some v -> Mem.load ch m b ofs = Some v) ->
    (forall b' o', Mem.load Mptr m' bm 156 = Some (Vptr b' o') -> b' = bc /\ o' = oc0) ->
    (forall av, Mem.load Mint32 m' bm 12 = Some av -> av = Vundef \/ exists vi, av = Vint vi) ->
    (forall fld delta b' o',
        mem_id fld chase_root_fields = true ->
        field_offset (prog_comp_env mario.prog) fld SymbolicLinking.mario_state_members = Errors.OK (delta, Full) ->
        Mem.loadv Mptr m' (Vptr bm (Ptrofs.add Ptrofs.zero (Ptrofs.repr delta))) = Some (Vptr b' o') ->
        S b') ->
    (forall ab b o, Genv.find_symbol (lp_ge lp) mario._gMarioAnimsBuf = Some ab ->
        Mem.load Mptr m' bm 160 = Some (Vptr b o) -> b = ab /\ o = Ptrofs.zero) ->
    (forall b ofs b' o', S b -> Mem.loadv Mptr m' (Vptr b ofs) = Some (Vptr b' o') -> S b') ->
    (forall ab (ofs : Z) b' o', Genv.find_symbol (lp_ge lp) mario._gMarioAnimsBuf = Some ab ->
        Mem.load Mptr m' ab ofs = Some (Vptr b' o') -> S b') ->
    (forall ab bt ot mb mo, Genv.find_symbol (lp_ge lp) mario._gMarioAnimsBuf = Some ab ->
        Mem.load Mptr m' ab 8 = Some (Vptr bt ot) -> Mem.load Mptr m' bm 136 = Some (Vptr mb mo) ->
        bt <> mb) ->
    MWF_real lp bm bc oc0 S m'.
Proof.
  intros lp bm bc oc0 S m m' M Hnb' Hinp Htr R2' R4' R6' R11' R7' R12' R13'.
  destruct M as ((Vbm & Vbc & Vgms & Vsafe & Vgt & Vtb & Vkt & Hnb)
                 & _ & _ & R3 & _ & R5 & _ & _ & R8 & R9 & R10 & _ & _ & _ & R14).
  assert (Hval : forall b, Mem.valid_block m b -> Mem.valid_block m' b).
  { intros b Hb. unfold Mem.valid_block in *. exact (Plt_Ple_trans _ _ _ Hb Hnb'). }
  refine (conj (conj (Hval _ Vbm) (conj (Hval _ Vbc) (conj _ (conj _ (conj _ (conj _ (conj _ _)))))))
          (conj Hinp (conj R2' (conj _ (conj R4' (conj _ (conj R6' (conj R7'
            (conj _ (conj _ (conj _ (conj R11' (conj R12' (conj R13' _)))))))))))))).
  - intros gb Hfs. exact (Hval _ (Vgms _ Hfs)).
  - intros b Hb. exact (Hval _ (Vsafe _ Hb)).
  - intros gb Hfs. exact (Hval _ (Vgt _ Hfs)).
  - intros tb Hfs. exact (Hval _ (Vtb _ Hfs)).
  - intros gid kb Hgid Hfs. exact (Hval _ (Vkt _ _ Hgid Hfs)).
  - exact (Ple_trans _ _ _ Hnb Hnb').
  - intros v Hld. apply R3. exact (Htr _ _ _ _ (or_introl eq_refl) Hld).
  - intros gb b o Hfs Hld. apply (R5 gb b o Hfs).
    cbn [Mem.loadv] in Hld |- *. exact (Htr _ _ _ _ (or_intror (or_introl Hfs)) Hld).
  - intros gb v Hfs Hld. apply (R8 gb v Hfs).
    exact (Htr _ _ _ _ (or_intror (or_intror (or_introl Hfs))) Hld).
  - intros tb ofs b o Hfs Hld. apply (R9 tb ofs b o Hfs).
    exact (Htr _ _ _ _ (or_intror (or_intror (or_intror (or_introl Hfs)))) Hld).
  - intros gid kb ofs v Hgid Hfs Hld. apply (R10 gid kb ofs v Hgid Hfs).
    exact (Htr _ _ _ _ (or_intror (or_intror (or_intror (or_intror (ex_intro _ gid (conj Hgid Hfs)))))) Hld).
  - intros ab Hfs. destruct (R14 ab Hfs) as (A1 & A2 & A3 & A4).
    exact (conj A1 (conj A2 (conj A3 (Hval _ A4)))).
Qed.

(* find_floor's hit under the spawn, as a real number (StartTerrain.ENTRY_FH) *)
Lemma entry_fh_val : R2 ENTRY_FH = 1669%R /\ F32 ENTRY_FH = true.
Proof.
  Local Transparent Float32.of_int.
  unfold ENTRY_FH, Float32.of_int.
  assert (Hr : - 2 ^ 24 <= Int.signed (Int.repr ENTRY_FH_Z) <= 2 ^ 24)
    by (change (Int.signed (Int.repr ENTRY_FH_Z)) with 1669; split; discriminate).
  split.
  - refine (eq_trans (proj1 (BofZ_exact _ _ _ _ _ Hr)) _). reflexivity.
  - exact (proj1 (proj2 (BofZ_exact _ _ _ _ _ Hr))).
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

(* m is what WMotR's real entry leaves, started from the level-entry memory
   m_ent: main_pool_init's post-state on a fresh pool block (StartTerrain
   S8), then THE REAL ENTRY (StartTerrain.entry_made: sound_init,
   init_mario_from_save_file, the level script's commands through the
   real handlers -- the level pool, AREA(1), the OBJECT commands,
   LOAD_AREA's Camera, TERRAIN / MACRO_OBJECTS via load_area_terrain, the
   spawn infos, init_level, warp_level, init_mario_after_warp -- every call
   a real execution under the FPU floor's value clause, FpuValue.sqrtf_value,
   TRUST 3.5; the stand-ins S1-S6 are in StartTerrain's header table).
   Every block of the entry's result reads on m exactly as the entry left
   it, but for the three stand-in globals the later stores set (the anim
   list S7, gCurrCourseNum and the controller S8).
   2026-11-03: replaces the earlier chain of separately-run pieces (the
   Camera, lvl_objs, the terrain, the spawn, Mario's cells as stores). *)
Definition terrain_loaded (lp : Clight.program) (m_ent m : mem) : Prop :=
  exists P0 bpl P Lm,
    Mem.alloc m_ent 0 POOL = (P0, bpl)
    /\ (exists s1 s2 s3 s4 s5,
          sym (lp_ge lp) "sPoolStart"%string = Some s1 /\ sym (lp_ge lp) "sPoolEnd"%string = Some s2
          /\ sym (lp_ge lp) "sPoolFreeSpace"%string = Some s3
          /\ sym (lp_ge lp) "sPoolListHeadL"%string = Some s4
          /\ sym (lp_ge lp) "sPoolListHeadR"%string = Some s5
          /\ apply_writes P0 (pool_writes s1 s2 s3 s4 s5 bpl) 0 = inl P)
    /\ (sqrtf_value -> entry_made (lp_ge lp) P Lm)
    /\ (forall ch b z, Plt b (Mem.nextblock Lm) ->
          (forall id, In id [mario._gMarioAnimsBuf; level_update._gCurrCourseNum; mario._gControllers] ->
             Genv.find_symbol (lp_ge lp) id <> Some b) ->
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
(* NON-VACUITY OF THE OBJECTS PHASE (2026-10-26): from m, one real
   area_update_objects (gAreaUpdateCounter++; update_objects(0), over the
   object lists clear_objects and Mario's spawn built) executes *)
Definition objects_runs (lp : Clight.program) (m : mem) : Prop :=
  sqrtf_value -> exists m', ObjPhase.objects_call lp m m'.

Definition frame_runs (lp : Clight.program) (bm : block) (m : mem) : Prop :=
  sqrtf_value ->
  (AGates.a_pressed_real bm m = false
  /\ (exists bo oo t m' v,
       eval_funcall function_entry2 (lp_ge lp) m (Internal mario.f_execute_mario_action)
         [Vptr bo oo] t m' v
       /\ Mem.load Mint32 m' bm 12 = Some (Vint (Int.repr BootRun.ACT_SPAWN_NO_SPIN_AIRBORNE)))
  (* 2026-10-26: a full frame through the camera: the objects phase
     (area_update_objects) and then update_camera on gCurrentArea's Camera
     (gAreaData[1].camera; the render's geo_camera_main call) both run *)
  /\ exists bgad cam m',
       Genv.find_symbol (lp_ge lp) area._gAreaData = Some bgad
       /\ Mem.load Mint32 m bgad 96 = Some cam
       /\ ObjPhase.objects_call lp m m'
       /\ exists t m'' v,
            eval_funcall function_entry2 (lp_ge lp) m' (Internal camera.f_update_camera) [cam] t m'' v)
  (* 2026-11-02: the WHOLE frame step (HeightFrame.play_frame_step, every
     segment: osContStartReadData's left case, audio_game_loop_tick and
     select_gfx_pool, read_controller_inputs, the level PRE slice in
     PLAY_MODE_NORMAL, area_update_objects, the POST slice, the render
     tail as the identity) runs from m, and the object world and the
     frame-boundary surface counters hold after the objects phase and at
     the frame's end *)
  /\ exists i ma m3 m',
       (forall MWF Phi OW, HeightFrame.play_frame_step lp bm MWF Phi OW i m m')
       /\ ObjPhase.objects_call lp ma m3
       /\ ObjWorld.obj_w (lp_ge lp) bm m3 /\ ObjWorld.ctr_ok (lp_ge lp) m3
       /\ ObjWorld.obj_w (lp_ge lp) bm m' /\ ObjWorld.ctr_ok (lp_ge lp) m'.

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

(* the whole frame's three cell checks (StartTerrain.frame_g), in the
   semantics *)
Lemma pm_b_sound : forall ge m, pm_b ge m = true ->
  forall b, Genv.find_symbol ge level_update._sCurrPlayMode = Some b ->
    Mem.loadv Mint16signed m (Vptr b Ptrofs.zero) = Some (Vint Int.zero).
Proof.
  intros ge m H b Hb. unfold pm_b in H. rewrite Hb, CM.load_eq in H.
  cbn [Mem.loadv]. rewrite Ptrofs.unsigned_zero.
  destruct (Mem.load Mint16signed m b 0) as [[| i | | | |]|]; try discriminate H.
  apply Int.same_if_eq in H. subst i. reflexivity.
Qed.

Lemma in_wmotr_b_sound : forall lp m, in_wmotr_b (lp_ge lp) m = true -> HeightFrame.in_wmotr lp m.
Proof.
  intros lp m H. unfold in_wmotr_b in H.
  destruct (Genv.find_symbol (lp_ge lp) level_update._gCurrLevelNum) as [b|] eqn:Hb; [ | discriminate H ].
  rewrite CM.load_eq in H.
  destruct (Mem.load Mint16signed m b 0) as [[| i | | | |]|] eqn:L; try discriminate H.
  apply Int.same_if_eq in H. subst i. exists b. split; [ exact Hb | exact L ].
Qed.

Lemma plat_still_b_sound : forall lp m, plat_still_b (lp_ge lp) m = true -> PlatformKeep.plat_still lp m.
Proof.
  intros lp m H bp v Hbp Hl. unfold plat_still_b in H.
  destruct (Genv.find_symbol (lp_ge lp) platform_displacement._gMarioPlatform) as [bp'|] eqn:Hbp'; [ | discriminate H ].
  assert (E : bp' = bp) by congruence. subst bp'.
  rewrite CM.load_eq, Hl in H.
  destruct v as [| i | | | | pb po]; try discriminate H.
  - left. apply Int.same_if_eq in H. subst i. reflexivity.
  - right. destruct (Genv.find_symbol (lp_ge lp) object_list_processor._gObjectPool) as [pb'|] eqn:Hp; [ | discriminate H ].
    apply andb_prop in H as [H Ha]. apply andb_prop in H as [H Hm].
    apply andb_prop in H as [E H]. apply Pos.eqb_eq in E. subst pb'.
    exists pb, po. split; [ reflexivity | split; [ first [ exact Hp | reflexivity ] | split ] ].
    2: { exists (Ptrofs.unsigned po / 608). apply Z.eqb_eq in Hm. apply Z.ltb_lt in Ha.
         pose proof (Ptrofs.unsigned_range po) as Rp.
         pose proof (Z.div_mod (Ptrofs.unsigned po) 608 ltac:(lia)) as Dm. rewrite Hm in Dm.
         split; [ split; [ apply Z.div_pos; lia | apply Z.div_lt_upper_bound; lia ] | lia ]. }
    intros k Hk. pose proof (proj1 (forallb_forall _ _) H k Hk) as Hz. cbv beta in Hz.
    rewrite CM.loadv_eq in Hz.
    destruct (Mem.loadv Mint32 m _) as [[| j | | | |]|]; try discriminate Hz.
    apply Int.same_if_eq in Hz. subst j. reflexivity.
Qed.

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
  (* The construction, as hypotheses: the entry stores, the main pool,    *)
  (* THE REAL ENTRY (StartTerrain.entry_g), then the stand-ins S7 / S8.   *)
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

    (* the main pool in main_pool_init's post-state (StartTerrain S8), then
       THE REAL ENTRY: sound_init, init_mario_from_save_file, the level
       script's commands through the real handlers, init_level,
       warp_level, init_mario_after_warp (StartTerrain.entry_g, its
       stand-ins S1-S6 in StartTerrain's header table); old_ok / frag_ok
       are the footprint and pointer checks on its result, CL Mario's cells
       on it *)
    Variables (P0 P Lm : mem) (bpl s1 s2 s3 s4 s5 bn : block).
    Hypothesis AP : Mem.alloc e6 0 POOL = (P0, bpl).
    Hypothesis PW : apply_writes P0 (pool_writes s1 s2 s3 s4 s5 bpl) 0 = inl P.
    Hypothesis Hs1 : sym (lp_ge lp) "sPoolStart"%string = Some s1.
    Hypothesis Hs2 : sym (lp_ge lp) "sPoolEnd"%string = Some s2.
    Hypothesis Hs3 : sym (lp_ge lp) "sPoolFreeSpace"%string = Some s3.
    Hypothesis Hs4 : sym (lp_ge lp) "sPoolListHeadL"%string = Some s4.
    Hypothesis Hs5 : sym (lp_ge lp) "sPoolListHeadR"%string = Some s5.
    Hypothesis Hbn : sym (lp_ge lp) "gSurfacesAllocated"%string = Some bn.
    Hypothesis EN : entry (lp_ge lp) P = Some Lm.
    Variables (bsi bpcs bbs bhud bC bga bpads bca bgad : block) (camv : val).
    Hypothesis Hsi : sym (lp_ge lp) "gPlayerSpawnInfos"%string = Some bsi.
    Hypothesis Hpcs : sym (lp_ge lp) "gPlayerCameraState"%string = Some bpcs.
    Hypothesis Hbbs : sym (lp_ge lp) "gBodyStates"%string = Some bbs.
    Hypothesis Hhud : sym (lp_ge lp) "gHudDisplay"%string = Some bhud.
    Hypothesis HcC : Genv.find_symbol (lp_ge lp) level_update._gCurrCourseNum = Some bC.
    Hypothesis Hga : Genv.find_symbol (lp_ge lp) game_init._gMarioAnims = Some bga.
    Hypothesis Hpads : Genv.find_symbol (lp_ge lp) game_init._gControllerPads = Some bpads.
    Hypothesis Hca : Genv.find_symbol (lp_ge lp) level_update._gCurrentArea = Some bca.
    Hypothesis Hgad : Genv.find_symbol (lp_ge lp) area._gAreaData = Some bgad.
    Hypothesis OK : old_ok (lp_ge lp) bm e6 Lm = true.
    Hypothesis FR : frag_ok (lp_ge lp) bm bpl Lm = true.
    Hypothesis CL : cells_chk Lm (bm_cells bm bo bc ab bsi bpcs bbs bgad bpl) = true.

    (* S7: the anim DMA shortcut (the buffer, the table, the list's three
       cells, the buffer's header); S8: gCurrCourseNum and the controller's
       pad pointer *)
    Variables (m1 m3 z9 z10a z10 z10b z11 z12 z13 z14 z15 z16 z17 m11 : mem) (bt bd : block).
    Hypothesis A1 : Mem.alloc Lm 0 16384 = (m1, bt).
    Hypothesis A4 : Mem.alloc m1 0 1680 = (m3, bd).
    Hypothesis Z9 : apply_writes m3 (tab_writes m0 bd bga) 0 = inl z9.
    Hypothesis Z10a : Mem.store Mint32 z9 ab 0 (Vptr bd Ptrofs.zero) = Some z10a.
    Hypothesis Z10 : Mem.store Mint32 z10a ab 4 (cur_addr m0 bga) = Some z10.
    Hypothesis Z10b : Mem.store Mint32 z10 ab 8 (Vptr bt Ptrofs.zero) = Some z10b.
    Hypothesis Z11 : Mem.store Mint32 z10b bt 0 (Vint Int.zero) = Some z11.
    Hypothesis Z12 : Mem.store Mint32 z11 bt 4 (Vint Int.zero) = Some z12.
    Hypothesis Z13 : Mem.store Mint32 z12 bt 8 (Vint Int.zero) = Some z13.
    Hypothesis Z14 : Mem.store Mint32 z13 bt 12 (Vint Int.zero) = Some z14.
    Hypothesis Z15 : Mem.store Mint32 z14 bt 16 (Vint Int.zero) = Some z15.
    Hypothesis Z16 : Mem.store Mint32 z15 bt 20 (Vint Int.zero) = Some z16.
    Hypothesis Z17 : Mem.store Mint16signed z16 bC 0 (Vint (Int.repr CourseRun.COURSE_WMOTR)) = Some z17.
    Hypothesis ZC : Mem.store Mint32 z17 bc 24 (Vptr bpads Ptrofs.zero) = Some m11.
    (* the checks on the witness itself *)
    Hypothesis CW : cells_chk m11 (bm_cells bm bo bc ab bsi bpcs bbs bgad bpl ++ glob_cells bw bL bca bgad) = true.
    Hypothesis WP : wff_parts WFUEL (lp_ge lp) bpl m11 = true.
    Hypothesis PO : parts_ok WFUEL (lp_ge lp) m11 = true.
    Hypothesis NS : nsurf_ok m11 bn = true.
    Hypothesis IF : ifs_ok (lp_ge lp) m0 bm bc ab bsi bpcs bbs bhud = true.
    Hypothesis FO : frame_ok (lp_ge lp) bm bo m11 = true.
    Hypothesis TC : tab_chk m11 bd bga = true.
    Hypothesis GC : ga_chk m11 bga = true.
    Hypothesis OWc : ObjWorld.ow_chk (lp_ge lp) bm m11 = true.
    Hypothesis BC : bo_chk m11 bo = true.
    Hypothesis OO : done_b (ex_call (lp_ge lp) BootRun.world FUEL m11
                              (Internal area.f_area_update_objects) []) = true.
    Hypothesis LC : Mem.load Mint32 m11 bgad 96 = Some camv.
    Hypothesis CF : cam_frame_ok (lp_ge lp) bgad camv m11 = true.
    Hypothesis DPc : dp_chk WFUEL (lp_ge lp) m11 = true.
    Hypothesis FW : frame_w (lp_ge lp) bm m11 = true.

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
    (* the entry keeps every old block's permissions (StartTerrain.entry_keep) *)
    Lemma keep_PL : acc_keep P0 Lm.
    Proof. exact (acc_keep_trans _ _ _ (apply_writes_keep _ _ _ _ PW) (entry_keep _ _ _ EN)). Qed.
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
    Lemma bd_eq : bd = Pos.succ NL.
    Proof. rewrite (Mem.alloc_result _ _ _ _ _ A4), (Mem.nextblock_alloc _ _ _ _ _ A1). reflexivity. Qed.
    Lemma nb3 : Mem.nextblock m3 = Pos.succ (Pos.succ NL).
    Proof. rewrite (Mem.nextblock_alloc _ _ _ _ _ A4), (Mem.nextblock_alloc _ _ _ _ _ A1). reflexivity. Qed.
    Lemma nb11 : Mem.nextblock m11 = Mem.nextblock m3.
    Proof.
      rewrite (Mem.nextblock_store _ _ _ _ _ _ ZC), (Mem.nextblock_store _ _ _ _ _ _ Z17),
        (Mem.nextblock_store _ _ _ _ _ _ Z16), (Mem.nextblock_store _ _ _ _ _ _ Z15),
        (Mem.nextblock_store _ _ _ _ _ _ Z14), (Mem.nextblock_store _ _ _ _ _ _ Z13),
        (Mem.nextblock_store _ _ _ _ _ _ Z12), (Mem.nextblock_store _ _ _ _ _ _ Z11),
        (Mem.nextblock_store _ _ _ _ _ _ Z10b), (Mem.nextblock_store _ _ _ _ _ _ Z10),
        (Mem.nextblock_store _ _ _ _ _ _ Z10a), (apply_writes_nb _ _ _ _ Z9).
      reflexivity.
    Qed.

    Lemma fresh_ge : forall b, b = bt \/ b = bd -> Ple (Mem.nextblock m0) b.
    Proof.
      intros b [-> | ->]; [ rewrite bt_eq | rewrite bd_eq ]; pose proof nb0_NL; unfold Ple, Plt in *; lia.
    Qed.
    Lemma fresh_lt : forall b, b = bt \/ b = bd -> Plt b (Mem.nextblock m11).
    Proof.
      intros b H. rewrite nb11, nb3.
      destruct H as [-> | ->]; [ rewrite bt_eq | rewrite bd_eq ]; unfold Plt; lia.
    Qed.
    Lemma bt_bd : bt <> bd.
    Proof. rewrite bt_eq, bd_eq. intro E. lia. Qed.
    Lemma bd_ge : Ple (Mem.nextblock m0) bd.
    Proof. exact (fresh_ge _ (or_intror eq_refl)). Qed.
    Lemma bd_lt : Plt bd (Mem.nextblock m11).
    Proof. exact (fresh_lt _ (or_intror eq_refl)). Qed.
    Lemma sym_ne_bd : forall id b, Genv.find_symbol (lp_ge lp) id = Some b -> b <> bd.
    Proof. intros id b H. exact (fresh_not_sym id b bd H bd_ge). Qed.
    Lemma bpl_bd : bpl <> bd.
    Proof. rewrite bd_eq. pose proof bpl_lt. intro E. unfold Plt in *. lia. Qed.
    Lemma sym_lt' : forall s b, sym (lp_ge lp) s = Some b -> Plt b (Mem.nextblock m0).
    Proof. intros s b H. exact (sym_old _ _ H). Qed.
    Lemma sym_ne_fresh : forall id b b', Genv.find_symbol (lp_ge lp) id = Some b ->
        b' = bt \/ b' = bd -> b <> b'.
    Proof. intros id b b' H F. exact (fresh_not_sym id b b' H (fresh_ge b' F)). Qed.
    Lemma old_lt : forall b, Plt b (Mem.nextblock m0) -> Plt b (Mem.nextblock m11).
    Proof. intros b H. rewrite nb11, nb3. pose proof nb0_NL. unfold Plt in *. lia. Qed.
    Lemma sym_ne_bpl : forall id b, Genv.find_symbol (lp_ge lp) id = Some b -> b <> bpl.
    Proof. intros id b H. exact (fresh_not_sym id b bpl H bpl_ge). Qed.
    Lemma bpl_fresh : forall b, b = bt \/ b = bd -> bpl <> b.
    Proof.
      intros b [-> | ->]; [ rewrite bt_eq | rewrite bd_eq ];
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
    Lemma bt_bo : bt <> bo.
    Proof. intro E. exact (sym_ne_fresh _ _ _ Hbo (or_introl eq_refl) (eq_sym E)). Qed.

    (* ---- the cells the vm read off Lm (the entry's result) and m11 ---- *)
    Lemma CLm : forall ch b z v, In (ch, b, z, v) (bm_cells bm bo bc ab bsi bpcs bbs bgad bpl) ->
        Mem.load ch Lm b z = Some v.
    Proof. exact (cells_chk_sound _ _ CL). Qed.
    Lemma C11 : forall ch b z v,
        In (ch, b, z, v) (bm_cells bm bo bc ab bsi bpcs bbs bgad bpl ++ glob_cells bw bL bca bgad) ->
        Mem.load ch m11 b z = Some v.
    Proof. exact (cells_chk_sound _ _ CW). Qed.
    Ltac inc := cbn [bm_cells glob_cells app]; repeat (first [ left; reflexivity | right ]).

    Lemma L_act : Mem.load Mint32 m11 bm 12 = Some (Vint ACT_SPAWN_NO_SPIN_AIRBORNE).
    Proof. apply C11. inc. Qed.
    Lemma L_inp : Mem.load Mint16unsigned m11 bm 2 = Some (Vint Int.zero).
    Proof. apply C11. inc. Qed.
    Lemma L_st : Mem.load Mint16unsigned m11 bm 24 = Some (Vint Int.zero).
    Proof. apply C11. inc. Qed.
    Lemma L_tm : Mem.load Mint16unsigned m11 bm 26 = Some (Vint Int.zero).
    Proof. apply C11. inc. Qed.
    Lemma L_posy : Mem.load Mfloat32 m11 bm 64 = Some (Vsingle ENTRY_Y).
    Proof. apply C11. inc. Qed.
    Lemma L_vely : Mem.load Mfloat32 m11 bm 76 = Some (Vsingle Float32.zero).
    Proof. apply C11. inc. Qed.
    Lemma L_wall : Mem.load Mint32 m11 bm 96 = Some (Vint Int.zero).
    Proof. apply C11. inc. Qed.
    Lemma L_ceil : Mem.load Mint32 m11 bm 100 = Some (Vint Int.zero).
    Proof. apply C11. inc. Qed.
    Lemma L_floor : Mem.load Mint32 m11 bm 104 = Some (Vptr bpl (Ptrofs.repr FLOOR_AT)).
    Proof. apply C11. inc. Qed.
    Lemma L_fh : Mem.load Mfloat32 m11 bm 112 = Some (Vsingle ENTRY_FH).
    Proof. apply C11. inc. Qed.
    Lemma L_held : Mem.load Mint32 m11 bm 124 = Some (Vint Int.zero).
    Proof. apply C11. inc. Qed.
    Lemma L_rid : Mem.load Mint32 m11 bm 132 = Some (Vint Int.zero).
    Proof. apply C11. inc. Qed.
    Lemma L_obj : Mem.load Mint32 m11 bm 136 = Some (Vptr bo (Ptrofs.repr MARIO_OFF)).
    Proof. apply C11. inc. Qed.
    Lemma L_area : Mem.load Mint32 m11 bm 144 = Some (Vptr bgad (Ptrofs.repr 60)).
    Proof. apply C11. inc. Qed.
    (* m->statusForCamera = &gPlayerCameraState[0] (init_mario_from_save_file) *)
    Lemma L_pcs : Mem.load Mint32 m11 bm 148 = Some (Vptr bpcs Ptrofs.zero).
    Proof. apply C11. inc. Qed.
    (* m->marioBodyState = &gBodyStates[0] (init_mario_from_save_file) *)
    Lemma L_body : Mem.load Mint32 m11 bm 152 = Some (Vptr bbs Ptrofs.zero).
    Proof. apply C11. inc. Qed.
    Lemma L_ctl : Mem.load Mint32 m11 bm 156 = Some (Vptr bc Ptrofs.zero).
    Proof. apply C11. inc. Qed.
    Lemma L_anim : Mem.load Mint32 m11 bm 160 = Some (Vptr ab Ptrofs.zero).
    Proof. apply C11. inc. Qed.
    Lemma L_qsd : Mem.load Mfloat32 m11 bm 192 = Some (Vsingle Float32.zero).
    Proof. apply C11. inc. Qed.
    Lemma L_gfx : Mem.load Mfloat32 m11 bo (MARIO_OFF + 36) = Some (Vsingle ENTRY_Y).
    Proof. apply C11. inc. Qed.
    Lemma L_styp : Mem.load Mint16signed m11 bpl FLOOR_AT = Some (Vint (Int.repr FLOOR_TYPE)).
    Proof. apply C11. inc. Qed.
    (* sWarpDest.type = WARP_TYPE_NOT_WARPING (init_mario_after_warp) *)
    Lemma L_wtype : Mem.load Mint8unsigned m11 bw 0 = Some (Vint Int.zero).
    Proof. apply C11. inc. Qed.
    (* gCurrentArea = &gAreaData[1] (load_area) *)
    Lemma L_ca : Mem.load Mint32 m11 bca 0 = Some (Vptr bgad (Ptrofs.repr 60)).
    Proof. apply C11. inc. Qed.
    (* gCurrLevelNum = LEVEL_WMOTR (warp_level) *)
    Lemma L_lvl : Mem.load Mint16signed m11 bL 0 = Some (Vint (Int.repr LEVEL_WMOTR)).
    Proof. apply C11. inc. Qed.

    Lemma floor_u : Ptrofs.unsigned (Ptrofs.repr FLOOR_AT) = FLOOR_AT.
    Proof.
      apply Ptrofs.unsigned_repr.
      unfold FLOOR_AT, Ptrofs.max_unsigned, Ptrofs.modulus, Ptrofs.wordsize, Wordsize_Ptrofs.wordsize.
      destruct Archi.ptr64; cbn; lia.
    Qed.

    (* ---- loads: cells nobody touched read the boot image ---- *)
    Lemma valid_0_e : forall b, Mem.valid_block m0 b -> Mem.valid_block e6 b.
    Proof. intros b H. unfold Mem.valid_block. rewrite nb_e. exact H. Qed.
    Lemma valid_e_L : forall b, Mem.valid_block e6 b -> Mem.valid_block Lm b.
    Proof. intros b H. unfold Mem.valid_block in *. exact (Plt_Ple_trans _ _ _ H (proj1 keep_eL)). Qed.
    (* the entry changes no old block outside f_ids and gMarioStates
       (old_ok) and keeps its permissions (keep_eL): same loads *)
    Lemma ld_Le : forall ch b z, Plt b (Mem.nextblock e6) -> inFb (lp_ge lp) b = false -> b <> bm ->
        Mem.load ch Lm b z = Mem.load ch e6 b z.
    Proof.
      intros ch b z Hb Hf Hm. apply load_same; [ exact (proj2 keep_eL b Hb) | ].
      intros o. exact (old_ok_sound _ _ _ _ OK b o Hb Hf Hm).
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
      rewrite (Mem.load_alloc_unchanged _ _ _ _ _ A4 _ _ _ V1),
        (Mem.load_alloc_unchanged _ _ _ _ _ A1 _ _ _ H). reflexivity.
    Qed.
    Lemma ld_3 : forall ch b z, Mem.valid_block m0 b -> b <> bw -> b <> bL ->
        inFb (lp_ge lp) b = false -> b <> bm -> Mem.load ch m3 b z = Mem.load ch m0 b z.
    Proof.
      intros ch b z H0 N1 N2 Nf Nm. rewrite (ld_3e ch b z (valid_e_L _ (valid_0_e _ H0))).
      rewrite (ld_Le ch b z (valid_0_e _ H0) Nf Nm). exact (ld_e ch b z N1 N2).
    Qed.

    (* an old cell outside the entry's footprint and the stand-in stores *)
    Definition untouched (ch : memory_chunk) (b : block) (z : Z) : Prop :=
      b <> bm /\ b <> bw /\ b <> bL /\ inFb (lp_ge lp) b = false
      /\ (b = ab -> z + size_chunk ch <= 0 \/ 12 <= z) /\ b <> bC
      /\ (b = bc -> z + size_chunk ch <= 24 \/ 28 <= z).

    Lemma ld_back : forall ch b z, Mem.valid_block m0 b -> untouched ch b z ->
        Mem.load ch m11 b z = Mem.load ch m0 b z.
    Proof.
      intros ch b z Hv (Nbm & Nbw & NbL & Nf & Uab & NbC & Ubc).
      assert (Nbt : b <> bt) by (intro E; subst b; exact (Plt_strict _ (Plt_Ple_trans _ _ _ Hv (fresh_ge _ (or_introl eq_refl))))).
      assert (Nbd : b <> bd) by (intro E; subst b; exact (Plt_strict _ (Plt_Ple_trans _ _ _ Hv bd_ge))).
      assert (Kab : forall d, d + 4 <= 12 -> 0 <= d ->
                b <> ab \/ z + size_chunk ch <= d \/ d + size_chunk Mint32 <= z).
      { intros d H1 H2. destruct (peq b ab) as [E | N];
          [ right; cbn [size_chunk]; destruct (Uab E); [ left | right ]; lia | left; exact N ]. }
      rewrite (Mem.load_store_other _ _ _ _ _ _ ZC)
        by (destruct (peq b bc) as [E | N];
            [ right; cbn [size_chunk]; destruct (Ubc E); [ left | right ]; lia | left; exact N ]).
      rewrite (Mem.load_store_other _ _ _ _ _ _ Z17) by (left; exact NbC).
      rewrite (Mem.load_store_other _ _ _ _ _ _ Z16) by (left; exact Nbt).
      rewrite (Mem.load_store_other _ _ _ _ _ _ Z15) by (left; exact Nbt).
      rewrite (Mem.load_store_other _ _ _ _ _ _ Z14) by (left; exact Nbt).
      rewrite (Mem.load_store_other _ _ _ _ _ _ Z13) by (left; exact Nbt).
      rewrite (Mem.load_store_other _ _ _ _ _ _ Z12) by (left; exact Nbt).
      rewrite (Mem.load_store_other _ _ _ _ _ _ Z11) by (left; exact Nbt).
      rewrite (Mem.load_store_other _ _ _ _ _ _ Z10b) by exact (Kab 8 ltac:(lia) ltac:(lia)).
      rewrite (Mem.load_store_other _ _ _ _ _ _ Z10) by exact (Kab 4 ltac:(lia) ltac:(lia)).
      rewrite (Mem.load_store_other _ _ _ _ _ _ Z10a) by exact (Kab 0 ltac:(lia) ltac:(lia)).
      rewrite (apply_writes_other _ _ _ _ _ _ _ Z9)
        by (intros w Hw; rewrite (proj1 (proj2 (tab_writes_shape _ _ _ _ Hw))); congruence).
      exact (ld_3 ch b z Hv Nbw NbL Nf Nbm).
    Qed.

    (* ---- MWF_real ---- *)
    (* SafeB: the SafeB symbols, the main-pool block (the entry's lists,
       surfaces and Camera live there and the pool globals point into it),
       the anim buffer and the DMA table *)
    Definition SB1 : block -> Prop :=
      SafeB_wit lp (fun b => b = bpl) (fun id => mem_id id non_safeb_syms = false).
    Definition SBw : block -> Prop :=
      SafeB_wit lp (fun b => b = bpl \/ b = bt \/ b = bd)
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
        [ intros b [-> | [-> | ->]]; rewrite genv_next_eq;
          [ exact bpl_ge | exact (fresh_ge _ (or_introl eq_refl)) | exact bd_ge ]
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
      (* sWarpDest is a stored global (CensusV2, 2026-10-24): not SafeB *)
      pose proof (proj2 (mwf_real_glob lp bm bc Ptrofs.zero (SafeB_boot lp) D1 D7
                    level_update._sWarpDest ltac:(vm_compute; reflexivity) bw Hbw)) as Gw.
      assert (SL : SafeB_boot lp bL).
      { right. exists level_update._gCurrLevelNum. split; [ left; vm_compute; reflexivity | exact HbL ]. }
      assert (NP : forall i bb oo, Vint i <> Vptr bb oo) by (intros i bb oo E; discriminate E).
      assert (M1 : MWF_real lp bm bc Ptrofs.zero (SafeB_boot lp) e1)
        by (eapply Gw; [ exact M0 | eassumption ]).
      assert (M2 : MWF_real lp bm bc Ptrofs.zero (SafeB_boot lp) e2)
        by (eapply Gw; [ exact M1 | eassumption ]).
      assert (M3 : MWF_real lp bm bc Ptrofs.zero (SafeB_boot lp) e3)
        by (eapply Gw; [ exact M2 | eassumption ]).
      assert (M4 : MWF_real lp bm bc Ptrofs.zero (SafeB_boot lp) e4)
        by (eapply Gw; [ exact M3 | eassumption ]).
      assert (M5 : MWF_real lp bm bc Ptrofs.zero (SafeB_boot lp) e5)
        by (eapply Gw; [ exact M4 | eassumption ]).
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
        mem_id id mwf_row_ids = true -> Plt b (Mem.nextblock e6) /\ inFb (lp_ge lp) b = false.
    Proof.
      intros id b Hs Hn. split; [ rewrite nb_e; exact (sym_old _ _ Hs) | ].
      exact (inFb_sym_false _ _ _ Hs (nonsafe_notF _ Hn)).
    Qed.

    Lemma ld_LP : forall ch b z, Plt b (Mem.nextblock e6) -> inFb (lp_ge lp) b = false -> b <> bm ->
        Mem.load ch Lm b z = Mem.load ch P0 b z.
    Proof.
      intros ch b z Hb Hf Hm. rewrite (ld_Le ch b z Hb Hf Hm). symmetry.
      exact (Mem.load_alloc_unchanged _ _ _ _ _ AP _ _ _ Hb).
    Qed.

    Lemma ld_bm_d : forall m d v, 0 <= d <= 1000 ->
        Mem.loadv Mptr m (Vptr bm (Ptrofs.add Ptrofs.zero (Ptrofs.repr d))) = Some v ->
        Mem.load Mint32 m bm d = Some v.
    Proof.
      intros m d v Hd H. rewrite Mptr32 in H. cbn [Mem.loadv] in H.
      rewrite Ptrofs.add_zero_l, Ptrofs.unsigned_repr in H; [ exact H | ].
      unfold Ptrofs.max_unsigned, Ptrofs.modulus, Ptrofs.wordsize, Wordsize_Ptrofs.wordsize.
      destruct Archi.ptr64; cbn; lia.
    Qed.

    (* across the entry, which WRITES gMarioStates: the rows over the other
       globals transfer (they read non-SafeB symbols outside the entry's
       footprint); Mario's rows are re-proved from the cells the entry left
       (CL); SafeB stays load-closed by frag_ok *)
    Lemma mwf_L : MWF_real lp bm bc Ptrofs.zero SB1 Lm.
    Proof.
      pose proof Sy_1 as Sy. dfacts Sy.
      pose proof mwf_P0 as M.
      pose proof M as (_ & _ & _ & _ & _ & _ & _ & R7 & _ & _ & _ & _ & R12 & _).
      assert (Fs : forall b, inFb (lp_ge lp) b = true \/ b = bpl -> forall z b' o',
                 Mem.load Mint32 Lm b z = Some (Vptr b' o') -> SB1 b').
      { intros b Hb z b' o' Hl.
        pose proof (load_ptr_ok _ _ _ _ _ _ (fun o => proj1 (frag_ok_sound _ _ _ _ FR) b o Hb) Hl) as T.
        destruct (safe_tgt_sym _ _ _ _ T) as [-> | (i & Hi & Hs)]; [ left; reflexivity | ].
        right. exists i. split; [ left; exact Hi | exact Hs ]. }
      assert (SYf : forall id b, Genv.find_symbol (lp_ge lp) id = Some b ->
                mem_id id non_safeb_syms = false -> SB1 b)
        by (intros id b Hs Hn; right; exists id; split; [ left; exact Hn | exact Hs ]).
      assert (SYs : forall s b, sym (lp_ge lp) s = Some b -> mem_id (id s) non_safeb_syms = false -> SB1 b)
        by (intros s b Hs Hn; right; exists (id s); split; [ left; exact Hn | exact Hs ]).
      assert (Ab : Plt ab (Mem.nextblock e6) /\ inFb (lp_ge lp) ab = false)
        by (apply (sym_nf _ _ Hab); vm_compute; reflexivity).
      apply (mwf_real_rebuild lp bm bc Ptrofs.zero SB1 P0 Lm M (proj1 keep_PL)).
      - (* R1: m->input = 0 *)
        intros v Hl. rewrite (CLm Mint16unsigned bm 2 (Vint Int.zero) ltac:(inc)) in Hl.
        injection Hl as <-. reflexivity.
      - (* the rows over the controller and the other globals *)
        intros ch b ofs v Hrow Hl.
        assert (Hnf : (Plt b (Mem.nextblock e6) /\ inFb (lp_ge lp) b = false) /\ b <> bm).
        { destruct Hrow as [ -> | [ Hs | [ Hs | [ Hs | (gid & Hg & Hs) ] ] ] ].
          - exact (conj (sym_nf _ _ Hbc ltac:(vm_compute; reflexivity)) bc_bm).
          - exact (conj (sym_nf _ _ Hs ltac:(vm_compute; reflexivity)) (proj1 (D3 _ Hs))).
          - exact (conj (sym_nf _ _ Hs ltac:(vm_compute; reflexivity)) (proj1 (D4 _ Hs))).
          - exact (conj (sym_nf _ _ Hs ltac:(vm_compute; reflexivity)) (proj1 (D5 _ Hs))).
          - refine (conj (sym_nf _ _ Hs _) (proj1 (D6 _ _ Hg Hs))).
            unfold mwf_row_ids. apply mem_id_app_r. exact Hg. }
        destruct Hnf as ((H1 & H2) & H3).
        rewrite <- (ld_LP _ _ _ H1 H2 H3). exact Hl.
      - (* R2: m->controller = &gControllers[0] *)
        intros b' o' Hl. rewrite Mptr32 in Hl.
        rewrite (CLm Mint32 bm 156 _ ltac:(inc)) in Hl. injection Hl as <- <-. split; reflexivity.
      - (* R4: the action is an int *)
        intros av Hl. rewrite (CLm Mint32 bm 12 _ ltac:(inc)) in Hl. injection Hl as <-.
        right. eexists. reflexivity.
      - (* R6: the chase roots (marioObj, interactObj, usedObj: gObjectPool;
           statusForCamera, marioBodyState; area: gAreaData; heldObj,
           riddenObj NULL) *)
        intros fld delta b' o' Hmem Hfo Hl.
        change ((Pos.eqb fld mario._marioObj
                 || (Pos.eqb fld mario._marioBodyState
                     || (Pos.eqb fld mario._statusForCamera
                         || (Pos.eqb fld mario._heldObj
                             || (Pos.eqb fld mario._usedObj
                                 || (Pos.eqb fld mario._riddenObj
                                     || (Pos.eqb fld mario._interactObj
                                         || (Pos.eqb fld mario._area
                                             || false))))))))%bool = true) in Hmem.
        repeat (apply orb_true_iff in Hmem; destruct Hmem as [Hm | Hmem]);
          try discriminate Hmem; apply Pos.eqb_eq in Hm; subst fld;
          vm_compute in Hfo; injection Hfo as <-;
          pose proof (fun Hd => ld_bm_d _ _ _ Hd Hl) as Hl'; specialize (Hl' ltac:(lia));
          match type of Hl' with
          | Mem.load Mint32 Lm bm ?z = _ => rewrite (CLm Mint32 bm z _ ltac:(inc)) in Hl'
          end;
          first [ discriminate Hl' | injection Hl' as <- _ ];
          first [ exact (SYf _ _ Hbo ltac:(vm_compute; reflexivity))
                | exact (SYf _ _ Hgad ltac:(vm_compute; reflexivity))
                | exact (SYs _ _ Hpcs ltac:(vm_compute; reflexivity))
                | exact (SYs _ _ Hbbs ltac:(vm_compute; reflexivity)) ].
      - (* R11: m->animList = &gMarioAnimsBuf *)
        intros ab' b o Hab' Hl. rewrite Hab in Hab'. injection Hab' as <-. rewrite Mptr32 in Hl.
        rewrite (CLm Mint32 bm 160 _ ltac:(inc)) in Hl. injection Hl as <- <-. split; reflexivity.
      - (* R7 *)
        intros b ofs b' o' Hs Hl. rewrite Mptr32 in Hl. cbn [Mem.loadv] in Hl.
        destruct Hs as [-> | (id & Hid & Hfs)]; [ exact (Fs _ (or_intror eq_refl) _ _ _ Hl) | ].
        destruct (inFb (lp_ge lp) b) eqn:Fb; [ exact (Fs b (or_introl Fb) _ _ _ Hl) | ].
        assert (Hb : Plt b (Mem.nextblock e6)) by (rewrite nb_e; exact (sym_old _ _ Hfs)).
        assert (Nb : b <> bm) by exact (D2 _ (or_intror (ex_intro _ id (conj Hid Hfs)))).
        apply (R7 b ofs b' o' (or_intror (ex_intro _ id (conj Hid Hfs)))).
        rewrite Mptr32. cbn [Mem.loadv]. rewrite <- (ld_LP _ _ _ Hb Fb Nb). exact Hl.
      - (* R12: the anim list is outside the entry's footprint *)
        intros ab' ofs b' o' Hab' Hl. rewrite Hab in Hab'. injection Hab' as <-.
        apply (R12 ab ofs b' o' Hab). rewrite <- (ld_LP _ _ _ (proj1 Ab) (proj2 Ab) ab_bm). exact Hl.
      - (* R13: the anim list's bufTarget is still the boot image's NULL *)
        intros ab' bt' ot mb mo Hab' Hl _. rewrite Hab in Hab'. injection Hab' as <-.
        exfalso. rewrite Mptr32 in Hl.
        rewrite (ld_Le _ _ _ (proj1 Ab) (proj2 Ab) ab_bm) in Hl.
        rewrite (ld_e _ _ _ (symne lp _ _ _ _ Hab Hbw eq_refl) (symne lp _ _ _ _ Hab HbL eq_refl)) in Hl.
        eapply boot_bss_noptr with (id := mario._gMarioAnimsBuf) (b := ab) (chunk := Mint32) (ofs := 8);
          first [ exact H12 | exact Hinit | reflexivity | exact Hab | exact Hl ].
    Qed.

    Lemma mwf_m3 : MWF_real lp bm bc Ptrofs.zero SB1 m3.
    Proof.
      pose proof Sy_1 as Sy. dfacts Sy. pose proof mwf_L as ML.
      eapply (mwf_real_alloc lp); try eassumption.
      eapply (mwf_real_alloc lp); try eassumption.
    Qed.

    Lemma bt_valid3 : Mem.valid_block m3 bt.
    Proof. eapply Mem.valid_block_alloc; [ exact A4 | exact (Mem.valid_new_block _ _ _ _ _ A1) ]. Qed.
    Lemma bd_valid3 : Mem.valid_block m3 bd.
    Proof. exact (Mem.valid_new_block _ _ _ _ _ A4). Qed.
    Lemma bd_noptr3 : forall ofs b' o', Mem.loadv Mptr m3 (Vptr bd ofs) = Some (Vptr b' o') -> False.
    Proof.
      intros ofs b' o' Hld. cbn [Mem.loadv] in Hld.
      pose proof (Mem.load_alloc_same _ _ _ _ _ A4 _ _ _ Hld). discriminate.
    Qed.
    Lemma bt_noptr3 : forall ofs b' o', Mem.loadv Mptr m3 (Vptr bt ofs) = Some (Vptr b' o') -> False.
    Proof.
      intros ofs b' o' Hld. cbn [Mem.loadv] in Hld.
      rewrite (Mem.load_alloc_unchanged _ _ _ _ _ A4 _ _ _ (Mem.valid_new_block _ _ _ _ _ A1)) in Hld.
      pose proof (Mem.load_alloc_same _ _ _ _ _ A1 _ _ _ Hld). discriminate.
    Qed.

    Lemma mwf_w3 : MWF_real lp bm bc Ptrofs.zero SBw m3.
    Proof.
      apply (mwf_real_widen lp bm bc Ptrofs.zero SB1 SBw (fun b => b = bt \/ b = bd) m3 mwf_m3).
      - intros b [[E | E] | H]; [ left; left; exact E | right; exact E | left; right; exact H ].
      - intros b [E | H]; [ left; left; exact E | right; exact H ].
      - intros b [-> | ->]; [ exact bt_valid3 | exact bd_valid3 ].
      - intros b ofs b' o' [-> | ->] Hld; [ exact (bt_noptr3 _ _ _ Hld) | exact (bd_noptr3 _ _ _ Hld) ].
      - intros ab' Hab'. exact (safeb_of_nonfam_sym lp SBw Sy_w _ _ Hab' eq_refl).
    Qed.

    (* block disequalities among symbols and the fresh blocks *)
    Ltac fr := first [ left; reflexivity | right; reflexivity ].
    Ltac dz := first [ congruence
      | exact bt_bd | apply not_eq_sym; exact bt_bd
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

    (* Mario's object pointer, before the anim list's bufTarget store *)
    Lemma L10_obj : Mem.load Mint32 z10 bm 136 = Some (Vptr bo (Ptrofs.repr MARIO_OFF)).
    Proof.
      pose proof ab_bm.
      peel2 Z10; peel2 Z10a; peelW.
      rewrite (ld_3e _ _ _ (valid_e_L _ (valid_0_e _ (Genv.find_symbol_not_fresh _ _ Hinit Hbm)))).
      apply CLm. inc.
    Qed.

    Theorem mwf_w11 : MWF_real lp bm bc Ptrofs.zero SBw m11.
    Proof.
      pose proof Sy_w as Sy. dfacts Sy.
      pose proof mwf_w3 as M3.
      assert (NP : forall i bb oo, Vint i <> Vptr bb oo) by (intros i bb oo E; discriminate E).
      assert (Sga : SBw bga).
      { right. exists game_init._gMarioAnims. split; [ left; vm_compute; reflexivity | exact Hga ]. }
      assert (Mz9 : MWF_real lp bm bc Ptrofs.zero SBw z9).
      { apply (apply_writes_ind (MWF_real lp bm bc Ptrofs.zero SBw) _ _ _ _ Z9); [ | exact M3 ].
        intros w mm mm' Hw Hs Hm.
        destruct (tab_writes_shape _ _ _ _ Hw) as (_ & Eb & Hv). rewrite Eb in Hs.
        eapply (mwf_real_chase_ptr lp) with (mm := mm) (mm' := mm') (bsafe := bd); try eassumption;
          [ left; right; right; reflexivity | ].
        intros bb oo E. destruct Hv as [Hv | Hv]; [ rewrite Hv in E; injection E as <- _; exact Sga
                                                  | exfalso; exact (Hv _ _ E) ]. }
      assert (Mz10a : MWF_real lp bm bc Ptrofs.zero SBw z10a).
      { eapply (mwf_anim_tab_store lp bm bc Ptrofs.zero SBw D1) with (mm := z9) (ab := ab); try eassumption.
        intros b o E. injection E as <- _. left. right. right. reflexivity. }
      assert (Mz10 : MWF_real lp bm bc Ptrofs.zero SBw z10).
      { eapply (mwf_real_anim_cur_store lp) with (mm := z10a) (ab := ab); try eassumption.
        intros b o E. unfold cur_addr in E.
        revert E; match goal with |- context [match ?x with _ => _ end] => destruct x as [[]|] end; intro E; try discriminate E.
        injection E as <- _. exact Sga. }
      assert (Bt : SBw bt) by (left; right; left; reflexivity).
      assert (Mz10b : MWF_real lp bm bc Ptrofs.zero SBw z10b).
      { eapply (mwf_real_buf_store lp) with (mm := z10) (mm' := z10b) (ab := ab); try eassumption.
        - intros b o E. injection E as <- _. exact Bt.
        - intros b o mb mo E Hl. injection E as <- _.
          change (Mem.load Mint32 z10 bm 136 = Some (Vptr mb mo)) in Hl.
          rewrite L10_obj in Hl. injection Hl as <- _. exact bt_bo. }
      assert (Mz11 : MWF_real lp bm bc Ptrofs.zero SBw z11)
        by (eapply (mwf_real_chase lp) with (mm := z10b) (bsafe := bt); try eassumption; apply NP).
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
      eapply (mwf_real_bc_store lp) with (mm := z17) (mm' := m11); try eassumption.
      intros v Hl. pose proof Mz17 as (_ & _ & _ & R3 & _). apply R3.
      rewrite <- Hl. symmetry. apply (Mem.load_store_other _ _ _ _ _ _ ZC). right. left.
      change (Ptrofs.unsigned (Ptrofs.add Ptrofs.zero (Ptrofs.repr 18))) with 18.
      cbn [size_chunk]. lia.
    Qed.

    (* ---- the facts PhiW reads ---- *)
    (* Mario's object (pool offset MARIO_OFF): the cells the frame world reads are
       zero on the witness -- checked on m11 itself (StartTerrain.bo_chk),
       after clear_objects and spawn_objects_from_info wrote the slot *)
    Lemma bo_z : forall ch z, In (ch, z) bo_cells -> Mem.load ch m11 bo (MARIO_OFF + z) = Some (Vint Int.zero).
    Proof. exact (bo_chk_sound _ _ BC). Qed.

    (* Hhud in find_symbol form *)
    Lemma Hhud_fs : Genv.find_symbol (lp_ge lp) (id "gHudDisplay"%string) = Some bhud.
    Proof. exact Hhud. Qed.

    Ltac peelZ := peel2 ZC; peel2 Z17; peel2 Z16; peel2 Z15; peel2 Z14; peel2 Z13; peel2 Z12; peel2 Z11;
      peel2 Z10b; peel2 Z10; peel2 Z10a; peelW.

    Lemma L_buf : Mem.load Mint32 m11 ab 8 = Some (Vptr bt Ptrofs.zero).
    Proof.
      peel2 ZC; peel2 Z17; peel2 Z16; peel2 Z15; peel2 Z14; peel2 Z13; peel2 Z12; peel2 Z11.
      rewrite (Mem.load_store_same _ _ _ _ _ _ Z10b). reflexivity.
    Qed.
    Lemma L_tab : Mem.load Mint32 m11 ab 0 = Some (Vptr bd Ptrofs.zero).
    Proof.
      peel2 ZC; peel2 Z17; peel2 Z16; peel2 Z15; peel2 Z14; peel2 Z13; peel2 Z12; peel2 Z11;
        peel2 Z10b; peel2 Z10.
      rewrite (Mem.load_store_same _ _ _ _ _ _ Z10a). reflexivity.
    Qed.

    (* every block below the entry's nextblock, except the three stand-in
       globals (the anim list, gCurrCourseNum, the controller), reads on
       the witness exactly what THE REAL ENTRY left *)
    Lemma ld_entry : forall ch b z, Plt b (Mem.nextblock Lm) ->
        (forall id, In id [mario._gMarioAnimsBuf; level_update._gCurrCourseNum; mario._gControllers] ->
           Genv.find_symbol (lp_ge lp) id <> Some b) ->
        Mem.load ch m11 b z = Mem.load ch Lm b z.
    Proof.
      intros ch b z Hb Hn.
      assert (Nab : b <> ab) by (intro E; subst b; exact (Hn _ (or_introl eq_refl) Hab)).
      assert (NbC : b <> bC) by (intro E; subst b; exact (Hn _ (or_intror (or_introl eq_refl)) HcC)).
      assert (Nbc : b <> bc)
        by (intro E; subst b; exact (Hn _ (or_intror (or_intror (or_introl eq_refl))) Hbc)).
      assert (Nbt : b <> bt) by (rewrite bt_eq; intro E; subst b; unfold NL, Plt in *; lia).
      assert (Nbd : b <> bd) by (rewrite bd_eq; intro E; subst b; unfold NL, Plt in *; lia).
      rewrite (Mem.load_store_other _ _ _ _ _ _ ZC) by (left; exact Nbc).
      rewrite (Mem.load_store_other _ _ _ _ _ _ Z17) by (left; exact NbC).
      rewrite (Mem.load_store_other _ _ _ _ _ _ Z16) by (left; exact Nbt).
      rewrite (Mem.load_store_other _ _ _ _ _ _ Z15) by (left; exact Nbt).
      rewrite (Mem.load_store_other _ _ _ _ _ _ Z14) by (left; exact Nbt).
      rewrite (Mem.load_store_other _ _ _ _ _ _ Z13) by (left; exact Nbt).
      rewrite (Mem.load_store_other _ _ _ _ _ _ Z12) by (left; exact Nbt).
      rewrite (Mem.load_store_other _ _ _ _ _ _ Z11) by (left; exact Nbt).
      rewrite (Mem.load_store_other _ _ _ _ _ _ Z10b) by (left; exact Nab).
      rewrite (Mem.load_store_other _ _ _ _ _ _ Z10) by (left; exact Nab).
      rewrite (Mem.load_store_other _ _ _ _ _ _ Z10a) by (left; exact Nab).
      rewrite (apply_writes_other _ _ _ _ _ _ _ Z9)
        by (intros w Hw; rewrite (proj1 (proj2 (tab_writes_shape _ _ _ _ Hw))); congruence).
      exact (ld_3e _ _ _ Hb).
    Qed.

    (* the height cells: the real WMotR entry's (WMotREntry.entry_cells),
       with floorHeight find_floor's hit under the spawn (ENTRY_FH, 1669.0),
       all read off the witness by vm (StartTerrain.bm_cells) *)
    Definition c0 : cells := entry_cells ENTRY_FH.

    Lemma read_c0 : read_cells bm m11 c0.
    Proof.
      unfold read_cells, c0, entry_cells, OFS_ACTION, OFS_ASTATE, OFS_ATIMER, OFS_POSY, OFS_VELY, OFS_FLOORH, OFS_MARIOOBJ.
      cbn [c_action c_state c_timer c_posy c_vely c_floorh c_gfxy].
      split; [ exact L_act | ].
      split; [ exact L_st | ].
      split; [ exact L_tm | ].
      split; [ exact L_posy | ].
      split; [ exact L_vely | ].
      split; [ exact L_fh | ].
      exists bo, (Ptrofs.repr MARIO_OFF). split; [ exact L_obj | ].
      rewrite mario_off_u. change OFS_GFXY with 36. exact L_gfx.
    Qed.

    Lemma budget_c0 : budget_ok c0.
    Proof.
      destruct entry_fh_val as (Er & Ef).
      apply entry_budget; [ exact Ef | right; rewrite Er; lra ].
    Qed.

    Lemma act_noA : action_sat R_noA m11 bm.
    Proof. intros v Hl. rewrite L_act in Hl. injection Hl as <-. exact entry_action_noA. Qed.

    Lemma hinv : height_invariant bm R_noA m11.
    Proof. split; [ exact act_noA | exists c0; split; [ exact read_c0 | exact budget_c0 ] ]. Qed.

    (* the WMotR world *)
    Lemma world11 : wmotr_world bm m11.
    Proof.
      unfold wmotr_world, wall_ok, ceil_ok, WALL_OFF, CEIL_OFF, FLOOR_OFF, HELD_OFF, RIDDEN_OFF, QSD_OFF.
      split; [ exact I | ].
      split; [ exact I | ].
      split; [ intros v Hl; rewrite L_floor in Hl; injection Hl as <-;
               exists bpl, (Ptrofs.repr FLOOR_AT), (Int.repr FLOOR_TYPE); split; [ reflexivity | ];
               split; [ rewrite floor_u; exact L_styp
                      | rewrite wmotr_surface_types_value;
                        change (Int.signed (Int.repr FLOOR_TYPE)) with 21; cbn; tauto ] | ].
      split; [ rewrite L_held; reflexivity | ].
      split; [ rewrite L_rid; reflexivity | ].
      split; [ exact L_qsd | ].
      exists bo, (Ptrofs.repr MARIO_OFF), Int.zero, Int.zero.
      split; [ exact L_obj | ].
      split; [ rewrite mario_off_u; change O_INTERACT_STATUS with 308;
               rewrite (bo_z Mint32 308) by (repeat (first [ left; reflexivity | right ])); reflexivity | ].
      split; [ reflexivity | ].
      split; [ rewrite mario_off_u; change NUMCOLL_OFF with 118;
               rewrite (bo_z Mint16signed 118) by (repeat (first [ left; reflexivity | right ])); reflexivity | ].
      split; [ rewrite Int.signed_zero; lia | ].
      intros i v Hi. exfalso. rewrite Int.signed_zero in Hi. lia.
    Qed.

    Lemma coll_noptr : forall i cb co, 0 <= i < 4
        -> Mem.load Mint32 m11 bo (Ptrofs.unsigned (Ptrofs.repr MARIO_OFF) + COLL_OFF + 4 * i)
           = Some (Vptr cb co) -> False.
    Proof.
      intros i cb co Hi Hl.
      rewrite mario_off_u in Hl. rewrite <- Z.add_assoc in Hl. unfold COLL_OFF in Hl.
      assert (Hc : i = 0 \/ i = 1 \/ i = 2 \/ i = 3) by lia.
      destruct Hc as [-> | [-> | [-> | ->]]];
        rewrite bo_z in Hl by (repeat (first [ left; reflexivity | right ])); discriminate Hl.
    Qed.

    Lemma wc_noptr : forall off sb so, off = WALL_OFF \/ off = CEIL_OFF ->
        Mem.load Mint32 m11 bm off = Some (Vptr sb so) -> False.
    Proof.
      intros off sb so [-> | ->] Hl;
        [ change WALL_OFF with 96 in Hl; rewrite L_wall in Hl
        | change CEIL_OFF with 100 in Hl; rewrite L_ceil in Hl ]; discriminate Hl.
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
          injection Hl as <- _. exact (not_eq_sym (bpl_fresh _ (or_introl eq_refl))).
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
          injection Hl as <- _. exact (not_eq_sym (sym_ne_bpl _ _ Hbo)).
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
      assert (T : thr = Pos.succ (Pos.succ NL)) by (unfold thr; rewrite nb11, nb3; reflexivity).
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
      (* the entry: unchanged blocks keep the boot image's closure, its
         pointers aim below nextblock (frag_ok) *)
      assert (NLm : Mem.inject_neutral thr Lm).
      { apply (neutral_frame (lp_ge lp) thr e6 Lm bm bpl N0);
          [ | exact keep_eL | rewrite bpl_eq, nb_e; reflexivity | exact OK | exact FR ].
        rewrite T. unfold NL, Ple. lia. }
      pose proof (Mem.alloc_inject_neutral _ _ _ _ _ _ A1 NLm ltac:(rewrite T; unfold NL, Plt; lia)) as N1.
      pose proof (Mem.alloc_inject_neutral _ _ _ _ _ _ A4 N1
                    ltac:(rewrite T, (Mem.nextblock_alloc _ _ _ _ _ A1); unfold NL, Plt; lia)) as N3.
      assert (Lab : Plt ab thr) by exact (sym_lt _ _ Hab).
      assert (Lbc : Plt bc thr) by exact (sym_lt _ _ Hbc).
      assert (Lbt : Plt bt thr) by exact (fresh_lt _ (or_introl eq_refl)).
      assert (Lbd : Plt bd thr) by exact bd_lt.
      assert (Lga : Plt bga thr) by exact (sym_lt _ _ Hga).
      assert (W9 : Mem.inject_neutral thr z9).
      { apply (apply_writes_ind (Mem.inject_neutral thr) _ _ _ _ Z9); [ | exact N3 ].
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
      pose proof (Mem.store_inject_neutral _ _ _ _ _ _ _ Z10b W10 Lab (vinj_ptr _ _ Lbt)) as W10b.
      pose proof (Mem.store_inject_neutral _ _ _ _ _ _ _ Z11 W10b Lbt (Val.inject_int _ _)) as W11.
      pose proof (Mem.store_inject_neutral _ _ _ _ _ _ _ Z12 W11 Lbt (Val.inject_int _ _)) as W12.
      pose proof (Mem.store_inject_neutral _ _ _ _ _ _ _ Z13 W12 Lbt (Val.inject_int _ _)) as W13.
      pose proof (Mem.store_inject_neutral _ _ _ _ _ _ _ Z14 W13 Lbt (Val.inject_int _ _)) as W14.
      pose proof (Mem.store_inject_neutral _ _ _ _ _ _ _ Z15 W14 Lbt (Val.inject_int _ _)) as W15.
      pose proof (Mem.store_inject_neutral _ _ _ _ _ _ _ Z16 W15 Lbt (Val.inject_int _ _)) as W16.
      assert (LbC : Plt bC thr) by exact (sym_lt _ _ HcC).
      pose proof (Mem.store_inject_neutral _ _ _ _ _ _ _ Z17 W16 LbC (Val.inject_int _ _)) as W17.
      assert (Lpads : Plt bpads thr) by exact (sym_lt _ _ Hpads).
      exact (Mem.store_inject_neutral _ _ _ _ _ _ _ ZC W17 Lbc (vinj_ptr _ _ Lpads)).
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
    Lemma keep_1_11 : acc_keep m1 m11.
    Proof.
      eapply acc_keep_trans; [ exact (alloc_keep _ _ _ _ _ A4) | ].
      eapply acc_keep_trans; [ exact (apply_writes_keep _ _ _ _ Z9) | ].
      eapply acc_keep_trans; [ exact (store_keep _ _ _ _ _ _ Z10a) | ].
      eapply acc_keep_trans; [ exact (store_keep _ _ _ _ _ _ Z10) | ].
      eapply acc_keep_trans; [ exact (store_keep _ _ _ _ _ _ Z10b) | ].
      eapply acc_keep_trans; [ exact (store_keep _ _ _ _ _ _ Z11) | ].
      eapply acc_keep_trans; [ exact (store_keep _ _ _ _ _ _ Z12) | ].
      eapply acc_keep_trans; [ exact (store_keep _ _ _ _ _ _ Z13) | ].
      eapply acc_keep_trans; [ exact (store_keep _ _ _ _ _ _ Z14) | ].
      eapply acc_keep_trans; [ exact (store_keep _ _ _ _ _ _ Z15) | ].
      eapply acc_keep_trans; [ exact (store_keep _ _ _ _ _ _ Z16) | ].
      eapply acc_keep_trans; [ exact (store_keep _ _ _ _ _ _ Z17) | ].
      exact (store_keep _ _ _ _ _ _ ZC).
    Qed.
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
      exact keep_1_11.
    Qed.

    Lemma perm_0_11 : forall b z k p, Plt b (Mem.nextblock m0) ->
        (Mem.perm m11 b z k p <-> Mem.perm m0 b z k p).
    Proof. intros b z k p Hb. exact (perm_same m11 m0 b z k p (proj2 keep_0_11 b Hb)). Qed.

    Lemma pfwd : forall b z k p, Mem.perm m0 b z k p -> Mem.perm m11 b z k p.
    Proof.
      intros b z k p H. exact (proj2 (perm_0_11 b z k p (Mem.perm_valid_block _ _ _ _ _ H)) H).
    Qed.

    (* every memory a Clight run reaches from m11 reads a partition only in
       its 1536 cells (ObjWorld.part_cells): the partition is the definer's
       6144 bytes (part_bound) and no run grows a Max permission
       (Generic.MaxPerm) *)
    Lemma part_cells_of : forall m, MaxPerm.MP m11 m -> ObjWorld.part_cells (lp_ge lp) m.
    Proof.
      intros m (_ & PMx) id bp z hd Hin Hs L.
      destruct (Mem.load_valid_access _ _ _ _ _ L) as (RP & _).
      assert (Pz : Mem.perm m bp z Cur Readable) by (apply RP; cbn [size_chunk]; lia).
      apply Mem.perm_cur_max in Pz.
      assert (V11 : Mem.valid_block m11 bp) by exact (sym_lt _ _ Hs).
      pose proof (PMx bp z Readable V11 Pz) as Q11.
      pose proof (proj1 (perm_0_11 bp z Max Readable (sym_old _ _ Hs)) Q11) as Q0.
      pose proof (part_bound lp H12 m0 Hinit id bp Hin Hs z Max Readable Q0) as B.
      change (Z.of_nat ObjWorld.PCELLS) with 1536. lia.
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

    Ltac neq := dz.

    Ltac norl := let o := fresh "o" in let Hin := fresh "Hin" in
      intros (o & Hin); cbn [ff_rl map In] in Hin;
      repeat (destruct Hin as [Hin | Hin];
              [ injection Hin as Hin; revert Hin; neq | ]);
      destruct Hin.

    Lemma Hpcs_fs : Genv.find_symbol (lp_ge lp) camera._gPlayerCameraState = Some bpcs.
    Proof. exact Hpcs. Qed.
    Lemma Hbbs_fs : Genv.find_symbol (lp_ge lp) mario._gBodyStates = Some bbs.
    Proof. exact Hbbs. Qed.

    Definition RL : list (option val) := ff_rl bm bo (Ptrofs.repr MARIO_OFF) bfi bmiss bcalls ab bt biom bmq brm blk bpcs bsr bsrc bsms bbs bfa.

    Lemma bpl_not_rl : ~ rblk RL bpl.
    Proof. pose proof Hpcs_fs. pose proof Hbbs_fs. unfold RL. norl. Qed.

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
      pose proof Hpcs_fs. pose proof Hbbs_fs.
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
          rewrite genv_next_eq. intros Hx. cbv beta in Hx. pose proof bpl_ge as G. unfold Plt, Ple in *. lia.
        - intros b o Ho. destruct (proj2 (part_lists _ Hp) _ Ho) as (o' & E & _ & _).
          injection E as -> _. rewrite genv_next_eq. exact bpl_ge. }
      split; [ unfold SZ_SURFACE; lia | exact (dp_chk_sound _ _ _ DPc) ].
    Qed.

    (* GOAL 2's floor premise and the decoder agreement, on the witness *)
    Lemma floor_data11 : floor_data (lp_ge lp) m11.
    Proof. exact (parts_ok_floor_data _ _ _ PO). Qed.
    Lemma static_agree11 : static_agree (lp_ge lp) m11.
    Proof. exact (parts_ok_agree _ _ _ PO). Qed.


    (* ---- the animation world (AnimWorld.anim_w) on the witness ---- *)
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
      eapply (AnimWorld.anim_w_other (lp_ge lp) bm m11 _ ab bga bauc bd Ptrofs.zero bt Ptrofs.zero bo (Ptrofs.repr MARIO_OFF));
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
        - unfold AnimWorld.flank_gvars, RenderAnim.render_gvars, LevelGvars.level_gvars, LevelGvars.lvl_safe_gvars, LevelGvars.warp_gvars in Hin. cbn [app] in Hin.
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
      - rewrite L_area in Hl. injection Hl as <- _. exact (sym_ne_bd _ _ Hgad).
      - rewrite L_ctl in Hl. injection Hl as <- _. exact (sym_ne_bd _ _ Hbc).
    Qed.

    Lemma ffw11 : ffw (lp_ge lp) bm m11.
    Proof.
      split.
      { rewrite genv_next_eq, nb11, nb3. pose proof nb0_NL. unfold Ple, Plt in *. lia. }
      split.
      2: exact floor_data11.
      pose proof Hpcs_fs as Hpcs'. pose proof Hbbs_fs as Hbbs'.
      exists {| fw_gp := Mem.flat_inj thr; fw_bfi := bfi; fw_bmiss := bmiss; fw_bcalls := bcalls;
                fw_bsin := bsin; fw_ab := ab; fw_biom := biom; fw_bmq := bmq; fw_brm := brm; fw_blk := blk;
                fw_bpc := bpcs; fw_bsr := bsr; fw_bsrc := bsrc; fw_bsms := bsms; fw_bbs := bbs; fw_bfa := bfa;
                fw_bo := bo; fw_oo := Ptrofs.repr MARIO_OFF; fw_bt := bt; fw_ot := Ptrofs.zero;
                fw_fl := Vptr bpl (Ptrofs.repr FLOOR_AT); fw_ar := Vptr bgad (Ptrofs.repr 60);
                fw_inp := Int.zero; fw_ctl := Vptr bc Ptrofs.zero |}.
      (* one goal per ffw_facts field, in declaration order *)
      apply mk_ffw_facts; ffw_simpl.
      - exact closed11.
      - intros id b Hfs; exact (flat_some _ (sym_lt _ _ Hfs)).
      - exact (flat_some _ (sym_lt _ _ Hbm)).
      - assumption.
      - assumption.
      - assumption.
      - assumption.
      - assumption.
      - assumption.
      - assumption.
      - assumption.
      - assumption.
      - assumption.
      - assumption.
      - assumption.
      - assumption.
      - assumption.
      - assumption.
      - exact L_obj.
      - unfold SZ_OBJECT; vm_compute; discriminate.
      - exact L_anim.
      - exact L_buf.
      - vm_compute; discriminate.
      - exact bo_bm.
      - intro E; exact (sym_ne_fresh _ _ _ Hbm (or_introl eq_refl) (eq_sym E)).
      - exact bt_bo.
      - intros b [Hin | [Hin | Hin]];
               [ cbn [In] in Hin; repeat (destruct Hin as [<- | Hin]; [ split; neq | ]); destruct Hin
               | split; neq | lvl_cases Hin; split; neq ].
      - exact wff11.
      - exact L_floor.
      - (* m->floor: find_floor's hit, a surface in the pool block *)
        left. exists bpl, (Ptrofs.repr FLOOR_AT). split; [ reflexivity | ].
        split; [ exact bpl_valid11 | ].
        split; [ unfold SZ_SURFACE; lia | ].
        split; [ unfold SZ_SURFACE; vm_compute; discriminate | ].
        exact bpl_not_rl.
      - intros off sb so Hoff Hl; exfalso; exact (wc_noptr off sb so Hoff Hl).
      - exact L_area.
      - (* m->area: &gAreaData[1], as load_area sets it *)
        exists bgad, (Ptrofs.repr 60). split; [ reflexivity | ].
        split; [ exact (sym_lt _ _ Hgad) | ].
        split; [ unfold SZ_AREA; lia | ].
        split; [ unfold SZ_AREA; vm_compute; discriminate | ].
        fold RL. unfold RL. norl.
      - exact L_inp.
      - reflexivity.
      - exact L_ctl.
      - exists bc, Ptrofs.zero. split; [ reflexivity | ].
        split; [ exact (sym_lt _ _ Hbc) | ].
        split; [ unfold SZ_CTL; lia | ].
        split; [ unfold SZ_CTL; vm_compute; discriminate | ].
        norl.
      - intros i cb co Hi Hl; exfalso; exact (coll_noptr _ _ _ Hi Hl).
      - exact L_pcs.
      - exact L_body.
      - (* Mario's gfx.throwMatrix: the zero-filled pool's NULL *)
        left. rewrite mario_off_u. change FFW_THROW with 80.
        rewrite (bo_z Mint32 80) by (repeat (first [ left; reflexivity | right ])); reflexivity.
      - (* the surface pointers: the wall / ceil cells hold none, the floor is
           in the pool block *)
        intros off sb so [Hoff | [Hoff | Hoff]] Hl.
        + exfalso; exact (wc_noptr off sb so (or_introl Hoff) Hl).
        + exfalso; exact (wc_noptr off sb so (or_intror Hoff) Hl).
        + subst off. change FFW_FLOOR with 104 in Hl. rewrite L_floor in Hl. injection Hl as <- _.
          rewrite genv_next_eq. exact bpl_ge.
      - exact Hbo.
      - intros b o E. injection E as <- _. right. exact Hgad.
      - rewrite genv_next_eq. exact (fresh_ge _ (or_introl eq_refl)).
      - intros b o E. injection E as <- _. exact Hbc.
      - intros i cb co Hi Hl; exfalso; exact (coll_noptr _ _ _ Hi Hl).
      - (* Mario's hitbox: allocate_object's 100.0f / 0.0f, run by the real
           spawn_objects_from_info (StartTerrain.bo_chk) *)
        exists FFW_F100. split; [ | left; reflexivity ].
        rewrite mario_off_u. change FFW_HH with 508. exact (proj1 (bo_chk_hh _ _ BC)).
      - rewrite mario_off_u. change FFW_HD with 520. exact (proj2 (bo_chk_hh _ _ BC)).
    Qed.

    (* ---- the level: gCurrLevelNum = LEVEL_WMOTR, by real code ---- *)
    Lemma in_wmotr11 : in_wmotr lp m11.
    Proof. exists bL. split; [ exact HbL | exact L_lvl ]. Qed.

    (* a symbol block none of the post-entry stores touch and outside the
       entry's footprint *)
    Ltac unt_tac Hs :=
      split; [ exact (symne lp _ _ _ _ Hs Hbm eq_refl) | ];
      split; [ exact (symne lp _ _ _ _ Hs Hbw eq_refl) | ];
      split; [ exact (symne lp _ _ _ _ Hs HbL eq_refl) | ];
      split; [ exact (inFb_sym_false _ _ _ Hs ltac:(vm_compute; reflexivity)) | ];
      split; [ let E := fresh "E" in intro E; exfalso; exact (symne lp _ _ _ _ Hs Hab eq_refl E) | ];
      split; [ exact (symne lp _ _ _ _ Hs HcC eq_refl) | ];
      let E := fresh "E" in intro E; exfalso; exact (symne lp _ _ _ _ Hs Hbc eq_refl E).

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
      rewrite (ld_back _ bsp 0 V0) by (unt_tac Hsp). exact (boot_spis bsp Hsp).
    Qed.

    (* ---- the controller cells (FfWorld.ctl_w, PollFlank): the boot
       image's static initializers (gPlayer1Controller = &gControllers[0],
       gPlayer3Controller = &gControllers[2], gCurrDemoInput = NULL), the
       .bss pads, and init_controllers' controllerData store (ZC) ---- *)
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

    Lemma dm_ctl : (prog_defmap game_init.prog) ! mario._gControllers
                   = Some (Gvar game_init.v_gControllers).
    Proof. reflexivity. Qed.

    Lemma ctl11 : ctl_w (lp_ge lp) m11.
    Proof.
      intros bc' bp Sc Sp.
      rewrite Hbc in Sc. injection Sc as <-.
      rewrite Hpads in Sp. injection Sp as <-.
      assert (Vc : Mem.valid_block m0 bc) by exact (Genv.find_symbol_not_fresh _ _ Hinit Hbc).
      assert (Uc : forall ch z, z + size_chunk ch <= 24 \/ 28 <= z -> untouched ch bc z).
      { intros ch z Hz.
        split; [ exact bc_bm | ].
        split; [ exact (symne lp _ _ _ _ Hbc Hbw eq_refl) | ].
        split; [ exact (symne lp _ _ _ _ Hbc HbL eq_refl) | ].
        split; [ exact (inFb_sym_false _ _ _ Hbc ltac:(vm_compute; reflexivity)) | ].
        split; [ intro E; exfalso; exact (bc_ab E) | ].
        split; [ exact (symne lp _ _ _ _ Hbc HcC eq_refl) | ].
        intros _; exact Hz. }
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
          change (28 * 0 + 24) with 24.
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
       NOT_WARPING (init_mario_after_warp's last store, run by the real
       entry); the demo and credits pointers and the delayed-warp op keep
       their boot zeros ---- *)
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
      rewrite (ld_back _ bsp 0 V0) by (unt_tac Hsp). exact (boot_cdi bsp Hsp).
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
      rewrite (ld_back _ bsp 0 V0) by (unt_tac Hsp). exact (boot_cce bsp Hsp).
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
      rewrite (ld_back _ bsp 0 V0) by (unt_tac Hsp). exact (boot_dwo bsp Hsp).
    Qed.

    Lemma warp11 : warp_w (lp_ge lp) m11.
    Proof.
      split; [ | split; [ exact L_cdi | split; [ exact L_cce | ] ] ].
      - intros bp bw' _ Hw _. rewrite Hbw in Hw. injection Hw as <-. exact L_wtype.
      - split.
        + intros bo' bs' Ho _ Hn. exfalso. exact (Hn (L_dwo bo' Ho)).
        + intros bo' Ho n Hn. rewrite (L_dwo bo' Ho) in Hn. injection Hn as <-.
          split; intro E; vm_compute in E; discriminate E.
    Qed.

    Lemma area11 : area_w (lp_ge lp) m11.
    Proof.
      intros ga Sa. rewrite Hca in Sa. injection Sa as <-.
      exists bgad, (Ptrofs.repr 60). split; [ exact Hgad | exact L_ca ].
    Qed.

    (* ---- the cutscene cells (FfWorld.cam_w, 2026-11-01): the witness's
       real Camera (gAreaData[1].camera, built by the real LOAD_AREA's
       create_camera's c->cutscene = 0) and sObjectCutscene's boot 0, read
       off m11 by StartTerrain.cut_chk (inside cam_frame_ok); the Camera is
       the main pool's block, past the globals and not the animation
       buffer ---- *)
    (* the root rebuild (2026-11-02): the camera pins, R3, the audio state,
       the surface counters and gTimeStopState, read off m11 by
       StartTerrain.pin_chk (inside cut_chk) *)
    Lemma pin11 : exists cb co, camv = Vptr cb co
      /\ (forall b, Genv.find_symbol (lp_ge lp) camera._gCamera = Some b ->
           forall bb oo, Mem.load Mint32 m11 b 0 = Some (Vptr bb oo) -> bb = cb /\ oo = co)
      /\ (forall x b, In x [camera._sMarioCamState; camera._sLuigiCamState] ->
           Genv.find_symbol (lp_ge lp) x = Some b ->
           forall bb oo, Mem.load Mint32 m11 b 0 = Some (Vptr bb oo) ->
             Genv.find_symbol (lp_ge lp) camera._gPlayerCameraState = Some bb)
      /\ (forall b, Genv.find_symbol (lp_ge lp) camera._gSecondCameraFocus = Some b ->
           forall bb oo, Mem.load Mint32 m11 b 0 <> Some (Vptr bb oo))
      /\ Ptrofs.unsigned co + CAM_SZ <= Ptrofs.max_unsigned
      /\ (forall id n bs bp op, In (id, n) cam_pools -> Genv.find_symbol (lp_ge lp) id = Some bs ->
            Mem.load Mint32 m11 bs 0 = Some (Vptr bp op) ->
            bp <> cb \/ Ptrofs.unsigned op + n <= Ptrofs.unsigned co
            \/ Ptrofs.unsigned co + CAM_SZ <= Ptrofs.unsigned op)
      /\ cam_si (lp_ge lp) m11 cb co
      /\ AudioInv.AudioInv (lp_ge lp) m11
      /\ ObjWorld.ctr_ok (lp_ge lp) m11
      /\ (forall b, Genv.find_symbol (lp_ge lp) object_list_processor._gTimeStopState = Some b ->
            Mem.load Mint32 m11 b 0 = Some (Vint Int.zero)).
    Proof.
      pose proof (cam_frame_ok_cut _ _ _ _ CF) as CCut.
      destruct (cut_chk_sound _ _ _ CCut) as (cb & co & Ec & _).
      pose proof (cut_chk_pin _ _ _ CCut) as PC. rewrite Ec in PC.
      exists cb, co. exact (conj Ec (pin_chk_sound _ _ _ _ PC)).
    Qed.

    Lemma aud11 : aud_w (lp_ge lp) m11.
    Proof.
      destruct pin11 as (cb & co & _ & _ & _ & _ & _ & _ & _ & AI & _).
      exact (proj2 (AudioInv.aud_w_eq _ _) AI).
    Qed.

    (* exported for the objects phase's carried ctr_ok (ObjWorld) and the
       camera's time-stop cell *)
    Lemma ctr11 : ObjWorld.ctr_ok (lp_ge lp) m11.
    Proof. destruct pin11 as (cb & co & _ & _ & _ & _ & _ & _ & _ & _ & C & _). exact C. Qed.

    Lemma ts11 : forall b, Genv.find_symbol (lp_ge lp) object_list_processor._gTimeStopState = Some b ->
        Mem.load Mint32 m11 b 0 = Some (Vint Int.zero).
    Proof. destruct pin11 as (cb & co & _ & _ & _ & _ & _ & _ & _ & _ & _ & T). exact T. Qed.

    Lemma cam11 : cam_w (lp_ge lp) m11.
    Proof.
      destruct (cut_chk_sound _ _ _ (cam_frame_ok_cut _ _ _ _ CF)) as (cb & co & Ec & C1 & Pg & Ab & C2).
      destruct pin11 as (cb' & co' & Ec' & Pgc & Pms & Psf & Psz & Ppool & Psi & _).
      rewrite Ec in Ec'. injection Ec' as <- <-.
      pose proof (cam_frame_ok_load _ _ _ _ CF) as L96. rewrite Ec in L96.
      split; [ exact C1 | split ].
      - intros ga bad o Sg Lg. rewrite Hca in Sg. injection Sg as <-.
        rewrite L_ca in Lg. injection Lg as <- <-.
        exists cb, co. change (Ptrofs.unsigned (Ptrofs.add (Ptrofs.repr 60) (Ptrofs.repr 36))) with 96. split; [ exact L96 | ].
        split; [ exact Pg | ]. split; [ exact Ab | ]. split; [ exact C2 | ].
        split; [ exact Psz | split; [ exact Ppool | exact Psi ] ].
      - split; [ | split; [ exact Pms | exact Psf ] ].
        intros b Hb bb oo L. destruct (Pgc b Hb bb oo L) as (-> & ->).
        exists bca, bgad, (Ptrofs.repr 60). split; [ exact Hca | split; [ exact L_ca | ] ].
        change (Ptrofs.unsigned (Ptrofs.add (Ptrofs.repr 60) (Ptrofs.repr 36))) with 96. exact L96.
    Qed.

    (* ---- gEnvironmentRegions (FfWorld.env_w, 2026-10-26): the real
       load_area_terrain (run by the real LOAD_AREA) stores NULL into it
       (surface_load.c), over the boot image's .bss zero, and WMotR's
       collision has no TERRAIN_LOAD_ENVIRONMENT block, so no table is
       loaded: the footprint check old_ok sees the same bytes (it is not an
       f_ids global) ---- *)
    Lemma dm_env : (prog_defmap object_list_processor.prog) ! object_list_processor._gEnvironmentRegions
                    = Some (Gvar object_list_processor.v_gEnvironmentRegions).
    Proof. vm_compute. reflexivity. Qed.

    Lemma L_env : forall b, Genv.find_symbol (lp_ge lp) object_list_processor._gEnvironmentRegions = Some b ->
        Mem.load Mint32 m11 b 0 = Some (Vint Int.zero).
    Proof.
      intros bsp Hsp.
      assert (V0 : Mem.valid_block m0 bsp) by exact (Genv.find_symbol_not_fresh _ _ Hinit Hsp).
      assert (RP : Mem.range_perm m0 bsp 0 4 Cur Writable)
        by exact (wr_sym _ _ _ bsp LO_olp dm_env eq_refl eq_refl ltac:(cbn; discriminate) Hsp).
      destruct (valid_ex Mint32 bsp 0 0 4 RP ltac:(lia) ltac:(cbn; lia) ltac:(apply Z.divide_0_r)) as (v & Hv).
      pose proof (boot_zero lp m0 object_list_processor._gEnvironmentRegions bsp _ _ _ H12 Hinit ltac:(unfold zero_ids; cbn [In]; auto 12) Hsp Hv) as Ez.
      rewrite (ld_back _ bsp 0 V0) by (unt_tac Hsp). rewrite Hv, Ez. reflexivity.
    Qed.

    (* ---- gShowDebugText (FfWorld.env_w): main.c's FALSE, the boot zero,
       which nothing in the witness chain stores ---- *)
    Lemma dm_dbg : (prog_defmap mario.prog) ! mario._gShowDebugText
                    = Some (Gvar mario.v_gShowDebugText).
    Proof. vm_compute. reflexivity. Qed.

    Lemma L_dbg : forall b, Genv.find_symbol (lp_ge lp) mario._gShowDebugText = Some b ->
        Mem.load Mint8signed m11 b 0 = Some (Vint Int.zero).
    Proof.
      intros bsp Hsp.
      assert (V0 : Mem.valid_block m0 bsp) by exact (Genv.find_symbol_not_fresh _ _ Hinit Hsp).
      assert (RP : Mem.range_perm m0 bsp 0 1 Cur Writable)
        by exact (wr_sym _ _ _ bsp (linked12_LO_mario lp H12) dm_dbg eq_refl eq_refl ltac:(cbn; discriminate) Hsp).
      destruct (valid_ex Mint8signed bsp 0 0 1 RP ltac:(lia) ltac:(cbn; lia) ltac:(apply Z.divide_0_r)) as (v & Hv).
      pose proof (boot_zero lp m0 mario._gShowDebugText bsp _ _ _ H12 Hinit ltac:(unfold zero_ids; cbn [In]; auto 12) Hsp Hv) as Ez.
      rewrite (ld_back _ bsp 0 V0) by (unt_tac Hsp). rewrite Hv, Ez. reflexivity.
    Qed.

    Lemma lvl11 : lvl_w (lp_ge lp) m11.
    Proof.
      split; [ | split; [ exact L_spis | split; [ exact warp11 | split; [ exact ctl11 | exact (conj area11 (conj (conj L_env L_dbg) (conj cam11 aud11))) ] ] ] ].
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
      rewrite (ld_back _ bsp 0 V0) by (unt_tac Hsp). exact (boot_gmp bsp Hsp).
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
      exists P0, bpl, P, Lm.
      split; [ exact AP | ].
      split; [ exists s1, s2, s3, s4, s5; tauto | ].
      split; [ intros Hv; exact (entry_sound _ _ _ (world_ok_of (lp_ge lp) Hv) EN) | ].
      exact ld_entry.
    Qed.

    Lemma objs11 : objects_runs lp m11.
    Proof.
      intros Hv. pose proof (BootRun.world_ok_of (lp_ge lp) Hv) as Wk.
      destruct (ex_done_sound _ _ _ _ Wk OO) as (t & m' & v & Ev).
      exists m', t, v. exact Ev.
    Qed.

    Lemma nsurf11 : nsurf_is lp m11.
    Proof.
      destruct (nsurf_ok_sound _ _ NS) as (n & Hl & Hn). exists bn, n. tauto.
    Qed.

    (* THE WHOLE FRAME (2026-11-02): HeightFrame.play_frame_step from the
       witness, every segment a real execution (frame_w) *)
    Lemma frame_whole_of : BootRun.world_ok (lp_ge lp) ->
      exists i ma fm3 fm4,
        (forall MWF Phi OW, HeightFrame.play_frame_step lp bm MWF Phi OW i m11 fm4)
        /\ ObjPhase.objects_call lp ma fm3
        /\ ObjWorld.obj_w (lp_ge lp) bm fm3 /\ ObjWorld.ctr_ok (lp_ge lp) fm3
        /\ ObjWorld.obj_w (lp_ge lp) bm fm4 /\ ObjWorld.ctr_ok (lp_ge lp) fm4.
    Proof.
      intros Wk.
      destruct (frame_w_sound _ _ _ Wk FW)
        as (fi1 & fi & fm0 & fle & fma & fm3 & fm4 & (ta & va & Ea) & (ts & vs & Es) & (tr & vr & Er)
            & Hpm & (tp & op & Ep) & (to & vo & Eo) & O3 & C3 & (tq & leq & oq & Eq) & Hps & Hw & O4 & C4).
      assert (Rest : forall MWF Phi OW, HeightFrame.seg_rest_spec lp bm MWF Phi OW fm4 fm4).
      { intros MWF Phi OW. unfold HeightFrame.seg_rest_spec.
        split; [ reflexivity | split; [ left; reflexivity | split; [ tauto | split ] ] ].
        - split; tauto.
        - split; [ exact (plat_still_b_sound lp fm4 Hps) | tauto ]. }
      exists fi, fma, fm3, fm4.
      split; [ | split; [ exists to, vo; exact Eo | ] ].
      - intros MWF Phi OW.
        exists fm0, fma, fm3, fm4, fm4, fm4.
        split; [ | split; [ | split; [ | split; [ | split; [ | split; [ | split ] ] ] ] ] ].
        + split; [ | exists tr, vr; exact Er ].
          exists m11. split; [ left; reflexivity | ].
          exists fi1. split; [ exists ta, va; exact Ea | exists ts, vs; exact Es ].
        + split; [ exact (pm_b_sound _ _ Hpm) | exists tp, fle, op; exact Ep ].
        + exists to, vo; exact Eo.
        + exists fle, tq, leq, oq; exact Eq.
        + exact (Rest MWF Phi OW).
        + left; reflexivity.
        + exact (Rest MWF Phi OW).
        + exact (in_wmotr_b_sound lp fm4 Hw).
      - assert (M3 : MaxPerm.MP m11 fm3).
        { eapply MaxPerm.MP_trans; [ exact (MaxPerm.funcall_maxperm _ _ _ _ _ _ _ Ea) | ].
          eapply MaxPerm.MP_trans; [ exact (MaxPerm.funcall_maxperm _ _ _ _ _ _ _ Es) | ].
          eapply MaxPerm.MP_trans; [ exact (MaxPerm.funcall_maxperm _ _ _ _ _ _ _ Er) | ].
          eapply MaxPerm.MP_trans; [ exact (MaxPerm.stmt_maxperm _ _ _ _ _ _ _ _ _ Ep) | ].
          exact (MaxPerm.funcall_maxperm _ _ _ _ _ _ _ Eo). }
        assert (M4 : MaxPerm.MP m11 fm4)
          by exact (MaxPerm.MP_trans _ _ _ M3 (MaxPerm.stmt_maxperm _ _ _ _ _ _ _ _ _ Eq)).
        split; [ exact (ObjWorld.ow_chk_sound _ _ _ (part_cells_of _ M3) O3) | split; [ exact (ObjWorld.ctr_b_sound _ _ C3) | ] ].
        split; [ exact (ObjWorld.ow_chk_sound _ _ _ (part_cells_of _ M4) O4) | exact (ObjWorld.ctr_b_sound _ _ C4) ].
    Qed.

    Theorem witness11 :
      SafeB_syms_ok lp SBw
      /\ mem_ok_lp bm (MWF_real lp bm bc Ptrofs.zero SBw) m11
      /\ PhiW lp bm m11 /\ PlatformKeep.plat_still lp m11
      /\ read_cells bm m11 (entry_cells ENTRY_FH)
      /\ in_wmotr lp m11
      /\ floor_data (lp_ge lp) m11 /\ static_agree (lp_ge lp) m11 /\ nsurf_is lp m11
      /\ ObjWorld.obj_w (lp_ge lp) bm m11 /\ objects_runs lp m11
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
        split; [ exact (ObjWorld.ow_chk_sound _ _ _ (part_cells_of _ (MaxPerm.MP_refl _)) OWc) | split; [ exact objs11 | ] ].
        destruct entry_runs as (R1 & R2).
        exists bL, e5, e6, (PTree.set level_update._t'2 (Vint (Int.repr LEVEL_WMOTR)) (PTree.empty val)). split; [ exact HbL | split; [ exact R1 | split; [ exact (R2 _) | ] ] ].
        split; [ rewrite L_lvl, (Mem.load_store_same _ _ _ _ _ _ E6); reflexivity | ].
        split; [ exact loaded11 | ].
        split; [ | split ].
        + intros Hv. pose proof (BootRun.world_ok_of (lp_ge lp) Hv) as Wk.
          destruct (frame_ok_sound _ _ _ _ Wk FO) as (Ha & t & m' & v & Ev & Hl).
          destruct (cam_frame_ok_sound _ _ _ _ Wk CF) as (Lc & tu & mu & vu & Eu & Ec).
          split; [ split; [ exact Ha | split; [ exists bo, (Ptrofs.repr MARIO_OFF), t, m', v; split; [ exact Ev | exact Hl ] | ] ] | ].
          { exists bgad, camv, mu. split; [ exact Hgad | split; [ exact Lc | split; [ exists tu, vu; exact Eu | exact Ec ] ] ]. }
          exact (frame_whole_of Wk).
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
          { rewrite (Mem.load_store_other _ _ _ _ _ _ ZC) by (left; exact (symne lp _ _ _ _ HcC Hbc eq_refl)).
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
      /\ read_cells bm m (entry_cells ENTRY_FH)
      /\ in_wmotr lp m
      /\ floor_data (lp_ge lp) m /\ static_agree (lp_ge lp) m /\ nsurf_is lp m
      /\ ObjWorld.obj_w (lp_ge lp) bm m /\ objects_runs lp m
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
    (* the whole chain, computed once over every linked12 link (StartTerrain) *)
    destruct (wchk_sound _ _ (wchk_lp lp H12 m0 Hinit) bm bc ab bo bw bL Hbm Hbc Hab Hbo Hbw HbL)
      as [s1 s2 s3 s4 s5 bn e1 e2 e3 e4 e5 e6 P0 bpl P Lm m1 bt m3 bd
          z9 z10a z10 z10b z11 z12 z13 z14 z15 z16 z17 m11
          bsi bpcs bbs bhud bC bga bpads bca bgad camv
          E1 E2 E3 E4 E5 E6 AP PW Hs1 Hs2 Hs3 Hs4 Hs5 EN A1 A4 Z9 Z10a Z10 Z10b
          Z11 Z12 Z13 Z14 Z15 Z16 Z17 ZC Hsi Hpcs Hbbs Hhud HcC Hga Hpads Hca Hgad Hbn
          OK FR CL CW WP PO NS IF FO TC GC OWc BC OO LC CF DPc FW].
    exists (SBw bpl bt bd), m11.
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
    (* Mario's height cells are the real entry's: floorHeight is
       find_floor's hit under the spawn (StartTerrain.ENTRY_FH) *)
    /\ read_cells bm m (entry_cells ENTRY_FH)
    (* the game is in WMotR, and that cell is what the real entry code
       stored: initiate_warp(LEVEL_WMOTR, 1, 0x0A, 0) from the boot image,
       then warp_level's gCurrLevelNum = sWarpDest.levelNum *)
    /\ in_wmotr lp m
    (* WMotR's REAL terrain is loaded: GOAL 2's floor premise (TRUST 0.8)
       and the decoder agreement hold on m, with 1352 surfaces allocated *)
    /\ floor_data (lp_ge lp) m /\ static_agree (lp_ge lp) m /\ nsurf_is lp m
    (* the object world holds on m (ObjWorld.obj_w: the lists clear_objects
       and Mario's spawn built), and the memory is not a dead end for the
       objects phase: one real area_update_objects runs from it
       (2026-10-26) *)
    /\ ObjWorld.obj_w (lp_ge lp) bm m /\ objects_runs lp m
    /\ exists m_boot bL m_iw m_ent le',
         Genv.init_mem lp = Some m_boot
         /\ Genv.find_symbol (lp_ge lp) level_update._gCurrLevelNum = Some bL
         /\ eval_funcall function_entry2 (lp_ge lp) m_boot
              (Internal level_update.f_initiate_warp) iw_args E0 m_iw Vundef
         /\ exec_stmt function_entry2 (lp_ge lp) empty_env (PTree.empty val) m_iw
              warp_level_head E0 le' m_ent Out_normal
         /\ Mem.load Mint16signed m bL 0 = Mem.load Mint16signed m_ent bL 0
         (* ... and m is what THE REAL ENTRY leaves (the level script's
            commands through the real handlers, init_level, warp_level,
            init_mario_after_warp: StartTerrain.entry_g) from the entry
            memory, but for the stand-in cells (StartTerrain's header) *)
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
    as (SafeB & m & Hs & Hok & Hphi & Hpl & Hrc & Hw & Hfd & Hsa & Hns & How & Hor
        & (bL & m_iw & m_ent & le' & HbL & Hiw & Hwl & Hld & Htl & Hfr & Hif & Hcs)).
  exists m, bm, bc, SafeB.
  refine (conj Hbm (conj Hbc (conj Hs (conj Hok (conj Hphi (conj Hpl (conj Hrc (conj Hw
            (conj Hfd (conj Hsa (conj Hns (conj How (conj Hor _))))))))))))).
  exists m0, bL, m_iw, m_ent, le'.
  exact (conj Hinit (conj HbL (conj Hiw (conj Hwl (conj Hld (conj Htl (conj Hfr (conj Hif Hcs)))))))).
Qed.
