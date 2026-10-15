From Coq Require Import List ZArith.
From compcert Require Import AST Clight Clightdefs Cop Ctypes Integers.
From Demo.Generated Require Import
  us_level_update jp_level_update us_level_script jp_level_script.
Import ListNotations.
Local Open Scope Z_scope.
Module U := us_level_update.
Module C := us_level_script.

(** Static certificates for the real generated dispatch code.  In particular,
    none of these equalities supplies an execution, call-target resolution,
    a frame theorem for callees, or a path from normal initialization. *)

Definition delayed_demo_choice (body : statement)
    : option (statement * expr * statement) :=
  match body with
  | Ssequence _
      (Sifthenelse _
        (Ssequence _
          (Ssequence _
            (Sifthenelse _ _
              (Ssequence load (Sifthenelse guard active _))))) _) =>
      Some (load, guard, active)
  | _ => None
  end.

Definition expected_delayed_demo_choice : statement * expr * statement :=
  (Sset U._t'5
      (Evar U._gCurrDemoInput (tptr (Tstruct U._DemoInput noattr))),
   Ebinop One
      (Etempvar U._t'5 (tptr (Tstruct U._DemoInput noattr)))
      (Ecast (Econst_int (Int.repr 0) tint) (tptr tvoid)) tint,
   Ssequence
      (Sset U._t'26 (Evar U._sDelayedWarpOp tshort))
      (Sifthenelse
        (Ebinop Oeq (Etempvar U._t'26 tshort)
          (Econst_int (Int.repr 25) tint) tint)
        (Scall None
          (Evar U._warp_special (Tfunction [tint] tvoid cc_default))
          [Eunop Oneg (Econst_int (Int.repr 8) tint) tint])
        (Scall None
          (Evar U._warp_special (Tfunction [tint] tvoid cc_default))
          [Eunop Oneg (Econst_int (Int.repr 2) tint) tint]))).

Definition delayed_demo_choice_is_checked : Prop :=
  delayed_demo_choice (fn_body U.f_initiate_delayed_warp) =
    Some expected_delayed_demo_choice /\
  delayed_demo_choice
    (fn_body jp_level_update.f_initiate_delayed_warp) =
    Some expected_delayed_demo_choice.

(** The selected non-null branch consists exactly of the operation test and
    warp_special(-8) / warp_special(-2) calls.  Debug handling is outside the
    selected branch, and the theorem does not claim it is reached. *)
Theorem generated_delayed_demo_choice_us_jp :
  delayed_demo_choice_is_checked.
Proof. split; reflexivity. Qed.

Definition command_forward_capture (body : statement)
    : option (statement * statement * statement) :=
  match body with
  | Ssequence _
      (Ssequence
        (Ssequence
          (Ssequence _ (Ssequence _ (Ssequence load call))) capture) _) =>
      Some (load, call, capture)
  | _ => None
  end.

Definition expected_command_forward_capture
    (argument saved : ident) : statement * statement * statement :=
  (Sset saved (Evar C._sRegister tint),
   Scall (Some C._t'1)
     (Etempvar C._func
       (tptr (Tfunction [tshort; tint] tint cc_default)))
     [Etempvar argument tshort; Etempvar saved tint],
   Sassign (Evar C._sRegister tint) (Etempvar C._t'1 tint)).

Definition command_register_forward_capture_is_checked : Prop :=
  command_forward_capture (fn_body C.f_level_cmd_call) =
    Some (expected_command_forward_capture C._t'6 C._t'7) /\
  command_forward_capture (fn_body jp_level_script.f_level_cmd_call) =
    Some (expected_command_forward_capture C._t'6 C._t'7) /\
  command_forward_capture (fn_body C.f_level_cmd_call_loop) =
    Some (expected_command_forward_capture C._t'7 C._t'8) /\
  command_forward_capture (fn_body jp_level_script.f_level_cmd_call_loop) =
    Some (expected_command_forward_capture C._t'7 C._t'8).

(** This pins down the read-register / indirect-call / capture-result suffix
    in both interpreter call commands.  It does not resolve _func or prove
    preservation of the register by arbitrary reached code. *)
Theorem generated_command_register_forward_capture_us_jp :
  command_register_forward_capture_is_checked.
Proof. repeat split; reflexivity. Qed.

Fixpoint direct_global_write_values (id : ident) (s : statement)
    : list expr :=
  match s with
  | Sassign (Evar name _) value => if Pos.eqb id name then [value] else []
  | Ssequence a b | Sloop a b =>
      direct_global_write_values id a ++ direct_global_write_values id b
  | Sifthenelse _ a b =>
      direct_global_write_values id a ++ direct_global_write_values id b
  | Sswitch _ cases => direct_global_write_values_labels id cases
  | Slabel _ a => direct_global_write_values id a
  | _ => []
  end
with direct_global_write_values_labels (id : ident) (ls : labeled_statements)
    : list expr :=
  match ls with
  | LSnil => []
  | LScons _ s rest =>
      direct_global_write_values id s ++
      direct_global_write_values_labels id rest
  end.

Fixpoint return_values (s : statement) : list expr :=
  match s with
  | Sreturn (Some value) => [value]
  | Ssequence a b | Sloop a b => return_values a ++ return_values b
  | Sifthenelse _ a b => return_values a ++ return_values b
  | Sswitch _ cases => return_values_labels cases
  | Slabel _ a => return_values a
  | _ => []
  end
with return_values_labels (ls : labeled_statements) : list expr :=
  match ls with
  | LSnil => []
  | LScons _ s rest => return_values s ++ return_values_labels rest
  end.

Definition initializer_level_transfer_is_checked : Prop :=
  direct_global_write_values U._gCurrLevelNum
    (fn_body U.f_lvl_init_from_save_file) = [Etempvar U._levelNum tint] /\
  direct_global_write_values jp_level_update._gCurrLevelNum
    (fn_body jp_level_update.f_lvl_init_from_save_file) =
    [Etempvar jp_level_update._levelNum tint] /\
  return_values (fn_body U.f_lvl_init_from_save_file) =
    [Etempvar U._levelNum tint] /\
  return_values (fn_body jp_level_update.f_lvl_init_from_save_file) =
    [Etempvar jp_level_update._levelNum tint] /\
  direct_global_write_values U._gCurrLevelNum
    (fn_body U.f_lvl_set_current_level) = [Etempvar U._levelNum tint] /\
  direct_global_write_values jp_level_update._gCurrLevelNum
    (fn_body jp_level_update.f_lvl_set_current_level) =
    [Etempvar jp_level_update._levelNum tint].

(** These are direct-write/return censuses of concrete generated functions.
    Calls and indirect stores are intentionally not turned into semantic
    preservation claims. *)
Theorem generated_initializer_level_transfer_us_jp :
  initializer_level_transfer_is_checked.
Proof. vm_compute; repeat split; reflexivity. Qed.

Definition demo_dispatch_boundary_claim : Prop :=
  delayed_demo_choice_is_checked /\
  command_register_forward_capture_is_checked /\
  initializer_level_transfer_is_checked.

Theorem generated_demo_dispatch_boundary_us_jp :
  demo_dispatch_boundary_claim.
Proof.
  exact (conj generated_delayed_demo_choice_us_jp
    (conj generated_command_register_forward_capture_us_jp
      generated_initializer_level_transfer_us_jp)).
Qed.
