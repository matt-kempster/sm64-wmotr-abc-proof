From Coq Require Import Bool List PArith.BinPos.
From compcert Require Import AST Cop Ctypes Clight Integers.
From DemoWarp.Generated Require Import
  game_init title_screen level_update memory camera behavior_actions
  rumble_init save_file os_cont_start_read_data os_si_raw_start_dma.

Import ListNotations.
Module G := game_init.
Module T := title_screen.
Module L := level_update.
Module M := memory.
Module C := camera.
Module B := behavior_actions.
Module R := rumble_init.
Module S := save_file.
Module O := os_cont_start_read_data.
Module SI := os_si_raw_start_dma.

Fixpoint uses_global_e (wanted : ident) (a : expr) : bool :=
  (match a with Evar found _ => Pos.eqb wanted found | _ => false end) ||
  match a with
  | Ederef x _ | Eaddrof x _ | Eunop _ x _ | Ecast x _ | Efield x _ _ =>
      uses_global_e wanted x
  | Ebinop _ x y _ => uses_global_e wanted x || uses_global_e wanted y
  | _ => false
  end.

Fixpoint uses_global_el (wanted : ident) (xs : list expr) : bool :=
  match xs with
  | [] => false
  | x :: rest => uses_global_e wanted x || uses_global_el wanted rest
  end.

Fixpoint uses_global_s (wanted : ident) (s : statement) : bool :=
  (match s with
   | Sassign lhs rhs => uses_global_e wanted lhs || uses_global_e wanted rhs
   | Sset _ rhs => uses_global_e wanted rhs
   | Scall _ callee args =>
       uses_global_e wanted callee || uses_global_el wanted args
   | Sbuiltin _ _ _ args => uses_global_el wanted args
   | Sifthenelse condition _ _ => uses_global_e wanted condition
   | Sswitch value _ => uses_global_e wanted value
   | Sreturn (Some value) => uses_global_e wanted value
   | _ => false
   end) ||
  match s with
  | Ssequence first second
  | Sifthenelse _ first second
  | Sloop first second => uses_global_s wanted first || uses_global_s wanted second
  | Slabel _ body => uses_global_s wanted body
  | Sswitch _ cases => uses_global_ls wanted cases
  | _ => false
  end
with uses_global_ls (wanted : ident) (cases : labeled_statements) : bool :=
  match cases with
  | LSnil => false
  | LScons _ body rest => uses_global_s wanted body || uses_global_ls wanted rest
  end.

Fixpoint global_users
    (wanted : ident) (defs : list (ident * globdef Clight.fundef type))
    : list ident :=
  match defs with
  | [] => []
  | (id, Gfun (Internal f)) :: rest =>
      if uses_global_s wanted (fn_body f)
      then id :: global_users wanted rest
      else global_users wanted rest
  | _ :: rest => global_users wanted rest
  end.

Definition current_pointer_users : list ident :=
  global_users G._gCurrDemoInput (prog_defs G.prog) ++
  global_users G._gCurrDemoInput (prog_defs T.prog) ++
  global_users G._gCurrDemoInput (prog_defs L.prog) ++
  global_users G._gCurrDemoInput (prog_defs M.prog) ++
  global_users G._gCurrDemoInput (prog_defs C.prog) ++
  global_users G._gCurrDemoInput (prog_defs B.prog) ++
  global_users G._gCurrDemoInput (prog_defs R.prog) ++
  global_users G._gCurrDemoInput (prog_defs S.prog) ++
  global_users G._gCurrDemoInput (prog_defs O.prog) ++
  global_users G._gCurrDemoInput (prog_defs SI.prog).

Definition allowed_current_pointer_users : list ident :=
  [ G._run_demo_inputs;
    T._run_level_id_or_demo;
    L._init_mario_after_warp;
    L._level_trigger_warp;
    L._initiate_delayed_warp;
    L._play_mode_normal;
    L._init_level;
    L._lvl_set_current_level;
    C._init_camera;
    B._bowser_bitdw_actions;
    S._save_file_get_flags ].

Definition demo_handler_users : list ident :=
  global_users G._gDemoInputsBuf (prog_defs G.prog) ++
  global_users G._gDemoInputsBuf (prog_defs T.prog) ++
  global_users G._gDemoInputsBuf (prog_defs L.prog) ++
  global_users G._gDemoInputsBuf (prog_defs M.prog) ++
  global_users G._gDemoInputsBuf (prog_defs C.prog) ++
  global_users G._gDemoInputsBuf (prog_defs B.prog) ++
  global_users G._gDemoInputsBuf (prog_defs R.prog) ++
  global_users G._gDemoInputsBuf (prog_defs S.prog) ++
  global_users G._gDemoInputsBuf (prog_defs O.prog) ++
  global_users G._gDemoInputsBuf (prog_defs SI.prog).

Definition ident_in (wanted : ident) (ids : list ident) : bool :=
  existsb (Pos.eqb wanted) ids.

Fixpoint global_load_temps_s (wanted : ident) (s : statement) : list ident :=
  (match s with
   | Sset destination (Evar found _) =>
       if Pos.eqb wanted found then [destination] else []
   | _ => []
   end) ++
  match s with
  | Ssequence first second
  | Sifthenelse _ first second
  | Sloop first second =>
      global_load_temps_s wanted first ++ global_load_temps_s wanted second
  | Slabel _ body => global_load_temps_s wanted body
  | Sswitch _ cases => global_load_temps_ls wanted cases
  | _ => []
  end
with global_load_temps_ls (wanted : ident) (cases : labeled_statements)
    : list ident :=
  match cases with
  | LSnil => []
  | LScons _ body rest =>
      global_load_temps_s wanted body ++ global_load_temps_ls wanted rest
  end.

Fixpoint global_occurrences_e (wanted : ident) (a : expr) : nat :=
  (match a with Evar found _ => if Pos.eqb wanted found then 1%nat else 0%nat
   | _ => 0%nat end) +
  match a with
  | Ederef x _ | Eaddrof x _ | Eunop _ x _ | Ecast x _ | Efield x _ _ =>
      global_occurrences_e wanted x
  | Ebinop _ x y _ =>
      global_occurrences_e wanted x + global_occurrences_e wanted y
  | _ => 0%nat
  end.

Fixpoint global_occurrences_el (wanted : ident) (xs : list expr) : nat :=
  match xs with
  | [] => 0%nat
  | x :: rest => global_occurrences_e wanted x + global_occurrences_el wanted rest
  end.

Fixpoint global_occurrences_s (wanted : ident) (s : statement) : nat :=
  (match s with
   | Sassign lhs rhs =>
       global_occurrences_e wanted lhs + global_occurrences_e wanted rhs
   | Sset _ rhs => global_occurrences_e wanted rhs
   | Scall _ callee args =>
       global_occurrences_e wanted callee + global_occurrences_el wanted args
   | Sbuiltin _ _ _ args => global_occurrences_el wanted args
   | Sifthenelse condition _ _ => global_occurrences_e wanted condition
   | Sswitch value _ => global_occurrences_e wanted value
   | Sreturn (Some value) => global_occurrences_e wanted value
   | _ => 0%nat
   end) +
  match s with
  | Ssequence first second
  | Sifthenelse _ first second
  | Sloop first second =>
      global_occurrences_s wanted first + global_occurrences_s wanted second
  | Slabel _ body => global_occurrences_s wanted body
  | Sswitch _ cases => global_occurrences_ls wanted cases
  | _ => 0%nat
  end
with global_occurrences_ls (wanted : ident) (cases : labeled_statements) : nat :=
  match cases with
  | LSnil => 0%nat
  | LScons _ body rest =>
      global_occurrences_s wanted body + global_occurrences_ls wanted rest
  end.

Definition is_zero_pointer (a : expr) : bool :=
  match a with
  | Ecast (Econst_int value _) _ => Int.eq value Int.zero
  | _ => false
  end.

Fixpoint unsafe_temp_e (watched : ident) (a : expr) : bool :=
  match a with
  | Ebinop Oeq (Etempvar found _) zero _
  | Ebinop Cop.One (Etempvar found _) zero _ =>
      if Pos.eqb watched found && is_zero_pointer zero then false
      else Pos.eqb watched found || unsafe_temp_e watched zero
  | Ebinop Oeq zero (Etempvar found _) _
  | Ebinop Cop.One zero (Etempvar found _) _ =>
      if Pos.eqb watched found && is_zero_pointer zero then false
      else unsafe_temp_e watched zero || Pos.eqb watched found
  | Etempvar found _ => Pos.eqb watched found
  | Ederef x _ | Eaddrof x _ | Eunop _ x _ | Ecast x _ | Efield x _ _ =>
      unsafe_temp_e watched x
  | Ebinop _ x y _ => unsafe_temp_e watched x || unsafe_temp_e watched y
  | _ => false
  end.

Fixpoint unsafe_temp_el (watched : ident) (xs : list expr) : bool :=
  match xs with
  | [] => false
  | x :: rest => unsafe_temp_e watched x || unsafe_temp_el watched rest
  end.

Fixpoint unsafe_temp_s (watched : ident) (s : statement) : bool :=
  (match s with
   | Sassign lhs rhs => unsafe_temp_e watched lhs || unsafe_temp_e watched rhs
   | Sset _ rhs => unsafe_temp_e watched rhs
   | Scall _ callee args =>
       unsafe_temp_e watched callee || unsafe_temp_el watched args
   | Sbuiltin _ _ _ args => unsafe_temp_el watched args
   | Sifthenelse condition _ _ => unsafe_temp_e watched condition
   | Sswitch value _ => unsafe_temp_e watched value
   | Sreturn (Some value) => unsafe_temp_e watched value
   | _ => false
   end) ||
  match s with
  | Ssequence first second
  | Sifthenelse _ first second
  | Sloop first second => unsafe_temp_s watched first || unsafe_temp_s watched second
  | Slabel _ body => unsafe_temp_s watched body
  | Sswitch _ cases => unsafe_temp_ls watched cases
  | _ => false
  end
with unsafe_temp_ls (watched : ident) (cases : labeled_statements) : bool :=
  match cases with
  | LSnil => false
  | LScons _ body rest => unsafe_temp_s watched body || unsafe_temp_ls watched rest
  end.

Definition function_reads_current_only_as_null_test (f : function) : bool :=
  let loads := global_load_temps_s G._gCurrDemoInput (fn_body f) in
  Nat.eqb (length loads)
    (global_occurrences_s G._gCurrDemoInput (fn_body f)) &&
  forallb (fun temp => negb (unsafe_temp_s temp (fn_body f))) loads.

Fixpoint read_only_users_safe_defs
    (defs : list (ident * globdef Clight.fundef type)) : bool :=
  match defs with
  | [] => true
  | (id, Gfun (Internal f)) :: rest =>
      let relevant := uses_global_s G._gCurrDemoInput (fn_body f) in
      let writer := Pos.eqb id G._run_demo_inputs ||
                    Pos.eqb id T._run_level_id_or_demo in
      (negb relevant || writer || function_reads_current_only_as_null_test f) &&
      read_only_users_safe_defs rest
  | _ :: rest => read_only_users_safe_defs rest
  end.

Definition generated_read_only_capability_audit : bool :=
  read_only_users_safe_defs (prog_defs G.prog) &&
  read_only_users_safe_defs (prog_defs T.prog) &&
  read_only_users_safe_defs (prog_defs L.prog) &&
  read_only_users_safe_defs (prog_defs M.prog) &&
  read_only_users_safe_defs (prog_defs C.prog) &&
  read_only_users_safe_defs (prog_defs B.prog) &&
  read_only_users_safe_defs (prog_defs R.prog) &&
  read_only_users_safe_defs (prog_defs S.prog) &&
  read_only_users_safe_defs (prog_defs O.prog) &&
  read_only_users_safe_defs (prog_defs SI.prog).

Theorem generated_current_pointer_capability_set_is_exact :
  length current_pointer_users = 11%nat /\
  forallb (fun id => ident_in id allowed_current_pointer_users)
    current_pointer_users = true /\
  forallb (fun id => ident_in id current_pointer_users)
    allowed_current_pointer_users = true.
Proof. vm_compute. repeat split; reflexivity. Qed.

Theorem generated_demo_handler_capability_set_is_exact :
  demo_handler_users = [G._setup_game_memory; T._run_level_id_or_demo].
Proof. vm_compute. reflexivity. Qed.

Theorem generated_read_only_users_do_not_escape_loaded_pointer :
  generated_read_only_capability_audit = true.
Proof. vm_compute. reflexivity. Qed.

Definition generated_target_capability_set_claim : Prop :=
  length current_pointer_users = 11%nat /\
  forallb (fun id => ident_in id allowed_current_pointer_users)
    current_pointer_users = true /\
  forallb (fun id => ident_in id current_pointer_users)
    allowed_current_pointer_users = true /\
  demo_handler_users = [G._setup_game_memory; T._run_level_id_or_demo] /\
  generated_read_only_capability_audit = true.

Theorem generated_target_capability_set_certificate :
  generated_target_capability_set_claim.
Proof.
  unfold generated_target_capability_set_claim.
  destruct generated_current_pointer_capability_set_is_exact as (Hlen & Hsub & Hsup).
  exact (conj Hlen (conj Hsub (conj Hsup
    (conj generated_demo_handler_capability_set_is_exact
      generated_read_only_users_do_not_escape_loaded_pointer)))).
Qed.
