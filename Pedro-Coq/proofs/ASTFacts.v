From Coq Require Import Bool List PArith.BinPos ZArith.
From compcert Require Import AST Clight Cop Ctypes Floats Integers.

Import ListNotations.

Fixpoint calls_ident_s (callee : ident) (s : statement) : bool :=
  match s with
  | Scall _ (Evar id _) _ => Pos.eqb id callee
  | Ssequence a b | Sloop a b =>
      calls_ident_s callee a || calls_ident_s callee b
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

Fixpoint direct_callees_s (s : statement) : list ident :=
  match s with
  | Scall _ (Evar id _) _ => [id]
  | Ssequence a b | Sloop a b => direct_callees_s a ++ direct_callees_s b
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

Fixpoint expression_mentions_int (needle : Z) (e : expr) : bool :=
  match e with
  | Econst_int value _ => Int.eq value (Int.repr needle)
  | Ederef inner _ | Eaddrof inner _ | Eunop _ inner _ | Ecast inner _
  | Efield inner _ _ => expression_mentions_int needle inner
  | Ebinop _ lhs rhs _ =>
      expression_mentions_int needle lhs || expression_mentions_int needle rhs
  | _ => false
  end.

Fixpoint expression_mentions_float32_bits (bits : Z) (e : expr) : bool :=
  match e with
  | Econst_single value _ => Int.eq (Float32.to_bits value) (Int.repr bits)
  | Ederef inner _ | Eaddrof inner _ | Eunop _ inner _ | Ecast inner _
  | Efield inner _ _ => expression_mentions_float32_bits bits inner
  | Ebinop _ lhs rhs _ =>
      expression_mentions_float32_bits bits lhs ||
      expression_mentions_float32_bits bits rhs
  | _ => false
  end.

Definition expressions_mention_ident (needle : ident) (args : list expr) : bool :=
  existsb (expression_mentions_ident needle) args.

Definition expressions_mention_int (needle : Z) (args : list expr) : bool :=
  existsb (expression_mentions_int needle) args.

Definition expressions_mention_float32_bits
    (bits : Z) (args : list expr) : bool :=
  existsb (expression_mentions_float32_bits bits) args.

Fixpoint statement_mentions_ident_s (needle : ident) (s : statement) : bool :=
  match s with
  | Sskip | Sbreak | Scontinue | Sreturn None | Sgoto _ => false
  | Sassign lhs rhs =>
      expression_mentions_ident needle lhs || expression_mentions_ident needle rhs
  | Sset _ rhs => expression_mentions_ident needle rhs
  | Scall _ fn args =>
      expression_mentions_ident needle fn || expressions_mention_ident needle args
  | Sbuiltin _ _ _ args => expressions_mention_ident needle args
  | Ssequence a b | Sloop a b =>
      statement_mentions_ident_s needle a || statement_mentions_ident_s needle b
  | Sifthenelse condition a b =>
      expression_mentions_ident needle condition ||
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

Fixpoint statement_mentions_int_s (needle : Z) (s : statement) : bool :=
  match s with
  | Sskip | Sbreak | Scontinue | Sreturn None | Sgoto _ => false
  | Sassign lhs rhs =>
      expression_mentions_int needle lhs || expression_mentions_int needle rhs
  | Sset _ rhs => expression_mentions_int needle rhs
  | Scall _ fn args =>
      expression_mentions_int needle fn || expressions_mention_int needle args
  | Sbuiltin _ _ _ args => expressions_mention_int needle args
  | Ssequence a b | Sloop a b =>
      statement_mentions_int_s needle a || statement_mentions_int_s needle b
  | Sifthenelse condition a b =>
      expression_mentions_int needle condition ||
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

Fixpoint statement_mentions_float32_bits_s
    (bits : Z) (s : statement) : bool :=
  match s with
  | Sskip | Sbreak | Scontinue | Sreturn None | Sgoto _ => false
  | Sassign lhs rhs =>
      expression_mentions_float32_bits bits lhs ||
      expression_mentions_float32_bits bits rhs
  | Sset _ rhs => expression_mentions_float32_bits bits rhs
  | Scall _ fn args =>
      expression_mentions_float32_bits bits fn ||
      expressions_mention_float32_bits bits args
  | Sbuiltin _ _ _ args => expressions_mention_float32_bits bits args
  | Ssequence a b | Sloop a b =>
      statement_mentions_float32_bits_s bits a ||
      statement_mentions_float32_bits_s bits b
  | Sifthenelse condition a b =>
      expression_mentions_float32_bits bits condition ||
      statement_mentions_float32_bits_s bits a ||
      statement_mentions_float32_bits_s bits b
  | Sreturn (Some value) => expression_mentions_float32_bits bits value
  | Sswitch value cases =>
      expression_mentions_float32_bits bits value ||
      statement_mentions_float32_bits_ls bits cases
  | Slabel _ body => statement_mentions_float32_bits_s bits body
  end
with statement_mentions_float32_bits_ls
    (bits : Z) (cases : labeled_statements) : bool :=
  match cases with
  | LSnil => false
  | LScons _ body rest =>
      statement_mentions_float32_bits_s bits body ||
      statement_mentions_float32_bits_ls bits rest
  end.

Definition optional_label_eqb
    (wanted found : option Z) : bool :=
  match wanted, found with
  | Some wanted_value, Some found_value => Z.eqb wanted_value found_value
  | None, None => true
  | _, _ => false
  end.

Fixpoint labeled_case_has_float32_bits
    (wanted_label : option Z) (bits : Z)
    (cases : labeled_statements) : bool :=
  match cases with
  | LSnil => false
  | LScons found_label body rest =>
      (optional_label_eqb wanted_label found_label &&
       statement_mentions_float32_bits_s bits body) ||
      labeled_case_has_float32_bits wanted_label bits rest
  end.

(** Locate a particular labeled arm of a normalized [Sswitch] and check the
    float constant used by that arm. [None] denotes the C default arm. *)
Fixpoint switch_has_case_float32_bits_s
    (wanted_label : option Z) (bits : Z) (s : statement) : bool :=
  match s with
  | Ssequence a b | Sloop a b =>
      switch_has_case_float32_bits_s wanted_label bits a ||
      switch_has_case_float32_bits_s wanted_label bits b
  | Sifthenelse _ a b =>
      switch_has_case_float32_bits_s wanted_label bits a ||
      switch_has_case_float32_bits_s wanted_label bits b
  | Sswitch _ cases =>
      labeled_case_has_float32_bits wanted_label bits cases ||
      switch_has_case_float32_bits_ls wanted_label bits cases
  | Slabel _ body => switch_has_case_float32_bits_s wanted_label bits body
  | _ => false
  end
with switch_has_case_float32_bits_ls
    (wanted_label : option Z) (bits : Z)
    (cases : labeled_statements) : bool :=
  match cases with
  | LSnil => false
  | LScons _ body rest =>
      switch_has_case_float32_bits_s wanted_label bits body ||
      switch_has_case_float32_bits_ls wanted_label bits rest
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
  | Sswitch _ cases => calls_ident_with_float32_arg_ls callee bits cases
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

(** Couple a normalized structure-field load, a [>=] binary32 threshold, and
    the call made by the true arm. *)
Fixpoint contains_field_ge_float_call_s
    (source_field : ident) (threshold_bits : Z)
    (callee : ident) (argument_bits : Z) (s : statement) : bool :=
  match s with
  | Ssequence
      (Sset loaded (Efield _ found_source _))
      (Sifthenelse
        (Ebinop Oge (Etempvar tested _) (Econst_single threshold _) _)
        yes_branch no_branch) =>
      (Pos.eqb found_source source_field && Pos.eqb loaded tested &&
       Int.eq (Float32.to_bits threshold) (Int.repr threshold_bits) &&
       calls_ident_with_float32_arg_s callee argument_bits yes_branch) ||
      contains_field_ge_float_call_s source_field threshold_bits
        callee argument_bits yes_branch ||
      contains_field_ge_float_call_s source_field threshold_bits
        callee argument_bits no_branch
  | Ssequence a b | Sloop a b =>
      contains_field_ge_float_call_s source_field threshold_bits
        callee argument_bits a ||
      contains_field_ge_float_call_s source_field threshold_bits
        callee argument_bits b
  | Sifthenelse _ a b =>
      contains_field_ge_float_call_s source_field threshold_bits
        callee argument_bits a ||
      contains_field_ge_float_call_s source_field threshold_bits
        callee argument_bits b
  | Sswitch _ cases =>
      contains_field_ge_float_call_ls source_field threshold_bits
        callee argument_bits cases
  | Slabel _ body =>
      contains_field_ge_float_call_s source_field threshold_bits
        callee argument_bits body
  | _ => false
  end
with contains_field_ge_float_call_ls
    (source_field : ident) (threshold_bits : Z)
    (callee : ident) (argument_bits : Z)
    (cases : labeled_statements) : bool :=
  match cases with
  | LSnil => false
  | LScons _ body rest =>
      contains_field_ge_float_call_s source_field threshold_bits
        callee argument_bits body ||
      contains_field_ge_float_call_ls source_field threshold_bits
        callee argument_bits rest
  end.

Definition lhs_field_is (field : ident) (lhs : expr) : bool :=
  match lhs with
  | Efield _ found _ => Pos.eqb found field
  | _ => false
  end.

Fixpoint assigns_field_s (field : ident) (s : statement) : bool :=
  match s with
  | Sassign lhs _ => lhs_field_is field lhs
  | Ssequence a b | Sloop a b => assigns_field_s field a || assigns_field_s field b
  | Sifthenelse _ a b => assigns_field_s field a || assigns_field_s field b
  | Sswitch _ cases => assigns_field_ls field cases
  | Slabel _ body => assigns_field_s field body
  | _ => false
  end
with assigns_field_ls (field : ident) (cases : labeled_statements) : bool :=
  match cases with
  | LSnil => false
  | LScons _ body rest => assigns_field_s field body || assigns_field_ls field rest
  end.

Definition array_lhs_field_index_is
    (field : ident) (index : Z) (lhs : expr) : bool :=
  match lhs with
  | Ederef
      (Ebinop Oadd (Efield _ found_field _) (Econst_int found_index _) _) _ =>
      Pos.eqb found_field field && Int.eq found_index (Int.repr index)
  | _ => false
  end.

Fixpoint assigns_array_field_index_s
    (field : ident) (index : Z) (s : statement) : bool :=
  match s with
  | Sassign lhs _ => array_lhs_field_index_is field index lhs
  | Ssequence a b | Sloop a b =>
      assigns_array_field_index_s field index a ||
      assigns_array_field_index_s field index b
  | Sifthenelse _ a b =>
      assigns_array_field_index_s field index a ||
      assigns_array_field_index_s field index b
  | Sswitch _ cases => assigns_array_field_index_ls field index cases
  | Slabel _ body => assigns_array_field_index_s field index body
  | _ => false
  end
with assigns_array_field_index_ls
    (field : ident) (index : Z) (cases : labeled_statements) : bool :=
  match cases with
  | LSnil => false
  | LScons _ body rest =>
      assigns_array_field_index_s field index body ||
      assigns_array_field_index_ls field index rest
  end.

Fixpoint returns_int_s (value : Z) (s : statement) : bool :=
  match s with
  | Sreturn (Some (Econst_int found _)) => Int.eq found (Int.repr value)
  | Ssequence a b | Sloop a b => returns_int_s value a || returns_int_s value b
  | Sifthenelse _ a b => returns_int_s value a || returns_int_s value b
  | Sswitch _ cases => returns_int_ls value cases
  | Slabel _ body => returns_int_s value body
  | _ => false
  end
with returns_int_ls (value : Z) (cases : labeled_statements) : bool :=
  match cases with
  | LSnil => false
  | LScons _ body rest => returns_int_s value body || returns_int_ls value rest
  end.

Definition is_floor_height_outer_condition
    (loaded_y floor_height : ident) (condition : expr) : bool :=
  match condition with
  | Ebinop Ole (Etempvar found_y _) (Etempvar found_floor _) _ =>
      Pos.eqb found_y loaded_y && Pos.eqb found_floor floor_height
  | _ => false
  end.

Definition assigns_array_field_index_from_temp
    (field : ident) (index : Z) (source : ident) (s : statement) : bool :=
  match s with
  | Sassign lhs (Etempvar found_source _) =>
      array_lhs_field_index_is field index lhs &&
      Pos.eqb found_source source
  | _ => false
  end.

Definition is_gap_gt_160_condition
    (ceil_height floor_height : ident) (condition : expr) : bool :=
  match condition with
  | Ebinop Ogt
      (Ebinop Osub (Etempvar found_ceil _) (Etempvar found_floor _) _)
      (Econst_single threshold _) _ =>
      Pos.eqb found_ceil ceil_height &&
      Pos.eqb found_floor floor_height &&
      Int.eq (Float32.to_bits threshold) (Int.repr 1126170624)
  | _ => false
  end.

(** Exact local control-flow receipt for the pinned Pedro branch. It couples
    the outer floor contact, inner gap test, guarded reference/horizontal
    writes, and unconditional vertical write plus landed return. It is still a
    syntax theorem, not a Clight execution theorem. *)
Fixpoint contains_pedro_landing_branch_s
    (next_pos pos floor floor_height ceil_height : ident)
    (s : statement) : bool :=
  match s with
  | Ssequence
      (Sset loaded_y
        (Ederef
          (Ebinop Oadd (Evar found_next_pos _)
            (Econst_int found_index _) _) _))
      (Sifthenelse outer_condition
        (Ssequence
          (Sifthenelse gap_condition guarded_updates Sskip)
          (Ssequence vertical_write landed_return))
        Sskip) =>
      (Pos.eqb found_next_pos next_pos &&
       Int.eq found_index (Int.repr 1) &&
       is_floor_height_outer_condition loaded_y floor_height outer_condition &&
       is_gap_gt_160_condition ceil_height floor_height gap_condition &&
       assigns_array_field_index_s pos 0 guarded_updates &&
       assigns_array_field_index_s pos 2 guarded_updates &&
       assigns_field_s floor guarded_updates &&
       assigns_field_s floor_height guarded_updates &&
       assigns_array_field_index_from_temp
         pos 1 floor_height vertical_write &&
       returns_int_s 1 landed_return) ||
      contains_pedro_landing_branch_s next_pos pos floor floor_height ceil_height
        guarded_updates ||
      contains_pedro_landing_branch_s next_pos pos floor floor_height ceil_height
        vertical_write ||
      contains_pedro_landing_branch_s next_pos pos floor floor_height ceil_height
        landed_return
  | Ssequence a b | Sloop a b =>
      contains_pedro_landing_branch_s next_pos pos floor floor_height ceil_height a ||
      contains_pedro_landing_branch_s next_pos pos floor floor_height ceil_height b
  | Sifthenelse _ a b =>
      contains_pedro_landing_branch_s next_pos pos floor floor_height ceil_height a ||
      contains_pedro_landing_branch_s next_pos pos floor floor_height ceil_height b
  | Sswitch _ cases =>
      contains_pedro_landing_branch_ls
        next_pos pos floor floor_height ceil_height cases
  | Slabel _ body =>
      contains_pedro_landing_branch_s
        next_pos pos floor floor_height ceil_height body
  | _ => false
  end
with contains_pedro_landing_branch_ls
    (next_pos pos floor floor_height ceil_height : ident)
    (cases : labeled_statements) : bool :=
  match cases with
  | LSnil => false
  | LScons _ body rest =>
      contains_pedro_landing_branch_s
        next_pos pos floor floor_height ceil_height body ||
      contains_pedro_landing_branch_ls
        next_pos pos floor floor_height ceil_height rest
  end.

Definition is_temp_bit_test
    (temporary : ident) (bit : Z) (condition : expr) : bool :=
  match condition with
  | Ebinop Oand (Etempvar found _) (Econst_int mask _) _
  | Ebinop Oand (Econst_int mask _) (Etempvar found _) _ =>
      Pos.eqb found temporary && Int.eq mask (Int.repr bit)
  | _ => false
  end.

(** Couple the input-field load to the normalized analog/neutral landing
    branches and their exact float arguments. *)
Fixpoint contains_landing_input_split_s
    (input_field : ident) (input_bit : Z)
    (analog_callee : ident) (analog_bits : Z)
    (neutral_source_field neutral_callee : ident)
    (neutral_bits threshold_bits : Z)
    (s : statement) : bool :=
  match s with
  | Ssequence
      (Sset loaded (Efield _ found_input _))
      (Sifthenelse condition analog_branch neutral_branch) =>
      (Pos.eqb found_input input_field &&
       is_temp_bit_test loaded input_bit condition &&
       calls_ident_with_float32_arg_s analog_callee analog_bits analog_branch &&
       contains_field_ge_float_call_s
         neutral_source_field threshold_bits neutral_callee neutral_bits
         neutral_branch) ||
      contains_landing_input_split_s input_field input_bit
        analog_callee analog_bits neutral_source_field neutral_callee
        neutral_bits threshold_bits
        analog_branch ||
      contains_landing_input_split_s input_field input_bit
        analog_callee analog_bits neutral_source_field neutral_callee
        neutral_bits threshold_bits
        neutral_branch
  | Ssequence a b | Sloop a b =>
      contains_landing_input_split_s input_field input_bit
        analog_callee analog_bits neutral_source_field neutral_callee
        neutral_bits threshold_bits a ||
      contains_landing_input_split_s input_field input_bit
        analog_callee analog_bits neutral_source_field neutral_callee
        neutral_bits threshold_bits b
  | Sifthenelse _ a b =>
      contains_landing_input_split_s input_field input_bit
        analog_callee analog_bits neutral_source_field neutral_callee
        neutral_bits threshold_bits a ||
      contains_landing_input_split_s input_field input_bit
        analog_callee analog_bits neutral_source_field neutral_callee
        neutral_bits threshold_bits b
  | Sswitch _ cases =>
      contains_landing_input_split_ls input_field input_bit
        analog_callee analog_bits neutral_source_field neutral_callee
        neutral_bits threshold_bits cases
  | Slabel _ body =>
      contains_landing_input_split_s input_field input_bit
        analog_callee analog_bits neutral_source_field neutral_callee
        neutral_bits threshold_bits body
  | _ => false
  end
with contains_landing_input_split_ls
    (input_field : ident) (input_bit : Z)
    (analog_callee : ident) (analog_bits : Z)
    (neutral_source_field neutral_callee : ident)
    (neutral_bits threshold_bits : Z)
    (cases : labeled_statements) : bool :=
  match cases with
  | LSnil => false
  | LScons _ body rest =>
      contains_landing_input_split_s input_field input_bit
        analog_callee analog_bits neutral_source_field neutral_callee
        neutral_bits threshold_bits body ||
      contains_landing_input_split_ls input_field input_bit
        analog_callee analog_bits neutral_source_field neutral_callee
        neutral_bits threshold_bits rest
  end.

Definition is_field_or_shift_bit_assignment_s
    (field : ident) (bit : Z) (s : statement) : bool :=
  match s with
  | Sassign lhs
      (Ebinop Oor _
        (Ebinop Oshl (Econst_int one _) (Econst_int found_bit _) _) _) =>
      lhs_field_is field lhs && Int.eq one Int.one &&
      Int.eq found_bit (Int.repr bit)
  | _ => false
  end.

Fixpoint assigns_field_or_shift_bit_s
    (field : ident) (bit : Z) (s : statement) : bool :=
  is_field_or_shift_bit_assignment_s field bit s ||
  match s with
  | Ssequence a b | Sloop a b =>
      assigns_field_or_shift_bit_s field bit a ||
      assigns_field_or_shift_bit_s field bit b
  | Sifthenelse _ a b =>
      assigns_field_or_shift_bit_s field bit a ||
      assigns_field_or_shift_bit_s field bit b
  | Sswitch _ cases => assigns_field_or_shift_bit_ls field bit cases
  | Slabel _ body => assigns_field_or_shift_bit_s field bit body
  | _ => false
  end
with assigns_field_or_shift_bit_ls
    (field : ident) (bit : Z) (cases : labeled_statements) : bool :=
  match cases with
  | LSnil => false
  | LScons _ body rest =>
      assigns_field_or_shift_bit_s field bit body ||
      assigns_field_or_shift_bit_ls field bit rest
  end.

(** Couple the normalized forward-velocity load, strict threshold, and dust
    bit write. *)
Fixpoint contains_field_gt_float_or_bit_s
    (source_field target_field : ident) (threshold_bits bit : Z)
    (s : statement) : bool :=
  match s with
  | Ssequence
      (Sset loaded (Efield _ found_source _))
      (Sifthenelse
        (Ebinop Ogt (Etempvar tested _) (Econst_single threshold _) _)
        yes_branch _) =>
      (Pos.eqb found_source source_field && Pos.eqb loaded tested &&
       Int.eq (Float32.to_bits threshold) (Int.repr threshold_bits) &&
       assigns_field_or_shift_bit_s target_field bit yes_branch) ||
      contains_field_gt_float_or_bit_s source_field target_field
        threshold_bits bit yes_branch
  | Ssequence a b | Sloop a b =>
      contains_field_gt_float_or_bit_s source_field target_field
        threshold_bits bit a ||
      contains_field_gt_float_or_bit_s source_field target_field
        threshold_bits bit b
  | Sifthenelse _ a b =>
      contains_field_gt_float_or_bit_s source_field target_field
        threshold_bits bit a ||
      contains_field_gt_float_or_bit_s source_field target_field
        threshold_bits bit b
  | Sswitch _ cases =>
      contains_field_gt_float_or_bit_ls source_field target_field
        threshold_bits bit cases
  | Slabel _ body =>
      contains_field_gt_float_or_bit_s source_field target_field
        threshold_bits bit body
  | _ => false
  end
with contains_field_gt_float_or_bit_ls
    (source_field target_field : ident) (threshold_bits bit : Z)
    (cases : labeled_statements) : bool :=
  match cases with
  | LSnil => false
  | LScons _ body rest =>
      contains_field_gt_float_or_bit_s source_field target_field
        threshold_bits bit body ||
      contains_field_gt_float_or_bit_ls source_field target_field
        threshold_bits bit rest
  end.

(** Check that a direct call occurs in the left side of a sequence whose right
    side contains the coupled strict-threshold/particle-bit gate. *)
Fixpoint call_precedes_field_gt_float_or_bit_s
    (callee source_field target_field : ident)
    (threshold_bits bit : Z) (s : statement) : bool :=
  match s with
  | Ssequence a b =>
      (calls_ident_s callee a &&
       contains_field_gt_float_or_bit_s
         source_field target_field threshold_bits bit b) ||
      call_precedes_field_gt_float_or_bit_s
        callee source_field target_field threshold_bits bit a ||
      call_precedes_field_gt_float_or_bit_s
        callee source_field target_field threshold_bits bit b
  | Sloop a b =>
      call_precedes_field_gt_float_or_bit_s
        callee source_field target_field threshold_bits bit a ||
      call_precedes_field_gt_float_or_bit_s
        callee source_field target_field threshold_bits bit b
  | Sifthenelse _ a b =>
      call_precedes_field_gt_float_or_bit_s
        callee source_field target_field threshold_bits bit a ||
      call_precedes_field_gt_float_or_bit_s
        callee source_field target_field threshold_bits bit b
  | Sswitch _ cases =>
      call_precedes_field_gt_float_or_bit_ls
        callee source_field target_field threshold_bits bit cases
  | Slabel _ body =>
      call_precedes_field_gt_float_or_bit_s
        callee source_field target_field threshold_bits bit body
  | _ => false
  end
with call_precedes_field_gt_float_or_bit_ls
    (callee source_field target_field : ident)
    (threshold_bits bit : Z) (cases : labeled_statements) : bool :=
  match cases with
  | LSnil => false
  | LScons _ body rest =>
      call_precedes_field_gt_float_or_bit_s
        callee source_field target_field threshold_bits bit body ||
      call_precedes_field_gt_float_or_bit_ls
        callee source_field target_field threshold_bits bit rest
  end.

Fixpoint statement_assigns_global_s
    (target : ident) (s : statement) : bool :=
  match s with
  | Sassign (Evar found _) _ => Pos.eqb found target
  | Ssequence a b | Sloop a b =>
      statement_assigns_global_s target a || statement_assigns_global_s target b
  | Sifthenelse _ a b =>
      statement_assigns_global_s target a || statement_assigns_global_s target b
  | Sswitch _ cases => statement_assigns_global_ls target cases
  | Slabel _ body => statement_assigns_global_s target body
  | _ => false
  end
with statement_assigns_global_ls
    (target : ident) (cases : labeled_statements) : bool :=
  match cases with
  | LSnil => false
  | LScons _ body rest =>
      statement_assigns_global_s target body ||
      statement_assigns_global_ls target rest
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
  | Init_addrof found _ :: rest => found :: initializer_addrof_idents rest
  | _ :: rest => initializer_addrof_idents rest
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

Definition initializer_addrof_subsequenceb
    (wanted : list ident) (values : list init_data) : bool :=
  ident_subsequenceb wanted (initializer_addrof_idents values).

Fixpoint init_int16_values (values : list init_data) : list Z :=
  match values with
  | [] => []
  | Init_int16 value :: rest => Int.signed value :: init_int16_values rest
  | _ :: rest => init_int16_values rest
  end.

Fixpoint init_float32_values (values : list init_data) : list float32 :=
  match values with
  | [] => []
  | Init_float32 value :: rest => value :: init_float32_values rest
  | _ :: rest => init_float32_values rest
  end.

Fixpoint chunks5 (values : list Z) : list (list Z) :=
  match values with
  | a :: b :: c :: d :: e :: rest => [a; b; c; d; e] :: chunks5 rest
  | _ => []
  end.

Definition record_low9_is (expected : Z) (record : list Z) : bool :=
  match record with
  | head :: _ => Z.eqb (Z.land head 511) expected
  | [] => false
  end.

Definition count_records_with_low9
    (expected : Z) (values : list init_data) : nat :=
  length (filter (record_low9_is expected) (chunks5 (init_int16_values values))).
