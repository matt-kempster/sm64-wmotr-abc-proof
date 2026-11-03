(* ====================================================================== *)
(* spine (via BhvStep's row 55): OBJECTS -- SPAWN_WATER_DROPLET          *)
(* (behavior_script.c bhv_cmd_spawn_water_droplet), run by its real body: *)
(*   params = gCurBhvCommand[1];                                          *)
(*   spawn_water_droplet(gCurrentObject, params) (object_helpers.c):      *)
(*     newObj = spawn_object(parent, params->model, params->behavior)     *)
(*       (= spawn_object_at_origin + obj_copy_pos_and_angle);             *)
(*     the flag-gated tail: random yaw (random_u16 / random_f32_around_   *)
(*     zero), posY = find_water_level(..), obj_translate_x(y)z_random,    *)
(*     forwardVel / velY from random_float, obj_scale;                    *)
(*   gCurBhvCommand += 2; return BHV_PROC_CONTINUE.                       *)
(* The tail is walked by fxc: ObjCreate's slot walker (fx) plus calls --  *)
(* "seed" callees that change nothing but gRandomSeed16 (random_u16,     *)
(* random_float, random_f32_around_zero, find_water_level), and slot     *)
(* callees whose own body is walked (obj_scale, obj_translate_*_random). *)
(* Every flag branch is walked, so the params' flags need not be known.  *)
(* ====================================================================== *)

From Coq Require Import ZArith List Lia Bool.
From compcert Require Import Coqlib Maps AST Integers Floats Values Memory
  Globalenvs Ctypes Cop Clight ClightBigstep Clightdefs Events Errors.
From compcert Require Linking.
From SM64.Generated Require graph_node spawn_object object_list_processor area math_util memory
  object_helpers behavior_script surface_collision.
From SM64.Proofs Require Import SymbolicLinking LinkedTwelve RealFrameLinked.
From SM64.Proofs.WMotRRequiresA Require Import ObjWorld ObjRing ObjAlloc ObjCreate ObjMake ObjGeo ObjOrigin
  ObjCopy ObjChild.
From SM64.Proofs.WMotRRequiresA Require ObjSelf RenderAnim ObjLoop.
From SM64.Proofs Require MarioModel.MathGeomBodies.
From SM64.Proofs.MarioModel Require SpawnBodies.

Import ListNotations.
Local Open Scope Z_scope.
Local Transparent Archi.ptr64.

Module RA := RenderAnim.
Module OH := SM64.Generated.object_helpers.
Module BS := SM64.Generated.behavior_script.
Module SC := SM64.Generated.surface_collision.
Module SO := SM64.Generated.spawn_object.

(* ---------------------------------------------------------------------- *)
(* 1. The walker with calls.                                               *)
(* ---------------------------------------------------------------------- *)
Section FXC.
  Variable ce : composite_env.
  Variable x : ident.
  Variable R : list ident.
  Variable scf : ident -> list fact -> option (list fact).

  Fixpoint noret (s : statement) : bool :=
    match s with
    | Sreturn _ => false
    | Ssequence a b | Sifthenelse _ a b => noret a && noret b
    | _ => true
    end.

  Fixpoint fxc (s : statement) (F : list fact) : option (list fact) :=
    match s with
    | Sskip => Some F
    | Sassign l r =>
        match ObjSelf.lad ce [x] l, access_mode (typeof l) with
        | Some d, By_value ch =>
            if wr_ok d (size_chunk ch) then
              Some (match sval x r (typeof l) ch with
                    | Some s0 => (ch, d, s0) :: kill d (size_chunk ch) F
                    | None => kill d (size_chunk ch) F
                    end)
            else None
        | _, _ => None
        end
    | Sset y _ => if Pos.eqb y x then None else Some F
    | Ssequence a b =>
        if noret a then match fxc a F with Some F1 => fxc b F1 | None => None end else None
    | Sifthenelse _ a b =>
        match fxc a F, fxc b F with Some Fa, Some Fb => Some (inter Fa Fb) | _, _ => None end
    | Scall (Some y) (Evar g (Tfunction _ _ _)) _ =>
        if Pos.eqb y x then None else if existsb (Pos.eqb g) R then Some F else None
    | Scall None (Evar g (Tfunction (Tpointer _ _ :: _) _ _)) (Etempvar y (Tpointer _ _) :: _) =>
        if Pos.eqb y x then scf g F else None
    | Sreturn _ => Some F
    | _ => None
    end.
End FXC.

Definition SEEDC : list ident :=
  [BS._random_u16; BS._random_float; OH._random_f32_around_zero; OH._find_water_level].

(* level 0: the slot callees' own bodies (no slot callees inside); their
   first parameter is _obj *)
Definition scf0 : ident -> list fact -> option (list fact) := fun _ _ => None.
Definition wbody (f : function) (F : list fact) : option (list fact) :=
  fxc CEH OH._obj SEEDC scf0 (fn_body f) F.
(* level 1: the slot callees spawn_water_droplet calls *)
Definition scf1 (g : ident) (F : list fact) : option (list fact) :=
  if Pos.eqb g OH._obj_scale then wbody OH.f_obj_scale F
  else if Pos.eqb g OH._obj_translate_xz_random then wbody OH.f_obj_translate_xz_random F
  else if Pos.eqb g OH._obj_translate_xyz_random then wbody OH.f_obj_translate_xyz_random F
  else None.

(* the walk's None-ness does not depend on the facts *)
Lemma fxc_indep : forall ce x R scf, (forall g F G, scf g F = None -> scf g G = None) ->
  forall s F G, fxc ce x R scf s F = None -> fxc ce x R scf s G = None.
Proof.
  intros ce x R scf Hs. induction s; intros F G H; cbn [fxc] in H |- *; try reflexivity; try discriminate H.
  - (* assign *)
    revert H. destruct (ObjSelf.lad ce [x] e) as [d|]; [ | intros _; reflexivity ].
    destruct (access_mode (typeof e)); try (intros _; reflexivity).
    destruct (wr_ok d (size_chunk m)); [ intros H; discriminate H | intros _; reflexivity ].
  - (* set *)
    revert H. destruct (Pos.eqb i x); [ intros _; reflexivity | intros H; discriminate H ].
  - (* call *)
    revert H.
    repeat match goal with |- context [match ?c with _ => _ end] => destruct c end;
      intros H; first [ reflexivity | discriminate H | exact (Hs _ _ _ H) ].
  - (* sequence *)
    revert H. destruct (noret s1); [ | intros _; reflexivity ].
    destruct (fxc ce x R scf s1 F) as [F1|] eqn:E1; destruct (fxc ce x R scf s1 G) as [G1|] eqn:E2;
      intros H; try reflexivity.
    + exact (IHs2 F1 G1 H).
    + rewrite (IHs1 F G E1) in E2. discriminate E2.
  - (* if *)
    revert H.
    destruct (fxc ce x R scf s1 F) as [Fa|] eqn:Ea; destruct (fxc ce x R scf s2 F) as [Fb|] eqn:Eb;
    destruct (fxc ce x R scf s1 G) as [Ga|] eqn:Ea'; destruct (fxc ce x R scf s2 G) as [Gb|] eqn:Eb';
      intros H; try reflexivity; try discriminate H.
    all: first [ rewrite (IHs1 F G Ea) in Ea'; discriminate Ea' | rewrite (IHs2 F G Eb) in Eb'; discriminate Eb' ].
Qed.

Lemma scf0_indep : forall g F G, scf0 g F = None -> scf0 g G = None.
Proof. reflexivity. Qed.
Lemma scf1_indep : forall g F G, scf1 g F = None -> scf1 g G = None.
Proof.
  intros g F G. unfold scf1, wbody.
  destruct (Pos.eqb g OH._obj_scale); [ apply fxc_indep; exact scf0_indep | ].
  destruct (Pos.eqb g OH._obj_translate_xz_random); [ apply fxc_indep; exact scf0_indep | ].
  destruct (Pos.eqb g OH._obj_translate_xyz_random); [ apply fxc_indep; exact scf0_indep | ].
  intros _; reflexivity.
Qed.

(* ---------------------------------------------------------------------- *)
(* 2. Soundness.                                                           *)
(* ---------------------------------------------------------------------- *)
Lemma cast_pp2 : forall b o a1 t1 a2 t2 m v,
  sem_cast (Vptr b o) (Tpointer a1 t1) (Tpointer a2 t2) m = Some v -> v = Vptr b o.
Proof. intros b o a1 t1 a2 t2 m v H. cbn in H. injection H as <-. reflexivity. Qed.

Section SOUND.
  Variable ge : genv.
  Variables pool gB sb : block.
  Hypothesis Hpool : Genv.find_symbol ge ObjSelf.POOL = Some pool.
  Hypothesis HgB : Genv.find_symbol ge ObjSelf.GCO = Some gB.
  Hypothesis Hsp : sb <> pool.
  Variable ce : composite_env.
  Hypothesis Hce : ObjSelf.cext ge ce.
  Variable k : Z.
  Hypothesis Hk : 0 <= k < NSLOT.
  Notation b0 := (k * OSZ).
  Notation ov := (slot_v pool k).
  Notation xs := (exec_stmt function_entry2 ge empty_env).

  (* what a walked statement keeps: KP, and the seed's block *)
  Definition KPs (b : block) (z : Z) : Prop := KP pool b0 b z /\ b <> sb.

  Definition seed_fn (fd : fundef) : Prop :=
    forall m vs t m' vr, eval_funcall function_entry2 ge m fd vs t m' vr ->
      Mem.unchanged_on (fun b _ => b <> sb) m m'.
  Definition seed_sym (g : ident) : Prop :=
    forall b fd, Genv.find_symbol ge g = Some b -> Genv.find_funct ge (Vptr b Ptrofs.zero) = Some fd -> seed_fn fd.

  Variable R : list ident.
  Hypothesis HR : forall g, In g R -> seed_sym g.
  Variable scf : ident -> list fact -> option (list fact).
  Hypothesis Hsc : forall g F F' b fd m vs t m' vr, scf g F = Some F' ->
    Genv.find_symbol ge g = Some b -> Genv.find_funct ge (Vptr b Ptrofs.zero) = Some fd ->
    eval_funcall function_entry2 ge m fd (ov :: vs) t m' vr -> facts m pool b0 ov F ->
    Mem.unchanged_on KPs m m' /\ facts m' pool b0 ov F'.

  Lemma kp_kps : forall m m', Mem.unchanged_on (KP pool b0) m m' -> Mem.unchanged_on KPs m m'.
  Proof. intros m m' U. exact (Mem.unchanged_on_implies _ _ _ _ U (fun b z Hz _ => proj1 Hz)). Qed.

  Lemma fxc_sound : forall x s F F', fxc ce x R scf s F = Some F' ->
    forall le m t le' m' out, xs le m s t le' m' out ->
    le ! x = Some ov -> facts m pool b0 ov F ->
    (out = Out_normal \/ exists r, out = Out_return r) /\ (noret s = true -> out = Out_normal)
    /\ le' ! x = Some ov /\ facts m' pool b0 ov F' /\ Mem.unchanged_on KPs m m'.
  Proof.
    intros x. induction s; intros F F' Hf le m t0 le' m' out H Hx HF; cbn [fxc] in Hf; try discriminate Hf.
    - (* skip *)
      assert (Hf' : fx ce x Sskip F = Some F') by exact Hf.
      destruct (fx_sound ge pool gB Hpool HgB ce Hce x k Hk _ F F' Hf' _ _ _ _ _ _ H Hx HF) as (-> & Hx' & HF' & U).
      exact (conj (or_introl eq_refl) (conj (fun _ => eq_refl) (conj Hx' (conj HF' (kp_kps _ _ U))))).
    - (* assign *)
      assert (Hf' : fx ce x (Sassign e e0) F = Some F') by exact Hf.
      destruct (fx_sound ge pool gB Hpool HgB ce Hce x k Hk _ F F' Hf' _ _ _ _ _ _ H Hx HF) as (-> & Hx' & HF' & U).
      exact (conj (or_introl eq_refl) (conj (fun _ => eq_refl) (conj Hx' (conj HF' (kp_kps _ _ U))))).
    - (* set *)
      assert (Hf' : fx ce x (Sset i e) F = Some F') by exact Hf.
      destruct (fx_sound ge pool gB Hpool HgB ce Hce x k Hk _ F F' Hf' _ _ _ _ _ _ H Hx HF) as (-> & Hx' & HF' & U).
      exact (conj (or_introl eq_refl) (conj (fun _ => eq_refl) (conj Hx' (conj HF' (kp_kps _ _ U))))).
    - (* call *)
      destruct o as [y|].
      + destruct e as [ | | | | g ty | | | | | | | | | ]; try discriminate Hf.
        destruct ty; try discriminate Hf.
        destruct (Pos.eqb y x) eqn:Ey; [ discriminate Hf | ].
        destruct (existsb (Pos.eqb g) R) eqn:Eg; [ injection Hf as <- | discriminate Hf ].
        apply existsb_exists in Eg as (g' & Hg' & Eg). apply Pos.eqb_eq in Eg. subst g'.
        apply RA.call_inv in H as (tya & tyr & cc & vf & vargs & fd & vres & Hcf & Evf & Eal & Hff & _ & Hc & -> & ->).
        match type of Evf with eval_expr _ _ _ _ (Evar _ ?ty) _ =>
          destruct (RA.ev_fun ge empty_env m le g ty vf (PTree.gempty _ _) eq_refl Evf) as (bf & Hs & ->) end.
        pose proof (HR g Hg' bf fd Hs Hff m vargs t0 m' vres Hc) as U.
        split; [ left; reflexivity | split; [ reflexivity | split; [ | split ] ] ].
        * cbn [set_opttemp]. rewrite PTree.gso; [ exact Hx | ]. intros E. subst y. rewrite Pos.eqb_refl in Ey. discriminate Ey.
        * apply (facts_unch _ m m' pool b0 ov F U); [ | exact HF ].
          intros _ _ _ _ i _. exact (not_eq_sym Hsp).
        * exact (Mem.unchanged_on_implies _ _ _ _ U (fun b z Hz _ => proj2 Hz)).
      + destruct e as [ | | | | g ty | | | | | | | | | ]; try discriminate Hf.
        destruct ty as [ | | | | | | targs tres cc | | ]; try discriminate Hf.
        destruct targs as [| ta targs]; try discriminate Hf.
        destruct ta; try discriminate Hf.
        destruct l as [| a1 al1]; try discriminate Hf.
        destruct a1; try discriminate Hf.
        destruct t; try discriminate Hf.
        destruct (Pos.eqb i x) eqn:Ei; [ | discriminate Hf ]. apply Pos.eqb_eq in Ei. subst i.
        apply RA.call_inv in H as (tya & tyr & cc' & vf & vargs & fd & vres & Hcf & Evf & Eal & Hff & _ & Hc & -> & ->).
        cbn in Hcf. injection Hcf as <- <- <-.
        match type of Evf with eval_expr _ _ _ _ (Evar _ ?ty) _ =>
          destruct (RA.ev_fun ge empty_env m le g ty vf (PTree.gempty _ _) eq_refl Evf) as (bf & Hs & ->) end.
        inversion Eal as [ | e1 el1 ty1 tys1 v0 v1 vl Ev0 Cv0 Erest ]; subst.
        apply RA.ev_temp in Ev0. rewrite Hx in Ev0. injection Ev0 as <-.
        unfold slot_v in Cv0. cbn [typeof] in Cv0. apply cast_pp2 in Cv0. subst v1.
        destruct (Hsc g F F' bf fd m vl t0 m' vres Hf Hs Hff Hc HF) as (U & HF').
        split; [ left; reflexivity | split; [ reflexivity | split; [ exact Hx | split; [ exact HF' | exact U ] ] ] ].
    - (* sequence *)
      destruct (noret s1) eqn:En1; [ | discriminate Hf ].
      destruct (fxc ce x R scf s1 F) as [F1|] eqn:E1; [ | discriminate Hf ].
      apply RA.seq_inv in H as [(t1 & le1 & m1 & t2 & H1 & H2) | (H1 & Hn)].
      + destruct (IHs1 F F1 E1 _ _ _ _ _ _ H1 Hx HF) as (_ & _ & Hx1 & HF1 & U1).
        destruct (IHs2 F1 F' Hf _ _ _ _ _ _ H2 Hx1 HF1) as (Ho & Hn2 & Hx2 & HF2 & U2).
        split; [ exact Ho | split; [ | split; [ exact Hx2 | split; [ exact HF2 | exact (Mem.unchanged_on_trans _ _ _ _ U1 U2) ] ] ] ].
        cbn [noret]. intros Hn. apply andb_prop in Hn as [_ Hn]. exact (Hn2 Hn).
      + destruct (IHs1 F F1 E1 _ _ _ _ _ _ H1 Hx HF) as (_ & Ho & _). exfalso. exact (Hn (Ho eq_refl)).
    - (* if *)
      destruct (fxc ce x R scf s1 F) as [Fa|] eqn:Ea; [ | discriminate Hf ].
      destruct (fxc ce x R scf s2 F) as [Fb|] eqn:Eb; [ | discriminate Hf ]. injection Hf as <-.
      apply RA.if_inv in H as (v & bb & _ & _ & H).
      destruct bb.
      + destruct (IHs1 F Fa Ea _ _ _ _ _ _ H Hx HF) as (Ho & Hn1 & Hx1 & HF1 & U).
        split; [ exact Ho | split; [ | split; [ exact Hx1 | split; [ apply facts_inter_l; exact HF1 | exact U ] ] ] ].
        cbn [noret]. intros Hn. apply andb_prop in Hn as [Hn _]. exact (Hn1 Hn).
      + destruct (IHs2 F Fb Eb _ _ _ _ _ _ H Hx HF) as (Ho & Hn1 & Hx1 & HF1 & U).
        split; [ exact Ho | split; [ | split; [ exact Hx1 | split; [ apply facts_inter_r; exact HF1 | exact U ] ] ] ].
        cbn [noret]. intros Hn. apply andb_prop in Hn as [_ Hn]. exact (Hn1 Hn).
    - (* return *)
      injection Hf as <-. inv H.
      + split; [ right; eexists; reflexivity | split; [ intros E; discriminate E | ] ].
        split; [ exact Hx | split; [ exact HF | apply Mem.unchanged_on_refl ] ].
      + split; [ right; eexists; reflexivity | split; [ intros E; discriminate E | ] ].
        split; [ exact Hx | split; [ exact HF | apply Mem.unchanged_on_refl ] ].
  Qed.

  (* a callee walked whole, its first parameter the slot *)
  Lemma fcall_fxc : forall f p ty rest vs m t m' vr F F',
    fn_vars f = [] -> fn_params f = (p, ty) :: rest -> ~ In p (var_names rest) ->
    fxc ce p R scf (fn_body f) F = Some F' ->
    eval_funcall function_entry2 ge m (Internal f) (ov :: vs) t m' vr ->
    facts m pool b0 ov F ->
    Mem.unchanged_on KPs m m' /\ facts m' pool b0 ov F'.
  Proof.
    intros f p ty rest vs m t m' vr F F' Hv Hp Hn Hf H HF.
    destruct (ObjAlloc.fcall_inv0 ge f m _ t m' vr Hv H) as (le & le' & out & Hbd & Hx & _).
    rewrite Hp in Hbd.
    pose proof (MarioModel.MathGeomBodies.bind_parameter_temps_head p ty rest _ vs _ le Hn Hbd) as Hle.
    destruct (fxc_sound p _ F F' Hf _ _ _ _ _ _ Hx Hle HF) as (_ & _ & _ & HF' & U).
    exact (conj U HF').
  Qed.
End SOUND.

(* ---------------------------------------------------------------------- *)
(* 3. The bodies.                                                          *)
(* ---------------------------------------------------------------------- *)
Definition DPRE : statement :=
  match fn_body OH.f_spawn_water_droplet with Ssequence p _ => p | _ => Sskip end.
Definition DREST : statement :=
  match fn_body OH.f_spawn_water_droplet with Ssequence _ r => r | _ => Sskip end.
Lemma DB_eq : fn_body OH.f_spawn_water_droplet = Ssequence DPRE DREST.
Proof. reflexivity. Qed.

(* what the droplet tail leaves of the slot's facts *)
Definition dtail (F : list fact) : list fact :=
  match fxc CEH OH._newObj SEEDC scf1 DREST F with Some F' => F' | None => [] end.
Lemma dtail_ok : forall F, fxc CEH OH._newObj SEEDC scf1 DREST F = Some (dtail F).
Proof.
  intros F. unfold dtail. destruct (fxc CEH OH._newObj SEEDC scf1 DREST F) eqn:E; [ reflexivity | ].
  exfalso. pose proof (fxc_indep CEH OH._newObj SEEDC scf1 scf1_indep DREST F [] E) as E0.
  vm_compute in E0. discriminate E0.
Qed.

Lemma dm_so : (prog_defmap OH.prog) ! OH._spawn_object = Some (Gfun (Internal OH.f_spawn_object)).
Proof. vm_compute. reflexivity. Qed.
Lemma dm_swd : (prog_defmap OH.prog) ! OH._spawn_water_droplet = Some (Gfun (Internal OH.f_spawn_water_droplet)).
Proof. vm_compute. reflexivity. Qed.
Lemma dm_scale : (prog_defmap OH.prog) ! OH._obj_scale = Some (Gfun (Internal OH.f_obj_scale)).
Proof. vm_compute. reflexivity. Qed.
Lemma dm_txz : (prog_defmap OH.prog) ! OH._obj_translate_xz_random = Some (Gfun (Internal OH.f_obj_translate_xz_random)).
Proof. vm_compute. reflexivity. Qed.
Lemma dm_txyz : (prog_defmap OH.prog) ! OH._obj_translate_xyz_random = Some (Gfun (Internal OH.f_obj_translate_xyz_random)).
Proof. vm_compute. reflexivity. Qed.
Lemma dm_rf32 : (prog_defmap OH.prog) ! OH._random_f32_around_zero = Some (Gfun (Internal OH.f_random_f32_around_zero)).
Proof. vm_compute. reflexivity. Qed.
Lemma dm_ru16 : (prog_defmap BS.prog) ! BS._random_u16 = Some (Gfun (Internal BS.f_random_u16)).
Proof. vm_compute. reflexivity. Qed.
Lemma dm_rf : (prog_defmap BS.prog) ! BS._random_float = Some (Gfun (Internal BS.f_random_float)).
Proof. vm_compute. reflexivity. Qed.
Lemma dm_fwl : (prog_defmap SC.prog) ! OH._find_water_level = Some (Gfun (Internal SC.f_find_water_level)).
Proof. vm_compute. reflexivity. Qed.

Lemma exl3f : forall (G : genv) e le m a1 a2 a3 tys vs, eval_exprlist G e le m [a1; a2; a3] tys vs ->
  exists t1 t2 t3 v1 v2 v3 w1 w2 w3, tys = [t1; t2; t3] /\ vs = [w1; w2; w3]
    /\ eval_expr G e le m a1 v1 /\ sem_cast v1 (typeof a1) t1 m = Some w1
    /\ eval_expr G e le m a2 v2 /\ sem_cast v2 (typeof a2) t2 m = Some w2
    /\ eval_expr G e le m a3 v3 /\ sem_cast v3 (typeof a3) t3 m = Some w3.
Proof.
  intros G e le m a1 a2 a3 tys vs H.
  inv H. match goal with H : eval_exprlist _ _ _ _ _ _ _ |- _ => inv H end.
  match goal with H : eval_exprlist _ _ _ _ _ _ _ |- _ => inv H end.
  match goal with H : eval_exprlist _ _ _ _ _ _ _ |- _ => inv H end.
  do 9 eexists. repeat split; eassumption.
Qed.

(* the seed callees' stores: gRandomSeed16 (a u16) only *)
Definition seed_st (lv rhs : expr) : bool :=
  match lv with
  | Evar y ty => Pos.eqb y BS._gRandomSeed16 && (if type_eq ty tushort then true else false)
  | _ => false
  end.
Definition seed_call (L : list ident) (o : option ident) (a : expr) (al : list expr) : bool :=
  match a with Evar g (Tfunction _ _ _) => existsb (Pos.eqb g) L | _ => false end.
Definition seed_chk (L : list ident) (f : function) : bool :=
  SpawnBodies.sw_chk (fun _ _ => true) seed_st (seed_call L) (fun _ => true) (fn_body f).

(* ---------------------------------------------------------------------- *)
(* 4. On the real linked program.                                          *)
(* ---------------------------------------------------------------------- *)
Section LINKED.
  Variable lp : Clight.program.
  Hypothesis H12 : linked12 lp.
  Notation G := (lp_ge lp).
  Variable sb : block.
  Hypothesis HsbR : Genv.find_symbol G BS._gRandomSeed16 = Some sb.

  Lemma seed_store : forall lv rhs le m t le' m' out, seed_st lv rhs = true ->
    exec_stmt function_entry2 G empty_env le m (Sassign lv rhs) t le' m' out ->
    Mem.unchanged_on (fun b _ => b <> sb) m m'.
  Proof.
    intros lv rhs le m t le' m' out Hc H.
    destruct lv; try discriminate Hc. cbn [seed_st] in Hc.
    apply andb_prop in Hc as [Hx Ht]. apply Pos.eqb_eq in Hx. subst i.
    destruct (type_eq t0 tushort) as [->|]; [ | discriminate Ht ].
    apply RA.assign_inv in H as (b2 & o2 & bf2 & v2 & v3 & Hlv & _ & _ & Has & _ & _).
    inversion Hlv; subst.
    - match goal with Hl : empty_env ! _ = Some _ |- _ => rewrite PTree.gempty in Hl; discriminate Hl end.
    - match goal with Hf : Genv.find_symbol _ _ = Some _ |- _ => rewrite HsbR in Hf; injection Hf as <- end.
      pose proof (RA.store_by_value _ tushort _ _ _ _ _ _ Mint16unsigned eq_refl eq_refl Has) as Hs.
      apply (Mem.store_unchanged_on _ _ _ _ _ _ _ Hs). intros i _ Hp. apply Hp. reflexivity.
  Qed.

  Lemma seed_callp : forall L, (forall g, In g L -> seed_sym G sb g) ->
    forall optid a al le m t le' m' out, seed_call L optid a al = true ->
    exec_stmt function_entry2 G empty_env le m (Scall optid a al) t le' m' out ->
    forall m0, Mem.unchanged_on (fun b _ => b <> sb) m0 m -> Mem.unchanged_on (fun b _ => b <> sb) m0 m'.
  Proof.
    intros L HL optid a al le m t le' m' out Hok H m0 U0.
    destruct a; try discriminate Hok. destruct t0; try discriminate Hok. cbn [seed_call] in Hok.
    apply existsb_exists in Hok as (g & Hg & E). apply Pos.eqb_eq in E. subst g.
    apply RA.call_inv in H as (tya & tyr & cc & vf & vargs & fd & vres & _ & Evf & _ & Hff & _ & Hc & _ & _).
    match type of Evf with eval_expr _ _ _ _ (Evar _ ?ty) _ =>
      destruct (RA.ev_fun G empty_env m le _ ty vf (PTree.gempty _ _) eq_refl Evf) as (bf & Hs & ->) end.
    exact (Mem.unchanged_on_trans _ _ _ _ U0 (HL i Hg bf fd Hs Hff m vargs t m' vres Hc)).
  Qed.

  Lemma seed_body : forall L f, fn_vars f = [] -> seed_chk L f = true ->
    (forall g, In g L -> seed_sym G sb g) -> seed_fn G sb (Internal f).
  Proof.
    intros L f Hv Hc HL m vs t m' vr H.
    destruct (ObjAlloc.fcall_inv0 G f m vs t m' vr Hv H) as (le & le' & out & _ & X & _).
    destruct (SpawnBodies.sw_walk G empty_env (Mem.unchanged_on (fun b _ => b <> sb) m) (fun _ => True) (fun _ => True)
      (fun _ _ => true) seed_st (seed_call L) (fun _ => true)
      (fun _ _ _ _ _ _ _ _ _ => I)
      (fun lv rhs le0 m0 t0 le0' m0' out0 Hok _ Hx Hf =>
         Mem.unchanged_on_trans _ _ _ _ Hf (seed_store _ _ _ _ _ _ _ _ Hok Hx))
      (fun optid a al le0 m0 t0 le0' m0' out0 Hok _ Hx Hf =>
         conj (seed_callp L HL optid a al le0 m0 t0 le0' m0' out0 Hok Hx m Hf) I)
      (fun _ _ _ _ _ _ _ _ => I)
      _ _ _ _ _ _ _ _ X eq_refl Hc I (Mem.unchanged_on_refl _ _)) as (U & _ & _).
    exact U.
  Qed.

  Lemma ss_ru16 : seed_sym G sb BS._random_u16.
  Proof.
    intros b fd Hs Hff. rewrite (fun_res lp _ _ _ (linked12_LO_behavior_script lp H12) dm_ru16 b fd Hs Hff).
    apply (seed_body []); [ reflexivity | vm_compute; reflexivity | intros g [] ].
  Qed.
  Lemma ss_rf : seed_sym G sb BS._random_float.
  Proof.
    intros b fd Hs Hff. rewrite (fun_res lp _ _ _ (linked12_LO_behavior_script lp H12) dm_rf b fd Hs Hff).
    apply (seed_body [BS._random_u16]); [ reflexivity | vm_compute; reflexivity | ].
    intros g [<- | []]. exact ss_ru16.
  Qed.
  Lemma ss_rf32 : seed_sym G sb OH._random_f32_around_zero.
  Proof.
    intros b fd Hs Hff. rewrite (fun_res lp _ _ _ (linked12_LO_object_helpers lp H12) dm_rf32 b fd Hs Hff).
    apply (seed_body [BS._random_float]); [ reflexivity | vm_compute; reflexivity | ].
    intros g [<- | []]. exact ss_rf.
  Qed.
  Lemma ss_fwl : seed_sym G sb OH._find_water_level.
  Proof.
    intros b fd Hs Hff. rewrite (fun_res lp _ _ _ (linked12_LO_surf lp H12) dm_fwl b fd Hs Hff).
    apply (seed_body []); [ reflexivity | vm_compute; reflexivity | intros g [] ].
  Qed.
  Lemma ss_all : forall g, In g SEEDC -> seed_sym G sb g.
  Proof. intros g [<- | [<- | [<- | [<- | []]]]]; [ exact ss_ru16 | exact ss_rf | exact ss_rf32 | exact ss_fwl ]. Qed.

  Lemma Hceh : ObjSelf.cext G CEH.
  Proof. exact (cenv_of lp _ (linked12_LO_object_helpers lp H12)). Qed.

  (* the slot callees of the droplet tail, walked on their real bodies *)
  Lemma ss_fns : forall pool gB, Genv.find_symbol G ObjSelf.POOL = Some pool ->
    Genv.find_symbol G ObjSelf.GCO = Some gB -> sb <> pool -> forall k, 0 <= k < NSLOT ->
    forall g F F' b fd m vs t m' vr, scf1 g F = Some F' ->
    Genv.find_symbol G g = Some b -> Genv.find_funct G (Vptr b Ptrofs.zero) = Some fd ->
    eval_funcall function_entry2 G m fd (slot_v pool k :: vs) t m' vr ->
    facts m pool (k * OSZ) (slot_v pool k) F ->
    Mem.unchanged_on (KPs pool sb k) m m' /\ facts m' pool (k * OSZ) (slot_v pool k) F'.
  Proof.
    intros pool gB Hp HgB Hsp k Hk g F F' b fd m vs t m' vr H Hs Hff Hev HF.
    unfold scf1, wbody in H.
    destruct (Pos.eqb g OH._obj_scale) eqn:E1.
    { apply Pos.eqb_eq in E1. subst g.
      rewrite (fun_res lp _ _ _ (linked12_LO_object_helpers lp H12) dm_scale b fd Hs Hff) in Hev.
      exact (fcall_fxc G pool gB sb Hp HgB Hsp CEH Hceh k Hk SEEDC ss_all scf0 ltac:(intros; discriminate)
               OH.f_obj_scale OH._obj _ _ vs m t m' vr F F' eq_refl eq_refl
               ltac:(cbn; intros [E | []]; discriminate E) H Hev HF). }
    destruct (Pos.eqb g OH._obj_translate_xz_random) eqn:E2.
    { apply Pos.eqb_eq in E2. subst g.
      rewrite (fun_res lp _ _ _ (linked12_LO_object_helpers lp H12) dm_txz b fd Hs Hff) in Hev.
      exact (fcall_fxc G pool gB sb Hp HgB Hsp CEH Hceh k Hk SEEDC ss_all scf0 ltac:(intros; discriminate)
               OH.f_obj_translate_xz_random OH._obj _ _ vs m t m' vr F F' eq_refl eq_refl
               ltac:(cbn; intros [E | []]; discriminate E) H Hev HF). }
    destruct (Pos.eqb g OH._obj_translate_xyz_random) eqn:E3.
    { apply Pos.eqb_eq in E3. subst g.
      rewrite (fun_res lp _ _ _ (linked12_LO_object_helpers lp H12) dm_txyz b fd Hs Hff) in Hev.
      exact (fcall_fxc G pool gB sb Hp HgB Hsp CEH Hceh k Hk SEEDC ss_all scf0 ltac:(intros; discriminate)
               OH.f_obj_translate_xyz_random OH._obj _ _ vs m t m' vr F F' eq_refl eq_refl
               ltac:(cbn; intros [E | []]; discriminate E) H Hev HF). }
    discriminate H.
  Qed.

  Lemma fo_bhv : forall co, (genv_cenv G) ! OH._WaterDropletParams = Some co ->
    field_offset G OH._behavior (co_members co) = OK (4, Full).
  Proof. apply (RA.fo_ok_lift CEH); [ vm_compute; reflexivity | exact Hceh ]. Qed.

  (* SPAWN_OBJECT (object_helpers.c): spawn_object_at_origin, then
     obj_copy_pos_and_angle(obj, parent) *)
  Theorem so_real : forall pool la fl bpg gol,
    Genv.find_symbol G object_list_processor._gObjectPool = Some pool ->
    Genv.find_symbol G object_list_processor._gObjectListArray = Some la ->
    Genv.find_symbol G object_list_processor._gFreeObjectList = Some fl ->
    Genv.find_symbol G area._gObjParentGraphNode = Some bpg ->
    Genv.find_symbol G object_list_processor._gObjectLists = Some gol ->
    forall m rs fs pv mdl bs o w t m' vr,
    rings m pool la = Some rs -> free_list m pool fl = Some fs -> NoDup (concat rs ++ fs) ->
    gfx_ok G pool m -> Mem.load Mint32 m gol 0 = Some (Vptr la Ptrofs.zero) ->
    Mem.load Mint32 m bs (Ptrofs.unsigned o) = Some (Vint w) ->
    bhv_list w < 13 -> bhv_list w <> 4 -> bhv_list w <> 5 -> bhv_list w <> 10 ->
    eval_funcall function_entry2 G m (Internal OH.f_spawn_object) [pv; mdl; Vptr bs o] t m' vr ->
    fs = []
    \/ (exists k fs' me, fs = k :: fs' /\ 0 <= k < NSLOT /\ vr = slot_v pool k
        /\ rings me pool la = Some (upd rs (Z.to_nat (bhv_list w)) (nth (Z.to_nat (bhv_list w)) rs [] ++ [k]))
        /\ free_list me pool fl = Some fs' /\ gfx_ok G pool me
        /\ Mem.unchanged_on (fun b z => AKEEP pool la fl bpg b z /\ KP pool (k * OSZ) b z) m me
        /\ Mem.unchanged_on (KP pool (k * OSZ)) me m'
        /\ facts m' pool (k * OSZ) (slot_v pool k) (cpa_facts (origin_facts (bhv_list w) (Vptr bs o) pv))).
  Proof.
    intros pool la fl bpg gol Hp Hl Hf Hb Hgl m rs fs pv mdl bs o w t m' vr
      Hr Hfl Hnd Hg Hgo Hw Hi13 Hi4 Hi5 Hi10 H.
    destruct dm_gco as (gd & Hdm).
    destruct (linkorder_resolves_symbol lp SO.prog _ gd (linked12_LO_spawn_object lp H12) Hdm) as (gB & HgB).
    destruct (ObjAlloc.fcall_inv0 G OH.f_spawn_object m _ t m' vr eq_refl H) as (le & le' & out & Hbd & Hx & Hov).
    cbn [fn_params OH.f_spawn_object bind_parameter_temps] in Hbd. injection Hbd as Hle.
    assert (Hpar : le ! OH._parent = Some pv) by (rewrite <- Hle; reflexivity).
    assert (Hbh : le ! OH._behavior = Some (Vptr bs o)) by (rewrite <- Hle; reflexivity).
    clear Hle.
    cbn [fn_body OH.f_spawn_object] in Hx.
    apply RA.seq_inv in Hx as [(t1 & le1 & m1 & t2 & X1 & X2) | (X1 & Hne)];
      [ | exfalso; apply Hne; exact (nb_normal _ _ _ _ _ _ _ _ _ X1 eq_refl) ].
    apply RA.seq_inv in X1 as [(t3 & le3 & m3 & t4 & A1 & A2) | (A1 & Hne)];
      [ | exfalso; apply Hne; exact (nb_normal _ _ _ _ _ _ _ _ _ A1 eq_refl) ].
    apply RA.call_inv in A1 as (tyargs & tyres & cc & vf & vargs & fd & vres & Hcf & Evf & Eal & Hff & _ & Hcl & -> & _).
    cbn in Hcf. injection Hcf as <- <- <-.
    match type of Evf with eval_expr _ _ _ _ (Evar _ ?ty) _ =>
      destruct (RA.ev_fun G empty_env _ _ _ ty vf (PTree.gempty _ _) eq_refl Evf) as (bf & Hsf & ->) end.
    rewrite (fun_res lp _ _ _ (linked12_LO_object_helpers lp H12) dm_soo bf fd Hsf Hff) in Hcl.
    destruct (exl4f _ _ _ _ _ _ _ _ _ _ Eal)
      as (t1' & t2' & t3' & t4' & u1 & u2 & u3 & u4 & w1 & w2 & w3 & w4 & Ety & -> & Eu1 & Cu1 & _ & _ & _ & _ & Eu4 & Cu4).
    injection Ety as <- <- <- <-.
    apply RA.ev_temp in Eu1. rewrite Hpar in Eu1. injection Eu1 as <-.
    cbn [typeof] in Cu1. apply RA.cast_ptr_id in Cu1. subst w1.
    apply RA.ev_temp in Eu4. rewrite Hbh in Eu4. injection Eu4 as <-.
    cbn [typeof] in Cu4. apply RA.cast_ptr_id in Cu4. subst w4.
    destruct (origin_real lp H12 pool la fl bpg gol Hp Hl Hf Hb Hgl m rs fs pv w2 w3 bs o w _ _ _
                Hr Hfl Hnd Hg Hgo Hw Hi13 Hi4 Hi5 Hi10 Hcl)
      as [E | (k & fs' & E & Hk & Ev & R & F & Gx & U & HF)]; [ left; exact E | right ].
    subst vres.
    apply RA.set_inv in A2 as (v & Hv & -> & -> & _).
    apply RA.ev_temp in Hv. cbn [set_opttemp] in Hv. rewrite PTree.gss in Hv. injection Hv as <-.
    apply RA.seq_inv in X2 as [(t5 & le5 & m5 & t6 & X3 & X4) | (X3 & Hne)];
      [ | exfalso; apply Hne; exact (nb_normal _ _ _ _ _ _ _ _ _ X3 eq_refl) ].
    apply RA.call_inv in X3 as (tyargs2 & tyres2 & cc2 & vf2 & vargs2 & fd2 & vres2 & Hcf2 & Evf2 & Eal2 & Hff2 & _ & Hcl2 & -> & _).
    cbn in Hcf2. injection Hcf2 as <- <- <-.
    match type of Evf2 with eval_expr _ _ _ _ (Evar _ ?ty) _ =>
      destruct (RA.ev_fun G empty_env _ _ _ ty vf2 (PTree.gempty _ _) eq_refl Evf2) as (bf2 & Hsf2 & ->) end.
    rewrite (fun_res lp _ _ _ (linked12_LO_object_helpers lp H12) dm_cpa bf2 fd2 Hsf2 Hff2) in Hcl2.
    destruct (ObjLoop.exl2 _ _ _ _ _ _ _ _ Eal2) as (ta1 & tb1 & y1 & y2 & z1 & z2 & Ea2 & -> & Ey1 & Cy1 & _ & _).
    injection Ea2 as <- <-.
    apply RA.ev_temp in Ey1. rewrite PTree.gss in Ey1. injection Ey1 as <-.
    cbn [typeof] in Cy1. apply RA.cast_ptr_id in Cy1. subst z1.
    destruct (cpa_ok G pool gB Hp HgB k Hk Hceh
                (fun b fd => fun_res lp _ _ _ (linked12_LO_object_helpers lp H12) dm_cp b fd)
                (fun b fd => fun_res lp _ _ _ (linked12_LO_object_helpers lp H12) dm_ca b fd)
                _ _ _ _ _ _ Hcl2 HF) as (U7 & HF7).
    apply RA.ret_inv in X4 as (-> & rv & Erv & ->).
    apply RA.ev_temp in Erv. cbn [set_opttemp] in Erv. rewrite PTree.gss in Erv. injection Erv as <-.
    cbn [outcome_result_value fn_return OH.f_spawn_object typeof] in Hov. destruct Hov as (_ & Hov).
    apply RA.cast_ptr_id in Hov.
    exists k, fs'. eexists.
    exact (conj E (conj Hk (conj Hov (conj R (conj F (conj Gx (conj U (conj U7 HF7)))))))).
  Qed.

  (* SPAWN_WATER_DROPLET's callee (object_helpers.c): spawn_object, then the
     walked tail.  The params' behavior field (word 1) is pinned to the
     child's script (bs, o) *)
  Theorem drop_real : forall pool la fl bpg gol,
    Genv.find_symbol G object_list_processor._gObjectPool = Some pool ->
    Genv.find_symbol G object_list_processor._gObjectListArray = Some la ->
    Genv.find_symbol G object_list_processor._gFreeObjectList = Some fl ->
    Genv.find_symbol G area._gObjParentGraphNode = Some bpg ->
    Genv.find_symbol G object_list_processor._gObjectLists = Some gol ->
    forall m rs fs pv bp op bs o w t m' vr,
    rings m pool la = Some rs -> free_list m pool fl = Some fs -> NoDup (concat rs ++ fs) ->
    gfx_ok G pool m -> Mem.load Mint32 m gol 0 = Some (Vptr la Ptrofs.zero) ->
    Mem.loadv Mint32 m (Vptr bp (Ptrofs.add op (Ptrofs.repr 4))) = Some (Vptr bs o) ->
    Mem.load Mint32 m bs (Ptrofs.unsigned o) = Some (Vint w) ->
    bhv_list w < 13 -> bhv_list w <> 4 -> bhv_list w <> 5 -> bhv_list w <> 10 ->
    eval_funcall function_entry2 G m (Internal OH.f_spawn_water_droplet) [pv; Vptr bp op] t m' vr ->
    fs = []
    \/ (exists k fs' me, fs = k :: fs' /\ 0 <= k < NSLOT
        /\ rings me pool la = Some (upd rs (Z.to_nat (bhv_list w)) (nth (Z.to_nat (bhv_list w)) rs [] ++ [k]))
        /\ free_list me pool fl = Some fs' /\ gfx_ok G pool me
        /\ Mem.unchanged_on (fun b z => AKEEP pool la fl bpg b z /\ KP pool (k * OSZ) b z) m me
        /\ Mem.unchanged_on (KPs pool sb k) me m'
        /\ facts m' pool (k * OSZ) (slot_v pool k) (dtail (cpa_facts (origin_facts (bhv_list w) (Vptr bs o) pv)))).
  Proof.
    intros pool la fl bpg gol Hp Hl Hf Hb Hgl m rs fs pv bp op bs o w t m' vr
      Hr Hfl Hnd Hg Hgo Hb8 Hw Hi13 Hi4 Hi5 Hi10 H.
    assert (Hsp : sb <> pool) by (apply (sym_ne lp _ _ _ _ HsbR Hp); RA.neq).
    destruct dm_gco as (gd & Hdm).
    destruct (linkorder_resolves_symbol lp SO.prog _ gd (linked12_LO_spawn_object lp H12) Hdm) as (gB & HgB).
    destruct (ObjAlloc.fcall_inv0 G OH.f_spawn_water_droplet m _ t m' vr eq_refl H) as (le & le' & out & Hbd & Hx & _).
    cbn [fn_params OH.f_spawn_water_droplet bind_parameter_temps] in Hbd. injection Hbd as Hle.
    assert (Hpar : le ! OH._parent = Some pv) by (rewrite <- Hle; reflexivity).
    assert (Hprm : le ! OH._params = Some (Vptr bp op)) by (rewrite <- Hle; reflexivity).
    clear Hle.
    rewrite DB_eq in Hx.
    apply RA.seq_inv in Hx as [(t1 & le1 & m1 & t2 & X1 & X2) | (X1 & Hne)];
      [ | exfalso; apply Hne; exact (nb_normal _ _ _ _ _ _ _ _ _ X1 eq_refl) ].
    unfold DPRE in X1. cbn [fn_body OH.f_spawn_water_droplet] in X1.
    apply RA.seq_inv in X1 as [(t3 & le3 & m3 & t4 & A1 & A2) | (A1 & Hne)];
      [ | exfalso; apply Hne; exact (nb_normal _ _ _ _ _ _ _ _ _ A1 eq_refl) ].
    apply RA.seq_inv in A1 as [(t5 & le5 & m5 & t6 & B1 & B2) | (B1 & Hne)];
      [ | apply RA.set_inv in B1 as (_ & _ & _ & _ & E); contradiction ].
    apply RA.set_inv in B1 as (v29 & E29 & -> & -> & _).
    apply RA.seq_inv in B2 as [(t7 & le7 & m7 & t8 & B3 & B4) | (B3 & Hne)];
      [ | apply RA.set_inv in B3 as (_ & _ & _ & _ & E); contradiction ].
    apply RA.set_inv in B3 as (v30 & E30 & -> & -> & _).
    destruct (RA.ev_fld G empty_env _ _ _ _ _ (tptr tuint) v30 Mint32 4 fo_bhv eq_refl E30) as (b1 & o1 & Hb1 & Hl1).
    rewrite PTree.gso in Hb1 by RA.neq. rewrite Hprm in Hb1. injection Hb1 as <- <-.
    rewrite Hb8 in Hl1. injection Hl1 as <-.
    apply RA.call_inv in B4 as (tyargs & tyres & cc & vf & vargs & fd & vres & Hcf & Evf & Eal & Hff & _ & Hcl & -> & _).
    cbn in Hcf. injection Hcf as <- <- <-.
    match type of Evf with eval_expr _ _ _ _ (Evar _ ?ty) _ =>
      destruct (RA.ev_fun G empty_env _ _ _ ty vf (PTree.gempty _ _) eq_refl Evf) as (bf & Hsf & ->) end.
    rewrite (fun_res lp _ _ _ (linked12_LO_object_helpers lp H12) dm_so bf fd Hsf Hff) in Hcl.
    destruct (exl3f _ _ _ _ _ _ _ _ _ Eal)
      as (t1' & t2' & t3' & u1 & u2 & u3 & w1 & w2 & w3 & Ety & -> & Eu1 & Cu1 & _ & _ & Eu3 & Cu3).
    injection Ety as <- <- <-.
    apply RA.ev_temp in Eu1. do 2 rewrite PTree.gso in Eu1 by RA.neq. rewrite Hpar in Eu1. injection Eu1 as <-.
    cbn [typeof] in Cu1. apply RA.cast_ptr_id in Cu1. subst w1.
    apply RA.ev_temp in Eu3. rewrite PTree.gss in Eu3. injection Eu3 as <-.
    cbn [typeof] in Cu3. apply RA.cast_ptr_id in Cu3. subst w3.
    destruct (so_real pool la fl bpg gol Hp Hl Hf Hb Hgl m rs fs pv w2 bs o w _ _ _
                Hr Hfl Hnd Hg Hgo Hw Hi13 Hi4 Hi5 Hi10 Hcl)
      as [E | (k & fs' & me & E & Hk & Ev & R & F & Gx & U & U7 & HF)]; [ left; exact E | right ].
    subst vres.
    apply RA.set_inv in A2 as (v & Hv & -> & -> & _).
    apply RA.ev_temp in Hv. cbn [set_opttemp] in Hv. rewrite PTree.gss in Hv. injection Hv as <-.
    destruct (fxc_sound G pool gB sb Hp HgB Hsp CEH Hceh k Hk SEEDC ss_all scf1 (ss_fns pool gB Hp HgB Hsp k Hk)
                OH._newObj DREST _ _ (dtail_ok _) _ _ _ _ _ _ X2 (PTree.gss _ _ _) HF) as (_ & _ & _ & HF2 & U2).
    exists k, fs', me.
    exact (conj E (conj Hk (conj R (conj F (conj Gx (conj U
             (conj (Mem.unchanged_on_trans _ _ _ _ (kp_kps pool sb k _ _ U7) U2) HF2))))))).
  Qed.

  (* SPAWN_WATER_DROPLET ON THE REAL PROGRAM.  Premises: drop_real's, the
     command pointer (cs, co) in gCurBhvCommand, its word 1 = the params
     pointer (bp, op), whose behavior field is the child's script (bs, o)
     with first word w; gCurrentObject = vgo, the droplet's parent *)
  Theorem wd_real : forall pool la fl bpg gol bc go,
    Genv.find_symbol G object_list_processor._gObjectPool = Some pool ->
    Genv.find_symbol G object_list_processor._gObjectListArray = Some la ->
    Genv.find_symbol G object_list_processor._gFreeObjectList = Some fl ->
    Genv.find_symbol G area._gObjParentGraphNode = Some bpg ->
    Genv.find_symbol G object_list_processor._gObjectLists = Some gol ->
    Genv.find_symbol G BS._gCurBhvCommand = Some bc ->
    Genv.find_symbol G BS._gCurrentObject = Some go ->
    forall m rs fs cs co bp op bs o w vgo t m' vr,
    rings m pool la = Some rs -> free_list m pool fl = Some fs -> NoDup (concat rs ++ fs) ->
    gfx_ok G pool m -> Mem.load Mint32 m gol 0 = Some (Vptr la Ptrofs.zero) ->
    Mem.load Mint32 m bc 0 = Some (Vptr cs co) ->
    Mem.load Mint32 m go 0 = Some vgo ->
    Mem.loadv Mint32 m (Vptr cs (Ptrofs.add co (Ptrofs.repr 4))) = Some (Vptr bp op) ->
    Mem.loadv Mint32 m (Vptr bp (Ptrofs.add op (Ptrofs.repr 4))) = Some (Vptr bs o) ->
    Mem.load Mint32 m bs (Ptrofs.unsigned o) = Some (Vint w) ->
    bhv_list w < 13 -> bhv_list w <> 4 -> bhv_list w <> 5 -> bhv_list w <> 10 ->
    eval_funcall function_entry2 G m (Internal BS.f_bhv_cmd_spawn_water_droplet) [] t m' vr ->
    (* EMPTY FREE LIST: named, as in alloc_real *)
    fs = []
    \/ (exists k fs', fs = k :: fs' /\ 0 <= k < NSLOT /\ vr = Vint (Int.repr 0)
        /\ Mem.load Mint32 m' bc 0 = Some (Vptr cs (Ptrofs.add co (Ptrofs.repr 8)))
        /\ rings m' pool la = Some (upd rs (Z.to_nat (bhv_list w)) (nth (Z.to_nat (bhv_list w)) rs [] ++ [k]))
        /\ free_list m' pool fl = Some fs'
        /\ gfx_ok G pool m'
        /\ Mem.unchanged_on (fun b z => AKEEP pool la fl bpg b z /\ KP pool (k * OSZ) b z /\ b <> bc /\ b <> sb) m m'
        /\ facts m' pool (k * OSZ) (slot_v pool k) (dtail (cpa_facts (origin_facts (bhv_list w) (Vptr bs o) vgo)))).
  Proof.
    intros pool la fl bpg gol bc go Hp Hl Hf Hb Hgl Hbc Hgc m rs fs cs co bp op bs o w vgo t m' vr
      Hr Hfl Hnd Hg Hgo Hc0 Hcu Hw4 Hb8 Hw Hi13 Hi4 Hi5 Hi10 H.
    assert (Hpl : pool <> la) by (apply (sym_ne lp _ _ _ _ Hp Hl); RA.neq).
    assert (Hpf : pool <> fl) by (apply (sym_ne lp _ _ _ _ Hp Hf); RA.neq).
    assert (Hlf : la <> fl) by (apply (sym_ne lp _ _ _ _ Hl Hf); RA.neq).
    assert (Hpb : pool <> bpg) by (apply (sym_ne lp _ _ _ _ Hp Hb); RA.neq).
    assert (Hlb : la <> bpg) by (apply (sym_ne lp _ _ _ _ Hl Hb); RA.neq).
    assert (Hfb : fl <> bpg) by (apply (sym_ne lp _ _ _ _ Hf Hb); RA.neq).
    assert (Hpc : pool <> bc) by (apply (sym_ne lp _ _ _ _ Hp Hbc); RA.neq).
    assert (Hlc : la <> bc) by (apply (sym_ne lp _ _ _ _ Hl Hbc); RA.neq).
    assert (Hfc : fl <> bc) by (apply (sym_ne lp _ _ _ _ Hf Hbc); RA.neq).
    assert (Hbgc : bpg <> bc) by (apply (sym_ne lp _ _ _ _ Hb Hbc); RA.neq).
    assert (Hsp : sb <> pool) by (apply (sym_ne lp _ _ _ _ HsbR Hp); RA.neq).
    assert (Hls : la <> sb) by (apply (sym_ne lp _ _ _ _ Hl HsbR); RA.neq).
    assert (Hfs : fl <> sb) by (apply (sym_ne lp _ _ _ _ Hf HsbR); RA.neq).
    assert (Hbs : bpg <> sb) by (apply (sym_ne lp _ _ _ _ Hb HsbR); RA.neq).
    assert (Hcs : bc <> sb) by (apply (sym_ne lp _ _ _ _ Hbc HsbR); RA.neq).
    destruct (ObjAlloc.fcall_inv0 G BS.f_bhv_cmd_spawn_water_droplet m _ t m' vr eq_refl H) as (le & le' & out & Hbd & Hx & Hov).
    cbn [fn_body BS.f_bhv_cmd_spawn_water_droplet] in Hx.
    (* params = gCurBhvCommand[1] *)
    apply RA.seq_inv in Hx as [(t1 & le1 & m1 & t2 & X1 & X2) | (X1 & Hne)];
      [ | destruct (so_mem _ _ _ _ _ _ _ _ _ X1 eq_refl) as (_ & E); contradiction ].
    apply RA.seq_inv in X1 as [(ta & lea & ma & tb & A1 & A2) | (A1 & Hne)];
      [ | apply RA.set_inv in A1 as (_ & _ & _ & _ & E); contradiction ].
    apply RA.set_inv in A1 as (v5 & E5 & -> & -> & _).
    destruct (RA.ev_gvar G empty_env m le _ (tptr tuint) v5 Mint32 (PTree.gempty _ _) eq_refl E5) as (b5 & Hb5 & Hl5).
    rewrite Hbc in Hb5. injection Hb5 as <-. cbn [Mem.loadv] in Hl5. rewrite Ptrofs.unsigned_zero, Hc0 in Hl5.
    injection Hl5 as <-. clear E5.
    apply RA.seq_inv in A2 as [(tc & lec & mc & td & A3 & A4) | (A3 & Hne)];
      [ | apply RA.set_inv in A3 as (_ & _ & _ & _ & E); contradiction ].
    apply RA.set_inv in A3 as (v6 & E6 & -> & -> & _).
    pose proof (ld_idx G _ m BS._t'3 1 cs co v6 (PTree.gss _ _ _) E6) as L6.
    assert (E4 : Ptrofs.mul (Ptrofs.repr 4) (Ptrofs.of_ints (Int.repr 1)) = Ptrofs.repr 4) by reflexivity.
    rewrite E4, Hw4 in L6. injection L6 as <-. clear E6.
    apply RA.set_inv in A4 as (vb & Eb & -> & -> & _).
    inv Eb; [ | match goal with Hq : eval_lvalue _ _ _ _ (Ecast _ _) _ _ _ |- _ => inv Hq end ].
    match goal with Ht : eval_expr _ _ _ _ (Etempvar _ _) _, Hcs' : sem_cast _ _ _ _ = Some _ |- _ =>
      apply RA.ev_temp in Ht; rewrite PTree.gss in Ht; injection Ht as <-;
      cbn [typeof] in Hcs'; assert (Ecs : sem_cast (Vptr bp op) tuint (tptr tvoid) m = Some (Vptr bp op)) by reflexivity;
      rewrite Ecs in Hcs'; injection Hcs' as <- end.
    set (le4 := PTree.set BS._dropletParams (Vptr bp op) _) in X2.
    assert (Hdp : le4 ! BS._dropletParams = Some (Vptr bp op)) by (unfold le4; apply PTree.gss).
    clearbody le4.
    (* spawn_water_droplet(gCurrentObject, params) *)
    apply RA.seq_inv in X2 as [(t5 & le5 & m5 & t6 & X5 & X6) | (X5 & Hne)];
      [ | exfalso; apply Hne; exact (nb_normal _ _ _ _ _ _ _ _ _ X5 eq_refl) ].
    apply RA.seq_inv in X5 as [(te & lee & me & tf & A5 & A6) | (A5 & Hne)];
      [ | apply RA.set_inv in A5 as (_ & _ & _ & _ & E); contradiction ].
    apply RA.set_inv in A5 as (v4 & E4' & -> & -> & _).
    destruct (RA.ev_gvar G empty_env _ _ _ (tptr OTB) v4 Mint32 (PTree.gempty _ _) eq_refl E4') as (b4 & Hb4 & Hl4).
    rewrite Hgc in Hb4. injection Hb4 as <-. cbn [Mem.loadv] in Hl4. rewrite Ptrofs.unsigned_zero, Hcu in Hl4.
    injection Hl4 as <-. clear E4'.
    apply RA.call_inv in A6 as (tyargs & tyres & cc & vf & vargs & fd & vres & Hcf & Evf & Eal & Hff & _ & Hcl & -> & _).
    cbn in Hcf. injection Hcf as <- <- <-.
    match type of Evf with eval_expr _ _ _ _ (Evar _ ?ty) _ =>
      destruct (RA.ev_fun G empty_env _ _ _ ty vf (PTree.gempty _ _) eq_refl Evf) as (bf & Hsf & ->) end.
    rewrite (fun_res lp _ _ _ (linked12_LO_object_helpers lp H12) dm_swd bf fd Hsf Hff) in Hcl.
    destruct (ObjLoop.exl2 _ _ _ _ _ _ _ _ Eal) as (ta1 & tb1 & y1 & y2 & z1 & z2 & Ea2 & -> & Ey1 & Cy1 & Ey2 & Cy2).
    injection Ea2 as <- <-.
    apply RA.ev_temp in Ey1. rewrite PTree.gss in Ey1. injection Ey1 as <-.
    cbn [typeof] in Cy1. apply RA.cast_ptr_id in Cy1. subst z1.
    apply RA.ev_temp in Ey2. rewrite PTree.gso in Ey2 by RA.neq. rewrite Hdp in Ey2. injection Ey2 as <-.
    cbn [typeof] in Cy2. apply RA.cast_ptr_id in Cy2. subst z2.
    destruct (drop_real pool la fl bpg gol Hp Hl Hf Hb Hgl m rs fs vgo bp op bs o w _ _ _
                Hr Hfl Hnd Hg Hgo Hb8 Hw Hi13 Hi4 Hi5 Hi10 Hcl)
      as [E | (k & fs' & mx & E & Hk & R & F & Gx & U & U2 & HF)]; [ left; exact E | right; exists k, fs' ].
    (* gCurBhvCommand += 2 *)
    assert (AKc : forall z, AKEEP pool la fl bpg bc z /\ KP pool (k * OSZ) bc z).
    { intros z. split; [ split | left; exact (not_eq_sym Hpc) ].
      - intros [(E1 & _) | (E1 & _)]; [ exact (Hpc (eq_sym E1)) | exact (Hbgc (eq_sym E1)) ].
      - intros [(E1 & _) | [E1 | E1]]; [ exact (Hpc (eq_sym E1)) | exact (Hlc (eq_sym E1)) | exact (Hfc (eq_sym E1)) ]. }
    match type of U2 with Mem.unchanged_on _ _ ?mc => assert (Lc : Mem.load Mint32 mc bc 0 = Some (Vptr cs co)) end.
    { apply (Mem.load_unchanged_on _ _ _ Mint32 bc 0 _ U2); [ intros i _; exact (conj (proj2 (AKc i)) Hcs) | ].
      apply (Mem.load_unchanged_on _ _ _ Mint32 bc 0 _ U); [ intros i _; exact (AKc i) | exact Hc0 ]. }
    apply RA.seq_inv in X6 as [(t9 & le9 & m9 & t10 & X9 & X10) | (X9 & Hne)];
      [ | exfalso; apply Hne; exact (nb_normal _ _ _ _ _ _ _ _ _ X9 eq_refl) ].
    apply RA.seq_inv in X9 as [(tk & lek & mk & tl & A11 & A12) | (A11 & Hne)];
      [ | apply RA.set_inv in A11 as (_ & _ & _ & _ & E'); contradiction ].
    apply RA.set_inv in A11 as (v2 & E2 & -> & -> & _).
    destruct (RA.ev_gvar G empty_env _ _ _ (tptr tuint) v2 Mint32 (PTree.gempty _ _) eq_refl E2) as (b2 & Hb2 & Hl2).
    rewrite Hbc in Hb2. injection Hb2 as <-. cbn [Mem.loadv] in Hl2. rewrite Ptrofs.unsigned_zero, Lc in Hl2.
    injection Hl2 as <-. clear E2.
    apply RA.assign_inv in A12 as (b' & o' & bf' & vv2 & vv & Hlv & Evv & Hcv & Has & -> & _).
    apply (RA.lv_gvar G empty_env _) in Hlv as (Hb' & -> & ->); [ | apply PTree.gempty ].
    rewrite Hbc in Hb'. injection Hb' as <-.
    pose proof (RA.store_by_value _ (tptr tuint) _ _ _ _ _ _ Mint32 eq_refl eq_refl Has) as Hs.
    rewrite Ptrofs.unsigned_zero in Hs.
    apply RA.ev_binop in Evv as (x1 & x2 & Y1 & Y2 & Y3).
    apply RA.ev_temp in Y1. rewrite PTree.gss in Y1. injection Y1 as <-.
    apply RA.ev_const in Y2. subst x2. cbn [typeof] in Y3, Hcv.
    match type of Y3 with sem_binary_operation _ _ _ _ _ _ ?mm = _ =>
      assert (E3 : sem_binary_operation G Oadd (Vptr cs co) (tptr tuint) (Vint (Int.repr 2)) tint mm
                   = Some (Vptr cs (Ptrofs.add co (Ptrofs.repr 8)))) by reflexivity end.
    rewrite E3 in Y3. injection Y3 as <-. apply RA.cast_ptr_id in Hcv. subst vv.
    apply RA.ret_inv in X10 as (-> & v9 & Ev9 & ->).
    apply RA.ev_const in Ev9. subst v9.
    cbn [outcome_result_value fn_return BS.f_bhv_cmd_spawn_water_droplet typeof] in Hov. destruct Hov as (_ & Hov).
    cbn in Hov. injection Hov as <-.
    pose proof (Mem.store_unchanged_on (fun b _ => b <> bc) _ _ _ _ _ _ Hs (fun i _ Hn => Hn eq_refl)) as U9.
    match type of U9 with Mem.unchanged_on _ _ ?mf =>
      assert (Us : Mem.unchanged_on (fun b z => KP pool (k * OSZ) b z /\ b <> bc /\ b <> sb) mx mf) end.
    { refine (Mem.unchanged_on_trans _ _ _ _
                (Mem.unchanged_on_implies _ _ _ _ U2 (fun b z Hz _ => conj (proj1 Hz) (proj2 (proj2 Hz))))
                (Mem.unchanged_on_implies _ _ _ _ U9 (fun b z Hz _ => proj1 (proj2 Hz)))). }
    assert (KPc : forall j i, 0 <= j < NSLOT -> j * OSZ + O_NEXT <= i < j * OSZ + O_PREV + 4 ->
                  KP pool (k * OSZ) pool i /\ pool <> bc /\ pool <> sb)
      by (intros j i Hj Hi; exact (conj (KP_rcell pool la fl bpg Hpl Hpf Hlf Hpb Hlb Hfb k Hk j i Hj Hi)
                                         (conj Hpc (not_eq_sym Hsp)))).
    refine (conj E (conj Hk (conj eq_refl (conj (Mem.load_store_same _ _ _ _ _ _ Hs) (conj _ (conj _ (conj _ (conj _ _)))))))).
    - exact (rings_keep pool la _ KPc (fun i => conj (or_introl (not_eq_sym Hpl)) (conj Hlc Hls)) mx _ _ Hpl Us R).
    - exact (free_keep pool fl _ KPc (fun i => conj (or_introl (not_eq_sym Hpf)) (conj Hfc Hfs)) mx _ _ Us F).
    - apply (proj2 (gfx_at_iff pool bpg Hpb G _ Hb)).
      refine (gfx_keep pool bpg _ mx _ Us _ (proj1 (gfx_at_iff pool bpg Hpb G mx Hb) Gx)).
      intros b z Hz. split; [ exact (KP_gcell pool la fl bpg Hpl Hpf Hlf Hpb Hlb Hfb k Hk b z Hz) | ].
      destruct Hz as [(-> & _) | (-> & _)]; [ exact (conj Hpc (not_eq_sym Hsp)) | exact (conj Hbgc Hbs) ].
    - refine (Mem.unchanged_on_trans _ _ _ _
                (Mem.unchanged_on_implies _ _ _ _ U (fun b z Hz _ => conj (proj1 Hz) (proj1 (proj2 Hz))))
                (Mem.unchanged_on_implies _ _ _ _ Us (fun b z Hz _ => proj2 Hz))).
    - exact (facts_store_other _ _ _ _ _ _ _ _ _ _ Hs (not_eq_sym Hpc) HF).
  Qed.
End LINKED.
