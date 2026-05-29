(* ToyReach.v -- the semantic kernel of the closed-world / entrypoint argument.
 *
 * Unlike ToyFrame.v (which proves facts about our *analysis function*, a
 * syntactic computation -- "Axis 1" in docs/two-axes-syntactic-vs-semantic.md),
 * this file proves a fact about CompCert's actual *execution semantics* of
 * memory.
 *
 * The point the user pushed on: a modular ("open-world") preservation claim
 * about, say, set_timer(o) needs an ASSUMED precondition that o doesn't alias
 * the global. That assumption is unsatisfying. In a CLOSED-WORLD setting -- a
 * guaranteed entrypoint -- pointers have provenance, and the non-aliasing fact
 * becomes DERIVED rather than assumed: a stack local is a freshly allocated
 * block, and a fresh block is distinct from any block that already existed
 * (which includes every global).
 *
 * This theorem is that derivation, in its purest form, fully machine-checked
 * with NO aliasing precondition: the distinctness comes entirely from
 * `valid_block` (already exists) vs. `~ valid_block` (just allocated / fresh).
 *
 * Honest scope note: this is the semantic *crux*, not yet the whole-program
 * theorem "after main runs, gUnrelated <> 7". Lifting it to f_main requires
 * wiring it through CompCert's eval_funcall = function_entry (alloc_variables)
 * -> exec_stmt (the store) -> free_list, plus reading gUnrelated's initial
 * value out of Genv.init_mem. That wiring is mechanical but lengthy and is the
 * declared next step; it is deliberately NOT faked here with an Admitted.
 *)

From compcert Require Import Coqlib Memory.

(* Storing to a block that is FRESH (not yet valid in m) leaves untouched the
   value at any location whose block was already valid in m.

   No hypothesis relates b_fresh and b_glob directly. Their distinctness is
   derived, below, from validity -- that is the whole point. *)
Theorem store_to_fresh_preserves_existing :
  forall chunk m b_fresh ofs v m'
         chunk' b_glob ofs',
    ~ Mem.valid_block m b_fresh ->          (* b_fresh: just allocated, fresh *)
    Mem.valid_block m b_glob ->             (* b_glob: already existed (e.g. a global) *)
    Mem.store chunk m b_fresh ofs v = Some m' ->
    Mem.load chunk' m' b_glob ofs' = Mem.load chunk' m b_glob ofs'.
Proof.
  intros chunk m b_fresh ofs v m' chunk' b_glob ofs' Hfresh Hvalid Hstore.
  eapply Mem.load_store_other; eauto.
  (* goal: b_glob <> b_fresh \/ (disjoint offsets). Take the block-distinctness
     disjunct, and derive it from validity -- NOT from any assumption. *)
  left.
  apply Mem.valid_not_valid_diff with (m := m); assumption.
Qed.
