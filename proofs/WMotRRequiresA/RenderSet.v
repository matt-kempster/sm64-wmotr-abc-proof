(* ===================================================================== *)
(* RenderSet: geo_set_animation_globals (rendering_graph_node.c), the     *)
(* render step's per-object animation advance, from the real generated    *)
(* Clight.  Footprint: only the node's animFrame / animTimer /            *)
(* animFrameAccelAssist and the six gCurrAnim* render globals             *)
(* (RenderAnim.rstore).  Range: the node's animFrame stays in             *)
(* [-1, loopEnd] (RenderAnim.guaf_range through the real call).           *)
(* ===================================================================== *)
From Coq Require Import ZArith Lia List Bool.
From compcert Require Import Coqlib Integers Floats Values AST Ctypes Cop Clight
  ClightBigstep Clightdefs Memory Maps Globalenvs Events Errors.
From SM64.Generated Require graph_node rendering_graph_node memory.
From SM64.Proofs.WMotRRequiresA Require Import RenderAnim.
Import ListNotations.

Local Open Scope Z_scope.

Section GSAG.
Variable ge : genv.
Hypothesis Hcenv : forall id co, (prog_comp_env graph_node.prog) ! id = Some co -> (genv_cenv ge) ! id = Some co.
Hypothesis Hguaf : forall b, Genv.find_symbol ge graph_node._geo_update_animation_frame = Some b ->
  Genv.find_funct_ptr ge b = Some (Internal graph_node.f_geo_update_animation_frame).
Hypothesis Hstv : forall b, Genv.find_symbol ge memory._segmented_to_virtual = Some b ->
  Genv.find_funct_ptr ge b = Some (Internal memory.f_segmented_to_virtual).

Ltac fo_any := first [ exact (fo_curAnim ge Hcenv) | exact (fo_animFrame ge Hcenv)
  | exact (fo_animTimer ge Hcenv) | exact (fo_accelAssist ge Hcenv) | exact (fo_animAccel ge Hcenv)
  | exact (fo_animYTrans ge Hcenv) | exact (fo_flags ge Hcenv) | exact (fo_divisor ge Hcenv)
  | exact (fo_loopStart ge Hcenv) | exact (fo_loopEnd ge Hcenv) | exact (fo_values ge Hcenv)
  | exact (fo_index ge Hcenv) ].

Ltac norm1 :=
  match goal with
  | H : eval_expr _ _ _ _ (Etempvar _ _) _ |- _ => apply ev_temp in H
  | H : eval_expr _ _ _ _ (Econst_int _ _) _ |- _ => apply ev_const in H; subst
  | H : eval_expr _ _ _ _ (Econst_single _ _) _ |- _ => apply ev_single in H; subst
  | H : eval_expr _ _ _ _ (Ebinop _ _ _ _) _ |- _ =>
      apply ev_binop in H; destruct H as (? & ? & ? & ? & H); cbn [typeof] in H
  | H : eval_expr _ _ _ _ (Ecast _ _) _ |- _ =>
      apply ev_cast in H; destruct H as (? & ? & H); cbn [typeof] in H
  | H : eval_expr _ _ _ _ (Efield _ _ _) _ |- _ =>
      eapply ev_fld in H; [ destruct H as (? & ? & ? & H) | fo_any | reflexivity ]
  | H : eval_expr _ _ _ _ (Eaddrof (Efield _ _ _) _) _ |- _ =>
      eapply ev_addr_fld in H; [ destruct H as (? & ? & ? & H) | fo_any ]; subst
  | H : eval_expr _ _ _ _ (Evar _ _) _ |- _ => clear H
  | H : (PTree.set _ _ _) ! _ = Some _ |- _ => progress getnorm H
  | H : Some _ = Some _ |- _ => injection H; clear H; intros; subst
  | H : Vptr _ _ = Vptr _ _ |- _ => injection H; clear H; intros; subst
  | H : sem_cast _ (tptr _) (tptr _) _ = Some _ |- _ => apply cast_ptr_id in H; subst
  end.

Ltac walk2 :=
  first [ walk1
        | match goal with H : exec_stmt _ _ _ _ _ (Scall _ _ _) _ _ _ _ |- _ =>
            apply call_inv in H;
            destruct H as (? & ? & ? & ? & ? & ? & ? & ? & ? & ? & ? & ? & ? & ? & ?); subst
          end ].

(* resolve a call: pin the callee from the global env, unfold the args *)
Ltac docall :=
  match goal with
  | Hfc : eval_funcall _ _ _ ?fd _ _ _ _, Hff : Genv.find_funct _ ?vf = Some ?fd,
    Hvf : eval_expr _ _ _ _ (Evar _ _) ?vf, Hcl : classify_fun _ = fun_case_f _ _ _ |- _ =>
      cbn [typeof classify_fun] in Hcl; injection Hcl; clear Hcl; intros; subst;
      let bf := fresh "bf" in let Hsym := fresh "Hsym" in
      apply ev_fun in Hvf; [ destruct Hvf as (bf & Hsym & ->) | reflexivity | reflexivity ];
      rewrite Genv.find_funct_find_funct_ptr in Hff;
      first [ rewrite (Hguaf _ Hsym) in Hff | rewrite (Hstv _ Hsym) in Hff ];
      injection Hff; clear Hff; intros; subst fd
  end.

Ltac exprlists :=
  repeat match goal with
  | H : eval_exprlist _ _ _ _ (_ :: _) _ _ |- _ => inv H
  | H : eval_exprlist _ _ _ _ nil _ _ |- _ => inv H
  end.

(* assignment -> store *)
Ltac assigns :=
  repeat match goal with
  | Hl : eval_lvalue _ _ _ _ (Efield _ _ _) _ _ _ |- _ =>
      eapply lv_fld in Hl; [ destruct Hl as (? & Hl & ? & ?); subst | fo_any ]
  | Hl : eval_lvalue _ _ _ _ (Evar _ _) _ _ _ |- _ =>
      apply lv_gvar in Hl; [ destruct Hl as (? & ? & ?); subst | reflexivity ]
  | Ha : assign_loc _ ?ty _ _ _ Full _ _ |- _ =>
      let Hs := fresh "Hs" in
      assert (Hs : Mem.store _ _ _ _ _ = Some _)
        by (eapply (store_by_value _ ty); [ reflexivity | reflexivity | exact Ha ]);
      clear Ha
  end.

Ltac casts :=
  repeat match goal with
  | H : sem_cast _ tshort tshort _ = Some _ |- _ => apply cast_ss_int in H; destruct H as (? & H); subst
  | H : sem_cast _ tushort tushort _ = Some _ |- _ => apply cast_us_int in H; destruct H as (? & H); subst
  | H : sem_cast _ tint tuchar _ = Some _ |- _ => apply cast_iuc_int in H; destruct H as (? & H); subst
  | H : sem_cast _ tfloat tfloat _ = Some _ |- _ => apply cast_ff_single in H; destruct H as (? & H); subst
  end.

Ltac chain :=
  repeat match goal with
  | |- stores_by _ ?a ?a => apply sb_refl
  | Hs : Mem.store ?ch ?a ?b ?z ?v = Some ?c |- stores_by _ ?a _ =>
      apply (sb_step _ _ c _ ch b z v); [ | exact Hs | ]
  end.

Ltac rcell :=
  split;
  [ first [ left; split; [ reflexivity | first [ left; split; reflexivity
                                              | right; left; split; reflexivity
                                              | right; right; split; reflexivity ] ]
          | right; match goal with
            | |- exists id, In id _ /\ Genv.find_symbol _ id = Some ?b /\ _ =>
                match goal with H : Genv.find_symbol _ ?id = Some b |- _ =>
                  exists id; split; [ cbn; tauto | split; [ exact H | reflexivity ] ] end
            end ]
  | intros ? ? ?; subst; try discriminate ].

Theorem gsag_footprint : forall m ob oi vh t m' vres,
  eval_funcall function_entry2 ge m (Internal rendering_graph_node.f_geo_set_animation_globals)
    [Vptr ob oi; vh] t m' vres ->
  stores_by (rstore ge ob oi m) m m'.
Proof.
  intros m ob oi vh t m' vres H.
  funcall_entry H.
  match goal with Hb : bind_parameter_temps _ _ _ = Some _ |- _ =>
    cbn [bind_parameter_temps rendering_graph_node.f_geo_set_animation_globals fn_params] in Hb;
    injection Hb as <- end.
  match goal with Hf : Mem.free_list _ _ = Some _ |- _ => cbn in Hf; injection Hf as <- end.
  match goal with Hx : exec_stmt _ _ _ _ _ _ _ _ _ _ |- _ =>
    cbn [rendering_graph_node.f_geo_set_animation_globals fn_body] in Hx end.
  repeat walk2.
  all: repeat docall.
  all: exprlists.
  all: cbn [typeof set_opttemp] in *.
  all: repeat norm1.
  all: repeat match goal with
       | Hfc : eval_funcall _ _ _ (Internal memory.f_segmented_to_virtual) _ _ _ _ |- _ =>
           apply stv_run in Hfc; destruct Hfc; subst
       | Hfc : eval_funcall _ _ _ (Internal graph_node.f_geo_update_animation_frame) _ _ _ _ |- _ =>
           apply (guaf_footprint ge Hcenv) in Hfc;
           destruct Hfc as [? | (? & ? & [(? & ?) | ?])]; subst
       end.
  all: assigns.
  all: repeat norm1.
  all: casts.
  all: chain.
  all: try rcell.
  all: match goal with
       | Hl : Mem.loadv _ ?mm (Vptr ?b0 ?o0) = Some (Vptr ?b' ?o')
         |- exists _ _, Mem.loadv Mptr ?mm _ = Some (Vptr ?b' ?o') /\ _ =>
           exists b0, o0; split; [ exact Hl |]
       end.
  all: first [ left; reflexivity | right; eexists; eassumption ].
Qed.

Lemma uadd : forall oi d, 0 <= d -> Ptrofs.unsigned oi + d <= Ptrofs.max_unsigned ->
  Ptrofs.unsigned (Ptrofs.add oi (Ptrofs.repr d)) = Ptrofs.unsigned oi + d.
Proof.
  intros oi d Hd Hm. pose proof (Ptrofs.unsigned_range oi) as R.
  unfold Ptrofs.add. rewrite (Ptrofs.unsigned_repr d) by lia.
  apply Ptrofs.unsigned_repr. lia.
Qed.

(* the node's animFrame after the render advance: in [-1, loopEnd] *)
Theorem gsag_frame : forall m ob oi vh t m' vres bt ot fr ls lend,
  eval_funcall function_entry2 ge m (Internal rendering_graph_node.f_geo_set_animation_globals)
    [Vptr ob oi; vh] t m' vres ->
  Ptrofs.unsigned oi + 20 <= Ptrofs.max_unsigned ->
  (forall id b, In id render_gvars -> Genv.find_symbol ge id = Some b -> b <> ob) ->
  Mem.loadv Mptr m (Vptr ob (Ptrofs.add oi (Ptrofs.repr 4))) = Some (Vptr bt ot) ->
  Mem.loadv Mint16signed m (Vptr ob (Ptrofs.add oi (Ptrofs.repr 8))) = Some (Vint fr) ->
  Mem.loadv Mint32 m (Vptr ob (Ptrofs.add oi (Ptrofs.repr 16))) = Some (Vint Int.zero) ->
  Mem.loadv Mint16signed m (Vptr bt (Ptrofs.add ot (Ptrofs.repr 6))) = Some (Vint ls) ->
  Mem.loadv Mint16signed m (Vptr bt (Ptrofs.add ot (Ptrofs.repr 8))) = Some (Vint lend) ->
  -1 <= Int.signed ls < Int.signed lend -> Int.signed lend <= 32766 ->
  -1 <= Int.signed fr <= Int.signed lend ->
  exists r, Mem.loadv Mint16signed m' (Vptr ob (Ptrofs.add oi (Ptrofs.repr 8))) = Some (Vint r)
            /\ -1 <= Int.signed r <= Int.signed lend.
Proof.
  intros m ob oi vh t m' vres bt ot fr ls lend H Hnw Hrg Pcur Pfr Pacc Pls Ple Rl Rle Rfr.
  assert (Pfr1 : forall v m1, Mem.store Mint32 m ob (Ptrofs.unsigned (Ptrofs.add oi (Ptrofs.repr 12))) v = Some m1 ->
            Mem.loadv Mint16signed m1 (Vptr ob (Ptrofs.add oi (Ptrofs.repr 8))) = Some (Vint fr)).
  { intros v m1 Hs. cbn [Mem.loadv] in *. rewrite (Mem.load_store_other _ _ _ _ _ _ Hs); [ exact Pfr |].
    right; left. rewrite !uadd by lia. cbn [size_chunk]. lia. }
  funcall_entry H.
  match goal with Hb : bind_parameter_temps _ _ _ = Some _ |- _ =>
    cbn [bind_parameter_temps rendering_graph_node.f_geo_set_animation_globals fn_params] in Hb;
    injection Hb as <- end.
  match goal with Hf : Mem.free_list _ _ = Some _ |- _ => cbn in Hf; injection Hf as <- end.
  match goal with Hx : exec_stmt _ _ _ _ _ _ _ _ _ _ |- _ =>
    cbn [rendering_graph_node.f_geo_set_animation_globals fn_body] in Hx end.
  repeat walk2.
  all: repeat docall.
  all: exprlists.
  all: cbn [typeof set_opttemp] in *.
  all: repeat norm1.
  all: repeat match goal with
       | Hfc : eval_funcall _ _ _ (Internal memory.f_segmented_to_virtual) _ _ _ _ |- _ =>
           apply stv_run in Hfc; destruct Hfc; subst
       | Hfc : eval_funcall _ _ _ (Internal graph_node.f_geo_update_animation_frame) _ _ _ _ |- _ =>
           pose proof (guaf_range ge Hcenv _ _ _ _ _ _ _ _ _ _ _ _ _ Hfc Pcur Pfr Pfr1 Pacc Pls Ple Rl Rle Rfr)
             as (? & ? & ?);
           apply (guaf_footprint ge Hcenv) in Hfc;
           destruct Hfc as [? | (? & ? & _)]; subst
       end.
  all: assigns.
  all: repeat norm1.
  all: repeat match goal with
       | H : sem_cast (Vint _) tshort tshort _ = Some _ |- _ => rewrite cast_s_s in H; injection H; clear H; intros; subst
       end.
  all: cbn [Mem.loadv] in *.
  all: repeat match goal with
       | |- exists r, Mem.load ?ch ?mK ?b ?z = Some (Vint r) /\ _ =>
           match goal with Hs : Mem.store ?ch' ?mJ ?b' ?z' ?v = Some mK |- _ =>
             first [ rewrite (Mem.load_store_same _ _ _ _ _ _ Hs)
                   | rewrite (Mem.load_store_other _ _ _ _ _ _ Hs);
                     [ | first [ left; apply not_eq_sym; match goal with Hg : Genv.find_symbol _ ?id = Some b' |- _ =>
                                     exact (Hrg id b' ltac:(cbn; tauto) Hg) end
                               | right; rewrite ?uadd by lia; cbn [size_chunk]; lia ] ] ]
           end
       end.
  all: cbn [Val.load_result].
  all: first [ exists fr; split; [ exact Pfr | lia ]
             | eexists; split; [ reflexivity |]; rewrite !sext16_idem; rewrite sext16_small by lia; lia ].
Qed.
End GSAG.
