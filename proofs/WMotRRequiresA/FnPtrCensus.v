(* spine-root: GOAL 1 over the whole frame -- the FUNCTION-POINTER TYPING
   census behind ActWriterCensus's indirect edges (TRUST 3.2): every
   function address in the link enters the program at exactly its own
   type, so an indirect call in the objects + camera closure reaches only
   functions of the call site's type -- the edges census_value follows. *)
(* ====================================================================== *)
(* DO ActWriterCensus's INDIRECT EDGES COVER WHAT THE N64 WOULD RUN?       *)
(*                                                                        *)
(* ActWriterCensus follows an indirect call of type t only to the address-*)
(* taken functions of exactly type t.  A call through a pointer of another*)
(* type is C UB: CompCert gives it no execution (exec_Scall), the N64     *)
(* would run the target.  This file shows, on the generated code of the   *)
(* whole link (ObjTable.lprogs, every TU, every initializer and body),     *)
(* that no such call can arise from the program's typed data flow:        *)
(*                                                                        *)
(* (I) the indirect calls of clos: 7 functions (set_camera_mode,          *)
(*     play_cutscene, cutscene_event, camera_course_processing,           *)
(*     cur_obj_call_action_function, bhv_cmd_call_native, cur_obj_update) *)
(*     at 4 call types (clos_icall_tys_value).                            *)
(* (A) INITIALIZERS: every Init_addrof of a function, in every global of  *)
(*     the link, sits in a slot (the field / element of the global's type *)
(*     at that offset) of type pointer-to-exactly-its-type -- 507 sites:  *)
(*     BehaviorCmdTable, the oAction tables handed to                     *)
(*     cur_obj_call_action_function, sModeTransitions, the cutscene and   *)
(*     camera-trigger structs, ... -- or (751 sites) in an INTEGER slot   *)
(*     of a behavior_data script (CALL_NATIVE's uintptr_t word), and then *)
(*     the function is void(void) (init_census).                          *)
(* (B) BODIES: every function designator in a body (assignment rhs,       *)
(*     argument, temp, return, cast) enters at exactly its type: 187      *)
(*     sites, no exception (body_census) -- so every function-pointer    *)
(*     struct-field / global store of a designator is type-exact.         *)
(* (C) RE-ENTRY: the only conversion into a function-pointer type from a  *)
(*     non-constant of another type, anywhere in the link, is             *)
(*     bhv_cmd_call_native's (void * -> void ( * )(void)) of its script   *)
(*     word (reentry_census); by (A)+(B)+(X) every function address held  *)
(*     at a non-function-pointer type is a void(void) function.           *)
(* (X) EXITS: no conversion of a function pointer to any other type       *)
(*     (exit_census).                                                      *)
(* (D) PUNNING: the only pointer casts to or from memory holding function *)
(*     pointers are the graph-node downcasts of the render code and       *)
(*     geo_process_held_object's (void * ) node, outside clos; the        *)
(*     function pointers they reach are all GraphNodeFunc, a type no call *)
(*     site of clos has; no union holds a function pointer (pun_census).  *)
(* (V) every temp is read at its declared type, and every global at its   *)
(*     defining TU's type, except setup_game_memory's gMarioAnims (no     *)
(*     function pointer, outside clos) (read_census).                     *)
(*                                                                        *)
(* So a function pointer that reaches a call site of type t in clos has   *)
(* type t, whatever slot it was stored in -- the edges of ActWriterCensus *)
(* are the real ones.  NOT covered (it is other UB, row 3.2): a call      *)
(* through a table entry read OUT OF BOUNDS (tbl[o->oAction],             *)
(* BehaviorCmdTable[cmd >> 24], sModeTransitions[mode], the cutscene and  *)
(* camera-trigger arrays), which on the N64 would read a neighbour of     *)
(* another type.                                                           *)
(* ====================================================================== *)

From Coq Require Import ZArith List Bool String.
From compcert Require Import Coqlib Maps AST Integers Ctypes Cop Clight Ctypesdefs Clightdefs.
From SM64.Proofs.WMotRRequiresA Require Import ObjTable RoCensus ActWriterCensus.
Import ListNotations.
Open Scope string_scope.

(* ---------------------------------------------------------------------- *)
(* Types, printed (for the pinned lists).                                  *)
(* ---------------------------------------------------------------------- *)

Fixpoint pty (t : type) : string :=
  match t with
  | Tvoid => "void"
  | Tint _ _ _ => "int"
  | Tlong _ _ => "long"
  | Tfloat F32 _ => "float" | Tfloat F64 _ => "double"
  | Tpointer t _ => pty t ++ "*"
  | Tarray t _ _ => pty t ++ "[]"
  | Tfunction a r _ => pty r ++ "(" ++ (fix ptl (l : list type) : string :=
      match l with nil => "" | t :: l => pty t ++ "," ++ ptl l end) a ++ ")"
  | Tstruct id _ => "struct " ++ string_of_ident id
  | Tunion id _ => "union " ++ string_of_ident id
  end.

Definition pairs (l : list (type * type)) : list (string * string) :=
  map (fun '(a, b) => (pty a, pty b)) l.

(* ---------------------------------------------------------------------- *)
(* (I) The indirect call sites of clos.                                    *)
(* ---------------------------------------------------------------------- *)

Fixpoint icall_tys (s : statement) : list type :=
  match s with
  | Scall _ f _ => match direct f with Some _ => nil | None => [typeof f] end
  | Ssequence s1 s2 | Sloop s1 s2 | Sifthenelse _ s1 s2 => icall_tys s1 ++ icall_tys s2
  | Slabel _ s1 => icall_tys s1
  | Sswitch _ sl => icall_tys_ls sl
  | _ => nil
  end
with icall_tys_ls (sl : labeled_statements) : list type :=
  match sl with LSnil => nil | LScons _ s sl' => icall_tys s ++ icall_tys_ls sl' end.

Definition icall_fns : list ident :=
  filter (fun x => match fn_tab ! x with
                   | Some (_, f) => match icall_tys (fn_body f) with nil => false | _ => true end
                   | None => false end) clos.

Fixpoint tnodup (l : list type) : list type :=
  match l with nil => nil | t :: l' => if existsb (tyb t) l' then tnodup l' else t :: tnodup l' end.

(* the (pointer) types of clos's indirect call sites *)
Definition clos_icall_tys : list type :=
  tnodup (flat_map (fun x => match fn_tab ! x with
                             | Some (_, f) => icall_tys (fn_body f) | None => nil end) clos).

(* ---------------------------------------------------------------------- *)
(* The type of every function of the link (internal definition first).    *)
(* ---------------------------------------------------------------------- *)

Definition fty_of_def (g : globdef Clight.fundef type) : option type :=
  match g with
  | Gfun (Internal f) => Some (type_of_function f)
  | Gfun (External _ a r cc) => Some (Tfunction a r cc)
  | _ => None
  end.

Definition ftab : PTree.t type :=
  fold_left (fun t p => fold_left (fun t '(id, g) =>
     match fty_of_def g, g with
     | Some ty, Gfun (Internal _) => PTree.set id ty t
     | Some ty, _ => match t ! id with Some _ => t | None => PTree.set id ty t end
     | None, _ => t
     end) (prog_defs p) t) lprogs (PTree.empty type).

Definition fty_is (x : ident) (t : type) : bool :=
  match ftab ! x with Some u => tyb u t | None => false end.

Definition is_fnptr (t : type) : option type :=
  match t with Tpointer (Tfunction _ _ _ as ft) _ => Some ft | _ => None end.

(* how a function address enters a slot of static type ctx *)
Inductive cls := Exact | Erased (t : type) | Mism (want : type) | Other.

Definition classify (f : ident) (ctx : option type) : cls :=
  match ctx with
  | None => Other
  | Some t =>
      match ftab ! f, is_fnptr t with
      | Some ft, Some pt => if tyb ft pt then Exact else Mism pt
      | _, Some pt => Mism pt
      | _, None => match t with Tfunction _ _ _ => Other | _ => Erased t end
      end
  end.

Definition is_exact (c : cls) : bool := match c with Exact => true | _ => false end.
Definition is_erased (c : cls) : bool := match c with Erased _ => true | _ => false end.

Definition t_vv : type := Tfunction nil Tvoid cc_default.

(* ---------------------------------------------------------------------- *)
(* (A) Initializers: the slot type at each Init_addrof's offset.           *)
(* ---------------------------------------------------------------------- *)

Fixpoint slot_ty (ce : composite_env) (fuel : nat) (t : type) (ofs : Z) : option type :=
  match fuel with O => None | S n =>
  match t with
  | Tarray e _ _ => let s := Ctypes.sizeof ce e in
                    if Z.ltb 0 s then slot_ty ce n e (Z.modulo ofs s) else None
  | Tstruct id _ =>
      match ce ! id with
      | Some co =>
          (fix go (ms : members) : option type :=
             match ms with
             | nil => None
             | m :: ms' =>
                 match field_offset ce (name_member m) (co_members co) with
                 | Errors.OK (o, _) =>
                     if Z.leb o ofs && Z.ltb ofs (o + Ctypes.sizeof ce (type_member m))
                     then slot_ty ce n (type_member m) (ofs - o) else go ms'
                 | _ => go ms'
                 end
             end) (co_members co)
      | None => None
      end
  | Tunion _ _ => Some t                    (* a union slot: classified Erased *)
  | _ => if Z.eqb ofs 0 then Some t else None
  end end.

Fixpoint init_addrs_ofs (l : list init_data) (pos : Z) : list (Z * ident) :=
  match l with
  | nil => nil
  | d :: l' => (match d with Init_addrof x _ => [(pos, x)] | _ => nil end)
                ++ init_addrs_ofs l' (pos + init_data_size d)
  end.

(* (holder global, function, how it enters) *)
Definition init_rows (p : Clight.program) : list (ident * ident * cls) :=
  flat_map (fun '(id, g) =>
    match g with
    | Gvar v => flat_map (fun '(o, x) =>
        match ftab ! x with
        | Some _ => [(id, x, classify x (slot_ty (prog_comp_env p) 50 (gvar_info v) o))]
        | None => nil
        end) (init_addrs_ofs (gvar_init v) 0)
    | _ => nil
    end) (prog_defs p).

Definition A_all : list (ident * ident * cls) := flat_map init_rows lprogs.

Definition init_ok (r : ident * ident * cls) : bool :=
  let '(g, x, c) := r in
  is_exact c || (is_erased c && memi g bhv_scripts && fty_is x t_vv).

(* ---------------------------------------------------------------------- *)
(* (B) Function designators in bodies, with the type they enter at.        *)
(* ---------------------------------------------------------------------- *)

Fixpoint occ (ctx : option type) (a : expr) : list (ident * option type) :=
  match a with
  | Evar x (Tfunction _ _ _) => [(x, ctx)]
  | Ecast a1 t => occ (Some t) a1
  | Ederef a1 _ | Efield a1 _ _ | Eaddrof a1 _ | Eunop _ a1 _ => occ None a1
  | Ebinop _ a1 a2 _ => occ None a1 ++ occ None a2
  | _ => nil
  end.

Fixpoint occl (ps : list type) (al : list expr) : list (ident * option type) :=
  match al with
  | nil => nil
  | a :: al' => match ps with
                | p :: ps' => occ (Some p) a ++ occl ps' al'
                | nil => occ None a ++ occl nil al'
                end
  end.

Definition params_of (t : type) : list type :=
  match t with
  | Tfunction a _ _ => a
  | Tpointer (Tfunction a _ _) _ => a
  | _ => nil
  end.

Definition temp_ty (f : function) (t : ident) : option type :=
  match find (fun '(i, _) => Pos.eqb i t) (fn_temps f) with Some (_, ty) => Some ty | None => None end.

Fixpoint bocc (f : function) (s : statement) : list (ident * option type) :=
  match s with
  | Sassign l r => occ None l ++ occ (Some (typeof l)) r
  | Sset t r => occ (temp_ty f t) r
  | Scall _ fe al => (match direct fe with Some _ => nil | None => occ None fe end)
                     ++ occl (params_of (typeof fe)) al
  | Sbuiltin _ _ _ al => occl nil al
  | Ssequence s1 s2 | Sloop s1 s2 => bocc f s1 ++ bocc f s2
  | Sifthenelse c s1 s2 => occ None c ++ bocc f s1 ++ bocc f s2
  | Slabel _ s1 => bocc f s1
  | Sswitch a sl => occ None a ++ bocc_ls f sl
  | Sreturn (Some a) => occ (Some (fn_return f)) a
  | _ => nil
  end
with bocc_ls (f : function) (sl : labeled_statements) : list (ident * option type) :=
  match sl with LSnil => nil | LScons _ s sl' => bocc f s ++ bocc_ls f sl' end.

Definition B_all : list (ident * ident * cls) :=
  flat_map (fun '(_, h, f) => map (fun '(x, c) => (h, x, classify x c)) (bocc f (fn_body f))) all_fns.

(* ---------------------------------------------------------------------- *)
(* (C) / (X) Conversions into and out of function-pointer types: explicit *)
(* casts, and the implicit ones of assignment, temp, argument, return.    *)
(* ---------------------------------------------------------------------- *)

Fixpoint is_iconst (a : expr) : bool :=
  match a with
  | Econst_int _ _ => true
  | Ecast a1 _ | Eunop _ a1 _ => is_iconst a1
  | _ => false
  end.

(* into a function-pointer type, from something not of that exact type
   (an integer constant -- NULL, the (void ( * )(s16 * )) -1 sentinel --
   is no function address) *)
Definition conv_in (src dst : type) (a : expr) : bool :=
  if is_iconst a then false else
  match is_fnptr dst with
  | None => false
  | Some pt =>
      if tyb src dst then false
      else match a with
           | Evar x (Tfunction _ _ _) => negb (fty_is x pt)
           | _ => match is_fnptr src with Some ps => negb (tyb ps pt) | None => true end
           end
  end.

(* out of a function-pointer type, into anything else *)
Definition conv_out (src dst : type) (a : expr) : bool :=
  match is_fnptr src with
  | Some _ => negb (tyb src dst) && match is_fnptr dst with
                                     | Some _ => false
                                     | None => match dst with Tfunction _ _ _ => false | _ => true end
                                     end
  | None => false
  end.

Section Conv.
  Variable bad : type -> type -> expr -> bool.

  Fixpoint ce_ (a : expr) : list (type * type) :=
    match a with
    | Ecast a1 t => (if bad (typeof a1) t a1 then [(typeof a1, t)] else nil) ++ ce_ a1
    | Ederef a1 _ | Efield a1 _ _ | Eaddrof a1 _ | Eunop _ a1 _ => ce_ a1
    | Ebinop _ a1 a2 _ => ce_ a1 ++ ce_ a2
    | _ => nil
    end.

  Fixpoint cel (ps : list type) (al : list expr) : list (type * type) :=
    match al with
    | nil => nil
    | a :: al' => ce_ a ++ match ps with
                  | p :: ps' => (if bad (typeof a) p a then [(typeof a, p)] else nil) ++ cel ps' al'
                  | nil => (if bad (typeof a) Tvoid a then [(typeof a, Tvoid)] else nil) ++ cel nil al'
                  end
    end.

  Fixpoint cs (f : function) (s : statement) : list (type * type) :=
    match s with
    | Sassign l r => ce_ l ++ ce_ r ++ (if bad (typeof r) (typeof l) r then [(typeof r, typeof l)] else nil)
    | Sset t r => ce_ r ++ match temp_ty f t with
                    | Some ty => if bad (typeof r) ty r then [(typeof r, ty)] else nil
                    | None => nil end
    | Scall _ fe al => ce_ fe ++ cel (params_of (typeof fe)) al
    | Sbuiltin _ _ _ al => cel nil al
    | Ssequence s1 s2 | Sloop s1 s2 => cs f s1 ++ cs f s2
    | Sifthenelse c s1 s2 => ce_ c ++ cs f s1 ++ cs f s2
    | Slabel _ s1 => cs f s1
    | Sswitch a sl => ce_ a ++ cs_ls f sl
    | Sreturn (Some a) => ce_ a ++ (if bad (typeof a) (fn_return f) a then [(typeof a, fn_return f)] else nil)
    | _ => nil
    end
  with cs_ls (f : function) (sl : labeled_statements) : list (type * type) :=
    match sl with LSnil => nil | LScons _ s sl' => cs f s ++ cs_ls f sl' end.

  (* per function of the link: (function, in clos?, the conversions) *)
  Definition conv_sites : list (string * bool * list (string * string)) :=
    flat_map (fun '(_, h, f) => match cs f (fn_body f) with
      | nil => nil
      | l => [(string_of_ident h, memi h clos, pairs l)] end) all_fns.
End Conv.

(* ---------------------------------------------------------------------- *)
(* (D) Pointer punning around memory that holds function pointers.         *)
(* ---------------------------------------------------------------------- *)

Fixpoint holds_fp (ce : composite_env) (fuel : nat) (t : type) : bool :=
  match fuel with O => true | S n =>
  match t with
  | Tpointer (Tfunction _ _ _) _ => true
  | Tarray e _ _ => holds_fp ce n e
  | Tstruct id _ | Tunion id _ => match ce ! id with
      | Some co => existsb (fun m => holds_fp ce n (type_member m)) (co_members co)
      | None => false end
  | _ => false
  end end.

(* the function-pointer types inside a type *)
Fixpoint fps (ce : composite_env) (fuel : nat) (t : type) : list type :=
  match fuel with O => nil | S n =>
  match t with
  | Tpointer (Tfunction _ _ _ as ft) _ => [ft]
  | Tarray e _ _ => fps ce n e
  | Tstruct id _ | Tunion id _ => match ce ! id with
      | Some co => flat_map (fun m => fps ce n (type_member m)) (co_members co)
      | None => nil end
  | _ => nil
  end end.

(* a conversion between pointer types where either side points at memory
   holding a function pointer *)
Definition pun (ce : composite_env) (src dst : type) : bool :=
  negb (tyb src dst) &&
  match src, dst with
  | (Tpointer s _ | Tarray s _ _), Tpointer d _ =>
      negb (tyb s d) && (holds_fp ce 20 s || holds_fp ce 20 d)
  | (Tpointer s _ | Tarray s _ _), _ => holds_fp ce 20 s
  | _, Tpointer d _ => holds_fp ce 20 d
  | _, _ => false
  end.

Definition pun_rows (p : Clight.program) : list (ident * list (type * type)) :=
  let ce := prog_comp_env p in
  flat_map (fun '(h, g) => match g with
    | Gfun (Internal f) =>
        match cs (fun s d a => if is_iconst a then false else pun ce s d) f (fn_body f) with
        | nil => nil
        | l => [(h, l)] end
    | _ => nil end) (prog_defs p).

Definition puns : list (ident * list (type * type)) := flat_map pun_rows lprogs.

(* the function-pointer types the punned pointers reach *)
Definition pun_fp_tys : list type :=
  tnodup (flat_map (fun p => let ce := prog_comp_env p in
    flat_map (fun '(_, l) => flat_map (fun '(s, d) =>
        match s, d with
        | (Tpointer s' _ | Tarray s' _ _), Tpointer d' _ => List.app (fps ce 20 s') (fps ce 20 d')
        | (Tpointer s' _ | Tarray s' _ _), _ => fps ce 20 s'
        | _, Tpointer d' _ => fps ce 20 d'
        | _, _ => nil end) l) (pun_rows p)) lprogs).

Definition fp_unions : list ident :=
  flat_map (fun p => flat_map (fun '(id, co) =>
    match co_su co with
    | Union => if holds_fp (prog_comp_env p) 20 (Tunion id noattr) then [id] else nil
    | Struct => nil end) (PTree.elements (prog_comp_env p))) lprogs.

(* ---------------------------------------------------------------------- *)
(* (V) Reads at the declared type.                                         *)
(* ---------------------------------------------------------------------- *)

Definition vtab : PTree.t type :=
  fold_left (fun t p => fold_left (fun t '(id, g) =>
     match g with
     | Gvar v => match gvar_init v with
                 | nil => match t ! id with Some _ => t | None => PTree.set id (gvar_info v) t end
                 | _ => PTree.set id (gvar_info v) t end
     | _ => t end) (prog_defs p) t) lprogs (PTree.empty type).

(* an array's declared length may differ between extern and definition *)
Definition nz (t : type) : type := match t with Tarray e _ a => Tarray e 0 a | _ => t end.

Fixpoint vchk (tl : list (ident * type)) (a : expr) : list ident :=
  match a with
  | Etempvar x ty => match find (fun '(i, _) => Pos.eqb i x) tl with
                     | Some (_, t) => if tyb t ty then nil else [x]
                     | None => [x] end
  | Evar x ty => match ty with Tfunction _ _ _ => nil | _ =>
                   match vtab ! x with Some t => if tyb (nz t) (nz ty) then nil else [x] | None => nil end end
  | Ecast a1 _ | Ederef a1 _ | Efield a1 _ _ | Eaddrof a1 _ | Eunop _ a1 _ => vchk tl a1
  | Ebinop _ a1 a2 _ => vchk tl a1 ++ vchk tl a2
  | _ => nil
  end.

Fixpoint bv (tl : list (ident * type)) (s : statement) : list ident :=
  match s with
  | Sassign l r => vchk tl l ++ vchk tl r
  | Sset _ r => vchk tl r
  | Scall _ fe al => vchk tl fe ++ flat_map (vchk tl) al
  | Sbuiltin _ _ _ al => flat_map (vchk tl) al
  | Ssequence s1 s2 | Sloop s1 s2 => bv tl s1 ++ bv tl s2
  | Sifthenelse c s1 s2 => vchk tl c ++ bv tl s1 ++ bv tl s2
  | Slabel _ s1 => bv tl s1
  | Sswitch a sl => vchk tl a ++ bv_ls tl sl
  | Sreturn (Some a) => vchk tl a
  | _ => nil
  end
with bv_ls (tl : list (ident * type)) (sl : labeled_statements) : list ident :=
  match sl with LSnil => nil | LScons _ s sl' => bv tl s ++ bv_ls tl sl' end.

Definition read_rows : list (string * bool * list string) :=
  flat_map (fun '(_, h, f) => match bv (fn_params f ++ fn_temps f) (fn_body f) with
    | nil => nil
    | l => [(string_of_ident h, memi h clos, map string_of_ident l)] end) all_fns.

(* ---------------------------------------------------------------------- *)
(* The census, pinned.                                                     *)
(* ---------------------------------------------------------------------- *)

(* (I) *)
Lemma icall_fns_value :
  map string_of_ident icall_fns =
    ["set_camera_mode"; "play_cutscene"; "cutscene_event"; "camera_course_processing";
     "cur_obj_call_action_function"; "bhv_cmd_call_native"; "cur_obj_update"].
Proof. vm_compute. reflexivity. Qed.

Lemma clos_icall_tys_value :
  map pty clos_icall_tys =
    ["int(struct Camera*,float*,float*,)*"; "void(struct Camera*,)*"; "void()*"; "int()*"].
Proof. vm_compute. reflexivity. Qed.

(* (A) *)
Lemma init_census :
  forallb init_ok A_all = true
  /\ List.length (filter (fun '(_, _, c) => is_exact c) A_all) = 507%nat
  /\ List.length (filter (fun '(_, _, c) => is_erased c) A_all) = 751%nat.
Proof. vm_compute. auto. Qed.

(* (B) *)
Lemma body_census :
  forallb (fun '(_, _, c) => is_exact c) B_all = true /\ List.length B_all = 187%nat.
Proof. vm_compute. auto. Qed.

(* (C) *)
Lemma reentry_census :
  conv_sites conv_in = [("bhv_cmd_call_native", true, [("void*", "void()*")])].
Proof. vm_compute. reflexivity. Qed.

(* (X) *)
Lemma exit_census : conv_sites conv_out = nil.
Proof. vm_compute. reflexivity. Qed.

(* (D) *)
Lemma pun_census :
  map (fun '(h, _) => (string_of_ident h, memi h clos)) puns =
    [("geo_switch_peach_eyes", false); ("geo_switch_bowser_eyes", false);
     ("geo_bits_bowser_coloring", false); ("geo_switch_tuxie_mother_eyes", false);
     ("geo_call_global_function_nodes_helper", false); ("geo_update_layer_transparency", false);
     ("geo_switch_anim_state", false); ("geo_switch_area", false); ("geo_camera_main", false);
     ("geo_camera_fov", false); ("geo_process_held_object", false);
     ("geo_process_node_and_siblings", false)]
  /\ List.length pun_fp_tys = 1%nat
  /\ forallb (fun t => negb (existsb (fun u => tyb (Tpointer t noattr) u) clos_icall_tys)) pun_fp_tys = true
  /\ fp_unions = nil.
Proof. vm_compute. auto. Qed.

(* (V) *)
Lemma read_census :
  read_rows = [("setup_game_memory", false, ["gMarioAnims"])].
Proof. vm_compute. reflexivity. Qed.
