(* ActionFrame.v -- the SEMANTIC frame lemma: field non-interference.
 *
 * WHY THIS FILE. Everything proved so far about Mario's `action` field
 * (Flying.v's flying_setters / writes_mario_action_s, ActionWriters.v's
 * whole-batch scan) is SYNTACTIC: "this pattern does not occur in the AST".
 * To make any of it mean something about EXECUTIONS we need the bridge:
 *
 *     a store to field f1 of a struct leaves a DIFFERENT field f2 unchanged.
 *
 * That is the field-granular analogue of Havoc.v's regime 1 (a store to a
 * different *global* preserves g, via block distinctness). Here the two
 * locations share a block but sit at disjoint byte ranges WITHIN the struct;
 * the disjointness comes from CompCert's `field_offset_no_overlap`.
 *
 * This is the genuinely new semantic content. Once we have it, the syntactic
 * `writes_mario_action_s s = false` corpus can be lifted to "executing s
 * preserves m->action" (an induction over exec_stmt), which is in turn R3's
 * inductive step. Those lifts are named as future rungs below.
 *
 * SCOPE / what this file does and does NOT yet do (no buried ledes):
 *   - It proves the MEMORY-level core at raw integer offsets (Mem.store / a
 *     common base offset), for two `Full` (non-bitfield) scalar fields. This is
 *     the mathematical heart.
 *   - Rung (a) IS now done: Brick 3 (assign_loc_field_preserves_other_loadv)
 *     lifts the raw store to a Clight `assign_loc` (By_value) into field f1 vs
 *     a `Mem.loadv` of field f2, with both addresses computed as
 *     `Ptrofs.add ofs0 (repr delta)` off a common base pointer. The Ptrofs<->Z
 *     gap is bridged by two EXPLICIT no-overflow side conditions on the field
 *     addresses (later rungs discharge them from `field_compatible`).
 *   - Rung (b) IS now done: exec_stmt_callfree_unchanged_on lifts per-store
 *     non-interference over a WHOLE Clight statement by induction on exec_stmt
 *     (composing via Mem.unchanged_on), with payoff corollary
 *     exec_stmt_preserves_watched_load. Two boundaries are made EXPLICIT, in
 *     the house style of Havoc.v regime 2: `call_free s` (calls -> rung (c))
 *     and `stmt_assigns_avoid` (every Sassign avoids the watched bytes = the
 *     leak-#1 aliasing side condition). NOTE: writes_mario_action_s=false is
 *     NOT semantically sufficient on its own -- it is `false` on Scall and on
 *     aliasing pointer stores -- so the bridge consumes the explicit
 *     stmt_assigns_avoid, which writes_mario_action_s + escape are meant to
 *     DISCHARGE (named, not hidden).
 *   - Rung (c) Phase 1+2 IS now done: exec_funcall_reach_unchanged_on lifts the
 *     statement-level frame ACROSS CALLS, by the mutual exec_stmt/eval_funcall
 *     induction (CompCert's Combined Scheme exec_stmt_funcall_ind). A call's
 *     three layers (function_entry2 alloc / body / free_list) each preserve a
 *     watched byte-set P that lives in blocks valid at entry: the Phase-1 leaves
 *     (function_entry2_unchanged_on, free_list_unchanged_on) handle the frame
 *     alloc/free, with function_entry2_fresh proving the callee's locals are
 *     fresh (so freeing them can't touch P); P-validity is threaded forward via
 *     Mem.valid_block_unchanged_on (memory only grows). The remaining Phase-3
 *     content is stated as TWO EXPLICIT global hypotheses (honest boundary, no
 *     hidden lede): reach_body_avoids (every internal fn body's Sassigns avoid P
 *     -- to be DERIVED later from the syntactic non-writers + local freshness)
 *     and reach_ext_preserves (reached externals/builtins preserve P). Payoff:
 *     exec_stmt_reach_preserves_watched_load -- the watched-load corollary with
 *     `call_free` GONE. Still open: discharging the two reach_* hypotheses from
 *     ActionWriters' syntactic scan (Phase 3) and the named leaks (#2 indirect
 *     calls via Genv.find_funct, #3 whole-program Linking).
 *   - Abstract over any composite_env / members list. The abstract bricks are
 *     now ALSO instantiated on the real MarioState composite at the bottom of
 *     this file (store_other_field_preserves_action / store_flags_preserves_action,
 *     à la Havoc's flying-carpet instance) -- field offsets discharged by
 *     vm_compute over the real prog_comp_env mario.prog, not asserted by hand.
 *
 * AXIOM STATUS (Print Assumptions, verified): the two pure lemmas
 * (size_chunk_by_value, full_fields_size_disjoint) are "Closed under the global
 * context". The memory lemma store_field_preserves_other_field rests on
 * CompCert's 4 standard axioms (Classical_Prop.classic, FunctionalExtensionality,
 * two ClassicalDedekindReals -- the Flocq float base). This is NOT a proof defect
 * and NOT extra trust we introduced: the lemma's *statement* mentions `sizeof ce
 * ty`, whose computation over real C types recurses through float-carrying
 * definitions, and Print Assumptions traverses the statement's type. It is the
 * same phenomenon ActionWriters.v documents for any prog-typed statement; the
 * whole CompCert correctness theorem rests on exactly these four axioms.
 *)

From compcert Require Import Coqlib Errors Maps AST Integers Values Events Memory Globalenvs Ctypes Cop Clight ClightBigstep.
From SM64.Generated Require mario.

(* ------------------------------------------------------------------ *)
(* Connector: for a by-value (scalar) access, the memory chunk's size  *)
(* equals the C sizeof. For scalar types sizeof is independent of the  *)
(* composite_env, so this holds for any ce. (Mirrors the inner assert  *)
(* of CompCert's SimplLocalsproof.sizeof_by_value.)                    *)
(* ------------------------------------------------------------------ *)
Lemma size_chunk_by_value :
  forall (ce : composite_env) ty chunk,
    access_mode ty = By_value chunk -> size_chunk chunk = sizeof ce ty.
Proof.
  unfold access_mode; intros ce ty chunk H.
  destruct ty; try destruct i; try destruct s; try destruct f; inv H; auto;
  unfold Mptr; simpl; destruct Archi.ptr64; auto.
Qed.

(* ------------------------------------------------------------------ *)
(* Brick 1 (pure arithmetic): two DISTINCT Full scalar fields of the   *)
(* same members list occupy disjoint byte ranges [ofs, ofs+chunk).     *)
(* Derived from field_offset_no_overlap (which speaks in bit units:    *)
(* layout_start ofs Full = ofs*8, layout_width ce ty Full = sizeof*8)  *)
(* plus the size_chunk = sizeof connector, divided back to bytes.       *)
(* ------------------------------------------------------------------ *)
Lemma full_fields_size_disjoint :
  forall (ce : composite_env) f1 ofs1 ty1 f2 ofs2 ty2 ms chunk1 chunk2,
    field_offset ce f1 ms = OK (ofs1, Full) -> field_type f1 ms = OK ty1 ->
    field_offset ce f2 ms = OK (ofs2, Full) -> field_type f2 ms = OK ty2 ->
    f1 <> f2 ->
    access_mode ty1 = By_value chunk1 ->
    access_mode ty2 = By_value chunk2 ->
    ofs1 + size_chunk chunk1 <= ofs2 \/ ofs2 + size_chunk chunk2 <= ofs1.
Proof.
  intros ce f1 ofs1 ty1 f2 ofs2 ty2 ms chunk1 chunk2
         Hfo1 Hft1 Hfo2 Hft2 Hne Ham1 Ham2.
  pose proof (field_offset_no_overlap ce f1 ofs1 Full ty1 f2 ofs2 Full ty2 ms
                Hfo1 Hft1 Hfo2 Hft2 Hne) as Hov.
  rewrite (size_chunk_by_value ce ty1 chunk1 Ham1).
  rewrite (size_chunk_by_value ce ty2 chunk2 Ham2).
  unfold layout_start, layout_width, bitsizeof in Hov.
  lia.
Qed.

(* ------------------------------------------------------------------ *)
(* Brick 2 (memory): a Mem.store into Full field f1 (at byte address   *)
(* base+ofs1) leaves a load from the DISTINCT Full field f2 (at base+  *)
(* ofs2) unchanged. The single non-trivial step is supplying the       *)
(* disjointness condition of Mem.load_store_other from Brick 1.        *)
(* Offsets are raw Z (a common `base` plus each field offset), so this  *)
(* brick is free of Ptrofs-overflow bookkeeping -- that, and the lift  *)
(* to Clight assign_loc, are the next rungs.                            *)
(* ------------------------------------------------------------------ *)
Lemma store_field_preserves_other_field :
  forall (ce : composite_env) m b base
         f1 ofs1 ty1 chunk1 v m'
         f2 ofs2 ty2 chunk2 ms,
    field_offset ce f1 ms = OK (ofs1, Full) -> field_type f1 ms = OK ty1 ->
    field_offset ce f2 ms = OK (ofs2, Full) -> field_type f2 ms = OK ty2 ->
    f1 <> f2 ->
    access_mode ty1 = By_value chunk1 ->
    access_mode ty2 = By_value chunk2 ->
    Mem.store chunk1 m b (base + ofs1) v = Some m' ->
    Mem.load chunk2 m' b (base + ofs2) = Mem.load chunk2 m b (base + ofs2).
Proof.
  intros ce m b base f1 ofs1 ty1 chunk1 v m' f2 ofs2 ty2 chunk2 ms
         Hfo1 Hft1 Hfo2 Hft2 Hne Ham1 Ham2 Hstore.
  pose proof (full_fields_size_disjoint ce f1 ofs1 ty1 f2 ofs2 ty2 ms chunk1 chunk2
                Hfo1 Hft1 Hfo2 Hft2 Hne Ham1 Ham2) as Hd.
  eapply Mem.load_store_other; [ exact Hstore | ].
  destruct Hd as [Hd | Hd]; [ right; right; lia | right; left; lia ].
Qed.

(* ------------------------------------------------------------------ *)
(* Brick 3 (Clight level): rung (a). The same non-interference, but for *)
(* a Clight `assign_loc` (By_value) into field f1 and a `Mem.loadv` of   *)
(* field f2, with BOTH addresses computed as `Ptrofs.add ofs0 (repr      *)
(* delta)` off a common base pointer `Vptr b ofs0` -- exactly how Clight *)
(* evaluates an Efield lvalue. The Ptrofs<->Z gap is bridged by two      *)
(* EXPLICIT no-overflow side conditions on the two field addresses (the  *)
(* honest hypotheses the header promised); later rungs discharge them    *)
(* from `field_compatible` / the enclosing block's size bound.           *)
(* ------------------------------------------------------------------ *)
Lemma assign_loc_field_preserves_other_loadv :
  forall (ce : composite_env) m b ofs0
         f1 ofs1 ty1 chunk1 v m'
         f2 ofs2 ty2 chunk2 ms,
    field_offset ce f1 ms = OK (ofs1, Full) -> field_type f1 ms = OK ty1 ->
    field_offset ce f2 ms = OK (ofs2, Full) -> field_type f2 ms = OK ty2 ->
    f1 <> f2 ->
    access_mode ty1 = By_value chunk1 ->
    access_mode ty2 = By_value chunk2 ->
    (* no-overflow side conditions on the two field addresses: *)
    Ptrofs.unsigned (Ptrofs.add ofs0 (Ptrofs.repr ofs1)) = Ptrofs.unsigned ofs0 + ofs1 ->
    Ptrofs.unsigned (Ptrofs.add ofs0 (Ptrofs.repr ofs2)) = Ptrofs.unsigned ofs0 + ofs2 ->
    assign_loc ce ty1 m b (Ptrofs.add ofs0 (Ptrofs.repr ofs1)) Full v m' ->
    Mem.loadv chunk2 m' (Vptr b (Ptrofs.add ofs0 (Ptrofs.repr ofs2)))
    = Mem.loadv chunk2 m  (Vptr b (Ptrofs.add ofs0 (Ptrofs.repr ofs2))).
Proof.
  intros ce m b ofs0 f1 ofs1 ty1 chunk1 v m' f2 ofs2 ty2 chunk2 ms
         Hfo1 Hft1 Hfo2 Hft2 Hne Ham1 Ham2 Hov1 Hov2 Hassign.
  (* inversion yields the By_value store goal + the By_copy goal; the    *)
  (* latter has access_mode ty1 = By_copy, impossible given Ham1.         *)
  inversion Hassign; subst.
  - (* assign_loc_value: use the inversion-introduced chunk directly *)
    match goal with
    | Hs : Mem.storev ?ck _ _ _ = Some _,
      Ha : access_mode ty1 = By_value ?ck |- _ =>
        unfold Mem.storev in Hs; unfold Mem.loadv;
        rewrite Hov1 in Hs; rewrite Hov2;
        eapply (store_field_preserves_other_field
                  ce m b (Ptrofs.unsigned ofs0)
                  f1 ofs1 ty1 ck v _
                  f2 ofs2 ty2 chunk2 ms
                  Hfo1 Hft1 Hfo2 Hft2 Hne Ha Ham2 Hs)
    end.
  - (* assign_loc_copy: By_copy contradicts Ham1 (By_value) *)
    congruence.
Qed.

(* ================================================================== *)
(* RUNG (b): the exec_stmt induction. Lift `the statement performs no  *)
(* store overlapping the watched bytes` to `executing it preserves the *)
(* watched location`, over a whole Clight statement.                   *)
(*                                                                     *)
(* HONEST SCOPE (no buried ledes). Two boundaries are made EXPLICIT:    *)
(*   - call_free s = true : no Scall / Sbuiltin. A call may write the   *)
(*     field through a callee (set_mario_action!), which the syntactic  *)
(*     writes_mario_action_s does NOT see (it is `false` on Scall). So  *)
(*     calls are deferred to rung (c) (Reach.v's callgraph) -- exactly  *)
(*     as the file header states.                                       *)
(*   - assigns_avoid : every Sassign in s lands OUTSIDE the watched     *)
(*     bytes, FOR ALL states. This is the leak-#1 (aliasing) boundary,  *)
(*     made an explicit hypothesis in the house style of Havoc.v's      *)
(*     regime 2 (b' <> bg as a hypothesis). For the action field it is  *)
(*     what writes_mario_action_s=false + the escape/separation rung    *)
(*     are meant to DISCHARGE; here it is assumed, the obligation named. *)
(* The induction itself -- composing per-store non-interference across  *)
(* sequencing, branches, loops and switches via Mem.unchanged_on -- is  *)
(* the new content.                                                     *)
(* ================================================================== *)

(* Leaf: a single assign_loc that avoids the watched byte-set P leaves  *)
(* P unchanged. Uniform over all three assign_loc kinds (By_value,      *)
(* By_copy, bitfield); each writes within [ofs, ofs + sizeof ce ty).    *)
Lemma assign_loc_unchanged_on :
  forall (P : block -> Z -> Prop) ce ty m loc ofs bf v m',
    assign_loc ce ty m loc ofs bf v m' ->
    (forall i, Ptrofs.unsigned ofs <= i < Ptrofs.unsigned ofs + sizeof ce ty ->
               ~ P loc i) ->
    Mem.unchanged_on P m m'.
Proof.
  intros P ce ty m loc ofs bf v m' Hassign Havoid.
  (* inv yields three goals (By_value / By_copy / bitfield); handle each *)
  (* with the matching store lemma. We use an explicit split rather than  *)
  (* `-` bullets because eapply shelves goals and reorders the focus.     *)
  inv Hassign.
  - (* By_value: store of chunk, size_chunk chunk = sizeof ce ty *)
    match goal with
    | Ham : access_mode ty = By_value ?chunk,
      Hs  : Mem.storev ?chunk _ _ _ = Some _ |- _ =>
        unfold Mem.storev in Hs;
        eapply Mem.store_unchanged_on;
          [ exact Hs
          | intros i Hi; apply Havoid;
            rewrite <- (size_chunk_by_value ce ty chunk Ham); exact Hi ]
    end.
  - (* By_copy: storebytes of (sizeof ce ty) bytes *)
    match goal with
    | Hlb : Mem.loadbytes _ _ _ _ = Some ?bytes,
      Hsb : Mem.storebytes _ _ _ ?bytes = Some _ |- _ =>
        eapply Mem.storebytes_unchanged_on;
          [ exact Hsb
          | intros i Hi; apply Havoid;
            apply Mem.loadbytes_length in Hlb;
            rewrite Hlb in Hi;
            rewrite Z2Nat.id in Hi by (pose proof (sizeof_pos ce ty); lia);
            exact Hi ]
    end.
  - (* bitfield: storev of (chunk_for_carrier sz) within the Tint field *)
    match goal with Hbf : store_bitfield _ _ _ _ _ _ _ _ _ _ |- _ => inv Hbf end.
    match goal with
    | Hs : Mem.storev (chunk_for_carrier ?sz) _ _ _ = Some _ |- _ =>
        unfold Mem.storev in Hs;
        eapply Mem.store_unchanged_on;
          [ exact Hs
          | intros i Hi; apply Havoid;
            replace (sizeof ce (Tint sz _ _))
              with (size_chunk (chunk_for_carrier sz)) by (destruct sz; reflexivity);
            exact Hi ]
    end.
Qed.

(* ------------------------------------------------------------------ *)
(* call_free: the statement contains no Scall and no Sbuiltin anywhere. *)
(* This is the leak-#2/#3 boundary: a call may mutate the watched field  *)
(* through a callee, invisibly to the syntactic single-statement scan.   *)
(* ------------------------------------------------------------------ *)
Fixpoint call_free_s (s : statement) : bool :=
  match s with
  | Sskip | Sset _ _ | Sassign _ _ | Sbreak | Scontinue
  | Sreturn _ | Sgoto _                 => true
  | Scall _ _ _ | Sbuiltin _ _ _ _      => false
  | Ssequence s1 s2 | Sifthenelse _ s1 s2 | Sloop s1 s2
                                        => call_free_s s1 && call_free_s s2
  | Slabel _ s1                         => call_free_s s1
  | Sswitch _ ls                        => call_free_ls ls
  end
with call_free_ls (ls : labeled_statements) : bool :=
  match ls with
  | LSnil           => true
  | LScons _ s rest => call_free_s s && call_free_ls rest
  end.

(* ------------------------------------------------------------------ *)
(* assign_avoids P ge e a1: the lvalue a1 (in env e), whatever local     *)
(* state it is evaluated in, names a location whose written byte-range   *)
(* [ofs, ofs + sizeof ty) is disjoint from the watched byte-set P. This  *)
(* is the per-store leak-#1 (aliasing) side condition, quantified over   *)
(* all (le,m) so it can be consumed at any point in the execution.       *)
(* ------------------------------------------------------------------ *)
Definition assign_avoids (P : block -> Z -> Prop) (ge : genv) (e : env) (a1 : expr) : Prop :=
  forall le m loc ofs bf,
    eval_lvalue ge e le m a1 loc ofs bf ->
    forall i, Ptrofs.unsigned ofs <= i < Ptrofs.unsigned ofs + sizeof ge (typeof a1) ->
              ~ P loc i.

(* Structural lifting of assign_avoids over a whole statement: every      *)
(* Sassign occurring in s avoids P. (Scall/Sbuiltin map to True here but  *)
(* are excluded separately by call_free.)                                 *)
Fixpoint stmt_assigns_avoid (P : block -> Z -> Prop) (ge : genv) (e : env) (s : statement) : Prop :=
  match s with
  | Sassign a1 _        => assign_avoids P ge e a1
  | Ssequence s1 s2     => stmt_assigns_avoid P ge e s1 /\ stmt_assigns_avoid P ge e s2
  | Sifthenelse _ s1 s2 => stmt_assigns_avoid P ge e s1 /\ stmt_assigns_avoid P ge e s2
  | Sloop s1 s2         => stmt_assigns_avoid P ge e s1 /\ stmt_assigns_avoid P ge e s2
  | Slabel _ s1         => stmt_assigns_avoid P ge e s1
  | Sswitch _ ls        => ls_assigns_avoid P ge e ls
  | _                   => True
  end
with ls_assigns_avoid (P : block -> Z -> Prop) (ge : genv) (e : env) (ls : labeled_statements) : Prop :=
  match ls with
  | LSnil           => True
  | LScons _ s rest => stmt_assigns_avoid P ge e s /\ ls_assigns_avoid P ge e rest
  end.

(* Structural lemmas: select_switch / seq_of_labeled_statement preserve  *)
(* both call_free and assigns_avoid (the switch case of the induction).   *)
Lemma call_free_ssd :
  forall sl, call_free_ls sl = true -> call_free_ls (select_switch_default sl) = true.
Proof.
  induction sl as [| o s rest IH]; simpl; intros H; auto.
  destruct o as [c|]; auto.
  apply andb_true_iff in H; destruct H; auto.
Qed.

Lemma call_free_ssc :
  forall n sl res,
    call_free_ls sl = true -> select_switch_case n sl = Some res -> call_free_ls res = true.
Proof.
  induction sl as [| o s rest IH]; simpl; intros res H Hsel; try discriminate.
  apply andb_true_iff in H; destruct H as [Hs Hrest].
  destruct o as [c|].
  - destruct (zeq c n).
    + inv Hsel. simpl. rewrite Hs, Hrest; auto.
    + eapply IH; eauto.
  - eapply IH; eauto.
Qed.

Lemma call_free_select_switch :
  forall n sl, call_free_ls sl = true -> call_free_ls (select_switch n sl) = true.
Proof.
  intros n sl H. unfold select_switch.
  destruct (select_switch_case n sl) eqn:E.
  - eapply call_free_ssc; eauto.
  - apply call_free_ssd; auto.
Qed.

Lemma call_free_seq_of_ls :
  forall ls, call_free_ls ls = true -> call_free_s (seq_of_labeled_statement ls) = true.
Proof.
  induction ls as [| o s rest IH]; simpl; intros H; auto.
  apply andb_true_iff in H; destruct H. rewrite H. simpl. auto.
Qed.

Lemma ssd_assigns_avoid :
  forall P ge e sl, ls_assigns_avoid P ge e sl -> ls_assigns_avoid P ge e (select_switch_default sl).
Proof.
  induction sl as [| o s rest IH]; simpl; intros H; auto.
  destruct o as [c|]; simpl.
  - destruct H as [_ Hrest]. apply IH; exact Hrest.
  - exact H.
Qed.

Lemma ssc_assigns_avoid :
  forall P ge e n sl res,
    ls_assigns_avoid P ge e sl -> select_switch_case n sl = Some res ->
    ls_assigns_avoid P ge e res.
Proof.
  induction sl as [| o s rest IH]; simpl; intros res Hav Hsel; try discriminate.
  destruct Hav as [Hs Hrest]. destruct o as [c|]; simpl in Hsel.
  - destruct (zeq c n).
    + inv Hsel. simpl. split; [ exact Hs | exact Hrest ].
    + eapply IH; eauto.
  - eapply IH; eauto.
Qed.

Lemma select_switch_assigns_avoid :
  forall P ge e n sl,
    ls_assigns_avoid P ge e sl -> ls_assigns_avoid P ge e (select_switch n sl).
Proof.
  intros P ge e n sl H. unfold select_switch.
  destruct (select_switch_case n sl) eqn:E.
  - eapply ssc_assigns_avoid; eauto.
  - apply ssd_assigns_avoid; auto.
Qed.

Lemma seq_of_ls_assigns_avoid :
  forall P ge e ls,
    ls_assigns_avoid P ge e ls -> stmt_assigns_avoid P ge e (seq_of_labeled_statement ls).
Proof.
  induction ls as [| o s rest IH]; simpl; intros H; auto.
  destruct H. split; auto.
Qed.

(* ================================================================== *)
(* The rung-(b) theorem: a call-free statement, all of whose Sassigns  *)
(* avoid the watched byte-set P, preserves P across execution.         *)
(* Proof = induction on exec_stmt, composing per-store non-interference *)
(* (assign_loc_unchanged_on) via Mem.unchanged_on transitivity. Calls   *)
(* are ruled out by call_free (discriminate); the aliasing side         *)
(* condition is carried by stmt_assigns_avoid.                          *)
(* ================================================================== *)
Theorem exec_stmt_callfree_unchanged_on :
  forall (P : block -> Z -> Prop) fe ge e le m s t le' m' out,
    exec_stmt fe ge e le m s t le' m' out ->
    call_free_s s = true ->
    stmt_assigns_avoid P ge e s ->
    Mem.unchanged_on P m m'.
Proof.
  intros P fe ge e le m s t le' m' out H.
  induction H; intros Hcf Hav; simpl in Hcf, Hav;
    (* leaves with no memory effect; calls excluded by call_free *)
    try (apply Mem.unchanged_on_refl); try discriminate.
  - (* Sassign: the one store; discharge via the leaf lemma + avoidance *)
    eapply assign_loc_unchanged_on; [ eassumption | ].
    intros i Hi. eapply Hav; eauto.
  - (* Ssequence, s1 normal then s2 *)
    eapply Mem.unchanged_on_trans;
      match goal with
      | IH : (call_free_s _ = true -> _ -> Mem.unchanged_on _ ?x _) |- Mem.unchanged_on _ ?x _ =>
          apply IH;
            first [ exact (proj1 (andb_prop _ _ Hcf)) | exact (proj2 (andb_prop _ _ Hcf))
                  | exact (proj1 Hav) | exact (proj2 Hav) ]
      end.
  - (* Ssequence, s1 abnormal *)
    match goal with
    | IH : (call_free_s _ = true -> _ -> Mem.unchanged_on _ ?x _) |- Mem.unchanged_on _ ?x _ =>
        apply IH;
          first [ exact (proj1 (andb_prop _ _ Hcf)) | exact (proj1 Hav) ]
    end.
  - (* Sifthenelse *)
    match goal with
    | IH : (call_free_s _ = true -> _ -> Mem.unchanged_on _ ?x _) |- Mem.unchanged_on _ ?x _ =>
        apply IH; destruct b;
          first [ exact (proj1 (andb_prop _ _ Hcf)) | exact (proj2 (andb_prop _ _ Hcf))
                | exact (proj1 Hav) | exact (proj2 Hav) ]
    end.
  - (* Sloop_stop1: only s1 ran *)
    match goal with
    | IH : (call_free_s _ = true -> _ -> Mem.unchanged_on _ ?x _) |- Mem.unchanged_on _ ?x _ =>
        apply IH;
          first [ exact (proj1 (andb_prop _ _ Hcf)) | exact (proj1 Hav) ]
    end.
  - (* Sloop_stop2: s1 then s2 *)
    eapply Mem.unchanged_on_trans;
      match goal with
      | IH : (call_free_s _ = true -> _ -> Mem.unchanged_on _ ?x _) |- Mem.unchanged_on _ ?x _ =>
          apply IH;
            first [ exact (proj1 (andb_prop _ _ Hcf)) | exact (proj2 (andb_prop _ _ Hcf))
                  | exact (proj1 Hav) | exact (proj2 Hav) ]
      end.
  - (* Sloop_loop: s1, s2, then the loop again *)
    eapply Mem.unchanged_on_trans;
      [ eapply Mem.unchanged_on_trans | idtac ];
      match goal with
      | IH : (call_free_s _ = true -> _ -> Mem.unchanged_on _ ?x _) |- Mem.unchanged_on _ ?x _ =>
          apply IH;
            first [ assumption
                  | exact (proj1 (andb_prop _ _ Hcf)) | exact (proj2 (andb_prop _ _ Hcf))
                  | exact (proj1 Hav) | exact (proj2 Hav) ]
      end.
  - (* Sswitch: reduce to the selected sequence via the structural lemmas *)
    match goal with
    | IH : (call_free_s _ = true -> _ -> Mem.unchanged_on _ ?x _) |- Mem.unchanged_on _ ?x _ =>
        apply IH;
          [ apply call_free_seq_of_ls; apply call_free_select_switch; exact Hcf
          | apply seq_of_ls_assigns_avoid; apply select_switch_assigns_avoid; exact Hav ]
    end.
Qed.

(* The action-field payoff: instantiate P at the 4 bytes of a watched     *)
(* location (block bm, offset aofs). A call-free statement whose Sassigns  *)
(* all avoid those bytes leaves the value loaded there unchanged. With     *)
(* bm/aofs = the Mario block and its action-field address this is exactly  *)
(* `executing s does not change m->action` -- the per-statement step R3's  *)
(* trace induction consumes (modulo the two named boundaries: calls = rung *)
(* (c), and the aliasing side condition stmt_assigns_avoid = leak #1).     *)
Corollary exec_stmt_preserves_watched_load :
  forall fe ge e le m s t le' m' out bm aofs,
    exec_stmt fe ge e le m s t le' m' out ->
    call_free_s s = true ->
    stmt_assigns_avoid
      (fun b o => b = bm /\ aofs <= o < aofs + size_chunk Mint32) ge e s ->
    Mem.valid_block m bm ->
    Mem.load Mint32 m' bm aofs = Mem.load Mint32 m bm aofs.
Proof.
  intros fe ge e le m s t le' m' out bm aofs Hexec Hcf Hav Hvalid.
  eapply Mem.load_unchanged_on_1.
  - eapply exec_stmt_callfree_unchanged_on; eauto.
  - exact Hvalid.
  - intros i Hi. split; [ reflexivity | exact Hi ].
Qed.

(* ------------------------------------------------------------------ *)
(* CONCRETE INSTANCE on the real MarioState composite (the analogue of *)
(* Havoc.v's flying-carpet corollary). We instantiate the abstract     *)
(* memory brick on the actual clightgen'd struct layout from mario.v:  *)
(* MarioState.action sits at byte offset 12 (Full, Mint32), and every  *)
(* other Full scalar field is disjoint from it. So a store to ANY      *)
(* other field of a MarioState leaves m->action's bytes untouched.     *)
(* The field offsets/types/access-modes are discharged by vm_compute   *)
(* over the real `prog_comp_env mario.prog`, not asserted by hand.      *)
(* ------------------------------------------------------------------ *)
Definition mario_ce : composite_env := prog_comp_env mario.prog.
Definition mario_members : members :=
  match mario_ce ! mario._MarioState with
  | Some co => co_members co
  | None => nil
  end.

(* General: writing any OTHER Full scalar field f of a MarioState (at  *)
(* base+ofs) preserves the load of m->action (at base+12).             *)
Corollary store_other_field_preserves_action :
  forall m b base f ofs ty chunk v m',
    field_offset mario_ce f mario_members = OK (ofs, Full) ->
    field_type f mario_members = OK ty ->
    access_mode ty = By_value chunk ->
    f <> mario._action ->
    Mem.store chunk m b (base + ofs) v = Some m' ->
    Mem.load Mint32 m' b (base + 12) = Mem.load Mint32 m b (base + 12).
Proof.
  intros m b base f ofs ty chunk v m' Hfo Hft Ham Hne Hstore.
  eapply (store_field_preserves_other_field
            mario_ce m b base
            f ofs ty chunk v m'
            mario._action 12 (Tint I32 Unsigned noattr) Mint32
            mario_members).
  - exact Hfo.
  - exact Hft.
  - vm_compute; reflexivity.   (* field_offset action = OK (12, Full) *)
  - vm_compute; reflexivity.   (* field_type   action = OK tuint      *)
  - exact Hne.
  - exact Ham.
  - vm_compute; reflexivity.   (* access_mode tuint = By_value Mint32 *)
  - exact Hstore.
Qed.

(* Fully concrete witness: storing MarioState.flags (offset 4) leaves  *)
(* MarioState.action (offset 12) unchanged. Non-vacuous instance.      *)
Corollary store_flags_preserves_action :
  forall m b base v m',
    Mem.store Mint32 m b (base + 4) v = Some m' ->
    Mem.load Mint32 m' b (base + 12) = Mem.load Mint32 m b (base + 12).
Proof.
  intros m b base v m' Hstore.
  eapply (store_other_field_preserves_action
            m b base mario._flags 4 (Tint I32 Unsigned noattr) Mint32 v m').
  - vm_compute; reflexivity.   (* field_offset flags = OK (4, Full) *)
  - vm_compute; reflexivity.   (* field_type   flags = OK tuint     *)
  - vm_compute; reflexivity.   (* access_mode tuint = By_value Mint32 *)
  - vm_compute; discriminate.  (* flags <> action *)
  - exact Hstore.
Qed.

(* Clight-level (rung a) instance on MarioState: a `assign_loc` (By_value) *)
(* into any OTHER Full scalar field f of a MarioState preserves a loadv of *)
(* m->action, given the two field-address no-overflow side conditions.     *)
Corollary assign_loc_other_field_preserves_action_loadv :
  forall m b ofs0 f ofs ty chunk v m',
    field_offset mario_ce f mario_members = OK (ofs, Full) ->
    field_type f mario_members = OK ty ->
    access_mode ty = By_value chunk ->
    f <> mario._action ->
    Ptrofs.unsigned (Ptrofs.add ofs0 (Ptrofs.repr ofs)) = Ptrofs.unsigned ofs0 + ofs ->
    Ptrofs.unsigned (Ptrofs.add ofs0 (Ptrofs.repr 12)) = Ptrofs.unsigned ofs0 + 12 ->
    assign_loc mario_ce ty m b (Ptrofs.add ofs0 (Ptrofs.repr ofs)) Full v m' ->
    Mem.loadv Mint32 m' (Vptr b (Ptrofs.add ofs0 (Ptrofs.repr 12)))
    = Mem.loadv Mint32 m  (Vptr b (Ptrofs.add ofs0 (Ptrofs.repr 12))).
Proof.
  intros m b ofs0 f ofs ty chunk v m' Hfo Hft Ham Hne Hov1 Hov2 Hassign.
  eapply (assign_loc_field_preserves_other_loadv
            mario_ce m b ofs0
            f ofs ty chunk v m'
            mario._action 12 (Tint I32 Unsigned noattr) Mint32
            mario_members).
  - exact Hfo.
  - exact Hft.
  - vm_compute; reflexivity.   (* field_offset action = OK (12, Full) *)
  - vm_compute; reflexivity.   (* field_type   action = OK tuint      *)
  - exact Hne.
  - exact Ham.
  - vm_compute; reflexivity.   (* access_mode tuint = By_value Mint32 *)
  - exact Hov1.
  - exact Hov2.
  - exact Hassign.
Qed.

(* ================================================================== *)
(* RUNG (c), Phase 1+2: the interprocedural lift.                      *)
(*                                                                     *)
(* Rung (b) stopped at `call_free`: an Scall hands control to a callee *)
(* whose body the single-statement scan cannot see. Rung (c) removes   *)
(* that wall by recursing into the callee via the MUTUAL induction     *)
(* exec_stmt / eval_funcall (CompCert's Combined Scheme                 *)
(* exec_stmt_funcall_ind).                                             *)
(*                                                                     *)
(* A function call's memory effect is exactly three layers             *)
(* (eval_funcall_internal):                                            *)
(*     function_entry2 ge f vargs m e le1 m1   -- alloc fresh locals    *)
(*     exec_stmt        e le1 m1 (fn_body f) ... m2 ...  -- run body     *)
(*     Mem.free_list    m2 (blocks_of_env ge e) = Some m3 -- free them   *)
(* For a watched location P over blocks VALID in m (e.g. the caller's   *)
(* Mario block, passed by pointer -- never a callee local):            *)
(*   - entry only ALLOCATES fresh blocks, so preserves P (any P);       *)
(*   - free_list frees only the callee's own frame, all fresh hence     *)
(*     != any P-block, so preserves P;                                  *)
(*   - the body preserves P by the mutual IH, PROVIDED its Sassigns     *)
(*     avoid P -- which is supplied by the global hypothesis            *)
(*     `reach_body_avoids` below (the Phase-3 content, stated here as    *)
(*     an explicit assumption, not yet discharged from the syntax).     *)
(* ================================================================== *)

(* ---- Phase 1: the call-boundary leaves (alloc/free, in unchanged_on) ---- *)

(* alloc_variables never touches an already-existing location: every    *)
(* allocation produces a fresh block, so unchanged_on P holds for ANY P. *)
Lemma alloc_variables_unchanged_on :
  forall (P : block -> Z -> Prop) ge vars e0 m e1 m1,
    alloc_variables ge e0 m vars e1 m1 ->
    Mem.unchanged_on P m m1.
Proof.
  intros P ge vars e0 m e1 m1 H.
  induction H.
  - apply Mem.unchanged_on_refl.
  - eapply Mem.unchanged_on_trans; [ | exact IHalloc_variables ].
    eapply Mem.alloc_unchanged_on; eauto.
Qed.

(* function_entry2 (clightgen's default: params as temps) changes memory *)
(* ONLY by alloc_variables of fn_vars; bind_parameter_temps is pure temp  *)
(* manipulation. So it preserves any P. *)
Lemma function_entry2_unchanged_on :
  forall (P : block -> Z -> Prop) ge f vargs m e le m1,
    function_entry2 ge f vargs m e le m1 ->
    Mem.unchanged_on P m m1.
Proof.
  intros P ge f vargs m e le m1 H. inv H.
  eapply alloc_variables_unchanged_on; eauto.
Qed.

(* Every block allocated by alloc_variables FROM AN EMPTY environment is  *)
(* fresh w.r.t. the starting memory. (Stated for general e0 with the      *)
(* invariant that e0's bindings are already valid; the call site uses     *)
(* empty_env, where the invariant is vacuous.)                            *)
Lemma alloc_variables_fresh :
  forall ge vars e0 m e1 m1,
    alloc_variables ge e0 m vars e1 m1 ->
    forall id b ty,
      e1 ! id = Some (b, ty) ->
      Mem.valid_block m b ->
      e0 ! id = Some (b, ty).
Proof.
  intros ge vars e0 m e1 m1 H. induction H; intros id0 b0 ty0 Hget Hvalid.
  - exact Hget.
  - (* alloc m 0 (sizeof ge ty) = (m1, b1); recurse on (set id (b1,ty) e). *)
    assert (Hvalid1 : Mem.valid_block m1 b0) by (eapply Mem.valid_block_alloc; eauto).
    specialize (IHalloc_variables id0 b0 ty0 Hget Hvalid1).
    (* b1 = nextblock m is fresh, so b <> b1 (b is valid in m). *)
    assert (Hb1 : ~ Mem.valid_block m b1) by (eapply Mem.fresh_block_alloc; eauto).
    destruct (peq id0 id).
    + subst id0. rewrite PTree.gss in IHalloc_variables. inv IHalloc_variables.
      exfalso. apply Hb1; exact Hvalid.
    + rewrite PTree.gso in IHalloc_variables by auto. exact IHalloc_variables.
Qed.

(* Hence every block freed at function exit (the callee's frame) is fresh  *)
(* w.r.t. the entry memory -- the invariant that makes callee-local writes  *)
(* auto-avoid any caller-visible watched block. *)
Lemma function_entry2_fresh :
  forall ge f vargs m e le m1,
    function_entry2 ge f vargs m e le m1 ->
    forall b lo hi, In (b, lo, hi) (blocks_of_env ge e) -> ~ Mem.valid_block m b.
Proof.
  intros ge f vargs m e le m1 H b lo hi Hin Hvalid. inv H.
  unfold blocks_of_env in Hin. apply list_in_map_inv in Hin.
  destruct Hin as [[id [bb ty]] [Heq Hin]].
  unfold block_of_binding in Heq.
  apply PTree.elements_complete in Hin.
  assert (Hbe : bb = b) by congruence.
  assert (Hempty : empty_env ! id = Some (bb, ty)).
  { eapply alloc_variables_fresh; [ eauto | exact Hin | rewrite Hbe; exact Hvalid ]. }
  rewrite PTree.gempty in Hempty. discriminate.
Qed.

(* free_list, in unchanged_on form: if P touches no freed block at all,    *)
(* freeing preserves P. (Lift of ToyReach.free_list_load_unchanged.) *)
Lemma free_list_unchanged_on :
  forall (P : block -> Z -> Prop) l m m',
    Mem.free_list m l = Some m' ->
    (forall b lo hi i, In (b, lo, hi) l -> ~ P b i) ->
    Mem.unchanged_on P m m'.
Proof.
  intros P l. induction l as [| [[b1 lo] hi] l IH]; intros m m' Hfree Hav.
  - simpl in Hfree. inv Hfree. apply Mem.unchanged_on_refl.
  - simpl in Hfree.
    destruct (Mem.free m b1 lo hi) as [m1|] eqn:Hf; try discriminate.
    eapply Mem.unchanged_on_trans.
    + eapply Mem.free_unchanged_on; [ exact Hf | ].
      intros i Hi. eapply Hav. left; reflexivity.
    + eapply IH; [ exact Hfree | ].
      intros b lo2 hi2 i Hin. eapply Hav. right; exact Hin.
Qed.

(* ---- Phase 2: the mutual induction over exec_stmt / eval_funcall ---- *)

(* The deferred Phase-3 content, stated as two explicit global hypotheses *)
(* about the program (whole-program facts; honest boundary):              *)
(*   reach_body_avoids: EVERY internal function, however entered, has a    *)
(*     body whose Sassigns avoid P. (Phase 3 will DERIVE this from the     *)
(*     syntactic non-writers + local-freshness/escape; here it is given.)  *)
(*   reach_ext_preserves: every external/builtin call preserves P. (The    *)
(*     reached externals are math/runtime, not Mario-state writers.)       *)
Definition reach_body_avoids (P : block -> Z -> Prop) (ge : genv) : Prop :=
  forall f vargs m e le m1,
    function_entry2 ge f vargs m e le m1 ->
    stmt_assigns_avoid P ge e (fn_body f).

Definition reach_ext_preserves (P : block -> Z -> Prop) (ge : genv) : Prop :=
  forall ef vargs m t vres m',
    external_call ef ge vargs m t vres m' ->
    Mem.unchanged_on P m m'.

(* THE rung-(c) meta-theorem (Phase 1+2). With the two global hypotheses,  *)
(* any execution -- statement OR whole funcall, calls and loops included -- *)
(* of clightgen code (function_entry2) preserves a watched byte-set P that  *)
(* lives in blocks valid at the start. The Scall case is discharged by the  *)
(* eval_funcall IH; the funcall case composes the Phase-1 leaves with the   *)
(* body IH. P-validity is threaded forward across each sub-execution via    *)
(* Mem.valid_block_unchanged_on (memory only ever grows).                   *)
Theorem exec_funcall_reach_unchanged_on :
  forall (P : block -> Z -> Prop) (ge : genv),
    reach_body_avoids P ge ->
    reach_ext_preserves P ge ->
    (forall e le m s t le' m' out,
       exec_stmt function_entry2 ge e le m s t le' m' out ->
       (forall b o, P b o -> Mem.valid_block m b) ->
       stmt_assigns_avoid P ge e s ->
       Mem.unchanged_on P m m')
    /\
    (forall m fd vargs t m' vres,
       eval_funcall function_entry2 ge m fd vargs t m' vres ->
       (forall b o, P b o -> Mem.valid_block m b) ->
       Mem.unchanged_on P m m').
Proof.
  intros P ge Hbody Hext.
  apply (exec_stmt_funcall_ind function_entry2 ge
    (fun e le m s t le' m' out =>
       (forall b o, P b o -> Mem.valid_block m b) ->
       stmt_assigns_avoid P ge e s ->
       Mem.unchanged_on P m m')
    (fun m fd vargs t m' vres =>
       (forall b o, P b o -> Mem.valid_block m b) ->
       Mem.unchanged_on P m m')).
  - (* Sskip *) intros e le m HPval Hav. apply Mem.unchanged_on_refl.
  - (* Sassign *)
    intros e le m a1 a2 loc ofs bf v2 v m' Hlv He Hcast Hassign HPval Hav.
    simpl in Hav. eapply assign_loc_unchanged_on; [ exact Hassign | ].
    intros i Hi. eapply Hav; eauto.
  - (* Sset *) intros e le m id a v He HPval Hav. apply Mem.unchanged_on_refl.
  - (* Scall: discharged by the eval_funcall IH *)
    intros e le m optid a al tyargs tyres cconv vf vargs f t m' vres
           Hcf He Hel Hff Htof Hfd IHfun HPval Hav.
    exact (IHfun HPval).
  - (* Sbuiltin: external call preserves P by hypothesis *)
    intros e le m optid ef al tyargs vargs t m' vres Hel Hec HPval Hav.
    eapply Hext; exact Hec.
  - (* Sseq_1: s1 normal then s2 *)
    intros e le m s1 s2 t1 le1 m1 t2 le2 m2 out He1 IH1 He2 IH2 HPval Hav.
    simpl in Hav. destruct Hav as [Hav1 Hav2].
    assert (U1 : Mem.unchanged_on P m m1) by (apply IH1; [ exact HPval | exact Hav1 ]).
    eapply Mem.unchanged_on_trans; [ exact U1 | ].
    apply IH2; [ | exact Hav2 ].
    intros b o HP. eapply Mem.valid_block_unchanged_on; [ exact U1 | eapply HPval; exact HP ].
  - (* Sseq_2: s1 abnormal *)
    intros e le m s1 s2 t1 le1 m1 out He1 IH1 Hout HPval Hav.
    simpl in Hav. apply IH1; [ exact HPval | exact (proj1 Hav) ].
  - (* Sifthenelse *)
    intros e le m a s1 s2 v1 b t le' m' out He Hbool Hexec IH HPval Hav.
    simpl in Hav. apply IH; [ exact HPval | ].
    destruct b; [ exact (proj1 Hav) | exact (proj2 Hav) ].
  - (* Sreturn_none *) intros e le m HPval Hav. apply Mem.unchanged_on_refl.
  - (* Sreturn_some *) intros e le m a v He HPval Hav. apply Mem.unchanged_on_refl.
  - (* Sbreak *) intros e le m HPval Hav. apply Mem.unchanged_on_refl.
  - (* Scontinue *) intros e le m HPval Hav. apply Mem.unchanged_on_refl.
  - (* Sloop_stop1: only s1 ran *)
    intros e le m s1 s2 t le' m' out' out He1 IH1 Hbor HPval Hav.
    simpl in Hav. apply IH1; [ exact HPval | exact (proj1 Hav) ].
  - (* Sloop_stop2: s1 then s2 *)
    intros e le m s1 s2 t1 le1 m1 out1 t2 le2 m2 out2 out
           He1 IH1 Hnoc He2 IH2 Hbor HPval Hav.
    simpl in Hav. destruct Hav as [Hav1 Hav2].
    assert (U1 : Mem.unchanged_on P m m1) by (apply IH1; [ exact HPval | exact Hav1 ]).
    eapply Mem.unchanged_on_trans; [ exact U1 | ].
    apply IH2; [ | exact Hav2 ].
    intros b o HP. eapply Mem.valid_block_unchanged_on; [ exact U1 | eapply HPval; exact HP ].
  - (* Sloop_loop: s1, s2, then the loop again *)
    intros e le m s1 s2 t1 le1 m1 out1 t2 le2 m2 t3 le3 m3 out
           He1 IH1 Hnoc He2 IH2 He3 IH3 HPval Hav.
    simpl in Hav. destruct Hav as [Hav1 Hav2].
    assert (U1 : Mem.unchanged_on P m m1) by (apply IH1; [ exact HPval | exact Hav1 ]).
    assert (HPval1 : forall b o, P b o -> Mem.valid_block m1 b)
      by (intros b o HP; eapply Mem.valid_block_unchanged_on; [ exact U1 | eapply HPval; exact HP ]).
    assert (U2 : Mem.unchanged_on P m1 m2) by (apply IH2; [ exact HPval1 | exact Hav2 ]).
    assert (HPval2 : forall b o, P b o -> Mem.valid_block m2 b)
      by (intros b o HP; eapply Mem.valid_block_unchanged_on; [ exact U2 | eapply HPval1; exact HP ]).
    eapply Mem.unchanged_on_trans; [ exact U1 | ].
    eapply Mem.unchanged_on_trans; [ exact U2 | ].
    apply IH3; [ exact HPval2 | ]. simpl. split; [ exact Hav1 | exact Hav2 ].
  - (* Sswitch: reduce to the selected sequence via the structural lemmas *)
    intros e le m a t v n sl le1 m1 out He Hsw Hexec IH HPval Hav.
    simpl in Hav. apply IH; [ exact HPval | ].
    apply seq_of_ls_assigns_avoid. apply select_switch_assigns_avoid. exact Hav.
  - (* eval_funcall_internal: compose entry (alloc) + body IH + free *)
    intros m f vargs t e le1 le2 m1 m2 out vres m3
           Hentry Hbexec IHbody Hout Hfree HPval.
    assert (Uentry : Mem.unchanged_on P m m1)
      by (eapply function_entry2_unchanged_on; eauto).
    assert (HPval1 : forall b o, P b o -> Mem.valid_block m1 b)
      by (intros b o HP; eapply Mem.valid_block_unchanged_on; [ exact Uentry | eapply HPval; exact HP ]).
    assert (Ubody : Mem.unchanged_on P m1 m2)
      by (apply IHbody; [ exact HPval1 | eapply Hbody; exact Hentry ]).
    assert (Ufree : Mem.unchanged_on P m2 m3).
    { eapply free_list_unchanged_on; [ exact Hfree | ].
      intros b lo hi i Hin HP.
      eapply (function_entry2_fresh _ _ _ _ _ _ _ Hentry b lo hi Hin).
      eapply HPval; exact HP. }
    eapply Mem.unchanged_on_trans; [ eapply Mem.unchanged_on_trans; [ exact Uentry | exact Ubody ] | exact Ufree ].
  - (* eval_funcall_external *)
    intros m ef targs tres cconv vargs t vres m' Hec HPval.
    eapply Hext; exact Hec.
Qed.

(* The interprocedural payoff: the watched-load corollary, now across      *)
(* calls and loops. Compare exec_stmt_preserves_watched_load (rung b): the  *)
(* `call_free` precondition is GONE -- replaced by the two global reach_*    *)
(* hypotheses, which are the whole-program closure of `no reached function   *)
(* writes the watched bytes`. *)
Corollary exec_stmt_reach_preserves_watched_load :
  forall ge e le m s t le' m' out bm aofs,
    let P := fun b o => b = bm /\ aofs <= o < aofs + size_chunk Mint32 in
    reach_body_avoids P ge ->
    reach_ext_preserves P ge ->
    exec_stmt function_entry2 ge e le m s t le' m' out ->
    stmt_assigns_avoid P ge e s ->
    Mem.valid_block m bm ->
    Mem.load Mint32 m' bm aofs = Mem.load Mint32 m bm aofs.
Proof.
  intros ge e le m s t le' m' out bm aofs P Hbody Hext Hexec Hav Hvalid.
  eapply Mem.load_unchanged_on_1.
  - eapply (proj1 (exec_funcall_reach_unchanged_on P ge Hbody Hext)); [ exact Hexec | | exact Hav ].
    intros b o [Hb _]. subst b. exact Hvalid.
  - exact Hvalid.
  - intros i Hi. split; [ reflexivity | exact Hi ].
Qed.
