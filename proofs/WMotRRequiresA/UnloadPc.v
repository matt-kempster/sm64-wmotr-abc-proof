(* ====================================================================== *)
(* UnloadPc (GOAL 2 objects, 2026-11-03): the real unload_object on an     *)
(* inactive slot k of a walked ring keeps the object phase's invariant     *)
(* (ClearKeep.Pc), from the sharp footprint (UnloadSharp.unload_sharp_real)*)
(* and the call's permission frame (PermWalk.pk_body over its call tree).  *)
(*                                                                        *)
(*   mem_ok   SpawnBodies.sr_unload (the SafeB world; the slot is a pool   *)
(*            pointer, the pool is SafeB);                                 *)
(*   PhiW     RenderKeep.k_all_lvl_wq with the written globals la / fl /   *)
(*            gObjParentGraphNode / the sound blocks, and for the pool the *)
(*            far objects Q = the pool's slots: the call changes slot      *)
(*            fields below 136 only (k's flags / throwMatrix / prevObj /   *)
(*            activeFlags, every slot's graph and list links), Mario's     *)
(*            slot is active so it is not k; lvl_w by FfWorld.lvl_w_unch_na*)
(*            (the sound blocks it reads are audio blocks; aud_w is kept   *)
(*            as AudioInv);                                                *)
(*   a_down   gMarioStates and the controllers are untouched;              *)
(*   obj_w    UnloadOw.obj_w_unload.                                       *)
(*   plat_still  gMarioPlatform is untouched; it is NULL or a slot        *)
(*            (PlatformKeep.plat_al, 2026-11-06), whose cells +276..+288   *)
(*            no write of the call reaches.  FOUND (phantom forall) before *)
(*            the pin: a misaligned pointer's cells could overlap a slot's *)
(*            links, which the call rewrites.  REPAIRED: StartTerrain      *)
(*            checks the pin at boot.                                      *)
(* ====================================================================== *)

From Coq Require Import ZArith Lia List Bool.
From compcert Require Import Coqlib Integers Floats Values AST Ctypes Cop Clight
  ClightBigstep Clightdefs Memory Maps Globalenvs Events Errors Linking.
From SM64.Generated Require surface_load surface_collision object_list_processor level_update mario
  area spawn_object graph_node audio_external.
From SM64.Proofs Require Import SymbolicLinking RealFrameLinked LinkedTwelve CensusV2 MWFReal
  SpawnInit ActionValueFrame NoAImpliesNoFlyLinked AGates.
From SM64.Proofs Require Import Generic.PermWalk Generic.ClosedMem Generic.ClightClosed.
From SM64.Proofs Require SpawnBodies.
From SM64.Proofs Require Import HeightInvariant WMotRWorld FrameSplit.
From SM64.Proofs.WMotRRequiresA Require Import FfWorld AnimData AnimWorld RenderKeep.
From SM64.Proofs.WMotRRequiresA Require ObjWorld ObjRing ObjAlloc PollKeep PlatformKeep ObjPhase BhvVM
  ClearKeep UnloadObj UnloadLoop UnloadSharp UnloadRows UnloadOw AudioInv CapAudio LsContract AnimWorld.
Import ListNotations.
Local Open Scope Z_scope.
Local Transparent Archi.ptr64.

Module OW := ObjWorld.
Module OLP := object_list_processor.
Module SO := spawn_object.
Module GN := graph_node.
Module AX := audio_external.

(* a load across a change kept on P, with the permission frame *)
Lemma ld_eq : forall (P : block -> Z -> Prop) m m' ch b z, PK m m' -> Mem.unchanged_on P m m' ->
  (forall i, z <= i < z + size_chunk ch -> P b i) -> Mem.load ch m' b z = Mem.load ch m b z.
Proof.
  intros P m m' ch b z (N & PP & F) U H.
  destruct (plt b (Mem.nextblock m)) as [V | V].
  - exact (Mem.load_unchanged_on_1 P m m' ch b z U V H).
  - destruct (Mem.load ch m' b z) eqn:E1.
    + exfalso. apply Mem.load_valid_access in E1. destruct E1 as (Hr & _).
      apply (F b z Cur Readable V). apply Hr. pose proof (size_chunk_pos ch). lia.
    + destruct (Mem.load ch m b z) eqn:E2; [ | reflexivity ]. exfalso. apply V.
      apply Mem.load_valid_access in E2.
      eapply Mem.valid_access_valid_block. eapply Mem.valid_access_implies; [ exact E2 | constructor ].
Qed.

Section UP.
  Variable lp : Clight.program.
  Hypothesis H12 : linked12 lp.
  Notation G := (lp_ge lp).
  Variable bm : block.
  Hypothesis Hbm_sym : Genv.find_symbol G level_update._gMarioStates = Some bm.
  Variables (bc : block) (oc0 : ptrofs) (SafeB : block -> Prop).
  Hypothesis HSafeB_syms : SafeB_syms_ok lp SafeB.
  Hypothesis Hbc_sym : Genv.find_symbol G mario._gControllers = Some bc.
  Hypothesis Hoc0 : oc0 = Ptrofs.zero.
  Notation MWF := (MWF_real lp bm bc oc0 SafeB).
  Notation Pc := (ClearKeep.Pc lp bm bc oc0 SafeB).
  Notation u := Ptrofs.unsigned.

  (* ---- 1. the call tree keeps every old permission (PermWalk) ---- *)
  Lemma PS_spftv : PS G (Internal AX.f_seq_player_fade_to_target_volume).
  Proof. apply (pk_body G [] (PollKeep.psym_nil lp)). vm_compute. reflexivity. Qed.
  Lemma ps_spftv : PollKeep.ps_id lp AX._seq_player_fade_to_target_volume.
  Proof.
    apply (PollKeep.ps_int lp AX.prog _ AX.f_seq_player_fade_to_target_volume (linked12_LO_audio_external lp H12));
      [ vm_compute; reflexivity | exact PS_spftv ].
  Qed.
  Lemma ps_spfnv : PollKeep.ps_id lp AX._seq_player_fade_to_normal_volume.
  Proof.
    apply (PollKeep.ps_int lp AX.prog _ AX.f_seq_player_fade_to_normal_volume (linked12_LO_audio_external lp H12));
      [ vm_compute; reflexivity | ].
    apply (pk_body G [] (PollKeep.psym_nil lp)). vm_compute. reflexivity.
  Qed.
  Lemma PS_bbmf : PS G (Internal AX.f_begin_background_music_fade).
  Proof.
    apply (pk_body G [AX._seq_player_fade_to_target_volume; AX._seq_player_fade_to_normal_volume]
             (PollKeep.psym_cons lp _ _ ps_spftv (PollKeep.psym_cons lp _ _ ps_spfnv (PollKeep.psym_nil lp)))).
    vm_compute. reflexivity.
  Qed.
  Lemma ps_bbmf : PollKeep.ps_id lp AX._begin_background_music_fade.
  Proof.
    apply (PollKeep.ps_int lp AX.prog _ AX.f_begin_background_music_fade (linked12_LO_audio_external lp H12));
      [ vm_compute; reflexivity | exact PS_bbmf ].
  Qed.
  Lemma PS_ubmas : PS G (Internal AX.f_update_background_music_after_sound).
  Proof.
    apply (pk_body G [AX._begin_background_music_fade] (PollKeep.psym_cons lp _ _ ps_bbmf (PollKeep.psym_nil lp))).
    vm_compute. reflexivity.
  Qed.
  Lemma ps_ubmas : PollKeep.ps_id lp AX._update_background_music_after_sound.
  Proof.
    apply (PollKeep.ps_int lp AX.prog _ AX.f_update_background_music_after_sound (linked12_LO_audio_external lp H12));
      [ vm_compute; reflexivity | exact PS_ubmas ].
  Qed.
  Lemma PS_ssfs : PS G (Internal AX.f_stop_sounds_from_source).
  Proof.
    apply (pk_body G [AX._update_background_music_after_sound] (PollKeep.psym_cons lp _ _ ps_ubmas (PollKeep.psym_nil lp))).
    vm_compute. reflexivity.
  Qed.
  Lemma ps_ssfs : PollKeep.ps_id lp SO._stop_sounds_from_source.
  Proof.
    apply (PollKeep.ps_int lp AX.prog _ AX.f_stop_sounds_from_source (linked12_LO_audio_external lp H12));
      [ vm_compute; reflexivity | exact PS_ssfs ].
  Qed.
  Lemma ps_grc : PollKeep.ps_id lp SO._geo_remove_child.
  Proof.
    apply (PollKeep.ps_int lp GN.prog _ GN.f_geo_remove_child (linked12_LO_graph_node lp H12));
      [ vm_compute; reflexivity | ].
    apply (pk_body G [] (PollKeep.psym_nil lp)). vm_compute. reflexivity.
  Qed.
  Lemma ps_gac : PollKeep.ps_id lp SO._geo_add_child.
  Proof.
    apply (PollKeep.ps_int lp GN.prog _ GN.f_geo_add_child (linked12_LO_graph_node lp H12));
      [ vm_compute; reflexivity | ].
    apply (pk_body G [] (PollKeep.psym_nil lp)). vm_compute. reflexivity.
  Qed.
  Lemma ps_dao : PollKeep.ps_id lp SO._deallocate_object.
  Proof.
    apply (PollKeep.ps_int lp SO.prog _ SO.f_deallocate_object (linked12_LO_spawn_object lp H12));
      [ vm_compute; reflexivity | ].
    apply (pk_body G [] (PollKeep.psym_nil lp)). vm_compute. reflexivity.
  Qed.
  Theorem PS_uo : PS G (Internal SO.f_unload_object).
  Proof.
    apply (pk_body G [SO._stop_sounds_from_source; SO._geo_remove_child; SO._geo_add_child; SO._deallocate_object]
             (PollKeep.psym_cons lp _ _ ps_ssfs (PollKeep.psym_cons lp _ _ ps_grc
               (PollKeep.psym_cons lp _ _ ps_gac (PollKeep.psym_cons lp _ _ ps_dao (PollKeep.psym_nil lp)))))).
    vm_compute. reflexivity.
  Qed.

  (* ---- 2. the written globals ---- *)
  Definition unl_ws : list ident :=
    [OLP._gObjectListArray; OLP._gFreeObjectList; area._gObjParentGraphNode] ++ UnloadObj.ws_u.

  Lemma HXs : forall id, In id unl_ws -> existsb (Pos.eqb id) core_ids = false.
  Proof. exact (avoid_of unl_ws core_ids ltac:(vm_compute; reflexivity)). Qed.

  Ltac sz := unfold OW.OSZ, OW.NSLOT, ObjWorld.G_PREV, ObjWorld.G_CHILD, ObjWorld.O_NEXT, ObjWorld.O_PREV in *;
             cbn [size_chunk] in *.

  Theorem unl_row_proved : UnloadRows.unl_row lp bm bc oc0 SafeB.
  Proof.
    intros pool la m rs i l1 k l2 t m' vr Hp Hl HP R Hi El Ina H.
    pose proof HP as (Ok & Hphi & HD & Hst & How).
    pose proof Ok as (_ & _ & HM).
    pose proof How as (pool' & la' & fl & gol & gmo & sdp & gdi & rs0 & fs & S1 & S2 & S3 & S4 & S5 & S6 & S7 & C).
    rewrite Hp in S1. injection S1 as <-. rewrite Hl in S2. injection S2 as <-.
    rewrite (OW.ow_rings _ _ _ _ _ _ _ _ _ _ _ _ C) in R. injection R as ->.
    destruct UnloadRows.dm_bpg as (gd & Hdm).
    destruct (linkorder_resolves_symbol lp SO.prog _ gd (linked12_LO_spawn_object lp H12) Hdm) as (bpg & Hb).
    pose proof Hphi as (_ & _ & _ & _ & Hf & _ & Haw & Hlvl).
    pose proof (proj1 (AudioInv.aud_w_eq G m) (lvl_w_aud G m Hlvl)) as AI.
    destruct (UnloadSharp.unload_sharp_real lp H12 pool la fl bpg Hp Hl S3 Hb m rs fs i l1 k l2 t m' vr
                (OW.ow_rings _ _ _ _ _ _ _ _ _ _ _ _ C)
                (OW.ow_free _ _ _ _ _ _ _ _ _ _ _ _ C) (proj1 (OW.ow_part _ _ _ _ _ _ _ _ _ _ _ _ C)) Hi El
                (OW.ow_gfx _ _ _ _ _ _ _ _ _ _ _ _ C) AI (mwf_real_nextbound lp bm bc oc0 SafeB m HM) H)
      as (R' & F' & G' & AI' & A' & U).
    pose proof (PS_uo m _ t m' vr H) as PKm.
    (* the blocks *)
    assert (SNE : forall id1 id2 b1 b2, Genv.find_symbol G id1 = Some b1 -> Genv.find_symbol G id2 = Some b2 ->
              id1 <> id2 -> b1 <> b2).
    { intros id1 id2 b1 b2 H1 H2 Ne ->. apply Ne. eapply Genv.genv_vars_inj; eassumption. }
    assert (Hpl : pool <> la) by (apply (SNE _ _ _ _ Hp Hl); vm_compute; discriminate).
    assert (Hpf : pool <> fl) by (apply (SNE _ _ _ _ Hp S3); vm_compute; discriminate).
    assert (Hpb : pool <> bpg) by (apply (SNE _ _ _ _ Hp Hb); vm_compute; discriminate).
    assert (Hak : forall b z, ~ LsContract.gblk G UnloadObj.ws_u b -> CapAudio.ak lp UnloadObj.ws_u b z)
      by (intros b z Hn; exact Hn).
    (* a block off the written set and the pool keeps every load *)
    assert (LG : forall b, b <> pool -> b <> la -> b <> fl -> b <> bpg -> ~ LsContract.gblk G UnloadObj.ws_u b ->
              forall ch z, Mem.load ch m' b z = Mem.load ch m b z).
    { intros b N1 N2 N3 N4 N5 ch z. apply (ld_eq _ m m' ch b z PKm U). intros z' _.
      split; [ left; exact N1 | split; [ | split; [ | exact (Hak b z' N5) ] ] ].
      - intros [(E & _) | (E & _)]; [ exact (N1 E) | exact (N4 E) ].
      - intros [(E & _) | [E | E]]; [ exact (N1 E) | exact (N2 E) | exact (N3 E) ]. }
    assert (LGs : forall id b, Genv.find_symbol G id = Some b -> existsb (Pos.eqb id) UnloadOw.unl_gids = false ->
              existsb (Pos.eqb id) UnloadObj.ws_u = false -> forall ch z, Mem.load ch m' b z = Mem.load ch m b z).
    { intros id b Hs Hn Hw. apply LG.
      - intros ->. assert (E : id = OLP._gObjectPool) by (eapply Genv.genv_vars_inj; eassumption).
        subst id. vm_compute in Hn. discriminate Hn.
      - intros ->. assert (E : id = OLP._gObjectListArray) by (eapply Genv.genv_vars_inj; eassumption).
        subst id. vm_compute in Hn. discriminate Hn.
      - intros ->. assert (E : id = OLP._gFreeObjectList) by (eapply Genv.genv_vars_inj; eassumption).
        subst id. vm_compute in Hn. discriminate Hn.
      - intros ->. assert (E : id = area._gObjParentGraphNode) by (eapply Genv.genv_vars_inj; eassumption).
        subst id. vm_compute in Hn. discriminate Hn.
      - exact (UnloadObj.gblk_not G _ id b Hs Hw). }
    assert (LDy : forall b, Ple (Genv.genv_next G) b -> forall ch z, Mem.load ch m' b z = Mem.load ch m b z).
    { intros b Hbd. assert (NS : forall id, Genv.find_symbol G id <> Some b).
      { intros id Hs. pose proof (Genv.genv_symb_range _ _ Hs) as R0. unfold Plt, Ple in R0, Hbd. lia. }
      apply LG; try (intros ->; eapply NS; eassumption).
      intros (g & _ & Hg). exact (NS g Hg). }
    assert (LBM : forall ch z, Mem.load ch m' bm z = Mem.load ch m bm z)
      by exact (LGs _ _ Hbm_sym ltac:(vm_compute; reflexivity) ltac:(vm_compute; reflexivity)).
    (* the pool: a byte off k's writes and off every slot's links *)
    assert (LP : forall ch z, (forall z', z <= z' < z + size_chunk ch ->
                   (forall d n, In (d, n) UnloadSharp.UWL -> z' < k * OW.OSZ + d \/ k * OW.OSZ + d + n <= z')
                   /\ (forall j, z' < j * OW.OSZ + ObjWorld.G_PREV \/ j * OW.OSZ + ObjWorld.G_CHILD <= z')
                   /\ (forall j, z' < j * OW.OSZ + ObjWorld.O_NEXT \/ j * OW.OSZ + ObjWorld.O_PREV + 4 <= z')) ->
                 Mem.load ch m' pool z = Mem.load ch m pool z).
    { intros ch z Hz. apply (ld_eq _ m m' ch pool z PKm U). intros z' Hz'.
      destruct (Hz z' Hz') as (W1 & W2 & W3).
      split; [ right; exact W1 | split; [ | split ] ].
      - intros [(_ & j & _ & Hj) | (E & _)]; [ specialize (W2 j); lia | exact (Hpb E) ].
      - intros [(_ & j & _ & Hj) | [E | E]]; [ specialize (W3 j); lia | exact (Hpl E) | exact (Hpf E) ].
      - apply Hak. intros (g & Hg & Hs).
        assert (E : g = OLP._gObjectPool) by (eapply Genv.genv_vars_inj; eassumption). subst g.
        revert Hg. vm_compute. intros Hg. repeat (destruct Hg as [E | Hg]; [ discriminate E | ]). exact Hg. }
    assert (UWLi : forall d n, In (d, n) UnloadSharp.UWL -> 2 <= d /\ d + n <= 118).
    { intros d n Hin. unfold UnloadSharp.UWL, UnloadSharp.W1L, UnloadSharp.W2L in Hin. cbn [app In] in Hin.
      repeat (destruct Hin as [E | Hin]; [ injection E as <- <-; lia | ]). destruct Hin. }
    (* a slot j's field at offsets >= 104, off k's prevObj / activeFlags *)
    assert (Ku : UnloadOw.KPu pool k m m').
    { intros ch j off H1 H2 H3. apply LP. intros z' Hz'. split; [ | split ].
      - intros d n Hin. pose proof (UWLi d n Hin) as Hd.
        unfold UnloadSharp.UWL, UnloadSharp.W1L, UnloadSharp.W2L in Hin. cbn [app In] in Hin.
        sz. destruct (Z.eq_dec j k) as [-> | Ne].
        + repeat (destruct Hin as [E | Hin]; [ injection E as <- <-; lia | ]). destruct Hin.
        + destruct (Z.lt_trichotomy j k) as [Hlt | [Heq | Hgt]]; [ left; nia | contradiction | right; nia ].
      - intros j'. sz. destruct (Z.lt_trichotomy j' j) as [Hlt | [-> | Hgt]]; [ right; nia | right; lia | left; nia ].
      - intros j'. sz. destruct (Z.lt_trichotomy j' j) as [Hlt | [-> | Hgt]]; [ right; nia | right; lia | left; nia ]. }
    (* plat_still: gMarioPlatform is untouched and points at a slot's
       angular velocity, which no write of the call reaches *)
    assert (Hst' : PlatformKeep.plat_still lp m').
    { intros bp v Hbp Hl0.
      rewrite (LGs _ _ Hbp ltac:(vm_compute; reflexivity) ltac:(vm_compute; reflexivity)) in Hl0.
      destruct (Hst bp v Hbp Hl0) as [Hz | (pb & po & -> & Hpb0 & Hk & Hal)]; [ left; exact Hz | right ].
      rewrite Hp in Hpb0. injection Hpb0 as <-.
      exists pool, po. split; [ reflexivity | split; [ exact Hp | split; [ | exact Hal ] ] ].
      intros k0 Hk0. destruct Hal as (j & Hj & Ej).
      assert (Hk0' : 35 <= k0 <= 37) by (cbn in Hk0; lia).
      specialize (Hk k0 Hk0). cbn [Mem.loadv] in Hk |- *.
      assert (Eu : Ptrofs.unsigned (Ptrofs.add po (Ptrofs.repr (136 + 4 * k0))) = j * 608 + (136 + 4 * k0)).
      { rewrite Ptrofs.add_unsigned, Ej, (Ptrofs.unsigned_repr (136 + 4 * k0))
          by (change Ptrofs.max_unsigned with 4294967295; lia).
        apply Ptrofs.unsigned_repr. change Ptrofs.max_unsigned with 4294967295; lia. }
      rewrite Eu in Hk |- *. rewrite LP; [ exact Hk | ].
      intros z' Hz'. cbn [size_chunk] in Hz'. split; [ | split ].
      - intros d n Hin. pose proof (UWLi d n Hin) as Hd. sz.
        destruct (Z.lt_trichotomy j k) as [Hlt | [-> | Hgt]]; [ left; nia | right; lia | right; nia ].
      - intros j'. sz. destruct (Z.lt_trichotomy j' j) as [Hlt | [-> | Hgt]]; [ right; nia | right; lia | left; nia ].
      - intros j'. sz. destruct (Z.lt_trichotomy j' j) as [Hlt | [-> | Hgt]]; [ right; nia | right; lia | left; nia ]. }
    (* Mario's slot *)
    destruct (OW.ow_mario _ _ _ _ _ _ _ _ _ _ _ _ C) as (km & Hkm & Lg & Lb & _).
    assert (Hnd := proj1 (OW.ow_part _ _ _ _ _ _ _ _ _ _ _ _ C)).
    assert (Rkm : 0 <= km < OW.NSLOT).
    { pose proof (proj1 (ObjRing.rings_iff pool m la rs Hpl) (OW.ow_rings _ _ _ _ _ _ _ _ _ _ _ _ C)) as (_ & Henc).
      destruct (Henc 0%nat ltac:(unfold OW.NLIST; lia)) as (_ & Hc & _).
      exact (ObjRing.chain_range pool m _ _ _ Hc km Hkm). }
    assert (Nkm : km <> k).
    { intros ->. destruct (OW.ow_mact _ _ _ _ _ _ _ _ _ _ _ _ C k Rkm Lg) as ((f & Lf & Ef) & _).
      destruct Ina as (a & La & Ea). rewrite Lf in La. injection La as <-. rewrite Ef in Ea.
      vm_compute in Ea. discriminate Ea. }
    assert (Ukm : u (Ptrofs.repr (km * OW.OSZ)) = km * OW.OSZ)
      by (apply Ptrofs.unsigned_repr; sz; change Ptrofs.max_unsigned with 4294967295; lia).
    (* ---- mem_ok ---- *)
    assert (SBp : SafeB pool) by exact (UnloadRows.pool_safe lp bm bc oc0 SafeB m pool Ok How Hp).
    assert (Ok' : mem_ok_lp bm MWF m').
    { destruct (linkorder_resolves_funct lp SO.prog SO._unload_object SO.f_unload_object
                  (linked12_LO_spawn_object lp H12) UnloadObj.dm_uo) as (bu & Hsu & Hfu).
      refine (proj1 (SpawnBodies.sr_unload lp H12 bm bc oc0 SafeB HSafeB_syms (ClearKeep.hsp lp H12 bm Hbm_sym bc oc0 Hbc_sym Hoc0)
                       bu _ Hsu Hfu m _ t m' vr H _ Ok)).
      constructor; [ | constructor ]. intros b o E. unfold OW.slot_v in E. injection E as <- _. exact SBp. }
    (* ---- PhiW ---- *)
    assert (Phi' : phiw lp bm m').
    { pose proof Haw as (ab & bga & bauc & btab & otab & bt & ot & mb & mo & B & _).
      pose proof B as (_ & _ & _ & _ & _ & Lmo & _).
      pose proof Hf as (Hgn & (dw & FWF) & _).
      pose proof (ff_W _ _ _ _ FWF) as W.
      assert (Emb : Vptr mb mo = OW.slot_v pool km) by (change 136 with MARIOOBJ_OFF in Lmo; congruence).
      unfold OW.slot_v in Emb. injection Emb as -> ->.
      pose proof PKm as (NB & PP & _).
      assert (PM : forall b o k0 p, Plt b (Mem.nextblock m) -> Mem.perm m b o k0 p -> Mem.perm m' b o k0 p)
        by (intros b o k0 p Hb' Hp'; exact (proj1 (PP b o k0 p Hb') Hp')).
      set (Q := fun co : ptrofs => exists j, 0 <= j < OW.NSLOT /\ u co = j * OW.OSZ).
      assert (Nr : forall b, rgb lp unl_ws b -> b = la \/ b = fl \/ b = bpg \/ LsContract.gblk G UnloadObj.ws_u b).
      { intros b (id & Hin & Hs). unfold unl_ws in Hin. cbn [app In] in Hin.
        destruct Hin as [<- | [<- | [<- | Hin]]].
        - left. rewrite Hl in Hs. congruence.
        - right; left. rewrite S3 in Hs. congruence.
        - right; right; left. change area._gObjParentGraphNode with SO._gObjParentGraphNode in Hs. pose proof (eq_trans (eq_sym Hs) Hb) as E. injection E as E. exact E.
        - right; right; right. exists id. exact (conj Hin Hs). }
      assert (LD : forall ch b z, ~ rgb lp unl_ws b -> b <> bm ->
                (b <> pool \/ owinq Q (Ptrofs.repr (km * OW.OSZ)) ch z) -> Mem.load ch m' b z = Mem.load ch m b z).
      { intros ch b z Hr _ Hor. destruct (eq_block b pool) as [-> | Nb].
        2: { apply LG; [ exact Nb | | | | ].
             - intros ->. apply Hr. exists OLP._gObjectListArray. split; [ cbn; auto | exact Hl ].
             - intros ->. apply Hr. exists OLP._gFreeObjectList. split; [ cbn; auto | exact S3 ].
             - intros ->. apply Hr. exists area._gObjParentGraphNode. split; [ cbn; auto | exact Hb ].
             - intros (g & Hg & Hs). apply Hr. exists g. split; [ unfold unl_ws; apply in_or_app; right; exact Hg | exact Hs ]. }
        destruct Hor as [Hor | Hq]; [ congruence | ].
          apply LP. intros z' Hz'. unfold owinq in Hq. rewrite Ukm in Hq.
          destruct Hq as [Hq | [Hq | [Hq | (co & (j & Hj & Ec) & _ & Hq)]]];
            [ | | | rewrite Ec in Hq ];
            (split; [ | split ]);
            first [ intros d n Hin; pose proof (UWLi d n Hin) as Hd; sz;
                    destruct (Z.lt_trichotomy km k) as [Hlt | [Heq | Hgt]];
                    first [ contradiction | left; nia | right; nia ]
                  | intros j'; sz;
                    first [ destruct (Z.lt_trichotomy j' km) as [Hlt | [Heq | Hgt]]; [ right; nia | subst; lia | left; nia ]
                          | destruct (Z.lt_trichotomy j' j) as [Hlt | [Heq | Hgt]]; [ right; nia | subst; lia | left; nia ] ]
                  | intros d n Hin; pose proof (UWLi d n Hin) as Hd; sz;
                    destruct (Z.lt_trichotomy j k) as [Hlt | [Heq | Hgt]]; [ left; nia | subst; right; lia | right; nia ] ]. }
      assert (Nbm : ~ rgb lp unl_ws bm) by exact (rgb_not lp unl_ws HXs _ bm Hbm_sym ltac:(vm_compute; reflexivity)).
      assert (Bpl : bm <> pool) by (apply (SNE _ _ _ _ Hbm_sym Hp); vm_compute; discriminate).
      assert (RGa : forall b, rgb lp unl_ws b -> b <> pool /\ AnimWorld.tab_apart G m b).
      { intros b Hr. pose proof Hr as (id & _ & Hs). split.
        - intros ->. destruct (Nr pool Hr) as [E | [E | [E | (g & Hg & Hs')]]]; [ exact (Hpl E) | exact (Hpf E) | exact (Hpb E) | ].
          assert (E : g = OLP._gObjectPool) by (eapply Genv.genv_vars_inj; eassumption). subst g.
          revert Hg. vm_compute. intros Hg. repeat (destruct Hg as [E | Hg]; [ discriminate E | ]). exact Hg.
        - exact (AnimWorld.tab_apart_global G m _ _ _ b (Genv.genv_symb_range _ _ Hs) W). }
      assert (CL : forall gp0, closed_by gp0 m -> gp0 pool <> None ->
                (forall id b, Genv.find_symbol G id = Some b -> gp0 b <> None) ->
                exists gp', (forall b, gp0 b <> None -> gp' b <> None) /\ closed_by gp' m').
      { intros gp0 HC0 Gp HS0.
        assert (Vk : Val.inject gp0 (OW.slot_v pool k) (OW.slot_v pool k))
          by (apply (ClearKeep.inj_symv gp0 m _ HC0); intros b o E; unfold OW.slot_v in E; injection E as <- _; exact Gp).
        destruct (funcall_closed G m _ _ t m' vr gp0 H HC0 HS0 (Forall_cons _ Vk (Forall_nil _))) as (gp' & I & HC' & _ & _).
        exists gp'. split; [ | exact HC' ].
        intros b Hb'. destruct (gp0 b) as [[b1 d]|] eqn:E0; [ | congruence ].
        rewrite (I _ _ _ E0). discriminate. }
      assert (FR : forall bt0 ot0 k0, In k0 hs_ids ->
                Mem.load Mint32 m pool (u (Ptrofs.repr (km * OW.OSZ)) + 60) = Some (Vptr bt0 ot0) ->
                Mem.load Mint32 m pool (u (Ptrofs.repr (km * OW.OSZ)) + 72) = Some (Vint Int.zero) ->
                (exists f, -1 <= f <= hs_le k0
                   /\ Mem.load Mint16signed m pool (u (Ptrofs.repr (km * OW.OSZ)) + 64) = Some (Vint (Int.repr f))) ->
                buf_ok m bt0 ot0 k0 -> u ot0 + BUFSZ < Ptrofs.modulus ->
                exists f, -1 <= f <= hs_le k0
                  /\ Mem.load Mint16signed m' pool (u (Ptrofs.repr (km * OW.OSZ)) + 64) = Some (Vint (Int.repr f))).
      { intros bt0 ot0 k0 _ _ _ (f & Rf & L64) _ _. exists f. split; [ exact Rf | ].
        rewrite LP; [ exact L64 | ]. rewrite Ukm. intros z' Hz'. split; [ | split ].
        - intros d n Hin. pose proof (UWLi d n Hin) as Hd. sz.
          destruct (Z.lt_trichotomy km k) as [Hlt | [Heq | Hgt]]; first [ contradiction | left; nia | right; nia ].
        - intros j'. sz. destruct (Z.lt_trichotomy j' km) as [Hlt | [Heq | Hgt]]; [ right; nia | subst; lia | left; nia ].
        - intros j'. sz. destruct (Z.lt_trichotomy j' km) as [Hlt | [Heq | Hgt]]; [ right; nia | subst; lia | left; nia ]. }
      (* Mario's collided objects and usedObj are slots *)
      assert (SQ : forall v co, OW.slot_ptr pool v -> v = Vptr pool co -> Q co).
      { intros v co [-> | (j & Hj & ->)] E; [ discriminate E | ].
        unfold OW.slot_v in E. injection E as <-. exists j. split; [ exact Hj | ].
        apply Ptrofs.unsigned_repr. sz. change Ptrofs.max_unsigned with 4294967295. lia. }
      assert (QC : forall i0 co, 0 <= i0 < 4 ->
                Mem.load Mint32 m pool (u (Ptrofs.repr (km * OW.OSZ)) + COLL_OFF + 4 * i0) = Some (Vptr pool co) -> Q co).
      { intros i0 co Hi0 Lc. rewrite Ukm in Lc.
        destruct (OW.ow_mcoll _ _ _ _ _ _ _ _ _ _ _ _ C km Rkm Lg i0 Hi0) as (v & Lv & Sv).
        unfold OW.O_COLLS, COLL_OFF in *. rewrite Lc in Lv. injection Lv as <-. exact (SQ _ co Sv eq_refl). }
      assert (QU : forall uo, Mem.load Mint32 m bm USED_OFF = Some (Vptr pool uo) -> Q uo).
      { intros uo Lu. destruct (OW.ow_stale _ _ _ _ _ _ _ _ _ _ _ _ C 128 ltac:(cbn; auto)) as (v & Lv & Sv).
        unfold USED_OFF in Lu. rewrite Lu in Lv. injection Lv as <-. exact (SQ _ uo Sv eq_refl). }
      (* lvl_w: the sound blocks lvl_w reads are audio blocks *)
      assert (Lw' : lvl_w G m').
      { apply (lvl_w_unch_na G m m'); [ | | | exact Hlvl ].
        - intros b ch z Hb' Na.
          destruct (lvl_rd_cases G m b Hlvl (or_introl Hb')) as [(id & Hin & Hs) | NS].
          + apply (LGs id b Hs).
            * assert (A : forallb (fun g => negb (existsb (Pos.eqb g) UnloadOw.unl_gids)) lvl_rd_ids = true)
                by (vm_compute; reflexivity).
              exact (proj1 (negb_true_iff _) (proj1 (forallb_forall _ _) A id Hin)).
            * destruct (existsb (Pos.eqb id) UnloadObj.ws_u) eqn:Ew; [ exfalso | reflexivity ].
              assert (A : forallb (fun g => negb (existsb (Pos.eqb g) lvl_rd_ids) || existsb (Pos.eqb g) aud_ls_ids)
                            UnloadObj.ws_u = true) by (vm_compute; reflexivity).
              apply existsb_exists in Ew as (g & Hg & Eg). apply Pos.eqb_eq in Eg. subst g.
              pose proof (proj1 (forallb_forall _ _) A id Hg) as Ai. apply orb_true_iff in Ai as [Ai | Ai].
              -- apply negb_true_iff in Ai. assert (In id lvl_rd_ids) by exact Hin.
                 assert (existsb (Pos.eqb id) lvl_rd_ids = true)
                   by (apply existsb_exists; exists id; split; [ exact Hin | apply Pos.eqb_refl ]).
                 congruence.
              -- apply Na. apply existsb_exists in Ai as (g & Hg' & Eg). apply Pos.eqb_eq in Eg. subst g.
                 exists id. exact (conj Hg' Hs).
          + apply LG; try (intros ->; eapply NS; eassumption).
            intros (g & _ & Hg). exact (NS g Hg).
        - intros ab' Hab. apply (LGs _ _ Hab); vm_compute; reflexivity.
        - exact (proj2 (AudioInv.aud_w_eq G m') AI'). }
      exact (k_all_lvl_wq lp bm unl_ws HXs m m' pool (Ptrofs.repr (km * OW.OSZ)) Q
               Lmo NB PM LD (fun ch z _ => LBM ch z) Hbm_sym Nbm Bpl RGa CL FR QC QU
               Hphi (phiw_surf_apart lp bm _ m Hphi) Lw'). }
    (* ---- the A-held bit ---- *)
    assert (HD' : a_down_real bm m' = false).
    { pose proof HM as (_ & _ & R2 & _).
      rewrite <- HD. unfold a_down_real. rewrite (LBM Mptr 156).
      destruct (Mem.load Mptr m bm 156) as [v |] eqn:E; [| reflexivity ].
      destruct v; try reflexivity.
      destruct (R2 _ _ eq_refl) as (-> & _).
      rewrite (LGs _ _ Hbc_sym ltac:(vm_compute; reflexivity) ltac:(vm_compute; reflexivity)). reflexivity. }
    (* ---- obj_w ---- *)
    assert (How' : OW.obj_w G bm m').
    { exists pool, la, fl, gol, gmo, sdp, gdi, (ObjRing.upd rs i (l1 ++ l2)), (k :: fs).
      do 7 (split; [ assumption | ]).
      apply (UnloadOw.obj_w_unload G bm pool la fl gol gmo sdp gdi m m' rs fs i l1 k l2 Hp Hl S3 S4 S5 S6 S7 C
               Hi El Ina R' F' G' A').
      - intros id b Hin Hn Hs ch z. apply (LGs id b Hs Hn).
        assert (A : forallb (fun g => negb (existsb (Pos.eqb g) UnloadObj.ws_u)) PollKeep.ow_ids = true)
          by (vm_compute; reflexivity).
        exact (proj1 (negb_true_iff _) (proj1 (forallb_forall _ _) A id Hin)).
      - exact LDy.
      - intros z _. apply LBM.
      - intros s b Hin Hs ch z. apply (LGs s b Hs).
        + assert (A : forallb (fun g => negb (existsb (Pos.eqb g) UnloadOw.unl_gids)) (map BhvVM.v_s BhvVM.vm_tab) = true)
            by (vm_compute; reflexivity).
          exact (proj1 (negb_true_iff _) (proj1 (forallb_forall _ _) A s Hin)).
        + assert (A : forallb (fun g => negb (existsb (Pos.eqb g) UnloadObj.ws_u)) (map BhvVM.v_s BhvVM.vm_tab) = true)
            by (vm_compute; reflexivity).
          exact (proj1 (negb_true_iff _) (proj1 (forallb_forall _ _) A s Hin)).
      - exact Ku. }
    exact (conj Ok' (conj Phi' (conj HD' (conj Hst' How')))).
  Qed.
End UP.
