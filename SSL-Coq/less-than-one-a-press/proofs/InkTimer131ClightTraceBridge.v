(** Live CompCert trace bridge for the timer-131 non-NULL Graphics retry.

    The source audits identify the only ordinary writers of Mario's graphical
    tail, but a source census is not an execution theorem.  This module makes
    the missing connection precise at the CompCert-memory boundary:

    - the two dangerous raw-data cells have exact entry loads;
    - both Mario globals still name one fixed pool slot;
    - that slot is active, carries the expected behavior pointer, and is
      reachable from the list-0 sentinel through live [next] pointers;
    - caller-selected command/behavior/dispatch loads retain their entry
      values; and
    - every actual Clight step in the run is classified as a safe store or as
      a byte-level frame for those locations.

    Under those premises, an arbitrary real [Smallstep.star] cannot install
    the flag/offset pair required by the timer-131 Graphics retry.  Recognized
    CompCert builtins and runtime functions satisfy the frame automatically.
    A genuine [EF_external] must instead satisfy the exact protected-byte
    frame below; its C prototype alone is deliberately not treated as proof.

    This module does not assert that the selected retail run already meets
    the step classifier.  In particular, entry execution of the allocator,
    live list construction, same-slot lifetime, internal alias stores, and
    each unresolved external remain explicit proof obligations rather than
    being hidden in an unconstrained Boolean or prose assumption. *)

From Coq Require Import Bool Lia List ZArith.
From compcert Require Import
  AST Builtins Clight Coqlib Ctypes Events Floats Integers Memory Smallstep
  Values.
From LessThanOneAPress.Proofs Require Import
  ClightLinkExecution DefaultArea1StartChronology EntryMemory
  InkTimer131IndirectAliasClosure InkTimer131LiveIdentityClosure
  OrdinaryArea1EntryMemory
  RetailExternalFrameReachability RetailExternalFrames.

Import ListNotations.
Local Open Scope Z_scope.

(** * Exact entry cells *)

Record InkTimer131EntryTailCells
    (memory : mem) (addresses : Area1EntryAddresses) : Prop := {
  ink_entry_flag_word_zero :
    ink_object_cell_load Mint32 ink_object_flag_cell_offset memory
      (area1_object_pool_block addresses)
      (mario_object_base addresses) = Some (Vint Int.zero);
  ink_entry_graphical_offset_zero :
    ink_object_cell_load Mfloat32 ink_object_graph_y_offset_cell_offset memory
      (area1_object_pool_block addresses)
      (mario_object_base addresses) = Some (Vsingle positive_f32_zero)
}.

Theorem ink_timer131_entry_tail_cells_are_safe :
  forall memory addresses,
    InkTimer131EntryTailCells memory addresses ->
    ink_timer131_cells_safe memory (area1_object_pool_block addresses)
      (area1_mario_slot addresses).
Proof.
  intros memory addresses Hentry.
  exists Int.zero.
  split.
  - exact (ink_entry_flag_word_zero memory addresses Hentry).
  - split.
    + vm_compute. reflexivity.
    + exact (ink_entry_graphical_offset_zero memory addresses Hentry).
Qed.

(** * A concrete memory predicate for list-0 membership *)

Definition ink_timer131_list_zero_head
    (addresses : Area1EntryAddresses) : val :=
  Vptr (area1_object_lists_storage_block addresses) Ptrofs.zero.

(** The path grammar admits only the list-0 sentinel and valid pool slots as
    intermediate nodes.  Fuel rules out an unbounded circular witness. *)
Inductive InkTimer131ListZeroPath
    (memory : mem) (addresses : Area1EntryAddresses) : nat -> val -> Prop :=
| InkListPathMario :
    InkTimer131ListZeroPath memory addresses 0
      (object_slot_pointer addresses (area1_mario_slot addresses))
| InkListPathHead :
    forall fuel next,
      load_at Mptr memory (area1_object_lists_storage_block addresses) 0
        object_next_offset = Some next ->
      InkTimer131ListZeroPath memory addresses fuel next ->
      InkTimer131ListZeroPath memory addresses (S fuel)
        (ink_timer131_list_zero_head addresses)
| InkListPathObject :
    forall slot fuel next,
      (slot < object_pool_capacity)%nat ->
      load_at Mptr memory (area1_object_pool_block addresses)
        (object_slot_offset slot) object_next_offset = Some next ->
      InkTimer131ListZeroPath memory addresses fuel next ->
      InkTimer131ListZeroPath memory addresses (S fuel)
        (object_slot_pointer addresses slot).

Definition InkTimer131MarioInListZero
    (memory : mem) (addresses : Area1EntryAddresses) : Prop :=
  exists fuel,
    (fuel <= S object_pool_capacity)%nat /\
    InkTimer131ListZeroPath memory addresses fuel
      (ink_timer131_list_zero_head addresses).

(** * Fixed live identity *)

Record InkTimer131MarioSlotIdentity
    (memory : mem) (addresses : Area1EntryAddresses)
    (behavior_block : block) : Prop := {
  ink_identity_global_mario_pointer :
    load_at Mptr memory
      (area1_mario_object_pointer_cell_block addresses) 0 0 =
      Some (object_slot_pointer addresses (area1_mario_slot addresses));
  ink_identity_state_mario_pointer :
    load_at Mptr memory (area1_state_storage_block addresses) 0
      mario_state_object_pointer_offset =
      Some (object_slot_pointer addresses (area1_mario_slot addresses));
  ink_identity_global_lists_pointer :
    load_at Mptr memory
      (area1_object_lists_pointer_cell_block addresses) 0 0 =
      Some (Vptr (area1_object_lists_storage_block addresses) Ptrofs.zero);
  ink_identity_mario_active :
    load_at Mint16signed memory (area1_object_pool_block addresses)
      (mario_object_base addresses) object_active_flags_offset =
      Some (Vint active_object_flags);
  ink_identity_mario_behavior :
    load_at Mptr memory (area1_object_pool_block addresses)
      (mario_object_base addresses) object_behavior_offset =
      Some (Vptr behavior_block Ptrofs.zero);
  ink_identity_mario_in_list_zero :
    InkTimer131MarioInListZero memory addresses
}.

(** The ordinary entry postcondition already fixes both Mario pointers, the
    lists pointer, and the active word.  The behavior load and live list path
    are intentionally separate because the existing entry boundary does not
    contain them. *)
Theorem ordinary_entry_plus_behavior_and_list_supplies_ink_identity :
  forall memory addresses x y z sample behavior_block,
    OrdinaryArea1EntryMemoryPostcondition memory addresses x y z sample ->
    load_at Mptr memory (area1_object_pool_block addresses)
      (mario_object_base addresses) object_behavior_offset =
      Some (Vptr behavior_block Ptrofs.zero) ->
    InkTimer131MarioInListZero memory addresses ->
    InkTimer131MarioSlotIdentity memory addresses behavior_block.
Proof.
  intros memory addresses x y z sample behavior_block Hentry Hbehavior Hlist.
  constructor.
  - exact (ordinary_area1_object_global_pointer _ _ _ _ _ _ Hentry).
  - exact (ordinary_area1_state_object_pointer _ _ _ _ _ _ Hentry).
  - exact (ordinary_area1_lists_global_pointer _ _ _ _ _ _ Hentry).
  - exact (ordinary_area1_mario_active _ _ _ _ _ _ Hentry).
  - exact Hbehavior.
  - exact Hlist.
Qed.

(** * Protected bytes and immutable initializer loads *)

Record InkTimer131ProtectedLoad := {
  ink_protected_load_chunk : memory_chunk;
  ink_protected_load_block : block;
  ink_protected_load_offset : Z;
  ink_protected_load_value : val
}.

Definition ink_timer131_protected_load_holds
    (memory : mem) (load : InkTimer131ProtectedLoad) : Prop :=
  Mem.load (ink_protected_load_chunk load) memory
    (ink_protected_load_block load) (ink_protected_load_offset load) =
    Some (ink_protected_load_value load).

Definition InkTimer131ProtectedLoadsHold
    (memory : mem) (loads : list InkTimer131ProtectedLoad) : Prop :=
  Forall (ink_timer131_protected_load_holds memory) loads.

Definition ink_timer131_load_spec_byte
    (loads : list InkTimer131ProtectedLoad) (target_block : block)
    (byte_offset : Z) : Prop :=
  exists load,
    In load loads /\
    ink_protected_load_block load = target_block /\
    ink_protected_load_offset load <= byte_offset <
      ink_protected_load_offset load +
        size_chunk (ink_protected_load_chunk load).

Definition ink_timer131_cell_byte
    (addresses : Area1EntryAddresses) (target_block : block)
    (byte_offset : Z) : Prop :=
  target_block = area1_object_pool_block addresses /\
  ((mario_object_base addresses + ink_object_flag_cell_offset <= byte_offset <
      mario_object_base addresses + ink_object_flag_cell_offset + 4) \/
   (mario_object_base addresses + ink_object_graph_y_offset_cell_offset <=
      byte_offset <
      mario_object_base addresses + ink_object_graph_y_offset_cell_offset + 4)).

Definition ink_timer131_identity_byte
    (addresses : Area1EntryAddresses) (target_block : block)
    (byte_offset : Z) : Prop :=
  (target_block = area1_mario_object_pointer_cell_block addresses /\
    0 <= byte_offset < size_chunk Mptr) \/
  (target_block = area1_state_storage_block addresses /\
    mario_state_object_pointer_offset <= byte_offset <
      mario_state_object_pointer_offset + size_chunk Mptr) \/
  (target_block = area1_object_lists_pointer_cell_block addresses /\
    0 <= byte_offset < size_chunk Mptr) \/
  (target_block = area1_object_pool_block addresses /\
    mario_object_base addresses + object_active_flags_offset <= byte_offset <
      mario_object_base addresses + object_active_flags_offset +
        size_chunk Mint16signed) \/
  (target_block = area1_object_pool_block addresses /\
    mario_object_base addresses + object_behavior_offset <= byte_offset <
      mario_object_base addresses + object_behavior_offset + size_chunk Mptr) \/
  (target_block = area1_object_lists_storage_block addresses /\
    object_next_offset <= byte_offset < object_next_offset + size_chunk Mptr) \/
  (target_block = area1_object_pool_block addresses /\
    exists slot,
      (slot < object_pool_capacity)%nat /\
      object_slot_offset slot + object_next_offset <= byte_offset <
        object_slot_offset slot + object_next_offset + size_chunk Mptr).

(** The five fixed identity loads are distinct from the mutable list links.
    Allocation, deletion, and list insertion legitimately rewrite [next]
    fields, so an execution classifier must prove preservation of Mario's
    list-0 membership rather than freeze every list link byte. *)
Definition ink_timer131_fixed_identity_byte
    (addresses : Area1EntryAddresses) (target_block : block)
    (byte_offset : Z) : Prop :=
  (target_block = area1_mario_object_pointer_cell_block addresses /\
    0 <= byte_offset < size_chunk Mptr) \/
  (target_block = area1_state_storage_block addresses /\
    mario_state_object_pointer_offset <= byte_offset <
      mario_state_object_pointer_offset + size_chunk Mptr) \/
  (target_block = area1_object_lists_pointer_cell_block addresses /\
    0 <= byte_offset < size_chunk Mptr) \/
  (target_block = area1_object_pool_block addresses /\
    mario_object_base addresses + object_active_flags_offset <= byte_offset <
      mario_object_base addresses + object_active_flags_offset +
        size_chunk Mint16signed) \/
  (target_block = area1_object_pool_block addresses /\
    mario_object_base addresses + object_behavior_offset <= byte_offset <
      mario_object_base addresses + object_behavior_offset + size_chunk Mptr).

Definition ink_timer131_identity_and_static_byte
    (addresses : Area1EntryAddresses)
    (loads : list InkTimer131ProtectedLoad) : block -> Z -> Prop :=
  fun target_block byte_offset =>
    ink_timer131_identity_byte addresses target_block byte_offset \/
    ink_timer131_load_spec_byte loads target_block byte_offset.

Definition ink_timer131_fixed_identity_and_static_byte
    (addresses : Area1EntryAddresses)
    (loads : list InkTimer131ProtectedLoad) : block -> Z -> Prop :=
  fun target_block byte_offset =>
    ink_timer131_fixed_identity_byte addresses target_block byte_offset \/
    ink_timer131_load_spec_byte loads target_block byte_offset.

Lemma ink_timer131_fixed_identity_byte_is_identity_byte :
  forall addresses target_block byte_offset,
    ink_timer131_fixed_identity_byte addresses target_block byte_offset ->
    ink_timer131_identity_byte addresses target_block byte_offset.
Proof.
  intros addresses target_block byte_offset Hfixed.
  unfold ink_timer131_fixed_identity_byte in Hfixed.
  unfold ink_timer131_identity_byte.
  destruct Hfixed as [H | [H | [H | [H | H]]]].
  - exact (or_introl H).
  - exact (or_intror (or_introl H)).
  - exact (or_intror (or_intror (or_introl H))).
  - exact (or_intror (or_intror (or_intror (or_introl H)))).
  - exact (or_intror (or_intror (or_intror (or_intror (or_introl H))))).
Qed.

Definition ink_timer131_full_external_byte
    (addresses : Area1EntryAddresses)
    (loads : list InkTimer131ProtectedLoad) : block -> Z -> Prop :=
  fun target_block byte_offset =>
    ink_timer131_cell_byte addresses target_block byte_offset \/
    ink_timer131_identity_and_static_byte addresses loads
      target_block byte_offset.

(** * Byte frames preserve the concrete identity predicates *)

Record InkTimer131ProtectedCellFrame
    (before after : mem) (addresses : Area1EntryAddresses) : Prop := {
  ink_frame_flag_cell :
    forall flags,
      ink_object_cell_load Mint32 ink_object_flag_cell_offset before
        (area1_object_pool_block addresses) (mario_object_base addresses) =
        Some (Vint flags) ->
      ink_object_cell_load Mint32 ink_object_flag_cell_offset after
        (area1_object_pool_block addresses) (mario_object_base addresses) =
        Some (Vint flags);
  ink_frame_graph_offset_cell :
    forall offset,
      ink_object_cell_load Mfloat32 ink_object_graph_y_offset_cell_offset before
        (area1_object_pool_block addresses) (mario_object_base addresses) =
        Some (Vsingle offset) ->
      ink_object_cell_load Mfloat32 ink_object_graph_y_offset_cell_offset after
        (area1_object_pool_block addresses) (mario_object_base addresses) =
        Some (Vsingle offset)
}.

Lemma ink_timer131_cell_unchanged_on_is_frame :
  forall before after addresses,
    Mem.unchanged_on (ink_timer131_cell_byte addresses) before after ->
    InkTimer131ProtectedCellFrame before after addresses.
Proof.
  intros before after addresses Hunchanged.
  constructor; intros value Hload; unfold ink_object_cell_load in *.
  - eapply Mem.load_unchanged_on; eauto.
    intros byte_offset Hrange.
    unfold ink_timer131_cell_byte.
    split; [reflexivity |]. left.
    cbn [size_chunk] in Hrange |- *. lia.
  - eapply Mem.load_unchanged_on; eauto.
    intros byte_offset Hrange.
    unfold ink_timer131_cell_byte.
    split; [reflexivity |]. right.
    cbn [size_chunk] in Hrange |- *. lia.
Qed.

Lemma ink_timer131_protected_cell_frame_preserves_safety :
  forall before after addresses,
    InkTimer131ProtectedCellFrame before after addresses ->
    ink_timer131_cells_safe before (area1_object_pool_block addresses)
      (area1_mario_slot addresses) ->
    ink_timer131_cells_safe after (area1_object_pool_block addresses)
      (area1_mario_slot addresses).
Proof.
  intros before after addresses Hframe
    [flags [Hflags [Hbit Hoffset]]].
  exists flags. split.
  - exact (ink_frame_flag_cell before after addresses Hframe flags Hflags).
  - split; [exact Hbit |].
    exact (ink_frame_graph_offset_cell before after addresses Hframe
      positive_f32_zero Hoffset).
Qed.

Lemma ink_timer131_list_zero_path_preserved :
  forall before after addresses fuel node loads,
    Mem.unchanged_on
      (ink_timer131_identity_and_static_byte addresses loads) before after ->
    InkTimer131ListZeroPath before addresses fuel node ->
    InkTimer131ListZeroPath after addresses fuel node.
Proof.
  intros before after addresses fuel node loads Hunchanged Hpath.
  induction Hpath.
  - constructor.
  - apply InkListPathHead with (next := next).
    + unfold load_at in *.
      eapply Mem.load_unchanged_on; eauto.
      intros byte_offset Hrange.
      left. unfold ink_timer131_identity_byte.
      right; right; right; right; right; left.
      split; [reflexivity |]. cbn [size_chunk] in Hrange. lia.
    + exact IHHpath.
  - apply InkListPathObject with (slot := slot) (next := next).
    + exact H.
    + unfold load_at in *.
      eapply Mem.load_unchanged_on; eauto.
      intros byte_offset Hrange.
      left. unfold ink_timer131_identity_byte.
      right; right; right; right; right; right.
      split; [reflexivity |].
      exists slot. split; [exact H |].
      cbn [size_chunk] in Hrange. lia.
    + exact IHHpath.
Qed.

Lemma ink_timer131_list_zero_membership_preserved :
  forall before after addresses loads,
    Mem.unchanged_on
      (ink_timer131_identity_and_static_byte addresses loads) before after ->
    InkTimer131MarioInListZero before addresses ->
    InkTimer131MarioInListZero after addresses.
Proof.
  intros before after addresses loads Hunchanged [fuel [Hfuel Hpath]].
  exists fuel. split; [exact Hfuel |].
  eapply ink_timer131_list_zero_path_preserved; eauto.
Qed.

Lemma ink_timer131_protected_loads_preserved :
  forall before after addresses loads,
    Mem.unchanged_on
      (ink_timer131_identity_and_static_byte addresses loads) before after ->
    InkTimer131ProtectedLoadsHold before loads ->
    InkTimer131ProtectedLoadsHold after loads.
Proof.
  intros before after addresses loads Hunchanged Hloads.
  unfold InkTimer131ProtectedLoadsHold in Hloads |- *.
  rewrite Forall_forall in Hloads |- *.
  intros load Hin.
  specialize (Hloads load Hin).
  unfold ink_timer131_protected_load_holds in *.
  eapply Mem.load_unchanged_on; eauto.
  intros byte_offset Hrange.
  right. unfold ink_timer131_load_spec_byte.
  exists load. split; [exact Hin |].
  split; [reflexivity | exact Hrange].
Qed.

Lemma ink_timer131_protected_loads_preserved_by_fixed_frame :
  forall before after addresses loads,
    Mem.unchanged_on
      (ink_timer131_fixed_identity_and_static_byte addresses loads)
      before after ->
    InkTimer131ProtectedLoadsHold before loads ->
    InkTimer131ProtectedLoadsHold after loads.
Proof.
  intros before after addresses loads Hunchanged Hloads.
  unfold InkTimer131ProtectedLoadsHold in Hloads |- *.
  rewrite Forall_forall in Hloads |- *.
  intros load Hin.
  specialize (Hloads load Hin).
  unfold ink_timer131_protected_load_holds in *.
  eapply Mem.load_unchanged_on; eauto.
  intros byte_offset Hrange.
  right. unfold ink_timer131_load_spec_byte.
  exists load. split; [exact Hin |].
  split; [reflexivity | exact Hrange].
Qed.

Lemma ink_timer131_identity_preserved :
  forall before after addresses behavior_block loads,
    Mem.unchanged_on
      (ink_timer131_identity_and_static_byte addresses loads) before after ->
    InkTimer131MarioSlotIdentity before addresses behavior_block ->
    InkTimer131MarioSlotIdentity after addresses behavior_block.
Proof.
  intros before after addresses behavior_block loads Hunchanged Hidentity.
  destruct Hidentity as
    [Hmario_global Hstate_object Hlists_global Hactive Hbehavior Hlist].
  constructor.
  - unfold load_at in *.
    eapply Mem.load_unchanged_on; eauto.
    intros byte_offset Hrange. left.
    unfold ink_timer131_identity_byte.
    left. split; [reflexivity |]. cbn [size_chunk] in Hrange. lia.
  - unfold load_at in *.
    eapply Mem.load_unchanged_on; eauto.
    intros byte_offset Hrange. left.
    unfold ink_timer131_identity_byte.
    right; left. split; [reflexivity |].
    cbn [size_chunk] in Hrange. lia.
  - unfold load_at in *.
    eapply Mem.load_unchanged_on; eauto.
    intros byte_offset Hrange. left.
    unfold ink_timer131_identity_byte.
    right; right; left. split; [reflexivity |].
    cbn [size_chunk] in Hrange. lia.
  - unfold load_at in *.
    eapply Mem.load_unchanged_on; eauto.
    intros byte_offset Hrange. left.
    unfold ink_timer131_identity_byte.
    right; right; right; left. split; [reflexivity |].
    cbn [size_chunk] in Hrange |- *. lia.
  - unfold load_at in *.
    eapply Mem.load_unchanged_on; eauto.
    intros byte_offset Hrange. left.
    unfold ink_timer131_identity_byte.
    right; right; right; right; left. split; [reflexivity |].
    cbn [size_chunk] in Hrange |- *. lia.
  - eapply ink_timer131_list_zero_membership_preserved; eauto.
Qed.

Lemma ink_timer131_identity_preserved_by_fixed_frame_and_membership :
  forall before after addresses behavior_block loads,
    Mem.unchanged_on
      (ink_timer131_fixed_identity_and_static_byte addresses loads)
      before after ->
    (InkTimer131MarioInListZero before addresses ->
      InkTimer131MarioInListZero after addresses) ->
    InkTimer131MarioSlotIdentity before addresses behavior_block ->
    InkTimer131MarioSlotIdentity after addresses behavior_block.
Proof.
  intros before after addresses behavior_block loads Hunchanged Hmembership
    Hidentity.
  destruct Hidentity as
    [Hmario_global Hstate_object Hlists_global Hactive Hbehavior Hlist].
  constructor.
  - unfold load_at in *.
    eapply Mem.load_unchanged_on; eauto.
    intros byte_offset Hrange. left.
    unfold ink_timer131_fixed_identity_byte.
    left. split; [reflexivity |]. cbn [size_chunk] in Hrange. lia.
  - unfold load_at in *.
    eapply Mem.load_unchanged_on; eauto.
    intros byte_offset Hrange. left.
    unfold ink_timer131_fixed_identity_byte.
    right; left. split; [reflexivity |].
    cbn [size_chunk] in Hrange. lia.
  - unfold load_at in *.
    eapply Mem.load_unchanged_on; eauto.
    intros byte_offset Hrange. left.
    unfold ink_timer131_fixed_identity_byte.
    right; right; left. split; [reflexivity |].
    cbn [size_chunk] in Hrange. lia.
  - unfold load_at in *.
    eapply Mem.load_unchanged_on; eauto.
    intros byte_offset Hrange. left.
    unfold ink_timer131_fixed_identity_byte.
    right; right; right; left. split; [reflexivity |].
    cbn [size_chunk] in Hrange |- *. lia.
  - unfold load_at in *.
    eapply Mem.load_unchanged_on; eauto.
    intros byte_offset Hrange. left.
    unfold ink_timer131_fixed_identity_byte.
    right; right; right; right. split; [reflexivity |].
    cbn [size_chunk] in Hrange |- *. lia.
  - exact (Hmembership Hlist).
Qed.

(** * One linked memory step and its invariant *)

Inductive InkTimer131CellEffect
    (before after : mem) (addresses : Area1EntryAddresses) : Prop :=
| InkCellEffectCleanStore :
    InkTimer131CleanStoreStep (area1_object_pool_block addresses)
      (area1_mario_slot addresses) before after ->
    InkTimer131CellEffect before after addresses
| InkCellEffectProtectedFrame :
    InkTimer131ProtectedCellFrame before after addresses ->
    InkTimer131CellEffect before after addresses.

Record InkTimer131LinkedMemoryStep
    (loads : list InkTimer131ProtectedLoad)
    (before after : mem) (addresses : Area1EntryAddresses) : Prop := {
  ink_linked_step_cell_effect : InkTimer131CellEffect before after addresses;
  ink_linked_step_fixed_identity_and_static_frame :
    Mem.unchanged_on
      (ink_timer131_fixed_identity_and_static_byte addresses loads)
      before after;
  ink_linked_step_preserves_mario_list_zero :
    InkTimer131MarioInListZero before addresses ->
    InkTimer131MarioInListZero after addresses
}.

Record InkTimer131LiveInvariant
    (memory : mem) (addresses : Area1EntryAddresses)
    (behavior_block : block) (loads : list InkTimer131ProtectedLoad) : Prop := {
  ink_live_invariant_safe_cells :
    ink_timer131_cells_safe memory (area1_object_pool_block addresses)
      (area1_mario_slot addresses);
  ink_live_invariant_fixed_identity :
    InkTimer131MarioSlotIdentity memory addresses behavior_block;
  ink_live_invariant_static_loads :
    InkTimer131ProtectedLoadsHold memory loads
}.

Theorem ink_timer131_linked_memory_step_preserves_invariant :
  forall before after addresses behavior_block loads,
    InkTimer131LinkedMemoryStep loads before after addresses ->
    InkTimer131LiveInvariant before addresses behavior_block loads ->
    InkTimer131LiveInvariant after addresses behavior_block loads.
Proof.
  intros before after addresses behavior_block loads Hstep Hinvariant.
  destruct Hstep as [Hcell Hframe Hmembership].
  destruct Hinvariant as [Hsafe Hidentity Hloads].
  constructor.
  - destruct Hcell as [Hstore | Hcell_frame].
    + eapply ink_clean_store_step_preserves_timer131_cell_safety; eauto.
    + eapply ink_timer131_protected_cell_frame_preserves_safety; eauto.
  - eapply ink_timer131_identity_preserved_by_fixed_frame_and_membership;
      eauto.
  - eapply ink_timer131_protected_loads_preserved_by_fixed_frame; eauto.
Qed.

(** A full byte frame is stronger than the linked-step relation: it frames
    both dangerous cells as well as identity and immutable initializer loads. *)
Lemma ink_timer131_full_unchanged_on_is_linked_memory_step :
  forall before after addresses loads,
    Mem.unchanged_on (ink_timer131_full_external_byte addresses loads)
      before after ->
    InkTimer131LinkedMemoryStep loads before after addresses.
Proof.
  intros before after addresses loads Hunchanged.
  constructor.
  - apply InkCellEffectProtectedFrame.
    apply ink_timer131_cell_unchanged_on_is_frame.
    eapply Mem.unchanged_on_implies; eauto.
    intros block offset Hprotected. left. exact Hprotected.
  - eapply Mem.unchanged_on_implies; eauto.
    intros block offset Hprotected. right.
    unfold ink_timer131_identity_and_static_byte.
    unfold ink_timer131_fixed_identity_and_static_byte in Hprotected.
    destruct Hprotected as [Hfixed | Hload].
    + left. eapply ink_timer131_fixed_identity_byte_is_identity_byte; eauto.
    + right. exact Hload.
  - intros Hmembership.
    eapply ink_timer131_list_zero_membership_preserved; eauto.
    eapply Mem.unchanged_on_implies; eauto.
    intros block offset Hprotected. right. exact Hprotected.
Qed.

(** * Concrete external-call consequences *)

Theorem external_call_with_timer131_frame_is_linked_memory_step :
  forall external ge arguments before trace result after addresses loads,
    ExternalCallFrame (ink_timer131_full_external_byte addresses loads)
      external ->
    external_call external ge arguments before trace result after ->
    InkTimer131LinkedMemoryStep loads before after addresses.
Proof.
  intros external ge arguments before trace result after addresses loads
    Hframe Hcall.
  apply ink_timer131_full_unchanged_on_is_linked_memory_step.
  unfold ExternalCallFrame in Hframe.
  exact (Hframe ge arguments before trace result after Hcall).
Qed.

Corollary recognized_builtin_is_timer131_linked_memory_step :
  forall name signature builtin ge arguments before trace result after
      addresses loads,
    lookup_builtin_function name signature = Some builtin ->
    external_call (EF_builtin name signature) ge arguments before trace
      result after ->
    InkTimer131LinkedMemoryStep loads before after addresses.
Proof.
  intros name signature builtin ge arguments before trace result after
    addresses loads Hlookup Hcall.
  eapply external_call_with_timer131_frame_is_linked_memory_step; eauto.
  eapply recognized_builtin_has_every_writable_frame; eauto.
Qed.

Corollary recognized_runtime_is_timer131_linked_memory_step :
  forall name signature builtin ge arguments before trace result after
      addresses loads,
    lookup_builtin_function name signature = Some builtin ->
    external_call (EF_runtime name signature) ge arguments before trace
      result after ->
    InkTimer131LinkedMemoryStep loads before after addresses.
Proof.
  intros name signature builtin ge arguments before trace result after
    addresses loads Hlookup Hcall.
  eapply external_call_with_timer131_frame_is_linked_memory_step; eauto.
  eapply recognized_runtime_has_every_writable_frame; eauto.
Qed.

(** The declaration-wide theorem is retained only as a compatibility result.
    It is stronger than needed and can be false for a legitimate external
    object writer.  The callsite-sensitive interface below is the proof target
    for reachable unresolved calls. *)
Theorem reachable_unresolved_external_is_timer131_linked_memory_step :
  forall (program : Clight.program) initial reach_trace name signature
      argument_types result_type
      calling_convention arguments continuation before step_trace result after
      addresses loads,
    list_norepet (prog_defs_names program) ->
    TrueUnresolvedExternalFrames program
      (ink_timer131_full_external_byte addresses loads) ->
    Clight.initial_state program initial ->
    @Smallstep.star _ _ Clight.step2 (Clight.globalenv program)
      initial reach_trace
      (Clight.Callstate
        (External (EF_external name signature) argument_types result_type
          calling_convention) arguments continuation before) ->
    Clight.step2 (Clight.globalenv program)
      (Clight.Callstate
        (External (EF_external name signature) argument_types result_type
          calling_convention) arguments continuation before)
      step_trace (Clight.Returnstate result continuation after) ->
    InkTimer131LinkedMemoryStep loads before after addresses.
Proof.
  intros program initial reach_trace name signature argument_types result_type
    calling_convention arguments continuation before step_trace result after
    addresses loads Hnorepet Hframes Hinitial Hreachable Hstep.
  apply ink_timer131_full_unchanged_on_is_linked_memory_step.
  eapply clight_reachable_true_external_step_obeys_inventory_frame; eauto.
Qed.

Definition ink_timer131_external_protected_policy
    (addresses : Area1EntryAddresses)
    (loads : list InkTimer131ProtectedLoad) : ExternalProtectedCellPolicy :=
  fun _ _ _ => ink_timer131_full_external_byte addresses loads.

(** A reachable external which legitimately writes memory must expose that
    exact effect as the same linked-step relation used for internal stores.
    It is not accepted merely because the protected pointer is absent from
    the C prototype. *)
Definition ink_timer131_external_writer_refinement
    (addresses : Area1EntryAddresses)
    (loads : list InkTimer131ProtectedLoad) : ExternalWriterRefinement :=
  fun _ _ before _ _ after =>
    InkTimer131LinkedMemoryStep loads before after addresses.

Record InkTimer131CallsiteExternalCoverage
    (program : Clight.program) (origin : ClightExecutionOrigin)
    (addresses : Area1EntryAddresses)
    (loads : list InkTimer131ProtectedLoad) : Prop := {
  ink_timer131_callsite_external_inventory :
    CallsiteSensitiveUnresolvedExternalInventory program origin
      (ink_timer131_external_protected_policy addresses loads)
      (ink_timer131_external_writer_refinement addresses loads)
}.

Theorem reachable_unresolved_external_under_callsite_coverage_is_linked :
  forall program origin addresses loads initial reach_trace name signature
      argument_types result_type calling_convention arguments continuation
      before step_trace result after,
    InkTimer131CallsiteExternalCoverage program origin addresses loads ->
    origin initial ->
    @Smallstep.star _ _ Clight.step2 (Clight.globalenv program)
      initial reach_trace
      (Clight.Callstate
        (External (EF_external name signature) argument_types result_type
          calling_convention) arguments continuation before) ->
    Clight.step2 (Clight.globalenv program)
      (Clight.Callstate
        (External (EF_external name signature) argument_types result_type
          calling_convention) arguments continuation before)
      step_trace (Clight.Returnstate result continuation after) ->
    InkTimer131LinkedMemoryStep loads before after addresses.
Proof.
  intros program origin addresses loads initial reach_trace name signature
    argument_types result_type calling_convention arguments continuation
    before step_trace result after Hcoverage Horigin Hreachable Hstep.
  destruct Hcoverage as [Hinventory].
  destruct (reachable_unresolved_external_effect_is_framed_or_refined
    _ _ _ _ Hinventory initial reach_trace name signature argument_types
    result_type calling_convention arguments continuation before step_trace
    result after Horigin Hreachable Hstep) as [Hframe | Hwriter].
  - apply ink_timer131_full_unchanged_on_is_linked_memory_step.
    exact Hframe.
  - exact Hwriter.
Qed.

(** * Entry and actual Clight-star bridge *)

Theorem ink_timer131_entry_supplies_live_invariant :
  forall memory addresses x y z sample behavior_block loads,
    OrdinaryArea1EntryMemoryPostcondition memory addresses x y z sample ->
    InkTimer131EntryTailCells memory addresses ->
    load_at Mptr memory (area1_object_pool_block addresses)
      (mario_object_base addresses) object_behavior_offset =
      Some (Vptr behavior_block Ptrofs.zero) ->
    InkTimer131MarioInListZero memory addresses ->
    InkTimer131ProtectedLoadsHold memory loads ->
    InkTimer131LiveInvariant memory addresses behavior_block loads.
Proof.
  intros memory addresses x y z sample behavior_block loads Hentry Hcells
    Hbehavior Hlist Hloads.
  constructor.
  - exact (ink_timer131_entry_tail_cells_are_safe memory addresses Hcells).
  - eapply ordinary_entry_plus_behavior_and_list_supplies_ink_identity; eauto.
  - exact Hloads.
Qed.

Definition ink_timer131_clight_state_memory
    (state : Clight.state) : mem :=
  default_area1_clight_state_memory state.

Definition InkTimer131ClightReachable
    (program : Clight.program) (start state : Clight.state) : Prop :=
  exists trace,
    @Smallstep.star _ _ Clight.step2 (Clight.globalenv program)
      start trace state.

(** Unlike the old six-field prose residual, this classifier is indexed by
    an actual reachable Clight state and its actual next [step2].  Proving it
    requires every reachable defined store to enter the clean-store branch,
    and every external effect to supply the full byte frame above. *)
Definition InkTimer131ReachableStepCoverage
    (program : Clight.program) (start : Clight.state)
    (addresses : Area1EntryAddresses)
    (loads : list InkTimer131ProtectedLoad) : Prop :=
  forall before,
    InkTimer131ClightReachable program start before ->
    forall step_trace after,
      Clight.step2 (Clight.globalenv program) before step_trace after ->
      InkTimer131LinkedMemoryStep loads
        (ink_timer131_clight_state_memory before)
        (ink_timer131_clight_state_memory after) addresses.

Lemma clight_star_tail_under_timer131_step_coverage_preserves_invariant :
  forall program origin current trace final addresses behavior_block loads,
    @Smallstep.star _ _ Clight.step2 (Clight.globalenv program)
      current trace final ->
    InkTimer131ReachableStepCoverage program origin addresses loads ->
    InkTimer131ClightReachable program origin current ->
    InkTimer131LiveInvariant (ink_timer131_clight_state_memory current)
      addresses behavior_block loads ->
    InkTimer131LiveInvariant (ink_timer131_clight_state_memory final)
      addresses behavior_block loads.
Proof.
  intros program origin current trace final addresses behavior_block loads
    Hstar.
  induction Hstar; intros Hcoverage Hreachable Hcurrent.
  - exact Hcurrent.
  - apply IHHstar.
    + exact Hcoverage.
    + destruct Hreachable as [prefix Hprefix].
      unfold InkTimer131ClightReachable.
      eexists.
      eapply Smallstep.star_trans.
      * exact Hprefix.
      * eapply Smallstep.star_step.
        -- exact H.
        -- constructor.
        -- reflexivity.
      * reflexivity.
    + eapply ink_timer131_linked_memory_step_preserves_invariant.
      * eapply Hcoverage; eauto.
      * exact Hcurrent.
Qed.

Theorem clight_star_under_timer131_step_coverage_preserves_invariant :
  forall program start trace final addresses behavior_block loads,
    @Smallstep.star _ _ Clight.step2 (Clight.globalenv program)
      start trace final ->
    InkTimer131ReachableStepCoverage program start addresses loads ->
    InkTimer131LiveInvariant (ink_timer131_clight_state_memory start)
      addresses behavior_block loads ->
    InkTimer131LiveInvariant (ink_timer131_clight_state_memory final)
      addresses behavior_block loads.
Proof.
  intros program start trace final addresses behavior_block loads Hstar
    Hcoverage Hinvariant.
  eapply clight_star_tail_under_timer131_step_coverage_preserves_invariant;
    eauto.
  exists E0. constructor.
Qed.

Theorem linked_clight_trace_cannot_install_timer131_tail_cells :
  forall program start trace final addresses behavior_block loads,
    @Smallstep.star _ _ Clight.step2 (Clight.globalenv program)
      start trace final ->
    InkTimer131ReachableStepCoverage program start addresses loads ->
    InkTimer131LiveInvariant (ink_timer131_clight_state_memory start)
      addresses behavior_block loads ->
    ~ ink_timer131_tail_cells_dangerous
        (ink_timer131_clight_state_memory final)
        (area1_object_pool_block addresses) (area1_mario_slot addresses).
Proof.
  intros program start trace final addresses behavior_block loads Hstar
    Hcoverage Hinvariant.
  apply safe_timer131_cells_are_not_dangerous.
  exact (ink_live_invariant_safe_cells _ _ _ _
    (clight_star_under_timer131_step_coverage_preserves_invariant
      program start trace final addresses behavior_block loads Hstar
      Hcoverage Hinvariant)).
Qed.

Corollary linked_clight_trace_preserves_mario_list_zero_and_slot_identity :
  forall program start trace final addresses behavior_block loads,
    @Smallstep.star _ _ Clight.step2 (Clight.globalenv program)
      start trace final ->
    InkTimer131ReachableStepCoverage program start addresses loads ->
    InkTimer131LiveInvariant (ink_timer131_clight_state_memory start)
      addresses behavior_block loads ->
    InkTimer131MarioSlotIdentity (ink_timer131_clight_state_memory final)
      addresses behavior_block.
Proof.
  intros.
  exact (ink_live_invariant_fixed_identity _ _ _ _
    (clight_star_under_timer131_step_coverage_preserves_invariant
      program start trace final addresses behavior_block loads H H0 H1)).
Qed.

Corollary linked_clight_trace_preserves_command_and_dispatch_loads :
  forall program start trace final addresses behavior_block loads,
    @Smallstep.star _ _ Clight.step2 (Clight.globalenv program)
      start trace final ->
    InkTimer131ReachableStepCoverage program start addresses loads ->
    InkTimer131LiveInvariant (ink_timer131_clight_state_memory start)
      addresses behavior_block loads ->
    InkTimer131ProtectedLoadsHold
      (ink_timer131_clight_state_memory final) loads.
Proof.
  intros.
  exact (ink_live_invariant_static_loads _ _ _ _
    (clight_star_under_timer131_step_coverage_preserves_invariant
      program start trace final addresses behavior_block loads H H0 H1)).
Qed.

Definition InkTimer131ClightTraceBridgeCheckedBoundary : Prop :=
  (forall memory addresses,
    InkTimer131EntryTailCells memory addresses ->
    ink_timer131_cells_safe memory (area1_object_pool_block addresses)
      (area1_mario_slot addresses)) /\
  (forall program start trace final addresses behavior_block loads,
    @Smallstep.star _ _ Clight.step2 (Clight.globalenv program)
      start trace final ->
    InkTimer131ReachableStepCoverage program start addresses loads ->
    InkTimer131LiveInvariant (ink_timer131_clight_state_memory start)
      addresses behavior_block loads ->
    ~ ink_timer131_tail_cells_dangerous
        (ink_timer131_clight_state_memory final)
        (area1_object_pool_block addresses) (area1_mario_slot addresses)).

Theorem ink_timer131_clight_trace_bridge_checked_boundary_holds :
  InkTimer131ClightTraceBridgeCheckedBoundary.
Proof.
  split.
  - exact ink_timer131_entry_tail_cells_are_safe.
  - exact linked_clight_trace_cannot_install_timer131_tail_cells.
Qed.

(** What remains after this bridge is no longer an amorphous corruption
    escape.  It is the construction of the exact entry loads/list path and
    [InkTimer131ReachableStepCoverage] for the selected run.  Invalid/OOB
    executions are outside Clight; valid same-block aliases and true external
    effects must either inhabit the relation above or exhibit the first
    concrete violating step. *)
