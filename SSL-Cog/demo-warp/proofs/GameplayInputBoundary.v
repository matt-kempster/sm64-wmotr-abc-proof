From Coq Require Import Bool List PArith.BinPos.
From compcert Require Import AST Ctypes Clight.
From DemoWarp.Generated Require Import game_init.
From DemoWarp.Proofs Require Import GeneratedFacts NormalInitialization.

Import ListNotations.
Module G := game_init.

Fixpoint calls_ident_s (wanted : ident) (s : statement) : bool :=
  (match s with
   | Scall _ (Evar found _) _ => Pos.eqb wanted found
   | _ => false
   end) ||
  match s with
  | Ssequence first second
  | Sifthenelse _ first second
  | Sloop first second => calls_ident_s wanted first || calls_ident_s wanted second
  | Slabel _ body => calls_ident_s wanted body
  | Sswitch _ cases => calls_ident_ls wanted cases
  | _ => false
  end
with calls_ident_ls (wanted : ident) (cases : labeled_statements) : bool :=
  match cases with
  | LSnil => false
  | LScons _ body rest => calls_ident_s wanted body || calls_ident_ls wanted rest
  end.

Fixpoint assigns_global_s (wanted : ident) (s : statement) : nat :=
  (match s with
   | Sassign (Evar found _) _ => if Pos.eqb wanted found then 1%nat else 0%nat
   | _ => 0%nat
   end) +
  match s with
  | Ssequence first second
  | Sifthenelse _ first second
  | Sloop first second => assigns_global_s wanted first + assigns_global_s wanted second
  | Slabel _ body => assigns_global_s wanted body
  | Sswitch _ cases => assigns_global_ls wanted cases
  | _ => 0%nat
  end
with assigns_global_ls (wanted : ident) (cases : labeled_statements) : nat :=
  match cases with
  | LSnil => 0%nat
  | LScons _ body rest => assigns_global_s wanted body + assigns_global_ls wanted rest
  end.

Theorem generated_controller_reader_calls_demo_playback :
  calls_ident_s G._run_demo_inputs (fn_body G.f_read_controller_inputs) = true.
Proof. vm_compute. reflexivity. Qed.

Theorem generated_demo_playback_has_no_calls :
  forall target, calls_ident_s target (fn_body G.f_run_demo_inputs) = false.
Proof. intro target; vm_compute; reflexivity. Qed.

Theorem generated_controller_reader_does_not_assign_demo_pointer :
  assigns_global_s G._gCurrDemoInput (fn_body G.f_read_controller_inputs) = 0%nat.
Proof. vm_compute. reflexivity. Qed.

Theorem generated_controller_reader_does_not_assign_demo_handler :
  assigns_global_s G._gDemoInputsBuf (fn_body G.f_read_controller_inputs) = 0%nat.
Proof. vm_compute. reflexivity. Qed.

Definition generated_controller_demo_boundary : Prop :=
  calls_ident_s G._run_demo_inputs (fn_body G.f_read_controller_inputs) = true /\
  (forall target, calls_ident_s target (fn_body G.f_run_demo_inputs) = false) /\
  assigns_global_s G._gCurrDemoInput (fn_body G.f_read_controller_inputs) = 0%nat /\
  assigns_global_s G._gDemoInputsBuf (fn_body G.f_read_controller_inputs) = 0%nat /\
  pointer_writes_s G._gCurrDemoInput (fn_body G.f_run_demo_inputs) =
    [Write_add_one] /\
  timer_store_count (demo_events_s (fn_body G.f_run_demo_inputs)) = 1%nat.

Theorem generated_controller_demo_boundary_certificate :
  generated_controller_demo_boundary.
Proof.
  unfold generated_controller_demo_boundary.
  exact (conj generated_controller_reader_calls_demo_playback
    (conj generated_demo_playback_has_no_calls
      (conj generated_controller_reader_does_not_assign_demo_pointer
        (conj generated_controller_reader_does_not_assign_demo_handler
          (conj generated_run_demo_pointer_writes_are_increment_only
            generated_run_demo_inputs_has_one_timer_store))))).
Qed.

Theorem normal_controller_path_preserves_no_alias_boundary :
  generated_controller_demo_boundary /\
  normal_initialization_reachability_claim.
Proof.
  split.
  - apply generated_controller_demo_boundary_certificate.
  - apply normal_initialization_forbids_demo_pointer_mario_y_alias.
Qed.
