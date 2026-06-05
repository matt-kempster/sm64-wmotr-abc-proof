(* ====================================================================== *)
(* THE SUBMERGED SURFACE: Hpres_sub DISCHARGED DOWN TO ITS LEAF CALLEES   *)
(* (SPINE: consumed by the MWF-grounded capstone).                        *)
(*                                                                        *)
(* f_mario_execute_submerged_action = check_common_submerged_cancels +    *)
(* early return; m->quicksandDepth := 0.0f (a window-checked store        *)
(* through Mario's block, offset 192); TWO chase-pair stores              *)
(* (m->marioBodyState->headAngle[1] := 0 and headAngle[2] := 0 -- stores  *)
(* through the chase pointer, killed by the MWF chase rows: the root load *)
(* at bm@152 lands in SafeB, and SafeB blocks are bm-disjoint); the       *)
(* 32-arm action dispatch; return cancel.                                 *)
(*                                                                        *)
(* DispatchKit instantiation #6 -- the LAST of the seven dispatchers.     *)
(* ONE census-keyed residual remains.                                     *)
(* ====================================================================== *)

From Coq Require Import ZArith List.
From compcert Require Import Coqlib Maps AST Integers Values Events Memory
  Globalenvs Ctypes Cop Clightdefs Clight ClightBigstep Linking Errors.
From SM64.Generated Require mario mario_actions_airborne mario_actions_submerged.
From SM64.Proofs Require Import SymbolicLinking Flying Taint
  ActionValueFrame RealFrameValue RealFrameLinked AGates.
From SM64.Proofs Require Import CensusV2 EngineV2Consumer RestSurface
  AirborneSurface DispatchKit.

Import ListNotations.

(* ====================================================================== *)
(* The leaf-callee census (top-level: no lp).                             *)
(* ====================================================================== *)

(* the prologue helper + the act handlers of the dispatch table, in table
   order; coverage-checked against the PROJECTED table below. *)
Definition submerged_callee_ids : list ident :=
  mario_actions_submerged._check_common_submerged_cancels ::
  mario_actions_submerged._act_water_idle ::
  mario_actions_submerged._act_hold_water_idle ::
  mario_actions_submerged._act_water_action_end ::
  mario_actions_submerged._act_hold_water_action_end ::
  mario_actions_submerged._act_drowning ::
  mario_actions_submerged._act_backward_water_kb ::
  mario_actions_submerged._act_forward_water_kb ::
  mario_actions_submerged._act_water_death ::
  mario_actions_submerged._act_water_shocked ::
  mario_actions_submerged._act_breaststroke ::
  mario_actions_submerged._act_swimming_end ::
  mario_actions_submerged._act_flutter_kick ::
  mario_actions_submerged._act_hold_breaststroke ::
  mario_actions_submerged._act_hold_swimming_end ::
  mario_actions_submerged._act_hold_flutter_kick ::
  mario_actions_submerged._act_water_shell_swimming ::
  mario_actions_submerged._act_water_throw ::
  mario_actions_submerged._act_water_punch ::
  mario_actions_submerged._act_water_plunge ::
  mario_actions_submerged._act_caught_in_whirlpool ::
  mario_actions_submerged._act_metal_water_standing ::
  mario_actions_submerged._act_metal_water_walking ::
  mario_actions_submerged._act_metal_water_falling ::
  mario_actions_submerged._act_metal_water_fall_land ::
  mario_actions_submerged._act_metal_water_jump ::
  mario_actions_submerged._act_metal_water_jump_land ::
  mario_actions_submerged._act_hold_metal_water_standing ::
  mario_actions_submerged._act_hold_metal_water_walking ::
  mario_actions_submerged._act_hold_metal_water_falling ::
  mario_actions_submerged._act_hold_metal_water_fall_land ::
  mario_actions_submerged._act_hold_metal_water_jump ::
  mario_actions_submerged._act_hold_metal_water_jump_land :: nil.

(* ---- the chase-pair statement shape: load the marioBodyState chase
   pointer into a temp, then store 0 through it into headAngle[idx].
   This is the ONLY store class in the seven dispatchers that writes
   through a chased pointer rather than through Mario's own block. ---- *)
Definition tyBS : type := Tstruct mario._MarioBodyState noattr.
Definition tyBSp : type := tptr tyBS.

Definition chase_pair_stmt (ct : ident) (idx : int) : statement :=
  Ssequence
    (Sset ct
       (Efield (Ederef (Etempvar mario_actions_airborne._m (tptr tyMS)) tyMS)
          mario._marioBodyState tyBSp))
    (Sassign
       (Ederef
          (Ebinop Oadd
             (Efield (Ederef (Etempvar ct tyBSp) tyBS)
                mario._headAngle (tarray tshort 3))
             (Econst_int idx tint) (tptr tshort)) tshort)
       (Econst_int (Int.repr 0) tint)).

(* ---- the projections from the generated AST: the body is
   Sseq(prologue, Sseq(QSD-store, Sseq(PAIR1, Sseq(PAIR2,
   Sseq(DISPATCH, return))))). ---- *)
Definition submerged_qsd : statement :=
  match fn_body mario_actions_submerged.f_mario_execute_submerged_action with
  | Ssequence _ (Ssequence q _) => q
  | _ => Sskip
  end.

Definition submerged_pair1 : statement :=
  match fn_body mario_actions_submerged.f_mario_execute_submerged_action with
  | Ssequence _ (Ssequence _ (Ssequence p _)) => p
  | _ => Sskip
  end.

Definition submerged_pair2 : statement :=
  match fn_body mario_actions_submerged.f_mario_execute_submerged_action with
  | Ssequence _ (Ssequence _ (Ssequence _ (Ssequence p _))) => p
  | _ => Sskip
  end.

Definition submerged_dispatch_stmt : statement :=
  match fn_body mario_actions_submerged.f_mario_execute_submerged_action with
  | Ssequence _ (Ssequence _ (Ssequence _ (Ssequence _ (Ssequence d _)))) => d
  | _ => Sskip
  end.

Definition submerged_cases : labeled_statements :=
  match submerged_dispatch_stmt with
  | Ssequence _ (Sswitch _ ls) => ls
  | _ => LSnil
  end.

(* ---- the shape pins (vm_compute reflexivity over the real AST). ---- *)

Example submerged_dispatch_shape :
  submerged_dispatch_stmt =
  value_gate_stmt mario_actions_submerged._t'34 submerged_cases.
Proof. vm_compute. reflexivity. Qed.

Example submerged_pair1_shape :
  submerged_pair1
  = chase_pair_stmt mario_actions_submerged._t'36 (Int.repr 1).
Proof. vm_compute. reflexivity. Qed.

Example submerged_pair2_shape :
  submerged_pair2
  = chase_pair_stmt mario_actions_submerged._t'35 (Int.repr 2).
Proof. vm_compute. reflexivity. Qed.

Example submerged_body_shape :
  fn_body mario_actions_submerged.f_mario_execute_submerged_action =
  Ssequence
    (Ssequence
       (Scall (Some mario_actions_airborne._t'1)
          (Evar mario_actions_submerged._check_common_submerged_cancels tyAct)
          (Etempvar mario_actions_airborne._m tyMSp :: nil))
       (Sifthenelse (Etempvar mario_actions_airborne._t'1 tint)
          (Sreturn (Some (Econst_int (Int.repr 1) tint)))
          Sskip))
    (Ssequence
       submerged_qsd
       (Ssequence
          submerged_pair1
          (Ssequence
             submerged_pair2
             (Ssequence
                submerged_dispatch_stmt
                (Sreturn (Some (Etempvar mario_actions_airborne._cancel tint))))))).
Proof. vm_compute. reflexivity. Qed.

(* the selector temp and the two chase temps are not the Mario param temp *)
Example submerged_tmp_ne :
  Pos.eqb mario_actions_submerged._t'34 mario_actions_airborne._m = false.
Proof. vm_compute. reflexivity. Qed.

Example submerged_ct1_ne :
  Pos.eqb mario_actions_submerged._t'36 mario_actions_airborne._m = false.
Proof. vm_compute. reflexivity. Qed.

Example submerged_ct2_ne :
  Pos.eqb mario_actions_submerged._t'35 mario_actions_airborne._m = false.
Proof. vm_compute. reflexivity. Qed.

(* ---- the chase-root geometry pins: marioBodyState IS a tabled chase
   root, at the mario.prog-computed offset 152 (a Mptr cell). ---- *)
Example submerged_mbs_root :
  mem_id mario._marioBodyState chase_root_fields = true.
Proof. vm_compute. reflexivity. Qed.

Example submerged_mbs_off :
  field_offset (prog_comp_env mario.prog) mario._marioBodyState
    mario_state_members = OK (152, Full).
Proof. vm_compute. reflexivity. Qed.

(* ---- the censuses. ---- *)

Example submerged_arms_tabled :
  nonT_suffixes_ok (suffix_tabled_in submerged_callee_ids) submerged_cases
  = true.
Proof. vm_compute. reflexivity. Qed.

(* POSITIVE CONTROL: the census is not vacuous -- an empty table fails. *)
Example submerged_arms_census_not_vacuous :
  nonT_suffixes_ok
    (fun sl => match drop_skips sl with
               | LSnil => true
               | LScons _ _ _ => false
               end)
    submerged_cases = false.
Proof. vm_compute. reflexivity. Qed.

(* COMPLETENESS PIN: the prologue helper and every callee the PROJECTED
   table can invoke is on the hand-spelled census list. *)
Example submerged_callee_ids_complete :
  forallb (fun fid => mem_id fid submerged_callee_ids)
    (mario_actions_submerged._check_common_submerged_cancels
       :: arm_callees submerged_cases) = true.
Proof. vm_compute. reflexivity. Qed.

(* every censused callee is defined INTERNAL by the submerged TU itself *)
Example submerged_callees_internal :
  forallb (internal_in (prog_defmap mario_actions_submerged.prog))
    submerged_callee_ids = true.
Proof. vm_compute. reflexivity. Qed.

(* the projected quicksandDepth store passes the kit's recognizer (the
   byte window [192,196) misses every protected Mario cell). *)
Example submerged_qsd_ok : epi_chk submerged_qsd = true.
Proof. vm_compute. reflexivity. Qed.

(* ====================================================================== *)
(* The walk.                                                              *)
(* ====================================================================== *)

Section SubmergedSurface.
  Variable lp : Clight.program.
  Hypothesis LO_mario : linkorder mario.prog lp.
  Hypothesis LO_sub : linkorder mario_actions_submerged.prog lp.

  Variable bm : block.
  Variable NoA MWF : mem -> Prop.
  Variable SafeB : block -> Prop.

  Hypothesis HNoA_of_MWF : forall m, MWF m -> NoA m.
  Hypothesis HMWF_window : forall mm mm' ch (delta : Z) vv,
      MWF mm -> store_window_ok delta (size_chunk ch) = true ->
      Mem.store ch mm bm delta vv = Some mm' -> MWF mm'.

  (* the chase rows: instantiated by MWFReal at the capstone
     (HSafeB_not_bm / mwf_real_chase_root / mwf_real_chase). *)
  Hypothesis HSafeNotBm : forall b, SafeB b -> b <> bm.
  Hypothesis HchaseRoot : forall fld delta m b' o',
      mem_id fld chase_root_fields = true ->
      field_offset (prog_comp_env mario.prog) fld mario_state_members
        = OK (delta, Full) ->
      MWF m ->
      Mem.loadv Mptr m
        (Vptr bm (Ptrofs.add Ptrofs.zero (Ptrofs.repr delta)))
        = Some (Vptr b' o') ->
      SafeB b'.
  Hypothesis HMWF_chase : forall mm ch bsafe (d : Z) vv mm',
      MWF mm -> SafeB bsafe ->
      (forall bb oo, vv <> Vptr bb oo) ->
      Mem.store ch mm bsafe d vv = Some mm' -> MWF mm'.

  (* THE RESIDUAL: per-leaf-callee preservation, keyed by the census. *)
  Hypothesis Hpres_callees : forall fid f,
      mem_id fid submerged_callee_ids = true ->
      (prog_defmap mario_actions_submerged.prog) ! fid
        = Some (Gfun (Internal f)) ->
      body_pres lp NoA MWF bm f.

  Lemma sub_call_pres :
    forall fid, mem_id fid submerged_callee_ids = true ->
      call_pres lp bm NoA MWF fid.
  Proof.
    exact (call_pres_of_census lp bm NoA MWF HNoA_of_MWF
             mario_actions_submerged.prog submerged_callee_ids LO_sub
             submerged_callees_internal Hpres_callees).
  Qed.

  (* ================================================================== *)
  (* The chase-pair brick: the pair preserves every carried fact.       *)
  (* The root load is forced (by the execution itself) through bm@152,  *)
  (* whose value the MWF chase-root row pins into SafeB; the store      *)
  (* therefore hits a SafeB block (bm-disjoint), and the stored value   *)
  (* is a cast int (never a pointer), so the chase row carries MWF.     *)
  (* ================================================================== *)
  Lemma chase_pair_pres :
    forall ct idx e le m0 tr le' m' out,
      Pos.eqb ct mario_actions_airborne._m = false ->
      (forall b o, le ! mario_actions_airborne._m = Some (Vptr b o) ->
                   b = bm /\ o = Ptrofs.zero) ->
      exec_stmt function_entry2 (lp_ge lp) e le m0 (chase_pair_stmt ct idx)
        tr le' m' out ->
      MWF m0 -> Mem.valid_block m0 bm -> action_sat not_tainted m0 bm ->
      Mem.valid_block m' bm /\ action_sat not_tainted m' bm /\ MWF m' /\
      (forall b o, le' ! mario_actions_airborne._m = Some (Vptr b o) ->
                   b = bm /\ o = Ptrofs.zero) /\
      out = Out_normal.
  Proof.
    intros ct idx e le m0 tr le' m' out Hctm Htat Hexec HM HV HS.
    inv Hexec.
    2:{ (* the Sset ended non-normally: impossible *)
        exfalso.
        match goal with
        | Hs : exec_stmt _ _ _ _ _ (Sset _ _) _ _ _ ?oo,
          Hn : ?oo <> Out_normal |- _ => inv Hs; congruence
        end. }
    match goal with
    | Hs : exec_stmt _ _ _ _ _ (Sset _ _) _ _ _ Out_normal |- _ =>
        rename Hs into Hset
    end.
    match goal with
    | Ha : exec_stmt _ _ _ _ _ (Sassign _ _) _ _ _ _ |- _ =>
        rename Ha into Hassign
    end.
    inv Hset.
    (* --- the chase-root load: forced through bm@152, value pinned --- *)
    match goal with
    | Hev : eval_expr _ _ _ _ (Efield _ _ _) _ |- _ =>
        apply eval_expr_Efield_load in Hev;
        destruct Hev as (lf & off & bff & Hlvf & Hdf)
    end.
    pose proof Hlvf as Hpin.
    apply eval_lvalue_Efield_base in Hpin.
    destruct Hpin as (oo0 & Hbase).
    apply eval_expr_Ederef_load in Hbase.
    destruct Hbase as (lb & ob & bfb & Hlvb & _).
    apply eval_lvalue_Ederef_base in Hlvb.
    apply eval_expr_Etempvar_val in Hlvb.
    destruct (Htat _ _ Hlvb) as [E1 E2]. subst lb ob.
    destruct (mfield_lvalue_geom_lp lp LO_mario _ _ _ _ _ _
                lf off bff _ _ _ Hlvb submerged_mbs_off Hlvf)
      as (E3 & E4 & E5).
    subst lf off bff.
    inv Hdf;
      try (match goal with
           | Hacc : access_mode tyBSp = _ |- _ => discriminate Hacc
           end).
    match goal with
    | Hacc : access_mode tyBSp = By_value ?ch |- _ =>
        change (access_mode tyBSp) with (By_value Mptr) in Hacc;
        injection Hacc as <-
    end.
    match goal with
    | Hld : Mem.loadv Mptr _ _ = Some _ |- _ => rename Hld into Hldroot
    end.
    (* --- the store through the chased pointer --- *)
    inv Hassign.
    match goal with
    | Hlv1 : eval_lvalue _ _ _ _ (Ederef (Ebinop _ _ _ _) _) _ _ _ |- _ =>
        inv Hlv1
    end.
    match goal with
    | Hb : eval_expr _ _ _ _ (Ebinop _ _ _ _) (Vptr _ _) |- _ => inv Hb
    end.
    2:{ match goal with
        | HlvX : eval_lvalue _ _ _ _ (Ebinop _ _ _ _) _ _ _ |- _ => inv HlvX
        end. }
    match goal with
    | Hsem : sem_binary_operation _ Oadd _ _ _ _ _ = Some (Vptr _ _) |- _ =>
        cbn [typeof] in Hsem;
        destruct (sem_add_ptrish_block _ _ (tarray tshort 3) _ _ _ _ _
                    eq_refl Hsem)
          as (o1 & ->)
    end.
    (* the array base: same block as the chase temp's pointer *)
    match goal with
    | Hv1 : eval_expr _ _ _ _ (Efield _ _ _) (Vptr _ _) |- _ =>
        apply eval_expr_Efield_load in Hv1;
        destruct Hv1 as (lf2 & of2 & bf2 & Hlv3 & Hd3)
    end.
    destruct (deref_loc_aggregate_eq (tarray tshort 3) _ _ _ _ _ _
                (or_introl eq_refl) Hd3) as [E6 E7].
    subst lf2 of2.
    apply eval_lvalue_Efield_base in Hlv3.
    destruct Hlv3 as (o0' & Hbase2).
    apply eval_expr_Ederef_load in Hbase2.
    destruct Hbase2 as (l4 & o4 & bf4 & Hlv4 & Hd4).
    destruct (deref_loc_aggregate_eq tyBS _ _ _ _ _ _
                (or_intror eq_refl) Hd4) as [E8 E9].
    subst l4 o4.
    apply eval_lvalue_Ederef_base in Hlv4.
    apply eval_expr_Etempvar_val in Hlv4.
    rewrite PTree.gss in Hlv4. injection Hlv4 as ->.
    (* the chase row: the loaded root pointer is SafeB *)
    match goal with
    | Hroot : Mem.loadv Mptr _ _ = Some (Vptr ?bsafe _) |- _ =>
        pose proof (HchaseRoot _ _ _ _ _ submerged_mbs_root submerged_mbs_off
                      HM Hroot) as Hsafe
    end.
    (* the RHS: a cast int, never a pointer *)
    match goal with
    | Hev2 : eval_expr _ _ _ _ (Econst_int (Int.repr 0) tint) _ |- _ =>
        inv Hev2;
        try match goal with
            | Hlvc : eval_lvalue _ _ _ _ (Econst_int _ _) _ _ _ |- _ =>
                inv Hlvc
            end
    end.
    match goal with
    | Hcast : sem_cast _ _ _ _ = Some _ |- _ =>
        cbn [typeof] in Hcast;
        pose proof (sem_cast_vint_nonptr _ _ _ _ _ Hcast) as Hnoptr
    end.
    (* the assign_loc: a By_value Mint16signed store into the SafeB block *)
    match goal with
    | Has : assign_loc _ _ _ _ _ _ _ _ |- _ =>
        cbn [typeof] in Has;
        inv Has;
        try (match goal with
             | Hacc2 : access_mode tshort = _ |- _ => discriminate Hacc2
             end)
    end.
    match goal with
    | Hacc2 : access_mode tshort = By_value ?ch2 |- _ =>
        change (access_mode tshort) with (By_value Mint16signed) in Hacc2;
        injection Hacc2 as <-
    end.
    match goal with
    | Hstv : Mem.storev _ _ _ _ = Some _ |- _ =>
        unfold Mem.storev in Hstv; rename Hstv into Hst
    end.
    (* --- the posts --- *)
    split; [ eauto using Mem.store_valid_block_1 | ].
    split.
    { intros av Hload.
      rewrite (Mem.load_store_other _ _ _ _ _ _ Hst) in Hload;
        [ exact (HS av Hload)
        | left; exact (not_eq_sym (HSafeNotBm _ Hsafe)) ]. }
    split.
    { exact (HMWF_chase _ _ _ _ _ _ HM Hsafe Hnoptr Hst). }
    split.
    { intros b o Hg.
      rewrite PTree.gso in Hg
        by (intro EE; rewrite <- EE, Pos.eqb_refl in Hctm;
            discriminate Hctm).
      exact (Htat _ _ Hg). }
    reflexivity.
  Qed.

  (* ================================================================== *)
  (* THE PAYOFF: Hpres_sub itself, PROVED from the per-leaf residuals.  *)
  (* ================================================================== *)
  Theorem submerged_pres :
    body_pres lp NoA MWF bm
      mario_actions_submerged.f_mario_execute_submerged_action.
  Proof.
    intros m vargs t m' vres Hmargp Hevf HN HM HV HS.
    assert (Hmarg : marg_ok bm vargs).
    { apply Hmargp. vm_compute. reflexivity. }
    inv Hevf.
    match goal with
    | He : function_entry2 _ _ _ _ _ _ _ |- _ => rename He into Hentry
    end.
    match goal with
    | Hx : exec_stmt _ _ _ _ _ _ _ _ _ _ |- _ => rename Hx into Hbody
    end.
    match goal with
    | Hf : Mem.free_list _ _ = Some _ |- _ => rename Hf into Hfree
    end.
    inv Hentry.
    match goal with
    | Ha : alloc_variables _ _ _ _ _ _ |- _ =>
        change (fn_vars mario_actions_submerged.f_mario_execute_submerged_action)
          with (@nil (ident * type)) in Ha;
        inv Ha
    end.
    match goal with
    | Hb : bind_parameter_temps _ _ _ = Some _ |- _ => rename Hb into Hbind
    end.
    change (fn_params mario_actions_submerged.f_mario_execute_submerged_action)
      with ((mario_actions_airborne._m, tyMSp) :: nil) in Hbind.
    cbn [bind_parameter_temps] in Hbind.
    destruct vargs as [| v0 vrest]; [ discriminate Hbind | ].
    destruct vrest; [ | discriminate Hbind ].
    injection Hbind as <-.
    change (blocks_of_env (lp_ge lp) empty_env)
      with (@nil (block * Z * Z)) in Hfree.
    cbn [Mem.free_list] in Hfree. injection Hfree as <-.
    rewrite submerged_body_shape in Hbody.
    set (base := create_undef_temps
                   (fn_temps mario_actions_submerged.f_mario_execute_submerged_action))
      in *.
    (* the param temp's exact provenance (if it is a pointer, it is Mario) *)
    assert (Htat0 : forall b o,
               (PTree.set mario_actions_airborne._m v0 base)
                 ! mario_actions_airborne._m = Some (Vptr b o) ->
               b = bm /\ o = Ptrofs.zero).
    { intros b o Hg. rewrite PTree.gss in Hg. injection Hg as ->.
      cbn in Hmarg. exact Hmarg. }
    assert (Hmem1 : mem_id
                      mario_actions_submerged._check_common_submerged_cancels
                      submerged_callee_ids = true)
      by (vm_compute; reflexivity).
    inv Hbody.
    - (* prologue normal: no early cancel; the frame continues *)
      match goal with
      | H1 : exec_stmt _ _ _ _ _ (Ssequence (Scall _ _ _) (Sifthenelse _ _ _))
               _ _ _ Out_normal |- _ => rename H1 into HS1
      end.
      match goal with
      | H2 : exec_stmt _ _ _ _ _ (Ssequence submerged_qsd _) _ _ _ _ |- _ =>
          rename H2 into Hrest2
      end.
      inv HS1.
      + (* the cancel-check call, then the (not-taken) if *)
        match goal with
        | Hc : exec_stmt _ _ _ _ _ (Scall (Some _) _ _) _ _ _ _ |- _ =>
            rename Hc into Hcall1
        end.
        match goal with
        | Hi : exec_stmt _ _ _ _ _ (Sifthenelse _ _ _) _ _ _ _ |- _ =>
            rename Hi into Hif
        end.
        destruct (kit_scall_pres lp bm NoA MWF _ _ _ _ _ _ _ _ _ _ Hcall1
                    (sub_call_pres _ Hmem1) Htat0 HN HM HV HS)
          as (HV1 & HS1' & HM1 & HN1 & _ & (vr1 & ->)).
        cbn [set_opttemp] in *.
        inv Hif.
        match goal with
        | Hbr : exec_stmt _ _ _ _ _ (if ?b then _ else _) _ _ _ Out_normal |- _ =>
            destruct b; [ inv Hbr | ]
        end.
        match goal with
        | Hbr : exec_stmt _ _ _ _ _ Sskip _ _ _ Out_normal |- _ => inv Hbr
        end.
        (* the post-prologue provenance fact *)
        assert (Htat1 : forall b o,
                   (PTree.set mario_actions_airborne._t'1 vr1
                      (PTree.set mario_actions_airborne._m v0 base))
                     ! mario_actions_airborne._m = Some (Vptr b o) ->
                   b = bm /\ o = Ptrofs.zero).
        { intros b o Hg.
          rewrite PTree.gso in Hg
            by (intro HH; vm_compute in HH; discriminate HH).
          exact (Htat0 _ _ Hg). }
        (* the quicksandDepth store, then pairs + dispatch + return *)
        inv Hrest2.
        * match goal with
          | Hq : exec_stmt _ _ _ _ _ submerged_qsd _ _ _ Out_normal |- _ =>
              rename Hq into Hqsd
          end.
          match goal with
          | Hr : exec_stmt _ _ _ _ _ (Ssequence submerged_pair1 _)
                   _ _ _ _ |- _ => rename Hr into Hrest3
          end.
          destruct (epi_pres lp LO_mario bm MWF HMWF_window
                      submerged_qsd _ _ _ _ _ _ _
                      submerged_qsd_ok Htat1 Hqsd HM1 HV1 HS1')
            as (HV2 & HS2 & HM2 & Htat2 & _).
          (* the first chase pair *)
          inv Hrest3.
          -- match goal with
             | Hp : exec_stmt _ _ _ _ _ submerged_pair1 _ _ _ Out_normal |- _ =>
                 rename Hp into Hpair1
             end.
             match goal with
             | Hr : exec_stmt _ _ _ _ _ (Ssequence submerged_pair2 _)
                      _ _ _ _ |- _ => rename Hr into Hrest4
             end.
             rewrite submerged_pair1_shape in Hpair1.
             destruct (chase_pair_pres _ _ _ _ _ _ _ _ _
                         submerged_ct1_ne Htat2 Hpair1 HM2 HV2 HS2)
               as (HV3 & HS3 & HM3 & Htat3 & _).
             (* the second chase pair *)
             inv Hrest4.
             ++ match goal with
                | Hp : exec_stmt _ _ _ _ _ submerged_pair2 _ _ _ Out_normal |- _ =>
                    rename Hp into Hpair2
                end.
                match goal with
                | Hr : exec_stmt _ _ _ _ _ (Ssequence submerged_dispatch_stmt _)
                         _ _ _ _ |- _ => rename Hr into Hrest5
                end.
                rewrite submerged_pair2_shape in Hpair2.
                destruct (chase_pair_pres _ _ _ _ _ _ _ _ _
                            submerged_ct2_ne Htat3 Hpair2 HM3 HV3 HS3)
                  as (HV4 & HS4 & HM4 & Htat4 & _).
                pose proof (HNoA_of_MWF _ HM4) as HN4.
                (* the dispatch, then the return *)
                inv Hrest5.
                ** match goal with
                   | Hd : exec_stmt _ _ _ _ _ submerged_dispatch_stmt
                            _ _ _ _ |- _ => rename Hd into Hdisp
                   end.
                   match goal with
                   | Hr : exec_stmt _ _ _ _ _ (Sreturn _) _ _ _ _ |- _ =>
                       rename Hr into Hret
                   end.
                   rewrite submerged_dispatch_shape in Hdisp.
                   destruct (kit_dispatch_m_is_ptr lp _ _ _ _ _ _ _ _ Hdisp)
                     as (l & o & Hlm).
                   pose proof (Htat4 _ _ Hlm) as [-> ->].
                   destruct (value_gate_pres lp LO_mario bm NoA MWF
                               mario_actions_submerged._t'34 submerged_cases
                               submerged_callee_ids
                               submerged_tmp_ne submerged_arms_tabled
                               sub_call_pres
                               _ _ _ _ _ _ Hlm HN4 HM4 HV4 HS4 Hdisp)
                     as (HV5 & HS5 & HM5 & HN5 & _ & _).
                   inv Hret.
                   repeat split; assumption.
                ** (* dispatch ended non-normally: refuted by the walk *)
                   exfalso.
                   match goal with
                   | Hd : exec_stmt _ _ _ _ _ submerged_dispatch_stmt _ _ _ ?oo,
                     Hn : ?oo <> Out_normal |- _ => rename Hd into Hdisp
                   end.
                   rewrite submerged_dispatch_shape in Hdisp.
                   destruct (kit_dispatch_m_is_ptr lp _ _ _ _ _ _ _ _ Hdisp)
                     as (l & o & Hlm).
                   pose proof (Htat4 _ _ Hlm) as [-> ->].
                   destruct (value_gate_pres lp LO_mario bm NoA MWF
                               mario_actions_submerged._t'34 submerged_cases
                               submerged_callee_ids
                               submerged_tmp_ne submerged_arms_tabled
                               sub_call_pres
                               _ _ _ _ _ _ Hlm HN4 HM4 HV4 HS4 Hdisp)
                     as (_ & _ & _ & _ & _ & Hnorm).
                   congruence.
             ++ (* pair2 ended non-normally: refuted by the pair brick *)
                exfalso.
                match goal with
                | Hp : exec_stmt _ _ _ _ _ submerged_pair2 _ _ _ ?oo,
                  Hn : ?oo <> Out_normal |- _ => rename Hp into Hpair2
                end.
                rewrite submerged_pair2_shape in Hpair2.
                destruct (chase_pair_pres _ _ _ _ _ _ _ _ _
                            submerged_ct2_ne Htat3 Hpair2 HM3 HV3 HS3)
                  as (_ & _ & _ & _ & Hnorm).
                congruence.
          -- (* pair1 ended non-normally: refuted by the pair brick *)
             exfalso.
             match goal with
             | Hp : exec_stmt _ _ _ _ _ submerged_pair1 _ _ _ ?oo,
               Hn : ?oo <> Out_normal |- _ => rename Hp into Hpair1
             end.
             rewrite submerged_pair1_shape in Hpair1.
             destruct (chase_pair_pres _ _ _ _ _ _ _ _ _
                         submerged_ct1_ne Htat2 Hpair1 HM2 HV2 HS2)
               as (_ & _ & _ & _ & Hnorm).
             congruence.
        * (* the quicksandDepth store ended non-normally: refuted *)
          exfalso.
          match goal with
          | Hq : exec_stmt _ _ _ _ _ submerged_qsd _ _ _ ?oo,
            Hn : ?oo <> Out_normal |- _ => rename Hq into Hqsd
          end.
          destruct (epi_pres lp LO_mario bm MWF HMWF_window
                      submerged_qsd _ _ _ _ _ _ _
                      submerged_qsd_ok Htat1 Hqsd HM1 HV1 HS1')
            as (_ & _ & _ & _ & Hnorm).
          congruence.
      + (* the cancel-check call ended non-normally: Scall is Out_normal *)
        exfalso.
        match goal with
        | Hc : exec_stmt _ _ _ _ _ (Scall (Some _) _ _) _ _ _ ?oo,
          Hn : ?oo <> Out_normal |- _ => inv Hc; congruence
        end.
    - (* prologue non-normal: the early `return 1` cancel path *)
      match goal with
      | H1 : exec_stmt _ _ _ _ _ (Ssequence (Scall _ _ _) (Sifthenelse _ _ _))
               _ _ _ _ |- _ => rename H1 into HS1
      end.
      inv HS1.
      + (* call normal; the if returns *)
        match goal with
        | Hc : exec_stmt _ _ _ _ _ (Scall (Some _) _ _) _ _ _ _ |- _ =>
            rename Hc into Hcall1
        end.
        match goal with
        | Hi : exec_stmt _ _ _ _ _ (Sifthenelse _ _ _) _ _ _ _ |- _ =>
            rename Hi into Hif
        end.
        destruct (kit_scall_pres lp bm NoA MWF _ _ _ _ _ _ _ _ _ _ Hcall1
                    (sub_call_pres _ Hmem1) Htat0 HN HM HV HS)
          as (HV1 & HS1' & HM1 & HN1 & _ & (vr1 & ->)).
        inv Hif.
        match goal with
        | Hbr : exec_stmt _ _ _ _ _ (if ?b then _ else _) _ _ _ _ |- _ =>
            destruct b
        end.
        * (* return 1: memory is the post-call memory *)
          match goal with
          | Hbr : exec_stmt _ _ _ _ _ (Sreturn _) _ _ _ _ |- _ => inv Hbr
          end.
          repeat split; assumption.
        * (* skip is Out_normal: contradicts the non-normal outcome *)
          exfalso.
          match goal with
          | Hbr : exec_stmt _ _ _ _ _ Sskip _ _ _ ?oo,
            Hn : ?oo <> Out_normal |- _ => inv Hbr; congruence
          end.
      + (* the call ended non-normally: Scall is Out_normal *)
        exfalso.
        match goal with
        | Hc : exec_stmt _ _ _ _ _ (Scall (Some _) _ _) _ _ _ ?oo,
          Hn : ?oo <> Out_normal |- _ => inv Hc; congruence
        end.
  Qed.

End SubmergedSurface.
