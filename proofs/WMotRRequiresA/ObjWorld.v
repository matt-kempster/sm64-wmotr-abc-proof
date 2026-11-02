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
(*   DEBUG   the debug spawner's guard is false (sDebugPage is not        *)
(*           STAGEINFO or gDebugInfo[ENEMYINFO][7] is not 1).            *)
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
  surface_load macro_special_objects wmotr_level_data.
From SM64.Proofs Require Interp.CMem.
From SM64.Proofs Require Import CensusV2.
From SM64.Proofs.WMotRRequiresA Require Import WMotRLevel WMotRWorld.
From SM64.Proofs.WMotRRequiresA Require BehaviorScripts ObjAct ObjCensus BhvVM FloorList.

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

Definition live_bhvs : list ident := BehaviorScripts.reached_bhvs.

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
Local Ltac ko := unfold OSZ, O_INTERACT_TYPE, O_POSX, O_POSY, O_POSZ, HITBOX_DOWN_OFF, HITBOX_H_OFF,
                   RAW_OFF; cbn [size_chunk]; lia.
Lemma kind_ok_eq : forall pool m m',
  (forall ch k off, 96 <= off -> off + size_chunk ch <= OSZ ->
     Mem.load ch m' pool (k * OSZ + off) = Mem.load ch m pool (k * OSZ + off)) ->
  forall k, kind_ok pool m k -> kind_ok pool m' k.
Proof.
  intros pool m m' Kp k (t & Lt & Hin & Hp & Hc & Hpx & Hcx).
  assert (S : forall ch off, 96 <= off -> off + size_chunk ch <= OSZ ->
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
(*     SURF_OBJ: every list from a partition cell walks through dynamic    *)
(*     blocks to NULL, and each of its surfaces has object NULL or a pool  *)
(*     slot whose angle velocity (0x23..0x25) is 0 -- what                 *)
(*     update_mario_platform's gMarioPlatform needs (PlatformKeep).        *)
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
Definition NP_OFF : Z := 2592.  (* sSurfaceNodePool's offset in the main-pool block (the boot run) *)
Definition SP_OFF : Z := 58608.  (* sSurfacePool's offset (the boot run) *)
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

(* a list from a partition head: dynamic nodes, ending in NULL *)
Fixpoint swalk (ge : genv) (m : mem) (fuel : nat) (v : val) : option (list val) :=
  match fuel with
  | O => None
  | S f =>
      match v with
      | Vptr b o =>
          if Pos.leb (Genv.genv_next ge) b then
            match CM.load Mint32 m b (Ptrofs.unsigned (Ptrofs.add o (Ptrofs.repr FloorList.SN_SURF))),
                  CM.load Mint32 m b (Ptrofs.unsigned (Ptrofs.add o (Ptrofs.repr FloorList.SN_NEXT))) with
            | Some s, Some nx => option_map (cons s) (swalk ge m f nx)
            | _, _ => None
            end
          else None
      | Vint i => if Int.eq i Int.zero then Some nil else None
      | _ => None
      end
  end.

Lemma swalk_on_list : forall ge m hd s, FloorList.on_list m hd s ->
  forall f l, swalk ge m f hd = Some l -> In s l.
Proof.
  intros ge m hd s H. induction H as [bn on s Hl | bn on nx s Hl Ho IH]; intros f l Hw;
    (destruct f as [| f]; [ discriminate Hw | ]); cbn [swalk] in Hw;
    (destruct (Pos.leb (Genv.genv_next ge) bn); [ | discriminate Hw ]);
    cbn [Mem.loadv] in Hl; rewrite !CM.load_eq in Hw.
  - rewrite Hl in Hw.
    destruct (Mem.load Mint32 m bn (Ptrofs.unsigned (Ptrofs.add on (Ptrofs.repr FloorList.SN_NEXT)))); [ | discriminate Hw ].
    destruct (swalk ge m f _); [ | discriminate Hw ]. cbn in Hw. injection Hw as <-. left. reflexivity.
  - rewrite Hl in Hw.
    destruct (Mem.load Mint32 m bn (Ptrofs.unsigned (Ptrofs.add on (Ptrofs.repr FloorList.SN_SURF)))); [ | discriminate Hw ].
    destruct (swalk ge m f nx) as [l'|] eqn:Hw'; [ | discriminate Hw ]. cbn in Hw. injection Hw as <-.
    right. exact (IH f l' Hw').
Qed.

Definition ANGV : list Z := [35; 36; 37].   (* oAngleVelPitch / Yaw / Roll *)

Definition surf_obj_at (ge : genv) (pool : block) (m : mem) (s : val) : Prop :=
  exists b o, s = Vptr b o /\ Ple (Genv.genv_next ge) b
    /\ (Mem.load Mint32 m b (Ptrofs.unsigned o + S_OBJ) = Some (Vint Int.zero)
        \/ exists k, 0 <= k < NSLOT
             /\ Mem.load Mint32 m b (Ptrofs.unsigned o + S_OBJ) = Some (slot_v pool k)
             /\ forall j, In j ANGV -> Mem.load Mint32 m pool (k * OSZ + RAW_OFF + 4 * j) = Some (Vint Int.zero)).

Definition surf_obj_ok (ge : genv) (pool : block) (m : mem) : Prop :=
  forall id bp j hd, In id FloorList.part_ids -> Genv.find_symbol ge id = Some bp -> (j < PCELLS)%nat ->
    Mem.load Mint32 m bp (4 * Z.of_nat j) = Some hd ->
    exists l, swalk ge m SFUEL hd = Some l /\ Forall (surf_obj_at ge pool m) l.

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
(* 4. obj_w.                                                                *)
(* ---------------------------------------------------------------------- *)
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
  ow_debug : Mem.load Mint8signed m sdp 0 <> Some (Vint (Int.repr 3))
             \/ Mem.load Mint16signed m gdi DBG_ENEMY7 <> Some (Vint Int.one);
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
  ow_ter : ter_ok ge pool m rs
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

Definition surf_obj_at_b (ge : genv) (pool : block) (m : mem) (s : val) : bool :=
  match s with
  | Vptr b o =>
      Pos.leb (Genv.genv_next ge) b
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

Lemma surf_obj_at_b_sound : forall ge pool m s, surf_obj_at_b ge pool m s = true -> surf_obj_at ge pool m s.
Proof.
  intros ge pool m s H. destruct s as [| | | | | b o]; try discriminate H.
  cbn [surf_obj_at_b] in H. apply andb_prop in H as [H0 H]. apply Pos.leb_le in H0.
  exists b, o. split; [ reflexivity | split; [ exact H0 | ] ]. rewrite CM.load_eq in H.
  destruct (Mem.load Mint32 m b (Ptrofs.unsigned o + S_OBJ)) as [[| i | | | | pb po]|] eqn:L; try discriminate H.
  - left. apply Int.same_if_eq in H. subst i. reflexivity.
  - right. apply andb_prop in H as [Hb Hs]. destruct (eq_block pb pool) as [-> | _]; [ | discriminate Hb ].
    destruct (slot_of (Ptrofs.unsigned po)) as [k|] eqn:Hk; [ | discriminate Hs ].
    destruct (slot_of_spec _ _ Hk) as (Hr & Ho). exists k. split; [ exact Hr | split ].
    + unfold slot_v. rewrite <- Ho, Ptrofs.repr_unsigned. reflexivity.
    + intros j Hj. pose proof (proj1 (forallb_forall _ _) Hs j Hj) as E. cbv beta in E.
      rewrite CM.load_eq in E. exact (vint_eqb_sound _ _ E).
Qed.

Definition surf_b (ge : genv) (pool : block) (m : mem) : bool :=
  forallb (fun id =>
    match Genv.find_symbol ge id with
    | Some bp =>
        forallb (fun j => match CM.load Mint32 m bp (4 * Z.of_nat j) with
                          | Some hd => match swalk ge m SFUEL hd with
                                       | Some l => forallb (surf_obj_at_b ge pool m) l
                                       | None => false end
                          | None => true end) (seq 0 PCELLS)
    | None => false
    end) FloorList.part_ids.

Lemma surf_b_sound : forall ge pool m, surf_b ge pool m = true -> surf_obj_ok ge pool m.
Proof.
  intros ge pool m H id bp j hd Hin Hs Hj L.
  pose proof (proj1 (forallb_forall _ _) H id Hin) as H1. cbv beta in H1. rewrite Hs in H1.
  pose proof (proj1 (forallb_forall _ _) H1 j (proj2 (in_seq PCELLS 0 j) (conj (Nat.le_0_l j) Hj))) as H2.
  cbv beta in H2. rewrite CM.load_eq, L in H2.
  destruct (swalk ge m SFUEL hd) as [l|]; [ | discriminate H2 ].
  exists l. split; [ reflexivity | ]. apply Forall_forall. intros s Hs'.
  exact (surf_obj_at_b_sound _ _ _ _ (proj1 (forallb_forall _ _) H2 s Hs')).
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
      && (negb (vint_is (CM.load Mint8signed m sdp 0) 3) || negb (vint_is (CM.load Mint16signed m gdi DBG_ENEMY7) 1))
      && forallb (fun z => match ld32 m bm z with Some v => slot_ptr_b pool v | None => false end)
           [120; 124; 128; 132]
      && order_b ge m
      && forallb (script12_b ge pool m) (nth 12%nat rs [])
      && cmdtab_b ge m
      && forallb (fun k => existsb (st_b ge pool m k) BhvVM.vm_tab) (concat rs)
      && spool_b ge m && surf_b ge pool m && coll_b ge pool m rs
      && ctr_s_b ge m && ter_b ge pool m rs
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
    ow_chk_core ge pool la fl gol gmo sdp gdi bm m = true ->
    exists rs fs, ow_core ge pool la fl gol gmo sdp gdi bm m rs fs.
Proof.
  intros ge pool la fl gol gmo sdp gdi bm m H. unfold ow_chk_core in H.
  destruct (rings m pool la) as [rs|] eqn:Hr; [ | discriminate H ].
  destruct (free_list m pool fl) as [fs|] eqn:Hf; [ | discriminate H ].
  destruct (ld32 m gmo 0) as [[| | | | | pb po]|] eqn:Hg;
    [ discriminate H .. | | discriminate H ].
  destruct (slot_of (Ptrofs.unsigned po)) as [k|] eqn:Hk; [ | discriminate H ].
  apply andb_prop in H as [H Hter]. apply andb_prop in H as [H Hctr].
  apply andb_prop in H as [H Hcoll]. apply andb_prop in H as [H Hsurf]. apply andb_prop in H as [H Hspool].
  apply andb_prop in H as [H Hvm].
  apply andb_prop in H as [H Hcmd].
  apply andb_prop in H as [H Hd12].
  apply andb_prop in H as [H Hord].
  apply andb_prop in H as [H Hst]. apply andb_prop in H as [H Hdb].
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
  - rewrite !CM.load_eq in Hdb. apply orb_true_iff in Hdb as [Hd | Hd]; apply negb_true_iff in Hd;
      [ left | right ]; refine (vint_is_ne _ _ _ Hd); cbn; lia.
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
  - exact (surf_b_sound _ _ _ Hsurf).
  - exact (coll_b_sound _ _ _ _ Hcoll).
  - exact (ctr_s_b_sound _ _ Hctr).
  - exact (ter_b_sound _ _ _ _ Hter).
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

Theorem ow_chk_sound : forall ge bm m, ow_chk ge bm m = true -> obj_w ge bm m.
Proof.
  intros ge bm m H. unfold ow_chk in H.
  destruct (Genv.find_symbol ge object_list_processor._gObjectPool) as [pool|] eqn:H1; [ | discriminate H ].
  destruct (Genv.find_symbol ge object_list_processor._gObjectListArray) as [la|] eqn:H2; [ | discriminate H ].
  destruct (Genv.find_symbol ge object_list_processor._gFreeObjectList) as [fl|] eqn:H3; [ | discriminate H ].
  destruct (Genv.find_symbol ge object_list_processor._gObjectLists) as [gol|] eqn:H4; [ | discriminate H ].
  destruct (Genv.find_symbol ge object_list_processor._gMarioObject) as [gmo|] eqn:H5; [ | discriminate H ].
  destruct (Genv.find_symbol ge debug._sDebugPage) as [sdp|] eqn:H6; [ | discriminate H ].
  destruct (Genv.find_symbol ge debug._gDebugInfo) as [gdi|] eqn:H7; [ | discriminate H ].
  destruct (ow_chk_core_sound _ _ _ _ _ _ _ _ _ _ H) as (rs & fs & C).
  exists pool, la, fl, gol, gmo, sdp, gdi, rs, fs.
  exact (conj H1 (conj H2 (conj H3 (conj H4 (conj H5 (conj H6 (conj H7 C))))))).
Qed.
