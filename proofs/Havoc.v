(* Havoc.v -- the separation / "havoc" rung of the pointer-write story.
 *
 * Escape.v gives the SYNTACTIC fact "the address of g is never produced". This
 * file is about the SEMANTIC payoff: a store that doesn't target g's block
 * leaves g's value untouched -- and, crucially, where the block-distinctness is
 * DERIVED rather than assumed.
 *
 * Two regimes, honestly separated:
 *
 *  (1) Store to a DIFFERENT GLOBAL g' (g' <> g). Distinctness bg <> bg' is a
 *      THEOREM: CompCert's Genv.global_addresses_distinct says distinct symbols
 *      occupy distinct blocks. Combined with Reach.direct_writers (which globals
 *      are written) this is a complete, assumption-free preservation argument
 *      for direct global writes. PROVED here.
 *
 *  (2) Store through an arbitrary POINTER (the real leak #1). Preservation needs
 *      bg not to be the pointer's block. That is exactly the escape invariant
 *      "no reachable pointer names bg", which addr_taken=false is meant to
 *      maintain across execution. We state the havoc step with that invariant as
 *      an explicit hypothesis (so the remaining obligation is named, not hidden);
 *      PROVING the invariant is preserved is the next rung.
 *
 * Generalizes ToyReach's store_to_fresh_preserves_existing: there the
 * discriminator was fresh-vs-valid; here it is distinct-symbol (regime 1) and
 * not-the-target (regime 2).
 *)

From compcert Require Import Coqlib Maps AST Integers Values Memory Globalenvs Ctypes Cop Clight.
From SM64.Generated Require Import shadow.

(* Generic: a Clight assignment to block b preserves loads at any other block,
   across all three assign_loc kinds. (Same lemma as ToyReach's, restated here so
   this file doesn't depend on the toy module.) *)
Lemma assign_loc_load_other :
  forall ce ty m b ofs bf v m',
    assign_loc ce ty m b ofs bf v m' ->
    forall chunk b' off,
      b' <> b ->
      Mem.load chunk m' b' off = Mem.load chunk m b' off.
Proof.
  intros ce ty m b ofs bf v m' H chunk b' off Hne.
  inv H.
  - unfold Mem.storev in *. eapply Mem.load_store_other; eauto.
  - eapply Mem.load_storebytes_other; eauto.
  - match goal with Hsb : store_bitfield _ _ _ _ _ _ _ _ _ _ |- _ => inv Hsb end.
    unfold Mem.storev in *. eapply Mem.load_store_other; eauto.
Qed.

(* ========================================================================== *)
(* Regime 1: a store to a DIFFERENT global preserves g. Block-distinctness     *)
(* derived from Genv.global_addresses_distinct, not assumed.                   *)
(* ========================================================================== *)

Theorem store_to_other_global_preserves :
  forall (F V : Type) (ge : Genv.t F V) g g' b b' chunk m ofs v m' chunk' off,
    g <> g' ->
    Genv.find_symbol ge g  = Some b ->
    Genv.find_symbol ge g' = Some b' ->
    Mem.store chunk m b' ofs v = Some m' ->
    Mem.load chunk' m' b off = Mem.load chunk' m b off.
Proof.
  intros F V ge g g' b b' chunk m ofs v m' chunk' off Hgg Hfg Hfg' Hstore.
  assert (Hbb : b <> b') by (eapply Genv.global_addresses_distinct; eauto).
  eapply Mem.load_store_other; [ exact Hstore | left; exact Hbb ].
Qed.

(* The same at the Clight level: an assign_loc into g''s block preserves g. *)
Theorem assign_to_other_global_preserves :
  forall (F V : Type) (ge : Genv.t F V) ce g g' b b' ty ofs bf v m m' chunk off,
    g <> g' ->
    Genv.find_symbol ge g  = Some b ->
    Genv.find_symbol ge g' = Some b' ->
    assign_loc ce ty m b' ofs bf v m' ->
    Mem.load chunk m' b off = Mem.load chunk m b off.
Proof.
  intros F V ge ce g g' b b' ty ofs bf v m m' chunk off Hgg Hfg Hfg' Hassign.
  assert (Hbb : b <> b') by (eapply Genv.global_addresses_distinct; eauto).
  eapply assign_loc_load_other; eauto.
Qed.

(* A concrete shadow.c instance: directly writing sMarioOnFlyingCarpet provably
   leaves sSurfaceTypeBelowShadow unchanged. The ONLY thing supplied by hand is
   that the two idents differ (`discriminate`); the block-distinctness that makes
   the stores non-interfering is derived. (We keep the symbols' blocks abstract
   via find_symbol hypotheses -- the fact is independent of their concrete
   addresses.) *)
Corollary writing_flying_carpet_preserves_surface_type :
  forall (F V : Type) (ge : Genv.t F V) ce b b' ty ofs bf v m m' chunk off,
    Genv.find_symbol ge _sSurfaceTypeBelowShadow = Some b ->
    Genv.find_symbol ge _sMarioOnFlyingCarpet    = Some b' ->
    assign_loc ce ty m b' ofs bf v m' ->
    Mem.load chunk m' b off = Mem.load chunk m b off.
Proof.
  intros. eapply assign_to_other_global_preserves; eauto. discriminate.
Qed.

(* ========================================================================== *)
(* Regime 2: store through an arbitrary pointer. The escape invariant          *)
(* ("no reachable pointer names g's block bg") is made an EXPLICIT hypothesis   *)
(* b' <> bg. This is the open-world shape; closing leak #1 means PROVING this   *)
(* hypothesis holds at every store, by induction over execution, from           *)
(* addr_taken=false (Escape.v). That preservation proof is the next rung.       *)
(* ========================================================================== *)

Theorem havoc_preserves_separable :
  forall bg b' chunk m ofs v m' chunk' off,
    b' <> bg ->                 (* <- discharged by the escape invariant (future) *)
    Mem.store chunk m b' ofs v = Some m' ->
    Mem.load chunk' m' bg off = Mem.load chunk' m bg off.
Proof.
  intros bg b' chunk m ofs v m' chunk' off Hne Hstore.
  eapply Mem.load_store_other; [ exact Hstore | left; congruence ].
Qed.
