From Coq Require Import List ZArith Bool.
From compcert Require Import AST Integers Ctypes Clight.
From Demo.Generated Require Import
  us_title_screen jp_title_screen us_game_init jp_game_init
  us_level_update jp_level_update
  us_bitdw_level_script jp_bitdw_level_script
  us_bowser_1_level_script jp_bowser_1_level_script
  us_wf_level_script jp_wf_level_script
  us_ccm_level_script jp_ccm_level_script
  us_bbh_level_script jp_bbh_level_script
  us_jrb_level_script jp_jrb_level_script
  us_hmc_level_script jp_hmc_level_script
  us_pss_level_script jp_pss_level_script.

Import ListNotations.
Local Open Scope Z_scope.

(** These checks inspect generated syntax. They do not assert that a complete
    retail execution follows any particular branch, or that an arbitrary
    memory image is reachable. *)
Fixpoint expr_mentions (id : ident) (a : expr) : bool :=
  match a with
  | Evar name _ => Pos.eqb id name
  | Ederef x _ | Eaddrof x _ | Eunop _ x _ | Ecast x _ | Efield x _ _ =>
      expr_mentions id x
  | Ebinop _ x y _ => expr_mentions id x || expr_mentions id y
  | _ => false
  end.

Fixpoint stmt_mentions (id : ident) (s : statement) : bool :=
  match s with
  | Sassign a b => expr_mentions id a || expr_mentions id b
  | Sset _ a => expr_mentions id a
  | Scall _ fn args => expr_mentions id fn || existsb (expr_mentions id) args
  | Sbuiltin _ _ _ args => existsb (expr_mentions id) args
  | Ssequence a b | Sloop a b => stmt_mentions id a || stmt_mentions id b
  | Sifthenelse c a b => expr_mentions id c || stmt_mentions id a || stmt_mentions id b
  | Sreturn (Some a) => expr_mentions id a
  | Sswitch a cases => expr_mentions id a || labels_mentions id cases
  | Slabel _ body => stmt_mentions id body
  | _ => false
  end
with labels_mentions (id : ident) (ls : labeled_statements) : bool :=
  match ls with
  | LSnil => false
  | LScons _ s rest => stmt_mentions id s || labels_mentions id rest
  end.

Definition playback_has_no_level_reference : Prop :=
  stmt_mentions us_level_update._gCurrLevelNum
    (fn_body us_game_init.f_run_demo_inputs) = false /\
  stmt_mentions jp_level_update._gCurrLevelNum
    (fn_body jp_game_init.f_run_demo_inputs) = false.

Theorem generated_playback_has_no_level_reference_us_jp :
  playback_has_no_level_reference.
Proof. vm_compute; split; reflexivity. Qed.

Definition painting_path_has_no_demo_reference : Prop :=
  stmt_mentions us_level_update._gCurrDemoInput
    (fn_body us_level_update.f_initiate_painting_warp) = false /\
  stmt_mentions jp_level_update._gCurrDemoInput
    (fn_body jp_level_update.f_initiate_painting_warp) = false.

Theorem generated_painting_path_has_no_demo_reference_us_jp :
  painting_path_has_no_demo_reference.
Proof. vm_compute; split; reflexivity. Qed.

(** Parse command boundaries, not every word's high byte: operands can have
    the same high bytes as opcodes. Every operand must occupy one N64 word;
    zero-length, misaligned, truncated, or unknown (>0x3c) commands fail. *)
Definition word_initializer (x : init_data) : bool :=
  match x with Init_int32 _ | Init_addrof _ _ => true | _ => false end.

Fixpoint script_opcodes (fuel : nat) (xs : list init_data) : option (list Z) :=
  match xs with
  | [] => Some []
  | Init_int32 head :: _ =>
      match fuel with
      | O => None
      | S remaining =>
          let opcode := Z.shiftr (Int.unsigned head) 24 in
          let bytes := Z.land (Z.shiftr (Int.unsigned head) 16) 255 in
          let words := Z.to_nat (bytes / 4) in
          if ((4 <=? bytes) && Z.eqb (bytes mod 4) 0 &&
              (opcode <=? 60) && Nat.leb words (length xs) &&
              forallb word_initializer (firstn words xs))%bool
          then match script_opcodes remaining (skipn words xs) with
               | Some rest => Some (opcode :: rest)
               | None => None
               end
          else None
      end
  | _ => None
  end.

Definition no_painting_or_instant_commands (xs : list init_data) : bool :=
  match script_opcodes (length xs) xs with
  | Some ops => forallb (fun op => negb (Z.eqb op 39 || Z.eqb op 40)) ops
  | None => false
  end.

Definition initialized_globals (p : Clight.program) : list (list init_data) :=
  fold_right (fun pair acc =>
    match snd pair with
    | Gvar v => match gvar_init v with [] => acc | xs => xs :: acc end
    | _ => acc
    end) [] (prog_defs p).

Definition script_unit_excludes_painting_and_instant (p : Clight.program) : bool :=
  let scripts := initialized_globals p in
  negb (Nat.eqb (length scripts) 0) &&
  forallb no_painting_or_instant_commands scripts.

Definition demo_script_inventory : list Clight.program :=
  [us_bowser_1_level_script.prog; us_wf_level_script.prog;
   us_ccm_level_script.prog; us_bbh_level_script.prog;
   us_jrb_level_script.prog; us_hmc_level_script.prog; us_pss_level_script.prog;
   jp_bowser_1_level_script.prog; jp_wf_level_script.prog;
   jp_ccm_level_script.prog; jp_bbh_level_script.prog;
   jp_jrb_level_script.prog; jp_hmc_level_script.prog; jp_pss_level_script.prog].

(** The US stream named bitdw.bin selects header 30: the Bowser 1 arena,
    not the BITDW course (17). Bowser 1 is absent from the JP demo table;
    including its JP script makes this a conservative superset there.
    See DemoScriptDispatchFacts for the generated numeric dispatch census. *)
Definition demo_scripts_exclude_painting_and_instant : Prop :=
  forallb script_unit_excludes_painting_and_instant demo_script_inventory = true.

Theorem generated_demo_scripts_exclude_painting_and_instant_us_jp :
  demo_scripts_exclude_painting_and_instant.
Proof. vm_compute; reflexivity. Qed.

Definition demo_source_boundary_claim : Prop :=
  playback_has_no_level_reference /\
  painting_path_has_no_demo_reference /\
  demo_scripts_exclude_painting_and_instant.

Theorem generated_demo_source_boundary_us_jp : demo_source_boundary_claim.
Proof.
  exact (conj generated_playback_has_no_level_reference_us_jp
    (conj generated_painting_path_has_no_demo_reference_us_jp
      generated_demo_scripts_exclude_painting_and_instant_us_jp)).
Qed.
