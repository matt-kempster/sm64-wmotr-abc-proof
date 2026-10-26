(* ======================================================================= *)
(* ObjPhase.v -- the OBJECTS phase as ONE real call.                       *)
(*                                                                         *)
(* play_mode_normal (level_update.c) calls area_update_objects() between   *)
(* its two slices (LevelFlank.level_pre_call / level_post_call).  That     *)
(* call IS the objects phase: gAreaUpdateCounter++ and update_objects(0),  *)
(* whose body (object_list_processor.c:603) runs, in this order,           *)
(*   clear_dynamic_surfaces; update_terrain_objects;                       *)
(*   apply_mario_platform_displacement; detect_object_collisions;          *)
(*   update_non_terrain_objects (Mario's object's script reaches           *)
(*   execute_mario_action here); unload_deactivated_objects;               *)
(*   update_mario_platform                                                 *)
(* plus the debug / clock calls and its own stores.                       *)
(*                                                                         *)
(* objects_call is that real eval_funcall.  objects_keep PROVES, for any   *)
(* invariant P, that the call keeps P from ONE ROW PER REAL CALLEE of      *)
(* update_objects (the rows below; the callee list is computed from the    *)
(* generated body, uo_callees_eq) and the body's own stores.  The two      *)
(* clock calls are PROVED (debug.c: they return 0 and touch no memory).    *)
(* The body's stack array cycleCounts[30] is handled by noref: the frame   *)
(* block is fresh, no stored pointer names it, and P does not read it.     *)
(* ======================================================================= *)

From Coq Require Import List ZArith.
From compcert Require Import Coqlib Maps AST Integers Values Memory Globalenvs
  Ctypes Ctypesdefs Cop Clight ClightBigstep Events Linking.
From SM64.Generated Require object_list_processor area debug.
From SM64.Proofs Require Import SymbolicLinking LinkedTwelve RealFrameLinked.
From SM64.Proofs.WMotRRequiresA Require Import FrameCalls.
Import ListNotations.

Module OLP := SM64.Generated.object_list_processor.
Module AR := SM64.Generated.area.
Module DB := SM64.Generated.debug.

(* ---------------------------------------------------------------------- *)
(* 1. A body walk in a given local environment (FrameCalls' checker is     *)
(*    for bodies with no stack variables).                                 *)
(* ---------------------------------------------------------------------- *)
Section Body.
  Variable ge : genv.
  Variable P : mem -> Prop.
  Variable e : env.

  Fixpoint clE (s : statement) : option (list obl) :=
    match s with
    | Sskip | Sset _ _ => Some []
    | Sassign _ _ => Some [OBlk s]
    | Scall _ (Evar f fty) al => if is_fun_ty fty then Some [OAny f fty al] else None
    | Ssequence s1 s2 =>
        if straight s && has_asg s then Some [OBlk s] else ocat (clE s1) (clE s2)
    | Sifthenelse _ s1 s2 => ocat (clE s1) (clE s2)
    | _ => None
    end.

  Definition safeE (s : statement) : Prop :=
    forall le m t le' m' out,
      P m -> exec_stmt function_entry2 ge e le m s t le' m' out -> P m'.

  (* a call of the function bound to f keeps P, with any arguments *)
  Definition call_keeps (f : ident) : Prop :=
    forall bf fd m vargs t m' vr,
      Genv.find_symbol ge f = Some bf ->
      Genv.find_funct ge (Vptr bf Ptrofs.zero) = Some fd ->
      P m -> eval_funcall function_entry2 ge m fd vargs t m' vr -> P m'.

  Definition obl_okE (o : obl) : Prop :=
    match o with
    | OCall _ => False
    | OAny f _ _ => e ! f = None /\ call_keeps f
    | OBlk s => safeE s
    end.

  Lemma safeE_seq : forall s1 s2, safeE s1 -> safeE s2 -> safeE (Ssequence s1 s2).
  Proof.
    intros s1 s2 H1 H2 le m t le' m' out HP H. inv H.
    - match goal with E1 : exec_stmt _ _ _ _ _ s1 _ _ _ _, E2 : exec_stmt _ _ _ _ _ s2 _ _ _ _ |- _ =>
        exact (H2 _ _ _ _ _ _ (H1 _ _ _ _ _ _ HP E1) E2) end.
    - match goal with E1 : exec_stmt _ _ _ _ _ s1 _ _ _ _ |- _ => exact (H1 _ _ _ _ _ _ HP E1) end.
  Qed.

  Lemma safeE_if : forall a s1 s2, safeE s1 -> safeE s2 -> safeE (Sifthenelse a s1 s2).
  Proof.
    intros a s1 s2 H1 H2 le m t le' m' out HP H. inv H.
    match goal with E : exec_stmt _ _ _ _ _ (if ?b then _ else _) _ _ _ _ |- _ =>
      destruct b; [ exact (H1 _ _ _ _ _ _ HP E) | exact (H2 _ _ _ _ _ _ HP E) ] end.
  Qed.

  Lemma safeE_skip : safeE Sskip.
  Proof. intros le m t le' m' out HP H. inv H. exact HP. Qed.
  Lemma safeE_set : forall i a, safeE (Sset i a).
  Proof. intros i a le m t le' m' out HP H. inv H. exact HP. Qed.

  Lemma safeE_call : forall o f fty al, is_fun_ty fty = true -> e ! f = None ->
    call_keeps f -> safeE (Scall o (Evar f fty) al).
  Proof.
    intros o f fty al Ht He Hk le m t le' m' out HP H. inv H.
    match goal with Hv : eval_expr _ _ _ _ (Evar f _) _ |- _ => inv Hv end.
    match goal with Hl : eval_lvalue _ _ _ _ (Evar _ _) _ _ _ |- _ => inv Hl end;
      [ congruence | ].
    destruct fty; try discriminate Ht.
    match goal with Hd : deref_loc _ _ _ _ _ _ |- _ => inv Hd end;
      match goal with Ha : access_mode _ = _ |- _ => cbn in Ha; try discriminate Ha end.
    match goal with
    | Hs : Genv.find_symbol _ f = Some _, Hff : Genv.find_funct _ _ = Some _,
      Hf : eval_funcall _ _ _ _ _ _ _ _ |- _ => exact (Hk _ _ _ _ _ _ _ Hs Hff HP Hf)
    end.
  Qed.

  Fixpoint clE_sound (s : statement) :
    forall l, clE s = Some l -> Forall obl_okE l -> safeE s.
  Proof.
    destruct s; intros ol E F; cbn [clE] in E; try discriminate E.
    - exact safeE_skip.
    - injection E as <-. inversion F; subst. exact H1.
    - exact (safeE_set _ _).
    - destruct e0; try discriminate E.
      destruct (is_fun_ty t) eqn:Ht; [| discriminate E].
      injection E as <-. inversion F; subst. destruct H1 as (He & Hk).
      exact (safeE_call o i t l Ht He Hk).
    - destruct (straight (Ssequence s1 s2) && has_asg (Ssequence s1 s2)).
      + injection E as <-. inversion F; subst. exact H1.
      + destruct (ocat_some _ _ _ E) as (x & y & Hx & Hy & ->).
        apply Forall_app in F. destruct F as (Fx & Fy).
        exact (safeE_seq _ _ (clE_sound _ _ Hx Fx) (clE_sound _ _ Hy Fy)).
    - destruct (ocat_some _ _ _ E) as (x & y & Hx & Hy & ->).
      apply Forall_app in F. destruct F as (Fx & Fy).
      exact (safeE_if _ _ _ (clE_sound _ _ Hx Fx) (clE_sound _ _ Hy Fy)).
  Qed.
End Body.

(* ---------------------------------------------------------------------- *)
(* 2. The frame block.                                                     *)
(* ---------------------------------------------------------------------- *)
(* no byte outside b holds a pointer into b *)
Definition noref (b : block) (m : mem) : Prop :=
  forall b' ofs, b' <> b ->
    match ZMap.get ofs ((Mem.mem_contents m) !! b') with
    | Fragment (Vptr x _) _ _ => x <> b
    | _ => True
    end.

Section TrAlloc.
Local Transparent Mem.alloc.
Lemma noref_alloc : forall m lo hi m1 b, Mem.alloc m lo hi = (m1, b) -> noref b m1 -> noref b m.
Proof.
  intros m lo hi m1 b Ha Hn b' ofs Hne. specialize (Hn b' ofs Hne).
  unfold Mem.alloc in Ha. injection Ha as <- <-. cbn in Hn.
  rewrite PMap.gso in Hn by exact Hne. exact Hn.
Qed.
End TrAlloc.

Lemma free_list_one : forall m b lo hi m',
  Mem.free_list m [(b, lo, hi)] = Some m' -> Mem.free m b lo hi = Some m'.
Proof.
  intros m b lo hi m' H. cbn in H.
  destruct (Mem.free m b lo hi) as [m1|] eqn:E; [ | discriminate H ].
  injection H as <-. reflexivity.
Qed.

(* ---------------------------------------------------------------------- *)
(* 3. The generated bodies, read by the checkers.                         *)
(* ---------------------------------------------------------------------- *)
Definition uo_list : list obl :=
  match clE (fn_body OLP.f_update_objects) with Some l => l | None => [] end.

Lemma uo_list_eq : clE (fn_body OLP.f_update_objects) = Some uo_list.
Proof. vm_compute. reflexivity. Qed.

Definition callees (l : list obl) : list ident :=
  flat_map (fun o => match o with OAny f _ _ => [f] | _ => [] end) l.

Definition no_ocall (l : list obl) : bool :=
  forallb (fun o => match o with OCall _ => false | _ => true end) l.

Definition uo_callees : list ident := callees uo_list.

(* update_objects' callees, in body order (computed from the generated body) *)
Lemma uo_callees_eq : uo_callees =
  [OLP._get_current_clock; OLP._reset_debug_objectinfo; OLP._stub_debug_5;
   OLP._get_clock_difference; OLP._clear_dynamic_surfaces;
   OLP._get_clock_difference; OLP._update_terrain_objects;
   OLP._apply_mario_platform_displacement;
   OLP._get_clock_difference; OLP._detect_object_collisions;
   OLP._get_clock_difference; OLP._update_non_terrain_objects;
   OLP._get_clock_difference; OLP._unload_deactivated_objects;
   OLP._get_clock_difference; OLP._update_mario_platform;
   OLP._get_clock_difference; OLP._try_print_debug_mario_object_info].
Proof. vm_compute. reflexivity. Qed.

Lemma uo_no_ocall : no_ocall uo_list = true.
Proof. vm_compute. reflexivity. Qed.

(* the body's own store blocks *)
Definition is_blk (o : obl) : bool := match o with OBlk _ => true | _ => false end.
Definition uo_blks : list obl := filter is_blk uo_list.

(* the frame's one stack variable *)
Definition uo_env (b : block) : env :=
  PTree.set OLP._cycleCounts (b, tarray tlong 30) empty_env.

Lemma uo_vars : fn_vars OLP.f_update_objects = [(OLP._cycleCounts, tarray tlong 30)].
Proof. reflexivity. Qed.

Lemma uo_env_callees : forallb (fun f => negb (Pos.eqb f OLP._cycleCounts)) uo_callees = true.
Proof. vm_compute. reflexivity. Qed.

Lemma In_callees : forall l f fty al, In (OAny f fty al) l -> In f (callees l).
Proof.
  induction l as [| o l IH]; intros f fty al H; [ destruct H | ].
  destruct H as [-> | H]; cbn.
  - left. reflexivity.
  - apply in_or_app. right. exact (IH _ _ _ H).
Qed.

Lemma In_no_ocall : forall l f, no_ocall l = true -> ~ In (OCall f) l.
Proof.
  intros l f H Hin. unfold no_ocall in H. rewrite forallb_forall in H.
  specialize (H _ Hin). discriminate H.
Qed.

(* area_update_objects: gAreaUpdateCounter++; update_objects(0) *)
Definition auo_counter : statement :=
  Ssequence (Sset AR._t'1 (Evar AR._gAreaUpdateCounter tushort))
    (Sassign (Evar AR._gAreaUpdateCounter tushort)
      (Ebinop Oadd (Etempvar AR._t'1 tushort) (Econst_int (Int.repr 1) tint) tint)).

Definition auo_obls : list obl :=
  [OBlk auo_counter;
   OAny AR._update_objects (Tfunction (tint :: nil) tvoid cc_default)
        (Econst_int (Int.repr 0) tint :: nil)].

Lemma auo_cl : cl xH tvoid (fn_body AR.f_area_update_objects) = Some auo_obls.
Proof. vm_compute. reflexivity. Qed.

Lemma auo_vars : fn_vars AR.f_area_update_objects = [].
Proof. reflexivity. Qed.

Lemma call_keeps_and : forall ge P Q f,
  call_keeps ge P f -> call_keeps ge Q f -> call_keeps ge (fun m => P m /\ Q m) f.
Proof.
  intros ge P Q f HP HQ bf fd m vargs t m' vr Hs Hf (Hp & Hq) Hev.
  exact (conj (HP _ _ _ _ _ _ _ Hs Hf Hp Hev) (HQ _ _ _ _ _ _ _ Hs Hf Hq Hev)).
Qed.

(* ---------------------------------------------------------------------- *)
(* 4. THE OBJECTS CALL, on the link.                                       *)
(* ---------------------------------------------------------------------- *)
Definition objects_call (lp : Clight.program) (m m' : mem) : Prop :=
  exists t vr, eval_funcall function_entry2 (lp_ge lp) m
                 (Internal AR.f_area_update_objects) [] t m' vr.

Section Link.
  Variable lp : Clight.program.
  Hypothesis H12 : linked12 lp.
  Notation G := (lp_ge lp).

  Lemma LO_olp : linkorder OLP.prog lp.
  Proof.
    exact (link_chain_linkorder_in _ _ _ _ (in_cons _ _ _ (in_cons _ _ _ (in_cons _ _ _ (in_cons _ _ _ (in_cons _ _ _ (in_cons _ _ _ (in_cons _ _ _ (in_cons _ _ _ (in_cons _ _ _ (in_cons _ _ _ (in_cons _ _ _ (in_cons _ _ _ (in_cons _ _ _ (in_cons _ _ _ (in_cons _ _ _ (in_eq _ _)))))))))))))))) H12).
  Qed.

  Lemma dm_uo : (prog_defmap OLP.prog) ! OLP._update_objects
                = Some (Gfun (Internal OLP.f_update_objects)).
  Proof. vm_compute. reflexivity. Qed.
  Lemma dm_gcc : (prog_defmap DB.prog) ! DB._get_current_clock
                 = Some (Gfun (Internal DB.f_get_current_clock)).
  Proof. vm_compute. reflexivity. Qed.
  Lemma dm_gcd : (prog_defmap DB.prog) ! DB._get_clock_difference
                 = Some (Gfun (Internal DB.f_get_clock_difference)).
  Proof. vm_compute. reflexivity. Qed.

  Lemma fun_of : forall q id f, linkorder q lp ->
    (prog_defmap q) ! id = Some (Gfun (Internal f)) ->
    forall b fd, Genv.find_symbol G id = Some b ->
      Genv.find_funct G (Vptr b Ptrofs.zero) = Some fd -> fd = Internal f.
  Proof.
    intros q id f Hlo Hdm b fd Hb Hf.
    destruct (linkorder_resolves_internal lp q _ _ Hlo Hdm) as (b' & Hs & Hp).
    unfold lp_ge in Hb. rewrite Hb in Hs. injection Hs as <-.
    rewrite Genv.find_funct_find_funct_ptr in Hf. unfold lp_ge in Hf.
    rewrite Hp in Hf. injection Hf as <-. reflexivity.
  Qed.

  (* debug.c's clock stubs return 0 and touch no memory: PROVED *)
  Lemma clock_keeps : forall Q,
    call_keeps G Q OLP._get_current_clock /\ call_keeps G Q OLP._get_clock_difference.
  Proof.
    intros Q. split; intros bf fd m vargs t m' vr Hs Hf HQ Hev.
    - rewrite (fun_of _ _ _ (linked12_LO_debug lp H12) dm_gcc bf fd Hs Hf) in Hev.
      exact (funcall_safe G xH tvoid Q DB.f_get_current_clock [] vargs m t m' vr
               eq_refl eq_refl (Forall_nil _) HQ Hev).
    - rewrite (fun_of _ _ _ (linked12_LO_debug lp H12) dm_gcd bf fd Hs Hf) in Hev.
      exact (funcall_safe G xH tvoid Q DB.f_get_clock_difference [] vargs m t m' vr
               eq_refl eq_refl (Forall_nil _) HQ Hev).
  Qed.

  Lemma auo_fun : forall bf fd, Genv.find_symbol G AR._update_objects = Some bf ->
    Genv.find_funct G (Vptr bf Ptrofs.zero) = Some fd -> fd = Internal OLP.f_update_objects.
  Proof. exact (fun_of _ _ _ LO_olp dm_uo). Qed.
End Link.

(* ---------------------------------------------------------------------- *)
(* 5. THE PHASE THEOREM, over the two link facts above (proved on every   *)
(*    twelve-TU link: clock_keeps, auo_fun) and the rows.                  *)
(* ---------------------------------------------------------------------- *)
Section Phase.
  Variable lp : Clight.program.
  Notation G := (lp_ge lp).
  Hypothesis Hclock : forall Q,
    call_keeps G Q OLP._get_current_clock /\ call_keeps G Q OLP._get_clock_difference.
  Hypothesis Hauo : forall bf fd, Genv.find_symbol G AR._update_objects = Some bf ->
    Genv.find_funct G (Vptr bf Ptrofs.zero) = Some fd -> fd = Internal OLP.f_update_objects.

  Section Rows.
    Variable P : mem -> Prop.

    (* ---- THE FRAME ROWS (the stack array cycleCounts[30]) ---- *)
    (* P does not read a non-symbol block that no stored pointer names *)
    Hypothesis Hobj_blind : forall b m m', Ple (Genv.genv_next G) b -> P m -> noref b m ->
      Mem.unchanged_on (fun b' _ => b' <> b) m m' -> P m'.
    (* the frame block, allocated from a P-memory, is a non-symbol block that
       no stored pointer names *)
    Hypothesis Hobj_fresh : forall m m1 b, P m -> Mem.alloc m 0 240 = (m1, b) ->
      Ple (Genv.genv_next G) b /\ noref b m1.
    (* no callee stores a pointer into a non-symbol block nothing names *)
    Hypothesis Hobj_noref : forall b f, In f uo_callees -> Ple (Genv.genv_next G) b ->
      call_keeps G (noref b) f.
    (* update_objects' own stores (cycleCounts[i], gTimeStopState,
       gNumRoomedObjects*, gCheckingSurfaceCollisionsForCamera, gObjectLists,
       gPrevFrameObjectCount) and area_update_objects' gAreaUpdateCounter++ *)
    Hypothesis Hobj_stores : forall b s, In (OBlk s) uo_list -> Ple (Genv.genv_next G) b ->
      safeE G (fun m => P m /\ noref b m) (uo_env b) s.
    Hypothesis Hobj_counter : forall le m t le' m' out,
      P m -> exec_stmt function_entry2 G empty_env le m auo_counter t le' m' out -> P m'.

    (* ---- THE STAGE ROWS: one per real callee of update_objects ---- *)
    Hypothesis Hobj_debug : call_keeps G P OLP._reset_debug_objectinfo
      /\ call_keeps G P OLP._stub_debug_5 /\ call_keeps G P OLP._try_print_debug_mario_object_info.
    Hypothesis Hobj_surfaces : call_keeps G P OLP._clear_dynamic_surfaces.
    Hypothesis Hobj_terrain : call_keeps G P OLP._update_terrain_objects.
    Hypothesis Hobj_platform : call_keeps G P OLP._apply_mario_platform_displacement.
    Hypothesis Hobj_collisions : call_keeps G P OLP._detect_object_collisions.
    Hypothesis Hobj_nonterrain : call_keeps G P OLP._update_non_terrain_objects.
    Hypothesis Hobj_unload : call_keeps G P OLP._unload_deactivated_objects.
    Hypothesis Hobj_mplat : call_keeps G P OLP._update_mario_platform.

    Lemma uo_calls_P : forall f, In f uo_callees -> call_keeps G P f.
    Proof.
      intros f Hin. rewrite uo_callees_eq in Hin.
      destruct (Hclock P) as (Hc1 & Hc2).
      destruct Hobj_debug as (Hd1 & Hd2 & Hd3).
      repeat (destruct Hin as [<- | Hin]; [ assumption | ]). destruct Hin.
    Qed.

    Theorem uo_keeps : forall m vargs t m' vr,
      P m -> eval_funcall function_entry2 G m (Internal OLP.f_update_objects) vargs t m' vr -> P m'.
    Proof.
      intros m vargs t m' vr HP Hev. inv Hev.
      match goal with Hfe : function_entry2 _ _ _ _ _ _ _ |- _ => inv Hfe end.
      match goal with Hav : alloc_variables _ _ _ _ _ _ |- _ =>
        rewrite uo_vars in Hav; inv Hav end.
      match goal with Hav : alloc_variables _ _ _ nil _ _ |- _ => inv Hav end.
      match goal with Ha : Mem.alloc _ 0 _ = (_, ?b) |- _ =>
        change (sizeof G (tarray tlong 30)) with 240 in Ha; rename Ha into Hal; rename b into b1 end.
      destruct (Hobj_fresh _ _ _ HP Hal) as (Hple & Hn1).
      match goal with Hal : Mem.alloc m 0 240 = (?m1, b1) |- _ => rename m1 into ma end.
      assert (HP1 : P ma).
      { apply (Hobj_blind b1 m ma Hple HP (noref_alloc _ _ _ _ _ Hal Hn1)).
        apply (Mem.unchanged_on_implies (fun _ _ => True)); [ | intros; exact I ].
        exact (Mem.alloc_unchanged_on _ _ _ _ _ _ Hal). }
      assert (F : Forall (obl_okE G (fun m0 => P m0 /\ noref b1 m0) (uo_env b1)) uo_list).
      { rewrite Forall_forall. intros [f | f fty al | s] Ho.
        - exact (In_no_ocall _ _ uo_no_ocall Ho).
        - pose proof (In_callees _ _ _ _ Ho) as Hin. split.
          + unfold uo_env. rewrite PTree.gso, PTree.gempty; [ reflexivity | ].
            pose proof uo_env_callees as E. unfold uo_callees in E. rewrite forallb_forall in E.
            specialize (E f Hin). intros ->. rewrite Pos.eqb_refl in E. discriminate E.
          + exact (call_keeps_and _ _ _ _ (uo_calls_P f Hin) (Hobj_noref b1 f Hin Hple)).
        - exact (Hobj_stores b1 s Ho Hple). }
      match goal with Hx : exec_stmt _ _ _ _ _ (fn_body _) _ _ _ _ |- _ =>
        destruct (clE_sound _ _ _ _ _ uo_list_eq F _ _ _ _ _ _ (conj HP1 Hn1) Hx) as (HP2 & Hn2) end.
      match goal with Hfr : Mem.free_list _ _ = Some _ |- _ =>
        change (blocks_of_env G (uo_env b1)) with [(b1, 0, 240)] in Hfr;
        apply free_list_one in Hfr; rename Hfr into Hfree end.
      apply (Hobj_blind b1 _ _ Hple HP2 Hn2).
      apply (Mem.free_unchanged_on _ _ _ _ _ _ Hfree). intros i _ N. exact (N eq_refl).
    Qed.

    (* THE OBJECTS PHASE: the real area_update_objects call keeps P *)
    Theorem objects_keep : forall m m', P m -> objects_call lp m m' -> P m'.
    Proof.
      intros m m' HP (t & vr & Hev).
      refine (funcall_safe G xH tvoid P AR.f_area_update_objects auo_obls [] m t m' vr
                auo_vars auo_cl _ HP Hev).
      constructor; [ exact Hobj_counter | constructor; [ | constructor ] ].
      intros le bf fd m0 tyargs tyres cc vargs t0 m0' vr0 _ Hs Hf _ _ HP0 Hc.
      rewrite (Hauo bf fd Hs Hf) in Hc.
      exact (uo_keeps m0 vargs t0 m0' vr0 HP0 Hc).
    Qed.
  End Rows.
End Phase.
