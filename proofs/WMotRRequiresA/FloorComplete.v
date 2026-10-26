(* ====================================================================== *)
(* FloorComplete (GOAL 2): find_floor_from_list is COMPLETE.               *)
(*                                                                          *)
(* FloorList proves what find_floor_from_list returns when it returns a     *)
(* surface (a hit) and that it may return NULL.  This file proves the       *)
(* converse, from the same generated Clight body: when a surface the loop   *)
(* accepts at (x, y, z) is on the list ([pass]: the three edge tests, the   *)
(* camera-flag / CAMERA_BOUNDARY tests, ny <> 0 and the height test all     *)
(* pass), the call does NOT return NULL.                                    *)
(*                                                                          *)
(* This is the first half of the NULL-floor repair (TRUST 7, the           *)
(* update_mario_inputs row): WMotR's death plane (SURFACE_DEATH_PLANE at   *)
(* y = -8191, spanning the level) passes at every in-bounds (x, z) above   *)
(* it, so find_floor never misses there.                                    *)
(* ====================================================================== *)

From Coq Require Import ZArith List Lia.
From compcert Require Import Coqlib Errors Maps AST Integers Floats Values Memory Events
  Globalenvs Ctypes Cop Clightdefs Clight ClightBigstep.
From SM64.Generated Require surface_collision.
From SM64.Proofs.WMotRRequiresA Require Import FloorList.
Import ListNotations.

(* Surface.type @ 0 (s16) and Surface.flags @ 4 (s8) *)
Lemma fo_type : forall ge, cenv_has ge -> fo_ok ge surface_collision._Surface surface_collision._type 0.
Proof. intros ge HC. unfold fo_ok. apply (fo_chk_ge _ ge _ _ _ HC). vm_compute. reflexivity. Qed.
Lemma fo_flags : forall ge, cenv_has ge -> fo_ok ge surface_collision._Surface surface_collision._flags 4.
Proof. intros ge HC. unfold fo_ok. apply (fo_chk_ge _ ge _ _ _ HC). vm_compute. reflexivity. Qed.

(* a surface find_floor_from_list ACCEPTS at the int point (X, Y, Z): its
   fields as loaded, and every `continue` test of the loop body false *)
Definition pass (m : mem) (s : val) (X Y Z : int) : Prop :=
  exists bs os ty fl x1 z1 x2 z2 x3 z3 nx ny nz oo,
    s = Vptr bs os
    /\ Mem.loadv Mint16signed m (Vptr bs (Ptrofs.add os (Ptrofs.repr 0))) = Some (Vint ty)
    /\ Mem.loadv Mint8signed m (Vptr bs (Ptrofs.add os (Ptrofs.repr 4))) = Some (Vint fl)
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
    /\ Int.eq ty (Int.repr 114) = false
    /\ Int.eq (Int.and fl (Int.repr 2)) Int.zero = true
    /\ Float32.cmp Ceq ny (Float32.of_bits (Int.repr 0)) = false
    /\ Float32.cmp Clt (Float32.sub (Float32.of_int Y)
                          (Float32.add (plane_h X Z nx ny nz oo) (Float32.neg c78)))
         Float32.zero = false.

Lemma pass_ptr : forall m s X Y Z, pass m s X Y Z -> exists bs os, s = Vptr bs os.
Proof. intros m s X Y Z (bs & os & _ & _ & _ & _ & _ & _ & _ & _ & _ & _ & _ & _ & E & _). eauto. Qed.

(* ---- the `continue` tests, on the TRUE side ---- *)

Lemma ev_edge_t : forall (ge : genv) e le m x z xi zi xj zj vx vz vxi vzi vxj vzj v,
    le ! x = Some vx -> le ! z = Some vz -> le ! xi = Some vxi -> le ! zi = Some vzi ->
    le ! xj = Some vxj -> le ! zj = Some vzj ->
    eval_expr ge e le m (edge_e x z xi zi xj zj) v ->
    bool_val v tint m = Some true ->
    exists X Z XI ZI XJ ZJ, vx = Vint X /\ vz = Vint Z /\ vxi = Vint XI /\ vzi = Vint ZI
      /\ vxj = Vint XJ /\ vzj = Vint ZJ /\ edge_ok X Z XI ZI XJ ZJ = false.
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
  match goal with Hb : bool_val (Val.of_bool ?c) _ _ = Some true |- _ =>
    destruct c eqn:L; [| vm_compute in Hb; discriminate Hb] end.
  change Int.zero with (Int.repr 0). rewrite L. reflexivity.
Qed.

Lemma ev_ny_t : forall (ge : genv) e le m vny v,
    le ! surface_collision._ny = Some vny ->
    eval_expr ge e le m ny_e v -> bool_val v tint m = Some true ->
    exists ny, vny = Vsingle ny /\ Float32.cmp Ceq ny (Float32.of_bits (Int.repr 0)) = true.
Proof.
  intros ge e le m vny v Hny H Hb. unfold ny_e, tf in H. ev_inv. cbn [typeof] in *.
  match goal with Hs : sem_binary_operation _ Oeq _ tfloat _ tfloat _ = Some _ |- _ =>
    destruct (eq_ss _ _ _ _ _ Hs) as (a & b & E1 & E2 & ->) end.
  injection E2 as <-.
  match goal with Hl : le ! _ = Some _ |- _ => rewrite Hny in Hl; injection Hl as <- end.
  exists a. split; [exact E1 |].
  destruct (Float32.cmp Ceq a _) eqn:L; [reflexivity | vm_compute in Hb; discriminate Hb].
Qed.

Lemma chk_eval_t : forall (ge : genv) e le m v hv yv,
    le ! surface_collision._height = Some hv -> le ! surface_collision._y = Some yv ->
    eval_expr ge e le m chk_expr v -> bool_val v tint m = Some true ->
    exists h yi, hv = Vsingle h /\ yv = Vint yi
      /\ Float32.cmp Clt (Float32.sub (Float32.of_int yi) (Float32.add h (Float32.neg c78)))
           Float32.zero = true.
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
  exists h, yi. split; [reflexivity |]. split; [reflexivity |].
  destruct (Float32.cmp Clt _ _); [reflexivity |].
  cbn in Hb. discriminate Hb.
Qed.

(* (t'3 & (1 << 1)): the surface's flags have SURFACE_FLAG_NO_CAM_COLLISION *)
Definition flag_e : expr :=
  Ebinop Oand (Etempvar surface_collision._t'3 tschar)
    (Ebinop Oshl (Econst_int (Int.repr 1) tint) (Econst_int (Int.repr 1) tint) tint) tint.

Lemma ev_flag_t : forall (ge : genv) e le m fv v,
    le ! surface_collision._t'3 = Some fv ->
    eval_expr ge e le m flag_e v -> bool_val v tint m = Some true ->
    exists fl, fv = Vint fl /\ Int.eq (Int.and fl (Int.repr 2)) Int.zero = false.
Proof.
  intros ge e le m fv v Hf H Hb. unfold flag_e in H.
  repeat match goal with
         | H : eval_expr _ _ _ _ _ _ |- _ => inv H
         | H : eval_lvalue _ _ _ _ _ _ _ _ |- _ => inv H
         end.
  rewrite Hf in *. repeat match goal with Hx : Some _ = Some _ |- _ => inv Hx end.
  match goal with Hs : sem_binary_operation _ Oshl _ _ _ _ _ = Some ?w |- _ =>
    assert (Ew : Some w = Some (Vint (Int.repr 2))) by (rewrite <- Hs; reflexivity);
    injection Ew as ->; clear Hs end.
  match goal with Hs : sem_binary_operation _ Oand ?a _ _ _ _ = Some ?w |- _ =>
    destruct a as [| f0 | | | |]; cbn in Hs; try discriminate Hs;
    assert (Ew : Some w = Some (Vint (Int.and f0 (Int.repr 2)))) by (rewrite <- Hs; reflexivity);
    injection Ew as ->; clear Hs end.
  eexists; split; [reflexivity |].
  destruct (Int.eq _ _) eqn:E; [cbn in Hb; rewrite E in Hb; discriminate Hb | reflexivity].
Qed.

(* (t'2 == 114): the surface is SURFACE_CAMERA_BOUNDARY *)
Definition type_e : expr :=
  Ebinop Oeq (Etempvar surface_collision._t'2 tshort) (Econst_int (Int.repr 114) tint) tint.

Lemma ev_type_t : forall (ge : genv) e le m tv0 v,
    le ! surface_collision._t'2 = Some tv0 ->
    eval_expr ge e le m type_e v -> bool_val v tint m = Some true ->
    exists ty, tv0 = Vint ty /\ Int.eq ty (Int.repr 114) = true.
Proof.
  intros ge e le m tv0 v Ht H Hb. unfold type_e in H.
  repeat match goal with
         | H : eval_expr _ _ _ _ _ _ |- _ => inv H
         | H : eval_lvalue _ _ _ _ _ _ _ _ |- _ => inv H
         end.
  rewrite Ht in *. repeat match goal with Hx : Some _ = Some _ |- _ => inv Hx end.
  match goal with Hs : sem_binary_operation _ Oeq ?a _ _ _ _ = Some ?w |- _ =>
    destruct a as [| t0 | | | |]; cbn in Hs; try discriminate Hs;
    assert (Ew : Some w = Some (Val.of_bool (Int.eq t0 (Int.repr 114)))) by (rewrite <- Hs; reflexivity);
    injection Ew as ->; clear Hs end.
  eexists; split; [reflexivity |].
  destruct (Int.eq _ _); [reflexivity | cbn in Hb; discriminate Hb].
Qed.

(* a pointer compared != NULL is true or undefined, never false *)
Lemma cmp_ne_null : forall m b o v,
    cmp_ptr m Cne (Vptr b o) (Vint (Int.repr 0)) = Some v -> v = Vtrue.
Proof.
  intros m b o v H. unfold cmp_ptr in H.
  change Archi.ptr64 with false in H. cbv beta iota in H.
  unfold Val.cmpu_bool in H. change Archi.ptr64 with false in H. cbv beta iota in H.
  change (Int.eq (Int.repr 0) Int.zero) with true in H. cbv beta iota in H.
  match type of H with
  | option_map _ (if ?c then _ else _) = _ => destruct c
  | option_map _ (if ?c then _ else _) = _ => destruct c
  end.
  - cbv in H. injection H as <-. reflexivity.
  - cbv in H. discriminate H.
Qed.

(* the loop guard (surfaceNode != NULL) is true at a pointer *)
Lemma guard_ptr : forall (ge : genv) e le m v b o,
    le ! surface_collision._surfaceNode = Some (Vptr b o) ->
    eval_expr ge e le m
      (Ebinop One (Etempvar surface_collision._surfaceNode (tptr sn_ty))
         (Ecast (Econst_int (Int.repr 0) tint) (tptr tvoid)) tint) v ->
    bool_val v tint m = Some false -> False.
Proof.
  intros ge e le m v b o Hn H Hb.
  repeat match goal with
         | H : eval_expr _ _ _ _ _ _ |- _ => inv H
         | H : eval_lvalue _ _ _ _ _ _ _ _ |- _ => inv H
         end.
  rewrite Hn in *. repeat match goal with Hx : Some _ = Some _ |- _ => inv Hx end.
  match goal with Hc : sem_cast (Vint _) _ _ _ = Some _ |- _ =>
    vm_compute in Hc; injection Hc as <- end.
  match goal with Hs : sem_binary_operation _ One _ _ _ _ _ = Some _ |- _ =>
    cbn in Hs; apply cmp_ne_null in Hs; subst end.
  cbn in Hb. discriminate Hb.
Qed.

(* ---- one round of the loop ---- *)

Ltac hit_ft HC :=
  repeat match goal with
  | Hv : eval_expr _ _ ?L ?M (Efield _ surface_collision._flags tschar) ?v |- _ =>
      lazymatch L with context [PTree.set surface_collision._surf ?sv _] =>
        let Hs := fresh in
        assert (Hs : L ! surface_collision._surf = Some sv) by (ptg; reflexivity);
        let R := fresh in
        pose proof (ev_field _ _ L M surf_e surface_collision._Surface surface_collision._flags
                      tschar v 4 Mint8signed eq_refl (fo_flags _ HC) eq_refl Hv) as R;
        clear Hv;
        let l := fresh in let o := fresh in let He := fresh in let Ld := fresh "Ld" in
        destruct R as (l & o & He & Ld);
        let El := fresh in let Ev := fresh in
        destruct (ev_surf _ _ _ _ _ _ Hs He) as (? & ? & El & Ev); clear He Hs;
        injection Ev as <- <-; first [subst sv | injection El as <- <-]
      end
  | Hv : eval_expr _ _ ?L ?M (Efield _ surface_collision._type tshort) ?v |- _ =>
      lazymatch L with context [PTree.set surface_collision._surf ?sv _] =>
        let Hs := fresh in
        assert (Hs : L ! surface_collision._surf = Some sv) by (ptg; reflexivity);
        let R := fresh in
        pose proof (ev_field _ _ L M surf_e surface_collision._Surface surface_collision._type
                      tshort v 0 Mint16signed eq_refl (fo_type _ HC) eq_refl Hv) as R;
        clear Hv;
        let l := fresh in let o := fresh in let He := fresh in let Ld := fresh "Ld" in
        destruct R as (l & o & He & Ld);
        let El := fresh in let Ev := fresh in
        destruct (ev_surf _ _ _ _ _ _ Hs He) as (? & ? & El & Ev); clear He Hs;
        injection Ev as <- <-; first [subst sv | injection El as <- <-]
      end
  end.

Ltac unify_loads :=
  repeat match goal with
  | H1 : Mem.loadv ?c ?mm ?a = Some ?x, H2 : Mem.loadv ?c ?mm ?a = Some ?y |- _ =>
      rewrite H1 in H2; injection H2 as H2; subst y
  | H1 : Mem.loadv ?c ?mm ?a = Some ?x, H2 : Mem.loadv ?c ?mm ?a = Some ?y |- _ =>
      rewrite H1 in H2; injection H2 as H2; subst x
  end.

(* a `continue` test came out true at a surface that passes: impossible *)
Ltac cond_contra :=
  first
  [ match goal with
    | Hv : eval_expr _ _ ?L _ (Ebinop Olt (Ebinop Osub
              (Ebinop Omul (Ebinop Osub (Etempvar ?zi _) (Etempvar ?z _) _)
                           (Ebinop Osub (Etempvar ?xj _) (Etempvar ?xi _) _) _)
              (Ebinop Omul (Ebinop Osub (Etempvar _ _) (Etempvar ?x _) _)
                           (Ebinop Osub (Etempvar ?zj _) (Etempvar _ _) _) _) _) _ _) ?v,
      Hb : bool_val ?v _ _ = Some true |- _ =>
        eapply (ev_edge_t _ _ L _ x z xi zi xj zj) in Hv;
        [| lkup | lkup | lkup | lkup | lkup | lkup | exact Hb];
        destruct Hv as (? & ? & ? & ? & ? & ? & ? & ? & ? & ? & ? & ? & ?);
        repeat match goal with Hi : Vint _ = Vint _ |- _ => injection Hi as Hi; subst end;
        congruence
    end
  | match goal with
    | Hv : eval_expr _ _ ?L _ (Ebinop Oand (Etempvar surface_collision._t'3 _) _ _) ?v,
      Hb : bool_val ?v _ _ = Some true |- _ =>
        eapply (ev_flag_t _ _ L _ _ _) in Hv; [| lkup | exact Hb];
        destruct Hv as (? & ? & ?);
        repeat match goal with Hi : Vint _ = Vint _ |- _ => injection Hi as Hi; subst end;
        congruence
    end
  | match goal with
    | Hv : eval_expr _ _ ?L _ (Ebinop Oeq (Etempvar surface_collision._t'2 _) _ _) ?v,
      Hb : bool_val ?v _ _ = Some true |- _ =>
        eapply (ev_type_t _ _ L _ _ _) in Hv; [| lkup | exact Hb];
        destruct Hv as (? & ? & ?);
        repeat match goal with Hi : Vint _ = Vint _ |- _ => injection Hi as Hi; subst end;
        congruence
    end
  | match goal with
    | Hv : eval_expr _ _ ?L _ (Ebinop Oeq (Etempvar surface_collision._ny _) _ _) ?v,
      Hb : bool_val ?v _ _ = Some true |- _ =>
        eapply (ev_ny_t _ _ L _ _ _) in Hv; [| lkup | exact Hb];
        destruct Hv as (? & ? & ?);
        repeat match goal with Hi : Vsingle _ = Vsingle _ |- _ => injection Hi as Hi; subst end;
        congruence
    end
  | match goal with
    | Hc : eval_expr _ _ ?L _ (Ebinop Olt (Ebinop Osub (Etempvar surface_collision._y tint) _ tfloat) _ tint) ?v,
      Hb : bool_val ?v _ _ = Some true |- _ =>
        lazymatch L with context [PTree.set surface_collision._height ?hv _] =>
          let Hhh := fresh "Hhh" in
          assert (Hhh : L ! surface_collision._height = Some hv) by (ptg; reflexivity);
          eapply (chk_eval_t _ _ _ _ _ hv _ Hhh) in Hc; [| ptg; eassumption | exact Hb];
          let h0 := fresh "h0" in let yi := fresh "yi" in let Ey := fresh "Ey" in let Hk := fresh "Hk" in
          destruct Hc as (h0 & yi & -> & Ey & Hk);
          injection Ey as Ey; subst yi;
          hit_h;
          repeat match goal with
                 | Hi : Vint _ = Vint _ |- _ => injection Hi as Hi; subst
                 | Hi : Vsingle _ = Vsingle _ |- _ => injection Hi as Hi; subst
                 end;
          congruence
        end
    end ].

Lemma ffl_iter_here : forall ge e m le t le1 m1 out1 node0 ph X Y Z bn on bs os,
    cenv_has ge ->
    exec_stmt function_entry2 ge e le m ffl_s1 t le1 m1 out1 ->
    Inv m node0 ph (Vint X) (Vint Y) (Vint Z) le ->
    le ! surface_collision._surfaceNode = Some (Vptr bn on) ->
    Mem.loadv Mint32 m (Vptr bn (Ptrofs.add on (Ptrofs.repr SN_SURF))) = Some (Vptr bs os) ->
    pass m (Vptr bs os) X Y Z ->
    out1 = Out_break /\ exists s', le1 ! surface_collision._floor = Some s' /\ s' <> Vint Int.zero.
Proof.
  intros ge e m le t le1 m1 out1 node0 ph X Y Z bn on bs os HC H
    (nd & Hnd & Hreach & Hfl & Hph & Hy & Hxx & Hzz) Hcur Hs0 P.
  rewrite Hcur in Hnd. injection Hnd as <-.
  destruct P as (bs' & os' & ty & fl & x1 & z1 & x2 & z2 & x3 & z3 & nx & ny & nz & oo & Es &
                 Lty & Lfl & L1 & L2 & L3 & L4 & L5 & L6 & L7 & L8 & L9 & L10 &
                 E1 & E2 & E3 & Nty & Nfl & Nny & Nh).
  injection Es as <- <-.
  cbv [ffl_s1 ffl_loop surface_collision.f_find_floor_from_list fn_body Swhile] in H.
  xinv.
  (* the guard said stop: not at a pointer *)
  all: try (exfalso;
            match goal with
            | Hg : eval_expr _ _ _ _ (Ebinop One (Etempvar surface_collision._surfaceNode _) _ _) ?v,
              Hb : bool_val ?v _ _ = Some false |- _ => exact (guard_ptr _ _ _ _ _ _ _ Hcur Hg Hb)
            end).
  (* the surface load *)
  all: match goal with
       Hs : eval_expr _ _ ?L _ (Efield (Ederef (Etempvar surface_collision._surfaceNode _) _)
                                 surface_collision._surface _) _ |- _ =>
         assert (Hle1 : L ! surface_collision._surfaceNode = Some (Vptr bn on)) by (ptg; exact Hcur);
         let Eb := fresh in let Ls := fresh in
         destruct (sn_surf _ _ _ _ _ _ HC Hle1 Hs) as (? & ? & Eb & Ls);
         injection Eb as <- <-; rewrite Hs0 in Ls; injection Ls as Ls; subst; clear Hle1
       end.
  all: hit_v HC.
  all: hit_ft HC.
  all: ofs_fix.
  all: unify_loads.
  (* a continue: the surface passes, so no test fails *)
  all: try (exfalso; cond_contra).
  (* the floor: floor := surf, a pointer *)
  all: split; [reflexivity |].
  all: repeat match goal with Ht : eval_expr _ _ _ _ (Etempvar surface_collision._surf _) _ |- _ =>
         inv Ht; [| match goal with Hl : eval_lvalue _ _ _ _ (Etempvar _ _) _ _ _ |- _ => inv Hl end]
       end.
  all: repeat match goal with Hx : (PTree.set _ _ _) ! _ = Some _ |- _ =>
         progress (repeat first [ rewrite PTree.gss in Hx
                                | rewrite PTree.gso in Hx by (let HH := fresh in intro HH; cbv in HH; discriminate HH) ])
       end.
  all: repeat match goal with Hx : Some _ = Some _ |- _ => inv Hx end.
  all: eexists; split; [ptg; reflexivity | discriminate].
Qed.

Lemma ffl_iter_next : forall ge e m le t le1 m1 out1 node0 ph xv yv zv bn on nx,
    cenv_has ge ->
    exec_stmt function_entry2 ge e le m ffl_s1 t le1 m1 out1 ->
    Inv m node0 ph xv yv zv le ->
    le ! surface_collision._surfaceNode = Some (Vptr bn on) ->
    Mem.loadv Mint32 m (Vptr bn (Ptrofs.add on (Ptrofs.repr SN_NEXT))) = Some nx ->
    (out1 = Out_break /\ exists s', le1 ! surface_collision._floor = Some s' /\ s' <> Vint Int.zero)
    \/ (out1 = Out_continue /\ m1 = m /\ le1 ! surface_collision._surfaceNode = Some nx
        /\ Inv m node0 ph xv yv zv le1).
Proof.
  intros ge e m le t le1 m1 out1 node0 ph xv yv zv bn on nx HC H
    (nd & Hnd & Hreach & Hfl & Hph & Hy & Hxx & Hzz) Hcur Hn0.
  rewrite Hcur in Hnd. injection Hnd as <-.
  cbv [ffl_s1 ffl_loop surface_collision.f_find_floor_from_list fn_body Swhile] in H.
  xinv.
  all: try (exfalso;
            match goal with
            | Hg : eval_expr _ _ _ _ (Ebinop One (Etempvar surface_collision._surfaceNode _) _ _) ?v,
              Hb : bool_val ?v _ _ = Some false |- _ => exact (guard_ptr _ _ _ _ _ _ _ Hcur Hg Hb)
            end).
  all: match goal with
       Hn : eval_expr _ _ ?L _ (Efield (Ederef (Etempvar surface_collision._surfaceNode _) _)
                                 surface_collision._next _) _ |- _ =>
         assert (Hle2 : L ! surface_collision._surfaceNode = Some (Vptr bn on)) by (ptg; exact Hcur);
         let Eb := fresh in let Ln := fresh in
         destruct (sn_next _ _ _ _ _ _ HC Hle2 Hn) as (? & ? & Eb & Ln);
         injection Eb as <- <-; rewrite Hn0 in Ln; injection Ln as Ln; subst; clear Hle2
       end.
  (* a continue: the cursor moved to next, still reachable *)
  all: try (right; split; [reflexivity | split; [reflexivity |]];
            split; [ptg; reflexivity |];
            eexists; split; [ptg; reflexivity |];
            split; [intros s0 Hs0; apply Hreach; eapply ol_next; [exact Hn0 | exact Hs0] |];
            repeat (split; [ptg; assumption |]); ptg; assumption).
  (* the floor: floor := surf, a pointer (its vertices were read) *)
  all: left; split; [reflexivity |].
  all: hit_v HC.
  all: repeat match goal with Ht : eval_expr _ _ _ _ (Etempvar surface_collision._surf _) _ |- _ =>
         inv Ht; [| match goal with Hl : eval_lvalue _ _ _ _ (Etempvar _ _) _ _ _ |- _ => inv Hl end]
       end.
  all: repeat match goal with Hx : (PTree.set _ _ _) ! _ = Some _ |- _ =>
         progress (repeat first [ rewrite PTree.gss in Hx
                                | rewrite PTree.gso in Hx by (let HH := fresh in intro HH; cbv in HH; discriminate HH) ])
       end.
  all: repeat match goal with Hx : Some _ = Some _ |- _ => inv Hx end.
  all: eexists; split; [ptg; reflexivity | discriminate].
Qed.

(* ---- the loop and the call ---- *)

Lemma ffl_loop_c : forall ge e m le t le' m' out node0 ph X Y Z,
    cenv_has ge ->
    exec_stmt function_entry2 ge e le m ffl_loop t le' m' out ->
    forall nd s, Inv m node0 ph (Vint X) (Vint Y) (Vint Z) le ->
    le ! surface_collision._surfaceNode = Some nd ->
    on_list m nd s -> pass m s X Y Z ->
    exists s', le' ! surface_collision._floor = Some s' /\ s' <> Vint Int.zero.
Proof.
  intros ge e m le t le' m' out node0 ph X Y Z HC H.
  rewrite ffl_loop_shape in H.
  remember (Sloop ffl_s1 Sskip) as S eqn:ES. revert ES.
  induction H; intros ES nd s HI Hnd OL P; try discriminate ES.
  - (* the body broke out (or returned) *)
    injection ES as -> ->.
    destruct (pass_ptr _ _ _ _ _ P) as (bs & os & ->).
    inv OL.
    + match goal with Hx : exec_stmt _ _ _ _ _ ffl_s1 _ _ _ _, Hl : Mem.loadv _ _ _ = Some (Vptr _ _) |- _ =>
        destruct (ffl_iter_here _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ HC Hx HI Hnd Hl P) as (_ & R) end.
      exact R.
    + match goal with Hx : exec_stmt _ _ _ _ _ ffl_s1 _ _ _ _, Hl : Mem.loadv _ _ _ = Some _,
                      Hb : out_break_or_return _ _ |- _ =>
        destruct (ffl_iter_next _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ HC Hx HI Hnd Hl)
          as [(_ & R) | (-> & _)]; [exact R | inv Hb] end.
  - (* the body continued, then Sskip went abrupt: impossible *)
    injection ES as -> ->.
    match goal with Hs : exec_stmt _ _ _ _ _ Sskip _ _ _ _,
                    Hb : out_break_or_return _ _ |- _ => inv Hs; inv Hb end.
  - (* one more round *)
    injection ES as -> ->.
    destruct (pass_ptr _ _ _ _ _ P) as (bs & os & ->).
    inv OL.
    + exfalso.
      match goal with Hx : exec_stmt _ _ _ _ _ ffl_s1 _ _ _ _, Hl : Mem.loadv _ _ _ = Some (Vptr _ _),
                      Hn : out_normal_or_continue _ |- _ =>
        destruct (ffl_iter_here _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ HC Hx HI Hnd Hl P) as (-> & _); inv Hn end.
    + match goal with Hx : exec_stmt _ _ _ _ _ ffl_s1 _ _ _ _, Hl : Mem.loadv _ _ _ = Some _,
                      Hn : out_normal_or_continue _ |- _ =>
        destruct (ffl_iter_next _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ HC Hx HI Hnd Hl)
          as [(-> & _) | (-> & -> & Hnx & HI')]; [inv Hn |] end.
      match goal with Hs : exec_stmt _ _ _ _ _ Sskip _ _ _ _ |- _ => inv Hs end.
      match goal with IH : Sloop _ _ = Sloop _ _ -> _ |- _ =>
        eapply IH; [reflexivity | exact HI' | exact Hnx | eassumption | exact P] end.
Qed.

(* THE COMPLETENESS of find_floor_from_list: a surface that passes at
   (X, Y, Z) on the list makes the call return a non-NULL floor *)
Theorem ffl_complete : forall (ge : genv),
    cenv_has ge ->
    forall m node X Y Z ph t m' vres s,
      eval_funcall function_entry2 ge m
        (Internal surface_collision.f_find_floor_from_list) [node; Vint X; Vint Y; Vint Z; ph] t m' vres ->
      on_list m node s -> pass m s X Y Z ->
      vres <> Vint Int.zero.
Proof.
  intros ge HC m node X Y Z ph t m' vres s H OL P.
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
    assert (HI : Inv mm node ph (Vint X) (Vint Y) (Vint Z) L)
      by (exists node; split; [ptg; reflexivity |]; split; [auto |];
          repeat (split; [ptg; reflexivity |]); ptg; reflexivity);
    assert (Hn : L ! surface_collision._surfaceNode = Some node) by (ptg; reflexivity)
  end.
  match goal with Hx : exec_stmt _ _ _ _ _ (Ssequence _ _) _ _ _ _ |- _ => inv Hx end.
  - match goal with Hl : exec_stmt _ _ _ _ _ ffl_loop _ _ _ _ |- _ =>
      destruct (ffl_loop_c _ _ _ _ _ _ _ _ _ _ _ _ _ HC Hl _ _ HI Hn OL P) as (s' & Hf & Nz) end.
    match goal with Hs : exec_stmt _ _ _ _ _ (Sreturn _) _ _ _ _ |- _ => inv Hs end.
    match goal with Ht : eval_expr _ _ _ _ (Etempvar _ _) _ |- _ =>
      inv Ht; [| match goal with Hl : eval_lvalue _ _ _ _ (Etempvar _ _) _ _ _ |- _ => inv Hl end] end.
    match goal with Ho : outcome_result_value _ _ _ _ |- _ => destruct Ho as (_ & Hc) end.
    apply cast_surf_ptr in Hc. subst vres. congruence.
  - match goal with Hl : exec_stmt _ _ _ _ _ ffl_loop _ _ _ _ |- _ =>
      destruct (ffl_loop_spec _ _ _ _ _ _ _ _ _ _ _ _ _ HC Hl HI) as (-> & _) end.
    congruence.
Qed.
