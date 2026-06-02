(* FuncallFrame.v -- THE GENERIC engine->funcall bridge (the `forall f` lemma).
 *
 * exec_body_nf preserves the bundle across a BODY (exec_stmt), under an entry
 * `tmps_off_bm` invariant. This file lifts it to a whole CALL (eval_funcall),
 * ONCE and generically over the function f: any f whose body satisfies the frame
 * check body_nf_ok, called on Mario's pointer in a well-formed heap, preserves the
 * non-flying action invariant. The entry `tmps_off_bm` is DISCHARGED here, not
 * assumed: function_entry2 initialises every temp to Vundef (create_undef_temps),
 * so no tracked pointer temp can alias bm at entry. This is the generalisation of
 * StoreFrameHook over f -- a new chase fn now needs only its body_nf_ok (the
 * dispatcher) + reach + the field wf, never a hand-written eval_funcall inversion.
 *
 * SCOPE (honestly): the premise is body_nf_ok (the frame check), NOT the spine's
 * purely-syntactic `locally_safe`. locally_safe alone is too weak -- it does not
 * constrain pointer aliasing, so it cannot imply preservation. Closing that last
 * gap needs a sound static rootedness analysis (locally_safe + heap separation =>
 * body_nf_ok); this lemma is the semantic half that analysis would feed.
 *)

From compcert Require Import Coqlib Maps AST Integers Values Memory Globalenvs
  Ctypes Clight ClightBigstep Events.
From Coq Require Import List.
Import ListNotations.
From SM64.Generated Require mario.
From SM64.Proofs Require Import Flying ActionValueFrame MarioMemoryWF
  ResetBodystate RootedLvalue TempProvenanceInvariant StatementFrame.

(* create_undef_temps never yields a pointer: every entry is Vundef (or absent). *)
Lemma create_undef_temps_not_ptr :
  forall tl t b o, (create_undef_temps tl) ! t = Some (Vptr b o) -> False.
Proof.
  induction tl as [|[id ty] tl IH]; intros t b o H; simpl in H.
  - rewrite PTree.gempty in H; discriminate.
  - rewrite PTree.gsspec in H. destruct (peq t id) as [|Hne].
    + discriminate H.
    + eapply IH; exact H.
Qed.

(* one-step unfolding of bind_parameter_temps, keeping the name (cbn would expose
   the raw fix and break later by-name matching). *)
Lemma bind_parameter_temps_cons :
  forall id ty xl v vl le,
    bind_parameter_temps ((id, ty) :: xl) (v :: vl) le
    = bind_parameter_temps xl vl (PTree.set id v le).
Proof. reflexivity. Qed.

(* bind_parameter_temps only rewrites the formal-parameter slots; any other temp
   keeps its value from the base environment. *)
Lemma bind_parameter_temps_other :
  forall formals args le le' t,
    bind_parameter_temps formals args le = Some le' ->
    ~ In t (map fst formals) ->
    le' ! t = le ! t.
Proof.
  induction formals as [|[id ty] formals IH]; intros args le le' t Hb Hni; simpl in *.
  - destruct args; inv Hb; reflexivity.
  - destruct args as [|v args]; [ discriminate | ].
    assert (Hid : id <> t) by (intro Hc; apply Hni; left; exact Hc).
    assert (Hrest : ~ In t (map fst formals)) by (intro Hc; apply Hni; right; exact Hc).
    rewrite (IH args (PTree.set id v le) le' t Hb Hrest).
    rewrite PTree.gso by (apply not_eq_sym; exact Hid). reflexivity.
Qed.

(* the first formal gets the first argument (it is distinct from the others). *)
Lemma bind_parameter_temps_get_first :
  forall id ty xl v vl base le',
    bind_parameter_temps ((id, ty) :: xl) (v :: vl) base = Some le' ->
    ~ In id (map fst xl) ->
    le' ! id = Some v.
Proof.
  intros id ty xl v vl base le' Hb Hni.
  rewrite bind_parameter_temps_cons in Hb.
  rewrite (bind_parameter_temps_other _ _ _ _ _ Hb Hni). apply PTree.gss.
Qed.

(* a non-first, non-formal temp keeps its base value. *)
Lemma bind_parameter_temps_get_temp :
  forall id ty xl v vl base le' t,
    bind_parameter_temps ((id, ty) :: xl) (v :: vl) base = Some le' ->
    t <> id ->
    ~ In t (map fst xl) ->
    le' ! t = base ! t.
Proof.
  intros id ty xl v vl base le' t Hb Hne Hni.
  rewrite bind_parameter_temps_cons in Hb.
  rewrite (bind_parameter_temps_other _ _ _ _ _ Hb Hni).
  apply PTree.gso. congruence.
Qed.

(* ================================================================== *)
(* THE GENERIC FUNCALL BRIDGE. For ANY f with:                          *)
(*   - no stack vars (fn_vars = nil, the clightgen-normalised shape),    *)
(*   - _m as its first formal parameter,                                 *)
(*   - PT tracking only temps of f,                                      *)
(*   - its body satisfying the frame check body_nf_ok,                   *)
(* a call on Mario's pointer (Vptr bm 0 :: rest) in a well-formed heap   *)
(* (mem_wf FS) preserves the action invariant. reach handles its calls.  *)
(* ================================================================== *)
Theorem funcall_body_nf_preserves :
  forall (PT : ident -> bool) (FS : list ident) (Q : int -> Prop) (bm : block)
         (f : function) rest m m' t res,
    reach_frame_preserves FS Q bm mario_ge ->
    fn_vars f = nil ->
    (exists ty rest_formals,
        fn_params f = (mario._m, ty) :: rest_formals
        /\ ~ In mario._m (map fst rest_formals)
        /\ (forall t0, PT t0 = true -> ~ In t0 (map fst rest_formals))) ->
    (forall e, body_nf_ok PT FS bm e (fn_body f)) ->
    Mem.valid_block m bm ->
    action_sat Q m bm ->
    mem_wf FS m bm ->
    eval_funcall function_entry2 mario_ge m (Internal f)
      (Vptr bm Ptrofs.zero :: rest) t m' res ->
    action_sat Q m' bm.
Proof.
  intros PT FS Q bm f rest m m' t res Hreach Hvars
         (ty & rest_formals & Hparams & Hmnotin & Hptfresh) Hok Hv Hsat Hwf Hfun.
  inv Hfun.
  match goal with Hfe : function_entry2 _ _ _ _ _ _ _ |- _ => inv Hfe end.
  match goal with Hav : alloc_variables _ _ _ _ _ _ |- _ =>
    rewrite Hvars in Hav; inv Hav end.
  (* read off le1's relevant entries via the bind helpers (applied to the
     full-params bind, so no fragile residual matching) *)
  match goal with Hbp : bind_parameter_temps _ _ _ = Some ?le1 |- _ =>
    rewrite Hparams in Hbp;
    assert (Hmle : le1 ! mario._m = Some (Vptr bm Ptrofs.zero)) by
      (eapply bind_parameter_temps_get_first; [ exact Hbp | exact Hmnotin ]);
    assert (Htmps : tmps_off_bm PT bm mario._m le1) by
      (intros t0 b o Hpt Hne Hlk;
       rewrite (bind_parameter_temps_get_temp _ _ _ _ _ _ _ _ Hbp Hne (Hptfresh t0 Hpt)) in Hlk;
       exfalso; eapply create_undef_temps_not_ptr; exact Hlk);
    pose proof (exec_body_nf PT FS Q bm Hreach _ le1 _ _ t _ _ _
                  ltac:(eassumption)
                  (conj Hv (conj Hsat (conj Htmps (conj Hwf Hmle)))) (Hok _)) as Hfr'
  end.
  match goal with Hfree : Mem.free_list _ _ = Some _ |- _ =>
    assert (Hbe : blocks_of_env mario_ge empty_env = nil) by reflexivity;
    rewrite Hbe in Hfree; cbn [Mem.free_list] in Hfree; inv Hfree end.
  unfold fr in Hfr'. tauto.
Qed.
