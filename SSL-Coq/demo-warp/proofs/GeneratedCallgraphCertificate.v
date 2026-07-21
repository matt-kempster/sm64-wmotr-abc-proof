From Coq Require Import Bool List PArith.BinPos.
From compcert Require Import AST Integers Ctypes Clight.
From DemoWarp.Generated Require Import
  game_init title_screen level_update memory camera behavior_actions
  rumble_init save_file os_cont_start_read_data os_si_raw_start_dma.
From DemoWarp.Proofs Require Import AuthorizedWriterExec.

Module G := game_init.
Module T := title_screen.
Module L := level_update.
Module M := memory.
Module C := camera.
Module B := behavior_actions.
Module R := rumble_init.
Module S := save_file.
Module OC := os_cont_start_read_data.
Module SI := os_si_raw_start_dma.

Definition authorized_update_pairb (s : statement) : bool :=
  match s with
  | Ssequence (Sset source_temp source)
      (Sassign (Evar target _) rhs) =>
      Pos.eqb target G._gCurrDemoInput &&
      match source, rhs with
      | Evar source_global _,
        Ebinop Oadd (Etempvar rhs_temp _) (Econst_int one _) _ =>
          Pos.eqb source_global G._gCurrDemoInput &&
          Pos.eqb source_temp G._t'5 &&
          Pos.eqb rhs_temp G._t'5 && Int.eq one Int.one
      | Efield (Evar handler _) field _,
        Ebinop Oadd (Ecast (Etempvar rhs_temp _) _)
          (Econst_int one _) _ =>
          Pos.eqb handler T._gDemoInputsBuf &&
          Pos.eqb field T._bufTarget &&
          Pos.eqb source_temp T._t'6 &&
          Pos.eqb rhs_temp T._t'6 && Int.eq one Int.one
      | _, _ => false
      end
  | _ => false
  end.

Fixpoint authorized_pair_count_s (s : statement) : nat :=
  (if authorized_update_pairb s then 1 else 0) +
  match s with
  | Ssequence first second
  | Sifthenelse _ first second
  | Sloop first second =>
      authorized_pair_count_s first + authorized_pair_count_s second
  | Slabel _ body => authorized_pair_count_s body
  | Sswitch _ cases => authorized_pair_count_ls cases
  | _ => 0
  end
with authorized_pair_count_ls (cases : labeled_statements) : nat :=
  match cases with
  | LSnil => 0
  | LScons _ body rest =>
      authorized_pair_count_s body + authorized_pair_count_ls rest
  end.

Fixpoint authorized_pair_count_defs
    (defs : list (ident * globdef Clight.fundef type)) : nat :=
  match defs with
  | nil => 0
  | (_, Gfun (Internal f)) :: rest =>
      authorized_pair_count_s (fn_body f) + authorized_pair_count_defs rest
  | _ :: rest => authorized_pair_count_defs rest
  end.

Definition generated_authorized_pair_surface : nat :=
  authorized_pair_count_defs (prog_defs G.prog) +
  authorized_pair_count_defs (prog_defs T.prog) +
  authorized_pair_count_defs (prog_defs L.prog) +
  authorized_pair_count_defs (prog_defs M.prog) +
  authorized_pair_count_defs (prog_defs C.prog) +
  authorized_pair_count_defs (prog_defs B.prog) +
  authorized_pair_count_defs (prog_defs R.prog) +
  authorized_pair_count_defs (prog_defs S.prog) +
  authorized_pair_count_defs (prog_defs OC.prog) +
  authorized_pair_count_defs (prog_defs SI.prog).

Theorem run_increment_pair_is_authorized :
  authorized_update_pairb run_increment_pair = true.
Proof. vm_compute. reflexivity. Qed.

Theorem title_install_pair_is_authorized :
  authorized_update_pairb title_install_pair = true.
Proof. vm_compute. reflexivity. Qed.

Theorem generated_run_body_has_one_authorized_pair :
  authorized_pair_count_s (fn_body G.f_run_demo_inputs) = 1.
Proof. vm_compute. reflexivity. Qed.

Theorem generated_title_body_has_one_authorized_pair :
  authorized_pair_count_s (fn_body T.f_run_level_id_or_demo) = 1.
Proof. vm_compute. reflexivity. Qed.

Theorem generated_closed_world_has_exactly_two_authorized_pairs :
  generated_authorized_pair_surface = 2.
Proof. vm_compute. reflexivity. Qed.

Definition generated_authorized_pair_claim : Prop :=
  authorized_update_pairb run_increment_pair = true /\
  authorized_update_pairb title_install_pair = true /\
  authorized_pair_count_s (fn_body G.f_run_demo_inputs) = 1 /\
  authorized_pair_count_s (fn_body T.f_run_level_id_or_demo) = 1 /\
  generated_authorized_pair_surface = 2.

Theorem generated_authorized_pair_certificate :
  generated_authorized_pair_claim.
Proof.
  unfold generated_authorized_pair_claim.
  exact (conj run_increment_pair_is_authorized
    (conj title_install_pair_is_authorized
      (conj generated_run_body_has_one_authorized_pair
        (conj generated_title_body_has_one_authorized_pair
          generated_closed_world_has_exactly_two_authorized_pairs)))).
Qed.
