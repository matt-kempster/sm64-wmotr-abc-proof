(* ======================================================================= *)
(* GOAL 2: WMotR's level data, read off the generated AST.                  *)
(*                                                                          *)
(* The move catalog (HeightMoveCatalog.v) is parameterized by two level     *)
(* predicates, the floors Mario can land on and the poles he can grab.      *)
(* This file DEFINES them from clightgen'd data and PROVES the two          *)
(* level-data rows HeightFrame used to assume:                              *)
(*                                                                          *)
(*   wmotr_floor h   h is within a floor triangle's y-range: a static       *)
(*                   WMotR terrain triangle (+-1 for the binary32 plane     *)
(*                   evaluation), or the top of a collision-bearing macro   *)
(*                   object (exclamation box, scale 2; cannon lid).         *)
(*   wmotr_pole b t  a bhvPoleGrabbing OBJECT of WMotR's level script,      *)
(*                   base b, top t = b + hitboxHeight (= 10 * bparam2).     *)
(*   wmotr_gap_proved    no floor height in (K, K + GAP).                   *)
(*   wmotr_poles_proved  every pole is low (top <= K) or out of reach       *)
(*                       (YMAX < base - 160).                               *)
(*                                                                          *)
(* Data: generated/wmotr_level_data.v (terrain, macro list, the two object  *)
(* meshes), generated/wmotr_script.v (the level script), generated/         *)
(* macro_special_objects.v (the preset -> behavior table).  The decoders    *)
(* below mirror surface_load.c / macro_special_objects.c; what they do NOT  *)
(* establish (that find_floor returns heights of exactly these surfaces;    *)
(* which behaviors load collision) is TRUST.md 0.8.                         *)
(* ======================================================================= *)

From Coq Require Import ZArith List Bool Reals Lra Lia.
From compcert Require Import Coqlib Integers AST.
From SM64.Generated Require wmotr_level_data wmotr_script macro_special_objects.
From SM64.Proofs Require Import HeightInvariant HeightBudgetArith.
Import ListNotations.

Local Open Scope Z_scope.

(* ----------------------------------------------------------------------- *)
(* 1. Reading the initializers.                                             *)
(* ----------------------------------------------------------------------- *)
(* a TerrainData / MacroObject array: each Init_int16 is one s16 *)
Fixpoint shorts (l : list init_data) : list Z :=
  match l with
  | Init_int16 i :: r => Int.signed i :: shorts r
  | _ :: r => shorts r
  | nil => nil
  end.

Definition all_int16 (l : list init_data) : bool :=
  forallb (fun d => match d with Init_int16 _ => true | _ => false end) l.

Definition collision_init := gvar_init wmotr_level_data.v_wmotr_seg7_collision.
Definition macro_init := gvar_init wmotr_level_data.v_wmotr_seg7_macro_objs.
Definition box_init :=
  gvar_init wmotr_level_data.v_exclamation_box_outline_seg8_collision_08025F78.
Definition lid_init := gvar_init wmotr_level_data.v_cannon_lid_seg8_collision_08004950.

(* nothing is dropped by `shorts` *)
Lemma level_arrays_all_int16 :
  all_int16 collision_init = true /\ all_int16 macro_init = true /\
  all_int16 box_init = true /\ all_int16 lid_init = true.
Proof. vm_compute. auto. Qed.

(* ----------------------------------------------------------------------- *)
(* 2. Terrain: load_area_terrain / load_static_surfaces / read_vertex_data  *)
(*    (surface_load.c:431-468, 473-490, 585-622).                           *)
(* ----------------------------------------------------------------------- *)
Definition vtx : Type := (Z * Z * Z)%type.
Record tri := mk_tri { t_type : Z; t_v1 : vtx; t_v2 : vtx; t_v3 : vtx }.

(* surface_has_force (surface_load.c:384-403; ids surface_terrains.h) *)
Definition has_force (ty : Z) : bool :=
  existsb (Z.eqb ty) [4; 14; 36; 37; 39; 44; 45].

Fixpoint verts (n : nat) (d : list Z) : list vtx :=
  match n, d with
  | S n', x :: y :: z :: r => (x, y, z) :: verts n' r
  | _, _ => nil
  end.

(* an out-of-range index makes the parse FAIL, so a successful parse
   certifies every index (the game does no bounds check) *)
Definition vat (vs : list vtx) (i : Z) : option vtx :=
  if i <? 0 then None else nth_error vs (Z.to_nat i).

Fixpoint take_tris (n : nat) (ty : Z) (vs : list vtx) (d : list Z)
  : option (list tri * list Z) :=
  match n with
  | O => Some (nil, d)
  | S n' =>
      match d with
      | a :: b :: c :: r =>
          let r' := if has_force ty then tl r else r in
          match vat vs a, vat vs b, vat vs c, take_tris n' ty vs r' with
          | Some va, Some vb, Some vc, Some (ts, rest) => Some (mk_tri ty va vb vc :: ts, rest)
          | _, _, _, _ => None
          end
      | _ => None
      end
  end.

(* The loop.  0x43 (TERRAIN_LOAD_OBJECTS) STOPS the parse and returns the
   rest; `terrain_tail` below pins that rest to the special-object list
   followed by TERRAIN_LOAD_END, so no surface follows it.  0x44
   (environment regions: water) fails loudly -- WMotR has none. *)
Fixpoint parse_terrain (fuel : nat) (vs : list vtx) (d : list Z)
  : option (list tri * list Z) :=
  match fuel with
  | O => None
  | S f =>
      match d with
      | nil => None
      | t :: r =>
          if (t <? 64) || (101 <=? t) then
            match r with
            | n :: r' =>
                match take_tris (Z.to_nat n) t vs r' with
                | Some (ts, r'') =>
                    match parse_terrain f vs r'' with
                    | Some (ts', rest) => Some (ts ++ ts', rest)
                    | None => None
                    end
                | None => None
                end
            | nil => None
            end
          else if t =? 64 then
            match r with
            | n :: r' => parse_terrain f (verts (Z.to_nat n) r') (skipn (Z.to_nat (3 * n)) r')
            | nil => None
            end
          else if t =? 65 then parse_terrain f vs r
          else if t =? 66 then Some (nil, nil)
          else if t =? 67 then Some (nil, d)
          else None
      end
  end.

Definition parse (d : list Z) : list tri :=
  match parse_terrain 100000 nil d with Some (ts, _) => ts | None => nil end.

Definition static_tris : list tri := parse (shorts collision_init).

(* the parse SUCCEEDS on the real data (so static_tris is not a vacuous nil),
   and what follows TERRAIN_LOAD_OBJECTS is the one special object
   (special_null_start at the spawn, collision.inc.c:2057-2058) and END *)
Lemma terrain_tail :
  exists ts, parse_terrain 100000 nil (shorts collision_init)
             = Some (ts, [67; 1; 0; -67; 1669; -16; 192; 66]).
Proof. vm_compute. eexists. reflexivity. Qed.

(* ----------------------------------------------------------------------- *)
(* 3. Floors.  A floor is a surface with normal.y > 0.01 (surface_load.c:   *)
(*    113); normal.y has the sign of the integer cross product ny below,    *)
(*    so `0 < ny` is a SUPERSET of the floors -- no float is needed.        *)
(* ----------------------------------------------------------------------- *)
Definition tri_ny (t : tri) : Z :=
  let '(x1, _, z1) := t_v1 t in
  let '(x2, _, z2) := t_v2 t in
  let '(x3, _, z3) := t_v3 t in
  (z2 - z1) * (x3 - x2) - (x2 - x1) * (z3 - z2).

Definition vy (v : vtx) : Z := let '(_, y, _) := v in y.
Definition tri_ylo (t : tri) : Z := Z.min (vy (t_v1 t)) (Z.min (vy (t_v2 t)) (vy (t_v3 t))).
Definition tri_yhi (t : tri) : Z := Z.max (vy (t_v1 t)) (Z.max (vy (t_v2 t)) (vy (t_v3 t))).

Definition is_floor (t : tri) : bool := 0 <? tri_ny t.

(* cross-check against tools/goal2_ladder.py: 1352 triangles, 778 floors *)

Lemma static_counts :
  length static_tris = 1352%nat /\ length (filter is_floor static_tris) = 778%nat.
Proof. vm_compute. split; reflexivity. Qed.

(* ----------------------------------------------------------------------- *)
(* 4. Macro objects (spawn_macro_objects, macro_special_objects.c:114-160)  *)
(*    and the collision-bearing ones.                                       *)
(* ----------------------------------------------------------------------- *)
Record mobj := mk_mobj { m_preset : Z; m_x : Z; m_y : Z; m_z : Z; m_param : Z }.

(* ends at -1 or at a negative preset id (both `break`s); the respawn
   filter is ignored, so this is a superset of the spawned objects *)
Fixpoint macro_objs (d : list Z) : list mobj :=
  match d with
  | h :: x :: y :: z :: p :: r =>
      if h =? -1 then nil
      else let pid := Z.land h 511 - 31 in
           if pid <? 0 then nil else mk_mobj pid x y z p :: macro_objs r
  | _ => nil
  end.

Definition wmotr_macro_objs : list mobj := macro_objs (shorts macro_init).

(* sMacroObjectPresets: { behavior; model; param } *)
Fixpoint preset_bhvs (l : list init_data) : list ident :=
  match l with
  | Init_addrof b _ :: _ :: _ :: r => b :: preset_bhvs r
  | _ => nil
  end.

Definition presets : list ident :=
  preset_bhvs (gvar_init macro_special_objects.v_sMacroObjectPresets).

Definition bhv_of (o : mobj) : ident := nth (Z.to_nat (m_preset o)) presets 1%positive.

(* TRUST.md 0.8 census (behavior_data.c): of the behaviors WMotR spawns,
   exactly these LOAD_COLLISION_DATA; the box runs cur_obj_scale(2.0f)
   every frame (exclamation_box.inc.c:176), which transform_object_vertices
   applies (surface_load.c:680).  Mesh vertex y scales, the object's
   (x,z)-only rotation leaves y alone. *)
Definition collision_of (b : ident) : option (list Z * Z) :=
  if Pos.eqb b macro_special_objects._bhvExclamationBox then Some (shorts box_init, 2)
  else if Pos.eqb b macro_special_objects._bhvCannonClosed then Some (shorts lid_init, 1)
  else None.

(* an object's floor triangles, heights already placed: (lo, hi) *)
Definition obj_floor_ranges (o : mobj) : list (Z * Z) :=
  match collision_of (bhv_of o) with
  | Some (mesh, s) =>
      map (fun t => (m_y o + s * tri_ylo t, m_y o + s * tri_yhi t))
          (filter is_floor (parse mesh))
  | None => nil
  end.

Definition object_floor_ranges : list (Z * Z) := flat_map obj_floor_ranges wmotr_macro_objs.

(* non-vacuity / cross-check: 26 macro objects; the 7 boxes (top faces,
   2 floor triangles each) and 2 cannon lids give 18 floor ranges *)
Lemma object_counts :
  length wmotr_macro_objs = 26%nat /\ length object_floor_ranges = 18%nat.
Proof. vm_compute. split; reflexivity. Qed.

(* ----------------------------------------------------------------------- *)
(* 5. Poles: the bhvPoleGrabbing OBJECTs of the level script.               *)
(*    OBJECT = 6 words (level_commands.h): header, x|y, z|rx, ry|rz,        *)
(*    bparams, behavior.  hitboxHeight = 10 * bparam2 (pole.inc.c:20-21).   *)
(* ----------------------------------------------------------------------- *)
Definition s16_lo (w : Z) : Z := let v := Z.land w 65535 in if v <? 32768 then v else v - 65536.

Fixpoint script_poles (l : list init_data) : list (Z * Z) :=
  match l with
  | Init_int32 _ :: Init_int32 xy :: Init_int32 _ :: Init_int32 _ :: Init_int32 bp
      :: Init_addrof b _ :: r =>
      if Pos.eqb b wmotr_script._bhvPoleGrabbing
      then (s16_lo (Int.unsigned xy), Z.land (Z.shiftr (Int.unsigned bp) 16) 255) :: script_poles r
      else script_poles r
  | _ :: r => script_poles r
  | nil => nil
  end.

(* (base, top) *)
Definition wmotr_pole_list : list (Z * Z) :=
  map (fun '(y, b2) => (y, y + 10 * b2))
      (script_poles (gvar_init wmotr_script.v_script_func_local_1)).

Lemma pole_list_value :
  wmotr_pole_list = [(-2739, -1919); (3564, 4404); (3359, 4409);
                     (3154, 4404); (4048, 4408); (3636, 4406)].
Proof. vm_compute. reflexivity. Qed.

(* the level really loads these arrays: level_wmotr_entry's TERRAIN,
   MACRO_OBJECTS and JUMP_LINK commands point at them (script.c:57-60) *)
Definition refs (l : list init_data) (id : ident) : bool :=
  existsb (fun d => match d with Init_addrof b _ => Pos.eqb b id | _ => false end) l.

Lemma level_entry_loads :
  let e := gvar_init wmotr_script.v_level_wmotr_entry in
  refs e wmotr_script._wmotr_seg7_collision = true /\
  refs e wmotr_script._wmotr_seg7_macro_objs = true /\
  refs e wmotr_script._script_func_local_1 = true.
Proof. vm_compute. auto. Qed.

(* bhvPoleGrabbing is referenced by no other array of the level script *)
Lemma poles_only_in_local_1 :
  forallb (fun v => negb (refs (gvar_init v) wmotr_script._bhvPoleGrabbing))
    [wmotr_script.v_level_wmotr_entry; wmotr_script.v_script_func_local_2] = true.
Proof. vm_compute. reflexivity. Qed.

(* ----------------------------------------------------------------------- *)
(* 6. The predicates HeightMoveCatalog consumes, and the two rows.          *)
(* ----------------------------------------------------------------------- *)
Local Open Scope R_scope.

(* stated over ANY lists, so the kernel never unfolds the level data when
   checking the theorems below (it overflows); the data enters only through
   the vm_compute'd boolean checks *)
Definition floor_in (L : list tri) (O : list (Z * Z)) (h : R) : Prop :=
  (exists t, In t L /\ is_floor t = true /\
             IZR (tri_ylo t) - 1 <= h <= IZR (tri_yhi t) + 1)
  \/ (exists lo hi, In (lo, hi) O /\ IZR lo <= h <= IZR hi).

Definition pole_in (P : list (Z * Z)) (base top : R) : Prop :=
  exists b t, In (b, t) P /\ base = IZR b /\ top = IZR t.

Definition gap_check_static (L : list tri) : bool :=
  forallb (fun t => negb (is_floor t) || (tri_yhi t + 1 <=? 2424)%Z
                    || (2424 + 622 <=? tri_ylo t - 1)%Z) L.
Definition gap_check_objects (O : list (Z * Z)) : bool :=
  forallb (fun '(lo, hi) => (hi <=? 2424)%Z || (2424 + 622 <=? lo)%Z) O.
Definition pole_check (P : list (Z * Z)) : bool :=
  forallb (fun '(b, t) => (t <=? 2424)%Z || (2796 <? b - 160)%Z) P.

Lemma K_val : PHI_K = 2424. Proof. reflexivity. Qed.
Lemma YMAX_val : PHI_YMAX = 2796. Proof. unfold PHI_YMAX, PHI_K, PHI_A. lra. Qed.

Lemma gap_generic : forall L O, gap_check_static L = true -> gap_check_objects O = true ->
  forall h, floor_in L O h -> ~ (PHI_K < h < PHI_K + GAP).
Proof.
  intros L O Hs Ho h Hf Hb. rewrite K_val in Hb. unfold GAP in Hb.
  destruct Hf as [(t & Hin & Hfl & Hlo & Hhi) | (lo & hi & Hin & Hlo & Hhi)].
  - unfold gap_check_static in Hs. rewrite forallb_forall in Hs.
    specialize (Hs t Hin). rewrite Hfl in Hs. simpl in Hs.
    apply orb_true_iff in Hs as [Hs | Hs]; apply Z.leb_le in Hs;
      apply IZR_le in Hs; rewrite ?plus_IZR, ?minus_IZR in Hs; lra.
  - unfold gap_check_objects in Ho. rewrite forallb_forall in Ho.
    specialize (Ho (lo, hi) Hin). simpl in Ho.
    apply orb_true_iff in Ho as [Ho | Ho]; apply Z.leb_le in Ho;
      apply IZR_le in Ho; rewrite ?plus_IZR in Ho; lra.
Qed.

Lemma poles_generic : forall P, pole_check P = true ->
  forall base top, pole_in P base top -> top <= PHI_K \/ PHI_YMAX < base - 160.
Proof.
  intros P Hp base top (b & t & Hin & -> & ->). rewrite K_val, YMAX_val.
  unfold pole_check in Hp. rewrite forallb_forall in Hp.
  specialize (Hp (b, t) Hin). simpl in Hp.
  apply orb_true_iff in Hp as [Hp | Hp].
  - apply Z.leb_le in Hp. left. apply IZR_le in Hp. exact Hp.
  - apply Z.ltb_lt in Hp. right. apply IZR_lt in Hp. rewrite ?minus_IZR in Hp. lra.
Qed.

(* the real data passes the checks (K = 2424, GAP = 622, YMAX = 2796) *)
Lemma level_checks :
  gap_check_static static_tris = true /\ gap_check_objects object_floor_ranges = true /\
  pole_check wmotr_pole_list = true.
Proof. vm_compute. auto. Qed.

Definition wmotr_floor : R -> Prop := floor_in static_tris object_floor_ranges.
Definition wmotr_pole : R -> R -> Prop := pole_in wmotr_pole_list.

Theorem wmotr_gap_proved : forall h, wmotr_floor h -> ~ (PHI_K < h < PHI_K + GAP).
Proof.
  destruct level_checks as (Hs & Ho & _).
  exact (gap_generic static_tris object_floor_ranges Hs Ho).
Qed.

Theorem wmotr_poles_proved :
  forall base top, wmotr_pole base top -> top <= PHI_K \/ PHI_YMAX < base - 160.
Proof.
  destruct level_checks as (_ & _ & Hp).
  exact (poles_generic wmotr_pole_list Hp).
Qed.

(* -----------------------------------------------------------------------  *)
(* LEVEL_WMOTR, read off the level's own script: the WARP_NODE with id      *)
(* 0x0A (the node Mario enters by: the entry OBJECT's bhvAirborneWarp       *)
(* param, script.c:51-52) targets WMotR itself, and the command word is     *)
(* CMD_BBBB(0x26, 0x08, 0x0A, destLevel) (level_commands.h:231).  The       *)
(* level's other nodes send Mario to LEVEL_CASTLE (6: success, death) and   *)
(* LEVEL_CASTLE_GROUNDS (0x10: the warp floor, i.e. falling off).           *)
(* -----------------------------------------------------------------------  *)
Definition LEVEL_WMOTR : Z := 31.

Definition has_word (l : list init_data) (w : Z) : bool :=
  existsb (fun d => match d with Init_int32 i => Int.eq i (Int.repr w) | _ => false end) l.

Lemma level_wmotr_self_warp :
  has_word (gvar_init wmotr_script.v_level_wmotr_entry)
    (0x26080A00 + LEVEL_WMOTR) = true.
Proof. vm_compute. reflexivity. Qed.
