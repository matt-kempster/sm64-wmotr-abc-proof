From Coq Require Import Bool List PArith.BinPos.
From compcert Require Import AST Ctypes Clight.
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

Definition generated_target_capability_set_claim : Prop :=
  length current_pointer_users = 11%nat /\
  forallb (fun id => ident_in id allowed_current_pointer_users)
    current_pointer_users = true /\
  forallb (fun id => ident_in id current_pointer_users)
    allowed_current_pointer_users = true /\
  demo_handler_users = [G._setup_game_memory; T._run_level_id_or_demo].

Theorem generated_target_capability_set_certificate :
  generated_target_capability_set_claim.
Proof.
  unfold generated_target_capability_set_claim.
  destruct generated_current_pointer_capability_set_is_exact as (Hlen & Hsub & Hsup).
  exact (conj Hlen (conj Hsub (conj Hsup
    generated_demo_handler_capability_set_is_exact))).
Qed.
