(* spine (via CamFootInst, 2026-11-02): the camera's byte-level footprint
   walker (CamRows derives the camera rows' footprint half from it). *)
(* ====================================================================== *)
(* CamFootKit.v -- a FOOTPRINT class walker for recursive call trees with *)
(* indirect calls (UcKit's shape), whose classes carry a BYTE range for   *)
(* one struct object (the area's Camera).                                 *)
(*                                                                        *)
(* UcKit proves update_camera keeps GOAL 1's carried facts: every store   *)
(* lands in a SafeB block, a fresh block, or a global MWF does not read.  *)
(* GOAL 2 needs where the camera writes: the main-pool Camera shares its  *)
(* block with the surface pool and the partition nodes, so a block-level  *)
(* answer is useless there.  This walk proves, for every state (no        *)
(* pruning: an indirect call may reach any function of its type):         *)
(*   memory changes only in                                               *)
(*     - the blocks of a listed set of globals FP,                         *)
(*     - blocks born during the call (stack locals),                       *)
(*     - the byte range [co, co + SZ) of block cb (the Camera),            *)
(*     - the cells of the PIN globals (written only with values of their   *)
(*       pin class),                                                       *)
(*   every old permission is kept and every new block ends permissionless,*)
(*   and the pins are kept.                                                *)
(* THE PINS.  A pin is a pointer global whose value the walk may trust:   *)
(* its cell holds a value of a fixed class (sMarioCamState: an FP block;  *)
(* gCamera: the Camera's base; gSecondCameraFocus: no pointer).  They are *)
(* the walk's PREMISE at its start; the walk keeps them.                  *)
(* THE CLASSES (a value, if a pointer Vptr b o, ...):                      *)
(*   fN    is no pointer;                                                  *)
(*   fF    b is an FP block or fresh (any offset);                         *)
(*   fC n  b = cb and co <= o, o + n <= co + SZ (n bytes from o are the   *)
(*         Camera's);                                                      *)
(*   fFC n either;                                                         *)
(*   fA    anything (never stored through).                                *)
(* Loads give fA (or fN by chunk), except a pin global's own cell.  So     *)
(* the walk needs nothing of the stored values but the pins'.             *)
(* ====================================================================== *)

From Coq Require Import ZArith List Lia Bool.
From compcert Require Import Coqlib Maps AST Integers Values Events Memory
  Globalenvs Ctypes Cop Clightdefs Clight ClightBigstep Errors.
From SM64.Proofs Require Import CensusV2.
From SM64.Proofs Require CameraModeBody MtxfBody RetSurface ActWriterSurface SpawnBodies.
Import ListNotations.
Local Open Scope Z_scope.

(* ---------------------------------------------------------------------- *)
(* 0. Classes.                                                             *)
(* ---------------------------------------------------------------------- *)
Inductive fcls : Type := fN | fF | fC (n : Z) | fFC (n : Z) | fA.

Definition fle (c d : fcls) : bool :=
  match c, d with
  | fN, _ => true
  | _, fA => true
  | fF, (fF | fFC _) => true
  | fC n, fC n' | fC n, fFC n' | fFC n, fFC n' => Z.leb n' n
  | _, _ => false
  end.

Definition fjoin (c d : fcls) : fcls :=
  match c, d with
  | fN, _ => d
  | _, fN => c
  | fA, _ | _, fA => fA
  | fF, fF => fF
  | fF, fC n | fC n, fF | fF, fFC n | fFC n, fF => fFC n
  | fC n, fC n' => fC (Z.min n n')
  | fC n, fFC n' | fFC n, fC n' | fFC n, fFC n' => fFC (Z.min n n')
  end.

Lemma fle_refl : forall c, fle c c = true.
Proof. intros []; cbn; try reflexivity; apply Z.leb_refl. Qed.

Lemma fle_join_l : forall c d, fle c (fjoin c d) = true.
Proof.
  intros [| | n | n |] [| | n' | n' |]; cbn; try reflexivity; apply Z.leb_le; lia.
Qed.
Lemma fle_join_r : forall c d, fle d (fjoin c d) = true.
Proof.
  intros [| | n | n |] [| | n' | n' |]; cbn; try reflexivity; apply Z.leb_le; lia.
Qed.

Lemma fle_trans : forall c d e, fle c d = true -> fle d e = true -> fle c e = true.
Proof.
  intros [| | n | n |] [| | n' | n' |] [| | n'' | n'' |]; cbn; intros H1 H2;
    try reflexivity; try discriminate; apply Z.leb_le in H1; apply Z.leb_le in H2;
    apply Z.leb_le; lia.
Qed.

(* the block part only (an unknown offset) *)
Definition fblk (c : fcls) : fcls := match c with fN => fN | fF => fF | _ => fA end.

(* the address d bytes further on *)
Definition fshift (c : fcls) (d : Z) : fcls :=
  match c with
  | fN => fN
  | fF => fF
  | fC n => if (0 <=? d) && (d <=? n) then fC (n - d) else fA
  | fFC n => if (0 <=? d) && (d <=? n) then fFC (n - d) else fA
  | fA => fA
  end.

(* a store of s bytes through an address of class c (fN: no address, so
   the store cannot run -- e.g. through gSecondCameraFocus, pinned NULL) *)
Definition fstorable (c : fcls) (s : Z) : bool :=
  match c with
  | fN | fF => true
  | fC n | fFC n => Z.leb s n
  | _ => false
  end.

Section PC.
  Variable FB : block -> Prop.
  Variables (cb : block) (co SZ : Z).

  Definition fpc (c : fcls) (b : block) (o : ptrofs) : Prop :=
    match c with
    | fN => False
    | fF => FB b
    | fC n => b = cb /\ co <= Ptrofs.unsigned o /\ Ptrofs.unsigned o + n <= co + SZ
    | fFC n => FB b \/ (b = cb /\ co <= Ptrofs.unsigned o /\ Ptrofs.unsigned o + n <= co + SZ)
    | fA => True
    end.

  Definition fvok (c : fcls) (v : val) : Prop := forall b o, v = Vptr b o -> fpc c b o.

  Lemma fle_pc : forall c d b o, fle c d = true -> fpc c b o -> fpc d b o.
  Proof.
    intros [| | n | n |] [| | n' | n' |] b o H; cbn in *; try discriminate H; try tauto;
      apply Z.leb_le in H; intuition lia.
  Qed.

  Lemma fle_vok : forall c d v, fle c d = true -> fvok c v -> fvok d v.
  Proof. intros c d v H Hv b o E. exact (fle_pc _ _ _ _ H (Hv b o E)). Qed.

  Lemma fvok_np : forall c v, (forall b o, v <> Vptr b o) -> fvok c v.
  Proof. intros c v H b o E. exact (False_ind _ (H b o E)). Qed.

  Lemma fvok_undef : forall c, fvok c Vundef.
  Proof. intros c. apply fvok_np. intros b o E. discriminate E. Qed.
End PC.

(* ---------------------------------------------------------------------- *)
(* 1. The classifier.                                                      *)
(* ---------------------------------------------------------------------- *)

Definition mem_idf (x : ident) (l : list ident) : bool := existsb (Pos.eqb x) l.

Fixpoint pin_of (x : ident) (pins : list (ident * fcls)) : option fcls :=
  match pins with
  | nil => None
  | (g, c) :: pins' => if Pos.eqb g x then Some c else pin_of x pins'
  end.

(* an rvalue of type ty read at an address of class c *)
Definition frv (ty : type) (c : fcls) : fcls :=
  match access_mode ty with
  | By_value Mint32 | By_value Many32 | By_value Many64 => fA
  | By_value _ => fN
  | By_reference | By_copy => c
  | By_nothing => fN
  end.

(* the size of a scalar element (independent of the composite env) *)
Definition scal_size (ty : type) : option Z :=
  match ty with
  | Tint I8 _ _ | Tint IBool _ _ => Some 1
  | Tint I16 _ _ => Some 2
  | Tint I32 _ _ | Tfloat F32 _ | Tpointer _ _ => Some 4
  | Tfloat F64 _ | Tlong _ _ => Some 8
  | _ => None
  end.

(* a constant non-negative int index *)
Definition cidx (a : expr) : option Z :=
  match a with
  | Econst_int k (Tint _ _ _) => if Int.lt k Int.zero then None else Some (Int.unsigned k)
  | _ => None
  end.

Definition elt_of (ty : type) : option type :=
  match ty with Tpointer t _ | Tarray t _ _ => Some t | _ => None end.

Section CLS.
  Variable ce : composite_env.
  Variable FP : list ident.
  Variable pins : list (ident * fcls).
  Variable lv : list ident.
  Variable tc : ident -> fcls.

  (* the address of a variable *)
  Definition fvar (x : ident) : fcls :=
    if mem_idf x lv then fF else if mem_idf x FP then fF else fA.

  Definition ffield (c : fcls) (sty : type) (f : ident) : fcls :=
    match sty with
    | Tstruct id _ =>
        match ce ! id with
        | Some co =>
            if complete_members ce (co_members co) then
              match field_offset ce f (co_members co) with
              | OK (d, Full) => fshift c d
              | _ => fA
              end
            else fA
        | None => fA
        end
    | Tunion _ _ => fblk c
    | _ => fA
    end.

  Fixpoint fx (a : expr) : fcls :=
    match a with
    | Econst_int _ _ | Econst_float _ _ | Econst_single _ _ | Econst_long _ _ => fN
    | Esizeof _ _ | Ealignof _ _ | Eunop _ _ _ => fN
    | Etempvar t _ => tc t
    | Ecast a1 _ => fx a1
    | Evar x ty =>
        if mem_idf x lv then frv ty fF
        else match pin_of x pins, access_mode ty with
             | Some c, By_value Mint32 => c
             | _, _ => frv ty (fvar x)
             end
    | Ederef a1 ty => frv ty (fx a1)
    | Efield a1 f ty => frv ty (ffield (flv a1) (typeof a1) f)
    | Eaddrof a1 _ => flv a1
    | Ebinop op a1 a2 _ =>
        if CameraModeBody.never_ptr_binop op (typeof a1) (typeof a2) then fN else
        match op with
        | Oadd =>
            match cidx a2, elt_of (typeof a1) with
            | Some k, Some t =>
                match scal_size t with
                | Some sz => fshift (fx a1) (k * sz)
                | None => fjoin (fblk (fx a1)) (fblk (fx a2))
                end
            | _, _ => fjoin (fblk (fx a1)) (fblk (fx a2))
            end
        | Osub => fblk (fx a1)
        | _ => if RetSurface.vint_binop op then fN else fA
        end
    end
  with flv (a : expr) : fcls :=
    match a with
    | Evar x _ => fvar x
    | Ederef a1 _ => fx a1
    | Efield a1 f _ => ffield (flv a1) (typeof a1) f
    | _ => fA
    end.

  Fixpoint fargs_ok (al : list expr) (pcs : list fcls) : bool :=
    match al, pcs with
    | nil, nil => true
    | a :: al', c :: pcs' => fle (fx a) c && fargs_ok al' pcs'
    | _, _ => false
    end.
End CLS.

(* ---------------------------------------------------------------------- *)
(* 2. Signatures and the per-statement recognizers.                        *)
(* ---------------------------------------------------------------------- *)

(* (parameter classes, return class) *)
Definition fsig : Type := (list fcls * fcls)%type.
Definition ftab := list (ident * fsig).
Definition fitab := list (type * fsig).

Definition ft_find (fid : ident) (t : ftab) : option fsig :=
  match find (fun p => Pos.eqb (fst p) fid) t with Some (_, s) => Some s | None => None end.

Definition fit_find (ty : type) (it : fitab) : option fsig :=
  match find (fun p => proj_sumbool (type_eq (fst p) ty)) it with Some (_, s) => Some s | None => None end.

Definition f_call_sig (t : ftab) (it : fitab) (a : expr) : option fsig :=
  match CameraModeBody.direct_fid a with
  | Some fid => ft_find fid t
  | None =>
      match classify_fun (typeof a) with
      | fun_case_f targs tres cc => fit_find (Tfunction targs tres cc) it
      | _ => None
      end
  end.

Definition chunk_size_of (ty : type) : Z :=
  match access_mode ty with By_value ch => size_chunk ch | _ => 0 end.

Section CHK.
  Variable ce : composite_env.
  Variable FP : list ident.
  Variable pins : list (ident * fcls).
  Variable t : ftab.
  Variable it : fitab.
  Variable lv : list ident.
  Variable tc : ident -> fcls.

  Notation fx := (fx ce FP pins lv tc).
  Notation flv := (flv ce FP pins lv tc).

  Definition fp_set (id : ident) (a : expr) : bool := fle (fx a) (tc id).

  Definition fp_store (l r : expr) : bool :=
    MtxfBody.is_byval (typeof l) &&
    match l with
    | Evar x _ =>
        if mem_idf x lv || mem_idf x FP then true
        else match pin_of x pins with
             | Some c => fle (fx r) c &&
                 match access_mode (typeof l) with By_value Mint32 => true | _ => false end
             | None => false
             end
    | _ => fstorable (flv l) (chunk_size_of (typeof l))
    end.

  Definition fp_ret (rc : fcls) (a : expr) : bool := fle (fx a) rc.

  Definition fp_call (optid : option ident) (a : expr) (al : list expr) : bool :=
    match CameraModeBody.direct_fid a with Some fid => negb (mem_idf fid lv) | None => true end &&
    match f_call_sig t it a with
    | Some (pcs, rc) =>
        fargs_ok ce FP pins lv tc al pcs &&
        match optid with None => true | Some id => fle rc (tc id) end
    | None => false
    end.
End CHK.

(* temp-class inference *)
Definition fupd (tbl : list (ident * fcls)) (id : ident) (c : fcls) : list (ident * fcls) :=
  let old := match find (fun p => Pos.eqb (fst p) id) tbl with Some (_, d) => d | None => fN end in
  if fle c old then tbl else (id, fjoin old c) :: tbl.

Definition ftcl (l : list (ident * fcls)) (t : ident) : fcls :=
  match find (fun p => Pos.eqb (fst p) t) l with Some (_, c) => c | None => fN end.

Section INF.
  Variable ce : composite_env.
  Variable FP : list ident.
  Variable pins : list (ident * fcls).
  Variable t : ftab.
  Variable it : fitab.
  Variable lv : list ident.

  Fixpoint finf (tbl : list (ident * fcls)) (s : statement) : list (ident * fcls) :=
    match s with
    | Sset id a => fupd tbl id (fx ce FP pins lv (ftcl tbl) a)
    | Scall (Some id) a _ =>
        match f_call_sig t it a with Some (_, rc) => fupd tbl id rc | None => tbl end
    | Ssequence s1 s2 | Sifthenelse _ s1 s2 | Sloop s1 s2 => finf (finf tbl s1) s2
    | Sswitch _ sl => finf_ls tbl sl
    | _ => tbl
    end
  with finf_ls (tbl : list (ident * fcls)) (sl : labeled_statements) : list (ident * fcls) :=
    match sl with LSnil => tbl | LScons _ s sl' => finf_ls (finf tbl s) sl' end.

  Fixpoint fiter (n : nat) (tbl : list (ident * fcls)) (s : statement) : list (ident * fcls) :=
    match n with O => tbl | S n' => fiter n' (finf tbl s) s end.
End INF.

Fixpoint fzip (ids : list ident) (pcs : list fcls) : list (ident * fcls) :=
  match ids, pcs with
  | x :: ids', c :: pcs' => (x, c) :: fzip ids' pcs'
  | _, _ => nil
  end.

Fixpoint fpar_ok (tc : ident -> fcls) (ids : list ident) (pcs : list fcls) : bool :=
  match ids, pcs with
  | x :: ids', c :: pcs' => fle c (tc x) && fpar_ok tc ids' pcs'
  | _, _ => true
  end.

Definition ftc_of ce FP pins t it (pcs : list fcls) (f : Clight.function) : ident -> fcls :=
  ftcl (fiter ce FP pins t it (map fst (fn_vars f)) 10 (fzip (map fst (fn_params f)) pcs) (fn_body f)).

Definition fchk ce FP pins (t : ftab) (it : fitab) (s : fsig) (f : Clight.function) : bool :=
  let '(pcs, rc) := s in
  let lv := map fst (fn_vars f) in
  let tc := ftc_of ce FP pins t it pcs f in
  SpawnBodies.sw_chk (fp_set ce FP pins lv tc) (fp_store ce FP pins lv tc)
    (fp_call ce FP pins t it lv tc) (fp_ret ce FP pins lv tc rc) (fn_body f)
  && fpar_ok tc (map fst (fn_params f)) pcs
  && Nat.eqb (List.length (fn_params f)) (List.length pcs).

(* the member of an indirect-call type fits the type's signature: it takes
   at least the type's argument classes, returns at most its class *)
Fixpoint fle_l (l1 l2 : list fcls) : bool :=
  match l1, l2 with
  | nil, nil => true
  | c :: l1', d :: l2' => fle c d && fle_l l1' l2'
  | _, _ => false
  end.

Definition ffits (se s : fsig) : bool :=
  let '(pcs', rc') := se in let '(pcs, rc) := s in fle_l pcs pcs' && fle rc' rc.
