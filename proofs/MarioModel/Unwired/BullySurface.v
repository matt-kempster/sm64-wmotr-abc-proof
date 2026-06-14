(* ====================================================================== *)
(* BullySurface: discharge call_pres_ret_act for bully_knock_back_mario.   *)
(* The LAST interact_* leaf (created by InterSurface commit 16298bb): the   *)
(* bully knockback helper computes a bonk action into a u32 and returns it  *)
(* (fed to drop_and_set_mario_action).  Its param is named `mario` (ident   *)
(* interaction._mario = 1481224854, NOT the canonical _m=86), so the shared *)
(* _m-keyed engine cannot walk it; this is a self-contained mid-walk keyed  *)
(* to interaction._mario.  Window/chase store bricks ported (s/_m/_mario/); *)
(* chase_assign reasoning mirrored; 4 external callees (init/transfer/atan2s *)
(* /sqrtf) are accepted call_pres_ext boundary rows.                        *)
(* ====================================================================== *)

From Coq Require Import ZArith List.
From compcert Require Import Coqlib Maps AST Integers Values Events Memory
  Globalenvs Ctypes Cop Clightdefs Clight ClightBigstep Linking Errors.
From SM64.Generated Require mario mario_actions_airborne interaction.
From SM64.Proofs Require Import SymbolicLinking Flying Taint
  ActionValueFrame RealFrameValue RealFrameLinked.
From SM64.Proofs Require Import CensusV2 EngineV2Consumer RestSurface
  AirborneSurface DispatchKit FloorsSurface.
From SM64.Proofs Require Import ActWriterSurface AutomaticLeafSurface
  LocalVarsSurface OutParamSurface MWFReal InterSurface.

Import ListNotations.

Section BkbmSurface.
  Variable lp : Clight.program.
  Hypothesis LO_mario : linkorder mario.prog lp.
  Hypothesis LO_int : linkorder interaction.prog lp.

  Variable bm : block.
  Variable NoA MWF : mem -> Prop.
  Variable SafeB : block -> Prop.

  Hypothesis HNoA_of_MWF : forall m, MWF m -> NoA m.
  Hypothesis HMWF_window : forall mm mm' ch (delta : Z) vv,
      MWF mm -> store_window_ok delta (size_chunk ch) = true ->
      Mem.store ch mm bm delta vv = Some mm' -> MWF mm'.
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

  (* entry/exit stack-frame rows: allocating the BullyCollisionData locals
     and freeing them at exit leave the watched (bm) cells untouched.
     Discharged at the capstone by MWFReal (mwf_real_alloc / mwf_real_free). *)
  Hypothesis HMWF_alloc : forall m lo hi m' b,
      Mem.alloc m lo hi = (m', b) -> MWF m -> MWF m'.
  Hypothesis HMWF_free : forall m l m',
      Mem.free_list m l = Some m' -> MWF m -> MWF m'.

  (* the 4 external callees: accepted boundary rows *)
  Hypothesis Hcpx_ibcd :
    call_pres_ext lp bm NoA MWF interaction._init_bully_collision_data.
  Hypothesis Hcpx_tbs :
    call_pres_ext lp bm NoA MWF interaction._transfer_bully_speed.
  Hypothesis Hcpx_atan2s :
    call_pres_ext lp bm NoA MWF interaction._atan2s.
  Hypothesis Hcpx_sqrtf :
    call_pres_ext lp bm NoA MWF interaction._sqrtf.

  (* ---- censuses ---- *)
  Definition bk_mario : ident := interaction._mario.
  Definition bk_bonk  : ident := interaction._bonkAction.
  Definition bk_bully : ident := 1649760139%positive.
  Definition bk_cact  : list ident := bk_bully :: nil.
  (* the non-pointer-temp census: the atan2s result fed into the I32
     oMoveAngleYaw union slot. *)
  Definition bk_nids  : list ident := interaction._newBullyYaw :: nil.
  Definition bk_xids  : list ident :=
    interaction._init_bully_collision_data
      :: interaction._transfer_bully_speed
      :: interaction._atan2s :: interaction._sqrtf :: nil.

  (* ---- recognizer ---- *)
  (* chase-load: bully = mario->interactObj (chase_root_chk shape, keyed
     to bk_mario instead of the canonical _m) *)
  Definition bk_chase_load_chk (a : expr) : bool :=
    match a with
    | Efield (Ederef (Etempvar p pty) sty) fld fty =>
        Pos.eqb p bk_mario
        && proj_sumbool (type_eq pty (tptr tyMS))
        && proj_sumbool (type_eq sty tyMS)
        && mem_id fld chase_root_fields
        && is_ptr_ty fty
    | _ => false
    end.

  (* bonkAction set from an untainted integer constant *)
  Definition bk_bonk_chk (a : expr) : bool :=
    match a with Econst_int c _ => wact_const c | _ => false end.

  (* an nptr-tracked temp is seeded ONLY by a cast TO a sub-word int
     (the cast yields a Vint/stuck, never a pointer): newBullyYaw = (s16)
     of the atan2s result. *)
  Definition bk_subint_cast_chk (a : expr) : bool :=
    match a with Ecast _ t => subint_ty t | _ => false end.

  Definition bk_set_chk (id : ident) (a : expr) : bool :=
    if mem_id id bk_cact then bk_chase_load_chk a
    else if Pos.eqb id bk_bonk then bk_bonk_chk a
    else if mem_id id bk_nids then bk_subint_cast_chk a
    else negb (Pos.eqb id bk_mario).

  (* chase store through a censused chase temp: value is non-pointer
     either because the target field is a sub-word/float scalar, or
     because it is an I32 slot fed by a sub-word (I16/I8) source temp
     (whose cast is i2i, never the ptr32 passthrough). *)
  Definition bk_chase_chk (a1 a2 : expr) : bool :=
    match chain_root_l a1 with
    | Some ct =>
        mem_id ct bk_cact
        && (nonptr_scalar (typeof a1)
            || (i32_ty (typeof a1)
                && match a2 with
                   | Etempvar q _ => mem_id q bk_nids
                   | _ => false end))
    | None => false
    end.

  (* the external call: an xids callee whose return temp (if any) keeps
     ALL threaded temp invariants -- not a chase temp, not _mario, not
     bonkAction, not an nptr-tracked temp (those are only seeded by the
     sub-word cast above). *)
  Definition bk_call_chk (optid : option ident) (fid : ident) : bool :=
    mem_id fid bk_xids
    && match optid with
       | None => true
       | Some t =>
           negb (mem_id t bk_cact) && negb (Pos.eqb t bk_mario)
           && negb (Pos.eqb t bk_bonk) && negb (mem_id t bk_nids)
       end.

  Fixpoint bkbm_chk (s : statement) : bool :=
    match s with
    | Sskip | Sbreak | Scontinue => true
    | Sreturn None => true
    | Sreturn (Some a) =>
        match a with
        | Etempvar q ty =>
            Pos.eqb q bk_bonk && proj_sumbool (type_eq ty tuint)
        | _ => false
        end
    | Ssequence s1 s2 => bkbm_chk s1 && bkbm_chk s2
    | Sifthenelse _ s1 s2 => bkbm_chk s1 && bkbm_chk s2
    | Sset id a => bk_set_chk id a
    | Sassign a1 a2 =>
        safe_mfield_store bk_mario a1
        || idx_mfield_store bk_mario a1
        || idx16_mfield_store bk_mario a1
        || bk_chase_chk a1 a2
    | Scall optid (Evar fid fty) al => is_tfun fty && bk_call_chk optid fid
    | _ => false
    end.

  (* ---- vm pins ---- *)
  Lemma bkbm_chk_body :
    bkbm_chk (fn_body interaction.f_bully_knock_back_mario) = true.
  Proof. vm_compute. reflexivity. Qed.

  Lemma bkbm_pin :
    (prog_defmap interaction.prog) ! interaction._bully_knock_back_mario
    = Some (Gfun (Internal interaction.f_bully_knock_back_mario)).
  Proof. vm_compute. reflexivity. Qed.

  Lemma bkbm_ret :
    fn_return interaction.f_bully_knock_back_mario = tuint.
  Proof. vm_compute. reflexivity. Qed.

  Lemma bkbm_params :
    fn_params interaction.f_bully_knock_back_mario
    = (interaction._mario, tyMSp) :: nil.
  Proof. vm_compute. reflexivity. Qed.

  (* ================================================================== *)
  (* WINDOW STORE BRICKS (ported from ActWriterSurface idx/idx16 and    *)
  (* DispatchKit epi, s/mario_actions_airborne._m/bk_mario/).           *)
  (* ================================================================== *)

  (* indexed f32 window store: m->pos[i] = v *)
  Lemma bk_idx_assign_pres :
    forall a1 a2 e le m0 tr le' m' out,
      idx_mfield_store bk_mario a1 = true ->
      (forall b o, le ! bk_mario = Some (Vptr b o) ->
                   b = bm /\ o = Ptrofs.zero) ->
      exec_stmt function_entry2 (lp_ge lp) e le m0 (Sassign a1 a2)
        tr le' m' out ->
      MWF m0 -> Mem.valid_block m0 bm -> action_sat not_tainted m0 bm ->
      Mem.valid_block m' bm /\ action_sat not_tainted m' bm /\ MWF m' /\
      le' = le /\ out = Out_normal.
  Proof.
    intros a1 a2 e le m0 tr le' m' out Hix Htat Hexec HM HV HS.
    destruct (idx_mfield_store_shape _ _ Hix)
      as (fld & idx & pattr & -> & Hg).
    destruct (idx_geom_chk_sound _ _ _ _ Hg)
      as (delta & Hfo & Hdel0 & Hidx0 & Hwin).
    inv Hexec.
    match goal with
    | Hlv : eval_lvalue _ _ _ _ (Ederef _ _) _ _ _ |- _ => inv Hlv
    end.
    match goal with
    | Hp : eval_expr _ _ _ _ (Ebinop _ _ _ _) _ |- _ => inv Hp
    end.
    2:{ match goal with
        | Hlv2 : eval_lvalue _ _ _ _ (Ebinop _ _ _ _) _ _ _ |- _ => inv Hlv2
        end. }
    match goal with
    | Hi : eval_expr _ _ _ _ (Econst_int _ _) _ |- _ =>
        inv Hi;
        try (match goal with
             | Hlv3 : eval_lvalue _ _ _ _ (Econst_int _ _) _ _ _ |- _ =>
                 inv Hlv3
             end)
    end.
    match goal with
    | Ha : eval_expr _ _ _ _ (Efield _ _ _) _ |- _ => inv Ha
    end.
    match goal with
    | Hd : deref_loc (typeof _) _ _ _ _ _ |- _ => cbn [typeof] in Hd
    end.
    match goal with
    | Hd : deref_loc (tarray tfloat 3) _ _ _ _ _ |- _ =>
        inv Hd;
        try (match goal with
             | Hacc : access_mode (tarray tfloat 3) = _ |- _ =>
                 cbn in Hacc; discriminate Hacc
             end);
        try (match goal with
             | Hlb : load_bitfield (tarray tfloat 3) _ _ _ _ _ _ _ |- _ =>
                 inv Hlb
             end)
    end.
    match goal with
    | Hflv : eval_lvalue _ _ _ _ (Efield _ _ _) ?lf ?of ?bff |- _ =>
        pose proof Hflv as Hpin;
        apply eval_lvalue_Efield_base in Hpin;
        destruct Hpin as (oo0 & Hbase);
        apply eval_expr_Ederef_load in Hbase;
        destruct Hbase as (lb & ob & bfb & Hlvb & _);
        apply eval_lvalue_Ederef_base in Hlvb;
        apply eval_expr_Etempvar_val in Hlvb
    end.
    destruct (Htat _ _ Hlvb) as [E1 E2]. subst lb ob.
    match goal with
    | Hflv : eval_lvalue _ _ _ _ (Efield _ _ _) ?lf ?of ?bff |- _ =>
        destruct (mfield_lvalue_geom_lp lp LO_mario _ _ _ _ _ _
                    lf of bff _ _ _ Hlvb Hfo Hflv) as (E3 & E4 & _);
        subst lf of
    end.
    match goal with
    | Hsem : sem_binary_operation _ Oadd _ _ _ _ _ = Some _ |- _ =>
        cbn in Hsem; injection Hsem as <- <-
    end.
    match goal with
    | Has : assign_loc _ _ _ _ _ _ _ m' |- _ =>
        cbn [typeof] in Has;
        inv Has;
        try (match goal with
             | Hac2 : access_mode tfloat = _ |- _ =>
                 cbn in Hac2; discriminate Hac2
             end)
    end.
    match goal with
    | Hac2 : access_mode tfloat = By_value ?ch2 |- _ =>
        change (access_mode tfloat) with (By_value Mfloat32) in Hac2;
        injection Hac2 as <-
    end.
    match goal with
    | Hstv : Mem.storev _ _ _ _ = Some m' |- _ =>
        unfold Mem.storev in Hstv; rename Hstv into Hst
    end.
    assert (Hbounds : 0 <= delta + 4 * Int.signed idx /\
                      delta + 4 * Int.signed idx + 4 <= Ptrofs.max_unsigned).
    { unfold store_window_ok in Hwin.
      change (size_chunk Mfloat32) with 4 in Hwin.
      repeat (apply andb_true_iff in Hwin; destruct Hwin as [Hwin ?]).
      match goal with
      | Hb1 : (0 <=? delta + 4 * Int.signed idx)%Z = true,
        Hb2 : (delta + 4 * Int.signed idx + _ <=? _)%Z = true |- _ =>
          apply Z.leb_le in Hb1; apply Z.leb_le in Hb2; lia
      end. }
    destruct Hbounds as [Hb0 Hb1].
    assert (Eofs : Ptrofs.unsigned
                     (Ptrofs.add (Ptrofs.add Ptrofs.zero (Ptrofs.repr delta))
                        (Ptrofs.mul (Ptrofs.repr 4) (Ptrofs.of_ints idx)))
                   = delta + 4 * Int.signed idx).
    { rewrite Ptrofs.add_zero_l.
      unfold Ptrofs.of_ints.
      unfold Ptrofs.mul.
      rewrite (Ptrofs.unsigned_repr 4) by lia.
      rewrite (Ptrofs.unsigned_repr (Int.signed idx)) by lia.
      unfold Ptrofs.add.
      rewrite (Ptrofs.unsigned_repr delta) by lia.
      rewrite (Ptrofs.unsigned_repr (4 * Int.signed idx)) by lia.
      apply Ptrofs.unsigned_repr. lia. }
    rewrite Eofs in Hst.
    split; [ eauto using Mem.store_valid_block_1 | ].
    split.
    { intros av Hload.
      rewrite (Mem.load_store_other _ _ _ _ _ _ Hst) in Hload;
        [ exact (HS av Hload) | right ].
      unfold store_window_ok in Hwin.
      apply andb_true_iff in Hwin as [Hwin _].
      apply andb_true_iff in Hwin as [Hwin _].
      apply andb_true_iff in Hwin as [Hwin Hw12].
      apply orb_true_iff in Hw12 as [Hw12 | Hw12]; apply Z.leb_le in Hw12;
        [ right; exact Hw12 | left; cbn [size_chunk]; lia ]. }
    split.
    { exact (HMWF_window _ _ _ _ _ HM Hwin Hst). }
    split; reflexivity.
  Qed.

  (* indexed s16 window store: m->faceAngle[i] = v *)
  Lemma bk_idx16_assign_pres :
    forall a1 a2 e le m0 tr le' m' out,
      idx16_mfield_store bk_mario a1 = true ->
      (forall b o, le ! bk_mario = Some (Vptr b o) ->
                   b = bm /\ o = Ptrofs.zero) ->
      exec_stmt function_entry2 (lp_ge lp) e le m0 (Sassign a1 a2)
        tr le' m' out ->
      MWF m0 -> Mem.valid_block m0 bm -> action_sat not_tainted m0 bm ->
      Mem.valid_block m' bm /\ action_sat not_tainted m' bm /\ MWF m' /\
      le' = le /\ out = Out_normal.
  Proof.
    intros a1 a2 e le m0 tr le' m' out Hix Htat Hexec HM HV HS.
    destruct (idx16_mfield_store_shape _ _ Hix)
      as (fld & idx & pattr & -> & Hg).
    destruct (idx_geom_chk_sound _ _ _ _ Hg)
      as (delta & Hfo & Hdel0 & Hidx0 & Hwin).
    inv Hexec.
    match goal with
    | Hlv : eval_lvalue _ _ _ _ (Ederef _ _) _ _ _ |- _ => inv Hlv
    end.
    match goal with
    | Hp : eval_expr _ _ _ _ (Ebinop _ _ _ _) _ |- _ => inv Hp
    end.
    2:{ match goal with
        | Hlv2 : eval_lvalue _ _ _ _ (Ebinop _ _ _ _) _ _ _ |- _ => inv Hlv2
        end. }
    match goal with
    | Hi : eval_expr _ _ _ _ (Econst_int _ _) _ |- _ =>
        inv Hi;
        try (match goal with
             | Hlv3 : eval_lvalue _ _ _ _ (Econst_int _ _) _ _ _ |- _ =>
                 inv Hlv3
             end)
    end.
    match goal with
    | Ha : eval_expr _ _ _ _ (Efield _ _ _) _ |- _ => inv Ha
    end.
    match goal with
    | Hd : deref_loc (typeof _) _ _ _ _ _ |- _ => cbn [typeof] in Hd
    end.
    match goal with
    | Hd : deref_loc (tarray tshort 3) _ _ _ _ _ |- _ =>
        inv Hd;
        try (match goal with
             | Hacc : access_mode (tarray tshort 3) = _ |- _ =>
                 cbn in Hacc; discriminate Hacc
             end);
        try (match goal with
             | Hlb : load_bitfield (tarray tshort 3) _ _ _ _ _ _ _ |- _ =>
                 inv Hlb
             end)
    end.
    match goal with
    | Hflv : eval_lvalue _ _ _ _ (Efield _ _ _) ?lf ?of ?bff |- _ =>
        pose proof Hflv as Hpin;
        apply eval_lvalue_Efield_base in Hpin;
        destruct Hpin as (oo0 & Hbase);
        apply eval_expr_Ederef_load in Hbase;
        destruct Hbase as (lb & ob & bfb & Hlvb & _);
        apply eval_lvalue_Ederef_base in Hlvb;
        apply eval_expr_Etempvar_val in Hlvb
    end.
    destruct (Htat _ _ Hlvb) as [E1 E2]. subst lb ob.
    match goal with
    | Hflv : eval_lvalue _ _ _ _ (Efield _ _ _) ?lf ?of ?bff |- _ =>
        destruct (mfield_lvalue_geom_lp lp LO_mario _ _ _ _ _ _
                    lf of bff _ _ _ Hlvb Hfo Hflv) as (E3 & E4 & _);
        subst lf of
    end.
    match goal with
    | Hsem : sem_binary_operation _ Oadd _ _ _ _ _ = Some _ |- _ =>
        cbn in Hsem; injection Hsem as <- <-
    end.
    match goal with
    | Has : assign_loc _ _ _ _ _ _ _ m' |- _ =>
        cbn [typeof] in Has;
        inv Has;
        try (match goal with
             | Hac2 : access_mode tshort = _ |- _ =>
                 cbn in Hac2; discriminate Hac2
             end)
    end.
    match goal with
    | Hac2 : access_mode tshort = By_value ?ch2 |- _ =>
        change (access_mode tshort) with (By_value Mint16signed) in Hac2;
        injection Hac2 as <-
    end.
    match goal with
    | Hstv : Mem.storev _ _ _ _ = Some m' |- _ =>
        unfold Mem.storev in Hstv; rename Hstv into Hst
    end.
    assert (Hbounds : 0 <= delta + 2 * Int.signed idx /\
                      delta + 2 * Int.signed idx + 2 <= Ptrofs.max_unsigned).
    { unfold store_window_ok in Hwin.
      change (size_chunk Mint16signed) with 2 in Hwin.
      repeat (apply andb_true_iff in Hwin; destruct Hwin as [Hwin ?]).
      match goal with
      | Hb1 : (0 <=? delta + 2 * Int.signed idx)%Z = true,
        Hb2 : (delta + 2 * Int.signed idx + _ <=? _)%Z = true |- _ =>
          apply Z.leb_le in Hb1; apply Z.leb_le in Hb2; lia
      end. }
    destruct Hbounds as [Hb0 Hb1].
    assert (Eofs : Ptrofs.unsigned
                     (Ptrofs.add (Ptrofs.add Ptrofs.zero (Ptrofs.repr delta))
                        (Ptrofs.mul (Ptrofs.repr 2) (Ptrofs.of_ints idx)))
                   = delta + 2 * Int.signed idx).
    { rewrite Ptrofs.add_zero_l.
      unfold Ptrofs.of_ints.
      unfold Ptrofs.mul.
      rewrite (Ptrofs.unsigned_repr 2) by lia.
      rewrite (Ptrofs.unsigned_repr (Int.signed idx)) by lia.
      unfold Ptrofs.add.
      rewrite (Ptrofs.unsigned_repr delta) by lia.
      rewrite (Ptrofs.unsigned_repr (2 * Int.signed idx)) by lia.
      apply Ptrofs.unsigned_repr. lia. }
    rewrite Eofs in Hst.
    split; [ eauto using Mem.store_valid_block_1 | ].
    split.
    { intros av Hload.
      rewrite (Mem.load_store_other _ _ _ _ _ _ Hst) in Hload;
        [ exact (HS av Hload) | right ].
      unfold store_window_ok in Hwin.
      apply andb_true_iff in Hwin as [Hwin _].
      apply andb_true_iff in Hwin as [Hwin _].
      apply andb_true_iff in Hwin as [Hwin Hw12].
      apply orb_true_iff in Hw12 as [Hw12 | Hw12]; apply Z.leb_le in Hw12;
        [ right; exact Hw12 | left; cbn [size_chunk]; lia ]. }
    split.
    { exact (HMWF_window _ _ _ _ _ HM Hwin Hst). }
    split; reflexivity.
  Qed.

  (* scalar window store: m->forwardVel = v *)
  Lemma bk_safe_assign_pres :
    forall a1 a2 e le m0 tr le' m' out,
      safe_mfield_store bk_mario a1 = true ->
      (forall b o, le ! bk_mario = Some (Vptr b o) ->
                   b = bm /\ o = Ptrofs.zero) ->
      exec_stmt function_entry2 (lp_ge lp) e le m0 (Sassign a1 a2)
        tr le' m' out ->
      MWF m0 -> Mem.valid_block m0 bm -> action_sat not_tainted m0 bm ->
      Mem.valid_block m' bm /\ action_sat not_tainted m' bm /\ MWF m' /\
      le' = le /\ out = Out_normal.
  Proof.
    intros a1 a2 e le m0 tr le' m' out Hsf Htat Hexec HM HV HS.
    inv Hexec.
    destruct (safe_mfield_store_shape _ _ Hsf) as (fld & fty & -> & Hgeo).
    destruct (mfield_geom_chk_sound _ _ Hgeo) as (delta & ch & Hfo & Hac & Hwin).
    match goal with
    | Hlv0 : eval_lvalue _ _ _ _ (Efield _ _ _) _ _ _ |- _ =>
        pose proof Hlv0 as Hpin;
        apply eval_lvalue_Efield_base in Hpin;
        destruct Hpin as (oo0 & Hbase);
        apply eval_expr_Ederef_load in Hbase;
        destruct Hbase as (lb & ob & bfb & Hlvb & _);
        apply eval_lvalue_Ederef_base in Hlvb;
        apply eval_expr_Etempvar_val in Hlvb
    end.
    destruct (Htat _ _ Hlvb) as [E1 E2]. subst lb ob.
    match goal with
    | Hlv0 : eval_lvalue _ _ _ _ (Efield _ _ _) ?loc ?ofs ?bf |- _ =>
        destruct (mfield_lvalue_geom_lp lp LO_mario _ _ _ _ _ _
                    loc ofs bf _ _ _ Hlvb Hfo Hlv0) as (E3 & E4 & E5);
        subst loc ofs bf
    end.
    match goal with
    | Has : assign_loc _ _ _ _ _ _ _ m' |- _ =>
        rewrite Ptrofs.add_zero_l in Has;
        cbn [typeof] in Has;
        inv Has;
        try (match goal with Hac2 : access_mode fty = _ |- _ =>
               rewrite Hac in Hac2; discriminate Hac2 end)
    end.
    match goal with
    | Hsv0 : Mem.storev _ _ _ _ = Some m',
      Hac2 : access_mode fty = By_value ?ch2 |- _ =>
        rewrite Hac in Hac2; injection Hac2 as <-;
        unfold Mem.storev in Hsv0;
        rewrite Ptrofs.unsigned_repr in Hsv0
    end.
    2:{ unfold store_window_ok in Hwin.
        repeat (apply andb_true_iff in Hwin; destruct Hwin as [Hwin ?]).
        match goal with
        | Hb1 : (0 <=? delta) = true, Hb2 : (delta + _ <=? _) = true,
          Hb3 : (0 <? _) = true |- _ =>
            apply Z.leb_le in Hb1; apply Z.leb_le in Hb2;
            apply Z.ltb_lt in Hb3; lia
        end. }
    match goal with
    | Hsv : Mem.store _ _ _ _ _ = Some m' |- _ =>
        split; [ eauto using Mem.store_valid_block_1 | split ];
        [ intros av Hload;
          rewrite (Mem.load_store_other _ _ _ _ _ _ Hsv) in Hload;
          [ exact (HS av Hload) | right ]
        | split;
          [ exact (HMWF_window _ _ _ _ _ HM Hwin Hsv)
          | split; reflexivity ] ]
    end.
    unfold store_window_ok in Hwin.
    apply andb_true_iff in Hwin as [Hwin Hw148].
    apply andb_true_iff in Hwin as [Hwin Hw136].
    apply andb_true_iff in Hwin as [Hwin Hw12].
    apply orb_true_iff in Hw12 as [Hw12 | Hw12]; apply Z.leb_le in Hw12;
      [ right; exact Hw12 | left; cbn [size_chunk]; lia ].
  Qed.

  (* ================================================================== *)
  (* CHASE-LOAD: bully = mario->interactObj forces the load through      *)
  (* (bm, interactObj_off), pinned SafeB by HchaseRoot.  Ported from     *)
  (* ActWriterSurface.chase_root_set_sound (s/_m/bk_mario/).             *)
  (* ================================================================== *)
  Lemma bk_chase_load_shape : forall a,
      bk_chase_load_chk a = true ->
      exists fld pt pa,
        a = Efield (Ederef (Etempvar bk_mario (tptr tyMS)) tyMS) fld
              (Tpointer pt pa) /\
        mem_id fld chase_root_fields = true.
  Proof.
    intros a H.
    destruct a as [ | | | | | | | | | | | ab fld fty | | ];
      try discriminate H.
    destruct ab as [ | | | | | | bb sty | | | | | | | ]; try discriminate H.
    destruct bb as [ | | | | | p pty | | | | | | | | ]; try discriminate H.
    cbn [bk_chase_load_chk] in H.
    apply andb_prop in H as [H Hptr].
    apply andb_prop in H as [H Hfld].
    apply andb_prop in H as [H Hsty].
    apply andb_prop in H as [Hp Hpty].
    apply Pos.eqb_eq in Hp. subst p.
    destruct (type_eq pty (tptr tyMS)); [ subst pty | discriminate Hpty ].
    destruct (type_eq sty tyMS); [ subst sty | discriminate Hsty ].
    destruct fty as [ | | | | pt pa | | | | ]; try discriminate Hptr.
    exists fld, pt, pa. split; [ reflexivity | exact Hfld ].
  Qed.

  Lemma bk_chase_load_sound :
    forall a e le m v,
      bk_chase_load_chk a = true ->
      (forall b o, le ! bk_mario = Some (Vptr b o) ->
                   b = bm /\ o = Ptrofs.zero) ->
      MWF m ->
      eval_expr (lp_ge lp) e le m a v ->
      forall b o, v = Vptr b o -> SafeB b.
  Proof.
    intros a e le m v Hck Htat HM Hev b o ->.
    destruct (bk_chase_load_shape _ Hck) as (fld & pt & pa & -> & Hfld).
    destruct (chase_root_field_offset _ Hfld) as (delta & Hfo).
    inv Hev.
    match goal with
    | Hlv0 : eval_lvalue _ _ _ _ (Efield _ _ _) _ _ _ |- _ =>
        pose proof Hlv0 as Hpin;
        apply eval_lvalue_Efield_base in Hpin;
        destruct Hpin as (oo0 & Hbase);
        apply eval_expr_Ederef_load in Hbase;
        destruct Hbase as (lb & ob & bfb & Hlvb & _);
        apply eval_lvalue_Ederef_base in Hlvb;
        apply eval_expr_Etempvar_val in Hlvb
    end.
    destruct (Htat _ _ Hlvb) as [E1 E2]. subst lb ob.
    match goal with
    | Hlv0 : eval_lvalue _ _ _ _ (Efield _ _ _) ?loc ?ofs ?bf |- _ =>
        destruct (mfield_lvalue_geom_lp lp LO_mario _ _ _ _ _ _
                    loc ofs bf _ _ _ Hlvb Hfo Hlv0)
          as (E3 & E4 & E5);
        subst loc ofs bf
    end.
    match goal with
    | Hd : deref_loc _ _ _ _ _ _ |- _ =>
        cbn [typeof] in Hd; inv Hd
    end.
    - match goal with
      | Hac : access_mode _ = By_value _ |- _ =>
          change (access_mode (Tpointer pt pa)) with (By_value Mptr)
            in Hac;
          injection Hac as <-
      end.
      match goal with
      | Hld : Mem.loadv Mptr _ _ = Some (Vptr _ _) |- _ =>
          exact (HchaseRoot _ _ _ _ _ Hfld Hfo HM Hld)
      end.
    - match goal with
      | Hac : access_mode _ = By_reference |- _ =>
          cbn in Hac; discriminate Hac
      end.
    - match goal with
      | Hac : access_mode _ = By_copy |- _ =>
          cbn in Hac; discriminate Hac
      end.
  Qed.

  (* ================================================================== *)
  (* CHASE STORE: bully->field = v.  The stored value is provably non-    *)
  (* pointer either because the target field is a sub-word/float scalar   *)
  (* (the cast yields a Vint/Vsingle), or because the source is the       *)
  (* nptr-tracked atan2s result (fed through an I32 union slot whose       *)
  (* ptr32 passthrough cast leaves the value verbatim).  The store lands  *)
  (* in the chase temp's SafeB block (chain_root_l_block), absorbed by     *)
  (* HMWF_chase.                                                          *)
  (* ================================================================== *)
  Lemma bk_chase_store_pres :
    forall a1 a2 e le m0 tr le' m' out,
      bk_chase_chk a1 a2 = true ->
      chase_inv SafeB bk_cact le ->
      nptr_inv bk_nids le ->
      exec_stmt function_entry2 (lp_ge lp) e le m0 (Sassign a1 a2)
        tr le' m' out ->
      MWF m0 -> Mem.valid_block m0 bm -> action_sat not_tainted m0 bm ->
      Mem.valid_block m' bm /\ action_sat not_tainted m' bm /\ MWF m' /\
      le' = le /\ out = Out_normal.
  Proof.
    intros a1 a2 e le m0 tr le' m' out Hck Hch Hnpi Hexec HM HV HS.
    unfold bk_chase_chk in Hck.
    destruct (chain_root_l a1) as [ct|] eqn:Hcr; [ | discriminate Hck ].
    apply andb_prop in Hck as [Hctm Hrhs].
    inv Hexec.
    match goal with
    | Hlv : eval_lvalue _ _ _ _ a1 _ _ _ |- _ =>
        destruct (chain_root_l_block _ _ _ _ _ _ _ _ _ Hcr Hlv)
          as (o0 & Hlet)
    end.
    pose proof (Hch _ Hctm _ _ Hlet) as Hsafe.
    pose proof (HSafeNotBm _ Hsafe) as Hneq.
    match goal with
    | Hcast0 : sem_cast _ _ _ _ = Some ?vw |- _ =>
        assert (Hnp : forall bb oo, vw <> Vptr bb oo)
    end.
    { apply orb_true_iff in Hrhs as [Hnps | Hsub].
      - (* sub-word / float field: the cast TO the scalar field is nonptr *)
        match goal with
        | Hcast0 : sem_cast _ _ _ _ = Some _ |- _ =>
            exact (sem_cast_to_nonptr_scalar _ _ _ _ _ Hnps Hcast0)
        end.
      - (* I32 slot fed by the nptr-tracked atan2s result *)
        apply andb_prop in Hsub as [_ Ha2].
        destruct a2 as [ | | | | | q qty | | | | | | | | ];
          try discriminate Ha2.
        match goal with
        | Hev2 : eval_expr _ _ _ _ (Etempvar q qty) _,
          Hcast0 : sem_cast _ _ _ _ = Some _ |- _ =>
            pose proof (eval_expr_Etempvar_val _ _ _ _ _ _ _ Hev2) as Hq;
            exact (sem_cast_nonptr_pres _ _ _ _ _ Hcast0
                     (Hnpi _ Ha2 _ Hq))
        end. }
    match goal with
    | Has : assign_loc _ _ _ _ _ _ _ m' |- _ => inv Has
    end.
    - match goal with
      | Hsv0 : Mem.storev _ _ _ _ = Some m' |- _ =>
          unfold Mem.storev in Hsv0
      end.
      match goal with
      | Hsv : Mem.store _ _ _ _ _ = Some m' |- _ =>
          split; [ eauto using Mem.store_valid_block_1 | split ];
          [ intros av Hload;
            rewrite (Mem.load_store_other _ _ _ _ _ _ Hsv) in Hload;
            [ exact (HS av Hload) | left; exact (not_eq_sym Hneq) ]
          | split;
            [ exact (HMWF_chase _ _ _ _ _ _ HM Hsafe Hnp Hsv)
            | split; reflexivity ] ]
      end.
    - exfalso. exact (Hnp _ _ eq_refl).
    - match goal with
      | Hsb : store_bitfield _ _ _ _ _ _ _ _ _ _ |- _ => inv Hsb
      end.
      match goal with
      | Hsv0 : Mem.storev _ _ _ (Vint _) = Some m' |- _ =>
          unfold Mem.storev in Hsv0
      end.
      match goal with
      | Hsv : Mem.store _ _ _ _ (Vint _) = Some m' |- _ =>
          split; [ eauto using Mem.store_valid_block_1 | split ];
          [ intros av Hload;
            rewrite (Mem.load_store_other _ _ _ _ _ _ Hsv) in Hload;
            [ exact (HS av Hload) | left; exact (not_eq_sym Hneq) ]
          | split;
            [ refine (HMWF_chase _ _ _ _ _ _ HM Hsafe _ Hsv);
              intros bb oo E; discriminate E
            | split; reflexivity ] ]
      end.
  Qed.

  (* ================================================================== *)
  (* THE EXTERNAL-CALL BRICK + xids dispatch.                            *)
  (* ================================================================== *)
  Lemma bk_xids_pres : forall fid,
      mem_id fid bk_xids = true -> call_pres_ext lp bm NoA MWF fid.
  Proof.
    intros fid H. unfold bk_xids in H. cbn [mem_id] in H.
    apply orb_true_iff in H as [H | H];
      [ apply Pos.eqb_eq in H; subst fid; exact Hcpx_ibcd | ].
    apply orb_true_iff in H as [H | H];
      [ apply Pos.eqb_eq in H; subst fid; exact Hcpx_tbs | ].
    apply orb_true_iff in H as [H | H];
      [ apply Pos.eqb_eq in H; subst fid; exact Hcpx_atan2s | ].
    apply orb_true_iff in H as [H | H];
      [ apply Pos.eqb_eq in H; subst fid; exact Hcpx_sqrtf | ].
    discriminate H.
  Qed.

  Lemma bk_scall_ext_pres :
    forall optid fid fty al e le0 m0 tr le1 m1 out0,
      is_tfun fty = true ->
      e ! fid = None ->
      call_pres_ext lp bm NoA MWF fid ->
      exec_stmt function_entry2 (lp_ge lp) e le0 m0
        (Scall optid (Evar fid fty) al) tr le1 m1 out0 ->
      carried bm NoA MWF m0 ->
      carried bm NoA MWF m1 /\ out0 = Out_normal /\
      exists vres, le1 = set_opttemp optid vres le0.
  Proof.
    intros optid fid fty al e le0 m0 tr le1 m1 out0 Htf He Hcp Hexec Hc.
    destruct Hc as (HV & HS & HM & HN).
    destruct fty; try discriminate Htf. clear Htf.
    inv Hexec.
    match goal with
    | Hv : eval_expr _ _ _ _ (Evar _ _) _ |- _ =>
        destruct (eval_Evar_funct lp _ _ _ _ _ _ _ _ He Hv)
          as (bf & Hsym & ->)
    end.
    match goal with
    | Hevf : eval_funcall _ _ _ _ ?vargs _ _ _,
      Hff : Genv.find_funct _ (Vptr bf Ptrofs.zero) = Some _ |- _ =>
        destruct (Hcp _ _ _ _ _ _ Hevf
                    ltac:(red; exists bf; split; assumption)
                    HN HM HV HS) as (HV' & HS' & HM' & HN')
    end.
    split;
      [ split; [ exact HV' | split; [ exact HS'
               | split; [ exact HM' | exact HN' ] ] ]
      | split; [ reflexivity | eexists; reflexivity ] ].
  Qed.

  (* ================================================================== *)
  (* THE WALK: an exec_stmt induction threading carried + the _mario     *)
  (* provenance + chase_inv + bonk_inv (untainted bonkAction) +          *)
  (* nptr_inv (non-pointer newBullyYaw) + the normal-return shape.       *)
  (* ================================================================== *)
  Definition bonk_inv (le : temp_env) : Prop :=
    forall v, le ! bk_bonk = Some v -> untainted_scalar v.

  Lemma bkbm_walk_pres :
    forall s e le m0 tr le' m' out,
      exec_stmt function_entry2 (lp_ge lp) e le m0 s tr le' m' out ->
      bkbm_chk s = true ->
      (forall fid, mem_id fid bk_xids = true -> e ! fid = None) ->
      (forall b o, le ! bk_mario = Some (Vptr b o) ->
                   b = bm /\ o = Ptrofs.zero) ->
      chase_inv SafeB bk_cact le ->
      bonk_inv le ->
      nptr_inv bk_nids le ->
      carried bm NoA MWF m0 ->
      carried bm NoA MWF m' /\
      (forall b o, le' ! bk_mario = Some (Vptr b o) ->
                   b = bm /\ o = Ptrofs.zero) /\
      chase_inv SafeB bk_cact le' /\
      bonk_inv le' /\
      nptr_inv bk_nids le' /\
      wret_ok true out.
  Proof.
    intros s e le m0 tr le' m' out Hexec.
    induction Hexec; intros Hchk Hxe Hm Hch Hbonk Hnpi Hc.
    - (* Sskip *)
      exact (conj Hc (conj Hm (conj Hch (conj Hbonk (conj Hnpi I))))).
    - (* Sassign *)
      cbn [bkbm_chk] in Hchk.
      assert (Hex : exec_stmt function_entry2 (lp_ge lp) e le m
                      (Sassign a1 a2) E0 le m' Out_normal)
        by (econstructor; eauto).
      destruct Hc as (HV & HS & HM & HN).
      apply orb_true_iff in Hchk as [Hchk | Hchase].
      apply orb_true_iff in Hchk as [Hchk | Hix16].
      apply orb_true_iff in Hchk as [Hsf | Hix].
      + destruct (bk_safe_assign_pres _ _ _ _ _ _ _ _ _ Hsf Hm Hex HM HV HS)
          as (HV' & HS' & HM' & _ & _).
        exact (conj (conj HV' (conj HS' (conj HM' (HNoA_of_MWF _ HM'))))
                 (conj Hm (conj Hch (conj Hbonk (conj Hnpi I))))).
      + destruct (bk_idx_assign_pres _ _ _ _ _ _ _ _ _ Hix Hm Hex HM HV HS)
          as (HV' & HS' & HM' & _ & _).
        exact (conj (conj HV' (conj HS' (conj HM' (HNoA_of_MWF _ HM'))))
                 (conj Hm (conj Hch (conj Hbonk (conj Hnpi I))))).
      + destruct (bk_idx16_assign_pres _ _ _ _ _ _ _ _ _ Hix16 Hm Hex HM HV HS)
          as (HV' & HS' & HM' & _ & _).
        exact (conj (conj HV' (conj HS' (conj HM' (HNoA_of_MWF _ HM'))))
                 (conj Hm (conj Hch (conj Hbonk (conj Hnpi I))))).
      + destruct (bk_chase_store_pres _ _ _ _ _ _ _ _ _ Hchase Hch Hnpi Hex
                    HM HV HS) as (HV' & HS' & HM' & _ & _).
        exact (conj (conj HV' (conj HS' (conj HM' (HNoA_of_MWF _ HM'))))
                 (conj Hm (conj Hch (conj Hbonk (conj Hnpi I))))).
    - (* Sset *)
      cbn [bkbm_chk] in Hchk. unfold bk_set_chk in Hchk.
      destruct (mem_id id bk_cact) eqn:Ecact.
      + (* chase-load: id = bully *)
        refine (conj Hc (conj _ (conj _ (conj _ (conj _ I))))).
        * intros b o Hg.
          rewrite PTree.gso in Hg
            by (intro EE; subst id; vm_compute in Ecact; discriminate Ecact).
          exact (Hm b o Hg).
        * intros t Ht b o Hg.
          destruct (Pos.eqb t id) eqn:Eti.
          { apply Pos.eqb_eq in Eti; subst t.
            rewrite PTree.gss in Hg. injection Hg as Hgv.
            destruct Hc as (_ & _ & HM & _).
            eapply bk_chase_load_sound.
            - exact Hchk.
            - exact Hm.
            - exact HM.
            - eassumption.
            - exact Hgv. }
          { apply Pos.eqb_neq in Eti.
            rewrite PTree.gso in Hg by congruence.
            exact (Hch t Ht b o Hg). }
        * intros w Hg.
          rewrite PTree.gso in Hg
            by (intro EE; subst id; vm_compute in Ecact; discriminate Ecact).
          exact (Hbonk w Hg).
        * intros t Ht vv Hg.
          rewrite PTree.gso in Hg
            by (unfold bk_nids, mem_id in Ht; cbn [existsb] in Ht;
                rewrite orb_false_r in Ht; apply Pos.eqb_eq in Ht; subst t;
                intro EE; subst id; vm_compute in Ecact; discriminate Ecact).
          exact (Hnpi t Ht vv Hg).
      + destruct (Pos.eqb id bk_bonk) eqn:Ebonk.
        * (* bonk const *)
          apply Pos.eqb_eq in Ebonk; subst id.
          unfold bk_bonk_chk in Hchk.
          destruct a as [ c cty | | | | | | | | | | | | | ];
            try discriminate Hchk.
          match goal with
          | Hev : eval_expr _ _ _ _ (Econst_int _ _) _ |- _ =>
              inv Hev;
              try (match goal with
                   | Hlv : eval_lvalue _ _ _ _ (Econst_int _ _) _ _ _ |- _ =>
                       inv Hlv
                   end)
          end.
          refine (conj Hc (conj _ (conj _ (conj _ (conj _ I))))).
          -- intros b o Hg.
             rewrite PTree.gso in Hg
               by (intro EE; vm_compute in EE; discriminate EE).
             exact (Hm b o Hg).
          -- intros t Ht b o Hg.
             rewrite PTree.gso in Hg
               by (intro EE; subst t; vm_compute in Ht; discriminate Ht).
             exact (Hch t Ht b o Hg).
          -- intros w Hg. rewrite PTree.gss in Hg.
             injection Hg as <-. exact (wact_const_sound _ Hchk).
          -- intros t Ht v Hg.
             rewrite PTree.gso in Hg
               by (intro EE; subst t; vm_compute in Ht; discriminate Ht).
             exact (Hnpi t Ht v Hg).
        * destruct (mem_id id bk_nids) eqn:Enids.
          -- (* sub-word cast: nptr seed *)
             unfold bk_subint_cast_chk in Hchk.
             destruct a as [ | | | | | | | | | | ca cty | | | ];
               try discriminate Hchk.
             match goal with
             | Hev : eval_expr _ _ _ _ (Ecast _ _) _ |- _ =>
                 inv Hev;
                 try (match goal with
                      | Hlv : eval_lvalue _ _ _ _ (Ecast _ _) _ _ _ |- _ =>
                          inv Hlv
                      end)
             end.
             refine (conj Hc (conj _ (conj _ (conj _ (conj _ I))))).
             ++ intros b o Hg.
                rewrite PTree.gso in Hg
                  by (intro EE; subst id; vm_compute in Enids;
                      discriminate Enids).
                exact (Hm b o Hg).
             ++ intros t Ht b o Hg.
                rewrite PTree.gso in Hg
                  by (intro EE; subst t; congruence).
                exact (Hch t Ht b o Hg).
             ++ intros w Hg.
                rewrite PTree.gso in Hg
                  by (intro EE; subst id; vm_compute in Enids;
                      discriminate Enids).
                exact (Hbonk w Hg).
             ++ intros t Ht vv Hg.
                destruct (Pos.eqb t id) eqn:Eti.
                { apply Pos.eqb_eq in Eti; subst t.
                  rewrite PTree.gss in Hg. injection Hg as <-.
                  match goal with
                  | Hc0 : sem_cast _ _ _ _ = Some _ |- _ =>
                      exact (sem_cast_subint_nonptr _ _ _ _ _ Hchk Hc0)
                  end. }
                { apply Pos.eqb_neq in Eti.
                  rewrite PTree.gso in Hg by congruence.
                  exact (Hnpi t Ht vv Hg). }
          -- (* generic: id <> _mario *)
             refine (conj Hc (conj _ (conj _ (conj _ (conj _ I))))).
             ++ intros b o Hg.
                rewrite PTree.gso in Hg
                  by (intro EE; subst id; vm_compute in Hchk;
                      discriminate Hchk).
                exact (Hm b o Hg).
             ++ intros t Ht b o Hg.
                rewrite PTree.gso in Hg
                  by (intro EE; subst t; congruence).
                exact (Hch t Ht b o Hg).
             ++ intros w Hg.
                rewrite PTree.gso in Hg
                  by (intro EE; subst id; vm_compute in Ebonk;
                      discriminate Ebonk).
                exact (Hbonk w Hg).
             ++ intros t Ht vv Hg.
                rewrite PTree.gso in Hg
                  by (intro EE; subst t; congruence).
                exact (Hnpi t Ht vv Hg).
    - (* Scall *)
      cbn [bkbm_chk] in Hchk.
      destruct a as [ | | | | fid fty | | | | | | | | | ];
        try discriminate Hchk.
      apply andb_true_iff in Hchk as [Htf Hchk].
      unfold bk_call_chk in Hchk.
      apply andb_true_iff in Hchk as [Hfid Hopt].
      assert (Hex : exec_stmt function_entry2 (lp_ge lp) e le m
                      (Scall optid (Evar fid fty) al) t
                      (set_opttemp optid vres le) m' Out_normal)
        by (econstructor; eauto).
      destruct (bk_scall_ext_pres optid fid fty al e le m _ _ _ _
                  Htf (Hxe fid Hfid) (bk_xids_pres fid Hfid) Hex Hc)
        as (Hc' & _ & vr & Hle1).
      rewrite Hle1.
      destruct optid as [oid | ]; cbn [set_opttemp] in *.
      + apply andb_true_iff in Hopt as [Hopt Hnid].
        apply andb_true_iff in Hopt as [Hopt Hob].
        apply andb_true_iff in Hopt as [Hoc Hom].
        apply negb_true_iff in Hoc. apply negb_true_iff in Hom.
        apply negb_true_iff in Hob. apply negb_true_iff in Hnid.
        refine (conj Hc' (conj _ (conj _ (conj _ (conj _ I))))).
        * intros b o Hg.
          rewrite PTree.gso in Hg
            by (intro EE; subst oid; rewrite Pos.eqb_refl in Hom;
                discriminate Hom).
          exact (Hm b o Hg).
        * intros tt Ht b o Hg.
          rewrite PTree.gso in Hg
            by (intro EE; subst tt; rewrite Ht in Hoc; discriminate Hoc).
          exact (Hch tt Ht b o Hg).
        * intros w Hg.
          rewrite PTree.gso in Hg
            by (intro EE; subst oid; rewrite Pos.eqb_refl in Hob;
                discriminate Hob).
          exact (Hbonk w Hg).
        * intros tt Ht v Hg.
          rewrite PTree.gso in Hg
            by (intro EE; subst tt; rewrite Ht in Hnid; discriminate Hnid).
          exact (Hnpi tt Ht v Hg).
      + exact (conj Hc' (conj Hm (conj Hch (conj Hbonk (conj Hnpi I))))).
    - (* Sbuiltin *)
      cbn [bkbm_chk] in Hchk. discriminate Hchk.
    - (* Sseq_1 *)
      cbn [bkbm_chk] in Hchk.
      apply andb_true_iff in Hchk as [H1 H2].
      destruct (IHHexec1 H1 Hxe Hm Hch Hbonk Hnpi Hc)
        as (Hc1 & Hm1 & Hch1 & Hb1 & Hn1 & _).
      exact (IHHexec2 H2 Hxe Hm1 Hch1 Hb1 Hn1 Hc1).
    - (* Sseq_2 *)
      cbn [bkbm_chk] in Hchk.
      apply andb_true_iff in Hchk as [H1 _].
      exact (IHHexec H1 Hxe Hm Hch Hbonk Hnpi Hc).
    - (* Sifthenelse *)
      cbn [bkbm_chk] in Hchk. apply andb_true_iff in Hchk as [H1 H2].
      apply IHHexec; try assumption.
      destruct b; assumption.
    - (* Sreturn None *)
      exact (conj Hc (conj Hm (conj Hch (conj Hbonk (conj Hnpi I))))).
    - (* Sreturn (Some a) *)
      cbn [bkbm_chk] in Hchk.
      destruct a as [ | | | | | q ty | | | | | | | | ];
        try discriminate Hchk.
      apply andb_true_iff in Hchk as [Hq Hty].
      apply Pos.eqb_eq in Hq; subst q.
      destruct (type_eq ty tuint) as [-> | ]; [ | discriminate Hty ].
      match goal with
      | Hev : eval_expr _ _ _ _ (Etempvar _ _) ?w |- _ =>
          apply eval_expr_Etempvar_val in Hev
      end.
      refine (conj Hc (conj Hm (conj Hch (conj Hbonk (conj Hnpi _))))).
      cbn [wret_ok typeof]. intros _.
      match goal with
      | Hg : le ! bk_bonk = Some ?w |- _ =>
          exact (conj (Hbonk _ Hg) eq_refl)
      end.
    - (* Sbreak *)
      exact (conj Hc (conj Hm (conj Hch (conj Hbonk (conj Hnpi I))))).
    - (* Scontinue *)
      exact (conj Hc (conj Hm (conj Hch (conj Hbonk (conj Hnpi I))))).
    - (* Sloop stop1 *) cbn [bkbm_chk] in Hchk. discriminate Hchk.
    - (* Sloop stop2 *) cbn [bkbm_chk] in Hchk. discriminate Hchk.
    - (* Sloop loop *) cbn [bkbm_chk] in Hchk. discriminate Hchk.
    - (* Sswitch *) cbn [bkbm_chk] in Hchk. discriminate Hchk.
  Qed.

  (* ================================================================== *)
  (* THE ROW: entry/exit assembly producing call_pres_ret_act.          *)
  (* Allocates the 2 BullyCollisionData locals (fresh, bm-disjoint),     *)
  (* binds the _mario param, runs the walk, frees the locals.            *)
  (* ================================================================== *)
  Lemma bkbm_vars :
    map fst (fn_vars interaction.f_bully_knock_back_mario)
    = 20957421103592086%positive :: 20957421272127371%positive :: nil.
  Proof. vm_compute. reflexivity. Qed.

  Lemma bkbm_row :
    call_pres_ret_act lp bm NoA MWF interaction._bully_knock_back_mario.
  Proof.
    intros fd m0 vargs0 t0 mEnd vres0 Hevf Hres Hmarg HN HM HV HS.
    pose proof (resolve_pin_fd lp interaction.prog
                  interaction._bully_knock_back_mario
                  interaction.f_bully_knock_back_mario fd
                  LO_int bkbm_pin Hres) as ->.
    inv Hevf.
    match goal with He : function_entry2 _ _ _ _ _ _ _ |- _ =>
      rename He into Hentry end.
    match goal with Hx : exec_stmt _ _ _ _ _ _ _ _ _ _ |- _ =>
      rename Hx into Hbody end.
    match goal with Ho : outcome_result_value _ _ _ _ |- _ =>
      rename Ho into Hout end.
    match goal with Hf : Mem.free_list _ _ = Some _ |- _ =>
      rename Hf into Hfree end.
    inv Hentry.
    match goal with Ha : alloc_variables _ _ _ _ _ _ |- _ =>
      rename Ha into Halloc end.
    match goal with Hb : bind_parameter_temps _ _ _ = Some _ |- _ =>
      rename Hb into Hbind end.
    rewrite bkbm_params in Hbind.
    cbn [bind_parameter_temps] in Hbind.
    destruct vargs0 as [| v0 vr1]; [ discriminate Hbind | ].
    destruct vr1 as [| vx vr2]; [ | discriminate Hbind ].
    injection Hbind as <-.
    (* name the entry env + post-alloc memory *)
    match goal with
    | Hb : exec_stmt _ _ ?E _ ?M _ _ _ _ _ |- _ =>
        set (eloc := E) in *; set (mpost := M) in *
    end.
    (* carried at the post-alloc memory *)
    assert (Hc0 : carried bm NoA MWF m0)
      by (split; [ exact HV
         | split; [ exact HS | split; [ exact HM | exact HN ] ] ]).
    pose proof (alloc_variables_carried bm NoA MWF HMWF_alloc HNoA_of_MWF
                  _ _ _ _ _ _ Halloc Hc0) as Hca.
    (* entry invariants over le_entry = set _mario v0 (create_undef_temps ..) *)
    assert (Hm0 : forall b o,
               (PTree.set interaction._mario v0
                  (create_undef_temps
                     (fn_temps interaction.f_bully_knock_back_mario)))
                 ! bk_mario = Some (Vptr b o) -> b = bm /\ o = Ptrofs.zero).
    { intros b o Hg. unfold bk_mario in Hg.
      rewrite PTree.gss in Hg. injection Hg as ->.
      cbn in Hmarg. exact Hmarg. }
    assert (Hch0 : chase_inv SafeB bk_cact
               (PTree.set interaction._mario v0
                  (create_undef_temps
                     (fn_temps interaction.f_bully_knock_back_mario)))).
    { intros t Hmem b o Hg.
      assert (Etb : t = bk_bully)
        by (unfold bk_cact, mem_id in Hmem; cbn [existsb] in Hmem;
            rewrite orb_false_r in Hmem; apply Pos.eqb_eq in Hmem; exact Hmem).
      subst t. unfold bk_bully in Hg.
      rewrite PTree.gso in Hg by (intro EE; vm_compute in EE; discriminate EE).
      apply create_undef_temps_val in Hg. discriminate Hg. }
    assert (Hbonk0 : bonk_inv
               (PTree.set interaction._mario v0
                  (create_undef_temps
                     (fn_temps interaction.f_bully_knock_back_mario)))).
    { intros w Hg. unfold bk_bonk in Hg.
      rewrite PTree.gso in Hg by (intro EE; vm_compute in EE; discriminate EE).
      apply create_undef_temps_val in Hg. subst w. left. reflexivity. }
    assert (Hnpi0 : nptr_inv bk_nids
               (PTree.set interaction._mario v0
                  (create_undef_temps
                     (fn_temps interaction.f_bully_knock_back_mario)))).
    { intros t Hmem v Hg bb oo.
      assert (Etn : t = interaction._newBullyYaw)
        by (unfold bk_nids, mem_id in Hmem; cbn [existsb] in Hmem;
            rewrite orb_false_r in Hmem; apply Pos.eqb_eq in Hmem; exact Hmem).
      subst t.
      rewrite PTree.gso in Hg by (intro EE; vm_compute in EE; discriminate EE).
      apply create_undef_temps_val in Hg. subst v. discriminate. }
    (* the externals are not local var idents -> unbound in the entry env *)
    assert (Hxe : forall fid, mem_id fid bk_xids = true -> eloc ! fid = None).
    { intros fid Hm.
      assert (Hnin : ~ In fid
                 (map fst (fn_vars interaction.f_bully_knock_back_mario))).
      { rewrite bkbm_vars. revert Hm. unfold bk_xids.
        cbn [mem_id existsb]. intro Hm.
        repeat (apply orb_true_iff in Hm as [Hm | Hm];
          [ apply Pos.eqb_eq in Hm; subst fid;
            cbn [In]; intros [E | [E | []]]; vm_compute in E; discriminate E | ]).
        discriminate Hm. }
      rewrite (alloc_variables_unbound (lp_ge lp) m0
                 (fn_vars interaction.f_bully_knock_back_mario)
                 empty_env eloc mpost Halloc fid Hnin).
      apply PTree.gempty. }
    (* run the walk *)
    destruct (bkbm_walk_pres _ _ _ _ _ _ _ _ Hbody bkbm_chk_body
                Hxe Hm0 Hch0 Hbonk0 Hnpi0 Hca)
      as (Hcar' & _ & _ & _ & _ & Hret').
    destruct Hcar' as (HVb & HSb & HMb & HNb).
    (* exit: free the fresh local blocks (each misses bm) *)
    pose proof (blocks_of_env_bm lp bm m0
                  (fn_vars interaction.f_bully_knock_back_mario) eloc mpost
                  Halloc HV) as Hforall.
    pose proof (free_list_carried_bm bm NoA MWF HMWF_free HNoA_of_MWF
                  (blocks_of_env (lp_ge lp) eloc) _ mEnd
                  Hforall Hfree (conj HVb (conj HSb (conj HMb HNb)))) as Hcf.
    destruct Hcf as (HVf & HSf & HMf & HNf).
    (* return value: tuint forces Out_return + i32-neutral untainted cast *)
    change (fn_return interaction.f_bully_knock_back_mario) with tuint in Hout.
    unfold outcome_result_value in Hout.
    match type of Hret' with
    | wret_ok _ ?oo => destruct oo as [ | | | ov ]
    end.
    - destruct Hout.
    - destruct Hout.
    - destruct Hout.
    - destruct ov as [ [v' t'] | ]; [ | destruct Hout ].
      destruct Hout as [_ Hcast].
      destruct (Hret' eq_refl) as [Huv Hi32'].
      assert (Hi32t : i32_ty tuint = true) by reflexivity.
      exact (conj HVf (conj HSf (conj HMf (conj HNf
               (sem_cast_i32_untainted _ _ _ _ _ Hi32' Hi32t Huv Hcast))))).
  Qed.

End BkbmSurface.

