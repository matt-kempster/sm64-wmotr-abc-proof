(* ======================================================================= *)
(* GOAL 2: THE WMOTR WORLD INVARIANT.                                        *)
(*                                                                          *)
(* The height rows are about one real execute_mario_action, and that code   *)
(* reads the world: the surfaces Mario stands on / hits, whether he holds   *)
(* or rides an object, his quicksand depth.  Over an ARBITRARY memory the   *)
(* rows are false (a BURNING floor sends Mario to ACT_LAVA_BOOST; a         *)
(* quicksand depth lowers gfx.pos every frame; docs/goal2-value-walk-       *)
(* plan.md §1).  `wmotr_world` says the world is WMotR's:                   *)
(*   - m->wall / m->ceil are NULL or, like m->floor (never NULL), point at *)
(*     a surface whose                                                      *)
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

(* the floor is never NULL at a frame boundary: the frame dereferences it
   (apply_vertical_wind reads m->floor->type), and every step that sets it
   stores a find_floor hit; a NULL find_floor leaves m->floor as it was
   (perform_air_quarter_step, update_mario_geometry_inputs' OOB branch).
   Found by experiments/symexec; the write watch saw no NULL floor at a
   frame end in 11,379 frames. *)
Definition surface_nonnull_ok (m : mem) (v : val) : Prop :=
  exists b o t, v = Vptr b o
    /\ Mem.load Mint16signed m b (Ptrofs.unsigned o) = Some (Vint t)
    /\ In (Int.signed t) wmotr_surface_types.

(* ---- 3. object collisions (the frame reads them in                     *)
(*      mario_process_interactions and update_mario_inputs).  The fields   *)
(*      are the ones experiments/symexec found the whole frame reads;      *)
(*      Phi depends on object memory ONLY through a collided pole's        *)
(*      oPosY / hitboxDownOffset / hitboxHeight and a collided cannon      *)
(*      base's oPosY.                                                       *)
Definition MARIOOBJ_OFF : Z := 136.   (* MarioState.marioObj *)

Definition object_members : members :=
  match (prog_comp_env mario.prog) ! mario._Object with
  | Some co => co_members co
  | None => nil
  end.

Definition NUMCOLL_OFF : Z := 118.    (* Object.numCollidedObjs, s16 *)
Definition COLL_OFF : Z := 120.       (* Object.collidedObjs[4] *)
Definition RAW_OFF : Z := 136.        (* Object.rawData *)
Definition HITBOX_H_OFF : Z := 508.   (* Object.hitboxHeight *)
Definition HITBOX_DOWN_OFF : Z := 520. (* Object.hitboxDownOffset *)
(* rawData slots (object_fields.h): OBJECT_FIELD_*(i) is rawData + 4 i *)
Definition O_POSY : Z := RAW_OFF + 4 * 7.            (* 0xA4 *)
Definition O_INTERACT_TYPE : Z := RAW_OFF + 4 * 42.  (* 0x130 *)
Definition O_INTERACT_STATUS : Z := RAW_OFF + 4 * 43. (* 0x134 *)

Lemma object_field_offsets :
  field_offset (prog_comp_env mario.prog) mario._marioObj mario_state_members = OK (MARIOOBJ_OFF, Full)
  /\ field_offset (prog_comp_env mario.prog) mario._numCollidedObjs object_members = OK (NUMCOLL_OFF, Full)
  /\ field_offset (prog_comp_env mario.prog) mario._collidedObjs object_members = OK (COLL_OFF, Full)
  /\ field_offset (prog_comp_env mario.prog) mario._rawData object_members = OK (RAW_OFF, Full)
  /\ field_offset (prog_comp_env mario.prog) mario._hitboxHeight object_members = OK (HITBOX_H_OFF, Full)
  /\ field_offset (prog_comp_env mario.prog) mario._hitboxDownOffset object_members = OK (HITBOX_DOWN_OFF, Full).
Proof. vm_compute. repeat split. Qed.

(* interaction.h *)
Definition INTERACT_COIN : Z := 16.
Definition INTERACT_CAP : Z := 32.
Definition INTERACT_POLE : Z := 64.
Definition INTERACT_BREAKABLE : Z := 512.
Definition INTERACT_CANNON_BASE : Z := 16384.
Definition INTERACT_TEXT : Z := 8388608.
(* INT_STATUS_MARIO_STUNNED | _KNOCKBACK_DMG | _SHOCKWAVE: the INPUT_STOMPED
   bits (mario.c update_mario_inputs), set only by Bowser / shock waves /
   enemies absent from WMotR (docs/goal2-wmotr-behavior-census.md §3) *)
Definition STOMP_BITS : Z := 19.

(* The interact types of WMotR's collidable objects (docs/goal2-wmotr-
   behavior-census.md): red coins and 1-ups (COIN), the wing cap (CAP), the
   6 poles (POLE), the ! boxes (BREAKABLE), the 2 cannons (CANNON_BASE), the
   bob-omb buddy (TEXT); 0 = no interaction.  A hand census, tethered by
   experiments/oracle/ywatch.py (every collided object at every frame
   entry).  NOT here: the red-coin star (INTERACT_STAR_OR_KEY).  It exists
   only after all 8 red coins, and coin #2 needs y >= 2980 > YMAX
   (TRUST.md 0.3, docs/goal2-coin-star-chain.md); experiments/symexec found
   that collecting it reaches STAR_DANCE_* / FALL_AFTER_STAR_GRAB, which are
   outside R_noA, so this exclusion is load-bearing. *)
Definition wmotr_interact_types : list Z :=
  [0; INTERACT_COIN; INTERACT_CAP; INTERACT_POLE; INTERACT_BREAKABLE;
   INTERACT_CANNON_BASE; INTERACT_TEXT].

Definition f32z (z : Z) : val := Vsingle (Float32.of_int (Int.repr z)).

(* a collided pole is one of the level script's (WMotRLevel §5): oPosY =
   base, hitboxDownOffset = 0 (spawn_object.c), hitboxHeight = top - base
   (pole.inc.c: 10 * bparam2) *)
Definition pole_obj_ok (m : mem) (b : block) (o : Z) : Prop :=
  exists base top, In (base, top) wmotr_pole_list
    /\ Mem.load Mfloat32 m b (o + O_POSY) = Some (f32z base)
    /\ Mem.load Mfloat32 m b (o + HITBOX_DOWN_OFF) = Some (Vsingle Float32.zero)
    /\ Mem.load Mfloat32 m b (o + HITBOX_H_OFF) = Some (f32z (top - base)).

(* a collided cannon base sits at its lid's y - 340 (WMotRLevel §5b), so
   act_in_cannon's seat, oPosY + 350, is in wmotr_cannon_list *)
Definition cannon_obj_ok (m : mem) (b : block) (o : Z) : Prop :=
  exists y, In y wmotr_cannon_list
    /\ Mem.load Mfloat32 m b (o + O_POSY) = Some (f32z (y - CANNON_SEAT)).

Definition coll_obj_ok (m : mem) (v : val) : Prop :=
  exists b o t, v = Vptr b o
    /\ Mem.load Mint32 m b (Ptrofs.unsigned o + O_INTERACT_TYPE) = Some (Vint t)
    /\ In (Int.unsigned t) wmotr_interact_types
    /\ (Int.unsigned t = INTERACT_POLE -> pole_obj_ok m b (Ptrofs.unsigned o))
    /\ (Int.unsigned t = INTERACT_CANNON_BASE -> cannon_obj_ok m b (Ptrofs.unsigned o)).

Definition wmotr_objects (bm : block) (m : mem) : Prop :=
  exists mb mo s n,
    Mem.load Mint32 m bm MARIOOBJ_OFF = Some (Vptr mb mo)
    /\ Mem.load Mint32 m mb (Ptrofs.unsigned mo + O_INTERACT_STATUS) = Some (Vint s)
    /\ Int.and s (Int.repr STOMP_BITS) = Int.zero
    /\ Mem.load Mint16signed m mb (Ptrofs.unsigned mo + NUMCOLL_OFF) = Some (Vint n)
    /\ 0 <= Int.signed n <= 4
    /\ forall i v, 0 <= i < Int.signed n ->
         Mem.load Mint32 m mb (Ptrofs.unsigned mo + COLL_OFF + 4 * i) = Some v ->
         coll_obj_ok m v.

Definition wmotr_world (bm : block) (m : mem) : Prop :=
  (forall v, Mem.load Mint32 m bm WALL_OFF = Some v -> surface_ok m v)
  /\ (forall v, Mem.load Mint32 m bm CEIL_OFF = Some v -> surface_ok m v)
  /\ (forall v, Mem.load Mint32 m bm FLOOR_OFF = Some v -> surface_nonnull_ok m v)
  /\ Mem.load Mint32 m bm HELD_OFF = Some Vnullptr
  /\ Mem.load Mint32 m bm RIDDEN_OFF = Some Vnullptr
  /\ Mem.load Mfloat32 m bm QSD_OFF = Some (Vsingle Float32.zero)
  /\ wmotr_objects bm m.
