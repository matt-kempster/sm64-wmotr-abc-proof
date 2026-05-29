(* ToyReach.v -- the semantic kernel of the closed-world / entrypoint argument,
 * AND its lift to the actual f_main from generated/toy.v.
 *
 * Unlike ToyFrame.v (which proves facts about our *analysis function*, a
 * syntactic computation -- "Axis 1" in docs/two-axes-syntactic-vs-semantic.md),
 * this file proves facts about CompCert's actual *execution semantics* of
 * memory.
 *
 * The point the user pushed on: a modular ("open-world") preservation claim
 * about set_timer(o) needs an ASSUMED precondition that o doesn't alias the
 * global -- unsatisfying. In a CLOSED-WORLD setting (a guaranteed entrypoint)
 * pointers have provenance, and non-aliasing becomes DERIVED, not assumed: a
 * stack local is a freshly allocated block, distinct from any block that
 * already existed (which includes every global).
 *)

From compcert Require Import Coqlib Maps AST Integers Values Memory Globalenvs Ctypes Cop Clight Clightdefs ClightBigstep.
From SM64.Generated Require Import toy.

(* ========================================================================== *)
(* The crux, in its purest form: storing to a FRESH (not-yet-valid) block      *)
(* leaves untouched the value at any block that was already valid. Block        *)
(* distinctness is DERIVED from valid vs ~valid, not assumed.                   *)
(* ========================================================================== *)

Theorem store_to_fresh_preserves_existing :
  forall chunk m b_fresh ofs v m'
         chunk' b_glob ofs',
    ~ Mem.valid_block m b_fresh ->
    Mem.valid_block m b_glob ->
    Mem.store chunk m b_fresh ofs v = Some m' ->
    Mem.load chunk' m' b_glob ofs' = Mem.load chunk' m b_glob ofs'.
Proof.
  intros chunk m b_fresh ofs v m' chunk' b_glob ofs' Hfresh Hvalid Hstore.
  eapply Mem.load_store_other; eauto.
  left. apply Mem.valid_not_valid_diff with (m := m); assumption.
Qed.

(* ========================================================================== *)
(* Reusable frame lemmas over the three phases of a function call.             *)
(* ========================================================================== *)

(* free_list preserves the load value at any block distinct from every freed
   block. *)
Lemma free_list_load_unchanged :
  forall l m m',
    Mem.free_list m l = Some m' ->
    forall chunk b ofs,
      (forall b1 lo hi, In (b1, lo, hi) l -> b <> b1) ->
      Mem.load chunk m' b ofs = Mem.load chunk m b ofs.
Proof.
  induction l as [| [[b1 lo] hi] l IH]; intros m m' Hfree chunk b ofs Hdis.
  - simpl in Hfree. inv Hfree. reflexivity.
  - simpl in Hfree.
    destruct (Mem.free m b1 lo hi) as [m1|] eqn:Hf; try discriminate.
    transitivity (Mem.load chunk m1 b ofs).
    + apply (IH m1 m' Hfree). intros b2 lo2 hi2 Hin.
      apply (Hdis b2 lo2 hi2). right; exact Hin.
    + apply (Mem.load_free _ _ _ _ _ Hf). left.
      apply (Hdis b1 lo hi). left; reflexivity.
Qed.

(* A Clight assignment to block b preserves loads at any other block. Covers
   all three assign_loc kinds (by-value store, by-copy storebytes, bitfield
   store), so callers never case-split on the store mechanism. *)
Lemma assign_loc_load_other :
  forall ce ty m b ofs bf v m',
    assign_loc ce ty m b ofs bf v m' ->
    forall chunk b' off,
      b' <> b ->
      Mem.load chunk m' b' off = Mem.load chunk m b' off.
Proof.
  intros ce ty m b ofs bf v m' H chunk b' off Hne.
  inv H.
  - (* assign_loc_value: storev = store at (b, ofs) *)
    unfold Mem.storev in *. eapply Mem.load_store_other; eauto.
  - (* assign_loc_copy: storebytes at (b, ofs) *)
    eapply Mem.load_storebytes_other; eauto.
  - (* assign_loc_bitfield: store_bitfield contains a storev at (b, ofs) *)
    match goal with Hsb : store_bitfield _ _ _ _ _ _ _ _ _ _ |- _ => inv Hsb end.
    unfold Mem.storev in *. eapply Mem.load_store_other; eauto.
Qed.

(* ========================================================================== *)
(* The middle phase: what f_main's body actually does to memory.               *)
(* ========================================================================== *)

(* `Sassign a1 a2; Sreturn (Some a3)` always returns (non-normal outcome) and
   changes memory by exactly the assignment. Both inversions are on
   single-constructor statement shapes, so no subgoal-ordering fragility. *)
Lemma exec_seq_assign_return :
  forall fe ge e le m a1 a2 a3 t le' m' out,
    exec_stmt fe ge e le m
      (Ssequence (Sassign a1 a2) (Sreturn (Some a3))) t le' m' out ->
    out <> Out_normal
    /\ exists loc ofs bf v,
         eval_lvalue ge e le m a1 loc ofs bf
         /\ assign_loc ge (typeof a1) m loc ofs bf v m'.
Proof.
  intros fe ge e le m a1 a2 a3 t le' m' out H.
  inv H;
    repeat match goal with
    | Hr : exec_stmt _ _ _ _ _ (Sreturn _)   _ _ _ _ |- _ => inv Hr
    | Ha : exec_stmt _ _ _ _ _ (Sassign _ _) _ _ _ _ |- _ => inv Ha
    end;
    try congruence;
    (split; [ discriminate | do 4 eexists; split; eauto ]).
Qed.

(* Executing f_main's body changes memory by exactly one store, into obj.timer.
   We expose the l-value + resulting assign_loc; identifying its block is left
   to the caller, where the concrete environment is known. *)
Lemma exec_main_body_assign :
  forall fe ge e le m t le' m' out,
    exec_stmt fe ge e le m (fn_body f_main) t le' m' out ->
    exists loc ofs bf v,
      eval_lvalue ge e le m
        (Efield (Evar _obj (Tstruct _Object noattr)) _timer tint) loc ofs bf
      /\ assign_loc ge tint m loc ofs bf v m'.
Proof.
  intros fe ge e le m t le' m' out H.
  assert (Hbody : fn_body f_main =
    Ssequence
      (Ssequence
        (Sassign (Efield (Evar _obj (Tstruct _Object noattr)) _timer tint)
          (Econst_int (Int.repr 0) tint))
        (Sreturn (Some (Econst_int (Int.repr 0) tint))))
      (Sreturn (Some (Econst_int (Int.repr 0) tint)))) by reflexivity.
  rewrite Hbody in H.
  (* Outer Ssequence: the inner seq always returns, so only exec_Sseq_2 fits. *)
  inv H;
    match goal with
    | Hs : exec_stmt _ _ _ _ _ (Ssequence (Sassign _ _) (Sreturn _)) _ _ _ _ |- _ =>
        apply exec_seq_assign_return in Hs;
        destruct Hs as [Hne Hass];
        first [ congruence | exact Hass ]
    end.
Qed.

(* ========================================================================== *)
(* The whole-program theorem about the actual f_main from generated/toy.v.     *)
(*                                                                            *)
(* Running main() from any memory m preserves the value at ANY block that      *)
(* already existed in m (in particular the global gUnrelated). No aliasing     *)
(* precondition: main only writes a fresh stack local, whose block is distinct *)
(* from every pre-existing block BY ALLOCATION FRESHNESS.                      *)
(* ========================================================================== *)

Theorem main_preserves_existing_block :
  forall ge m t m' res b ofs chunk,
    Mem.valid_block m b ->
    eval_funcall function_entry1 ge m (Internal f_main) nil t m' res ->
    Mem.load chunk m' b ofs = Mem.load chunk m b ofs.
Proof.
  intros ge m t m' res b ofs chunk Hvalid Heval.
  inv Heval.
  (* function_entry1: no params, one local _obj. *)
  match goal with Hfe : function_entry1 _ _ _ _ _ _ _ |- _ => inv Hfe end.
  (* Reduce the projections fn_params/fn_vars of the concrete f_main. *)
  match goal with Hav : alloc_variables _ _ _ ?vl _ _ |- _ =>
    replace vl with ((_obj, Tstruct _Object noattr) :: nil) in Hav by reflexivity
  end.
  match goal with Hbp : bind_parameters _ _ _ ?pl _ _ |- _ =>
    replace pl with (@nil (ident * type)) in Hbp by reflexivity
  end.
  (* Invert alloc of the single local: one Mem.alloc, then nil. *)
  match goal with Hav : alloc_variables _ _ _ (_ :: _) _ _ |- _ => inv Hav end.
  match goal with Hav : alloc_variables _ _ _ nil _ _ |- _ => inv Hav end.
  (* bind_parameters nil: post-entry memory = post-alloc memory. *)
  match goal with Hbp : bind_parameters _ _ _ nil _ _ |- _ => inv Hbp end.
  (* The inversions already named the post-alloc memory (m1), post-body memory
     (m2), and the freshly allocated local block; rename the latter to b_obj. *)
  match goal with Halloc : Mem.alloc _ _ _ = (_, ?bobj) |- _ => set (b_obj := bobj) in * end.
  (* b (already valid in m) is distinct from the fresh local block. *)
  assert (Hne : b <> b_obj).
  { apply Mem.valid_not_valid_diff with (m := m); auto.
    eapply Mem.fresh_block_alloc; eauto. }
  (* The body performs exactly one assignment, into obj.timer. *)
  match goal with Hexec : exec_stmt _ _ _ _ ?mm (fn_body f_main) _ _ _ _ |- _ =>
    edestruct exec_main_body_assign as (loc & ofs0 & bf & v & Hlv & Hassign);
      [ exact Hexec | ] end.
  (* The l-value obj.timer lives in the local block b_obj. *)
  assert (Hloc : loc = b_obj).
  { inv Hlv;
    (* Efield_union branch: typeof (Evar _obj ..) = Tunion is false (it's a struct) *)
    try (match goal with H7 : typeof (Evar _ _) = Tunion _ _ |- _ =>
           simpl in H7; discriminate end);
    (* Efield_struct branch: base addr via eval_expr (Evar _obj) ->
       eval_Elvalue -> eval_lvalue (Evar _obj); peel both layers *)
    match goal with He : eval_expr _ _ _ _ (Evar _ _) _ |- _ => inv He end;
    (* deref_loc of the struct-typed base is By_reference: returns ptr unchanged.
       The other deref_loc constructors carry a contradictory access_mode hyp. *)
    match goal with Hd : deref_loc _ _ _ _ _ _ |- _ => inv Hd end;
    repeat match goal with
    | Hm : access_mode (typeof _) = _ |- _ => simpl in Hm; try discriminate
    | Hm : access_mode (Tstruct _ _) = _ |- _ => simpl in Hm; try discriminate
    end;
    match goal with Hl : eval_lvalue _ _ _ _ (Evar _ _) _ _ _ |- _ => inv Hl end;
    match goal with
    | He : (PTree.set _obj (b_obj, _) _) ! _obj = Some _ |- _ =>
        rewrite PTree.gss in He; inv He; reflexivity
    | He : (PTree.set _obj (b_obj, _) _) ! _obj = None |- _ =>
        rewrite PTree.gss in He; discriminate
    end. }
  subst loc.
  (* free_list frees exactly the local block b_obj. *)
  match goal with Hfl : Mem.free_list m2 (blocks_of_env ge ?ev) = Some m' |- _ =>
    assert (Hbe : blocks_of_env ge ev
                  = (b_obj, 0, sizeof ge (Tstruct _Object noattr)) :: nil)
      by reflexivity;
    rewrite Hbe in Hfl; rename Hfl into Hfree end.
  (* Compose: load m' = load m2 (free) = load m1 (assign) = load m (alloc). *)
  transitivity (Mem.load chunk m2 b ofs).
  { eapply free_list_load_unchanged; eauto.
    intros bb lo hi Hin. simpl in Hin. destruct Hin as [Heq | []].
    inv Heq. exact Hne. }
  transitivity (Mem.load chunk m1 b ofs).
  { eapply assign_loc_load_other; eauto. }
  { eapply Mem.load_alloc_unchanged; eauto. }
Qed.
