(* ======================================================================= *)
(* GOAL 2: THE WMOTR WORLD INVARIANT.                                        *)
(*                                                                          *)
(* The height rows are about one real execute_mario_action, and that code   *)
(* reads the world: the surfaces Mario stands on / hits, whether he holds   *)
(* or rides an object, his quicksand depth.  Over an ARBITRARY memory the   *)
(* rows are false (a BURNING floor sends Mario to ACT_LAVA_BOOST; a         *)
(* quicksand depth lowers gfx.pos every frame; docs/goal2-value-walk-       *)
(* plan.md §1).  `wmotr_world` says the world is WMotR's:                   *)
(*   - m->wall / m->ceil / m->floor are NULL or point at a surface whose    *)
(*     type is one of the types WMotR's collision data uses (computed from  *)
(*     the generated terrain and object meshes, not listed by hand);        *)
(*   - no held and no ridden object (WMotR has nothing grabbable or         *)
(*     rideable: the buddy is holdable-flagged but INTERACT_TEXT);          *)
(*   - quicksandDepth = 0 (no quicksand surface type in the level).         *)
(* It is carried by the run next to Phi.  Its preservation by the Mario     *)
(* frame is a row (HeightFrame.Hframe_keeps_world); by the flanks, part of  *)
(* their specs (TRUST.md 0.7).  Object collisions are the next conjunct,    *)
(* once the symbolic walk says what the frame reads from them.              *)
(* ======================================================================= *)

From Coq Require Import ZArith List Bool.
From compcert Require Import Coqlib Errors Maps Integers Floats AST Values Memory Ctypes.
From SM64.Generated Require mario.
From SM64.Proofs Require Import Generic.SymbolicLinking.
From SM64.Proofs.WMotRRequiresA Require Import WMotRLevel.
Import ListNotations.

Local Open Scope Z_scope.

(* ---- the MarioState fields, pinned against mario.c's own composite ---- *)
Definition WALL_OFF : Z := 96.
Definition CEIL_OFF : Z := 100.
Definition FLOOR_OFF : Z := 104.
Definition HELD_OFF : Z := 124.
Definition RIDDEN_OFF : Z := 132.
Definition QSD_OFF : Z := 192.

Lemma world_field_offsets :
  field_offset (prog_comp_env mario.prog) mario._wall mario_state_members = OK (WALL_OFF, Full)
  /\ field_offset (prog_comp_env mario.prog) mario._ceil mario_state_members = OK (CEIL_OFF, Full)
  /\ field_offset (prog_comp_env mario.prog) mario._floor mario_state_members = OK (FLOOR_OFF, Full)
  /\ field_offset (prog_comp_env mario.prog) mario._heldObj mario_state_members = OK (HELD_OFF, Full)
  /\ field_offset (prog_comp_env mario.prog) mario._riddenObj mario_state_members = OK (RIDDEN_OFF, Full)
  /\ field_offset (prog_comp_env mario.prog) mario._quicksandDepth mario_state_members = OK (QSD_OFF, Full).
Proof. vm_compute. repeat split. Qed.

(* Surface.type is the first member (s16, offset 0) *)
Definition surface_members : members :=
  match (prog_comp_env mario.prog) ! mario._Surface with
  | Some co => co_members co
  | None => nil
  end.

Lemma surface_type_offset :
  field_offset (prog_comp_env mario.prog) mario._type surface_members = OK (0, Full).
Proof. vm_compute. reflexivity. Qed.

(* ---- WMotR's surface types, from the generated collision data ---- *)
Definition nodup_z (l : list Z) : list Z :=
  fold_right (fun x acc => if existsb (Z.eqb x) acc then acc else x :: acc) nil l.

Definition wmotr_surface_types : list Z :=
  nodup_z (map t_type (static_tris ++ parse (shorts box_init) ++ parse (shorts lid_init))).

(* SURFACE_DEFAULT 0, SURFACE_HANGABLE 5, SURFACE_DEATH_PLANE 10,
   SURFACE_NOT_SLIPPERY 21, SURFACE_HARD_NOT_SLIPPERY 55 (surface_terrains.h);
   in particular no BURNING (1), no wind (12/56), no quicksand, no warps *)
Lemma wmotr_surface_types_value : wmotr_surface_types = [5; 10; 21; 55; 0].
Proof. vm_compute. reflexivity. Qed.

(* ---- the invariant ---- *)
Definition surface_ok (m : mem) (v : val) : Prop :=
  v = Vnullptr
  \/ exists b o t, v = Vptr b o
       /\ Mem.load Mint16signed m b (Ptrofs.unsigned o) = Some (Vint t)
       /\ In (Int.signed t) wmotr_surface_types.

Definition wmotr_world (bm : block) (m : mem) : Prop :=
  (forall v, Mem.load Mint32 m bm WALL_OFF = Some v -> surface_ok m v)
  /\ (forall v, Mem.load Mint32 m bm CEIL_OFF = Some v -> surface_ok m v)
  /\ (forall v, Mem.load Mint32 m bm FLOOR_OFF = Some v -> surface_ok m v)
  /\ Mem.load Mint32 m bm HELD_OFF = Some Vnullptr
  /\ Mem.load Mint32 m bm RIDDEN_OFF = Some Vnullptr
  /\ Mem.load Mfloat32 m bm QSD_OFF = Some (Vsingle Float32.zero).
