(* spine-root: the camera's indirect-call TABLE INDICES (TRUST 3.2 UB
   worklist): sModeTransitions[mode], the cutscene shot arrays, the
   camera-trigger arrays -- a census of every store into the index cells,
   machine-checked on the generated link.  Camera family (may stay open);
   this closes what the code alone decides and names the rest. *)
(* ====================================================================== *)
(* CAN THE CAMERA'S INDIRECT CALLS READ A TABLE OUT OF BOUNDS?             *)
(*                                                                        *)
(* A VALUE-SOURCE census (leaves): from every store into an index cell,   *)
(* anywhere in the link, follow the stored value back through temps,      *)
(* parameters (every caller's argument) and pointer parameters every      *)
(* caller passes as &cell, until it is a constant, a read of an index     *)
(* cell, or a LEAF it cannot resolve.  The leaves are pinned.             *)
(*                                                                        *)
(* 1. sModeTransitions[sModeInfo.newMode] (set_camera_mode): 18 entries,  *)
(*    0 is NULL, 1..17 functions (mode_table).  Cells: Camera.mode /      *)
(*    defMode, LakituState.mode / defMode, ModeTransitionInfo.newMode /   *)
(*    lastMode.  Every stored value is a constant in 1..17 or a cell,     *)
(*    except four leaves (mode_census):                                    *)
(*    - set_camera_mode(.., -1, ..) from update_mario_sound_and_camera    *)
(*      and act_first_person: set_camera_mode stores newMode only when    *)
(*      mode != -1 (else lastMode, a cell) -- path-guarded;               *)
(*    - set_mode_if_not_set_by_surface(c, CAMERA_MODE_NONE) from          *)
(*      camera_course_processing (AREA_BOB): it calls                     *)
(*      transition_to_camera_mode only when mode != 0 -- path-guarded;     *)
(*    - create_camera's gc->config.mode: the level's GEO_CAMERA node, i.e. *)
(*      geo layout DATA outside the link.  WMotR's is 16                  *)
(*      (levels/wmotr/areas/1/geo.inc.c: GEO_CAMERA(16, ...)), in range.  *)
(*    So the index is in 1..17 given the two guards and WMotR's geo mode. *)
(* 2. sCameraTriggers[level][b] (camera_course_processing): 40 entries;   *)
(*    LEVEL_WMOTR's (31) is NULL, so WMotR runs no trigger; every non-    *)
(*    NULL array is terminated by exactly one NULL event, its last        *)
(*    element (trig_census).  NOTE (decomp, not WMotR): the clamp         *)
(*    `level > LEVEL_COUNT + 1 -> LEVEL_COUNT + 1` allows index 40 of a   *)
(*    40-entry array; unreachable while gCurrLevelNum = LEVEL_WMOTR.      *)
(* 3. cutscene[sCutsceneShot] (play_cutscene, 43 arrays): sCutsceneShot   *)
(*    is stored only as 0 and by play_cutscene's ++, which fires when     *)
(*    gCutsceneTimer == the shot's nonzero duration (shot_census).  The    *)
(*    counter stops at 0x3FFF, so a CUTSCENE_LOOP (0x7FFF) shot advances *)
(*    only when a function sets the timer to CUTSCENE_LOOP; those 8       *)
(*    setters (loop_setters) occur only in the closure of shots that are *)
(*    NOT their array's last, and every last shot's duration is 0 or      *)
(*    CUTSCENE_LOOP (cut_census).  So within one cutscene the index stays *)
(*    below the length.  NOT closed here (named residual): a cutscene     *)
(*    switch with a stale shot index.  The census of c->cutscene stores   *)
(*    (cut_end_census) shows every `c->cutscene = 0` is paired with       *)
(*    gCutsceneTimer = CUTSCENE_STOP (play_cutscene then resets the shot) *)
(*    or sits in a last shot of duration 0 (same reset), and start_cutscene*)
(*    is reached mid-cutscene only as a no-op (get_cutscene_from_mario_   *)
(*    status returns the running cutscene); carrying  c->cutscene = 0 ->   *)
(*    sCutsceneShot = 0  is the remaining semantic step.                  *)
(* No store found that can exceed its bound.                               *)
(* ====================================================================== *)

From Coq Require Import ZArith List Bool String Ascii.
From compcert Require Import Coqlib Maps AST Integers Ctypes Cop Clight Ctypesdefs Clightdefs.
From SM64.Generated Require camera.
From SM64.Proofs.WMotRRequiresA Require Import ObjTable RoCensus ActWriterCensus FnPtrCensus.
Import ListNotations.

Local Open Scope string_scope.

Fixpoint ns (fuel : nat) (n : Z) : string :=
  match fuel with O => "" | S f =>
    let d := String (Ascii.ascii_of_nat (48 + Z.to_nat (n mod 10))) EmptyString in
    if Z.ltb n 10 then d else ns f (n / 10) ++ d end.
Definition zs (n : Z) : string := if Z.ltb n 0 then "-" ++ ns 12 (- n) else ns 12 n.

Fixpoint pex (a : expr) : string :=
  match a with
  | Evar x _ => string_of_ident x
  | Etempvar x _ => "$" ++ string_of_ident x
  | Ederef a _ => "*(" ++ pex a ++ ")"
  | Efield a f _ => pex a ++ "." ++ string_of_ident f
  | Eaddrof a _ => "&" ++ pex a
  | Ecast a t => "(" ++ pty t ++ ")" ++ pex a
  | Ebinop _ a b _ => "(" ++ pex a ++ " op " ++ pex b ++ ")"
  | Eunop _ a _ => "u(" ++ pex a ++ ")"
  | Econst_int n _ => zs (Int.signed n)
  | _ => "?"
  end.

Fixpoint cval (i : expr) : option Z :=
  match i with
  | Econst_int n _ => Some (Int.signed n)
  | Eunop Oneg a _ => match cval a with Some x => Some (- x)%Z | None => None end
  | Ecast a _ => cval a
  | _ => None
  end.

(* ---------------------------------------------------------------------- *)
(* The value-source census.                                                *)
(* ---------------------------------------------------------------------- *)

Section Flow.
  Variable is_cell : expr -> bool.
  Variable okc : Z -> bool.

  Definition CALLRES : ident := 1%positive.

  Fixpoint ssets (t : ident) (s : statement) : list expr :=
    match s with
    | Sset t' r => if Pos.eqb t t' then [r] else []
    | Scall (Some t') _ _ => if Pos.eqb t t' then [Evar CALLRES Tvoid] else []
    | Sbuiltin (Some t') _ _ _ => if Pos.eqb t t' then [Evar CALLRES Tvoid] else []
    | Ssequence s1 s2 | Sloop s1 s2 | Sifthenelse _ s1 s2 => ssets t s1 ++ ssets t s2
    | Slabel _ s1 => ssets t s1
    | Sswitch _ sl => ssets_ls t sl
    | _ => []
    end
  with ssets_ls (t : ident) (sl : labeled_statements) : list expr :=
    match sl with LSnil => [] | LScons _ s sl' => ssets t s ++ ssets_ls t sl' end.

  Definition callers (g : ident) : list (ident * list expr) :=
    flat_map (fun '(_, h, f) => map (fun al => (h, al)) (calls_to g (fn_body f))) all_fns.

  Fixpoint index_of (x : ident) (l : list (ident * type)) (i : nat) : option nat :=
    match l with nil => None | (y, _) :: l' => if Pos.eqb x y then Some i else index_of x l' (S i) end.

  (* a pointer parameter every caller passes as &cell (or its own such) *)
  Fixpoint cptr (fuel : nat) (g : ident) (p : ident) : bool :=
    match fuel with O => false | S n =>
    match fn_tab ! g with
    | Some (_, f) => match index_of p (fn_params f) 0 with
        | Some i => let cs := callers g in
            negb (Nat.eqb (List.length cs) 0) &&
            forallb (fun '(h, al) => match nth_error al i with
              | Some (Eaddrof l _) => is_cell l
              | Some (Etempvar q _) => cptr n h q
              | Some (Ecast (Eaddrof l _) _) => is_cell l
              | _ => false end) cs
        | None => false end
    | None => false end end.

  Definition is_wcell (g : ident) (l : expr) : bool :=
    is_cell l || match l with Ederef (Etempvar p _) _ => cptr 6 g p | _ => false end.

  (* the unresolved sources of a stored value: (function, description) *)
  Fixpoint leaves (fuel : nat) (g : ident) (e : expr) : list (string * string) :=
    match fuel with O => [(string_of_ident g, "FUEL")] | S n =>
    match cval e with
    | Some k => if okc k then [] else [(string_of_ident g, "const " ++ zs k)]
    | None =>
    match e with
    | Ecast a _ => leaves n g a
    | Etempvar t _ =>
        match fn_tab ! g with
        | Some (_, f) =>
            match index_of t (fn_params f) 0 with
            | Some i => flat_map (fun '(h, al) => match nth_error al i with
                          | Some a => leaves n h a | None => [(string_of_ident h, "noarg")] end) (callers g)
            | None => flat_map (fun r => match r with
                          | Evar x _ => if Pos.eqb x CALLRES then [(string_of_ident g, "call result")]
                                        else leaves n g r
                          | _ => leaves n g r end) (ssets t (fn_body f))
            end
        | None => [(string_of_ident g, "no body")]
        end
    | _ => if is_wcell g e then [] else [(string_of_ident g, pex e)]
    end end end.

  Fixpoint roots (g : ident) (s : statement) : list (ident * expr) :=
    match s with
    | Sassign l r => if is_wcell g l then [(g, r)] else []
    | Ssequence s1 s2 | Sloop s1 s2 | Sifthenelse _ s1 s2 => roots g s1 ++ roots g s2
    | Slabel _ s1 => roots g s1
    | Sswitch _ sl => roots_ls g sl
    | _ => []
    end
  with roots_ls (g : ident) (sl : labeled_statements) : list (ident * expr) :=
    match sl with LSnil => [] | LScons _ s sl' => roots g s ++ roots_ls g sl' end.

  Definition all_roots : list (ident * expr) := flat_map (fun '(_, h, f) => roots h (fn_body f)) all_fns.
  Definition report : list (string * string) := flat_map (fun '(g, r) => leaves 12 g r) all_roots.
End Flow.

Definition sty (t : type) : ident := match t with Tstruct id _ => id | _ => 1%positive end.

(* ---------------------------------------------------------------------- *)
(* 1. The camera mode.                                                     *)
(* ---------------------------------------------------------------------- *)

Definition mode_cell (l : expr) : bool :=
  match l with
  | Efield b f _ => memi f [camera._mode; camera._defMode; camera._newMode; camera._lastMode]
                    && memi (sty (typeof b)) [camera._Camera; camera._LakituState; camera._ModeTransitionInfo]
  | _ => false
  end.

Definition mode_ok (z : Z) : bool := (1 <=? z)%Z && (z <=? 17)%Z.

Lemma mode_census :
  List.length (all_roots mode_cell) = 38%nat
  /\ report mode_cell mode_ok =
       [("camera_course_processing", "const 0");
        ("update_mario_sound_and_camera", "const -1");
        ("act_first_person", "const -1");
        ("create_camera", "*($gc).config.mode");
        ("create_camera", "*($gc).config.mode")].
Proof. split; vm_compute; reflexivity. Qed.

(* ---------------------------------------------------------------------- *)
(* Initializer reading.                                                    *)
(* ---------------------------------------------------------------------- *)

Local Open Scope Z_scope.
Local Close Scope string_scope.

Definition cce := prog_comp_env camera.prog.
Definition gv (x : ident) : option (globvar type) :=
  match (prog_defmap camera.prog) ! x with Some (Gvar v) => Some v | _ => None end.

Fixpoint cell_at (l : list init_data) (pos ofs : Z) : option init_data :=
  match l with
  | nil => None
  | d :: l' => if (pos <=? ofs) && (ofs <? pos + init_data_size d) then Some d
               else cell_at l' (pos + init_data_size d) ofs
  end.

Definition foff (sid f : ident) : Z :=
  match cce ! sid with
  | Some co => match field_offset cce f (co_members co) with Errors.OK (o, _) => o | _ => -1 end
  | None => -1 end.

Definition ssize (sid : ident) : Z := Ctypes.sizeof cce (Tstruct sid noattr).
Definition total (l : list init_data) : Z := fold_left (fun a d => a + init_data_size d) l 0.
Definition ginit (x : ident) : list init_data := match gv x with Some v => gvar_init v | None => [] end.

Definition is_fn (d : option init_data) : bool := match d with Some (Init_addrof _ _) => true | _ => false end.

(* the 18-entry transition table: NULL at 0, a function at 1..17 *)
Lemma mode_table :
  total (ginit camera._sModeTransitions) = 72
  /\ map (fun k => is_fn (cell_at (ginit camera._sModeTransitions) 0 (4 * Z.of_nat k))) (seq 0 18)
     = false :: repeat true 17.
Proof. split; vm_compute; reflexivity. Qed.

(* ---------------------------------------------------------------------- *)
(* 2. The camera triggers.                                                 *)
(* ---------------------------------------------------------------------- *)

Definition elems (sid x : ident) : nat := Z.to_nat (total (ginit x) / ssize sid).

Definition trig_arrays : list (option ident) :=
  map (fun k => match cell_at (ginit camera._sCameraTriggers) 0 (Z.of_nat k * 4) with
                | Some (Init_addrof x _) => Some x | _ => None end)
      (seq 0 (Z.to_nat (total (ginit camera._sCameraTriggers) / 4))).

(* is element k's event NULL? *)
Definition ev_nulls (x : ident) : list bool :=
  map (fun k => negb (is_fn (cell_at (ginit x) 0
                   (Z.of_nat k * ssize camera._CameraTrigger + foff camera._CameraTrigger camera._event))))
      (seq 0 (elems camera._CameraTrigger x)).

Definition null_terminated (l : list bool) : bool :=
  match rev l with true :: r => forallb negb r | _ => false end.

Lemma trig_census :
  List.length trig_arrays = 40%nat
  /\ nth 31 trig_arrays (Some 1%positive) = None                (* LEVEL_WMOTR *)
  /\ forallb (fun o => match o with Some x => null_terminated (ev_nulls x) | None => true end) trig_arrays = true
  /\ List.length (filter (fun o => match o with Some _ => true | None => false end) trig_arrays) = 9%nat.
Proof. vm_compute. auto. Qed.

(* ---------------------------------------------------------------------- *)
(* 3. The cutscene shots.                                                  *)
(* ---------------------------------------------------------------------- *)

Fixpoint sev (s : statement) : list ident :=
  match s with
  | Sassign l r => evars l ++ evars r | Sset _ r => evars r
  | Scall _ fe al => evars fe ++ flat_map evars al
  | Ssequence a b | Sloop a b => sev a ++ sev b
  | Sifthenelse c a b => evars c ++ sev a ++ sev b
  | Slabel _ a => sev a
  | Sswitch e sl => evars e ++ sev_ls sl
  | Sreturn (Some e) => evars e
  | _ => nil
  end
with sev_ls (sl : labeled_statements) : list ident :=
  match sl with LSnil => nil | LScons _ a sl' => sev a ++ sev_ls sl' end.

(* the shot arrays play_cutscene indexes *)
Definition cut_arrays : list ident :=
  match fn_tab ! camera._play_cutscene with
  | Some (_, f) => inodup (filter (fun x => match gv x with
       | Some v => match gvar_info v with Tarray (Tstruct id _) _ _ => Pos.eqb id camera._Cutscene | _ => false end
       | None => false end) (sev (fn_body f)))
  | None => [] end.

Definition durations (x : ident) : list Z :=
  map (fun k => match cell_at (ginit x) 0 (Z.of_nat k * ssize camera._Cutscene + foff camera._Cutscene camera._duration) with
                | Some (Init_int16 n) => Int.signed n | Some (Init_space _) => 0 | _ => -1 end)
      (seq 0 (elems camera._Cutscene x)).

Definition shots (x : ident) : list ident :=
  map (fun k => match cell_at (ginit x) 0 (Z.of_nat k * ssize camera._Cutscene) with
                | Some (Init_addrof g _) => g | _ => 1%positive end)
      (seq 0 (elems camera._Cutscene x)).

Definition timer_cell (l : expr) : bool :=
  match l with Evar x _ => Pos.eqb x camera._gCutsceneTimer | _ => false end.
Definition shot_cell (l : expr) : bool :=
  match l with Evar x _ => Pos.eqb x camera._sCutsceneShot | _ => false end.

Definition LOOP : Z := 32767.

(* the functions that may store CUTSCENE_LOOP (or an unresolved value) into
   gCutsceneTimer *)
Definition loop_setters : list ident :=
  inodup (map fst (filter (fun '(g, r) =>
    match leaves timer_cell (fun z => negb (Z.eqb z LOOP)) 12 g r with nil => false | _ => true end)
    (all_roots timer_cell))).

(* a shot's closure: direct calls and the functions passed as values
   (cutscene_event's events) *)
Definition ssucc (x : ident) : list ident :=
  match fn_tab ! x with Some (_, f) => let '(c, _, v) := cg (fn_body f) in c ++ v | None => [] end.
Fixpoint sclose (fuel : nat) (work seen : list ident) : list ident :=
  match fuel with O => seen | S n =>
    match work with
    | nil => seen
    | x :: w => if memi x seen then sclose n w seen else sclose n (ssucc x ++ w) (x :: seen)
    end end.

Definition sets_loop (g : ident) : bool :=
  existsb (fun s => memi s (sclose 5000 [g] [])) (filter (fun s => negb (Pos.eqb s camera._play_cutscene)) loop_setters).

(* an array is safe: no shot is a non-function, the last duration is 0 or
   LOOP, and only a shot before the last can set the timer to LOOP *)
Definition cut_ok (x : ident) : bool :=
  let sh := shots x in let ds := durations x in
  let n := List.length sh in
  negb (Nat.eqb n 0)
  && forallb (fun g => negb (Pos.eqb g 1%positive)) sh
  && (match rev ds with d :: _ => Z.eqb d 0 || Z.eqb d LOOP | nil => false end)
  && negb (sets_loop (nth (n - 1) sh 1%positive)).

Local Open Scope string_scope.

Lemma loop_setters_value :
  map string_of_ident loop_setters =
    ["cutscene_mario_dialog"; "cutscene_bowser_arena_dialog"; "cutscene_star_spawn";
     "cutscene_red_coin_star"; "cutscene_dialog"; "cutscene_read_message";
     "cutscene_intro_peach_start_to_pipe_spline"; "cutscene_intro_peach_letter"; "play_cutscene"].
Proof. vm_compute. reflexivity. Qed.

(* sCutsceneShot: stored as 0, and by play_cutscene's ++ (its only leaf) *)
Lemma shot_census :
  report shot_cell (fun z => Z.eqb z 0) = [("play_cutscene", "($5 op 1)")].
Proof. vm_compute. reflexivity. Qed.

Lemma cut_census :
  List.length cut_arrays = 43%nat /\ forallb cut_ok cut_arrays = true.
Proof. split; vm_compute; reflexivity. Qed.

(* every function storing Camera.cutscene, with its gCutsceneTimer stores *)
Definition cut_cell (l : expr) : bool :=
  match l with Efield b f _ => Pos.eqb f camera._cutscene && memi (sty (typeof b)) [camera._Camera] | _ => false end.

Definition cut_end_rows : list (string * list string * list string) :=
  flat_map (fun '(_, h, f) => match roots cut_cell h (fn_body f) with
   | nil => nil
   | l => [(string_of_ident h, map (fun '(_, r) => pex r) l,
            map (fun '(_, r) => pex r) (roots timer_cell h (fn_body f)))] end) all_fns.

Lemma cut_end_census :
  cut_end_rows =
   [("init_camera", ["0"], []); ("create_camera", ["0"], []);
    ("start_cutscene", ["$cutscene"], []);
    ("stop_cutscene_and_retrieve_stored_info", ["0"], ["32768"]);
    ("cutscene_ending_stop", ["0"], ["32768"]);
    ("cutscene_dance_default_rotate", ["0"], ["32768"]);
    ("cutscene_bowser_arena_end", ["0"], []);
    ("cutscene_star_spawn_end", ["0"], ["32768"]);
    ("cutscene_exit_to_castle_grounds_end", ["0"], ["32768"]);
    ("cutscene_red_coin_star_end", ["0"], ["32768"]);
    ("cutscene_prepare_cannon_end", ["0"], ["32768"]);
    ("cutscene_dialog_end", ["0"], []);
    ("cutscene_read_message_end", ["0"], []);
    ("cutscene_non_painting_end", ["0"], []);
    ("cutscene_intro_peach_dialog", ["0"], ["32768"]);
    ("cutscene_double_doors_end", ["0"], []);
    ("cutscene_enter_painting", ["0"], ["32768"]);
    ("cutscene_exit_painting_end", ["0"], ["32768"]);
    ("cutscene_enter_cannon_end", ["0"], []);
    ("cutscene_door_loop", ["0"], ["32768"]);
    ("cutscene_door_end", ["0"], ["32768"]);
    ("cutscene_door_mode", ["0"], ["32768"])].
Proof. vm_compute. reflexivity. Qed.

(* the six zeroing shots without CUTSCENE_STOP are each a LAST shot of
   duration 0 in some array (so play_cutscene resets the shot index) *)
Definition last_zero_shot (g : ident) : bool :=
  existsb (fun x => let sh := shots x in
     match rev sh, rev (durations x) with
     | g' :: _, d :: _ => Pos.eqb g g' && Z.eqb d 0
     | _, _ => false end) cut_arrays.

Lemma unpaired_ends_last :
  forallb last_zero_shot
    [camera._cutscene_bowser_arena_end; camera._cutscene_dialog_end; camera._cutscene_read_message_end;
     camera._cutscene_non_painting_end; camera._cutscene_double_doors_end; camera._cutscene_enter_cannon_end]
  = true.
Proof. vm_compute. reflexivity. Qed.
