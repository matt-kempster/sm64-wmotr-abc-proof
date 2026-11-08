(* spine-root: OBJECTS phase S2 -- obj_w, the object-world invariant the
   real update_objects pass carries next to PhiW, and its checker (the boot
   witness checks it on the real clear_objects / spawn_objects_from_info
   output, StartTerrain / StartSat). *)
(* ====================================================================== *)
(* ObjWorld.v                                                             *)
(*                                                                        *)
(* obj_w ge bm m: the object pool is a well-formed world.  Every clause  *)
(* reads real cells (offsets pinned against the composite env, 1.):      *)
(*   LISTS   gObjectLists = &gObjectListArray; each of the 13 object      *)
(*           lists is a doubly-linked ring from its head through pool     *)
(*           slots (header.next @96 / header.prev @100), the free list a *)
(*           chain from gFreeObjectList.next ending in NULL; together     *)
(*           they partition the 240 slots; a free slot is inactive        *)
(*           (activeFlags = 0).                                           *)
(*   MARIO   gMarioObject = m->marioObj = a slot of OBJ_LIST_PLAYER       *)
(*           (Mario's slot is never freed).                               *)
(*   SCRIPT  every listed slot's curBhvCommand points into a live         *)
(*           behavior script (BehaviorScripts.reached_bhvs).  B3 will     *)
(*           sharpen it to a command boundary.                            *)
(*   ACTION  act_in_range: a listed slot running one of the 3 behaviors  *)
(*           whose native calls cur_obj_call_action_function has         *)
(*           0 <= oAction < its table's length (ObjAct's UB-coverage      *)
(*           point, TRUST 3.2).                                           *)
(*   KIND    a listed slot other than Mario's has an interaction type in  *)
(*           wmotr_interact_types, a pole meets pole_obj_ok, a cannon     *)
(*           base cannon_obj_ok (what PhiW's collided list needs once    *)
(*           detect_object_collisions rebuilds it).                        *)
(*   RED     no listed slot runs bhvStarSpawnCoordinates (the red-coin    *)
(*           star), and a listed bhvHiddenRedCoinStar's counter is < 8.   *)
(*   DEBUG   sDebugPage is 0 and gDebugInfoFlags has bit 0 clear        *)
(*           (2026-11-07: the debug prints and the debug spawner's guard *)
(*           are off; see dflags_ok).                                     *)
(*   ORDER   sObjectListUpdateOrder holds its initializer.               *)
(*   STALE   Mario's interactObj / heldObj / usedObj / riddenObj are NULL *)
(*           or a slot-aligned pool pointer.  NOT claimed: that the slot  *)
(*           still holds the object the pointer was stored for (it may   *)
(*           have been freed and reused, "spiny adoption").  A write     *)
(*           through one must be shown harmless by the row that walks it *)
(*           (either the target is still that object, or the write cannot *)
(*           hit a protected slot).                                       *)
(* ow_chk is the executable form; ow_chk_sound.                           *)
(* ====================================================================== *)

From Coq Require Import ZArith List Lia Bool String.
From compcert Require Import Coqlib Maps AST Integers Floats Values Memory Ctypesdefs
  Globalenvs Ctypes Clight Errors.
From SM64.Generated Require object_list_processor behavior_data behavior_script object_helpers debug
  surface_load macro_special_objects wmotr_level_data area.
From SM64.Proofs Require Interp.CMem.
From SM64.Proofs Require Import CensusV2.
From SM64.Proofs.WMotRRequiresA Require Import WMotRLevel WMotRWorld.
From SM64.Proofs.WMotRRequiresA Require BehaviorScripts ObjAct ObjCensus BhvVM FloorList BoxCensus.
From SM64.Proofs.WMotRRequiresA Require FieldWin.

Import ListNotations.
Local Open Scope string_scope.
Module CM := SM64.Proofs.Interp.CMem.
Local Open Scope Z_scope.
(* the VM's reachable states: tactics must never reduce them (that runs the
   VM by conversion); vm_compute ignores this *)
Local Opaque BhvVM.vm_tab.

(* ---------------------------------------------------------------------- *)
(* 1. Layout, pinned.                                                       *)
(* ---------------------------------------------------------------------- *)
Definition OSZ : Z := 608.     (* sizeof(struct Object) *)
Definition NSLOT : Z := 240.   (* OBJECT_POOL_CAPACITY *)
Definition NLIST : nat := 13.  (* NUM_OBJ_LISTS *)
Definition NODESZ : Z := 104.  (* sizeof(struct ObjectNode) *)
Definition O_NEXT : Z := 96.   (* header.next *)
Definition O_PREV : Z := 100.  (* header.prev *)
Definition O_FLAGS : Z := 116. (* activeFlags (s16) *)
Definition O_CMD : Z := 460.   (* curBhvCommand *)
Definition O_BHV : Z := 524.   (* behavior *)
Definition O_SIDX : Z := 464.  (* bhvStackIndex (u32) *)
Definition O_STK : Z := 468.   (* bhvStack[8] (uintptr_t) *)
Definition O_ACTION : Z := RAW_OFF + 4 * 49.   (* oAction, 0x14C *)
Definition O_HSCOUNT : Z := RAW_OFF + 4 * 27.  (* oHiddenStarTriggerCounter, 0xF4 *)
Definition DBG_ENEMY7 : Z := 2 * (5 * 8 + 7).  (* gDebugInfo[5][7], s16 *)

Definition oce : composite_env := prog_comp_env object_helpers.prog.
Definition fo (s f : ident) : option Z :=
  match oce ! s with
  | Some co => match field_offset oce f (co_members co) with OK (x, _) => Some x | _ => None end
  | None => None
  end.
Definition csz (s : ident) : option Z :=
  match oce ! s with Some co => Some (co_sizeof co) | None => None end.

Lemma layout_pinned :
  (csz object_helpers._Object, csz object_helpers._ObjectNode,
   fo object_helpers._ObjectNode object_helpers._next, fo object_helpers._ObjectNode object_helpers._prev,
   fo object_helpers._Object object_helpers._activeFlags,
   fo object_helpers._Object object_helpers._curBhvCommand,
   fo object_helpers._Object object_helpers._behavior,
   fo object_helpers._Object object_helpers._rawData)
  = (Some OSZ, Some NODESZ, Some O_NEXT, Some O_PREV, Some O_FLAGS, Some O_CMD, Some O_BHV, Some RAW_OFF).
Proof. vm_compute. reflexivity. Qed.

Lemma stack_pinned :
  (fo object_helpers._Object object_helpers._bhvStackIndex,
   fo object_helpers._Object object_helpers._bhvStack) = (Some O_SIDX, Some O_STK).
Proof. vm_compute. reflexivity. Qed.

(* ---------------------------------------------------------------------- *)
(* 2. The walks.                                                            *)
(* ---------------------------------------------------------------------- *)
Definition slot_v (pool : block) (k : Z) : val := Vptr pool (Ptrofs.repr (k * OSZ)).

(* the slot index of a pool offset *)
Definition slot_of (o : Z) : option Z :=
  if (0 <=? o) && (o <? NSLOT * OSZ) && (o mod OSZ =? 0) then Some (o / OSZ) else None.

Definition ld32 (m : mem) (b : block) (z : Z) : option val := CM.load Mint32 m b z.

Definition veqb (x y : val) : bool := if Val.eq x y then true else false.

(* a ring from head (hb, ho): prev is the node before cur *)
Fixpoint ring_from (m : mem) (pool hb : block) (ho : Z) (prev cur : val) (n : nat) : option (list Z) :=
  match n with
  | O => None
  | S n' =>
      match cur with
      | Vptr b o =>
          if eq_block b hb && Z.eqb (Ptrofs.unsigned o) ho then
            (* back at the head: its prev is the last node *)
            if veqb (match ld32 m hb (ho + O_PREV) with Some v => v | None => Vundef end) prev
            then Some [] else None
          else if eq_block b pool then
            match slot_of (Ptrofs.unsigned o) with
            | Some k =>
                match ld32 m pool (Ptrofs.unsigned o + O_PREV), ld32 m pool (Ptrofs.unsigned o + O_NEXT) with
                | Some p, Some nx =>
                    if veqb p prev then
                      match ring_from m pool hb ho cur nx n' with
                      | Some l => Some (k :: l)
                      | None => None
                      end
                    else None
                | _, _ => None
                end
            | None => None
            end
          else None
      | _ => None
      end
  end.

Definition WFUEL : nat := 300.

Definition ring_i (m : mem) (pool la : block) (i : nat) : option (list Z) :=
  let ho := Z.of_nat i * NODESZ in
  match ld32 m la (ho + O_NEXT) with
  | Some nx => ring_from m pool la ho (Vptr la (Ptrofs.repr ho)) nx WFUEL
  | None => None
  end.

Fixpoint all_some {A} (l : list (option A)) : option (list A) :=
  match l with
  | [] => Some []
  | Some x :: l' => match all_some l' with Some r => Some (x :: r) | None => None end
  | None :: _ => None
  end.

Definition rings (m : mem) (pool la : block) : option (list (list Z)) :=
  all_some (map (ring_i m pool la) (seq 0 NLIST)).

Fixpoint free_from (m : mem) (pool : block) (cur : val) (n : nat) : option (list Z) :=
  match n with
  | O => None
  | S n' =>
      if veqb cur Vnullptr then Some [] else
      match cur with
      | Vptr b o =>
          if eq_block b pool then
            match slot_of (Ptrofs.unsigned o), ld32 m pool (Ptrofs.unsigned o + O_NEXT) with
            | Some k, Some nx =>
                match free_from m pool nx n' with Some l => Some (k :: l) | None => None end
            | _, _ => None
            end
          else None
      | _ => None
      end
  end.

Definition free_list (m : mem) (pool fl : block) : option (list Z) :=
  match ld32 m fl O_NEXT with
  | Some nx => free_from m pool nx WFUEL
  | None => None
  end.

(* ---------------------------------------------------------------------- *)
(* 3. The per-slot clauses.                                                 *)
(* ---------------------------------------------------------------------- *)
(* the three behaviors whose natives index an action table (ObjAct) *)
Definition act_pairs : list (ident * ident) :=
  [(behavior_data._bhvJumpingBox, Ctypesdefs.ident_of_string "sJumpingBoxActions");
   (behavior_data._bhvCannon, Ctypesdefs.ident_of_string "sOpenedCannonActions");
   (behavior_data._bhvExclamationBox, Ctypesdefs.ident_of_string "sExclamationBoxActions")].
Definition tlen (t : ident) : Z := Z.of_nat (List.length (ObjAct.tentries t)).

Lemma act_tables_pinned : map (fun p => tlen (snd p)) act_pairs = [2; 7; 6].
Proof. vm_compute. reflexivity. Qed.

(* SCRIPT, narrowed 2026-11-03 (FOUND, the objects agent): reached_bhvs is
   the closure over every symbol a body or table mentions, so it held the
   exclamation box's koopa-shell content and the shell's flame
   (bhvKoopaShellFlame, INTERACT_FLAME 0x40000, outside
   wmotr_interact_types: a slot running it breaks KIND through its
   SET_INTERACT_TYPE).  WMotR's boxes spawn only the contents of their real
   ids (BoxCensus.wmotr_closure_b, the box-contents edge cut to those ids),
   so the live scripts are reached_bhvs minus the 13 that closure never
   reaches (cut_bhvs, pinned against the closure by vm below: every live
   script is in wmotr_closure_b, and the cut ones are not).  PHANTOM CHECK:
   the boot slots run only closure scripts (m11, vm); in play a slot's
   script changes only by a spawn of a closure behavior. *)
Definition cut_bhvs : list ident :=
  map Ctypesdefs.ident_of_string
    ["bhvMetalCap"; "bhvObjectWaveTrail"; "bhvSingleCoinGetsSpawned"; "bhvSpawnedStar";
     "bhvKoopaShellUnderwater"; "bhvKoopaShell"; "bhvKoopaShellFlame"; "bhv1UpRunningAway";
     "bhvVanishCap"; "bhvBlueCoinJumping"; "bhvJumpingBox"; "bhvTenCoinsSpawn"; "bhvThreeCoinsSpawn"].
Definition live_bhvs : list ident :=
  filter (fun x => negb (existsb (Pos.eqb x) cut_bhvs)) BehaviorScripts.reached_bhvs.

Lemma live_in_closure_b : forallb (fun x => existsb (Pos.eqb x) BoxCensus.wmotr_closure_b) live_bhvs = true.
Proof. vm_compute. reflexivity. Qed.
Lemma cut_not_closure_b : forallb (fun x => negb (existsb (Pos.eqb x) BoxCensus.wmotr_closure_b)) cut_bhvs = true.
Proof. vm_compute. reflexivity. Qed.
Lemma flame_not_live : existsb (Pos.eqb behavior_data._bhvKoopaShellFlame) live_bhvs = false.
Proof. vm_compute. reflexivity. Qed.

(* generic over the lists, so nothing unfolds the computed closure *)
Lemma forallb_existsb_incl : forall l1 l2 : list ident,
  forallb (fun x => existsb (Pos.eqb x) l2) l1 = true -> forall x, In x l1 -> In x l2.
Proof.
  intros l1 l2 H x Hin. rewrite forallb_forall in H. specialize (H x Hin). cbv beta in H.
  apply existsb_exists in H as (y & Hy & E). apply Pos.eqb_eq in E. subst y. exact Hy.
Qed.

Lemma live_closure_b : forall id, In id live_bhvs -> In id BoxCensus.wmotr_closure_b.
Proof. exact (forallb_existsb_incl _ _ live_in_closure_b). Qed.

Section CLAUSES.
  Variable ge : genv.
  Variables pool bm : block.
  Variable m : mem.

  Definition is_bhv (k : Z) (id : ident) : Prop :=
    exists b, Genv.find_symbol ge id = Some b
              /\ Mem.load Mint32 m pool (k * OSZ + O_BHV) = Some (Vptr b Ptrofs.zero).

  Definition script_ok (k : Z) : Prop :=
    exists id b o, In id live_bhvs /\ Genv.find_symbol ge id = Some b
                   /\ Mem.load Mint32 m pool (k * OSZ + O_CMD) = Some (Vptr b o).

  (* DRY12 (B3a): a slot of ring 12 (OBJ_LIST_UNIMPORTANT) runs a list-12
     script that is not a water mover (ObjCensus.live12, each DRY). *)
  Definition script12_ok (k : Z) : Prop :=
    exists id b o, In id ObjCensus.live12 /\ Genv.find_symbol ge id = Some b
                   /\ Mem.load Mint32 m pool (k * OSZ + O_CMD) = Some (Vptr b o).

  (* CMDPOS (B3 ii): the slot's script pointer and behavior stack are a
     reachable state of the script VM (BhvVM.vm_tab): the pointer is at a
     command boundary (so the opcode indexes BehaviorCmdTable in bounds),
     bhvStackIndex is the stack depth (<= 8) and each pushed cell is the
     frame the VM expects (a command address, or an int repeat count). *)
  Definition frame_ok (f : BhvVM.frame) (ov : option val) : Prop :=
    match f with
    | BhvVM.FAddr s i => exists b, Genv.find_symbol ge s = Some b
                           /\ ov = Some (Vptr b (Ptrofs.repr (4 * Z.of_nat i)))
    | BhvVM.FCount => exists c, ov = Some (Vint c)
    end.

  Definition stk_cell (k : Z) (d n : nat) : Z := k * OSZ + O_STK + 4 * (Z.of_nat d - 1 - Z.of_nat n).

  Definition vm_ok (k : Z) : Prop :=
    exists st, In st BhvVM.vm_tab
      /\ (exists b, Genv.find_symbol ge (BhvVM.v_s st) = Some b
           /\ Mem.load Mint32 m pool (k * OSZ + O_CMD)
                = Some (Vptr b (Ptrofs.repr (4 * Z.of_nat (BhvVM.v_i st)))))
      /\ Mem.load Mint32 m pool (k * OSZ + O_SIDX)
           = Some (Vint (Int.repr (Z.of_nat (List.length (BhvVM.v_k st)))))
      /\ (forall n f, nth_error (BhvVM.v_k st) n = Some f ->
           frame_ok f (Mem.load Mint32 m pool (stk_cell k (List.length (BhvVM.v_k st)) n))).

  Definition act_ok (k : Z) : Prop :=
    forall bh t, In (bh, t) act_pairs -> is_bhv k bh ->
      exists a, Mem.load Mint32 m pool (k * OSZ + O_ACTION) = Some (Vint a)
                /\ 0 <= Int.signed a < tlen t.

  Definition kind_ok (k : Z) : Prop :=
    exists t, Mem.load Mint32 m pool (k * OSZ + O_INTERACT_TYPE) = Some (Vint t)
      /\ In (Int.unsigned t) wmotr_interact_types
      /\ (Int.unsigned t = INTERACT_POLE -> pole_obj_ok m pool (k * OSZ))
      /\ (Int.unsigned t = INTERACT_CANNON_BASE -> cannon_obj_ok m pool (k * OSZ))
      (* 2026-10-26, the x/z pins (WMotRWorld.pole_xz_ok / cannon_xz_ok:
         x, y, z of the same level-data entry) *)
      /\ (Int.unsigned t = INTERACT_POLE -> pole_xz_ok m pool (k * OSZ))
      /\ (Int.unsigned t = INTERACT_CANNON_BASE -> cannon_xz_ok m pool (k * OSZ)).

  Definition red_ok (k : Z) : Prop :=
    ~ is_bhv k behavior_data._bhvStarSpawnCoordinates
    /\ (is_bhv k behavior_data._bhvHiddenRedCoinStar ->
        exists c, Mem.load Mint32 m pool (k * OSZ + O_HSCOUNT) = Some (Vint c) /\ Int.signed c < 8).

  Definition slot_ptr (v : val) : Prop :=
    v = Vnullptr \/ exists k, 0 <= k < NSLOT /\ v = slot_v pool k.
End CLAUSES.

(* kind_ok depends only on each slot's cells at offsets >= 96 of the pool
   block (frames call this rather than destructing the clause) *)
(* the collision cells of a slot (2026-11-06, detect_object_collisions):
   collidedObjInteractTypes [112, 116), numCollidedObjs and collidedObjs
   [118, 136) (activeFlags, 116, is not one), rawData word 5
   (oIntangibleTimer, 156) and word 66 (400).  ccl off e: the bytes
   [off, e) miss them *)
Definition ccl (off e : Z) : Prop :=
  (e <= 112 \/ 116 <= off) /\ (e <= 118 \/ 136 <= off) /\ (e <= 156 \/ 160 <= off)
  /\ (e <= 400 \/ 404 <= off) /\ FieldWin.ucl off e.
(* 2026-11-08: and the script-written fields no clause reads (FieldWin.ucl) *)

Local Ltac ko := unfold OSZ, O_INTERACT_TYPE, O_POSX, O_POSY, O_POSZ, HITBOX_DOWN_OFF, HITBOX_H_OFF,
                   RAW_OFF, ccl, FieldWin.ucl; cbn [size_chunk]; lia.
(* the slot fields obj_w reads: from offset 96 on, except the platform
   field (Object.platform, offset 532, which update_mario_platform writes
   and no obj_w clause reads) and the collision cells (ccl) *)
Lemma kind_ok_eq : forall pool m m',
  (forall ch k off, 96 <= off -> off + size_chunk ch <= OSZ -> (off + size_chunk ch <= 532 \/ 536 <= off) ->
     ccl off (off + size_chunk ch) ->
     Mem.load ch m' pool (k * OSZ + off) = Mem.load ch m pool (k * OSZ + off)) ->
  forall k, kind_ok pool m k -> kind_ok pool m' k.
Proof.
  intros pool m m' Kp k (t & Lt & Hin & Hp & Hc & Hpx & Hcx).
  assert (S : forall ch off, 96 <= off -> off + size_chunk ch <= OSZ -> (off + size_chunk ch <= 532 \/ 536 <= off) ->
            ccl off (off + size_chunk ch) ->
            Mem.load ch m' pool (k * OSZ + off) = Mem.load ch m pool (k * OSZ + off)) by (intros; apply Kp; assumption).
  exists t.
  split; [ rewrite S by ko; exact Lt | split; [ exact Hin | split; [ | split; [ | split ] ] ] ].
  - intros E. destruct (Hp E) as (base & top & Hb & L1 & L2 & L3).
    exists base, top. rewrite !S by ko. exact (conj Hb (conj L1 (conj L2 L3))).
  - intros E. destruct (Hc E) as (y & Hy & L). exists y. rewrite S by ko. exact (conj Hy L).
  - intros E. destruct (Hpx E) as (x & z & base & top & Hb & L1 & L2 & L3).
    exists x, z, base, top. rewrite !S by ko. exact (conj Hb (conj L1 (conj L2 L3))).
  - intros E. destruct (Hcx E) as (x & z & y & Hy & L1 & L2 & L3).
    exists x, z, y. rewrite !S by ko. exact (conj Hy (conj L1 (conj L2 L3))).
Qed.

(* ORDER: update_non_terrain_objects / unload_deactivated_objects walk the
   lists in the order of the writable table sObjectListUpdateOrder; its 11
   cells hold their initializer (nothing in the game stores to it). *)
Definition upd_order : list Z := [11; 9; 10; 0; 5; 4; 2; 6; 8; 12; -1].

Definition order_ok (ge : genv) (m : mem) : Prop :=
  exists b, Genv.find_symbol ge object_list_processor._sObjectListUpdateOrder = Some b
    /\ forall j, (j < 11)%nat ->
         Mem.load Mint8signed m b (Z.of_nat j) = Some (Vint (Int.repr (nth j upd_order 0))).

(* CMDTAB (B3 i): behavior_script.c's static BehaviorCmdTable holds its
   initializer: cell j points to the j-th handler (ObjCensus.cmd_handlers).
   Only cur_obj_update reads it and nothing writes it
   (ObjCensus.cmdtab_read_only / cmdtab_users_value / cmdtab_not_in_inits). *)
Definition cmdtab_ok (ge : genv) (m : mem) : Prop :=
  exists b, Genv.find_symbol ge behavior_script._BehaviorCmdTable = Some b
    /\ forall j id, nth_error ObjCensus.cmd_handlers j = Some id ->
         exists hb, Genv.find_symbol ge id = Some hb
           /\ Mem.load Mint32 m b (4 * Z.of_nat j) = Some (Vptr hb Ptrofs.zero).

(* ---------------------------------------------------------------------- *)
(* 3b. Surfaces (2026-11-02).  FOUND: the per-object step rows             *)
(*     (HeightFrame.Hobj_step_*_terrain) were false over memories whose    *)
(*     sSurfacePool / sSurfaceNodePool point anywhere: alloc_surface and   *)
(*     alloc_surface_node store through sSurfacePool[gSurfacesAllocated] / *)
(*     sSurfaceNodePool[gSurfaceNodesAllocated] unchecked                  *)
(*     (surface_load.c:41-71).  SPOOL pins both pointers into one dynamic  *)
(*     block at their boot offsets, sSurfacePoolSize and the static        *)
(*     counts (nothing writes them after the level load).  The COUNTERS'   *)
(*     bound is NOT here: a fixed bound is false per object step at        *)
(*     saturation (a collision object stepping from a frame whose objects  *)
(*     all loaded already); it is the frame-boundary fact ctr_ok below,    *)
(*     and the step rows' walk-indexed bound is the planned fix.           *)
(*     SURF_OBJ: every list from a partition cell walks through            *)
(*     sSurfaceNodePool slots (in the pools' block P, [NP_OFF, NP_END) at  *)
(*     stride 8) to NULL, its surfaces are sSurfacePool slots ([SP_OFF,    *)
(*     SP_END) at stride 48), and each has object NULL or a pool           *)
(*     slot whose angle velocity (0x23..0x25) is 0 -- what                 *)
(*     update_mario_platform's gMarioPlatform needs (PlatformKeep).        *)
(*     FOUND (phantom forall, 2026-11-02) / REPAIRED (2026-11-03): SURF_OBJ *)
(*     let the nodes and surfaces lie anywhere in any dynamic block, so    *)
(*     the camera row's surf_keep (HeightFrame) ranged over states whose   *)
(*     list nodes sit inside the Camera's bytes (the Camera shares the     *)
(*     main-pool block) -- false there.  Now both are bounded to their     *)
(*     pool's range at its stride; in the game alloc_surface_node /        *)
(*     alloc_surface hand out exactly those slots (surface_load.c:41-71),  *)
(*     and the boot witness checks it by vm (surf_b at m11).  PHANTOM      *)
(*     CHECK: every partition list the game builds is pool nodes ->        *)
(*     pool surfaces, so the bound excludes no reachable state.            *)
(*     COLL: at most WMotR's placed exclamation boxes (each at a placed    *)
(*     position) and cannon lids are listed -- the only collision-loading  *)
(*     behaviors of the closure (BehaviorScripts.reached_bhvs).            *)
(* ---------------------------------------------------------------------- *)
Definition sce : composite_env := prog_comp_env surface_load.prog.
Definition sfo (s f : ident) : option Z :=
  match sce ! s with
  | Some co => match field_offset sce f (co_members co) with OK (x, _) => Some x | _ => None end
  | None => None
  end.
Definition scsz (s : ident) : option Z :=
  match sce ! s with Some co => Some (co_sizeof co) | None => None end.

Definition SURF_SZ : Z := 48.     (* sizeof(struct Surface) *)
Definition S_OBJ : Z := 44.       (* Surface.object *)
Definition SNODE_SZ : Z := 8.     (* sizeof(struct SurfaceNode) *)
Lemma surf_layout_pinned :
  (scsz surface_load._Surface, sfo surface_load._Surface surface_load._object, scsz surface_load._SurfaceNode,
   sfo surface_load._SurfaceNode surface_load._next, sfo surface_load._SurfaceNode surface_load._surface)
  = (Some SURF_SZ, Some S_OBJ, Some SNODE_SZ, Some FloorList.SN_NEXT, Some FloorList.SN_SURF).
Proof. vm_compute. reflexivity. Qed.

Definition SP_CAP : Z := 2300.    (* sSurfacePoolSize = 2300, surface_load.c:522 *)
Definition NP_CAP : Z := 7000.    (* the node pool, surface_load.c:523 *)
Definition NS : Z := 1352.        (* WMotR's static surfaces (WMotRLevel.static_counts) *)
Definition NN : Z := 2908.   (* its static surface nodes (the boot run) *)
Definition NP_OFF : Z := 2672.  (* sSurfaceNodePool's offset in the main-pool block (the boot run) *)
Definition SP_OFF : Z := 58688.  (* sSurfacePool's offset (the boot run) *)
Definition PCELLS : nat := 1536.  (* 16 * 16 * 3 SurfaceNode heads, 2 words each *)
Definition SFUEL : nat := 8000.

(* a global's cell holds v *)
Definition gcell (ge : genv) (id : ident) (ch : memory_chunk) (v : val) (m : mem) : Prop :=
  exists b, Genv.find_symbol ge id = Some b /\ Mem.load ch m b 0 = Some v.

Definition spool_ok (ge : genv) (m : mem) : Prop :=
  exists P, Ple (Genv.genv_next ge) P
    /\ gcell ge surface_load._sSurfacePool Mint32 (Vptr P (Ptrofs.repr SP_OFF)) m
    /\ gcell ge surface_load._sSurfaceNodePool Mint32 (Vptr P (Ptrofs.repr NP_OFF)) m
    /\ gcell ge surface_load._sSurfacePoolSize Mint16signed (Vint (Int.repr SP_CAP)) m
    /\ gcell ge surface_load._gNumStaticSurfaces Mint32 (Vint (Int.repr NS)) m
    /\ gcell ge surface_load._gNumStaticSurfaceNodes Mint32 (Vint (Int.repr NN)) m.

(* the two pools are apart and inside the main pool block (BootRun.POOL) *)
Lemma spool_layout :
  0 <= NP_OFF /\ NP_OFF + NP_CAP * SNODE_SZ <= SP_OFF /\ SP_OFF + SP_CAP * SURF_SZ <= 262144.
Proof. vm_compute. repeat split; discriminate. Qed.

(* the pools' ranges in their block (spool_layout): a node / surface is a
   pool slot -- in its pool's range, at its pool's stride *)
Definition NP_END : Z := NP_OFF + NP_CAP * SNODE_SZ.
Definition SP_END : Z := SP_OFF + SP_CAP * SURF_SZ.
Definition in_np (z : Z) : bool := (NP_OFF <=? z) && (z <? NP_END) && ((z - NP_OFF) mod SNODE_SZ =? 0).
Definition in_sp (z : Z) : bool := (SP_OFF <=? z) && (z <? SP_END) && ((z - SP_OFF) mod SURF_SZ =? 0).

Lemma in_np_spec : forall z, in_np z = true -> NP_OFF <= z /\ z + SNODE_SZ <= NP_END.
Proof.
  intros z H. unfold in_np in H. apply andb_prop in H as [H H3]. apply andb_prop in H as [H1 H2].
  apply Z.leb_le in H1. apply Z.ltb_lt in H2. apply Z.eqb_eq in H3.
  unfold NP_END, NP_OFF, NP_CAP, SNODE_SZ in *.
  pose proof (Z_div_mod_eq_full (z - 2672) 8) as E. rewrite H3 in E. lia.
Qed.

Lemma in_sp_spec : forall z, in_sp z = true -> SP_OFF <= z /\ z + SURF_SZ <= SP_END.
Proof.
  intros z H. unfold in_sp in H. apply andb_prop in H as [H H3]. apply andb_prop in H as [H1 H2].
  apply Z.leb_le in H1. apply Z.ltb_lt in H2. apply Z.eqb_eq in H3.
  unfold SP_END, SP_OFF, SP_CAP, SURF_SZ in *.
  pose proof (Z_div_mod_eq_full (z - 58688) 48) as E. rewrite H3 in E. lia.
Qed.

Lemma sp_end_small : SP_END <= Ptrofs.max_unsigned.
Proof. apply Z.leb_le. vm_compute. reflexivity. Qed.

Lemma uadd_small : forall o d, 0 <= d -> Ptrofs.unsigned o + d <= Ptrofs.max_unsigned ->
  Ptrofs.unsigned (Ptrofs.add o (Ptrofs.repr d)) = Ptrofs.unsigned o + d.
Proof.
  intros o d H0 H1. pose proof (Ptrofs.unsigned_range o) as R.
  unfold Ptrofs.add. rewrite (Ptrofs.unsigned_repr d) by lia. apply Ptrofs.unsigned_repr. lia.
Qed.

(* a list from a partition head: sSurfaceNodePool slots of the pools'
   block P, ending in NULL *)
Fixpoint swalk (P : block) (m : mem) (fuel : nat) (v : val) : option (list val) :=
  match fuel with
  | O => None
  | S f =>
      match v with
      | Vptr b o =>
          if Pos.eqb b P && in_np (Ptrofs.unsigned o) then
            match CM.load Mint32 m b (Ptrofs.unsigned (Ptrofs.add o (Ptrofs.repr FloorList.SN_SURF))),
                  CM.load Mint32 m b (Ptrofs.unsigned (Ptrofs.add o (Ptrofs.repr FloorList.SN_NEXT))) with
            | Some s, Some nx => option_map (cons s) (swalk P m f nx)
            | _, _ => None
            end
          else None
      | Vint i => if Int.eq i Int.zero then Some nil else None
      | _ => None
      end
  end.

Lemma swalk_on_list : forall P m hd s, FloorList.on_list m hd s ->
  forall f l, swalk P m f hd = Some l -> In s l.
Proof.
  intros P m hd s H. induction H as [bn on s Hl | bn on nx s Hl Ho IH]; intros f l Hw;
    (destruct f as [| f]; [ discriminate Hw | ]); cbn [swalk] in Hw;
    (destruct (Pos.eqb bn P && in_np (Ptrofs.unsigned on)); [ | discriminate Hw ]);
    cbn [Mem.loadv] in Hl; rewrite !CM.load_eq in Hw.
  - rewrite Hl in Hw.
    destruct (Mem.load Mint32 m bn (Ptrofs.unsigned (Ptrofs.add on (Ptrofs.repr FloorList.SN_NEXT)))); [ | discriminate Hw ].
    destruct (swalk P m f _); [ | discriminate Hw ]. cbn in Hw. injection Hw as <-. left. reflexivity.
  - rewrite Hl in Hw.
    destruct (Mem.load Mint32 m bn (Ptrofs.unsigned (Ptrofs.add on (Ptrofs.repr FloorList.SN_SURF)))); [ | discriminate Hw ].
    destruct (swalk P m f nx) as [l'|] eqn:Hw'; [ | discriminate Hw ]. cbn in Hw. injection Hw as <-.
    right. exact (IH f l' Hw').
Qed.

(* the walk reads only the node pool's range of P *)
Lemma swalk_ext : forall P m m',
  (forall ch z, NP_OFF <= z -> z + size_chunk ch <= NP_END -> Mem.load ch m' P z = Mem.load ch m P z) ->
  forall f v, swalk P m' f v = swalk P m f v.
Proof.
  intros P m m' K. induction f as [| f IH]; intros v; [ reflexivity | ]. cbn [swalk].
  destruct v; try reflexivity.
  destruct (Pos.eqb b P) eqn:E; [ | reflexivity ].
  destruct (in_np (Ptrofs.unsigned i)) eqn:N; [ | reflexivity ]. cbn [andb].
  apply Pos.eqb_eq in E. subst b. destruct (in_np_spec _ N) as (N1 & N2).
  pose proof sp_end_small as Sm. pose proof (Ptrofs.unsigned_range i) as R.
  unfold FloorList.SN_SURF, FloorList.SN_NEXT.
  rewrite !uadd_small by (unfold NP_END, SP_END, NP_OFF, NP_CAP, SNODE_SZ, SP_OFF, SP_CAP, SURF_SZ in *; lia).
  rewrite !CM.load_eq, !K by (cbn [size_chunk]; unfold SNODE_SZ in N2; lia).
  destruct (Mem.load Mint32 m P (Ptrofs.unsigned i + 4)); [ | reflexivity ].
  destruct (Mem.load Mint32 m P (Ptrofs.unsigned i + 0)); [ | reflexivity ].
  rewrite IH. reflexivity.
Qed.

Definition ANGV : list Z := [35; 36; 37].   (* oAngleVelPitch / Yaw / Roll *)

Definition surf_obj_at (P pool : block) (m : mem) (s : val) : Prop :=
  exists o, s = Vptr P o /\ in_sp (Ptrofs.unsigned o) = true
    /\ (Mem.load Mint32 m P (Ptrofs.unsigned o + S_OBJ) = Some (Vint Int.zero)
        \/ exists k, 0 <= k < NSLOT
             /\ Mem.load Mint32 m P (Ptrofs.unsigned o + S_OBJ) = Some (slot_v pool k)
             /\ forall j, In j ANGV -> Mem.load Mint32 m pool (k * OSZ + RAW_OFF + 4 * j) = Some (Vint Int.zero)).

(* P is the pools' block (both pointers, as spool_ok pins them; stated
   here too so the clause names the ranges it reads).
   2026-11-03: EVERY word a partition holds (any offset a Mint32 load
   reads), not only the cells 4 * j, j < PCELLS: find_floor's contract
   (FloorList.FL) names its list head by an arbitrary partition offset.
   The two forms agree on every reachable memory: a partition is the
   definer's 6144 bytes and no Clight run grows a block's permissions
   (part_cells below, checked at boot from Generic.MaxPerm). *)
Definition surf_obj_ok (ge : genv) (pool : block) (m : mem) : Prop :=
  exists P, Ple (Genv.genv_next ge) P
    /\ gcell ge surface_load._sSurfacePool Mint32 (Vptr P (Ptrofs.repr SP_OFF)) m
    /\ gcell ge surface_load._sSurfaceNodePool Mint32 (Vptr P (Ptrofs.repr NP_OFF)) m
    /\ forall id bp z hd, In id FloorList.part_ids -> Genv.find_symbol ge id = Some bp ->
         Mem.load Mint32 m bp z = Some hd ->
         exists l, swalk P m SFUEL hd = Some l /\ Forall (surf_obj_at P pool m) l.

(* a partition word is one of its 1536 cells: what the boot witness's
   memories satisfy (a partition is 6144 bytes, StartTerrain.part_bound,
   and Max permissions never grow, Generic.MaxPerm) *)
Definition part_cells (ge : genv) (m : mem) : Prop :=
  forall id bp z hd, In id FloorList.part_ids -> Genv.find_symbol ge id = Some bp ->
    Mem.load Mint32 m bp z = Some hd -> 0 <= z < 4 * Z.of_nat PCELLS.

(* the globals the clause reads *)
Definition surf_gids : list ident :=
  surface_load._sSurfacePool :: surface_load._sSurfaceNodePool :: FloorList.part_ids.

(* THE KEEP: the clause reads its globals, the two pools' ranges of P and
   the listed slots' angle velocities -- nothing else *)
Lemma surf_obj_ok_ext : forall (ge : genv) pool m m',
  (forall id b, In id surf_gids -> Genv.find_symbol ge id = Some b ->
     forall ch z, Mem.load ch m' b z = Mem.load ch m b z) ->
  (forall P, Ple (Genv.genv_next ge) P ->
     gcell ge surface_load._sSurfacePool Mint32 (Vptr P (Ptrofs.repr SP_OFF)) m ->
     gcell ge surface_load._sSurfaceNodePool Mint32 (Vptr P (Ptrofs.repr NP_OFF)) m ->
     forall ch z, (NP_OFF <= z /\ z + size_chunk ch <= NP_END) \/ (SP_OFF <= z /\ z + size_chunk ch <= SP_END) ->
     Mem.load ch m' P z = Mem.load ch m P z) ->
  (forall k j, 0 <= k < NSLOT -> In j ANGV ->
     Mem.load Mint32 m' pool (k * OSZ + RAW_OFF + 4 * j) = Mem.load Mint32 m pool (k * OSZ + RAW_OFF + 4 * j)) ->
  surf_obj_ok ge pool m -> surf_obj_ok ge pool m'.
Proof.
  intros ge pool m m' KG KP KA (P & HP & G1 & G2 & W).
  assert (Kc : forall id ch v, In id surf_gids -> gcell ge id ch v m -> gcell ge id ch v m').
  { intros id ch v Hin (b & Hs & L). exists b. rewrite (KG id b Hin Hs). exact (conj Hs L). }
  pose proof (KP P HP G1 G2) as KR.
  exists P. split; [ exact HP | split; [ apply Kc; [ cbn; auto | exact G1 ] | split; [ apply Kc; [ cbn; auto | exact G2 ] | ] ] ].
  intros id bp z hd Hin Hs L.
  rewrite (KG id bp ltac:(cbn [surf_gids]; right; right; exact Hin) Hs) in L.
  destruct (W id bp z hd Hin Hs L) as (l & Hw & F).
  exists l. rewrite (swalk_ext P m m' (fun ch z H1 H2 => KR ch z (or_introl (conj H1 H2)))). split; [ exact Hw | ].
  refine (Forall_impl _ _ F). intros s (o & -> & N & H).
  exists o. split; [ reflexivity | split; [ exact N | ] ].
  destruct (in_sp_spec _ N) as (N1 & N2).
  rewrite (KR Mint32 (Ptrofs.unsigned o + S_OBJ)) by (right; cbn [size_chunk]; unfold S_OBJ, SURF_SZ in *; lia).
  destruct H as [H | (k & Hk & Lk & A)]; [ left; exact H | right ].
  exists k. split; [ exact Hk | split; [ exact Lk | ] ]. intros j' Hj'. rewrite (KA k j' Hk Hj'). exact (A j' Hj').
Qed.

(* the placed collision objects (WMotRLevel's macro list) *)
Definition placed (b : ident) : list (Z * Z * Z) :=
  map (fun o => (m_x o, m_y o, m_z o)) (filter (fun o => Pos.eqb (bhv_of o) b) wmotr_macro_objs).
Definition box_xyz : list (Z * Z * Z) := placed macro_special_objects._bhvExclamationBox.
Definition N_BOX : Z := Z.of_nat (List.length box_xyz).
Definition N_LID : Z := Z.of_nat (List.length (placed macro_special_objects._bhvCannonClosed)).
Lemma coll_counts : (N_BOX, N_LID) = (7, 2).
Proof. vm_compute. reflexivity. Qed.

Definition is_bhv_b (ge : genv) (pool : block) (m : mem) (id : ident) (k : Z) : bool :=
  match Genv.find_symbol ge id, ld32 m pool (k * OSZ + O_BHV) with
  | Some b, Some v => veqb v (Vptr b Ptrofs.zero)
  | _, _ => false
  end.

Definition box_pos_ok (pool : block) (m : mem) (k : Z) : Prop :=
  exists x y z, In (x, y, z) box_xyz
    /\ Mem.load Mfloat32 m pool (k * OSZ + O_POSX) = Some (f32z x)
    /\ Mem.load Mfloat32 m pool (k * OSZ + O_POSY) = Some (f32z y)
    /\ Mem.load Mfloat32 m pool (k * OSZ + O_POSZ) = Some (f32z z).

Definition coll_ok (ge : genv) (pool : block) (m : mem) (rs : list (list Z)) : Prop :=
  Z.of_nat (List.length (filter (is_bhv_b ge pool m macro_special_objects._bhvExclamationBox) (concat rs))) <= N_BOX
  /\ Z.of_nat (List.length (filter (is_bhv_b ge pool m macro_special_objects._bhvCannonClosed) (concat rs))) <= N_LID
  /\ forall k, In k (concat rs) -> is_bhv_b ge pool m macro_special_objects._bhvExclamationBox k = true ->
       box_pos_ok pool m k.

(* THE FRAME-BOUNDARY COUNTER FACT (not in ow_core: see 3b).  In a frame
   without time stop, clear_dynamic_surfaces resets both counters to the
   static counts and each collision object then loads its mesh at most
   once.  In a time-stop frame (TIME_STOP_ACTIVE at the clear) the clear
   does NOT reset, and load_object_collision_model loads nothing either
   (the same gate; CollisionCensus.gates_value), and no terrain script
   writes gTimeStopState (CollisionCensus.terrain_value), so the counters
   keep the previous frame's values (FOUND 2026-11-02: this comment said
   the clear always resets).  The bound:
   DS = the placed collision objects' triangles (7 boxes x 12 + 2 lids x 2);
   DN = 4 DS: a dynamic triangle spans at most 2 x 2 cells, since its x / z
   extent is at most 2 * scale * |vertex| + 2 <= 802 < 924 (mesh_radius;
   lower_cell_index / upper_cell_index widen by 50 on each side,
   surface_load.c:194-250, so an extent under 924 meets at most 2 cells) *)
Definition mesh_tris (o : mobj) : Z :=
  match collision_of (bhv_of o) with Some (mesh, _) => Z.of_nat (List.length (parse mesh)) | None => 0 end.
Definition DS : Z := fold_right Z.add 0 (map mesh_tris wmotr_macro_objs).
Definition DN : Z := 4 * DS.

Definition vnorm2 (v : vtx) : Z := let '(x, y, z) := v in x * x + y * y + z * z.
Lemma mesh_radius : forallb (fun o => match collision_of (bhv_of o) with
    | Some (mesh, s) => forallb (fun t => (s * s * vnorm2 (t_v1 t) <=? 400 * 400)
                                          && (s * s * vnorm2 (t_v2 t) <=? 400 * 400)
                                          && (s * s * vnorm2 (t_v3 t) <=? 400 * 400)) (parse mesh)
    | None => true end) wmotr_macro_objs = true.
Proof. vm_compute. reflexivity. Qed.

Lemma ctr_fits : (DS, DN) = (88, 352) /\ NS + DS <= SP_CAP /\ NN + DN <= NP_CAP.
Proof. vm_compute. repeat split; try reflexivity; discriminate. Qed.

Definition ctr_ok (ge : genv) (m : mem) : Prop :=
  exists a n, gcell ge surface_load._gSurfacesAllocated Mint32 (Vint a) m
    /\ NS <= Int.signed a <= NS + DS
    /\ gcell ge surface_load._gSurfaceNodesAllocated Mint32 (Vint n) m
    /\ NN <= Int.signed n <= NN + DN.

(* ---------------------------------------------------------------------- *)
(* 3c. THE SURFACE BUDGET (2026-11-02; the census: CollisionCensus).       *)
(*   A slot's dynamic surfaces per step, by the script it RUNS (the block  *)
(*   its curBhvCommand points into, not its behavior field): the box      *)
(*   script 12 (its mesh's triangles), the lid script 2, any other 0 (no  *)
(*   other reached script reaches load_object_collision_model:           *)
(*   CollisionCensus.loaders_value); 0 in a time stop (the loader's gate, *)
(*   gates_value).  CTR_S: NS <= gSurfacesAllocated <= NS + DS.  TER: a   *)
(*   slot with dynamic surfaces is in list 9; lists 9 and 11 run only the *)
(*   box, lid and bhvCoinFormation scripts (terrain_value: the reached    *)
(*   scripts that BEGIN in 9 or 11); list 9's budgets sum to at most DS;  *)
(*   a box / lid slot's collisionData is NULL (not yet loaded) or its     *)
(*   mesh; both meshes hold their initializers (the arrays are writable   *)
(*   globals, wmotr_level_data, so this is pinned, not assumed).          *)
(*   NOT here: the node counter.  FOUND 2026-11-02: a per-step node bound *)
(*   (4 per triangle) is false over states whose box / lid transform      *)
(*   (header.gfx.throwMatrix, the lid's scale, offsets < 96) is not        *)
(*   pinned; it stays a frame-boundary check (ctr_ok) and an open item.   *)
(* ---------------------------------------------------------------------- *)
Definition O_COLL : Z := 536.     (* collisionData *)
Lemma coll_pinned : fo object_helpers._Object object_helpers._collisionData = Some O_COLL.
Proof. vm_compute. reflexivity. Qed.

Definition BOXS : ident := behavior_data._bhvExclamationBox.
Definition LIDS : ident := behavior_data._bhvCannonClosed.
Definition COINF : ident := behavior_data._bhvCoinFormation.
Definition BOXM : ident := wmotr_level_data._exclamation_box_outline_seg8_collision_08025F78.
Definition LIDM : ident := wmotr_level_data._cannon_lid_seg8_collision_08004950.
Definition D_BOX : Z := 12.
Definition D_LID : Z := 2.

(* the meshes' triangle counts (the parse DS is the sum of) *)
Lemma mesh_tris_pinned :
  (Z.of_nat (List.length (parse (shorts box_init))), Z.of_nat (List.length (parse (shorts lid_init))))
  = (D_BOX, D_LID).
Proof. vm_compute. reflexivity. Qed.

Definition sym_is (ge : genv) (id : ident) (b : block) : bool :=
  match Genv.find_symbol ge id with Some b' => Pos.eqb b b' | None => false end.

(* slot k runs the script id *)
Definition runs (ge : genv) (pool : block) (m : mem) (k : Z) (id : ident) : bool :=
  match ld32 m pool (k * OSZ + O_CMD) with Some (Vptr b _) => sym_is ge id b | _ => false end.

Definition sdyn (ge : genv) (pool : block) (m : mem) (k : Z) : Z :=
  if runs ge pool m k BOXS then D_BOX else if runs ge pool m k LIDS then D_LID else 0.

Definition sumz (l : list Z) : Z := fold_right Z.add 0 l.

Definition mesh_ptr (ge : genv) (id : ident) (ov : option val) : Prop :=
  ov = Some (Vint Int.zero) \/ exists b, Genv.find_symbol ge id = Some b /\ ov = Some (Vptr b Ptrofs.zero).

Definition coll_pin (ge : genv) (pool : block) (m : mem) (k : Z) : Prop :=
  (runs ge pool m k BOXS = true -> mesh_ptr ge BOXM (Mem.load Mint32 m pool (k * OSZ + O_COLL)))
  /\ (runs ge pool m k LIDS = true -> mesh_ptr ge LIDM (Mem.load Mint32 m pool (k * OSZ + O_COLL))).

Definition mesh_ok (ge : genv) (id : ident) (l : list Z) (m : mem) : Prop :=
  exists b, Genv.find_symbol ge id = Some b
    /\ forall j x, nth_error l j = Some x -> Mem.load Mint16signed m b (2 * Z.of_nat j) = Some (Vint (Int.repr x)).

Definition ter_ok (ge : genv) (pool : block) (m : mem) (rs : list (list Z)) : Prop :=
  (forall i k, In k (nth i rs []) -> sdyn ge pool m k <> 0 -> i = 9%nat)
  /\ (forall i k, (i = 9 \/ i = 11)%nat -> In k (nth i rs []) ->
        runs ge pool m k BOXS = true \/ runs ge pool m k LIDS = true \/ runs ge pool m k COINF = true)
  /\ sumz (map (sdyn ge pool m) (nth 9 rs [])) <= DS
  /\ (forall k, In k (concat rs) -> coll_pin ge pool m k)
  /\ mesh_ok ge BOXM (shorts box_init) m /\ mesh_ok ge LIDM (shorts lid_init) m.

Definition ctr_s_ok (ge : genv) (m : mem) : Prop :=
  exists a, gcell ge surface_load._gSurfacesAllocated Mint32 (Vint a) m /\ NS <= Int.signed a <= NS + DS.

(* the time-stop gate and the counter, as values *)
Definition tsa (ge : genv) (m : mem) : bool :=
  match Genv.find_symbol ge surface_load._gTimeStopState with
  | Some b => match Mem.load Mint32 m b 0 with
              | Some (Vint x) => negb (Int.eq (Int.and x (Int.repr 64)) Int.zero)
              | _ => false
              end
  | None => false
  end.

Definition ctrv (ge : genv) (m : mem) : Z :=
  match Genv.find_symbol ge surface_load._gSurfacesAllocated with
  | Some b => match Mem.load Mint32 m b 0 with Some (Vint a) => Int.signed a | _ => NS + DS + 1 end
  | None => NS + DS + 1
  end.

Definition dyn (ge : genv) (pool : block) (m : mem) (k : Z) : Z :=
  if tsa ge m then 0 else sdyn ge pool m k.

(* THE POST-CLEAR FACT R (ObjPhase 3b): after clear_dynamic_surfaces the
   counter is back at the static count, or a time stop is on.  PHANTOM
   CHECK: on the real path the clear makes it true (surface_load.c:643:
   gSurfacesAllocated = gNumStaticSurfaces, pinned NS by ow_spool, unless
   TIME_STOP_ACTIVE), and the boot witness satisfies it before the first
   objects phase (counters = (NS, NN) at m11, once the boot side checks
   ctr_b there). *)
Definition post_clear (ge : genv) (m : mem) : Prop := tsa ge m = true \/ ctrv ge m = NS.

Lemma sym_load_store : forall (ge : genv) id bs ch m b ofs v m' ch' z,
  Genv.find_symbol ge id = Some bs -> Ple (Genv.genv_next ge) b ->
  Mem.store ch m b ofs v = Some m' -> Mem.load ch' m' bs z = Mem.load ch' m bs z.
Proof.
  intros ge id bs ch m b ofs v m' ch' z Hs Hp Hst.
  apply (Mem.load_store_other _ _ _ _ _ _ Hst). left.
  intros ->. pose proof (Genv.genv_symb_range _ _ Hs) as Hr. unfold Plt, Ple in *. lia.
Qed.

Lemma post_clear_store : forall (ge : genv) ch m b ofs v m', Ple (Genv.genv_next ge) b ->
  post_clear ge m -> Mem.store ch m b ofs v = Some m' -> post_clear ge m'.
Proof.
  intros ge ch m b ofs v m' Hp H Hst. unfold post_clear, tsa, ctrv in *.
  destruct (Genv.find_symbol ge surface_load._gTimeStopState) as [bt|] eqn:Et;
  destruct (Genv.find_symbol ge surface_load._gSurfacesAllocated) as [ba|] eqn:Ea;
  rewrite ?(sym_load_store ge _ _ _ _ _ _ _ _ _ _ Et Hp Hst), ?(sym_load_store ge _ _ _ _ _ _ _ _ _ _ Ea Hp Hst);
  exact H.
Qed.

(* ---------------------------------------------------------------------- *)
(* 3d. Scripts (2026-11-03; designed in BhvStep, B3 iii).  SCR: every      *)
(*     script the behavior VM can reach (the scripts of BhvVM.vm_tab's    *)
(*     states) holds its initializer, word for word.  The scripts are      *)
(*     writable globals in C, so this is a world fact, not a link fact.    *)
(*     PHANTOM CHECK: nothing in the game stores through a script pointer *)
(*     (RoCensus.ro_deep_no_store), so every reachable memory has the      *)
(*     scripts as initialized; the boot witness checks it by vm (scr_b_l  *)
(*     inside ow_chk at m11), and each keeper needs only "no store into a *)
(*     script block" from its footprint.                                  *)
(*     PERF TRAP: never name sdedup (map BhvVM.v_s BhvVM.vm_tab) as a      *)
(*     constant; it is written out where used.                            *)
(* ---------------------------------------------------------------------- *)
Definition init_val (ge : genv) (d : init_data) (v : val) : Prop :=
  match d with
  | Init_int32 n => v = Vint n
  | Init_addrof t o => exists bt, Genv.find_symbol ge t = Some bt /\ v = Vptr bt o
  | _ => True
  end.

Definition scr_ok (ge : genv) (m : mem) : Prop :=
  forall s bs i d, Genv.find_symbol ge s = Some bs -> In s (map BhvVM.v_s BhvVM.vm_tab) ->
    nth_error (BhvVM.words s) i = Some d ->
    exists v, Mem.load Mint32 m bs (4 * Z.of_nat i) = Some v /\ init_val ge d v.

(* the keep: the clause reads only the script blocks *)
Lemma scr_ok_ext : forall (ge : genv) m m',
  (forall s b, In s (map BhvVM.v_s BhvVM.vm_tab) -> Genv.find_symbol ge s = Some b ->
     forall ch z, Mem.load ch m' b z = Mem.load ch m b z) ->
  scr_ok ge m -> scr_ok ge m'.
Proof.
  intros ge m m' K H s bs i d Hs Hin Hd. rewrite (K s bs Hin Hs). exact (H s bs i d Hs Hin Hd).
Qed.

Fixpoint sdedup (l : list ident) : list ident :=
  match l with
  | [] => []
  | x :: l' => let t := sdedup l' in if existsb (Pos.eqb x) t then t else x :: t
  end.
Lemma sdedup_in : forall x l, In x l -> In x (sdedup l).
Proof.
  intros x l. induction l as [| y l IH]; intros H; [ destruct H | ].
  cbn [sdedup]. destruct (existsb (Pos.eqb y) (sdedup l)) eqn:E.
  - destruct H as [<- | H]; [ | exact (IH H) ].
    apply existsb_exists in E as (z & Hz & Ez). apply Pos.eqb_eq in Ez. subst z. exact Hz.
  - destruct H as [<- | H]; [ left; reflexivity | right; exact (IH H) ].
Qed.

(* ---------------------------------------------------------------------- *)
(* 3e. Mario stays live, respawn targets, graph links (2026-11-03).        *)
(*   FOUND (phantom forall, 2026-11-03): HeightFrame's row Hobj_unload    *)
(*   (unload_deactivated_objects keeps Pobj) was FALSE over memories obj_w *)
(*   allowed, so both capstones assumed a false hypothesis:               *)
(*   (a) Mario's slot with ACTIVE_FLAG_ACTIVE clear: the real             *)
(*       unload_deactivated_objects_in_list frees it, breaking MARIO      *)
(*       (ow_mario) and PhiW;                                             *)
(*   (b) a listed slot of respawnInfoType 1 / 2 whose respawnInfo aims    *)
(*       anywhere (gMarioStates, a list head): set_object_respawn_info_   *)
(*       bits ORs 0xFF00 into it;                                         *)
(*   (c) graph links aimed anywhere: unload_object's geo_remove_child /   *)
(*       geo_add_child (graph_node.c:525-577) store through the node's    *)
(*       prev->next, next->prev, parent->children and the old first       *)
(*       child's prev / last child's next.                                *)
(*   REPAIRED by three clauses, each vm-checked on the real boot memory   *)
(*   (m11, StartTerrain; the probe of 2026-11-03 read: Mario = slot 34,   *)
(*   every live slot's activeFlags 257; respawn targets as listed below;  *)
(*   all 240 nodes under gObjParentGraphNode in one consistent ring whose *)
(*   first child is Mario's node):                                        *)
(*   MACT  Mario's slot has ACTIVE (bit 0 of activeFlags) and runs        *)
(*         bhvMario: curBhvCommand and every pushed bhvStack address lie  *)
(*         in bhvMario's block.  TRUTH: allocate_object sets ACTIVE|UNK8; *)
(*         the clearers are DEACTIVATE (bhv op 29, in no bhvMario command *)
(*         and bhvMario has no CALL / GOTO out: the stepper's census,     *)
(*         BhvStep) and obj_mark_for_deletion, applied to Mario's object  *)
(*         on no WMotR path.                                               *)
(*   RESP  a listed slot's respawnInfoType is an int; type 1 aims at      *)
(*         gPlayerSpawnInfos' behaviorArg (+16, Mario's) or at one of the *)
(*         area's eight SpawnInfo behaviorArg cells in the main-pool block *)
(*         (sSurfacePool's block, SI_OFFS: the level pool's eight          *)
(*         SpawnInfos + 16, under the node pool at NP_OFF, as the real     *)
(*         entry run lays them out, 2026-11-03); type 2 at a macro entry's *)
(*         params word                                                     *)
(*         (wmotr_seg7_macro_objs + 10 i + 8, i < 26).  TRUTH: the pair   *)
(*         is written only by allocate_object (NULL, NULL;                *)
(*         spawn_object.c:281), spawn_objects_from_info (type 1) and      *)
(*         spawn_macro_objects (type 2); the last two run only at area    *)
(*         load, so every slot spawned in play is NULL-typed.              *)
(*   GFX   every slot's graph node (all 240, free ones too) has parent    *)
(*         &gObjParentGraphNode and prev / next slot nodes; the parent's  *)
(*         children is NULL or a slot node.  TRUTH: clear_objects puts    *)
(*         every node under gObjParentGraphNode (geo_reset_object_node,   *)
(*         graph_node.c:686); the in-play relinkers try_allocate_object   *)
(*         and unload_object (spawn_object.c:95-96, 194-195: remove, then  *)
(*         add under gObjParentGraphNode) keep this shape whatever the     *)
(*         ring order; geo_make_first_child runs only at Mario's spawn    *)
(*         (object_list_processor.c:500), gMirrorMario's links only at    *)
(*         area load / unload (mario_misc.c:598-601).  The shape is the   *)
(*         writer-stable one, weaker than the ring the boot shows.        *)
(* ---------------------------------------------------------------------- *)
Definition O_RTYPE : Z := 502.   (* respawnInfoType (s16) *)
Definition O_RINFO : Z := 604.   (* respawnInfo *)
Lemma resp_pinned :
  (fo object_helpers._Object object_helpers._respawnInfoType, fo object_helpers._Object object_helpers._respawnInfo)
  = (Some O_RTYPE, Some O_RINFO).
Proof. vm_compute. reflexivity. Qed.

Definition mact_ok (ge : genv) (pool gmo : block) (m : mem) : Prop :=
  forall k, 0 <= k < NSLOT -> Mem.load Mint32 m gmo 0 = Some (slot_v pool k) ->
    (exists f, Mem.load Mint16signed m pool (k * OSZ + O_FLAGS) = Some (Vint f)
               /\ Int.and f Int.one = Int.one)
    /\ (exists b, Genv.find_symbol ge behavior_data._bhvMario = Some b
        /\ (exists o, Mem.load Mint32 m pool (k * OSZ + O_CMD) = Some (Vptr b o))
        /\ (forall d n, Mem.load Mint32 m pool (k * OSZ + O_SIDX) = Some (Vint d) ->
              0 <= n < Z.min (Int.unsigned d) 8 ->
              (exists o, Mem.load Mint32 m pool (k * OSZ + O_STK + 4 * n) = Some (Vptr b o))
              \/ (exists c, Mem.load Mint32 m pool (k * OSZ + O_STK + 4 * n) = Some (Vint c)))).

Definition SI_OFFS : list Z := [2364; 2444; 2476; 2508; 2540; 2572; 2604; 2636].
Definition MAC_OFFS : list Z := map (fun i => 10 * Z.of_nat i + 8) (seq 0 26).

Definition resp_ok (ge : genv) (pool : block) (m : mem) (k : Z) : Prop :=
  exists t, Mem.load Mint16signed m pool (k * OSZ + O_RTYPE) = Some (Vint t)
    /\ (Int.unsigned t = 1 -> exists b o, Mem.load Mint32 m pool (k * OSZ + O_RINFO) = Some (Vptr b o)
          /\ ((Genv.find_symbol ge area._gPlayerSpawnInfos = Some b /\ Ptrofs.unsigned o = 16)
              \/ (gcell ge surface_load._sSurfacePool Mint32 (Vptr b (Ptrofs.repr SP_OFF)) m
                  /\ In (Ptrofs.unsigned o) SI_OFFS)))
    /\ (Int.unsigned t = 2 -> exists b o, Mem.load Mint32 m pool (k * OSZ + O_RINFO) = Some (Vptr b o)
          /\ Genv.find_symbol ge wmotr_level_data._wmotr_seg7_macro_objs = Some b
          /\ In (Ptrofs.unsigned o) MAC_OFFS).

Definition G_PREV : Z := 4.   (* GraphNode.prev *)
Definition G_NEXT : Z := 8.   (* GraphNode.next *)
Definition G_PAR : Z := 12.   (* GraphNode.parent *)
Definition G_CHILD : Z := 16. (* GraphNode.children *)

Definition slot_node (pool : block) (ov : option val) : Prop :=
  exists j, 0 <= j < NSLOT /\ ov = Some (slot_v pool j).

Definition gfx_ok (ge : genv) (pool : block) (m : mem) : Prop :=
  forall bpg, Genv.find_symbol ge area._gObjParentGraphNode = Some bpg ->
    (forall k, 0 <= k < NSLOT ->
       Mem.load Mint32 m pool (k * OSZ + G_PAR) = Some (Vptr bpg Ptrofs.zero)
       /\ slot_node pool (Mem.load Mint32 m pool (k * OSZ + G_PREV))
       /\ slot_node pool (Mem.load Mint32 m pool (k * OSZ + G_NEXT)))
    /\ (Mem.load Mint32 m bpg G_CHILD = Some (Vint Int.zero)
        \/ slot_node pool (Mem.load Mint32 m bpg G_CHILD)).

(* ---------------------------------------------------------------------- *)
(* 3f. Mario's surfaces are not loose in the main pool (2026-11-03).      *)
(*   FOUND (phantom forall, 2026-11-03): the row Hobj_unload was FALSE     *)
(*   over memories Pobj allowed.  unload_deactivated_objects calls         *)
(*   set_object_respawn_info_bits on a deactivated slot without            *)
(*   OBJ_FLAG_PERSISTENT_RESPAWN; for respawnInfoType 1 it ORs 0xFF00 into  *)
(*   a SpawnInfo behaviorArg cell of the main-pool block P (SI_OFFS,       *)
(*   ow_resp).  Nothing pinned where m->wall / m->ceil / m->floor          *)
(*   point (PhiW's ffw asks only a dynamic block off the frame's regions), *)
(*   so a memory with m->floor = P + 2338, whose s16 "type" reads the low  *)
(*   half of a behaviorArg (0, a WMotR type), met every premise, and the   *)
(*   OR breaks wmotr_world's surface_ok.                                    *)
(*   REPAIRED by MSURF: each of the three cells is NULL or points into a   *)
(*   block other than P, or into P at a surface-pool slot                  *)
(*   P + [SP_OFF, SP_END) at the pool's stride (in_sp).  Unload's only     *)
(*   store into a dynamic block is the respawn OR into P off the surface   *)
(*   pool, so this is what the repair needs.                               *)
(*   TRUTH (in play): the cells are written only with find_floor /         *)
(*   find_ceil / find_wall_collisions results or NULL, and every surface   *)
(*   those return is on a partition list, static or dynamic;               *)
(*   alloc_surface takes every surface, static ones included               *)
(*   (load_area_terrain), from sSurfacePool = P + SP_OFF (surface_load.c   *)
(*   alloc_surface; the lists' surfaces are in_sp by surf_obj_ok): the     *)
(*   in_sp arm.  Since 2026-11-03 the boot witness's cells are the real    *)
(*   init_mario's (StartTerrain.entry: wall = ceil = NULL, floor = the     *)
(*   find_floor hit P + 112592, in_sp), so the in_sp arm holds there too;  *)
(*   the clause still asks only "not loose in P" (all unload needs; until  *)
(*   then the witness's floor was a stand-in block off P).  Checked by vm  *)
(*   on the boot witness (ow_chk, m11).  It reads three gMarioStates      *)
(*   cells and sSurfacePool only: no slot.                                 *)
(* ---------------------------------------------------------------------- *)
Definition MSURF : list Z := [WALL_OFF; CEIL_OFF; FLOOR_OFF].

Definition msurf_ok (ge : genv) (bm : block) (m : mem) : Prop :=
  forall z v, In z MSURF -> Mem.load Mint32 m bm z = Some v ->
    v = Vint Int.zero
    \/ exists b o, v = Vptr b o
         /\ forall P, gcell ge surface_load._sSurfacePool Mint32 (Vptr P (Ptrofs.repr SP_OFF)) m ->
              b <> P \/ in_sp (Ptrofs.unsigned o) = true.

(* ---------------------------------------------------------------------- *)
(* 3g. Parents (2026-11-03, for BhvStep's PARENT_BIT_CLEAR row, row 51).   *)
(*   PAR1  every slot's parentObj (offset 104) is NULL or a pool slot.     *)
(*   PAR2  a listed slot running one of the twelve PARENT_BIT_CLEAR        *)
(*         scripts (BhvVM.pbc_states; pbc_ids_ok) has a pool-slot parent.  *)
(*   TRUTH: parentObj is written only by spawn_object / try_allocate's     *)
(*   callers with the spawning object (a slot) and by clear_objects'       *)
(*   reset (NULL); unload_object leaves it.  The twelve particle spawners  *)
(*   are spawned only by Mario's own code with parent gMarioObject.        *)
(*   Checked by vm on the boot witness (ow_chk, m11).  Slot fields from    *)
(*   96 on, so every slot keeper (PollKeep.SKp) keeps them.                *)
(* ---------------------------------------------------------------------- *)
Definition O_PARENT : Z := 104.
Lemma parent_pinned : fo object_helpers._Object object_helpers._parentObj = Some O_PARENT.
Proof. vm_compute. reflexivity. Qed.

Definition pbc_ids : list ident :=
  [behavior_data._bhvTriangleParticleSpawner; behavior_data._bhvHorStarParticleSpawner;
   behavior_data._bhvPlungeBubble; behavior_data._bhvBubbleParticleSpawner;
   behavior_data._bhvVertStarParticleSpawner; behavior_data._bhvSparkleParticleSpawner;
   behavior_data._bhvShallowWaterSplash; behavior_data._bhvShallowWaterWave;
   behavior_data._bhvWhitePuff1; behavior_data._bhvWaveTrail; behavior_data._bhvWaterSplash;
   behavior_data._bhvMistParticleSpawner].

(* the list is the VM table's PARENT_BIT_CLEAR states' scripts *)
Lemma pbc_ids_ok : map BhvVM.v_s (filter (fun st => BhvVM.opc st =? 51) BhvVM.vm_tab) = pbc_ids.
Proof. vm_compute. reflexivity. Qed.

Definition par_ok (ge : genv) (pool : block) (m : mem) (rs : list (list Z)) : Prop :=
  (forall k, 0 <= k < NSLOT ->
     Mem.load Mint32 m pool (k * OSZ + O_PARENT) = Some (Vint Int.zero)
     \/ slot_node pool (Mem.load Mint32 m pool (k * OSZ + O_PARENT)))
  /\ (forall k id, In k (concat rs) -> In id pbc_ids -> runs ge pool m k id = true ->
        slot_node pool (Mem.load Mint32 m pool (k * OSZ + O_PARENT))).

(* ---------------------------------------------------------------------- *)
(* 3h. Mario's VM state, the animation data, the special-slot tie         *)
(*     (2026-11-03, for BhvStep's init chain, ANIMATE row and sfr_keep).   *)
(*   MVM   Mario's slot's VM cells (curBhvCommand @460, bhvStackIndex     *)
(*         @464, bhvStack @468) are a reachable state OF bhvMario (vm_tab *)
(*         filtered to v_s = bhvMario: ten states, all at depth <= 1).    *)
(*         TRUTH: create_object starts him at &bhvMario[0], depth 0, and  *)
(*         bhvMario has no CALL / GOTO out.  The boot witness has him at  *)
(*         &bhvMario[0], depth 0 (checked by vm, m11).                     *)
(*   ANIM  the tables LOAD_ANIMATIONS (0x27) loads -- word 1 of every     *)
(*         reachable 0x27 state, anim_tabs_ok -- and the Animation structs *)
(*         those tables point at hold their initializers, chunk by chunk  *)
(*         (the s16 fields as Mint16signed, the words as Mint32: what     *)
(*         geo_obj_init_animation's *(oAnimations + i), flags, startFrame *)
(*         read).  They are writable globals (gvar_readonly false), so,   *)
(*         like SCR, a world fact; nothing in the game stores into them.  *)
(*   CLS   a listed slot whose interactType is POLE or CANNON_BASE, and   *)
(*         any slot a partition surface points at, runs a VM state of     *)
(*         sp_scripts: every script a VM state reachable from the special *)
(*         behaviors runs in (sp_bhvs; the same computation as BhvStep's *)
(*         sp_scripts).  So a slot running a generic script is read by no *)
(*         pole / cannon pin (kind_ok) and no ANGV pin (surf_obj_at).     *)
(*         Reads the slots' VM cells and interactType, the partitions and *)
(*         the surfaces' object words; no allow_n global.                 *)
(*   PERF TRAP: sp_scripts runs the VM explorer; never unfold it in a     *)
(*   proof (the checker takes it, and vm_tab, as arguments).              *)
(* ---------------------------------------------------------------------- *)

(* the cells of slot k hold VM state st (vm_ok's body, named) *)
Definition vm_at (ge : genv) (pool : block) (m : mem) (k : Z) (st : BhvVM.vst) : Prop :=
  (exists b, Genv.find_symbol ge (BhvVM.v_s st) = Some b
     /\ Mem.load Mint32 m pool (k * OSZ + O_CMD)
          = Some (Vptr b (Ptrofs.repr (4 * Z.of_nat (BhvVM.v_i st)))))
  /\ Mem.load Mint32 m pool (k * OSZ + O_SIDX)
       = Some (Vint (Int.repr (Z.of_nat (List.length (BhvVM.v_k st)))))
  /\ (forall n f, nth_error (BhvVM.v_k st) n = Some f ->
       frame_ok ge f (Mem.load Mint32 m pool (stk_cell k (List.length (BhvVM.v_k st)) n))).

Lemma vm_ok_at : forall ge pool m k,
  vm_ok ge pool m k <-> exists st, In st BhvVM.vm_tab /\ vm_at ge pool m k st.
Proof. intros. unfold vm_ok, vm_at. apply iff_refl. Qed.

(* MVM *)
Definition mvm_ok (ge : genv) (pool gmo : block) (m : mem) : Prop :=
  forall k, 0 <= k < NSLOT -> Mem.load Mint32 m gmo 0 = Some (slot_v pool k) ->
    exists st, In st BhvVM.vm_tab /\ BhvVM.v_s st = behavior_data._bhvMario
               /\ vm_at ge pool m k st.

(* ANIM *)
Definition ldata_words (t : ident) : list init_data :=
  match find (fun p => Pos.eqb (fst p) t) wmotr_level_data.global_definitions with
  | Some (_, Gvar v) => gvar_init v
  | _ => []
  end.

(* the cells of an initializer: (byte offset, datum) *)
Fixpoint icells (z : Z) (l : list init_data) : list (Z * init_data) :=
  match l with
  | [] => []
  | d :: l' => (z, d) :: icells (z + init_data_size d) l'
  end.

Definition init_ld (ge : genv) (m : mem) (b : block) (z : Z) (d : init_data) : Prop :=
  match d with
  | Init_int16 n => Mem.load Mint16signed m b z = Some (Vint (Int.sign_ext 16 n))
  | Init_int32 n => Mem.load Mint32 m b z = Some (Vint n)
  | Init_addrof t o => exists bt, Genv.find_symbol ge t = Some bt /\ Mem.load Mint32 m b z = Some (Vptr bt o)
  | _ => True
  end.

Definition anim_tabs : list ident :=
  [wmotr_level_data._bobomb_seg8_anims_0802396C; wmotr_level_data._bowser_key_seg3_anims_list;
   wmotr_level_data._toad_seg6_anims_0600FB58; wmotr_level_data._peach_seg5_anims_0501C41C].

Definition anim_structs : list ident :=
  [wmotr_level_data._bobomb_seg8_anim_080237FC; wmotr_level_data._bobomb_seg8_anim_08023954;
   wmotr_level_data._bowser_key_seg3_anim_unlock_door; wmotr_level_data._bowser_key_seg3_anim_course_exit;
   wmotr_level_data._toad_seg6_anim_0600B66C; wmotr_level_data._toad_seg6_anim_0600CE78;
   wmotr_level_data._toad_seg6_anim_0600E414; wmotr_level_data._toad_seg6_anim_0600FB40;
   wmotr_level_data._toad_seg6_anim_060099F0; wmotr_level_data._toad_seg6_anim_0600A0D0;
   wmotr_level_data._toad_seg6_anim_06008F7C; wmotr_level_data._toad_seg6_anim_06009310;
   wmotr_level_data._peach_seg5_anim_0500C638; wmotr_level_data._peach_seg5_anim_0500E6B4;
   wmotr_level_data._peach_seg5_anim_0500ED94; wmotr_level_data._peach_seg5_anim_0500F474;
   wmotr_level_data._peach_seg5_anim_0500FE84; wmotr_level_data._peach_seg5_anim_05011050;
   wmotr_level_data._peach_seg5_anim_05012F40; wmotr_level_data._peach_seg5_anim_05015468;
   wmotr_level_data._peach_seg5_anim_05016798; wmotr_level_data._peach_seg5_anim_05018664;
   wmotr_level_data._peach_seg5_anim_0501B328; wmotr_level_data._peach_seg5_anim_0501C404].

Definition anim_ids : list ident := anim_tabs ++ anim_structs.

(* the lists are the generated data's: every reachable LOAD_ANIMATIONS
   state's word 1 is a listed table, ... *)
Lemma anim_tabs_ok :
  forallb (fun st => implb (BhvVM.opc st =? 39)
             (match BhvVM.ptr_at st 1 with Some t => existsb (Pos.eqb t) anim_tabs | None => false end))
    BhvVM.vm_tab = true.
Proof. vm_compute. reflexivity. Qed.

(* ... every pointer a table holds is a listed struct, and every listed
   global has a nonempty initializer in the linked level data (no vacuous
   pin) *)
Lemma anim_structs_ok :
  forallb (fun t => forallb (fun d => match d with
                                      | Init_addrof a _ => existsb (Pos.eqb a) anim_structs
                                      | Init_int32 _ => true | _ => false end) (ldata_words t)) anim_tabs
  && forallb (fun t => Nat.ltb 0 (List.length (ldata_words t))) anim_ids = true.
Proof. vm_compute. reflexivity. Qed.

Definition anim_ok (ge : genv) (m : mem) : Prop :=
  forall t bt z d, In t anim_ids -> Genv.find_symbol ge t = Some bt ->
    In (z, d) (icells 0 (ldata_words t)) -> init_ld ge m bt z d.

(* the keep: the clause reads only the listed blocks *)
Lemma anim_ok_ext : forall (ge : genv) m m',
  (forall t b, In t anim_ids -> Genv.find_symbol ge t = Some b ->
     forall ch z, Mem.load ch m' b z = Mem.load ch m b z) ->
  anim_ok ge m -> anim_ok ge m'.
Proof.
  intros ge m m' K H t bt z d Ht Hs Hi. pose proof (H t bt z d Ht Hs Hi) as A.
  destruct d; cbn [init_ld] in A |- *; rewrite ?(K t bt Ht Hs); exact A.
Qed.

(* 3i, 2026-11-03 (OBJECTS row 55, SPAWN_WATER_DROPLET): the two droplet
   parameter structs name bhvWaterDroplet in their behavior field (byte 4,
   after two s16s).  TRUTH: index 2 of both initializers is
   Init_addrof _bhvWaterDroplet 0 (BhvStep.dparams_init); no code writes
   these globals (they are read only through spawn_water_droplet's params
   pointer).  Checked by vm on the boot witness (ow_chk). *)
Definition dparams : list ident :=
  [behavior_data._gShallowWaterSplashDropletParams; behavior_data._gShallowWaterWaveDropletParams].

Definition dp_ok (ge : genv) (m : mem) : Prop :=
  forall p bp, In p dparams -> Genv.find_symbol ge p = Some bp ->
    exists bwd, Genv.find_symbol ge behavior_data._bhvWaterDroplet = Some bwd
      /\ Mem.load Mint32 m bp 4 = Some (Vptr bwd Ptrofs.zero).

(* the keep: the clause reads only the two structs' blocks *)
Lemma dp_ok_ext : forall (ge : genv) m m',
  (forall p b, In p dparams -> Genv.find_symbol ge p = Some b ->
     forall ch z, Mem.load ch m' b z = Mem.load ch m b z) ->
  dp_ok ge m -> dp_ok ge m'.
Proof.
  intros ge m m' K H p bp Hp Hs. destruct (H p bp Hp Hs) as (bwd & S & L).
  exists bwd. split; [ exact S | rewrite (K p bp Hp Hs); exact L ].
Qed.

(* 3j, 2026-11-03 (detect_object_collisions, unload): every listed slot's
   numCollidedObjs (s16 at 118) is in [0, 4], and Mario's collidedObjs[0..3]
   (120..136) are NULL or slots.  TRUTH: numCollidedObjs is written by
   allocate_object (0), clear_object_collision (0) and
   detect_object_hitbox_overlap (++, only after the >= 4 tests);
   collidedObjs[i] only by detect_object_hitbox_overlap, with an object of
   a walked list (a slot), and the pool starts zeroed.  Checked by vm on the
   boot witness (ow_chk).  No PhiW clause reads an object's
   oIntangibleTimer (rawData word 5, offset 156), which
   clear_object_collision decrements (grep, 2026-11-03). *)
Definition O_NCOLL : Z := 118.
Definition O_COLLS : Z := 120.

Definition ncoll_ok (pool : block) (m : mem) (rs : list (list Z)) : Prop :=
  forall k, In k (concat rs) -> exists n, Mem.load Mint16signed m pool (k * OSZ + O_NCOLL) = Some (Vint n)
    /\ 0 <= Int.signed n <= 4.

Definition mcoll_ok (pool gmo : block) (m : mem) : Prop :=
  forall k, 0 <= k < NSLOT -> Mem.load Mint32 m gmo 0 = Some (slot_v pool k) ->
    forall i, 0 <= i < 4 -> exists v, Mem.load Mint32 m pool (k * OSZ + O_COLLS + 4 * i) = Some v
      /\ slot_ptr pool v.

(* CLS *)
Definition sp_bhvs : list ident :=
  [behavior_data._bhvPoleGrabbing; behavior_data._bhvCannon; behavior_data._bhvJumpingBox;
   behavior_data._bhvExclamationBox; behavior_data._bhvCannonClosed;
   behavior_data._bhvHiddenRedCoinStar; behavior_data._bhvMario].
Definition sp_states : list BhvVM.vst :=
  BhvVM.opt_list (BhvVM.explore 100000 (flat_map BhvVM.entries sp_bhvs) []).
Definition sp_scripts : list ident := map BhvVM.v_s sp_states.

(* slot k runs a special state *)
Definition sp_vm (ge : genv) (pool : block) (m : mem) (k : Z) : Prop :=
  exists st, In st BhvVM.vm_tab /\ In (BhvVM.v_s st) sp_scripts /\ vm_at ge pool m k st.

(* the surface half, with the walk read on mw and the slot's VM cells on
   mv (so a keeper keeps the two halves separately: the walk exactly as
   surf_obj_ok_ext keeps surf_obj_ok, the VM cells as slot fields) *)
Definition cls_surf_at (ge : genv) (pool : block) (mw mv : mem) : Prop :=
  forall P id bp z hd l o k,
    Ple (Genv.genv_next ge) P ->
    gcell ge surface_load._sSurfacePool Mint32 (Vptr P (Ptrofs.repr SP_OFF)) mw ->
    gcell ge surface_load._sSurfaceNodePool Mint32 (Vptr P (Ptrofs.repr NP_OFF)) mw ->
    In id FloorList.part_ids -> Genv.find_symbol ge id = Some bp ->
    Mem.load Mint32 mw bp z = Some hd -> swalk P mw SFUEL hd = Some l ->
    In (Vptr P o) l -> in_sp (Ptrofs.unsigned o) = true -> 0 <= k < NSLOT ->
    Mem.load Mint32 mw P (Ptrofs.unsigned o + S_OBJ) = Some (slot_v pool k) ->
    sp_vm ge pool mv k.

Definition cls_ok (ge : genv) (pool : block) (m : mem) (rs : list (list Z)) : Prop :=
  (forall k t, In k (concat rs) ->
     Mem.load Mint32 m pool (k * OSZ + O_INTERACT_TYPE) = Some (Vint t) ->
     Int.unsigned t = INTERACT_POLE \/ Int.unsigned t = INTERACT_CANNON_BASE ->
     sp_vm ge pool m k)
  /\ cls_surf_at ge pool m m.

(* the walk half's keep: the hypotheses of surf_obj_ok_ext *)
Lemma cls_surf_ext : forall (ge : genv) pool m m' mv,
  (forall id b, In id surf_gids -> Genv.find_symbol ge id = Some b ->
     forall ch z, Mem.load ch m' b z = Mem.load ch m b z) ->
  (forall P, Ple (Genv.genv_next ge) P ->
     gcell ge surface_load._sSurfacePool Mint32 (Vptr P (Ptrofs.repr SP_OFF)) m ->
     gcell ge surface_load._sSurfaceNodePool Mint32 (Vptr P (Ptrofs.repr NP_OFF)) m ->
     forall ch z, (NP_OFF <= z /\ z + size_chunk ch <= NP_END) \/ (SP_OFF <= z /\ z + size_chunk ch <= SP_END) ->
     Mem.load ch m' P z = Mem.load ch m P z) ->
  cls_surf_at ge pool m mv -> cls_surf_at ge pool m' mv.
Proof.
  intros ge pool m m' mv KG KP C P id bp z hd l o k HP G1 G2 Hin Hs L Hw Ho N Hk Lo.
  assert (Kc : forall id ch v, In id surf_gids -> gcell ge id ch v m' -> gcell ge id ch v m).
  { intros id' ch v Hin' (b & Hs' & L'). exists b. rewrite <- (KG id' b Hin' Hs'). exact (conj Hs' L'). }
  pose proof (Kc surface_load._sSurfacePool _ _ ltac:(cbn; auto) G1) as G1'.
  pose proof (Kc surface_load._sSurfaceNodePool _ _ ltac:(cbn; auto) G2) as G2'.
  pose proof (KP P HP G1' G2') as KR.
  rewrite (KG id bp ltac:(cbn [surf_gids]; right; right; exact Hin) Hs) in L.
  rewrite (swalk_ext P m m' (fun ch z H1 H2 => KR ch z (or_introl (conj H1 H2)))) in Hw.
  destruct (in_sp_spec _ N) as (N1 & N2).
  rewrite (KR Mint32 (Ptrofs.unsigned o + S_OBJ)) in Lo by (right; cbn [size_chunk]; unfold S_OBJ, SURF_SZ in *; lia).
  exact (C P id bp z hd l o k HP G1' G2' Hin Hs L Hw Ho N Hk Lo).
Qed.

(* ---------------------------------------------------------------------- *)
(* 4. obj_w.                                                                *)
(* ---------------------------------------------------------------------- *)
(* gDebugInfoFlags has DEBUG_INFO_FLAG_DPRINT (bit 0) clear (2026-11-07):
   the gate of debug.c's print_debug_top_down_mapinfo / _bottom_up /
   _top_down_objectinfo.  In the game: the global boots 0; its only
   generated store is debug_unknown_level_select_check's (from
   clear_objects), of 0 << 0 or 1 << 1, both with bit 0 clear
   (DebugKeep.dlsc_keeps). *)
Definition dflags_ok (ge : genv) (m : mem) : Prop :=
  forall b, Genv.find_symbol ge debug._gDebugInfoFlags = Some b ->
    exists n, Mem.load Mint32 m b 0 = Some (Vint n) /\ Int.and n Int.one = Int.zero.

Lemma dflags_ok_ext : forall (ge : genv) m m',
  (forall b, Genv.find_symbol ge debug._gDebugInfoFlags = Some b -> Mem.load Mint32 m' b 0 = Mem.load Mint32 m b 0) ->
  dflags_ok ge m -> dflags_ok ge m'.
Proof. intros ge m m' K D b Hs. rewrite (K b Hs). exact (D b Hs). Qed.

(* TIE (2026-11-07, for the generic frame keep of GOAL 2's object step):
   the slots whose fields obj_w reads by behavior run a special script.
   T1: a slot whose behavior is one of the act_pairs behaviors or the
   hidden red-coin star (act_ok / red_ok / coll_ok read its oAction,
   oHiddenStarTriggerCounter, position) runs an sp_scripts state.  In the
   game: a spawn sets the behavior and the script together, and every VM
   step keeps the script's class (ObjFamily.fam_chk_ok).
   T3: in a pole or cannon action (used_acts, Mario's action at bm 12),
   usedObj (bm 128) is a slot running an sp_scripts state.  In the game:
   only interact_pole / interact_cannon_base enter those actions, with
   usedObj the POLE / CANNON_BASE object, which runs a special state
   (ow_cls).  Both are checked on the boot witness (tie_b, in ow_chk). *)
Definition tie_bhvs : list ident :=
  [behavior_data._bhvJumpingBox; behavior_data._bhvCannon; behavior_data._bhvExclamationBox;
   behavior_data._bhvHiddenRedCoinStar].

Definition tie_ok (ge : genv) (pool bm : block) (m : mem) (rs : list (list Z)) : Prop :=
  (forall k bh, In k (concat rs) -> In bh tie_bhvs -> is_bhv ge pool m k bh -> sp_vm ge pool m k)
  /\ (forall a, Mem.load Mint32 m bm 12 = Some (Vint a) -> In (Int.unsigned a) used_acts ->
        exists k, 0 <= k < NSLOT /\ Mem.load Mint32 m bm USED_OFF = Some (slot_v pool k)
                  /\ sp_vm ge pool m k).

Record ow_core (ge : genv) (pool la fl gol gmo sdp gdi bm : block) (m : mem)
    (rs : list (list Z)) (fs : list Z) : Prop := {
  ow_gol : Mem.load Mint32 m gol 0 = Some (Vptr la Ptrofs.zero);
  ow_rings : rings m pool la = Some rs;
  ow_free : free_list m pool fl = Some fs;
  ow_part : NoDup (concat rs ++ fs) /\ Z.of_nat (List.length (concat rs ++ fs)) = NSLOT;
  ow_free_off : forall k, In k fs -> Mem.load Mint16signed m pool (k * OSZ + O_FLAGS) = Some (Vint Int.zero);
  ow_mario : exists k, In k (nth 0%nat rs [])
               /\ Mem.load Mint32 m gmo 0 = Some (slot_v pool k)
               /\ Mem.load Mint32 m bm MARIOOBJ_OFF = Some (slot_v pool k)
               /\ (forall j, In j (concat rs) -> j <> k -> kind_ok pool m j);
  ow_script : forall k, In k (concat rs) -> script_ok ge pool m k;
  ow_act : forall k, In k (concat rs) -> act_ok ge pool m k;
  ow_red : forall k, In k (concat rs) -> red_ok ge pool m k;
  (* 2026-11-07: sDebugPage is 0 (it boots 0 and no generated code stores
     it by name: try_modify_debug_controls, its only writer in debug.c, has
     no caller), so the debug spawner's guard (sDebugPage == STAGEINFO) and
     try_print_debug_mario_object_info's page switch are off *)
  ow_debug : Mem.load Mint8signed m sdp 0 = Some (Vint Int.zero) /\ dflags_ok ge m;
  ow_stale : forall z, In z [120; 124; 128; 132] ->
               exists v, Mem.load Mint32 m bm z = Some v /\ slot_ptr pool v;
  ow_order : order_ok ge m;
  ow_dry12 : forall k, In k (nth 12%nat rs []) -> script12_ok ge pool m k;
  ow_cmdtab : cmdtab_ok ge m;
  ow_vm : forall k, In k (concat rs) -> vm_ok ge pool m k;
  (* 3b, 2026-11-02 *)
  ow_spool : spool_ok ge m;
  ow_surf_obj : surf_obj_ok ge pool m;
  ow_coll : coll_ok ge pool m rs;
  (* 3c, 2026-11-02 *)
  ow_ctr : ctr_s_ok ge m;
  ow_ter : ter_ok ge pool m rs;
  (* 3d, 2026-11-03 *)
  ow_scr : scr_ok ge m;
  (* 3e, 2026-11-03 *)
  ow_mact : mact_ok ge pool gmo m;
  ow_resp : forall k, In k (concat rs) -> resp_ok ge pool m k;
  ow_gfx : gfx_ok ge pool m;
  (* 3f, 2026-11-03 *)
  ow_msurf : msurf_ok ge bm m;
  (* 3g, 2026-11-03 *)
  ow_par : par_ok ge pool m rs;
  (* 3h, 2026-11-03 *)
  ow_mvm : mvm_ok ge pool gmo m;
  ow_anim : anim_ok ge m;
  ow_cls : cls_ok ge pool m rs;
  (* 3i, 2026-11-03 *)
  ow_dp : dp_ok ge m;
  (* 3j, 2026-11-03 *)
  ow_ncoll : ncoll_ok pool m rs;
  ow_mcoll : mcoll_ok pool gmo m;
  (* 2026-11-07 *)
  ow_tie : tie_ok ge pool bm m rs
}.

Definition obj_w (ge : genv) (bm : block) (m : mem) : Prop :=
  exists pool la fl gol gmo sdp gdi rs fs,
    Genv.find_symbol ge object_list_processor._gObjectPool = Some pool
    /\ Genv.find_symbol ge object_list_processor._gObjectListArray = Some la
    /\ Genv.find_symbol ge object_list_processor._gFreeObjectList = Some fl
    /\ Genv.find_symbol ge object_list_processor._gObjectLists = Some gol
    /\ Genv.find_symbol ge object_list_processor._gMarioObject = Some gmo
    /\ Genv.find_symbol ge debug._sDebugPage = Some sdp
    /\ Genv.find_symbol ge debug._gDebugInfo = Some gdi
    /\ ow_core ge pool la fl gol gmo sdp gdi bm m rs fs.

(* ---------------------------------------------------------------------- *)
(* 5. The checker (stronger than obj_w where that is cheaper: a pole or    *)
(*    cannon base, an action-table behavior, the hidden red-coin star    *)
(*    are checked against their clause: 2026-11-02, the real-order boot  *)
(*    witness holds WMotR's placed objects -- exclamation boxes, the red- *)
(*    coin star, poles, cannons).                                         *)
(* ---------------------------------------------------------------------- *)
Fixpoint nodupb (l : list Z) : bool :=
  match l with [] => true | x :: l' => negb (existsb (Z.eqb x) l') && nodupb l' end.

Lemma nodupb_sound : forall l, nodupb l = true -> NoDup l.
Proof.
  induction l as [| x l IH]; intros H; [ constructor | ].
  cbn in H. apply andb_prop in H as [H1 H2]. constructor; [ | exact (IH H2) ].
  intro Hin. apply negb_true_iff in H1. apply (proj2 (not_true_iff_false _) H1).
  apply existsb_exists. exists x. split; [ exact Hin | apply Z.eqb_refl ].
Qed.

Definition vint_eqb (ov : option val) (z : Z) : bool :=
  match ov with Some (Vint i) => Int.eq i (Int.repr z) | _ => false end.

Lemma vint_eqb_sound : forall ov z, vint_eqb ov z = true -> ov = Some (Vint (Int.repr z)).
Proof.
  intros ov z H. destruct ov as [[| i | | | |]|]; try discriminate H.
  cbn in H. apply Int.same_if_eq in H. subst i. reflexivity.
Qed.

Section CHK.
  Variable ge : genv.
  Variables pool bm : block.
  Variable m : mem.

  Definition not_bhv_b (k : Z) (id : ident) : bool :=
    match Genv.find_symbol ge id, ld32 m pool (k * OSZ + O_BHV) with
    | Some b, Some v => negb (veqb v (Vptr b Ptrofs.zero))
    | _, _ => true
    end.

  Lemma not_bhv_b_sound : forall k id, not_bhv_b k id = true -> ~ is_bhv ge pool m k id.
  Proof.
    intros k id H (b & Hs & Hl). unfold not_bhv_b, ld32 in H.
    rewrite Hs, CM.load_eq, Hl in H. unfold veqb in H.
    destruct (Val.eq _ _) as [_ | N]; [ discriminate H | exact (N eq_refl) ].
  Qed.

  Definition script_b (k : Z) : bool :=
    match ld32 m pool (k * OSZ + O_CMD) with
    | Some (Vptr b _) =>
        existsb (fun id => match Genv.find_symbol ge id with Some b' => Pos.eqb b b' | None => false end)
          live_bhvs
    | _ => false
    end.

  Definition script12_b (k : Z) : bool :=
    match ld32 m pool (k * OSZ + O_CMD) with
    | Some (Vptr b _) =>
        existsb (fun id => match Genv.find_symbol ge id with Some b' => Pos.eqb b b' | None => false end)
          ObjCensus.live12
    | _ => false
    end.

  Lemma script12_b_sound : forall k, script12_b k = true -> script12_ok ge pool m k.
  Proof.
    intros k H. unfold script12_b, ld32 in H. rewrite CM.load_eq in H.
    destruct (Mem.load Mint32 m pool (k * OSZ + O_CMD)) as [[| | | | | b o]|] eqn:Hl;
      [ discriminate H .. | | discriminate H ].
    apply existsb_exists in H as (id & Hin & Hb).
    destruct (Genv.find_symbol ge id) as [b'|] eqn:Hs; [ | discriminate Hb ].
    apply Pos.eqb_eq in Hb. subst b'. exists id, b, o. exact (conj Hin (conj Hs Hl)).
  Qed.

  Lemma script_b_sound : forall k, script_b k = true -> script_ok ge pool m k.
  Proof.
    intros k H. unfold script_b, ld32 in H. rewrite CM.load_eq in H.
    destruct (Mem.load Mint32 m pool (k * OSZ + O_CMD)) as [[| | | | | b o]|] eqn:Hl;
      [ discriminate H .. | | discriminate H ].
    apply existsb_exists in H as (id & Hin & Hb).
    destruct (Genv.find_symbol ge id) as [b'|] eqn:Hs; [ | discriminate Hb ].
    apply Pos.eqb_eq in Hb. subst b'. exists id, b, o. exact (conj Hin (conj Hs Hl)).
  Qed.

  Definition sym_ptr_b (s : ident) (i : nat) (ov : option val) : bool :=
    match Genv.find_symbol ge s, ov with
    | Some b, Some (Vptr b' o) => Pos.eqb b b' && Ptrofs.eq o (Ptrofs.repr (4 * Z.of_nat i))
    | _, _ => false
    end.

  Lemma sym_ptr_b_sound : forall s i ov, sym_ptr_b s i ov = true ->
      exists b, Genv.find_symbol ge s = Some b /\ ov = Some (Vptr b (Ptrofs.repr (4 * Z.of_nat i))).
  Proof.
    intros s i ov H. unfold sym_ptr_b in H.
    destruct (Genv.find_symbol ge s) as [b|]; [ | discriminate H ].
    destruct ov as [[| | | | | b' o]|]; try discriminate H.
    apply andb_prop in H as [H1 H2]. apply Pos.eqb_eq in H1. subst b'.
    pose proof (Ptrofs.eq_spec o (Ptrofs.repr (4 * Z.of_nat i))) as E. rewrite H2 in E. subst o.
    exists b. split; reflexivity.
  Qed.

  Definition frame_b (f : BhvVM.frame) (ov : option val) : bool :=
    match f with
    | BhvVM.FAddr s i => sym_ptr_b s i ov
    | BhvVM.FCount => match ov with Some (Vint _) => true | _ => false end
    end.

  Lemma frame_b_sound : forall f ov, frame_b f ov = true -> frame_ok ge f ov.
  Proof.
    intros [s i |] ov H; cbn in H |- *.
    - exact (sym_ptr_b_sound s i ov H).
    - destruct ov as [[| c | | | |]|]; try discriminate H. exists c. reflexivity.
  Qed.

  Fixpoint frames_b (k : Z) (d n : nat) (l : list BhvVM.frame) : bool :=
    match l with
    | [] => true
    | f :: r => frame_b f (CM.load Mint32 m pool (stk_cell k d n)) && frames_b k d (S n) r
    end.

  Lemma frames_b_sound : forall k d l n0 n f, frames_b k d n0 l = true -> nth_error l n = Some f ->
      frame_ok ge f (Mem.load Mint32 m pool (stk_cell k d (n0 + n))).
  Proof.
    intros k d l. induction l as [| x r IH]; intros n0 n f H E; [ destruct n; discriminate E | ].
    cbn in H. apply andb_prop in H as [H1 H2]. destruct n as [| n].
    - cbn in E. injection E as <-. rewrite Nat.add_0_r. rewrite CM.load_eq in H1.
      exact (frame_b_sound _ _ H1).
    - cbn in E. rewrite <- Nat.add_succ_comm. exact (IH (S n0) n f H2 E).
  Qed.

  Definition st_b (k : Z) (st : BhvVM.vst) : bool :=
    sym_ptr_b (BhvVM.v_s st) (BhvVM.v_i st) (CM.load Mint32 m pool (k * OSZ + O_CMD))
    && vint_eqb (CM.load Mint32 m pool (k * OSZ + O_SIDX)) (Z.of_nat (List.length (BhvVM.v_k st)))
    && frames_b k (List.length (BhvVM.v_k st)) 0 (BhvVM.v_k st).

  (* stated over ANY state list, so no step can reduce BhvVM.vm_tab (it
     would run the VM) *)
  Lemma vm_b_sound_gen : forall k (l : list BhvVM.vst), existsb (st_b k) l = true ->
    exists st, In st l
      /\ (exists b, Genv.find_symbol ge (BhvVM.v_s st) = Some b
           /\ Mem.load Mint32 m pool (k * OSZ + O_CMD)
                = Some (Vptr b (Ptrofs.repr (4 * Z.of_nat (BhvVM.v_i st)))))
      /\ Mem.load Mint32 m pool (k * OSZ + O_SIDX)
           = Some (Vint (Int.repr (Z.of_nat (List.length (BhvVM.v_k st)))))
      /\ (forall n f, nth_error (BhvVM.v_k st) n = Some f ->
           frame_ok ge f (Mem.load Mint32 m pool (stk_cell k (List.length (BhvVM.v_k st)) n))).
  Proof.
    intros k l H. apply existsb_exists in H as (st & Hin & H).
    unfold st_b in H. apply andb_prop in H as [H H3]. apply andb_prop in H as [H1 H2].
    rewrite CM.load_eq in H1, H2.
    exists st. split; [ exact Hin | split; [ | split ] ].
    - exact (sym_ptr_b_sound _ _ _ H1).
    - exact (vint_eqb_sound _ _ H2).
    - intros n f E. exact (frames_b_sound k _ _ 0 n f H3 E).
  Qed.


  Definition act_in_b (k t : Z) : bool :=
    match ld32 m pool (k * OSZ + O_ACTION) with
    | Some (Vint a) => Z.leb 0 (Int.signed a) && Z.ltb (Int.signed a) t
    | _ => false
    end.

  Definition act_b (k : Z) : bool :=
    forallb (fun p => not_bhv_b k (fst p) || act_in_b k (tlen (snd p))) act_pairs.

  Lemma act_b_sound : forall k, act_b k = true -> act_ok ge pool m k.
  Proof.
    intros k H bh t Hin Hb.
    pose proof (proj1 (forallb_forall _ _) H _ Hin) as Hn. cbn [fst snd] in Hn.
    apply orb_true_iff in Hn as [Hn | Hn]; [ exfalso; exact (not_bhv_b_sound k bh Hn Hb) | ].
    unfold act_in_b, ld32 in Hn. rewrite CM.load_eq in Hn.
    destruct (Mem.load Mint32 m pool (k * OSZ + O_ACTION)) as [[| a | | | |]|]; try discriminate Hn.
    apply andb_prop in Hn as [H1 H2]. apply Z.leb_le in H1. apply Z.ltb_lt in H2.
    exists a. split; [ reflexivity | lia ].
  Qed.

  (* the float cells of a pole / cannon base (WMotRWorld's pins) *)
  Definition f32_at_b (o : Z) (v : val) : bool :=
    match CM.load Mfloat32 m pool o with Some w => veqb w v | None => false end.

  Lemma f32_at_b_sound : forall o v, f32_at_b o v = true -> Mem.load Mfloat32 m pool o = Some v.
  Proof.
    intros o v H. unfold f32_at_b in H. rewrite CM.load_eq in H.
    destruct (Mem.load Mfloat32 m pool o) as [w|]; [ | discriminate H ]. unfold veqb in H.
    destruct (Val.eq w v) as [-> | _]; [ reflexivity | discriminate H ].
  Qed.

  Definition pole_b (o : Z) : bool :=
    existsb (fun '(base, top) => f32_at_b (o + O_POSY) (f32z base)
                                 && f32_at_b (o + HITBOX_DOWN_OFF) (Vsingle Float32.zero)
                                 && f32_at_b (o + HITBOX_H_OFF) (f32z (top - base))) wmotr_pole_list.

  Lemma pole_b_sound : forall o, pole_b o = true -> pole_obj_ok m pool o.
  Proof.
    intros o H. apply existsb_exists in H as ([base top] & Hin & H).
    apply andb_prop in H as [H H3]. apply andb_prop in H as [H1 H2].
    exists base, top. split; [ exact Hin | ].
    exact (conj (f32_at_b_sound _ _ H1) (conj (f32_at_b_sound _ _ H2) (f32_at_b_sound _ _ H3))).
  Qed.

  Definition cannon_b (o : Z) : bool :=
    existsb (fun y => f32_at_b (o + O_POSY) (f32z (y - CANNON_SEAT))) wmotr_cannon_list.

  Lemma cannon_b_sound : forall o, cannon_b o = true -> cannon_obj_ok m pool o.
  Proof.
    intros o H. apply existsb_exists in H as (y & Hin & H).
    exists y. exact (conj Hin (f32_at_b_sound _ _ H)).
  Qed.

  Definition pole_xz_b (o : Z) : bool :=
    existsb (fun '(x, z, base, top) => f32_at_b (o + O_POSX) (f32z x)
                                       && f32_at_b (o + O_POSY) (f32z base)
                                       && f32_at_b (o + O_POSZ) (f32z z)) wmotr_pole_xz_list.

  Lemma pole_xz_b_sound : forall o, pole_xz_b o = true -> pole_xz_ok m pool o.
  Proof.
    intros o H. apply existsb_exists in H as ([[[x z] base] top] & Hin & H).
    apply andb_prop in H as [H H3]. apply andb_prop in H as [H1 H2].
    exists x, z, base, top. split; [ exact Hin | ].
    exact (conj (f32_at_b_sound _ _ H1) (conj (f32_at_b_sound _ _ H2) (f32_at_b_sound _ _ H3))).
  Qed.

  Definition cannon_xz_b (o : Z) : bool :=
    existsb (fun '(x, z, y) => f32_at_b (o + O_POSX) (f32z x)
                               && f32_at_b (o + O_POSY) (f32z (y - CANNON_SEAT))
                               && f32_at_b (o + O_POSZ) (f32z z)) wmotr_cannon_xzy.

  Lemma cannon_xz_b_sound : forall o, cannon_xz_b o = true -> cannon_xz_ok m pool o.
  Proof.
    intros o H. apply existsb_exists in H as ([[x z] y] & Hin & H).
    apply andb_prop in H as [H H3]. apply andb_prop in H as [H1 H2].
    exists x, z, y. split; [ exact Hin | ].
    exact (conj (f32_at_b_sound _ _ H1) (conj (f32_at_b_sound _ _ H2) (f32_at_b_sound _ _ H3))).
  Qed.

  Definition kind_b (k : Z) : bool :=
    match ld32 m pool (k * OSZ + O_INTERACT_TYPE) with
    | Some (Vint t) => existsb (Z.eqb (Int.unsigned t)) wmotr_interact_types
                       && (negb (Z.eqb (Int.unsigned t) INTERACT_POLE)
                           || (pole_b (k * OSZ) && pole_xz_b (k * OSZ)))
                       && (negb (Z.eqb (Int.unsigned t) INTERACT_CANNON_BASE)
                           || (cannon_b (k * OSZ) && cannon_xz_b (k * OSZ)))
    | _ => false
    end.

  Lemma kind_b_sound : forall k, kind_b k = true -> kind_ok pool m k.
  Proof.
    intros k H. unfold kind_b, ld32 in H. rewrite CM.load_eq in H.
    destruct (Mem.load Mint32 m pool (k * OSZ + O_INTERACT_TYPE)) as [[| t | | | |]|] eqn:Hl; try discriminate H.
    apply andb_prop in H as [H Hc]. apply andb_prop in H as [Hi Hp].
    apply existsb_exists in Hi as (z & Hz & E). apply Z.eqb_eq in E. subst z.
    exists t. split; [ exact Hl | split; [ exact Hz | ] ].
    split; [ | split; [ | split ] ].
    - intro E. apply Z.eqb_eq in E. rewrite E in Hp. cbn in Hp.
      apply andb_prop in Hp as [Hp _]. exact (pole_b_sound _ Hp).
    - intro E. apply Z.eqb_eq in E. rewrite E in Hc. cbn in Hc.
      apply andb_prop in Hc as [Hc _]. exact (cannon_b_sound _ Hc).
    - intro E. apply Z.eqb_eq in E. rewrite E in Hp. cbn in Hp.
      apply andb_prop in Hp as [_ Hp]. exact (pole_xz_b_sound _ Hp).
    - intro E. apply Z.eqb_eq in E. rewrite E in Hc. cbn in Hc.
      apply andb_prop in Hc as [_ Hc]. exact (cannon_xz_b_sound _ Hc).
  Qed.

  Definition red_b (k : Z) : bool :=
    not_bhv_b k behavior_data._bhvStarSpawnCoordinates
    && (not_bhv_b k behavior_data._bhvHiddenRedCoinStar
        || match ld32 m pool (k * OSZ + O_HSCOUNT) with
           | Some (Vint c) => Z.ltb (Int.signed c) 8
           | _ => false
           end).

  Lemma red_b_sound : forall k, red_b k = true -> red_ok ge pool m k.
  Proof.
    intros k H. apply andb_prop in H as [H1 H2].
    split; [ exact (not_bhv_b_sound _ _ H1) | intros Hb ].
    apply orb_true_iff in H2 as [H2 | H2]; [ exfalso; exact (not_bhv_b_sound _ _ H2 Hb) | ].
    unfold ld32 in H2. rewrite CM.load_eq in H2.
    destruct (Mem.load Mint32 m pool (k * OSZ + O_HSCOUNT)) as [[| c | | | |]|]; try discriminate H2.
    apply Z.ltb_lt in H2. exists c. split; [ reflexivity | exact H2 ].
  Qed.

  Definition slot_ptr_b (v : val) : bool :=
    veqb v Vnullptr ||
    match v with
    | Vptr b o => (if eq_block b pool then true else false)
                  && match slot_of (Ptrofs.unsigned o) with Some _ => true | None => false end
    | _ => false
    end.

  Lemma slot_of_spec : forall o k, slot_of o = Some k ->
      0 <= k < NSLOT /\ o = k * OSZ.
  Proof.
    intros o k H. unfold slot_of in H.
    destruct ((0 <=? o) && (o <? NSLOT * OSZ) && (o mod OSZ =? 0)) eqn:E; [ | discriminate H ].
    injection H as <-. apply andb_prop in E as [E E3]. apply andb_prop in E as [E1 E2].
    apply Z.leb_le in E1. apply Z.ltb_lt in E2. apply Z.eqb_eq in E3.
    unfold OSZ, NSLOT in *.
    pose proof (Z.div_mod o 608 ltac:(lia)) as D. rewrite E3 in D.
    split; [ split; [ apply Z.div_pos; lia | apply Z.div_lt_upper_bound; lia ] | lia ].
  Qed.

  Lemma slot_ptr_b_sound : forall v, slot_ptr_b v = true -> slot_ptr pool v.
  Proof.
    intros v H. unfold slot_ptr_b, veqb in H. apply orb_true_iff in H as [H | H].
    - destruct (Val.eq v Vnullptr) as [E | _]; [ left; exact E | discriminate H ].
    - destruct v as [| | | | | b o]; try discriminate H.
      apply andb_prop in H as [Hb Hs]. destruct (eq_block b pool) as [-> | _]; [ | discriminate Hb ].
      destruct (slot_of (Ptrofs.unsigned o)) as [k|] eqn:Hk; [ | discriminate Hs ].
      destruct (slot_of_spec _ _ Hk) as (Hr & Ho). right. exists k. split; [ exact Hr | ].
      unfold slot_v. rewrite <- Ho, Ptrofs.repr_unsigned. reflexivity.
  Qed.
End CHK.

Definition vint_is (ov : option val) (z : Z) : bool :=
  match ov with Some (Vint i) => Z.eqb (Int.unsigned i) z | _ => false end.

Definition order_b (ge : genv) (m : mem) : bool :=
  match Genv.find_symbol ge object_list_processor._sObjectListUpdateOrder with
  | Some b => forallb (fun j => match CM.load Mint8signed m b (Z.of_nat j) with
                                | Some (Vint i) => Int.eq i (Int.repr (nth j upd_order 0))
                                | _ => false end) (seq 0 11)
  | None => false
  end.

Lemma order_b_sound : forall ge m, order_b ge m = true -> order_ok ge m.
Proof.
  intros ge m H. unfold order_b in H.
  destruct (Genv.find_symbol ge object_list_processor._sObjectListUpdateOrder) as [b|] eqn:Hs; [ | discriminate H ].
  exists b. split; [ exact Hs | ]. intros j Hj.
  pose proof (proj1 (forallb_forall _ _) H j (proj2 (in_seq 11 0 j) (conj (Nat.le_0_l j) Hj))) as Hz.
  cbn beta in Hz. rewrite CM.load_eq in Hz.
  destruct (Mem.load Mint8signed m b (Z.of_nat j)) as [[| i | | | |]|]; try discriminate Hz.
  apply Int.same_if_eq in Hz. subst i. reflexivity.
Qed.

Section CMDTAB.
  Variable ge : genv.
  Variable m : mem.
  Variable b : block.

  Definition cell_b (j : nat) (id : ident) : bool :=
    match Genv.find_symbol ge id, CM.load Mint32 m b (4 * Z.of_nat j) with
    | Some hb, Some (Vptr hb' o) => Pos.eqb hb hb' && Ptrofs.eq o Ptrofs.zero
    | _, _ => false
    end.

  Fixpoint cells_from (j : nat) (l : list ident) : bool :=
    match l with [] => true | id :: r => cell_b j id && cells_from (S j) r end.

  Lemma cells_from_sound : forall l j n id, cells_from j l = true -> nth_error l n = Some id ->
      cell_b (j + n) id = true.
  Proof.
    induction l as [| x r IH]; intros j n id H E; [ destruct n; discriminate E | ].
    cbn in H. apply andb_prop in H as [H1 H2]. destruct n as [| n].
    - cbn in E. injection E as <-. rewrite Nat.add_0_r. exact H1.
    - cbn in E. rewrite <- Nat.add_succ_comm. exact (IH (S j) n id H2 E).
  Qed.

  Lemma cell_b_sound : forall j id, cell_b j id = true ->
      exists hb, Genv.find_symbol ge id = Some hb
        /\ Mem.load Mint32 m b (4 * Z.of_nat j) = Some (Vptr hb Ptrofs.zero).
  Proof.
    intros j id H. unfold cell_b in H. rewrite CM.load_eq in H.
    destruct (Genv.find_symbol ge id) as [hb|]; [ | discriminate H ].
    destruct (Mem.load Mint32 m b (4 * Z.of_nat j)) as [[| | | | | hb' o]|]; try discriminate H.
    apply andb_prop in H as [H1 H2]. apply Pos.eqb_eq in H1. subst hb'.
    pose proof (Ptrofs.eq_spec o Ptrofs.zero) as E. rewrite H2 in E. subst o.
    exists hb. split; reflexivity.
  Qed.
End CMDTAB.

Definition cmdtab_b (ge : genv) (m : mem) : bool :=
  match Genv.find_symbol ge behavior_script._BehaviorCmdTable with
  | Some b => cells_from ge m b 0 ObjCensus.cmd_handlers
  | None => false
  end.

Lemma cmdtab_b_sound : forall ge m, cmdtab_b ge m = true -> cmdtab_ok ge m.
Proof.
  intros ge m H. unfold cmdtab_b in H.
  destruct (Genv.find_symbol ge behavior_script._BehaviorCmdTable) as [b|] eqn:Hs; [ | discriminate H ].
  exists b. split; [ exact Hs | ]. intros j id E.
  exact (cell_b_sound ge m b j id (cells_from_sound ge m b _ 0 j id H E)).
Qed.

Lemma veqb_eq : forall x y, veqb x y = true -> x = y.
Proof. intros x y H. unfold veqb in H. destruct (Val.eq x y); [ assumption | discriminate H ]. Qed.

(* the surface clauses' checkers (3b) *)
Definition gcell_b (ge : genv) (id : ident) (ch : memory_chunk) (v : val) (m : mem) : bool :=
  match Genv.find_symbol ge id with
  | Some b => match CM.load ch m b 0 with Some w => veqb w v | None => false end
  | None => false
  end.

Lemma gcell_b_sound : forall ge id ch v m, gcell_b ge id ch v m = true -> gcell ge id ch v m.
Proof.
  intros ge id ch v m H. unfold gcell_b in H.
  destruct (Genv.find_symbol ge id) as [b|] eqn:Hs; [ | discriminate H ]. rewrite CM.load_eq in H.
  destruct (Mem.load ch m b 0) as [w|] eqn:L; [ | discriminate H ].
  apply veqb_eq in H. subst w. exists b. split; [ exact Hs | exact L ].
Qed.

Definition spool_b (ge : genv) (m : mem) : bool :=
  match Genv.find_symbol ge surface_load._sSurfacePool with
  | Some sp =>
      match CM.load Mint32 m sp 0 with
      | Some (Vptr P _) =>
          Pos.leb (Genv.genv_next ge) P
          && gcell_b ge surface_load._sSurfacePool Mint32 (Vptr P (Ptrofs.repr SP_OFF)) m
          && gcell_b ge surface_load._sSurfaceNodePool Mint32 (Vptr P (Ptrofs.repr NP_OFF)) m
          && gcell_b ge surface_load._sSurfacePoolSize Mint16signed (Vint (Int.repr SP_CAP)) m
          && gcell_b ge surface_load._gNumStaticSurfaces Mint32 (Vint (Int.repr NS)) m
          && gcell_b ge surface_load._gNumStaticSurfaceNodes Mint32 (Vint (Int.repr NN)) m
      | _ => false
      end
  | None => false
  end.

Lemma spool_b_sound : forall ge m, spool_b ge m = true -> spool_ok ge m.
Proof.
  intros ge m H. unfold spool_b in H.
  destruct (Genv.find_symbol ge surface_load._sSurfacePool) as [sp|]; [ | discriminate H ].
  destruct (CM.load Mint32 m sp 0) as [[| | | | | P o]|]; try discriminate H.
  apply andb_prop in H as [H H5]. apply andb_prop in H as [H H4]. apply andb_prop in H as [H H3].
  apply andb_prop in H as [H H2]. apply andb_prop in H as [H0 H1].
  exists P. split; [ apply Pos.leb_le in H0; exact H0 | ].
  exact (conj (gcell_b_sound _ _ _ _ _ H1) (conj (gcell_b_sound _ _ _ _ _ H2)
          (conj (gcell_b_sound _ _ _ _ _ H3) (conj (gcell_b_sound _ _ _ _ _ H4) (gcell_b_sound _ _ _ _ _ H5))))).
Qed.

Definition surf_obj_at_b (P pool : block) (m : mem) (s : val) : bool :=
  match s with
  | Vptr b o =>
      Pos.eqb b P && in_sp (Ptrofs.unsigned o)
      && match CM.load Mint32 m b (Ptrofs.unsigned o + S_OBJ) with
         | Some (Vint i) => Int.eq i Int.zero
         | Some (Vptr pb po) =>
             (if eq_block pb pool then true else false)
             && match slot_of (Ptrofs.unsigned po) with
                | Some k => forallb (fun j => vint_eqb (CM.load Mint32 m pool (k * OSZ + RAW_OFF + 4 * j)) 0) ANGV
                | None => false
                end
         | _ => false
         end
  | _ => false
  end.

Lemma surf_obj_at_b_sound : forall P pool m s, surf_obj_at_b P pool m s = true -> surf_obj_at P pool m s.
Proof.
  intros P pool m s H. destruct s as [| | | | | b o]; try discriminate H.
  cbn [surf_obj_at_b] in H. apply andb_prop in H as [H0 H]. apply andb_prop in H0 as [Hb0 Hn].
  apply Pos.eqb_eq in Hb0. subst b.
  exists o. split; [ reflexivity | split; [ exact Hn | ] ]. rewrite CM.load_eq in H.
  destruct (Mem.load Mint32 m P (Ptrofs.unsigned o + S_OBJ)) as [[| i | | | | pb po]|] eqn:L; try discriminate H.
  - left. apply Int.same_if_eq in H. subst i. reflexivity.
  - right. apply andb_prop in H as [Hb Hs]. destruct (eq_block pb pool) as [-> | _]; [ | discriminate Hb ].
    destruct (slot_of (Ptrofs.unsigned po)) as [k|] eqn:Hk; [ | discriminate Hs ].
    destruct (slot_of_spec _ _ Hk) as (Hr & Ho). exists k. split; [ exact Hr | split ].
    + unfold slot_v. rewrite <- Ho, Ptrofs.repr_unsigned. reflexivity.
    + intros j Hj. pose proof (proj1 (forallb_forall _ _) Hs j Hj) as E. cbv beta in E.
      rewrite CM.load_eq in E. exact (vint_eqb_sound _ _ E).
Qed.

Definition surf_b (ge : genv) (pool : block) (m : mem) : bool :=
  match Genv.find_symbol ge surface_load._sSurfaceNodePool with
  | Some nb =>
      match CM.load Mint32 m nb 0 with
      | Some (Vptr P _) =>
          Pos.leb (Genv.genv_next ge) P
          && gcell_b ge surface_load._sSurfacePool Mint32 (Vptr P (Ptrofs.repr SP_OFF)) m
          && gcell_b ge surface_load._sSurfaceNodePool Mint32 (Vptr P (Ptrofs.repr NP_OFF)) m
          && forallb (fun id =>
               match Genv.find_symbol ge id with
               | Some bp =>
                   forallb (fun j => match CM.load Mint32 m bp (4 * Z.of_nat j) with
                                     | Some hd => match swalk P m SFUEL hd with
                                                  | Some l => forallb (surf_obj_at_b P pool m) l
                                                  | None => false end
                                     | None => true end) (seq 0 PCELLS)
               | None => false
               end) FloorList.part_ids
      | _ => false
      end
  | None => false
  end.

Lemma surf_b_sound : forall ge pool m, part_cells ge m -> surf_b ge pool m = true -> surf_obj_ok ge pool m.
Proof.
  intros ge pool m PC H. unfold surf_b in H.
  destruct (Genv.find_symbol ge surface_load._sSurfaceNodePool) as [nb|]; [ | discriminate H ].
  destruct (CM.load Mint32 m nb 0) as [[| | | | | P po]|]; try discriminate H.
  apply andb_prop in H as [H H3]. apply andb_prop in H as [H H2]. apply andb_prop in H as [H0 H1].
  exists P. split; [ apply Pos.leb_le in H0; exact H0 | ].
  split; [ exact (gcell_b_sound _ _ _ _ _ H1) | split; [ exact (gcell_b_sound _ _ _ _ _ H2) | ] ].
  intros id bp z hd Hin Hs L.
  pose proof (PC id bp z hd Hin Hs L) as Bz.
  destruct (Mem.load_valid_access _ _ _ _ _ L) as (_ & (q & Eq)). cbn [align_chunk] in Eq.
  change (Z.of_nat PCELLS) with 1536 in Bz.
  assert (Hq : 0 <= q < 1536) by lia.
  set (j := Z.to_nat q).
  assert (Ez : z = 4 * Z.of_nat j) by (unfold j; rewrite Z2Nat.id by lia; lia).
  assert (Hj : (j < PCELLS)%nat)
    by (apply Nat2Z.inj_lt; unfold j; rewrite Z2Nat.id by lia; change (Z.of_nat PCELLS) with 1536; lia).
  rewrite Ez in L. clearbody j. clear Eq Bz Ez Hq.
  pose proof (proj1 (forallb_forall _ _) H3 id Hin) as H4. cbv beta in H4. rewrite Hs in H4.
  pose proof (proj1 (forallb_forall _ _) H4 j (proj2 (in_seq PCELLS 0 j) (conj (Nat.le_0_l j) Hj))) as H5.
  cbv beta in H5. rewrite CM.load_eq, L in H5.
  destruct (swalk P m SFUEL hd) as [l|]; [ | discriminate H5 ].
  exists l. split; [ reflexivity | ]. apply Forall_forall. intros s Hs'.
  exact (surf_obj_at_b_sound _ _ _ _ (proj1 (forallb_forall _ _) H5 s Hs')).
Qed.

Definition box_pos_b (pool : block) (m : mem) (k : Z) : bool :=
  existsb (fun '(x, y, z) => f32_at_b pool m (k * OSZ + O_POSX) (f32z x)
                             && f32_at_b pool m (k * OSZ + O_POSY) (f32z y)
                             && f32_at_b pool m (k * OSZ + O_POSZ) (f32z z)) box_xyz.

Lemma box_pos_b_sound : forall pool m k, box_pos_b pool m k = true -> box_pos_ok pool m k.
Proof.
  intros pool m k H. apply existsb_exists in H as ([[x y] z] & Hin & H).
  apply andb_prop in H as [H H3]. apply andb_prop in H as [H1 H2].
  exists x, y, z. split; [ exact Hin | ].
  exact (conj (f32_at_b_sound _ _ _ _ H1) (conj (f32_at_b_sound _ _ _ _ H2) (f32_at_b_sound _ _ _ _ H3))).
Qed.

Definition coll_b (ge : genv) (pool : block) (m : mem) (rs : list (list Z)) : bool :=
  (Z.of_nat (List.length (filter (is_bhv_b ge pool m macro_special_objects._bhvExclamationBox) (concat rs))) <=? N_BOX)
  && (Z.of_nat (List.length (filter (is_bhv_b ge pool m macro_special_objects._bhvCannonClosed) (concat rs))) <=? N_LID)
  && forallb (fun k => negb (is_bhv_b ge pool m macro_special_objects._bhvExclamationBox k) || box_pos_b pool m k)
       (concat rs).

Lemma coll_b_sound : forall ge pool m rs, coll_b ge pool m rs = true -> coll_ok ge pool m rs.
Proof.
  intros ge pool m rs H. apply andb_prop in H as [H H3]. apply andb_prop in H as [H1 H2].
  apply Z.leb_le in H1. apply Z.leb_le in H2.
  split; [ exact H1 | split; [ exact H2 | ] ]. intros k Hk Hb.
  pose proof (proj1 (forallb_forall _ _) H3 k Hk) as E. cbv beta in E. rewrite Hb in E.
  exact (box_pos_b_sound _ _ _ E).
Qed.

Definition ctr_b (ge : genv) (m : mem) : bool :=
  match Genv.find_symbol ge surface_load._gSurfacesAllocated, Genv.find_symbol ge surface_load._gSurfaceNodesAllocated with
  | Some ba, Some bn =>
      match CM.load Mint32 m ba 0, CM.load Mint32 m bn 0 with
      | Some (Vint a), Some (Vint n) =>
          (NS <=? Int.signed a) && (Int.signed a <=? NS + DS) && (NN <=? Int.signed n) && (Int.signed n <=? NN + DN)
      | _, _ => false
      end
  | _, _ => false
  end.

Lemma ctr_b_sound : forall ge m, ctr_b ge m = true -> ctr_ok ge m.
Proof.
  intros ge m H. unfold ctr_b in H.
  destruct (Genv.find_symbol ge surface_load._gSurfacesAllocated) as [ba|] eqn:Ha; [ | discriminate H ].
  destruct (Genv.find_symbol ge surface_load._gSurfaceNodesAllocated) as [bn|] eqn:Hn; [ | discriminate H ].
  rewrite !CM.load_eq in H.
  destruct (Mem.load Mint32 m ba 0) as [[| a | | | |]|] eqn:La; try discriminate H.
  destruct (Mem.load Mint32 m bn 0) as [[| n | | | |]|] eqn:Ln; try discriminate H.
  apply andb_prop in H as [H H4]. apply andb_prop in H as [H H3]. apply andb_prop in H as [H1 H2].
  apply Z.leb_le in H1, H2, H3, H4.
  exists a, n. split; [ exists ba; exact (conj Ha La) | split; [ lia | split; [ exists bn; exact (conj Hn Ln) | lia ] ] ].
Qed.

Definition ctr_s_b (ge : genv) (m : mem) : bool :=
  match Genv.find_symbol ge surface_load._gSurfacesAllocated with
  | Some ba => match CM.load Mint32 m ba 0 with
               | Some (Vint a) => (NS <=? Int.signed a) && (Int.signed a <=? NS + DS)
               | _ => false
               end
  | None => false
  end.

Lemma ctr_s_b_sound : forall ge m, ctr_s_b ge m = true -> ctr_s_ok ge m.
Proof.
  intros ge m H. unfold ctr_s_b in H.
  destruct (Genv.find_symbol ge surface_load._gSurfacesAllocated) as [ba|] eqn:Ha; [ | discriminate H ].
  rewrite CM.load_eq in H.
  destruct (Mem.load Mint32 m ba 0) as [[| a | | | |]|] eqn:La; try discriminate H.
  apply andb_prop in H as [H1 H2]. apply Z.leb_le in H1, H2.
  exists a. split; [ exists ba; exact (conj Ha La) | lia ].
Qed.

Fixpoint idx_from (n : nat) (l : list Z) : list (nat * Z) :=
  match l with [] => [] | x :: r => (n, x) :: idx_from (S n) r end.

Lemma idx_from_in : forall l n j x, nth_error l j = Some x -> In (n + j, x)%nat (idx_from n l).
Proof.
  induction l as [| y l IH]; intros n j x H; [ destruct j; discriminate H | ].
  destruct j as [| j]; cbn in H.
  - injection H as <-. left. f_equal. lia.
  - right. replace (n + S j)%nat with (S n + j)%nat by lia. exact (IH _ _ _ H).
Qed.

Definition mesh_b (ge : genv) (id : ident) (l : list Z) (m : mem) : bool :=
  match Genv.find_symbol ge id with
  | Some b => forallb (fun p => match CM.load Mint16signed m b (2 * Z.of_nat (fst p)) with
                               | Some v => veqb v (Vint (Int.repr (snd p)))
                               | None => false
                               end) (idx_from 0 l)
  | None => false
  end.

Lemma mesh_b_sound : forall ge id l m, mesh_b ge id l m = true -> mesh_ok ge id l m.
Proof.
  intros ge id l m H. unfold mesh_b in H.
  destruct (Genv.find_symbol ge id) as [b|] eqn:Hs; [ | discriminate H ].
  exists b. split; [ first [ exact Hs | reflexivity ] | ]. intros j x Hj.
  pose proof (proj1 (forallb_forall _ _) H _ (idx_from_in l 0 j x Hj)) as E. cbv beta in E.
  cbn [fst snd Nat.add] in E. rewrite CM.load_eq in E.
  destruct (Mem.load Mint16signed m b (2 * Z.of_nat j)) as [v|]; [ | discriminate E ].
  rewrite (veqb_eq _ _ E). reflexivity.
Qed.

Definition mesh_ptr_b (ge : genv) (id : ident) (ov : option val) : bool :=
  match ov with
  | Some (Vint i) => Int.eq i Int.zero
  | Some (Vptr b o) => sym_is ge id b && Ptrofs.eq o Ptrofs.zero
  | _ => false
  end.

Lemma mesh_ptr_b_sound : forall ge id ov, mesh_ptr_b ge id ov = true -> mesh_ptr ge id ov.
Proof.
  intros ge id [[| i | | | | b o]|] H; try discriminate H; cbn in H.
  - left. apply Int.same_if_eq in H. subst i. reflexivity.
  - right. apply andb_prop in H as [H1 H2]. unfold sym_is in H1.
    destruct (Genv.find_symbol ge id) as [b'|] eqn:Hs; [ | discriminate H1 ].
    apply Pos.eqb_eq in H1. subst b'. apply Ptrofs.same_if_eq in H2. subst o.
    exists b. split; [ first [ exact Hs | reflexivity ] | reflexivity ].
Qed.

Definition coll_pin_b (ge : genv) (pool : block) (m : mem) (k : Z) : bool :=
  (negb (runs ge pool m k BOXS) || mesh_ptr_b ge BOXM (CM.load Mint32 m pool (k * OSZ + O_COLL)))
  && (negb (runs ge pool m k LIDS) || mesh_ptr_b ge LIDM (CM.load Mint32 m pool (k * OSZ + O_COLL))).

Lemma coll_pin_b_sound : forall ge pool m k, coll_pin_b ge pool m k = true -> coll_pin ge pool m k.
Proof.
  intros ge pool m k H. unfold coll_pin_b in H. rewrite CM.load_eq in H.
  apply andb_prop in H as [H1 H2]. split; intros E.
  - rewrite E in H1. exact (mesh_ptr_b_sound _ _ _ H1).
  - rewrite E in H2. exact (mesh_ptr_b_sound _ _ _ H2).
Qed.

Definition ter_b (ge : genv) (pool : block) (m : mem) (rs : list (list Z)) : bool :=
  forallb (fun i => forallb (fun k => Z.eqb (sdyn ge pool m k) 0 || Nat.eqb i 9) (nth i rs []))
          (seq 0 (List.length rs))
  && forallb (fun k => runs ge pool m k BOXS || runs ge pool m k LIDS || runs ge pool m k COINF)
             (nth 9 rs [] ++ nth 11 rs [])
  && (sumz (map (sdyn ge pool m) (nth 9 rs [])) <=? DS)
  && forallb (coll_pin_b ge pool m) (concat rs)
  && mesh_b ge BOXM (shorts box_init) m && mesh_b ge LIDM (shorts lid_init) m.

Lemma ter_b_sound : forall ge pool m rs, ter_b ge pool m rs = true -> ter_ok ge pool m rs.
Proof.
  intros ge pool m rs H. unfold ter_b in H.
  apply andb_prop in H as [H H6]. apply andb_prop in H as [H H5]. apply andb_prop in H as [H H4].
  apply andb_prop in H as [H H3]. apply andb_prop in H as [H1 H2].
  split; [ | split; [ | split; [ | split; [ | split ] ] ] ].
  - intros i k Hk Hn. destruct (Nat.lt_ge_cases i (List.length rs)) as [Hi | Hi].
    + assert (Hs : In i (seq 0 (List.length rs))) by (apply in_seq; lia).
      pose proof (proj1 (forallb_forall _ _) H1 i Hs) as E. cbv beta in E.
      pose proof (proj1 (forallb_forall _ _) E k Hk) as E2. apply orb_true_iff in E2 as [E2 | E2].
      * apply Z.eqb_eq in E2. contradiction.
      * apply Nat.eqb_eq in E2. exact E2.
    + rewrite nth_overflow in Hk by exact Hi. destruct Hk.
  - intros i k Hi Hk.
    assert (Hk' : In k (nth 9 rs [] ++ nth 11 rs []))
      by (apply in_or_app; destruct Hi as [-> | ->]; [ left | right ]; exact Hk).
    pose proof (proj1 (forallb_forall _ _) H2 k Hk') as E. cbv beta in E.
    apply orb_true_iff in E as [E | E]; [ apply orb_true_iff in E as [E | E] | ].
    + left. exact E.
    + right. left. exact E.
    + right. right. exact E.
  - apply Z.leb_le. exact H3.
  - intros k Hk. exact (coll_pin_b_sound _ _ _ _ (proj1 (forallb_forall _ _) H4 k Hk)).
  - exact (mesh_b_sound _ _ _ _ H5).
  - exact (mesh_b_sound _ _ _ _ H6).
Qed.

(* the scripts' checker (3d): each cell of each listed script against its
   initializer *)
Section ScrCheck.
  Variable G : genv.

  Definition scell_b (m : mem) (b : block) (i : nat) (d : init_data) : bool :=
    match d with
    | Init_int32 n =>
        match CM.load Mint32 m b (4 * Z.of_nat i) with Some (Vint n') => Int.eq n n' | _ => false end
    | Init_addrof t o =>
        match Genv.find_symbol G t, CM.load Mint32 m b (4 * Z.of_nat i) with
        | Some bt, Some (Vptr b' o') => Pos.eqb bt b' && Ptrofs.eq o o'
        | _, _ => false
        end
    | _ => match CM.load Mint32 m b (4 * Z.of_nat i) with Some _ => true | None => false end
    end.

  Fixpoint scells_b (m : mem) (b : block) (i : nat) (l : list init_data) : bool :=
    match l with [] => true | d :: l' => scell_b m b i d && scells_b m b (S i) l' end.

  (* the check over a symbol list l; used with l := sdedup (map v_s vm_tab),
     written out (PERF TRAP) *)
  Definition scr_b_l (l : list ident) (m : mem) : bool :=
    forallb (fun s => match Genv.find_symbol G s with
                      | Some b => scells_b m b 0 (BhvVM.words s) | None => false end) l.

  Lemma scell_b_sound : forall m b i d, scell_b m b i d = true ->
    exists v, Mem.load Mint32 m b (4 * Z.of_nat i) = Some v /\ init_val G d v.
  Proof.
    intros m b i d H. unfold scell_b in H. rewrite !CM.load_eq in H. revert H.
    generalize (4 * Z.of_nat i) as z. intros z H. destruct d;
      try (destruct (Mem.load Mint32 m b z) as [v|]; [ exists v; split; [ reflexivity | exact I ] | discriminate H ]).
    - destruct (Mem.load Mint32 m b z) as [[]|]; try discriminate H.
      apply Int.same_if_eq in H. subst. eexists; split; reflexivity.
    - destruct (Genv.find_symbol G i0) as [bt|] eqn:Eb; [ | discriminate H ].
      destruct (Mem.load Mint32 m b z) as [[]|]; try discriminate H.
      apply andb_prop in H as [H1 H2]. apply Pos.eqb_eq in H1. apply Ptrofs.same_if_eq in H2.
      subst. eexists; split; [ reflexivity | exists b0; auto ].
  Qed.

  Lemma scells_b_sound : forall m b l i, scells_b m b i l = true ->
    forall k d, nth_error l k = Some d ->
      exists v, Mem.load Mint32 m b (4 * Z.of_nat (i + k)) = Some v /\ init_val G d v.
  Proof.
    intros m b l. induction l as [| d0 l IH]; intros i H k d Hk; [ destruct k; discriminate Hk | ].
    cbn [scells_b] in H. apply andb_prop in H as [H1 H2].
    destruct k as [|k]; cbn in Hk.
    - injection Hk as <-. rewrite Nat.add_0_r. exact (scell_b_sound _ _ _ _ H1).
    - replace (i + S k)%nat with (S i + k)%nat by lia. exact (IH _ H2 k d Hk).
  Qed.

  Lemma scr_b_l_sound : forall l, (forall s, In s (map BhvVM.v_s BhvVM.vm_tab) -> In s l) ->
    forall m, scr_b_l l m = true -> scr_ok G m.
  Proof.
    intros l Hl m H s bs i d Hs Hin Hd. unfold scr_b_l in H.
    pose proof (proj1 (forallb_forall _ l) H s (Hl s Hin)) as H1. clear H.
    cbv beta in H1. rewrite Hs in H1.
    exact (scells_b_sound _ _ _ _ H1 i d Hd).
  Qed.

  (* SOUND: the deduplicated check over every script the VM can reach *)
  Theorem scr_b_sound : forall m, scr_b_l (sdedup (map BhvVM.v_s BhvVM.vm_tab)) m = true -> scr_ok G m.
  Proof.
    exact (scr_b_l_sound (sdedup (map BhvVM.v_s BhvVM.vm_tab)) (fun s => sdedup_in s (map BhvVM.v_s BhvVM.vm_tab))).
  Qed.
End ScrCheck.

(* 3e's checkers *)
Definition mstk_b (m : mem) (pool b : block) (k : Z) : bool :=
  match ld32 m pool (k * OSZ + O_SIDX) with
  | Some (Vint d) =>
      forallb (fun n => negb (n <? Z.min (Int.unsigned d) 8)
                        || match ld32 m pool (k * OSZ + O_STK + 4 * n) with
                           | Some (Vptr b' _) => Pos.eqb b' b
                           | Some (Vint _) => true
                           | _ => false
                           end) (map Z.of_nat (seq 0 8))
  | _ => true
  end.

Definition mact_b (ge : genv) (pool : block) (m : mem) (k : Z) : bool :=
  match CM.load Mint16signed m pool (k * OSZ + O_FLAGS) with
  | Some (Vint f) => Int.eq (Int.and f Int.one) Int.one
  | _ => false
  end
  && match Genv.find_symbol ge behavior_data._bhvMario, ld32 m pool (k * OSZ + O_CMD) with
     | Some b, Some (Vptr b' _) => Pos.eqb b' b && mstk_b m pool b k
     | _, _ => false
     end.

Lemma slot_v_inj : forall pool k k', 0 <= k < NSLOT -> 0 <= k' < NSLOT ->
  slot_v pool k = slot_v pool k' -> k = k'.
Proof.
  intros pool k k' Hk Hk' E0. unfold slot_v in E0.
  assert (E : Ptrofs.repr (k * OSZ) = Ptrofs.repr (k' * OSZ)) by congruence.
  apply (f_equal Ptrofs.unsigned) in E.
  rewrite !Ptrofs.unsigned_repr in E
    by (unfold OSZ, NSLOT in *; change Ptrofs.max_unsigned with 4294967295; lia).
  unfold OSZ in E. lia.
Qed.

Lemma in_seq8 : forall n, 0 <= n < 8 -> In n (map Z.of_nat (seq 0 8)).
Proof.
  intros n Hn. apply in_map_iff. exists (Z.to_nat n). split; [ lia | ].
  apply in_seq. lia.
Qed.

Lemma mact_b_sound : forall ge pool gmo m k, 0 <= k < NSLOT ->
  Mem.load Mint32 m gmo 0 = Some (slot_v pool k) -> mact_b ge pool m k = true -> mact_ok ge pool gmo m.
Proof.
  intros ge pool gmo m k Hk Lg H k' Hk' Lg'.
  rewrite Lg in Lg'. assert (Ek : slot_v pool k = slot_v pool k') by congruence.
  apply (slot_v_inj pool k k' Hk Hk') in Ek. subst k'.
  unfold mact_b in H. rewrite !CM.load_eq in H. apply andb_prop in H as [H1 H2]. split.
  - destruct (Mem.load Mint16signed m pool (k * OSZ + O_FLAGS)) as [[| f | | | |]|]; try discriminate H1.
    exists f. split; [ reflexivity | apply Int.same_if_eq; exact H1 ].
  - destruct (Genv.find_symbol ge behavior_data._bhvMario) as [b|] eqn:Hs; [ | discriminate H2 ].
    unfold ld32 in H2. rewrite CM.load_eq in H2.
    destruct (Mem.load Mint32 m pool (k * OSZ + O_CMD)) as [[| | | | | b' o]|] eqn:Lc; try discriminate H2.
    apply andb_prop in H2 as [E Hst]. apply Pos.eqb_eq in E. subst b'.
    exists b. split; [ reflexivity | split; [ exists o; reflexivity | ] ].
    intros d n Ld Hn. unfold mstk_b, ld32 in Hst. rewrite CM.load_eq, Ld in Hst.
    assert (Hn8 : 0 <= n < 8) by lia.
    pose proof (proj1 (forallb_forall _ _) Hst n (in_seq8 n Hn8)) as Hc. cbv beta in Hc.
    assert (Lt : (n <? Z.min (Int.unsigned d) 8) = true) by (apply Z.ltb_lt; lia).
    rewrite Lt in Hc. cbn [negb orb] in Hc. rewrite CM.load_eq in Hc.
    destruct (Mem.load Mint32 m pool (k * OSZ + O_STK + 4 * n)) as [[| c | | | | b' o']|]; try discriminate Hc.
    + right. exists c. reflexivity.
    + left. apply Pos.eqb_eq in Hc. subst b'. exists o'. reflexivity.
Qed.

Definition resp_b (ge : genv) (pool : block) (m : mem) (k : Z) : bool :=
  match CM.load Mint16signed m pool (k * OSZ + O_RTYPE) with
  | Some (Vint t) =>
      (negb (Z.eqb (Int.unsigned t) 1)
       || match ld32 m pool (k * OSZ + O_RINFO) with
          | Some (Vptr b o) =>
              (sym_is ge area._gPlayerSpawnInfos b && Z.eqb (Ptrofs.unsigned o) 16)
              || (gcell_b ge surface_load._sSurfacePool Mint32 (Vptr b (Ptrofs.repr SP_OFF)) m
                  && existsb (Z.eqb (Ptrofs.unsigned o)) SI_OFFS)
          | _ => false
          end)
      && (negb (Z.eqb (Int.unsigned t) 2)
          || match ld32 m pool (k * OSZ + O_RINFO) with
             | Some (Vptr b o) =>
                 sym_is ge wmotr_level_data._wmotr_seg7_macro_objs b
                 && existsb (Z.eqb (Ptrofs.unsigned o)) MAC_OFFS
             | _ => false
             end)
  | _ => false
  end.

Lemma sym_is_sound : forall ge id b, sym_is ge id b = true -> Genv.find_symbol ge id = Some b.
Proof.
  intros ge id b H. unfold sym_is in H. destruct (Genv.find_symbol ge id) as [b'|]; [ | discriminate H ].
  apply Pos.eqb_eq in H. subst b'. reflexivity.
Qed.

Lemma existsb_eqb_in : forall z l, existsb (Z.eqb z) l = true -> In z l.
Proof.
  intros z l H. apply existsb_exists in H as (x & Hx & E). apply Z.eqb_eq in E. subst x. exact Hx.
Qed.

Lemma resp_b_sound : forall ge pool m k, resp_b ge pool m k = true -> resp_ok ge pool m k.
Proof.
  intros ge pool m k H. unfold resp_ok. unfold resp_b, ld32 in H. rewrite !CM.load_eq in H.
  destruct (Mem.load Mint16signed m pool (k * OSZ + O_RTYPE)) as [[| t | | | |]|]; try discriminate H.
  apply andb_prop in H as [H1 H2]. exists t. split; [ reflexivity | split ].
  - intros Et. rewrite Et in H1. cbn [Z.eqb negb orb Pos.eqb] in H1.
    destruct (Mem.load Mint32 m pool (k * OSZ + O_RINFO)) as [[| | | | | b o]|]; try discriminate H1.
    exists b, o. split; [ reflexivity | ].
    apply orb_true_iff in H1 as [H1 | H1]; apply andb_prop in H1 as [A B]; [ left | right ].
    + split; [ exact (sym_is_sound _ _ _ A) | apply Z.eqb_eq; exact B ].
    + split; [ exact (gcell_b_sound _ _ _ _ _ A) | exact (existsb_eqb_in _ _ B) ].
  - intros Et. rewrite Et in H2. cbn [Z.eqb negb orb Pos.eqb] in H2.
    destruct (Mem.load Mint32 m pool (k * OSZ + O_RINFO)) as [[| | | | | b o]|]; try discriminate H2.
    exists b, o. split; [ reflexivity | ].
    apply andb_prop in H2 as [A B]. exact (conj (sym_is_sound _ _ _ A) (existsb_eqb_in _ _ B)).
Qed.

Definition slot_node_b (pool : block) (ov : option val) : bool :=
  match ov with
  | Some (Vptr b o) => Pos.eqb b pool && match slot_of (Ptrofs.unsigned o) with Some _ => true | None => false end
  | _ => false
  end.

Lemma slot_node_b_sound : forall pool ov, slot_node_b pool ov = true -> slot_node pool ov.
Proof.
  intros pool ov H. destruct ov as [[| | | | | b o]|]; try discriminate H.
  cbn [slot_node_b] in H. apply andb_prop in H as [Hb Hs]. apply Pos.eqb_eq in Hb. subst b.
  destruct (slot_of (Ptrofs.unsigned o)) as [j|] eqn:Hj; [ | discriminate Hs ].
  destruct (slot_of_spec _ _ Hj) as (Hr & Ho). exists j. split; [ exact Hr | ].
  unfold slot_v. rewrite <- Ho, Ptrofs.repr_unsigned. reflexivity.
Qed.

Definition gfx_b (ge : genv) (pool : block) (m : mem) : bool :=
  match Genv.find_symbol ge area._gObjParentGraphNode with
  | Some bpg =>
      forallb (fun k => match ld32 m pool (k * OSZ + G_PAR) with
                        | Some v => veqb v (Vptr bpg Ptrofs.zero) | None => false end
                        && slot_node_b pool (ld32 m pool (k * OSZ + G_PREV))
                        && slot_node_b pool (ld32 m pool (k * OSZ + G_NEXT)))
              (map Z.of_nat (seq 0 240))
      && match ld32 m bpg G_CHILD with
         | Some (Vint i) => Int.eq i Int.zero
         | ov => slot_node_b pool ov
         end
  | None => false
  end.

Lemma gfx_b_sound : forall ge pool m, gfx_b ge pool m = true -> gfx_ok ge pool m.
Proof.
  intros ge pool m H bpg Hs. unfold gfx_b in H. rewrite Hs in H. apply andb_prop in H as [H1 H2]. split.
  - intros k Hk.
    assert (Hin : In k (map Z.of_nat (seq 0 240))).
    { apply in_map_iff. exists (Z.to_nat k). split; [ lia | apply in_seq; unfold NSLOT in Hk; lia ]. }
    pose proof (proj1 (forallb_forall _ _) H1 k Hin) as Hc. cbv beta in Hc.
    apply andb_prop in Hc as [Hc Hn]. apply andb_prop in Hc as [Hp Hv].
    unfold ld32 in *. rewrite !CM.load_eq in *.
    split; [ | split; [ exact (slot_node_b_sound _ _ Hv) | exact (slot_node_b_sound _ _ Hn) ] ].
    destruct (Mem.load Mint32 m pool (k * OSZ + G_PAR)) as [v|]; [ | discriminate Hp ].
    apply veqb_eq in Hp. subst v. reflexivity.
  - unfold ld32 in H2. rewrite CM.load_eq in H2.
    destruct (Mem.load Mint32 m bpg G_CHILD) as [[| i | | | | b o]|] eqn:L.
    + right. exact (slot_node_b_sound _ _ H2).
    + left. apply Int.same_if_eq in H2. subst i. reflexivity.
    + right. exact (slot_node_b_sound _ _ H2).
    + right. exact (slot_node_b_sound _ _ H2).
    + right. exact (slot_node_b_sound _ _ H2).
    + right. exact (slot_node_b_sound _ _ H2).
    + right. exact (slot_node_b_sound _ _ H2).
Qed.

Definition msurf_b (ge : genv) (bm : block) (m : mem) : bool :=
  forallb (fun z => match ld32 m bm z with
                    | Some (Vint i) => Int.eq i Int.zero
                    | Some (Vptr b o) =>
                        match Genv.find_symbol ge surface_load._sSurfacePool with
                        | Some s => match ld32 m s 0 with
                                    | Some (Vptr P _) => negb (Pos.eqb b P) || in_sp (Ptrofs.unsigned o)
                                    | _ => true
                                    end
                        | None => true
                        end
                    | _ => false
                    end) MSURF.

Lemma msurf_b_sound : forall ge bm m, msurf_b ge bm m = true -> msurf_ok ge bm m.
Proof.
  intros ge bm m H z v Hz L. pose proof (proj1 (forallb_forall _ _) H z Hz) as Hc. cbv beta in Hc.
  unfold ld32 in Hc. rewrite CM.load_eq, L in Hc.
  destruct v as [| i | | | | P o]; try discriminate Hc.
  - left. apply Int.same_if_eq in Hc. subst i. reflexivity.
  - right. exists P, o. split; [ reflexivity | ]. intros Q (s & Hs & Ls).
    rewrite Hs in Hc. unfold ld32 in Hc. rewrite CM.load_eq, Ls in Hc.
    apply orb_true_iff in Hc as [Hc | Hc]; [ left | right; exact Hc ].
    intros E. subst Q. rewrite Pos.eqb_refl in Hc. discriminate Hc.
Qed.

Definition par_b (ge : genv) (pool : block) (m : mem) (rs : list (list Z)) : bool :=
  forallb (fun k => match ld32 m pool (k * OSZ + O_PARENT) with
                    | Some (Vint i) => Int.eq i Int.zero
                    | ov => slot_node_b pool ov
                    end) (map Z.of_nat (seq 0 240))
  && forallb (fun k => forallb (fun id => negb (runs ge pool m k id)
                                          || slot_node_b pool (ld32 m pool (k * OSZ + O_PARENT))) pbc_ids)
       (concat rs).

Lemma par_b_sound : forall ge pool m rs, par_b ge pool m rs = true -> par_ok ge pool m rs.
Proof.
  intros ge pool m rs H. unfold par_b in H. apply andb_prop in H as [H1 H2]. split.
  - intros k Hk.
    assert (Hin : In k (map Z.of_nat (seq 0 240))).
    { apply in_map_iff. exists (Z.to_nat k). split; [ lia | apply in_seq; unfold NSLOT in Hk; lia ]. }
    pose proof (proj1 (forallb_forall _ _) H1 k Hin) as Hc. cbv beta in Hc.
    unfold ld32 in Hc. rewrite CM.load_eq in Hc.
    destruct (Mem.load Mint32 m pool (k * OSZ + O_PARENT)) as [[| i | | | | b o]|] eqn:L;
      try (right; exact (slot_node_b_sound _ _ Hc)).
    left. cbv iota beta in Hc. apply Int.same_if_eq in Hc. subst i. reflexivity.
  - intros k id Hk Hid Hr. pose proof (proj1 (forallb_forall _ _) H2 k Hk) as Hc. cbv beta in Hc.
    pose proof (proj1 (forallb_forall _ _) Hc id Hid) as Hd. cbv beta in Hd.
    rewrite Hr in Hd. cbn [negb orb] in Hd. unfold ld32 in Hd. rewrite CM.load_eq in Hd.
    exact (slot_node_b_sound _ _ Hd).
Qed.

(* 3h's checkers: vm_tab and sp_scripts come in as arguments (vt, sp), so
   each is computed once per check and no proof unfolds them *)
Section Chk3h.
  Variable ge : genv.
  Variables pool : block.
  Variable m : mem.

  Lemma st_b_sound : forall k st, st_b ge pool m k st = true -> vm_at ge pool m k st.
  Proof.
    intros k st H. destruct (vm_b_sound_gen ge pool m k [st] ltac:(cbn [existsb]; rewrite H; reflexivity))
      as (st' & Hin & R). destruct Hin as [<- | []]. exact R.
  Qed.

  (* MVM at Mario's slot k *)
  Definition mvm_b (vt : list BhvVM.vst) (k : Z) : bool :=
    existsb (fun st => Pos.eqb (BhvVM.v_s st) behavior_data._bhvMario && st_b ge pool m k st) vt.

  Lemma mvm_b_sound : forall gmo k, 0 <= k < NSLOT ->
    Mem.load Mint32 m gmo 0 = Some (slot_v pool k) ->
    mvm_b BhvVM.vm_tab k = true -> mvm_ok ge pool gmo m.
  Proof.
    intros gmo k Hk Lg H k' Hk' Lg'.
    rewrite Lg in Lg'. assert (Ek : slot_v pool k = slot_v pool k') by congruence.
    apply (slot_v_inj pool k k' Hk Hk') in Ek. subst k'.
    unfold mvm_b in H. apply (proj1 (existsb_exists _ _)) in H as (st & Hin & H). apply andb_prop in H as [E H].
    apply Pos.eqb_eq in E. exists st. exact (conj Hin (conj E (st_b_sound k st H))).
  Qed.

  (* ANIM *)
  Definition init_ld_b (b : block) (z : Z) (d : init_data) : bool :=
    match d with
    | Init_int16 n =>
        match CM.load Mint16signed m b z with Some (Vint n') => Int.eq (Int.sign_ext 16 n) n' | _ => false end
    | Init_int32 n =>
        match CM.load Mint32 m b z with Some (Vint n') => Int.eq n n' | _ => false end
    | Init_addrof t o =>
        match Genv.find_symbol ge t, CM.load Mint32 m b z with
        | Some bt, Some (Vptr b' o') => Pos.eqb bt b' && Ptrofs.eq o o'
        | _, _ => false
        end
    | _ => true
    end.

  Lemma init_ld_b_sound : forall b z d, init_ld_b b z d = true -> init_ld ge m b z d.
  Proof.
    intros b z d H. unfold init_ld_b in H.
    destruct d as [n | n | n | n | f | f | sz | t o]; cbn [init_ld]; try exact I;
      rewrite ?CM.load_eq in H.
    - destruct (Mem.load Mint16signed m b z) as [[| i | | | | ]|]; try discriminate H.
      apply Int.same_if_eq in H. rewrite H. reflexivity.
    - destruct (Mem.load Mint32 m b z) as [[| i | | | | ]|]; try discriminate H.
      apply Int.same_if_eq in H. rewrite H. reflexivity.
    - destruct (Genv.find_symbol ge t) as [bt|] eqn:Eb; [ | discriminate H ].
      destruct (Mem.load Mint32 m b z) as [[| | | | | b' o']|]; try discriminate H.
      apply andb_prop in H as [H1 H2]. apply Pos.eqb_eq in H1. apply Ptrofs.same_if_eq in H2.
      subst b' o'. exists bt. split; reflexivity.
  Qed.

  Definition anim_b : bool :=
    forallb (fun t => match Genv.find_symbol ge t with
                      | Some b => forallb (fun zd => init_ld_b b (fst zd) (snd zd)) (icells 0 (ldata_words t))
                      | None => true end) anim_ids.

  Lemma anim_b_sound : anim_b = true -> anim_ok ge m.
  Proof.
    intros H t bt z d Ht Hs Hi. unfold anim_b in H.
    pose proof (proj1 (forallb_forall _ _) H t Ht) as H1. cbv beta in H1. rewrite Hs in H1.
    exact (init_ld_b_sound _ _ _ (proj1 (forallb_forall _ _) H1 (z, d) Hi)).
  Qed.

  Definition dp_b : bool :=
    forallb (fun p => match Genv.find_symbol ge p with
                      | Some bp => match Genv.find_symbol ge behavior_data._bhvWaterDroplet with
                                   | Some bwd => veqb (match CM.load Mint32 m bp 4 with Some v => v | None => Vundef end)
                                                      (Vptr bwd Ptrofs.zero)
                                   | None => false end
                      | None => true end) dparams.

  Lemma dp_b_sound : dp_b = true -> dp_ok ge m.
  Proof.
    intros H p bp Hp Hs. unfold dp_b in H.
    pose proof (proj1 (forallb_forall _ _) H p Hp) as H1. cbv beta in H1. rewrite Hs in H1.
    destruct (Genv.find_symbol ge behavior_data._bhvWaterDroplet) as [bwd|]; [ | discriminate H1 ].
    exists bwd. split; [ reflexivity | ].
    apply veqb_eq in H1. rewrite CM.load_eq in H1.
    destruct (Mem.load Mint32 m bp 4); [ congruence | discriminate H1 ].
  Qed.

  Definition ncoll_b (rs : list (list Z)) : bool :=
    forallb (fun k => match CM.load Mint16signed m pool (k * OSZ + O_NCOLL) with
                      | Some (Vint n) => (0 <=? Int.signed n) && (Int.signed n <=? 4)
                      | _ => false end) (concat rs).

  Lemma ncoll_b_sound : forall rs, ncoll_b rs = true -> ncoll_ok pool m rs.
  Proof.
    intros rs H k Hk. pose proof (proj1 (forallb_forall _ _) H k Hk) as H1. cbv beta in H1.
    rewrite CM.load_eq in H1.
    destruct (Mem.load Mint16signed m pool (k * OSZ + O_NCOLL)) as [[| n | | | |]|]; try discriminate H1.
    apply andb_prop in H1 as [A B]. apply Z.leb_le in A. apply Z.leb_le in B.
    exists n. split; [ reflexivity | lia ].
  Qed.

  Definition mcoll_b (k : Z) : bool :=
    forallb (fun i => match CM.load Mint32 m pool (k * OSZ + O_COLLS + 4 * i) with
                      | Some v => slot_ptr_b pool v | None => false end) [0; 1; 2; 3].

  Lemma mcoll_b_sound : forall gmo k, 0 <= k < NSLOT -> Mem.load Mint32 m gmo 0 = Some (slot_v pool k) ->
    mcoll_b k = true -> mcoll_ok pool gmo m.
  Proof.
    intros gmo k Hk Lg H k' Hk' Lg' i Hi.
    rewrite Lg in Lg'. assert (Ek : slot_v pool k = slot_v pool k') by congruence.
    apply (slot_v_inj pool k k' Hk Hk') in Ek. subst k'.
    assert (Hin : In i [0; 1; 2; 3]) by (cbn; lia).
    pose proof (proj1 (forallb_forall _ _) H i Hin) as H1. cbv beta in H1. rewrite CM.load_eq in H1.
    destruct (Mem.load Mint32 m pool (k * OSZ + O_COLLS + 4 * i)) as [v|]; [ | discriminate H1 ].
    exists v. split; [ reflexivity | exact (slot_ptr_b_sound pool v H1) ].
  Qed.

  (* CLS *)
  Definition sp_b (vt : list BhvVM.vst) (sp : list ident) (k : Z) : bool :=
    existsb (fun st => existsb (Pos.eqb (BhvVM.v_s st)) sp && st_b ge pool m k st) vt.

  Lemma sp_b_sound : forall k, sp_b BhvVM.vm_tab sp_scripts k = true -> sp_vm ge pool m k.
  Proof.
    intros k H. unfold sp_b in H.
    apply (proj1 (existsb_exists _ _)) in H as (st & Hin & H). apply andb_prop in H as [E H].
    apply (proj1 (existsb_exists _ _)) in E as (s & Hs & E). apply Pos.eqb_eq in E.
    exists st. split; [ exact Hin | split; [ rewrite E; exact Hs | exact (st_b_sound k st H) ] ].
  Qed.

  Definition cls_type_b (vt : list BhvVM.vst) (sp : list ident) (rs : list (list Z)) : bool :=
    forallb (fun k => match ld32 m pool (k * OSZ + O_INTERACT_TYPE) with
                      | Some (Vint t) => negb (Z.eqb (Int.unsigned t) INTERACT_POLE
                                               || Z.eqb (Int.unsigned t) INTERACT_CANNON_BASE)
                                         || sp_b vt sp k
                      | _ => true end) (concat rs).

  Definition owner_b (vt : list BhvVM.vst) (sp : list ident) (P : block) (s : val) : bool :=
    match s with
    | Vptr b o =>
        if eq_block b P then
          match CM.load Mint32 m P (Ptrofs.unsigned o + S_OBJ) with
          | Some (Vptr pb po) =>
              if eq_block pb pool then
                match slot_of (Ptrofs.unsigned po) with Some k => sp_b vt sp k | None => true end
              else true
          | _ => true
          end
        else true
    | _ => true
    end.

  Definition cls_surf_b (vt : list BhvVM.vst) (sp : list ident) : bool :=
    match Genv.find_symbol ge surface_load._sSurfaceNodePool with
    | Some nb =>
        match CM.load Mint32 m nb 0 with
        | Some (Vptr P _) =>
            forallb (fun id =>
              match Genv.find_symbol ge id with
              | Some bp =>
                  forallb (fun j => match CM.load Mint32 m bp (4 * Z.of_nat j) with
                                    | Some hd => match swalk P m SFUEL hd with
                                                 | Some l => forallb (owner_b vt sp P) l
                                                 | None => true end
                                    | None => true end) (seq 0 PCELLS)
              | None => true
              end) FloorList.part_ids
        | _ => true
        end
    | None => true
    end.

  Definition cls_b (vt : list BhvVM.vst) (sp : list ident) (rs : list (list Z)) : bool :=
    cls_type_b vt sp rs && cls_surf_b vt sp.

  Lemma cls_b_sound : forall rs, part_cells ge m ->
    cls_b BhvVM.vm_tab sp_scripts rs = true -> cls_ok ge pool m rs.
  Proof.
    intros rs PC H. unfold cls_b in H. apply andb_prop in H as [Ht Hs]. split.
    - intros k t Hk L Ht'. unfold cls_type_b in Ht.
      pose proof (proj1 (forallb_forall _ _) Ht k Hk) as E. cbv beta in E.
      unfold ld32 in E. rewrite CM.load_eq, L in E.
      apply orb_true_iff in E as [E | E]; [ | exact (sp_b_sound k E) ].
      exfalso. apply negb_true_iff in E. apply orb_false_iff in E as [E1 E2].
      apply Z.eqb_neq in E1. apply Z.eqb_neq in E2. destruct Ht'; contradiction.
    - intros P id bp z hd l o k _ _ (nb & Hnb & Lnb) Hin Hsy L Hw Ho _ Hk Lo.
      unfold cls_surf_b in Hs. rewrite Hnb, CM.load_eq, Lnb in Hs.
      pose proof (PC id bp z hd Hin Hsy L) as Bz.
      destruct (Mem.load_valid_access _ _ _ _ _ L) as (_ & (q & Eq)). cbn [align_chunk] in Eq.
      change (Z.of_nat PCELLS) with 1536 in Bz.
      assert (Hq : 0 <= q < 1536) by lia.
      set (j := Z.to_nat q).
      assert (Ez : z = 4 * Z.of_nat j) by (unfold j; rewrite Z2Nat.id by lia; lia).
      assert (Hj : (j < PCELLS)%nat)
        by (apply Nat2Z.inj_lt; unfold j; rewrite Z2Nat.id by lia; change (Z.of_nat PCELLS) with 1536; lia).
      rewrite Ez in L. clearbody j. clear Eq Bz Ez Hq.
      pose proof (proj1 (forallb_forall _ _) Hs id Hin) as H4. cbv beta in H4. rewrite Hsy in H4.
      pose proof (proj1 (forallb_forall _ _) H4 j (proj2 (in_seq PCELLS 0 j) (conj (Nat.le_0_l j) Hj))) as H5.
      cbv beta in H5. rewrite CM.load_eq, L, Hw in H5.
      pose proof (proj1 (forallb_forall _ _) H5 _ Ho) as H6. unfold owner_b in H6.
      destruct (eq_block P P) as [_ | N]; [ | contradiction N; reflexivity ].
      rewrite CM.load_eq, Lo in H6. unfold slot_v in H6.
      destruct (eq_block pool pool) as [_ | N]; [ | contradiction N; reflexivity ].
      rewrite Ptrofs.unsigned_repr in H6
        by (unfold OSZ, NSLOT in *; change Ptrofs.max_unsigned with 4294967295; lia).
      assert (Sk : slot_of (k * OSZ) = Some k).
      { unfold slot_of. unfold OSZ, NSLOT in *.
        replace ((0 <=? k * 608) && (k * 608 <? 240 * 608) && ((k * 608) mod 608 =? 0)) with true
          by (symmetry; rewrite Z_mod_mult; apply andb_true_iff; split; [ apply andb_true_iff; split | ];
              [ apply Z.leb_le; lia | apply Z.ltb_lt; lia | apply Z.eqb_refl ]).
        rewrite Z_div_mult by lia. reflexivity. }
      rewrite Sk in H6. exact (sp_b_sound k H6).
  Qed.
End Chk3h.

(* TIE's checker (2026-11-07) *)
Section ChkTie.
  Variable ge : genv.
  Variables pool bm : block.
  Variable m : mem.

  Lemma is_bhv_b_true : forall k id, is_bhv ge pool m k id -> is_bhv_b ge pool m id k = true.
  Proof.
    intros k id (b & Hs & L). unfold is_bhv_b, ld32. rewrite Hs, CM.load_eq, L. unfold veqb.
    destruct (Val.eq _ _) as [_ | N]; [ reflexivity | contradiction N; reflexivity ].
  Qed.

  Definition tie_b (vt : list BhvVM.vst) (sp : list ident) (rs : list (list Z)) : bool :=
    forallb (fun k => forallb (fun bh => negb (is_bhv_b ge pool m bh k) || sp_b ge pool m vt sp k) tie_bhvs)
      (concat rs)
    && match ld32 m bm 12 with
       | Some (Vint a) =>
           negb (existsb (Z.eqb (Int.unsigned a)) used_acts)
           || match ld32 m bm USED_OFF with
              | Some (Vptr b o) =>
                  (if eq_block b pool then true else false)
                  && match slot_of (Ptrofs.unsigned o) with Some k => sp_b ge pool m vt sp k | None => false end
              | _ => false
              end
       | _ => true
       end.

  Lemma tie_b_sound : forall rs, tie_b BhvVM.vm_tab sp_scripts rs = true -> tie_ok ge pool bm m rs.
  Proof.
    intros rs H. unfold tie_b in H. apply andb_prop in H as [H1 H2]. split.
    - intros k bh Hk Hb Hi.
      pose proof (proj1 (forallb_forall _ _) H1 k Hk) as E. cbv beta in E.
      pose proof (proj1 (forallb_forall _ _) E bh Hb) as E2. cbv beta in E2.
      rewrite (is_bhv_b_true k bh Hi) in E2. cbn [negb orb] in E2. exact (sp_b_sound ge pool m k E2).
    - intros a La Ha. unfold ld32 in H2. rewrite !CM.load_eq, La in H2.
      assert (Ea : existsb (Z.eqb (Int.unsigned a)) used_acts = true)
        by (apply existsb_exists; exists (Int.unsigned a); split; [ exact Ha | apply Z.eqb_refl ]).
      rewrite Ea in H2. cbn [negb orb] in H2.
      destruct (Mem.load Mint32 m bm USED_OFF) as [[| | | | | b o]|]; try discriminate H2.
      destruct (eq_block b pool) as [-> | _]; [ | discriminate H2 ]. cbn [andb] in H2.
      destruct (slot_of (Ptrofs.unsigned o)) as [k|] eqn:Hk; [ | discriminate H2 ].
      destruct (slot_of_spec _ _ Hk) as (Rk & Eo).
      exists k. split; [ exact Rk | split; [ | exact (sp_b_sound ge pool m k H2) ] ].
      unfold slot_v. rewrite <- Eo, Ptrofs.repr_unsigned. reflexivity.
  Qed.
End ChkTie.

Definition dflags_b (ge : genv) (m : mem) : bool :=
  match Genv.find_symbol ge debug._gDebugInfoFlags with
  | Some b => match CM.load Mint32 m b 0 with
              | Some (Vint n) => Int.eq (Int.and n Int.one) Int.zero
              | _ => false end
  | None => true
  end.

Lemma dflags_b_sound : forall ge m, dflags_b ge m = true -> dflags_ok ge m.
Proof.
  intros ge m H b Hs. unfold dflags_b in H. rewrite Hs, CM.load_eq in H.
  destruct (Mem.load Mint32 m b 0) as [[| n | | | |]|]; try discriminate H.
  exists n. split; [ reflexivity | exact (Int.same_if_eq _ _ H) ].
Qed.

Definition ow_chk_core (ge : genv) (pool la fl gol gmo sdp gdi bm : block) (m : mem) : bool :=
  match rings m pool la, free_list m pool fl, ld32 m gmo 0 with
  | Some rs, Some fs, Some (Vptr pb po) =>
      match slot_of (Ptrofs.unsigned po) with
      | Some k =>
      veqb (match ld32 m gol 0 with Some v => v | None => Vundef end) (Vptr la Ptrofs.zero)
      && nodupb (concat rs ++ fs) && Z.eqb (Z.of_nat (List.length (concat rs ++ fs))) NSLOT
      && forallb (fun k => match CM.load Mint16signed m pool (k * OSZ + O_FLAGS) with
                           | Some (Vint i) => Int.eq i Int.zero | _ => false end) fs
      && existsb (Z.eqb k) (nth 0%nat rs [])
      && veqb (match ld32 m bm MARIOOBJ_OFF with Some v => v | None => Vundef end) (slot_v pool k)
      && veqb (Vptr pb po) (slot_v pool k)
      && forallb (fun j => Z.eqb j k || kind_b pool m j) (concat rs)
      && forallb (fun k => script_b ge pool m k && act_b ge pool m k && red_b ge pool m k) (concat rs)
      && vint_is (CM.load Mint8signed m sdp 0) 0 && dflags_b ge m
      && forallb (fun z => match ld32 m bm z with Some v => slot_ptr_b pool v | None => false end)
           [120; 124; 128; 132]
      && order_b ge m
      && forallb (script12_b ge pool m) (nth 12%nat rs [])
      && cmdtab_b ge m
      && forallb (fun k => existsb (st_b ge pool m k) BhvVM.vm_tab) (concat rs)
      && spool_b ge m && surf_b ge pool m && coll_b ge pool m rs
      && ctr_s_b ge m && ter_b ge pool m rs
      && scr_b_l ge (sdedup (map BhvVM.v_s BhvVM.vm_tab)) m
      && mact_b ge pool m k && forallb (resp_b ge pool m) (concat rs) && gfx_b ge pool m
      && msurf_b ge bm m && par_b ge pool m rs
      && mvm_b ge pool m BhvVM.vm_tab k && anim_b ge m && cls_b ge pool m BhvVM.vm_tab sp_scripts rs
      && dp_b ge m && ncoll_b pool m rs && mcoll_b pool m k
      && tie_b ge pool bm m BhvVM.vm_tab sp_scripts rs
      | None => false
      end
  | _, _, _ => false
  end.


Lemma vint_is_ne : forall ov z, 0 <= z <= Int.max_unsigned -> vint_is ov z = false -> ov <> Some (Vint (Int.repr z)).
Proof.
  intros ov z Hz H E. subst ov. cbn in H. rewrite Int.unsigned_repr in H by exact Hz.
  rewrite Z.eqb_refl in H. discriminate H.
Qed.

Lemma ld_dflt : forall m b z v, veqb (match ld32 m b z with Some v => v | None => Vundef end) v = true ->
    v <> Vundef -> Mem.load Mint32 m b z = Some v.
Proof.
  intros m b z v H Hn. apply veqb_eq in H. unfold ld32 in H. rewrite CM.load_eq in H.
  destruct (Mem.load Mint32 m b z); [ congruence | subst v; contradiction ].
Qed.

Lemma ow_chk_core_sound : forall ge pool la fl gol gmo sdp gdi bm m,
    part_cells ge m ->
    ow_chk_core ge pool la fl gol gmo sdp gdi bm m = true ->
    exists rs fs, ow_core ge pool la fl gol gmo sdp gdi bm m rs fs.
Proof.
  intros ge pool la fl gol gmo sdp gdi bm m PC H. unfold ow_chk_core in H.
  destruct (rings m pool la) as [rs|] eqn:Hr; [ | discriminate H ].
  destruct (free_list m pool fl) as [fs|] eqn:Hf; [ | discriminate H ].
  destruct (ld32 m gmo 0) as [[| | | | | pb po]|] eqn:Hg;
    [ discriminate H .. | | discriminate H ].
  destruct (slot_of (Ptrofs.unsigned po)) as [k|] eqn:Hk; [ | discriminate H ].
  apply andb_prop in H as [H Htie].
  apply andb_prop in H as [H Hmco]. apply andb_prop in H as [H Hnco].
  apply andb_prop in H as [H Hdp].
  apply andb_prop in H as [H Hcls]. apply andb_prop in H as [H Hanim]. apply andb_prop in H as [H Hmvm].
  apply andb_prop in H as [H Hpar]. apply andb_prop in H as [H Hms].
  apply andb_prop in H as [H Hgfx]. apply andb_prop in H as [H Hresp]. apply andb_prop in H as [H Hmact].
  apply andb_prop in H as [H Hscr].
  apply andb_prop in H as [H Hter]. apply andb_prop in H as [H Hctr].
  apply andb_prop in H as [H Hcoll]. apply andb_prop in H as [H Hsurf]. apply andb_prop in H as [H Hspool].
  apply andb_prop in H as [H Hvm].
  apply andb_prop in H as [H Hcmd].
  apply andb_prop in H as [H Hd12].
  apply andb_prop in H as [H Hord].
  apply andb_prop in H as [H Hst]. apply andb_prop in H as [H Hdf]. apply andb_prop in H as [H Hdb].
  apply andb_prop in H as [H Hsar]. apply andb_prop in H as [H Hkd].
  apply andb_prop in H as [H Hpo]. apply andb_prop in H as [H Hbm].
  apply andb_prop in H as [H Hin]. apply andb_prop in H as [H Hff].
  apply andb_prop in H as [H Hlen]. apply andb_prop in H as [Hgol Hnd].
  exists rs, fs. constructor.
  - exact (ld_dflt _ _ _ _ Hgol ltac:(discriminate)).
  - exact Hr.
  - exact Hf.
  - split; [ apply nodupb_sound; exact Hnd | apply Z.eqb_eq; exact Hlen ].
  - intros j Hj. pose proof (proj1 (forallb_forall _ _) Hff j Hj) as Hz.
    cbn beta in Hz. rewrite CM.load_eq in Hz.
    destruct (Mem.load Mint16signed m pool (j * OSZ + O_FLAGS)) as [[| i | | | |]|]; try discriminate Hz.
    apply Int.same_if_eq in Hz. subst i. reflexivity.
  - exists k. split; [ | split; [ | split ] ].
    + apply existsb_exists in Hin as (j & Hj & E). apply Z.eqb_eq in E. subst j. exact Hj.
    + apply veqb_eq in Hpo. rewrite <- Hpo. unfold ld32 in Hg. rewrite CM.load_eq in Hg. exact Hg.
    + exact (ld_dflt _ _ _ _ Hbm ltac:(unfold slot_v; discriminate)).
    + intros j Hj Hne. pose proof (proj1 (forallb_forall _ _) Hkd j Hj) as Hz.
      apply orb_true_iff in Hz as [E | Hz]; [ apply Z.eqb_eq in E; contradiction | exact (kind_b_sound _ _ _ Hz) ].
  - intros j Hj. pose proof (proj1 (forallb_forall _ _) Hsar j Hj) as Hz.
    apply andb_prop in Hz as [Hz _]. apply andb_prop in Hz as [Hz _]. exact (script_b_sound _ _ _ _ Hz).
  - intros j Hj. pose proof (proj1 (forallb_forall _ _) Hsar j Hj) as Hz.
    apply andb_prop in Hz as [Hz _]. apply andb_prop in Hz as [_ Hz]. exact (act_b_sound _ _ _ _ Hz).
  - intros j Hj. pose proof (proj1 (forallb_forall _ _) Hsar j Hj) as Hz.
    apply andb_prop in Hz as [_ Hz]. exact (red_b_sound _ _ _ _ Hz).
  - split; [ | exact (dflags_b_sound _ _ Hdf) ].
    rewrite CM.load_eq in Hdb. destruct (Mem.load Mint8signed m sdp 0) as [[| i | | | |]|]; try discriminate Hdb.
    cbn in Hdb. apply Z.eqb_eq in Hdb. rewrite <- (Int.repr_unsigned i), Hdb. reflexivity.
  - intros z Hz. pose proof (proj1 (forallb_forall _ _) Hst z Hz) as Hy.
    cbn beta in Hy. unfold ld32 in Hy. rewrite CM.load_eq in Hy.
    destruct (Mem.load Mint32 m bm z) as [v|]; [ | discriminate Hy ].
    exists v. split; [ reflexivity | exact (slot_ptr_b_sound _ _ Hy) ].
  - exact (order_b_sound _ _ Hord).
  - intros j Hj. exact (script12_b_sound _ _ _ _ (proj1 (forallb_forall _ _) Hd12 j Hj)).
  - exact (cmdtab_b_sound _ _ Hcmd).
  - (* no conversion may unfold BhvVM.vm_tab: the checker names it directly *)
    intros j Hj. pose proof (proj1 (forallb_forall _ _) Hvm j Hj) as Hj'. cbv beta in Hj'.
    unfold vm_ok. exact (vm_b_sound_gen _ _ _ j BhvVM.vm_tab Hj').
  - exact (spool_b_sound _ _ Hspool).
  - exact (surf_b_sound _ _ _ PC Hsurf).
  - exact (coll_b_sound _ _ _ _ Hcoll).
  - exact (ctr_s_b_sound _ _ Hctr).
  - exact (ter_b_sound _ _ _ _ Hter).
  - exact (scr_b_sound _ _ Hscr).
  - apply (mact_b_sound _ _ _ _ k (proj1 (slot_of_spec _ _ Hk))); [ | exact Hmact ].
    apply veqb_eq in Hpo. rewrite <- Hpo. unfold ld32 in Hg. rewrite CM.load_eq in Hg. exact Hg.
  - intros j Hj. exact (resp_b_sound _ _ _ _ (proj1 (forallb_forall _ _) Hresp j Hj)).
  - exact (gfx_b_sound _ _ _ Hgfx).
  - exact (msurf_b_sound _ _ _ Hms).
  - exact (par_b_sound _ _ _ _ Hpar).
  - apply (mvm_b_sound _ _ _ _ k (proj1 (slot_of_spec _ _ Hk))); [ | exact Hmvm ].
    apply veqb_eq in Hpo. rewrite <- Hpo. unfold ld32 in Hg. rewrite CM.load_eq in Hg. exact Hg.
  - exact (anim_b_sound _ _ Hanim).
  - exact (cls_b_sound _ _ _ _ PC Hcls).
  - exact (dp_b_sound _ _ Hdp).
  - exact (ncoll_b_sound _ _ _ Hnco).
  - apply (mcoll_b_sound _ _ _ k (proj1 (slot_of_spec _ _ Hk))); [ | exact Hmco ].
    apply veqb_eq in Hpo. rewrite <- Hpo. unfold ld32 in Hg. rewrite CM.load_eq in Hg. exact Hg.
  - exact (tie_b_sound _ _ _ _ _ Htie).
Qed.

Definition ow_chk (ge : genv) (bm : block) (m : mem) : bool :=
  match Genv.find_symbol ge object_list_processor._gObjectPool,
        Genv.find_symbol ge object_list_processor._gObjectListArray,
        Genv.find_symbol ge object_list_processor._gFreeObjectList,
        Genv.find_symbol ge object_list_processor._gObjectLists,
        Genv.find_symbol ge object_list_processor._gMarioObject,
        Genv.find_symbol ge debug._sDebugPage, Genv.find_symbol ge debug._gDebugInfo with
  | Some pool, Some la, Some fl, Some gol, Some gmo, Some sdp, Some gdi =>
      ow_chk_core ge pool la fl gol gmo sdp gdi bm m
  | _, _, _, _, _, _, _ => false
  end.

Theorem ow_chk_sound : forall ge bm m, part_cells ge m -> ow_chk ge bm m = true -> obj_w ge bm m.
Proof.
  intros ge bm m PC H. unfold ow_chk in H.
  destruct (Genv.find_symbol ge object_list_processor._gObjectPool) as [pool|] eqn:H1; [ | discriminate H ].
  destruct (Genv.find_symbol ge object_list_processor._gObjectListArray) as [la|] eqn:H2; [ | discriminate H ].
  destruct (Genv.find_symbol ge object_list_processor._gFreeObjectList) as [fl|] eqn:H3; [ | discriminate H ].
  destruct (Genv.find_symbol ge object_list_processor._gObjectLists) as [gol|] eqn:H4; [ | discriminate H ].
  destruct (Genv.find_symbol ge object_list_processor._gMarioObject) as [gmo|] eqn:H5; [ | discriminate H ].
  destruct (Genv.find_symbol ge debug._sDebugPage) as [sdp|] eqn:H6; [ | discriminate H ].
  destruct (Genv.find_symbol ge debug._gDebugInfo) as [gdi|] eqn:H7; [ | discriminate H ].
  destruct (ow_chk_core_sound _ _ _ _ _ _ _ _ _ _ PC H) as (rs & fs & C).
  exists pool, la, fl, gol, gmo, sdp, gdi, rs, fs.
  exact (conj H1 (conj H2 (conj H3 (conj H4 (conj H5 (conj H6 (conj H7 C))))))).
Qed.
