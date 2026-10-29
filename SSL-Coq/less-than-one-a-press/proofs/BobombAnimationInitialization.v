(** Concrete initialization and animation-table witnesses for both selected
    programs. No object execution, survival or wrong warp is asserted. *)
From Coq Require Import ZArith.
From compcert Require Import AST Clight Ctypes Globalenvs Integers Memory Values.
From LessThanOneAPress.Proofs Require Import
  GameTypes SelectedClightTarget SelectedClightInitialMemory BobombAnimationLink.

Local Open Scope Z_scope.

Theorem selected_bobomb_animation_initialized_table_exists : forall version,
  exists memory table_block anim0_block anim1_block,
    Genv.init_mem (selected_clight_target version) = Some memory /\
    Genv.find_symbol (Clight.globalenv (selected_clight_target version))
      bal_table_id = Some table_block /\
    Genv.find_symbol (Clight.globalenv (selected_clight_target version))
      bal_anim0_id = Some anim0_block /\
    Genv.find_symbol (Clight.globalenv (selected_clight_target version))
      bal_anim1_id = Some anim1_block /\
    Mem.load Mptr memory table_block 0 = Some (Vptr anim0_block Ptrofs.zero) /\
    Mem.load Mptr memory table_block 4 = Some (Vptr anim1_block Ptrofs.zero) /\
    Mem.load Mint32 memory table_block 8 = Some (Vint Int.zero).
Proof.
  intro version.
  destruct (selected_clight_initial_memory_exists version) as [memory Hinit].
  destruct (selected_bobomb_animation_initial_entries version memory Hinit)
    as [table_block [anim0_block [anim1_block Hentries]]].
  exists memory, table_block, anim0_block, anim1_block.
  exact (conj Hinit Hentries).
Qed.

Definition BobombAnimationInitializationBoundary : Prop :=
  BobombAnimationLinkBoundary /\
  (forall version,
    exists memory table_block anim0_block anim1_block,
      Genv.init_mem (selected_clight_target version) = Some memory /\
      Genv.find_symbol (Clight.globalenv (selected_clight_target version))
        bal_table_id = Some table_block /\
      Genv.find_symbol (Clight.globalenv (selected_clight_target version))
        bal_anim0_id = Some anim0_block /\
      Genv.find_symbol (Clight.globalenv (selected_clight_target version))
        bal_anim1_id = Some anim1_block /\
      Mem.load Mptr memory table_block 0 = Some (Vptr anim0_block Ptrofs.zero) /\
      Mem.load Mptr memory table_block 4 = Some (Vptr anim1_block Ptrofs.zero) /\
      Mem.load Mint32 memory table_block 8 = Some (Vint Int.zero)).

Theorem bobomb_animation_initialization_boundary_checked :
  BobombAnimationInitializationBoundary.
Proof.
  split; [exact bobomb_animation_link_boundary_checked |
    exact selected_bobomb_animation_initialized_table_exists].
Qed.
