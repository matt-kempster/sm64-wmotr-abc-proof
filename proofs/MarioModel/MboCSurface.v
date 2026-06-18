(* ====================================================================== *)
(* THE mario_blow_off_cap SURFACE: Hcp_mboc_real DISCHARGED (SPINE).       *)
(*                                                                        *)
(* f_mario_blow_off_cap (interaction.prog, act_getting_blown's helper):   *)
(*   t'3 = does_mario_have_normal_cap_on_head(m);                         *)
(*   if (t'3) {                                                           *)
(*     save_file_set_cap_pos(m->pos[0], m->pos[1], m->pos[2]);           *)
(*     m->flags &= ~(NORMAL_CAP | WING_CAP);            <- a Mario field   *)
(*     capObject = spawn_object(m->marioObj, 136, bhvNormalCap);          *)
(*     capObject->rawData.asF32[7]  += <cap speed>;     <- chase stores    *)
(*     capObject->rawData.asF32[12]  = capSpeed;          through the      *)
(*     capObject->rawData.asS32[16]  = (short)(faceAngle+1024);  spawned   *)
(*     if (m->forwardVel < 0)                             object block.    *)
(*       capObject->rawData.asS32[16] = (short)(... + 32768);             *)
(*   }                                                                    *)
(*                                                                        *)
(* This is the SPAWN/WIND arc (the air analogue of f_spawn_wind_particles *)
(* in WindSurface): the spawn_object return is a SafeB object-pool slot,  *)
(* every store through `capObject` lands in a bm-disjoint SafeB block, and *)
(* the one store INTO Mario (m->flags, offset 4) is window-disjoint from  *)
(* the action cell [12,16).  The two internal callees are honest: spawn_  *)
(* object is EF_external in EVERY TU (Hcp_spawn_real), save_file_set_cap_ *)
(* pos is an EF_external save-file boundary (scalar args, no Mario ptr),  *)
(* and does_mario_have_normal_cap_on_head is a memory-PURE reader         *)
(* (pure_walk, ZERO residual).                                            *)
(* ====================================================================== *)

From Coq Require Import ZArith List Lia.
From compcert Require Import Coqlib Maps AST Integers Values Events Memory
  Globalenvs Ctypes Cop Clightdefs Clight ClightBigstep Linking Errors.
From SM64.Generated Require Import interaction.
From SM64.Generated Require mario.
From SM64.Proofs Require Import SymbolicLinking Flying Taint
  ActionValueFrame RealFrameValue RealFrameLinked.
From SM64.Proofs Require Import CensusV2 EngineV2Consumer RestSurface
  LocalVarsSurface DispatchKit MarioStepSurface FloorsSurface WindSurface MWFReal.

Import ListNotations.

(* ====================================================================== *)
(* The recognizer (top-level, no lp).  Single-column helper booleans      *)
(* (the WindSurface lesson: one constructor level per match keeps every   *)
(* intermediate reduction definitional).                                  *)
(* ====================================================================== *)

Definition is_capobj_temp (a : expr) : bool :=
  match a with Etempvar i _ => Pos.eqb i _capObject | _ => false end.
Definition is_t1_temp (a : expr) : bool :=
  match a with Etempvar i _ => Pos.eqb i _t'1 | _ => false end.

(* the capObject <- t'1 TRANSFER, or any OTHER temp (gso-safe). *)
Definition mbc_set_chk (id : ident) (a : expr) : bool :=
  if Pos.eqb id _capObject then is_t1_temp a
  else negb (Pos.eqb id _m) && negb (Pos.eqb id _t'1).

(* ---- flags store: m->flags = <int> ---- *)
Definition is_tuint (t : type) : bool :=
  match t with Tint I32 Unsigned _ => true | _ => false end.
(* the flags lvalue m->flags: the base must be EXACTLY
   Ederef (Etempvar _m (tptr tyMS)) tyMS so the field-offset geometry pins
   the store to (bm, 4).  The MarioState type is load-bearing for soundness:
   a cast through another struct could land the same field name elsewhere. *)
Definition is_flags_lval (base : expr) (fld : ident) (fty : type) : bool :=
  match base with
  | Ederef (Etempvar p pty) sty =>
      Pos.eqb p _m
      && proj_sumbool (type_eq pty (tptr tyMS))
      && proj_sumbool (type_eq sty tyMS)
      && Pos.eqb fld _flags
      && is_tuint fty
  | _ => false
  end.

(* ---- chase store: capObject->rawData.{asF32|asS32}[i] = <non-ptr> ---- *)
Definition is_struct_ty (t : type) : bool :=
  match t with Tstruct _ _ => true | _ => false end.
Definition is_capobj_base (a : expr) : bool :=
  match a with
  | Ederef b t => is_capobj_temp b && is_struct_ty t
  | _ => false
  end.
Definition is_rawdata_union (a : expr) : bool :=
  match a with
  | Efield b _ (Tunion _ _) => is_capobj_base b
  | _ => false
  end.
Definition is_chase_arr_field (a : expr) : bool :=
  match a with
  | Efield b _ (Tarray _ _ _) => is_rawdata_union b
  | _ => false
  end.
Definition is_chase_addr (a : expr) : bool :=
  match a with
  | Ebinop Oadd b _ _ => is_chase_arr_field b
  | _ => false
  end.
Definition is_tint_src (a : expr) : bool :=
  match typeof a with Tint I32 Signed _ => true | _ => false end.
Definition is_cast_short (a : expr) : bool :=
  match a with Ecast inner (Tint I16 _ _) => is_tint_src inner | _ => false end.
(* tfloat dst => the stored value is a float (never a Vptr); tint dst =>   *)
(* the rvalue is a cast-to-short, so it evaluates to a Vint.               *)
Definition chase_src_ok (ty : type) (a2 : expr) : bool :=
  match ty with
  | Tfloat F32 _ => true
  | Tint I32 _ _ => is_cast_short a2
  | _ => false
  end.

Definition mbc_assign_chk (a1 a2 : expr) : bool :=
  match a1 with
  | Efield base fld fty => is_flags_lval base fld fty
  | Ederef aP ty => is_chase_addr aP && chase_src_ok ty a2
  | _ => false
  end.

Definition mbc_call_chk (optid : option ident) (a : expr) : bool :=
  match a with
  | Evar fid (Tfunction _ _ _) =>
      if Pos.eqb fid _does_mario_have_normal_cap_on_head
      then match optid with Some t => Pos.eqb t _t'3 | None => false end
      else if Pos.eqb fid _save_file_set_cap_pos
      then match optid with None => true | _ => false end
      else if Pos.eqb fid _spawn_object
      then match optid with Some t => Pos.eqb t _t'1 | None => false end
      else false
  | _ => false
  end.

Fixpoint mbc_chk (s : statement) : bool :=
  match s with
  | Sskip => true
  | Sset id a => mbc_set_chk id a
  | Sassign a1 a2 => mbc_assign_chk a1 a2
  | Scall optid a _ => mbc_call_chk optid a
  | Ssequence s1 s2 => mbc_chk s1 && mbc_chk s2
  | Sifthenelse _ s1 s2 => mbc_chk s1 && mbc_chk s2
  | _ => false
  end.

(* NON-VACUITY: the recognizer accepts the REAL generated body. *)
Lemma mbc_chk_body :
  mbc_chk (fn_body f_mario_blow_off_cap) = true.
Proof. vm_compute. reflexivity. Qed.

(* the generated offset of MarioState.flags (window-disjoint from the
   action cell [12,16)). *)
Example flags_field_off :
  field_offset (prog_comp_env mario.prog) mario._flags mario_state_members
  = OK (4, Full).
Proof. vm_compute. reflexivity. Qed.

(* the recognizer pins the flags lvalue base to the exact MarioState shape
   that mfield_lvalue_geom_lp consumes. *)
Lemma is_flags_lval_shape : forall base fld fty,
    is_flags_lval base fld fty = true ->
    base = Ederef (Etempvar _m (tptr tyMS)) tyMS /\
    fld = _flags /\ is_tuint fty = true.
Proof.
  intros base fld fty H.
  destruct base as [ | | | | | | bb sty | | | | | | | ]; try discriminate H.
  destruct bb as [ | | | | | p pty | | | | | | | | ]; try discriminate H.
  cbn [is_flags_lval] in H.
  apply andb_prop in H as [H Hfty].
  apply andb_prop in H as [H Hfld].
  apply andb_prop in H as [H Hsty].
  apply andb_prop in H as [Hp Hpty].
  apply Pos.eqb_eq in Hp. subst p.
  apply Pos.eqb_eq in Hfld. subst fld.
  destruct (type_eq pty (tptr tyMS)); [ subst pty | discriminate Hpty ].
  destruct (type_eq sty tyMS); [ subst sty | discriminate Hsty ].
  repeat split; assumption.
Qed.

(* the defmap pin: f_mario_blow_off_cap is Internal in interaction.prog. *)
Lemma mboc_pin :
  (prog_defmap interaction.prog) ! _mario_blow_off_cap
  = Some (Gfun (Internal f_mario_blow_off_cap)).
Proof. vm_compute. reflexivity. Qed.

Lemma dmhncoh_pin :
  (prog_defmap interaction.prog) ! _does_mario_have_normal_cap_on_head
  = Some (Gfun (Internal f_does_mario_have_normal_cap_on_head)).
Proof. vm_compute. reflexivity. Qed.

Lemma dmhncoh_chk :
  pure_chk (fn_body f_does_mario_have_normal_cap_on_head) = true.
Proof. vm_compute. reflexivity. Qed.

(* a cast landing in tfloat (Tfloat F32) is never a pointer: every cast
   case for a single-precision target produces Vsingle or fails. *)
Lemma sem_cast_tfloat_nonptr : forall v0 t1 a m v,
    sem_cast v0 t1 (Tfloat F32 a) m = Some v -> forall bb oo, v <> Vptr bb oo.
Proof.
  intros v0 t1 a m v H bb oo Heq; subst v.
  unfold sem_cast in H.
  destruct t1 as [ | sz si att | si att | fsz att | t att
                 | t z att | tl tr cc | id att | id att ];
    cbn in H;
    try (destruct v0; cbn in H; discriminate H);
    try (destruct fsz; cbn in H; destruct v0; cbn in H; discriminate H).
Qed.

(* a cast from a (Tint I32 Signed _) source to a (Tint I16 _ _) target is
   always cast_case_i2i, hence yields a Vint -- never a pointer (the inner
   tshort cast in mboc's asS32 chase stores). *)
Lemma sem_cast_i32s_i16_vint : forall v2 a1 si2 a2 m v,
    sem_cast v2 (Tint I32 Signed a1) (Tint I16 si2 a2) m = Some v ->
    exists vi, v = Vint vi.
Proof.
  intros v2 a1 si2 a2 m v H.
  unfold sem_cast in H.
  change (classify_cast (Tint I32 Signed a1) (Tint I16 si2 a2))
    with (cast_case_i2i I16 si2) in H.
  destruct v2; cbn in H; try discriminate H;
    inversion H; subst; eexists; reflexivity.
Qed.

Section MboCSurface.
  Variable lp : Clight.program.
  Hypothesis LO_int : linkorder interaction.prog lp.
  Hypothesis LO_mario : linkorder mario.prog lp.
  Variable bm : block.
  Variable NoA MWF : mem -> Prop.
  Variable SafeB : block -> Prop.

  Hypothesis HNoA_of_MWF : forall m, MWF m -> NoA m.
  Hypothesis HSafeNotBm : forall b, SafeB b -> b <> bm.
  (* a NON-POINTER store into a SafeB block at ANY offset preserves MWF
     (MWFReal.mwf_real_chase at the capstone). *)
  Hypothesis HMWF_chase : forall mm ch bsafe (d : Z) vv mm',
      MWF mm -> SafeB bsafe ->
      (forall bb oo, vv <> Vptr bb oo) ->
      Mem.store ch mm bsafe d vv = Some mm' -> MWF mm'.
  (* a word store into bm at the flags offset 4 preserves MWF -- the
     window region of bm, disjoint from action/input/chase cells
     (MWFReal.mwf_real_window with store_window_ok 4 4 at the capstone). *)
  Hypothesis HMWF_flags : forall mm mm' vv,
      MWF mm -> Mem.store Mint32 mm bm 4 vv = Some mm' -> MWF mm'.
  (* spawn_object: the SafeB-return external boundary (Hcp_spawn_real). *)
  Hypothesis Hcp_spawn : call_pres_ext_sr lp bm NoA MWF SafeB _spawn_object.
  (* save_file_set_cap_pos: a scalar-arg, void, save-file external
     boundary (the honest terminal external-call model class). *)
  Hypothesis Hcp_savefile : call_pres_ext lp bm NoA MWF _save_file_set_cap_pos.

  (* ================================================================== *)
  (* does_mario_have_normal_cap_on_head: a memory-PURE reader            *)
  (* (loads m->flags, returns a boolean) -- ZERO residual.              *)
  (* ================================================================== *)
  (* the pure FRAME fact: executing does_mario's read-only body leaves the
     carried frame intact, with NO marg gate -- the body never writes, so
     the argument provenance is irrelevant.  (does_mario IS marg-flagged
     since it takes a MarioState*, but its body_pres never consumes the
     gate, so we expose the marg-free core directly.) *)
  Lemma dmhncoh_pure_frame :
    forall m0 vargs0 t0 mF vres0,
      eval_funcall function_entry2 (lp_ge lp) m0
        (Internal f_does_mario_have_normal_cap_on_head) vargs0 t0 mF vres0 ->
      Mem.valid_block m0 bm -> action_sat not_tainted m0 bm -> MWF m0 ->
      Mem.valid_block mF bm /\ action_sat not_tainted mF bm /\ MWF mF.
  Proof.
    intros m0 vargs0 t0 mF vres0 Hevf HV HS HM.
    inv Hevf.
    match goal with He : function_entry2 _ _ _ _ _ _ _ |- _ =>
      rename He into Hentry end.
    match goal with Hx : exec_stmt _ _ _ _ _ _ _ _ _ _ |- _ =>
      rename Hx into Hbody end.
    match goal with Hf : Mem.free_list _ _ = Some _ |- _ =>
      rename Hf into Hfree end.
    inv Hentry.
    match goal with Ha : alloc_variables _ _ _ _ _ _ |- _ =>
      rename Ha into Halloc end.
    change (fn_vars f_does_mario_have_normal_cap_on_head)
      with (@nil (ident * type)) in Halloc.
    inv Halloc.
    pose proof (pure_walk _ _ _ _ _ _ _ _ _ Hbody dmhncoh_chk) as Em.
    subst m1.
    change (blocks_of_env (lp_ge lp) empty_env) with (@nil (block * Z * Z))
      in Hfree.
    cbn [Mem.free_list] in Hfree. injection Hfree as <-.
    exact (conj HV (conj HS HM)).
  Qed.

  (* the marg-FREE call lemma: resolve the call target to does_mario's
     internal body, then apply the pure frame fact.  Mirror of
     resolve_pin_fd (SymbolicLinking.linkorder_resolves_funct). *)
  Lemma dmhncoh_cp_pure :
    forall fd m0 vargs0 t0 m1 vres0,
      eval_funcall function_entry2 (lp_ge lp) m0 fd vargs0 t0 m1 vres0 ->
      resolves_lp lp _does_mario_have_normal_cap_on_head fd ->
      NoA m0 -> MWF m0 -> Mem.valid_block m0 bm ->
      action_sat not_tainted m0 bm ->
      Mem.valid_block m1 bm /\ action_sat not_tainted m1 bm /\
      MWF m1 /\ NoA m1.
  Proof.
    intros fd m0 vargs0 t0 m1 vres0 Hevf Hres HN HM HV HS.
    destruct Hres as (b & Hsym & Hff).
    destruct (linkorder_resolves_funct lp interaction.prog
                _does_mario_have_normal_cap_on_head
                f_does_mario_have_normal_cap_on_head LO_int dmhncoh_pin)
      as (b' & Hsym' & Hff').
    unfold lp_ge in Hsym, Hff.
    rewrite Hsym in Hsym'. injection Hsym' as <-.
    rewrite Hff in Hff'. injection Hff' as Hfd. subst fd.
    destruct (dmhncoh_pure_frame m0 vargs0 t0 m1 vres0 Hevf HV HS HM)
      as (HV' & HS' & HM').
    repeat split;
      [ exact HV' | exact HS' | exact HM' | exact (HNoA_of_MWF _ HM') ].
  Qed.

  (* ================================================================== *)
  (* The le-invariant: _m is Mario (marg), and _t'1 / _capObject hold    *)
  (* SafeB pointers if they hold pointers at all.                        *)
  (* ================================================================== *)
  Definition mle (le : temp_env) : Prop :=
    (forall b o, le ! _m = Some (Vptr b o) -> b = bm /\ o = Ptrofs.zero) /\
    (forall b o, le ! _t'1 = Some (Vptr b o) -> SafeB b) /\
    (forall b o, le ! _capObject = Some (Vptr b o) -> SafeB b).

  Lemma mle_set_other :
    forall le id v,
      Pos.eqb id _m = false ->
      Pos.eqb id _t'1 = false ->
      Pos.eqb id _capObject = false ->
      mle le -> mle (PTree.set id v le).
  Proof.
    intros le id v Hm Ht1 Hco (Wm & W1 & Wc).
    refine (conj _ (conj _ _)); intros b o Hg.
    - rewrite PTree.gso in Hg;
        [ exact (Wm b o Hg)
        | intro E; subst id; rewrite Pos.eqb_refl in Hm; discriminate Hm ].
    - rewrite PTree.gso in Hg;
        [ exact (W1 b o Hg)
        | intro E; subst id; rewrite Pos.eqb_refl in Ht1; discriminate Ht1 ].
    - rewrite PTree.gso in Hg;
        [ exact (Wc b o Hg)
        | intro E; subst id; rewrite Pos.eqb_refl in Hco; discriminate Hco ].
  Qed.

  (* ================================================================== *)
  (* THE WALK: exec-derivation induction (no Sloop/Sswitch in the body). *)
  (* ================================================================== *)
  Lemma mbc_walk_pres :
    forall e le m0 s tr le' m' out,
      exec_stmt function_entry2 (lp_ge lp) e le m0 s tr le' m' out ->
      mbc_chk s = true ->
      e = empty_env ->
      mle le ->
      (Mem.valid_block m0 bm /\ action_sat not_tainted m0 bm /\
       MWF m0 /\ NoA m0) ->
      (Mem.valid_block m' bm /\ action_sat not_tainted m' bm /\
       MWF m' /\ NoA m') /\ mle le'.
  Proof.
    intros e le m0 s tr le' m' out Hexec.
    induction Hexec; intros Hchk Hee Hmle Hc.
    - (* Sskip *) exact (conj Hc Hmle).
    - (* Sassign: a chase store (Ederef) OR the flags store (Efield) *)
      cbn [mbc_chk] in Hchk. unfold mbc_assign_chk in Hchk.
      destruct Hc as (HV & HS & HM & HN).
      destruct a1 as [ | | | | | | aBP aTY | | | | | aBASE aFLD aFTY | | ];
        try discriminate Hchk.
      + (* ---- a chase store: capObject->rawData.{asF32|asS32}[i] = .. ---- *)
        apply andb_true_iff in Hchk. destruct Hchk as [Haddr Hsrc].
        destruct Hmle as (Wm & W1 & Wc).
        (* decode the address chain, pinning the block to le!_capObject *)
        unfold is_chase_addr in Haddr.
        destruct aBP as [ | | | | | | | | | op cF cI tyB | | | | ];
          try discriminate Haddr.
        destruct op; try discriminate Haddr.
        unfold is_chase_arr_field in Haddr.
        destruct cF as [ | | | | | | | | | | | cF1 fld2 tyA | | ];
          try discriminate Haddr.
        destruct tyA as [ | | | | | tA zA aA | | | ]; try discriminate Haddr.
        unfold is_rawdata_union in Haddr.
        destruct cF1 as [ | | | | | | | | | | | cF2 fld1 tyU | | ];
          try discriminate Haddr.
        destruct tyU as [ | | | | | | | | uU aU ]; try discriminate Haddr.
        unfold is_capobj_base in Haddr.
        destruct cF2 as [ | | | | | | cW tyS | | | | | | | ];
          try discriminate Haddr.
        apply andb_true_iff in Haddr. destruct Haddr as [Hct Hsty].
        unfold is_capobj_temp in Hct.
        destruct cW as [ | | | | | w tyW | | | | | | | | ];
          try discriminate Hct.
        apply Pos.eqb_eq in Hct. subst w.
        unfold is_struct_ty in Hsty.
        destruct tyS as [ | | | | | | | sS aS | ]; try discriminate Hsty.
        (* the lvalue chain pins the store block to le!_capObject's *)
        match goal with
        | Hlv : eval_lvalue _ _ _ _ (Ederef _ _) _ _ _ |- _ => inv Hlv
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
            destruct (sem_add_ptrish_block _ _ (Tarray tA zA aA) _ _ _ _ _
                        eq_refl Hsem) as (oA & ->)
        end.
        match goal with
        | Hv1 : eval_expr _ _ _ _ (Efield _ _ (Tarray _ _ _)) (Vptr _ _) |- _ =>
            apply eval_expr_Efield_load in Hv1;
            destruct Hv1 as (lA & ofA & bfA & HlvA & HdA)
        end.
        destruct (deref_loc_aggregate_eq (Tarray tA zA aA) _ _ _ _ _ _
                    (or_introl eq_refl) HdA) as [E1 E2]; subst.
        match goal with
        | HlvA' : eval_lvalue _ _ _ _ (Efield _ _ (Tarray _ _ _)) _ _ _ |- _ =>
            apply eval_lvalue_Efield_base in HlvA';
            destruct HlvA' as (oU & HevU)
        end.
        apply eval_expr_Efield_load in HevU.
        destruct HevU as (lU & ofU & bfU & HlvU & HdU).
        destruct (deref_loc_aggregate_eq (Tunion uU aU) _ _ _ _ _ _
                    (or_intror eq_refl) HdU) as [E3 E4]; subst.
        apply eval_lvalue_Efield_base in HlvU.
        destruct HlvU as (oS & HevS).
        apply eval_expr_Ederef_load in HevS.
        destruct HevS as (lS & ofS & bfS & HlvS & HdS).
        destruct (deref_loc_aggregate_eq (Tstruct sS aS) _ _ _ _ _ _
                    (or_intror eq_refl) HdS) as [E5 E6]; subst.
        apply eval_lvalue_Ederef_base in HlvS.
        apply eval_expr_Etempvar_val in HlvS.
        pose proof (Wc _ _ HlvS) as Hsafe.
        (* the stored value v is non-pointer (float dst => Vsingle; tint dst
           => the rvalue is a cast-to-short of an int, hence a Vint) *)
        assert (Hnoptr : forall bb oo, v <> Vptr bb oo).
        { unfold chase_src_ok in Hsrc.
          destruct aTY as [ | szc sgc atc | sgl atl | szf atf
                          | tp ap | te ze ae | tlf trf ccf | idt ait | idu aiu ];
            try discriminate Hsrc.
          - (* tint dst *)
            destruct szc; try discriminate Hsrc.
            unfold is_cast_short in Hsrc.
            destruct a2 as [ | | | | | | | | | | cE cTY | | | ];
              try discriminate Hsrc.
            destruct cTY as [ | szs sgs ats | sgl atl | szf atf
                            | tp ap | te ze ae | tlf trf ccf | idt ait | idu aiu ];
              try discriminate Hsrc.
            destruct szs; try discriminate Hsrc.
            unfold is_tint_src in Hsrc.
            destruct (typeof cE) as [ | szi sgi ati | sgl atl | szf atf
                                    | tp ap | te ze ae | tlf trf ccf
                                    | idt ait | idu aiu ] eqn:Ety;
              try discriminate Hsrc.
            destruct szi; try discriminate Hsrc.
            destruct sgi; try discriminate Hsrc.
            (* invert the inner Ecast eval: the source value is a Vint *)
            match goal with
            | Hev2 : eval_expr _ _ _ _ (Ecast _ _) _ |- _ =>
                inv Hev2;
                [ | match goal with
                    | Hx : eval_lvalue _ _ _ _ (Ecast _ _) _ _ _ |- _ =>
                        inv Hx
                    end ]
            end.
            match goal with
            | Hc16 : sem_cast _ (typeof cE) (Tint I16 _ _) _ = Some _ |- _ =>
                rewrite Ety in Hc16;
                destruct (sem_cast_i32s_i16_vint _ _ _ _ _ _ Hc16) as (vi & ->)
            end.
            match goal with
            | Hca : sem_cast (Vint _) _ _ _ = Some v |- _ =>
                exact (sem_cast_vint_not_vptr _ _ _ _ _ Hca)
            end.
          - (* tfloat dst: the STORE cast targets Tfloat F32, hence non-ptr *)
            destruct szf; try discriminate Hsrc.
            match goal with
            | Hca : sem_cast _ _ ?tylv _ = Some v |- _ =>
                change tylv with (Tfloat F32 atf) in Hca;
                exact (sem_cast_tfloat_nonptr _ _ _ _ _ Hca)
            end. }
        (* aTY (the Ederef type) is Tfloat F32 or Tint I32 -- both By_value,
           never By_copy. aTY is abstract in the main goal, so derive its
           access_mode from Hsrc to kill the spurious By_copy assign_loc case. *)
        assert (Hacc : exists ch, access_mode aTY = By_value ch).
        { unfold chase_src_ok in Hsrc.
          destruct aTY as [ | isz sg aa | | szf aa | | | | | ];
            try discriminate Hsrc.
          - (* Tint: only I32 survives chase_src_ok; By_value Mint32 *)
            destruct isz; try discriminate Hsrc; eexists; reflexivity.
          - (* Tfloat: only F32 survives; By_value Mfloat32 *)
            destruct szf; try discriminate Hsrc; eexists; reflexivity. }
        destruct Hacc as [chA HaccA].
        (* the assign_loc: a By_value store into the SafeB block *)
        match goal with
        | Has : assign_loc _ _ _ _ _ _ _ m' |- _ =>
            cbn [typeof] in Has; inv Has;
            try (match goal with
                 | Hac : access_mode _ = _ |- _ =>
                     rewrite HaccA in Hac; discriminate Hac
                 end)
        end.
        match goal with
        | Hsv : Mem.storev _ _ (Vptr _ _) _ = Some m' |- _ =>
            unfold Mem.storev in Hsv; rename Hsv into Hst
        end.
        split; [ | exact (conj Wm (conj W1 Wc)) ].
        refine (conj _ (conj _ (conj _ _))).
        * eapply Mem.store_valid_block_1; eauto.
        * intros av Hload.
          rewrite (Mem.load_store_other _ _ _ _ _ _ Hst) in Hload;
            [ exact (HS av Hload)
            | left; exact (not_eq_sym (HSafeNotBm _ Hsafe)) ].
        * exact (HMWF_chase _ _ _ _ _ _ HM Hsafe Hnoptr Hst).
        * exact (HNoA_of_MWF _ (HMWF_chase _ _ _ _ _ _ HM Hsafe Hnoptr Hst)).
      + (* ---- the flags store: m->flags = <int> into bm at offset 4 ---- *)
        destruct (is_flags_lval_shape _ _ _ Hchk) as (-> & -> & Hfty).
        destruct Hmle as (Wm & W1 & Wc).
        (* pin the lvalue: Mario's block at the flags offset 4 *)
        match goal with
        | Hlv0 : eval_lvalue _ _ _ _ (Efield _ _ _) _ _ _ |- _ =>
            pose proof Hlv0 as Hpin;
            apply eval_lvalue_Efield_base in Hpin;
            destruct Hpin as (oo0 & Hb0);
            apply eval_expr_Ederef_load in Hb0;
            destruct Hb0 as (lb & ob & bfb & Hlvb & _);
            apply eval_lvalue_Ederef_base in Hlvb;
            apply eval_expr_Etempvar_val in Hlvb
        end.
        destruct (Wm _ _ Hlvb) as [E1 E2]. subst lb ob.
        match goal with
        | Hlv0 : eval_lvalue _ _ _ _ (Efield _ _ _) ?loc ?ofs ?bf |- _ =>
            destruct (mfield_lvalue_geom_lp lp LO_mario _ _ _ _ _ _
                        loc ofs bf _ _ _ Hlvb flags_field_off Hlv0)
              as (E3 & E4 & E5);
            subst loc ofs bf
        end.
        rewrite Ptrofs.add_zero_l in *.
        (* pin the field type concretely: is_tuint aFTY => Tint I32 Unsigned _,
           so access_mode reduces to By_value Mint32 (kills By_copy on inv) *)
        unfold is_tuint in Hfty.
        destruct aFTY as [ | fisz fsg faa | | | | | | | ]; try discriminate Hfty.
        destruct fisz; try discriminate Hfty.
        destruct fsg; try discriminate Hfty.
        (* the assign: a By_value Mint32 store at (bm, 4) *)
        match goal with
        | Has : assign_loc _ _ _ _ _ _ _ m' |- _ =>
            cbn [typeof] in Has; inv Has;
            try (match goal with
                 | Hac : access_mode _ = _ |- _ =>
                     cbn in Hac; discriminate Hac
                 end)
        end.
        match goal with
        | Hac : access_mode _ = By_value _ |- _ =>
            cbn in Hac; injection Hac as <-
        end.
        match goal with
        | Hsv : Mem.storev _ _ _ _ = Some m' |- _ =>
            unfold Mem.storev in Hsv;
            change (Ptrofs.unsigned (Ptrofs.repr 4)) with 4 in Hsv;
            rename Hsv into Hst
        end.
        split; [ | exact (conj Wm (conj W1 Wc)) ].
        refine (conj _ (conj _ (conj _ _))).
        * eapply Mem.store_valid_block_1; eauto.
        * intros av Hload.
          rewrite (Mem.load_store_other _ _ _ _ _ _ Hst) in Hload;
            [ exact (HS av Hload)
            | right; right; cbn; lia ].
        * exact (HMWF_flags _ _ _ HM Hst).
        * exact (HNoA_of_MWF _ (HMWF_flags _ _ _ HM Hst)).
    - (* Sset: the capObject <- t'1 transfer, or another temp (gso) *)
      cbn [mbc_chk] in Hchk. unfold mbc_set_chk in Hchk.
      split; [ exact Hc | ].
      destruct (Pos.eqb id _capObject) eqn:Eco.
      + (* the TRANSFER: capObject = t'1 *)
        apply Pos.eqb_eq in Eco. subst id.
        unfold is_t1_temp in Hchk.
        destruct a as [ | | | | | s0 sty | | | | | | | | ];
          try discriminate Hchk.
        apply Pos.eqb_eq in Hchk. subst s0.
        match goal with
        | Hev : eval_expr _ _ _ _ (Etempvar _ _) _ |- _ =>
            apply eval_expr_Etempvar_val in Hev
        end.
        destruct Hmle as (Wm & W1 & Wc).
        refine (conj _ (conj _ _)); intros b o Hg.
        * rewrite PTree.gso in Hg; [ exact (Wm b o Hg) | discriminate ].
        * rewrite PTree.gso in Hg; [ exact (W1 b o Hg) | discriminate ].
        * rewrite PTree.gss in Hg. injection Hg as ->.
          match goal with
          | Hev : le ! _t'1 = Some (Vptr _ _) |- _ => exact (W1 _ _ Hev)
          end.
      + (* another temp: gso-safe on all three clauses *)
        apply andb_true_iff in Hchk. destruct Hchk as [Hnm Hn1].
        apply negb_true_iff in Hnm. apply negb_true_iff in Hn1.
        exact (mle_set_other le id v Hnm Hn1 Eco Hmle).
    - (* Scall: does_mario (pure) / save_file (ext) / spawn (ext+SafeB) *)
      cbn [mbc_chk] in Hchk. unfold mbc_call_chk in Hchk.
      destruct Hc as (HV & HS & HM & HN).
      destruct a as [ | | | | fid fty | | | | | | | | | ];
        try discriminate Hchk.
      destruct fty as [ | | | | | | tyl rty cc1 | | ]; try discriminate Hchk.
      subst e.
      match goal with
      | Hvf : eval_expr _ _ _ _ (Evar _ _) _ |- _ =>
          apply (eval_Evar_funct_empty lp) in Hvf;
          destruct Hvf as (bf0 & Hsym & ->)
      end.
      match goal with
      | Hff : Genv.find_funct _ (Vptr bf0 Ptrofs.zero) = Some _ |- _ =>
          rename Hff into Hfind
      end.
      destruct (Pos.eqb fid _does_mario_have_normal_cap_on_head) eqn:Edm.
      + (* does_mario_have_normal_cap_on_head: a memory-PURE reader.  No
           marg needed -- the body never writes, so the frame survives any
           argument provenance (dmhncoh_cp_pure). *)
        apply Pos.eqb_eq in Edm. subst fid.
        destruct optid as [ t3 | ]; [ | discriminate Hchk ].
        apply Pos.eqb_eq in Hchk. subst t3.
        match goal with
        | Hevf : eval_funcall _ _ _ _ _ _ _ _ |- _ =>
            destruct (dmhncoh_cp_pure _ _ _ _ _ _ Hevf
                        (ex_intro _ bf0 (conj Hsym Hfind))
                        HN HM HV HS) as (HV' & HS' & HM' & HN')
        end.
        split.
        { exact (conj HV' (conj HS' (conj HM' HN'))). }
        cbn [set_opttemp].
        apply mle_set_other; try reflexivity. exact Hmle.
      + destruct (Pos.eqb fid _save_file_set_cap_pos) eqn:Esf.
        * (* save_file_set_cap_pos: an honest external boundary *)
          apply Pos.eqb_eq in Esf. subst fid.
          destruct optid as [ | ]; [ discriminate Hchk | ].
          match goal with
          | Hevf : eval_funcall _ _ _ _ _ _ _ _ |- _ =>
              destruct (Hcp_savefile _ _ _ _ _ _ Hevf
                          (ex_intro _ bf0 (conj Hsym Hfind))
                          HN HM HV HS) as (HV' & HS' & HM' & HN')
          end.
          split.
          { exact (conj HV' (conj HS' (conj HM' HN'))). }
          cbn [set_opttemp]. exact Hmle.
        * destruct (Pos.eqb fid _spawn_object) eqn:Esp;
            [ | discriminate Hchk ].
          (* spawn_object: external + SafeB-return *)
          apply Pos.eqb_eq in Esp. subst fid.
          destruct optid as [ t1 | ]; [ | discriminate Hchk ].
          apply Pos.eqb_eq in Hchk. subst t1.
          destruct Hmle as (Wm & W1 & Wc).
          match goal with
          | Hevf : eval_funcall _ _ _ _ _ _ _ _ |- _ =>
              destruct (Hcp_spawn _ _ _ _ _ _ Hevf
                          (ex_intro _ bf0 (conj Hsym Hfind))
                          HN HM HV HS) as (HV' & HS' & HM' & Hret)
          end.
          split.
          { exact (conj HV' (conj HS' (conj HM' (HNoA_of_MWF _ HM')))). }
          cbn [set_opttemp].
          refine (conj _ (conj _ _)); intros b o Hg.
          -- rewrite PTree.gso in Hg; [ exact (Wm b o Hg) | discriminate ].
          -- rewrite PTree.gss in Hg. injection Hg as Hg.
             exact (Hret _ _ Hg).
          -- rewrite PTree.gso in Hg; [ exact (Wc b o Hg) | discriminate ].
    - (* Sbuiltin: rejected *)
      cbn [mbc_chk] in Hchk. discriminate Hchk.
    - (* Sseq_1 *)
      cbn [mbc_chk] in Hchk. apply andb_true_iff in Hchk.
      destruct Hchk as [H1 H2].
      destruct (IHHexec1 H1 Hee Hmle Hc) as (Hc1 & Hmle1).
      exact (IHHexec2 H2 Hee Hmle1 Hc1).
    - (* Sseq_2 *)
      cbn [mbc_chk] in Hchk. apply andb_true_iff in Hchk.
      destruct Hchk as [H1 _].
      exact (IHHexec H1 Hee Hmle Hc).
    - (* Sifthenelse *)
      cbn [mbc_chk] in Hchk. apply andb_true_iff in Hchk.
      destruct Hchk as [H1 H2].
      apply IHHexec; try assumption.
      destruct b; assumption.
    - (* Sreturn None: rejected *)
      cbn [mbc_chk] in Hchk. discriminate Hchk.
    - (* Sreturn Some: rejected *)
      cbn [mbc_chk] in Hchk. discriminate Hchk.
    - (* Sbreak: rejected *)
      cbn [mbc_chk] in Hchk. discriminate Hchk.
    - (* Scontinue: rejected *)
      cbn [mbc_chk] in Hchk. discriminate Hchk.
    - (* Sloop stop1: rejected *)
      cbn [mbc_chk] in Hchk. discriminate Hchk.
    - (* Sloop stop2: rejected *)
      cbn [mbc_chk] in Hchk. discriminate Hchk.
    - (* Sloop loop: rejected *)
      cbn [mbc_chk] in Hchk. discriminate Hchk.
    - (* Sswitch: rejected *)
      cbn [mbc_chk] in Hchk. discriminate Hchk.
  Qed.

  (* ================================================================== *)
  (* THE ENTRY: the marg-gated body, then the call_pres discharge.       *)
  (* ================================================================== *)
  Lemma mboc_body_pres :
    body_pres lp NoA MWF bm f_mario_blow_off_cap.
  Proof.
    intros m vargs t mF vres Hgate Hevf HN HM HV HS.
    pose proof (Hgate eq_refl) as Hmarg.
    inv Hevf.
    match goal with He : function_entry2 _ _ _ _ _ _ _ |- _ =>
      rename He into Hentry end.
    match goal with Hx : exec_stmt _ _ _ _ _ _ _ _ _ _ |- _ =>
      rename Hx into Hbody end.
    match goal with Hf : Mem.free_list _ _ = Some _ |- _ =>
      rename Hf into Hfree end.
    inv Hentry.
    match goal with Ha : alloc_variables _ _ _ _ _ _ |- _ =>
      change (fn_vars f_mario_blow_off_cap) with (@nil (ident * type)) in Ha;
      inv Ha end.
    match goal with Hb : bind_parameter_temps _ _ _ = Some _ |- _ =>
      rename Hb into Hbind end.
    change (fn_params f_mario_blow_off_cap)
      with ((_m, tptr (Tstruct _MarioState noattr)) :: (_capSpeed, tfloat)
              :: nil) in Hbind.
    cbn [bind_parameter_temps] in Hbind.
    destruct vargs as [ | v1 vr1 ]; [ discriminate Hbind | ].
    cbn [bind_parameter_temps] in Hbind.
    destruct vr1 as [ | v2 vr2 ]; [ discriminate Hbind | ].
    cbn [bind_parameter_temps] in Hbind.
    destruct vr2 as [ | v3 vr3 ]; [ | discriminate Hbind ].
    injection Hbind as <-.
    (* the entry invariant *)
    assert (Hmle : mle (PTree.set _capSpeed v2
                          (PTree.set _m v1
                             (create_undef_temps
                                (fn_temps f_mario_blow_off_cap))))).
    { refine (conj _ (conj _ _)); intros b o Hg.
      - rewrite PTree.gso in Hg; [ | discriminate ].
        rewrite PTree.gss in Hg. injection Hg as Hv1. subst v1.
        cbn in Hmarg. destruct Hmarg as [-> ->]. auto.
      - rewrite PTree.gso in Hg; [ | discriminate ].
        rewrite PTree.gso in Hg; [ | discriminate ].
        vm_compute in Hg. discriminate Hg.
      - rewrite PTree.gso in Hg; [ | discriminate ].
        rewrite PTree.gso in Hg; [ | discriminate ].
        vm_compute in Hg. discriminate Hg. }
    (* the walk *)
    destruct (mbc_walk_pres _ _ _ _ _ _ _ _ Hbody mbc_chk_body eq_refl Hmle
                (conj HV (conj HS (conj HM HN)))) as ((HV' & HS' & HM' & _) & _).
    (* exit: fn_vars = nil, nothing to free *)
    change (blocks_of_env (lp_ge lp) empty_env) with (@nil (block * Z * Z))
      in Hfree.
    cbn [Mem.free_list] in Hfree. injection Hfree as <-.
    exact (conj HV' (conj HS' HM')).
  Qed.

  (* ================================================================== *)
  (* THE PAYOFF: Hcp_mboc_real, PROVED.                                  *)
  (* ================================================================== *)
  Theorem mboc_cp :
    call_pres lp bm NoA MWF _mario_blow_off_cap.
  Proof.
    exact (call_pres_of_body lp bm NoA MWF HNoA_of_MWF interaction.prog
             _mario_blow_off_cap f_mario_blow_off_cap
             LO_int mboc_pin mboc_body_pres).
  Qed.

End MboCSurface.
