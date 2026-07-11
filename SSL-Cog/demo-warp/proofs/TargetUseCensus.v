From Coq Require Import Bool List PArith.BinPos.
From compcert Require Import AST Ctypes Clight.
From DemoWarp.Generated Require Import
  game_init title_screen level_update memory camera
  behavior_actions rumble_init save_file
  os_cont_start_read_data os_si_raw_start_dma.

Local Open Scope nat_scope.

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

Fixpoint addrof_global_e (wanted : ident) (a : expr) : nat :=
  (match a with
   | Eaddrof (Evar found _) _ => if Pos.eqb wanted found then 1 else 0
   | _ => 0
   end) +
  match a with
  | Ederef x _ | Eaddrof x _ | Eunop _ x _ | Ecast x _ | Efield x _ _ =>
      addrof_global_e wanted x
  | Ebinop _ x y _ => addrof_global_e wanted x + addrof_global_e wanted y
  | _ => 0
  end.

Fixpoint addrof_global_el (wanted : ident) (xs : list expr) : nat :=
  match xs with
  | nil => 0
  | x :: rest => addrof_global_e wanted x + addrof_global_el wanted rest
  end.

Fixpoint addrof_global_s (wanted : ident) (s : statement) : nat :=
  (match s with
   | Sassign lhs rhs => addrof_global_e wanted lhs + addrof_global_e wanted rhs
   | Sset _ rhs => addrof_global_e wanted rhs
   | Scall _ callee args =>
       addrof_global_e wanted callee + addrof_global_el wanted args
   | Sbuiltin _ _ _ args => addrof_global_el wanted args
   | Sifthenelse condition _ _ => addrof_global_e wanted condition
   | Sswitch value _ => addrof_global_e wanted value
   | Sreturn (Some value) => addrof_global_e wanted value
   | _ => 0
   end) +
  match s with
  | Ssequence first second
  | Sifthenelse _ first second
  | Sloop first second =>
      addrof_global_s wanted first + addrof_global_s wanted second
  | Slabel _ body => addrof_global_s wanted body
  | Sswitch _ cases => addrof_global_ls wanted cases
  | _ => 0
  end
with addrof_global_ls (wanted : ident) (cases : labeled_statements) : nat :=
  match cases with
  | LSnil => 0
  | LScons _ body rest =>
      addrof_global_s wanted body + addrof_global_ls wanted rest
  end.

Fixpoint direct_global_assigns_s (wanted : ident) (s : statement) : nat :=
  (match s with
   | Sassign (Evar found _) _ => if Pos.eqb wanted found then 1 else 0
   | _ => 0
   end) +
  match s with
  | Ssequence first second
  | Sifthenelse _ first second
  | Sloop first second =>
      direct_global_assigns_s wanted first +
      direct_global_assigns_s wanted second
  | Slabel _ body => direct_global_assigns_s wanted body
  | Sswitch _ cases => direct_global_assigns_ls wanted cases
  | _ => 0
  end
with direct_global_assigns_ls
    (wanted : ident) (cases : labeled_statements) : nat :=
  match cases with
  | LSnil => 0
  | LScons _ body rest =>
      direct_global_assigns_s wanted body +
      direct_global_assigns_ls wanted rest
  end.

Fixpoint addrof_global_defs
    (wanted : ident)
    (defs : list (ident * globdef Clight.fundef type)) : nat :=
  match defs with
  | nil => 0
  | (_, Gfun (Internal f)) :: rest =>
      addrof_global_s wanted (fn_body f) + addrof_global_defs wanted rest
  | _ :: rest => addrof_global_defs wanted rest
  end.

Fixpoint direct_global_assigns_defs
    (wanted : ident)
    (defs : list (ident * globdef Clight.fundef type)) : nat :=
  match defs with
  | nil => 0
  | (_, Gfun (Internal f)) :: rest =>
      direct_global_assigns_s wanted (fn_body f) +
      direct_global_assigns_defs wanted rest
  | _ :: rest => direct_global_assigns_defs wanted rest
  end.

Definition curr_addrof_surface : nat :=
  addrof_global_defs G._gCurrDemoInput (prog_defs G.prog) +
  addrof_global_defs G._gCurrDemoInput (prog_defs T.prog) +
  addrof_global_defs G._gCurrDemoInput (prog_defs L.prog) +
  addrof_global_defs G._gCurrDemoInput (prog_defs M.prog) +
  addrof_global_defs G._gCurrDemoInput (prog_defs C.prog) +
  addrof_global_defs G._gCurrDemoInput (prog_defs B.prog) +
  addrof_global_defs G._gCurrDemoInput (prog_defs R.prog) +
  addrof_global_defs G._gCurrDemoInput (prog_defs S.prog) +
  addrof_global_defs G._gCurrDemoInput (prog_defs OC.prog) +
  addrof_global_defs G._gCurrDemoInput (prog_defs SI.prog).

Definition curr_direct_assign_surface : nat :=
  direct_global_assigns_defs G._gCurrDemoInput (prog_defs G.prog) +
  direct_global_assigns_defs G._gCurrDemoInput (prog_defs T.prog) +
  direct_global_assigns_defs G._gCurrDemoInput (prog_defs L.prog) +
  direct_global_assigns_defs G._gCurrDemoInput (prog_defs M.prog) +
  direct_global_assigns_defs G._gCurrDemoInput (prog_defs C.prog) +
  direct_global_assigns_defs G._gCurrDemoInput (prog_defs B.prog) +
  direct_global_assigns_defs G._gCurrDemoInput (prog_defs R.prog) +
  direct_global_assigns_defs G._gCurrDemoInput (prog_defs S.prog) +
  direct_global_assigns_defs G._gCurrDemoInput (prog_defs OC.prog) +
  direct_global_assigns_defs G._gCurrDemoInput (prog_defs SI.prog).

Definition handler_addrof_surface : nat :=
  addrof_global_defs G._gDemoInputsBuf (prog_defs G.prog) +
  addrof_global_defs G._gDemoInputsBuf (prog_defs T.prog) +
  addrof_global_defs G._gDemoInputsBuf (prog_defs L.prog) +
  addrof_global_defs G._gDemoInputsBuf (prog_defs M.prog) +
  addrof_global_defs G._gDemoInputsBuf (prog_defs C.prog) +
  addrof_global_defs G._gDemoInputsBuf (prog_defs B.prog) +
  addrof_global_defs G._gDemoInputsBuf (prog_defs R.prog) +
  addrof_global_defs G._gDemoInputsBuf (prog_defs S.prog) +
  addrof_global_defs G._gDemoInputsBuf (prog_defs OC.prog) +
  addrof_global_defs G._gDemoInputsBuf (prog_defs SI.prog).

Theorem generated_curr_pointer_cell_address_never_escapes :
  curr_addrof_surface = 0.
Proof. vm_compute. reflexivity. Qed.

Theorem generated_curr_pointer_has_three_runtime_assignments :
  curr_direct_assign_surface = 3.
Proof. vm_compute. reflexivity. Qed.

Theorem generated_demo_handler_address_has_two_uses :
  handler_addrof_surface = 2.
Proof. vm_compute. reflexivity. Qed.

Definition generated_target_use_surface_claim : Prop :=
  curr_addrof_surface = 0 /\
  curr_direct_assign_surface = 3 /\
  handler_addrof_surface = 2.

Theorem generated_target_use_surface_certificate :
  generated_target_use_surface_claim.
Proof.
  exact (conj generated_curr_pointer_cell_address_never_escapes
    (conj generated_curr_pointer_has_three_runtime_assignments
      generated_demo_handler_address_has_two_uses)).
Qed.
