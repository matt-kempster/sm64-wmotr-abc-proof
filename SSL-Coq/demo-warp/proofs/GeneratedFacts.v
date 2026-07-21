From Coq Require Import Bool List PArith.BinPos.
From compcert Require Import AST Ctypes Clight Integers.
From DemoWarp.Generated Require Import game_init title_screen.

Import ListNotations.

Module G := game_init.
Module T := title_screen.

Inductive demo_event : Type :=
| Event_load_current : ident -> demo_event
| Event_load_timer : ident -> ident -> demo_event
| Event_decrement : ident -> ident -> demo_event
| Event_store_timer : ident -> ident -> demo_event
| Event_advance_current : ident -> demo_event.

Definition demo_event_eqb (left right : demo_event) : bool :=
  match left, right with
  | Event_load_current l, Event_load_current r
  | Event_advance_current l, Event_advance_current r => Pos.eqb l r
  | Event_load_timer ld lb, Event_load_timer rd rb
  | Event_decrement ld lb, Event_decrement rd rb
  | Event_store_timer ld lb, Event_store_timer rd rb =>
      Pos.eqb ld rd && Pos.eqb lb rb
  | _, _ => false
  end.

Definition event_of_statement (s : statement) : list demo_event :=
  match s with
  | Sset destination (Evar global _) =>
      if Pos.eqb global G._gCurrDemoInput
      then [Event_load_current destination]
      else []
  | Sset destination
      (Efield
        (Ederef
          (Etempvar base
            (Tpointer (Tstruct struct_id _) _))
          (Tstruct deref_id _))
        field (Tint I8 Unsigned _)) =>
      if Pos.eqb struct_id G._DemoInput &&
         Pos.eqb deref_id G._DemoInput &&
         Pos.eqb field G._timer
      then [Event_load_timer destination base]
      else []
  | Sset destination
      (Ecast
        (Ebinop Osub (Etempvar source _) (Econst_int one _) _)
        (Tint I8 Unsigned _)) =>
      if Int.eq one Int.one
      then [Event_decrement destination source]
      else []
  | Sassign
      (Efield
        (Ederef
          (Etempvar base
            (Tpointer (Tstruct struct_id _) _))
          (Tstruct deref_id _))
        field (Tint I8 Unsigned _))
      (Etempvar source (Tint I8 Unsigned _)) =>
      if Pos.eqb struct_id G._DemoInput &&
         Pos.eqb deref_id G._DemoInput &&
         Pos.eqb field G._timer
      then [Event_store_timer base source]
      else []
  | Sassign (Evar global _)
      (Ebinop Oadd (Etempvar source _) (Econst_int one _) _) =>
      if Pos.eqb global G._gCurrDemoInput && Int.eq one Int.one
      then [Event_advance_current source]
      else []
  | _ => []
  end.

Fixpoint demo_events_s (s : statement) : list demo_event :=
  event_of_statement s ++
  match s with
  | Ssequence first second
  | Sifthenelse _ first second
  | Sloop first second => demo_events_s first ++ demo_events_s second
  | Slabel _ body => demo_events_s body
  | Sswitch _ cases => demo_events_ls cases
  | _ => []
  end
with demo_events_ls (cases : labeled_statements) : list demo_event :=
  match cases with
  | LSnil => []
  | LScons _ body rest => demo_events_s body ++ demo_events_ls rest
  end.

Fixpoint event_subsequenceb
    (needle haystack : list demo_event) : bool :=
  match needle with
  | [] => true
  | wanted :: remaining =>
      match haystack with
      | [] => false
      | found :: rest =>
          if demo_event_eqb wanted found
          then event_subsequenceb remaining rest
          else event_subsequenceb needle rest
      end
  end.

Fixpoint timer_store_count (events : list demo_event) : nat :=
  match events with
  | [] => O
  | Event_store_timer _ _ :: rest => S (timer_store_count rest)
  | _ :: rest => timer_store_count rest
  end.

Definition expected_timer_decrement_trace : list demo_event :=
  [ Event_load_current G._t'7;
    Event_load_timer G._t'8 G._t'7;
    Event_decrement G._t'1 G._t'8;
    Event_load_current G._t'6;
    Event_store_timer G._t'6 G._t'1;
    Event_load_current G._t'5;
    Event_advance_current G._t'5 ].

Theorem generated_run_demo_inputs_has_decrement_trace :
  event_subsequenceb expected_timer_decrement_trace
    (demo_events_s (fn_body G.f_run_demo_inputs)) = true.
Proof. vm_compute. reflexivity. Qed.

Theorem generated_run_demo_inputs_has_one_timer_store :
  timer_store_count (demo_events_s (fn_body G.f_run_demo_inputs)) = 1%nat.
Proof. vm_compute. reflexivity. Qed.

Inductive pointer_write_shape : Type :=
| Write_null
| Write_add_one
| Write_other.

Definition classify_pointer_rhs (rhs : expr) : pointer_write_shape :=
  match rhs with
  | Ecast (Econst_int zero _) _ =>
      if Int.eq zero Int.zero then Write_null else Write_other
  | Ebinop Oadd _ (Econst_int one _) _ =>
      if Int.eq one Int.one then Write_add_one else Write_other
  | _ => Write_other
  end.

Fixpoint pointer_writes_s
    (global : ident) (s : statement) : list pointer_write_shape :=
  (match s with
   | Sassign (Evar found _) rhs =>
       if Pos.eqb found global then [classify_pointer_rhs rhs] else []
   | _ => []
   end) ++
  match s with
  | Ssequence first second
  | Sifthenelse _ first second
  | Sloop first second =>
      pointer_writes_s global first ++ pointer_writes_s global second
  | Slabel _ body => pointer_writes_s global body
  | Sswitch _ cases => pointer_writes_ls global cases
  | _ => []
  end
with pointer_writes_ls
    (global : ident) (cases : labeled_statements)
    : list pointer_write_shape :=
  match cases with
  | LSnil => []
  | LScons _ body rest =>
      pointer_writes_s global body ++ pointer_writes_ls global rest
  end.

Theorem generated_run_demo_pointer_writes_are_increment_only :
  pointer_writes_s G._gCurrDemoInput (fn_body G.f_run_demo_inputs) =
    [Write_add_one].
Proof. vm_compute. reflexivity. Qed.

Theorem generated_title_pointer_writes_are_null_or_buffer_advance :
  pointer_writes_s T._gCurrDemoInput
    (fn_body T.f_run_level_id_or_demo) =
    [Write_null; Write_add_one].
Proof. vm_compute. reflexivity. Qed.

Theorem generated_game_init_pointer_starts_null :
  gvar_init G.v_gCurrDemoInput = [Init_int32 Int.zero].
Proof. reflexivity. Qed.

Definition generated_direct_pointer_writer_claim : Prop :=
  gvar_init G.v_gCurrDemoInput = [Init_int32 Int.zero] /\
  pointer_writes_s G._gCurrDemoInput (fn_body G.f_run_demo_inputs) =
    [Write_add_one] /\
  pointer_writes_s T._gCurrDemoInput
    (fn_body T.f_run_level_id_or_demo) =
    [Write_null; Write_add_one].

Theorem generated_direct_pointer_writer_certificate :
  generated_direct_pointer_writer_claim.
Proof.
  unfold generated_direct_pointer_writer_claim.
  split.
  - apply generated_game_init_pointer_starts_null.
  - split.
    + apply generated_run_demo_pointer_writes_are_increment_only.
    + apply generated_title_pointer_writes_are_null_or_buffer_advance.
Qed.
