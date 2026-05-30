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
 *   - It does NOT yet lift to (a) Clight `assign_loc` with `Ptrofs` offsets
 *     (needs a no-overflow side condition on base+ofs), nor (b) `exec_stmt`
 *     over a whole statement (the induction that consumes writes_mario_action_s),
 *     nor (c) the interprocedural case (a callee may write the field). Each is a
 *     separate rung; (c) is exactly where Reach.v's callgraph plugs in.
 *   - Abstract over any composite_env / members list: instantiating it on the
 *     real MarioState composite (a concrete corollary, à la Havoc's flying-carpet
 *     instance) is a follow-up.
 *)

From compcert Require Import Coqlib Errors Maps AST Integers Values Memory Globalenvs Ctypes Cop Clight.

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
