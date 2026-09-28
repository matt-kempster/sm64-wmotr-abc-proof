(* spine-root: GOAL 2's object census, decoded from the generated behavior
   scripts -- which behaviors WMotR places, which they spawn by script
   command, their script-set interaction types and collision.  A certificate
   (like YWriterCensus / HeldObjCensus): consumed when the coin-link and
   level-data rows (TRUST.md 0.3 / 0.8) become lemmas. *)
(* ======================================================================= *)
(* GOAL 2: WHAT OBJECTS CAN EXIST IN WMOTR, AND WHAT ARE THEY?              *)
(*                                                                          *)
(* generated/behavior_data.v is clightgen's image of data/behavior_data.c:  *)
(* every behavior script as a word array (int words and function / data     *)
(* pointers).  This file decodes that command stream, mirroring the         *)
(* command table of behavior_script.c (sBehaviorCmdTable) and the macro     *)
(* layouts of behavior_data.c, and fails closed: an unknown opcode or a     *)
(* pointer where a command should be makes the decoder return None.         *)
(*                                                                          *)
(* Scope of THIS file: the SCRIPT layer.  Objects spawned from native C     *)
(* (spawn_object(..., bhvX) in behavior code) and interaction types set in  *)
(* C (obj_set_hitbox, o->oInteractType = ...) are the next layer.           *)
(* ======================================================================= *)

From Coq Require Import ZArith List Bool.
From compcert Require Import Coqlib Integers AST Ctypes.
From SM64.Generated Require behavior_data wmotr_script macro_special_objects.
From SM64.Proofs.WMotRRequiresA Require Import WMotRLevel.
Import ListNotations.

Local Open Scope Z_scope.

Inductive cmd :=
  | CNative (f : ident)                (* 0x0C CALL_NATIVE *)
  | CJump (b : ident)                  (* 0x02 CALL / 0x04 GOTO *)
  | CSpawn (b : ident)                 (* 0x1C / 0x29 / 0x2C SPAWN_* *)
  | CCollision (d : ident)             (* 0x2A LOAD_COLLISION_DATA *)
  | CSetInt (op field value : Z)       (* 0x10 SET_INT / 0x11 OR_INT / 0x12 BIT_CLEAR *)
  | CInteract (t : Z)                  (* 0x2F SET_INTERACT_TYPE *)
  | CPlain (op : Z).                   (* every other command *)

Definition word (d : init_data) : option Z :=
  match d with Init_int32 n => Some (Int.unsigned n) | _ => None end.
Definition ptr (d : init_data) : option ident :=
  match d with Init_addrof b _ => Some b | _ => None end.

(* length in words of each command (behavior_data.c macros) *)
Definition cmd_len (op : Z) : option nat :=
  if (op =? 2) || (op =? 4) || (op =? 12) then Some 2%nat
  else if (19 <=? op) && (op <=? 23) then Some 2%nat
  else if (op =? 35) || (op =? 39) || (op =? 42) || (op =? 46) || (op =? 47)
          || (op =? 49) || (op =? 51) || (op =? 54) || (op =? 55) then Some 2%nat
  else if (op =? 28) || (op =? 41) || (op =? 43) || (op =? 44) then Some 3%nat
  else if op =? 48 then Some 5%nat
  else if (0 <=? op) && (op <=? 55) then Some 1%nat
  else None.

Fixpoint decode (fuel : nat) (l : list init_data) : option (list cmd) :=
  match fuel with
  | O => match l with nil => Some nil | _ => None end
  | S fuel =>
  match l with
  | nil => Some nil
  | d :: r =>
      match word d with
      | None => None
      | Some w =>
          let op := Z.shiftr w 24 in
          let hi8 := Z.land (Z.shiftr w 16) 255 in
          let lo16 := Z.land w 65535 in
          match cmd_len op with
          | None => None
          | Some n =>
              let args := firstn (pred n) r in
              let rest := skipn (pred n) r in
              if negb (Nat.eqb (List.length args) (pred n)) then None else
              let this :=
                if op =? 12 then option_map CNative (ptr (nth 0 args (Init_int8 Int.zero)))
                else if (op =? 2) || (op =? 4) then option_map CJump (ptr (nth 0 args (Init_int8 Int.zero)))
                else if (op =? 28) || (op =? 41) || (op =? 44) then option_map CSpawn (ptr (nth 1 args (Init_int8 Int.zero)))
                else if op =? 42 then option_map CCollision (ptr (nth 0 args (Init_int8 Int.zero)))
                else if op =? 47 then option_map CInteract (word (nth 0 args (Init_int8 Int.zero)))
                else if (16 <=? op) && (op <=? 18) then Some (CSetInt op hi8 lo16)
                else Some (CPlain op) in
              match this, decode fuel rest with
              | Some c, Some cs => Some (c :: cs)
              | _, _ => None
              end
          end
      end
  end
  end.

(* the script of a behavior symbol, looked up in the generated TU *)
Definition script_of (b : ident) : option (list cmd) :=
  match find (fun p => Pos.eqb (fst p) b) behavior_data.global_definitions with
  | Some (_, Gvar v) => decode (List.length (gvar_init v)) (gvar_init v)
  | _ => None
  end.

(* ----------------------------------------------------------------------- *)
(* The behaviors WMotR places: bhvMario (MARIO), the macro objects'         *)
(* presets, and every behavior the level script's arrays point at.         *)
(* ----------------------------------------------------------------------- *)
Definition is_bhv (b : ident) : bool :=
  match find (fun p => Pos.eqb (fst p) b) behavior_data.global_definitions with
  | Some (_, Gvar v) => match gvar_info v with Tarray _ _ _ => true | _ => false end
  | _ => false
  end && match script_of b with Some _ => true | None => false end.

Definition script_refs (l : list init_data) : list ident :=
  flat_map (fun d => match d with Init_addrof b _ => [b] | _ => nil end) l.

Fixpoint dedup (l : list ident) : list ident :=
  match l with
  | nil => nil
  | x :: r => let r' := dedup r in if existsb (Pos.eqb x) r' then r' else x :: r'
  end.

Definition placed : list ident :=
  dedup (filter is_bhv
    (map bhv_of wmotr_macro_objs
     ++ script_refs (gvar_init wmotr_script.v_level_wmotr_entry)
     ++ script_refs (gvar_init wmotr_script.v_script_func_local_1)
     ++ script_refs (gvar_init wmotr_script.v_script_func_local_2))).

From compcert Require Import Ctypesdefs.
From Coq Require Import String.

(* ----------------------------------------------------------------------- *)
(* The spawn closure.  Starting from the placed behaviors, follow every     *)
(* symbol a script, a data table or a function body mentions -- except a   *)
(* symbol that is only compared (`o->behavior == bhvX`), which instantiates *)
(* nothing.  A behavior can come into being only by a spawn_* call or by    *)
(* obj_set_held_state, both of which receive it as a symbol the caller      *)
(* mentions, so the behaviors in the closure over-approximate the ones that *)
(* can exist in WMotR -- relative to the code that is generated.  Calls     *)
(* into code that is not generated are listed (`frontier`).                 *)
(* ----------------------------------------------------------------------- *)
From compcert Require Import Maps Cop Clight.
From SM64.Generated Require mario mario_step mario_actions_stationary
  mario_actions_moving mario_actions_airborne mario_actions_submerged
  mario_actions_cutscene mario_actions_automatic mario_actions_object
  interaction behavior_actions level_update mario_misc surface_collision
  math_util object_helpers obj_behaviors obj_behaviors_2 spawn_object
  object_list_processor.

(* --- where can a behavior pointer's VALUE go?  (a taint analysis) ------ *)
(* An expression carries the taint if its value can be the tainted pointer: *)
(* the pointer itself, a cast of it, or pointer arithmetic on it.  Loading  *)
(* through it (a deref or field load) or comparing it yields something else.            *)
Definition memb (x : ident) (T : PTree.t unit) : bool :=
  match PTree.get x T with Some _ => true | None => false end.

Fixpoint tainted (T : PTree.t unit) (Sy : ident -> bool) (a : expr) : bool :=
  match a with
  | Etempvar t _ => memb t T
  | Evar x _ => Sy x
  | Eaddrof b _ => tainted T Sy b
  | Ecast b _ => tainted T Sy b
  | Ebinop Oadd x y _ | Ebinop Osub x y _ => tainted T Sy x || tainted T Sy y
  | _ => false
  end.

(* externals that only translate an address (memory.c): the result carries
   the taint, nothing is stored *)
Definition is_pure (g : ident) : bool :=
  Pos.eqb g interaction._segmented_to_virtual || Pos.eqb g interaction._virtual_to_segmented.

Definition fn_entry : Type := (list (ident * type) * statement)%type.

Definition add_fns (t : PTree.t (list fn_entry)) (defs : list (ident * globdef fundef type)) :=
  fold_left (fun t '(id, g) =>
    match g with
    | Gfun (Internal f) =>
        PTree.set id ((fn_params f, fn_body f) :: match PTree.get id t with Some o => o | None => nil end) t
    | _ => t
    end) defs t.

Definition all_tus : list (list (ident * globdef fundef type)) :=
  [ behavior_data.global_definitions; mario.global_definitions;
    mario_step.global_definitions; mario_actions_stationary.global_definitions;
    mario_actions_moving.global_definitions; mario_actions_airborne.global_definitions;
    mario_actions_submerged.global_definitions; mario_actions_cutscene.global_definitions;
    mario_actions_automatic.global_definitions; mario_actions_object.global_definitions;
    interaction.global_definitions; behavior_actions.global_definitions;
    level_update.global_definitions; mario_misc.global_definitions;
    surface_collision.global_definitions; math_util.global_definitions;
    object_helpers.global_definitions; obj_behaviors.global_definitions;
    obj_behaviors_2.global_definitions; spawn_object.global_definitions;
    object_list_processor.global_definitions ].

Definition fns : PTree.t (list fn_entry) := fold_left add_fns all_tus (PTree.empty _).

Definition gvar_defs : PTree.t (list (globvar type)) :=
  fold_left (fun t defs => fold_left (fun t '(id, g) =>
    match g with
    | Gvar v => match gvar_init v with
                | nil => t                                 (* an extern declaration *)
                | _ => PTree.set id (v :: match PTree.get id t with Some o => o | None => nil end) t
                end
    | _ => t
    end) defs t) all_tus (PTree.empty _).

(* locals whose address is taken appear as Evar too; they are not frontier *)
Definition all_locals : PTree.t unit :=
  fold_left (fun t defs => fold_left (fun t '(_, g) =>
    match g with
    | Gfun (Internal f) => fold_left (fun t '(x, _) => PTree.set x tt t) (fn_vars f) t
    | _ => t
    end) defs t) all_tus (PTree.empty _).


(* sink table: for each function, the argument positions whose value may be
   stored, returned or handed to code we cannot see *)
Definition sink_tab := PTree.t (list nat).
Definition is_sink (st : sink_tab) (g : ident) (j : nat) : bool :=
  match PTree.get g st with Some l => existsb (Nat.eqb j) l | None => false end.

Fixpoint idx_tainted (T : PTree.t unit) (Sy : ident -> bool) (n : nat) (al : list expr) : list nat :=
  match al with
  | nil => nil
  | a :: r => (if tainted T Sy a then [n] else nil) ++ idx_tainted T Sy (S n) r
  end.

(* one pass over a body: the grown temp-taint set, and whether a sink fired *)
Fixpoint pass (st : sink_tab) (Sy : ident -> bool) (T : PTree.t unit) (s : statement)
  : PTree.t unit * bool :=
  match s with
  | Sassign _ b => (T, tainted T Sy b)
  | Sset t e => (if tainted T Sy e then PTree.set t tt T else T, false)
  | Scall ret f al =>
      let ix := idx_tainted T Sy O al in
      match ix with
      | nil => (T, false)
      | _ =>
        match f with
        | Evar g _ =>
            if is_pure g then
              (match ret with Some t => PTree.set t tt T | None => T end, false)
            else match PTree.get g fns with
                 | Some _ => (T, existsb (is_sink st g) ix)
                 | None => (T, true)          (* code we cannot see *)
                 end
        | _ => (T, true)                      (* indirect call *)
        end
      end
  | Sbuiltin _ _ _ al => (T, negb (Nat.eqb (List.length (idx_tainted T Sy O al)) 0))
  | Sreturn (Some a) => (T, tainted T Sy a)
  | Ssequence a b | Sloop a b =>
      let '(T1, k1) := pass st Sy T a in let '(T2, k2) := pass st Sy T1 b in (T2, k1 || k2)
  | Sifthenelse _ a b =>
      let '(T1, k1) := pass st Sy T a in let '(T2, k2) := pass st Sy T1 b in (T2, k1 || k2)
  | Sswitch _ ls => pass_ls st Sy T ls
  | Slabel _ a => pass st Sy T a
  | _ => (T, false)
  end
with pass_ls (st : sink_tab) (Sy : ident -> bool) (T : PTree.t unit) (ls : labeled_statements)
  : PTree.t unit * bool :=
  match ls with
  | LSnil => (T, false)
  | LScons _ a r =>
      let '(T1, k1) := pass st Sy T a in let '(T2, k2) := pass_ls st Sy T1 r in (T2, k1 || k2)
  end.

(* iterate passes (loops / later uses of earlier-tainted temps) *)
Fixpoint reaches_sink (n : nat) (st : sink_tab) (Sy : ident -> bool) (T : PTree.t unit) (s : statement) : bool :=
  match n with
  | O => true                                  (* out of fuel: assume the worst *)
  | S n =>
      let '(T', k) := pass st Sy T s in
      if k then true
      else if Nat.eqb (List.length (PTree.elements T')) (List.length (PTree.elements T)) then false
      else reaches_sink n st Sy T' s
  end.

Definition NOSYM (_ : ident) : bool := false.

Definition param_sinks (st : sink_tab) (e : fn_entry) : list nat :=
  let '(ps, body) := e in
  let fix go (n : nat) (ps : list (ident * type)) :=
    match ps with
    | nil => nil
    | (p, ty) :: r =>
        (match ty with
         | Tpointer _ _ => if reaches_sink 50 st NOSYM (PTree.set p tt (PTree.empty _)) body then [n] else nil
         | _ => nil
         end) ++ go (S n) r
    end in
  go O ps.

Definition step_sinks (st : sink_tab) : sink_tab :=
  PTree.map (fun _ es => flat_map (param_sinks st) es) fns.

Fixpoint iter_sinks (n : nat) (st : sink_tab) : sink_tab :=
  match n with O => st | S n => iter_sinks n (step_sinks st) end.

Definition sinks : sink_tab := iter_sinks 12 (PTree.empty _).

(* --- the closure ------------------------------------------------------- *)
Definition bhv_set : PTree.t unit :=
  fold_left (fun t '(id, g) =>
    match g with
    | Gvar v => match gvar_info v with Tarray _ _ _ => PTree.set id tt t | _ => t end
    | _ => t
    end) behavior_data.global_definitions (PTree.empty _).
Definition is_bhv_sym (x : ident) : bool := memb x bhv_set.

Fixpoint evars (a : expr) : list ident :=
  match a with
  | Evar x _ => [x]
  | Eaddrof b _ | Ederef b _ | Eunop _ b _ | Ecast b _ | Efield b _ _ => evars b
  | Ebinop _ x y _ => evars x ++ evars y
  | _ => nil
  end.

Fixpoint svars (s : statement) : list ident :=
  match s with
  | Sassign a b => evars a ++ evars b
  | Sset _ a => evars a
  | Scall _ f al => evars f ++ flat_map evars al
  | Sbuiltin _ _ _ al => flat_map evars al
  | Ssequence a b | Sloop a b => svars a ++ svars b
  | Sifthenelse c a b => evars c ++ svars a ++ svars b
  | Sreturn (Some a) => evars a
  | Sswitch a ls => evars a ++ svars_ls ls
  | Slabel _ a => svars a
  | _ => nil
  end
with svars_ls (ls : labeled_statements) : list ident :=
  match ls with LSnil => nil | LScons _ a r => svars a ++ svars_ls r end.

(* a body's references: every non-behavior symbol (functions, tables), and a
   behavior symbol only if its value reaches a sink in that body *)
Definition body_refs (s : statement) : list ident :=
  filter (fun x => negb (is_bhv_sym x) || reaches_sink 50 sinks (Pos.eqb x) (PTree.empty _) s)
         (dedup (svars s)).

Definition gvar_tab : PTree.t (list ident) :=
  fold_left (fun t defs => fold_left (fun t '(id, g) =>
    match g with
    | Gvar v => PTree.set id (script_refs (gvar_init v) ++ match PTree.get id t with Some o => o | None => nil end) t
    | _ => t
    end) defs t) all_tus (PTree.empty _).

Definition refs_of (x : ident) : list ident :=
  match PTree.get x fns with
  | Some es => flat_map (fun e => body_refs (snd e)) es
  | None =>
      match PTree.get x gvar_tab with Some r => r | None => nil end
  end.

Fixpoint close (fuel : nat) (work : list ident) (seen : PTree.t unit) : PTree.t unit :=
  match fuel with
  | O => seen
  | S fuel =>
      match work with
      | nil => seen
      | x :: w =>
          if memb x seen then close fuel w seen
          else close fuel (refs_of x ++ w) (PTree.set x tt seen)
      end
  end.

Definition closure_of (roots : list ident) : list ident :=
  map fst (PTree.elements (close 1000000 roots (PTree.empty _))).

Definition wmotr_closure : list ident := closure_of placed.
Definition reached_bhvs : list ident := filter is_bhv_sym wmotr_closure.
Definition frontier : list ident :=
  filter (fun x => negb (is_bhv_sym x)
                   && match PTree.get x fns with Some _ => false | None => true end
                   && match PTree.get x gvar_defs with Some _ => false | None => true end
                   && negb (memb x all_locals)) wmotr_closure.

(* ----------------------------------------------------------------------- *)
(* Interaction types.  oInteractType is rawData.asU32[0x2A]                 *)
(* (object_fields.h:98).  It is set by a script (SET_INT / OR_INT on field  *)
(* 0x2A, SET_INTERACT_TYPE), by obj_set_hitbox from an ObjectHitbox table   *)
(* (its first word), or by a store in C.  Collect every value any of these  *)
(* can give an object of the closure; None = a value we could not read.     *)
(* ----------------------------------------------------------------------- *)
Definition IT_FIELD : Z := 42.
Definition cidx_z (i : expr) : Z :=
  match i with Econst_int n _ => Int.signed n | Ecast (Econst_int n _) _ => Int.signed n | _ => -1 end.

Definition script_itypes (b : ident) : list (option Z) :=
  match script_of b with
  | Some cs => flat_map (fun c => match c with
                 | CSetInt op fld v => if (fld =? IT_FIELD) && ((op =? 16) || (op =? 17)) then [Some v] else nil
                 | CInteract t => [Some t]
                 | _ => nil end) cs
  | None => [None]
  end.

Definition is_itype_lhs (a : expr) : bool :=
  match a with
  | Ederef (Ebinop Oadd (Efield (Efield _ rd _) arr _) i _) _ =>
      Pos.eqb rd behavior_actions._rawData
      && (Pos.eqb arr behavior_actions._asU32 || Pos.eqb arr behavior_actions._asS32)
      && (cidx_z i =? IT_FIELD)
  | _ => false
  end.

Fixpoint const_of (a : expr) : option Z :=
  match a with
  | Econst_int n _ => Some (Int.unsigned n)
  | Ecast b _ => const_of b
  | Ebinop Oor x y _ =>          (* x |= c: the load of x itself, or c *)
      if is_itype_lhs x then const_of y else None
  | _ => None
  end.

Fixpoint itype_stores (s : statement) : list (option Z) :=
  match s with
  | Sassign a b => if is_itype_lhs a then [const_of b] else nil
  | Ssequence a b | Sloop a b | Sifthenelse _ a b => itype_stores a ++ itype_stores b
  | Sswitch _ ls => itype_stores_ls ls
  | Slabel _ a => itype_stores a
  | _ => nil
  end
with itype_stores_ls (ls : labeled_statements) : list (option Z) :=
  match ls with LSnil => nil | LScons _ a r => itype_stores a ++ itype_stores_ls r end.

Definition hitbox_itype (x : ident) : list (option Z) :=
  match PTree.get x gvar_defs with
  | Some vs => flat_map (fun v =>
      match gvar_info v with
      | Tstruct id _ => if Pos.eqb id behavior_actions._ObjectHitbox
                        then [match gvar_init v with Init_int32 n :: _ => Some (Int.unsigned n) | _ => None end]
                        else nil
      | _ => nil
      end) vs
  | None => nil
  end.

Definition closure_itypes : list (ident * option Z) :=
  flat_map (fun x =>
    map (fun v => (x, v))
      (if is_bhv_sym x then script_itypes x
       else match PTree.get x fns with
            | Some es => flat_map (fun e => itype_stores (snd e)) es
            | None => hitbox_itype x
            end)) wmotr_closure.


(* ----------------------------------------------------------------------- *)
(* The census, pinned.                                                      *)
(* ----------------------------------------------------------------------- *)

(* the behaviors WMotR places *)
Lemma placed_value : map string_of_ident placed = [
     "bhvCannonClosed"; "bhvBobombBuddyOpensCannon"; "bhvHidden1UpInPoleSpawner";
     "bhvExclamationBox"; "bhvRedCoin"; "bhvCoinFormation"; "bhv1Up"; "bhvMario";
     "bhvAirborneWarp"; "bhvPoleGrabbing"; "bhvHiddenRedCoinStar" ]%string.
Proof. vm_compute. reflexivity. Qed.

(* the sink table is a fixpoint of the analysis (no more rounds would add a sink) *)
Lemma sinks_stable : PTree.elements (step_sinks sinks) = PTree.elements sinks.
Proof. vm_compute. reflexivity. Qed.

(* every behavior that can come into being in WMotR, over the generated code
   (an over-approximation: every Mario action is reachable, for instance) *)
Lemma reached_bhvs_value : map string_of_ident reached_bhvs = [
     "cannon_lid_seg8_collision_08004950";
     "exclamation_box_outline_seg8_collision_08025F78"; "peach_seg5_anims_0501C41C";
     "toad_seg6_anims_0600FB58"; "bowser_key_seg3_anims_list";
     "bobomb_seg8_anims_0802396C"; "bhvMistCircParticleSpawner"; "bhvMistParticleSpawner";
     "bhvMario"; "bhvMetalCap"; "bhvExclamationBox"; "bhvEndPeach"; "bhvEndToad";
     "bhvUnlockDoorStar"; "bhvAirborneWarp"; "bhvIdleWaterWave"; "bhvYellowCoin";
     "bhvObjectWaterWave"; "bhvObjectWaterSplash"; "bhvObjectWaveTrail"; "bhvObjectBubble";
     "bhvOrangeNumber"; "bhvGoldenCoinSparkles"; "bhvWingCap"; "bhvWind";
     "bhvWallTinyStarParticle"; "bhvWaterMist"; "bhvWaterSplash"; "bhvWaterDropletSplash";
     "bhvWaterDroplet"; "bhvWaveTrail"; "bhvWhitePuffExplosion"; "bhvWhitePuff2";
     "bhvWhitePuff1"; "bhvCoinSparkles"; "bhvCoinFormationSpawn"; "bhvCoinFormation";
     "bhvCarrySomething4"; "bhvCarrySomething5"; "bhvCarrySomething3"; "bhvCannonClosed";
     "bhvCannon"; "bhvCannonBarrel"; "bhvCelebrationStarSparkle"; "bhvCelebrationStar";
     "bhvSingleCoinGetsSpawned"; "bhvSmallWaterWave"; "bhvSmallWaterWave398";
     "bhvSmallParticle"; "bhvShallowWaterWave"; "bhvShallowWaterSplash"; "bhvSpawnedStar";
     "bhvSpawnedStarNoLevelExit"; "bhvSparkleSpawn"; "bhvSparkle";
     "bhvSparkleParticleSpawner"; "bhvStaticObject"; "bhvStarSpawnCoordinates";
     "bhvStarKeyCollectionPuffSpawner"; "bhvStar"; "bhvSnowParticleSpawner";
     "bhvKoopaShell"; "bhvKoopaShellFlame"; "bhv1UpWalking"; "bhv1Up"; "bhv1UpRunningAway";
     "bhvNormalCap"; "bhvFireParticleSpawner"; "bhvVanishCap";
     "bhvVertStarParticleSpawner"; "bhvBowserKeyUnlockDoor"; "bhvBowserKeyCourseExit";
     "bhvBobombBuddyOpensCannon"; "bhvBubbleSplash"; "bhvBubbleParticleSpawner";
     "bhvBlackSmokeMario"; "bhvBreakBoxTriangle"; "bhvBreathParticleSpawner";
     "bhvRotatingExclamationMark"; "bhvRedCoinStarMarker"; "bhvRedCoin";
     "bhvPoundTinyStarParticle"; "bhvPoleGrabbing"; "bhvPunchTinyTriangle";
     "bhvPlungeBubble"; "bhvHorStarParticleSpawner"; "bhvHidden1UpInPoleSpawner";
     "bhvHidden1UpInPole"; "bhvHidden1UpInPoleTrigger"; "bhvHiddenRedCoinStar";
     "bhvDirtParticleSpawner"; "bhvTenCoinsSpawn"; "bhvThreeCoinsSpawn";
     "bhvTriangleParticleSpawner"; "bhvTreeSnow"; "bhvTreeLeaf"; "bhvLeafParticleSpawner";
     "blue_fish_seg3_anims_0301C2B0" ]%string.
Proof. vm_compute. reflexivity. Qed.

(* THE GRAB FACT: no object of the closure can ever carry INTERACT_GRABBABLE
   (bit 1).  Every interaction type a script, a hitbox table or a C store
   can give it is a known constant without that bit; the one unreadable
   store is obj_set_hitbox copying hitbox->interactType, whose tables are
   the ObjectHitbox rows listed. *)
Definition INTERACT_GRABBABLE : Z := 2.
Lemma closure_itypes_value :
  map (fun p => (string_of_ident (fst p), snd p)) closure_itypes = [
     ("obj_set_hitbox", None); ("sExclamationBoxHitbox", Some 512);
     ("sYellowCoinHitbox", Some 16); ("sCollectStarHitbox", Some 4096);
     ("sCapHitbox", Some 32); ("sSparkleSpawnStarHitbox", Some 4096);
     ("sKoopaShellHitbox", Some 524288); ("sRedCoinHitbox", Some 16);
     ("bhvCannon", Some 16384); ("bhvKoopaShellFlame", Some 262144);
     ("bhvBobombBuddyOpensCannon", Some 8388608); ("bhvPoleGrabbing", Some 64) ]%string.
Proof. vm_compute. reflexivity. Qed.

Lemma no_grabbable_in_wmotr :
  forallb (fun p => match snd p with
                    | Some v => Z.land v INTERACT_GRABBABLE =? 0
                    | None => Pos.eqb (fst p) behavior_actions._obj_set_hitbox
                    end) closure_itypes = true.
Proof. vm_compute. reflexivity. Qed.

(* what the closure calls or reads that is NOT generated (TRUST.md 0.10):
   audio, camera, dialog, save file, graph nodes, RNG, collision loading,
   the debug spawner.  The census is complete only if none of these spawns
   an object or writes oInteractType. *)
Lemma frontier_value : map string_of_ident frontier = [
     "gAudioRandom"; "gAreas"; "gObjCutsceneDone"; "gObjParentGraphNode";
     "gGlobalSoundSource"; "gGlobalTimer"; "gCameraMovementFlags"; "gCamera";
     "gCutsceneFocus"; "gCurrAreaIndex"; "gCurrCourseNum"; "gCurrCreditsEntry";
     "gCurrSaveFileNum"; "gCurrentArea"; "gCurrDemoInput"; "gCurrLevelNum";
     "gSaveOptSelectIndex"; "gSavedCourseNum"; "gShowDebugText"; "gSpecialTripleJump";
     "gStaticSurfacePartition"; "geo_obj_init_animation"; "geo_obj_init"; "geo_add_child";
     "geo_update_animation_frame"; "geo_remove_child"; "get_current_background_music";
     "get_dialog_id"; "gVec3sZero"; "gVec3fZero"; "gRecentCutscene"; "gRedCoinsCollected";
     "gPaintingMarioYEntry"; "gPlayer1Controller"; "gDynamicSurfacePartition";
     "gDialogResponse"; "gDebugLevelSelect"; "gLoadedGraphNodes";
     "gLastCompletedCourseNum"; "gLastCompletedStarNum"; "override_viewport_and_clip";
     "camera_approach_f32_symmetric"; "cutscene_object_with_dialog"; "cutscene_object";
     "cur_obj_play_sound_2"; "cur_obj_play_sound_1"; "create_sound_spawner";
     "create_dialog_inverted_box"; "create_dialog_box_with_response";
     "create_dialog_box_with_var"; "create_dialog_box"; "sound_banks_enable";
     "save_file_get_star_flags"; "save_file_get_total_star_count"; "save_file_get_flags";
     "save_file_collect_star_or_key"; "save_file_clear_flags"; "save_file_set_cap_pos";
     "save_file_set_cannon_unlocked"; "save_file_set_flags";
     "save_file_is_cannon_unlocked"; "save_file_do_save"; "sqrtf"; "segmented_to_virtual";
     "seq_player_unlower_volume"; "seq_player_lower_volume"; "set_camera_shake_from_hit";
     "set_camera_mode"; "set_cutscene_message"; "set_sound_moving_speed"; "set_menu_mode";
     "stop_cap_music"; "stop_sounds_from_source"; "stop_sound"; "stop_shell_music";
     "alloc_display_list"; "area_get_warp_node"; "enable_background_sound";
     "play_course_clear"; "play_cap_music"; "play_cutscene_music"; "play_sound";
     "play_shell_music"; "play_infinite_stairs_music"; "play_music";
     "play_power_star_jingle"; "play_peachs_jingle"; "play_transition";
     "print_text_fmt_int"; "lower_background_noise"; "load_object_collision_model";
     "load_patchable_table"; "disable_background_sound"; "drop_queued_background_music";
     "try_print_debug_mario_level_info"; "try_do_mario_debug_object_spawn";
     "trigger_cutscene_dialog"; "raise_background_noise"; "random_u16"; "random_float";
     "reset_cutscene_msg_fade"; "retrieve_animation_index"; "fadeout_cap_music";
     "fadeout_music"; "fadeout_level_music"; "virtual_to_segmented" ]%string.
Proof. vm_compute. reflexivity. Qed.
