(* Reach.v -- the whole-program "formal grep + callgraph" skeleton.
 *
 * Two computable analyses over the entire translation unit `prog`:
 *
 *   direct_writers prog g  -- which internal functions directly assign global g
 *                             (the structural `grep`: "who touches this symbol?")
 *   reaches prog a b        -- can the static call graph get from function a to b
 *                             (the unreachability half of the argument)
 *
 * Both are decidable computations, so concrete facts close by `reflexivity`.
 *
 * SCOPE / honesty (same leaks as Frame.v, now load-bearing):
 *   - direct_writers reuses writes_global, so it sees only Sassign rooted at an
 *     Evar. Indirect writes through pointers/arrays are NOT counted. For the
 *     impossibility *direction* this must become a sound over-approximation
 *     (escape analysis + havoc); see docs/pointer-writes-and-block-disjointness.md.
 *   - reaches follows only direct Scall (Evar _) targets. Indirect calls through
 *     function pointers have no static target and are dropped.
 *   - One TU only: "sole writer in prog" is not yet "sole writer in the program".
 *)

From Coq Require Import List PArith.BinPos.
Import ListNotations.
From compcert Require Import AST Ctypes Clight.
From SM64.Proofs Require Import Frame.
From SM64.Generated Require Import shadow.

(* --- Half 1: the structural grep ------------------------------------------ *)

(* The internal (defined-here) functions of a program, with their idents. *)
Fixpoint internal_funcs (defs : list (ident * globdef fundef type))
  : list (ident * function) :=
  match defs with
  | nil => nil
  | (id, Gfun (Internal f)) :: rest => (id, f) :: internal_funcs rest
  | _ :: rest => internal_funcs rest
  end.

(* Every internal function that DIRECTLY assigns global g. *)
Definition direct_writers (p : program) (g : ident) : list ident :=
  map fst (filter (fun idf => writes_global (snd idf) g) (internal_funcs (prog_defs p))).

(* --- Half 2: the static call graph ---------------------------------------- *)

Fixpoint callees_s (s : statement) : list ident :=
  match s with
  | Scall _ (Evar id _) _ => [id]
  | Ssequence s1 s2     => callees_s s1 ++ callees_s s2
  | Sifthenelse _ s1 s2 => callees_s s1 ++ callees_s s2
  | Sloop s1 s2         => callees_s s1 ++ callees_s s2
  | Slabel _ s1         => callees_s s1
  | Sswitch _ ls        => callees_ls ls
  | _                   => []
  end
with callees_ls (ls : labeled_statements) : list ident :=
  match ls with
  | LSnil           => []
  | LScons _ s rest => callees_s s ++ callees_ls rest
  end.

Definition callees (f : function) : list ident := callees_s (fn_body f).

Fixpoint lookup_func (defs : list (ident * globdef fundef type)) (id : ident)
  : option function :=
  match defs with
  | nil => None
  | (id', Gfun (Internal f)) :: rest =>
      if Pos.eqb id id' then Some f else lookup_func rest id
  | _ :: rest => lookup_func rest id
  end.

Definition func_of (p : program) (id : ident) : option function :=
  lookup_func (prog_defs p) id.

(* Fuel-bounded worklist reachability with a visited set (one node per step,
   so any fuel >= (#nodes) is enough; visited bounds the work and kills cycles). *)
Fixpoint reach (p : program) (fuel : nat) (worklist visited : list ident)
  (target : ident) {struct fuel} : bool :=
  match fuel with
  | O => false
  | S fuel' =>
    match worklist with
    | [] => false
    | id :: rest =>
      if Pos.eqb id target then true
      else if existsb (Pos.eqb id) visited then reach p fuel' rest visited target
      else let next := match func_of p id with Some f => callees f | None => [] end in
           reach p fuel' (next ++ rest) (id :: visited) target
    end
  end.

Definition reaches (p : program) (start target : ident) : bool :=
  reach p 1000 [start] [] target.

(* --- The combined intuition ----------------------------------------------- *)

(* "start's static call graph contains no direct write to g": none of g's direct
   writers is reachable from start (reaches w w = true, so this also rules out
   start itself being a writer). This is the computable shape of the WMotR
   argument -- it is NOT yet the semantic theorem (see SCOPE above). *)
Definition cannot_write_g (p : program) (start g : ident) : bool :=
  forallb (fun w => negb (reaches p start w)) (direct_writers p g).

(* --- Machine-checked facts over the real shadow.c TU ---------------------- *)

(* HALF 1, the formal grep: across all 29 internal functions of the TU, exactly
   one directly assigns sSurfaceTypeBelowShadow. ("grep says one hit", verified.) *)
Example sole_writer_of_surface_type :
  direct_writers prog _sSurfaceTypeBelowShadow = [_create_shadow_below_xyz].
Proof. reflexivity. Qed.

(* HALF 2, the call graph: atan2_deg's only static callee is the external atan2s. *)
Example atan2_deg_calls_only_atan2s :
  callees f_atan2_deg = [_atan2s].
Proof. reflexivity. Qed.

(* ...so atan2_deg cannot statically reach the sole writer, while the writer can
   transitively reach atan2_deg (sanity that `reaches` is not vacuously false). *)
Example atan2_deg_cannot_reach_writer :
  reaches prog _atan2_deg _create_shadow_below_xyz = false.
Proof. reflexivity. Qed.

Example writer_reaches_atan2_deg :
  reaches prog _create_shadow_below_xyz _atan2_deg = true.
Proof. reflexivity. Qed.

(* The two halves combined: atan2_deg's static call graph contains no direct
   write to sSurfaceTypeBelowShadow. (Syntactic over the leaks noted above.) *)
Example atan2_deg_cannot_write_surface_type :
  cannot_write_g prog _atan2_deg _sSurfaceTypeBelowShadow = true.
Proof. reflexivity. Qed.

(* And the honest negative: the sole writer obviously *can* write it. *)
Example writer_can_write_surface_type :
  cannot_write_g prog _create_shadow_below_xyz _sSurfaceTypeBelowShadow = false.
Proof. reflexivity. Qed.
