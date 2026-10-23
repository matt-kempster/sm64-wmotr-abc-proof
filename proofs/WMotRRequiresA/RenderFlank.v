(* ===================================================================== *)
(* RenderFlank: the render step as a flank of GOAL 2's frame (2026-10-22). *)
(*                                                                       *)
(* rendering_graph_node.c is the 35th linked TU (LinkedTwelve.tu_rest).   *)
(* Between two of Mario's frames geo_process_object runs                 *)
(*   geo_set_animation_globals(&marioObj->header.gfx.animInfo, hasAnim)  *)
(* on Mario's node (rendering_graph_node.c), which advances animFrame    *)
(* through graph_node.c's geo_update_animation_frame.  This file:        *)
(*   - render_call: that real call on the linked genv, the frame's        *)
(*     seg_render segment (HeightFrame);                                  *)
(*   - render_mem_ok: GOAL 1's mem_ok (valid bm, the action cell, MWF_real)*)
(*     is CARRIED through it, from the proved footprint                   *)
(*     (RenderSet.gsag_footprint: Mario's animFrame / animTimer /         *)
(*     animFrameAccelAssist and the six gCurrAnim* globals only);         *)
(*   - render_frame_range: the animFrame range on the link                *)
(*     (RenderSet.gsag_frame), for the top-of-pole rows;                  *)
(*   - linked12_gAreaUpdateCounter: the counter the advance reads now has *)
(*     rendering_graph_node.c's 2-byte storage (it was a size-0 extern    *)
(*     block before this TU: FINDING, docs/TRUST.md audit).               *)
(* ===================================================================== *)
From Coq Require Import ZArith Lia List.
From compcert Require Import Coqlib Integers Values AST Ctypes Clight ClightBigstep
  Memory Maps Globalenvs Linking Events Errors.
From SM64.Generated Require graph_node rendering_graph_node memory mario level_update
  interaction.
From SM64.Proofs Require Import SymbolicLinking RealFrameLinked CensusV2 MWFReal SpawnInit
  LinkedTwelve ActionValueFrame Taint NoAImpliesNoFlyLinked GraphNodeBodies.
From SM64.Proofs Require NoAImpliesNoFlyTwelve.
From SM64.Proofs.WMotRRequiresA Require Import RenderAnim RenderSet.
Import ListNotations.

Local Open Scope Z_scope.

(* Mario's AnimInfo sits 56 bytes into his Object
   (Object.header.gfx.animInfo), pinned from the generated composites *)
Definition RENDER_ANIM_OFF : Z := 56.

Lemma animInfo_offset :
  (match (prog_comp_env rendering_graph_node.prog) ! rendering_graph_node._GraphNodeObject with
   | Some co => field_offset (prog_comp_env rendering_graph_node.prog)
                  rendering_graph_node._animInfo (co_members co)
   | None => Error nil end) = OK (RENDER_ANIM_OFF, Full)
  /\ (match (prog_comp_env rendering_graph_node.prog) ! rendering_graph_node._ObjectNode with
      | Some co => field_offset (prog_comp_env rendering_graph_node.prog)
                     rendering_graph_node._gfx (co_members co)
      | None => Error nil end) = OK (0, Full)
  /\ (match (prog_comp_env rendering_graph_node.prog) ! rendering_graph_node._Object with
      | Some co => field_offset (prog_comp_env rendering_graph_node.prog)
                     rendering_graph_node._header (co_members co)
      | None => Error nil end) = OK (0, Full).
Proof. vm_compute. auto. Qed.

(* the render step on Mario's node: the real geo_set_animation_globals call
   on &m->marioObj->header.gfx.animInfo (MarioState.marioObj at 136) *)
Definition render_call (lp : Clight.program) (bm : block) (m m' : mem) : Prop :=
  exists mb mo vh t vres,
    Mem.load Mint32 m bm 136 = Some (Vptr mb mo)
    /\ eval_funcall function_entry2 (lp_ge lp) m
         (Internal rendering_graph_node.f_geo_set_animation_globals)
         [Vptr mb (Ptrofs.add mo (Ptrofs.repr RENDER_ANIM_OFF)); vh] t m' vres.

(* ---- the link supplies the two callees and the composites ---- *)
Section Link.
  Variable lp : Clight.program.
  Hypothesis H12 : linked12 lp.

  Lemma render_cenv : forall id co, (prog_comp_env graph_node.prog) ! id = Some co ->
    (genv_cenv (lp_ge lp)) ! id = Some co.
  Proof.
    intros id co Hco. unfold lp_ge, globalenv. cbn [genv_cenv].
    exact (linkorder_comp_env_extends lp graph_node.prog id co (linked12_LO_graph_node lp H12) Hco).
  Qed.

  Lemma render_guaf : forall b,
    Genv.find_symbol (lp_ge lp) graph_node._geo_update_animation_frame = Some b ->
    Genv.find_funct_ptr (lp_ge lp) b = Some (Internal graph_node.f_geo_update_animation_frame).
  Proof.
    intros b Hb.
    destruct (linkorder_resolves_internal lp graph_node.prog _ _ (linked12_LO_graph_node lp H12)
                gn_defmap_geo) as (b' & Hs & Hf).
    unfold lp_ge in Hb. change mario._geo_update_animation_frame with graph_node._geo_update_animation_frame in Hs.
    rewrite Hb in Hs. injection Hs as <-. exact Hf.
  Qed.

  Lemma mem_defmap_stv :
    (prog_defmap memory.prog) ! memory._segmented_to_virtual
      = Some (Gfun (Internal memory.f_segmented_to_virtual)).
  Proof. vm_compute. reflexivity. Qed.

  Lemma render_stv : forall b,
    Genv.find_symbol (lp_ge lp) memory._segmented_to_virtual = Some b ->
    Genv.find_funct_ptr (lp_ge lp) b = Some (Internal memory.f_segmented_to_virtual).
  Proof.
    intros b Hb.
    destruct (linkorder_resolves_internal lp memory.prog _ _ (linked12_LO_memory lp H12)
                mem_defmap_stv) as (b' & Hs & Hf).
    unfold lp_ge in Hb. rewrite Hb in Hs. injection Hs as <-. exact Hf.
  Qed.

  (* FINDING (2026-10-22): before rendering_graph_node.c was linked, every TU
     only DECLARED gAreaUpdateCounter (extern, init nil), so init_mem gave it a
     size-0 block and geo_update_animation_frame's read of it had no
     execution from the boot image.  Now the link's definition is
     rendering_graph_node.c's: a real 2-byte u16 initialised to 0. *)
  Lemma rgn_defmap_counter :
    (prog_defmap rendering_graph_node.prog) ! rendering_graph_node._gAreaUpdateCounter
      = Some (Gvar rendering_graph_node.v_gAreaUpdateCounter).
  Proof. vm_compute. reflexivity. Qed.

  Lemma linked12_gAreaUpdateCounter :
    exists gv, (prog_defmap lp) ! rendering_graph_node._gAreaUpdateCounter = Some (Gvar gv)
      /\ gvar_init gv = [Init_int16 (Int.repr 0)].
  Proof.
    pose proof (linked12_LO_rendering_graph_node lp H12) as LO.
    Local Transparent Linker_program.
    unfold linkorder, Linker_program, linkorder_program in LO.
    destruct LO as [LOast _].
    destruct (prog_defmap_linkorder _ _ _ _ LOast rgn_defmap_counter) as (gd' & Hgd' & Hlo).
    inv Hlo. match goal with H : linkorder _ _ |- _ => inv H end.
    match goal with H : linkorder ?i1 ?i2 |- _ =>
      change (linkorder_varinit i1 i2) in H; inv H end.
    - eexists. split; [ exact Hgd' | reflexivity ].
  Qed.
End Link.

(* ---- a store apart from every cell MWF_real reads keeps MWF_real ---- *)
Section MwfStore.
  Variable lp : Clight.program.
  Variables (bm bc : block) (oc0 : ptrofs) (SafeB : block -> Prop).
  Hypothesis Hbc_bm : bc <> bm.
  Notation MWF := (MWF_real lp bm bc oc0 SafeB).

  Definition mwf_watched (id : ident) : Prop :=
    id = mario._gMarioState \/ id = interaction._gGlobalTimer
    \/ id = interaction._sInteractionHandlers \/ mem_id id knockback_table_ids = true
    \/ id = mario._gMarioAnimsBuf.

  Lemma mwf_store_apart : forall mm ch b z v mm',
    MWF mm -> b <> bm -> b <> bc ->
    (forall id gb, mwf_watched id -> Genv.find_symbol (lp_ge lp) id = Some gb -> gb <> b) ->
    (forall b' o', v = Vptr b' o' -> SafeB b') ->
    Mem.store ch mm b z v = Some mm' -> MWF mm'.
  Proof.
    intros mm ch b z v mm' M Hbm Hbc Hw Hsafe Hst.
    apply (MWF_real_transfer lp bm bc oc0 SafeB Hbc_bm mm mm'); [ .. | exact M ].
    - intros b0 Hv. eapply Mem.store_valid_block_1; eauto.
    - intros v0 Hld. pose proof M as (_ & R1 & _). apply R1.
      rewrite <- Hld. symmetry.
      eapply Mem.load_store_other; [ exact Hst | left; congruence ].
    - intros ch1 b1 ofs v1 Hrow Hld.
      rewrite <- Hld. symmetry.
      eapply Mem.load_store_other; [ exact Hst | left ].
      destruct Hrow as [ [Eb _] | [ Eb | [ Hfs | [ Hfs | [ Hfs | [ (gid & Hkt & Hfs) | Hfs ] ] ] ] ] ].
      + subst b1. congruence.
      + subst b1. congruence.
      + exact (Hw _ _ (or_introl eq_refl) Hfs).
      + exact (Hw _ _ (or_intror (or_introl eq_refl)) Hfs).
      + exact (Hw _ _ (or_intror (or_intror (or_introl eq_refl))) Hfs).
      + exact (Hw _ _ (or_intror (or_intror (or_intror (or_introl Hkt)))) Hfs).
      + exact (Hw _ _ (or_intror (or_intror (or_intror (or_intror eq_refl)))) Hfs).
    - intros b1 ofs b' o' Hs Hld.
      pose proof M as (_ & _ & _ & _ & _ & _ & _ & R7 & _).
      cbn [Mem.loadv] in Hld.
      destruct (Mem.load_pointer_store _ _ _ _ _ _ _ _ _ _ _ Hst Hld)
        as [ (Evv & _) | Hdis ].
      + exact (Hsafe _ _ Evv).
      + apply (R7 b1 ofs b' o' Hs). cbn [Mem.loadv].
        rewrite <- Hld. symmetry.
        eapply Mem.load_store_other; [ exact Hst | exact Hdis ].
  Qed.
End MwfStore.

(* a property kept by every allowed store is kept by a chain of them *)
Lemma stores_by_carry : forall (P : mem -> block -> Z -> memory_chunk -> val -> Prop) (Q : mem -> Prop),
  (forall mm mm' ch b z v, P mm b z ch v -> Mem.store ch mm b z v = Some mm' -> Q mm -> Q mm') ->
  forall m m', stores_by P m m' -> Q m -> Q m'.
Proof.
  intros P Q Hstep m m' H. induction H as [m | m m1 m2 ch b z v HP Hst _ IH]; intros Hq.
  - exact Hq.
  - exact (IH (Hstep _ _ _ _ _ _ HP Hst Hq)).
Qed.

(* ---- the render step carries GOAL 1's mem_ok, on the link ---- *)
Section RenderOk.
  Variable lp : Clight.program.
  Hypothesis H12 : linked12 lp.
  Variables (bm bc : block) (oc0 : ptrofs) (SafeB : block -> Prop).
  Hypothesis HSafeB_syms : SafeB_syms_ok lp SafeB.
  Hypothesis Hbm_sym : Genv.find_symbol (lp_ge lp) level_update._gMarioStates = Some bm.
  Hypothesis Hbc_sym : Genv.find_symbol (lp_ge lp) mario._gControllers = Some bc.
  Hypothesis Hoc0 : oc0 = Ptrofs.zero.
  Notation MWF := (MWF_real lp bm bc oc0 SafeB).

  Lemma mwf_watched_not_safe : forall id gb, mwf_watched id ->
    Genv.find_symbol (lp_ge lp) id = Some gb -> ~ SafeB gb.
  Proof.
    intros id gb Hw Hs. apply (safeb_of_nonfam_sym lp SafeB HSafeB_syms id gb Hs).
    destruct Hw as [-> | [-> | [-> | [Hk | ->]]]]; try (vm_compute; reflexivity).
    exact (non_safeb_ktab _ Hk).
  Qed.

  Lemma render_gvar_apart : forall id b, In id render_gvars ->
    Genv.find_symbol (lp_ge lp) id = Some b ->
    b <> bm /\ b <> bc /\ (forall id' gb, mwf_watched id' -> Genv.find_symbol (lp_ge lp) id' = Some gb -> gb <> b).
  Proof.
    intros id b Hin Hs.
    assert (Hne : forall id', id' = level_update._gMarioStates \/ id' = mario._gControllers
                    \/ mwf_watched id' -> id' <> id).
    { intros id' Hid' E. subst id'.
      cbn in Hin.
      destruct Hid' as [E | [E | [E | [E | [E | [E | E]]]]]];
        repeat destruct Hin as [Hin | Hin]; subst; try contradiction;
        try (vm_compute in E; discriminate E);
        vm_compute in E; discriminate E. }
    split; [| split].
    - intro E. subst b. exact (Genv.global_addresses_distinct _ (Hne _ (or_introl eq_refl)) Hbm_sym Hs eq_refl).
    - intro E. subst b. exact (Genv.global_addresses_distinct _ (Hne _ (or_intror (or_introl eq_refl))) Hbc_sym Hs eq_refl).
    - intros id' gb Hw Hs'. exact (Genv.global_addresses_distinct _ (Hne _ (or_intror (or_intror Hw))) Hs' Hs).
  Qed.

  Theorem render_mem_ok : forall m m',
    mem_ok_lp bm MWF m -> render_call lp bm m m' -> mem_ok_lp bm MWF m'.
  Proof.
    intros m m' (Hv & Hs & HM) (mb & mo & vh & t & vres & Hmo & Hev).
    destruct (NoAImpliesNoFlyTwelve.Hspawn lp H12 bm bc oc0 Hbm_sym Hbc_sym Hoc0) as (init & Hspawn).
    pose proof (spawn_Hbc_bm lp init bm bc oc0 Hspawn) as Hbc_bm.
    pose proof (gsag_footprint (lp_ge lp) (render_cenv lp H12) (render_guaf lp H12) (render_stv lp H12)
                  m mb _ vh t m' vres Hev) as Hfp.
    set (oi := Ptrofs.add mo (Ptrofs.repr RENDER_ANIM_OFF)) in *.
    (* Mario's object is SafeB (the marioObj chase root), and so is the
       Animation header it points at (R7) *)
    assert (Smb : SafeB mb).
    { apply (mwf_real_chase_safe lp bm bc oc0 SafeB 136 m mb mo); [ vm_compute; reflexivity | exact HM | exact Hmo ]. }
    assert (Sbt : forall bt ot, Mem.loadv Mptr m (Vptr mb (Ptrofs.add oi (Ptrofs.repr 4))) = Some (Vptr bt ot) -> SafeB bt).
    { intros bt ot Hl. exact (mwf_real_chase_step lp bm bc oc0 SafeB m mb _ bt ot HM Smb Hl). }
    clear Hev Hmo.
    refine (stores_by_carry _ (mem_ok_lp bm MWF) _ m m' Hfp (conj Hv (conj Hs HM))).
    intros m1 m2 ch b z v HP Hst (Hv1 & Hs1 & HM1).
    clear Hv Hs HM. rename Hv1 into Hv, Hs1 into Hs, HM1 into HM.
    - destruct HP as [Hloc Hval].
      (* the target block is apart from bm, bc and every cell MWF_real reads *)
      assert (Hap : b <> bm /\ b <> bc /\ (forall id gb, mwf_watched id ->
                      Genv.find_symbol (lp_ge lp) id = Some gb -> gb <> b)).
      { destruct Hloc as [(-> & _) | (id & Hin & Hfs & _)].
        - split; [ exact (safeb_not_bm lp init bm bc oc0 SafeB Hspawn HSafeB_syms _ Smb) |].
          split; [ intro E; rewrite E in Smb; exact (safeb_not_bc lp init bm bc oc0 SafeB Hspawn HSafeB_syms Smb) |].
          intros id gb Hw Hfs E. subst gb. exact (mwf_watched_not_safe id mb Hw Hfs Smb).
        - exact (render_gvar_apart id b Hin Hfs). }
      destruct Hap as (Hbm & Hbc & Hw).
      (* a stored pointer is SafeB: read from Mario's object or the header *)
      assert (Hsv : forall b' o', v = Vptr b' o' -> SafeB b').
      { intros b' o' Ev. destruct (Hval b' o' Ev) as (b0 & o0 & Hl & Hb0).
        assert (S0 : SafeB b0) by (destruct Hb0 as [-> | (ot & Hc)]; [ exact Smb | exact (Sbt _ _ Hc) ]).
        subst v. exact (mwf_real_chase_step lp bm bc oc0 SafeB m1 b0 o0 b' o' HM S0 Hl). }
      split; [| split].
      + eapply Mem.store_valid_block_1; eauto.
      + intros a Hl. apply Hs. rewrite <- Hl. symmetry.
        eapply Mem.load_store_other; [ exact Hst | left; congruence ].
      + exact (mwf_store_apart lp bm bc oc0 SafeB Hbc_bm m1 ch b z v m2 HM Hbm Hbc Hw Hsv Hst).
  Qed.

  (* the animFrame range on the link (RenderSet.gsag_frame): with no
     acceleration and a header with -1 <= loopStart < loopEnd <= 32766, the
     render step keeps Mario's animFrame in [-1, loopEnd] *)
  Theorem render_frame_range : forall m m' mb mo vh t vres bt ot fr ls lend,
    eval_funcall function_entry2 (lp_ge lp) m
      (Internal rendering_graph_node.f_geo_set_animation_globals)
      [Vptr mb (Ptrofs.add mo (Ptrofs.repr RENDER_ANIM_OFF)); vh] t m' vres ->
    Ptrofs.unsigned (Ptrofs.add mo (Ptrofs.repr RENDER_ANIM_OFF)) + 20 <= Ptrofs.max_unsigned ->
    (forall id b, In id render_gvars -> Genv.find_symbol (lp_ge lp) id = Some b -> b <> mb) ->
    let oi := Ptrofs.add mo (Ptrofs.repr RENDER_ANIM_OFF) in
    Mem.loadv Mptr m (Vptr mb (Ptrofs.add oi (Ptrofs.repr 4))) = Some (Vptr bt ot) ->
    Mem.loadv Mint16signed m (Vptr mb (Ptrofs.add oi (Ptrofs.repr 8))) = Some (Vint fr) ->
    Mem.loadv Mint32 m (Vptr mb (Ptrofs.add oi (Ptrofs.repr 16))) = Some (Vint Int.zero) ->
    Mem.loadv Mint16signed m (Vptr bt (Ptrofs.add ot (Ptrofs.repr 6))) = Some (Vint ls) ->
    Mem.loadv Mint16signed m (Vptr bt (Ptrofs.add ot (Ptrofs.repr 8))) = Some (Vint lend) ->
    -1 <= Int.signed ls < Int.signed lend -> Int.signed lend <= 32766 ->
    -1 <= Int.signed fr <= Int.signed lend ->
    exists r, Mem.loadv Mint16signed m' (Vptr mb (Ptrofs.add oi (Ptrofs.repr 8))) = Some (Vint r)
              /\ -1 <= Int.signed r <= Int.signed lend.
  Proof.
    intros m m' mb mo vh t vres bt ot fr ls lend Hev Hnw Hrg oi.
    exact (gsag_frame (lp_ge lp) (render_cenv lp H12) (render_guaf lp H12) (render_stv lp H12)
             m mb oi vh t m' vres bt ot fr ls lend Hev Hnw Hrg).
  Qed.
End RenderOk.
