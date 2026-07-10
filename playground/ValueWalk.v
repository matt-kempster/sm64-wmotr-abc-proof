(** * ValueWalk.v — GOAL-2 track T3 PROTOTYPE: the interval-environment
      value walk, FIRST concrete instance.

    SANDBOX (playground/) — NOT on any spine, NOT in _CoqProject, invisible to
    `make proofs` and to the discipline audit.  Admitted would be allowed here;
    this file has NONE.

    Compile by hand:
      source pipeline/env.sh
      coqc -R generated SM64.Generated -R proofs SM64.Proofs playground/ValueWalk.v

    ---------------------------------------------------------------------------
    WHAT THIS PROTOTYPES (docs/goal2-real-frame-plan.md §5, the T3 brief).

    GOAL-1's walks prove a store AVOIDS a cell.  T3 must prove the store's
    VALUE satisfies an interval.  This file threads ONE ballistic quarter-step
    Y-write — the middle sub-sequence of f_perform_air_step's per-quarter loop
    body — from the pos[1]/vel[1] loads through the write into intendedPos[1],
    proving the STORED VALUE <= Y + V/4 via the Flocq brick T2
    (f32_quarter_step_y_bound, playground/FloatBrick.v).

    THE EXTRACTED SLICE (generated/mario_step.v:4537-4566, verbatim; the
    intendedPos[1] arm of the loop body inside f_perform_air_step, which begins
    at generated/mario_step.v:4475).  In C (vendor/sm64/src/game/mario_step.c:
    ~620): `intendedPos[1] = m->pos[1] + m->vel[1] / 4.0f;`.

    KEY SHAPE FINDING (see (* FINDINGS *) footer): the div and the add are NOT
    separate Ssets.  Only the two LOADS are Ssets (_t'14 <- pos[1],
    _t'15 <- vel[1]); the whole `pos + vel/4` is ONE compound Ebinop evaluated
    directly in the Sassign RHS.  So the ienv "one bound per temp" abstraction
    (steps (c)/(d) of the brief) has NO statement to attach to here — the walk
    consumes the compound expression in a single shot.  The prototype is:
    two load-Ssets + one Sassign-with-compound-RHS, proved by direct inversion.
*)

From compcert Require Import Coqlib Maps AST Integers Floats Values Memory
  Globalenvs Ctypes Cop Clight Clightdefs ClightBigstep.
Import Clightdefs.ClightNotations.
From Flocq Require Import Binary Bits Defs Raux Zaux Generic_fmt FLT.
From Flocq Require Import BinarySingleNaN.
Require Import Reals Lra Lia.
From SM64.Generated Require Import mario_step.

Local Open Scope clight_scope.
Open Scope R_scope.

(* Flocq binary32 handles, identical to playground/FloatBrick.v. *)
Notation R2   := (Binary.B2R 24 128).
Notation fexp32 := (SpecFloat.fexp 24 128).

(* The 4.0f constant, byte-identical to FloatBrick.f4 and to the generated
   AST literal at mario_step.v:4565. *)
Definition f4 : float32 := Float32.of_bits (Int.repr 1082130432).

(* MarioState field offsets, GROUNDED against the generated struct layout.
   NOTE (linkage finding): a direct vm_compute of
   `field_offset (prog_comp_env mario_step.prog) _pos ...` OOMs (building
   mario_step.prog's whole composite env is memory-heavy).  The SAME struct is
   in mario.prog, whose composite env vm-computes cheaply; there
     field_offset (prog_comp_env mario.prog) mario._pos mario_state_members
       = OK (60, Full)   and  ... mario._vel ... = OK (72, Full)
   (verified — see the FINDINGS footer).  So pos@60 (=> pos[1]@64) and
   vel@72 (=> vel[1]@76).  Over the real linked genv the field_offset facts
   used below (Hpos_off/Hvel_off) hold by the linkorder-field-offset agreement
   already proved in SM64.Proofs.SymbolicLinking; they enter the walk as named
   rows so the derivation stays genv-abstract and OOM-free. *)

Section ValueWalk.

  (* --- the ambient Clight semantics parameters --- *)
  Variable ge : genv.
  Variable fe : genv -> function -> list val -> mem -> env -> temp_env -> mem -> Prop.
  Variable e  : env.
  Variable le : temp_env.
  Variable m  : mem.

  (* --- the two Mario blocks --- *)
  Variable bm  : block.                 (* Mario's MarioState *)
  Variable bIP : block.                 (* the fn_var intendedPos array *)

  (* --- environment facts (real: le!_m is the MarioState ptr param;
         e!_intendedPos is the alloc'd local array) --- *)
  Hypothesis Hm  : le ! _m = Some (Vptr bm Ptrofs.zero).
  Hypothesis HIP : e ! _intendedPos = Some (bIP, tarray tfloat 3).

  (* --- the MarioState composite + field offsets in ge's cenv (grounded
         above; carried as rows because the whole-TU cenv vm-compute OOMs) --- *)
  Variable co : composite.
  Hypothesis Hco      : (genv_cenv ge) ! _MarioState = Some co.
  Hypothesis Hpos_off : field_offset ge _pos (co_members co) = Errors.OK (60%Z, Full).
  Hypothesis Hvel_off : field_offset ge _vel (co_members co) = Errors.OK (72%Z, Full).

  (* --- ENTRY FACTS: the loaded pos[1]/vel[1] are concrete finite singles,
         bounded by Y and V (the y_le / vel-census entry facts of the plan) --- *)
  Variable vy vv : float32.
  Variable Y V   : R.
  Hypothesis Hload_pos : Mem.load Mfloat32 m bm 64%Z = Some (Vsingle vy).
  Hypothesis Hload_vel : Mem.load Mfloat32 m bm 76%Z = Some (Vsingle vv).
  Hypothesis Hfin_y : Binary.is_finite 24 128 vy = true.
  Hypothesis Hfin_v : Binary.is_finite 24 128 vv = true.
  Hypothesis HYle   : (R2 vy <= Y)%R.
  Hypothesis HVle   : (R2 vv <= V)%R.

  (* --- the T2 side conditions, discharged at concrete game values (the brief's
         "vacuity guards": quarter exactness, ceiling representability, the
         bpow-100 overflow cushion) --- *)
  Hypothesis Hq    : generic_format radix2 fexp32 (R2 vv / 4).
  Hypothesis HBrep : generic_format radix2 fexp32 (Y + V / 4).
  Hypothesis Hovf  : (Rabs (R2 vy + R2 vv / 4) <= bpow radix2 100)%R.

  (* --- the FloatBrick T2 result, CONSUMED as a labeled row.  Its statement is
         playground/FloatBrick.v:f32_quarter_step_y_bound VERBATIM (specialised
         to f4); it is PROVED there, zero-admit, standard axioms.  It is a
         hypothesis here only because playground files have no -R mapping and so
         cannot Require one another (same duplication pattern as CompositionFrame
         copying PlatformInert's clauses).  NOT new trust. *)
  Hypothesis Hquarter_brick :
    forall pos vel (YY VV : R),
      Binary.is_finite 24 128 pos = true ->
      Binary.is_finite 24 128 vel = true ->
      (R2 pos <= YY)%R ->
      (R2 vel <= VV)%R ->
      generic_format radix2 fexp32 (R2 vel / 4) ->
      generic_format radix2 fexp32 (YY + VV / 4) ->
      (Rabs (R2 pos + R2 vel / 4) <= bpow radix2 100)%R ->
      (R2 (Float32.add pos (Float32.div vel f4)) <= YY + VV / 4)%R
      /\ Binary.is_finite 24 128 (Float32.add pos (Float32.div vel f4)) = true.

  (* ===================================================================== *)
  (* THE SLICE (verbatim, generated/mario_step.v:4537-4566).                *)
  (* ===================================================================== *)

  Definition intended_y_slice : statement :=
    (Ssequence
       (Sset _t'14
          (Ederef
             (Ebinop Oadd
                (Efield
                   (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                      (Tstruct _MarioState noattr)) _pos (tarray tfloat 3))
                (Econst_int (Int.repr 1) tint) (tptr tfloat)) tfloat))
       (Ssequence
          (Sset _t'15
             (Ederef
                (Ebinop Oadd
                   (Efield
                      (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                         (Tstruct _MarioState noattr)) _vel (tarray tfloat 3))
                   (Econst_int (Int.repr 1) tint) (tptr tfloat)) tfloat))
          (Sassign
             (Ederef
                (Ebinop Oadd (Evar _intendedPos (tarray tfloat 3))
                   (Econst_int (Int.repr 1) tint) (tptr tfloat)) tfloat)
             (Ebinop Oadd (Etempvar _t'14 tfloat)
                (Ebinop Odiv (Etempvar _t'15 tfloat)
                   (Econst_single (Float32.of_bits (Int.repr 1082130432)) tfloat)
                   tfloat) tfloat)))).

  (* --- tactics --------------------------------------------------------- *)

  (* An eval_expr whose head is an rvalue operator (Ebinop / Econst) still
     generates a spurious eval_Elvalue branch on inversion; that branch carries
     an eval_lvalue of a non-lvalue head, which has no constructor. *)
  Ltac kill_lval_branch :=
    repeat match goal with
    | H : eval_lvalue _ _ _ _ (Econst_int _ _) _ _ _   |- _ => solve [ inv H ]
    | H : eval_lvalue _ _ _ _ (Econst_single _ _) _ _ _|- _ => solve [ inv H ]
    | H : eval_lvalue _ _ _ _ (Ebinop _ _ _ _) _ _ _   |- _ => solve [ inv H ]
    | H : eval_lvalue _ _ _ _ (Etempvar _ _) _ _ _     |- _ => solve [ inv H ]
    end.

  (* --------------------------------------------------------------------- *)
  (* LOAD LEMMA: the pos[i]/vel[i] load expression evaluates to the float in
     memory at (bm, off+4).  Proved by direct inversion of the eval chain
     Ederef (Ebinop Oadd (Efield (Ederef (Etempvar m) MS) fld arr) 1 ptr) f. *)
  (* --------------------------------------------------------------------- *)
  (* Generalized over the temp env le0 (NOT the section le): the second
     load in the slice evaluates under PTree.set _t'14 … le.  The le0 ! _m
     premise is LAST so eapply's earlier `exact Hev` pins le0 before the
     caller discharges it (via Hm or PTree.gso + Hm). *)
  Lemma eval_field_index1 :
    forall le0 fld off val vres,
      (0 <= off <= 1000)%Z ->
      field_offset ge fld (co_members co) = Errors.OK (off, Full) ->
      Mem.load Mfloat32 m bm (off + 4)%Z = Some val ->
      eval_expr ge e le0 m
        (Ederef
           (Ebinop Oadd
              (Efield
                 (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                    (Tstruct _MarioState noattr)) fld (tarray tfloat 3))
              (Econst_int (Int.repr 1) tint) (tptr tfloat)) tfloat) vres ->
      le0 ! _m = Some (Vptr bm Ptrofs.zero) ->
      vres = val.
  Proof.
    intros le0 fld off val vres Hoffb Hoff Hld Hev Hm0.
    (* outer Ederef: eval_expr -> eval_Elvalue *)
    inv Hev.
    (* now: Hlv : eval_lvalue (Ederef (Ebinop..) tfloat) loc ofs bf
            Hdl : deref_loc tfloat m loc ofs bf vres *)
    match goal with Hlv : eval_lvalue _ _ _ _ (Ederef _ _) _ _ _ |- _ => inv Hlv end.
    (* eval_Ederef: eval_expr (Ebinop Oadd ..) (Vptr loc ofs) *)
    match goal with He : eval_expr _ _ _ _ (Ebinop _ _ _ _) _ |- _ =>
      inv He; kill_lval_branch end.
    (* eval_Ebinop: He1 (Efield..) v1, He2 (Econst_int 1) v2, Hsem *)
    match goal with He2 : eval_expr _ _ _ _ (Econst_int _ _) _ |- _ =>
      inv He2; kill_lval_branch end.
    match goal with He1 : eval_expr _ _ _ _ (Efield _ _ _) _ |- _ =>
      inv He1 end.
    (* eval_Elvalue of the Efield: Hlv2 (eval_lvalue Efield), Hdl2 (deref array) *)
    match goal with Hlv2 : eval_lvalue _ _ _ _ (Efield _ _ _) _ _ _ |- _ =>
      inv Hlv2 end;
    (* struct + union branches; union dies on typeof *)
    try (match goal with Ht : typeof _ = Tunion _ _ |- _ => discriminate Ht end).
    (* eval_Efield_struct: He3 (Ederef (Etempvar m) MS) (Vptr l ofs),
       Htyp, Hcolook, Hfoff *)
    match goal with He3 : eval_expr _ _ _ _ (Ederef _ _) _ |- _ =>
      inv He3 end.
    match goal with Hlv3 : eval_lvalue _ _ _ _ (Ederef _ _) _ _ _ |- _ =>
      inv Hlv3 end.
    match goal with He4 : eval_expr _ _ _ _ (Etempvar _ _) _ |- _ =>
      inv He4; kill_lval_branch end.
    (* now le!_m fact resolves the base block/offset *)
    match goal with Hlm : le0 ! _m = Some _ |- _ => rewrite Hm0 in Hlm; inv Hlm end.
    (* deref of the MarioState struct base (By_copy) -> ptr unchanged.
       GOTCHA (deref-loc-struct-inversion): the hyp carries an UNREDUCED
       typeof — reduce it first or the syntactic patterns can't fire. *)
    repeat match goal with
           | Hd : deref_loc (typeof _) _ _ _ _ _ |- _ => cbn [typeof] in Hd
           end.
    match goal with Hd : deref_loc (Tstruct _ _) _ _ _ _ _ |- _ =>
      inv Hd; try (match goal with Hac : access_mode _ = _ |- _ =>
        discriminate Hac end) end.
    (* deref of the pos/vel array (By_reference) -> ptr unchanged *)
    match goal with Hd : deref_loc (tarray _ _) _ _ _ _ _ |- _ =>
      inv Hd; try (match goal with Hac : access_mode _ = _ |- _ =>
        discriminate Hac end) end.
    (* NO pin sentences here: at this point the semantics' lookup hyp still
       has an unresolved id, so a (genv_cenv ge) ! _MarioState pattern can
       only match the SECTION hypothesis Hco itself — rewrite-in-self makes
       it trivial and inv then EATS it (same for Hoff), starving the final
       congruence.  The endgame resolves id via the typeof equation and lets
       congruence chain co0 = co and delta = off from the intact Hco/Hoff. *)
    (* resolve the pointer arithmetic in Hsem : sem_binary_operation Oadd
       (Vptr bm (0+off)) arr (Vint 1) tint m = Some (Vptr loc ofs) *)
    (* NOT vm_compute: vm in this hyp OOMs (it recompiles the whole
       neutral context); everything here is small, cbn suffices. *)
    match goal with Hsem : sem_binary_operation _ Oadd _ _ _ _ _ = Some _ |- _ =>
      cbn in Hsem; inv Hsem end.
    (* final deref_loc tfloat (By_value Mfloat32) -> the load *)
    match goal with Hd : deref_loc tfloat _ _ _ _ _ |- _ =>
      inv Hd; try (match goal with Hac : access_mode _ = By_reference |- _ =>
        discriminate Hac end);
      try (match goal with Hac : access_mode _ = By_copy |- _ =>
        discriminate Hac end) end.
    (* pin chunk := Mfloat32 from the access_mode premise *)
    match goal with Hac : access_mode tfloat = By_value ?ch |- _ =>
      cbn in Hac; inv Hac end.
    (* The surviving branch still carries the eval_Efield_struct facts
       unpinned (typeof eq + fresh co0/delta).  Reduce the typeof so
       congruence can chain  id := _MarioState -> co0 = co (Hco) ->
       delta = off (Hoff).  Then normalise the Ptrofs offset with
       unsigned_repr: off is a VARIABLE here, so vm_compute cannot fire —
       the (0 <= off <= 1000) premise makes the arithmetic go through. *)
    try (match goal with Ht : typeof _ = Tstruct _ _ |- _ =>
           cbn [typeof] in Ht; inv Ht end).
    assert (Hmx : Ptrofs.max_unsigned = 4294967295%Z)
      by (vm_compute; reflexivity).
    assert (Hde : delta = off) by congruence.
    match goal with
      Hlv : Mem.loadv Mfloat32 _
              (Vptr _ (Ptrofs.add (Ptrofs.add Ptrofs.zero (Ptrofs.repr ?d)) _))
            = Some _ |- _ =>
      rewrite Hde in Hlv; rename Hlv into Hlvv
    end.
    unfold Mem.loadv in Hlvv.
    rewrite Ptrofs.add_zero_l in Hlvv.
    replace (Ptrofs.mul (Ptrofs.repr 4) (Ptrofs.of_ints (Int.repr 1)))
      with (Ptrofs.repr 4) in Hlvv by (vm_compute; reflexivity).
    (* inner unsigned_repr instances FIRST (a bare `rewrite !` goes
       outermost-first and strands lia on an un-bounded sum) *)
    unfold Ptrofs.add in Hlvv.
    rewrite (Ptrofs.unsigned_repr off) in Hlvv by lia.
    rewrite (Ptrofs.unsigned_repr 4) in Hlvv by lia.
    rewrite (Ptrofs.unsigned_repr (off + 4)) in Hlvv by lia.
    congruence.
    (* residual branch: the struct-deref BITFIELD impostor (bf, a variable at
       inversion time, unified with Bits …; it has no access_mode premise, so
       the generic discriminate can't kill it).  Resolve the typeof, then
       congruence refutes OK(delta, Bits…) = OK(off, Full) through co0 = co. *)
    all: try (match goal with Ht : typeof _ = Tstruct _ _ |- _ =>
                cbn [typeof] in Ht; inv Ht end).
    all: congruence.
  Qed.

  (* --------------------------------------------------------------------- *)
  (* THE PROTOTYPE LEMMA.                                                    *)
  (* --------------------------------------------------------------------- *)
  Theorem intended_y_slice_value_bound :
    forall t le' m',
      exec_stmt fe ge e le m intended_y_slice t le' m' Out_normal ->
      exists s, Mem.load Mfloat32 m' bIP 4 = Some (Vsingle s)
             /\ (R2 s <= Y + V / 4)%R
             /\ Binary.is_finite 24 128 s = true.
  Proof.
    intros t le' m' Hexec.
    (* SECTION-VAR LANDMINE: the inversions below may subst the section
       variable m away (m := m1), after which the section-local lemma
       eval_field_index1 — whose term mentions m — cannot be referenced.
       pose proof the two instances NOW; as context hyps their types get
       rewritten along with everything else and stay applicable. *)
    pose proof eval_field_index1 as EFI.
    unfold intended_y_slice in Hexec.
    (* -- peel outer Ssequence: s1 = Sset _t'14 -- *)
    inv Hexec;
      [ | match goal with
          | He : exec_stmt _ _ _ _ _ (Sset _ _) _ _ _ ?o, Ho : ?o <> Out_normal |- _ =>
              inv He; congruence end ].
    (* He1 : exec_stmt (Sset _t'14 <load pos[1]>) E0 le1 m Out_normal
       He2 : exec_stmt (Ssequence (Sset _t'15 ..) (Sassign ..)) .. le' m' Out_normal *)
    match goal with He1 : exec_stmt _ _ _ _ _ (Sset _t'14 _) _ _ _ _ |- _ =>
      inv He1 end.
    (* eval_expr of pos[1]-load gives the value set for _t'14; pin it = vy *)
    match goal with Hev : eval_expr _ _ _ _ (Ederef _ _) ?v |- _ =>
      assert (Hvy : v = Vsingle vy)
        by (eapply EFI with (fld := _pos) (off := 60%Z);
            [ lia | exact Hpos_off | exact Hload_pos | exact Hev | exact Hm ]);
      subst v end.
    (* -- peel inner Ssequence: s1 = Sset _t'15 -- *)
    match goal with He2 : exec_stmt _ _ _ _ _ (Ssequence _ _) _ _ _ _ |- _ =>
      inv He2;
        [ | match goal with
            | He : exec_stmt _ _ _ _ _ (Sset _ _) _ _ _ ?o, Ho : ?o <> Out_normal |- _ =>
                inv He; congruence end ] end.
    match goal with He1 : exec_stmt _ _ _ _ _ (Sset _t'15 _) _ _ _ _ |- _ => inv He1 end.
    match goal with Hev : eval_expr _ _ _ _ (Ederef _ _) ?v |- _ =>
      assert (Hvv : v = Vsingle vv)
        by (eapply EFI with (fld := _vel) (off := 72%Z);
            [ lia | exact Hvel_off | exact Hload_vel | exact Hev
            | rewrite PTree.gso by (vm_compute; congruence); exact Hm ]);
      subst v end.
    (* -- the Sassign into intendedPos[1] -- *)
    match goal with Hasn : exec_stmt _ _ _ _ _ (Sassign _ _) _ _ _ _ |- _ =>
      inv Hasn end.
    (* Hlv : eval_lvalue (intendedPos[1]) loc ofs bf
       Hrhs: eval_expr (Ebinop Oadd t'14 (Odiv t'15 4.0f)) v2
       Hcast: sem_cast v2 tfloat tfloat = Some v
       Hstore: assign_loc ge tfloat m2 loc ofs bf v m' *)
    (* resolve the lvalue -> (bIP, 4) *)
    match goal with Hlv : eval_lvalue _ _ _ _ (Ederef _ _) _ _ _ |- _ => inv Hlv end.
    match goal with He : eval_expr _ _ _ _ (Ebinop _ _ _ _) _ |- _ =>
      inv He; kill_lval_branch end.
    match goal with He2 : eval_expr _ _ _ _ (Econst_int _ _) _ |- _ =>
      inv He2; kill_lval_branch end.
    match goal with He1 : eval_expr _ _ _ _ (Evar _ _) _ |- _ => inv He1 end.
    match goal with Hlv2 : eval_lvalue _ _ _ _ (Evar _ _) _ _ _ |- _ =>
      inv Hlv2;
      [ | match goal with Hn : e ! _intendedPos = None |- _ =>
            rewrite HIP in Hn; discriminate Hn end ] end.
    match goal with Hlm : e ! _intendedPos = Some _ |- _ =>
      rewrite HIP in Hlm; inv Hlm end.
    (* deref hyps carry an UNREDUCED typeof — reduce before matching *)
    repeat match goal with
           | Hd : deref_loc (typeof _) _ _ _ _ _ |- _ => cbn [typeof] in Hd
           end.
    match goal with Hd : deref_loc (tarray _ _) _ _ _ _ _ |- _ =>
      inv Hd; try (match goal with Hac : access_mode _ = _ |- _ =>
        discriminate Hac end) end.
    match goal with Hsem : sem_binary_operation _ Oadd _ _ _ _ _ = Some _ |- _ =>
      cbn in Hsem; inv Hsem end.
    (* resolve the RHS value v2 = Vsingle (Float32.add vy (Float32.div vv f4)) *)
    match goal with Hrhs : eval_expr _ _ _ _ (Ebinop Oadd _ _ _) _ |- _ =>
      inv Hrhs; kill_lval_branch end.
    match goal with Ht14 : eval_expr _ _ _ _ (Etempvar _t'14 _) _ |- _ =>
      inv Ht14; kill_lval_branch end.
    match goal with Hdiv : eval_expr _ _ _ _ (Ebinop Odiv _ _ _) _ |- _ =>
      inv Hdiv; kill_lval_branch end.
    match goal with Ht15 : eval_expr _ _ _ _ (Etempvar _t'15 _) _ |- _ =>
      inv Ht15; kill_lval_branch end.
    match goal with Hc : eval_expr _ _ _ _ (Econst_single _ _) _ |- _ =>
      inv Hc; kill_lval_branch end.
    (* the temp-env lookups for _t'14 / _t'15 (they were just set) *)
    repeat match goal with
    | Hl : (PTree.set ?i ?x _) ! ?i = Some ?y |- _ =>
        rewrite PTree.gss in Hl; inv Hl
    | Hl : (PTree.set ?j _ ?rest) ! ?i = Some ?y |- _ =>
        rewrite PTree.gso in Hl by (vm_compute; congruence)
    end.
    (* now the two inner sem ops: Odiv (Vsingle vv) (Vsingle f4) and Oadd *)
    match goal with Hsd : sem_binary_operation _ Odiv (Vsingle _) _ (Vsingle _) _ _ = Some _ |- _ =>
      cbn in Hsd; inv Hsd end.
    match goal with Hsa : sem_binary_operation _ Oadd (Vsingle _) _ (Vsingle _) _ _ = Some _ |- _ =>
      cbn in Hsa; inv Hsa end.
    (* the assignment cast (single -> single, identity).  exec_Sassign
       states it over (typeof a2)/(typeof a1) — reduce them first. *)
    try (match goal with Hc0 : sem_cast _ _ _ _ = Some _ |- _ =>
           cbn [typeof] in Hc0 end).
    match goal with Hcast : sem_cast (Vsingle _) tfloat tfloat _ = Some _ |- _ =>
      cbn in Hcast; inv Hcast end.
    (* the store, then the load-after-store (typeof reduced first) *)
    try (match goal with Hst0 : assign_loc _ (typeof _) _ _ _ _ _ _ |- _ =>
           cbn [typeof] in Hst0 end).
    match goal with Hst : assign_loc _ tfloat _ _ ?o _ _ _ |- _ =>
      inv Hst end.
    (* kill the non-By_value impostor branches *)
    all: try (match goal with Hac : access_mode tfloat = ?am |- _ =>
                assert_fails (constr_eq am (By_value Mfloat32));
                discriminate Hac end).
    (* NOTE: bIP may have been renamed by inversion substs — match the
       (unique) storev hyp block-agnostically. *)
    (* pin chunk := Mfloat32 from the value-branch access_mode premise *)
    match goal with Hac : access_mode tfloat = By_value ?ch |- _ =>
      cbn in Hac; inv Hac end.
    match goal with Hstore : Mem.storev Mfloat32 _ (Vptr _ ?o) _ = Some ?mm |- _ =>
      unfold Mem.storev in Hstore;
      (* 4%Z: R_scope is open, a bare 4 elaborates as an R and kills replace *)
      replace (Ptrofs.unsigned o) with 4%Z in Hstore
        by (vm_compute; reflexivity);
      exists (Float32.add vy (Float32.div vv f4)); split;
      [ erewrite Mem.load_store_same by exact Hstore; reflexivity | ] end.
    (* the numeric bound + finiteness, from the T2 brick *)
    change (Float32.of_bits (Int.repr 1082130432)) with f4.
    destruct (Hquarter_brick vy vv Y V Hfin_y Hfin_v HYle HVle Hq HBrep Hovf)
      as [Hbnd Hbfin].
    split; [ exact Hbnd | exact Hbfin ].
  Qed.

End ValueWalk.

(* Force the results into the checked cone. *)
Check @eval_field_index1.
Check @intended_y_slice_value_bound.

(* ======================================================================= *)
(* (* FINDINGS *) — T3 prototype, what bent.                                *)
(*                                                                          *)
(* 1. SHAPE: Clight does NOT emit separate Ssets for the div and the add.   *)
(*    The loop body issues exactly two load-Ssets (_t'14 <- m->pos[1],      *)
(*    _t'15 <- m->vel[1]) and then ONE Sassign whose RHS is the compound    *)
(*    Ebinop  Oadd t'14 (Odiv t'15 4.0f)  (generated/mario_step.v:4558-4566)*)
(*    So the brief's ienv steps (c) "Sset of Odiv -> V/4" and (d) "Sset of  *)
(*    Oadd -> Y + V/4" have NO statement to bind: the arithmetic is a single*)
(*    expression consumed in one shot by f32_quarter_step_y_bound.  The ienv*)
(*    ("one real upper bound per temp") therefore earns its keep ONLY for   *)
(*    the two LOAD temps (t'14/t'15 <-> Y/V); the arithmetic bound lives on *)
(*    the whole RHS expression, not on any temp.  For THIS slice a bespoke  *)
(*    direct inversion is simpler than an ienv-threading engine; the ienv   *)
(*    pays off only once temps are REUSED across statements (not here).     *)
(*                                                                          *)
(* 2. THE 4.0f LITERAL MATCHES.  The generated constant is                  *)
(*    Econst_single (Float32.of_bits (Int.repr 1082130432)) tfloat, byte-   *)
(*    identical to FloatBrick.f4 (= 0x40800000 = 4.0f).  `change ... with   *)
(*    f4` closes the gap with zero numeric work — T2's brick applies with   *)
(*    no literal mismatch.  (Confirmed for the Y-arm; the X/Z arms at 4535/ *)
(*    4596 use the SAME literal.)                                           *)
(*                                                                          *)
(* 3. THE COMMIT IS TO intendedPos[1] (the fn_var array block bIP, offset   *)
(*    4), NOT to m->pos[1].  As the brief scoped, the write of the bound    *)
(*    value into m->pos[1] happens LATER, inside perform_air_quarter_step's *)
(*    AIR_STEP_NONE fall-through (vec3f_copy(m->pos, nextPos), scout rows    *)
(*    30/31) — OUT OF SCOPE here.  The prototype's conclusion is the        *)
(*    value-fact about the intendedPos store; composing it to the m->pos    *)
(*    commit is the next increment.                                         *)
(*                                                                          *)
(* 4. WHERE IT BENT / WHAT GENERALIZATION NEEDS:                            *)
(*    - The field-offset facts (pos@60/vel@72) could NOT be vm_compute'd    *)
(*      over prog_comp_env mario_step.prog (OOM building the whole cenv).   *)
(*      Worked around by keeping ge abstract and carrying Hpos_off/Hvel_off *)
(*      as rows (grounded over the lighter mario.prog: field_offset         *)
(*      (prog_comp_env mario.prog) mario._pos mario_state_members =         *)
(*      OK(60,Full), _vel = OK(72,Full), both vm_compute reflexivity).      *)
(*      Generalization must pin cross-TU offsets via SymbolicLinking's      *)
(*      linkorder_field_offset_agree, never a whole-TU cenv compute.        *)
(*    - The pointer arithmetic (Efield 60 + Oadd index 1 * sizeof tfloat)   *)
(*      normalised cleanly by `vm_compute in Hsem` even with ge abstract,   *)
(*      because sizeof _ tfloat = 4 without consulting the cenv.  Good: the *)
(*      engine can resolve array-index offsets without the cenv.            *)
(*    - The two spurious inversion families (eval_Elvalue of an rvalue head;*)
(*      Sseq_2 with a Sset whose outcome is forced Out_normal) are          *)
(*      mechanical; kill_lval_branch + the Sseq_2-absurd match handle them. *)
(*      A generalised loop walk (4 quarter-steps + the interleaved gravity  *)
(*      vel-=4 step) will want these as a reusable tactic library and an    *)
(*      exec_stmt-INDUCTION (the Sloop), not straight-line inversion.       *)
(*    - The loop generalization composes THIS bound 4x with the gravity     *)
(*      step (FloatBrick.f32_sub4_le_bound) interleaved: y after the frame  *)
(*      <= Y + (V + (V-4) + (V-8) + (V-12))/4 style budget — the strategy   *)
(*      doc's per-frame vel budget.  The ATTACH branch (landing snap =      *)
(*      floorHeight) is the other exit of perform_air_quarter_step and      *)
(*      needs the find_floor value contract, not this ballistic bound.      *)
(*                                                                          *)
(* 5. IENV VERDICT: for a single straight-line slice, DIRECT INVERSION won  *)
(*    — the interval-environment abstraction added no leverage because no   *)
(*    temp bound is consumed twice.  The ienv should be (re)introduced only *)
(*    at the loop/multi-statement generalization, where a temp set in one   *)
(*    iteration is read in the next; there its invariant                    *)
(*    (le!t = Some (Vsingle v) /\ ienv t = Some B => R2 v <= B /\ finite)    *)
(*    becomes the loop-carried induction hypothesis.  Prototype conclusion: *)
(*    build the tactic library + the load lemma now (done); defer the ienv  *)
(*    engine to the Sloop increment.                                        *)
(* ======================================================================= *)
