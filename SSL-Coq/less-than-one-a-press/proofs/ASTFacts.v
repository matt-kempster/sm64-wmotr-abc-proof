From Coq Require Import Bool List PArith.BinPos ZArith.
From compcert Require Import AST Clight Cop Ctypes Floats Integers.

Import ListNotations.

Fixpoint calls_ident_s (callee : ident) (s : statement) : bool :=
  match s with
  | Scall _ (Evar id _) _ => Pos.eqb id callee
  | Ssequence a b
  | Sloop a b => calls_ident_s callee a || calls_ident_s callee b
  | Sifthenelse _ a b => calls_ident_s callee a || calls_ident_s callee b
  | Slabel _ body => calls_ident_s callee body
  | Sswitch _ cases => calls_ident_ls callee cases
  | _ => false
  end
with calls_ident_ls (callee : ident) (cases : labeled_statements) : bool :=
  match cases with
  | LSnil => false
  | LScons _ body rest =>
      calls_ident_s callee body || calls_ident_ls callee rest
  end.

(** Locate a direct-call occurrence under a particular switch label.  This
    records the syntactic link between the label and the call; it says neither
    that the switch selects the label nor that the call executes. *)
Fixpoint switch_case_calls_ident_s
    (tag : Z) (callee : ident) (s : statement) : bool :=
  match s with
  | Ssequence a b | Sloop a b =>
      switch_case_calls_ident_s tag callee a ||
      switch_case_calls_ident_s tag callee b
  | Sifthenelse _ a b =>
      switch_case_calls_ident_s tag callee a ||
      switch_case_calls_ident_s tag callee b
  | Sswitch _ cases =>
      switch_case_calls_ident_ls tag callee cases
  | Slabel _ body => switch_case_calls_ident_s tag callee body
  | _ => false
  end
with switch_case_calls_ident_ls
    (tag : Z) (callee : ident) (cases : labeled_statements) : bool :=
  match cases with
  | LSnil => false
  | LScons label body rest =>
      (match label with
       | Some found => Z.eqb found tag && calls_ident_s callee body
       | None => false
       end) ||
      switch_case_calls_ident_s tag callee body ||
      switch_case_calls_ident_ls tag callee rest
  end.

Fixpoint direct_callees_s (s : statement) : list ident :=
  match s with
  | Scall _ (Evar id _) _ => [id]
  | Ssequence a b
  | Sloop a b => direct_callees_s a ++ direct_callees_s b
  | Sifthenelse _ a b => direct_callees_s a ++ direct_callees_s b
  | Slabel _ body => direct_callees_s body
  | Sswitch _ cases => direct_callees_ls cases
  | _ => []
  end
with direct_callees_ls (cases : labeled_statements) : list ident :=
  match cases with
  | LSnil => []
  | LScons _ body rest => direct_callees_s body ++ direct_callees_ls rest
  end.

(** Unlike [direct_callees_s], this projection follows only [Ssequence]
    structure (and transparent labels).  Calls underneath a branch, switch, or
    loop are deliberately omitted.  A subsequence result over this list is
    still only a straight-line syntax receipt: it is not a Clight execution or
    a proof that an earlier return/goto cannot bypass the calls. *)
Fixpoint straightline_callees_s (s : statement) : list ident :=
  match s with
  | Scall _ (Evar id _) _ => [id]
  | Ssequence a b => straightline_callees_s a ++ straightline_callees_s b
  | Slabel _ body => straightline_callees_s body
  | _ => []
  end.

Fixpoint ident_subsequenceb (wanted found : list ident) : bool :=
  match wanted, found with
  | [], _ => true
  | _, [] => false
  | w :: ws, f :: fs =>
      if Pos.eqb w f
      then ident_subsequenceb ws fs
      else ident_subsequenceb wanted fs
  end.

Fixpoint ident_mem (needle : ident) (ids : list ident) : bool :=
  match ids with
  | [] => false
  | id :: rest => Pos.eqb needle id || ident_mem needle rest
  end.

Fixpoint expression_mentions_ident (needle : ident) (e : expr) : bool :=
  match e with
  | Evar id _ | Etempvar id _ => Pos.eqb id needle
  | Ederef inner _ | Eaddrof inner _ | Eunop _ inner _ | Ecast inner _ =>
      expression_mentions_ident needle inner
  | Efield inner field _ =>
      expression_mentions_ident needle inner || Pos.eqb field needle
  | Ebinop _ lhs rhs _ =>
      expression_mentions_ident needle lhs || expression_mentions_ident needle rhs
  | _ => false
  end.

Definition expression_list_mentions_ident
    (needle : ident) (args : list expr) : bool :=
  existsb (expression_mentions_ident needle) args.

(** A base-sensitive call/argument receipt.  This is useful for distinguishing
    [deallocate_object(&gFreeObjectList, ...)] from an unrelated occurrence of
    either identifier in the same function. *)
Fixpoint calls_ident_with_argument_ident_s
    (callee argument : ident) (s : statement) : bool :=
  match s with
  | Scall _ (Evar found _) args =>
      Pos.eqb found callee && expression_list_mentions_ident argument args
  | Ssequence a b | Sloop a b =>
      calls_ident_with_argument_ident_s callee argument a ||
      calls_ident_with_argument_ident_s callee argument b
  | Sifthenelse _ a b =>
      calls_ident_with_argument_ident_s callee argument a ||
      calls_ident_with_argument_ident_s callee argument b
  | Sswitch _ cases =>
      calls_ident_with_argument_ident_ls callee argument cases
  | Slabel _ body =>
      calls_ident_with_argument_ident_s callee argument body
  | _ => false
  end
with calls_ident_with_argument_ident_ls
    (callee argument : ident) (cases : labeled_statements) : bool :=
  match cases with
  | LSnil => false
  | LScons _ body rest =>
      calls_ident_with_argument_ident_s callee argument body ||
      calls_ident_with_argument_ident_ls callee argument rest
  end.

Fixpoint expression_mentions_int (needle : Z) (e : expr) : bool :=
  match e with
  | Econst_int value _ => Int.eq value (Int.repr needle)
  | Ederef inner _ | Eaddrof inner _ | Eunop _ inner _ | Ecast inner _
  | Efield inner _ _ => expression_mentions_int needle inner
  | Ebinop _ lhs rhs _ =>
      expression_mentions_int needle lhs || expression_mentions_int needle rhs
  | _ => false
  end.

Fixpoint statement_mentions_ident_s (needle : ident) (s : statement) : bool :=
  match s with
  | Sskip | Sbreak | Scontinue | Sreturn None | Sgoto _ => false
  | Sassign lhs rhs =>
      expression_mentions_ident needle lhs || expression_mentions_ident needle rhs
  | Sset _ rhs => expression_mentions_ident needle rhs
  | Scall _ fn args =>
      expression_mentions_ident needle fn ||
      existsb (expression_mentions_ident needle) args
  | Sbuiltin _ _ _ args => existsb (expression_mentions_ident needle) args
  | Ssequence a b | Sloop a b =>
      statement_mentions_ident_s needle a || statement_mentions_ident_s needle b
  | Sifthenelse cond a b =>
      expression_mentions_ident needle cond ||
      statement_mentions_ident_s needle a || statement_mentions_ident_s needle b
  | Sreturn (Some value) => expression_mentions_ident needle value
  | Sswitch value cases =>
      expression_mentions_ident needle value ||
      statement_mentions_ident_ls needle cases
  | Slabel _ body => statement_mentions_ident_s needle body
  end
with statement_mentions_ident_ls
    (needle : ident) (cases : labeled_statements) : bool :=
  match cases with
  | LSnil => false
  | LScons _ body rest =>
      statement_mentions_ident_s needle body ||
      statement_mentions_ident_ls needle rest
  end.

(** Recognize the specific control-flow shape used by Mario's graphical
    floor-null fallback. *)

Definition is_null_test_of_temp (guard_temp : ident)
    (condition : expr) : bool :=
  match condition with
  | Ebinop Oeq
      (Etempvar found_temp _)
      (Ecast (Econst_int zero _) _) _ =>
      Pos.eqb found_temp guard_temp && Int.eq zero Int.zero
  | Ebinop Oeq
      (Ecast (Econst_int zero _) _)
      (Etempvar found_temp _) _ =>
      Pos.eqb found_temp guard_temp && Int.eq zero Int.zero
  | _ => false
  end.

Definition is_graphics_copy_from_mario_object_s
    (state_temp mario_object_field header_field copy_callee graphics_field
      position_field : ident)
    (s : statement) : bool :=
  match s with
  | Ssequence
      (Sset object_temp
        (Efield
          (Ederef (Etempvar loaded_state_temp _) _)
          loaded_mario_object_field _))
      (Scall None (Evar found_callee _)
        [Efield
          (Ederef (Etempvar destination_state_temp _) _)
          destination_position_field _;
         Efield
          (Efield
            (Efield
              (Ederef (Etempvar source_object_temp _) _)
              source_header_field _)
            source_graphics_field _)
          source_position_field _]) =>
      Pos.eqb found_callee copy_callee &&
      Pos.eqb loaded_state_temp state_temp &&
      Pos.eqb loaded_mario_object_field mario_object_field &&
      Pos.eqb destination_state_temp state_temp &&
      Pos.eqb destination_position_field position_field &&
      Pos.eqb source_object_temp object_temp &&
      Pos.eqb source_header_field header_field &&
      Pos.eqb source_graphics_field graphics_field &&
      Pos.eqb source_position_field position_field
  | _ => false
  end.

Definition is_state_position_component_load
    (state_temp position_field : ident) (component : Z)
    (loaded : expr) : bool :=
  match loaded with
  | Ederef
      (Ebinop Oadd
        (Efield
          (Ederef (Etempvar found_state_temp _) _)
          found_position_field _)
        (Econst_int found_component _) _) _ =>
      Pos.eqb found_state_temp state_temp &&
      Pos.eqb found_position_field position_field &&
      Int.eq found_component (Int.repr component)
  | _ => false
  end.

Definition is_state_floor_address
    (state_temp floor_field : ident) (address : expr) : bool :=
  match address with
  | Eaddrof
      (Efield
        (Ederef (Etempvar found_state_temp _) _)
        found_floor_field _) _ =>
      Pos.eqb found_state_temp state_temp &&
      Pos.eqb found_floor_field floor_field
  | _ => false
  end.

Definition is_retry_from_exact_state_position_s
    (state_temp result_temp retry_callee position_field floor_field : ident)
    (s : statement) : bool :=
  match s with
  | Ssequence
      (Sset x_temp x_load)
      (Ssequence
        (Sset y_temp y_load)
        (Ssequence
          (Sset z_temp z_load)
          (Scall (Some found_result) (Evar found_callee _)
            [Etempvar x_arg _;
             Etempvar y_arg _;
             Etempvar z_arg _;
             floor_address]))) =>
      Pos.eqb found_result result_temp &&
      Pos.eqb found_callee retry_callee &&
      Pos.eqb x_arg x_temp &&
      Pos.eqb y_arg y_temp &&
      Pos.eqb z_arg z_temp &&
      is_state_position_component_load
        state_temp position_field 0 x_load &&
      is_state_position_component_load
        state_temp position_field 1 y_load &&
      is_state_position_component_load
        state_temp position_field 2 z_load &&
      is_state_floor_address state_temp floor_field floor_address
  | _ => false
  end.

Definition is_state_field_lvalue
    (state_temp field : ident) (destination : expr) : bool :=
  match destination with
  | Efield
      (Ederef (Etempvar found_state_temp _) _)
      found_field _ =>
      Pos.eqb found_state_temp state_temp &&
      Pos.eqb found_field field
  | _ => false
  end.

Definition is_retry_floor_height_store_s
    (state_temp retry_callee position_field floor_field
      floor_height_field : ident)
    (s : statement) : bool :=
  match s with
  | Ssequence before
      (Sassign destination (Etempvar result_temp _)) =>
      is_retry_from_exact_state_position_s
        state_temp result_temp retry_callee position_field floor_field before &&
      is_state_field_lvalue state_temp floor_height_field destination
  | _ => false
  end.

(** Match the exact linear true-branch shape emitted by [clightgen]: the
    Graphics-to-State copy is followed on the same execution path by the three
    State-position loads, retry call, and exact [m->floorHeight] store. *)
Definition is_exact_graphics_floor_retry_branch_s
    (state_temp mario_object_field header_field copy_callee retry_callee
      graphics_field position_field floor_field floor_height_field : ident)
    (branch : statement) : bool :=
  match branch with
  | Ssequence graphics_copy retry_and_store =>
      is_graphics_copy_from_mario_object_s
        state_temp mario_object_field header_field copy_callee graphics_field
        position_field graphics_copy &&
      is_retry_floor_height_store_s
        state_temp retry_callee position_field floor_field floor_height_field
        retry_and_store
  | _ => false
  end.

(** CompCert lowers the source guard to an immediate sequence: load
    [m->floor] into a temporary, then compare that same temporary with a null
    pointer.  In the true branch this recognizer checks:

    - [m->marioObj] flows into an object temporary;
    - [vec3f_copy] receives State [pos] as its destination and that object's
      [gfx.pos] as its source;
    - the retry [find_floor] mentions the same State [pos] and [floor], returns
      through a temporary, and that temporary is stored to the same State's
      [floorHeight]; and
    - the copy call precedes the retry call.

    Types are left to the generated Clight AST.
    This is still a decidable syntax/dataflow receipt, not a small-step memory
    execution. *)
Fixpoint contains_guarded_graphics_floor_retry_s
    (floor_field mario_object_field header_field copy_callee retry_callee
      graphics_field position_field floor_height_field : ident)
    (s : statement) : bool :=
  match s with
  | Ssequence first second =>
      (match first, second with
       | Sset guard_temp
           (Efield
             (Ederef (Etempvar state_temp _) _) found_floor_field _),
          Sifthenelse condition yes_branch _ =>
            Pos.eqb found_floor_field floor_field &&
            is_null_test_of_temp guard_temp condition &&
            is_exact_graphics_floor_retry_branch_s
              state_temp mario_object_field header_field copy_callee
              retry_callee graphics_field position_field floor_field
              floor_height_field yes_branch &&
            ident_subsequenceb [copy_callee; retry_callee]
              (direct_callees_s yes_branch)
       | _, _ => false
       end) ||
      contains_guarded_graphics_floor_retry_s
        floor_field mario_object_field header_field copy_callee retry_callee
        graphics_field position_field floor_height_field first ||
      contains_guarded_graphics_floor_retry_s
        floor_field mario_object_field header_field copy_callee retry_callee
        graphics_field position_field floor_height_field second
  | Sifthenelse _ yes_branch no_branch =>
      contains_guarded_graphics_floor_retry_s
        floor_field mario_object_field header_field copy_callee retry_callee
        graphics_field position_field floor_height_field yes_branch ||
      contains_guarded_graphics_floor_retry_s
        floor_field mario_object_field header_field copy_callee retry_callee
        graphics_field position_field floor_height_field no_branch
  | Sloop body increment =>
      contains_guarded_graphics_floor_retry_s
        floor_field mario_object_field header_field copy_callee retry_callee
        graphics_field position_field floor_height_field body ||
      contains_guarded_graphics_floor_retry_s
        floor_field mario_object_field header_field copy_callee retry_callee
        graphics_field position_field floor_height_field increment
  | Slabel _ body =>
      contains_guarded_graphics_floor_retry_s
        floor_field mario_object_field header_field copy_callee retry_callee
        graphics_field position_field floor_height_field body
  | _ => false
  end.

(** Recognize a generated [m->floor] non-null test whose false branch is the
    exact direct [level_trigger_warp(m, WARP_OP_DEATH)] call.  In the pinned
    function, source inspection and the separate graphical-retry receipt
    identify this as the final post-retry test; this recognizer deliberately
    checks the local guard/call relationship rather than uniqueness or global
    order. *)
Definition is_nonnull_test_of_temp
    (guard_temp : ident) (condition : expr) : bool :=
  match condition with
  | Ebinop Cop.One
      (Etempvar found_temp _)
      (Ecast (Econst_int zero _) _) _ =>
      Pos.eqb found_temp guard_temp && Int.eq zero Int.zero
  | Ebinop Cop.One
      (Ecast (Econst_int zero _) _)
      (Etempvar found_temp _) _ =>
      Pos.eqb found_temp guard_temp && Int.eq zero Int.zero
  | _ => false
  end.

Definition is_exact_call_with_temp_and_int_s
    (callee mario_temp : ident) (argument : Z)
    (s : statement) : bool :=
  match s with
  | Scall None (Evar found_callee _)
      ((Etempvar found_mario_temp _) ::
       (Econst_int found_argument _) :: nil) =>
      Pos.eqb found_callee callee &&
      Pos.eqb found_mario_temp mario_temp &&
      Int.eq found_argument (Int.repr argument)
  | _ => false
  end.

Fixpoint contains_guarded_floor_null_else_call_s
    (mario_temp floor_field callee : ident) (argument : Z)
    (s : statement) : bool :=
  match s with
  | Ssequence first second =>
      (match first, second with
        | Sset guard_temp
            (Efield
              (Ederef (Etempvar found_mario_temp _) _) found_floor_field _),
          Sifthenelse condition _ no_floor_branch =>
            Pos.eqb found_mario_temp mario_temp &&
            Pos.eqb found_floor_field floor_field &&
            is_nonnull_test_of_temp guard_temp condition &&
            is_exact_call_with_temp_and_int_s
              callee mario_temp argument no_floor_branch
        | _, _ => false
        end) ||
      contains_guarded_floor_null_else_call_s
        mario_temp floor_field callee argument first ||
      contains_guarded_floor_null_else_call_s
        mario_temp floor_field callee argument second
  | Sifthenelse _ yes_branch no_branch =>
      contains_guarded_floor_null_else_call_s
        mario_temp floor_field callee argument yes_branch ||
      contains_guarded_floor_null_else_call_s
        mario_temp floor_field callee argument no_branch
  | Sloop body increment =>
      contains_guarded_floor_null_else_call_s
        mario_temp floor_field callee argument body ||
      contains_guarded_floor_null_else_call_s
        mario_temp floor_field callee argument increment
  | Slabel _ body =>
      contains_guarded_floor_null_else_call_s
        mario_temp floor_field callee argument body
  | _ => false
  end.

(** [level_trigger_warp] is a first-writer latch: after a prefix with no direct
    assignment to [sDelayedWarpOp], the generated body loads that global,
    tests it against zero, and assigns the requested operation only in the
    true branch.  The exact recognizer below also requires the false branch to
    be [Sskip]. *)
Definition is_zero_test_of_temp
    (guard_temp : ident) (condition : expr) : bool :=
  match condition with
  | Ebinop Oeq
      (Etempvar found_temp _)
      (Econst_int zero _) _ =>
      Pos.eqb found_temp guard_temp && Int.eq zero Int.zero
  | Ebinop Oeq
      (Econst_int zero _)
      (Etempvar found_temp _) _ =>
      Pos.eqb found_temp guard_temp && Int.eq zero Int.zero
  | _ => false
  end.

Fixpoint assigns_ident_from_temp_s
    (target source : ident) (s : statement) : bool :=
  match s with
  | Sassign (Evar found_target _) (Etempvar found_source _) =>
      Pos.eqb found_target target && Pos.eqb found_source source
  | Ssequence first second | Sloop first second =>
      assigns_ident_from_temp_s target source first ||
      assigns_ident_from_temp_s target source second
  | Sifthenelse _ yes_branch no_branch =>
      assigns_ident_from_temp_s target source yes_branch ||
      assigns_ident_from_temp_s target source no_branch
  | Sswitch _ cases =>
      assigns_ident_from_temp_ls target source cases
  | Slabel _ body => assigns_ident_from_temp_s target source body
  | _ => false
  end
with assigns_ident_from_temp_ls
    (target source : ident) (cases : labeled_statements) : bool :=
  match cases with
  | LSnil => false
  | LScons _ body rest =>
      assigns_ident_from_temp_s target source body ||
      assigns_ident_from_temp_ls target source rest
  end.

Fixpoint statement_assigns_ident_s
    (target : ident) (s : statement) : bool :=
  match s with
  | Sassign (Evar found_target _) _ =>
      Pos.eqb found_target target
  | Ssequence first second | Sloop first second =>
      statement_assigns_ident_s target first ||
      statement_assigns_ident_s target second
  | Sifthenelse _ yes_branch no_branch =>
      statement_assigns_ident_s target yes_branch ||
      statement_assigns_ident_s target no_branch
  | Sswitch _ cases =>
      statement_assigns_ident_ls target cases
  | Slabel _ body => statement_assigns_ident_s target body
  | _ => false
  end
with statement_assigns_ident_ls
    (target : ident) (cases : labeled_statements) : bool :=
  match cases with
  | LSnil => false
  | LScons _ body rest =>
      statement_assigns_ident_s target body ||
      statement_assigns_ident_ls target rest
  end.

Definition is_guarded_first_writer_warp_latch_s
    (delayed_warp_ident requested_warp_temp : ident)
    (body : statement) : bool :=
  match body with
  | Ssequence prefix
      (Ssequence
        (Ssequence
          (Sset guard_temp (Evar found_delayed_warp_ident _))
          (Sifthenelse condition yes_branch Sskip))
        suffix) =>
      Pos.eqb found_delayed_warp_ident delayed_warp_ident &&
      is_zero_test_of_temp guard_temp condition &&
      assigns_ident_from_temp_s
        delayed_warp_ident requested_warp_temp yes_branch &&
      negb (statement_assigns_ident_s delayed_warp_ident prefix) &&
      negb (statement_assigns_ident_s delayed_warp_ident suffix)
  | _ => false
  end.

Fixpoint statement_mentions_int_s (needle : Z) (s : statement) : bool :=
  match s with
  | Sskip | Sbreak | Scontinue | Sreturn None | Sgoto _ => false
  | Sassign lhs rhs =>
      expression_mentions_int needle lhs || expression_mentions_int needle rhs
  | Sset _ rhs => expression_mentions_int needle rhs
  | Scall _ fn args =>
      expression_mentions_int needle fn ||
      existsb (expression_mentions_int needle) args
  | Sbuiltin _ _ _ args => existsb (expression_mentions_int needle) args
  | Ssequence a b | Sloop a b =>
      statement_mentions_int_s needle a || statement_mentions_int_s needle b
  | Sifthenelse cond a b =>
      expression_mentions_int needle cond ||
      statement_mentions_int_s needle a || statement_mentions_int_s needle b
  | Sreturn (Some value) => expression_mentions_int needle value
  | Sswitch value cases =>
      expression_mentions_int needle value || statement_mentions_int_ls needle cases
  | Slabel _ body => statement_mentions_int_s needle body
  end
with statement_mentions_int_ls
    (needle : Z) (cases : labeled_statements) : bool :=
  match cases with
  | LSnil => false
  | LScons _ body rest =>
      statement_mentions_int_s needle body || statement_mentions_int_ls needle rest
  end.

Fixpoint expression_mentions_float32_bits (bits : Z) (e : expr) : bool :=
  match e with
  | Econst_single value _ => Int.eq (Float32.to_bits value) (Int.repr bits)
  | Ederef inner _ | Eaddrof inner _ | Eunop _ inner _ | Ecast inner _ =>
      expression_mentions_float32_bits bits inner
  | Ebinop _ lhs rhs _ =>
      expression_mentions_float32_bits bits lhs ||
      expression_mentions_float32_bits bits rhs
  | Efield inner _ _ => expression_mentions_float32_bits bits inner
  | _ => false
  end.

Fixpoint expressions_mention_float32_bits
    (bits : Z) (args : list expr) : bool :=
  match args with
  | [] => false
  | arg :: rest =>
      expression_mentions_float32_bits bits arg ||
      expressions_mention_float32_bits bits rest
  end.

Fixpoint statement_mentions_float32_bits_s
    (bits : Z) (s : statement) : bool :=
  match s with
  | Sassign lhs rhs =>
      expression_mentions_float32_bits bits lhs ||
      expression_mentions_float32_bits bits rhs
  | Sset _ rhs => expression_mentions_float32_bits bits rhs
  | Scall _ fn args =>
      expression_mentions_float32_bits bits fn ||
      expressions_mention_float32_bits bits args
  | Ssequence a b | Sloop a b =>
      statement_mentions_float32_bits_s bits a ||
      statement_mentions_float32_bits_s bits b
  | Sifthenelse cond a b =>
      expression_mentions_float32_bits bits cond ||
      statement_mentions_float32_bits_s bits a ||
      statement_mentions_float32_bits_s bits b
  | Sreturn (Some value) => expression_mentions_float32_bits bits value
  | Sswitch value cases =>
      expression_mentions_float32_bits bits value ||
      statements_mention_float32_bits bits cases
  | Slabel _ body => statement_mentions_float32_bits_s bits body
  | _ => false
  end
with statements_mention_float32_bits
    (bits : Z) (cases : labeled_statements) : bool :=
  match cases with
  | LSnil => false
  | LScons _ body rest =>
      statement_mentions_float32_bits_s bits body ||
      statements_mention_float32_bits bits rest
  end.

Fixpoint calls_ident_with_float32_arg_s
    (callee : ident) (bits : Z) (s : statement) : bool :=
  match s with
  | Scall _ (Evar id _) args =>
      Pos.eqb id callee && expressions_mention_float32_bits bits args
  | Ssequence a b | Sloop a b =>
      calls_ident_with_float32_arg_s callee bits a ||
      calls_ident_with_float32_arg_s callee bits b
  | Sifthenelse _ a b =>
      calls_ident_with_float32_arg_s callee bits a ||
      calls_ident_with_float32_arg_s callee bits b
  | Sswitch _ cases =>
      calls_ident_with_float32_arg_ls callee bits cases
  | Slabel _ body => calls_ident_with_float32_arg_s callee bits body
  | _ => false
  end
with calls_ident_with_float32_arg_ls
    (callee : ident) (bits : Z) (cases : labeled_statements) : bool :=
  match cases with
  | LSnil => false
  | LScons _ body rest =>
      calls_ident_with_float32_arg_s callee bits body ||
      calls_ident_with_float32_arg_ls callee bits rest
  end.

Fixpoint expression_mentions_field (field : ident) (e : expr) : bool :=
  match e with
  | Ederef inner _ | Eaddrof inner _ | Eunop _ inner _ | Ecast inner _ =>
      expression_mentions_field field inner
  | Ebinop _ lhs rhs _ =>
      expression_mentions_field field lhs || expression_mentions_field field rhs
  | Efield inner found _ =>
      Pos.eqb found field || expression_mentions_field field inner
  | _ => false
  end.

Fixpoint assigns_through_field_s (field : ident) (s : statement) : bool :=
  match s with
  | Sassign lhs _ => expression_mentions_field field lhs
  | Ssequence a b | Sloop a b =>
      assigns_through_field_s field a || assigns_through_field_s field b
  | Sifthenelse _ a b =>
      assigns_through_field_s field a || assigns_through_field_s field b
  | Sswitch _ cases => assigns_through_field_ls field cases
  | Slabel _ body => assigns_through_field_s field body
  | _ => false
  end
with assigns_through_field_ls
    (field : ident) (cases : labeled_statements) : bool :=
  match cases with
  | LSnil => false
  | LScons _ body rest =>
      assigns_through_field_s field body || assigns_through_field_ls field rest
  end.

Fixpoint statement_contains_loop_s (s : statement) : bool :=
  match s with
  | Ssequence a b | Sifthenelse _ a b =>
      statement_contains_loop_s a || statement_contains_loop_s b
  | Sloop _ _ => true
  | Sswitch _ cases => statements_contain_loop cases
  | Slabel _ body => statement_contains_loop_s body
  | _ => false
  end
with statements_contain_loop (cases : labeled_statements) : bool :=
  match cases with
  | LSnil => false
  | LScons _ body rest =>
      statement_contains_loop_s body || statements_contain_loop rest
  end.

Definition rhs_has_pressed_operator_shape (rhs : expr) : bool :=
  match rhs with
  | Ebinop Oand _ (Ebinop Oxor _ _ _) _ => true
  | _ => false
  end.

Definition lhs_field_is (field : ident) (lhs : expr) : bool :=
  match lhs with
  | Efield _ found _ => Pos.eqb found field
  | _ => false
  end.

Fixpoint assigns_pressed_operator_shape_s (field : ident) (s : statement) : bool :=
  match s with
  | Sassign lhs rhs =>
      lhs_field_is field lhs && rhs_has_pressed_operator_shape rhs
  | Ssequence a b | Sloop a b =>
      assigns_pressed_operator_shape_s field a ||
      assigns_pressed_operator_shape_s field b
  | Sifthenelse _ a b =>
      assigns_pressed_operator_shape_s field a ||
      assigns_pressed_operator_shape_s field b
  | Sswitch _ cases => assigns_pressed_operator_shape_ls field cases
  | Slabel _ body => assigns_pressed_operator_shape_s field body
  | _ => false
  end
with assigns_pressed_operator_shape_ls
    (field : ident) (cases : labeled_statements) : bool :=
  match cases with
  | LSnil => false
  | LScons _ body rest =>
      assigns_pressed_operator_shape_s field body ||
      assigns_pressed_operator_shape_ls field rest
  end.

Fixpoint assigns_field_named_s (field : ident) (s : statement) : bool :=
  match s with
  | Sassign lhs _ => lhs_field_is field lhs
  | Ssequence a b | Sloop a b =>
      assigns_field_named_s field a || assigns_field_named_s field b
  | Sifthenelse _ a b =>
      assigns_field_named_s field a || assigns_field_named_s field b
  | Sswitch _ cases => assigns_field_named_ls field cases
  | Slabel _ body => assigns_field_named_s field body
  | _ => false
  end
with assigns_field_named_ls
    (field : ident) (cases : labeled_statements) : bool :=
  match cases with
  | LSnil => false
  | LScons _ body rest =>
      assigns_field_named_s field body || assigns_field_named_ls field rest
  end.

Definition rhs_is_int_constant (value : Z) (rhs : expr) : bool :=
  match rhs with
  | Econst_int found _ => Int.eq found (Int.repr value)
  | _ => false
  end.

(** Require the complete assignment shape [base.field := value], rather than
    merely observing the field name somewhere on an assignment's left side. *)
Fixpoint assigns_field_int_constant_s
    (field : ident) (value : Z) (s : statement) : bool :=
  match s with
  | Sassign lhs rhs =>
      lhs_field_is field lhs && rhs_is_int_constant value rhs
  | Ssequence a b | Sloop a b =>
      assigns_field_int_constant_s field value a ||
      assigns_field_int_constant_s field value b
  | Sifthenelse _ a b =>
      assigns_field_int_constant_s field value a ||
      assigns_field_int_constant_s field value b
  | Sswitch _ cases =>
      assigns_field_int_constant_ls field value cases
  | Slabel _ body => assigns_field_int_constant_s field value body
  | _ => false
  end
with assigns_field_int_constant_ls
    (field : ident) (value : Z) (cases : labeled_statements) : bool :=
  match cases with
  | LSnil => false
  | LScons _ body rest =>
      assigns_field_int_constant_s field value body ||
      assigns_field_int_constant_ls field value rest
  end.

(** Recognize a load of a named field from a dereferenced instance of one
    particular struct.  This distinguishes a [Surface.object] load from a
    coincidental occurrence of the identifier [_object] elsewhere. *)
Definition rhs_is_struct_field_read
    (struct_tag field : ident) (rhs : expr) : bool :=
  match rhs with
  | Efield (Ederef _ (Tstruct found_struct _)) found_field _ =>
      Pos.eqb found_struct struct_tag && Pos.eqb found_field field
  | _ => false
  end.

Fixpoint sets_temp_from_struct_field_s
    (struct_tag field : ident) (s : statement) : bool :=
  match s with
  | Sset _ rhs => rhs_is_struct_field_read struct_tag field rhs
  | Ssequence a b | Sloop a b =>
      sets_temp_from_struct_field_s struct_tag field a ||
      sets_temp_from_struct_field_s struct_tag field b
  | Sifthenelse _ a b =>
      sets_temp_from_struct_field_s struct_tag field a ||
      sets_temp_from_struct_field_s struct_tag field b
  | Sswitch _ cases =>
      sets_temp_from_struct_field_ls struct_tag field cases
  | Slabel _ body => sets_temp_from_struct_field_s struct_tag field body
  | _ => false
  end
with sets_temp_from_struct_field_ls
    (struct_tag field : ident) (cases : labeled_statements) : bool :=
  match cases with
  | LSnil => false
  | LScons _ body rest =>
      sets_temp_from_struct_field_s struct_tag field body ||
      sets_temp_from_struct_field_ls struct_tag field rest
  end.

Definition lhs_global_is (global : ident) (lhs : expr) : bool :=
  match lhs with
  | Evar found _ => Pos.eqb found global
  | _ => false
  end.

Fixpoint assigns_global_ident_s (global : ident) (s : statement) : bool :=
  match s with
  | Sassign lhs _ => lhs_global_is global lhs
  | Ssequence a b | Sloop a b =>
      assigns_global_ident_s global a || assigns_global_ident_s global b
  | Sifthenelse _ a b =>
      assigns_global_ident_s global a || assigns_global_ident_s global b
  | Sswitch _ cases => assigns_global_ident_ls global cases
  | Slabel _ body => assigns_global_ident_s global body
  | _ => false
  end
with assigns_global_ident_ls
    (global : ident) (cases : labeled_statements) : bool :=
  match cases with
  | LSnil => false
  | LScons _ body rest =>
      assigns_global_ident_s global body || assigns_global_ident_ls global rest
  end.

(* Array-field accessors emitted by clightgen for expressions such as
   [object->rawData.asF32[6]] and [marioState->pos[0]].  These checkers were
   useful in an archived spawning-displacement investigation; they are
   redefined here so the current project checks its own generated ASTs rather
   than importing an old translation. *)
Fixpoint expression_const_int_z (e : expr) : option Z :=
  match e with
  | Econst_int found _ => Some (Int.signed found)
  | Ecast inner _ => expression_const_int_z inner
  | Ebinop Oadd lhs rhs _ =>
      match expression_const_int_z lhs, expression_const_int_z rhs with
      | Some lhs_value, Some rhs_value => Some (lhs_value + rhs_value)%Z
      | _, _ => None
      end
  | _ => None
  end.

Definition expression_is_array_slot
    (array_field : ident) (index : Z) (e : expr) : bool :=
  match e with
  | Ederef (Ebinop Oadd (Efield _ found_field _) offset _) _ =>
      Pos.eqb found_field array_field &&
      match expression_const_int_z offset with
      | Some found_index => Z.eqb found_index index
      | None => false
      end
  | _ => false
  end.

Fixpoint expression_mentions_array_slot
    (array_field : ident) (index : Z) (e : expr) : bool :=
  expression_is_array_slot array_field index e ||
  match e with
  | Ederef inner _ | Eaddrof inner _ | Eunop _ inner _ | Ecast inner _ =>
      expression_mentions_array_slot array_field index inner
  | Efield inner _ _ =>
      expression_mentions_array_slot array_field index inner
  | Ebinop _ lhs rhs _ =>
      expression_mentions_array_slot array_field index lhs ||
      expression_mentions_array_slot array_field index rhs
  | _ => false
  end.

Fixpoint statement_mentions_array_slot_s
    (array_field : ident) (index : Z) (s : statement) : bool :=
  match s with
  | Sskip | Sbreak | Scontinue | Sreturn None | Sgoto _ => false
  | Sassign lhs rhs =>
      expression_mentions_array_slot array_field index lhs ||
      expression_mentions_array_slot array_field index rhs
  | Sset _ rhs => expression_mentions_array_slot array_field index rhs
  | Scall _ fn args =>
      expression_mentions_array_slot array_field index fn ||
      existsb (expression_mentions_array_slot array_field index) args
  | Sbuiltin _ _ _ args =>
      existsb (expression_mentions_array_slot array_field index) args
  | Ssequence a b | Sloop a b =>
      statement_mentions_array_slot_s array_field index a ||
      statement_mentions_array_slot_s array_field index b
  | Sifthenelse cond a b =>
      expression_mentions_array_slot array_field index cond ||
      statement_mentions_array_slot_s array_field index a ||
      statement_mentions_array_slot_s array_field index b
  | Sreturn (Some value) =>
      expression_mentions_array_slot array_field index value
  | Sswitch value cases =>
      expression_mentions_array_slot array_field index value ||
      statement_mentions_array_slot_ls array_field index cases
  | Slabel _ body =>
      statement_mentions_array_slot_s array_field index body
  end
with statement_mentions_array_slot_ls
    (array_field : ident) (index : Z) (cases : labeled_statements) : bool :=
  match cases with
  | LSnil => false
  | LScons _ body rest =>
      statement_mentions_array_slot_s array_field index body ||
      statement_mentions_array_slot_ls array_field index rest
  end.

Fixpoint assigns_array_slot_s
    (array_field : ident) (index : Z) (s : statement) : bool :=
  match s with
  | Sassign lhs _ => expression_is_array_slot array_field index lhs
  | Ssequence a b | Sloop a b =>
      assigns_array_slot_s array_field index a ||
      assigns_array_slot_s array_field index b
  | Sifthenelse _ a b =>
      assigns_array_slot_s array_field index a ||
      assigns_array_slot_s array_field index b
  | Sswitch _ cases => assigns_array_slot_ls array_field index cases
  | Slabel _ body => assigns_array_slot_s array_field index body
  | _ => false
  end
with assigns_array_slot_ls
    (array_field : ident) (index : Z) (cases : labeled_statements) : bool :=
  match cases with
  | LSnil => false
  | LScons _ body rest =>
      assigns_array_slot_s array_field index body ||
      assigns_array_slot_ls array_field index rest
  end.

(* [find_floor] is translated with a nested cast from binary32 to signed
   16-bit TerrainData.  This deliberately narrow recognizer avoids pretending
   that arbitrary out-of-range ISO C casts have already been semantically
   refined to the target MIPS instruction. *)
Definition type_is_s16 (ty : type) : bool :=
  match ty with
  | Tint I16 Signed _ => true
  | _ => false
  end.

Definition type_is_float32 (ty : type) : bool :=
  match ty with
  | Tfloat F32 _ => true
  | _ => false
  end.

Definition rhs_is_float_temp_cast_to_s16 (source : ident) (rhs : expr) : bool :=
  match rhs with
  | Ecast (Ecast (Etempvar found source_type) inner_type) outer_type =>
      Pos.eqb found source &&
      type_is_float32 source_type &&
      type_is_s16 inner_type &&
      type_is_s16 outer_type
  | _ => false
  end.

Fixpoint sets_temp_from_float_cast_to_s16_s
    (destination source : ident) (s : statement) : bool :=
  match s with
  | Sset found rhs =>
      Pos.eqb found destination && rhs_is_float_temp_cast_to_s16 source rhs
  | Ssequence a b | Sloop a b =>
      sets_temp_from_float_cast_to_s16_s destination source a ||
      sets_temp_from_float_cast_to_s16_s destination source b
  | Sifthenelse _ a b =>
      sets_temp_from_float_cast_to_s16_s destination source a ||
      sets_temp_from_float_cast_to_s16_s destination source b
  | Sswitch _ cases =>
      sets_temp_from_float_cast_to_s16_ls destination source cases
  | Slabel _ body =>
      sets_temp_from_float_cast_to_s16_s destination source body
  | _ => false
  end
with sets_temp_from_float_cast_to_s16_ls
    (destination source : ident) (cases : labeled_statements) : bool :=
  match cases with
  | LSnil => false
  | LScons _ body rest =>
      sets_temp_from_float_cast_to_s16_s destination source body ||
      sets_temp_from_float_cast_to_s16_ls destination source rest
  end.

Definition initializer_mentions_addrof (needle : ident) (datum : init_data) : bool :=
  match datum with
  | Init_addrof found _ => Pos.eqb found needle
  | _ => false
  end.

Definition initializer_list_mentions_addrof
    (needle : ident) (values : list init_data) : bool :=
  existsb (initializer_mentions_addrof needle) values.

Fixpoint initializer_addrof_idents (values : list init_data) : list ident :=
  match values with
  | [] => []
  | Init_addrof found _ :: rest =>
      found :: initializer_addrof_idents rest
  | _ :: rest => initializer_addrof_idents rest
  end.

(** Check address-initializer order without pretending that a behavior-script
    interpreter has executed the commands represented by the array. *)
Definition initializer_addrof_subsequenceb
    (wanted : list ident) (values : list init_data) : bool :=
  ident_subsequenceb wanted (initializer_addrof_idents values).

Fixpoint init_int16_values (values : list init_data) : list Z :=
  match values with
  | [] => []
  | Init_int16 value :: rest => Int.signed value :: init_int16_values rest
  | _ :: rest => init_int16_values rest
  end.

Fixpoint chunks5 (values : list Z) : list (list Z) :=
  match values with
  | a :: b :: c :: d :: e :: rest => [a; b; c; d; e] :: chunks5 rest
  | _ => []
  end.

Definition record_starts_with (tag : Z) (record : list Z) : bool :=
  match record with
  | found :: _ => Z.eqb found tag
  | [] => false
  end.

Definition records_with_tag (tag : Z) (values : list init_data) : list (list Z) :=
  filter (record_starts_with tag) (chunks5 (init_int16_values values)).
