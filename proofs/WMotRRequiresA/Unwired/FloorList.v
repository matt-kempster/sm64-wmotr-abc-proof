(* ====================================================================== *)
(* FloorList (unwired, GOAL 2): the VALUE contract of the real             *)
(* find_floor_from_list (surface_collision.c), proved from its generated   *)
(* Clight body.                                                            *)
(*                                                                          *)
(* The loop walks a SurfaceNode list.  Every execution ends in one of two  *)
(* ways:                                                                    *)
(*   - NULL, memory unchanged (no floor below the point);                  *)
(*   - a surface pointer READ FROM A NODE OF THE LIST (on_list), with one  *)
(*     float written through pheight and nothing else.                     *)
(* This is the brick the GOAL-2 executor's find_floor contract needs: the  *)
(* floor find_floor returns is a surface FROM THE PARTITION LIST, so a     *)
(* world invariant over the partition lists can speak about it (its type,  *)
(* its block).  No list shape is assumed: on_list is whatever the loads    *)
(* reach.                                                                  *)
(* ====================================================================== *)

From Coq Require Import ZArith List Lia.
From compcert Require Import Coqlib Errors Maps AST Integers Floats Values Memory Events
  Globalenvs Ctypes Cop Clightdefs Clight ClightBigstep.
From SM64.Generated Require surface_collision.
Import ListNotations.

Local Notation SC := surface_collision.prog.

(* SurfaceNode = { next @ 0; surface @ 4 } (pinned below) *)
Definition SN_NEXT : Z := 0.
Definition SN_SURF : Z := 4.

(* s is the surface field of some node reachable from nd by next-loads *)
Inductive on_list (m : mem) : val -> val -> Prop :=
  | ol_here : forall bn on s,
      Mem.loadv Mint32 m (Vptr bn (Ptrofs.add on (Ptrofs.repr SN_SURF))) = Some s ->
      on_list m (Vptr bn on) s
  | ol_next : forall bn on nx s,
      Mem.loadv Mint32 m (Vptr bn (Ptrofs.add on (Ptrofs.repr SN_NEXT))) = Some nx ->
      on_list m nx s -> on_list m (Vptr bn on) s.

(* the genv's composites include the TU's (true of any linked program) *)
Definition cenv_has (ge : genv) : Prop :=
  forall id co, (prog_comp_env SC) ! id = Some co -> (genv_cenv ge) ! id = Some co.

Definition sn_ty : type := Tstruct surface_collision._SurfaceNode noattr.

(* SurfaceNode's members, read off the TU without reading back a composite
   (whose proof fields make vm readback blow up) *)
Definition sn_members : members :=
  [Member_plain surface_collision._next (tptr sn_ty);
   Member_plain surface_collision._surface
     (tptr (Tstruct surface_collision._Surface noattr))].

Lemma sn_members_eq :
    match (prog_comp_env SC) ! surface_collision._SurfaceNode with
    | Some co => co_members co | None => nil end = sn_members.
Proof. vm_compute. reflexivity. Qed.

Lemma sn_offsets_ge : forall (ge : genv) co,
    cenv_has ge -> (genv_cenv ge) ! surface_collision._SurfaceNode = Some co ->
    field_offset ge surface_collision._next (co_members co) = OK (SN_NEXT, Full)
    /\ field_offset ge surface_collision._surface (co_members co) = OK (SN_SURF, Full).
Proof.
  intros ge co HC H. pose proof sn_members_eq as M.
  destruct ((prog_comp_env SC) ! surface_collision._SurfaceNode) as [co0|] eqn:E0;
    [| discriminate M].
  rewrite (HC _ _ E0) in H. injection H as <-. rewrite M.
  split; reflexivity.
Qed.

(* reading a field of *surfaceNode *)
Lemma sn_field : forall (ge : genv) e le m fld ty v nd d,
    cenv_has ge ->
    (forall co, (genv_cenv ge) ! surface_collision._SurfaceNode = Some co ->
       field_offset ge fld (co_members co) = OK (d, Full)) ->
    access_mode ty = By_value Mint32 ->
    le ! surface_collision._surfaceNode = Some nd ->
    eval_expr ge e le m
      (Efield (Ederef (Etempvar surface_collision._surfaceNode (tptr sn_ty)) sn_ty) fld ty) v ->
    exists bn on, nd = Vptr bn on
      /\ Mem.loadv Mint32 m (Vptr bn (Ptrofs.add on (Ptrofs.repr d))) = Some v.
Proof.
  intros ge e le m fld ty v nd d HC Hfo Ham Hle H.
  inv H.
  match goal with Hl : eval_lvalue _ _ _ _ (Efield _ _ _) _ _ _ |- _ => inv Hl end;
    [| cbn in *; discriminate].
  match goal with Ha : eval_expr _ _ _ _ (Ederef _ _) _ |- _ => inv Ha end.
  match goal with Hl : eval_lvalue _ _ _ _ (Ederef _ _) _ _ _ |- _ => inv Hl end.
  cbn [typeof] in *. unfold sn_ty in *.
  match goal with H5 : Tstruct _ _ = Tstruct _ _ |- _ => inv H5 end.
  match goal with Hd : deref_loc (Tstruct _ _) _ _ _ _ _ |- _ => inv Hd end;
    cbn [access_mode] in *; try discriminate.
  match goal with Ht : eval_expr _ _ _ _ (Etempvar _ _) _ |- _ => inv Ht end;
    [| match goal with Hl : eval_lvalue _ _ _ _ (Etempvar _ _) _ _ _ |- _ => inv Hl end].
  rewrite Hle in *. match goal with Hx : Some _ = Some _ |- _ => inv Hx end.
  match goal with Hc : (genv_cenv ge) ! _ = Some _, Hf : field_offset _ _ _ = OK _ |- _ =>
    rewrite (Hfo _ Hc) in Hf; inv Hf end.
  exists loc, ofs0. split; [reflexivity |].
  match goal with Hd : deref_loc ty _ _ _ _ _ |- _ => inv Hd end; congruence.
Qed.

Definition surf_pty : type := tptr (Tstruct surface_collision._Surface noattr).

Lemma sn_surf : forall (ge : genv) e le m v nd,
    cenv_has ge -> le ! surface_collision._surfaceNode = Some nd ->
    eval_expr ge e le m
      (Efield (Ederef (Etempvar surface_collision._surfaceNode (tptr sn_ty)) sn_ty)
         surface_collision._surface surf_pty) v ->
    exists bn on, nd = Vptr bn on
      /\ Mem.loadv Mint32 m (Vptr bn (Ptrofs.add on (Ptrofs.repr SN_SURF))) = Some v.
Proof.
  intros ge e le m v nd HC Hle H.
  exact (sn_field ge e le m surface_collision._surface surf_pty v nd SN_SURF HC
           (fun co Hc => proj2 (sn_offsets_ge _ co HC Hc)) eq_refl Hle H).
Qed.

Lemma sn_next : forall (ge : genv) e le m v nd,
    cenv_has ge -> le ! surface_collision._surfaceNode = Some nd ->
    eval_expr ge e le m
      (Efield (Ederef (Etempvar surface_collision._surfaceNode (tptr sn_ty)) sn_ty)
         surface_collision._next (tptr sn_ty)) v ->
    exists bn on, nd = Vptr bn on
      /\ Mem.loadv Mint32 m (Vptr bn (Ptrofs.add on (Ptrofs.repr SN_NEXT))) = Some v.
Proof.
  intros ge e le m v nd HC Hle H.
  exact (sn_field ge e le m surface_collision._next (tptr sn_ty) v nd SN_NEXT HC
           (fun co Hc => proj1 (sn_offsets_ge _ co HC Hc)) eq_refl Hle H).
Qed.

(* ---- the body's pieces, cut out of the generated AST ---- *)
Definition ffl_loop : statement :=
  match fn_body surface_collision.f_find_floor_from_list with
  | Ssequence _ (Ssequence l _) => l | _ => Sskip end.
Definition ffl_s1 : statement := match ffl_loop with Sloop s1 _ => s1 | _ => Sskip end.

Lemma ffl_loop_shape : ffl_loop = Sloop ffl_s1 Sskip.
Proof. reflexivity. Qed.

Lemma ffl_body_shape :
  fn_body surface_collision.f_find_floor_from_list =
  Ssequence (Sset surface_collision._floor (Ecast (Econst_int (Int.repr 0) tint) (tptr tvoid)))
    (Ssequence ffl_loop
       (Sreturn (Some (Etempvar surface_collision._floor
                         (tptr (Tstruct surface_collision._Surface noattr)))))).
Proof. reflexivity. Qed.

(* the loop invariant: memory untouched, floor still NULL, the cursor is
   reachable from the head, pheight unchanged *)
Definition Inv (m : mem) (node0 ph : val) (le : temp_env) : Prop :=
  exists nd, le ! surface_collision._surfaceNode = Some nd
    /\ (forall s, on_list m nd s -> on_list m node0 s)
    /\ le ! surface_collision._floor = Some (Vint Int.zero)
    /\ le ! surface_collision._pheight = Some ph.

Ltac ptg := repeat first [ rewrite PTree.gss
  | rewrite PTree.gso by (let HH := fresh in intro HH; cbv in HH; discriminate HH) ].

Ltac xinv :=
  repeat match goal with
  | H : exec_stmt _ _ _ _ _ (Ssequence _ _) _ _ _ _ |- _ => inv H
  | H : exec_stmt _ _ _ _ _ (Sset _ _) _ _ _ _ |- _ => inv H
  | H : exec_stmt _ _ _ _ _ Sskip _ _ _ _ |- _ => inv H
  | H : exec_stmt _ _ _ _ _ Scontinue _ _ _ _ |- _ => inv H
  | H : exec_stmt _ _ _ _ _ Sbreak _ _ _ _ |- _ => inv H
  | H : exec_stmt _ _ _ _ _ (Sassign _ _) _ _ _ _ |- _ => inv H
  | H : exec_stmt _ _ _ _ _ (Sifthenelse _ _ _) _ _ _ _ |- _ => inv H
  | H : exec_stmt _ _ _ _ _ (if ?b then _ else _) _ _ _ _ |- _ => destruct b
  | H : ?o <> ?o |- _ => contradiction H; reflexivity
  end.

Lemma ffl_iter : forall ge e m le t le1 m1 out1 node0 ph,
    cenv_has ge ->
    exec_stmt function_entry2 ge e le m ffl_s1 t le1 m1 out1 ->
    Inv m node0 ph le ->
    (out1 = Out_break /\ m1 = m /\ le1 = le)
    \/ (out1 = Out_continue /\ m1 = m /\ Inv m node0 ph le1)
    \/ (out1 = Out_break /\ exists s h, on_list m node0 s
          /\ le1 ! surface_collision._floor = Some s
          /\ Mem.storev Mfloat32 m ph h = Some m1).
Proof.
  intros ge e m le t le1 m1 out1 node0 ph HC H (nd & Hnd & Hreach & Hfl & Hph).
  cbv [ffl_s1 ffl_loop surface_collision.f_find_floor_from_list fn_body Swhile] in H.
  xinv.
  (* the guard said stop: nothing changed *)
  all: try (left; split; [reflexivity | split; reflexivity]).
  (* the two node loads *)
  all: match goal with
       Hs : eval_expr _ _ ?L _ (Efield (Ederef (Etempvar surface_collision._surfaceNode _) _)
                                 surface_collision._surface _) _ |- _ =>
         assert (Hle1 : L ! surface_collision._surfaceNode = Some nd) by (ptg; exact Hnd);
         destruct (sn_surf _ _ _ _ _ _ HC Hle1 Hs)
           as (bn & on & -> & Ls)
       end.
  all: match goal with
       Hn : eval_expr _ _ ?L _ (Efield (Ederef (Etempvar surface_collision._surfaceNode _) _)
                                 surface_collision._next _) _ |- _ =>
         assert (Hle2 : L ! surface_collision._surfaceNode = Some (Vptr bn on)) by (ptg; exact Hnd);
         destruct (sn_next _ _ _ _ _ _ HC Hle2 Hn)
           as (bn' & on' & Eb & Ln); injection Eb as <- <-
       end.
  (* a continue: the cursor moved to next, still reachable *)
  all: try (right; left; split; [reflexivity | split; [reflexivity |]];
            eexists; split; [ptg; reflexivity |];
            split; [intros s0 Hs0; apply Hreach; eapply ol_next; [exact Ln | exact Hs0] |];
            split; ptg; assumption).
  (* the floor: pheight written, floor := surf *)
  all: repeat match goal with Hl : eval_lvalue _ _ _ _ (Ederef _ _) _ _ _ |- _ => inv Hl end.
  all: repeat match goal with Ht : eval_expr _ _ _ _ (Etempvar _ _) _ |- _ =>
         inv Ht; [| match goal with Hl : eval_lvalue _ _ _ _ (Etempvar _ _) _ _ _ |- _ => inv Hl end]
       end.
  all: repeat match goal with Hx : (PTree.set _ _ _) ! _ = Some _ |- _ =>
         progress (repeat first [ rewrite PTree.gss in Hx
                                | rewrite PTree.gso in Hx by (let HH := fresh in intro HH; cbv in HH; discriminate HH) ])
       end.
  all: repeat match goal with Hx : Some _ = Some _ |- _ => inv Hx end.
  all: match goal with Ha : assign_loc _ _ _ _ _ _ _ _ |- _ => inv Ha end;
       try (cbn in *; discriminate).
  all: right; right; split; [reflexivity |].
  all: eexists; eexists; split; [apply Hreach; apply ol_here; exact Ls |].
  all: split; [ptg; reflexivity |].
  all: match goal with Hp : _ ! surface_collision._pheight = Some (Vptr _ _) |- _ =>
         rewrite Hph in Hp; inv Hp end.
  all: match goal with Hm : access_mode _ = By_value _ |- _ => cbn in Hm; inv Hm end.
  all: eassumption.
Qed.

Lemma ffl_loop_spec : forall ge e m le t le' m' out node0 ph,
    cenv_has ge ->
    exec_stmt function_entry2 ge e le m ffl_loop t le' m' out ->
    Inv m node0 ph le ->
    out = Out_normal
    /\ ((m' = m /\ le' ! surface_collision._floor = Some (Vint Int.zero))
        \/ (exists s h, on_list m node0 s
              /\ le' ! surface_collision._floor = Some s
              /\ Mem.storev Mfloat32 m ph h = Some m')).
Proof.
  intros ge e m le t le' m' out node0 ph HC H.
  rewrite ffl_loop_shape in H.
  remember (Sloop ffl_s1 Sskip) as S eqn:ES. revert ES.
  induction H; intros ES HI; try discriminate ES.
  - (* the body broke out (or returned) *)
    injection ES as -> ->.
    match goal with Hx : exec_stmt _ _ _ _ _ ffl_s1 _ _ _ _,
                    Hb : out_break_or_return _ _ |- _ =>
      destruct (ffl_iter _ _ _ _ _ _ _ _ _ _ HC Hx HI)
        as [(-> & -> & ->) | [(-> & _ & _) | (-> & s & h & Hs & Hf & Hst)]];
      inv Hb
    end.
    + destruct HI as (nd & _ & _ & Hfl & _). split; [reflexivity | left; split; auto].
    + split; [reflexivity | right; eauto].
  - (* the body continued, then Sskip went abrupt: impossible *)
    injection ES as -> ->.
    match goal with Hs : exec_stmt _ _ _ _ _ Sskip _ _ _ _,
                    Hb : out_break_or_return _ _ |- _ => inv Hs; inv Hb end.
  - (* one more round *)
    injection ES as -> ->.
    match goal with Hx : exec_stmt _ _ _ _ _ ffl_s1 _ _ _ _,
                    Hn : out_normal_or_continue _ |- _ =>
      destruct (ffl_iter _ _ _ _ _ _ _ _ _ _ HC Hx HI)
        as [(-> & _ & _) | [(-> & -> & HI') | (-> & _)]];
      [inv Hn | | inv Hn]
    end.
    match goal with Hs : exec_stmt _ _ _ _ _ Sskip _ _ _ _ |- _ => inv Hs end.
    eauto.
Qed.

Lemma cast_surf_ptr : forall v m vr, sem_cast v surf_pty surf_pty m = Some vr -> vr = v.
Proof. intros v m vr H. destruct v; vm_compute in H; congruence. Qed.

(* THE CONTRACT *)
Theorem ffl_value_contract : forall (ge : genv),
    cenv_has ge ->
    forall m node x y z ph t m' vres,
      eval_funcall function_entry2 ge m
        (Internal surface_collision.f_find_floor_from_list) [node; x; y; z; ph] t m' vres ->
      (m' = m /\ vres = Vint Int.zero)
      \/ (on_list m node vres /\ exists h, Mem.storev Mfloat32 m ph h = Some m').
Proof.
  intros ge HC m node x y z ph t m' vres H.
  inv H.
  match goal with He : function_entry2 _ _ _ _ _ _ _ |- _ => inv He end.
  match goal with Ha : alloc_variables _ _ _ _ _ _ |- _ => inv Ha end.
  match goal with Hb : bind_parameter_temps _ _ _ = Some _ |- _ =>
    cbn [bind_parameter_temps surface_collision.f_find_floor_from_list fn_params] in Hb;
    injection Hb as <- end.
  match goal with Hx : exec_stmt _ _ _ _ _ _ _ _ _ _ |- _ => rewrite ffl_body_shape in Hx; inv Hx end;
    [| match goal with Hs : exec_stmt _ _ _ _ _ (Sset _ _) _ _ _ _ |- _ => inv Hs end;
       congruence].
  match goal with Hs : exec_stmt _ _ _ _ _ (Sset _ _) _ _ _ _ |- _ => inv Hs end.
  match goal with Hc : eval_expr _ _ _ _ (Ecast _ _) _ |- _ =>
    inv Hc; [| match goal with Hl : eval_lvalue _ _ _ _ (Ecast _ _) _ _ _ |- _ => inv Hl end] end.
  match goal with Hk : eval_expr _ _ _ _ (Econst_int _ _) _ |- _ =>
    inv Hk; [| match goal with Hl : eval_lvalue _ _ _ _ (Econst_int _ _) _ _ _ |- _ => inv Hl end] end.
  match goal with Hc : sem_cast _ _ _ ?mm = Some _ |- _ =>
    change (sem_cast (Vint (Int.repr 0)) (typeof (Econst_int (Int.repr 0) tint)) (tptr tvoid) mm)
      with (Some (Vint (Int.repr 0))) in Hc; injection Hc as <- end.
  match goal with Hx : exec_stmt _ _ _ ?L ?mm (Ssequence ffl_loop _) _ _ _ _ |- _ =>
    assert (HI : Inv mm node ph L)
      by (exists node; split; [ptg; reflexivity |]; split; [auto |]; split; ptg; reflexivity)
  end.
  match goal with Hx : exec_stmt _ _ _ _ _ (Ssequence _ _) _ _ _ _ |- _ => inv Hx end.
  - match goal with Hl : exec_stmt _ _ _ _ _ ffl_loop _ _ _ _ |- _ =>
      destruct (ffl_loop_spec _ _ _ _ _ _ _ _ _ _ HC Hl HI) as (_ & Hr) end.
    match goal with Hs : exec_stmt _ _ _ _ _ (Sreturn _) _ _ _ _ |- _ => inv Hs end.
    match goal with Ht : eval_expr _ _ _ _ (Etempvar _ _) _ |- _ =>
      inv Ht; [| match goal with Hl : eval_lvalue _ _ _ _ (Etempvar _ _) _ _ _ |- _ => inv Hl end] end.
    match goal with Ho : outcome_result_value _ _ _ _ |- _ => destruct Ho as (_ & Hc) end.
    apply cast_surf_ptr in Hc. subst vres.
    match goal with Hf : Mem.free_list _ _ = Some _ |- _ =>
      cbn [blocks_of_env PTree.elements Mem.free_list] in Hf; injection Hf as <- end.
    destruct Hr as [(-> & Hf) | (s & h & Hs & Hf & Hst)];
      match goal with Hg : _ ! surface_collision._floor = Some _ |- _ => rewrite Hf in Hg; inv Hg end.
    + left; auto.
    + right; eauto.
  - match goal with Hl : exec_stmt _ _ _ _ _ ffl_loop _ _ _ _ |- _ =>
      destruct (ffl_loop_spec _ _ _ _ _ _ _ _ _ _ HC Hl HI) as (-> & _) end.
    congruence.
Qed.
