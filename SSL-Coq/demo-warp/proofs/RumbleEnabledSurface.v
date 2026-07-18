From Coq Require Import Bool List.
From compcert Require Import AST Ctypes Clight.
From DemoWarp.Generated Require Import rumble_enabled.
From DemoWarp.Proofs Require Import TargetCapabilitySet TargetUseCensus
  GeneratedCallgraphCertificate.

Import ListNotations.
Module RE := rumble_enabled.

Definition enabled_rumble_current_pointer_users : list ident :=
  global_users RE._gCurrDemoInput (prog_defs RE.prog).

Definition expected_enabled_rumble_current_pointer_users : list ident :=
  [ RE._queue_rumble_data;
    RE._reset_rumble_timers;
    RE._reset_rumble_timers_2;
    RE._func_sh_8024CA04 ].

Definition enabled_rumble_current_pointer_occurrences : nat :=
  global_occurrences_s RE._gCurrDemoInput
    (fn_body RE.f_queue_rumble_data) +
  global_occurrences_s RE._gCurrDemoInput
    (fn_body RE.f_reset_rumble_timers) +
  global_occurrences_s RE._gCurrDemoInput
    (fn_body RE.f_reset_rumble_timers_2) +
  global_occurrences_s RE._gCurrDemoInput
    (fn_body RE.f_func_sh_8024CA04).

Theorem enabled_rumble_adds_exactly_four_current_pointer_users :
  enabled_rumble_current_pointer_users =
    expected_enabled_rumble_current_pointer_users.
Proof. vm_compute. reflexivity. Qed.

Theorem enabled_rumble_has_four_current_pointer_occurrences :
  enabled_rumble_current_pointer_occurrences = 4%nat.
Proof. vm_compute. reflexivity. Qed.

Theorem enabled_rumble_never_assigns_current_pointer :
  direct_global_assigns_defs RE._gCurrDemoInput (prog_defs RE.prog) = 0%nat.
Proof. vm_compute. reflexivity. Qed.

Theorem enabled_rumble_never_takes_current_pointer_cell_address :
  addrof_global_defs RE._gCurrDemoInput (prog_defs RE.prog) = 0%nat.
Proof. vm_compute. reflexivity. Qed.

Theorem enabled_rumble_users_only_null_test_loaded_pointer :
  read_only_users_safe_defs (prog_defs RE.prog) = true.
Proof. vm_compute. reflexivity. Qed.

Theorem enabled_rumble_has_no_authorized_pointer_update_pair :
  authorized_pair_count_defs (prog_defs RE.prog) = 0%nat.
Proof. vm_compute. reflexivity. Qed.

Definition enabled_rumble_pointer_capability_claim : Prop :=
  enabled_rumble_current_pointer_users =
    expected_enabled_rumble_current_pointer_users /\
  enabled_rumble_current_pointer_occurrences = 4%nat /\
  direct_global_assigns_defs RE._gCurrDemoInput (prog_defs RE.prog) = 0%nat /\
  addrof_global_defs RE._gCurrDemoInput (prog_defs RE.prog) = 0%nat /\
  read_only_users_safe_defs (prog_defs RE.prog) = true /\
  authorized_pair_count_defs (prog_defs RE.prog) = 0%nat.

Theorem enabled_rumble_pointer_capability_certificate :
  enabled_rumble_pointer_capability_claim.
Proof.
  unfold enabled_rumble_pointer_capability_claim.
  exact (conj enabled_rumble_adds_exactly_four_current_pointer_users
    (conj enabled_rumble_has_four_current_pointer_occurrences
      (conj enabled_rumble_never_assigns_current_pointer
        (conj enabled_rumble_never_takes_current_pointer_cell_address
          (conj enabled_rumble_users_only_null_test_loaded_pointer
            enabled_rumble_has_no_authorized_pointer_update_pair))))).
Qed.
