(* ======================================================================= *)
(* GOAL 2: the cells Phi reads at the real WMotR entry, read off the        *)
(* generated AST (phantom-forall sweep of the capstone's start premise,     *)
(* 2026-10-21).                                                              *)
(*                                                                          *)
(* The capstone wmotr_noA_height_bound_linked12 starts a run from a memory  *)
(* in PhiW.  StartSat showed SOME memory meets the premise (Mario idle at   *)
(* y = 0).  This file pins what the real entry path puts in Phi's cells,     *)
(* so StartSat's witness can carry THOSE values:                            *)
(*                                                                          *)
(*  - the level script's entry area has exactly one OBJECT with warp node   *)
(*    0x0A, a bhvAirborneWarp at (-67, 2669, -16) (script.c:51); node 0x0A *)
(*    is the node every warp into WMotR targets (the level's own WARP_NODE  *)
(*    0x0A, WMotRLevel.level_wmotr_self_warp; the castle's entrance node,  *)
(*    castle_inside/script.c, is not generated);                             *)
(*  - init_mario_after_warp (level_update.c) copies that object's position  *)
(*    into gPlayerSpawnInfos[0].startPos as s16, calls init_mario, which   *)
(*    sets pos := startPos (vec3s_to_vec3f), vel := 0, actionTimer := 0,  *)
(*    gfx.pos := pos (mario.c:1794-1855), and then                           *)
(*    set_mario_initial_action(m, spawnType, arg);                          *)
(*  - spawnType for bhvAirborneWarp is MARIO_SPAWN_AIRBORNE = 0x12, read    *)
(*    off the generated area.c (linked since 2026-10-21): get_mario_spawn_  *)
(*    type's loop compares o->behavior with sWarpBhvSpawnTable[i], i < 20,  *)
(*    and returns sSpawnTypeFromWarpBhv[i] (spawn_lookup_shape); the only   *)
(*    entry naming bhvAirborneWarp is i = 7 (airborne_warp_index) and       *)
(*    sSpawnTypeFromWarpBhv[7] = 0x12 (spawn_type_at_7).  The lookup is NOT *)
(*    executed: in CompCert's semantics it is stuck (see below);            *)
(*  - the generated set_mario_initial_action's case 0x12 is                 *)
(*    set_mario_action(m, 6450, 0) = ACT_SPAWN_NO_SPIN_AIRBORNE, which       *)
(*    zeroes actionState / actionTimer (mario.c set_mario_action).           *)
(*                                                                          *)
(* So at entry: action 6450, state 0, timer 0, pos[1] = gfx.pos[1] = 2669,  *)
(* vel[1] = 0, floorHeight = find_floor's hit under the spawn (>= -11000).  *)
(* entry_budget proves these cells are in the budget: 2669 + 0 <= 2796      *)
(* (margin 127).  Had the spawn been above YMAX, Phi would be false at      *)
(* every real entry and the capstone vacuous for the real game.             *)
(*                                                                          *)
(* NOT proved here (TRUST.md 0.4): that the real code produces these cells *)
(* in the linked model.  area.c is linked (2026-10-21), so gCurrLevelNum,  *)
(* gCurrCourseNum, gMarioSpawnInfo, gCurrentArea have storage, and         *)
(* EntryWarp runs the stores that set gCurrLevelNum = LEVEL_WMOTR.  Still  *)
(* not run: init_mario_after_warp itself (it needs the level's objects,    *)
(* spawned by the unlinked level-script / spawn_object path).  The       *)
(* spawn-type lookup get_mario_spawn_type is RUN since 2026-10-21          *)
(* (SpawnTypeRun.spawn_type_runs: behavior_data.c is linked, so the bhv*   *)
(* scripts in sWarpBhvSpawnTable are blocks with their real lengths).      *)
(* Before, it had no CompCert execution: those scripts were size-0 extern  *)
(* blocks and CompCert's pointer == needs a valid pointer on both sides    *)
(* (cmp_size0_stuck); earlier still, virtual_to_segmented's & 0x1FFFFFFF.  *)
(* ======================================================================= *)

From Coq Require Import ZArith List Reals Lra Lia.
From Flocq Require Import Binary.
From compcert Require Import Coqlib Integers Floats AST Values Memory Ctypes Cop Clightdefs Clight IEEE754_extra.
From SM64.Generated Require level_update wmotr_script mario area.
From SM64.Proofs Require Import HeightInvariant WMotRLevel NoAActions.
Import ListNotations.

Local Open Scope Z_scope.

(* ----------------------------------------------------------------------- *)
(* 1. The level script's OBJECT commands (level_commands.h: OBJECT =        *)
(*    CMD_BBH(0x24, 0x18, model), x|y, z|rx, ry|rz, bparams, behavior).     *)
(* ----------------------------------------------------------------------- *)
Definition s16_hi (w : Z) : Z := s16_lo (Z.shiftr w 16).

(* (behavior, x, y, z, bparam2) of the OBJECT command at the head, if any *)
Definition obj_at (l : list init_data) : option (ident * Z * Z * Z * Z) :=
  match l with
  | Init_int32 h :: Init_int32 xy :: Init_int32 zr :: Init_int32 _ :: Init_int32 bp
      :: Init_addrof b _ :: _ =>
      if Z.eqb (Z.shiftr (Int.unsigned h) 16) 0x2418
      then Some (b, s16_hi (Int.unsigned xy), s16_lo (Int.unsigned xy), s16_hi (Int.unsigned zr),
                 Z.land (Z.shiftr (Int.unsigned bp) 16) 255)
      else None
  | _ => None
  end.

(* every OBJECT command in an array *)
Fixpoint script_objs (l : list init_data) : list (ident * Z * Z * Z * Z) :=
  match l with
  | nil => nil
  | _ :: r => match obj_at l with Some o => o :: script_objs r | None => script_objs r end
  end.

(* the level's three script arrays: the entry (area 1 and its loads) and the
   two object lists it JUMP_LINKs (WMotRLevel.level_entry_loads) *)
Definition wmotr_script_objs : list (ident * Z * Z * Z * Z) :=
  flat_map (fun v => script_objs (gvar_init v))
    [wmotr_script.v_level_wmotr_entry; wmotr_script.v_script_func_local_1;
     wmotr_script.v_script_func_local_2].

Definition WARP_NODE_0A : Z := 10.

(* the objects of warp node 0x0A: exactly one, the airborne warp *)
Lemma entry_warp_object :
  filter (fun o => let '(_, _, _, _, bp2) := o in Z.eqb bp2 WARP_NODE_0A) wmotr_script_objs
  = [(wmotr_script._bhvAirborneWarp, -67, 2669, -16, WARP_NODE_0A)].
Proof. vm_compute. reflexivity. Qed.

(* sanity: the decoder sees the six poles and the hidden star as well *)
Lemma script_obj_count : length wmotr_script_objs = 8%nat.
Proof. vm_compute. reflexivity. Qed.

Definition ENTRY_Y_Z : Z := 2669.

(* ----------------------------------------------------------------------- *)
(* 2. The entry action: set_mario_initial_action's MARIO_SPAWN_AIRBORNE     *)
(*    case, read off the generated level_update.c.                          *)
(* ----------------------------------------------------------------------- *)
Definition MARIO_SPAWN_AIRBORNE : Z := 18.   (* 0x12, level_update.h:38 *)

Fixpoint first_call_args (s : statement) : option (ident * list expr) :=
  match s with
  | Scall _ (Evar id _) al => Some (id, al)
  | Ssequence a b =>
      match first_call_args a with Some x => Some x | None => first_call_args b end
  | _ => None
  end.

Fixpoint case_call (ls : labeled_statements) (n : Z) : option (ident * list expr) :=
  match ls with
  | LSnil => None
  | LScons (Some k) s rest => if Z.eqb k n then first_call_args s else case_call rest n
  | LScons None _ rest => case_call rest n
  end.

Fixpoint switch_call (s : statement) (n : Z) : option (ident * list expr) :=
  match s with
  | Sswitch _ ls => case_call ls n
  | Ssequence a b | Sifthenelse _ a b | Sloop a b =>
      match switch_call a n with Some x => Some x | None => switch_call b n end
  | Slabel _ a => switch_call a n
  | _ => None
  end.

(* the call's (callee, action literal, arg literal) *)
Definition action_arg (o : option (ident * list expr)) : option (ident * Z * Z) :=
  match o with
  | Some (f, _ :: Econst_int a _ :: Econst_int g _ :: nil) => Some (f, Int.unsigned a, Int.unsigned g)
  | _ => None
  end.

Lemma initial_action_airborne :
  action_arg (switch_call (fn_body level_update.f_set_mario_initial_action) MARIO_SPAWN_AIRBORNE)
  = Some (level_update._set_mario_action, Int.unsigned ACT_SPAWN_NO_SPIN_AIRBORNE, 0).
Proof. vm_compute. reflexivity. Qed.

(* ----------------------------------------------------------------------- *)
(* 2b. The spawn-type lookup, read off the generated area.c.               *)
(* ----------------------------------------------------------------------- *)
(* every index whose initializer is &id *)
Fixpoint addr_idx (l : list init_data) (id : ident) (k : nat) : list nat :=
  match l with
  | nil => nil
  | Init_addrof i _ :: r => if Pos.eqb i id then k :: addr_idx r id (S k) else addr_idx r id (S k)
  | _ :: r => addr_idx r id (S k)
  end.

Lemma airborne_warp_index :
  addr_idx (gvar_init area.v_sWarpBhvSpawnTable) area._bhvAirborneWarp 0 = [7%nat]
  /\ length (gvar_init area.v_sWarpBhvSpawnTable) = 20%nat.
Proof. split; vm_compute; reflexivity. Qed.

Lemma spawn_type_at_7 :
  nth_error (gvar_init area.v_sSpawnTypeFromWarpBhv) 7
  = Some (Init_int8 (Int.repr MARIO_SPAWN_AIRBORNE))
  /\ length (gvar_init area.v_sSpawnTypeFromWarpBhv) = 20%nat.
Proof. split; vm_compute; reflexivity. Qed.

(* get_mario_spawn_type's body: behavior := virtual_to_segmented(0x13,
   o->behavior); for (i = 0; i < n; i++) if (behavior == tbl[i]) return
   typ[i]; return 0 -- this matcher returns (tbl, typ, n) *)
Definition loop_lookup (s : statement) : option (ident * ident * Z) :=
  match s with
  | Ssequence _
      (Ssequence
         (Ssequence (Sset i0 (Econst_int z _))
            (Sloop
               (Ssequence
                  (Sifthenelse (Ebinop Olt (Etempvar i1 _) (Econst_int n _) _) Sskip Sbreak)
                  (Ssequence
                     (Sset t2 (Ederef (Ebinop Oadd (Evar tbl _) (Etempvar i2 _) _) _))
                     (Sifthenelse (Ebinop Oeq (Etempvar bh _) (Etempvar t2' _) _)
                        (Ssequence
                           (Sset t3 (Ederef (Ebinop Oadd (Evar typ _) (Etempvar i3 _) _) _))
                           (Sreturn (Some (Etempvar t3' _))))
                        Sskip)))
               _))
         (Sreturn (Some (Econst_int r _)))) =>
      if Pos.eqb i0 i1 && Pos.eqb i1 i2 && Pos.eqb i2 i3 && Pos.eqb t2 t2'
         && Pos.eqb t3 t3' && Pos.eqb bh area._behavior
         && Int.eq z Int.zero && Int.eq r Int.zero
      then Some (tbl, typ, Int.unsigned n) else None
  | _ => None
  end.

Lemma spawn_lookup_shape :
  loop_lookup (fn_body area.f_get_mario_spawn_type)
  = Some (area._sWarpBhvSpawnTable, area._sSpawnTypeFromWarpBhv, 20).
Proof. vm_compute. reflexivity. Qed.

(* why the lookup could not be RUN before behavior_data.c was linked
   (2026-10-21; now SpawnTypeRun runs it): each table entry pointed into a
   bhv* block with no valid offset (a size-0 extern), and CompCert's pointer
   == has no value unless both sides are (weakly) valid pointers --
   whichever block o->behavior is in.  The lemma still describes any
   size-0 block, e.g. the collision data warp_pipe_seg3_collision_03009AC8
   that interaction.c:881,889 compares with (not linked). *)
Lemma cmp_size0_stuck : forall ce m b1 o1 b o t1 a1 t2 a2,
    (forall z, Mem.valid_pointer m b z = false) ->
    sem_binary_operation ce Oeq (Vptr b1 o1) (Tpointer t1 a1)
      (Vptr b o) (Tpointer t2 a2) m = None.
Proof.
  intros ce m b1 o1 b o t1 a1 t2 a2 H0.
  unfold sem_binary_operation, sem_cmp, cmp_ptr. cbn.
  unfold Val.cmpu_bool, Mem.weak_valid_pointer. rewrite !H0. cbn.
  destruct (eq_block b1 b); rewrite ?andb_false_r; reflexivity.
Qed.

(* every direct call in a body, in order *)
Fixpoint calls_of (s : statement) : list ident :=
  match s with
  | Scall _ (Evar id _) _ => [id]
  | Ssequence a b | Sifthenelse _ a b | Sloop a b => calls_of a ++ calls_of b
  | Slabel _ a => calls_of a
  | Sswitch _ ls => calls_ls ls
  | _ => []
  end
with calls_ls (ls : labeled_statements) : list ident :=
  match ls with
  | LSnil => []
  | LScons _ s rest => calls_of s ++ calls_ls rest
  end.

(* init_mario_after_warp (level_update.c:356) asks area.c for the spawn type,
   runs init_mario, then set_mario_initial_action *)
Lemma after_warp_calls :
  filter (fun f => Pos.eqb f level_update._get_mario_spawn_type
                   || Pos.eqb f level_update._init_mario
                   || Pos.eqb f level_update._set_mario_initial_action)
    (calls_of (fn_body level_update.f_init_mario_after_warp))
  = [level_update._get_mario_spawn_type; level_update._init_mario;
     level_update._set_mario_initial_action].
Proof. vm_compute. reflexivity. Qed.

(* ----------------------------------------------------------------------- *)
(* 3. The entry cells and their budget.                                     *)
(* ----------------------------------------------------------------------- *)
(* (f32)(s16)2669: vec3s_to_vec3f's int -> float conversion *)
Definition ENTRY_Y : float32 := Float32.of_int (Int.repr ENTRY_Y_Z).

Lemma entry_y_val : R2 ENTRY_Y = 2669%R /\ F32 ENTRY_Y = true.
Proof.
  Local Transparent Float32.of_int.
  unfold ENTRY_Y, Float32.of_int.
  assert (Hr : - 2 ^ 24 <= Int.signed (Int.repr ENTRY_Y_Z) <= 2 ^ 24)
    by (change (Int.signed (Int.repr ENTRY_Y_Z)) with 2669; split; discriminate).
  split.
  - refine (eq_trans (proj1 (BofZ_exact _ _ _ _ _ Hr)) _). reflexivity.
  - exact (proj1 (proj2 (BofZ_exact _ _ _ _ _ Hr))).
Qed.

(* action, actionState, actionTimer, pos[1], vel[1], floorHeight, gfx.pos[1]
   as the entry path leaves them; fh is find_floor's hit under the spawn *)
Definition entry_cells (fh : float32) : cells :=
  mkCells ACT_SPAWN_NO_SPIN_AIRBORNE Int.zero Int.zero ENTRY_Y Float32.zero fh ENTRY_Y.

Lemma int_ne_u : forall a b : int, Int.unsigned a <> Int.unsigned b -> a <> b.
Proof. intros a b H E. subst. exact (H eq_refl). Qed.

Local Open Scope R_scope.

Lemma entry_budget : forall fh, F32 fh = true -> -11000 <= R2 fh ->
  budget_ok (entry_cells fh).
Proof.
  intros fh Ff Hf. destruct entry_y_val as (Ey & Fy).
  unfold budget_ok, InRange, credit_of, credit, state_of, timer_of, entry_cells.
  cbn [c_action c_state c_timer c_posy c_vely c_floorh c_gfxy].
  rewrite Ey, Fy.
  replace (R2 Float32.zero) with 0 by reflexivity.
  replace (Int.eq ACT_SPAWN_NO_SPIN_AIRBORNE ACT_FREEFALL) with false by reflexivity.
  replace (Int.eq ACT_SPAWN_NO_SPIN_AIRBORNE ACT_BUTT_SLIDE_AIR) with false by reflexivity.
  replace (Int.eq ACT_SPAWN_NO_SPIN_AIRBORNE ACT_SLIDE_KICK) with false by reflexivity.
  replace (Int.eq ACT_SPAWN_NO_SPIN_AIRBORNE ACT_GROUND_POUND) with false by reflexivity.
  replace (roll_prep ACT_SPAWN_NO_SPIN_AIRBORNE _) with false by reflexivity.
  replace (is_air ACT_SPAWN_NO_SPIN_AIRBORNE) with true by reflexivity.
  unfold rise_credit. destruct (Rle_dec 0 0) as [_ | N]; [ | exfalso; lra ].
  unfold PHI_K, PHI_A.
  split; [ split; [ exact Fy | split; [ reflexivity | split; [ exact Fy | ] ] ] | ].
  { split; [ lra | split; [ lra | split; [ split; [ exact Ff | exact Hf ] | lra ] ] ]. }
  split; [ lra | split; [ lra | ] ].
  split; [ intro E; exfalso; revert E; apply int_ne_u; vm_compute; discriminate | ].
  split; [ intro E; exfalso; revert E; apply int_ne_u; vm_compute; discriminate | ].
  split; [ intro E; exfalso; revert E; apply int_ne_u; vm_compute; discriminate | ].
  intro E; exfalso; revert E; apply int_ne_u; vm_compute; discriminate.
Qed.

(* the margin to YMAX: Mario enters 127 below it, with nothing to gain *)
Lemma entry_margin : R2 ENTRY_Y + 127 = PHI_YMAX.
Proof. rewrite (proj1 entry_y_val). unfold PHI_YMAX, PHI_K, PHI_A. lra. Qed.

Lemma entry_action_noA : R_noA ACT_SPAWN_NO_SPIN_AIRBORNE.
Proof.
  unfold R_noA, ACT_SPAWN_NO_SPIN_AIRBORNE. rewrite Int.unsigned_repr by (cbn; lia).
  unfold R_noA_list. repeat (first [ left; reflexivity | right ]).
Qed.
