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
 *   - It does NOT yet lift to (b) `exec_stmt` over a whole statement (the
 *     induction that consumes writes_mario_action_s), nor (c) the
 *     interprocedural case (a callee may write the field). Each is a separate
 *     rung; (c) is exactly where Reach.v's callgraph plugs in.
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

From compcert Require Import Coqlib Errors Maps AST Integers Values Memory Globalenvs Ctypes Cop Clight.
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
