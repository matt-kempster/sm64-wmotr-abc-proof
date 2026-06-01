(* ArrayStore.v -- the ARRAY-ELEMENT store inverter (the last un-cracked lvalue shape).
 *
 * Target store (from update_mario_pos_for_anim in mario.v), m->pos[0] = rhs:
 *   Sassign
 *     (Ederef
 *       (Ebinop Oadd
 *         (Efield (Ederef (Etempvar _m (tptr MarioState)) MarioState) _pos (tarray tfloat 3))
 *         (Econst_int (Int.repr 0) tint) (tptr tfloat)) tfloat)
 *     rhs
 * This is the lvalue shape (m->fld[i]) that stalled the prior session. exec_pos0_store
 * inverts it to a plain assign_loc at (bm, field_offset _pos), so the existing
 * preservation bricks (assign_loc_action_sat_avoid) then apply unchanged.
 *
 * THE HANG (prior attempt) AND THE FIX (the reusable recipe):
 *  - inv over the tarray `By_reference` deref_loc, and any vm_compute of sem_binop,
 *    forces genv_cenv mario_ge (the whole globalenv) -> OOM. NEVER vm_compute here.
 *  - deref_loc_tarray_inv: invert the By_reference field read via a CONCRETE-Tarray
 *    helper (its bitfield branch dies on Tint<>Tarray; its By_value/By_copy on
 *    access_mode reduction) -- no genv touched.
 *  - sem_add over the (tarray)+int: reduce with scoped cbn [.. typeof ..] + unfold
 *    sem_add/sem_add_ptr_int, discharge classify_add by a TYPE-ONLY equation
 *    (reflexivity, no genv), and cbn [sizeof tfloat] (= 4, matches on tfloat NOT cenv,
 *    so cenv stays opaque). The index-0 offset then collapses via Ptrofs.{mul_zero,
 *    add_zero,add_zero_l}.
 *  - the eval_expr inversions on Ebinop/Econst_int leave a SPURIOUS eval_Elvalue
 *    branch (a bogus eval_lvalue on a non-lvalue) -- kill it with `solve [inv Hl]`.
 *  - the struct-base read is By_copy: discharge the spurious By_value/By_reference
 *    deref branches by TARGETED `discriminate H` on the access_mode hyp (bare
 *    `discriminate` would scan the heavy field_offset eq and HANG).
 *)

From compcert Require Import Coqlib Errors Maps AST Integers Values Memory Globalenvs Ctypes Cop Clight Clightdefs ClightBigstep Events.
From Coq Require Import Lia.
Import Clightdefs.ClightNotations.
Local Open Scope clight_scope.
From SM64.Generated Require mario.
From SM64.Proofs Require Import Flying ActionFrame ActionValueFrame MarioMemWF ResetBodystate.

(* A deref_loc of an ARRAY type yields the pointer unchanged (arrays are
   accessed By_reference). Concrete Tarray, so: the By_value/By_copy cases die
   on access_mode (Tarray ..) = By_reference (reduces, no genv); the bitfield
   case dies because load_bitfield forces the type to be Tint, not Tarray. *)
Lemma deref_loc_tarray_inv :
  forall t n a m b ofs bf v,
    deref_loc (Tarray t n a) m b ofs bf v ->
    v = Vptr b ofs.
Proof.
  intros t n a m b ofs bf v Hdl.
  inv Hdl;
    [ discriminate
    | reflexivity
    | discriminate
    | match goal with H : load_bitfield _ _ _ _ _ _ _ _ |- _ => inv H end ].
Qed.

(* The array-element store inverter, concrete first: m->pos[0]. *)
Lemma exec_pos0_store :
  forall e le m rhs t le' m' out bm off,
    le ! mario._m = Some (Vptr bm Ptrofs.zero) ->
    field_offset mario_ce mario._pos mario_members = OK (off, Full) ->
    exec_stmt function_entry2 mario_ge e le m
      (Sassign
        (Ederef
          (Ebinop Oadd
            (Efield (Ederef (Etempvar mario._m (tptr (Tstruct mario._MarioState noattr)))
                       (Tstruct mario._MarioState noattr)) mario._pos (tarray tfloat 3))
            (Econst_int (Int.repr 0) tint) (tptr tfloat)) tfloat)
        rhs) t le' m' out ->
    le' = le /\ out = Out_normal /\
    exists v, assign_loc mario_ce tfloat m bm (Ptrofs.repr off) Full v m'.
Proof.
  intros e le m rhs t le' m' out bm off Hm Hfo Hexec.
  inv Hexec.
  (* outer Ederef lvalue -> eval_expr of the Ebinop = Vptr loc ofs *)
  match goal with Hlv : eval_lvalue _ _ _ _ (Ederef _ _) _ _ _ |- _ => inv Hlv end.
  (* the Ebinop rvalue *)
  (* Ebinop is not an lvalue: inv leaves a spurious eval_Elvalue branch with a bogus
     eval_lvalue (Ebinop ..) hyp -- kill it (no eval_lvalue rule for Ebinop). *)
  match goal with He : eval_expr _ _ _ _ (Ebinop _ _ _ _) _ |- _ => inv He end;
    try (match goal with Hl : eval_lvalue _ _ _ _ (Ebinop _ _ _ _) _ _ _ |- _ => solve [inv Hl] end).
  (* index operand: same, Econst_int is not an lvalue *)
  match goal with Hi : eval_expr _ _ _ _ (Econst_int _ _) _ |- _ => inv Hi end;
    try (match goal with Hl : eval_lvalue _ _ _ _ (Econst_int _ _) _ _ _ |- _ => solve [inv Hl] end).
  (* base operand: Efield as rvalue -> eval_Elvalue + deref_loc(tarray) By_reference *)
  match goal with He : eval_expr _ _ _ _ (Efield _ _ _) _ |- _ => inv He end.
  (* the tarray field read returns the field pointer unchanged *)
  match goal with Hd : deref_loc _ _ _ _ _ _ |- _ => cbn [typeof] in Hd;
    apply deref_loc_tarray_inv in Hd; subst end.
  (* resolve the Efield lvalue: base is a struct, so eval_Efield_struct *)
  match goal with Hlv : eval_lvalue _ _ _ _ (Efield _ _ _) _ _ _ |- _ => inv Hlv end;
    [ | match goal with Hut : typeof _ = Tunion _ _ |- _ => inv Hut end ].
  (* the struct base (Ederef _m) rvalue + its lvalue + the Etempvar *)
  match goal with Hee : eval_expr _ _ _ _ (Ederef _ _) _ |- _ => inv Hee end.
  match goal with Hlv2 : eval_lvalue _ _ _ _ (Ederef _ _) _ _ _ |- _ => inv Hlv2 end.
  match goal with He : eval_expr _ _ _ _ (Etempvar _ _) _ |- _ =>
    inv He;
    try (match goal with Hl2 : eval_lvalue _ _ _ _ (Etempvar _ _) _ _ _ |- _ =>
           solve [ inv Hl2 ] end) end.
  (* pin the struct-base block/offset: require BOTH the eval-derived lookup
     (Vptr l o) and the entry hypothesis (Vptr bm zero) so the match binds the
     eval-derived l/o, not bm/zero (which would no-op the subst). *)
  match goal with
  | Hlk : ?T ! mario._m = Some (Vptr ?l ?o),
    Hm0 : ?T ! mario._m = Some (Vptr bm Ptrofs.zero) |- _ =>
      assert (l = bm) by congruence; assert (o = Ptrofs.zero) by congruence; subst l o end.
  (* discharge the struct-base By_copy deref_loc *)
  repeat match goal with Hdl : deref_loc ?ty _ _ _ _ _ |- _ => progress cbn [typeof] in Hdl end.
  (* the Tstruct base is read By_copy; the spurious By_value/By_reference branches
     carry a false access_mode hyp -- discharge by THAT specific hyp (targeted
     `discriminate H`, which reduces access_mode (Tstruct ..) = By_copy; NOT bare
     `discriminate`, which would scan the heavy field_offset eq and hang). The
     bitfield branch dies because load_bitfield forces Tint <> Tstruct. *)
  match goal with Hdl : deref_loc (Tstruct _ _) _ _ _ _ _ |- _ => inv Hdl end;
    try (match goal with H : access_mode (Tstruct _ _) = By_value _ |- _ => discriminate H end);
    try (match goal with H : access_mode (Tstruct _ _) = By_reference |- _ => discriminate H end);
    try (match goal with H : load_bitfield _ _ _ _ _ _ _ _ |- _ => inv H end).
  match goal with Ht : typeof (Ederef _ _) = Tstruct _ _ |- _ => cbn [typeof] in Ht; inv Ht end.
  rewrite genv_cenv_mario in *.
  (* pin the field offset off via field_offset determinism *)
  match goal with
  | Hco : PTree.get mario._MarioState mario_ce = Some ?co,
    Hfo2 : field_offset mario_ce mario._pos (co_members ?co) = OK (?delta, ?bf) |- _ =>
      assert (Hmm : mario_members = co_members co)
        by (unfold mario_members; rewrite Hco; reflexivity);
      rewrite <- Hmm in Hfo2;
      assert (Hd1 : delta = off) by congruence;
      assert (Hd2 : bf = Full) by congruence;
      subst delta bf
  end.
  (* reduce the pointer arithmetic: sem_add over (tarray) + index 0.
     The reduction keeps cenv opaque (sizeof tfloat = 4 ignores cenv); classify_add
     is discharged by a type-only equation (no genv), avoiding a stuck change_attributes. *)
  match goal with Hsb : sem_binary_operation _ _ _ _ _ _ _ = _ |- _ =>
    cbn [sem_binary_operation typeof] in Hsb;
    unfold sem_add in Hsb;
    assert (Hca : classify_add (tarray tfloat 3) tint = add_case_pi tfloat Signed) by reflexivity;
    rewrite Hca in Hsb; clear Hca;
    unfold sem_add_ptr_int in Hsb;
    cbn [sizeof tfloat] in Hsb
  end.
  match goal with Hsb : Some (Vptr _ _) = Some (Vptr _ _) |- _ => inv Hsb end.
  match goal with Hass : assign_loc _ ?ty _ _ _ _ _ _ |- _ => cbn [typeof] in Hass end.
  split; [ reflexivity | split; [ reflexivity | ] ].
  (* offset = add (add zero (repr off)) (mul (repr 4) (ptrofs_of_int Signed 0)) = repr off *)
  assert (Hpz : Ptrofs.of_ints (Int.repr 0) = Ptrofs.zero).
  { unfold Ptrofs.of_ints. change (Int.repr 0) with Int.zero.
    rewrite Int.signed_zero. reflexivity. }
  match goal with Hass : assign_loc _ _ _ _ _ _ ?vv _ |- _ =>
    exists vv;
    rewrite Hpz, Ptrofs.mul_zero, Ptrofs.add_zero, Ptrofs.add_zero_l in Hass; exact Hass
  end.
Qed.
