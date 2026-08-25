(** Defined CompCert casts cannot fabricate a dereferenceable platform-cell
    alias from an integer value.

    CompCert's values retain their constructor across C integer/pointer casts:
    on this 32-bit target a cast integer is still [Vint], never [Vptr].  In
    turn, [Mem.storev] accepts only a [Vptr] address.  Thus an integer-derived
    address cannot perform a successful Clight store.  This removes
    [PlatformAliasIntegerFabricated] from successful in-bounds executions; it
    deliberately says nothing about retail MIPS after undefined behavior. *)

From compcert Require Import AST Archi Cop Ctypes Integers Memory Values.

Theorem sem_cast_vint_never_yields_vptr :
  forall i source_type target_type memory block offset,
    Cop.sem_cast (Vint i) source_type target_type memory <>
      Some (Vptr block offset).
Proof.
  intros i source_type target_type memory block offset Hcast.
  unfold Cop.sem_cast in Hcast.
  destruct (Cop.classify_cast source_type target_type);
    cbn in Hcast; try discriminate.
Qed.

Theorem sem_cast_vlong_never_yields_vptr :
  forall i source_type target_type memory block offset,
    Cop.sem_cast (Vlong i) source_type target_type memory <>
      Some (Vptr block offset).
Proof.
  intros i source_type target_type memory block offset Hcast.
  unfold Cop.sem_cast in Hcast.
  destruct (Cop.classify_cast source_type target_type);
    cbn in Hcast; try discriminate.
Qed.

Theorem successful_storev_address_is_vptr :
  forall chunk before address value after,
    Mem.storev chunk before address value = Some after ->
    exists block offset, address = Vptr block offset.
Proof.
  intros chunk before address value after Hstore.
  destruct address; cbn in Hstore; try discriminate.
  eauto.
Qed.

Theorem cast_vint_cannot_address_successful_store :
  forall i source_type target_type before address
      chunk value after,
    Cop.sem_cast (Vint i) source_type target_type before = Some address ->
    Mem.storev chunk before address value = Some after ->
    False.
Proof.
  intros i source_type target_type before address chunk value after
    Hcast Hstore.
  destruct (successful_storev_address_is_vptr
    chunk before address value after Hstore) as (block & offset & ->).
  exact (sem_cast_vint_never_yields_vptr
    i source_type target_type before block offset Hcast).
Qed.

Theorem cast_vlong_cannot_address_successful_store :
  forall i source_type target_type before address
      chunk value after,
    Cop.sem_cast (Vlong i) source_type target_type before = Some address ->
    Mem.storev chunk before address value = Some after ->
    False.
Proof.
  intros i source_type target_type before address chunk value after
    Hcast Hstore.
  destruct (successful_storev_address_is_vptr
    chunk before address value after Hstore) as (block & offset & ->).
  exact (sem_cast_vlong_never_yields_vptr
    i source_type target_type before block offset Hcast).
Qed.

Definition PlatformIntegerAliasDefinedClosure : Prop :=
  (forall i source_type target_type before address chunk value after,
    Cop.sem_cast (Vint i) source_type target_type before = Some address ->
    Mem.storev chunk before address value = Some after ->
    False) /\
  (forall i source_type target_type before address chunk value after,
    Cop.sem_cast (Vlong i) source_type target_type before = Some address ->
    Mem.storev chunk before address value = Some after ->
    False).

Theorem platform_integer_alias_defined_closure_holds :
  PlatformIntegerAliasDefinedClosure.
Proof.
  split.
  - exact cast_vint_cannot_address_successful_store.
  - exact cast_vlong_cannot_address_successful_store.
Qed.
