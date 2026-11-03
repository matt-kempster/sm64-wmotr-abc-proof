(* ====================================================================== *)
(* spine (via BhvStep's spawn rows): OBJECTS -- callees that write only   *)
(* through their first parameter, a fresh slot: the slot walker (fx) run  *)
(* over a whole function body (fcall_fx), and obj_copy_pos_and_angle      *)
(* (object_helpers.c: obj_copy_pos + obj_copy_angle) on a fresh slot.     *)
(* ====================================================================== *)

From Coq Require Import ZArith List Lia Bool.
From compcert Require Import Coqlib Maps AST Integers Floats Values Memory
  Globalenvs Ctypes Cop Clight ClightBigstep Clightdefs Events Errors.
From SM64.Generated Require object_helpers.
From SM64.Proofs Require MarioModel.MathGeomBodies.
From SM64.Proofs.WMotRRequiresA Require Import ObjWorld ObjRing ObjAlloc ObjCreate ObjMake ObjGeo.
From SM64.Proofs.WMotRRequiresA Require ObjSelf RenderAnim ObjLoop.

Import ListNotations.
Local Open Scope Z_scope.
Local Transparent Archi.ptr64.

Module RA := RenderAnim.
Module OH := SM64.Generated.object_helpers.

Definition CEH : composite_env := prog_comp_env OH.prog.

(* the walker over a whole body, its None-ness checked on [] *)
Definition cfx (f : function) (F : list fact) : list fact :=
  match fx CEH OH._dst (fn_body f) F with Some F' => F' | None => [] end.

Lemma cfx_ok : forall f F, fx CEH OH._dst (fn_body f) [] <> None ->
  fx CEH OH._dst (fn_body f) F = Some (cfx f F).
Proof.
  intros f F H. unfold cfx. destruct (fx CEH OH._dst (fn_body f) F) eqn:E; [ reflexivity | ].
  exfalso. apply H. exact (fx_none _ _ _ _ _ E).
Qed.

Lemma cp_some : fx CEH OH._dst (fn_body OH.f_obj_copy_pos) [] <> None.
Proof. vm_compute. discriminate. Qed.
Lemma ca_some : fx CEH OH._dst (fn_body OH.f_obj_copy_angle) [] <> None.
Proof. vm_compute. discriminate. Qed.

(* what survives obj_copy_pos_and_angle on the slot: the copied rawData
   words (position, face and move angles) killed *)
Definition cpa_facts (F : list fact) : list fact :=
  cfx OH.f_obj_copy_angle (cfx OH.f_obj_copy_pos F).

Section FC.
  Variable ge : genv.
  Variables pool gB : block.
  Hypothesis Hpool : Genv.find_symbol ge ObjSelf.POOL = Some pool.
  Hypothesis HgB : Genv.find_symbol ge ObjSelf.GCO = Some gB.
  Variable k : Z.
  Hypothesis Hk : 0 <= k < NSLOT.
  Notation b0 := (k * OSZ).
  Notation ov := (slot_v pool k).

  (* A CALLEE WALKED WHOLE: first parameter = slot k, body walkable *)
  Lemma fcall_fx : forall ce (Hce : ObjSelf.cext ge ce) f x ty rest vs m t m' vr F F',
    fn_vars f = [] -> fn_params f = (x, ty) :: rest -> ~ In x (var_names rest) ->
    fx ce x (fn_body f) F = Some F' ->
    eval_funcall function_entry2 ge m (Internal f) (ov :: vs) t m' vr ->
    facts m pool b0 ov F ->
    Mem.unchanged_on (KP pool b0) m m' /\ facts m' pool b0 ov F'.
  Proof.
    intros ce Hce f x ty rest vs m t m' vr F F' Hv Hp Hn Hf H HF.
    destruct (fcall_inv0 ge f m _ t m' vr Hv H) as (le & le' & out & Hbd & Hx & _).
    rewrite Hp in Hbd.
    pose proof (MarioModel.MathGeomBodies.bind_parameter_temps_head x ty rest _ vs _ le Hn Hbd) as Hle.
    destruct (fx_sound ge pool gB Hpool HgB ce Hce x k Hk _ F F' Hf _ _ _ _ _ _ Hx Hle HF) as (_ & _ & HF' & U).
    exact (conj U HF').
  Qed.

  Hypothesis Hceh : ObjSelf.cext ge CEH.
  Hypothesis Hcp : forall b fd, Genv.find_symbol ge OH._obj_copy_pos = Some b ->
    Genv.find_funct ge (Vptr b Ptrofs.zero) = Some fd -> fd = Internal OH.f_obj_copy_pos.
  Hypothesis Hca : forall b fd, Genv.find_symbol ge OH._obj_copy_angle = Some b ->
    Genv.find_funct ge (Vptr b Ptrofs.zero) = Some fd -> fd = Internal OH.f_obj_copy_angle.

  Lemma dst_call : forall f fid le m t le' m' out F src,
    fid = OH._obj_copy_pos /\ f = OH.f_obj_copy_pos \/ fid = OH._obj_copy_angle /\ f = OH.f_obj_copy_angle ->
    le ! OH._dst = Some ov -> facts m pool b0 ov F ->
    exec_stmt function_entry2 ge empty_env le m
      (Scall None (Evar fid (Tfunction [tptr (Tstruct OH._Object noattr); tptr (Tstruct OH._Object noattr)] tvoid cc_default))
         [Etempvar OH._dst (tptr (Tstruct OH._Object noattr)); src]) t le' m' out ->
    le' = le /\ out = Out_normal /\ Mem.unchanged_on (KP pool b0) m m' /\ facts m' pool b0 ov (cfx f F).
  Proof.
    intros f fid le m t le' m' out F src Hfid Hx HF H.
    apply RA.call_inv in H as (tyargs & tyres & cc & vf & vargs & fd & vres & Hcf & Evf & Eal & Hff & _ & Hc & -> & ->).
    cbn in Hcf. injection Hcf as <- <- <-.
    match type of Evf with eval_expr _ _ _ _ (Evar _ ?ty) _ =>
      destruct (RA.ev_fun ge empty_env _ _ _ ty vf (PTree.gempty _ _) eq_refl Evf) as (bf & Hsf & ->) end.
    destruct (ObjLoop.exl2 _ _ _ _ _ _ _ _ Eal) as (ta1 & tb1 & u1 & u2 & x1 & x2 & Ea2 & -> & Eva & Cca & _ & _).
    injection Ea2 as <- <-.
    apply RA.ev_temp in Eva. rewrite Hx in Eva. injection Eva as <-.
    cbn [typeof] in Cca. apply RA.cast_ptr_id in Cca. subst x1.
    destruct Hfid as [(-> & ->) | (-> & ->)].
    - rewrite (Hcp bf fd Hsf Hff) in Hc.
      destruct (fcall_fx CEH Hceh OH.f_obj_copy_pos OH._dst _ _ _ m _ _ _ F _ eq_refl eq_refl
                  ltac:(cbn; intros [E | []]; discriminate E) (cfx_ok _ F cp_some) Hc HF) as (U & HF').
      refine (conj eq_refl (conj eq_refl (conj U HF'))).
    - rewrite (Hca bf fd Hsf Hff) in Hc.
      destruct (fcall_fx CEH Hceh OH.f_obj_copy_angle OH._dst _ _ _ m _ _ _ F _ eq_refl eq_refl
                  ltac:(cbn; intros [E | []]; discriminate E) (cfx_ok _ F ca_some) Hc HF) as (U & HF').
      refine (conj eq_refl (conj eq_refl (conj U HF'))).
  Qed.

  (* OBJ_COPY_POS_AND_ANGLE(slot k, src) *)
  Theorem cpa_ok : forall src m t m' vr F,
    eval_funcall function_entry2 ge m (Internal OH.f_obj_copy_pos_and_angle) [ov; src] t m' vr ->
    facts m pool b0 ov F ->
    Mem.unchanged_on (KP pool b0) m m' /\ facts m' pool b0 ov (cpa_facts F).
  Proof.
    intros src m t m' vr F H HF.
    destruct (fcall_inv0 ge OH.f_obj_copy_pos_and_angle m _ t m' vr eq_refl H) as (le & le' & out & Hbd & Hx & _).
    cbn [fn_params OH.f_obj_copy_pos_and_angle bind_parameter_temps] in Hbd. injection Hbd as Hle.
    assert (Hd : le ! OH._dst = Some ov).
    { rewrite <- Hle. rewrite PTree.gso by RA.neq. apply PTree.gss. }
    cbn [fn_body OH.f_obj_copy_pos_and_angle] in Hx.
    apply RA.seq_inv in Hx as [(t1 & le1 & m1 & t2 & X1 & X2) | (X1 & Hne)].
    2:{ apply RA.call_inv in X1 as (_ & _ & _ & _ & _ & _ & _ & _ & _ & _ & _ & _ & _ & _ & E). contradiction. }
    destruct (dst_call OH.f_obj_copy_pos _ le m t1 le1 m1 Out_normal F _ (or_introl (conj eq_refl eq_refl)) Hd HF X1)
      as (-> & _ & U1 & HF1).
    destruct (dst_call OH.f_obj_copy_angle _ le m1 t2 le' m' out _ _ (or_intror (conj eq_refl eq_refl)) Hd HF1 X2)
      as (_ & _ & U2 & HF2).
    exact (conj (Mem.unchanged_on_trans _ _ _ _ U1 U2) HF2).
  Qed.
End FC.
