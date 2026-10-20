(* ====================================================================== *)
(* THE BULLY-COLLISION ROWS, DISCHARGED (SPINE: premise sweep, 2026-10-20). *)
(*                                                                        *)
(* init_bully_collision_data(data, ..) and transfer_bully_speed(obj1,      *)
(* obj2) are defined in mario_step.c, which is IN the link (LO_stp), yet   *)
(* the capstones took them as two rows (Hcpx_ibcd_real : call_pres_ext_wl, *)
(* Hcpx_tbs_real : call_pres_ext_ol).  Their real bodies have no locals    *)
(* and no calls (sins / coss are gSineTable loads), and every store goes   *)
(* through one of the pointer parameters, which the rows' gates put in a   *)
(* caller stack block (local_blk).  So both rows are lemmas here.          *)
(*                                                                        *)
(* The walk is MathBodies' out-pointer walk generalised to a list of       *)
(* FROZEN pointer temps: the body never reassigns them, and a store whose  *)
(* chain root is one of them lands in that temp's block                    *)
(* (CensusV2.chain_root_l_block).                                           *)
(* ====================================================================== *)

From Coq Require Import ZArith List Lia.
From compcert Require Import Coqlib Maps AST Integers Values Events Memory
  Globalenvs Ctypes Cop Clightdefs Clight ClightBigstep Linking.
From SM64.Generated Require mario mario_step interaction.
From SM64.Proofs Require Import SymbolicLinking ActionValueFrame Taint
  RealFrameLinked AGates CensusV2 RestSurface MWFReal SpawnInit MathGeomBodies
  MathGeomGated SurfaceBodies OutParamSurface LocalVarsSurface FloorsSurface
  MathBodies.

Import ListNotations.

(* ---------------------------------------------------------------------- *)
(* The frozen-temps walk.                                                   *)
(* ---------------------------------------------------------------------- *)

Section OWF.
  Variable ge : genv.
  Variable e : env.
  Variable bm : block.
  Variable MWF : mem -> Prop.
  Variable gs : list ident.
  Variable le0 : temp_env.
  Variable store_ok : expr -> bool.
  Variable call_ok : expr -> list expr -> bool.

  Definition frozen (le : temp_env) : Prop :=
    forall g, mem_id g gs = true -> le ! g = le0 ! g.

  Hypothesis Hstore : forall lv rhs le m t le' m' out,
      store_ok lv = true -> frozen le ->
      exec_stmt function_entry2 ge e le m (Sassign lv rhs) t le' m' out ->
      ow_facts bm MWF m -> ow_facts bm MWF m'.
  Hypothesis Hcall : forall optid a al le m t le' m' out,
      call_ok a al = true -> frozen le ->
      exec_stmt function_entry2 ge e le m (Scall optid a al) t le' m' out ->
      ow_facts bm MWF m -> ow_facts bm MWF m'.

  Fixpoint owf_chk (s : statement) : bool :=
    match s with
    | Sskip | Sbreak | Scontinue | Sreturn _ => true
    | Sset id _ => negb (mem_id id gs)
    | Sassign lv _ => store_ok lv
    | Scall optid a al =>
        call_ok a al
        && match optid with Some ti => negb (mem_id ti gs) | None => true end
    | Ssequence s1 s2 => owf_chk s1 && owf_chk s2
    | Sifthenelse _ s1 s2 => owf_chk s1 && owf_chk s2
    | Sloop s1 s2 => owf_chk s1 && owf_chk s2
    | Sswitch _ sl => owf_chk_ls sl
    | _ => false
    end
  with owf_chk_ls (sl : labeled_statements) : bool :=
    match sl with
    | LSnil => true
    | LScons _ s sl' => owf_chk s && owf_chk_ls sl'
    end.

  Lemma owf_chk_ls_seq : forall sl,
      owf_chk_ls sl = true -> owf_chk (seq_of_labeled_statement sl) = true.
  Proof.
    induction sl as [| o s sl0 IH]; intros H; [reflexivity|].
    cbn in H. apply andb_prop in H as [H1 H2].
    cbn. rewrite H1. exact (IH H2).
  Qed.

  Lemma owf_chk_ls_case : forall n sl sl',
      owf_chk_ls sl = true -> select_switch_case n sl = Some sl' ->
      owf_chk_ls sl' = true.
  Proof.
    intros n sl; induction sl as [| o s sl0 IH]; intros sl' H Hsel;
      [discriminate Hsel|].
    cbn in H. apply andb_prop in H as [H1 H2].
    destruct o as [c|]; cbn in Hsel.
    - destruct (zeq c n).
      + injection Hsel as <-. cbn. rewrite H1, H2. reflexivity.
      + exact (IH sl' H2 Hsel).
    - exact (IH sl' H2 Hsel).
  Qed.

  Lemma owf_chk_ls_default : forall sl,
      owf_chk_ls sl = true -> owf_chk_ls (select_switch_default sl) = true.
  Proof.
    induction sl as [| o s sl0 IH]; intros H; [exact H|].
    cbn in H. apply andb_prop in H as [H1 H2].
    destruct o as [c|]; cbn; [exact (IH H2)|rewrite H1, H2; reflexivity].
  Qed.

  Lemma owf_chk_select : forall n sl,
      owf_chk_ls sl = true ->
      owf_chk (seq_of_labeled_statement (select_switch n sl)) = true.
  Proof.
    intros n sl H. apply owf_chk_ls_seq. unfold select_switch.
    destruct (select_switch_case n sl) eqn:E.
    - exact (owf_chk_ls_case _ _ _ H E).
    - exact (owf_chk_ls_default _ H).
  Qed.

  Lemma frozen_set : forall le id v,
      mem_id id gs = false -> frozen le -> frozen (PTree.set id v le).
  Proof.
    intros le id v Hn Hf g Hg. rewrite PTree.gso; [exact (Hf g Hg)|].
    intro E; subst; rewrite Hg in Hn; discriminate Hn.
  Qed.

  Lemma owf_walk : forall e1 le m s t le' m' out,
      exec_stmt function_entry2 ge e1 le m s t le' m' out -> e1 = e ->
      owf_chk s = true -> frozen le -> ow_facts bm MWF m ->
      ow_facts bm MWF m' /\ frozen le'.
  Proof.
    intros e1 le m s t le' m' out Hexec.
    induction Hexec; intros He Hchk Hg Hf; subst; cbn [owf_chk] in Hchk;
      try discriminate Hchk.
    - (* Sskip *) split; assumption.
    - (* Sassign *)
      split; [|exact Hg].
      lazymatch goal with Hl : eval_lvalue ?gg ?ee ?ll ?mm a1 _ _ _ |- _ =>
        assert (Hx : exec_stmt function_entry2 gg ee ll mm (Sassign a1 a2) E0 ll m' Out_normal)
          by (eapply exec_Sassign; eassumption) end.
      exact (Hstore _ _ _ _ _ _ _ _ Hchk Hg Hx Hf).
    - (* Sset *)
      split; [exact Hf|].
      apply frozen_set; [|exact Hg].
      apply negb_true_iff in Hchk. exact Hchk.
    - (* Scall *)
      apply andb_prop in Hchk as [Hc Ho].
      lazymatch goal with Hee : eval_expr ?gg ?ee ?ll ?mm a _,
                          Hfc : eval_funcall _ _ _ _ _ ?tt ?mm' ?vr |- _ =>
        assert (Hx : exec_stmt function_entry2 gg ee ll mm (Scall optid a al) tt
                       (set_opttemp optid vr ll) mm' Out_normal)
          by (eapply exec_Scall; eassumption) end.
      split; [exact (Hcall _ _ _ _ _ _ _ _ _ Hc Hg Hx Hf)|].
      destruct optid as [ti|]; cbn [set_opttemp]; [|exact Hg].
      apply frozen_set; [|exact Hg].
      apply negb_true_iff in Ho. exact Ho.
    - (* Sseq_1 *)
      apply andb_prop in Hchk as [H1 H2].
      destruct (IHHexec1 eq_refl H1 Hg Hf) as [Hf1 Hg1].
      exact (IHHexec2 eq_refl H2 Hg1 Hf1).
    - (* Sseq_2 *)
      apply andb_prop in Hchk as [H1 _].
      exact (IHHexec eq_refl H1 Hg Hf).
    - (* Sifthenelse *)
      apply andb_prop in Hchk as [H1 H2].
      apply IHHexec; [reflexivity|destruct b; assumption|exact Hg|exact Hf].
    - split; assumption.
    - split; assumption.
    - split; assumption.
    - split; assumption.
    - (* Sloop_stop1 *)
      apply andb_prop in Hchk as [H1 _].
      exact (IHHexec eq_refl H1 Hg Hf).
    - (* Sloop_stop2 *)
      apply andb_prop in Hchk as [H1 H2].
      destruct (IHHexec1 eq_refl H1 Hg Hf) as [Hf1 Hg1].
      exact (IHHexec2 eq_refl H2 Hg1 Hf1).
    - (* Sloop_loop *)
      pose proof Hchk as Hchk0.
      apply andb_prop in Hchk as [H1 H2].
      destruct (IHHexec1 eq_refl H1 Hg Hf) as [Hf1 Hg1].
      destruct (IHHexec2 eq_refl H2 Hg1 Hf1) as [Hf2 Hg2].
      exact (IHHexec3 eq_refl Hchk0 Hg2 Hf2).
    - (* Sswitch *)
      exact (IHHexec eq_refl (owf_chk_select _ _ Hchk) Hg Hf).
  Qed.
End OWF.

(* a by-value store whose chain root is one of the frozen temps *)
Definition frozen_store_ok (gs : list ident) (lv : expr) : bool :=
  match CensusV2.chain_root_l lv with
  | Some t => mem_id t gs
              && match access_mode (typeof lv) with By_value _ => true | _ => false end
  | None => false
  end.

(* the store brick: if every frozen temp's pointer (in le0) is a wholly
   store-safe block, a frozen_store_ok store keeps the walk facts *)
Lemma frozen_store_pres :
  forall (ge : genv) e bm (MWF : mem -> Prop) gs le0,
    (forall t b o, mem_id t gs = true -> le0 ! t = Some (Vptr b o) ->
       blk_pres not_tainted bm MWF b) ->
    forall lv rhs le m t le' m' out,
      frozen_store_ok gs lv = true -> frozen gs le0 le ->
      exec_stmt function_entry2 ge e le m (Sassign lv rhs) t le' m' out ->
      ow_facts bm MWF m -> ow_facts bm MWF m'.
Proof.
  intros ge e bm MWF gs le0 Hblk lv rhs le m t le' m' out Hok Hfr Hx (Hv0 & Hs0 & Hm0).
  unfold frozen_store_ok in Hok.
  destruct (CensusV2.chain_root_l lv) as [tr|] eqn:Hcr; [|discriminate Hok].
  apply andb_prop in Hok as [Ht Hac].
  pose proof Hx as Hx'. inv Hx'.
  match goal with Hl : eval_lvalue _ _ _ _ lv _ _ _ |- _ =>
    destruct (CensusV2.chain_root_l_block _ _ _ _ _ _ _ _ _ Hcr Hl) as (o0 & Hle) end.
  pose proof (Hblk _ _ _ Ht (eq_trans (eq_sym (Hfr _ Ht)) Hle)) as Hbp.
  destruct (gate_assign_pres_B MWF not_tainted bm _ o0 _ lv rhs ge _ _ m _ _ m' _
              Hbp Hcr Hac Hle Hx Hv0 Hs0 Hm0) as (Hv1 & Hs1 & Hm1 & _).
  exact (conj Hv1 (conj Hs1 Hm1)).
Qed.

Lemma stp_defmap_ibcd :
  (prog_defmap mario_step.prog) ! interaction._init_bully_collision_data
    = Some (Gfun (Internal mario_step.f_init_bully_collision_data)).
Proof. vm_compute. reflexivity. Qed.
Lemma stp_defmap_tbs :
  (prog_defmap mario_step.prog) ! interaction._transfer_bully_speed
    = Some (Gfun (Internal mario_step.f_transfer_bully_speed)).
Proof. vm_compute. reflexivity. Qed.

Definition ibcd_gs : list ident := mario_step._data :: nil.
Definition tbs_gs : list ident := mario_step._obj1 :: mario_step._obj2 :: nil.

Lemma ibcd_owf_chk :
  owf_chk ibcd_gs (frozen_store_ok ibcd_gs) (fun _ _ => false)
    (fn_body mario_step.f_init_bully_collision_data) = true.
Proof. vm_compute. reflexivity. Qed.
Lemma tbs_owf_chk :
  owf_chk tbs_gs (frozen_store_ok tbs_gs) (fun _ _ => false)
    (fn_body mario_step.f_transfer_bully_speed) = true.
Proof. vm_compute. reflexivity. Qed.

(* the body frame: a no-locals, no-calls body whose stores all go through
   frozen pointer parameters landing in wholly store-safe blocks *)
Lemma owf_body_frame :
  forall (ge : genv) (MWF : mem -> Prop) bm (f : Clight.function) gs,
    fn_vars f = nil ->
    owf_chk gs (frozen_store_ok gs) (fun _ _ => false) (fn_body f) = true ->
    forall m vargs t m' vres,
      eval_funcall function_entry2 ge m (Internal f) vargs t m' vres ->
      (forall le1, bind_parameter_temps (fn_params f) vargs
                     (create_undef_temps (fn_temps f)) = Some le1 ->
         forall g b o, mem_id g gs = true -> le1 ! g = Some (Vptr b o) ->
         blk_pres not_tainted bm MWF b) ->
      Mem.valid_block m bm -> action_sat not_tainted m bm -> MWF m ->
      Mem.valid_block m' bm /\ action_sat not_tainted m' bm /\ MWF m'.
Proof.
  intros ge MWF bm f gs Hvars Hchk m vargs t m' vres Hevf Hblk Hv Hsat Hmwf.
  inv Hevf.
  match goal with He : function_entry2 _ _ _ _ _ _ _ |- _ => rename He into Hentry end.
  match goal with Hx : exec_stmt _ _ _ _ _ _ _ _ _ _ |- _ => rename Hx into Hbody end.
  match goal with Hf : Mem.free_list _ _ = Some _ |- _ => rename Hf into Hfree end.
  inv Hentry.
  match goal with Ha : alloc_variables _ _ _ _ _ _ |- _ =>
    rewrite Hvars in Ha; inv Ha end.
  match goal with Hb : bind_parameter_temps _ _ _ = Some ?LE |- _ =>
    pose proof (Hblk LE Hb) as Hblk';
    pose proof (frozen_store_pres ge empty_env bm MWF gs LE Hblk') as Hst;
    assert (Hca : forall optid a al le m0 t0 le' m0' out,
      (fun (_ : expr) (_ : list expr) => false) a al = true ->
      frozen gs LE le ->
      exec_stmt function_entry2 ge empty_env le m0 (Scall optid a al) t0 le' m0' out ->
      ow_facts bm MWF m0 -> ow_facts bm MWF m0')
    by (intros ? ? ? ? ? ? ? ? ? Hno; cbv beta in Hno; discriminate Hno)
  end.
  destruct (owf_walk ge empty_env bm MWF gs _ _ _ Hst Hca
              _ _ _ _ _ _ _ _ Hbody eq_refl Hchk (fun _ _ => eq_refl)
              (conj Hv (conj Hsat Hmwf)))
    as ((Hv1 & Hs1 & Hm1) & _).
  change (blocks_of_env ge empty_env) with (@nil (block * Z * Z)) in Hfree.
  cbn [Mem.free_list] in Hfree. injection Hfree as <-.
  exact (conj Hv1 (conj Hs1 Hm1)).
Qed.

(* ---------------------------------------------------------------------- *)
(* The two capstone rows, at the concrete MWF_real.                         *)
(* ---------------------------------------------------------------------- *)

Section BullyRows.
  Variable lp : Clight.program.
  Variables bm bc : block.
  Variable oc0 : ptrofs.
  Variable SafeB : block -> Prop.
  Hypothesis Hbc_bm : bc <> bm.
  Hypothesis LO_stp : linkorder mario_step.prog lp.
  Hypothesis Hbc_sym : exists gid, Genv.find_symbol (lp_ge lp) gid = Some bc.

  Let MWF := MWF_real lp bm bc oc0 SafeB.
  Let NoA := fun m => ctl_a_clear m bm.

  Lemma bully_local_pres : forall b, local_blk lp bm SafeB b ->
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

  Lemma Hcpx_ibcd_proved :
    call_pres_ext_wl lp bm NoA MWF SafeB interaction._init_bully_collision_data.
  Proof.
    intros fd m0 vargs0 t0 m1 vres0 Hevf Hres Harg _ HM Hv Hsat.
    pose proof (resolves_pin_fd lp _ _ _ _ LO_stp stp_defmap_ibcd Hres) as ->.
    destruct Harg as (b0 & o0 & rest & -> & Hl0).
    destruct (owf_body_frame (lp_ge lp) MWF bm mario_step.f_init_bully_collision_data ibcd_gs eq_refl ibcd_owf_chk
                m0 _ t0 m1 vres0 Hevf) as (Hv' & Hs' & HM');
      [ | exact Hv | exact Hsat | exact HM | ].
    - intros le1 Hb g b o Hg Hle.
      unfold ibcd_gs in Hg. cbn [mem_id existsb] in Hg.
      rewrite orb_false_r in Hg. apply Pos.eqb_eq in Hg. subst g.
      change (fn_params mario_step.f_init_bully_collision_data)
        with ((mario_step._data, tptr (Tstruct mario_step._BullyCollisionData noattr))
              :: (mario_step._posX, tfloat) :: (mario_step._posZ, tfloat)
              :: (mario_step._forwardVel, tfloat) :: (mario_step._yaw, tshort)
              :: (mario_step._conversionRatio, tfloat) :: (mario_step._radius, tfloat)
              :: nil) in Hb.
      match type of Hb with bind_parameter_temps (_ :: ?ps) _ _ = _ =>
        assert (Hni : ~ In mario_step._data (var_names ps))
          by (cbn [var_names map fst];
              intros H; repeat (destruct H as [H|H]; [discriminate H|]); exact H)
      end.
      rewrite (bind_parameter_temps_head _ _ _ _ _ _ _ Hni Hb) in Hle.
      injection Hle as <- <-. exact (bully_local_pres b0 Hl0).
    - exact (conj Hv' (conj Hs' (conj HM' (mwf_real_ctl lp bm bc oc0 SafeB _ HM')))).
  Qed.

  Lemma Hcpx_tbs_proved :
    call_pres_ext_ol lp bm NoA MWF SafeB interaction._transfer_bully_speed.
  Proof.
    intros fd m0 vargs0 t0 m1 vres0 Hevf Hres Hall _ HM Hv Hsat.
    pose proof (resolves_pin_fd lp _ _ _ _ LO_stp stp_defmap_tbs Hres) as ->.
    destruct (owf_body_frame (lp_ge lp) MWF bm mario_step.f_transfer_bully_speed tbs_gs eq_refl tbs_owf_chk
                m0 _ t0 m1 vres0 Hevf) as (Hv' & Hs' & HM');
      [ | exact Hv | exact Hsat | exact HM | ].
    - intros le1 Hb g b o Hg Hle.
      change (fn_params mario_step.f_transfer_bully_speed)
        with ((mario_step._obj1, tptr (Tstruct mario_step._BullyCollisionData noattr))
              :: (mario_step._obj2, tptr (Tstruct mario_step._BullyCollisionData noattr))
              :: nil) in Hb.
      destruct vargs0 as [| a0 [| a1 [| a2 vr]]]; cbn [bind_parameter_temps] in Hb;
        try discriminate Hb.
      injection Hb as <-.
      apply bully_local_pres. apply (Hall b o).
      unfold tbs_gs in Hg. cbn [mem_id existsb] in Hg.
      apply orb_true_iff in Hg as [Hg | Hg].
      + apply Pos.eqb_eq in Hg. subst g.
        rewrite PTree.gso in Hle by discriminate. rewrite PTree.gss in Hle.
        injection Hle as ->. left. reflexivity.
      + rewrite orb_false_r in Hg. apply Pos.eqb_eq in Hg. subst g.
        rewrite PTree.gss in Hle. injection Hle as ->. right. left. reflexivity.
    - exact (conj Hv' (conj Hs' (conj HM' (mwf_real_ctl lp bm bc oc0 SafeB _ HM')))).
  Qed.
End BullyRows.
