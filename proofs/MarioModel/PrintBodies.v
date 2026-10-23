(* ====================================================================== *)
(* print_text_fmt_int, PROVED FROM ITS REAL BODY (SPINE: the print link,  *)
(* 2026-10-23).                                                           *)
(*                                                                        *)
(* game/print.c is linked (the 42nd TU, LinkedTwelve.tu_rest), so mario.c's *)
(* debug_print_speed_action_normal calls the real print_text_fmt_int, and  *)
(* its whole call tree has real bodies:                                    *)
(*   print.c  : print_text_fmt_int, parse_width_field, format_integer,     *)
(*              int_pow;                                                   *)
(*   memory.c : mem_pool_alloc (the label comes from gEffectsMemoryPool).  *)
(*                                                                        *)
(* THE CLAIM: with x, y, n not pointers (the call-site gate CensusV2.T_ptfi, *)
(* discharged at mario.c's three call sites by CensusV2.wargs_chk), the    *)
(* call keeps the carried run facts (valid bm, action_sat, MWF_real).      *)
(*                                                                        *)
(* FOUND FALSE (the rows this replaces): the old engine rows               *)
(* Hext_action_ptfi / Hmwf_ext_ptfi claimed this for EVERY argument and    *)
(* every pool.  Against the real body that is false: label->x = x stores   *)
(* the argument into the pool label, so x = a pointer to a non-SafeB block *)
(* (Mario's own) breaks MWF's load closure R7; and with the pool globals   *)
(* outside SafeB nothing keeps the free-list chase off Mario's block (the  *)
(* stores label->x / label->buffer[i] could then land on the action cell). *)
(* RESTATED: the gated residual (x, y, n not pointers) with the print      *)
(* globals SafeB symbols (CensusV2.print_safe_syms, the spawn_safe_syms    *)
(* precedent: every store of the tree goes THROUGH a pointer read out of   *)
(* them, so a stored_globals-style frame cannot cover it).                 *)
(*                                                                        *)
(* THE WALK: a class walker over four value classes                        *)
(*   cN  never a pointer;                                                  *)
(*   cS  SafeB-if-pointer (SpawnBodies.safev);                             *)
(*   cL  a pointer into a block allocated since the outer call's entry     *)
(*       (Ple nb0 b: the stack locals &srcIndex / &width / &zeroPad / &len  *)
(*       and parse_width_field's digits[]);                                *)
(*   cA  anything (the format string `str`, only ever read bytewise).      *)
(* Every store lands in a SafeB block (mwf_real_chase_ptr) or in a fresh   *)
(* stack block (mwf_real_local_store) with a cS value; the carried         *)
(* invariant adds "a pointer read out of a fresh block is SafeB".          *)
(* ====================================================================== *)

From Coq Require Import ZArith List Lia Bool String.
From compcert Require Import Coqlib Maps AST Integers Values Events Memory
  Globalenvs Ctypes Cop Clightdefs Clight ClightBigstep Linking.
From SM64.Generated Require mario memory print.
From SM64.Proofs Require Import SymbolicLinking ActionValueFrame Taint
  RealFrameLinked AGates CensusV2 RestSurface MWFReal SpawnInit MathGeomBodies
  MathGeomGated OutParamSurface MathBodies LinkedTwelve LocalVarsSurface
  SurfaceBodies SpawnBodies.
From SM64.Proofs Require MtxfBody ActWriterSurface RetSurface SaveDoSaveBody
  ObjHelpersBodies.

Import ListNotations.
Local Open Scope Z_scope.

(* ---------------------------------------------------------------------- *)
(* 1. Classes.                                                             *)
(* ---------------------------------------------------------------------- *)

Inductive cls : Type := cN | cS | cL | cA.

Definition cle (c d : cls) : bool :=
  match c, d with
  | cN, _ => true
  | _, cA => true
  | cS, cS => true
  | cL, cL => true
  | _, _ => false
  end.

Definition cjoin (c d : cls) : cls :=
  match c, d with
  | cN, _ => d
  | _, cN => c
  | cS, cS => cS
  | cL, cL => cL
  | _, _ => cA
  end.

Definition pc (SafeB : block -> Prop) (nb0 : block) (c : cls) (b : block) : Prop :=
  match c with
  | cN => False
  | cS => SafeB b
  | cL => Ple nb0 b
  | cA => True
  end.

Definition vok (SafeB : block -> Prop) (nb0 : block) (c : cls) (v : val) : Prop :=
  forall b o, v = Vptr b o -> pc SafeB nb0 c b.

Lemma cle_pc : forall SafeB nb0 c d b, cle c d = true ->
    pc SafeB nb0 c b -> pc SafeB nb0 d b.
Proof. intros SafeB nb0 c d b H. destruct c, d; cbn in *; try discriminate H; tauto. Qed.

Lemma cle_vok : forall SafeB nb0 c d v, cle c d = true ->
    vok SafeB nb0 c v -> vok SafeB nb0 d v.
Proof. intros SafeB nb0 c d v H Hv b o E. exact (cle_pc _ _ _ _ _ H (Hv b o E)). Qed.

Lemma cjoin_l : forall SafeB nb0 c d b, pc SafeB nb0 c b -> pc SafeB nb0 (cjoin c d) b.
Proof. intros SafeB nb0 c d b H. destruct c, d; cbn in *; tauto. Qed.

Lemma cjoin_r : forall SafeB nb0 c d b, pc SafeB nb0 d b -> pc SafeB nb0 (cjoin c d) b.
Proof. intros SafeB nb0 c d b H. destruct c, d; cbn in *; tauto. Qed.

Lemma load_valid : forall ch m b ofs v, Mem.load ch m b ofs = Some v -> Mem.valid_block m b.
Proof.
  intros ch m b ofs v H.
  exact (Mem.valid_access_valid_block _ _ _ _
           (Mem.valid_access_implies _ _ _ _ _ _ (Mem.load_valid_access _ _ _ _ _ H) (perm_any_N _))).
Qed.

Lemma vok_undef : forall SafeB nb0 c, vok SafeB nb0 c Vundef.
Proof. intros SafeB nb0 c b o E. discriminate E. Qed.

(* ---------------------------------------------------------------------- *)
(* 2. The expression classifier and its soundness.                         *)
(*    lv: the function's locals (fresh blocks); gs: SafeB global symbols;  *)
(*    tc: the temps' classes.                                              *)
(* ---------------------------------------------------------------------- *)

Definition lvar (lv gs : list ident) (x : ident) : cls :=
  if mem_id x lv then cL else if mem_id x gs then cS else cA.

(* the class of a value read at a block of class bc *)
Definition rv (ty : type) (bc : cls) : cls :=
  match access_mode ty with
  | By_value Mint32 => match bc with cA => cA | _ => cS end
  | By_value Many32 | By_value Many64 => cA
  | By_value _ => cN
  | By_reference | By_copy => bc
  | By_nothing => cN
  end.

Definition binop_cls (op : binary_operation) (c1 c2 : cls) : cls :=
  match op with
  | Oadd => cjoin c1 c2
  | Osub => c1
  | Omul | Odiv | Omod => cN
  | _ => if RetSurface.vint_binop op then cN else cA
  end.

Section CX.
  Variables lv gs : list ident.
  Variable tc : ident -> cls.

  Fixpoint cx (a : expr) : cls :=
    match a with
    | Econst_int _ _ | Econst_float _ _ | Econst_single _ _ | Econst_long _ _ => cN
    | Esizeof _ _ | Ealignof _ _ => cN
    | Etempvar t _ => tc t
    | Eunop _ _ _ => cN
    | Ecast a1 _ => cx a1
    | Ebinop op a1 a2 _ => binop_cls op (cx a1) (cx a2)
    | Evar x ty => rv ty (lvar lv gs x)
    | Ederef a1 ty => rv ty (cx a1)
    | Efield a1 _ ty => rv ty (cx a1)
    | Eaddrof a1 _ =>
        match a1 with
        | Evar x _ => lvar lv gs x
        | Ederef a2 _ | Efield a2 _ _ => cx a2
        | _ => cA
        end
    end.

  (* the class of an lvalue's block *)
  Definition clv (a : expr) : cls :=
    match a with
    | Evar x _ => lvar lv gs x
    | Ederef a1 _ | Efield a1 _ _ => cx a1
    | _ => cA
    end.
End CX.

Section CXS.
  Variable ge : genv.
  Variable e : env.
  Variable le : temp_env.
  Variable m : mem.
  Variable SafeB : block -> Prop.
  Variable nb0 : block.
  Variables lv gs : list ident.
  Variable tc : ident -> cls.

  Hypothesis Hle : forall t v, le ! t = Some v -> vok SafeB nb0 (tc t) v.
  Hypothesis He : forall x b ty, e ! x = Some (b, ty) -> mem_id x lv = true /\ Ple nb0 b.
  Hypothesis He2 : forall x, mem_id x lv = true -> e ! x <> None.
  Hypothesis Hgs : forall x b, mem_id x gs = true -> Genv.find_symbol ge x = Some b -> SafeB b.
  Hypothesis R7 : forall b ofs b' o', SafeB b ->
      Mem.loadv Mint32 m (Vptr b ofs) = Some (Vptr b' o') -> SafeB b'.
  Hypothesis RL : forall b ofs b' o', Ple nb0 b ->
      Mem.load Mint32 m b ofs = Some (Vptr b' o') -> SafeB b'.

  Lemma deref_cls : forall ty loc ofs bf v c,
      deref_loc ty m loc ofs bf v -> pc SafeB nb0 c loc -> vok SafeB nb0 (rv ty c) v.
  Proof.
    intros ty loc ofs bf v c Hd Hc b o Ev. subst v.
    inv Hd.
    - match goal with Ha : access_mode _ = By_value ?ch, Hl : Mem.loadv ?ch _ _ = Some _ |- _ =>
        pose proof Hl as Hl'; cbn in Hl';
        destruct (load_vptr_chunk _ _ _ _ _ _ Hl') as [E | [E | E]]; subst ch;
        unfold rv; rewrite Ha end.
      + destruct c; cbn in Hc |- *.
        * contradiction Hc.
        * eapply R7; eassumption.
        * eapply RL; eassumption.
        * exact I.
      + exact I.
      + exact I.
    - match goal with Ha : access_mode _ = By_reference |- _ => unfold rv; rewrite Ha; exact Hc end.
    - match goal with Ha : access_mode _ = By_copy |- _ => unfold rv; rewrite Ha; exact Hc end.
    - match goal with Hl : load_bitfield _ _ _ _ _ _ _ _ |- _ => inv Hl end.
  Qed.

  Lemma cx_sound_mut :
    (forall a v, eval_expr ge e le m a v -> vok SafeB nb0 (cx lv gs tc a) v) /\
    (forall a b o bf, eval_lvalue ge e le m a b o bf -> pc SafeB nb0 (clv lv gs tc a) b).
  Proof.
    apply (eval_expr_lvalue_ind ge e le m
             (fun a v => vok SafeB nb0 (cx lv gs tc a) v)
             (fun a b o bf => pc SafeB nb0 (clv lv gs tc a) b));
      intros; cbv beta in *.
    - intros bb oo E; discriminate E.
    - intros bb oo E; discriminate E.
    - intros bb oo E; discriminate E.
    - intros bb oo E; discriminate E.
    - cbn [cx]. eapply Hle; eassumption.
    - (* Eaddrof *)
      intros bb oo E. injection E as <- <-.
      destruct a; cbn [clv] in *; cbn [cx]; first [ exact I | assumption ].
    - (* Eunop *)
      intros bb oo E. subst. exfalso.
      eapply ActWriterSurface.sem_unop_nonptr; [ eassumption | reflexivity ].
    - (* Ebinop *)
      intros bb oo E. subst. cbn [cx].
      match goal with
      | Hs : sem_binary_operation _ ?op ?v1 _ ?v2 _ _ = Some _,
        IH1 : vok _ _ _ ?v1, IH2 : vok _ _ _ ?v2 |- _ =>
        pose proof Hs as Hs0;
        destruct op; cbn [binop_cls]; cbn [sem_binary_operation] in Hs;
        [ destruct (SaveDoSaveBody.sem_add_vptr_src _ _ _ _ _ _ _ _ Hs) as [(o1 & E1) | (o2 & E2)];
          [ exact (cjoin_l _ _ _ _ _ (IH1 _ _ E1)) | exact (cjoin_r _ _ _ _ _ (IH2 _ _ E2)) ]
        | destruct (SaveDoSaveBody.sem_sub_vptr_src _ _ _ _ _ _ _ _ Hs) as (o1 & E1);
          exact (IH1 _ _ E1)
        | exact (False_ind _ (ActWriterSurface.sem_mul_nonptr _ _ _ _ _ _ Hs _ _ eq_refl))
        | exact (False_ind _ (ActWriterSurface.sem_div_nonptr _ _ _ _ _ _ Hs _ _ eq_refl))
        | exact (False_ind _ (ActWriterSurface.sem_mod_nonptr _ _ _ _ _ _ Hs _ _ eq_refl))
        | (exfalso; refine (vint_binop_sound _ _ _ _ _ _ _ _ _ Hs0 _ _ eq_refl); reflexivity) .. ]
      end.
    - (* Ecast *)
      intros bb oo E. subst. cbn [cx].
      match goal with Hc : sem_cast ?v1 _ _ _ = Some _, IH : vok _ _ _ ?v1 |- _ =>
        exact (IH _ _ (sem_cast_vptr_inv _ _ _ _ _ _ Hc)) end.
    - intros bb oo E. unfold Vptrofs in E. destruct Archi.ptr64; discriminate E.
    - intros bb oo E. unfold Vptrofs in E. destruct Archi.ptr64; discriminate E.
    - (* Elvalue *)
      destruct a;
        try (match goal with Hl : eval_lvalue _ _ _ _ _ _ _ _ |- _ => inv Hl end; fail);
        cbn [cx clv typeof] in *; eapply deref_cls; eassumption.
    - (* Evar local *)
      cbn [clv]. unfold lvar. destruct (He _ _ _ H) as (-> & Hb). exact Hb.
    - (* Evar global *)
      cbn [clv]. unfold lvar.
      destruct (mem_id id lv) eqn:El; [ exact (False_ind _ (He2 _ El H)) | ].
      destruct (mem_id id gs) eqn:Eg; [ exact (Hgs _ _ Eg H0) | exact I ].
    - cbn [clv]. match goal with IH : vok _ _ _ (Vptr ?l _) |- _ => exact (IH _ _ eq_refl) end.
    - cbn [clv]. match goal with IH : vok _ _ _ (Vptr ?l _) |- _ => exact (IH _ _ eq_refl) end.
    - cbn [clv]. match goal with IH : vok _ _ _ (Vptr ?l _) |- _ => exact (IH _ _ eq_refl) end.
  Qed.

  Lemma cx_sound : forall a v, eval_expr ge e le m a v -> vok SafeB nb0 (cx lv gs tc a) v.
  Proof. exact (proj1 cx_sound_mut). Qed.

  Lemma clv_sound : forall a b o bf, eval_lvalue ge e le m a b o bf ->
      pc SafeB nb0 (clv lv gs tc a) b.
  Proof. exact (proj2 cx_sound_mut). Qed.

  Fixpoint args_ok (al : list expr) (pcs : list cls) : bool :=
    match al, pcs with
    | nil, nil => true
    | a :: al', c :: pcs' => cle (cx lv gs tc a) c && args_ok al' pcs'
    | _, _ => false
    end.

  Lemma args_sound : forall al tyl vl, eval_exprlist ge e le m al tyl vl ->
      forall pcs, args_ok al pcs = true -> Forall2 (vok SafeB nb0) pcs vl.
  Proof.
    intros al tyl vl Hel. induction Hel; intros pcs Hok;
      destruct pcs as [| c pcs]; cbn [args_ok] in Hok; try discriminate Hok; [ constructor | ].
    apply andb_prop in Hok as [H1 H2].
    constructor; [ | exact (IHHel _ H2) ].
    intros bb oo E. subst.
    match goal with Hc : sem_cast ?v1 _ _ _ = Some (Vptr bb oo),
                    Hx : eval_expr _ _ _ _ ?a ?v1 |- _ =>
      exact (cle_pc _ _ _ _ _ H1 (cx_sound _ _ Hx _ _ (sem_cast_vptr_inv _ _ _ _ _ _ Hc))) end.
  Qed.
End CXS.

(* ---------------------------------------------------------------------- *)
(* 3. The per-function recognizer.                                          *)
(* ---------------------------------------------------------------------- *)

(* a class table: the listed temps, the rest at the default *)
Definition tcl (l : list (ident * cls)) (dflt : cls) (t : ident) : cls :=
  match find (fun p => Pos.eqb (fst p) t) l with
  | Some (_, c) => c
  | None => dflt
  end.

(* a callee table: (callee, (param classes, return class)) *)
Definition ctab := list (ident * (list cls * cls)).

Definition ct_find (fid : ident) (ct : ctab) : option (list cls * cls) :=
  match find (fun p => Pos.eqb (fst p) fid) ct with
  | Some (_, s) => Some s
  | None => None
  end.

Definition blk_ok (c : cls) : bool :=
  match c with cS | cL => true | _ => false end.

Definition p_set (lv gs : list ident) (tc : ident -> cls) (id : ident) (a : expr) : bool :=
  cle (cx lv gs tc a) (tc id).
Definition p_store (lv gs : list ident) (tc : ident -> cls) (l r : expr) : bool :=
  MtxfBody.is_byval (typeof l) && blk_ok (clv lv gs tc l) && cle (cx lv gs tc r) cS.
Definition p_ret (lv gs : list ident) (tc : ident -> cls) (rc : cls) (a : expr) : bool :=
  cle (cx lv gs tc a) rc.
Definition p_call (lv gs : list ident) (tc : ident -> cls) (ct : ctab)
    (optid : option ident) (a : expr) (al : list expr) : bool :=
  match a with
  | Evar fid (Tfunction _ _ _) =>
      negb (mem_id fid lv) &&
      match ct_find fid ct with
      | Some (pcs, rc) =>
          args_ok lv gs tc al pcs &&
          match optid with None => true | Some id => cle rc (tc id) end
      | None => false
      end
  | _ => false
  end.

Definition pchk (gs : list ident) (tc : ident -> cls) (ct : ctab) (rc : cls)
    (f : Clight.function) : bool :=
  let lv := map fst (fn_vars f) in
  sw_chk (p_set lv gs tc) (p_store lv gs tc) (p_call lv gs tc ct) (p_ret lv gs tc rc)
    (fn_body f).

(* the parameters' classes cover the argument classes *)
Fixpoint par_ok (tc : ident -> cls) (ids : list ident) (pcs : list cls) : bool :=
  match ids, pcs with
  | x :: ids', c :: pcs' => cle c (tc x) && par_ok tc ids' pcs'
  | _, _ => true
  end.

Lemma par_ok_nth : forall tc ids pcs i x c,
    par_ok tc ids pcs = true -> nth_error ids i = Some x -> nth_error pcs i = Some c ->
    cle c (tc x) = true.
Proof.
  intros tc ids. induction ids as [| y ids IH]; intros pcs i x c H Hx Hc;
    [ destruct i; discriminate Hx | ].
  destruct pcs as [| c' pcs]; [ destruct i; discriminate Hc | ].
  cbn [par_ok] in H. apply andb_prop in H as [H1 H2].
  destruct i as [| i]; cbn in Hx, Hc.
  - injection Hx as <-. injection Hc as <-. exact H1.
  - exact (IH _ _ _ _ H2 Hx Hc).
Qed.

Lemma forall2_nth : forall {A B} (P : A -> B -> Prop) l1 l2 i a b,
    Forall2 P l1 l2 -> nth_error l1 i = Some a -> nth_error l2 i = Some b -> P a b.
Proof.
  intros A B P l1 l2 i a b H. revert i.
  induction H as [| x y l1 l2 Hxy Hl IH]; intros i H1 H2; [ destruct i; discriminate H1 | ].
  destruct i as [| i]; cbn in H1, H2.
  - injection H1 as <-. injection H2 as <-. exact Hxy.
  - exact (IH _ H1 H2).
Qed.

Lemma forall2_nth_l : forall {A B} (P : A -> B -> Prop) l1 l2 i b,
    Forall2 P l1 l2 -> nth_error l2 i = Some b -> exists a, nth_error l1 i = Some a.
Proof.
  intros A B P l1 l2 i b H. revert i.
  induction H as [| x y l1 l2 Hxy Hl IH]; intros i H2; [ destruct i; discriminate H2 | ].
  destruct i as [| i]; cbn in H2 |- *; [ eauto | exact (IH _ H2) ].
Qed.

(* ---------------------------------------------------------------------- *)
(* 4. The walk, at the concrete MWF_real.                                   *)
(* ---------------------------------------------------------------------- *)

Section PB.
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

  Lemma pb_not_bm : forall b, SafeB b -> b <> bm.
  Proof. destruct Hspawn as (init & Hs). exact (safeb_not_bm lp init bm bc oc0 SafeB Hs HSafeB_syms). Qed.
  Lemma pb_Hbc_bm : bc <> bm.
  Proof. destruct Hspawn as (init & Hs). exact (spawn_Hbc_bm lp init bm bc oc0 Hs). Qed.

  Lemma fresh_ne : forall b b', Ple nb0 b -> Plt b' nb0 -> b <> b'.
  Proof. intros b b' H1 H2 E. subst. exact (Plt_strict _ (Plt_Ple_trans _ _ _ H2 H1)). Qed.

  (* the carried invariant *)
  Definition PInv (m : mem) : Prop :=
    OF m /\ Ple nb0 (Mem.nextblock m) /\
    (forall b ofs b' o', Ple nb0 b -> Mem.load Mint32 m b ofs = Some (Vptr b' o') -> SafeB b').

  Lemma pinv_store_safe : forall ch m b z v m', SafeB b -> safev SafeB v ->
      Mem.store ch m b z v = Some m' -> PInv m -> PInv m'.
  Proof.
    intros ch m b z v m' Hs Hv Hst (Hf & Hnb & HL).
    split; [ | split ].
    - exact (sb_safe_store lp bm bc oc0 SafeB HSafeB_syms Hspawn b ch z v m m' Hs Hv Hst Hf).
    - rewrite (Mem.nextblock_store _ _ _ _ _ _ Hst). exact Hnb.
    - intros b1 ofs b' o' Hb1 Hld.
      rewrite (Mem.load_store_other _ _ _ _ _ _ Hst) in Hld.
      + exact (HL _ _ _ _ Hb1 Hld).
      + left. exact (fresh_ne _ _ Hb1 (Hn_safe _ Hs)).
  Qed.

  Lemma pinv_store_local : forall ch m b z v m', Ple nb0 b -> safev SafeB v ->
      Mem.store ch m b z v = Some m' -> PInv m -> PInv m'.
  Proof.
    intros ch m b z v m' Hb Hv Hst ((Hvb & Hsat & HM) & Hnb & HL).
    split; [ split; [ eauto using Mem.store_valid_block_1 | split ] | split ].
    - eapply action_sat_unchanged_on with (m := m); [ | exact Hvb | exact Hsat ].
      eapply Mem.store_unchanged_on; [ exact Hst | ].
      intros i _ [Hb' _]. exact (fresh_ne _ _ Hb Hn_bm Hb').
    - destruct Hspawn as (init & Hsp).
      destruct (spawn_Hbc_sym lp init bm bc oc0 Hsp) as (gid & Hsy).
      eapply mwf_real_local_store; [ exact pb_Hbc_bm | exact HM | | | | | exact Hst ].
      + exact (fresh_ne _ _ Hb Hn_bm).
      + exact (fresh_ne _ _ Hb (Hn_glob _ _ Hsy)).
      + intros Hs. exact (fresh_ne _ _ Hb (Hn_safe _ Hs) eq_refl).
      + intros gid' bg Hg. exact (fresh_ne _ _ Hb (Hn_glob _ _ Hg)).
    - rewrite (Mem.nextblock_store _ _ _ _ _ _ Hst). exact Hnb.
    - intros b1 ofs b' o' Hb1 Hld.
      destruct (Mem.load_pointer_store _ _ _ _ _ _ _ _ _ _ _ Hst Hld)
        as [(Ev & _ & _ & _) | Hdis].
      + exact (Hv _ _ Ev).
      + rewrite (Mem.load_store_other _ _ _ _ _ _ Hst _ _ _ Hdis) in Hld.
        exact (HL _ _ _ _ Hb1 Hld).
  Qed.

  Lemma pinv_store : forall ch m b z v m' c, blk_ok c = true -> pc SafeB nb0 c b ->
      safev SafeB v -> Mem.store ch m b z v = Some m' -> PInv m -> PInv m'.
  Proof.
    intros ch m b z v m' c Hc Hp Hv Hst Hi.
    destruct c; cbn in Hc, Hp; try discriminate Hc.
    - exact (pinv_store_safe _ _ _ _ _ _ Hp Hv Hst Hi).
    - exact (pinv_store_local _ _ _ _ _ _ Hp Hv Hst Hi).
  Qed.

  (* entry: the frame's allocations *)
  Lemma av_pinv : forall e0 m vars e m1,
      alloc_variables ge e0 m vars e m1 ->
      (forall x b ty, e0 ! x = Some (b, ty) -> Ple nb0 b) ->
      Ple nb0 (Mem.nextblock m) ->
      (forall b ofs b' o', Ple nb0 b -> Mem.load Mint32 m b ofs = Some (Vptr b' o') -> SafeB b') ->
      Ple nb0 (Mem.nextblock m1) /\
      (forall b ofs b' o', Ple nb0 b -> Mem.load Mint32 m1 b ofs = Some (Vptr b' o') -> SafeB b') /\
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
        { destruct (Mem.valid_block_alloc_inv _ _ _ _ _ Hal _ (load_valid _ _ _ _ _ Hld)) as [E | Hv];
            [ congruence | exact Hv ]. }
        rewrite (Mem.load_alloc_unchanged _ _ _ _ _ Hal _ _ _ Hv) in Hld.
        exact (HL _ _ _ _ Hb Hld).
  Qed.

  (* exit: freeing the frame *)
  Lemma free_pinv : forall l m m',
      Mem.free_list m l = Some m' ->
      Ple nb0 (Mem.nextblock m) ->
      (forall b ofs b' o', Ple nb0 b -> Mem.load Mint32 m b ofs = Some (Vptr b' o') -> SafeB b') ->
      Ple nb0 (Mem.nextblock m') /\
      (forall b ofs b' o', Ple nb0 b -> Mem.load Mint32 m' b ofs = Some (Vptr b' o') -> SafeB b').
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
  Definition csp (pcs : list cls) (rc : cls) (fd : Clight.fundef) : Prop :=
    forall m vargs t m' vres,
      eval_funcall function_entry2 ge m fd vargs t m' vres ->
      Forall2 (vok SafeB nb0) pcs vargs -> PInv m -> PInv m' /\ vok SafeB nb0 rc vres.

  Definition cres (fid : ident) (pcs : list cls) (rc : cls) : Prop :=
    forall b fd, Genv.find_symbol ge fid = Some b ->
      Genv.find_funct ge (Vptr b Ptrofs.zero) = Some fd -> csp pcs rc fd.

  Definition ct_ok (ct : ctab) : Prop :=
    forall fid pcs rc, ct_find fid ct = Some (pcs, rc) -> cres fid pcs rc.

  Lemma cres_of : forall q fid f pcs rc,
      linkorder q lp -> (prog_defmap q) ! fid = Some (Gfun (Internal f)) ->
      csp pcs rc (Internal f) -> cres fid pcs rc.
  Proof.
    intros q fid f pcs rc LO Hdm Hs b fd Hsy Hff.
    destruct (linkorder_resolves_funct lp _ _ _ LO Hdm) as (b' & Hs' & Hff').
    unfold ge, lp_ge in Hsy, Hff. rewrite Hsy in Hs'. injection Hs' as <-.
    rewrite Hff' in Hff. injection Hff as <-. exact Hs.
  Qed.

  Definition TPc (tc : ident -> cls) (le : temp_env) : Prop :=
    forall t v, le ! t = Some v -> vok SafeB nb0 (tc t) v.

  (* the frame's env: its names are the locals, each a fresh block *)
  Definition EIL (lv : list ident) (e : env) : Prop :=
    (forall x b ty, e ! x = Some (b, ty) -> mem_id x lv = true /\ Ple nb0 b)
    /\ (forall x, mem_id x lv = true -> e ! x <> None).

  Section Fn.
    Variable lv gs : list ident.
    Variable tc : ident -> cls.
    Variable ct : ctab.
    Variable e : env.
    Hypothesis HEI : EIL lv e.
    Hypothesis Hgs : forall x b, mem_id x gs = true -> Genv.find_symbol ge x = Some b -> SafeB b.
    Hypothesis Hct : ct_ok ct.

    Lemma pb_R7 : forall m, PInv m -> forall b ofs b' o', SafeB b ->
        Mem.loadv Mint32 m (Vptr b ofs) = Some (Vptr b' o') -> SafeB b'.
    Proof.
      intros m ((_ & _ & HM) & _) b ofs b' o' Hs Hld.
      exact (mwf_real_chase_step lp bm bc oc0 SafeB m b ofs b' o' HM Hs Hld).
    Qed.

    Lemma pb_cx : forall le m a v, TPc tc le -> PInv m ->
        eval_expr ge e le m a v -> vok SafeB nb0 (cx lv gs tc a) v.
    Proof.
      intros le m a v HP Hi Hev.
      exact (cx_sound ge e le m SafeB nb0 lv gs tc HP (proj1 HEI) (proj2 HEI) Hgs
               (pb_R7 m Hi) (proj2 (proj2 Hi)) a v Hev).
    Qed.

    Lemma pb_clv : forall le m a b o bf, TPc tc le -> PInv m ->
        eval_lvalue ge e le m a b o bf -> pc SafeB nb0 (clv lv gs tc a) b.
    Proof.
      intros le m a b o bf HP Hi Hev.
      exact (clv_sound ge e le m SafeB nb0 lv gs tc HP (proj1 HEI) (proj2 HEI) Hgs
               (pb_R7 m Hi) (proj2 (proj2 Hi)) a b o bf Hev).
    Qed.

    Lemma pb_set : forall id a le m v,
        p_set lv gs tc id a = true -> TPc tc le -> PInv m ->
        eval_expr ge e le m a v -> TPc tc (PTree.set id v le).
    Proof.
      intros id a le m v Hok HP Hi Hev t v' Hg.
      destruct (peq t id) as [-> | Hne].
      - rewrite PTree.gss in Hg. injection Hg as <-.
        exact (cle_vok _ _ _ _ _ Hok (pb_cx _ _ _ _ HP Hi Hev)).
      - rewrite PTree.gso in Hg by exact Hne. exact (HP _ _ Hg).
    Qed.

    Lemma pb_store : forall l r le m t le' m' out,
        p_store lv gs tc l r = true -> TPc tc le ->
        exec_stmt function_entry2 ge e le m (Sassign l r) t le' m' out ->
        PInv m -> PInv m'.
    Proof.
      intros l r le m t le' m' out Hok HP Hx Hi.
      unfold p_store in Hok. apply andb_prop in Hok as [Hok Hr].
      apply andb_prop in Hok as [Hbv Hbk].
      inv Hx.
      lazymatch goal with Hlv : eval_lvalue _ _ _ _ _ ?loc _ _ |- _ =>
        pose proof (pb_clv _ _ _ _ _ _ HP Hi Hlv) as Hpc end.
      match goal with Hre : eval_expr _ _ _ _ r ?v2, Hc : sem_cast ?v2 _ _ _ = Some ?vv |- _ =>
        assert (Hsv : safev SafeB vv)
          by (intros bb oo Ev; subst vv;
              exact (cle_pc _ _ _ _ _ Hr (pb_cx _ _ _ _ HP Hi Hre _ _
                       (sem_cast_vptr_inv _ _ _ _ _ _ Hc)))) end.
      match goal with Ha : assign_loc _ _ _ _ _ _ _ _ |- _ => inv Ha end.
      - match goal with Hst : Mem.storev _ _ _ _ = Some _ |- _ =>
          unfold Mem.storev in Hst; exact (pinv_store _ _ _ _ _ _ _ Hbk Hpc Hsv Hst Hi) end.
      - unfold MtxfBody.is_byval in Hbv.
        match goal with Hc : access_mode _ = By_copy |- _ => rewrite Hc in Hbv; discriminate Hbv end.
      - match goal with Hb : store_bitfield _ _ _ _ _ _ _ _ _ _ |- _ => inv Hb end.
        match goal with Hst : Mem.storev _ _ _ _ = Some _ |- _ =>
          unfold Mem.storev in Hst;
          refine (pinv_store _ _ _ _ _ _ _ Hbk Hpc _ Hst Hi); intros bb oo E; discriminate E end.
    Qed.

    Lemma pb_ret : forall rc a le m v,
        p_ret lv gs tc rc a = true -> TPc tc le -> PInv m ->
        eval_expr ge e le m a v -> vok SafeB nb0 rc v.
    Proof.
      intros rc a le m v Hok HP Hi Hev.
      exact (cle_vok _ _ _ _ _ Hok (pb_cx _ _ _ _ HP Hi Hev)).
    Qed.

    Lemma pb_call : forall optid a al le m t le' m' out,
        p_call lv gs tc ct optid a al = true -> TPc tc le ->
        exec_stmt function_entry2 ge e le m (Scall optid a al) t le' m' out ->
        PInv m -> PInv m' /\ TPc tc le'.
    Proof.
      intros optid a al le m t le' m' out Hok HP Hx Hi.
      destruct a as [ | | | | fid fty | | | | | | | | | ]; try discriminate Hok.
      destruct fty as [ | | | | | | targs tres tcc | | ]; try discriminate Hok.
      cbn [p_call] in Hok. apply andb_prop in Hok as [Hnl Hok]. apply negb_true_iff in Hnl.
      destruct (ct_find fid ct) as [[pcs rc]|] eqn:Hf; [ | discriminate Hok ].
      apply andb_prop in Hok as [Hal Hopt].
      assert (Hnone : e ! fid = None).
      { destruct (e ! fid) as [[b ty]|] eqn:E; [ | reflexivity ].
        destruct (proj1 HEI _ _ _ E) as (Hm & _). congruence. }
      inv Hx.
      match goal with Hcf : classify_fun _ = fun_case_f _ _ _ |- _ =>
        cbn in Hcf; injection Hcf as <- <- <- end.
      match goal with Hee : eval_expr _ _ _ _ (Evar _ _) ?vf |- _ =>
        destruct (evar_fun_val _ _ _ _ _ _ _ _ _ Hee Hnone) as (lf & Hsy & ->) end.
      match goal with Hff : Genv.find_funct _ _ = Some ?fd,
                      Hfc : eval_funcall _ _ _ ?fd _ _ _ _,
                      Hel : eval_exprlist _ _ _ _ _ _ _ |- _ =>
        destruct (Hct _ _ _ Hf lf fd Hsy Hff _ _ _ _ _ Hfc
                    (args_sound _ _ _ _ SafeB nb0 lv gs tc HP (proj1 HEI) (proj2 HEI) Hgs
                       (pb_R7 m Hi) (proj2 (proj2 Hi)) _ _ _ Hel _ Hal) Hi) as (Hi' & Hr) end.
      split; [ exact Hi' | ].
      intros t0 v0 Hg. destruct optid as [ti|]; cbn [set_opttemp] in Hg; [ | exact (HP _ _ Hg) ].
      destruct (peq t0 ti) as [-> | Hne].
      - rewrite PTree.gss in Hg. injection Hg as <-. exact (cle_vok _ _ _ _ _ Hopt Hr).
      - rewrite PTree.gso in Hg by exact Hne. exact (HP _ _ Hg).
    Qed.
  End Fn.

  (* THE BODY LEMMA *)
  Lemma body_csp : forall gs tc ct pcs rc f,
      (forall x b, mem_id x gs = true -> Genv.find_symbol ge x = Some b -> SafeB b) ->
      pchk gs tc ct rc f = true ->
      par_ok tc (map fst (fn_params f)) pcs = true ->
      ct_ok ct ->
      csp pcs rc (Internal f).
  Proof.
    intros gs tc ct pcs rc f Hgs Hchk Hpar Hct m vargs t m' vres Hevf Hva Hi.
    destruct Hi as (Hf & Hnb & HL).
    pose proof Hf as (Hv & Hs & HM).
    inv Hevf.
    match goal with He : function_entry2 _ _ _ _ _ _ _ |- _ => inv He end.
    match goal with Ha : alloc_variables _ _ _ _ _ _ |- _ => rename Ha into Hav end.
    match goal with Hb : bind_parameter_temps _ _ _ = Some _ |- _ => rename Hb into Hbp end.
    match goal with Hfl : Mem.free_list _ _ = Some _ |- _ => rename Hfl into Hfree end.
    match goal with Ho : outcome_result_value _ _ _ _ |- _ => rename Ho into Hor end.
    set (lv := map fst (fn_vars f)) in *.
    pose proof (MtxfBody.av_facts bm MWF _ _ _ _ _ _ (mwf_real_alloc lp bm bc oc0 SafeB pb_Hbc_bm) Hav Hf)
      as Hf1.
    destruct (av_pinv _ _ _ _ _ Hav
                ltac:(intros x b ty Hx; rewrite PTree.gempty in Hx; discriminate Hx) Hnb HL)
      as (Hnb1 & HL1 & He1).
    assert (HEI : EIL lv e).
    { split.
      - intros x b ty Hx. split; [ | exact (He1 _ _ _ Hx) ].
        destruct (mem_id x lv) eqn:E; [ reflexivity | exfalso ].
        rewrite (alloc_variables_unbound _ _ _ _ _ _ Hav x (MtxfBody.mem_id_notin _ _ E)) in Hx.
        rewrite PTree.gempty in Hx. discriminate Hx.
      - intros x Hx. destruct (alloc_variables_in_bound _ _ _ _ _ _ Hav x (MtxfBody.mem_id_In _ _ Hx))
          as (b & ty & E). congruence. }
    assert (HP1 : TPc tc le1).
    { intros t0 v Hg.
      destruct (ObjHelpersBodies.bind_get _ _ _ _ _ _ Hbp Hg) as [Hu | (i & Hi & Hvi)].
      - apply MtxfBody.create_undef_temps_get in Hu. subst v. apply vok_undef.
      - destruct (forall2_nth_l _ _ _ _ _ Hva Hvi) as (c & Hc).
        exact (cle_vok _ _ _ _ _ (par_ok_nth _ _ _ _ _ _ Hpar Hi Hc)
                 (forall2_nth _ _ _ _ _ _ Hva Hc Hvi)). }
    lazymatch goal with Hb : exec_stmt _ _ ?E ?LE ?M1 _ _ _ ?M2 _ |- _ =>
      destruct (sw_walk ge E PInv (TPc tc) (vok SafeB nb0 rc)
                  (p_set lv gs tc) (p_store lv gs tc) (p_call lv gs tc ct) (p_ret lv gs tc rc)
                  ltac:(intros ? ? ? ? ? J1 J2 J3 J4; eapply pb_set; eassumption)
                  ltac:(intros ? ? ? ? ? ? ? ? J1 J2 J3 J4; eapply pb_store; eassumption)
                  ltac:(intros ? ? ? ? ? ? ? ? ? J1 J2 J3 J4; eapply pb_call; eassumption)
                  ltac:(intros ? ? ? ? J1 J2 J3 J4; eapply pb_ret; eassumption)
                  _ _ _ _ _ _ _ _ Hb eq_refl Hchk HP1 (conj Hf1 (conj Hnb1 HL1)))
        as (((Hv2 & Hs2 & HM2) & Hnb2 & HL2) & _ & Hout)
    end.
    assert (Hfa : Forall (fun blh => let '(b,_,_) := blh in b <> bm)
                    (blocks_of_env (lp_ge lp) e)).
    { eapply Forall_impl; [ | exact (blocks_of_env_bm lp bm _ _ _ _ Hav Hv) ].
      intros [[b lo] hi] Hq. exact Hq. }
    destruct (vfc_free_list_frame not_tainted bm _ _ _ Hfa Hfree Hv2 Hs2) as (Hvf & Hsf).
    destruct (free_pinv _ _ _ Hfree Hnb2 HL2) as (Hnb3 & HL3).
    split; [ exact (conj (conj Hvf (conj Hsf (mwf_real_free lp bm bc oc0 SafeB pb_Hbc_bm _ _ _ Hfree HM2)))
                         (conj Hnb3 HL3)) | ].
    intros bb oo Ev. subst vres.
    destruct out as [ | | | [[v' t']|] ]; cbn in Hor.
    - contradiction Hor.
    - contradiction Hor.
    - destruct (fn_return f); try contradiction Hor; discriminate Hor.
    - destruct Hor as (_ & Hc). exact (Hout _ _ (sem_cast_vptr_inv _ _ _ _ _ _ Hc)).
    - destruct (fn_return f); try contradiction Hor; discriminate Hor.
  Qed.

  (* ---- the print tree, bottom-up ---- *)
  Definition print_gs : list ident :=
    print._gEffectsMemoryPool :: print._sTextLabels :: print._sTextLabelsCount :: nil.

  Lemma print_gs_sub : forall x, mem_id x print_gs = true -> mem_id x safe_ptr_syms = true.
  Proof.
    intros x H. unfold print_gs in H. cbn [mem_id existsb] in H.
    repeat (apply orb_true_iff in H as [E | H];
            [ apply Pos.eqb_eq in E; subst x; vm_compute; reflexivity | ]).
    discriminate H.
  Qed.
  Lemma pgs : forall x b, mem_id x print_gs = true ->
      Genv.find_symbol ge x = Some b -> SafeB b.
  Proof.
    intros x b Hx Hs. destruct HSafeB_syms as (_ & _ & Hc).
    exact (Hc x b (print_gs_sub x Hx) Hs).
  Qed.

  Lemma ct_nil : ct_ok nil.
  Proof. intros fid pcs rc H. discriminate H. Qed.

  Lemma ct_cons : forall fid s ct, cres fid (fst s) (snd s) -> ct_ok ct -> ct_ok ((fid, s) :: ct).
  Proof.
    intros fid s ct Hs Hct fid' pcs rc H. unfold ct_find in H. cbn [find fst] in H.
    destruct (Pos.eqb fid fid') eqn:E.
    - apply Pos.eqb_eq in E. subst fid'. injection H as Es. subst s. exact Hs.
    - exact (Hct fid' pcs rc H).
  Qed.

  Let LO_mem := linked12_LO_memory lp H12.
  Let LO_print := linked12_LO_print lp H12.

  (* mem_pool_alloc (memory.c): all SafeB-world *)
  Definition tc_mpa : ident -> cls := tcl nil cS.
  Lemma chk_mpa : pchk print_gs tc_mpa nil cS memory.f_mem_pool_alloc = true.
  Proof. vm_compute. reflexivity. Qed.
  Lemma par_mpa : par_ok tc_mpa (map fst (fn_params memory.f_mem_pool_alloc)) [cS; cS] = true.
  Proof. vm_compute. reflexivity. Qed.
  Lemma dm_mpa : (prog_defmap memory.prog) ! print._mem_pool_alloc
                 = Some (Gfun (Internal memory.f_mem_pool_alloc)).
  Proof. vm_compute. reflexivity. Qed.
  Lemma cr_mpa : cres print._mem_pool_alloc [cS; cS] cS.
  Proof.
    exact (cres_of _ _ _ _ _ LO_mem dm_mpa (body_csp _ _ _ _ _ _ pgs chk_mpa par_mpa ct_nil)).
  Qed.

  (* int_pow *)
  Definition tc_ip : ident -> cls := tcl nil cS.
  Lemma chk_ip : pchk print_gs tc_ip nil cS print.f_int_pow = true.
  Proof. vm_compute. reflexivity. Qed.
  Lemma par_ip : par_ok tc_ip (map fst (fn_params print.f_int_pow)) [cS; cS] = true.
  Proof. vm_compute. reflexivity. Qed.
  Lemma dm_ip : (prog_defmap print.prog) ! print._int_pow
                = Some (Gfun (Internal print.f_int_pow)).
  Proof. vm_compute. reflexivity. Qed.
  Lemma cr_ip : cres print._int_pow [cS; cS] cS.
  Proof.
    exact (cres_of _ _ _ _ _ LO_print dm_ip (body_csp _ _ _ _ _ _ pgs chk_ip par_ip ct_nil)).
  Qed.

  (* format_integer(n, base, dest, &len, width, zeroPad) *)
  Definition ct_fi : ctab := [(print._int_pow, ([cS; cS], cS))].
  Definition tc_fi : ident -> cls := tcl [(print._totalLength, cL)] cS.
  Definition pcs_fi : list cls := [cS; cS; cS; cL; cS; cS].
  Lemma chk_fi : pchk print_gs tc_fi ct_fi cS print.f_format_integer = true.
  Proof. vm_compute. reflexivity. Qed.
  Lemma par_fi : par_ok tc_fi (map fst (fn_params print.f_format_integer)) pcs_fi = true.
  Proof. vm_compute. reflexivity. Qed.
  Lemma dm_fi : (prog_defmap print.prog) ! print._format_integer
                = Some (Gfun (Internal print.f_format_integer)).
  Proof. vm_compute. reflexivity. Qed.
  Lemma ct_fi_ok : ct_ok ct_fi.
  Proof. apply ct_cons; [ exact cr_ip | exact ct_nil ]. Qed.
  Lemma cr_fi : cres print._format_integer pcs_fi cS.
  Proof.
    exact (cres_of _ _ _ _ _ LO_print dm_fi (body_csp _ _ _ _ _ _ pgs chk_fi par_fi ct_fi_ok)).
  Qed.

  (* parse_width_field(str, &srcIndex, &width, &zeroPad) *)
  Definition tc_pwf : ident -> cls :=
    tcl [(print._str, cA); (print._srcIndex, cL); (print._width, cL); (print._zeroPad, cL);
         (print._digitsLen, cN); (print._i, cN)] cS.
  Definition pcs_pwf : list cls := [cA; cL; cL; cL].
  Lemma chk_pwf : pchk print_gs tc_pwf nil cS print.f_parse_width_field = true.
  Proof. vm_compute. reflexivity. Qed.
  Lemma par_pwf : par_ok tc_pwf (map fst (fn_params print.f_parse_width_field)) pcs_pwf = true.
  Proof. vm_compute. reflexivity. Qed.
  Lemma dm_pwf : (prog_defmap print.prog) ! print._parse_width_field
                 = Some (Gfun (Internal print.f_parse_width_field)).
  Proof. vm_compute. reflexivity. Qed.
  Lemma cr_pwf : cres print._parse_width_field pcs_pwf cS.
  Proof.
    exact (cres_of _ _ _ _ _ LO_print dm_pwf (body_csp _ _ _ _ _ _ pgs chk_pwf par_pwf ct_nil)).
  Qed.

  (* print_text_fmt_int(x, y, str, n) *)
  Definition ct_ptfi : ctab :=
    [(print._mem_pool_alloc, ([cS; cS], cS));
     (print._parse_width_field, (pcs_pwf, cS));
     (print._format_integer, (pcs_fi, cS))].
  Definition tc_ptfi : ident -> cls := tcl [(print._str, cA)] cS.
  Definition pcs_ptfi : list cls := [cN; cN; cA; cN].
  Lemma chk_ptfi : pchk print_gs tc_ptfi ct_ptfi cS print.f_print_text_fmt_int = true.
  Proof. vm_compute. reflexivity. Qed.
  Lemma par_ptfi : par_ok tc_ptfi (map fst (fn_params print.f_print_text_fmt_int)) pcs_ptfi = true.
  Proof. vm_compute. reflexivity. Qed.
  Lemma ct_ptfi_ok : ct_ok ct_ptfi.
  Proof.
    apply ct_cons; [ exact cr_mpa | ].
    apply ct_cons; [ exact cr_pwf | ].
    apply ct_cons; [ exact cr_fi | exact ct_nil ].
  Qed.
  Lemma csp_ptfi : csp pcs_ptfi cS (Internal print.f_print_text_fmt_int).
  Proof. exact (body_csp _ _ _ _ _ _ pgs chk_ptfi par_ptfi ct_ptfi_ok). Qed.
End PB.

(* ---------------------------------------------------------------------- *)
(* 5. The capstone-facing residual.                                         *)
(* ---------------------------------------------------------------------- *)

Lemma wgate_ptfi_elim : forall bm SafeB vargs,
  wgate bm SafeB T_ptfi vargs ->
  nptr (nth 0 vargs Vundef) /\ nptr (nth 1 vargs Vundef) /\ nptr (nth 3 vargs Vundef).
Proof.
  intros bm SafeB vargs H. unfold wgate in H.
  destruct (type_eq T_ptfi T_ffc) as [E | _]; [ discriminate E | ].
  destruct (type_eq T_ptfi T_f32w) as [E | _]; [ discriminate E | ].
  destruct (type_eq T_ptfi T_v3fcopy) as [E | _]; [ discriminate E | ].
  destruct (type_eq T_ptfi T_v3fset) as [E | _]; [ discriminate E | ].
  destruct (type_eq T_ptfi T_v3scopy) as [E | _]; [ discriminate E | ].
  destruct (type_eq T_ptfi T_vfc) as [E | _]; [ discriminate E | ].
  destruct (type_eq T_ptfi T_scm) as [E | _]; [ discriminate E | ].
  destruct (type_eq T_ptfi T_ptfi) as [_ | N]; [ exact H | exact (False_ind _ (N eq_refl)) ].
Qed.

Lemma Hptfi_body_proved :
  forall lp, linked12 lp ->
  forall bm bc oc0 SafeB,
    SafeB_syms_ok lp SafeB ->
    (exists init, spawn_ok lp init bm bc oc0) ->
    RestSurface.body_pres_w lp (MWF_real lp bm bc oc0 SafeB) bm SafeB print.f_print_text_fmt_int.
Proof.
  intros lp H12 bm bc oc0 SafeB HSafeB_syms Hspawn m vargs t m' vres Hgate Hevf HM Hv Hsat.
  rewrite print_ptfi_type in Hgate.
  destruct (wgate_ptfi_elim _ _ _ Hgate) as (Hx & Hy & Hn).
  set (nb0 := Mem.nextblock m).
  assert (Hn_safe : forall b, SafeB b -> Plt b nb0)
    by (intros b Hs; exact (mwf_real_safe_valid lp bm bc oc0 SafeB m HM b Hs)).
  assert (Hn_glob : forall gid bg, Genv.find_symbol (lp_ge lp) gid = Some bg -> Plt bg nb0)
    by (intros gid bg Hg;
        exact (glob_valid_of_nextbound lp m (mwf_real_nextbound lp bm bc oc0 SafeB m HM) gid bg Hg)).
  (* the arguments: x, y, n not pointers (the gate), str anything *)
  assert (Hva : Forall2 (vok SafeB nb0) pcs_ptfi vargs).
  { inv Hevf.
    match goal with He : function_entry2 _ _ _ _ _ _ _ |- _ => inv He end.
    match goal with Hb : bind_parameter_temps _ _ _ = Some _ |- _ => revert Hb end.
    cbn [fn_params print.f_print_text_fmt_int bind_parameter_temps].
    destruct vargs as [| v0 [| v1 [| v2 [| v3 [| v4 vr]]]]]; cbn; intros Hb; try discriminate Hb.
    cbn in Hx, Hy, Hn. unfold pcs_ptfi.
    repeat apply Forall2_cons; try apply Forall2_nil; intros b o E; cbn [pc];
      [ exact (Hx b o E) | exact (Hy b o E) | exact I | exact (Hn b o E) ]. }
  destruct (csp_ptfi lp H12 bm bc oc0 SafeB HSafeB_syms Hspawn nb0 Hv Hn_safe Hn_glob
              m vargs t m' vres Hevf Hva
              (conj (conj Hv (conj Hsat HM)) (conj (Ple_refl _)
                 (fun b ofs b' o' Hb Hld => False_ind _
                    (Plt_strict _ (Plt_Ple_trans _ _ _ (load_valid _ _ _ _ _ Hld) Hb))))))
    as (((Hv' & Hs' & HM') & _) & _).
  exact (conj Hv' (conj Hs' HM')).
Qed.
