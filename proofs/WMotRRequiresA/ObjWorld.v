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
From SM64.Generated Require object_list_processor behavior_data object_helpers debug.
From SM64.Proofs Require Interp.CMem.
From SM64.Proofs Require Import CensusV2.
From SM64.Proofs.WMotRRequiresA Require Import WMotRWorld.
From SM64.Proofs.WMotRRequiresA Require BehaviorScripts ObjAct.

Import ListNotations.
Local Open Scope string_scope.
Module CM := SM64.Proofs.Interp.CMem.
Local Open Scope Z_scope.

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

  Definition act_ok (k : Z) : Prop :=
    forall bh t, In (bh, t) act_pairs -> is_bhv k bh ->
      exists a, Mem.load Mint32 m pool (k * OSZ + O_ACTION) = Some (Vint a)
                /\ 0 <= Int.signed a < tlen t.

  Definition kind_ok (k : Z) : Prop :=
    exists t, Mem.load Mint32 m pool (k * OSZ + O_INTERACT_TYPE) = Some (Vint t)
      /\ In (Int.unsigned t) wmotr_interact_types
      /\ (Int.unsigned t = INTERACT_POLE -> pole_obj_ok m pool (k * OSZ))
      /\ (Int.unsigned t = INTERACT_CANNON_BASE -> cannon_obj_ok m pool (k * OSZ)).

  Definition red_ok (k : Z) : Prop :=
    ~ is_bhv k behavior_data._bhvStarSpawnCoordinates
    /\ (is_bhv k behavior_data._bhvHiddenRedCoinStar ->
        exists c, Mem.load Mint32 m pool (k * OSZ + O_HSCOUNT) = Some (Vint c) /\ Int.signed c < 8).

  Definition slot_ptr (v : val) : Prop :=
    v = Vnullptr \/ exists k, 0 <= k < NSLOT /\ v = slot_v pool k.
End CLAUSES.

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
               exists v, Mem.load Mint32 m bm z = Some v /\ slot_ptr pool v
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
(*    cannon base, an action-table behavior, the hidden red-coin star are *)
(*    rejected outright -- the boot witness holds none of them).          *)
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

  Lemma script_b_sound : forall k, script_b k = true -> script_ok ge pool m k.
  Proof.
    intros k H. unfold script_b, ld32 in H. rewrite CM.load_eq in H.
    destruct (Mem.load Mint32 m pool (k * OSZ + O_CMD)) as [[| | | | | b o]|] eqn:Hl;
      [ discriminate H .. | | discriminate H ].
    apply existsb_exists in H as (id & Hin & Hb).
    destruct (Genv.find_symbol ge id) as [b'|] eqn:Hs; [ | discriminate Hb ].
    apply Pos.eqb_eq in Hb. subst b'. exists id, b, o. exact (conj Hin (conj Hs Hl)).
  Qed.

  Definition act_b (k : Z) : bool := forallb (fun p => not_bhv_b k (fst p)) act_pairs.

  Lemma act_b_sound : forall k, act_b k = true -> act_ok ge pool m k.
  Proof.
    intros k H bh t Hin Hb. exfalso.
    pose proof (proj1 (forallb_forall _ _) H _ Hin) as Hn. exact (not_bhv_b_sound k bh Hn Hb).
  Qed.

  Definition kind_b (k : Z) : bool :=
    match ld32 m pool (k * OSZ + O_INTERACT_TYPE) with
    | Some (Vint t) => existsb (Z.eqb (Int.unsigned t)) wmotr_interact_types
                       && negb (Z.eqb (Int.unsigned t) INTERACT_POLE)
                       && negb (Z.eqb (Int.unsigned t) INTERACT_CANNON_BASE)
    | _ => false
    end.

  Lemma kind_b_sound : forall k, kind_b k = true -> kind_ok pool m k.
  Proof.
    intros k H. unfold kind_b, ld32 in H. rewrite CM.load_eq in H.
    destruct (Mem.load Mint32 m pool (k * OSZ + O_INTERACT_TYPE)) as [[| t | | | |]|] eqn:Hl; try discriminate H.
    apply andb_prop in H as [H Hc]. apply andb_prop in H as [Hi Hp].
    apply existsb_exists in Hi as (z & Hz & E). apply Z.eqb_eq in E. subst z.
    apply negb_true_iff, Z.eqb_neq in Hp. apply negb_true_iff, Z.eqb_neq in Hc.
    exists t. split; [ exact Hl | split; [ exact Hz | split; intro E; contradiction ] ].
  Qed.

  Definition red_b (k : Z) : bool :=
    not_bhv_b k behavior_data._bhvStarSpawnCoordinates && not_bhv_b k behavior_data._bhvHiddenRedCoinStar.

  Lemma red_b_sound : forall k, red_b k = true -> red_ok ge pool m k.
  Proof.
    intros k H. apply andb_prop in H as [H1 H2].
    split; [ exact (not_bhv_b_sound _ _ H1) | intros Hb; exfalso; exact (not_bhv_b_sound _ _ H2 Hb) ].
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
      | None => false
      end
  | _, _, _ => false
  end.

Lemma veqb_eq : forall x y, veqb x y = true -> x = y.
Proof. intros x y H. unfold veqb in H. destruct (Val.eq x y); [ assumption | discriminate H ]. Qed.

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
