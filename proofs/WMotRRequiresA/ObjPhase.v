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
From SM64.Generated Require object_list_processor area debug surface_load platform_displacement
  object_collision.
From SM64.Proofs Require Import SymbolicLinking LinkedTwelve RealFrameLinked.
From SM64.Proofs.WMotRRequiresA Require Import FrameCalls.
From SM64.Proofs Require Generic.ClosedMem Generic.ClightClosed.
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
(* b is PRIVATE: some closing injection g (Generic.ClosedMem.closed_by:
   every readable byte of a g-mapped block names a g-mapped block) maps
   every symbol and leaves b unmapped, so no byte reachable from a global
   names b.  RESTATED 2026-11-07 (was raw: no byte outside b, readable or
   not, holds a pointer into b).  The raw form is not provable across an
   external call: CompCert's external-call properties
   (external_call_mem_inject_gen) speak only of readable bytes of mapped
   blocks, so an external call may write anything into unreadable bytes or
   unmapped blocks.  The closure form is kept by every Clight call
   (Generic.ClightClosed.funcall_closed_sep), and every use of noref reads
   it only through a closing injection. *)
Definition noref (ge : genv) (b : block) (m : mem) : Prop :=
  exists g, Generic.ClosedMem.closed_by g m /\ Generic.ClightClosed.syms_mapped ge g /\ g b = None.

(* a store into b, of anything *)
Lemma noref_store_in : forall ge b ch m z v m2,
  Mem.store ch m b z v = Some m2 -> noref ge b m -> noref ge b m2.
Proof.
  intros ge b ch m z v m2 St (g & Hc & Hs & Hb). exists g.
  split; [ exact (Generic.ClosedMem.store_private_closed _ _ _ _ _ _ _ Hc Hb St) | split; assumption ].
Qed.

(* a pointer into a symbol's block is closed *)
Lemma vok_sym_ptr : forall (ge : genv) g m id b o, Generic.ClosedMem.closed_by g m ->
  Generic.ClightClosed.syms_mapped ge g -> Genv.find_symbol ge id = Some b ->
  Generic.ClightClosed.vok g (Vptr b o).
Proof.
  intros ge g m id b o Hc Hs Hid.
  exact (Generic.ClightClosed.vok_mk_ptr _ _ _ (Generic.ClightClosed.closed_mapped_flat _ _ _ Hc (Hs _ _ Hid))).
Qed.

(* a store into a symbol's block of a value naming only a symbol's block *)
Lemma noref_store_sym : forall (ge : genv) b bg ch m z v m2,
  (exists id, Genv.find_symbol ge id = Some bg) ->
  (forall x o, v = Vptr x o -> exists id, Genv.find_symbol ge id = Some x) ->
  Mem.store ch m bg z v = Some m2 -> noref ge b m -> noref ge b m2.
Proof.
  intros ge b bg ch m z v m2 (id & Hid) Hv St (g & Hc & Hs & Hb). exists g.
  split; [ | split; assumption ].
  apply (Generic.ClosedMem.store_mapped_closed g m ch bg z v m2 Hc); [ | | exact St ].
  - exact (Generic.ClightClosed.closed_mapped_flat _ _ _ Hc (Hs _ _ Hid)).
  - destruct v as [ | | | | | x o ]; try solve [ constructor ].
    destruct (Hv x o eq_refl) as (id' & Hid').
    exact (Generic.ClightClosed.vok_mk_ptr _ _ _ (Generic.ClightClosed.closed_mapped_flat _ _ _ Hc (Hs _ _ Hid'))).
Qed.

(* a fresh block is private, before and after its alloc *)
Lemma noref_fresh : forall ge g m lo hi m1 b,
  Generic.ClosedMem.closed_by g m -> Generic.ClightClosed.syms_mapped ge g ->
  Mem.alloc m lo hi = (m1, b) -> noref ge b m /\ noref ge b m1.
Proof.
  intros ge g m lo hi m1 b Hc Hs Ha.
  destruct (Generic.ClosedMem.alloc_private _ _ _ _ _ _ Hc Ha) as (Hc1 & Hb).
  split; exists g; tauto.
Qed.

(* the frame block is allocated and private.  The callee row
   (Hobj_noref) is stated over nrv: FOUND 2026-11-07 (phantom forall),
   b may otherwise be the next fresh block, which a callee's own frame
   alloc returns. *)
Definition nrv (ge : genv) (b : block) (m : mem) : Prop := Mem.valid_block m b /\ noref ge b m.

(* Clight execution never invalidates a block (Generic.ClightClosed) *)
Notation exec_valid := Generic.ClightClosed.exec_valid.

(* a call given only closed arguments keeps nrv: the separated closedness
   (Generic.ClightClosed.funcall_closed_sep) leaves an allocated block the
   closing injection drops still dropped *)
Lemma nrv_funcall : forall ge b m fd vs t m' vr,
  eval_funcall function_entry2 ge m fd vs t m' vr ->
  (forall g, Generic.ClosedMem.closed_by g m -> Generic.ClightClosed.syms_mapped ge g ->
     Forall (Generic.ClightClosed.vok g) vs) ->
  nrv ge b m -> nrv ge b m'.
Proof.
  intros ge b m fd vs t m' vr Hev Hvs (Hv & g & Hc & Hs & Hb).
  destruct (Generic.ClightClosed.funcall_closed_sep ge m fd vs t m' vr g Hev Hc Hs (Hvs g Hc Hs))
    as (g' & _ & Hc' & Hs' & _ & Sp).
  split; [ exact (proj2 (exec_valid ge) _ _ _ _ _ _ Hev b Hv) | ].
  exists g'. split; [ exact Hc' | split; [ exact Hs' | exact (Sp b Hv Hb) ] ].
Qed.

(* a function with no parameters is called with no arguments *)
Lemma funcall_nil_args : forall ge m f vs t m' vr, fn_params f = nil ->
  eval_funcall function_entry2 ge m (Internal f) vs t m' vr -> vs = nil.
Proof.
  intros ge m f vs t m' vr Hp H. inv H.
  match goal with Hfe : function_entry2 _ _ _ _ _ _ _ |- _ => destruct Hfe as [_ _ _ _ Hb] end.
  rewrite Hp in Hb. destruct vs; [ reflexivity | cbn in Hb; discriminate Hb ].
Qed.

(* so a call of a parameterless function keeps nrv *)
Lemma nrv_keeps_nil : forall (ge : genv) f id b, fn_params f = nil ->
  (forall bf fd, Genv.find_symbol ge id = Some bf ->
     Genv.find_funct ge (Vptr bf Ptrofs.zero) = Some fd -> fd = Internal f) ->
  call_keeps ge (nrv ge b) id.
Proof.
  intros ge f id b Hp Hfd bf fd m vargs t m' vr Hs Hf Hn Hev.
  rewrite (Hfd bf fd Hs Hf) in Hev.
  pose proof (funcall_nil_args _ _ _ _ _ _ _ Hp Hev) as E. subst vargs.
  exact (nrv_funcall _ _ _ _ _ _ _ _ Hev (fun _ _ _ => Forall_nil _) Hn).
Qed.

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
(* 3b. THE STAGED WINDOW (2026-11-02).  FOUND: with one invariant P for   *)
(*     every callee, the terrain row (call_keeps P update_terrain_objects) *)
(*     was FALSE over phantom states: P holds at a frame boundary with    *)
(*     gSurfacesAllocated = NS + 88 and no time stop, and from there the  *)
(*     terrain walk loads every collision mesh a second time.  The real   *)
(*     walk starts right after clear_dynamic_surfaces, which resets the   *)
(*     counters (or, under TIME_STOP_ACTIVE, leaves them and loading is   *)
(*     off).  So the phase is staged: the clear yields P /\ R, the window  *)
(*     between the two calls (get_clock_difference and the store          *)
(*     cycleCounts[2]) keeps R, and the terrain call starts from P /\ R.   *)
(*     The window is cut out of the generated body (uo_split, tail_shape). *)
(* ---------------------------------------------------------------------- *)
Definition call_rel (ge : genv) (A B : mem -> Prop) (f : ident) : Prop :=
  forall bf fd m vargs t m' vr,
    Genv.find_symbol ge f = Some bf ->
    Genv.find_funct ge (Vptr bf Ptrofs.zero) = Some fd ->
    A m -> eval_funcall function_entry2 ge m fd vargs t m' vr -> B m'.

Definition srel (ge : genv) (e : env) (A B : mem -> Prop) (s : statement) : Prop :=
  forall le m t le' m' out, A m -> exec_stmt function_entry2 ge e le m s t le' m' out -> B m'.

Lemma srel_seq : forall ge e A B C s1 s2, srel ge e A B s1 -> srel ge e B C s2 ->
  (forall m, B m -> C m) -> srel ge e A C (Ssequence s1 s2).
Proof.
  intros ge e A B C s1 s2 H1 H2 BC le m t le' m' out HA H. inv H.
  - match goal with E1 : exec_stmt _ _ _ _ _ s1 _ _ _ _, E2 : exec_stmt _ _ _ _ _ s2 _ _ _ _ |- _ =>
      exact (H2 _ _ _ _ _ _ (H1 _ _ _ _ _ _ HA E1) E2) end.
  - match goal with E1 : exec_stmt _ _ _ _ _ s1 _ _ _ _ |- _ => exact (BC _ (H1 _ _ _ _ _ _ HA E1)) end.
Qed.

Lemma srel_call : forall ge e A B o f fty al, is_fun_ty fty = true -> e ! f = None ->
  call_rel ge A B f -> srel ge e A B (Scall o (Evar f fty) al).
Proof.
  intros ge e A B o f fty al Ht He Hk le m t le' m' out HA H. inv H.
  match goal with Hv : eval_expr _ _ _ _ (Evar f _) _ |- _ => inv Hv end.
  match goal with Hl : eval_lvalue _ _ _ _ (Evar _ _) _ _ _ |- _ => inv Hl end;
    [ congruence | ].
  destruct fty; try discriminate Ht.
  match goal with Hd : deref_loc _ _ _ _ _ _ |- _ => inv Hd end;
    match goal with Ha : access_mode _ = _ |- _ => cbn in Ha; try discriminate Ha end.
  match goal with
  | Hs : Genv.find_symbol _ f = Some _, Hff : Genv.find_funct _ _ = Some _,
    Hf : eval_funcall _ _ _ _ _ _ _ _ |- _ => exact (Hk _ _ _ _ _ _ _ Hs Hff HA Hf)
  end.
Qed.

Lemma fold_safe : forall ge P e l s, Forall (safeE ge P e) l -> safeE ge P e s ->
  safeE ge P e (fold_right Ssequence s l).
Proof.
  intros ge P e l s F Hs. induction F as [| x l Hx F IH]; [ exact Hs | ].
  cbn [fold_right]. exact (safeE_seq _ _ _ _ _ Hx IH).
Qed.

Definition is_clr (s : statement) : bool :=
  match s with Scall None (Evar f _) nil => Pos.eqb f OLP._clear_dynamic_surfaces | _ => false end.

Fixpoint peel (n : nat) (s : statement) : list statement * statement :=
  match n with
  | O => ([], s)
  | S n' =>
      match s with
      | Ssequence a b => if is_clr a then ([], s) else let '(l, r) := peel n' b in (a :: l, r)
      | _ => ([], s)
      end
  end.

Definition uo_pre : list statement := fst (peel 30 (fn_body OLP.f_update_objects)).
Definition uo_tail : statement := snd (peel 30 (fn_body OLP.f_update_objects)).

Lemma uo_split : fn_body OLP.f_update_objects = fold_right Ssequence uo_tail uo_pre.
Proof. vm_compute. reflexivity. Qed.

Definition clr_call : statement :=
  Scall None (Evar OLP._clear_dynamic_surfaces (Tfunction nil tvoid cc_default)) nil.
Definition ter_call : statement :=
  Scall None (Evar OLP._update_terrain_objects (Tfunction nil tvoid cc_default)) nil.
Definition uo_win : statement :=
  match uo_tail with Ssequence _ (Ssequence w _) => w | _ => Sskip end.
Definition uo_post : statement :=
  match uo_tail with Ssequence _ (Ssequence _ (Ssequence _ p)) => p | _ => Sskip end.

(* clear; <window>; update_terrain_objects; <the rest> *)
Lemma tail_shape : uo_tail = Ssequence clr_call (Ssequence uo_win (Ssequence ter_call uo_post)).
Proof. vm_compute. reflexivity. Qed.

Definition ol (s : statement) : list obl := match clE s with Some l => l | None => [] end.
Definition pieces : list statement := uo_win :: uo_post :: uo_pre.

Lemma pieces_cl : forallb (fun s => match clE s with Some _ => true | None => false end) pieces = true.
Proof. vm_compute. reflexivity. Qed.

Lemma list_split : uo_list = flat_map ol uo_pre
  ++ OAny OLP._clear_dynamic_surfaces (Tfunction nil tvoid cc_default) nil
  :: ol uo_win ++ OAny OLP._update_terrain_objects (Tfunction nil tvoid cc_default) nil :: ol uo_post.
Proof. vm_compute. reflexivity. Qed.

(* the callees of the pieces: every callee but the two staged ones *)
Definition rest_callees : list ident :=
  [OLP._get_current_clock; OLP._reset_debug_objectinfo; OLP._stub_debug_5; OLP._get_clock_difference;
   OLP._apply_mario_platform_displacement; OLP._detect_object_collisions;
   OLP._update_non_terrain_objects; OLP._unload_deactivated_objects; OLP._update_mario_platform;
   OLP._try_print_debug_mario_object_info].

Lemma pieces_callees :
  forallb (fun f => existsb (Pos.eqb f) rest_callees) (callees (flat_map ol pieces)) = true.
Proof. vm_compute. reflexivity. Qed.

Lemma rest_in_uo : forallb (fun f => existsb (Pos.eqb f) uo_callees) rest_callees = true.
Proof. vm_compute. reflexivity. Qed.

(* the window: t'18 = cycleCounts[0]; t'3 = get_clock_difference(t'18);
   cycleCounts[2] = t'3 *)
Definition cc2 : statement :=
  Sassign (Ederef (Ebinop Oadd (Evar OLP._cycleCounts (tarray tlong 30))
                     (Econst_int (Int.repr 2) tint) (tptr tlong)) tlong)
          (Etempvar OLP._t'3 tlong).

Lemma win_cl : clE uo_win = Some
  [OAny OLP._get_clock_difference (Tfunction (tlong :: nil) tlong cc_default) [Etempvar OLP._t'18 tlong];
   OBlk cc2].
Proof. vm_compute. reflexivity. Qed.

Lemma existsb_in : forall f l, existsb (Pos.eqb f) l = true -> In f l.
Proof.
  intros f l H. apply existsb_exists in H as (x & Hx & E). apply Pos.eqb_eq in E. subst x. exact Hx.
Qed.

Lemma piece_in : forall s o, In s pieces -> In o (ol s) -> In o uo_list.
Proof.
  intros s o Hs Ho. rewrite list_split.
  destruct Hs as [<- | [<- | Hs]].
  - apply in_or_app. right. right. apply in_or_app. left. exact Ho.
  - apply in_or_app. right. right. apply in_or_app. right. right. exact Ho.
  - apply in_or_app. left. apply in_flat_map. exists s. exact (conj Hs Ho).
Qed.

(* the window's store cycleCounts[2] = t'3 writes the frame block only *)
Lemma cc2_store : forall (ge : genv) b (R : mem -> Prop),
  (forall ch m ofs v m', R m -> Mem.store ch m b ofs v = Some m' -> R m') ->
  safeE ge R (uo_env b) cc2.
Proof.
  intros ge b R HR le m t le' m' out Hm H. unfold cc2 in H.
  inv H.
  match goal with Hl : eval_lvalue _ _ _ _ (Ederef _ _) _ _ _ |- _ => inv Hl end.
  match goal with He : eval_expr _ _ _ _ (Ebinop _ _ _ _) _ |- _ => inv He end;
    try (match goal with Hl : eval_lvalue _ _ _ _ (Ebinop _ _ _ _) _ _ _ |- _ => inv Hl end).
  match goal with He : eval_expr _ _ _ _ (Evar _ _) _ |- _ => inv He end.
  match goal with Hl : eval_lvalue _ _ _ _ (Evar _ _) _ _ _ |- _ => inv Hl end;
    [ | match goal with Hn : (uo_env b) ! _ = None |- _ =>
          unfold uo_env in Hn; rewrite PTree.gss in Hn; discriminate Hn end ].
  match goal with Hg : (uo_env b) ! _ = Some _ |- _ =>
    unfold uo_env in Hg; rewrite PTree.gss in Hg; injection Hg as <- end.
  match goal with Hd : deref_loc _ _ _ _ _ _ |- _ => inv Hd end;
    try (match goal with Ha : access_mode _ = _ |- _ => cbn in Ha; discriminate Ha end).
  match goal with Hc : eval_expr _ _ _ _ (Econst_int _ _) _ |- _ => inv Hc end;
    try (match goal with Hl : eval_lvalue _ _ _ _ (Econst_int _ _) _ _ _ |- _ => inv Hl end).
  match goal with Hb : sem_binary_operation _ _ _ _ _ _ _ = Some _ |- _ =>
    cbn in Hb; injection Hb as <- <- end.
  match goal with Ha : assign_loc _ _ _ _ _ _ _ _ |- _ => inv Ha end;
    try (match goal with Ha : access_mode _ = _ |- _ => cbn in Ha; discriminate Ha end).
  match goal with Hs : Mem.storev _ _ _ _ = Some _ |- _ =>
    cbn [Mem.storev] in Hs; exact (HR _ _ _ _ _ Hm Hs) end.
Qed.

Lemma piece_callee : forall s f fty al, In s pieces -> In (OAny f fty al) (ol s) -> In f rest_callees.
Proof.
  intros s f fty al Hs Ho.
  assert (Hin : In f (callees (flat_map ol pieces)))
    by (apply (In_callees _ _ fty al); apply in_flat_map; exists s; exact (conj Hs Ho)).
  apply existsb_in. exact (proj1 (forallb_forall _ _) pieces_callees f Hin).
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

  (* THE FRAME BLOCK'S CALLEE ROW, PROVED (2026-11-07, was Hobj_noref): every
     callee of update_objects is a parameterless function of the link, so it
     is called with no argument and keeps any allocated private block
     private (nrv_keeps_nil); the clock stubs keep anything (clock_keeps) *)
  Lemma noref_uo : forall b f, In f uo_callees -> call_keeps G (nrv G b) f.
  Proof.
    intros b f Hin. rewrite uo_callees_eq in Hin.
    assert (Hd : forall q id fn, linkorder q lp -> (prog_defmap q) ! id = Some (Gfun (Internal fn)) ->
               fn_params fn = nil -> call_keeps G (nrv G b) id)
      by (intros q id fn Hlo Hdm Hp; exact (nrv_keeps_nil G fn id b Hp (fun_of q id fn Hlo Hdm))).
    pose proof (linked12_LO_debug lp H12) as Ldb.
    pose proof (linked12_LO_surface_load lp H12) as Lsl.
    pose proof (linked12_LO_platform_displacement lp H12) as Lpd.
    pose proof (linked12_LO_object_collision lp H12) as Loc.
    cbn [In] in Hin.
    repeat (destruct Hin as [<- | Hin];
      [ lazymatch goal with
        | |- call_keeps _ _ OLP._get_current_clock => exact (proj1 (clock_keeps _))
        | |- call_keeps _ _ OLP._get_clock_difference => exact (proj2 (clock_keeps _))
        | |- call_keeps _ _ OLP._reset_debug_objectinfo =>
            apply (Hd DB.prog _ DB.f_reset_debug_objectinfo Ldb); [ vm_compute; reflexivity | reflexivity ]
        | |- call_keeps _ _ OLP._stub_debug_5 =>
            apply (Hd DB.prog _ DB.f_stub_debug_5 Ldb); [ vm_compute; reflexivity | reflexivity ]
        | |- call_keeps _ _ OLP._try_print_debug_mario_object_info =>
            apply (Hd DB.prog _ DB.f_try_print_debug_mario_object_info Ldb); [ vm_compute; reflexivity | reflexivity ]
        | |- call_keeps _ _ OLP._clear_dynamic_surfaces =>
            apply (Hd surface_load.prog _ surface_load.f_clear_dynamic_surfaces Lsl); [ vm_compute; reflexivity | reflexivity ]
        | |- call_keeps _ _ OLP._update_terrain_objects =>
            apply (Hd OLP.prog _ OLP.f_update_terrain_objects LO_olp); [ vm_compute; reflexivity | reflexivity ]
        | |- call_keeps _ _ OLP._apply_mario_platform_displacement =>
            apply (Hd platform_displacement.prog _ platform_displacement.f_apply_mario_platform_displacement Lpd);
              [ vm_compute; reflexivity | reflexivity ]
        | |- call_keeps _ _ OLP._detect_object_collisions =>
            apply (Hd object_collision.prog _ object_collision.f_detect_object_collisions Loc); [ vm_compute; reflexivity | reflexivity ]
        | |- call_keeps _ _ OLP._update_non_terrain_objects =>
            apply (Hd OLP.prog _ OLP.f_update_non_terrain_objects LO_olp); [ vm_compute; reflexivity | reflexivity ]
        | |- call_keeps _ _ OLP._unload_deactivated_objects =>
            apply (Hd OLP.prog _ OLP.f_unload_deactivated_objects LO_olp); [ vm_compute; reflexivity | reflexivity ]
        | |- call_keeps _ _ OLP._update_mario_platform =>
            apply (Hd platform_displacement.prog _ platform_displacement.f_update_mario_platform Lpd);
              [ vm_compute; reflexivity | reflexivity ]
        end
      | ]).
    destruct Hin.
  Qed.
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
    (* THE POST-CLEAR FACT (2026-11-02, the staged window 3b): what
       clear_dynamic_surfaces leaves for update_terrain_objects (on the
       link: the counters reset, or a time stop).  It reads globals only, so
       a store into a non-symbol block (the frame block) keeps it. *)
    Variable R : mem -> Prop.
    Hypothesis HR_store : forall ch m b ofs v m', Ple (Genv.genv_next G) b -> R m ->
      Mem.store ch m b ofs v = Some m' -> R m'.

    (* ---- THE FRAME ROWS (the stack array cycleCounts[30]) ---- *)
    (* FB: what the invariant knows of a frame block (on the link: past
       every symbol, and outside GOAL 1's chase set) *)
    Variable FB : block -> Prop.
    Hypothesis HFB : forall b, FB b -> Ple (Genv.genv_next G) b.
    (* P does not read a private frame block *)
    Hypothesis Hobj_blind : forall b m m', FB b -> P m -> noref G b m ->
      Mem.unchanged_on (fun b' _ => b' <> b) m m' -> P m'.
    (* the frame block, allocated from a P-memory, is a frame block,
       private before and after its alloc *)
    Hypothesis Hobj_fresh : forall m m1 b, P m -> Mem.alloc m 0 240 = (m1, b) ->
      FB b /\ noref G b m /\ noref G b m1.
    (* no callee makes an allocated private block reachable (nrv: FOUND
       2026-11-07, see nrv; on the link PROVED, noref_uo) *)
    Hypothesis Hobj_noref : forall b f, In f uo_callees -> call_keeps G (nrv G b) f.
    (* update_objects' own stores (cycleCounts[i], gTimeStopState,
       gNumRoomedObjects*, gCheckingSurfaceCollisionsForCamera, gObjectLists,
       gPrevFrameObjectCount) and area_update_objects' gAreaUpdateCounter++ *)
    Hypothesis Hobj_stores : forall b s, In (OBlk s) uo_list -> FB b ->
      safeE G (fun m => P m /\ noref G b m) (uo_env b) s.
    Hypothesis Hobj_counter : forall le m t le' m' out,
      P m -> exec_stmt function_entry2 G empty_env le m auo_counter t le' m' out -> P m'.

    (* ---- THE STAGE ROWS: one per real callee of update_objects ---- *)
    Hypothesis Hobj_debug : call_keeps G P OLP._reset_debug_objectinfo
      /\ call_keeps G P OLP._stub_debug_5 /\ call_keeps G P OLP._try_print_debug_mario_object_info.
    (* staged (3b): the clear yields R, the terrain walk starts from it.
       FOUND 2026-11-02: the single-P terrain row (call_keeps P) is false at
       gSurfacesAllocated = NS + 88 with no time stop (a box adds 12 more). *)
    Hypothesis Hobj_surfaces : call_rel G P (fun m => P m /\ R m) OLP._clear_dynamic_surfaces.
    Hypothesis Hobj_terrain : call_rel G (fun m => P m /\ R m) P OLP._update_terrain_objects.
    Hypothesis Hobj_platform : call_keeps G P OLP._apply_mario_platform_displacement.
    Hypothesis Hobj_collisions : call_keeps G P OLP._detect_object_collisions.
    Hypothesis Hobj_nonterrain : call_keeps G P OLP._update_non_terrain_objects.
    Hypothesis Hobj_unload : call_keeps G P OLP._unload_deactivated_objects.
    Hypothesis Hobj_mplat : call_keeps G P OLP._update_mario_platform.

    Lemma rest_P : forall f, In f rest_callees -> call_keeps G P f.
    Proof.
      intros f Hin. unfold rest_callees in Hin.
      destruct (Hclock P) as (Hc1 & Hc2).
      destruct Hobj_debug as (Hd1 & Hd2 & Hd3).
      repeat (destruct Hin as [<- | Hin]; [ assumption | ]). destruct Hin.
    Qed.

    Lemma rest_uo : forall f, In f rest_callees -> In f uo_callees.
    Proof. intros f Hin. apply existsb_in. exact (proj1 (forallb_forall _ _) rest_in_uo f Hin). Qed.

    Lemma env_none : forall b f, In f uo_callees -> (uo_env b) ! f = None.
    Proof.
      intros b f Hin. unfold uo_env. rewrite PTree.gso, PTree.gempty; [ reflexivity | ].
      pose proof uo_env_callees as E. unfold uo_callees in E. rewrite forallb_forall in E.
      specialize (E f Hin). intros ->. rewrite Pos.eqb_refl in E. discriminate E.
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
      destruct (Hobj_fresh _ _ _ HP Hal) as (Hfb & Hn0 & Hn1).
      pose proof (HFB _ Hfb) as Hple.
      match goal with Hal : Mem.alloc m 0 240 = (?m1, b1) |- _ => rename m1 into ma end.
      assert (HP1 : P ma).
      { apply (Hobj_blind b1 m ma Hfb HP Hn0).
        apply (Mem.unchanged_on_implies (fun _ _ => True)); [ | intros; exact I ].
        exact (Mem.alloc_unchanged_on _ _ _ _ _ _ Hal). }
      set (Q := fun m0 => P m0 /\ nrv G b1 m0).
      (* every piece outside the window's two calls keeps Q *)
      assert (Hpc : forall s, In s pieces -> safeE G Q (uo_env b1) s).
      { intros s Hs.
        pose proof (proj1 (forallb_forall _ _) pieces_cl s Hs) as Hc. cbv beta in Hc.
        destruct (clE s) as [l|] eqn:El; [ | discriminate Hc ].
        apply (clE_sound G Q (uo_env b1) s l El).
        assert (Hol : ol s = l) by (unfold ol; rewrite El; reflexivity).
        rewrite Forall_forall. intros [f | f fty al | s'] Ho; rewrite <- Hol in Ho.
        - exact (In_no_ocall _ _ uo_no_ocall (piece_in _ _ Hs Ho)).
        - pose proof (piece_callee _ _ _ _ Hs Ho) as Hr. split.
          + exact (env_none b1 f (rest_uo f Hr)).
          + exact (call_keeps_and _ _ _ _ (rest_P f Hr) (Hobj_noref b1 f (rest_uo f Hr))).
        - intros le0 m0 t0 le0' m0' out0 (Hp & Hv & Hn) Hx0.
          destruct (Hobj_stores b1 s' (piece_in _ _ Hs Ho) Hfb _ _ _ _ _ _ (conj Hp Hn) Hx0) as (Hp' & Hn').
          exact (conj Hp' (conj (proj1 (exec_valid G) _ _ _ _ _ _ _ _ Hx0 b1 Hv) Hn')). }
      set (QR := fun m0 => Q m0 /\ R m0).
      assert (Hin_clr : In OLP._clear_dynamic_surfaces uo_callees)
        by (rewrite uo_callees_eq; cbn; tauto).
      assert (Hin_ter : In OLP._update_terrain_objects uo_callees)
        by (rewrite uo_callees_eq; cbn; tauto).
      assert (HT : safeE G Q (uo_env b1) uo_tail).
      { rewrite tail_shape.
        apply (srel_seq G (uo_env b1) Q QR Q); [ | | intros m0 (H0 & _); exact H0 ].
        - apply srel_call; [ reflexivity | exact (env_none b1 _ Hin_clr) | ].
          intros bf fd m0 vargs0 t0 m0' vr0 Hs Hf (Hp & Hn) Hc.
          destruct (Hobj_surfaces _ _ _ _ _ _ _ Hs Hf Hp Hc) as (Hp' & Hr').
          exact (conj (conj Hp' (Hobj_noref b1 _ Hin_clr _ _ _ _ _ _ _ Hs Hf Hn Hc)) Hr').
        - apply (srel_seq G (uo_env b1) QR QR Q); [ | | intros m0 (H0 & _); exact H0 ].
          + intros le0 m0 t0 le0' m0' out0 (Hq & Hr) Hx0. split.
            * exact (Hpc uo_win (or_introl eq_refl) _ _ _ _ _ _ Hq Hx0).
            * refine (clE_sound G R (uo_env b1) uo_win _ win_cl _ _ _ _ _ _ _ Hr Hx0).
              constructor; [ split; [ exact (env_none b1 _ ltac:(rewrite uo_callees_eq; cbn; tauto))
                                    | exact (proj2 (Hclock R)) ] | ].
              constructor; [ | constructor ].
              exact (cc2_store G b1 R (fun ch m1 ofs v m1' Hr1 Hs1 => HR_store ch m1 b1 ofs v m1' Hple Hr1 Hs1)).
          + apply (srel_seq G (uo_env b1) QR Q Q); [ | | intros m0 H0; exact H0 ].
            * apply srel_call; [ reflexivity | exact (env_none b1 _ Hin_ter) | ].
              intros bf fd m0 vargs0 t0 m0' vr0 Hs Hf ((Hp & Hn) & Hr) Hc.
              exact (conj (Hobj_terrain _ _ _ _ _ _ _ Hs Hf (conj Hp Hr) Hc)
                          (Hobj_noref b1 _ Hin_ter _ _ _ _ _ _ _ Hs Hf Hn Hc)).
            * exact (Hpc uo_post (or_intror (or_introl eq_refl))). }
      assert (Hbody : safeE G Q (uo_env b1) (fn_body OLP.f_update_objects)).
      { rewrite uo_split. apply fold_safe; [ | exact HT ].
        rewrite Forall_forall. intros s Hs. exact (Hpc s (or_intror (or_intror Hs))). }
      match goal with Hx : exec_stmt _ _ _ _ _ (fn_body _) _ _ _ _ |- _ =>
        destruct (Hbody _ _ _ _ _ _ (conj HP1 (conj (Mem.valid_new_block _ _ _ _ _ Hal) Hn1)) Hx)
          as (HP2 & _ & Hn2) end.
      match goal with Hfr : Mem.free_list _ _ = Some _ |- _ =>
        change (blocks_of_env G (uo_env b1)) with [(b1, 0, 240)] in Hfr;
        apply free_list_one in Hfr; rename Hfr into Hfree end.
      apply (Hobj_blind b1 _ _ Hfb HP2 Hn2).
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
