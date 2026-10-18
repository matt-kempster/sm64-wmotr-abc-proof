(* playground: measure SymExec2 on the real perform_air_step, with the
   proved contract table AirXc.air_xc (every contract sound: air_xc_sound). *)
From Coq Require Import List ZArith String.
From compcert Require Import Coqlib Maps AST Integers Floats Values Memory Ctypes Clight Errors.
From SM64.Generated Require mario_step mario surface_collision.
From SM64.Proofs Require Import Interp.SymExec2 LinkGenv WMotRRequiresA.Unwired.FloorExec
  WMotRRequiresA.Unwired.CeilExec WMotRRequiresA.Unwired.WallExec WMotRRequiresA.Unwired.AirXc.
Import ListNotations.
Local Notation "'let?' x := a 'in' b" :=
  (match a with Some x => b | None => None end)
  (at level 200, x ident, a at level 100, b at level 200).

Definition tfloat := Tfloat F32 noattr.

Section LAB.
Variable g : genv.

Definition fo (s f : ident) : Z :=
  match (genv_cenv g) ! s with
  | Some co => match field_offset g f (co_members co) with OK (d, _) => d | _ => -1 end
  | None => -1
  end.
Definition szs (s : ident) : Z := sizeof g (Tstruct s noattr).

Definition NB : positive := 10.
Definition RM : positive := 1.
Definition RO : positive := 2.
(* find_floor's statics: gFindFloorIncludeSurfaceIntangible (short),
   gNumFindFloorMisses (int), gNumCalls (3 shorts) *)
Definition RFI : positive := 4.
Definition RMISS : positive := 5.
Definition RCALLS : positive := 6.
Definition R0 : list (positive * Z) := [(RM, szs mario._MarioState); (RO, szs mario._Object); (3%positive, 12);
  (RFI, 2); (RMISS, 4); (RCALLS, 6)].
Definition gtab : list (ident * positive) :=
  [(surface_collision._gFindFloorIncludeSurfaceIntangible, RFI);
   (surface_collision._gNumFindFloorMisses, RMISS); (surface_collision._gNumCalls, RCALLS)].
Definition kv : list (positive * Z * memory_chunk * sval) :=
  [ (RM, fo mario._MarioState mario._marioObj, Mint32, Sptr RO Ptrofs.zero);
    (RM, 12, Mint32, Sconst (Vint (Int.repr 16779404))) ].

(* vec3f_copy / vec3s_set: no contract -- math_util is linked, so the executor
   inlines their REAL bodies.  atan2s gets xc_fresh: inlining fails
   (atan2_lookup reads gArctanTable at a symbolic index). *)
(* the world fact the surface contracts need (FloorExec.Wff over the consumer's regions) *)
Definition kW : positive := 1.
(* the PROVED contract table (AirXc.air_xc_sound) *)
Definition xc : ident -> option xcontract :=
  air_xc NB R0 RFI RMISS RCALLS kW (szs mario._Surface).

(* key cells: action, actionState, actionTimer, pos[1], vel[1], floorHeight, gfx.pos[1] *)
Definition jkeys : list (positive * Z * memory_chunk) :=
  [(RM, 12, Mint32); (RM, 24, Mint16unsigned); (RM, 26, Mint16unsigned);
   (RM, 64, Mfloat32); (RM, 76, Mfloat32); (RM, 112, Mfloat32); (RO, 36, Mfloat32)].

Definition mergef (id : ident) : bool :=
  Pos.eqb id mario_step._perform_air_quarter_step || Pos.eqb id mario._resolve_and_return_wall_collisions.

Definition pc0 : list fact :=
  [Fuser kW (wargs R0); Fbits (Sinit RM 2 Mint16unsigned) (Int.repr 130);
   Fworld (Sinit RM (fo mario._MarioState mario._floor) Mint32) (szs mario._Surface);
   Fworld (Sinit RM (fo mario._MarioState mario._area) Mint32) (szs mario._Area)]
  (* the entry floor is a WMotR surface (WMotRWorld.surface_nonnull_ok) *)
  ++ ffacts (Sinit RM (fo mario._MarioState mario._floor) Mint32).

Definition g0 : gst := mkg nil pc0 NB nil.

Definition run (jl : bool) (mg : bool) :=
  sx_call g NB R0 gtab kv xc jkeys (fun id => mg && mergef id) jl 400 g0
          (Internal mario_step.f_perform_air_step) [Sptr RM Ptrofs.zero; Sconst (Vint Int.zero)].
End LAB.

Definition res (jl mg : bool) := match ge12 with Some g => run g jl mg | None => None end.

Time Eval vm_compute in (match ge12 with Some g => Some (fo g mario._MarioState mario._floor, fo g mario._MarioState mario._area, szs g mario._Surface, szs g mario._WallCollisionData, fo g mario._WallCollisionData mario._numWalls) | None => None end).
Definition R0x (g : genv) := R0 g.
Definition runf (f : function) (args : list sval) :=
  match ge12 with Some g => sx_call g NB (R0x g) gtab (kv g) (xc g) jkeys (fun id => mergef id) true 400 (g0 g) (Internal f) args | None => None end.
Definition MP := Sptr RM Ptrofs.zero.
Definition PP := Sptr 3 Ptrofs.zero.

Section DBG.
Variable g : genv.
Let SX := sx_stmt g NB (R0x g) gtab (kv g) (xc g) jkeys mergef true.
Fixpoint first_normal (ps : list spath) : option (PTree.t sval * gst) :=
  match ps with nil => None | (le, s, SOnormal) :: _ => Some (le, s) | _ :: ps' => first_normal ps' end.
Fixpoint dbg (d : nat) (se : PTree.t (positive * type)) (le : PTree.t sval) (st : gst) (s : statement)
  : option (statement * PTree.t sval * gst) :=
  match d with O => Some (s, le, st) | S d' =>
  match s with
  | Ssequence s1 s2 =>
      match SX 400 se le st s1 with
      | None => dbg d' se le st s1
      | Some ps =>
          (fix go (ps : list spath) := match ps with
             | nil => None
             | (le', st', SOnormal) :: ps' =>
                 match SX 400 se le' st' s2 with
                 | None => dbg d' se le' st' s2
                 | Some _ => go ps' end
             | _ :: ps' => go ps' end) ps
      end
  | Sifthenelse a s1 s2 =>
      match sx_expr g NB (R0x g) gtab (kv g) se le st a with
      | None => Some (s, le, st)
      | Some c =>
          match decide (g_pc st) c (typeof a) with
          | Some b => dbg d' se le st (if b then s1 else s2)
          | None => match SX 400 se le (add_fact st (Fbool c (typeof a) true)) s1 with
                    | None => dbg d' se le (add_fact st (Fbool c (typeof a) true)) s1
                    | Some _ => dbg d' se le (add_fact st (Fbool c (typeof a) false)) s2 end
          end
      end
  | Sloop s1 s2 => match SX 400 se le st s1 with None => dbg d' se le st s1 | Some _ => Some (s, le, st) end
  | _ => Some (s, le, st)
  end end.
Definition dbgf (f : function) (args : list sval) :=
  let '(se, st1) := salloc f.(fn_vars) (PTree.empty _) (g0 g) in
  match sbind f.(fn_params) args (sundef f.(fn_temps)) with
  | Some le => dbg 200 se le st1 f.(fn_body) | None => None end.
End DBG.
Definition dbg_top (f : function) (args : list sval) :=
  match ge12 with Some g => match dbgf g f args with Some (s, le, st) => Some (s, PTree.elements le, st) | None => None end | None => None end.
Time Eval vm_compute in option_map (@List.length _) (runf mario_step.f_perform_air_quarter_step [MP; PP; Sconst (Vint Int.zero)]).
Time Eval vm_compute in option_map (@List.length _) (runf mario_step.f_apply_gravity [MP]).
Time Eval vm_compute in (option_map (@List.length _) (res true true)).

(* the call-site join on the whole step's outcomes (anti-unification joins):
   760 raw outcomes; 43 keyed on [jkeys]; 3 keyed on the action cells only
   (7328 / 225 / 4 before the surface-type facts, 2026-10-18) *)
Definition jg (ks : list (positive * Z * memory_chunk)) (cs : list cpath) :=
  match ge12 with Some g => jgroup_c NB (R0x g) (kv g) ks cs | None => None end.
Definition ka : list (positive * Z * memory_chunk) :=
  [(RM, 12, Mint32); (RM, 24, Mint16unsigned); (RM, 26, Mint16unsigned)].
Time Eval vm_compute in (match res true true with Some cs => option_map (@List.length _) (jg jkeys cs) | None => None end).
Time Eval vm_compute in (match res true true with Some cs => option_map (@List.length _) (jg ka cs) | None => None end).
