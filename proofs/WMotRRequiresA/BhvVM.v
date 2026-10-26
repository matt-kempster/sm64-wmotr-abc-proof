(* spine-root: B3 (ii), the behavior-script VM's reachable states -- the
   census behind obj_w's CMDPOS clause (a slot's script pointer and stack
   are a reachable VM state), which the cur_obj_update stepper needs:
   BehaviorCmdTable has 56 cells and is indexed by the opcode byte. *)
(* ======================================================================= *)
(* BhvVM.v -- where can a WMotR object's script pointer be?                *)
(*                                                                         *)
(* cur_obj_update runs BehaviorCmdTable[*gCurBhvCommand >> 24]().  The     *)
(* table has 56 cells; obj_w's script_ok only said the pointer lies in a   *)
(* live script's block, at ANY offset, so the opcode byte could be any of *)
(* 0..255 (SHARPENING / FOUND 2026-10-26: script_ok alone allowed an      *)
(* out-of-table index, i.e. a Clight-stuck dispatch).                      *)
(*                                                                         *)
(* This file runs the script VM abstractly over behavior_data's generated *)
(* words: a state is (script symbol, word index, stack of frames), a frame *)
(* a pushed command address or a repeat count, as behavior_script.c's     *)
(* handlers push them (CALL / BEGIN_LOOP / BEGIN_REPEAT; RETURN /         *)
(* END_LOOP / END_REPEAT pop).  From every live script's entry (word 0,   *)
(* and word 1 after a BEGIN: create_object skips it) it collects every     *)
(* reachable state and checks, fail-closed:                                *)
(*   - the word at the index is an int whose opcode has a command length  *)
(*     (so < 56: BehaviorScripts.cmd_len),                                 *)
(*   - the command fits in the script,                                     *)
(*   - every pop finds the frame kind it needs, the stack never exceeds   *)
(*     bhvStack's 8 cells,                                                 *)
(*   - every jump target is a word-aligned address in a script.           *)
(* The command lengths / jumps used here are the macro layouts; B3 (iii)  *)
(* ties each one to its handler's generated body (the stepper).           *)
(* ======================================================================= *)

From Coq Require Import ZArith List Bool String.
From compcert Require Import Coqlib Integers AST Ctypes Maps Ctypesdefs.
From SM64.Generated Require behavior_data.
From SM64.Proofs.WMotRRequiresA Require Import BehaviorScripts.
From SM64.Proofs.WMotRRequiresA Require ObjTable.
Import ListNotations.
Local Open Scope Z_scope.

Inductive frame := FAddr (s : ident) (i : nat) | FCount.
Record vst := { v_s : ident; v_i : nat; v_k : list frame }.

Definition frame_eqb (a b : frame) : bool :=
  match a, b with
  | FAddr s i, FAddr s' i' => Pos.eqb s s' && Nat.eqb i i'
  | FCount, FCount => true
  | _, _ => false
  end.
Fixpoint stk_eqb (a b : list frame) : bool :=
  match a, b with
  | [], [] => true
  | x :: a', y :: b' => frame_eqb x y && stk_eqb a' b'
  | _, _ => false
  end.
Definition vst_eqb (a b : vst) : bool :=
  Pos.eqb (v_s a) (v_s b) && Nat.eqb (v_i a) (v_i b) && stk_eqb (v_k a) (v_k b).

(* the generated words of every behavior_data variable *)
Definition words_tab : PTree.t (list init_data) :=
  fold_left (fun t '(id, g) =>
    match g with Gvar v => PTree.set id (gvar_init v) t | _ => t end)
    behavior_data.global_definitions (PTree.empty _).

Definition words (s : ident) : list init_data :=
  match words_tab ! s with Some l => l | None => [] end.

Definition word_at (s : ident) (i : nat) : option Z := match nth_error (words s) i with
  | Some d => word d | None => None end.

(* a jump target: &script[i] *)
Definition target_at (s : ident) (i : nat) : option (ident * nat) :=
  match nth_error (words s) i with
  | Some (Init_addrof t o) =>
      let z := Ptrofs.unsigned o in
      if (z mod 4 =? 0) && negb (Nat.eqb (List.length (words t)) 0)
      then Some (t, Z.to_nat (z / 4)) else None
  | _ => None
  end.

(* successors of a state; None = the state is ill-formed (fail closed) *)
Definition succs (st : vst) : option (list vst) :=
  let s := v_s st in let i := v_i st in let k := v_k st in
  let at_ i' k' := {| v_s := s; v_i := i'; v_k := k' |} in
  match word_at s i with
  | None => None
  | Some w =>
      let op := Z.shiftr w 24 in
      match cmd_len op with
      | None => None
      | Some n =>
          if Nat.ltb (List.length (words s)) (i + n)%nat then None else
          if op =? 2 then                                  (* CALL *)
            match target_at s (i + 1)%nat with
            | Some (t, j) => Some [{| v_s := t; v_i := j; v_k := FAddr s (i + 2)%nat :: k |}]
            | None => None
            end
          else if op =? 3 then                             (* RETURN *)
            match k with FAddr t j :: k' => Some [{| v_s := t; v_i := j; v_k := k' |}] | _ => None end
          else if op =? 4 then                             (* GOTO *)
            match target_at s (i + 1)%nat with
            | Some (t, j) => Some [{| v_s := t; v_i := j; v_k := k |}]
            | None => None
            end
          else if (op =? 5) || (op =? 38) then             (* BEGIN_REPEAT(_UNUSED) *)
            Some [at_ (i + 1)%nat (FCount :: FAddr s (i + 1)%nat :: k)]
          else if (op =? 6) || (op =? 7) then              (* END_REPEAT(_CONTINUE) *)
            match k with
            | FCount :: FAddr t j :: k' =>
                Some [{| v_s := t; v_i := j; v_k := FCount :: FAddr t j :: k' |}; at_ (i + 1)%nat k']
            | _ => None
            end
          else if op =? 8 then                             (* BEGIN_LOOP *)
            Some [at_ (i + 1)%nat (FAddr s (i + 1)%nat :: k)]
          else if op =? 9 then                             (* END_LOOP *)
            match k with
            | FAddr t j :: k' => Some [{| v_s := t; v_i := j; v_k := FAddr t j :: k' |}]
            | _ => None
            end
          else if (op =? 10) || (op =? 11) || (op =? 29) then   (* BREAK(_UNUSED), DEACTIVATE *)
            Some [st]
          else if (op =? 1) || (op =? 37) then             (* DELAY, DELAY_VAR *)
            Some [st; at_ (i + 1)%nat k]
          else Some [at_ (i + n)%nat k]
      end
  end.

Definition ok_depth (st : vst) : bool := Nat.leb (List.length (v_k st)) 8.

Definition memv (x : vst) (l : list vst) : bool := existsb (vst_eqb x) l.

(* worklist exploration *)
Fixpoint explore (fuel : nat) (todo seen : list vst) : option (list vst) :=
  match fuel with
  | O => None
  | S fuel =>
      match todo with
      | [] => Some seen
      | st :: todo' =>
          if memv st seen then explore fuel todo' seen else
          if negb (ok_depth st) then None else
          match succs st with
          | None => None
          | Some ns => explore fuel (ns ++ todo') (st :: seen)
          end
      end
  end.

(* The scripts an object can START in (create_object's and
   obj_set_held_state's argument): every live BehaviorScript array (u32
   words; the closure's other behavior_data symbols are collision /
   animation data), except a FRAGMENT -- a script that no placement, no
   function and no data table mentions, only scripts, and those only as a
   CALL / GOTO target (never as a SPAWN_* argument). *)
Definition gvar_tab : PTree.t (globvar type) :=
  fold_left (fun t '(id, g) => match g with Gvar v => PTree.set id v t | _ => t end)
    behavior_data.global_definitions (PTree.empty _).

Definition is_script (b : ident) : bool :=
  match gvar_tab ! b with
  | Some v => match gvar_info v, gvar_init v with
              | Ctypes.Tarray (Ctypes.Tint Ctypes.I32 Ctypes.Unsigned _) _ _, _ :: _ => true
              | _, _ => false
              end
  | None => false
  end.

Definition referrers (x : ident) : list ident :=
  filter (fun y => existsb (Pos.eqb x) (refs_of y)) wmotr_closure.

Definition jumps_only (x r : ident) : bool :=
  is_script r &&
  match script_of r with
  | Some cs => forallb (fun c => match c with CSpawn b => negb (Pos.eqb b x) | _ => true end) cs
  | None => false
  end.

Definition fragment (x : ident) : bool :=
  negb (existsb (Pos.eqb x) placed)
  && negb (Nat.eqb (List.length (referrers x)) 0)
  && forallb (jumps_only x) (referrers x).

Definition entry_bhvs : list ident :=
  filter (fun b => is_script b && negb (fragment b)) reached_bhvs.

(* entry states: word 0 (obj_set_held_state; create_object for a script
   without BEGIN) and word 1 (create_object skips a BEGIN) *)
Definition entries (b : ident) : list vst :=
  {| v_s := b; v_i := 0; v_k := [] |} ::
  match word_at b 0 with
  | Some w => if Z.shiftr w 24 =? 0 then [{| v_s := b; v_i := 1; v_k := [] |}] else []
  | None => []
  end.

Definition vm_states : option (list vst) :=
  explore 100000 (flat_map entries entry_bhvs) [].

(* the reachable states (not materialized: vm readback of 741 states takes
   minutes; each lemma below recomputes them in ~20 s) *)
Definition opt_list {A : Type} (o : option (list A)) : list A :=
  match o with Some l => l | None => [] end.
Definition vm_tab : list vst := opt_list vm_states.

Lemma vm_tab_states : vm_states = Some vm_tab.
Proof. vm_compute. reflexivity. Qed.

Lemma vm_tab_count : List.length vm_tab = 741%nat.
Proof. vm_compute. reflexivity. Qed.

(* what the stepper consumes: the table is closed under the VM step, every
   state decodes (opcode < 56, the command fits), the stack stays within
   bhvStack[8], and every entry state is in it *)
Lemma vm_tab_closed :
  forallb (fun st => match succs st with
                     | Some ns => forallb (fun n => memv n vm_tab) ns
                     | None => false
                     end) vm_tab = true.
Proof. vm_compute. reflexivity. Qed.

Lemma vm_tab_depth : forallb ok_depth vm_tab = true.
Proof. vm_compute. reflexivity. Qed.

Lemma vm_tab_entries : forallb (fun st => memv st vm_tab) (flat_map entries entry_bhvs) = true.
Proof. vm_compute. reflexivity. Qed.

Lemma entry_excluded :
  map string_of_ident (filter (fun b => negb (is_script b) || fragment b) reached_bhvs) =
  [ "cannon_lid_seg8_collision_08004950"; "exclamation_box_outline_seg8_collision_08025F78";
    "peach_seg5_anims_0501C41C"; "toad_seg6_anims_0600FB58"; "bowser_key_seg3_anims_list";
    "bobomb_seg8_anims_0802396C"; "bhvSmallWaterWave398"; "blue_fish_seg3_anims_0301C2B0" ]%string.
Proof. vm_compute. reflexivity. Qed.

(* ----------------------------------------------------------------------- *)
(* Indexed arguments at the reachable states (B3 iii groundwork): no       *)
(* handler indexes out of its array.                                       *)
(*  - field commands (ADD/SET_FLOAT, ADD/SET_INT, OR_INT, BIT_CLEAR, the   *)
(*    random ones, DELAY_VAR, LOAD_ANIMATIONS, ANIMATE_TEXTURE,            *)
(*    SET_INT_UNUSED, PARENT_BIT_CLEAR, SUM_FLOAT / SUM_INT's three        *)
(*    fields) index o->rawData.asU32[0x50]: every field byte is < 0x50;    *)
(*  - SET_MODEL / SPAWN_CHILD / SPAWN_CHILD_WITH_PARAM / SPAWN_OBJ index   *)
(*    gLoadedGraphNodes = D_8033A160[0x100]: every model id is in [0,256). *)
(* ----------------------------------------------------------------------- *)
Definition w0 (st : vst) : Z := match word_at (v_s st) (v_i st) with Some w => w | None => -1 end.
Definition opc (st : vst) : Z := Z.shiftr (w0 st) 24.
Definition byte2 (w : Z) : Z := Z.land (Z.shiftr w 16) 255.
Definition byte3 (w : Z) : Z := Z.land (Z.shiftr w 8) 255.
Definition byte4 (w : Z) : Z := Z.land w 255.

Definition field_ops : list Z := [13; 14; 15; 16; 17; 18; 19; 20; 21; 22; 23; 37; 39; 51; 52; 54].
Definition fields_of (st : vst) : list Z :=
  let w := w0 st in
  if existsb (Z.eqb (opc st)) field_ops then [byte2 w]
  else if (opc st =? 31) || (opc st =? 32) then [byte2 w; byte3 w; byte4 w] else [].

Lemma vm_fields_in_rawdata :
  forallb (fun st => forallb (fun f => (0 <=? f) && (f <? 80)) (fields_of st)) vm_tab = true.
Proof. vm_compute. reflexivity. Qed.

Definition model_of (st : vst) : option Z :=
  if opc st =? 27 then Some (Z.land (w0 st) 65535)
  else if (opc st =? 28) || (opc st =? 41) || (opc st =? 44)
  then word_at (v_s st) (v_i st + 1)%nat else None.

Lemma vm_models_in_table :
  forallb (fun st => match model_of st with Some z => (0 <=? z) && (z <? 256) | None => true end) vm_tab = true.
Proof. vm_compute. reflexivity. Qed.

(* ANIMATE (0x28) indexes the object's oAnimations table.  The reachable
   ANIMATE states and the tables their scripts load (LOAD_ANIMATIONS,
   0x27).  FOUND 2026-10-26: these tables were only DECLARED in the link
   (behavior_data's extern, size 0) -- the actor animation data was not
   linked -- and bhvBobombBuddyOpensCannon is PLACED in WMotR.  REPAIRED
   the same day: pipeline/tu/wmotr_level_data.c links the vendor anim
   .inc.c files (closure_data_linked / vm_data_args_linked below). *)
Definition ptr_at (st : vst) (k : nat) : option ident :=
  match nth_error (words (v_s st)) (v_i st + k)%nat with Some (Init_addrof t _) => Some t | _ => None end.

Lemma vm_animate_users :
  map (fun st => (string_of_ident (v_s st), byte2 (w0 st))) (filter (fun st => opc st =? 40) vm_tab) =
  [ ("bhvBobombBuddyOpensCannon", 0); ("bhvEndToad", 0); ("bhvEndPeach", 0) ]%string.
Proof. vm_compute. reflexivity. Qed.

Lemma vm_anim_tables :
  map (fun st => (string_of_ident (v_s st), option_map string_of_ident (ptr_at st 1)))
      (filter (fun st => opc st =? 39) vm_tab) =
  [ ("bhvBobombBuddyOpensCannon", Some "bobomb_seg8_anims_0802396C");
    ("bhvBowserKeyCourseExit", Some "bowser_key_seg3_anims_list");
    ("bhvBowserKeyUnlockDoor", Some "bowser_key_seg3_anims_list");
    ("bhvEndToad", Some "toad_seg6_anims_0600FB58");
    ("bhvEndPeach", Some "peach_seg5_anims_0501C41C") ]%string.
Proof. vm_compute. reflexivity. Qed.

(* ----------------------------------------------------------------------- *)
(* Linked-data census (2026-10-26, systematic; replaces the one-off        *)
(* vm_anim_tables_unlinked).  A global that is only DECLARED in every TU  *)
(* of the link is a size-0 block, so any load from it has no Clight       *)
(* execution, and a theorem over runs that reach such a load is vacuous   *)
(* there.  Two fail-closed checks over the real link (ObjTable.lprogs):   *)
(*  (a) every global VARIABLE in the WMotR closure (BehaviorScripts: the  *)
(*      placed behaviors, every script / function / table they reach, all *)
(*      the anim tables, collision meshes, model / geo pointers, dialog,  *)
(*      trajectories and hitboxes the closure's bodies and scripts name)  *)
(*      has a definer in the link with a non-empty initializer;           *)
(*  (b) every data argument of a reachable script command                 *)
(*      (LOAD_ANIMATIONS 0x27, LOAD_COLLISION_DATA 0x2A,                  *)
(*      SPAWN_WATER_DROPLET 0x37 word 1) is such a symbol.                *)
(* ----------------------------------------------------------------------- *)
Definition defined_nonempty (t : ident) : bool :=
  existsb (fun p => existsb (fun '(id, g) =>
     Pos.eqb id t && match g with Gvar v => 0 <? init_data_list_size (gvar_init v)
                                 | _ => false end) (prog_defs p)) ObjTable.lprogs.

Definition is_gvar_in_link (t : ident) : bool :=
  existsb (fun p => existsb (fun '(id, g) =>
     Pos.eqb id t && match g with Gvar _ => true | _ => false end) (prog_defs p)) ObjTable.lprogs.

Lemma closure_data_linked :
  forallb (fun t => negb (is_gvar_in_link t) || defined_nonempty t) wmotr_closure = true.
Proof. vm_compute. reflexivity. Qed.

Definition data_args (st : vst) : list ident :=
  if (opc st =? 39) || (opc st =? 42) || (opc st =? 55) then
    match ptr_at st 1 with Some t => [t] | None => [] end else [].

Lemma vm_data_args_linked :
  forallb (fun st => implb ((opc st =? 39) || (opc st =? 42) || (opc st =? 55))
                     (match ptr_at st 1 with Some _ => true | None => false end
                      && forallb defined_nonempty (data_args st))) vm_tab = true.
Proof. vm_compute. reflexivity. Qed.
