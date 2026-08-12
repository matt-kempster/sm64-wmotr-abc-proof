(** Noncomputational aggregation of the official JP Area-1 symbols.

    The imported source-unit modules contain the only definition-map
    computations.  Here the opaque symbol-existence theorems instantiate an
    [Area1EntryAddresses] record, and generic global-address facts establish
    limited structural separation.  This does not assert live memory content,
    allocation sizes, initialization values, reachability, or execution. *)

From Coq Require Import Lia.
From compcert Require Import Clight Globalenvs.
From LessThanOneAPress.Proofs Require Import
  CleanedClightPrograms
  JPArea1SymbolBehaviorDataReceipt JPArea1SymbolGameInitReceipt
  JPArea1SymbolDelayedWarpReceipt JPArea1SymbolFreeObjectListReceipt
  JPArea1SymbolMarioObjectReceipt JPArea1SymbolMarioStateReceipt
  JPArea1SymbolMarioStatesReceipt JPArea1SymbolObjectListArrayReceipt
  JPArea1SymbolObjectListsReceipt JPArea1SymbolObjectPoolReceipt
  JPArea1SymbolPlatformReceipt JPArea1SymbolWarpDestReceipt
  OrdinaryArea1EntryMemory.

Lemma jp_area1_symbol_existence_supplies_bindings :
  forall (ge : Clight.genv),
    (exists block, Genv.find_symbol ge JLU._gMarioStates = Some block) ->
    (exists block, Genv.find_symbol ge JLU._gMarioState = Some block) ->
    (exists block, Genv.find_symbol ge JM._gControllers = Some block) ->
    (exists block, Genv.find_symbol ge JOL._gObjectPool = Some block) ->
    (exists block, Genv.find_symbol ge JOL._gObjectListArray = Some block) ->
    (exists block, Genv.find_symbol ge JOL._gFreeObjectList = Some block) ->
    (exists block, Genv.find_symbol ge JOL._gObjectLists = Some block) ->
    (exists block, Genv.find_symbol ge JOL._gMarioObject = Some block) ->
    (exists block, Genv.find_symbol ge JPD._gMarioPlatform = Some block) ->
    (exists block, Genv.find_symbol ge JLU._sWarpDest = Some block) ->
    (exists block, Genv.find_symbol ge JLU._sDelayedWarpOp = Some block) ->
    (exists block, Genv.find_symbol ge JSS._bhvSpinAirborneWarp = Some block) ->
    exists addresses,
      area1_mario_slot addresses = 0%nat /\
      area1_entry_warp_slot addresses = 1%nat /\
      JPArea1EntrySymbolBindings ge addresses.
Proof.
  intros ge Hstate_storage Hstate_pointer Hcontroller_storage Hobject_pool
    Hobject_lists_storage Hfree_list Hobject_lists_pointer
    Hmario_object_pointer Hplatform_pointer Hwarp_dest Hdelayed_warp
    Hspin_behavior.
  destruct Hstate_storage as [state_storage Hstate_storage].
  destruct Hstate_pointer as [state_pointer Hstate_pointer].
  destruct Hcontroller_storage as [controller_storage Hcontroller_storage].
  destruct Hobject_pool as [object_pool Hobject_pool].
  destruct Hobject_lists_storage as
    [object_lists_storage Hobject_lists_storage].
  destruct Hfree_list as [free_list Hfree_list].
  destruct Hobject_lists_pointer as
    [object_lists_pointer Hobject_lists_pointer].
  destruct Hmario_object_pointer as
    [mario_object_pointer Hmario_object_pointer].
  destruct Hplatform_pointer as [platform_pointer Hplatform_pointer].
  destruct Hwarp_dest as [warp_dest Hwarp_dest].
  destruct Hdelayed_warp as [delayed_warp Hdelayed_warp].
  destruct Hspin_behavior as [spin_behavior Hspin_behavior].
  exists {| area1_state_storage_block := state_storage;
            area1_state_pointer_cell_block := state_pointer;
            area1_controller_storage_block := controller_storage;
            area1_object_pool_block := object_pool;
            area1_object_lists_storage_block := object_lists_storage;
            area1_free_list_block := free_list;
            area1_object_lists_pointer_cell_block := object_lists_pointer;
            area1_mario_object_pointer_cell_block := mario_object_pointer;
            area1_platform_pointer_cell_block := platform_pointer;
            area1_warp_dest_block := warp_dest;
            area1_delayed_warp_block := delayed_warp;
            area1_spin_behavior_block := spin_behavior;
            area1_mario_slot := 0%nat;
            area1_entry_warp_slot := 1%nat |}.
  repeat split; cbn; assumption.
Qed.

Theorem jp_official_area1_entry_symbol_bindings_exist :
  exists addresses,
    area1_mario_slot addresses = 0%nat /\
    area1_entry_warp_slot addresses = 1%nat /\
    JPArea1EntrySymbolBindings
      (Clight.globalenv jp_official_cleaned_slice) addresses.
Proof.
  eapply jp_area1_symbol_existence_supplies_bindings.
  - exact jp_official_area1_state_storage_symbol_exists.
  - exact jp_official_area1_state_pointer_symbol_exists.
  - exact jp_official_area1_controller_storage_symbol_exists.
  - exact jp_official_area1_object_pool_symbol_exists.
  - exact jp_official_area1_object_lists_storage_symbol_exists.
  - exact jp_official_area1_free_list_symbol_exists.
  - exact jp_official_area1_object_lists_pointer_symbol_exists.
  - exact jp_official_area1_mario_object_pointer_symbol_exists.
  - exact jp_official_area1_platform_pointer_symbol_exists.
  - exact jp_official_area1_warp_dest_symbol_exists.
  - exact jp_official_area1_delayed_warp_symbol_exists.
  - exact jp_official_area1_spin_behavior_symbol_exists.
Qed.

Theorem jp_official_area1_entry_symbol_structure_closed :
  exists addresses,
    area1_mario_slot addresses = 0%nat /\
    area1_entry_warp_slot addresses = 1%nat /\
    area1_entry_slots_valid addresses /\
    JPArea1EntrySymbolBindings
      (Clight.globalenv jp_official_cleaned_slice) addresses /\
    (area1_state_storage_block addresses <>
       area1_controller_storage_block addresses /\
     area1_state_storage_block addresses <>
       area1_object_pool_block addresses /\
     area1_controller_storage_block addresses <>
       area1_object_pool_block addresses) /\
    area1_pointer_cells_separate_from_core_storage addresses.
Proof.
  destruct jp_official_area1_entry_symbol_bindings_exist as
    [addresses [Hmario_slot [Hwarp_slot Hbindings]]].
  exists addresses. split; [exact Hmario_slot |].
  split; [exact Hwarp_slot |].
  split.
  - unfold area1_entry_slots_valid, object_pool_capacity.
    rewrite Hmario_slot, Hwarp_slot. lia.
  - split; [exact Hbindings |]. split.
    + exact (jp_area1_entry_storage_blocks_pairwise_distinct
        _ _ Hbindings).
    + exact (jp_area1_pointer_cells_are_separate_from_core_storage
        _ _ Hbindings).
Qed.
