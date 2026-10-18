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

(* ---- reading a Surface's fields ---- *)

Definition surf_ty : type := Tstruct surface_collision._Surface noattr.

(* the Surface field offsets (vertex1/2/3, normal, originOffset) and the
   normal's (x, y, z), checked in the TU's composite env and carried to any
   genv that contains it.  The lemma is generic in the env, so the kernel
   never unfolds the TU's. *)
Definition fo_chk (env : composite_env) (sid f : ident) (d : Z) : bool :=
  match env ! sid with
  | Some co => complete_members env (co_members co) &&
      match field_offset env f (co_members co) with
      | OK (d', Full) => Z.eqb d' d | _ => false end
  | None => false end.

Lemma fo_chk_ge : forall (env : composite_env) (ge : genv) sid f d,
    (forall id co, env ! id = Some co -> (genv_cenv ge) ! id = Some co) ->
    fo_chk env sid f d = true ->
    forall co, (genv_cenv ge) ! sid = Some co -> field_offset ge f (co_members co) = OK (d, Full).
Proof.
  intros env ge sid f d HC K co H. unfold fo_chk in K.
  destruct (env ! sid) as [co0|] eqn:E0; [| discriminate K].
  apply andb_true_iff in K as [K1 K2].
  rewrite (HC _ _ E0) in H. injection H as <-.
  rewrite (field_offset_stable env ge HC f _ K1).
  destruct (field_offset env f (co_members co0)) as [[d' []]|]; try discriminate K2.
  apply Z.eqb_eq in K2. subst. reflexivity.
Qed.

Definition fo_ok (ge : genv) (sid f : ident) (d : Z) : Prop :=
  forall co, (genv_cenv ge) ! sid = Some co -> field_offset ge f (co_members co) = OK (d, Full).

Lemma fo_v1 : forall ge, cenv_has ge -> fo_ok ge surface_collision._Surface surface_collision._vertex1 10.
Proof. intros ge HC. unfold fo_ok. apply (fo_chk_ge _ ge _ _ _ HC). vm_compute. reflexivity. Qed.
Lemma fo_v2 : forall ge, cenv_has ge -> fo_ok ge surface_collision._Surface surface_collision._vertex2 16.
Proof. intros ge HC. unfold fo_ok. apply (fo_chk_ge _ ge _ _ _ HC). vm_compute. reflexivity. Qed.
Lemma fo_v3 : forall ge, cenv_has ge -> fo_ok ge surface_collision._Surface surface_collision._vertex3 22.
Proof. intros ge HC. unfold fo_ok. apply (fo_chk_ge _ ge _ _ _ HC). vm_compute. reflexivity. Qed.
Lemma fo_n : forall ge, cenv_has ge -> fo_ok ge surface_collision._Surface surface_collision._normal 28.
Proof. intros ge HC. unfold fo_ok. apply (fo_chk_ge _ ge _ _ _ HC). vm_compute. reflexivity. Qed.
Lemma fo_oo : forall ge, cenv_has ge -> fo_ok ge surface_collision._Surface surface_collision._originOffset 40.
Proof. intros ge HC. unfold fo_ok. apply (fo_chk_ge _ ge _ _ _ HC). vm_compute. reflexivity. Qed.
Lemma fo_nx : forall ge, cenv_has ge -> fo_ok ge surface_collision.__769 surface_collision._x 0.
Proof. intros ge HC. unfold fo_ok. apply (fo_chk_ge _ ge _ _ _ HC). vm_compute. reflexivity. Qed.
Lemma fo_ny : forall ge, cenv_has ge -> fo_ok ge surface_collision.__769 surface_collision._y 4.
Proof. intros ge HC. unfold fo_ok. apply (fo_chk_ge _ ge _ _ _ HC). vm_compute. reflexivity. Qed.
Lemma fo_nz : forall ge, cenv_has ge -> fo_ok ge surface_collision.__769 surface_collision._z 8.
Proof. intros ge HC. unfold fo_ok. apply (fo_chk_ge _ ge _ _ _ HC). vm_compute. reflexivity. Qed.

(* a struct-typed expression evaluates to its address *)
Lemma ev_deref_struct : forall (ge : genv) e le m A sid v,
    eval_expr ge e le m (Ederef A (Tstruct sid noattr)) v ->
    exists l ofs, v = Vptr l ofs /\ eval_expr ge e le m A (Vptr l ofs).
Proof.
  intros ge e le m A sid v H. inv H.
  match goal with Hl : eval_lvalue _ _ _ _ (Ederef _ _) _ _ _ |- _ => inv Hl end.
  match goal with Hd : deref_loc _ _ _ _ _ _ |- _ => inv Hd end;
    cbn [access_mode] in *; try discriminate.
  eauto.
Qed.

(* reading a field of a struct-typed expression *)
Lemma ev_field_gen : forall (ge : genv) e le m B sid fld ty v d,
    typeof B = Tstruct sid noattr ->
    (forall co, (genv_cenv ge) ! sid = Some co ->
       field_offset ge fld (co_members co) = OK (d, Full)) ->
    eval_expr ge e le m (Efield B fld ty) v ->
    exists l ofs, eval_expr ge e le m B (Vptr l ofs)
      /\ deref_loc ty m l (Ptrofs.add ofs (Ptrofs.repr d)) Full v.
Proof.
  intros ge e le m B sid fld ty v d Ht Hfo H.
  inv H.
  match goal with Hl : eval_lvalue _ _ _ _ (Efield _ _ _) _ _ _ |- _ => inv Hl end;
    rewrite Ht in *; try discriminate.
  match goal with H5 : Tstruct _ _ = Tstruct _ _ |- _ => inv H5 end.
  match goal with Hc : (genv_cenv ge) ! _ = Some _, Hf : field_offset _ _ _ = OK _ |- _ =>
    rewrite (Hfo _ Hc) in Hf; inv Hf end.
  eauto.
Qed.

Lemma ev_field : forall (ge : genv) e le m B sid fld ty v d ch,
    typeof B = Tstruct sid noattr ->
    (forall co, (genv_cenv ge) ! sid = Some co ->
       field_offset ge fld (co_members co) = OK (d, Full)) ->
    access_mode ty = By_value ch ->
    eval_expr ge e le m (Efield B fld ty) v ->
    exists l ofs, eval_expr ge e le m B (Vptr l ofs)
      /\ Mem.loadv ch m (Vptr l (Ptrofs.add ofs (Ptrofs.repr d))) = Some v.
Proof.
  intros ge e le m B sid fld ty v d ch Ht Hfo Ham H.
  destruct (ev_field_gen _ _ _ _ _ _ _ _ _ _ Ht Hfo H) as (l & ofs & HB & Hd).
  exists l, ofs. split; [exact HB |]. inv Hd; congruence.
Qed.

Lemma ev_field_ref : forall (ge : genv) e le m B sid fld ty v d,
    typeof B = Tstruct sid noattr ->
    (forall co, (genv_cenv ge) ! sid = Some co ->
       field_offset ge fld (co_members co) = OK (d, Full)) ->
    access_mode ty = By_reference \/ access_mode ty = By_copy ->
    eval_expr ge e le m (Efield B fld ty) v ->
    exists l ofs, eval_expr ge e le m B (Vptr l ofs)
      /\ v = Vptr l (Ptrofs.add ofs (Ptrofs.repr d)).
Proof.
  intros ge e le m B sid fld ty v d Ht Hfo Ham H.
  destruct (ev_field_gen _ _ _ _ _ _ _ _ _ _ Ht Hfo H) as (l & ofs & HB & Hd).
  exists l, ofs. split; [exact HB |]. destruct Ham as [Ham | Ham]; inv Hd; congruence.
Qed.

Definition surf_e : expr :=
  Ederef (Etempvar surface_collision._surf (tptr surf_ty)) surf_ty.

Lemma ev_surf : forall (ge : genv) e le m v s,
    le ! surface_collision._surf = Some s -> eval_expr ge e le m surf_e v ->
    exists l ofs, s = Vptr l ofs /\ v = Vptr l ofs.
Proof.
  intros ge e le m v s Hs H. unfold surf_e, surf_ty in H.
  destruct (ev_deref_struct _ _ _ _ _ _ _ H) as (l & ofs & -> & Ht).
  inv Ht; [| match goal with Hl : eval_lvalue _ _ _ _ (Etempvar _ _) _ _ _ |- _ => inv Hl end].
  exists l, ofs. split; [congruence | reflexivity].
Qed.

(* surf->vertexN[k] *)
Definition vtx_e (fld : ident) (k : Z) : expr :=
  Ederef (Ebinop Oadd (Efield surf_e fld (tarray tshort 3)) (Econst_int (Int.repr k) tint)
            (tptr tshort)) tshort.

Lemma ev_vtx : forall (ge : genv) e le m fld d k v s,
    (forall co, (genv_cenv ge) ! surface_collision._Surface = Some co ->
       field_offset ge fld (co_members co) = OK (d, Full)) ->
    le ! surface_collision._surf = Some s ->
    eval_expr ge e le m (vtx_e fld k) v ->
    exists l ofs, s = Vptr l ofs /\
      Mem.loadv Mint16signed m
        (Vptr l (Ptrofs.add (Ptrofs.add ofs (Ptrofs.repr d))
                   (Ptrofs.mul (Ptrofs.repr 2) (Ptrofs.of_ints (Int.repr k))))) = Some v.
Proof.
  intros ge e le m fld d k v s Hfo Hs H. unfold vtx_e in H.
  inv H. match goal with Hl : eval_lvalue _ _ _ _ (Ederef _ _) _ _ _ |- _ => inv Hl end.
  match goal with Hb : eval_expr _ _ _ _ (Ebinop _ _ _ _) _ |- _ =>
    inv Hb; [| match goal with Hl : eval_lvalue _ _ _ _ (Ebinop _ _ _ _) _ _ _ |- _ => inv Hl end] end.
  destruct (ev_field_ref ge e le m surf_e surface_collision._Surface fld (tarray tshort 3) v1 d eq_refl Hfo (or_introl eq_refl) H5) as (l & ofs1 & Hse & ->).
  destruct (ev_surf _ _ _ _ _ _ Hs Hse) as (l' & ofs' & -> & E). injection E as <- <-.
  match goal with Hk : eval_expr _ _ _ _ (Econst_int _ _) _ |- _ =>
    inv Hk; [| match goal with Hl : eval_lvalue _ _ _ _ (Econst_int _ _) _ _ _ |- _ => inv Hl end] end.
  match goal with Ho : sem_binary_operation _ Oadd _ _ _ _ _ = Some _ |- _ =>
    cbn in Ho; injection Ho as <- end.
  exists l, ofs1. split; [reflexivity |]. subst ofs.
  match goal with Hd : deref_loc _ _ _ _ _ _ |- _ => inv Hd end; cbn in *; try discriminate;
    try congruence.
Qed.

(* surf->normal.c and surf->originOffset *)
Definition nrm_e (c : ident) : expr :=
  Efield (Efield surf_e surface_collision._normal (Tstruct surface_collision.__769 noattr)) c tfloat.
Definition oo_e : expr := Efield surf_e surface_collision._originOffset tfloat.

Lemma ev_nrm : forall (ge : genv) e le m c d v s, cenv_has ge ->
    fo_ok ge surface_collision.__769 c d ->
    le ! surface_collision._surf = Some s ->
    eval_expr ge e le m (nrm_e c) v ->
    exists l ofs, s = Vptr l ofs /\
      Mem.loadv Mfloat32 m (Vptr l (Ptrofs.add (Ptrofs.add ofs (Ptrofs.repr 28)) (Ptrofs.repr d))) = Some v.
Proof.
  intros ge e le m c d v s HC Hfo Hs H. unfold nrm_e in H.
  destruct (ev_field _ _ _ _ (Efield surf_e surface_collision._normal (Tstruct surface_collision.__769 noattr))
              surface_collision.__769 c tfloat v d Mfloat32 eq_refl Hfo eq_refl H)
    as (l & ofs & Hn & Hld).
  destruct (ev_field_ref _ _ _ _ surf_e surface_collision._Surface surface_collision._normal
              (Tstruct surface_collision.__769 noattr) _ 28 eq_refl (fo_n ge HC) (or_intror eq_refl) Hn) as (l1 & ofs1 & Hse & E).
  injection E as -> ->.
  destruct (ev_surf _ _ _ _ _ _ Hs Hse) as (l' & ofs' & -> & E). injection E as <- <-.
  eauto.
Qed.

Lemma ev_oo : forall (ge : genv) e le m v s, cenv_has ge ->
    le ! surface_collision._surf = Some s ->
    eval_expr ge e le m oo_e v ->
    exists l ofs, s = Vptr l ofs /\
      Mem.loadv Mfloat32 m (Vptr l (Ptrofs.add ofs (Ptrofs.repr 40))) = Some v.
Proof.
  intros ge e le m v s HC Hs H. unfold oo_e in H.
  destruct (ev_field _ _ _ _ surf_e surface_collision._Surface surface_collision._originOffset tfloat v 40 Mfloat32 eq_refl (fo_oo ge HC) eq_refl H)
    as (l & ofs & Hse & Hld).
  destruct (ev_surf _ _ _ _ _ _ Hs Hse) as (l' & ofs' & -> & E). injection E as <- <-.
  eauto.
Qed.

(* ---- the integer edge tests and the plane height ---- *)

Lemma sub_ii : forall (ge : genv) a b w m,
    sem_binary_operation ge Osub a tint b tint m = Some w ->
    exists i j, a = Vint i /\ b = Vint j /\ w = Vint (Int.sub i j).
Proof.
  intros ge a b w m H. destruct a; destruct b; cbn in H; try discriminate H;
    try (destruct Archi.ptr64; discriminate H).
  injection H as <-. eauto.
Qed.

Lemma mul_ii : forall (ge : genv) a b w m,
    sem_binary_operation ge Omul a tint b tint m = Some w ->
    exists i j, a = Vint i /\ b = Vint j /\ w = Vint (Int.mul i j).
Proof.
  intros ge a b w m H. destruct a; destruct b; cbn in H; try discriminate H;
    try (destruct Archi.ptr64; discriminate H).
  injection H as <-. eauto.
Qed.

Lemma lt_ii : forall (ge : genv) a b w m,
    sem_binary_operation ge Olt a tint b tint m = Some w ->
    exists i j, a = Vint i /\ b = Vint j /\ w = Val.of_bool (Int.lt i j).
Proof.
  intros ge a b w m H.
  destruct a as [| i | | | |]; destruct b as [| j | | | |];
    try (cbn in H; first [discriminate H | destruct Archi.ptr64; discriminate H]).
  exists i, j. split; [reflexivity | split; [reflexivity |]].
  assert (E : sem_binary_operation ge Olt (Vint i) tint (Vint j) tint m
              = Some (Val.of_bool (Int.lt i j))) by reflexivity.
  rewrite E in H. injection H as H. symmetry. exact H.
Qed.

Definition edge_ok (x z xi zi xj zj : int) : bool :=
  negb (Int.lt (Int.sub (Int.mul (Int.sub zi z) (Int.sub xj xi))
                        (Int.mul (Int.sub xi x) (Int.sub zj zi))) Int.zero).

Definition tv (x : ident) : expr := Etempvar x tint.
Definition edge_e (x z xi zi xj zj : ident) : expr :=
  Ebinop Olt
    (Ebinop Osub
       (Ebinop Omul (Ebinop Osub (tv zi) (tv z) tint) (Ebinop Osub (tv xj) (tv xi) tint) tint)
       (Ebinop Omul (Ebinop Osub (tv xi) (tv x) tint) (Ebinop Osub (tv zj) (tv zi) tint) tint)
       tint)
    (Econst_int (Int.repr 0) tint) tint.

Ltac ev_inv :=
  repeat match goal with
         | H : eval_expr _ _ _ _ (Ebinop _ _ _ _) _ |- _ => inv H
         | H : eval_expr _ _ _ _ (Eunop _ _ _) _ |- _ => inv H
         | H : eval_expr _ _ _ _ (Etempvar _ _) _ |- _ => inv H
         | H : eval_expr _ _ _ _ (Econst_int _ _) _ |- _ => inv H
         | H : eval_expr _ _ _ _ (Econst_single _ _) _ |- _ => inv H
         | H : eval_lvalue _ _ _ _ _ _ _ _ |- _ => inv H
         end.

Lemma ev_edge : forall (ge : genv) e le m x z xi zi xj zj vx vz vxi vzi vxj vzj v,
    le ! x = Some vx -> le ! z = Some vz -> le ! xi = Some vxi -> le ! zi = Some vzi ->
    le ! xj = Some vxj -> le ! zj = Some vzj ->
    eval_expr ge e le m (edge_e x z xi zi xj zj) v ->
    bool_val v tint m = Some false ->
    exists X Z XI ZI XJ ZJ, vx = Vint X /\ vz = Vint Z /\ vxi = Vint XI /\ vzi = Vint ZI
      /\ vxj = Vint XJ /\ vzj = Vint ZJ /\ edge_ok X Z XI ZI XJ ZJ = true.
Proof.
  intros ge e le m x z xi zi xj zj vx vz vxi vzi vxj vzj v Hx Hz Hxi Hzi Hxj Hzj H Hb.
  unfold edge_e, tv in H. ev_inv.
  cbn [typeof] in *.
  repeat match goal with
         | Hs : sem_binary_operation _ Osub _ tint _ tint _ = Some _ |- _ =>
             let E1 := fresh in let E2 := fresh in let E3 := fresh in
             destruct (sub_ii _ _ _ _ _ Hs) as (? & ? & E1 & E2 & E3); clear Hs; subst
         | Hs : sem_binary_operation _ Omul _ tint _ tint _ = Some _ |- _ =>
             let E1 := fresh in let E2 := fresh in let E3 := fresh in
             destruct (mul_ii _ _ _ _ _ Hs) as (? & ? & E1 & E2 & E3); clear Hs; subst
         | Hs : sem_binary_operation _ Olt _ tint _ tint _ = Some _ |- _ =>
             let E1 := fresh in let E2 := fresh in let E3 := fresh in
             destruct (lt_ii _ _ _ _ _ Hs) as (? & ? & E1 & E2 & E3); clear Hs; subst
         | Hm : Vint _ = Vint _ |- _ => injection Hm as Hm; subst
         end.
  repeat match goal with Hl : le ! ?i = Some ?a, Hl' : le ! ?i = Some ?b |- _ =>
           rewrite Hl in Hl'; injection Hl' as Hl'; subst; clear Hl' end.
  do 6 eexists. split; [reflexivity |]. split; [reflexivity |]. split; [reflexivity |].
  split; [reflexivity |]. split; [reflexivity |]. split; [reflexivity |].
  unfold edge_ok.
  match goal with Hb : bool_val (Val.of_bool ?c) _ _ = Some false |- _ =>
    destruct c eqn:L; [vm_compute in Hb; discriminate Hb |] end.
  change Int.zero with (Int.repr 0). rewrite L. reflexivity.
Qed.

(* ---- the plane height and the ny test ---- *)

Lemma mul_is : forall (ge : genv) a b w m,
    sem_binary_operation ge Omul a tint b tfloat m = Some w ->
    exists i j, a = Vint i /\ b = Vsingle j /\ w = Vsingle (Float32.mul (Float32.of_int i) j).
Proof.
  intros ge a b w m H.
  destruct a as [| i | | | |]; destruct b as [| | | | j |];
    try (cbn in H; first [discriminate H | destruct Archi.ptr64; discriminate H]).
  exists i, j. split; [reflexivity | split; [reflexivity |]].
  assert (E : sem_binary_operation ge Omul (Vint i) tint (Vsingle j) tfloat m = Some (Vsingle (Float32.mul (Float32.of_int i) j)))
    by reflexivity.
  rewrite E in H. injection H as H. symmetry. exact H.
Qed.

Lemma mul_si : forall (ge : genv) a b w m,
    sem_binary_operation ge Omul a tfloat b tint m = Some w ->
    exists i j, a = Vsingle i /\ b = Vint j /\ w = Vsingle (Float32.mul i (Float32.of_int j)).
Proof.
  intros ge a b w m H.
  destruct a as [| | | | i |]; destruct b as [| j | | | |];
    try (cbn in H; first [discriminate H | destruct Archi.ptr64; discriminate H]).
  exists i, j. split; [reflexivity | split; [reflexivity |]].
  assert (E : sem_binary_operation ge Omul (Vsingle i) tfloat (Vint j) tint m = Some (Vsingle (Float32.mul i (Float32.of_int j))))
    by reflexivity.
  rewrite E in H. injection H as H. symmetry. exact H.
Qed.

Lemma add_ss : forall (ge : genv) a b w m,
    sem_binary_operation ge Oadd a tfloat b tfloat m = Some w ->
    exists i j, a = Vsingle i /\ b = Vsingle j /\ w = Vsingle (Float32.add i j).
Proof.
  intros ge a b w m H.
  destruct a as [| | | | i |]; destruct b as [| | | | j |];
    try (cbn in H; first [discriminate H | destruct Archi.ptr64; discriminate H]).
  exists i, j. split; [reflexivity | split; [reflexivity |]].
  assert (E : sem_binary_operation ge Oadd (Vsingle i) tfloat (Vsingle j) tfloat m = Some (Vsingle (Float32.add i j)))
    by reflexivity.
  rewrite E in H. injection H as H. symmetry. exact H.
Qed.

Lemma div_ss : forall (ge : genv) a b w m,
    sem_binary_operation ge Odiv a tfloat b tfloat m = Some w ->
    exists i j, a = Vsingle i /\ b = Vsingle j /\ w = Vsingle (Float32.div i j).
Proof.
  intros ge a b w m H.
  destruct a as [| | | | i |]; destruct b as [| | | | j |];
    try (cbn in H; first [discriminate H | destruct Archi.ptr64; discriminate H]).
  exists i, j. split; [reflexivity | split; [reflexivity |]].
  assert (E : sem_binary_operation ge Odiv (Vsingle i) tfloat (Vsingle j) tfloat m = Some (Vsingle (Float32.div i j)))
    by reflexivity.
  rewrite E in H. injection H as H. symmetry. exact H.
Qed.

Lemma eq_ss : forall (ge : genv) a b w m,
    sem_binary_operation ge Oeq a tfloat b tfloat m = Some w ->
    exists i j, a = Vsingle i /\ b = Vsingle j /\ w = Val.of_bool (Float32.cmp Ceq i j).
Proof.
  intros ge a b w m H.
  destruct a as [| | | | i |]; destruct b as [| | | | j |];
    try (cbn in H; first [discriminate H | destruct Archi.ptr64; discriminate H]).
  exists i, j. split; [reflexivity | split; [reflexivity |]].
  assert (E : sem_binary_operation ge Oeq (Vsingle i) tfloat (Vsingle j) tfloat m = Some (Val.of_bool (Float32.cmp Ceq i j)))
    by reflexivity.
  rewrite E in H. injection H as H. symmetry. exact H.
Qed.

Lemma neg_s : forall a w m,
    sem_unary_operation Oneg a tfloat m = Some w -> exists f, a = Vsingle f /\ w = Vsingle (Float32.neg f).
Proof.
  intros a w m H. destruct a as [| | | | f |];
    try (cbn in H; first [discriminate H | destruct Archi.ptr64; discriminate H]).
  exists f. split; [reflexivity |].
  assert (E : sem_unary_operation Oneg (Vsingle f) tfloat m = Some (Vsingle (Float32.neg f)))
    by reflexivity.
  rewrite E in H. injection H as H. symmetry. exact H.
Qed.

Definition plane_h (x z : int) (nx ny nz oo : float32) : float32 :=
  Float32.div
    (Float32.neg (Float32.add (Float32.add (Float32.mul (Float32.of_int x) nx)
                                           (Float32.mul nz (Float32.of_int z))) oo)) ny.

Definition tf (x : ident) : expr := Etempvar x tfloat.
Definition h_e : expr :=
  Ebinop Odiv
    (Eunop Oneg
       (Ebinop Oadd
          (Ebinop Oadd (Ebinop Omul (tv surface_collision._x) (tf surface_collision._nx) tfloat)
             (Ebinop Omul (tf surface_collision._nz) (tv surface_collision._z) tfloat) tfloat)
          (tf surface_collision._oo) tfloat) tfloat)
    (tf surface_collision._ny) tfloat.

Lemma ev_height : forall (ge : genv) e le m vx vz vnx vny vnz voo v,
    le ! surface_collision._x = Some vx -> le ! surface_collision._z = Some vz ->
    le ! surface_collision._nx = Some vnx -> le ! surface_collision._ny = Some vny ->
    le ! surface_collision._nz = Some vnz -> le ! surface_collision._oo = Some voo ->
    eval_expr ge e le m h_e v ->
    exists X Z nx ny nz oo, vx = Vint X /\ vz = Vint Z /\ vnx = Vsingle nx /\ vny = Vsingle ny
      /\ vnz = Vsingle nz /\ voo = Vsingle oo /\ v = Vsingle (plane_h X Z nx ny nz oo).
Proof.
  intros ge e le m vx vz vnx vny vnz voo v Hx Hz Hnx Hny Hnz Hoo H.
  unfold h_e, tv, tf in H. ev_inv. cbn [typeof] in *.
  repeat match goal with
         | Hs : sem_binary_operation _ Omul _ tint _ tfloat _ = Some _ |- _ =>
             let E1 := fresh in let E2 := fresh in let E3 := fresh in
             destruct (mul_is _ _ _ _ _ Hs) as (? & ? & E1 & E2 & E3); clear Hs; subst
         | Hs : sem_binary_operation _ Omul _ tfloat _ tint _ = Some _ |- _ =>
             let E1 := fresh in let E2 := fresh in let E3 := fresh in
             destruct (mul_si _ _ _ _ _ Hs) as (? & ? & E1 & E2 & E3); clear Hs; subst
         | Hs : sem_binary_operation _ Oadd _ tfloat _ tfloat _ = Some _ |- _ =>
             let E1 := fresh in let E2 := fresh in let E3 := fresh in
             destruct (add_ss _ _ _ _ _ Hs) as (? & ? & E1 & E2 & E3); clear Hs; subst
         | Hs : sem_binary_operation _ Odiv _ tfloat _ tfloat _ = Some _ |- _ =>
             let E1 := fresh in let E2 := fresh in let E3 := fresh in
             destruct (div_ss _ _ _ _ _ Hs) as (? & ? & E1 & E2 & E3); clear Hs; subst
         | Hs : sem_unary_operation Oneg _ tfloat _ = Some _ |- _ =>
             let E1 := fresh in let E2 := fresh in
             destruct (neg_s _ _ _ Hs) as (? & E1 & E2); clear Hs; subst
         | Hm : Vsingle _ = Vsingle _ |- _ => injection Hm as Hm; subst
         | Hm : Vint _ = Vint _ |- _ => injection Hm as Hm; subst
         end.
  repeat match goal with Hl : le ! ?i = Some ?a, Hl' : le ! ?i = Some ?b |- _ =>
           rewrite Hl in Hl'; injection Hl' as Hl'; subst; clear Hl' end.
  do 6 eexists. repeat (split; [reflexivity |]). reflexivity.
Qed.

Definition ny_e : expr :=
  Ebinop Oeq (tf surface_collision._ny) (Econst_single (Float32.of_bits (Int.repr 0)) tfloat) tint.

Lemma ev_ny : forall (ge : genv) e le m vny v,
    le ! surface_collision._ny = Some vny ->
    eval_expr ge e le m ny_e v -> bool_val v tint m = Some false ->
    exists ny, vny = Vsingle ny /\ Float32.cmp Ceq ny (Float32.of_bits (Int.repr 0)) = false.
Proof.
  intros ge e le m vny v Hny H Hb. unfold ny_e, tf in H. ev_inv. cbn [typeof] in *.
  match goal with Hs : sem_binary_operation _ Oeq _ tfloat _ tfloat _ = Some _ |- _ =>
    destruct (eq_ss _ _ _ _ _ Hs) as (a & b & E1 & E2 & ->) end.
  injection E2 as <-.
  match goal with Hl : le ! _ = Some _ |- _ => rewrite Hny in Hl; injection Hl as <- end.
  exists a. split; [exact E1 |].
  destruct (Float32.cmp Ceq a _) eqn:L; [vm_compute in Hb; discriminate Hb | reflexivity].
Qed.

(* ---- the height test: y - (height + -78.0f) < 0.0f is false ---- *)
Definition c78 : float32 := Float32.of_bits (Int.repr 1117519872).   (* 78.0f *)

Definition chk_expr : expr :=
  Ebinop Olt
    (Ebinop Osub (Etempvar surface_collision._y tint)
       (Ebinop Oadd (Etempvar surface_collision._height tfloat)
          (Eunop Oneg (Econst_single c78 tfloat) tfloat) tfloat) tfloat)
    (Econst_single (Float32.of_bits (Int.repr 0)) tfloat) tint.

(* the floor accepted passed the test, in exactly the body's float ops *)
Definition hok (yv : val) (h : float32) : Prop :=
  exists yi, yv = Vint yi
    /\ Float32.cmp Clt (Float32.sub (Float32.of_int yi) (Float32.add h (Float32.neg c78)))
         Float32.zero = false.

Lemma add_single : forall (ge : genv) hv c w m,
    sem_binary_operation ge Oadd hv tfloat (Vsingle c) tfloat m = Some w ->
    exists h, hv = Vsingle h /\ w = Vsingle (Float32.add h c).
Proof.
  intros ge hv c w m H. destruct hv; cbn in H; try discriminate H.
  all: try (injection H as <-; eauto).
  all: try (destruct Archi.ptr64; discriminate H).
Qed.

Lemma sub_int_single : forall (ge : genv) yv c w m,
    sem_binary_operation ge Osub yv tint (Vsingle c) tfloat m = Some w ->
    exists yi, yv = Vint yi /\ w = Vsingle (Float32.sub (Float32.of_int yi) c).
Proof.
  intros ge yv c w m H. destruct yv; cbn in H; try discriminate H.
  all: try (injection H as <-; eauto).
  all: try (destruct Archi.ptr64; discriminate H).
Qed.

Lemma chk_eval : forall (ge : genv) e le m v hv yv,
    le ! surface_collision._height = Some hv -> le ! surface_collision._y = Some yv ->
    eval_expr ge e le m chk_expr v -> bool_val v tint m = Some false ->
    exists h, hv = Vsingle h /\ hok yv h.
Proof.
  intros ge e le m v hv yv Hh Hy H Hb. unfold chk_expr in H.
  repeat match goal with
         | H : eval_expr _ _ _ _ _ _ |- _ => inv H
         | H : eval_lvalue _ _ _ _ _ _ _ _ |- _ => inv H
         end.
  rewrite Hh in *. rewrite Hy in *.
  repeat match goal with Hx : Some _ = Some _ |- _ => inv Hx end.
  match goal with Hu : sem_unary_operation Oneg _ _ _ = Some _ |- _ => cbn in Hu; inv Hu end.
  match goal with Ha : sem_binary_operation _ Oadd _ _ _ _ _ = Some _ |- _ =>
    destruct (add_single _ _ _ _ _ Ha) as (h & -> & ->) end.
  match goal with Hs : sem_binary_operation _ Osub _ _ _ _ _ = Some _ |- _ =>
    destruct (sub_int_single _ _ _ _ _ Hs) as (yi & -> & ->) end.
  match goal with Hc : sem_binary_operation _ Olt _ _ _ _ _ = Some _ |- _ =>
    cbn in Hc; inv Hc end.
  eexists; split; [reflexivity |]. eexists; split; [reflexivity |].
  destruct (Float32.cmp Clt _ _); [| reflexivity].
  cbn in Hb. discriminate Hb.
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
Definition Inv (m : mem) (node0 ph xv yv zv : val) (le : temp_env) : Prop :=
  exists nd, le ! surface_collision._surfaceNode = Some nd
    /\ (forall s, on_list m nd s -> on_list m node0 s)
    /\ le ! surface_collision._floor = Some (Vint Int.zero)
    /\ le ! surface_collision._pheight = Some ph
    /\ le ! surface_collision._y = Some yv
    /\ le ! surface_collision._x = Some xv
    /\ le ! surface_collision._z = Some zv.

(* what a hit means: the surface's vertices and normal as loaded, the three
   edge tests passed at (x, z), ny <> 0, and the height is the plane's *)
Definition ffl_hit (m : mem) (s xv zv : val) (h : float32) : Prop :=
  exists bs os X Z x1 z1 x2 z2 x3 z3 nx ny nz oo,
    s = Vptr bs os /\ xv = Vint X /\ zv = Vint Z
    /\ Mem.loadv Mint16signed m (Vptr bs (Ptrofs.add os (Ptrofs.repr 10))) = Some (Vint x1)
    /\ Mem.loadv Mint16signed m (Vptr bs (Ptrofs.add os (Ptrofs.repr 14))) = Some (Vint z1)
    /\ Mem.loadv Mint16signed m (Vptr bs (Ptrofs.add os (Ptrofs.repr 16))) = Some (Vint x2)
    /\ Mem.loadv Mint16signed m (Vptr bs (Ptrofs.add os (Ptrofs.repr 20))) = Some (Vint z2)
    /\ Mem.loadv Mint16signed m (Vptr bs (Ptrofs.add os (Ptrofs.repr 22))) = Some (Vint x3)
    /\ Mem.loadv Mint16signed m (Vptr bs (Ptrofs.add os (Ptrofs.repr 26))) = Some (Vint z3)
    /\ Mem.loadv Mfloat32 m (Vptr bs (Ptrofs.add os (Ptrofs.repr 28))) = Some (Vsingle nx)
    /\ Mem.loadv Mfloat32 m (Vptr bs (Ptrofs.add os (Ptrofs.repr 32))) = Some (Vsingle ny)
    /\ Mem.loadv Mfloat32 m (Vptr bs (Ptrofs.add os (Ptrofs.repr 36))) = Some (Vsingle nz)
    /\ Mem.loadv Mfloat32 m (Vptr bs (Ptrofs.add os (Ptrofs.repr 40))) = Some (Vsingle oo)
    /\ edge_ok X Z x1 z1 x2 z2 = true /\ edge_ok X Z x2 z2 x3 z3 = true
    /\ edge_ok X Z x3 z3 x1 z1 = true
    /\ Float32.cmp Ceq ny (Float32.of_bits (Int.repr 0)) = false
    /\ h = plane_h X Z nx ny nz oo.

Lemma ofs_norm : forall o a b e,
    (Ptrofs.unsigned a + Ptrofs.unsigned b =? e) = true ->
    Ptrofs.add (Ptrofs.add o a) b = Ptrofs.add o (Ptrofs.repr e).
Proof.
  intros o a b e H. rewrite Ptrofs.add_assoc. f_equal. unfold Ptrofs.add at 1.
  apply Z.eqb_eq in H. rewrite H. reflexivity.
Qed.

Ltac ofs_fix :=
  repeat match goal with
  | Hl : Mem.loadv _ _ (Vptr _ (Ptrofs.add (Ptrofs.add ?o ?a) ?b)) = _ |- _ =>
      lazymatch a with Ptrofs.repr ?d =>
        let e := eval vm_compute in (Ptrofs.unsigned a + Ptrofs.unsigned b) in
        rewrite (ofs_norm o a b e ltac:(vm_compute; reflexivity)) in Hl end
  end.

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

Ltac hit_v HC :=
  (* the vertices *)
  repeat match goal with
  | Hv : eval_expr _ _ ?L ?M (Ederef (Ebinop Oadd (Efield _ ?fld _) (Econst_int (Int.repr ?k) _) _) _) ?v |- _ =>
      lazymatch L with context [PTree.set surface_collision._surf ?sv _] =>
        let Hs := fresh in
        assert (Hs : L ! surface_collision._surf = Some sv) by (ptg; reflexivity);
        let R := fresh in
        first [ pose proof (ev_vtx _ _ L M fld 10 k v sv (fo_v1 _ HC) Hs Hv) as R
              | pose proof (ev_vtx _ _ L M fld 16 k v sv (fo_v2 _ HC) Hs Hv) as R
              | pose proof (ev_vtx _ _ L M fld 22 k v sv (fo_v3 _ HC) Hs Hv) as R ];
        clear Hv Hs;
        let El := fresh in let Ld := fresh "Ld" in
        destruct R as (? & ? & El & Ld); first [subst sv | injection El as <- <-]
      end
  | Hv : eval_expr _ _ ?L ?M (Efield (Efield _ surface_collision._normal _) ?c tfloat) ?v |- _ =>
      lazymatch L with context [PTree.set surface_collision._surf ?sv _] =>
        let Hs := fresh in
        assert (Hs : L ! surface_collision._surf = Some sv) by (ptg; reflexivity);
        let R := fresh in
        first [ pose proof (ev_nrm _ _ L M c 0 v sv HC (fo_nx _ HC) Hs Hv) as R
              | pose proof (ev_nrm _ _ L M c 4 v sv HC (fo_ny _ HC) Hs Hv) as R
              | pose proof (ev_nrm _ _ L M c 8 v sv HC (fo_nz _ HC) Hs Hv) as R ];
        clear Hv Hs;
        let El := fresh in let Ld := fresh "Ld" in
        destruct R as (? & ? & El & Ld); first [subst sv | injection El as <- <-]
      end
  | Hv : eval_expr _ _ ?L ?M (Efield _ surface_collision._originOffset tfloat) ?v |- _ =>
      lazymatch L with context [PTree.set surface_collision._surf ?sv _] =>
        let Hs := fresh in
        assert (Hs : L ! surface_collision._surf = Some sv) by (ptg; reflexivity);
        let R := fresh in
        pose proof (ev_oo _ _ L M v sv HC Hs Hv) as R;
        clear Hv Hs;
        let El := fresh in let Ld := fresh "Ld" in
        destruct R as (? & ? & El & Ld); first [subst sv | injection El as <- <-]
      end
  | Hp : Vptr _ _ = Vptr _ _ |- _ => injection Hp as Hp; subst
  end.
Ltac lkup := ptg; first [reflexivity | eassumption].
Ltac hit_e :=
  repeat match goal with
  | Hv : eval_expr _ _ ?L _ (Ebinop Olt (Ebinop Osub
            (Ebinop Omul (Ebinop Osub (Etempvar ?zi _) (Etempvar ?z _) _)
                         (Ebinop Osub (Etempvar ?xj _) (Etempvar ?xi _) _) _)
            (Ebinop Omul (Ebinop Osub (Etempvar _ _) (Etempvar ?x _) _)
                         (Ebinop Osub (Etempvar ?zj _) (Etempvar _ _) _) _) _) _ _) ?v,
    Hb : bool_val ?v _ _ = Some false |- _ =>
      eapply (ev_edge _ _ L _ x z xi zi xj zj) in Hv;
      [| lkup | lkup | lkup | lkup | lkup | lkup | exact Hb];
      clear Hb;
      let E1 := fresh in let E2 := fresh in let E3 := fresh in let E4 := fresh in
      let E5 := fresh in let E6 := fresh "Edge" in
      destruct Hv as (? & ? & ? & ? & ? & ? & E1 & E2 & E3 & E4 & E5 & E6 & ?);
      subst
  | Hi : Vint _ = Vint _ |- _ => injection Hi as Hi; subst
  end.
Ltac hit_n :=
  match goal with
  | Hv : eval_expr _ _ ?L _ (Ebinop Oeq (Etempvar surface_collision._ny _) _ _) ?v,
    Hb : bool_val ?v _ _ = Some false |- _ =>
      eapply (ev_ny _ _ L _ _ _) in Hv; [| lkup | exact Hb];
      clear Hb;
      let E1 := fresh in let Hny := fresh "Hny" in
      destruct Hv as (? & E1 & Hny); subst
  end.
Ltac hit_h :=
  match goal with
  | Hv : eval_expr _ _ ?L _ (Ebinop Odiv _ _ tfloat) (Vsingle ?hh) |- _ =>
      eapply (ev_height _ _ L _ _ _ _ _ _ _ _) in Hv;
      [| lkup | lkup | lkup | lkup | lkup | lkup];
      destruct Hv as (? & ? & ? & ? & ? & ? & ? & ? & ? & ? & ? & ? & ?)
  end.
Ltac hit_fin :=
  repeat match goal with
  | Hi : Vint _ = Vint _ |- _ => injection Hi as Hi; subst
  | Hi : Vsingle _ = Vsingle _ |- _ => injection Hi as Hi; subst
  end;
  unfold ffl_hit; do 14 eexists;
  repeat (split; [first [reflexivity | eassumption] |]); first [reflexivity | eassumption].

Lemma ffl_iter : forall ge e m le t le1 m1 out1 node0 ph xv yv zv,
    cenv_has ge ->
    exec_stmt function_entry2 ge e le m ffl_s1 t le1 m1 out1 ->
    Inv m node0 ph xv yv zv le ->
    (out1 = Out_break /\ m1 = m /\ le1 = le)
    \/ (out1 = Out_continue /\ m1 = m /\ Inv m node0 ph xv yv zv le1)
    \/ (out1 = Out_break /\ exists s h, on_list m node0 s
          /\ le1 ! surface_collision._floor = Some s
          /\ Mem.storev Mfloat32 m ph (Vsingle h) = Some m1 /\ hok yv h
          /\ ffl_hit m s xv zv h).
Proof.
  intros ge e m le t le1 m1 out1 node0 ph xv yv zv HC H (nd & Hnd & Hreach & Hfl & Hph & Hy & Hxx & Hzz).
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
            repeat (split; [ptg; assumption |]); ptg; assumption).
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
  all: match goal with
       | Hc : eval_expr _ _ ?L _ (Ebinop Olt (Ebinop Osub (Etempvar surface_collision._y tint) _ tfloat) _ tint) ?v,
         Hb : bool_val ?v _ _ = Some false |- _ =>
           lazymatch L with context [PTree.set surface_collision._height ?hv _] =>
             let Hhh := fresh "Hhh" in let Hyy := fresh "Hyy" in
             assert (Hhh : L ! surface_collision._height = Some hv) by (ptg; reflexivity);
             assert (Hyy : L ! surface_collision._y = Some yv) by (ptg; first [exact Hy | assumption]);
             destruct (chk_eval _ _ _ _ _ _ _ Hhh Hyy Hc Hb) as (h0 & -> & Hk)
           end
       end.
  all: match goal with Hc : sem_cast (Vsingle _) _ _ _ = Some _ |- _ => cbn in Hc; inv Hc end.
  all: eexists; eexists; split; [apply Hreach; apply ol_here; exact Ls |].
  all: split; [ptg; reflexivity |].
  all: match goal with Hp : _ ! surface_collision._pheight = Some (Vptr _ _) |- _ =>
         rewrite Hph in Hp; inv Hp end.
  all: match goal with Hm : access_mode _ = By_value _ |- _ => cbn in Hm; inv Hm end.
  all: split; [eassumption | split; [exact Hk |]].
  all: hit_v HC.
  all: ofs_fix.
  all: hit_e.
  all: hit_n.
  all: hit_h.
  all: hit_fin.
Qed.

Lemma ffl_loop_spec : forall ge e m le t le' m' out node0 ph xv yv zv,
    cenv_has ge ->
    exec_stmt function_entry2 ge e le m ffl_loop t le' m' out ->
    Inv m node0 ph xv yv zv le ->
    out = Out_normal
    /\ ((m' = m /\ le' ! surface_collision._floor = Some (Vint Int.zero))
        \/ (exists s h, on_list m node0 s
              /\ le' ! surface_collision._floor = Some s
              /\ Mem.storev Mfloat32 m ph (Vsingle h) = Some m' /\ hok yv h
              /\ ffl_hit m s xv zv h)).
Proof.
  intros ge e m le t le' m' out node0 ph xv yv zv HC H.
  rewrite ffl_loop_shape in H.
  remember (Sloop ffl_s1 Sskip) as S eqn:ES. revert ES.
  induction H; intros ES HI; try discriminate ES.
  - (* the body broke out (or returned) *)
    injection ES as -> ->.
    match goal with Hx : exec_stmt _ _ _ _ _ ffl_s1 _ _ _ _,
                    Hb : out_break_or_return _ _ |- _ =>
      destruct (ffl_iter _ _ _ _ _ _ _ _ _ _ _ _ _ HC Hx HI)
        as [(-> & -> & ->) | [(-> & _ & _) | (-> & s & h & Hs & Hf & Hst & Hk & Hh)]];
      inv Hb
    end.
    + destruct HI as (nd & _ & _ & Hfl & _). split; [reflexivity | left; split; auto].
    + split; [reflexivity | right; exists s, h; auto 6].
  - (* the body continued, then Sskip went abrupt: impossible *)
    injection ES as -> ->.
    match goal with Hs : exec_stmt _ _ _ _ _ Sskip _ _ _ _,
                    Hb : out_break_or_return _ _ |- _ => inv Hs; inv Hb end.
  - (* one more round *)
    injection ES as -> ->.
    match goal with Hx : exec_stmt _ _ _ _ _ ffl_s1 _ _ _ _,
                    Hn : out_normal_or_continue _ |- _ =>
      destruct (ffl_iter _ _ _ _ _ _ _ _ _ _ _ _ _ HC Hx HI)
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
      \/ (on_list m node vres /\ exists h, Mem.storev Mfloat32 m ph (Vsingle h) = Some m' /\ hok y h
            /\ ffl_hit m vres x z h).
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
    assert (HI : Inv mm node ph x y z L)
      by (exists node; split; [ptg; reflexivity |]; split; [auto |];
          repeat (split; [ptg; reflexivity |]); ptg; reflexivity)
  end.
  match goal with Hx : exec_stmt _ _ _ _ _ (Ssequence _ _) _ _ _ _ |- _ => inv Hx end.
  - match goal with Hl : exec_stmt _ _ _ _ _ ffl_loop _ _ _ _ |- _ =>
      destruct (ffl_loop_spec _ _ _ _ _ _ _ _ _ _ _ _ _ HC Hl HI) as (_ & Hr) end.
    match goal with Hs : exec_stmt _ _ _ _ _ (Sreturn _) _ _ _ _ |- _ => inv Hs end.
    match goal with Ht : eval_expr _ _ _ _ (Etempvar _ _) _ |- _ =>
      inv Ht; [| match goal with Hl : eval_lvalue _ _ _ _ (Etempvar _ _) _ _ _ |- _ => inv Hl end] end.
    match goal with Ho : outcome_result_value _ _ _ _ |- _ => destruct Ho as (_ & Hc) end.
    apply cast_surf_ptr in Hc. subst vres.
    match goal with Hf : Mem.free_list _ _ = Some _ |- _ =>
      cbn [blocks_of_env PTree.elements Mem.free_list] in Hf; injection Hf as <- end.
    destruct Hr as [(-> & Hf) | (s & h & Hs & Hf & Hst & Hk & Hh)];
      match goal with Hg : _ ! surface_collision._floor = Some _ |- _ => rewrite Hf in Hg; inv Hg end.
    + left; auto.
    + right; eauto.
  - match goal with Hl : exec_stmt _ _ _ _ _ ffl_loop _ _ _ _ |- _ =>
      destruct (ffl_loop_spec _ _ _ _ _ _ _ _ _ _ _ _ _ HC Hl HI) as (-> & _) end.
    congruence.
Qed.

(* ====================================================================== *)
(* Toward find_floor: helpers                                              *)
(* ====================================================================== *)

(* reading a field through an arbitrary struct pointer *)
Lemma deref_field : forall (ge : genv) e le m A sid fld ty v d,
    (forall co, (genv_cenv ge) ! sid = Some co ->
       field_offset ge fld (co_members co) = OK (d, Full)) ->
    access_mode ty = By_value Mint32 ->
    eval_expr ge e le m (Efield (Ederef A (Tstruct sid noattr)) fld ty) v ->
    exists l ofs, eval_expr ge e le m A (Vptr l ofs)
      /\ Mem.loadv Mint32 m (Vptr l (Ptrofs.add ofs (Ptrofs.repr d))) = Some v.
Proof.
  intros ge e le m A sid fld ty v d Hfo Ham H.
  inv H.
  match goal with Hl : eval_lvalue _ _ _ _ (Efield _ _ _) _ _ _ |- _ => inv Hl end;
    [| cbn [typeof] in *; discriminate].
  match goal with Ha : eval_expr _ _ _ _ (Ederef _ _) _ |- _ => inv Ha end.
  match goal with Hl : eval_lvalue _ _ _ _ (Ederef _ _) _ _ _ |- _ => inv Hl end.
  cbn [typeof] in *.
  match goal with H5 : Tstruct _ _ = Tstruct _ _ |- _ => inv H5 end.
  match goal with Hd : deref_loc (Tstruct _ _) _ _ _ _ _ |- _ => inv Hd end;
    cbn [access_mode] in *; try discriminate.
  match goal with Hc : (genv_cenv ge) ! _ = Some _, Hf : field_offset _ _ _ = OK _ |- _ =>
    rewrite (Hfo _ Hc) in Hf; inv Hf end.
  do 2 eexists. split; [eassumption |].
  match goal with Hd : deref_loc ty _ _ _ _ _ |- _ => inv Hd end; congruence.
Qed.

(* a global array's address, indexed and dereferenced as arrays: it stays
   in the global's block *)
Fixpoint gaddr (id : ident) (a : expr) : bool :=
  match a with
  | Evar x (Tarray _ _ _) => Pos.eqb x id
  | Ebinop Oadd a1 a2 _ =>
      match classify_add (typeof a1) (typeof a2) with
      | add_case_pi _ _ => gaddr id a1
      | _ => false
      end
  | Ederef a1 (Tarray _ _ _) => gaddr id a1
  | _ => false
  end.

Lemma gaddr_eval : forall (ge : genv) e le m id,
    e ! id = None ->
    forall a v, gaddr id a = true -> eval_expr ge e le m a v ->
    exists bp o, Genv.find_symbol ge id = Some bp /\ v = Vptr bp o.
Proof.
  intros ge e le m id He a.
  induction a; cbn [gaddr]; intros v G H; try discriminate G.
  - destruct t; try discriminate G. apply Pos.eqb_eq in G. subst i.
    inv H.
    match goal with Hl : eval_lvalue _ _ _ _ (Evar _ _) _ _ _ |- _ => inv Hl end;
      [congruence |].
    match goal with Hd : deref_loc _ _ _ _ _ _ |- _ => inv Hd end;
      cbn [access_mode] in *; try discriminate.
    eauto.
  - destruct t; try discriminate G.
    inv H.
    match goal with Hl : eval_lvalue _ _ _ _ (Ederef _ _) _ _ _ |- _ => inv Hl end.
    match goal with Ha : eval_expr _ _ _ _ a _ |- _ => destruct (IHa _ G Ha) as (bp & o & Hs & Eo) end.
    inv Eo.
    match goal with Hd : deref_loc _ _ _ _ _ _ |- _ => inv Hd end;
      cbn [access_mode] in *; try discriminate. eauto.
  - destruct b; try discriminate G.
    destruct (classify_add (typeof a1) (typeof a2)) eqn:CA; try discriminate G.
    inv H; [| match goal with Hl : eval_lvalue _ _ _ _ (Ebinop _ _ _ _) _ _ _ |- _ => inv Hl end].
    match goal with Ha : eval_expr _ _ _ _ a1 _ |- _ => destruct (IHa1 _ G Ha) as (bp & o & Hs & ->) end.
    match goal with Hb : sem_binary_operation _ _ _ _ _ _ _ = Some _ |- _ =>
      cbn [sem_binary_operation] in Hb; unfold sem_add in Hb; rewrite CA in Hb;
      unfold sem_add_ptr_int in Hb end.
    match goal with Hb : match ?v2 with _ => _ end = Some _ |- _ =>
      destruct v2; try discriminate Hb; injection Hb as <- end.
    eauto.
Qed.

(* a NULL-terminated list in m whose nodes are valid blocks outside avoid *)
Inductive wf_list (m : mem) (avoid : block -> Prop) : val -> Prop :=
  | wf_nil : wf_list m avoid (Vint Int.zero)
  | wf_cons : forall bn on nx,
      Mem.valid_block m bn -> ~ avoid bn ->
      Mem.loadv Mint32 m (Vptr bn (Ptrofs.add on (Ptrofs.repr SN_NEXT))) = Some nx ->
      wf_list m avoid nx -> wf_list m avoid (Vptr bn on).

Definition keep (m : mem) (avoid : block -> Prop) : block -> Z -> Prop :=
  fun b _ => Mem.valid_block m b /\ ~ avoid b.

(* a list read in a later memory that kept the list's blocks is the same list *)
Lemma on_list_back : forall m avoid hd, wf_list m avoid hd ->
    forall m' s, Mem.unchanged_on (keep m avoid) m m' -> on_list m' hd s -> on_list m hd s.
Proof.
  intros m avoid hd W. induction W as [| bn on nx Hv Hav Hld W IH];
    intros m' s U OL; inv OL.
  - apply ol_here. cbn [Mem.loadv] in *.
    erewrite <- Mem.load_unchanged_on_1; [eassumption | exact U | exact Hv |].
    intros i _. split; assumption.
  - cbn [Mem.loadv] in *.
    match goal with Hn : Mem.load _ m' _ _ = Some ?nx' |- _ =>
      erewrite Mem.load_unchanged_on_1 in Hn; [| exact U | exact Hv | intros i _; split; assumption ];
      rewrite Hld in Hn; injection Hn as <- end.
    eapply ol_next; [exact Hld | eapply IH; eauto].
Qed.

(* the callee name resolves to the real body (same shape as
   MathGeomGated.resolves_to) *)
Definition ffl_pinned (ge : genv) : Prop :=
  forall bf f, Genv.find_symbol ge surface_collision._find_floor_from_list = Some bf ->
    Genv.find_funct_ptr ge bf = Some f -> f = Internal surface_collision.f_find_floor_from_list.

Lemma ffl_args5 : forall (ge : genv) m vargs t m' vres,
    eval_funcall function_entry2 ge m (Internal surface_collision.f_find_floor_from_list)
      vargs t m' vres ->
    exists node x y z ph, vargs = [node; x; y; z; ph].
Proof.
  intros ge m vargs t m' vres H.
  destruct vargs as [|node [|x [|y [|z [|ph [|w r]]]]]]; eauto 7;
    inv H; match goal with He : function_entry2 _ _ _ _ _ _ _ |- _ => inv He end;
    match goal with Hb : bind_parameter_temps _ _ _ = Some _ |- _ =>
      cbn [bind_parameter_temps surface_collision.f_find_floor_from_list fn_params] in Hb;
      discriminate Hb end.
Qed.

Lemma ffl_call : forall (ge : genv) e le m tid args targs tres cc t le' m' out,
    cenv_has ge -> ffl_pinned ge -> e ! surface_collision._find_floor_from_list = None ->
    exec_stmt function_entry2 ge e le m
      (Scall (Some tid) (Evar surface_collision._find_floor_from_list (Tfunction targs tres cc)) args)
      t le' m' out ->
    exists node x y z ph fl,
      eval_exprlist ge e le m args targs [node; x; y; z; ph]
      /\ out = Out_normal /\ le' = PTree.set tid fl le
      /\ ((m' = m /\ fl = Vint Int.zero)
          \/ (on_list m node fl /\ exists h, Mem.storev Mfloat32 m ph (Vsingle h) = Some m' /\ hok y h
                /\ ffl_hit m fl x z h)).
Proof.
  intros ge e le m tid args targs tres cc t le' m' out HC Hpin He H.
  inv H.
  cbn [typeof classify_fun] in *.
  match goal with Hc : fun_case_f _ _ _ = fun_case_f _ _ _ |- _ => inv Hc end.
  match goal with Hv : eval_expr _ _ _ _ (Evar _ _) _ |- _ => inv Hv end.
  match goal with Hl : eval_lvalue _ _ _ _ (Evar _ _) _ _ _ |- _ => inv Hl end; [congruence |].
  match goal with Hd : deref_loc _ _ _ _ _ _ |- _ => inv Hd end;
    cbn [access_mode] in *; try discriminate.
  match goal with Hf : Genv.find_funct _ (Vptr _ _) = Some _ |- _ =>
    cbn [Genv.find_funct] in Hf; rewrite pred_dec_true in Hf by reflexivity;
    rewrite (Hpin _ _ ltac:(eassumption) Hf) in * end.
  match goal with Hev : eval_funcall _ _ _ _ _ _ _ _ |- _ =>
    destruct (ffl_args5 _ _ _ _ _ _ Hev) as (node & x & y & z & ph & ->);
    destruct (ffl_value_contract _ HC _ _ _ _ _ _ _ _ _ Hev) as [(-> & ->) | (Ho & h & Hst & Hk & Hh)] end.
  - do 6 eexists. split; [eassumption |]. split; [reflexivity |]. split; [reflexivity |]. left; auto.
  - do 6 eexists. split; [eassumption |]. split; [reflexivity |]. split; [reflexivity |]. right; eauto.
Qed.

(* ====================================================================== *)
(* find_floor, by big-step TRIPLES over its real AST                       *)
(* ====================================================================== *)

Section TRI.
Variable ge : genv.
Variable e : env.

(* every execution of s from P either completes normally into Q, or exits
   abruptly (return) into R *)
Definition tri (P : temp_env -> mem -> Prop) (s : statement)
    (Q R : temp_env -> mem -> Prop) : Prop :=
  forall le M t le' M' out, P le M ->
    exec_stmt function_entry2 ge e le M s t le' M' out ->
    (out = Out_normal /\ Q le' M') \/ (out <> Out_normal /\ R le' M').

Lemma tri_seq : forall P s1 Q s2 Q' R,
    tri P s1 Q R -> tri Q s2 Q' R -> tri P (Ssequence s1 s2) Q' R.
Proof.
  intros P s1 Q s2 Q' R T1 T2 le M t le' M' out HP H. inv H.
  - match goal with H1 : exec_stmt _ _ _ _ _ s1 _ _ _ Out_normal,
                    H2 : exec_stmt _ _ _ _ _ s2 _ _ _ _ |- _ =>
      destruct (T1 _ _ _ _ _ _ HP H1) as [(_ & HQ) | (Hn & _)];
        [exact (T2 _ _ _ _ _ _ HQ H2) | congruence] end.
  - match goal with H1 : exec_stmt _ _ _ _ _ s1 _ _ _ _, Hne : _ <> Out_normal |- _ =>
      destruct (T1 _ _ _ _ _ _ HP H1) as [(-> & _) | (_ & HR)];
        [congruence | right; split; assumption] end.
Qed.

Lemma tri_ite : forall P a s1 s2 Q R,
    tri P s1 Q R -> tri P s2 Q R -> tri P (Sifthenelse a s1 s2) Q R.
Proof.
  intros P a s1 s2 Q R T1 T2 le M t le' M' out HP H. inv H.
  match goal with Hx : exec_stmt _ _ _ _ _ (if ?b then _ else _) _ _ _ _ |- _ =>
    destruct b; [exact (T1 _ _ _ _ _ _ HP Hx) | exact (T2 _ _ _ _ _ _ HP Hx)] end.
Qed.

Lemma tri_skip : forall P R, tri P Sskip P R.
Proof. intros P R le M t le' M' out HP H. inv H. left; auto. Qed.

Lemma tri_ret : forall (P : temp_env -> mem -> Prop) a Q (R : temp_env -> mem -> Prop),
    (forall le M, P le M -> R le M) -> tri P (Sreturn a) Q R.
Proof.
  intros P a Q R PR le M t le' M' out HP H.
  inv H; right; split; try discriminate; auto.
Qed.

Lemma tri_set : forall (P : temp_env -> mem -> Prop) x a R,
    (forall le M v, P le M -> eval_expr ge e le M a v -> P (PTree.set x v le) M) ->
    tri P (Sset x a) P R.
Proof. intros P x a R HS le M t le' M' out HP H. inv H. left; eauto. Qed.

Lemma tri_set2 : forall (P P' : temp_env -> mem -> Prop) x a R,
    (forall le M v, P le M -> eval_expr ge e le M a v -> P' (PTree.set x v le) M) ->
    tri P (Sset x a) P' R.
Proof. intros P P' x a R HS le M t le' M' out HP H. inv H. left; eauto. Qed.

Lemma tri_assign : forall (P : temp_env -> mem -> Prop) lhs rhs R,
    (forall le M b ofs bf v v' M', P le M ->
       eval_lvalue ge e le M lhs b ofs bf -> eval_expr ge e le M rhs v ->
       sem_cast v (typeof rhs) (typeof lhs) M = Some v' ->
       assign_loc ge (typeof lhs) M b ofs bf v' M' -> P le M') ->
    tri P (Sassign lhs rhs) P R.
Proof. intros P lhs rhs R HS le M t le' M' out HP H. inv H. left; eauto. Qed.

Lemma tri_strengthen : forall (P Q Q' R : temp_env -> mem -> Prop) s,
    tri P s Q R -> (forall le M, Q le M -> Q' le M) -> tri P s Q' R.
Proof.
  intros P Q Q' R s T W le M t le' M' out HP H.
  destruct (T _ _ _ _ _ _ HP H) as [(? & ?) | ?]; [left; auto | right; auto].
Qed.

End TRI.

(* a store, of any access mode, touches only its own block *)
Lemma assign_loc_frame : forall ce ty M b ofs bf v M',
    assign_loc ce ty M b ofs bf v M' ->
    Mem.unchanged_on (fun b' _ => b' <> b) M M'.
Proof.
  intros ce ty M b ofs bf v M' H. inv H.
  - eapply Mem.store_unchanged_on; [eassumption | intros i _ Hne; apply Hne; reflexivity].
  - eapply Mem.storebytes_unchanged_on; [eassumption | intros i _ Hne; apply Hne; reflexivity].
  - match goal with Hs : store_bitfield _ _ _ _ _ _ _ _ _ _ |- _ => inv Hs end.
    eapply Mem.store_unchanged_on; [eassumption | intros i _ Hne; apply Hne; reflexivity].
Qed.

Lemma cast_ptr_same : forall ty a v m vr,
    sem_cast v (Tpointer ty a) (Tpointer ty a) m = Some vr -> vr = v.
Proof. intros ty a v m vr H. destruct v; vm_compute in H; congruence. Qed.

Definition ff_statics : list ident :=
  [surface_collision._gFindFloorIncludeSurfaceIntangible;
   surface_collision._gNumFindFloorMisses; surface_collision._gNumCalls].
Definition part_ids : list ident :=
  [surface_collision._gStaticSurfacePartition; surface_collision._gDynamicSurfacePartition].

(* the static cells find_floor writes, with their sizes (each at offset 0;
   gNumCalls.floor is the first field) *)
Definition ff_cells : list (ident * Z) :=
  [(surface_collision._gFindFloorIncludeSurfaceIntangible, 2);
   (surface_collision._gNumFindFloorMisses, 4); (surface_collision._gNumCalls, 2)].

Definition is_static (ge : genv) (b : block) : Prop :=
  exists id, In id ff_statics /\ Genv.find_symbol ge id = Some b.

(* a list head stored anywhere in a partition array *)
Definition part_head (ge : genv) (m : mem) (hd : val) : Prop :=
  exists id bp o, In id part_ids /\ Genv.find_symbol ge id = Some bp
    /\ Mem.loadv Mint32 m (Vptr bp o) = Some hd.

(* the floor find_floor reports: NULL, or a surface on a partition list *)
Definition FL (ge : genv) (m : mem) (v : val) : Prop :=
  v = Vint Int.zero \/ exists hd, part_head ge m hd /\ on_list m hd v.

Ltac idne := let HH := fresh in intro HH; cbv in HH; discriminate HH.

Definition ffe (bH bD : block) : env :=
  PTree.set surface_collision._dynamicHeight (bD, tfloat)
    (PTree.set surface_collision._height (bH, tfloat) empty_env).

Lemma ffe_H : forall bH bD, (ffe bH bD) ! surface_collision._height = Some (bH, tfloat).
Proof. intros. unfold ffe. rewrite PTree.gso by idne. apply PTree.gss. Qed.
Lemma ffe_D : forall bH bD, (ffe bH bD) ! surface_collision._dynamicHeight = Some (bD, tfloat).
Proof. intros. unfold ffe. apply PTree.gss. Qed.
Lemma ffe_other : forall bH bD x,
    x <> surface_collision._height -> x <> surface_collision._dynamicHeight ->
    (ffe bH bD) ! x = None.
Proof. intros. unfold ffe. rewrite !PTree.gso by auto. apply PTree.gempty. Qed.

Section FF.
Variable ge : genv.
Variable avoid : block -> Prop.
Variable m : mem.
Variable bpf : block.
Variable opf : ptrofs.
Variables bH bD : block.
Hypothesis HC : cenv_has ge.
Hypothesis Hpin : ffl_pinned ge.
Hypothesis Hpf_av : avoid bpf.
Hypothesis Hpf_v : Mem.valid_block m bpf.
Hypothesis Hst : forall b, is_static ge b -> avoid b /\ b <> bpf.
Hypothesis Hpart : forall id bp, In id part_ids -> Genv.find_symbol ge id = Some bp ->
  Mem.valid_block m bp /\ ~ avoid bp.
Hypothesis Hwf : forall hd, part_head ge m hd -> wf_list m avoid hd.
Hypothesis HnvH : ~ Mem.valid_block m bH.
Hypothesis HnvD : ~ Mem.valid_block m bD.

Local Notation e := (ffe bH bD).

(* the cells find_floor may write: the *pfloor cell and the static cells *)
Definition wc (b : block) (i : Z) : Prop :=
  (b = bpf /\ Ptrofs.unsigned opf <= i < Ptrofs.unsigned opf + 4)
  \/ (exists id sz, In (id, sz) ff_cells /\ Genv.find_symbol ge id = Some b /\ 0 <= i < sz).

Definition kept (b : block) (i : Z) : Prop := Mem.valid_block m b /\ ~ wc b i.

(* every other cell of m is unchanged, and no permission of m changes *)
Definition UO (M : mem) : Prop :=
  Mem.unchanged_on kept m M
  /\ (forall b i k p, Mem.valid_block m b -> (Mem.perm m b i k p <-> Mem.perm M b i k p)).

Lemma avoid_wc : forall b i, wc b i -> avoid b.
Proof.
  intros b i [(-> & _) | (id & sz & Hin & Hs & _)]; [exact Hpf_av |].
  apply Hst. exists id. split; [| exact Hs].
  cbn in Hin |- *. destruct Hin as [Eq | [Eq | [Eq | []]]]; inv Eq; auto.
Qed.

Lemma UO_keep : forall M, UO M -> Mem.unchanged_on (keep m avoid) m M.
Proof.
  intros M (U & _). eapply Mem.unchanged_on_implies; [exact U |].
  intros b i (Hv & Hna) _. split; [exact Hv |]. intro Hw. exact (Hna (avoid_wc _ _ Hw)).
Qed.

(* a store into a block that is new, or into written cells only *)
Lemma UO_store : forall M M' ch b ofs v,
    UO M -> Mem.store ch M b ofs v = Some M' ->
    (~ Mem.valid_block m b \/ forall i, ofs <= i < ofs + size_chunk ch -> wc b i) -> UO M'.
Proof.
  intros M M' ch b ofs v (U & P) Hs Hb. split.
  - eapply Mem.unchanged_on_trans; [exact U |].
    eapply Mem.store_unchanged_on; [exact Hs |].
    intros i Hi (Hv & Hn). destruct Hb as [Hb | Hb]; [exact (Hb Hv) | exact (Hn (Hb i Hi))].
  - intros b' i k p Hv. rewrite (P b' i k p Hv).
    split; intro HH; [eapply Mem.perm_store_1; eauto | eapply Mem.perm_store_2; eauto].
Qed.
(* *pfloor holds a floor; the cell was writable already in m *)
Definition PFm (M : mem) : Prop :=
  exists v, (FL ge m v /\ Mem.valid_access m Mint32 bpf (Ptrofs.unsigned opf) Writable)
    /\ Mem.loadv Mint32 M (Vptr bpf opf) = Some (Val.load_result Mint32 v).

Definition IV (pfs sl dyn fl : bool) (le : temp_env) (M : mem) : Prop :=
  UO M
  /\ le ! surface_collision._pfloor = Some (Vptr bpf opf)
  /\ (pfs = true -> PFm M)
  /\ (sl = true -> exists v, le ! surface_collision._surfaceList = Some v /\ part_head ge m v)
  /\ (dyn = true -> exists v, le ! surface_collision._dynamicFloor = Some v /\ FL ge m v)
  /\ (fl = true -> exists v, le ! surface_collision._floor = Some v /\ FL ge m v).

Definition RR (le : temp_env) (M : mem) : Prop := UO M /\ PFm M.

Lemma bpf_ne : forall b, ~ Mem.valid_block m b -> b <> bpf.
Proof. intros b H ->. contradiction. Qed.

(* a step that touches one block outside the kept part, never bpf *)
Lemma IV_frame : forall pfs sl dyn fl le M M' ch b ofs v,
    IV pfs sl dyn fl le M -> Mem.store ch M b ofs v = Some M' ->
    (~ Mem.valid_block m b \/ forall i, ofs <= i < ofs + size_chunk ch -> wc b i) -> b <> bpf ->
    IV pfs sl dyn fl le M'.
Proof.
  intros pfs sl dyn fl le M M' ch b ofs v (U & Hp & PF & SL & DY & FLo) Hs Hb Hne.
  split; [| split; [exact Hp | split; [| split; [exact SL | split; [exact DY | exact FLo]]]]].
  - exact (UO_store _ _ _ _ _ _ U Hs Hb).
  - intros Ht. destruct (PF Ht) as (w & Hfl & Hl). exists w. split; [exact Hfl |].
    cbn [Mem.loadv] in *. erewrite Mem.load_store_other; [exact Hl | exact Hs |].
    left. exact (not_eq_sym Hne).
Qed.

Lemma lv_H : forall le M ty b ofs bf,
    eval_lvalue ge e le M (Evar surface_collision._height ty) b ofs bf -> b = bH.
Proof.
  intros le M ty b ofs bf H. inv H; rewrite ffe_H in *; congruence.
Qed.
Lemma lv_D : forall le M ty b ofs bf,
    eval_lvalue ge e le M (Evar surface_collision._dynamicHeight ty) b ofs bf -> b = bD.
Proof.
  intros le M ty b ofs bf H. inv H; rewrite ffe_D in *; congruence.
Qed.
Lemma lv_static : forall x le M ty b ofs bf,
    In x ff_statics -> eval_lvalue ge e le M (Evar x ty) b ofs bf ->
    Genv.find_symbol ge x = Some b /\ ofs = Ptrofs.zero /\ bf = Full.
Proof.
  intros x le M ty b ofs bf Hin H. inv H.
  - exfalso. cbn in Hin.
    match goal with Hx : (ffe _ _) ! _ = Some _ |- _ =>
      rewrite ffe_other in Hx; [discriminate Hx | |] end;
    destruct Hin as [<- | [<- | [<- | []]]]; idne.
  - auto.
Qed.

Lemma ntc_floor_ofs : forall co,
    (genv_cenv ge) ! surface_collision._NumTimesCalled = Some co ->
    field_offset ge surface_collision._floor (co_members co) = OK (0, Full).
Proof.
  intros co H.
  assert (M : match (prog_comp_env SC) ! surface_collision._NumTimesCalled with
              | Some co => co_members co | None => nil end
              = [Member_plain surface_collision._floor tshort;
                 Member_plain surface_collision._ceil tshort;
                 Member_plain surface_collision._wall tshort]) by (vm_compute; reflexivity).
  destruct ((prog_comp_env SC) ! surface_collision._NumTimesCalled) as [co0|] eqn:E0;
    [| discriminate M].
  rewrite (HC _ _ E0) in H. injection H as <-. rewrite M. reflexivity.
Qed.

Lemma lv_calls_floor : forall le M b ofs bf,
    eval_lvalue ge e le M
      (Efield (Evar surface_collision._gNumCalls (Tstruct surface_collision._NumTimesCalled noattr))
         surface_collision._floor tshort) b ofs bf ->
    Genv.find_symbol ge surface_collision._gNumCalls = Some b /\ ofs = Ptrofs.zero /\ bf = Full.
Proof.
  intros le M b ofs bf H. inv H; cbn [typeof] in *; try discriminate.
  match goal with Ha : eval_expr _ _ _ _ (Evar _ _) _ |- _ => inv Ha end.
  match goal with Hd : deref_loc _ _ _ _ _ _ |- _ => inv Hd end;
    cbn [access_mode] in *; try discriminate;
    [| match goal with Hb : load_bitfield _ _ _ _ _ _ _ _ |- _ => inv Hb end].
  match goal with Hl : eval_lvalue _ _ _ _ (Evar _ _) _ _ _ |- _ =>
    apply lv_static in Hl; [destruct Hl as (Hs & -> & _) | cbn; auto] end.
  match goal with Ht : Tstruct _ _ = Tstruct _ _ |- _ => injection Ht as <- _ end.
  match goal with Hc : (genv_cenv ge) ! _ = Some ?co, Hf : field_offset _ _ _ = OK _ |- _ =>
    rewrite (ntc_floor_ofs _ Hc) in Hf; injection Hf as <- <- end.
  split; [exact Hs | split; [exact (Ptrofs.add_zero Ptrofs.zero) | reflexivity]].
Qed.

(* the written lvalue: a new block (any access), or a static cell written
   by value *)
Definition wr_ok (ty : type) (b : block) (ofs : ptrofs) (bf : bitfield) : Prop :=
  b <> bpf /\
  (~ Mem.valid_block m b
   \/ (bf = Full /\ exists ch, access_mode ty = By_value ch
         /\ forall i, Ptrofs.unsigned ofs <= i < Ptrofs.unsigned ofs + size_chunk ch -> wc b i)).

Lemma tri_frame : forall lhs rhs pfs sl dyn fl R,
    (forall le M b ofs bf, eval_lvalue ge e le M lhs b ofs bf -> wr_ok (typeof lhs) b ofs bf) ->
    tri ge e (IV pfs sl dyn fl) (Sassign lhs rhs) (IV pfs sl dyn fl) R.
Proof.
  intros lhs rhs pfs sl dyn fl R Hl. apply tri_assign.
  intros le M b ofs bf v v' M' HI Hlv _ _ Ha.
  destruct (Hl _ _ _ _ _ Hlv) as (Hne & [Hnv | (-> & ch & Ham & Hw)]).
  - (* a new block: any kind of write keeps UO and the pfloor cell *)
    destruct HI as (U & Hp & PF & SL & DY & FLo).
    pose proof (assign_loc_frame _ _ _ _ _ _ _ _ Ha) as Hu.
    assert (Hperm : forall b' i k p, b' <> b -> (Mem.perm M b' i k p <-> Mem.perm M' b' i k p)).
    { intros b' i k p Hn. inv Ha.
      - cbn [Mem.storev] in *. split; intro HH; [eapply Mem.perm_store_1 | eapply Mem.perm_store_2]; eauto.
      - split; intro HH; [eapply Mem.perm_storebytes_1 | eapply Mem.perm_storebytes_2]; eauto.
      - match goal with Hb : store_bitfield _ _ _ _ _ _ _ _ _ _ |- _ => inv Hb end.
        cbn [Mem.storev] in *. split; intro HH; [eapply Mem.perm_store_1 | eapply Mem.perm_store_2]; eauto. }
    destruct U as (U & P).
    split; [split |].
    + eapply Mem.unchanged_on_trans; [exact U |].
      eapply Mem.unchanged_on_implies; [exact Hu |].
      intros b' i (Hv & _) _ ->. contradiction.
    + intros b' i k p Hv. rewrite (P b' i k p Hv). apply Hperm. intros ->. contradiction.
    + split; [exact Hp | split; [| split; [exact SL | split; [exact DY | exact FLo]]]].
      intros Ht. destruct (PF Ht) as (w & Hfl & Hld). exists w. split; [exact Hfl |].
      cbn [Mem.loadv] in *.
      erewrite Mem.load_unchanged_on_1; [exact Hld | exact Hu | | intros i _; exact (not_eq_sym Hne)].
      eapply Mem.valid_access_valid_block.
      eapply Mem.valid_access_implies; [eapply Mem.load_valid_access; eauto | constructor].
  - inv Ha; try congruence;
      match goal with Hm : access_mode _ = _ |- _ => rewrite Ham in Hm; try discriminate Hm end.
    match goal with Hm : By_value _ = By_value _ |- _ => inv Hm end.
    cbn [Mem.storev] in *.
    exact (IV_frame _ _ _ _ _ _ _ _ _ _ _ HI ltac:(eassumption) (or_intror Hw) Hne).
Qed.

Lemma tri_set_un : forall x a pfs sl dyn fl R,
    x <> surface_collision._pfloor -> x <> surface_collision._surfaceList ->
    x <> surface_collision._dynamicFloor -> x <> surface_collision._floor ->
    tri ge e (IV pfs sl dyn fl) (Sset x a) (IV pfs sl dyn fl) R.
Proof.
  intros x a pfs sl dyn fl R N1 N2 N3 N4. apply tri_set.
  intros le M v (U & Hp & PF & SL & DY & FLo) _.
  split; [exact U |]. split; [rewrite PTree.gso by congruence; exact Hp |].
  split; [exact PF |].
  split; [intros Ht; destruct (SL Ht) as (w & ? & ?); exists w; rewrite PTree.gso by congruence; auto |].
  split; [intros Ht; destruct (DY Ht) as (w & ? & ?); exists w; rewrite PTree.gso by congruence; auto |].
  intros Ht; destruct (FLo Ht) as (w & ? & ?); exists w; rewrite PTree.gso by congruence; auto.
Qed.

Lemma UO_free : forall M M' b lo hi,
    UO M -> Mem.free M b lo hi = Some M' -> ~ Mem.valid_block m b -> UO M'.
Proof.
  intros M M' b lo hi (U & P) Hf Hn. split.
  - eapply Mem.unchanged_on_trans; [exact U |].
    eapply Mem.free_unchanged_on; [exact Hf |]. intros i _ (Hv & _). exact (Hn Hv).
  - intros b' i k p Hv. rewrite (P b' i k p Hv).
    assert (Hne : b' <> b) by (intros ->; contradiction).
    split; intro HH; [eapply Mem.perm_free_1; eauto | eapply Mem.perm_free_3; eauto].
Qed.

Definition untracked (x : ident) : Prop :=
  x <> surface_collision._pfloor /\ x <> surface_collision._surfaceList
  /\ x <> surface_collision._dynamicFloor /\ x <> surface_collision._floor.

Lemma IV_set_un : forall pfs sl dyn fl le M x v,
    IV pfs sl dyn fl le M -> untracked x -> IV pfs sl dyn fl (PTree.set x v le) M.
Proof.
  intros pfs sl dyn fl le M x v (U & Hp & PF & SL & DY & FLo) (N1 & N2 & N3 & N4).
  split; [exact U |]. split; [rewrite PTree.gso by congruence; exact Hp |].
  split; [exact PF |].
  split; [intros Ht; destruct (SL Ht) as (w & ? & ?); exists w; rewrite PTree.gso by congruence; auto |].
  split; [intros Ht; destruct (DY Ht) as (w & ? & ?); exists w; rewrite PTree.gso by congruence; auto |].
  intros Ht; destruct (FLo Ht) as (w & ? & ?); exists w; rewrite PTree.gso by congruence; auto.
Qed.

Definition surf_t : type := Tstruct surface_collision._Surface noattr.

Lemma tri_pf_store : forall rhs pfs sl dyn fl R,
    (forall le M v v', IV pfs sl dyn fl le M -> eval_expr ge e le M rhs v ->
       sem_cast v (typeof rhs) (tptr surf_t) M = Some v' -> FL ge m v') ->
    tri ge e (IV pfs sl dyn fl)
      (Sassign (Ederef (Etempvar surface_collision._pfloor (tptr (tptr surf_t))) (tptr surf_t)) rhs)
      (IV true sl dyn fl) R.
Proof.
  intros rhs pfs sl dyn fl R Hv le M t le' M' out HI H. inv H. left; split; [reflexivity |].
  pose proof HI as (U & Hp & PF & SL & DY & FLo).
  match goal with Hl : eval_lvalue _ _ _ _ (Ederef _ _) _ _ _ |- _ => inv Hl end.
  match goal with Ht : eval_expr _ _ _ _ (Etempvar _ _) _ |- _ =>
    inv Ht; [| match goal with Hl : eval_lvalue _ _ _ _ (Etempvar _ _) _ _ _ |- _ => inv Hl end] end.
  rewrite Hp in *. match goal with Hx : Some _ = Some _ |- _ => inv Hx end.
  match goal with Hc : sem_cast _ _ _ _ = Some _, He : eval_expr _ _ _ _ rhs _ |- _ =>
    pose proof (Hv _ _ _ _ HI He Hc) as Hfl end.
  match goal with Ha : assign_loc _ _ _ _ _ _ _ _ |- _ =>
    pose proof (assign_loc_frame _ _ _ _ _ _ _ _ Ha) as Hu; inv Ha end;
    cbn [access_mode typeof] in *; try discriminate.
  match goal with Hm : access_mode _ = By_value _ |- _ =>
    change (access_mode (tptr surf_t)) with (By_value Mint32) in Hm; inv Hm end.
  split; [refine (UO_store _ _ _ _ _ _ U ltac:(eassumption) (or_intror _));
          intros i Hi; left; split; [reflexivity | exact Hi] |].
  split; [exact Hp |].
  split; [| split; [exact SL | split; [exact DY | exact FLo]]].
  intros _. eexists. split; [split; [exact Hfl |] |].
  { cbn [Mem.storev] in *.
    match goal with Hs : Mem.store _ _ _ _ _ = Some _ |- _ =>
      destruct (Mem.store_valid_access_3 _ _ _ _ _ _ Hs) as (Hr & Ha) end.
    split; [| exact Ha]. intros i Hi.
    apply (proj2 U bpf i Cur Writable Hpf_v). exact (Hr i Hi). }
  cbn [Mem.loadv Mem.storev] in *.
  erewrite Mem.load_store_same; [reflexivity | eassumption].
Qed.

Lemma tri_sl : forall pid A pfs sl dyn fl R,
    In pid part_ids -> gaddr pid A = true ->
    tri ge e (IV pfs sl dyn fl)
      (Sset surface_collision._surfaceList
         (Efield (Ederef A (Tstruct surface_collision._SurfaceNode noattr))
            surface_collision._next (tptr (Tstruct surface_collision._SurfaceNode noattr))))
      (IV pfs true dyn fl) R.
Proof.
  intros pid A pfs sl dyn fl R Hin G le M t le' M' out HI H. inv H. left; split; [reflexivity |].
  destruct HI as (U & Hp & PF & SL & DY & FLo).
  match goal with Hx : eval_expr _ _ ?L ?MM (Efield _ _ _) ?v |- _ =>
    destruct (deref_field ge e L MM A surface_collision._SurfaceNode surface_collision._next
                (tptr (Tstruct surface_collision._SurfaceNode noattr)) v SN_NEXT
                (fun co Hc => proj1 (sn_offsets_ge ge co HC Hc)) eq_refl Hx)
      as (l & ofs & HA & Hld) end.
  assert (Hne : e ! pid = None)
    by (apply ffe_other; destruct Hin as [<- | [<- | []]]; idne).
  destruct (gaddr_eval ge e _ _ pid Hne A _ G HA) as (bp & o & Hs & Eq). inv Eq.
  destruct (Hpart pid bp Hin Hs) as (Hvb & Hna).
  split; [exact U |]. split; [rewrite PTree.gso by idne; exact Hp |].
  split; [exact PF |].
  split; [intros _; eexists; split; [apply PTree.gss |] |].
  { exists pid, bp, (Ptrofs.add o (Ptrofs.repr SN_NEXT)). split; [exact Hin |]. split; [exact Hs |].
    cbn [Mem.loadv] in *.
    erewrite <- Mem.load_unchanged_on_1; [exact Hld | exact (UO_keep _ U) | exact Hvb |].
    intros i _. split; assumption. }
  split; [intros Ht; destruct (DY Ht) as (w & ? & ?); exists w; rewrite PTree.gso by idne; auto |].
  intros Ht; destruct (FLo Ht) as (w & ? & ?); exists w; rewrite PTree.gso by idne; auto.
Qed.

Definition IVk (pfs dyn fl : bool) (tk : ident) (le : temp_env) (M : mem) : Prop :=
  IV pfs true dyn fl le M /\ exists v, le ! tk = Some v /\ FL ge m v.

Lemma tri_call1 : forall tk tres cc loc bL a1 a2 a3 pfs dyn fl R,
    ((loc = surface_collision._height /\ bL = bH)
     \/ (loc = surface_collision._dynamicHeight /\ bL = bD)) ->
    untracked tk ->
    tri ge e (IV pfs true dyn fl)
      (Scall (Some tk)
         (Evar surface_collision._find_floor_from_list
            (Tfunction [tptr (Tstruct surface_collision._SurfaceNode noattr); tint; tint; tint;
                        tptr tfloat] tres cc))
         [Etempvar surface_collision._surfaceList
            (tptr (Tstruct surface_collision._SurfaceNode noattr));
          a1; a2; a3; Eaddrof (Evar loc tfloat) (tptr tfloat)])
      (IVk pfs dyn fl tk) R.
Proof.
  intros tk tres cc loc bL a1 a2 a3 pfs dyn fl R Hloc Htk.
  intros le M t le' M' out HI H.
  assert (Hn : e ! surface_collision._find_floor_from_list = None) by (apply ffe_other; idne).
  destruct (ffl_call _ _ _ _ _ _ _ _ _ _ _ _ _ HC Hpin Hn H)
    as (node & x & y & z & ph & fl0 & Hargs & -> & -> & Hres).
  left; split; [reflexivity |].
  pose proof HI as (U & Hp & PF & SL & DY & FLo).
  destruct (SL eq_refl) as (vsl & Hsl & PH).
  (* the arguments *)
  inv Hargs.
  match goal with Ht : eval_expr _ _ _ _ (Etempvar _ _) _ |- _ =>
    inv Ht; [| match goal with Hl : eval_lvalue _ _ _ _ (Etempvar _ _) _ _ _ |- _ => inv Hl end] end.
  match goal with Hc : sem_cast _ (typeof (Etempvar _ _)) _ _ = Some _ |- _ =>
    cbn [typeof] in Hc; apply cast_ptr_same in Hc; subst end.
  rewrite Hsl in *. match goal with Hx : Some _ = Some _ |- _ => inv Hx end.
  repeat match goal with Hl : eval_exprlist _ _ _ _ (_ :: _) _ _ |- _ => inv Hl end.
  match goal with Ha : eval_expr _ _ _ _ (Eaddrof _ _) _ |- _ =>
    inv Ha; [| match goal with Hl : eval_lvalue _ _ _ _ (Eaddrof _ _) _ _ _ |- _ => inv Hl end] end.
  match goal with Hl : eval_lvalue _ _ _ _ (Evar _ _) _ _ _ |- _ => inv Hl end;
    [| destruct Hloc as [(-> & _) | (-> & _)];
       [rewrite ffe_H in * | rewrite ffe_D in *]; discriminate].
  match goal with Hx : (ffe _ _) ! loc = Some (?bb, _) |- _ =>
    assert (Eb : bb = bL)
      by (destruct Hloc as [(-> & ->) | (-> & ->)];
          [rewrite ffe_H in Hx | rewrite ffe_D in Hx]; congruence);
    subst bb end.
  match goal with Hc : sem_cast _ (typeof (Eaddrof _ _)) _ _ = Some _ |- _ =>
    cbn [typeof] in Hc; apply cast_ptr_same in Hc; subst end.
  assert (HnvL : ~ Mem.valid_block m bL) by (destruct Hloc as [(_ & ->) | (_ & ->)]; assumption).
  destruct Hres as [(-> & ->) | (Hon & h & Hstv & Hk)].
  + split; [exact (IV_set_un _ _ _ _ _ _ _ _ HI Htk) |].
    eexists; split; [apply PTree.gss | left; reflexivity].
  + cbn [Mem.storev] in Hstv.
    split; [exact (IV_set_un _ _ _ _ _ _ _ _
                     (IV_frame _ _ _ _ _ _ _ _ _ _ _ HI Hstv (or_introl HnvL) (bpf_ne _ HnvL)) Htk) |].
    eexists; split; [apply PTree.gss |].
    right. eexists. split; [exact PH |].
    exact (on_list_back _ _ _ (Hwf _ PH) _ _ (UO_keep _ U) Hon).
Qed.

Lemma tri_take : forall tk dst Tk pfs dyn fl dyn' fl' R,
    ((dst = surface_collision._dynamicFloor /\ dyn' = true /\ fl' = fl)
     \/ (dst = surface_collision._floor /\ dyn' = dyn /\ fl' = true)) ->
    tri ge e (IVk pfs dyn fl tk) (Sset dst (Etempvar tk Tk)) (IV pfs true dyn' fl') R.
Proof.
  intros tk dst Tk pfs dyn fl dyn' fl' R Hdst.
  apply tri_set2. intros le M v ((U & Hp & PF & SL & DY & FLo) & (w & Hw & Hfw)) Hev.
  inv Hev; [| match goal with Hl : eval_lvalue _ _ _ _ (Etempvar _ _) _ _ _ |- _ => inv Hl end].
  match goal with Hx : le ! tk = Some _ |- _ => rewrite Hw in Hx; inv Hx end.
  destruct Hdst as [(-> & -> & ->) | (-> & -> & ->)].
  + split; [exact U |]. split; [rewrite PTree.gso by idne; exact Hp |].
    split; [exact PF |].
    split; [intros Ht; destruct (SL Ht) as (w' & ? & ?); exists w'; rewrite PTree.gso by idne; auto |].
    split; [intros _; exists v; split; [apply PTree.gss | exact Hfw] |].
    intros Ht; destruct (FLo Ht) as (w' & ? & ?); exists w'; rewrite PTree.gso by idne; auto.
  + split; [exact U |]. split; [rewrite PTree.gso by idne; exact Hp |].
    split; [exact PF |].
    split; [intros Ht; destruct (SL Ht) as (w' & ? & ?); exists w'; rewrite PTree.gso by idne; auto |].
    split; [intros Ht; destruct (DY Ht) as (w' & ? & ?); exists w'; rewrite PTree.gso by idne; auto |].
    intros _; exists v; split; [apply PTree.gss | exact Hfw].
Qed.

Lemma tri_floor_dyn : forall T pfs sl fl R,
    tri ge e (IV pfs sl true fl)
      (Sset surface_collision._floor (Etempvar surface_collision._dynamicFloor T))
      (IV pfs sl true true) R.
Proof.
  intros T pfs sl fl R. apply tri_set2.
  intros le M v (U & Hp & PF & SL & DY & FLo) Hev.
  inv Hev; [| match goal with Hl : eval_lvalue _ _ _ _ (Etempvar _ _) _ _ _ |- _ => inv Hl end].
  destruct (DY eq_refl) as (w & Hw & Hfw).
  match goal with Hx : le ! _ = Some v |- _ => rewrite Hw in Hx; inv Hx end.
  split; [exact U |]. split; [rewrite PTree.gso by idne; exact Hp |].
  split; [exact PF |].
  split; [intros Ht; destruct (SL Ht) as (w' & ? & ?); exists w'; rewrite PTree.gso by idne; auto |].
  split; [intros _; eexists; rewrite PTree.gso by idne; eauto |].
  intros _; eexists; split; [apply PTree.gss | eassumption].
Qed.

Lemma IV_RR : forall sl dyn fl le M, IV true sl dyn fl le M -> RR le M.
Proof. intros sl dyn fl le M (U & _ & PF & _). split; [exact U | exact (PF eq_refl)]. Qed.

Lemma null_FL : forall le M v v',
    eval_expr ge e le M (Ecast (Econst_int (Int.repr 0) tint) (tptr tvoid)) v ->
    sem_cast v (tptr tvoid) (tptr surf_t) M = Some v' -> FL ge m v'.
Proof.
  intros le M v v' Hev Hc.
  inv Hev; [| match goal with Hl : eval_lvalue _ _ _ _ (Ecast _ _) _ _ _ |- _ => inv Hl end].
  match goal with Hk : eval_expr _ _ _ _ (Econst_int _ _) _ |- _ =>
    inv Hk; [| match goal with Hl : eval_lvalue _ _ _ _ (Econst_int _ _) _ _ _ |- _ => inv Hl end] end.
  match goal with H1 : sem_cast (Vint _) _ _ _ = Some _ |- _ =>
    change (sem_cast (Vint (Int.repr 0)) (typeof (Econst_int (Int.repr 0) tint)) (tptr tvoid) M)
      with (Some (Vint (Int.repr 0))) in H1; injection H1 as <- end.
  change (sem_cast (Vint (Int.repr 0)) (tptr tvoid) (tptr surf_t) M)
    with (Some (Vint (Int.repr 0))) in Hc.
  injection Hc as <-. left. reflexivity.
Qed.

Lemma floor_FL : forall pfs sl dyn le M v v',
    IV pfs sl dyn true le M ->
    eval_expr ge e le M (Etempvar surface_collision._floor (tptr surf_t)) v ->
    sem_cast v (tptr surf_t) (tptr surf_t) M = Some v' -> FL ge m v'.
Proof.
  intros pfs sl dyn le M v v' (_ & _ & _ & _ & _ & FLo) Hev Hc.
  apply cast_ptr_same in Hc. subst v'.
  inv Hev; [| match goal with Hl : eval_lvalue _ _ _ _ (Etempvar _ _) _ _ _ |- _ => inv Hl end].
  destruct (FLo eq_refl) as (w & Hw & Hf). congruence.
Qed.

Ltac untr := split; [idne | split; [idne | split; idne]].
Ltac locok := first [left; split; reflexivity | right; split; reflexivity].
Ltac dstok := first [left; split; [reflexivity | split; reflexivity]
                    | right; split; [reflexivity | split; reflexivity]].
Ltac inlist := cbn; repeat (first [left; reflexivity | right]).
Ltac wcok Hs :=
  lazymatch type of Hs with Genv.find_symbol _ ?x = Some ?b =>
    let Hin := fresh in let Hne := fresh in
    assert (Hin : In x ff_statics) by inlist;
    destruct (Hst b (ex_intro _ x (conj Hin Hs))) as (_ & Hne);
    split; [exact Hne |];
    right; split; [reflexivity |]; eexists; split; [reflexivity |];
    let i := fresh in let Hi := fresh in
    intros i Hi; right; exists x; eexists; split; [inlist | split; [exact Hs |]];
    rewrite Ptrofs.unsigned_zero in Hi; cbn [size_chunk] in Hi; lia
  end.
Ltac lvok :=
  let le := fresh in let M := fresh in let b := fresh in let o := fresh in
  let bf := fresh in let Hl := fresh in
  intros le M b o bf Hl;
  first [ apply lv_H in Hl; subst b; split; [exact (bpf_ne _ HnvH) | left; exact HnvH]
        | apply lv_D in Hl; subst b; split; [exact (bpf_ne _ HnvD) | left; exact HnvD]
        | apply lv_calls_floor in Hl; destruct Hl as (Hs & -> & ->); wcok Hs
        | apply lv_static in Hl; [destruct Hl as (Hs & -> & ->); wcok Hs | inlist] ].
Ltac pfok :=
  let le := fresh in let M := fresh in let v := fresh in let v' := fresh in
  let HI := fresh in let Hev := fresh in let Hc := fresh in
  intros le M v v' HI Hev Hc; cbn [typeof] in Hc;
  first [ exact (null_FL _ _ _ _ Hev Hc) | exact (floor_FL _ _ _ _ _ _ _ HI Hev Hc) ].

Ltac base_id A :=
  lazymatch A with
  | Evar ?x _ => x
  | Ebinop _ ?a1 _ _ => base_id a1
  | Ederef ?a1 _ => base_id a1
  end.

Ltac solve_tri :=
  lazymatch goal with
  | |- tri _ _ _ (Ssequence (Scall _ _ _) (Sset _ _)) _ _ =>
      eapply tri_seq; [eapply tri_call1; [locok | untr] | eapply tri_take; dstok]
  | |- tri _ _ _ (Ssequence _ _) _ _ => eapply tri_seq; [solve_tri | solve_tri]
  | |- tri _ _ _ (Sifthenelse _ _ _) _ _ => eapply tri_ite; [solve_tri | solve_tri]
  | |- tri _ _ _ Sskip _ _ => eapply tri_skip
  | |- tri _ _ _ (Sreturn _) _ _ =>
      eapply tri_ret; let HH := fresh in intros ? ? HH; eapply IV_RR; exact HH
  | |- tri _ _ _ (Scall _ _ _) _ _ => eapply tri_call1; [locok | untr]
  | |- tri _ _ _ (Sset surface_collision._surfaceList (Efield (Ederef ?A _) _ _)) _ _ =>
      let pid := base_id A in eapply (tri_sl pid); [inlist | reflexivity]
  | |- tri _ _ (IVk _ _ _ _) (Sset _ _) _ _ => eapply tri_take; dstok
  | |- tri _ _ _ (Sset surface_collision._floor (Etempvar surface_collision._dynamicFloor _)) _ _ =>
      eapply tri_floor_dyn
  | |- tri _ _ _ (Sset _ _) _ _ => eapply tri_set_un; idne
  | |- tri _ _ _ (Sassign (Ederef (Etempvar surface_collision._pfloor _) _) _) _ _ =>
      eapply tri_pf_store; pfok
  | |- tri _ _ _ (Sassign _ _) _ _ => eapply tri_frame; lvok
  end.

Lemma ff_body_tri :
  tri ge e (IV false false false false) (fn_body surface_collision.f_find_floor)
    (fun _ _ => True) RR.
Proof.
  eapply tri_strengthen; [| intros; exact I].
  cbn [fn_body surface_collision.f_find_floor].
  solve_tri.
  Unshelve. all: exact (fun _ _ => True).
Qed.

End FF.

(* a float function returns a single *)
Lemma orv_single : forall out vres M,
    outcome_result_value out tfloat vres M -> exists h, vres = Vsingle h.
Proof.
  intros out vres M H. destruct out as [| | |[[v ty]|]]; cbn in H; try contradiction.
  destruct H as (_ & H). unfold sem_cast in H.
  destruct ty as [| [] [] ? | [] ? | [] ? | | | | |]; destruct v; cbn in H;
    try discriminate; try (destruct Archi.ptr64; discriminate);
    try (injection H as <-; eauto).
  all: try (destruct (Float.to_single _) ; injection H as <-; eauto).
  all: try (destruct (Mem.weak_valid_pointer _ _ _); discriminate).
Qed.

(* freeing a block that is new keeps UO and the pfloor cell *)
Lemma free_keeps : forall ge m bpf opf M M' b,
    Mem.valid_block m bpf -> UO ge m bpf opf M -> PFm ge m bpf opf M -> ~ Mem.valid_block m b ->
    Mem.free M b 0 4 = Some M' -> UO ge m bpf opf M' /\ PFm ge m bpf opf M'.
Proof.
  intros ge m bpf opf M M' b Hpv U (v & Hv & Hl) Hn Hf.
  split; [eapply UO_free; eauto |].
  exists v; split; [exact Hv |].
  cbn [Mem.loadv] in *. erewrite Mem.load_free; [exact Hl | exact Hf |].
  left. intros ->. contradiction.
Qed.

(* THE CONTRACT: find_floor stores into *pfloor either NULL or a surface
   read off a partition list (of the entry memory).  Every cell of the entry
   memory other than *pfloor and the three static cells (ff_cells) is
   unchanged, and no permission changes.  The statics and the pfloor block
   must be outside the lists ("avoid"); the lists must be well formed. *)
Theorem ff_value_contract : forall (ge : genv) avoid,
    cenv_has ge -> ffl_pinned ge ->
    forall m xv yv zv bpf opf t m' vres,
      avoid bpf -> Mem.valid_block m bpf ->
      (forall b, is_static ge b -> avoid b /\ b <> bpf) ->
      (forall id bp, In id part_ids -> Genv.find_symbol ge id = Some bp ->
         Mem.valid_block m bp /\ ~ avoid bp) ->
      (forall hd, part_head ge m hd -> wf_list m avoid hd) ->
      eval_funcall function_entry2 ge m (Internal surface_collision.f_find_floor)
        [xv; yv; zv; Vptr bpf opf] t m' vres ->
      exists fl, FL ge m fl
        /\ Mem.loadv Mint32 m' (Vptr bpf opf) = Some (Val.load_result Mint32 fl)
        /\ UO ge m bpf opf m'
        /\ Mem.valid_access m Mint32 bpf (Ptrofs.unsigned opf) Writable
        /\ exists h, vres = Vsingle h.
Proof.
  intros ge avoid HC Hpin m xv yv zv bpf opf t m' vres Hav Hpv Hst Hpart Hwf H.
  inv H.
  match goal with He : function_entry2 _ _ _ _ _ _ _ |- _ => inv He end.
  match goal with Ha : alloc_variables _ _ _ _ _ _ |- _ =>
    cbn [surface_collision.f_find_floor fn_vars] in Ha; inv Ha end.
  match goal with Ha : alloc_variables _ _ _ _ _ _ |- _ => inv Ha end.
  match goal with Ha : alloc_variables _ _ _ [] _ _ |- _ => inv Ha end.
  match goal with
  | A1 : Mem.alloc m 0 _ = (?M1, ?b1), A2 : Mem.alloc ?M1 0 _ = (?M2, ?b2) |- _ =>
      rename b1 into bH, b2 into bD, A1 into HA1, A2 into HA2, M1 into mA, M2 into mB
  end.
  assert (HnvH : ~ Mem.valid_block m bH) by exact (Mem.fresh_block_alloc _ _ _ _ _ HA1).
  assert (HnvD : ~ Mem.valid_block m bD)
    by (intro HH; exact (Mem.fresh_block_alloc _ _ _ _ _ HA2 (Mem.valid_block_alloc _ _ _ _ _ HA1 _ HH))).
  assert (U2 : UO ge m bpf opf mB).
  { split.
    - eapply Mem.unchanged_on_trans; eapply Mem.alloc_unchanged_on; eassumption.
    - intros b i k p Hv.
      assert (N1 : b <> bH) by (intros ->; contradiction).
      assert (N2 : b <> bD) by (intros ->; contradiction).
      split; intro HH.
      + eapply Mem.perm_alloc_1; [exact HA2 |]. eapply Mem.perm_alloc_1; [exact HA1 | exact HH].
      + eapply Mem.perm_alloc_4; [exact HA1 | | exact N1].
        eapply Mem.perm_alloc_4; [exact HA2 | exact HH | exact N2]. }
  match goal with Hb : bind_parameter_temps _ _ _ = Some ?L |- _ =>
    assert (HI : IV ge m bpf opf false false false false L mB)
  end.
  { match goal with Hb : bind_parameter_temps _ _ _ = Some _ |- _ =>
      cbn [bind_parameter_temps surface_collision.f_find_floor fn_params] in Hb;
      injection Hb as <- end.
    split; [exact U2 |]. split; [ptg; reflexivity |].
    repeat split; discriminate. }
  match goal with Hx : exec_stmt _ _ _ _ _ _ _ _ _ _ |- _ =>
    destruct (ff_body_tri ge avoid m bpf opf bH bD HC Hpin Hav Hpv Hst Hpart Hwf HnvH HnvD
                _ _ _ _ _ _ HI Hx) as [(-> & _) | (_ & U3 & PF3)] end.
  { match goal with Ho : outcome_result_value _ _ _ _ |- _ => cbn in Ho; contradiction end. }
  match goal with Hf : Mem.free_list ?M _ = Some ?R |- _ =>
    first [ change (Mem.free_list M [(bH, 0, 4); (bD, 0, 4)] = Some R) in Hf
          | change (Mem.free_list M [(bD, 0, 4); (bH, 0, 4)] = Some R) in Hf ];
    cbn [Mem.free_list] in Hf end.
  match goal with Hf : (match Mem.free ?M ?b1 0 4 with Some _ => _ | None => _ end) = Some _ |- _ =>
    destruct (Mem.free M b1 0 4) as [M4|] eqn:F1; [| discriminate Hf];
    assert (N1 : ~ Mem.valid_block m b1) by assumption end.
  match goal with Hf : (match Mem.free ?M ?b1 0 4 with Some _ => _ | None => _ end) = Some _ |- _ =>
    destruct (Mem.free M b1 0 4) as [M5|] eqn:F2; [| discriminate Hf]; injection Hf as <-;
    assert (N2 : ~ Mem.valid_block m b1) by assumption end.
  destruct (free_keeps _ _ _ _ _ _ _ Hpv U3 PF3 N1 F1) as (U4 & PF4).
  destruct (free_keeps _ _ _ _ _ _ _ Hpv U4 PF4 N2 F2) as (U5 & (fl & (Hfl & Hwr) & Hld)).
  exists fl. split; [exact Hfl | split; [exact Hld | split; [exact U5 | split; [exact Hwr |]]]].
  match goal with Ho : outcome_result_value _ _ _ _ |- _ =>
    cbn [fn_return surface_collision.f_find_floor] in Ho; exact (orv_single _ _ _ Ho) end.
Qed.
