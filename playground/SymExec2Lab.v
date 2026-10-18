(* playground: measure SymExec2 on the real perform_air_step.
   The contracts here are STAND-INS for measurement only (not proved). *)
From Coq Require Import List ZArith String.
From compcert Require Import Coqlib Maps AST Integers Floats Values Memory Ctypes Clight Errors.
From SM64.Generated Require mario_step mario.
From SM64.Proofs Require Import Interp.SymExec2 LinkGenv.
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
Definition R0 : list (positive * Z) := [(RM, szs mario._MarioState); (RO, szs mario._Object); (3%positive, 12)].
Definition gtab : list (ident * positive) := nil.
Definition kv : list (positive * Z * memory_chunk * sval) :=
  [ (RM, fo mario._MarioState mario._marioObj, Mint32, Sptr RO Ptrofs.zero);
    (RM, 12, Mint32, Sconst (Vint (Int.repr 16779404))) ].

Definition fresh (s : gst) : sval * gst :=
  (Sfresh (g_nx s), mkg (g_sm s) (g_pc s) (Pos.succ (g_nx s)) (g_loc s)).

Definition ldl (s : gst) (l : sloc) (ch : memory_chunk) : option sval :=
  match l with
  | Lreg r o => sload NB R0 kv s r (Ptrofs.unsigned o) ch
  | Lwld q k => wload s q k ch
  end.
Definition stl (s : gst) (l : sloc) (ch : memory_chunk) (v : sval) : option gst :=
  match l with
  | Lreg r o => sstore NB R0 s r (Ptrofs.unsigned o) ch v
  | Lwld _ _ => None
  end.
Definition addf (s : gst) (f : fact) : gst := mkg (g_sm s) (f :: g_pc s) (g_nx s) (g_loc s).

Definition c_vec3f_copy : xcontract := fun args s =>
  match args with
  | [d; src] =>
      let ls := loc_of src in let ld := loc_of d in
      let? a := ldl s ls Mfloat32 in
      let? b := ldl s (loc_add ls 4) Mfloat32 in
      let? c := ldl s (loc_add ls 8) Mfloat32 in
      let? s1 := stl s ld Mfloat32 a in
      let? s2 := stl s1 (loc_add ld 4) Mfloat32 b in
      let? s3 := stl s2 (loc_add ld 8) Mfloat32 c in
      Some [(s3, d)]
  | _ => None
  end.

Definition c_vec3s_set : xcontract := fun args s =>
  match args with
  | [d; x; y; z] =>
      let ld := loc_of d in
      let? s1 := stl s ld Mint16signed (mk_ldres Mint16signed x) in
      let? s2 := stl s1 (loc_add ld 2) Mint16signed (mk_ldres Mint16signed y) in
      let? s3 := stl s2 (loc_add ld 4) Mint16signed (mk_ldres Mint16signed z) in
      Some [(s3, d)]
  | _ => None
  end.

(* height result, surface out-param: NULL + default height, or a world surface *)
Definition c_find_surf (dflt : float32) (pidx : nat) : xcontract := fun args s =>
  let? p := nth_error args pidx in
  let lp := loc_of p in
  let? s0 := stl s lp Mint32 (Sconst (Vint Int.zero)) in
  let '(f, s1) := fresh s in
  let '(h, s2) := fresh s1 in
  let? s3 := stl s2 lp Mint32 f in
  Some [(s0, Sconst (Vsingle dflt)); (addf s3 (Fworld f (szs mario._Surface)), h)].

Definition c_water : xcontract := fun args s =>
  Some [(s, Sconst (Vsingle (Float32.of_int (Int.repr (-11000)))))].

Definition c_fresh : xcontract := fun args s => let '(h, s1) := fresh s in Some [(s1, h)].

Fixpoint walls_out (n : nat) (lw : sloc) (s : gst) : option gst :=
  match n with
  | O => Some s
  | S n' =>
      let '(w, s1) := fresh s in
      let? s2 := stl s1 (loc_add lw (4 * Z.of_nat n')) Mint32 w in
      walls_out n' lw (addf s2 (Fworld w (szs mario._Surface)))
  end.

Definition c_walls : xcontract := fun args s =>
  match args with
  | [p] =>
      let l := loc_of p in
      let '(x, s1) := fresh s in
      let '(z, s2) := fresh s1 in
      let? s3 := stl s2 l Mfloat32 x in
      let? s4 := stl s3 (loc_add l 8) Mfloat32 z in
      omap (fun n =>
              let? s5 := stl s4 (loc_add l 22) Mint16signed (Sconst (Vint (Int.repr (Z.of_nat n)))) in
              let? s6 := walls_out n (loc_add l 24) s5 in
              Some (s6, Sconst (Vint (Int.repr (Z.of_nat n))))) [0; 1; 2; 3; 4]%nat
  | _ => None
  end.

(* vec3f_copy / vec3s_set: no contract -- math_util is linked (2026-10-17), so
   the executor inlines their REAL bodies (same 7328 outcomes as the old
   stand-ins).  atan2s keeps c_fresh: inlining fails (atan2_lookup reads
   gArctanTable at a symbolic index), but the contract itself -- memory
   unchanged, some result -- is what MathBodies.cpure2_funcall_memid proves. *)
Definition xc (id : ident) : option xcontract :=
  if Pos.eqb id mario._find_floor then Some (c_find_surf (Float32.of_int (Int.repr (-11000))) 3)
  else if Pos.eqb id mario._vec3f_find_ceil then Some (c_find_surf (Float32.of_int (Int.repr 20000)) 2)
  else if Pos.eqb id mario._find_water_level then Some xc_fresh
  else if Pos.eqb id mario._atan2s then Some xc_fresh
  else if Pos.eqb id mario._mario_get_terrain_sound_addend then Some c_fresh
  else if Pos.eqb id mario._find_wall_collisions then Some c_walls
  else None.

(* key cells: action, actionState, actionTimer, pos[1], vel[1], floorHeight, gfx.pos[1] *)
Definition jkeys : list (positive * Z * memory_chunk) :=
  [(RM, 12, Mint32); (RM, 24, Mint16unsigned); (RM, 26, Mint16unsigned);
   (RM, 64, Mfloat32); (RM, 76, Mfloat32); (RM, 112, Mfloat32); (RO, 36, Mfloat32)].

Definition mergef (id : ident) : bool :=
  Pos.eqb id mario_step._perform_air_quarter_step || Pos.eqb id mario._resolve_and_return_wall_collisions.

Definition pc0 : list fact :=
  [Fbits (Sinit RM 2 Mint16unsigned) (Int.repr 130);
   Fworld (Sinit RM (fo mario._MarioState mario._floor) Mint32) (szs mario._Surface);
   Fworld (Sinit RM (fo mario._MarioState mario._area) Mint32) (szs mario._Area)].

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
   7328 raw outcomes; 225 keyed on [jkeys]; 4 keyed on the action cells only *)
Definition jg (ks : list (positive * Z * memory_chunk)) (cs : list cpath) :=
  match ge12 with Some g => jgroup_c NB (R0x g) (kv g) ks cs | None => None end.
Definition ka : list (positive * Z * memory_chunk) :=
  [(RM, 12, Mint32); (RM, 24, Mint16unsigned); (RM, 26, Mint16unsigned)].
Time Eval vm_compute in (match res true true with Some cs => option_map (@List.length _) (jg jkeys cs) | None => None end).
Time Eval vm_compute in (match res true true with Some cs => option_map (@List.length _) (jg ka cs) | None => None end).
