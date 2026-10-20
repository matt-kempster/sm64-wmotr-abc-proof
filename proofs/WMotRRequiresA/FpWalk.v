(* ====================================================================== *)
(* FpWalk (unwired, GOAL 2): write footprints of real function bodies.    *)
(*                                                                        *)
(* fp m m' : m' differs from m only inside a fixed list of cells of one  *)
(* struct (the block/offset a pointer parameter holds), with the same     *)
(* blocks and permissions.  fp_walk proves it for a body whose every     *)
(* store is "p->field" or "p->arr[k]" at an allowed cell (p the pointer   *)
(* parameter, never reassigned) and whose every call is answered by the   *)
(* caller (Hcall).  The bodies are the generated Clight; the cell list is *)
(* checked against them by vm_compute.                                    *)
(*                                                                        *)
(* Used for the act_freefall layer: update_air_without_turn writes only   *)
(* forwardVel, slideVelX/Z, vel[0], vel[2] (and slideYaw through          *)
(* check_horizontal_wind), so Phi's cells survive it.  Its sin/cos table  *)
(* reads at a computed index do not matter to a footprint.               *)
(* ====================================================================== *)

From Coq Require Import ZArith List Lia String.
From compcert Require Import Coqlib Errors Maps AST Integers Floats Values Memory Events
  Globalenvs Ctypes Cop Clight ClightBigstep Linking.
From SM64.Generated Require mario mario_actions_airborne math_util.
From SM64.Proofs Require Import MarioModel.LinkedTwelve WMotRRequiresA.FpuFloor
  MarioModel.MathGeomGated MarioModel.MathBodies MarioModel.RestSurface Interp.LinkGenv
  WMotRRequiresA.AirXc.
From SM64.Proofs Require MarioModel.CensusV2.
Import ListNotations.
Local Open Scope Z_scope.

(* ---------------------------------------------------------------------- *)
(* The relation                                                           *)
(* ---------------------------------------------------------------------- *)

Section FP.
Variable ge : genv.
Variable g : ident.
Variables (bm : block) (om : ptrofs).
Variable cells : list (Z * Z).   (* (offset from om, size) *)

Definition cbase (d : Z) : Z := Ptrofs.unsigned (Ptrofs.add om (Ptrofs.repr d)).

Definition incell (b : block) (z : Z) : Prop :=
  b = bm /\ exists d s, In (d, s) cells /\ cbase d <= z < cbase d + s.

Definition fp (m m' : mem) : Prop :=
  Mem.unchanged_on (fun b z => ~ incell b z) m m'
  /\ Mem.nextblock m' = Mem.nextblock m
  /\ (forall b z k p, Mem.perm m' b z k p <-> Mem.perm m b z k p).

Lemma fp_refl : forall m, fp m m.
Proof.
  intros m. split; [apply Mem.unchanged_on_refl | split; [reflexivity | tauto]].
Qed.

Lemma fp_trans : forall m1 m2 m3, fp m1 m2 -> fp m2 m3 -> fp m1 m3.
Proof.
  intros m1 m2 m3 (U1 & N1 & P1) (U2 & N2 & P2).
  split; [eapply Mem.unchanged_on_trans; eauto |].
  split; [congruence | intros b z k p; rewrite P2; apply P1].
Qed.

(* ---------------------------------------------------------------------- *)
(* The allowed stores                                                     *)
(* ---------------------------------------------------------------------- *)

(* p->f, p the parameter: the field's offset and type *)
Definition mfield (a : expr) : option (Z * type) :=
  match a with
  | Efield (Ederef (Etempvar x (Tpointer (Tstruct sid _) _)) (Tstruct sid' _)) f ty =>
      if Pos.eqb x g && Pos.eqb sid sid' then
        match (genv_cenv ge) ! sid with
        | Some co =>
            match field_offset ge f (co_members co) with
            | OK (d, Full) => Some (d, ty)
            | _ => None
            end
        | None => None
        end
      else None
  | _ => None
  end.

Definition bv_size (ty : type) : option Z :=
  match access_mode ty with By_value ch => Some (size_chunk ch) | _ => None end.

(* the cell an lvalue stores to: p->f, or p->arr[k] *)
Definition lv_cell (a : expr) : option (Z * Z) :=
  match a with
  | Efield _ _ ty =>
      match mfield a, bv_size ty with
      | Some (d, _), Some s => Some (d, s)
      | _, _ => None
      end
  | Ederef (Ebinop Oadd af (Econst_int k (Tint I32 Signed _)) _) ety =>
      match mfield af, bv_size ety with
      | Some (d, Tarray ety' _ _), Some s =>
          if type_eq ety ety' then Some (d + sizeof ge ety * Int.signed k, s) else None
      | _, _ => None
      end
  | _ => None
  end.

Definition cell_ok (c : Z * Z) : bool :=
  existsb (fun c' => Z.eqb (fst c) (fst c') && Z.eqb (snd c) (snd c')) cells.

Definition store_ok (lv : expr) : bool :=
  match lv_cell lv with Some c => cell_ok c | None => false end.

Lemma mfield_sound : forall e le m a d ty loc ofs bf,
  le ! g = Some (Vptr bm om) -> mfield a = Some (d, ty) ->
  eval_lvalue ge e le m a loc ofs bf ->
  loc = bm /\ ofs = Ptrofs.add om (Ptrofs.repr d) /\ bf = Full /\ typeof a = ty.
Proof.
  intros e le m a d ty loc ofs bf Hg Hm Hl.
  destruct a; try discriminate Hm.
  match type of Hm with mfield (Efield ?b ?f ?t) = _ => rename b into a0 end.
  destruct a0; try discriminate Hm.
  match type of Hm with mfield (Efield (Ederef ?b ?u) _ _) = _ => rename b into a1; rename u into ts end.
  destruct a1; try discriminate Hm.
  match type of Hm with mfield (Efield (Ederef (Etempvar ?x ?u) _) _ _) = _ => rename u into tp end.
  destruct tp; try discriminate Hm. destruct tp; try discriminate Hm.
  destruct ts; try discriminate Hm.
  cbn [mfield] in Hm.
  match type of Hm with (if ?c then _ else _) = _ => destruct c eqn:C; [| discriminate Hm] end.
  apply andb_true_iff in C as [C1 C2]. apply Pos.eqb_eq in C1, C2. subst.
  match type of Hm with match ?x with _ => _ end = _ => destruct x as [co |] eqn:Hco; [| discriminate Hm] end.
  match type of Hm with match ?x with _ => _ end = _ => destruct x as [[d0 [| ? ? ? ?]] |] eqn:Hfo; try discriminate Hm end.
  injection Hm as <- <-.
  inv Hl; [| match goal with H : typeof _ = Tunion _ _ |- _ => cbn in H; discriminate H end].
  match goal with H : typeof _ = Tstruct _ _ |- _ => cbn in H; injection H as <- _ end.
  match goal with H : eval_expr _ _ _ _ (Ederef _ _) _ |- _ => inv H end.
  match goal with H : eval_lvalue _ _ _ _ (Ederef _ _) _ _ _ |- _ => inv H end.
  match goal with H : eval_expr _ _ _ _ (Etempvar _ _) _ |- _ => inv H end;
    try (match goal with H : eval_lvalue _ _ _ _ (Etempvar _ _) _ _ _ |- _ => inv H end).
  match goal with H : deref_loc _ _ _ _ _ _ |- _ => inv H end;
    try (match goal with H : access_mode _ = _ |- _ => cbn in H; discriminate H end).
  rewrite Hg in *. match goal with H : Some _ = Some _ |- _ => injection H as <- <- end.
  rewrite Hco in *. match goal with H : Some _ = Some _ |- _ => injection H as <- end.
  rewrite Hfo in *. match goal with H : OK _ = OK _ |- _ => injection H as <- <- end.
  auto.
Qed.

Lemma ptrofs_index : forall o d sz k,
  Ptrofs.add (Ptrofs.add o (Ptrofs.repr d)) (Ptrofs.mul (Ptrofs.repr sz) (Ptrofs.of_ints k))
  = Ptrofs.add o (Ptrofs.repr (d + sz * Int.signed k)).
Proof.
  intros o d sz k. rewrite Ptrofs.add_assoc. f_equal.
  unfold Ptrofs.add, Ptrofs.mul, Ptrofs.of_ints. apply Ptrofs.eqm_samerepr.
  apply Ptrofs.eqm_add; [apply Ptrofs.eqm_sym, Ptrofs.eqm_unsigned_repr |].
  eapply Ptrofs.eqm_trans; [apply Ptrofs.eqm_sym, Ptrofs.eqm_unsigned_repr |].
  apply Ptrofs.eqm_mult; apply Ptrofs.eqm_sym, Ptrofs.eqm_unsigned_repr.
Qed.

Lemma lv_cell_sound : forall e le m lv loc ofs bf d s,
  le ! g = Some (Vptr bm om) -> lv_cell lv = Some (d, s) ->
  eval_lvalue ge e le m lv loc ofs bf ->
  loc = bm /\ ofs = Ptrofs.add om (Ptrofs.repr d) /\ bf = Full
  /\ exists ch, access_mode (typeof lv) = By_value ch /\ size_chunk ch = s.
Proof.
  intros e le m lv loc ofs bf d s Hg Hc Hl.
  destruct lv; try discriminate Hc.
  - (* p->arr[k] *)
    match type of Hc with lv_cell (Ederef ?b ?t) = _ => rename b into a0; rename t into ety end.
    destruct a0; try discriminate Hc. destruct b; try discriminate Hc.
    match type of Hc with lv_cell (Ederef (Ebinop _ ?x ?y _) _) = _ => rename x into af; rename y into ak end.
    destruct ak; try discriminate Hc.
    match type of Hc with lv_cell (Ederef (Ebinop _ _ (Econst_int ?kk ?tt) _) _) = _ =>
      rename kk into k; destruct tt as [| [| | |] [|] ? | | | | | | |]; try discriminate Hc end.
    cbn [lv_cell] in Hc.
    destruct (mfield af) as [[d0 [| | | | | ety' n att | | |]] |] eqn:Hm; try discriminate Hc.
    destruct (bv_size ety) as [s0 |] eqn:Hs; [| discriminate Hc].
    destruct (type_eq ety ety') as [<- |]; [| discriminate Hc].
    injection Hc as <- <-.
    inv Hl.
    match goal with H : eval_expr _ _ _ _ (Ebinop _ _ _ _) _ |- _ => inv H end;
      [| match goal with H : eval_lvalue _ _ _ _ (Ebinop _ _ _ _) _ _ _ |- _ => inv H end].
    match goal with H : eval_expr _ _ _ _ (Econst_int _ _) _ |- _ => inv H end;
      [| match goal with H : eval_lvalue _ _ _ _ (Econst_int _ _) _ _ _ |- _ => inv H end].
    assert (Hv1 : exists l1 o1 bf1, eval_lvalue ge e le m af l1 o1 bf1 /\
               deref_loc (typeof af) m l1 o1 bf1 v1).
    { match goal with H : eval_expr _ _ _ _ af v1 |- _ => inv H end;
        try (cbn [mfield] in Hm; discriminate Hm).
      all: eauto. }
    destruct Hv1 as (l1 & o1 & bf1 & Hl1 & Hd1).
    destruct (mfield_sound _ _ _ _ _ _ _ _ _ Hg Hm Hl1) as (-> & -> & -> & Hty).
    rewrite Hty in Hd1. inv Hd1; try (cbn in *; discriminate).
    match goal with H : sem_binary_operation _ _ _ _ _ _ _ = Some _ |- _ => rename H into Hsem end.
    rewrite Hty in Hsem. cbn in Hsem.
    injection Hsem as <- <-. rewrite ptrofs_index.
    split; [reflexivity | split; [reflexivity | split; [reflexivity |]]].
    unfold bv_size in Hs. cbn [typeof]. destruct (access_mode ety); try discriminate Hs.
    injection Hs as <-. eauto.
  - (* p->f *)
    cbn [lv_cell] in Hc.
    destruct (mfield (Efield lv i t)) as [[d0 ty0] |] eqn:Hm; [| discriminate Hc].
    destruct (bv_size t) as [s0 |] eqn:Hs; [| discriminate Hc].
    injection Hc as <- <-.
    destruct (mfield_sound _ _ _ _ _ _ _ _ _ Hg Hm Hl) as (-> & -> & -> & _).
    split; [reflexivity | split; [reflexivity | split; [reflexivity |]]].
    unfold bv_size in Hs. cbn [typeof]. destruct (access_mode t); try discriminate Hs.
    injection Hs as <-. eauto.
Qed.

Lemma cell_ok_in : forall c, cell_ok c = true -> In c cells.
Proof.
  intros [d s] H. apply existsb_exists in H as ([d' s'] & I & E).
  apply andb_true_iff in E as [E1 E2]. apply Z.eqb_eq in E1, E2. cbn in E1, E2. subst. exact I.
Qed.

Lemma store_fp : forall e le m lv rhs t le' m' out,
  store_ok lv = true -> le ! g = Some (Vptr bm om) ->
  exec_stmt function_entry2 ge e le m (Sassign lv rhs) t le' m' out -> fp m m'.
Proof.
  intros e le m lv rhs t le' m' out Hok Hg Hx. inv Hx.
  unfold store_ok in Hok. destruct (lv_cell lv) as [[d s] |] eqn:Hc; [| discriminate Hok].
  pose proof (cell_ok_in _ Hok) as Hin.
  match goal with H : eval_lvalue _ _ _ _ lv _ _ _ |- _ =>
    destruct (lv_cell_sound _ _ _ _ _ _ _ _ _ Hg Hc H) as (-> & -> & -> & ch & Ham & Hsz) end.
  match goal with H : assign_loc _ _ _ _ _ _ _ _ |- _ => inv H end; try congruence.
  rewrite Ham in *. match goal with H : By_value _ = By_value _ |- _ => injection H as <- end.
  match goal with H : Mem.storev _ _ _ _ = Some _ |- _ => rename H into Hst end.
  cbn in Hst.
  split; [| split].
  - eapply Mem.store_unchanged_on; [exact Hst |].
    intros i Hi N. apply N. split; [reflexivity |]. exists d. eexists. split; [exact Hin |].
    unfold cbase. lia.
  - exact (Mem.nextblock_store _ _ _ _ _ _ Hst).
  - intros b z k p. split; [eapply Mem.perm_store_2; eauto | eapply Mem.perm_store_1; eauto].
Qed.

(* ---------------------------------------------------------------------- *)
(* The walker                                                             *)
(* ---------------------------------------------------------------------- *)

Variable e : env.
Variable call_ok : expr -> list expr -> bool.
Hypothesis Hcall : forall optid a al le m t le' m' out,
  call_ok a al = true -> le ! g = Some (Vptr bm om) ->
  exec_stmt function_entry2 ge e le m (Scall optid a al) t le' m' out -> fp m m'.

Fixpoint fp_chk (s : statement) : bool :=
  match s with
  | Sskip | Sbreak | Scontinue | Sreturn _ => true
  | Sset id _ => negb (Pos.eqb id g)
  | Sassign lv _ => store_ok lv
  | Scall optid a al =>
      call_ok a al && match optid with Some ti => negb (Pos.eqb ti g) | None => true end
  | Ssequence s1 s2 => fp_chk s1 && fp_chk s2
  | Sifthenelse _ s1 s2 => fp_chk s1 && fp_chk s2
  | Sloop s1 s2 => fp_chk s1 && fp_chk s2
  | _ => false
  end.

Lemma fp_walk : forall e0 le m s t le' m' out,
  exec_stmt function_entry2 ge e0 le m s t le' m' out -> e0 = e ->
  fp_chk s = true -> le ! g = Some (Vptr bm om) ->
  fp m m' /\ le' ! g = Some (Vptr bm om).
Proof.
  intros e0 le m s t le' m' out Hexec.
  induction Hexec; intros He Hchk Hg; subst; cbn [fp_chk] in Hchk; try discriminate Hchk.
  - split; [apply fp_refl | exact Hg].
  - split; [| exact Hg].
    eapply store_fp; [exact Hchk | exact Hg | eapply exec_Sassign; eassumption].
  - split; [apply fp_refl |].
    rewrite PTree.gso; [exact Hg |].
    intro E; subst; rewrite Pos.eqb_refl in Hchk; discriminate Hchk.
  - apply andb_prop in Hchk as [Hc Ho].
    split; [eapply (Hcall optid); [exact Hc | exact Hg | eapply exec_Scall; eassumption] |].
    destruct optid as [ti |]; cbn [set_opttemp]; [| exact Hg].
    rewrite PTree.gso; [exact Hg |].
    intro E; subst; rewrite Pos.eqb_refl in Ho; discriminate Ho.
  - apply andb_prop in Hchk as [H1 H2].
    destruct (IHHexec1 eq_refl H1 Hg) as [F1 G1].
    destruct (IHHexec2 eq_refl H2 G1) as [F2 G2].
    split; [exact (fp_trans _ _ _ F1 F2) | exact G2].
  - apply andb_prop in Hchk as [H1 _]. exact (IHHexec eq_refl H1 Hg).
  - apply andb_prop in Hchk as [H1 H2].
    apply IHHexec; [reflexivity | destruct b; assumption | exact Hg].
  - split; [apply fp_refl | exact Hg].
  - split; [apply fp_refl | exact Hg].
  - split; [apply fp_refl | exact Hg].
  - split; [apply fp_refl | exact Hg].
  - apply andb_prop in Hchk as [H1 _]. exact (IHHexec eq_refl H1 Hg).
  - apply andb_prop in Hchk as [H1 H2].
    destruct (IHHexec1 eq_refl H1 Hg) as [F1 G1].
    destruct (IHHexec2 eq_refl H2 G1) as [F2 G2].
    split; [exact (fp_trans _ _ _ F1 F2) | exact G2].
  - pose proof Hchk as Hchk0. apply andb_prop in Hchk as [H1 H2].
    destruct (IHHexec1 eq_refl H1 Hg) as [F1 G1].
    destruct (IHHexec2 eq_refl H2 G1) as [F2 G2].
    destruct (IHHexec3 eq_refl Hchk0 G2) as [F3 G3].
    split; [exact (fp_trans _ _ _ F1 (fp_trans _ _ _ F2 F3)) | exact G3].
Qed.
End FP.

(* a function whose one parameter is the pointer and which has no locals:
   the call's footprint is its body's *)
Lemma fp_funcall : forall ge g ty bm om cells call_ok f m t m' vres,
  fn_vars f = nil -> fn_params f = [(g, ty)] ->
  (forall optid a al le m t le' m' out,
     call_ok a al = true -> le ! g = Some (Vptr bm om) ->
     exec_stmt function_entry2 ge empty_env le m (Scall optid a al) t le' m' out ->
     fp bm om cells m m') ->
  fp_chk ge g cells call_ok (fn_body f) = true ->
  eval_funcall function_entry2 ge m (Internal f) [Vptr bm om] t m' vres ->
  fp bm om cells m m'.
Proof.
  intros ge g ty bm om cells call_ok f m t m' vres Hv Hp Hc Hchk Hev.
  inv Hev.
  match goal with H : function_entry2 _ _ _ _ _ _ _ |- _ => inv H end.
  rewrite Hv in *. match goal with H : alloc_variables _ _ _ _ _ _ |- _ => inv H end.
  rewrite Hp in *.
  match goal with H : bind_parameter_temps _ _ _ = Some _ |- _ => cbn in H; injection H as <- end.
  match goal with H : exec_stmt _ _ _ _ _ _ _ _ _ _ |- _ =>
    destruct (fp_walk ge g bm om cells empty_env call_ok Hc _ _ _ _ _ _ _ _ H eq_refl Hchk
                (PTree.gss _ _ _)) as [F _] end.
  match goal with H : Mem.free_list _ _ = Some _ |- _ => cbn in H; injection H as <- end.
  exact F.
Qed.

(* a footprint inside a larger cell list *)
Lemma fp_mono : forall bm om c1 c2 m m',
  incl c1 c2 -> fp bm om c1 m m' -> fp bm om c2 m m'.
Proof.
  intros bm om c1 c2 m m' I (U & N & P). split; [| split; [exact N | exact P]].
  eapply Mem.unchanged_on_implies; [exact U |].
  intros b z N2 _ (Eb & d & s & Hin & R). apply N2. split; [exact Eb |]. exists d, s. auto.
Qed.

(* ---------------------------------------------------------------------- *)
(* Calls through a global function name                                   *)
(* ---------------------------------------------------------------------- *)

Lemma scall_evar_inv2 : forall ge e le m optid fid fty al t le' m' out,
  exec_stmt function_entry2 ge e le m (Scall optid (Evar fid fty) al) t le' m' out ->
  e ! fid = None -> access_mode fty = By_reference ->
  exists b fd tyargs tyres cc vargs vres,
    Genv.find_symbol ge fid = Some b
    /\ Genv.find_funct ge (Vptr b Ptrofs.zero) = Some fd
    /\ classify_fun fty = fun_case_f tyargs tyres cc
    /\ eval_exprlist ge e le m al tyargs vargs
    /\ eval_funcall function_entry2 ge m fd vargs t m' vres.
Proof.
  intros ge e le m optid fid fty al t le' m' out H En Am.
  inv H.
  match goal with Hv : eval_expr _ _ _ _ (Evar _ _) _ |- _ => inv Hv end;
    try (cbn in *; discriminate).
  match goal with Hx : eval_lvalue _ _ _ _ (Evar _ _) _ _ _ |- _ => inv Hx end.
  - congruence.
  - match goal with Hd : deref_loc _ _ _ _ _ _ |- _ => inv Hd end; cbn in *; try congruence.
    do 7 eexists. split; [eassumption | split; [eassumption |]].
    split; [eassumption | split; eassumption].
Qed.

Lemma find_funct_res : forall ge id f b fd, resolves_to ge id f ->
  Genv.find_symbol ge id = Some b -> Genv.find_funct ge (Vptr b Ptrofs.zero) = Some fd ->
  fd = Internal f.
Proof.
  intros ge id f b fd R Hs Hf. rewrite Genv.find_funct_find_funct_ptr in Hf. exact (R b fd Hs Hf).
Qed.

(* an External symbol of the link: no linked TU defines it *)
Definition ext_named (o : option (globdef Clight.fundef type)) (n : String.string) : bool :=
  match o with
  | Some (Gfun (External (EF_external n' _) _ _ _)) => String.eqb n' n
  | _ => false
  end.

Lemma ext_named_ok : forall o n, ext_named o n = true ->
  exists sg targs tres cc, o = Some (Gfun (External (EF_external n sg) targs tres cc)).
Proof.
  intros o n H. destruct o as [[[f | ef targs tres cc] | v] |]; try discriminate.
  destruct ef; try discriminate. cbn in H. apply String.eqb_eq in H. subst. eauto.
Qed.

Definition no_internal_all (ids : list ident) : bool :=
  forallb (fun p => no_internal_ids p ids) (mario.prog :: tu_rest).

Lemma ext_resolve : forall lp q fid ids n b fd,
  linked12 lp -> linkorder q lp ->
  CensusV2.mem_id fid ids = true -> no_internal_all ids = true ->
  ext_named ((prog_defmap q) ! fid) n = true ->
  Genv.find_symbol (globalenv lp) fid = Some b ->
  Genv.find_funct (globalenv lp) (Vptr b Ptrofs.zero) = Some fd ->
  exists sg targs tres cc, fd = External (EF_external n sg) targs tres cc.
Proof.
  intros lp q fid ids n b fd Hlink LOq Hid Hall Hn Hs Hf.
  destruct (ext_named_ok _ _ Hn) as (sg & targs & tres & cc & Hdm).
  assert (Hdm' : (prog_defmap lp) ! fid = Some (Gfun fd)).
  { apply resolves_defmap. exists b. split; assumption. }
  Local Transparent Linker_program.
  unfold linkorder, Linker_program, linkorder_program in LOq.
  destruct LOq as [LOast _].
  destruct (prog_defmap_linkorder _ _ _ _ LOast Hdm) as (gd' & Hgd' & Hlo).
  change (prog_defmap (program_of_program lp)) with (prog_defmap lp) in Hgd'.
  rewrite Hdm' in Hgd'. injection Hgd' as <-.
  inv Hlo.
  match goal with H : linkorder _ _ |- _ => inv H end.
  - do 4 eexists. reflexivity.
  - exfalso. unfold no_internal_all in Hall. rewrite forallb_forall in Hall.
    destruct (link_chain_internal_origin _ _ _ _ _ Hlink Hdm') as [Hbase | (q' & Hq & Hqdm)].
    + exact (no_internal_ids_correct _ _ _ _ (Hall _ (or_introl eq_refl)) Hid Hbase).
    + exact (no_internal_ids_correct _ _ _ _ (Hall _ (or_intror Hq)) Hid Hqdm).
Qed.

(* ---------------------------------------------------------------------- *)
(* The real bodies                                                        *)
(* ---------------------------------------------------------------------- *)

Module AIR := mario_actions_airborne.

Definition fo (ge : genv) (s f : ident) : Z :=
  match (genv_cenv ge) ! s with
  | Some co => match field_offset ge f (co_members co) with OK (d, _) => d | _ => -1 end
  | None => -1
  end.

(* the cells update_air_without_turn may write (check_horizontal_wind's
   included): forwardVel, slideVelX, slideVelZ, vel[0], vel[2], slideYaw *)
Definition uawt_cells (ge : genv) : list (Z * Z) :=
  [(fo ge AIR._MarioState AIR._forwardVel, 4);
   (fo ge AIR._MarioState AIR._slideVelX, 4);
   (fo ge AIR._MarioState AIR._slideVelZ, 4);
   (fo ge AIR._MarioState AIR._vel, 4);
   (fo ge AIR._MarioState AIR._vel + 8, 4);
   (fo ge AIR._MarioState AIR._slideYaw, 2)].

Definition is_call (ids : list ident) (a : expr) : bool :=
  match a with Evar fid (Tfunction _ _ _) => existsb (Pos.eqb fid) ids | _ => false end.

Definition chw_call_ok (a : expr) (al : list expr) : bool :=
  is_call [AIR._sqrtf; AIR._atan2s] a.

Definition uawt_call_ok (a : expr) (al : list expr) : bool :=
  is_call [AIR._approach_f32] a
  || (is_call [AIR._check_horizontal_wind] a
      && match a, al with
         | Evar _ (Tfunction [Tpointer (Tstruct s1 _) _] _ _),
           [Etempvar x (Tpointer (Tstruct s2 _) _)] =>
             Pos.eqb x AIR._m && Pos.eqb s1 AIR._MarioState && Pos.eqb s2 AIR._MarioState
         | _, _ => false
         end).

Lemma chw_chk12 : match ge12 with
  | Some ge => fp_chk ge AIR._m (uawt_cells ge) chw_call_ok (fn_body AIR.f_check_horizontal_wind)
  | None => false end = true.
Proof. vm_compute. reflexivity. Qed.

Lemma uawt_chk12 : match ge12 with
  | Some ge => fp_chk ge AIR._m (uawt_cells ge) uawt_call_ok (fn_body AIR.f_update_air_without_turn)
  | None => false end = true.
Proof. vm_compute. reflexivity. Qed.

Lemma is_call_inv : forall ids a, is_call ids a = true ->
  exists fid targs tres cc, a = Evar fid (Tfunction targs tres cc) /\ In fid ids.
Proof.
  intros ids a H. destruct a; try discriminate H. destruct t; try discriminate H.
  apply existsb_exists in H as (x & I & E). apply Pos.eqb_eq in E. subst. eauto 6.
Qed.

Lemma sqrtf_named : ext_named ((prog_defmap AIR.prog) ! AIR._sqrtf) "sqrtf" = true.
Proof. vm_compute. reflexivity. Qed.
Lemma sqrtf_ni : no_internal_all [AIR._sqrtf] = true.
Proof. vm_compute. reflexivity. Qed.
Lemma dm_chw : (prog_defmap AIR.prog) ! AIR._check_horizontal_wind
  = Some (Gfun (Internal AIR.f_check_horizontal_wind)).
Proof. vm_compute. reflexivity. Qed.
Lemma dm_uawt : (prog_defmap AIR.prog) ! AIR._update_air_without_turn
  = Some (Gfun (Internal AIR.f_update_air_without_turn)).
Proof. vm_compute. reflexivity. Qed.
Lemma dm_atan2s_air : (prog_defmap math_util.prog) ! AIR._atan2s
  = Some (Gfun (Internal math_util.f_atan2s)).
Proof. vm_compute. reflexivity. Qed.

Section LP.
Variable lp : Clight.program.
Hypothesis H12 : linked12 lp.
Hypothesis Hsq : sqrtf_spec.
Local Notation G := (globalenv lp).

Let LOair : linkorder AIR.prog lp := linked12_LO_air lp H12.
Let LOmath : linkorder math_util.prog lp := linked12_LO_math lp H12.
Let Rat : resolves_to G math_util._atan2_lookup math_util.f_atan2_lookup :=
  res_link lp _ _ _ LOmath math_dm_atan2_lookup.

(* sqrtf, atan2s and approach_f32 leave memory as it was *)
Lemma call_memid : forall optid fid targs tres cc al le m t le' m' out,
  In fid [AIR._sqrtf; AIR._atan2s; AIR._approach_f32] ->
  exec_stmt function_entry2 G empty_env le m
    (Scall optid (Evar fid (Tfunction targs tres cc)) al) t le' m' out -> m' = m.
Proof.
  intros optid fid targs tres cc al le m t le' m' out I Hx.
  destruct (scall_evar_inv2 _ _ _ _ _ _ _ _ _ _ _ _ Hx (PTree.gempty _ _) eq_refl)
    as (b & fd & tyargs & tyres & cc' & vargs & vres & Hs & Hf & _ & _ & Hev).
  destruct I as [<- | [<- | [<- | []]]].
  - destruct (ext_resolve lp AIR.prog AIR._sqrtf [AIR._sqrtf] "sqrtf" b fd H12 LOair eq_refl sqrtf_ni
                sqrtf_named Hs Hf) as (sg & ? & ? & ? & ->).
    inv Hev. eapply Hsq. eassumption.
  - rewrite (find_funct_res _ _ _ _ _ (res_link lp _ _ _ LOmath dm_atan2s_air) Hs Hf) in Hev.
    exact (proj1 (atan2s_value_contract G Rat _ _ _ _ _ Hev)).
  - rewrite (find_funct_res _ _ _ _ _ (res_link lp _ _ _ LOmath math_defmap_af32) Hs Hf) in Hev.
    exact (cpure2_funcall_memid G math_util.f_approach_f32 eq_refl af32_pure Rat _ _ _ _ _ Hev).
Qed.

Lemma chw_fp : forall bm om m t m' vres,
  eval_funcall function_entry2 G m (Internal AIR.f_check_horizontal_wind) [Vptr bm om] t m' vres ->
  fp bm om (uawt_cells G) m m'.
Proof.
  intros bm om m t m' vres Hev.
  pose proof chw_chk12 as W. rewrite (ge12_ok lp H12) in W.
  eapply (fp_funcall G AIR._m _ bm om (uawt_cells G) _ AIR.f_check_horizontal_wind); [reflexivity | reflexivity | | exact W | exact Hev].
  intros optid a al le m0 t0 le' m0' out Hok _ Hx.
  unfold chw_call_ok in Hok. destruct (is_call_inv _ _ Hok) as (fid & targs & tres & cc & -> & I).
  assert (I' : In fid [AIR._sqrtf; AIR._atan2s; AIR._approach_f32])
    by (destruct I as [<- | [<- | []]]; cbn; auto).
  rewrite (call_memid _ fid _ _ _ _ _ _ _ _ _ _ I' Hx).
  apply fp_refl.
Qed.

Theorem uawt_fp : forall bm om m t m' vres,
  eval_funcall function_entry2 G m (Internal AIR.f_update_air_without_turn) [Vptr bm om] t m' vres ->
  fp bm om (uawt_cells G) m m'.
Proof.
  intros bm om m t m' vres Hev.
  pose proof uawt_chk12 as W. rewrite (ge12_ok lp H12) in W.
  eapply (fp_funcall G AIR._m _ bm om (uawt_cells G) _ AIR.f_update_air_without_turn); [reflexivity | reflexivity | | exact W | exact Hev].
  intros optid a al le m0 t0 le' m0' out Hok Hg Hx.
  unfold uawt_call_ok in Hok. apply orb_true_iff in Hok as [Hok | Hok].
  - destruct (is_call_inv _ _ Hok) as (fid & targs & tres & cc & -> & [<- | []]).
    assert (I' : In AIR._approach_f32 [AIR._sqrtf; AIR._atan2s; AIR._approach_f32]) by (cbn; auto).
    rewrite (call_memid _ _ _ _ _ _ _ _ _ _ _ _ I' Hx). apply fp_refl.
  - apply andb_true_iff in Hok as [Hc Ha].
    destruct (is_call_inv _ _ Hc) as (fid & targs & tres & cc & -> & [<- | []]).
    cbn beta iota in Ha.
    repeat (match type of Ha with context [match ?x with _ => _ end] =>
              destruct x; cbn beta iota in Ha; try discriminate Ha end).
    match goal with Hx : exec_stmt _ _ _ _ _ (Scall _ _ [Etempvar ?xx _]) _ _ _ _ |- _ =>
      rename xx into x end.
    apply andb_true_iff in Ha as [Ha Hs2]. apply andb_true_iff in Ha as [Hx1 Hs1].
    apply Pos.eqb_eq in Hx1, Hs1, Hs2. subst.
    destruct (scall_evar_inv2 _ _ _ _ _ _ _ _ _ _ _ _ Hx (PTree.gempty _ _) eq_refl)
      as (b & fd & tyargs & tyres & cc' & vargs & vres' & Hs & Hf & Hcl & Hel & Hev').
    rewrite (find_funct_res _ _ _ _ _ (res_link lp _ _ _ LOair dm_chw) Hs Hf) in Hev'.
    cbn in Hcl. injection Hcl as <- <- <-.
    inv Hel. match goal with H : eval_exprlist _ _ _ _ [] _ _ |- _ => inv H end.
    match goal with H : eval_expr _ _ _ _ (Etempvar _ _) _ |- _ => inv H end;
      [| match goal with H : eval_lvalue _ _ _ _ (Etempvar _ _) _ _ _ |- _ => inv H end].
    rewrite Hg in *. match goal with H : Some _ = Some _ |- _ => injection H as <- end.
    match goal with H : sem_cast _ _ _ _ = Some _ |- _ => cbn in H; injection H as <- end.
    exact (chw_fp _ _ _ _ _ _ Hev').
Qed.
End LP.
