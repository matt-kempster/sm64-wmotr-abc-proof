From Coq Require Import Bool List PArith.BinPos ZArith.
From compcert Require Import AST Ctypes Clight Integers.

Fixpoint calls_ident_s (callee : ident) (s : statement) : bool :=
  match s with
  | Scall _ (Evar id _) _ => Pos.eqb id callee
  | Ssequence s1 s2 =>
      calls_ident_s callee s1 || calls_ident_s callee s2
  | Sifthenelse _ s1 s2 =>
      calls_ident_s callee s1 || calls_ident_s callee s2
  | Sloop s1 s2 =>
      calls_ident_s callee s1 || calls_ident_s callee s2
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
  | Scall _ (Evar id _) _ => id :: nil
  | Ssequence s1 s2 => direct_callees_s s1 ++ direct_callees_s s2
  | Sifthenelse _ s1 s2 =>
      direct_callees_s s1 ++ direct_callees_s s2
  | Sloop s1 s2 => direct_callees_s s1 ++ direct_callees_s s2
  | Slabel _ body => direct_callees_s body
  | Sswitch _ cases => direct_callees_ls cases
  | _ => nil
  end
with direct_callees_ls (cases : labeled_statements) : list ident :=
  match cases with
  | LSnil => nil
  | LScons _ body rest =>
      direct_callees_s body ++ direct_callees_ls rest
  end.

Fixpoint writes_temp_s (temporary : ident) (s : statement) : bool :=
  match s with
  | Sset found _ => Pos.eqb found temporary
  | Scall (Some found) _ _ => Pos.eqb found temporary
  | Sbuiltin (Some found) _ _ _ => Pos.eqb found temporary
  | Ssequence s1 s2 =>
      writes_temp_s temporary s1 || writes_temp_s temporary s2
  | Sifthenelse _ s1 s2 =>
      writes_temp_s temporary s1 || writes_temp_s temporary s2
  | Sloop s1 s2 =>
      writes_temp_s temporary s1 || writes_temp_s temporary s2
  | Slabel _ body => writes_temp_s temporary body
  | Sswitch _ cases => writes_temp_ls temporary cases
  | _ => false
  end
with writes_temp_ls (temporary : ident) (cases : labeled_statements) : bool :=
  match cases with
  | LSnil => false
  | LScons _ body rest =>
      writes_temp_s temporary body || writes_temp_ls temporary rest
  end.

Definition expression_is_null (e : expr) : bool :=
  match e with
  | Econst_int value _ => Int.eq value Int.zero
  | Ecast (Econst_int value _) _ => Int.eq value Int.zero
  | _ => false
  end.

Definition lvalue_top_field (e : expr) : option ident :=
  match e with
  | Efield _ field _ => Some field
  | _ => None
  end.

Inductive statement_event : Type :=
| Event_call : ident -> statement_event
| Event_assign_field : ident -> statement_event
| Event_assign_field_null : ident -> statement_event
| Event_set_temp_from_field :
    ident -> ident -> ident -> statement_event
| Event_assign_field_from_temp :
    ident -> ident -> statement_event.

Definition statement_event_eqb (left right : statement_event) : bool :=
  match left, right with
  | Event_call left_id, Event_call right_id
  | Event_assign_field left_id, Event_assign_field right_id =>
      Pos.eqb left_id right_id
  | Event_assign_field_null left_id, Event_assign_field_null right_id =>
      Pos.eqb left_id right_id
  | Event_set_temp_from_field left_temp left_base left_field,
    Event_set_temp_from_field right_temp right_base right_field =>
      Pos.eqb left_temp right_temp &&
      Pos.eqb left_base right_base &&
      Pos.eqb left_field right_field
  | Event_assign_field_from_temp left_field left_temp,
    Event_assign_field_from_temp right_field right_temp =>
      Pos.eqb left_field right_field &&
      Pos.eqb left_temp right_temp
  | _, _ => false
  end.

Definition expression_temp (e : expr) : option ident :=
  match e with
  | Etempvar temporary _ => Some temporary
  | _ => None
  end.

Definition expression_field_of_temp
    (e : expr) : option (ident * ident) :=
  match e with
  | Efield
      (Ederef (Etempvar base _) _)
      field _ => Some (base, field)
  | _ => None
  end.

Fixpoint statement_events_s (s : statement) : list statement_event :=
  match s with
  | Scall _ (Evar id _) _ => Event_call id :: nil
  | Sset temporary rhs =>
      match expression_field_of_temp rhs with
      | Some (base, field) =>
          Event_set_temp_from_field temporary base field :: nil
      | None => nil
      end
  | Sassign lhs rhs =>
      match lvalue_top_field lhs with
      | Some field =>
          Event_assign_field field ::
          ((if expression_is_null rhs then
              Event_assign_field_null field :: nil
            else nil) ++
           match expression_temp rhs with
           | Some temporary =>
               Event_assign_field_from_temp field temporary :: nil
           | None => nil
           end)
      | None => nil
      end
  | Ssequence s1 s2 =>
      statement_events_s s1 ++ statement_events_s s2
  | Sifthenelse _ s1 s2 =>
      statement_events_s s1 ++ statement_events_s s2
  | Sloop s1 s2 =>
      statement_events_s s1 ++ statement_events_s s2
  | Slabel _ body => statement_events_s body
  | Sswitch _ cases => statement_events_ls cases
  | _ => nil
  end
with statement_events_ls (cases : labeled_statements)
    : list statement_event :=
  match cases with
  | LSnil => nil
  | LScons _ body rest =>
      statement_events_s body ++ statement_events_ls rest
  end.

Fixpoint event_subsequenceb
    (needle haystack : list statement_event) : bool :=
  match needle with
  | nil => true
  | wanted :: rest =>
      match haystack with
      | nil => false
      | found :: haystack_rest =>
          if statement_event_eqb wanted found then
            event_subsequenceb rest haystack_rest
          else
            event_subsequenceb needle haystack_rest
      end
  end.

Fixpoint expression_mentions_temp (temporary : ident) (e : expr) : bool :=
  match e with
  | Etempvar found _ => Pos.eqb found temporary
  | Ederef inner _ | Eaddrof inner _ | Eunop _ inner _
  | Ecast inner _ | Efield inner _ _ =>
      expression_mentions_temp temporary inner
  | Ebinop _ operand1 operand2 _ =>
      expression_mentions_temp temporary operand1 ||
      expression_mentions_temp temporary operand2
  | _ => false
  end.

Fixpoint assigns_through_temp_s
    (temporary : ident) (s : statement) : bool :=
  match s with
  | Sassign lhs _ => expression_mentions_temp temporary lhs
  | Ssequence s1 s2 | Sifthenelse _ s1 s2 | Sloop s1 s2 =>
      assigns_through_temp_s temporary s1 ||
      assigns_through_temp_s temporary s2
  | Slabel _ body => assigns_through_temp_s temporary body
  | Sswitch _ cases => assigns_through_temp_ls temporary cases
  | _ => false
  end
with assigns_through_temp_ls
       (temporary : ident) (cases : labeled_statements) : bool :=
  match cases with
  | LSnil => false
  | LScons _ body rest =>
      assigns_through_temp_s temporary body ||
      assigns_through_temp_ls temporary rest
  end.

Fixpoint assigns_zero_to_field_s (field : ident) (s : statement) : bool :=
  match s with
  | Sassign lhs rhs =>
      match lvalue_top_field lhs with
      | Some found => Pos.eqb found field && expression_is_null rhs
      | None => false
      end
  | Ssequence s1 s2 =>
      assigns_zero_to_field_s field s1 || assigns_zero_to_field_s field s2
  | Sifthenelse _ s1 s2 =>
      assigns_zero_to_field_s field s1 || assigns_zero_to_field_s field s2
  | Sloop s1 s2 =>
      assigns_zero_to_field_s field s1 || assigns_zero_to_field_s field s2
  | Slabel _ body => assigns_zero_to_field_s field body
  | Sswitch _ cases => assigns_zero_to_field_ls field cases
  | _ => false
  end
with assigns_zero_to_field_ls
       (field : ident) (cases : labeled_statements) : bool :=
  match cases with
  | LSnil => false
  | LScons _ body rest =>
      assigns_zero_to_field_s field body ||
      assigns_zero_to_field_ls field rest
  end.

Fixpoint assigns_field_s (field : ident) (s : statement) : bool :=
  match s with
  | Sassign lhs _ =>
      match lvalue_top_field lhs with
      | Some found => Pos.eqb found field
      | None => false
      end
  | Ssequence s1 s2 =>
      assigns_field_s field s1 || assigns_field_s field s2
  | Sifthenelse _ s1 s2 =>
      assigns_field_s field s1 || assigns_field_s field s2
  | Sloop s1 s2 =>
      assigns_field_s field s1 || assigns_field_s field s2
  | Slabel _ body => assigns_field_s field body
  | Sswitch _ cases => assigns_field_ls field cases
  | _ => false
  end
with assigns_field_ls (field : ident) (cases : labeled_statements) : bool :=
  match cases with
  | LSnil => false
  | LScons _ body rest =>
      assigns_field_s field body || assigns_field_ls field rest
  end.

Local Open Scope Z_scope.

Definition pack_bytes (a b c d : Z) : int :=
  Int.repr (a * 2 ^ 24 + b * 2 ^ 16 + c * 2 ^ 8 + d).

Definition warp_node_words_match
    (word1 word2 : int)
    (node_id dest_level dest_area dest_node flags : Z) : bool :=
  Int.eq word1 (pack_bytes 38 8 node_id dest_level) &&
  Int.eq word2 (pack_bytes dest_area dest_node flags 0).

Fixpoint contains_warp_node_aux
    (previous : option int) (data : list init_data)
    (node_id dest_level dest_area dest_node flags : Z) : bool :=
  match data with
  | Init_int32 word :: rest =>
      match previous with
      | Some word1 =>
          warp_node_words_match word1 word
            node_id dest_level dest_area dest_node flags ||
          contains_warp_node_aux (Some word) rest
            node_id dest_level dest_area dest_node flags
      | None =>
          contains_warp_node_aux (Some word) rest
            node_id dest_level dest_area dest_node flags
      end
  | _ :: rest =>
      contains_warp_node_aux None rest
        node_id dest_level dest_area dest_node flags
  | nil => false
  end.

Definition contains_warp_node
    (data : list init_data)
    (node_id dest_level dest_area dest_node flags : Z) : bool :=
  contains_warp_node_aux None data
    node_id dest_level dest_area dest_node flags.

Definition int16_matches (value : int) (expected : Z) : bool :=
  Int.eq value (Int.repr expected).

Fixpoint contains_macro_object
    (data : list init_data)
    (encoded_preset x y z parameter : Z) : bool :=
  match data with
  | Init_int16 p :: Init_int16 px :: Init_int16 py ::
    Init_int16 pz :: Init_int16 arg :: rest =>
      (int16_matches p encoded_preset &&
       int16_matches px x &&
       int16_matches py y &&
       int16_matches pz z &&
       int16_matches arg parameter) ||
      contains_macro_object rest encoded_preset x y z parameter
  | _ => false
  end.

Fixpoint macro_preset_behavior_at
    (index : nat) (data : list init_data) : option ident :=
  match index, data with
  | O, Init_addrof behavior _ :: Init_int16 _ :: Init_int16 _ :: _ =>
      Some behavior
  | S index',
    Init_addrof _ _ :: Init_int16 _ :: Init_int16 _ :: rest =>
      macro_preset_behavior_at index' rest
  | _, _ => None
  end.

Fixpoint macro_preset_param_at
    (index : nat) (data : list init_data) : option int :=
  match index, data with
  | O, Init_addrof _ _ :: Init_int16 _ :: Init_int16 parameter :: _ =>
      Some parameter
  | S index',
    Init_addrof _ _ :: Init_int16 _ :: Init_int16 _ :: rest =>
      macro_preset_param_at index' rest
  | _, _ => None
  end.

Fixpoint count_macro_objects_with_preset
    (data : list init_data) (encoded_preset : Z) : nat :=
  match data with
  | Init_int16 p :: Init_int16 _ :: Init_int16 _ ::
    Init_int16 _ :: Init_int16 _ :: rest =>
      if int16_matches p encoded_preset
      then S (count_macro_objects_with_preset rest encoded_preset)
      else count_macro_objects_with_preset rest encoded_preset
  | _ => O
  end.

Definition int8_matches (value : int) (expected : Z) : bool :=
  Int.eq value (Int.repr expected).

Fixpoint exclamation_box_content_behavior_at
    (contents_id : Z) (data : list init_data) : option ident :=
  match data with
  | Init_int8 found_id :: Init_int8 _ :: Init_int8 _ :: Init_int8 _ ::
    Init_addrof behavior _ :: rest =>
      if int8_matches found_id contents_id
      then Some behavior
      else exclamation_box_content_behavior_at contents_id rest
  | _ => None
  end.

Definition first_int32 (data : list init_data) : option int :=
  match data with
  | Init_int32 value :: _ => Some value
  | _ => None
  end.

Fixpoint internal_functions
    (definitions : list (ident * globdef fundef type))
    : list (ident * function) :=
  match definitions with
  | nil => nil
  | (id, Gfun (Internal function_body)) :: rest =>
      (id, function_body) :: internal_functions rest
  | _ :: rest => internal_functions rest
  end.

Definition direct_field_writers
    (program : Clight.program) (field : ident) : list ident :=
  map fst
    (filter
      (fun named_function =>
         assigns_field_s field (fn_body (snd named_function)))
      (internal_functions (prog_defs program))).
