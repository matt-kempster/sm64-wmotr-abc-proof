(* ===================================================================== *)
(* MplatRun (GOAL 2): the real update_mario_platform, inverted            *)
(* (2026-11-03).                                                          *)
(*                                                                       *)
(* platform_displacement.c:31-56 (generated/platform_displacement.v,      *)
(* f_update_mario_platform): with two locals (floor, filler) it returns   *)
(* at once when gMarioObject is NULL; otherwise it reads Mario's position,*)
(* calls find_floor(x, y, z, &floor) and absf, and stores ONE value X     *)
(* into gMarioPlatform and gMarioObject->platform (offset 532): NULL, or  *)
(* floor->object (offset 44 of the Surface find_floor reported).         *)
(* mplat_run states exactly that memory trace; MplatKeep reads the       *)
(* invariants off it.                                                     *)
(* ===================================================================== *)
From Coq Require Import ZArith Lia List.
From compcert Require Import Coqlib Integers Floats Values AST Ctypes Cop Clight
  ClightBigstep Clightdefs Memory Maps Globalenvs Events Errors.
From SM64.Generated Require platform_displacement surface_collision object_helpers.
From SM64.Proofs.WMotRRequiresA Require Import RenderAnim PlatformWalk.
Import ListNotations.
Local Open Scope Z_scope.

Module PD := platform_displacement.
Module SC := surface_collision.
Module OH := object_helpers.

(* absf has no locals and no store: memory unchanged *)
Lemma absf_mem : forall (ge : genv) m vargs t m' vres,
  eval_funcall function_entry2 ge m (Internal OH.f_absf) vargs t m' vres -> m' = m.
Proof.
  intros ge m vargs t m' vres H. inv H.
  match goal with He : function_entry2 _ _ _ _ _ _ _ |- _ => inv He end.
  match goal with Ha : alloc_variables _ _ _ _ _ _ |- _ => cbn [OH.f_absf fn_vars] in Ha; inv Ha end.
  match goal with Hf : Mem.free_list _ _ = Some _ |- _ => cbn in Hf; injection Hf as <- end.
  match goal with Hx : exec_stmt _ _ _ _ _ _ _ _ _ _ |- _ => cbn [OH.f_absf fn_body] in Hx;
    apply if_inv in Hx; destruct Hx as (? & [|] & _ & _ & Hx); inv Hx end; reflexivity.
Qed.

Section RUN.
Variable ge : genv.
Hypothesis Hcenv : forall id co, (prog_comp_env PD.prog) ! id = Some co -> (genv_cenv ge) ! id = Some co.
Variables bgp bgmo : block.
Hypothesis Hgp : Genv.find_symbol ge PD._gMarioPlatform = Some bgp.
Hypothesis Hgmo : Genv.find_symbol ge PD._gMarioObject = Some bgmo.
Hypothesis Hffr : forall b fd, Genv.find_symbol ge PD._find_floor = Some b ->
  Genv.find_funct ge (Vptr b Ptrofs.zero) = Some fd -> fd = Internal SC.f_find_floor.
Hypothesis Habr : forall b fd, Genv.find_symbol ge PD._absf = Some b ->
  Genv.find_funct ge (Vptr b Ptrofs.zero) = Some fd -> fd = Internal OH.f_absf.

Lemma fo_plat : forall co, (genv_cenv ge) ! PD._Object = Some co ->
  field_offset ge PD._platform (co_members co) = OK (532, Full).
Proof. apply (fo_ok_lift (prog_comp_env PD.prog)); [ vm_compute; reflexivity | exact Hcenv ]. Qed.
Lemma fo_sobj : forall co, (genv_cenv ge) ! PD._Surface = Some co ->
  field_offset ge PD._object (co_members co) = OK (44, Full).
Proof. apply (fo_ok_lift (prog_comp_env PD.prog)); [ vm_compute; reflexivity | exact Hcenv ]. Qed.

Lemma ret_none_inv : forall e le m t le' m' out,
  exec_stmt function_entry2 ge e le m (Sreturn None) t le' m' out ->
  m' = m /\ le' = le /\ out = Out_return None.
Proof. intros. inv H. auto. Qed.

Lemma break_inv : forall e le m t le' m' out,
  exec_stmt function_entry2 ge e le m Sbreak t le' m' out ->
  m' = m /\ le' = le /\ out = Out_break.
Proof. intros. inv H. auto. Qed.

Lemma switch_inv : forall e le m a sl t le' m' out,
  exec_stmt function_entry2 ge e le m (Sswitch a sl) t le' m' out ->
  exists v n out1, eval_expr ge e le m a v /\ sem_switch_arg v (typeof a) = Some n /\
    exec_stmt function_entry2 ge e le m (seq_of_labeled_statement (select_switch n sl)) t le' m' out1 /\
    out = outcome_switch out1.
Proof. intros. inv H. eauto 10. Qed.

Lemma boe_mp : forall bX bF,
  map (block_of_binding ge) (PTree.elements
    (PTree.set PD._filler (bX, tarray tuchar 4)
       (PTree.set PD._floor (bF, tptr (Tstruct PD._Surface noattr)) empty_env)))
  = [(bX, 0, 4); (bF, 0, 4)].
Proof. intros. reflexivity. Qed.

Ltac mw :=
  match goal with
  | H : exec_stmt _ _ _ _ _ (Ssequence _ _) _ _ _ _ |- _ =>
      apply seq_inv in H; destruct H as [(? & ? & ? & ? & ? & ?) | (? & ?)]
  | H : exec_stmt _ _ _ _ _ (Sset _ _) _ _ _ _ |- _ =>
      apply set_inv in H; destruct H as (? & ? & ? & ? & ?); subst
  | H : exec_stmt _ _ _ _ _ Sskip _ _ _ _ |- _ =>
      apply skip_inv in H; destruct H as (? & ? & ?); subst
  | H : exec_stmt _ _ _ _ _ (Sreturn None) _ _ _ _ |- _ =>
      apply ret_none_inv in H; destruct H as (? & ? & ?); subst
  | H : exec_stmt _ _ _ _ _ Sbreak _ _ _ _ |- _ =>
      apply break_inv in H; destruct H as (? & ? & ?); subst
  | H : exec_stmt _ _ _ _ _ (Sassign _ _) _ _ _ _ |- _ =>
      apply assign_inv in H; destruct H as (? & ? & ? & ? & ? & ? & ? & ? & ? & ? & ?); subst
  | H : exec_stmt _ _ _ _ _ (Sifthenelse _ _ _) _ _ _ _ |- _ =>
      apply if_inv in H; destruct H as (? & [|] & ? & ? & H); cbv beta iota in H
  | H : exec_stmt _ _ _ _ _ (Scall _ _ _) _ _ _ _ |- _ =>
      apply call_inv in H;
      destruct H as (? & ? & ? & ? & ? & ? & ? & ? & ? & ? & ? & ? & ? & ? & ?); subst
  end; try congruence.

Lemma ss0 : forall s1 s0, select_switch 0 (LScons (Some 1) s1 (LScons (Some 0) s0 LSnil)) = LScons (Some 0) s0 LSnil.
Proof. reflexivity. Qed.
Lemma ss1 : forall s1 s0, select_switch 1 (LScons (Some 1) s1 (LScons (Some 0) s0 LSnil)) = LScons (Some 1) s1 (LScons (Some 0) s0 LSnil).
Proof. reflexivity. Qed.

Ltac envget := repeat first [ rewrite PTree.gss | rewrite PTree.gso by neq ];
  first [ reflexivity | apply PTree.gempty ].

Ltac pn :=
  match goal with
  | H : exec_stmt _ _ _ _ _ (Sswitch _ _) _ _ _ _ |- _ =>
      apply switch_inv in H; destruct H as (? & ? & ? & ? & ? & H & ?); subst
  | H : eval_expr _ _ _ _ (Etempvar _ _) _ |- _ => apply ev_temp in H
  | H : eval_expr _ _ _ _ (Econst_int _ _) _ |- _ => apply ev_const in H; subst
  | H : eval_expr _ _ _ _ (Ecast _ _) _ |- _ =>
      apply ev_cast in H; destruct H as (? & ? & H); cbn [typeof] in H
  | H : eval_expr _ _ _ _ (Ebinop _ _ _ _) _ |- _ =>
      apply ev_binop in H; destruct H as (? & ? & ? & ? & H); cbn [typeof] in H
  | H : eval_expr _ _ _ _ (Eaddrof (Evar _ _) _) _ |- _ =>
      eapply ev_addr_local in H; [ subst | envget ]
  | H : eval_expr _ _ _ _ (Evar PD._floor _) _ |- _ =>
      eapply ev_local in H; [ | envget | reflexivity ]
  | H : eval_expr _ _ _ _ (Evar PD._gMarioObject _) _ |- _ =>
      eapply ev_gvar in H; [ destruct H as (? & ? & H); cbn [Mem.loadv] in H | envget | reflexivity ]
  | H : eval_expr _ _ _ _ (Evar _ (Tfunction _ _ _)) _ |- _ =>
      eapply ev_fun in H; [ destruct H as (? & ? & ?); subst | envget | reflexivity ]
  | H : eval_expr _ _ _ _ (Efield (Ederef (Etempvar _ _) _) PD._object _) _ |- _ =>
      eapply (ev_fld ge) in H; [ destruct H as (? & ? & ? & H); cbn [Mem.loadv] in H | exact fo_sobj | reflexivity ]
  | H : eval_lvalue _ _ _ _ (Efield (Ederef (Etempvar _ _) _) PD._platform _) _ _ _ |- _ =>
      eapply (lv_fld ge) in H; [ destruct H as (? & ? & ? & ?); subst | exact fo_plat ]
  | H : eval_lvalue _ _ _ _ (Evar PD._gMarioPlatform _) _ _ _ |- _ =>
      apply lv_gvar in H; [ destruct H as (H & ? & ?); subst | envget ]
  | H : (PTree.set _ _ _) ! _ = Some _ |- _ => progress getnorm H
  | H : Some _ = Some _ |- _ => injection H; clear H; intros; subst
  | H : Vptr _ _ = Vptr _ _ |- _ => injection H; clear H; intros; subst
  | H : eval_exprlist _ _ _ _ (_ :: _) _ _ |- _ => inv H
  | H : eval_exprlist _ _ _ _ nil _ _ |- _ => inv H
  | H : classify_fun _ = _ |- _ => cbn [typeof classify_fun] in H; injection H; clear H; intros; subst
  | H : assign_loc _ (typeof _) _ _ _ _ _ _ |- _ => progress cbn [typeof] in H
  | H : assign_loc _ ?ty _ _ _ Full _ _ |- _ => eapply (store_by_value _ ty) in H; [ | reflexivity | reflexivity ]
  | H : sem_cast _ (typeof _) _ _ = Some _ |- _ => progress cbn [typeof] in H
  | H : sem_cast _ _ (typeof _) _ = Some _ |- _ => progress cbn [typeof] in H
  | H : sem_cast (Vint _) _ _ _ = Some _ |- _ => vm_compute in H; injection H; clear H; intros; subst
  | H : sem_cast _ (tptr _) (tptr _) _ = Some _ |- _ => apply cast_ptr_id in H; subst
  | H : sem_cast _ tfloat tfloat _ = Some _ |- _ =>
      let E := fresh in pose proof (cast_ff_single _ _ _ H) as (? & E); clear H; subst
  | H : bool_val (Vint _) _ _ = Some _ |- _ => vm_compute in H; first [ discriminate H | clear H ]
  | H : sem_switch_arg (Vint _) _ = Some _ |- _ => vm_compute in H; injection H; clear H; intros; subst
  | H : exec_stmt _ _ _ _ _ (seq_of_labeled_statement (select_switch 0 _)) _ _ _ _ |- _ =>
      rewrite ss0 in H; cbn [seq_of_labeled_statement] in H
  | H : exec_stmt _ _ _ _ _ (seq_of_labeled_statement (select_switch 1 _)) _ _ _ _ |- _ =>
      rewrite ss1 in H; cbn [seq_of_labeled_statement] in H
  | H : context [ set_opttemp (Some _) _ _ ] |- _ => progress cbn [set_opttemp] in H
  end.

Theorem mplat_run : forall m t m' vres,
  eval_funcall function_entry2 ge m (Internal PD.f_update_mario_platform) [] t m' vres ->
  exists bF bX mA m1 m3,
    Mem.alloc m 0 4 = (mA, bF) /\ Mem.alloc mA 0 4 = (m1, bX)
    /\ Mem.free_list m3 [(bX, 0, 4); (bF, 0, 4)] = Some m'
    /\ (m3 = m1
        \/ exists fx fy fz t1 m2 vff X1 m2a pb2 po2 X2,
             eval_funcall function_entry2 ge m1 (Internal SC.f_find_floor)
               [Vsingle fx; Vsingle fy; Vsingle fz; Vptr bF Ptrofs.zero] t1 m2 vff
          /\ Mem.store Mint32 m2 bgp 0 X1 = Some m2a
          /\ Mem.load Mint32 m2a bgmo 0 = Some (Vptr pb2 po2)
          /\ Mem.store Mint32 m2a pb2 (Ptrofs.unsigned (Ptrofs.add po2 (Ptrofs.repr 532))) X2 = Some m3
          /\ ((X1 = Vint Int.zero /\ X2 = Vint Int.zero)
              \/ exists sb so sb2 so2,
                   Mem.load Mint32 m2 bF 0 = Some (Vptr sb so)
                /\ Mem.load Mint32 m2 sb (Ptrofs.unsigned (Ptrofs.add so (Ptrofs.repr 44))) = Some X1
                /\ Mem.load Mint32 m2a bF 0 = Some (Vptr sb2 so2)
                /\ Mem.load Mint32 m2a sb2 (Ptrofs.unsigned (Ptrofs.add so2 (Ptrofs.repr 44))) = Some X2)).
Proof.

  intros m t m' vres H. inv H.
  match goal with He : function_entry2 _ _ _ _ _ _ _ |- _ => inv He end.
  match goal with Ha : alloc_variables _ _ _ _ _ _ |- _ =>
    cbn [PD.f_update_mario_platform fn_vars] in Ha end.
  repeat match goal with Ha : alloc_variables _ _ _ (_ :: _) _ _ |- _ => inv Ha end.
  match goal with Ha : alloc_variables _ _ _ [] _ _ |- _ => inv Ha end.
  match goal with Hb : bind_parameter_temps _ _ _ = Some _ |- _ =>
    cbn [bind_parameter_temps PD.f_update_mario_platform fn_params] in Hb; injection Hb as <- end.
  match goal with Hf : Mem.free_list _ _ = Some _ |- _ => unfold blocks_of_env in Hf; rewrite boe_mp in Hf end.
  change (sizeof ge (tptr (Tstruct PD._Surface noattr))) with 4 in *.
  change (sizeof ge (tarray tuchar 4)) with 4 in *.
  match goal with Hx : exec_stmt _ _ _ _ _ _ _ _ _ _ |- _ => cbn [PD.f_update_mario_platform fn_body] in Hx end.
  repeat (first [ mw | pn ]).
  all: repeat match goal with
    | Hs : Genv.find_symbol _ PD._find_floor = Some ?b, Hf : Genv.find_funct _ (Vptr ?b _) = Some ?fd |- _ =>
        pose proof (Hffr _ _ Hs Hf); subst fd; clear Hf
    | Hs : Genv.find_symbol _ PD._absf = Some ?b, Hf : Genv.find_funct _ (Vptr ?b _) = Some ?fd |- _ =>
        pose proof (Habr _ _ Hs Hf); subst fd; clear Hf
    | He : eval_funcall _ _ _ (Internal OH.f_absf) _ _ _ _ |- _ => apply absf_mem in He; subst
    | Hs : Genv.find_symbol _ PD._gMarioPlatform = Some ?x |- _ =>
        tryif constr_eq x bgp then fail else (rewrite Hgp in Hs; injection Hs as Hs; subst x)
    | Hs : Genv.find_symbol _ PD._gMarioObject = Some ?x |- _ =>
        tryif constr_eq x bgmo then fail else (rewrite Hgmo in Hs; injection Hs as Hs; subst x)
    end.
  all: unfold Mptr in *; cbn [Archi.ptr64] in *; rewrite ?Ptrofs.unsigned_zero in *.
  (* the same cell read twice gives the same value *)
  all: repeat match goal with
    | H1 : Mem.load ?c ?mm ?b ?o = Some ?v1, H2 : Mem.load ?c ?mm ?b ?o = Some ?v2 |- _ =>
        tryif constr_eq v1 v2 then fail
        else (rewrite H1 in H2; injection H2; clear H2; intros; subst)
    end.
  all: do 5 eexists; split; [ eassumption | split; [ eassumption | split; [ eassumption | ] ] ].
  all: first
    [ left; reflexivity
    | right; do 11 eexists;
      split; [ eassumption | split; [ eassumption | split; [ eassumption | split; [ eassumption | ] ] ] ];
      first [ left; split; reflexivity
            | right; do 4 eexists; split; [ eassumption | split; [ eassumption | split; [ eassumption | eassumption ] ] ] ] ].
Qed.

End RUN.
