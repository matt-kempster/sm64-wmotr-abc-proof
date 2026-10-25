(* ====================================================================== *)
(* UcKit.v -- the class walker of CameraModeBody, made RECURSIVE and       *)
(* two-moded, for update_camera's call tree (SPINE via UpdateCameraBody).  *)
(*                                                                        *)
(* CameraModeBody walks a call DAG bottom-up (a callee's spec is proved    *)
(* before its callers).  update_camera's tree is not a DAG once the        *)
(* writable cutscene / trigger tables are covered by a type certificate:  *)
(* update_camera itself has the CameraEvent type (Camera* -> void), so    *)
(* play_cutscene's indirect call may, in an arbitrary memory, call        *)
(* update_camera again.  So here every body is checked against ONE table  *)
(* (all callees, the caller itself included), and the per-function spec   *)
(* is proved for all of them at once by mutual induction on the big-step  *)
(* derivation (ClightBigstep.exec_stmt_funcall_ind).                       *)
(*                                                                        *)
(* TWO MODES.  The clean mode (dm = false) is CameraModeBody's invariant: *)
(* the carried facts OF, nextblock >= nb0, and RL (a pointer stored in a  *)
(* block allocated since nb0 is kW).  Some leaves keep OF but say nothing *)
(* about stack blocks (save_file_do_save's OS floor may write any harm    *)
(* block, a caller's stack frame included, when memory holds a dangling  *)
(* pointer; set_mario_npc_dialog is proved by GOAL 1's engine).  A body   *)
(* that calls one is checked in the DIRTY mode (dm = true): no RL, so a  *)
(* pointer read out of a local is class kA, and any value may be stored   *)
(* into a local (a fresh block is never one MWF reads).  A dirty caller   *)
(* may call a clean callee by restarting its nb0 at the call's nextblock  *)
(* (RL is then vacuous), provided every argument's class is nb0-free     *)
(* (kN / kS / kA).  A clean caller never calls a dirty callee.            *)
(* ====================================================================== *)

From Coq Require Import ZArith List Lia Bool String.
From compcert Require Import Coqlib Maps AST Integers Values Events Memory
  Globalenvs Ctypes Cop Clightdefs Clight ClightBigstep Linking.
From SM64.Generated Require mario camera.
From SM64.Proofs Require Import SymbolicLinking ActionValueFrame Taint
  RealFrameLinked AGates CensusV2 RestSurface MWFReal SpawnInit MathBodies
  LinkedTwelve LocalVarsSurface SpawnBodies MathGeomGated.
From SM64.Proofs Require CameraModeBody MtxfBody ActWriterSurface RetSurface SaveDoSaveBody
  ObjHelpersBodies ObjExtBodies InitMemSat PrintBodies.

Import ListNotations.
Local Open Scope Z_scope.


(* ---------------------------------------------------------------------- *)
(* 0. Classes: CameraModeBody's five plus kT (SafeB or a fresh local).      *)
(*   kN  never a pointer;          kS  a SafeB block;                       *)
(*   kL  a block allocated since nb0 (a stack local);                       *)
(*   kT  kS or kL (an out cell that is a SafeB field or a caller local);    *)
(*   kW  kT or the block of a global MWF does not read;   kA  anything.    *)
(* ---------------------------------------------------------------------- *)

Inductive kcls : Type := kN | kS | kL | kT | kW | kA.

Definition kle (c d : kcls) : bool :=
  match c, d with
  | kN, _ => true
  | _, kA => true
  | kS, (kS | kT | kW) => true
  | kL, (kL | kT | kW) => true
  | kT, (kT | kW) => true
  | kW, kW => true
  | _, _ => false
  end.

Definition kjoin (c d : kcls) : kcls :=
  match c, d with
  | kN, _ => d
  | _, kN => c
  | kA, _ | _, kA => kA
  | kW, _ | _, kW => kW
  | kS, kS => kS
  | kL, kL => kL
  | _, _ => kT
  end.

Lemma kle_join_l : forall c d, kle c (kjoin c d) = true.
Proof. intros c d. destruct c, d; reflexivity. Qed.
Lemma kle_join_r : forall c d, kle d (kjoin c d) = true.
Proof. intros c d. destruct c, d; reflexivity. Qed.

Section PC.
  Variable SafeB GB : block -> Prop.
  Variable nl nb0 : block.

  Definition kpc (c : kcls) (b : block) : Prop :=
    match c with
    | kN => False
    | kS => SafeB b
    | kL => Ple nb0 b
    | kT => SafeB b \/ (Ple nl b \/ Ple nb0 b)
    | kW => SafeB b \/ (Ple nl b \/ Ple nb0 b) \/ GB b
    | kA => True
    end.

  Definition kvok (c : kcls) (v : val) : Prop :=
    forall b o, v = Vptr b o -> kpc c b.

  Lemma kle_pc : forall c d b, kle c d = true -> kpc c b -> kpc d b.
  Proof. intros c d b H. destruct c, d; cbn in *; try discriminate H; tauto. Qed.

  Lemma kle_vok : forall c d v, kle c d = true -> kvok c v -> kvok d v.
  Proof. intros c d v H Hv b o E. exact (kle_pc _ _ _ H (Hv b o E)). Qed.

  Lemma kvok_undef : forall c, kvok c Vundef.
  Proof. intros c b o E. discriminate E. Qed.

  Lemma kvok_np : forall c v, (forall b o, v <> Vptr b o) -> kvok c v.
  Proof. intros c v H b o E. exact (False_ind _ (H b o E)). Qed.
End PC.

Definition klvar (lv gs : list ident) (x : ident) : kcls :=
  if mem_id x lv then kL
  else if mem_id x gs then kS
  else if mem_id x ObjExtBodies.mwf_syms then kA
  else kW.

Definition kbinop (op : binary_operation) (c1 c2 : kcls) : kcls :=
  match op with
  | Oadd => kjoin c1 c2
  | Osub => c1
  | Omul | Odiv | Omod => kN
  | _ => if RetSurface.vint_binop op then kN else kA
  end.

Notation never_ptr_binop := CameraModeBody.never_ptr_binop.
Notation never_ptr_binop_sound := CameraModeBody.never_ptr_binop_sound.
Notation direct_fid := CameraModeBody.direct_fid.
Notation direct_fid_inv := CameraModeBody.direct_fid_inv.

Definition ktcl (l : list (ident * kcls)) (dflt : kcls) (t : ident) : kcls :=
  match find (fun p => Pos.eqb (fst p) t) l with
  | Some (_, c) => c
  | None => dflt
  end.

Definition kupd (tbl : list (ident * kcls)) (id : ident) (c : kcls) : list (ident * kcls) :=
  if kle c (ktcl tbl kN id) then tbl else (id, kjoin (ktcl tbl kN id) c) :: tbl.

Fixpoint kzip (ids : list ident) (pcs : list kcls) : list (ident * kcls) :=
  match ids, pcs with
  | x :: ids', c :: pcs' => (x, c) :: kzip ids' pcs'
  | _, _ => nil
  end.

Fixpoint kpar_ok (tc : ident -> kcls) (ids : list ident) (pcs : list kcls) : bool :=
  match ids, pcs with
  | x :: ids', c :: pcs' => kle c (tc x) && kpar_ok tc ids' pcs'
  | _, _ => true
  end.

Lemma kpar_ok_nth : forall tc ids pcs i x c,
    kpar_ok tc ids pcs = true -> nth_error ids i = Some x -> nth_error pcs i = Some c ->
    kle c (tc x) = true.
Proof.
  intros tc ids. induction ids as [| y ids IH]; intros pcs i x c H Hx Hc;
    [ destruct i; discriminate Hx | ].
  destruct pcs as [| c' pcs]; [ destruct i; discriminate Hc | ].
  cbn [kpar_ok] in H. apply andb_prop in H as [H1 H2].
  destruct i as [| i]; cbn in Hx, Hc.
  - injection Hx as <-. injection Hc as <-. exact H1.
  - exact (IH _ _ _ _ H2 Hx Hc).
Qed.

(* ---------------------------------------------------------------------- *)
(* 1. The mode-aware classifier.                                            *)
(* ---------------------------------------------------------------------- *)

Definition krvd (dm : bool) (ty : type) (c : kcls) : kcls :=
  match access_mode ty with
  | By_value Mint32 =>
      match c with kN | kS => kS | kL => if dm then kA else kW | _ => kA end
  | By_value Many32 | By_value Many64 => kA
  | By_value _ => kN
  | By_reference | By_copy => c
  | By_nothing => kN
  end.

Section KXD.
  Variable dm : bool.
  Variables lv gs : list ident.
  Variable tc : ident -> kcls.

  Fixpoint kxd (a : expr) : kcls :=
    match a with
    | Econst_int _ _ | Econst_float _ _ | Econst_single _ _ | Econst_long _ _ => kN
    | Esizeof _ _ | Ealignof _ _ => kN
    | Etempvar t _ => tc t
    | Eunop _ _ _ => kN
    | Ecast a1 _ => kxd a1
    | Ebinop op a1 a2 _ =>
        if never_ptr_binop op (typeof a1) (typeof a2) then kN
        else kbinop op (kxd a1) (kxd a2)
    | Evar x ty => krvd dm ty (klvar lv gs x)
    | Ederef a1 ty => krvd dm ty (kxd a1)
    | Efield a1 _ ty => krvd dm ty (kxd a1)
    | Eaddrof a1 _ =>
        match a1 with
        | Evar x _ => klvar lv gs x
        | Ederef a2 _ | Efield a2 _ _ => kxd a2
        | _ => kA
        end
    end.

  Definition klvd (a : expr) : kcls :=
    match a with
    | Evar x _ => klvar lv gs x
    | Ederef a1 _ | Efield a1 _ _ => kxd a1
    | _ => kA
    end.

  Fixpoint kargs_okd (al : list expr) (pcs : list kcls) : bool :=
    match al, pcs with
    | nil, nil => true
    | a :: al', c :: pcs' => kle (kxd a) c && kargs_okd al' pcs'
    | _, _ => false
    end.
End KXD.

(* ---------------------------------------------------------------------- *)
(* 2. Signatures, tables, the per-statement recognizers.                    *)
(* ---------------------------------------------------------------------- *)

(* (parameter classes, return class, dirty?) *)
Definition usig : Type := (list kcls * kcls * bool)%type.
Definition utab := list (ident * usig).
Definition uitab := list (type * usig).

Definition ut_find (fid : ident) (ut : utab) : option usig :=
  match find (fun p => Pos.eqb (fst p) fid) ut with
  | Some (_, s) => Some s
  | None => None
  end.

Definition uit_find (ty : type) (it : uitab) : option usig :=
  match find (fun p => proj_sumbool (type_eq (fst p) ty)) it with
  | Some (_, s) => Some s
  | None => None
  end.

Definition u_call_sig (ut : utab) (it : uitab) (a : expr) : option usig :=
  match direct_fid a with
  | Some fid => ut_find fid ut
  | None =>
      match classify_fun (typeof a) with
      | fun_case_f targs tres cc => uit_find (Tfunction targs tres cc) it
      | _ => None
      end
  end.

(* a class whose meaning does not depend on nb0 *)
Definition kfree (c : kcls) : bool :=
  match c with kL => false | _ => true end.

(* mode compatibility of a call: caller mode dm, callee mode dme *)
Definition mode_ok (dm dme : bool) (pcs : list kcls) : bool :=
  if dm then (dme || forallb kfree pcs) else negb dme.

Definition kp_setd dm lv gs tc (id : ident) (a : expr) : bool :=
  kle (kxd dm lv gs tc a) (tc id).
Definition kp_stored dm lv gs tc (l r : expr) : bool :=
  MtxfBody.is_byval (typeof l) &&
  match klvd dm lv gs tc l with
  | kS => kle (kxd dm lv gs tc r) kS || nonptr_scalar (typeof l)
  | kL => dm || kle (kxd dm lv gs tc r) kW || nonptr_scalar (typeof l)
  | kT => kle (kxd dm lv gs tc r) kS || nonptr_scalar (typeof l)
  | kW => kle (kxd dm lv gs tc r) kN || nonptr_scalar (typeof l)
  | _ => false
  end.
Definition kp_retd dm lv gs tc (rc : kcls) (a : expr) : bool :=
  kle (kxd dm lv gs tc a) rc.
Definition kp_calld dm lv gs tc (ut : utab) (it : uitab)
    (optid : option ident) (a : expr) (al : list expr) : bool :=
  match direct_fid a with Some fid => negb (mem_id fid lv) | None => true end &&
  match u_call_sig ut it a with
  | Some (pcs, rc, dme) =>
      kargs_okd dm lv gs tc al pcs && mode_ok dm dme pcs &&
      match optid with None => true | Some id => kle rc (tc id) end
  | None => false
  end.

(* temp-class inference *)
Fixpoint kinfd dm (lv gs : list ident) (ut : utab) (it : uitab)
    (tbl : list (ident * kcls)) (s : statement) : list (ident * kcls) :=
  match s with
  | Sset id a => kupd tbl id (kxd dm lv gs (ktcl tbl kN) a)
  | Scall (Some id) a _ =>
      match u_call_sig ut it a with Some (_, rc, _) => kupd tbl id rc | None => tbl end
  | Ssequence s1 s2 | Sifthenelse _ s1 s2 | Sloop s1 s2 =>
      kinfd dm lv gs ut it (kinfd dm lv gs ut it tbl s1) s2
  | Sswitch _ sl => kinfd_ls dm lv gs ut it tbl sl
  | _ => tbl
  end
with kinfd_ls dm (lv gs : list ident) (ut : utab) (it : uitab)
    (tbl : list (ident * kcls)) (sl : labeled_statements) : list (ident * kcls) :=
  match sl with
  | LSnil => tbl
  | LScons _ s sl' => kinfd_ls dm lv gs ut it (kinfd dm lv gs ut it tbl s) sl'
  end.

Fixpoint kiterd dm (n : nat) (lv gs : list ident) (ut : utab) (it : uitab)
    (tbl : list (ident * kcls)) (s : statement) : list (ident * kcls) :=
  match n with
  | O => tbl
  | S n' => kiterd dm n' lv gs ut it (kinfd dm lv gs ut it tbl s) s
  end.

Definition utc_of dm (gs : list ident) (ut : utab) (it : uitab) (pcs : list kcls)
    (f : Clight.function) : ident -> kcls :=
  ktcl (kiterd dm 8 (map fst (fn_vars f)) gs ut it (kzip (map fst (fn_params f)) pcs) (fn_body f)) kN.

Definition uchk_tc dm (gs : list ident) (tc : ident -> kcls) (ut : utab) (it : uitab)
    (pcs : list kcls) (rc : kcls) (f : Clight.function) : bool :=
  let lv := map fst (fn_vars f) in
  sw_chk (kp_setd dm lv gs tc) (kp_stored dm lv gs tc) (kp_calld dm lv gs tc ut it)
    (kp_retd dm lv gs tc rc) (fn_body f)
  && kpar_ok tc (map fst (fn_params f)) pcs.

Definition uchk (gs : list ident) (ut : utab) (it : uitab) (s : usig) (f : Clight.function) : bool :=
  let '(pcs, rc, dm) := s in
  uchk_tc dm gs (utc_of dm gs ut it pcs f) ut it pcs rc f.

(* the member of an indirect-call type fits the type's signature *)
Definition kcls_eqb (c d : kcls) : bool := kle c d && kle d c.
Fixpoint kcls_leq (l1 l2 : list kcls) : bool :=
  match l1, l2 with
  | nil, nil => true
  | c :: l1', d :: l2' => kcls_eqb c d && kcls_leq l1' l2'
  | _, _ => false
  end.
Definition fitsb (se s : usig) : bool :=
  let '(pcs', rc', dm') := se in
  let '(pcs, rc, dm) := s in
  kcls_leq pcs' pcs && kle rc' rc &&
  (if dm' then dm else (negb dm || forallb kfree pcs)).

Lemma kcls_eqb_eq : forall c d, kcls_eqb c d = true -> c = d.
Proof. intros c d H. destruct c, d; try reflexivity; discriminate H. Qed.

Lemma kcls_leq_eq : forall l1 l2, kcls_leq l1 l2 = true -> l1 = l2.
Proof.
  induction l1 as [| c l1 IH]; intros [| d l2] H; try discriminate H; [ reflexivity | ].
  cbn [kcls_leq] in H. apply andb_prop in H as [H1 H2].
  rewrite (kcls_eqb_eq _ _ H1), (IH _ H2). reflexivity.
Qed.

(* ---------------------------------------------------------------------- *)
(* 3. Soundness of the classifier (mode-aware).                             *)
(* ---------------------------------------------------------------------- *)

Section KXDS.
  Variable ge : genv.
  Variable e : env.
  Variable le : temp_env.
  Variable m : mem.
  Variable SafeB : block -> Prop.
  Variable nl nb0 : block.
  Variable dm : bool.
  Variables lv gs : list ident.
  Variable tc : ident -> kcls.

  Let GB (b : block) : Prop :=
    exists g, Genv.find_symbol ge g = Some b /\ mem_id g ObjExtBodies.mwf_syms = false.

  Hypothesis Hle : forall t v, le ! t = Some v -> kvok SafeB GB nl nb0 (tc t) v.
  Hypothesis He : forall x b ty, e ! x = Some (b, ty) -> mem_id x lv = true /\ Ple nb0 b.
  Hypothesis He2 : forall x, mem_id x lv = true -> e ! x <> None.
  Hypothesis Hgs : forall x b, mem_id x gs = true -> Genv.find_symbol ge x = Some b -> SafeB b.
  Hypothesis R7 : forall b ofs b' o', SafeB b ->
      Mem.loadv Mint32 m (Vptr b ofs) = Some (Vptr b' o') -> SafeB b'.
  Hypothesis RL : dm = false -> forall b ofs b' o', Ple nb0 b ->
      Mem.load Mint32 m b ofs = Some (Vptr b' o') -> kpc SafeB GB nl nb0 kW b'.

  Lemma kderefd_cls : forall ty loc ofs bf v c,
      deref_loc ty m loc ofs bf v -> kpc SafeB GB nl nb0 c loc ->
      kvok SafeB GB nl nb0 (krvd dm ty c) v.
  Proof.
    intros ty loc ofs bf v c Hd Hc b o Ev. subst v.
    inv Hd.
    - match goal with Ha : access_mode _ = By_value ?ch, Hl : Mem.loadv ?ch _ _ = Some _ |- _ =>
        pose proof Hl as Hl'; cbn in Hl';
        destruct (load_vptr_chunk _ _ _ _ _ _ Hl') as [E | [E | E]]; subst ch;
        unfold krvd; rewrite Ha end.
      + destruct c; cbn in Hc |- *.
        * contradiction Hc.
        * eapply R7; eassumption.
        * destruct dm; [ exact I | ]. eapply RL; [ reflexivity | eassumption | eassumption ].
        * exact I.
        * exact I.
        * exact I.
      + exact I.
      + exact I.
    - match goal with Ha : access_mode _ = By_reference |- _ => unfold krvd; rewrite Ha; exact Hc end.
    - match goal with Ha : access_mode _ = By_copy |- _ => unfold krvd; rewrite Ha; exact Hc end.
    - match goal with Hl : load_bitfield _ _ _ _ _ _ _ _ |- _ => inv Hl end.
  Qed.

  Lemma kxd_sound_mut :
    (forall a v, eval_expr ge e le m a v -> kvok SafeB GB nl nb0 (kxd dm lv gs tc a) v) /\
    (forall a b o bf, eval_lvalue ge e le m a b o bf -> kpc SafeB GB nl nb0 (klvd dm lv gs tc a) b).
  Proof.
    apply (eval_expr_lvalue_ind ge e le m
             (fun a v => kvok SafeB GB nl nb0 (kxd dm lv gs tc a) v)
             (fun a b o bf => kpc SafeB GB nl nb0 (klvd dm lv gs tc a) b));
      intros; cbv beta in *.
    - intros bb oo E; discriminate E.
    - intros bb oo E; discriminate E.
    - intros bb oo E; discriminate E.
    - intros bb oo E; discriminate E.
    - cbn [kxd]. eapply Hle; eassumption.
    - intros bb oo E. injection E as <- <-.
      destruct a; cbn [klvd] in *; cbn [kxd]; first [ exact I | assumption ].
    - intros bb oo E. subst. exfalso.
      eapply ActWriterSurface.sem_unop_nonptr; [ eassumption | reflexivity ].
    - intros bb oo E. subst. cbn [kxd].
      match goal with |- context [if never_ptr_binop ?o ?x ?y then _ else _] =>
        destruct (never_ptr_binop o x y) eqn:Enp;
        [ exfalso; eapply never_ptr_binop_sound; eassumption | ] end.
      match goal with
      | Hs : sem_binary_operation _ ?op ?v1 _ ?v2 _ _ = Some _,
        IH1 : kvok _ _ _ _ _ ?v1, IH2 : kvok _ _ _ _ _ ?v2 |- _ =>
        pose proof Hs as Hs0;
        destruct op; cbn [kbinop]; cbn [sem_binary_operation] in Hs;
        [ destruct (SaveDoSaveBody.sem_add_vptr_src _ _ _ _ _ _ _ _ Hs) as [(o1 & E1) | (o2 & E2)];
          [ exact (kle_pc _ _ _ _ _ _ _ (kle_join_l _ _) (IH1 _ _ E1))
          | exact (kle_pc _ _ _ _ _ _ _ (kle_join_r _ _) (IH2 _ _ E2)) ]
        | destruct (SaveDoSaveBody.sem_sub_vptr_src _ _ _ _ _ _ _ _ Hs) as (o1 & E1);
          exact (IH1 _ _ E1)
        | exact (False_ind _ (ActWriterSurface.sem_mul_nonptr _ _ _ _ _ _ Hs _ _ eq_refl))
        | exact (False_ind _ (ActWriterSurface.sem_div_nonptr _ _ _ _ _ _ Hs _ _ eq_refl))
        | exact (False_ind _ (ActWriterSurface.sem_mod_nonptr _ _ _ _ _ _ Hs _ _ eq_refl))
        | (exfalso; refine (vint_binop_sound _ _ _ _ _ _ _ _ _ Hs0 _ _ eq_refl); reflexivity) .. ]
      end.
    - intros bb oo E. subst. cbn [kxd].
      match goal with Hc : sem_cast ?v1 _ _ _ = Some _, IH : kvok _ _ _ _ _ ?v1 |- _ =>
        exact (IH _ _ (sem_cast_vptr_inv _ _ _ _ _ _ Hc)) end.
    - intros bb oo E. unfold Vptrofs in E. destruct Archi.ptr64; discriminate E.
    - intros bb oo E. unfold Vptrofs in E. destruct Archi.ptr64; discriminate E.
    - destruct a;
        try (match goal with Hl : eval_lvalue _ _ _ _ _ _ _ _ |- _ => inv Hl end; fail);
        cbn [kxd klvd typeof] in *; eapply kderefd_cls; eassumption.
    - cbn [klvd]. unfold klvar. destruct (He _ _ _ H) as (-> & Hb). exact Hb.
    - cbn [klvd]. unfold klvar.
      destruct (mem_id id lv) eqn:El; [ exact (False_ind _ (He2 _ El H)) | ].
      destruct (mem_id id gs) eqn:Eg; [ exact (Hgs _ _ Eg H0) | ].
      destruct (mem_id id ObjExtBodies.mwf_syms) eqn:Em; [ exact I | ].
      cbn [kpc]. right. right. exists id. split; [ exact H0 | exact Em ].
    - cbn [klvd]. match goal with IH : kvok _ _ _ _ _ (Vptr ?l _) |- _ => exact (IH _ _ eq_refl) end.
    - cbn [klvd]. match goal with IH : kvok _ _ _ _ _ (Vptr ?l _) |- _ => exact (IH _ _ eq_refl) end.
    - cbn [klvd]. match goal with IH : kvok _ _ _ _ _ (Vptr ?l _) |- _ => exact (IH _ _ eq_refl) end.
  Qed.

  Lemma kxd_sound : forall a v, eval_expr ge e le m a v -> kvok SafeB GB nl nb0 (kxd dm lv gs tc a) v.
  Proof. exact (proj1 kxd_sound_mut). Qed.

  Lemma klvd_sound : forall a b o bf, eval_lvalue ge e le m a b o bf ->
      kpc SafeB GB nl nb0 (klvd dm lv gs tc a) b.
  Proof. exact (proj2 kxd_sound_mut). Qed.

  Lemma kargsd_sound : forall al tyl vl, eval_exprlist ge e le m al tyl vl ->
      forall pcs, kargs_okd dm lv gs tc al pcs = true -> Forall2 (kvok SafeB GB nl nb0) pcs vl.
  Proof.
    intros al tyl vl Hel. induction Hel; intros pcs Hok;
      destruct pcs as [| c pcs]; cbn [kargs_okd] in Hok; try discriminate Hok; [ constructor | ].
    apply andb_prop in Hok as [H1 H2].
    constructor; [ | exact (IHHel _ H2) ].
    intros bb oo E. subst.
    match goal with Hc : sem_cast ?v1 _ _ _ = Some (Vptr bb oo),
                    Hx : eval_expr _ _ _ _ ?a ?v1 |- _ =>
      exact (kle_pc _ _ _ _ _ _ _ H1 (kxd_sound _ _ Hx _ _ (sem_cast_vptr_inv _ _ _ _ _ _ Hc))) end.
  Qed.
End KXDS.

(* the nb0-dependence of the classes *)
Lemma kpc_mono : forall SafeB GB nl nb0 nb1 c b,
    Ple nb0 nb1 -> kpc SafeB GB nl nb1 c b -> kpc SafeB GB nl nb0 c b.
Proof.
  intros SafeB GB nl nb0 nb1 c b Hle H. destruct c; cbn in *; try tauto.
  - eapply Ple_trans; eassumption.
  - destruct H as [H | [H | H]]; [ left; exact H | right; left; exact H
                                 | right; right; eapply Ple_trans; eassumption ].
  - destruct H as [H | [[H | H] | H]]; [ left; exact H | right; left; left; exact H
                                       | right; left; right; eapply Ple_trans; eassumption
                                       | right; right; exact H ].
Qed.

Lemma kvok_mono : forall SafeB GB nl nb0 nb1 c v,
    Ple nb0 nb1 -> kvok SafeB GB nl nb1 c v -> kvok SafeB GB nl nb0 c v.
Proof. intros SafeB GB nl nb0 nb1 c v Hle H b o E. exact (kpc_mono _ _ _ _ _ _ _ Hle (H b o E)). Qed.

Lemma kvok_free : forall SafeB GB nl nb0 nb1 c v, Ple nl nb0 ->
    kfree c = true -> kvok SafeB GB nl nb0 c v -> kvok SafeB GB nl nb1 c v.
Proof.
  intros SafeB GB nl nb0 nb1 c v Hl Hf H b o E. specialize (H b o E).
  destruct c; cbn in *; try discriminate Hf; try exact H.
  - destruct H as [H | [H | H]]; [ left; exact H | right; left; exact H
                                 | right; left; eapply Ple_trans; eassumption ].
  - destruct H as [H | [[H | H] | H]]; [ left; exact H | right; left; left; exact H
                                       | right; left; left; eapply Ple_trans; eassumption
                                       | right; right; exact H ].
Qed.

Lemma forall2_kvok_free : forall SafeB GB nl nb0 nb1 pcs vs, Ple nl nb0 ->
    forallb kfree pcs = true -> Forall2 (kvok SafeB GB nl nb0) pcs vs ->
    Forall2 (kvok SafeB GB nl nb1) pcs vs.
Proof.
  intros SafeB GB nl nb0 nb1 pcs vs Hl Hf H. induction H; [ constructor | ].
  cbn [forallb] in Hf. apply andb_prop in Hf as [H1 H2].
  constructor; [ exact (kvok_free _ _ _ _ _ _ _ Hl H1 H) | exact (IHForall2 H2) ].
Qed.

(* ---------------------------------------------------------------------- *)
(* 4. The carried invariant at the concrete MWF_real.                       *)
(* ---------------------------------------------------------------------- *)

Section UK.
  Variable lp : Clight.program.
  Hypothesis H12 : linked12 lp.
  Variables bm bc : block.
  Variable oc0 : ptrofs.
  Variable SafeB : block -> Prop.
  Hypothesis HSafeB_syms : SafeB_syms_ok lp SafeB.
  Hypothesis Hspawn : exists init, spawn_ok lp init bm bc oc0.

  Let ge := lp_ge lp.
  Let MWF := MWF_real lp bm bc oc0 SafeB.
  Let OF := ow_facts bm MWF.

  Definition GBu (b : block) : Prop :=
    exists g, Genv.find_symbol ge g = Some b /\ mem_id g ObjExtBodies.mwf_syms = false.

  (* nl lies above every block that exists before the walk; it is fixed for
     the whole induction (the outermost call's nextblock).  nb0 >= nl is the
     moving RL threshold: a dirty caller restarts it at a clean call. *)
  Definition HnB (nb0 : block) : Prop :=
    Plt bm nb0 /\ (forall b, SafeB b -> Plt b nb0) /\
    (forall gid bg, Genv.find_symbol ge gid = Some bg -> Plt bg nb0).

  Variable nl : block.
  Hypothesis HNL : HnB nl.

  Definition Hn (nb0 : block) : Prop := Ple nl nb0.

  Definition upc (nb0 : block) := kpc SafeB GBu nl nb0.
  Definition uvok (nb0 : block) := kvok SafeB GBu nl nb0.

  Lemma hn_base : forall nb0, Hn nb0 -> HnB nb0.
  Proof.
    intros nb0 Hle. destruct HNL as (H1 & H2 & H3).
    split; [ exact (Plt_Ple_trans _ _ _ H1 Hle) | split ].
    - intros b Hb. exact (Plt_Ple_trans _ _ _ (H2 _ Hb) Hle).
    - intros gid bg Hg. exact (Plt_Ple_trans _ _ _ (H3 _ _ Hg) Hle).
  Qed.

  Definition RLu (nb0 : block) (m : mem) : Prop :=
    forall b ofs b' o', Ple nb0 b -> Mem.load Mint32 m b ofs = Some (Vptr b' o') -> upc nb0 kW b'.

  Definition UInv (dm : bool) (nb0 : block) (m : mem) : Prop :=
    OF m /\ Ple nb0 (Mem.nextblock m) /\ (dm = false -> RLu nb0 m).

  Lemma uk_not_bm : forall b, SafeB b -> b <> bm.
  Proof. destruct Hspawn as (init & Hs). exact (safeb_not_bm lp init bm bc oc0 SafeB Hs HSafeB_syms). Qed.
  Lemma uk_Hbc_bm : bc <> bm.
  Proof. destruct Hspawn as (init & Hs). exact (spawn_Hbc_bm lp init bm bc oc0 Hs). Qed.

  Lemma ufresh_ne : forall nb0 b b', Ple nb0 b -> Plt b' nb0 -> b <> b'.
  Proof. intros nb0 b b' H1 H2 E. subst. exact (Plt_strict _ (Plt_Ple_trans _ _ _ H2 H1)). Qed.

  Section NB.
    Variable nb0 : block.
    Hypothesis HN : Hn nb0.

    Let pc := upc nb0.
    Let vok := uvok nb0.

    Lemma u_rl_other : forall ch m b z v m',
        Plt b nb0 -> Mem.store ch m b z v = Some m' -> RLu nb0 m -> RLu nb0 m'.
    Proof.
      intros ch m b z v m' Hb Hst HL b1 ofs b' o' Hb1 Hld.
      rewrite (Mem.load_store_other _ _ _ _ _ _ Hst) in Hld.
      - exact (HL _ _ _ _ Hb1 Hld).
      - left. exact (ufresh_ne _ _ _ Hb1 Hb).
    Qed.

    Lemma u_rl_np : forall ch m b z v m',
        (forall bb oo, v <> Vptr bb oo) -> Mem.store ch m b z v = Some m' -> RLu nb0 m -> RLu nb0 m'.
    Proof.
      intros ch m b z v m' Hnp Hst HL b1 ofs b' o' Hb1 Hld.
      destruct (Mem.load_pointer_store _ _ _ _ _ _ _ _ _ _ _ Hst Hld)
        as [(Ev & _ & _ & _) | Hdis].
      - exact (False_ind _ (Hnp _ _ Ev)).
      - rewrite (Mem.load_store_other _ _ _ _ _ _ Hst _ _ _ Hdis) in Hld.
        exact (HL _ _ _ _ Hb1 Hld).
    Qed.

    Lemma u_store_safe : forall dm ch m b z v m', SafeB b -> safev SafeB v ->
        Mem.store ch m b z v = Some m' -> UInv dm nb0 m -> UInv dm nb0 m'.
    Proof.
      intros dm ch m b z v m' Hs Hv Hst (Hf & Hnb & HL).
      destruct (hn_base _ HN) as (_ & Hn_safe & _).
      split; [ | split ].
      - exact (sb_safe_store lp bm bc oc0 SafeB HSafeB_syms Hspawn b ch z v m m' Hs Hv Hst Hf).
      - rewrite (Mem.nextblock_store _ _ _ _ _ _ Hst). exact Hnb.
      - intros Hd. exact (u_rl_other _ _ _ _ _ _ (Hn_safe _ Hs) Hst (HL Hd)).
    Qed.

    (* a store into a block allocated since nb0: any value keeps OF *)
    Lemma u_local_of : forall ch m b z v m', Ple nl b ->
        Mem.store ch m b z v = Some m' -> OF m -> OF m'.
    Proof.
      intros ch m b z v m' Hb Hst (Hvb & Hsat & HM).
      destruct HNL as (Hn_bm & Hn_safe & Hn_glob).
      split; [ eauto using Mem.store_valid_block_1 | split ].
      - eapply action_sat_unchanged_on with (m := m); [ | exact Hvb | exact Hsat ].
        eapply Mem.store_unchanged_on; [ exact Hst | ].
        intros i _ [Hb' _]. exact (ufresh_ne _ _ _ Hb Hn_bm Hb').
      - destruct Hspawn as (init & Hsp).
        destruct (spawn_Hbc_sym lp init bm bc oc0 Hsp) as (gid & Hsy).
        eapply mwf_real_local_store; [ exact uk_Hbc_bm | exact HM | | | | | exact Hst ].
        + exact (ufresh_ne _ _ _ Hb Hn_bm).
        + exact (ufresh_ne _ _ _ Hb (Hn_glob _ _ Hsy)).
        + intros Hs. exact (ufresh_ne _ _ _ Hb (Hn_safe _ Hs) eq_refl).
        + intros gid' bg Hg. exact (ufresh_ne _ _ _ Hb (Hn_glob _ _ Hg)).
    Qed.

    Lemma u_store_local : forall dm ch m b z v m', Ple nb0 b -> (dm = false -> vok kW v) ->
        Mem.store ch m b z v = Some m' -> UInv dm nb0 m -> UInv dm nb0 m'.
    Proof.
      intros dm ch m b z v m' Hb Hv Hst (Hf & Hnb & HL).
      split; [ exact (u_local_of _ _ _ _ _ _ (Ple_trans _ _ _ HN Hb) Hst Hf) | split ].
      - rewrite (Mem.nextblock_store _ _ _ _ _ _ Hst). exact Hnb.
      - intros Hd b1 ofs b' o' Hb1 Hld.
        destruct (Mem.load_pointer_store _ _ _ _ _ _ _ _ _ _ _ Hst Hld)
          as [(Ev & _ & _ & _) | Hdis].
        + exact (Hv Hd _ _ Ev).
        + rewrite (Mem.load_store_other _ _ _ _ _ _ Hst _ _ _ Hdis) in Hld.
          exact (HL Hd _ _ _ _ Hb1 Hld).
    Qed.

    Lemma u_store_glob : forall dm ch m b z v m', GBu b ->
        (forall bb oo, v <> Vptr bb oo) ->
        Mem.store ch m b z v = Some m' -> UInv dm nb0 m -> UInv dm nb0 m'.
    Proof.
      intros dm ch m b z v m' (g & Hg & Hng) Hnp Hst (Hf & Hnb & HL).
      split; [ | split ].
      - exact (ObjExtBodies.np_store_pres lp bm bc oc0 SafeB Hspawn g b ch z v m m' Hng Hg Hnp Hst Hf).
      - rewrite (Mem.nextblock_store _ _ _ _ _ _ Hst). exact Hnb.
      - intros Hd. exact (u_rl_np _ _ _ _ _ _ Hnp Hst (HL Hd)).
    Qed.

    Lemma u_store_w : forall dm ch m b z v m', pc kW b ->
        (forall bb oo, v <> Vptr bb oo) ->
        Mem.store ch m b z v = Some m' -> UInv dm nb0 m -> UInv dm nb0 m'.
    Proof.
      intros dm ch m b z v m' Hb Hnp Hst Hi.
      destruct Hb as [Hs | [Hl | Hg]].
      - refine (u_store_safe _ _ _ _ _ _ _ Hs _ Hst Hi). intros bb oo E. exact (False_ind _ (Hnp _ _ E)).
      - assert (Hl' : Ple nl b) by (destruct Hl as [Hl | Hl]; [ exact Hl | exact (Ple_trans _ _ _ HN Hl) ]).
        destruct Hi as (Hf & Hnb & HL).
        split; [ exact (u_local_of _ _ _ _ _ _ Hl' Hst Hf) | split ].
        + rewrite (Mem.nextblock_store _ _ _ _ _ _ Hst). exact Hnb.
        + intros Hd. exact (u_rl_np _ _ _ _ _ _ Hnp Hst (HL Hd)).
      - exact (u_store_glob _ _ _ _ _ _ _ Hg Hnp Hst Hi).
    Qed.

    (* entry: the frame's allocations *)
    Lemma u_av : forall e0 m vars e m1,
        alloc_variables ge e0 m vars e m1 ->
        (forall x b ty, e0 ! x = Some (b, ty) -> Ple nb0 b) ->
        Ple nb0 (Mem.nextblock m) ->
        Ple nb0 (Mem.nextblock m1) /\
        (forall x b ty, e ! x = Some (b, ty) -> Ple nb0 b) /\
        (RLu nb0 m -> RLu nb0 m1).
    Proof.
      intros e0 m vars e m1 Hav.
      induction Hav as [e0 m0 | e0 m0 id ty vars0 m1 b1 m2 e2 Hal Hrest IH];
        intros He0 Hnb; [ auto | ].
      destruct IH as (IH1 & IH2 & IH3).
      - intros x b ty' Hx. destruct (peq x id) as [-> | Hne].
        + rewrite PTree.gss in Hx. injection Hx as <- _.
          rewrite (Mem.alloc_result _ _ _ _ _ Hal). exact Hnb.
        + rewrite PTree.gso in Hx by exact Hne. exact (He0 _ _ _ Hx).
      - rewrite (Mem.nextblock_alloc _ _ _ _ _ Hal). eapply Ple_trans; [ exact Hnb | apply Ple_succ ].
      - split; [ exact IH1 | split; [ exact IH2 | ] ].
        intros HL. apply IH3.
        intros b ofs b' o' Hb Hld.
        destruct (peq b b1) as [-> | Hne].
        + pose proof (Mem.load_alloc_same _ _ _ _ _ Hal _ _ _ Hld) as E. discriminate E.
        + assert (Hv : Mem.valid_block m0 b).
          { destruct (Mem.valid_block_alloc_inv _ _ _ _ _ Hal _ (PrintBodies.load_valid _ _ _ _ _ Hld))
              as [E | Hv]; [ congruence | exact Hv ]. }
          rewrite (Mem.load_alloc_unchanged _ _ _ _ _ Hal _ _ _ Hv) in Hld.
          exact (HL _ _ _ _ Hb Hld).
    Qed.

    Lemma u_free : forall l m m',
        Mem.free_list m l = Some m' ->
        Ple nb0 (Mem.nextblock m) ->
        Ple nb0 (Mem.nextblock m') /\ (RLu nb0 m -> RLu nb0 m').
    Proof.
      intros l m m' Hfl Hnb. split.
      - revert m Hfl Hnb. induction l as [| [[b lo] hi] l IH]; intros m Hfl Hnb.
        + cbn in Hfl. injection Hfl as <-. exact Hnb.
        + cbn in Hfl. destruct (Mem.free m b lo hi) as [m1|] eqn:Hf; [ | discriminate Hfl ].
          apply (IH m1 Hfl). rewrite (Mem.nextblock_free _ _ _ _ _ Hf). exact Hnb.
      - intros HL b ofs b' o' Hb Hld.
        exact (HL _ _ _ _ Hb (free_list_load_2 _ _ _ Hfl _ _ _ _ Hld)).
    Qed.
  End NB.

  Lemma u_R7 : forall m, OF m -> forall b ofs b' o', SafeB b ->
      Mem.loadv Mint32 m (Vptr b ofs) = Some (Vptr b' o') -> SafeB b'.
  Proof.
    intros m (_ & _ & HM) b ofs b' o' Hs Hld.
    exact (mwf_real_chase_step lp bm bc oc0 SafeB m b ofs b' o' HM Hs Hld).
  Qed.

  (* ---------------------------------------------------------------------- *)
  (* 5. The specs, and the mutual induction.                                 *)
  (* ---------------------------------------------------------------------- *)

  (* the semantic per-function spec *)
  Definition uspec (fd : Clight.fundef) (s : usig) : Prop :=
    let '(pcs, rc, dm) := s in
    forall nb0, Hn nb0 ->
    forall m vargs t m' vres,
      eval_funcall function_entry2 ge m fd vargs t m' vres ->
      Forall2 (uvok nb0) pcs vargs -> UInv dm nb0 m -> UInv dm nb0 m' /\ uvok nb0 rc vres.

  Variable gs : list ident.
  Hypothesis Hgs : forall x b, mem_id x gs = true -> Genv.find_symbol ge x = Some b -> SafeB b.
  Variable ut : utab.
  Variable it : uitab.
  (* the leaves proved outside the walk *)
  Variable Leaf : Clight.fundef -> usig -> Prop.
  Hypothesis HLeaf : forall fd s, Leaf fd s -> uspec fd s.

  Definition Good (fd : Clight.fundef) (s : usig) : Prop :=
    (exists f, fd = Internal f /\ uchk gs ut it s f = true) \/ Leaf fd s.

  Definition TabGood : Prop :=
    forall fid s, ut_find fid ut = Some s ->
      forall b fd, Genv.find_symbol ge fid = Some b ->
        Genv.find_funct ge (Vptr b Ptrofs.zero) = Some fd -> Good fd s.

  Definition ItGood : Prop :=
    forall ty s, uit_find ty it = Some s ->
      forall vf fd, Genv.find_funct ge vf = Some fd -> type_of_fundef fd = ty ->
        exists se, Good fd se /\ fitsb se s = true.

  Hypothesis HTab : TabGood.
  Hypothesis HIt : ItGood.

  Definition KTPu (nb0 : block) (tc : ident -> kcls) (le : temp_env) : Prop :=
    forall t v, le ! t = Some v -> uvok nb0 (tc t) v.

  Definition KEILu (nb0 : block) (lv : list ident) (e : env) : Prop :=
    (forall x b ty, e ! x = Some (b, ty) -> mem_id x lv = true /\ Ple nb0 b)
    /\ (forall x, mem_id x lv = true -> e ! x <> None).

  Definition uout_ok (nb0 : block) (rc : kcls) (out : outcome) : Prop :=
    match out with
    | Out_return (Some (v, _)) => uvok nb0 rc v
    | _ => True
    end.

  Definition Pstmt (e : env) (le : temp_env) (m : mem) (s : statement) (t : trace)
      (le' : temp_env) (m' : mem) (out : outcome) : Prop :=
    exec_stmt function_entry2 ge e le m s t le' m' out /\
    forall dm nb0 lv tc rc, Hn nb0 -> KEILu nb0 lv e ->
      sw_chk (kp_setd dm lv gs tc) (kp_stored dm lv gs tc) (kp_calld dm lv gs tc ut it)
        (kp_retd dm lv gs tc rc) s = true ->
      KTPu nb0 tc le -> UInv dm nb0 m ->
      UInv dm nb0 m' /\ KTPu nb0 tc le' /\ uout_ok nb0 rc out.

  Definition Pfun (m : mem) (fd : Clight.fundef) (vargs : list val) (t : trace)
      (m' : mem) (vres : val) : Prop :=
    eval_funcall function_entry2 ge m fd vargs t m' vres /\
    forall s, Good fd s ->
      let '(pcs, rc, dm) := s in
      forall nb0, Hn nb0 ->
      Forall2 (uvok nb0) pcs vargs -> UInv dm nb0 m -> UInv dm nb0 m' /\ uvok nb0 rc vres.

  (* ---- per-statement bricks ---- *)
  Section Fn.
    Variable dm : bool.
    Variable nb0 : block.
    Hypothesis HN : Hn nb0.
    Variable lv : list ident.
    Variable tc : ident -> kcls.
    Variable e : env.
    Hypothesis HEI : KEILu nb0 lv e.

    Lemma ub_x : forall le m a v, KTPu nb0 tc le -> UInv dm nb0 m ->
        eval_expr ge e le m a v -> uvok nb0 (kxd dm lv gs tc a) v.
    Proof.
      intros le m a v HP (Hf & _ & HL) Hev.
      exact (kxd_sound ge e le m SafeB nl nb0 dm lv gs tc HP (proj1 HEI) (proj2 HEI) Hgs
               (u_R7 m Hf) HL a v Hev).
    Qed.

    Lemma ub_lv : forall le m a b o bf, KTPu nb0 tc le -> UInv dm nb0 m ->
        eval_lvalue ge e le m a b o bf -> upc nb0 (klvd dm lv gs tc a) b.
    Proof.
      intros le m a b o bf HP (Hf & _ & HL) Hev.
      exact (klvd_sound ge e le m SafeB nl nb0 dm lv gs tc HP (proj1 HEI) (proj2 HEI) Hgs
               (u_R7 m Hf) HL a b o bf Hev).
    Qed.

    Lemma ub_set : forall id a le m v,
        kp_setd dm lv gs tc id a = true -> KTPu nb0 tc le -> UInv dm nb0 m ->
        eval_expr ge e le m a v -> KTPu nb0 tc (PTree.set id v le).
    Proof.
      intros id a le m v Hok HP Hi Hev t v' Hg.
      destruct (peq t id) as [-> | Hne].
      - rewrite PTree.gss in Hg. injection Hg as <-.
        exact (kle_vok _ _ _ _ _ _ _ Hok (ub_x _ _ _ _ HP Hi Hev)).
      - rewrite PTree.gso in Hg by exact Hne. exact (HP _ _ Hg).
    Qed.

    Lemma ustore_val : forall K le m r v2 ty vv,
        KTPu nb0 tc le -> UInv dm nb0 m -> eval_expr ge e le m r v2 ->
        sem_cast v2 (typeof r) ty m = Some vv ->
        kle (kxd dm lv gs tc r) K || nonptr_scalar ty = true ->
        uvok nb0 K vv /\ (K = kN \/ nonptr_scalar ty = true -> forall bb oo, vv <> Vptr bb oo).
    Proof.
      intros K le m r v2 ty vv HP Hi Hre Hc Hor.
      apply orb_true_iff in Hor as [Hk | Hn'].
      - assert (Hv : uvok nb0 K vv).
        { intros bb oo Ev. subst vv.
          exact (kle_pc _ _ _ _ _ _ _ Hk (ub_x _ _ _ _ HP Hi Hre _ _ (sem_cast_vptr_inv _ _ _ _ _ _ Hc))). }
        split; [ exact Hv | ].
        intros [-> | Hn'] bb oo Ev.
        + exact (Hv _ _ Ev).
        + exact (sem_cast_to_nonptr_scalar _ _ _ _ _ Hn' Hc _ _ Ev).
      - pose proof (sem_cast_to_nonptr_scalar _ _ _ _ _ Hn' Hc) as Hnp.
        split; [ exact (kvok_np _ _ _ _ _ _ Hnp) | intros _; exact Hnp ].
    Qed.

    Lemma ub_store_mem : forall c ch m b z vv m' K ty,
        (match c with
         | kS => kle K kS || nonptr_scalar ty
         | kL => dm || kle K kW || nonptr_scalar ty
         | kT => kle K kS || nonptr_scalar ty
         | kW => kle K kN || nonptr_scalar ty
         | _ => false end) = true ->
        upc nb0 c b ->
        (forall K', kle K K' || nonptr_scalar ty = true ->
           uvok nb0 K' vv /\ (K' = kN \/ nonptr_scalar ty = true -> forall bb oo, vv <> Vptr bb oo)) ->
        Mem.store ch m b z vv = Some m' -> UInv dm nb0 m -> UInv dm nb0 m'.
    Proof.
      intros c ch m b z vv m' K ty Hc Hp Hval Hst Hi.
      destruct c; try discriminate Hc.
      - destruct (Hval kS Hc) as (Hv & _).
        exact (u_store_safe nb0 HN _ _ _ _ _ _ _ Hp Hv Hst Hi).
      - refine (u_store_local nb0 HN _ _ _ _ _ _ _ Hp _ Hst Hi).
        intros Hd. subst dm. cbn [orb] in Hc.
        destruct (Hval kW Hc) as (Hv & _). exact Hv.
      - destruct (Hval kS Hc) as (Hv & _).
        destruct Hp as [Hp | Hp].
        + exact (u_store_safe nb0 HN _ _ _ _ _ _ _ Hp Hv Hst Hi).
        + destruct (plt b nb0) as [Hlt | Hge].
          * (* an older local, below the RL threshold *)
            assert (Hl : Ple nl b) by (destruct Hp as [Hp | Hp]; [ exact Hp | exact (Ple_trans _ _ _ HN Hp) ]).
            destruct Hi as (Hf & Hnb & HL).
            split; [ exact (u_local_of _ _ _ _ _ _ Hl Hst Hf) | split ].
            -- rewrite (Mem.nextblock_store _ _ _ _ _ _ Hst). exact Hnb.
            -- intros Hd. exact (u_rl_other nb0 _ _ _ _ _ _ Hlt Hst (HL Hd)).
          * assert (Hp' : Ple nb0 b) by (unfold Plt, Ple in *; lia).
            refine (u_store_local nb0 HN _ _ _ _ _ _ _ Hp' _ Hst Hi).
            intros _. exact (kle_vok _ _ _ _ _ _ _ (eq_refl : kle kS kW = true) Hv).
      - destruct (Hval kN Hc) as (_ & Hnp).
        refine (u_store_w nb0 HN _ _ _ _ _ _ _ Hp _ Hst Hi).
        apply Hnp. apply orb_true_iff in Hc as [Hk | Hn']; [ left | right; exact Hn' ].
        destruct K; try discriminate Hk; reflexivity.
    Qed.

    Lemma ub_store : forall l r le m t le' m' out,
        kp_stored dm lv gs tc l r = true -> KTPu nb0 tc le ->
        exec_stmt function_entry2 ge e le m (Sassign l r) t le' m' out ->
        UInv dm nb0 m -> UInv dm nb0 m'.
    Proof.
      intros l r le m t le' m' out Hok HP Hx Hi.
      unfold kp_stored in Hok. apply andb_prop in Hok as [Hbv Hcl].
      inv Hx.
      lazymatch goal with Hlv : eval_lvalue _ _ _ _ _ ?loc _ _ |- _ =>
        pose proof (ub_lv _ _ _ _ _ _ HP Hi Hlv) as Hpc end.
      match goal with Hre : eval_expr _ _ _ _ r ?v2, Hc : sem_cast ?v2 _ _ _ = Some ?vv |- _ =>
        pose proof (fun K' H => ustore_val K' _ _ _ _ _ _ HP Hi Hre Hc H) as Hval end.
      match goal with Ha : assign_loc _ _ _ _ _ _ _ _ |- _ => inv Ha end.
      - match goal with Hst : Mem.storev _ _ _ _ = Some _ |- _ =>
          unfold Mem.storev in Hst; exact (ub_store_mem _ _ _ _ _ _ _ _ _ Hcl Hpc Hval Hst Hi) end.
      - unfold MtxfBody.is_byval in Hbv.
        match goal with Hc : access_mode _ = By_copy |- _ => rewrite Hc in Hbv; discriminate Hbv end.
      - match goal with Hb : store_bitfield _ _ _ _ _ _ _ _ _ _ |- _ => inv Hb end.
        match goal with Hst : Mem.storev _ _ _ _ = Some _ |- _ =>
          unfold Mem.storev in Hst;
          refine (ub_store_mem _ _ _ _ _ _ _ _ _ Hcl Hpc _ Hst Hi) end.
        intros K' _. split; [ intros bb oo E; discriminate E | intros _ bb oo E; discriminate E ].
    Qed.

    Lemma ub_ret : forall rc a le m v,
        kp_retd dm lv gs tc rc a = true -> KTPu nb0 tc le -> UInv dm nb0 m ->
        eval_expr ge e le m a v -> uvok nb0 rc v.
    Proof.
      intros rc a le m v Hok HP Hi Hev.
      exact (kle_vok _ _ _ _ _ _ _ Hok (ub_x _ _ _ _ HP Hi Hev)).
    Qed.

    (* the callee of a checked call fits its looked-up signature *)
    Lemma ub_callee : forall a le m vf fd targs tres cc sg,
        match direct_fid a with Some fid => negb (mem_id fid lv) | None => true end = true ->
        u_call_sig ut it a = Some sg ->
        classify_fun (typeof a) = fun_case_f targs tres cc ->
        eval_expr ge e le m a vf -> Genv.find_funct ge vf = Some fd ->
        type_of_fundef fd = Tfunction targs tres cc ->
        exists se, Good fd se /\ fitsb se sg = true.
    Proof.
      intros a le m vf fd targs tres cc sg Hnl Hsig Hcf Hev Hff Hty.
      unfold u_call_sig in Hsig.
      destruct (direct_fid a) as [fid|] eqn:Ed.
      - destruct (direct_fid_inv _ _ Ed) as (targs' & tres' & cc' & ->).
        apply negb_true_iff in Hnl.
        assert (Hnone : e ! fid = None).
        { destruct (e ! fid) as [[b ty]|] eqn:E; [ | reflexivity ].
          destruct (proj1 HEI _ _ _ E) as (Hm & _). congruence. }
        destruct (evar_fun_val _ _ _ _ _ _ _ _ _ Hev Hnone) as (lf & Hsy & ->).
        exists sg. split; [ exact (HTab _ _ Hsig lf fd Hsy Hff) | ].
        destruct sg as [[pcs rc] d]. unfold fitsb.
        assert (Hrefl : forall l, kcls_leq l l = true).
        { induction l as [| c l IH]; [ reflexivity | cbn [kcls_leq]; rewrite IH;
            destruct c; reflexivity ]. }
        rewrite Hrefl. destruct rc, d; reflexivity.
      - rewrite Hcf in Hsig. exact (HIt _ _ Hsig vf fd Hff Hty).
    Qed.
  End Fn.

  Lemma rl_fresh : forall nb m, Mem.nextblock m = nb -> RLu nb m.
  Proof.
    intros nb m E b ofs b' o' Hb Hld. exfalso.
    pose proof (PrintBodies.load_valid _ _ _ _ _ Hld) as Hv. unfold Mem.valid_block in Hv.
    subst nb. exact (Plt_strict _ (Plt_Ple_trans _ _ _ Hv Hb)).
  Qed.

  Lemma Hn_mono : forall nb0 nb1, Hn nb0 -> Ple nb0 nb1 -> Hn nb1.
  Proof. intros nb0 nb1 H1 H2. exact (Ple_trans _ _ _ H1 H2). Qed.

  (* the call case, given the callee's induction hypothesis *)
  Lemma ub_call_ih : forall dm nb0 lv tc e optid a al le m targs tres cc vf vargs fd t m' vres,
      Hn nb0 -> KEILu nb0 lv e ->
      kp_calld dm lv gs tc ut it optid a al = true -> KTPu nb0 tc le -> UInv dm nb0 m ->
      classify_fun (typeof a) = fun_case_f targs tres cc ->
      eval_expr ge e le m a vf -> eval_exprlist ge e le m al targs vargs ->
      Genv.find_funct ge vf = Some fd -> type_of_fundef fd = Tfunction targs tres cc ->
      Pfun m fd vargs t m' vres ->
      UInv dm nb0 m' /\ KTPu nb0 tc (set_opttemp optid vres le).
  Proof.
    intros dm nb0 lv tc e optid a al le m targs tres cc vf vargs fd t m' vres
      HN HEI Hok HP Hi Hcf Hev Hel Hff Hty (_ & IH).
    unfold kp_calld in Hok. apply andb_prop in Hok as [Hnl Hok].
    destruct (u_call_sig ut it a) as [[[pcs rc] dme]|] eqn:Hsig; [ | discriminate Hok ].
    apply andb_prop in Hok as [Hok Hopt]. apply andb_prop in Hok as [Hal Hmode].
    destruct (ub_callee nb0 lv e HEI a le m vf fd targs tres cc _ Hnl Hsig Hcf Hev Hff Hty)
      as ([[pcs' rc'] dm'] & Hgood & Hfit).
    unfold fitsb in Hfit.
    apply andb_prop in Hfit as [Hfit Hfm]. apply andb_prop in Hfit as [Hpl Hrc].
    apply kcls_leq_eq in Hpl. subst pcs'.
    pose proof (IH _ Hgood) as IH'. cbv beta iota in IH'.
    pose proof (kargsd_sound ge e le m SafeB nl nb0 dm lv gs tc HP (proj1 HEI) (proj2 HEI) Hgs
                  (u_R7 m (proj1 Hi)) (proj2 (proj2 Hi)) _ _ _ Hel _ Hal) as Hargs.
    (* the callee's result, at the caller's nb0 *)
    assert (Hres : UInv dm nb0 m' /\ uvok nb0 rc' vres).
    { destruct dm' eqn:Edm'.
      - (* dirty callee: then the caller is dirty too *)
        assert (Edm : dm = true).
        { destruct dme; [ | discriminate Hfm ]. destruct dm; [ reflexivity | discriminate Hmode ]. }
        subst dm. exact (IH' nb0 HN Hargs Hi).
      - destruct dm eqn:Edm.
        + (* dirty caller, clean callee: restart nb0 at the call *)
          assert (Hfree : forallb kfree pcs = true).
          { unfold mode_ok in Hmode. destruct dme.
            - cbn in Hfm. exact Hfm.
            - cbn in Hmode. exact Hmode. }
          destruct Hi as (Hf & Hnb & _).
          set (nb1 := Mem.nextblock m).
          assert (HN1 : Hn nb1) by exact (Hn_mono _ _ HN Hnb).
          destruct (IH' nb1 HN1 (forall2_kvok_free _ _ _ _ _ _ _ HN Hfree Hargs)
                      (conj Hf (conj (Ple_refl _) (fun _ => rl_fresh nb1 m eq_refl))))
            as ((Hf' & Hnb' & _) & Hr).
          split; [ split; [ exact Hf' | split; [ exact (Ple_trans _ _ _ Hnb Hnb') | discriminate ] ]
                 | exact (kvok_mono _ _ _ _ _ _ _ Hnb Hr) ].
        + exact (IH' nb0 HN Hargs Hi). }
    destruct Hres as (Hi' & Hr).
    split; [ exact Hi' | ].
    intros t0 v0 Hg. destruct optid as [ti|]; cbn [set_opttemp] in Hg; [ | exact (HP _ _ Hg) ].
    destruct (peq t0 ti) as [-> | Hne].
    - rewrite PTree.gss in Hg. injection Hg as <-.
      exact (kle_vok _ _ _ _ _ _ _ Hopt (kle_vok _ _ _ _ _ _ _ Hrc Hr)).
    - rewrite PTree.gso in Hg by exact Hne. exact (HP _ _ Hg).
  Qed.

  (* the function body, given the statement induction hypothesis *)
  Lemma ub_body : forall f vargs m e le1 m1 t le2 m2 out vres m3 s,
      function_entry2 ge f vargs m e le1 m1 ->
      Pstmt e le1 m1 (fn_body f) t le2 m2 out ->
      outcome_result_value out (fn_return f) vres m2 ->
      Mem.free_list m2 (blocks_of_env ge e) = Some m3 ->
      uchk gs ut it s f = true ->
      let '(pcs, rc, dm) := s in
      forall nb0, Hn nb0 ->
      Forall2 (uvok nb0) pcs vargs -> UInv dm nb0 m -> UInv dm nb0 m3 /\ uvok nb0 rc vres.
  Proof.
    intros f vargs m e le1 m1 t le2 m2 out vres m3 [[pcs rc] dm] Hentry (_ & IHb) Hor Hfree Hchk
      nb0 HN Hva (Hf & Hnb & HL).
    unfold uchk in Hchk. set (tc := utc_of dm gs ut it pcs f) in Hchk.
    unfold uchk_tc in Hchk. apply andb_prop in Hchk as [Hchk Hpar].
    pose proof Hf as (Hv & Hs & HM).
    inv Hentry.
    match goal with Ha : alloc_variables _ _ _ _ _ _ |- _ => rename Ha into Hav end.
    match goal with Hb : bind_parameter_temps _ _ _ = Some _ |- _ => rename Hb into Hbp end.
    set (lv := map fst (fn_vars f)) in *.
    pose proof (MtxfBody.av_facts bm MWF _ _ _ _ _ _ (mwf_real_alloc lp bm bc oc0 SafeB uk_Hbc_bm) Hav Hf)
      as Hf1.
    destruct (u_av nb0 _ _ _ _ _ Hav
                ltac:(intros x b ty Hx; rewrite PTree.gempty in Hx; discriminate Hx) Hnb)
      as (Hnb1 & He1 & HL1).
    assert (HEI : KEILu nb0 lv e).
    { split.
      - intros x b ty Hx. split; [ | exact (He1 _ _ _ Hx) ].
        destruct (mem_id x lv) eqn:E; [ reflexivity | exfalso ].
        rewrite (alloc_variables_unbound _ _ _ _ _ _ Hav x (MtxfBody.mem_id_notin _ _ E)) in Hx.
        rewrite PTree.gempty in Hx. discriminate Hx.
      - intros x Hx. destruct (alloc_variables_in_bound _ _ _ _ _ _ Hav x (MtxfBody.mem_id_In _ _ Hx))
          as (b & ty & E). congruence. }
    assert (HP1 : KTPu nb0 tc le1).
    { intros t0 v Hg.
      destruct (ObjHelpersBodies.bind_get _ _ _ _ _ _ Hbp Hg) as [Hu | (i & Hi & Hvi)].
      - apply MtxfBody.create_undef_temps_get in Hu. subst v. apply kvok_undef.
      - destruct (PrintBodies.forall2_nth_l _ _ _ _ _ Hva Hvi) as (c & Hc).
        exact (kle_vok _ _ _ _ _ _ _ (kpar_ok_nth _ _ _ _ _ _ Hpar Hi Hc)
                 (PrintBodies.forall2_nth _ _ _ _ _ _ Hva Hc Hvi)). }
    destruct (IHb dm nb0 lv tc rc HN HEI Hchk HP1
                (conj Hf1 (conj Hnb1 (fun Hd => HL1 (HL Hd)))))
      as ((Hf2 & Hnb2 & HL2) & _ & Hout).
    pose proof Hf2 as (Hv2 & Hs2 & HM2).
    assert (Hfa : Forall (fun blh => let '(b,_,_) := blh in b <> bm)
                    (blocks_of_env (lp_ge lp) e)).
    { eapply Forall_impl; [ | exact (blocks_of_env_bm lp bm _ _ _ _ Hav Hv) ].
      intros [[b lo] hi] Hq. exact Hq. }
    destruct (vfc_free_list_frame not_tainted bm _ _ _ Hfa Hfree Hv2 Hs2) as (Hvf & Hsf).
    destruct (u_free nb0 _ _ _ Hfree Hnb2) as (Hnb3 & HL3).
    split; [ exact (conj (conj Hvf (conj Hsf (mwf_real_free lp bm bc oc0 SafeB uk_Hbc_bm _ _ _ Hfree HM2)))
                         (conj Hnb3 (fun Hd => HL3 (HL2 Hd)))) | ].
    intros bb oo Ev. subst vres.
    destruct out as [ | | | [[v' t']|] ]; cbn in Hor.
    - contradiction Hor.
    - contradiction Hor.
    - destruct (fn_return f); try contradiction Hor; discriminate Hor.
    - destruct Hor as (_ & Hc). exact (Hout _ _ (sem_cast_vptr_inv _ _ _ _ _ _ Hc)).
    - destruct (fn_return f); try contradiction Hor; discriminate Hor.
  Qed.

  (* THE MUTUAL INDUCTION *)
  Lemma u_mutual :
    (forall e le m s t le' m' out,
        exec_stmt function_entry2 ge e le m s t le' m' out -> Pstmt e le m s t le' m' out) /\
    (forall m fd vargs t m' vres,
        eval_funcall function_entry2 ge m fd vargs t m' vres -> Pfun m fd vargs t m' vres).
  Proof.
    apply (exec_stmt_funcall_ind function_entry2 ge Pstmt Pfun); unfold Pstmt, Pfun.
    - (* Sskip *)
      intros e le m. split; [ constructor | ].
      intros dm nb0 lv tc rc _ _ _ HP Hi. exact (conj Hi (conj HP I)).
    - (* Sassign *)
      intros e le m a1 a2 loc ofs bf v2 v m' Hl Hr Hc Ha.
      assert (Hx : exec_stmt function_entry2 ge e le m (Sassign a1 a2) E0 le m' Out_normal)
        by (eapply exec_Sassign; eassumption).
      split; [ exact Hx | ].
      intros dm nb0 lv tc rc HN HEI Hchk HP Hi. cbn [sw_chk] in Hchk.
      exact (conj (ub_store dm nb0 HN lv tc e HEI _ _ _ _ _ _ _ _ Hchk HP Hx Hi) (conj HP I)).
    - (* Sset *)
      intros e le m id a v Hev.
      split; [ exact (exec_Sset _ _ _ _ _ _ _ _ Hev) | ].
      intros dm nb0 lv tc rc HN HEI Hchk HP Hi. cbn [sw_chk] in Hchk.
      exact (conj Hi (conj (ub_set dm nb0 lv tc e HEI _ _ _ _ _ Hchk HP Hi Hev) I)).
    - (* Scall *)
      intros e le m optid a al targs tres cc vf vargs fd t m' vres Hcf Hev Hel Hff Hty _ IHf.
      split; [ exact (exec_Scall _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ Hcf Hev Hel Hff Hty (proj1 IHf)) | ].
      intros dm nb0 lv tc rc HN HEI Hchk HP Hi. cbn [sw_chk] in Hchk.
      destruct (ub_call_ih dm nb0 lv tc e optid a al le m targs tres cc vf vargs fd t m' vres
                  HN HEI Hchk HP Hi Hcf Hev Hel Hff Hty IHf) as (Hi' & HP').
      exact (conj Hi' (conj HP' I)).
    - (* Sbuiltin *)
      intros e le m optid ef al targs vargs t m' vres Hel Hext.
      split; [ exact (exec_Sbuiltin _ _ _ _ _ _ _ _ _ _ _ _ _ Hel Hext) | ].
      intros dm nb0 lv tc rc _ _ Hchk. cbn [sw_chk] in Hchk. discriminate Hchk.
    - (* Sseq_1 *)
      intros e le m s1 s2 t1 le1 m1 t2 le2 m2 out D1 (_ & IH1) D2 (_ & IH2).
      split; [ exact (exec_Sseq_1 _ _ _ _ _ _ _ _ _ _ _ _ _ _ D1 D2) | ].
      intros dm nb0 lv tc rc HN HEI Hchk HP Hi. cbn [sw_chk] in Hchk.
      apply andb_prop in Hchk as [H1 H2].
      destruct (IH1 dm nb0 lv tc rc HN HEI H1 HP Hi) as (Hi1 & HP1 & _).
      exact (IH2 dm nb0 lv tc rc HN HEI H2 HP1 Hi1).
    - (* Sseq_2 *)
      intros e le m s1 s2 t1 le1 m1 out D1 (_ & IH1) Hne.
      split; [ exact (exec_Sseq_2 _ _ _ _ _ _ _ _ _ _ _ D1 Hne) | ].
      intros dm nb0 lv tc rc HN HEI Hchk HP Hi. cbn [sw_chk] in Hchk.
      apply andb_prop in Hchk as [H1 _].
      exact (IH1 dm nb0 lv tc rc HN HEI H1 HP Hi).
    - (* Sifthenelse *)
      intros e le m a s1 s2 v1 b t le' m' out Hev Hbv D (_ & IH).
      split; [ exact (exec_Sifthenelse _ _ _ _ _ _ _ _ _ _ _ _ _ _ Hev Hbv D) | ].
      intros dm nb0 lv tc rc HN HEI Hchk HP Hi. cbn [sw_chk] in Hchk.
      apply andb_prop in Hchk as [H1 H2].
      apply (IH dm nb0 lv tc rc HN HEI); [ destruct b; assumption | exact HP | exact Hi ].
    - (* Sreturn None *)
      intros e le m. split; [ constructor | ].
      intros dm nb0 lv tc rc _ _ _ HP Hi. exact (conj Hi (conj HP I)).
    - (* Sreturn Some *)
      intros e le m a v Hev. split; [ exact (exec_Sreturn_some _ _ _ _ _ _ _ Hev) | ].
      intros dm nb0 lv tc rc HN HEI Hchk HP Hi. cbn [sw_chk] in Hchk.
      exact (conj Hi (conj HP (ub_ret dm nb0 lv tc e HEI _ _ _ _ _ Hchk HP Hi Hev))).
    - (* Sbreak *)
      intros e le m. split; [ constructor | ].
      intros dm nb0 lv tc rc _ _ _ HP Hi. exact (conj Hi (conj HP I)).
    - (* Scontinue *)
      intros e le m. split; [ constructor | ].
      intros dm nb0 lv tc rc _ _ _ HP Hi. exact (conj Hi (conj HP I)).
    - (* Sloop_stop1 *)
      intros e le m s1 s2 t le' m' out' out D (_ & IH) Hbr.
      split; [ exact (exec_Sloop_stop1 _ _ _ _ _ _ _ _ _ _ _ _ D Hbr) | ].
      intros dm nb0 lv tc rc HN HEI Hchk HP Hi. cbn [sw_chk] in Hchk.
      apply andb_prop in Hchk as [H1 _].
      destruct (IH dm nb0 lv tc rc HN HEI H1 HP Hi) as (Hi1 & HP1 & Ho1).
      split; [ exact Hi1 | split; [ exact HP1 | ] ].
      inv Hbr; [ exact I | exact Ho1 ].
    - (* Sloop_stop2 *)
      intros e le m s1 s2 t1 le1 m1 out1 t2 le2 m2 out2 out D1 (_ & IH1) Hnc D2 (_ & IH2) Hbr.
      split; [ eapply exec_Sloop_stop2; [ exact D1 | exact Hnc | exact D2 | exact Hbr ] | ].
      intros dm nb0 lv tc rc HN HEI Hchk HP Hi. cbn [sw_chk] in Hchk.
      apply andb_prop in Hchk as [H1 H2].
      destruct (IH1 dm nb0 lv tc rc HN HEI H1 HP Hi) as (Hi1 & HP1 & _).
      destruct (IH2 dm nb0 lv tc rc HN HEI H2 HP1 Hi1) as (Hi2 & HP2 & Ho2).
      split; [ exact Hi2 | split; [ exact HP2 | ] ].
      inv Hbr; [ exact I | exact Ho2 ].
    - (* Sloop_loop *)
      intros e le m s1 s2 t1 le1 m1 out1 t2 le2 m2 t3 le3 m3 out D1 (_ & IH1) Hnc D2 (_ & IH2) D3 (_ & IH3).
      split; [ eapply exec_Sloop_loop; [ exact D1 | exact Hnc | exact D2 | exact D3 ] | ].
      intros dm nb0 lv tc rc HN HEI Hchk HP Hi.
      pose proof Hchk as Hchk'. cbn [sw_chk] in Hchk.
      apply andb_prop in Hchk as [H1 H2].
      destruct (IH1 dm nb0 lv tc rc HN HEI H1 HP Hi) as (Hi1 & HP1 & _).
      destruct (IH2 dm nb0 lv tc rc HN HEI H2 HP1 Hi1) as (Hi2 & HP2 & _).
      exact (IH3 dm nb0 lv tc rc HN HEI Hchk' HP2 Hi2).
    - (* Sswitch *)
      intros e le m a t v n sl le1 m1 out Hev Hsw D (_ & IH).
      split; [ eapply exec_Sswitch; [ exact Hev | exact Hsw | exact D ] | ].
      intros dm nb0 lv tc rc HN HEI Hchk HP Hi. cbn [sw_chk] in Hchk.
      destruct (IH dm nb0 lv tc rc HN HEI (sw_chk_select _ _ _ _ _ _ Hchk) HP Hi) as (Hi1 & HP1 & Ho1).
      split; [ exact Hi1 | split; [ exact HP1 | ] ].
      destruct out as [ | | | [[vr tyr]|] ]; cbn; auto.
    - (* funcall internal *)
      intros m f vargs t e le1 le2 m1 m2 out vres m3 Hentry _ IHb Hor Hfree.
      assert (D : eval_funcall function_entry2 ge m (Internal f) vargs t m3 vres)
        by (eapply eval_funcall_internal; [ exact Hentry | exact (proj1 IHb) | exact Hor | exact Hfree ]).
      split; [ exact D | ].
      intros [[pcs rc] dm] Hg.
      destruct Hg as [(f' & Ef & Hchk) | Hlf].
      + injection Ef as <-.
        exact (ub_body f vargs m e le1 m1 t le2 m2 out vres m3 (pcs, rc, dm) Hentry IHb Hor Hfree Hchk).
      + intros nb0 HN Hva Hi. exact (HLeaf _ _ Hlf nb0 HN _ _ _ _ _ D Hva Hi).
    - (* funcall external *)
      intros m ef targs tres cc vargs t vres m' Hext.
      assert (D : eval_funcall function_entry2 ge m (External ef targs tres cc) vargs t m' vres)
        by (eapply eval_funcall_external; exact Hext).
      split; [ exact D | ].
      intros [[pcs rc] dm] Hg.
      destruct Hg as [(f' & Ef & _) | Hlf]; [ discriminate Ef | ].
      intros nb0 HN Hva Hi. exact (HLeaf _ _ Hlf nb0 HN _ _ _ _ _ D Hva Hi).
  Qed.

  (* THE RESULT: every table function meets its spec *)
  Theorem good_spec : forall fd s, Good fd s -> uspec fd s.
  Proof.
    intros fd [[pcs rc] dm] Hg nb0 HN m vargs t m' vres Hev Hva Hi.
    destruct (proj2 u_mutual _ _ _ _ _ _ Hev) as (_ & IH).
    exact (IH (pcs, rc, dm) Hg nb0 HN Hva Hi).
  Qed.
End UK.
