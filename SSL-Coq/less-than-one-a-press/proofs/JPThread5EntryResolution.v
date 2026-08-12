(** Exact resolution of the JP game-task entry in the official cleaned link.
    The only concrete computation is the definition map of the first cleaned
    unit; the whole official link is consumed through opaque linker lemmas. *)

From compcert Require Import AST Clight Coqlib Ctypes Globalenvs Linking Maps.
From LessThanOneAPress.Generated Require Import jp_game_init.
From LessThanOneAPress.Proofs Require Import
  CleanedClightPrograms ClightLinkExecution.

Definition jp_first_cleaned_unit : Clight.program :=
  nfirst jp_cleaned_units.

Lemma nfirst_nIn :
  forall (A : Type) (units : nlist A),
    nIn (nfirst units) units.
Proof.
  intros A [head | head rest]; cbn; [reflexivity | now left].
Qed.

Theorem jp_first_cleaned_unit_thread5_defmap_checked :
  (prog_defmap jp_first_cleaned_unit) ! jp_game_init._thread5_game_loop =
    Some (Gfun (Internal jp_game_init.f_thread5_game_loop)).
Proof. vm_compute. reflexivity. Qed.

Theorem jp_thread5_game_loop_resolves_exact_body :
  exists entry_block,
    Genv.find_symbol (Clight.globalenv jp_official_cleaned_slice)
      jp_game_init._thread5_game_loop = Some entry_block /\
    Genv.find_funct_ptr (Clight.globalenv jp_official_cleaned_slice)
      entry_block = Some (Internal jp_game_init.f_thread5_game_loop).
Proof.
  eapply (official_link_resolves_internal_globalenv
    jp_cleaned_units jp_official_cleaned_slice
    jp_cleaned_units_official_link
    jp_first_cleaned_unit
    jp_game_init._thread5_game_loop
    jp_game_init.f_thread5_game_loop).
  - exact (nfirst_nIn _ jp_cleaned_units).
  - exact jp_first_cleaned_unit_thread5_defmap_checked.
Qed.
