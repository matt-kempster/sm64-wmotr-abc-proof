(* kept: the camera pins' write census (2026-11-02).  Consumed by the
   deferred cam_w pin clause (sMarioCamState / sLuigiCamState =
   &gPlayerCameraState[0 / 1], gSecondCameraFocus = NULL), proved at boot and
   carried together with R3 and B'' (b)/(c) in one rebuild. *)
(* ====================================================================== *)
(* CamPinCensus.v -- who can write the camera's pointer globals, read off  *)
(* the generated AST of EVERY linked TU (RoCensus.all_fns: the 53 TUs of  *)
(* LinkedTwelve.tu_rest plus mario.c), not a grep of the vendor sources.   *)
(*                                                                        *)
(* A global g can change only through                                     *)
(*   (a) a store whose lvalue IS g (Sassign (Evar g _) _), or              *)
(*   (b) a store through a pointer to g's block, which needs g's address: *)
(*       an Eaddrof (Evar g) in some body, or an Init_addrof g in some    *)
(*       global's initializer, or g as an rvalue of array / struct type   *)
(*       (decay) -- g is a scalar pointer here, so only the first two.    *)
(* The census pins, for each pin global, the functions of (a) and checks  *)
(* that (b) never happens: its address is taken nowhere in the link.      *)
(* So a carried pin can only be broken by the listed direct writers or by  *)
(* a store through some pointer that ALREADY aims at g's block -- which   *)
(* each phase's footprint (the walks) excludes.                            *)
(* ====================================================================== *)

From Coq Require Import ZArith List Bool.
From compcert Require Import Coqlib Maps AST Integers Ctypes Cop Clight Clightdefs.
From SM64.Generated Require camera object_helpers behavior_actions.
From SM64.Proofs Require Import LinkedTwelve.
From SM64.Proofs.WMotRRequiresA Require Import ObjTable RoCensus.
Import ListNotations.

(* every expression of a statement (each assignment / call / test operand) *)
Fixpoint s_exprs (s : statement) : list expr :=
  match s with
  | Sassign l r => [l; r]
  | Sset _ a => [a]
  | Scall _ a al => a :: al
  | Sbuiltin _ _ _ al => al
  | Ssequence s1 s2 | Sloop s1 s2 => s_exprs s1 ++ s_exprs s2
  | Sifthenelse a s1 s2 => a :: s_exprs s1 ++ s_exprs s2
  | Sswitch a sl => a :: ls_exprs sl
  | Sreturn (Some a) => [a]
  | Slabel _ s1 => s_exprs s1
  | _ => nil
  end
with ls_exprs (sl : labeled_statements) : list expr :=
  match sl with LSnil => nil | LScons _ s sl' => s_exprs s ++ ls_exprs sl' end.

(* g's address is taken somewhere in the expression *)
Fixpoint addr_of (g : ident) (a : expr) : bool :=
  match a with
  | Eaddrof (Evar x _) _ => Pos.eqb x g
  | Eaddrof a1 _ | Ederef a1 _ | Efield a1 _ _ | Eunop _ a1 _ | Ecast a1 _ => addr_of g a1
  | Ebinop _ a1 a2 _ => addr_of g a1 || addr_of g a2
  | _ => false
  end.

(* the direct stores to g *)
Fixpoint direct_st (g : ident) (s : statement) : bool :=
  match s with
  | Sassign (Evar x _) _ => Pos.eqb x g
  | Ssequence s1 s2 | Sloop s1 s2 | Sifthenelse _ s1 s2 => direct_st g s1 || direct_st g s2
  | Sswitch _ sl => direct_ls g sl
  | Slabel _ s1 => direct_st g s1
  | _ => false
  end
with direct_ls (g : ident) (sl : labeled_statements) : bool :=
  match sl with LSnil => false | LScons _ s sl' => direct_st g s || direct_ls g sl' end.

(* the functions storing g directly, and those taking its address; a body
   whose function is not an Internal of the link has no statement *)
Definition direct_writers (g : ident) : list ident :=
  map (fun '(_, id, _) => id)
    (filter (fun '(_, _, f) => direct_st g (fn_body f)) all_fns).

Definition addr_takers (g : ident) : list ident :=
  map (fun '(_, id, _) => id)
    (filter (fun '(_, _, f) => existsb (addr_of g) (s_exprs (fn_body f))) all_fns).

(* g's address in some global's initializer, in any TU *)
Definition init_addr (g : ident) : bool :=
  existsb (fun p : Clight.program =>
    existsb (fun '(_, d) =>
      match d with
      | Gvar v => existsb (fun i => match i with Init_addrof x _ => Pos.eqb x g | _ => false end)
                    (gvar_init v)
      | _ => false
      end) (prog_defs p)) lprogs.

(* ---------------------------------------------------------------------- *)
(* The pins.                                                               *)
(* ---------------------------------------------------------------------- *)

(* sMarioCamState / sLuigiCamState: no direct store anywhere, address never
   taken: the initializer (camera.c:439-440) is the only writer *)
Lemma mcs_never_written :
  direct_writers camera._sMarioCamState = [] /\ addr_takers camera._sMarioCamState = []
  /\ init_addr camera._sMarioCamState = false.
Proof. vm_compute. auto. Qed.

Lemma lcs_never_written :
  direct_writers camera._sLuigiCamState = [] /\ addr_takers camera._sLuigiCamState = []
  /\ init_addr camera._sLuigiCamState = false.
Proof. vm_compute. auto. Qed.

(* ... and their initializers are &gPlayerCameraState[0] / [1] (36 bytes
   apart: sizeof(struct PlayerCameraState)) *)
Lemma mcs_init :
  (prog_defmap camera.prog) ! camera._sMarioCamState
  = Some (Gvar (mkglobvar (tptr (Tstruct camera._PlayerCameraState noattr))
                 [Init_addrof camera._gPlayerCameraState (Ptrofs.repr 0)] false false)).
Proof. vm_compute. reflexivity. Qed.

Lemma lcs_init :
  (prog_defmap camera.prog) ! camera._sLuigiCamState
  = Some (Gvar (mkglobvar (tptr (Tstruct camera._PlayerCameraState noattr))
                 [Init_addrof camera._gPlayerCameraState (Ptrofs.repr 36)] false false)).
Proof. vm_compute. reflexivity. Qed.

(* gSecondCameraFocus: address never taken; its direct writers are
   reset_camera (NULL) and the boss / Bowser code (whomp, King Bob-omb,
   Big Boo, Bowser's collectable, cur_obj_start_cam_event) *)
Lemma scf_writers :
  addr_takers camera._gSecondCameraFocus = [] /\ init_addr camera._gSecondCameraFocus = false.
Proof. vm_compute. auto. Qed.

Definition scf_direct : list ident := direct_writers camera._gSecondCameraFocus.

(* the six direct writers: reset_camera's `gSecondCameraFocus = NULL` and
   five object functions (King Bob-omb, Bowser's collectable, Big Boo
   (obj_set_secondary_camera_focus), Whomp, cur_obj_start_cam_event, the
   last called from Bowser only).  A carried NULL pin needs: none of the
   five object writers runs in WMotR (the objects census: no such kind). *)
Lemma scf_direct_eq : scf_direct =
  [behavior_actions._king_bobomb_act_0; behavior_actions._bowser_spawn_collectable;
   behavior_actions._obj_set_secondary_camera_focus; behavior_actions._whomp_init;
   object_helpers._cur_obj_start_cam_event; camera._reset_camera].
Proof. vm_compute. reflexivity. Qed.

(* gCamera: written only by update_camera and reset_camera (`gCamera = c`) *)
Lemma gcam_writers :
  direct_writers camera._gCamera = [camera._update_camera; camera._reset_camera]
  /\ addr_takers camera._gCamera = [] /\ init_addr camera._gCamera = false.
Proof. vm_compute. auto. Qed.
