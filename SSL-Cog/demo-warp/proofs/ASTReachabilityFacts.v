From Coq Require Import Bool List PArith.BinPos ZArith.
From compcert Require Import AST Cop Ctypes Clight Integers.
From DemoWarp.Generated Require Import game_init level_update main memory
  title_screen.

Import ListNotations.
Local Open Scope Z_scope.

Module G := game_init.
Module L := level_update.
Module N := main.
Module R := memory.
Module T := title_screen.

Inductive reachability_event : Type :=
| Reach_pool_start
| Reach_pool_end
| Reach_pool_init_call
| Reach_allocator_align
| Reach_allocator_left_result
| Reach_demo_alloc_call : ident -> reachability_event
| Reach_demo_alloc_global_store : ident -> reachability_event
| Reach_demo_alloc_global_load : ident -> reachability_event
| Reach_setup_demo_list_call : ident -> reachability_event
| Reach_buf_target_store
| Reach_buf_target_read : ident -> reachability_event
| Reach_title_buf_target_read : ident -> reachability_event
| Reach_title_current_from_buffer : ident -> reachability_event.

Definition reachability_event_eqb
    (left right : reachability_event) : bool :=
  match left, right with
  | Reach_pool_start, Reach_pool_start
  | Reach_pool_end, Reach_pool_end
  | Reach_pool_init_call, Reach_pool_init_call
  | Reach_allocator_align, Reach_allocator_align
  | Reach_allocator_left_result, Reach_allocator_left_result
  | Reach_buf_target_store, Reach_buf_target_store => true
  | Reach_demo_alloc_call l, Reach_demo_alloc_call r
  | Reach_demo_alloc_global_store l, Reach_demo_alloc_global_store r
  | Reach_demo_alloc_global_load l, Reach_demo_alloc_global_load r
  | Reach_setup_demo_list_call l, Reach_setup_demo_list_call r
  | Reach_buf_target_read l, Reach_buf_target_read r
  | Reach_title_buf_target_read l, Reach_title_buf_target_read r
  | Reach_title_current_from_buffer l, Reach_title_current_from_buffer r =>
      Pos.eqb l r
  | _, _ => false
  end.

Definition reachability_event_of_statement
    (statement_to_check : statement) : list reachability_event :=
  match statement_to_check with
  | Sset found
      (Ecast (Econst_int value _ ) _) =>
      if Pos.eqb found N._start &&
         Int.eq value (Int.repr (-2147106816))
      then [Reach_pool_start]
      else []
  | Sset found
      (Ecast
        (Ebinop Oadd (Econst_int base _) (Econst_int size _) _) _) =>
      if Pos.eqb found N._end &&
         Int.eq base (Int.repr (-2147106816)) &&
         Int.eq size (Int.repr 1462272)
      then [Reach_pool_end]
      else []
  | Scall None (Evar callee _)
      (Etempvar first _ :: Etempvar second _ :: nil) =>
      if Pos.eqb callee N._main_pool_init &&
         Pos.eqb first N._start && Pos.eqb second N._end
      then [Reach_pool_init_call]
      else []
  | Sset found
      (Ebinop Oadd
        (Ebinop Oand
          (Ebinop Oadd (Etempvar source _) (Econst_int fifteen _) _) _ _)
        (Econst_int sixteen _) _) =>
      if Pos.eqb found R._size && Pos.eqb source R._size &&
         Int.eq fifteen (Int.repr 15) && Int.eq sixteen (Int.repr 16)
      then [Reach_allocator_align]
      else []
  | Sset found
      (Ebinop Oadd (Ecast (Etempvar _ _) _) (Econst_int sixteen _) _) =>
      if Pos.eqb found R._addr && Int.eq sixteen (Int.repr 16)
      then [Reach_allocator_left_result]
      else []
  | Scall (Some result) (Evar callee _)
      (Econst_int size _ :: Econst_int side _ :: nil) =>
      if Pos.eqb callee G._main_pool_alloc &&
         Int.eq size (Int.repr 2048) && Int.eq side Int.zero
      then [Reach_demo_alloc_call result]
      else []
  | Sassign (Evar global _) (Etempvar source _) =>
      if Pos.eqb global G._gDemoInputsMemAlloc
      then [Reach_demo_alloc_global_store source]
      else []
  | Sset destination (Evar global _) =>
      if Pos.eqb global G._gDemoInputsMemAlloc
      then [Reach_demo_alloc_global_load destination]
      else []
  | Scall None (Evar callee _)
      (Eaddrof (Evar list_global _) _ :: Evar demo_data _ ::
       Etempvar source _ :: nil) =>
      if Pos.eqb callee G._setup_dma_table_list &&
         Pos.eqb list_global G._gDemoInputsBuf &&
         Pos.eqb demo_data G._gDemoInputs
      then [Reach_setup_demo_list_call source]
      else []
  | Sassign
      (Efield (Ederef (Etempvar list_parameter _) _) field _)
      (Etempvar source_parameter _) =>
      if Pos.eqb list_parameter R._list &&
         Pos.eqb field R._bufTarget &&
         Pos.eqb source_parameter R._buffer
      then [Reach_buf_target_store]
      else []
  | Sset destination
      (Efield (Ederef (Etempvar list_parameter _) _) field _) =>
      if Pos.eqb list_parameter R._list && Pos.eqb field R._bufTarget
      then [Reach_buf_target_read destination]
      else []
  | Sset destination (Efield (Evar list_global _) field _) =>
      if Pos.eqb list_global T._gDemoInputsBuf && Pos.eqb field T._bufTarget
      then [Reach_title_buf_target_read destination]
      else []
  | Sassign (Evar global _)
      (Ebinop Oadd (Ecast (Etempvar source _) _)
        (Econst_int one _) _) =>
      if Pos.eqb global T._gCurrDemoInput && Int.eq one Int.one
      then [Reach_title_current_from_buffer source]
      else []
  | _ => []
  end.

Fixpoint reachability_events_s (s : statement) : list reachability_event :=
  reachability_event_of_statement s ++
  match s with
  | Ssequence first second
  | Sifthenelse _ first second
  | Sloop first second =>
      reachability_events_s first ++ reachability_events_s second
  | Slabel _ body => reachability_events_s body
  | Sswitch _ cases => reachability_events_ls cases
  | _ => []
  end
with reachability_events_ls
    (cases : labeled_statements) : list reachability_event :=
  match cases with
  | LSnil => []
  | LScons _ body rest =>
      reachability_events_s body ++ reachability_events_ls rest
  end.

Fixpoint reachability_event_subsequenceb
    (needle haystack : list reachability_event) : bool :=
  match needle with
  | [] => true
  | wanted :: remaining =>
      match haystack with
      | [] => false
      | found :: rest =>
          if reachability_event_eqb wanted found
          then reachability_event_subsequenceb remaining rest
          else reachability_event_subsequenceb needle rest
      end
  end.

Fixpoint field_assignment_count_s
    (field : ident) (s : statement) : nat :=
  (match s with
   | Sassign (Efield _ found _) _ =>
       if Pos.eqb found field then 1%nat else 0%nat
   | _ => 0%nat
   end) +
  match s with
  | Ssequence first second
  | Sifthenelse _ first second
  | Sloop first second =>
      field_assignment_count_s field first +
      field_assignment_count_s field second
  | Slabel _ body => field_assignment_count_s field body
  | Sswitch _ cases => field_assignment_count_ls field cases
  | _ => 0%nat
  end
with field_assignment_count_ls
    (field : ident) (cases : labeled_statements) : nat :=
  match cases with
  | LSnil => 0%nat
  | LScons _ body rest =>
      field_assignment_count_s field body +
      field_assignment_count_ls field rest
  end.

Definition expected_pool_initialization : list reachability_event :=
  [Reach_pool_start; Reach_pool_end; Reach_pool_init_call].

Definition expected_demo_allocation_handoff : list reachability_event :=
  [ Reach_demo_alloc_call G._t'2;
    Reach_demo_alloc_global_store G._t'2;
    Reach_demo_alloc_global_load G._t'3;
    Reach_setup_demo_list_call G._t'3 ].

Definition expected_title_pointer_origin : list reachability_event :=
  [ Reach_title_buf_target_read T._t'6;
    Reach_title_current_from_buffer T._t'6 ].

Theorem generated_main_initializes_fixed_pool_interval :
  reachability_event_subsequenceb expected_pool_initialization
    (reachability_events_s (fn_body N.f_alloc_pool)) = true.
Proof. vm_compute. reflexivity. Qed.

Theorem generated_allocator_has_align_and_left_result_shape :
  reachability_event_subsequenceb
    [Reach_allocator_align; Reach_allocator_left_result]
    (reachability_events_s (fn_body R.f_main_pool_alloc)) = true.
Proof. vm_compute. reflexivity. Qed.

Theorem generated_setup_game_memory_hands_demo_allocation_to_dma_list :
  reachability_event_subsequenceb expected_demo_allocation_handoff
    (reachability_events_s (fn_body G.f_setup_game_memory)) = true.
Proof. vm_compute. reflexivity. Qed.

Theorem generated_setup_dma_list_stores_buffer_once :
  reachability_event_subsequenceb [Reach_buf_target_store]
    (reachability_events_s (fn_body R.f_setup_dma_table_list)) = true /\
  field_assignment_count_s R._bufTarget
    (fn_body R.f_setup_dma_table_list) = 1%nat.
Proof. vm_compute. split; reflexivity. Qed.

Theorem generated_load_patchable_reads_but_never_writes_buffer_target :
  (exists destination,
    reachability_event_subsequenceb [Reach_buf_target_read destination]
      (reachability_events_s (fn_body R.f_load_patchable_table)) = true) /\
  field_assignment_count_s R._bufTarget
    (fn_body R.f_load_patchable_table) = 0%nat.
Proof.
  split.
  - exists R._t'3.
    vm_compute. reflexivity.
  - vm_compute. reflexivity.
Qed.

Theorem generated_title_current_pointer_originates_from_demo_buffer :
  reachability_event_subsequenceb expected_title_pointer_origin
    (reachability_events_s (fn_body T.f_run_level_id_or_demo)) = true.
Proof. vm_compute. reflexivity. Qed.

Theorem generated_mario_states_global_is_one_concrete_state :
  gvar_info L.v_gMarioStates =
    Tarray (Tstruct L._MarioState noattr) 1 noattr /\
  gvar_init L.v_gMarioStates = [Init_space 200].
Proof. split; reflexivity. Qed.

Definition generated_reachability_ast_claim : Prop :=
  reachability_event_subsequenceb expected_pool_initialization
    (reachability_events_s (fn_body N.f_alloc_pool)) = true /\
  reachability_event_subsequenceb
    [Reach_allocator_align; Reach_allocator_left_result]
    (reachability_events_s (fn_body R.f_main_pool_alloc)) = true /\
  reachability_event_subsequenceb expected_demo_allocation_handoff
    (reachability_events_s (fn_body G.f_setup_game_memory)) = true /\
  field_assignment_count_s R._bufTarget
    (fn_body R.f_setup_dma_table_list) = 1%nat /\
  field_assignment_count_s R._bufTarget
    (fn_body R.f_load_patchable_table) = 0%nat /\
  reachability_event_subsequenceb expected_title_pointer_origin
    (reachability_events_s (fn_body T.f_run_level_id_or_demo)) = true /\
  gvar_info L.v_gMarioStates =
    Tarray (Tstruct L._MarioState noattr) 1 noattr.

Theorem generated_reachability_ast_certificate :
  generated_reachability_ast_claim.
Proof.
  unfold generated_reachability_ast_claim.
  split; [apply generated_main_initializes_fixed_pool_interval |].
  split; [apply generated_allocator_has_align_and_left_result_shape |].
  split; [apply generated_setup_game_memory_hands_demo_allocation_to_dma_list |].
  split.
  - exact (proj2 generated_setup_dma_list_stores_buffer_once).
  - split.
    + exact (proj2 generated_load_patchable_reads_but_never_writes_buffer_target).
    + split; [apply generated_title_current_pointer_originates_from_demo_buffer |].
      exact (proj1 generated_mario_states_global_is_one_concrete_state).
Qed.
