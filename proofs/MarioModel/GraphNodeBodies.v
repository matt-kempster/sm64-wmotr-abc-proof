(* SPINE (premise sweep, 2026-10-20): the two animation-frame externals of
   set_mario_animation's callers, PROVED from their real engine/graph_node.c
   bodies now that graph_node is linked (the 19th TU, LinkedTwelve.tu_rest).
   They were the capstone rows Hgeo_real and Hocp_rai_real.

   - retrieve_animation_index(frame, attributes) (graph_node.c): its one
     store is `*attributes += 2`, through its last parameter.  The oc gate
     puts that pointer in a caller stack block (local_blk), so the store
     touches nothing the carried facts watch.
   - geo_update_animation_frame(obj, accelAssist) (graph_node.c): its two
     stores are `*accelAssist = ...`, each under `accelAssist != NULL`.  The
     geo gate pins accelAssist = NULL (Vint 0), so neither store can run:
     a store through the frozen temp needs it to hold a pointer.

   Both go through BullyBodies.owf_body_frame (no locals, no calls, every
   store's chain root is a frozen parameter temp). *)

From Coq Require Import ZArith List.
From compcert Require Import Coqlib Maps AST Integers Values Events Memory
  Globalenvs Ctypes Cop Clightdefs Clight ClightBigstep Linking.
From SM64.Generated Require mario graph_node.
From SM64.Proofs Require Import SymbolicLinking ActionValueFrame Taint
  RealFrameLinked AGates CensusV2 MWFReal MathGeomGated LocalVarsSurface OutParamSurface
  RestSurface BullyBodies.

Import ListNotations.

Lemma gn_defmap_geo :
  (prog_defmap graph_node.prog) ! mario._geo_update_animation_frame
    = Some (Gfun (Internal graph_node.f_geo_update_animation_frame)).
Proof. vm_compute. reflexivity. Qed.
Lemma gn_defmap_rai :
  (prog_defmap graph_node.prog) ! mario._retrieve_animation_index
    = Some (Gfun (Internal graph_node.f_retrieve_animation_index)).
Proof. vm_compute. reflexivity. Qed.

Definition geo_gs : list ident := graph_node._accelAssist :: nil.
Definition rai_gs : list ident := graph_node._attributes :: nil.

(* NON-VACUITY: the recognizer accepts the REAL generated bodies. *)
Lemma geo_owf_chk :
  owf_chk geo_gs (frozen_store_ok geo_gs) (fun _ _ => false)
    (fn_body graph_node.f_geo_update_animation_frame) = true.
Proof. vm_compute. reflexivity. Qed.
Lemma rai_owf_chk :
  owf_chk rai_gs (frozen_store_ok rai_gs) (fun _ _ => false)
    (fn_body graph_node.f_retrieve_animation_index) = true.
Proof. vm_compute. reflexivity. Qed.

Section GraphNodeRows.
  Variable lp : Clight.program.
  Variables bm bc : block.
  Variable oc0 : ptrofs.
  Variable SafeB : block -> Prop.
  Hypothesis Hbc_bm : bc <> bm.
  Hypothesis LO_gn : linkorder graph_node.prog lp.
  Hypothesis Hbc_sym : exists gid, Genv.find_symbol (lp_ge lp) gid = Some bc.

  Let MWF := MWF_real lp bm bc oc0 SafeB.
  Let NoA := fun m => ctl_a_clear m bm.

  Lemma gn_local_pres : forall b, local_blk lp bm SafeB b ->
      blk_pres not_tainted bm MWF b.
  Proof.
    intros b Hl.
    apply (blk_pres_local bm MWF (local_blk lp bm SafeB)).
    - intros b0 (Hb0 & _). exact Hb0.
    - intros m ch b0 d v m' (Hb0 & HnS & Hgl) Hst HM0.
      destruct Hbc_sym as (gid & Hsy).
      exact (mwf_real_local_store lp bm bc oc0 SafeB Hbc_bm m ch b0 d v m' HM0
               Hb0 (Hgl gid bc Hsy) HnS Hgl Hst).
    - exact Hl.
  Qed.

  Lemma Hgeo_proved :
    call_pres_ext_geo lp bm NoA MWF SafeB mario._geo_update_animation_frame.
  Proof.
    intros fd m0 vargs0 t0 m1 vres0 Hevf Hres Harg _ HM Hv Hsat.
    pose proof (resolves_pin_fd lp _ _ _ _ LO_gn gn_defmap_geo Hres) as ->.
    destruct Harg as (b0 & o0 & rest & -> & _).
    destruct (owf_body_frame (lp_ge lp) MWF bm graph_node.f_geo_update_animation_frame
                geo_gs eq_refl geo_owf_chk m0 _ t0 m1 vres0 Hevf) as (Hv' & Hs' & HM');
      [ | exact Hv | exact Hsat | exact HM | ].
    - intros le1 Hb g b o Hg Hle.
      unfold geo_gs in Hg. cbn [mem_id existsb] in Hg.
      rewrite orb_false_r in Hg. apply Pos.eqb_eq in Hg. subst g.
      change (fn_params graph_node.f_geo_update_animation_frame)
        with ((graph_node._obj, tptr (Tstruct graph_node._AnimInfo noattr))
              :: (graph_node._accelAssist, tptr tint) :: nil) in Hb.
      destruct rest as [| a2 vr]; cbn [bind_parameter_temps] in Hb; [ | discriminate Hb].
      injection Hb as <-. rewrite PTree.gss in Hle. discriminate Hle.
    - exact (conj Hv' (conj Hs' (conj HM' (mwf_real_ctl lp bm bc oc0 SafeB _ HM')))).
  Qed.

  Lemma Hocp_rai_proved :
    call_pres_ext_oc lp bm NoA MWF SafeB mario._retrieve_animation_index.
  Proof.
    intros fd m0 vargs0 t0 m1 vres0 Hevf Hres Harg _ HM Hv Hsat.
    pose proof (resolves_pin_fd lp _ _ _ _ LO_gn gn_defmap_rai Hres) as ->.
    destruct Harg as (bl & ol & Hlast & Hl).
    destruct (owf_body_frame (lp_ge lp) MWF bm graph_node.f_retrieve_animation_index
                rai_gs eq_refl rai_owf_chk m0 _ t0 m1 vres0 Hevf) as (Hv' & Hs' & HM');
      [ | exact Hv | exact Hsat | exact HM | ].
    - intros le1 Hb g b o Hg Hle.
      unfold rai_gs in Hg. cbn [mem_id existsb] in Hg.
      rewrite orb_false_r in Hg. apply Pos.eqb_eq in Hg. subst g.
      change (fn_params graph_node.f_retrieve_animation_index)
        with ((graph_node._frame, tint) :: (graph_node._attributes, tptr (tptr tushort))
              :: nil) in Hb.
      destruct vargs0 as [| a0 [| a1 [| a2 vr]]]; cbn [bind_parameter_temps] in Hb;
        try discriminate Hb.
      injection Hb as <-. rewrite PTree.gss in Hle. injection Hle as ->.
      cbn [last_val] in Hlast. injection Hlast as -> ->.
      exact (gn_local_pres bl Hl).
    - exact (conj Hv' (conj Hs' (conj HM' (mwf_real_ctl lp bm bc oc0 SafeB _ HM')))).
  Qed.
End GraphNodeRows.
