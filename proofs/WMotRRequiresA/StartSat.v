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
(* ====================================================================== *)

From Coq Require Import ZArith List Lia Reals Lra.
From Flocq Require Import Binary.
From compcert Require Import Coqlib Maps AST Integers Floats Values Memory
  Globalenvs Ctypes Clight Linking.
From SM64.Generated Require mario level_update interaction mario_actions_moving
  surface_collision memory game_init object_list_processor.
From SM64.Proofs Require Import RealFrameLinked ActionValueFrame Taint CensusV2 MWFReal SpawnInit
  LinkedTwelve InitMemSat BootMWF NoAImpliesNoFlyLinked ClosedMem.
From SM64.Proofs.WMotRRequiresA Require Import HeightInvariant NoAActions WMotRWorld
  FloorList FloorHeight FloorExec AirMatch FfWorld FrameSplit HeightFrame WMotREntry.
Import ListNotations.

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

(* the global ids whose every TU initializer is all .bss (or absent) *)
Definition zero_ids : list ident :=
  [ level_update._gMarioStates; object_list_processor._gObjectPool;
    surface_collision._gStaticSurfacePartition;
    surface_collision._gDynamicSurfacePartition ].

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
    Variables ab bo bfi bmiss bcalls bsin biom bmq brm : block.
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

    Variables (m1 m2 m3 m3a m3b m4 m5 m6 m7 m8 m9 m10 m11 : mem) (bt bs bar : block).
    Hypothesis A1 : Mem.alloc m0 0 24 = (m1, bt).
    Hypothesis A2 : Mem.alloc m1 0 48 = (m2, bs).
    Hypothesis A3 : Mem.alloc m2 0 60 = (m3, bar).
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
    Hypothesis S8 : Mem.store Mint32 m10 ab 8 (Vptr bt Ptrofs.zero) = Some m11.

    (* ---- blocks ---- *)
    Lemma bt_eq : bt = Mem.nextblock m0.
    Proof. exact (Mem.alloc_result _ _ _ _ _ A1). Qed.
    Lemma bs_eq : bs = Pos.succ (Mem.nextblock m0).
    Proof. rewrite (Mem.alloc_result _ _ _ _ _ A2), (Mem.nextblock_alloc _ _ _ _ _ A1). reflexivity. Qed.
    Lemma bar_eq : bar = Pos.succ (Pos.succ (Mem.nextblock m0)).
    Proof.
      rewrite (Mem.alloc_result _ _ _ _ _ A3), (Mem.nextblock_alloc _ _ _ _ _ A2),
        (Mem.nextblock_alloc _ _ _ _ _ A1). reflexivity.
    Qed.
    Lemma nb3 : Mem.nextblock m3 = Pos.succ (Pos.succ (Pos.succ (Mem.nextblock m0))).
    Proof.
      rewrite (Mem.nextblock_alloc _ _ _ _ _ A3), (Mem.nextblock_alloc _ _ _ _ _ A2),
        (Mem.nextblock_alloc _ _ _ _ _ A1). reflexivity.
    Qed.
    Lemma nb11 : Mem.nextblock m11 = Mem.nextblock m3.
    Proof.
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
        unfold Ple; lia.
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
    Lemma sym_ne_fresh : forall id b b', Genv.find_symbol (lp_ge lp) id = Some b ->
        b' = bt \/ b' = bs \/ b' = bar -> b <> b'.
    Proof. intros id b b' H F. exact (fresh_not_sym id b b' H (fresh_ge b' F)). Qed.
    Lemma old_lt : forall b, Plt b (Mem.nextblock m0) -> Plt b (Mem.nextblock m11).
    Proof. intros b H. rewrite nb11, nb3. unfold Plt in *. lia. Qed.
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
    Lemma valid_0_3 : forall b, Mem.valid_block m0 b -> Mem.valid_block m3 b.
    Proof.
      intros b H. eapply Mem.valid_block_alloc; [ exact A3 | ].
      eapply Mem.valid_block_alloc; [ exact A2 | ].
      eapply Mem.valid_block_alloc; [ exact A1 | exact H ].
    Qed.
    Lemma ld_3 : forall ch b z, Mem.valid_block m0 b -> Mem.load ch m3 b z = Mem.load ch m0 b z.
    Proof.
      intros ch b z H.
      assert (V1 : Mem.valid_block m1 b) by (eapply Mem.valid_block_alloc; [ exact A1 | exact H ]).
      assert (V2 : Mem.valid_block m2 b) by (eapply Mem.valid_block_alloc; [ exact A2 | exact V1 ]).
      rewrite (Mem.load_alloc_unchanged _ _ _ _ _ A3 _ _ _ V2),
        (Mem.load_alloc_unchanged _ _ _ _ _ A2 _ _ _ V1),
        (Mem.load_alloc_unchanged _ _ _ _ _ A1 _ _ _ H). reflexivity.
    Qed.

    Definition cells_bm : list Z := [12; 104; 144; 156; 160; 136; 64].
    Definition untouched (ch : memory_chunk) (b : block) (z : Z) : Prop :=
      b <> bs
      /\ (b = bm -> forall d, In d cells_bm -> z + size_chunk ch <= d \/ d + 4 <= z)
      /\ (b = ab -> z + size_chunk ch <= 8 \/ 12 <= z)
      /\ (b = bo -> z + size_chunk ch <= 36 \/ 40 <= z).

    Lemma ld_back : forall ch b z, Mem.valid_block m0 b -> untouched ch b z ->
        Mem.load ch m11 b z = Mem.load ch m0 b z.
    Proof.
      intros ch b z Hv U.
      destruct U as (Nbs & Ubm & Uab & Ubo).
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
      exact (ld_3 ch b z Hv).
    Qed.

    (* ---- MWF_real, store by store ---- *)
    Definition SBw : block -> Prop :=
      SafeB_wit lp (fun b => b = bt \/ b = bar) (fun id => mem_id id non_safeb_syms = false).

    Lemma Sy_w : SafeB_syms_ok lp SBw.
    Proof.
      apply safeb_wit_sat_le;
        [ intros b Hb; rewrite genv_next_eq; apply fresh_ge; tauto
        | intros id H; exact H | exact gobj_not_nonsafe ].
    Qed.

    Lemma Hsp : spawn_ok lp m0 bm bc Ptrofs.zero.
    Proof. split; [ exact Hinit | split; [ exact Hbm | split; [ exact Hbc | reflexivity ] ] ]. Qed.

    Lemma mwf_m3 : MWF_real lp bm bc Ptrofs.zero (SafeB_boot lp) m3.
    Proof.
      pose proof (SafeB_boot_syms_ok lp) as Sy.
      pose proof (linked12_LO_mario lp H12) as LOm.
      pose proof (spawn_Hbc_bm lp m0 bm bc Ptrofs.zero Hsp) as D1.
      pose proof (safeb_not_bm lp m0 bm bc Ptrofs.zero _ Hsp Sy) as D2.
      pose proof (safeb_not_bc lp m0 bm bc Ptrofs.zero _ Hsp Sy) as D2'.
      pose proof (gms_blk lp m0 bm bc Ptrofs.zero _ Hsp Sy) as D3.
      pose proof (gtimer_blk lp m0 bm bc Ptrofs.zero _ Hsp Sy) as D4.
      pose proof (table_blk lp m0 bm bc Ptrofs.zero _ Hsp Sy) as D5.
      pose proof (ktab_blk lp m0 bm bc Ptrofs.zero _ Hsp Sy) as D6.
      pose proof (glob_blk lp m0 bm bc Ptrofs.zero _ Hsp Sy) as D7.
      pose proof (boot_mwf lp H12 m0 Hinit bm bc Hbm Hbc) as M0.
      eapply (mwf_real_alloc lp); try eassumption.
      eapply (mwf_real_alloc lp); try eassumption.
      eapply (mwf_real_alloc lp); try eassumption.
    Qed.

    Lemma bt_valid3 : Mem.valid_block m3 bt.
    Proof.
      eapply Mem.valid_block_alloc; [ exact A3 | ].
      eapply Mem.valid_block_alloc; [ exact A2 | ].
      exact (Mem.valid_new_block _ _ _ _ _ A1).
    Qed.

    Lemma bar_valid3 : Mem.valid_block m3 bar.
    Proof. exact (Mem.valid_new_block _ _ _ _ _ A3). Qed.

    Lemma bar_noptr3 : forall ofs b' o', Mem.loadv Mptr m3 (Vptr bar ofs) = Some (Vptr b' o') -> False.
    Proof.
      intros ofs b' o' Hld. cbn [Mem.loadv] in Hld.
      pose proof (Mem.load_alloc_same _ _ _ _ _ A3 _ _ _ Hld). discriminate.
    Qed.

    Lemma bt_noptr3 : forall ofs b' o', Mem.loadv Mptr m3 (Vptr bt ofs) = Some (Vptr b' o') -> False.
    Proof.
      intros ofs b' o' Hld. cbn [Mem.loadv] in Hld.
      assert (V1 : Mem.valid_block m1 bt) by exact (Mem.valid_new_block _ _ _ _ _ A1).
      assert (V2 : Mem.valid_block m2 bt) by (eapply Mem.valid_block_alloc; [ exact A2 | exact V1 ]).
      rewrite (Mem.load_alloc_unchanged _ _ _ _ _ A3 _ _ _ V2),
        (Mem.load_alloc_unchanged _ _ _ _ _ A2 _ _ _ V1) in Hld.
      pose proof (Mem.load_alloc_same _ _ _ _ _ A1 _ _ _ Hld). discriminate.
    Qed.

    Lemma mwf_w3 : MWF_real lp bm bc Ptrofs.zero SBw m3.
    Proof.
      apply (mwf_real_widen lp bm bc Ptrofs.zero (SafeB_boot lp) SBw (fun b => b = bt \/ b = bar) m3 mwf_m3).
      - intros b [E | H]; [ right; exact E | left; right; exact H ].
      - intros b [[] | H]. right. exact H.
      - intros b [-> | ->]; [ exact bt_valid3 | exact bar_valid3 ].
      - intros b ofs b' o' [-> | ->] Hld; [ exact (bt_noptr3 _ _ _ Hld) | exact (bar_noptr3 _ _ _ Hld) ].
      - intros ab' Hab'. exact (safeb_of_nonfam_sym lp SBw Sy_w _ _ Hab' eq_refl).
    Qed.

    Lemma bs_not_sbw : ~ SBw bs.
    Proof.
      intros [[E | E] | (id & _ & Hfs)]; [ exact (bt_bs (eq_sym E)) | exact (bs_bar E) | ].
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
      apply ld_3. exact (Genv.find_symbol_not_fresh _ _ Hinit Hab).
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
        intros bb oo E. injection E as <- _. left. right. reflexivity. }
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
      eapply (mwf_real_buf_store lp) with (mm := m10) (mm' := m11) (ab := ab); try eassumption.
      - intros b o E. injection E as <- _. left. left. reflexivity.
      - intros b o mb mo E Hl. injection E as <- _.
        change (Mem.load Mint32 m10 bm 136 = Some (Vptr mb mo)) in Hl.
        rewrite mobj_m10 in Hl. injection Hl as <- _. exact bt_bo.
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
      split; [ intros E; exfalso; exact (ab_bm (eq_sym E)) | intros E; exfalso; exact (bo_bm (eq_sym E)) ].
    Qed.
    Lemma bs_bo : bs <> bo.
    Proof. intro E. exact (sym_ne_fresh _ _ _ Hbo (or_intror (or_introl eq_refl)) (eq_sym E)). Qed.
    (* Mario's object, off gfx.pos[1] (offset 36) *)
    Lemma unt_bo : forall ch z, z + size_chunk ch <= 36 \/ 40 <= z -> untouched ch bo z.
    Proof.
      intros ch z Hz. split; [ intro E; exact (bs_bo (eq_sym E)) | ].
      split; [ intros E; exfalso; exact (bo_bm E) | ].
      split; [ intros E; exfalso; exact (bo_ab E) | intros _; exact Hz ].
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
    Lemma z_part : forall id bp ch z v, In id part_ids -> Genv.find_symbol (lp_ge lp) id = Some bp ->
        Mem.load ch m11 bp z = Some v -> v = zeros ch.
    Proof.
      intros id bp ch z v Hid Hfs Hl.
      assert (U : untouched ch bp z).
      { split; [ intro E; subst bp; exact (sym_ne_fresh _ _ _ Hfs (or_intror (or_introl eq_refl)) eq_refl) | ].
        split; [ | split ]; intros E; exfalso; subst bp;
          destruct Hid as [<- | [<- | []]];
          first [ exact (symne lp _ _ _ _ Hfs Hbm eq_refl eq_refl)
                | exact (symne lp _ _ _ _ Hfs Hab eq_refl eq_refl)
                | exact (symne lp _ _ _ _ Hfs Hbo eq_refl eq_refl) ]. }
      rewrite (ld_back ch bp z (Genv.find_symbol_not_fresh _ _ Hinit Hfs) U) in Hl.
      assert (Hz : In id zero_ids) by (destruct Hid as [<- | [<- | []]]; cbn; tauto).
      exact (boot_zero lp m0 _ bp ch z v H12 Hinit Hz Hfs Hl).
    Qed.
    Lemma part_zero : forall hd, part_head (lp_ge lp) m11 hd -> hd = Vint Int.zero.
    Proof.
      intros hd (id & bp & o & Hid & Hfs & Hl). cbn [Mem.loadv] in Hl.
      rewrite (z_part _ _ _ _ _ Hid Hfs Hl). reflexivity.
    Qed.

    Ltac peel S := rewrite (Mem.load_store_other _ _ _ _ _ _ S)
      by (first [ left; congruence | right; cbn [size_chunk]; lia ]).

    Lemma L_act : Mem.load Mint32 m11 bm 12 = Some (Vint ACT_SPAWN_NO_SPIN_AIRBORNE).
    Proof.
      pose proof ab_bm. peel S8; peel S7; peel S6; peel S5; peel S4; peel S3.
      rewrite (Mem.load_store_same _ _ _ _ _ _ S2). reflexivity.
    Qed.
    Lemma L_floor : Mem.load Mint32 m11 bm 104 = Some (Vptr bs Ptrofs.zero).
    Proof.
      pose proof ab_bm. peel S8; peel S7; peel S6; peel S5; peel S4.
      rewrite (Mem.load_store_same _ _ _ _ _ _ S3). reflexivity.
    Qed.
    Lemma L_area : Mem.load Mint32 m11 bm 144 = Some (Vptr bar Ptrofs.zero).
    Proof.
      pose proof ab_bm. peel S8; peel S7; peel S6; peel S5.
      rewrite (Mem.load_store_same _ _ _ _ _ _ S4). reflexivity.
    Qed.
    Lemma L_ctl : Mem.load Mint32 m11 bm 156 = Some (Vptr bc Ptrofs.zero).
    Proof.
      pose proof ab_bm. peel S8; peel S7; peel S6.
      rewrite (Mem.load_store_same _ _ _ _ _ _ S5). reflexivity.
    Qed.
    Lemma L_anim : Mem.load Mint32 m11 bm 160 = Some (Vptr ab Ptrofs.zero).
    Proof.
      pose proof ab_bm. peel S8; peel S7.
      rewrite (Mem.load_store_same _ _ _ _ _ _ S6). reflexivity.
    Qed.
    Lemma L_obj : Mem.load Mint32 m11 bm 136 = Some (Vptr bo Ptrofs.zero).
    Proof.
      pose proof ab_bm. peel S8.
      rewrite (Mem.load_store_same _ _ _ _ _ _ S7). reflexivity.
    Qed.
    Lemma L_buf : Mem.load Mint32 m11 ab 8 = Some (Vptr bt Ptrofs.zero).
    Proof. rewrite (Mem.load_store_same _ _ _ _ _ _ S8). reflexivity. Qed.
    Lemma L_styp : Mem.load Mint16signed m11 bs 0 = Some (Vint Int.zero).
    Proof.
      pose proof bs_ab. pose proof bs_bm.
      peel S8; peel S7; peel S6; peel S5; peel S4; peel S3; peel S2.
      rewrite (Mem.load_store_same _ _ _ _ _ _ S1). reflexivity.
    Qed.
    Lemma L_posy : Mem.load Mfloat32 m11 bm 64 = Some (Vsingle ENTRY_Y).
    Proof.
      pose proof ab_bm. pose proof bs_bm. pose proof bo_bm.
      peel S8; peel S7; peel S6; peel S5; peel S4; peel S3; peel S2; peel S1; peel S1b.
      rewrite (Mem.load_store_same _ _ _ _ _ _ S1a). reflexivity.
    Qed.
    Lemma L_gfx : Mem.load Mfloat32 m11 bo 36 = Some (Vsingle ENTRY_Y).
    Proof.
      pose proof bo_ab. pose proof bs_bo. pose proof bo_bm.
      peel S8; peel S7; peel S6; peel S5; peel S4; peel S3; peel S2; peel S1.
      rewrite (Mem.load_store_same _ _ _ _ _ _ S1b). reflexivity.
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
    Lemma world : wmotr_world bm m11.
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
      assert (T : thr = Pos.succ (Pos.succ (Pos.succ (Mem.nextblock m0))))
        by (unfold thr; rewrite nb11, nb3; reflexivity).
      assert (P0 : Ple (Mem.nextblock m0) thr) by (rewrite T; unfold Ple; lia).
      pose proof (boot_neutral lp m0 thr Hinit P0) as N0.
      pose proof (Mem.alloc_inject_neutral _ _ _ _ _ _ A1 N0 ltac:(rewrite T; unfold Plt; lia)) as N1.
      pose proof (Mem.alloc_inject_neutral _ _ _ _ _ _ A2 N1
                    ltac:(rewrite T, (Mem.nextblock_alloc _ _ _ _ _ A1); unfold Plt; lia)) as N2.
      pose proof (Mem.alloc_inject_neutral _ _ _ _ _ _ A3 N2
                    ltac:(rewrite T, (Mem.nextblock_alloc _ _ _ _ _ A2),
                            (Mem.nextblock_alloc _ _ _ _ _ A1); unfold Plt; lia)) as N3.
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
      exact (Mem.store_inject_neutral _ _ _ _ _ _ _ S8 N10 Lab (vinj_ptr _ _ Lbt)).
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

    Lemma pfwd : forall b z k p, Mem.perm m0 b z k p -> Mem.perm m11 b z k p.
    Proof.
      intros b z k p H.
      eapply Mem.perm_store_1; [ exact S8 | ]. eapply Mem.perm_store_1; [ exact S7 | ].
      eapply Mem.perm_store_1; [ exact S6 | ]. eapply Mem.perm_store_1; [ exact S5 | ].
      eapply Mem.perm_store_1; [ exact S4 | ]. eapply Mem.perm_store_1; [ exact S3 | ].
      eapply Mem.perm_store_1; [ exact S2 | ]. eapply Mem.perm_store_1; [ exact S1 | ].
      eapply Mem.perm_store_1; [ exact S1b | ]. eapply Mem.perm_store_1; [ exact S1a | ].
      eapply Mem.perm_alloc_1; [ exact A3 | ]. eapply Mem.perm_alloc_1; [ exact A2 | ].
      eapply Mem.perm_alloc_1; [ exact A1 | exact H ].
    Qed.

    Ltac neq :=
      first [ exact bt_bs | exact bt_bar | exact bs_bar
            | apply not_eq_sym; first [ exact bt_bs | exact bt_bar | exact bs_bar ]
            | eapply symne; [ eassumption | eassumption | reflexivity ]
            | eapply sym_ne_fresh; [ eassumption
                                   | first [ left; reflexivity | right; left; reflexivity
                                           | right; right; reflexivity ] ]
            | apply not_eq_sym; eapply sym_ne_fresh;
              [ eassumption
              | first [ left; reflexivity | right; left; reflexivity | right; right; reflexivity ] ] ].

    Ltac norl := let o := fresh "o" in let Hin := fresh "Hin" in
      intros (o & Hin); cbn [ff_rl map In] in Hin;
      repeat (destruct Hin as [Hin | Hin];
              [ injection Hin as Hin; revert Hin; neq | ]);
      destruct Hin.

    Definition RL : list (option val) := ff_rl bm bo Ptrofs.zero bfi bmiss bcalls ab bt biom bmq brm.

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
      split; [ intros hd Hp; rewrite (part_zero _ Hp); constructor | ].
      split; [ intros hd s Hp Ho; rewrite (part_zero _ Hp) in Ho; inv Ho | ].
      split; [ intros hd b o Hp Ho; rewrite (part_zero _ Hp) in Ho; inv Ho | ].
      split; [ intros hd b o Hp Ho; rewrite (part_zero _ Hp) in Ho; inv Ho | ].
      unfold SZ_SURFACE. lia.
    Qed.

    Lemma floor_data11 : floor_data (lp_ge lp) m11.
    Proof.
      intros h (hd & sf & xv & zv & Hh & Ho & _).
      rewrite (part_zero _ (floor_head_part _ _ _ Hh)) in Ho. inv Ho.
    Qed.

    Lemma ffw11 : ffw (lp_ge lp) bm m11.
    Proof.
      split.
      { rewrite genv_next_eq, nb11, nb3. unfold Ple. lia. }
      split.
      2: split; [ exact floor_data11 | ].
      2: { intros a s y fh Hl _ Hae. rewrite L_act in Hl. injection Hl as <-. exfalso.
           vm_compute in Hae. discriminate Hae. }
      exists (Mem.flat_inj thr), bfi, bmiss, bcalls, bsin, ab, biom, bmq, brm, bo, Ptrofs.zero,
        bt, Ptrofs.zero, (Vptr bs Ptrofs.zero), (Vptr bar Ptrofs.zero), Int.zero, (Vptr bc Ptrofs.zero).
      split; [ exact closed11 | ].
      split; [ intros id b Hfs; exact (flat_some _ (sym_lt _ _ Hfs)) | ].
      split; [ exact (flat_some _ (sym_lt _ _ Hbm)) | ].
      do 8 (split; [ assumption | ]).
      split; [ exact L_obj | ].
      split; [ unfold SZ_OBJECT; vm_compute; discriminate | ].
      split; [ exact L_anim | ].
      split; [ exact L_buf | ].
      split; [ vm_compute; discriminate | ].
      split; [ exact bo_bm | ].
      split; [ intro E; exact (sym_ne_fresh _ _ _ Hbm (or_introl eq_refl) (eq_sym E)) | ].
      split; [ exact bt_bo | ].
      split; [ intros b [Hin | Hin];
               [ cbn [In] in Hin; repeat (destruct Hin as [<- | Hin]; [ split; neq | ]); destruct Hin
               | split; neq ] | ].
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
      intros i cb co Hi Hl. exfalso. exact (coll_noptr _ _ _ Hi Hl).
    Qed.

    (* ---- the witness ---- *)
    Theorem witness_ok :
      SafeB_syms_ok lp SBw
      /\ mem_ok_lp bm (MWF_real lp bm bc Ptrofs.zero SBw) m11
      /\ PhiW lp bm m11
      /\ read_cells bm m11 (entry_cells Float32.zero).
    Proof.
      split; [ exact Sy_w | ].
      split.
      - split; [ exact (mwf_real_valid lp bm bc Ptrofs.zero SBw m11 mwf_w11) | ].
        split; [ | exact mwf_w11 ].
        intros v Hl. rewrite L_act in Hl. injection Hl as <-. reflexivity.
      - split; [ exact (conj hinv (conj world (conj anim_ok (conj mobj_ok ffw11)))) | exact read_c0 ].
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

  Theorem start_sat_lp :
    exists SafeB m, SafeB_syms_ok lp SafeB
      /\ mem_ok_lp bm (MWF_real lp bm bc Ptrofs.zero SafeB) m /\ PhiW lp bm m
      /\ read_cells bm m (entry_cells Float32.zero).
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
    destruct (Mem.alloc m0 0 24) as [m1 bt] eqn:A1.
    destruct (Mem.alloc m1 0 48) as [m2 bs] eqn:A2.
    destruct (Mem.alloc m2 0 60) as [m3 bar] eqn:A3.
    assert (Pgms : forall x, 0 <= x < 200 -> Mem.perm m0 bm x Cur Writable) by exact rp_gms.
    assert (Pab : forall x, 0 <= x < 12 -> Mem.perm m0 ab x Cur Writable)
      by exact (wr_sym _ _ _ ab LO_gi dm_ab eq_refl eq_refl ltac:(cbn; discriminate) Hab).
    destruct (store_ex m3 Mfloat32 bm 64 (Vsingle ENTRY_Y)) as (m3a & S1a).
    { intros x Hx. cbn [size_chunk] in Hx. fwd. apply Pgms. lia. }
    { exists 16. reflexivity. }
    destruct (store_ex m3a Mfloat32 bo 36 (Vsingle ENTRY_Y)) as (m3b & S1b).
    { intros x Hx. cbn [size_chunk] in Hx. fwd.
      refine (wr_sym _ _ _ bo LO_olp dm_pool eq_refl eq_refl ltac:(cbn; discriminate) Hbo x _). cbn. lia. }
    { exists 9. reflexivity. }
    destruct (store_ex m3b Mint16signed bs 0 (Vint Int.zero)) as (m4 & S1).
    { intros x Hx. cbn [size_chunk] in Hx.
      eapply Mem.perm_store_1; [ exact S1b | ]. eapply Mem.perm_store_1; [ exact S1a | ].
      eapply Mem.perm_alloc_1; [ exact A3 | ].
      eapply Mem.perm_implies; [ eapply Mem.perm_alloc_2; [ exact A2 | lia ] | constructor ]. }
    { exists 0. reflexivity. }
    destruct (store_ex m4 Mint32 bm 12 (Vint ACT_SPAWN_NO_SPIN_AIRBORNE)) as (m5 & S2).
    { intros x Hx. cbn [size_chunk] in Hx. fwd. apply Pgms. lia. }
    { exists 3. reflexivity. }
    destruct (store_ex m5 Mint32 bm 104 (Vptr bs Ptrofs.zero)) as (m6 & S3).
    { intros x Hx. cbn [size_chunk] in Hx. fwd. apply Pgms. lia. }
    { exists 26. reflexivity. }
    destruct (store_ex m6 Mint32 bm 144 (Vptr bar Ptrofs.zero)) as (m7 & S4).
    { intros x Hx. cbn [size_chunk] in Hx. fwd. apply Pgms. lia. }
    { exists 36. reflexivity. }
    destruct (store_ex m7 Mint32 bm 156 (Vptr bc Ptrofs.zero)) as (m8 & S5).
    { intros x Hx. cbn [size_chunk] in Hx. fwd. apply Pgms. lia. }
    { exists 39. reflexivity. }
    destruct (store_ex m8 Mint32 bm 160 (Vptr ab Ptrofs.zero)) as (m9 & S6).
    { intros x Hx. cbn [size_chunk] in Hx. fwd. apply Pgms. lia. }
    { exists 40. reflexivity. }
    destruct (store_ex m9 Mint32 bm 136 (Vptr bo Ptrofs.zero)) as (m10 & S7).
    { intros x Hx. cbn [size_chunk] in Hx. fwd. apply Pgms. lia. }
    { exists 34. reflexivity. }
    destruct (store_ex m10 Mint32 ab 8 (Vptr bt Ptrofs.zero)) as (m11 & S8).
    { intros x Hx. cbn [size_chunk] in Hx. fwd. apply Pab. lia. }
    { exists 2. reflexivity. }
    exists (SBw bt bar), m11.
    eapply witness_ok; eassumption.
  Qed.
End Witness.

(* ====================================================================== *)
(* THE GUARD: for every 17-TU link, the GOAL-2 capstone's start premise   *)
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
    /\ read_cells bm m (entry_cells Float32.zero).
Proof.
  intros lp H12.
  destruct (linked12_init_mem lp H12) as (m0 & Hinit).
  destruct (spawn_symbols_resolve lp H12) as (bm & bc & Hbm & Hbc).
  destruct (start_sat_lp lp H12 m0 Hinit bm bc Hbm Hbc) as (SafeB & m & Hs & Hok & Hphi & Hrc).
  exists m, bm, bc, SafeB. exact (conj Hbm (conj Hbc (conj Hs (conj Hok (conj Hphi Hrc))))).
Qed.
