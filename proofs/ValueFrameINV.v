(* ValueFrameINV.v -- THE CAPSTONE ENGINE (temp-provenance), built incrementally.
 *
 * The wall (why per-function doesn't fold into one lemma yet): a chase store
 * `p->fid = rhs` lands in whatever block the temp p points to. ActionValueFrame's
 * assign_value_ok quantifies `forall le`, so it cannot know p points OFF Mario's
 * block -- under an arbitrary le, p could point INTO it. The fix is to thread a
 * temp-environment invariant tmps_off_bm: every temp EXCEPT the Mario pointer _m
 * points to a block other than bm (Mario's block). Then:
 *   - a chase store (base temp <> _m) lands off-bm  -> avoids the action cell;
 *   - a direct store (base temp = _m)  lands in bm  -> handled by offset (the
 *     existing direct-store frame: action field is at a fixed offset).
 * tmps_off_bm holds at entry (only _m is a pointer param) and is re-established at
 * each chase-field-load Sset (the loaded pointer is off-bm by mario_mem_wf).
 *
 * THIS FILE grows the engine bottom-up; each piece is validated against the real
 * inverter bricks (ResetBodystate / ArrayStore) and stays axiom-clean.
 *)

From compcert Require Import Coqlib Errors Maps AST Integers Values Memory Globalenvs Ctypes Cop Clight Clightdefs ClightBigstep Events.
Import Clightdefs.ClightNotations.
Local Open Scope clight_scope.
From SM64.Proofs Require Import Flying ActionFrame ActionValueFrame MarioMemWF ResetBodystate RootedLvalue.

(* The temp-environment invariant: every temp other than the Mario-pointer id
   `mid` that holds a pointer points to a block distinct from Mario's block bm. *)
Definition tmps_off_bm (bm : block) (mid : ident) (le : temp_env) : Prop :=
  forall t b o, t <> mid -> le ! t = Some (Vptr b o) -> b <> bm.

(* ENGINE LEMMA (general chase store). A store through ANY tempvar p that points
   to a block blk <> bm preserves action_sat and validity, leaving le unchanged.
   Generalizes ResetBodystate.chase_store_preserves over the base temp p, the
   struct ident sid, and the genv ge. *)
Lemma chase_store_preserves_gen :
  forall (Q : int -> Prop) ge e le m p sid sattr fid fty rhs t le' m' out bm blk off,
    le ! p = Some (Vptr blk off) ->
    blk <> bm ->
    Mem.valid_block m bm ->
    action_sat Q m bm ->
    exec_stmt function_entry2 ge e le m
      (Sassign (Efield (Ederef (Etempvar p (tptr (Tstruct sid sattr)))
                  (Tstruct sid sattr)) fid fty) rhs) t le' m' out ->
    le' = le /\ out = Out_normal /\ Mem.valid_block m' bm /\ action_sat Q m' bm.
Proof.
  intros Q ge e le m p sid sattr fid fty rhs t le' m' out bm blk off Hp Hblk Hv Hs Hexec.
  destruct (exec_field_store_block _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ Hp Hexec)
    as (Hle & Hout & (ofs & bf & v & Hass)).
  split; [ exact Hle | split; [ exact Hout | split ] ].
  - eapply assign_loc_valid_block; [ exact Hass | exact Hv ].
  - eapply store_offblock_preserves_action_sat; [ exact Hass | exact Hv | exact Hblk | exact Hs ].
Qed.

(* The invariant version: from tmps_off_bm + (p is not the Mario pointer) we
   DERIVE blk <> bm, so no explicit per-call distinctness hypothesis is needed.
   le!p = Vptr blk off is read off the execution (the lvalue deref needs it). *)
Lemma chase_store_preserves_tmps :
  forall (Q : int -> Prop) ge e le m mid p sid sattr fid fty rhs t le' m' out bm blk off,
    tmps_off_bm bm mid le ->
    p <> mid ->
    le ! p = Some (Vptr blk off) ->
    Mem.valid_block m bm ->
    action_sat Q m bm ->
    exec_stmt function_entry2 ge e le m
      (Sassign (Efield (Ederef (Etempvar p (tptr (Tstruct sid sattr)))
                  (Tstruct sid sattr)) fid fty) rhs) t le' m' out ->
    le' = le /\ out = Out_normal /\ Mem.valid_block m' bm /\ action_sat Q m' bm.
Proof.
  intros Q ge e le m mid p sid sattr fid fty rhs t le' m' out bm blk off Hinv Hp Hlk Hv Hs Hexec.
  assert (Hblk : blk <> bm) by (eapply Hinv; [ exact Hp | exact Hlk ]).
  eapply chase_store_preserves_gen; eauto.
Qed.

(* INVARIANT PRESERVATION across a tempvar update. tmps_off_bm survives
   PTree.set t v provided: if t is not the Mario pointer and v is a pointer,
   that pointer is off-bm. (Scalar v, or v reusing an already-off-bm temp,
   satisfy this vacuously / from the prior invariant.) *)
Lemma tmps_off_bm_set :
  forall bm mid le t v,
    tmps_off_bm bm mid le ->
    (t <> mid -> forall b o, v = Vptr b o -> b <> bm) ->
    tmps_off_bm bm mid (PTree.set t v le).
Proof.
  intros bm mid le t v Hinv Hv. unfold tmps_off_bm.
  intros t' b o Hne Hlk. rewrite PTree.gsspec in Hlk.
  destruct (peq t' t) as [He|He].
  - subst t'. injection Hlk; intro Heq; subst v. exact (Hv Hne b o eq_refl).
  - eapply Hinv; [ exact Hne | exact Hlk ].
Qed.

(* _bodyState and _m are distinct temp identifiers. *)
Lemma bodyState_neq_m : mario._bodyState <> mario._m.
Proof. vm_compute. discriminate. Qed.

(* ESTABLISHMENT (marioBodyState chase-load). The Sset
     bodyState = m->marioBodyState
   re-establishes tmps_off_bm: the loaded pointer is off-bm by mario_mem_wf
   (gMarioState's block <> gBodyStates' block). This is the canonical point
   where the invariant is (re)created from memory well-formedness. *)
Lemma tmps_off_bm_set_bodystate :
  forall bm bbs e le m t le' m' out,
    tmps_off_bm bm mario._m le ->
    le ! mario._m = Some (Vptr bm Ptrofs.zero) ->
    mario_mem_wf m bm bbs ->
    exec_stmt function_entry2 mario_ge e le m
      (Sset mario._bodyState
        (Efield
          (Ederef (Etempvar mario._m (tptr (Tstruct mario._MarioState noattr)))
            (Tstruct mario._MarioState noattr)) mario._marioBodyState
          (tptr (Tstruct mario._MarioBodyState noattr)))) t le' m' out ->
    m' = m /\ out = Out_normal /\ tmps_off_bm bm mario._m le'.
Proof.
  intros bm bbs e le m t le' m' out Hinv Hm Hwf Hexec.
  destruct Hwf as (Hbb & off_bs & ofs & Hfo & Hld).
  destruct (exec_bodystate_load e le m t le' m' out bm bbs off_bs ofs Hm Hfo Hld Hexec)
    as (Hle' & Hm' & Hout).
  split; [ exact Hm' | split; [ exact Hout | ] ].
  subst le'. apply tmps_off_bm_set; [ exact Hinv | ].
  intros _ b o Heq. injection Heq; intros; subst b o. intro Hcontra.
  apply Hbb. symmetry. exact Hcontra.
Qed.

(* ================================================================== *)
(* GENERIC pointer-field-load inverter (the lever for clearing the     *)
(* chase functions field-by-field). For any pointer field fid of       *)
(* MarioState, the Sset  tid = m->fid  binds tid to the loaded pointer  *)
(* (Vptr b ofs). Generalizes exec_bodystate_load over the temp tid, the *)
(* field fid, its result struct type resty, and the (symbolic) offset   *)
(* off -- carrying off as a hypothesis from field_offset instead of the *)
(* hard-coded 200. The offset bound discharges by vm_compute per field. *)
(* ================================================================== *)
Lemma exec_field_ptr_load :
  forall e le m tid fid resty t le' m' out bm b off ofs,
    le ! mario._m = Some (Vptr bm Ptrofs.zero) ->
    field_offset mario_ce fid mario_members = OK (off, Full) ->
    0 <= off <= Ptrofs.max_unsigned ->
    Mem.load Mptr m bm off = Some (Vptr b ofs) ->
    exec_stmt function_entry2 mario_ge e le m
      (Sset tid
        (Efield
          (Ederef (Etempvar mario._m (tptr (Tstruct mario._MarioState noattr)))
            (Tstruct mario._MarioState noattr)) fid (tptr resty))) t le' m' out ->
    le' = PTree.set tid (Vptr b ofs) le /\ m' = m /\ out = Out_normal.
Proof.
  intros e le m tid fid resty t le' m' out bm b off ofs Hm Hfo Hbound Hld Hexec.
  inv Hexec.
  match goal with Hev : eval_expr _ _ _ _ (Efield _ _ _) ?v |- _ =>
    rename Hev into Heval; rename v into vfield end.
  inv Heval.
  match goal with Hlv : eval_lvalue _ _ _ _ (Efield _ _ _) _ _ _ |- _ => inv Hlv end;
    [ | match goal with Hut : typeof _ = Tunion _ _ |- _ => inv Hut end ].
  match goal with Hee : eval_expr _ _ _ _ (Ederef _ _) _ |- _ => inv Hee end.
  match goal with Hlv2 : eval_lvalue _ _ _ _ (Ederef _ _) _ _ _ |- _ => inv Hlv2 end.
  match goal with He : eval_expr _ _ _ _ (Etempvar _ _) _ |- _ =>
    inv He;
    try (match goal with Hl2 : eval_lvalue _ _ _ _ (Etempvar _ _) _ _ _ |- _ =>
           solve [ inv Hl2 ] end) end.
  match goal with
  | Hlk : ?T ! mario._m = Some (Vptr ?l ?o) |- _ =>
      assert (l = bm) by congruence; assert (o = Ptrofs.zero) by congruence; subst l o
  end.
  repeat match goal with
  | Hdl : deref_loc ?ty _ _ _ _ _ |- _ => progress cbn [typeof] in Hdl
  end.
  match goal with Hdl : deref_loc (Tstruct _ _) _ _ _ _ _ |- _ =>
    inv Hdl end;
    try (match goal with Hac : access_mode (Tstruct _ _) = By_value _ |- _ => discriminate end);
    try (match goal with Hac : access_mode (Tstruct _ _) = By_reference |- _ => discriminate end).
  match goal with Ht : typeof (Ederef _ _) = Tstruct _ _ |- _ =>
    cbn [typeof] in Ht; inv Ht end.
  rewrite genv_cenv_mario in *.
  match goal with
  | Hco : PTree.get mario._MarioState mario_ce = Some ?co,
    Hfo2 : field_offset mario_ce fid (co_members ?co) = OK (?delta, ?bf) |- _ =>
      assert (Hmm : mario_members = co_members co)
        by (unfold mario_members; rewrite Hco; reflexivity);
      rewrite <- Hmm in Hfo2;
      assert (Hd1 : delta = off) by congruence;
      assert (Hd2 : bf = Full) by congruence;
      subst delta bf
  end.
  match goal with Hdl : deref_loc (tptr _) _ _ _ _ _ |- _ =>
    inv Hdl end;
    try (match goal with Hac : access_mode (tptr _) = By_reference |- _ => discriminate end);
    try (match goal with Hac : access_mode (tptr _) = By_copy |- _ => discriminate end).
  match goal with
  | Hac : access_mode (tptr _) = By_value ?chunk,
    Hlv : Mem.loadv ?chunk _ (Vptr _ _) = Some ?v |- _ =>
      simpl in Hac; inversion Hac; subst chunk;
      unfold Mem.loadv in Hlv;
      rewrite Ptrofs.add_zero_l in Hlv;
      rewrite Ptrofs.unsigned_repr in Hlv by exact Hbound;
      rewrite Hld in Hlv; inv Hlv
  end.
  split; [ reflexivity | split; reflexivity ].
Qed.

(* A pointer field fid of MarioState loads, in memory m, a pointer into a block
   OTHER than Mario's block bm. This is the per-field well-formedness clause (the
   anti-aliasing assumption: marioObj/floor/area/... are separate allocations from
   gMarioState). One such clause per chased field; mario_mem_wf is the instance
   for marioBodyState. *)
Definition field_loads_off_bm (m : mem) (bm : block) (fid : ident) : Prop :=
  exists off b ofs,
    field_offset mario_ce fid mario_members = OK (off, Full) /\
    0 <= off <= Ptrofs.max_unsigned /\
    Mem.load Mptr m bm off = Some (Vptr b ofs) /\
    b <> bm.

(* GENERIC ESTABLISHMENT. Any chase-load  tid = m->fid  (tid not the Mario
   pointer, fid a pointer field that loads off-bm) re-establishes tmps_off_bm.
   This is tmps_off_bm_set_bodystate generalized over the field -- one lemma now
   covers every chased pointer field, given its field_loads_off_bm clause. *)
Lemma tmps_off_bm_set_field :
  forall bm e le m tid fid resty t le' m' out,
    tmps_off_bm bm mario._m le ->
    tid <> mario._m ->
    le ! mario._m = Some (Vptr bm Ptrofs.zero) ->
    field_loads_off_bm m bm fid ->
    exec_stmt function_entry2 mario_ge e le m
      (Sset tid
        (Efield
          (Ederef (Etempvar mario._m (tptr (Tstruct mario._MarioState noattr)))
            (Tstruct mario._MarioState noattr)) fid (tptr resty))) t le' m' out ->
    m' = m /\ out = Out_normal /\ tmps_off_bm bm mario._m le'.
Proof.
  intros bm e le m tid fid resty t le' m' out Hinv Htid Hm Hwf Hexec.
  destruct Hwf as (off & b & ofs & Hfo & Hbound & Hld & Hboff).
  destruct (exec_field_ptr_load e le m tid fid resty t le' m' out bm b off ofs
              Hm Hfo Hbound Hld Hexec) as (Hle' & Hm' & Hout).
  split; [ exact Hm' | split; [ exact Hout | ] ].
  subst le'. apply tmps_off_bm_set; [ exact Hinv | ].
  intros _ b' o' Heq. injection Heq; intros; subst b' o'. exact Hboff.
Qed.

(* ================================================================== *)
(* THE GENERAL CHASE-STORE ENGINE (any accessor depth). A store whose   *)
(* lvalue is rooted at a tempvar p (p not the Mario pointer) preserves   *)
(* action_sat: tmps_off_bm gives p's block <> bm, and RootedLvalue's      *)
(* rooted_block puts the store in p's block. This subsumes                *)
(* chase_store_preserves_tmps (single Efield) for ALL nested shapes        *)
(* (o->header.gfx.pos[i], t->throwMatrix[i][j], ...). *)
(* ================================================================== *)
Lemma rooted_store_preserves_tmps :
  forall (Q : int -> Prop) ge e le m mid p pb po lhs rhs t le' m' out bm,
    tmps_off_bm bm mid le ->
    p <> mid ->
    le ! p = Some (Vptr pb po) ->
    rooted_lv p lhs = true ->
    Mem.valid_block m bm ->
    action_sat Q m bm ->
    exec_stmt function_entry2 ge e le m (Sassign lhs rhs) t le' m' out ->
    le' = le /\ out = Out_normal /\ Mem.valid_block m' bm /\ action_sat Q m' bm.
Proof.
  intros Q ge e le m mid p pb po lhs rhs t le' m' out bm Hinv Hp Hlk Hroot Hv Hs Hexec.
  assert (Hpb : pb <> bm) by (eapply Hinv; [ exact Hp | exact Hlk ]).
  inv Hexec.
  match goal with Hlv : eval_lvalue _ _ _ _ lhs ?loc ?ofs ?bf |- _ =>
    assert (Hloc : loc = pb) by (eapply eval_lvalue_rooted; [ exact Hlk | exact Hlv | exact Hroot ]);
    subst loc end.
  split; [ reflexivity | split; [ reflexivity | split ] ].
  - match goal with Hass : assign_loc _ _ _ _ _ _ _ _ |- _ =>
      eapply assign_loc_valid_block; [ exact Hass | exact Hv ] end.
  - match goal with Hass : assign_loc _ _ _ _ _ _ _ _ |- _ =>
      eapply store_offblock_preserves_action_sat; [ exact Hass | exact Hv | exact Hpb | exact Hs ] end.
Qed.
