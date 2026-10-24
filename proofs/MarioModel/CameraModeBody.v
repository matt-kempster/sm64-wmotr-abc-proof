(* ====================================================================== *)
(* set_camera_mode, PROVED FROM ITS REAL BODY (SPINE: discharges the       *)
(* capstones' Hscm_body_real, 2026-10-23).                                 *)
(*                                                                        *)
(* camera.c is linked (the 35th TU), so mario.c's set_camera_mode(c, mode, *)
(* frames) calls the real camera.c body.  That body (camera.c:2854)        *)
(*  - stores scalars into camera.c globals (sModeInfo, gLakituState,       *)
(*    sAreaYaw, ...) and into c->mode;                                     *)
(*  - copies / subtracts vectors through vec3f_copy, vec3f_sub,            *)
(*    vec3f_get_dist_and_angle (math_util.c / camera.c), reading           *)
(*    sMarioCamState->pos;                                                 *)
(*  - calls THROUGH THE WRITABLE TABLE sModeTransitions[newMode](c, ...).  *)
(* The table is a plain (non-const) global, so in an arbitrary memory its  *)
(* slot can hold any function pointer.  A Clight indirect call only runs a *)
(* function whose type IS the call's type, (Camera ptr, f32 ptr, f32 ptr)  *)
(* to s32, and the per-TU certificate tu_trans_ok shows that across every  *)
(* linked TU exactly the fourteen camera.c transition functions have that  *)
(* type.  So the indirect call is covered by walking all fourteen and      *)
(* their callees: 60 real bodies in camera.c, math_util.c and              *)
(* surface_collision.c (find_floor, find_ceil, their _from_list walkers,   *)
(* find_water_level), plus play_sound (AudioBodies) and sqrtf.            *)
(*                                                                        *)
(* THE WALK: a class walker (PrintBodies' design, two more classes):       *)
(*   kN  never a pointer;                                                  *)
(*   kS  a SafeB block;                                                    *)
(*   kL  a block allocated since the outer call's entry (a stack local);   *)
(*   kW  kS or kL or the block of a global MWF does not read (mwf_syms);   *)
(*   kA  anything.                                                         *)
(* Every store is a SafeB-if-pointer value into kS, a kW value into a kL   *)
(* local, or a NON-pointer value into kW.  The carried invariant adds:     *)
(* nextblock stays above the entry's, and a pointer read out of a local is *)
(* kW (vec3f_copy / vec3f_set / vec3f_add spill their dest param).         *)
(*                                                                        *)
(* STRENGTHENED (2026-10-23): update_boss_fight_camera STORES through      *)
(* sMarioCamState (sMarioCamState->cameraEvent = 0), a pointer global MWF  *)
(* said nothing about, so the row covered memories where it aims at        *)
(* Mario's block.  sMarioCamState is now a SafeB symbol                    *)
(* (CensusV2.camera_safe_syms; SafeB_boot already contains it): R7 keeps   *)
(* its target SafeB.  In the real game it holds &gPlayerCameraState[0].    *)
(* Likewise the two surface partitions: find_floor / find_ceil store the   *)
(* Surface they found into the caller's local out cell, and chased from a  *)
(* SafeB partition it is SafeB, so the local keeps holding a kW pointer.   *)
(* Integer + / - on arithmetic types is classed never-pointer              *)
(* (never_ptr_binop: sem_binarith only returns numbers).                   *)
(*                                                                        *)
(* Floors used: the FPU floor sqrtf_spec (TRUST 3.5, already a capstone    *)
(* premise; vec3f_get_dist_and_angle calls sqrtf).  No new trust.          *)
(* ====================================================================== *)

From Coq Require Import ZArith List Lia Bool String.
From compcert Require Import Coqlib Maps AST Integers Values Events Memory
  Globalenvs Ctypes Cop Clightdefs Clight ClightBigstep Linking.
From SM64.Generated Require mario camera math_util audio_external surface_collision.
From SM64.Proofs Require Import SymbolicLinking ActionValueFrame Taint
  RealFrameLinked AGates CensusV2 RestSurface MWFReal SpawnInit MathGeomBodies
  MathGeomGated OutParamSurface MathBodies LinkedTwelve LocalVarsSurface
  SurfaceBodies SpawnBodies FpuFloor.
From SM64.Proofs Require MtxfBody ActWriterSurface RetSurface SaveDoSaveBody
  ObjHelpersBodies ObjExtBodies AudioBodies InitMemSat PrintBodies.

Import ListNotations.
Local Open Scope Z_scope.

(* ---------------------------------------------------------------------- *)
(* 1. Classes.                                                             *)
(* ---------------------------------------------------------------------- *)

Inductive kcls : Type := kN | kS | kL | kW | kA.

Definition kle (c d : kcls) : bool :=
  match c, d with
  | kN, _ => true
  | _, kA => true
  | kS, kS | kS, kW => true
  | kL, kL | kL, kW => true
  | kW, kW => true
  | _, _ => false
  end.

Definition kjoin (c d : kcls) : kcls :=
  match c, d with
  | kN, _ => d
  | _, kN => c
  | kA, _ | _, kA => kA
  | kS, kS => kS
  | kL, kL => kL
  | _, _ => kW
  end.

Lemma kle_join_l : forall c d, kle c (kjoin c d) = true.
Proof. intros c d. destruct c, d; reflexivity. Qed.
Lemma kle_join_r : forall c d, kle d (kjoin c d) = true.
Proof. intros c d. destruct c, d; reflexivity. Qed.

Section PC.
  Variable SafeB GB : block -> Prop.
  Variable nb0 : block.

  Definition kpc (c : kcls) (b : block) : Prop :=
    match c with
    | kN => False
    | kS => SafeB b
    | kL => Ple nb0 b
    | kW => SafeB b \/ Ple nb0 b \/ GB b
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

(* ---------------------------------------------------------------------- *)
(* 2. The expression classifier and its soundness.                         *)
(* ---------------------------------------------------------------------- *)

Definition klvar (lv gs : list ident) (x : ident) : kcls :=
  if mem_id x lv then kL
  else if mem_id x gs then kS
  else if mem_id x ObjExtBodies.mwf_syms then kA
  else kW.

(* the class of a value read at a block of class c *)
Definition krv (ty : type) (c : kcls) : kcls :=
  match access_mode ty with
  | By_value Mint32 => match c with kN | kS => kS | kL => kW | _ => kA end
  | By_value Many32 | By_value Many64 => kA
  | By_value _ => kN
  | By_reference | By_copy => c
  | By_nothing => kN
  end.

Definition kbinop (op : binary_operation) (c1 c2 : kcls) : kcls :=
  match op with
  | Oadd => kjoin c1 c2
  | Osub => c1
  | Omul | Odiv | Omod => kN
  | _ => if RetSurface.vint_binop op then kN else kA
  end.

(* an integer + / - (both operands arithmetic): sem_binarith's result is
   never a pointer, whatever the operand values *)
Definition never_ptr_binop (op : binary_operation) (t1 t2 : type) : bool :=
  match op with
  | Oadd => match classify_add t1 t2 with add_default => true | _ => false end
  | Osub => match classify_sub t1 t2 with sub_default => true | _ => false end
  | _ => false
  end.

Lemma never_ptr_binop_sound : forall ce op v1 t1 v2 t2 m b o,
    never_ptr_binop op t1 t2 = true ->
    sem_binary_operation ce op v1 t1 v2 t2 m = Some (Vptr b o) -> False.
Proof.
  intros ce op v1 t1 v2 t2 m b o H Hs.
  destruct op; try discriminate H; cbn [never_ptr_binop sem_binary_operation] in H, Hs.
  - unfold sem_add in Hs. destruct (classify_add t1 t2); try discriminate H.
    unfold sem_binarith in Hs. cbv zeta in Hs.
    repeat match type of Hs with context [match ?x with _ => _ end] => destruct x end;
      discriminate Hs.
  - unfold sem_sub in Hs. destruct (classify_sub t1 t2); try discriminate H.
    unfold sem_binarith in Hs. cbv zeta in Hs.
    repeat match type of Hs with context [match ?x with _ => _ end] => destruct x end;
      discriminate Hs.
Qed.

Section KX.
  Variables lv gs : list ident.
  Variable tc : ident -> kcls.

  Fixpoint kx (a : expr) : kcls :=
    match a with
    | Econst_int _ _ | Econst_float _ _ | Econst_single _ _ | Econst_long _ _ => kN
    | Esizeof _ _ | Ealignof _ _ => kN
    | Etempvar t _ => tc t
    | Eunop _ _ _ => kN
    | Ecast a1 _ => kx a1
    | Ebinop op a1 a2 _ =>
        if never_ptr_binop op (typeof a1) (typeof a2) then kN
        else kbinop op (kx a1) (kx a2)
    | Evar x ty => krv ty (klvar lv gs x)
    | Ederef a1 ty => krv ty (kx a1)
    | Efield a1 _ ty => krv ty (kx a1)
    | Eaddrof a1 _ =>
        match a1 with
        | Evar x _ => klvar lv gs x
        | Ederef a2 _ | Efield a2 _ _ => kx a2
        | _ => kA
        end
    end.

  Definition klv (a : expr) : kcls :=
    match a with
    | Evar x _ => klvar lv gs x
    | Ederef a1 _ | Efield a1 _ _ => kx a1
    | _ => kA
    end.
End KX.

Section KXS.
  Variable ge : genv.
  Variable e : env.
  Variable le : temp_env.
  Variable m : mem.
  Variable SafeB : block -> Prop.
  Variable nb0 : block.
  Variables lv gs : list ident.
  Variable tc : ident -> kcls.

  Let GB (b : block) : Prop :=
    exists g, Genv.find_symbol ge g = Some b /\ mem_id g ObjExtBodies.mwf_syms = false.

  Hypothesis Hle : forall t v, le ! t = Some v -> kvok SafeB GB nb0 (tc t) v.
  Hypothesis He : forall x b ty, e ! x = Some (b, ty) -> mem_id x lv = true /\ Ple nb0 b.
  Hypothesis He2 : forall x, mem_id x lv = true -> e ! x <> None.
  Hypothesis Hgs : forall x b, mem_id x gs = true -> Genv.find_symbol ge x = Some b -> SafeB b.
  Hypothesis R7 : forall b ofs b' o', SafeB b ->
      Mem.loadv Mint32 m (Vptr b ofs) = Some (Vptr b' o') -> SafeB b'.
  Hypothesis RL : forall b ofs b' o', Ple nb0 b ->
      Mem.load Mint32 m b ofs = Some (Vptr b' o') -> kpc SafeB GB nb0 kW b'.

  Lemma kderef_cls : forall ty loc ofs bf v c,
      deref_loc ty m loc ofs bf v -> kpc SafeB GB nb0 c loc ->
      kvok SafeB GB nb0 (krv ty c) v.
  Proof.
    intros ty loc ofs bf v c Hd Hc b o Ev. subst v.
    inv Hd.
    - match goal with Ha : access_mode _ = By_value ?ch, Hl : Mem.loadv ?ch _ _ = Some _ |- _ =>
        pose proof Hl as Hl'; cbn in Hl';
        destruct (load_vptr_chunk _ _ _ _ _ _ Hl') as [E | [E | E]]; subst ch;
        unfold krv; rewrite Ha end.
      + destruct c; cbn in Hc |- *.
        * contradiction Hc.
        * eapply R7; eassumption.
        * eapply RL; eassumption.
        * exact I.
        * exact I.
      + exact I.
      + exact I.
    - match goal with Ha : access_mode _ = By_reference |- _ => unfold krv; rewrite Ha; exact Hc end.
    - match goal with Ha : access_mode _ = By_copy |- _ => unfold krv; rewrite Ha; exact Hc end.
    - match goal with Hl : load_bitfield _ _ _ _ _ _ _ _ |- _ => inv Hl end.
  Qed.

  Lemma kx_sound_mut :
    (forall a v, eval_expr ge e le m a v -> kvok SafeB GB nb0 (kx lv gs tc a) v) /\
    (forall a b o bf, eval_lvalue ge e le m a b o bf -> kpc SafeB GB nb0 (klv lv gs tc a) b).
  Proof.
    apply (eval_expr_lvalue_ind ge e le m
             (fun a v => kvok SafeB GB nb0 (kx lv gs tc a) v)
             (fun a b o bf => kpc SafeB GB nb0 (klv lv gs tc a) b));
      intros; cbv beta in *.
    - intros bb oo E; discriminate E.
    - intros bb oo E; discriminate E.
    - intros bb oo E; discriminate E.
    - intros bb oo E; discriminate E.
    - cbn [kx]. eapply Hle; eassumption.
    - (* Eaddrof *)
      intros bb oo E. injection E as <- <-.
      destruct a; cbn [klv] in *; cbn [kx]; first [ exact I | assumption ].
    - (* Eunop *)
      intros bb oo E. subst. exfalso.
      eapply ActWriterSurface.sem_unop_nonptr; [ eassumption | reflexivity ].
    - (* Ebinop *)
      intros bb oo E. subst. cbn [kx].
      match goal with |- context [if never_ptr_binop ?o ?x ?y then _ else _] =>
        destruct (never_ptr_binop o x y) eqn:Enp;
        [ exfalso; eapply never_ptr_binop_sound; eassumption | ] end.
      match goal with
      | Hs : sem_binary_operation _ ?op ?v1 _ ?v2 _ _ = Some _,
        IH1 : kvok _ _ _ _ ?v1, IH2 : kvok _ _ _ _ ?v2 |- _ =>
        pose proof Hs as Hs0;
        destruct op; cbn [kbinop]; cbn [sem_binary_operation] in Hs;
        [ destruct (SaveDoSaveBody.sem_add_vptr_src _ _ _ _ _ _ _ _ Hs) as [(o1 & E1) | (o2 & E2)];
          [ exact (kle_pc _ _ _ _ _ _ (kle_join_l _ _) (IH1 _ _ E1))
          | exact (kle_pc _ _ _ _ _ _ (kle_join_r _ _) (IH2 _ _ E2)) ]
        | destruct (SaveDoSaveBody.sem_sub_vptr_src _ _ _ _ _ _ _ _ Hs) as (o1 & E1);
          exact (IH1 _ _ E1)
        | exact (False_ind _ (ActWriterSurface.sem_mul_nonptr _ _ _ _ _ _ Hs _ _ eq_refl))
        | exact (False_ind _ (ActWriterSurface.sem_div_nonptr _ _ _ _ _ _ Hs _ _ eq_refl))
        | exact (False_ind _ (ActWriterSurface.sem_mod_nonptr _ _ _ _ _ _ Hs _ _ eq_refl))
        | (exfalso; refine (vint_binop_sound _ _ _ _ _ _ _ _ _ Hs0 _ _ eq_refl); reflexivity) .. ]
      end.
    - (* Ecast *)
      intros bb oo E. subst. cbn [kx].
      match goal with Hc : sem_cast ?v1 _ _ _ = Some _, IH : kvok _ _ _ _ ?v1 |- _ =>
        exact (IH _ _ (sem_cast_vptr_inv _ _ _ _ _ _ Hc)) end.
    - intros bb oo E. unfold Vptrofs in E. destruct Archi.ptr64; discriminate E.
    - intros bb oo E. unfold Vptrofs in E. destruct Archi.ptr64; discriminate E.
    - (* Elvalue *)
      destruct a;
        try (match goal with Hl : eval_lvalue _ _ _ _ _ _ _ _ |- _ => inv Hl end; fail);
        cbn [kx klv typeof] in *; eapply kderef_cls; eassumption.
    - (* Evar local *)
      cbn [klv]. unfold klvar. destruct (He _ _ _ H) as (-> & Hb). exact Hb.
    - (* Evar global *)
      cbn [klv]. unfold klvar.
      destruct (mem_id id lv) eqn:El; [ exact (False_ind _ (He2 _ El H)) | ].
      destruct (mem_id id gs) eqn:Eg; [ exact (Hgs _ _ Eg H0) | ].
      destruct (mem_id id ObjExtBodies.mwf_syms) eqn:Em; [ exact I | ].
      cbn [kpc]. right. right. exists id. split; [ exact H0 | exact Em ].
    - cbn [klv]. match goal with IH : kvok _ _ _ _ (Vptr ?l _) |- _ => exact (IH _ _ eq_refl) end.
    - cbn [klv]. match goal with IH : kvok _ _ _ _ (Vptr ?l _) |- _ => exact (IH _ _ eq_refl) end.
    - cbn [klv]. match goal with IH : kvok _ _ _ _ (Vptr ?l _) |- _ => exact (IH _ _ eq_refl) end.
  Qed.

  Lemma kx_sound : forall a v, eval_expr ge e le m a v -> kvok SafeB GB nb0 (kx lv gs tc a) v.
  Proof. exact (proj1 kx_sound_mut). Qed.

  Lemma klv_sound : forall a b o bf, eval_lvalue ge e le m a b o bf ->
      kpc SafeB GB nb0 (klv lv gs tc a) b.
  Proof. exact (proj2 kx_sound_mut). Qed.

  Fixpoint kargs_ok (al : list expr) (pcs : list kcls) : bool :=
    match al, pcs with
    | nil, nil => true
    | a :: al', c :: pcs' => kle (kx lv gs tc a) c && kargs_ok al' pcs'
    | _, _ => false
    end.

  Lemma kargs_sound : forall al tyl vl, eval_exprlist ge e le m al tyl vl ->
      forall pcs, kargs_ok al pcs = true -> Forall2 (kvok SafeB GB nb0) pcs vl.
  Proof.
    intros al tyl vl Hel. induction Hel; intros pcs Hok;
      destruct pcs as [| c pcs]; cbn [kargs_ok] in Hok; try discriminate Hok; [ constructor | ].
    apply andb_prop in Hok as [H1 H2].
    constructor; [ | exact (IHHel _ H2) ].
    intros bb oo E. subst.
    match goal with Hc : sem_cast ?v1 _ _ _ = Some (Vptr bb oo),
                    Hx : eval_expr _ _ _ _ ?a ?v1 |- _ =>
      exact (kle_pc _ _ _ _ _ _ H1 (kx_sound _ _ Hx _ _ (sem_cast_vptr_inv _ _ _ _ _ _ Hc))) end.
  Qed.
End KXS.

(* ---------------------------------------------------------------------- *)
(* 3. The per-function recognizer, with temp-class inference.               *)
(* ---------------------------------------------------------------------- *)

Definition ktcl (l : list (ident * kcls)) (dflt : kcls) (t : ident) : kcls :=
  match find (fun p => Pos.eqb (fst p) t) l with
  | Some (_, c) => c
  | None => dflt
  end.

(* direct callees: (callee, (param classes, return class)) *)
Definition kctab := list (ident * (list kcls * kcls)).
(* indirect callees, by the call's function type *)
Definition kitab := list (type * (list kcls * kcls)).

Definition kct_find (fid : ident) (ct : kctab) : option (list kcls * kcls) :=
  match find (fun p => Pos.eqb (fst p) fid) ct with
  | Some (_, s) => Some s
  | None => None
  end.

Definition kit_find (ty : type) (it : kitab) : option (list kcls * kcls) :=
  match find (fun p => proj_sumbool (type_eq (fst p) ty)) it with
  | Some (_, s) => Some s
  | None => None
  end.

Definition direct_fid (a : expr) : option ident :=
  match a with
  | Evar fid (Tfunction _ _ _) => Some fid
  | _ => None
  end.

Lemma direct_fid_inv : forall a fid, direct_fid a = Some fid ->
    exists targs tres cc, a = Evar fid (Tfunction targs tres cc).
Proof.
  intros a fid H. destruct a; try discriminate H.
  destruct t; try discriminate H. injection H as <-. eauto.
Qed.

(* the callee's signature: direct by name, else indirect by type *)
Definition call_sig (ct : kctab) (it : kitab) (a : expr) : option (list kcls * kcls) :=
  match direct_fid a with
  | Some fid => kct_find fid ct
  | None =>
      match classify_fun (typeof a) with
      | fun_case_f targs tres cc => kit_find (Tfunction targs tres cc) it
      | _ => None
      end
  end.

Definition kp_set (lv gs : list ident) (tc : ident -> kcls) (id : ident) (a : expr) : bool :=
  kle (kx lv gs tc a) (tc id).
Definition kp_store (lv gs : list ident) (tc : ident -> kcls) (l r : expr) : bool :=
  MtxfBody.is_byval (typeof l) &&
  match klv lv gs tc l with
  | kS => kle (kx lv gs tc r) kS || nonptr_scalar (typeof l)
  | kL => kle (kx lv gs tc r) kW || nonptr_scalar (typeof l)
  | kW => kle (kx lv gs tc r) kN || nonptr_scalar (typeof l)
  | _ => false
  end.
Definition kp_ret (lv gs : list ident) (tc : ident -> kcls) (rc : kcls) (a : expr) : bool :=
  kle (kx lv gs tc a) rc.
Definition kp_call (lv gs : list ident) (tc : ident -> kcls) (ct : kctab) (it : kitab)
    (optid : option ident) (a : expr) (al : list expr) : bool :=
  match direct_fid a with Some fid => negb (mem_id fid lv) | None => true end &&
  match call_sig ct it a with
  | Some (pcs, rc) =>
      kargs_ok lv gs tc al pcs &&
      match optid with None => true | Some id => kle rc (tc id) end
  | None => false
  end.

(* temp-class inference: a few Gauss-Seidel passes over the body *)
Definition kupd (tbl : list (ident * kcls)) (id : ident) (c : kcls) : list (ident * kcls) :=
  if kle c (ktcl tbl kN id) then tbl else (id, kjoin (ktcl tbl kN id) c) :: tbl.

Fixpoint kinf (lv gs : list ident) (ct : kctab) (it : kitab)
    (tbl : list (ident * kcls)) (s : statement) : list (ident * kcls) :=
  match s with
  | Sset id a => kupd tbl id (kx lv gs (ktcl tbl kN) a)
  | Scall (Some id) a _ =>
      match call_sig ct it a with Some (_, rc) => kupd tbl id rc | None => tbl end
  | Ssequence s1 s2 | Sifthenelse _ s1 s2 | Sloop s1 s2 =>
      kinf lv gs ct it (kinf lv gs ct it tbl s1) s2
  | Sswitch _ sl => kinf_ls lv gs ct it tbl sl
  | _ => tbl
  end
with kinf_ls (lv gs : list ident) (ct : kctab) (it : kitab)
    (tbl : list (ident * kcls)) (sl : labeled_statements) : list (ident * kcls) :=
  match sl with
  | LSnil => tbl
  | LScons _ s sl' => kinf_ls lv gs ct it (kinf lv gs ct it tbl s) sl'
  end.

Fixpoint kiter (n : nat) (lv gs : list ident) (ct : kctab) (it : kitab)
    (tbl : list (ident * kcls)) (s : statement) : list (ident * kcls) :=
  match n with
  | O => tbl
  | S n' => kiter n' lv gs ct it (kinf lv gs ct it tbl s) s
  end.

Fixpoint kzip (ids : list ident) (pcs : list kcls) : list (ident * kcls) :=
  match ids, pcs with
  | x :: ids', c :: pcs' => (x, c) :: kzip ids' pcs'
  | _, _ => nil
  end.

Definition ktc_of (gs : list ident) (ct : kctab) (it : kitab) (pcs : list kcls)
    (f : Clight.function) : ident -> kcls :=
  ktcl (kiter 6 (map fst (fn_vars f)) gs ct it (kzip (map fst (fn_params f)) pcs) (fn_body f)) kN.

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

Definition kchk_tc (gs : list ident) (tc : ident -> kcls) (ct : kctab) (it : kitab)
    (pcs : list kcls) (rc : kcls) (f : Clight.function) : bool :=
  let lv := map fst (fn_vars f) in
  sw_chk (kp_set lv gs tc) (kp_store lv gs tc) (kp_call lv gs tc ct it) (kp_ret lv gs tc rc)
    (fn_body f)
  && kpar_ok tc (map fst (fn_params f)) pcs.

Definition kchk (gs : list ident) (ct : kctab) (it : kitab) (pcs : list kcls) (rc : kcls)
    (f : Clight.function) : bool :=
  kchk_tc gs (ktc_of gs ct it pcs f) ct it pcs rc f.

(* ---------------------------------------------------------------------- *)
(* 4. The indirect call: the functions of the transition type.             *)
(* ---------------------------------------------------------------------- *)

(* CameraTransition = s32 ( * )(struct Camera *c, Vec3f, Vec3f) *)
Definition trans_ty : type :=
  Tfunction (tptr (Tstruct camera._Camera noattr) :: tptr tfloat :: tptr tfloat :: nil)
    tint cc_default.

(* the fourteen distinct entries of sModeTransitions (camera.c:465) *)
Definition trans_ids : list ident :=
  [ camera._update_radial_camera; camera._update_outward_radial_camera;
    camera._update_behind_mario_camera; camera._update_mario_camera;
    camera._unused_update_mode_5_camera; camera._update_c_up;
    camera._nop_update_water_camera; camera._update_slide_or_0f_camera;
    camera._update_in_cannon; camera._update_boss_fight_camera;
    camera._update_parallel_tracking_camera; camera._update_fixed_camera;
    camera._update_8_directions_camera; camera._update_spiral_stairs_camera ].

(* per TU: a function of the transition type is one of the fourteen *)
Definition tu_trans_ok (q : Clight.program) : bool :=
  PTree_Properties.for_all (prog_defmap q) (fun id gd =>
    match gd with
    | Gfun fd => if type_eq (type_of_fundef fd) trans_ty then mem_id id trans_ids else true
    | Gvar _ => true
    end).

(* THE CERTIFICATE: one vm sweep over every linked TU *)
Lemma all_trans_ok : forallb tu_trans_ok (mario.prog :: tu_rest) = true.
Proof. vm_compute. reflexivity. Qed.

(* NON-VACUITY: the table really holds these functions (its initializer's
   addrof targets are all in trans_ids; the first slot is NULL) *)
Example trans_table_cover :
  forallb (fun ini => match ini with
                      | Init_addrof f _ => mem_id f trans_ids
                      | _ => true end)
    (gvar_init camera.v_sModeTransitions) = true.
Proof. vm_compute. reflexivity. Qed.

Lemma link_chain_def_origin :
  forall l p lp id gd,
    link_chain p l = Some lp ->
    (prog_defmap lp) ! id = Some gd ->
    (prog_defmap p) ! id = Some gd \/ exists q, In q l /\ (prog_defmap q) ! id = Some gd.
Proof.
  induction l as [| r l' IH]; intros p lp id gd Hc Hdm; cbn [link_chain] in Hc.
  - injection Hc as <-. left. exact Hdm.
  - destruct (link p r) as [pr |] eqn:Hpr; [ | discriminate ].
    destruct (IH pr lp id gd Hc Hdm) as [Hpr_dm | (q & Hin & Hq)].
    + destruct (InitMemSat.clight_link_globdef_origin _ _ _ _ _ Hpr Hpr_dm) as [Hp | Hr].
      * left. exact Hp.
      * right. exists r. split; [ apply in_eq | exact Hr ].
    + right. exists q. split; [ apply in_cons; exact Hin | exact Hq ].
Qed.

Lemma tu_trans_ok_fd : forall q id fd,
    tu_trans_ok q = true -> (prog_defmap q) ! id = Some (Gfun fd) ->
    type_of_fundef fd = trans_ty -> mem_id id trans_ids = true.
Proof.
  intros q id fd Hok Hdm Hty. unfold tu_trans_ok in Hok.
  pose proof (proj1 (PTree_Properties.for_all_correct _ _) Hok id (Gfun fd) Hdm) as Hrow.
  cbv beta iota in Hrow. rewrite Hty in Hrow.
  destruct (type_eq trans_ty trans_ty) as [_ | N]; [ exact Hrow | exact (False_ind _ (N eq_refl)) ].
Qed.

Lemma trans_fd_ids : forall lp, linked12 lp -> forall b fd,
    Genv.find_funct_ptr (lp_ge lp) b = Some fd -> type_of_fundef fd = trans_ty ->
    exists id, mem_id id trans_ids = true /\ (prog_defmap lp) ! id = Some (Gfun fd).
Proof.
  intros lp H12 b fd Hfp Hty.
  apply Genv.find_funct_ptr_iff in Hfp.
  destruct (Genv.find_def_inversion _ _ Hfp) as (id & Hin).
  assert (Hnr : list_norepet (prog_defs_names lp)).
  { unfold linked12 in H12.
    apply (InitMemSat.link_chain_norepet tu_rest mario.prog lp); [ discriminate | exact H12 ]. }
  assert (Hdm : (prog_defmap lp) ! id = Some (Gfun fd))
    by (apply prog_defmap_norepet; assumption).
  exists id. split; [ | exact Hdm ].
  pose proof all_trans_ok as Hall. cbn [forallb] in Hall. apply andb_prop in Hall as [Hm Hr].
  unfold linked12 in H12.
  destruct (link_chain_def_origin _ _ _ _ _ H12 Hdm) as [Hq | (q & Hq & Hqd)].
  - exact (tu_trans_ok_fd _ _ _ Hm Hq Hty).
  - exact (tu_trans_ok_fd _ _ _ (proj1 (forallb_forall _ _) Hr q Hq) Hqd Hty).
Qed.

(* ---------------------------------------------------------------------- *)
(* 5. The chain of callee bodies, bottom-up.                                *)
(* ---------------------------------------------------------------------- *)

Inductive ktu : Type := TCam | TMath | TSurf.

(* a chain entry: callee, its TU, parameter classes, return class *)
Definition kent : Type := (ident * ktu * list kcls * kcls)%type.

Definition kdm (dmc dmm dms : PTree.t (globdef Clight.fundef type)) (tu : ktu) :=
  match tu with TCam => dmc | TMath => dmm | TSurf => dms end.

Fixpoint kchain (dmc dmm dms : PTree.t (globdef Clight.fundef type)) (gs : list ident)
    (done : kctab) (todo : list kent) : bool :=
  match todo with
  | nil => true
  | (fid, tu, pcs, rc) :: rest =>
      match (kdm dmc dmm dms tu) ! fid with
      | Some (Gfun (Internal f)) => kchk gs done nil pcs rc f
      | _ => false
      end && kchain dmc dmm dms gs ((fid, (pcs, rc)) :: done) rest
  end.

Fixpoint kchain_tab (done : kctab) (todo : list kent) : kctab :=
  match todo with
  | nil => done
  | (fid, _, pcs, rc) :: rest => kchain_tab ((fid, (pcs, rc)) :: done) rest
  end.

(* the SafeB globals the walk reads pointers out of *)
Definition cam_gs : list ident := camera_safe_syms.

(* the leaves proved outside the walk: sqrtf (FPU floor) and play_sound *)
Definition cam_init : kctab :=
  [ (math_util._sqrtf, ([kA], kA)); (camera._play_sound, ([kA; kA], kA)) ].

Definition cam_chain : list kent :=
  [ (math_util._atan2_lookup, TMath, [kA; kA], kA);
    (math_util._atan2s, TMath, [kA; kA], kA);
    (math_util._approach_f32, TMath, [kA; kA; kA; kA], kA);
    (math_util._vec3f_copy, TMath, [kW; kA], kA);
    (math_util._vec3f_set, TMath, [kW; kA; kA; kA], kA);
    (math_util._vec3f_add, TMath, [kW; kA], kA);
    (math_util._vec3f_get_dist_and_angle, TMath, [kA; kA; kW; kW; kW], kA);
    (math_util._vec3f_set_dist_and_angle, TMath, [kA; kW; kA; kA; kA], kA);
    (surface_collision._find_floor_from_list, TSurf, [kS; kA; kA; kA; kL], kS);
    (surface_collision._find_floor, TSurf, [kA; kA; kA; kL], kA);
    (surface_collision._find_ceil_from_list, TSurf, [kS; kA; kA; kA; kL], kS);
    (surface_collision._find_ceil, TSurf, [kA; kA; kA; kL], kA);
    (surface_collision._find_water_level, TSurf, [kA; kA], kA);
    (camera._calc_abs_dist, TCam, [kA; kA], kA);
    (camera._calculate_pitch, TCam, [kA; kA], kA);
    (camera._calculate_yaw, TCam, [kA; kA], kA);
    (camera._clamp_positions_and_find_yaw, TCam, [kW; kA; kA; kA; kA; kA], kA);
    (camera._find_in_bounds_yaw_wdw_bob_thi, TCam, [kW; kA; kA], kA);
    (camera._look_down_slopes, TCam, [kA], kA);
    (camera._vec3f_sub, TCam, [kW; kA], kA);
    (camera._play_sound_button_change_blocked, TCam, [], kA);
    (camera._play_sound_cbutton_up, TCam, [], kA);
    (camera._play_sound_cbutton_side, TCam, [], kA);
    (camera._play_sound_cbutton_down, TCam, [], kA);
    (camera._play_camera_buzz_if_cdown, TCam, [], kA);
    (camera._play_camera_buzz_if_c_sideways, TCam, [], kA);
    (camera._store_lakitu_cam_info_for_c_up, TCam, [kS], kA);
    (camera._set_mode_c_up, TCam, [kS], kA);
    (camera._handle_c_button_movement, TCam, [kS], kA);
    (camera._camera_approach_s16_symmetric_bool, TCam, [kW; kA; kA], kA);
    (camera._camera_approach_f32_symmetric_bool, TCam, [kW; kA; kA], kA);
    (camera._approach_s16_asymptotic_bool, TCam, [kW; kA; kA], kA);
    (camera._approach_f32_asymptotic_bool, TCam, [kW; kA; kA], kA);
    (camera._calc_y_to_curr_floor, TCam, [kW; kA; kA; kW; kA; kA], kA);
    (camera._focus_on_mario, TCam, [kW; kW; kA; kA; kA; kA; kA], kA);
    (camera._set_camera_yaw_shake, TCam, [kA; kA; kA], kA);
    (camera._set_camera_roll_shake, TCam, [kA; kA; kA], kA);
    (camera._set_camera_pitch_shake, TCam, [kA; kA; kA], kA);
    (camera._set_environmental_camera_shake, TCam, [kA], kA);
    (camera._offset_rotated, TCam, [kW; kA; kA; kA], kA);
    (camera._object_pos_to_vec3f, TCam, [kW; kA], kA);
    (camera._lakitu_zoom, TCam, [kA; kA], kA);
    (camera._rotate_in_xz, TCam, [kW; kA; kA], kA);
    (camera._rotate_in_yz, TCam, [kW; kA; kA], kA);
    (camera._calculate_angles, TCam, [kA; kA; kW; kW], kA);
    (camera._pan_ahead_of_player, TCam, [kS], kA);
    (camera._update_radial_camera, TCam, [kS; kW; kW], kA);
    (camera._update_outward_radial_camera, TCam, [kS; kW; kW], kA);
    (camera._update_behind_mario_camera, TCam, [kS; kW; kW], kA);
    (camera._update_mario_camera, TCam, [kS; kW; kW], kA);
    (camera._unused_update_mode_5_camera, TCam, [kS; kW; kW], kA);
    (camera._update_c_up, TCam, [kS; kW; kW], kA);
    (camera._nop_update_water_camera, TCam, [kS; kW; kW], kA);
    (camera._update_slide_or_0f_camera, TCam, [kS; kW; kW], kA);
    (camera._update_in_cannon, TCam, [kS; kW; kW], kA);
    (camera._update_boss_fight_camera, TCam, [kS; kW; kW], kA);
    (camera._update_parallel_tracking_camera, TCam, [kS; kW; kW], kA);
    (camera._update_fixed_camera, TCam, [kS; kW; kW], kA);
    (camera._update_8_directions_camera, TCam, [kS; kW; kW], kA);
    (camera._update_spiral_stairs_camera, TCam, [kS; kW; kW], kA) ].

(* ---------------------------------------------------------------------- *)
(* 6. The walk, at the concrete MWF_real.                                   *)
(* ---------------------------------------------------------------------- *)

Section KB.
  Variable lp : Clight.program.
  Hypothesis H12 : linked12 lp.
  Variables bm bc : block.
  Variable oc0 : ptrofs.
  Variable SafeB : block -> Prop.
  Hypothesis HSafeB_syms : SafeB_syms_ok lp SafeB.
  Hypothesis Hspawn : exists init, spawn_ok lp init bm bc oc0.

  (* the outer call's entry nextblock: everything older lies below it *)
  Variable nb0 : block.
  Hypothesis Hn_bm : Plt bm nb0.
  Hypothesis Hn_safe : forall b, SafeB b -> Plt b nb0.
  Hypothesis Hn_glob : forall gid bg, Genv.find_symbol (lp_ge lp) gid = Some bg -> Plt bg nb0.

  Let ge := lp_ge lp.
  Let MWF := MWF_real lp bm bc oc0 SafeB.
  Let OF := ow_facts bm MWF.

  Definition GBk (b : block) : Prop :=
    exists g, Genv.find_symbol ge g = Some b /\ mem_id g ObjExtBodies.mwf_syms = false.

  Let pc := kpc SafeB GBk nb0.
  Let vok := kvok SafeB GBk nb0.

  Lemma kb_not_bm : forall b, SafeB b -> b <> bm.
  Proof. destruct Hspawn as (init & Hs). exact (safeb_not_bm lp init bm bc oc0 SafeB Hs HSafeB_syms). Qed.
  Lemma kb_Hbc_bm : bc <> bm.
  Proof. destruct Hspawn as (init & Hs). exact (spawn_Hbc_bm lp init bm bc oc0 Hs). Qed.

  Lemma kfresh_ne : forall b b', Ple nb0 b -> Plt b' nb0 -> b <> b'.
  Proof. intros b b' H1 H2 E. subst. exact (Plt_strict _ (Plt_Ple_trans _ _ _ H2 H1)). Qed.

  Lemma gb_old : forall b, GBk b -> Plt b nb0.
  Proof. intros b (g & Hg & _). exact (Hn_glob _ _ Hg). Qed.

  (* the carried invariant *)
  Definition KInv (m : mem) : Prop :=
    OF m /\ Ple nb0 (Mem.nextblock m) /\
    (forall b ofs b' o', Ple nb0 b -> Mem.load Mint32 m b ofs = Some (Vptr b' o') -> pc kW b').

  Lemma kinv_rl_other : forall ch m b z v m',
      Plt b nb0 -> Mem.store ch m b z v = Some m' ->
      (forall b1 ofs b' o', Ple nb0 b1 -> Mem.load Mint32 m b1 ofs = Some (Vptr b' o') -> pc kW b') ->
      (forall b1 ofs b' o', Ple nb0 b1 -> Mem.load Mint32 m' b1 ofs = Some (Vptr b' o') -> pc kW b').
  Proof.
    intros ch m b z v m' Hb Hst HL b1 ofs b' o' Hb1 Hld.
    rewrite (Mem.load_store_other _ _ _ _ _ _ Hst) in Hld.
    - exact (HL _ _ _ _ Hb1 Hld).
    - left. exact (kfresh_ne _ _ Hb1 Hb).
  Qed.

  Lemma kinv_store_safe : forall ch m b z v m', SafeB b -> safev SafeB v ->
      Mem.store ch m b z v = Some m' -> KInv m -> KInv m'.
  Proof.
    intros ch m b z v m' Hs Hv Hst (Hf & Hnb & HL).
    split; [ | split ].
    - exact (sb_safe_store lp bm bc oc0 SafeB HSafeB_syms Hspawn b ch z v m m' Hs Hv Hst Hf).
    - rewrite (Mem.nextblock_store _ _ _ _ _ _ Hst). exact Hnb.
    - exact (kinv_rl_other _ _ _ _ _ _ (Hn_safe _ Hs) Hst HL).
  Qed.

  Lemma kinv_store_local : forall ch m b z v m', Ple nb0 b -> vok kW v ->
      Mem.store ch m b z v = Some m' -> KInv m -> KInv m'.
  Proof.
    intros ch m b z v m' Hb Hv Hst ((Hvb & Hsat & HM) & Hnb & HL).
    split; [ split; [ eauto using Mem.store_valid_block_1 | split ] | split ].
    - eapply action_sat_unchanged_on with (m := m); [ | exact Hvb | exact Hsat ].
      eapply Mem.store_unchanged_on; [ exact Hst | ].
      intros i _ [Hb' _]. exact (kfresh_ne _ _ Hb Hn_bm Hb').
    - destruct Hspawn as (init & Hsp).
      destruct (spawn_Hbc_sym lp init bm bc oc0 Hsp) as (gid & Hsy).
      eapply mwf_real_local_store; [ exact kb_Hbc_bm | exact HM | | | | | exact Hst ].
      + exact (kfresh_ne _ _ Hb Hn_bm).
      + exact (kfresh_ne _ _ Hb (Hn_glob _ _ Hsy)).
      + intros Hs. exact (kfresh_ne _ _ Hb (Hn_safe _ Hs) eq_refl).
      + intros gid' bg Hg. exact (kfresh_ne _ _ Hb (Hn_glob _ _ Hg)).
    - rewrite (Mem.nextblock_store _ _ _ _ _ _ Hst). exact Hnb.
    - intros b1 ofs b' o' Hb1 Hld.
      destruct (Mem.load_pointer_store _ _ _ _ _ _ _ _ _ _ _ Hst Hld)
        as [(Ev & _ & _ & _) | Hdis].
      + exact (Hv _ _ Ev).
      + rewrite (Mem.load_store_other _ _ _ _ _ _ Hst _ _ _ Hdis) in Hld.
        exact (HL _ _ _ _ Hb1 Hld).
  Qed.

  Lemma kinv_store_np_rl : forall ch m b z v m',
      (forall bb oo, v <> Vptr bb oo) -> Mem.store ch m b z v = Some m' ->
      (forall b1 ofs b' o', Ple nb0 b1 -> Mem.load Mint32 m b1 ofs = Some (Vptr b' o') -> pc kW b') ->
      (forall b1 ofs b' o', Ple nb0 b1 -> Mem.load Mint32 m' b1 ofs = Some (Vptr b' o') -> pc kW b').
  Proof.
    intros ch m b z v m' Hnp Hst HL b1 ofs b' o' Hb1 Hld.
    destruct (Mem.load_pointer_store _ _ _ _ _ _ _ _ _ _ _ Hst Hld)
      as [(Ev & _ & _ & _) | Hdis].
    - exact (False_ind _ (Hnp _ _ Ev)).
    - rewrite (Mem.load_store_other _ _ _ _ _ _ Hst _ _ _ Hdis) in Hld.
      exact (HL _ _ _ _ Hb1 Hld).
  Qed.

  Lemma kinv_store_glob : forall ch m b z v m', GBk b ->
      (forall bb oo, v <> Vptr bb oo) ->
      Mem.store ch m b z v = Some m' -> KInv m -> KInv m'.
  Proof.
    intros ch m b z v m' (g & Hg & Hng) Hnp Hst (Hf & Hnb & HL).
    split; [ | split ].
    - exact (ObjExtBodies.np_store_pres lp bm bc oc0 SafeB Hspawn g b ch z v m m' Hng Hg Hnp Hst Hf).
    - rewrite (Mem.nextblock_store _ _ _ _ _ _ Hst). exact Hnb.
    - exact (kinv_store_np_rl _ _ _ _ _ _ Hnp Hst HL).
  Qed.

  Lemma kinv_store_w : forall ch m b z v m', pc kW b ->
      (forall bb oo, v <> Vptr bb oo) ->
      Mem.store ch m b z v = Some m' -> KInv m -> KInv m'.
  Proof.
    intros ch m b z v m' Hb Hnp Hst Hi.
    destruct Hb as [Hs | [Hl | Hg]].
    - refine (kinv_store_safe _ _ _ _ _ _ Hs _ Hst Hi). intros bb oo E. exact (False_ind _ (Hnp _ _ E)).
    - refine (kinv_store_local _ _ _ _ _ _ Hl _ Hst Hi). intros bb oo E. exact (False_ind _ (Hnp _ _ E)).
    - exact (kinv_store_glob _ _ _ _ _ _ Hg Hnp Hst Hi).
  Qed.

  (* entry: the frame's allocations *)
  Lemma kav_inv : forall e0 m vars e m1,
      alloc_variables ge e0 m vars e m1 ->
      (forall x b ty, e0 ! x = Some (b, ty) -> Ple nb0 b) ->
      Ple nb0 (Mem.nextblock m) ->
      (forall b ofs b' o', Ple nb0 b -> Mem.load Mint32 m b ofs = Some (Vptr b' o') -> pc kW b') ->
      Ple nb0 (Mem.nextblock m1) /\
      (forall b ofs b' o', Ple nb0 b -> Mem.load Mint32 m1 b ofs = Some (Vptr b' o') -> pc kW b') /\
      (forall x b ty, e ! x = Some (b, ty) -> Ple nb0 b).
  Proof.
    intros e0 m vars e m1 Hav.
    induction Hav as [e0 m0 | e0 m0 id ty vars0 m1 b1 m2 e2 Hal Hrest IH];
      intros He0 Hnb HL; [ auto | ].
    apply IH.
    - intros x b ty' Hx. destruct (peq x id) as [-> | Hne].
      + rewrite PTree.gss in Hx. injection Hx as <- _.
        rewrite (Mem.alloc_result _ _ _ _ _ Hal). exact Hnb.
      + rewrite PTree.gso in Hx by exact Hne. exact (He0 _ _ _ Hx).
    - rewrite (Mem.nextblock_alloc _ _ _ _ _ Hal). eapply Ple_trans; [ exact Hnb | apply Ple_succ ].
    - intros b ofs b' o' Hb Hld.
      destruct (peq b b1) as [-> | Hne].
      + pose proof (Mem.load_alloc_same _ _ _ _ _ Hal _ _ _ Hld) as E. discriminate E.
      + assert (Hv : Mem.valid_block m0 b).
        { destruct (Mem.valid_block_alloc_inv _ _ _ _ _ Hal _ (PrintBodies.load_valid _ _ _ _ _ Hld))
            as [E | Hv]; [ congruence | exact Hv ]. }
        rewrite (Mem.load_alloc_unchanged _ _ _ _ _ Hal _ _ _ Hv) in Hld.
        exact (HL _ _ _ _ Hb Hld).
  Qed.

  (* exit: freeing the frame *)
  Lemma kfree_inv : forall l m m',
      Mem.free_list m l = Some m' ->
      Ple nb0 (Mem.nextblock m) ->
      (forall b ofs b' o', Ple nb0 b -> Mem.load Mint32 m b ofs = Some (Vptr b' o') -> pc kW b') ->
      Ple nb0 (Mem.nextblock m') /\
      (forall b ofs b' o', Ple nb0 b -> Mem.load Mint32 m' b ofs = Some (Vptr b' o') -> pc kW b').
  Proof.
    intros l m m' Hfl Hnb HL. split.
    - clear HL. revert m Hfl Hnb. induction l as [| [[b lo] hi] l IH]; intros m Hfl Hnb.
      + cbn in Hfl. injection Hfl as <-. exact Hnb.
      + cbn in Hfl. destruct (Mem.free m b lo hi) as [m1|] eqn:Hf; [ | discriminate Hfl ].
        apply (IH m1 Hfl). rewrite (Mem.nextblock_free _ _ _ _ _ Hf). exact Hnb.
    - intros b ofs b' o' Hb Hld.
      exact (HL _ _ _ _ Hb (free_list_load_2 _ _ _ Hfl _ _ _ _ Hld)).
  Qed.

  (* ---- the per-function spec ---- *)
  Definition kcsp (pcs : list kcls) (rc : kcls) (fd : Clight.fundef) : Prop :=
    forall m vargs t m' vres,
      eval_funcall function_entry2 ge m fd vargs t m' vres ->
      Forall2 vok pcs vargs -> KInv m -> KInv m' /\ vok rc vres.

  Definition kcres (fid : ident) (pcs : list kcls) (rc : kcls) : Prop :=
    forall b fd, Genv.find_symbol ge fid = Some b ->
      Genv.find_funct ge (Vptr b Ptrofs.zero) = Some fd -> kcsp pcs rc fd.

  Definition kct_ok (ct : kctab) : Prop :=
    forall fid pcs rc, kct_find fid ct = Some (pcs, rc) -> kcres fid pcs rc.

  Definition kit_ok (it : kitab) : Prop :=
    forall ty pcs rc, kit_find ty it = Some (pcs, rc) ->
      forall vf fd, Genv.find_funct ge vf = Some fd -> type_of_fundef fd = ty -> kcsp pcs rc fd.

  Lemma kcres_of : forall q fid f pcs rc,
      linkorder q lp -> (prog_defmap q) ! fid = Some (Gfun (Internal f)) ->
      kcsp pcs rc (Internal f) -> kcres fid pcs rc.
  Proof.
    intros q fid f pcs rc LO Hdm Hs b fd Hsy Hff.
    destruct (linkorder_resolves_funct lp _ _ _ LO Hdm) as (b' & Hs' & Hff').
    unfold ge, lp_ge in Hsy, Hff. rewrite Hsy in Hs'. injection Hs' as <-.
    rewrite Hff' in Hff. injection Hff as <-. exact Hs.
  Qed.

  Definition KTP (tc : ident -> kcls) (le : temp_env) : Prop :=
    forall t v, le ! t = Some v -> vok (tc t) v.

  Definition KEIL (lv : list ident) (e : env) : Prop :=
    (forall x b ty, e ! x = Some (b, ty) -> mem_id x lv = true /\ Ple nb0 b)
    /\ (forall x, mem_id x lv = true -> e ! x <> None).

  Section Fn.
    Variable lv gs : list ident.
    Variable tc : ident -> kcls.
    Variable ct : kctab.
    Variable it : kitab.
    Variable e : env.
    Hypothesis HEI : KEIL lv e.
    Hypothesis Hgs : forall x b, mem_id x gs = true -> Genv.find_symbol ge x = Some b -> SafeB b.
    Hypothesis Hct : kct_ok ct.
    Hypothesis Hit : kit_ok it.

    Lemma kb_R7 : forall m, KInv m -> forall b ofs b' o', SafeB b ->
        Mem.loadv Mint32 m (Vptr b ofs) = Some (Vptr b' o') -> SafeB b'.
    Proof.
      intros m ((_ & _ & HM) & _) b ofs b' o' Hs Hld.
      exact (mwf_real_chase_step lp bm bc oc0 SafeB m b ofs b' o' HM Hs Hld).
    Qed.

    Lemma kb_x : forall le m a v, KTP tc le -> KInv m ->
        eval_expr ge e le m a v -> vok (kx lv gs tc a) v.
    Proof.
      intros le m a v HP Hi Hev.
      exact (kx_sound ge e le m SafeB nb0 lv gs tc HP (proj1 HEI) (proj2 HEI) Hgs
               (kb_R7 m Hi) (proj2 (proj2 Hi)) a v Hev).
    Qed.

    Lemma kb_lv : forall le m a b o bf, KTP tc le -> KInv m ->
        eval_lvalue ge e le m a b o bf -> pc (klv lv gs tc a) b.
    Proof.
      intros le m a b o bf HP Hi Hev.
      exact (klv_sound ge e le m SafeB nb0 lv gs tc HP (proj1 HEI) (proj2 HEI) Hgs
               (kb_R7 m Hi) (proj2 (proj2 Hi)) a b o bf Hev).
    Qed.

    Lemma kb_set : forall id a le m v,
        kp_set lv gs tc id a = true -> KTP tc le -> KInv m ->
        eval_expr ge e le m a v -> KTP tc (PTree.set id v le).
    Proof.
      intros id a le m v Hok HP Hi Hev t v' Hg.
      destruct (peq t id) as [-> | Hne].
      - rewrite PTree.gss in Hg. injection Hg as <-.
        exact (kle_vok _ _ _ _ _ _ Hok (kb_x _ _ _ _ HP Hi Hev)).
      - rewrite PTree.gso in Hg by exact Hne. exact (HP _ _ Hg).
    Qed.

    (* the stored value's class: from the rhs class, or the lvalue type *)
    Lemma kstore_val : forall K le m r v2 ty vv,
        KTP tc le -> KInv m -> eval_expr ge e le m r v2 ->
        sem_cast v2 (typeof r) ty m = Some vv ->
        kle (kx lv gs tc r) K || nonptr_scalar ty = true ->
        vok K vv /\ (K = kN \/ nonptr_scalar ty = true -> forall bb oo, vv <> Vptr bb oo).
    Proof.
      intros K le m r v2 ty vv HP Hi Hre Hc Hor.
      apply orb_true_iff in Hor as [Hk | Hn].
      - assert (Hv : vok K vv).
        { intros bb oo Ev. subst vv.
          exact (kle_pc _ _ _ _ _ _ Hk (kb_x _ _ _ _ HP Hi Hre _ _ (sem_cast_vptr_inv _ _ _ _ _ _ Hc))). }
        split; [ exact Hv | ].
        intros [-> | Hn] bb oo Ev.
        + exact (Hv _ _ Ev).
        + exact (sem_cast_to_nonptr_scalar _ _ _ _ _ Hn Hc _ _ Ev).
      - pose proof (sem_cast_to_nonptr_scalar _ _ _ _ _ Hn Hc) as Hnp.
        split; [ exact (kvok_np _ _ _ _ _ Hnp) | intros _; exact Hnp ].
    Qed.

    Lemma kb_store_mem : forall c ch m b z vv m' K ty,
        (match c with
         | kS => kle K kS || nonptr_scalar ty
         | kL => kle K kW || nonptr_scalar ty
         | kW => kle K kN || nonptr_scalar ty
         | _ => false end) = true ->
        pc c b ->
        (forall K', kle K K' || nonptr_scalar ty = true ->
           vok K' vv /\ (K' = kN \/ nonptr_scalar ty = true -> forall bb oo, vv <> Vptr bb oo)) ->
        Mem.store ch m b z vv = Some m' -> KInv m -> KInv m'.
    Proof.
      intros c ch m b z vv m' K ty Hc Hp Hval Hst Hi.
      destruct c; try discriminate Hc.
      - destruct (Hval kS Hc) as (Hv & _).
        exact (kinv_store_safe _ _ _ _ _ _ Hp Hv Hst Hi).
      - destruct (Hval kW Hc) as (Hv & _).
        exact (kinv_store_local _ _ _ _ _ _ Hp Hv Hst Hi).
      - destruct (Hval kN Hc) as (_ & Hnp).
        refine (kinv_store_w _ _ _ _ _ _ Hp _ Hst Hi).
        apply Hnp. apply orb_true_iff in Hc as [Hk | Hn]; [ left | right; exact Hn ].
        destruct K; try discriminate Hk; reflexivity.
    Qed.

    Lemma kb_store : forall l r le m t le' m' out,
        kp_store lv gs tc l r = true -> KTP tc le ->
        exec_stmt function_entry2 ge e le m (Sassign l r) t le' m' out ->
        KInv m -> KInv m'.
    Proof.
      intros l r le m t le' m' out Hok HP Hx Hi.
      unfold kp_store in Hok. apply andb_prop in Hok as [Hbv Hcl].
      inv Hx.
      lazymatch goal with Hlv : eval_lvalue _ _ _ _ _ ?loc _ _ |- _ =>
        pose proof (kb_lv _ _ _ _ _ _ HP Hi Hlv) as Hpc end.
      match goal with Hre : eval_expr _ _ _ _ r ?v2, Hc : sem_cast ?v2 _ _ _ = Some ?vv |- _ =>
        pose proof (fun K' H => kstore_val K' _ _ _ _ _ _ HP Hi Hre Hc H) as Hval end.
      match goal with Ha : assign_loc _ _ _ _ _ _ _ _ |- _ => inv Ha end.
      - match goal with Hst : Mem.storev _ _ _ _ = Some _ |- _ =>
          unfold Mem.storev in Hst; exact (kb_store_mem _ _ _ _ _ _ _ _ _ Hcl Hpc Hval Hst Hi) end.
      - unfold MtxfBody.is_byval in Hbv.
        match goal with Hc : access_mode _ = By_copy |- _ => rewrite Hc in Hbv; discriminate Hbv end.
      - match goal with Hb : store_bitfield _ _ _ _ _ _ _ _ _ _ |- _ => inv Hb end.
        match goal with Hst : Mem.storev _ _ _ _ = Some _ |- _ =>
          unfold Mem.storev in Hst;
          refine (kb_store_mem _ _ _ _ _ _ _ _ _ Hcl Hpc _ Hst Hi) end.
        intros K' _. split; [ intros bb oo E; discriminate E | intros _ bb oo E; discriminate E ].
    Qed.

    Lemma kb_ret : forall rc a le m v,
        kp_ret lv gs tc rc a = true -> KTP tc le -> KInv m ->
        eval_expr ge e le m a v -> vok rc v.
    Proof.
      intros rc a le m v Hok HP Hi Hev.
      exact (kle_vok _ _ _ _ _ _ Hok (kb_x _ _ _ _ HP Hi Hev)).
    Qed.

    Lemma kb_call : forall optid a al le m t le' m' out,
        kp_call lv gs tc ct it optid a al = true -> KTP tc le ->
        exec_stmt function_entry2 ge e le m (Scall optid a al) t le' m' out ->
        KInv m -> KInv m' /\ KTP tc le'.
    Proof.
      intros optid a al le m t le' m' out Hok HP Hx Hi.
      unfold kp_call in Hok. apply andb_prop in Hok as [Hnl Hok].
      destruct (call_sig ct it a) as [[pcs rc]|] eqn:Hsig; [ | discriminate Hok ].
      apply andb_prop in Hok as [Hal Hopt].
      assert (Hcsp : forall vf fd,
                 eval_expr ge e le m a vf -> Genv.find_funct ge vf = Some fd ->
                 type_of_fundef fd = (match classify_fun (typeof a) with
                                      | fun_case_f targs tres cc => Tfunction targs tres cc
                                      | _ => Tvoid end) ->
                 kcsp pcs rc fd).
      { intros vf fd Hev Hff Hty.
        unfold call_sig in Hsig.
        destruct (direct_fid a) as [fid|] eqn:Ed.
        - destruct (direct_fid_inv _ _ Ed) as (targs & tres & cc & ->).
          apply negb_true_iff in Hnl.
          assert (Hnone : e ! fid = None).
          { destruct (e ! fid) as [[b ty]|] eqn:E; [ | reflexivity ].
            destruct (proj1 HEI _ _ _ E) as (Hm & _). congruence. }
          destruct (evar_fun_val _ _ _ _ _ _ _ _ _ Hev Hnone) as (lf & Hsy & ->).
          exact (Hct _ _ _ Hsig lf fd Hsy Hff).
        - destruct (classify_fun (typeof a)) as [targs tres cc | ] eqn:Ecf; try discriminate Hsig.
          exact (Hit _ _ _ Hsig vf fd Hff Hty). }
      inv Hx.
      match goal with Hcf : classify_fun _ = fun_case_f _ _ _,
                      Hee : eval_expr _ _ _ _ a ?vf,
                      Hff : Genv.find_funct _ ?vf = Some ?fd,
                      Hty : type_of_fundef ?fd = _,
                      Hfc : eval_funcall _ _ _ ?fd _ _ _ _,
                      Hel : eval_exprlist _ _ _ _ _ _ _ |- _ =>
        rewrite Hcf in Hcsp;
        destruct (Hcsp _ _ Hee Hff Hty _ _ _ _ _ Hfc
                    (kargs_sound _ _ _ _ SafeB nb0 lv gs tc HP (proj1 HEI) (proj2 HEI) Hgs
                       (kb_R7 m Hi) (proj2 (proj2 Hi)) _ _ _ Hel _ Hal) Hi) as (Hi' & Hr) end.
      split; [ exact Hi' | ].
      intros t0 v0 Hg. destruct optid as [ti|]; cbn [set_opttemp] in Hg; [ | exact (HP _ _ Hg) ].
      destruct (peq t0 ti) as [-> | Hne].
      - rewrite PTree.gss in Hg. injection Hg as <-. exact (kle_vok _ _ _ _ _ _ Hopt Hr).
      - rewrite PTree.gso in Hg by exact Hne. exact (HP _ _ Hg).
    Qed.
  End Fn.

  (* THE BODY LEMMA *)
  Lemma kbody_csp : forall gs tc ct it pcs rc f,
      (forall x b, mem_id x gs = true -> Genv.find_symbol ge x = Some b -> SafeB b) ->
      kchk_tc gs tc ct it pcs rc f = true ->
      kct_ok ct -> kit_ok it ->
      kcsp pcs rc (Internal f).
  Proof.
    intros gs tc ct it pcs rc f Hgs Hchk Hct Hit m vargs t m' vres Hevf Hva Hi.
    unfold kchk_tc in Hchk. apply andb_prop in Hchk as [Hchk Hpar].
    destruct Hi as (Hf & Hnb & HL).
    pose proof Hf as (Hv & Hs & HM).
    inv Hevf.
    match goal with He : function_entry2 _ _ _ _ _ _ _ |- _ => inv He end.
    match goal with Ha : alloc_variables _ _ _ _ _ _ |- _ => rename Ha into Hav end.
    match goal with Hb : bind_parameter_temps _ _ _ = Some _ |- _ => rename Hb into Hbp end.
    match goal with Hfl : Mem.free_list _ _ = Some _ |- _ => rename Hfl into Hfree end.
    match goal with Ho : outcome_result_value _ _ _ _ |- _ => rename Ho into Hor end.
    set (lv := map fst (fn_vars f)) in *.
    pose proof (MtxfBody.av_facts bm MWF _ _ _ _ _ _ (mwf_real_alloc lp bm bc oc0 SafeB kb_Hbc_bm) Hav Hf)
      as Hf1.
    destruct (kav_inv _ _ _ _ _ Hav
                ltac:(intros x b ty Hx; rewrite PTree.gempty in Hx; discriminate Hx) Hnb HL)
      as (Hnb1 & HL1 & He1).
    assert (HEI : KEIL lv e).
    { split.
      - intros x b ty Hx. split; [ | exact (He1 _ _ _ Hx) ].
        destruct (mem_id x lv) eqn:E; [ reflexivity | exfalso ].
        rewrite (alloc_variables_unbound _ _ _ _ _ _ Hav x (MtxfBody.mem_id_notin _ _ E)) in Hx.
        rewrite PTree.gempty in Hx. discriminate Hx.
      - intros x Hx. destruct (alloc_variables_in_bound _ _ _ _ _ _ Hav x (MtxfBody.mem_id_In _ _ Hx))
          as (b & ty & E). congruence. }
    assert (HP1 : KTP tc le1).
    { intros t0 v Hg.
      destruct (ObjHelpersBodies.bind_get _ _ _ _ _ _ Hbp Hg) as [Hu | (i & Hi & Hvi)].
      - apply MtxfBody.create_undef_temps_get in Hu. subst v. apply kvok_undef.
      - destruct (PrintBodies.forall2_nth_l _ _ _ _ _ Hva Hvi) as (c & Hc).
        exact (kle_vok _ _ _ _ _ _ (kpar_ok_nth _ _ _ _ _ _ Hpar Hi Hc)
                 (PrintBodies.forall2_nth _ _ _ _ _ _ Hva Hc Hvi)). }
    lazymatch goal with Hb : exec_stmt _ _ ?E ?LE ?M1 _ _ _ ?M2 _ |- _ =>
      destruct (sw_walk ge E KInv (KTP tc) (vok rc)
                  (kp_set lv gs tc) (kp_store lv gs tc) (kp_call lv gs tc ct it) (kp_ret lv gs tc rc)
                  ltac:(intros ? ? ? ? ? J1 J2 J3 J4; eapply kb_set; eassumption)
                  ltac:(intros ? ? ? ? ? ? ? ? J1 J2 J3 J4; eapply kb_store; eassumption)
                  ltac:(intros ? ? ? ? ? ? ? ? ? J1 J2 J3 J4; eapply kb_call; eassumption)
                  ltac:(intros ? ? ? ? J1 J2 J3 J4; eapply kb_ret; eassumption)
                  _ _ _ _ _ _ _ _ Hb eq_refl Hchk HP1 (conj Hf1 (conj Hnb1 HL1)))
        as (((Hv2 & Hs2 & HM2) & Hnb2 & HL2) & _ & Hout)
    end.
    assert (Hfa : Forall (fun blh => let '(b,_,_) := blh in b <> bm)
                    (blocks_of_env (lp_ge lp) e)).
    { eapply Forall_impl; [ | exact (blocks_of_env_bm lp bm _ _ _ _ Hav Hv) ].
      intros [[b lo] hi] Hq. exact Hq. }
    destruct (vfc_free_list_frame not_tainted bm _ _ _ Hfa Hfree Hv2 Hs2) as (Hvf & Hsf).
    destruct (kfree_inv _ _ _ Hfree Hnb2 HL2) as (Hnb3 & HL3).
    split; [ exact (conj (conj Hvf (conj Hsf (mwf_real_free lp bm bc oc0 SafeB kb_Hbc_bm _ _ _ Hfree HM2)))
                         (conj Hnb3 HL3)) | ].
    intros bb oo Ev. subst vres.
    destruct out as [ | | | [[v' t']|] ]; cbn in Hor.
    - contradiction Hor.
    - contradiction Hor.
    - destruct (fn_return f); try contradiction Hor; discriminate Hor.
    - destruct Hor as (_ & Hc). exact (Hout _ _ (sem_cast_vptr_inv _ _ _ _ _ _ Hc)).
    - destruct (fn_return f); try contradiction Hor; discriminate Hor.
  Qed.

  (* ---- callees proved outside the walk ---- *)

  (* a function proved to keep the carried facts (ObjExtBodies.sym_pres) whose
     body neither allocates nor calls: nextblock and every fresh block's
     content stay (its stores hit global-rooted chains, all below nb0) *)
  Lemma kcres_sqrtf : sqrtf_spec -> kcres math_util._sqrtf [kA] kA.
  Proof.
    intros Hsq b fd Hs Hff m vargs t m' vres Hevf _ Hi.
    pose proof (MtxfBody.sqrtf_memid lp H12 Hsq b fd m vargs t m' vres Hs Hff Hevf) as ->.
    split; [ exact Hi | intros bb oo _; exact I ].
  Qed.

  Lemma ct_nil : kct_ok nil.
  Proof. intros fid pcs rc H. discriminate H. Qed.

  Lemma ct_cons : forall fid s ct, kcres fid (fst s) (snd s) -> kct_ok ct -> kct_ok ((fid, s) :: ct).
  Proof.
    intros fid s ct Hs Hct fid' pcs rc H. unfold kct_find in H. cbn [find fst] in H.
    destruct (Pos.eqb fid fid') eqn:E.
    - apply Pos.eqb_eq in E. subst fid'. injection H as Es. subst s. exact Hs.
    - exact (Hct fid' pcs rc H).
  Qed.

  Lemma it_nil : kit_ok nil.
  Proof. intros ty pcs rc H. discriminate H. Qed.
  (* ---- play_sound: proved to keep the carried facts (AudioBodies); its
     body has no locals and no calls and stores only into global-rooted
     chains, so it keeps nextblock and every fresh block's contents ---- *)
  Definition gstore_only (f : Clight.function) : bool :=
    match fn_vars f with nil => true | _ => false end &&
    sw_chk (fun _ _ => true)
      (fun l _ => match SaveFileBody.groot_l l with Some _ => true | None => false end)
      (fun _ _ _ => false) (fun _ => true) (fn_body f).

  Lemma assign_loc_nextblock : forall ce ty m loc ofs bf v m',
      assign_loc ce ty m loc ofs bf v m' -> Mem.nextblock m' = Mem.nextblock m.
  Proof.
    intros ce ty m loc ofs bf v m' Ha. inv Ha.
    - match goal with Hs : Mem.storev _ _ _ _ = Some _ |- _ => unfold Mem.storev in Hs;
        exact (Mem.nextblock_store _ _ _ _ _ _ Hs) end.
    - match goal with Hs : Mem.storebytes _ _ _ _ = Some _ |- _ =>
        exact (Mem.nextblock_storebytes _ _ _ _ _ Hs) end.
    - match goal with Hb : store_bitfield _ _ _ _ _ _ _ _ _ _ |- _ => inv Hb end.
      match goal with Hs : Mem.storev _ _ _ _ = Some _ |- _ => unfold Mem.storev in Hs;
        exact (Mem.nextblock_store _ _ _ _ _ _ Hs) end.
  Qed.

  Lemma kcres_gstore : forall q fid f pcs,
      linkorder q lp -> (prog_defmap q) ! fid = Some (Gfun (Internal f)) ->
      gstore_only f = true -> ObjExtBodies.sym_pres lp bm bc oc0 SafeB fid ->
      kcres fid pcs kA.
  Proof.
    intros q fid f pcs LO Hdm Hchk Hsp b fd Hsy Hff m vargs t m' vres Hevf _ (Hf & Hnb & HL).
    assert (Hfp : Genv.find_funct_ptr ge b = Some fd)
      by (rewrite <- Genv.find_funct_find_funct_ptr; exact Hff).
    pose proof (Hsp b fd Hsy Hfp m vargs t m' vres Hevf Hf) as Hf'.
    split; [ split; [ exact Hf' | ] | intros bb oo _; exact I ].
    destruct (linkorder_resolves_funct lp _ _ _ LO Hdm) as (b' & Hs' & Hff').
    unfold ge, lp_ge in Hsy, Hff. rewrite Hsy in Hs'. injection Hs' as <-.
    rewrite Hff' in Hff. injection Hff as <-.
    unfold gstore_only in Hchk. apply andb_prop in Hchk as [Hv Hw].
    assert (Hvars : fn_vars f = nil) by (destruct (fn_vars f); [ reflexivity | discriminate Hv ]).
    inv Hevf.
    match goal with He : function_entry2 _ _ _ _ _ _ _ |- _ => inv He end.
    match goal with Ha : alloc_variables _ _ _ _ _ _ |- _ => rewrite Hvars in Ha; inv Ha end.
    match goal with Hfl : Mem.free_list _ _ = Some _ |- _ => rename Hfl into Hfree end.
    replace (blocks_of_env _ empty_env) with (@nil (block * Z * Z)) in Hfree by reflexivity.
    cbn [Mem.free_list] in Hfree. injection Hfree as <-.
    lazymatch goal with Hb : exec_stmt _ _ ?E ?LE ?M1 _ _ _ ?M2 _ |- _ =>
      refine (proj1 (sw_walk ge E
                  (fun mm => Ple nb0 (Mem.nextblock mm) /\
                     (forall b ofs b' o', Ple nb0 b ->
                        Mem.load Mint32 mm b ofs = Some (Vptr b' o') -> pc kW b'))
                  (fun _ => True) (fun _ => True)
                  (fun _ _ => true)
                  (fun l _ => match SaveFileBody.groot_l l with Some _ => true | None => false end)
                  (fun _ _ _ => false) (fun _ => true)
                  ltac:(intros; exact I)
                  _
                  ltac:(intros ? ? ? ? ? ? ? ? ? J1; discriminate J1)
                  ltac:(intros; exact I)
                  _ _ _ _ _ _ _ _ Hb eq_refl Hw I (conj Hnb HL)))
    end.
    - intros l0 r0 le0 m0 t0 le0' m0' out0 Hok _ Hx (Hn0 & HL0).
      destruct (SaveFileBody.groot_l l0) as [g|] eqn:Hg; [ | discriminate Hok ].
      inv Hx.
      match goal with Hl : eval_lvalue _ _ _ _ l0 ?loc _ _ |- _ =>
        pose proof (SaveFileBody.groot_l_blk _ _ _ _ _ _ _ _ Hg Hl) as Hgs end.
      match goal with Ha : assign_loc _ _ _ _ _ _ _ _ |- _ => rename Ha into Hal end.
      split; [ rewrite (assign_loc_nextblock _ _ _ _ _ _ _ _ Hal); exact Hn0 | ].
      intros b1 ofs1 b' o' Hb1 Hld.
      rewrite (MtxfBody.assign_loc_load_other _ _ _ _ _ _ _ _ _ _ _ Hal) in Hld.
      + exact (HL0 _ _ _ _ Hb1 Hld).
      + exact (kfresh_ne _ _ Hb1 (Hn_glob _ _ Hgs)).
  Qed.

  (* the SafeB globals of the walk *)
  Lemma cam_gs_safe : forall x b, mem_id x cam_gs = true ->
      Genv.find_symbol ge x = Some b -> SafeB b.
  Proof.
    intros x b Hx Hs. destruct HSafeB_syms as (_ & _ & Hc). apply (Hc x b); [ | exact Hs ].
    unfold cam_gs, camera_safe_syms, mem_id in Hx. cbn [existsb] in Hx.
    repeat (apply orb_true_iff in Hx as [E | Hx];
            [ apply Pos.eqb_eq in E; subst x; vm_compute; reflexivity | ]).
    discriminate Hx.
  Qed.

  Hypothesis Hsq : sqrtf_spec.

  Lemma dm_ps : (prog_defmap audio_external.prog) ! camera._play_sound
                = Some (Gfun (Internal audio_external.f_play_sound)).
  Proof. vm_compute. reflexivity. Qed.
  Lemma gso_ps : gstore_only audio_external.f_play_sound = true.
  Proof. vm_compute. reflexivity. Qed.

  Lemma cam_init_ok : kct_ok cam_init.
  Proof.
    apply ct_cons; [ exact (kcres_sqrtf Hsq) | ].
    apply ct_cons; [ | exact ct_nil ].
    exact (kcres_gstore _ _ _ _ (linked12_LO_audio_external lp H12) dm_ps gso_ps
             (AudioBodies.sp_play_sound lp H12 bm bc oc0 SafeB HSafeB_syms Hspawn)).
  Qed.

  Lemma kchain_sound : forall dmc dmm dms,
      (forall tu fid f pcs rc, (kdm dmc dmm dms tu) ! fid = Some (Gfun (Internal f)) ->
         kcsp pcs rc (Internal f) -> kcres fid pcs rc) ->
      forall todo done,
      kct_ok done -> kchain dmc dmm dms cam_gs done todo = true ->
      kct_ok (kchain_tab done todo).
  Proof.
    intros dmc dmm dms Hdm_.
    induction todo as [| [[[fid tu] pcs] rc] rest IH]; intros done Hd Hc; [ exact Hd | ].
    cbn [kchain] in Hc. apply andb_prop in Hc as [H1 H2].
    cbn [kchain_tab]. apply IH; [ | exact H2 ].
    apply ct_cons; [ | exact Hd ]. cbn [fst snd].
    destruct ((kdm dmc dmm dms tu) ! fid) as [[[f|]|]|] eqn:Edm; try discriminate H1.
    exact (Hdm_ _ _ _ _ _ Edm (kbody_csp _ _ _ _ _ _ _ cam_gs_safe H1 Hd it_nil)).
  Qed.

  Definition cam_tab : kctab := kchain_tab cam_init cam_chain.

  (* NON-VACUITY + the walk: every one of the 60 real bodies passes *)
  Lemma cam_chain_ok :
    kchain (prog_defmap camera.prog) (prog_defmap math_util.prog)
      (prog_defmap surface_collision.prog) cam_gs cam_init cam_chain = true.
  Proof. vm_compute. reflexivity. Qed.

  Lemma cam_tab_ok : kct_ok cam_tab.
  Proof.
    refine (kchain_sound _ _ _ _ cam_chain cam_init cam_init_ok cam_chain_ok).
    intros tu fid f pcs rc Edm Hs. destruct tu; cbn [kdm] in Edm.
    - exact (kcres_of _ _ _ _ _ (linked12_LO_camera lp H12) Edm Hs).
    - exact (kcres_of _ _ _ _ _ (linked12_LO_math lp H12) Edm Hs).
    - exact (kcres_of _ _ _ _ _ (linked12_LO_surf lp H12) Edm Hs).
  Qed.

  (* ---- the indirect call ---- *)
  Definition cam_it : kitab := [(trans_ty, ([kS; kW; kW], kA))].

  Definition sig_is (o : option (list kcls * kcls)) : bool :=
    match o with Some ([kS; kW; kW], kA) => true | _ => false end.

  Lemma sig_is_eq : forall o, sig_is o = true -> o = Some ([kS; kW; kW], kA).
  Proof.
    intros o H. destruct o as [[l r]|]; [ | discriminate H ].
    destruct l as [| c1 l]; [ discriminate H | ]. destruct c1; try discriminate H.
    destruct l as [| c2 l]; [ discriminate H | ]. destruct c2; try discriminate H.
    destruct l as [| c3 l]; [ discriminate H | ]. destruct c3; try discriminate H.
    destruct l; [ | discriminate H ]. destruct r; try discriminate H. reflexivity.
  Qed.

  Lemma trans_in_tab : forallb (fun id => sig_is (kct_find id cam_tab)) trans_ids = true.
  Proof. vm_compute. reflexivity. Qed.

  Lemma cam_it_ok : kit_ok cam_it.
  Proof.
    intros ty pcs rc Hf vf fd Hff Hty.
    unfold kit_find, cam_it in Hf. cbn [find fst] in Hf.
    destruct (type_eq trans_ty ty) as [<- | N]; cbn in Hf; [ | discriminate Hf ].
    injection Hf as <- <-.
    destruct (Genv.find_funct_inv _ _ Hff) as (b & ->).
    rewrite Genv.find_funct_find_funct_ptr in Hff.
    destruct (trans_fd_ids lp H12 b fd Hff Hty) as (id & Hid & Hdm).
    destruct (proj1 (Genv.find_def_symbol _ _ _) Hdm) as (b' & Hs' & Hd').
    pose proof (proj1 (forallb_forall _ _) trans_in_tab id (MtxfBody.mem_id_In _ _ Hid)) as Hsig.
    apply sig_is_eq in Hsig.
    refine (cam_tab_ok id _ _ Hsig b' fd Hs' _).
    rewrite Genv.find_funct_find_funct_ptr. apply Genv.find_funct_ptr_iff. exact Hd'.
  Qed.

  (* ---- set_camera_mode(c, mode, frames) ---- *)
  (* stated in kchk_tc form so the kernel never has to unfold kchk (a
     conversion it otherwise tries by evaluation: hours) *)
  Definition tc_scm : ident -> kcls :=
    ktc_of cam_gs cam_tab cam_it [kS; kA; kA] camera.f_set_camera_mode.
  Lemma chk_scm :
    kchk_tc cam_gs tc_scm cam_tab cam_it [kS; kA; kA] kA camera.f_set_camera_mode = true.
  Proof. vm_compute. reflexivity. Qed.

  Lemma csp_scm : kcsp [kS; kA; kA] kA (Internal camera.f_set_camera_mode).
  Proof.
    exact (kbody_csp cam_gs tc_scm cam_tab cam_it [kS; kA; kA] kA camera.f_set_camera_mode
             cam_gs_safe chk_scm cam_tab_ok cam_it_ok).
  Qed.
End KB.

(* ---------------------------------------------------------------------- *)
(* 7. The capstone-facing residual.                                         *)
(* ---------------------------------------------------------------------- *)

Lemma wgate_scm_elim : forall bm SafeB vargs,
  wgate bm SafeB T_scm vargs -> osafe bm SafeB 0 (nth 0 vargs Vundef).
Proof.
  intros bm SafeB vargs H. unfold wgate in H.
  destruct (type_eq T_scm T_ffc) as [E | _];
    [ exfalso; assert (B0 : proj_sumbool (type_eq T_scm T_ffc) = false) by (vm_compute; reflexivity);
      rewrite E in B0; destruct (type_eq T_ffc T_ffc) as [Ee | N]; [ discriminate B0 | exact (N eq_refl) ] | ].
  destruct (type_eq T_scm T_f32w) as [E | _];
    [ exfalso; assert (B0 : proj_sumbool (type_eq T_scm T_f32w) = false) by (vm_compute; reflexivity);
      rewrite E in B0; destruct (type_eq T_f32w T_f32w) as [Ee | N]; [ discriminate B0 | exact (N eq_refl) ] | ].
  destruct (type_eq T_scm T_v3fcopy) as [E | _];
    [ exfalso; assert (B0 : proj_sumbool (type_eq T_scm T_v3fcopy) = false) by (vm_compute; reflexivity);
      rewrite E in B0; destruct (type_eq T_v3fcopy T_v3fcopy) as [Ee | N]; [ discriminate B0 | exact (N eq_refl) ] | ].
  destruct (type_eq T_scm T_v3fset) as [E | _];
    [ exfalso; assert (B0 : proj_sumbool (type_eq T_scm T_v3fset) = false) by (vm_compute; reflexivity);
      rewrite E in B0; destruct (type_eq T_v3fset T_v3fset) as [Ee | N]; [ discriminate B0 | exact (N eq_refl) ] | ].
  destruct (type_eq T_scm T_v3scopy) as [E | _];
    [ exfalso; assert (B0 : proj_sumbool (type_eq T_scm T_v3scopy) = false) by (vm_compute; reflexivity);
      rewrite E in B0; destruct (type_eq T_v3scopy T_v3scopy) as [Ee | N]; [ discriminate B0 | exact (N eq_refl) ] | ].
  destruct (type_eq T_scm T_vfc) as [E | _];
    [ exfalso; assert (B0 : proj_sumbool (type_eq T_scm T_vfc) = false) by (vm_compute; reflexivity);
      rewrite E in B0; destruct (type_eq T_vfc T_vfc) as [Ee | N]; [ discriminate B0 | exact (N eq_refl) ] | ].
  destruct (type_eq T_scm T_scm) as [_ | N]; [ exact H | exact (False_ind _ (N eq_refl)) ].
Qed.

(* THE ROW, PROVED.  The Camera* argument is a SafeB block (osafe at size 0:
   no window of Mario's block is 0-store-safe); mode and frames are any. *)
Lemma Hscm_body_proved :
  forall lp, linked12 lp ->
  forall bm bc oc0 SafeB,
    SafeB_syms_ok lp SafeB ->
    (exists init, spawn_ok lp init bm bc oc0) ->
    sqrtf_spec ->
    RestSurface.body_pres_w lp (MWF_real lp bm bc oc0 SafeB) bm SafeB camera.f_set_camera_mode.
Proof.
  intros lp H12 bm bc oc0 SafeB HSafeB_syms Hspawn Hsq m vargs t m' vres Hgate Hevf HM Hv Hsat.
  rewrite camera_scm_type in Hgate.
  pose proof (wgate_scm_elim _ _ _ Hgate) as Hc.
  set (nb0 := Mem.nextblock m).
  assert (Hn_safe : forall b, SafeB b -> Plt b nb0)
    by (intros b Hs; exact (mwf_real_safe_valid lp bm bc oc0 SafeB m HM b Hs)).
  assert (Hn_glob : forall gid bg, Genv.find_symbol (lp_ge lp) gid = Some bg -> Plt bg nb0)
    by (intros gid bg Hg;
        exact (glob_valid_of_nextbound lp m (mwf_real_nextbound lp bm bc oc0 SafeB m HM) gid bg Hg)).
  assert (Hva : Forall2 (kvok SafeB (GBk lp) nb0) [kS; kA; kA] vargs).
  { inv Hevf.
    match goal with He : function_entry2 _ _ _ _ _ _ _ |- _ => inv He end.
    match goal with Hb : bind_parameter_temps _ _ _ = Some _ |- _ => revert Hb end.
    cbn [fn_params camera.f_set_camera_mode bind_parameter_temps].
    destruct vargs as [| v0 [| v1 [| v2 [| v3 vr]]]]; cbn; intros Hb; try discriminate Hb.
    cbn in Hc.
    repeat apply Forall2_cons; try apply Forall2_nil; intros b o E; cbn [kpc];
      [ | exact I | exact I ].
    destruct (Hc b o E) as [(_ & Hw) | Hs]; [ | exact Hs ].
    unfold store_window_ok in Hw. cbn in Hw. discriminate Hw. }
  destruct (csp_scm lp H12 bm bc oc0 SafeB HSafeB_syms Hspawn nb0 Hv Hn_safe Hn_glob Hsq
              m vargs t m' vres Hevf Hva
              (conj (conj Hv (conj Hsat HM)) (conj (Ple_refl _)
                 (fun b ofs b' o' Hb Hld => False_ind _
                    (Plt_strict _ (Plt_Ple_trans _ _ _ (PrintBodies.load_valid _ _ _ _ _ Hld) Hb))))))
    as (((Hv' & Hs' & HM') & _) & _).
  exact (conj Hv' (conj Hs' HM')).
Qed.
