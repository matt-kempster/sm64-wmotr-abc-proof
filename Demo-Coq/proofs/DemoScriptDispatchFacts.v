From Coq Require Import Bool List ZArith.
From compcert Require Import AST Clight Ctypes Integers.
From Demo.Generated Require Import us_level_scripts jp_level_scripts.
Import ListNotations.
Local Open Scope Z_scope.
Module D := us_level_scripts.

(** This is a finite initializer certificate.  It parses the whole dispatch
    table at command boundaries, checks the load-current-level instruction,
    equality operator and instruction lengths, selects a matching arm, then
    resolves that arm's generated global and the EXECUTE entry operand.
    No conclusion about execution, loaded memory or retail reachability is
    supplied by this syntax check.  Asset filenames play no role. *)

Definition dispatch_header_is (word : int) (opcode bytes arg2 arg3 : Z) : bool :=
  let value := Int.unsigned word in
  Z.eqb (Z.shiftr value 24) opcode &&
  Z.eqb (Z.land (Z.shiftr value 16) 255) bytes &&
  Z.eqb (Z.land (Z.shiftr value 8) 255) arg2 &&
  Z.eqb (Z.land value 255) arg3.

Fixpoint decode_equality_dispatch (fuel : nat) (xs : list init_data)
    : option (list (Z * ident)) :=
  match fuel with
  | O => None
  | S remaining =>
      match xs with
      | [Init_int32 exit] =>
          if dispatch_header_is exit 2 4 0 0 then Some [] else None
      | Init_int32 jump :: Init_int32 argument :: Init_addrof target offset :: rest =>
          if dispatch_header_is jump 12 12 2 0 && Ptrofs.eq offset Ptrofs.zero
          then match decode_equality_dispatch remaining rest with
               | Some arms => Some ((Int.signed argument, target) :: arms)
               | None => None
               end
          else None
      | _ => None
      end
  end.

Definition decode_current_level_dispatch (xs : list init_data)
    : option (list (Z * ident)) :=
  match xs with
  | Init_int32 read :: rest =>
      if dispatch_header_is read 60 4 1 3
      then decode_equality_dispatch (length xs) rest
      else None
  | _ => None
  end.

Fixpoint lookup_dispatch_arm (header : Z) (arms : list (Z * ident))
    : option ident :=
  match arms with
  | [] => None
  | (argument, target) :: rest =>
      if Z.eqb header argument then Some target
      else lookup_dispatch_arm header rest
  end.

Fixpoint lookup_script_initializer (symbol : ident)
    (definitions : list (ident * globdef Clight.fundef type)) : option (list init_data) :=
  match definitions with
  | [] => None
  | (name, definition) :: rest =>
      if Pos.eqb name symbol then
        match definition with Gvar global => Some (gvar_init global) | _ => None end
      else lookup_script_initializer symbol rest
  end.

(** The entry is specifically the fourth word of EXECUTE(0x0E,...), with
    zero relocation offsets and an immediate RETURN command.  ROM-range
    operands must be relocations; unrelated occurrences of an entry address
    elsewhere in an initializer cannot satisfy this decoder. *)
Definition decode_level_execute_entry (xs : list init_data) : option ident :=
  match xs with
  | [Init_int32 execute; Init_addrof _ rom_start_offset;
     Init_addrof _ rom_end_offset; Init_addrof entry entry_offset;
     Init_int32 ret] =>
      if dispatch_header_is execute 0 16 0 14 &&
         Ptrofs.eq rom_start_offset Ptrofs.zero &&
         Ptrofs.eq rom_end_offset Ptrofs.zero &&
         Ptrofs.eq entry_offset Ptrofs.zero &&
         dispatch_header_is ret 7 4 0 0
      then Some entry else None
  | _ => None
  end.

Definition checked_level_dispatch_route
    (definitions : list (ident * globdef Clight.fundef type)) (header : Z)
    : option (ident * ident) :=
  match lookup_script_initializer D._script_exec_level_table definitions with
  | Some table =>
      match decode_current_level_dispatch table with
      | Some arms =>
          match lookup_dispatch_arm header arms with
          | Some script =>
              match lookup_script_initializer script definitions with
              | Some body =>
                  match decode_level_execute_entry body with
                  | Some entry => Some (script, entry)
                  | None => None
                  end
              | None => None
              end
          | None => None
          end
      | None => None
      end
  | None => None
  end.

Definition demo_dispatch_headers : list Z := [4; 5; 7; 12; 24; 27; 30].

Definition expected_demo_dispatch_routes : list (option (ident * ident)) :=
  [Some (D._script_exec_bbh, D._level_bbh_entry);
   Some (D._script_exec_ccm, D._level_ccm_entry);
   Some (D._script_exec_hmc, D._level_hmc_entry);
   Some (D._script_exec_jrb, D._level_jrb_entry);
   Some (D._script_exec_wf, D._level_wf_entry);
   Some (D._script_exec_pss, D._level_pss_entry);
   Some (D._script_exec_bowser_1, D._level_bowser_1_entry)].

Definition demo_script_dispatch_routes_claim_us_jp : Prop :=
  map (checked_level_dispatch_route us_level_scripts.global_definitions)
    demo_dispatch_headers = expected_demo_dispatch_routes /\
  map (checked_level_dispatch_route jp_level_scripts.global_definitions)
    demo_dispatch_headers = expected_demo_dispatch_routes /\
  checked_level_dispatch_route us_level_scripts.global_definitions 17 =
    Some (D._script_exec_bitdw, D._level_bitdw_entry) /\
  checked_level_dispatch_route jp_level_scripts.global_definitions 17 =
    Some (D._script_exec_bitdw, D._level_bitdw_entry) /\
  D._script_exec_bowser_1 <> D._script_exec_bitdw /\
  D._level_bowser_1_entry <> D._level_bitdw_entry.

Theorem generated_demo_script_dispatch_routes_us_jp :
  demo_script_dispatch_routes_claim_us_jp.
Proof. vm_compute. repeat split; discriminate || reflexivity. Qed.
