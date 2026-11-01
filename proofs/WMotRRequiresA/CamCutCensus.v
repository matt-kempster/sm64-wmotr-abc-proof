(* spine-root: the camera family's WMotR census (TRUST 3.2 UB worklist and
   the Hcam_phi / Hcam_ow gates): CamIdxCensus's open carries closed by a
   path- and level-aware value census, which cutscenes can start in WMotR,
   and what the camera can reach there.  Machine-checked on the generated
   link; a census, not a proof (what it leaves open is named). *)
(* ====================================================================== *)
(* CamCutCensus.v                                                         *)
(*                                                                        *)
(* Two refinements of CamIdxCensus's value-source census (leaves):        *)
(*  - PATH GUARDS (guarded): a constant k passed to parameter p of g is   *)
(*    dropped when every use of p in g that can carry the value on        *)
(*    (a whole Sset / Sassign right side, a call argument, a return,      *)
(*    casts aside) sits where a test `p != k` (or the else-branch of      *)
(*    `p == k`, or a temp holding such a test) is known true.  The        *)
(*    constant must fit p's type (so the test sees k itself).             *)
(*  - LEVEL-DEAD CALL SITES (callers_ctx): a call inside a case of a      *)
(*    switch on gCurrLevelNum (or on a temp only ever loaded from it)     *)
(*    that neither a LEVEL_WMOTR (31) label nor default reaches, with     *)
(*    fallthrough followed, is dead in WMotR.  gCurrLevelNum = 31 is      *)
(*    carried (FfWorld.lvl_w, inside PhiW).                               *)
(*  and a call's result is followed into the callee's returns.            *)
(*                                                                        *)
(* 1. MODE (sModeTransitions[mode]): with the guards, the two guarded     *)
(*    leaves go (set_camera_mode's `mode != -1`,                          *)
(*    set_mode_if_not_set_by_surface's `mode != 0`); what is left is      *)
(*    create_camera's gc->config.mode, the GEO_CAMERA node.  Geo layouts  *)
(*    are not linked: the boot witness passes WMotR's mode 16             *)
(*    (StartTerrain.cam_chain, levels/wmotr/areas/1/geo.inc.c:16) -- one   *)
(*    TRUST 3.2 line.                                                      *)
(* 2. CUTSCENE VALUES: every value that can reach Camera.cutscene or      *)
(*    sObjectCutscene, link-wide, is a constant, a cutscene cell, or a    *)
(*    read of sDanceCutsceneTable[nibble of sDanceCutsceneIndexTable];    *)
(*    the tables' nibbles are < 5, picking the five dance cutscenes.  So  *)
(*    CUTSCENE_SSL_PYRAMID_EXPLODE (168) is never stored, and             *)
(*    CUTSCENE_ENTER_BOWSER_ARENA (144) only by init_camera's three       *)
(*    Bowser-level arms, dead in WMotR.  The tables involved are only     *)
(*    read (never stored, no address escapes).                            *)
(*    NOTE (decomp UB, not WMotR): CUTSCENE_WATER_DEATH (159, from        *)
(*    ACT_WATER_DEATH) has no case in play_cutscene's switch, so its       *)
(*    cutsceneDuration is read uninitialized.                             *)
(* 3. WHAT THE CAMERA REACHES IN WMotR: update_camera's closure (calls,    *)
(*    function values, and the functions and tables any referenced        *)
(*    global's initializer holds) without the two cutscene arrays and     *)
(*    the trigger table (WMotR's trigger entry is NULL,                    *)
(*    CamIdxCensus.trig_census) does NOT contain set_mario_npc_dialog,    *)
(*    and its only store through gSecondCameraFocus (an object) is        *)
(*    init_camera's, in the LEVEL_BOWSER_1 arm (dead).  With them it      *)
(*    contains both (non-vacuity).                                        *)
(* 4. THE CUTSCENE-SWITCH CARRY (c->cutscene == 0 -> sCutsceneShot == 0): *)
(*    - the 19 functions that store c->cutscene = 0 besides               *)
(*      init_camera / create_camera, and everything that can call or      *)
(*      name them (RZ, 22), lie in the shots' closure; only cutscene     *)
(*      arrays hold their addresses; update_camera and play_cutscene are  *)
(*      not among them, and update_camera's closure without the cutscene  *)
(*      and trigger tables reaches none of them.  So c->cutscene becomes  *)
(*      0 only inside play_cutscene's shot call (or in init_camera);      *)
(*    - every shot whose closure reaches one is its array's last shot of  *)
(*      duration 0, or every timer store in its closure is CUTSCENE_STOP  *)
(*      and every such zeroing function stores CUTSCENE_STOP on each path *)
(*      that zeroes (pend_ok, path-sensitive).  Either way play_cutscene's *)
(*      tail takes its else branch: sCutsceneShot = 0;                     *)
(*    - init_camera runs only from update_camera under                    *)
(*      CAM_MOVE_INIT_CAMERA, which only reset_camera sets (and it zeroes *)
(*      sCutsceneShot); play_cutscene runs only from update_camera, after *)
(*      that check;                                                       *)
(*    - a cutscene starts only through start_cutscene: in WMotR from      *)
(*      update_camera with get_cutscene_from_mario_status(c), which       *)
(*      returns c->cutscene unchanged when it is non-zero (gcfms_shape),  *)
(*      or from cam_castle_hmc_start_pool_cutscene, held only by the      *)
(*      castle / HMC trigger arrays.  So a switch is always from 0, with   *)
(*      sCutsceneShot = 0, and CamIdxCensus.cut_census bounds the index   *)
(*      within the cutscene.                                              *)
(* No FOUND for WMotR.                                                    *)
(* ====================================================================== *)

From Coq Require Import ZArith List Bool String Ascii.
From compcert Require Import Coqlib Maps AST Integers Ctypes Cop Clight Ctypesdefs Clightdefs.
From SM64.Generated Require camera mario mario_actions_cutscene.
From SM64.Proofs.WMotRRequiresA Require Import ObjTable RoCensus ActWriterCensus FnPtrCensus CamIdxCensus.
Import ListNotations.
Local Open Scope string_scope.

(* ---------------------------------------------------------------------- *)
(* Path guards.                                                            *)
(* ---------------------------------------------------------------------- *)

Fixpoint uncast (e : expr) : expr := match e with Ecast a _ => uncast a | _ => e end.
Definition is_t (p : ident) (e : expr) : bool :=
  match uncast e with Etempvar x _ => Pos.eqb x p | _ => false end.
Definition ceq (e : expr) (k : Z) : bool := match cval e with Some z => Z.eqb z k | None => false end.
Definition rm (x : ident) (l : list ident) : list ident := filter (fun y => negb (Pos.eqb x y)) l.
Definition inter (a b : list ident) : list ident := filter (fun x => memi x b) a.

Section Guard.
  Variable p : ident.
  Variable k : Z.

  Fixpoint gcond (W : list ident) (c : expr) : option bool :=
    match c with
    | Ebinop One a b _ => if (is_t p a && ceq b k) || (is_t p b && ceq a k) then Some true else None
    | Ebinop Oeq a b _ => if (is_t p a && ceq b k) || (is_t p b && ceq a k) then Some false else None
    | Etempvar x _ => if memi x W then Some true else None
    | Ecast a _ => gcond W a
    | _ => None
    end.

  Definition wit (W : list ident) (e : expr) : bool :=
    match gcond W e with Some true => true | _ => false end || ceq e 0.

  Fixpoint gw (s : statement) (g : bool) (W : list ident) : bool * bool * list ident :=
    match s with
    | Sset t e =>
        let ok := g || negb (is_t p e) in
        if Pos.eqb t p then (ok, match cval e with Some z => negb (Z.eqb z k) | None => false end, [])
        else (ok, g, if wit W e then t :: rm t W else rm t W)
    | Sassign _ e => (g || negb (is_t p e), g, W)
    | Scall o _ al | Sbuiltin o _ _ al =>
        let ok := g || negb (existsb (is_t p) al) in
        match o with
        | Some t => if Pos.eqb t p then (ok, false, []) else (ok, g, rm t W)
        | None => (ok, g, W)
        end
    | Sreturn (Some e) => (g || negb (is_t p e), g, W)
    | Ssequence a b =>
        let '(o1, g1, W1) := gw a g W in
        let '(o2, g2, W2) := gw b g1 W1 in (o1 && o2, g2, W2)
    | Sifthenelse c a b =>
        let '(ga, gb) := match gcond W c with
                         | Some true => (true, g) | Some false => (g, true) | None => (g, g) end in
        let '(o1, g1, W1) := gw a ga W in
        let '(o2, g2, W2) := gw b gb W in (o1 && o2, g1 && g2, inter W1 W2)
    | Sloop a b =>
        let '(o1, _, _) := gw a false [] in
        let '(o2, _, _) := gw b false [] in (o1 && o2, false, [])
    | Sswitch _ sl => (gw_ls sl, false, [])
    | Slabel _ a => let '(o, _, _) := gw a false [] in (o, false, [])
    | _ => (true, g, W)
    end
  with gw_ls (sl : labeled_statements) : bool :=
    match sl with
    | LSnil => true
    | LScons _ a sl' => (let '(o, _, _) := gw a false [] in o) && gw_ls sl'
    end.
End Guard.

Definition fits (t : type) (k : Z) : bool :=
  match t with
  | Tint I8 Signed _ => (-128 <=? k)%Z && (k <=? 127)%Z
  | Tint I8 Unsigned _ => (0 <=? k)%Z && (k <=? 255)%Z
  | Tint I16 Signed _ => (-32768 <=? k)%Z && (k <=? 32767)%Z
  | Tint I16 Unsigned _ => (0 <=? k)%Z && (k <=? 65535)%Z
  | Tint I32 Signed _ => (- 2147483648 <=? k)%Z && (k <=? 2147483647)%Z
  | _ => false
  end.

(* the constant k, passed to parameter p of g, never leaves g except under
   a test p != k *)
Definition guarded (g p : ident) (k : Z) : bool :=
  match fn_tab ! g with
  | Some (_, f) =>
      match find (fun '(x, _) => Pos.eqb x p) (fn_params f) with
      | Some (_, t) => fits t k && fst (fst (gw p k (fn_body f) false []))
      | None => false
      end
  | None => false
  end.
(* ---- call sites dead in WMotR: inside a case of a switch on gCurrLevelNum
   that no label LEVEL_WMOTR (31) or default reaches ---- *)
Definition WMOTR : Z := 31.

Definition reads_lvl (e : expr) : bool :=
  match uncast e with Evar x _ => Pos.eqb x mario._gCurrLevelNum | _ => false end.

Definition lvl_temps (f : function) : list ident :=
  map fst (filter (fun '(t, _) => match ssets t (fn_body f) with
                                  | nil => false
                                  | l => forallb reads_lvl l end) (fn_temps f)).

Definition is_lvl (lt : list ident) (e : expr) : bool :=
  reads_lvl e || match uncast e with Etempvar t _ => memi t lt | _ => false end.

Fixpoint ends_break (s : statement) : bool :=
  match s with Sbreak | Sreturn _ => true | Ssequence _ b => ends_break b | _ => false end.

Definition lbl_alive (l : option Z) : bool :=
  match l with None => true | Some z => Z.eqb z WMOTR end.

Fixpoint calls_ctx (lt : list ident) (g : ident) (s : statement) (dead : bool) : list (list expr * bool) :=
  match s with
  | Scall _ (Evar h _) args => if Pos.eqb g h then [(args, dead)] else nil
  | Ssequence s1 s2 | Sifthenelse _ s1 s2 | Sloop s1 s2 => calls_ctx lt g s1 dead ++ calls_ctx lt g s2 dead
  | Slabel _ s1 => calls_ctx lt g s1 dead
  | Sswitch e sl => calls_sw lt g sl dead (is_lvl lt e) false
  | _ => nil
  end
with calls_sw (lt : list ident) (g : ident) (sl : labeled_statements) (dead lvl fall : bool)
    : list (list expr * bool) :=
  match sl with
  | LSnil => nil
  | LScons l s sl' =>
      let reach := fall || lbl_alive l in
      calls_ctx lt g s (dead || (lvl && negb reach))
        ++ calls_sw lt g sl' dead lvl (reach && negb (ends_break s))
  end.

Definition callers_ctx (g : ident) : list (ident * list expr * bool) :=
  flat_map (fun '(_, h, f) => map (fun '(al, d) => (h, al, d)) (calls_ctx (lvl_temps f) g (fn_body f) false))
    all_fns.

(* direct callees whose result is assigned to t *)
Fixpoint scalls (t : ident) (s : statement) : list ident :=
  match s with
  | Scall (Some t') (Evar f _) _ => if Pos.eqb t t' then [f] else []
  | Ssequence s1 s2 | Sloop s1 s2 | Sifthenelse _ s1 s2 => scalls t s1 ++ scalls t s2
  | Slabel _ s1 => scalls t s1
  | Sswitch _ sl => scalls_ls t sl
  | _ => []
  end
with scalls_ls (t : ident) (sl : labeled_statements) : list ident :=
  match sl with LSnil => [] | LScons _ s sl' => scalls t s ++ scalls_ls t sl' end.

Fixpoint rets (s : statement) : list expr :=
  match s with
  | Sreturn (Some e) => [e]
  | Ssequence s1 s2 | Sloop s1 s2 | Sifthenelse _ s1 s2 => rets s1 ++ rets s2
  | Slabel _ s1 => rets s1
  | Sswitch _ sl => rets_ls sl
  | _ => []
  end
with rets_ls (sl : labeled_statements) : list expr :=
  match sl with LSnil => [] | LScons _ s sl' => rets s ++ rets_ls sl' end.

Definition is_callres (e : expr) : bool :=
  match e with Evar x _ => Pos.eqb x CALLRES | _ => false end.

Section GFlow.
  Variable is_cell : expr -> bool.
  Variable okc : Z -> bool.

  Fixpoint gleaves (fuel : nat) (g : ident) (e : expr) : list (string * string) :=
    match fuel with O => [(string_of_ident g, "FUEL")] | S n =>
    match cval e with
    | Some k => if okc k then [] else [(string_of_ident g, "const " ++ zs k)]
    | None =>
    match e with
    | Ecast a _ => gleaves n g a
    | Etempvar t _ =>
        match fn_tab ! g with
        | Some (_, f) =>
            match index_of t (fn_params f) 0 with
            | Some i =>
                flat_map (fun (x : ident * list expr * bool) => let (hal, dead) := x in let (h, al) := hal in
                  if dead then [] else
                  match nth_error al i with
                  | Some a =>
                      match cval a with
                      | Some z => if negb (okc z) && guarded g t z then [] else gleaves n h a
                      | None => gleaves n h a
                      end
                  | None => [(string_of_ident h, "noarg")]
                  end) (callers_ctx g)
            | None =>
                let srcs := ssets t (fn_body f) in
                let cs := scalls t (fn_body f) in
                (if Nat.ltb (List.length cs) (List.length (filter is_callres srcs))
                 then [(string_of_ident g, "indirect call result")] else [])
                ++ flat_map (fun r => if is_callres r then [] else gleaves n g r) srcs
                ++ flat_map (fun h => match fn_tab ! h with
                     | Some (_, fh) => flat_map (gleaves n h) (rets (fn_body fh))
                     | None => [(string_of_ident g, "extern result " ++ string_of_ident h)]
                     end) cs
            end
        | None => [(string_of_ident g, "no body")]
        end
    | _ => if is_wcell is_cell g e then [] else [(string_of_ident g, pex e)]
    end end end.

  Definition greport : list (string * string) :=
    flat_map (fun '(g, r) => gleaves 12 g r) (all_roots is_cell).
End GFlow.

(* ---------------------------------------------------------------------- *)
(* 1. The camera mode, with the path guards.                               *)
(* ---------------------------------------------------------------------- *)

Lemma mode_guards :
  guarded camera._set_camera_mode camera._mode (-1) = true
  /\ guarded camera._set_mode_if_not_set_by_surface camera._mode 0 = true
  /\ guarded camera._transition_to_camera_mode camera._newMode (-1) = true
  (* control: an unguarded constant is not dropped *)
  /\ guarded camera._set_camera_mode camera._mode 3 = false.
Proof. vm_compute. auto. Qed.

(* only the GEO_CAMERA node's mode is left (TRUST 3.2: the witness's 16) *)
Lemma mode_census_guarded :
  greport mode_cell mode_ok =
    [("create_camera", "*($gc).config.mode"); ("create_camera", "*($gc).config.mode")].
Proof. vm_compute. reflexivity. Qed.

(* ---------------------------------------------------------------------- *)
(* 2. The cutscene values.                                                 *)
(* ---------------------------------------------------------------------- *)

Definition cutc (l : expr) : bool :=
  match l with
  | Efield b f _ => Pos.eqb f camera._cutscene && memi (sty (typeof b)) [camera._Camera]
  | Evar x _ => Pos.eqb x camera._sObjectCutscene
  | _ => false end.

Definition PYRAMID_EXPLODE : Z := 168.
Definition BOWSER_ARENA : Z := 144.
Definition not_two (z : Z) : bool := negb (Z.eqb z BOWSER_ARENA || Z.eqb z PYRAMID_EXPLODE).

(* without the level guard, init_camera's Bowser arms are what stores 144 *)
Lemma cut_raw :
  report cutc not_two =
    [("update_camera", "call result"); ("init_camera", "const 144");
     ("init_camera", "const 144"); ("init_camera", "const 144")].
Proof. vm_compute. reflexivity. Qed.

(* with it (and call results followed): only the dance-table read *)
Lemma cut_census_wmotr :
  greport cutc not_two =
    [("determine_dance_cutscene", "*((sDanceCutsceneTable op $cutsceneIndex))");
     ("determine_dance_cutscene", "*((sDanceCutsceneTable op $cutsceneIndex))")].
Proof. vm_compute. reflexivity. Qed.

Definition gtab : PTree.t (list init_data) :=
  fold_left (fun t p => fold_left (fun t '(id, g) =>
      match g with
      | Gvar v => match gvar_init v with nil => t | l => PTree.set id l t end
      | _ => t end) (prog_defs p) t) lprogs (PTree.empty _).

Definition ginit_all (x : ident) : list init_data := match gtab ! x with Some l => l | None => [] end.

Definition addrs (l : list init_data) : list ident :=
  flat_map (fun d => match d with Init_addrof g _ => [g] | _ => [] end) l.

Definition bytes (l : list init_data) : list Z :=
  flat_map (fun d => match d with
    | Init_int8 n => [Int.unsigned n] | Init_space k => repeat 0 (Z.to_nat k) | _ => [-1] end) l.

(* the index is a nibble < 5 of the 27 x 4 index table (courseNum <= 25 or
   0, starIndex <= 3: in bounds), picking one of the five dance cutscenes *)
Lemma dance_tables :
  firstn 5 (bytes (ginit_all camera._sDanceCutsceneTable)) = [165; 143; 166; 167; 175]
  /\ List.length (bytes (ginit_all camera._sDanceCutsceneIndexTable)) = 108%nat
  /\ forallb (fun b => Z.ltb (Z.land b 15) 5 && Z.ltb (Z.shiftr b 4) 5)
       (bytes (ginit_all camera._sDanceCutsceneIndexTable)) = true.
Proof. vm_compute. auto. Qed.

(* the cutscene values with no case in play_cutscene's switch *)
Definition sw_labels : list Z :=
  match fn_tab ! camera._play_cutscene with
  | Some (_, f) =>
     let fix lbls (s : statement) : list Z :=
       match s with
       | Sswitch _ sl => let fix ls (sl : labeled_statements) : list Z :=
            match sl with LSnil => [] | LScons (Some z) _ sl' => z :: ls sl' | LScons None _ sl' => ls sl' end in ls sl
       | Ssequence a b => List.app (lbls a) (lbls b)
       | _ => [] end in lbls (fn_body f)
  | None => [] end.

Definition has_case (z : Z) : bool := Z.eqb z 0 || existsb (Z.eqb z) sw_labels.

Lemma no_case_values :
  List.length sw_labels = 45%nat
  /\ greport cutc has_case =
     [("get_cutscene_from_mario_status", "const 159");
      ("determine_dance_cutscene", "*((sDanceCutsceneTable op $cutsceneIndex))");
      ("determine_dance_cutscene", "*((sDanceCutsceneTable op $cutsceneIndex))")].
Proof. split; vm_compute; reflexivity. Qed.

(* the tables are only READ: named only by their reader, never stored, their
   address neither stored, passed nor returned, and held by no initializer
   (sCameraTriggers holds the trigger arrays) *)
Fixpoint load_top (e : expr) : bool :=
  match e with Ecast a _ => load_top a | Ederef _ _ | Efield _ _ _ => true | _ => false end.

Fixpoint esc (x : ident) (s : statement) : bool :=
  match s with
  | Sassign l r => memi x (evars l) || (memi x (evars r) && negb (load_top r))
  | Sset _ r => memi x (evars r) && negb (load_top r)
  | Scall _ fe al => memi x (evars fe) || existsb (fun a => memi x (evars a)) al
  | Sbuiltin _ _ _ al => existsb (fun a => memi x (evars a)) al
  | Sreturn (Some e) => memi x (evars e)
  | Ssequence a b | Sloop a b | Sifthenelse _ a b => esc x a || esc x b
  | Slabel _ a => esc x a
  | Sswitch _ sl => esc_ls x sl
  | _ => false end
with esc_ls (x : ident) (sl : labeled_statements) : bool :=
  match sl with LSnil => false | LScons _ a sl' => esc x a || esc_ls x sl' end.

Definition occ (x : ident) : list ident :=
  map (fun '(_, h, _) => h) (filter (fun '(_, h, f) => memi x (sev (fn_body f))) all_fns).
Definition escs (x : ident) : list ident :=
  map (fun '(_, h, _) => h) (filter (fun '(_, h, f) => esc x (fn_body f)) all_fns).
Definition holders (l : list ident) : list ident :=
  PTree.fold (fun acc id d => if existsb (fun x => memi x l) (addrs d) then id :: acc else acc) gtab [].

Definition read_only_by (x r : ident) : bool :=
  match occ x with [y] => Pos.eqb y r | _ => false end
  && match escs x with nil => true | _ => false end
  && match holders [x] with nil => true | _ => false end.

Lemma tables_read_only :
  read_only_by camera._sCameraTriggers camera._camera_course_processing = true
  /\ read_only_by camera._sDanceCutsceneTable camera._determine_dance_cutscene = true
  /\ read_only_by camera._sDanceCutsceneIndexTable camera._determine_dance_cutscene = true
  /\ read_only_by camera._sModeTransitions camera._set_camera_mode = true
  /\ forallb (fun x => read_only_by x camera._play_cutscene) cut_arrays = true.
Proof. vm_compute. auto. Qed.

(* ---------------------------------------------------------------------- *)
(* 3. What update_camera reaches in WMotR.                                 *)
(* ---------------------------------------------------------------------- *)

(* calls, function values, and (through any global a body names) the
   functions and globals its initializer holds; ex is cut off *)
Definition tsucc (ex : list ident) (x : ident) : list ident :=
  if memi x ex then [] else
  match fn_tab ! x with
  | Some (_, f) => let '(c, _, v) := cg (fn_body f) in List.app c (List.app v (sev (fn_body f)))
  | None => addrs (ginit_all x)
  end.

Fixpoint tclose (ex : list ident) (fuel : nat) (work seen : list ident) : list ident :=
  match fuel with O => seen | S n =>
    match work with
    | nil => seen
    | x :: w => if memi x seen then tclose ex n w seen else tclose ex n (List.app (tsucc ex x) w) (x :: seen)
    end end.

Definition fns_of (l : list ident) : list ident :=
  filter (fun x => match fn_tab ! x with Some _ => true | None => false end) l.

Definition uc_cl (ex : list ident) : list ident :=
  fns_of (tclose ex 200000 [camera._update_camera] []).

(* WMotR cuts off: the two cutscenes no WMotR code starts (section 2) and
   the trigger table, whose WMotR entry is NULL *)
Definition EX : list ident :=
  [camera._sCutsceneEnterBowserArena; camera._sCutscenePyramidTopExplode; camera._sCameraTriggers].

Fixpoint etemps (a : expr) : list ident :=
  match a with
  | Etempvar x _ => [x]
  | Ederef a1 _ | Efield a1 _ _ | Eaddrof a1 _ | Eunop _ a1 _ | Ecast a1 _ => etemps a1
  | Ebinop _ a1 a2 _ => List.app (etemps a1) (etemps a2)
  | _ => nil
  end.

Definition sf_temp (body : statement) (t : ident) : bool :=
  existsb (fun e => memi camera._gSecondCameraFocus (evars e)) (ssets t body).

(* stores THROUGH gSecondCameraFocus (into its object), each with its
   WMotR-dead flag *)
Fixpoint sf_thru (lt : list ident) (body : statement) (s : statement) (dead : bool) : list bool :=
  match s with
  | Sassign l _ =>
      if existsb (sf_temp body) (etemps l)
         || match l with Evar _ _ => false | _ => memi camera._gSecondCameraFocus (evars l) end
      then [dead] else []
  | Ssequence s1 s2 | Sloop s1 s2 | Sifthenelse _ s1 s2 =>
      List.app (sf_thru lt body s1 dead) (sf_thru lt body s2 dead)
  | Slabel _ s1 => sf_thru lt body s1 dead
  | Sswitch e sl => sf_sw lt body sl dead (is_lvl lt e) false
  | _ => []
  end
with sf_sw (lt : list ident) (body : statement) (sl : labeled_statements) (dead lvl fall : bool) : list bool :=
  match sl with
  | LSnil => []
  | LScons l s sl' =>
      let reach := fall || lbl_alive l in
      List.app (sf_thru lt body s (dead || (lvl && negb reach)))
               (sf_sw lt body sl' dead lvl (reach && negb (ends_break s)))
  end.

Definition sf_rows (l : list ident) : list (string * list bool) :=
  flat_map (fun x => match fn_tab ! x with
    | Some (_, f) => match sf_thru (lvl_temps f) (fn_body f) (fn_body f) false with
                     | nil => [] | r => [(string_of_ident x, r)] end
    | None => [] end) l.

Lemma uc_wmotr :
  List.length (uc_cl EX) = 428%nat
  /\ memi mario_actions_cutscene._set_mario_npc_dialog (uc_cl EX) = false
  /\ sf_rows (uc_cl EX) = [("init_camera", [true])]
  (* non-vacuity: the cut-off is what removes them *)
  /\ List.length (uc_cl []) = 530%nat
  /\ memi mario_actions_cutscene._set_mario_npc_dialog (uc_cl []) = true
  /\ sf_rows (uc_cl []) =
       [("cutscene_bowser_arena_end", [false]); ("cutscene_bowser_area_start_bowser_walking", [false]);
        ("init_camera", [true])].
Proof. vm_compute. auto 7. Qed.

(* ---------------------------------------------------------------------- *)
(* 4. The cutscene-switch carry.                                           *)
(* ---------------------------------------------------------------------- *)

Definition cut0 (l : expr) : bool :=
  match l with Efield b f _ => Pos.eqb f camera._cutscene && memi (sty (typeof b)) [camera._Camera] | _ => false end.

(* the functions storing c->cutscene = 0, but init_camera / create_camera *)
Definition zeroers : list ident :=
  map (fun '(_, h, _) => h)
    (filter (fun '(_, h, f) =>
       negb (memi h [camera._init_camera; camera._create_camera])
       && existsb (fun '(_, r) => ceq r 0) (roots cut0 h (fn_body f))) all_fns).

Lemma zeroers_value :
  map string_of_ident zeroers =
    ["stop_cutscene_and_retrieve_stored_info"; "cutscene_ending_stop"; "cutscene_dance_default_rotate";
     "cutscene_bowser_arena_end"; "cutscene_star_spawn_end"; "cutscene_exit_to_castle_grounds_end";
     "cutscene_red_coin_star_end"; "cutscene_prepare_cannon_end"; "cutscene_dialog_end";
     "cutscene_read_message_end"; "cutscene_non_painting_end"; "cutscene_intro_peach_dialog";
     "cutscene_double_doors_end"; "cutscene_enter_painting"; "cutscene_exit_painting_end";
     "cutscene_enter_cannon_end"; "cutscene_door_loop"; "cutscene_door_end"; "cutscene_door_mode"].
Proof. vm_compute. reflexivity. Qed.

Definition refs (x : ident) : list ident :=
  map (fun '(_, h, _) => h)
    (filter (fun '(_, h, f) => let '(c, _, v) := cg (fn_body f) in memi x (List.app c v)) all_fns).

Fixpoint rclose (fuel : nat) (work seen : list ident) : list ident :=
  match fuel with O => seen | S n =>
    match work with
    | nil => seen
    | x :: w => if memi x seen then rclose n w seen else rclose n (List.app (refs x) w) (x :: seen)
    end end.

(* everything that can call or name a zeroing function *)
Definition RZ : list ident := rclose 10000 zeroers [].
Definition shot_cl : list ident := sclose 100000 (flat_map shots cut_arrays) [].
Definition EXALL : list ident := camera._sCameraTriggers :: cut_arrays.

Lemma zero_only_in_shots :
  List.length RZ = 22%nat
  /\ forallb (fun x => memi x shot_cl) RZ = true
  /\ memi camera._update_camera RZ = false
  /\ memi camera._play_cutscene RZ = false
  /\ forallb (fun h => memi h cut_arrays) (holders RZ) = true
  /\ existsb (fun z => memi z (uc_cl EXALL)) zeroers = false.
Proof. vm_compute. auto 7. Qed.

(* path states (zeroed?, CUTSCENE_STOP stored?) *)
Definition pst := list (bool * bool).
Definition pmem (x : bool * bool) (l : pst) : bool :=
  existsb (fun '(a, b) => Bool.eqb a (fst x) && Bool.eqb b (snd x)) l.
Definition punion (l1 l2 : pst) : pst := List.app l1 (filter (fun x => negb (pmem x l1)) l2).
Definition bad (l : pst) : bool := existsb (fun '(z, s) => z && negb s) l.

(* (no bad state at a return, the states at the fallthrough exit) *)
Fixpoint zst (s : statement) (P : pst) : bool * pst :=
  match s with
  | Sassign l r =>
      if cut0 l && ceq r 0 then (true, map (fun '(_, b) => (true, b)) P)
      else if timer_cell l && ceq r 32768 then (true, map (fun '(a, _) => (a, true)) P) else (true, P)
  | Sreturn _ => (negb (bad P), [])
  | Ssequence a b => let '(o1, P1) := zst a P in let '(o2, P2) := zst b P1 in (o1 && o2, P2)
  | Sifthenelse _ a b => let '(o1, P1) := zst a P in let '(o2, P2) := zst b P in (o1 && o2, punion P1 P2)
  | Sloop a b =>
      let '(o1, P1) := zst a P in let '(o2, P2) := zst b (punion P P1) in
      let Q := punion P (punion P1 P2) in
      let '(o3, P3) := zst a Q in let '(o4, P4) := zst b (punion Q P3) in
      (o1 && o2 && o3 && o4, punion Q (punion P3 P4))
  | Slabel _ a => zst a [(false, false); (false, true); (true, false); (true, true)]
  | Sswitch _ sl => zst_ls sl P []
  | _ => (true, P)
  end
with zst_ls (sl : labeled_statements) (P0 acc : pst) : bool * pst :=
  match sl with
  | LSnil => (true, punion P0 acc)
  | LScons _ a sl' => let '(o, Q) := zst a (punion P0 acc) in
                      let '(o', Q') := zst_ls sl' P0 Q in (o && o', punion Q Q')
  end.

(* every path that zeroes c->cutscene also stores CUTSCENE_STOP *)
Definition pend_ok (g : ident) : bool :=
  match fn_tab ! g with
  | Some (_, f) => let '(o, Q) := zst (fn_body f) [(false, false)] in o && negb (bad Q)
  | None => false end.

Lemma stop_paired :
  map string_of_ident (filter (fun z => negb (pend_ok z)) zeroers) =
    ["cutscene_bowser_arena_end"; "cutscene_dialog_end"; "cutscene_read_message_end";
     "cutscene_non_painting_end"; "cutscene_double_doors_end"; "cutscene_enter_cannon_end"].
Proof. vm_compute. reflexivity. Qed.

(* (array, position, shot, last?, duration) *)
Definition shot_rows : list (ident * nat * ident * bool * Z) :=
  flat_map (fun x => let sh := shots x in let ds := durations x in
     map (fun i => (x, i, nth i sh 1%positive, Nat.eqb (S i) (List.length sh), nth i ds (-1)))
         (seq 0 (List.length sh))) cut_arrays.

Definition shot_ok (r : ident * nat * ident * bool * Z) : bool :=
  let '(x, i, s, last, d) := r in
  let cl := sclose 5000 [s] [] in
  negb (existsb (fun z => memi z cl) zeroers)
  || (last && Z.eqb d 0)
  || (forallb (fun z => negb (memi z cl) || pend_ok z) zeroers
      && forallb (fun g => match fn_tab ! g with
           | Some (_, f) => forallb (fun '(_, r) => ceq r 32768) (roots timer_cell g (fn_body f))
           | None => true end) cl).

Lemma shots_reset :
  List.length shot_rows = 101%nat /\ forallb shot_ok shot_rows = true.
Proof. split; vm_compute; reflexivity. Qed.

(* get_cutscene_from_mario_status: cutscene = c->cutscene; if (cutscene == 0)
   {..}; .. return cutscene -- with no other assignment, and no return,
   outside the then-branch *)
Definition gcfms_shape : bool :=
  match fn_tab ! camera._get_cutscene_from_mario_status with
  | Some (_, f) =>
    match fn_body f with
    | Ssequence (Ssequence (Sset t1 (Efield (Ederef (Etempvar c _) _) fld _)) (Sset cs (Ecast (Etempvar t1' _) _)))
        (Ssequence (Sifthenelse (Ebinop Oeq (Etempvar cs' _) z _) A B) R) =>
        Pos.eqb c camera._c && Pos.eqb fld camera._cutscene && Pos.eqb t1 t1' && Pos.eqb cs camera._cutscene
        && Pos.eqb cs' cs && ceq z 0 && (match List.app (ssets cs B) (ssets cs R) with nil => true | _ => false end)
        && (match List.app (rets A) (rets B) with nil => true | _ => false end)
        && (match rets R with [Etempvar x _] => Pos.eqb x cs | _ => false end)
    | _ => false
    end
  | None => false
  end.

Definition live_starts : list (string * list string) :=
  flat_map (fun (x : ident * list expr * bool) => let (hal, d) := x in let (h, al) := hal in
    if d then [] else [(string_of_ident h, map pex al)])
    (callers_ctx camera._start_cutscene).

(* update_camera's argument temp: set once, by the call's result *)
Definition update_camera_start_arg : list ident :=
  match fn_tab ! camera._update_camera with
  | Some (_, f) =>
      flat_map (fun al => match al with
        | [_; a] => match uncast a with
                    | Etempvar t _ =>
                        if Nat.eqb (List.length (ssets t (fn_body f))) 1 then scalls t (fn_body f) else [1%positive]
                    | _ => [1%positive] end
        | _ => [1%positive] end) (calls_to camera._start_cutscene (fn_body f))
  | None => [] end.

Lemma starts_from_zero :
  gcfms_shape = true
  /\ live_starts = [("update_camera", ["$c"; "$4"]); ("cam_castle_hmc_start_pool_cutscene", ["$c"; "181"])]
  /\ map string_of_ident update_camera_start_arg = ["get_cutscene_from_mario_status"]
  /\ refs camera._cam_castle_hmc_start_pool_cutscene = []
  /\ map string_of_ident (holders [camera._cam_castle_hmc_start_pool_cutscene]) = ["sCamHMC"; "sCamCastle"].
Proof. vm_compute. auto 6. Qed.

(* CAM_MOVE_INIT_CAMERA (0x800) *)
Fixpoint ceval (e : expr) : option Z :=
  match e with
  | Econst_int n _ => Some (Int.signed n)
  | Ecast a _ => ceval a
  | Eunop Oneg a _ => option_map Z.opp (ceval a)
  | Eunop Onotint a _ => option_map Z.lnot (ceval a)
  | Ebinop Oor a b _ => match ceval a, ceval b with Some x, Some y => Some (Z.lor x y) | _, _ => None end
  | Ebinop Oand a b _ => match ceval a, ceval b with Some x, Some y => Some (Z.land x y) | _, _ => None end
  | Ebinop Oshl a b _ => match ceval a, ceval b with Some x, Some y => Some (Z.shiftl x y) | _, _ => None end
  | _ => None
  end.

Definition INITCAM : Z := 2048.
Definition cmf_cell (l : expr) : bool :=
  match l with Evar x _ => Pos.eqb x camera._gCameraMovementFlags | _ => false end.
Definition flag_reads (body : statement) (t : ident) : bool :=
  match ssets t body with nil => false | l => forallb cmf_cell l end.

(* a store that cannot set the bit: an AND, an OR of the flags' own value
   with a constant without it, or such a constant *)
Definition no_init_bit (body : statement) (r : expr) : bool :=
  match uncast r with
  | Ebinop Oand _ _ _ => true
  | Ebinop Oor a k _ =>
      (match uncast a with Etempvar t _ => flag_reads body t | _ => false end)
      && match ceval k with Some z => Z.eqb (Z.land z INITCAM) 0 | None => false end
  | e => match ceval e with Some z => Z.eqb (Z.land z INITCAM) 0 | None => false end
  end.

Definition init_bit_setters : list string :=
  flat_map (fun '(_, h, f) =>
    if existsb (fun '(_, r) => negb (no_init_bit (fn_body f) r)) (roots cmf_cell h (fn_body f))
    then [string_of_ident h] else []) all_fns.

Definition shot_zeroers : list string :=
  flat_map (fun '(_, h, f) => if existsb (fun '(_, r) => ceq r 0) (roots shot_cell h (fn_body f))
                              then [string_of_ident h] else []) all_fns.

Lemma init_after_reset :
  init_bit_setters = ["reset_camera"]
  /\ shot_zeroers = ["reset_camera"; "play_cutscene"]
  /\ map string_of_ident (refs camera._init_camera) = ["update_camera"]
  /\ map string_of_ident (refs camera._play_cutscene) = ["update_camera"]
  /\ holders [camera._init_camera; camera._play_cutscene; camera._update_camera] = [].
Proof. vm_compute. auto 6. Qed.
