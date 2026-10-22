(* ====================================================================== *)
(* spawn_object / spawn_object_abs_with_rot, PROVED FROM THEIR REAL BODIES *)
(* (SPINE: premise sweep, 2026-10-21).                                     *)
(*                                                                        *)
(* spawn_object.c is linked (the 31st TU, LinkedTwelve.tu_rest), so the   *)
(* whole spawn call tree has real bodies:                                 *)
(*   object_helpers.c : spawn_object, spawn_object_abs_with_rot,          *)
(*                      spawn_object_at_origin, obj_copy_pos_and_angle,   *)
(*                      obj_copy_pos, obj_copy_angle, obj_set_pos,        *)
(*                      obj_set_angle, find_unimportant_object;           *)
(*   spawn_object.c   : create_object, allocate_object,                   *)
(*                      try_allocate_object, unload_object,               *)
(*                      deallocate_object, snap_object_to_floor;          *)
(*   graph_node.c     : geo_obj_init, geo_add_child, geo_remove_child;    *)
(*   math_util.c      : mtxf_identity, vec3f_set, vec3f_copy, vec3s_copy; *)
(*   memory.c         : segmented_to_virtual (the identity, TRUST 2.2);   *)
(*   surface_collision.c : find_floor (its frame, SurfaceBodies);         *)
(*   audio            : stop_sounds_from_source -- NOT linked (audio is   *)
(*                      deferred): the labeled open premise sss_inert.    *)
(* allocate_object's pool-exhausted branch is `while (TRUE) {}`: it has   *)
(* no terminating execution, so no big-step derivation reaches past it.   *)
(*                                                                        *)
(* THE CLAIM ("the SafeB world"): if every argument is SafeB-if-pointer,  *)
(* the call keeps the carried run facts and returns a SafeB-if-pointer    *)
(* value.  Every pointer the tree touches comes from an argument, from a  *)
(* SafeB global (gFreeObjectList, gObjParentGraphNode, gObjectLists,      *)
(* gLoadedGraphNodes, gVec3fZero, gVec3sZero: CensusV2.spawn_safe_syms,   *)
(* SpawnInit.SafeB_syms_ok (c)), or from a load out of a SafeB block      *)
(* (MWF's load closure R7).  Every store lands in a SafeB block with a    *)
(* SafeB-if-pointer value (MWFReal.mwf_real_chase_ptr), in a vec / matrix *)
(* field of a SafeB object (the math_util frames), or in                  *)
(* snap_object_to_floor's stack local (find_floor's out cell).            *)
(*                                                                        *)
(* FOUND FALSE: the old any-argument rows Hcp_spawn_real / Hcp_soawr_real *)
(* (WindSurface.call_pres_ext_sr).  spawn_object_at_origin stores its     *)
(* `parent` argument into obj->parentObj, a pointer field of a SafeB pool *)
(* object, and create_object stores `behavior` into obj->curBhvCommand /  *)
(* obj->behavior: with parent = Mario's own block (or any non-SafeB       *)
(* block) R7 fails, so MWF_real does not survive.  RESTATED: the gated    *)
(* row call_pres_ext_sg takes every argument SafeB-if-pointer; the walked *)
(* call sites pass a chase temp (an object), a model constant and a bhv*  *)
(* script symbol (CensusV2.spawn_bhv_syms, SafeB symbols).                *)
(*                                                                        *)
(* The walk (sw_chk) is a generic loop- and switch-tolerant walk whose    *)
(* temp invariant is "every temp is SafeB-if-pointer"; its expression     *)
(* recognizer sx is sound for any body (sx_sound), and the call arms take *)
(* a table of callees already proved (bottom-up).                         *)
(* ====================================================================== *)

From Coq Require Import ZArith List Lia Bool String.
From compcert Require Import Coqlib Maps AST Integers Values Events Memory
  Globalenvs Ctypes Cop Clightdefs Clight ClightBigstep Linking.
From SM64.Generated Require mario memory math_util object_helpers graph_node
  spawn_object surface_collision behavior_actions interaction mario_actions_cutscene.
From SM64.Proofs Require Import SymbolicLinking ActionValueFrame Taint
  RealFrameLinked AGates CensusV2 RestSurface MWFReal SpawnInit MathGeomBodies
  MathGeomGated OutParamSurface MathBodies LinkedTwelve LocalVarsSurface
  SurfaceBodies.
From SM64.Proofs Require MtxfBody ActWriterSurface RetSurface SaveDoSaveBody
  ObjHelpersBodies WindSurface.

Import ListNotations.
Local Open Scope Z_scope.

(* ---------------------------------------------------------------------- *)
(* 1. Values: SafeB-if-pointer.                                            *)
(* ---------------------------------------------------------------------- *)

Definition safev (SafeB : block -> Prop) (v : val) : Prop :=
  forall b o, v = Vptr b o -> SafeB b.

Lemma decode_vptr_chunk : forall ch bl b o,
    decode_val ch bl = Vptr b o -> ch = Mint32 \/ ch = Many32 \/ ch = Many64.
Proof.
  intros ch bl b o H. unfold decode_val in H.
  destruct (proj_bytes bl).
  - destruct ch; try discriminate H;
      try (unfold Val.norm_bool in H; destruct (Val.is_bool _); discriminate H).
  - destruct ch; auto; try discriminate H;
      try (unfold Val.norm_bool in H; destruct (Val.is_bool _); discriminate H);
      cbn in H; discriminate H.
Qed.

Lemma load_vptr_chunk : forall ch m b z b' o',
    Mem.load ch m b z = Some (Vptr b' o') -> ch = Mint32 \/ ch = Many32 \/ ch = Many64.
Proof.
  intros ch m b z b' o' H.
  apply Mem.load_result in H. symmetry in H.
  exact (decode_vptr_chunk _ _ _ _ H).
Qed.

(* the value of an access_mode load is a pointer only through Mint32 = Mptr *)
Definition rvok (ty : type) (addr_ok : bool) : bool :=
  match access_mode ty with
  | By_value Mint32 => addr_ok
  | By_value Many32 | By_value Many64 => false
  | By_value _ => true
  | By_reference | By_copy => addr_ok
  | By_nothing => true
  end.

Lemma vint_binop_sound : forall cenv op v1 t1 v2 t2 m v,
    RetSurface.vint_binop op = true ->
    sem_binary_operation cenv op v1 t1 v2 t2 m = Some v ->
    forall b o, v <> Vptr b o.
Proof.
  intros cenv op v1 t1 v2 t2 m v Hop Hs b o.
  exact (RetSurface.sem_binop_vint_not_vptr cenv op v1 t1 v2 t2 m v Hop Hs b o).
Qed.

(* ---------------------------------------------------------------------- *)
(* 2. The expression recognizer and its soundness.                         *)
(*    lv: the function's locals (never SafeB); gs: SafeB global symbols.   *)
(* ---------------------------------------------------------------------- *)

Definition gsym_ok (lv gs : list ident) (x : ident) : bool :=
  negb (mem_id x lv) && mem_id x gs.

Fixpoint sx (lv gs : list ident) (a : expr) : bool :=
  match a with
  | Econst_int _ _ | Econst_float _ _ | Econst_single _ _ | Econst_long _ _ => true
  | Esizeof _ _ | Ealignof _ _ => true
  | Etempvar _ _ => true
  | Eunop _ _ _ => true
  | Ecast a1 _ => sx lv gs a1
  | Ebinop Oadd a1 a2 _ => sx lv gs a1 && sx lv gs a2
  | Ebinop Osub a1 _ _ => sx lv gs a1
  | Ebinop op _ _ _ => RetSurface.vint_binop op
  | Evar x ty => rvok ty (gsym_ok lv gs x)
  | Ederef a1 ty => rvok ty (sx lv gs a1)
  | Efield a1 _ ty => rvok ty (sx lv gs a1)
  | Eaddrof a1 _ =>
      match a1 with
      | Evar x _ => gsym_ok lv gs x
      | Ederef a2 _ | Efield a2 _ _ => sx lv gs a2
      | _ => false
      end
  end.

(* the lvalue's block is SafeB *)
Definition slv (lv gs : list ident) (a : expr) : bool :=
  match a with
  | Evar x _ => gsym_ok lv gs x
  | Ederef a1 _ | Efield a1 _ _ => sx lv gs a1
  | _ => false
  end.

Lemma sx_addrof : forall lv gs a ty, sx lv gs (Eaddrof a ty) = slv lv gs a.
Proof. intros lv gs a ty. destruct a; reflexivity. Qed.

Section SX.
  Variable ge : genv.
  Variable e : env.
  Variable le : temp_env.
  Variable m : mem.
  Variable SafeB : block -> Prop.
  Variables lv gs : list ident.

  Hypothesis Hle : forall t v, le ! t = Some v -> safev SafeB v.
  Hypothesis He : forall x b ty, e ! x = Some (b, ty) -> mem_id x lv = true.
  Hypothesis Hgs : forall x b, mem_id x gs = true -> Genv.find_symbol ge x = Some b -> SafeB b.
  Hypothesis R7 : forall b ofs b' o', SafeB b ->
      Mem.loadv Mint32 m (Vptr b ofs) = Some (Vptr b' o') -> SafeB b'.

  Lemma deref_safe : forall ty loc ofs bf v ok,
      deref_loc ty m loc ofs bf v -> rvok ty ok = true ->
      (ok = true -> SafeB loc) -> safev SafeB v.
  Proof.
    intros ty loc ofs bf v ok Hd Hr Hok b o Ev. subst v.
    inv Hd.
    - match goal with Ha : access_mode _ = By_value ?c, Hl : Mem.loadv ?c _ _ = Some _ |- _ =>
        unfold rvok in Hr; rewrite Ha in Hr; pose proof Hl as Hl'; cbn in Hl';
        destruct (load_vptr_chunk _ _ _ _ _ _ Hl') as [-> | [-> | ->]];
        [ exact (R7 _ _ _ _ (Hok Hr) Hl) | discriminate Hr | discriminate Hr ] end.
    - match goal with Ha : access_mode _ = By_reference |- _ =>
        unfold rvok in Hr; rewrite Ha in Hr; exact (Hok Hr) end.
    - match goal with Ha : access_mode _ = By_copy |- _ =>
        unfold rvok in Hr; rewrite Ha in Hr; exact (Hok Hr) end.
    - match goal with Hl : load_bitfield _ _ _ _ _ _ _ _ |- _ => inv Hl end.
  Qed.

  Lemma sx_sound_mut :
    (forall a v, eval_expr ge e le m a v -> sx lv gs a = true -> safev SafeB v) /\
    (forall a b o bf, eval_lvalue ge e le m a b o bf -> slv lv gs a = true -> SafeB b).
  Proof.
    apply (eval_expr_lvalue_ind ge e le m
             (fun a v => sx lv gs a = true -> safev SafeB v)
             (fun a b o bf => slv lv gs a = true -> SafeB b));
      intros; cbn [sx slv] in *.
    - intros bb oo E; discriminate E.
    - intros bb oo E; discriminate E.
    - intros bb oo E; discriminate E.
    - intros bb oo E; discriminate E.
    - eapply Hle; eassumption.
    - intros bb oo E. injection E as <- <-. apply H0.
      destruct a; try exact H1; discriminate H1.
    - intros bb oo E. subst. exfalso.
      eapply ActWriterSurface.sem_unop_nonptr; [ eassumption | reflexivity ].
    - (* Ebinop *)
      intros bb oo E. subst.
      destruct op;
        try (exfalso; eapply vint_binop_sound; [ eassumption | eassumption | reflexivity ]).
      + apply andb_prop in H4 as [Ha1 Ha2].
        cbn [sem_binary_operation] in H3.
        destruct (SaveDoSaveBody.sem_add_vptr_src _ _ _ _ _ _ _ _ H3) as [(o1 & E1) | (o2 & E2)].
        * exact (H0 Ha1 _ _ E1).
        * exact (H2 Ha2 _ _ E2).
      + cbn [sem_binary_operation] in H3.
        destruct (SaveDoSaveBody.sem_sub_vptr_src _ _ _ _ _ _ _ _ H3) as (o1 & E1).
        exact (H0 H4 _ _ E1).
    - intros bb oo E. subst.
      pose proof (sem_cast_vptr_inv _ _ _ _ _ _ H1) as E1. exact (H0 H2 _ _ E1).
    - intros bb oo E. unfold Vptrofs in E. destruct Archi.ptr64; discriminate E.
    - intros bb oo E. unfold Vptrofs in E. destruct Archi.ptr64; discriminate E.
    - (* Elvalue *)
      destruct a;
        try (match goal with Hl : eval_lvalue _ _ _ _ _ _ _ _ |- _ => inv Hl end; fail).
      + cbn [sx typeof] in H2.
        eapply deref_safe; [ exact H1 | exact H2 | ]. intro Hg. apply H0. exact Hg.
      + cbn [sx typeof] in H2.
        eapply deref_safe; [ exact H1 | exact H2 | ]. intro Hg. apply H0. exact Hg.
      + cbn [sx typeof] in H2.
        eapply deref_safe; [ exact H1 | exact H2 | ]. intro Hg. apply H0. exact Hg.
    - (* Evar local *)
      exfalso. unfold gsym_ok in H0. rewrite (He _ _ _ H) in H0. discriminate H0.
    - (* Evar global *)
      unfold gsym_ok in H1. apply andb_prop in H1 as [_ Hg]. exact (Hgs _ _ Hg H0).
    - exact (H0 H1 _ _ eq_refl).
    - exact (H0 H4 _ _ eq_refl).
    - exact (H0 H4 _ _ eq_refl).
  Qed.

  Lemma sx_sound : forall a v, eval_expr ge e le m a v -> sx lv gs a = true -> safev SafeB v.
  Proof. exact (proj1 sx_sound_mut). Qed.

  Lemma slv_sound : forall a b o bf, eval_lvalue ge e le m a b o bf ->
      slv lv gs a = true -> SafeB b.
  Proof. exact (proj2 sx_sound_mut). Qed.

  Lemma sx_list : forall al tyl vl, eval_exprlist ge e le m al tyl vl ->
      forallb (sx lv gs) al = true -> Forall (safev SafeB) vl.
  Proof.
    intros al tyl vl Hel. induction Hel; intros Hok; [ constructor | ].
    cbn [forallb] in Hok. apply andb_prop in Hok as [H1 H2].
    constructor; [ | exact (IHHel H2) ].
    intros bb oo ->.
    match goal with Hc : sem_cast ?v1 _ _ _ = Some (Vptr bb oo),
                    Hx : eval_expr _ _ _ _ ?a ?v1 |- _ =>
      exact (sx_sound _ _ Hx H1 _ _ (sem_cast_vptr_inv _ _ _ _ _ _ Hc)) end.
  Qed.
End SX.

(* ---------------------------------------------------------------------- *)
(* 3. The statement walk: loops, switches, returns.                        *)
(* ---------------------------------------------------------------------- *)

Section SW.
  Variable ge : genv.
  Variable e : env.
  Variable Inv : mem -> Prop.
  Variable P : temp_env -> Prop.
  Variable Q : val -> Prop.
  Variable set_ok : ident -> expr -> bool.
  Variable store_ok : expr -> expr -> bool.
  Variable call_ok : option ident -> expr -> list expr -> bool.
  Variable ret_ok : expr -> bool.

  Hypothesis Hset : forall id a le m v,
      set_ok id a = true -> P le -> Inv m ->
      eval_expr ge e le m a v -> P (PTree.set id v le).
  Hypothesis Hstore : forall lv rhs le m t le' m' out,
      store_ok lv rhs = true -> P le ->
      exec_stmt function_entry2 ge e le m (Sassign lv rhs) t le' m' out ->
      Inv m -> Inv m'.
  Hypothesis Hcall : forall optid a al le m t le' m' out,
      call_ok optid a al = true -> P le ->
      exec_stmt function_entry2 ge e le m (Scall optid a al) t le' m' out ->
      Inv m -> Inv m' /\ P le'.
  Hypothesis Hret : forall a le m v,
      ret_ok a = true -> P le -> Inv m -> eval_expr ge e le m a v -> Q v.

  Definition out_ok (out : outcome) : Prop :=
    match out with
    | Out_return (Some (v, _)) => Q v
    | _ => True
    end.

  Fixpoint sw_chk (s : statement) : bool :=
    match s with
    | Sskip | Sbreak | Scontinue | Sreturn None => true
    | Sreturn (Some a) => ret_ok a
    | Sset id a => set_ok id a
    | Sassign lv rhs => store_ok lv rhs
    | Scall optid a al => call_ok optid a al
    | Ssequence s1 s2 => sw_chk s1 && sw_chk s2
    | Sifthenelse _ s1 s2 => sw_chk s1 && sw_chk s2
    | Sloop s1 s2 => sw_chk s1 && sw_chk s2
    | Sswitch _ sl => sw_chk_ls sl
    | _ => false
    end
  with sw_chk_ls (sl : labeled_statements) : bool :=
    match sl with
    | LSnil => true
    | LScons _ s sl' => sw_chk s && sw_chk_ls sl'
    end.

  Lemma sw_chk_ls_seq : forall sl, sw_chk_ls sl = true ->
      sw_chk (seq_of_labeled_statement sl) = true.
  Proof.
    induction sl as [| c s sl IH]; intros H; cbn [sw_chk_ls seq_of_labeled_statement] in *.
    - reflexivity.
    - apply andb_prop in H as [H1 H2]. cbn [sw_chk]. rewrite H1, (IH H2). reflexivity.
  Qed.

  Lemma sw_chk_ls_find : forall sl c sl', select_switch_case c sl = Some sl' ->
      sw_chk_ls sl = true -> sw_chk_ls sl' = true.
  Proof.
    induction sl as [| c0 s sl IH]; intros c sl' Hs H; cbn in Hs; [ discriminate Hs | ].
    destruct c0 as [c0|].
    - destruct (zeq c0 c).
      + injection Hs as <-. exact H.
      + apply andb_prop in H as [_ H2]. exact (IH _ _ Hs H2).
    - apply andb_prop in H as [_ H2]. exact (IH _ _ Hs H2).
  Qed.

  Lemma sw_chk_ls_dflt : forall sl, sw_chk_ls sl = true ->
      sw_chk_ls (select_switch_default sl) = true.
  Proof.
    induction sl as [| c0 s sl IH]; intros H; cbn [select_switch_default]; [ exact H | ].
    destruct c0 as [c0|]; [ | exact H ].
    apply andb_prop in H as [_ H2]. exact (IH H2).
  Qed.

  Lemma sw_chk_select : forall n sl, sw_chk_ls sl = true ->
      sw_chk (seq_of_labeled_statement (select_switch n sl)) = true.
  Proof.
    intros n sl H. apply sw_chk_ls_seq. unfold select_switch.
    destruct (select_switch_case n sl) eqn:E.
    - exact (sw_chk_ls_find _ _ _ E H).
    - exact (sw_chk_ls_dflt _ H).
  Qed.

  Lemma sw_walk : forall e1 le m s t le' m' out,
      exec_stmt function_entry2 ge e1 le m s t le' m' out -> e1 = e ->
      sw_chk s = true -> P le -> Inv m -> Inv m' /\ P le' /\ out_ok out.
  Proof.
    intros e1 le m s t le' m' out Hexec.
    induction Hexec; intros Ee Hchk Hp Hf; subst; cbn [sw_chk] in Hchk;
      try discriminate Hchk.
    - (* Sskip *) repeat split; assumption.
    - (* Sassign *)
      lazymatch goal with Hl : eval_lvalue ?gg ?ee ?ll ?mm a1 _ _ _ |- _ =>
        assert (Hx : exec_stmt function_entry2 gg ee ll mm (Sassign a1 a2) E0 ll m' Out_normal)
          by (eapply exec_Sassign; eassumption) end.
      split; [ exact (Hstore _ _ _ _ _ _ _ _ Hchk Hp Hx Hf) | split; [ exact Hp | exact I ] ].
    - (* Sset *)
      split; [ exact Hf | split; [ eapply Hset; eassumption | exact I ] ].
    - (* Scall *)
      lazymatch goal with Hee : eval_expr ?gg ?ee ?ll ?mm a _,
                          Hfc : eval_funcall _ _ _ _ _ ?tt ?mm' ?vr |- _ =>
        assert (Hx : exec_stmt function_entry2 gg ee ll mm (Scall optid a al) tt
                       (set_opttemp optid vr ll) mm' Out_normal)
          by (eapply exec_Scall; eassumption) end.
      destruct (Hcall _ _ _ _ _ _ _ _ _ Hchk Hp Hx Hf) as [Hc1 Hc2].
      exact (conj Hc1 (conj Hc2 I)).
    - (* Sseq_1 *)
      apply andb_prop in Hchk as [H1 H2].
      destruct (IHHexec1 eq_refl H1 Hp Hf) as (Hf1 & Hp1 & _).
      exact (IHHexec2 eq_refl H2 Hp1 Hf1).
    - (* Sseq_2 *)
      apply andb_prop in Hchk as [H1 _].
      exact (IHHexec eq_refl H1 Hp Hf).
    - (* Sifthenelse *)
      apply andb_prop in Hchk as [H1 H2].
      apply IHHexec; [ reflexivity | destruct b; assumption | exact Hp | exact Hf ].
    - (* Sreturn None *) repeat split; assumption.
    - (* Sreturn Some *)
      split; [ exact Hf | split; [ exact Hp | ] ]. cbn [out_ok]. eapply Hret; eassumption.
    - repeat split; assumption.
    - repeat split; assumption.
    - (* Sloop_stop1 *)
      apply andb_prop in Hchk as [H1 _].
      destruct (IHHexec eq_refl H1 Hp Hf) as (Hf1 & Hp1 & Ho1).
      split; [ exact Hf1 | split; [ exact Hp1 | ] ].
      match goal with Hb : out_break_or_return _ _ |- _ => inv Hb end; [ exact I | exact Ho1 ].
    - (* Sloop_stop2 *)
      apply andb_prop in Hchk as [H1 H2].
      destruct (IHHexec1 eq_refl H1 Hp Hf) as (Hf1 & Hp1 & _).
      destruct (IHHexec2 eq_refl H2 Hp1 Hf1) as (Hf2 & Hp2 & Ho2).
      split; [ exact Hf2 | split; [ exact Hp2 | ] ].
      match goal with Hb : out_break_or_return _ _ |- _ => inv Hb end; [ exact I | exact Ho2 ].
    - (* Sloop_loop *)
      pose proof Hchk as Hchk'. apply andb_prop in Hchk as [H1 H2].
      destruct (IHHexec1 eq_refl H1 Hp Hf) as (Hf1 & Hp1 & _).
      destruct (IHHexec2 eq_refl H2 Hp1 Hf1) as (Hf2 & Hp2 & _).
      exact (IHHexec3 eq_refl Hchk' Hp2 Hf2).
    - (* Sswitch *)
      destruct (IHHexec eq_refl (sw_chk_select _ _ Hchk) Hp Hf) as (Hf1 & Hp1 & Ho1).
      split; [ exact Hf1 | split; [ exact Hp1 | ] ].
      destruct out as [ | | | [[vr tyr]|] ]; cbn; auto.
  Qed.
End SW.

(* ---------------------------------------------------------------------- *)
(* 4. The per-function recognizer.                                          *)
(*    lv: the function's locals; gs: the SafeB globals; vt: the callees     *)
(*    already proved (bottom-up).                                           *)
(* ---------------------------------------------------------------------- *)

(* the SafeB globals the tree touches (CensusV2.spawn_safe_syms) *)
Definition sb_gs : list ident :=
  graph_node._gObjParentGraphNode :: spawn_object._gFreeObjectList
    :: spawn_object._gObjectLists :: object_helpers._gLoadedGraphNodes
    :: object_helpers._gVec3fZero :: object_helpers._gVec3sZero :: nil.

Definition vec_ids : list ident :=
  math_util._vec3f_set :: math_util._vec3f_copy :: math_util._vec3s_copy :: nil.

Definition ptr_ty (t : type) : bool :=
  match t with Tpointer _ _ => true | _ => false end.

(* an array field of a SafeB object: its address is in that object *)
Definition arr_arg (lv gs : list ident) (a : expr) : bool :=
  match a with
  | Efield a1 _ (Tarray _ _ _) => sx lv gs a1
  | _ => false
  end.

(* vec3f_set / vec3f_copy / vec3s_copy (dest, ...): dest an array field of
   a SafeB object; the result (&dest of the callee's frame) is dropped *)
Definition vec_ok (lv gs : list ident) (optid : option ident) (targs : list type)
    (al : list expr) : bool :=
  match optid with
  | Some _ => false
  | None =>
      match al, targs with
      | a0 :: _, t0 :: _ => arr_arg lv gs a0 && ptr_ty t0
      | _, _ => false
      end
  end.

(* find_floor(x, y, z, &local) *)
Definition ff_ok (lv : list ident) (targs : list type) (al : list expr) : bool :=
  match nth_error al 3, nth_error targs 3 with
  | Some (Eaddrof (Evar x _) _), Some t3 => mem_id x lv && ptr_ty t3
  | _, _ => false
  end.

Definition s_set (lv gs : list ident) (id : ident) (a : expr) : bool := sx lv gs a.
Definition s_store (lv gs : list ident) (l r : expr) : bool :=
  slv lv gs l && MtxfBody.is_byval (typeof l) && sx lv gs r.
Definition s_ret (lv gs : list ident) (a : expr) : bool := sx lv gs a.
Definition s_call (lv gs vt : list ident) (optid : option ident) (a : expr)
    (al : list expr) : bool :=
  match a with
  | Evar fid (Tfunction targs _ _) =>
      negb (mem_id fid lv) &&
      ((mem_id fid vt && forallb (sx lv gs) al)
       || (mem_id fid vec_ids && vec_ok lv gs optid targs al)
       || (Pos.eqb fid surface_collision._find_floor && ff_ok lv targs al)
       || Pos.eqb fid spawn_object._stop_sounds_from_source)
  | _ => false
  end.

Definition sb_chk (gs vt : list ident) (f : Clight.function) : bool :=
  let lv := map fst (fn_vars f) in
  sw_chk (s_set lv gs) (s_store lv gs) (s_call lv gs vt) (s_ret lv gs) (fn_body f).

(* ---------------------------------------------------------------------- *)
(* 5. The audio boundary: stop_sounds_from_source (audio/external.c, not   *)
(*    linked).  LABELED OPEN AUDIO PREMISE (audio is deferred): it changes  *)
(*    no block of the modeled memory and returns no pointer (it is void).  *)
(*    Same shape as WMotRRequiresA/ExtInert.ext_inert.                     *)
(* ---------------------------------------------------------------------- *)

Definition sss_inert : Prop :=
  forall sg ge vargs m t vres m',
    external_functions_sem "stop_sounds_from_source" sg ge vargs m t vres m' ->
    Mem.unchanged_on (fun b _ => Mem.valid_block m b) m m' /\ (forall b o, vres <> Vptr b o).

Definition sss_named (o : option (globdef Clight.fundef type)) : bool :=
  match o with
  | Some (Gfun (External (EF_external n _) _ _ _)) => String.eqb n "stop_sounds_from_source"
  | _ => false
  end.

Lemma sss_named_so :
  sss_named ((prog_defmap spawn_object.prog) ! spawn_object._stop_sounds_from_source) = true.
Proof. vm_compute. reflexivity. Qed.

(* no linked TU defines it *)
Lemma sss_no_internal :
  forallb (fun p => no_internal_ids p [spawn_object._stop_sounds_from_source])
    (mario.prog :: tu_rest) = true.
Proof. vm_compute. reflexivity. Qed.

Lemma sss_resolve : forall lp b fd,
    linked12 lp ->
    Genv.find_symbol (globalenv lp) spawn_object._stop_sounds_from_source = Some b ->
    Genv.find_funct (globalenv lp) (Vptr b Ptrofs.zero) = Some fd ->
    exists sg targs tres cc,
      fd = External (EF_external "stop_sounds_from_source" sg) targs tres cc.
Proof.
  intros lp b fd Hlink Hs Hf.
  pose proof sss_named_so as Hn.
  destruct ((prog_defmap spawn_object.prog) ! spawn_object._stop_sounds_from_source)
    as [[[f0 | ef targs tres cc] | v0] |] eqn:Hdm0; try discriminate Hn.
  destruct ef; try discriminate Hn. cbn in Hn. apply String.eqb_eq in Hn. subst name.
  assert (Hdm' : (prog_defmap lp) ! spawn_object._stop_sounds_from_source = Some (Gfun fd)).
  { apply resolves_defmap. exists b. split; assumption. }
  pose proof (linked12_LO_spawn_object lp Hlink) as LOq.
  Local Transparent Linker_program.
  unfold linkorder, Linker_program, linkorder_program in LOq.
  destruct LOq as [LOast _].
  destruct (prog_defmap_linkorder _ _ _ _ LOast Hdm0) as (gd' & Hgd' & Hlo).
  change (prog_defmap (program_of_program lp)) with (prog_defmap lp) in Hgd'.
  rewrite Hdm' in Hgd'. injection Hgd' as <-.
  inv Hlo.
  match goal with H : linkorder _ _ |- _ => inv H end.
  - do 4 eexists. reflexivity.
  - exfalso. pose proof sss_no_internal as Hall. rewrite forallb_forall in Hall.
    assert (Hid : mem_id spawn_object._stop_sounds_from_source
                    [spawn_object._stop_sounds_from_source] = true)
      by (vm_compute; reflexivity).
    destruct (link_chain_internal_origin _ _ _ _ _ Hlink Hdm') as [Hbase | (q' & Hq & Hqdm)].
    + exact (no_internal_ids_correct _ _ _ _ (Hall _ (or_introl eq_refl)) Hid Hbase).
    + exact (no_internal_ids_correct _ _ _ _ (Hall _ (or_intror Hq)) Hid Hqdm).
Qed.

Lemma mu_dm_v3fcopy :
  (prog_defmap math_util.prog) ! math_util._vec3f_copy
    = Some (Gfun (Internal math_util.f_vec3f_copy)).
Proof. vm_compute. reflexivity. Qed.
Lemma mu_dm_v3scopy :
  (prog_defmap math_util.prog) ! math_util._vec3s_copy
    = Some (Gfun (Internal math_util.f_vec3s_copy)).
Proof. vm_compute. reflexivity. Qed.

(* ---- small value facts for the call arms ---- *)

(* an array-typed field evaluates to its own address *)
Lemma arr_field_val : forall ge e le m a1 f ty n at0 v,
    eval_expr ge e le m (Efield a1 f (Tarray ty n at0)) v ->
    exists l o bf, eval_lvalue ge e le m (Efield a1 f (Tarray ty n at0)) l o bf
                   /\ v = Vptr l o.
Proof.
  intros ge e le m a1 f ty n at0 v H. inv H.
  match goal with Hd : deref_loc _ _ _ _ _ _, Hl : eval_lvalue _ _ _ _ _ _ _ _ |- _ =>
    inv Hd; [ discriminate | | discriminate | ] end.
  - do 3 eexists. split; [ eassumption | reflexivity ].
  - match goal with Hl : load_bitfield _ _ _ _ _ _ _ _ |- _ => inv Hl end.
Qed.

(* a pointer cast keeps a pointer *)
Lemma cast_vptr_ptr : forall b o t1 t2 m v,
    sem_cast (Vptr b o) t1 t2 m = Some v -> ptr_ty t2 = true -> v = Vptr b o.
Proof.
  intros b o t1 t2 m v H Hp.
  destruct t2; try discriminate Hp.
  unfold sem_cast in H.
  destruct t1 as [ | [] [] ? | [] ? | [] ? | ? ? | ? ? ? | ? ? ? | ? ? | ? ? ];
    cbn in H; try discriminate H; try (injection H as <-; reflexivity);
    unfold Archi.ptr64 in *; cbn in H; try discriminate H; injection H as <-; reflexivity.
Qed.

(* a float-returning body returns no pointer *)
Lemma funcall_float_ret : forall (ge : genv) m f vargs t m' vres,
    eval_funcall function_entry2 ge m (Internal f) vargs t m' vres ->
    fn_return f = tfloat -> forall b o, vres <> Vptr b o.
Proof.
  intros ge m f vargs t m' vres H Hr b o Ev. subst vres. inv H.
  match goal with Ho : outcome_result_value _ _ _ _ |- _ =>
    rewrite Hr in Ho; destruct out as [ | | | [[v' t']|] ]; cbn in Ho; try contradiction Ho;
    destruct Ho as (_ & Hc) end.
  exact (sem_cast_scalar_nonptr _ _ _ _ (or_introl Hc) b o eq_refl).
Qed.

(* ---------------------------------------------------------------------- *)
(* 6. NON-VACUITY of the recognizer: it accepts the REAL generated bodies, *)
(*    bottom-up, each with the callees proved before it.                   *)
(* ---------------------------------------------------------------------- *)

Module SO := spawn_object.
Module OH := object_helpers.
Module GN := graph_node.
Module MU := math_util.

(* level 0: no proved callee needed *)
Definition vt0 : list ident := [].
Definition vt_ocpa : list ident := [OH._obj_copy_pos; OH._obj_copy_angle].
Definition vt_geo : list ident := [SO._geo_remove_child; SO._geo_add_child].
Definition vt_unload : list ident :=
  [SO._geo_remove_child; SO._geo_add_child; SO._deallocate_object].
Definition vt_alloc : list ident :=
  [SO._try_allocate_object; SO._find_unimportant_object; SO._unload_object;
   SO._mtxf_identity].
Definition vt_create : list ident := [SO._allocate_object; SO._snap_object_to_floor].
Definition vt_soao : list ident :=
  [OH._segmented_to_virtual; OH._create_object; OH._geo_obj_init].
Definition vt_spawn : list ident := [OH._spawn_object_at_origin; OH._obj_copy_pos_and_angle].
Definition vt_soawr : list ident :=
  [OH._spawn_object_at_origin; OH._obj_set_pos; OH._obj_set_angle].

Lemma chk_s2v : sb_chk sb_gs vt0 memory.f_segmented_to_virtual = true.
Proof. vm_compute. reflexivity. Qed.
Lemma chk_gac : sb_chk sb_gs vt0 GN.f_geo_add_child = true.
Proof. vm_compute. reflexivity. Qed.
Lemma chk_grc : sb_chk sb_gs vt0 GN.f_geo_remove_child = true.
Proof. vm_compute. reflexivity. Qed.
Lemma chk_goi : sb_chk sb_gs vt0 GN.f_geo_obj_init = true.
Proof. vm_compute. reflexivity. Qed.
Lemma chk_dealloc : sb_chk sb_gs vt0 SO.f_deallocate_object = true.
Proof. vm_compute. reflexivity. Qed.
Lemma chk_snap : sb_chk sb_gs vt0 SO.f_snap_object_to_floor = true.
Proof. vm_compute. reflexivity. Qed.
Lemma chk_fuo : sb_chk sb_gs vt0 OH.f_find_unimportant_object = true.
Proof. vm_compute. reflexivity. Qed.
Lemma chk_ocp : sb_chk sb_gs vt0 OH.f_obj_copy_pos = true.
Proof. vm_compute. reflexivity. Qed.
Lemma chk_oca : sb_chk sb_gs vt0 OH.f_obj_copy_angle = true.
Proof. vm_compute. reflexivity. Qed.
Lemma chk_osp : sb_chk sb_gs vt0 OH.f_obj_set_pos = true.
Proof. vm_compute. reflexivity. Qed.
Lemma chk_osa : sb_chk sb_gs vt0 OH.f_obj_set_angle = true.
Proof. vm_compute. reflexivity. Qed.
Lemma chk_mid : sb_chk sb_gs vt0 MU.f_mtxf_identity = true.
Proof. vm_compute. reflexivity. Qed.
Lemma chk_ocpa : sb_chk sb_gs vt_ocpa OH.f_obj_copy_pos_and_angle = true.
Proof. vm_compute. reflexivity. Qed.
Lemma chk_tao : sb_chk sb_gs vt_geo SO.f_try_allocate_object = true.
Proof. vm_compute. reflexivity. Qed.
Lemma chk_unload : sb_chk sb_gs vt_unload SO.f_unload_object = true.
Proof. vm_compute. reflexivity. Qed.
Lemma chk_alloc : sb_chk sb_gs vt_alloc SO.f_allocate_object = true.
Proof. vm_compute. reflexivity. Qed.
Lemma chk_create : sb_chk sb_gs vt_create SO.f_create_object = true.
Proof. vm_compute. reflexivity. Qed.
Lemma chk_soao : sb_chk sb_gs vt_soao OH.f_spawn_object_at_origin = true.
Proof. vm_compute. reflexivity. Qed.
Lemma chk_spawn : sb_chk sb_gs vt_spawn OH.f_spawn_object = true.
Proof. vm_compute. reflexivity. Qed.
Lemma chk_soawr : sb_chk sb_gs vt_soawr OH.f_spawn_object_abs_with_rot = true.
Proof. vm_compute. reflexivity. Qed.

(* the generated-AST pins: each name is its TU's real body *)
Lemma dm_gac : (prog_defmap GN.prog) ! SO._geo_add_child = Some (Gfun (Internal GN.f_geo_add_child)).
Proof. vm_compute. reflexivity. Qed.
Lemma dm_grc : (prog_defmap GN.prog) ! SO._geo_remove_child = Some (Gfun (Internal GN.f_geo_remove_child)).
Proof. vm_compute. reflexivity. Qed.
Lemma dm_goi : (prog_defmap GN.prog) ! OH._geo_obj_init = Some (Gfun (Internal GN.f_geo_obj_init)).
Proof. vm_compute. reflexivity. Qed.
Lemma dm_dealloc : (prog_defmap SO.prog) ! SO._deallocate_object = Some (Gfun (Internal SO.f_deallocate_object)).
Proof. vm_compute. reflexivity. Qed.
Lemma dm_snap : (prog_defmap SO.prog) ! SO._snap_object_to_floor = Some (Gfun (Internal SO.f_snap_object_to_floor)).
Proof. vm_compute. reflexivity. Qed.
Lemma dm_tao : (prog_defmap SO.prog) ! SO._try_allocate_object = Some (Gfun (Internal SO.f_try_allocate_object)).
Proof. vm_compute. reflexivity. Qed.
Lemma dm_unload : (prog_defmap SO.prog) ! SO._unload_object = Some (Gfun (Internal SO.f_unload_object)).
Proof. vm_compute. reflexivity. Qed.
Lemma dm_alloc : (prog_defmap SO.prog) ! SO._allocate_object = Some (Gfun (Internal SO.f_allocate_object)).
Proof. vm_compute. reflexivity. Qed.
Lemma dm_create : (prog_defmap SO.prog) ! OH._create_object = Some (Gfun (Internal SO.f_create_object)).
Proof. vm_compute. reflexivity. Qed.
Lemma dm_fuo : (prog_defmap OH.prog) ! SO._find_unimportant_object = Some (Gfun (Internal OH.f_find_unimportant_object)).
Proof. vm_compute. reflexivity. Qed.
Lemma dm_ocp : (prog_defmap OH.prog) ! OH._obj_copy_pos = Some (Gfun (Internal OH.f_obj_copy_pos)).
Proof. vm_compute. reflexivity. Qed.
Lemma dm_oca : (prog_defmap OH.prog) ! OH._obj_copy_angle = Some (Gfun (Internal OH.f_obj_copy_angle)).
Proof. vm_compute. reflexivity. Qed.
Lemma dm_ocpa : (prog_defmap OH.prog) ! OH._obj_copy_pos_and_angle = Some (Gfun (Internal OH.f_obj_copy_pos_and_angle)).
Proof. vm_compute. reflexivity. Qed.
Lemma dm_osp : (prog_defmap OH.prog) ! OH._obj_set_pos = Some (Gfun (Internal OH.f_obj_set_pos)).
Proof. vm_compute. reflexivity. Qed.
Lemma dm_osa : (prog_defmap OH.prog) ! OH._obj_set_angle = Some (Gfun (Internal OH.f_obj_set_angle)).
Proof. vm_compute. reflexivity. Qed.
Lemma dm_soao : (prog_defmap OH.prog) ! OH._spawn_object_at_origin = Some (Gfun (Internal OH.f_spawn_object_at_origin)).
Proof. vm_compute. reflexivity. Qed.
Lemma dm_spawn : (prog_defmap OH.prog) ! OH._spawn_object = Some (Gfun (Internal OH.f_spawn_object)).
Proof. vm_compute. reflexivity. Qed.
Lemma dm_soawr : (prog_defmap OH.prog) ! OH._spawn_object_abs_with_rot = Some (Gfun (Internal OH.f_spawn_object_abs_with_rot)).
Proof. vm_compute. reflexivity. Qed.
Lemma dm_mid : (prog_defmap MU.prog) ! SO._mtxf_identity = Some (Gfun (Internal MU.f_mtxf_identity)).
Proof. vm_compute. reflexivity. Qed.

(* ---------------------------------------------------------------------- *)
(* 7. The SafeB world, at the concrete MWF_real.                            *)
(* ---------------------------------------------------------------------- *)

Section SB.
  Variable lp : Clight.program.
  Hypothesis H12 : linked12 lp.
  Variables bm bc : block.
  Variable oc0 : ptrofs.
  Variable SafeB : block -> Prop.
  Hypothesis HSafeB_syms : SafeB_syms_ok lp SafeB.
  Hypothesis Hspawn : exists init, spawn_ok lp init bm bc oc0.
  Hypothesis Hsss : sss_inert.

  (* the spawn globals are SafeB symbols: SafeB_syms_ok (c), since
     CensusV2.spawn_safe_syms (= sb_gs) is part of safe_ptr_syms *)
  Lemma sb_gs_sub : forall x, mem_id x sb_gs = true -> mem_id x safe_ptr_syms = true.
  Proof.
    intros x H. unfold sb_gs in H. cbn [mem_id existsb] in H.
    repeat (apply orb_true_iff in H as [E | H];
            [ apply Pos.eqb_eq in E; subst x; vm_compute; reflexivity | ]).
    discriminate H.
  Qed.
  Lemma Hgs : forall x b, mem_id x sb_gs = true ->
      Genv.find_symbol (lp_ge lp) x = Some b -> SafeB b.
  Proof.
    intros x b Hx Hs. destruct HSafeB_syms as (_ & _ & Hc).
    exact (Hc x b (sb_gs_sub x Hx) Hs).
  Qed.

  Let ge := lp_ge lp.
  Let MWF := MWF_real lp bm bc oc0 SafeB.
  Let OF := ow_facts bm MWF.

  Lemma sb_Hbc_bm : bc <> bm.
  Proof. destruct Hspawn as (init & Hs). exact (spawn_Hbc_bm lp init bm bc oc0 Hs). Qed.
  Lemma sb_Hbc_sym : exists gid, Genv.find_symbol (lp_ge lp) gid = Some bc.
  Proof. destruct Hspawn as (init & Hs). exact (spawn_Hbc_sym lp init bm bc oc0 Hs). Qed.
  Lemma sb_not_bm : forall b, SafeB b -> b <> bm.
  Proof. destruct Hspawn as (init & Hs). exact (safeb_not_bm lp init bm bc oc0 SafeB Hs HSafeB_syms). Qed.
  Lemma sb_not_bc : ~ SafeB bc.
  Proof. destruct Hspawn as (init & Hs). exact (safeb_not_bc lp init bm bc oc0 SafeB Hs HSafeB_syms). Qed.
  Lemma sb_gms : forall gb,
      Genv.find_symbol (lp_ge lp) mario._gMarioState = Some gb ->
      gb <> bm /\ gb <> bc /\ ~ SafeB gb.
  Proof. destruct Hspawn as (init & Hs). exact (gms_blk lp init bm bc oc0 SafeB Hs HSafeB_syms). Qed.
  Lemma sb_glob : forall gid bg,
      mem_id gid stored_globals = true ->
      Genv.find_symbol (lp_ge lp) gid = Some bg ->
      bg <> bm /\ bg <> bc /\ ~ SafeB bg.
  Proof. destruct Hspawn as (init & Hs). exact (glob_blk lp init bm bc oc0 SafeB Hs HSafeB_syms). Qed.
  Lemma sb_gtimer : forall gb,
      Genv.find_symbol (lp_ge lp) interaction._gGlobalTimer = Some gb ->
      gb <> bm /\ gb <> bc /\ ~ SafeB gb.
  Proof. destruct Hspawn as (init & Hs). exact (gtimer_blk lp init bm bc oc0 SafeB Hs HSafeB_syms). Qed.
  Lemma sb_table : forall tb,
      Genv.find_symbol (lp_ge lp) interaction._sInteractionHandlers = Some tb ->
      tb <> bm /\ tb <> bc /\ ~ SafeB tb.
  Proof. destruct Hspawn as (init & Hs). exact (table_blk lp init bm bc oc0 SafeB Hs HSafeB_syms). Qed.
  Lemma sb_ktab : forall gid kb,
      mem_id gid knockback_table_ids = true ->
      Genv.find_symbol (lp_ge lp) gid = Some kb ->
      kb <> bm /\ kb <> bc /\ ~ SafeB kb.
  Proof. destruct Hspawn as (init & Hs). exact (ktab_blk lp init bm bc oc0 SafeB Hs HSafeB_syms). Qed.

  (* a SafeB-if-pointer store into a SafeB block keeps the carried facts *)
  Lemma sb_safe_store : forall b ch z v m1 m2,
      SafeB b -> safev SafeB v ->
      Mem.store ch m1 b z v = Some m2 -> OF m1 -> OF m2.
  Proof.
    intros b ch z v m1 m2 Hs Hv Hst (Hvb & Hsat & HM).
    split; [ eauto using Mem.store_valid_block_1 | split ].
    - eapply action_sat_unchanged_on with (m := m1); [ | exact Hvb | exact Hsat ].
      eapply Mem.store_unchanged_on; [ exact Hst | ].
      intros i _ [Hb _]. exact (sb_not_bm b Hs Hb).
    - exact (mwf_real_chase_ptr lp bm bc oc0 SafeB sb_Hbc_bm sb_not_bm sb_not_bc sb_gms
               sb_gtimer sb_table sb_ktab _ _ _ _ _ _ HM Hs Hv Hst).
  Qed.

  Lemma sb_chase_np : forall mm ch bsafe (d : Z) vv mm',
      MWF mm -> SafeB bsafe -> (forall bb oo, vv <> Vptr bb oo) ->
      Mem.store ch mm bsafe d vv = Some mm' -> MWF mm'.
  Proof.
    exact (mwf_real_chase lp bm bc oc0 SafeB sb_Hbc_bm sb_not_bm sb_not_bc sb_gms
             sb_gtimer sb_table sb_ktab).
  Qed.

  (* a stack local: wholly store-safe *)
  Lemma sb_local_pres : forall b, local_blk lp bm SafeB b ->
      blk_pres not_tainted bm MWF b.
  Proof.
    intros b Hl.
    apply (blk_pres_local bm MWF (local_blk lp bm SafeB)).
    - intros b0 (Hb0 & _). exact Hb0.
    - intros m ch b0 d v m' (Hb0 & HnS & Hgl) Hst HM0.
      destruct sb_Hbc_sym as (gid & Hsy).
      eapply mwf_real_local_store; eauto using sb_Hbc_bm.
    - exact Hl.
  Qed.

  (* a change confined to blocks the memory did not have keeps the facts *)
  Lemma sb_unch : forall m m',
      OF m -> Mem.unchanged_on (fun b _ => Mem.valid_block m b) m m' -> OF m'.
  Proof.
    intros m m' (Vb & AS & M) UO.
    pose proof M as ((Vbm & Vbc & Vgms & Vsafe & Vgt & Vtb & Vkt & _) & _).
    assert (Lsame : forall ch b z, Mem.valid_block m b ->
              Mem.load ch m' b z = Mem.load ch m b z).
    { intros ch b z Hv. eapply Mem.load_unchanged_on_1; [ exact UO | exact Hv | ].
      intros; exact Hv. }
    split; [ eapply Mem.valid_block_unchanged_on; eauto | split ].
    - eapply action_sat_unchanged_on; [ | exact Vb | exact AS ].
      eapply Mem.unchanged_on_implies; [ exact UO | ].
      intros b z _ Hv. exact Hv.
    - apply (MWF_real_transfer lp bm bc oc0 SafeB sb_Hbc_bm m m'); [ | | | | exact M ].
      + intros b Hv. eapply Mem.valid_block_unchanged_on; eauto.
      + intros v Hld. pose proof M as (_ & R1 & _). apply R1.
        rewrite <- Hld. symmetry. exact (Lsame _ _ _ Vbm).
      + intros ch b ofs v Hrow Hld. rewrite <- Hld. symmetry.
        destruct Hrow as [ [Eb _] | [ Eb | [ F | [ F | [ F | [ (gid & Hg & F) | F ] ] ] ] ] ].
        * subst b. exact (Lsame _ _ _ Vbm).
        * subst b. exact (Lsame _ _ _ Vbc).
        * exact (Lsame _ _ _ (Vgms _ F)).
        * exact (Lsame _ _ _ (Vgt _ F)).
        * exact (Lsame _ _ _ (Vtb _ F)).
        * exact (Lsame _ _ _ (Vkt _ _ Hg F)).
        * exact (Lsame _ _ _ (proj2 (proj2 (proj2 (mwf_real_anim_blk lp bm bc oc0 SafeB m b M F))))).
      + intros b ofs b' o' Hs Hld.
        pose proof M as (_ & _ & _ & _ & _ & _ & _ & R7 & _).
        apply (R7 b ofs b' o' Hs). cbn in Hld |- *.
        rewrite <- Hld. symmetry. exact (Lsame _ _ _ (Vsafe _ Hs)).
  Qed.

  Lemma sb_R7 : forall m, MWF m -> forall b ofs b' o', SafeB b ->
      Mem.loadv Mint32 m (Vptr b ofs) = Some (Vptr b' o') -> SafeB b'.
  Proof.
    intros m HM b ofs b' o' Hs Hld.
    exact (mwf_real_chase_step lp bm bc oc0 SafeB m b ofs b' o' HM Hs Hld).
  Qed.

  (* ---- the per-function spec ---- *)
  Definition sfun (fd : Clight.fundef) : Prop :=
    forall m vargs t m' vres,
      eval_funcall function_entry2 ge m fd vargs t m' vres ->
      Forall (safev SafeB) vargs -> OF m -> OF m' /\ safev SafeB vres.

  Definition sres (fid : ident) : Prop :=
    forall b fd, Genv.find_symbol ge fid = Some b ->
      Genv.find_funct ge (Vptr b Ptrofs.zero) = Some fd -> sfun fd.

  Lemma sres_of : forall q fid f,
      linkorder q lp -> (prog_defmap q) ! fid = Some (Gfun (Internal f)) ->
      sfun (Internal f) -> sres fid.
  Proof.
    intros q fid f LO Hdm Hs b fd Hsy Hff.
    destruct (linkorder_resolves_funct lp _ _ _ LO Hdm) as (b' & Hs' & Hff').
    unfold ge, lp_ge in Hsy, Hff. rewrite Hsy in Hs'. injection Hs' as <-.
    rewrite Hff' in Hff. injection Hff as <-. exact Hs.
  Qed.

  Definition TP (le : temp_env) : Prop := forall t v, le ! t = Some v -> safev SafeB v.

  (* the frame's env: its names are the locals, each a fresh local block *)
  Definition EI (lv : list ident) (e : env) : Prop :=
    (forall x b ty, e ! x = Some (b, ty) -> mem_id x lv = true /\ local_blk lp bm SafeB b)
    /\ (forall x, mem_id x lv = true -> exists b ty, e ! x = Some (b, ty)).

  Lemma EI_none : forall lv e x, EI lv e -> mem_id x lv = false -> e ! x = None.
  Proof.
    intros lv e x (H1 & _) Hx. destruct (e ! x) as [[b ty]|] eqn:E; [ | reflexivity ].
    destruct (H1 _ _ _ E) as (Hm & _). congruence.
  Qed.

  Section Fn.
    Variable lv : list ident.
    Variable vt : list ident.
    Variable e : env.
    Hypothesis HEI : EI lv e.
    Hypothesis Hvt : forall fid, mem_id fid vt = true -> sres fid.

    Lemma sb_set : forall id a le m v,
        s_set lv sb_gs id a = true -> TP le -> OF m ->
        eval_expr ge e le m a v -> TP (PTree.set id v le).
    Proof.
      intros id a le m v Hok HP (_ & _ & HM) Hev t v' Hg.
      destruct (peq t id) as [-> | Hne].
      - rewrite PTree.gss in Hg. injection Hg as <-.
        exact (sx_sound ge e le m SafeB lv sb_gs HP
                 (fun x b ty Hx => proj1 (proj1 HEI x b ty Hx)) Hgs (sb_R7 m HM)
                 a v Hev Hok).
      - rewrite PTree.gso in Hg by exact Hne. exact (HP _ _ Hg).
    Qed.

    Lemma sb_store : forall l r le m t le' m' out,
        s_store lv sb_gs l r = true -> TP le ->
        exec_stmt function_entry2 ge e le m (Sassign l r) t le' m' out ->
        OF m -> OF m'.
    Proof.
      intros l r le m t le' m' out Hok HP Hx Hf.
      unfold s_store in Hok. apply andb_prop in Hok as [Hok Hr].
      apply andb_prop in Hok as [Hl Hbv].
      pose proof Hf as (_ & _ & HM).
      assert (He : forall x b ty, e ! x = Some (b, ty) -> mem_id x lv = true)
        by (intros x b ty Hxx; exact (proj1 (proj1 HEI x b ty Hxx))).
      inv Hx.
      lazymatch goal with Hlv : eval_lvalue _ _ _ _ _ ?loc _ _ |- _ =>
        pose proof (slv_sound ge e _ m SafeB lv sb_gs HP He Hgs (sb_R7 m HM) _ _ _ _ Hlv Hl)
          as Hsb end.
      match goal with Hre : eval_expr _ _ _ _ r ?v2, Hc : sem_cast ?v2 _ _ _ = Some ?vv |- _ =>
        assert (Hsv : safev SafeB vv)
          by (intros bb oo Ev; subst vv;
              exact (sx_sound ge e _ m SafeB lv sb_gs HP He Hgs (sb_R7 m HM) _ _ Hre Hr _ _
                       (sem_cast_vptr_inv _ _ _ _ _ _ Hc))) end.
      match goal with Ha : assign_loc _ _ _ _ _ _ _ _ |- _ => inv Ha end.
      - match goal with Hst : Mem.storev _ _ _ _ = Some _ |- _ =>
          unfold Mem.storev in Hst; exact (sb_safe_store _ _ _ _ _ _ Hsb Hsv Hst Hf) end.
      - unfold MtxfBody.is_byval in Hbv.
        match goal with Hc : access_mode _ = By_copy |- _ => rewrite Hc in Hbv; discriminate Hbv end.
      - match goal with Hb : store_bitfield _ _ _ _ _ _ _ _ _ _ |- _ => inv Hb end.
        match goal with Hst : Mem.storev _ _ _ _ = Some _ |- _ =>
          unfold Mem.storev in Hst;
          refine (sb_safe_store _ _ _ _ _ _ Hsb _ Hst Hf); intros bb oo E; discriminate E end.
    Qed.

    Lemma sb_ret : forall a le m v,
        s_ret lv sb_gs a = true -> TP le -> OF m ->
        eval_expr ge e le m a v -> safev SafeB v.
    Proof.
      intros a le m v Hok HP (_ & _ & HM) Hev.
      exact (sx_sound ge e le m SafeB lv sb_gs HP
               (fun x b ty Hx => proj1 (proj1 HEI x b ty Hx)) Hgs (sb_R7 m HM)
               a v Hev Hok).
    Qed.

    Lemma sb_call : forall optid a al le m t le' m' out,
        s_call lv sb_gs vt optid a al = true -> TP le ->
        exec_stmt function_entry2 ge e le m (Scall optid a al) t le' m' out ->
        OF m -> OF m' /\ TP le'.
    Proof.
      intros optid a al le m t le' m' out Hok HP Hx Hf.
      pose proof Hf as (Hv & Hs & HM).
      assert (He : forall x b ty, e ! x = Some (b, ty) -> mem_id x lv = true)
        by (intros x b ty Hxx; exact (proj1 (proj1 HEI x b ty Hxx))).
      destruct a as [ | | | | fid fty | | | | | | | | | ]; try discriminate Hok.
      destruct fty as [ | | | | | | targs tres tcc | | ]; try discriminate Hok.
      cbn [s_call] in Hok. apply andb_prop in Hok as [Hnl Hok]. apply negb_true_iff in Hnl.
      inv Hx.
      match goal with Hcf : classify_fun _ = fun_case_f _ _ _ |- _ =>
        cbn in Hcf; injection Hcf as <- <- <- end.
      match goal with Hee : eval_expr _ _ _ _ (Evar _ _) ?vf |- _ =>
        destruct (evar_fun_val _ _ _ _ _ _ _ _ _ Hee (EI_none lv e fid HEI Hnl))
          as (lf & Hsy & ->) end.
      rename vres into vr.
      assert (Htp : forall vv, safev SafeB vv -> TP (set_opttemp optid vv le)).
      { intros vv Hvv t0 v0 Hg. destruct optid as [ti|]; cbn [set_opttemp] in Hg;
          [ | exact (HP _ _ Hg) ].
        destruct (peq t0 ti) as [-> | Hne].
        - rewrite PTree.gss in Hg. injection Hg as <-. exact Hvv.
        - rewrite PTree.gso in Hg by exact Hne. exact (HP _ _ Hg). }
      apply orb_true_iff in Hok as [Hok | Hsss_].
      apply orb_true_iff in Hok as [Hok | Hffc].
      apply orb_true_iff in Hok as [Hvtc | Hvec].
      - (* a callee already proved *)
        apply andb_prop in Hvtc as [Hm Hal].
        match goal with Hff : Genv.find_funct _ _ = Some ?fd,
                        Hfc : eval_funcall _ _ _ ?fd _ _ _ _,
                        Hel : eval_exprlist _ _ _ _ _ _ _ |- _ =>
          destruct (Hvt fid Hm lf fd Hsy Hff _ _ _ _ _ Hfc
                      (sx_list ge e le m SafeB lv sb_gs HP He Hgs (sb_R7 m HM) _ _ _ Hel Hal)
                      Hf) as (Hf' & Hr) end.
        exact (conj Hf' (Htp _ Hr)).
      - (* vec3f_set / vec3f_copy / vec3s_copy into an array field of a SafeB object *)
        apply andb_prop in Hvec as [Hm Hvok].
        unfold vec_ok in Hvok.
        destruct optid as [ti|]; [ discriminate Hvok | ].
        destruct al as [| a0 al']; [ discriminate Hvok | ].
        destruct targs as [| t0 targs']; [ discriminate Hvok | ].
        apply andb_prop in Hvok as [Harr Hpt].
        destruct a0 as [ | | | | | | | | | | | a1 fld fty0 | | ]; try discriminate Harr.
        destruct fty0 as [ | | | | | aty an aat | | | ]; try discriminate Harr.
        cbn [arr_arg] in Harr.
        match goal with Hel : eval_exprlist _ _ _ _ _ _ _ |- _ => inv Hel end.
        match goal with H0 : eval_expr _ _ _ _ (Efield _ _ _) ?v1 |- _ =>
          destruct (arr_field_val _ _ _ _ _ _ _ _ _ _ H0) as (l & o & bf & Hlv & ->) end.
        pose proof (slv_sound ge e le m SafeB lv sb_gs HP He Hgs (sb_R7 m HM) _ _ _ _ Hlv Harr)
          as Hsl.
        match goal with Hc : sem_cast (Vptr l o) _ _ _ = Some ?v2 |- _ =>
          pose proof (cast_vptr_ptr _ _ _ _ _ _ Hc Hpt) as -> end.
        pose proof (mwf_real_safe_valid lp bm bc oc0 SafeB m HM l Hsl) as Hvl.
        pose proof (sb_frame_oracles lp bm bc oc0 SafeB sb_Hbc_bm) as Hor.
        split; [ | exact HP ].
        match goal with Hff : Genv.find_funct _ _ = Some _ |- _ =>
          rewrite Genv.find_funct_find_funct_ptr in Hff end.
        unfold vec_ids in Hm. cbn [mem_id existsb] in Hm.
        apply orb_true_iff in Hm as [Hm | Hm]; [ | apply orb_true_iff in Hm as [Hm | Hm];
          [ | apply orb_true_iff in Hm as [Hm | Hm]; [ | discriminate Hm ] ] ];
          apply Pos.eqb_eq in Hm; subst fid.
        + match goal with Hfp : Genv.find_funct_ptr _ _ = Some ?fd,
                          Hfc : eval_funcall _ _ _ ?fd _ _ _ _ |- _ =>
            rewrite (math_resolves lp (linked12_LO_math lp H12) _ _ MtxfBody.mu_dm_v3fset
                       _ _ Hsy Hfp) in Hfc;
            exact (vec3f_set_body_frame_B (lp_ge lp) MWF bm l o Hor _ _ _ _ _ Hfc eq_refl
                     (vec_out_safeb bm MWF SafeB sb_not_bm sb_chase_np Mfloat32 l o Hsl)
                     Hvl Hv Hs HM) end.
        + match goal with Hfp : Genv.find_funct_ptr _ _ = Some ?fd,
                          Hfc : eval_funcall _ _ _ ?fd _ _ _ _ |- _ =>
            rewrite (math_resolves lp (linked12_LO_math lp H12) _ _ mu_dm_v3fcopy
                       _ _ Hsy Hfp) in Hfc;
            exact (vec3f_copy_body_frame_B (lp_ge lp) MWF bm l o Hor _ _ _ _ _ Hfc eq_refl
                     (vec_out_safeb bm MWF SafeB sb_not_bm sb_chase_np Mfloat32 l o Hsl)
                     Hvl Hv Hs HM) end.
        + match goal with Hfp : Genv.find_funct_ptr _ _ = Some ?fd,
                          Hfc : eval_funcall _ _ _ ?fd _ _ _ _ |- _ =>
            rewrite (math_resolves lp (linked12_LO_math lp H12) _ _ mu_dm_v3scopy
                       _ _ Hsy Hfp) in Hfc;
            exact (vec3s_copy_body_frame_B (lp_ge lp) MWF bm l o Hor _ _ _ _ _ Hfc eq_refl
                     (vec_out_safeb bm MWF SafeB sb_not_bm sb_chase_np Mint16signed l o Hsl)
                     Hvl Hv Hs HM) end.
      - (* find_floor(x, y, z, &local) *)
        apply andb_prop in Hffc as [Hfid Hfo]. apply Pos.eqb_eq in Hfid. subst fid.
        unfold ff_ok in Hfo.
        destruct (nth_error al 3) as [a3|] eqn:Ha3; [ | discriminate Hfo ].
        destruct a3 as [ | | | | | | | a3' aty | | | | | | ]; try discriminate Hfo.
        destruct a3' as [ | | | | x xty | | | | | | | | | ]; try discriminate Hfo.
        destruct (nth_error targs 3) as [t3|] eqn:Ht3; [ | discriminate Hfo ].
        apply andb_prop in Hfo as [Hxl Hpt].
        destruct (proj2 HEI x Hxl) as (bx & tx & Hex).
        pose proof (proj2 (proj1 HEI x bx tx Hex)) as Hloc.
        match goal with Hel : eval_exprlist _ _ _ _ _ _ _ |- _ =>
          destruct (exprlist_nth _ _ _ _ _ _ _ Hel 3 _ _ Ha3 Ht3) as (v1 & v2 & Hx1 & Hc1 & Hn3) end.
        assert (Ev1 : v1 = Vptr bx Ptrofs.zero).
        { inv Hx1;
            [ | match goal with Hl : eval_lvalue _ _ _ _ (Eaddrof _ _) _ _ _ |- _ => inv Hl end ].
          match goal with Hl : eval_lvalue _ _ _ _ (Evar _ _) _ _ _ |- _ => inv Hl end;
            congruence. }
        subst v1.
        rewrite (cast_vptr_ptr _ _ _ _ _ _ Hc1 Hpt) in Hn3.
        pose proof (sb_local_pres bx Hloc) as Hbp.
        pose proof (sb_frame_oracles lp bm bc oc0 SafeB sb_Hbc_bm) as Hor.
        match goal with Hff : Genv.find_funct _ _ = Some _ |- _ =>
          rewrite Genv.find_funct_find_funct_ptr in Hff end.
        match goal with Hfp : Genv.find_funct_ptr _ _ = Some ?fd,
                        Hfc : eval_funcall _ _ _ ?fd _ _ _ _ |- _ =>
          rewrite (sb_resolves lp (linked12_LO_surf lp H12) _ _ MtxfBody.surf_dm_ff2 _ _ Hsy Hfp)
            in Hfc;
          pose proof (funcall_float_ret _ _ _ _ _ _ _ Hfc eq_refl) as Hnp;
          destruct (find_floor_body_frame_pinned (lp_ge lp) MWF bm bx Ptrofs.zero Hor
                      (sb_statics lp bm bc oc0 SafeB sb_Hbc_bm sb_glob)
                      (sb_resolves lp (linked12_LO_surf lp H12) _ _ surf_dm_ffl)
                      _ _ _ _ _ Hfc Hn3 (fun ch _ => Hbp ch _) Hv Hs HM) as (Hv' & Hs' & HM')
        end.
        split; [ exact (conj Hv' (conj Hs' HM')) | ].
        apply Htp. intros bb oo Ev. exfalso. exact (Hnp bb oo Ev).
      - (* stop_sounds_from_source: the labeled audio premise *)
        apply Pos.eqb_eq in Hsss_. subst fid.
        match goal with Hff : Genv.find_funct _ _ = Some ?fd |- _ =>
          destruct (sss_resolve lp lf fd H12 Hsy Hff) as (sg & targs' & tres' & cc' & ->) end.
        match goal with Hfc : eval_funcall _ _ _ (External _ _ _ _) _ _ _ _ |- _ => inv Hfc end.
        match goal with Hec : external_call _ _ _ _ _ _ _ |- _ =>
          destruct (Hsss _ _ _ _ _ _ _ Hec) as (UO & NP) end.
        split; [ exact (sb_unch _ _ Hf UO) | ].
        apply Htp. intros bb oo Ev. exfalso. exact (NP bb oo Ev).
    Qed.
  End Fn.

  (* the entry: params hold the (safe) arguments, the other temps Vundef *)
  Lemma bind_tp : forall ps temps vargs le,
      bind_parameter_temps ps vargs (create_undef_temps temps) = Some le ->
      Forall (safev SafeB) vargs -> TP le.
  Proof.
    intros ps temps vargs le Hb Hva t v Hg.
    destruct (ObjHelpersBodies.bind_get _ _ _ _ _ _ Hb Hg) as [Hu | (i & _ & Hv)].
    - apply MtxfBody.create_undef_temps_get in Hu. subst v. intros bb oo E; discriminate E.
    - rewrite Forall_forall in Hva. exact (Hva v (nth_error_In _ _ Hv)).
  Qed.

  (* THE BODY LEMMA: a body the recognizer accepts, whose proved-callee
     table holds, is in the SafeB world *)
  Lemma body_sfun : forall f vt,
      sb_chk sb_gs vt f = true ->
      (forall fid, mem_id fid vt = true -> sres fid) ->
      sfun (Internal f).
  Proof.
    intros f vt Hchk Hvt m vargs t m' vres Hevf Hva Hf.
    pose proof Hf as (Hv & Hs & HM).
    inv Hevf.
    match goal with He : function_entry2 _ _ _ _ _ _ _ |- _ => inv He end.
    match goal with Ha : alloc_variables _ _ _ _ _ _ |- _ => rename Ha into Hav end.
    match goal with Hb : bind_parameter_temps _ _ _ = Some _ |- _ => rename Hb into Hbp end.
    match goal with Hfl : Mem.free_list _ _ = Some _ |- _ => rename Hfl into Hfree end.
    match goal with Ho : outcome_result_value _ _ _ _ |- _ => rename Ho into Hor end.
    set (lv := map fst (fn_vars f)) in *.
    pose proof (MtxfBody.av_facts bm MWF _ _ _ _ _ _ (mwf_real_alloc lp bm bc oc0 SafeB sb_Hbc_bm) Hav Hf)
      as Hf1.
    assert (HGv : forall gid bg, Genv.find_symbol (lp_ge lp) gid = Some bg -> Mem.valid_block m bg)
      by (apply glob_valid_of_nextbound; exact (mwf_real_nextbound lp bm bc oc0 SafeB m HM)).
    assert (HEI : EI lv e).
    { split.
      - intros x b ty Hx. split.
        + destruct (mem_id x lv) eqn:E; [ reflexivity | exfalso ].
          rewrite (alloc_variables_unbound _ _ _ _ _ _ Hav x (MtxfBody.mem_id_notin _ _ E)) in Hx.
          rewrite PTree.gempty in Hx. discriminate Hx.
        + exact (alloc_variables_local_blk lp bm SafeB _ _ _ _ Hav Hv
                   (mwf_real_safe_valid lp bm bc oc0 SafeB m HM) HGv x b ty Hx).
      - intros x Hx. exact (alloc_variables_in_bound _ _ _ _ _ _ Hav x (MtxfBody.mem_id_In _ _ Hx)). }
    pose proof (bind_tp _ _ _ _ Hbp Hva) as HP1.
    lazymatch goal with Hb : exec_stmt _ _ ?E ?LE ?M1 _ _ _ ?M2 _ |- _ =>
      destruct (sw_walk ge E OF TP (safev SafeB) (s_set lv sb_gs) (s_store lv sb_gs)
                  (s_call lv sb_gs vt) (s_ret lv sb_gs)
                  ltac:(intros ? ? ? ? ? J1 J2 J3 J4; eapply sb_set; eassumption)
                  ltac:(intros ? ? ? ? ? ? ? ? J1 J2 J3 J4; eapply sb_store; eassumption)
                  ltac:(intros ? ? ? ? ? ? ? ? ? J1 J2 J3 J4; eapply sb_call; eassumption)
                  ltac:(intros ? ? ? ? J1 J2 J3 J4; eapply sb_ret; eassumption)
                  _ _ _ _ _ _ _ _ Hb eq_refl Hchk HP1 Hf1) as ((Hv2 & Hs2 & HM2) & _ & Hout)
    end.
    assert (Hfa : Forall (fun blh => let '(b,_,_) := blh in b <> bm)
                    (blocks_of_env (lp_ge lp) e)).
    { eapply Forall_impl; [ | exact (blocks_of_env_bm lp bm _ _ _ _ Hav Hv) ].
      intros [[b lo] hi] Hq. exact Hq. }
    destruct (vfc_free_list_frame not_tainted bm _ _ _ Hfa Hfree Hv2 Hs2) as (Hvf & Hsf).
    split; [ exact (conj Hvf (conj Hsf (mwf_real_free lp bm bc oc0 SafeB sb_Hbc_bm _ _ _ Hfree HM2))) | ].
    intros bb oo Ev. subst vres.
    destruct out as [ | | | [[v' t']|] ]; cbn in Hor.
    - contradiction Hor.
    - contradiction Hor.
    - destruct (fn_return f); try contradiction Hor; discriminate Hor.
    - destruct Hor as (_ & Hc). exact (Hout _ _ (sem_cast_vptr_inv _ _ _ _ _ _ Hc)).
    - destruct (fn_return f); try contradiction Hor; discriminate Hor.
  Qed.

  (* ---- the tree, bottom-up ---- *)
  Lemma vt_of : forall l, Forall sres l -> forall fid, mem_id fid l = true -> sres fid.
  Proof.
    intros l Hl fid Hm. rewrite Forall_forall in Hl. exact (Hl _ (MtxfBody.mem_id_In _ _ Hm)).
  Qed.
  Lemma vt0_ok : forall fid, mem_id fid vt0 = true -> sres fid.
  Proof. intros fid H. discriminate H. Qed.

  Let LO_so := linked12_LO_spawn_object lp H12.
  Let LO_oh := linked12_LO_object_helpers lp H12.
  Let LO_gn := linked12_LO_graph_node lp H12.
  Let LO_mu := linked12_LO_math lp H12.
  Let LO_mem := linked12_LO_memory lp H12.

  Lemma sr_s2v : sres OH._segmented_to_virtual.
  Proof. exact (sres_of _ _ _ LO_mem ObjHelpersBodies.mem_dm_s2v (body_sfun _ _ chk_s2v vt0_ok)). Qed.
  Lemma sr_gac : sres SO._geo_add_child.
  Proof. exact (sres_of _ _ _ LO_gn dm_gac (body_sfun _ _ chk_gac vt0_ok)). Qed.
  Lemma sr_grc : sres SO._geo_remove_child.
  Proof. exact (sres_of _ _ _ LO_gn dm_grc (body_sfun _ _ chk_grc vt0_ok)). Qed.
  Lemma sr_goi : sres OH._geo_obj_init.
  Proof. exact (sres_of _ _ _ LO_gn dm_goi (body_sfun _ _ chk_goi vt0_ok)). Qed.
  Lemma sr_dealloc : sres SO._deallocate_object.
  Proof. exact (sres_of _ _ _ LO_so dm_dealloc (body_sfun _ _ chk_dealloc vt0_ok)). Qed.
  Lemma sr_snap : sres SO._snap_object_to_floor.
  Proof. exact (sres_of _ _ _ LO_so dm_snap (body_sfun _ _ chk_snap vt0_ok)). Qed.
  Lemma sr_fuo : sres SO._find_unimportant_object.
  Proof. exact (sres_of _ _ _ LO_oh dm_fuo (body_sfun _ _ chk_fuo vt0_ok)). Qed.
  Lemma sr_ocp : sres OH._obj_copy_pos.
  Proof. exact (sres_of _ _ _ LO_oh dm_ocp (body_sfun _ _ chk_ocp vt0_ok)). Qed.
  Lemma sr_oca : sres OH._obj_copy_angle.
  Proof. exact (sres_of _ _ _ LO_oh dm_oca (body_sfun _ _ chk_oca vt0_ok)). Qed.
  Lemma sr_osp : sres OH._obj_set_pos.
  Proof. exact (sres_of _ _ _ LO_oh dm_osp (body_sfun _ _ chk_osp vt0_ok)). Qed.
  Lemma sr_osa : sres OH._obj_set_angle.
  Proof. exact (sres_of _ _ _ LO_oh dm_osa (body_sfun _ _ chk_osa vt0_ok)). Qed.
  Lemma sr_mid : sres SO._mtxf_identity.
  Proof. exact (sres_of _ _ _ LO_mu dm_mid (body_sfun _ _ chk_mid vt0_ok)). Qed.

  Lemma sr_ocpa : sres OH._obj_copy_pos_and_angle.
  Proof.
    exact (sres_of _ _ _ LO_oh dm_ocpa
             (body_sfun _ _ chk_ocpa
                (vt_of _ (Forall_cons _ sr_ocp (Forall_cons _ sr_oca (Forall_nil _)))))).
  Qed.
  Lemma sr_tao : sres SO._try_allocate_object.
  Proof.
    exact (sres_of _ _ _ LO_so dm_tao
             (body_sfun _ _ chk_tao
                (vt_of _ (Forall_cons _ sr_grc (Forall_cons _ sr_gac (Forall_nil _)))))).
  Qed.
  Lemma sr_unload : sres SO._unload_object.
  Proof.
    exact (sres_of _ _ _ LO_so dm_unload
             (body_sfun _ _ chk_unload
                (vt_of _ (Forall_cons _ sr_grc (Forall_cons _ sr_gac
                            (Forall_cons _ sr_dealloc (Forall_nil _))))))).
  Qed.
  (* allocate_object: the pool-exhausted `while (TRUE) {}` has no
     terminating execution, so it contributes no derivation *)
  Lemma sr_alloc : sres SO._allocate_object.
  Proof.
    exact (sres_of _ _ _ LO_so dm_alloc
             (body_sfun _ _ chk_alloc
                (vt_of _ (Forall_cons _ sr_tao (Forall_cons _ sr_fuo
                            (Forall_cons _ sr_unload (Forall_cons _ sr_mid (Forall_nil _)))))))).
  Qed.
  Lemma sr_create : sres OH._create_object.
  Proof.
    exact (sres_of _ _ _ LO_so dm_create
             (body_sfun _ _ chk_create
                (vt_of _ (Forall_cons _ sr_alloc (Forall_cons _ sr_snap (Forall_nil _)))))).
  Qed.
  Lemma sr_soao : sres OH._spawn_object_at_origin.
  Proof.
    exact (sres_of _ _ _ LO_oh dm_soao
             (body_sfun _ _ chk_soao
                (vt_of _ (Forall_cons _ sr_s2v (Forall_cons _ sr_create
                            (Forall_cons _ sr_goi (Forall_nil _))))))).
  Qed.
  Lemma sr_spawn : sres OH._spawn_object.
  Proof.
    exact (sres_of _ _ _ LO_oh dm_spawn
             (body_sfun _ _ chk_spawn
                (vt_of _ (Forall_cons _ sr_soao (Forall_cons _ sr_ocpa (Forall_nil _)))))).
  Qed.
  Lemma sr_soawr : sres OH._spawn_object_abs_with_rot.
  Proof.
    exact (sres_of _ _ _ LO_oh dm_soawr
             (body_sfun _ _ chk_soawr
                (vt_of _ (Forall_cons _ sr_soao (Forall_cons _ sr_osp
                            (Forall_cons _ sr_osa (Forall_nil _))))))).
  Qed.

  (* ---- the capstone-facing gated rows ---- *)
  Lemma sg_of_sres : forall fid NoA, sres fid ->
      WindSurface.call_pres_ext_sg lp bm NoA MWF SafeB fid.
  Proof.
    intros fid NoA Hs fd m0 vargs0 t0 m1 vres0 Hev (b & Hsy & Hff) Hargs _ HM HV HA.
    assert (Hargs' : Forall (safev SafeB) vargs0).
    { eapply Forall_impl; [ | exact Hargs ].
      intros v Hv bb oo Ev. destruct (Hv bb oo Ev) as [ Hsb | (g & Hg & Hgs') ];
        [ exact Hsb | ].
      destruct HSafeB_syms as (_ & _ & Hc).
      exact (Hc g bb (spawn_bhv_in_safe g Hg) Hgs'). }
    destruct (Hs b fd Hsy Hff m0 vargs0 t0 m1 vres0 Hev Hargs' (conj HV (conj HA HM)))
      as ((HV' & HA' & HM') & Hr).
    exact (conj HV' (conj HA' (conj HM' Hr))).
  Qed.

  Lemma Hcp_spawn_sg : forall NoA,
      WindSurface.call_pres_ext_sg lp bm NoA MWF SafeB OH._spawn_object.
  Proof. intros NoA. exact (sg_of_sres _ NoA sr_spawn). Qed.
  Lemma Hcp_soawr_sg : forall NoA,
      WindSurface.call_pres_ext_sg lp bm NoA MWF SafeB OH._spawn_object_abs_with_rot.
  Proof. intros NoA. exact (sg_of_sres _ NoA sr_soawr). Qed.

  (* the engine's cs class (ActWriterSurface.objw_ids): the cs_gate's
     spawn branch is the same all-argument gate *)
  Lemma cs_of_sres : forall fid NoA, (forall m, MWF m -> NoA m) ->
      mem_id fid spawn_fids = true ->
      Pos.eqb fid interaction._obj_set_held_state = false -> sres fid ->
      OutParamSurface.call_pres_ext_cs lp bm NoA MWF SafeB fid.
  Proof.
    intros fid NoA HN Hsp Hosh Hs fd m0 vargs0 t0 m1 vres0 Hev Hres (_ & Hg) _ HM HV HA.
    rewrite Hosh, Hsp in Hg.
    destruct (sg_of_sres fid (fun _ => True) Hs fd m0 vargs0 t0 m1 vres0 Hev Hres Hg I HM HV HA)
      as (HV' & HA' & HM' & _).
    exact (conj HV' (conj HA' (conj HM' (HN _ HM')))).
  Qed.
  Lemma Hcs_spawn : forall NoA, (forall m, MWF m -> NoA m) ->
      OutParamSurface.call_pres_ext_cs lp bm NoA MWF SafeB interaction._spawn_object.
  Proof.
    intros NoA HN. apply (cs_of_sres _ NoA HN); [ vm_compute; reflexivity
      | vm_compute; reflexivity | exact sr_spawn ].
  Qed.
  Lemma Hcs_soawr : forall NoA, (forall m, MWF m -> NoA m) ->
      OutParamSurface.call_pres_ext_cs lp bm NoA MWF SafeB
        mario_actions_cutscene._spawn_object_abs_with_rot.
  Proof.
    intros NoA HN. apply (cs_of_sres _ NoA HN); [ vm_compute; reflexivity
      | vm_compute; reflexivity | exact sr_soawr ].
  Qed.
End SB.

(* the per-TU spawn idents are the same positive (one symbol table) *)
Lemma spawn_ids_eq :
  behavior_actions._spawn_object = OH._spawn_object
  /\ interaction._spawn_object = OH._spawn_object
  /\ mario_actions_cutscene._spawn_object = OH._spawn_object
  /\ mario_actions_cutscene._spawn_object_abs_with_rot = OH._spawn_object_abs_with_rot.
Proof. vm_compute. auto. Qed.
