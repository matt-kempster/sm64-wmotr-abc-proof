(* ===================================================================== *)
(* PlatformWalk (GOAL 2): the real apply_mario_platform_displacement,    *)
(* walked (2026-10-23).                                                   *)
(*                                                                       *)
(* platform_displacement.c is linked (the 45th TU).  Its                 *)
(* apply_platform_displacement(1, platform), on a platform whose angle   *)
(* velocity cells (rawData.asS32[35..37]) are zero, stores               *)
(*   rotation[0..2] := 0 (locals), D_8032FEC0 := 0,                       *)
(*   x, y, z := pos[0..2] (get_mario_pos, into locals),                   *)
(*   x += platform velX, z += platform velZ (locals),                     *)
(*   pos[0..2] := x, y, z (set_mario_pos) -- y is the value just read,    *)
(* and skips the rotation block (t'2 = 0).  apd_eff: such a run is a      *)
(* PlatformEff.sruns between allocating and freeing its eight locals, so *)
(* its effect is plat_eff.  ampd_eff: the outer                          *)
(* apply_mario_platform_displacement either does not call it (memory     *)
(* unchanged) or calls it on gMarioPlatform, which the premise makes     *)
(* NULL (then the guard is false) or a non-rotating object.              *)
(* ===================================================================== *)
From Coq Require Import ZArith Lia List.
From compcert Require Import Coqlib Integers Floats Values AST Ctypes Cop Clight
  ClightBigstep Clightdefs Memory Maps Globalenvs Events Errors.
From SM64.Generated Require platform_displacement.
From SM64.Proofs.WMotRRequiresA Require Import RenderAnim PlatformEff.
Import ListNotations.
Local Open Scope Z_scope.

Module PD := platform_displacement.

Definition ufo_ok (ce : composite_env) (U f : ident) : bool :=
  match ce ! U with
  | Some co => complete_members ce (co_members co) &&
      match union_field_offset ce f (co_members co) with OK (0, Full) => true | _ => false end
  | None => false
  end.

Lemma ufo_ok_lift : forall ce ce' U f, ufo_ok ce U f = true ->
  (forall id co, ce ! id = Some co -> ce' ! id = Some co) ->
  forall co, ce' ! U = Some co -> union_field_offset ce' f (co_members co) = OK (0, Full).
Proof.
  unfold ufo_ok. intros ce ce' U f H Hext co Hco.
  destruct (ce ! U) as [co0|] eqn:E; [| discriminate].
  apply andb_prop in H as [Hc Hf].
  rewrite (Hext _ _ E) in Hco. injection Hco as <-.
  rewrite (union_field_offset_stable ce ce' Hext _ _ Hc).
  destruct (union_field_offset ce f (co_members co0)) as [[[|p|p] []]|]; try discriminate.
  reflexivity.
Qed.

Section PW.
Variable ge : genv.
Hypothesis Hcenv : forall id co, (prog_comp_env PD.prog) ! id = Some co -> (genv_cenv ge) ! id = Some co.

Lemma fo_raw : forall co, (genv_cenv ge) ! PD._Object = Some co ->
  field_offset ge PD._rawData (co_members co) = OK (136, Full).
Proof. apply (fo_ok_lift (prog_comp_env PD.prog)); [ vm_compute; reflexivity | exact Hcenv ]. Qed.
Lemma fo_pos : forall co, (genv_cenv ge) ! PD._MarioState = Some co ->
  field_offset ge PD._pos (co_members co) = OK (60, Full).
Proof. apply (fo_ok_lift (prog_comp_env PD.prog)); [ vm_compute; reflexivity | exact Hcenv ]. Qed.
Lemma ufo_s32 : forall co, (genv_cenv ge) ! PD.__764 = Some co ->
  union_field_offset ge PD._asS32 (co_members co) = OK (0, Full).
Proof. apply (ufo_ok_lift (prog_comp_env PD.prog)); [ vm_compute; reflexivity | exact Hcenv ]. Qed.
Lemma ufo_f32 : forall co, (genv_cenv ge) ! PD.__764 = Some co ->
  union_field_offset ge PD._asF32 (co_members co) = OK (0, Full).
Proof. apply (ufo_ok_lift (prog_comp_env PD.prog)); [ vm_compute; reflexivity | exact Hcenv ]. Qed.

Ltac kill :=
  try (match goal with Ha : access_mode _ = _ |- _ => cbn in Ha; discriminate Ha end);
  try (match goal with Ht : typeof _ = _ |- _ => cbn in Ht; discriminate Ht end);
  try (match goal with Hb : load_bitfield _ _ _ _ _ _ _ _ |- _ => inv Hb end).

Section EV.
Variable e : env.
Variable m : mem.

(* platform->rawData.asXX[k] *)
Lemma ev_raw : forall le p fld ety k v ch,
  (forall co, (genv_cenv ge) ! PD.__764 = Some co -> union_field_offset ge fld (co_members co) = OK (0, Full)) ->
  access_mode ety = By_value ch ->
  eval_expr ge e le m
    (Ederef (Ebinop Oadd (Efield (Efield (Ederef (Etempvar p (tptr (Tstruct PD._Object noattr)))
       (Tstruct PD._Object noattr)) PD._rawData (Tunion PD.__764 noattr)) fld (tarray ety 80))
       (Econst_int (Int.repr k) tint) (tptr ety)) ety) v ->
  exists b o, le ! p = Some (Vptr b o) /\
    Mem.loadv ch m (Vptr b (Ptrofs.add (Ptrofs.add (Ptrofs.add o (Ptrofs.repr 136)) (Ptrofs.repr 0))
                              (Ptrofs.mul (Ptrofs.repr (sizeof ge ety)) (Ptrofs.of_ints (Int.repr k))))) = Some v.
Proof.
  intros le p fld ety k v ch Hu Ham H.
  inv H. rename H1 into Hd.
  match goal with Hl : eval_lvalue _ _ _ _ (Ederef _ _) _ _ _ |- _ => inv Hl end.
  match goal with Hb : eval_expr _ _ _ _ (Ebinop _ _ _ _) _ |- _ =>
    apply ev_binop in Hb; destruct Hb as (v1 & v2 & E1 & E2 & E3) end.
  apply ev_const in E2. subst v2.
  inv E1. cbn [typeof] in Hd, H0, E3.
  inv H0; kill.
  all: inv H; kill.
  all: match goal with Ht : typeof _ = Tunion _ _ |- _ => cbn in Ht; injection Ht as <- <- end.
  all: match goal with Hf : union_field_offset _ _ (co_members ?co) = OK _, Hc : _ ! _ = Some ?co |- _ =>
         rewrite (Hu _ Hc) in Hf; injection Hf; intros; subst end.
  all: match goal with He : eval_expr _ _ _ _ (Efield _ _ _) _ |- _ => inv He end.
  all: match goal with Hd2 : deref_loc (typeof (Efield _ _ _)) _ _ _ _ _ |- _ =>
         cbn [typeof] in Hd2; inv Hd2 end; kill.
  all: match goal with Hl : eval_lvalue _ _ _ _ (Efield _ _ _) _ _ _ |- _ => inv Hl end; kill.
  all: match goal with Ht : typeof _ = Tstruct _ _ |- _ => cbn in Ht; injection Ht as <- <- end.
  all: match goal with Hf : field_offset _ _ (co_members ?co) = OK _, Hc : _ ! _ = Some ?co |- _ =>
         rewrite (fo_raw _ Hc) in Hf; injection Hf; intros; subst end.
  all: match goal with He : eval_expr _ _ _ _ (Ederef _ _) _ |- _ => inv He end.
  all: match goal with Hd2 : deref_loc (typeof (Ederef _ _)) _ _ _ _ _ |- _ =>
         cbn [typeof] in Hd2; inv Hd2 end; kill.
  all: match goal with Hl : eval_lvalue _ _ _ _ (Ederef _ _) _ _ _ |- _ => inv Hl end.
  all: match goal with Ht : eval_expr _ _ _ _ (Etempvar _ _) _ |- _ => apply ev_temp in Ht end.
  all: cbn in E3; injection E3 as <- <-.
  all: inv Hd; kill.
  all: do 2 eexists; split; [ eassumption |].
  all: match goal with Hh : access_mode ?t = By_value _, H1 : access_mode ?t = _ |- _ =>
         tryif constr_eq H1 Hh then fail else (rewrite Hh in H1; try discriminate H1; injection H1 as <-) end.
  all: assumption.
Qed.

(* a local scalar, read *)
Lemma ev_local : forall le x b0 ty v ch, e ! x = Some (b0, ty) -> access_mode ty = By_value ch ->
  eval_expr ge e le m (Evar x ty) v -> Mem.load ch m b0 0 = Some v.
Proof.
  intros le x b0 ty v ch He Ham H. inv H.
  match goal with Hl : eval_lvalue _ _ _ _ (Evar _ _) _ _ _ |- _ => inv Hl end; [| congruence].
  match goal with H1 : e ! x = Some _ |- _ => rewrite He in H1; injection H1 as <- end.
  match goal with Hd : deref_loc _ _ _ _ _ _ |- _ => cbn [typeof] in Hd; inv Hd end; kill;
  match goal with Hh : access_mode ?t = By_value _, H1 : access_mode ?t = _ |- _ =>
    tryif constr_eq H1 Hh then fail else (rewrite Hh in H1; try discriminate H1; injection H1 as <-) end.
  assumption.
Qed.

(* a local, written *)
Lemma lv_local : forall le x b0 ty ty' b o bf, e ! x = Some (b0, ty') ->
  eval_lvalue ge e le m (Evar x ty) b o bf -> b = b0 /\ o = Ptrofs.zero /\ bf = Full.
Proof.
  intros le x b0 ty ty' b o bf He H. inv H; [| congruence].
  rewrite He in *. match goal with H1 : Some _ = Some _ |- _ => injection H1 as <- <- end. auto.
Qed.

(* &x, x a local *)
Lemma ev_addr_local : forall le x b0 ty pty v, e ! x = Some (b0, ty) ->
  eval_expr ge e le m (Eaddrof (Evar x ty) pty) v -> v = Vptr b0 Ptrofs.zero.
Proof.
  intros le x b0 ty pty v He H. inv H; [| match goal with Hl : eval_lvalue _ _ _ _ (Eaddrof _ _) _ _ _ |- _ => inv Hl end].
  match goal with Hl : eval_lvalue _ _ _ _ (Evar _ _) _ _ _ |- _ => apply (lv_local _ _ _ _ _ _ _ _ He) in Hl; destruct Hl as (-> & -> & _) end.
  reflexivity.
Qed.

(* a[k], a a local array *)
Lemma lv_arr : forall le a b0 ty n k b o bf, e ! a = Some (b0, tarray ty n) ->
  eval_lvalue ge e le m (Ederef (Ebinop Oadd (Evar a (tarray ty n)) (Econst_int (Int.repr k) tint) (tptr ty)) ty) b o bf ->
  b = b0 /\ bf = Full /\ o = Ptrofs.add Ptrofs.zero (Ptrofs.mul (Ptrofs.repr (sizeof ge ty)) (Ptrofs.of_ints (Int.repr k))).
Proof.
  intros le a b0 ty n k b o bf He H. inv H.
  match goal with Hb : eval_expr _ _ _ _ (Ebinop _ _ _ _) _ |- _ =>
    apply ev_binop in Hb; destruct Hb as (v1 & v2 & E1 & E2 & E3) end.
  apply ev_const in E2. subst v2.
  inv E1. match goal with Hl : eval_lvalue _ _ _ _ (Evar _ _) _ _ _ |- _ =>
    apply (lv_local _ _ _ _ _ _ _ _ He) in Hl; destruct Hl as (-> & -> & ->) end.
  match goal with Hd : deref_loc _ _ _ _ _ _ |- _ => cbn [typeof] in Hd; inv Hd end; kill.
  cbn in E3. injection E3 as <- <-. auto.
Qed.

(* the value of a[k], a a local array *)
Lemma ev_arr : forall le a b0 ty n k v ch, e ! a = Some (b0, tarray ty n) -> access_mode ty = By_value ch ->
  eval_expr ge e le m (Ederef (Ebinop Oadd (Evar a (tarray ty n)) (Econst_int (Int.repr k) tint) (tptr ty)) ty) v ->
  Mem.loadv ch m (Vptr b0 (Ptrofs.add Ptrofs.zero (Ptrofs.mul (Ptrofs.repr (sizeof ge ty)) (Ptrofs.of_ints (Int.repr k))))) = Some v.
Proof.
  intros le a b0 ty n k v ch He Ham H. inv H.
  match goal with Hl : eval_lvalue _ _ _ _ (Ederef _ _) _ _ _ |- _ =>
    apply (lv_arr _ _ _ _ _ _ _ _ _ He) in Hl; destruct Hl as (-> & -> & ->) end.
  match goal with Hd : deref_loc _ _ _ _ _ _ |- _ => cbn [typeof] in Hd; inv Hd end; kill;
  match goal with Hh : access_mode ?t = By_value _, H1 : access_mode ?t = _ |- _ =>
    tryif constr_eq H1 Hh then fail else (rewrite Hh in H1; try discriminate H1; injection H1 as <-) end.
  assumption.
Qed.

(* *p, p a temp *)
Lemma lv_deref_temp : forall le x ty b o bf,
  eval_lvalue ge e le m (Ederef (Etempvar x (tptr ty)) ty) b o bf -> le ! x = Some (Vptr b o) /\ bf = Full.
Proof.
  intros le x ty b o bf H. inv H.
  match goal with Ht : eval_expr _ _ _ _ (Etempvar _ _) _ |- _ => apply ev_temp in Ht end. auto.
Qed.

(* gMarioStates[0].pos[k], as an lvalue *)
Lemma lv_mpos : forall le k b o bf, e ! PD._gMarioStates = None ->
  eval_lvalue ge e le m
    (Ederef (Ebinop Oadd (Efield (Ederef (Ebinop Oadd
       (Evar PD._gMarioStates (tarray (Tstruct PD._MarioState noattr) 0))
       (Econst_int (Int.repr 0) tint) (tptr (Tstruct PD._MarioState noattr)))
       (Tstruct PD._MarioState noattr)) PD._pos (tarray tfloat 3))
       (Econst_int (Int.repr k) tint) (tptr tfloat)) tfloat) b o bf ->
  Genv.find_symbol ge PD._gMarioStates = Some b /\ bf = Full /\
  o = Ptrofs.add (Ptrofs.add (Ptrofs.add Ptrofs.zero
         (Ptrofs.mul (Ptrofs.repr (sizeof ge (Tstruct PD._MarioState noattr))) (Ptrofs.of_ints (Int.repr 0))))
         (Ptrofs.repr 60)) (Ptrofs.mul (Ptrofs.repr (sizeof ge tfloat)) (Ptrofs.of_ints (Int.repr k))).
Proof.
  intros le k b o bf He H. inv H.
  match goal with Hb : eval_expr _ _ _ _ (Ebinop _ _ _ _) _ |- _ =>
    apply ev_binop in Hb; destruct Hb as (v1 & v2 & E1 & E2 & E3) end.
  apply ev_const in E2. subst v2.
  inv E1. match goal with Hd : deref_loc _ _ _ _ _ _ |- _ => cbn [typeof] in Hd; inv Hd end; kill.
  match goal with Hl : eval_lvalue _ _ _ _ (Efield _ _ _) _ _ _ |- _ => inv Hl end; kill.
  match goal with Ht : typeof _ = Tstruct _ _ |- _ => cbn in Ht; injection Ht as <- <- end.
  match goal with Hf : field_offset _ _ (co_members ?co) = OK _, Hc : _ ! _ = Some ?co |- _ =>
    rewrite (fo_pos _ Hc) in Hf; injection Hf; intros; subst end.
  match goal with He2 : eval_expr _ _ _ _ (Ederef _ _) _ |- _ => inv He2 end.
  match goal with Hd : deref_loc _ _ _ _ _ _ |- _ => cbn [typeof] in Hd; inv Hd end; kill.
  match goal with Hl : eval_lvalue _ _ _ _ (Ederef _ _) _ _ _ |- _ => inv Hl end.
  match goal with Hb : eval_expr _ _ _ _ (Ebinop _ _ _ _) _ |- _ =>
    apply ev_binop in Hb; destruct Hb as (w1 & w2 & F1 & F2 & F3) end.
  apply ev_const in F2. subst w2.
  inv F1. match goal with Hl : eval_lvalue _ _ _ _ (Evar _ _) _ _ _ |- _ => inv Hl end; [ congruence |].
  match goal with Hd : deref_loc _ _ _ _ _ _ |- _ => cbn [typeof] in Hd; inv Hd end; kill.
  cbn in F3. injection F3 as <- <-.
  cbn in E3. injection E3 as <- <-.
  auto.
Qed.

Lemma ev_mpos : forall le k v, e ! PD._gMarioStates = None ->
  eval_expr ge e le m
    (Ederef (Ebinop Oadd (Efield (Ederef (Ebinop Oadd
       (Evar PD._gMarioStates (tarray (Tstruct PD._MarioState noattr) 0))
       (Econst_int (Int.repr 0) tint) (tptr (Tstruct PD._MarioState noattr)))
       (Tstruct PD._MarioState noattr)) PD._pos (tarray tfloat 3))
       (Econst_int (Int.repr k) tint) (tptr tfloat)) tfloat) v ->
  exists b, Genv.find_symbol ge PD._gMarioStates = Some b /\
  Mem.loadv Mfloat32 m (Vptr b (Ptrofs.add (Ptrofs.add (Ptrofs.add Ptrofs.zero
         (Ptrofs.mul (Ptrofs.repr (sizeof ge (Tstruct PD._MarioState noattr))) (Ptrofs.of_ints (Int.repr 0))))
         (Ptrofs.repr 60)) (Ptrofs.mul (Ptrofs.repr (sizeof ge tfloat)) (Ptrofs.of_ints (Int.repr k))))) = Some v.
Proof.
  intros le k v He H. inv H.
  match goal with Hl : eval_lvalue _ _ _ _ (Ederef _ _) _ _ _ |- _ =>
    apply lv_mpos in Hl; [ destruct Hl as (Hs & -> & ->) | exact He ] end.
  exists loc. split; [ exact Hs |].
  match goal with Hd : deref_loc _ _ _ _ _ _ |- _ => cbn [typeof] in Hd; inv Hd end; kill.
  match goal with H1 : access_mode tfloat = By_value _ |- _ => cbn in H1; injection H1 as <- end.
  assumption.
Qed.

End EV.

Lemma cast_ff_id : forall v v' m, sem_cast v tfloat tfloat m = Some v' -> exists f, v = Vsingle f /\ v' = v.
Proof. intros v v' m H. destruct v; cbn in H; try discriminate; injection H; intros <-; eauto. Qed.

Lemma ofs_lin : forall a c k, 0 <= a <= 1000 -> 0 <= c <= 100 -> 0 <= k <= 100 ->
  Ptrofs.add (Ptrofs.repr a) (Ptrofs.mul (Ptrofs.repr c) (Ptrofs.of_ints (Int.repr k))) = Ptrofs.repr (a + c * k).
Proof.
  intros a c k Ha Hc Hk. unfold Ptrofs.of_ints.
  rewrite Int.signed_repr by (change Int.min_signed with (-2147483648); change Int.max_signed with 2147483647; lia).
  unfold Ptrofs.mul, Ptrofs.add.
  assert (U : forall z, 0 <= z <= 1000000 -> Ptrofs.unsigned (Ptrofs.repr z) = z)
    by (intros z Hz; apply Ptrofs.unsigned_repr; change Ptrofs.max_unsigned with 4294967295; lia).
  rewrite (U c), (U k), (U a) by lia. rewrite (U (c * k)) by nia. reflexivity.
Qed.

Lemma mpos_ofs : forall (ce : composite_env) k, 0 <= k < 3 ->
  Ptrofs.unsigned (Ptrofs.add (Ptrofs.add (Ptrofs.add Ptrofs.zero
         (Ptrofs.mul (Ptrofs.repr (sizeof ce (Tstruct PD._MarioState noattr))) (Ptrofs.of_ints (Int.repr 0))))
         (Ptrofs.repr 60)) (Ptrofs.mul (Ptrofs.repr (sizeof ce tfloat)) (Ptrofs.of_ints (Int.repr k))))
  = 60 + 4 * k.
Proof.
  intros ce k Hk. rewrite ptr_add0, Ptrofs.add_zero_l.
  change (sizeof ce tfloat) with 4. rewrite ofs_lin by lia.
  apply Ptrofs.unsigned_repr. change Ptrofs.max_unsigned with 4294967295; lia.
Qed.

Lemma arr_ofs : forall c k, 0 <= c <= 100 -> 0 <= k <= 100 ->
  Ptrofs.unsigned (Ptrofs.add Ptrofs.zero (Ptrofs.mul (Ptrofs.repr c) (Ptrofs.of_ints (Int.repr k)))) = c * k.
Proof.
  intros c k Hc Hk. change Ptrofs.zero with (Ptrofs.repr 0). rewrite ofs_lin by lia.
  apply Ptrofs.unsigned_repr. change Ptrofs.max_unsigned with 4294967295; nia.
Qed.

Variable bm : block.
Hypothesis Hbm : Genv.find_symbol ge PD._gMarioStates = Some bm.

Ltac pn1 :=
  match goal with
  | H : eval_expr _ _ _ _ (Etempvar _ _) _ |- _ => apply ev_temp in H
  | H : eval_expr _ _ _ _ (Econst_int _ _) _ |- _ => apply ev_const in H; subst
  | H : eval_lvalue _ _ _ _ (Ederef (Etempvar _ _) _) _ _ _ |- _ =>
      apply lv_deref_temp in H; destruct H as (H & ?); subst
  | H : eval_expr _ _ _ _ (Ederef (Ebinop Oadd (Efield (Ederef (Ebinop Oadd (Evar PD._gMarioStates _) _ _) _) _ _) _ _) _) _ |- _ =>
      let Hs := fresh in
      apply ev_mpos in H; [ destruct H as (? & Hs & H); rewrite Hbm in Hs; injection Hs as <-;
                            cbn [Mem.loadv] in H; rewrite mpos_ofs in H by lia; cbn [Z.mul Z.add] in H
                          | first [ reflexivity | progress getnorm_env ] ]
  | H : eval_lvalue _ _ _ _ (Ederef (Ebinop Oadd (Efield (Ederef (Ebinop Oadd (Evar PD._gMarioStates _) _ _) _) _ _) _ _) _) _ _ _ |- _ =>
      let Hs := fresh in
      apply lv_mpos in H; [ destruct H as (Hs & ? & ?); rewrite Hbm in Hs; injection Hs as <-; subst
                          | first [ reflexivity | progress getnorm_env ] ]
  | H : (PTree.set _ _ _) ! _ = Some _ |- _ => progress getnorm H
  | H : (PTree.empty _) ! _ = Some _ |- _ => rewrite PTree.gempty in H; discriminate H
  | H : Some _ = Some _ |- _ => injection H; clear H; intros; subst
  | H : Vptr _ _ = Vptr _ _ |- _ => injection H; clear H; intros; subst
  | H : sem_cast _ (typeof _) (typeof _) _ = Some _ |- _ => progress cbn [typeof] in H
  | H : sem_cast _ tfloat tfloat _ = Some _ |- _ => apply cast_ff_id in H; destruct H as (? & ? & ?); subst
  | H : assign_loc _ (typeof _) _ _ _ _ _ _ |- _ => progress cbn [typeof] in H
  | H : assign_loc _ ?ty _ _ _ Full _ _ |- _ => eapply (store_by_value _ ty) in H; [ | reflexivity | reflexivity ]
  end
with getnorm_env := fail.

Lemma gmp_run : forall m bx ox by_ oy bz oz t m' vres,
  eval_funcall function_entry2 ge m (Internal PD.f_get_mario_pos) [Vptr bx ox; Vptr by_ oy; Vptr bz oz] t m' vres ->
  exists fx fy fz m1 m2,
    Mem.load Mfloat32 m bm 60 = Some (Vsingle fx) /\ Mem.store Mfloat32 m bx (Ptrofs.unsigned ox) (Vsingle fx) = Some m1 /\
    Mem.load Mfloat32 m1 bm 64 = Some (Vsingle fy) /\ Mem.store Mfloat32 m1 by_ (Ptrofs.unsigned oy) (Vsingle fy) = Some m2 /\
    Mem.load Mfloat32 m2 bm 68 = Some (Vsingle fz) /\ Mem.store Mfloat32 m2 bz (Ptrofs.unsigned oz) (Vsingle fz) = Some m'.
Proof.
  intros m bx ox by_ oy bz oz t m' vres H.
  funcall_entry H.
  match goal with Hb : bind_parameter_temps _ _ _ = Some _ |- _ =>
    cbn [bind_parameter_temps PD.f_get_mario_pos fn_params] in Hb; injection Hb as <- end.
  match goal with Hf : Mem.free_list _ _ = Some _ |- _ => cbn in Hf; injection Hf as <- end.
  match goal with Hx : exec_stmt _ _ _ _ _ _ _ _ _ _ |- _ => cbn [PD.f_get_mario_pos fn_body] in Hx end.
  repeat walk1.
  repeat pn1.
  do 5 eexists. repeat split; eassumption.
Qed.

Lemma smp_run : forall m vx vy vz t m' vres,
  eval_funcall function_entry2 ge m (Internal PD.f_set_mario_pos) [vx; vy; vz] t m' vres ->
  exists fx fy fz m1 m2, vx = Vsingle fx /\ vy = Vsingle fy /\ vz = Vsingle fz /\
    Mem.store Mfloat32 m bm 60 vx = Some m1 /\ Mem.store Mfloat32 m1 bm 64 vy = Some m2 /\
    Mem.store Mfloat32 m2 bm 68 vz = Some m'.
Proof.
  intros m vx vy vz t m' vres H.
  funcall_entry H.
  match goal with Hb : bind_parameter_temps _ _ _ = Some _ |- _ =>
    cbn [bind_parameter_temps PD.f_set_mario_pos fn_params] in Hb; injection Hb as <- end.
  match goal with Hf : Mem.free_list _ _ = Some _ |- _ => cbn in Hf; injection Hf as <- end.
  match goal with Hx : exec_stmt _ _ _ _ _ _ _ _ _ _ |- _ => cbn [PD.f_set_mario_pos fn_body] in Hx end.
  repeat walk1.
  repeat pn1.
  rewrite !mpos_ofs in * by lia. cbn [Z.mul Z.add] in *.
  do 5 eexists. repeat split; eassumption.
Qed.

End PW.


Lemma raw_ofs : forall o k, 0 <= k <= 100 ->
  Ptrofs.add (Ptrofs.add (Ptrofs.add o (Ptrofs.repr 136)) (Ptrofs.repr 0))
    (Ptrofs.mul (Ptrofs.repr 4) (Ptrofs.of_ints (Int.repr k)))
  = Ptrofs.add o (Ptrofs.repr (136 + 4 * k)).
Proof.
  intros o k Hk. change (Ptrofs.repr 0) with Ptrofs.zero. rewrite Ptrofs.add_zero.
  rewrite Ptrofs.add_assoc. rewrite ofs_lin by lia. reflexivity.
Qed.

Section APD.
Variable ge : genv.
Hypothesis Hcenv : forall id co, (prog_comp_env PD.prog) ! id = Some co -> (genv_cenv ge) ! id = Some co.
Variables bm bD : block.
Hypothesis Hbm : Genv.find_symbol ge PD._gMarioStates = Some bm.
Hypothesis HbD : Genv.find_symbol ge PD._D_8032FEC0 = Some bD.
Hypothesis Hgmp : forall b, Genv.find_symbol ge PD._get_mario_pos = Some b ->
  Genv.find_funct_ptr ge b = Some (Internal PD.f_get_mario_pos).
Hypothesis Hsmp : forall b, Genv.find_symbol ge PD._set_mario_pos = Some b ->
  Genv.find_funct_ptr ge b = Some (Internal PD.f_set_mario_pos).

Ltac envget := repeat first [ rewrite PTree.gss | rewrite PTree.gso by neq ];
  first [ reflexivity | apply PTree.gempty ].

Ltac pn1 :=
  match goal with
  | H : eval_expr _ _ _ _ (Etempvar _ _) _ |- _ => apply ev_temp in H
  | H : eval_expr _ _ _ _ (Econst_int _ _) _ |- _ => apply ev_const in H; subst
  | H : eval_lvalue _ _ _ _ (Ederef (Etempvar _ _) _) _ _ _ |- _ =>
      apply lv_deref_temp in H; destruct H as (H & ?); subst
  | H : eval_expr _ _ _ _ (Ederef (Ebinop Oadd (Efield (Efield (Ederef (Etempvar _ _) _) PD._rawData _) PD._asS32 _) _ _) _) _ |- _ =>
      eapply (ev_raw ge Hcenv) in H; [ destruct H as (? & ? & ? & H) | exact (ufo_s32 ge Hcenv) | reflexivity ]
  | H : eval_expr _ _ _ _ (Ederef (Ebinop Oadd (Efield (Efield (Ederef (Etempvar _ _) _) PD._rawData _) PD._asF32 _) _ _) _) _ |- _ =>
      eapply (ev_raw ge Hcenv) in H; [ destruct H as (? & ? & ? & H) | exact (ufo_f32 ge Hcenv) | reflexivity ]
  | H : eval_lvalue _ _ _ _ (Ederef (Ebinop Oadd (Evar _ _) (Econst_int _ _) _) _) _ _ _ |- _ =>
      eapply lv_arr in H; [ destruct H as (? & ? & ?); subst | envget ]
  | H : eval_expr _ _ _ _ (Ederef (Ebinop Oadd (Evar _ _) (Econst_int _ _) _) _) _ |- _ =>
      eapply ev_arr in H; [ | envget | reflexivity ]
  | H : eval_expr _ _ _ _ (Eaddrof (Evar _ _) _) _ |- _ =>
      eapply ev_addr_local in H; [ subst | envget ]
  | H : eval_expr _ _ _ _ (Evar _ tfloat) _ |- _ =>
      eapply ev_local in H; [ | envget | reflexivity ]
  | H : eval_lvalue _ _ _ _ (Evar PD._D_8032FEC0 _) _ _ _ |- _ =>
      apply lv_gvar in H; [ destruct H as (H & ? & ?); rewrite HbD in H; injection H as <-; subst | envget ]
  | H : eval_lvalue _ _ _ _ (Evar _ tfloat) _ _ _ |- _ =>
      eapply lv_local in H; [ destruct H as (? & ? & ?); subst | envget ]
  | H : eval_expr _ _ _ _ (Ebinop Oadd _ _ tfloat) _ |- _ => clear H
  | H : eval_expr _ _ _ _ (Ebinop One _ _ _) _ |- _ =>
      apply ev_binop in H; destruct H as (? & ? & ? & ? & H); cbn [typeof] in H
  | H : eval_expr _ _ _ _ (Ecast _ _) _ |- _ =>
      apply ev_cast in H; destruct H as (? & ? & H); cbn [typeof] in H
  | H : (PTree.set _ _ _) ! _ = Some _ |- _ => progress getnorm H
  | H : (PTree.empty _) ! _ = Some _ |- _ => rewrite PTree.gempty in H; discriminate H
  | H : Some _ = Some _ |- _ => injection H; clear H; intros; subst
  | H : Vptr _ _ = Vptr _ _ |- _ => injection H; clear H; intros; subst
  | H : (_, _) = (_, _) |- _ => injection H; clear H; intros; subst
  | H : sem_cast _ (typeof _) _ _ = Some _ |- _ => progress cbn [typeof] in H
  | H : sem_cast _ _ (typeof _) _ = Some _ |- _ => progress cbn [typeof] in H
  | H : context [ set_opttemp None _ _ ] |- _ => progress cbn [set_opttemp] in H
  | H : sem_cast _ tfloat tfloat _ = Some _ |- _ => apply cast_ff_id in H; destruct H as (? & ? & ?); subst
  | H : assign_loc _ (typeof _) _ _ _ _ _ _ |- _ => progress cbn [typeof] in H
  | H : assign_loc _ ?ty _ _ _ Full _ _ |- _ => eapply (store_by_value _ ty) in H; [ | reflexivity | reflexivity ]
  | H : bool_val _ (typeof _) _ = _ |- _ => progress cbn [typeof] in H
  | H : bool_val (Vint _) _ _ = Some _ |- _ => vm_compute in H; first [ discriminate H | clear H ]
  | H : eval_funcall _ _ _ (Internal PD.f_get_mario_pos) [Vptr _ _; Vptr _ _; Vptr _ _] _ _ _ |- _ =>
      apply (gmp_run ge Hcenv bm Hbm) in H; destruct H as (? & ? & ? & ? & ? & ? & ? & ? & ? & ? & ?)
  | H : eval_funcall _ _ _ (Internal PD.f_set_mario_pos) _ _ _ _ |- _ =>
      apply (smp_run ge Hcenv bm Hbm) in H; let Ex := fresh "Ex" in let Ey := fresh "Ey" in let Ez := fresh "Ez" in destruct H as (? & ? & ? & ? & ? & Ex & Ey & Ez & ? & ? & ?); injection Ex; injection Ey; injection Ez; clear Ex Ey Ez; intros; subst
  | H : sem_cast (Vptr _ _) _ _ _ = Some _ |- _ => simpl in H; injection H; clear H; intros; subst
  | H : sem_cast (Vint _) _ _ _ = Some _ |- _ => simpl in H; injection H; clear H; intros; subst
  | H : sem_binary_operation _ _ (Vint _) _ (Vint _) _ _ = Some _ |- _ =>
      vm_compute in H; injection H; clear H; intros; subst
  end.

(* walk one statement; the rotation branch's guard (t'2) is left for later *)
Ltac pwalk :=
  match goal with
  | H : exec_stmt _ _ _ _ _ (Ssequence _ _) _ _ _ _ |- _ =>
      apply seq_inv in H; destruct H as [(? & ? & ? & ? & ? & ?) | (? & ?)]
  | H : exec_stmt _ _ _ _ _ (Sset _ _) _ _ _ _ |- _ =>
      apply set_inv in H; destruct H as (? & ? & ? & ? & ?); subst
  | H : exec_stmt _ _ _ _ _ Sskip _ _ _ _ |- _ =>
      apply skip_inv in H; destruct H as (? & ? & ?); subst
  | H : exec_stmt _ _ _ _ _ (Sassign _ _) _ _ _ _ |- _ =>
      apply assign_inv in H; destruct H as (? & ? & ? & ? & ? & ? & ? & ? & ? & ? & ?); subst
  | H : exec_stmt _ _ _ _ _ (Sifthenelse ?c _ _) _ _ _ _ |- _ =>
      lazymatch c with
      | Etempvar PD._t'2 _ => fail
      | _ => apply if_inv in H; destruct H as (? & [|] & ? & ? & H); cbv beta iota in H
      end
  | H : exec_stmt _ _ _ _ _ (Scall _ _ _) _ _ _ _ |- _ =>
      apply call_inv in H;
      destruct H as (? & ? & ? & ? & ? & ? & ? & ? & ? & ? & ? & ? & ? & ? & ?); subst
  end; try congruence.

Ltac docall :=
  match goal with
  | Hfc : eval_funcall _ _ _ ?fd _ _ _ _, Hff : Genv.find_funct _ ?vf = Some ?fd,
    Hvf : eval_expr _ _ _ _ (Evar _ _) ?vf, Hcl : classify_fun _ = fun_case_f _ _ _ |- _ =>
      cbn [typeof classify_fun] in Hcl; injection Hcl; clear Hcl; intros; subst;
      let bf := fresh "bf" in let Hsym := fresh "Hsym" in
      eapply ev_fun in Hvf; [ destruct Hvf as (bf & Hsym & ->) | envget | reflexivity ];
      rewrite Genv.find_funct_find_funct_ptr in Hff;
      first [ rewrite (Hgmp _ Hsym) in Hff | rewrite (Hsmp _ Hsym) in Hff ];
      injection Hff; clear Hff; intros; subst fd
  end.

Ltac exprlists :=
  repeat match goal with
  | H : eval_exprlist _ _ _ _ (_ :: _) _ _ |- _ => inv H
  | H : eval_exprlist _ _ _ _ nil _ _ |- _ => inv H
  end.

(* offsets to numerals *)
Ltac norm_ofs :=
  change (sizeof ge tint) with 4 in *; change (sizeof ge tshort) with 2 in *;
  change (sizeof ge tfloat) with 4 in *;
  repeat match goal with H : Mem.loadv _ _ (Vptr _ _) = _ |- _ => cbn [Mem.loadv] in H end;
  repeat match goal with H : context [ Ptrofs.add (Ptrofs.add (Ptrofs.add ?o (Ptrofs.repr 136)) (Ptrofs.repr 0)) (Ptrofs.mul (Ptrofs.repr 4) (Ptrofs.of_ints (Int.repr ?k))) ] |- _ =>
           rewrite (raw_ofs o k) in H by lia end;
  repeat match goal with H : context [ Ptrofs.unsigned (Ptrofs.add Ptrofs.zero (Ptrofs.mul (Ptrofs.repr ?c) (Ptrofs.of_ints (Int.repr ?k)))) ] |- _ =>
           rewrite (arr_ofs c k) in H by lia end;
  rewrite ?Ptrofs.unsigned_zero in *;
  cbn [Z.mul Z.add Pos.mul Pos.add Pos.add_carry Pos.succ] in *.

(* the locals' blocks, as successors of the entry's nextblock *)
Ltac nbfacts :=
  repeat match goal with Ha : Mem.alloc _ _ _ = (_, _) |- _ =>
    pose proof (Mem.alloc_result _ _ _ _ _ Ha); pose proof (Mem.nextblock_alloc _ _ _ _ _ Ha); clear Ha
  end; subst.

Ltac nbne := let E := fresh in intro E; unfold Plt, Ple in *; lia.

Ltac ldside := first [ left; assumption | left; apply not_eq_sym; assumption | left; nbne | right; left; cbn [size_chunk]; lia | right; right; cbn [size_chunk]; lia ].

Ltac ld1 H :=
  match type of H with
  | Mem.load _ ?M _ _ = _ =>
      match goal with Hs : Mem.store _ _ _ _ _ = Some M |- _ =>
        first [ rewrite (Mem.load_store_other _ _ _ _ _ _ Hs) in H by ldside
              | rewrite (Mem.load_store_same _ _ _ _ _ _ Hs) in H ]
      end
  end.

Ltac ldall := repeat match goal with H : Mem.load _ _ _ _ = Some _ |- _ => ld1 H end.

Ltac ldgoal := repeat match goal with |- Mem.load _ ?M _ _ = _ =>
  match goal with Hs : Mem.store _ _ _ _ _ = Some M |- _ =>
    rewrite (Mem.load_store_other _ _ _ _ _ _ Hs) by ldside end end.

Ltac ldmerge := repeat match goal with
  | H1 : Mem.load ?c ?M ?b ?z = Some ?v1, H2 : Mem.load ?c ?M ?b ?z = Some ?v2 |- _ =>
      rewrite H1 in H2; injection H2; clear H2; intros; subst
  end.

Ltac sopt Hs := first
  [ eapply sop_D; [ | exact Hs ]; intros ? ? ?; discriminate
  | eapply sop_xz; [ | exact Hs ]; first [ left; reflexivity | right; reflexivity ]
  | eapply sop_y; [ | exact Hs ]; ldgoal; eassumption
  | eapply sop_local; [ | exact Hs ]; unfold Plt, Ple in *; lia ].

Ltac sbuild :=
  match goal with
  | |- sruns _ _ _ ?M ?M => apply sr_refl
  | Hs : Mem.store _ ?M _ _ _ = Some ?M' |- sruns _ _ _ ?M _ =>
      apply (sr_step _ _ _ M M' _); [ sopt Hs | sbuild ]
  end.

Theorem apd_eff : forall m pb po t m' vres,
  Plt bm (Mem.nextblock m) -> Plt bD (Mem.nextblock m) -> bm <> bD ->
  (forall k, In k [35; 36; 37] ->
     Mem.loadv Mint32 m (Vptr pb (Ptrofs.add po (Ptrofs.repr (136 + 4 * k)))) = Some (Vint Int.zero)) ->
  eval_funcall function_entry2 ge m (Internal PD.f_apply_platform_displacement)
    [Vint (Int.repr 1); Vptr pb po] t m' vres ->
  plat_eff bm bD m m'.
Proof.
  intros m pb po t m' vres Vbm VbD Nbm Hst H.
  inv H.
  match goal with He : function_entry2 _ _ _ _ _ _ _ |- _ => inv He end.
  match goal with Ha : alloc_variables _ _ _ _ _ ?m1, Hf : Mem.free_list ?m3 _ = Some _,
                  Hn : list_norepet (var_names (fn_vars _)) |- _ =>
    pose proof Ha as Hav;
    refine (plat_eff_frame ge bm bD m _ _ m1 m3 m' Ha Hn _ Hf Vbm VbD Nbm); clear Hf
  end.
  assert (Vpb : Plt pb (Mem.nextblock m)).
  { pose proof (Hst 35 ltac:(cbn; tauto)) as L. cbn [Mem.loadv] in L.
    eapply Mem.valid_access_valid_block.
    eapply Mem.valid_access_implies; [ exact (Mem.load_valid_access _ _ _ _ _ L) | constructor ]. }
  match goal with Ha : alloc_variables _ _ _ _ _ ?m1 |- _ =>
    assert (Hst1 : forall k, In k [35; 36; 37] ->
      Mem.load Mint32 m1 pb (Ptrofs.unsigned (Ptrofs.add po (Ptrofs.repr (136 + 4 * k)))) = Some (Vint Int.zero))
    by (intros k Hk; rewrite (proj2 (av_old ge _ _ _ _ _ Hav) _ _ _ Vpb); exact (Hst k Hk))
  end.
  pose proof (Hst1 35 ltac:(cbn; tauto)) as S35.
  pose proof (Hst1 36 ltac:(cbn; tauto)) as S36.
  pose proof (Hst1 37 ltac:(cbn; tauto)) as S37.
  clear Hst Hst1.
  match goal with Ha : alloc_variables _ _ _ _ _ _ |- _ =>
    cbn [PD.f_apply_platform_displacement fn_vars] in Ha end.
  repeat match goal with Ha : alloc_variables _ _ _ (_ :: _) _ _ |- _ => inv Ha end.
  match goal with Ha : alloc_variables _ _ _ [] _ _ |- _ => inv Ha end.
  match goal with Hb : bind_parameter_temps _ _ _ = Some _ |- _ =>
    cbn [bind_parameter_temps PD.f_apply_platform_displacement fn_params] in Hb; injection Hb as <- end.
  match goal with Hx : exec_stmt _ _ _ _ _ _ _ _ _ _ |- _ => cbn [PD.f_apply_platform_displacement fn_body] in Hx end.
  repeat pwalk.
  all: repeat docall.
  all: exprlists.
  all: repeat pn1.
  all: do 2 (repeat pn1; norm_ofs; nbfacts; ldall; ldmerge).
  all: try (match goal with H : exec_stmt _ _ _ _ _ (Sifthenelse (Etempvar PD._t'2 _) _ _) _ _ _ _ |- _ =>
         apply if_inv in H; destruct H as (? & [|] & ? & ? & H); cbv beta iota in H end).
  all: repeat pn1.
  all: repeat pwalk.
  all: do 2 (repeat pn1; norm_ofs; nbfacts; ldall; ldmerge).

  all: try sbuild.
Qed.

End APD.

Section OUT.
Variable ge : genv.
Hypothesis Hcenv : forall id co, (prog_comp_env PD.prog) ! id = Some co -> (genv_cenv ge) ! id = Some co.
Variables bm bD bp : block.
Hypothesis Hbm : Genv.find_symbol ge PD._gMarioStates = Some bm.
Hypothesis HbD : Genv.find_symbol ge PD._D_8032FEC0 = Some bD.
Hypothesis Hgmp : forall b, Genv.find_symbol ge PD._get_mario_pos = Some b ->
  Genv.find_funct_ptr ge b = Some (Internal PD.f_get_mario_pos).
Hypothesis Hsmp : forall b, Genv.find_symbol ge PD._set_mario_pos = Some b ->
  Genv.find_funct_ptr ge b = Some (Internal PD.f_set_mario_pos).
Hypothesis Hapd : forall b, Genv.find_symbol ge PD._apply_platform_displacement = Some b ->
  Genv.find_funct_ptr ge b = Some (Internal PD.f_apply_platform_displacement).
Hypothesis Hbp : Genv.find_symbol ge PD._gMarioPlatform = Some bp.

Ltac o1 :=
  match goal with
  | H : eval_expr _ _ _ _ (Etempvar _ _) _ |- _ => apply ev_temp in H
  | H : eval_expr _ _ _ _ (Econst_int _ _) _ |- _ => apply ev_const in H; subst
  | H : eval_expr _ _ _ _ (Evar PD._gMarioPlatform _) _ |- _ =>
      eapply ev_gvar in H; [ destruct H as (? & ? & H) | apply PTree.gempty | reflexivity ]
  | H : eval_expr _ _ _ _ (Ebinop One _ _ _) _ |- _ =>
      apply ev_binop in H; destruct H as (? & ? & ? & ? & H); cbn [typeof] in H
  | H : eval_expr _ _ _ _ (Ecast _ _) _ |- _ =>
      apply ev_cast in H; destruct H as (? & ? & H); cbn [typeof] in H
  | H : (PTree.set _ _ _) ! _ = Some _ |- _ => progress getnorm H
  | H : Some _ = Some _ |- _ => injection H; clear H; intros; subst
  | H : bool_val _ (typeof _) _ = _ |- _ => progress cbn [typeof] in H
  | H : bool_val (Vint _) _ _ = Some _ |- _ => vm_compute in H; first [ discriminate H | clear H ]
  end.

Theorem ampd_eff : forall m t m' vres,
  Plt bm (Mem.nextblock m) -> Plt bD (Mem.nextblock m) -> bm <> bD ->
  (forall v, Mem.load Mint32 m bp 0 = Some v ->
     v = Vint Int.zero
     \/ exists pb po, v = Vptr pb po /\ forall k, In k [35; 36; 37] ->
          Mem.loadv Mint32 m (Vptr pb (Ptrofs.add po (Ptrofs.repr (136 + 4 * k)))) = Some (Vint Int.zero)) ->
  eval_funcall function_entry2 ge m (Internal PD.f_apply_mario_platform_displacement) [] t m' vres ->
  plat_eff bm bD m m'.
Proof.
  intros m t m' vres Vbm VbD Nbm Hpl H.
  inv H.
  match goal with He : function_entry2 _ _ _ _ _ _ _ |- _ => inv He end.
  match goal with Ha : alloc_variables _ _ _ _ _ _ |- _ =>
    cbn [PD.f_apply_mario_platform_displacement fn_vars] in Ha; inv Ha end.
  match goal with Hb : bind_parameter_temps _ _ _ = Some _ |- _ =>
    cbn [bind_parameter_temps PD.f_apply_mario_platform_displacement fn_params] in Hb; injection Hb as <- end.
  match goal with Hf : Mem.free_list _ _ = Some _ |- _ =>
    unfold blocks_of_env in Hf; cbn in Hf; injection Hf as <- end.
  match goal with Hx : exec_stmt _ _ _ _ _ _ _ _ _ _ |- _ =>
    cbn [PD.f_apply_mario_platform_displacement fn_body] in Hx end.
  repeat walk1.
  all: try (apply plat_eff_refl).
  all: repeat o1.
  all: match goal with Hs : Genv.find_symbol _ PD._gMarioPlatform = Some ?x, Hl : Mem.loadv _ _ (Vptr ?x _) = Some ?v |- _ =>
         rewrite Hbp in Hs; injection Hs as <-;
         assert (Lp : Mem.load Mint32 m1 bp 0 = Some v) by exact Hl; clear Hl;
         destruct (Hpl _ Lp) as [-> | (pb & po & -> & Hst)]
       end.
  - (* NULL: the guard is false *)
    exfalso.
    repeat match goal with
    | H : sem_cast (Vint _) _ _ _ = Some _ |- _ => vm_compute in H; injection H; clear H; intros; subst
    | H : sem_binary_operation _ _ (Vint _) _ (Vint _) _ _ = Some _ |- _ =>
        vm_compute in H; injection H; clear H; intros; subst
    | H : bool_val (Vint _) _ _ = Some _ |- _ => vm_compute in H; discriminate H
    end.
  - (* the call *)
    match goal with Hx : exec_stmt _ _ _ _ _ (Scall _ _ _) _ _ _ _ |- _ =>
      apply call_inv in Hx;
      destruct Hx as (tyargs & tyres & cconv & vf & vargs & fd & vr & Hcl & Hvf & Hal & Hff & Hty & Hfc & _ & _)
    end.
    cbn [typeof classify_fun] in Hcl. injection Hcl as <- <- <-.
    eapply ev_fun in Hvf; [ destruct Hvf as (bf & Hsym & ->) | apply PTree.gempty | reflexivity ].
    rewrite Genv.find_funct_find_funct_ptr in Hff. rewrite (Hapd _ Hsym) in Hff.
    injection Hff as <-.
    repeat match goal with
    | H : eval_exprlist _ _ _ _ (_ :: _) _ _ |- _ => inv H
    | H : eval_exprlist _ _ _ _ nil _ _ |- _ => inv H
    end.
    repeat o1.
    repeat match goal with
    | H : sem_cast (Vint _) tint tuint _ = Some _ |- _ => vm_compute in H; injection H; clear H; intros; subst
    | H : sem_cast (Vptr _ _) _ _ _ = Some _ |- _ => apply cast_ptr_id in H; subst
    | H : sem_cast _ (typeof _) _ _ = Some _ |- _ => progress cbn [typeof] in H
    end.
    exact (apd_eff ge Hcenv bm bD Hbm HbD Hgmp Hsmp m1 pb po _ m2 _ Vbm VbD Nbm Hst Hfc).
Qed.
End OUT.
